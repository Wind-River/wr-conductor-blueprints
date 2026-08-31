#!/bin/bash
#
# ./hwcheck.sh [--option value] [--option value]
#
# Tests a hardware platform against a set of requirements.  The defaults
# come from the Hardware Compatibility guide in the WRCP installation
# namual.  This is described as a 4th gen or better Xeon, 2 disks of at least
# 500G, minimum 8 physical cores (excluding threads), 64GB RAM, at least  
# one 10G NIC for data, and a least 2 addition 1G or better NICs for
# Management.  Each of these requirement can be tweaked for a particular
# installation using command line flags seen below in the OPTIONS array.
#
SCRIPTPATH=$(realpath "${BASH_SOURCE:-$0}")
SCRIPTDIR=$(dirname $SCRIPTPATH)
CFGFILE=$SCRIPTDIR/hwcheck.cfg

#
# Make sure this is x86_64.  Don't even continue if it is not.
#
echo "Report for `uname -n`"
if [ `uname -m` = x86_64 ] ; then
    echo "    PASS: CPU architecture is x86_64"
else
    echo "    FAIL: CPU architecture is `uname -m`"
    exit
fi

#
# These are the defaulf options as per the Installation Guide for WRCP 25.09.
#
declare -A OPTIONS
OPTIONS["cpugen"]=4
OPTIONS["numdisks"]=2
OPTIONS["cpuspeed"]=2200
OPTIONS["mincores"]=8
OPTIONS["disksize"]=500
OPTIONS["ramsize"]=62
OPTIONS["tengig"]=1
OPTIONS["numnics"]=3

#
# Next, we also look for a file called hwcheck.cfg.  This is a simple option=val
# file with each option on a seperate line.  For example, to require 10-cores,
# 800G disks, 256G of RAM and 3 10G network interfaces, you would create a
# file with the following...  These values override the defaults for and AIO
# Simplex configuration.
# 
#  mincores=10
#  disksize=800
#  ramsize=250
#  tengig=3
#
if [ -e $CFGFILE ] ; then
    while IFS= read -r line; do
	IFS='= ' read -r -a NVP <<< $line
	OPTIONS["${NVP[0]}"]=${NVP[1]}
    done < $CFGFILE
fi

#
# Finally, each of these can be modified by using '--option val' on the command line.
# So, if all else was good, but I need extra storage, say 2TB, the command is:
#
#     ./hwcheck.sh --disksize 2048 
#
while [ "$1" != "" ] ; do
    if [[ "$1" =~ ^-- ]]; then
	opt=`echo $1 | sed -e 's/^--//'`
	if [ "${OPTIONS[$opt]}" != "" ] ; then
	    OPTIONS["$opt"]=$2
	    shift
	fi
    fi
    shift
done

#
# The code below prints out the array after processing the command line
#
#for key in ${!OPTIONS[@]}; do
#    echo "  ${key}: ${OPTIONS[${key}]}"
#done

export XEON=FALSE
export CPUGEN=0
export TOTALSTORAGE=0
export DISKSFOUND=0
export SMALLDISK=0
export SMALLSTORAGE=0
export ONEGIG=0
export TENGIG=0
declare -a ETHDEVS
declare -A DISKS
CPUMODEL=$(cat /proc/cpuinfo | grep '^model name' | head -n 1 | sed -E 's/model name[[:space:]]+:[[:space:]]+//')
CPUTHREADS=$(cat /proc/cpuinfo | grep -c '^model name')
IFS='()- ' read -r -a MODELINFO <<< $CPUMODEL
for opt in "${!MODELINFO[@]}"
do
    if [ "`echo ${MODELINFO[$opt]} | tr '[:lower:]' '[:upper:]'`" = "XEON" ] ; then
	XEON=TRUE
    elif [ "$CPUGEN" = "0" -o "$CPUGEN" = "" ] ; then
	DIGITS=`echo ${MODELINFO[$opt]} | tr -cd '[:digit:]'`
	if [ "$DIGITS" != "" ] ; then
	    CPUGEN=$(expr $DIGITS \/ 1000)
	fi
    fi
done
CORESPERCPU=$(awk '/^cpu cores/{print $4}'  /proc/cpuinfo | tail -n 1)
NUMCPUS=$(cat /proc/cpuinfo | grep 'physical id' | sort -u | wc -l)
TOTALCORES=$(expr $CORESPERCPU \* $NUMCPUS)

if [ $XEON = TRUE ] ; then
    echo "    PASS: Xeon CPU '$CPUMODEL' detected"
else
    echo "    FAIL: CPU '$CPUMODEL' is not a Xeon class CPU"
fi
if [[ $CPUGEN -ge ${OPTIONS["cpugen"]} ]]; then
    echo "    PASS: CPU Generation is >= ${OPTIONS['cpugen']}"
else
    echo "    FAIL: CPU $CPUMODEL is not >= Gen ${OPTIONS['cpugen']}"
fi
if [[ $TOTALCORES -ge ${OPTIONS["mincores"]} ]]; then
    echo "    PASS: $TOTALCORES cores ($CPUTHREADS threads) detected $NUMCPUS CPUs with $CORESPERCPU cores each"
else
    echo "    FAIL: Expecting at least ${OPTIONS['mincores']} physical cores.  Detected $NUMCPUS CPUs with $CORESPERCPU core(s) each, $CPUTHREADS total threads"
fi
MAXSPEED=$(lscpu | grep 'CPU max MHz' |  awk -F':' '{print $2}' |  awk -F'.' '{print $1}' | tr -dc '0-9')
if [[ $MAXSPEED -ge ${OPTIONS["cpuspeed"]} ]]; then
    echo "    PASS: CPU max speed ${MAXSPEED}Mhz is >= ${OPTIONS['cpuspeed']}Mhz"
else
    echo "    FAIL: CPU max speed ${MAXSPEED}Mhz is below recommended speed ${OPTIONS['cpuspeed']}Mhz"
fi

#
# Get the total memory installed.  We want 64G, but there will always be
# some memory unavailable.  MemTotal is in kB, so we divide by 1024 twice
# to get GB.  We want this value to be at least 62.
#
MEMGB=$(expr `awk '/^MemTotal:/{print $2}' /proc/meminfo` / 1048576 )
if [[ $MEMGB -ge ${OPTIONS["ramsize"]} ]]; then
    echo "    PASS: Memory available is $MEMGB Gb"
else
    echo "    FAIL: Insufficient memory. ${OPTIONS['ramsize']}G desired, $MEMGB detected"
fi

#
# Get information on disks.  We need at least 2 disks that are 500G or more each.
#
readarray -t DISKDATA <<< $(lsblk | grep -e '^sd' -e '^nvme')
for line in "${!DISKDATA[@]}"
do
    read -ra TEMP <<< ${DISKDATA[$line]}
    case ${TEMP[3]} in
	*T )
	    # Convert TB to GB
	    SIZE=$(echo ${TEMP[3]} | sed 's/T//' | awk '{printf "%d\n", $1 * 1000}')
	    ;;
	*G )
	    # Get GB Size
	    SIZE=$(echo ${TEMP[3]} | sed -e 's/\..*//')
	    ;;
	* )
	    SIZE=0
	    ;;
    esac

    # If this disk is large enough per the spec, include it in the count
    if [ $SIZE -ge ${OPTIONS["disksize"]} ] ; then
	DISKSFOUND=`expr $DISKSFOUND + 1`
	TOTALSTORAGE=$(expr $SIZE + $TOTALSTORAGE)
    elif [ $SIZE -gt 0 ] ; then
	SMALLDISK=`expr $SMALLDISK + 1`
	SMALLSTORAGE=$(expr $SIZE + $SMALLSTORAGE)
    fi
done
if [ $DISKSFOUND -ge ${OPTIONS["numdisks"]} ] ; then
    echo -n "    PASS: $DISKSFOUND disks of at least ${OPTIONS['disksize']}G detected with ${TOTALSTORAGE}G, "
    if [ $SMALLDISK -gt 0 ] ; then
	echo -n " $SMALLDISK additional smaller disks totaling ${SMALLSTORAGE}G found"
    fi
    echo ""
else
    echo -n "    FAIL: $DISKSFOUND disk(s) of ${OPTIONS['disksize']}G+ found with ${TOTALSTORAGE}G total storage,"
    if [ $SMALLDISK -gt 0 ] ; then
	echo -n " $SMALLDISK smaller disks totaling ${SMALLSTORAGE}G found, "
    fi
    echo " required ${OPTIONS['numdisks']} disks with ${TOTALSTORAGE}G+ each"
fi

#
# This is the last thing we need to do...  Minimum Network needs are
#
#     MGMT: 1x1GE ( Recommended: MGMT 2x10GE LAG ) Only required if subcloud is in Distributed Cloud.
#     OAM: 1x1GE (Recommended: OAM: 2x1GE LAG)
#     Data: 1 or more x 10GE (Recommended: Data: 2x10GE LAG)
#
# So, we look for PCI ethernet devices.  We then make sure there is at least 1-10G and 2-1G networks.
#     3+ 10G is Good
#     2 10G and 1 1G
#     1 10G and 2 1G
# anything else is a FAIL
#
# We use lspci to find physical devices, then use /sys/class/pci_bus to find the assigned name, and
# finally ethtool to get the available link speeds.
#
readarray -t PCINICS <<< $(lspci | grep Ethernet)
for line in "${!PCINICS[@]}"
do
    read -ra TEMP <<< ${PCINICS[$line]}
    IFS=':.' read -r -a BDF <<< ${TEMP[0]}
    ETHDEVS+=("`ls /sys/class/pci_bus/0000:${BDF[0]}/device/0000:${TEMP[0]}/net`")
done
for dev in "${!ETHDEVS[@]}"
do
    readarray -t ETHTOOL <<< $(ethtool ${ETHDEVS[$dev]} 2>/dev/null)
    FOUNDSPEEDS=FALSE
    MAXSPEED=0
    for line in "${!ETHTOOL[@]}"
    do
	if [[ "${ETHTOOL[$line]}" =~ "Supported link modes:" ]]; then
	    FOUNDSPEEDS=TRUE
	elif [[ "${ETHTOOL[$line]}" =~ "Supported" ]]; then
	    if [ $FOUNDSPEEDS = TRUE ] ; then
		break
	    fi
	fi
	if [ $FOUNDSPEEDS = TRUE ] ; then
	    DIGITS=`echo ${ETHTOOL[$line]} | sed -e 's|/.*||' | tr -cd '[:digit:]'`
	    if [ $DIGITS -gt $MAXSPEED ] ; then
		MAXSPEED=$DIGITS
	    fi
	fi
    done
    if [ $MAXSPEED -ge 10000 ] ; then
	TENGIG=`expr $TENGIG + 1`
    elif [ $MAXSPEED -eq 1000 ] ; then
	ONEGIG=`expr $ONEGIG + 1`
    fi
done

NETGOOD=TRUE
if [ $TENGIG -lt ${OPTIONS["tengig"]} ] ; then
    NETGOOD=FALSE
fi
if [ `expr $TENGIG + $ONEGIG` -lt ${OPTIONS["numnics"]} ] ; then
    NETGOOD=FALSE
fi
if [ $NETGOOD = TRUE ] ; then
    echo "    PASS: Network Interfaces Found $TENGIG 10G and $ONEGIG 1G"
else
    echo "    FAIL: Insufficient network interfaces ($TENGIG 10G and $ONEGIG 1G)"
fi

echo "  BIOS Setting Checks:"
# Make sure VM-x is available and the EPT is supported
if [ "`grep '^vmx flags' /proc/cpuinfo | grep ept | wc -l`" != "0" ] ; then
    echo "    PASS: VT-x is turned ON in"
else
    echo "    FAIL: VT-x is turned OFF"
fi

# While not technically needed, the manual does say to have Hyperthreading enabled.
if [ $CPUTHREADS -gt $TOTALCORES ]; then
    echo "    PASS: Hyperthreading is ENABLED"
else
    echo "    FAIL: Hyperthreading is DISABLED"
fi

# While not technically needed, the manual does say to have Hyperthreading enabled.
if [ "`cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`" = "performance" ]; then
    echo "    PASS: CPU power mode is set to performance"
else
    echo "    FAIL: CPU power mode is not set for performance"
fi

#
# TODO: Other BIOS features that are not testable without SUDO... 
#
if [ "`id -u`" = "0" ] ; then
    if [ `dmesg | grep -e 'ACPI: Reserving DMAR table' -e 'Intel-IOMMU: enabled' | wc -l` -gt 0 ] ; then
	echo "    PASS: VT-d is ENABLED"
    else
	echo "    FAIL: VT-d is DISABLED"
    fi	
else
    echo "    SKIP: VT-d status requires ROOT access to validate"
fi

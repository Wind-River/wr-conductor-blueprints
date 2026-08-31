#!/bin/bash
set -e

KERNEL="/opt/vxworks/vxWorks"
APP_DIR="/opt/vxworks/app"

QEMU_ARGS="-m ${QEMU_MEM:-4G} -smp ${QEMU_SMP:-4}"
QEMU_ARGS="$QEMU_ARGS -display none -serial mon:stdio"
QEMU_ARGS="$QEMU_ARGS -net nic -net user,hostfwd=tcp::1534-:1534,hostfwd=tcp::2345-:2345,hostfwd=tcp::10023-:23"
QEMU_ARGS="$QEMU_ARGS -append \"bootline:fs(0,0)host:vxWorks h=10.0.2.2 f=0x40 u=ftp pw=ftp o=gei0 s=/bd0a/start.cmd\""
QEMU_ARGS="$QEMU_ARGS -kernel $KERNEL"
QEMU_ARGS="$QEMU_ARGS -usb -device usb-ehci,id=ehci"
QEMU_ARGS="$QEMU_ARGS -device usb-storage,drive=fat32 -drive file=fat:rw:$APP_DIR,id=fat32,format=raw,if=none"

eval exec qemu-system-x86_64 $QEMU_ARGS

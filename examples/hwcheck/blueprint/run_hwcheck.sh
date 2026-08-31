#!/bin/bash
# Wrapper: deploys hwcheck.sh + hwcheck.cfg to remote, runs it, stores output via ctx
WORKDIR=/tmp/hwcheck
mkdir -p $WORKDIR

# Download the blueprint resources from the manager
ctx download-resource hwcheck.sh "$WORKDIR/hwcheck.sh"
ctx download-resource hwcheck.cfg "$WORKDIR/hwcheck.cfg"
chmod +x "$WORKDIR/hwcheck.sh"

# Run and capture output
OUTPUT=$(bash "$WORKDIR/hwcheck.sh" 2>&1)
echo "$OUTPUT"

# Store result as runtime property
ctx instance runtime-properties hwcheck_output "$OUTPUT"

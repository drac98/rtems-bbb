#!/bin/sh

JLinkGDBServerCLExe -device Cortex-A7 -endian little -if JTAG -speed 10000

# find out own directory
#SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
#
#openocd -f interface/jlink.cfg -f ${SCRIPTDIR}/rpi2/rpi2.cfg -c "gdb_port 2331"

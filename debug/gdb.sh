#!/bin/sh

# find out own directory
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export PROJECTDIR="${SCRIPTDIR}/../"

${PROJECTDIR}/install/rtems/6/bin/arm-rtems6-gdb -x ${SCRIPTDIR}/start.gdb $@

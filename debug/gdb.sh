#!/bin/bash

# find out own directory
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECTDIR="${SCRIPTDIR}/../"

# configuration
. "${PROJECTDIR}/build/configuration.sh"

PORT=1234

${PREFIX}/bin/${RTEMS_CPU}-rtems${RTEMS_VERSION}-gdb -x ${SCRIPTDIR}/start.gdb $@ \
	-ex "reset" \
	$BINARY

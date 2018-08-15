#! /usr/bin/env sh

# be more verbose
set -x
# exit on wrong command and undefined variables
set -e -u

# find out own directory
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECTDIR="${SCRIPTDIR}/../"

# Configuration
. "${SCRIPTDIR}/configuration.sh"
export PATH="${PREFIX}/bin:${PATH}"

# Evaluate options
make_targets="all"
for i in "$@" ; do
	case "$i" in
	clean)
		make_targets="clean all"
		;;
	*)
		echo "Unexpected option: '$i'"
		exit 1
		;;
	esac
done

cd $PROJECTDIR/apps/fio
export TOOL_PATH_PREFIX=$PREFIX
./configure --cc=$PREFIX/bin/arm-rtems5-gcc --disable-optimizations --extra-cflags=-O3
make -j`nproc` CROSS_COMPILE=$PREFIX/bin/arm-rtems5- V=1

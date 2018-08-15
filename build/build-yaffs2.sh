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

cd "libs/rtems-yaffs2"

BUILD_TARGET="all"

# Evaluate options
DO_CLEAN=0
DO_INSTALL=0
for i in "$@" ; do
	case "$i" in
	clean)
		DO_CLEAN=1
		;;
	install)
		DO_INSTALL=1
		;;
	*)
		echo "Unexpected option: '$i'"
		exit 1
		;;
	esac
done

# Build and install libbsd
if [ $DO_CLEAN -ne 0 ]
then
	BUILD_TARGET="clean all"
fi
if [ $DO_INSTALL -ne 0 ]
then
	BUILD_TARGET="$BUILD_TARGET install"
fi

export RTEMS_MAKEFILE_PATH="${PREFIX}/${RTEMS_CPU}-rtems${RTEMS_VERSION}/${BSP_NAME}/"

make -f Makefile.rtems $BUILD_TARGET

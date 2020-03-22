# This script is expected to be sourced. It expects the following variables to
# be already set:
#   $PROJECTDIR -- set to the base dir of the project

BSP_NAME="raspberrypi2"
RTEMS_CPU="arm"
RTEMS_VERSION="5"
TARGET="${RTEMS_CPU}-rtems${RTEMS_VERSION}"
PREFIX="${PROJECTDIR}/install/rtems/${RTEMS_VERSION}/"
DTS_FILE="sys/gnu/dts/arm/bcm2836-rpi-2-b.dts"
DTB_INSTALL_NAME="bcm2836-rpi-2-b.dtb"

RSB_DIR="${PROJECTDIR}/tools/rtems-source-builder"
RTEMS_SOURCE_DIR="${PROJECTDIR}/libs/rtems"
LIBBSD_SOURCE_DIR="${PROJECTDIR}/libs/rtems-libbsd"
DEVICETREE_DIR="${PROJECTDIR}/tools/devicetree-freebsd-export"
DEVICETREEOVERLAY_DIR="${PROJECTDIR}/tools/devicetree-overlays"

BSP_CONFIG_OPT="
	--enable-tests=samples
	--disable-networking
	"

export CFLAGS_OPTIMIZE_V="-O0 -g"

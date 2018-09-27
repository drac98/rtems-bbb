# This script is expected to be sourced. It expects the following variables to
# be already set:
#   $PROJECTDIR -- set to the base dir of the project

BSP_NAME="xilinx_zynq_a9_qemu"
RTEMS_CPU="arm"
RTEMS_VERSION="5"
TARGET="${RTEMS_CPU}-rtems${RTEMS_VERSION}"
PREFIX="${PROJECTDIR}/install/rtems/${RTEMS_VERSION}/"

RSB_DIR="${PROJECTDIR}/tools/rtems-source-builder"
RTEMS_SOURCE_DIR="${PROJECTDIR}/libs/rtems"
LIBBSD_SOURCE_DIR="${PROJECTDIR}/libs/rtems-libbsd"
QEMU_SOURCE_DIR="${PROJECTDIR}/tools/qemu"

BSP_CONFIG_OPT="
	--enable-tests=samples
	--disable-networking
	"

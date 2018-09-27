#!/bin/bash

# exit on wrong command and undefined variable
set -e
set -u
# The following one only works for bash. It catches the fail of the first
# command in a pipe. e.g. 'which asdf | true' would fail due to the missing asdf
# command.
set -o pipefail

# find out own directory
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECTDIR="${SCRIPTDIR}/../"

# configuration
. "${PROJECTDIR}/build/configuration.sh"

BINDIR="${PROJECTDIR}/install/rtems/5/bin/"

VERBOSE=0
PORT=1234
ARCH="arm"
QEMU_PARAMS=""
QEMU_NET="-net none"
QEMU_MAC=""
SCRIPTNAME=$0
BSP="xilinx_zynq_a9_qemu"

# Print a error message and exits with 1
# Arguments:
#	0: message
printerror () {
	echo "ERROR: $1"
	echo ""
	echo "Call with \"${SCRIPTNAME} -h\" for help."
	exit 1
}

# Check if the parameter is a program. Print error and exit if not.
# Arguments:
#	0: program name
test_command () {
	if ! which $1 >/dev/null 2>&1
	then
		printerror "Command \"$1\" not found."
	fi
}

# Print a message depending on verbose level (set in ${VERBOSE}).
# Arguments:
#	0: message will be printed on this level
#	1: message
print_msg () {
	local LEVEL="$1"
	local MSG="$2"

	if [ ${LEVEL} -le ${VERBOSE} ]
	then
		echo "${MSG}"
	fi
}

# Print a help text and exit
# Arguments:
#	n.a.
printhelp () {
	echo ""
	echo "Call:   ${SCRIPTNAME} [<options>] <binary>"
	echo "Start an qemu with a given binary."
	echo ""
	echo "The following parameters are optional:"
	echo "  -b          BSP. Default: $BSP"
	echo "  -h          Print this help and exit the script."
	echo "  -n <IF>     Enable network and connect to <IF>. <IF> can for"
	echo "              example be \"qtap1\". Not on sparc."
	echo "  -s          Use smp with two cores."
	echo "  -p <PORT>   Start gdb-server on given port. Use 0 for no gdb."
	echo "              Default: $PORT"
	echo "  -v          Be more verbose. Can be used multiple times."
	echo ""
	echo "The following BSPs are supported:"
	cat ${SCRIPTNAME} | grep "xxRTEMS-BSP" | grep -v "grep" | grep -o -e "\".*\"" | tr '"' ' '
	exit 0
}

# The main script

# generate random MAC
test_command "shuf"
test_command "printf"

QEMU_MAC=`shuf -i 0-255 -n 4 -z | xargs -0 -- printf "0e:b0:%02x:%02x:%02x:%02x"`

# Read options
while getopts "b:hn:sp:v" OPTION
do
	case $OPTION in
		b)  BSP=$OPTARG ;;
		h)  printhelp ;;
		n)  QEMU_NET="-net nic,model=cadence_gem,macaddr=${QEMU_MAC} -net tap,ifname=${OPTARG},script=no,downscript=no" ;;
		s)  QEMU_PARAMS="$QEMU_PARAMS -smp 2 -icount auto" ;;
		p)  PORT=$OPTARG ;;
		v)  VERBOSE=$(($VERBOSE + 1)) ;;
		\?) printerror "Unknown option \"-$OPTARG\"." ;;
		:)  printerror "Option \"-$OPTARG\" needs an argument." ;;
	esac
done
# Remove the already processed ones
shift $(($OPTIND - 1))

[[ $VERBOSE -gt 2 ]] && set -x

# Set architecture specific options
case "$BSP" in
	"xilinx_zynq_a9_qemu") # xxRTEMS-BSP
		QEMU_PARAMS="$QEMU_PARAMS ${QEMU_NET} -serial null -serial mon:stdio -nographic -M xilinx-zynq-a9 -m 256M"
		QEMU="qemu-system-arm"
		ARCH="arm"
		;;
	*)
		printerror "Unknown architecture: $ARCH"
		;;
esac

# Process all parameters without dash
[[ $# -lt 1 ]] && printerror "Need a binary."

while [ $# -ge 1 ]
do
	if [ $PORT -ne 0 ]
	then
		QEMU_PARAMS="-gdb tcp::$PORT -S $QEMU_PARAMS"
	else
		QEMU_PARAMS="-no-reboot $QEMU_PARAMS"
	fi

	# Check commands
	test_command "$BINDIR/$QEMU"

	# Start qemu
	print_msg 1 "Disabling audio."
	export QEMU_AUDIO_DRV=none

	print_msg 0 "--------------------------------------------------------------"
	print_msg 0 "Starting qemu."
	print_msg 0 "Press \"ctrl-a h\" for help."
	[[ $PORT -ne 0 ]] && print_msg 0 "gdb-server is started on tcp::$PORT"
	print_msg 1 "call: $BINDIR/$QEMU $QEMU_PARAMS -kernel \"$1\""
	print_msg 0 "--------------------------------------------------------------"

	$BINDIR/$QEMU $QEMU_PARAMS -kernel "$1"
	shift
done

# vim: set ts=4 sw=4:

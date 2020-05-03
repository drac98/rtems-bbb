# Note: $(PWD) doesn't work if called from another path with -C option of make.
MAKEFILE_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PROJDIR = $(MAKEFILE_DIR)

RTEMS_VERSION = 5

MACHINE = arm
BSP = beagleboneblack
UBOOT_CONFIG="am335x_boneblack_defconfig"

PREFIX = $(PROJDIR)/install/rtems/5
RSB = $(PROJDIR)/tools/rtems-source-builder
SRC_RTEMS = $(PROJDIR)/libs/rtems
SRC_LIBBSD = $(PROJDIR)/libs/rtems-libbsd
SRC_UBOOT = $(PROJDIR)/tools/u-boot
SRC_DEVICETREE = $(PROJDIR)/devicetree
SRC_NEWFS_MSDOS = $(PROJDIR)/tools/newfs_msdos
SRC_PARTITION = $(PROJDIR)/tools/partition
SRC_MTOOLS = $(PROJDIR)/tools/mtools
FDT_MAIN_FILE = sys/gnu/dts/arm/am335x-boneblack.dts
BUILD_BSP = $(PROJDIR)/build/b-$(BSP)
TAGFILE = $(PROJDIR)/tags

OPTIMIZATION = 0

export PREFIX
export PATH := $(PREFIX)/bin:$(PATH)
export CFLAGS_OPTIMIZE_V ?= -O$(OPTIMIZATION) -g -ffunction-sections -fdata-sections

help:
	@##H## Show some help.
	@ grep -B 1 '@##H##' $(firstword $(MAKEFILE_LIST)) \
		| grep -v grep | grep -v -- "--" | sed -e 's/@##H##//g'

setup: submodule-update toolchain u-boot dtb newfs-msdos partition mtools bootstrap bsp libbsd ctags
	@##H## Basic setup. Use with care.

newfs-msdos:
	cd $(SRC_NEWFS_MSDOS) && make
	cd $(SRC_NEWFS_MSDOS) && make install

partition:
	cd $(SRC_PARTITION) && make partition
	mkdir -p $(PREFIX)/bin
	mv $(SRC_PARTITION)/partition $(PREFIX)/bin

mtools:
	cd $(SRC_MTOOLS) && make
	cd $(SRC_MTOOLS) && make install

submodule-update:
	@##H## Update the submodules.
	git submodule init
	git submodule update $(RSB)
	git submodule update $(SRC_RTEMS)
	git submodule update $(SRC_LIBBSD)
	git submodule update $(SRC_UBOOT)
	cd $(SRC_LIBBSD) && git submodule init rtems_waf
	cd $(SRC_LIBBSD) && git submodule update rtems_waf

toolchain:
	@##H## Build the toolchain.
	rm -rf $(RSB)/rtems/build
	cd $(RSB) && ./source-builder/sb-check
	cd $(RSB)/rtems && ../source-builder/sb-set-builder \
		--log=$(RSB)/b-rsb-$(MACHINE)-$(sh date +%Y%m%d_%H%M%S).log \
		--prefix=$(PREFIX) \
		--without-rtems \
		$(RTEMS_VERSION)/rtems-$(MACHINE)
	rm -rf $(RSB)/rtems/build

dtc:
	@##H## Build the dtc.
	rm -rf $(RSB)/rtems/build
	cd $(RSB) && ./source-builder/sb-check
	cd $(RSB)/rtems && ../source-builder/sb-set-builder \
		--log=$(RSB)/b-rsb-dtc-$(sh date +%Y%m%d_%H%M%S).log \
		--prefix=$(PREFIX) \
		devel/dtc
	rm -rf $(RSB)/rtems/build

u-boot:
	@##H## Build an U-Boot.
	cd "$(SRC_UBOOT)" && make -j `nproc` PYTHON=python2 \
		CROSS_COMPILE=$(MACHINE)-rtems$(RTEMS_VERSION)- mrproper
	cd "$(SRC_UBOOT)" && make -j `nproc` PYTHON=python2 \
		CROSS_COMPILE=$(MACHINE)-rtems$(RTEMS_VERSION)- $(UBOOT_CONFIG)
	cd "$(SRC_UBOOT)" && make -j `nproc` PYTHON=python2 \
		CROSS_COMPILE=$(MACHINE)-rtems$(RTEMS_VERSION)-
	mkdir -p $(PREFIX)/uboot/$(UBOOT_CONFIG)/
	cp $(SRC_UBOOT)/MLO $(SRC_UBOOT)/u-boot.img $(PREFIX)/uboot/$(UBOOT_CONFIG)/
	mkdir -p $(PREFIX)/bin
	cp $(SRC_UBOOT)/tools/mkimage $(PREFIX)/bin

dtb:
	@##H## Create all device tree binaries.
	make -C $(SRC_DEVICETREE) MACHINE=$(MACHINE) install

bootstrap:
	@##H## Execute bootstrap for RTEMS.
	cd $(SRC_RTEMS) && $(RSB)/source-builder/sb-bootstrap

bsp:
	@##H## Build the BSP.
	rm -rf $(BUILD_BSP)
	mkdir -p $(BUILD_BSP)
	cd $(BUILD_BSP) && $(SRC_RTEMS)/configure \
		--target=$(MACHINE)-rtems$(RTEMS_VERSION) \
		--prefix=$(PREFIX) \
		--enable-posix \
		--enable-rtemsbsp=$(BSP) \
		--enable-maintainer-mode \
		--enable-rtems-debug \
		--disable-networking \
		--enable-tests=samples \
		CONSOLE_POLLED=1
	cd $(BUILD_BSP) && make -j `nproc`
	cd $(BUILD_BSP) && make -j `nproc` install
	# Generate .mk file
	mkdir -p "$(PREFIX)/make/custom/"
	cat "$(PROJDIR)/build/src/bsp.mk" | \
		sed 	-e "s/##RTEMS_API##/$(RTEMS_VERSION)/g" \
			-e "s/##RTEMS_BSP##/$(BSP)/g" \
			-e "s/##RTEMS_CPU##/$(MACHINE)/g" \
		> "$(PREFIX)/make/custom/$(BSP).mk"

libbsd:
	@##H## Build the libbsd.
	rm -rf $(SRC_LIBBSD)/build
	cd $(SRC_LIBBSD) && ./waf configure \
		--prefix=$(PREFIX) \
		--rtems-bsps=$(MACHINE)/$(BSP) \
		--buildset=$(PROJDIR)/build/src/noipsec.ini \
		--enable-warnings \
		--optimization=$(OPTIMIZATION)
	cd $(SRC_LIBBSD) && ./waf
	cd $(SRC_LIBBSD) && ./waf install

ctags:
	@##H## Tags for VI
	rm -f $(TAGFILE)
	ctags -a -f $(PROJDIR)/tags --extras=+fq --recurse=yes \
		"$(SRC_RTEMS)"
	ctags -a -f $(PROJDIR)/tags --extras=+fq --recurse=yes \
		--exclude="freebsd-org" "$(SRC_LIBBSD)"

zsh:
	@##H## Start a new shell with a matching environment
	export PREPROMPT='%B(BBB-RTEMS)%b ' && zsh

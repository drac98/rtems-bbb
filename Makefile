# Note: $(PWD) doesn't work if called from another path with -C option of make.
MAKEFILE_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PROJDIR = $(MAKEFILE_DIR)

RTEMS_VERSION = 6

MACHINE = arm
BSP = beagleboneblack
UBOOT_CONFIG="am335x_boneblack_defconfig"

PREFIX = $(PROJDIR)/install/rtems/$(RTEMS_VERSION)
RSB = $(PROJDIR)/tools/rtems-source-builder
SRC_RTEMS = $(PROJDIR)/libs/rtems
SRC_LIBBSD = $(PROJDIR)/libs/rtems-libbsd
SRC_APPS = $(PROJDIR)/apps
SRC_LVGL = $(PROJDIR)/libs/rtems-littlevgl
SRC_UBOOT = $(PROJDIR)/tools/u-boot
SRC_DEVICETREE = $(PROJDIR)/devicetree
SRC_NEWFS_MSDOS = $(PROJDIR)/tools/newfs_msdos
SRC_PARTITION = $(PROJDIR)/tools/partition
SRC_MTOOLS = $(PROJDIR)/tools/mtools
BUILD_BSP = $(PROJDIR)/build/b-$(BSP)
TAGFILE = $(PROJDIR)/tags

OPTIMIZATION = 2

export PREFIX
export PATH := $(PREFIX)/bin:$(PATH)
export CFLAGS_OPTIMIZE_V ?= -O$(OPTIMIZATION) -g -ffunction-sections -fdata-sections

help:
	@##H## Show some help.
	@ grep -B 1 '@##H##' $(firstword $(MAKEFILE_LIST)) \
		| grep -v grep | grep -v -- "--" | sed -e 's/@##H##//g'

setup: submodule-update toolchain u-boot dtb newfs-msdos partition mtools sd-image-script bsp libbsd lvgl ctags
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
	git submodule update $(SRC_LVGL)
	cd $(SRC_LIBBSD) && git submodule init rtems_waf
	cd $(SRC_LIBBSD) && git submodule update rtems_waf
	cd $(SRC_LVGL) && git submodule init
	cd $(SRC_LVGL) && git submodule update

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
		devel/dtc-1.6.0-1
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

sd-image-script:
	@##H## Copy script for creating sd images
	cp $(PROJDIR)/build/create-sdcardimage.sh $(PREFIX)/bin

dtb:
	@##H## Create all device tree binaries.
	make -C $(SRC_DEVICETREE) MACHINE=$(MACHINE) install

bsp:
	@##H## Build the BSP.
	cd $(SRC_RTEMS) && ./waf clean || true
	cd $(SRC_RTEMS) && ./waf bsp_defaults --rtems-bsps=$(MACHINE)/$(BSP) > config.ini
	cd $(SRC_RTEMS) && sed -i \
		-e "s|RTEMS_POSIX_API = False|RTEMS_POSIX_API = True|" \
		config.ini
	cd $(SRC_RTEMS) && ./waf configure --prefix=$(PREFIX)
	cd $(SRC_RTEMS) && ./waf
	cd $(SRC_RTEMS) && ./waf install

libbsd:
	@##H## Build the libbsd.
	rm -rf $(SRC_LIBBSD)/build
	cd $(SRC_LIBBSD) && ./waf configure \
		--prefix=$(PREFIX) \
		--rtems-bsps=$(MACHINE)/$(BSP) \
		--buildset=$(PROJDIR)/build/src/noipsec.ini \
		--enable-warnings \
		--optimization=$(OPTIMIZATION) \
		--rtems-version=6
	cd $(SRC_LIBBSD) && ./waf
	cd $(SRC_LIBBSD) && ./waf install

lvgl:
	@##H## Build littlevgl.
	rm -rf $(SRC_LVGL)/build
	cd $(SRC_LVGL) && python2 ./waf configure \
		--prefix=$(PREFIX) \
		--rtems-version=$(RTEMS_VERSION)
	cd $(SRC_LVGL) && python2 ./waf
	cd $(SRC_LVGL) && python2 ./waf install

ctags:
	@##H## Tags for VI
	rm -f $(TAGFILE)
	ctags -a -f $(PROJDIR)/tags --extras=+fq --recurse=yes \
		"$(SRC_RTEMS)"
	ctags -a -f $(PROJDIR)/tags --extras=+fq --recurse=yes \
		--exclude="freebsd-org" "$(SRC_LIBBSD)"

.PHONY: apps
apps:
	@##H## Build applications
	rm -rf $(SRC_APPS)/build
	cd $(SRC_APPS) && ./waf configure \
		--prefix=$(PREFIX) \
		--rtems-version=$(RTEMS_VERSION)
	cd $(SRC_APPS) && ./waf

zsh:
	@##H## Start a new shell with a matching environment
	export PREPROMPT='%B(BBB-RTEMS)%b ' && zsh

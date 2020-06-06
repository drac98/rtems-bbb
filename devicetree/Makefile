MAKEFILE_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

FREEBSD = $(MAKEFILE_DIR)/freebsd-export
TARGETDIR = $(PREFIX)/fdt
DTS_PATH = $(FREEBSD)/sys/gnu/dts/arm/
MAIN_DTS = am335x-boneblack.dts am335x-pocketbeagle.dts
MAIN_DTB = $(MAIN_DTS:%.dts=$(TARGETDIR)/%.dtb)
OVERLAY_DTS = $(wildcard $(MAKEFILE_DIR)/*.dtso)
OVERLAY_DTBO = $(OVERLAY_DTS:$(MAKEFILE_DIR)/%.dtso=$(PREFIX)/fdt/%.dtbo)

install: $(TARGETDIR) $(MAIN_DTB) $(OVERLAY_DTBO)

export MACHINE

$(TARGETDIR):
	mkdir -p $(TARGETDIR)

$(TARGETDIR)/%.dtb: $(DTS_PATH)/%.dts
	echo $<
	$(FREEBSD)/sys/tools/fdt/make_dtb.sh $(FREEBSD)/sys $< $(TARGETDIR)

$(TARGETDIR)/%.dtbo: $(MAKEFILE_DIR)/%.dtso
	dtc -@ -o $@ $<

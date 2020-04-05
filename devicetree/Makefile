MAKEFILE_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

FREEBSD = $(MAKEFILE_DIR)/freebsd-export
MAIN_DTS = $(FREEBSD)/sys/gnu/dts/arm/am335x-boneblack.dts
MAIN_FILENAME = $(notdir $(MAIN_DTS))
MAIN_DTB = $(MAIN_FILENAME:%.dts=$(PREFIX)/fdt/%.dtb)
OVERLAY_DTS = $(wildcard $(MAKEFILE_DIR)/*.dtso)
OVERLAY_DTBO = $(OVERLAY_DTS:$(MAKEFILE_DIR)/%.dtso=$(PREFIX)/fdt/%.dtbo)
TARGETDIR = $(PREFIX)/fdt

install: $(TARGETDIR) $(MAIN_DTB) $(OVERLAY_DTBO)

export MACHINE

$(TARGETDIR):
	mkdir $(TARGETDIR)

$(MAIN_DTB): $(MAIN_DTS)
	echo $(MAIN_DTB)
	$(FREEBSD)/sys/tools/fdt/make_dtb.sh $(FREEBSD)/sys $(MAIN_DTS) $(PREFIX)/fdt/

$(TARGETDIR)/%.dtbo: $(MAKEFILE_DIR)/%.dtso
	dtc -@ -o $@ $<

MAKEFILE_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR = $(MAKEFILE_DIR)/b-mtools

all:
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	cd $(BUILD_DIR) && tar xf $(MAKEFILE_DIR)/mtools-4.0.18.tar.bz2
	cd $(BUILD_DIR)/mtools-4.0.18 && patch -p1 -i $(MAKEFILE_DIR)/mtools-4.0.18.diff
	cd $(BUILD_DIR)/mtools-4.0.18 && ./configure --prefix=${PREFIX}
	cd $(BUILD_DIR)/mtools-4.0.18 && make -j `nproc` all

install: all
	cd $(BUILD_DIR)/mtools-4.0.18 && make install

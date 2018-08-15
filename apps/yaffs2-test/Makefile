RTEMS_ROOT ?= $(PWD)/../../install/rtems/5
RTEMS_BSP ?= beagleboneblack

include $(RTEMS_ROOT)/make/custom/$(RTEMS_BSP).mk

CFLAGS += -O2

APP = $(BUILDDIR)/yaffs2_test
APP_PIECES = $(wildcard *.c)
APP_OBJS = $(APP_PIECES:%.c=$(BUILDDIR)/%.o)
APP_DEPS = $(APP_PIECES:%.c=$(BUILDDIR)/%.d)

all: $(BUILDDIR) $(APP).exe

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(APP).exe: $(APP_OBJS)
	$(CCLINK) $^ -lyaffs2 -o $@

clean:
	rm -rf $(BUILDDIR)

-include $(APP_DEPS)

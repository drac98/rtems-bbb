ARMGNU ?= arm-none-eabi

COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding

APP = loop

all : $(APP).bin

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.elf

$(APP).elf : $(APP).c
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

$(APP).bin : $(APP).elf
	$(ARMGNU)-objcopy $< -O binary $@

ASM          = nasm
ASMFLAGS     = -MD

CC           = gcc
CFLAGS       = -MMD -MF $(BUILD_DIR)/tools/$*.d

CC16         = /usr/bin/watcom/binl/wcc
CFLAGS16     =

LD16         = /usr/bin/watcom/binl/wlink
LDFLAGS16    =

SRC_DIR      = src
TOOLS_DIR    = tools
BUILD_DIR    = build

STAGE1_SRC   = $(SRC_DIR)/bootloader/stage1/boot.asm
STAGE2_SRC   = $(SRC_DIR)/bootloader/stage2/main.asm
KERNEL_SRC   = $(SRC_DIR)/kernel/main.asm

STAGE1_DEPS := $(wildcard $(SRC_DIR)/bootloader/stage1/*.asm)

STAGE2_DEPS := $(wildcard $(SRC_DIR)/bootloader/stage2/*.asm) \
               $(wildcard $(SRC_DIR)/bootloader/stage2/*.c) \
               $(wildcard $(SRC_DIR)/bootloader/stage2/*.h)

KERNEL_DEPS  := $(wildcard $(SRC_DIR)/kernel/*.asm)

STAGE1_BIN   = $(BUILD_DIR)/stage1.bin
STAGE2_BIN   = $(BUILD_DIR)/stage2.bin
KERNEL_BIN   = $(BUILD_DIR)/kernel.bin
FLOPPY_IMG   = $(BUILD_DIR)/main_floppy.img

TOOL_SOURCES = $(wildcard $(TOOLS_DIR)/*/*.c)
TOOL_BINS    = $(patsubst $(TOOLS_DIR)/%, $(BUILD_DIR)/tools/%, $(TOOL_SOURCES:.c=))

MCOPY        = mcopy
DD           = dd
MKFS         = mkfs.fat

V           ?= 0

GREEN        = \033[0;32m
YELLOW       = \033[0;33m
RED          = \033[0;31m
RESET        = \033[0m

ifeq ($(V), 1)
	Q=
	NULL=
	VFLAGS=-v
	VDDLEVEL=progress
	VMAKEFLAGS=
else
	Q=@
	NULL=&> /dev/null
	VFLAGS=
	VDDLEVEL=none
	VMAKEFLAGS=--no-print-directory
endif

.PHONY: all clean bootloader kernel tools_fat tools run

#
# Top-Level Targets
#
all:         $(FLOPPY_IMG) tools_fat

bootloader:  $(STAGE1_BIN) $(STAGE2_BIN)
kernel:      $(KERNEL_BIN)
tools:       $(TOOL_BINS)

#
# Floppy image
#
$(FLOPPY_IMG): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	@echo -e '[${GREEN}+${RESET}] Creating floppy image...'
	$(Q)$(DD) if=/dev/zero of=$@ bs=512 count=2880 status=$(VDDLEVEL)
	$(Q)$(MKFS) -F 12 -n "OS" $@ $(NULL)
	$(Q)$(DD) if=$(STAGE1_BIN) of=$@ conv=notrunc status=$(VDDLEVEL)
	@echo -e '[${GREEN}+${RESET}] Copying stage2 bootloader to image...'
	@if ! $(MCOPY) -i $@ $(STAGE2_BIN) "::stage2.bin" $(NULL); then \
		echo -e '[${RED}*${RESET}] Mcopy failed!'; \
		echo -e '[${RED}-${RESET}] Deleting image...'; \
		rm -f $@; \
		exit 1; \
	fi
	@echo -e '[${GREEN}+${RESET}] Copying kernel to image...'
	@if ! $(MCOPY) -i $@ $(KERNEL_BIN) "::kernel.bin" $(NULL); then \
		echo -e '[${RED}*${RESET}] Mcopy failed!'; \
		echo -e '[${RED}-${RESET}] Deleting image...'; \
		rm -f $@; \
		exit 1; \
	fi

#
# Bootloader stages
#
$(STAGE1_BIN): $(STAGE1_DEPS) | $(BUILD_DIR)
	@echo -e '[${GREEN}+${RESET}] Assembling stage1 bootloader...'
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

$(STAGE2_BIN): $(STAGE2_DEPS) | $(BUILD_DIR)
	@echo -e '[${GREEN}+${RESET}] Assembling stage2 bootloader...'
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

#
# Kernel
#
$(KERNEL_BIN): $(KERNEL_DEPS) | $(BUILD_DIR)
	@echo -e '[${GREEN}+${RESET}] Assembling kernel...'
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

#
# Tools
#
tools_fat: $(TOOL_BINS)

$(BUILD_DIR)/tools/%: $(TOOLS_DIR)/%.c
	@echo -e '[${GREEN}+${RESET}] Compiling tool: $<'
	$(Q)mkdir -p $(VFLAGS) $(dir $@)
	$(Q)$(CC) $(CFLAGS) -o $@ $<

#
# Ensure build directory exists
#
$(BUILD_DIR):
	$(Q)mkdir -p $@

#
# Clean
#
clean:
	@echo -e '[${RED}-${RESET}] Cleaning build artifacts...'
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage1 clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage2 clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/kernel clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)rm -rf $(VFLAGS) $(FLOPPY_IMG)
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)/$(TOOLS_DIR)

#
# Distclean
#
distclean: clean
	@echo -e '[${RED}-${RESET}] Cleaning distruibution...'
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)
	$(Q)rm -f $(VFLAGS) src/**/*.err src/**/*.out src/**/*.in
	$(Q)rm -f $(VFLAGS) src/**/**/*.err src/**/**/*.out src/**/**/*.in

#
# Run qemu
#
run: $(FLOPPY_IMG)
	$(Q)qemu-system-x86_64 -drive format=raw,if=floppy,file=$(FLOPPY_IMG)

#
# Include dependencies
#
-include $(BUILD_DIR)/*.d
-include $(wildcard $(BUILD_DIR)/**/**/*.d)

# -include $(wildcard $(BUILD_DIR)/stage2/c/*.d)
# -include $(wildcard $(BUILD_DIR)/stage2/asm/*.d)
# -include $(wildcard $(BUILD_DIR)/tools/fat/*.d)

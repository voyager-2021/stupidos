# Bare-Metal License v1.0
# Copyright (c) 2025 voyager-2021
# This software is inspired by and includes code from chibicitiberiu's nanobyte_os
#
# You may not use this software for commercial purposes or profit.
# See LICENSE file for full terms.

include scripts/config.mk

ASMFLAGS    += -MD
CFLAGS      += -MMD -MF $(BUILD_DIR)/tools/$*.d

STAGE1_SRC   = $(SRC_DIR)/bootloader/stage1/boot.asm
STAGE2_SRC   = $(SRC_DIR)/bootloader/stage2/entry.asm
KERNEL_SRC   = $(SRC_DIR)/kernel/main.asm

STAGE1_DEPS := $(wildcard $(SRC_DIR)/bootloader/stage1/*.asm)

STAGE2_DEPS := $(wildcard $(SRC_DIR)/bootloader/stage2/*.asm) \
               $(wildcard $(SRC_DIR)/bootloader/stage2/*.c) \
               $(wildcard $(SRC_DIR)/bootloader/stage2/*.h)

KERNEL_DEPS := $(shell find $(SRC_DIR)/kernel -type f -name "*.c") \
               $(shell find $(SRC_DIR)/kernel -type f -name "*.asm") \
			   $(shell find $(SRC_DIR)/kernel -type f -name "*.inc") \
			   $(shell find $(SRC_DIR)/kernel -type f -name "*.h")

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

SRC_C       := $(shell find src -type f \( -name '*.c' -o -name '*.h' \))
SRC_ASM     := $(shell find src -type f \( -name '*.asm' -o -name '*.S' \))
SRC_MK      := $(shell find . -path ./toolchain -prune -o -type f -name 'Makefile')

ifeq ($(V), 1)
	Q=
	NULL=
	VFLAGS=-v
	VDDLEVEL=progress
	VMAKEFLAGS=
	VFINDFLAGS=-print
else
	Q=@
	NULL=&> /dev/null
	VFLAGS=
	VDDLEVEL=none
	VMAKEFLAGS=--no-print-directory
	VFINDFLAGS=-exec echo '  RM      ' {} +
endif

define PRINT_ACTION
	@printf "  %-8s %s\n" "$(1)" "$(2)"
endef

.PHONY: all clean distclean bootloader kernel tools_fat tools run debug autolicense

#
# Top-Level Targets
#
all:         $(FLOPPY_IMG) tools_fat

bootloader:  $(STAGE1_BIN) $(STAGE2_BIN)
kernel:      $(KERNEL_BIN)
tools:       $(TOOL_BINS)

include scripts/toolchain.mk

#
# Floppy image
#
$(FLOPPY_IMG): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	@$(call PRINT_ACTION,DD,$@)
	$(Q)$(DD) if=/dev/zero of=$@ bs=512 count=2880 status=$(VDDLEVEL)
	@$(call PRINT_ACTION,MKFS,$@)
	$(Q)$(MKFS) -F 12 -n "OS" $@ $(NULL)
	@$(call PRINT_ACTION,DD,$@)
	$(Q)$(DD) if=$(STAGE1_BIN) of=$@ conv=notrunc status=$(VDDLEVEL)
	@$(call PRINT_ACTION,MCOPY,$(STAGE2_BIN))
	@if ! $(MCOPY) -i $@ $(STAGE2_BIN) "::stage2.bin" $(NULL); then \
		echo -e '*** Mcopy failed!'; \
		$(call PRINT_ACTION,RM,$@);  \
		rm -f $@; \
		exit 1; \
	fi
	@$(call PRINT_ACTION,MCOPY,$(KERNEL_BIN))
	@if ! $(MCOPY) -i $@ $(KERNEL_BIN) "::kernel.bin" $(NULL); then \
		echo -e '*** Mcopy failed!'; \
		$(call PRINT_ACTION,RM,$@); \
		rm -f $@; \
		exit 1; \
	fi

#
# Bootloader stages
#
$(STAGE1_BIN): $(STAGE1_DEPS) | $(BUILD_DIR)
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

$(STAGE2_BIN): $(STAGE2_DEPS) | $(BUILD_DIR)
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

#
# Kernel
#
$(KERNEL_BIN): $(KERNEL_DEPS) | $(BUILD_DIR)
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) ENABLE_DEPS=1 V=$(V)

#
# Tools
#
tools_fat: $(TOOL_BINS)

$(BUILD_DIR)/tools/%: $(TOOLS_DIR)/%.c
	@$(call PRINT_ACTION,MKDIR,$@)
	$(Q)mkdir -p $(VFLAGS) $(dir $@)
	@$(call PRINT_ACTION,CC,$<)
	$(Q)$(CC) $(CFLAGS) -o $@ $<

#
# Ensure build directory exists
#
$(BUILD_DIR):
	@$(call PRINT_ACTION,MKDIR,$@)
	$(Q)mkdir -p $@

#
# Clean
#
clean:
	@$(call PRINT_ACTION,CLEAN,$(BUILD_DIR))
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage1 clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/bootloader/stage2 clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/kernel clean BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)/$(TOOLS_DIR)
	$(Q)rm -f $(VFLAGS) $(FLOPPY_IMG)

#
# Distclean
#
distclean:
	@$(call PRINT_ACTION,RMDIR,$(BUILD_DIR))
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)
	@$(call PRINT_ACTION,CLEAN,$(SRC_DIR))
	$(Q)find src -name '*.err' -delete $(VFINDFLAGS)

#
# Run qemu
#
run: $(FLOPPY_IMG)
	@$(call PRINT_ACTION,RUN,$<)
	$(Q)qemu-system-x86_64 -drive format=raw,if=floppy,file=$(FLOPPY_IMG)

#
# Debug
#
debug: $(FLOPPY_IMG)
	@$(call PRINT_ACTION,DEBUG,$<)
	$(Q)bochs -f .bochsrc

#
# License headers
#
autolicense:
	@sh ./autolicense.sh

# -include $(wildcard $(BUILD_DIR)/stage2/c/*.d)
# -include $(wildcard $(BUILD_DIR)/stage2/asm/*.d)
# -include $(wildcard $(BUILD_DIR)/tools/fat/*.d)

#
# Include dependencies
#
DEPFILES := $(shell find $(abspath $(BUILD_DIR)) -name '*.d' 2>/dev/null)

-include $(DEPFILES)

# -include $(DEPFILES)
#
# -include $(wildcard $(BUILD_DIR)/*.d)
#
# -include $(wildcard $(BUILD_DIR)/kernel/c/*.d)
# -include $(wildcard $(BUILD_DIR)/kernel/asm/*.d)
#
# -include $(wildcard $(BUILD_DIR)/stage2/c/*.d)
# -include $(wildcard $(BUILD_DIR)/stage2/asm/*.d)

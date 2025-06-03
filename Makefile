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
	@$(call PRINT_ACTION,DD,$@)
	$(Q)$(DD) if=/dev/zero of=$@ bs=512 count=2880 status=$(VDDLEVEL)
	@$(call PRINT_ACTION,MKFS,$@)
	$(Q)$(MKFS) -F 12 -n "OS" $@ $(NULL)
	@$(call PRINT_ACTION,DD,$@)
	$(Q)$(DD) if=$(STAGE1_BIN) of=$@ conv=notrunc status=$(VDDLEVEL)
	@$(call PRINT_ACTION,MCOPY,$(STAGE2_BIN))
	@if ! $(MCOPY) -i $@ $(STAGE2_BIN) "::stage2.bin" $(NULL); then \
		echo -e '[${RED}*${RESET}] Mcopy failed!'; \
		echo -e '[${RED}-${RESET}] Deleting image...'; \
		rm -f $@; \
		exit 1; \
	fi
	@$(call PRINT_ACTION,MCOPY,$(KERNEL_BIN))
	@if ! $(MCOPY) -i $@ $(KERNEL_BIN) "::kernel.bin" $(NULL); then \
		echo -e '${RED}***${RESET} Mcopy failed!'; \
		@$(call PRINT_ACTION,RM,$@); \
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
	@$(MAKE) $(VMAKEFLAGS) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) V=$(V)

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
# Include dependencies
#
-include $(BUILD_DIR)/*.d
-include $(wildcard $(BUILD_DIR)/**/**/*.d)

# -include $(wildcard $(BUILD_DIR)/stage2/c/*.d)
# -include $(wildcard $(BUILD_DIR)/stage2/asm/*.d)
# -include $(wildcard $(BUILD_DIR)/tools/fat/*.d)

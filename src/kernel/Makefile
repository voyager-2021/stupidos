# Bare-Metal License v1.0
# Copyright (c) 2025 voyager-2021
# This software is inspired by and includes code from chibicitiberiu's nanobyte_os
#
# You may not use this software for commercial purposes or profit.
# See LICENSE file for full terms.

export TARGET                ?= i686-elf
export TARGET_ASM            ?= nasm
export TARGET_ASMFLAGS       ?=
export TARGET_CC             ?= $(TARGET)-gcc
export TARGET_CFLAGS         ?= -std=c99 -g
export TARGET_CXX            ?= $(TARGET)-g++
export TARGET_CXXFLAGS       ?= -std=c99 -g
export TARGET_LD             ?= $(TARGET)-gcc
export TARGET_LDFLAGS        ?=
export TARGET_LIBS           ?=

TOOLCHAIN_PREFIX             ?= $(abspath ../../toolchain/$(TARGET))

export PATH                  := $(TOOLCHAIN_PREFIX)/bin:$(PATH)


TARGET_ASMFLAGS  += -f elf -MD -MF $(@:.obj=.d)
TARGET_CFLAGS    += -ffreestanding -nostdlib -MMD -MP -MF $(@:.obj=.d) -I.
TARGET_LIBS      += -lgcc
TARGET_LDFLAGS   += -T linker.ld -nostdlib

SOURCES_C         = $(shell find . -type f -name "*.c" ! -path "./arch/i686/isr_gen.c") arch/i686/isr_gen.c
SOURCES_ASM       = $(shell find . -type f -name "*.asm")

HEADERS_C         = $(shell find . -type f -name "*.h")
HEADERS_ASM       = $(shell find . -type f -name "*.inc") arch/i686/isr_gen.inc

OBJECTS_C         = $(patsubst %.c, $(BUILD_DIR)/kernel/c/%.obj, $(SOURCES_C))
OBJECTS_ASM       = $(patsubst %.asm, $(BUILD_DIR)/kernel/asm/%.obj, $(SOURCES_ASM))

DEPS_C            = $(OBJECTS_C:.obj=.d)
DEPS_ASM          = $(OBJECTS_ASM:.obj=.d)

V                ?= 0
EANBLE_DEPS      ?= 0

ifeq ($(V), 1)
	Q=
	NULL=
	NULLSTDOUT=
	VFLAGS=-v
else
	Q=@
	NULL=&> /dev/null
	NULLSTDOUT=1> /dev/null
	VFLAGS=
endif

define PRINT_ACTION
	@printf "  %-8s %s\n" "$(1)" "$(2)"
endef

relpath = $(patsubst $(BUILD_DIR)/%,%,$(1))

.PHONY: all kernel clean

all: kernel

kernel: $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/kernel.bin.d

$(BUILD_DIR)/kernel.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	@$(call PRINT_ACTION,LD,build/$(call relpath,$@))
	$(Q)$(TARGET_LD) $(TARGET_LDFLAGS) -Wl,-Map=$(BUILD_DIR)/kernel.map -o $@ $^ $(TARGET_LIBS) $(NULLSTDOUT)

ifeq ($(EANBLE_DEPS), 0)
HEADER_STAMP := $(BUILD_DIR)/.headers.stamp
$(HEADER_STAMP): $(HEADERS_C)
	@$(call PRINT_ACTION,STAMP,build/.headers.stamp)
	$(Q)mkdir -p $(dir $@)
	$(Q)touch $@
endif

$(BUILD_DIR)/kernel/c/%.obj: %.c $(HEADER_STAMP)
	@$(call PRINT_ACTION,CC,src/kernel/$(call relpath,$<))
	$(Q)mkdir -p $(dir $@)
	$(Q)$(TARGET_CC) $(TARGET_CFLAGS) -c -o $@ $< $(NULLSTDOUT)

ifeq ($(EANBLE_DEPS), 0)
ASM_HEADER_STAMP := $(BUILD_DIR)/.asm_headers.stamp
$(ASM_HEADER_STAMP): $(HEADERS_ASM)
	@$(call PRINT_ACTION,STAMP,build/.asm_headers.stamp)
	$(Q)mkdir -p $(dir $@)
	$(Q)touch $@
endif

$(BUILD_DIR)/kernel/asm/%.obj: %.asm $(ASM_HEADER_STAMP)
	@$(call PRINT_ACTION,AS,src/kernel/$(call relpath,$<))
	$(Q)mkdir -p $(dir $@)
	$(Q)$(TARGET_ASM) $(TARGET_ASMFLAGS) -o $@ $< $(NULLSTDOUT)

$(BUILD_DIR):
	@$(call PRINT_ACTION,MKDIR,$(call relpath,$@))
	$(Q)mkdir -p $@

$(BUILD_DIR)/kernel/c:
	@$(call PRINT_ACTION,MKDIR,build/$(call relpath,$@))
	$(Q)mkdir -p $@

$(BUILD_DIR)/kernel/asm:
	@$(call PRINT_ACTION,MKDIR,build/$(call relpath,$@))
	$(Q)mkdir -p $@

$(BUILD_DIR)/kernel.bin.d: $(SOURCES_C) $(HEADERS_ASM) $(HEADERS_C) $(HEADERS_ASM)  linker.ld
	@mkdir -p $(dir $@)
	@printf "$(abspath BUILD_DIR)/kernel.bin: " > $@
	@printf "%s " $^ >> $@
	@printf "\n" >> $@

arch/i686/isr_gen.c arch/i686/isr_gen.inc:
	@../../scripts/generate_isr.sh $@

clean:
	$(Q)rm -rf $(BUILD_DIR)/kernel
	$(Q)rm -f $(BUILD_DIR)/kernel.*

-include $(DEPS_C) $(DEPS_ASM)

ASM          ?= nasm
ASMFLAGS     ?= -MD -MF $(@:.obj=.d)

CC16         ?= /usr/bin/watcom/binl/wcc
CFLAGS16     ?= -4 -d3 -s -wx -ms -zl -zq

LD16         ?= /usr/bin/watcom/binl/wlink
LDFLAGS16    ?=

BUILD_DIR    ?= build

SOURCES_C     = $(wildcard *.c)
SOURCES_ASM   = $(wildcard *.asm)

OBJECTS_C     = $(patsubst %.c, $(BUILD_DIR)/stage2/c/%.o, $(SOURCES_C))
OBJECTS_ASM   = $(patsubst %.asm, $(BUILD_DIR)/stage2/asm/%.obj, $(SOURCES_ASM))

DEPS_C        = $(OBJECTS_C:.o=.d)
DEPS_ASM      = $(OBJECTS_ASM:.obj=.d)

HEADERS      := $(wildcard *.h)

V            ?= 0

GREEN         = \033[0;32m
YELLOW        = \033[0;33m
RED           = \033[0;31m
RESET         = \033[0m

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

.PHONY: all stage2 clean

all: stage2

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	@echo -e "[${GREEN}+${RESET}] Linking: $<"
	$(Q)$(LD16) $(LDFLAGS16) NAME $(BUILD_DIR)/stage2.bin FILE \{ $(OBJECTS_ASM) $(OBJECTS_C) \} OPTION MAP=$(BUILD_DIR)/stage2.map @linker.lnk $(NULLSTDOUT)

$(BUILD_DIR)/stage2/asm/%.obj: %.asm | $(BUILD_DIR)/stage2/asm
	@echo -e "[${GREEN}+${RESET}] Assembling: $<"
	$(Q)$(ASM) $(ASMFLAGS) -f obj -o $@ $< $(NULLSTDOUT)

$(BUILD_DIR)/stage2/c/%.o: %.c $(HEADERS) | $(BUILD_DIR)/stage2/c
	@echo -e "[${GREEN}+${RESET}] Compiling: $<"
	$(Q)$(CC16) $(CFLAGS16) -fo=$@ -ad=$(BUILD_DIR)/stage2/c/$*.d $< $(NULLSTDOUT)

$(BUILD_DIR):
	$(Q)mkdir -p $(VFLAGS) $@

$(BUILD_DIR)/stage2/c:
	$(Q)mkdir -p $(VFLAGS) $(BUILD_DIR)/stage2/c

$(BUILD_DIR)/stage2/asm:
	$(Q)mkdir -p $(VFLAGS) $(BUILD_DIR)/stage2/asm

clean:
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)/stage2
	$(Q)rm -f $(VFLAGS) $(BUILD_DIR)/stage2.*

-include $(DEPS_C) $(DEPS_ASM)

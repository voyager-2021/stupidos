TARGET_ASMFLAGS  += -f elf -MD -MF $(@:.obj=.d)
TARGET_CFLAGS    += -ffreestanding -nostdlib
TARGET_LIBS      += -lgcc
TARGET_LDFLAGS   += -T linker.ld -nostdlib

SOURCES_C         = $(wildcard *.c)
SOURCES_ASM       = $(wildcard *.asm)

OBJECTS_C         = $(patsubst %.c, $(BUILD_DIR)/stage2/c/%.obj, $(SOURCES_C))
OBJECTS_ASM       = $(patsubst %.asm, $(BUILD_DIR)/stage2/asm/%.obj, $(SOURCES_ASM))

DEPS_C            = $(OBJECTS_C:.obj=.d)
DEPS_ASM          = $(OBJECTS_ASM:.obj=.d)

HEADERS          := $(wildcard *.h)

V                ?= 0

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

.PHONY: all stage2 clean

all: stage2

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	@$(call PRINT_ACTION,LD,build/$(call relpath,$@))
	$(Q)$(TARGET_LD) $(TARGET_LDFLAGS) -Wl,-Map=$(BUILD_DIR)/stage2.map -o $@ $^ $(TARGET_LIBS) $(NULLSTDOUT)

$(BUILD_DIR)/stage2/c/%.obj: %.c $(HEADERS) | $(BUILD_DIR)/stage2/c
	@$(call PRINT_ACTION,CC,src/bootloader/stage2/$(call relpath,$*).c)
	$(Q)$(TARGET_CC) $(TARGET_CFLAGS) -c -o $@ -MMD -MF $(BUILD_DIR)/stage2/c/$*.d $< $(NULLSTDOUT)

$(BUILD_DIR)/stage2/asm/%.obj: %.asm | $(BUILD_DIR)/stage2/asm
	@$(call PRINT_ACTION,AS,src/bootloader/stage2/$(call relpath,$*).asm)
	$(Q)$(TARGET_ASM) $(TARGET_ASMFLAGS) -o $@ $< $(NULLSTDOUT)

#
$(BUILD_DIR):
	@$(call PRINT_ACTION,MKDIR,$(call relpath,$@))
	$(Q)mkdir -p $(VFLAGS) $@

$(BUILD_DIR)/stage2/c:
	@$(call PRINT_ACTION,MKDIR,build/$(call relpath,$@))
	$(Q)mkdir -p $(VFLAGS) $(BUILD_DIR)/stage2/c

$(BUILD_DIR)/stage2/asm:
	@$(call PRINT_ACTION,MKDIR,build/$(call relpath,$@))
	$(Q)mkdir -p $(VFLAGS) $(BUILD_DIR)/stage2/asm

clean:
	$(Q)rm -rf $(VFLAGS) $(BUILD_DIR)/stage2
	$(Q)rm -f $(VFLAGS) $(BUILD_DIR)/stage2.*

-include $(DEPS_C) $(DEPS_ASM)

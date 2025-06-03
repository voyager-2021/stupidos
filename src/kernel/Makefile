ASM         ?= nasm
ASMFLAGS    ?= -MD -MF $(BUILD_DIR)/kernel.d

BUILD_DIR   ?= build
SRC         := main.asm
OUT         := $(BUILD_DIR)/kernel.bin

 V           ?= 0

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

.PHONY: all kernel clean

all: kernel

kernel: $(OUT)

$(BUILD_DIR)/kernel.bin:
	@$(call PRINT_ACTION,AS,src/kernel/$(SRC))
	$(Q)$(ASM) $(ASMFLAGS) -f bin -o $(OUT) main.asm

$(BUILD_DIR):
	@$(call PRINT_ACTION,MKDIR,$@)
	$(Q)mkdir -p $(VFLAGS) $@

clean:
	$(Q)rm -rf $(VFLAGS) $(OUT) $(BUILD_DIR)/kernel.d

-include $(BUILD_DIR)/kernel.d

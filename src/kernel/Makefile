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

.PHONY: all kernel clean

all: kernel

kernel: $(OUT)

$(BUILD_DIR)/kernel.bin:
	$(Q)$(ASM) $(ASMFLAGS) -f bin -o $(OUT) main.asm

$(BUILD_DIR):
	$(Q)mkdir -p $(VFLAGS) $@

clean:
	$(Q)rm -rf $(VFLAGS) $(OUT) $(BUILD_DIR)/kernel.d

-include $(BUILD_DIR)/kernel.d

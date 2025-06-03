ASM         ?= nasm
ASMFLAGS    ?= -MD -MF $(BUILD_DIR)/stage1.d

BUILD_DIR   ?= build
SRC         := boot.asm
OUT         := $(BUILD_DIR)/stage1.bin

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

.PHONY: all stage1 clean

all: stage1

stage1: $(OUT)

$(OUT): $(SRC) | $(BUILD_DIR)
	@$(call PRINT_ACTION,AS,src/bootloader/stage1/$(SRC))
	$(Q)$(ASM) $(ASMFLAGS) -f bin -o $@ $<

$(BUILD_DIR):
	@$(call PRINT_ACTION,MKDIR,$@)
	$(Q)mkdir -p $(VFLAGS) $@

clean:
	$(Q)rm -rf $(VFLAGS) $(OUT) $(BUILD_DIR)/stage1.d

-include $(BUILD_DIR)/stage1.d

TOOLCHAIN_PREFIX              = $(abspath toolchain/$(TARGET))

V                            ?= 0

export PATH                  := $(TOOLCHAIN_PREFIX)/bin:$(PATH)

ifeq ($(V), 1)
	Q=
	NULL=
	VFLAGS=-v
	VDDLEVEL=progress
	VMAKEFLAGS=
	VFINDFLAGS=-print
	NULLSTDOUT=
	NULLSTDERR=
else
	Q=@
	NULL=&> /dev/null
	VFLAGS=
	VDDLEVEL=none
	VMAKEFLAGS=--no-print-directory
	VFINDFLAGS=-exec echo '  RM      ' {} +
	NULLSTDOUT=1> /dev/null
	NULLSTDERR=2> /dev/null
endif

define PRINT_ACTION
	@printf "  %-8s %s\n" "$(1)" "$(2)"
endef

toolchain: toolchain_binutils toolchain_gcc

toolchain_binutils: toolchain/$(BINUTILS_NAME).tar.xz
	$(call PRINT_ACTION,CONFIG,binutils)
	$(Q)rm -rf toolchain/$(BINUTILS_NAME)/build
	$(Q)mkdir -p toolchain/$(BINUTILS_NAME)/build
	$(Q)cd toolchain/$(BINUTILS_NAME)/build && \
		../configure \
			--prefix="$(TOOLCHAIN_PREFIX)"  \
			--target=$(TARGET)              \
			--with-sysroot                  \
			--disable-nls                   \
			--disable-werror                \
			$(NULLSTDOUT)

	$(call PRINT_ACTION,BUILD,binutils)
	$(Q)$(MAKE) -j$(shell nproc) -C toolchain/$(BINUTILS_NAME)/build $(NULLSTDOUT)

	$(call PRINT_ACTION,INSTALL,binutils)
	$(Q)$(MAKE) -j$(shell nproc) -C toolchain/$(BINUTILS_NAME)/build install $(NULLSTDOUT)

toolchain/$(BINUTILS_NAME).tar.xz:
	$(call PRINT_ACTION,GET,$(BINUTILS_NAME).tar.xz)
	$(Q)mkdir -p toolchain
	$(Q)cd toolchain && wget $(BINUTILS_URL) $(NULLSTDERR)
	$(Q)cd toolchain && tar xf $(BINUTILS_NAME).tar.xz $(NULLSTDOUT)

toolchain_gcc: toolchain_binutils toolchain/$(GCC_NAME).tar.xz
	$(call PRINT_ACTION,CONFIG,gcc)
	$(Q)rm -rf toolchain/$(GCC_NAME)/build
	$(Q)mkdir -p toolchain/$(GCC_NAME)/build
	$(Q)cd toolchain/$(GCC_NAME)/build && \
		../configure \
			--prefix="$(TOOLCHAIN_PREFIX)"  \
			--target=$(TARGET)              \
			--disable-nls                   \
			--enable-languages=c,c++        \
			--without-headers               \
			$(NULLSTDOUT)

	$(call PRINT_ACTION,BUILD,gcc)
	$(Q)$(MAKE) -j$(shell nproc) -C toolchain/$(GCC_NAME)/build all-gcc all-target-libgcc $(NULLSTDOUT)

	$(call PRINT_ACTION,INSTALL,gcc)
	$(Q)$(MAKE) -j$(shell nproc) -C toolchain/$(GCC_NAME)/build install-gcc install-target-libgcc $(NULLSTDOUT)

toolchain/$(GCC_NAME).tar.xz:
	$(call PRINT_ACTION,GET,$(GCC_NAME).tar.xz)
	$(Q)mkdir -p toolchain
	$(Q)cd toolchain && wget $(GCC_URL) $(NULLSTDERR)
	$(Q)cd toolchain && tar xf $(GCC_NAME).tar.xz $(NULLSTDOUT)

clean-toolchain:
	$(call PRINT_ACTION,CLEAN,toolchain)
	$(Q)rm -rf $(VFLAGS) toolchain/$(GCC_NAME) toolchain/$(BINUTILS_NAME) toolchain/$(TARGET)

clean-toolchain-all:
	$(call PRINT_ACTION,RMDIR,toolchain)
	$(Q)rm -rf $(VFLAGS) toolchain

.PHONY: toolchain toolchain_gcc toolchain_binutils clean-toolchain clean-toolchain-all

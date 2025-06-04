SRC_DIR                       = src
TOOLS_DIR                     = tools
BUILD_DIR                     = build

export ASM                    =
export ASMFLAGS               =
export CC                     = gcc
export CFLAGS                 =
export CXX                    = g++
export CXXFLAGS               =
export LD                     = ld
export LDFLAGS                =
export LIBS                   =

export TARGET                 = i686-elf
export TARGET_ASM             = nasm
export TARGET_ASMFLAGS        =
export TARGET_CC              = $(TARGET)-gcc
export TARGET_CFLAGS          = -std=c99 -g
export TARGET_CXX             = $(TARGET)-g++
export TARGET_CXXFLAGS        = -std=c99 -g
export TARGET_LD              = $(TARGET)-gcc
export TARGET_LDFLAGS         =
export TARGET_LIBS            =

BINUTILS_NAME                 = binutils-2.42
BINUTILS_URL                  = https://www.nic.funet.fi/pub/gnu/ftp.gnu.org/gnu/binutils/$(BINUTILS_NAME).tar.xz
GCC_NAME                      = gcc-15.1.0
GCC_URL                       = https://www.nic.funet.fi/pub/gnu/ftp.gnu.org/gnu/gcc/$(GCC_NAME)/$(GCC_NAME).tar.xz

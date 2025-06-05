# stupidos

![License](https://img.shields.io/badge/license-Bare%20Metal-blue.svg) ![GitHub stars](https://img.shields.io/github/stars/voyager-2021/stupidos?style=social) ![Last Commit](https://img.shields.io/github/last-commit/voyager-2021/stupidos) ![Lines of Code](https://raw.githubusercontent.com/voyager-2021/stupidos/image-data/loc-badge.svg)

---

## Description

My stupid floppy disk OS is a small educational operating system project built from scratch. It consists of a 512-byte Stage 1 bootloader, a Stage 2 bootloader that initializes the system and loads the kernel, and a simple kernel that currently prints "Hello from kernel!!!". Inspired by and code from chibicitiberiu’s nanobyte_os.

Here is a [showcase](https://i.imgur.com/m0SsWq3.png) of it in action.

---

## Features

- Bootloader stage 1 fits in first floppy disk sector (512 bytes).
- Stage 2 bootloader supports FAT12 filesystem and system initialization.
- Kernel implemented in C with basic I/O and memory management functions.
- Custom printf, panic handling, and assembly routines for x86 I/O.
- FAT file system support in the bootloader.
- Separate compilation of C and assembly files with linker scripts.
- Bochs and QEMU support for debugging and running.

---

## Build Prerequisites

- GCC cross-compiler targeting i686-elf (can be built using make toolchain)
- NASM assembler
- GNU Make

---

## Build and Run

Build everything and run on QEMU or Bochs using the provided Makefile targets:

```sh
make toolchain
make
make run      # Run on QEMU
make debug    # Run on Bochs
```

---

## How It Works

1. **Stage 1 bootloader**: Loads from the first sector of the floppy disk (512 bytes), jumps to Stage 2.
2. **Stage 2 bootloader**: Loads from FAT12 filesystem, switches CPU to real mode, loads kernel.
3. **Kernel**: Prints "Hello from kernel!!!" and provides basic runtime functions.

---

## Resources and Inspiration

- Inspired by and code from [chibicitiberiu’s nanobyte_os](https://github.com/chibicitiberiu/nanobyte_os)
- [OSDev Wiki](https://wiki.osdev.org/Main_Page)
- [Intel 80386 Manual](https://www.intel.com/content/www/us/en/processors/architectures-software-developer-manuals.html)

---

## License

This project is licensed under a custom bare metal license similar to BSD 3-Clause. See the [LICENSE](./LICENSE) file for details.

/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#pragma once
#include <stdint.h>
#include <stdbool.h>

void __attribute__((cdecl)) i686_outb(uint16_t port, uint8_t value);

uint8_t __attribute__((cdecl)) i686_inb(uint16_t port);

bool __attribute__((cdecl)) i686_Halt(void);


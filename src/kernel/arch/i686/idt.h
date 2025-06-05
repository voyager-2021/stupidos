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

typedef enum {
    IDT_FLAG_GATE_TASK                = 0x5,
    IDT_FLAG_GATE_16BIT_INT           = 0x6,
    IDT_FLAG_GATE_16BIT_TRAP          = 0x7,
    IDT_FLAG_GATE_32BIT_INT           = 0xe,
    IDT_FLAG_GATE_32BIT_TRAP          = 0xf,

    IDT_FLAG_RING_0                   = (0 << 5),
    IDT_FLAG_RING_1                   = (1 << 5),
    IDT_FLAG_RING_2                   = (2 << 5),
    IDT_FLAG_RING_3                   = (3 << 5),

    IDT_FLAG_PRESENT                  = 0x80,
} IDT_FLAGS;

void i686_IDT_SetGate(int interrupt, void* base, uint16_t segmentDescriptor, uint8_t flags);
void i686_IDT_EnableGate(int interrupt);
void i686_IDT_DisableGate(int interrupt);

void i686_IDT_Initialize();

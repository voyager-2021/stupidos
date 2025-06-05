/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "gdt.h"
#include <stdint.h>

typedef struct {
    uint16_t LimitLow;
    uint16_t BaseLow;
    uint8_t BaseMiddle;
    uint8_t Access;
    uint8_t FlagsLimitHi;
    uint8_t BaseHigh;
} __attribute__((packed)) GDTEntry;

typedef struct {
    uint16_t Limit;
    GDTEntry* Ptr;
} __attribute__((packed)) GDTDescriptor;

typedef enum {
    GDT_ACCESS_CODE_READABLE             = 0x02,
    GDT_ACCESS_DATA_WRITEABLE            = 0x02,
    GDT_ACCESS_CODE_CONFORMING           = 0x04,

    GDT_ACCESS_DATA_DIRECTION_NORMAL     = 0x00,
    GDT_ACCESS_DATA_DIRECTION_DOWN       = 0x04,

    GDT_ACCESS_DATA_SEGMENT              = 0x10,
    GDT_ACCESS_CODE_SEGMENT              = 0x18,

    GDT_ACCESS_DESCRIPTOR_TSS            = 0x00,

    GDT_ACCESS_RING_0                    = 0x00,
    GDT_ACCESS_RING_1                    = 0x20,
    GDT_ACCESS_RING_2                    = 0x40,
    GDT_ACCESS_RING_3                    = 0x60,

    GDT_ACCESS_PRESENT                   = 0x80,
} GDT_ACCESS;

typedef enum {
    GDT_FLAG_64BIT                       = 0x20,
    GDT_FLAG_32BIT                       = 0x40,
    GDT_FLAG_16BIT                       = 0x00,

    GDT_FLAG_GRANULARITY_1B              = 0x00,
    GDT_FLAG_GRANULARITY_4K              = 0x80,
} GDT_FLAGS;

#define GDT_LIMIT_LOW(limit)                  (limit & 0xffff)
#define GDT_BASE_LOW(base)                    (base & 0xffff)
#define GDT_BASE_MIDDLE(base)                 ((base >> 16) & 0xff)
#define GDT_FLAGS_LIMIT_HIGH(limit, flags)    (((limit >> 16 ) & 0xf) | (flags & 0xf0))
#define GDT_BASE_HIGH(base)                   ((base >> 24) & 0xff)

#define GDT_ENTRY(base, limit, access, flags) { \
    GDT_LIMIT_LOW(limit), \
    GDT_BASE_LOW(base), \
    GDT_BASE_MIDDLE(base), \
    access, \
    GDT_FLAGS_LIMIT_HIGH(limit, flags), \
    GDT_BASE_HIGH(base) \
}

#define GDT_ENTRY_ACCESS_1 GDT_ACCESS_PRESENT | GDT_ACCESS_RING_0 | GDT_ACCESS_CODE_SEGMENT | GDT_ACCESS_CODE_READABLE
#define GDT_ENTRY_ACCESS_2 GDT_ACCESS_PRESENT | GDT_ACCESS_RING_0 | GDT_ACCESS_DATA_SEGMENT | GDT_ACCESS_DATA_WRITEABLE

GDTEntry g_GDT[] = {
    GDT_ENTRY(0, 0, 0, 0),
    GDT_ENTRY(0, 0xfffff, GDT_ENTRY_ACCESS_1, GDT_FLAG_32BIT | GDT_FLAG_GRANULARITY_4K),
    GDT_ENTRY(0, 0xfffff, GDT_ENTRY_ACCESS_2, GDT_FLAG_32BIT | GDT_FLAG_GRANULARITY_4K),
};

GDTDescriptor g_GDTDescriptor = { sizeof(g_GDT) - 1, g_GDT };

void __attribute__((cdecl)) i686_GDT_Load(GDTDescriptor* descriptor, uint16_t codeSegment, uint16_t dataSegment);

void i686_GDT_Initialize() {
    i686_GDT_Load(&g_GDTDescriptor, i686_GDT_CODE_SEGMENT, i686_GDT_DATA_SEGMENT);
}

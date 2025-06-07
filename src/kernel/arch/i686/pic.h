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

typedef struct {
    const char* Name;
    bool (*Probe)();
    void (*Initialize)(uint8_t offsetPic1, uint8_t offsetPic2, bool autoEoi);
    void (*Disable)();
    void (*SendEndOfInterrupt)(int irq);
    void (*Mask)(int irq);
    void (*Unmask)(int irq);
} PICDriver;

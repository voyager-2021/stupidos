/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#pragma once

#include "isr.h"

typedef void (*IRQHandler)(Registers* regs);

void i686_IRQ_Initialize();

void i686_IRQ_RegisterHandler(int irq, IRQHandler handler);

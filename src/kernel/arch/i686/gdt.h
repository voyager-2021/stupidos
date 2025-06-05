/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#pragma once

#define i686_GDT_CODE_SEGMENT 0x8
#define i686_GDT_DATA_SEGMENT 0x10

void i686_GDT_Initialize();

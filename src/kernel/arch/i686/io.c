/*
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "io.h"

#define UNUSED_PORT 0x80

void i686_iowait() {
    i686_outb(UNUSED_PORT, 0);
}

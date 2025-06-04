/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "ctype.h"

bool islower(char chr)
{
    return chr >= 'a' && chr <= 'z';
}

char toupper(char chr)
{
    return islower(chr) ? (chr - 'a' + 'A') : chr;
}

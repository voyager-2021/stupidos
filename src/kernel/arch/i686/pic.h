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

void i686_PIC_Configure(uint8_t offsetPic1, uint8_t offsetPic2);

void i686_PIC_Mask(int irq);
void i686_PIC_Unmask(int irq);
void i686_PIC_Disable();

void i686_PIC_SendEndOfInterrupt(int irq);

uint16_t i686_PIC_ReadIrqRequestRegister();
uint16_t i686_PIC_ReadInServiceRegister();

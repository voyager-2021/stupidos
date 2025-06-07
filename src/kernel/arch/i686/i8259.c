/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include <stdbool.h>
#include "i8259.h"
#include "pic.h"
#include "io.h"

#define PIC1_COMMAND_PORT 0x20
#define PIC1_DATA_PORT    0x21
#define PIC2_COMMAND_PORT 0xa0
#define PIC2_DATA_PORT    0xa1

typedef enum {
    PIC_ICW1_ICW4       = 0x01,
    PIC_ICW1_SINGLE     = 0x02,
    PIC_ICW1_INTERVAL4  = 0x04,
    PIC_ICW1_LEVEL      = 0x08,
    PIC_ICW1_INITIALIZE = 0x10
} PIC_ICW1;

typedef enum {
    PIC_ICW4_8086          = 0x01,
    PIC_ICW4_AUTO_EOI      = 0x02,
    PIC_ICW4_BUFFER_MASTER = 0x04,
    PIC_ICW4_BUFFER_SLAVE  = 0x00,
    PIC_ICW4_BUFFERED      = 0x08,
    PIC_ICW4_SFNM          = 0x10,
} PIC_ICW4;

typedef enum {
    PIC_CMD_END_OF_INTERRUPT = 0x20,
    PIC_CMD_READ_IRR         = 0x0a,
    PIC_CMD_READ_ISR         = 0x0b,
} PIC_CMD;

static uint16_t g_Mask = 0xffff;
static bool g_AutoEoi = false;

void i8259_SetMask(uint16_t newMask) {
    g_Mask = newMask;

    i686_outb(PIC1_DATA_PORT, g_Mask & 0xFF);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, (g_Mask >> 8) & 0xFF);
    i686_iowait();
}

uint16_t i8259_GetMask() {
    uint8_t mask1, mask2;

    mask1 = i686_inb(PIC1_DATA_PORT);
    mask2 = i686_inb(PIC2_DATA_PORT);

    return mask1 | (mask2 << 8);
}

void i8259_Configure(uint8_t offsetPic1, uint8_t offsetPic2, bool autoEoi) {
    i8259_SetMask(0xffff);

    i686_outb(PIC1_COMMAND_PORT, PIC_ICW1_ICW4 | PIC_ICW1_INITIALIZE);
    i686_iowait();
    i686_outb(PIC2_COMMAND_PORT, PIC_ICW1_ICW4 | PIC_ICW1_INITIALIZE);
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, offsetPic1);  // ICW2: vector offset
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, offsetPic2);  // ICW2: vector offset
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, 0x04);        // ICW3: master has slave on IRQ2
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, 0x02);        // ICW3: slave ID at IRQ2
    i686_iowait();

    uint8_t icw4 = PIC_ICW4_8086;

    if (autoEoi) {
        icw4 |= PIC_ICW4_AUTO_EOI;
    }

    i686_outb(PIC1_DATA_PORT, icw4);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, icw4);
    i686_iowait();

    i8259_SetMask(0xffff);
}

void i8259_SendEndOfInterrupt(int irq) {
    if (irq >= 8)
        i686_outb(PIC2_COMMAND_PORT, PIC_CMD_END_OF_INTERRUPT);
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_END_OF_INTERRUPT);
}

void i8259_Disable(void) {
    i8259_SetMask(0xffff);
}

void i8259_Mask(int irq) {
    if (irq < 0 || irq >= 16) return;

    g_Mask |= (1 << irq);
    i8259_SetMask(g_Mask);
}

void i8259_Unmask(int irq) {
    if (irq < 0 || irq >= 16) return;

    g_Mask &= ~(1 << irq);
    i8259_SetMask(g_Mask);
}

uint16_t i8259_ReadIrqRequestRegister(void) {
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_READ_IRR);
    i686_outb(PIC2_COMMAND_PORT, PIC_CMD_READ_IRR);

    uint8_t irr1 = i686_inb(PIC1_COMMAND_PORT);
    uint8_t irr2 = i686_inb(PIC2_COMMAND_PORT);

    return ((uint16_t)irr2 << 8) | irr1;
}

uint16_t i8259_ReadInServiceRegister(void) {
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_READ_ISR);
    i686_outb(PIC2_COMMAND_PORT, PIC_CMD_READ_ISR);

    uint8_t isr1 = i686_inb(PIC1_COMMAND_PORT);
    uint8_t isr2 = i686_inb(PIC2_COMMAND_PORT);

    return ((uint16_t)isr2 << 8) | isr1;
}

bool i8259_Probe() {
    i8259_Disable();
    i8259_SetMask(0x6969);

    return i8259_GetMask() == 0x6969;
}

static const PICDriver g_PICDriver = {
    .Name = "8259 PIC",
    .Probe = &i8259_Probe,
    .Initialize = &i8259_Configure,
    .Disable = &i8259_Disable,
    .SendEndOfInterrupt = &i8259_SendEndOfInterrupt,
    .Mask = &i8259_Mask,
    .Unmask = &i8259_Unmask,
};

const PICDriver* i8259_GetDriver() {
    return &g_PICDriver;
}

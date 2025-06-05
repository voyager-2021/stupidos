/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "pic.h"
#include "io.h"

#define PIC1_COMMAND_PORT 0x20
#define PIC1_DATA_PORT 0x21

#define PIC2_COMMAND_PORT 0xa0
#define PIC2_DATA_PORT 0xa1

enum {
    PIC_ICW1_ICW4           = 0x01,
    PIC_ICW1_SINGLE         = 0x02,
    PIC_ICW1_INTERVAL4      = 0x04,
    PIC_ICW1_LEVEL          = 0x08,
    PIC_ICW1_INITIALIZE     = 0x10
} PIC_ICW1;

enum {
    PIC_ICW4_8086           = 0x01,
    PIC_ICW4_AUTO_EOI       = 0x02,
    PIC_ICW4_BUFFER_MASTER  = 0x04,
    PIC_ICW4_BUFFER_SLAVE   = 0x00,
    PIC_ICW4_BUFFERRED      = 0x08,
    PIC_ICW4_SFNM           = 0x10,
} PIC_ICW4;


enum {
    PIC_CMD_END_OF_INTERRUPT    = 0x20,
    PIC_CMD_READ_IRR            = 0x0a,
    PIC_CMD_READ_ISR            = 0x0b,
} PIC_CMD;

void i686_PIC_Configure(uint8_t offsetPic1, uint8_t offsetPic2) {
    i686_outb(PIC1_COMMAND_PORT, PIC_ICW1_ICW4 | PIC_ICW1_INITIALIZE);
    i686_iowait();
    i686_outb(PIC2_COMMAND_PORT, PIC_ICW1_ICW4 | PIC_ICW1_INITIALIZE);
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, offsetPic1);
    i686_iowait();
    i686_outb(PIC1_DATA_PORT, offsetPic2);
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, 0x4);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, 0x2);
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, PIC_ICW4_8086);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, PIC_ICW4_8086);
    i686_iowait();

    i686_outb(PIC1_DATA_PORT, 0);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, 0);
    i686_iowait();
}

void i686_PIC_SendEndOfInterrupt(int irq)
{
    if (irq >= 8)
        i686_outb(PIC2_COMMAND_PORT, PIC_CMD_END_OF_INTERRUPT);
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_END_OF_INTERRUPT);
}

void i686_PIC_Disable()
{
    i686_outb(PIC1_DATA_PORT, 0xff);
    i686_iowait();
    i686_outb(PIC2_DATA_PORT, 0xff);
    i686_iowait();
}

void i686_PIC_Mask(int irq) {
    uint8_t port;

    if (irq < 8) {
        port = PIC1_DATA_PORT;
    } else {
        irq -= 8;
        port = PIC2_DATA_PORT;
    }

    uint8_t mask = i686_inb(PIC1_DATA_PORT);
    i686_outb(PIC1_DATA_PORT,  mask | (1 << irq));
}

void i686_PIC_Unmask(int irq) {
    uint8_t port;

    if (irq < 8) {
        port = PIC1_DATA_PORT;
    } else {
        irq -= 8;
        port = PIC2_DATA_PORT;
    }

    uint8_t mask = i686_inb(PIC1_DATA_PORT);
    i686_outb(PIC1_DATA_PORT,  mask & ~(1 << irq));
}

uint16_t i686_PIC_ReadIrqRequestRegister() {
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_READ_IRR);
    i686_outb(PIC2_COMMAND_PORT, PIC_CMD_READ_IRR);
    return ((uint16_t)i686_inb(PIC2_COMMAND_PORT)) | (((uint16_t)i686_inb(PIC2_COMMAND_PORT)) << 8);
}

uint16_t i686_PIC_ReadInServiceRegister() {
    i686_outb(PIC1_COMMAND_PORT, PIC_CMD_READ_ISR);
    i686_outb(PIC2_COMMAND_PORT, PIC_CMD_READ_ISR);
    return ((uint16_t)i686_inb(PIC2_COMMAND_PORT)) | (((uint16_t)i686_inb(PIC2_COMMAND_PORT)) << 8);
}
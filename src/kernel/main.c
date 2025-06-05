/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include <stdint.h>
#include <stdio.h>
#include <memory.h>
#include <hal/hal.h>
#include <arch/i686/irq.h>

extern uint8_t __bss_start;
extern uint8_t __end;

void crash_me();

void timer(Registers* regs) {
    printf(".");
}

void keyboard(Registers* regs) {
    debugf("Key was pressed!\n");
    logf("  eax=0x%x  ebx=0x%x  ecx=0x%x  edx=0x%x  esi=0x%x  edi=0x%x\r\n",
        regs->eax, regs->ebx, regs->ecx, regs->edx, regs->esi, regs->edi);
    logf("  esp=0x%x  ebp=0x%x  eip=0x%x  eflags=0x%x\r\n",
        regs->esp, regs->ebp, regs->eip, regs->eflags);
    logf("  cs=0x%x  ds=0x%x  ss=0x%x  interrupt=0x%x  errorcode=0x%x\r\n",
        regs->cs, regs->ds, regs->ss, regs->interrupt, regs->error);
}

void __attribute__((section(".entry"))) start(uint16_t bootDrive)
{
    memset(&__bss_start, 0, (&__end) - (&__bss_start));

    HAL_Initialize();

    printf("Hello from kernel!\n");
    debugf("Hello from port e9!\n");
    logf("Hello from log!\n");

    i686_IRQ_RegisterHandler(0, timer);
    i686_IRQ_RegisterHandler(1, keyboard);

    // crash_me();

end:
    for (;;);
}

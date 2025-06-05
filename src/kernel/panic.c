/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "panic.h"
#include <ctype.h>
#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <utils/ptr.h>
#include <arch/i686/io.h>

static inline unsigned short get_ax(void) {
    unsigned short val;
    __asm__ ("mov %%ax, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_bx(void) {
    unsigned short val;
    __asm__ ("mov %%bx, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_cx(void) {
    unsigned short val;
    __asm__ ("mov %%cx, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_dx(void) {
    unsigned short val;
    __asm__ ("mov %%dx, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_si(void) {
    unsigned short val;
    __asm__ ("mov %%si, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_di(void) {
    unsigned short val;
    __asm__ ("mov %%di, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_bp(void) {
    unsigned short val;
    __asm__ ("mov %%bp, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_sp(void) {
    unsigned short val;
    __asm__ ("mov %%sp, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_cs(void) {
    unsigned short val;
    __asm__ ("mov %%cs, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_ds(void) {
    unsigned short val;
    __asm__ ("mov %%ds, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_es(void) {
    unsigned short val;
    __asm__ ("mov %%es, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_ss(void) {
    unsigned short val;
    __asm__ ("mov %%ss, %0" : "=r"(val));
    return val;
}

static inline unsigned short get_ip(void) {
    unsigned short val;
    __asm__ ("call 1f\n"
             "1: pop %0\n"
             : "=r"(val));
    return val;
}

static inline unsigned short get_flags(void) {
    unsigned short val;
    __asm__ ("pushf\n"
             "pop %0\n"
             : "=r"(val));
    return val;
}

void printStackTrace(unsigned short ss, unsigned short* bp)
{
    for (int i = 0; i < 16 && bp != NULL; i++) {
        unsigned short return_ip = *(bp + 1);
        unsigned short prev_bp = *bp;

        printf("  #%d  IP = 0x%x | BP = 0x%x\r\n", i, return_ip, (unsigned int)(uintptr_t)bp);

        if (prev_bp == 0 || prev_bp <= (unsigned short)(uintptr_t)bp)
            break;

        bp = (unsigned short*)MK_FP(ss, prev_bp);
    }
}

void printHex16(uint16_t val)
{
    const char* hex = "0123456789abcdef";
    putc('0');
    putc('x');
    putc(toupper(hex[(val >> 12) & 0xF]));
    putc(toupper(hex[(val >> 8) & 0xF]));
    putc(toupper(hex[(val >> 4) & 0xF]));
    putc(toupper(hex[val & 0xF]));
}

void printRegisters(void)
{
    printf("\r\nREGISTERS:\r\n");
    printf("  AX=%x BX=%x CX=%x DX=%x\r\n", get_ax(), get_bx(), get_cx(), get_dx());
    printf("  SI=%x DI=%x BP=%x SP=%x\r\n", get_si(), get_di(), get_bp(), get_sp());
    printf("  CS=%x DS=%x ES=%x SS=%x\r\n", get_cs(), get_ds(), get_es(), get_ss());
    printf("  IP=%x FLAGS=%x\r\n", get_ip(), get_flags());
}

__attribute__((noreturn)) void halt(const char* reason, bool noTrace, bool noRegisters) {
    printf("\r");
    printf("**********************************\r\n");
    printf("****       KERNEL PANIC       ****\r\n");
    printf("**********************************\r\n");

    printf(">>> %s\r\n", reason);

    if (!noTrace) {
        printf("*** BEGIN TRACE ***\r\n");

        unsigned short ss = get_ss();
        unsigned short* bp = (unsigned short*)MK_FP(ss, get_bp());
        printStackTrace(ss, bp);

        printf("***  END TRACE  ***\r\n\n");
    }

    if (!noRegisters)
        printRegisters();

    // printf("**********************************\r\n");
    // printf("****      SYSTEM STOPPED      ****\r\n");
    // printf("**********************************\r\n");

    // printf("\r\n\n*** KERNEL PANIC ***\r\n");
    // printf(">>> %s\r\n", reason);
    // printf("*** SYSTEM HALTED ***\r\n\n");

    x86_Halt();

    __asm__ ("cli");
    __asm__ ("hlt");

    __builtin_unreachable();
}

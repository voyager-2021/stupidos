#include "panic.h"
#include "ctype.h"
#include "stdint.h"
#include "stdio.h"
#include "x86.h"

#pragma aux get_ax = "mov ax, ax" value[ax]
#pragma aux get_bx = "mov ax, bx" value[ax]
#pragma aux get_cx = "mov ax, cx" value[ax]
#pragma aux get_dx = "mov ax, dx" value[ax]
#pragma aux get_si = "mov ax, si" value[ax]
#pragma aux get_di = "mov ax, di" value[ax]
#pragma aux get_bp = "mov ax, bp" value[ax]
#pragma aux get_sp = "mov ax, sp" value[ax]
#pragma aux get_cs = "mov ax, cs" value[ax]
#pragma aux get_ds = "mov ax, ds" value[ax]
#pragma aux get_es = "mov ax, es" value[ax]
#pragma aux get_ss = "mov ax, ss" value[ax]
#pragma aux get_ip = "mov ax, [bp+2]" value[ax]
#pragma aux get_flags = "pushf" \
                        "pop ax" value[ax]

void printStackTrace(unsigned short* bp)
{
    for (int i = 0; i < 16 && bp != NULL; i++) {
        unsigned short return_ip = *(bp + 1);
        unsigned short prev_bp = *bp;

        printf("  #%d  IP = 0x%x | BP = 0x%x\r\n", i, return_ip, (unsigned int)(uintptr_t)bp);

        if (prev_bp == 0 || prev_bp <= (unsigned short)(uintptr_t)bp)
            break;

        bp = (unsigned short*)prev_bp;
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

void printStackRaw(uint16_t ss, uint16_t sp, long length_bytes)
{
    uint16_t far* stack_ptr;

    long max_bytes = 0x10000 - sp;
    if (length_bytes > max_bytes)
        length_bytes = max_bytes;

    stack_ptr = (uint16_t far*)MK_FP(ss, sp);

    for (int i = 0; i < length_bytes; i++) {
        if (i == 0)
            printf("%x: ", sp + i * 2);

        if (i % 8 == 0 && i != 0)
            printf("\r\n%x: ", sp + i * 2);

        uint16_t val = stack_ptr[i];

        printHex16(val);
        putc(' ');
    }
    printf("\r\n");
}

void printRegisters(void)
{
    printf("\r\nREGISTERS:\r\n");
    printf("  AX=%x BX=%x CX=%x DX=%x\r\n", get_ax(), get_bx(), get_cx(), get_dx());
    printf("  SI=%x DI=%x BP=%x SP=%x\r\n", get_si(), get_di(), get_bp(), get_sp());
    printf("  CS=%x DS=%x ES=%x SS=%x\r\n", get_cs(), get_ds(), get_es(), get_ss());
    printf("  IP=%x FLAGS=%x\r\n", get_ip(), get_flags());
}

#ifndef __INTELLISENSE__
__declspec(noreturn) void halt(const char* reason, bool noTrace, bool noRegisters, bool noRawStack, int rawStackLen) {
    printf("\r");
    printf("**********************************\r\n");
    printf("****       KERNEL PANIC       ****\r\n");
    printf("**********************************\r\n");

    printf(">>> %s\r\n", reason);

    if (!noTrace) {
        printf("*** BEGIN TRACE ***\r\n");

        unsigned short* bp = (unsigned short*)get_bp();
        printStackTrace(bp);

        printf("***  END TRACE  ***\r\n\n");
    }

    if (!noRawStack) {
        uint16_t sp = get_sp();
        uint16_t ss = get_ss();

        printStackRaw(ss, sp, rawStackLen);
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

    __asm {
        cli
        hlt
    .halt:
        jmp .halt
    }
}
#endif

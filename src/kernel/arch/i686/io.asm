; Bare-Metal License v1.0
; Copyright (c) 2025 voyager-2021
; This software is inspired by and includes code from chibicitiberiu's nanobyte_os
;
; You may not use this software for commercial purposes or profit.
; See LICENSE file for full terms.

global i686_outb
i686_outb:
    [bits 32]
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

global i686_inb
i686_inb:
    [bits 32]
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret

global i686_EnableInterrupts
i686_EnableInterrupts:
    sti
    ret

global i686_EnableInterrupts
i686_DisableInterrupts:
    cli
    ret

global crash_me
crash_me:
    int 50
    ret

global i686_panic
i686_panic:
    cli
    hlt
.halt:
    jmp .halt

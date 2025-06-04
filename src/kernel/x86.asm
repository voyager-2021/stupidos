; Bare-Metal License v1.0
; Copyright (c) 2025 voyager-2021
; This software is inspired by and includes code from chibicitiberiu's nanobyte_os
;
; You may not use this software for commercial purposes or profit.
; See LICENSE file for full terms.


global x86_outb
x86_outb:
    [bits 32]
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

global x86_inb
x86_inb:
    [bits 32]
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret

global x86_Halt
x86_Halt:
    cli
    hlt
.halt:
    jmp .halt

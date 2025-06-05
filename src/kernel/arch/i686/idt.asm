; Bare-Metal License v1.0
; Copyright (c) 2025 voyager-2021
; This software is inspired by and includes code from chibicitiberiu's nanobyte_os
;
; You may not use this software for commercial purposes or profit.
; See LICENSE file for full terms.

[bits 32]

global i686_IDT_Load
i686_IDT_Load:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    lidt [eax]

    mov esp, ebp
    pop ebp
    ret

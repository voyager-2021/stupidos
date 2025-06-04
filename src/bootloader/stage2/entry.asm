bits 16

section .entry

extern __bss_start
extern __end

extern start
global entry

entry:
    cli

    mov [g_BootDrive], dl

    mov ax, ds
    mov ss, ax
    mov sp, 0xFFF0
    mov bp, sp

    call enable_a20
    call load_gdt

    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp dword 08h:.pmode

.pmode:
    [bits 32]

    mov ax, 0x10
    mov ds, ax
    mov ss, ax

    mov edi, __bss_start
    mov ecx, __end
    sub ecx, edi
    mov al, 0
    cld
    rep stosb

    xor edx, edx
    mov dl, [g_BootDrive]
    push edx
    call start

    cli
    hlt

enable_a20:
    [bits 16]

    call a20_wait_input
    mov al, kbd_controller_disable_keyboard
    out kbd_controller_command_port, al

    call a20_wait_input
    mov al, kbd_controller_read_ctrl_output_port
    out kbd_controller_command_port, al

    call a20_wait_output
    in al, kbd_controller_data_port
    push eax

    call a20_wait_input
    mov al, kbd_controller_write_ctrl_output_port
    out kbd_controller_command_port, al

    call a20_wait_input
    pop eax
    or al, 2
    out kbd_controller_data_port, al

    call a20_wait_input
    mov al, kbd_controller_enable_keyboard
    out kbd_controller_command_port, al

    call a20_wait_input
    ret

a20_wait_input:
    [bits 16]

    in al, kbd_controller_command_port
    test al, 2
    jnz a20_wait_input
    ret

a20_wait_output:
    [bits 16]

    in al, kbd_controller_command_port
    test al, 1
    jz a20_wait_output
    ret

load_gdt:
    [bits 16]
    lgdt [g_GDTDesc]
    ret

kbd_controller_data_port                 equ 0x60
kbd_controller_command_port              equ 0x64
kbd_controller_disable_keyboard          equ 0xad
kbd_controller_enable_keyboard           equ 0xae
kbd_controller_read_ctrl_output_port     equ 0xd0
kbd_controller_write_ctrl_output_port    equ 0xd1

screen_buffer                            equ 0xb8000

g_GDT:
            dq 0


            dw 0xffff
            dw 0
            db 0
            db 10011010b
            db 11001111b
            db 0

            dw 0xffff
            dw 0
            db 0
            db 10010010b
            db 11001111b
            db 0

            dw 0xffff
            dw 0
            db 0
            db 10011010b
            db 00001111b
            db 0

            dw 0xffff
            dw 0
            db 0
            db 10010010b
            db 00001111b
            db 0

g_GDTDesc:  dw g_GDTDesc - g_GDT - 1
            dd g_GDT

g_BootDrive: db 0

bits 16

%define ENDL 0x0d, 0x0a

section _ENTRY class=CODE

extern _cstart_
global entry

entry:
    mov si, msg_hello
    call puts

    cli
    mov ax, ds
    mov ss, ax
    mov sp, 0
    mov bp, sp
    sti

    xor dh, dh
    push dx
    call _cstart_

    cli
    hlt

; Prints a string to the screen
; Params:
;   - ds:si points to string
puts:
    push si
    push ax

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret

msg_hello: db "Hello from assembly!", ENDL, 0

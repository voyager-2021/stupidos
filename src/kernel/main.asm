org 0x0
bits 16

%define ENDL 0x0d, 0x0a

_start:
    mov si, msg_hello
    call puts

    cli
    hlt

.halt:
    jmp .halt

;
; Basic routines
;

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

msg_hello: db 'Hello world from the kernel!', ENDL, 0

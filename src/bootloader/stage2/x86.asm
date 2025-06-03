bits 16

section _TEXT class=CODE

global __U4D
global __U4M

__U4D:
    shl edx, 16
    mov dx, ax
    mov eax, edx
    xor edx, edx

    shl ecx, 16
    mov cx, bx

    div ecx
    mov ebx, edx
    mov ecx, edx
    shr ecx, 16

    mov edx, eax
    shr edx, 16

    ret

__U4M:
    shl edx, 16         ; dx to upper half of edx
    mov dx, ax          ; m1 in edx
    mov eax, edx        ; m1 in eax

    shl ecx, 16         ; cx to upper half of ecx
    mov cx, bx          ; m2 in ecx

    mul ecx             ; result in edx:eax (we only need eax)
    mov edx, eax        ; move upper half to dx
    shr edx, 16

    ret

global _x86_div64_32
global _x86_Video_WriteCharTeletype

; void _cdecl x86_div64_32 \
;     (uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);

_x86_div64_32:
    push bp
    mov bp, sp

    push bx

    mov eax, [bp + 8]
    mov ecx, [bp + 12]
    xor edx, edx
    div ecx

    mov bx, [bp + 16]
    mov [bx + 4], eax

    mov eax, [bp + 4]
    div ecx

    mov [bx], eax
    mov bx, [bp + 18]
    mov [bx], edx

    pop bx

    mov sp, bp
    pop bp
    ret

; int 0x10 ah=0x0e
; args: character, page
_x86_Video_WriteCharTeletype:
    push bp
    mov bp, sp

    push bx

    mov ah, 0x0e
    mov al, [bp + 4]
    mov bh, [bp + 6]

    int 0x10

    pop bx

    mov sp, bp
    pop bp
    ret

global _x86_Disk_GetDriveParams
global _x86_Disk_Reset
global _x86_Disk_Read

; bool _cdecl x86_Disk_Reset \
;     (uint8_t drive);
_x86_Disk_Reset:
    push bp
    mov bp, sp

    mov ah, 0
    mov dl, [bp + 4]

    stc
    int 0x13

    mov ax, 1
    sbb ax, 0

    mov sp, bp
    pop bp
    ret

; bool _cdecl x86_Disk_Read \
;     (uint8_t drive, uint16_t cylinder, uint16_t head, uint16_t sector, uint8_t count, uint8_t far* dataOut);
_x86_Disk_Read:
    push bp
    mov bp, sp

    push bx
    push es

    mov dl, [bp + 4]

    mov ch, [bp + 6]
    mov cl, [bp + 7]
    shl cl, 6

    mov al, [bp + 8]
    and al, 3Fh
    or cl, al

    mov dh, [bp + 10]

    mov al, [bp + 12]

    mov bx, [bp + 16]
    mov es, bx
    mov bx, [bp + 14]

    mov ah, 02h
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    pop es
    pop bx

    mov sp, bp
    pop bp
    ret

; bool _cdecl x86_Disk_GetDriveParams \
;     (uint8_t drive, uint8_t* driveTypeOut, uint16_t* cylindersOut, uint16_t* sectorsOut, uint16_t* headsOut);
_x86_Disk_GetDriveParams:
    push bp
    mov bp, sp

    push es
    push bx
    push si
    push di

    mov dl, [bp + 4]
    mov ah, 08h
    mov di, 0
    mov es, di
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    mov si, [bp + 6]
    mov [si], bl

    mov bl, ch
    mov bh, cl
    shr bh, 6
    mov si, [bp + 8]
    mov [si], bx

    xor ch, ch
    and cl, 3Fh
    mov si, [bp + 10]
    mov [si], cx

    mov cl, dh
    mov si, [bp + 12]
    mov [si], cx

    pop di
    pop si
    pop bx
    pop es

    mov sp, bp
    pop bp
    ret

global _x86_Halt

_x86_Halt:
    cli
    hlt
.halt:
    jmp .halt

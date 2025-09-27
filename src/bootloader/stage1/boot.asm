; Copyright (c) 2025 voyager-2021
; This software is inspired by and includes code from chibicitiberiu's nanobyte_os
;
; You may not use this software for commercial purposes or profit.
; See LICENSE file for full terms.

org 0x7c00
bits 16

%define ENDL 0x0d, 0x0a

;
; FAT12 header
;
jmp short _start
nop

bdb_oem:                        db 'MSWIN4.1'
bdb_bytes_per_sector:           dw 512
bdb_sector_per_cluster:         db 1
bdb_reserved_sectors:           dw 1
bdb_fat_count:                  db 2
bdb_dir_entries_count:          dw 0xe0
bdb_total_sectors:              dw 2880
bdb_media_descriptor_type:      db 0xf0
bdb_sectors_per_fat:            dw 9
bdb_sectors_per_track:          dw 18
bdb_heads:                      dw 2
bdb_hidden_sectors:             dd 0
bdb_large_sector_count:         dd 0

; extended boot record
ebr_drive_number:               db 0
                                db 0
ebr_signature:                  db 0x29
ebr_volume_id:                  db 0xbe, 0x69, 0x42, 0x00
ebr_volume_label:               db 'nullos     '
ebr_system_id:                  db 'FAT12   '

times 90-($-$$) db 0

_start:
    mov ax, 0
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7c00

    push es
    push word .after
    retf

.after:
    mov [ebr_drive_number], dl

    mov si, msg_loading
    call puts

    mov ah, 0x41
    mov bx, 0x55aa
    stc

    int 13h

    jc .no_disk_extensions
    cmp bx, 0xaa55
    jne .no_disk_extensions

    mov byte [has_disk_extensions], 1
    jmp .after_disk_extensions_check

.no_disk_extensions:
    mov byte [has_disk_extensions], 0

.after_disk_extensions_check:
    mov si, stage2_location

    mov ax, STAGE2_LOAD_SEGMENT
    mov es, ax

    mov bx, STAGE2_LOAD_OFFSET

.loop:
    mov eax, [si]
    add si, 4
    mov cl, [si]
    inc si

    cmp eax, 0
    je .read_finish

    call disk_read

    xor ch, ch
    shl cx, 5
    mov di, es
    add di, cx
    mov es, di

    jmp .loop

.read_finish:
    mov dl, [ebr_drive_number]
    mov ax, STAGE2_LOAD_SEGMENT
    mov ds, ax
    mov es, ax

    jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET

    jmp wait_key_and_reboot

    cli
    hlt

;
; Error handlers
;

floppy_error:
    mov si, msg_read_failed
    call puts

    jmp wait_key_and_reboot

stage2_not_found:
    mov si, msg_stage2_not_found
    call puts

    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 0x16
    jmp 0xffff:0x0000

.halt:
    cli
    hlt

;
; Basic routines
;

; Prints a string to the screen
; Params:
;   - ds:si points to string
puts:
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

;
; Disk routines
;

; Converts LBA to CHS
; Params:
;   - ax: LBA address
; Returns:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head

lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track]

    inc dx
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al
    pop ax

    ret

; Reads sectors from disk
; Params:
;   - eax: LBA address
;   - cl: number of sectors to read
;   - dl: drive number
;   - es:bx: memory address where to store read data

disk_read:
    push eax
    push bx
    push cx
    push dx
    push si
    push di

    cmp byte [has_disk_extensions], 1
    jne .no_disk_extensions

    mov [disk_extensions_dap.lba], eax
    mov [disk_extensions_dap.segment], es
    mov [disk_extensions_dap.offset], bx
    mov [disk_extensions_dap.count], cl

    mov ah, 0x42
    mov si, disk_extensions_dap
    mov di, 3

    jmp .retry

.no_disk_extensions:
    push cx
    call lba_to_chs
    pop ax

    mov ah, 0x02
    mov di, 3

.retry:
    pusha
    stc
    int 13h
    jnc .done

    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop eax

    ret

; Resets disk controller
; Params:
;   - dl: drive number
disk_reset:
    pusha
    mov ah, 0
    stc
    int 0x13
    jc floppy_error
    popa
    ret

msg_loading:            db 'Loading...', ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_stage2_not_found:   db 'Stage 2 not found!', ENDL, 0
file_stage2_bin:        db 'STAGE2  BIN'

has_disk_extensions:    db 0
disk_extensions_dap:
    .size:              db 0x10
                        db 0
    .count:             dw 0
    .offset:            dw 0
    .segment:           dw 0
    .lba:               dq 0

STAGE2_LOAD_SEGMENT     equ 0x0
STAGE2_LOAD_OFFSET      equ 0x500

times 510-30-($-$$)     db 0

stage2_location:        times 30 db 0

dw 0xaa55

buffer:

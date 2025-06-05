/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#include "vfs.h"
#include <arch/i686/vga_text.h>
#include <arch/i686/e9.h>
#include <stdio.h>

__attribute__((section(".logbuffer")))
char g_LogBuffer[LOG_BUFFER_SIZE];

__attribute__((section(".logbuffer")))
size_t g_LogPos = 0;

extern char __logbuffer_start;
extern char __logbuffer_end;

int VFS_Write(fd_t file, uint8_t* data, size_t size) {
    switch (file) {
        case VFS_FD_STDIN:
            return 0;

        case VFS_FD_STDOUT:
        case VFS_FD_STDERR:
            for (size_t i = 0; i < size; i++)
                VGA_putc(data[i]);
            return size;

        case VFS_FD_STDDBG:
            for (size_t i = 0; i < size; i++)
                e9_putc(data[i]);
            return size;

        case VFS_FD_STDLOG:
            for (size_t i = 0; i < size; i++) {
                if (g_LogPos < LOG_BUFFER_SIZE - 1) {
                    g_LogBuffer[g_LogPos++] = data[i];
                } else {
                    break;
                }
            }
            return size;

        default:
            break;
    }
    return 0;
}

const char* VFS_GetLogBuffer(void) {
    return g_LogBuffer;
}

void VFS_ResetLogBuffer(void) {
    g_LogPos = 0;
}

char* VFS_GetLogBufferStart(void) {
    return &__logbuffer_start;
}

size_t VFS_GetLogBufferSize(void) {
    return (size_t)(&__logbuffer_end - &__logbuffer_start);
}

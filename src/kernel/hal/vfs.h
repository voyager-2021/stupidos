/*
 * Bare-Metal License v1.0
 * Copyright (c) 2025 voyager-2021
 * This software is inspired by and includes code from chibicitiberiu's nanobyte_os
 *
 * You may not use this software for commercial purposes or profit.
 * See LICENSE file for full terms.
 */

#pragma once

#include <stdint.h>
#include <stddef.h>

typedef int fd_t;

#define VFS_FD_STDIN    0
#define VFS_FD_STDOUT   1
#define VFS_FD_STDERR   2
#define VFS_FD_STDDBG   3
#define VFS_FD_STDLOG   4

#define LOG_BUFFER_SIZE 4096

extern char g_LogBuffer[LOG_BUFFER_SIZE];
extern size_t g_LogPos;

int VFS_Write(fd_t file, uint8_t* data, size_t size);

const char* VFS_GetLogBuffer(void);

char* VFS_GetLogBufferStart(void);
size_t VFS_GetLogBufferSize(void);
size_t VFS_GetLogBufferUsed(void);

void VFS_ResetLogBuffer(void);


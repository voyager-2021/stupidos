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
#include <stdarg.h>
#include <hal/vfs.h>

void fputc(char c, fd_t file);
void fputs(const char* str, fd_t file);
void vfprintf(fd_t file, const char* fmt, va_list args);
void fprintf(fd_t file, const char* fmt, ...);
void fprint_buffer(fd_t file, const char* msg, const void* buffer, uint32_t count);

void putc(char c);
void puts(const char* str);
void printf(const char* fmt, ...);
void print_buffer(const char* msg, const void* buffer, uint32_t count);

void debugc(char c);
void debugs(const char* str);
void debugf(const char* fmt, ...);
void debug_buffer(const char* msg, const void* buffer, uint32_t count);

void logc(char c);
void logs(const char* str);
void logf(const char* fmt, ...);
void log_buffer(const char* msg, const void* buffer, uint32_t count);

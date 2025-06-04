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
#include <stdbool.h>
#include <stddef.h>
#include "comtypes.h"

// Define NORETURN macro for compiler-specific noreturn attribute
#if defined(_MSC_VER)
  #define NORETURN __declspec(noreturn)
#elif defined(__GNUC__) || defined(__clang__)
  #define NORETURN __attribute__((noreturn))
#else
  #define NORETURN
#endif

static inline unsigned short get_ax(void);
static inline unsigned short get_bx(void);
static inline unsigned short get_cx(void);
static inline unsigned short get_dx(void);
static inline unsigned short get_si(void);
static inline unsigned short get_di(void);
static inline unsigned short get_bp(void);
static inline unsigned short get_sp(void);
static inline unsigned short get_cs(void);
static inline unsigned short get_ds(void);
static inline unsigned short get_es(void);
static inline unsigned short get_ss(void);
static inline unsigned short get_ip(void);
static inline unsigned short get_flags(void);

NORETURN void halt(const char* reason, bool noTrace, bool noRegisters);

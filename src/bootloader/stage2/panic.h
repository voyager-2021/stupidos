#pragma once

#include "stdint.h"

unsigned short get_ax(void);
unsigned short get_bx(void);
unsigned short get_cx(void);
unsigned short get_dx(void);
unsigned short get_si(void);
unsigned short get_di(void);
unsigned short get_bp(void);
unsigned short get_sp(void);
unsigned short get_cs(void);
unsigned short get_ds(void);
unsigned short get_es(void);
unsigned short get_ss(void);
unsigned short get_ip(void);
unsigned short get_flags(void);

#ifdef __INTELLISENSE__
void halt(const char* reason, bool noTrace, bool noRegisters, bool noRawStack, int rawStackLen);
#else
__declspec(noreturn) void halt(const char* reason, bool noTrace, bool noRegisters, bool noRawStack, int rawStackLen);
#endif

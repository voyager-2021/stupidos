#pragma once

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))

#define MK_FP(seg, ofs) ((void*)((unsigned long)(seg) << 4) + (unsigned long)(ofs))


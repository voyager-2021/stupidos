#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    const char far* far_str = "far string";

    puts("Hello world from C!\r\n");

    printf("printf from scratch!\r\n");

    printf("%% %c %s %ls\r\n", 'a', "string", far_str);
    printf("%d %i %x %p %o %hd %hi %hhu %hhd\r\n", 1234, -5678, 0xdead, 0xbeef, 012345, (short)27, (short)-42, (unsigned char)20, (signed char)-10);
    printf("%ld %lx %lld %llx\r\n", -100000000l, 0xdeadbeeful, 10200300400ll, 0xdeadbeeffeebdaedull);
    // printf("Boot drive number: %d\r\n", bootDrive);

    for (;;)
        ;
}

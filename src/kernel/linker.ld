ENTRY(start)
OUTPUT_FORMAT("binary")

MEMORY
{
    phys (rxw) : ORIGIN = 0x00100000, LENGTH = 16M
}

SECTIONS
{
    . = ORIGIN(phys);

    .entry      : { __entry_start = .;  *(.entry)   } > phys
    .text       : { __text_start = .;   *(.text)    } > phys
    .data       : { __data_start = .;   *(.data)    } > phys
    .rodata     : { __rodata_start = .; *(.rodata)  } > phys
    .bss        : { __bss_start = .;    *(.bss COMMON) } > phys

    .logbuffer ALIGN(4K) : {
        __logbuffer_start = .;
        KEEP(*(.logbuffer))
        __logbuffer_end = .;
    } > phys

    __end = .;
}

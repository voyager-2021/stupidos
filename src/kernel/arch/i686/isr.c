#include <stddef.h>
#include <stdio.h>
#include "io.h"
#include "isr.h"
#include "idt.h"
#include "gdt.h"

ISRHandler g_ISRHandlers[256];

static const char* const g_Exceptions[] = {
    "Divide by zero error",
    "Debug",
    "Non-maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Bound Range Exceeded",
    "Invalid Opcode",
    "Device Not Available",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Invalid TSS",
    "Segment Not Present",
    "Stack-Segment Fault",
    "General Protection Fault",
    "Page Fault",
    "",
    "x87 Floating-Point Exception",
    "Alignment Check",
    "Machine Check",
    "SIMD Floating-Point Exception",
    "Virtualization Exception",
    "Control Protection Exception ",
    "",
    "",
    "",
    "",
    "",
    "",
    "Hypervisor Injection Exception",
    "VMM Communication Exception",
    "Security Exception",
    ""
};

void i686_ISR_InitializeGates();

void i686_ISR_Initialize() {
    i686_ISR_InitializeGates();
    for (int i = 0; i < 256; i++)
        i686_IDT_EnableGate(i);

    i686_IDT_DisableGate(50);
}

void __attribute__((cdecl)) i686_ISR_Handler(Registers* regs) {
    if (g_ISRHandlers[regs->interrupt] != NULL)
        g_ISRHandlers[regs->interrupt](regs);

    else if (regs->interrupt >= 32)
        printf("\r\nUnhandled interrupt %d!\r\n", regs->interrupt);

    else {
        printf("\r\nUnhandled exception '%d' type '%s':\r\n", regs->interrupt, g_Exceptions[regs->interrupt]);

        printf("  eax=0x%x  ebx=0x%x  ecx=0x%x  edx=0x%x  esi=0x%x  edi=0x%x\r\n",
            regs->eax, regs->ebx, regs->ecx, regs->edx, regs->esi, regs->edi);

        printf("  esp=0x%x  ebp=0x%x  eip=0x%x  eflags=0x%x\r\n",
            regs->eflags, regs->esp, regs->ebp, regs->eip);

        printf("  cs=0x%x  ds=0x%x  ss=0x%x  interrupt=0x%x  errorcode=0x%x\r\n",
            regs->cs, regs->ds, regs->ss, regs->interrupt, regs->error);

        i686_panic();
    }
}

void i686_ISR_RegisterHandler(int interrupt, ISRHandler handler)
{
    g_ISRHandlers[interrupt] = handler;
    i686_IDT_EnableGate(interrupt);
}

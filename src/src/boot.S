#include "arm/sysregs.h"
#include "mm.h"

.section ".text.boot" // this section is put at the beginning of the linked output image

.globl _start
_start:
    mrs x0, mpidr_el1
    and x0, x0, #0xFF   // check processor id
    cbz x0, master      // if primary CPU, jump to master, others: hang
    b   proc_hang

proc_hang:
    b   proc_hang

master:
    ldr x0, =SCTLR_VALUE_MMU_DISABLED
    msr sctlr_el1, x0                   # disable MMU till we implement paging

    ldr x0, =HCR_VALUE
    msr hcr_el2, x0                     # hypervisor configuration register. execution state set ot AArch64

    ldr x0, =SCR_VALUE                  # secure configuration register
    msr scr_el3, x0

    ldr x0, =SPSR_VALUE
    msg spsr_el3, x0

    adr x0, el1_entry
    msr elr_el3, x0

    eret


el1_entry:
    adr x0, bss_begin
    adr x1, bss_end
    sub x1, x1, x0
    bl  memzero         // memzero takes two arguments, x0 : start addr, x1 : num bytes to zero

    mov sp, #LOW_MEMORY
    bl  kernel_main
    b   proc_hang       // should never come here

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
    adr x0, bss_begin
    adr x1, bss_end
    sub x1, x1, x0
    bl  memzero         // memzero takes two arguments, x0 : start addr, x1 : num bytes to zero

    mov sp, #LOW_MEMORY
    bl  kernel_main
    b   proc_hang       // should never come here

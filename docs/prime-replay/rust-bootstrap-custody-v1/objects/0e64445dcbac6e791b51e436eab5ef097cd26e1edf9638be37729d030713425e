// AArch64 ELF assembly. Stack is a separate future host mapping, never reply RAM.
.section .text.boot,"ax",@progbits
.balign 4
.global _start
.type _start,@function
_start:
    mov     x9, #0x4000
    movk    x9, #0x1001, lsl #16
    mov     sp, x9
    mov     x29, xzr
    mov     x30, xzr
    mov     x9, #0x4000
    movk    x9, #0x1000, lsl #16
    ldar    x0, [x9]
    ldr     x1, [x9, #8]
    ldr     x2, [x9, #16]
    ldr     x3, [x9, #24]
    bl      epr_guest_evaluate
    cmp     x0, #42
    b.ne    epr_guest_reject
    // X0-X18 are caller-clobbered; reconstruct every address after Rust returns.
    mov     x1, #0x8000
    movk    x1, #0x1000, lsl #16
    mov     x3, #0xc000
    movk    x3, #0x1000, lsl #16
    mov     x4, #1
    str     x4, [x1, #8]
    str     x0, [x1, #16]
    str     xzr, [x1, #24]
    stlr    x4, [x1]
    dsb     sy
.global epr_guest_doorbell
.type epr_guest_doorbell,@function
epr_guest_doorbell:
    str     w4, [x3]
.global epr_guest_returned_doorbell
.type epr_guest_returned_doorbell,@function
epr_guest_returned_doorbell:
    brk     #0xdead
1:  b       1b
.global epr_guest_reject
.type epr_guest_reject,@function
epr_guest_reject:
    brk     #0xbad
2:  b       2b
.global epr_guest_panic
.type epr_guest_panic,@function
epr_guest_panic:
    brk     #0xbaf
3:  b       3b
.size _start, .-_start

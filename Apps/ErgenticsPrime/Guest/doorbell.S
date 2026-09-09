// Freestanding AArch64, little endian. No stack, runtime, syscall or loop.
// The host loads only this fixed __text byte sequence at IPA 0x10000000.
// Request: [sequence=1, ABI=1, a=19, b=23], each little-endian uint64.
// Reply:   [sequence=1, ABI=1, sum=42, status=0].
// The expected terminal is an intercepted 32-bit write attempt, not a
// completed MMIO store. The host never advances PC or resumes this image.
.text
.p2align 2
.globl _epr_tiny_guest_start
_epr_tiny_guest_start:
    mov     x0, #0x4000
    movk    x0, #0x1000, lsl #16
    mov     x1, #0x8000
    movk    x1, #0x1000, lsl #16
    mov     x3, #0xc000
    movk    x3, #0x1000, lsl #16
    ldar    x4, [x0]
    cmp     x4, #1
    b.ne    1f
    ldr     x5, [x0, #8]
    cmp     x5, #1
    b.ne    1f
    ldr     x6, [x0, #16]
    ldr     x7, [x0, #24]
    add     x6, x6, x7
    str     x5, [x1, #8]
    str     x6, [x1, #16]
    str     xzr, [x1, #24]
    stlr    x4, [x1]
    dsb     sy
.globl _epr_tiny_guest_doorbell
_epr_tiny_guest_doorbell:
    str     w4, [x3]
    brk     #0xdead
1:
    brk     #0xbad
.globl _epr_tiny_guest_end
_epr_tiny_guest_end:

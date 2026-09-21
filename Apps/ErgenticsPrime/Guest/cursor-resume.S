// Freestanding AArch64 H3 cursor/resume fixture, little endian.
// Phase A preserves the H2 arithmetic and first doorbell exactly through
// offset 0x50. Phase B begins at 0x54 and can succeed only if both X6 and the
// reply page were restored from the captured cursor. It publishes 43 under
// sequence 2 and traps at the second doorbell instruction at offset 0x7c.
// No stack, runtime, syscall, loop, loader or caller-supplied input exists.
.text
.p2align 2
.globl _epr_h3_guest_start
_epr_h3_guest_start:
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
.globl _epr_h3_guest_checkpoint_doorbell
_epr_h3_guest_checkpoint_doorbell:
    str     w4, [x3]
.globl _epr_h3_guest_resume
_epr_h3_guest_resume:
    cmp     x6, #42
    b.ne    1f
    ldr     x8, [x1, #16]
    cmp     x8, #42
    b.ne    1f
    add     x8, x8, #1
    str     x8, [x1, #24]
    mov     x4, #2
    stlr    x4, [x1]
    dsb     sy
.globl _epr_h3_guest_terminal_doorbell
_epr_h3_guest_terminal_doorbell:
    str     w4, [x3]
    brk     #0xdead
1:
    brk     #0xbad
.globl _epr_h3_guest_end
_epr_h3_guest_end:

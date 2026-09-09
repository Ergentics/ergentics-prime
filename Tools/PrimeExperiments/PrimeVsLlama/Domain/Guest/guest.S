// Fixed freestanding AArch64 step loop. Code IPA0x10000000; data IPA0x10004000.
// State: count8, min12, completed16, terminal20, active24, predictions32,
// allowedCount52; jobs64 (stride280): inputCount0, feedbackCount4,
// bindings8/16 {inputOffset,sourceJobIndex}, input IDs24. No stack/OS services.
.text
.p2align 2
.globl _epr_prime_guest_start
_epr_prime_guest_start:
    mov     x20, #0x4000
    movk    x20, #0x1000, lsl #16
    ldr     w22, [x20, #8]
    ldr     w23, [x20, #12]
    ldr     w28, [x20, #52]
    mov     w21, #0
    mov     w27, #-1
    add     x24, x20, #64
Ljob:
    str     w21, [x20, #24]
    cmp     w21, w22
    b.eq    Lcomplete
    ldr     w25, [x24]
    ldr     w26, [x24, #4]
    mov     w11, #0
    add     x10, x24, #8
Lfeedback:
    cmp     w11, w26
    b.eq    Linfer
    // Guest loads each requested source from its OWN committed predictions.
    ldr     w12, [x10]
    ldr     w13, [x10, #4]
    add     x14, x20, #32
    ldr     w27, [x14, w13, uxtw #2]
    sub     w9, w27, w23
    cmp     w9, w28
    b.hs    Linvalid
    add     x14, x24, #24
    str     w27, [x14, w12, uxtw #2]
    add     x10, x10, #8
    add     w11, w11, #1
    b       Lfeedback
Linfer:
    mov     x0, x21
    add     x1, x24, #24
    mov     x2, x25
    mov     x3, x23
    dsb     sy
.globl _epr_prime_guest_infer
_epr_prime_guest_infer:
    hvc     #0x41
.globl _epr_prime_guest_infer_resume
_epr_prime_guest_infer_resume:
    mov     w27, w0
    add     x10, x20, #32
    str     w27, [x10, w21, uxtw #2]
    add     w21, w21, #1
    str     w21, [x20, #16]
    add     x24, x24, #280
    b       Ljob
Lcomplete:
    mov     w9, #1
    str     w9, [x20, #20]
    mov     x0, x21
    mov     x1, #1
    mov     x2, x27
    mov     x3, x23
    dsb     sy
.globl _epr_prime_guest_complete
_epr_prime_guest_complete:
    hvc     #0x42
.globl _epr_prime_guest_complete_resume
_epr_prime_guest_complete_resume:
    brk     #0xdead
Linvalid:
    mov     w9, #2
    str     w9, [x20, #20]
    mov     x0, x21
    mov     x1, #2
    mov     x2, x27
    mov     x3, x23
    dsb     sy
.globl _epr_prime_guest_invalid
_epr_prime_guest_invalid:
    hvc     #0x43
.globl _epr_prime_guest_invalid_resume
_epr_prime_guest_invalid_resume:
    brk     #0xbad
.globl _epr_prime_guest_end
_epr_prime_guest_end:

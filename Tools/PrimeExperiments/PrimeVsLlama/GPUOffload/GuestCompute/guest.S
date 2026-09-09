// Fixed 2D field operation. Code IPA0x10000000, data IPA0x10004000.
// Control: stage8, operation12, guestReadCount16, checksum24, valueCount32.
// Input64. Reply4096: valueCount0,reserved4,packed F32 values8.
.text
.p2align 2
.globl _epr_prime_compute_start
_epr_prime_compute_start:
    mov     x20, #0x4000
    movk    x20, #0x1000, lsl #16
    add     x21, x20, #4096
    ldr     w22, [x20, #32]
    mov     w9, #1
    str     w9, [x20, #8]
    mov     x0, #1
    add     x1, x20, #64
    mov     x2, x21
    mov     x3, x22
    dsb     sy
.globl _epr_prime_compute_request
_epr_prime_compute_request:
    hvc     #0x51
.globl _epr_prime_compute_request_resume
_epr_prime_compute_request_resume:
    // Host has validated count and all finite returned values before resume.
    ldr     w22, [x21]
    add     x10, x21, #8
    mov     w23, #0
    mov     x27, #0x2325
    movk    x27, #0x8422, lsl #16
    movk    x27, #0x9ce4, lsl #32
    movk    x27, #0xcbf2, lsl #48
    mov     x28, #0x01b3
    movk    x28, #0x0100, lsl #32
Lword:
    ldr     w12, [x10], #4
    eor     x27, x27, x12
    mul     x27, x27, x28
    add     w23, w23, #1
    cmp     w23, w22
    b.lo    Lword
    str     w23, [x20, #16]
    str     x27, [x20, #24]
    mov     w9, #2
    str     w9, [x20, #8]
    mov     x0, #2
    mov     x1, x23
    mov     x2, x27
    mov     x3, x22
    dsb     sy
.globl _epr_prime_compute_complete
_epr_prime_compute_complete:
    hvc     #0x52
.globl _epr_prime_compute_complete_resume
_epr_prime_compute_complete_resume:
    brk     #0xdead
.globl _epr_prime_compute_end
_epr_prime_compute_end:

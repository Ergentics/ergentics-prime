#ifndef ERGENTICS_RUST_BOOTSTRAP_IMAGE_H
#define ERGENTICS_RUST_BOOTSTRAP_IMAGE_H

/* Exact, independently extracted bytes from both retained bootstrap builds:
 * Control/rust-guest-bootstrap-2026-08-30.YtXTfY/{build-A,build-B}/image.bin
 * SHA-256: 6e1b2a92646a69ef353491b2cde8104c6d6f311bc4d03bb8cb3bd5bb28f4dfa1
 * This is an in-image constant, not an ELF/Mach-O/path loader. */
#define RUST_LE32(v) ((v) & 255), (((v) >> 8) & 255), (((v) >> 16) & 255), (((v) >> 24) & 255)
static const unsigned char rust_bootstrap_image[] = {
    RUST_LE32(0xd2880009U), RUST_LE32(0xf2a20029U), RUST_LE32(0x9100013fU),
    RUST_LE32(0xaa1f03fdU), RUST_LE32(0xaa1f03feU), RUST_LE32(0xd2880009U),
    RUST_LE32(0xf2a20009U), RUST_LE32(0xc8dffd20U), RUST_LE32(0xf9400521U),
    RUST_LE32(0xf9400922U), RUST_LE32(0xf9400d23U), RUST_LE32(0x94000014U),
    RUST_LE32(0xf100a81fU), RUST_LE32(0x540001c1U), RUST_LE32(0xd2900001U),
    RUST_LE32(0xf2a20001U), RUST_LE32(0xd2980003U), RUST_LE32(0xf2a20003U),
    RUST_LE32(0xd2800024U), RUST_LE32(0xf9000424U), RUST_LE32(0xf9000820U),
    RUST_LE32(0xf9000c3fU), RUST_LE32(0xc89ffc24U), RUST_LE32(0xd5033f9fU),
    RUST_LE32(0xb9000064U), RUST_LE32(0xd43bd5a0U), RUST_LE32(0x14000000U),
    RUST_LE32(0xd42175a0U), RUST_LE32(0x14000000U), RUST_LE32(0xd42175e0U),
    RUST_LE32(0x14000000U), RUST_LE32(0xa9bf7bfdU), RUST_LE32(0xf1005c7fU),
    RUST_LE32(0x52800548U), RUST_LE32(0x910003fdU), RUST_LE32(0xfa530840U),
    RUST_LE32(0xfa410820U), RUST_LE32(0xfa410800U), RUST_LE32(0x9a9f0100U),
    RUST_LE32(0xa8c17bfdU), RUST_LE32(0xd65f03c0U)
};
#undef RUST_LE32
_Static_assert(sizeof(rust_bootstrap_image) == 164, "Frozen Rust bootstrap image size");

#define RUST_LE64(v) ((v) & 255), (((v) >> 8) & 255), (((v) >> 16) & 255), (((v) >> 24) & 255), \
    (((v) >> 32) & 255), (((v) >> 40) & 255), (((v) >> 48) & 255), (((v) >> 56) & 255)
/* Sorted mapped slots: IPA, length, R/W/X bits; then unmapped doorbell,
 * instruction offset, initial/restored SP and copied stack-frame length. */
static const unsigned char rust_memory_contract[] = {
    RUST_LE64(UINT64_C(0x10000000)), RUST_LE64(UINT64_C(16384)), RUST_LE64(UINT64_C(5)),
    RUST_LE64(UINT64_C(0x10004000)), RUST_LE64(UINT64_C(16384)), RUST_LE64(UINT64_C(1)),
    RUST_LE64(UINT64_C(0x10008000)), RUST_LE64(UINT64_C(16384)), RUST_LE64(UINT64_C(3)),
    RUST_LE64(UINT64_C(0x10010000)), RUST_LE64(UINT64_C(16384)), RUST_LE64(UINT64_C(3)),
    RUST_LE64(UINT64_C(0x1000c000)), RUST_LE64(UINT64_C(96)),
    RUST_LE64(UINT64_C(0x10014000)), RUST_LE64(UINT64_C(16))
};
static const unsigned char rust_expected_stack_frame[] = {
    RUST_LE64(UINT64_C(0)), RUST_LE64(UINT64_C(0x10000030))
};
#undef RUST_LE64
_Static_assert(sizeof(rust_memory_contract) == 128, "Frozen Rust memory contract size");
_Static_assert(sizeof(rust_expected_stack_frame) == 16, "Frozen Rust stack frame size");
#endif

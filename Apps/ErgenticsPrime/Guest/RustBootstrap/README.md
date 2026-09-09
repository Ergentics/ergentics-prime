# Freestanding Rust guest bootstrap

Build-only successor to `Guest/doorbell.S`, not a host Rust library or guest OS.
The Swift/C app and its current 92-byte image remain unchanged.

The assembly shim copies the fixed request into four integer arguments. Rust
validates `[1, 1, 19, 23]` and returns 42 or the reserved rejection value 0.
Assembly owns stack setup, shared-memory access, acquire/release publication and
the intentional unmapped doorbell fault; Rust holds no shared-memory pointers.

The future mapping contract adds a disjoint RW/NX stack at
`0x10010000..<0x10014000`. Linker assertions reject writable data, BSS, TLS,
constructors and dynamic indirection. A bounded independent ELF parser checks
the actual image; LLVM separately extracts the same raw bytes. Neither parser
is linked into the application or used as a runtime loader.

Pinned compiler: Rust 1.98.0, host `aarch64-apple-darwin`, target
`aarch64-unknown-none-softfloat`, stored under
`/Users/ergentics/Developer/ErgenticsToolchains/rust-1.98.0-guest-bootstrap`.
No Cargo packages or build scripts are required. Builds use an explicit
replacement environment; this does not claim network confinement or attestation.

The offline `build.rb` helper accepts one existing empty self-owned 0700 result
directory. It preserves separate A/B sources, compiler/analyzer streams and
outputs. It never invokes a resulting ELF/raw image. This development helper
is not an authority-bearing supervisor or grant API.

Retained result:
`Control/rust-guest-bootstrap-2026-08-30.YtXTfY/README.md`.
The two builds match at 164 bytes; the new doorbell is at offset `0x60` and
the exact compiled call graph uses 16 stack bytes. Nine compile-time assertions
and the inspector's 12 synthetic tests passed. No guest has run.

The native host still needs successor-specific mapping/image/trap/receipt
integration and pure tests before a synthetic launch. High-value state remains
outside this bootstrap.

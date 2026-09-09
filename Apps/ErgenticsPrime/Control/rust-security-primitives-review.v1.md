# Rust security primitive: reviewed first candidate

Status: recommendation only, not implemented, compiled, linked or executed.
The names-only GUI measurement is complete independently of this design.

Use Rust for a small **deterministic-CBOR wire validator**, initially test-only,
beside `GuestCBOR.decode` in `Sources/GuestJournal.swift`. Swift retains app/UI
lifecycle, decoding semantics, journal ownership and current evidence checks.
Existing C retains signing, descriptor admission and Hypervisor operations.

The benefit is an independently written malformed-input checker with bounded
safe-slice parsing, differential tests and a reusable C ABI. Swift is already
memory-safe; a rewrite alone is not a demonstrated security or speed improvement.
Moving Darwin syscalls into Rust would not remove unsafe FFI, named-path TOCTOU,
or kernel resource-lifetime obligations. No such move is part of this proposal.

## First contract

- Borrow immutable bytes for one synchronous call; fixed-width status and error
  offset results. No retained pointers, callbacks or allocation ownership crossing
  the C ABI. Swift keeps the Data buffer alive throughout the call.
- Static linkage, ultimately `aarch64-apple-darwin`, macOS 14 minimum. No runtime
  library discovery, filesystem, environment, process, network or journal access.
- Match current wire limits: 1,048,576 bytes, depth 16, 256 collection members,
  8,192 nodes. Definite lengths, minimal arguments, supported CBOR types only,
  valid UTF-8, strictly ordered encoded text keys, and exact end of input.
- Safe Rust inside; a minimal reviewed `unsafe` pointer/length adapter. A non-null
  pointer is not proof of readable memory: validity/lifetime remain caller
  obligations. No panic or foreign exception may unwind across the boundary;
  error returns, panic policy and allocation-failure behavior must be explicit
  before linking. `panic=abort` would kill the app, so it is not ordinary rejection.
- Begin outside the production app target with existing CBOR fixtures, every
  truncation, size/depth/node limits, integer overflow, invalid UTF-8, nonminimal
  encodings and malformed map order. Add C-ABI tests before app integration.

The C ABI and unsafe/unwinding obligations follow the
[Rust FFI reference](https://doc.rust-lang.org/nomicon/ffi.html).

## Semantic boundary that must remain explicit

Swift dictionary keys reject Unicode strings that compare canonically equal.
Rust string equality is bytewise. Therefore a raw Rust wire check is **not full
equivalence to `GuestCBOR.decode`**. Preserve Swift's extra semantic rejection;
include composed/decomposed key aliases in differential tests. Do not broaden
the journal's accepted language or add a normalization dependency silently.
The existing encoder/decoder and Merkle implementation remain references.

## Setup status

`rustc` and `cargo` were not found on the current tool shell's PATH. No Rust
compiler was found at the checked conventional locations:
`/Users/ergentics/.cargo/bin/rustc`, `/Users/ergentics/.rustup/toolchains`,
`/opt/homebrew/bin/rustc`, or `/usr/local/bin/rustc`.
This is not an exhaustive machine-wide inventory. No installer, package-manager
change or toolchain download was attempted. Locate/admit a toolchain before the
first Rust build; this does not block the existing Swift app.

Independent review converged on this one parser boundary, not descriptor or
Hypervisor migration. No new authority, Gate E progress, energy claim, Git backend,
or guest execution follows from this recommendation.

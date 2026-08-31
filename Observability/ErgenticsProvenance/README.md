# Ergentics Provenance

The native Hypervisor development lab and read-only historical receipt viewer. Bundle identifier:
`com.ergentics.provenance`. This is a separate native Xcode project, on the
existing branch. The original project, binary, sandbox container and twelve
historical PASS artifacts remain unchanged.

## Open and sign

Open `ErgenticsProvenance.xcodeproj`, select the `ErgenticsProvenance` target,
then inspect Signing & Capabilities. The project selects Ergentics, LLC,
Team `ZCQ435U8JP`, from the actual public Apple Development certificate visible
with host access. The restricted identity query returned zero; the host query
returned one valid identity. No private key was exported. Bundle registration
is not inferred from the certificate. The project requests Apple Development
signing and Hardened Runtime.

The app admits its exact bundle identifier, configured nonempty Team ID,
Apple-anchored signature, and effective entitlement allowlist before enabling
file selection. It has no ad-hoc fallback. The scheme runs without a debugger;
`get-task-allow` and Xcode base-entitlement injection are disabled. Release
distribution, Developer ID signing, notarization and archiving are separate
steps, not performed or claimed by this source slice.

App Sandbox, user-selected **read-only** file access, and Hypervisor capability
access are requested. There are no network, app-group, iCloud, broad-file-access,
Virtualization-framework or PCC entitlements. Signing does not substitute for backup or
scientific authority. No credentials belong in source or chat.

## Normal launch does not enter a guest

Startup inspects the viewer's own signing identity, native `kern.hv_support`,
and (only after exact effective-entitlement admission) the two Hypervisor
maximum-vCPU/maximum-IPA capability getters. It does not find, import, create or
recompute a historical run. It verifies the app's own lab journal if one exists;
SQLite may maintain its own WAL metadata, but no run event is appended. A new
lab journal is created only for an explicit run. macOS/SwiftUI can create container and
framework metadata; this is not a claim of literally zero operating-system
writes.

Use **Open retained receipts…** to explicitly select the existing directory:

`/Users/ergentics/Library/Containers/com.ergentics.PrivateCompute/Data/Library/Application Support/ErgenticsPrivateCompute/native-static-177403f-r1`

The path above is documentation, not a runtime fallback. The sandbox grant
comes from the user's selection. Nothing is copied, moved, rewritten,
chmodded, repaired or deleted. No bookmark or selection is persisted.

The native C reader holds the root and all twelve regular-file descriptors,
checks the exact inventory, caps each file at 64 KiB, requires self-owned
0700/0600 root/files and single-link files, rejects symlinks at the admitted
root/leaves, and joins device/inode/metadata/names before and after capture.
The Swift verifier binds terminal SHA-256
`1a4c92297c28f9e686bbe9930b54453d909a2102e3cde1d95dee9f1556e24568`,
then checks all eleven manifest entries, retained graph byte equality and
historical identity/timebase joins.

The result means **historical STATIC PASS / current receipt-byte integrity**.
It does not rerun JSON/CBOR projectors, reconstruct the Merkle tree, create a
new PASS receipt, or admit today's Prime source tree. No original compute or
receipt-writer code is linked. Gate E remains `ABSTAIN`; vector `00000000`.
Energy remains unmeasured in ergs; historical rational timing is not current
CPU time, energy or viewer duration.

Snapshot checks are observations, not a filesystem transaction or continuous
watch. Ancestors are not held; transient restoration between checks and later
changes are not excluded. Read-only reads can update filesystem access-time
bookkeeping. The screen displays the captured bytes, not a live-root lease.

## Run the fixed Hypervisor guest

At the user's direction, the app links **Hypervisor.framework**, not
Virtualization.framework. Its separate capability entry calls
`sysctlbyname("kern.hv_support", ..., NULL, 0)`,
`hv_vm_get_max_vcpu_count`, and `hv_vm_config_get_max_ipa_size`. The Hypervisor
entitlement is admitted before the latter two calls, even though they are
read-only getters. Raw return codes are retained in memory; output values are
shown only on success. IPA is address width, not RAM allocated or available;
the vCPU count is a supported limit, not created CPUs or a performance score.

Select **Hypervisor lab → Run fixed guest** in the signed app. This creates one
VM and one vCPU on a dedicated OS thread, enters once, and tears both down.
The bundled 92-byte AArch64 image is reviewed in `Guest/doorbell.S`; its exact
bytes are embedded in the signed host, not loaded from a pathname. It reads
`[sequence=1, ABI=1, 19, 23]` and publishes `[1, 1, 42, status=0]` into separate
32-byte mailboxes. Acquire/release sequences and a fixed MMIO store form the
boundary. There is no OS, IPSW, virtual disk, network device, host mount,
SwiftPM, shell, guest command parser or external dependency.

The native owner validates the exact trap, PC/IPA/registers and every byte of
three 16-KiB slots. It computes a domain-separated Merkle snapshot **before
teardown**. Swift independently reconstructs that root from the copied bytes
after native return. A private watchdog requests vCPU exit after two seconds;
kernel return latency is not finitely guaranteed. User cancellation uses the
same protected, at-most-once exit request. No process signal is used. Failed
resource conservation blocks another run in this app process and retains
mapped backing memory. Quit while a run is active requests cancellation and
waits for the owner; cancellation acceptance is not teardown proof.

Normal repeated development runs receive fresh UUIDs and retain their results.
Debug builds also accept exactly `--run-fixed-guest-once` to invoke the same
operation once on launch; no additional arguments or input loader are admitted.
Release builds have no automatic-run flag. App Sandbox, this local virtual CPU,
and Apple's Private Cloud Compute service remain different boundaries.

## Durable host journal and independent reconstruction

The app stores its own runs at the sandbox's Application Support path:
`ErgenticsProvenance/HypervisorLab/guest-events.sqlite3`. This is not a temporary
directory, and the lab never reads or alters the original app's evidence.
Each run has exactly `start → observation → terminal` events on success;
interrupted prefixes remain incomplete. The start is committed and read back
before guest entry. Raw Hypervisor return codes, entry counts, full mailboxes,
image bytes, rational hardware ticks and snapshot root are retained.

Every event's deterministic CBOR envelope contains its identity and preceding
event digest. Its own SHA-256 is stored outside the envelope. SQLite atomically
stores those bytes and their indexed projection using WAL, FULL synchronous,
fullfsync and bounded busy waits. Reopening verifies schema, canonical CBOR,
digest/ancestry and the execution predicates—not just a terminal's PASS text.
The native and Swift Merkle implementations are separate; SQLite and CBOR are
**not two independent execution witnesses**. A Merkle index/graph can later be
rebuilt from this journal without becoming another mutable source of truth.

The pre-teardown Merkle seal is initially volatile. Durability begins only at
the host journal transaction. Persistence failure does not reinterpret native
execution: a retained prefix stays incomplete, full recovery CBOR stays in
the open window, and further runs are blocked for that process. The journal
holds and rejoins its parent/file descriptors, rejects symlinks, and checks
private modes; SQLite's VFS still opens named paths. Transient replacement,
same-user tampering, rollback of a whole valid journal and power-loss behavior
beyond the filesystem's sync contract are not excluded. Back up SQLite using
a consistent SQLite backup/checkpoint workflow, not a lone database-file copy
while a WAL is active. This is local durable storage, not off-device archival.

This first guest is the transport test environment for future **ΔPU / Delta
Processing Unit** work. Its arithmetic is not a speed benchmark, incremental
state engine, GPU replacement or scientific candidate-selection result.
Energy remains unmeasured in ergs. Gate E stays `ABSTAIN`, vector `00000000`.

Apple references:

- [Hypervisor framework](https://developer.apple.com/documentation/hypervisor)
- [Hypervisor entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.hypervisor)
- [Virtualization entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.virtualization)
- [macOS VM configuration](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon)
- [Read-only directory shares](https://developer.apple.com/documentation/virtualization/vzshareddirectory)
- [Small Business / separately granted PCC access](https://developer.apple.com/app-store/small-business-program/)

The broader requested Merkle-root inception is specified separately in
`Control/hypervisor-genesis-design.v1.md`: typed/domain-separated commitments,
historical-parent references, explicit transition predicates and independent
round trips. This lab implements only the fixed four-leaf guest snapshot and
three-event host chain; it does not close the broader scientific design.

## Optional local repository

The **Select local checkout reference…** control retains only a path label in
memory. It does not enumerate or hash files, call Git, fetch/push, resolve
packages, admit a source identity or mount anything into a VM.

A local candidate was found read-only at:
`/Users/ergentics/Documents/Codex/2026-07-26/you-re-in-a-clean-recoverable/work/ergentics-prime`

It was not selected for you. Its observed HEAD was
`2e065cd1eeabdd09e1f20fe5627b2ee3591a5858`; that observation is not a fresh
tracked/untracked content admission. A future integration needs an explicit
snapshot/commit/tree/content join. Guest read-only sharing would prevent guest
writes, not host-side mutation.

## Verification scope

The native project has no external packages or build scripts. Its hostless
tests exercise the hash/manifest/clock, guest contract, Merkle and semantic
verifiers using synthetic inputs, plus the journal on private test directories.
They do not open the original receipt directory, start the
application or run a VM. In particular they are not a positive production
signature or full native descriptor-reader proof. Unsigned build-only
verification must be reported as unsigned, never as developer-signing PASS.

All new files live under `Observability/ErgenticsProvenance`; no Prime source
identity reseal, production Driver V2 edit, old process observation/actuation,
or change to unrelated drafts is part of this slice.

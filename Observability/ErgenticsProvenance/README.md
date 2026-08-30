# Ergentics Provenance

The read-only successor to Ergentics Private Compute. Bundle identifier:
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

## First launch is read-only

Startup inspects the viewer's own signing identity, native `kern.hv_support`,
and (only after exact effective-entitlement admission) the two Hypervisor
maximum-vCPU/maximum-IPA capability getters. It does not find, import, create or
recompute a historical run. An empty new sandbox container stays empty of
application evidence. macOS/SwiftUI can still create ordinary container and
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

## Hypervisor first

At the user's direction, the app links **Hypervisor.framework**, not
Virtualization.framework. Its fixed native entry calls only
`sysctlbyname("kern.hv_support", ..., NULL, 0)`,
`hv_vm_get_max_vcpu_count`, and `hv_vm_config_get_max_ipa_size`. The Hypervisor
entitlement is admitted before the latter two calls, even though they are
read-only getters. Raw return codes are retained in memory; output values are
shown only on success. IPA is address width, not RAM allocated or available;
the vCPU count is a supported limit, not created CPUs or a performance score.

No VM/configuration instance, memory map, vCPU, disk attachment, installer,
auxiliary storage, network adapter, directory share, socket or guest process
is created. The UI shows **capability queries only / VM not created**. There
is no guest loop to enter containment. App Sandbox, a local VM, and Apple's
Private Cloud Compute service remain separate boundaries.

For a later macOS guest, first identify an existing compatible disk with its
matching auxiliary storage, hardware model and machine identifier—or a
separately admitted local restore image for installation. Preserve that set
as one guest identity. Do not call the latest-image downloader in an offline
workflow. A full macOS guest needs a later reviewed boot/device/lifecycle layer;
Hypervisor alone does not supply Virtualization.framework's macOS installer.
Account-level entitlements alone are not runtime proof.

The intended later guest is offline with disjoint retained writable storage,
no writable host sharing, no implicit network/clipboard/socket bridge and
explicit resource/lifecycle bounds. Guest boot and execution require a
reviewed configuration, not merely a supported host. VM execution cannot
inherit the old host's mapped-image, vnode or process-generation proofs.

Apple references:

- [Hypervisor framework](https://developer.apple.com/documentation/hypervisor)
- [Hypervisor entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.hypervisor)
- [Virtualization entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.virtualization)
- [macOS VM configuration](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon)
- [Read-only directory shares](https://developer.apple.com/documentation/virtualization/vzshareddirectory)
- [Small Business / separately granted PCC access](https://developer.apple.com/app-store/small-business-program/)

The requested Merkle-root inception is specified separately in
`Control/hypervisor-genesis-design.v1.md`: typed/domain-separated commitments,
historical-parent references, explicit transition predicates and independent
round trips. It is design-only here; no new genesis root/receipt is claimed.

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
tests exercise only the pure hash/manifest/clock verifier using synthetic
in-memory inputs. They do not open the original receipt directory, start the
application or run a VM. In particular they are not a positive production
signature or full native descriptor-reader proof. Unsigned build-only
verification must be reported as unsigned, never as developer-signing PASS.

All new files live under `Observability/ErgenticsProvenance`; no Prime source
identity reseal, production Driver V2 edit, old process observation/actuation,
or change to unrelated drafts is part of this slice.

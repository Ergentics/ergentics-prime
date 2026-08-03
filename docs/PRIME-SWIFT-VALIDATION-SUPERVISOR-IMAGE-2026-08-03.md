<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation Driver V2 supervisor-image boundary

Date: 2026-08-03

## Disposition

The root package now contains the dedicated
`PrimeValidationWorkflowDriverV2` executable, but the executable is admitted
only as a caller-predeclared, exact-image-bound pre-execution supervisor. It
cannot run a child, stage an artifact, build, list or execute tests, publish
evidence, restore a live capability, or mint a positive Driver V2 receipt.

The frozen `PrimeValidationDriverAuthorityCeilingV2.frozenPlannerV2` remains
byte-for-byte semantically unchanged. In particular, process, build,
inventory, resume, CI, optimizer, neural, scientific, training, and product
authority remain false.

## Live boundary

The transition is deliberately additive and one-shot:

1. the existing admission capability retains the exclusive lease, canonical
   roots, complete Prime source snapshot, `Package.resolved`, static
   toolchain, source watch, and mapped current-process image;
2. the guarded pre-executor transfers those live values to a neutral,
   non-Codable current-image handoff;
3. each old alias becomes `transferred_no_authority`, cannot revalidate or
   transfer again, and no longer retains the descriptors, watch, image, or
   lease;
4. before the bridge consumes the handoff, the executable requires a
   caller-supplied canonical path, SHA-256, and byte count to equal both a
   fresh secure capture and the retained current-image observation; the
   declaration uses the compiled first-party source-identity pin;
5. a package-scoped DriverCore bridge requires that exact precursor
   declaration to match the retained source and image;
6. the bridge maps the descriptor-, path-, and mapped-image-joined metadata
   into a revalidatable live Driver image token; and
7. every before/after checkpoint, including the terminal checkpoint after a
   complete stdout write, must remain equal or the live token becomes
   `poisoned_no_authority` and the process exits nonzero.

The production bridge rejects the root-owned Apple XCTest host accepted by
the internal test seam. A decoded declaration is data only and cannot restore
the handoff or the bound token.

The neutral handoff and claimed-image types remain public only across the
PrimeCore-to-nested-workflow package boundary. They have no public initializer,
codec, restoration, process, staging, or completion surface. Driver role
assignment, the bound token, and its bridge remain package-scoped; widening
the neutral transport does not widen execution authority.

## Executable topology

The executable is a root-package product now so later package-only access to
the already-audited neutral secure-child substrate does not require replacing
the Mach-O image whose identity this boundary proves. The shared workflow
contract and DriverCore sources are compiled into unproducted root-only
modules; the nested workflow package retains its original module names and
test products.

The Driver target closure is intentionally MLX-free:

- `PrimeValidationWorkflowDriverV2` depends on `PrimeCore` and the unproducted
  root contracts and DriverCore modules;
- root DriverCore depends on `PrimeCore` and the unproducted root contracts
  module; and
- neither target names `MLX`, `MLXNN`, `MLXOptimizers`, `MLXLLM`, or another
  package product.

The root manifest still resolves repository-wide MLX dependencies for other
targets. Target isolation and binary linkage therefore must be reported
separately from whole-repository dependency resolution. This boundary does
not claim that the repository has no third-party software or license
obligations.

## Historical manifest accounting

The Driver product and its three root-only targets are a later additive
continuation of the root manifest, not a rewrite of the historical-worker
V21 through V27 checkpoint. The historical `Package.swift` receipt remains
27,650 bytes with SHA-256
`190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d`.
The current Driver manifest is 28,758 bytes with SHA-256
`52a0078a3dd6b5cf68aa75e63c12ea739e2238cdb7c8f5b0380cbbff4cb66fa6`.
Its delta is exactly 1,108 bytes and 32 inserted lines in two regions: the
Driver product declaration and the root contracts, DriverCore, and executable
target declarations. No historical-worker declaration or dependency changes.

The live historical tests retain every frozen V21 through V27 contract value
and canonical identity. Test support admits only the exact current manifest,
removes each exact Driver insertion once, requires the reconstructed bytes to
match the historical receipt, then deterministically reinserts the two regions
and requires byte equality with the current manifest. Because later historical
contracts also pin earlier test-source bytes, the same support reverses only
the exact continuation call-site replacement before checking those older test
identities. Unknown paths, identities, replacement counts, or residual drift
fail closed. This is source-accounting authority only; it grants no Driver
process, build, inventory, staging, completion, decoder, MLX, or training
authority.

## Hosted Xcode selector

The Driver keeps `/Applications/Xcode.app/Contents/Developer` as its fixed
Xcode selector, but resolves that selector before admission because hosted
macOS runners can publish `Xcode.app` as a symlink. The only admitted
canonical targets are the direct selector path and the physical Xcode 26.5 or
26.6 developer directories. The live test fixture uses the same resolution.

This does not relax the generic toolchain boundary. PrimeCore still receives
only the resolved, allowlisted path and opens every held system directory with
`O_NOFOLLOW_ANY`, requires canonical path equality, and reopens and revalidates
the same directory identity. No caller path, environment variable, alias
rewrite, or process-derived toolchain selection is admitted.

## Canary interface

The executable accepts exactly nine fields: run ID, Prime root, companion
root, workspace root, evidence root, lease root, expected Driver path,
expected Driver SHA-256, and expected Driver byte count. It rejects unknown or
duplicate flags, malformed values, relative or noncanonical paths, a
caller-supplied image identity that differs from the securely captured and
retained image, and roots that fail the existing admission checks. The
developer directory, companion commit, and source-identity pin remain fixed
first-party contract values.

These three expected-image fields are an independently supplied precursor
declaration, not a fabricated complete `PrimeValidationRunIntentV2`. A later
full run intent must carry the same exact `driverExecutable` identity before
it may inherit this live boundary; this slice does not claim that full intent
admission exists.

On success it emits one canonical JSON envelope to standard output. The
record binds the declaration identity, source identity, executable path,
executable SHA-256 and byte count, the
`supervisor_image_bound_pre_execution_only` ceiling, the exact remaining
authorities, and `unobserved` execution states. It writes no evidence file.
The stdout bytes are admissible only when the process subsequently exits zero;
write failure or the final live checkpoint forces a nonzero exit.

The rolling two-role actual-package description anchor for this root topology
is 65,306 bytes with SHA-256
`6a4221c36d6e1b013b5e8bd7ad1c7730ebb8847a257305d7c550b14e1543a7e6`.
Earlier package-description anchors remain historical and are not rewritten;
this canary proves matching package capture only, not Driver execution.

## Authority boundary

The bound supervisor closes only `supervisor_executable_image` in addition to
the already-held source closure and watch. Eight authorities remain missing:

1. Prime Git HEAD and clean-tree process observation;
2. companion Git HEAD and clean-tree process observation;
3. Swift version process observation;
4. Swift target-info process observation;
5. SwiftPM build execution;
6. XCTest inventory execution;
7. Swift Testing inventory execution; and
8. artifact staging.

No process observation is produced by this slice. Canonical tracked-tree
manifests, companion descriptor closure, and a gapless source-watch sequence
must be implemented before the first fixed Git or Swift probe. Staging plus
build follows that pre-observation slice; inventories and parser-derived shard
semantics remain later independently audited boundaries.

## Release and security boundaries

The first native decoder execution boundary remains the pinned Logic 10M
conformance profile. It does not authorize 300M, 3B, or 10B execution,
quantization, training, or product release. Before any product release, the
exact dependency closure, license and notice inventory, source provenance,
binary linkage, security review, and unresolved-risk disposition must be
published and reviewed. Copyleft or another third-party license is not an
automatic rejection; an undisclosed or unresolved obligation is.

No verified confidential reporting channel, supported-version policy, or
response owner is currently named. A `SECURITY.md` should be added only when
it can publish those real controls, not as a release-theater placeholder.

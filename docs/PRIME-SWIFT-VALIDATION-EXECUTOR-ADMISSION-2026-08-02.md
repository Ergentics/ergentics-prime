<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation executor admission

Date: 2026-08-02

## Disposition

This slice implements the admission boundary that must precede any new
repository-wide validation spend. It does not run SwiftPM, build tests, list
tests, execute a shard, resume prior work, or publish a validation outcome.

The boundary has two deliberately different parts:

- durable Driver V2 declarations bind exactly what a later live adapter must
  observe, but decoded or caller-constructed bytes cannot regain a live
  capability; and
- a PrimeCore-owned, non-Codable, one-shot prerequisite capability retains
  real descriptors and the exclusive lease while explicitly withholding every
  process-derived or execution-derived authority that is not yet observed.

`unobserved` is not encoded as `false`, and neither state can become `PASS`,
`GROUNDED`, admitted build evidence, inventory evidence, or completion.

## Where Prime helps

Prime is useful here as a typed holder and negative authority boundary. It can
retain exact direct local observations, reject mutations, and dispose an
unsupported execution proposal. It cannot certify its own declared receipt.

There is no generic EnginePropose/Derive/Dispose runtime in this repository.
The existing validation-specific V2 planner remains the typed proposal and
derivation surface. A later Prime critic may be added only as a veto-only,
mutation-producing observer over separately acquired live evidence. Positive
admission must continue to come from held operating-system resources, closed
process roles, raw-output parsers, and receipt validation.

The neural profile `EngineRecommend` path is not reused. Its scale-selection
and `GROUNDED` vocabulary do not grant repository-validation authority.

## Durable admission contract

The additive nested DriverCore contract binds:

- canonical APFS roots, filesystem identity, device/inode, ownership, mode,
  link count, initial modification/status-change times, descriptor joins,
  path joins, no-symlink observations, and path/identity disjointness;
- declarations of held supervisor, Git, Swift, Swift compiler, physical
  `swift-package`, and `Package.resolved` observations with exact content and
  metadata;
- the clean Prime and companion declarations, exact companion commit, source
  snapshot identity, retained source closures, and armed mutation watchers that
  a future live adapter must supply;
- Xcode 26.6 build 17F113, SDK 26.5, Swift 6.3.3 target information, bounded raw
  probe bytes, parsed/raw agreement, and an exact five-entry probe environment;
- the physical `swift-package` image plus the exact `swift-build` and
  `swift-test` symlink targets and role-derived `argv[0]` values;
- exact equality with the merged V2 build and two inventory invocations. Each
  physical declaration selects the held `swift-package` image, derives
  `swift-build` or `swift-test` as `argv[0]`, removes only the leading logical
  `build` or `test` argument, binds the admitted Prime repository as cwd, and
  binds an exact sorted 19-entry replacement environment. That environment is
  a duplicate-equality merge of a 13-entry deterministic execution base and
  the 13-entry intent overlay; seven shared keys must have byte-identical
  values and inherited or extra variables are rejected;
- the already-merged `temporary` and `output` root names plus exact phase
  budgets; and
- a canonical hash chain over policy, toolchain, supervisor, repository,
  staging, and launch plan.

The required metallib remains an intent-bound planned relative path and hash.
No metallib file can exist in the initially empty admission workspace; the
actual generated file must be held and authenticated by later build evidence.

Shard launch is intentionally excluded. The serializable receipt records all
process, build, inventory, and shard-completion observations as `unobserved`.
Its non-Codable prepared type has no public constructor, exposes no execution
method, and rejects restoration from durable bytes.

## Live PrimeCore prerequisite

The PrimeCore capability performs no `Process`, spawn, fork, exec, shell, or
Python operation. It holds and revalidates:

- canonical, descriptor-backed Prime, companion, workspace, evidence, and
  lease roots;
- private empty workspace and evidence roots, plus a lease directory that is
  private and empty before acquisition and then contains the held lock file;
- one exclusive nonblocking workflow lease;
- the complete Prime source snapshot and exact `Package.resolved` binding;
- Xcode and SDK directories, `version.plist`, `SDKSettings.plist`, and their
  parsed static identities;
- the direct 23,293,616-byte Xcode `swift-package` executable; and
- the exact `swift-build -> swift-package` and
  `swift-test -> swift-package` personalities.

Consumption is one-shot and revalidates all held inputs before transferring
the still-live prerequisite state. Sequential or concurrent reuse is rejected.
The returned token is non-Codable, has no public initializer, retains the
lease and descriptors, exposes no command surface, and cannot mint a Driver V2
receipt.

It explicitly reports these remaining authorities as missing:

1. descriptor-backed source closure and mutation guard;
2. source watch window;
3. supervisor executable image;
4. Prime Git HEAD and clean-tree process observation;
5. companion Git HEAD and clean-tree process observation;
6. Swift version process observation;
7. Swift target-info process observation;
8. SwiftPM build execution;
9. XCTest inventory execution;
10. Swift Testing inventory execution; and
11. artifact staging.

The absent prepared-executor bridge is represented separately by the
`retained_inputs_only_no_prepared_executor` authority ceiling; it is not a
twelfth observation or a substitute for one of the eleven missing authorities.

Caller-declared companion HEAD and empty porcelain bytes are checked for
internal consistency only. They remain declarations, not Git observations.

## Guarded source follow-on

The 2026-08-03 follow-on can atomically consume the live prerequisite into a
non-Codable `source_guards_prepared_only` capability. It closes exactly two of
the eleven missing authorities:

1. the complete Prime source snapshot is held by file and directory
   descriptors and revalidated against its admitted bytes and metadata; and
2. a kqueue vnode watch is armed before the transition completes and can be
   checked repeatedly while no child has started.

The guard reuses Prime's maintained source-closure implementation behind a
domain-neutral wrapper; it does not copy or fork the security mechanics. A
failed transition cannot be retried. A failed later checkpoint permanently
changes the live state to `poisoned`, restores the complete missing-authority
set, and reports the `poisoned_no_authority` ceiling.

The current holder process's mapped main image is also retained by descriptor,
joined to the loaded vnode, read exactly, and revalidated by named-path and
held-descriptor bytes. This is prerequisite evidence only. It is deliberately
named `currentProcessExecutable`, and it does **not** close supervisor-image
authority: no dedicated Driver V2 executable or non-restorable DriverCore
bridge yet proves equality with `PrimeValidationRunIntentV2.driverExecutable`.
The root-owned Apple `xctest` image is accepted only through an internal test
seam and cannot be admitted by the production capture path.

The guarded capability therefore still reports nine missing authorities:
supervisor image, both Git observations, both Swift observations, build,
both inventories, and artifact staging. Process, build, inventory, staging,
shard-completion, and completion observations remain `unobserved` or
unauthorized. No durable receipt can restore the live guard.

## Evaluation boundary

The nested DriverCore admission suite covers canonical encoding and decode,
failed capability restoration, canonical aliases, duplicate root identities,
filesystem identity and timestamp mutations, raw/parsed toolchain disagreement,
environment drift, admission-chain and intent substitution, `false` versus
`unobserved`, physical SwiftPM argument transformation, budget drift, and held
file metadata mutation.

The separate live prerequisite evaluation uses the current M5/Xcode
installation and remains outside the frozen root test inventory. Its synthetic
source arm checks the actual Xcode/SDK/static SwiftPM observations, one-shot
and lease behavior, and rejects aliases, overlap, symlinks, non-private or
nonempty roots, and post-admission input mutation. A separate Release-only arm
exercises the public embedded-source authority against the actual Prime tree
when a companion root and internally consistent pinned-commit declaration are
supplied. Git observation remains explicitly missing.

The guarded-source arm additionally covers atomic sequential and concurrent
transition, empty-root enforcement before the transition, repeatable prepared
checkpoints, post-guard source mutation poisoning, dynamic restoration of all
missing authorities after poison, exact held current-image revalidation, and
the absence of Codable, generic argv/environment, staging, `Process`, spawn,
shell, or Python surfaces. The public Release arm also prepares and revalidates
the Prime source guard against the actual embedded source identity; its Apple
test-host image remains explicitly non-authoritative.

These focused checks do not constitute a current 892/12 or 904-test execution
receipt. No repository-wide suite is counted as passing in this slice.

## Next boundary

The next security-sensitive slice is not build execution. It must first:

1. add a dedicated closed Swift Driver V2 supervisor executable and a
   non-restorable DriverCore bridge that proves the retained mapped image's
   exact path and content equal the run intent's `driverExecutable`;
2. complete the internal secure-child supervision substrate around the now-
   neutral physical spawn path, logical `argv[0]`, and pipe transport, while
   exposing no public generic command surface; and
3. extend the source watcher from its current single-child transition to a
   gapless build-plus-two-list sequence.

The transport defect is now closed by a Release fixture canary: the factory
spawns a descriptor-pinned physical image with the exact logical
`swift-build` value in `argv[0]`, while suspended cwd and mapped-image proof,
bounded EOF drains, exact PID reap, and empty process-group checks continue to
bind the physical executable. The spawn and pipe mechanics now live in the
internal `PrimeSecureChildDarwinSubstrate` and both closed callers use it.
That is only a transport layer: cwd/mapped-image evidence, lifecycle,
containment/reap, EOF drains, and a pre-spawn absolute deadline must still be
neutralized before a Driver V2 supervisor can depend on it. The existing
`PrimeNativeGitBlobTransport` is not a fallback: it uses Foundation `Process`
and does not prove suspended cwd, mapped image, exact PID reap, or empty
process group.

After that substrate passes an independent audit, the remaining authorities
must close in these groups:

1. Prime and companion Git HEAD/clean plus Swift version/target-info fixed
   probes;
2. descriptor-relative staging together with build execution and exact
   generated metallib/test-bundle binding; and
3. the two list roles together with exact parsing and the frozen 892 XCTest / 12
   Swift Testing byte, hash, and count anchors.

Before any positive repository receipt, the currently declarative
`repositoryTrackedTreeSHA256` and `companionTrackedTreeSHA256` fields must be
defined as canonical tracked-tree manifests and bound to descriptor-held bytes;
well-formed arbitrary digests are not evidence.

The build/inventory executor must revalidate source, lock, companion,
toolchain, executable, workspace, and every phase-available staged artifact
before each spawn and after reap. It must bind the suspended child's
working-directory vnode and mapped main image, enforce bounded output and
deadline escalation, reap the exact PID, and prove the process group empty.
Shard execution and the 904-test spend remain later boundaries.

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

These focused checks do not constitute a current 891/12 or 903-test execution
receipt. No repository-wide suite is counted as passing in this slice.

## Next boundary

The next slice may add fixed admission probes plus three closed SwiftPM roles;
it may not add a shard role:

1. retain a descriptor-backed Prime source closure, arm its watch window, and
   admit the exact supervisor executable image;
2. run fixed Git HEAD/clean-tree and Swift version/target-info probes through
   the shared suspended-spawn, bounded-drain, exact-wait, and
   empty-process-group mechanics;
3. consume the still-live PrimeCore prerequisite, while workspace and evidence
   are still empty, through an internal bridge that cannot be rebuilt from a
   durable receipt;
4. create descriptor-relative private staging;
5. execute the admitted physical `swift-package` image only through the
   `swift-build` role, then bind the generated metallib and test bundle into
   exact build evidence;
6. execute only the XCTest-list and Swift-Testing-list roles; and
7. admit parser-derived inventory only when the frozen 891 XCTest and 12 Swift
   Testing list byte/hash anchors match exactly.

The build/inventory executor must revalidate source, lock, companion,
toolchain, executable, workspace, and every phase-available staged artifact
before each spawn and after reap. It must bind the suspended child's
working-directory vnode and mapped main image, enforce bounded output and
deadline escalation, reap the exact PID, and prove the process group empty.
Shard execution and the 903-test spend remain later boundaries.

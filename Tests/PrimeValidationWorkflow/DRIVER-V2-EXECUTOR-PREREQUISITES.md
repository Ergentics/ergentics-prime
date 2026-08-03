<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Validation Driver V2 executor prerequisites

Date: 2026-08-02

The V2 package now implements contracts, deterministic planning, internal
reconciliation kernels, an admission-only durable declaration, and a
PrimeCore-owned live prerequisite capability. It does not authorize process
execution, durable resume, or complete arm/final receipts. Public completion
remains fail-closed until an executor supplies all of the following.

A later non-executing guard transition now holds the complete Prime source
snapshot by descriptor and arms a repeatable prepared-state vnode watch. It
also retains the current holder process's mapped image as non-authoritative
prerequisite evidence. The supervisor image remains missing until a dedicated
Driver V2 executable and non-restorable DriverCore bridge bind that image to
the run intent. Poisoned guards dynamically restore the complete missing set.

- Time and concurrency authority: monotonic active and wall-clock accounting,
  deadline escalation receipts, and enforced per-arm/global concurrency caps.
- Staging TOCTOU controls: descriptor-relative no-follow traversal, identity
  checks before and after use, private creation modes, atomic publication, and
  durable file and directory synchronization.
- Per-arm isolation: distinct scratch, cache, configuration, security, home,
  temporary, output, and evidence trees with no shared mutable build state.
- Companion admission: the exact pinned commit, a clean tracked and untracked
  tree, descriptor-bound package content before each invocation, and the
  generated metallib after build and before inventory or shard roles.
- Toolchain admission: the resolved Xcode build, SDK path/version, target
  triple, Swift executable content, and linker/runtime configuration—not only
  an ambient `swift` path.
- Semantic evidence: maintained framework parsers must derive exact per-test
  terminals from the bound xUnit/transcript bytes. Caller-supplied semantic
  arrays are not completion authority.

The admission-only slice now binds canonical roots, source and lock identity,
an exclusive retained lease, static Xcode/SDK inputs, the physical
`swift-package` image, its exact `swift-build`/`swift-test` personalities, the
frozen root/budget policy, and three logical-to-physical pre-shard launch
declarations. Each launch binds the physical image, `argv[0]`, arguments,
exact 19-entry replacement environment, and repository-root cwd path. The
durable receipt contains staging declarations but no live staging capability;
the live prerequisite still withholds Git/tool process observations, artifact
staging, and all build/inventory/execution outcomes. A decoded declaration
cannot restore the live capability.

The next implementation prerequisite is a closed internal secure-child
substrate with independent physical spawn path and logical `argv[0]`, plus a
gapless multi-child source-watch sequence. The current maintained
external-child factory and Foundation `Process` Git transport are not execution
authority for the build/list plan.

These are implementation prerequisites, not claims that the current schema
already observes or enforces the remaining operating-system behavior. The
repository-level dispositions and evidence are recorded in
`docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-FOUNDATION-2026-08-02.md` and
`docs/PRIME-SWIFT-VALIDATION-EXECUTOR-ADMISSION-2026-08-02.md`.

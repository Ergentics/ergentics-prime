# Prime native neural-gate fixture replay plan

Date: 2026-07-30

Status: secure capture and live descriptor-inventory substrates implemented;
capture is lifecycle-tested and confirmed by a resealed live Release two-role
canary after two contained discovery failures; Stage-B replay not implemented

## Decision

Stage B is not one replay anymore. It has two separately named Swift arms:

1. an exact source-pinned reconstruction of the historical synthetic fixture
   for forensic gate-mechanics evidence; and
2. a corrected Prime-owned prompt-only fixed-cap/EOS fixture that can test
   target-independent synthetic gate mechanics.

The historical arm may pass its forensic mechanics. It cannot ground
target-independent semantics and cannot independently complete Stage B.
A terminal Stage-B pass requires both arms to replay exactly under distinct
Release probe and verifier supervisors. The trap-bearing historical arm also
requires a distinct fresh worker process under each supervisor.

This plan freezes that boundary in
`PrimeNativeNeuralGateFixtureReplayPlan.frozenV3`, schema 3, at
`neural-gate-replay/plan.v3.json`. It deliberately does not
publish another projection receipt. The closed PrimeCore external-child
capture substrate, held local-APFS source guard, fresh per-role scratch
namespace, schema-4 capture envelopes, and typed rejection lifecycle are
unit-tested. Two initial Release two-role canary attempts failed only after
each child and drain remained contained and the child was reaped. The first
exposed terminal mapped-region zero-byte/`EINVAL` behavior; the second exposed
the exact optional `com.apple.TextEncoding` value on regular `work/.lock`.
After those corrections, the resealed live Release two-role canary passed end
to end on the pinned host with byte-identical 21,582-byte probe/verifier
output, SHA-256
`8a352013c632aa39f2d082bb5ae366f061f48e0572c70a5baea813d4560a4c12`.
This later reseal includes the PrimeCore trusted descriptor-inventory source
and tests; it does not widen the canary's authority.
That pass validates only the secure capture substrate. It published no durable
Stage-B process record or receipt, `executionImplemented` remains false, and
no replay, historical worker, model, Metal, or product use is implemented or
authorized.

PrimeCore now also has the prerequisite live filesystem-inventory authority.
It starts only from the already-held `PrimeArtifactRoot` descriptor, admits
either the complete root or a descriptor-relative role prefix, requires one
local-APFS filesystem identity, enumerates every node without following
symbolic links, binds exact owner/type/link/mode/byte-count/SHA-256 facts, and
returns a closed non-`Codable` capability. The public pre-receipt output gate
requires that capability and a fresh unchanged recapture; a decoded inventory
DTO or caller-supplied `captured_from_descriptor` Boolean cannot establish
authority. The frozen Stage-B namespace is printable ASCII; the live capture
rejects non-ASCII or control-byte components rather than relying on Swift
`String` canonical equivalence for path identity. Capture is bounded by
declared paths, depth, node and byte limits, and a monotonic deadline. It
creates no artifact or receipt.

Implementation is intentionally split after those substrates. The next slice
is the pure Stage-B replay-mechanics and typed-content library layer. The
dedicated historical worker follows that layer; the paired probe and verifier
remain one final slice because neither may independently publish a terminal
receipt.

The pre-factory contract-only canonical JSON content SHA-256 was
`149dfea0e90c56f012d1da748cf934a5a398d3829533c2826a480afbdb9ab77d`.
That value is historical. The current V3 plan content SHA-256 is
`4144b211af62149ab8c5155e3ab0737d503898d418a240c63913cb444d178dc2`.

## Why the split is mandatory

The pinned regression fixture at companion revision
`163fc100710ece48119bc25954452d10f6a84f7f` contains a real construction leak:

| Lines | Observed construction | Effect |
| --- | --- | --- |
| 3543–3548 | zero-shot text length uses `target.count` | target length reaches synthetic output construction |
| 3599–3600 | trained prediction copies `row.expectedCompletion` | prediction is synthetic oracle-forged, not model output |
| 3630 | `targetIndependentDecisionBudget` is recorded `true` | declaration conflicts with construction |
| 3631–3632 | decision counts use prediction or target count plus EOS | historical fixture cannot prove target-independent execution |

The historical mutation sweep changes the report declaration and verifies that
the gate rejects the changed report. It does not independently observe how the
baseline fixture constructed its outputs. Therefore `46/46` does not erase
this leak.

The historical receipt remains useful evidence that the old synthetic suite
ran. It is not a golden record-set or residue oracle because it publishes only
`10/10`, `46/46`, `59,497`, `GROUNDED`, and timings—not the records, residues,
per-mutation observations, seed reports, shards, or fixture materials.

## Immutable parent

Stage B accepts only the canonical Stage-A root whose terminal receipt is:

| Binding | Value |
| --- | --- |
| Receipt | `prime-native-neural-gate-contract-projection-receipt.v1.json` |
| Bytes / SHA-256 | 3,193 / `2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed` |
| Prime revision / tree | `a1ff82f092eed2093ab8062ef1bbea66f03cb3a3` / `617c70e258e393cacc88896962f16b684480958a` |
| Source snapshot | `neural-gate-contract/prime-swift-source-snapshot.v1.json` |
| Snapshot bytes / SHA-256 | 3,684,142 / `5c433cf3a84c46c83b250fd6391ab5644252e5979eabc179f59cf1a1be5d0179` |
| Closed source identity | `c2a144054544b9db68a3765ed3068430cb2ccd284e6477cd6ece26220a8a6091` |

`PrimePinnedHistoricalReleaseSource` now has a closed
`nativeNeuralGateContractProjection20260730` case. No public raw digest can
create another historical authority token.

## Eleven source inputs

The probe must resolve the ten Stage-A source bindings plus
`neural-kit/Package.resolved` from the exact companion commit/tree. Total
pinned input size is 1,232,537 bytes. The eleven complete input contracts are
literal in the Stage-B plan; their canonical catalog SHA-256 is
`e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4`.

The tokenizer, corpus, and five runtime-authority sources remain byte-exact
inside a Prime-owned local target named `ErgenticsPrimeRuntime`; that local
target name satisfies the pinned imports without adding the companion package
or a PMHNP runtime dependency. The native gate is also a byte-exact donor copy
inside the replay-mechanics target and receives a separately compiled Prime
observation seam. The generic carrier is limited to an exact declaration
slice. The regression fixture becomes a source-faithful, package-bound
forensic materializer with exact package-lock bytes supplied explicitly
instead of reading through `#filePath`.

The implementation must copy all eleven donor blobs as immutable evidence.
Those blobs may never be dynamically compiled or executed. Only future
checked-in Prime adaptations may compile and execute, and the source-contract
verifier must prove each adaptation against its pinned donor bytes.

That proof is a frozen eleven-entry role-to-source contract, not an assertion
derived from successful behavior. Entries 1–8 and 11 have plan-authoritative
byte-exact outputs. The carrier is a three-range LF-preserving source
derivation with a 2,397-byte expected result
(`4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f`).
The historical fixture uses five exact donor line groups and four ordered,
single-occurrence, hash-bound rewrites; input 11's package-lock digest is a
second derivation input. Its expected result is 88,141 bytes with SHA-256
`e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99`.
The package lock is also copied as immutable evidence. Every executable
adaptation publishes a lexical source-diff manifest and appears in the
compiled authority-target source closure. The future Release supervisors must
independently recompute the proof from plan expectations, while each worker
must bind the same sealed closure. Candidate-declared expectations and
behavior-only equivalence are forbidden. This is source-contract continuity,
not an independent scientific-oracle claim.

The source-faithful historical fixture still inherits eleven donor `try!`
operations plus additional forced-unwrap/precondition sites. It is therefore
not claimed to be wholly fail-closed. A dedicated sealed Swift worker must own
the complete historical arm: fixture materialization, gate replay, invariant
publication, fingerprinting, statistics, mutations, and result publication.
The non-`Codable` fixture never crosses that process boundary. Probe and
verifier must each supervise a separate worker invocation of the same sealed
image.

The trap-bearing worker has a 600-second monotonic wall cap, independent
1,048,576-byte stdout and stderr caps, an empty environment, and stdin at EOF.
Successful stdout and stderr are exactly empty; evidence is written only as
no-replace artifacts. The supervisor owns request and execution records; the
worker owns only its process binding, semantic artifacts, and result. A
successful worker result is transport/inventory evidence and cannot itself
establish mechanics `PASS`; the terminal verifier must decode and recompute
every semantic artifact. Typed cleanup begins with positive direct-PID
authority. Only after `SID == PGID == PID` is observed may termination target
the isolated session's dedicated process group. A resumed child receives
`SIGTERM`, a bounded two-second wait, and at most one `SIGKILL`; missing death
notification permits at most 200 bounded exact-PID `WNOHANG` probes. Reap is
exactly once, and no signal is permitted after reap.

No verifier continuation is allowed until containment and reap are observed.
Descriptor-rooted pre-launch and post-exit role-prefix inventories must have
the exact expected difference. Output overflow, completed read failure, launch
failure, timeout, signal, nonzero exit, nonempty successful output,
PID/image/source mismatch, or missing/extra artifacts sets an internal Stage-B
`ABSTAIN` only after the child and drains are contained and the exact child is
reaped. It poisons the root, accepts no worker result as evidence, and permits
neither a successful execution record nor any terminal receipt. An uncontained
child or drain must fail-stop rather than return into evidence logic. Partial
artifacts or even a result may physically remain if the worker fails after
publication, but they are non-authoritative. A failed root may not be repaired
or retried.
The corrected arm does not inherit the historical trap allowance.

## Frozen target and CLI boundary

The implementation target graph is:

```text
ErgenticsPrimeRuntime (Prime-local; exact pinned sources 2–8)
             └─────────────┐
PrimeNativeCorpusReplayMechanics
             └─────────────┴── PrimeNativeNeuralGateReplayMechanics
                                  └── PrimeNativeNeuralGateReplay
                                      ├── PrimeNativeNeuralGateHistoricalFixtureWorker
                                      ├── PrimeNativeNeuralGateReplayProbe
                                      └── PrimeNativeNeuralGateReplayVerifier
```

The worker's direct dependencies are `PrimeCore`, `ErgenticsPrimeRuntime`,
`PrimeNativeNeuralGateReplayMechanics`, and
`PrimeNativeNeuralGateReplay`; this matches the imports in the derived
trap-bearing fixture instead of relying on transitive module visibility.

The probe accepts only:

```text
--stage-a-root
--companion-root
--prime-root
--artifact-root
```

The verifier accepts only:

```text
--prime-root
--artifact-root
```

The private worker accepts only:

```text
--artifact-root
--invocation-role
--request-sha256
```

The role is exactly `probe` or `verifier`. Package-lock and output paths are
frozen by the plan and are not caller-selectable.

The probe copies the closed donor-source inventory into the output root. The
verifier reconstructs both fixtures from those exact copied inputs before it
reads candidate-derived values. Candidate counts, hashes, residues, mutation
IDs, or verdicts can never become expectations.

Before executing either arm, the future probe must use the completed PrimeCore
factory to capture a complete current clean Prime Swift source snapshot
including every compiled adaptation, supervisor, worker, and secure-child
lifecycle path. Probe and verifier must each directly run the frozen Xcode
26.6 build 17F113 `swift-package` byte image as
`swift-package describe --type json`, not the `/usr/bin/swift` tool shim, as a
bounded no-shell child with stdin at EOF and asynchronously drained bounded
output. The child receives exactly four non-inherited environment keys:

```text
HOME={scratch_root}/home
TMPDIR={scratch_root}/tmp
CLANG_MODULE_CACHE_PATH={scratch_root}/module-cache
SWIFT_MODULECACHE_PATH={scratch_root}/module-cache
```

Its exact argument vector after the executable path is:

```text
--scratch-path {scratch_root}/work
--cache-path {scratch_root}/cache
--config-path {scratch_root}/config
--security-path {scratch_root}/security
--disable-dependency-cache
--manifest-cache none
--disable-prefetching
--disable-automatic-resolution
--disable-netrc
--disable-keychain
describe --type json
```

The vector contains neither `--skip-update` nor `--disable-sandbox`; SwiftPM's
manifest sandbox remains enabled. The repository `.build` tree is not passed
to SwiftPM, is not used by this capture, and has no source or execution
authority. A parseable JSON prefix is never accepted after an output cap is
crossed.

Source admission begins before snapshot construction and has a 30-second cap.
The root must be current-owner local APFS, and the snapshot is limited to
4,096 files, 4,096 directories, 512 MiB aggregate bytes, 8 MiB per file, and
relative depth 32. The factory holds the root, every authoritative directory,
and every admitted source file descriptor. It registers receipt-checked
`EVFILT_VNODE` filters for delete, write, extend, attribute, link, rename, and
revoke events, then requires exact directory inventories, file bytes,
metadata, path/vnode rejoins, and zero pending events at initial, pre-resume,
and post-reap checkpoints.

Each child gets a distinct run root atomically created at mode `0700` below
Darwin's `_CS_DARWIN_USER_TEMP_DIR`. That parent directory is an explicit
trusted prerequisite. The run root contains exactly seven held directories:
`work`, `cache`, `config`, `security`, `home`, `tmp`, and `module-cache`.
Every held descriptor is opened with no symbolic links in its path and
close-on-exec, and every directory must share the source root's exact local
APFS filesystem identity. ACLs and unknown extended attributes are rejected.
`com.apple.provenance` is permitted only as opaque, non-authoritative bytes
bounded to 4,096 bytes. Optional `com.apple.TextEncoding` is permitted only on
the regular file `work/.lock`, with the exact 15-byte value
`utf-8;134217984`; absence is allowed.

Receipt-checked vnode guards detect destructive changes before resume and
after reap. A bounded post-reap audit scans every subtree: at most 65,536 files,
8,192 directories, 1 GiB aggregate bytes, relative depth 32, and two seconds.
`cache`, `config`, and `security` must remain empty, and resolution residues
are rejected anywhere under all seven subtrees. The evidence records
`dependencyResolutionPermitted = false` and
`networkDenialEstablished = false`. These CLI and residue controls do not
establish hermeticity, kernel-level network denial, or isolation from a hostile
same-UID process. Prime closes all held descriptors but never recursively
deletes the path; the namespace is left for the system temporary-directory
lifecycle.

The exact `swift-package` descriptor is opened before spawn as a regular file,
with no symlinks allowed anywhere in the path and `FD_CLOEXEC` observed on the
held descriptor. Spawn applies `POSIX_SPAWN_START_SUSPENDED` (`0x0080`),
`POSIX_SPAWN_CLOEXEC_DEFAULT` (`0x4000`), `POSIX_SPAWN_SETSID` (`0x0400`),
`POSIX_SPAWN_SETSIGDEF` (`0x0004`), and
`POSIX_SPAWN_SETSIGMASK` (`0x0008`): exactly `0x448c`. It does not apply
`POSIX_SPAWN_SETPGROUP`. Positive direct-PID authority is retained until the
suspended child proves `SID == PGID == PID`; only then may termination target
the isolated session's dedicated process group.

The typed evidence sequence is descriptor open, successful suspended spawn,
session/process-group join, child-cwd descriptor/vnode join, complete
mapped-region enumeration, descriptor and held-source revalidation before
resume, successful `SIGCONT`, observed child termination, exact-once PID reap,
empty process group, descriptor revalidation, and held-source revalidation
after reap. Before `SIGCONT`, the supervisor enumerates all regions with
`PROC_PIDREGIONPATHINFO`, advancing only by checked
`pri_address + pri_size`, and requires at least one file-offset-zero mapped
executable region whose vnode equals the held descriptor device/inode. The
record carries every query address, returned struct byte count, returned
region, the checked next address, and a terminal zero-byte/`EINVAL` query.
Apple's XNU `proc_pidregionpathinfo` uses `EINVAL` when no next region exists,
and libproc maps that syscall failure to a zero byte count while retaining the
errno. Every other terminal errno, an empty transcript, and missing,
duplicated, non-progressing, overflowing, or truncated transcripts abstain.
The terminal tuple is accepted only inside the complete lifecycle join below;
it is not independently sufficient evidence because a mapless task can also
produce `EINVAL`. The exact-PID reap carries the requested
PID, returned PID, wait options, raw wait status, derived exit/signal/core
facts, and monotonic return time; clean exit zero is derived rather than
asserted. Successful records also carry zero `posix_spawn`/`SIGCONT` return
codes and prove that the deadline did not expire and neither escalation signal
was delivered. Rejected cleanup before session/group proof sends one
positive-PID `SIGKILL`; after proof it uses the dedicated group. A resumed
child receives `SIGTERM`, a bounded two-second wait, and at most one
`SIGKILL`. Missing death notification permits at most 200 bounded exact-PID
`WNOHANG` probes. Reap is exact once and no post-reap signal is permitted.
An uncontained child or drain must fail-stop. The
pre-spawn, pre-resume, and post-reap descriptor snapshots must agree exactly
on identity, metadata, bytes, and SHA-256. The launch path, `proc_pidpath`
pathname, and locally observed code-sign fields remain telemetry, not identity
authority. No Apple trust claim is made. The capture authority is:
`primecore_trusted_external_child_descriptor_open_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_query_transcript_mapped_vnode_join_pre_resume_stability_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_post_reap_stability_v6`.

The distinct frozen policy identifiers for this capture surface are:

- overall capture policy:
  `direct_swift_package_executable_describe_type_json_exact_noninherited_scratch_environment_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_local_apfs_bounded_source_admission_held_source_closure_kqueue_guard_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_full_region_transcript_descriptor_join_trusted_capture_bounded_output_exact_once_wait_bounded_wnohang_no_post_reap_signal_uncontained_fail_stop_no_shell_v9`;
- mapped-region enumeration policy:
  `proc_pidregionpathinfo_full_query_transcript_address_plus_size_progression_terminal_zero_errno_einval_nonprogress_overflow_other_error_fail_closed_v3`;
- capability-calibration policy:
  `runtime_constants_struct_sizes_same_child_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_transcript_terminal_errno_einval_22_descriptor_join_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_no_escalation_v6`; and
- non-`Codable` trusted-capture capability authority:
  `primecore_non_codable_factory_result_binding_role_exact_launch_arguments_and_environment_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_three_descriptor_read_checkpoints_fstat_source_snapshot_held_source_closure_mutation_guard_direct_pid_to_isolated_session_process_group_authority_working_root_region_transcript_pre_reap_group_members_exact_once_waitpid_and_eof_stream_lifecycle_v8`.

The capture-authority V6 identifier above and the capability-calibration V6
identifier are distinct contracts; neither substitutes for the other.

Decoded record fields cannot validate themselves. Public validation also
requires a non-`Codable` trusted-capture capability that callers cannot
construct. It binds the role, exact arguments and shell-free launch, exact
working directory plus validated-Prime-root result, the exact four-key
non-inherited environment, stdin EOF, deadline/termination policy,
descriptor-read-byte-derived identity, full region transcript, exact wait
result, launch and mapped-image telemetry paths, held-source mutation-guard and
scratch-namespace observations, stream
limits/overflow/EOF/worker-finished outcomes, and separately drained
stdout/stderr bytes. The implemented PrimeCore factory reads and hashes
executable bytes through the same held descriptor represented by its `fstat`
snapshot and descriptor-validates the Prime working root; path-loaded bytes or
a caller Boolean cannot establish live capture authority. The capability is
transient and is not an artifact substitute.

This path uses Apple's version-sensitive libproc ABI, so a native startup
capability calibration is mandatory. A denied query, ABI mismatch, incomplete
or non-progressing enumeration, identity/byte instability, output overflow,
source mutation, or contained lifecycle failure is internal `ABSTAIN`; no
accepted record is emitted. An uncontained child or drain fail-stops. The
capture adapter is implemented and its typed lifecycle has ten focused tests.
After the two contained, reaped discovery failures for terminal
zero-byte/`EINVAL` and exact optional `com.apple.TextEncoding`, the resealed
live Release two-role canary passed on the pinned host with the exact
21,582-byte output binding above. The pass published no durable Stage-B process
record or receipt, `executionImplemented` remains false, and no replay, worker,
model, Metal, or product claim follows. Future probe and verifier records must
bind one byte-identical JSON output and the same direct `swift-package`
mapped-vnode/descriptor/byte identity. That evaluated output must reconcile
the exact selected ten-target authority subgraph,
including target type, path, direct local dependencies, empty product
dependencies, and complete Swift source lists. This is not a claim that the
whole package contains only ten targets.

The historical feasibility correction was measured on the M5 host before the
closed factory was implemented. Suspending `/usr/bin/swift` bound only its
118,928-byte tool shim. Suspending the direct 23,293,616-byte arm64
`swift-package` image produced four mapped regions matching its exact
descriptor device/inode, then exited zero after `SIGCONT` with 20,959 stdout
bytes and empty stderr. The image's full-file SHA-256 is
`dc1a5f5bd4f05be81b8cc4a4bc6e0fd8846210e4cb829062d0fed3d03f79b753`;
the contract also pins regular-file type, owner UID/GID `0`/`0`, mode `0755`,
and link count `1`; live capture additionally requires no-symlink-any open and
`FD_CLOEXEC`.
The historical direct and shim routes produced byte-identical graph output
with SHA-256
`59ceb088e1d5d1d15f7762b5049ccf7b410ff8002e549044cb7a221f537fe939`.
Those 20,959 bytes and that output hash describe only the earlier graph and are
not the current factory expectation. The accepted secure-capture canary
expectation is 21,582 bytes with SHA-256
`8a352013c632aa39f2d082bb5ae366f061f48e0572c70a5baea813d4560a4c12`.
Neither value is a Stage-B replay execution record.

The measured platform was macOS 26.5.2 build 25F84, Darwin 25.5.0
`xnu-12377.121.10~1`, Xcode 26.6 build 17F113, and macOS SDK 26.5 build 25F70.
The local SDK headers are byte-pinned as follows:

| Header | SHA-256 |
|---|---|
| `usr/include/spawn.h` (8,793 bytes) | `2d90f16beec60b2080553613234f004b58f384003feaa5eb809fe5e91b42b884` |
| `usr/include/sys/spawn.h` | `8e73a88c3f63dae77ebf831737942e82ee7c78a7af1446fdbb1ee7ac6804a7e4` |
| `usr/include/sys/proc_info.h` | `e427fa96b348537b21552b9de71e01039410bcad2cedee5584c5e5fddafd70fc` |
| `usr/include/libproc.h` | `246d87709fc6b9157ce5cf3c475656ac48e0e1ae8bbdc46cf45acd34294448cd` |
| `usr/include/sys/fcntl.h` | `805fd8c695f8e5e1c327b6852382cc5533738bbfd8f18bc11f850531166e4fe8` |
| `usr/include/sys/event.h` (17,873 bytes) | `b09a4fdd9e88a5c1c9a29bded36a6f8b96b39a3054f0075a07c19da587f0e062` |
| `usr/include/sys/mount.h` (20,959 bytes) | `45872741bb916b92bddd2e562d2047b552af1f68269081a0aeb58a3e5a2b8a51` |
| `usr/include/dirent.h` (8,703 bytes) | `46d55897015dc859be0181397444b74b22315db8f4ffcdd01c1c3c2a147f196d` |

Primary implementation anchors are the Apple OSS XNU files at source commit
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`:
[`spawn.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/spawn.h)
and
[`kern_exec.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exec.c)
for start-suspended semantics,
[`proc_info.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/proc_info.h)
and
[`proc_info.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/proc_info.c)
for mapped-region vnode observations,
[`libproc.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/wrappers/libproc/libproc.c)
for the public wrapper's zero-return/error preservation, and
[`bsd_vm.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/osfmk/vm/bsd_vm.c)
for the no-next-region and mapless-task cases,
[`fcntl.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/fcntl.h)
for `O_NOFOLLOW_ANY`,
[`event.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/event.h)
and
[`kern_event.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_event.c)
for kqueue/vnode-event mechanics,
[`mount.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/sys/mount.h)
for `statfs` and `MNT_LOCAL`,
[`kern_proc.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_proc.c)
for process/session relationships,
[`kern_sig.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_sig.c)
for signal delivery,
[`kern_exit.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_exit.c)
for wait/reap behavior, and
[`vfs_vnops.c`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/vfs/vfs_vnops.c)
for vnode operations. Apple's
[`dirent.h`](https://github.com/apple-oss-distributions/Libc/blob/main/include/dirent.h)
is an additional source reference for directory enumeration. The same XNU
source snapshot's
[`libproc.h`](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/wrappers/libproc/libproc.h)
labels that interface private and changeable. That published XNU snapshot is a
source reference, and the Libc link is not an installed-header byte identity
claim. Neither is claimed to exactly equal the newer running kernel or SDK.
The pinned local headers, startup capability calibration, contained
`ABSTAIN`, and fail-stop for uncontained state are therefore mandatory.

The probe then descriptor-captures its running Release executable. It also copies
the Stage-A terminal receipt and every descriptor-bound parent artifact,
preserving relative paths, and revalidates that copied parent root. The
verifier receives no live Stage-A or companion path: it must revalidate the
copied parent, copied donor bytes, adaptation proof, and Prime source closure
from the artifact root, capture its own running Release executable, and fully
reconstruct both arms. Probe and verifier process identifiers must be positive
and distinct; their running-image bindings and immutable executable copies are
receipt-bound. The current Prime source state must remain unchanged across
both supervisors and their SwiftPM-capture windows.

The source/image join is frozen as required `Codable` record schemas; no
Stage-B execution process record or receipt has been observed. The
external-child evidence and enclosing role-specific describe-capture records
are schema 4 at
`neural-gate-replay/source/probe-swift-package-describe-capture.v4.json` and
`neural-gate-replay/source/verifier-swift-package-describe-capture.v4.json`.
The enclosing capture and
nested external-child evidence advance together; no durable capture-V1,
capture-V2, or capture-V3 artifact exists.

The aggregate wire contracts are:

- `PrimeNativeNeuralGateAdaptationProofContract.frozenV2`, contract ID
  `prime_source_pinned_neural_gate_adaptation_proof_v2`, at
  `neural-gate-replay/source/adaptation-proof.v2.json`;
- `PrimeNativeNeuralGateSourceExecutionBindingContract.frozenV3`, contract ID
  `prime_stage_b_release_source_executable_join_v3`;
- `PrimeNativeNeuralGateHistoricalWorkerContract.frozenV2`, contract ID
  `prime_stage_b_historical_fixture_worker_v2`;
- `PrimeNativeNeuralGateOutputPathClassificationContract`, contract ID
  `prime_stage_b_output_path_namespace_classification_v3`;
- `PrimeNativeNeuralGateReplayOutputContract.frozenV3`; and
- `PrimeNativeNeuralGateFixtureReplayPlan.frozenV3`, schema 3, plan ID
  `ergentics_prime_native_neural_gate_dual_fixture_replay_v3`, at
  `neural-gate-replay/plan.v3.json`.

The nested held-source mutation-guard observation remains schema 1, while the
scratch-namespace observation is schema 2. The raw evaluated
`swift-package-describe.v1.json`, compiled-source-closure record, Release
process-binding records, historical worker request/process/result/success
records, and terminal receipt remain V1.
The compiled-source-closure schema carries the plan binding, source-snapshot
binding, evaluated SwiftPM JSON binding, `Package.swift` identity, source and
embedded identities, Release configuration, exact selected authority
subgraph, direct dependencies, and complete sorted file identities. The probe
and verifier process schemas carry positive PIDs, exact transitive target
closures, clean pre/post Prime Git state, pre/post snapshot bindings, their
role-specific SwiftPM-capture binding, the compiled-closure binding, source
identities, Release configuration, and the descriptor-captured running
executable binding. Role-specific worker process schemas bind the same source
snapshot/closure and the same sealed worker image; workers do not invent live
Git authority. `Package.swift` and every
`.swift` file in each exact transitive local target directory must appear,
sorted and hash/count-exact, in the current source snapshot and
compiled-target closure. Snapshot source identity, snapshot embedded identity,
each process's compiled
`PrimeEmbeddedBuildProvenance.sourceIdentitySHA256`, and each process binding
must agree; all build configurations must be `release`.
`PrimeSecureRunningExecutableCapture.data` must capture the mapped main-image
vnode from the same positive process that publishes its binding. Probe and
verifier roles, targets, paths, PIDs, and executable hashes must be distinct.
Their SwiftPM child PIDs and the two historical-worker PIDs must also be
distinct, producing a six-process topology. Each worker result must bind its
same-process PID and the same sealed worker image. The verifier must validate
each record before applying the explicit prevalidated-record topology join.
The supervisor and worker records bind descriptor-captured same-process
running images to a shared source identity and declared target closure. The
SwiftPM records separately bind the frozen full-file SHA-256, byte count,
root ownership, `0755` mode, and single link to stable pre-spawn, pre-resume,
and post-reap descriptor snapshots. They also require the typed
held-source counts, aggregate bytes, inventories, watcher receipts, zero-event
checkpoints, start-suspended full mapped-region query transcript and
descriptor-vnode join before `SIGCONT`, direct-PID-to-dedicated-group
authority transition, bounded EOF drains, exact-once reap, no post-reap
signal, and the matching non-`Codable` trusted-capture capability. Target names
remain declared rather than
target-specifically embedded, so this does not prove that a particular binary
was reproducibly built from the named target or claim independently
reproducible-build provenance.

All four roots must be absolute, standardized, non-root, NUL-free, and
unchanged by symlink resolution. The Stage-A and output roots must be distinct
strict descendants of `prime-root/artifacts/`. The companion root must be
disjoint from Prime, Stage A, and output; Stage A and output must also be
disjoint. `.git` traversal is forbidden. The output root must already be an
empty current-user-owned `0700` directory. The probe observes the exact clean
companion revision, tree, and eleven blob identities before and after
execution. Stage A and the companion remain read-only during the run.

The output contract assigns the copied blobs to
`neural-gate-replay/source/blobs/01.blob` through `11.blob`, publishes
role-separated historical global streams plus the corrected global stream,
and uses zero-based eight-digit chunk ordinals.
It additionally fixes the Stage-A copy root and manifest, adaptation-proof and
Prime-source manifests, the evaluated SwiftPM JSON plus role-specific capture
records, separate probe/verifier executable and binding paths, one sealed
historical-worker executable and binding path, and complete role-separated
historical-worker evidence under
`neural-gate-replay/historical/probe/` and
`neural-gate-replay/historical/verifier/`. Every publication is
descriptor-rooted, SHA-256-bound, current-owner/single-link, and exclusive
no-replace. Ordinary data and binding manifests use purpose `immutable_data`
and exact mode `0444`; the captured probe, verifier, and worker images use
purpose `executable` and exact mode `0555`.

The copied Stage-A subroot preserves each original typed binding and purpose
rather than applying a blanket mode. The terminal receipt is separately pinned
immutable data. Traversing it reaches exactly 35 typed descriptor bindings:
28 immutable-data and 7 executable. Copying those records plus the separately
pinned receipt yields 36 artifacts total: 29 immutable-data and 7 executable.
Exact descriptor-binding equality applies to the 35 reachable records. The
parent `README.md` and the two outer probe/verifier CLI-output JSON files are
not descriptor-bound and must not be copied.

A typed path-namespace classifier assigns modes and purposes for every fixed
output, both role-specific historical chunk patterns, the corrected chunk
pattern, authenticated Stage-A descendants, the three exact executable paths,
and the terminal receipt. Namespace classification does not authorize
publication. Before the receipt, a separate exact realized path-and-metadata
inventory validator must reconcile all fixed paths, exactly 36 authenticated
Stage-A copied bindings, and three nonempty contiguous zero-based chunk
inventories against a descriptor-captured all-node sorted list. This
top-level inventory is relative to the artifact-root descriptor and must carry
`root_relative_path: null`; a narrower subtree root cannot establish
artifact-root closure. Missing, extra, forbidden, gapped, wrong-mode,
wrong-purpose, non-regular,
non-single-link, wrong-owner, non-descriptor, symlink, FIFO, socket, device, or
extra-directory entries fail. This validator does not establish the semantic
content of an ordinary fixed artifact; every artifact must separately pass its
typed content validator or source-derived binding before receipt publication.
The three known unbound Stage-A files are rejected even though they sit under
the Stage-A prefix. The terminal receipt is immutable data at `0444`, has a
fixed name, and may be published only after path/metadata validation, typed
content validation, and all other artifacts.

## Invariant-record serialization

The complete invariant multiset uses
`prime_raw_utf8_length_framed_ordered_multiset_v1`:

- records are ordered by raw UTF-8 bytes;
- duplicates remain repeated;
- Unicode normalization and line-delimited text encodings are forbidden;
- the global stream begins with ASCII `PRIMEIRM1`, a UInt64 big-endian total
  count, then repeated UInt64 big-endian byte lengths and raw bytes;
- chunks begin with ASCII `PRIMEIRC1`, UInt32 big-endian ordinal and record
  count, then the same length-framed records;
- chunk ordinals start at zero;
- chunks are the consecutive sorted records, exactly 4,096 records except for
  one nonempty final chunk;
- empty chunks are forbidden;
- every chunk and the ordered global stream have authoritative SHA-256
  bindings; and
- finite-field residues are supplemental integrity evidence, never artifact
  identity.

This encoding makes omission, duplication, reordering, normalization, and byte
mutation independently falsifiable.

## Direct and accelerated fingerprints

The direct path remains the source-pinned three-point raw-UTF-8 Horner fold:

- prime `2,147,483,647`;
- points `257`, `65,537`, and `1,000,003`;
- accumulator seed `1`;
- UInt64 big-endian record-byte-length prefix; and
- `accumulator * point + byte + 1`.

The accelerator is
`immutable_raw_utf8_affine_segment_tree_v1`. Its cache key binds the field
parameters and authoritative ordered-multiset stream SHA-256. Both paths run
for both role-scoped replays and must agree exactly. Historical fingerprints
execute inside the two isolated workers; corrected-arm fingerprints execute
under the Release supervisors. Raw-byte equality is required before cache
reuse, and stale-cache reuse has a mandatory mutation.

Each byte is the affine leaf
`(multiplier: point, addend: byte + 1, byteCount: 1)` over the field. Identity
is `(1, 0, 0)`. For a left segment followed by a right segment, composition is
`(Ml*Mr, Al*Mr+Ar, countL+countR)` modulo the prime; the root is applied to the
seed as `seed*M+A`. The byte order is each UInt64 big-endian record length
followed by its raw UTF-8 bytes, in canonical record order.

The frozen five-record known-answer vector preserves a duplicate and
canonically equivalent but byte-distinct UTF-8 forms. Its global stream is 64
bytes with SHA-256
`56ae18634d740ef5e08f86212ac580510db5211def0834302871ba8a00246294`;
its single chunk is 64 bytes with SHA-256
`be85d2d8dea54573b84d99afbabf9cf8fdca050f1dafed9d498547eb455860a2`;
and both fingerprint paths must produce
`[1809436187, 238577571, 1233137383]`.

## Arm-specific truth

| Claim | Historical forensic arm | Corrected fixed-cap/EOS arm |
| --- | --- | --- |
| Source-pinned fixture mechanics | yes | yes, as a named Prime adaptation |
| Prediction provenance | `synthetic_oracle_forged` | prompt-only deterministic synthetic executor |
| Fixed cap 64, independent of target | no | required |
| EOS available at every decision | only report-declared | required by construction and mutation |
| May pass mechanics replay | yes | yes |
| May ground terminal Stage B alone | no | no; both arms required |
| Must equal unpublished historical residues | no | no; separate namespace |

The corrected arm uses the already frozen
`greedy_native_bytes_eos_fixed_cap64_kv_v2` generation contract. It may not
derive a negative output, output length, grouping key, decision budget, or
termination condition from the target. Its prediction input set is exactly
`row_id`, `seed`, `prompt_text`, `prompt_token_ids`, and
`prompt_grouping_key`. Target, target tokens, expected completion, regrade
fields, and abstention fields are forbidden. The support remains EOS plus all
256 byte tokens, the decision cap is exactly 64, EOS is available at every
decision, and no per-row target-dependent skip, grouping, batching, or
termination is allowed.

The corrected catalog freezes ten ordered defect injections, not a prose
promise:

| Mutation | Injected defect | Expected failed leg |
| --- | --- | --- |
| `target_value_changes_raw_execution` | target value enters prediction construction | `corrected_target_value_independence` |
| `target_length_changes_raw_execution` | target length controls prediction length | `corrected_target_length_independence` |
| `expected_completion_injected_into_prediction` | expected completion enters prediction bytes | `corrected_prediction_input_exclusion` |
| `target_dependent_prompt_grouping` | target byte count enters grouping | `corrected_prompt_grouping` |
| `target_dependent_decision_budget` | target token count replaces cap 64 | `corrected_decision_budget` |
| `eos_unavailable_at_decision` | EOS is removed at one decision | `corrected_eos_availability` |
| `completion_support_narrowed` | full byte support is replaced by ASCII | `corrected_completion_support` |
| `fixed_cap_drift` | cap 64 is replaced by 63 | `corrected_fixed_cap` |
| `target_dependent_termination` | generation stops at target length | `corrected_termination_independence` |
| `target_dependent_row_inclusion` | row inclusion depends on target/prediction length | `corrected_row_inclusion_independence` |

Every historical and corrected mutation must be detected, fail its frozen leg,
diverge in fingerprint, and restore both records and fingerprint exactly.

## Verify/Abstain and verdict scope

Both arms must independently regrade their raw inputs, recompute all ten
projected `NL1`–`NL10` leg outcomes, recompute the source-pinned
target-token-weighted statistics and fixed-prompt runner-up margin, apply the
projected capability thresholds, and derive the count label and all-critical
verdict from those recomputed observations. Candidate-declared aggregates are
never authority.

The label remains
`count_derived_label_not_four_tier_independence_audit`. It does not become an
independent TriadAudit, distinct implementation-family evidence, guarded
statistical entanglement, confidence intervals, or per-family
rank/decision-margin analysis.

The outcome composition is explicit:

- historical mechanics must be `PASS` while historical target independence is
  `ABSTAIN` for the known leak;
- corrected mechanics and corrected target independence must be `PASS`;
- terminal Stage-B mechanics is `PASS` only when both scoped arms satisfy every
  record, fingerprint, gate, mutation, and fresh-process condition; and
- model capability remains `ABSTAIN`.

An invalid contract or unsafe root throws and publishes no terminal receipt. A
complete valid observation that does not satisfy the mechanics gate may publish
only terminal `ABSTAIN`.

## Required execution results

A future terminal Stage-B pass requires:

- closed Stage-A parent validation;
- a lossless copy of the Stage-A terminal receipt and every descriptor-bound
  parent artifact, followed by independent revalidation of the copied root;
- all eleven source inputs resolved and copied;
- all eleven typed donor-to-Prime adaptation proofs recomputed, with the
  compiled target source closure and adapted-output hashes bound;
- independent direct `swift-package describe --type json` captures from probe
  and verifier, with mandatory libproc capability calibration and each
  suspended child PID bound from its initial mapped executable vnode to the
  same preopened no-symlink-any descriptor device/inode/stable-byte identity,
  a complete checked query/terminal transcript, bounded local-APFS held-source
  closure and zero-event mutation guard, direct-PID-to-dedicated-group
  authority transition, bounded exact-PID `WNOHANG`, exact-once clean reap,
  no post-reap signal, fail-stop for uncontained child/drain state, a
  PrimeCore-produced non-`Codable` live-capture capability, overflow-free EOF
  stream drains, and one byte-identical evaluated authority subgraph bound to
  the unchanged source snapshot and `Package.swift`;
- a clean current Prime source snapshot that remains unchanged, plus exact
  running Release executable bindings and a validated six-process topology for
  probe, verifier, their two SwiftPM children, and two historical workers;
- two distinct, bounded historical-worker invocations with typed request,
  same-process result, stream-drain/termination, observed death/reap, exact
  pre/post role-prefix inventory, and successful supervisor execution records;
- terminal verifier decoding and recomputation of every worker semantic
  artifact; worker transport results alone cannot authorize mechanics `PASS`;
- historical forensic reconstruction independently published under probe and
  verifier role prefixes, with role-neutral semantic identities equal;
- complete historical invariant-record publication;
- exact historical direct/accelerated residues;
- all ten historical gate legs, projected statistics/margin, thresholds, and
  count-derived verdict recomputed;
- all 46 historical semantic mutations detected, fingerprint-divergent, and
  record/fingerprint-exact after restoration;
- corrected prompt-only fixed-cap/EOS reconstruction;
- complete corrected invariant-record publication and exact
  direct/accelerated residues;
- all ten corrected gate legs, projected statistics/margin, thresholds, and
  count-derived verdict recomputed;
- all ten corrected construction-level leakage mutations detected,
  fingerprint-divergent, and record/fingerprint-exact after restoration;
- corrected target independence established;
- exact descriptor-rooted pre-receipt realized path-and-metadata inventory with
  no missing, extra, forbidden, gapped, mistyped, wrong-mode, or unsupported
  filesystem nodes, plus separate typed content validation for every artifact;
- each arm and the complete observation repeated exactly in a distinct Release
  verifier; and
- terminal receipt created exclusively and last.

Historical residue parity and historical per-mutation parity remain false
because those old values were never published. Fresh probe/verifier equality
is the authority.

## Claims that remain false

Even after Stage B passes:

- NeuralKit module execution and PMHNP runtime dependency;
- model, MLX training, Metal, physical checkpoint, or physical generation-shard
  execution;
- an independent scientific oracle;
- AgentContractKit four-tier audit or distinct implementation families;
- guarded statistical entanglement, confidence intervals, or per-family
  rank/decision-margin analysis;
- functional training, quantization, or diagonal-Hessian evaluation;
- Phase-3 completion; and
- RecommendationProvider or product authority.

The historical `native300M` value is synthetic report metadata, not a profile
recommendation or a model run. `quant_hessian_lineage` is a rejection mutation,
not a Hessian experiment.

## Checkout mode normalization

Git degraded five tracked immutable Stage-A JSON files from `0444` to `0644`.
Before a canonical Stage-B run, verify the exact current-user ownership,
single-link regular-file type, byte count, and SHA-256 in the frozen plan.
Only then set those five listed files to `0444`.

That exact hash-gated metadata normalization is the only permitted Stage-A
parent change. Never change parent bytes or an unlisted path, never recurse,
never repair a mismatch, and never touch the Prime source, companion, or
`.git` trees.

The local Prime source root has a separate fail-closed metadata prerequisite.
During this implementation the exact `.swiftpm` directory was found at mode
`0777` and explicitly normalized to `0755`; its inode, owner, contents, tracked
Git state, `.swiftpm/configuration` mode `0755`, and
`mirrors.json` mode `0644` were unchanged. The factory does not perform that
repair: it rejects any authoritative source directory or file that is
group/world writable. It neither creates nor mutates the repository `.build`
tree. All SwiftPM work is redirected to the held per-role scratch namespace,
and repository `.build` contents have no authority. The factory never
recursively changes source metadata.

## Next actions

The frozen aggregate implementation prerequisite remains:

`implement_stage_b_role_scoped_historical_worker_probe_verifier_using_completed_primecore_secure_capture_typed_artifact_recomputation_corrected_fixed_cap_eos_fixture_and_exact_path_content_inventory`

Its implementation order is now:

1. pure replay mechanics and typed semantic payloads;
2. the isolated historical worker using the completed secure capture and live
   role-prefix inventory capabilities; and
3. the paired probe/verifier with full-root pre-receipt recapture and
   receipt-last publication.

After a real dual-arm Stage-B pass:

`physical_native_checkpoint_and_evaluation_shard_binding`

That next step begins real-artifact admission. It is not authorized by this
contract-only change.

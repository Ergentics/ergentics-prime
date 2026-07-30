# Prime native contract resolver

Status: resolver implementation and gates in progress; no canonical resolver
receipt claimed

Plan lineage date: 2026-07-29

Companion commit:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

## Decision

Phase 2 is complete for its exact narrow claim. The source-sealed,
random-initialized exact 3B FP32 canary matched the declared collision-free
synthetic step-1 and step-2 states across uninterrupted and
fresh-process-restored Metal trajectories. Its canonical receipt SHA-256 is
`2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e`.
That receipt is repository- and off-device-durable.

The complete approximately 32 GiB descriptor-backed Phase 2 root, including
the model and two Adam moment components plus bound runtime evidence, remains
local-only. The resolver does not consume that checkpoint, so its local-only
status does not block this read-only migration slice. It does block any later
action that requires the complete checkpoint/runtime root until that root is
copied to separately controlled off-device storage.

The next transition is not a model run or a compatibility claim. It is a
resolver-only gate that materializes exactly eight opaque blobs already frozen
in `PrimeNativeArcContinuityPlan.frozenV1`. The historical plan is not
rewritten. `PrimeNativeContractMigrationPlan.frozenV1` adds the exact Git
revision, tree, path, mode, type, object ID, byte-count, and SHA-256 bindings
needed to make the inventory real in Prime.

## Exact admitted inventory

The admitted set is exactly eight blobs and 11,969,097 bytes.

| Artifact | Companion path | Git blob OID | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| `native_byte_tokenizer_manifest` | `content-staging/prime-native-byte-tokenizer-manifest.v1.json` | `c2661016dd5a3af21fd6a998f286184ebdd7a196` | 4,790 | `5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302` |
| `native_compositional_corpus_manifest` | `content-staging/prime-native-text-corpus-manifest.v1.json` | `a01344ad4105d755cfd97324092b15a1b31dc542` | 44,803 | `fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031` |
| `native_10m_metal_mechanics_report` | `content-staging/prime-native-metal-language-canary-report.latest.json` | `e04a264634d5f785e73a4c64b773fd5a4329f896` | 40,833 | `686bc619ca2019e0960a887b35a8e7dc853172b0d24d27cfbba01e5624c7360c` |
| `native_schema4_profile_screen_archive` | `content-staging/prime-native-language-schema4-profile-screen.v1.tar.xz` | `4b3027164c82af0db1feab8db9da95d3f9e8f9bd` | 11,830,112 | `0830920b1e1d57e2fa20731d1caae89899802fec286bbca2e6ee58cbfb5cc903` |
| `native_schema6_profile_screen_audit` | `content-staging/prime-native-language-schema6-profile-screen-audit.v1.json` | `577a7ccbdddbc9c0d249b5fa1ec355c0319d0193` | 38,760 | `4d7e696344770f57779cc72e1c6f58cb5ea6ce1b3ef0f86f1b571a3f10e84612` |
| `native_schema6_truth_projection` | `content-staging/prime-native-language-schema6-profile-screen-truth-projection.v1.json` | `e48445e10e8a39e96a21dcc84bd1d7d92ddfa33c` | 2,090 | `7d1c190659cec310e52e5823b1b752cba31f5a64a43cb25dfd1469d41155378a` |
| `neuralkit_native_language_verify_abstain_receipt` | `content-staging/prime-native-language-schema4-verify-abstain-receipt.v1.json` | `afe0fde09285c1ad928d2e8f77dfd622b32e6b20` | 5,760 | `91c6fd5f26492357cad938dcab1926356bc33914cc281c5ccd2297f1759b0b0a` |
| `neuralkit_package_lock` | `neural-kit/Package.resolved` | `18aef69512c82c3e6cdff192f3aa0a6ee13c702e` | 1,949 | `cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3` |

The companion commit object is separately bound at 1,240 raw bytes with
SHA-256
`c1087083018d8b964e67e9f1d0d93d689805459457cd58c8f0d46d54c81e0abe`.
The 11,830,112-byte profile-screen archive remains an opaque blob in this
slice; it is not expanded or interpreted.

## Authority and transport

Swift is the resolver authority. `/usr/bin/git` is directly executed as a
read-only raw-object transport because Git object resolution is the maintained
mechanism for reading a pinned repository. No shell is launched. No Python is
used.

The in-progress gate binds the exact Git executable observation and uses only
read-only plumbing to:

1. verify the companion remote identity and object format;
2. resolve the exact commit and tree;
3. read the raw commit object;
4. enumerate the exact tree records with NUL-delimited paths;
5. read each admitted blob by its object ID;
6. recheck the revision and tree after all reads.

Swift validates path, regular-file mode, object type, object ID, byte-count,
and SHA-256 before immutable publication. The donor checkout is read-only and
is never an output target. The resolver source snapshot, exact Release
executable, process observations, and materialized blobs are intended to be
receipt-bound, with the canonical receipt published last into a fresh, empty
artifact root whose mode is exactly `0700`.

Prime source state is observed twice. The pre-snapshot observation binds the
accepted remote, `HEAD` commit, `HEAD` tree, and complete porcelain status
including all untracked files. After source-snapshot validation and
running-executable capture, the post-executable observation repeats those
checks. Both states must be clean and must have identical remote, revision, and
tree identities.

The running executable is not captured by trusting a pathname alone. On
macOS, Swift observes the executable vnode loaded in the current process,
opens the resolved regular file with no-follow semantics, and requires the
descriptor's device and inode to match the loaded vnode. Owner, mode, link
count, size, modification time, and change time must remain admissible and
stable across the bounded descriptor read.

Git output is transport evidence, not a scientific verdict. Swift owns every
admission, mutation, publication, and outcome decision.

## Fresh-process persistence verifier

`PrimeNativeContractResolutionVerifier` is a separate Swift-only executable.
It accepts exactly one input: the absolute canonical artifact root. It does
not execute Git, read the donor checkout, launch another process, select an
artifact, or expose revision, tree, scope, model, seed, or execution knobs.

In a fresh process, the verifier rebinds the canonical receipt, validates the
complete persisted descriptor root, rebinds the receipt again, requires the
binding to remain exact, decodes it again, and repeats structural validation.
This is persistence and structural-replay evidence. It explicitly records
`independentScientificOracleClaimed: false`; it is not a disjoint scientific
grader and cannot promote compatibility or behavior.

## Required failure gates

The resolver must fail closed for at least these distinct cases:

- a different commit with an identical tree;
- a different path that names identical blob bytes;
- a missing artifact;
- changed blob bytes;
- a plan mutation that expands compatibility, execution, training,
  quantization, or product authority.

Repository and output roots must also be safely separated. The output root
must be newly empty and exactly mode `0700`; Prime source must remain clean and
identity-stable across its pre-snapshot and post-executable observations; and
the captured executable file must match the loaded vnode and remain unchanged
across the read. These are implementation gates, not evidence that a canonical
run has already occurred.

## Explicit non-claims

This slice does not:

- perform compatibility replay;
- implement a tokenizer, corpus, evaluator, or NeuralKit adapter;
- expand or inspect the profile-screen archive;
- import implementation source into the Prime tensor core;
- execute companion code or NeuralKit;
- execute a model or admit a checkpoint;
- train, calibrate, distill, or quantize;
- change PMHNP product, recommendation, safety, or clinical authority;
- authorize product use.

Materializing an exact blob proves only that the frozen donor object was
resolved and copied under the declared contract. It does not prove that Prime
can interpret the blob or that current implementations remain behaviorally
compatible.

## Exit and next action

This slice exits only after a clean, source-sealed Release execution publishes
a canonical resolver receipt and a separately invoked
`PrimeNativeContractResolutionVerifier` fresh process accepts that receipt and
its complete local descriptor root. The verifier is not an independent
scientific oracle. Until that persistence validation completes, resolver
status remains in progress.

Only after that evidence exists may the next slice implement the narrow
compatibility adapter for the resolved tokenizer, corpus, generation, and
regrade contracts. Adapter work must preserve the existing authority
direction: Prime emits versioned research artifacts and NeuralKit independently
regrades them. It must not make the companion a runtime dependency or write
target.

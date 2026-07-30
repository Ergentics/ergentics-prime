# Prime native neural-gate fixture replay plan

Date: 2026-07-30

Status: execution contract frozen; mechanics not yet implemented

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

This short slice freezes that boundary in
`PrimeNativeNeuralGateFixtureReplayPlan.frozenV1`. It deliberately does not
publish another projection receipt. The next slice must implement the frozen
probe, verifier, dedicated historical worker, independent external-child
mapped-region-vnode SwiftPM capture, fail-closed SwiftPM child lifecycle,
typed worker-artifact recomputation, and exact realized path-and-metadata
inventory gate. Its
canonical JSON content SHA-256 is
`17f19feb26869b77d88964855943c45ff91a65b8892b67e9926d5edb02366dda`.

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
every semantic artifact. Timeout handling is frozen as deadline, `SIGTERM`,
a two-second wait, `SIGKILL`, observed death, and `waitpid` reap. No verifier
continuation is allowed until death and reap are observed. Descriptor-rooted
pre-launch and post-exit role-prefix inventories must have the exact expected
difference. Output overflow, incomplete drain, launch failure, timeout,
signal, nonzero exit, nonempty successful output, PID/image/source mismatch,
or missing/extra artifacts sets an internal Stage-B `ABSTAIN`, poisons the
root, accepts no worker result as evidence, and permits neither a successful
execution record nor any terminal receipt. Partial artifacts or even a result
may physically remain if the worker fails after publication, but they are
non-authoritative. A failed root may not be repaired or retried.
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

Before executing either arm, the future probe must capture a complete current
clean Prime Swift source snapshot including every compiled adaptation,
supervisor, and worker path. Probe and verifier must each directly run
`swift package describe --type json` as a bounded no-shell child with an empty
environment, stdin at EOF, asynchronously drained bounded output, explicit
no-overflow observations, typed clean exit, deadline/`SIGTERM`/two-second
wait/`SIGKILL` escalation, observed death, `waitpid` reap, and unchanged Prime
Git/source state. A parseable JSON prefix is never accepted after an output
cap is crossed. Both absolute executable paths must be standardized before
capture.

The launch-file path/hash declaration and a `proc_pidpath` pathname are
explicitly non-authoritative. Each role-specific record must instead observe
the live external child's mapped-region vnode while the child is running,
then join that observed device/inode identity to a no-symlink descriptor of
the standardized path and to the descriptor-read bytes:
`external_child_mapped_region_vnode_then_descriptor_device_inode_and_bytes_join_v1`.
The trusted native external-child observation mechanism is required before
execution; it is not implemented and has no observed evidence in this
contract-only slice. The two records must bind one byte-identical JSON output
and the same mapped-region vnode/descriptor/byte identity. That evaluated
output must reconcile the exact selected ten-target authority subgraph,
including target type, path, direct local dependencies, empty product
dependencies, and complete Swift source lists. This is not a claim that the
whole package contains only ten targets.

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

The source/image join is frozen as required `Codable` record schemas; no such
Stage-B execution records have been observed in this contract-only slice. The
compiled-source-closure schema carries the plan binding, source-snapshot
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
SwiftPM records separately require standardized-path, external-child
mapped-region-vnode, descriptor device/inode/bytes, no-overflow, clean
termination, observed-death, and reap evidence. Target names remain declared
rather than target-specifically embedded, so this does not prove that a
particular binary was reproducibly built from the named target or claim
independently reproducible-build provenance.

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
- independent direct `swift package describe --type json` captures from probe
  and verifier, with live child PIDs bound through external-child
  mapped-region-vnode observation to the same standardized no-symlink
  descriptor device/inode/bytes identity, overflow-free stream drains, clean
  termination, observed death/reap, and one byte-identical evaluated authority
  subgraph bound to the unchanged source snapshot and `Package.swift`;
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

## Next actions

Immediate implementation prerequisite:

`implement_stage_b_external_child_mapped_region_vnode_capture_swiftpm_fail_closed_lifecycle_historical_worker_typed_artifact_recomputation_corrected_fixed_cap_eos_probe_verifier_and_exact_path_metadata_inventory`

After a real dual-arm Stage-B pass:

`physical_native_checkpoint_and_evaluation_shard_binding`

That next step begins real-artifact admission. It is not authorized by this
contract-only change.

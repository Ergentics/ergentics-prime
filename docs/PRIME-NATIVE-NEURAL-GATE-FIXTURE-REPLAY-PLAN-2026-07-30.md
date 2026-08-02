# Prime native neural-gate fixture replay plan

Date: 2026-07-30; updated 2026-07-31

Status: secure capture, live descriptor-inventory, raw-stream/fingerprint
mechanics, and isolated corrected value/observation mechanics implemented;
capture is lifecycle-tested and has a last accepted Release two-role canary;
the exact corrected fixture identity/count is source-plan-bound by an offline
Swift authority; an isolated prompt-only symbolic solver derivation is
implemented; corrected admission V3, source binding V6, and plan V5 source-bind
the lossless sidecar codec and maintained MLX Float32 operation; durable
Stage-B replay, workers, process records, and receipt are not implemented;
the package-level raw/evaluation split, trap-disjoint topology V4, pure typed
artifact contracts, shared bounded transport codec, descriptor-rooted
invariant/logit source binding, strict incremental prompt schedule, role
projections, and exact four-source replay composition are implemented, while
topology V7 additionally freezes exact-count bounded stream admission and typed
artifact/worker-source reference declarations. Real common/branch scalar
references are supervisor-derived and non-authorizing; every execution target
and every worker-source or role-artifact content reference remains planned or
absent. The exact current boundary is recorded in
`PRIME-NATIVE-NEURAL-GATE-TYPED-ARTIFACT-TRANSPORT-2026-07-31.md` and
`PRIME-NATIVE-NEURAL-GATE-REPLAY-COMPOSITION-2026-07-31.md` and
`PRIME-NATIVE-NEURAL-GATE-DESCRIPTOR-SOURCE-BINDING-2026-07-31.md` and
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

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

The current source plan freezes that boundary in
`PrimeNativeNeuralGateFixtureReplayPlan.frozenV5`, schema 5, with canonical
content SHA-256
`c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b`.
Frozen V4/schema 4 remains the historical pre-sidecar plan and V3/schema 3 the
pre-solver plan. The still-frozen V3 replay-output namespace reserves
`neural-gate-replay/plan.v3.json`, but no V4 or V5 execution artifact or
receipt is claimed. The plan deliberately does not publish another projection
receipt.
The closed PrimeCore external-child
capture substrate, held local-APFS source guard, fresh per-role scratch
namespace, schema-4 capture envelopes, and typed rejection lifecycle are
unit-tested. Two initial Release two-role canary attempts failed only after
each child and drain remained contained and the child was reaped. The first
exposed terminal mapped-region zero-byte/`EINVAL` behavior; the second exposed
the exact optional `com.apple.TextEncoding` value on regular `work/.lock`.
After those corrections, the Release two-role canary was rerun after the
fixture-authority twelve-target source freeze and passed end to end on the
pinned host. That probe/verifier output was byte-identical at 23,207 bytes,
SHA-256
`f2204bbae8623c35fdf7357c6b0aa2a585e9071f22556edbe6ce6e7cfccf04d5`.
That is the preceding twelve-target fixture-authority reseal. It includes the
PrimeCore trusted descriptor-inventory substrate, pure replay mechanics,
corrected value mechanics, and the offline source-attested fixture target and
does not widen the canary's authority.
After the isolated thirteenth prompt-solver target was added, the same Release
canary was rerun on the pinned host and passed with byte-identical
probe/verifier output: 23,791 bytes, SHA-256
`9d56ad223c9d980272583dc752e0ff05bb815ce504cd3c82fc7e186627c02aa7`.
This remains valid historical secure-capture evidence for the complete
thirteen-target package description and source snapshot. The live factory
still used the typed V4 selected-subgraph contract, so it was not a typed V5
source-binding reseal and does not widen canary authority. After the
fifteen-target V6 source graph and isolated MLX validation topology were
frozen, the same Release canary passed with byte-identical probe/verifier
output: 26,090 bytes with SHA-256
`53ace0b68b1f8f2cf6534be886cb93241b08a36e0ddf0e9da7f8eee33f37cb40`.
The later topology audit established that this is an actual-package
secure-capture reseal only. The captured package description was not
reconciled against V6's planned closure, whose future execution targets were
not materialized, so it is not V6 selected-source execution-graph proof.
After the raw/evaluation package split and topology V1 correction, the same
Release canary passed with byte-identical probe/verifier output: 27,015 bytes,
SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`.
This is the last accepted topology-V1 actual-package secure-capture reseal.
It predates topology V2's two new targets and is not current V2 evidence.
After the complete topology-V2 source reseal, the same Release canary passed
with byte-identical probe/verifier output: 28,589 bytes, SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
This is the last accepted topology-V2 actual-package secure-capture reseal. It
predates topology V3 and replay composition; source binding V7 remains
unissued.
After the complete topology-V3 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 29,905 bytes,
SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the last accepted topology-V3 actual-package secure-capture reseal.
It validates only the secure-capture substrate on the pinned host. It is not
V6/V7 selected-source execution-graph proof; it does not issue source binding
V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
After the complete topology-V4 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 32,735 bytes,
SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is the last accepted historical topology-V4 actual-package secure-capture
reseal, with the same secure-capture-only scope.
After the additive topology-V5 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 36,047 bytes,
SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
`executionImplemented` remains false,
and no replay, historical worker, Metal, or product use is implemented or
authorized.

The historical held-root/crosswalk topology is additive V5,
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`; its canonical
SHA-256 is
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`.
Historical
`PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV4` remains exact at
SHA-256
`8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`.
Topology V1 remains exact at SHA-256
`48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`.
Topology V2 remains exact at SHA-256
`abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`.
Topology V3 remains exact at SHA-256
`b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`.
Topology V5 preserves V1 through V4 plus plan V5 and source binding V6 as
historical identities,
supersedes only their future donor-routing assumption, and explicitly leaves
source binding V7 unissued. The complete implemented and planned closures are
recorded in
`PRIME-NATIVE-NEURAL-GATE-TRAP-DISJOINT-TOPOLOGY-2026-07-30.md`.
Historical topology V6 has canonical SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`.
Its process/evaluation/receipt ownership and target-free delivery-preparation
claim ceiling is recorded in
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`.
Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
has canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`.
Its declaration/decoder claim ceiling is recorded in
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.
Topology V7 is distinct from source/execution-binding V7, which remains
unissued.
The historical held-root/crosswalk claim ceiling remains recorded in
`PRIME-NATIVE-NEURAL-GATE-HELD-ROOT-CROSSWALK-AUTHORITY-2026-07-31.md`.

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

Implementation is intentionally split after those substrates. The pure
library layer implements raw-UTF-8 stream/chunk mechanics, independent direct
and affine finite-field fingerprints, the raw-byte cache guard, and typed
invariant/fingerprint payload validation.
`PrimeNativeNeuralGateCorrectedMechanics` depends only on that layer and now
contains prompt-only input, replicate-scoped admitted seed context,
fixed-cap/EOS full-512-logit decisions, and raw structural execution traces.
The new one-way
`PrimeNativeNeuralGateCorrectedEvaluationMechanics` target depends on the raw
target and owns correlation, completion feasibility, canonical regrade,
weighted statistics, fixed-prompt margins, capability thresholds, ten-leg
count verdicts, and fifteen ordered mutation-observation validators. Prompt
solver and logit sidecar depend only on the raw target. Fixture authority
depends on both plus the trap-bearing corpus derivation target. Full logits
are locally digest-bound; Foundation/Double probability values remain
non-evidentiary and cannot replace the frozen source-pinned Float32
log-softmax.

Those APIs accept caller-provided values. They do not derive or run a semantic
solver, inject or detect the named mutations, establish any leg/capability
truth, decode durable Stage-B artifacts, or authorize a receipt. Semantic
match and model capability remain unavailable.

An isolated `PrimeNativeNeuralGateCorrectedFixtureAuthority` target now
exhaustively recomputes the five selected splits and globally sorts all 18,432
rows by raw UTF-8 row ID. It cross-binds the donor and corrected tokenizer
contracts, regrades every selected fixture row, and separately binds complete
source-row and outer-regrade records, prompt-only inputs, and
domain-separated target-token/EOS feasibility. The fixture identity is
`c1f29a0d1067a4bce5541ee5100044276ccc16c63e57501b509fb3126fcd29a4`;
the canonical observation is
`a30c7fe39157ce6e0de2e0783a8af8807c4a1b02b309a144ba3272a6cc6d931d`.
The historical regression fixture is lineage-only here and is neither read
nor executed. Complete Stage-A and full-corpus parent receipt identities are
source-bound and type-decoded in repository tests, but receipt bytes are not
read during derivation and no independent fixture probe/verifier receipt is
published.

The concrete prompt-only derivation is isolated in
`PrimeNativeNeuralGatePromptSolver`. Its only local target dependency is
`PrimeNativeNeuralGateCorrectedMechanics`, and its public concrete type is
`PrimeNativeNeuralGatePromptOnlyReplicateSolver`. The solver receives only a
`PrimeNativeNeuralGatePromptOnlyExecutionInput` plus the admitted seed fixed in
its `PrimeNativeNeuralGateCorrectedReplicateContext`; every solve creates fresh
local parse/evaluation state. Recognized valid prompts produce deterministic
synthetic completions with EOS and finite 512-value decision logits;
unrecognized or invalid prompts abstain. Those in-memory logits are not the
required durable full-vocabulary sidecar and do not establish the
source-pinned Float32 log-softmax evidence.

The adaptation binds this exact Ergentics-owned donor provenance:

| Binding | Value |
| --- | --- |
| Rights holder | `Ergentics, LLC` |
| License | `LicenseRef-Ergentics-Proprietary` |
| Remote | `https://github.com/Ergentics/pmhnp-companion-ergentics.git` |
| Revision | `163fc100710ece48119bc25954452d10f6a84f7f` |
| Tree | `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Donor path | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift` |
| Git blob | `b2a087c9410a71f2bc99debade752ff779d7a8a8` |
| Bytes | `177032` |
| SHA-256 | `4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210` |

This is a trap-free Swift adaptation of the donor's private grammar and
semantic evaluator, not a byte-exact transplant. The repository test contract
passed all 18,432 selected rows under each admitted replicate seed (`1618`,
`2718`, and `3141`) and again in seed-keyed row permutations. The 670.275
second exhaustive gate required exact output and EOS, exact selected `+1` /
unselected `-1` Float32 bit patterns and `PRIMEFVL1` digests at every
decision, seed-invariant per-input logit manifests, and distinct seed-bound
raw trace identities. Separate mutations reject noncanonical openings,
surface/action/question mismatches, missing/extra/interior LF, and CRLF to
exact `ABSTAIN\n` plus EOS. This remains repository-only symbolic/synthetic
mechanics evidence—not model execution, an independent scientific oracle, a
durable solver observation or receipt, Metal authority, or product authority.
Plan V5 keeps `executionImplemented` false. Corrected admission V3 and source
binding V6 bind the bounded lossless logit-sidecar codec and maintained MLX
Float32 log-softmax operation as source contracts only. No durable sidecar,
full-fixture process observation or recomputation, model execution, Stage-B
Metal authority, worker/process record, independent solver/fixture receipt,
terminal Stage-B receipt, or product authority has been established.

The repository-test checkpoint passed pure sidecar mechanics 6/6. The
source-pinned MLX validation package remains outside the MLX-free
`PrimeCoreTests` bundle and passed 9/9 in 193.005 seconds against the exact
3,817,916-byte metallib, SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`,
with structural three-vector digest
`8dca965dbb3057c79d268435b23e58ecab8e77ecfe745b6a434cc1b2a852d98a`.
Those nine cases comprise seven focused MLX mechanics cases and two exhaustive
integration cases; the main exhaustive case took 192.889 seconds and covered
18,432 rows and 232,638 decisions per seed for `1618`, `2718`, and `3141`. It
reconstructed every decision bit-exactly from 44 unique complete 512-value
vectors, a 90,136-byte dictionary, and a 2,070,912-byte aggregate, with stable
MLX digest
`db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02`.
The codec admits at most 1,179,648 candidate vectors and 65,536 unique vectors.
This is repository mechanics only, not durable Stage-B evidence.

The dedicated historical worker follows a completed, trap-disjoint semantic
layer; paired probe and verifier remain later work because neither may
independently publish a terminal receipt.

The pre-factory contract-only canonical JSON content SHA-256 was
`149dfea0e90c56f012d1da748cf934a5a398d3829533c2826a480afbdb9ab77d`.
That value is historical. The historical V3 plan content SHA-256 is
`9e8e9c4820fcea592f79cb4cbdc9abdd217a0ca6e00e2b715a215d8a1d315ee6`.
That V3 digest remains the historical pre-solver identity. The canonical V4
plan content SHA-256 is
`a458a2caf801d01fa98b403b21514d2ea18ddbe284ea4d893c101fc5ca7663be`.

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

## Blocked draft target graph and implemented pure boundary

The V3 aggregate target graph was frozen as:

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

Forward audit found that this shared graph would expose trap-bearing
historical donor/runtime code to corrected supervisors. It is a blocked draft,
not an execution-authorized topology. Before Stage-B execution it must be
amended so corrected supervision has no trap-bearing donor dependency.

The implemented corrected dependency edges are:

```text
PrimeNativeNeuralGatePromptSolver
    └── PrimeNativeNeuralGateCorrectedMechanics
        └── PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateCorrectedFixtureAuthority
    ├── PrimeNativeNeuralGateCorrectedMechanics
    └── PrimeNativeCorpusReplayMechanics

PrimeNativeNeuralGateMLXLogSoftmaxRecomputation
    └── PrimeNativeNeuralGateLogitSidecarMechanics
        └── PrimeNativeNeuralGateCorrectedMechanics
```

The corrected mechanics target contains pure value/observation mechanics
only. The fixture-authority leaf is offline and trap-bearing through its
corpus dependency. The prompt-solver leaf is trap-free and depends only on
corrected mechanics. The sidecar target is pure Swift; the recomputation target
uses the source-pinned maintained MLX/MLXNN operation. Source-binding V6 attests
all five targets while leaving them unreachable from every current
probe/verifier executable closure. V5 remains the historical thirteen-target
prompt-solver source contract and V4 the earlier twelve-target
fixture-authority contract. None has a process, network, model, durable
artifact observation, Stage-B receipt, Stage-B artifact publication, or
product-evidence publication path.

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
zero-byte/`EINVAL` and exact optional `com.apple.TextEncoding`, the live Release
two-role canary was rerun after the fixture-authority twelve-target source
freeze and passed on the pinned host with the exact 23,207-byte output binding
above. After the thirteenth prompt-solver target was added, the canary passed
with the exact 23,791-byte output and
`9d56ad223c9d980272583dc752e0ff05bb815ce504cd3c82fc7e186627c02aa7`
SHA-256 binding above. That is valid historical evidence for the complete
thirteen-target package description and source snapshot under the typed V4
selected-subgraph contract, not a typed V5 source-binding reseal. Neither
canary pass published a durable Stage-B process record or receipt,
`executionImplemented` remains false, and no replay, worker, model, Metal, or
product claim follows. Future probe and verifier records must
bind one byte-identical JSON output and the same direct `swift-package`
mapped-vnode/descriptor/byte identity. That evaluated output must reconcile
the same materialized target/source contract, including target type, path,
direct local and product dependencies, and complete Swift source lists. V6
does not satisfy that condition because it names non-materialized execution
targets and its live 26,090-byte capture was never reconciled against its
planned closure. After the raw/evaluation split, the last accepted
topology-V1 actual-package capture is 27,015 bytes with SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`.
It predates the two topology-V2 targets and cannot be reused as V2 evidence.
The last accepted topology-V2 actual-package secure-capture reseal is
byte-identical across probe and verifier at 28,589 bytes with SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
It predates topology V3 and remains secure-capture evidence, not V6/V7 graph
proof. The last accepted historical topology-V3 actual-package secure-capture
reseal is
byte-identical across probe and verifier at 29,905 bytes with SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
The V3 pass validates only the secure-capture substrate on the pinned host. It
is not V6/V7 selected-source execution-graph proof; it does not issue source
binding V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
The last accepted historical topology-V4 actual-package secure-capture reseal is
byte-identical across probe and verifier at 32,735 bytes with SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
It has the same secure-capture-only scope and is not V6/V7 selected-source
execution-graph reconciliation.
Source binding V7 remains reserved until the planned execution targets exist
and a live compiled-source closure validates those exact captured bytes.

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
Those 20,959 bytes and that output hash describe only the earlier graph. The
preceding twelve-target fixture-authority secure-capture canary was 23,207
bytes with SHA-256
`f2204bbae8623c35fdf7357c6b0aa2a585e9071f22556edbe6ce6e7cfccf04d5`.
The historical thirteen-target complete-package/source-snapshot capture under
typed V4 selected-subgraph authority is 23,791 bytes with SHA-256
`9d56ad223c9d980272583dc752e0ff05bb815ce504cd3c82fc7e186627c02aa7`.
It is not a typed V5 reseal. Neither the historical graph output nor either
secure-capture canary is a Stage-B replay execution record.

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
- `PrimeNativeNeuralGateSourceExecutionBindingContract.frozenV6`, contract ID
  `prime_stage_b_release_source_executable_join_v6`; V5 remains frozen as the
  historical thirteen-target prompt-solver source contract, V4 as the earlier
  twelve-target fixture-authority source contract, and V3 as the earlier
  ten-target source contract;
- `PrimeNativeNeuralGateHistoricalWorkerContract.frozenV2`, contract ID
  `prime_stage_b_historical_fixture_worker_v2`;
- `PrimeNativeNeuralGateOutputPathClassificationContract`, contract ID
  `prime_stage_b_output_path_namespace_classification_v3`;
- `PrimeNativeNeuralGateReplayOutputContract.frozenV3`; and
- `PrimeNativeNeuralGateFixtureReplayPlan.frozenV5`, schema 5, plan ID
  `ergentics_prime_native_neural_gate_dual_fixture_replay_v5`, canonical
  content SHA-256
  `c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b`;
  frozen V4 remains the historical pre-sidecar plan and V3 the pre-solver
  plan. The unchanged V3 replay-output namespace still reserves
  `neural-gate-replay/plan.v3.json`; no V4 or V5 execution artifact is claimed.

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
distinct, producing the historical V5 six-process topology. Historical
topology V6 freezes the replacement symmetric ten-role
process/evaluation/receipt
ownership declarations, including two corrected raw and two corrected
evaluation workers, but materializes none of them. Topology V7 freezes typed
role/path/content and four-part worker-source declarations under a common
capture/schedule identity, but realizes none of them. Actual source snapshots,
compiled closures, sealed executables, and artifact-content references remain
prerequisites. Each future worker result must bind
its same-process PID and the same sealed worker image. The verifier must
validate each record before applying the explicit prevalidated-record
topology join.
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

## Arm-specific terminal requirements and current truth

| Claim | Historical forensic arm | Corrected fixed-cap/EOS arm |
| --- | --- | --- |
| Source-pinned fixture mechanics | yes | yes, as a named Prime adaptation |
| Required prediction provenance | `synthetic_oracle_forged` | prompt-only deterministic synthetic executor |
| Current execution implementation | absent | no Stage-B execution; symbolic solver source plus value calculators only |
| Exact fixture identity/count bound | historical source pinned | yes; offline source-plan binding over 18,432 rows, no independent fixture receipt |
| Concrete prompt-only solver bound | not applicable | yes; source-plan-bound symbolic/synthetic Swift mechanics only |
| Fixed cap 64, independent of target | no | required |
| EOS available at every decision | only report-declared | required by construction and mutation |
| May pass mechanics replay | yes | yes |
| May ground terminal Stage B alone | no | no; both arms required |
| Must equal unpublished historical residues | no | no; separate namespace |

The corrected arm uses the already frozen
`greedy_native_bytes_eos_fixed_cap64_kv_v2` generation contract. It may not
derive a negative output, output length, grouping key, decision budget, or
termination condition from the target. Its row-level prediction input is
exactly `prompt_token_ids`. The one admitted evaluation seed is held once at
the replicate/shard scope; it is not a row field. `correlation_id` remains
outside the executor. `row_id`, split, semantic family, generator index,
prompt text/grouping, seed, target, target tokens, expected completion,
regrade fields, abstention fields, and budget controls are forbidden
row-level inputs.

The complete source-derived fixture identity, exact row count, and concrete
prompt-only solver derivation are now source-plan-bound, and all canonical
completion support fits the frozen cap with EOS. Those bindings are not an
independent fixture/solver receipt and do not authorize execution. The solver
starts from fresh local state for every row, and the repository test contract
observed that permuted invocation order preserves each prompt's raw trace
exactly. The support remains EOS plus all 256 byte tokens, the decision cap is
exactly 64, EOS is available at every decision, and no per-row
target-dependent seed, skip, grouping, batching, state retention, or
termination is allowed. Admitted replicate seeds are `1618`, `2718`, and
`3141`; each passed separately over the same complete fixture.

The pure trace binds each full 512-logit decision by an exact bit-pattern
SHA-256 rather than expanding every logit into the canonical invariant
multiset. Hex expansion would exceed the Stage-B `1_000_000`-record and
`1 GiB` aggregate decode limits at the required fixture size. This bounded
binding is not a durable full-logit artifact: corrected execution remains
closed even though the chunked sidecar codec and maintained MLX Float32
operation are now source-bound and repository-tested. It still requires
trap-disjoint processes, source-bound mutators and typed decoders, durable
sidecar publication, and independent full-fixture process recomputation. The
local Foundation/Double probability diagnostics are excluded from canonical
fingerprints and are not evidence.

The corrected catalog freezes fifteen ordered defect IDs:

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
| `correlation_row_id_injected_into_prediction` | outer row correlation enters row construction | `corrected_prediction_input_exclusion` |
| `correlation_split_injected_into_prediction` | outer split correlation enters row construction | `corrected_prediction_input_exclusion` |
| `correlation_semantic_family_injected_into_prediction` | outer family correlation enters row construction | `corrected_prediction_input_exclusion` |
| `row_dependent_evaluation_seed` | seed is selected from row, target, or correlation metadata | `corrected_replicate_seed_scope` |
| `retained_state_changes_permuted_row_trace` | cross-row state makes a prompt trace order-dependent | `corrected_row_order_state_independence` |

Future source-bound mutation execution must detect every historical and
corrected defect, fail its frozen leg, diverge in fingerprint, and restore
both records and fingerprint exactly. The implemented pure target currently
validates only caller-provided mutation observations, ordering, divergence,
and restoration; it does not inject or independently detect these defects.

## Verify/Abstain and verdict scope

Both arms must independently regrade their raw inputs, recompute all ten
projected `NL1`–`NL10` leg outcomes, recompute the source-pinned
target-token-weighted statistics and fixed-prompt runner-up margin, apply the
projected capability thresholds, and derive the count label and all-critical
verdict from those recomputed observations. Candidate-declared aggregates are
never authority.

The corrected-mechanics target supplies arithmetic/value recomputation only.
The separate prompt solver supplies deterministic symbolic/synthetic
completions and in-memory logits, not model observations. Loss rows,
capability rows, critical-leg booleans, mutated records, and failed-leg IDs
remain caller inputs, and no durable full-logit sidecar is bound. Positive
solver or calculator outputs therefore do not establish model mechanics.
Exact regrade is NFC-consistent and requires EOS, but model semantic match
remains `unavailable`; capability and verdict calculations leave model
capability `unavailable`. No TriadAudit, independent implementation family,
guarded statistic, or receipt is created.

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
  running Release executable bindings; the historical probe, verifier, their
  two SwiftPM children, and two historical workers form V5's six-process
  topology; V6 freezes a non-authorizing ten-role replacement ownership model,
  and V7 freezes typed common-capture artifact and worker-source declaration
  schemas. Real common/branch scalar references are supervisor-derived and non-
  authorizing, but realized worker-source and role-artifact content references
  plus all worker/supervisor materialization remain prerequisites;
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
- all fifteen corrected construction, metadata, seed-scope, and row-state
  mutations executed and detected,
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

## Development workflow follow-up

A local Swift workflow preflight is a separate future slice, not part of
Stage-B execution. Its useful boundary is read-only and credential-free: emit
canonical JSON for repository root, branch/upstream, clean or exact diff
state, commit author identity, embedded source-seal agreement, and named test
evidence. It must not hold GitHub credentials or perform push, PR, review, or
merge operations. The signed-in GitHub app remains the authenticated
publication authority and the final human-visible confirmation point. This
keeps desirable publication friction while removing repeated local-state
ambiguity.

## Next actions

Descriptor-rooted invariant validation, source-bound lossless-sidecar
validation, incremental schedule reconstruction, and the exact four-source
join remain frozen under topology V4. Historical additive topology V5 also implements
the retained exact 41-file held-root capture and the independent source-derived
18,432-row keyed prompt/target crosswalk. The focused integration passed in
300.125 seconds. V5 establishes only the exact capture epoch, bounded durable
origin for captured bytes, corrected fixture identity, exact source join,
independent crosswalk, and outer completion binding. Prompt-content target
independence, process delivery, model execution, evaluation/verdict authority,
mechanics `PASS`, receipt, science, and product authority remain false.
Topology V6 freezes the symmetric ten-role process roster, branch-scoped
raw/evaluation ownership, verifier-only receipt-last ownership, target-free
schedule construction, and a real retained-capture-bound supervisor adapter.
Topology V7 adds exact-count bounded `PRIMEIRM1` raw/outer stream admission
while aggregate candidates remain non-`Decodable`, and freezes typed
common/branch/artifact and four-part Release worker-source declarations. Real
common/branch scalar references are supervisor-derived and non-authorizing;
realized worker-source and role-artifact content references remain absent. The
adapter prepares source- and owner-bound candidates but does not observe
delivery. Topology V7 is distinct from the
still-unissued source/execution-binding V7. At the V7 checkpoint, the corrected
implementation prerequisite was:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

Its then-planned implementation order was:

1. freeze the deferred mutation, historical, MLX, and statistics/verdict
   record schemas;
2. assign a source-bound corrected mutation producer and an independently
   implemented detector;
   the current fifteen mutation-observation validators do not execute defects;
3. implement the isolated historical worker using the completed secure
   capture and live role-prefix inventory capabilities; and
4. implement the paired probe/verifier and exact path/metadata/content
   inventory, durable sidecar publication, full-fixture MLX recomputation,
   full-root pre-receipt recapture, and receipt-last publication.

That order is now refined by observed source reality. V8 completed the schema
and disjoint corrected-target step, V9 derived the historical source material,
and V10 compiled the internal historical closure. V11 source-binds the exact
historical fixture and creates only an executable target whose `main` exits
unavailable with status `78`; it does not implement item 3's evidence-producing
worker. The V11 next prerequisite was:

`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`

V12 resolved only that design/source-contract boundary. Topology V13
materialized the exact source-only exporter. V14 now appends that exporter to
the worker's exact four-dependency prefix and source- and compile-binds one
private cross-file call edge. The V11 primary source is unchanged; `main`
still exits `78` and cannot name that member. No worker request handling,
sealing, launch, execution, encoding, or publication is enabled. The V14
historical prerequisite is recorded in
[Prime Native Neural Gate Historical Worker/Export
Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).

V15 completed only the carrier-to-artifact projection design audit. Its exact
nine-field mapping cannot yet become a codec: the namespace has three deferred
historical specifications versus 22 worker artifacts per role; the singular
statistics schema cannot losslessly retain all three keyed seed families; and
the V15 semantic-record target violates historical-worker dependency
isolation. External context and observation-state policies are frozen. The
complete namespace, additive keyed three-seed envelope, and historical-only
projection boundary must become exact before projector materialization. See
[Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md).

At the V16 checkpoint, V16 satisfied that bounded prerequisite with an additive 44-spec
namespace, exact seed-keyed envelope, corrected mutation-record split, and
package-internal in-memory projector. ReplayTransport is unchanged and not in
the projector closure; the status-`78` worker was unchanged and could not invoke
the projector. This is source/package/test evidence only. See [Prime Native
Neural Gate Historical Evidence Semantic-Artifact Projection
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-SOURCE-2026-08-01.md).

V17 now satisfies the private call-edge prerequisite with a third worker
source accepting an already-formed carrier plus explicit context. The exact
status-`78` main and V14 edge cannot name it; ReplayTransport/decoder
integration, invocation, I/O, and publication remain later boundaries. See
[Prime Native Neural Gate Historical Worker Semantic-Artifact Projection
Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-PROJECTION-CALL-EDGE-SOURCE-2026-08-01.md).

Those namespace, envelope, codec, and compiler-bound call-edge boundaries are
now exact through V17. The next slice must design and source-bind the complete
V16 historical semantic-artifact decoder for the six canonical JSON leaves and
descriptor-streamed global/chunk artifacts per role. Only after that separate
boundary may a later slice consider ReplayTransport integration, worker
request handling, sealing, launch/supervision, semantic artifact publication,
or the paired probe/verifier. The V10 public seam's summary projection cannot
replace the complete V16 artifact namespace.

After a real dual-arm Stage-B pass:

`physical_native_checkpoint_and_evaluation_shard_binding`

That next step begins real-artifact admission. It is not authorized by this
contract-only change.

## V18 historical semantic-artifact decoder continuation

V18 fulfills the V17 decoder-design prerequisite as a pure consumer boundary.
It adds a product-free keyed-three-seed statistics wire target and a
product-free semantic-artifact decoder target, but does not connect either one
to the historical worker, V16 projector, `ReplayTransport`, a descriptor, or
an artifact root. The decoder receives caller-owned bytes only.

For each historical role, exact keyed coverage remains 22 artifacts: six
bounded canonical JSON leaves, one invariant global stream, and fifteen
ordered invariant chunks. Foundation `Codable` plus canonical re-encoding
owns JSON admission, while the statistics envelope remains non-`Decodable` to
generic callers. The existing maintained framed reader owns exact-keyed
incremental fragments capped at 65,536 bytes. No all-binary materialization
convenience or pre-verification record callback is exposed. The decoder
requires byte-exact global/chunk record equality for all 59,497 records across
the exact 15-chunk geometry and derives the complete 22-binding set only after
terminal acceptance. It fails closed on missing, duplicate, wrong-role,
wrong-ordinal, unexpected, non-canonical, mismatched, oversized, truncated, or
trailing input.

This closes only compatibility mechanics. It does not show that a descriptor
captured producer bytes, that the V17 worker or private projection edge ran,
that the historical gate/model or mutation workload executed, or that an
artifact was written or published. Request handling, sealing, launch,
supervision, `ReplayTransport`, I/O, mechanics `PASS`, terminal receipt,
source/execution binding V7, scientific authority, and product authority all
remain absent. The exact next prerequisite is
`source_bind_the_unavailable_historical_worker_already_formed_v16_projected_artifact_set_to_the_complete_v18_historical_semantic_artifact_decoder_call_edge_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Historical Semantic-Artifact Decoder
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SEMANTIC-ARTIFACT-DECODER-SOURCE-2026-08-02.md).

## Additive V8 continuation

The V7 schema/assignment prerequisite above is now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
V8 preserves replay plan V5, semantic namespace V4, and the V7 twenty-path
declaration exactly. The missing semantic record shapes are frozen, and four
internal Swift targets separate the narrow label-free, presence-only surface,
the semantic catalog/identity contract, the corrected 15-case producer, and
the independent detector. The corrected mutation catalog/control contract has
SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on surface contracts and closes transitively
over only surface plus replay mechanics, structurally excluding the catalog,
identity, expected-leg mapping, replay-artifact contracts, and producer.
Its sole public entry admits exactly 15 triplets at once; single-triplet
detection is private. All full bound baseline/restored contexts must be
byte-and-binding identical across the batch, and all mutated surfaces must be
pairwise distinct. Wrong counts, duplicate cases, per-case reference-hash or
seed drift, and any fixed-cap value other than exact defect 63 against baseline
64 fail closed. Permutation invariance is verified. `Label-free` excludes
explicit mutation IDs/labels, arbitrary prediction strings, and per-case
caller-controlled context.
Their local in-memory tests do not materialize the isolated historical worker,
any supervisor/process, or durable mutation evidence. Actual Release source
references remain absent and non-authorizing; `executionImplemented` is false
and source/execution-binding V7 is unissued.

Fixture truth is also insufficient for a verdict by count.
`countDerivedLabel` is scoped `provisional_count_only_non_authorizing`, and ten
bare true legs still yield `ABSTAIN`. `GROUNDED` requires verified/durably
published evidence per true leg, weighted-statistics recomputation,
stable-greedy and behavioral fixed-prompt predicates, model capability
including exact abstention decisions, mutation-sweep and source-bound-leg
evidence, distinct implementation families, and four-tier audit state.
The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API remains
compatible but always returns `ABSTAIN`, exposes only the provisional scope,
and cannot produce generic `GROUNDED`. Historical `GROUNDED` also requires all
five aggregate references to be
verified/durably published and model execution observed. V8 carries none of
that durable authority; mechanics `PASS`, science, and product claims stay
false.

Historical package capture continued after V5 with V6 at 40,100 bytes,
SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`,
under source identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
Those are secure-capture-only prevalidation checkpoints. Completed final V8
validation is recorded canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
The historical gate/carrier seam and raw 46-case material must be derived from
the pinned donor source rather than hand-ported. Topology V9 now performs that
bounded derivation and introduces additive adaptation proof V3, which corrects
the future gate/carrier destination to the historical replay target while
preserving V2 as history. Topology V10 now compiles that exact closure behind
an internal, unreachable historical library and binds the Prime observation
seam without executing it. Its next prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
V11 now completes its fixture-source and unavailable-target portions only.
Its next prerequisite was
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).
V13 resolved the bounded historical-evidence exporter source and topology
materialization prerequisite while preserving the V13 worker call graph. V14
now adds one separately pinned private cross-file call edge while preserving
the byte-exact V11 primary source and status-`78` main. That edge remains
unreachable from `main` and is source- and compile-bound only. V14's next exact prerequisite was
`design_and_source_bind_the_historical_evidence_carrier_to_frozen_worker_semantic_artifact_projection_without_enabling_worker_request_handling_sealing_launch_execution_or_issuing_source_binding_v7`.
V15 source-binds that design only. It freezes the exact nine-field mapping,
mandatory external context, and fail-closed join/observation policies while
recording the incomplete namespace, missing keyed three-seed envelope, and
historical-only dependency-isolation blockers. No projector existed at V15.
Its next exact prerequisite was
`freeze_the_complete_non_authorizing_historical_semantic_artifact_namespace_and_additive_keyed_three_seed_statistics_envelope_then_source_bind_a_historical_only_projection_codec_without_enabling_worker_request_handling_sealing_launch_execution_publication_or_issuing_source_binding_v7`.
V16 satisfies that prerequisite additively without changing the unavailable
worker, integrating ReplayTransport, writing or publishing artifacts, or
issuing source/execution binding V7. The projector is a package-internal pure
in-memory boundary; Swift tests are not historical execution evidence.
See [Prime Native Neural Gate Historical Evidence Export Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-EXPORT-SOURCE-2026-08-01.md).
See [Prime Native Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
See [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md).
See [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-SOURCE-2026-08-01.md).
V17 appends only the private compiler-bound worker/projector call edge and the
sixth dependency. It does not enable request handling, ReplayTransport/decoder
integration, execution, I/O, publication, or V7. See [Prime Native Neural Gate
Historical Worker Semantic-Artifact Projection Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-PROJECTION-CALL-EDGE-SOURCE-2026-08-01.md).

## Additive V19 projected-set decoder call edge

V19 adds only the compile-bound edge that the completed V18 decoder required.
The unavailable worker retains its exact status-`78` `main` and private V14/
V17 edges, then appends one private source accepting an already-formed V16
projected artifact set and the V18 decoder as the seventh dependency after the
exact V17 prefix. None of the earlier files can name the new private member,
and no test imports or invokes the worker.

The edge obtains the six canonical leaves by exact key and feeds the global
and fifteen manifest-declared chunk streams through the maintained V18 decoder.
Paired fragments are global-first, equal in byte count, and no larger than
65,536 bytes; remaining chunk and global bytes are drained only through the
bounded finish sequence. No JSON or frame parser, frame-header math, record
inspection, transport, filesystem/process I/O, publication, or execution path
is added.

The evolved live V17 guard preserves its former exact source assertions and
adds only the V19 source/dependency continuation; the old V17 guard identity
remains recorded as history. V19 is not fixture replay, historical evaluation,
durable evidence, `PASS`, receipt, source/execution binding V7, science, or
product authority. See [Prime Native Neural Gate Historical Worker
Semantic-Artifact Decoder Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-DECODER-CALL-EDGE-SOURCE-2026-08-02.md).

The next exact prerequisite is a design checkpoint only:

`design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V20 design checkpoint for the future composition edge

V20 freezes only the future composition contract and topology. It changes no
`Package.swift`, worker inventory, target reachability, V16 projector, V18
decoder, V19 edge, fixture, runtime, or executable path. The two exact inputs
are already-formed V14 Evidence and explicit V16 context; both context
observation states must be `unavailable`, with no role/state defaulting or
inference.

Evidence remains non-`Codable`, opaque, and without canonical or source
identity. Its equality cannot be promoted to a digest—the signed-zero
counterexample produces equal floating values but different projected bit
patterns—and its target-bearing fields cannot be logged or used for model,
evaluation, ranking, or recommendation behavior.

The future non-`Codable` result retains the exact projected set and the
decoded set produced from it, linked across one role and the exact ordered
22-key byte-count/SHA-256 inventory. It is neither durable evidence nor a
publication or receipt capability. Implementation is reserved for an
append-only same-file continuation of V19 that reuses the existing private
decoder edge and V16 projector without duplicating the bounded zipper or
widening access.

V20 executes nothing and leaves `ABSTAIN`, transport, request handling,
sealing, launch, I/O, publication, `PASS`, receipt, V7, science, and product
authority unchanged. Design SHA-256 is `b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c`; topology
SHA-256 is `b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57`. See [Prime Native Neural Gate
Historical Worker Exported-Evidence Projection/Decode Composition
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-DESIGN-2026-08-02.md).

The next exact prerequisite is:

`source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V21 append-only composition source

V21 source-binds the V20 design without running the historical fixture. The
V19 decoder edge remains the exact 7,050-byte prefix of its live file. The
append accepts only already-formed Evidence and explicit context, rejects
either observation state unless `unavailable`, projects once, reuses the V19
private decoder once, and admits the result only after exact keyed 22-artifact
role/order/specification/byte-count/SHA linkage.

The private `Sendable` pair is not a replay artifact, descriptor capture,
publication candidate, receipt, or admission result. `Package.swift`, the
four-file worker inventory, seven dependencies, fixture resource, target graph,
and status-78 main remain exact. Compiler binding does not establish fixture,
worker, projector, decoder, gate, mutation, model, or evaluation execution.
Source/topology SHA-256 values are
`843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`
and `6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`.
See [Prime Native Neural Gate Historical Worker Exported-Evidence Projection/
Decode Composition Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-CALL-EDGE-SOURCE-2026-08-02.md).

Prime remains `ABSTAIN`. The next exact prerequisite is:

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V22 design-only seam before any replay caller

V22 does not replay the fixture or add a caller. It freezes one future
append-only, same-file access bridge: an internal wrapper nested in the worker
with only the private V21 composition result, a private initializer, no
accessor/conformance, and one internal static method on the wrapper. That
method calls the private V21 composition edge exactly once with unchanged
already-formed Evidence and explicit context and lets every error propagate.
Both context observations remain nonoptional and exactly `.unavailable`
before V21 projection; `.observed_false` is not absence and `nil` is not an
admitted substitute. The bridge adds no duplicate/default/inference path.

No `main` edge, request decoder, `ReplayTransport` integration, process owner,
worker launch, artifact reader/writer, or wrapper consumer is designed or
implemented. V22 adds PrimeCore governance contract/topology source only; it
adds no worker, invocation-seam, runtime, replay, or caller source and preserves
the exact V21 source, status-78 main, `Package.swift`, worker inventory, target graph, and forbidden
reachability. Design/topology hashes are `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757` and
`af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. See [Prime Native Neural Gate Historical Worker
Invocation Seam
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-DESIGN-2026-08-02.md).

Replay, execution, publication, durability, receipt, V7, science, and product
authority remain false; Prime remains `ABSTAIN`. The next exact prerequisite
is:

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

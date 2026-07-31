# Prime Apple-native learning plan

Status: planning and admission authority
Snapshot date: 2026-07-29
Prime baseline: `5a8aa46c725b3f3c863ccfbfb5073549fcd18e33`

## Purpose

This document turns the current Prime mechanics work into a reality-based
implementation plan for a first-party, Swift-first learning system on Apple
silicon. It records:

- what exists in Ergentics repositories and what is still aspiration;
- which Apple frameworks solve which parts of the system;
- why exact optimizer restoration remained `ABSTAIN` on the stock API and
  what the private typed-state candidate now proves;
- the smallest supported fix for that blocker;
- how Prime, NeuralKit, MasteryKit, AgentContractKit, Workstation, Logic,
  Algebra, Geometry, and Ur should compose without creating a dependency knot;
- the gates that must pass before another long or 3B training run.

This is not authorization to start functional training, write a 3B checkpoint,
promote a model, change PMHNP product authority, or introduce a Python
scientific lane. The current PMHNP release route remains governed by its own
product-truth artifact. Prime is the research execution authority.

The companion [Prime safe first-party AI R&D charter](PRIME-AI-RD-GOVERNANCE.md)
defines the implemented-versus-planned control boundary, agent and Workstation
authority, per-tool Python exception requirements, data/model provenance, and
open-source readiness. It is an internal R&D policy, not a compliance or
scientific claim.

The exact private derivative publication, commit-identity normalization,
recovery, and fresh-receipt sequence is frozen in
[the private MLX mirror migration pickup](PRIME-PICKUP-PRIVATE-MLX-MIRROR-2026-07-29.md).
That pickup permits amendments only to the two unpushed arc-tip commits; it
does not authorize rewriting merged or upstream history.

## Executive decision

Use maintained MLX Swift as the primary Apple-native training runtime. It
already supplies Swift model primitives, automatic differentiation,
`MLXOptimizers.AdamW`, and Metal execution. Do not replace it with a
Prime-written optimizer or a whole-model custom Metal trainer.

Before any resumable training, complete this sequence:

1. add a public, typed optimizer-state export/import seam to a narrowly pinned
   Ergentics fork of `mlx-swift`, while preserving the upstream AdamW
   arithmetic unchanged — implemented in private revision
   `68904d54b72871f26968261ae05d4fbb7c5e3142`, with fork tests and
   authenticated cache-empty clone resolution observed;
2. after a separate human authorization and the license, security, provenance,
   and publication reviews in the R&D charter, propose the same capability
   upstream and move back to an upstream release when it exists — future
   option, not authorized by this plan; the private revision is not public,
   upstream-accepted, or an open-source release;
3. prove exact `N -> checkpoint -> fresh process -> N+1` trajectory identity
   on tiny CPU FP32 flat and nested models — complete in a canonical Release
   run bound to the private revision across three fresh worker processes, with
   all 19 declared structural mutations disposed; a fresh reissue and its
   complete evidence root are repository-durable at `3481ffc`;
4. resolve and byte-verify only the four Prime-owned exact-3B/CPU evidence
   bindings required by this slice, then run the scoped
   Prime/private-MLX source/dependency/runtime compatibility replay;
5. prove an interrupted two-step Metal canary on the existing native 3B
   geometry, operator-selected for bounded mechanics only, with complete
   training-state restoration;
6. only then consider separately scoped functional profile calibration,
   corpus-schema migration, retained checkpoint I/O, or long training.

Assess MPSGraph as a small Swift primitive-level numerical verifier where its
Adam semantics can be aligned explicitly. Its graph/optimizer API is disjoint
from MLX, but it is not hardware-disjoint when both run on the same Metal
device. Use Core ML and the preliminary Core AI framework as
deployment/inference lanes, not as the 3B trainer. Add a custom Metal kernel
only after profiling identifies a material bottleneck and the kernel has
independent forward and backward oracles.

Prime does not currently import NeuralKit, MasteryKit, or AgentContractKit.
That is the correct dependency direction for the tensor core, but those
packages are not absent from the arc:

- NeuralKit remains the PMHNP-local load/propose inference consumer and
  independent synthetic/research-artifact regrade for mature Swift evaluation,
  SZ, triadic, mutation, and VerifyAbstain contracts; PMHNP retains
  user-visible safety and clinical verification;
- MasteryKit remains a downstream topic-agnostic product-learning consumer and
  bench/statistical-pattern donor; Prime/Workstation-specific EngineRecommend
  handles Prime evidence and bounded experiment proposals;
- AgentContractKit remains an independent verification/governance library.
  Reusable subject-agnostic parts may later move into a small standalone
  evidence package, rather than making Prime depend on `agentcraft-app`.

## Reality snapshot

### Hardware and local toolchain

The audited machine is a MacBook Pro with:

- Apple M5 Max;
- 18 CPU cores;
- 40 GPU cores;
- 128 GB unified memory;
- approximately 1.4 TiB free local storage at the time of this snapshot;
- Xcode 26.6, Swift 6.3.3, and the macOS 26.5 SDK.

Apple lists the M5 Max configuration at up to 18 CPU cores, 40 GPU cores,
128 GB unified memory, and 614 GB/s memory bandwidth. Those specifications do
not create an “all cores” training switch. GPU occupancy depends on tensor
shapes, precision, tiling, batch/sequence sizes, memory traffic, and the
maintained runtime. Utilization must be measured, not inferred from the chip
name.

The installed SDK does not contain `CoreAI.framework`. Apple currently
documents Core AI as preliminary beta software in the Xcode 27/macOS 27
generation. Core AI work must wait for a final or otherwise explicitly
supported toolchain and pass a fresh API audit; the local absence is not
evidence that the public framework does not exist.

### Prime now

`ergentics-prime` currently has real Swift implementations for:

- the exact `ergentics_prime_native_3b_gqa_v1` geometry;
- random initialization and one-step FP32 mechanics;
- factorized initialization, schedule, and evaluation controls;
- MLX/Metal allocation, forward, backward, and maintained AdamW update;
- a process-scoped Metal lease;
- exact executable, source, and MLX metallib binding;
- Swift supervision and fail-closed immutable receipts;
- a tiny cross-process optimizer serialization and optimizer-import
  feasibility probe.

The MLX resource boundary is role-separated rather than build-system-neutral.
The unexecuted Xcode Release host is a stage-time donor whose 1,130-byte
`Info.plist` has SHA-256
`124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e`
and bundle identifier `ergentics-mlx-swift.Cmlx.resources`. The executing
SwiftPM Release host retains its canonical 1,120-byte `Info.plist`, SHA-256
`62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d`,
and bundle identifier `mlx-swift.Cmlx.resources`. Both roles contain the
same 3,817,916-byte `default.metallib`, SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`.
Prime always validates the donor, stages only that exact metallib with
no-replace semantics, and never copies or overwrites the canonical SwiftPM
manifest. Runtime and receipt evidence bind only the canonical manifest and
shared metallib.

The 3B FP32 one-step probe measured an active peak of 46,779,945,265 bytes
(about 43.6 GiB). The raw model-plus-Adam-moment tensor floor for a resumable
checkpoint is about 31.52 GiB before manifests and safetensors headers: about
10.51 GiB of weights and 21.01 GiB of Adam moments. The current stock API
cannot yet import that optimizer state. Gradients, activations, allocator
headroom, graph state, control state, and atomic checkpoint staging add to
those floors.

Prime now admits the exact isolated byte-tokenizer/compositional-corpus replay,
the prompt-only fixed-cap/EOS generation contract, and the bounded Stage-A
native-gate schema projection. Those receipts establish source/schema and
synthetic replay mechanics only.

Prime still does not contain:

- the dual-arm Stage-B execution, including its sealed trap-containment worker;
- a full native-language training executor;
- an evaluator disjoint enough for a broad functional claim;
- AgentContractKit four-tier TriadAudit or an explicit dependency-family
  audit;
- per-family confidence/rank/decision-margin analysis;
- a complete functional executor joined to a physical evaluation shard; or
- an accepted functional checkpoint.

Prime now contains a private public-API typed optimizer-state transport
candidate,
two deterministic mechanics fixtures, a 19-case same-process structural
mutation self-check, three-role process supervision, and an exact canonical
Release CPU `N+1` receipt bound to the private revision. These are
optimizer-resume mechanics, not a functional model or learning-quality
result, and the self-check is not an independent scientific oracle. The exact
derivative revision is privately remote-resolvable and authenticated-clone
resolution is observed. The complete successful evidence root is repository
durable at Prime revision `3481ffc24f3a81a26197fc8625510cab66e6e29b`;
its canonical receipt has SHA-256
`fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d`.

The historical companion has checked-in tokenizer/corpus, evaluator/gate,
fixed-cap/EOS, count-label, fingerprint, and mutation materials. Its evaluator
is not an independent implementation family, and its count-derived triadic
label is not a four-tier TriadAudit. Those materials are frozen donors and
downstream inputs, not proof of a complete functional executor or accepted
checkpoint. The exact boundary is frozen in
[the Prime/NeuralKit continuity contract](PRIME-NEURALKIT-ARC-CONTINUITY-2026-07-29.md).

PMHNP already links NeuralKit, and `StudyAskChatTurn` calls `PrimeAskBrain`.
The local machine also has a gitignored Prime Core ML package of roughly
3.0 GiB and an inherited tokenizer sidecar of roughly 16 MiB. These are local
installation/lab evidence, not source-controlled artifacts, accepted Prime
checkpoints, or product authority. PMHNP’s release path remains engine-only
unless its product-truth contract is changed explicitly.

PMHNP’s shadow store is also already implemented: it persists frozen issuance,
joins exact outcomes, keeps the engine authoritative in service, and records a
fail-honest `provider_not_configured` challenger state. Prime should bind a
real accepted challenger to that seam later, not rebuild it.

## Apple stack decision matrix

| Technology | Training/autodiff | Exact optimizer restore | Intended Prime role |
| --- | --- | --- | --- |
| MLX Swift | Yes; maintained Swift API over Apple silicon/Metal | Stock 0.31.3 lacks import; private Ergentics revision `68904d54b72871f26968261ae05d4fbb7c5e3142` adds a public typed transport seam without changing optimizer arithmetic | Candidate primary trainer; private-revision CPU restore evidence is exact and repository durable, while resumable Metal use still requires interrupted-Metal evidence |
| MPSGraph | Yes; graph/autodiff APIs and Adam operations with explicit moment inputs and updated-moment outputs | Feasible for an app-owned Adam-state graph; AdamW trajectory parity with pinned MLX is unproved | Candidate primitive-level moment/Adam oracle after a semantics assay |
| Core ML | Inference plus constrained on-device updates for eligible legacy neural-network models | No public exact Adam moment/step import/export contract found | Product inference; later audited Core ML Tools conversion/export; tightly bounded personalization experiments |
| Core AI | Preliminary Swift inference runtime; authoring/conversion/optimization is described through Python/PyTorch tooling | No training optimizer contract | Future deployment comparator after final/supported toolchain admission |
| Metal 4 / Metal Performance Primitives | No framework-level training/autodiff; Metal compute and MPP/TensorOps can implement manually authored forward/backward primitives, while the ML command encoder dispatches inference | Entire model/autodiff/optimizer/checkpoint system would be application-owned | Profiler-proven custom kernels only |
| Accelerate/BNNS | Maintained BNNSGraph CPU graph/inference; classic backward/training and optimizer APIs are deprecated | Not a maintained 3B resume path | CPU numerical oracle |
| ML Compute | Deprecated | Not a new foundation | Reject |

### Consequences

- AdamW is not “Python.” Prime is already calling the maintained Swift
  `MLXOptimizers.AdamW`.
- Core AI and Core ML do not repair the missing MLX optimizer-state setter.
- MPSGraph exposes Adam graph operations with explicit moment inputs and
  updated-moment outputs. Prime would own backing tensor data, serialization,
  schedule/step state, and any decoupled-weight-decay composition. The cited
  API is Adam, not a proven match for pinned MLX AdamW; its beta-power overload
  also has different bias-correction semantics. An MPSGraph executable package
  is not an optimizer-state checkpoint. Porting the 3B decoder and aligning
  full AdamW semantics would be a much larger hand-roll.
- A custom `.metal` kernel is not an independent quant family merely because
  it runs on the GPU. It becomes admissible only with a defined operation,
  measured need, independent reference families, backward validation where
  applicable, and bound metallib identity.
- Any Core AI asset production currently requires an audited,
  non-authoritative conversion-only Python/PyTorch tooling exception unless
  Apple later ships a supported Swift authoring path. Custom Metal operations
  are one case of that authoring flow. Scientific training and evaluation
  authority remains Swift.
- Core ML is the Swift runtime. Model conversion/export normally uses Python
  Core ML Tools and therefore also requires an explicit conversion-only
  exception. ML Program does not support on-device update; the legacy
  updatable neural-network path is limited to eligible convolution or
  fully-connected layers, categorical cross-entropy or MSE, and SGD or Adam.
  Saving updated weights or using inference `MLState` is not Adam moment/step
  restoration.

## Why stock optimizer restoration remained `ABSTAIN`

The blocker is a real public-API gap in the exact pinned dependency, not a
failed serializer and not an inability to restore model weights.

In `mlx-swift` 0.31.3:

- `OptimizerBase<State>` owns a non-public
  `stateStorage: NestedDictionary<String, State>`;
- `innerState()` exposes a flattened `[MLXArray]` view with no supported public
  setter/import, losing the named parameter tree and typed state structure;
- `TupleState` holds Adam/AdamW first and second moments, but its values and
  constructors are not public to a downstream package;
- the optimizer update path is the only supported writer of `stateStorage`;
- `Module.update(parameters:verify:)` is a supported typed model restore API,
  but an optimizer is not an `MLXNN.Module`;
- `_updateInternal` is explicitly documented as an MLX implementation detail
  that outside callers must not depend on.

Prime has already proved that it can:

- run a real maintained AdamW step;
- serialize the resulting model and moment arrays;
- reload and exact-compare their logical tensor bytes in a fresh process;
- restore model parameters through the supported module API.

The historical probe cannot inject the reloaded moments into a fresh stock
optimizer through a
supported typed API. Calling a new optimizer with zeroed moments a “resume”
would be false. Reflection, unsafe offsets, `@testable`, dummy optimizer
steps, `_updateInternal`, or a Prime-written AdamW equation would evade rather
than solve the contract.

The pinned Swift AdamW implementation independently (a) omits bias correction
and (b) stores no Adam step counter. Prime must still checkpoint the external
global step and schedule position. Later mixed-precision work must additionally
bind any master weights and loss-scaler state.

The current probe’s anonymous `slot_####` optimizer artifacts remain
`ABSTAIN` diagnostics. Their inferred flatten order is not a maintained import
contract. Only snapshots produced through a new named export API may become
importable.

Diagonal Hessian estimation is unrelated to this blocker. It is a later
quantization/calibration decision and cannot restore Adam moments.

## Supported solution

### Chosen route and current state

A separate, minimal, pinned Ergentics derivative of `mlx-swift` now implements
API/state transport only: public typed optimizer-state export/import while the
upstream AdamW update arithmetic source remains unchanged. Fork and downstream
tests cover normal import, invalid topology/shape/dtype, nonempty replacement,
alias isolation, API-unused one-step bytes, and exact AdamW `N+1`.

This remains private R&D. The exact fork commit is remotely resolvable from an
authorized private mirror and authenticated cache-empty clone resolution was
observed. The upstream arithmetic remains third-party MIT-licensed code, and
no CI credentialing, public availability, upstream acceptance, or
open-source-release claim is made.

The API design must:

- preserve parameter-path names rather than anonymous slot order;
- represent first and second moments distinctly;
- expose construction/import through the fork’s public downstream types;
- import against the target trainable `ModuleParameters` topology with
  `verify: .all`, before the first optimizer update;
- declare trainable, frozen, and missing-gradient state policy;
- reject replacement of nonempty optimizer state unless an explicit,
  separately tested replacement mode exists;
- detect duplicate serialized keys before dictionary/map materialization, then
  reject missing or extra parameter paths;
- verify tensor shape and dtype;
- bind optimizer type and configuration, including the lack of bias
  correction in this pinned implementation;
- avoid a dummy update before restore;
- define and test snapshot ownership so exported artifacts cannot alias live
  optimizer state and imported state cannot alias mutable loader buffers;
- keep external step, learning-rate schedule, RNG domains, deterministic data
  position, and the declared accumulation-boundary/buffer policy in Prime’s
  checkpoint schema;
- retain the exact fork revision and the small source diff in every receipt.

Fork admission also requires:

- exact upstream base SHA and fork SHA;
- preserved upstream remote plus a declared sync/rebase policy;
- license and third-party notice retention;
- a source-diff allowlist;
- byte-identical `Adam`/`AdamW` arithmetic and configuration regions,
  especially `newState`, `applySingle`, parameter update iteration, and
  decoupled-weight-decay math, except for unavoidable visibility declarations;
- zero-import behavior differential tests against the upstream base;
- an ordinary downstream-package import test, not only `@testable` fork tests;
- exact trajectory differential tests;
- post-export and post-import alias/isolation mutations.

Only after separate human publication authorization and the charter's license,
security, provenance, and release reviews should the same change be proposed
upstream. This plan does not grant that authority. A later upstream release
with an equivalent tested contract may supersede the fork through a pinned
migration gate.

This route is not a hand-written optimizer if and only if those guards show
that it exposes the state seam without duplicating or changing the maintained
update equation.

### Exact N+1 admission gate

The minimum proof is a Swift supervisor plus three freshly exec’d CPU FP32
role processes using fork-pinned `MLXOptimizers.AdamW` with the upstream
`newState`/`applySingle` arithmetic unchanged:

1. **Uninterrupted control:** initialize `theta0`, emit its canonical identity
   and initial RNG-state identity, run step 1, emit `theta1`, `m1`, `v1`, then
   run step 2 and emit `theta2`, `m2`, `v2`, loss, model-output, and gradient
   identities.
2. **Writer:** initialize the same `theta0`, emit the same initial identities,
   run step 1, emit `theta1`, `m1`, `v1`, optimizer configuration, global
   step, and schedule state, publish the checkpoint, then exit.
3. **Restorer:** independently construct and emit the same canonical `theta0`
   and initial RNG identities, deliberately perturb its live model and fresh
   optimizer, read only the published checkpoint, restore before any update,
   immediately re-export state at `N`, run the same step 2, and emit the
   `N+1` state.

The parent observes three distinct worker PIDs and clean exits. Deterministic
initialization is frozen in source and the control/writer must independently
produce exact complete step-1 evidence; the restorer receives only immutable
writer artifacts. The final receipt binds the Release executable, Prime source
snapshot, the complete admitted MLX Swift `Package.swift` plus `Source/**`
tree, reviewed dependency sources, both package/mirror configurations, runtime
metallib, checkpoint files, bounded empty worker output, empty worker
environment, process transcript, exact input/configuration identifiers, and
all declared structural mutation evidence. The separately pinned
`swift-numerics` source tree is not yet receipt-bound, so full transitive
build-source closure remains pending. No restorer role may access writer
in-memory objects.

Use both:

- the current flat `Linear(2,2,bias)` arithmetic smoke fixture; and
- a structural fixture with nested/indexed parameter paths and at least two
  same-shaped tensors, such as two standard `Linear(2,2)` layers in a
  `Sequential`.

Admission requires the writer’s published checkpoint tensors—not merely its
pre-write observations—to match control, writer observations, and the
restorer’s immediate re-export exactly at `N`, then exact logical tensor
equality between control and restorer for every model parameter and both
moments at `N+1`. The integrated gate also binds loss, model outputs, and
gradients. Step 1 is sufficient only when every admitted parameter has a
verified finite, nonzero, distinguishable gradient and finite, nonzero `m` and
`v`. The two batches must be asymmetric and distinct so path, moment, or
stale-state swaps have an actual witness.

The current mechanics receipt executes these fail-closed structural cases:

- missing, extra, and duplicate keys;
- first/second moment swap;
- parameter-name swap;
- shape and dtype mismatch;
- optimizer configuration or source-revision mismatch;
- stale global step or schedule position;
- order permutation;
- checkpoint-byte tamper;
- lazy-array alias mutation;
- initialization seed-domain or input-batch substitution;
- nested/indexed path swap between same-shaped tensors;
- frozen/trainable or missing-gradient policy mutation.

Prime's source, dependency-tree, executable, runtime, output, termination, and
checkpoint live validators provide additional fail-closed boundaries, with
their own unit/source-contract tests. They are not miscounted as independent
scientific mutation families. Phase 3 now source-projects the NeuralKit gate's
functional mutation catalog, guarded loss-statistics formulas, fixed-prompt
runner-up-margin predicate, count-derived triadic label, all-critical rule,
finite-field mechanics, and selected capability thresholds. It still requires
a source-pinned historical forensic replay, a separately fingerprinted
Prime-owned prompt-only fixed-cap/EOS replay, an evaluator disjoint enough for
the intended functional claim, leakage execution, per-family confidence/margin
statistics, explicit dependency-family audit, and real-artifact
fingerprinting. The historical fixture cannot establish target independence:
it consumes target length in output and decision-count construction and copies
the expected completion into the trained prediction. Its exact replay remains
mechanics evidence only.

The frozen Stage-B plan also requires a typed source proof for every
donor-to-Prime adaptation, a lossless independently revalidated copy of the
Stage-A descriptor closure, a complete current clean Prime Swift source
snapshot, required compiled-source/process record schemas, and independent
direct `swift-package describe` authority-subgraph captures of the frozen
Xcode 26.6 build 17F113 byte image.

The closed PrimeCore capture substrate for that SwiftPM observation is
implemented. It launches the fixed executable directly with stdin at EOF and
exactly four non-inherited environment keys: `HOME`, `TMPDIR`,
`CLANG_MODULE_CACHE_PATH`, and `SWIFT_MODULECACHE_PATH`, each rooted in a
fresh per-role scratch namespace. The exact arguments bind scratch, cache,
configuration, and security paths there; disable dependency
cache/prefetch/automatic resolution/netrc/keychain; select
`--manifest-cache none`; and invoke `describe --type json`. They include
neither `--skip-update` nor `--disable-sandbox`, so the manifest sandbox stays
enabled. The repository `.build` tree is unused and non-authoritative.

Each run root is atomically created at `0700` below the trusted Darwin
user-temporary parent. PrimeCore holds the exact `work`, `cache`, `config`,
`security`, `home`, `tmp`, and `module-cache` directories through no-follow,
close-on-exec descriptors on the same local-APFS filesystem as the source.
ACLs and unknown extended attributes are forbidden. `com.apple.provenance` is
permitted only as opaque, non-authoritative bytes bounded to 4,096 bytes.
Optional `com.apple.TextEncoding` is permitted only on the regular file
`work/.lock`, with the exact 15-byte value `utf-8;134217984`; absence is
allowed. Prime performs no recursive path deletion; the namespace remains for
system temporary-directory cleanup.

Exact `0x448c` spawn flags retain direct-PID authority until
`SID == PGID == PID`; the isolated session and dedicated process group then
become lifecycle authority. Three stable executable-descriptor reads bind to
the suspended mapped vnode, and the child cwd binds to the held Prime root.
Bounded local-APFS source admission holds all authoritative file and directory
descriptors, arms receipt-checked `EVFILT_VNODE` guards, and requires exact
inventory/byte/metadata/path stability plus zero events at initial, pre-resume,
and post-reap checkpoints.

The ten-case typed rejection lifecycle covers pre-join direct-PID cleanup,
proven-group cleanup, TERM/KILL escalation, bounded exact-PID `WNOHANG`,
exact-once reap, overflow-through-EOF, drain failure, and no post-reap signal.
Contained and reaped rejection may become internal `ABSTAIN`; an uncontained
child or drain must fail-stop. The post-reap audit scans all seven scratch
subtrees, requires `cache`, `config`, and `security` to remain empty, and
rejects dependency-resolution residue anywhere. It records
`dependencyResolutionPermitted = false` but
`networkDenialEstablished = false`; there is no hermetic, kernel
network-denial, or hostile same-UID-process isolation claim.

External-child evidence and the enclosing describe-capture record are schema
4 at the role-specific capture-V4 paths. The adaptation-proof and
historical-worker aggregate contracts remain V2. The source/execution-binding
and replay-output contracts are V3, the output-path-classification contract ID
is `prime_stage_b_output_path_namespace_classification_v3`, and the fixture
plan is V3/schema 3 at `neural-gate-replay/plan.v3.json`. The adaptation proof
remains `neural-gate-replay/source/adaptation-proof.v2.json`. The nested
held-source mutation-guard observation stays schema 1, the scratch observation
is schema 2, and the raw describe artifact, compiled closure, Release bindings,
historical-worker request/process/result/success records, and terminal receipt
stay V1.

Two initial Release two-role factory canary attempts were contained and reaped
failures: the first exposed terminal mapped-region zero-byte/`EINVAL`
behavior, and the second exposed the exact optional
`com.apple.TextEncoding` value on the regular file `work/.lock`. After those
corrections, the resealed live Release canary passed end to end on the pinned
host. Probe and verifier output was byte-identical: 21,582 bytes with SHA-256
`8a352013c632aa39f2d082bb5ae366f061f48e0572c70a5baea813d4560a4c12`.
This later reseal includes the PrimeCore trusted descriptor-inventory source
and tests; it does not widen the canary's authority.
That pass validates only the secure capture substrate on the pinned host. It
published no durable Stage-B process record or receipt,
`executionImplemented` remains false, and no Stage-B replay, historical
worker, model execution, Metal execution, or product use is implemented or
authorized. Descriptor-bound running Release probe/verifier executables, two
SwiftPM children, two historical workers, and one sealed Swift worker image
remain required Stage-B work. The direct
executable launch path, `proc_pidpath` pathname, and code-sign fields are
non-authoritative telemetry; no Apple trust claim is made. The Stage-A
copy is 35 reachable typed bindings plus its separately pinned terminal
receipt, or 36 copied artifacts total. Separate bounded probe/verifier worker
invocations own the complete
trap-bearing historical arm and publish role-separated evidence; death/reap,
exact role-prefix inventory, terminal semantic recomputation, exact
pre-receipt realized path-and-metadata inventory, and separate typed
artifact-content validation are mandatory. A contained and reaped abnormal
worker outcome poisons the root, accepts no result as evidence, and publishes
no successful-execution record or terminal receipt. An uncontained child or
drain must fail-stop. The
non-`Codable` fixture and inherited traps never enter the authoritative
supervisor processes. Behavior-only reconciliation cannot substitute for
source equivalence.

The Stage-A parent chain is historical by construction. Exact generation and
corpus receipt hashes bind their own clean Release Git/snapshot tuples and
closed source-identity tokens; those parents are not required to equal a later
Stage-A binary's current source seal, and artifact-provided expected digests
are never admitted as authority.

Passage authorizes only an interrupted small canary. A same-device Metal
trajectory gate follows. Immediate imported state at `N` remains exact because
import performs no optimizer arithmetic. If `N+1` requires a preregistered
ULP, tensor, and downstream decision-margin tolerance because of runtime
nondeterminism, the result proves functional trajectory continuity, not exact
resume. Phase 2 remains `ABSTAIN` for resumable/convergence-capped or long-run
authority; a tolerance result may inform only explicitly bounded,
non-resumable calibration.

### What the Prime optimizer-restore probes can do

`Sources/PrimeOptimizerRestoreProbe/PrimeOptimizerRestoreProbeMain.swift` is
the preserved stock-API diagnostic. It truthfully records that anonymous
read-only Adam arrays cannot establish supported resume. It is archival in the
migrated root; a deliberate rerun requires an isolated package pinned to the
upstream `mlx-swift` `0.31.3` dependency rather than rebinding the historical
claim to the typed derivative.

`Sources/PrimeTypedOptimizerRestoreProbe/PrimeTypedOptimizerRestoreProbeMain.swift`
uses the reviewed public typed derivative API. It can:

- supervise fresh control, writer, and restorer roles without a shell;
- generate and reload canonical named model/moment checkpoints;
- bind the complete admitted MLX Swift manifest/source tree, Prime source,
  executable, runtime, configuration, and process transcript;
- verify topology, key, order, shape, dtype, schedule, batch, seed-domain,
  output, and termination invariants;
- run and dispose the declared same-process structural self-checks;
- publish either an exact local R&D receipt or a separate durable `ABSTAIN`.

It does not independently establish scientific validity, model quality,
convergence, safety, or product eligibility. The local patch remains the
pinned-derivative solution and must retain upstream license and review
boundaries.

## Cross-repository composition

### Dependency rule

The training core owns tensor execution and scientific receipts. Product,
pedagogy, verification, and orchestration systems may consume or independently
regrade versioned artifacts, but none may silently become the authority for
optimizer math.

Prefer process/file contracts until a stable second consumer proves a shared
Swift package is warranted. Do not add a package dependency merely to reuse a
small type.

| Repository/module | Implemented value | Prime relationship | Explicit boundary |
| --- | --- | --- | --- |
| `ergentics-prime` | Swift/MLX/Metal mechanics, supervisor, lease, receipts, restore probe | Training and evidence authority | Owns model/training truth |
| PMHNP `prime-runtime` | Swift tokenizer/corpus canaries, scale recommendations, quant/Schur/GPTQ research, historical executors | Read-only migration oracle after source/schema audit | Never a Prime runtime/write target; do not import Python/Core ML bridge or old shell authority |
| PMHNP `neural-kit` | `PrimeAskBrain` load/propose façade plus consumer-side synthetic/research-artifact Verify/Abstain, finite-field/count-label, and mutation regrade | Current PMHNP consumer and research-evaluation-contract donor | Not a Prime training dependency; PMHNP app owns user-visible verify |
| `MasteryKit` | EngineV21, recency/coupled recall, tutoring selection and reusable bench methods | Later product-learning consumer and bench/statistical-pattern donor | Does not orchestrate Prime experiments or own tensors, tokenizer, optimizer, or checkpoint |
| `AgentContractKit` | Triad, Verify/Abstain, mutation, audit and governed probe primitives | Independent verifier; candidate source for a future standalone evidence package | Do not make Prime depend on `agentcraft-app` |
| `agentcraft-app` | Agent subject, governed probes, corpus harvest, optional inherited-model inference | Candidate second consumer, contingent on a real product use case and feasible adapter | Its MLX lane is inference, not first-party training |
| `ergentics-workstation` | Fleet status/doctor/test orchestration and append-only ledgers | Outer observer and bounded command orchestrator | Never owns scientific result publication |
| `ergentics-logic` | Real corpus registry/harvest work plus a Python MLX decoder/trainer/tokenizer | Corpus/schema donor only under the current Swift-first policy | JSONL presence is not oracle independence; Python training is not Prime authority |
| `algebra-app` | Exact SymbolicKit, deterministic generators, harvest and falsifiers | First-party semantic curriculum/oracle donor | Exchange versioned rows/evidence; avoid app dependency |
| `geometry-app` | Exact mechanics families, Metal field/render parity, generators and audits | Semantic donor and custom-kernel test-pattern donor | Geometry Metal is not an LLM/quant kernel |
| `ur-app` PrimeProbe | Swift n=1200 derive/dispose fingerprint methodology | Probe/report-shape donor | Test-only/domain-specific code is not a neural evaluator |

### NeuralKit

NeuralKit is not imported into Prime's tensor core. It already exists
downstream as the PMHNP load/propose inference façade and independent
synthetic/research-artifact regrade. PMHNP's app endpoint retains user-visible
safety and clinical verification. As Prime begins emitting accepted checkpoint
contracts:

1. define a dependency-light `PrimeInferenceContract` with manifest,
   tokenizer, prompt/generation, runtime requirements, and provenance fields;
2. publish and version that artifact contract from Prime; any PMHNP NeuralKit
   consumer adapter is separately authorized PMHNP-side work outside this
   repository and never a Prime runtime dependency;
3. keep abstention, independent regrade, and evidence semantics in
   `PrimeEvaluationContract` or a versioned response/evidence envelope;
4. evaluate AgentCraft or another app only when a real second-consumer use
   case exists;
5. extract a shared package only after both adapters demonstrate the same
   contract.

This preserves the future goal of a unified Ergentics neural capability
without making the current PMHNP consumer the training authority.

### MasteryKit

MasteryKit is not added to the Prime tensor runtime. Its existing EngineV21
and bench layers solve adaptive selection and learning behavior, not neural
optimization.

The appropriate boundary is:

1. Prime publishes a canonical evaluation/experiment receipt.
2. A Prime/Workstation-specific EngineRecommend consumes Prime receipts and
   proposes bounded experiments.
3. Prime independently validates that any proposed action is in the
   preregistered allowed set before executing it.
4. MasteryKit may later consume an accepted Prime capability inside a
   learning/product adapter, or donate bench/statistical patterns. It does not
   orchestrate Prime training.

Historical `ErgenticsNativeModelEngineRecommend` and
`ErgenticsNativeScaleEngineRecommend` are useful Swift donors. They must be
ported with their tests and revised to distinguish:

- a first-party compositional function-learning canary;
- broad-language pretraining;
- profile comparison;
- product promotion.

A missing licensed broad-language corpus must block broad-language training,
but it should not be overloaded to block a properly scoped controlled
micro-language canary. No recommender may infer quality from mechanics alone.

### AgentContractKit

AgentContractKit is not added to Prime today. It is a target inside
`agentcraft-app`, which would make Prime depend on a product/subject
repository.

If the second-consumer test demonstrates real reuse, extract only the
subject-agnostic contracts into a versioned package, tentatively
`ErgenticsEvidenceKit`:

- extract/adapt triadic verdict and evidence-dependency declarations;
- extract/adapt Verify/Abstain outcomes with unavailable distinct from
  observed false;
- extract/adapt mutation-sweep records and independent regrade contracts;
- extract/adapt audit-bundle schemas;
- extract/adapt preregistration contracts from the separate
  `ProbeHarnessKit` target;
- add Prime-required source, executable, input, and artifact bindings where
  the donor does not already provide them.

Prime and AgentCraft may then depend on that package. MasteryKit remains
independent. Extraction must preserve history or bind the donor commit, and
must bind the exact donor files and include differential fixtures proving that
the extracted implementation classifies the existing audit corpus
identically. This is a target design, not a claim that AgentContractKit already
contains every proposed field in one type.

## First-party language and ownership boundary

“First-party weights” means:

- random initialization under the Prime contract;
- no inherited Llama or other base-model parameters;
- training performed by the admitted Prime executor;
- checkpoint provenance binds every corpus, tokenizer, source, configuration,
  and dependency input.

It does not mean every dependency is written by Ergentics. The pinned MLX
packages are third-party open-source Swift dependencies under their recorded
licenses. It also does not erase corpus-license obligations.

The first admitted language task should be an Ergentics-controlled
compositional micro-language, not a claim of broad English fluency:

- deterministic grammar and vocabulary;
- native Swift tokenizer and manifest;
- train/validation/holdout split by unseen combinations, not random duplicate
  rows;
- exact symbolic answers and disjoint verifier families;
- composition, negation, ordering, conservation/reversal, and multi-step
  relations;
- target-independent fixed-cap generation with EOS;
- mutation tests against target-length, digit-count, entity, codebook, and
  template leakage;
- raw prompt and generation preservation.

Inventory, license review, schema freeze, and frozen-fixture reconciliation
for the companion’s existing Swift byte tokenizer, native text corpus,
evaluator, SZ, and mutation contracts should proceed in parallel with the
optimizer fork. Prime implementation and any functional training use remain
blocked until the restore seam passes. Selective migration requires:

- a source inventory and donor-commit binding;
- removal of companion, inherited-model, Python, and shell assumptions;
- independent output reconciliation against frozen donor fixtures;
- explicit ownership/license manifests for every corpus component;
- new Prime-native package and test boundaries.

Algebra, Geometry, AgentCraft, and Ur may contribute exact semantic families
and independent oracle records through versioned artifacts. Logic is a
corpus/schema registry and sink, not automatically an independent oracle:
each admitted Logic family must bind its originating Swift producer/verifier,
license/provenance, and successful replay. JSONL presence alone is not
scientific independence. The app layers should not become Prime dependencies.

Broad functional language requires much more corpus mass and compute than this
controlled canary. A licensed pretraining-corpus manifest, token count,
throughput projection, wall-clock budget, and storage plan remain mandatory
before any broad-language training claim. A locally trained random-init 3B
mechanics pass is not evidence that broad pretraining is feasible on one M5
Max.

## M5 Max execution policy

### Resource control

- Keep the existing process-scoped Metal lease. Only one Prime GPU run may
  hold scientific authority at a time.
- Preserve FP32 as the reference profile. BF16 is a paired
  feasibility/performance arm after restore, not a silent replacement.
- Treat the current 96 GiB MLX setting as a scheduler limit, not a guarantee
  about total process RSS.
- Reserve substantial unified memory for macOS, file caches, staging, and
  failure recovery. Do not target all 128 GB.
- Calibrate sequence, microbatch, and accumulation settings from measurements.
  Do not assume more batch always improves GPU occupancy.
- Record cold and steady-state tokens/second, active wall time, peak process
  memory, MLX memory observations, checkpoint throughput, temperature/power
  context where available, OS/toolchain/runtime versions, and any concurrent
  load exclusions.
- Use Instruments Metal System Trace and supported GPU counters during
  diagnostic calibration. Profiling builds do not publish scientific model
  results.

### Checkpoint durability

- Stream or chunk large tensors; do not require duplicate in-memory
  checkpoint materialization.
- Write into a private staging directory, sync, verify, then publish without
  replacement.
- Bind model, moments, configuration, schedule, RNG domains, corpus cursor,
  shuffle/sampler/prefetch state, tokenizer, source, executable, dependency
  revisions, and runtime resources in one root manifest.
- Publish only at optimizer-step boundaries with accumulation phase zero and
  no pending gradient buffers, or serialize and exact-restore every accumulated
  gradient tensor. Mixed precision also requires overflow and loss-scale state.
- Checkpoint only at deterministic data boundaries unless the full
  shuffle/sampler/prefetch state is restored.
- Retain a known-good previous checkpoint until the successor passes reload
  verification.
- Copy admitted checkpoints and receipts to durable off-device storage before
  they authorize later work.
- Size the local retention policy before 3B runs: each raw FP32 resumable
  checkpoint begins near 31.52 GiB, and safe publication needs additional
  staging capacity.

### Multi-fidelity executor

After exact resume is grounded, implement three distinct arms:

1. **Fixed-token:** short-horizon learning efficiency with identical token
   presentations.
2. **Matched active wall/compute:** equal measured resource comparison,
   calibrated from completed fixed-token evidence.
3. **Convergence-capped:** whether a profile converges within declared bounds;
   this arm is forbidden until exact interruption/resume passes.

Initialization, schedule, data order, and evaluation seed domains must be
explicit independent controls. Use at least three independent confirmation
replicates for a profile-level claim. One root seed that changes all factors
together is not factorization.

## Functional evaluation contract

Every admitted candidate must preserve full raw outputs and pass:

- prompt-only batching and target-independent fixed-cap/EOS generation;
- independent Swift regrade;
- known/base, unseen-combination, held-codebook, refusal, and mutation sets;
- at least 1,000 independently meaningful evaluation cases before a broad
  statistical claim, with the planned exhaustive matrix used when available;
  exhaustive finite domains or preregistered power-derived canary matrices may
  use their justified sizes and do not inherit this as a universal mechanics
  threshold;
- per-family and aggregate confidence intervals;
- rank-margin and decision-margin analysis;
- triadic audit with explicit dependency-family accounting;
- Verify/Abstain gate where unavailable is distinct from observed false;
- SZ fingerprinting and disagreement witnesses;
- mutation-sweep synthesis and replay;
- multi-seed reconciliation;
- issuance-to-completion replay before any RecommendationProvider promotion.

Training-loss decline alone is diagnostic. Mechanics, exact checkpointing,
known-row accuracy, or one favorable seed cannot establish function learning
or product benefit.

For the PMHNP consumer, the PMHNP app’s local EngineV21/engine route remains
authoritative; this is not a reference to MasteryKit’s separate EngineV21
implementation. A Prime/NeuralKit challenger begins in shadow mode and may be
promoted only after the same issuance-to-completion contract demonstrates a
preregistered behavioral gain. The optional upload/improve-model setting is
not required to prove local training mechanics.

## Quantization and custom kernels

Quantization follows an accepted FP reference checkpoint. It does not precede
function learning.

The later sequence is:

1. bind an accepted FP checkpoint and evaluation matrix;
2. run chosen-runtime 8-bit inference/export parity and memory tests, measuring
   the effective compute path rather than inferring it from storage dtype;
3. if size or memory blocks the product, run a small mixed-precision
   sensitivity sweep;
4. evaluate diagonal-Hessian/GPTQ/Schur calibration against the same FP
   reference;
5. consider QAT/distillation only after post-training quantization evidence
   identifies a correctable quality gap;
6. do not repeat an exhaustive 2-bit lane unless a new native arithmetic path,
   representation, or measured hypothesis makes it materially different.

On the installed macOS 26.5 lane, Apple documents 4/8-bit integer TensorOps at
the Metal API level. Native 2-bit integer TensorOps are a macOS 27 addition.
A dtype/storage capability does not prove that the selected MLX or Core ML path
used native accelerated arithmetic; bind the runtime identity and profile the
effective kernel path.

For any custom Metal kernel:

- require profiler evidence that the operation is a material bottleneck;
- freeze exact operation semantics, shapes, dtypes, accumulation behavior, and
  tolerances;
- implement independent scalar and maintained framework references;
- add a third disjoint oracle where practical, such as Accelerate/BNNS or
  MPSGraph;
- validate forward, backward, edge cases, corruption detection, determinism,
  and integration decision margins;
- bind source and metallib bytes;
- demonstrate end-to-end benefit, not only microbenchmark speed.

Record the actual independence boundary: a CPU Accelerate/BNNS oracle can be
compute-backend- and execution-unit-disjoint from the GPU lane while still
sharing the same SoC, unified memory, OS, and host. An MPSGraph GPU oracle is
API/runtime-disjoint at the graph layer but still shares Metal, drivers, and
the same GPU. A separate physical system is required for device-level hardware
independence.

Geometry’s existing Metal field/render families are useful exemplars for this
parity discipline. They are not themselves language or quant kernels.

## Phased implementation and exit criteria

### Phase 0 — freeze the interfaces

Deliver:

- this execution plan;
- a public optimizer-state API proposal;
- a minimal fork-diff specification;
- a Prime checkpoint schema draft;
- a selective donor inventory for tokenizer, corpus, evaluator, SZ, mutations,
  and Prime-specific recommendations.

Exit: all interfaces have explicit ownership, versioning, and negative cases.
No training run.

### Phase 1 — exact optimizer restoration

Deliver:

- pinned `mlx-swift` fork with typed named export/import only;
- upstream proposal;
- Swift supervisor plus three freshly exec’d role processes for the exact CPU
  `N+1` gate;
- complete declared structural tamper/mutation battery;
- updated source and dependency receipts.

Exit: exact model, `m`, and `v` identity at `N` and `N+1`, with the fork’s
public downstream API only and unchanged upstream optimizer arithmetic.

### Phase 2 — exact-profile resumable Metal canary

Deliver:

- complete checkpoint root schema;
- schedule, RNG, shuffle/sampler/prefetch restoration and either
  optimizer-step-boundary-only checkpoints or exact accumulated-gradient
  restoration;
- interruption at a preregistered step and fresh-process continuation;
- paired uninterrupted/restored result;
- optional MPSGraph Adam semantics assay and primitive-level moment comparison,
  recording actual device placement and making no AdamW-equivalence claim.

Exit for resumable authority: the operator-selected existing exact 3B FP32
geometry matches at step 1 and step 2 across uninterrupted and
fresh-process-restored trajectories, and every state-loss mutation is
rejected. This mechanics choice does not overturn the historical schema-6
`ABSTAIN` or authorize the scale. A tolerance-only result is preserved as
`ABSTAIN`; it cannot admit convergence-capped or long training.

### Phase 3 — existing evaluation-contract migration

Deliver:

- dependency-light adapter for the frozen companion/NeuralKit schemas;
- exact native tokenizer and deterministic first-party compositional-corpus
  artifact bindings;
- existing fixed-cap/EOS raw-generation contract;
- exact historical forensic gate replay, explicitly ineligible to establish
  target independence;
- separately fingerprinted Prime-owned prompt-only fixed-cap-64/EOS gate
  replay with construction-level leakage mutations;
- complete raw invariant records, direct and accelerated fingerprints, and
  ordered Verify/Abstain, statistics, count-label, SZ, and mutation
  observations;
- typed donor-to-Prime adaptation proof, copied and revalidated Stage-A
  descriptor evidence, complete Prime source closure, independent SwiftPM
  captures of the frozen Xcode 26.6 `swift-package` image with exact full-file
  hash/metadata, typed descriptor-open → complete checked suspended
  region-query transcript/mapped-vnode join → pre-resume stability →
  `SIGCONT` → raw exact-PID wait/clean reap → post-reap stability evidence, a
  PrimeCore-only non-`Codable` live-capture capability, overflow-free bounded
  streams, required
  six-process/image records, distinct bound Release probe/verifier
  executables, exact pre-receipt path-and-metadata inventory, separate typed
  artifact-content validation, and a sealed bounded historical worker;
- revised Prime EngineRecommend that separates canary, broad-language,
  profile, and product claims.

Exit: both replay arms reconcile under distinct Release probe/verifier
supervisors; the historical arm additionally reconciles two separate bounded
worker invocations. Every arm recomputes all ten gate legs, projected
statistics/margin, count-derived verdict, SZ fingerprints, and its complete
mutation catalog; leakage mutations fail; and every artifact is generated and
graded in Swift. Historical target independence and model capability remain
explicit `ABSTAIN` outcomes. This synthetic mechanics exit still does not prove
checkpoint causality, broad-language function learning, or product authority.

Implementation checkpoint: the closed PrimeCore SwiftPM capture substrate,
held local-APFS source and fresh scratch guards, schema-4 capture envelopes,
and typed rejection lifecycle are unit-tested. After the two contained
discovery failures described above, the resealed live Release two-role canary
passed with the exact 21,582-byte output binding. All role-scoped Stage-B
replay/process/artifact work in this phase remains pending.

### Phase 4 — calibrated M5 Max executor

Deliver:

- FP32 reference calibration;
- paired BF16 feasibility/performance arm;
- measured memory, throughput, checkpoint I/O, and wall projections;
- fixed-token and matched-wall executors;
- three factorized confirmation replicates for any profile comparison.

Exit: the Engine can make one bounded next-action recommendation from measured
evidence without naming a quality winner prematurely.

### Phase 5 — first-party function-learning canary

Deliver:

- small-to-profile-bound training on the controlled micro-language;
- unseen-combination and held-codebook evaluation;
- full raw results and audit battery;
- interrupted/resumed replay under the same contract.

Exit: `GROUNDED` only if preregistered function-learning and multi-seed gates
pass. Otherwise preserve `ABSTAIN` and diagnose capacity, representation,
curriculum, or optimization without moving the goalposts.

### Phase 6 — profile-bound durability and broad-language investment decision

Deliver:

- measured projection from earlier phases;
- a bounded, selected-profile-and-precision checkpoint canary over the full
  parameter topology: streamed writer publication, fresh-process load,
  immediate exact model/moment verification, and one `N+1` continuation;
- for a proposed FP32 3B run, exercise the actual roughly 31.52 GiB raw
  model-plus-moment path rather than extrapolating from the small fixture;
- measured checkpoint staging, publication, reload, and recovery behavior
  without starting a long or multi-seed training run;
- licensed-corpus and tokenizer manifests;
- storage/retention/off-device durability plan;
- explicit time, power, and opportunity-cost budget;
- Engine recommendation comparing local 3B, smaller native profiles, and any
  permitted distributed route.

Exit: the bounded full-profile durability gate passes before human
authorization based on measured feasibility. A mechanics-capable or
small-fixture-resumable 3B profile is not automatic authorization for a long
run.

### Phase 7 — deployment and product challenge

Deliver:

- versioned checkpoint and `PrimeInferenceContract`;
- Core ML device inference parity after an explicit conversion-only tooling
  decision;
- Core AI comparator once a final/supported toolchain is installed and an
  explicit conversion-only tooling decision is admitted;
- Prime-owned, versioned inference/evidence contract plus any demonstrated
  second-consumer contract, with AgentCraft only if a real use case and
  feasible boundary exist;
- a separately authorized PMHNP-side change may adapt NeuralKit and bind an
  accepted Prime challenger to PMHNP's existing shadow store for
  device/offline issuance-to-completion replay; the Prime plan does not
  authorize or perform that companion write.

Exit: consumer-specific promotion only after measured behavioral gain. Prime
research success does not silently change PMHNP release authority.

Any use of the frozen NeuralKit research regrade from Prime must run from a
read-only pinned source in an isolated work root. Inputs and outputs resolve
only through Prime or separately controlled external artifact storage; the
companion checkout is never an output target.

## First implementation slices

The non-training implementation slices now stand as follows:

1. **Optimizer API contract and fork spike — implemented privately**
   - no AdamW arithmetic changes;
   - typed named state export/import;
   - exact upstream/fork diff guards;
   - source/API tests inside the fork and an ordinary downstream import test.
2. **Prime/NeuralKit continuity — Stage A complete; Stage-B execution pending**
   - the companion byte tokenizer, controlled corpus, fixed-cap/EOS evaluator,
     SZ, Verify/Abstain, and mutation inventory is frozen;
   - licenses, provenance, wire schemas, donor fixtures, and the downstream
     NeuralKit authority direction are frozen;
   - the revision/path/SHA resolver and bounded Stage-A source projection are
     implemented with a canonical Release receipt;
   - the dual-arm Stage-B adapter/execution contract is frozen;
   - its closed PrimeCore full-region-transcript SwiftPM capture factory,
     non-`Codable` trust capability, held local-APFS kqueue source guard, and
     typed rejection lifecycle are implemented, with fresh per-role scratch
     namespaces and external-child/describe-capture envelopes at schema 4;
   - after two contained, reaped discovery failures for terminal
     zero-byte/`EINVAL` behavior and exact optional
     `com.apple.TextEncoding`, the resealed live Release two-role
     secure-capture canary passed with byte-identical 21,582-byte
     probe/verifier output, SHA-256
     `8a352013c632aa39f2d082bb5ae366f061f48e0572c70a5baea813d4560a4c12`;
     it published no durable Stage-B process record or receipt and authorizes
     no replay, worker, model, Metal, or product claim;
   - the Prime-owned immutable fixtures, typed worker-artifact recomputation,
     sealed historical worker, role-scoped probe/verifier execution, exact
     path-and-content inventory evidence, separately typed artifact-content
     validation, Stage-B process records, and receipt do not yet exist;
   - `executionImplemented` remains false;
   - Stage B must add no PMHNP runtime dependency and must not write to the
     companion tree;
   - document exclusions, especially Python/Core ML bridge and shell-derived
     authority;
   - do not yet start functional training;
   - this migration/adapter work remains separate from the AdamW continuation
     slice.
3. **Prime exact CPU N+1 gate — private-revision canonical Release proof
   complete**
   - one Swift supervisor plus three fresh role processes;
   - empty child environments, stdin bound to EOF, bounded output, and
     observed termination;
   - complete admitted MLX Swift manifest/source tree plus runtime closure;
   - exact CPU trajectory;
   - 19-case same-process structural self-check and immutable receipt;
   - fresh full evidence root preserved by repository revision `3481ffc` with
     receipt SHA-256
     `fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d`;
   - separate MLX mechanics/security-test processes with a compiled Swift
     resource stager.

The CPU evidence root is now off-device durable. Verify only the four
Prime-owned exact-3B/CPU bindings required by this task; the next execution is
the two-step exact 3B continuation gate. Tokenizer/corpus/evaluator migration
and NeuralKit execution are outside this slice. Do not start a long 3B
training loop, broad corpus ingestion, BF16 profile race, quantization, or
custom kernels in these slices.

## Decision ledger

| Decision | Status | Reason |
| --- | --- | --- |
| MLX Swift remains candidate primary trainer | Accepted | Maintained Swift autodiff, AdamW, and Metal path already execute; resume gates remain |
| Minimal pinned MLX derivative for typed optimizer state | Implemented in an authenticated-clone-resolvable private revision with canonical Prime reissue complete | Public named state transport; pinned optimizer arithmetic source remains unchanged and fork/downstream tests pass |
| Prime-written AdamW | Rejected | Unnecessary hand-roll and parity burden |
| `_updateInternal`, reflection, unsafe restore, or dummy step | Rejected | Unsupported and cannot prove exact resume |
| MPSGraph as full immediate trainer | Deferred | Candidate API-disjoint primitive oracle after semantics assay; excessive whole-model port |
| Core ML/Core AI as trainer | Rejected | Inference/constrained update roles do not satisfy resume contract |
| Custom whole-model Metal trainer | Rejected | Rebuilds autodiff/optimizer/checkpoint stack without evidence |
| NeuralKit dependency in Prime | Rejected for now | Consumer façade must remain downstream |
| New Prime decoder/profile family | Rejected | The exact native 300M/1B/3B family and NeuralKit arc already exist; a new toy profile would split authority |
| MasteryKit dependency in Prime tensor core | Rejected | Recommendation/pedagogy is an outer concern |
| AgentContractKit dependency through AgentCraft | Rejected | Extract a neutral evidence package only after second-consumer proof |
| Python scientific implementation/gate | Rejected under current policy | Swift-first authority remains explicit |
| Audited Python conversion/interchange exception | Deferred per tool | Only where a maintained Apple authoring path lacks Swift; raw artifacts remain subject to independent Swift regrade |
| Workstation as Prime evidence authority | Rejected for current runner | Useful outer observer, but free-form execution lacks the typed binary/runtime/resource boundary Prime evidence requires |
| Open-source Prime code, weights, data, or evidence | Not authorized | Four separate future release decisions; current proprietary license remains controlling |
| Diagonal Hessian in restore phase | Rejected | Quantization concern, unrelated to Adam state |
| First-party controlled micro-language | Required canary | Tests function learning without inherited weights or corpus ambiguity |
| Full-profile checkpoint/reload/N+1 canary | Required before a long 3B run | Small fixtures do not prove full topology, precision, streaming, or recovery behavior |
| Broad-language local 3B run | `ABSTAIN` | Corpus, throughput, wall-clock, and exact resume are not yet grounded |

## Repository and source pointers

### Ergentics

- [Ergentics Prime](https://github.com/Ergentics/ergentics-prime)
- [Prime execution architecture](ARCHITECTURE.md)
- [Preserved PMHNP Metal/quant arc and resolution ledger](PMHNP-METAL-QUANT-ARC-RESOLUTION-2026-07-29.md)
- [Prime optimizer-restore contract](../Sources/PrimeCore/PrimeOptimizerRestoreGate.swift)
- [Prime optimizer-restore executor](../Sources/PrimeOptimizerRestoreProbe/PrimeOptimizerRestoreProbeMain.swift)
- [Prime optimizer-restore replay tests](../Tests/PrimeCoreTests/PrimeOptimizerRestoreGateTests.swift)
- [Prime optimizer-restore source-contract tests](../Tests/PrimeCoreTests/PrimeOptimizerRestoreProbeSourceContractTests.swift)
- [Prime typed optimizer-restore contract](../Sources/PrimeCore/PrimeTypedOptimizerRestoreContract.swift)
- [Prime typed dependency build-input tree](../Sources/PrimeCore/PrimeTypedOptimizerDependencyTree.swift)
- [Prime pinned MLX runtime verifier](../Sources/PrimeCore/PrimePinnedMLXMetallib.swift)
- [Prime Xcode-donor-to-SwiftPM-runtime stager](../Sources/PrimeMLXBundleStage/PrimeMLXBundleStageMain.swift)
- [Prime typed optimizer mechanics](../Sources/PrimeTypedOptimizerRestoreMechanics/PrimeTypedOptimizerRestoreMechanics.swift)
- [Prime typed optimizer supervisor](../Sources/PrimeTypedOptimizerRestoreProbe/PrimeTypedOptimizerRestoreProbeMain.swift)
- [Prime MLX test-resource stager](../Sources/PrimeMLXTestBundleStage/PrimeMLXTestBundleStageMain.swift)
- [Prime isolated typed optimizer mechanics tests](../Tests/PrimeTypedOptimizerRestoreMechanicsValidation/Tests/PrimeTypedOptimizerRestoreMechanicsTests/PrimeTypedOptimizerRestoreMechanicsTests.swift)
- [PMHNP companion](https://github.com/Ergentics/pmhnp-companion-ergentics)
- [MasteryKit](https://github.com/Ergentics/MasteryKit)
- [AgentCraft / AgentContractKit](https://github.com/Ergentics/agentcraft-app)
- [Ergentics Workstation](https://github.com/Ergentics/ergentics-workstation)
- [Ergentics Logic](https://github.com/Ergentics/ergentics-logic)
- [Algebra](https://github.com/Ergentics/algebra-app)
- [Geometry](https://github.com/Ergentics/geometry-app)
- [Ur](https://github.com/Ergentics/ur-app)

PMHNP implementation donors at the audited commit:

- [native Swift canary](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/prime-runtime/Sources/PrimeNativeLanguageSwiftCanary/main.swift)
- [native byte tokenizer](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift)
- [first-party controlled text corpus](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift)
- [native-language Verify/Abstain gate](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift)
- [SZ fingerprint](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/neural-kit/Sources/NeuralKit/ErgenticsNeuralSZFingerprint.swift)
- [Study Ask NeuralKit consumer](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/PMHNPCompanion/PMHNPCompanion/Sources/Engine/StudyAskChatTurn.swift)
- [live recommendation decision](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/PMHNPCompanion/PMHNPCompanion/Sources/Engine/LiveRecommendationDecision.swift)
- [existing outcome shadow store](https://github.com/Ergentics/pmhnp-companion-ergentics/blob/163fc100710ece48119bc25954452d10f6a84f7f/PMHNPCompanion/PMHNPCompanion/Sources/Store/PrimeOutcomeShadowRecord.swift)

Other reusable implementation pointers:

- [MasteryKit content seam](https://github.com/Ergentics/MasteryKit/blob/bf059b96692dc0123a161ac2bdd1f1adef2f0899/Sources/MasteryKit/ContentProvider.swift)
- [MasteryKit tutor loop](https://github.com/Ergentics/MasteryKit/blob/bf059b96692dc0123a161ac2bdd1f1adef2f0899/Sources/MasteryKit/TutorSession.swift)
- [MasteryKit bench sources](https://github.com/Ergentics/MasteryKit/tree/bf059b96692dc0123a161ac2bdd1f1adef2f0899/Sources/MasteryKitBench)
- [AgentContractKit mutation sweep](https://github.com/Ergentics/agentcraft-app/blob/e36e8b0ff607d853572c5d2d440d44b8980b6c3a/Sources/AgentContractKit/MutationSweep.swift)
- [ProbeHarnessKit preregistration/governance](https://github.com/Ergentics/agentcraft-app/blob/e36e8b0ff607d853572c5d2d440d44b8980b6c3a/Sources/ProbeHarnessKit/ProbeHarness.swift)
- [AgentCraft closed loop](https://github.com/Ergentics/agentcraft-app/blob/e36e8b0ff607d853572c5d2d440d44b8980b6c3a/Sources/AgentcraftKit/ClosedLoop.swift)

Audited snapshot commits:

- Prime: `5a8aa46c725b3f3c863ccfbfb5073549fcd18e33`
- PMHNP companion: `163fc100710ece48119bc25954452d10f6a84f7f`
- MasteryKit: `bf059b96692dc0123a161ac2bdd1f1adef2f0899`
- AgentCraft: `e36e8b0ff607d853572c5d2d440d44b8980b6c3a`
- Logic: `97be84b2790b79ce79558d6bade846a532226540`
- Workstation: `5a3f73a582cae2ddc0b5eb9da660f1c02b140be9`
- Algebra: `9bc3fa5710558c1bc4349c7708576c47a69de58b`
- Geometry: `74906b86eeca4e655d31e6912a905ac390215443`
- Ur: `838e00a013969ba92715b5c3044c540336786486`

Prime, PMHNP companion, MasteryKit, and Ur were inspected from local
checkouts. AgentCraft, Logic, Workstation, Algebra, and Geometry were inspected
through authenticated GitHub repository/file reads at the listed commits.
That distinction is part of the evidence record; the list does not imply every
repository was built locally in this audit.

### Apple and MLX primary sources

- [Core AI documentation](https://developer.apple.com/documentation/coreai)
- [Core AI model inference API](https://developer.apple.com/documentation/coreai/aimodel)
- [WWDC26: Meet Core AI](https://developer.apple.com/videos/play/wwdc2026/324/)
- [WWDC26: optimize and customize Core AI models](https://developer.apple.com/videos/play/wwdc2026/325/)
- [Core ML documentation](https://developer.apple.com/documentation/coreml)
- [Core ML on-device update task](https://developer.apple.com/documentation/coreml/mlupdatetask)
- [Core ML updatable-model limits](https://apple.github.io/coremltools/docs-guides/source/updatable-neural-network-classifier-on-mnist-dataset.html)
- [Core ML neural-network versus ML Program capabilities](https://apple.github.io/coremltools/docs-guides/source/comparing-ml-programs-and-neural-networks.html)
- [Core ML optimizer/update schema](https://apple.github.io/coremltools/mlmodel/Format/NeuralNetwork.html)
- [MPSGraph documentation](https://developer.apple.com/documentation/metalperformanceshadersgraph)
- [MPSGraph gradients](https://developer.apple.com/documentation/metalperformanceshadersgraph/mpsgraph/gradients%28of%3Awith%3Aname%3A%29)
- [MPSGraph Adam with explicit state tensors](https://developer.apple.com/documentation/metalperformanceshadersgraph/mpsgraph/adam%28learningrate%3Abeta1%3Abeta2%3Aepsilon%3Abeta1power%3Abeta2power%3Avalues%3Amomentum%3Avelocity%3Amaximumvelocity%3Agradient%3Aname%3A%29)
- [Accelerate BNNS](https://developer.apple.com/documentation/accelerate/bnns-library/)
- [Classic BNNS API deprecations](https://developer.apple.com/documentation/accelerate/classic-bnns-api)
- [ML Compute deprecation](https://developer.apple.com/documentation/mlcompute)
- [Metal capabilities](https://developer.apple.com/metal/capabilities/)
- [Metal 4 machine-learning inference encoder](https://developer.apple.com/documentation/metal/mtl4machinelearningcommandencoder)
- [Metal feature-set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf)
- [Apple silicon machine-learning optimization and profiling](https://developer.apple.com/videos/play/tech-talks/111432/)
- [WWDC26 Metal machine-learning and quantized TensorOps updates](https://developer.apple.com/videos/play/wwdc2026/330/)
- [macOS 27 release notes](https://developer.apple.com/documentation/macos-release-notes/macos-27-release-notes)
- [Apple M5 Pro and M5 Max](https://www.apple.com/newsroom/2026/03/apple-debuts-m5-pro-and-m5-max-to-supercharge-the-most-demanding-pro-workflows/)
- [MLX Swift](https://github.com/ml-explore/mlx-swift)
- [Pinned MLX Swift optimizer source](https://github.com/ml-explore/mlx-swift/blob/61b9e011e09a62b489f6bd647958f1555bdf2896/Source/MLXOptimizers/Optimizers.swift)

## Immediate next decision

The next investment is not another seed, profile, precision, quantization, or
3B run. The exact CPU gate is complete against an authenticated-clone-
resolvable private MLX revision. Preserve the generated receipt in separately
controlled off-device storage, then run one bounded interrupted Metal
continuation canary.

Until the Metal interruption gate passes, Prime’s verdict on resumable
training beyond the tiny CPU mechanics fixtures remains `ABSTAIN`.

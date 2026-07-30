# Prime execution architecture

The implemented authority chain is intentionally narrow:

1. `PrimeCore` defines exact profiles, factorized controls, arm mechanics,
   artifact schemas, mutation contracts, and fail-closed validation.
2. The outer Swift supervisor validates the independently reproduced MLX
   bundle, publishes that exact tree and its own exact executable into the
   descriptor-rooted artifact directory, rejects coverage/profile/sanitizer
   instrumentation in its loaded Mach-O image, and launches the staged
   executable beside the staged bundle without a shell.
3. The staged worker independently resolves and verifies its own sibling
   `mlx-swift_Cmlx.bundle`, rejects alternate loader paths and unsafe
   filesystem metadata, then acquires the Metal lease and performs MLX work
   without Python or shell scientific authority.
4. The worker reverifies its live loader context and bundle after execution.
   The supervisor then separately verifies the staged executable binding,
   target-local alternate loader paths, and exact immutable bundle tree before
   any final GROUNDED or ABSTAIN publication. It does not treat the
   supervisor's own Bundle/framework/cwd state as evidence about the exited
   child.
5. Immutable mechanics receipts bind source, executable, configuration, both
   pinned MLX bundle artifacts, dependency build inputs, factorized seed
   records, device observations, and optimizer state observations. Missing
   observations remain `nil`; they are never rewritten as `false`.

The first-party tokenizer/corpus, historical training receipts, independent
Swift evaluator, fixed-cap/EOS generation contract, triadic audit, SZ
fingerprint, and mutation-sweep contract already exist in the frozen
companion/NeuralKit arc. They are upstream evidence and migration inputs, not
outputs of Prime's allocation probe. PMHNP is a read-only migration oracle,
not Prime's runtime or write target. Prime must verify and materialize its own
immutable fixtures/adapters without rebuilding the scientific contracts or
adding a PMHNP runtime dependency. No accepted trained checkpoint or real
full-pool NeuralKit regrade exists yet.

`PrimeNativeArcContinuityPlan.frozenV1` inventories that no-rebuild boundary
and requires Prime-produced research evidence to flow downstream into
NeuralKit. It remains the frozen historical inventory; the post-Phase-2
resolver adds a new typed gate instead of changing that record. The Prime
tensor core does not import its consumer/regrader.

Phase 2 is complete for its exact narrow mechanics claim. The source-sealed,
random-initialized exact 3B FP32 run matched step 1 and step 2 across
uninterrupted and fresh-process-restored Metal trajectories. Its canonical
receipt SHA-256 is
`2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e`.
The receipt is repository- and off-device-durable; the complete approximately
32 GiB descriptor-backed checkpoint/runtime root remains local-only.

## Current Phase 3 resolver admission

`PrimeNativeContractMigrationPlan.frozenV1` defines the completed
resolver-only transition. It admits exactly eight existing companion
Git blobs, totalling 11,969,097 bytes, at commit
`163fc100710ece48119bc25954452d10f6a84f7f` and tree
`9009daa4f8a07fbd5897e00b9571cef44ec292db`.

- `/usr/bin/git` is directly executed only for read-only revision, tree, and
  raw-object transport; no shell or Python is scientific authority.
- Git receives the fixed, non-inherited
  `prime_git_read_only_fixed_environment_v2` policy, including canonical
  `TMPDIR=/private/tmp`; every admitted invocation must keep stderr empty.
- Swift owns repository identity, revision, tree, path, mode, object type,
  object ID, byte-count, SHA-256, mutation, immutable publication, and receipt
  validation.
- Publication requires a fresh, empty artifact root with exact mode `0700`.
  Prime remote, revision, tree, and tracked/untracked cleanliness are observed
  before the source snapshot and after running-executable capture; both states
  must remain identical and clean.
- Running-executable capture opens the no-follow descriptor and requires its
  device and inode to match the executable vnode loaded in the current
  process, with stable size and timestamps across the read.
- Wrong revision, wrong path, missing artifact, changed bytes, and authority
  expansion must fail before a canonical receipt can validate.
- A separately invoked Swift-only
  `PrimeNativeContractResolutionVerifier` accepts only the artifact root and
  revalidates the persisted receipt and descriptor bindings in a fresh
  process. It has no Git, donor-selection, or execution knobs and is a
  persistence validator, not an independent scientific oracle.
- The source-sealed Release resolver and separate fresh-process persistence
  verifier pass. The repository-durable receipt and evidence note are under
  `artifacts/native-contract-resolution-canonical-2026-07-29/`.

This resolver does not implement an adapter, expand the archived profile
screen, execute companion or NeuralKit code, execute a model, train, quantize,
or authorize product use.

## Separately scoped future admission

- implement the compatibility adapter only after canonical resolver evidence
  validates;
- reuse archived mechanics, factorized-seed, profile-screen, and synthetic
  NeuralKit evidence without wholesale reruns;
- durably bind the resulting checkpoint and evaluation shards;
- execute the frozen 18,432-row fixed-cap/EOS evaluation on a preregistered
  trained checkpoint;
- run the existing independent NeuralKit regrade, statistics, SZ fingerprint,
  triadic audit, and mutation sweep over real artifacts.

This future list is not authorized by the resolver slice. The current task
materializes opaque frozen blobs but does not interpret tokenizer, corpus, or
evaluator contracts and does not execute NeuralKit.

The three fidelity arms are mechanisms, not arbitrary budgets. Wall and
convergence bounds are derived from a completed fixed-token calibration and
must align to optimizer-step and curriculum-block boundaries.

## Optimizer checkpoint admission

Optimizer checkpoint admission is separate from the Metal allocation result.
The stock lane may read and serialize `AdamW.innerState()`, but anonymous
read-only arrays are not a supported restoration schema. Prime does not
reinterpret MLX's public-for-cross-module `_updateInternal` implementation
hook as an application API.

The historical stock-API probe remains an `ABSTAIN`: `mlx-swift` 0.31.3 can
export anonymous optimizer arrays but cannot import named Adam state through a
supported public API. That evidence is preserved rather than reinterpreted.

The typed candidate admission sequence is:

1. bind the exact dependency revision, root and isolated-test mirror
   configurations, the complete admitted MLX Swift `Package.swift` plus
   `Source/**` tree, reviewed state-transport sources, retained MIT license,
   and the complete Prime Swift source snapshot;
2. stage and bind the exact pinned MLX metallib under the frozen typed-probe
   runtime role, because the maintained scheduler requires it even for
   CPU-scoped tensors;
3. launch fresh control, writer, and restorer processes from one immutable
   Release executable with an empty environment, stdin bound to EOF, capped
   asynchronously drained output, observed termination, and no shell;
4. run maintained AdamW on both a flat fixture and a nested fixture with
   same-shaped sibling tensors;
5. publish immutable model and named first/second-moment safetensors, validate
   their ordered manifest before dictionary materialization, then import them
   through the public typed candidate API in the fresh restorer;
6. require exact evaluated FP32 logical bytes for loss, output, gradients,
   model parameters, and both moments at the applicable `N` and `N+1`
   boundaries, with finite nonzero gradients and changing state;
7. run the declared same-process structural proposal/detector/disposal
   self-checks, explicitly claiming no independent scientific oracle;
8. recapture Prime source and reverify the parent runtime, staged runtime,
   dependency tree, every worker record, every checkpoint, and the canonical
   receipt before success.

The minimal typed state-transport derivative is implemented at private
revision `68904d54b72871f26968261ae05d4fbb7c5e3142`; its fork and downstream
mechanics tests pass, and authenticated cache-empty clone resolution from the
authorized private mirror has been observed. The separately pinned
`swift-numerics` source tree is not yet a receipt artifact, so full transitive
build-source closure is not claimed. A canonical Release execution observed
exact flat and nested `N+1` continuation across three fresh worker processes
and disposed all 19 declared structural mutations. The dependency source is
privately remote-resolvable; the generated CPU receipt remains locally
preserved evidence until it is copied to separately controlled off-device
storage.
Convergence-capped, long, 3B, functional, quantization, and product authority
remain unauthorized.

MLX-linked mechanics tests run in a separate XCTest bundle. A compiled Swift
stager places the exact pinned resource into that bundle. PrimeCore's
loader-shadow tests remain in an MLX-free test process, so test convenience
does not weaken the production rule that rejects alternate loader candidates.

## Threat boundary

The staged-image contract covers accidental and persistent mutation through
exact tree, owner, mode, link, ACL, xattr, environment, loader-shadow,
bounded-output, observed-termination, and pre/post hash checks. The same user
must retain write authority over the artifact root so the worker and
supervisor can publish receipts. A malicious concurrent process running as
that same user could attempt a transient swap/load/restore attack; resistance
to that actor is not claimed. Closing that boundary requires a separately
isolated runtime identity or exact loader-return attestation from the
maintained MLX runtime.

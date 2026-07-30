# Prime and NeuralKit arc continuity

Status: Phase 2 exact continuation `PASS`; Phase 3 resolver implementation and
gates in progress

Snapshot date: 2026-07-29

Companion authority: `163fc100710ece48119bc25954452d10f6a84f7f`

Prime baseline: `ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f`

## Decision

The first-party native Prime arc has historical evidence across the PMHNP
companion, `prime-runtime`, NeuralKit, the external Lab, and Ergentics Prime.
PMHNP is not Prime: the pinned companion revision is a read-only migration
oracle and evidence archive, never the runtime or write target for new Prime
work. Prime owns the new native runtime and training evidence in this
repository. A new decoder family, tokenizer, corpus, evaluator, or
VerifyAbstain system would still duplicate proven work and split authority.

The operator-selected bounded continuation uses the existing
`ergentics_prime_native_3b_gqa_v1` geometry, maintained
`MLXLLM.LlamaModel`, and Swift/MLX/Metal execution. The tokenizer and corpus
remain historical inventory and possible future functional inputs; this slice
does not import or execute them. The 3B selection is for two-step
optimizer-restore mechanics only. It does not overturn the historical
schema-6 `ABSTAIN`, authorize the 3B scale, promote a profile, or claim
function learning.

The preserved 3B mechanics receipt binds its factorized seed records,
configuration, executable, source snapshot, dependency source, and metallib.
The continuation contract prohibits pretrained-weight import and requires the
same source-bound random initialization path. Learned weights would be
Ergentics-produced artifacts; the maintained MLX/MLXLLM implementation remains
permissively licensed execution infrastructure.

NeuralKit is not absent. It owns the downstream synthetic/research-artifact
regrade used by this arc: SZ, triadic, mutation, and VerifyAbstain mechanics.
`NeuralKit.PrimeAskBrain` remains the load/propose product façade. PMHNP's app
endpoint retains user-visible safety and clinical verification, and
PMHNP `EngineV21` plus `Recommender.recommend` retain the recommendation and
candidate-selection authority. Prime must not import NeuralKit into its tensor
core, because that would reverse the evidence direction and make a consumer
regrade itself. Integration is a versioned cross-repository artifact contract,
not a dependency on the PMHNP application tree.

`PrimeNativeArcContinuityPlan.frozenV1` is the typed inventory for this
boundary. Its `validate()` method detects in-process inventory drift; it does
not resolve repositories or verify artifact bytes.
`PrimeNativeContractMigrationPlan.frozenV1` is the new, non-overwriting
resolver-only transition. Its implementation and gates are in progress; no
canonical resolver receipt or compatibility replay is claimed yet.

## Authority and migration boundaries

| Responsibility | Canonical owner |
| --- | --- |
| Training, Metal execution, optimizer state, immutable training receipts | `ergentics-prime` |
| New native runtime, Prime-owned contract adapters, and training evidence | `ergentics-prime` |
| Historical model profiles, tokenizer, corpus, generation and evaluation schemas | read-only companion `prime-runtime` at the frozen revision |
| Synthetic/research artifact SZ, triadic, mutation, and VerifyAbstain regrade | companion `neural-kit` |
| Load/propose product façade | `NeuralKit.PrimeAskBrain` |
| User-visible safety and clinical verification | PMHNP app / `PrimeChatModelEndpoint` |
| User-visible recommendation and candidate-selection authority | PMHNP `EngineV21` + `Recommender.recommend` |
| Large generated artifacts | external Lab plus separately controlled durable storage |

## Preserved foundation — do not recreate as missing

- The native tokenizer manifest is Swift-authored, first-party, vocabulary
  512, and requires no inherited vocabulary or training. Its checked-in
  artifact SHA-256 is
  `5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302`.
- The controlled corpus contains 155,648 unique rows and 38,506,757 token
  instances with disjoint training, refusal, validation, combination,
  out-of-distribution, mutation, and abstention pools. Its checked-in artifact
  SHA-256 is
  `fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031`.
- The 10.23M Swift/MLX/Metal mechanics canary proved forward, causal masking,
  backward, AdamW update, finite loss reduction, exact 74-tensor weight
  checkpoint reload, throughput, and memory. It did not prove exact training
  trajectory replay or functional composition.
- The complete 15-trial FP32 300M/1B/3B screen is preserved. It is a valid
  fixed-token, fixed-step diagnostic and remains `ABSTAIN` for winner,
  capacity, convergence, scale authorization, and capability claims.
- NeuralKit's synthetic contract gate passed its tokenizer/corpus, fixed-cap
  generation, EOS, cache-parity, SZ, triadic, malformed-abstention, and
  mutation checks. This proves research-gate mechanics, not a trained model or
  product verification.
- Prime's exact 3B FP32 allocation/forward/backward/AdamW receipt is
  `GROUNDED` only for
  `allocation_forward_backward_adamw_step_only_no_language_capability`.
- Prime's CPU typed AdamW transport proves exact fresh-process `N+1` for flat
  and same-shaped nested fixtures. The fresh reissue from Prime source
  `6465beb184228f2e6ff03f08d5f5e523210e5d7e` has canonical receipt
  SHA-256
  `fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d`.
  Its complete 34 MiB evidence root is repository-durable at
  `3481ffc24f3a81a26197fc8625510cab66e6e29b`.
- Prime's exact random-initialized 3B FP32 Metal continuation passed its
  collision-free synthetic step-1 and step-2 equality contract across three
  fresh workers. Its canonical receipt SHA-256 is
  `2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e`.
  The receipt is repository- and off-device-durable. The complete
  approximately 32 GiB descriptor-backed checkpoint/runtime root remains
  local-only.

These archives are not to be recreated merely because work moved repositories.
Narrow source/dependency compatibility replay is still required when Prime
adapts a frozen schema. These results remain distinct; none may be relabeled
as functional language, accepted checkpoint, quantization, product, clinical,
or broad-language evidence.

## Current slice — frozen companion resolver only

1. Bind the exact companion repository at commit
   `163fc100710ece48119bc25954452d10f6a84f7f` and tree
   `9009daa4f8a07fbd5897e00b9571cef44ec292db`.
2. Resolve exactly the eight companion blobs already frozen by
   `PrimeNativeArcContinuityPlan.frozenV1`, totalling 11,969,097 bytes.
3. Use `/usr/bin/git` only as directly executed, read-only raw-object
   transport. Swift owns revision, tree, path, mode, object type, object ID,
   byte-count, SHA-256, mutation, publication, and receipt authority.
4. Require a fresh, empty mode-`0700` artifact root. Observe Prime remote,
   revision, tree, and complete tracked/untracked cleanliness before source
   snapshotting and after loaded-vnode-bound running-executable capture;
   require identical clean states and stable executable metadata.
5. Fail closed on wrong revision, wrong path, missing artifact, changed bytes,
   or expanded authority before a canonical receipt can validate.
6. In a separately invoked Swift-only fresh process, have
   `PrimeNativeContractResolutionVerifier` rebind and revalidate the persisted
   receipt and descriptor root. It accepts only the artifact root, exposes no
   Git, donor-selection, or execution knobs, and does not claim an independent
   scientific oracle.

Implementation and gates are in progress; no canonical resolver run is
claimed. This slice materializes opaque frozen blobs only. It does not perform
compatibility replay, implement an adapter, expand the archived profile
screen, execute companion or NeuralKit code, execute a model, train, quantize,
change a PMHNP consumer, or authorize product use.

## Fresh CPU reissue diagnostics

The fresh preservation sequence failed closed twice before the exact reissue:

- receipt
  `c8ea425296e2f3c3e65cc1288fa144bf1a96ab8a7c37d4035e4463d823d295d1`
  abstained during source staging because a final Markdown normalization had
  changed the source identity after its embedded seal;
- receipt
  `3951956d313b866c92d09aa311df6c1555c11231868ccb183ad2539a1a1b811a`
  abstained at the control worker when the command sandbox exposed no Metal
  device. A copied worker reproduced MLX's device-enumeration
  `NSRangeException`; the same committed binary passed outside that sandbox.

Those two roots remain local, gitignored diagnostics. They are not AdamW
failures and are not promoted. The unsandboxed reissue is the only new
repository-durable exact receipt.

## Phase 2 continuation boundary and result

The historical native-language executor saves model parameters only. It
records `bounded_diagnostic_no_optimizer_resume` and
`interrupted_trajectory_replay_exact: false`. A second invocation reloads the
trained model for evaluation; it does not restore Adam first/second moments,
schedule position, or the next training cursor.

The bounded operator-selected mechanics gate binds Prime's typed optimizer
transport to the existing exact 3B geometry:

```text
control:  source-bound random-init exact 3B -> step 1 -> step 2
writer:   same random-init exact 3B -> step 1 -> immutable checkpoint
restorer: fresh process -> exact model + Adam m/v + schedule/cursor restore
          -> step 2
```

The gate requires exact logical FP32 bytes at the step-1 checkpoint and after
step 2 for model parameters and both Adam moment families, plus exact loss,
gradient, logits, next-batch identity, schedule position, factorized
seed-domain bindings, executable, dependency source, metallib, and process
evidence. Tolerance cannot promote resumable authority.

The source-sealed run at Prime commit
`7c3989bd0e448eddf3b8b8b87d83c90f518a7d0c` passed this exact declared
boundary. The result is still only a two-step mechanics continuation on an
existing geometry. It is not a long training run, profile promotion, new
language experiment, scale authorization, or new model family.

## Separately scoped follow-on after resolver evidence

1. Implement the dependency-light compatibility adapter only after a canonical
   resolver receipt validates.
2. Copy the complete approximately 32 GiB Phase 2 descriptor root to
   separately controlled off-device storage before any later action consumes
   that checkpoint/runtime root.
3. Bind a physical native checkpoint and evaluation-shard inventory.
4. Execute the already-frozen prompt-only fixed-cap-64/EOS cached and uncached
   regrade on a trained checkpoint.
5. Feed those research artifacts through the existing NeuralKit SZ, triadic,
   mutation, and VerifyAbstain gate for three real seeds using a read-only
   pinned source and isolated work root. Store inputs/outputs only in Prime or
   separately controlled external artifact storage, never in the companion
   checkout.
6. Keep product safety/clinical verification in the PMHNP app and
   recommendation/candidate-selection authority in PMHNP `EngineV21` plus
   `Recommender.recommend`.
7. Only after an unquantized native checkpoint is accepted may quantization,
   including diagonal-Hessian calibration, be reassessed.

No existing companion or Lab result is overwritten, regenerated for
convenience, or converted into a stronger claim by this proceeding.

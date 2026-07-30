# Prime and NeuralKit arc continuity

Status: frozen typed inventory; cross-repository replay pending

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
not resolve repositories or verify artifact bytes. A Swift resolver and
narrow compatibility replay remain future integration gates. They are not
prerequisites for the current AdamW slice beyond its four Prime-owned evidence
bindings.

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

These archives are not to be recreated merely because work moved repositories.
Narrow source/dependency compatibility replay is still required when Prime
adapts a frozen schema. These results remain distinct; none may be relabeled
as functional language, accepted checkpoint, quantization, product, clinical,
or broad-language evidence.

## Current slice — AdamW continuation only

1. Resolve and byte-verify only the Prime-owned exact-3B mechanics receipt,
   execution configuration, source snapshot, and CPU typed-restore receipt.
2. Run the scoped Prime/private-MLX source, dependency, and runtime
   compatibility checks needed by the AdamW continuation.
3. Execute the bounded exact-3B interruption gate below.

Tokenizer/corpus migration, evaluator adapters, NeuralKit execution, PMHNP
consumer changes, broad cross-repository resolution, and functional training
are outside this slice. Historical artifacts stay inventoried so a later task
does not recreate them, but they are not imported now.

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

## Exact unresolved execution boundary

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

This is a two-step mechanics continuation on an existing geometry. It is not a
long training run, profile promotion, new language experiment, scale
authorization, or new model family.

## Separately scoped follow-on after exact continuation

1. Preserve the 3B Metal receipt in separately controlled off-device storage.
2. Bind a physical native checkpoint and evaluation-shard inventory.
3. Execute the already-frozen prompt-only fixed-cap-64/EOS cached and uncached
   regrade on a trained checkpoint.
4. Feed those research artifacts through the existing NeuralKit SZ, triadic,
   mutation, and VerifyAbstain gate for three real seeds using a read-only
   pinned source and isolated work root. Store inputs/outputs only in Prime or
   separately controlled external artifact storage, never in the companion
   checkout.
5. Keep product safety/clinical verification in the PMHNP app and
   recommendation/candidate-selection authority in PMHNP `EngineV21` plus
   `Recommender.recommend`.
6. Only after an unquantized native checkpoint is accepted may quantization,
   including diagonal-Hessian calibration, be reassessed.

No existing companion or Lab result is overwritten, regenerated for
convenience, or converted into a stronger claim by this proceeding.

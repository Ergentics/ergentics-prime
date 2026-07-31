# Prime native NeuralKit gate contract projection

Date: 2026-07-30

Status: source contract implemented; no canonical outcome is claimed here

## Decision

Prime is implementing the bounded Stage-A prerequisite:

`source_pinned_neuralkit_native_language_gate_contract_projection_only`

This is a Prime-owned Swift value contract and two-process persistence gate.
It does not import NeuralKit, add a PMHNP runtime dependency, or copy the
companion gate's broad compile closure into Prime.

The projection binds:

- the exact ten ordered native-language critical-leg identifiers and projected
  meanings;
- all 46 ordered historical mutation identifiers, expected failed legs, and
  raw-prediction mutation classifications;
- the guarded target-token-weighted heldout-loss and effective-sample-size
  formulas;
- the fixed-prompt greedy runner-up-margin replay predicate;
- the exact split counts and selected capability thresholds;
- the native gate's three-point finite-field fingerprint mechanics;
- the generic Verify/Abstain carrier's count-derived label;
- the stronger native rule that all ten critical legs must pass; and
- the historical synthetic fixture and regression-test source identity.

The canonical generation-contract and full-corpus replay receipts are
read-only parents. The new probe validates both complete roots, copies their
evidence losslessly, publishes an incomplete candidate, and cannot publish a
PASS receipt. A distinct Release verifier must recapture the same clean Prime
source, replay the exact projected observation, bind a distinct positive
process identifier, and publish the receipt last.

Process separation is fail-closed and PID-based. A delayed verifier that
receives the probe's recycled numeric PID will abstain even though it is a new
process; this can strand a candidate but cannot create a false PASS.

## Parent truth

| Parent | Path | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| Fixed-cap/EOS generation projection | `prime-native-generation-contract-projection-receipt.v1.json` | 20,010 | `05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b` |
| Full corpus regeneration/regrade | `prime-native-full-corpus-replay-receipt.v1.json` | 2,965 | `88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2` |

Those exact receipt hashes transitively bind each parent's historical Git and
source-snapshot tuple. Stage A also checks the complete tuple directly:

| Parent | Prime revision / tree | Snapshot path | Snapshot bytes / SHA-256 | Source identity |
| --- | --- | --- | --- | --- |
| Generation projection | `28906ef704f4d8727ea0da5e068f6ecbe52330ab` / `c2d07ff9f4a011f7dddf8eb91dcd7278d873b18c` | `generation-contract/prime-swift-source-snapshot.v1.json` | 2,858,617 / `f3b51e4a01f4af2725fff1e1256db7d1378e0d412b6f22d26840ef5f97ff15c7` | `a634994a9aedb2803b61353ffd30f0fcd0f1bad4356ce738f7d150f3cd08d2fb` |
| Full corpus replay | `e17d031af4ec48b644a326646da7bcb8ce24388d` / `3f061674b652cca9cbc2429dc44c85a3aa803665` | `source/prime-swift-source-snapshot.v1.json` | 3,400,268 / `0811b735c3162269907ce44db5321733dc01fc85454f45a8ebb19e0520b02d37` | `d13a817e2918e94972174b78eb1372dd0d4395161fca08b63850e7c2bfbbb08f` |

Both parent source states are clean Release snapshots from
`https://github.com/Ergentics/ergentics-prime.git`. A historical parent is
validated against its compiled closed authority token, not the source identity
of the currently running Stage-A binary and not a digest read back from the
artifact. Prime exposes no public raw-string expectation that could let an
arbitrary internally consistent snapshot nominate itself as authority.

The full-corpus parent regenerated and embedded-regraded all 155,648 rows, but
its semantic evaluator is the same implementation family as the corpus
generator. This projection does not upgrade that result into an independent
scientific oracle.

## Exact donor source boundary

Companion commit:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

| Role | Donor path | Git blob | Bytes | SHA-256 |
| --- | --- | --- | ---: | --- |
| Native gate | `neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift` | `795fff7c458ec68ba4562b6cd1c674fe8de7ffc4` | 368,918 | `c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6` |
| Native tokenizer | `prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift` | `27f5d4f61864499027d3e65516ae4c5cfe1ff5d1` | 21,320 | `9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721` |
| Native corpus | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift` | `b2a087c9410a71f2bc99debade752ff779d7a8a8` | 177,032 | `4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210` |
| Canary/report schema | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift` | `027a25b49dde1acfb4cd8af970e05ecd8241f427` | 216,815 | `8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f` |
| Run configuration | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageRunConfiguration.swift` | `d9141e1c08263f10f06b68acada836dc59a45dc9` | 18,069 | `1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b` |
| Artifact-path safety | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageArtifactPathSafety.swift` | `f7404c905c58e8ff2d51f90ee90dad6cb61cbedc` | 51,514 | `cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c` |
| Profile-trial failure | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageProfileTrialFailure.swift` | `ed64476a8aea3010fe4e6a8b4f799eeb58e64d34` | 16,567 | `42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463` |
| Scale recommendation lineage | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift` | `c3f1e242d07ad3cc7b8e961edab868a895d567df` | 190,002 | `7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea` |
| Verdict-carrier slice | `neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift` | `3866cc1fd1b39829c913376abece2454b0c11624` | 4,659 | `7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c` |
| Regression fixture | `neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift` | `aa87aff21832ebd5c7a6598692139b81ae065e0b` | 165,692 | `266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c` |

The selected native-gate pre-carrier compile closure contains eight explicitly
pinned files totaling 1,060,237 bytes; some are transitive inputs. The generic
verdict carrier is a further compile dependency, but Stage A projects only its
`Witness`, `Outcome`, and `Verdict` slice. Importing that source's complete
closure would add unrelated quant,
GPTQ, deep-cannon, Core ML, and retention code. The historical regression
fixture is pinned separately as the tenth source identity. Stage A therefore
closes the selected native-gate pre-carrier identities while deliberately
not claiming that the generic carrier's broad source closure was imported,
compiled, or executed.

This is a deliberate dependency boundary, not a claim that source hashes alone
replay behavior.

## Projected mechanics

### Verify/Abstain and triadic semantics

The historical native gate creates ten witnesses and uses the generic
`independentThreePlus(k)` label when at least three passing witnesses are
marked independent. The native gate then overrides admission: all ten
critical legs must pass.

That label is count-derived inside one gate implementation. It is not
AgentContractKit's four-tier TriadAudit, does not establish ten organizationally
or algorithmically independent implementations, and is not guarded
statistical-entanglement evidence. The projection encodes those facts as
false, rather than silently promoting the label.

### Statistics

The donor gate recomputes heldout cross-entropy with `target_token_count` row
weights. Stage A records these mechanics without recomputing model losses:

- weighted mean after the donor's positive-total-weight guard:
  `sum(w*x) / sum(w)`;
- effective rows: `sum(w)^2 / max(1, sum(w^2))`;
- unbiased denominator: `sum(w) - sum(w^2)/max(1, sum(w))`;
- squared deviation:
  `sum(w * (x_after - weighted_mean_after)^2)`;
- variance divides that squared deviation by the unbiased denominator when
  positive;
- weighted variance is `0` when that denominator is non-positive;
- standard error:
  `sqrt(weighted_unbiased_variance / max(1, effective_rows))`; and
- equality tolerance:
  `max(1e-12, abs(expected) * 1e-12)`.

The donor also checks one fixed-prompt replay: both greedy runner-up margins
must be finite and positive, the greedy token must remain exact, and twice the
maximum absolute logit delta must remain strictly below the smaller margin;
the recorded maximum delta, greedy token IDs, margins, greedy-exact flag, and
behavioral-exact flag must equal the recomputed values. Its recorded
result-exact flag must equal bitwise equality of the two logit arrays. Stage A
projects that predicate. The donor does not provide the plan's later per-family
confidence-interval, rank-margin, decision-margin, or AgentContractKit
guarded-statistics battery. Stage A records only those broader batteries as
absent.

### Selected capability counts and thresholds

| Split | Rows | Minimum trained exact accuracy | Strictly better than zero-shot |
| --- | ---: | ---: | --- |
| `validation` | 4,096 | selection telemetry only | no |
| `combination_holdout` | 4,096 | 0.80 | yes |
| `ood` | 4,096 | 0.70 | yes |
| `mutation` | 4,096 | 0.80 | yes |
| `abstention` | 2,048 | 1.00 | yes |

Total: 18,432 rows.

This is intentionally a threshold sub-contract, not the complete donor
`capabilityValid` predicate. Stage A does not project that predicate's exact
optimizer-continuation check, complete raw-row/EOS/UTF-8/semantic/support
checks, zero disallowed held-split argmax rule, or N10 recommendation pass.
Those remain inside the pinned donor source and require later materialization
and replay before Prime can claim the full capability leg.

### Finite-field/SZ-shaped fingerprint

The projected direct implementation:

1. sorts records by raw UTF-8 bytes;
2. prefixes each record with its eight-byte big-endian UTF-8 byte count;
3. starts each accumulator at `1`;
4. folds every byte as `accumulator * point + byte + 1`;
5. reduces modulo `2,147,483,647`; and
6. evaluates at `257`, `65,537`, and `1,000,003`.

The probe and verifier execute a five-record raw-Unicode contract vector. Its
residues are:

`[1929142910, 1440393600, 837181579]`

This proves that the projected mechanics execute deterministically and retain
raw-byte distinctions. It is not the historical 59,497-record fingerprint.

## Structural falsifiers

The Stage-A adapter executes and restores twelve projection mutations:

1. source-pin set drift;
2. source-blob identity drift;
3. critical-leg order drift;
4. mutation-catalog truncation;
5. expected-failed-leg drift;
6. finite-field-prime drift;
7. capability-threshold drift;
8. removal of the all-critical admission rule;
9. promotion of the count label into a four-tier audit;
10. promotion of the historical summary into fresh execution;
11. source-resolution overclaim; and
12. Phase-3 authority expansion.

These are Prime projection-integrity falsifiers. They are not the historical
46 semantic mutations and are recorded separately.

## Why Stage A does not claim the historical replay

The checked-in historical receipt and log publish only summary facts:

- `10/10` critical legs;
- `46/46` mutations detected and restored;
- `59,497` invariant records;
- `GROUNDED`; and
- timing summaries.

They do not publish:

- the 59,497 invariant records or their set hash;
- the three fingerprint residues;
- the 46 per-mutation records;
- the three seed reports;
- raw evaluation shards;
- checkpoint bindings; or
- the complete synthetic fixture materials.

Validating the summary again would be envelope validation, not a replay.
Therefore the Stage-A receipt must keep all of these false:

- `source_blob_bytes_resolved_at_execution`;
- `invariant_records_observed`;
- `historical_semantic_mutations_executed`;
- `historical_sz_fingerprint_recomputed`;
- `neural_kit_executed`;
- `agent_contract_kit_four_tier_audit_performed`;
- `guarded_statistical_entanglement_performed`;
- `model_execution_performed`; and
- `phase_three_compatibility_complete`.

## Git checkout mode normalization

Prime's immutable-data contract requires exact mode `0444`. Git preserves
only the executable bit, so six tracked files in the full-corpus parent can
materialize as `0644` after checkout even when their bytes remain exact.
Stage A must not weaken or auto-repair that parent contract.

| Parent-relative path | Bytes | SHA-256 |
| --- | ---: | --- |
| `prime-native-full-corpus-replay-receipt.v1.json` | 2,965 | `88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2` |
| `corpus-replay/probe-candidate.v1.json` | 2,011 | `a9319a41b436075523c4ace314233f69370af1917725e1caea91ed36409a292f` |
| `corpus-replay/probe-observation.v1.json` | 12,909 | `520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1` |
| `corpus-replay/verifier-observation.v1.json` | 12,909 | `520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1` |
| `corpus-replay/prime-native-byte-tokenizer-manifest.v1.json` | 4,790 | `5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302` |
| `corpus-replay/prime-native-text-corpus-manifest.v1.json` | 44,803 | `fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031` |

Before a canonical run, verify each exact path is a current-user-owned,
single-link regular file with the listed byte count and SHA-256. Only then
normalize those six files:

```sh
export PRIME_CORPUS_PARENT="$PWD/artifacts/native-full-corpus-replay-canonical-2026-07-30"
chmod 0444 \
  "$PRIME_CORPUS_PARENT/prime-native-full-corpus-replay-receipt.v1.json" \
  "$PRIME_CORPUS_PARENT/corpus-replay/probe-candidate.v1.json" \
  "$PRIME_CORPUS_PARENT/corpus-replay/probe-observation.v1.json" \
  "$PRIME_CORPUS_PARENT/corpus-replay/verifier-observation.v1.json" \
  "$PRIME_CORPUS_PARENT/corpus-replay/prime-native-byte-tokenizer-manifest.v1.json" \
  "$PRIME_CORPUS_PARENT/corpus-replay/prime-native-text-corpus-manifest.v1.json"
```

Do not change modes recursively. A wrong owner, link count, byte count, hash,
or file type remains `ABSTAIN` and requires reconstruction from frozen
evidence.

## Canonical publication

Build from a committed clean source tree:

```sh
swift build -c release \
  --product PrimeNativeNeuralGateContractProjectionProbe
swift build -c release \
  --product PrimeNativeNeuralGateContractProjectionVerifier
mkdir -m 700 \
  artifacts/native-neural-gate-contract-projection-canonical-2026-07-30
.build/release/PrimeNativeNeuralGateContractProjectionProbe \
  --generation-root "$PWD/artifacts/native-generation-contract-projection-canonical-2026-07-30" \
  --corpus-replay-root "$PWD/artifacts/native-full-corpus-replay-canonical-2026-07-30" \
  --prime-root "$PWD" \
  --artifact-root "$PWD/artifacts/native-neural-gate-contract-projection-canonical-2026-07-30" \
  > /private/tmp/prime-native-neural-gate-probe-summary.v1.json
.build/release/PrimeNativeNeuralGateContractProjectionVerifier \
  --prime-root "$PWD" \
  --artifact-root "$PWD/artifacts/native-neural-gate-contract-projection-canonical-2026-07-30" \
  > /private/tmp/prime-native-neural-gate-verifier-summary.v1.json
```

The two summary captures are outside the empty output root and are not
scientific authority. The verifier exclusively publishes the terminal receipt
after source closure and exact replay; a byte-identical pre-existing receipt
is a conflict, not idempotent success.

The source-hashed document deliberately does not record a result. A canonical
outcome exists only when the artifact root contains a repository-durable
`README.md` that binds the exact source commit, probe/verifier process
identifiers, and receipt SHA-256. That compact tracked subset is historical
evidence, not a self-contained verifiable root: the complete copied parents,
source snapshot, and executables remain required for live receipt validation.

## Next boundary

The receipt recorded the then-current prerequisite name:

`source_pinned_synthetic_fixture_materialization_and_gate_replay`

The forward audit below refines that historical name into two mandatory arms.
The historical arm reconstructs the source-pinned fixture, materializes its
complete invariant-record set, recomputes direct and accelerated fingerprints,
executes every historical semantic mutation, requires exact restoration, and
repeats in a distinct Release verifier. The corrected arm separately executes
prompt-only fixed-cap/EOS construction, its complete records/fingerprints, and
its leakage-mutation catalog. Neither arm may be silently substituted for the
other.

The forward source audit found that the pinned historical regression fixture
constructs zero-shot output length from `target.count`, copies
`row.expectedCompletion` into the trained prediction, and derives executed
decision counts from the prediction or target while declaring the decision
budget target-independent. The historical sweep mutates the declaration; it
does not independently observe that construction. Stage B is therefore frozen
as two arms: an exact historical forensic replay that remains `ABSTAIN` on
target independence, plus a separately named Prime-owned prompt-only
fixed-cap/EOS fixture. The complete boundary is in
`PRIME-NATIVE-NEURAL-GATE-FIXTURE-REPLAY-PLAN-2026-07-30.md`.

That boundary additionally freezes source continuity: every donor-to-Prime
adaptation needs a typed recomputed source proof; the closed Stage-A
descriptor closure must be copied losslessly and independently revalidated;
the 35 reachable parent bindings and separately pinned terminal receipt must
remain distinct in the copy contract; and the current clean Prime source
snapshot plus required compiled-source/process record schemas, independent
direct `swift-package describe` authority-subgraph captures using the frozen
Xcode 26.6 build 17F113 image whose full-file hash and descriptor metadata are
contract-pinned.

The closed PrimeCore external-child capture substrate is implemented. It
launches that exact executable directly with stdin at EOF and an exact
non-inherited environment containing `HOME`, `TMPDIR`,
`CLANG_MODULE_CACHE_PATH`, and `SWIFT_MODULECACHE_PATH`, all inside a fresh
per-role scratch namespace. Exact arguments place the scratch, cache,
configuration, and security paths there; disable dependency
cache/prefetch/automatic resolution/netrc/keychain; use
`--manifest-cache none`; and run `describe --type json`. They do not include
`--skip-update` or `--disable-sandbox`, so the SwiftPM manifest sandbox remains
enabled. The repository `.build` tree is neither used nor authoritative.

The scratch root is atomically created at `0700` below Darwin's trusted
user-temporary parent and holds exactly seven no-follow, close-on-exec
directory descriptors: `work`, `cache`, `config`, `security`, `home`, `tmp`,
and `module-cache`. It must share the source's exact local-APFS filesystem
identity and have no ACL. Unknown extended attributes are rejected.
`com.apple.provenance` is permitted only as opaque, non-authoritative bytes
bounded to 4,096 bytes. Optional `com.apple.TextEncoding` is permitted only on
the regular file `work/.lock`, with the exact 15-byte value
`utf-8;134217984`; absence is allowed. Prime does no recursive path cleanup;
it closes the held authority and leaves the namespace to system
temporary-directory cleanup.

Spawn flags are exactly `0x448c`; direct-PID authority is retained until
`SID == PGID == PID`, and only then does the isolated session and dedicated
process group become lifecycle authority. The capture binds the held
executable descriptor to the suspended mapped vnode, the held Prime root to
the child cwd, and stable descriptor bytes at pre-spawn, pre-resume, and
post-reap checkpoints.

The source root must pass bounded current-owner local-APFS admission. PrimeCore
holds all authoritative source file and directory descriptors, arms
receipt-checked `EVFILT_VNODE` guards, and requires exact inventories, bytes,
metadata, path/vnode rejoins, and zero source events at initial, pre-resume,
and post-reap checkpoints. The ten-case typed rejection lifecycle proves
bounded exact-PID `WNOHANG`, exact-once reap, overflow-through-EOF, drain
handling, and no post-reap signals. Contained and reaped rejection may
abstain; an uncontained child or drain must fail-stop. Its post-reap audit
walks all seven scratch subtrees, requires `cache`, `config`, and `security` to
remain empty, and rejects dependency-resolution residue anywhere. The
contract records `dependencyResolutionPermitted = false` and
`networkDenialEstablished = false`; it claims no hermeticity, OS-level network
denial, or hostile same-UID-process isolation. The Darwin user-temporary parent
is an explicit trust prerequisite.

External-child evidence and the enclosing describe-capture record are schema
4 at the role-specific capture-V4 paths. The adaptation-proof and
historical-worker aggregate contracts remain V2. The source/execution-binding
and replay-output contracts are V3, the output-path-classification contract ID
is `prime_stage_b_output_path_namespace_classification_v3`, and the fixture
plan is V3/schema 3 at `neural-gate-replay/plan.v3.json`; the adaptation proof
remains at `neural-gate-replay/source/adaptation-proof.v2.json`. The nested
held-source mutation-guard observation stays schema 1, the scratch observation
is schema 2, and the raw describe artifact, compiled closure, Release bindings,
historical-worker request/process/result/success records, and terminal receipt
stay V1. Focused
Swift tests establish lifecycle and scratch mechanics, not a live factory
proof. Two initial Release two-role factory canary attempts were contained and
reaped failures: the first exposed terminal mapped-region zero-byte/`EINVAL`
behavior, and the second exposed the exact optional
`com.apple.TextEncoding` value on the regular file `work/.lock`. After those
corrections, the resealed live Release two-role secure-capture canary passed end
to end on the pinned host with byte-identical probe/verifier output: 22,022
bytes, SHA-256
`f5f2d2ebf4409da26164c1980bcece14c60db6937f664adb96e4e57693580b86`.
This current reseal includes the PrimeCore trusted descriptor-inventory
substrate and the pure Stage-B replay-mechanics foundation; it does not widen
the canary's authority.
That pass validates only the secure capture substrate on the pinned host. It
published no durable Stage-B process record or receipt,
`executionImplemented` remains false, and no Stage-B replay, historical
worker, model execution, Metal execution, or product use is implemented or
authorized. A validated six-process topology,
distinct running Release probe/verifier executables, and every semantic
Stage-B artifact remain future work. The direct executable launch path,
`proc_pidpath` pathname, and code-sign fields are non-authoritative telemetry;
no Apple trust claim is made. A sealed Swift worker owns the complete
trap-bearing historical arm under separate bounded probe and verifier
invocations; death/reap, exact role-prefix inventory, terminal decoding and
semantic recomputation, exact pre-receipt realized path-and-metadata inventory,
and separate typed artifact-content validation are mandatory. Contained and
reaped abnormal worker outcomes poison the root, accept no result as evidence,
and publish no successful-execution record or terminal receipt; an uncontained
child or drain must fail-stop. The fixture never crosses that process
boundary. A successful
behavioral replay alone cannot establish adapter equivalence.

Even Stage B remains a synthetic same-implementation mechanics replay. Real
profile admission is a later Stage C and requires physical three-seed reports,
fixed-cap/EOS output shards, checkpoint, executor, recommender, configuration,
Metal-library, training-stage, tokenizer, corpus, and package-lock bindings.

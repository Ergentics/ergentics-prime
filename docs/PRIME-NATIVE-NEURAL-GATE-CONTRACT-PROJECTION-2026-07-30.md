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
repeats in a distinct Release verifier. In a future source-bound Stage-B run,
the corrected arm must separately execute prompt-only fixed-cap/EOS
construction, its complete records/fingerprints, and its leakage-mutation
catalog. The current pure corrected calculators and source-plan-bound
symbolic solver are not that execution.
Neither arm may be silently substituted for the other.

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
historical-worker aggregate contracts remain V2. Corrected execution admission
is V3. The source/execution-binding contract is V6; V5 remains the historical
thirteen-target prompt-solver source contract and V4 the earlier twelve-target
fixture-authority binding. The replay-output contract remains V3, the
output-path-classification contract ID is
`prime_stage_b_output_path_namespace_classification_v3`, and the fixture plan
is V5/schema 5 with canonical content SHA-256
`c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b`.
V4/schema 4 remains the historical pre-sidecar plan and V3/schema 3 the
pre-solver plan. The unchanged V3 replay-output namespace still
reserves `neural-gate-replay/plan.v3.json`, and no V4 or V5 execution artifact
is claimed.
The adaptation proof remains at
`neural-gate-replay/source/adaptation-proof.v2.json`. The nested held-source
mutation-guard observation stays schema 1, the scratch observation is schema
2, and the raw describe artifact, compiled closure, Release bindings,
historical-worker request/process/result/success records, and terminal receipt
stay V1. Focused
Swift tests establish lifecycle and scratch mechanics, not a live factory
proof. Two initial Release two-role factory canary attempts were contained and
reaped failures: the first exposed terminal mapped-region zero-byte/`EINVAL`
behavior, and the second exposed the exact optional
`com.apple.TextEncoding` value on the regular file `work/.lock`. After those
corrections, the live Release two-role secure-capture canary was rerun after
the fixture-authority twelve-target source freeze and passed end to end on the
pinned host with byte-identical probe/verifier output: 23,207 bytes, SHA-256
`f2204bbae8623c35fdf7357c6b0aa2a585e9071f22556edbe6ce6e7cfccf04d5`.
That is the preceding twelve-target fixture-authority reseal. After the
isolated thirteenth prompt-solver target was added, the same Release canary was
rerun on the pinned host and passed with byte-identical probe/verifier output:
23,791 bytes, SHA-256
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
This is the last accepted historical topology-V3 actual-package secure-capture
reseal.
It validates only the secure-capture substrate on the pinned host. It is not
V6/V7 selected-source execution-graph proof; it does not issue source binding
V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
It predates topology V4 and is not reused as V4 package-capture evidence.

After the complete topology-V4 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 32,735 bytes,
SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is the last accepted historical topology-V4 actual-package secure-capture
reseal.
After the additive topology-V5 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 36,047 bytes,
SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
The V4 bytes were not reused as V5 evidence.
It validates only the secure-capture substrate on the pinned host and does not
establish V6/V7 selected-source graph reconciliation, source binding V7,
execution, evaluation, publication, receipt, reproducible-build,
network-denial, Metal, scientific, or product authority.

The historical held-root/crosswalk boundary is additive topology V5,
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`; its canonical
SHA-256 is
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`.
Historical topology V4 remains exact at SHA-256
`8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`.
V5 preserves topology V1/V2/V3/V4 and adds the retained exact 41-file held-root
capture plus a separate trap-bearing 18,432-row source-derived keyed
prompt/target crosswalk without changing pure composition V1. The focused
integration passed in 300.125 seconds. Semantic namespace V4,
canonical SHA-256
`60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`,
is an incomplete non-authorizing overlay on historical output classification
V3, not an execution artifact or receipt. See
`PRIME-NATIVE-NEURAL-GATE-TYPED-ARTIFACT-TRANSPORT-2026-07-31.md` and
`PRIME-NATIVE-NEURAL-GATE-REPLAY-COMPOSITION-2026-07-31.md`, and
`PRIME-NATIVE-NEURAL-GATE-DESCRIPTOR-SOURCE-BINDING-2026-07-31.md`. Historical
topology V6 has canonical SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`;
its exact authority ceiling is recorded in
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`.
Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
has canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`;
its exact authority ceiling is recorded in
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.
The V5 historical authority ceiling remains in
`PRIME-NATIVE-NEURAL-GATE-HELD-ROOT-CROSSWALK-AUTHORITY-2026-07-31.md`.

The corrected mechanics are now split. The raw target owns prompt-only input,
replicate-scoped seed context, fixed-cap/EOS full-512-logit decisions, and
structural raw execution. The one-way evaluation target owns correlation,
completion feasibility, exact regrade, weighted statistics, fixed-prompt
margins, capability thresholds, count-derived verdict composition, and
fifteen ordered mutation observations over caller-provided values. Prompt
solver and logit sidecar depend only on raw mechanics. Full logits remain
locally digest-bound; Foundation/Double probability values are
non-evidentiary and cannot stand in for the frozen source-pinned Float32
log-softmax. The evaluation target does not execute or detect mutations,
establish semantic/capability truth, derive a solver, or authorize
execution/receipt.
An isolated offline Swift fixture-authority target now exhaustively
recomputes the globally UTF-8-row-ID-ordered 18,432-row corrected fixture from
the byte-exact source-pinned tokenizer/corpus transplant. Its source-plan
fixture identity is
`c1f29a0d1067a4bce5541ee5100044276ccc16c63e57501b509fb3126fcd29a4`;
the canonical observation is
`a30c7fe39157ce6e0de2e0783a8af8807c4a1b02b309a144ba3272a6cc6d931d`.
The historical regression fixture is lineage-only in this derivation. Parent
receipt identities are complete and type-decoded in tests, but the derivation
reads no receipt bytes and publishes no independent fixture receipt.

The historical source-plan slice also added the isolated
`PrimeNativeNeuralGatePromptSolver` target. Its sole local dependency is
`PrimeNativeNeuralGateCorrectedMechanics`; its concrete replicate-scoped type
receives prompt tokens only and creates fresh local state per row. It is a
trap-free Swift adaptation, not a byte-exact transplant, of the Ergentics,
LLC-owned corpus solver pinned above at revision
`163fc100710ece48119bc25954452d10f6a84f7f`, tree
`9009daa4f8a07fbd5897e00b9571cef44ec292db`, path
`prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift`,
blob `b2a087c9410a71f2bc99debade752ff779d7a8a8`, 177,032 bytes,
SHA-256
`4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210`,
under `LicenseRef-Ergentics-Proprietary`. Its repository test contract is
observed across all 18,432 selected rows, the three admitted replicate
contexts, and their seed-keyed permutations, with exact structural-logit and
strict malformed-grammar gates. That remains symbolic/synthetic mechanics—not
model execution, an independent scientific oracle, a durable solver receipt,
Metal authority, or product authority.
Corrected admission V3, source binding V6, and fixture plan V5/schema 5 now
bind the bounded lossless logit-sidecar codec and maintained MLX Float32
log-softmax operation as source contracts. Historical topology V4 implements
the descriptor-bound sidecar adapter; topology V5 adds the held-root capture
and keyed crosswalk. `executionImplemented` remains false: no process delivery,
model execution, Stage-B Metal authority, worker/process record, terminal
receipt, independent scientific oracle, or product authority has been
established.

The earlier corrected request exposed `row_id`, whose corpus value encodes
split and semantic family; that metadata is now outer correlation only.
Row-selected seeds, retained state, and invocation order are also metadata
channels, so one seed per replicate, fresh per-row state, and row-permutation
trace identity are mandatory. The planned shared donor topology also exposed
trap-bearing historical code to corrected supervisors. The implemented
package now splits raw execution from evaluation/regrade authority, while
historical trap-disjoint topology V5 preserves V1/V2/V3/V4 and supersedes the
unsafe future routing without issuing source binding V7. The capture/crosswalk result
establishes one exact 41-file capture epoch, durable origin only for those
captured bytes, corrected fixture identity, exact source join, independent
prompt/target association, and outer expected-completion binding. It does not
establish prompt-content target independence, process delivery, model
execution, evaluation/verdict publication, mechanics `PASS`, receipt, science,
or product authority. Historical topology V6 adds the exact ten-role
process/evaluation/receipt ownership declarations, target-free schedule
construction, and a real supervisor-only retained-capture binding wrapper.
Current topology V7 adds exact-count bounded `PRIMEIRM1` raw/outer stream
admission, typed common/branch/twenty-path artifact-reference declarations,
six four-part Release worker-source declarations, and a retained-capture
reference adapter. Aggregate candidates remain non-`Decodable`; real common/
branch scalar references are supervisor-derived and non-authorizing, while
realized worker-source and role-artifact content references remain absent. The
wrapper observes no delivery. Topology
V7 is distinct from source/execution-binding V7, which remains unissued. The
exact next prerequisite is
`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`.

The repository-test checkpoint passed pure sidecar mechanics 6/6. The
source-pinned MLX validation package remains outside the MLX-free
`PrimeCoreTests` bundle and passed 9/9 in 193.005 seconds against the exact
3,817,916-byte metallib, SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`,
with structural three-vector digest
`8dca965dbb3057c79d268435b23e58ecab8e77ecfe745b6a434cc1b2a852d98a`.
Those nine cases comprise seven focused MLX mechanics cases and two exhaustive
integration cases; the main exhaustive case took 192.889 seconds and covered
18,432 rows and 232,638 decisions per seed for `1618`, `2718`, and `3141`,
with 44 unique complete 512-value vectors, a 90,136-byte dictionary, a
2,070,912-byte aggregate, bit-exact reconstruction, and stable MLX digest
`db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02`.
Candidate vectors are capped at 1,179,648 and unique vectors at 65,536. This is
repository mechanics only, not durable Stage-B evidence. The separate V6
focused contract/topology checkpoint passed 48/48, and the real retained-root
projection/binding test passed 1/1 across 18,432 rows in 363.326 seconds. These
are focused results, not a complete-suite claim.

That pass validates only the secure capture substrate on the pinned host. It
published no durable Stage-B process record or receipt,
`executionImplemented` remains false, and no Stage-B replay, historical
worker, model execution, Metal execution, or product use is implemented or
authorized. The historical V5 six-process count remains historical and is
superseded by V6's exact symmetric ten-role roster. Distinct
running Release probe/verifier executables and every semantic Stage-B
artifact remain future work. The direct executable launch path,
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

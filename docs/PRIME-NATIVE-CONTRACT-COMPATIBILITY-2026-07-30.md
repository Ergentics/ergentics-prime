# Prime native contract compatibility adapter

Status: implementation plan and bounded claim surface. Canonical run status is
recorded only in the artifact evidence note named below.

Plan date: 2026-07-30

## Decision

Prime now has a narrow Swift compatibility adapter for the exact native
contract-resolution evidence accepted in the preceding slice. The adapter
does not reopen the companion repository and does not reinterpret repository
history. It accepts only the descriptor-backed resolution root produced by
the frozen resolver, revalidates the complete parent receipt, and publishes a
typed Prime projection into a distinct fresh artifact root.

The adapter's claim scope is exactly:

`frozen_tokenizer_corpus_evaluation_and_synthetic_regrade_envelope_compatibility_only`

This is narrower than Phase 3 completion. The current artifact inventory does
not expose the fixed-cap/EOS generation wire contract as a standalone blob,
and the corpus manifest explicitly states that full rows are not embedded.
Consequently, this slice cannot honestly claim generation-behavior
compatibility, full corpus replay, or independent semantic regrade.

This source-hashed document does not claim a canonical adapter result. The
`PASS` or `ABSTAIN` result, receipt SHA-256, adapter source revision, and
fresh-process verifier result must be recorded after the clean Release
workflow only in
`artifacts/native-resolved-contract-adapter-canonical-2026-07-30/README.md`.
If that repository-durable evidence note is absent, the canonical result is
pending.

## Exact parent chain

The adapter freezes the following parent identities:

| Binding | Exact value |
| --- | --- |
| Phase 2 exact-3B continuation receipt SHA-256 | `2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e` |
| Parent resolver receipt path | `prime-native-contract-resolution-receipt.v1.json` |
| Parent resolver receipt bytes | `27,035` |
| Parent resolver receipt SHA-256 | `d8e8caefb9f0c340a7418befeca4966daf178894164eaaebdfae7b565928c8f4` |
| Parent resolver source revision | `7c7b0496a94fe776df2e542df7413fd4a8bcf250` |
| Parent resolver source identity SHA-256 | `51efb053b6c6ac4e338020842fab6a25715bf57076c0d62a3f8ea39c6a3ea05a` |
| Companion revision | `163fc100710ece48119bc25954452d10f6a84f7f` |
| Companion tree | `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Parent artifact count | `8` |
| Parent artifact bytes | `11,969,097` |

The selected semantic inputs retain separate artifact and internal-content
hashes:

| Input | Resolved artifact SHA-256 | Internal content SHA-256 |
| --- | --- | --- |
| Native byte tokenizer manifest | `5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302` | `f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7` |
| Native text corpus manifest | `fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031` | `7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7` |
| Synthetic Verify/Abstain receipt | `91c6fd5f26492357cad938dcab1926356bc33914cc281c5ccd2297f1759b0b0a` | Not a self-hashed manifest |

The adapter must validate the outer artifact binding and the internal
manifest content hash independently. Substituting one for the other is
contract drift.

## Implemented positive scope

Subject to a future successful Release run, the adapter is designed to record
these bounded positives:

- the exact parent resolution receipt and all eight parent artifacts validate
  in the input descriptor root;
- all parent artifacts, the parent receipt, the parent resolver executable,
  and the parent resolver source snapshot are copied losslessly into the new
  descriptor root;
- the tokenizer manifest matches the fixed first-party NFC UTF-8 byte profile;
- tokenizer mechanics replay through both `String.UTF8View` and
  `Foundation.Data` paths for the seven frozen probes;
- tokenizer vocabulary size, byte offset, special tokens, probe ordering,
  probe hashes, and internal manifest hash match exactly;
- the corpus manifest matches the first-party, research-only generator,
  tokenizer linkage, eight declared split counts, leakage predicates, refusal
  holdout predicates, falsifiers, token accounting, and internal content
  hash;
- the evaluation-record projection matches the declared result fields,
  evaluation splits, seeds `1618`, `2718`, and `3141`, explicit JSON-null
  mutation encoding, and triadic witness names;
- a prompt-only generation boundary exists in Prime without target,
  completion, evaluation-row, corpus-row, mutation, abstention, semantic, or
  verifier material;
- the historical synthetic Verify/Abstain envelope matches its exact
  classification, record count, mutation count, and explicit non-admission
  flags.

The historical synthetic envelope contains the word `GROUNDED`, but only for
`synthetic_first_party_contract_and_mutation_verification_only`. The same
artifact records `current_admission_effect: false`, no schema-4 profile
execution, no profile artifacts, no accepted checkpoint, and no functional,
broad-language, product, quantization, or diagonal-Hessian authority. The
adapter preserves that boundary.

The new adapter-owned output paths are:

- `adapter/prime-native-resolved-contract-projection.v1.json`;
- `adapter/prime-swift-source-snapshot.v1.json`;
- `adapter/PrimeNativeResolvedContractAdapterProbe.executable`;
- `prime-native-resolved-contract-adapter-receipt.v1.json`.

The adapter receipt is published last.

## Git checkout mode normalization

The canonical resolver originally published immutable data with mode `0444`.
Git preserves only the executable bit in its tree, so checking out the tracked
parent receipt can materialize it as `0644`. That happened in the current lab
checkout: the receipt bytes and SHA-256 remained exact, but the fresh-process
resolver verifier correctly rejected the writable file.

This is an environment normalization issue, not permission to weaken the
artifact contract.

The adapter and verifier must continue requiring:

- an owner-controlled root with exact mode `0700`;
- an owned, single-link, regular, non-symlink receipt;
- exact receipt byte count and SHA-256;
- immutable-data mode `0444`.

Before a canonical adapter run, inspect the exact parent receipt:

```zsh
export PRIME_REPO_ROOT=/Users/ergentics/Documents/Codex/2026-07-26/you-re-in-a-clean-recoverable/work/ergentics-prime
export PRIME_RESOLUTION_ROOT=/Users/ergentics/Documents/Codex/2026-07-26/you-re-in-a-clean-recoverable/work/ergentics-prime/artifacts/native-contract-resolution-canonical-2026-07-29
stat -f '%Sp %u %l %z %N' "$PRIME_RESOLUTION_ROOT/prime-native-contract-resolution-receipt.v1.json"
shasum -a 256 "$PRIME_RESOLUTION_ROOT/prime-native-contract-resolution-receipt.v1.json"
```

Only if the path is exact, the file is owned by the current user, the link
count is `1`, the byte count is `27035`, and the SHA-256 is exactly
`d8e8caefb9f0c340a7418befeca4966daf178894164eaaebdfae7b565928c8f4`,
repair that one file:

```zsh
chmod 0444 "$PRIME_RESOLUTION_ROOT/prime-native-contract-resolution-receipt.v1.json"
stat -f '%Sp %u %l %z %N' "$PRIME_RESOLUTION_ROOT/prime-native-contract-resolution-receipt.v1.json"
"$PRIME_REPO_ROOT/.build/release/PrimeNativeContractResolutionVerifier" --artifact-root "$PRIME_RESOLUTION_ROOT"
```

Do not change modes recursively. Do not repair a symlink, hard link,
wrong-owner file, wrong-size file, or wrong-hash file. Do not make the adapter
auto-repair its input. Do not admit `0644` as immutable evidence. If any
precondition differs, preserve the failure and reconstruct the resolution
root from its frozen source instead.

## Release probe and fresh verifier

These commands are the pending canonical workflow. They must be run only
after the implementation, tests, source-seal digest, and documentation are
committed and the Prime source tree is clean.

Build both Swift executables:

```zsh
cd "$PRIME_REPO_ROOT"
git status --porcelain=v1 --untracked-files=all
env CLANG_MODULE_CACHE_PATH="$PRIME_REPO_ROOT/.build/codex-release-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$PRIME_REPO_ROOT/.build/codex-release-swiftpm-cache" swift build --disable-sandbox -c release --product PrimeNativeResolvedContractAdapterProbe
env CLANG_MODULE_CACHE_PATH="$PRIME_REPO_ROOT/.build/codex-release-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$PRIME_REPO_ROOT/.build/codex-release-swiftpm-cache" swift build --disable-sandbox -c release --product PrimeNativeResolvedContractAdapterVerifier
```

Choose a new, unused, explicit output root under Prime's ignored `artifacts/`
directory. Never reuse a root after either success or failure. The final
source-sealed run uses the evidence path below; earlier calibration attempts
must use differently named candidate roots.

```zsh
export PRIME_ADAPTER_ROOT=/Users/ergentics/Documents/Codex/2026-07-26/you-re-in-a-clean-recoverable/work/ergentics-prime/artifacts/native-resolved-contract-adapter-canonical-2026-07-30
mkdir "$PRIME_ADAPTER_ROOT"
chmod 0700 "$PRIME_ADAPTER_ROOT"
"$PRIME_REPO_ROOT/.build/release/PrimeNativeResolvedContractAdapterProbe" --resolution-root "$PRIME_RESOLUTION_ROOT" --prime-root "$PRIME_REPO_ROOT" --artifact-root "$PRIME_ADAPTER_ROOT"
"$PRIME_REPO_ROOT/.build/release/PrimeNativeResolvedContractAdapterVerifier" --artifact-root "$PRIME_ADAPTER_ROOT"
shasum -a 256 "$PRIME_ADAPTER_ROOT/prime-native-resolved-contract-adapter-receipt.v1.json"
```

The probe requires both the resolution root and output root to be absolute,
canonical, disjoint descendants of the Prime `artifacts/` directory. The
output root must be empty and exactly `0700`. Prime source identity is observed
before and after loaded-executable capture and must remain clean and exact.

The verifier is a separate fresh Swift process. It accepts only
`--artifact-root`; it exposes no companion, archive, report, source,
executable, schema, model, checkpoint, seed, target, or execution knobs.

The exact canonical adapter receipt SHA-256, adapter source revision, and
verifier outcome belong only in the artifact evidence note. This prevents a
post-run edit to source-hashed documentation from invalidating the source
identity that the canonical receipt records.

## Authority and implementation boundary

Swift owns all interpretation, mutation detection, immutable publication, and
outcome decisions. The adapter runtime does not launch Python or a shell. It
does not use a companion package, NeuralKit product, PMHNP target, dynamic
loader, tar/xz utility, or archive library.

The existing direct `/usr/bin/git` transport is used only to observe the
Prime source repository before and after executable capture. It does not read
the companion repository in this slice.

The parent profile-screen archive is revalidated and copied only as an opaque
receipt-bound byte artifact. It is not listed, decompressed, expanded, or
interpreted. The historical receipt's recorded shell command is inert
historical data and is not executed or imported as authority.

`Package.swift` retains the existing package inventory. The adapter probe and
verifier depend only on `PrimeCore`; no PMHNP or NeuralKit runtime dependency
is added.

## Explicit non-claims

This slice does not:

- regenerate any of the 155,648 declared corpus rows;
- transplant or execute the companion corpus generator;
- independently parse or semantically regrade real corpus rows;
- bind the exact fixed-cap/EOS generation wire contract;
- inspect or observe physical generation shards;
- execute zero-shot, trained, or reloaded model generation;
- establish generation-behavior compatibility;
- complete Phase 3 compatibility;
- list, decompress, expand, or interpret the profile-screen archive;
- execute companion code or NeuralKit;
- add a companion runtime dependency or write to the companion repository;
- execute a model, load a checkpoint, or claim language capability;
- train, calibrate, distill, quantize, or evaluate a diagonal Hessian;
- authorize product, recommendation, safety, or clinical use;
- claim an independent scientific oracle.

The adapter can report that a resolved manifest declared rows independently
verified. It cannot turn that historical declaration into a new Prime
independent regrade without regenerating and checking those rows.

## Next bounded slices

### 1. Resolve one fixed-cap/EOS generation projection blob

The next prerequisite is:

`resolve_exact_fixed_cap_eos_generation_contract_projection`

Create one standalone, Swift-generated, versioned projection blob that freezes
the source-reviewed schema-4 generation boundary without expanding the
historical archive. It should bind at least:

- generation contract
  `greedy_native_bytes_eos_fixed_cap64_kv_v2`;
- prompt grouping
  `prompt_byte_token_count_excluding_bos_v1`;
- target-independent decision budget `64`;
- EOS token `70` available at every decision;
- allowed support equal to EOS plus byte-token IDs `256...511`;
- the target-free prompt request fields;
- EOS and fixed-cap termination rules;
- executed-decision mean-log-probability treatment, including immediate EOS;
- raw-result and post-generation regrade field projections;
- explicit separation between generation input and target-bearing regrade
  authority.

Source-reviewed development references at companion revision
`163fc100710ece48119bc25954452d10f6a84f7f` are:

| Source | Git blob | SHA-256 |
| --- | --- | --- |
| `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift` | `027a25b49dde1acfb4cd8af970e05ecd8241f427` | `8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f` |
| `neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift` | `795fff7c458ec68ba4562b6cd1c674fe8de7ffc4` | `c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6` |

Those source references are design lineage, not currently resolved source
artifacts. The new projection must become its own exact admitted blob before
the adapter may set `fixedCapEOSGenerationContractBound` to true. Even then,
generation-behavior compatibility remains false until physical result
artifacts are independently regraded.

### 2. Transplant the source-pinned full corpus generator

After the one-blob projection, transplant the complete first-party Swift
corpus generator and independent text verifier into Prime. This must be a
source-pinned transplant, not a companion runtime dependency and not an
execution of code from the PMHNP checkout.

The starting source identities at the same companion revision are:

| Source | Git blob | SHA-256 |
| --- | --- | --- |
| `prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift` | `27f5d4f61864499027d3e65516ae4c5cfe1ff5d1` | `9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721` |
| `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift` | `b2a087c9410a71f2bc99debade752ff779d7a8a8` | `4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210` |

That later slice must regenerate all eight splits and all 155,648 rows under
Prime authority, reproduce the exact row, sequence, semantic, prompt,
falsifier, and manifest hashes, re-run leakage and refusal-holdout mutations,
and independently regrade every row. Only that evidence can change
`corpusRowsRegenerated` or `corpusSemanticRegradePerformed` to true.

Neither next slice by itself authorizes model execution or product use.

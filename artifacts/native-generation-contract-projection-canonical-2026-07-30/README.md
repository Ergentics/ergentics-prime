# Prime native generation-contract projection evidence

Canonical local execution date: 2026-07-30 America/Los_Angeles

Outcome: `PASS`

Claim scope:
`source_pinned_fixed_cap_eos_generation_contract_binding_only`

Prime source revision:
`28906ef704f4d8727ea0da5e068f6ecbe52330ab`

Prime source tree:
`c2d07ff9f4a011f7dddf8eb91dcd7278d873b18c`

Prime source identity SHA-256:
`a634994a9aedb2803b61353ffd30f0fcd0f1bad4356ce738f7d150f3cd08d2fb`

Companion revision:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

Frozen parent adapter receipt SHA-256:
`0c5cb638a5ba4e157f9e9a62b648862fe5511841e43f18b87c9d94d5b4b3a867`

Canonical receipt:
`prime-native-generation-contract-projection-receipt.v1.json`

Canonical receipt byte count: `20,010`

Canonical receipt SHA-256:
`05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b`

Generation-contract projection:
`generation-contract/prime-native-fixed-cap-eos-generation-contract-projection.v1.json`

Generation-contract projection byte count: `15,482`

Generation-contract projection SHA-256:
`bc8e8730ec455396a01c0d3347c088d89f4b101a64ca10b4bd0bcc7eb80c290c`

Raw Release probe output:
`prime-native-generation-contract-projection-probe-output.v1.json`

Same-source fresh-process verifier output:
`prime-native-generation-contract-projection-verifier-output.v1.json`

The source-sealed Swift Release probe returned `PASS`. It independently
revalidated the frozen parent adapter receipt, copied all `14` parent evidence
bindings losslessly (`25,958,642` bytes), bound the exact three content-audited
companion source identities, published the typed projection, executed all
`48` named contract mutations, validated the completed root, and published
the receipt last.

The projection now includes the complete source-reviewed
`greedy_native_bytes_eos_fixed_cap64_kv_v2` boundary: target-independent
fixed-cap/EOS mechanics, ordered byte support, full-vocabulary tie and
log-softmax precision, active-decision support-mass witnesses, cached
BOS-inclusive prompt prefill, cached one-token decode, batch/context geometry,
exact single- and multi-step cache-parity fixtures, schema-2 raw fields,
schema-4 post-generation regrade fields, and donor-compatible canonical
Swift `String` equality for NFC-normalized generated text.

The separately invoked Swift Release verifier returned `PASS` with
`sameSourceFreshProcessPersistenceValidated: true`. This persistence statement
is deliberately qualified: `freshVerifierSameSourceIdentityRequired` is
`true`. Future verification must check out the recorded Prime revision and
use a Release verifier carrying the same embedded source identity. An
arbitrary later verifier is not equivalent.

The three companion source identities are content-audited design lineage, not
runtime-resolved source artifacts. The receipt therefore records
`sourceBlobEvidenceResolvedAtExecution: false`. Likewise, it records
`cacheParityWitnessValuesObserved: false` and
`fullVocabularyWitnessValuesRecomputedFromLogits: false`. The projection binds
the required mechanics; it does not fabricate model observations.

Before the canonical run, the complete Swift suite executed `237` tests with
zero failures. Two existing opt-in tests were skipped by the default suite:
the large sparse-artifact test and the live pinned-companion transport test.
The full production Swift package then built successfully, and the frozen
parent adapter independently passed its own Release verifier.

This note, the two raw output files, the canonical receipt, and the typed
projection are the compact repository evidence. They are not part of the
canonical receipt. The complete self-contained `19`-file descriptor root,
including copied source snapshots, executables, and parent evidence, remains
local because those larger inputs are already durable at their pinned Git
revisions.

This result does not observe physical generation shards, execute NeuralKit or
a model, observe or recompute logits, establish generation-behavior
compatibility, regenerate or independently regrade the corpus, complete Phase
3, train, quantize, authorize product use, or claim an independent scientific
oracle.

The next exact prerequisite is:
`source_pinned_full_swift_corpus_generator_transplant_replay`.

## Git checkout mode normalization

Git preserves only the executable permission bit. A fresh checkout can
therefore rematerialize the two tracked, receipt-bound immutable files as
`0644` even though the canonical run published them as `0444`. The Release
verifier must reject that state; this is not permission to weaken the
immutable-file gate.

Before repairing anything, require an owner-controlled mode-`0700` root and
inspect these exact files:

```zsh
stat -f '%Sp %u %l %z %N' \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/prime-native-generation-contract-projection-receipt.v1.json \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/generation-contract/prime-native-fixed-cap-eos-generation-contract-projection.v1.json
shasum -a 256 \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/prime-native-generation-contract-projection-receipt.v1.json \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/generation-contract/prime-native-fixed-cap-eos-generation-contract-projection.v1.json
```

The receipt must be owned by the current user, have link count `1`, contain
exactly `20,010` bytes, and hash to
`05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b`.
The projection must have the same ownership and link requirements, contain
exactly `15,482` bytes, and hash to
`bc8e8730ec455396a01c0d3347c088d89f4b101a64ca10b4bd0bcc7eb80c290c`.

Only when every condition is exact, restore immutable-data mode on those two
files and rerun the same-source Release verifier:

```zsh
chmod 0444 \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/prime-native-generation-contract-projection-receipt.v1.json \
  artifacts/native-generation-contract-projection-canonical-2026-07-30/generation-contract/prime-native-fixed-cap-eos-generation-contract-projection.v1.json
.build/release/PrimeNativeGenerationContractProjectionVerifier \
  --artifact-root "$PWD/artifacts/native-generation-contract-projection-canonical-2026-07-30"
```

Do not change modes recursively. Do not repair a symlink, hard link,
wrong-owner file, wrong-size file, or wrong-hash file. The human-readable
index and raw output files are not receipt-bound immutable inputs and do not
need this normalization.

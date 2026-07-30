# Prime native resolved-contract adapter evidence

Canonical local execution date: 2026-07-30 America/Los_Angeles

Outcome: `PASS`

Claim scope:
`frozen_tokenizer_corpus_evaluation_and_synthetic_regrade_envelope_compatibility_only`

Adapter source revision:
`69e65f2d23fe790bec2336e0d2c8686e1fd4daaf`

Adapter source tree:
`08a7d58b2f0f41962642ba2faeda547962bd2449`

Adapter source identity SHA-256:
`464853f9b09358b3ed95e5ac7fbf63888e6458af8ec8996ca485c1d7d0581647`

Parent resolver source revision:
`7c7b0496a94fe776df2e542df7413fd4a8bcf250`

Parent resolver source identity SHA-256:
`51efb053b6c6ac4e338020842fab6a25715bf57076c0d62a3f8ea39c6a3ea05a`

Companion revision:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

Canonical receipt:
`prime-native-resolved-contract-adapter-receipt.v1.json`

Canonical receipt byte count: `13,293`

Canonical receipt SHA-256:
`0c5cb638a5ba4e157f9e9a62b648862fe5511841e43f18b87c9d94d5b4b3a867`

Compatibility projection:
`adapter/prime-native-resolved-contract-projection.v1.json`

Compatibility projection byte count: `3,964`

Compatibility projection SHA-256:
`ddba956b7b4f7e3996fde6d8f11046ec3a222ef62467b806b5170887ef7620bf`

Raw Release probe output:
`prime-native-resolved-contract-adapter-probe-output.v1.json`

Fresh-process verifier output:
`prime-native-resolved-contract-adapter-verifier-output.v1.json`

The source-sealed Swift Release probe returned `PASS`. It revalidated the
exact parent receipt and all eight parent artifacts, copied the complete
parent descriptor evidence losslessly, replayed all seven tokenizer probes
through `String.UTF8View` and Foundation UTF-8 encoding paths, validated the
corpus/evaluation manifest and inert historical Verify/Abstain envelope, and
detected and restored all nine named adapter mutations.

The separately invoked Swift-only verifier returned `PASS` with
`freshProcessPersistenceValidated: true`. Fresh receipt validation re-read the
persisted tokenizer, corpus, and synthetic inputs, reproduced the typed
projection, reran the nine-mutation sweep, and rebound the immutable receipt.

Before the canonical run, the complete Swift suite executed 215 tests with
zero failures. Two pre-existing opt-in tests were skipped by the default
suite: the large sparse-artifact test and the live pinned-companion transport
test. The historical parent Release verifier was separately rerun and passed
with 8 artifacts and 11,969,097 bytes.

This note, the two raw output files, the canonical receipt, and the typed
projection are the compact repository evidence. They are not part of the
canonical receipt. The complete self-contained 15-file descriptor root,
including copied source snapshots, executables, and resolved parent artifacts,
remains local because those inputs are already durable at their pinned Git
revisions.

This result does not regenerate or semantically regrade the 155,648 corpus
rows. It does not bind the exact fixed-cap/EOS generation wire contract,
observe physical generation shards, establish generation-behavior
compatibility, complete Phase 3, expand the opaque archive, execute NeuralKit
or a model, train, quantize, authorize product use, or claim an independent
scientific oracle.

The next exact prerequisite remains:
`resolve_exact_fixed_cap_eos_generation_contract_projection`.

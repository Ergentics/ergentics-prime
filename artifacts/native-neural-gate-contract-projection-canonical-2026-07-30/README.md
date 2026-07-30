# Prime native NeuralKit gate-contract projection evidence

Canonical local execution date: 2026-07-30 America/Los_Angeles

Outcome: `PASS`

Claim scope:
`source_pinned_neuralkit_native_language_gate_contract_projection_only`

Prime source revision:
`a1ff82f092eed2093ab8062ef1bbea66f03cb3a3`

Prime source tree:
`617c70e258e393cacc88896962f16b684480958a`

Prime source identity SHA-256:
`c2a144054544b9db68a3765ed3068430cb2ccd284e6477cd6ece26220a8a6091`

Plan SHA-256:
`f4ab6e17319603d29d2410c597ba52a5bf5ebde4944c82021216098ed0781cf1`

Canonical parent receipts:

- generation-contract projection:
  `05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b`;
- full-corpus replay:
  `88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2`.

The generation parent was authenticated against historical Prime source
identity
`a634994a9aedb2803b61353ffd30f0fcd0f1bad4356ce738f7d150f3cd08d2fb`.
The corpus parent was authenticated against historical Prime source identity
`d13a817e2918e94972174b78eb1372dd0d4395161fca08b63850e7c2bfbbb08f`.
Both identities are closed compiled authority tokens paired with exact
receipt, Git, and snapshot tuples; neither was supplied by an artifact.

The source-sealed Swift Release probe ran as process `57559`. It revalidated
both complete parents, copied `26` parent evidence bindings losslessly
(`53,498,652` bytes), published the source-pinned projection, executed the
five-record finite-field contract vector and all `12` structural projection
falsifiers, and published only an incomplete candidate:

- candidate:
  `neural-gate-contract/probe-candidate.v1.json`;
- bytes: `7,258`;
- SHA-256:
  `17319547d44b5ef6821c0cd69068586127b9831992b4c8d273fe50af0d6205b6`.

The separately invoked Swift Release verifier ran as process `57638`. It
recaptured the same clean Prime source, authenticated the copied parents
again, reproduced the projection observation byte-for-byte, required the
distinct process identifiers, and exclusively published the terminal receipt:

- receipt:
  `prime-native-neural-gate-contract-projection-receipt.v1.json`;
- bytes: `3,193`;
- SHA-256:
  `2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed`.

The raw probe summary hashes to
`e5b94d30451328dbc2284c12617dfedf81f296bb6a3185fdc3cfc990fc3fd887`.
The raw verifier summary hashes to
`2e2a17b5941f07ceb12e3982724688fd8f76a616fbe444281d2c2c32a4490212`.

The typed projection is
`neural-gate-contract/prime-native-neural-gate-contract-projection.v1.json`,
contains `17,137` bytes, and hashes to
`890d96d67267606048d3dfebb0bc29fe118c086d111b7b39de8501a6120bac48`.
The probe and verifier observations each contain `4,114` bytes and hash to
`09f72adf2e14ebd2c36572ed6d94ea35bdfda305a48d1f19dd868dcc83722a04`.
Their finite-field residues are
`[1929142910, 1440393600, 837181579]`.

The Release probe executable contains `8,368,672` bytes and hashes to
`994d878aea9ad152505790e4d5c2108905a7340e21310e35ecb43f5bc1586b69`.
The Release verifier executable contains `8,370,000` bytes and hashes to
`cc55badc7f788909f90b18541547ea6c596d4bfd5db92a5103adc70c5ca40d90`.

Before the canonical run, the complete pinned-metallib Swift suite executed
`268` tests with zero failures. Two opt-in tests were skipped: the sparse
multi-gigabyte artifact test and the live pinned-companion transport test.

The verifier-completed descriptor root contained `36` files totaling
`73,980,257` bytes before this README and the two raw summaries were added.
This README, raw summaries, candidate, projection, observations, and receipt
are compact repository evidence. They are not a self-contained verifiable
descriptor root. Live receipt validation also requires the omitted copied
parent evidence, source snapshot, and both exact executables retained in the
complete local root or reconstructed from their frozen sources.

This `PASS` is deliberately bounded. It projects all `46` historical mutation
contracts and the source-reviewed Verify/Abstain, statistics, count-derived
triadic label, all-critical rule, selected capability thresholds, and
finite-field mechanics. It does not execute the historical `46` mutations,
observe the `59,497` invariant records, recompute the historical SZ
fingerprint, perform AgentContractKit's four-tier audit, execute NeuralKit or
a model, train, quantize, complete Phase 3, authorize product use, or claim an
independent scientific oracle.

The next exact prerequisite is:
`source_pinned_synthetic_fixture_materialization_and_gate_replay`.

The compact receipt-bound JSON files may materialize as mode `0644` after a
Git checkout even though the canonical local root published them as `0444`.
That archive behavior is not permission to weaken live verifier checks. A
future canonical rerun must use a new empty mode-`0700` root.

# Prime native contract resolution evidence

Canonical local execution date: 2026-07-29 America/Los_Angeles

Outcome: `PASS`

Claim scope: `frozen_companion_blob_resolution_only`

Resolver source revision:
`7c7b0496a94fe776df2e542df7413fd4a8bcf250`

Resolver source identity SHA-256:
`51efb053b6c6ac4e338020842fab6a25715bf57076c0d62a3f8ea39c6a3ea05a`

Companion revision:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

Canonical receipt:
`prime-native-contract-resolution-receipt.v1.json`

Canonical receipt SHA-256:
`d8e8caefb9f0c340a7418befeca4966daf178894164eaaebdfae7b565928c8f4`

Fresh-process verifier output:
`prime-native-contract-resolution-verifier-output.v1.json`

Resolved inventory: 8 artifacts, 11,969,097 bytes.

The separately invoked Swift-only
`PrimeNativeContractResolutionVerifier` returned `PASS` with
`freshProcessPersistenceValidated: true` and
`independentScientificOracleClaimed: false`.

Before the canonical run, the full Swift test suite executed 196 tests with
zero failures. Two opt-in tests were skipped by the default suite: the large
sparse-artifact test and the live pinned-companion transport test. The live
pinned-companion transport test was invoked separately against the frozen
checkout and passed.

This note is a human-readable index and is not part of the canonical receipt.
The complete descriptor root remains local. The repository preserves this
index and receipt; the exact eight source blobs remain independently durable
at the pinned companion revision.

This evidence does not claim compatibility replay, adapter completion,
archive interpretation, model execution, training, quantization, product
authority, or an independent scientific verdict.

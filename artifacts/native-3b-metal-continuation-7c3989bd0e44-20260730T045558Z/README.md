# Exact 3B interrupted Metal continuation — PASS

This directory records the canonical receipt from the source-sealed run at
Prime commit `7c3989bd0e448eddf3b8b8b87d83c90f518a7d0c`, using the merged first-party
Ergentics MLX revision `d37885a278f1c37484a94d0f401a418735e66519`.

The canonical receipt SHA-256 is
`2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e`.
It records three distinct workers with normal zero exits and exact comparisons
at all declared boundaries:

- control step 1 versus writer step 1 before checkpoint publication;
- checkpoint state immediately after restore at step 1;
- uninterrupted control step 2 versus restored continuation step 2.

The complete local artifact root, including the three approximately 11.28 GB
safetensor components and all bound source/runtime evidence, was independently
replayed with `PrimeNative3BMetalContinuationReceipt.validate(in:)`. Only this
README and the canonical receipt are intended for Git. The checked-in receipt
supports structural replay but cannot by itself perform live descriptor replay
without the intentionally local checkpoint and runtime files.

Later preservation exception (2026-08-03): an independent Driver V2 release
audit found that the exact current-revision dependency source-tree manifest
needed Git/off-device durability for license and provenance accounting. The
existing 267,732-byte
`content-staging/evidence/mlx-swift/dependency-source-tree.v1.json` was added
unchanged at SHA-256
`91c9f71a7d32a21a5f23e5aaf0b6d54036a2858f88c30128e5910ea8f17e175f`.
This append-only exception does not add the local checkpoints, runtimes, or
large safetensors; rewrite the canonical receipt; or expand the R&D result's
authority.

This is a narrow random-initialized, collision-free synthetic continuation
mechanics result. It does not use pretrained weights, a tokenizer, a corpus, or
an adapter. It does not authorize training, quantization, profile promotion,
language capability, or product use. Descriptor-backed checkpoint bytes are
materialized and verified on MLX's supported CPU load stream; restored model
execution and AdamW continuation run through the declared Metal path.
Arbitrary repeated-token exact gradient replay remains unresolved.

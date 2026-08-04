# Third-party notices

Prime's first-party source and generated artifacts, to the extent owned by
Ergentics, LLC, remain subject to the repository license. Artifact-specific
data, model, corpus, and third-party manifests control where other rights are
incorporated. Dependency licenses do not transfer ownership of independent
Prime source or evidence.

The active resolved SwiftPM dependency and upstream-lineage inventory is:

| Resolved package or lineage | Pinned version | License |
| --- | --- | --- |
| `Ergentics/ergentics-mlx-swift` typed-state, descriptor-I/O, and restore modifications | private revision `d37885a278f1c37484a94d0f401a418735e66519`; typed-optimizer validation preserves evidence-bound revision `68904d54b72871f26968261ae05d4fbb7c5e3142` | Derivative of the MIT-licensed `ml-explore/mlx-swift` 0.31.3 lineage; upstream notice retained, Ergentics modifications copyright 2026 Ergentics, LLC |
| `apple/swift-numerics` | 1.1.1 | Apache License 2.0 |

The following packages remain relevant to preserved historical R&D artifacts
but are not pins in the active root or validation lockfiles:

| Historical package | Frozen version | License |
| --- | --- | --- |
| `ml-explore/mlx-swift-lm` | 3.31.3 | MIT, copyright 2024 ml-explore |
| `swiftlang/swift-syntax` | 600.0.1 | Apache License 2.0 |

The pinned MLX Swift source tree also vendors or submodules build inputs with
their own notices:

| Transitive component in `mlx-swift/Source/Cmlx` | License / notice |
| --- | --- |
| `{fmt}` | MIT-style license with optional binary exception; copyright Victor Zverovich and contributors |
| `nlohmann/json` | MIT; copyright Niels Lohmann |
| Apple `metal-cpp` | Apache License 2.0; copyright Apple Inc. |
| Apple MLX core | MIT; copyright Apple Inc. |
| `ml-explore/mlx-c` | MIT; copyright ml-explore |
| PocketFFT | BSD 3-Clause-style notice; copyright Max-Planck-Society, Peter Bell, and the DCT-IV contributors named in the vendored header |
| `gguf-tools` | MIT; copyright 2022 Georgi Gerganov |

The active `Package.resolved` files bind the exact active revisions. License files for the
vendored components are present in the pinned dependency tree. Those texts
and all required notices must accompany any redistribution; this inventory is
not yet an SBOM.

The pinned Ergentics revision contains typed optimizer-state transport,
descriptor-relative I/O, save/load coverage, and restore changes; relative to
the earlier `68904d54b72871f26968261ae05d4fbb7c5e3142` pin it changes five files
with 1,827 insertions and 74 deletions. It does not change the dependency's
`LICENSE` or `ACKNOWLEDGMENTS.md`. The revision is present in an explicitly
authorized private, license-preserving remote. This is a private R&D
dependency, not an open-source release, upstream acceptance, CI credential
proof, or public-availability claim.

Historical `mlx-swift-lm` use, its notices, and its immutable evidence remain
preserved for accounting. Preservation does not restore it to the dependency
graph or grant it decoder, training, product, or release authority.

The existing typed-gate source-tree receipt—1,667 files, SHA-256
`ef4e3c57d3c24bdc5705be78bdf60b630d84ab7bbbd9affc1faa41137b4ead43`,
21,822,344 bytes—belongs to the earlier dependency tree and is retained as
historical evidence. It must not be presented as the source receipt for
`d37885a278f1c37484a94d0f401a418735e66519`.

An exact R&D source-tree manifest for the current revision is separately
preserved at
`artifacts/native-3b-metal-continuation-7c3989bd0e44-20260730T045558Z/content-staging/evidence/mlx-swift/dependency-source-tree.v1.json`.
Its JSON is 1,668 files and 21,867,860 source bytes, has SHA-256
`91c9f71a7d32a21a5f23e5aaf0b6d54036a2858f88c30128e5910ea8f17e175f`,
and records tree SHA-256
`9e90ccf907b8d5ec3da62078da5c95bb6e4145bdb1cfa46df764fb5962eea4e6`;
`PrimeNative3BContinuationDependencyPlan.frozenV1` binds that manifest to the
current fork revision. This is preserved R&D evidence, not a release-scoped
SBOM, redistributable source bundle, notice-closure receipt, or product-release
authorization. Those release artifacts and reviews remain required before an
artifact incorporating the fork may ship. The Driver V2 supervisor target is
separately required to prove that its target graph and linked Mach-O contain no
MLX or MLXLLM product.
`swift-numerics` is revision-pinned but does not yet have a separately frozen
source-tree receipt, so full transitive build-source closure is not claimed.
Private source reachability does not establish off-device durability for
Prime's generated receipt artifacts.

The repository owner selected `Ergentics, LLC` as the exact legal
rights-holder spelling on 2026-07-29. Git author identity and the `Ergentics`
brand/GitHub organization remain separate. No public submission is authorized
by this notice.

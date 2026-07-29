# Third-party notices

Prime's first-party source and generated artifacts, to the extent owned by
Ergentics, LLC, remain subject to the repository license. Artifact-specific
data, model, corpus, and third-party manifests control where other rights are
incorporated. Dependency licenses do not transfer ownership of independent
Prime source or evidence.

The direct SwiftPM dependency inventory is:

| Direct package | Pinned version | License |
| --- | --- | --- |
| `ml-explore/mlx-swift` | 0.31.3, upstream base `61b9e011e09a62b489f6bd647958f1555bdf2896` | MIT, copyright 2023 ml-explore |
| Ergentics `mlx-swift` typed-state modification | private revision `68904d54b72871f26968261ae05d4fbb7c5e3142`, authenticated fresh-clone resolution observed | Derivative of the MIT-licensed upstream package; upstream notice retained, Ergentics modifications copyright 2026 Ergentics, LLC |
| `ml-explore/mlx-swift-lm` | 3.31.3 | MIT, copyright 2024 ml-explore |
| `apple/swift-numerics` | 1.1.1 | Apache License 2.0 |
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

`Package.resolved` binds the exact direct revisions. License files for the
vendored components are present in the pinned dependency tree. Those texts
and all required notices must accompany any redistribution; this inventory is
not yet an SBOM.

The typed optimizer-state candidate changes public state transport only and
does not change the pinned upstream AdamW arithmetic source. Its exact
Ergentics revision is now present in an explicitly authorized private,
license-preserving remote, and authenticated cache-empty clone resolution has
been observed. This is a private R&D dependency, not an open-source release,
upstream acceptance, CI credential proof, or public-availability claim. The
typed gate additionally binds the MLX Swift `Package.swift` and
all 1,666 admitted regular files under its `Source/**` tree (excluding only
two `.git` submodule metadata files): 1,667 files total, tree SHA-256
`ef4e3c57d3c24bdc5705be78bdf60b630d84ab7bbbd9affc1faa41137b4ead43`,
21,822,344 bytes).
`swift-numerics` is revision-pinned but does not yet have a separately frozen
source-tree receipt, so full transitive build-source closure is not claimed.
Private source reachability does not establish off-device durability for
Prime's generated receipt artifacts.

The repository owner selected `Ergentics, LLC` as the exact legal
rights-holder spelling on 2026-07-29. Git author identity and the `Ergentics`
brand/GitHub organization remain separate. No public submission is authorized
by this notice.

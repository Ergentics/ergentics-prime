<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime source-bound MLX runtime scaffold

Date: 2026-08-03

Status: implementation and CI integration are unverified WIP; final source
identity, hosted validation, durable commit, and independent audit are pending

## Why this boundary exists

A hosted root Release run from a fresh checkout failed before the existing
MLX metallib stager. The SwiftPM destination did not contain
`mlx-swift_Cmlx.bundle/Contents/Info.plist`. Local validation had not exposed
the gap because a persisted `.build` tree already contained that manifest.
The pinned Cmlx package declares neither this SwiftPM resource nor a build
plugin that produces it.

This does not invalidate the frozen donor/runtime role split. It identifies a
missing producer between a clean SwiftPM build and the existing metallib-only
stage.

## Historical lineage remains preserved

Commit `9cdfd7060b51e5d36ef8e6d0a4f60dbbd0e0cfa6` implemented the first runtime
stage by copying the then-admitted bundle contents, including its manifest.
After the private first-party MLX identity made the Xcode donor manifest
different from the canonical SwiftPM runtime manifest, commit
`ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f` correctly separated the roles:
the stager validates both manifests and transfers only the metallib.

Those commits and every receipt produced under their contracts remain
historical accounting. The new scaffold neither rewrites them nor uses their
evidence as a runtime bootstrap source. Persisted `.build` contents,
historical receipts, evidence roots, and the 1,130-byte Xcode donor manifest
are not admitted template inputs.

## Exact authorities

The tracked canonical template is:

```text
Sources/PrimeMLXRuntimeScaffold/Templates/canonical-swiftpm-runtime/mlx-swift_Cmlx.bundle/Contents/Info.plist
```

Its frozen identity is 1,120 bytes, SHA-256
`62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d`,
with `CFBundleIdentifier=mlx-swift.Cmlx.resources`.

The independent Xcode donor manifest remains 1,130 bytes, SHA-256
`124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e`,
with `CFBundleIdentifier=ergentics-mlx-swift.Cmlx.resources`. The shared
`default.metallib` remains 3,817,916 bytes, SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`.

The scaffold owns only creation and binding of the canonical manifest-only
SwiftPM runtime tree. `PrimeMLXBundleStage` retains exclusive authority to
validate the typed Xcode donor and publish only the exact metallib.

## Fail-closed scaffold

`PrimeMLXRuntimeScaffold` accepts exactly three values:

```sh
.build/arm64-apple-macosx/release/PrimeMLXRuntimeScaffold \
  --source-root "$PWD" \
  --destination-host .build/arm64-apple-macosx/release/PrimeTypedOptimizerRestoreProbe \
  --runtime-role typed_optimizer_restore_probe
```

The other admitted role/host pairs are `calibration` with
`PrimeGPUCalibration`, `optimizer_restore_probe` with
`PrimeOptimizerRestoreProbe`, and `native_3b_metal_continuation_probe` with
`PrimeNative3BMetalContinuationProbe`.

Before publication the utility:

1. rejects symlink-traversing source and destination paths;
2. captures and validates the complete Prime Swift source identity, including
   the exact tracked template;
3. holds and rereads that template through the source boundary;
4. requires the role-specific destination-host basename and a trusted
   executable/build root; the workflow separately builds that host in Release;
5. rejects forbidden loader environment and instrumentation state; and
6. descriptor-walks the destination without following links.

For an absent destination it exclusively creates the bundle, `Contents`, and
`Contents/Resources` directories at mode `0700`, then exclusively publishes
only `Contents/Info.plist` at mode `0444`. The exact post-scaffold tree is:

```text
mlx-swift_Cmlx.bundle/
└── Contents/
    ├── Info.plist
    └── Resources/
```

No metallib exists at this point. A conflicting or partial occupant fails
without overwrite. The implementation may rebind an already exact,
manifest-only scaffold idempotently, but the hosted creation canary requires
the entire destination bundle to be absent before invocation so it proves the
missing producer rather than accepting cached state.

For the typed-restore canary, exact successful standard output is one line:

```text
Prime MLX runtime scaffold complete: runtime_role=typed_optimizer_restore_probe mlx_swift=0.31.3 destination_bundle_initially_absent=true runtime_info_plist_sha256=62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d metallib_absent=true
```

## Promotion workflow sequence

The root Release promotion workflow now performs this order:

1. bind the tracked template's exact SHA-256 and byte count as a static input;
2. build the role-specific SwiftPM Release destination host;
3. build `PrimeMLXRuntimeScaffold` before `PrimeMLXBundleStage`;
4. require the complete destination runtime bundle to be absent;
5. invoke the exact source-root/destination-host/runtime-role scaffold CLI;
6. compare exact output and verify the exact tree, `0700` directory modes,
   `0444` manifest mode, manifest bytes/SHA, and absent metallib;
7. invoke the unchanged metallib-only stager against the separately built
   Xcode donor; and
8. compare exact stage output and verify the final exact tree, both file
   identities, `0700` directory modes, and `0444` file modes.

The final runtime tree adds only
`Contents/Resources/default.metallib`. No command may copy, derive, normalize,
rewrite, or overwrite either role-specific manifest. SwiftPM's sandbox remains
enabled; `--disable-sandbox` is not an authorized workaround for outer managed
sandboxing.

“Promotion-only” describes when the heavy workflow is selected; it is not a
skip within that workflow. Once the root Release promotion gate runs, every
scaffold and staging assertion above is mandatory, and a missing fixture is a
failure. Ordinary Xcode and SwiftPM iteration and normal macOS/Mac App Store
development remain usable without performing the full Metal-backed suite on
every build. The package currently declares macOS 14 only; an iOS App Store
target is a separate platform/packaging task and is not blocked by these
canaries or by SwiftPM.

## Driver and model authority ceilings

The Driver V2 MLX-free claim remains supervisor-only. The scaffold executable
depends on PrimeCore alone and is separate from the
`PrimeValidationWorkflowDriverV2` target and Mach-O linkage closure. It is not
a Driver dependency, child-execution grant, staging receipt, or positive
Driver V2 completion record. Other root targets continue to resolve and link
MLX, so no repository-wide MLX-free claim is made.

This transient CI canary does not authorize decoder implementation, Logic 10M
execution, 300M/3B/10B execution, training, quantization, checkpoint promotion,
scientific inference, or product release. The frozen historical Llama run
remains comparator evidence only and is not a template or authority source for
this boundary.

## Accounting and remaining validation

The historical-worker `Package.swift` anchor remains 27,650 bytes, SHA-256
`190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d`.
The Driver-only anchor remains 28,758 bytes, SHA-256
`52a0078a3dd6b5cf68aa75e63c12ea739e2238cdb7c8f5b0380cbbff4cb66fa6`.
The scaffold working manifest is 29,043 bytes, SHA-256
`5df810b3796bc3b254e58148ddcc9e4014c92c504845084743c1d3a580c2c895`.
The pre-scaffold two-role package-description anchor remains historical at
65,306 bytes, SHA-256
`6a4221c36d6e1b013b5e8bd7ad1c7730ebb8847a257305d7c550b14e1543a7e6`.
That checkout-specific raw capture normalized to 65,060 bytes, SHA-256
`47d0df8b252bbc5b51b4ca70319cd88ce16f6bca2a55989c6c00a26e49cb6b93`;
both values remain historical. The additive scaffold topology now normalizes
to 65,740 bytes, SHA-256
`a9b8935742e67c2ea5cf8cb19727a4dcc24adb46553f7a74d4a243f713cb51f5`.

Before this continuation can be published as complete, the final source tree
must be frozen, the embedded source identity and current package-description
evidence must be regenerated, focused tests and the full hosted promotion
workflow must pass, and an independent final audit must name the exact commit.
No earlier evidence file or historical anchor is overwritten to satisfy those
steps.

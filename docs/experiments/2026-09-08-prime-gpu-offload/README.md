# Prime guest GPU offload

Prime now has a live, bounded 2D geometry compute operation across its real ARM guest boundary: the guest issues HVC0x51, native Swift runs geometry-app’s Metal kernel, a typed floating-point reply returns to guest memory, and the guest reads every reply word and commits a checksum before HVC0x52. This is custom guest GPU offload, not a complete virtual graphics device. No learned model or training ran.

The live diagnostic passed 24 host/guest pairs at 1,32 and200 points (eight pairs each, alternating route order). All5,592 guest-returned floats matched direct-host Metal output exactly and passed CPU potential/gradient checks. There were50 real Metal dispatches including two shared-pipeline warmups,24 measured VMs plus one deliberately invalid-reply VM,48 measured guest entries, and four negative checks. Three malformed requests were rejected before VM/compute; a nonfinite fixture reply was rejected before guest resume. The process exited0 with exact reap, EOF and no remaining owned process-group member.

| Points | Host GPU median µs | Guest-route GPU median µs | Host route median µs | Guest round-trip median µs |
|---|---:|---:|---:|---:|
| 1 | 16.31 | 16.38 | 526.44 | 604.52 |
| 32 | 31.17 | 19.56 | 221.25 | 297.50 |
| 200 | 13.44 | 45.56 | 203.10 | 378.08 |

GPU duration comes from completed Metal command-buffer timestamps. The route interval excludes persistence and CPU reference scoring; guest time includes a fresh VM, callback, checksum, joined watchdog and teardown. The pipeline’s cold initialization was67.52ms. Small samples, shared-system load and fresh-VM costs prevent a throughput or isolated vCPU-overhead conclusion. Missing timestamps would remain unavailable; all48 measured samples provided valid timestamps. [Raw measurements](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04/Live/native/result.json), [independent live review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04/Readiness/LIVE-REVIEW.json).

## Where the repositories fit

- **Ur / URRenderKit:** Core Graphics/vImage CPU rasterization and image-parity helpers. Its separate RealityKit scene is iOS-only; the macOS branch is a black placeholder. No custom Metal compute, hypervisor transport or virtual GPU was found in the inspected Ur sources.
- **geometry-app:** real, separate host Metal APIs for triangle rasterization (`GeometryRenderMetal`) and field computation (`MasteryFieldMetal`). This implementation reuses the latter’s actual kernel and adds timing around the existing bounded adapter.
- **Prime:** its retained history records an “Apple Paravirtual device” on the Aug10 GitHub macos-26 runner. That is a recorded hosted GPU exposure, not evidence of a locally implemented virtual GPU. Existing `PrimeGPUCalibration` allocates a random3B model and runs optimizer mechanics; it was not needed or launched here.

[Ur and geometry audit](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04/UrReview/UR-GPU-REVIEW.json), [render versus compute](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04/UrReview/GEOMETRY-RENDER-COMPUTE-REVIEW.json), [Prime and SDK readiness](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04/Readiness/GPU-ROUTE-READINESS.json).

Apple’s full [Paravirtualized Graphics framework](https://developer.apple.com/documentation/paravirtualizedgraphics) additionally needs a virtual graphics device, guest driver and host callbacks for memory/device operations. This typed compute service does not provide that graphics stack. Apple documents the timing semantics in [gpuStartTime](https://developer.apple.com/documentation/metal/mtlcommandbuffer/gpustarttime).

## Saved runtime

Experiment build0013 retains the signed `PrimeGuestGPU` executable and the exact compiled source. Run it directly, or through the retained bounded controller, with `--output-directory /absolute/fresh/output`. It initializes one Metal pipeline and performs the complete small diagnostic. No dependency installation, model download or app replacement occurs. The new source lives alongside the existing Prime domain/model work in the authoritative staging checkout.

The next graphics-specific step would be a guest driver/device integration. The current completed step is useful independently: a real guest can request a bounded GPU operation and consume its numeric result. These measurements come from runtime telemetry, not a predicted language-model answer.

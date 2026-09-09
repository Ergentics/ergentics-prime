# Native compute services for the existing app

These two helpers are launched by the signed `com.ergentics.provenance` app. They require the live parent identity and the existing app entitlements. The helper copies are signed with their dedicated identifiers, hardened runtime, App Sandbox, sandbox inheritance and Hypervisor capability. No external executable, arbitrary guest code, network access, training or alternate model is introduced.

`PrimeModelService` (`com.ergentics.provenance.prime-model-service`) preserves runtime 0014's Prime10M architecture, strict 74-tensor/10,227,968-parameter F32 loader, full-vocabulary predictions, GPU stream, timing intervals and guest ABI2. The only model-main adaptations are app admission, parent monitoring and post-compute admission revalidation. Its protocol remains:

```
PrimeModelService --request ABS_JSON --output-directory ABS_FRESH_DIRECTORY
```

The request and `result.json` retain `prime_10m_feedback_inference_request_v2` and `prime_10m_feedback_inference_result_v2`. The app selects its bundled checkpoint by exact path and SHA256. User input consists of symbolic tokens; this model does not accept natural-language prompts or generate answers from a text model. Raw full-vocabulary logits and actual guest receipts remain in the fresh output directory. The helper hashes the weights and request before/after execution.

`PrimeGeometryService` (`com.ergentics.provenance.prime-geometry-service`) uses runtime 0013's unchanged Gaussian potential/gradient Metal kernel, CPU reference and guest ABI1. It replaces that runtime's fixed repeated diagnostic with exactly one user-input dispatch:

```
PrimeGeometryService --request ABS_JSON --output-directory ABS_FRESH_DIRECTORY
```

Request keys are exactly `points`, `nodes`, `sigma`, `execution`. Points are 1–200 `[x,y]` arrays; nodes are 1–64 `{x,y,weight}` objects; coordinates/weights are finite F32, and positive sigma must support finite F32 kernel arithmetic. Execution is `host` or `guest`. No input truncation, random fixtures or CPU fallback is used.

`result.json` uses `prime_app_geometry_result_v1` with `status: completed`, execution, PID, device, exact request SHA256, actual F32 points/nodes/sigma, `potential[n]`, interleaved `gradientXY[2n]`, raw-vector SHA256, CPU comparison, GPU command-buffer timestamps and route timing. Guest mode additionally retains the full native guest receipt, observed typed input and reply, checksum, actual read count, HVC/cleanup observations, and byte equality with the GPU vector. Host mode reports a null guest. Geometry is a deterministic compute kernel, not a learned model.

Both services have a 120-second process alarm, parent monitoring, and the retained joined 10-second per-guest watchdog. The app's existing bounded process runner owns cancellation, output drainage and exact child cleanup. The guest bridge is typed HVC offload to host Metal; it is not a general virtual GPU device.

Build with `python3 Tools/PrimeComputeNative/build.py build03` from the app repository. Build directories must be fresh. build01 and build02 are preserved completed compilations; packaging selects build02. The script runs sequential bounded compiler processes with two Swift compiler threads, and never runs or signs a service. It reuses 440 recorded Release MLXLLM transitive objects plus one copied, rebuilt app-only library-loader object and source-bound guest objects from the retained experiment workspace. It does not resolve packages or install dependencies. Compilation requires that recorded workspace cache and the installed Xcode SDK; the packaged app needs only the resulting binaries, `Contents/Resources/PrimeCompute/mlx.metallib`, bundled weights and macOS frameworks.

`build02/result.json` records successful compilation, exact output hashes and unchanged source/dependency inputs. These are pre-sign binary hashes. Packaging signs only copies under `Contents/Helpers/PrimeCompute` and records their different final hashes in `Resources/PrimeComputeAssets.json`. The standalone runtimes' previous admission policies and source bytes remain untouched. Compilation by itself does not prove signed sandbox app execution; that is a separate live check owned by the app integration task.

The first app seal rejected a raw metallib under the Helpers code directory. build02 therefore replaces only `load_default_library` in a copied MLX `device.cpp`: it resolves `../../Resources/PrimeCompute/mlx.metallib` from the helper executable directory and fails if that sealed resource cannot load. It uses the original C++ compilation arguments; original source/object and build01 remain unchanged. There is no unsupported environment override, current-directory fallback or shader math change. The prior README/review and build script are retained under build01.

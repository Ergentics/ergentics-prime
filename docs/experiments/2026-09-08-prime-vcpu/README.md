# Prime: live vCPU-controlled inference

The missing guest-to-model connection is implemented and has run successfully. A fixed 200-byte ARM guest controls the job sequence, requests actual Swift/Metal inference through HVC exits, receives the unrestricted model prediction, inserts that value into its next request, and resumes. The host verifies the guest's work without filling its continuation slots.

The full comparison completed **160 VM instances, 880 vCPU entries, 720 actual model forwards and 400 guest-written feedback slots**. All720 input arrays, predictions and full16,384-value logit arrays match the earlier host-only run exactly. Every required model/VM process finished normally and retained its results. See [numerical review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-vCPU-02/NUMERICAL-REVIEW.json) and [live lifecycle review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-vCPU-02/LIVE-REVIEW.json).

| Checkpoint | Correct direct final | Correct iterative final | Every trace step correct |
|---|---:|---:|---:|
| Swift Prime10M, seed1618, 4,000 training steps | 8/80 | 54/80 | 48/80 |
| Swift Prime10M, seed1618, 8,000 training steps | 15/80 | 61/80 | 48/80 |

The guest connection preserves numerical behavior; it does not improve learned accuracy by itself. These remain two symbolic programs across80 binding/context/start variations. Unseen-codebook traces remain a model weakness. The [older Llama results](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/README.md) remain the saved comparison baseline; Llama was not rerun or placed inside a guest in this step.

## Where computation happens

```
ARM vCPU: choose job and insert previous prediction
    → HVC inference request carrying native input IDs
    → host Swift: original checkpoint → Metal → raw logits and prediction
    → returned register value
ARM vCPU: record prediction and construct the next request
```

Prime inference is native Swift. The guest program and Hypervisor.framework bridge are native AArch64/C. Python prepares input-only requests and schedules batches; Ruby records process ownership, output and exit status. No Python model inference is involved in these Prime runs.

The model weights and GPU operations remain on the Mac host. This is a real guest-controlled inference service with shared pages and HVC requests, not an OS guest containing MLX or GPU passthrough. It needs no OS installer. Historical “Apple Paravirtual” Metal devices in hosted CI are a separate capability and are not proof of this custom bridge.

The signed helper uses its own `com.ergentics.prime.vcpu-inference` identifier and existing Ergentics Apple Development identity. Admission requires the exact identity/team, Apple signature, hardened runtime and hypervisor entitlement. It is a normal user-level host process, without App Sandbox containment. The existing Provenance app and its fixed-guest admission were unchanged; experiment runtime0008 is separate from installed application Build22.

## Failure handling checked live

Unsigned code, a wrong identifier, missing entitlement, malformed feedback slot and an unexpected target field were rejected before model or VM activity. Six separate mechanism fixtures also checked invalid counts, unassigned feedback, callback failure, final invalid output, altered guest data and timeout cleanup. A final invalid model symbol remains an accuracy failure even when the guest transport finishes successfully.

The timeout fixture slept inside a callback for10.2seconds: the watchdog requested exit, the returned callback was not resumed in the guest, the watchdog joined and VM/vCPU resources were destroyed. Those constant callbacks are explicitly mechanism fixtures; none is counted among the720 learned predictions. See [checks](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-vCPU-02/Checks/README.md).

## Saved runtime and replay

[Runtime0008](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/0008-prime-vcpu-runtime/BUILD.json) contains the signed executable, metallib, native source, fixed guest image and compile/signature records. It uses the unchanged checkpoint bytes in builds0006 and0007. All raw logits, inputs, guest registers, predictions and process receipts are retained here.

From this directory, verify the saved files:

```sh
/usr/bin/python3 Runtime/verify_snapshot.py
```

Run the same input-only suite again into a new directory:

```sh
/usr/bin/python3 Runtime/replay.py /absolute/path/to/new-vcpu-results
```

Replay uses the signed runtime and existing local checkpoint paths. It requires normal macOS Hypervisor/Metal access and refuses an existing output directory. It produces fresh raw evidence; this run's review is not automatically transferred to a new run. No training, model download, app replacement, upload or push was performed.

Replay and verification commands above are run from `/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-vCPU-02`.

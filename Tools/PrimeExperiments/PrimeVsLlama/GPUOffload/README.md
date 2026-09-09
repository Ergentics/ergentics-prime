# Typed guest GPU offload

GuestCompute/ implements a bounded real ARM guest request and returned-vector checksum. NativeGPU/ runs the original geometry field kernel on host Metal and records GPU and route timing separately. Admission/ retains the existing signed-helper policy. This is a compute operation alongside the Prime model runtime, not an Apple virtual graphics device.

The exact compiled signed runtime0013, inputs, raw vectors, guest records, timing samples and independent reviews are saved at:

/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-GPU-Offload-04

Replay with `python3 Runtime/replay.py /absolute/fresh/results` from this source directory or the saved report directory. The config points to the durable signed executable. Model inference, training, dependency installation and app replacement are not part of this diagnostic. Fresh source compilation requires `python3 GuestCompute/build_guest.py` then `python3 NativeGPU/build.py build02`; build helpers retain the existing source-bound predecessor path and installed Xcode SDK paths. Sign using the existing dedicated identifier/team and hypervisor entitlement before a live run.

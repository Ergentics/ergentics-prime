# Live Prime versus older Llama experiment source

Prime inference runs in native Swift on Metal. The older Llama fine-tune runs through its retained Python MLX runtime on Metal. Python schedules input-only cases and scores saved predictions; Ruby supervises bounded worker processes. No scoring target is sent to either model.

`NativeSwift/` retains the actual compiled source, build helper and compile bindings. `Runtime/` contains the serial driver and Llama comparator. `Inputs/` contains the fixed80-case symbolic diagnostic; `References/` is for preparation and post-run scoring. The separate plain-arithmetic comparator is retained under `Plain-Arithmetic-Control/`.

From this directory, run `/usr/bin/python3 Runtime/replay.py /absolute/path/to/new-results` to create a fresh offline main-suite run using the original local model paths in RUN-CONFIG.json. This requires the retained builds and Metal access on this Mac. Do not overwrite an old result directory. Native compilation reuses the recorded local SwiftPM objects; no package install or training step is involved.

The scored run, raw logits/text, model bytes, executable builds0006/0007 and verification commands are saved at:

/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01

See the tracked report at `docs/experiments/2026-09-08-prime-v-llama/README.md`. Completed host inference and feedback do not imply guest hypervisor execution, app integration or formal gate authority. Earlier evidence retains its own status.

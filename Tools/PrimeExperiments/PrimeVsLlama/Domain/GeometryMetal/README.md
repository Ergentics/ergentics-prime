This standalone comparison reuses geometry-app's real host Metal field kernel. It compares 200 deterministic sample points against the original CPU potential/gradient formulas, log-sum-exp potential and finite-difference gradient. It performs no model inference, training, guest launch or CPU fallback.

The original source and CPU functions are retained under `Original`; `PROVENANCE.json` pins the geometry repository revision and source hashes. `ADAPTER.patch` shows all changes. The MSL kernel is unchanged. The adapter adds bounded finite input validation, a 4096-point cap, explicit command-buffer completion/error checks, finite result validation and dispatch/device observations. Its single queue/pipeline is retained for the run.

Build only: `python3 build.py`. Compilation has two Swift threads and a fixed timeout. This command does not initialize Metal or run the executable.

Run after build: `build01/GeometryMetalComparison --output-directory /absolute/fresh/output`. The parent directory must already exist. The executable has a 60-second hard alarm; use the existing owned-process controller for exact reap and retained stdout/stderr. It rejects zero/unknown arguments and existing output directories.

The run writes the exact inputs, six complete typed binary arrays, their hashes, 14 invalid-input outcomes, actual GPU submission/completion metadata and every predeclared comparison tolerance/max error in `result.json`. A failed initialization, command, result or comparison exits70; it never treats unavailable Metal as a pass. No device performance conclusion follows from one dispatch.

The current Prime guest ABI returns one token ID. Geometry potentials and gradients are vectors of floats. A future typed HVC service requires its own bounded vector request/reply and integrity join. This comparison does not pretend the current token ABI can represent those results, and it is not an Apple virtual GPU device or an increase in neural geometry knowledge.

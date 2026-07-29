# Prime execution architecture

The implemented authority chain is intentionally narrow:

1. `PrimeCore` defines exact profiles, factorized controls, arm mechanics,
   artifact schemas, mutation contracts, and fail-closed validation.
2. The outer Swift supervisor validates the independently reproduced MLX
   bundle, publishes that exact tree and its own exact executable into the
   descriptor-rooted artifact directory, rejects coverage/profile/sanitizer
   instrumentation in its loaded Mach-O image, and launches the staged
   executable beside the staged bundle without a shell.
3. The staged worker independently resolves and verifies its own sibling
   `mlx-swift_Cmlx.bundle`, rejects alternate loader paths and unsafe
   filesystem metadata, then acquires the Metal lease and performs MLX work
   without Python or shell scientific authority.
4. The worker reverifies its live loader context and bundle after execution.
   The supervisor then separately verifies the staged executable binding,
   target-local alternate loader paths, and exact immutable bundle tree before
   any final GROUNDED or ABSTAIN publication. It does not treat the
   supervisor's own Bundle/framework/cwd state as evidence about the exited
   child.
5. Immutable mechanics receipts bind source, executable, configuration, both
   pinned MLX bundle artifacts, factorized seed records, device observations,
   and optimizer state observations. Missing observations remain `nil`; they
   are never rewritten as `false`.

The first-party tokenizer/corpus, training receipts, independent Swift
evaluator, raw fixed-cap/EOS generation artifacts, statistical battery,
triadic audit, SZ fingerprint, and mutation-sweep receipts are subsequent
admission stages. They do not exist yet and are not implied by a successful
allocation probe. The Engine can recommend a later arm only after those
corresponding artifacts exist and resolve.

## Admission sequence

- mechanics/allocation calibration;
- factorized-seed isolation;
- fixed-token short-horizon calibration;
- calibration-bound matched-active-wall comparison;
- convergence-capped execution only after exact optimizer resume exists;
- exhaustive 18,432-row evaluation of a preregistered candidate;
- independent Swift regrade, statistics, SZ fingerprint, and mutation sweep.

The three fidelity arms are mechanisms, not arbitrary budgets. Wall and
convergence bounds are derived from a completed fixed-token calibration and
must align to optimizer-step and curriculum-block boundaries.

## Optimizer checkpoint admission

Optimizer checkpoint admission is separate from the Metal allocation result.
The stock lane may read and serialize `AdamW.innerState()`, but anonymous
read-only arrays are not a supported restoration schema. Prime does not
reinterpret MLX's public-for-cross-module `_updateInternal` implementation
hook as an application API.

The admission sequence is:

1. bind the exact dependency revision, audited upstream source identities,
   and the complete Prime Swift source snapshot to the embedded Release
   source identity;
2. stage and bind the exact pinned MLX metallib under the frozen optimizer
   probe runtime role, because the maintained scheduler requires it even for
   CPU-scoped tensors;
3. run a deterministic maintained AdamW step in a Swift writer process;
4. publish model and moment safetensors, the writer PID, and observed CPU
   device/stream state with an independent logical tensor catalog;
5. reload and exact-compare them in a fresh Swift verifier process, bind both
   child records, and reconcile both reported PIDs to the supervisor's
   launched processes;
6. restore the model through the maintained typed module API;
7. require a maintained named optimizer-state import API before attempting
   `N -> checkpoint -> restart -> N+1` trajectory identity.

Steps 1 through 6 can be grounded with stock `mlx-swift` 0.31.3. Step 7 cannot,
so the gate is `ABSTAIN` and convergence-capped or resumable training remains
unauthorized. The parent publishes that receipt and exits with status `2`, so
exit-status-only automation cannot promote the API-limit result. A future
Ergentics-pinned MLX fork may add only the typed
state-import seam while preserving the maintained AdamW arithmetic; it must
pass exact uninterrupted-versus-restarted trajectory comparison on a tiny
model before any 3B checkpoint I/O.

## Threat boundary

The staged-image contract covers accidental and persistent mutation through
exact tree, owner, mode, link, ACL, xattr, environment, loader-shadow, and
pre/post hash checks. The same user must retain write authority over the
artifact root so the worker and supervisor can publish receipts. A malicious
concurrent process running as that same user could attempt a transient
swap/load/restore attack; resistance to that actor is not claimed. Closing
that boundary requires a separately isolated runtime identity or exact
loader-return attestation from the maintained MLX runtime.

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

## Threat boundary

The staged-image contract covers accidental and persistent mutation through
exact tree, owner, mode, link, ACL, xattr, environment, loader-shadow, and
pre/post hash checks. The same user must retain write authority over the
artifact root so the worker and supervisor can publish receipts. A malicious
concurrent process running as that same user could attempt a transient
swap/load/restore attack; resistance to that actor is not claimed. Closing
that boundary requires a separately isolated runtime identity or exact
loader-return attestation from the maintained MLX runtime.

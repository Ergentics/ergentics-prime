# Prime execution architecture

The implemented authority chain is intentionally narrow:

1. `PrimeCore` defines exact profiles, factorized controls, arm mechanics,
   artifact schemas, mutation contracts, and fail-closed validation.
2. A compiled Swift supervisor launches the exact same hashed binary as a
   worker, without a shell, and enforces the hard process deadline.
3. The worker acquires the Metal device lease and performs MLX work without
   Python or shell scientific authority. A development shell may invoke that
   exact hashed supervisor but cannot select scientific knobs.
4. Immutable mechanics receipts bind source, executable, configuration,
   factorized seed records, device observations, and optimizer state
   observations. Missing observations remain `nil`; they are never rewritten
   as `false`.

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

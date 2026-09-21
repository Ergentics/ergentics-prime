# Independent receipt verifier successor

This offline successor separates two facts that must never be collapsed:

- `DeclaredTraceCoverage` can be checked over exact committed bytes.
- `RuntimeAttemptCompleteness` remains `UNASSESSED` because a caller-built graph
  cannot prove that no real operation was omitted before observation.

The verifier is a separate crate-free Rust process. It receives one fixed
stdin frame, independently parses and re-encodes the canonical CBOR, rebuilds
the three-leaf Merkle commitment with an in-tree SHA-256 implementation, and
reconstructs the deny-only Riemann predicate. It has no argument, environment,
path, file, network, persistence, child-process, GUI, app, or guest protocol.

The Rust binary is a test resource only. Xcode does not build it and the app
target does not depend on it. The hostless Swift test harness validates its
frozen identity, sends exact frames through pipes, owns a five-second deadline,
and reaps only its direct child. It attempts a four-second operation deadline
inside a five-second userspace horizon and permits no blocking post-KILL wait;
entered kernel calls are not externally bounded. Passing is local mechanics
evidence, not a
mathematical proof, runtime noninterference, or Gate-E authority.

The pinned compiler is reused from the previously retained Rust 1.98.0 archive.
The missing official host standard library is materialized into a new disjoint
prefix. Cargo, registries, rustup, Homebrew, system locations, shell profiles,
and the sealed freestanding guest toolchain remain untouched.

Independent review narrowed the original process-wide I/O and generation-join
wording before the selected binary was built. `contract-correction.json` is the
non-destructive correction: structural receipt joins and deterministic CBOR
set semantics pass, while Swift's unique domain-array order, per-access
generation/transition identity, kernel-call bounds, and process-wide runtime
syscall completeness remain unassessed. `result.json` records the two
byte-identical Rust builds,
Debug/Release hostless round trips, zero entered signals, and the retained
limits. Its SHA-256 is stored separately so the JSON never hashes itself.
`reviews.json` is a successor receipt over that exact result and records the
three independent PASS verdicts plus the corrections that made convergence
possible.

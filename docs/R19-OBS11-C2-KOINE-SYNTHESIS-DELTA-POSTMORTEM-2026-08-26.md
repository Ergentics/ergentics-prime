# R19 OBS11 C2 Koine synthesis and delta postmortem

This is a disposable prose projection of the canonical postmortem data. It
does not supply facts, resolve unavailable evidence, feed a controller, close
authority, authorize a successor, or change Gate E.

Normative exact JSON source (pretty UTF-8 JSON with terminal LF; compact
canonicalization is limited to the hash inputs named in the record):
`artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26/r19-obs11-c2-koine-synthesis-delta-postmortem.v1.json`,
SHA-256
`ac9f44203101c6168042ccf2d69b7dfc1dc72892ed453e12107df8c097daeec5`.
Final read-only validation receipt:
`artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26/r19-obs11-c2-koine-synthesis-delta-validation.v1.json`,
SHA-256
`9d217645452b3f0e8defb6eea041e1257d452485ee42f79811b180cc8405ac54`.
Evidence predecessor: commit
`b8dcbc8805d096bc466a2ec1f26e657dee3b64e6`, tree
`0babf8d9d989aa8f767000ef521e9ecc05d73a8e`.
A separate noncircular projection receipt binds the exact Markdown bytes,
source and validation digests, rendered claim set, section map, and ordered
validation check IDs. Its own digest is deliberately not embedded here.

## Outcome first

The C2 v6 failure was a narrow language/API defect, not an observed TOCTOU,
kernel, governor, or scientific failure. `IO.new(fd)` returned a base `IO`;
Apple Ruby 2.6 has no `IO#chmod`. The first missing-method dispatch occurred
in `ROOT_CREATION` before harness admission or child spawn. The root was
created, recovery reached the pre-99 snapshot, containment retained one
unsealed staging leaf, and the runner exited `70`.

The single selected successor design is:

1. use a fresh version and namespace;
2. remove the redundant root `0700` reassertion after exclusive
   `mkdirat(..., 0700)` and retain exact held/named admission checks; and
3. route the two real mode changes—leaf `0600 → 0400` and terminal root
   `0700 → 0500`—through one fixed-arity, descriptor-bound `fchmod` helper
   with exact errno capture and held `fstat`/vnode revalidation.

That is a model result, not implementation or launch authority. The retained
v6 namespace remains consumed and may not be repaired, renamed, sealed,
cleaned, or retried. Authority remains `00000000`; science and Gate E remain
`ABSTAIN`.

## Language comparison

| Layer | What it does well | Failure surface or limit | Selected role |
| --- | --- | --- | --- |
| Apple Ruby 2.6 | Small closed orchestration, canonical JSON, SHA-256, ordered fail-closed checks | Dynamic receiver methods are not proven by parsing; Fiddle ABI declarations are manually typed | Retain only for the minimal fresh successor after moving mode semantics to one fixed-arity helper |
| Swift | Closed enums, unique descriptor-owner types, compile-time member checking, explicit transition and errno models | Raw descriptors still require kernel postconditions; imported variadic interfaces remain unsafe | Long-term sole live state-machine owner, not a reason to rewrite this consumed slice |
| Fixed-arity C | Header-checked Darwin ABI and a very small syscall surface | An `int` does not prove vnode kind; policy and hashing do not belong here | Narrow in-image primitive for `fchmod`, called by the sole owner |
| Koine pure relation model | Predicate replay, contradiction detection, and minimal-delta synthesis over immutable bytes | Cannot establish host ABI, inspect a live descriptor, or own any process | Postpublication differential oracle only; no local implementation exists yet |
| Canonical JSON | Exact typed values, scopes, framing, hashes, and portable joins | Representation does not observe or validate the kernel | Sole immutable fact/interchange bytes for this postmortem |
| SQLite/graph | Foreign-key joins, lineage queries, display, and contradiction views | Rebuildable projection only; database bytes are not semantic authority | Optional read-only query layer after canonical validation |
| Markdown | Causal explanation for a human reader | Lossy and ambiguous unless every sentence resolves to claim IDs | Last, disposable projection; never parsed back into state |

The boundary that follows from the comparison is:

```text
Darwin kernel
    ↑ fixed-arity C: syscall + errno + immediate FD postcondition
    ↑ Swift: one typed live owner (long-term)
    ↑ canonical JSON: immutable evidence
    ↙                                  ↘
SQLite/graph read-only views       Koine pure differential oracle
no controller feed                no observation, actuation, veto, or authority
```

## The synthesis, not just the label

The normative record freezes ten hard constraints, including descriptor-only
mode mutation, fixed arity, exact errno, post-call vnode joins, one live owner,
fresh namespace, no retry, and unchanged authority. It then solves a
lexicographic objective:

1. satisfy every safety and epistemic constraint;
2. minimize live ownership surfaces;
3. minimize changed mode-transition sites; and
4. maximize ABI checking without expanding this slice.

| Candidate | Decision | First reason |
| --- | --- | --- |
| D0: no source change | Reject | Required transitions still dispatch absent `IO#chmod` |
| D1: named-path `File.chmod` | Reject | Breaks descriptor ownership and reintroduces path rebound |
| D2: open or cast a second `File` receiver | Reject | Mode change no longer belongs unambiguously to the already-held owner |
| D3: delete the redundant `0700` reassertion; use one fixed-arity `fchmod` helper for the two real transitions | Select as the minimal fresh-successor design | Satisfies the constraints with one owner and the smallest meaningful delta |
| D4: rewrite this runner as Swift plus C | Defer | Strong long-term boundary, but not the minimal correction |
| D5: add a live Koine/Ruby shadow | Reject | Recreates two owners |
| D6: pure Koine differential report after publication | Select as optional and disjoint | Adds contradiction checking without live capability or authority |

The Koine contract is finite: immutable witness bytes, content-addressed
states/transitions/witnesses, baseline and hypothetical successor models,
claims, Merkle commitment, transition chain, and authority `00000000` go in.
A disjoint canonical report containing hash checks, predicate results,
unknowns, removed/added failure surfaces, and one of
`MODEL_CONSISTENT`, `MODEL_INCONSISTENT`, or `ABSTAIN_UNKNOWN` comes out.
There are no paths or descriptors as capabilities, filesystem observations,
libproc calls, spawn, wait, signal, poll, controller feed, or authorization.

## Exact state and transition delta

```text
S0 readiness committed; v6 root absent at candidate freeze;
   runner-internal pre-mkdir absence is statically derived;
   a separately retained outer-final-preflight observation is unavailable
  → T0 exact outer entry consumes the one-shot
S1 runner entered, no retry
  → T1 mkdir/open succeeds; IO#chmod predicate is false
S2 recovered pre-99 root: 0700, nlink 2, 64 B, empty
  → T2 staging bytes retained; sync completion unavailable;
       0400 transition, fixed-99 publication, and 0500 seal are false
S3 final retained root: 0700, nlink 3, 96 B, one 0600 staging leaf
```

The lifecycle graph is bipartite: state nodes connect only to transition
nodes and transition nodes only to states. A second bipartite evidence layer
connects semantic nodes only to exact witness nodes. There are no direct
state-to-state, transition-to-transition, or witness-to-witness edges.

All four states carry explicit epistemic-class arrays and hash-chain ancestry.
The thirteen state, transition,
and witness nodes are content addressed with the repository's length-framed
identifier primitive. The Merkle graph domain is
`ergentics-r19-obs11-c2-postmortem-graph-v1`; sorted-leaf ordinals are
zero-based. Raw-address-sorted RFC6962-shaped commitment:

- node count: `13`
- ordered-address-list SHA-256:
  `f08842804c737747edbbd97a615cc238fed65151e8f5a662332398925fdd86cc`
- Merkle root:
  `a94600285fa1b60851a6db9a380456c9fa4553caca3fb9c5960cd3b521436e2f`
- transition-chain tip:
  `a2ee1306a912c99fbb06aefea922fde0d77f1ab183a8df79125ae758ec68597d`

## What prose can do to the data

Prose did not cause the runner defect. Its risk is epistemic: if a sentence is
accepted as a fact, it can invent a witness edge, collapse time scopes, erase
operations, or promote unavailable evidence into a terminal conclusion.

| Unsafe prose | Actual predicate | Data corruption if accepted |
| --- | --- | --- |
| “The runner wrote this to stderr” | Outer capture is 987-byte combined/unattributed JSON+LF | Invents a stdout/stderr split |
| “No process/build/signal ever occurred” | Zero counts cover only this exact C2 attempt; runner/root/staging counts are positive; observers are outside that vector | Leaks scope and erases history |
| “The staging bytes were fsynced/crash-durable” | Source orders sync before chmod, but completion is unavailable | Promotes `UNKNOWN` to observed truth |
| “99-incomplete was published and the root was sealed” | Only an unsealed `0600` staging leaf exists; fixed 99 is absent | Creates a false terminal transition and possible false authority |
| “The embedded empty inventory is final” | Empty/nlink-2/64-B is pre-staging; final is one entry/nlink-3/96-B | Collapses two time-scoped states |
| “Git preserved mode 0600” | Git preserved exact bytes at tree mode `100644`; live inode mode was `0600` | Overwrites live metadata with archive metadata |
| “This was a scientific failure” | Classification is consumed infrastructure incomplete; science is `ABSTAIN` | Reinterprets infrastructure as science |

The enforced direction is one-way:

```text
exact evidence bytes
  → validated canonical claims
  → optional read-only SQLite/graph views
  → disposable Markdown
```

No reverse edge exists. A prose edit cannot change a predicate, witness,
scientific state, or authority. Such a change requires a new content-addressed
canonical claim record.

## Validation and the observer delta

The preliminary Apple-Ruby validator passed `102` read-only checks. The next
validator failed before semantic evaluation because it used newer Ruby
endless-method syntax; Apple Ruby 2.6 rejected `def cbytes(value) = ...`.
That observer defect performed no filesystem mutation and remains in the
normative record rather than being hidden.

Classic `def ... end` validators then passed `82`, `98`, `117`, `143`, and
finally `147` checks. The first four were superseded—not contradicted—by
claim-closure, graph-model, semantic prose-closure, and exact operation-vector
corrections. The final validation receipt retains all 147 ordered
check IDs and their hash rule, covering source/witness hashes and Git blobs,
duplicate-key parsing, explicit epistemic typing, exact S0 evidence grades,
pre99/final vnode and staging fields, node addresses, ancestry, both graph
bipartitions, scoped claims and section coverage, explicit Merkle parameters,
Merkle root, transition chain, synthesis selection, the exact predecessor
operation vector—including one outer attempt, three positive infrastructure
entries, and zero full-controller and post-exit active-match counts—and
semantic section coverage. Across all seven named
validator entries:

- successful validators: `6`
- observer syntax failures: `1`
- filesystem mutations: `0`
- Python entries: `0`
- controller, runner, Swift/SwiftPM, compiler, signal, cleanup, repair, and
  retry entries: `0`

Claim IDs rendered here: `C01`–`C15`. Their scientific and authority effects
are all `NONE`.

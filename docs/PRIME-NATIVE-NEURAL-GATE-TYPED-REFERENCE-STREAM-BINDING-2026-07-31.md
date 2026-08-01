# Prime Native Neural Gate Typed Reference and Stream Binding

Date: 2026-07-31

## Outcome

This additive Stage-B slice closes the next declaration and transport gap
without materializing a supervisor, worker, executable, output artifact, or
receipt. It adds:

- an exact-count incremental decoder for the two target-free schedule slot
  streams;
- a pure typed schema for the common replay capture/schedule reference;
- typed branch, role/path/content, and Release worker-source references;
- the exact ten-role, twenty-path corrected pre-receipt declaration matrix;
  and
- a supervisor-only sealed adapter that retains the existing held replay
  capture while joining the copied references and decoded stream identities.

Every aggregate candidate remains non-`Decodable`. Every copied reference is
non-authoritative. Source/execution-binding V7 remains unissued, and every
process in the future ten-role topology remains absent.

Topology V7 and source/execution-binding V7 are separate version domains.
Topology V7 is implemented as the additive declaration/decoder boundary in
this document; it does not issue source/execution-binding V7.

## Frozen identities

- topology V7,
  `prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`:
  `88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`;
- target-free schedule stream contract V2,
  `prime_stage_b_target_free_schedule_bounded_stream_transport_v2`:
  `ed897cba2313f25bfcf610a6eb1abcdc4c45eaee2524c758f49d515c0ca49331`;
- role/artifact source-reference contract V1,
  `prime_stage_b_role_artifact_source_reference_contract_v1`:
  `c6948fb552c78f16911f4846a5f6971ed6e69486aba5afbc2d40fe4c5f342cf8`;
  and
- retained reference authority V1,
  `prime_stage_b_retained_delivery_role_artifact_reference_authority_v1`:
  `ca0d27932e76d1b8b75cac65d9ff32413762bc377ed408ad16b065941facc830`.

Topology V1 through V6 and target-free schedule contract V1 remain exact
history. Validation, provenance-reseal, and Release-canary results are recorded
only after their final runs; no result is claimed here yet.

## Bounded target-free stream transport

The V1 schedule contract and its canonical identity remain exact history. The
additive V2 transport does not decode the large aggregate candidate JSON
arrays. It admits two independent `PRIMEIRM1` streams:

| Stream | Exact rows | Record cap | Aggregate record-byte cap | Framed-file cap |
| --- | ---: | ---: | ---: | ---: |
| raw prompt-only | 18,432 | 16,384 | 301,989,888 | 302,137,361 |
| outer correlation-only | 18,432 | 1,024 | 18,874,368 | 19,021,841 |

The combined framed-byte cap is 321,159,202 bytes. Descriptor drivers must
feed no more than 65,536 bytes at a time. The maintained framed reader rejects
a declared count other than 18,432 before any record callback. It bounds each
record and the aggregate before reserving record storage, hashes every framed
byte incrementally, retains only one decoded slot at a time, and poisons the
reader after any failure.

Raw decoding rederives the canonical prompt tokens, `PRIMECPI2` binding, and
`PRIMECOR1` correlation. Both streams require contiguous execution indexes and
unique correlations; raw additionally requires unique prompt bindings. Outer
decoding joins every correlation to the already admitted raw correlation at
the same index. The decoder then recomputes the raw candidate, outer candidate,
and delivery identities.

The scalar header is canonical JSON capped at 4,096 bytes. A trusted expected
header derived from the retained candidate pair is compared during decoder
initialization, before reader construction or slot work. This prevents an
internally consistent but unexpected header from forcing a full bounded parse
before rejection. The supervisor factory separately performs the bounded
canonical scalar-header preflight before retained-capture and full-pair work;
that cheap untrusted-input gate does not claim the trusted expected header was
already derived.

Successful stream admission is mechanics only. It does not establish source
origin, process delivery, target independence, execution, evaluation, `PASS`,
receipt authority, science, or product use.

## Typed reference boundary

`PrimeNativeNeuralGateRoleArtifactReferenceContracts` is an internal pure
target. It imports no `PrimeCore`, descriptor capture, source composition,
crosswalk, evaluator implementation, MLX, historical runtime, or product
authority.

Its common reference binds copied observations of:

- the V5 capture contract and capture identity;
- the complete replay-root scalar identity;
- the prompt-source binding;
- the `PRIMESCH1` schedule identity; and
- a self-derived canonical reference identity.

Each branch reference additionally binds the exact probe/verifier role and
raw, outer, and pair identities. Each realized role-artifact content reference
must bind the exact frozen schema, branch, path, owner, reader set, content
digest and count, immutable purpose, mode, and the common and branch reference
identities. Constructing such a value does not prove that the bytes exist.

The frozen declaration matrix contains exactly ten corrected process roles and
the exact twenty role-scoped paths independently declared by the raw,
evaluation, and terminal-receipt ownership contracts. Package-description and
historical-worker roles have explicit empty corrected-path arrays; this slice
does not invent replacement paths for their separately deferred evidence.

## Worker source references

The six future worker roles require four typed Release reference kinds:

1. Prime source snapshot;
2. `swift package describe` output;
3. compiled source closure; and
4. sealed worker executable.

The value schemas bind safe paths, content SHA-256 and byte count, purpose and
mode, Release configuration, source and embedded-source identities, the worker
role/target, exact ordered local dependency names, and the common
capture/schedule identity. The frozen declarations preserve package/topology
dependency order rather than treating dependencies as an unordered set.

At topology V7 no actual worker target existed, so the frozen inventory
contained no realized source reference, closure, or executable value. V11 now
adds the historical fixture worker target only as an unavailable compile
boundary; it still creates no realized source/execution reference or sealed
image. A whole-repository snapshot is not substituted for a compiled worker
closure, and a staged executable is not called a running mapped image.
Executable vnode, PID, same-process capture, delivery, death/reap, and result
evidence remain future runtime work.

## Retained authority and intentional terminal reachability

The supervisor-only authority target depends on the existing retained
target-free delivery authority. It recaptures the replay source before and
after projection, derives the common and branch references, validates the
exact raw/outer ownership paths, and privately retains the live capture
capability. Its capture-bound stream wrapper derives the trusted scalar stream
header from that retained candidate pair after the bounded scalar preflight,
then compares it before reader construction or framed-record callbacks. It
reconciles the finished admission to the common/branch identities, recaptures
again, and returns only a sealed non-`Codable` admission.

The pure reference target intentionally reaches the terminal-receipt
*declaration* target so the twenty paths can be checked against a third,
independently frozen list. This grants no publication function or receipt
authority. All terminal flags remain false, and neither reference target is a
package product.

## Authority ceiling

The following remain false:

- actual worker source pinning or executable binding observed;
- process or schedule delivery observed;
- worker, model, mutation, or evaluator execution;
- prompt-content target independence;
- accepted verdict or mechanics `PASS`;
- terminal receipt authorization or publication;
- source binding V7;
- scientific authority; and
- product authority.

## Next prerequisite

The next bounded slice is:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

Only after those semantic schemas and disjoint producer/detector ownership are
frozen should Prime consider materializing the historical worker and paired
Stage-B supervisors/workers. Live Release closure, executable, process, and
artifact evidence must then fill the typed references; the declarations in
this slice cannot stand in for that evidence.

## Recorded V7 closeout and additive V8 continuation

The pre-run statement in the frozen-identities section records this document's
authoring point. The completed V7 closeout subsequently used embedded source
identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`
and passed the actual-package Release canary at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`.
The preceding V6 checkpoint was 40,100 bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`.
Both retain secure-capture-only authority.

The prerequisite quoted above is now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
V8 preserves this document's exact ten-role/twenty-path reference declarations,
freezes the deferred semantic schemas, and adds four internal Swift targets:
the narrow label-free, presence-only surface contract; the semantic
catalog/identity contract; the corrected producer; and the independent
detector. The corrected mutation catalog/control contract has SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on surface contracts and transitively only on
surface plus replay mechanics. It cannot reach catalog/identity, expected-leg
mapping, replay-artifact contracts, or producer.
Its only public entry is exact 15-case batch detection; the single-triplet path
is private. Every full bound baseline/restored context must be identical in
bytes and binding throughout the batch, and mutated surfaces must be pairwise
distinct. Wrong counts, duplicate cases, per-case reference-hash or seed drift,
and cap drift other than exact 63 against baseline 64 fail closed. Permutation
invariance is verified. `Label-free` excludes explicit mutation IDs/labels,
arbitrary prediction strings, and per-case caller-controlled context.
Actual Release source references are still absent and non-authorizing. Local
in-memory mutation mechanics are not worker/process delivery, durable artifact
evidence, a verdict, or receipt; source/execution-binding V7 remains unissued.
That final-validation absence was the V8 prevalidation authoring state.
Completed final V8 validation is recorded canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

The typed reference declarations cannot promote a count-only result.
`countDerivedLabel` has exact scope `provisional_count_only_non_authorizing`,
and ten bare true legs remain `ABSTAIN`. `GROUNDED` requires verified/durably
published per-leg evidence, weighted-statistics recomputation, stable-greedy
and behavioral fixed-prompt predicates, model capability including exact
abstention decisions, mutation-sweep and source-bound-leg evidence, distinct
implementation families, and four-tier audit state. The historical gate
additionally requires all five aggregate references verified/durably
published and model execution observed. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API stays
compatible but always returns `ABSTAIN` with only the provisional scope and
cannot return generic `GROUNDED`. Those bindings remain absent, so mechanics
`PASS`, scientific authority, and product authority remain false.

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it while actual Release source references and source
binding V7 remain absent. Topology V10 then materializes only the isolated
historical source closure; those Release bindings remain absent. Its next
prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
Topology V11 now source-binds the fixture and adds only an unavailable target;
the V7 realized-reference fields remain absent. The V11 next prerequisite was
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
V12 resolved only that design/source-contract boundary. Topology V13
materialized the exact source-only exporter. V14 now source- and compile-binds
one private cross-file worker/exporter call edge. That edge remains unreachable
from the exact V11 `main`, which exits `78`. The V7 realized-reference fields
and authority remain absent. The V14 prerequisite is recorded in [Prime Native
Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
V15 source-binds only the projection design; its current prerequisite is
recorded in [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md).
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).

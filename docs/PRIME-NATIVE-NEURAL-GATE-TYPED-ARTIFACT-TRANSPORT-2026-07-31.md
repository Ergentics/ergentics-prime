# Prime Native Neural Gate Typed Artifact Transport

Date: 2026-07-31

## Outcome

Stage B now has two pure Swift transport-foundation targets plus one
trap-free composition consumer:

```text
PrimeNativeNeuralGateReplayArtifactContracts
    dependencies: []

PrimeNativeNeuralGateReplayTransport
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateReplayComposition
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics
```

No production or execution target imports the transport. The contract target
contains typed artifact identities, paths, roles, ownership, reader sets,
bounds, and non-authorizing namespace policy. The transport target validates
exactly three bounded canonical manifest envelopes and exactly three pathless
record shapes: prompt-only row, outer-evaluation row, and raw-execution
reference. The transport also owns the shared producer/decoder canonical
codec; the composition target owns the strict prompt schedule and exact
outer/raw/validated-sidecar join. None executes a worker, reads a file,
streams a large payload, invokes MLX, imports PMHNP, publishes an artifact, or
creates a receipt.

This closes the manifest/record-shape, shared-codec, strict-schedule, and
in-memory exact-join slices of the prior Stage-B prerequisite. It does not
implement Stage-B execution. Exact composition mechanics are recorded in
`PRIME-NATIVE-NEURAL-GATE-REPLAY-COMPOSITION-2026-07-31.md`.

## Frozen identities

- historical topology V1 remains unchanged at SHA-256
  `48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`;
- topology V2 has canonical SHA-256
  `abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`;
- topology V3 has canonical SHA-256
  `b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`;
- composition V1 has canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- historical replay plan V5 and source-binding V6 remain unchanged;
- historical replay-output and path-classification V3 remain unchanged;
- the non-authorizing semantic-namespace overlay V4 has canonical SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`.

Topology V3 remains globally `planned_not_materialized` because the execution
graph is incomplete. It preserves V1 and V2 exactly and marks the contracts,
bounded transport, shared codec, and replay composition implemented.
`executionImplemented` is false and source binding V7 is unissued.

Semantic namespace V4 is an incomplete overlay, not an execution artifact,
source-binding version, or receipt. Its identity embeds the complete 116-spec
table, exact historical 46-case and corrected 15-case mutation catalogs,
historical and corrected leg domains, and the three implemented record-schema
IDs. It preserves historical V3 identity while making changes to the concrete
namespace semantics change the V4 digest.

## Decoder boundary

The in-memory artifact decoder accepts only a V4 artifact whose decoder mode
is `bounded_canonical_json`. Its hard maximum is 1,048,576 bytes, nesting depth
is 16, individual JSON string content is limited to 65,536 encoded bytes, and
the lexical structural-token ceiling is 700,000. All four limits are embedded
in semantic namespace V4. It rejects:

- empty input, UTF-8 BOM, invalid UTF-8, and a non-object root;
- excess bytes, depth, string content, or structural tokens;
- duplicate, unknown, missing, or `null` fields through exact canonical
  decode/re-encode equality;
- alternate key order, whitespace, escaping, number, or boolean encodings;
- wrong schema version, artifact kind, path, digest syntax, byte count,
  ordinal, chunk order, partition count, or record count;
- any transport field that attempts to authorize execution, mechanics
  `PASS`, `GROUNDED`, mutation detection, science, product use, or a receipt.

The bounded artifact entry point implements exactly three manifest schemas:
prompt-only fixture, outer-evaluation, and seed-scoped raw-execution. The
pathless record entry points implement exactly the corresponding prompt,
outer-evaluation, and raw-execution row shapes. Descriptor-streamed record
payloads, source-bound logit codecs, mutation payloads, historical
observations, MLX observations, statistics/verdict observations, worker and
process records, results, and the receipt all fail before JSON parsing with
their frozen decoder mode. A manifest can bind the paths, counts, sizes, and
digests of an admitted record stream; this target does not read or decode that
stream.

## Record semantics

The prompt row has only the canonical prompt-token array. Replicate seed is
replicate-scoped and is rejected at the row boundary together with dedicated
target, correlation, regrade, caller-budget, support, and termination fields.
Valid prompt bytes can still contain any string, including target-like text,
so the decoded value explicitly reports
`targetIndependenceEstablished == false`. Content independence belongs to a
future cross-artifact derivation verifier, not this shape decoder.

Outer evaluation rows carry correlation and expected completion separately.
Raw execution rows carry only seed, execution index, prompt/trace digests,
generated byte tokens, and exact EOS-or-fixed-cap decision accounting. The raw
row cannot carry expected completion. Its seed must equal the caller's
seed-scoped stream context, so a valid row from another replicate is rejected.

The contract target freezes mutation identity as
`(arm, one_based_ordinal, mutation_id, expected_failed_leg_id)`. The copied
46-case historical and 15-case corrected catalogs are reconciled in tests
against the existing frozen Swift authorities. This is namespace and identity
authority only. No mutation-delta schema, producer, detector, or result
decoder is implemented.

The historical and corrected leg domains are likewise frozen in semantic
order, including exact `NL1` through `NL10` ordering. No historical
observation, MLX observation, statistic, verdict, or receipt value can be
decoded in this slice. Those schemas remain explicit deferred keys rather
than permissive placeholder records.

Prompt-only, outer-evaluation, and each per-seed raw-execution payload are
separate `prime_raw_utf8_length_framed_ordered_multiset_v1` streams. Each
stream is independently sorted by its own raw record bytes; cross-stream
positional zipping is forbidden. Composition V1 now defines
`execution_index` as the strict ordinal of canonical prompt-row JSON bytes in
the caller-provided in-memory sequence, requires exact `0..<18_432` coverage,
derives target-free `PRIMECOR1` identity from index plus prompt binding, and
joins outer/raw/sidecar records against that identity. It reconstructs every
full-logit decision and requires the exact corrected trace. Duplicate, missing,
or conflicting indexes fail closed. Descriptor-rooted streaming validation
must still prove that the supplied record arrays came from the bound durable
streams; composition itself does not establish artifact origin, lawful
schedule-capability delivery to disjoint producers, independent
prompt/expected-completion binding, or prompt-content independence.

## Package-capture status

The 27,015-byte package-description capture with SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`
is preserved as the last accepted topology-V1 actual-package secure-capture
checkpoint. It predates the two V2 targets and is not current V2 evidence.

After the complete topology-V2 source was resealed, the Release canary passed
with byte-identical probe/verifier package-description output: 28,589 bytes,
SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
This is the last topology-V2 actual-package secure-capture reseal and predates
the composition target and topology V3. It remains
secure-capture evidence only, not V6/V7 selected-source execution-graph proof;
source binding V7 is unissued.

After the complete topology-V3 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 29,905 bytes,
SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the current accepted topology-V3 actual-package secure-capture reseal.
It validates only the secure-capture substrate on the pinned host. It is not
V6/V7 selected-source execution-graph proof; it does not issue source binding
V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.

## Remaining evidence gaps

- implement descriptor-rooted, bounded streaming validation for the global and
  chunked raw-UTF8 invariant formats and bind the resulting validated
  capabilities to composition V1;
- bind durable source-artifact origin for the already integrated in-memory
  lossless logit dictionary/chunk/manifest codec without widening the pure
  composition closure;
- freeze lawful delivery of the target-free schedule/correlation capability to
  the disjoint producers and an independently source-derived prompt/target
  crosswalk before any evaluation promotion;
- freeze and implement mutation-delta, historical-observation, MLX-observation,
  and corrected statistics/verdict schemas before any of those keys can admit
  bytes;
- freeze corrected process ownership, evaluation ownership, replacement
  process count, result records, receipt ownership, and receipt-last
  publication;
- implement the corrected 15-case mutation producer and an independently
  implemented detector in disjoint targets;
- derive the historical gate/carrier seam and 46-case raw mutation material
  from pinned donor source rather than hand-porting it;
- only then materialize role-scoped workers, probe, verifier, complete
  path/metadata/content inventory, full-fixture MLX observation, and terminal
  composition.

The next implementation prerequisite is therefore:

`implement_descriptor_rooted_bounded_invariant_stream_decoders_bind_validated_stream_capabilities_and_lawful_schedule_delivery_to_frozen_composition_then_freeze_independent_prompt_target_crosswalk_without_materializing_workers`

The shared codec, schedule, target-free correlation derivation, and join are
now frozen. The next slice must prove the durable origin and exact global/chunk
partition of the independently ordered streams, lawful schedule-capability
delivery, and the independent prompt/target crosswalk before those in-memory
capabilities can be treated as artifact or evaluation evidence.

## Workflow boundary

Publication remains explicit: local Git for intentional commit/push and the
signed-in GitHub app for PR checks and merge. A future credential-free Swift
Git preflight belongs in `ergentics-workstation` as a read-only outer observer.
It may report repository root, branch/upstream, HEAD, cleanliness or exact
diff state, author identity, source-seal agreement, and named test evidence.
It must not own GitHub credentials, push, mutate a PR, approve, or merge, and
it does not enter Prime's scientific evidence graph.

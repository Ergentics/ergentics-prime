# Prime Native Neural Gate Replay Composition

Date: 2026-07-31

## Outcome

Stage B now has a pure Swift composition boundary for the three independently
canonicalized V4 corrected-replay record streams plus a separately validated
in-memory logit sidecar. It implements:

- one producer/decoder-shared bounded canonical JSON codec in
  `PrimeNativeNeuralGateReplayTransport`;
- one strict prompt-derived execution schedule over exactly 18,432 canonical
  prompt records; and
- one exact, keyed outer/raw/validated-logit-sidecar join that reconstructs
  every decision and requires the corrected `PRIMECRT4` trace to match.

The new package target is:

```text
PrimeNativeNeuralGateReplayComposition
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics
```

It has no dependency on `PrimeCore`, corpus/fixture authority, evaluation or
regrade mechanics, the prompt solver, MLX, a historical runtime, PMHNP, a
worker, a process supervisor, or a receipt writer.

This is repository mechanics, not Stage-B execution. No descriptor-rooted
record stream or durable logit artifact is read by this target. Its validated
values are deliberately non-`Codable` capabilities and keep durable origin,
prompt-content target independence, model execution, mechanics `PASS`,
publication, science, receipt, and product authority false.

## Frozen identities

- semantic artifact namespace V4 remains byte-for-byte unchanged at SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`;
- composition V1 is
  `prime_stage_b_strict_prompt_schedule_exact_cross_artifact_join_v1`,
  canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- topology V3 is `prime_stage_b_trap_disjoint_topology_v3`, canonical SHA-256
  `b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`;
- topology V1 remains exact at
  `48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`;
  and
- topology V2 remains exact at
  `abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`.

Topology V3 remains globally `planned_not_materialized`, with
`executionImplemented == false` and source binding V7 unissued. It adds only
the already implemented shared codec and replay-composition target to the
package truth; it does not promote any planned worker or supervisor.

## V3 package-capture checkpoint

After the complete topology-V3 source reseal, the Release canary passed with
byte-identical probe/verifier package-description output: 29,905 bytes, SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the current accepted topology-V3 actual-package secure-capture reseal.
Topology V1 and V2 capture values remain historical checkpoints.

The V3 pass validates only the secure-capture substrate on the pinned host. It
is not V6/V7 selected-source execution-graph proof; it does not issue source
binding V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.

## Shared canonical codec

`PrimeNativeNeuralGateReplayTransportCodec` is the only bounded JSON producer
seam for the three implemented record shapes and their three manifests. Its
serialization contract is
`prime_stage_b_bounded_canonical_json_shared_transport_codec_v1`.

The codec accepts semantic fields, not a caller-authored wire envelope. It
derives schema and kind IDs, paths, chunk ordinals and counts, the exact record
count, and all false authority flags from frozen V4. For a raw row it derives
the decision count from termination and generated-token count; a caller cannot
supply that redundant field. A manifest input from the invariant codec is
treated as untrusted and must satisfy its exact identity, partition, ordinal,
count, digest, and byte bounds. Every produced value is decoded again through
the same bounded decoder before its bytes are returned.

Known-answer tests bind exact bytes for prompt, outer, and raw rows plus the
exact manifest byte count and SHA-256. Negative tests reject invalid
fixed-cap/EOS accounting, oversized semantic inputs before encoding, and
manifest count or ordinal changes. A future worker must use this codec;
hand-authored JSON is outside the contract.

## Strict prompt schedule

The schedule is not a row-ID order and is not inferred from outer, raw, or
sidecar records. It is the strict zero-based ordinal of each caller-provided
canonical prompt-row JSON record. A future descriptor decoder must prove that
this exact sequence is the durable prompt global stream:

```text
execution_index = ordinal(canonical_prompt_row_bytes)
```

`makePromptSchedule` requires exactly 18,432 records in strict raw-byte
lexicographic order. It validates only in-memory bounded shape, exact
count/order, codec round trip, corrected prompt-token derivation, and unique
`PRIMECPI2` bindings. It rejects any failure of those checks, recomputes the
invariant global-stream SHA-256, and derives a schedule identity from
`PRIMESCH1`, the big-endian record count, and the raw global-stream digest. The
magic and exact serialization are part of composition V1 and the schedule has
full known-answer SHA-256 coverage.
It does not validate a descriptor, filesystem object, manifest binding, or
durable source origin.

The schedule does not silently sort input. Sorting would conceal whether the
caller had actually validated the source stream. The resulting capability
therefore records exact coverage and strict order but explicitly records that
source-stream binding and mechanics `PASS` are not established.

The existing exhaustive logit-sidecar repository test historically emits
`rowOrdinal` in corrected fixture row-ID order. That remains valid mechanics
coverage for dictionary/chunk reconstruction, but it is not durable Stage-B
schedule authority. A future artifact producer must emit sidecar row ordinals
as the prompt-record schedule indexes defined here.

## Exact cross-artifact join

For one admitted replicate seed, the composition join requires:

- exactly 18,432 outer rows and a complete unique execution-index bijection;
- exactly 18,432 raw rows, a complete unique execution-index bijection, and
  the requested replicate seed on every row;
- a previously validated 18-chunk lossless sidecar containing exactly 18,432
  rows under the same replicate seed;
- globally unique outer correlation IDs;
- exact raw `PRIMECPI2` prompt binding at every schedule index;
- exact outer and sidecar correlation equality with the schedule-derived
  `PRIMECOR1` identity at every index; and
- exact equality between sidecar decision count and raw decision count.

`PRIMECOR1` hashes the big-endian execution index plus the raw `PRIMECPI2`
prompt-binding digest. It is target-free: neither producer chooses a free-form
coordination string. The pure derivation is available from replay mechanics,
but V4 does not yet lawfully deliver the prompt schedule capability to every
disjoint future producer. Composition V1 therefore records schedule-capability
delivery as false; this slice defines and verifies the identity without
claiming that a worker topology can produce it yet.

The join indexes each stream independently; input array order is irrelevant
and positional zipping is never used. It resolves every sidecar dictionary
index into the complete 512-value Float32 logit vector, reconstructs each
corrected completion decision, reruns
`PrimeNativeNeuralGateRawExecution.validate`, and then requires exact generated
tokens and `PRIMECRT4` trace SHA-256 equality with the raw reference.
EOS/fixed-cap shape is already fixed by raw decision/generated-token accounting
and reconstructed decisions. A copied correlation ID or self-consistent raw
summary cannot launder unrelated logits through this join.

Mutations cover duplicate or missing indexes, duplicate correlations,
cross-seed rows, prompt and trace digest changes, generated-token and
termination changes, sidecar correlation/count/seed changes, and an exact
Float bit-pattern change. The full 18,432-row join is exercised with outer and
raw inputs independently reversed to prove that the implementation is keyed,
not positional.

The join deliberately does not establish that an outer expected completion is
the source-authoritative target for the scheduled prompt. Swapping two expected
completions while preserving their indexes is outside the raw trace and cannot
be detected from these in-memory values alone. The result therefore records
corrected-fixture identity and outer expected-completion binding as false. A
separately derived prompt/target crosswalk is mandatory before grading or any
promotion.

## Remaining truth gap

The next implementation prerequisite is:

`implement_descriptor_rooted_bounded_invariant_stream_decoders_bind_validated_stream_capabilities_and_lawful_schedule_delivery_to_frozen_composition_then_freeze_independent_prompt_target_crosswalk_without_materializing_workers`

That slice must validate the descriptor-rooted global and chunk files, their
canonical record order, exact byte/count/digest partitions, and the durable
origin of the prompt, outer, raw, and sidecar inputs before handing non-writable
validated capabilities to composition. It must also freeze lawful delivery of
the target-free schedule/correlation capability to disjoint producers and an
independently source-derived prompt/target crosswalk. It must not turn decoder
success into prompt independence, model execution, an evaluation verdict, or a
receipt.

Only after that boundary is source-bound should Stage B freeze the remaining
deferred observation/result schemas, process/evaluation/receipt ownership, and
disjoint mutation producer/detector targets. The historical runtime and all
workers remain planned.

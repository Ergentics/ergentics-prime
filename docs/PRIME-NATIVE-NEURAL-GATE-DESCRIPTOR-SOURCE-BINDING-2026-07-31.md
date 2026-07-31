# Prime Native Neural Gate Descriptor Source Binding

Date: 2026-07-31

## Outcome

Stage B now has a Swift-only descriptor source boundary and an outer
source-composition adapter. The implemented targets are:

```text
PrimeNativeNeuralGateReplaySourceBinding
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics

PrimeNativeNeuralGateReplaySourceComposition
    dependencies:
      - PrimeNativeNeuralGateReplaySourceBinding
      - PrimeNativeNeuralGateReplayComposition
```

The pure `PrimeNativeNeuralGateReplayComposition` target remains unchanged in
authority and remains free of `PrimeCore`, filesystem, process, fixture,
evaluation, and model dependencies.

This slice implements no worker or model run. It creates no Stage-B process
record or receipt, does not issue source binding V7, does not establish the
corrected fixture identity or prompt-content target independence, and cannot
authorize mechanics `PASS`, science, publication, or product use.

## Frozen identities

- source-reader contract:
  `prime_stage_b_descriptor_rooted_exact_source_binding_v1`;
- outer source-composition contract:
  `prime_stage_b_descriptor_source_bound_schedule_delivery_v1`, canonical
  SHA-256
  `f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5`;
- unchanged pure composition V1, canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- topology V4:
  `prime_stage_b_descriptor_source_binding_topology_v4`, canonical SHA-256
  `8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`;
- topology V1, V2, and V3 remain exact historical contracts; and
- semantic artifact namespace V4 remains exact at SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`.

Topology V4 is still globally `planned_not_materialized` and keeps
`executionImplemented == false` and `sourceBindingV7Issued == false`.

## Descriptor admission

The source target accepts an already-admitted `PrimeArtifactRoot`, or creates
one from the URL convenience entry point. Child traversal, no-symlink lookup,
regular-file admission, exact owner/mode/link policy, ACL and extended-
attribute policy, descriptor-relative name-to-vnode checks, byte count,
SHA-256, and pre/post stability are delegated to
`PrimeArtifactRoot.withVerifiedArtifactDescriptor`. The source target does not
reimplement `openat` path walking.

`PrimeArtifactRoot.verifiedRootIdentity()` exposes a sealed value derived from
the held root descriptor. Each operation requires the root identity before and
after materialization to be identical. Each returned source capability records
the root identity plus exact admitted file observations. These observations
are not caller-authored booleans and are not serializable authority tokens.

The source target opens no writable artifact handle. Its only low-level system
operation is bounded reading from the borrowed, already-verified descriptor.

## Incremental invariant stream validation

`PrimeNativeNeuralGateInvariantFramedRecordReader` is the shared pure parser
for both frozen envelopes:

- `PRIMEIRM1` global stream; and
- `PRIMEIRC1` chunk stream.

It receives descriptor bytes in blocks of at most 64 KiB, retains at most the
current and previous record plus bounded unmatched records, and rejects before
record allocation when the declared length exceeds the schema-specific row
limit. The transport target owns those exact limits:

- prompt row: 65,536 bytes;
- outer-evaluation row: 8,192 bytes; and
- raw-execution reference: 8,192 bytes.

The reader verifies magic, declared count, chunk ordinal, per-record and
aggregate bounds, integer conversions, UTF-8, canonical order, exact EOF,
exact stream byte count, and exact stream SHA-256. A parse or callback failure
poisons the reader. It cannot resume or emit a validated summary after partial
failure.

Source binding holds the verified global descriptor while it opens each
verified chunk. Global and chunk records are compared byte-for-byte in
lockstep, including across chunk boundaries. Exact V4 partitioning is enforced
as four 4,096-record chunks plus one 2,048-record chunk. Complete invariant
stream bytes are never assembled in one `Data` value; the typed 18,432-row
result array is intentionally materialized for the existing pure composition
API.

`PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator` separately
reconstructs the exact `PRIMEIRM1` hash from one canonical record at a time.
The pure composition target uses it to check the descriptor-observed global
digest without re-encoding a second complete global stream.

## Sealed source capabilities

The source target returns separate, non-`Codable`, non-publicly constructible
capabilities for:

- prompt records, with each typed row's canonical-record SHA-256 and the exact
  global-stream SHA-256;
- outer-evaluation rows;
- one seed-scoped raw-execution stream; and
- one seed-scoped validated lossless-logit sidecar.

The logit path descriptor-binds its manifest, dictionary, and all 18 chunks,
then delegates semantic reconstruction to the existing frozen complete
sidecar validator. Unlike the invariant parser, that existing codec requires
bounded `Data` materialization of the dictionary and chunks. This slice does
not claim a non-materializing logit codec.

An individual source capability records `sourceStreamBindingEstablished ==
true`, but keeps durable replay origin false. Each capability is one separately
observed role; the four binds do not yet share a single held-root capture
session or a complete pre/post descendant inventory. Every fixture, execution,
evaluation, mechanics, receipt, science, and product flag remains false.

## Schedule projection and exact source join

The outer adapter reconstructs the unchanged pure V1 prompt schedule from the
sealed prompt capability. For every row it:

1. re-encodes the typed prompt row through the shared canonical codec;
2. requires the re-encoded record's SHA-256 to equal the source-bound
   canonical-record digest;
3. requires strict record order and unique `PRIMECPI2` prompt bindings;
4. derives the exact `PRIMECOR1` correlation identity; and
5. requires the incremental `PRIMEIRM1` digest to equal the held descriptor's
   global-stream digest.

The underlying V1 schedule remains non-authorizing and still records source
binding false. The outer wrapper, rather than mutating V1, carries the sealed
source identity.

Two asymmetric role projections are implemented:

- raw projection: execution index, prompt token IDs, canonical prompt text,
  `PRIMECPI2` binding, and `PRIMECOR1` correlation only; and
- outer projection: execution index and `PRIMECOR1` correlation only.

Neither projection contains an expected completion. The outer projection
contains no prompt text, prompt token IDs, or direct `PRIMECPI2` binding;
its `PRIMECOR1` value remains deterministically prompt-binding-derived and is
therefore linkable. They are typed in-memory projections, not observations of
delivery to a separate process; `processDeliveryObserved` remains false.

The complete source join requires prompt, outer, raw, and logit capabilities
to share one exact held-root identity and requires raw/logit replicate seeds
to match. It then calls the existing keyed V1 join. Array position is never a
join key. Root identity does not cover nested replacement between separate
bind calls, so the resulting four-source wrapper records exact capability join
true but single-capture epoch and durable artifact origin false. Independent
prompt/target crosswalk, expected-completion binding, prompt-content
independence, process delivery, model execution, mechanics `PASS`, receipt,
science, and product authority all remain false.

## Verification

Focused verification covers:

- every feed split point for known global and chunk streams;
- exact parity between incremental and frozen whole-buffer encoders/decoders;
- wrong magic, truncation, trailing bytes, early and repeated finish,
  consume-after-finish, callback failure/reentry, invalid UTF-8, ordering,
  count, length, aggregate, and overflow failures;
- parity acceptance for valid zero-length and duplicate ordered-multiset
  records;
- manifest/path/count/order/digest/size and global/chunk divergence;
- symlink, hard-link, writable-mode, wrong-size, wrong-hash, and typed-record
  mutation rejection;
- exact incremental prompt schedule equality and rejection of
  canonical-record-digest/`PRIMECPI2` digest-domain substitution;
- a real 18,432-row prompt/outer/raw/logit artifact publication and
  descriptor-source join;
- independently canonicalized input ordering, proving the join is keyed and
  not positional;
- root and replicate-seed substitution rejection; and
- same-root nested outer-artifact replacement between binds, including an
  expected-completion swap, proving the exact join cannot promote a set of
  separately captured capabilities to one durable epoch.

The focused replay family passed 54/54 before the complete package reseal.

## V4 package-capture checkpoint

After the complete topology-V4 source reseal, the Release two-role canary
passed with byte-identical probe/verifier package-description output: 32,735
bytes, SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is actual-package secure-capture evidence on the pinned host, not V6/V7
selected-source execution-graph reconciliation. It does not establish source
binding V7, execution, evaluation, publication, a receipt, reproducible-build
identity, network denial, Metal authority, scientific authority, or product
authority.

## Remaining truth gap

The immediate implementation prerequisite is:

`freeze_single_held_root_four_source_capture_inventory_session_then_freeze_independent_source_derived_prompt_target_crosswalk_in_trap_bearing_authority_target_without_materializing_workers`

The capture boundary must hold the admitted root and every required artifact
descriptor as one sealed input set, bind a complete exact inventory, and
revalidate the set before durable origin can become true. The crosswalk must
then be a separate trap-bearing target. It must bind prompt and
expected completion independently of raw execution, reject equal-length target
swaps, EOS omission, row-ID/order confusion, positional zipping, and digest-
domain substitution, and remain unreachable from the corrected raw-worker
closure.

After the crosswalk, Stage B still needs deferred mutation/historical/MLX/
statistics schemas, corrected process and evaluation ownership, replacement
process-count and receipt contracts, independently implemented mutation
producer/detector targets, role-scoped workers, probe/verifier, exact
inventory, actual process delivery, and receipt-last publication. None is
authorized by this slice.

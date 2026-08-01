# Prime Native Neural Gate Held-Root Crosswalk Authority

Date: 2026-07-31

## Outcome

The additive topology-V5 slice implements two Swift-only authority boundaries:

- `PrimeNativeNeuralGateReplayCaptureInventory` holds one admitted
  `PrimeArtifactRoot`, discovers the exact four-source file set, discards the
  discovery values, captures the complete 41-file descriptor-rooted inventory,
  rebinds the four sources while that retained capability is live, and requires
  an exact final recapture before returning a sealed result; and
- `PrimeNativeNeuralGatePromptTargetCrosswalkAuthority` consumes only that
  sealed capture plus the sealed corrected-fixture derivation, reconstructs the
  prompt schedule, performs the exact source-capability join, and binds each
  prompt to its independently source-derived expected completion without using
  row position as a join key.

This closes the held-root capture and prompt/target-crosswalk prerequisites. It
does not implement a Stage-B worker, process delivery, evaluation verdict,
receipt, or model run.

## Historical locks and package canaries

This is additive. No historical topology identity is rewritten:

- topology V1 remains SHA-256
  `48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`;
- topology V2 remains SHA-256
  `abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`;
- topology V3 remains SHA-256
  `b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`;
- topology V4 remains SHA-256
  `8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`;
- historical fixture replay plan V5 and source binding V6 remain historical
  identities and are not relabeled as topology V5; and
- semantic namespace V4 and pure composition V1 remain unchanged.

The additive topology V5 is
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`, canonical
SHA-256
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`.
The topology-V5 actual-package Release canary passed with byte-identical
probe/verifier package-description output: 36,047 bytes, SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
It remains secure-capture evidence only. The topology-V4 package capture remains
historical evidence and is not reused as topology-V5 package evidence.

Run this canary in an exclusive repository-observation window. One validation
attempt overlapped independent source-tree audits and failed closed with
`source_event_before_post_reap`; after those traversals stopped, the unchanged
tree passed. The failed attempt remains evidence that concurrent vnode activity
is contamination, not a result to retry away.

The two new frozen mechanics contracts are:

- capture inventory V1:
  `prime_stage_b_single_held_root_four_source_capture_inventory_v1`, canonical
  SHA-256
  `ae3477c44af1f36a111a6312a88a6b86995ddad231c9225a069173860ed29878`;
  and
- crosswalk authority V1:
  `prime_stage_b_independent_source_derived_prompt_target_crosswalk_authority_v1`,
  canonical SHA-256
  `b4a994635c2d7fafe8f9d47587122beee149533013b69592242bcba33b60ea67`.

## Package boundary

```text
PrimeNativeNeuralGateReplayCaptureInventory
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplaySourceBinding

PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedFixtureAuthority
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateReplayCaptureInventory
      - PrimeNativeNeuralGateReplayComposition
      - PrimeNativeNeuralGateReplaySourceComposition
      - PrimeNativeNeuralGateReplayTransport
```

The capture target remains trap-free. It has no corpus, corrected-fixture,
evaluation/regrade, prompt-solver, MLX, process, worker, or receipt dependency.
The crosswalk target is deliberately trap-bearing and downstream. Neither the
capture target, pure replay composition, source binding, nor source composition
depends on it. This one-way reachability prevents target authority from entering
the corrected raw closure.

## Exact held-root capture

The admitted source set is exactly 41 immutable files in one dedicated,
owner-private root:

- seven prompt artifacts: manifest, global stream, and five chunks;
- seven outer-evaluation artifacts;
- seven raw-execution artifacts for one admitted replicate seed; and
- twenty lossless-logit artifacts for the same seed: dictionary, manifest, and
  eighteen chunks.

Capture is fail-closed:

1. bind all four sources only to discover and canonicalize the exact paths,
   hashes, sizes, root identity, and seed;
2. reject duplicates, omissions, substitutions, or any path outside the frozen
   41-file set;
3. use `PrimeTrustedArtifactInventoryCapture` to capture the complete
   descriptor-rooted node closure, including required directories and exact
   immutable-file policy;
4. discard the discovery values and rebind prompt, outer, raw, and logit sources
   through the same admitted `PrimeArtifactRoot`;
5. require the rebound bytes to match the captured inventory; and
6. recapture the retained inventory and require exact equality before issuing a
   non-`Codable` capability.

Extra files, unsupported nodes, symbolic links, writable files, hard links,
root substitution, seed substitution, inventory drift, and final recapture
drift reject the capture. A decoded inventory value cannot reconstruct the live
capability or promote authority.

## Source-derived keyed crosswalk

The corrected-fixture authority derives all 18,432 selected rows in frozen
UTF-8 row-ID order. For each row it emits sealed, non-`Codable` material that
binds:

- the exact canonical prompt and prompt tokens under `PRIMECPI2`;
- source row and evaluation row identities;
- the exact canonical expected-completion bytes; and
- completion tokens plus one terminal EOS under `PRIMECFT1`.

The crosswalk authority does not zip source-row order to prompt-record order.
It reconstructs the captured canonical prompt schedule, finds each scheduled
prompt by its unique typed `PRIMECPI2` binding, uses the schedule-derived
`PRIMECOR1` execution-index/correlation identity to find the outer row, and
requires exact expected-completion bytes. The existing composition join
separately binds prompt, outer, raw, and lossless-logit material and recomputes
the corrected raw trace. Retained inventory is revalidated around the
association/join.

Target swaps, terminal-byte omission, duplicate prompt bindings, duplicate or
missing execution indexes, correlation substitution, prompt/token drift,
wrong EOS shape, positional joining, and digest-domain substitution fail
closed.

## Observed verification

The focused held-root/crosswalk integration passed over the complete 18,432-row
fixture with an exact 41-file root closure in **300.125 seconds**. It exercised:

- successful held-root capture, final unchanged recapture, source composition,
  and source-derived prompt/target association;
- exact row cardinality and the full keyed replay join;
- rejection after an unexpected root file was added;
- rejection of a same-length target swap; and
- rejection after terminal expected-completion material was omitted.

The complete Debug package validation then passed **469 XCTest cases** with
**4 intentional environment/opt-in skips** in **1,021.469 seconds**, followed
by **12 Swift Testing cases** in **2 suites** with zero failures. The
topology-V5 Release provenance check and actual-package canary are separate
Release gates; both passed against the identities recorded above.

This is repository mechanics evidence. It is not an observed worker delivery,
model execution, evaluation verdict, scientific result, or product result.

## Exact authority ceiling

Successful capture establishes only:

- exact whole-root 41-file node closure;
- one held-root four-source capture epoch; and
- durable origin for the captured prompt, outer-evaluation, one-seed
  raw-execution, and one-seed lossless-logit bytes.

Successful crosswalk binding additionally establishes only:

- exact source-capability join;
- corrected fixture identity;
- the independent source-derived 18,432-row
  `PRIMECPI2` -> `PRIMECOR1` -> `PRIMECFT1` keyed prompt/target association;
- exact outer expected-completion binding; and
- the capture's bounded durable origin for those captured bytes.

The following remain false:

- prompt-content target independence;
- process or schedule delivery observed;
- model execution;
- evaluation, verdict, or publication authority;
- mechanics `PASS`;
- terminal receipt;
- scientific authority; and
- product authority.

Globally, topology status remains `planned_not_materialized`,
`executionImplemented == false`, and `sourceBindingV7Issued == false`. The
historical runtime, workers, probe, verifier, mutation producer, and mutation
detector remain `planned_not_materialized`. Mutation producer/detector
assignment remains deferred and their implementation must be disjoint.

## Historical V6 continuation and current V7 status

The V5 prerequisite originally recorded below was satisfied additively by
topology V6; V5 remains unchanged history. V6 freezes the exact ten-role
process roster, branch-scoped process/evaluation ownership, verifier-only
receipt-last ownership, strict byte-bounded slot decoding, and construct-only
target-free candidate types. Its supervisor-only retained-capture wrapper is a
real capability-bound projection and ownership adapter, but no schedule has
crossed a process boundary.

Topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`
(canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`),
satisfies the declaration-and-decoder prerequisite that followed V6. It adds
exact-count bounded `PRIMEIRM1` stream admission and typed common/branch,
twenty-path artifact, and four-part Release worker-source declarations. Real
common/branch scalar references are supervisor-derived and non-authorizing;
realized worker-source and role-artifact content references remain absent, no
worker is materialized, and
source/execution-binding V7 remains separately unissued. The exact current
implementation prerequisite is:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

That slice must freeze the deferred semantic record schemas before Prime
assigns separate source-bound mutation producer and detector targets. Aggregate
candidates remain non-`Decodable`; exact-count bounded stream admission is now
implemented. Worker
materialization, Stage-B execution, verdict publication, and receipt issuance
remain later work. See
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`
for the exact V6 identities and focused evidence, and
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`
for the V7 boundary.

## Additive V8 continuation

The V7 prerequisite above is now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
It leaves the held-root/crosswalk authority and V7's exact twenty-path
declaration unchanged while freezing the deferred semantic schemas and adding
four internal targets: the narrow label-free, presence-only surface contract;
the semantic catalog/identity contract; the corrected producer; and the
independent detector. The corrected mutation catalog/control contract is
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract is
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on the surface contracts and transitively only
on surface plus replay mechanics. It cannot reach catalog/identity,
expected-leg mapping, replay-artifact contracts, or producer.
The only public detector entry requires an exact 15-case batch. Every full
bound baseline/restored context must be identical in bytes and binding across
the batch; mutated surfaces must be pairwise distinct. Wrong counts, duplicate
cases, per-case reference-hash or seed drift, and cap drift other than exact 63
against baseline 64 are rejected, and permutation invariance is verified.
`Label-free` excludes explicit mutation IDs/labels, arbitrary prediction
strings, and per-case caller-controlled context.
Actual Release source references, workers, processes, delivery, durable
semantic evidence, verdicts, and receipts remain absent and non-authorizing;
source/execution-binding V7 remains unissued. Historical package capture
continued with V6 at
40,100 bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`,
under source identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
That was the V8 prevalidation state. Completed final V8 validation is recorded
canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

No held-root or crosswalk count can establish a verdict. `countDerivedLabel`
is scoped `provisional_count_only_non_authorizing`; ten bare true leg states
remain `ABSTAIN`. `GROUNDED` requires verified/durably published per-leg
evidence, statistics recomputation, stable-greedy and behavioral fixed-prompt
predicates, model capability including exact abstention decisions, the
mutation sweep, source-bound leg evidence, distinct implementation families,
and four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` entry keeps its API
but always emits `ABSTAIN` with the provisional scope and cannot emit generic
`GROUNDED`. Historical `GROUNDED` further requires all five aggregate
references to be verified/durably published plus observed model execution.
These are absent in V8, and all authority booleans remain false.

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it without changing held-root or crosswalk
authority. Topology V10 then materializes only the isolated historical source
closure, without changing that authority ceiling. Its next prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
Topology V11 now source-binds the fixture and adds only an unavailable
executable target; held-root/crosswalk authority remains unchanged. The V11
next prerequisite was
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
V12 resolved only that design/source-contract boundary. Topology V13
materialized the exact source-only exporter. V14 now source- and compile-binds
one private cross-file worker/exporter call edge. That edge remains unreachable
from the exact V11 `main`, which exits `78`; held-root/crosswalk authority
remains unchanged. The current prerequisite is recorded in [Prime Native Neural Gate
Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).

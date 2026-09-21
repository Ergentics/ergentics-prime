# Ergentics Provenance Privacy Architecture

Document ID: `ergentics.provenance.privacy-architecture`

Status: **NORMATIVE WORKING ARCHITECTURE**

Scope: product-local Hypervisor roadmap H1–H8 and later agent/function work.

This document defines prospective design constraints. It does not change runtime
behavior, product resources, entitlements, the privacy manifest, execution
authority, any completed H-stage result, or Prime Gate E. It is not bundled in
the application and is not an Xcode target member.

The evidence predecessor for this working policy is the consumed Build 9 H3
result:

- receipt commit: `9199377b645a27cbedbc312016728e9d5c33ce21`
- receipt tree: `dbd8f973a7ebe1f473722914f8d3718257509a7a`
- receipt blob: `21dc12f43b374612134bc475418e15c948424ea8`
- receipt SHA-256: `5df90f2a933c70e715273b9d17700ef6cd059a926f6e807f3ddb1ef6cfad02a0`
- product H3: `FAIL_CONSUMED_PRODUCT_H3_NATIVE_NONPASS`
- ABI-v5 ordered SCTLR observation: `PASS_ABI5_ORDERED_SCTLR_TRACE`
- Gate E: `ABSTAIN`; authority vector: `00000000`; H4: `NOT_ENTERED`

The observability PASS does not promote the product result. This architecture
does not retrofit privacy guarantees onto H1–H3 or turn their evidence into a
candidate-selection result.

## 1. Decision

Privacy fits throughout H work. It should not be deferred to the end, because
H4 introduces durable receipts and therefore fixes disclosure, diagnostic, and
retention surfaces that later stages would otherwise inherit.

The adoption order is:

1. adopt this document as a repository-only policy;
2. make H4 the first executable privacy-envelope and disclosure-evidence slice;
3. extend cumulative disclosure and linkability controls in H5;
4. verify archive, entitlement, and internal-versus-release projection in H6;
5. enforce pre-entry and per-destination output gates during H7 execution; and
6. close retained lineage, expiration, revocation, and admission rules in H8.

No live action, journal migration, schema migration, or H-stage transition is
authorized by this decision.

## 2. Claim discipline

Every privacy statement must carry one of these states:

| State | Meaning |
| --- | --- |
| `OBSERVED` | Exact retained evidence records the bounded fact. |
| `VERIFIED` | A named predicate over exact evidence passed in a frozen scope. |
| `NORMATIVE` | Required design behavior; implementation is not implied. |
| `STAGED` | Assigned to a future H slice and not yet implemented. |
| `RESEARCH` | A useful target without a presently justified product claim. |
| `UNKNOWN` | Evidence is missing, ambiguous, or outside the measured scope. |

Prose, UI labels, hashes, signatures, Merkle roots, SQLite rows, graph nodes,
and a producer's own PASS cannot promote `NORMATIVE`, `STAGED`, `RESEARCH`, or
`UNKNOWN` to `VERIFIED`.

Unless explicitly tagged otherwise, prescriptive text in this working
architecture is `NORMATIVE` and not yet implemented or verified. Observational
claims appear only where tagged or bound to the evidence predecessor. The
H1–H8 matrix and source-control appendix identify `STAGED` and `RESEARCH` work.

## 3. Current bounded baseline

At this predecessor, the repository records these bounded observations and
declarations. A manifest declaration is not proof of all runtime behavior.

- `[OBSERVED]` `Entitlements.plist` and the Build 9 readiness record contain
  App Sandbox, user-selected read-only files, and Hypervisor entitlements;
- `[OBSERVED]` those effective-entitlement records contain no network-client or
  network-server key;
- `[OBSERVED]` declaration: `PrivacyInfo.xcprivacy` declares no tracking and no
  collected-data types;
- `[OBSERVED]` declaration: that manifest declares file timestamp and system
  boot-time reasons for local file handling and in-app timing;
- `[OBSERVED]` the H3 receipt records no journal Create/Open and no durable
  product evidence publication;
- `[OBSERVED]` the signed development archive exposed the H3 native diagnostic
  through its Accessibility tree; and
- `[OBSERVED]` the one Build 9 H3 action ended with Gate E `ABSTAIN`, authority
  vector `00000000`, product durable `false`, and H4 not entered.

These are not claims of non-observability, non-interference, secure erasure,
constant-time behavior, host confidentiality, or App Store distribution
privacy. Revalidate the manifest and effective entitlements for every archive.

## 4. Terms and actors

- **Execution** `E`: one bounded function, agent, guest, or verifier epoch.
- **Purpose** `P`: trusted, policy-issued reason for a bounded operation.
- **Capability** `C`: authority whose authenticity and claims are verified
  relative to a named issuer, verifier, policy, and threat model, binding a
  subject, object or field, operation, purpose, epoch, recipient, and limits.
- **Privacy envelope** `Envelope(E)`: the maximum declared observation,
  derivation, retention, recipient, and externality surface for `E`.
- **Projection** `Π`: a pre-execution transformation that produces the fields
  and records authorized for `P`.
- **Disclosure**: making information observable to a destination, including a
  UI, agent, file, diagnostic, database, model context, or external party.
- **Lineage**: the transitive dependency graph from protected inputs to derived
  values and outputs.
- **Declassification**: a separately authorized protection downgrade; ordinary
  transformation is not declassification.
- **Presentation**: a claim-labelled rendering of admitted or observed state.
  Presentation cannot upgrade the source claim and is not an authority source.

Actors include the user, trusted purpose/policy issuer, capability verifier,
projector, Swift application model, SwiftUI presentation, native C boundary,
Hypervisor guest, journal, independent reconstruction verifier, and any
external relying party.

## 5. Threat model and trust boundary

Assume multiple agents, curious or adversarial agents, confused deputies,
collusion, bugs, stale or malformed capabilities, over-broad retrieval,
metadata and existence leakage, diagnostic capture, linkability, derived-data
leakage, rollback, persistence beyond purpose, timing or resource channels,
and GUI or Accessibility clients attempting unauthorized actuation.

Logical privacy roles include the frozen purpose/policy issuer, capability
verifier, projector, lineage and declassification gate, destination gate,
journal encoder, and independent reconstruction verifier. This is not an
exhaustive trusted computing base. Every executable slice must enumerate its
transitive app/native/runtime, serialization, filesystem/SQLite, compiler and
signing, capability-authenticity/key-custody, crypto/codec, SQLite VFS,
key-store, hardware, OS/kernel/process/VM, and external-verifier dependencies,
then name the evidence and residuals for each relied-upon component. Unknown
transitive dependencies remain `UNKNOWN`; they are not silently outside the
trusted computing base.

Current Hypervisor guest memory is controlled by the host. It is not a
confidential VM, independent host attestation, or protection from a compromised
macOS host. Same-user tampering, whole-journal rollback, recipient forgetting,
backup deletion, allocator copies, and physical media erasure remain outside
current proof unless a later slice supplies exact evidence.

## 6. Core predicates

`[NORMATIVE]` The equations below define conformance predicates for future
executable slices. Implementation state: `STAGED` for H4/H7. They are not
claims about the ambient macOS process namespace or current H3 runtime.
`MinimumInformationRequired(P)` is a research
optimization target until a domain-specific sufficiency proof exists; it must
not be asserted as verified merely because an allowlist is small.

Let `C` be an operation/disclosure capability, `C_d` a declassification
capability (or `⊥` when no downgrade is proposed), `E` an execution, `P` a
purpose, `op` an operation, `e` an epoch, `d` a destination, `t` the evaluation
time, `r` a retention rule, `l_from` and `l_to` protection labels, and `w` a
declassification witness:

```text
CapabilityValid(C, t) =
    SchemaKnown(C)
  ∧ AuthenticityValidForNamedMechanism(C)
  ∧ IntegrityValid(C)
  ∧ TrustedIssuerAndPolicyDigest(C)
  ∧ RevocationStateAllows(C, t)
  ∧ ReplayOrOneUseStateAllows(C)
```

`AuthenticityValidForNamedMechanism` distinguishes a process-local handle from
a serialized or signed token and records the issuer/verifier/key-custody threat
model. No production privacy capability mechanism is currently implemented;
this predicate is `STAGED`.

```text
Admit(C, E, P, op, e, d, t) =
    TrustedPurpose(P)
  ∧ CapabilityValid(C, t)
  ∧ ExactSubject(C, E)
  ∧ ExactPurpose(C, P)
  ∧ ExactOperation(C, op)
  ∧ ExactEpoch(C, e)
  ∧ ExactRecipient(C, d)
  ∧ NotExpired(C, t)
```

Unknown, missing, malformed, stale, blank, or conflicting operands reject.

```text
Namespace(E, P, op, e, t) = {
  h | ∃ C:
      Admit(C, E, P, op, e, ExecutionDomain(E), t)
    ∧ Authorizes(C, h)
}
```

A conforming execution interface exposes no global root, implicit enumeration,
ambient search, or implicit persistence outside this namespace. Enumeration
requires its own enumerable-scope capability; possession of one object handle
does not grant its parent or peers.

```text
Input(E) = Π[policy(P), fields, records, metadata](AuthorizedSource)
ActualFields(E) ⊆ AllowedFields(E)
RetrievalCorpus(E) = AuthorizedCorpus(E)
```

Retrieval occurs after corpus authorization, never over a global corpus with a
post-search filter.

`ObservedInformation(E)` is the set of information classes/fields admitted to
the execution domain in the measured epoch. `AuthorizedObservation(E)` is the
observation projection of `Envelope(E)`. `RetainedInformation(E)` is the set
written to declared persistence destinations. `AuthorizedPersistence(P)` and
`AuthorizedDisclosure(P,d)` are the corresponding policy-approved information
sets for purpose and destination.

```text
ObservedInformation(E) ⊆ AuthorizedObservation(E)
RetainedInformation(E) ⊆ AuthorizedPersistence(P)
DisclosedInformation(E,d) ⊆ AuthorizedDisclosure(P,d)
```

The stronger target is:

```text
minimize Observation + Retention + Linkability + Inference + Disclosure
subject to AuthorizedUtility
```

Let protection labels form a declared lattice `(L, ⪯, ∨, ⊥)`, with `⊥` as the
empty join. The exact privileged downgrade predicate is:

```text
VerifiedDeclassification(
  C_d, E, P, e, y, d, l_from, l_to, t, w
) =
    CapabilityValid(C_d, t)
  ∧ TrustedDeclassificationPolicy(C_d, P)
  ∧ ExactSubject(C_d, E)
  ∧ ExactPurpose(C_d, P)
  ∧ ExactOperation(C_d, Declassify)
  ∧ ExactEpoch(C_d, e)
  ∧ ExactRecipient(C_d, d)
  ∧ NotExpired(C_d, t)
  ∧ CurrentProtection(y) = l_from
  ∧ AuthorizesDeclassification(C_d, y, l_from, l_to, d)
  ∧ LineageComplete(y)
  ∧ DeclassificationWitnessValid(
       w, C_d, E, P, e, y, d, l_from, l_to, t
    )
```

For a proposed release `(E,P,e,y,d,l_from,l_to,t)`, protection is monotone when
no `C_d,w` satisfy that exact predicate:

```text
¬∃ C_d,w: VerifiedDeclassification(
  C_d, E, P, e, y, d, l_from, l_to, t, w
)
⇒ Protection(y) ⪰ ⋁ { Protection(x) | x ∈ Ancestors(y) }
```

```text
Release(C, C_d, E, P, op, e, y, d, l_from, l_to, t, w) =
    CandidateWellFormed(y)
  ∧ LineageComplete(y)
  ∧ Admit(C, E, P, op, e, d, t)
  ∧ d ∈ AllowedRecipients(E)
  ∧ ExactPurposeForDestination(E, P, y, d)
  ∧ DisclosureScopeValid(C, y, d)
  ∧ (
       ProtectionPreserved(y, d)
       ∨ VerifiedDeclassification(
           C_d, E, P, e, y, d, l_from, l_to, t, w
         )
    )
```

Persistence is separate from observation:

```text
Persist(C, E, P, op, e, x, store, r, t) =
    Admit(C, E, P, op, e, store, t)
  ∧ PersistenceScopeValid(C, x, store, r)
  ∧ LineageComplete(x)
```

Expiration requires the trusted admission boundary to reject future
system-mediated access. It does not revoke copied/offline bearer data or claim
that a prior recipient has forgotten data already observed.

## 7. Normative invariants

| ID | Required invariant |
| --- | --- |
| `PRIV-001` | Purpose originates from trusted user/application policy; an agent may only propose purpose. |
| `PRIV-002` | Every admitted observation uses a capability-closed execution interface; that interface exposes no ambient enumeration. |
| `PRIV-003` | Field, record, and metadata projection occurs before entry into the execution domain. |
| `PRIV-004` | Each execution has a bounded privacy envelope joined to subject, purpose, operation, epoch, and recipients. |
| `PRIV-005` | Each destination applies an independent release predicate; no-network is not equivalent to no-disclosure. |
| `PRIV-006` | Retention requires a separate persistence capability and declared lifetime. |
| `PRIV-007` | Derived data inherits transitive protection and lineage unless a privileged declassification passes. |
| `PRIV-008` | Agent/function context is private by default; shared context is explicit and field-scoped. |
| `PRIV-009` | Retrieval searches only an already authorized corpus. |
| `PRIV-010` | Diagnostics are structural and payload-free by default. Payload capture requires a separate capability and domain. |
| `PRIV-011` | The GUI presents claim-labelled admitted projections; it cannot upgrade their source claim, mint capability, declassify, or elevate authority. |
| `PRIV-012` | Presentation receives no authority-bearing store handle. View actions are proposals; changes cross an independently enforced commit gate, unauthorized store changes are detected/rejected, and debugger-attached intervals are ineligible at that gate. |
| `PRIV-013` | JSON and CBOR are separate canonical streams, independently decoded and joined; neither is silently synthesized from the other. |
| `PRIV-014` | Merkle commitments bind exact bytes and ancestry only; they do not prove truth, privacy, secrecy, minimization, deletion, or authority. |
| `PRIV-015` | SQLite is a durable container and checked index/projection, not source semantic authority. |
| `PRIV-016` | State/witness nodes and transition nodes remain distinct; transition predicates are explicit and forward/reverse reconstruction of retained semantic relations must agree. No hash or lossy projection inversion is claimed. |
| `PRIV-017` | Unknown lineage, purpose, recipient, capability, protection, or declassification rejects disclosure. |
| `PRIV-018` | Disclosure and retention are explicit state transitions with structural evidence and no payload duplication where commitments suffice. |
| `PRIV-019` | Stable IDs, hashes, roots, sizes, timestamps, and energy/work measurements are metadata subject to projection and linkability review. |
| `PRIV-020` | No local evidence producer, representation, or presentation can self-promote Gate E or scientific authority. |

## 8. Capability and projection boundary

A capability must bind, at minimum:

- issuer and schema/policy digest;
- execution subject and epoch;
- purpose and operation;
- object classes and exact allowed fields;
- enumeration and retrieval scope;
- allowed derivations and declassification policy;
- each allowed recipient/destination;
- persistence destination and retention rule;
- expiration and replay/one-use state where applicable; and
- evidence commitment needed to reconstruct the decision.

The user interface can submit an authenticated action proposal. The trusted
policy boundary decides whether that proposal produces a capability. A button
press is not blanket consent for collection, network transfer, retention,
trusted ingress/egress, or Gate E promotion.

Projections must be typed, bounded, and fail closed. A projector cannot query a
larger namespace than its input capability permits. Field omission is the
default; a field is added only when a named predicate requires it. Projector
source access is itself an observation governed by its own envelope and
capability.

## 9. Execution, isolation, and lifetime

Every agent or function receives its own context, handles, scratch, caches,
queues, and epoch. The normative target is no intersection of protected
payload namespaces except explicitly shared fields; literal disjointness of
all runtime metadata is not claimed.

Ephemeral capability and plaintext lifetime should end with the execution
epoch unless separately retained. Implementations must inventory copies made
by serialization, queues, exceptions, model context construction, shared
memory, accelerators, and diagnostics.

Logical deletion, physical overwrite, cryptographic erasure, and managed-memory
zeroization are separate claims. Swift allocator behavior, SQLite WAL/backups,
VM pages, accelerator memory, and physical media prevent an absolute erasure
claim today. Later key-domain work must document the exact guarantee and its
residuals.

## 10. Lineage, cumulative disclosure, and declassification

Every protected derivative records transitive ancestor commitments and a
protection join. A transform cannot lower protection. Declassification requires
its own policy, purpose, destination, complete lineage, verifier, and witness.

H5 must conservatively accumulate the fields, classes, recipients, and
linkability made available across executions. This is exposure accounting, not
a claim to reconstruct an agent's beliefs.

```text
DisclosureSet(E, n+1) = Closure(
  DisclosureSet(E, n) ∪ NewlyDisclosedClasses(E, n+1)
)
```

`Closure` must be domain-specific. A generic inference-closure proof is a
research target, not a current invariant.

## 11. Destination boundaries

| Destination | Allowed source | Required gate | Default retained content |
| --- | --- | --- | --- |
| Guest/function/agent | Pre-authorized bounded projection | subject + purpose + operation + epoch + fields | none after epoch unless separately granted |
| GUI | Verified bounded presentation projection | presentation schema + source-root join | view state only; never authority |
| Accessibility | Minimal accessible presentation | destination policy plus the same proposal/commit boundary as GUI actuation | no raw native diagnostic in release destination |
| JSON receipt | Independent canonical JSON stream | schema + bounds + semantic reconstruction | structural evidence and exact required values |
| CBOR journal | Independent deterministic CBOR stream | canonical decoder + bounds + semantic reconstruction | structural events; protected payload exceptional |
| SQLite | Joined CBOR bytes and checked columns/indexes | one atomic transaction + reopen/reconstruct equality | canonical bytes plus minimal indexed fields |
| Graph | Verified state/witness/transition projections | bipartite kind rule + explicit predicates + hash ancestry | content-addressed structural nodes |
| Merkle root | Exact committed byte leaves | domain-separated frame + independent vectors | root and needed inclusion/ancestry evidence |
| Logs/errors | Structural diagnostic projection | error-class and payload-canary gate | counts, classes, scoped IDs; no consumer payload |
| File/export/network | Explicit destination capability | complete lineage + recipient + declassification/retention | deny by default |

Hashing a low-entropy name, path, identifier, or fact is not declassification.
Roots and stable identifiers can themselves create existence and linkability
signals and must be purpose-scoped.

## 12. Evidence plane: JSON, CBOR, SQLite, graph, and Merkle

JSON and CBOR are independent evidence streams for their declared byte and
semantic domains. Each must parse independently; each must reconstruct the
same declared semantics; their join must fail on missing, duplicate,
noncanonical, truncated, reordered, or conflicting fields. Agreement proves
encoding/semantic consistency, not the truth of the producer's claim.

The admitted JSON/CBOR streams are canonical evidence inputs. SQLite retains
admitted canonical stream bytes plus non-authoritative checked indexes and
projections; neither SQLite nor its projector becomes semantic, transition, or
execution authority. Query membership is usable only after rebinding to those
admitted bytes and independent reconstruction. Indexed columns and canonical
CBOR must commit atomically. Reopen must reproduce the same rows, graph, stream
commitments, and roots. WAL, disk-full, partial-write, concurrency, rollback,
and schema-version cases fail closed.

The graph is bipartite between state/witness content and transitions.
Transitions carry actual predicates and exact input/output roots. Every state
is content addressed and carries hash-chain ancestry. Forward reconstruction
maps admitted bytes to semantics, projections, and recomputed roots. Reverse
reconstruction starts from retained admitted stream/node bytes and indexes,
reconstructs semantic relations, then recomputes the same roots. It is not hash
inversion or recovery of information removed by a lossy projection. A root
alone is insufficient. Both directions must agree before conservation or
release.

A Merkle commitment is computed before a conservation claim and after all
required leaves are closed. Domain separation, leaf order, cardinality, and
unpaired-node behavior are schema fields. A root cannot authorize a run or
repair missing evidence.

These streams, decoders, database checks, graph reconstruction, and Merkle
vectors are independent representations or checks only in their named scope.
They are not automatically independent execution witnesses or truth witnesses.

## 13. Diagnostics, GUI, and debugger boundary

The diagnostic objective is high structural observability with low payload
observability. Default events contain scoped pseudonyms, type/size classes,
field masks, purpose/capability IDs, transition IDs, recipient class, retention
rule, lineage commitments, counters, and roots—not plaintext payload.

An **internal diagnostic destination** is a separately gated privacy-policy
destination or capability domain excluded from the release/external
destination. It is not Swift `internal` access, Debug/Release optimization,
archive type, or signing identity. A **release destination** is the exact
allowlisted product/Accessibility/export projection intended for distribution.
Internal rich diagnostics require their separate capability and privacy
domain. External errors should not reveal protected existence where the policy
calls for existence privacy. Internal diagnostics may retain a richer error
class only when separately authorized.

The GUI may format, summarize, graph, color, animate, organize, and filter a
claim-labelled admitted projection. It may not upgrade the source claim,
declassify, or elevate the underlying state. Every rendered fact must be
derivable from an admitted projection. GUI and Accessibility gestures are
untrusted action proposals. A non-GUI/non-AX policy verifier and commit owner
must revalidate subject, purpose, capability, namespace, and destination at an
independently enforced commit boundary before an authorized state change.
Presentation receives no authority-bearing store handle.

A debugger may inspect, mutate, or control development execution. An
independently enforced product commit path must reject a debugger-attached
interval as ineligible to publish authoritative state. Debug-derived
observations remain diagnostic evidence only; no inability to mutate bytes is
claimed.

The current H3 archive exposed `h3-native-diagnostic` through Accessibility.
That is an observed privacy gap, not an accepted release policy. H4 must implement
the bounded internal/release projection split. The raw diagnostic must be
absent and unreachable in the signed release destination, and H6 dynamically
audits the archived Accessibility surface before a release privacy claim can
pass.

## 14. Retention, expiration, revocation, and deletion

Every persistent class declares purpose, retention lifetime, deletion
authority, lineage consequences, and cryptographic domain. Default retention
is none.

Expiration and revocation require system-controlled enforcement points to
reject future authorization and identify affected active capabilities,
derivatives, caches, indexes, embeddings, memories, and outputs only within the
declared lineage/holder inventory. Already observed copies, active external
recipients, untracked caches, backups, offline bearer data, and compromised
components remain unaffected or `UNKNOWN`; no forgetting claim is made.

Deletion propagation is a policy decision over `Descendants(X)`. Audit or
legal retention conflicts produce an explicit tombstone/retention state; they
must not be hidden as successful deletion. Physical overwrite, backup deletion,
WAL erasure, and key erasure require separate evidence.

## 15. Privacy luminosity and work accounting

Privacy luminosity directs verification effort; it is not a violation verdict:

```text
L_privacy = vector(
  disclosure,
  inference,
  linkability,
  retention,
  cross_agent,
  metadata,
  externality
)
```

A transition with a positive privacy delta receives increased review. CPU time,
energy estimates, ergs, timing, and resource occupancy are work/accounting
observations. They may be sensitive metadata and side channels. They do not
serve as a generic privacy budget or authority bit.

For every implementation change, retain a structured delta:

```text
ΔPrivacy = (
  ΔDataVisible,
  ΔFieldsVisible,
  ΔRetention,
  ΔRecipients,
  ΔLinkability,
  ΔPersistence,
  ΔInferenceSurface,
  ΔLeakage
)
```

An identical functional output with a larger input or observation surface is a
privacy regression.

## 16. H1–H8 adoption matrix

| Stage | Existing stage | Privacy work and evidence |
| --- | --- | --- |
| H1 | `hypervisor_product_schema_and_pure_contract_v1` | Historical pure contract remains unchanged. Adopt vocabulary, claim states, fail-closed predicates, GUI non-authority, and privacy-delta review prospectively. No retrofit. |
| H2 | `hypervisor_tiny_fixed_guest_mechanics_v1` | Preserve fixed image, no loader/network, bounded mechanics, explicit Run, and read-only reconstruction. Do not relabel incomplete formal H2 evidence. |
| H3 | `hypervisor_explicit_state_cursor_resume_v1` | Build 9 is a consumed product non-PASS with observability PASS. Product cursor evidence bytes are zero, no product journal was opened, and no durable product evidence was published. The separate outer Git receipt durably retains structural native checkpoint/GPR/system/timing and AX observations and is explicitly not product-journal evidence. Record the Accessibility exposure as a gap; do not rerun or promote H3. |
| H4 | `hypervisor_durable_receipt_fault_injection_v1` | First executable privacy slice: bounded `PrivacyEnvelope`, capability-checked source-field projection before diagnostic/receipt persistence, `DisclosureEvent`, per-destination gates, independent JSON/CBOR streams, atomic non-authoritative SQLite projection, bipartite graph, pre-conservation Merkle commitment, payload-canary scans, and crash/WAL/partial-write/replay tests. |
| H5 | `hypervisor_repeated_same_host_resume_determinism_v1` | Add cumulative disclosure, cross-run linkability, scoped IDs, repetition bounds, stale/replay rejection, privacy delta, and post-execution exposure accounting. |
| H6 | `hypervisor_signed_product_resource_probe_v1` | Freeze probe/field allowlists and purposes; verify manifest and effective entitlements; split internal diagnostic from release projection; audit archive and Accessibility surface; no telemetry or implicit externality. |
| H7 | `hypervisor_bounded_product_checkpoint_execution_v1` | Generalize capability-closed namespace and pre-entry projection to agent/function/retrieval inputs; enforce bounded context, per-destination output gate, cross-agent/confused-deputy negatives, teardown, and timing/resource channel tests. |
| H8 | `hypervisor_retained_product_provenance_and_admission_v1` | Require explicit retention/read grants, transitive lineage, expiration/revocation/deletion conflict states, replay-safe admission, retained disclosure receipts, and independent relying-party authority for trusted egress. |

No H-stage process described here may change Gate E or the authority vector.
Only a separate, independently authorized Gate-E authority process may do so.

## 17. H4 executable minimum

H4 must not attempt all privacy research. Its bounded minimum is:

1. a closed `PrivacyEnvelope` value with subject, purpose, operation, epoch,
   allowed fields/classes, recipients, persistence, and expiration;
2. a typed, capability-checked source-field projection applied before any H4
   diagnostic, receipt, CBOR, SQLite, graph, or Merkle persistence;
3. a closed `DisclosureEvent` with no payload by default;
4. one decision function returning structured allow/reject predicates;
5. independent JSON and deterministic CBOR encoders/decoders joined by exact
   reconstructed semantics;
6. one atomic SQLite append of canonical CBOR plus minimal indexed fields;
7. a content-addressed state/witness/transition graph with actual predicates;
8. a domain-separated Merkle root committed before conservation;
9. reopen and bidirectional reconstruction receipts;
10. internal and release presentation projections, with raw diagnostic absent
   from the release projection; and
11. fault-injection evidence for no partial authority, no payload spill, and no
    silent rebaseline.

H4 is scoped to close the pre-persistence diagnostic/receipt projection only
after its named executable predicates pass. General agent and retrieval
namespace closure remains H7 work.

This minimum changes no external collection policy and adds no network or file
write entitlement. Any such change requires a separate privacy delta and Apple
manifest/entitlement review.

## 18. Verification matrix

Every test result is bounded to its named revision/build, environment, fixture
namespace, enumerated destinations, instrumentation, attempt count, fault
schedule, and observation window. A negative, canary, or one-bit PASS is
evidence for that scope; it is not proof that no undiscovered path or channel
exists.

| Test ID | Predicate |
| --- | --- |
| `PRIV-T001` | Wrong subject, purpose, operation, epoch, recipient, expiry, replay state, or malformed capability rejects. |
| `PRIV-T002` | On the frozen public API surface, no root/list/search API or ambient enumeration is reachable outside the fixture capability namespace. |
| `PRIV-T003` | Secret sentinel fields, paths, URLs, environment values, credentials, certificate data, and error text are absent from every enumerated unauthorized projection. |
| `PRIV-T004` | Removing each supplied field independently either preserves required behavior or produces a named necessity witness. |
| `PRIV-T005` | Retrieval over the authorized fixture corpus does not reveal the planted existence, count, or ranking facts from the disjoint fixture corpus through enumerated outputs. |
| `PRIV-T006` | Enumerated cross-agent handles, caches, queues, and confused-deputy fixtures do not transfer planted protected fields through named destinations. |
| `PRIV-T007` | Transform preserves transitive protection; incomplete lineage and unauthorized downgrade reject. |
| `PRIV-T008` | Every destination independently allows or denies the same candidate from its own policy. |
| `PRIV-T009` | External error classes do not distinguish unauthorized from nonexistent where existence privacy is required. |
| `PRIV-T010` | JSON and CBOR decode independently, reconstruct equal semantics, and reject malformed, noncanonical, truncated, duplicate, or trailing data. |
| `PRIV-T011` | Merkle known-answer vectors, tamper cases, leaf ordering, cardinality, and ancestry round trip exactly. |
| `PRIV-T012` | Under the named transaction/WAL/disk-full/crash/concurrency/reopen fault schedule, no partial or mismatched SQLite projection becomes admitted. |
| `PRIV-T013` | Forward and reverse graph reconstruction reproduce exact node kinds, predicate identifiers, roots, and ancestry. |
| `PRIV-T014` | Within the frozen GUI/store boundary, presentation corruption, deletion, filtering, or reordering cannot cross the independent commit gate; unauthorized store deltas are detected and rejected. |
| `PRIV-T015` | The named product commit path rejects a debugger-attached interval; no general inability to mutate memory is claimed. |
| `PRIV-T016` | Planted diagnostic payload canaries are absent from all enumerated logs, errors, AX records, SQLite indexes, graphs, exports, and agent outputs in the observation window. |
| `PRIV-T017` | Internal and release destinations are distinct; static and dynamic archive/AX audits find no raw native diagnostic or internal identifier in the signed release destination. |
| `PRIV-T018` | PrivacyInfo, effective entitlements, linked frameworks, resources, AX surface, and exported files match an allowlisted archive manifest. |
| `PRIV-T019` | Timing and resource one-bit probes are reported without claiming constant-time or non-interference. |
| `PRIV-T020` | Repetition produces a cumulative disclosure/linkability delta and rejects stale or replayed retention/admission state. |
| `PRIV-T021` | AXPress and AX set-value fixtures cannot bypass disabled controls, subject/purpose/namespace gates, the independent commit boundary, or reach the internal-only destination. |

Claim promotion requires exact source revision, environment, schema, bounded
scope, retained raw evidence, independent reconstruction, and a receipt that
names residuals. Test count or prose alone is insufficient.

## 19. Change-control triggers

A privacy review and structured delta are mandatory before adding or changing:

- a data class or field;
- agent/function context or retrieval corpus;
- a recipient or destination;
- journal, SQLite, graph, cache, embedding, or model memory retention;
- a stable identifier, root, timestamp, energy/work measure, or linkable key;
- Accessibility, logs, errors, export, file writes, or network behavior;
- entitlements, privacy manifest declarations, required-reason APIs, linked
  frameworks, or bundled resources;
- declassification, deletion, key management, or external relying-party rules;
  or
- a claim state from `NORMATIVE`, `STAGED`, `RESEARCH`, or `UNKNOWN` to
  `VERIFIED`.

## 20. Explicit nonclaims and research queue

This architecture does not presently claim:

- proof of minimum sufficient information;
- formal non-interference or complete inference closure;
- constant-time or resource-channel elimination;
- differential privacy without a domain-specific mechanism and epsilon/delta;
- secure zeroization of Swift, allocator, VM, DMA, or accelerator memory;
- physical overwrite or deletion from WAL, backups, snapshots, or recipients;
- absolute cryptographic erasure;
- private embeddings or model-memory deletion;
- confidentiality against a compromised host/kernel;
- independent host attestation or honest-computation proof;
- privacy merely because the network is absent; or
- truth, secrecy, authority, or deletion merely because a hash/Merkle root,
  signature, CBOR stream, SQLite row, or graph agrees.

Research can improve later claims, but it must not block honest staged product
work unless a promised product property depends on it.

## Appendix A: source-control disposition

The supplied sixty-point privacy draft is a requirements source. The table
below prevents its strongest aspirations from being mistaken for current
implementation facts.

| # | Topic | Disposition | First H adoption |
| ---: | --- | --- | --- |
| 1 | Non-observability | `RESEARCH` target; capability closure is `NORMATIVE` | H7–H8 |
| 2 | Pre-execution minimization | `NORMATIVE` | H4 |
| 3 | Purpose limitation | `NORMATIVE` | H4 |
| 4 | Trusted purpose origin | `NORMATIVE` | H4 |
| 5 | Data views | `NORMATIVE` | H4 |
| 6 | Field capabilities | `NORMATIVE` | H4 |
| 7 | Privacy budget | `RESEARCH`; no generic scalar | domain-specific |
| 8 | Cumulative disclosure | `STAGED` | H5 |
| 9 | Knowledge state | `STAGED` conservative exposure classes | H5 |
| 10 | Derived protection | `NORMATIVE` | H5 |
| 11 | Transitive lineage | `STAGED` | H5/H8 |
| 12 | Privileged declassification | `NORMATIVE`, implementation `STAGED` | H5/H8 |
| 13 | Disclosure transition | `NORMATIVE` | H4 |
| 14 | Ephemeral disclosure | `NORMATIVE`, platform evidence `STAGED` | H4/H7 |
| 15 | Key erasure | `RESEARCH`/future mechanism | H8+ |
| 16 | Key compartmentalization | `STAGED` after key design | H8+ |
| 17 | Plaintext lifetime | `STAGED` measurement | H7 |
| 18 | Memory sanitization | `RESEARCH` with platform-specific evidence | H7+ |
| 19 | Private contexts | `NORMATIVE` for protected payload namespaces | H7 |
| 20 | Private retrieval | `NORMATIVE` | H7 |
| 21 | Private embeddings | `RESEARCH`; no current embedding runtime | future |
| 22 | Cross-agent privacy | `NORMATIVE` | H7 |
| 23 | Confused deputy | `NORMATIVE` and negative tests | H7 |
| 24 | Output gate | `NORMATIVE` | H4/H7 |
| 25 | Destination breadth | `NORMATIVE` | H4 |
| 26 | Diagnostic privacy | `NORMATIVE` | H4 |
| 27 | Structural telemetry | `NORMATIVE`; no off-device telemetry implied | H4 |
| 28 | Flight recorder privacy | `NORMATIVE` if recorder exists | H4+ |
| 29 | Privacy/observability balance | `NORMATIVE` | H4 |
| 30 | Metadata privacy | `NORMATIVE` | H4–H6 |
| 31 | Error privacy | `NORMATIVE` | H4/H7 |
| 32 | Timing privacy | `RESEARCH` plus bounded tests | H7 |
| 33 | Resource channels | `RESEARCH` plus one-bit tests | H7 |
| 34 | Existence privacy | `STAGED`; policy-dependent | H7 |
| 35 | Linkability | `NORMATIVE` delta | H5 |
| 36 | Purpose unlinkability | `STAGED`; policy-dependent IDs | H5 |
| 37 | Retention declaration | `NORMATIVE` | H4/H8 |
| 38 | Expiration | `STAGED` | H8 |
| 39 | Revocation | `STAGED`; no forgetting claim | H8 |
| 40 | Deletion propagation | `STAGED`; conflict states required | H8 |
| 41 | Privacy differential | `NORMATIVE` for each H change | H4 onward |
| 42 | Regression tests | `NORMATIVE` | H4 onward |
| 43 | Counterfactual minimization | `STAGED` experimental evidence | H4 onward |
| 44 | Inference testing | `RESEARCH`/red-team evidence | H8 |
| 45 | Collusion testing | `RESEARCH`/red-team evidence | H8 |
| 46 | Canary data | `STAGED` test-only | H4 |
| 47 | Fault injection | `NORMATIVE` for H4 | H4 |
| 48 | Invariant engine | `STAGED` executable predicates | H4 |
| 49 | Privacy luminosity | `NORMATIVE` attention vector, not verdict | H4 onward |
| 50 | Privacy envelope | `NORMATIVE` | H4 |
| 51 | Fail closed | `NORMATIVE` | all prospective H work |
| 52 | Disclosure receipt | `STAGED` structural evidence | H4/H8 |
| 53 | Private by construction | `NORMATIVE` design ergonomics | H4 onward |
| 54 | Function contract | `STAGED` | H4/H7 |
| 55 | Pre-execution analysis | `STAGED` | H4/H7 |
| 56 | Post-execution analysis | `STAGED` | H5 |
| 57 | Optimization loop | `RESEARCH`/iterative engineering | H5–H8 |
| 58 | Privacy/utility frontier | `RESEARCH` decision support | H5–H8 |
| 59 | Agent red team | `STAGED` before sensitive multi-agent use | H8 |
| 60 | Access→minimum→non-observability→non-interference | staged progression; final property `RESEARCH` | H4–future |

## Appendix B: concise audit questions

For every byte, field, object, derivative, identifier, capability, trace,
cache, output, and commitment, record:

1. why it exists;
2. why this execution can observe it;
3. which predicate requires it;
4. whether a smaller projection preserves required utility;
5. how long and where it remains observable;
6. which recipients or executions can correlate it;
7. what can be inferred alone and in composition;
8. which descendants it creates;
9. how those descendants are traced and protected; and
10. whether instrumentation duplicates payload unnecessarily.

Missing answers identify a missing privacy primitive. They do not authorize a
default.

`[NORMATIVE]` Design maxim; not a verified product claim.

**Private by default. Minimal by execution. Isolated by capability. Protected
through derivation. Ephemeral unless authorized. Auditable without payload
duplication.**

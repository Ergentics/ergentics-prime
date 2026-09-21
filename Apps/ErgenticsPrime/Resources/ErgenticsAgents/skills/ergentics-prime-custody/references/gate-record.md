# Gate decision record

Use in the existing task evidence record, not a new monitoring system. Omit
irrelevant fields with an explicit reason. Record unknowns without inventing
values. This is a readable contract, not an executable schema validator.

| Field | Evidence needed |
| --- | --- |
| Decision and authority | Exact requested operation, user scope, owner, destination |
| Source | Repository, base/head/tree and uncommitted selection if relevant |
| Family and phase | Named authority, version/hash, pre/post-outcome or provenance-only |
| Trigger | Event, branches, job conditions, observed run ID/URL; attempt if exposed |
| Admission | Caller identity, accepted events, ancestry, path-set and phase predicates |
| Outcome | Each executed, failed, skipped or unobserved check; log/source attribution |
| Transition | Retained predecessor/terminal contract, next mutation, resource restoration |
| Change | IMPLEMENTATION_FIX, INSTRUMENTATION_FIX, PROVENANCE_FIX or PROTOCOL_AMENDMENT; protected semantics and evidence |
| Qualification | Exact object/runtime/family covered; historical results kept separate |
| Durability | LOCAL_DURABLE, COMMITTED, PUSHED, REMOTE_SHA_VERIFIED; intended merge separately |
| Next action | One concrete authorized operation; holds scoped to affected operations |

A source excerpt supports static interpretation. A workflow outcome supports
only the steps that actually ran. A helper receipt supports its stated byte
checks, not independent authentication of the author's review or provider
retention. Preserve those distinctions when a later receipt supersedes a state.

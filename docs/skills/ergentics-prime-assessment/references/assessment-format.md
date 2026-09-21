# Assessment record v1

The JSON record is a durable index into the existing report and evidence. It is
not a second policy or authorization system. Preserve raw evidence separately;
include no credentials, protected payloads or whole execution histories.

Required top-level fields:

| Field | Contract |
| --- | --- |
| `schema_version` | Integer `1`; unsupported versions fail validation. |
| `assessment_id` | Nonempty stable identifier. |
| `scope` | `roots`: explicit absolute directories; `required_surfaces`: nonempty distinct IDs; `question`: actual review question; `exclusions`: list of objects with `pattern` and `reason`. |
| `inventory` | Nonempty list of unique `id`, `surface`, `kind`. Kinds: `source`, `image`, `record`, `logical`. File items have absolute `path` and lowercase SHA-256; logical items name an unavailable or non-file surface in `description`. |
| `reviews` | Exactly one row per inventory ID: `item_id`, `state`, `basis`, `evidence`. State: `pending`, `blocked`, `reviewed`, `fixed`, `retired`, `excluded`. Basis is a concrete explanation; evidence is a list of safe references. Completed/excluded rows need evidence. |
| `findings` | Unique `id`, `state` (`open`, `fixed`, `accepted_limit`), nonempty `item_ids`, `evidence`; a fixed finding also has `verification_ids`. Accepted limits explain their disposition in `reason`. |
| `verifications` | Unique `id`, `status` (`pass`, `fail`, `not_run`), `subjects` mapping inventory IDs to exact candidate SHA-256, and `evidence`. Optional `superseded_by` references a later record; old failures remain in the list. |
| `live_processes` | `state` (`unknown` or `observed`), `count` (null when unknown), `evidence`. An observed count also needs an ISO-8601 `observed_at` timestamp. Counts are time-bound observations, not ongoing monitoring. |
| `holds` | Objects with unique `id`, boolean `active`, and `reason`. The validator never clears a hold or grants commit authority. |
| `completion` | `state`: `in_progress`, `complete_with_limits`, or `complete`; `summary`: explanation of the actual outcome. |

Every required surface must appear in the inventory. File paths must be below a
declared root, and credential-like path components are excluded from file intake.
Inventory and review IDs must match exactly; a missing row cannot silently
disappear from the denominator. Add fields for project-specific evidence without
changing existing field meanings.

`complete` rejects pending/blocked items, open findings, unknown required live
coverage, and effective failed/unrun verification. `complete_with_limits` still
requires every item to have an explicit disposition: blocked items and open
findings remain visible, and the summary explains the limit. Neither state clears
the user's holds. `in_progress` is appropriate while source review or repairs
remain pending. A passed validator checks the consistency of these declarations,
not whether their evidence is authentic, sufficient or exhaustive.

A fixed finding must cite at least one passing verification whose subject hash
matches each affected current file. A reviewed/retired entrypoint claim should
also explain its actual static or runtime test basis; metadata validation alone
does not qualify native behavior. A supersession must terminate at a successful
record covering the same subject identities; a newer pass for different bytes
does not erase an old failure.

Every verification defaults to `current: true` and must bind current file hashes,
including checks not attached to a finding. Use `current: false` plus a concrete
`history_reason` to preserve results for earlier bytes. Logical surfaces have no
file hash; record their observation evidence in the review instead.

Run the validator without `--check-files` for structure-only validation. With
`--check-files`, it opens only named regular files beneath declared roots,
refuses symlink traversal, hashes at most 512 MiB per file, and checks that file
identity/size/time did not change during the read. It does not launch the
files, query processes, call the network, discover more files or mutate them.
The JSON input is itself bounded to 16 MiB and must be a regular, non-symlink
file. Extend caps deliberately for a demonstrated need; a skipped file is not
a successful identity check.

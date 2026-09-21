# Versioned JSON contracts

The executable validator is `scripts/profile_packet.rb` v0.1.0. Formats have explicit schema IDs, required fields and named extensions. This package does not claim an official JSON Schema validator run. Duplicate object keys, unknown fields at validated boundaries, unsupported schema IDs and malformed pins are rejected.

## Profile: ergentics.profile.v1

See the two concrete files under `profiles/`. Identity/version/purpose are stable; `agent` pins the dependency version and external manifest SHA. `method` names policy and applicable capabilities/skills; conditional skills are routing guidance, not proof of installation. `boundaries` preserves project precedence and grants no access. `continuity` binds the receiving task, originals and reviewed lesson workflow. `corpus` limits eligible content classes. No hosting model is hardcoded.

## Run request: ergentics.profile-request.v1

Required fields: `schema`, `run_id`, `profile_id`, `profile_version`, `assignment`, `authority`, `purpose`, `requested`, `processing`, `budget`, `selection`, `bindings`, `extensions`.

- `requested`: `adapter` (`codex_explicit` or `packet_only`), model label, reasoning effort, context (`mode`: fresh/existing; `inherited_context`: explicit description), and requested tool names.
- `processing`: mode (`hosted` or `local_preparation`), recipient, provider and actual retention-evidence description. The Codex adapter requires hosted mode. An unverified provider-control state must remain unverified.
- `budget`: positive integer maximum context bytes (at most 1 MiB), output bytes (at most 1 MiB), deadline seconds (at most 86400), selected entry count (at most 32). These conservative helper ceilings are implementation limits, not inherited research clocks or future workload limits; extend/version/test when actual tasks justify larger packets.
- `selection`: explicit `{id, version, sha256}` objects; no wildcard or directory scan. Empty selection is valid for a profile-only load.
- `bindings.profiles` and `bindings.agents`: absolute `root` plus expected manifest `sha256`; `bindings.policy`: absolute path, ID, version and expected SHA; `bindings.corpus`: absolute root plus expected `index_sha256` for `INDEX.json`.
- `extensions`: optional interpretation-free namespaced keys inside the required object; unsupported fields elsewhere are rejected.

Per-run source/data references may be selected as approved corpus task fixtures or carried in a namespaced extension, but must be explicitly verified by the assigned implementation before use. A reference in an extension is not automatically loaded, executed or qualified.

## Corpus index: ergentics.corpus-index.v1

Required fields: schema, ID/version, owner, entries, extensions. Each entry contains ID/version, relative payload path, byte count/hash, kind/material class, attribution/origin, review (status/reviewer/evidence), profile IDs, purposes, allowed recipient/processing pairs, extensions. See `corpus/INDEX.json` for concrete records.

A selected entry must be accepted, compatible with the profile, purpose and exact processing route, and match its caller-supplied pin. Held-out answers, unreviewed/withheld entries, raw histories, credential classes and environment dumps are ineligible for these profiles. Eligibility metadata is checked for ALL selected entries before any selected corpus payload is opened. An eligible payload whose bytes drifted must be read to detect that mismatch; its read is recorded and it is not included in a successful packet. Metadata labels are not a secret detector or authority signature.

## Load observation (separate output)

Record `schema: ergentics.profile-load-observation.v1`, run/profile identity, packet receipt path/hash, actual context/task name, requested model/effort, visible model information and unknown serving build, actual file/entry reads with hashes, blockers, result path/hash and limitations. Report a successful instruction load only after the actual required reads. Do not relabel the packet's preparation as an observed load or execution. The caller checks the observation against tool evidence and the resulting work.

## Reviewed contribution: ergentics.corpus-promotion.v1

The `promote` helper takes an externally pinned request with authority, a source root, one complete candidate entry, review, destination corpus ID/version/owner and extensions. Review must be accepted and name the same reviewer as the entry. Its positive and golden-negative evidence each name a path/SHA for a `ergentics.corpus-review-check.v1` record with matching candidate SHA, corresponding `kind`, PASS result, method and observation.

This establishes content joins to reviewed records, not signer authentication or automatic trust in claimed test results. The caller must authorize the exact source file and review evidence before supplying the request pin; a caller can mislabel arbitrary bytes, and another self-supplied manifest would not authenticate that caller. The helper is a selective packaging tool, not a policy-enforcement boundary against its operator. It writes one new contribution corpus and receipt without altering any existing corpus or originals. Each promoted entry gains a reserved `ergentics.promotion` extension with source/request identity and structured positive/negative evidence pins, so its lineage travels in the index. A receiving run can select this contribution corpus explicitly. Consolidating contributions into a shared release is an explicit reviewed version update, not background mutation. Corpus review/check records describe the actual method, including manual review where applicable.

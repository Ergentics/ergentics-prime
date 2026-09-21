# Ergentics Agents

Version **0.1.0**. Owner and method authority: **Ergentics, LLC**.

Two reusable agents carry the Ergentics implementation roles established in the math studies:

| Stable Agent ID | Role definition | Implementation |
| --- | --- | --- |
| `ergentics_swift_c` | [Swift+C Agent](agents/ergentics_swift_c/AGENT.md) | Swift with purposeful C interfaces and native computation |
| `ergentics_cpp` | [C/C++ Agent](agents/ergentics_cpp/AGENT.md) | C17 and C++20, with explicit ownership and checked numerical operations |

An Agent is its versioned identity, instructions, operating contract and recorded task state. The operator/model used to carry out that role is selected for each dispatch. These definitions supply no AI weights, resident service or implied background activity.

## Load an Agent

Use [LOAD.md](LOAD.md) with the selected Agent ID and the actual bundle path. This explicit instruction handoff works with the current collaboration tools. It loads an existing definition into a permitted task context; it does not itself dispatch a scientific run.

[Codex role adapters](adapters/codex/README.md) are provided separately. Their native named-role registration and dispatch have a different verification status from an observed explicit instruction load. Refer to the external release receipt for checks actually completed.

The shared [operating contract](shared/OPERATING-CONTRACT.md) describes task recovery, execution and evidence. [Run record](contracts/run-record.schema.json) and [load receipt](contracts/load-receipt.schema.json) schemas support those distinctions. Use existing project task notes when available; the schemas do not require a second task-management system.

## Extend without losing history

Stable Agent IDs remain unchanged when a compatible implementation or lesson is added. Package version, Agent definition version, run-record schema, policy version and task attempt ID are separate identities. For this first bundle both Agent versions are 0.1.0.

- Patch: clarify instructions without changing capabilities, defaults or evidence meaning.
- Minor: add a compatible capability, adapter, or optional extension with corresponding checks.
- Major: change required inputs, authority semantics or incompatible result meanings.

Keep `agents.json`, Agent metadata, source instructions, generated adapters, manifest and validation evidence consistent. A changed released file needs a new version; retain prior bundles and failures. Record scoped additions in [CHANGELOG.md](CHANGELOG.md). Extensible data belongs in a named `extensions` object, not in instructions inferred from task data.

The bundle is prepared for ordinary Git review as text. The current task's commit hold remains active. A manifest is local content identity, not a Git commit or remote durability. No separate Git history is initialized by this package; integrate into the selected existing Ergentics repository when that destination is established.

## Lineage and limits

[Selected lineage](references/lineage.json) records the math-run roles, installed display packages, and later review limits. The display packages' fixed-fixture renderers are historical implementations. New problems use newly bound source, input and runtime; do not run an old helper simply because its skill is readable. Later repository review records unresolved alerts in old helpers, so matching old file hashes is not their safety clearance.

Shared capabilities such as Alignment, Behavior Review, task-relevant Math Gate methods, Auto Harvest and golden cases are loaded for the current task as applicable. Their actual runtime state is recorded separately. Preserve the task's current approved state instead of inheriting old studies' held helpers, archive caps, deadlines or attempt authorizations.

This release does not change the existing Prime assessment skill, retained PyYAML runtime, installed historical skills, canonical policy or protected mathematical exam. Local creation, explicit loading, native adapter activation, implementation execution and Git publication remain separately evidenced.

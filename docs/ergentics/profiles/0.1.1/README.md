# Ergentics operating profiles

Package version **0.1.1**. Owner and method authority: **Ergentics, LLC**.

Two reusable profiles, `ergentics_swift_c` and `ergentics_cpp`, layer explicit method, continuity, corpus and run bindings over the preserved Ergentics Agents v0.1.0 definitions. Profile identity is independent of the operator model. Each runtime still needs supported tools, authorized data handling and relevant observed behavior.

The [loading procedure](LOAD.md) uses the Ruby standard-library [packet helper](scripts/profile_packet.rb). It accepts externally pinned profile/Agent manifests, a policy binding, an allowlisted corpus and one current run request. It reads only selected eligible corpus payloads, writes a new packet and records requested versus observed state. No model client, scheduler, monitor, dependency installer or network client is included.

See [JSON contracts](CONTRACTS.md), the [corpus and outputs guide](CORPUS.md), and the [Codex adapter](adapters/codex.md). [Portability](adapters/portability.md) describes what a relocated packet proves and what another runtime still needs. The external release receipt records actual checks and observed loads; this README does not qualify its own claims.

These are operating profiles and selected knowledge, not model weights. Surface remains a prototype whose readiness is incomplete; this package does not change or launch it. Task authorization and readiness holds come from the current receiving task, not historical release notes. This compatible helper repair keeps both logical profiles and their Agent dependencies at v0.1.0; package/helper version is v0.1.1.

## Extension and version control

Preserve stable profile IDs and prior releases. Package version, profile version, underlying Agent version, policy version, corpus version and run ID are distinct. Patch versions clarify compatible behavior; minor versions add optional capabilities or adapters; major versions change required meanings or inputs. Unknown top-level fields are rejected. Optional data uses namespaced `extensions`; extensions never become commands or authority.

A changed released file requires an appropriate version, refreshed manifest, affected checks and observed loading where behavior changes. Keep run state and outputs outside immutable releases. The Ruby helper depends only on its interpreter and standard library; record the interpreter used for checks. No repository is initialized by this package. Integrate these text files into the selected existing repository once that destination and the commit action are established.

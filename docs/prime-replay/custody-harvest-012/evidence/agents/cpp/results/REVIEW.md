# Prime custody candidate review — C/C++ role

Run `prime-custody-012-cpp`; profile `ergentics_cpp` v0.1.0. The packet receipt is independently verified at SHA256 `a27a438ab0052c08b351c0101769c7e240227e52a2a38eeb1aece9818445f266`. Its nine declared members are exactly the nine files present, and all member bytes and hashes match. The eight task-input extensions also match their declared bytes and SHA256 values.

The selected accepted corpus entries were read by exact ID/version/hash: `evidence-stages` 0.1.0 (`fa7afb83b35e03d9a74ba05d56c0e69744b40d512bedd723eed892f77c623d06`) and `phase-scoped-observations` 0.1.0 (`b5a34d0a0f2bb2455a2e15f10a9d86a3a9c5dfd446148da02651185d8120b346`). The installed profile/agent manifests, policy EA-POLICY-001 v0.4.1, installed loader and canonical observation template were also hash-checked. This is an observed hosted packet read and response; the packet's earlier `NOT_PERFORMED` preparation state remains a separate fact.

The candidate skill has the correct core custody model: event delivery, caller admission, executed/skipped checks, qualification, durability, merge destination, phase-specific authority, and model/effort versus serving identity are separate. Its Prime derivation correctly preserves the run-178 admission failure, skipped native work, and the distinction between mergeability and CI success. The raw-case answers are in `responses.json`.

Two corrections are required before acceptance:

1. `SKILL.md:72-73` should explicitly say that Auto Harvest is a logical capability, not evidence of an installed package, scheduler, publication route, or authority to install one. Those operations remain separately authorized.
2. `SKILL.md:74-77` links to `references/metadata-validation.md`, but that file is absent from the candidate package. Pin a valid installed/shared procedure or include the referenced file with version and hash.

The candidate and lesson remain review inputs only. No corpus promotion or installed-skill update was performed. No CI, launch, install, network, repository mutation, or native execution was performed. Requested model `gpt-5.6-luna` and effort `high` are recorded as requested values only; serving build and realized effort are unknown.

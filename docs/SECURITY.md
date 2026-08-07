# Security policy

## Reporting a vulnerability

Do not disclose a suspected vulnerability in a public issue. Use GitHub's
private vulnerability-reporting entry for this repository when it is visible.
If that entry is unavailable, use the private contact method published on the
Ergentics GitHub organization or business profile. Include the affected commit,
the narrowest reproducible case, the observed impact, and whether any secret or
private artifact may have been exposed. Do not include live credentials.

## Validation and runner boundary

The GitHub-hosted Driver V2 workflow is a non-authoritative supervisor-image
canary. It may prove two disjoint builds have identical bytes and that the
current executable image is bound before execution. It cannot authorize build,
test, inventory, artifact staging, shard completion, or release completion.

Strict promotion requires a dedicated Apple-silicon runner with Xcode 26.6
(build 17F113) installed in a root-owned, non-writable system directory before
the Actions service starts. The strict workflow is manual and requires the
labels `self-hosted`, `macOS`, `ARM64`, and `ergentics-prime-promotion`. The
workflow does not register or start that runner. If no such runner is active,
ordinary pushes remain available and no strict job is queued unless someone
explicitly dispatches it.

SwiftPM sandboxing remains enabled. `--disable-sandbox`, permissive failure,
and relabeling an environmental rejection as strict success are outside the
security contract.

## Credentials and dependencies

GitHub workflow permissions are `contents: read`. The external
`ERGENTICS_PAT` credential cannot be downscoped by workflow permissions and
must independently remain read-only for the exact companion and first-party
MLX repositories. Workflows disable persisted checkout credentials and pin
checkout actions and repository revisions exactly.

Third-party license and attribution obligations are recorded in
`THIRD_PARTY_NOTICES.md`. A dependency's license does not grant it runtime,
decoder, training, quantization, release, or security authority.

The active Prime package and validation locks must not contain
`mlx-swift-lm` or an `MLXLLM` product binding. Historical Llama source and
receipts remain immutable research accounting and must not be copied into a
current dependency graph, a Driver authority claim, or a released PMHNP
application claim. The current trace and the bounded Python-process exception
are recorded in
`docs/PRIME-LLAMA-QUARANTINE-AND-PYTHON-TRACE-2026-08-04.md`.

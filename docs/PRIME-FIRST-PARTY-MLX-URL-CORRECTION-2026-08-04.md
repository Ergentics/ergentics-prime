# Prime first-party MLX URL correction — 2026-08-04

## Active dependency rule

Every active Prime Swift package manifest and `Package.resolved` pin for the Ergentics MLX fork names the first-party repository directly:

`https://github.com/Ergentics/ergentics-mlx-swift`

The exact active root revision remains:

`d37885a278f1c37484a94d0f401a418735e66519`

The typed-optimizer mechanics validation retains its older, explicitly frozen first-party revision:

`68904d54b72871f26968261ae05d4fbb7c5e3142`

The checked-in active `mirrors.json` files remain part of the source-provenance inventory but contain an empty mirror set. They cannot reverse-canonicalize the first-party dependency to `ml-explore/mlx-swift`.

## Correction boundary

Before this correction, the root manifest named the Ergentics repository while SwiftPM mirror configuration caused the root lockfile to record the upstream `ml-explore/mlx-swift` location with an Ergentics-only revision. The typed-optimizer validation manifest still named the upstream repository directly and relied on the mirror for its Ergentics-only revision. Both forms were operationally ambiguous and could send a clean resolver to a repository that does not contain the pinned revision; neither changed the licensed source bytes.

This correction updates only active manifests, active lockfiles, active no-remapping configuration, and their live validation gates. It does not rewrite retained evidence packages, archived artifact copies, historical receipts, or frozen historical contract values. Those files continue to describe the configuration under which their evidence was originally produced.

## Validation rule

CI fails closed unless:

- the active mirror configuration contains no mapping;
- the root lock has exactly one `ergentics-mlx-swift` pin;
- that pin's location is the Ergentics repository;
- that pin's revision is the exact admitted Ergentics revision; and
- the lockfile and manifest hashes match the source-bound CI constants.

SwiftPM lock regeneration must run with normal sandboxing. A managed environment that cannot nest SwiftPM's sandbox may validate JSON, hashes, source contracts, and direct compiler parsing, but it must not use `--disable-sandbox` to manufacture a resolver result.

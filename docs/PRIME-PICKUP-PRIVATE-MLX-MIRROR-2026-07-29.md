# Prime private MLX mirror migration pickup

Status: active durability and publication map
Snapshot date: 2026-07-29
Scope: typed optimizer restore R&D only

## Outcome and rewrite boundary

This migration makes the exact MLX Swift derivative remotely resolvable from a
private, license-preserving Ergentics repository and then rebinds Prime's
typed-optimizer evidence to that durable revision.

The rewrite boundary was limited to the two pre-existing unpushed arc tips:

| Repository | Branch | Pre-migration tip | Actual permitted treatment |
| --- | --- | --- | --- |
| `ergentics-mlx-swift` working copy | `feat/typed-optimizer-state-0.31.3` | `ba97519f91557e8160515ef2c8fa3dd6725aa875` | Metadata-only identity normalization produced `d913077c02b961dcf515e093c77c541095b4572b` with the identical source tree; after private publication, the owner-selected legal name was added as a normal fast-forward SPDX commit `68904d54b72871f26968261ae05d4fbb7c5e3142`, never a force rewrite |
| `ergentics-prime` | `feat/prime-typed-optimizer-restore-rd` | `b27e652ea60f7ff0b644127fd60bd78dde51f1f5` | Rebind dependency provenance, refresh source-bound evidence, and normalize this tip's author and committer to `Ashton <support@ergentics.com>` |

Do not rewrite `origin/main`, any merged PMHNP companion commit, upstream MLX
history, another contributor's authorship, or an existing historical `.local`
identity. A `.local` address is not treated as invalid history and may remain
where an operational tool requires it. Identity normalization is deliberately
limited to the two controlled pre-existing tips. The additive legal-name
commit preserves the already-pushed normalized MLX commit as its parent.

Repository-local Git identity is the durable default for these two working
copies:

```text
user.name = Ashton
user.email = support@ergentics.com
```

No global Git identity change is authorized by this map.

## Frozen starting points

### MLX Swift derivative

- working copy:
  `work/mlx-swift-ergentics`
- derivative tip:
  `ba97519f91557e8160515ef2c8fa3dd6725aa875`
- pinned upstream parent and tag:
  `61b9e011e09a62b489f6bd647958f1555bdf2896` / `0.31.3`
- intended source delta:
  `Package.swift`,
  `Source/MLXOptimizers/AdamOptimizerState.swift`, and
  `Tests/MLXOptimizerStatePublicAPITests/AdamOptimizerStatePublicAPITests.swift`
- final delta size relative to `0.31.3`:
  1,283 insertions across three files; the only change after the 1,281-line
  functional patch is SPDX metadata on the two new Ergentics-authored files
- old public fork:
  `https://github.com/Ergentics/mlx-swift`
- new private mirror:
  `https://github.com/Ergentics/ergentics-mlx-swift`
- private mirror verification:
  created empty under the `Ergentics` organization; GitHub reports
  `visibility: private` and admin/push access
- normalized derivative tip:
  `d913077c02b961dcf515e093c77c541095b4572b`
- authoritative rights-holder-corrected derivative tip:
  `68904d54b72871f26968261ae05d4fbb7c5e3142`
- remotely verified explicit refs:
  `main` and tag `0.31.3` resolve to
  `61b9e011e09a62b489f6bd647958f1555bdf2896`; branch
  `feat/typed-optimizer-state-0.31.3` resolves to
  `68904d54b72871f26968261ae05d4fbb7c5e3142`

The repository must retain the complete upstream history and MIT license and
notices. The private mirror is an R&D dependency source, not a public release
or an upstream-acceptance claim.

The private mirror was populated with those three explicit refspecs only.
Never use `git push --all` or `git push --mirror`: local recovery refs and
cache/public/upstream namespaces are not publication inputs. The local
working copy makes `origin` the default push target and gives `public-fork`,
`upstream`, and `cache` disabled push URLs.

### Rights-holder decision resolved

Prime's committed governance charter requires the human repository owner to
choose the legal rights-holder name before durable private or public
publication of the derivative. On 2026-07-29 the owner selected the exact
legal spelling `Ergentics, LLC`. Commit
`68904d54b72871f26968261ae05d4fbb7c5e3142` records that entity in
`SPDX-FileCopyrightText` with `SPDX-License-Identifier: MIT` on both new
Ergentics-authored MLX files. Normalizing Git author/committer identity to
`Ashton <support@ergentics.com>` remains a separate display-identity action.
Ordinary `Ergentics` brand, package, repository, and GitHub organization names
do not acquire the legal comma/suffix.

### Private mirror hardening before a mirror pull request

The inherited upstream workflows are source-controlled. Their jobs currently
fail closed on `github.repository == 'ml-explore/mlx-swift'`, so the explicit
branch push did not execute the build or release jobs. They still contain
third-party actions and a manual release workflow with write-scoped
`GITHUB_TOKEN` use. Before opening a pull request or enabling manual workflow
execution in the private mirror:

- verify organization/repository access and secret exposure;
- restrict Actions and set the default workflow token read-only;
- verify force-push/deletion protection for the durable derivative ref or
  publish a deliberately reviewed immutable tag;
- retain the upstream-repository job guards unless a separate workflow review
  admits Ergentics execution;
- never place a PAT, credential, or token in a Git URL, SwiftPM mirror file,
  receipt, log, or tracked configuration.

The amended commits are currently unsigned. The normalized email is display
identity, not cryptographic provenance; do not claim signed authorship.

### Prime

- working copy:
  `work/ergentics-prime`
- branch:
  `feat/prime-typed-optimizer-restore-rd`
- pre-migration tip:
  `b27e652ea60f7ff0b644127fd60bd78dde51f1f5`
- unchanged base:
  `5a8aa46c725b3f3c863ccfbfb5073549fcd18e33`
- pre-migration source identity:
  `7eb18cb2bad97278f574502fbcaf51503dc4ec0f9b96c3fe2ce22065351773d9`
- preserved historical canonical receipt:
  `5729c38b9ee4603102be0b9e430917033a075ba15da399786ea6328f2c5e5f27`
- preserved historical receipt root:
  `outputs/prime-typed-restore-5729c38b`

The historical receipt is immutable evidence for the local-only derivative
revision. Do not overwrite or relabel it. The post-migration run must use a
new empty mode-0700 artifact root and publish a new receipt.
That output path and its local recovery ref are not off-device backups.

The schema-1 `PrimeOptimizerRestoreProbe` remains an archival stock-API
diagnostic. It is not a live gate for the migrated root and must not be rebound
to the typed derivative; any intentional rerun requires an isolated package
pinned to upstream `mlx-swift` `0.31.3`. The migrated root's authoritative
path is the schema-2 `PrimeTypedOptimizerRestoreProbe`.

The PMHNP companion remains clean at its already merged history. Its 55-commit
Metal/quant arc remains governed by
`PMHNP-METAL-QUANT-ARC-RESOLUTION-2026-07-29.md`; this migration must not
rewrite or reinterpret it.

## Role-separated MLX resource closure

The Xcode resource bundle and canonical SwiftPM runtime bundle are two
different typed roles. They share the exact metallib but intentionally have
different manifests:

| Role | Build location | `Info.plist` identity | `default.metallib` identity |
| --- | --- | --- | --- |
| Xcode donor; stage-time input only | `.build/apple/Build/Products/Release/mlx-swift_Cmlx.bundle` beside the unexecuted Xcode host | 1,130 bytes; SHA-256 `124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e`; `CFBundleIdentifier=ergentics-mlx-swift.Cmlx.resources` | 3,817,916 bytes; SHA-256 `24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b` |
| Canonical SwiftPM runtime and receipt | `.build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle` beside the executable that actually runs | 1,120 bytes; SHA-256 `62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d`; `CFBundleIdentifier=mlx-swift.Cmlx.resources` | 3,817,916 bytes; SHA-256 `24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b` |

`PrimeMLXBundleStage` is a one-way, role-separated bridge. It must
descriptor-validate a trusted Xcode source-host anchor plus the exact donor
bundle tree, manifest, and metallib on every invocation, even when the
destination already contains the exact metallib. The unexecuted anchor's
executable bytes are not donor provenance. It must separately validate the
destination SwiftPM host and pre-existing canonical manifest. It may publish
only the exact metallib into an absent destination metallib path, using
no-replace semantics. An already exact destination is idempotent only after
source validation; any other existing bytes fail without overwrite.

The donor manifest is never a runtime substitute. The stager must not copy,
rewrite, synthesize, normalize, or overwrite either `Info.plist`. Runtime
preflight, immutable artifact capture, and receipt replay admit only the
canonical SwiftPM manifest plus the shared exact metallib. The Xcode donor
manifest remains typed staging-input provenance and is not added to a generic
runtime allowlist.

The complete PrimeCore suite must read its canonical fixture from:

```sh
PRIME_TEST_PINNED_MLX_METALLIB=.build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib swift test
```

The staging source host remains the Xcode Release path under
`.build/apple/Build/Products/Release`; changing the test fixture does not
collapse the donor and runtime roles.

## Ordered execution

1. Create local-only recovery refs for both frozen starting tips.
2. Set repository-local Git identity in both working copies.
3. Amend only the MLX derivative tip with the normalized identity.
4. Prove that the amended MLX commit has the same parent, paths, patch, and
   license content as the frozen derivative tip.
5. Add a private-mirror remote and push only the explicit `main`, `0.31.3`,
   and feature-branch refspecs. Verify the exact amended revision and private
   visibility through GitHub.
6. Record the owner-selected `Ergentics, LLC` name in a normal fast-forward
   SPDX commit, verify that it changes only the two new derivative files, and
   fast-forward only the private feature branch.
7. Replace every Prime reference to the old public fork and old derivative
   revision, including root and isolated package manifests, resolved files,
   Swift contracts, tests, notices, mirrors, and planning prose.
8. Replace all “local-only/not remote-resolvable” statements with the exact
   private-mirror boundary. Do not claim public availability, upstream
   acceptance, full transitive closure, or functional model quality.
9. Complete all documentation and provenance edits before freezing the new
   Prime source identity.
10. Run root Swift tests and the isolated typed-restore mechanics tests.
11. Build the Xcode donor and SwiftPM Release runtime, validate both typed
    manifests, stage only the exact metallib with no-replace semantics, then
    run the canonical three-process typed optimizer gate in a new artifact
    root.
12. Verify the new immutable receipt, dependency tree, metallib, process,
    mutation, and source identities from the produced artifacts.
13. Amend only the Prime feature tip with the normalized identity, recheck
    the final tree, push its branch, and open a draft pull request.
14. Only after that pull request merges, run the separately bounded
    interrupted MLX Swift/Metal continuation canary.

## Revision reconciliation ledger

| Binding | Before | After |
| --- | --- | --- |
| MLX derivative revision | `ba97519f91557e8160515ef2c8fa3dd6725aa875` | metadata-normalized `d913077c02b961dcf515e093c77c541095b4572b`, then additive rights-holder-corrected `68904d54b72871f26968261ae05d4fbb7c5e3142` |
| MLX dependency URL | `https://github.com/Ergentics/mlx-swift` | `https://github.com/Ergentics/ergentics-mlx-swift` |
| SwiftPM identity / checkout | `mlx-swift` | frozen `ergentics-mlx-swift`; target products and exact dependency-source verifier use the same identity |
| Prime feature revision | `b27e652ea60f7ff0b644127fd60bd78dde51f1f5` | recorded outside the source-hashed tree after the final commit |
| Prime source identity | `7eb18cb2bad97278f574502fbcaf51503dc4ec0f9b96c3fe2ce22065351773d9` | recorded outside the source-hashed tree after final source freeze |
| canonical typed-restore receipt | `5729c38b9ee4603102be0b9e430917033a075ba15da399786ea6328f2c5e5f27` | recorded outside the source-hashed tree after the new immutable run |

The final Prime commit SHA, source identity, and receipt hash are deliberately
not embedded in this source-hashed document. Doing so would make the commit
self-referential and would change the source identity while trying to record
it. Close the migration in the draft pull-request body and final external
handoff after the evidence-bearing commit exists; do not iterate toward a
fictional fixed point.

## Fail-closed verification gates

- both working trees have an intentionally understood diff before staging;
- the MLX source patch relative to `0.31.3` is byte-equivalent before and
  after identity normalization;
- the additive legal-name commit changes only the two new MLX files and names
  `Ergentics, LLC` under MIT SPDX metadata;
- GitHub independently reports the mirror as private;
- the amended MLX commit is remotely resolvable from the private mirror;
- an authenticated cache-empty clone and SwiftPM resolution succeed without a
  credential embedded in source or logs;
- root and isolated Swift package resolution bind the same canonical original,
  private mirror, `ergentics-mlx-swift` identity, and revision;
- no source-controlled reference to the old derivative SHA or public fork
  remains except the explicitly labeled historical ledger in this document;
- root `swift test` and isolated mechanics `swift test` pass;
- Xcode donor validation runs even when the canonical SwiftPM destination
  metallib already exists and is exact;
- staging transfers only the exact metallib; it never copies or overwrites an
  `Info.plist`, and any wrong existing destination metallib fails closed;
- runtime and receipt replay bind the canonical 1,120-byte SwiftPM manifest
  and shared exact metallib, never the 1,130-byte Xcode donor manifest;
- the final canonical Release run uses three fresh clean worker processes and
  disposes all declared mutations;
- receipt replay binds the final source identity, executable, full admitted
  MLX source tree, metallib, checkpoints, and raw role records;
- author and committer of the normalized MLX tip, additive SPDX commit, and
  final Prime tip are exactly
  `Ashton <support@ergentics.com>`;
- all earlier authors remain unchanged.

Any missing, ambiguous, or contradictory observation stops publication and
records `ABSTAIN`; it is not repaired by prose.

## Recovery and do-nots

The pre-migration object IDs above are recovery anchors even after an amend.
Local recovery refs make them easier to reach, but they are local-only and do
not survive loss of this working copy. The private feature branch preserves
the normalized derivative, not its pre-normalization commit metadata. If
reconciliation fails, stop with both local objects preserved; do not
force-push, delete the historical receipt, or reset another branch.

Do not:

- push the derivative patch to the public `Ergentics/mlx-swift` fork;
- use `git push --all` or `git push --mirror`;
- publish a recovery ref or cache/public/upstream namespace;
- initialize the private mirror with a separate README or license commit;
- squash away upstream MLX history;
- rewrite any merged branch or another author's identity;
- overwrite `outputs/prime-typed-restore-5729c38b`;
- treat the Xcode donor manifest as a runtime/receipt substitute or copy it
  over the canonical SwiftPM manifest;
- allow Python or shell to author or grade Prime evidence;
- reinterpret CPU typed-restore mechanics as Metal continuation, language
  learning, quantization, model quality, product, clinical, or scientific
  evidence;
- begin a long, profile-ranking, retained functional-checkpoint, or functional
  training run.

## Next authorized execution after merge

The private-mirror work originally left the model choice as a small
MLX Swift/Metal continuation canary. The subsequent cross-repository audit in
[`PRIME-NEURALKIT-ARC-CONTINUITY-2026-07-29.md`](PRIME-NEURALKIT-ARC-CONTINUITY-2026-07-29.md)
supersedes only that model choice: the bounded gate now uses the existing exact
3B profile so it does not create another model lineage or repeat the 10M
mechanics canary.

The next bounded experiment is therefore:

```text
uninterrupted control N+1
versus
Metal train to N -> exact checkpoint -> fresh process restore -> N+1
```

It must bind model state, both Adam moment families, optimizer step,
initialization/training/evaluation seed domains, schedule position, RNG state,
executable, dependency source, metallib, raw observations, and resource
measurements. Passing that gate authorizes planning the next mechanics slice;
it does not authorize functional or long training.

The complete CPU typed-restore evidence root is now repository-durable at
`3481ffc`. Before executing the Metal gate, resolve only the four Prime-owned
exact-3B/CPU evidence bindings required by this task and run the narrowly
scoped compatibility checks needed for the current Prime/private-MLX runtime.
Tokenizer/corpus/evaluator migration, NeuralKit execution, and PMHNP consumer
changes are outside this AdamW slice. PMHNP remains a read-only historical
oracle and is not a write target. The exact 3B geometry is an operator-selected
mechanics choice; it does not overturn the historical schema-6 `ABSTAIN` or
authorize the scale.

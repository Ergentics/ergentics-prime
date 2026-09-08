# Driver V2 current source inventory v1 — 2026-09-07

This additive `current_source_inventory_v1` profile reconciles the current source with its observed test inventory under the user's authorization to preserve existing work, adjust the workflow, and proceed through Driver V2 F–H with delegated work. It preserves the historical 904-test profile, its default selection, original anchors, resources, Planner algorithm, and existing plan/receipt encoding.

The profile identity remains the exact six-field tuple: count, raw byte count and SHA-256 for each framework. No profile-name field is added to the intent or receipt schema. Only an explicitly selected, compiled known whole tuple is admissible; mixed fields, caller-defined anchors and selection inferred from incoming output reject.

| Profile/framework | IDs | Bytes | Raw SHA-256 |
| --- | ---: | ---: | --- |
| Historical XCTest | 892 | 114186 | `93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b` |
| Current XCTest | 1068 | 139244 | `7428f3e1ebc8e76eb312c54feac209d0c70d8d741e1eb38cbab8b1d5b815ece2` |
| Both profiles: Swift Testing | 12 | 1287 | `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3` |

Native G06 observed both current streams from source commit `3c95246366e1f602b8a9790b1317ce2506e2b006`, source identity `d486f0e60b27feb01e6f3d6d9fe62c312074bceb70643a48967c0b76dbbf52e1`. Run `prime-driver-v2-gate-g-3c95246-20260907T190000Z` retained them beneath:

`/private/tmp/prime-gate-g-live-80bb1cc7-7539-436c-802e-cb6a88d37c50/production/evidence/prime-driver-v2-gate-g-3c95246-20260907T190000Z/inventory/`

The files are `xctest-list.stdout.log` and `swift-testing-list.stdout.log`. Both list children completed with exit zero and exact reap, with the physical Swift test alias recorded. Independent mechanical review and the actual compiled Swift inventory parser passed. The typed inventory identity is `6303c8bc34045b39adc9821c0e84174e571c0807229d38e21c008d7fdf18eba9`.

Evidence paths below are relative to task `/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users`:

- `work/gate-g-live/independent-reader/calibration-physical-argv0-v1/review-attempt-06-01.json`; SHA `a5c4db42d163cee0a7685f14b6c9c0db980d227d7eceb57cf641cb76b559cf9e`.
- `work/gate-g-live/independent-reader/calibration-physical-argv0-v1/run-attempt-06-02/result.json`; SHA `91984800e4e533fb718c1efda3c3a43dd17390a64b390793f77a46469594b718`.
- `work/gate-g-live/diagnosis/attempt-04/source-provenance-final.json`; SHA `8e5a8d30f3dad9dd6683af771182778d732ec901bd402de2b9e7158a755f1ed6`. Its exact ID/source audit attributes all 176 additions to inherited coverage: 116 Latin tests and 60 Core tests across 60 source files. All historical 892 XCTest IDs remain; zero were removed. No tests are relocated, deleted or filtered.

This accepts candidate calibration, not a Gate G pass: G06 remains a contained nonzero result under the historical anchor. It establishes no H execution or StartOwner integration. Historical failures and receipts remain unchanged.

Final H selection requires a separate accepted record joining these observations to the newly tested, sealed and committed source pin. Its execution-go scope separately binds the matching rebuilt images. That record is not minted by this note. Fixed suite-contiguous partitions, 32-test/16,384-byte filter limits, reference-three layout, budgets, skip policy and semantic validation remain unchanged.

## Separate H execution allowance after attempt 02

H02 on `9b9fca6e9c50431ab3875bf6bdc53b30ca31a8ec` reached 806 of 1,068 first-reference XCTest progress rows when its shared 1,800-second arm deadline expired. It retained successful typed F/G bindings and four phase prefixes, but no shard or outer terminal. Governor exit 70 and captured supervisor diagnostic 98 remain failed/incomplete evidence. The raw and typed review is `work/gate-h-live/independent-reader/contained-attempt-02/verification.json`, SHA `f31d382a4f1bd8c5448ca1586e5000827a913b08a8db9231be4b03676b32c0fe`.

The separately named `current_source_execution_v1` allowance declares 10,800 seconds for each complete arm, shared across its children. The reference contains three lanes; the candidate contains 81 shards executed serially, including both complete XCTest coverages. This is a finite allowance with uncertainty, not an observed completion upper bound. The runtime review is `work/gate-h-live/diagnosis/attempt-02/runtime-allowance-review.json`, SHA `31b6af8a7193d008800cdf09fef4c0b918c79c6eb1daae2628dfd5bcf3501b86`.

The historical 1,800-second profile and default bytes remain unchanged. Only the complete new nine-phase budget array together with the explicit current inventory is admitted, and only the live H route permits that budget profile. Intent, original Planner output, go scope, native deadlines, process joins, phase history, publication and independent reader must agree. All other phase limits remain unchanged: 23,070 seconds total plus the existing 30-second outer margin gives 23,100 seconds; the separate task transport is bounded at 23,200 seconds. Shard identifiers, selections, ordering, commands, worker count, tests, resource pins and historical evidence are preserved. H02 cleanup is independently repaired and validated before any fresh attempt; changing the allowance cannot convert H02 into success.

H rejection cleanup retains the suspended leader's identity, stops and rejoins its descendant tree, kills deepest workers before the leader, and requires captured generations and groups to disappear. Its separate bound is two seconds to freeze, the existing nine-second leader cleanup, and three seconds to settle. Unknown ancestry, changed identity or incomplete cleanup still fails closed; Governor checks are unchanged. A bounded native fixture using the exact helper body and retained testable Debug16 supervision passed in `work/gate-h-timeout-cleanup-repair-draft/native-fixture/run-02/transport-result.json`: leader 50680 and worker 50683 had separate groups under session 50679, exact leader cleanup occurred once, and the external observer found no live members or need for rescue signals. Rejection drains were closed terminal error drains, not normal-success EOF; that distinction is recorded. This fixture does not establish H completion. Its earlier assertion failure and all failed fixture builds remain preserved.

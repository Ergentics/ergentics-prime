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

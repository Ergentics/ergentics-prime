# Changes

## 0.1.1 — 2026-09-21

Repair output verification for valid UTF-8 JSON/corpus content: compare binary bytes after readback so differing Ruby encoding labels cannot reject identical bytes. Actual byte mismatches still fail with INCOMPLETE retained. Add a UTF-8 roundtrip regression and corrupted-output negative. Packet/request schemas, profile identities v0.1.0, Agent v0.1.0 dependency, eligibility, caps, source pins and authority are unchanged. The original failed promoted-corpus preparation is preserved in Prime custody harvest 012. This candidate does not replace the installed v0.1.0 package.

## 0.1.0

Initial operating-profile extension over preserved Ergentics Agents v0.1.0. Adds two model-independent profiles, explicit per-run requested settings and processing bindings, a six-entry selected corpus, bounded packet preparation with read ledgers, and reviewed contribution packaging with positive/negative evidence joins. Records load versus preparation, ownership/custody and portability limits separately. Actual release/check/load state is bound by the external receipt.

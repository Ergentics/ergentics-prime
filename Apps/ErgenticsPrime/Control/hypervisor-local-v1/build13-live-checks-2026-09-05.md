# Build 13 live checks — September 5, 2026

The previously blocked control-tool attachment succeeded on retry. Its earlier root cause is unconfirmed. Actual native runs and UI inspection now establish the following bounded results.

- **Build 12 signed Release H5:** PASS, three accepted runs, generations 1→2, 3→4, 5→6. Receipt root `6bc8690119b765638166fb9256a3c33efc025ef2335aaeb498742aa6c99e0611`.
- **Build 13 archived H3:** VERIFIED_PASS, checkpoint 42 → resume 43, 113812 ticks at 125/3 ns per tick. Receipt root `90e5f97fba3d3894252ae4016a7ef577be4ab98bd917a374fb141d9d8225134e`.
- **H6 live Accessibility check:** all four H3 State/Graph JSON/CBOR disclosures were expanded. The returned 26224-character tree contained VERIFIED_PASS and all four expanded controls, with neither `h3-native-diagnostic` nor its former diagnostic heading. This inspected the successful H3 surface; no live failure was injected.
- **Build 13 archived H5:** PASS, three accepted runs, generations 1→2, 3→4, 5→6. Receipt root `47ab6d3b0b917524314fcaf3325447ca57aa417e6812301a3def9476845a6e2d`.

Both H5 runs share comparison root `834e600b023a9131394810e071aa6af703bf64c9cdda0c0364204cab514107ea`. The displayed JSON was captured, deterministic CBOR independently reconstructed, and both displayed receipt roots reproduced. Exact summary streams and verification records are retained in `/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Build13-Live-Checks`; they do not contain all original per-run H3 evidence.

The archived executable still hashes to `518d6fb4fc488621f13ae11491e0c5fc0ce45af689a74f426031e8726a9a7fb5` and passes strict signature verification after execution. Its source commit is `30f1953d3f55566794e047bebe0cd4b6824e8085`. The archived app is left open showing H5 PASS. No upload or OS attestation occurred.

# v0.1.1 helper repair review

The candidate repair is an `IMPLEMENTATION_FIX`; its repair record states `protected_scientific_semantics_changed: false`, package version `0.1.1`, logical profile versions unchanged at `0.1.0`, and `installed_changed: false`.

Verified candidate identity:

- Candidate package `MANIFEST.json`: SHA256 `68235f1964e79404b1fd15781c3a987aa5f8a808cf9f48816a0ccbff72954edc`.
- `scripts/profile_packet.rb`: SHA256 `05b78a96f41194abe00328375eb6084dc2ba24f5e3aa4ea09cd996d8bbba3f94`.
- `tests/check_profile_packet.rb`: SHA256 `ea19e9a24cf6c54d998bd84e70b27edfe7cb656b0692b98de60c71fa4f324828`.
- Installed helper identity remains separately recorded as `63ed495b1b26732133141205074bc9321e7d431c9a25b87ad3e30380eb55e459`; it was not read or changed in this review.

The concrete repair changes the helper version from 0.1.0 to 0.1.1 and changes the output verification from encoding-sensitive `copied == bytes` to byte-domain `copied.b == bytes.b`. The surrounding checks still require the written byte size to equal `bytes.bytesize`, read back at most `bytes.bytesize + 1`, and verify the named path's device/inode against the opened descriptor. The finalization rescue preserves an `INCOMPLETE` marker in the exact directory created by the failed invocation.

Actual-byte rejection is retained. The appended `utf8-selected-payload-roundtrip` case writes `Ergentics — café λ 漢字 😀`, pins byte length and digest, checks the emitted corpus text with `.b == payload.b`, and verifies every receipt file hash. The appended `utf8-output-corruption-rejected` case mutates one byte at the same size during a synthetic write, expects `output_hash_mismatch`, and requires `INCOMPLETE` to remain. The attributed candidate regression result reports 42 passed and 0 failed; this task did not execute the helper or repeat those cases.

No concrete blocker to committing this implementation repair was found from the authorized source/test review. The repair is not installed, the installed bindings remain unchanged, and commit or activation was outside this task's authority. Those are separate follow-up operations, not evidence against the repair itself.

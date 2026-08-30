# Hypervisor genesis / Merkle ancestry

Design only. No genesis receipt or new Merkle root has been produced by this
source file. No VM creation or authority-bearing transition is authorized by
a hash. This is separate from the historical static PASS root.

The user's "Merkle root style inception" is interpreted as a committed genesis
followed by explicitly witnessed child states, not recursive VM execution.

## Commitments

A future genesis commits independent, typed leaves for the exact host image
identity, signed entitlement policy, raw Hypervisor capability observations,
execution exclusions, and any explicitly admitted historical parent root.
The historical root remains a reference with its original producer/subject;
it is not relabeled as a new host/guest result. Missing witnesses stay missing.

Use SHA-256 and a versioned domain-separated binary frame:

- Leaf: H(0x00 || u32be(label-byte-count) || UTF8(label) || u64be(payload-byte-count) || payload).
- Binary parent: H(0x01 || left-digest-32 || right-digest-32).
- Unpaired node: H(0x03 || child-digest-32), not implicit duplication.
- Final root: H(0x02 || u64be(leaf-count) || top-digest-32).

Labels must be unique, sorted by UTF-8 bytes; empty sets are rejected. Payloads
are exact retained bytes, not prose summaries. A schema/version leaf is
mandatory. The root is attached outside its own hashed payload; no self hash.
The implementation and test vectors must be reviewed before this format is
used for a live receipt. This document is not itself that implementation.

## State and transition separation

Keep state/witness nodes distinct from transition nodes. A transition commits
its input state roots, output state root, fixed predicate identifier and raw
witness digests. Bidirectional reconstruction must yield the same labels,
payload bytes, predecessor links and root. A round-trip mismatch rejects.

The first possible predicate is capability-only:

`signature_valid && team_bound && entitlements_exact && hardened_runtime &&
hv_support == 1 && max_vcpu_status == HV_SUCCESS && max_ipa_status == HV_SUCCESS`

Even true, it yields `CAPABILITY_OBSERVED / VM_NOT_CREATED`, never VM readiness
or isolation proof. A future VM transition requires its own reviewed lifecycle,
resource limits, memory mappings, guest identity, containment and conservation
witnesses. No parent PASS supplies those missing witnesses.

JSON and CBOR remain distinct future receipt streams with independent decoding
and a join; neither is silently synthesized from the other. Merkle ancestry
does not override that independence or promote Gate E. Authority vector stays
`00000000`, Gate E `ABSTAIN`; energy in ergs remains unmeasured.

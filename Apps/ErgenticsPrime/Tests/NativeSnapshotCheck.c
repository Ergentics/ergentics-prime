/* Standalone HOST test, deliberately absent from app and XCTest source lists.
 * Includes actual production hash functions without a test-only production API.
 * main never calls native run/cancel/signing or any Hypervisor API. */
#include "../Sources/HypervisorGuest.c"
#include <stdio.h>
#include <stdlib.h>

int epr_admit_signing(const char *expected_team, int *error) {
    (void)expected_team; (void)error;
    abort(); /* Any accidental attempt to enter a live run is a test defect. */
}

static void hex(const unsigned char *bytes, size_t count, char *result) {
    const char alphabet[] = "0123456789abcdef";
    for (size_t i = 0; i < count; ++i) {
        result[2 * i] = alphabet[bytes[i] >> 4];
        result[2 * i + 1] = alphabet[bytes[i] & 15];
    }
    result[2 * count] = 0;
}

static bool digest_is(const unsigned char *bytes, size_t count, const char *expected) {
    unsigned char digest[32]; char actual[65];
    if (!CC_SHA256(bytes, (CC_LONG)count, digest)) return false;
    hex(digest, 32, actual);
    return !strcmp(actual, expected);
}

#define CHECK(value) do { if (!(value)) { fprintf(stderr, "FAIL line %d\n", __LINE__); return 1; } } while (0)
int main(void) {
    CHECK(epr_guest_image_size() == 92 && epr_rust_guest_image_size() == 164 &&
          epr_guest_h3_image_size() == 136);
    CHECK(epr_guest_image_load_address() == UINT64_C(0x10000000));
    CHECK(epr_rust_guest_image_load_address() == UINT64_C(0x10000000));
    CHECK(epr_guest_h3_image_load_address() == UINT64_C(0x10000000));
    CHECK(epr_guest_doorbell_instruction_offset() == 80);
    CHECK(epr_rust_guest_doorbell_instruction_offset() == 96);
    CHECK(epr_guest_h3_checkpoint_instruction_offset() == 0x50);
    CHECK(epr_guest_h3_resume_instruction_offset() == 0x54);
    CHECK(epr_guest_h3_terminal_instruction_offset() == 0x7c);
    CHECK(digest_is(epr_guest_image_bytes(), epr_guest_image_size(),
        "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44"));
    CHECK(digest_is(epr_rust_guest_image_bytes(), epr_rust_guest_image_size(),
        "6e1b2a92646a69ef353491b2cde8104c6d6f311bc4d03bb8cb3bd5bb28f4dfa1"));
    CHECK(digest_is(epr_guest_h3_image_bytes(), epr_guest_h3_image_size(),
        "3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0"));
    const uint64_t layout[16] = {
        0x10000000, 16384, 5, 0x10004000, 16384, 1, 0x10008000, 16384, 3,
        0x10010000, 16384, 3, 0x1000c000, 96, 0x10014000, 16
    };
    CHECK(epr_rust_guest_memory_contract_size() == sizeof(layout));
    CHECK(!memcmp(epr_rust_guest_memory_contract_bytes(), layout, sizeof(layout)));
    CHECK(HV_MEMORY_READ == 1 && HV_MEMORY_WRITE == 2 && HV_MEMORY_EXEC == 4);
    EPRGuestResult baseline = empty_result(), successor = empty_result();
    EPRRustGuestResult extra = {0};
    CHECK(baseline.abi_version == 1 && sizeof(baseline.map_status) == 3 * sizeof(int32_t));
    memcpy(baseline.request, expected_request, 32); memcpy(baseline.reply, expected_reply, 32);
    memcpy(successor.request, expected_request, 32); memcpy(successor.reply, expected_reply, 32);
    memcpy(extra.stack_frame, rust_expected_stack_frame, 16);
    CHECK(seal_snapshot(&baseline));
    CHECK(seal_rust_snapshot(&successor, &extra, rust_memory_contract));
    CHECK(baseline.snapshot_sealed == 1 && successor.snapshot_sealed == 1);
    CHECK(baseline.snapshot_ticks > 0 && successor.snapshot_ticks > 0);
    char baseline_root[65], successor_root[65];
    hex(baseline.snapshot_merkle, 32, baseline_root);
    hex(successor.snapshot_merkle, 32, successor_root);
    extra.stack_frame[0] ^= 1;
    CHECK(seal_rust_snapshot(&successor, &extra, rust_memory_contract));
    char changed_root[65]; hex(successor.snapshot_merkle, 32, changed_root);
    CHECK(strcmp(successor_root, changed_root));
    unsigned char digest[32], over_limit[257] = {0};
    CHECK(!leaf_hash("over_limit", over_limit, sizeof(over_limit), digest));

    /* Fabricated host-only H3 framing exercise. No reservation, signing,
     * watchdog, VM, vCPU, map, run, cancel, journal or file API is entered. */
    unsigned char h3_code_page[slot_size] = {0};
    unsigned char h3_request_page[slot_size] = {0};
    unsigned char h3_reply_page[slot_size] = {0};
    memcpy(h3_code_page, h3_guest_image, sizeof(h3_guest_image));
    memcpy(h3_request_page, expected_request, sizeof(expected_request));
    memcpy(h3_reply_page, expected_reply, sizeof(expected_reply));
    unsigned char *h3_pages[h3_region_count] = {
        h3_code_page, h3_request_page, h3_reply_page
    };
    uint64_t h3_gprs[h3_gpr_count] = {0};
    h3_gprs[0] = h3_regions[1].ipa;
    h3_gprs[1] = h3_regions[2].ipa;
    h3_gprs[3] = h3_doorbell_ipa;
    h3_gprs[4] = h3_gprs[5] = 1;
    h3_gprs[6] = 42;
    h3_gprs[7] = 23;
    unsigned char internal_cursor[h3_internal_cursor_bytes] = {0};
    EPRGuestH3CursorResumeResult h3 = h3_empty_result();
    CHECK(h3_encode_internal_cursor(&h3, internal_cursor, 7, 8, h3_gprs,
        UINT64_C(0x600003c5), initial_sctlr, h3_stack_top, 0, h3_pages));
    CHECK(h3_encode_evidence(&h3, internal_cursor));
    CHECK(h3.cursor_sealed == 1 &&
          h3.cursor_evidence.byte_count == EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES);
    CHECK(!memcmp(internal_cursor, h3_internal_magic, sizeof(h3_internal_magic)));
    CHECK(!memcmp(h3.cursor_evidence.bytes, h3_evidence_magic,
                  sizeof(h3_evidence_magic)));
    CHECK(!memcmp(h3.cursor_evidence.bytes + EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES - 32,
                  h3.cursor_sha256, 32));
    EPRH3DecodedCursor decoded = {0};
    CHECK(h3_decode_internal_cursor(internal_cursor, h3.cursor_sha256, 7, 8, &decoded));
    CHECK(decoded.source_generation == 7 && decoded.target_generation == 8);
    CHECK(!memcmp(decoded.gprs, h3_gprs, sizeof(h3_gprs)));
    CHECK(!memcmp(decoded.checkpoint_page, h3_reply_page, slot_size));
    CHECK(h3_terminal_root(h3.checkpoint_reply, h3.cursor_sha256,
                           h3_expected_terminal_reply, h3.terminal_merkle));
    char h3_cursor_sha[65], h3_checkpoint_root_hex[65], h3_terminal_root_hex[65];
    hex(h3.cursor_sha256, 32, h3_cursor_sha);
    hex(h3.checkpoint_merkle, 32, h3_checkpoint_root_hex);
    hex(h3.terminal_merkle, 32, h3_terminal_root_hex);
    internal_cursor[8] ^= 1;
    CHECK(!h3_decode_internal_cursor(internal_cursor, h3.cursor_sha256, 7, 8, &decoded));

    printf("{\"scope\":\"fabricated host-only hash check\",\"baseline_root\":\"%s\",\"rust_root\":\"%s\",\"changed_stack_root\":\"%s\",\"h3_cursor_sha256\":\"%s\",\"h3_checkpoint_root\":\"%s\",\"h3_terminal_root\":\"%s\",\"guest_entries\":0}\n",
        baseline_root, successor_root, changed_root, h3_cursor_sha,
        h3_checkpoint_root_hex, h3_terminal_root_hex);
    return 0;
}

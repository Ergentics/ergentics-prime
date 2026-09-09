#include "HypervisorGuest.h"
#ifndef EPR_GUEST_LIFECYCLE_TESTS
#include "ProvenanceReadOnly.h"
#include "RustBootstrapImage.h"
#include "GuestCapabilityPlan.h"
#include <CommonCrypto/CommonDigest.h>
#include <libkern/OSCacheControl.h>
#include <sys/mman.h>
#include <unistd.h>
#endif
#include <Hypervisor/Hypervisor.h>
#include <errno.h>
#include <limits.h>
#include <mach/mach_time.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#if !defined(__arm64__) || __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#error This fixed guest requires an arm64 little-endian macOS host.
#endif

#ifndef EPR_GUEST_LIFECYCLE_TESTS
enum { slot_size = 16384, allocation_size = 32768 };
static const uint64_t code_ipa = UINT64_C(0x10000000);
static const uint64_t doorbell_offset = 0x50;
static const uint64_t rust_doorbell_offset = 0x60;
static const uint64_t h3_checkpoint_offset = 0x50;
static const uint64_t h3_resume_offset = 0x54;
static const uint64_t h3_terminal_offset = 0x7c;
// Baseline Armv8.0 RES1 fields, little endian, M/C/I disabled. The exact value
// and EL1h/DAIF state are read back before entry; there is no guest page table.
static const uint64_t initial_sctlr = UINT64_C(0x30d00800);
// H3 v2 explicitly disables AArch32 SETEND/IT (SED bit 8, ITD bit 7).
// The fixed guest is AArch64-only. Leaving these bits clear read back as
// 0x30d00800 before entry but 0x30d00980 after entry on the live platform.
// Initialize the exact supported state; never mask a checkpoint difference.
// Keep the historical H2/Rust initialization above unchanged.
static const uint64_t h3_initial_sctlr = UINT64_C(0x30d00980);
static const uint64_t initial_cpsr = UINT64_C(0x3c5);
_Static_assert(HV_MEMORY_READ == 1 && HV_MEMORY_WRITE == 2 && HV_MEMORY_EXEC == 4,
               "Capability rights must match the actual Hypervisor ABI");
_Static_assert(HV_EXIT_REASON_EXCEPTION == 1, "Exact terminal exception reason");
_Static_assert(cap_witness_bytes == sizeof(((EPRGuestCapabilityWitness *)0)->bytes),
               "Canonical witness frame bound");

#define LE32_BYTES(v) ((v) & 255), (((v) >> 8) & 255), (((v) >> 16) & 255), (((v) >> 24) & 255)
// Exact __TEXT,__text bytes from Guest/doorbell.S, not a Mach-O guest loader.
static const unsigned char guest_image[] = {
    LE32_BYTES(0xd2880000U), LE32_BYTES(0xf2a20000U),
    LE32_BYTES(0xd2900001U), LE32_BYTES(0xf2a20001U),
    LE32_BYTES(0xd2980003U), LE32_BYTES(0xf2a20003U),
    LE32_BYTES(0xc8dffc04U), LE32_BYTES(0xf100049fU),
    LE32_BYTES(0x540001c1U), LE32_BYTES(0xf9400405U),
    LE32_BYTES(0xf10004bfU), LE32_BYTES(0x54000161U),
    LE32_BYTES(0xf9400806U), LE32_BYTES(0xf9400c07U),
    LE32_BYTES(0x8b0700c6U), LE32_BYTES(0xf9000425U),
    LE32_BYTES(0xf9000826U), LE32_BYTES(0xf9000c3fU),
    LE32_BYTES(0xc89ffc24U), LE32_BYTES(0xd5033f9fU),
    LE32_BYTES(0xb9000064U), LE32_BYTES(0xd43bd5a0U),
    LE32_BYTES(0xd42175a0U)
};
// Exact two-build-matched __TEXT,__text bytes from Guest/cursor-resume.S.
// SHA-256: 3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0.
static const unsigned char h3_guest_image[] = {
    LE32_BYTES(0xd2880000U), LE32_BYTES(0xf2a20000U),
    LE32_BYTES(0xd2900001U), LE32_BYTES(0xf2a20001U),
    LE32_BYTES(0xd2980003U), LE32_BYTES(0xf2a20003U),
    LE32_BYTES(0xc8dffc04U), LE32_BYTES(0xf100049fU),
    LE32_BYTES(0x54000321U), LE32_BYTES(0xf9400405U),
    LE32_BYTES(0xf10004bfU), LE32_BYTES(0x540002c1U),
    LE32_BYTES(0xf9400806U), LE32_BYTES(0xf9400c07U),
    LE32_BYTES(0x8b0700c6U), LE32_BYTES(0xf9000425U),
    LE32_BYTES(0xf9000826U), LE32_BYTES(0xf9000c3fU),
    LE32_BYTES(0xc89ffc24U), LE32_BYTES(0xd5033f9fU),
    LE32_BYTES(0xb9000064U), LE32_BYTES(0xf100a8dfU),
    LE32_BYTES(0x54000161U), LE32_BYTES(0xf9400828U),
    LE32_BYTES(0xf100a91fU), LE32_BYTES(0x54000101U),
    LE32_BYTES(0x91000508U), LE32_BYTES(0xf9000c28U),
    LE32_BYTES(0xd2800044U), LE32_BYTES(0xc89ffc24U),
    LE32_BYTES(0xd5033f9fU), LE32_BYTES(0xb9000064U),
    LE32_BYTES(0xd43bd5a0U), LE32_BYTES(0xd42175a0U)
};
#undef LE32_BYTES
_Static_assert(sizeof(guest_image) == 92, "Fixed guest image size");
_Static_assert(sizeof(h3_guest_image) == 136, "Fixed H3 guest image size");
_Static_assert(sizeof(_Atomic(uint64_t)) == 8, "Queue sequence ABI");

static const unsigned char expected_request[32] = {
    1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
    19,0,0,0,0,0,0,0, 23,0,0,0,0,0,0,0
};
static const unsigned char expected_reply[32] = {
    1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
    42,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
};
static const unsigned char h3_expected_terminal_reply[32] = {
    2,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
    42,0,0,0,0,0,0,0, 43,0,0,0,0,0,0,0
};

enum {
    stage_none, stage_admission, stage_clock, stage_memory, stage_vm_create,
    stage_vm_map, stage_vcpu_create, stage_registers, stage_watchdog,
    stage_run, stage_exit_registers, stage_predicates, stage_snapshot,
    stage_watchdog_join, stage_vcpu_destroy, stage_vm_unmap,
    stage_vm_destroy, stage_host_unmap, stage_cancellation,
    stage_h3_cursor_capture, stage_h3_source_conservation,
    stage_h3_cursor_decode, stage_h3_restore, stage_h3_terminal
};

const char *epr_guest_stage_name(int32_t stage) {
    static const char *const names[] = {
        "none", "self-admission", "clock", "private-memory", "vm-create",
        "vm-map", "vcpu-create", "register-configuration", "watchdog",
        "vcpu-run", "exit-registers", "terminal-predicates", "snapshot-merkle",
        "watchdog-join", "vcpu-destroy", "vm-unmap", "vm-destroy",
        "host-unmap", "cancellation", "h3-cursor-capture",
        "h3-source-conservation", "h3-cursor-decode", "h3-restore",
        "h3-terminal"
    };
    return stage >= 0 && (size_t)stage < sizeof(names) / sizeof(names[0]) ? names[stage] : "unknown";
}

const unsigned char *epr_guest_image_bytes(void) { return guest_image; }
size_t epr_guest_image_size(void) { return sizeof(guest_image); }
uint64_t epr_guest_image_load_address(void) { return code_ipa; }
uint64_t epr_guest_doorbell_instruction_offset(void) { return doorbell_offset; }
const unsigned char *epr_rust_guest_image_bytes(void) { return rust_bootstrap_image; }
size_t epr_rust_guest_image_size(void) { return sizeof(rust_bootstrap_image); }
uint64_t epr_rust_guest_image_load_address(void) { return code_ipa; }
uint64_t epr_rust_guest_doorbell_instruction_offset(void) { return rust_doorbell_offset; }
const unsigned char *epr_guest_h3_image_bytes(void) { return h3_guest_image; }
size_t epr_guest_h3_image_size(void) { return sizeof(h3_guest_image); }
uint64_t epr_guest_h3_image_load_address(void) { return code_ipa; }
uint64_t epr_guest_h3_checkpoint_instruction_offset(void) { return h3_checkpoint_offset; }
uint64_t epr_guest_h3_resume_instruction_offset(void) { return h3_resume_offset; }
uint64_t epr_guest_h3_terminal_instruction_offset(void) { return h3_terminal_offset; }
const unsigned char *epr_rust_guest_memory_contract_bytes(void) { return rust_memory_contract; }
size_t epr_rust_guest_memory_contract_size(void) { return sizeof(rust_memory_contract); }
#endif

struct EPRGuestReservation {
    uint64_t generation;
    uint32_t references;
    bool claimed;
    _Atomic(bool) cancel_requested;
    EPRGuestCapabilityWitness witness;
};
_Static_assert(ATOMIC_BOOL_LOCK_FREE == 2, "UI cancellation intent must be lock-free");

// This mutex serializes publication, cancellation and retirement of the vCPU
// ID. It is never held across hv_vcpu_run. The watchdog owns no VM resource.
static pthread_mutex_t lifetime_lock = PTHREAD_MUTEX_INITIALIZER;
#ifndef EPR_GUEST_LIFECYCLE_TESTS
static pthread_cond_t lifetime_condition = PTHREAD_COND_INITIALIZER;
#endif
static struct {
    bool active, quarantined, vcpu_live, finished, cancel_requested;
    bool cancel_entered, watchdog_fired;
    hv_vcpu_t vcpu;
    uint64_t generation, deadline;
    mach_timebase_info_data_t timebase;
    int32_t cancel_status;
    int32_t watchdog_wait_status;
    void *retained_allocations[4];
    EPRGuestReservation *reservation;
} lifetime;

#ifndef EPR_GUEST_LIFECYCLE_TESTS
static void fail(EPRGuestResult *result, int32_t stage, int32_t error) {
    if (!result->failure_stage) {
        result->failure_stage = stage;
        result->first_error = error ? error : EIO;
    }
}
#endif

// Pointer identity is checked BEFORE dereferencing. Valid callers retain their
// token; a released pointer is never an acceptable API input (including ABA).
static bool reservation_matches_locked(const EPRGuestReservation *reservation) {
    return reservation && lifetime.reservation == reservation &&
        reservation->references && reservation->generation == lifetime.generation;
}

int epr_guest_reservation_copy_capability_witness(EPRGuestReservation *reservation,
                                                 EPRGuestCapabilityWitness *output) {
    if (!output) return EINVAL;
    pthread_mutex_lock(&lifetime_lock);
    int error = !reservation_matches_locked(reservation) ? EINVAL :
        (lifetime.active ? EBUSY : (reservation->witness.byte_count ? 0 : ENODATA));
    if (!error) *output = reservation->witness;
    pthread_mutex_unlock(&lifetime_lock);
    return error;
}

EPRGuestReservation *epr_guest_reserve(int *error) {
    if (!error) return NULL;
    *error = 0;
    EPRGuestReservation *reservation = calloc(1, sizeof(*reservation));
    if (!reservation) { *error = ENOMEM; return NULL; }
    atomic_init(&reservation->cancel_requested, false);
    pthread_mutex_lock(&lifetime_lock);
    if (lifetime.active || lifetime.reservation || lifetime.quarantined || lifetime.generation == UINT64_MAX) {
        *error = lifetime.quarantined ? EPERM :
            (lifetime.generation == UINT64_MAX ? EOVERFLOW : EBUSY);
        pthread_mutex_unlock(&lifetime_lock);
        free(reservation);
        return NULL;
    }
    reservation->generation = ++lifetime.generation;
    reservation->references = 1;
    lifetime.reservation = reservation;
    pthread_mutex_unlock(&lifetime_lock);
    return reservation;
}

int epr_guest_reservation_retain(EPRGuestReservation *reservation) {
    pthread_mutex_lock(&lifetime_lock);
    int error = 0;
    if (!reservation_matches_locked(reservation)) error = EINVAL;
    else if (reservation->references == UINT32_MAX) error = EOVERFLOW;
    else ++reservation->references;
    pthread_mutex_unlock(&lifetime_lock);
    return error;
}

int epr_guest_reservation_release(EPRGuestReservation *reservation) {
    pthread_mutex_lock(&lifetime_lock);
    int error = 0;
    bool destroy = false;
    if (!reservation_matches_locked(reservation)) error = EINVAL;
    else if (reservation->references == 1 && lifetime.active) error = EBUSY;
    else if (--reservation->references == 0) {
        lifetime.reservation = NULL;
        destroy = true;
    }
    pthread_mutex_unlock(&lifetime_lock);
    if (destroy) free(reservation);
    return error;
}

void epr_guest_reservation_request_cancel(EPRGuestReservation *reservation) {
    if (reservation) atomic_store_explicit(&reservation->cancel_requested, true, memory_order_seq_cst);
}

int epr_guest_reservation_is_cancelled(EPRGuestReservation *reservation) {
    return reservation && atomic_load_explicit(&reservation->cancel_requested, memory_order_seq_cst);
}

// Shared by real fixed entry and the no-HV lifecycle tests. A reservation is
// consumed once; its cancellation bit is never reset at native activation.
static int claim_lifetime_locked(EPRGuestReservation *reservation) {
    if (lifetime.quarantined) return EPERM;
    if (lifetime.active) return EBUSY;
    if (reservation) {
        if (!reservation_matches_locked(reservation)) return EINVAL;
        if (reservation->claimed) return EALREADY;
        reservation->claimed = true;
    } else {
        if (lifetime.reservation) return EBUSY;
        if (lifetime.generation == UINT64_MAX) return EOVERFLOW;
        ++lifetime.generation;
    }
    lifetime.active = true;
    lifetime.finished = lifetime.vcpu_live = false;
    lifetime.cancel_requested = epr_guest_reservation_is_cancelled(reservation);
    lifetime.cancel_entered = lifetime.watchdog_fired = false;
    lifetime.cancel_status = INT32_MIN;
    lifetime.watchdog_wait_status = INT32_MIN;
    return 0;
}

static bool cancellation_pending_locked(void) {
    if (epr_guest_reservation_is_cancelled(lifetime.reservation)) lifetime.cancel_requested = true;
    return lifetime.cancel_requested;
}

#ifdef EPR_GUEST_LIFECYCLE_TESTS
// Compile-time substitution only. No Hypervisor call is linked into this test
// translation unit; production has neither this counter nor a call table.
static unsigned test_exit_calls;
static int32_t test_exit_status;
#endif

// lifetime_lock is held. A not-yet-running vCPU receives the SDK's sticky exit
// request. A request before vCPU publication prevents the later run entirely.
static void cancel_locked(void) {
    lifetime.cancel_requested = true;
    epr_guest_reservation_request_cancel(lifetime.reservation);
    if (lifetime.vcpu_live && !lifetime.finished && !lifetime.cancel_entered) {
        lifetime.cancel_entered = true;
#ifdef EPR_GUEST_LIFECYCLE_TESTS
        ++test_exit_calls;
        lifetime.cancel_status = test_exit_status;
#else
        lifetime.cancel_status = (int32_t)hv_vcpus_exit(&lifetime.vcpu, 1);
#endif
    }
}

int epr_guest_reservation_cancel(EPRGuestReservation *reservation) {
    // Publish intent even if another kernel delivery currently owns the mutex.
    // The asynchronous caller retains the token while either operation waits.
    epr_guest_reservation_request_cancel(reservation);
    pthread_mutex_lock(&lifetime_lock);
    int accepted = reservation_matches_locked(reservation) &&
        (!reservation->claimed || (lifetime.active && !lifetime.finished));
    if (accepted && lifetime.active) cancel_locked();
    pthread_mutex_unlock(&lifetime_lock);
    return accepted;
}

int epr_guest_cancel(void) {
    pthread_mutex_lock(&lifetime_lock);
    // A legacy unscoped request may never cancel an app-owned reservation.
    int accepted = !lifetime.reservation && lifetime.active && !lifetime.finished;
    if (accepted) cancel_locked();
    pthread_mutex_unlock(&lifetime_lock);
    return accepted;
}

#ifndef EPR_GUEST_LIFECYCLE_TESTS
static void *watchdog_main(void *unused) {
    (void)unused;
    pthread_mutex_lock(&lifetime_lock);
    const uint64_t generation = lifetime.generation;
    while (lifetime.active && !lifetime.finished && lifetime.generation == generation) {
        uint64_t now = mach_absolute_time();
        if (now >= lifetime.deadline) {
            lifetime.watchdog_fired = true;
            cancel_locked();
            break;
        }
        __uint128_t ns = (__uint128_t)(lifetime.deadline - now) * lifetime.timebase.numer;
        ns = (ns + lifetime.timebase.denom - 1) / lifetime.timebase.denom;
        struct timespec interval = { .tv_sec = (time_t)(ns / 1000000000), .tv_nsec = (long)(ns % 1000000000) };
        int status = pthread_cond_timedwait_relative_np(&lifetime_condition, &lifetime_lock, &interval);
        lifetime.watchdog_wait_status = status;
        if (status && status != ETIMEDOUT) {
            // A broken timer still asks the vCPU to return. It does not invent
            // timeout evidence or release the owning thread's resources.
            cancel_locked();
            break;
        }
    }
    pthread_mutex_unlock(&lifetime_lock);
    return NULL;
}

static bool zero_tail(const unsigned char *bytes, size_t start) {
    unsigned char combined = 0;
    for (size_t i = start; i < slot_size; ++i) combined |= bytes[i];
    return combined == 0;
}

static void append_be(unsigned char *dst, uint64_t value, size_t width) {
    for (size_t i = 0; i < width; ++i) dst[i] = (unsigned char)(value >> (8 * (width - i - 1)));
}

static bool leaf_hash(const char *label, const unsigned char *payload, size_t count, unsigned char digest[32]) {
    unsigned char frame[512];
    size_t length = strlen(label);
    if (length > 64 || count > 256 || 13 + length + count > sizeof(frame)) return false;
    frame[0] = 0;
    append_be(frame + 1, length, 4);
    memcpy(frame + 5, label, length);
    append_be(frame + 5 + length, count, 8);
    memcpy(frame + 13 + length, payload, count);
    return CC_SHA256(frame, (CC_LONG)(13 + length + count), digest) != NULL;
}

static bool parent_hash(const unsigned char left[32], const unsigned char right[32], unsigned char digest[32]) {
    unsigned char frame[65];
    frame[0] = 1; memcpy(frame + 1, left, 32); memcpy(frame + 33, right, 32);
    return CC_SHA256(frame, sizeof(frame), digest) != NULL;
}

static bool odd_hash(const unsigned char child[32], unsigned char digest[32]) {
    unsigned char frame[33];
    frame[0] = 3; memcpy(frame + 1, child, 32);
    return CC_SHA256(frame, sizeof(frame), digest) != NULL;
}

static bool root_hash(uint64_t count, const unsigned char top[32], unsigned char digest[32]) {
    unsigned char frame[41];
    frame[0] = 2; append_be(frame + 1, count, 8); memcpy(frame + 9, top, 32);
    return CC_SHA256(frame, sizeof(frame), digest) != NULL;
}

enum {
    h3_region_count = 3, h3_gpr_count = 31,
    h3_system_count = 4, h3_phase_count = 2, h3_cursor_version = 2,
    h3_internal_cursor_bytes = 16992, h3_evidence_prefix_bytes = 608
};
static const uint64_t h3_doorbell_ipa = UINT64_C(0x1000c000);
static const uint64_t h3_stack_top = UINT64_C(0x1000bff0);
static const unsigned char h3_internal_magic[8] = { 'E','P','R','C','U','R','0','2' };
static const unsigned char h3_evidence_magic[8] = { 'E','P','R','H','3','E','2',0 };
static const unsigned char h3_checkpoint_schema[] = "ergentics.hypervisor.guest.h3.checkpoint.v2";
static const unsigned char h3_terminal_schema[] = "ergentics.hypervisor.guest.h3.terminal.v2";
static const EPRCapRegion h3_regions[h3_region_count] = {
    {1, UINT64_C(0x10000000), slot_size, 5},
    {2, UINT64_C(0x10004000), slot_size, 1},
    {3, UINT64_C(0x10008000), slot_size, 3}
};
_Static_assert(EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES == 680, "Fixed H3 evidence width");
_Static_assert(EPR_GUEST_H3_CP_REQUIRED_MASK == UINT32_C(0x1ff),
               "Fixed H3 checkpoint predicate mask");
_Static_assert(offsetof(EPRGuestH3PageMismatchWitness, first_mismatch_offset) == 0 &&
               offsetof(EPRGuestH3PageMismatchWitness, observed_byte) == 4 &&
               offsetof(EPRGuestH3PageMismatchWitness, expected_byte) == 5 &&
               offsetof(EPRGuestH3PageMismatchWitness, reserved_zero) == 6 &&
               sizeof(EPRGuestH3PageMismatchWitness) == 8,
               "Fixed H3 page mismatch witness ABI");
_Static_assert(offsetof(EPRGuestH3CheckpointDiagnostic, schema_version) == 0 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, required_mask) == 4 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, evaluated_mask) == 8 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, passed_mask) == 12 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, gpr_mismatch_mask) == 16 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, reserved_zero) == 20 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, checkpoint_sequence) == 24 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, gprs) == 32 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, cpsr) == 280 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, sctlr) == 288 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, sp) == 296 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, vbar) == 304 &&
               offsetof(EPRGuestH3CheckpointDiagnostic, page_witnesses) == 312 &&
               sizeof(EPRGuestH3CheckpointDiagnostic) == 336,
               "Fixed H3 checkpoint diagnostic ABI");
_Static_assert(sizeof(((EPRGuestH3CheckpointDiagnostic *)0)->gprs) == 31 * sizeof(uint64_t) &&
               sizeof(((EPRGuestH3CheckpointDiagnostic *)0)->page_witnesses) ==
                   EPR_GUEST_H3_CP_PAGE_COUNT * sizeof(EPRGuestH3PageMismatchWitness),
               "Fixed H3 checkpoint diagnostic arrays");
_Static_assert(offsetof(EPRGuestH3CursorResumeResult, checkpoint_diagnostic) == 1296 &&
               offsetof(EPRGuestH3CursorResumeResult, sctlr_transition_diagnostic) == 1632,
               "H3 ABI-v4 appends diagnostics without moving its ABI-v3 prefix");
_Static_assert(EPR_GUEST_H3_SCTLR_REQUIRED_MASK == UINT32_C(0x7),
               "Fixed H3 SCTLR transition sample mask");
_Static_assert(offsetof(EPRGuestH3SCTLRTransitionDiagnostic, schema_version) == 0 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, sampled_mask) == 4 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                        source_pre_entry_read_entries) == 8 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                        source_post_exit_read_entries) == 12 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                        source_pre_entry_read_status) == 16 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic,
                        source_post_exit_read_status) == 20 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, reserved_zero_0) == 24 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, reserved_zero_1) == 28 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, requested) == 32 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, source_pre_entry) == 40 &&
               offsetof(EPRGuestH3SCTLRTransitionDiagnostic, source_post_exit) == 48 &&
               sizeof(EPRGuestH3SCTLRTransitionDiagnostic) == 56 &&
               sizeof(EPRGuestH3CursorResumeResult) == 1688,
               "H3 ABI-v5 appends SCTLR diagnostics without moving its ABI-v4 prefix");
_Static_assert(8 + 16 * 8 + h3_gpr_count * 8 + h3_system_count * 8 +
               h3_region_count * 4 * 8 + h3_region_count * 32 ==
               h3_evidence_prefix_bytes, "Fixed H3 canonical prefix width");
_Static_assert(h3_evidence_prefix_bytes + 32 + 8 + 32 ==
               EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES, "Fixed H3 projection framing");
_Static_assert(h3_internal_cursor_bytes == h3_evidence_prefix_bytes + slot_size,
               "H3 internal cursor is prefix plus full checkpoint page");

typedef struct {
    bool vm_created, vcpu_created, mapped[h3_region_count];
    void *allocations[h3_region_count];
    unsigned char *pages[h3_region_count];
    hv_vcpu_t vcpu;
    hv_vcpu_exit_t *exit_info;
} EPRH3Owner;

typedef struct {
    uint64_t source_generation, target_generation;
    uint64_t gprs[h3_gpr_count];
    uint64_t cpsr, sctlr, sp, vbar;
    unsigned char page_hashes[h3_region_count][32];
    unsigned char checkpoint_page[slot_size];
} EPRH3DecodedCursor;

typedef struct {
    uint64_t reservation_generation, deadline;
    bool completed;
} EPRH3Watchdog;

/* A failed pthread_join cannot leave a worker referring to returned stack
 * storage. Successful runs fully join before either slot is reused; a failed
 * join quarantines the shared lifetime permanently while these slots persist. */
static EPRH3Watchdog h3_watchdog_slots[h3_phase_count];

static void h3_fail(EPRGuestH3CursorResumeResult *result, int32_t stage, int32_t error) {
    if (!result->failure_stage) {
        result->failure_stage = stage;
        result->first_error = error ? error : EIO;
    }
}

static void h3_phase_empty(EPRGuestH3PhaseResult *phase) {
    memset(phase, 0, sizeof(*phase));
    phase->exception_reason = UINT64_MAX;
    phase->vm_create_status = phase->vcpu_create_status = INT32_MIN;
    phase->register_status = phase->run_status = phase->read_register_status = INT32_MIN;
    phase->vcpu_destroy_status = phase->vm_destroy_status = INT32_MIN;
    for (size_t i = 0; i < h3_region_count; ++i) {
        phase->map_status[i] = phase->unmap_status[i] = phase->host_unmap_status[i] = INT32_MIN;
    }
}

static EPRGuestH3CursorResumeResult h3_empty_result(void) {
    EPRGuestH3CursorResumeResult result = {0};
    result.abi_version = 5;
    result.signing_error = result.cancellation_status = INT32_MIN;
    result.watchdog_create_status = result.watchdog_join_status = result.watchdog_wait_status = INT32_MIN;
    result.checkpoint_diagnostic.schema_version = 1;
    result.checkpoint_diagnostic.required_mask = EPR_GUEST_H3_CP_REQUIRED_MASK;
    for (size_t i = 0; i < EPR_GUEST_H3_CP_PAGE_COUNT; ++i)
        result.checkpoint_diagnostic.page_witnesses[i].first_mismatch_offset = UINT32_MAX;
    h3_phase_empty(&result.source); h3_phase_empty(&result.target);
    return result;
}

static bool h3_page_hash(const unsigned char *page, unsigned char digest[32]) {
    return CC_SHA256(page, slot_size, digest) != NULL;
}

static bool h3_fixed_page_hash(size_t index, unsigned char digest[32]) {
    unsigned char page[slot_size] = {0};
    if (index == 0) memcpy(page, h3_guest_image, sizeof(h3_guest_image));
    else if (index == 1) memcpy(page, expected_request, sizeof(expected_request));
    else return false;
    return h3_page_hash(page, digest);
}

static bool h3_checkpoint_root(const unsigned char cursor_digest[32],
                               const unsigned char reply[32], unsigned char root[32]) {
    unsigned char leaves[5][32], level1[3][32], level2[2][32], top[32];
    if (!leaf_hash("cursor_digest", cursor_digest, 32, leaves[0]) ||
        !leaf_hash("guest_image", h3_guest_image, sizeof(h3_guest_image), leaves[1]) ||
        !leaf_hash("reply", reply, 32, leaves[2]) ||
        !leaf_hash("request", expected_request, sizeof(expected_request), leaves[3]) ||
        !leaf_hash("schema", h3_checkpoint_schema, sizeof(h3_checkpoint_schema) - 1, leaves[4]) ||
        !parent_hash(leaves[0], leaves[1], level1[0]) ||
        !parent_hash(leaves[2], leaves[3], level1[1]) || !odd_hash(leaves[4], level1[2]) ||
        !parent_hash(level1[0], level1[1], level2[0]) || !odd_hash(level1[2], level2[1]) ||
        !parent_hash(level2[0], level2[1], top)) return false;
    return root_hash(5, top, root);
}

static bool h3_terminal_root(const unsigned char checkpoint_reply[32],
                             const unsigned char cursor_digest[32],
                             const unsigned char final_reply[32], unsigned char root[32]) {
    unsigned char leaves[6][32], parents[3][32], level2[2][32], top[32];
    if (!leaf_hash("checkpoint_reply", checkpoint_reply, 32, leaves[0]) ||
        !leaf_hash("cursor_digest", cursor_digest, 32, leaves[1]) ||
        !leaf_hash("final_reply", final_reply, 32, leaves[2]) ||
        !leaf_hash("guest_image", h3_guest_image, sizeof(h3_guest_image), leaves[3]) ||
        !leaf_hash("request", expected_request, sizeof(expected_request), leaves[4]) ||
        !leaf_hash("schema", h3_terminal_schema, sizeof(h3_terminal_schema) - 1, leaves[5])) return false;
    for (size_t i = 0; i < 3; ++i)
        if (!parent_hash(leaves[2 * i], leaves[2 * i + 1], parents[i])) return false;
    if (!parent_hash(parents[0], parents[1], level2[0]) ||
        !odd_hash(parents[2], level2[1]) ||
        !parent_hash(level2[0], level2[1], top)) return false;
    return root_hash(6, top, root);
}

static bool h3_put_word(unsigned char *frame, size_t capacity,
                        size_t *offset, uint64_t value) {
    if (*offset > capacity - 8) return false;
    append_be(frame + *offset, value, 8); *offset += 8; return true;
}

static bool h3_take_word(const unsigned char *frame, size_t capacity,
                         size_t *offset, uint64_t *value) {
    if (!value || *offset > capacity - 8) return false;
    uint64_t word = 0;
    for (size_t i = 0; i < 8; ++i) word = (word << 8) | frame[*offset + i];
    *offset += 8; *value = word; return true;
}

static void h3_header(uint64_t source_generation, uint64_t target_generation,
                      uint64_t words[16]) {
    const uint64_t fixed[16] = {
        h3_cursor_version, source_generation, target_generation, h3_phase_count,
        h3_region_count, h3_gpr_count, h3_system_count, sizeof(h3_guest_image),
        slot_size, h3_checkpoint_offset, h3_resume_offset, h3_terminal_offset,
        h3_doorbell_ipa, 4, 1, 2
    };
    memcpy(words, fixed, sizeof(fixed));
}

static bool h3_encode_internal_cursor(EPRGuestH3CursorResumeResult *result,
                             unsigned char frame[h3_internal_cursor_bytes],
                             uint64_t source_generation, uint64_t target_generation,
                             const uint64_t gprs[h3_gpr_count], uint64_t cpsr,
                             uint64_t sctlr, uint64_t sp, uint64_t vbar,
                             unsigned char *const pages[h3_region_count]) {
    unsigned char hashes[h3_region_count][32];
    memset(frame, 0, h3_internal_cursor_bytes);
    for (size_t i = 0; i < h3_region_count; ++i)
        if (!h3_page_hash(pages[i], hashes[i])) return false;
    memcpy(frame, h3_internal_magic, sizeof(h3_internal_magic));
    size_t offset = sizeof(h3_internal_magic);
    uint64_t header[16]; h3_header(source_generation, target_generation, header);
    for (size_t i = 0; i < 16; ++i)
        if (!h3_put_word(frame, h3_internal_cursor_bytes, &offset, header[i])) return false;
    for (size_t i = 0; i < h3_gpr_count; ++i)
        if (!h3_put_word(frame, h3_internal_cursor_bytes, &offset, gprs[i])) return false;
    const uint64_t systems[] = { cpsr, sctlr, sp, vbar };
    for (size_t i = 0; i < h3_system_count; ++i)
        if (!h3_put_word(frame, h3_internal_cursor_bytes, &offset, systems[i])) return false;
    for (size_t i = 0; i < h3_region_count; ++i) {
        const uint64_t fields[] = { h3_regions[i].object, h3_regions[i].ipa,
            h3_regions[i].length, h3_regions[i].rights };
        for (size_t j = 0; j < 4; ++j)
            if (!h3_put_word(frame, h3_internal_cursor_bytes, &offset, fields[j])) return false;
    }
    for (size_t i = 0; i < h3_region_count; ++i) {
        memcpy(frame + offset, hashes[i], 32); offset += 32;
    }
    if (offset != h3_evidence_prefix_bytes) return false;
    memcpy(frame + offset, pages[2], slot_size); offset += slot_size;
    memcpy(result->checkpoint_reply, pages[2], sizeof(result->checkpoint_reply));
    if (offset != h3_internal_cursor_bytes ||
        !CC_SHA256(frame, h3_internal_cursor_bytes, result->cursor_sha256) ||
        !h3_checkpoint_root(result->cursor_sha256, result->checkpoint_reply,
                            result->checkpoint_merkle)) return false;
    result->cursor_sealed = 1;
    return true;
}

static uint64_t h3_expected_checkpoint_gpr(size_t index) {
    if (index == 0) return h3_regions[1].ipa;
    if (index == 1) return h3_regions[2].ipa;
    if (index == 3) return h3_doorbell_ipa;
    if (index == 4 || index == 5) return 1;
    if (index == 6) return 42;
    if (index == 7) return 23;
    return 0;
}

static bool h3_exact_checkpoint_gprs(const uint64_t gprs[h3_gpr_count]) {
    for (size_t i = 0; i < h3_gpr_count; ++i)
        if (gprs[i] != h3_expected_checkpoint_gpr(i)) return false;
    return true;
}

static bool h3_decode_internal_cursor(const unsigned char frame[h3_internal_cursor_bytes],
                             const unsigned char expected_sha[32],
                             uint64_t source_generation, uint64_t target_generation,
                             EPRH3DecodedCursor *decoded) {
    if (!frame || !decoded) return false;
    unsigned char actual_sha[32], expected_hashes[2][32];
    if (!CC_SHA256(frame, h3_internal_cursor_bytes, actual_sha) ||
        memcmp(actual_sha, expected_sha, 32) ||
        !h3_fixed_page_hash(0, expected_hashes[0]) ||
        !h3_fixed_page_hash(1, expected_hashes[1])) return false;
    if (memcmp(frame, h3_internal_magic, sizeof(h3_internal_magic))) return false;
    size_t offset = sizeof(h3_internal_magic);
    uint64_t expected_header[16]; h3_header(source_generation, target_generation, expected_header);
    for (size_t i = 0; i < 16; ++i) {
        uint64_t value;
        if (!h3_take_word(frame, h3_internal_cursor_bytes, &offset, &value) ||
            value != expected_header[i]) return false;
    }
    memset(decoded, 0, sizeof(*decoded));
    decoded->source_generation = source_generation;
    decoded->target_generation = target_generation;
    for (size_t i = 0; i < h3_gpr_count; ++i)
        if (!h3_take_word(frame, h3_internal_cursor_bytes, &offset, &decoded->gprs[i])) return false;
    if (!h3_take_word(frame, h3_internal_cursor_bytes, &offset, &decoded->cpsr) ||
        !h3_take_word(frame, h3_internal_cursor_bytes, &offset, &decoded->sctlr) ||
        !h3_take_word(frame, h3_internal_cursor_bytes, &offset, &decoded->sp) ||
        !h3_take_word(frame, h3_internal_cursor_bytes, &offset, &decoded->vbar)) return false;
    for (size_t i = 0; i < h3_region_count; ++i) {
        uint64_t fields[4];
        for (size_t j = 0; j < 4; ++j)
            if (!h3_take_word(frame, h3_internal_cursor_bytes, &offset, &fields[j])) return false;
        if (fields[0] != h3_regions[i].object || fields[1] != h3_regions[i].ipa ||
            fields[2] != h3_regions[i].length || fields[3] != h3_regions[i].rights) return false;
    }
    for (size_t i = 0; i < h3_region_count; ++i) {
        memcpy(decoded->page_hashes[i], frame + offset, 32); offset += 32;
    }
    if (offset != h3_evidence_prefix_bytes) return false;
    memcpy(decoded->checkpoint_page, frame + offset, slot_size); offset += slot_size;
    unsigned char reply_hash[32];
    if (offset != h3_internal_cursor_bytes ||
        memcmp(decoded->page_hashes[0], expected_hashes[0], 32) ||
        memcmp(decoded->page_hashes[1], expected_hashes[1], 32) ||
        !h3_page_hash(decoded->checkpoint_page, reply_hash) ||
        memcmp(decoded->page_hashes[2], reply_hash, 32) ||
        memcmp(decoded->checkpoint_page, expected_reply, sizeof(expected_reply)) ||
        !zero_tail(decoded->checkpoint_page, sizeof(expected_reply)) ||
        !h3_exact_checkpoint_gprs(decoded->gprs) ||
        decoded->cpsr != UINT64_C(0x600003c5) || decoded->sctlr != h3_initial_sctlr ||
        decoded->sp != h3_stack_top || decoded->vbar != 0) return false;
    return true;
}

static bool h3_encode_evidence(EPRGuestH3CursorResumeResult *result,
                               const unsigned char internal[h3_internal_cursor_bytes]) {
    unsigned char *frame = result->cursor_evidence.bytes;
    memset(frame, 0, EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES);
    memcpy(frame, h3_evidence_magic, sizeof(h3_evidence_magic));
    memcpy(frame + 8, internal + 8, h3_evidence_prefix_bytes - 8);
    memcpy(frame + h3_evidence_prefix_bytes, internal + h3_evidence_prefix_bytes,
           sizeof(result->checkpoint_reply));
    size_t offset = h3_evidence_prefix_bytes + sizeof(result->checkpoint_reply);
    if (!h3_put_word(frame, EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES, &offset,
                     slot_size - sizeof(result->checkpoint_reply))) return false;
    memcpy(frame + offset, result->cursor_sha256, 32); offset += 32;
    if (offset != EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES) return false;
    result->cursor_evidence.byte_count = EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES;
    return true;
}

static bool h3_set_reg(EPRGuestH3CursorResumeResult *result,
                       EPRGuestH3PhaseResult *phase, hv_vcpu_t vcpu,
                       hv_reg_t reg, uint64_t value) {
    ++phase->register_set_calls;
    phase->register_status = (int32_t)hv_vcpu_set_reg(vcpu, reg, value);
    if (phase->register_status != HV_SUCCESS) {
        h3_fail(result, stage_registers, phase->register_status); return false;
    }
    return true;
}

static bool h3_set_sys(EPRGuestH3CursorResumeResult *result,
                       EPRGuestH3PhaseResult *phase, hv_vcpu_t vcpu,
                       hv_sys_reg_t reg, uint64_t value) {
    ++phase->register_set_calls;
    phase->register_status = (int32_t)hv_vcpu_set_sys_reg(vcpu, reg, value);
    if (phase->register_status != HV_SUCCESS) {
        h3_fail(result, stage_registers, phase->register_status); return false;
    }
    return true;
}

static bool h3_get_reg(EPRGuestH3CursorResumeResult *result,
                       EPRGuestH3PhaseResult *phase, hv_vcpu_t vcpu,
                       hv_reg_t reg, uint64_t *value) {
    ++phase->register_read_calls;
    phase->read_register_status = (int32_t)hv_vcpu_get_reg(vcpu, reg, value);
    if (phase->read_register_status != HV_SUCCESS) {
        h3_fail(result, stage_exit_registers, phase->read_register_status); return false;
    }
    return true;
}

static bool h3_get_sys(EPRGuestH3CursorResumeResult *result,
                       EPRGuestH3PhaseResult *phase, hv_vcpu_t vcpu,
                       hv_sys_reg_t reg, uint64_t *value) {
    ++phase->register_read_calls;
    phase->read_register_status = (int32_t)hv_vcpu_get_sys_reg(vcpu, reg, value);
    if (phase->read_register_status != HV_SUCCESS) {
        h3_fail(result, stage_exit_registers, phase->read_register_status); return false;
    }
    return true;
}

static bool h3_read_source_pre_entry_sctlr(EPRGuestH3CursorResumeResult *result,
                                           EPRH3Owner *owner) {
    EPRGuestH3SCTLRTransitionDiagnostic *diagnostic =
        &result->sctlr_transition_diagnostic;
    *diagnostic = (EPRGuestH3SCTLRTransitionDiagnostic){
        .schema_version = 1,
        .sampled_mask = EPR_GUEST_H3_SCTLR_REQUESTED,
        .source_pre_entry_read_status = INT32_MIN,
        .source_post_exit_read_status = INT32_MIN,
        .requested = h3_initial_sctlr
    };
    ++diagnostic->source_pre_entry_read_entries;
    diagnostic->source_pre_entry_read_status = (int32_t)hv_vcpu_get_sys_reg(
        owner->vcpu, HV_SYS_REG_SCTLR_EL1, &diagnostic->source_pre_entry);
    if (diagnostic->source_pre_entry_read_status != HV_SUCCESS) {
        h3_fail(result, stage_registers, diagnostic->source_pre_entry_read_status);
        return false;
    }
    diagnostic->sampled_mask |= EPR_GUEST_H3_SCTLR_SOURCE_PRE_ENTRY;
    return true;
}

static bool h3_read_source_post_exit_sctlr(EPRGuestH3CursorResumeResult *result,
                                           EPRGuestH3PhaseResult *phase,
                                           EPRH3Owner *owner, uint64_t *value) {
    EPRGuestH3SCTLRTransitionDiagnostic *diagnostic =
        &result->sctlr_transition_diagnostic;
    ++phase->register_read_calls;
    ++diagnostic->source_post_exit_read_entries;
    diagnostic->source_post_exit_read_status = (int32_t)hv_vcpu_get_sys_reg(
        owner->vcpu, HV_SYS_REG_SCTLR_EL1, value);
    phase->read_register_status = diagnostic->source_post_exit_read_status;
    if (diagnostic->source_post_exit_read_status != HV_SUCCESS) {
        h3_fail(result, stage_exit_registers,
                diagnostic->source_post_exit_read_status);
        return false;
    }
    diagnostic->source_post_exit = *value;
    diagnostic->sampled_mask |= EPR_GUEST_H3_SCTLR_SOURCE_POST_EXIT;
    return true;
}

static bool h3_prepare_owner(EPRGuestH3CursorResumeResult *result, EPRH3Owner *owner,
                             EPRGuestH3PhaseResult *phase, uint64_t generation,
                             const EPRH3DecodedCursor *decoded) {
    phase->generation = generation;
    for (size_t i = 0; i < h3_region_count; ++i) {
        owner->allocations[i] = mmap(NULL, allocation_size, PROT_READ | PROT_WRITE,
            MAP_PRIVATE | MAP_ANON, -1, 0);
        if (owner->allocations[i] == MAP_FAILED) {
            owner->allocations[i] = NULL; h3_fail(result, stage_memory, errno); return false;
        }
        uintptr_t aligned = ((uintptr_t)owner->allocations[i] + slot_size - 1) &
            ~(uintptr_t)(slot_size - 1);
        owner->pages[i] = (unsigned char *)aligned;
        memset(owner->pages[i], 0, slot_size);
    }
    memcpy(owner->pages[0], h3_guest_image, sizeof(h3_guest_image));
    memcpy(owner->pages[1], expected_request, sizeof(expected_request));
    if (decoded) memcpy(owner->pages[2], decoded->checkpoint_page, slot_size);
    sys_icache_invalidate(owner->pages[0], sizeof(h3_guest_image));
    atomic_init((_Atomic(uint64_t) *)owner->pages[1], 1);
    atomic_init((_Atomic(uint64_t) *)owner->pages[2], decoded ? 1 : 0);
    if (!atomic_is_lock_free((_Atomic(uint64_t) *)owner->pages[1]) ||
        !atomic_is_lock_free((_Atomic(uint64_t) *)owner->pages[2])) {
        h3_fail(result, stage_memory, ENOTSUP); return false;
    }
    if (mprotect(owner->pages[0], slot_size, PROT_READ) ||
        mprotect(owner->pages[1], slot_size, PROT_READ)) {
        h3_fail(result, stage_memory, errno); return false;
    }
    phase->vm_create_status = (int32_t)hv_vm_create(NULL);
    if (phase->vm_create_status != HV_SUCCESS) {
        h3_fail(result, stage_vm_create, phase->vm_create_status); return false;
    }
    owner->vm_created = true;
    for (size_t i = 0; i < h3_region_count; ++i) {
        ++phase->mappings_entered;
        phase->map_status[i] = (int32_t)hv_vm_map(owner->pages[i], h3_regions[i].ipa,
            (size_t)h3_regions[i].length, (hv_memory_flags_t)h3_regions[i].rights);
        if (phase->map_status[i] != HV_SUCCESS) {
            h3_fail(result, stage_vm_map, phase->map_status[i]); return false;
        }
        owner->mapped[i] = true;
    }
    phase->vcpu_create_status = (int32_t)hv_vcpu_create(&owner->vcpu, &owner->exit_info, NULL);
    if (phase->vcpu_create_status != HV_SUCCESS) {
        h3_fail(result, stage_vcpu_create, phase->vcpu_create_status); return false;
    }
    owner->vcpu_created = true;
    if (!owner->exit_info) { h3_fail(result, stage_vcpu_create, EFAULT); return false; }
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu = owner->vcpu; lifetime.vcpu_live = true;
    pthread_mutex_unlock(&lifetime_lock);

    for (uint32_t index = 0; index < h3_gpr_count; ++index) {
        uint64_t value = decoded ? decoded->gprs[index] : 0;
        if (!h3_set_reg(result, phase, owner->vcpu, (hv_reg_t)(HV_REG_X0 + index), value)) return false;
    }
    if (!h3_set_reg(result, phase, owner->vcpu, HV_REG_PC,
                    decoded ? code_ipa + h3_resume_offset : code_ipa) ||
        !h3_set_reg(result, phase, owner->vcpu, HV_REG_CPSR,
                    decoded ? decoded->cpsr : initial_cpsr) ||
        !h3_set_sys(result, phase, owner->vcpu, HV_SYS_REG_SCTLR_EL1,
                    decoded ? decoded->sctlr : h3_initial_sctlr) ||
        !h3_set_sys(result, phase, owner->vcpu, HV_SYS_REG_SP_EL1,
                    decoded ? decoded->sp : h3_stack_top) ||
        !h3_set_sys(result, phase, owner->vcpu, HV_SYS_REG_VBAR_EL1,
                    decoded ? decoded->vbar : 0)) return false;
    if (decoded) {
        unsigned char hashes[h3_region_count][32];
        for (size_t i = 0; i < h3_region_count; ++i)
            if (!h3_page_hash(owner->pages[i], hashes[i]) ||
                memcmp(hashes[i], decoded->page_hashes[i], 32)) {
                h3_fail(result, stage_h3_restore, EPROTO); return false;
            }
    }
    return true;
}

static bool h3_read_checkpoint_state(EPRGuestH3CursorResumeResult *result,
                          EPRGuestH3PhaseResult *phase, EPRH3Owner *owner,
                          uint64_t gprs[h3_gpr_count], uint64_t *cpsr,
                          uint64_t *sctlr, uint64_t *sp, uint64_t *vbar) {
    if (!h3_read_source_post_exit_sctlr(result, phase, owner, sctlr)) return false;
    for (uint32_t index = 0; index < h3_gpr_count; ++index)
        if (!h3_get_reg(result, phase, owner->vcpu, (hv_reg_t)(HV_REG_X0 + index),
                        &gprs[index])) return false;
    if (!h3_get_reg(result, phase, owner->vcpu, HV_REG_PC, &phase->pc) ||
        !h3_get_reg(result, phase, owner->vcpu, HV_REG_CPSR, cpsr) ||
        !h3_get_sys(result, phase, owner->vcpu, HV_SYS_REG_SP_EL1, sp) ||
        !h3_get_sys(result, phase, owner->vcpu, HV_SYS_REG_VBAR_EL1, vbar)) return false;
    phase->x4 = gprs[4];
    return true;
}

static bool h3_read_terminal_state(EPRGuestH3CursorResumeResult *result,
                                   EPRGuestH3PhaseResult *phase, EPRH3Owner *owner) {
    if (!h3_get_reg(result, phase, owner->vcpu, HV_REG_PC, &phase->pc) ||
        !h3_get_reg(result, phase, owner->vcpu, HV_REG_X4, &phase->x4)) return false;
    return true;
}

static bool h3_verify_restored_state(EPRGuestH3CursorResumeResult *result,
                                     EPRGuestH3PhaseResult *phase, EPRH3Owner *owner,
                                     const EPRH3DecodedCursor *decoded) {
    uint64_t value;
    for (uint32_t index = 0; index < h3_gpr_count; ++index) {
        if (!h3_get_reg(result, phase, owner->vcpu, (hv_reg_t)(HV_REG_X0 + index),
                        &value) || value != decoded->gprs[index]) {
            if (!result->failure_stage) h3_fail(result, stage_h3_restore, EPROTO);
            return false;
        }
    }
    if (!h3_get_reg(result, phase, owner->vcpu, HV_REG_PC, &value) ||
        value != code_ipa + h3_resume_offset) goto mismatch;
    if (!h3_get_reg(result, phase, owner->vcpu, HV_REG_CPSR, &value) ||
        value != decoded->cpsr) goto mismatch;
    if (!h3_get_sys(result, phase, owner->vcpu, HV_SYS_REG_SCTLR_EL1, &value) ||
        value != decoded->sctlr) goto mismatch;
    if (!h3_get_sys(result, phase, owner->vcpu, HV_SYS_REG_SP_EL1, &value) ||
        value != decoded->sp) goto mismatch;
    if (!h3_get_sys(result, phase, owner->vcpu, HV_SYS_REG_VBAR_EL1, &value) ||
        value != decoded->vbar) goto mismatch;
    result->cursor_restored = 1;
    return true;
mismatch:
    if (!result->failure_stage) h3_fail(result, stage_h3_restore, EPROTO);
    return false;
}

static bool h3_trap_valid(const EPRGuestH3PhaseResult *phase,
                          uint64_t expected_pc, uint64_t expected_value) {
    const uint64_t dfsc = phase->syndrome & 63;
    return phase->exception_reason == HV_EXIT_REASON_EXCEPTION &&
        phase->syndrome == (UINT64_C(0x93840040) | dfsc) && dfsc >= 4 && dfsc <= 7 &&
        phase->pc == expected_pc && phase->fault_ipa == h3_doorbell_ipa &&
        phase->fault_virtual_address == h3_doorbell_ipa && phase->x4 == expected_value;
}

static bool h3_run_owner(EPRGuestH3CursorResumeResult *result, EPRH3Owner *owner,
                         EPRGuestH3PhaseResult *phase, bool checkpoint_phase,
                         uint64_t gprs[h3_gpr_count], uint64_t *cpsr,
                         uint64_t *sctlr, uint64_t *sp, uint64_t *vbar) {
    pthread_mutex_lock(&lifetime_lock);
    bool canceled = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled) { h3_fail(result, stage_cancellation, ECANCELED); return false; }
    phase->entry_ticks = mach_absolute_time();
    if (phase->entry_ticks >= lifetime.deadline) {
        h3_fail(result, stage_clock, ETIMEDOUT); return false;
    }
    phase->run_entries = 1;
    phase->run_status = (int32_t)hv_vcpu_run(owner->vcpu);
    phase->exit_ticks = mach_absolute_time();
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu_live = false;
    pthread_cond_broadcast(&lifetime_condition);
    pthread_mutex_unlock(&lifetime_lock);
    if (phase->run_status != HV_SUCCESS) {
        h3_fail(result, stage_run, phase->run_status); return false;
    }
    phase->exception_reason = owner->exit_info->reason;
    if (owner->exit_info->reason == HV_EXIT_REASON_EXCEPTION) {
        phase->syndrome = owner->exit_info->exception.syndrome;
        phase->fault_ipa = owner->exit_info->exception.physical_address;
        phase->fault_virtual_address = owner->exit_info->exception.virtual_address;
    }
    if (checkpoint_phase) {
        if (!h3_read_checkpoint_state(result, phase, owner, gprs, cpsr, sctlr, sp, vbar)) return false;
    } else if (!h3_read_terminal_state(result, phase, owner)) return false;
    if (phase->exit_ticks > lifetime.deadline) {
        h3_fail(result, stage_clock, ETIMEDOUT); return false;
    }
    return true;
}

static void *h3_watchdog_main(void *opaque) {
    EPRH3Watchdog *watchdog = opaque;
    pthread_mutex_lock(&lifetime_lock);
    while (lifetime.active && lifetime.generation == watchdog->reservation_generation &&
           !watchdog->completed) {
        uint64_t now = mach_absolute_time();
        if (now >= watchdog->deadline) {
            lifetime.watchdog_fired = true;
            cancel_locked();
            break;
        }
        __uint128_t ns = (__uint128_t)(watchdog->deadline - now) * lifetime.timebase.numer;
        ns = (ns + lifetime.timebase.denom - 1) / lifetime.timebase.denom;
        struct timespec interval = {
            .tv_sec = (time_t)(ns / 1000000000),
            .tv_nsec = (long)(ns % 1000000000)
        };
        int status = pthread_cond_timedwait_relative_np(&lifetime_condition,
                                                        &lifetime_lock, &interval);
        lifetime.watchdog_wait_status = status;
        if (status && status != ETIMEDOUT) {
            cancel_locked();
            break;
        }
    }
    pthread_mutex_unlock(&lifetime_lock);
    return NULL;
}

static bool h3_start_watchdog(EPRGuestH3CursorResumeResult *result,
                              EPRH3Watchdog *watchdog, pthread_t *thread,
                              uint64_t reservation_generation,
                              mach_timebase_info_data_t timebase) {
    uint64_t now = mach_absolute_time();
    __uint128_t duration = ((__uint128_t)2000000000 * timebase.denom +
                            timebase.numer - 1) / timebase.numer;
    if (!duration || duration > UINT64_MAX - now) {
        h3_fail(result, stage_clock, EOVERFLOW); return false;
    }
    *watchdog = (EPRH3Watchdog){
        .reservation_generation = reservation_generation,
        .deadline = now + (uint64_t)duration,
        .completed = false
    };
    pthread_mutex_lock(&lifetime_lock);
    lifetime.deadline = watchdog->deadline;
    lifetime.timebase = timebase;
    pthread_mutex_unlock(&lifetime_lock);
    ++result->watchdog_create_entries;
    result->watchdog_create_status = pthread_create(thread, NULL, h3_watchdog_main, watchdog);
    if (result->watchdog_create_status) {
        h3_fail(result, stage_watchdog, result->watchdog_create_status); return false;
    }
    return true;
}

static bool h3_finish_watchdog(EPRGuestH3CursorResumeResult *result,
                               EPRH3Watchdog *watchdog, pthread_t thread) {
    pthread_mutex_lock(&lifetime_lock);
    watchdog->completed = true;
    pthread_cond_broadcast(&lifetime_condition);
    pthread_mutex_unlock(&lifetime_lock);
    ++result->watchdog_join_entries;
    result->watchdog_join_status = pthread_join(thread, NULL);
    if (result->watchdog_join_status) {
        h3_fail(result, stage_watchdog_join, result->watchdog_join_status); return false;
    }
    return true;
}

static bool h3_conserve_owner(EPRGuestH3CursorResumeResult *result, EPRH3Owner *owner,
                              EPRGuestH3PhaseResult *phase) {
    bool clean = true;
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu_live = false;
    if (owner->vcpu_created) {
        phase->vcpu_destroy_status = (int32_t)hv_vcpu_destroy(owner->vcpu);
        if (phase->vcpu_destroy_status == HV_SUCCESS) owner->vcpu_created = false;
        else { h3_fail(result, stage_vcpu_destroy, phase->vcpu_destroy_status); clean = false; }
    }
    pthread_mutex_unlock(&lifetime_lock);
    if (!owner->vcpu_created) {
        for (size_t i = 0; i < h3_region_count; ++i) if (owner->mapped[i]) {
            phase->unmap_status[i] = (int32_t)hv_vm_unmap(h3_regions[i].ipa,
                                                          (size_t)h3_regions[i].length);
            if (phase->unmap_status[i] == HV_SUCCESS) owner->mapped[i] = false;
            else { h3_fail(result, stage_vm_unmap, phase->unmap_status[i]); clean = false; }
        }
        if (owner->vm_created) {
            phase->vm_destroy_status = (int32_t)hv_vm_destroy();
            if (phase->vm_destroy_status == HV_SUCCESS) {
                owner->vm_created = false;
                for (size_t i = 0; i < h3_region_count; ++i) owner->mapped[i] = false;
            } else { h3_fail(result, stage_vm_destroy, phase->vm_destroy_status); clean = false; }
        }
    }
    bool kernel_conserved = !owner->vcpu_created && !owner->vm_created;
    for (size_t i = 0; i < h3_region_count; ++i) kernel_conserved &= !owner->mapped[i];
    if (kernel_conserved) {
        for (size_t i = 0; i < h3_region_count; ++i) if (owner->allocations[i]) {
            phase->host_unmap_status[i] = munmap(owner->allocations[i], allocation_size);
            if (phase->host_unmap_status[i] == 0) {
                owner->allocations[i] = NULL; owner->pages[i] = NULL;
            } else { h3_fail(result, stage_host_unmap, errno); clean = false; }
        }
    }
    bool host_conserved = true;
    for (size_t i = 0; i < h3_region_count; ++i) host_conserved &= owner->allocations[i] == NULL;
    phase->conserved = clean && kernel_conserved && host_conserved;
    return phase->conserved == 1;
}

static bool h3_exact_page(const unsigned char *page,
                          const unsigned char *prefix, size_t prefix_size) {
    return !memcmp(page, prefix, prefix_size) && zero_tail(page, prefix_size);
}

static bool h3_checkpoint_page_witness(
    const unsigned char page[slot_size], const unsigned char *prefix,
    size_t prefix_size, EPRGuestH3PageMismatchWitness *witness) {
    *witness = (EPRGuestH3PageMismatchWitness){
        .first_mismatch_offset = UINT32_MAX
    };
    for (size_t offset = 0; offset < slot_size; ++offset) {
        unsigned char expected = offset < prefix_size ? prefix[offset] : 0;
        if (page[offset] != expected) {
            witness->first_mismatch_offset = (uint32_t)offset;
            witness->observed_byte = page[offset];
            witness->expected_byte = expected;
            return false;
        }
    }
    return true;
}

static void h3_capture_checkpoint_diagnostic(
    EPRGuestH3CursorResumeResult *result, unsigned char *const pages[h3_region_count],
    const uint64_t gprs[h3_gpr_count], uint64_t cpsr, uint64_t sctlr,
    uint64_t sp, uint64_t vbar) {
    EPRGuestH3CheckpointDiagnostic *diagnostic = &result->checkpoint_diagnostic;
    uint32_t passed = 0, gpr_mismatches = 0;

    diagnostic->checkpoint_sequence = atomic_load_explicit(
        (_Atomic(uint64_t) *)pages[EPR_GUEST_H3_CP_PAGE_REPLY], memory_order_acquire);
    if (diagnostic->checkpoint_sequence == 1) passed |= EPR_GUEST_H3_CP_SEQUENCE;

    if (h3_checkpoint_page_witness(pages[EPR_GUEST_H3_CP_PAGE_CODE],
            h3_guest_image, sizeof(h3_guest_image),
            &diagnostic->page_witnesses[EPR_GUEST_H3_CP_PAGE_CODE]))
        passed |= EPR_GUEST_H3_CP_CODE_PAGE;
    if (h3_checkpoint_page_witness(pages[EPR_GUEST_H3_CP_PAGE_REQUEST],
            expected_request, sizeof(expected_request),
            &diagnostic->page_witnesses[EPR_GUEST_H3_CP_PAGE_REQUEST]))
        passed |= EPR_GUEST_H3_CP_REQUEST_PAGE;
    if (h3_checkpoint_page_witness(pages[EPR_GUEST_H3_CP_PAGE_REPLY],
            expected_reply, sizeof(expected_reply),
            &diagnostic->page_witnesses[EPR_GUEST_H3_CP_PAGE_REPLY]))
        passed |= EPR_GUEST_H3_CP_REPLY_PAGE;

    for (size_t i = 0; i < h3_gpr_count; ++i) {
        diagnostic->gprs[i] = gprs[i];
        if (gprs[i] != h3_expected_checkpoint_gpr(i))
            gpr_mismatches |= UINT32_C(1) << i;
    }
    diagnostic->gpr_mismatch_mask = gpr_mismatches;
    if (!gpr_mismatches) passed |= EPR_GUEST_H3_CP_GPRS;

    diagnostic->cpsr = cpsr;
    if (cpsr == UINT64_C(0x600003c5)) passed |= EPR_GUEST_H3_CP_CPSR;
    diagnostic->sctlr = sctlr;
    if (sctlr == h3_initial_sctlr) passed |= EPR_GUEST_H3_CP_SCTLR;
    diagnostic->sp = sp;
    if (sp == h3_stack_top) passed |= EPR_GUEST_H3_CP_SP;
    diagnostic->vbar = vbar;
    if (!vbar) passed |= EPR_GUEST_H3_CP_VBAR;

    diagnostic->passed_mask = passed;
    diagnostic->evaluated_mask = EPR_GUEST_H3_CP_REQUIRED_MASK;
}

static bool seal_snapshot(EPRGuestResult *result) {
    static const unsigned char schema[] = "ergentics.hypervisor.guest.snapshot.v1";
    unsigned char leaves[4][32], parents[2][32], top[32], frame[41];
    if (!leaf_hash("guest_image", guest_image, sizeof(guest_image), leaves[0]) ||
        !leaf_hash("reply", result->reply, sizeof(result->reply), leaves[1]) ||
        !leaf_hash("request", result->request, sizeof(result->request), leaves[2]) ||
        !leaf_hash("schema", schema, sizeof(schema) - 1, leaves[3]) ||
        !parent_hash(leaves[0], leaves[1], parents[0]) ||
        !parent_hash(leaves[2], leaves[3], parents[1]) ||
        !parent_hash(parents[0], parents[1], top)) return false;
    frame[0] = 2; append_be(frame + 1, 4, 8); memcpy(frame + 9, top, 32);
    if (!CC_SHA256(frame, sizeof(frame), result->snapshot_merkle)) return false;
    result->snapshot_ticks = mach_absolute_time();
    result->snapshot_sealed = 1;
    return true;
}

static bool seal_rust_snapshot(EPRGuestResult *result, const EPRRustGuestResult *rust,
                               const unsigned char memory_contract[128]) {
    static const unsigned char schema[] = "ergentics.hypervisor.rust-bootstrap.snapshot.v1";
    unsigned char leaves[6][32], parents[3][32], next[2][32], top[32], odd[33], frame[41];
    if (!leaf_hash("guest_image", rust_bootstrap_image, sizeof(rust_bootstrap_image), leaves[0]) ||
        !leaf_hash("memory_contract", memory_contract, 128, leaves[1]) ||
        !leaf_hash("reply", result->reply, sizeof(result->reply), leaves[2]) ||
        !leaf_hash("request", result->request, sizeof(result->request), leaves[3]) ||
        !leaf_hash("schema", schema, sizeof(schema) - 1, leaves[4]) ||
        !leaf_hash("stack_frame", rust->stack_frame, sizeof(rust->stack_frame), leaves[5])) return false;
    for (size_t i = 0; i < 3; ++i)
        if (!parent_hash(leaves[2 * i], leaves[2 * i + 1], parents[i])) return false;
    if (!parent_hash(parents[0], parents[1], next[0])) return false;
    // Six leaves become three parents: commit the unpaired parent with the
    // same 0x03 domain as the independent Swift Merkle implementation.
    odd[0] = 3; memcpy(odd + 1, parents[2], 32);
    if (!CC_SHA256(odd, sizeof(odd), next[1]) || !parent_hash(next[0], next[1], top)) return false;
    frame[0] = 2; append_be(frame + 1, 6, 8); memcpy(frame + 9, top, 32);
    if (!CC_SHA256(frame, sizeof(frame), result->snapshot_merkle)) return false;
    result->snapshot_ticks = mach_absolute_time();
    result->snapshot_sealed = 1;
    return true;
}

static EPRGuestResult empty_result(void) {
    EPRGuestResult r = {0};
    r.abi_version = 1;
    r.exception_reason = UINT32_MAX;
    r.vm_create_status = r.vcpu_create_status = r.register_status = r.run_status = INT32_MIN;
    r.read_register_status = r.vcpu_destroy_status = r.vm_destroy_status = INT32_MIN;
    r.cancellation_status = r.watchdog_create_status = r.watchdog_join_status = INT32_MIN;
    r.watchdog_wait_status = INT32_MIN;
    for (size_t i = 0; i < 3; ++i) r.map_status[i] = r.unmap_status[i] = r.host_unmap_status[i] = INT32_MIN;
    return r;
}

// Only the two zero-argument wrappers below select these fixed in-image
// profiles. Both use this single lifetime owner; no runtime policy is exposed.
static EPRGuestResult run_fixed_guest(bool rust_bootstrap, EPRRustGuestResult *rust,
                                     EPRGuestReservation *reservation) {
    EPRGuestResult result = empty_result();
    result.abi_version = rust_bootstrap ? 2 : 1;
    const unsigned char *image = rust_bootstrap ? rust_bootstrap_image : guest_image;
    const size_t image_size = rust_bootstrap ? sizeof(rust_bootstrap_image) : sizeof(guest_image);
    pthread_mutex_lock(&lifetime_lock);
    int claim_error = claim_lifetime_locked(reservation);
    if (claim_error) {
        result.outcome = lifetime.quarantined ? EPR_GUEST_QUARANTINED : EPR_GUEST_BUSY;
        result.resources_quarantined = lifetime.quarantined;
        if (claim_error != EBUSY && !lifetime.quarantined) {
            result.outcome = EPR_GUEST_FAILED;
            fail(&result, stage_admission, claim_error);
        }
        pthread_mutex_unlock(&lifetime_lock);
        return result;
    }
    const uint64_t generation = lifetime.generation;
    pthread_mutex_unlock(&lifetime_lock);
    const EPRCapPlan plan = cap_fixed_plan(rust_bootstrap ? 2 : 1, generation);
    const size_t page_count = (size_t)plan.count;
    EPRCapTrace trace = cap_empty_trace();
    bool plan_admitted = false;
    unsigned char image_digest[32] = {0}, mapped_memory_contract[128] = {0};
    bool vm_created = false, vcpu_created = false, watchdog_created = false;
    bool mapped[4] = {false, false, false, false};
    void *allocations[4] = {NULL, NULL, NULL, NULL};
    unsigned char *pages[4] = {NULL, NULL, NULL, NULL};
    hv_vcpu_t vcpu = 0;
    hv_vcpu_exit_t *exit_info = NULL;
    pthread_t watchdog;
    mach_timebase_info_data_t timebase = {0};
    result.start_ticks = mach_absolute_time();

    if (pthread_main_np()) { fail(&result, stage_admission, EINVAL); goto finish; }
    plan_admitted = cap_plan_valid(&plan, generation);
    if (!plan_admitted || !CC_SHA256(image, (CC_LONG)image_size, image_digest)) {
        fail(&result, stage_admission, EINVAL); goto finish;
    }

    pthread_mutex_lock(&lifetime_lock);
    bool canceled_before_setup = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled_before_setup) { fail(&result, stage_cancellation, ECANCELED); goto finish; }

    int signing_error = 0;
    result.signing_admitted = epr_admit_signing("ZCQ435U8JP", &signing_error) == 1;
    result.signing_error = signing_error;
    if (!result.signing_admitted) { fail(&result, stage_admission, signing_error ? signing_error : EACCES); goto finish; }
    if (mach_timebase_info(&timebase) != KERN_SUCCESS || !timebase.numer || !timebase.denom) {
        fail(&result, stage_clock, EINVAL); goto finish;
    }
    result.timebase_numer = timebase.numer; result.timebase_denom = timebase.denom;
    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0 || page_size > slot_size || slot_size % page_size) { fail(&result, stage_memory, EINVAL); goto finish; }

    for (size_t i = 0; i < page_count; ++i) {
        allocations[i] = mmap(NULL, allocation_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
        if (allocations[i] == MAP_FAILED) { allocations[i] = NULL; fail(&result, stage_memory, errno); goto finish; }
        uintptr_t aligned = ((uintptr_t)allocations[i] + slot_size - 1) & ~(uintptr_t)(slot_size - 1);
        pages[i] = (unsigned char *)aligned;
        memset(pages[i], 0, slot_size);
    }
    memcpy(pages[0], image, image_size);
    sys_icache_invalidate(pages[0], image_size);
    memcpy(pages[1], expected_request, sizeof(expected_request));
    atomic_init((_Atomic(uint64_t) *)pages[1], 0);
    atomic_init((_Atomic(uint64_t) *)pages[2], 0);
    if (!atomic_is_lock_free((_Atomic(uint64_t) *)pages[1]) || !atomic_is_lock_free((_Atomic(uint64_t) *)pages[2])) {
        fail(&result, stage_memory, ENOTSUP); goto finish;
    }
    atomic_store_explicit((_Atomic(uint64_t) *)pages[1], 1, memory_order_release);
    // Guest execute permission does not require host executable memory. The
    // host code/request pages become read-only before they are guest-mapped.
    if (mprotect(pages[0], slot_size, PROT_READ) || mprotect(pages[1], slot_size, PROT_READ)) {
        fail(&result, stage_memory, errno); goto finish;
    }
    result.vm_create_status = (int32_t)hv_vm_create(NULL);
    if (result.vm_create_status != HV_SUCCESS) { fail(&result, stage_vm_create, result.vm_create_status); goto finish; }
    vm_created = true;
    for (size_t i = 0; i < page_count; ++i) {
        if (!cap_map_enter(&plan, &trace, generation, i)) {
            fail(&result, stage_vm_map, EPROTO); goto finish;
        }
        ++result.mappings_entered;
        int32_t *status = i < 3 ? &result.map_status[i] : &rust->stack_map_status;
        const EPRCapRegion arguments = trace.maps[i].arguments;
        *status = (int32_t)hv_vm_map(pages[i], arguments.ipa, (size_t)arguments.length,
                                    (hv_memory_flags_t)arguments.rights);
        cap_map_return(&trace, i, *status);
        if (*status != HV_SUCCESS) { fail(&result, stage_vm_map, *status); goto finish; }
        mapped[i] = true;
    }
    if (!cap_maps_joined(&plan, &trace, generation) || (rust_bootstrap &&
        (!cap_rust_memory_contract(&plan, &trace, generation, mapped_memory_contract) ||
         memcmp(mapped_memory_contract, rust_memory_contract, sizeof(mapped_memory_contract))))) {
        fail(&result, stage_vm_map, EPROTO); goto finish;
    }
    result.vcpu_create_status = (int32_t)hv_vcpu_create(&vcpu, &exit_info, NULL);
    if (result.vcpu_create_status != HV_SUCCESS) { fail(&result, stage_vcpu_create, result.vcpu_create_status); goto finish; }
    vcpu_created = true; result.vcpu_created = 1;
    pthread_mutex_lock(&lifetime_lock);
    lifetime.vcpu = vcpu; lifetime.vcpu_live = true;
    pthread_mutex_unlock(&lifetime_lock);
    if (!exit_info) { fail(&result, stage_vcpu_create, EFAULT); goto finish; }

#define SET_REGISTER(reg, value) do { \
    ++result.register_calls; result.register_status = (int32_t)hv_vcpu_set_reg(vcpu, (reg), (value)); \
    if (result.register_status != HV_SUCCESS) { fail(&result, stage_registers, result.register_status); goto finish; } \
} while (0)
#define SET_SYSTEM(reg, value) do { \
    ++result.register_calls; result.register_status = (int32_t)hv_vcpu_set_sys_reg(vcpu, (reg), (value)); \
    if (result.register_status != HV_SUCCESS) { fail(&result, stage_registers, result.register_status); goto finish; } \
} while (0)
    for (uint32_t reg = HV_REG_X0; reg <= HV_REG_X30; ++reg) SET_REGISTER((hv_reg_t)reg, 0);
    SET_REGISTER(HV_REG_PC, plan.regions[0].ipa);
    SET_REGISTER(HV_REG_CPSR, initial_cpsr);
    SET_SYSTEM(HV_SYS_REG_SCTLR_EL1, initial_sctlr);
    SET_SYSTEM(HV_SYS_REG_SP_EL1, plan.stack_top);
    SET_SYSTEM(HV_SYS_REG_VBAR_EL1, 0);
#undef SET_REGISTER
#undef SET_SYSTEM
    ++result.read_register_calls;
    result.read_register_status = (int32_t)hv_vcpu_get_sys_reg(vcpu, HV_SYS_REG_SCTLR_EL1, &result.sctlr_el1);
    if (result.read_register_status != HV_SUCCESS) { fail(&result, stage_registers, result.read_register_status); goto finish; }
    ++result.read_register_calls;
    result.read_register_status = (int32_t)hv_vcpu_get_reg(vcpu, HV_REG_CPSR, &result.cpsr);
    if (result.read_register_status != HV_SUCCESS) { fail(&result, stage_registers, result.read_register_status); goto finish; }
    if (result.sctlr_el1 != initial_sctlr || result.cpsr != initial_cpsr) { fail(&result, stage_registers, EINVAL); goto finish; }
    if (rust_bootstrap) {
        ++result.read_register_calls;
        rust->entry_sp_status = (int32_t)hv_vcpu_get_sys_reg(vcpu, HV_SYS_REG_SP_EL1, &rust->entry_sp);
        if (rust->entry_sp_status != HV_SUCCESS) { fail(&result, stage_registers, rust->entry_sp_status); goto finish; }
        if (rust->entry_sp != plan.stack_top) { fail(&result, stage_registers, EINVAL); goto finish; }
    }

    uint64_t now = mach_absolute_time();
    __uint128_t duration = ((__uint128_t)2000000000 * timebase.denom + timebase.numer - 1) / timebase.numer;
    if (!duration || duration > UINT64_MAX - now) { fail(&result, stage_clock, EOVERFLOW); goto finish; }
    result.deadline_ticks = now + (uint64_t)duration;
    pthread_mutex_lock(&lifetime_lock);
    lifetime.deadline = result.deadline_ticks; lifetime.timebase = timebase;
    pthread_mutex_unlock(&lifetime_lock);
    result.watchdog_create_status = pthread_create(&watchdog, NULL, watchdog_main, NULL);
    if (result.watchdog_create_status) { fail(&result, stage_watchdog, result.watchdog_create_status); goto finish; }
    watchdog_created = true;
    pthread_mutex_lock(&lifetime_lock);
    // This load is the native-entry commitment cut: a token request ordered
    // before it prevents entry. A later request uses the SDK's sticky exit on
    // the published vCPU, including the short interval before hv_vcpu_run.
    bool canceled = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled) { fail(&result, stage_cancellation, ECANCELED); goto finish; }
    result.entry_ticks = mach_absolute_time();
    if (result.entry_ticks >= result.deadline_ticks) { fail(&result, stage_clock, ETIMEDOUT); goto finish; }
    if (!cap_run_enter(&plan, &trace, generation)) { fail(&result, stage_run, EPROTO); goto finish; }
    result.run_entries = trace.run_entered;
    result.run_status = (int32_t)hv_vcpu_run(vcpu);
    result.exit_ticks = mach_absolute_time();
    // No second entry can occur. Remove cancellation eligibility before the
    // stable copy; destruction still belongs exclusively to this owner thread.
    pthread_mutex_lock(&lifetime_lock);
    lifetime.finished = true;
    pthread_cond_broadcast(&lifetime_condition);
    pthread_mutex_unlock(&lifetime_lock);

    if (result.run_status == HV_SUCCESS) {
        result.exception_reason = exit_info->reason;
        if (exit_info->reason == HV_EXIT_REASON_EXCEPTION) {
            result.syndrome = exit_info->exception.syndrome;
            result.fault_ipa = exit_info->exception.physical_address;
            result.fault_virtual_address = exit_info->exception.virtual_address;
        }
    } else fail(&result, stage_run, result.run_status);
    ++result.read_register_calls;
    result.read_register_status = (int32_t)hv_vcpu_get_reg(vcpu, HV_REG_PC, &result.pc);
    if (result.read_register_status != HV_SUCCESS) fail(&result, stage_exit_registers, result.read_register_status);
    else {
        ++result.read_register_calls;
        result.read_register_status = (int32_t)hv_vcpu_get_reg(vcpu, HV_REG_X4, &result.x4);
        if (result.read_register_status != HV_SUCCESS) fail(&result, stage_exit_registers, result.read_register_status);
    }
    if (rust_bootstrap) {
        ++result.read_register_calls;
        rust->exit_sp_status = (int32_t)hv_vcpu_get_sys_reg(vcpu, HV_SYS_REG_SP_EL1, &rust->exit_sp);
        if (rust->exit_sp_status != HV_SUCCESS) fail(&result, stage_exit_registers, rust->exit_sp_status);
    }
    // Platform ABI: one coherent shared physical page, aligned atomic sequence,
    // guest STLR + DSB, host acquire. A VM exit alone is not an acquire fence.
    // No guest or host writer can run while these once-only copies are made.
    uint64_t reply_sequence = atomic_load_explicit((_Atomic(uint64_t) *)pages[2], memory_order_acquire);
    memcpy(result.request, pages[1], sizeof(result.request));
    memcpy(result.reply, pages[2], sizeof(result.reply));
    result.request_unchanged = !memcmp(pages[1], expected_request, 32) && zero_tail(pages[1], 32);
    result.reply_valid = reply_sequence == 1 && !memcmp(pages[2], expected_reply, 32) && zero_tail(pages[2], 32);
    result.code_unchanged = !memcmp(pages[0], image, image_size) && zero_tail(pages[0], image_size);
    if (rust_bootstrap) {
        const size_t frame_start = slot_size - sizeof(rust->stack_frame);
        memcpy(rust->stack_frame, pages[3] + frame_start, sizeof(rust->stack_frame));
        unsigned char prefix = 0;
        for (size_t i = 0; i < frame_start; ++i) prefix |= pages[3][i];
        rust->stack_valid = !prefix &&
            !memcmp(rust->stack_frame, rust_expected_stack_frame, sizeof(rust->stack_frame)) &&
            rust->entry_sp_status == HV_SUCCESS && rust->exit_sp_status == HV_SUCCESS &&
            rust->entry_sp == plan.stack_top && rust->exit_sp == plan.stack_top;
    }
    // EC=data abort from lower EL, IL=1, ISV=1, SAS=32-bit, SRT=4,
    // unsigned W4 store, WnR=1; only translation-fault level may vary (0..3).
    result.trap_valid = cap_terminal(&plan, &trace, generation, result.exception_reason,
        result.syndrome, result.pc, result.fault_ipa, result.fault_virtual_address, result.x4);
    if (!(rust_bootstrap ? seal_rust_snapshot(&result, rust, mapped_memory_contract) : seal_snapshot(&result)))
        fail(&result, stage_snapshot, EIO);
    if (!result.request_unchanged || !result.reply_valid || !result.code_unchanged || !result.trap_valid ||
        (rust_bootstrap && !rust->stack_valid)) {
        fail(&result, stage_predicates, EPROTO);
    }
    if (result.exit_ticks > result.deadline_ticks) fail(&result, stage_clock, ETIMEDOUT);
    result.execution_pass = !result.failure_stage;

finish:
    pthread_mutex_lock(&lifetime_lock);
    lifetime.finished = true;
    pthread_cond_broadcast(&lifetime_condition);
    pthread_mutex_unlock(&lifetime_lock);
    if (watchdog_created) {
        result.watchdog_join_status = pthread_join(watchdog, NULL);
        if (result.watchdog_join_status) fail(&result, stage_watchdog_join, result.watchdog_join_status);
    }
    pthread_mutex_lock(&lifetime_lock);
    result.cancellation_requested = lifetime.cancel_requested;
    result.cancellation_calls = lifetime.cancel_entered;
    result.cancellation_status = lifetime.cancel_status;
    result.watchdog_fired = lifetime.watchdog_fired;
    result.watchdog_wait_status = lifetime.watchdog_wait_status;
    if (result.cancellation_requested) {
        result.execution_pass = 0;
        fail(&result, stage_cancellation, ECANCELED);
    }
    // Same mutex as hv_vcpus_exit excludes an in-flight cancellation call from
    // destruction, including an already-returned vCPU ID about to be retired.
    if (vcpu_created) {
        result.vcpu_destroy_status = (int32_t)hv_vcpu_destroy(vcpu);
        if (result.vcpu_destroy_status == HV_SUCCESS) { vcpu_created = false; lifetime.vcpu_live = false; }
        else fail(&result, stage_vcpu_destroy, result.vcpu_destroy_status);
    }
    pthread_mutex_unlock(&lifetime_lock);
    if (!vcpu_created) {
        for (size_t i = 0; i < page_count; ++i) if (mapped[i]) {
            int32_t *status = i < 3 ? &result.unmap_status[i] : &rust->stack_unmap_status;
            trace.maps[i].unmap_entered = 1;
            *status = (int32_t)hv_vm_unmap(trace.maps[i].arguments.ipa,
                                          (size_t)trace.maps[i].arguments.length);
            trace.maps[i].unmap_status = *status;
            trace.maps[i].unmap_returned = 1;
            if (*status == HV_SUCCESS) mapped[i] = false;
            else fail(&result, stage_vm_unmap, *status);
        }
        if (vm_created) {
            result.vm_destroy_status = (int32_t)hv_vm_destroy();
            if (result.vm_destroy_status == HV_SUCCESS) {
                vm_created = false;
                for (size_t i = 0; i < page_count; ++i) mapped[i] = false;
            } else fail(&result, stage_vm_destroy, result.vm_destroy_status);
        }
    }
    bool conserved = !vm_created && !vcpu_created && (!watchdog_created || result.watchdog_join_status == 0);
    if (conserved) {
        for (size_t i = 0; i < page_count; ++i) if (allocations[i]) {
            int32_t *status = i < 3 ? &result.host_unmap_status[i] : &rust->stack_host_unmap_status;
            *status = munmap(allocations[i], allocation_size);
            if (*status == 0) allocations[i] = NULL;
            else { fail(&result, stage_host_unmap, errno); conserved = false; }
        }
    }
    pthread_mutex_lock(&lifetime_lock);
    if (!conserved) {
        lifetime.quarantined = true;
        for (size_t i = 0; i < page_count; ++i) lifetime.retained_allocations[i] = allocations[i];
        result.resources_quarantined = 1;
    }
    if (reservation) {
        cap_encode_witness(&plan, &trace, image_digest, image_size, plan_admitted,
                           conserved, reservation->witness.bytes);
        reservation->witness.byte_count = cap_witness_bytes;
    }
    lifetime.active = false;
    pthread_mutex_unlock(&lifetime_lock);
    result.teardown_pass = conserved;
    result.end_ticks = mach_absolute_time();
    if (result.execution_pass && result.teardown_pass && !result.failure_stage) result.outcome = EPR_GUEST_PASS;
    else if (result.cancellation_requested) result.outcome = EPR_GUEST_CANCELED;
    else result.outcome = EPR_GUEST_FAILED;
    return result;
}

static EPRGuestH3CursorResumeResult
run_h3_cursor_resume(EPRGuestReservation *reservation) {
    EPRGuestH3CursorResumeResult result = h3_empty_result();
    EPRH3Owner source = {0}, target = {0};
    EPRH3DecodedCursor decoded = {0};
    EPRH3Watchdog *source_watchdog = &h3_watchdog_slots[0];
    EPRH3Watchdog *target_watchdog = &h3_watchdog_slots[1];
    pthread_t source_watchdog_thread = 0, target_watchdog_thread = 0;
    mach_timebase_info_data_t timebase = {0};
    unsigned char internal_cursor[h3_internal_cursor_bytes] = {0};
    uint64_t source_gprs[h3_gpr_count] = {0};
    uint64_t source_cpsr = 0, source_sctlr = 0, source_sp = 0, source_vbar = 0;
    uint64_t reservation_generation = 0, source_generation = 0, target_generation = 0;
    bool source_attempted = false, target_attempted = false;
    bool source_cleanup_done = false, target_cleanup_done = false;
    bool watchdogs_conserved = true;

    pthread_mutex_lock(&lifetime_lock);
    int claim_error = claim_lifetime_locked(reservation);
    if (claim_error) {
        result.outcome = lifetime.quarantined ? EPR_GUEST_QUARANTINED : EPR_GUEST_BUSY;
        result.resources_quarantined = lifetime.quarantined;
        if (claim_error != EBUSY && !lifetime.quarantined) {
            result.outcome = EPR_GUEST_FAILED;
            h3_fail(&result, stage_admission, claim_error);
        }
        pthread_mutex_unlock(&lifetime_lock);
        return result;
    }
    reservation_generation = lifetime.generation;
    pthread_mutex_unlock(&lifetime_lock);
    result.start_ticks = mach_absolute_time();

    if (pthread_main_np() || reservation_generation > UINT64_MAX / 2) {
        h3_fail(&result, stage_admission,
                pthread_main_np() ? EINVAL : EOVERFLOW);
        goto finish;
    }
    source_generation = reservation_generation * 2 - 1;
    target_generation = source_generation + 1;
    result.source.generation = source_generation;
    result.target.generation = target_generation;

    pthread_mutex_lock(&lifetime_lock);
    bool canceled_before_setup = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled_before_setup) {
        h3_fail(&result, stage_cancellation, ECANCELED); goto finish;
    }

    int signing_error = 0;
    result.signing_admitted = epr_admit_signing("ZCQ435U8JP", &signing_error) == 1;
    result.signing_error = signing_error;
    if (!result.signing_admitted) {
        h3_fail(&result, stage_admission, signing_error ? signing_error : EACCES);
        goto finish;
    }
    if (mach_timebase_info(&timebase) != KERN_SUCCESS ||
        !timebase.numer || !timebase.denom) {
        h3_fail(&result, stage_clock, EINVAL); goto finish;
    }
    result.timebase_numer = timebase.numer;
    result.timebase_denom = timebase.denom;
    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0 || page_size > slot_size || slot_size % page_size) {
        h3_fail(&result, stage_memory, EINVAL); goto finish;
    }

    /* Phase A owns a complete VM/vCPU lifetime. Its checkpoint is sealed
     * before any source resource is retired. */
    source_attempted = true;
    if (!h3_prepare_owner(&result, &source, &result.source,
                          source_generation, NULL)) goto finish;
    if (!h3_read_source_pre_entry_sctlr(&result, &source)) goto finish;
    if (!h3_start_watchdog(&result, source_watchdog,
                           &source_watchdog_thread, reservation_generation,
                           timebase)) goto finish;
    bool source_run_ok = h3_run_owner(&result, &source, &result.source, true,
                                      source_gprs, &source_cpsr, &source_sctlr,
                                      &source_sp, &source_vbar);
    bool source_watchdog_ok = h3_finish_watchdog(&result, source_watchdog,
                                                 source_watchdog_thread);
    watchdogs_conserved &= source_watchdog_ok;
    if (!source_run_ok || !source_watchdog_ok) goto finish;

    if (!h3_trap_valid(&result.source, code_ipa + h3_checkpoint_offset, 1)) {
        h3_fail(&result, stage_predicates, EPROTO); goto finish;
    }
    h3_capture_checkpoint_diagnostic(&result, source.pages, source_gprs,
                                     source_cpsr, source_sctlr, source_sp, source_vbar);
    if (result.checkpoint_diagnostic.evaluated_mask != EPR_GUEST_H3_CP_REQUIRED_MASK ||
        result.checkpoint_diagnostic.passed_mask != EPR_GUEST_H3_CP_REQUIRED_MASK ||
        result.source.register_set_calls != 36 ||
        result.source.register_read_calls != 36) {
        h3_fail(&result, stage_predicates, EPROTO); goto finish;
    }
    result.checkpoint_valid = 1;
    if (!h3_encode_internal_cursor(&result, internal_cursor,
                                   source_generation, target_generation,
                                   source_gprs, source_cpsr, source_sctlr,
                                   source_sp, source_vbar, source.pages) ||
        !h3_encode_evidence(&result, internal_cursor)) {
        h3_fail(&result, stage_h3_cursor_capture, EIO); goto finish;
    }

    /* No source register copy survives into the decoder. The canonical
     * internal cursor is the only dynamic Phase-A to Phase-B channel. */
    memset(source_gprs, 0, sizeof(source_gprs));
    source_cpsr = source_sctlr = source_sp = source_vbar = 0;
    source_cleanup_done = true;
    result.source_conserved = h3_conserve_owner(&result, &source, &result.source);
    if (!result.source_conserved) {
        h3_fail(&result, stage_h3_source_conservation, EBUSY); goto finish;
    }

    pthread_mutex_lock(&lifetime_lock);
    bool canceled_before_decode = cancellation_pending_locked();
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled_before_decode) {
        h3_fail(&result, stage_cancellation, ECANCELED); goto finish;
    }
    if (!h3_decode_internal_cursor(internal_cursor, result.cursor_sha256,
                                   source_generation, target_generation,
                                   &decoded)) {
        h3_fail(&result, stage_h3_cursor_decode, EPROTO); goto finish;
    }
    result.cursor_decoded = 1;
    memset(internal_cursor, 0, sizeof(internal_cursor));

    /* Phase B is a fresh owner. It reconstructs only from the decoded
     * internal cursor and fixed in-image constants; the 680-byte evidence is
     * observation-only and is never imported. */
    target_attempted = true;
    if (!h3_prepare_owner(&result, &target, &result.target,
                          target_generation, &decoded) ||
        !h3_verify_restored_state(&result, &result.target, &target, &decoded)) {
        goto finish;
    }
    memset(&decoded, 0, sizeof(decoded));
    if (!h3_start_watchdog(&result, target_watchdog,
                           &target_watchdog_thread, reservation_generation,
                           timebase)) goto finish;
    bool target_run_ok = h3_run_owner(&result, &target, &result.target, false,
                                      NULL, NULL, NULL, NULL, NULL);
    bool target_watchdog_ok = h3_finish_watchdog(&result, target_watchdog,
                                                 target_watchdog_thread);
    watchdogs_conserved &= target_watchdog_ok;
    if (!target_run_ok || !target_watchdog_ok) goto finish;

    uint64_t terminal_sequence = atomic_load_explicit(
        (_Atomic(uint64_t) *)target.pages[2], memory_order_acquire);
    memcpy(result.final_reply, target.pages[2], sizeof(result.final_reply));
    if (!h3_trap_valid(&result.target, code_ipa + h3_terminal_offset, 2) ||
        terminal_sequence != 2 ||
        !h3_exact_page(target.pages[0], h3_guest_image, sizeof(h3_guest_image)) ||
        !h3_exact_page(target.pages[1], expected_request, sizeof(expected_request)) ||
        !h3_exact_page(target.pages[2], h3_expected_terminal_reply,
                       sizeof(h3_expected_terminal_reply)) ||
        result.target.register_set_calls != 36 ||
        result.target.register_read_calls != 38 ||
        !h3_terminal_root(result.checkpoint_reply, result.cursor_sha256,
                          result.final_reply, result.terminal_merkle)) {
        h3_fail(&result, stage_h3_terminal, EPROTO); goto finish;
    }
    result.terminal_valid = 1;
    result.execution_pass = 1;

finish:
    memset(internal_cursor, 0, sizeof(internal_cursor));
    memset(&decoded, 0, sizeof(decoded));
    memset(source_gprs, 0, sizeof(source_gprs));
    source_cpsr = source_sctlr = source_sp = source_vbar = 0;

    pthread_mutex_lock(&lifetime_lock);
    lifetime.finished = true;
    pthread_cond_broadcast(&lifetime_condition);
    result.cancellation_requested = lifetime.cancel_requested;
    result.cancellation_calls = lifetime.cancel_entered;
    result.cancellation_status = lifetime.cancel_status;
    result.watchdog_fired = lifetime.watchdog_fired;
    result.watchdog_wait_status = lifetime.watchdog_wait_status;
    pthread_mutex_unlock(&lifetime_lock);
    if (result.cancellation_requested) {
        result.execution_pass = 0;
        h3_fail(&result, stage_cancellation, ECANCELED);
    }

    if (source_attempted && !source_cleanup_done) {
        source_cleanup_done = true;
        result.source_conserved = h3_conserve_owner(&result, &source, &result.source);
    }
    if (target_attempted && !target_cleanup_done) {
        target_cleanup_done = true;
        result.target_conserved = h3_conserve_owner(&result, &target, &result.target);
    }
    bool source_clean = !source_attempted || result.source_conserved;
    bool target_clean = !target_attempted || result.target_conserved;
    bool conserved = source_clean && target_clean && watchdogs_conserved;

    pthread_mutex_lock(&lifetime_lock);
    if (!conserved) {
        lifetime.quarantined = true;
        for (size_t i = 0; i < h3_region_count; ++i) {
            lifetime.retained_allocations[i] = source.allocations[i] ?
                source.allocations[i] : target.allocations[i];
        }
        result.resources_quarantined = 1;
    }
    lifetime.active = false;
    pthread_mutex_unlock(&lifetime_lock);

    result.teardown_pass = conserved;
    result.end_ticks = mach_absolute_time();
    if (result.execution_pass && result.teardown_pass &&
        result.source_conserved && result.target_conserved &&
        result.watchdog_create_entries == 2 && result.watchdog_join_entries == 2 &&
        !result.failure_stage) {
        result.outcome = EPR_GUEST_PASS;
    } else if (result.cancellation_requested) {
        result.outcome = EPR_GUEST_CANCELED;
    } else {
        result.outcome = EPR_GUEST_FAILED;
    }
    return result;
}

EPRGuestResult epr_guest_run(void) {
    return run_fixed_guest(false, NULL, NULL);
}

EPRRustGuestResult epr_rust_guest_run(void) {
    EPRRustGuestResult rust = {0};
    rust.stack_map_status = rust.stack_unmap_status = rust.stack_host_unmap_status = INT32_MIN;
    rust.entry_sp_status = rust.exit_sp_status = INT32_MIN;
    rust.base = run_fixed_guest(true, &rust, NULL);
    return rust;
}

EPRGuestResult epr_guest_run_reserved(EPRGuestReservation *reservation) {
    if (!reservation) {
        EPRGuestResult result = empty_result();
        result.outcome = EPR_GUEST_FAILED;
        fail(&result, stage_admission, EINVAL);
        return result;
    }
    return run_fixed_guest(false, NULL, reservation);
}

EPRRustGuestResult epr_rust_guest_run_reserved(EPRGuestReservation *reservation) {
    EPRRustGuestResult rust = {0};
    rust.stack_map_status = rust.stack_unmap_status = rust.stack_host_unmap_status = INT32_MIN;
    rust.entry_sp_status = rust.exit_sp_status = INT32_MIN;
    if (!reservation) {
        rust.base = empty_result();
        rust.base.abi_version = 2;
        rust.base.outcome = EPR_GUEST_FAILED;
        fail(&rust.base, stage_admission, EINVAL);
        return rust;
    }
    rust.base = run_fixed_guest(true, &rust, reservation);
    return rust;
}

EPRGuestH3CursorResumeResult
epr_guest_h3_cursor_resume_run_reserved(EPRGuestReservation *reservation) {
    if (!reservation) {
        EPRGuestH3CursorResumeResult result = h3_empty_result();
        result.outcome = EPR_GUEST_FAILED;
        h3_fail(&result, stage_admission, EINVAL);
        return result;
    }
    return run_h3_cursor_resume(reservation);
}
#endif

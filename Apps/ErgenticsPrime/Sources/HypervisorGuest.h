#ifndef ERGENTICS_HYPERVISOR_GUEST_H
#define ERGENTICS_HYPERVISOR_GUEST_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
    EPR_GUEST_NOT_ENTERED = 0, EPR_GUEST_PASS = 1, EPR_GUEST_FAILED = 2,
    EPR_GUEST_CANCELED = 3, EPR_GUEST_BUSY = 4, EPR_GUEST_QUARANTINED = 5
};

/* Raw HV statuses use INT32_MIN when the corresponding call was not entered.
 * No result here asserts scientific authority, process-group conservation,
 * persistence, acceleration, or Gate-E completion. */
typedef struct {
    uint32_t abi_version;
    uint32_t outcome;
    uint32_t execution_pass;
    uint32_t teardown_pass;
    uint32_t signing_admitted;
    uint32_t run_entries;
    uint32_t vcpu_created;
    uint32_t mappings_entered;
    uint32_t register_calls;
    uint32_t read_register_calls;
    uint32_t cancellation_requested;
    uint32_t cancellation_calls;
    uint32_t watchdog_fired;
    uint32_t resources_quarantined;
    uint32_t request_unchanged;
    uint32_t reply_valid;
    uint32_t code_unchanged;
    uint32_t trap_valid;
    uint32_t snapshot_sealed;
    uint32_t exception_reason;
    uint32_t timebase_numer;
    uint32_t timebase_denom;
    int32_t failure_stage;
    int32_t first_error;
    int32_t signing_error;
    int32_t vm_create_status;
    int32_t map_status[3];
    int32_t vcpu_create_status;
    int32_t register_status;
    int32_t run_status;
    int32_t read_register_status;
    int32_t vcpu_destroy_status;
    int32_t unmap_status[3];
    int32_t vm_destroy_status;
    int32_t cancellation_status;
    int32_t watchdog_create_status;
    int32_t watchdog_join_status;
    int32_t watchdog_wait_status;
    int32_t host_unmap_status[3];
    uint64_t start_ticks;
    uint64_t entry_ticks;
    uint64_t exit_ticks;
    uint64_t end_ticks;
    uint64_t deadline_ticks;
    uint64_t snapshot_ticks;
    uint64_t syndrome;
    uint64_t pc;
    uint64_t fault_ipa;
    uint64_t fault_virtual_address;
    uint64_t x4;
    uint64_t sctlr_el1;
    uint64_t cpsr;
    unsigned char request[32];
    unsigned char reply[32];
    unsigned char snapshot_merkle[32];
} EPRGuestResult;

/* ABI 2 is a distinct wrapper; the legacy ABI 1 structure above is unchanged.
 * stack_valid observes the zero prefix plus the copied 16-byte return frame.
 * The snapshot commits that frame and the memory layout, not all stack bytes. */
typedef struct {
    EPRGuestResult base;
    uint32_t stack_valid;
    int32_t stack_map_status;
    int32_t stack_unmap_status;
    int32_t stack_host_unmap_status;
    int32_t entry_sp_status;
    int32_t exit_sp_status;
    uint64_t entry_sp;
    uint64_t exit_sp;
    unsigned char stack_frame[16];
} EPRRustGuestResult;

/* H3 is a separate fixed in-memory checkpoint/resume ABI. Its two phase
 * records describe distinct derived generations and complete VM/vCPU
 * create-run-destroy intervals under one reservation. The 680-byte evidence
 * is an observation-only projection of a distinct 16,992-byte internal cursor;
 * cursor_sha256 commits that internal A-to-B channel, not the projection.
 * Neither representation can be imported as a capability. INT32_MIN retains
 * the same not-entered meaning as ABI1/2. */
typedef struct {
    uint32_t run_entries;
    uint32_t mappings_entered;
    uint32_t register_set_calls;
    uint32_t register_read_calls;
    uint32_t conserved;
    int32_t vm_create_status;
    int32_t map_status[3];
    int32_t vcpu_create_status;
    int32_t register_status;
    int32_t run_status;
    int32_t read_register_status;
    int32_t vcpu_destroy_status;
    int32_t unmap_status[3];
    int32_t vm_destroy_status;
    int32_t host_unmap_status[3];
    uint64_t generation;
    uint64_t entry_ticks;
    uint64_t exit_ticks;
    uint64_t exception_reason;
    uint64_t syndrome;
    uint64_t pc;
    uint64_t fault_ipa;
    uint64_t fault_virtual_address;
    uint64_t x4;
} EPRGuestH3PhaseResult;

enum { EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES = 680 };
typedef struct {
    uint32_t byte_count;
    unsigned char bytes[EPR_GUEST_H3_CURSOR_EVIDENCE_BYTES];
} EPRGuestH3CursorEvidence;

enum {
    EPR_GUEST_H3_CP_SEQUENCE = 1u << 0,
    EPR_GUEST_H3_CP_CODE_PAGE = 1u << 1,
    EPR_GUEST_H3_CP_REQUEST_PAGE = 1u << 2,
    EPR_GUEST_H3_CP_REPLY_PAGE = 1u << 3,
    EPR_GUEST_H3_CP_GPRS = 1u << 4,
    EPR_GUEST_H3_CP_CPSR = 1u << 5,
    EPR_GUEST_H3_CP_SCTLR = 1u << 6,
    EPR_GUEST_H3_CP_SP = 1u << 7,
    EPR_GUEST_H3_CP_VBAR = 1u << 8,
    EPR_GUEST_H3_CP_REQUIRED_MASK = (1u << 9) - 1,
    EPR_GUEST_H3_CP_PAGE_CODE = 0,
    EPR_GUEST_H3_CP_PAGE_REQUEST = 1,
    EPR_GUEST_H3_CP_PAGE_REPLY = 2,
    EPR_GUEST_H3_CP_PAGE_COUNT = 3
};

/* A page witness is meaningful only when its corresponding evaluated bit is
 * set. UINT32_MAX denotes an evaluated exact page; otherwise the offset is the
 * first differing byte and observed/expected retain that exact mismatch. */
typedef struct {
    uint32_t first_mismatch_offset;
    uint8_t observed_byte;
    uint8_t expected_byte;
    uint16_t reserved_zero;
} EPRGuestH3PageMismatchWitness;

/* ABI-v4 observation of the nine previously unexposed members of the
 * source-checkpoint conjunction. An evaluated mask of zero means this
 * checkpoint was not reached; v1 otherwise evaluates all nine bits. */
typedef struct {
    uint32_t schema_version;
    uint32_t required_mask;
    uint32_t evaluated_mask;
    uint32_t passed_mask;
    uint32_t gpr_mismatch_mask;
    uint32_t reserved_zero;
    uint64_t checkpoint_sequence;
    uint64_t gprs[31];
    uint64_t cpsr;
    uint64_t sctlr;
    uint64_t sp;
    uint64_t vbar;
    EPRGuestH3PageMismatchWitness page_witnesses[EPR_GUEST_H3_CP_PAGE_COUNT];
} EPRGuestH3CheckpointDiagnostic;

enum {
    EPR_GUEST_H3_SCTLR_REQUESTED = 1u << 0,
    EPR_GUEST_H3_SCTLR_SOURCE_PRE_ENTRY = 1u << 1,
    EPR_GUEST_H3_SCTLR_SOURCE_POST_EXIT = 1u << 2,
    EPR_GUEST_H3_SCTLR_REQUIRED_MASK = (1u << 3) - 1
};

/* ABI-v5 source-only observation of the requested SCTLR value, its immediate
 * post-set/pre-entry readback and the existing post-exit checkpoint read. */
typedef struct {
    uint32_t schema_version;
    uint32_t sampled_mask;
    uint32_t source_pre_entry_read_entries;
    uint32_t source_post_exit_read_entries;
    int32_t source_pre_entry_read_status;
    int32_t source_post_exit_read_status;
    uint32_t reserved_zero_0;
    uint32_t reserved_zero_1;
    uint64_t requested;
    uint64_t source_pre_entry;
    uint64_t source_post_exit;
} EPRGuestH3SCTLRTransitionDiagnostic;

typedef struct {
    uint32_t abi_version;
    uint32_t outcome;
    uint32_t execution_pass;
    uint32_t teardown_pass;
    uint32_t signing_admitted;
    uint32_t cursor_sealed;
    uint32_t cursor_decoded;
    uint32_t cursor_restored;
    uint32_t checkpoint_valid;
    uint32_t terminal_valid;
    uint32_t source_conserved;
    uint32_t target_conserved;
    uint32_t cancellation_requested;
    uint32_t cancellation_calls;
    uint32_t watchdog_fired;
    uint32_t watchdog_create_entries;
    uint32_t watchdog_join_entries;
    uint32_t resources_quarantined;
    uint32_t timebase_numer;
    uint32_t timebase_denom;
    int32_t failure_stage;
    int32_t first_error;
    int32_t signing_error;
    int32_t cancellation_status;
    int32_t watchdog_create_status;
    int32_t watchdog_join_status;
    int32_t watchdog_wait_status;
    uint64_t start_ticks;
    uint64_t end_ticks;
    EPRGuestH3PhaseResult source;
    EPRGuestH3PhaseResult target;
    EPRGuestH3CursorEvidence cursor_evidence;
    unsigned char cursor_sha256[32];
    unsigned char checkpoint_reply[32];
    unsigned char final_reply[32];
    unsigned char checkpoint_merkle[32];
    unsigned char terminal_merkle[32];
    EPRGuestH3CheckpointDiagnostic checkpoint_diagnostic;
    EPRGuestH3SCTLRTransitionDiagnostic sctlr_transition_diagnostic;
} EPRGuestH3CursorResumeResult;

/* Synchronous, zero-argument, one fixed request and at most one vCPU entry.
 * Call on a dedicated OS thread, never on the UI actor/thread. All owner-only
 * Hypervisor calls stay on this thread. A private watchdog only requests
 * hv_vcpus_exit; it never signals a process. No finite kernel latency is claimed.
 * A non-conserved teardown permanently prevents another run in this process. */
EPRGuestResult epr_guest_run(void);

/* Closed Rust bootstrap successor, sharing the SAME owner, cancellation and
 * quarantine as the assembly baseline. No path, arguments or runtime policy.
 * Not a high-value trust grant. This entry point has no UI/autostart trigger. */
EPRRustGuestResult epr_rust_guest_run(void);

/* Thread-safe request: 1 accepted for the active invocation; 0 no active run.
 * At most one hv_vcpus_exit call is entered across user and watchdog requests.
 * Acceptance does not mean the vCPU has returned or its resources are released. */
int epr_guest_cancel(void);

/* App-owned run reservation. Reserve BEFORE asynchronous preparation. A retained
 * token owns the shared slot through native return and journal completion;
 * cancellation is sticky before native activation and cannot target a later
 * generation. Existing zero-argument entries cannot bypass a reserved slot.
 *
 * Each concurrent caller must hold a reference for its entire call. A Swift
 * owner retained by every worker/cancellation closure can own one C reference.
 * Never use a pointer after its final release. retain/release return 0 or an
 * errno value; release refuses the last reference during an active native call.
 * No caller-supplied image, request, environment, path, or execution policy. */
typedef struct EPRGuestReservation EPRGuestReservation;
/* Separate observation ABI; existing guest result ABI1/2 is unchanged.
 * Big-endian fixed frame, not an authority token or a serialized C struct. */
typedef struct {
    uint32_t byte_count;
    unsigned char bytes[680];
} EPRGuestCapabilityWitness;
EPRGuestReservation *epr_guest_reserve(int *error);
/* Read-only copy after native return, from the SAME still-retained owner.
 * ENODATA before a witness, EBUSY during native work, EINVAL for wrong owner.
 * There is no import/restore API and no global last-result accessor. */
int epr_guest_reservation_copy_capability_witness(EPRGuestReservation *reservation,
                                                 EPRGuestCapabilityWitness *output);
int epr_guest_reservation_retain(EPRGuestReservation *reservation);
int epr_guest_reservation_release(EPRGuestReservation *reservation);
/* Nonblocking token-local intent: one atomic store, no mutex or Hypervisor call.
 * The caller MUST retain the token across the call. Call synchronously at Stop,
 * then dispatch reservation_cancel off the UI thread for any kernel delivery. */
void epr_guest_reservation_request_cancel(EPRGuestReservation *reservation);
/* 1: cancellation accepted for this reserved/preparing/active generation;
 * 0: already finished or not the current reservation. It is not teardown proof.
 * May wait for the lifetime mutex or kernel; call off the UI thread. */
int epr_guest_reservation_cancel(EPRGuestReservation *reservation);
/* Atomic token snapshot only; requires a retained reference. The reserved entry
 * performs the authoritative owner/generation join and pre-entry check. */
int epr_guest_reservation_is_cancelled(EPRGuestReservation *reservation);
EPRGuestResult epr_guest_run_reserved(EPRGuestReservation *reservation);
EPRRustGuestResult epr_rust_guest_run_reserved(EPRGuestReservation *reservation);
/* One reserved session owns both in-memory phases, two bounded run watchdogs,
 * and sticky cancellation. Phase generations are distinct; the target is the
 * source successor. The full internal cursor is encoded and independently
 * decoded only after complete source conservation. The fixed evidence frame
 * is never the resume input.
 * It has no path, serialized-cursor input, policy, environment or role input.
 * Phase B is unreachable until Phase A has fully conserved. */
EPRGuestH3CursorResumeResult
epr_guest_h3_cursor_resume_run_reserved(EPRGuestReservation *reservation);

/* Immutable image in the signed host. Accessors never create or run a VM. */
const unsigned char *epr_guest_image_bytes(void);
size_t epr_guest_image_size(void);
uint64_t epr_guest_image_load_address(void);
uint64_t epr_guest_doorbell_instruction_offset(void);
const unsigned char *epr_rust_guest_image_bytes(void);
size_t epr_rust_guest_image_size(void);
uint64_t epr_rust_guest_image_load_address(void);
uint64_t epr_rust_guest_doorbell_instruction_offset(void);
const unsigned char *epr_guest_h3_image_bytes(void);
size_t epr_guest_h3_image_size(void);
uint64_t epr_guest_h3_image_load_address(void);
uint64_t epr_guest_h3_checkpoint_instruction_offset(void);
uint64_t epr_guest_h3_resume_instruction_offset(void);
uint64_t epr_guest_h3_terminal_instruction_offset(void);
const unsigned char *epr_rust_guest_memory_contract_bytes(void);
size_t epr_rust_guest_memory_contract_size(void);
const char *epr_guest_stage_name(int32_t stage);

#ifdef __cplusplus
}
#endif
#endif

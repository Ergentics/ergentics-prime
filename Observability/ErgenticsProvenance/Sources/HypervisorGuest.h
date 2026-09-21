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

/* Synchronous, zero-argument, one fixed request and at most one vCPU entry.
 * Call on a dedicated OS thread, never on the UI actor/thread. All owner-only
 * Hypervisor calls stay on this thread. A private watchdog only requests
 * hv_vcpus_exit; it never signals a process. No finite kernel latency is claimed.
 * A non-conserved teardown permanently prevents another run in this process. */
EPRGuestResult epr_guest_run(void);

/* Thread-safe request: 1 accepted for the active invocation; 0 no active run.
 * At most one hv_vcpus_exit call is entered across user and watchdog requests.
 * Acceptance does not mean the vCPU has returned or its resources are released. */
int epr_guest_cancel(void);

/* Immutable image in the signed host. Accessors never create or run a VM. */
const unsigned char *epr_guest_image_bytes(void);
size_t epr_guest_image_size(void);
uint64_t epr_guest_image_load_address(void);
uint64_t epr_guest_doorbell_instruction_offset(void);
const char *epr_guest_stage_name(int32_t stage);

#ifdef __cplusplus
}
#endif
#endif

#include "HypervisorGuest.h"
#include "ProvenanceReadOnly.h"
#include <CommonCrypto/CommonDigest.h>
#include <Hypervisor/Hypervisor.h>
#include <errno.h>
#include <limits.h>
#include <libkern/OSCacheControl.h>
#include <mach/mach_time.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#if !defined(__arm64__) || __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#error This fixed guest requires an arm64 little-endian macOS host.
#endif

enum { slot_size = 16384, allocation_size = 32768 };
static const uint64_t code_ipa = UINT64_C(0x10000000);
static const uint64_t request_ipa = UINT64_C(0x10004000);
static const uint64_t reply_ipa = UINT64_C(0x10008000);
static const uint64_t doorbell_ipa = UINT64_C(0x1000c000);
static const uint64_t doorbell_offset = 0x50;
// Baseline Armv8.0 RES1 fields, little endian, M/C/I disabled. The exact value
// and EL1h/DAIF state are read back before entry; there is no guest page table.
static const uint64_t initial_sctlr = UINT64_C(0x30d00800);
static const uint64_t initial_cpsr = UINT64_C(0x3c5);

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
#undef LE32_BYTES
_Static_assert(sizeof(guest_image) == 92, "Fixed guest image size");
_Static_assert(sizeof(_Atomic(uint64_t)) == 8, "Queue sequence ABI");

static const unsigned char expected_request[32] = {
    1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
    19,0,0,0,0,0,0,0, 23,0,0,0,0,0,0,0
};
static const unsigned char expected_reply[32] = {
    1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
    42,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
};

enum {
    stage_none, stage_admission, stage_clock, stage_memory, stage_vm_create,
    stage_vm_map, stage_vcpu_create, stage_registers, stage_watchdog,
    stage_run, stage_exit_registers, stage_predicates, stage_snapshot,
    stage_watchdog_join, stage_vcpu_destroy, stage_vm_unmap,
    stage_vm_destroy, stage_host_unmap, stage_cancellation
};

const char *epr_guest_stage_name(int32_t stage) {
    static const char *const names[] = {
        "none", "self-admission", "clock", "private-memory", "vm-create",
        "vm-map", "vcpu-create", "register-configuration", "watchdog",
        "vcpu-run", "exit-registers", "terminal-predicates", "snapshot-merkle",
        "watchdog-join", "vcpu-destroy", "vm-unmap", "vm-destroy",
        "host-unmap", "cancellation"
    };
    return stage >= 0 && (size_t)stage < sizeof(names) / sizeof(names[0]) ? names[stage] : "unknown";
}

const unsigned char *epr_guest_image_bytes(void) { return guest_image; }
size_t epr_guest_image_size(void) { return sizeof(guest_image); }
uint64_t epr_guest_image_load_address(void) { return code_ipa; }
uint64_t epr_guest_doorbell_instruction_offset(void) { return doorbell_offset; }

// This mutex serializes publication, cancellation and retirement of the vCPU
// ID. It is never held across hv_vcpu_run. The watchdog owns no VM resource.
static pthread_mutex_t lifetime_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t lifetime_condition = PTHREAD_COND_INITIALIZER;
static struct {
    bool active, quarantined, vcpu_live, finished, cancel_requested;
    bool cancel_entered, watchdog_fired;
    hv_vcpu_t vcpu;
    uint64_t generation, deadline;
    mach_timebase_info_data_t timebase;
    int32_t cancel_status;
    int32_t watchdog_wait_status;
    void *retained_allocations[3];
} lifetime;

static void fail(EPRGuestResult *result, int32_t stage, int32_t error) {
    if (!result->failure_stage) {
        result->failure_stage = stage;
        result->first_error = error ? error : EIO;
    }
}

// lifetime_lock is held. A not-yet-running vCPU receives the SDK's sticky exit
// request. A request before vCPU publication prevents the later run entirely.
static void cancel_locked(void) {
    lifetime.cancel_requested = true;
    if (lifetime.vcpu_live && !lifetime.finished && !lifetime.cancel_entered) {
        lifetime.cancel_entered = true;
        lifetime.cancel_status = (int32_t)hv_vcpus_exit(&lifetime.vcpu, 1);
    }
}

int epr_guest_cancel(void) {
    pthread_mutex_lock(&lifetime_lock);
    int accepted = lifetime.active && !lifetime.finished;
    if (accepted) cancel_locked();
    pthread_mutex_unlock(&lifetime_lock);
    return accepted;
}

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
    unsigned char frame[256];
    size_t length = strlen(label);
    if (length > 64 || count > 128 || 13 + length + count > sizeof(frame)) return false;
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

EPRGuestResult epr_guest_run(void) {
    EPRGuestResult result = empty_result();
    pthread_mutex_lock(&lifetime_lock);
    if (lifetime.active || lifetime.quarantined) {
        result.outcome = lifetime.quarantined ? EPR_GUEST_QUARANTINED : EPR_GUEST_BUSY;
        result.resources_quarantined = lifetime.quarantined;
        pthread_mutex_unlock(&lifetime_lock);
        return result;
    }
    lifetime.active = true;
    lifetime.finished = lifetime.vcpu_live = lifetime.cancel_requested = false;
    lifetime.cancel_entered = lifetime.watchdog_fired = false;
    lifetime.cancel_status = INT32_MIN;
    lifetime.watchdog_wait_status = INT32_MIN;
    ++lifetime.generation;
    pthread_mutex_unlock(&lifetime_lock);

    bool vm_created = false, vcpu_created = false, watchdog_created = false;
    bool mapped[3] = {false, false, false};
    void *allocations[3] = {NULL, NULL, NULL};
    unsigned char *pages[3] = {NULL, NULL, NULL};
    const uint64_t ipas[3] = {code_ipa, request_ipa, reply_ipa};
    const hv_memory_flags_t permissions[3] = {HV_MEMORY_READ | HV_MEMORY_EXEC, HV_MEMORY_READ, HV_MEMORY_READ | HV_MEMORY_WRITE};
    hv_vcpu_t vcpu = 0;
    hv_vcpu_exit_t *exit_info = NULL;
    pthread_t watchdog;
    mach_timebase_info_data_t timebase = {0};
    result.start_ticks = mach_absolute_time();

    if (pthread_main_np()) { fail(&result, stage_admission, EINVAL); goto finish; }

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

    for (size_t i = 0; i < 3; ++i) {
        allocations[i] = mmap(NULL, allocation_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
        if (allocations[i] == MAP_FAILED) { allocations[i] = NULL; fail(&result, stage_memory, errno); goto finish; }
        uintptr_t aligned = ((uintptr_t)allocations[i] + slot_size - 1) & ~(uintptr_t)(slot_size - 1);
        pages[i] = (unsigned char *)aligned;
        memset(pages[i], 0, slot_size);
    }
    memcpy(pages[0], guest_image, sizeof(guest_image));
    sys_icache_invalidate(pages[0], sizeof(guest_image));
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
    for (size_t i = 0; i < 3; ++i) {
        ++result.mappings_entered;
        result.map_status[i] = (int32_t)hv_vm_map(pages[i], ipas[i], slot_size, permissions[i]);
        if (result.map_status[i] != HV_SUCCESS) { fail(&result, stage_vm_map, result.map_status[i]); goto finish; }
        mapped[i] = true;
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
    SET_REGISTER(HV_REG_PC, code_ipa);
    SET_REGISTER(HV_REG_CPSR, initial_cpsr);
    SET_SYSTEM(HV_SYS_REG_SCTLR_EL1, initial_sctlr);
    SET_SYSTEM(HV_SYS_REG_SP_EL1, reply_ipa + slot_size - 16);
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
    bool canceled = lifetime.cancel_requested;
    pthread_mutex_unlock(&lifetime_lock);
    if (canceled) { fail(&result, stage_cancellation, ECANCELED); goto finish; }
    result.entry_ticks = mach_absolute_time();
    if (result.entry_ticks >= result.deadline_ticks) { fail(&result, stage_clock, ETIMEDOUT); goto finish; }
    result.run_entries = 1;
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
    // Platform ABI: one coherent shared physical page, aligned atomic sequence,
    // guest STLR + DSB, host acquire. A VM exit alone is not an acquire fence.
    // No guest or host writer can run while these once-only copies are made.
    uint64_t reply_sequence = atomic_load_explicit((_Atomic(uint64_t) *)pages[2], memory_order_acquire);
    memcpy(result.request, pages[1], sizeof(result.request));
    memcpy(result.reply, pages[2], sizeof(result.reply));
    result.request_unchanged = !memcmp(pages[1], expected_request, 32) && zero_tail(pages[1], 32);
    result.reply_valid = reply_sequence == 1 && !memcmp(pages[2], expected_reply, 32) && zero_tail(pages[2], 32);
    result.code_unchanged = !memcmp(pages[0], guest_image, sizeof(guest_image)) && zero_tail(pages[0], sizeof(guest_image));
    uint64_t dfsc = result.syndrome & 63;
    // EC=data abort from lower EL, IL=1, ISV=1, SAS=32-bit, SRT=4,
    // unsigned W4 store, WnR=1; only translation-fault level may vary (0..3).
    result.trap_valid = result.exception_reason == HV_EXIT_REASON_EXCEPTION &&
        result.syndrome == (UINT64_C(0x93840040) | dfsc) && dfsc >= 4 && dfsc <= 7 &&
        result.pc == code_ipa + doorbell_offset && result.fault_ipa == doorbell_ipa &&
        result.fault_virtual_address == doorbell_ipa && result.x4 == 1;
    if (!seal_snapshot(&result)) fail(&result, stage_snapshot, EIO);
    if (!result.request_unchanged || !result.reply_valid || !result.code_unchanged || !result.trap_valid) {
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
        for (size_t i = 0; i < 3; ++i) if (mapped[i]) {
            result.unmap_status[i] = (int32_t)hv_vm_unmap(ipas[i], slot_size);
            if (result.unmap_status[i] == HV_SUCCESS) mapped[i] = false;
            else fail(&result, stage_vm_unmap, result.unmap_status[i]);
        }
        if (vm_created) {
            result.vm_destroy_status = (int32_t)hv_vm_destroy();
            if (result.vm_destroy_status == HV_SUCCESS) {
                vm_created = false;
                for (size_t i = 0; i < 3; ++i) mapped[i] = false;
            } else fail(&result, stage_vm_destroy, result.vm_destroy_status);
        }
    }
    bool conserved = !vm_created && !vcpu_created && (!watchdog_created || result.watchdog_join_status == 0);
    if (conserved) {
        for (size_t i = 0; i < 3; ++i) if (allocations[i]) {
            result.host_unmap_status[i] = munmap(allocations[i], allocation_size);
            if (result.host_unmap_status[i] == 0) allocations[i] = NULL;
            else { fail(&result, stage_host_unmap, errno); conserved = false; }
        }
    }
    pthread_mutex_lock(&lifetime_lock);
    if (!conserved) {
        lifetime.quarantined = true;
        for (size_t i = 0; i < 3; ++i) lifetime.retained_allocations[i] = allocations[i];
        result.resources_quarantined = 1;
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

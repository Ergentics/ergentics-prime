#include "PrimeGuestBridge.h"
#include "PrimeGuestImage.h" /* fixed bytes/label offsets generated from guest.S */
#include <Hypervisor/Hypervisor.h>
#include <errno.h>
#include <mach/mach.h>
#include <mach/mach_vm.h>
#include <libkern/OSCacheControl.h>
#include <pthread.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>

enum { PAGE = 16384, MAX_WATCH_WAKES = 1024 };
static const uint64_t CODE_IPA = UINT64_C(0x10000000);
static const uint64_t DATA_IPA = UINT64_C(0x10004000);
static const uint64_t MAGIC = UINT64_C(0x31564d4952505045);
static const uint64_t SCTLR = UINT64_C(0x30d00980);
static const uint64_t CPSR = UINT64_C(0x3c5);
static const uint64_t LIMIT_NS = UINT64_C(10000000000);

typedef struct {
    uint64_t magic;
    uint32_t count, allowedMin, completed, terminal, active, guard;
    uint32_t predictions[5], reserved[3];
    EPRPrimeGuestJob jobs[5];
} GuestState;
_Static_assert(sizeof(EPRPrimeGuestJob) == 264, "assembly job stride");
_Static_assert(offsetof(GuestState, jobs) == 64, "assembly jobs offset");
_Static_assert(offsetof(GuestState, predictions) == 32, "assembly predictions offset");
_Static_assert(sizeof(GuestState) == 1384, "assembly state layout");
_Static_assert(EPR_GUEST_IMAGE_SIZE < PAGE, "one fixed code page");

static pthread_mutex_t gate = PTHREAD_MUTEX_INITIALIZER;
static bool unusable_after_cleanup_failure;

typedef struct {
    pthread_mutex_t lock;
    pthread_cond_t condition;
    bool done, fired;
    uint32_t exitCalls;
    int waitStatus;
    hv_return_t exitStatus;
    hv_vcpu_t vcpu;
    uint64_t deadline;
} Watchdog;

static uint64_t now_ns(void) { return clock_gettime_nsec_np(CLOCK_UPTIME_RAW); }

static void *watch(void *opaque) {
    Watchdog *w = opaque;
    pthread_mutex_lock(&w->lock);
    uint32_t wakes = 0;
    while (!w->done) {
        uint64_t now = now_ns();
        if (now >= w->deadline || ++wakes > MAX_WATCH_WAKES) {
            w->fired = true;
            if (wakes > MAX_WATCH_WAKES) w->waitStatus = ELOOP;
            ++w->exitCalls;
            w->exitStatus = hv_vcpus_exit(&w->vcpu, 1);
            break;
        }
        uint64_t delay = w->deadline - now;
        if (delay > UINT64_C(100000000)) delay = UINT64_C(100000000);
        struct timespec relative = {0, (long)delay};
        int e = pthread_cond_timedwait_relative_np(&w->condition, &w->lock, &relative);
        w->waitStatus = e;
        if (e && e != ETIMEDOUT) {
            ++w->exitCalls;
            w->exitStatus = hv_vcpus_exit(&w->vcpu, 1);
            break;
        }
    }
    pthread_mutex_unlock(&w->lock);
    return NULL;
}

static void fail(EPRPrimeGuestResult *r, int32_t status, int32_t code) {
    if (r->status == EPR_PRIME_GUEST_OK) { r->status = status; r->failureCode = code; }
}

static bool region_has(void *ptr, vm_prot_t protection) {
    mach_vm_address_t requested = (mach_vm_address_t)ptr, address = requested;
    mach_vm_size_t size = 0;
    vm_region_basic_info_data_64_t info = {0};
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    mach_port_t object = MACH_PORT_NULL;
    kern_return_t kr = mach_vm_region(mach_task_self(), &address, &size,
        VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &count, &object);
    if (object != MACH_PORT_NULL) mach_port_deallocate(mach_task_self(), object);
    return kr == KERN_SUCCESS && address <= requested && size >= PAGE &&
        requested - address <= size - PAGE && info.protection == protection;
}

static bool pages_valid(uint8_t *codeAllocation, uint8_t *dataAllocation,
                        const uint8_t *expectedCode, const uint8_t *expectedData,
                        EPRPrimeGuestResult *r) {
    bool code = region_has(codeAllocation, VM_PROT_NONE) &&
        region_has(codeAllocation + PAGE, VM_PROT_READ) &&
        region_has(codeAllocation + 2 * PAGE, VM_PROT_NONE) &&
        memcmp(codeAllocation + PAGE, expectedCode, PAGE) == 0;
    bool data = region_has(dataAllocation, VM_PROT_NONE) &&
        region_has(dataAllocation + PAGE, VM_PROT_READ | VM_PROT_WRITE) &&
        region_has(dataAllocation + 2 * PAGE, VM_PROT_NONE) &&
        memcmp(dataAllocation + PAGE, expectedData, PAGE) == 0;
    r->codeImmutableValidated = code; r->dataGuardValidated = data;
    return code && data;
}

static bool set_reg(hv_vcpu_t cpu, hv_reg_t reg, uint64_t value, EPRPrimeGuestResult *r) {
    hv_return_t e = hv_vcpu_set_reg(cpu, reg, value);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, (int32_t)e); return false; }
    return true;
}

static bool get_reg(hv_vcpu_t cpu, hv_reg_t reg, uint64_t *value, EPRPrimeGuestResult *r) {
    hv_return_t e = hv_vcpu_get_reg(cpu, reg, value);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, (int32_t)e); return false; }
    return true;
}

static bool get_exit(hv_vcpu_t cpu, const hv_vcpu_exit_t *exit, EPRPrimeGuestExit *e,
                     EPRPrimeGuestResult *r) {
    e->reason = exit->reason; e->syndrome = exit->exception.syndrome;
    e->virtualAddress = exit->exception.virtual_address;
    e->physicalAddress = exit->exception.physical_address;
    if (!get_reg(cpu, HV_REG_PC, &e->pc, r) || !get_reg(cpu, HV_REG_CPSR, &e->cpsr, r) ||
        !get_reg(cpu, HV_REG_X0, &e->x0, r) || !get_reg(cpu, HV_REG_X1, &e->x1, r) ||
        !get_reg(cpu, HV_REG_X2, &e->x2, r) || !get_reg(cpu, HV_REG_X3, &e->x3, r) ||
        !get_reg(cpu, HV_REG_X20, &e->x20, r) || !get_reg(cpu, HV_REG_X21, &e->x21, r) ||
        !get_reg(cpu, HV_REG_X22, &e->x22, r) || !get_reg(cpu, HV_REG_X23, &e->x23, r) ||
        !get_reg(cpu, HV_REG_X24, &e->x24, r)) return false;
    hv_return_t status = hv_vcpu_get_sys_reg(cpu, HV_SYS_REG_SCTLR_EL1, &e->sctlr);
    if (status != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, (int32_t)status); return false; }
    return true;
}

/* Only the two fixed sides of this precise HVC instruction are admitted.
   The actual PC is retained; resume always selects the immutable next label,
   never arbitrary guest/host-provided code or a blind increment. */
static bool hvc_pc(uint64_t pc, uint32_t instruction, uint32_t next) {
    return next == instruction + 4 && (pc == CODE_IPA + instruction || pc == CODE_IPA + next);
}

static bool expected_page(uint8_t *expected, const GuestState *initial,
                           const uint32_t *returned, uint32_t completed,
                           uint32_t active, uint32_t terminal, bool preparingCurrent) {
    memset(expected, 0xa5, PAGE);
    GuestState *s = (GuestState *)expected;
    memcpy(s, initial, sizeof(*s));
    s->completed = completed; s->active = active; s->terminal = terminal;
    for (uint32_t j = 0; j < completed; ++j) s->predictions[j] = returned[j];
    uint32_t prepared = completed + (preparingCurrent ? 1u : 0u);
    for (uint32_t j = 0; j < prepared; ++j) {
        int32_t slot = s->jobs[j].priorPredictionOffset;
        if (slot >= 0) {
            if (j == 0 || returned[j - 1] < s->allowedMin || returned[j - 1] >= s->allowedMin + 8) return false;
            s->jobs[j].inputTokenIDs[slot] = returned[j - 1];
        }
    }
    return true;
}

int32_t epr_prime_guest_run(const EPRPrimeGuestJob *jobs, uint32_t count,
    uint32_t allowedMin, EPRPrimeGuestInferenceCallback callback, void *context,
    EPRPrimeGuestResult *r) {
    if (!r) return EPR_PRIME_GUEST_INVALID_REQUEST;
    memset(r, 0, sizeof(*r));
    r->requestedCount = count; r->codeByteCount = EPR_GUEST_IMAGE_SIZE;
    int32_t *statuses[] = {&r->vmCreateStatus, &r->codeMapStatus, &r->dataMapStatus,
        &r->vcpuCreateStatus, &r->codeProtectStatus, &r->dataProtectStatus,
        &r->watchdogCreateStatus, &r->watchdogJoinStatus, &r->watchdogWaitStatus,
        &r->watchdogExitStatus, &r->vcpuDestroyStatus, &r->codeUnmapStatus,
        &r->dataUnmapStatus, &r->vmDestroyStatus, &r->codeMunmapStatus, &r->dataMunmapStatus};
    for (size_t i = 0; i < sizeof(statuses) / sizeof(statuses[0]); ++i) *statuses[i] = INT32_MIN;
    for (unsigned i = 0; i < 5; ++i) r->predictions[i] = UINT32_MAX;
    for (unsigned i = 0; i < 6; ++i) r->exits[i].runStatus = INT32_MIN;
    uint64_t started = now_ns();
    pthread_threadid_np(NULL, &r->ownerThreadID);
    if (!jobs || !callback || count < 1 || count > 5 || (allowedMin != 16 && allowedMin != 64)) {
        r->status = EPR_PRIME_GUEST_INVALID_REQUEST; r->cleanupComplete = 1; return r->status;
    }
    for (uint32_t i = 0; i < count; ++i) {
        const EPRPrimeGuestJob *j = &jobs[i];
        if (!j->inputCount || j->inputCount > 64 || j->priorPredictionOffset < -1 ||
            j->priorPredictionOffset >= (int32_t)j->inputCount || (i == 0 && j->priorPredictionOffset != -1)) {
            r->status = EPR_PRIME_GUEST_INVALID_REQUEST; r->cleanupComplete = 1; return r->status;
        }
        for (uint32_t t = 0; t < 64; ++t) {
            if ((t < j->inputCount && j->inputTokenIDs[t] >= 16384) ||
                (t >= j->inputCount && j->inputTokenIDs[t] != 0)) {
                r->status = EPR_PRIME_GUEST_INVALID_REQUEST; r->cleanupComplete = 1; return r->status;
            }
        }
    }
    int lockResult = pthread_mutex_trylock(&gate);
    if (lockResult != 0) { r->status = EPR_PRIME_GUEST_BUSY; r->failureCode = lockResult; r->cleanupComplete = 1; return r->status; }
    if (unusable_after_cleanup_failure) {
        r->status = EPR_PRIME_GUEST_CLEANUP_ERROR; pthread_mutex_unlock(&gate); return r->status;
    }
    uint8_t *code = MAP_FAILED, *data = MAP_FAILED;
    uint8_t expectedCode[PAGE] = {0}, expectedData[PAGE];
    GuestState initial = {0};
    uint32_t returned[5] = {UINT32_MAX, UINT32_MAX, UINT32_MAX, UINT32_MAX, UINT32_MAX};
    bool vm = false, cpu = false, codeMapped = false, dataMapped = false, watcher = false;
    hv_vcpu_t vcpu = 0; hv_vcpu_exit_t *exitInfo = NULL;
    pthread_t thread;
    Watchdog wd = {.lock = PTHREAD_MUTEX_INITIALIZER, .condition = PTHREAD_COND_INITIALIZER,
                   .exitStatus = (hv_return_t)INT32_MIN, .deadline = started + LIMIT_NS};
    if (getpagesize() != PAGE) { fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, ENOTSUP); goto cleanup; }
    code = mmap(NULL, 3 * PAGE, PROT_NONE, MAP_PRIVATE | MAP_ANON, -1, 0);
    data = mmap(NULL, 3 * PAGE, PROT_NONE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (code == MAP_FAILED || data == MAP_FAILED) { fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, errno); goto cleanup; }
    if (mprotect(code + PAGE, PAGE, PROT_READ | PROT_WRITE) || mprotect(data + PAGE, PAGE, PROT_READ | PROT_WRITE)) {
        fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, errno); goto cleanup;
    }
    memcpy(expectedCode, epr_guest_image, EPR_GUEST_IMAGE_SIZE);
    memcpy(code + PAGE, expectedCode, PAGE);
    sys_icache_invalidate(code + PAGE, PAGE);
    initial.magic = MAGIC; initial.count = count; initial.allowedMin = allowedMin; initial.guard = 0xc0deface;
    for (unsigned i = 0; i < 5; ++i) initial.predictions[i] = UINT32_MAX;
    memcpy(initial.jobs, jobs, count * sizeof(*jobs));
    expected_page(expectedData, &initial, returned, 0, 0, 0, false);
    memcpy(data + PAGE, expectedData, PAGE);
    r->codeProtectStatus = mprotect(code + PAGE, PAGE, PROT_READ);
    if (r->codeProtectStatus) { fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, errno); goto cleanup; }
    r->dataProtectStatus = mprotect(data + PAGE, PAGE, PROT_READ | PROT_WRITE);
    if (r->dataProtectStatus || !pages_valid(code, data, expectedCode, expectedData, r)) {
        fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, r->dataProtectStatus ? errno : EPROTO); goto cleanup;
    }
    r->vmCreateStatus = (int32_t)hv_vm_create(NULL);
    if (r->vmCreateStatus != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, r->vmCreateStatus); goto cleanup; }
    vm = true;
    r->codeMapStatus = (int32_t)hv_vm_map(code + PAGE, CODE_IPA, PAGE, HV_MEMORY_READ | HV_MEMORY_EXEC);
    if (r->codeMapStatus != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, r->codeMapStatus); goto cleanup; }
    codeMapped = true;
    r->dataMapStatus = (int32_t)hv_vm_map(data + PAGE, DATA_IPA, PAGE, HV_MEMORY_READ | HV_MEMORY_WRITE);
    if (r->dataMapStatus != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, r->dataMapStatus); goto cleanup; }
    dataMapped = true;
    r->vcpuCreateStatus = (int32_t)hv_vcpu_create(&vcpu, &exitInfo, NULL);
    if (r->vcpuCreateStatus != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, r->vcpuCreateStatus); goto cleanup; }
    cpu = true;
    if (!exitInfo) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, EFAULT); goto cleanup; }
    for (uint32_t j = 0; j < 31; ++j) if (!set_reg(vcpu, (hv_reg_t)(HV_REG_X0 + j), 0, r)) goto cleanup;
    if (!set_reg(vcpu, HV_REG_PC, CODE_IPA, r) || !set_reg(vcpu, HV_REG_CPSR, CPSR, r)) goto cleanup;
    hv_return_t e = hv_vcpu_set_sys_reg(vcpu, HV_SYS_REG_SCTLR_EL1, SCTLR);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, (int32_t)e); goto cleanup; }
    e = hv_vcpu_set_sys_reg(vcpu, HV_SYS_REG_VBAR_EL1, 0);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, (int32_t)e); goto cleanup; }
    wd.vcpu = vcpu;
    r->watchdogCreateStatus = pthread_create(&thread, NULL, watch, &wd);
    if (r->watchdogCreateStatus) { fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, r->watchdogCreateStatus); goto cleanup; }
    watcher = true;
    for (uint32_t entry = 0; entry < count + 1; ++entry) {
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_GUEST_DEADLINE, ETIMEDOUT); break; }
        EPRPrimeGuestExit *observed = &r->exits[entry];
        ++r->runCount;
        observed->runStatus = (int32_t)hv_vcpu_run(vcpu);
        if (observed->runStatus != HV_SUCCESS) { fail(r, EPR_PRIME_GUEST_HYPERVISOR_ERROR, observed->runStatus); break; }
        if (!get_exit(vcpu, exitInfo, observed, r)) break;
        if (observed->reason == HV_EXIT_REASON_EXCEPTION) ++r->exceptionCount;
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_GUEST_DEADLINE, ETIMEDOUT); break; }
        uint32_t stage = r->inferenceReturnCount; r->stage = stage;
        bool isInfer = observed->syndrome == UINT64_C(0x5a000041);
        bool isComplete = observed->syndrome == UINT64_C(0x5a000042);
        bool isInvalid = observed->syndrome == UINT64_C(0x5a000043);
        bool registerOK = observed->reason == HV_EXIT_REASON_EXCEPTION &&
            (observed->cpsr & ~UINT64_C(0xf0000000)) == CPSR && observed->sctlr == SCTLR &&
            observed->x20 == DATA_IPA && observed->x21 == stage && observed->x22 == count &&
            observed->x23 == allowedMin && observed->x24 == DATA_IPA + 64 + stage * 264 &&
            observed->x0 == stage && observed->x3 == allowedMin;
        if (isInfer) registerOK = registerOK && stage < count &&
            hvc_pc(observed->pc, EPR_GUEST_INFER_OFFSET, EPR_GUEST_INFER_RESUME_OFFSET) &&
            observed->x1 == DATA_IPA + 64 + stage * 264 + 8 && observed->x2 == jobs[stage].inputCount;
        else if (isComplete) registerOK = registerOK && stage == count &&
            hvc_pc(observed->pc, EPR_GUEST_COMPLETE_OFFSET, EPR_GUEST_COMPLETE_RESUME_OFFSET) &&
            observed->x1 == 1 && observed->x2 == returned[stage - 1];
        else if (isInvalid) registerOK = registerOK && stage > 0 && stage < count &&
            jobs[stage].priorPredictionOffset >= 0 &&
            (returned[stage - 1] < allowedMin || returned[stage - 1] >= allowedMin + 8) &&
            hvc_pc(observed->pc, EPR_GUEST_INVALID_OFFSET, EPR_GUEST_INVALID_RESUME_OFFSET) &&
            observed->x1 == 2 && observed->x2 == returned[stage - 1];
        else registerOK = false;
        r->registerChecksPassed = registerOK;
        if (!registerOK || !expected_page(expectedData, &initial, returned, stage, stage,
                                         isComplete ? 1u : isInvalid ? 2u : 0u, isInfer) ||
            !pages_valid(code, data, expectedCode, expectedData, r)) {
            fail(r, EPR_PRIME_GUEST_INVALID_EXIT, EPROTO); break;
        }
        observed->validated = 1; r->guestInputChecksPassed = 1;
        r->completedCount = stage;
        memcpy(r->predictions, ((GuestState *)(data + PAGE))->predictions, sizeof(r->predictions));
        if (isComplete) { ++r->completionHVCCount; break; }
        if (isInvalid) { fail(r, EPR_PRIME_GUEST_INVALID_FEEDBACK, ERANGE); break; }
        ++r->inferenceRequestCount;
        const EPRPrimeGuestJob *active = &((GuestState *)(data + PAGE))->jobs[stage];
        r->observedJobs[stage] = *active;
        uint32_t prediction = UINT32_MAX;
        ++r->callbackCount;
        int32_t callbackStatus = callback(context, active->inputTokenIDs, active->inputCount, &prediction);
        if (callbackStatus || prediction >= 16384) {
            fail(r, EPR_PRIME_GUEST_CALLBACK_ERROR, callbackStatus ? callbackStatus : ERANGE); break;
        }
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_GUEST_DEADLINE, ETIMEDOUT); break; }
        // The callback receives a const view only. Rejoin all guest memory before
        // returning its unrestricted prediction in X0; host does not insert feedback.
        if (!pages_valid(code, data, expectedCode, expectedData, r)) { fail(r, EPR_PRIME_GUEST_INVALID_EXIT, EPROTO); break; }
        if (!set_reg(vcpu, HV_REG_X0, prediction, r) ||
            !set_reg(vcpu, HV_REG_PC, CODE_IPA + EPR_GUEST_INFER_RESUME_OFFSET, r)) break;
        returned[stage] = prediction;
        ++r->inferenceReturnCount;
    }
    if (r->status == EPR_PRIME_GUEST_OK && (r->completedCount != count || r->completionHVCCount != 1))
        fail(r, EPR_PRIME_GUEST_ENTRY_LIMIT, ELOOP);

cleanup:
    if (watcher) {
        pthread_mutex_lock(&wd.lock); wd.done = true; pthread_cond_signal(&wd.condition); pthread_mutex_unlock(&wd.lock);
        r->watchdogJoinStatus = pthread_join(thread, NULL);
        if (r->watchdogJoinStatus) {
            // No return, resource destruction, or expired stack while a watcher
            // could still call hv_vcpus_exit. The outer process owner records78.
            fprintf(stderr, "Prime guest watchdog join failed: %d\n", r->watchdogJoinStatus);
            _Exit(78);
        }
        r->watchdogFired = wd.fired; r->watchdogExitCalls = wd.exitCalls;
        r->watchdogExitStatus = (int32_t)wd.exitStatus; r->watchdogWaitStatus = wd.waitStatus;
        if (wd.fired) fail(r, EPR_PRIME_GUEST_DEADLINE, ETIMEDOUT);
        if ((wd.waitStatus && wd.waitStatus != ETIMEDOUT) || (wd.exitCalls && wd.exitStatus != HV_SUCCESS))
            fail(r, EPR_PRIME_GUEST_SYSTEM_ERROR, wd.waitStatus && wd.waitStatus != ETIMEDOUT ? wd.waitStatus : (int32_t)wd.exitStatus);
    }
    pthread_cond_destroy(&wd.condition); pthread_mutex_destroy(&wd.lock);
    bool safeToFree = !vm, clean = true;
    if (cpu) {
        r->vcpuDestroyStatus = (int32_t)hv_vcpu_destroy(vcpu);
        if (r->vcpuDestroyStatus != HV_SUCCESS) clean = false;
        else cpu = false;
    }
    if (!cpu && vm) {
        if (codeMapped) { r->codeUnmapStatus = (int32_t)hv_vm_unmap(CODE_IPA, PAGE); if (r->codeUnmapStatus != HV_SUCCESS) clean = false; }
        if (dataMapped) { r->dataUnmapStatus = (int32_t)hv_vm_unmap(DATA_IPA, PAGE); if (r->dataUnmapStatus != HV_SUCCESS) clean = false; }
        r->vmDestroyStatus = (int32_t)hv_vm_destroy();
        if (r->vmDestroyStatus != HV_SUCCESS) clean = false;
        else safeToFree = true;
    }
    if (safeToFree) {
        if (code != MAP_FAILED) { r->codeMunmapStatus = munmap(code, 3 * PAGE); if (r->codeMunmapStatus) clean = false; }
        if (data != MAP_FAILED) { r->dataMunmapStatus = munmap(data, 3 * PAGE); if (r->dataMunmapStatus) clean = false; }
    } else clean = false; /* Keep backing alive for any unconfirmed mapping. */
    r->cleanupComplete = clean;
    if (!clean) { unusable_after_cleanup_failure = true; r->status = EPR_PRIME_GUEST_CLEANUP_ERROR; }
    r->elapsedNanoseconds = now_ns() - started;
    pthread_mutex_unlock(&gate);
    return r->status;
}

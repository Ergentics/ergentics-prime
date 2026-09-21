#include "PrimeGuestCompute.h"
#include "PrimeComputeImage.h" /* fixed bytes/label offsets generated from guest.S */
#include <Hypervisor/Hypervisor.h>
#include <errno.h>
#include <math.h>
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
static const uint64_t MAGIC = UINT64_C(0x31504d4f43525045);
static const uint64_t SCTLR = UINT64_C(0x30d00980);
static const uint64_t CPSR = UINT64_C(0x3c5);
static const uint64_t LIMIT_NS = UINT64_C(10000000000);

typedef struct {
    uint64_t magic;
    uint32_t stage, operation, guestReadCount, reserved0;
    uint64_t checksum;
    uint32_t expectedValueCount, reserved[7];
} Control;
_Static_assert(sizeof(Control) == 64, "assembly control layout");
_Static_assert(offsetof(Control, checksum) == 24, "assembly checksum offset");
_Static_assert(sizeof(EPRPrimeComputeInput) == 2384, "typed 2D request layout");
_Static_assert(sizeof(EPRPrimeComputeReply) == 2408, "typed 2D reply layout");
_Static_assert(64 + sizeof(EPRPrimeComputeInput) < 4096, "request before reply");
_Static_assert(4096 + sizeof(EPRPrimeComputeReply) < PAGE, "reply before guard padding");
_Static_assert(EPR_COMPUTE_IMAGE_SIZE < PAGE, "fixed code page");
static const uint64_t HASH_START = UINT64_C(0xcbf29ce484222325);
static const uint64_t HASH_PRIME = UINT64_C(0x100000001b3);

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

static void fail(EPRPrimeComputeResult *r, int32_t status, int32_t code) {
    if (r->status == EPR_PRIME_COMPUTE_OK) { r->status = status; r->failureCode = code; }
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
                        EPRPrimeComputeResult *r) {
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

static bool set_reg(hv_vcpu_t cpu, hv_reg_t reg, uint64_t value, EPRPrimeComputeResult *r) {
    hv_return_t e = hv_vcpu_set_reg(cpu, reg, value);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, (int32_t)e); return false; }
    return true;
}

static bool get_reg(hv_vcpu_t cpu, hv_reg_t reg, uint64_t *value, EPRPrimeComputeResult *r) {
    hv_return_t e = hv_vcpu_get_reg(cpu, reg, value);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, (int32_t)e); return false; }
    return true;
}

static bool get_exit(hv_vcpu_t cpu, const hv_vcpu_exit_t *exit, EPRPrimeComputeExit *e,
                     EPRPrimeComputeResult *r) {
    e->reason = exit->reason; e->syndrome = exit->exception.syndrome;
    e->virtualAddress = exit->exception.virtual_address;
    e->physicalAddress = exit->exception.physical_address;
    if (!get_reg(cpu, HV_REG_PC, &e->pc, r) || !get_reg(cpu, HV_REG_CPSR, &e->cpsr, r) ||
        !get_reg(cpu, HV_REG_X0, &e->x0, r) || !get_reg(cpu, HV_REG_X1, &e->x1, r) ||
        !get_reg(cpu, HV_REG_X2, &e->x2, r) || !get_reg(cpu, HV_REG_X3, &e->x3, r) ||
        !get_reg(cpu, HV_REG_X20, &e->x20, r) || !get_reg(cpu, HV_REG_X21, &e->x21, r) ||
        !get_reg(cpu, HV_REG_X22, &e->x22, r) || !get_reg(cpu, HV_REG_X23, &e->x23, r) ||
        !get_reg(cpu, HV_REG_X27, &e->x27, r) || !get_reg(cpu, HV_REG_X28, &e->x28, r)) return false;
    hv_return_t status = hv_vcpu_get_sys_reg(cpu, HV_SYS_REG_SCTLR_EL1, &e->sctlr);
    if (status != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, (int32_t)status); return false; }
    return true;
}

/* Only the two fixed sides of this precise HVC instruction are admitted.
   The actual PC is retained; resume always selects the immutable next label,
   never arbitrary guest/host-provided code or a blind increment. */
static bool hvc_pc(uint64_t pc, uint32_t instruction, uint32_t next) {
    return next == instruction + 4 && (pc == CODE_IPA + instruction || pc == CODE_IPA + next);
}

static uint32_t float_bits(float value) {
    uint32_t bits; memcpy(&bits, &value, sizeof(bits)); return bits;
}

static bool input_valid(const EPRPrimeComputeInput *input) {
    if (!input || input->pointCount < 1 || input->pointCount > 200 ||
        input->nodeCount < 1 || input->nodeCount > 64 || input->reserved != 0 ||
        !isfinite(input->sigma) || input->sigma <= 0) return false;
    for (uint32_t i = 0; i < 400; ++i)
        if (i < 2 * input->pointCount ? !isfinite(input->pointsXY[i]) : float_bits(input->pointsXY[i]) != 0) return false;
    for (uint32_t i = 0; i < 192; ++i)
        if (i < 3 * input->nodeCount ? !isfinite(input->nodesXYWeight[i]) : float_bits(input->nodesXYWeight[i]) != 0) return false;
    return true;
}

static bool reply_valid(const EPRPrimeComputeReply *reply, uint32_t count) {
    if (reply->valueCount != count || reply->reserved != 0) return false;
    for (uint32_t i = 0; i < 600; ++i)
        if (i < count ? !isfinite(reply->values[i]) : float_bits(reply->values[i]) != 0) return false;
    return true;
}

static uint64_t checksum(const EPRPrimeComputeReply *reply) {
    uint64_t hash = HASH_START;
    for (uint32_t i = 0; i < reply->valueCount; ++i) hash = (hash ^ float_bits(reply->values[i])) * HASH_PRIME;
    return hash;
}

int32_t epr_prime_compute_run(const EPRPrimeComputeInput *input,
    EPRPrimeComputeCallback callback, void *context, EPRPrimeComputeResult *r) {
    if (!r) return EPR_PRIME_COMPUTE_INVALID_REQUEST;
    memset(r, 0, sizeof(*r)); r->codeByteCount = EPR_COMPUTE_IMAGE_SIZE;
    int32_t *statuses[] = {&r->vmCreateStatus, &r->codeMapStatus, &r->dataMapStatus,
        &r->vcpuCreateStatus, &r->codeProtectStatus, &r->dataProtectStatus,
        &r->watchdogCreateStatus, &r->watchdogJoinStatus, &r->watchdogWaitStatus,
        &r->watchdogExitStatus, &r->vcpuDestroyStatus, &r->codeUnmapStatus,
        &r->dataUnmapStatus, &r->vmDestroyStatus, &r->codeMunmapStatus, &r->dataMunmapStatus};
    for (size_t i = 0; i < sizeof(statuses) / sizeof(statuses[0]); ++i) *statuses[i] = INT32_MIN;
    for (unsigned i = 0; i < 2; ++i) r->exits[i].runStatus = INT32_MIN;
    uint64_t started = now_ns(); pthread_threadid_np(NULL, &r->ownerThreadID);
    // Snapshot caller-owned values once; all later admission/readback uses this copy.
    EPRPrimeComputeInput retained = {0};
    if (input) memcpy(&retained, input, sizeof(retained));
    if (!input || !callback || !input_valid(&retained)) {
        r->status = EPR_PRIME_COMPUTE_INVALID_REQUEST; r->cleanupComplete = 1; return r->status;
    }
    r->inputValidated = 1;
    int lockResult = pthread_mutex_trylock(&gate);
    if (lockResult) { r->status = EPR_PRIME_COMPUTE_BUSY; r->failureCode = lockResult; r->cleanupComplete = 1; return r->status; }
    if (unusable_after_cleanup_failure) {
        r->status = EPR_PRIME_COMPUTE_CLEANUP_ERROR; pthread_mutex_unlock(&gate); return r->status;
    }
    uint8_t *code = MAP_FAILED, *data = MAP_FAILED;
    uint8_t expectedCode[PAGE] = {0}, expectedData[PAGE];
    bool vm = false, cpu = false, codeMapped = false, dataMapped = false, watcher = false;
    hv_vcpu_t vcpu = 0; hv_vcpu_exit_t *exitInfo = NULL;
    pthread_t thread;
    Watchdog wd = {.lock = PTHREAD_MUTEX_INITIALIZER, .condition = PTHREAD_COND_INITIALIZER,
                   .exitStatus = (hv_return_t)INT32_MIN, .deadline = started + LIMIT_NS};
    if (getpagesize() != PAGE) { fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, ENOTSUP); goto cleanup; }
    code = mmap(NULL, 3 * PAGE, PROT_NONE, MAP_PRIVATE | MAP_ANON, -1, 0);
    data = mmap(NULL, 3 * PAGE, PROT_NONE, MAP_PRIVATE | MAP_ANON, -1, 0);
    if (code == MAP_FAILED || data == MAP_FAILED) { fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, errno); goto cleanup; }
    if (mprotect(code + PAGE, PAGE, PROT_READ | PROT_WRITE) || mprotect(data + PAGE, PAGE, PROT_READ | PROT_WRITE)) {
        fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, errno); goto cleanup;
    }
    memcpy(expectedCode, epr_compute_image, EPR_COMPUTE_IMAGE_SIZE);
    memcpy(code + PAGE, expectedCode, PAGE); sys_icache_invalidate(code + PAGE, PAGE);
    memset(expectedData, 0xa5, PAGE);
    Control initial = {.magic = MAGIC, .operation = 1, .expectedValueCount = 3 * retained.pointCount};
    memcpy(expectedData, &initial, sizeof(initial));
    memcpy(expectedData + 64, &retained, sizeof(retained));
    memset(expectedData + 4096, 0, sizeof(EPRPrimeComputeReply));
    memcpy(data + PAGE, expectedData, PAGE);
    r->codeProtectStatus = mprotect(code + PAGE, PAGE, PROT_READ);
    if (r->codeProtectStatus) { fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, errno); goto cleanup; }
    r->dataProtectStatus = mprotect(data + PAGE, PAGE, PROT_READ | PROT_WRITE);
    if (r->dataProtectStatus || !pages_valid(code, data, expectedCode, expectedData, r)) {
        fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, r->dataProtectStatus ? errno : EPROTO); goto cleanup;
    }
    r->vmCreateStatus = (int32_t)hv_vm_create(NULL);
    if (r->vmCreateStatus != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, r->vmCreateStatus); goto cleanup; }
    vm = true;
    r->codeMapStatus = (int32_t)hv_vm_map(code + PAGE, CODE_IPA, PAGE, HV_MEMORY_READ | HV_MEMORY_EXEC);
    if (r->codeMapStatus != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, r->codeMapStatus); goto cleanup; }
    codeMapped = true;
    r->dataMapStatus = (int32_t)hv_vm_map(data + PAGE, DATA_IPA, PAGE, HV_MEMORY_READ | HV_MEMORY_WRITE);
    if (r->dataMapStatus != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, r->dataMapStatus); goto cleanup; }
    dataMapped = true;
    r->vcpuCreateStatus = (int32_t)hv_vcpu_create(&vcpu, &exitInfo, NULL);
    if (r->vcpuCreateStatus != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, r->vcpuCreateStatus); goto cleanup; }
    cpu = true;
    if (!exitInfo) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, EFAULT); goto cleanup; }
    for (uint32_t j = 0; j < 31; ++j) if (!set_reg(vcpu, (hv_reg_t)(HV_REG_X0 + j), 0, r)) goto cleanup;
    if (!set_reg(vcpu, HV_REG_PC, CODE_IPA, r) || !set_reg(vcpu, HV_REG_CPSR, CPSR, r)) goto cleanup;
    hv_return_t e = hv_vcpu_set_sys_reg(vcpu, HV_SYS_REG_SCTLR_EL1, SCTLR);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, (int32_t)e); goto cleanup; }
    e = hv_vcpu_set_sys_reg(vcpu, HV_SYS_REG_VBAR_EL1, 0);
    if (e != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, (int32_t)e); goto cleanup; }
    wd.vcpu = vcpu;
    r->watchdogCreateStatus = pthread_create(&thread, NULL, watch, &wd);
    if (r->watchdogCreateStatus) { fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, r->watchdogCreateStatus); goto cleanup; }
    watcher = true;
    for (uint32_t entry = 0; entry < 2; ++entry) {
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_COMPUTE_DEADLINE, ETIMEDOUT); break; }
        EPRPrimeComputeExit *observed = &r->exits[entry]; ++r->runCount;
        observed->runStatus = (int32_t)hv_vcpu_run(vcpu);
        if (observed->runStatus != HV_SUCCESS) { fail(r, EPR_PRIME_COMPUTE_HYPERVISOR_ERROR, observed->runStatus); break; }
        if (!get_exit(vcpu, exitInfo, observed, r)) break;
        if (observed->reason == HV_EXIT_REASON_EXCEPTION) ++r->exceptionCount;
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_COMPUTE_DEADLINE, ETIMEDOUT); break; }
        Control *expected = (Control *)expectedData;
        bool registerOK = observed->reason == HV_EXIT_REASON_EXCEPTION &&
            (observed->cpsr & ~UINT64_C(0xf0000000)) == CPSR && observed->sctlr == SCTLR &&
            observed->x20 == DATA_IPA && observed->x21 == DATA_IPA + 4096 &&
            observed->x22 == initial.expectedValueCount && observed->x3 == initial.expectedValueCount;
        if (entry == 0) {
            expected->stage = 1;
            registerOK = registerOK && observed->syndrome == UINT64_C(0x5a000051) &&
                hvc_pc(observed->pc, EPR_COMPUTE_REQUEST_OFFSET, EPR_COMPUTE_REQUEST_RESUME_OFFSET) &&
                observed->x0 == 1 && observed->x1 == DATA_IPA + 64 && observed->x2 == DATA_IPA + 4096 &&
                observed->x23 == 0 && observed->x27 == 0 && observed->x28 == 0;
        } else {
            expected->stage = 2; expected->guestReadCount = initial.expectedValueCount;
            expected->checksum = r->hostExpectedChecksum;
            registerOK = registerOK && observed->syndrome == UINT64_C(0x5a000052) &&
                hvc_pc(observed->pc, EPR_COMPUTE_COMPLETE_OFFSET, EPR_COMPUTE_COMPLETE_RESUME_OFFSET) &&
                observed->x0 == 2 && observed->x1 == initial.expectedValueCount && observed->x2 == r->hostExpectedChecksum &&
                observed->x23 == initial.expectedValueCount && observed->x27 == r->hostExpectedChecksum && observed->x28 == HASH_PRIME;
        }
        r->registerChecksPassed = registerOK;
        if (!registerOK || !pages_valid(code, data, expectedCode, expectedData, r)) {
            fail(r, EPR_PRIME_COMPUTE_INVALID_EXIT, EPROTO); break;
        }
        observed->validated = 1; r->stage = entry + 1;
        if (entry == 1) {
            const Control *actual = (const Control *)(data + PAGE);
            r->guestReadCount = actual->guestReadCount; r->guestChecksum = actual->checksum;
            r->checksumMatched = r->guestChecksum == r->hostExpectedChecksum;
            ++r->completionHVCCount; break;
        }
        ++r->requestHVCCount;
        const EPRPrimeComputeInput *active = (const EPRPrimeComputeInput *)(data + PAGE + 64);
        EPRPrimeComputeReply *reply = (EPRPrimeComputeReply *)(data + PAGE + 4096);
        memcpy(&r->observedInput, active, sizeof(*active));
        ++r->callbackCount;
        int32_t callbackStatus = callback(context, active, reply);
        // Copy the actual reply even on rejection; invalid floats must be saved
        // as raw bit patterns by a caller that records this failure path.
        memcpy(&r->observedReply, reply, sizeof(*reply));
        if (callbackStatus) { fail(r, EPR_PRIME_COMPUTE_CALLBACK_ERROR, callbackStatus); break; }
        if (now_ns() >= wd.deadline) { fail(r, EPR_PRIME_COMPUTE_DEADLINE, ETIMEDOUT); break; }
        if (!reply_valid(&r->observedReply, initial.expectedValueCount)) {
            fail(r, EPR_PRIME_COMPUTE_INVALID_REPLY, EDOM); break;
        }
        r->replyValidated = 1;
        memcpy(expectedData + 4096, &r->observedReply, sizeof(*reply));
        // Only the dedicated reply region may change. All control, input, code,
        // padding, unused storage and host protections are rejoined unchanged.
        if (!pages_valid(code, data, expectedCode, expectedData, r)) {
            fail(r, EPR_PRIME_COMPUTE_INVALID_EXIT, EPROTO); break;
        }
        r->hostExpectedChecksum = checksum(&r->observedReply);
        if (!set_reg(vcpu, HV_REG_X0, 0, r) ||
            !set_reg(vcpu, HV_REG_PC, CODE_IPA + EPR_COMPUTE_REQUEST_RESUME_OFFSET, r)) break;
        ++r->replyReturnCount;
    }
    if (r->status == EPR_PRIME_COMPUTE_OK && (r->completionHVCCount != 1 || r->guestReadCount != initial.expectedValueCount || !r->checksumMatched))
        fail(r, EPR_PRIME_COMPUTE_ENTRY_LIMIT, ELOOP);

cleanup:
    if (watcher) {
        pthread_mutex_lock(&wd.lock); wd.done = true; pthread_cond_signal(&wd.condition); pthread_mutex_unlock(&wd.lock);
        r->watchdogJoinStatus = pthread_join(thread, NULL);
        if (r->watchdogJoinStatus) {
            // No return, resource destruction, or expired stack while a watcher
            // could still call hv_vcpus_exit. The outer process owner records78.
            fprintf(stderr, "Prime compute guest watchdog join failed: %d\n", r->watchdogJoinStatus);
            _Exit(78);
        }
        r->watchdogFired = wd.fired; r->watchdogExitCalls = wd.exitCalls;
        r->watchdogExitStatus = (int32_t)wd.exitStatus; r->watchdogWaitStatus = wd.waitStatus;
        if (wd.fired) fail(r, EPR_PRIME_COMPUTE_DEADLINE, ETIMEDOUT);
        if ((wd.waitStatus && wd.waitStatus != ETIMEDOUT) || (wd.exitCalls && wd.exitStatus != HV_SUCCESS))
            fail(r, EPR_PRIME_COMPUTE_SYSTEM_ERROR, wd.waitStatus && wd.waitStatus != ETIMEDOUT ? wd.waitStatus : (int32_t)wd.exitStatus);
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
    if (!clean) { unusable_after_cleanup_failure = true; r->status = EPR_PRIME_COMPUTE_CLEANUP_ERROR; }
    r->elapsedNanoseconds = now_ns() - started;
    pthread_mutex_unlock(&gate);
    return r->status;
}

#ifndef EPR_PRIME_GUEST_BRIDGE_H
#define EPR_PRIME_GUEST_BRIDGE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

#define EPR_PRIME_GUEST_MAX_JOBS 5u
#define EPR_PRIME_GUEST_MAX_TOKENS 64u
#define EPR_PRIME_GUEST_MAX_EXITS 6u
#define EPR_PRIME_GUEST_NOT_ATTEMPTED INT32_MIN

typedef struct {
    uint32_t inputCount;
    int32_t priorPredictionOffset; /* -1, or a slot in this job; first job must be -1. */
    uint32_t inputTokenIDs[64];
} EPRPrimeGuestJob;

/* Return zero only when prediction has been written. Prediction is unrestricted
   0..<16384, not clamped to the eight assigned value symbols. Synchronous call
   on the same thread as the owning vCPU; callback must have its own finite bound. */
typedef int32_t (*EPRPrimeGuestInferenceCallback)(void *context,
    const uint32_t *inputTokenIDs, uint32_t inputCount, uint32_t *prediction);

enum EPRPrimeGuestStatus {
    EPR_PRIME_GUEST_OK = 0, EPR_PRIME_GUEST_INVALID_REQUEST = 1,
    EPR_PRIME_GUEST_BUSY = 2, EPR_PRIME_GUEST_SYSTEM_ERROR = 3,
    EPR_PRIME_GUEST_HYPERVISOR_ERROR = 4, EPR_PRIME_GUEST_INVALID_EXIT = 5,
    EPR_PRIME_GUEST_CALLBACK_ERROR = 6, EPR_PRIME_GUEST_INVALID_FEEDBACK = 7,
    EPR_PRIME_GUEST_DEADLINE = 8, EPR_PRIME_GUEST_CLEANUP_ERROR = 9,
    EPR_PRIME_GUEST_ENTRY_LIMIT = 10
};

typedef struct {
    int32_t runStatus;
    uint32_t reason;
    uint64_t pc, cpsr, syndrome, virtualAddress, physicalAddress;
    uint64_t x0, x1, x2, x3;
    uint64_t x20, x21, x22, x23, x24, sctlr;
    uint32_t validated;
} EPRPrimeGuestExit;

typedef struct {
    int32_t status;             /* enum EPRPrimeGuestStatus */
    uint32_t stage;             /* zero-based next/in-progress job */
    int32_t failureCode;        /* actual errno/HV/callback value where applicable */
    uint32_t requestedCount, completedCount;
    uint32_t runCount, exceptionCount, inferenceRequestCount, inferenceReturnCount;
    uint32_t callbackCount, completionHVCCount;
    uint32_t predictions[5];   /* only first completedCount are guest committed */
    EPRPrimeGuestJob observedJobs[5]; /* exact validated HVC inputs, by callback index */
    EPRPrimeGuestExit exits[6];
    uint64_t ownerThreadID, elapsedNanoseconds;
    uint32_t codeByteCount, codeImmutableValidated, dataGuardValidated;
    uint32_t registerChecksPassed, guestInputChecksPassed;
    int32_t vmCreateStatus, codeMapStatus, dataMapStatus, vcpuCreateStatus;
    int32_t codeProtectStatus, dataProtectStatus;
    int32_t watchdogCreateStatus, watchdogJoinStatus, watchdogWaitStatus;
    uint32_t watchdogFired, watchdogExitCalls;
    int32_t watchdogExitStatus;
    int32_t vcpuDestroyStatus, codeUnmapStatus, dataUnmapStatus, vmDestroyStatus;
    int32_t codeMunmapStatus, dataMunmapStatus;
    uint32_t cleanupComplete;
} EPRPrimeGuestResult;

/* Creates a dedicated VM, executes fixed guest bytes, joins its watchdog, and
   destroys owned resources before normal return. allowedMin is exactly16 or64;
   the assigned value domain is [allowedMin,allowedMin+8). Up to5 jobs.
   Fixed 10s VM/callback wall deadline, <=count+1 entries. The watchdog only calls
   thread-safe hv_vcpus_exit; all owning HV calls and callbacks stay on this thread.
   A callback that does not return needs the containing process's outer deadline.
   pthread_join failure is fail-stop _Exit(78), never return with a live watcher.
   A failed HV cleanup latches this bridge unavailable for subsequent calls. */
int32_t epr_prime_guest_run(const EPRPrimeGuestJob *jobs, uint32_t count,
    uint32_t allowedMin, EPRPrimeGuestInferenceCallback callback, void *context,
    EPRPrimeGuestResult *result);

#ifdef __cplusplus
}
#endif
#endif

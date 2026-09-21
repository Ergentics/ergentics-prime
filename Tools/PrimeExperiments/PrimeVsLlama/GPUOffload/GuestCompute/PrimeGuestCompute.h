#ifndef EPR_PRIME_GUEST_COMPUTE_H
#define EPR_PRIME_GUEST_COMPUTE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

#define EPR_PRIME_COMPUTE_ABI_VERSION 1u
#define EPR_PRIME_COMPUTE_MAX_POINTS 200u
#define EPR_PRIME_COMPUTE_MAX_NODES 64u
#define EPR_PRIME_COMPUTE_MAX_VALUES 600u
#define EPR_PRIME_COMPUTE_NOT_ATTEMPTED INT32_MIN

typedef struct {
    uint32_t pointCount, nodeCount;
    float sigma; /* finite and strictly positive */
    uint32_t reserved; /* zero */
    float pointsXY[400]; /* interleaved x,y; unused storage all-zero bits */
    float nodesXYWeight[192]; /* interleaved x,y,weight; unused storage zero */
} EPRPrimeComputeInput;

typedef struct {
    uint32_t valueCount, reserved;
    /* Exactly 3*pointCount finite F32 values: potential[pointCount], followed
       by interleaved gradientXY[2*pointCount]. Unused storage all-zero bits. */
    float values[600];
} EPRPrimeComputeReply;

/* Synchronous owning-thread callback. Fill only reply, returning zero only on
   complete actual compute. Input/reply point into stopped guest memory. The
   bridge rejoins every byte outside reply and validates the typed reply before
   resuming. Callback must have its own finite bound; process owner is required
   for a callback that never returns. No model operation is implemented here. */
typedef int32_t (*EPRPrimeComputeCallback)(void *context,
    const EPRPrimeComputeInput *input, EPRPrimeComputeReply *reply);

enum EPRPrimeComputeStatus {
    EPR_PRIME_COMPUTE_OK = 0, EPR_PRIME_COMPUTE_INVALID_REQUEST = 1,
    EPR_PRIME_COMPUTE_BUSY = 2, EPR_PRIME_COMPUTE_SYSTEM_ERROR = 3,
    EPR_PRIME_COMPUTE_HYPERVISOR_ERROR = 4, EPR_PRIME_COMPUTE_INVALID_EXIT = 5,
    EPR_PRIME_COMPUTE_CALLBACK_ERROR = 6, EPR_PRIME_COMPUTE_INVALID_REPLY = 7,
    EPR_PRIME_COMPUTE_DEADLINE = 8, EPR_PRIME_COMPUTE_CLEANUP_ERROR = 9,
    EPR_PRIME_COMPUTE_ENTRY_LIMIT = 10
};

typedef struct {
    int32_t runStatus;
    uint32_t reason;
    uint64_t pc, cpsr, syndrome, virtualAddress, physicalAddress;
    uint64_t x0, x1, x2, x3, x20, x21, x22, x23, x27, x28, sctlr;
    uint32_t validated;
} EPRPrimeComputeExit;

typedef struct {
    int32_t status;
    uint32_t stage; /* 0 before request,1 before reply commit,2 guest complete */
    int32_t failureCode;
    uint32_t runCount, exceptionCount, requestHVCCount, replyReturnCount;
    uint32_t callbackCount, completionHVCCount, guestReadCount;
    uint64_t guestChecksum, hostExpectedChecksum;
    EPRPrimeComputeInput observedInput;
    EPRPrimeComputeReply observedReply;
    EPRPrimeComputeExit exits[2];
    uint64_t ownerThreadID, elapsedNanoseconds;
    uint32_t codeByteCount, codeImmutableValidated, dataGuardValidated;
    uint32_t registerChecksPassed, inputValidated, replyValidated, checksumMatched;
    int32_t vmCreateStatus, codeMapStatus, dataMapStatus, vcpuCreateStatus;
    int32_t codeProtectStatus, dataProtectStatus;
    int32_t watchdogCreateStatus, watchdogJoinStatus, watchdogWaitStatus;
    uint32_t watchdogFired, watchdogExitCalls;
    int32_t watchdogExitStatus;
    int32_t vcpuDestroyStatus, codeUnmapStatus, dataUnmapStatus, vmDestroyStatus;
    int32_t codeMunmapStatus, dataMunmapStatus;
    uint32_t cleanupComplete;
} EPRPrimeComputeResult;

/* Fixed geometry operation1, HVC request0x51 then complete0x52. Guest consumes
   every returned F32 bit pattern, in packed order, committing a64-bit checksum:
   start0xcbf29ce484222325; for each UInt32 word: (hash XOR word)*0x100000001b3
   modulo2^64. This is transport equality, not a claim of GPU device emulation
   or numerical correctness. Same-thread HV ownership,10s joined watchdog,
   exact cleanup; no VM/GPU call occurs until this function is invoked. */
int32_t epr_prime_compute_run(const EPRPrimeComputeInput *input,
    EPRPrimeComputeCallback callback, void *context, EPRPrimeComputeResult *result);

#ifdef __cplusplus
}
#endif
#endif

#include "../Guest/PrimeGuestBridge.h"
#include "../Admission/PrimeInferenceAdmission.h"
#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/* Explicit mechanism fixtures only: no weights, model, tokenizer or gold answers. */
typedef struct {
    unsigned test, calls, returned;
    uint64_t started, finished;
    EPRPrimeGuestJob observed[5];
    uint32_t valueBeforeMutation, valueAfterMutation;
    int sleepError;
} Fixture;

static int32_t fixture_callback(void *opaque, const uint32_t *ids, uint32_t count,
                                 uint32_t *prediction) {
    Fixture *f = opaque;
    if (f->calls >= 5 || count > 64) return -98;
    EPRPrimeGuestJob *observed = &f->observed[f->calls++];
    observed->inputCount = count;
    memcpy(observed->inputTokenIDs, ids, count * sizeof(*ids));
    f->started = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    int32_t error = 0;
    if (f->test == 2) error = -99;
    else if (f->test == 4) {
        /* Deliberate test-only violation of the const callback contract. */
        f->valueBeforeMutation = ids[0];
        ((uint8_t *)(uintptr_t)ids)[0] ^= 1u;
        f->valueAfterMutation = ids[0];
        *prediction = 16;
    } else if (f->test == 5) {
        struct timespec remaining = {10, 200000000}, next;
        for (unsigned tries = 0; ; ++tries) {
            if (nanosleep(&remaining, &next) == 0) break;
            if (errno != EINTR || tries >= 31) { f->sleepError = errno; error = -97; break; }
            remaining = next;
        }
        *prediction = 16;
    } else *prediction = 47;
    f->finished = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    ++f->returned;
    return error;
}

static void string(const char *s) {
    putchar('"');
    for (const unsigned char *p = (const unsigned char *)s; *p; ++p) {
        if (*p == '"' || *p == '\\') { putchar('\\'); putchar(*p); }
        else if (*p < 32) printf("\\u%04x", *p);
        else putchar(*p);
    }
    putchar('"');
}

static void admission_json(PrimeInferenceAdmissionResult a) {
    printf("{\"status\":%d,\"reason\":%u,\"securityStatus\":%d,\"effectiveEntitlementError\":%" PRId64,
           a.status, a.reason, a.security_status, a.effective_entitlement_error);
    printf(",\"signatureFlags\":%" PRIu64 ",\"identityMatches\":%u,\"teamMatches\":%u,\"hardenedRuntime\":%u,\"adHoc\":%u",
           a.signature_flags, a.identity_matches, a.team_matches, a.hardened_runtime, a.ad_hoc);
    printf(",\"entitlementCount\":%u,\"unexpectedEntitlementCount\":%u,\"hypervisorEntitlementTrue\":%u,\"getTaskAllowPresent\":%u,\"appSandboxPresent\":%u,\"entitlementSetExact\":%u",
           a.entitlement_count, a.unexpected_entitlement_count, a.hypervisor_entitlement_true,
           a.get_task_allow_present, a.app_sandbox_present, a.entitlement_set_exact);
    printf(",\"signatureValidationPerformed\":%u,\"signatureValid\":%u,\"effectiveEntitlementChecked\":%u,\"effectiveHypervisorTrue\":%u,\"identifier\":",
           a.signature_validation_performed, a.signature_valid, a.effective_entitlement_checked, a.effective_hypervisor_true);
    string(a.inspected_identifier); printf(",\"team\":"); string(a.inspected_team); putchar('}');
}

static void job_json(const EPRPrimeGuestJob *j) {
    printf("{\"inputCount\":%u,\"priorPredictionOffset\":%d,\"inputTokenIDs\":[", j->inputCount, j->priorPredictionOffset);
    for (uint32_t i = 0; i < j->inputCount && i < 64; ++i) printf("%s%u", i ? "," : "", j->inputTokenIDs[i]);
    printf("]}");
}

static void result_json(const EPRPrimeGuestResult *r) {
    printf("{\"status\":%d,\"stage\":%u,\"failureCode\":%d,\"requestedCount\":%u,\"completedCount\":%u,\"runCount\":%u,\"exceptionCount\":%u,\"inferenceRequestCount\":%u,\"inferenceReturnCount\":%u,\"callbackCount\":%u,\"completionHVCCount\":%u",
           r->status, r->stage, r->failureCode, r->requestedCount, r->completedCount,
           r->runCount, r->exceptionCount, r->inferenceRequestCount, r->inferenceReturnCount,
           r->callbackCount, r->completionHVCCount);
    printf(",\"predictions\":[");
    for (unsigned i = 0; i < 5; ++i) printf("%s%u", i ? "," : "", r->predictions[i]);
    printf("],\"observedJobs\":[");
    for (unsigned i = 0; i < r->inferenceRequestCount && i < 5; ++i) { if (i) putchar(','); job_json(&r->observedJobs[i]); }
    printf("],\"exits\":[");
    for (unsigned i = 0; i < r->runCount && i < 6; ++i) {
        const EPRPrimeGuestExit *e = &r->exits[i];
        if (i) putchar(',');
        printf("{\"runStatus\":%d,\"reason\":%u,\"pc\":%" PRIu64 ",\"cpsr\":%" PRIu64 ",\"syndrome\":%" PRIu64 ",\"virtualAddress\":%" PRIu64 ",\"physicalAddress\":%" PRIu64,
               e->runStatus, e->reason, e->pc, e->cpsr, e->syndrome, e->virtualAddress, e->physicalAddress);
        printf(",\"x0\":%" PRIu64 ",\"x1\":%" PRIu64 ",\"x2\":%" PRIu64 ",\"x3\":%" PRIu64 ",\"x20\":%" PRIu64 ",\"x21\":%" PRIu64 ",\"x22\":%" PRIu64 ",\"x23\":%" PRIu64 ",\"x24\":%" PRIu64 ",\"sctlr\":%" PRIu64 ",\"validated\":%u}",
               e->x0, e->x1, e->x2, e->x3, e->x20, e->x21, e->x22, e->x23, e->x24, e->sctlr, e->validated);
    }
    printf("],\"ownerThreadID\":%" PRIu64 ",\"elapsedNanoseconds\":%" PRIu64,
           r->ownerThreadID, r->elapsedNanoseconds);
#define U(name) printf(",\"" #name "\":%u", r->name)
#define I(name) printf(",\"" #name "\":%d", r->name)
    U(codeByteCount); U(codeImmutableValidated); U(dataGuardValidated); U(registerChecksPassed); U(guestInputChecksPassed);
    I(vmCreateStatus); I(codeMapStatus); I(dataMapStatus); I(vcpuCreateStatus); I(codeProtectStatus); I(dataProtectStatus);
    I(watchdogCreateStatus); I(watchdogJoinStatus); I(watchdogWaitStatus); U(watchdogFired); U(watchdogExitCalls); I(watchdogExitStatus);
    I(vcpuDestroyStatus); I(codeUnmapStatus); I(dataUnmapStatus); I(vmDestroyStatus); I(codeMunmapStatus); I(dataMunmapStatus); U(cleanupComplete);
#undef U
#undef I
    putchar('}');
}

static bool clean_vm(const EPRPrimeGuestResult *r) {
    return r->cleanupComplete == 1 && r->vmCreateStatus == 0 && r->codeMapStatus == 0 && r->dataMapStatus == 0 &&
        r->vcpuCreateStatus == 0 && r->codeProtectStatus == 0 && r->dataProtectStatus == 0 &&
        r->watchdogCreateStatus == 0 && r->watchdogJoinStatus == 0 && r->vcpuDestroyStatus == 0 &&
        r->codeUnmapStatus == 0 && r->dataUnmapStatus == 0 && r->vmDestroyStatus == 0 &&
        r->codeMunmapStatus == 0 && r->dataMunmapStatus == 0;
}

int main(int argc, char **argv) {
    (void)argv;
    alarm(30);
    setvbuf(stdout, NULL, _IONBF, 0);
    if (argc != 1) { fprintf(stderr, "No arguments: fixed mechanism fixtures only.\n"); return 64; }
    const char *names[] = {"invalid_zero_job_count", "guest_rejects_unassigned_feedback",
        "callback_error_no_resume", "final_unassigned_prediction_transport_only",
        "callback_data_mutation_rejected", "callback_deadline_no_resume"};
    unsigned passedCount = 0;
    for (unsigned test = 0; test < 6; ++test) {
        /* Even the pre-VM rejection test records real process admission. Nothing
           reaches epr_prime_guest_run without the normal same-identity admission. */
        PrimeInferenceAdmissionResult admission = prime_inference_inspect_admission();
        if (admission.status != PRIME_INFERENCE_ADMISSION_ADMITTED) {
            printf("{\"type\":\"admission_rejected\",\"test\":%u,\"admission\":", test);
            admission_json(admission); printf("}\n"); return 77;
        }
        EPRPrimeGuestJob jobs[2] = {0};
        jobs[0].inputCount = 2; jobs[0].priorPredictionOffset = -1;
        jobs[0].inputTokenIDs[0] = 16; jobs[0].inputTokenIDs[1] = 32;
        jobs[1].inputCount = 2; jobs[1].priorPredictionOffset = 0;
        jobs[1].inputTokenIDs[0] = 0; jobs[1].inputTokenIDs[1] = 33;
        uint32_t count = test == 0 ? 0 : test == 1 ? 2 : 1;
        Fixture fixture = {.test = test}; EPRPrimeGuestResult result;
        int32_t returnedStatus = epr_prime_guest_run(jobs, count, 16, fixture_callback, &fixture, &result);
        bool base = returnedStatus == result.status && fixture.returned == fixture.calls;
        if (test != 0) base = base && clean_vm(&result) && result.callbackCount == 1 && fixture.calls == 1 &&
            result.inferenceRequestCount == 1 && result.codeImmutableValidated == 1 &&
            result.observedJobs[0].inputCount == 2 && result.observedJobs[0].inputTokenIDs[0] == 16 &&
            result.observedJobs[0].inputTokenIDs[1] == 32;
        if (test > 0 && test < 5) base = base && result.watchdogFired == 0 && result.watchdogExitCalls == 0;
        bool pass = false;
        switch (test) {
            case 0: pass = base && result.status == EPR_PRIME_GUEST_INVALID_REQUEST && result.runCount == 0 &&
                result.vmCreateStatus == INT32_MIN && result.vcpuCreateStatus == INT32_MIN &&
                result.callbackCount == 0 && fixture.calls == 0 && result.cleanupComplete == 1; break;
            case 1: pass = base && result.status == EPR_PRIME_GUEST_INVALID_FEEDBACK && result.runCount == 2 &&
                result.completedCount == 1 && result.predictions[0] == 47 && result.inferenceReturnCount == 1 &&
                result.stage == 1 && result.completionHVCCount == 0 && result.dataGuardValidated == 1; break;
            case 2: pass = base && result.status == EPR_PRIME_GUEST_CALLBACK_ERROR && result.failureCode == -99 &&
                result.runCount == 1 && result.completedCount == 0 && result.inferenceReturnCount == 0 && result.completionHVCCount == 0; break;
            case 3: pass = base && result.status == EPR_PRIME_GUEST_OK && result.runCount == 2 &&
                result.completedCount == 1 && result.predictions[0] == 47 && result.inferenceReturnCount == 1 &&
                result.completionHVCCount == 1 && result.dataGuardValidated == 1; break;
            case 4: pass = base && result.status == EPR_PRIME_GUEST_INVALID_EXIT && result.runCount == 1 &&
                result.completedCount == 0 && result.inferenceReturnCount == 0 && result.dataGuardValidated == 0 &&
                fixture.valueBeforeMutation == 16 && fixture.valueAfterMutation == 17; break;
            case 5: pass = base && result.status == EPR_PRIME_GUEST_DEADLINE && result.runCount == 1 &&
                result.completedCount == 0 && result.inferenceReturnCount == 0 && result.completionHVCCount == 0 &&
                result.watchdogFired == 1 && result.watchdogExitCalls == 1 && result.watchdogExitStatus == 0 &&
                fixture.sleepError == 0 && fixture.finished >= fixture.started &&
                fixture.finished - fixture.started >= UINT64_C(10200000000); break;
        }
        if (pass) ++passedCount;
        printf("{\"type\":\"mechanism_check\",\"test\":%u,\"name\":", test); string(names[test]);
        printf(",\"passed\":%s,\"mechanismOnly\":true,\"modelInvoked\":false,\"semanticInvalid\":%s,\"returnedStatus\":%d,\"admission\":",
               pass ? "true" : "false", test == 3 ? "true" : "false", returnedStatus);
        admission_json(admission); printf(",\"fixture\":{\"calls\":%u,\"returned\":%u,\"callbackReturnedBeforeBridgeReturn\":%s,\"callbackElapsedNanoseconds\":%" PRIu64 ",\"sleepError\":%d,\"valueBeforeMutation\":%u,\"valueAfterMutation\":%u},\"result\":",
            fixture.calls, fixture.returned, fixture.calls == fixture.returned ? "true" : "false",
            fixture.finished >= fixture.started ? fixture.finished - fixture.started : 0,
            fixture.sleepError, fixture.valueBeforeMutation, fixture.valueAfterMutation);
        result_json(&result); printf("}\n");
        /* Do not proceed to another VM after any unexpected mechanism failure. */
        if (!pass) return 1;
    }
    printf("{\"type\":\"summary\",\"passed\":%u,\"expected\":6,\"mechanismOnly\":true,\"modelInvoked\":false}\n", passedCount);
    alarm(0); return passedCount == 6 ? 0 : 1;
}

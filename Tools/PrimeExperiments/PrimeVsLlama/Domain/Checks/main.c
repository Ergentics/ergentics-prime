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

/* ABI 2 mechanism fixtures only. Fixed callback values are not model predictions,
   teacher labels, training inputs or scientific results. No MLX/Metal dependency. */
typedef struct {
    unsigned calls, returned;
    uint32_t values[5];
    EPRPrimeGuestJob seen[5];
} Fixture;

static int32_t fixture_callback(void *opaque, const uint32_t *ids, uint32_t count,
                                 uint32_t *prediction) {
    Fixture *f = opaque;
    if (f->calls >= 5 || count == 0 || count > 64) return -98;
    EPRPrimeGuestJob *seen = &f->seen[f->calls];
    seen->inputCount = count;
    memcpy(seen->inputTokenIDs, ids, count * sizeof(*ids));
    *prediction = f->values[f->calls++];
    ++f->returned;
    return 0;
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
    printf("{\"inputCount\":%u,\"feedbackCount\":%u,\"bindings\":[", j->inputCount, j->feedbackCount);
    for (uint32_t k = 0; k < j->feedbackCount && k < 2; ++k)
        printf("%s{\"inputOffset\":%u,\"sourceJobIndex\":%u}", k ? "," : "", j->bindings[k].inputOffset, j->bindings[k].sourceJobIndex);
    printf("],\"inputTokenIDs\":[");
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
        printf(",\"x0\":%" PRIu64 ",\"x1\":%" PRIu64 ",\"x2\":%" PRIu64 ",\"x3\":%" PRIu64 ",\"x20\":%" PRIu64 ",\"x21\":%" PRIu64 ",\"x22\":%" PRIu64 ",\"x23\":%" PRIu64 ",\"x24\":%" PRIu64 ",\"sctlr\":%" PRIu64 ",\"x11\":%" PRIu64 ",\"x12\":%" PRIu64 ",\"x13\":%" PRIu64 ",\"x28\":%" PRIu64 ",\"validated\":%u}",
               e->x0, e->x1, e->x2, e->x3, e->x20, e->x21, e->x22, e->x23, e->x24, e->sctlr, e->x11, e->x12, e->x13, e->x28, e->validated);
    }
    printf("],\"ownerThreadID\":%" PRIu64 ",\"elapsedNanoseconds\":%" PRIu64,
           r->ownerThreadID, r->elapsedNanoseconds);
#define U(name) printf(",\"" #name "\":%u", r->name)
#define I(name) printf(",\"" #name "\":%d", r->name)
    U(allowedMin); U(allowedCount); U(codeByteCount); U(codeImmutableValidated); U(dataGuardValidated); U(registerChecksPassed); U(guestInputChecksPassed);
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

static bool ids_equal(const EPRPrimeGuestJob *j, const uint32_t *expected, uint32_t count) {
    return j->inputCount == count && memcmp(j->inputTokenIDs, expected, count * sizeof(*expected)) == 0;
}

static bool completed(const EPRPrimeGuestResult *r, const Fixture *f, uint32_t count) {
    if (r->status != EPR_PRIME_GUEST_OK || r->completedCount != count || r->callbackCount != count ||
        r->inferenceRequestCount != count || r->inferenceReturnCount != count ||
        r->runCount != count + 1 || r->completionHVCCount != 1 || f->calls != count) return false;
    for (uint32_t i = 0; i < count; ++i) if (r->predictions[i] != f->values[i]) return false;
    return true;
}

int main(int argc, char **argv) {
    (void)argv;
    alarm(30); setvbuf(stdout, NULL, _IONBF, 0);
    if (argc != 1) { fprintf(stderr, "No arguments: fixed ABI 2 mechanism fixtures only.\n"); return 64; }
    const char *names[] = {"two_distinct_guest_sources", "duplicate_input_offset_rejected_before_vm",
        "self_source_rejected_before_vm", "forward_source_rejected_before_vm",
        "full_vocabulary_224_feedback", "invalid_second_z8_binding_keeps_first_insertion"};
    unsigned passedCount = 0;
    for (unsigned test = 0; test < 6; ++test) {
        PrimeInferenceAdmissionResult admission = prime_inference_inspect_admission();
        if (admission.status != PRIME_INFERENCE_ADMISSION_ADMITTED) {
            printf("{\"type\":\"admission_rejected\",\"test\":%u,\"admission\":", test);
            admission_json(admission); printf("}\n"); return 77;
        }
        EPRPrimeGuestJob jobs[4] = {0};
        for (unsigned i = 0; i < 3; ++i) {
            jobs[i].inputCount = 2; jobs[i].inputTokenIDs[0] = 40 + i;
            jobs[i].inputTokenIDs[1] = 50 + i;
        }
        jobs[3].inputCount = 4; jobs[3].feedbackCount = 2;
        jobs[3].inputTokenIDs[0] = 60; jobs[3].inputTokenIDs[3] = 61;
        jobs[3].bindings[0] = (EPRPrimeGuestFeedbackBinding){1, 1};
        jobs[3].bindings[1] = (EPRPrimeGuestFeedbackBinding){2, 2};
        uint32_t count = 4, minimum = 16, domainCount = 8;
        Fixture fixture = {.values = {17, 19, 22, 20, 0}};
        if (test == 1) jobs[3].bindings[1].inputOffset = 1;
        if (test == 2) jobs[3].bindings[0].sourceJobIndex = 3;
        if (test == 3) {
            jobs[1].feedbackCount = 1; jobs[1].inputTokenIDs[0] = 0;
            jobs[1].bindings[0] = (EPRPrimeGuestFeedbackBinding){0, 2};
        }
        if (test == 4) {
            count = 2; minimum = 0; domainCount = 16384;
            jobs[1] = (EPRPrimeGuestJob){0}; jobs[1].inputCount = 3; jobs[1].feedbackCount = 1;
            jobs[1].inputTokenIDs[0] = 60; jobs[1].inputTokenIDs[2] = 61;
            jobs[1].bindings[0] = (EPRPrimeGuestFeedbackBinding){1, 0};
            fixture.values[0] = 224; fixture.values[1] = 16383;
        }
        if (test == 5) fixture.values[2] = 47;
        EPRPrimeGuestResult result;
        int32_t returnedStatus = epr_prime_guest_run(jobs, count, minimum, domainCount,
                                                    fixture_callback, &fixture, &result);
        bool rejected = test >= 1 && test <= 3;
        bool pass = returnedStatus == result.status && fixture.calls == fixture.returned &&
            result.allowedMin == minimum && result.allowedCount == domainCount;
        if (rejected) {
            pass = pass && result.status == EPR_PRIME_GUEST_INVALID_REQUEST && result.cleanupComplete == 1 &&
                result.vmCreateStatus == INT32_MIN && result.vcpuCreateStatus == INT32_MIN &&
                result.runCount == 0 && result.callbackCount == 0 && fixture.calls == 0 &&
                result.inferenceReturnCount == 0 && result.completedCount == 0;
        } else {
            pass = pass && clean_vm(&result) && result.watchdogFired == 0 && result.watchdogExitCalls == 0 &&
                result.codeImmutableValidated == 1 && result.dataGuardValidated == 1 &&
                result.registerChecksPassed == 1 && result.guestInputChecksPassed == 1;
            for (uint32_t i = 0; i < result.runCount && i < 6; ++i)
                pass = pass && result.exits[i].runStatus == 0 && result.exits[i].validated == 1;
            for (uint32_t i = 0; i < fixture.calls; ++i)
                pass = pass && ids_equal(&result.observedJobs[i], fixture.seen[i].inputTokenIDs, fixture.seen[i].inputCount);
        }
        if (test == 0) {
            const uint32_t expected[] = {60, 19, 22, 61};
            pass = pass && completed(&result, &fixture, 4) && ids_equal(&fixture.seen[3], expected, 4) &&
                result.observedJobs[3].feedbackCount == 2 &&
                result.observedJobs[3].bindings[0].sourceJobIndex == 1 &&
                result.observedJobs[3].bindings[1].sourceJobIndex == 2 &&
                result.exits[3].x11 == 2 && result.exits[3].x12 == 2 && result.exits[3].x13 == 2;
        }
        if (test == 4) {
            const uint32_t expected[] = {60, 224, 61};
            pass = pass && completed(&result, &fixture, 2) && ids_equal(&fixture.seen[1], expected, 3) &&
                result.exits[1].x11 == 1 && result.exits[1].x12 == 1 && result.exits[1].x13 == 0 && result.exits[1].x28 == 16384;
        }
        if (test == 5) {
            const EPRPrimeGuestExit *last = &result.exits[3];
            pass = pass && result.status == EPR_PRIME_GUEST_INVALID_FEEDBACK && result.failureCode == ERANGE &&
                result.stage == 3 && result.completedCount == 3 && result.runCount == 4 &&
                result.callbackCount == 3 && fixture.calls == 3 && result.inferenceRequestCount == 3 &&
                result.inferenceReturnCount == 3 && result.completionHVCCount == 0 &&
                result.predictions[0] == 17 && result.predictions[1] == 19 && result.predictions[2] == 47 &&
                last->syndrome == UINT64_C(0x5a000043) && last->x11 == 1 && last->x12 == 2 && last->x13 == 2 &&
                last->x2 == 47 && last->validated == 1;
            /* validated+dataGuardValidated includes a full-page byte comparison:
               job3[1] must be19 and job3[2] must still be0. No fourth callback. */
        }
        if (pass) ++passedCount;
        printf("{\"type\":\"mechanism_check\",\"test\":%u,\"name\":", test); string(names[test]);
        printf(",\"passed\":%s,\"mechanismOnly\":true,\"modelInvoked\":false,\"returnedStatus\":%d,\"admission\":", pass ? "true" : "false", returnedStatus);
        admission_json(admission);
        printf(",\"request\":{\"allowedMin\":%u,\"allowedCount\":%u,\"jobs\":[", minimum, domainCount);
        for (unsigned i = 0; i < count; ++i) { if (i) putchar(','); job_json(&jobs[i]); }
        printf("]},\"fixture\":{\"calls\":%u,\"returned\":%u,\"returnValues\":[", fixture.calls, fixture.returned);
        for (unsigned i = 0; i < fixture.calls; ++i) printf("%s%u", i ? "," : "", fixture.values[i]);
        printf("],\"observedInputs\":[");
        for (unsigned i = 0; i < fixture.calls; ++i) { if (i) putchar(','); job_json(&fixture.seen[i]); }
        printf("]},\"invalidSecondBindingFullPagePrefixValidated\":%s,\"result\":", test == 5 && pass ? "true" : "false");
        result_json(&result); printf("}\n");
        if (!pass) return 1;
    }
    printf("{\"type\":\"summary\",\"passed\":%u,\"expected\":6,\"mechanismOnly\":true,\"modelInvoked\":false}\n", passedCount);
    alarm(0); return passedCount == 6 ? 0 : 1;
}

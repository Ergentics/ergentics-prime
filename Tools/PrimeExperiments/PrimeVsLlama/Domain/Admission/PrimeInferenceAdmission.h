#ifndef PRIME_INFERENCE_ADMISSION_H
#define PRIME_INFERENCE_ADMISSION_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Inspects this process only. No guest, model, signing, keychain mutation,
 * external network access, or filesystem permission grant is performed. */
enum {
    PRIME_INFERENCE_ADMISSION_ERROR = -1,
    PRIME_INFERENCE_ADMISSION_REJECTED = 0,
    PRIME_INFERENCE_ADMISSION_ADMITTED = 1
};
enum {
    PRIME_INFERENCE_ADMISSION_REASON_NONE = 0,
    PRIME_INFERENCE_ADMISSION_REASON_INSPECTION = 1,
    PRIME_INFERENCE_ADMISSION_REASON_IDENTITY = 2,
    PRIME_INFERENCE_ADMISSION_REASON_FLAGS = 3,
    PRIME_INFERENCE_ADMISSION_REASON_ENTITLEMENTS = 4,
    PRIME_INFERENCE_ADMISSION_REASON_SIGNATURE = 5,
    PRIME_INFERENCE_ADMISSION_REASON_EFFECTIVE_ENTITLEMENT = 6
};

typedef struct {
    uint32_t schema_version;
    int32_t status;
    uint32_t reason;
    int32_t security_status;
    int64_t effective_entitlement_error;
    uint64_t signature_flags;
    uint32_t identity_matches;
    uint32_t team_matches;
    uint32_t hardened_runtime;
    uint32_t ad_hoc;
    uint32_t entitlement_count;
    uint32_t unexpected_entitlement_count;
    uint32_t hypervisor_entitlement_true;
    uint32_t get_task_allow_present;
    uint32_t app_sandbox_present;
    uint32_t entitlement_set_exact;
    uint32_t signature_validation_performed;
    uint32_t signature_valid;
    uint32_t effective_entitlement_checked;
    uint32_t effective_hypervisor_true;
    char inspected_identifier[128];
    char inspected_team[32];
} PrimeInferenceAdmissionResult;

/* Requires exact identifier com.ergentics.prime.vcpu-inference, team
 * ZCQ435U8JP, Apple generic anchor, hardened runtime, and exactly one signed
 * entitlement: Boolean true com.apple.security.hypervisor. This is an
 * unsandboxed user-level helper; no App Sandbox containment is claimed. */
PrimeInferenceAdmissionResult prime_inference_inspect_admission(void);

#ifdef __cplusplus
}
#endif
#endif

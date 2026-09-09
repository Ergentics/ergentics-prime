#include "PrimeInferenceAdmission.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <Security/SecTask.h>
#include <limits.h>

static int copy_string(CFTypeRef value, char *destination, CFIndex capacity) {
    destination[0] = '\0';
    if (!value || CFGetTypeID(value) != CFStringGetTypeID()) return 0;
    int copied = CFStringGetCString((CFStringRef)value, destination, capacity,
                                   kCFStringEncodingUTF8);
    destination[capacity - 1] = '\0';
    if (!copied) destination[0] = '\0';
    return copied;
}

static int true_boolean(CFTypeRef value) {
    return value && CFGetTypeID(value) == CFBooleanGetTypeID() &&
        CFBooleanGetValue((CFBooleanRef)value);
}

static void inspect_entitlement(const void *key, const void *value, void *context) {
    PrimeInferenceAdmissionResult *result = context;
    if (CFEqual(key, CFSTR("com.apple.security.hypervisor"))) {
        result->hypervisor_entitlement_true = (uint32_t)true_boolean(value);
    } else {
        ++result->unexpected_entitlement_count;
    }
    if (CFEqual(key, CFSTR("com.apple.security.get-task-allow")) ||
        CFEqual(key, CFSTR("get-task-allow"))) result->get_task_allow_present = 1;
    if (CFEqual(key, CFSTR("com.apple.security.app-sandbox")))
        result->app_sandbox_present = 1;
}

PrimeInferenceAdmissionResult prime_inference_inspect_admission(void) {
    PrimeInferenceAdmissionResult result = {0};
    result.schema_version = 1;
    result.status = PRIME_INFERENCE_ADMISSION_ERROR;
    result.reason = PRIME_INFERENCE_ADMISSION_REASON_INSPECTION;
    SecCodeRef code = NULL;
    SecRequirementRef requirement = NULL;
    CFDictionaryRef information = NULL;
    SecTaskRef task = NULL;
    CFTypeRef effective = NULL;
    CFErrorRef effective_error = NULL;

    OSStatus status = SecCodeCopySelf(kSecCSDefaultFlags, &code);
    if (status != errSecSuccess) goto api_error;
    status = SecCodeCopySigningInformation((SecStaticCodeRef)code,
                                          kSecCSSigningInformation, &information);
    if (status != errSecSuccess) goto api_error;
    if (!information || CFGetTypeID(information) != CFDictionaryGetTypeID())
        goto done;

    CFTypeRef identifier = CFDictionaryGetValue(information, kSecCodeInfoIdentifier);
    CFTypeRef team = CFDictionaryGetValue(information, kSecCodeInfoTeamIdentifier);
    result.identity_matches = (uint32_t)(copy_string(identifier,
        result.inspected_identifier, sizeof(result.inspected_identifier)) &&
        CFEqual(identifier, CFSTR("com.ergentics.prime.vcpu-inference")));
    result.team_matches = (uint32_t)(copy_string(team, result.inspected_team,
        sizeof(result.inspected_team)) && CFEqual(team, CFSTR("ZCQ435U8JP")));

    CFTypeRef flags = CFDictionaryGetValue(information, kSecCodeInfoFlags);
    int64_t bits = 0;
    if (!flags || CFGetTypeID(flags) != CFNumberGetTypeID() ||
        !CFNumberGetValue((CFNumberRef)flags, kCFNumberSInt64Type, &bits) || bits < 0)
        goto done;
    result.signature_flags = (uint64_t)bits;
    result.hardened_runtime = (bits & kSecCodeSignatureRuntime) != 0;
    result.ad_hoc = (bits & kSecCodeSignatureAdhoc) != 0;

    CFTypeRef entitlements = CFDictionaryGetValue(information, kSecCodeInfoEntitlementsDict);
    if (entitlements && CFGetTypeID(entitlements) == CFDictionaryGetTypeID()) {
        CFIndex count = CFDictionaryGetCount((CFDictionaryRef)entitlements);
        if (count < 0 || (uint64_t)count > UINT32_MAX) goto done;
        result.entitlement_count = (uint32_t)count;
        CFDictionaryApplyFunction((CFDictionaryRef)entitlements, inspect_entitlement, &result);
        result.entitlement_set_exact = result.entitlement_count == 1 &&
            result.unexpected_entitlement_count == 0 && result.hypervisor_entitlement_true;
    }

    result.status = PRIME_INFERENCE_ADMISSION_REJECTED;
    if (!result.identity_matches || !result.team_matches) {
        result.reason = PRIME_INFERENCE_ADMISSION_REASON_IDENTITY;
        goto done;
    }
    if (!result.hardened_runtime || result.ad_hoc) {
        result.reason = PRIME_INFERENCE_ADMISSION_REASON_FLAGS;
        goto done;
    }
    if (!result.entitlement_set_exact) {
        result.reason = PRIME_INFERENCE_ADMISSION_REASON_ENTITLEMENTS;
        goto done;
    }
    status = SecRequirementCreateWithString(CFSTR(
        "anchor apple generic and identifier \"com.ergentics.prime.vcpu-inference\" "
        "and certificate leaf[subject.OU] = \"ZCQ435U8JP\""),
        kSecCSDefaultFlags, &requirement);
    if (status != errSecSuccess) goto api_error;
    result.signature_validation_performed = 1;
    status = SecCodeCheckValidity(code, kSecCSNoNetworkAccess, requirement);
    result.security_status = status;
    if (status != errSecSuccess) {
        result.reason = PRIME_INFERENCE_ADMISSION_REASON_SIGNATURE;
        goto done;
    }
    result.signature_valid = 1;

    task = SecTaskCreateFromSelf(NULL);
    if (!task) {
        status = errSecAllocate;
        goto api_error;
    }
    result.effective_entitlement_checked = 1;
    effective = SecTaskCopyValueForEntitlement(task,
        CFSTR("com.apple.security.hypervisor"), &effective_error);
    result.effective_hypervisor_true = (uint32_t)true_boolean(effective);
    if (effective_error) result.effective_entitlement_error = CFErrorGetCode(effective_error);
    if (effective_error || !result.effective_hypervisor_true) {
        result.reason = PRIME_INFERENCE_ADMISSION_REASON_EFFECTIVE_ENTITLEMENT;
        goto done;
    }
    result.status = PRIME_INFERENCE_ADMISSION_ADMITTED;
    result.reason = PRIME_INFERENCE_ADMISSION_REASON_NONE;
    goto done;

api_error:
    result.status = PRIME_INFERENCE_ADMISSION_ERROR;
    result.reason = PRIME_INFERENCE_ADMISSION_REASON_INSPECTION;
    result.security_status = status;
done:
    if (effective_error) CFRelease(effective_error);
    if (effective) CFRelease(effective);
    if (task) CFRelease(task);
    if (information) CFRelease(information);
    if (requirement) CFRelease(requirement);
    if (code) CFRelease(code);
    return result;
}

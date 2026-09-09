#include "PrimeInferenceAdmission.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <Security/SecTask.h>
#include <unistd.h>
#include <string.h>

#ifndef PRIME_SERVICE_IDENTIFIER
#error "Build must select exactly one app service identity"
#endif

static int is_true(CFTypeRef x) {
    return x && CFGetTypeID(x) == CFBooleanGetTypeID() && CFBooleanGetValue(x);
}
static int same(CFTypeRef a, CFStringRef b) {
    return a && CFGetTypeID(a) == CFStringGetTypeID() && CFEqual(a,b);
}
static void copy_string(CFTypeRef x, char *out, size_t capacity) {
    if (!x || CFGetTypeID(x) != CFStringGetTypeID() ||
        !CFStringGetCString(x,out,(CFIndex)capacity,kCFStringEncodingUTF8)) out[0]=0;
    out[capacity-1]=0;
}

// Same closed identity metadata exceptions as the existing app-only lease.
// These are signer-added identifiers, not additional runtime permissions.
static int entitlements_valid(CFDictionaryRef info, CFStringRef identifier,
                              int parent, PrimeInferenceAdmissionResult *r) {
    CFTypeRef value=CFDictionaryGetValue(info,kSecCodeInfoEntitlementsDict);
    if (!value || CFGetTypeID(value)!=CFDictionaryGetTypeID()) return 0;
    CFDictionaryRef ent=value;
    const CFStringRef helperKeys[]={CFSTR("com.apple.security.app-sandbox"),
        CFSTR("com.apple.security.inherit"),CFSTR("com.apple.security.hypervisor")};
    const CFStringRef parentKeys[]={CFSTR("com.apple.security.app-sandbox"),
        CFSTR("com.apple.security.files.user-selected.read-write"),
        CFSTR("com.apple.security.hypervisor"),CFSTR("com.apple.security.virtualization")};
    const CFStringRef *required=parent ? parentKeys : helperKeys;
    size_t count=parent ? 4 : 3;
    CFIndex n=CFDictionaryGetCount(ent);
    if (n<0 || n>16) return 0;
    const void *keys[16],*values[16];
    CFDictionaryGetKeysAndValues(ent,keys,values);
    int valid=1;
    if (!parent) {
        r->entitlement_count=(uint32_t)n;
        r->hypervisor_entitlement_true=is_true(CFDictionaryGetValue(ent,helperKeys[2]));
        r->app_sandbox_present=CFDictionaryContainsKey(ent,helperKeys[0]);
        r->get_task_allow_present=CFDictionaryContainsKey(ent,CFSTR("com.apple.security.get-task-allow")) ||
            CFDictionaryContainsKey(ent,CFSTR("get-task-allow"));
    }
    for (size_t i=0;i<count;i++) if (!is_true(CFDictionaryGetValue(ent,required[i]))) valid=0;
    CFStringRef application=CFStringCreateWithFormat(NULL,NULL,CFSTR("ZCQ435U8JP.%@"),identifier);
    if (!application) return 0;
    for (CFIndex i=0;i<n;i++) {
        int known=0;
        for (size_t j=0;j<count;j++) if (CFEqual(keys[i],required[j])) known=1;
        if (known) continue;
        if (CFEqual(keys[i],CFSTR("com.apple.developer.team-identifier")) && same(values[i],CFSTR("ZCQ435U8JP"))) continue;
        if ((CFEqual(keys[i],CFSTR("com.apple.application-identifier")) ||
             CFEqual(keys[i],CFSTR("application-identifier"))) && same(values[i],application)) continue;
        valid=0;
        if (!parent) r->unexpected_entitlement_count++;
    }
    CFRelease(application);
    return valid;
}

static int inspect(SecCodeRef code, CFStringRef identifier, int parent,
                   PrimeInferenceAdmissionResult *r) {
    SecStaticCodeRef staticCode=NULL;
    CFDictionaryRef info=NULL;
    SecRequirementRef requirement=NULL;
    CFStringRef rule=NULL;
    int ok=0;
    OSStatus status=SecCodeCopyStaticCode(code,kSecCSDefaultFlags,&staticCode);
    if (status!=errSecSuccess) goto done;
    status=SecCodeCopySigningInformation(staticCode,kSecCSSigningInformation,&info);
    if (status!=errSecSuccess || !info) goto done;
    CFTypeRef id=CFDictionaryGetValue(info,kSecCodeInfoIdentifier);
    CFTypeRef team=CFDictionaryGetValue(info,kSecCodeInfoTeamIdentifier);
    int identity=same(id,identifier),teamOK=same(team,CFSTR("ZCQ435U8JP"));
    if (!parent) {
        copy_string(id,r->inspected_identifier,sizeof(r->inspected_identifier));
        copy_string(team,r->inspected_team,sizeof(r->inspected_team));
        r->identity_matches=identity;r->team_matches=teamOK;
    } else r->parent_identity_matches=identity && teamOK;
    r->reason=PRIME_INFERENCE_ADMISSION_REASON_IDENTITY;
    if (!identity || !teamOK) goto done;
    CFTypeRef flags=CFDictionaryGetValue(info,kSecCodeInfoFlags);
    int64_t bits=0;
    r->reason=PRIME_INFERENCE_ADMISSION_REASON_FLAGS;
    if (!flags || CFGetTypeID(flags)!=CFNumberGetTypeID() ||
        !CFNumberGetValue(flags,kCFNumberSInt64Type,&bits) || bits<0) goto done;
    int hardened=(bits & kSecCodeSignatureRuntime)!=0;
    int adhoc=(bits & kSecCodeSignatureAdhoc)!=0;
    if (!parent) {r->signature_flags=(uint64_t)bits;r->hardened_runtime=hardened;r->ad_hoc=adhoc;}
    if (!hardened || adhoc) goto done;
    int exact=entitlements_valid(info,identifier,parent,r);
    if (parent) r->parent_entitlement_set_exact=exact; else r->entitlement_set_exact=exact;
    r->reason=PRIME_INFERENCE_ADMISSION_REASON_ENTITLEMENTS;
    if (!exact) goto done;
    rule=CFStringCreateWithFormat(NULL,NULL,
        CFSTR("anchor apple generic and identifier \"%@\" and certificate leaf[subject.OU] = \"ZCQ435U8JP\""),identifier);
    if (!rule) {status=errSecAllocate;goto done;}
    status=SecRequirementCreateWithString(rule,kSecCSDefaultFlags,&requirement);
    if (status!=errSecSuccess) goto done;
    if (!parent) r->signature_validation_performed=1;
    r->reason=PRIME_INFERENCE_ADMISSION_REASON_SIGNATURE;
    status=SecCodeCheckValidity(code,kSecCSNoNetworkAccess,requirement);
    if (status!=errSecSuccess) goto done;
    if (parent) r->parent_signature_valid=1; else r->signature_valid=1;
    ok=1;
done:
    r->security_status=status;
    if (rule) CFRelease(rule);
    if (requirement) CFRelease(requirement);
    if (info) CFRelease(info);
    if (staticCode) CFRelease(staticCode);
    return ok;
}

PrimeInferenceAdmissionResult prime_inference_inspect_admission(void) {
    PrimeInferenceAdmissionResult r={0};r.schema_version=2;
    r.status=PRIME_INFERENCE_ADMISSION_REJECTED;r.reason=PRIME_INFERENCE_ADMISSION_REASON_INSPECTION;
    const pid_t parent=getppid();r.parent_pid=parent;
    SecCodeRef own=NULL,caller=NULL;
    SecTaskRef task=NULL;
    CFNumberRef pid=NULL;
    CFDictionaryRef attributes=NULL;
    if (parent<=1 || getuid()!=geteuid()) goto done;
    OSStatus status=SecCodeCopySelf(kSecCSDefaultFlags,&own);
    if (status!=errSecSuccess) {r.security_status=status;goto done;}
    if (!inspect(own,CFSTR(PRIME_SERVICE_IDENTIFIER),0,&r)) goto done;
    pid=CFNumberCreate(NULL,kCFNumberIntType,&parent);
    if (!pid) goto done;
    const void *key=kSecGuestAttributePid,*value=pid;
    attributes=CFDictionaryCreate(NULL,&key,&value,1,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    if (!attributes) goto done;
    status=SecCodeCopyGuestWithAttributes(NULL,attributes,kSecCSDefaultFlags,&caller);
    if (status!=errSecSuccess) {r.security_status=status;goto done;}
    if (!inspect(caller,CFSTR("com.ergentics.provenance"),1,&r)) goto done;
    task=SecTaskCreateFromSelf(NULL);
    if (!task) goto done;
    const CFStringRef keys[]={CFSTR("com.apple.security.hypervisor"),CFSTR("com.apple.security.app-sandbox"),CFSTR("com.apple.security.inherit")};
    uint32_t *observations[]={&r.effective_hypervisor_true,&r.effective_app_sandbox_true,&r.effective_inherit_true};
    r.effective_entitlement_checked=1;
    r.reason=PRIME_INFERENCE_ADMISSION_REASON_EFFECTIVE_ENTITLEMENT;
    for (int i=0;i<3;i++) {
        CFErrorRef error=NULL;
        CFTypeRef effective=SecTaskCopyValueForEntitlement(task,keys[i],&error);
        *observations[i]=is_true(effective);
        int failed=error || !*observations[i];
        if (error) {r.effective_entitlement_error=CFErrorGetCode(error);CFRelease(error);}
        if (effective) CFRelease(effective);
        if (failed) goto done;
    }
    r.parent_unchanged=getppid()==parent;
    if (!r.parent_unchanged) goto done;
    r.status=PRIME_INFERENCE_ADMISSION_ADMITTED;r.reason=PRIME_INFERENCE_ADMISSION_REASON_NONE;
done:
    if (task) CFRelease(task);
    if (attributes) CFRelease(attributes);
    if (pid) CFRelease(pid);
    if (caller) CFRelease(caller);
    if (own) CFRelease(own);
    return r;
}

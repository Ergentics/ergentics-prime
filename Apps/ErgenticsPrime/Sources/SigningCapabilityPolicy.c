#include "SigningCapabilityPolicy.h"

struct capability_check { CFStringRef team; CFStringRef application; unsigned required; int allowed; };
static void check_capability(const void *key, const void *value, void *context) {
    struct capability_check *check = context;
    if (CFGetTypeID(key) != CFStringGetTypeID()) { check->allowed = 0; return; }
    unsigned bit = 0;
    if (CFEqual(key, CFSTR("com.apple.security.app-sandbox"))) bit = 1;
    else if (CFEqual(key, CFSTR("com.apple.security.files.user-selected.read-write"))) bit = 2;
    else if (CFEqual(key, CFSTR("com.apple.security.hypervisor"))) bit = 4;
    else if (CFEqual(key, CFSTR("com.apple.security.virtualization"))) bit = 8;
    if (bit) {
        if (CFGetTypeID(value) != CFBooleanGetTypeID() || !CFBooleanGetValue(value)) check->allowed = 0;
        check->required |= bit;
    } else if (CFEqual(key, CFSTR("com.apple.developer.team-identifier"))) {
        if (CFGetTypeID(value) != CFStringGetTypeID() || !CFEqual(value, check->team)) check->allowed = 0;
    } else if (CFEqual(key, CFSTR("com.apple.application-identifier")) || CFEqual(key, CFSTR("application-identifier"))) {
        if (CFGetTypeID(value) != CFStringGetTypeID() || !CFEqual(value, check->application)) check->allowed = 0;
    } else check->allowed = 0;
}

int epr_signing_capabilities_allowed(CFDictionaryRef entitlements, CFStringRef team, CFStringRef application) {
    if (!entitlements || !team || !application || CFGetTypeID(entitlements) != CFDictionaryGetTypeID() ||
        CFGetTypeID(team) != CFStringGetTypeID() || CFGetTypeID(application) != CFStringGetTypeID()) return 0;
    struct capability_check check = { team, application, 0, 1 };
    CFDictionaryApplyFunction(entitlements, check_capability, &check);
    return check.allowed && check.required == 15;
}

#ifndef ERGENTICS_SIGNING_CAPABILITY_POLICY_H
#define ERGENTICS_SIGNING_CAPABILITY_POLICY_H
#include <CoreFoundation/CoreFoundation.h>
/* Pure dictionary validation shared by live signing admission and unit tests. */
int epr_signing_capabilities_allowed(CFDictionaryRef entitlements, CFStringRef team, CFStringRef application);
#endif

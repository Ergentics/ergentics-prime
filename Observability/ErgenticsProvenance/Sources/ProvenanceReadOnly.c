#include "ProvenanceReadOnly.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <Security/SecTask.h>
#include <Hypervisor/Hypervisor.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <unistd.h>

enum { leaf_count = 12, leaf_cap = 65536 };
static const char *const leaf_names[leaf_count] = {
    "00-start.json", "candidate-json.bin", "candidate-cbor.bin",
    "10-json-verifier.json", "11-json-graph.json", "12-json-roundtrip.json",
    "20-cbor-verifier.json", "21-cbor-graph.json", "22-cbor-roundtrip.json",
    "30-join-receipt.json", "31-authoritative-graph.json", "90-terminal.json"
};
struct EPRSnapshot {
    int root;
    int files[leaf_count];
    struct stat root_stat;
    struct stat file_stat[leaf_count];
    unsigned char *bytes[leaf_count];
    size_t sizes[leaf_count];
};

static int same(const struct stat *a, const struct stat *b) {
    return a->st_dev == b->st_dev && a->st_ino == b->st_ino &&
        a->st_mode == b->st_mode && a->st_uid == b->st_uid && a->st_gid == b->st_gid &&
        a->st_nlink == b->st_nlink && a->st_size == b->st_size && a->st_flags == b->st_flags &&
        a->st_mtimespec.tv_sec == b->st_mtimespec.tv_sec && a->st_mtimespec.tv_nsec == b->st_mtimespec.tv_nsec &&
        a->st_ctimespec.tv_sec == b->st_ctimespec.tv_sec && a->st_ctimespec.tv_nsec == b->st_ctimespec.tv_nsec;
}
static int inventory(int root) {
    int fd = openat(root, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd < 0) return -1;
    DIR *directory = fdopendir(fd);
    if (!directory) { int e = errno; close(fd); errno = e; return -1; }
    unsigned seen = 0;
    int e = 0;
    for (;;) {
        errno = 0;
        struct dirent *entry = readdir(directory);
        if (!entry) { e = errno; break; }
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) continue;
        size_t i;
        for (i = 0; i < leaf_count; ++i) if (!strcmp(entry->d_name, leaf_names[i])) break;
        if (i == leaf_count || (seen & (1U << i))) { e = EINVAL; break; }
        seen |= 1U << i;
    }
    if (!e && seen != (1U << leaf_count) - 1U) e = EINVAL;
    if (closedir(directory) && !e) e = errno;
    if (e) { errno = e; return -1; }
    return 0;
}
static int path_valid(const char *path) {
    if (!path || path[0] != '/') return 0;
    size_t n = strnlen(path, PATH_MAX + 1);
    if (n < 2 || n > PATH_MAX || path[n - 1] == '/') return 0;
    for (const char *p = path + 1; *p;) {
        size_t k = strcspn(p, "/");
        if (!k || (k == 1 && p[0] == '.') || (k == 2 && p[0] == '.' && p[1] == '.')) return 0;
        p += k;
        if (*p) ++p;
    }
    return 1;
}
void epr_snapshot_free(EPRSnapshot *s) {
    if (!s) return;
    for (size_t i = 0; i < leaf_count; ++i) {
        if (s->files[i] >= 0) close(s->files[i]);
        free(s->bytes[i]);
    }
    if (s->root >= 0) close(s->root);
    free(s);
}
EPRSnapshot *epr_read_snapshot(const char *path, int *error) {
    if (!error) { errno = EINVAL; return NULL; }
    *error = 0;
    if (!path_valid(path)) { *error = EINVAL; return NULL; }
    EPRSnapshot *s = calloc(1, sizeof(*s));
    if (!s) { *error = ENOMEM; return NULL; }
    s->root = -1;
    for (size_t i = 0; i < leaf_count; ++i) s->files[i] = -1;
    struct stat named, current;
    s->root = open(path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (s->root < 0 || fstat(s->root, &s->root_stat) || lstat(path, &named)) goto failed;
    if (!S_ISDIR(s->root_stat.st_mode) || (s->root_stat.st_mode & 07777) != 0700 ||
        s->root_stat.st_uid != geteuid() || !same(&s->root_stat, &named)) { errno = EACCES; goto failed; }
    if (inventory(s->root)) goto failed;
    for (size_t i = 0; i < leaf_count; ++i) {
        s->files[i] = openat(s->root, leaf_names[i], O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK);
        if (s->files[i] < 0 || fstat(s->files[i], &s->file_stat[i]) ||
            fstatat(s->root, leaf_names[i], &named, AT_SYMLINK_NOFOLLOW)) goto failed;
        struct stat *m = &s->file_stat[i];
        if (!S_ISREG(m->st_mode) || (m->st_mode & 07777) != 0600 || m->st_uid != geteuid() ||
            m->st_nlink != 1 || m->st_size < 0 || m->st_size > leaf_cap || !same(m, &named)) {
            errno = EACCES; goto failed;
        }
        s->sizes[i] = (size_t)m->st_size;
        s->bytes[i] = malloc(s->sizes[i] + 1);
        if (!s->bytes[i]) { errno = ENOMEM; goto failed; }
        size_t offset = 0;
        while (offset < s->sizes[i]) {
            ssize_t got = read(s->files[i], s->bytes[i] + offset, s->sizes[i] - offset);
            if (got < 0 && errno == EINTR) continue;
            if (got <= 0) { if (!got) errno = EIO; goto failed; }
            offset += (size_t)got;
        }
        unsigned char extra;
        ssize_t eof;
        do { eof = read(s->files[i], &extra, 1); } while (eof < 0 && errno == EINTR);
        if (eof != 0) { if (eof > 0) errno = EFBIG; goto failed; }
    }
    if (inventory(s->root)) goto failed;
    for (size_t i = 0; i < leaf_count; ++i) {
        if (fstat(s->files[i], &current) || fstatat(s->root, leaf_names[i], &named, AT_SYMLINK_NOFOLLOW)) goto failed;
        if (!same(&s->file_stat[i], &current) || !same(&s->file_stat[i], &named)) { errno = ESTALE; goto failed; }
    }
    if (fstat(s->root, &current) || lstat(path, &named)) goto failed;
    if (!same(&s->root_stat, &current) || !same(&s->root_stat, &named)) { errno = ESTALE; goto failed; }
    return s;
failed:
    *error = errno ? errno : EIO;
    epr_snapshot_free(s);
    return NULL;
}
size_t epr_snapshot_count(const EPRSnapshot *s) { return s ? leaf_count : 0; }
const char *epr_snapshot_name(const EPRSnapshot *s, size_t i) { return s && i < leaf_count ? leaf_names[i] : NULL; }
const unsigned char *epr_snapshot_bytes(const EPRSnapshot *s, size_t i) { return s && i < leaf_count ? s->bytes[i] : NULL; }
size_t epr_snapshot_size(const EPRSnapshot *s, size_t i) { return s && i < leaf_count ? s->sizes[i] : 0; }

struct entitlement_check { CFStringRef team; CFStringRef app; int allowed; unsigned required; };
static void check_entitlement(const void *key, const void *value, void *context) {
    struct entitlement_check *c = context;
    if (CFGetTypeID(key) != CFStringGetTypeID()) { c->allowed = 0; return; }
    unsigned bit = 0;
    if (CFEqual(key, CFSTR("com.apple.security.app-sandbox"))) bit = 1;
    else if (CFEqual(key, CFSTR("com.apple.security.files.user-selected.read-only"))) bit = 2;
    else if (CFEqual(key, CFSTR("com.apple.security.hypervisor"))) bit = 4;
    if (bit) {
        if (CFGetTypeID(value) != CFBooleanGetTypeID() || !CFBooleanGetValue(value)) c->allowed = 0;
        c->required |= bit;
    } else if (CFEqual(key, CFSTR("com.apple.developer.team-identifier"))) {
        if (!CFEqual(value, c->team)) c->allowed = 0;
    } else if (CFEqual(key, CFSTR("com.apple.application-identifier")) || CFEqual(key, CFSTR("application-identifier"))) {
        if (!CFEqual(value, c->app)) c->allowed = 0;
    } else c->allowed = 0;
}
int epr_admit_signing(const char *expected_team, int *error) {
    if (!error) return -1;
    *error = 0;
    if (!expected_team || strlen(expected_team) != 10) return 0;
    for (size_t i = 0; i < 10; ++i) {
        unsigned char c = (unsigned char)expected_team[i];
        if (!((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'))) return 0;
    }
    SecCodeRef code = NULL;
    SecRequirementRef requirement = NULL;
    CFDictionaryRef information = NULL;
    CFStringRef team = CFStringCreateWithCString(NULL, expected_team, kCFStringEncodingASCII);
    CFStringRef app = team ? CFStringCreateWithFormat(NULL, NULL, CFSTR("%@.com.ergentics.provenance"), team) : NULL;
    CFStringRef rule = team ? CFStringCreateWithFormat(NULL, NULL,
        CFSTR("anchor apple generic and identifier \"com.ergentics.provenance\" and certificate leaf[subject.OU] = \"%@\""), team) : NULL;
    OSStatus status = errSecSuccess;
    int result = 0;
    if (!team || !app || !rule) { *error = ENOMEM; result = -1; goto done; }
    status = SecCodeCopySelf(kSecCSDefaultFlags, &code);
    if (status) goto api_failed;
    status = SecRequirementCreateWithString(rule, kSecCSDefaultFlags, &requirement);
    if (status) goto api_failed;
    status = SecCodeCheckValidity(code, kSecCSNoNetworkAccess, requirement);
    if (status) goto api_failed;
    status = SecCodeCopySigningInformation((SecStaticCodeRef)code, kSecCSSigningInformation, &information);
    if (status) goto api_failed;
    CFTypeRef actual = CFDictionaryGetValue(information, kSecCodeInfoTeamIdentifier);
    CFTypeRef identifier = CFDictionaryGetValue(information, kSecCodeInfoIdentifier);
    CFTypeRef flags = CFDictionaryGetValue(information, kSecCodeInfoFlags);
    CFTypeRef entitlements = CFDictionaryGetValue(information, kSecCodeInfoEntitlementsDict);
    int64_t flag_bits = 0;
    if (!actual || !CFEqual(actual, team) || !identifier || !CFEqual(identifier, CFSTR("com.ergentics.provenance")) ||
        !flags || CFGetTypeID(flags) != CFNumberGetTypeID() || !CFNumberGetValue(flags, kCFNumberSInt64Type, &flag_bits) ||
        !(flag_bits & kSecCodeSignatureRuntime) || !entitlements || CFGetTypeID(entitlements) != CFDictionaryGetTypeID()) goto done;
    struct entitlement_check check = { team, app, 1, 0 };
    CFDictionaryApplyFunction(entitlements, check_entitlement, &check);
    result = check.allowed && check.required == 7;
    if (result) {
        SecTaskRef task = SecTaskCreateFromSelf(NULL);
        if (!task) { *error = ENOMEM; result = -1; goto done; }
        const CFStringRef keys[] = { CFSTR("com.apple.security.app-sandbox"),
            CFSTR("com.apple.security.files.user-selected.read-only"), CFSTR("com.apple.security.hypervisor") };
        for (size_t i = 0; i < 3; ++i) {
            CFErrorRef task_error = NULL;
            CFTypeRef value = SecTaskCopyValueForEntitlement(task, keys[i], &task_error);
            if (!value || CFGetTypeID(value) != CFBooleanGetTypeID() || !CFBooleanGetValue(value)) result = 0;
            if (task_error) { *error = (int)CFErrorGetCode(task_error); result = -1; CFRelease(task_error); }
            if (value) CFRelease(value);
            if (result != 1) break;
        }
        CFRelease(task);
    }
    goto done;
api_failed:
    *error = (int)status;
    result = -1;
done:
    if (information) CFRelease(information);
    if (requirement) CFRelease(requirement);
    if (code) CFRelease(code);
    if (rule) CFRelease(rule);
    if (app) CFRelease(app);
    if (team) CFRelease(team);
    return result;
}

EPRHypervisorCapabilities epr_hypervisor_capabilities(void) {
    EPRHypervisorCapabilities value = {0};
    size_t size = sizeof(value.host_supported);
    value.support_status = sysctlbyname("kern.hv_support", &value.host_supported, &size, NULL, 0);
    value.support_size = size;
    if (value.support_status != 0) value.support_error = errno;
    else if (size != sizeof(value.host_supported) || (value.host_supported != 0 && value.host_supported != 1)) value.support_error = EINVAL;
    value.vcpu_status = (int32_t)HV_DENIED;
    value.ipa_status = (int32_t)HV_DENIED;
    // A second self admission makes the native API fail closed even if a future
    // UI caller skips its first check. This slice binds only the resolved Team.
    int error = 0;
    value.signing_admitted = epr_admit_signing("ZCQ435U8JP", &error);
    value.signing_error = error;
    if (value.signing_admitted != 1 || value.support_error || value.host_supported != 1) return value;
    value.queries_entered = 2;
    value.vcpu_status = (int32_t)hv_vm_get_max_vcpu_count(&value.max_vcpus);
    value.ipa_status = (int32_t)hv_vm_config_get_max_ipa_size(&value.max_ipa_bits);
    if (value.vcpu_status != (int32_t)HV_SUCCESS) value.max_vcpus = 0;
    if (value.ipa_status != (int32_t)HV_SUCCESS) value.max_ipa_bits = 0;
    return value;
}

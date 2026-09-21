#ifndef ERGENTICS_PROVENANCE_READ_ONLY_H
#define ERGENTICS_PROVENANCE_READ_ONLY_H

#include <stddef.h>
#include <stdint.h>
#include "HypervisorGuest.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Closed, read-only admission of the twelve historical receipt leaves.
 * The caller must hold its explicit user-selected, read-only sandbox grant
 * throughout this call. No bookmark, fallback path, or container migration is
 * performed. The absolute path must have no trailing slash or dot components.
 *
 * Each leaf is at most 65,536 bytes. All leaf descriptors and bytes remain held
 * through the complete final metadata, named-entry, and directory-inventory
 * joins. A successful snapshot owns those descriptors until snapshot_free.
 * Accessor pointers are immutable borrows, valid only until snapshot_free.
 *
 * Admission is a set of bounded observations, not a watch or a filesystem
 * transaction: ancestors are not descriptor-held; a transient mutation
 * restored between observations, or a mutation after the final observations,
 * is not excluded. Reading can cause filesystem access-time bookkeeping.
 * Snapshot bytes are retained in memory, not a continuing live-root authority.
 */
typedef struct EPRSnapshot EPRSnapshot;

/* NULL on failure; error receives an errno value. Success sets error to zero. */
EPRSnapshot *epr_read_snapshot(const char *path, int *error);
size_t epr_snapshot_count(const EPRSnapshot *snapshot);
const char *epr_snapshot_name(const EPRSnapshot *snapshot, size_t index);
const unsigned char *epr_snapshot_bytes(const EPRSnapshot *snapshot, size_t index);
size_t epr_snapshot_size(const EPRSnapshot *snapshot, size_t index);

/* Closes each owned descriptor once; no retry, file mutation, or cleanup. */
void epr_snapshot_free(EPRSnapshot *snapshot);

/*
 * 1: admitted; 0: policy rejection; -1: inspection/API failure.
 * error is zero for 1/0, otherwise errno, OSStatus, or a CFError code.
 * expected_team must be exactly ten ASCII alphanumeric characters.
 *
 * Self-only code-signing admission requires an Apple certificate anchor,
 * identifier com.ergentics.provenance, and the expected actual signing Team.
 * Only true app-sandbox, user-selected.read-only, and hypervisor entitlements are
 * accepted. Optional Team/application-identifier metadata must match. Every
 * other entitlement, even an unknown or false-valued one, rejects.
 * Validation explicitly disables network checks. It is neither notarization
 * evidence nor a claim of online revocation checking or resource-wide sealing.
 */
int epr_admit_signing(const char *expected_team, int *error);

/* No VM/config object, memory map, vCPU, guest instruction, network or write.
 * Only kern.hv_support and two capability queries after self-signing admission.
 * Values from an hv_* query are meaningful only when its status is HV_SUCCESS.
 */
typedef struct {
    int host_supported;
    int support_status;
    size_t support_size;
    int support_error;
    int signing_admitted;
    int signing_error;
    uint32_t queries_entered;
    int32_t vcpu_status;
    int32_t ipa_status;
    uint32_t max_vcpus;
    uint32_t max_ipa_bits;
} EPRHypervisorCapabilities;
EPRHypervisorCapabilities epr_hypervisor_capabilities(void);

#ifdef __cplusplus
}
#endif

#endif

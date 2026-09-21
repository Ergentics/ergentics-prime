#ifndef ERGENTICS_PROVENANCE_READ_ONLY_H
#define ERGENTICS_PROVENANCE_READ_ONLY_H

#include <stddef.h>
#include <stdint.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sqlite3.h>
#include <sys/stat.h>
#include <unistd.h>
#include "HypervisorGuest.h"
#include "SigningCapabilityPolicy.h"

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
 * Only true app-sandbox, user-selected.read-write, hypervisor and virtualization entitlements are
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

/*
 * Fixed-arity bridge for sqlite3_db_config(), whose variadic ABI is not an
 * acceptable Swift authority surface. The database must already be open on an
 * admitted private store or private in-memory image. This bridge opens no path
 * and performs no I/O.
 */
typedef struct {
    int defensive;
    int trusted_schema;
    int dqs_ddl;
    int dqs_dml;
} EPRSQLiteReadOnlyPolicy;

typedef struct {
    int defensive;
    int trusted_schema;
    int dqs_ddl;
    int dqs_dml;
} EPRSQLiteWriterPolicy;

/*
 * H4-D2b fixed publication primitives. SQLite allocator ownership never
 * crosses into Swift, and callers cannot select a schema, capacity, leaf,
 * mode, open flag, rename flag, or VFS.
 */
enum { EPR_H4D2B_IMAGE_CAP = 64 * 4096 };

static inline int epr_h4d2b_sqlite_serialize_main(void *opaque,
                                                   unsigned char *destination,
                                                   int64_t *size) {
    if (!opaque || !destination || !size) return SQLITE_MISUSE;
    *size = 0;
    sqlite3_int64 count = 0;
    unsigned char *serialized = sqlite3_serialize(
        (sqlite3 *)opaque, "main", &count, 0
    );
    if (!serialized) return SQLITE_NOMEM;
    if (count <= 0 || count > EPR_H4D2B_IMAGE_CAP ||
        (uint64_t)count > (uint64_t)SIZE_MAX) {
        sqlite3_free(serialized);
        return SQLITE_TOOBIG;
    }
    memcpy(destination, serialized, (size_t)count);
    sqlite3_free(serialized);
    *size = (int64_t)count;
    return SQLITE_OK;
}

static inline int epr_h4d2b_create_staging(int root) {
    return openat(root, ".h4d2b-receipt.sqlite.staging",
                  O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                  (mode_t)0600);
}

static inline int epr_h4d2b_publish_staging(int root) {
    return renameatx_np(root, ".h4d2b-receipt.sqlite.staging",
                        root, "h4d2b-receipt.sqlite",
                        RENAME_EXCL | RENAME_NOFOLLOW_ANY |
                        RENAME_RESOLVE_BENEATH);
}

static inline int epr_h4d2b_open_final(int root) {
    return openat(root, "h4d2b-receipt.sqlite",
                  O_RDONLY | O_NOFOLLOW | O_CLOEXEC);
}

/*
 * D2c inspection is deliberately distinct from D2b's same-process reopen.
 * O_NONBLOCK prevents a rebound FIFO or device-shaped leaf from turning the
 * fixed read-only observation into an unbounded open. Metadata and vnode joins
 * in Swift must still reject every non-regular or replaced entry.
 */
static inline int epr_h4d2c_open_final(int root) {
    return openat(root, "h4d2b-receipt.sqlite",
                  O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC);
}

/*
 * H4-D3 fixed dual-stream publication primitives. The caller already owns the
 * admitted directory descriptor; no path, flag, mode, schema, or fallback is
 * selectable through this surface.
 */
enum { EPR_H4D3_IMAGE_CAP = 64 * 4096 };

static inline int epr_h4d3_sqlite_serialize_main(void *opaque,
                                                  unsigned char *destination,
                                                  int64_t *size) {
    if (!opaque || !destination || !size) return SQLITE_MISUSE;
    *size = 0;
    sqlite3_int64 count = 0;
    unsigned char *serialized = sqlite3_serialize(
        (sqlite3 *)opaque, "main", &count, 0
    );
    if (!serialized) return SQLITE_NOMEM;
    if (count <= 0 || count > EPR_H4D3_IMAGE_CAP ||
        (uint64_t)count > (uint64_t)SIZE_MAX) {
        sqlite3_free(serialized);
        return SQLITE_TOOBIG;
    }
    memcpy(destination, serialized, (size_t)count);
    sqlite3_free(serialized);
    *size = (int64_t)count;
    return SQLITE_OK;
}

/*
 * Test-only mutation images need resize headroom, but the Swift caller must
 * never declare more capacity than was actually allocated.  This fixed C
 * boundary allocates the complete H4-D3 cap itself and always transfers that
 * allocation to SQLite with FREEONCLOSE.  The fixed buffer already provides
 * all admitted headroom, so SQLite is not allowed to realloc beyond the cap.
 * Once sqlite3_deserialize() is entered, this function must not free the
 * buffer on any return path.
 */
static inline int epr_h4d3_deserialize_mutable_image(void *opaque,
                                                      const unsigned char *source,
                                                      int64_t size) {
    if (!opaque || !source || size <= 0 || size > EPR_H4D3_IMAGE_CAP) {
        return SQLITE_MISUSE;
    }
    unsigned char *buffer = sqlite3_malloc64(EPR_H4D3_IMAGE_CAP);
    if (!buffer) return SQLITE_NOMEM;
    memcpy(buffer, source, (size_t)size);
    return sqlite3_deserialize((sqlite3 *)opaque, "main", buffer, size,
                               EPR_H4D3_IMAGE_CAP,
                               SQLITE_DESERIALIZE_FREEONCLOSE);
}

static inline int epr_h4d3_create_staging(int root) {
    return openat(root, ".h4d3-dual-receipt.sqlite.staging",
                  O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                  (mode_t)0600);
}

static inline int epr_h4d3_publish_staging(int root) {
    return renameatx_np(root, ".h4d3-dual-receipt.sqlite.staging",
                        root, "h4d3-dual-receipt.sqlite",
                        RENAME_EXCL | RENAME_NOFOLLOW_ANY |
                        RENAME_RESOLVE_BENEATH);
}

static inline int epr_h4d3_open_final(int root) {
    return openat(root, "h4d3-dual-receipt.sqlite",
                  O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC);
}

/* Always consumes bytes; caller cannot select flags, schema, capacity or VFS. */
static inline int epr_sqlite_deserialize_readonly(void *opaque,
                                                   unsigned char *bytes,
                                                   int64_t size) {
    if (!bytes) return SQLITE_NOMEM;
    if (!opaque || size <= 0) {
        sqlite3_free(bytes);
        return SQLITE_MISUSE;
    }
    return sqlite3_deserialize((sqlite3 *)opaque, "main", bytes, size, size,
                               SQLITE_DESERIALIZE_FREEONCLOSE |
                               SQLITE_DESERIALIZE_READONLY);
}

/* Force and read back SQLite-owned last-close WAL/SHM disposal. */
static inline int epr_sqlite_disable_persistent_wal(void *opaque) {
    if (!opaque) return SQLITE_MISUSE;
    sqlite3 *database = (sqlite3 *)opaque;
    int value = 0;
    int status = sqlite3_file_control(database, "main",
                                      SQLITE_FCNTL_PERSIST_WAL, &value);
    if (status != SQLITE_OK) return status;
    value = -1;
    status = sqlite3_file_control(database, "main",
                                  SQLITE_FCNTL_PERSIST_WAL, &value);
    if (status != SQLITE_OK) return status;
    return value == 0 ? SQLITE_OK : SQLITE_MISUSE;
}

/* SQLITE_OK only when all four requested values are read back exactly. */
static inline int epr_sqlite_harden_readonly(void *opaque,
                                              EPRSQLiteReadOnlyPolicy *policy) {
    if (!opaque || !policy) return SQLITE_MISUSE;
    sqlite3 *database = (sqlite3 *)opaque;
    policy->defensive = policy->trusted_schema = policy->dqs_ddl = policy->dqs_dml = -1;
    int status = sqlite3_db_config(database, SQLITE_DBCONFIG_DEFENSIVE,
                                   1, &policy->defensive);
    if (status == SQLITE_OK && policy->defensive != 1) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_TRUSTED_SCHEMA,
                               0, &policy->trusted_schema);
    if (status == SQLITE_OK && policy->trusted_schema != 0) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_DQS_DDL,
                               0, &policy->dqs_ddl);
    if (status == SQLITE_OK && policy->dqs_ddl != 0) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_DQS_DML,
                               0, &policy->dqs_dml);
    if (status == SQLITE_OK && policy->dqs_dml != 0) status = SQLITE_MISUSE;
    return status;
}

/* Fixed-arity writer hardening; no caller-selected db_config operation. */
static inline int epr_sqlite_harden_writer(void *opaque,
                                            EPRSQLiteWriterPolicy *policy) {
    if (!opaque || !policy) return SQLITE_MISUSE;
    sqlite3 *database = (sqlite3 *)opaque;
    policy->defensive = policy->trusted_schema = policy->dqs_ddl = policy->dqs_dml = -1;
    int status = sqlite3_db_config(database, SQLITE_DBCONFIG_DEFENSIVE,
                                   1, &policy->defensive);
    if (status == SQLITE_OK && policy->defensive != 1) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_TRUSTED_SCHEMA,
                               0, &policy->trusted_schema);
    if (status == SQLITE_OK && policy->trusted_schema != 0) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_DQS_DDL,
                               0, &policy->dqs_ddl);
    if (status == SQLITE_OK && policy->dqs_ddl != 0) status = SQLITE_MISUSE;
    if (status != SQLITE_OK) return status;
    status = sqlite3_db_config(database, SQLITE_DBCONFIG_DQS_DML,
                               0, &policy->dqs_dml);
    if (status == SQLITE_OK && policy->dqs_dml != 0) status = SQLITE_MISUSE;
    return status;
}

static inline int epr_sqlite_readonly_authorizer(void *context, int action,
                                                  const char *first,
                                                  const char *second,
                                                  const char *database,
                                                  const char *trigger) {
    (void)context; (void)first; (void)second; (void)database; (void)trigger;
    return action == SQLITE_SELECT || action == SQLITE_READ ? SQLITE_OK : SQLITE_DENY;
}

/* After installation, only SELECT and READ authorizer actions are admitted. */
static inline int epr_sqlite_install_readonly_authorizer(void *opaque) {
    if (!opaque) return SQLITE_MISUSE;
    return sqlite3_set_authorizer((sqlite3 *)opaque,
                                  epr_sqlite_readonly_authorizer, NULL);
}

#ifdef __cplusplus
}
#endif

#endif

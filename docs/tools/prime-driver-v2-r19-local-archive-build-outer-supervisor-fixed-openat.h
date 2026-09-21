// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#ifndef PRIME_DRIVER_V2_R19_LOCAL_ARCHIVE_BUILD_OUTER_SUPERVISOR_FIXED_OPENAT_H
#define PRIME_DRIVER_V2_R19_LOCAL_ARCHIVE_BUILD_OUTER_SUPERVISOR_FIXED_OPENAT_H

#include <stdint.h>
#include <sys/types.h>

typedef struct {
    _Alignas(8) uint8_t raw[464];
    int32_t call_return;
    int32_t call_errno;
} prime_r19_rusage_v6_capture_v1;

typedef struct {
    _Alignas(8) uint8_t raw[3][512];
    int32_t open_return;
    int32_t open_errno;
    int32_t bulk_return[3];
    int32_t bulk_errno[3];
    int32_t close_return;
    int32_t close_errno;
    uint64_t options;
    uint32_t bulk_calls_entered;
    uint32_t ordinal;
    uint32_t requested_commonattr;
    uint32_t raw_capacity;
    uint32_t bulk_call_cap;
    uint32_t reserved_zero;
} prime_r19_runtime_root_inventory_raw_capture_v1;

typedef struct {
    _Alignas(8) uint8_t raw[37];
    uint8_t reserved_zero[3];
    uint64_t requested_length;
    uint64_t returned_length;
    int32_t call_return;
    int32_t call_errno;
} prime_r19_boot_session_uuid_capture_v1;

#define PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT \
    __attribute__((visibility("hidden"), warn_unused_result))

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_runtime_parent_v1(
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_mkdir_runtime_root_at_v1(
    int32_t parent_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_runtime_root_at_v1(
    int32_t parent_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_create_journal_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_create_fifo_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_fifo_read_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_ruby_image_v1(
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_controller_source_v1(
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_open_cwd_root_v1(
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_fullfsync_v1(
    int32_t fd,
    uint32_t ordinal,
    int32_t *out_errno
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_capture_rusage_v6_v1(
    pid_t pid,
    uint32_t ordinal,
    prime_r19_rusage_v6_capture_v1 *out_capture
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_capture_runtime_root_inventory_raw_v1(
    int32_t root_fd,
    uint32_t ordinal,
    prime_r19_runtime_root_inventory_raw_capture_v1 *out_capture
);

PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT
int32_t prime_r19_capture_boot_session_uuid_v1(
    uint32_t ordinal,
    prime_r19_boot_session_uuid_capture_v1 *out_capture
);

#undef PRIME_R19_OUTER_SUPERVISOR_FIXED_RESULT

#endif

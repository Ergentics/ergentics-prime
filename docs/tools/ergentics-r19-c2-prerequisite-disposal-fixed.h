// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#ifndef ERGENTICS_R19_C2_PREREQUISITE_DISPOSAL_FIXED_H
#define ERGENTICS_R19_C2_PREREQUISITE_DISPOSAL_FIXED_H

#include <stdint.h>

#define ERGENTICS_R19_DISPOSAL_RESULT \
    __attribute__((visibility("hidden"), warn_unused_result))

__attribute__((visibility("hidden"), noinline, used))
void ergentics_r19_disposal_image_anchor(void);

ERGENTICS_R19_DISPOSAL_RESULT
uint64_t ergentics_r19_disposal_image_anchor_address(void);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_install_containment(void);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_open_private_tmp(int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_create_root(int32_t parent_fd, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_open_root(int32_t parent_fd, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_validate_root(
    int32_t parent_fd,
    int32_t root_fd,
    uint32_t expected_mode,
    uint32_t expected_entry_mask,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_create_leaf(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_leaf_rejoin(
    int32_t root_fd,
    int32_t leaf_fd,
    uint32_t ordinal,
    uint64_t expected_size,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_sealed_leaf_rejoin(
    int32_t root_fd,
    int32_t leaf_fd,
    uint32_t ordinal,
    uint64_t expected_size,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_precreate_outcome(
    int32_t root_fd,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int64_t ergentics_r19_disposal_readback_outcome(
    int32_t outcome_fd,
    void *buffer,
    uint64_t byte_count,
    uint64_t offset,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_outcome_rejoin(
    int32_t root_fd,
    int32_t outcome_fd,
    uint64_t expected_size,
    uint32_t expected_mode,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_seal_leaf(int32_t leaf_fd, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_full_fsync(int32_t fd, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_seal_root(int32_t root_fd, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_open_image(uint32_t ordinal, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_open_cwd(uint32_t ordinal, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_open_launch_cwd(int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_validate_launch_cwd(
    int32_t fd,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_validate_held_image(
    int32_t fd,
    uint32_t ordinal,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_validate_held_cwd(
    int32_t fd,
    uint32_t ordinal,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_proc_pidinfo(
    int32_t pid,
    int32_t flavor,
    uint64_t arg,
    void *buffer,
    int32_t size,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_proc_pidpath(
    int32_t pid,
    void *buffer,
    uint32_t size,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_proc_listpids(
    uint32_t type,
    uint32_t type_info,
    void *buffer,
    int32_t size,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_getsid(int32_t pid, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_getpgid(int32_t pid, int32_t *out_errno);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_kill_guardian(
    int32_t *out_return,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_kill_stopped_fixture_group(
    int32_t *out_return,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_kill_awk(
    int32_t *out_return,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_fixture_signal_zero(
    int32_t *out_return,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_guardian_signal_zero(
    int32_t *out_return,
    int32_t *out_errno
);

ERGENTICS_R19_DISPOSAL_RESULT
int32_t ergentics_r19_disposal_awk_signal_zero(
    int32_t *out_return,
    int32_t *out_errno
);

void ergentics_r19_disposal_wait_quantum(void);
void ergentics_r19_disposal_wait_recovery_quantum(void);

__attribute__((visibility("hidden"), noreturn))
void ergentics_r19_disposal_contain_forever(void);

#undef ERGENTICS_R19_DISPOSAL_RESULT

#endif

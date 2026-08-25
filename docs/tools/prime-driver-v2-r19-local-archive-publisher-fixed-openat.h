// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#ifndef PRIME_DRIVER_V2_R19_LOCAL_ARCHIVE_PUBLISHER_FIXED_OPENAT_H
#define PRIME_DRIVER_V2_R19_LOCAL_ARCHIVE_PUBLISHER_FIXED_OPENAT_H

#include <stddef.h>
#include <stdint.h>

#define PRIME_R19_ARCHIVE_FIXED_RESULT \
    __attribute__((visibility("hidden"), warn_unused_result))

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_open_node(uint32_t ordinal);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_validate_stdin_devnull(void);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_destination_absent(
    int32_t parent_fd,
    uint32_t root_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_create_staging_root(int32_t parent_fd);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_open_root(
    int32_t parent_fd,
    uint32_t root_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_create_directory(
    int32_t root_fd,
    uint32_t directory_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_open_directory(
    int32_t root_fd,
    uint32_t directory_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_create_leaf(
    int32_t root_fd,
    uint32_t global_leaf_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_open_leaf(
    int32_t root_fd,
    uint32_t global_leaf_ordinal
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_publish(int32_t parent_fd);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_full_fsync(int32_t fd);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_validate_parent_filesystem(int32_t parent_fd);

PRIME_R19_ARCHIVE_FIXED_RESULT
int32_t prime_r19_archive_parent_volume_uuid(
    int32_t parent_fd,
    uint8_t uuid_bytes[16]
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int64_t prime_r19_archive_list_xattrs(
    int32_t fd,
    void *buffer,
    size_t size
);

PRIME_R19_ARCHIVE_FIXED_RESULT
int64_t prime_r19_archive_get_xattr(
    int32_t fd,
    const char *name,
    void *buffer,
    size_t size
);

#undef PRIME_R19_ARCHIVE_FIXED_RESULT

#endif

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "prime-driver-v2-r19-local-archive-build-outer-supervisor-fixed-openat.h"

#include <errno.h>
#include <fcntl.h>
#include <libproc.h>
#include <stddef.h>
#include <string.h>
#include <sys/attr.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <unistd.h>

static const char prime_r19_runtime_parent[] =
    "/private/tmp";
static const char prime_r19_runtime_root_leaf[] =
    "r19-local-archive-build-outer-supervisor-4e7d6406-861da2f4";
static const char prime_r19_journal_leaf[] =
    "00-child-supervisor.v1.jsonl";
static const char prime_r19_fifo_leaf[] =
    "01-child-go.v1.fifo";
static const char prime_r19_ruby_image[] =
    "/usr/bin/ruby";
static const char prime_r19_controller_source[] =
    "/Users/ergentics/Documents/Codex/2026-08-09/"
    "resume-latin-roadmap-pr45/"
    ".phase-a-v2-fixture-identity-restore-only-staging/"
    "docs/tools/prime-driver-v2-r19-local-archive-build-controller.rb";
static const char prime_r19_cwd_root[] =
    "/";
static const char prime_r19_dot[] =
    ".";
static const char prime_r19_boot_session_uuid_name[] =
    "kern.bootsessionuuid";

_Static_assert(sizeof(struct rusage_info_v6) == 464u,
    "rusage_info_v6 size");
_Static_assert(_Alignof(struct rusage_info_v6) == 8u,
    "rusage_info_v6 alignment");
_Static_assert(offsetof(struct rusage_info_v6, ri_uuid) == 0u,
    "rusage_info_v6 uuid offset");
_Static_assert(offsetof(struct rusage_info_v6, ri_proc_start_abstime) == 80u,
    "rusage_info_v6 process start offset");
_Static_assert(offsetof(struct rusage_info_v6, ri_proc_exit_abstime) == 88u,
    "rusage_info_v6 process exit offset");
_Static_assert(offsetof(struct rusage_info_v6, ri_energy_nj) == 336u,
    "rusage_info_v6 energy offset");
_Static_assert(offsetof(struct rusage_info_v6, ri_penergy_nj) == 344u,
    "rusage_info_v6 performance energy offset");
_Static_assert(RUSAGE_INFO_V6 == 6,
    "rusage v6 flavor");

_Static_assert(sizeof(prime_r19_rusage_v6_capture_v1) == 472u,
    "rusage capture size");
_Static_assert(_Alignof(prime_r19_rusage_v6_capture_v1) == 8u,
    "rusage capture alignment");
_Static_assert(offsetof(prime_r19_rusage_v6_capture_v1, raw) == 0u,
    "rusage capture raw offset");
_Static_assert(offsetof(prime_r19_rusage_v6_capture_v1, call_return) == 464u,
    "rusage capture return offset");
_Static_assert(offsetof(prime_r19_rusage_v6_capture_v1, call_errno) == 468u,
    "rusage capture errno offset");

_Static_assert(sizeof(prime_r19_runtime_root_inventory_raw_capture_v1) == 1608u,
    "runtime root inventory raw capture size");
_Static_assert(_Alignof(prime_r19_runtime_root_inventory_raw_capture_v1) == 8u,
    "runtime root inventory raw capture alignment");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    raw) == 0u, "runtime root inventory raw offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    raw[1]) == 512u, "runtime root inventory raw 1 offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    raw[2]) == 1024u, "runtime root inventory raw 2 offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    open_return) == 1536u, "runtime root inventory open return offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    open_errno) == 1540u, "runtime root inventory open errno offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    bulk_return) == 1544u, "runtime root inventory bulk return offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    bulk_errno) == 1556u, "runtime root inventory bulk errno offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    close_return) == 1568u, "runtime root inventory close return offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    close_errno) == 1572u, "runtime root inventory close errno offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    options) == 1576u, "runtime root inventory options offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    bulk_calls_entered) == 1584u,
    "runtime root inventory calls offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    ordinal) == 1588u, "runtime root inventory ordinal offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    requested_commonattr) == 1592u,
    "runtime root inventory attributes offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    raw_capacity) == 1596u, "runtime root inventory capacity offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    bulk_call_cap) == 1600u, "runtime root inventory call cap offset");
_Static_assert(offsetof(prime_r19_runtime_root_inventory_raw_capture_v1,
    reserved_zero) == 1604u, "runtime root inventory reserved offset");

_Static_assert(sizeof(prime_r19_boot_session_uuid_capture_v1) == 64u,
    "boot session UUID capture size");
_Static_assert(_Alignof(prime_r19_boot_session_uuid_capture_v1) == 8u,
    "boot session UUID capture alignment");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1, raw) == 0u,
    "boot session UUID raw offset");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1,
    reserved_zero) == 37u, "boot session UUID reserved offset");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1,
    requested_length) == 40u, "boot session UUID requested length offset");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1,
    returned_length) == 48u, "boot session UUID returned length offset");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1,
    call_return) == 56u, "boot session UUID return offset");
_Static_assert(offsetof(prime_r19_boot_session_uuid_capture_v1,
    call_errno) == 60u, "boot session UUID errno offset");
_Static_assert(sizeof(size_t) == 8u,
    "boot session UUID length ABI");

_Static_assert(ATTR_BIT_MAP_COUNT == 5,
    "runtime root inventory attribute bitmap count");
_Static_assert((ATTR_CMN_RETURNED_ATTRS | ATTR_CMN_NAME | ATTR_CMN_OBJTYPE
    | ATTR_CMN_FILEID) == 0x82000009u,
    "runtime root inventory common attributes");
_Static_assert(FSOPT_PACK_INVAL_ATTRS == 0x00000008u,
    "runtime root inventory options");

static int32_t
prime_r19_invalid_out_errno(int32_t *out_errno) {
    errno = EINVAL;
    if (out_errno != NULL) {
        *out_errno = (int32_t)EINVAL;
    }
    return -1;
}

int32_t
prime_r19_open_runtime_parent_v1(uint32_t ordinal, int32_t *out_errno) {
    int result;
    int captured_errno;

    if (ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = open(
        prime_r19_runtime_parent,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_mkdir_runtime_root_at_v1(
    int32_t parent_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (parent_fd < 3 || ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = mkdirat(
        (int)parent_fd,
        prime_r19_runtime_root_leaf,
        (mode_t)0700
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_open_runtime_root_at_v1(
    int32_t parent_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (parent_fd < 3 || ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = openat(
        (int)parent_fd,
        prime_r19_runtime_root_leaf,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_create_journal_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (root_fd < 3 || ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = openat(
        (int)root_fd,
        prime_r19_journal_leaf,
        O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC | O_NOFOLLOW,
        (mode_t)0600
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_create_fifo_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (root_fd < 3 || ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = mkfifoat(
        (int)root_fd,
        prime_r19_fifo_leaf,
        (mode_t)0600
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_open_fifo_read_at_v1(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (root_fd < 3 || ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = openat(
        (int)root_fd,
        prime_r19_fifo_leaf,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_open_ruby_image_v1(uint32_t ordinal, int32_t *out_errno) {
    int result;
    int captured_errno;

    if (ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = open(
        prime_r19_ruby_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_open_controller_source_v1(
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = open(
        prime_r19_controller_source,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_open_cwd_root_v1(uint32_t ordinal, int32_t *out_errno) {
    int result;
    int captured_errno;

    if (ordinal != 1u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = open(
        prime_r19_cwd_root,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
    );
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_fullfsync_v1(
    int32_t fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int result;
    int captured_errno;

    if (fd < 3 || ordinal < 1u || ordinal > 96u || out_errno == NULL) {
        return prime_r19_invalid_out_errno(out_errno);
    }

    errno = 0;
    result = fcntl((int)fd, F_FULLFSYNC);
    captured_errno = errno;
    *out_errno = (int32_t)captured_errno;
    return (int32_t)result;
}

int32_t
prime_r19_capture_rusage_v6_v1(
    pid_t pid,
    uint32_t ordinal,
    prime_r19_rusage_v6_capture_v1 *out_capture
) {
    int call_return;
    int call_errno;

    if (pid <= 1 || (ordinal != 1u && ordinal != 2u)
        || out_capture == NULL) {
        errno = EINVAL;
        return -1;
    }

    (void)memset(out_capture, 0, sizeof(*out_capture));
    errno = 0;
    call_return = proc_pid_rusage(
        (int)pid,
        RUSAGE_INFO_V6,
        (rusage_info_t *)(void *)out_capture->raw
    );
    call_errno = errno;
    out_capture->call_return = (int32_t)call_return;
    out_capture->call_errno = (int32_t)call_errno;
    return 0;
}

int32_t
prime_r19_capture_runtime_root_inventory_raw_v1(
    int32_t root_fd,
    uint32_t ordinal,
    prime_r19_runtime_root_inventory_raw_capture_v1 *out_capture
) {
    struct attrlist attributes;
    int open_return;
    int call_errno;
    uint32_t index;

    if (root_fd < 3 || ordinal < 1u || ordinal > 5u
        || out_capture == NULL) {
        errno = EINVAL;
        return -1;
    }

    (void)memset(out_capture, 0, sizeof(*out_capture));
    (void)memset(&attributes, 0, sizeof(attributes));
    attributes.bitmapcount = ATTR_BIT_MAP_COUNT;
    attributes.commonattr = ATTR_CMN_RETURNED_ATTRS | ATTR_CMN_NAME
        | ATTR_CMN_OBJTYPE | ATTR_CMN_FILEID;
    out_capture->options = (uint64_t)FSOPT_PACK_INVAL_ATTRS;
    out_capture->ordinal = ordinal;
    out_capture->requested_commonattr = (uint32_t)attributes.commonattr;
    out_capture->raw_capacity = 512u;
    out_capture->bulk_call_cap = 3u;

    errno = 0;
    open_return = openat(
        (int)root_fd,
        prime_r19_dot,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
    );
    call_errno = errno;
    out_capture->open_return = (int32_t)open_return;
    out_capture->open_errno = (int32_t)call_errno;
    if (open_return < 0) {
        return 0;
    }
    if (open_return < 3) {
        errno = 0;
        out_capture->close_return = (int32_t)close(open_return);
        call_errno = errno;
        out_capture->close_errno = (int32_t)call_errno;
        return 0;
    }

    for (index = 0u; index < 3u; index += 1u) {
        int bulk_return;

        out_capture->bulk_calls_entered += 1u;
        errno = 0;
        bulk_return = getattrlistbulk(
            open_return,
            &attributes,
            out_capture->raw[index],
            (size_t)512u,
            (uint64_t)FSOPT_PACK_INVAL_ATTRS
        );
        call_errno = errno;
        out_capture->bulk_return[index] = (int32_t)bulk_return;
        out_capture->bulk_errno[index] = (int32_t)call_errno;
    }

    errno = 0;
    out_capture->close_return = (int32_t)close(open_return);
    call_errno = errno;
    out_capture->close_errno = (int32_t)call_errno;
    return 0;
}

int32_t
prime_r19_capture_boot_session_uuid_v1(
    uint32_t ordinal,
    prime_r19_boot_session_uuid_capture_v1 *out_capture
) {
    size_t returned_length;
    int call_return;
    int call_errno;

    if ((ordinal != 1u && ordinal != 2u) || out_capture == NULL) {
        errno = EINVAL;
        return -1;
    }

    (void)memset(out_capture, 0, sizeof(*out_capture));
    returned_length = (size_t)37u;
    out_capture->requested_length = 37u;
    errno = 0;
    call_return = sysctlbyname(
        prime_r19_boot_session_uuid_name,
        out_capture->raw,
        &returned_length,
        NULL,
        (size_t)0u
    );
    call_errno = errno;
    out_capture->returned_length = (uint64_t)returned_length;
    out_capture->call_return = (int32_t)call_return;
    out_capture->call_errno = (int32_t)call_errno;
    return 0;
}

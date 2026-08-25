// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.h"

#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

static const char prime_r19_split_owner_root_directory[] =
    "/";
static const char prime_r19_split_owner_private_tmp[] =
    "/private/tmp";
static const char prime_r19_split_owner_dev_null[] =
    "/dev/null";
static const char prime_r19_split_owner_owner_a_image[] =
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner";
static const char prime_r19_split_owner_primitive_a_image[] =
    "/private/tmp/prime-driver-v2-r19-native-leaf-build-a-e9b6f7bd/sdk26_5_fdflags/PrimeDriverV2R19NativeLeafPrimitiveCanary";
static const char prime_r19_split_owner_supervisor_a_image[] =
    "/private/tmp/prime-driver-v2-r19-native-leaf-controller-runtime-supervisor-repair1-build-a-1aa26d77/PrimeDriverV2R19NativeLeafControllerRuntimeSupervisor";
static const char prime_r19_split_owner_controller_a_image[] =
    "/private/tmp/prime-driver-v2-r19-native-leaf-admission-controller-repair1-build-a-cfa948e2/PrimeDriverV2R19NativeLeafAdmissionController";
static const char prime_r19_split_owner_auditor_a_image[] =
    "/private/tmp/prime-driver-v2-r19-native-leaf-admission-repair1-build-a-c414eac5/PrimeDriverV2R19NativeLeafAdmission";
static const char prime_r19_split_owner_root_leaf[] =
    "r19-native-leaf-split-stream-owner-6a015c11-95c54351";

int32_t
prime_driver_v2_r19_split_owner_open_root_directory(void) {
    return (int32_t)open(
        prime_r19_split_owner_root_directory,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_private_tmp(void) {
    return (int32_t)open(
        prime_r19_split_owner_private_tmp,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_dev_null(void) {
    return (int32_t)open(
        prime_r19_split_owner_dev_null,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_owner_a_image(void) {
    return (int32_t)open(
        prime_r19_split_owner_owner_a_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_primitive_a_image(void) {
    return (int32_t)open(
        prime_r19_split_owner_primitive_a_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_supervisor_a_image(void) {
    return (int32_t)open(
        prime_r19_split_owner_supervisor_a_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_controller_a_image(void) {
    return (int32_t)open(
        prime_r19_split_owner_controller_a_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_open_auditor_a_image(void) {
    return (int32_t)open(
        prime_r19_split_owner_auditor_a_image,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_create_owner_root(int32_t private_tmp_fd) {
    if (mkdirat(
            (int)private_tmp_fd,
            prime_r19_split_owner_root_leaf,
            (mode_t)0700
        ) == -1) {
        return -1;
    }
    return 0;
}

int32_t
prime_driver_v2_r19_split_owner_open_owner_root(int32_t private_tmp_fd) {
    return (int32_t)openat(
        (int)private_tmp_fd,
        prime_r19_split_owner_root_leaf,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_driver_v2_r19_split_owner_create_poisoned_journal_leaf(
    int32_t owner_root_fd,
    uint32_t ordinal
) {
    const char *leaf;

    switch (ordinal) {
    case 0u:
        leaf = "00-intent.json";
        break;
    case 1u:
        leaf = "01-owner-bound.json";
        break;
    case 2u:
        leaf = "02-primitive-spawn-commitment.json";
        break;
    case 3u:
        leaf = "03-primitive-action-commitment.json";
        break;
    case 4u:
        leaf = "04-primitive-terminal.json";
        break;
    case 5u:
        leaf = "05-supervisor-spawn-commitment.json";
        break;
    case 6u:
        leaf = "06-supervisor-action-commitment.json";
        break;
    case 7u:
        leaf = "07-supervisor-terminal.json";
        break;
    case 8u:
        leaf = "08-owner-terminal.json";
        break;
    default:
        errno = EINVAL;
        return -1;
    }

    return (int32_t)openat(
        (int)owner_root_fd,
        leaf,
        O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
        (mode_t)0000
    );
}

int32_t
prime_driver_v2_r19_split_owner_get_fd_flags(int32_t fd) {
    return (int32_t)fcntl((int)fd, F_GETFD);
}

int32_t
prime_driver_v2_r19_split_owner_get_status_flags(int32_t fd) {
    return (int32_t)fcntl((int)fd, F_GETFL);
}

int32_t
prime_driver_v2_r19_split_owner_set_cloexec(int32_t fd) {
    int flags = fcntl((int)fd, F_GETFD);
    if (flags == -1) {
        return -1;
    }
    if (fcntl((int)fd, F_SETFD, flags | FD_CLOEXEC) == -1) {
        return -1;
    }
    return 0;
}

int32_t
prime_driver_v2_r19_split_owner_set_nonblocking(int32_t fd) {
    int flags = fcntl((int)fd, F_GETFL);
    if (flags == -1) {
        return -1;
    }
    if (fcntl((int)fd, F_SETFL, flags | O_NONBLOCK) == -1) {
        return -1;
    }
    return 0;
}

int32_t
prime_driver_v2_r19_split_owner_set_nosigpipe(int32_t fd) {
    if (fcntl((int)fd, F_SETNOSIGPIPE, 1) == -1) {
        return -1;
    }
    return 0;
}

int32_t
prime_driver_v2_r19_split_owner_full_fsync(int32_t fd) {
    if (fsync((int)fd) == -1) {
        return -1;
    }
    if (fcntl((int)fd, F_FULLFSYNC) == -1) {
        return -1;
    }
    return 0;
}

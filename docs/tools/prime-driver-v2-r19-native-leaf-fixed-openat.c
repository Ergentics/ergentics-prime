// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "prime-driver-v2-r19-native-leaf-fixed-openat.h"

#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>

static const char prime_r19_fixed_leaf[] =
    "00-native-leaf-canary.json";

int32_t
prime_driver_v2_r19_create_exclusive_poisoned_leaf(
    int32_t directory_fd,
    const char *fixed_leaf
) {
    if (directory_fd < 3 || fixed_leaf == NULL ||
        strcmp(fixed_leaf, prime_r19_fixed_leaf) != 0) {
        errno = EINVAL;
        return -1;
    }

    return openat(
        directory_fd,
        prime_r19_fixed_leaf,
        O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
        (mode_t)0000
    );
}

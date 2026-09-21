// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "prime-driver-v2-r19-native-leaf-controller-runtime-supervisor-fixed-openat.h"

#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

static const char *const prime_r19_controller_supervisor_journal_leaves[] = {
    "00-intent.json",
    "01-start.json",
    "02-terminal.json",
};

int32_t
prime_driver_v2_r19_controller_supervisor_create_poisoned_journal_leaf(
    int32_t directory_fd,
    uint32_t ordinal
) {
    if (directory_fd < 3 || ordinal >= 3u) {
        errno = EINVAL;
        return -1;
    }

    return openat(
        directory_fd,
        prime_r19_controller_supervisor_journal_leaves[ordinal],
        (int)0x01000b02,
        (mode_t)0000
    );
}

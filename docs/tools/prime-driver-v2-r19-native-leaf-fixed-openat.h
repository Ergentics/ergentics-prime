// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#ifndef PRIME_DRIVER_V2_R19_NATIVE_LEAF_FIXED_OPENAT_H
#define PRIME_DRIVER_V2_R19_NATIVE_LEAF_FIXED_OPENAT_H

#include <stdint.h>

__attribute__((visibility("hidden"), warn_unused_result))
int32_t prime_driver_v2_r19_create_exclusive_poisoned_leaf(
    int32_t directory_fd,
    const char *fixed_leaf
);

#endif

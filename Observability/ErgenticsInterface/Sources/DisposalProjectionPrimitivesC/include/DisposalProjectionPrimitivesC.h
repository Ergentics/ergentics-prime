#ifndef DISPOSAL_PROJECTION_PRIMITIVES_C_H
#define DISPOSAL_PROJECTION_PRIMITIVES_C_H

#include <stdint.h>

int32_t disposal_projection_openat_directory_no_follow(
    int32_t parent_descriptor,
    const char *leaf);

int32_t disposal_projection_openat_readonly_no_follow(
    int32_t parent_descriptor,
    const char *leaf);

int32_t disposal_projection_openat_create_exclusive_private(
    int32_t parent_descriptor,
    const char *leaf,
    uint32_t mode);

#endif

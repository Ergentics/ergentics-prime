#ifndef ERGENTICS_R19_OBS11_C2_FCHMOD_V7_H
#define ERGENTICS_R19_OBS11_C2_FCHMOD_V7_H

#include <stdint.h>

__attribute__((visibility("default")))
int32_t ergentics_r19_obs11_c2_v7_fchmod(
    int32_t fd,
    uint32_t mode_bits,
    int32_t *errno_out);

#endif

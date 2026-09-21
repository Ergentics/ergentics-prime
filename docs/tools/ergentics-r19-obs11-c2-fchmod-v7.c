#include "ergentics-r19-obs11-c2-fchmod-v7.h"

#include <errno.h>
#include <sys/stat.h>

_Static_assert(sizeof(int32_t) == sizeof(int),
    "int32_t and int must have equal width");
_Static_assert((uint32_t)(mode_t)0400 == UINT32_C(0400),
    "mode_t must round-trip 0400");
_Static_assert((uint32_t)(mode_t)0500 == UINT32_C(0500),
    "mode_t must round-trip 0500");

typedef int (*ergentics_fchmod_function)(int, mode_t);

static ergentics_fchmod_function const ergentics_system_fchmod = &fchmod;

int32_t
ergentics_r19_obs11_c2_v7_fchmod(
    int32_t fd,
    uint32_t mode_bits,
    int32_t *errno_out)
{
    if (errno_out == (int32_t *)0) {
        return INT32_C(-2);
    }

    mode_t const native_mode = (mode_t)mode_bits;
    if (fd < INT32_C(3) ||
        (mode_bits != UINT32_C(0400) && mode_bits != UINT32_C(0500)) ||
        (uint32_t)native_mode != mode_bits) {
        *errno_out = (int32_t)EINVAL;
        return INT32_C(-1);
    }

    *errno_out = INT32_C(0);
    errno = 0;
    int const result = ergentics_system_fchmod((int)fd, native_mode);
    int const captured_errno = errno;
    *errno_out = (int32_t)captured_errno;
    return (int32_t)result;
}

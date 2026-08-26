#include "DisposalProjectionPrimitivesC.h"

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int32_t
disposal_projection_openat_directory_no_follow(
    int32_t parent_descriptor,
    const char *leaf)
{
    return (int32_t)openat(
        parent_descriptor,
        leaf,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY);
}

int32_t
disposal_projection_openat_readonly_no_follow(
    int32_t parent_descriptor,
    const char *leaf)
{
    return (int32_t)openat(
        parent_descriptor,
        leaf,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY);
}

int32_t
disposal_projection_openat_create_exclusive_private(
    int32_t parent_descriptor,
    const char *leaf,
    uint32_t mode)
{
    return (int32_t)openat(
        parent_descriptor,
        leaf,
        O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
        (mode_t)mode);
}

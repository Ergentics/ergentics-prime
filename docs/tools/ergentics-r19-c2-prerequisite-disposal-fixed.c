// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "ergentics-r19-c2-prerequisite-disposal-fixed.h"

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <libproc.h>
#include <mach/mach_time.h>
#include <signal.h>
#include <stddef.h>
#include <stdatomic.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

static const char *const disposal_root_leaf =
    "ergentics-r19-obs11-c2-prerequisite-disposal-b5afcd7-8930176-8930235-8668003-v4";

static const char *const disposal_leaves[] = {
    "00-start.json",
    "01-guardian-prestate.json",
    "02-guardian-kill-commitment.json",
    "03-guardian-kill-result.json",
    "04-guardian-conservation.json",
    "05-stopped-fixture-prestate.json",
    "06-stopped-fixture-kill-commitment.json",
    "07-stopped-fixture-kill-result.json",
    "08-stopped-fixture-conservation.json",
    "09-awk-prestate.json",
    "10-awk-kill-commitment.json",
    "11-awk-kill-result.json",
    "12-awk-conservation.json",
    "13-natural-exit-observers.json",
    "14-terminal.json",
    "99-outcome.jsonl",
};

static const char *const disposal_images[] = {
    "/usr/bin/ruby",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2SessionFixture",
    "/usr/bin/awk",
    "/bin/zsh",
    "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-a-b5afcd7-v4/ErgenticsR19C2PrerequisiteDisposal",
    "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-b-b5afcd7-v4/ErgenticsR19C2PrerequisiteDisposal",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26/r19-obs11-c2-prerequisite-disposal-readiness.v4.frame",
};

static const char *const disposal_cwds[] = {
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging",
    "/private/tmp/prime-validation-admission-tests-369E97E5-AAF3-4267-B810-BA92ADB20BD1/workspace",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging",
};

static const char *const disposal_launch_cwd = "/private/var/empty";

_Static_assert(sizeof(disposal_leaves) / sizeof(disposal_leaves[0]) == 16u,
    "journal leaf table must remain fixed");
_Static_assert(sizeof(disposal_images) / sizeof(disposal_images[0]) == 7u,
    "image table must remain fixed");
_Static_assert(sizeof(disposal_cwds) / sizeof(disposal_cwds[0]) == 3u,
    "cwd table must remain fixed");
static int32_t
checked_fd(int descriptor, int operation_errno, int32_t *out_errno) {
    int duplicate;
    int flags;
    if (descriptor == -1) {
        *out_errno = operation_errno;
        errno = operation_errno;
        return -1;
    }
    if (descriptor >= 0 && descriptor < 3) {
        duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3);
        operation_errno = duplicate == -1 ? errno : 0;
        (void)close(descriptor);
        if (duplicate == -1) {
            *out_errno = operation_errno;
            errno = operation_errno;
            return -1;
        }
        descriptor = duplicate;
    }
    flags = fcntl(descriptor, F_GETFD);
    if (flags == -1 || (flags & FD_CLOEXEC) == 0) {
        operation_errno = flags == -1 ? errno : EBADF;
        (void)close(descriptor);
        *out_errno = operation_errno;
        errno = operation_errno;
        return -1;
    }
    *out_errno = 0;
    return (int32_t)descriptor;
}

static int32_t
invalid_argument(int32_t *out_errno) {
    if (out_errno != NULL) {
        *out_errno = EINVAL;
    }
    errno = EINVAL;
    return -1;
}

__attribute__((visibility("hidden"), noinline, used))
void
ergentics_r19_disposal_image_anchor(void) {
    __asm__ volatile("" ::: "memory");
}

uint64_t
ergentics_r19_disposal_image_anchor_address(void) {
    return (uint64_t)(uintptr_t)&ergentics_r19_disposal_image_anchor;
}

int32_t
ergentics_r19_disposal_install_containment(void) {
    struct sigaction ignored;
    unsigned int index;
    const int signals[] = {SIGHUP, SIGINT, SIGQUIT, SIGTERM, SIGPIPE};
    memset(&ignored, 0, sizeof(ignored));
    ignored.sa_handler = SIG_IGN;
    if (sigemptyset(&ignored.sa_mask) == -1) {
        return -1;
    }
    for (index = 0; index < sizeof(signals) / sizeof(signals[0]); ++index) {
        if (sigaction(signals[index], &ignored, NULL) == -1) {
            return -1;
        }
    }
    (void)umask((mode_t)0077);
    return 0;
}

int32_t
ergentics_r19_disposal_open_private_tmp(int32_t *out_errno) {
    int descriptor;
    int operation_errno;
    if (out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    descriptor = open(
        "/private/tmp", O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
    operation_errno = errno;
    return checked_fd(descriptor, operation_errno, out_errno);
}

int32_t
ergentics_r19_disposal_create_root(int32_t parent_fd, int32_t *out_errno) {
    int result;
    if (parent_fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    result = mkdirat(parent_fd, disposal_root_leaf, (mode_t)0700);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_open_root(int32_t parent_fd, int32_t *out_errno) {
    int descriptor;
    int operation_errno;
    if (parent_fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    descriptor = openat(
        parent_fd, disposal_root_leaf,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
    operation_errno = errno;
    return checked_fd(descriptor, operation_errno, out_errno);
}

int32_t
ergentics_r19_disposal_root_rejoin(
    int32_t parent_fd,
    int32_t root_fd,
    uint32_t expected_mode,
    int32_t *out_errno
) {
    struct stat named;
    struct stat held;
    if (parent_fd < 3 || root_fd < 3 || out_errno == NULL ||
        (expected_mode != 0700u && expected_mode != 0500u)) {
        return invalid_argument(out_errno);
    }
    if (fstatat(parent_fd, disposal_root_leaf, &named, AT_SYMLINK_NOFOLLOW) == -1 ||
        fstat(root_fd, &held) == -1) {
        *out_errno = errno;
        return -1;
    }
    if (!S_ISDIR(named.st_mode) || !S_ISDIR(held.st_mode) ||
        named.st_dev != held.st_dev || named.st_ino != held.st_ino ||
        named.st_uid != 501 || held.st_uid != 501 ||
        named.st_gid != 0 || held.st_gid != 0 ||
        named.st_nlink != 2 || held.st_nlink != 2 ||
        named.st_flags != 0 || held.st_flags != 0 ||
        (named.st_mode & 07777) != expected_mode ||
        (held.st_mode & 07777) != expected_mode) {
        *out_errno = EPERM;
        errno = EPERM;
        return -1;
    }
    *out_errno = 0;
    return 0;
}

int32_t
ergentics_r19_disposal_root_inventory(
    int32_t root_fd,
    uint32_t expected_mask,
    int32_t *out_errno
) {
    DIR *directory;
    struct dirent *entry;
    uint32_t seen = 0;
    int duplicate;
    unsigned int index;
    int outcome_seen = 0;
    if (root_fd < 3 || out_errno == NULL || (expected_mask & ~0x7fffu) != 0) {
        return invalid_argument(out_errno);
    }
    duplicate = fcntl(root_fd, F_DUPFD_CLOEXEC, 3);
    if (duplicate == -1) {
        *out_errno = errno;
        return -1;
    }
    directory = fdopendir(duplicate);
    if (directory == NULL) {
        int operation_errno = errno;
        (void)close(duplicate);
        *out_errno = operation_errno;
        errno = operation_errno;
        return -1;
    }
    errno = 0;
    while ((entry = readdir(directory)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        for (index = 0; index < 16u; ++index) {
            if (strcmp(entry->d_name, disposal_leaves[index]) == 0) {
                break;
            }
        }
        if (index == 16u ||
            (index == 15u && outcome_seen) ||
            (index < 15u && (seen & (1u << index)) != 0)) {
            errno = EPERM;
            break;
        }
        if (index == 15u) {
            outcome_seen = 1;
        } else {
            seen |= 1u << index;
        }
    }
    if (errno != 0 || seen != expected_mask) {
        int operation_errno = errno != 0 ? errno : EPERM;
        (void)closedir(directory);
        *out_errno = operation_errno;
        errno = operation_errno;
        return -1;
    }
    if (closedir(directory) == -1) {
        *out_errno = errno;
        return -1;
    }
    *out_errno = 0;
    return 0;
}

int32_t
ergentics_r19_disposal_create_leaf(
    int32_t root_fd,
    uint32_t ordinal,
    int32_t *out_errno
) {
    int descriptor;
    int operation_errno;
    if (root_fd < 3 || ordinal >= 15u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    descriptor = openat(
        root_fd, disposal_leaves[ordinal],
        O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
        (mode_t)0000
    );
    operation_errno = errno;
    return checked_fd(descriptor, operation_errno, out_errno);
}

static int32_t
leaf_rejoin(
    int32_t root_fd,
    int32_t leaf_fd,
    uint32_t ordinal,
    uint64_t expected_size,
    uint32_t expected_mode,
    int32_t *out_errno
) {
    struct stat named;
    struct stat held;
    if (root_fd < 3 || leaf_fd < 3 || ordinal >= 16u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    if (fstatat(root_fd, disposal_leaves[ordinal], &named,
            AT_SYMLINK_NOFOLLOW) == -1 || fstat(leaf_fd, &held) == -1) {
        *out_errno = errno;
        return -1;
    }
    if (!S_ISREG(named.st_mode) || !S_ISREG(held.st_mode) ||
        named.st_dev != held.st_dev || named.st_ino != held.st_ino ||
        named.st_uid != 501 || held.st_uid != 501 ||
        named.st_gid != 0 || held.st_gid != 0 ||
        named.st_nlink != 1 || held.st_nlink != 1 ||
        named.st_flags != 0 || held.st_flags != 0 ||
        (named.st_mode & 07777) != expected_mode ||
        (held.st_mode & 07777) != expected_mode ||
        (uint64_t)named.st_size != expected_size ||
        (uint64_t)held.st_size != expected_size) {
        *out_errno = EPERM;
        errno = EPERM;
        return -1;
    }
    *out_errno = 0;
    return 0;
}

int32_t
ergentics_r19_disposal_leaf_rejoin(
    int32_t root_fd, int32_t leaf_fd, uint32_t ordinal,
    uint64_t expected_size, int32_t *out_errno
) {
    if (ordinal >= 15u) {
        return invalid_argument(out_errno);
    }
    return leaf_rejoin(
        root_fd, leaf_fd, ordinal, expected_size, 0000u, out_errno
    );
}

int32_t
ergentics_r19_disposal_sealed_leaf_rejoin(
    int32_t root_fd, int32_t leaf_fd, uint32_t ordinal,
    uint64_t expected_size, int32_t *out_errno
) {
    if (ordinal >= 15u) {
        return invalid_argument(out_errno);
    }
    return leaf_rejoin(
        root_fd, leaf_fd, ordinal, expected_size, 0400u, out_errno
    );
}

int32_t
ergentics_r19_disposal_precreate_outcome(
    int32_t root_fd, int32_t *out_errno
) {
    int descriptor;
    int operation_errno;
    if (root_fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    descriptor = openat(
        root_fd, disposal_leaves[15],
        O_RDWR | O_APPEND | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
        (mode_t)0600
    );
    operation_errno = errno;
    return checked_fd(descriptor, operation_errno, out_errno);
}

int64_t
ergentics_r19_disposal_readback_outcome(
    int32_t outcome_fd,
    void *buffer,
    uint64_t byte_count,
    uint64_t offset,
    int32_t *out_errno
) {
    ssize_t result;
    if (outcome_fd < 3 || buffer == NULL || out_errno == NULL ||
        byte_count > (uint64_t)SSIZE_MAX || offset > (uint64_t)INT64_MAX) {
        return (int64_t)invalid_argument(out_errno);
    }
    errno = 0;
    result = pread(
        outcome_fd, buffer, (size_t)byte_count, (off_t)offset
    );
    *out_errno = result == -1 ? errno : 0;
    return (int64_t)result;
}

int32_t
ergentics_r19_disposal_outcome_rejoin(
    int32_t root_fd,
    int32_t outcome_fd,
    uint64_t expected_size,
    uint32_t expected_mode,
    int32_t *out_errno
) {
    int descriptor_flags;
    int status_flags;
    if (expected_mode != 0600u && expected_mode != 0400u) {
        return invalid_argument(out_errno);
    }
    if (leaf_rejoin(
            root_fd, outcome_fd, 15u, expected_size, expected_mode, out_errno
        ) == -1) {
        return -1;
    }
    descriptor_flags = fcntl(outcome_fd, F_GETFD);
    status_flags = fcntl(outcome_fd, F_GETFL);
    if (descriptor_flags == -1 || status_flags == -1) {
        *out_errno = errno;
        return -1;
    }
    if ((descriptor_flags & FD_CLOEXEC) == 0 ||
        (status_flags & O_ACCMODE) != O_RDWR ||
        (status_flags & O_APPEND) == 0) {
        *out_errno = EPERM;
        errno = EPERM;
        return -1;
    }
    *out_errno = 0;
    return 0;
}

int32_t
ergentics_r19_disposal_seal_leaf(int32_t leaf_fd, int32_t *out_errno) {
    int result;
    if (leaf_fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    result = fchmod(leaf_fd, (mode_t)0400);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_full_fsync(int32_t fd, int32_t *out_errno) {
    int result;
    if (fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    if (fsync(fd) == -1) {
        *out_errno = errno;
        return -1;
    }
    result = fcntl(fd, F_FULLFSYNC);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_seal_root(int32_t root_fd, int32_t *out_errno) {
    int result;
    if (root_fd < 3 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    result = fchmod(root_fd, (mode_t)0500);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

static int32_t
open_fixed_path(const char *path, int directory, int32_t *out_errno) {
    int descriptor;
    int operation_errno;
    int flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY;
    if (directory) {
        flags |= O_DIRECTORY;
    }
    descriptor = open(path, flags);
    operation_errno = errno;
    return checked_fd(descriptor, operation_errno, out_errno);
}

int32_t
ergentics_r19_disposal_open_image(uint32_t ordinal, int32_t *out_errno) {
    if (ordinal >= 7u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return open_fixed_path(disposal_images[ordinal], 0, out_errno);
}

int32_t
ergentics_r19_disposal_open_cwd(uint32_t ordinal, int32_t *out_errno) {
    if (ordinal >= 3u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return open_fixed_path(disposal_cwds[ordinal], 1, out_errno);
}

int32_t
ergentics_r19_disposal_open_launch_cwd(int32_t *out_errno) {
    if (out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return open_fixed_path(disposal_launch_cwd, 1, out_errno);
}

static int32_t
validate_held_path(int32_t fd, const char *path, int directory,
    int32_t *out_errno) {
    struct stat named;
    struct stat held;
    int flags;
    if (fd < 3 || path == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    flags = fcntl(fd, F_GETFL);
    if (flags == -1) {
        *out_errno = errno;
        return -1;
    }
    if ((flags & O_ACCMODE) != O_RDONLY) {
        *out_errno = EPERM;
        errno = EPERM;
        return -1;
    }
    if (fstatat(AT_FDCWD, path, &named, AT_SYMLINK_NOFOLLOW) == -1 ||
        fstat(fd, &held) == -1) {
        *out_errno = errno;
        return -1;
    }
    if ((directory && (!S_ISDIR(named.st_mode) || !S_ISDIR(held.st_mode))) ||
        (!directory && (!S_ISREG(named.st_mode) || !S_ISREG(held.st_mode))) ||
        named.st_dev != held.st_dev || named.st_ino != held.st_ino ||
        named.st_uid != held.st_uid || named.st_gid != held.st_gid ||
        named.st_nlink != held.st_nlink || named.st_flags != held.st_flags ||
        named.st_mode != held.st_mode || named.st_size != held.st_size) {
        *out_errno = EPERM;
        errno = EPERM;
        return -1;
    }
    *out_errno = 0;
    return 0;
}

int32_t
ergentics_r19_disposal_validate_held_image(
    int32_t fd, uint32_t ordinal, int32_t *out_errno
) {
    if (ordinal >= 7u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return validate_held_path(fd, disposal_images[ordinal], 0, out_errno);
}

int32_t
ergentics_r19_disposal_validate_held_cwd(
    int32_t fd, uint32_t ordinal, int32_t *out_errno
) {
    if (ordinal >= 3u || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return validate_held_path(fd, disposal_cwds[ordinal], 1, out_errno);
}

int32_t
ergentics_r19_disposal_validate_launch_cwd(
    int32_t fd, int32_t *out_errno
) {
    if (out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    return validate_held_path(fd, disposal_launch_cwd, 1, out_errno);
}

int32_t
ergentics_r19_disposal_proc_pidinfo(
    int32_t pid, int32_t flavor, uint64_t arg, void *buffer, int32_t size,
    int32_t *out_errno
) {
    int result;
    if (pid <= 0 || buffer == NULL || size <= 0 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = proc_pidinfo(pid, flavor, arg, buffer, size);
    *out_errno = result <= 0 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_proc_pidpath(
    int32_t pid, void *buffer, uint32_t size, int32_t *out_errno
) {
    int result;
    if (pid <= 0 || buffer == NULL || size == 0 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = proc_pidpath(pid, buffer, size);
    *out_errno = result <= 0 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_proc_listpids(
    uint32_t type, uint32_t type_info, void *buffer, int32_t size,
    int32_t *out_errno
) {
    int result;
    if (buffer == NULL || size <= 0 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = proc_listpids(type, type_info, buffer, size);
    *out_errno = result <= 0 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_getsid(int32_t pid, int32_t *out_errno) {
    int result;
    if (pid <= 0 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = getsid(pid);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_getpgid(int32_t pid, int32_t *out_errno) {
    int result;
    if (pid <= 0 || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = getpgid(pid);
    *out_errno = result == -1 ? errno : 0;
    return result;
}

int32_t
ergentics_r19_disposal_kill_guardian(
    int32_t *out_return, int32_t *out_errno
) {
    static atomic_uint entered = 0;
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    if (atomic_exchange_explicit(&entered, 1u, memory_order_seq_cst) != 0u) {
        *out_return = -1;
        *out_errno = EALREADY;
        errno = EALREADY;
        return -1;
    }
    errno = 0;
    result = kill(21601, SIGKILL);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

int32_t
ergentics_r19_disposal_kill_stopped_fixture_group(
    int32_t *out_return, int32_t *out_errno
) {
    static atomic_uint entered = 0;
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    if (atomic_exchange_explicit(&entered, 1u, memory_order_seq_cst) != 0u) {
        *out_return = -1;
        *out_errno = EALREADY;
        errno = EALREADY;
        return -1;
    }
    errno = 0;
    result = kill(-21660, SIGKILL);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

int32_t
ergentics_r19_disposal_kill_awk(
    int32_t *out_return, int32_t *out_errno
) {
    static atomic_uint entered = 0;
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    if (atomic_exchange_explicit(&entered, 1u, memory_order_seq_cst) != 0u) {
        *out_return = -1;
        *out_errno = EALREADY;
        errno = EALREADY;
        return -1;
    }
    errno = 0;
    result = kill(56518, SIGKILL);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

int32_t
ergentics_r19_disposal_fixture_signal_zero(
    int32_t *out_return, int32_t *out_errno
) {
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = kill(-21660, 0);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

int32_t
ergentics_r19_disposal_guardian_signal_zero(
    int32_t *out_return, int32_t *out_errno
) {
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = kill(21601, 0);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

int32_t
ergentics_r19_disposal_awk_signal_zero(
    int32_t *out_return, int32_t *out_errno
) {
    int result;
    if (out_return == NULL || out_errno == NULL) {
        return invalid_argument(out_errno);
    }
    errno = 0;
    result = kill(56518, 0);
    *out_return = result;
    *out_errno = result == -1 ? errno : 0;
    return 0;
}

static void
absolute_wait(uint64_t nanoseconds) {
    mach_timebase_info_data_t timebase;
    kern_return_t wait_result;
    uint64_t ticks;
    if (mach_timebase_info(&timebase) == KERN_SUCCESS && timebase.numer != 0u) {
        ticks = nanoseconds * (uint64_t)timebase.denom / (uint64_t)timebase.numer;
        wait_result = mach_wait_until(mach_absolute_time() + ticks);
        if (wait_result == KERN_SUCCESS) {
            return;
        }
    }
    {
        struct timespec remaining = {
            (time_t)(nanoseconds / 1000000000u),
            (long)(nanoseconds % 1000000000u)
        };
        while (nanosleep(&remaining, &remaining) == -1) {
            if (errno == EINTR) {
                continue;
            }
            /* A persistent clock failure must fail closed without spinning. */
            for (;;) {
                (void)pause();
            }
        }
    }
}

void
ergentics_r19_disposal_wait_quantum(void) {
    absolute_wait(250000000u);
}

void
ergentics_r19_disposal_wait_recovery_quantum(void) {
    /* Bound an indefinite recovery census to low duty cycle. */
    absolute_wait(5000000000u);
}

void
ergentics_r19_disposal_contain_forever(void) {
    for (;;) {
        absolute_wait(1000000000u);
    }
}

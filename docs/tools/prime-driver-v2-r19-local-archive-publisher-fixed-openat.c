// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

#include "prime-driver-v2-r19-local-archive-publisher-fixed-openat.h"

#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/attr.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/xattr.h>
#include <unistd.h>

static const char *const prime_r19_archive_nodes[] = {
    "/Users/ergentics/Documents",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
    "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.c",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.h",
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner.swift",
};

static const char *const prime_r19_archive_roots[] = {
    ".PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136-staging",
    "PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136",
};

static const char *const prime_r19_archive_directories[] = {
    "a", "b", "data", "source",
};

static const uint8_t prime_r19_archive_leaf_directory_ordinals[] = {
    0u, 0u, 1u, 1u, 3u, 3u, 3u,
    2u, 2u, 2u, 2u, 2u, 2u, 2u, 2u, 2u, 2u, 2u, 2u,
};

static const char *const prime_r19_archive_leaves[] = {
    "owner-object.o",
    "owner-product.macho",
    "owner-object.o",
    "owner-product.macho",
    "owner-fixed-openat.c",
    "owner-fixed-openat.h",
    "owner.swift",
    "00-control.json",
    "01-crs12-frame.json",
    "02-origins-a.json",
    "03-origins-b.json",
    "04-artifacts.json",
    "05-macho.json",
    "06-linked-images.json",
    "07-undefined-symbols.json",
    "08-codesign.json",
    "09-xattrs.json",
    "10-toolchain.json",
    "11-manifest-index.json",
};

_Static_assert(
    sizeof(prime_r19_archive_nodes) / sizeof(prime_r19_archive_nodes[0]) == 10u,
    "input ordinal table must have ten entries"
);
_Static_assert(
    sizeof(prime_r19_archive_roots) / sizeof(prime_r19_archive_roots[0]) == 2u,
    "root ordinal table must have two entries"
);
_Static_assert(
    sizeof(prime_r19_archive_directories) /
        sizeof(prime_r19_archive_directories[0]) == 4u,
    "directory ordinal table must have four entries"
);
_Static_assert(
    sizeof(prime_r19_archive_leaves) / sizeof(prime_r19_archive_leaves[0]) == 19u,
    "leaf ordinal table must have nineteen entries"
);
_Static_assert(
    sizeof(prime_r19_archive_leaf_directory_ordinals) /
        sizeof(prime_r19_archive_leaf_directory_ordinals[0]) == 19u,
    "leaf-directory binding table must have nineteen entries"
);

int32_t
prime_r19_archive_validate_stdin_devnull(void) {
    struct stat input_metadata;
    struct stat named_metadata;
    int input_flags;
    int named_fd;
    int result;
    int operation_errno;

    if (fstat(STDIN_FILENO, &input_metadata) == -1) {
        return -1;
    }
    input_flags = fcntl(STDIN_FILENO, F_GETFL);
    if (input_flags == -1) {
        return -1;
    }
    if ((input_flags & O_ACCMODE) != O_RDONLY ||
        (input_metadata.st_mode & S_IFMT) != S_IFCHR) {
        errno = EPERM;
        return -1;
    }
    named_fd = open(
        "/dev/null",
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
    if (named_fd < 3) {
        operation_errno = named_fd == -1 ? errno : EBADF;
        if (named_fd >= 0) {
            (void)close(named_fd);
        }
        errno = operation_errno;
        return -1;
    }
    result = fstat(named_fd, &named_metadata);
    operation_errno = errno;
    if (result == 0 &&
        ((named_metadata.st_mode & S_IFMT) != S_IFCHR ||
         input_metadata.st_dev != named_metadata.st_dev ||
         input_metadata.st_ino != named_metadata.st_ino)) {
        result = -1;
        operation_errno = EPERM;
    }
    if (close(named_fd) == -1) {
        return -1;
    }
    if (result == -1) {
        errno = operation_errno;
    }
    return (int32_t)result;
}

static int
prime_r19_archive_open_bound_directory(
    int root_fd,
    uint32_t global_leaf_ordinal
) {
    uint8_t directory_ordinal;

    if (root_fd < 3 || global_leaf_ordinal >= 19u) {
        errno = EINVAL;
        return -1;
    }
    directory_ordinal =
        prime_r19_archive_leaf_directory_ordinals[global_leaf_ordinal];
    return openat(
        root_fd,
        prime_r19_archive_directories[directory_ordinal],
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_r19_archive_open_node(uint32_t ordinal) {
    int flags;

    if (ordinal >= 10u) {
        errno = EINVAL;
        return -1;
    }
    flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY;
    if (ordinal == 0u || ordinal == 1u || ordinal == 4u) {
        flags |= O_DIRECTORY;
    }
    return (int32_t)open(prime_r19_archive_nodes[ordinal], flags);
}

int32_t
prime_r19_archive_destination_absent(
    int32_t parent_fd,
    uint32_t root_ordinal
) {
    struct stat metadata;
    int result;

    if (parent_fd < 3 || root_ordinal >= 2u) {
        errno = EINVAL;
        return -1;
    }
    result = fstatat(
        (int)parent_fd,
        prime_r19_archive_roots[root_ordinal],
        &metadata,
        AT_SYMLINK_NOFOLLOW
    );
    if (result == -1 && errno == ENOENT) {
        return 0;
    }
    if (result == 0) {
        errno = EEXIST;
    }
    return -1;
}

int32_t
prime_r19_archive_create_staging_root(int32_t parent_fd) {
    if (parent_fd < 3) {
        errno = EINVAL;
        return -1;
    }
    return (int32_t)mkdirat(
        (int)parent_fd,
        prime_r19_archive_roots[0],
        (mode_t)0700
    );
}

int32_t
prime_r19_archive_open_root(int32_t parent_fd, uint32_t root_ordinal) {
    if (parent_fd < 3 || root_ordinal >= 2u) {
        errno = EINVAL;
        return -1;
    }
    return (int32_t)openat(
        (int)parent_fd,
        prime_r19_archive_roots[root_ordinal],
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_r19_archive_create_directory(
    int32_t root_fd,
    uint32_t directory_ordinal
) {
    if (root_fd < 3 || directory_ordinal >= 4u) {
        errno = EINVAL;
        return -1;
    }
    return (int32_t)mkdirat(
        (int)root_fd,
        prime_r19_archive_directories[directory_ordinal],
        (mode_t)0700
    );
}

int32_t
prime_r19_archive_open_directory(
    int32_t root_fd,
    uint32_t directory_ordinal
) {
    if (root_fd < 3 || directory_ordinal >= 4u) {
        errno = EINVAL;
        return -1;
    }
    return (int32_t)openat(
        (int)root_fd,
        prime_r19_archive_directories[directory_ordinal],
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
}

int32_t
prime_r19_archive_create_leaf(
    int32_t root_fd,
    uint32_t global_leaf_ordinal
) {
    int directory_fd;
    int result;
    int operation_errno;

    directory_fd = prime_r19_archive_open_bound_directory(
        (int)root_fd,
        global_leaf_ordinal
    );
    if (directory_fd == -1) {
        return -1;
    }
    result = openat(
        directory_fd,
        prime_r19_archive_leaves[global_leaf_ordinal],
        O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
        (mode_t)0000
    );
    operation_errno = errno;
    if (close(directory_fd) == -1) {
        if (result >= 0) {
            (void)close(result);
        }
        return -1;
    }
    if (result == -1) {
        errno = operation_errno;
    }
    return (int32_t)result;
}

int32_t
prime_r19_archive_open_leaf(
    int32_t root_fd,
    uint32_t global_leaf_ordinal
) {
    int directory_fd;
    int result;
    int operation_errno;

    directory_fd = prime_r19_archive_open_bound_directory(
        (int)root_fd,
        global_leaf_ordinal
    );
    if (directory_fd == -1) {
        return -1;
    }
    result = openat(
        directory_fd,
        prime_r19_archive_leaves[global_leaf_ordinal],
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
    );
    operation_errno = errno;
    if (close(directory_fd) == -1) {
        if (result >= 0) {
            (void)close(result);
        }
        return -1;
    }
    if (result == -1) {
        errno = operation_errno;
    }
    return (int32_t)result;
}

int32_t
prime_r19_archive_publish(int32_t parent_fd) {
    if (parent_fd < 3) {
        errno = EINVAL;
        return -1;
    }
    return (int32_t)renameatx_np(
        (int)parent_fd,
        prime_r19_archive_roots[0],
        (int)parent_fd,
        prime_r19_archive_roots[1],
        (unsigned int)RENAME_EXCL
    );
}

int32_t
prime_r19_archive_full_fsync(int32_t fd) {
    if (fd < 3) {
        errno = EINVAL;
        return -1;
    }
    if (fsync((int)fd) == -1) {
        return -1;
    }
    return (int32_t)fcntl((int)fd, F_FULLFSYNC);
}

int32_t
prime_r19_archive_validate_parent_filesystem(int32_t parent_fd) {
    struct statfs filesystem;

    if (parent_fd < 3) {
        errno = EINVAL;
        return -1;
    }
    if (fstatfs((int)parent_fd, &filesystem) == -1) {
        return -1;
    }
    if (strcmp(filesystem.f_fstypename, "apfs") != 0 ||
        strcmp(filesystem.f_mntonname, "/System/Volumes/Data") != 0 ||
        strcmp(filesystem.f_mntfromname, "/dev/disk3s5") != 0 ||
        (filesystem.f_flags & MNT_LOCAL) == 0 ||
        (filesystem.f_flags & MNT_RDONLY) != 0 ||
        (filesystem.f_flags & MNT_IGNORE_OWNERSHIP) != 0) {
        errno = EPERM;
        return -1;
    }
    return 0;
}

int32_t
prime_r19_archive_parent_volume_uuid(
    int32_t parent_fd,
    uint8_t uuid_bytes[16]
) {
    struct attrlist attributes;
    struct {
        uint32_t length;
        uint8_t uuid[16];
    } result;

    if (parent_fd < 3 || uuid_bytes == NULL) {
        errno = EINVAL;
        return -1;
    }
    memset(&attributes, 0, sizeof(attributes));
    memset(&result, 0, sizeof(result));
    attributes.bitmapcount = ATTR_BIT_MAP_COUNT;
    attributes.volattr = ATTR_VOL_INFO | ATTR_VOL_UUID;
    if (fgetattrlist(
            (int)parent_fd,
            &attributes,
            &result,
            sizeof(result),
            0
        ) == -1 || result.length != sizeof(result)) {
        return -1;
    }
    memcpy(uuid_bytes, result.uuid, 16u);
    return 0;
}

int64_t
prime_r19_archive_list_xattrs(
    int32_t fd,
    void *buffer,
    size_t size
) {
    if (fd < 3 || (buffer == NULL && size != 0u)) {
        errno = EINVAL;
        return -1;
    }
    return (int64_t)flistxattr((int)fd, buffer, size, 0);
}

int64_t
prime_r19_archive_get_xattr(
    int32_t fd,
    const char *name,
    void *buffer,
    size_t size
) {
    if (fd < 3 || name == NULL || (buffer == NULL && size != 0u)) {
        errno = EINVAL;
        return -1;
    }
    return (int64_t)fgetxattr((int)fd, name, buffer, size, 0, 0);
}

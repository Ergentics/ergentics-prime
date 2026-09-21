#include "NativeReceipt.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Security/SecTask.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <mach/mach_time.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static const char run_leaf[] = "native-static-177403f-r1";

static int fail(int *error, int value) {
    if (value == 0) value = EIO;
    if (error != NULL) *error = value;
    errno = value;
    return -1;
}

static int begin(int *error) {
    if (error == NULL) return fail(NULL, EINVAL);
    *error = 0;
    return 0;
}

static int close_once(int fd, int prior_error, int *error) {
    int rc = close(fd);
    int close_error = rc == 0 ? 0 : errno;
    if (prior_error != 0) return fail(error, prior_error);
    if (close_error != 0) return fail(error, close_error);
    return 0;
}

static int park_directory(int fd, int *error) {
    if (fd >= 3) return fd;
    int parked = fcntl(fd, F_DUPFD_CLOEXEC, 3);
    if (parked < 0) {
        int saved = errno;
        return close_once(fd, saved, error);
    }
    if (close_once(fd, 0, error) != 0) {
        int saved = *error;
        return close_once(parked, saved, error);
    }
    return parked;
}

static int private_directory(int fd, struct stat *metadata, int *error) {
    if (fd < 0) return fail(error, EBADF);
    if (fstat(fd, metadata) != 0) return fail(error, errno);
    if (!S_ISDIR(metadata->st_mode) ||
        (metadata->st_mode & 07777) != 0700 ||
        metadata->st_uid != geteuid()) return fail(error, EACCES);
    int flags = fcntl(fd, F_GETFD);
    if (flags < 0) return fail(error, errno);
    if ((flags & FD_CLOEXEC) == 0) return fail(error, EINVAL);
    return 0;
}

static int same_identity(const struct stat *a, const struct stat *b) {
    return a->st_dev == b->st_dev && a->st_ino == b->st_ino &&
           a->st_mode == b->st_mode && a->st_uid == b->st_uid &&
           a->st_gid == b->st_gid;
}

static int same_file(const struct stat *a, const struct stat *b) {
    return same_identity(a, b) && a->st_nlink == b->st_nlink &&
           a->st_size == b->st_size && a->st_flags == b->st_flags &&
           a->st_mtimespec.tv_sec == b->st_mtimespec.tv_sec &&
           a->st_mtimespec.tv_nsec == b->st_mtimespec.tv_nsec &&
           a->st_ctimespec.tv_sec == b->st_ctimespec.tv_sec &&
           a->st_ctimespec.tv_nsec == b->st_ctimespec.tv_nsec;
}

static int named_join(int parent, const char *leaf, const struct stat *held,
                      int regular_file, int *error) {
    struct stat named;
    if (fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) != 0)
        return fail(error, errno);
    if (!(regular_file ? same_file(held, &named) : same_identity(held, &named)))
        return fail(error, ESTALE);
    return 0;
}

static int open_run(int parent, int *error) {
    struct stat parent_before, parent_after, held;
    if (private_directory(parent, &parent_before, error) != 0) return -1;
    int fd = openat(parent, run_leaf, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd < 0) return fail(error, errno);
    if (private_directory(fd, &held, error) != 0 ||
        named_join(parent, run_leaf, &held, 0, error) != 0 ||
        private_directory(parent, &parent_after, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (!same_identity(&parent_before, &parent_after))
        return close_once(fd, ESTALE, error);
    return park_directory(fd, error);
}

int epc_open_private_directory(const char *path, int *error) {
    if (begin(error) != 0) return -1;
    if (path == NULL || path[0] != '/' || path[1] == '\0')
        return fail(error, EINVAL);
    size_t length = strnlen(path, PATH_MAX + 1U);
    if (length > PATH_MAX || path[length - 1] == '/') return fail(error, EINVAL);
    int fd = open(path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd < 0) return fail(error, errno);
    struct stat held, named;
    if (private_directory(fd, &held, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (lstat(path, &named) != 0) return close_once(fd, errno, error);
    if (!same_identity(&held, &named)) return close_once(fd, ESTALE, error);
    return park_directory(fd, error);
}

int epc_create_run(int parent_fd, int *error) {
    if (begin(error) != 0) return -1;
    struct stat parent;
    if (private_directory(parent_fd, &parent, error) != 0) return -1;
    if (mkdirat(parent_fd, run_leaf, 0700) != 0) return fail(error, errno);
    /* Every failure after mkdir retains that exact run directory. */
    int fd = open_run(parent_fd, error);
    if (fd < 0) return -1;
    if (fsync(parent_fd) != 0) return close_once(fd, errno, error);
    return fd;
}

int epc_open_run(int parent_fd, int *error) {
    if (begin(error) != 0) return -1;
    return open_run(parent_fd, error);
}

int epc_revalidate_run(int parent_fd, int run_fd, int *error) {
    if (begin(error) != 0) return -1;
    if (parent_fd == run_fd) return fail(error, EINVAL);
    struct stat parent_before, parent_after, run_before, run_after;
    if (private_directory(parent_fd, &parent_before, error) != 0 ||
        private_directory(run_fd, &run_before, error) != 0 ||
        named_join(parent_fd, run_leaf, &run_before, 0, error) != 0 ||
        private_directory(run_fd, &run_after, error) != 0 ||
        private_directory(parent_fd, &parent_after, error) != 0) return -1;
    if (!same_identity(&parent_before, &parent_after) ||
        !same_identity(&run_before, &run_after)) return fail(error, ESTALE);
    return named_join(parent_fd, run_leaf, &run_after, 0, error);
}

static int allowed_leaf(const char *leaf) {
    static const char *const names[] = {
        "00-start.json", "candidate-json.bin", "candidate-cbor.bin",
        "10-json-verifier.json", "11-json-graph.json", "12-json-roundtrip.json",
        "20-cbor-verifier.json", "21-cbor-graph.json", "22-cbor-roundtrip.json",
        "30-join-receipt.json", "31-authoritative-graph.json", "90-terminal.json"
    };
    if (leaf == NULL) return 0;
    for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); ++i)
        if (strcmp(leaf, names[i]) == 0) return 1;
    return 0;
}

static int regular_file(int fd, struct stat *metadata, int *error) {
    if (fstat(fd, metadata) != 0) return fail(error, errno);
    if (!S_ISREG(metadata->st_mode) ||
        (metadata->st_mode & 07777) != 0600 ||
        metadata->st_uid != geteuid() || metadata->st_nlink != 1)
        return fail(error, EACCES);
    if (metadata->st_size < 0 ||
        (uint64_t)metadata->st_size >= EPC_LEAF_BYTE_CEILING)
        return fail(error, EFBIG);
    return 0;
}

static int validate_file(int fd, int parent, const char *leaf,
                         struct stat *metadata, int *error) {
    if (regular_file(fd, metadata, error) != 0) return -1;
    return named_join(parent, leaf, metadata, 1, error);
}

static int pread_full(int fd, unsigned char *buffer, size_t size, int *error) {
    size_t offset = 0;
    while (offset < size) {
        ssize_t count = pread(fd, buffer + offset, size - offset, (off_t)offset);
        if (count < 0) {
            if (errno == EINTR) continue;
            return fail(error, errno);
        }
        if (count == 0) return fail(error, EIO);
        offset += (size_t)count;
    }
    unsigned char extra;
    for (;;) {
        ssize_t count = pread(fd, &extra, 1, (off_t)size);
        if (count < 0 && errno == EINTR) continue;
        if (count < 0) return fail(error, errno);
        if (count != 0) return fail(error, EFBIG);
        return 0;
    }
}

static int compare_file(int fd, const unsigned char *bytes, size_t size, int *error) {
    unsigned char buffer[8192];
    size_t offset = 0;
    while (offset < size) {
        size_t request = size - offset;
        if (request > sizeof(buffer)) request = sizeof(buffer);
        ssize_t count = pread(fd, buffer, request, (off_t)offset);
        if (count < 0) {
            if (errno == EINTR) continue;
            return fail(error, errno);
        }
        if (count == 0 || memcmp(buffer, bytes + offset, (size_t)count) != 0)
            return fail(error, EIO);
        offset += (size_t)count;
    }
    unsigned char extra;
    for (;;) {
        ssize_t count = pread(fd, &extra, 1, (off_t)size);
        if (count < 0 && errno == EINTR) continue;
        if (count < 0) return fail(error, errno);
        if (count != 0) return fail(error, EFBIG);
        return 0;
    }
}

int epc_write_leaf(int run_fd, const char *leaf,
                   const unsigned char *bytes, size_t size, int *error) {
    if (begin(error) != 0) return -1;
    if (!allowed_leaf(leaf) || (size != 0 && bytes == NULL)) return fail(error, EINVAL);
    if (size >= EPC_LEAF_BYTE_CEILING) return fail(error, EFBIG);
    struct stat directory_before, directory_after, created, after, final;
    if (private_directory(run_fd, &directory_before, error) != 0) return -1;
    int fd = openat(run_fd, leaf, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0600);
    if (fd < 0) return fail(error, errno);
    if (validate_file(fd, run_fd, leaf, &created, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (created.st_size != 0) return close_once(fd, EIO, error);
    size_t offset = 0;
    while (offset < size) {
        ssize_t count = write(fd, bytes + offset, size - offset);
        if (count < 0) {
            if (errno == EINTR) continue;
            return close_once(fd, errno, error);
        }
        if (count == 0) return close_once(fd, EIO, error);
        offset += (size_t)count;
    }
    if (validate_file(fd, run_fd, leaf, &after, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (!same_identity(&created, &after) || (uint64_t)after.st_size != size)
        return close_once(fd, ESTALE, error);
    if (compare_file(fd, bytes, size, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (fsync(fd) != 0) return close_once(fd, errno, error);
    if (fsync(run_fd) != 0) return close_once(fd, errno, error);
    if (compare_file(fd, bytes, size, error) != 0 ||
        validate_file(fd, run_fd, leaf, &final, error) != 0 ||
        private_directory(run_fd, &directory_after, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (!same_file(&after, &final) || !same_identity(&directory_before, &directory_after))
        return close_once(fd, ESTALE, error);
    return close_once(fd, 0, error);
}

long epc_read_leaf(int run_fd, const char *leaf,
                   unsigned char *buffer, size_t capacity, int *error) {
    if (begin(error) != 0) return -1;
    if (!allowed_leaf(leaf) || (capacity != 0 && buffer == NULL)) return fail(error, EINVAL);
    struct stat directory_before, directory_after, before, after;
    if (private_directory(run_fd, &directory_before, error) != 0) return -1;
    /* A substituted FIFO must not block before its fstat admission. */
    int fd = openat(run_fd, leaf, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK);
    if (fd < 0) return fail(error, errno);
    if (validate_file(fd, run_fd, leaf, &before, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    int flags = fcntl(fd, F_GETFL);
    if (flags < 0) return close_once(fd, errno, error);
    if (fcntl(fd, F_SETFL, flags & ~O_NONBLOCK) != 0) return close_once(fd, errno, error);
    if ((uint64_t)before.st_size > capacity) return close_once(fd, EFBIG, error);
    size_t size = (size_t)before.st_size;
    if (pread_full(fd, buffer, size, error) != 0 ||
        validate_file(fd, run_fd, leaf, &after, error) != 0 ||
        private_directory(run_fd, &directory_after, error) != 0) {
        int saved = *error;
        return close_once(fd, saved, error);
    }
    if (!same_file(&before, &after) || !same_identity(&directory_before, &directory_after))
        return close_once(fd, ESTALE, error);
    if (close_once(fd, 0, error) != 0) return -1;
    return (long)size;
}

int epc_close_directory(int fd, int *error) {
    if (begin(error) != 0) return -1;
    struct stat metadata;
    if (private_directory(fd, &metadata, error) != 0) return -1;
    return close_once(fd, 0, error);
}

EPCClockSample epc_clock_sample(void) {
    EPCClockSample sample = {0, 0, 0, 0};
    mach_timebase_info_data_t ratio = {0, 0};
    sample.ticks = mach_absolute_time();
    kern_return_t status = mach_timebase_info(&ratio);
    sample.numerator = ratio.numer;
    sample.denominator = ratio.denom;
    sample.error = status == KERN_SUCCESS ? 0 : (int)status;
    if (sample.error == 0 && (sample.numerator == 0 || sample.denominator == 0))
        sample.error = EINVAL;
    return sample;
}

static int boolean_entitlement(SecTaskRef task, CFStringRef key,
                                int required_value, int absent_allowed, int *error) {
    CFErrorRef failure = NULL;
    CFTypeRef value = SecTaskCopyValueForEntitlement(task, key, &failure);
    if (failure != NULL) {
        CFIndex code = CFErrorGetCode(failure);
        int raw = code >= INT_MIN && code <= INT_MAX && code != 0 ? (int)code : EIO;
        CFRelease(failure);
        if (value != NULL) CFRelease(value);
        return fail(error, raw);
    }
    if (value == NULL) return absent_allowed;
    int accepted = CFGetTypeID(value) == CFBooleanGetTypeID() &&
                   (CFBooleanGetValue((CFBooleanRef)value) != 0) == required_value;
    CFRelease(value);
    return accepted;
}

int epc_sandbox_entitlements(int *error) {
    if (begin(error) != 0) return -1;
    SecTaskRef task = SecTaskCreateFromSelf(kCFAllocatorDefault);
    if (task == NULL) return fail(error, EIO);
    int accepted = boolean_entitlement(task, CFSTR("com.apple.security.app-sandbox"), 1, 0, error);
    if (accepted == 1)
        accepted = boolean_entitlement(task, CFSTR("com.apple.security.network.client"), 0, 1, error);
    if (accepted == 1)
        accepted = boolean_entitlement(task, CFSTR("com.apple.security.network.server"), 0, 1, error);
    CFRelease(task);
    return accepted;
}

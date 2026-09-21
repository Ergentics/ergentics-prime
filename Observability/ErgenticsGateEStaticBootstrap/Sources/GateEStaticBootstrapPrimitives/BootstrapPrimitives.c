#include "BootstrapPrimitives.h"

#if !defined(__APPLE__) || !defined(__MACH__)
#error "The closed static bootstrap primitives require Darwin."
#endif

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <mach/mach_time.h>
#include <signal.h>
#include <spawn.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

_Static_assert(sizeof(pid_t) == sizeof(int32_t), "Darwin PID width changed");
_Static_assert(sizeof(off_t) == sizeof(int64_t), "Darwin offset width changed");

static GEBSCallResult call_result(int64_t value, int error, int entered) {
    GEBSCallResult result = {value, error, entered, 0};
    return result;
}

static GEBSCallResult rejection(int error) {
    return call_result(-1, error, 0);
}

static int valid_component(const char *component) {
    if (component == NULL) return 0;
    size_t length = strnlen(component, NAME_MAX + 1);
    return length > 0 && length <= NAME_MAX
        && strcmp(component, ".") != 0 && strcmp(component, "..") != 0
        && memchr(component, '/', length) == NULL;
}

static GEBSCallResult reject_open_descriptor(int descriptor, int primary_error) {
    GEBSCallResult result = call_result(-1, primary_error, 1);
    if (close(descriptor) != 0) result.cleanup_error_number = errno;
    return result;
}

uint32_t gebs_effective_uid(void) { return (uint32_t)geteuid(); }

GEBSCallResult gebs_set_private_umask(void) {
    return call_result((int64_t)umask(0077), 0, 1);
}

GEBSCallResult gebs_open_root_directory(void) {
    int fd = open("/", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    return call_result(fd, fd < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_open_directory_at(int32_t parent, const char *component) {
    if (parent < 0 || !valid_component(component)) return rejection(EINVAL);
    int fd = openat(parent, component,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    return call_result(fd, fd < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_open_regular_read_at(int32_t parent, const char *component) {
    if (parent < 0 || !valid_component(component)) return rejection(EINVAL);
    /* Temporary open-time refinement: a substituted FIFO cannot block before
     * its type is checked. No successful descriptor retains O_NONBLOCK. */
    int fd = openat(parent, component,
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK);
    if (fd < 0) return call_result(-1, errno, 1);
    struct stat metadata;
    if (fstat(fd, &metadata) != 0) return reject_open_descriptor(fd, errno);
    if (!S_ISREG(metadata.st_mode)) return reject_open_descriptor(fd, EINVAL);
    int flags = fcntl(fd, F_GETFL);
    if (flags < 0) return reject_open_descriptor(fd, errno);
    if (fcntl(fd, F_SETFL, flags & ~O_NONBLOCK) != 0)
        return reject_open_descriptor(fd, errno);
    return call_result(fd, 0, 1);
}

GEBSCallResult gebs_create_run_root(int32_t parent) {
    if (parent < 0) return rejection(EINVAL);
    int rc = mkdirat(parent, "gate-e-static-bootstrap-c51f796-r1", 0700);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_create_workspace(int32_t run_root) {
    if (run_root < 0) return rejection(EINVAL);
    int rc = mkdirat(run_root, "workspace", 0700);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_create_leaf(int32_t run_root, const char *leaf) {
    static const char *const allowed[] = {
        "00-start.json", "90-terminal.json",
        "candidate-json.bin", "candidate-cbor.bin",
        "10-json-enter.json", "11-json-verifier.json", "12-json-graph.json",
        "13-json-roundtrip.json", "14-json-stderr.bin", "15-json-exit.json",
        "20-cbor-enter.json", "21-cbor-verifier.json", "22-cbor-graph.json",
        "23-cbor-roundtrip.json", "24-cbor-stderr.bin", "25-cbor-exit.json",
        "30-join-enter.json", "31-join-receipt.json",
        "32-authoritative-static-graph.json", "33-join-stderr.bin", "34-join-exit.json"
    };
    if (run_root < 0 || !valid_component(leaf)) return rejection(EINVAL);
    int admitted = 0;
    for (size_t i = 0; i < sizeof(allowed) / sizeof(allowed[0]); ++i) {
        if (strcmp(leaf, allowed[i]) == 0) { admitted = 1; break; }
    }
    if (!admitted) return rejection(EINVAL);
    int fd = openat(run_root, leaf,
                    O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0600);
    return call_result(fd, fd < 0 ? errno : 0, 1);
}

static GEBSStat stat_fields(const struct stat *metadata) {
    GEBSStat result = {0};
    result.device = (uint64_t)(uint32_t)metadata->st_dev;
    result.inode = (uint64_t)metadata->st_ino;
    result.file_type = (uint32_t)(metadata->st_mode & S_IFMT);
    result.mode = (uint32_t)(metadata->st_mode & 07777);
    result.uid = (uint32_t)metadata->st_uid;
    result.gid = (uint32_t)metadata->st_gid;
    result.nlink = (uint64_t)metadata->st_nlink;
    result.size = (int64_t)metadata->st_size;
    result.mtime_seconds = (int64_t)metadata->st_mtimespec.tv_sec;
    result.mtime_nanoseconds = (int64_t)metadata->st_mtimespec.tv_nsec;
    result.ctime_seconds = (int64_t)metadata->st_ctimespec.tv_sec;
    result.ctime_nanoseconds = (int64_t)metadata->st_ctimespec.tv_nsec;
    return result;
}

GEBSStatResult gebs_stat(int32_t descriptor) {
    GEBSStatResult result = {0};
    if (descriptor < 0) { result.call = rejection(EINVAL); return result; }
    struct stat metadata;
    int rc = fstat(descriptor, &metadata);
    result.call = call_result(rc, rc < 0 ? errno : 0, 1);
    if (rc == 0) result.metadata = stat_fields(&metadata);
    return result;
}

GEBSStatResult gebs_stat_at(int32_t parent, const char *component) {
    GEBSStatResult result = {0};
    if (parent < 0 || !valid_component(component)) {
        result.call = rejection(EINVAL); return result;
    }
    struct stat metadata;
    int rc = fstatat(parent, component, &metadata, AT_SYMLINK_NOFOLLOW);
    result.call = call_result(rc, rc < 0 ? errno : 0, 1);
    if (rc == 0) result.metadata = stat_fields(&metadata);
    return result;
}

GEBSCallResult gebs_pread(int32_t descriptor, void *buffer, size_t count, int64_t offset) {
    if (descriptor < 0 || (buffer == NULL && count != 0)
        || count > (size_t)SSIZE_MAX || offset < 0) return rejection(EINVAL);
    ssize_t rc = pread(descriptor, buffer, count, (off_t)offset);
    return call_result((int64_t)rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_write(int32_t descriptor, const void *buffer, size_t count) {
    if (descriptor < 0 || (buffer == NULL && count != 0)
        || count > (size_t)SSIZE_MAX) return rejection(EINVAL);
    ssize_t rc = write(descriptor, buffer, count);
    return call_result((int64_t)rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_sync(int32_t descriptor) {
    if (descriptor < 0) return rejection(EINVAL);
    int rc = fsync(descriptor);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_close(int32_t descriptor) {
    if (descriptor < 0) return rejection(EINVAL);
    int rc = close(descriptor);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_cursor(int32_t descriptor) {
    if (descriptor < 0) return rejection(EINVAL);
    off_t rc = lseek(descriptor, 0, SEEK_CUR);
    return call_result((int64_t)rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_access_mode(int32_t descriptor) {
    if (descriptor < 0) return rejection(EINVAL);
    int rc = fcntl(descriptor, F_GETFL);
    return call_result(rc < 0 ? -1 : (rc & O_ACCMODE), rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_park_descriptor(int32_t descriptor) {
    if (descriptor < 0) return rejection(EINVAL);
    int fd = fcntl(descriptor, F_DUPFD_CLOEXEC, 32);
    return call_result(fd, fd < 0 ? errno : 0, 1);
}

GEBSDirectoryResult gebs_directory_names(int32_t descriptor, void *buffer, size_t capacity) {
    GEBSDirectoryResult result = {0};
    if (descriptor < 0 || buffer == NULL || capacity == 0 || capacity > 65536) {
        result.call = rejection(EINVAL); return result;
    }
    /* openat creates a fresh cursor; dup would share the original directory's
     * open-file description and is deliberately not used for enumeration. */
    int fd = openat(descriptor, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (fd < 0) { result.call = call_result(-1, errno, 1); return result; }
    DIR *directory = fdopendir(fd);
    if (directory == NULL) {
        int primary_error = errno;
        result.close_result = close(fd);
        result.close_error_number = result.close_result != 0 ? errno : 0;
        result.call = call_result(-1, primary_error, 1);
        return result;
    }
    size_t used = 0;
    int primary_error = 0;
    for (;;) {
        errno = 0;
        struct dirent *entry = readdir(directory);
        if (entry == NULL) { primary_error = errno; break; }
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;
        size_t length = strnlen(entry->d_name, NAME_MAX + 1);
        if (length == 0 || length > NAME_MAX || length + 1 > capacity - used) {
            primary_error = ENOBUFS; break;
        }
        memcpy((char *)buffer + used, entry->d_name, length + 1);
        used += length + 1;
    }
    result.close_result = closedir(directory);
    result.close_error_number = result.close_result != 0 ? errno : 0;
    result.call = call_result(primary_error == 0 ? (int64_t)used : -1, primary_error, 1);
    return result;
}

GEBSClockSample gebs_clock_sample(void) {
    GEBSClockSample result = {0};
    mach_timebase_info_data_t timebase = {0};
    result.ticks = mach_continuous_time();
    result.kernel_result = (int32_t)mach_timebase_info(&timebase);
    result.numerator = timebase.numer;
    result.denominator = timebase.denom;
    return result;
}

GEBSCallResult gebs_poll_pause(void) {
    const struct timespec request = {0, 10000000};
    int rc = nanosleep(&request, NULL);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

GEBSCallResult gebs_configure_sigchld(void) {
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = SIG_DFL;
    action.sa_flags = 0; /* In particular, never SA_NOCLDWAIT. */
    if (sigemptyset(&action.sa_mask) != 0) return rejection(errno);
    int rc = sigaction(SIGCHLD, &action, NULL);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

/* These paths and logical argv[0] values are distinct compiled constants. */
static const char json_image[] = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/gate-e-static-release-builds-04c5324-2026-08-30-r1/A/scratch/arm64-apple-macosx/release/ErgenticsGateEJSONProjector";
static const char cbor_image[] = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/gate-e-static-release-builds-04c5324-2026-08-30-r1/A/scratch/arm64-apple-macosx/release/ErgenticsGateECBORProjector";
static const char join_image[] = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/gate-e-static-release-builds-04c5324-2026-08-30-r1/A/scratch/arm64-apple-macosx/release/ErgenticsGateEDualGraphJoin";

enum {
    SETUP_ARGUMENTS = 1, SETUP_FD_PLAN = 2, SETUP_SIGCHLD = 3,
    SETUP_ACTIONS_INIT = 4, SETUP_ATTRIBUTES_INIT = 5, SETUP_CWD = 6,
    SETUP_DUP = 7, SETUP_CLOSE = 8, SETUP_PGROUP = 9,
    SETUP_SIGNAL_SETS = 10, SETUP_SIGNAL_DEFAULTS = 11,
    SETUP_SIGNAL_MASK = 12, SETUP_FLAGS = 13
};

typedef struct { int source; int target; int input; } FixedFD;

static int validate_fixed_fds(int cwd, const FixedFD *mapping, size_t count) {
    if (cwd < 32 || count == 0 || count > 9) return EINVAL;
    struct stat cwd_stat;
    if (fstat(cwd, &cwd_stat) != 0) return errno;
    if (!S_ISDIR(cwd_stat.st_mode)) return EINVAL;
    int cwd_flags = fcntl(cwd, F_GETFD);
    if (cwd_flags < 0) return errno;
    if ((cwd_flags & FD_CLOEXEC) == 0) return EINVAL;
    struct stat snapshots[9];
    for (size_t i = 0; i < count; ++i) {
        int fd = mapping[i].source;
        if (fd < 32 || fd == cwd || mapping[i].target < 0 || mapping[i].target > 8)
            return EINVAL;
        if (fstat(fd, &snapshots[i]) != 0) return errno;
        if (!S_ISREG(snapshots[i].st_mode) || snapshots[i].st_nlink != 1
            || snapshots[i].st_uid != geteuid()
            || (snapshots[i].st_mode & 07777) != 0600) return EINVAL;
        int fd_flags = fcntl(fd, F_GETFD);
        if (fd_flags < 0) return errno;
        if ((fd_flags & FD_CLOEXEC) == 0) return EINVAL;
        int flags = fcntl(fd, F_GETFL);
        if (flags < 0) return errno;
        if ((flags & (O_APPEND | O_NONBLOCK)) != 0) return EINVAL;
        int access = flags & O_ACCMODE;
        if (mapping[i].input ? access != O_RDONLY : (access != O_WRONLY && access != O_RDWR))
            return EINVAL;
        off_t position = lseek(fd, 0, SEEK_CUR);
        if (position < 0) return errno;
        if (position != 0 || (mapping[i].input ? snapshots[i].st_size <= 0 : snapshots[i].st_size != 0))
            return EINVAL;
        for (size_t j = 0; j < i; ++j) {
            if (mapping[j].source == fd || mapping[j].target == mapping[i].target
                || (snapshots[j].st_dev == snapshots[i].st_dev
                    && snapshots[j].st_ino == snapshots[i].st_ino)) return EINVAL;
        }
    }
    return 0;
}

/* Private shared mechanics only: no caller outside this translation unit can
 * select image, argv, environment, target descriptors or spawn attributes. */
static void spawn_fixed(const char *image, const char *logical_name,
                        int cwd, const FixedFD *mapping, size_t count,
                        GEBSSpawnResult *result) {
    if (result == NULL) return; /* No out-owner slot means no spawn entry. */
    memset(result, 0, sizeof(*result));
    result->pid = -1;
    result->spawn_result = -1;
    int rc = validate_fixed_fds(cwd, mapping, count);
    if (rc != 0) { result->setup_error = rc; result->setup_step = SETUP_FD_PLAN; return; }
    struct sigaction current;
    if (sigaction(SIGCHLD, NULL, &current) != 0) {
        result->setup_error = errno; result->setup_step = SETUP_SIGCHLD; return;
    }
    if (current.sa_handler != SIG_DFL || (current.sa_flags & SA_NOCLDWAIT) != 0) {
        result->setup_error = EINVAL; result->setup_step = SETUP_SIGCHLD; return;
    }
    posix_spawn_file_actions_t actions;
    posix_spawnattr_t attributes;
    int have_actions = 0;
    int have_attributes = 0;
    int step = SETUP_ACTIONS_INIT;
    rc = posix_spawn_file_actions_init(&actions);
    if (rc != 0) goto finish;
    have_actions = 1;
    step = SETUP_ATTRIBUTES_INIT;
    rc = posix_spawnattr_init(&attributes);
    if (rc != 0) goto finish;
    have_attributes = 1;
    step = SETUP_CWD;
    /* CLOEXEC_DEFAULT requires explicit cwd inheritance before fchdir; the
     * existing late addclose below removes this descriptor before exec. */
    rc = posix_spawn_file_actions_addinherit_np(&actions, cwd);
    if (rc != 0) goto finish;
    /* The non-np spelling is macOS26-only; this descriptor action exists
     * since10.15 and preserves the worker's macOS14 deployment floor. */
    rc = posix_spawn_file_actions_addfchdir_np(&actions, cwd);
    if (rc != 0) goto finish;
    step = SETUP_DUP;
    for (size_t i = 0; i < count; ++i) {
        rc = posix_spawn_file_actions_adddup2(&actions, mapping[i].source, mapping[i].target);
        if (rc != 0) goto finish;
    }
    step = SETUP_CLOSE;
    for (size_t i = 0; i < count; ++i) {
        rc = posix_spawn_file_actions_addclose(&actions, mapping[i].source);
        if (rc != 0) goto finish;
    }
    rc = posix_spawn_file_actions_addclose(&actions, cwd);
    if (rc != 0) goto finish;
    step = SETUP_PGROUP;
    rc = posix_spawnattr_setpgroup(&attributes, 0);
    if (rc != 0) goto finish;
    sigset_t defaults;
    sigset_t mask;
    step = SETUP_SIGNAL_SETS;
    if (sigemptyset(&defaults) != 0 || sigemptyset(&mask) != 0) { rc = errno; goto finish; }
    for (int number = 1; number < NSIG; ++number) {
        if (number == SIGKILL || number == SIGSTOP) continue;
        if (sigaddset(&defaults, number) != 0) { rc = errno; goto finish; }
    }
    step = SETUP_SIGNAL_DEFAULTS;
    rc = posix_spawnattr_setsigdefault(&attributes, &defaults);
    if (rc != 0) goto finish;
    step = SETUP_SIGNAL_MASK;
    rc = posix_spawnattr_setsigmask(&attributes, &mask);
    if (rc != 0) goto finish;
    step = SETUP_FLAGS;
    rc = posix_spawnattr_setflags(&attributes,
        POSIX_SPAWN_CLOEXEC_DEFAULT | POSIX_SPAWN_SETPGROUP
        | POSIX_SPAWN_SETSIGDEF | POSIX_SPAWN_SETSIGMASK);
    if (rc != 0) goto finish;
    char *const argv[] = {(char *)logical_name, NULL};
    char *const environment[] = {NULL};
    pid_t pid = -1;
    result->spawn_entered = 1;
    rc = posix_spawn(&pid, image, &actions, &attributes, argv, environment);
    result->spawn_result = rc;
    if (rc == 0) result->pid = (int32_t)pid;
    /* No allocation, close, journal operation or teardown precedes the
     * ownership transfer above. Destroy errors never overwrite this PID. */
    rc = 0;
finish:
    if (!result->spawn_entered && rc != 0) {
        result->setup_error = rc;
        result->setup_step = step;
    }
    if (have_attributes) {
        result->attributes_destroy_entered = 1;
        result->attributes_destroy_result = posix_spawnattr_destroy(&attributes);
    }
    if (have_actions) {
        result->actions_destroy_entered = 1;
        result->actions_destroy_result = posix_spawn_file_actions_destroy(&actions);
    }
}

static void reject_spawn_arguments(GEBSSpawnResult *result) {
    if (result == NULL) return;
    memset(result, 0, sizeof(*result));
    result->pid = -1;
    result->spawn_result = -1;
    result->setup_error = EINVAL;
    result->setup_step = SETUP_ARGUMENTS;
}

void gebs_spawn_json(const GEBSProjectorFDs *d, GEBSSpawnResult *result) {
    if (d == NULL) { reject_spawn_arguments(result); return; }
    const FixedFD mapping[] = {
        {d->input, 0, 1}, {d->verifier, 1, 0}, {d->stderr_file, 2, 0},
        {d->graph, 3, 0}, {d->roundtrip, 4, 0}
    };
    spawn_fixed(json_image, "ErgenticsGateEJSONProjector", d->cwd, mapping, 5, result);
}

void gebs_spawn_cbor(const GEBSProjectorFDs *d, GEBSSpawnResult *result) {
    if (d == NULL) { reject_spawn_arguments(result); return; }
    const FixedFD mapping[] = {
        {d->input, 0, 1}, {d->verifier, 1, 0}, {d->stderr_file, 2, 0},
        {d->graph, 3, 0}, {d->roundtrip, 4, 0}
    };
    spawn_fixed(cbor_image, "ErgenticsGateECBORProjector", d->cwd, mapping, 5, result);
}

void gebs_spawn_join(const GEBSJoinFDs *d, GEBSSpawnResult *result) {
    if (d == NULL) { reject_spawn_arguments(result); return; }
    const FixedFD mapping[] = {
        {d->json_graph, 0, 1}, {d->receipt, 1, 0}, {d->stderr_file, 2, 0},
        {d->json_verifier, 3, 1}, {d->json_roundtrip, 4, 1},
        {d->cbor_graph, 5, 1}, {d->cbor_verifier, 6, 1},
        {d->cbor_roundtrip, 7, 1}, {d->graph, 8, 0}
    };
    spawn_fixed(join_image, "ErgenticsGateEDualGraphJoin", d->cwd, mapping, 9, result);
}

static GEBSWaitResult wait_exact(int32_t pid, int options) {
    GEBSWaitResult result = {0};
    if (pid <= 1) { result.call = rejection(EINVAL); return result; }
    int status = 0;
    pid_t observed = waitpid((pid_t)pid, &status, options);
    result.call = call_result((int64_t)observed, observed < 0 ? errno : 0, 1);
    if (observed == (pid_t)pid) {
        result.status = status;
        result.exited = WIFEXITED(status) ? 1 : 0;
        result.exit_code = result.exited ? WEXITSTATUS(status) : 0;
        result.signaled = WIFSIGNALED(status) ? 1 : 0;
        result.term_signal = result.signaled ? WTERMSIG(status) : 0;
    }
    return result;
}

GEBSWaitResult gebs_wait_exact_nonblocking(int32_t pid) { return wait_exact(pid, WNOHANG); }
GEBSWaitResult gebs_reap_exact(int32_t pid) { return wait_exact(pid, 0); }

GEBSCallResult gebs_kill_exact(int32_t pid) {
    if (pid <= 1) return rejection(EINVAL);
    int rc = kill((pid_t)pid, SIGKILL);
    return call_result(rc, rc < 0 ? errno : 0, 1);
}

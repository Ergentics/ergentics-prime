#ifndef ERGENTICS_GATE_E_STATIC_BOOTSTRAP_PRIMITIVES_H
#define ERGENTICS_GATE_E_STATIC_BOOTSTRAP_PRIMITIVES_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Primitive results preserve primary errors independently of cleanup errors.
 * No wrapper retries a close or signal. `entered` describes the primitive's
 * primary syscall, not proof that any child was entered. */
typedef struct {
    int64_t value;
    int32_t error_number;
    int32_t entered;
    int32_t cleanup_error_number;
} GEBSCallResult;

typedef struct {
    uint64_t device;
    uint64_t inode;
    uint32_t file_type;
    uint32_t mode;
    uint32_t uid;
    uint32_t gid;
    uint64_t nlink;
    int64_t size;
    int64_t mtime_seconds;
    int64_t mtime_nanoseconds;
    int64_t ctime_seconds;
    int64_t ctime_nanoseconds;
} GEBSStat;

typedef struct {
    GEBSCallResult call;
    GEBSStat metadata;
} GEBSStatResult;

typedef struct {
    GEBSCallResult call;
    int32_t close_result;
    int32_t close_error_number;
} GEBSDirectoryResult;

typedef struct {
    uint64_t ticks;
    uint32_t numerator;
    uint32_t denominator;
    int32_t kernel_result;
} GEBSClockSample;

typedef struct {
    int32_t cwd;
    int32_t input;
    int32_t verifier;
    int32_t stderr_file;
    int32_t graph;
    int32_t roundtrip;
} GEBSProjectorFDs;

typedef struct {
    int32_t cwd;
    int32_t json_graph;
    int32_t json_verifier;
    int32_t json_roundtrip;
    int32_t cbor_graph;
    int32_t cbor_verifier;
    int32_t cbor_roundtrip;
    int32_t receipt;
    int32_t stderr_file;
    int32_t graph;
} GEBSJoinFDs;

typedef struct {
    int32_t setup_error;
    int32_t setup_step;
    int32_t spawn_entered;
    int32_t spawn_result;
    int32_t pid;
    int32_t actions_destroy_entered;
    int32_t actions_destroy_result;
    int32_t attributes_destroy_entered;
    int32_t attributes_destroy_result;
} GEBSSpawnResult;

typedef struct {
    GEBSCallResult call;
    int32_t status;
    int32_t exited;
    int32_t exit_code;
    int32_t signaled;
    int32_t term_signal;
} GEBSWaitResult;

uint32_t gebs_effective_uid(void);
GEBSCallResult gebs_set_private_umask(void);
GEBSCallResult gebs_open_root_directory(void);
GEBSCallResult gebs_open_directory_at(int32_t parent, const char *component);
/* O_NONBLOCK prevents a substituted FIFO from blocking open. The wrapper
 * immediately requires a regular file, then clears O_NONBLOCK. A successful
 * returned description has the frozen O_RDONLY|O_NOFOLLOW|O_CLOEXEC mode. */
GEBSCallResult gebs_open_regular_read_at(int32_t parent, const char *component);
/* These are mkdirat results (0 on success), not descriptors. Open and join
 * the new fixed directory separately; failed states are never removed. */
GEBSCallResult gebs_create_run_root(int32_t parent);
GEBSCallResult gebs_create_workspace(int32_t run_root);
/* Only the exact twenty-one frozen leaves are accepted; success is an owned
 * O_RDWR descriptor. Parent readback uses pread without consuming a cursor. */
GEBSCallResult gebs_create_leaf(int32_t run_root, const char *leaf);
GEBSStatResult gebs_stat(int32_t descriptor);
GEBSStatResult gebs_stat_at(int32_t parent, const char *component);
GEBSCallResult gebs_pread(int32_t descriptor, void *buffer, size_t count, int64_t offset);
GEBSCallResult gebs_write(int32_t descriptor, const void *buffer, size_t count);
GEBSCallResult gebs_sync(int32_t descriptor);
GEBSCallResult gebs_close(int32_t descriptor);
GEBSCallResult gebs_cursor(int32_t descriptor);
GEBSCallResult gebs_access_mode(int32_t descriptor);
GEBSCallResult gebs_park_descriptor(int32_t descriptor);
/* Fresh directory description; output is unsorted NUL-separated names without
 * dot entries. Capacity must be 1...65536; no partial listing is accepted. */
GEBSDirectoryResult gebs_directory_names(int32_t descriptor, void *buffer, size_t capacity);
GEBSClockSample gebs_clock_sample(void);
GEBSCallResult gebs_poll_pause(void);
GEBSCallResult gebs_configure_sigchld(void);

/* Inputs are already-owned, separately admitted descriptor slots >=32. These
 * functions never accept executable paths, argv, environment or role IDs.
 * On spawn success PID ownership is written to `result` BEFORE teardown. */
void gebs_spawn_json(const GEBSProjectorFDs *descriptors, GEBSSpawnResult *result);
void gebs_spawn_cbor(const GEBSProjectorFDs *descriptors, GEBSSpawnResult *result);
void gebs_spawn_join(const GEBSJoinFDs *descriptors, GEBSSpawnResult *result);

/* Swift's sole-owner state machine must prove OWNED_UNREAPED before these
 * exact-positive-PID operations. There is no wait-any, group, zero-signal,
 * STOP, CONT, adoption or auto-cleanup operation in this interface. */
GEBSWaitResult gebs_wait_exact_nonblocking(int32_t pid);
GEBSWaitResult gebs_reap_exact(int32_t pid);
GEBSCallResult gebs_kill_exact(int32_t pid);

#ifdef __cplusplus
}
#endif

#endif

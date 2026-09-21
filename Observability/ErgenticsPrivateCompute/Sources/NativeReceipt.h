#ifndef ERGENTICS_NATIVE_RECEIPT_H
#define ERGENTICS_NATIVE_RECEIPT_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Leaf sizes must be strictly below this ceiling. */
#define EPC_LEAF_BYTE_CEILING (1024U * 1024U)

typedef struct EPCClockSample {
    uint64_t ticks;
    uint32_t numerator;
    uint32_t denominator;
    int error;
} EPCClockSample;

/* Every error pointer is required. Filesystem calls return -1 and the first
 * errno on failure; successful calls set *error to zero. An internal close is
 * never retried, including after EINTR; callers must also close each returned
 * owned descriptor only once. No path is removed, replaced, repaired, or
 * chmodded on any failure.
 *
 * Successful directory opens return an O_RDONLY|O_CLOEXEC descriptor >= 3.
 * The private-parent path comes only from the application's Application
 * Support lookup. O_NOFOLLOW protects its final component; its ancestors are
 * not descriptor-held by this interface. Named joins are snapshots, not watches.
 */
int epc_open_private_directory(const char *path, int *error);
int epc_create_run(int parent_fd, int *error);
int epc_open_run(int parent_fd, int *error);
/* Rejoins the existing held run descriptor to its fixed parent/name at this
 * observation cut. Returns zero on success; never reopens or replaces it. */
int epc_revalidate_run(int parent_fd, int run_fd, int *error);
int epc_close_directory(int fd, int *error);

/* Only the twelve control-frozen leaf names are admitted. Writes create a
 * fresh 0600 regular file exclusively, compare complete pread bytes, and check
 * file/directory fsync. Partial files are permanently retained on failure.
 * Reads open a fresh description and return the exact byte count or -1.
 * Temporary O_NONBLOCK protects admission against FIFO substitution; a
 * successfully admitted regular-file description has that flag cleared.
 */
int epc_write_leaf(int run_fd, const char *leaf,
                   const unsigned char *bytes, size_t size, int *error);
long epc_read_leaf(int run_fd, const char *leaf,
                   unsigned char *buffer, size_t capacity, int *error);

/* mach_absolute_time is the timebase's monotonic tick clock, not CPU time or
 * energy, and unlike mach_continuous_time it does not advance during sleep.
 * Nonzero error is the mach_timebase_info result or EINVAL for an invalid ratio.
 */
EPCClockSample epc_clock_sample(void);

/* Returns 1 only for Boolean app-sandbox=true and both network entitlements
 * absent or Boolean false; 0 means a policy rejection. -1 means inspection
 * failed: *error is the CFError integer code when representable, otherwise EIO.
 * No process census, network probe, or environment inspection occurs here.
 */
int epc_sandbox_entitlements(int *error);

#ifdef __cplusplus
}
#endif
#endif

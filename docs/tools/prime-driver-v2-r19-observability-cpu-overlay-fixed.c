#include <errno.h>
#include <sqlite3.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

int
prime_r19_overlay_full_sync_file(int descriptor)
{
    if (fsync(descriptor) == -1) {
        return -1;
    }
    return fcntl(descriptor, F_FULLFSYNC);
}

int
prime_r19_overlay_open_directory_no_follow_any(const char *absolute_path)
{
    return open(absolute_path,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY);
}

int
prime_r19_overlay_openat_directory_no_follow(int parent_descriptor,
    const char *leaf)
{
    return openat(parent_descriptor, leaf,
        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY);
}

int
prime_r19_overlay_openat_readonly_no_follow(int root_descriptor,
    const char *leaf)
{
    return openat(root_descriptor, leaf,
        O_RDONLY | O_NONBLOCK | O_CLOEXEC | O_NOFOLLOW_ANY);
}

int
prime_r19_overlay_mkdirat_private(int parent_descriptor, const char *leaf)
{
    return mkdirat(parent_descriptor, leaf, 0700);
}

int
prime_r19_overlay_openat_create_exclusive_private(int root_descriptor,
    const char *leaf)
{
    return openat(root_descriptor, leaf,
        O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY, 0600);
}

int
prime_r19_overlay_sqlite_harden_connection(sqlite3 *database)
{
    int result = sqlite3_db_config(
        database, SQLITE_DBCONFIG_DEFENSIVE, 1, NULL);
    if (result != SQLITE_OK) {
        return result;
    }
    return sqlite3_db_config(
        database, SQLITE_DBCONFIG_TRUSTED_SCHEMA, 0, NULL);
}

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

// Test-only process: no shell, GPU, model, or app resources. Compile separately
// and pass its absolute path as PRIME_RUNTIME_PROCESS_FIXTURE_PATH to XCTest.
extern char **environ;
static void pid_file(const char *name, pid_t pid) {
    int fd = open(name, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, 0600);
    if (fd < 0 || dprintf(fd, "%d\n", pid) <= 0 || close(fd) != 0) _exit(92);
}
static void emit_report(void) {
    const char *bytes = "{\"evidence_id\":\"ergentics_prime_native_decoder_maintained_runtime_initialization_v1\",\"bounded_mlx_runtime_initialization_established\":true,\"decoder_forward_observed\":false,\"checkpoint_io_observed\":false,\"sandbox_application_synchronization_lease\":{\"policy\":\"signed_sandbox_application_internal_synchronization_v1\",\"applicationIdentifier\":\"com.ergentics.provenance\",\"helperIdentifier\":\"com.ergentics.provenance.prime-runtime\"},\"metal_device\":{\"index_zero_name\":\"Native process fixture\"},\"metallib\":{\"sha256\":\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"}}";
    size_t count = strlen(bytes), offset = 0;
    while (offset < count) {
        ssize_t written = write(STDOUT_FILENO, bytes + offset, count - offset);
        if (written <= 0) _exit(93);
        offset += (size_t)written;
    }
}
int main(int argc, char **argv) {
    alarm(10); // Independent fixture fail-safe; production cleanup is much shorter.
    if (argc != 3 || strcmp(argv[1], "--check-runtime") != 0) return 90;
    struct stat requested, cwd;
    char byte;
    if (stat(argv[2], &requested) != 0 || stat(".", &cwd) != 0 ||
        requested.st_dev != cwd.st_dev || requested.st_ino != cwd.st_ino ||
        getpgrp() != getpid() || read(STDIN_FILENO, &byte, 1) != 0 ||
        !environ[0] || environ[1] || strcmp(environ[0], "MLX_ENABLE_TF32=0") != 0) return 91;
    int mode_fd = open("fixture-mode", O_RDONLY | O_NOFOLLOW);
    char mode[32] = {0};
    if (mode_fd < 0 || read(mode_fd, mode, sizeof(mode) - 1) <= 0 || close(mode_fd) != 0) return 92;
    pid_file("helper.pid", getpid());
    if (strcmp(mode, "linger") == 0) {
        signal(SIGTERM, SIG_IGN);
        for (;;) pause();
    }
    if (strcmp(mode, "descendant") == 0) {
        int ready[2];
        if (pipe(ready) != 0) return 94;
        pid_t child = fork();
        if (child < 0) return 95;
        if (child == 0) {
            close(ready[0]);
            alarm(10);
            pid_file("descendant.pid", getpid());
            if (write(ready[1], "x", 1) != 1) _exit(96);
            close(ready[1]);
            for (;;) pause(); // Holds both inherited output pipes until group cleanup.
        }
        close(ready[1]);
        if (read(ready[0], &byte, 1) != 1) return 97;
        close(ready[0]);
    } else if (strcmp(mode, "normal") != 0) return 98;
    emit_report();
    return 0;
}

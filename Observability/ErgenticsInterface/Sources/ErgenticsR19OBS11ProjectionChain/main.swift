import Darwin
import DisposalProjectionCore

@main
enum ErgenticsR19OBS11ProjectionChainMain {
    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(64) }
        guard environ.pointee == nil else { _exit(64) }

        var cwdBytes = [CChar](repeating: 0, count: Int(PATH_MAX))
        let cwdRead = cwdBytes.withUnsafeMutableBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return nil }
            return getcwd(base, buffer.count)
        }
        guard cwdRead != nil else { _exit(64) }
        let cwdMatches = cwdBytes.withUnsafeBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return false }
            return strcmp(base, "/private/var/empty") == 0
        }
        guard cwdMatches else { _exit(64) }

        var standardInputStatus = stat()
        var nullStatus = stat()
        guard fstat(STDIN_FILENO, &standardInputStatus) == 0,
              lstat("/dev/null", &nullStatus) == 0,
              standardInputStatus.st_dev == nullStatus.st_dev,
              standardInputStatus.st_ino == nullStatus.st_ino,
              standardInputStatus.st_gen == nullStatus.st_gen,
              standardInputStatus.st_rdev == nullStatus.st_rdev,
              standardInputStatus.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              nullStatus.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR)
        else {
            _exit(64)
        }

        do {
            try DisposalR19OBS11ProjectionChain.runFrozen()
            _exit(0)
        } catch {
            _exit(70)
        }
    }
}

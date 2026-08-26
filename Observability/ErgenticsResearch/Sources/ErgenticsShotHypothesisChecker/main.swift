import Darwin
import ErgenticsShotResearchCore
import Foundation

@main
enum ErgenticsShotHypothesisCheckerMain {
    private static let maximumOutputBytes = 16_384

    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(64) }
        guard isClosedFoundationBootstrapEnvironment() else { _exit(64) }

        do {
            let clock = try CheckerTransportClock()
            let input = try readBoundedCanonicalInput(clock: clock)
            let report = try DisposalShotHypothesisChecker.evaluate(
                exactCanonicalJSON: input)
            try writeAll(report.canonicalJSONWithLF, clock: clock)
            _exit(0)
        } catch let failure as CheckerTransportFailure {
            _exit(failure.exitCode)
        } catch {
            _exit(70)
        }
    }

    private static func readBoundedCanonicalInput(
        clock: CheckerTransportClock
    ) throws -> Data {
        let priorFlags = fcntl(STDIN_FILENO, F_GETFL)
        guard priorFlags >= 0,
              fcntl(STDIN_FILENO, F_SETFL, priorFlags | O_NONBLOCK) == 0
        else {
            throw CheckerTransportFailure(exitCode: 70)
        }
        defer { _ = fcntl(STDIN_FILENO, F_SETFL, priorFlags) }
        var input = Data()
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while true {
            var descriptor = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0)
            try waitForReadiness(&descriptor, clock: clock, timeoutExitCode: 65)
            guard descriptor.revents & Int16(POLLNVAL | POLLERR) == 0 else {
                throw CheckerTransportFailure(exitCode: 70)
            }
            let count = buffer.withUnsafeMutableBytes { bytes in
                Darwin.read(STDIN_FILENO, bytes.baseAddress, bytes.count)
            }
            if count == 0 { return input }
            if count < 0 {
                if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK { continue }
                throw CheckerTransportFailure(exitCode: 70)
            }
            guard input.count <= DisposalShotHypothesisChecker.maximumInputBytes - count else {
                throw CheckerTransportFailure(exitCode: 65)
            }
            input.append(buffer, count: count)
        }
    }

    private static func writeAll(
        _ data: Data,
        clock: CheckerTransportClock
    ) throws {
        guard data.count <= maximumOutputBytes else {
            throw CheckerTransportFailure(exitCode: 70)
        }
        let priorNoSigPipe = fcntl(STDOUT_FILENO, F_GETNOSIGPIPE)
        let priorFlags = fcntl(STDOUT_FILENO, F_GETFL)
        guard priorNoSigPipe >= 0,
              priorFlags >= 0,
              fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) == 0,
              fcntl(STDOUT_FILENO, F_SETFL, priorFlags | O_NONBLOCK) == 0
        else {
            throw CheckerTransportFailure(exitCode: 70)
        }
        defer {
            _ = fcntl(STDOUT_FILENO, F_SETFL, priorFlags)
            _ = fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, priorNoSigPipe)
        }
        try data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            var offset = 0
            while offset < bytes.count {
                var descriptor = pollfd(
                    fd: STDOUT_FILENO,
                    events: Int16(POLLOUT),
                    revents: 0)
                try waitForReadiness(&descriptor, clock: clock, timeoutExitCode: 70)
                guard descriptor.revents & Int16(POLLNVAL | POLLERR | POLLHUP) == 0 else {
                    throw CheckerTransportFailure(exitCode: 70)
                }
                let count = Darwin.write(
                    STDOUT_FILENO,
                    base.advanced(by: offset),
                    bytes.count - offset)
                if count < 0 {
                    if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK { continue }
                    throw CheckerTransportFailure(exitCode: 70)
                }
                guard count > 0 else { throw CheckerTransportFailure(exitCode: 70) }
                offset += count
            }
        }
    }

    private static func waitForReadiness(
        _ descriptor: inout pollfd,
        clock: CheckerTransportClock,
        timeoutExitCode: Int32
    ) throws {
        while true {
            let remaining = try clock.remainingMilliseconds(
                timeoutExitCode: timeoutExitCode)
            let readiness = poll(&descriptor, 1, remaining)
            if readiness > 0 { return }
            if readiness < 0 && errno != EINTR {
                throw CheckerTransportFailure(exitCode: 70)
            }
        }
    }

    private static func isClosedFoundationBootstrapEnvironment() -> Bool {
        guard let first = environ.pointee else { return true }
        guard environ.advanced(by: 1).pointee == nil else { return false }
        let entry = String(cString: first)
        let prefix = "__CF_USER_TEXT_ENCODING="
        guard entry.hasPrefix(prefix) else { return false }
        let fields = entry.dropFirst(prefix.count).split(separator: ":", omittingEmptySubsequences: false)
        guard fields.count == 3 else { return false }
        return fields.allSatisfy { field in
            field.count >= 3 && field.hasPrefix("0x") && field.dropFirst(2).utf8.allSatisfy {
                (0x30...0x39).contains($0) || (0x41...0x46).contains($0)
            }
        }
    }
}

private struct CheckerTransportFailure: Error {
    let exitCode: Int32
}

private struct CheckerTransportClock {
    private static let horizonNanoseconds: UInt64 = 5_000_000_000

    private let denominator: UInt64
    private let numerator: UInt64
    private let startTicks: UInt64

    init() throws {
        var timebase = mach_timebase_info_data_t()
        guard mach_timebase_info(&timebase) == KERN_SUCCESS,
              timebase.numer > 0,
              timebase.denom > 0
        else {
            throw CheckerTransportFailure(exitCode: 70)
        }
        denominator = UInt64(timebase.denom)
        numerator = UInt64(timebase.numer)
        startTicks = mach_continuous_time()
    }

    func remainingMilliseconds(timeoutExitCode: Int32) throws -> Int32 {
        let now = mach_continuous_time()
        guard now >= startTicks else {
            throw CheckerTransportFailure(exitCode: 70)
        }
        let delta = now - startTicks
        guard delta == 0 || numerator <= UInt64.max / delta else {
            throw CheckerTransportFailure(exitCode: timeoutExitCode)
        }
        let elapsedNanoseconds = (delta * numerator) / denominator
        guard elapsedNanoseconds < Self.horizonNanoseconds else {
            throw CheckerTransportFailure(exitCode: timeoutExitCode)
        }
        let remainingNanoseconds = Self.horizonNanoseconds - elapsedNanoseconds
        return Int32((remainingNanoseconds + 999_999) / 1_000_000)
    }
}

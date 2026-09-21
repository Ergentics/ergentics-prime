import Darwin
import ErgenticsShotResearchCore
import Foundation

@main
enum ErgenticsShotHypothesisResultComparatorMain {
    private static let frameMagic = Data("ERGC2V10".utf8)
    private static let maximumInputBytes = 1_048_576
    private static let maximumOutputBytes = 1_048_576

    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(64) }
        guard isClosedFoundationBootstrapEnvironment() else { _exit(64) }

        do {
            let clock = try ComparatorTransportClock()
            let inputs = try readFramedInputs(clock: clock)
            let report = try DisposalShotHypothesisResultComparator.compare(
                hypothesisExactCanonicalJSON: inputs.hypothesis,
                resultExactCanonicalJSON: inputs.result)
            try writeCanonicalOutput(report, clock: clock)
            _exit(0)
        } catch let failure as ComparatorTransportFailure {
            _exit(failure.exitCode)
        } catch {
            _exit(70)
        }
    }

    private static func readFramedInputs(
        clock: ComparatorTransportClock
    ) throws -> (hypothesis: Data, result: Data) {
        let priorFlags = fcntl(STDIN_FILENO, F_GETFL)
        guard priorFlags >= 0,
              fcntl(STDIN_FILENO, F_SETFL, priorFlags | O_NONBLOCK) == 0
        else {
            throw ComparatorTransportFailure(exitCode: 70)
        }
        defer { _ = fcntl(STDIN_FILENO, F_SETFL, priorFlags) }

        let magic = try readExactly(frameMagic.count, clock: clock)
        guard magic == frameMagic else {
            throw ComparatorTransportFailure(exitCode: 65)
        }

        let hypothesisLength = try readLength(clock: clock)
        let hypothesis = try readExactly(hypothesisLength, clock: clock)
        let resultLength = try readLength(clock: clock)
        let result = try readExactly(resultLength, clock: clock)
        try requireTerminalEOF(clock: clock)
        return (hypothesis, result)
    }

    private static func readLength(clock: ComparatorTransportClock) throws -> Int {
        let encoded = try readExactly(MemoryLayout<UInt64>.size, clock: clock)
        var value: UInt64 = 0
        for byte in encoded {
            value = (value << 8) | UInt64(byte)
        }
        guard value <= UInt64(maximumInputBytes) else {
            throw ComparatorTransportFailure(exitCode: 65)
        }
        return Int(value)
    }

    private static func readExactly(
        _ expectedCount: Int,
        clock: ComparatorTransportClock
    ) throws -> Data {
        var data = Data()
        data.reserveCapacity(expectedCount)
        var buffer = [UInt8](
            repeating: 0,
            count: max(1, min(16_384, expectedCount)))

        while data.count < expectedCount {
            var descriptor = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0)
            try waitForReadiness(
                &descriptor,
                clock: clock,
                timeoutExitCode: 65)
            guard descriptor.revents & Int16(POLLNVAL | POLLERR) == 0 else {
                throw ComparatorTransportFailure(exitCode: 70)
            }

            let requested = min(buffer.count, expectedCount - data.count)
            let count = buffer.withUnsafeMutableBytes { bytes in
                Darwin.read(STDIN_FILENO, bytes.baseAddress, requested)
            }
            if count == 0 {
                throw ComparatorTransportFailure(exitCode: 65)
            }
            if count < 0 {
                if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK {
                    continue
                }
                throw ComparatorTransportFailure(exitCode: 70)
            }
            data.append(buffer, count: count)
        }
        return data
    }

    private static func requireTerminalEOF(
        clock: ComparatorTransportClock
    ) throws {
        var byte: UInt8 = 0
        while true {
            var descriptor = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0)
            try waitForReadiness(
                &descriptor,
                clock: clock,
                timeoutExitCode: 65)
            guard descriptor.revents & Int16(POLLNVAL | POLLERR) == 0 else {
                throw ComparatorTransportFailure(exitCode: 70)
            }

            let count = withUnsafeMutablePointer(to: &byte) { pointer in
                Darwin.read(STDIN_FILENO, pointer, 1)
            }
            if count == 0 { return }
            if count > 0 {
                throw ComparatorTransportFailure(exitCode: 65)
            }
            if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK {
                continue
            }
            throw ComparatorTransportFailure(exitCode: 70)
        }
    }

    private static func writeCanonicalOutput(
        _ report: DisposalShotHypothesisResultReport,
        clock: ComparatorTransportClock
    ) throws {
        var expected = report.canonicalJSON
        expected.append(0x0a)
        let output = report.canonicalJSONWithLF
        guard output == expected,
              !output.isEmpty,
              output.count <= maximumOutputBytes,
              output.last == 0x0a,
              !output.dropLast().contains(0x0a),
              !output.dropLast().contains(0x0d)
        else {
            throw ComparatorTransportFailure(exitCode: 70)
        }
        try writeAll(output, clock: clock)
    }

    private static func writeAll(
        _ data: Data,
        clock: ComparatorTransportClock
    ) throws {
        let priorNoSigPipe = fcntl(STDOUT_FILENO, F_GETNOSIGPIPE)
        let priorFlags = fcntl(STDOUT_FILENO, F_GETFL)
        guard priorNoSigPipe >= 0,
              priorFlags >= 0,
              fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) == 0,
              fcntl(STDOUT_FILENO, F_SETFL, priorFlags | O_NONBLOCK) == 0
        else {
            throw ComparatorTransportFailure(exitCode: 70)
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
                try waitForReadiness(
                    &descriptor,
                    clock: clock,
                    timeoutExitCode: 70)
                guard descriptor.revents & Int16(POLLNVAL | POLLERR | POLLHUP) == 0 else {
                    throw ComparatorTransportFailure(exitCode: 70)
                }

                let count = Darwin.write(
                    STDOUT_FILENO,
                    base.advanced(by: offset),
                    bytes.count - offset)
                if count < 0 {
                    if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK {
                        continue
                    }
                    throw ComparatorTransportFailure(exitCode: 70)
                }
                guard count > 0 else {
                    throw ComparatorTransportFailure(exitCode: 70)
                }
                offset += count
            }
        }
    }

    private static func waitForReadiness(
        _ descriptor: inout pollfd,
        clock: ComparatorTransportClock,
        timeoutExitCode: Int32
    ) throws {
        while true {
            let remaining = try clock.remainingMilliseconds(
                timeoutExitCode: timeoutExitCode)
            let readiness = poll(&descriptor, 1, remaining)
            if readiness > 0 { return }
            if readiness < 0 && errno != EINTR {
                throw ComparatorTransportFailure(exitCode: 70)
            }
        }
    }

    private static func isClosedFoundationBootstrapEnvironment() -> Bool {
        guard let first = environ.pointee,
              environ.advanced(by: 1).pointee == nil,
              let entry = String(validatingUTF8: first)
        else {
            return false
        }

        let prefix = "__CF_USER_TEXT_ENCODING="
        guard entry.hasPrefix(prefix) else { return false }
        let fields = entry.dropFirst(prefix.count).split(
            separator: ":",
            omittingEmptySubsequences: false)
        guard fields.count == 3 else { return false }
        return fields.allSatisfy { field in
            field.count >= 3 &&
                field.hasPrefix("0x") &&
                field.dropFirst(2).utf8.allSatisfy { byte in
                    (0x30...0x39).contains(byte) ||
                        (0x41...0x46).contains(byte)
                }
        }
    }
}

private struct ComparatorTransportFailure: Error {
    let exitCode: Int32
}

private struct ComparatorTransportClock {
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
            throw ComparatorTransportFailure(exitCode: 70)
        }
        denominator = UInt64(timebase.denom)
        numerator = UInt64(timebase.numer)
        startTicks = mach_continuous_time()
    }

    func remainingMilliseconds(timeoutExitCode: Int32) throws -> Int32 {
        let now = mach_continuous_time()
        guard now >= startTicks else {
            throw ComparatorTransportFailure(exitCode: 70)
        }
        let delta = now - startTicks
        guard delta == 0 || numerator <= UInt64.max / delta else {
            throw ComparatorTransportFailure(exitCode: timeoutExitCode)
        }
        let elapsedNanoseconds = delta * numerator / denominator
        guard elapsedNanoseconds < Self.horizonNanoseconds else {
            throw ComparatorTransportFailure(exitCode: timeoutExitCode)
        }
        let remainingNanoseconds = Self.horizonNanoseconds - elapsedNanoseconds
        return Int32((remainingNanoseconds + 999_999) / 1_000_000)
    }
}

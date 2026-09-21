import CryptoKit
import Darwin
import Foundation
import XCTest

final class HypervisorStageH4DualStreamSigkillCutClassificationTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4D = HypervisorStageH4OwnerBinding
    private typealias H4D3 = HypervisorStageH4DualStreamPersistence

    private let operationNanoseconds: UInt64 = 10_000_000_000
    private let hardNanoseconds: UInt64 = 15_000_000_000
    private let readerOperationNanoseconds: UInt64 = 4_000_000_000
    private let readerHardNanoseconds: UInt64 = 5_000_000_000
    private let streamLimit = 4_096
    private let executableLimit = 64 * 1_024 * 1_024
    // The Clang importer marks the two `sizeof(struct ...)` SDK macros as
    // unavailable to Swift. These are their exact typed sizeof equivalents.
    private let procPIDTBSDInfoSize = Int32(MemoryLayout<proc_bsdinfo>.size)
    private let procPIDRegionPathInfoSize =
        Int32(MemoryLayout<proc_regionwithpathinfo>.size)
    private let stagingLeaf = ".h4d3-dual-receipt.sqlite.staging"
    private let finalLeaf = "h4d3-dual-receipt.sqlite"

    private enum HarnessFailure: Error, CustomStringConvertible {
        case clock
        case deadline
        case descriptor(Int32)
        case executableAdmission
        case malformedMachO
        case spawn(Int32)
        case processAdmission
        case mappedImageAdmission
        case commandWrite(Int32)
        case gateWrite(Int32)
        case read(Int32)
        case streamBound
        case protocolRejected
        case wait(Int32)
        case signalRejected(Int32, Int32)
        case containmentUnproven
        case fixture

        var description: String {
            switch self {
            case .clock: return "monotonic clock conversion rejected"
            case .deadline: return "deadline rejected"
            case .descriptor(let value): return "descriptor operation rejected: \(value)"
            case .executableAdmission: return "executable admission rejected"
            case .malformedMachO: return "Mach-O admission rejected"
            case .spawn(let value): return "posix_spawn rejected: \(value)"
            case .processAdmission: return "suspended child generation rejected"
            case .mappedImageAdmission: return "mapped main image rejected"
            case .commandWrite(let value): return "command write rejected: \(value)"
            case .gateWrite(let value): return "gate write rejected: \(value)"
            case .read(let value): return "pipe read rejected: \(value)"
            case .streamBound: return "pipe stream exceeded its fixed cap"
            case .protocolRejected: return "event protocol rejected"
            case .wait(let value): return "waitpid rejected: \(value)"
            case .signalRejected(let signal, let value):
                return "signal \(signal) rejected: \(value)"
            case .containmentUnproven: return "exact-child containment was not proved"
            case .fixture: return "fixed fixture rejected"
            }
        }
    }

    private struct Deadlines {
        let start: UInt64
        let operation: UInt64
        let hard: UInt64
    }

    private struct FileWitness: Equatable {
        let device: UInt64
        let inode: UInt64
        let mode: UInt16
        let userID: UInt32
        let groupID: UInt32
        let linkCount: UInt16
        let size: Int64
        let flags: UInt32
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let changeSeconds: Int64
        let changeNanoseconds: Int64

        init(_ value: stat) {
            device = UInt64(value.st_dev)
            inode = UInt64(value.st_ino)
            mode = UInt16(value.st_mode)
            userID = value.st_uid
            groupID = value.st_gid
            linkCount = UInt16(value.st_nlink)
            size = Int64(value.st_size)
            flags = value.st_flags
            modificationSeconds = Int64(value.st_mtimespec.tv_sec)
            modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
            changeSeconds = Int64(value.st_ctimespec.tv_sec)
            changeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        }
    }

    private struct ExecutableAdmission {
        let path: String
        var descriptor: Int32
        let witness: FileWitness
        let sha256: String
        let uuid: String
    }

    private struct GenerationSnapshot: Equatable {
        let pid: UInt32
        let parentPID: UInt32
        let effectiveUserID: UInt32
        let effectiveGroupID: UInt32
        let realUserID: UInt32
        let realGroupID: UInt32
        let savedUserID: UInt32
        let savedGroupID: UInt32
        let processGroupID: UInt32
        let status: UInt32
        let startSeconds: UInt64
        let startMicroseconds: UInt64
    }

    private enum EventKind: UInt8 {
        case passed = 1
        case reached = 2
        case normalTerminal = 3
        case failure = 4
    }

    private struct EventFrame: Equatable {
        let kind: EventKind
        let ordinal: UInt8
        let sequence: UInt16
        let status: UInt32
    }

    private struct EventParser {
        private(set) var frames: [EventFrame] = []
        private var pending = Data()
        private var total = 0
        private var terminal = false
        private var nextOrdinal: UInt8 = 0

        var isFrameAligned: Bool { pending.isEmpty }

        mutating func feed(_ fragment: Data) throws {
            guard !fragment.isEmpty else { return }
            let addition = total.addingReportingOverflow(fragment.count)
            guard !addition.overflow, addition.partialValue <= 4_096 else {
                throw HarnessFailure.streamBound
            }
            total = addition.partialValue
            pending.append(fragment)
            while pending.count >= 16 {
                let bytes = Array(pending.prefix(16))
                pending.removeFirst(16)
                try append(bytes)
            }
        }

        mutating func finishEOF() throws -> [EventFrame] {
            guard pending.isEmpty else { throw HarnessFailure.protocolRejected }
            return frames
        }

        private mutating func append(_ bytes: [UInt8]) throws {
            guard bytes.count == 16,
                  bytes[0..<8].elementsEqual("EPRD3CE1".utf8),
                  !terminal,
                  let kind = EventKind(rawValue: bytes[8]) else {
                throw HarnessFailure.protocolRejected
            }
            let sequence = UInt16(bytes[10]) << 8 | UInt16(bytes[11])
            let status = UInt32(bytes[12]) << 24 |
                UInt32(bytes[13]) << 16 |
                UInt32(bytes[14]) << 8 |
                UInt32(bytes[15])
            guard sequence == UInt16(exactly: frames.count) else {
                throw HarnessFailure.protocolRejected
            }
            switch kind {
            case .passed, .reached:
                guard nextOrdinal <= 9, bytes[9] == nextOrdinal,
                      status == 0 else {
                    throw HarnessFailure.protocolRejected
                }
                nextOrdinal += 1
            case .normalTerminal:
                guard nextOrdinal == 10, bytes[9] == 255, status == 0 else {
                    throw HarnessFailure.protocolRejected
                }
                terminal = true
            case .failure:
                guard bytes[9] == 255, status == 70 else {
                    throw HarnessFailure.protocolRejected
                }
                terminal = true
            }
            frames.append(EventFrame(
                kind: kind,
                ordinal: bytes[9],
                sequence: sequence,
                status: status
            ))
        }
    }

    private struct CommandParser {
        private var bytes = Data()

        mutating func feed(_ fragment: Data) throws {
            let total = bytes.count.addingReportingOverflow(fragment.count)
            guard !total.overflow, total.partialValue <= 17 else {
                throw HarnessFailure.protocolRejected
            }
            bytes.append(fragment)
        }

        func finishEOF() throws -> (UInt8, UInt8) {
            guard bytes.count == 16,
                  bytes[0..<8].elementsEqual("EPRD3CC1".utf8),
                  bytes[10..<16].allSatisfy({ $0 == 0 }) else {
                throw HarnessFailure.protocolRejected
            }
            switch (bytes[8], bytes[9]) {
            case (0, 255): return (0, 255)
            case (1, 0...9): return (1, bytes[9])
            default: throw HarnessFailure.protocolRejected
            }
        }
    }

    private func fullWriteOutcomeAdmitted(
        _ outcomes: [(count: Int, error: Int32)],
        expectedCount: Int
    ) -> Bool {
        guard expectedCount > 0 else { return false }
        for outcome in outcomes {
            if outcome.count < 0, outcome.error == EINTR { continue }
            return outcome.count == expectedCount
        }
        return false
    }

    private enum SignalReason: Equatable {
        case resume
        case intentionalCut(UInt8)
        case preResumeContainment
        case protocolContainment
        case operationDeadline
    }

    private struct SignalCall: Equatable {
        let pid: pid_t
        let signal: Int32
        let result: Int32
        let capturedErrno: Int32
        let reason: SignalReason
        let enteredNanoseconds: UInt64
        let returnedNanoseconds: UInt64?
    }

    private enum PublisherMode {
        case baseline
        case releasedGate(UInt8)
        case intentionalCut(UInt8)
        case malformedCommand(Data)
        case preResumeContainment
        case protocolContainment(UInt8)
        case deadlineContainment
    }

    private struct MappedImageEvidence: Equatable {
        let joined: Bool
        let terminalResult: Int32
        let terminalErrno: Int32
        let terminalCallIndex: Int
        let positiveRecordCount: Int
        let terminalCursor: UInt64
        let qualifyingMatchCount: Int
    }

    private struct PublisherResult {
        let parentPID: pid_t
        let pid: pid_t
        let waitStatus: Int32
        let frames: [EventFrame]
        let eventStream: Data
        let stdout: Data
        let stderr: Data
        let eventEOF: Bool
        let stdoutEOF: Bool
        let stderrEOF: Bool
        let signals: [SignalCall]
        let firstGeneration: GenerationSnapshot
        let secondGeneration: GenerationSnapshot
        let mappedImageEvidence: MappedImageEvidence
        let timedOut: Bool
        let gateReleaseCount: Int
        let cutStreamsOpenAndAlignedAtSignal: Bool
        let startNanoseconds: UInt64
        let terminalElapsedNanoseconds: UInt64?
        let elapsedNanoseconds: UInt64
        let reapElapsedNanoseconds: UInt64

        var mappedImageJoined: Bool { mappedImageEvidence.joined }
    }

    private struct PublisherContainmentEvidence {
        let parentPID: pid_t
        let pid: pid_t
        let waitStatus: Int32
        let frames: [EventFrame]
        let eventStream: Data
        let stdout: Data
        let stderr: Data
        let eventEOF: Bool
        let stdoutEOF: Bool
        let stderrEOF: Bool
        let signals: [SignalCall]
        let firstGeneration: GenerationSnapshot?
        let secondGeneration: GenerationSnapshot?
        let mappedImageEvidence: MappedImageEvidence?
        let gateReleaseCount: Int
        let exactlyReaped: Bool
        let elapsedNanoseconds: UInt64
        let reapElapsedNanoseconds: UInt64?

        var mappedImageJoined: Bool { mappedImageEvidence?.joined == true }
    }

    private final class PublisherContainmentProbe {
        var evidence: PublisherContainmentEvidence?
    }

    private struct ReaderResult {
        let parentPID: pid_t
        let pid: pid_t
        let waitStatus: Int32
        let stdout: Data
        let stderr: Data
        let stdoutEOF: Bool
        let stderrEOF: Bool
        let signals: [SignalCall]
        let firstGeneration: GenerationSnapshot
        let secondGeneration: GenerationSnapshot
        let mappedImageEvidence: MappedImageEvidence
        let timedOut: Bool
        let startNanoseconds: UInt64
        let elapsedNanoseconds: UInt64
        let reapElapsedNanoseconds: UInt64

        var mappedImageJoined: Bool { mappedImageEvidence.joined }
    }

    private struct PublisherChannels {
        var commandRead: Int32
        var commandWrite: Int32
        var gateRead: Int32
        var gateWrite: Int32
        var eventRead: Int32
        var eventWrite: Int32
        var stdoutRead: Int32
        var stdoutWrite: Int32
        var stderrRead: Int32
        var stderrWrite: Int32
        var stdinRead: Int32

        var all: [Int32] {
            [commandRead, commandWrite, gateRead, gateWrite,
             eventRead, eventWrite, stdoutRead, stdoutWrite,
             stderrRead, stderrWrite, stdinRead]
        }
    }

    private struct ReaderChannels {
        var stdoutRead: Int32
        var stdoutWrite: Int32
        var stderrRead: Int32
        var stderrWrite: Int32
        var stdinRead: Int32

        var all: [Int32] {
            [stdoutRead, stdoutWrite, stderrRead, stderrWrite, stdinRead]
        }
    }

    private struct SpawnedPublisher {
        let parentPID: pid_t
        let pid: pid_t
        let deadlines: Deadlines
        var admission: ExecutableAdmission
        var channels: PublisherChannels
    }

    private struct SpawnedReader {
        let parentPID: pid_t
        let pid: pid_t
        let deadlines: Deadlines
        var admission: ExecutableAdmission
        var channels: ReaderChannels
    }

    private func monotonicNanoseconds() throws -> UInt64 {
        var information = mach_timebase_info_data_t()
        guard mach_timebase_info(&information) == KERN_SUCCESS,
              information.numer > 0, information.denom > 0 else {
            throw HarnessFailure.clock
        }
        let product = mach_continuous_time().multipliedReportingOverflow(
            by: UInt64(information.numer)
        )
        guard !product.overflow else { throw HarnessFailure.clock }
        return product.partialValue / UInt64(information.denom)
    }

    private func deadlines(
        operationNanoseconds: UInt64,
        hardNanoseconds: UInt64
    ) throws -> Deadlines {
        let start = try monotonicNanoseconds()
        let operation = start.addingReportingOverflow(operationNanoseconds)
        let hard = start.addingReportingOverflow(hardNanoseconds)
        guard !operation.overflow, !hard.overflow,
              operation.partialValue < hard.partialValue else {
            throw HarnessFailure.deadline
        }
        return Deadlines(
            start: start,
            operation: operation.partialValue,
            hard: hard.partialValue
        )
    }

    private func pollMilliseconds(now: UInt64, deadline: UInt64) -> Int32 {
        guard now < deadline else { return 0 }
        let remaining = deadline - now
        return Int32(max(1, min(10, (remaining + 999_999) / 1_000_000)))
    }

    private func productURL(_ name: String) -> URL {
        Bundle(for: Self.self).bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent(name, isDirectory: false)
    }

    private func namedStat(_ path: String) throws -> stat {
        var value = stat()
        guard lstat(path, &value) == 0 else {
            throw HarnessFailure.executableAdmission
        }
        return value
    }

    private func heldStat(_ descriptor: Int32) throws -> stat {
        var value = stat()
        guard fstat(descriptor, &value) == 0 else {
            throw HarnessFailure.executableAdmission
        }
        return value
    }

    private func executableMetadataIsValid(_ value: stat) -> Bool {
        value.st_mode & S_IFMT == S_IFREG &&
            value.st_mode & 0o7777 == 0o755 &&
            value.st_uid == geteuid() &&
            value.st_nlink == 1 &&
            value.st_size > 0 &&
            value.st_size <= executableLimit
    }

    private func canonicalPath(_ path: String) throws -> String {
        guard let resolved = realpath(path, nil) else {
            throw HarnessFailure.executableAdmission
        }
        defer { free(resolved) }
        guard let result = String(validatingCString: resolved),
              result.hasPrefix("/"), result != "/" else {
            throw HarnessFailure.executableAdmission
        }
        return result
    }

    private func readHeld(
        _ descriptor: Int32,
        offset: Int,
        count: Int
    ) throws -> Data {
        guard offset >= 0, count > 0,
              count <= 4 * 1_024 * 1_024 else {
            throw HarnessFailure.malformedMachO
        }
        var result = Data(count: count)
        try result.withUnsafeMutableBytes { bytes in
            guard let base = bytes.baseAddress else {
                throw HarnessFailure.malformedMachO
            }
            var completed = 0
            while completed < count {
                let amount = pread(
                    descriptor,
                    base.advanced(by: completed),
                    count - completed,
                    off_t(offset + completed)
                )
                if amount < 0, errno == EINTR { continue }
                guard amount > 0, amount <= count - completed else {
                    throw HarnessFailure.malformedMachO
                }
                completed += amount
            }
        }
        return result
    }

    private func heldSHA256(_ descriptor: Int32, size: Int) throws -> String {
        guard size > 0, size <= executableLimit else {
            throw HarnessFailure.executableAdmission
        }
        var hasher = SHA256()
        var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
        var offset = 0
        while offset < size {
            let requested = min(buffer.count, size - offset)
            let amount = buffer.withUnsafeMutableBytes {
                pread(descriptor, $0.baseAddress, requested, off_t(offset))
            }
            if amount < 0, errno == EINTR { continue }
            guard amount > 0, amount <= requested else {
                throw HarnessFailure.executableAdmission
            }
            hasher.update(data: Data(buffer.prefix(amount)))
            offset += amount
        }
        var trailing: UInt8 = 0
        while true {
            let amount = pread(descriptor, &trailing, 1, off_t(size))
            if amount < 0, errno == EINTR { continue }
            guard amount == 0 else { throw HarnessFailure.executableAdmission }
            break
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func unsigned32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw HarnessFailure.malformedMachO
        }
        return UInt32(bytes[offset]) |
            UInt32(bytes[offset + 1]) << 8 |
            UInt32(bytes[offset + 2]) << 16 |
            UInt32(bytes[offset + 3]) << 24
    }

    private func heldMachOUUID(_ descriptor: Int32, size: Int) throws -> String {
        guard size >= 32 else { throw HarnessFailure.malformedMachO }
        let header = try readHeld(descriptor, offset: 0, count: 32)
        guard try unsigned32(header, 0) == 0xfeedfacf,
              try unsigned32(header, 4) == 0x0100000c,
              try unsigned32(header, 12) == 2 else {
            throw HarnessFailure.malformedMachO
        }
        let commandCount = Int(try unsigned32(header, 16))
        let commandByteCount = Int(try unsigned32(header, 20))
        guard commandCount > 0, commandCount <= 4_096,
              commandByteCount >= 8,
              commandByteCount <= 4 * 1_024 * 1_024,
              commandByteCount <= size - 32 else {
            throw HarnessFailure.malformedMachO
        }
        let commands = try readHeld(
            descriptor,
            offset: 32,
            count: commandByteCount
        )
        var cursor = 0
        var uuid: String?
        for _ in 0..<commandCount {
            guard cursor <= commands.count - 8 else {
                throw HarnessFailure.malformedMachO
            }
            let command = try unsigned32(commands, cursor)
            let commandSize = Int(try unsigned32(commands, cursor + 4))
            guard commandSize >= 8, commandSize.isMultiple(of: 8),
                  commandSize <= commands.count - cursor else {
                throw HarnessFailure.malformedMachO
            }
            if command == 0x1b {
                guard commandSize == 24, uuid == nil else {
                    throw HarnessFailure.malformedMachO
                }
                let raw = commands[(cursor + 8)..<(cursor + 24)]
                uuid = raw.map { String(format: "%02X", $0) }.joined()
            }
            cursor += commandSize
        }
        guard cursor == commands.count, let uuid, uuid.count == 32 else {
            throw HarnessFailure.malformedMachO
        }
        return "\(uuid.prefix(8))-\(uuid.dropFirst(8).prefix(4))-" +
            "\(uuid.dropFirst(12).prefix(4))-\(uuid.dropFirst(16).prefix(4))-" +
            "\(uuid.dropFirst(20))"
    }

    private func admitExecutable(_ product: String) throws -> ExecutableAdmission {
        let path = try canonicalPath(productURL(product).path)
        let named = try namedStat(path)
        let descriptor = open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw HarnessFailure.executableAdmission }
        do {
            let held = try heldStat(descriptor)
            guard executableMetadataIsValid(named),
                  executableMetadataIsValid(held),
                  FileWitness(named) == FileWitness(held),
                  let size = Int(exactly: held.st_size) else {
                throw HarnessFailure.executableAdmission
            }
            return ExecutableAdmission(
                path: path,
                descriptor: descriptor,
                witness: FileWitness(held),
                sha256: try heldSHA256(descriptor, size: size),
                uuid: try heldMachOUUID(descriptor, size: size)
            )
        } catch {
            _ = close(descriptor)
            throw error
        }
    }

    private func revalidateExecutable(_ admission: ExecutableAdmission) throws {
        guard try canonicalPath(admission.path) == admission.path else {
            throw HarnessFailure.executableAdmission
        }
        let named = try namedStat(admission.path)
        let held = try heldStat(admission.descriptor)
        guard executableMetadataIsValid(named), executableMetadataIsValid(held),
              FileWitness(named) == admission.witness,
              FileWitness(held) == admission.witness,
              let size = Int(exactly: held.st_size),
              try heldSHA256(admission.descriptor, size: size) == admission.sha256,
              try heldMachOUUID(admission.descriptor, size: size) == admission.uuid else {
            throw HarnessFailure.executableAdmission
        }
    }

    private func makeRawPipe() throws -> [Int32] {
        var values = [Int32](repeating: -1, count: 2)
        guard pipe(&values) == 0 else {
            throw HarnessFailure.descriptor(errno)
        }
        return values
    }

    private func closeDistinct(_ descriptors: [Int32]) {
        var closed = Set<Int32>()
        for descriptor in descriptors where descriptor >= 0 {
            if closed.insert(descriptor).inserted { _ = close(descriptor) }
        }
    }

    private func relocateEveryDescriptor(_ raw: [Int32]) throws -> [Int32] {
        guard raw.allSatisfy({ $0 >= 0 }), Set(raw).count == raw.count else {
            throw HarnessFailure.descriptor(EBADF)
        }
        var relocated: [Int32] = []
        do {
            for descriptor in raw {
                let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 10)
                guard duplicate >= 0 else {
                    throw HarnessFailure.descriptor(errno)
                }
                guard duplicate >= 10,
                      !relocated.contains(duplicate),
                      !raw.contains(duplicate) else {
                    let closeStatus = close(duplicate)
                    throw HarnessFailure.descriptor(
                        closeStatus == 0 ? EINVAL : errno
                    )
                }
                relocated.append(duplicate)
            }
        } catch {
            closeDistinct(relocated)
            throw error
        }
        return relocated
    }

    private func closeOriginalsOnce(_ descriptors: inout [Int32]) throws {
        var firstError: Int32?
        for descriptor in descriptors where descriptor >= 0 {
            if close(descriptor) != 0, firstError == nil { firstError = errno }
        }
        descriptors.removeAll(keepingCapacity: false)
        if let firstError { throw HarnessFailure.descriptor(firstError) }
    }

    private func makePublisherChannels() throws -> PublisherChannels {
        var raw: [Int32] = []
        do {
            for _ in 0..<5 { raw.append(contentsOf: try makeRawPipe()) }
            let input = open("/dev/null", O_RDONLY | O_CLOEXEC)
            guard input >= 0 else { throw HarnessFailure.descriptor(errno) }
            raw.append(input)
            let moved = try relocateEveryDescriptor(raw)
            do {
                try closeOriginalsOnce(&raw)
            } catch {
                closeDistinct(moved)
                throw error
            }
            guard moved.count == 11 else {
                closeDistinct(moved)
                throw HarnessFailure.descriptor(EINVAL)
            }
            return PublisherChannels(
                commandRead: moved[0], commandWrite: moved[1],
                gateRead: moved[2], gateWrite: moved[3],
                eventRead: moved[4], eventWrite: moved[5],
                stdoutRead: moved[6], stdoutWrite: moved[7],
                stderrRead: moved[8], stderrWrite: moved[9],
                stdinRead: moved[10]
            )
        } catch {
            closeDistinct(raw)
            throw error
        }
    }

    private func makeReaderChannels() throws -> ReaderChannels {
        var raw: [Int32] = []
        do {
            for _ in 0..<2 { raw.append(contentsOf: try makeRawPipe()) }
            let input = open("/dev/null", O_RDONLY | O_CLOEXEC)
            guard input >= 0 else { throw HarnessFailure.descriptor(errno) }
            raw.append(input)
            let moved = try relocateEveryDescriptor(raw)
            do {
                try closeOriginalsOnce(&raw)
            } catch {
                closeDistinct(moved)
                throw error
            }
            guard moved.count == 5 else {
                closeDistinct(moved)
                throw HarnessFailure.descriptor(EINVAL)
            }
            return ReaderChannels(
                stdoutRead: moved[0], stdoutWrite: moved[1],
                stderrRead: moved[2], stderrWrite: moved[3],
                stdinRead: moved[4]
            )
        } catch {
            closeDistinct(raw)
            throw error
        }
    }

    private func setNonblocking(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFL)
        guard flags >= 0,
              fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0,
              fcntl(descriptor, F_GETFL) & O_NONBLOCK != 0 else {
            throw HarnessFailure.descriptor(errno)
        }
    }

    private func setNoSigPipe(_ descriptor: Int32) throws {
        guard fcntl(descriptor, F_SETNOSIGPIPE, 1) == 0,
              fcntl(descriptor, F_GETNOSIGPIPE) == 1 else {
            throw HarnessFailure.descriptor(errno)
        }
    }

    private func closeRequired(_ descriptor: inout Int32) throws {
        guard descriptor >= 0 else { throw HarnessFailure.descriptor(EBADF) }
        let current = descriptor
        descriptor = -1
        guard close(current) == 0 else {
            throw HarnessFailure.descriptor(errno)
        }
    }

    private func closeIgnoringResult(_ descriptor: inout Int32) {
        guard descriptor >= 0 else { return }
        let current = descriptor
        descriptor = -1
        _ = close(current)
    }

    private func initializeSpawnObjects(
        actions: inout posix_spawn_file_actions_t?,
        attributes: inout posix_spawnattr_t?
    ) throws {
        let actionStatus = posix_spawn_file_actions_init(&actions)
        guard actionStatus == 0 else { throw HarnessFailure.spawn(actionStatus) }
        let attributeStatus = posix_spawnattr_init(&attributes)
        guard attributeStatus == 0 else {
            posix_spawn_file_actions_destroy(&actions)
            throw HarnessFailure.spawn(attributeStatus)
        }
    }

    private func configureSpawnAttributes(
        _ attributes: inout posix_spawnattr_t?
    ) throws {
        var emptyMask = sigset_t()
        var defaultSignals = sigset_t()
        guard sigemptyset(&emptyMask) == 0,
              sigfillset(&defaultSignals) == 0,
              sigdelset(&defaultSignals, SIGKILL) == 0,
              sigdelset(&defaultSignals, SIGSTOP) == 0 else {
            throw HarnessFailure.spawn(errno)
        }
        for status in [
            posix_spawnattr_setsigmask(&attributes, &emptyMask),
            posix_spawnattr_setsigdefault(&attributes, &defaultSignals),
        ] where status != 0 {
            throw HarnessFailure.spawn(status)
        }
        let flags = POSIX_SPAWN_CLOEXEC_DEFAULT |
            POSIX_SPAWN_START_SUSPENDED |
            POSIX_SPAWN_SETSIGMASK |
            POSIX_SPAWN_SETSIGDEF
        let status = posix_spawnattr_setflags(&attributes, Int16(flags))
        guard status == 0 else { throw HarnessFailure.spawn(status) }
    }

    private func addCloseActions(
        _ descriptors: [Int32],
        to actions: inout posix_spawn_file_actions_t?
    ) throws {
        guard Set(descriptors).count == descriptors.count else {
            throw HarnessFailure.spawn(EINVAL)
        }
        for descriptor in descriptors {
            let status = posix_spawn_file_actions_addclose(&actions, descriptor)
            guard status == 0 else { throw HarnessFailure.spawn(status) }
        }
    }

    private func spawnPath(
        admission: ExecutableAdmission,
        rootPath: String,
        actions: inout posix_spawn_file_actions_t?,
        attributes: inout posix_spawnattr_t?,
        operationNanoseconds: UInt64,
        hardNanoseconds: UInt64
    ) throws -> (pid_t, Deadlines) {
        let strings = [admission.path, rootPath]
        let allocated = strings.map { strdup($0) }
        guard allocated.allSatisfy({ $0 != nil }) else {
            for value in allocated { free(value) }
            throw HarnessFailure.spawn(ENOMEM)
        }
        defer { for value in allocated { free(value) } }
        var arguments: [UnsafeMutablePointer<CChar>?] = allocated + [nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var pid: pid_t = 0
        try revalidateExecutable(admission)
        // The horizon begins only after all fallible path admission and spawn
        // construction, immediately before entering posix_spawn.
        let limits = try deadlines(
            operationNanoseconds: operationNanoseconds,
            hardNanoseconds: hardNanoseconds
        )
        let status = admission.path.withCString { path in
            arguments.withUnsafeMutableBufferPointer { argv in
                environment.withUnsafeMutableBufferPointer { envp in
                    posix_spawn(
                        &pid, path, &actions, &attributes,
                        argv.baseAddress, envp.baseAddress
                    )
                }
            }
        }
        guard status == 0, pid > 0, pid != getpid() else {
            throw HarnessFailure.spawn(status)
        }
        return (pid, limits)
    }

    private func spawnPublisher(rootPath: String) throws -> SpawnedPublisher {
        let admission = try admitExecutable("H4D3cCutPublisher")
        var channels: PublisherChannels
        do {
            channels = try makePublisherChannels()
        } catch {
            _ = close(admission.descriptor)
            throw error
        }
        var ownsChannels = true
        defer {
            if ownsChannels { closeDistinct(channels.all) }
        }
        do {
            try setNonblocking(channels.eventRead)
            try setNonblocking(channels.stdoutRead)
            try setNonblocking(channels.stderrRead)
            try setNoSigPipe(channels.commandWrite)
            try setNoSigPipe(channels.gateWrite)
            try setNoSigPipe(channels.eventWrite)

            var actions: posix_spawn_file_actions_t?
            var attributes: posix_spawnattr_t?
            try initializeSpawnObjects(actions: &actions, attributes: &attributes)
            defer {
                posix_spawn_file_actions_destroy(&actions)
                posix_spawnattr_destroy(&attributes)
            }
            let mappings: [(Int32, Int32)] = [
                (channels.stdinRead, STDIN_FILENO),
                (channels.stdoutWrite, STDOUT_FILENO),
                (channels.stderrWrite, STDERR_FILENO),
                (channels.commandRead, 3),
                (channels.gateRead, 4),
                (channels.eventWrite, 5),
            ]
            for (source, destination) in mappings {
                let status = posix_spawn_file_actions_adddup2(
                    &actions, source, destination
                )
                guard status == 0 else { throw HarnessFailure.spawn(status) }
            }
            try addCloseActions(channels.all, to: &actions)
            let chdirStatus = "/private/var/empty".withCString {
                posix_spawn_file_actions_addchdir(&actions, $0)
            }
            guard chdirStatus == 0 else {
                throw HarnessFailure.spawn(chdirStatus)
            }
            try configureSpawnAttributes(&attributes)
            let parentPID = getpid()
            let (pid, limits) = try spawnPath(
                admission: admission,
                rootPath: rootPath,
                actions: &actions,
                attributes: &attributes,
                operationNanoseconds: operationNanoseconds,
                hardNanoseconds: hardNanoseconds
            )
            ownsChannels = false
            return SpawnedPublisher(
                parentPID: parentPID,
                pid: pid,
                deadlines: limits,
                admission: admission,
                channels: channels
            )
        } catch {
            closeDistinct(channels.all)
            _ = close(admission.descriptor)
            ownsChannels = false
            throw error
        }
    }

    private func spawnReader(rootPath: String) throws -> SpawnedReader {
        let admission = try admitExecutable("H4D3bRestartReader")
        var channels: ReaderChannels
        do {
            channels = try makeReaderChannels()
        } catch {
            _ = close(admission.descriptor)
            throw error
        }
        var ownsChannels = true
        defer { if ownsChannels { closeDistinct(channels.all) } }
        do {
            try setNonblocking(channels.stdoutRead)
            try setNonblocking(channels.stderrRead)
            var actions: posix_spawn_file_actions_t?
            var attributes: posix_spawnattr_t?
            try initializeSpawnObjects(actions: &actions, attributes: &attributes)
            defer {
                posix_spawn_file_actions_destroy(&actions)
                posix_spawnattr_destroy(&attributes)
            }
            for (source, destination) in [
                (channels.stdinRead, STDIN_FILENO),
                (channels.stdoutWrite, STDOUT_FILENO),
                (channels.stderrWrite, STDERR_FILENO),
            ] {
                let status = posix_spawn_file_actions_adddup2(
                    &actions, source, destination
                )
                guard status == 0 else { throw HarnessFailure.spawn(status) }
            }
            try addCloseActions(channels.all, to: &actions)
            let chdirStatus = "/private/var/empty".withCString {
                posix_spawn_file_actions_addchdir(&actions, $0)
            }
            guard chdirStatus == 0 else {
                throw HarnessFailure.spawn(chdirStatus)
            }
            try configureSpawnAttributes(&attributes)
            let parentPID = getpid()
            let (pid, limits) = try spawnPath(
                admission: admission,
                rootPath: rootPath,
                actions: &actions,
                attributes: &attributes,
                operationNanoseconds: readerOperationNanoseconds,
                hardNanoseconds: readerHardNanoseconds
            )
            ownsChannels = false
            return SpawnedReader(
                parentPID: parentPID,
                pid: pid,
                deadlines: limits,
                admission: admission,
                channels: channels
            )
        } catch {
            closeDistinct(channels.all)
            _ = close(admission.descriptor)
            ownsChannels = false
            throw error
        }
    }

    private func generationSnapshot(
        pid: pid_t,
        parentPID: pid_t
    ) throws -> GenerationSnapshot {
        var information = proc_bsdinfo()
        let expected = procPIDTBSDInfoSize
        let result = proc_pidinfo(
            pid, PROC_PIDTBSDINFO, 0, &information, expected
        )
        guard result == expected,
              information.pbi_pid == UInt32(pid),
              information.pbi_ppid == UInt32(parentPID),
              information.pbi_uid == geteuid(),
              information.pbi_ruid == getuid(),
              information.pbi_svuid == geteuid(),
              information.pbi_gid == getegid(),
              information.pbi_rgid == getgid(),
              information.pbi_svgid == getegid(),
              information.pbi_status == UInt32(SSTOP) else {
            throw HarnessFailure.processAdmission
        }
        return GenerationSnapshot(
            pid: information.pbi_pid,
            parentPID: information.pbi_ppid,
            effectiveUserID: information.pbi_uid,
            effectiveGroupID: information.pbi_gid,
            realUserID: information.pbi_ruid,
            realGroupID: information.pbi_rgid,
            savedUserID: information.pbi_svuid,
            savedGroupID: information.pbi_svgid,
            processGroupID: information.pbi_pgid,
            status: information.pbi_status,
            startSeconds: information.pbi_start_tvsec,
            startMicroseconds: information.pbi_start_tvusec
        )
    }

    private func mappedMainImageJoined(
        pid: pid_t,
        admission: ExecutableAdmission
    ) throws -> MappedImageEvidence {
        var cursor: UInt64 = 0
        var matches = 0
        var positiveRecordCount = 0
        let expected = procPIDRegionPathInfoSize
        for callIndex in 0...4_096 {
            var information = proc_regionwithpathinfo()
            errno = 0
            let result = proc_pidinfo(
                pid, PROC_PIDREGIONPATHINFO, cursor,
                &information, expected
            )
            let capturedErrno = errno
            if result == 0 {
                guard capturedErrno == EINVAL,
                      callIndex == positiveRecordCount,
                      matches == 1 else {
                    throw HarnessFailure.mappedImageAdmission
                }
                return MappedImageEvidence(
                    joined: true,
                    terminalResult: result,
                    terminalErrno: capturedErrno,
                    terminalCallIndex: callIndex,
                    positiveRecordCount: positiveRecordCount,
                    terminalCursor: cursor,
                    qualifyingMatchCount: matches
                )
            }
            guard callIndex < 4_096,
                  result == expected,
                  capturedErrno == 0 else {
                throw HarnessFailure.mappedImageAdmission
            }
            positiveRecordCount += 1
            let region = information.prp_prinfo
            guard region.pri_size > 0, region.pri_address >= cursor else {
                throw HarnessFailure.mappedImageAdmission
            }
            let next = region.pri_address.addingReportingOverflow(region.pri_size)
            guard !next.overflow, next.partialValue > cursor else {
                throw HarnessFailure.mappedImageAdmission
            }
            cursor = next.partialValue

            let vnode = information.prp_vip.vip_vi.vi_stat
            if UInt64(vnode.vst_dev) == admission.witness.device,
               vnode.vst_ino == admission.witness.inode,
               region.pri_offset == 0,
               region.pri_protection & UInt32(VM_PROT_EXECUTE) != 0 {
                var pathBytes = [CChar](repeating: 0x7f, count: Int(PATH_MAX))
                let count = pathBytes.withUnsafeMutableBytes { bytes in
                    proc_regionfilename(
                        pid, region.pri_address,
                        bytes.baseAddress, UInt32(bytes.count)
                    )
                }
                let nulLimit = min(pathBytes.count, Int(count) + 1)
                guard count > 0, count <= pathBytes.count,
                      let relativeNul = pathBytes[..<nulLimit].firstIndex(of: 0),
                      relativeNul > 0,
                      let path = String(
                        bytes: pathBytes[..<relativeNul].map {
                            UInt8(bitPattern: $0)
                        },
                        encoding: .utf8
                      ), try canonicalPath(path) == admission.path else {
                    throw HarnessFailure.mappedImageAdmission
                }
                matches += 1
            }
        }
        throw HarnessFailure.mappedImageAdmission
    }

    private func commandFrame(mode: UInt8, ordinal: UInt8) -> Data {
        var frame = Data("EPRD3CC1".utf8)
        frame.append(mode)
        frame.append(ordinal)
        frame.append(contentsOf: repeatElement(UInt8(0), count: 6))
        precondition(frame.count == 16)
        return frame
    }

    private func command(for mode: PublisherMode) -> Data {
        switch mode {
        case .baseline, .preResumeContainment, .deadlineContainment:
            return commandFrame(mode: 0, ordinal: 255)
        case .releasedGate(let ordinal), .intentionalCut(let ordinal),
             .protocolContainment(let ordinal):
            return commandFrame(mode: 1, ordinal: ordinal)
        case .malformedCommand(let bytes):
            return bytes
        }
    }

    private func writeSingleComplete(
        _ bytes: Data,
        descriptor: Int32,
        gate: Bool = false
    ) throws {
        while true {
            errno = 0
            let result = bytes.withUnsafeBytes {
                write(descriptor, $0.baseAddress, $0.count)
            }
            if result < 0, errno == EINTR { continue }
            let captured = result < 0 ? errno : 0
            guard fullWriteOutcomeAdmitted(
                [(count: result, error: captured)],
                expectedCount: bytes.count
            ) else {
                let value = result < 0 ? errno : EIO
                if gate { throw HarnessFailure.gateWrite(value) }
                throw HarnessFailure.commandWrite(value)
            }
            return
        }
    }

    private func waitNoHang(_ pid: pid_t, status: inout Int32) throws -> pid_t {
        while true {
            let result = waitpid(pid, &status, WNOHANG)
            if result < 0, errno == EINTR { continue }
            if result < 0 { throw HarnessFailure.wait(errno) }
            return result
        }
    }

    private func sendSignal(
        _ signal: Int32,
        reason: SignalReason,
        pid: pid_t,
        parentPID: pid_t,
        spawnedPID: pid_t,
        returnBefore deadline: UInt64,
        waitStatus: inout Int32,
        reaped: inout Bool,
        reapTime: inout UInt64?,
        calls: inout [SignalCall]
    ) throws {
        guard pid > 0, pid != parentPID, pid == spawnedPID else {
            throw HarnessFailure.signalRejected(signal, ECHILD)
        }
        guard try monotonicNanoseconds() < deadline else {
            throw HarnessFailure.deadline
        }
        let waitResult = try waitNoHang(pid, status: &waitStatus)
        if waitResult == pid { reaped = true }
        let waitObservedAt = try monotonicNanoseconds()
        if waitResult == pid { reapTime = waitObservedAt }
        guard waitObservedAt < deadline else {
            throw HarnessFailure.deadline
        }
        guard waitResult == 0 else {
            throw HarnessFailure.signalRejected(signal, ECHILD)
        }
        let enteredAt = try monotonicNanoseconds()
        guard enteredAt < deadline else { throw HarnessFailure.deadline }
        errno = 0
        let result = kill(pid, signal)
        let captured = result == 0 ? 0 : errno
        // Accounting is appended before interpreting either syscall result or
        // the optional post-call clock sample, so an entered signal can never
        // disappear and induce a retry on a catch path.
        let returnedAt = try? monotonicNanoseconds()
        calls.append(SignalCall(
            pid: pid,
            signal: signal,
            result: result,
            capturedErrno: captured,
            reason: reason,
            enteredNanoseconds: enteredAt,
            returnedNanoseconds: returnedAt
        ))
        guard result == 0 else {
            throw HarnessFailure.signalRejected(signal, captured)
        }
        guard let returnedAt, returnedAt < deadline else {
            if returnedAt == nil { throw HarnessFailure.clock }
            throw HarnessFailure.deadline
        }
    }

    private func drainAvailable(
        _ descriptor: Int32,
        into data: inout Data,
        maximum: Int
    ) throws -> Bool {
        var buffer = [UInt8](repeating: 0, count: 256)
        while true {
            let amount = buffer.withUnsafeMutableBytes {
                read(descriptor, $0.baseAddress, $0.count)
            }
            if amount == 0 { return true }
            if amount < 0 {
                if errno == EINTR { continue }
                if errno == EAGAIN || errno == EWOULDBLOCK { return false }
                throw HarnessFailure.read(errno)
            }
            guard amount <= maximum - data.count else {
                throw HarnessFailure.streamBound
            }
            data.append(contentsOf: buffer.prefix(amount))
        }
    }

    private func drainEvents(
        _ descriptor: Int32,
        parser: inout EventParser,
        into data: inout Data
    ) throws -> Bool {
        var buffer = [UInt8](repeating: 0, count: 256)
        while true {
            let amount = buffer.withUnsafeMutableBytes {
                read(descriptor, $0.baseAddress, $0.count)
            }
            if amount == 0 { return true }
            if amount < 0 {
                if errno == EINTR { continue }
                if errno == EAGAIN || errno == EWOULDBLOCK { return false }
                throw HarnessFailure.read(errno)
            }
            guard amount <= streamLimit - data.count else {
                throw HarnessFailure.streamBound
            }
            let fragment = Data(buffer.prefix(amount))
            data.append(fragment)
            try parser.feed(fragment)
            // A successful read never immediately probes again for EOF. This
            // lets the parent stop protocol reads at a terminal/reached frame
            // and make every admitted EOF observation after exact reap.
            return false
        }
    }

    private func closeIfOpenBeforeHard(
        _ descriptor: inout Int32,
        hardDeadline: UInt64
    ) throws {
        guard descriptor >= 0 else { return }
        guard try monotonicNanoseconds() < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
        try closeRequired(&descriptor)
        guard try monotonicNanoseconds() < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
    }

    private func drainToEOFBeforeHard(
        _ descriptor: inout Int32,
        into data: inout Data,
        maximum: Int,
        hardDeadline: UInt64
    ) throws {
        guard descriptor >= 0 else {
            throw HarnessFailure.containmentUnproven
        }
        while true {
            let before = try monotonicNanoseconds()
            guard before < hardDeadline else {
                throw HarnessFailure.containmentUnproven
            }
            let reachedEOF = try drainAvailable(
                descriptor, into: &data, maximum: maximum
            )
            let after = try monotonicNanoseconds()
            guard after < hardDeadline else {
                throw HarnessFailure.containmentUnproven
            }
            if reachedEOF {
                try closeIfOpenBeforeHard(
                    &descriptor, hardDeadline: hardDeadline
                )
                return
            }
            try pollStreams(
                [descriptor],
                timeout: pollMilliseconds(now: after, deadline: hardDeadline)
            )
        }
    }

    private func pollStreams(
        _ descriptors: [Int32],
        timeout: Int32
    ) throws {
        var values = descriptors.map {
            pollfd(
                fd: $0,
                events: $0 >= 0 ? Int16(POLLIN | POLLHUP) : 0,
                revents: 0
            )
        }
        let result = values.withUnsafeMutableBufferPointer {
            Darwin.poll($0.baseAddress, nfds_t($0.count), timeout)
        }
        if result < 0, errno != EINTR { throw HarnessFailure.read(errno) }
        guard !values.contains(where: { $0.revents & Int16(POLLNVAL) != 0 }) else {
            throw HarnessFailure.read(EBADF)
        }
    }

    private func exited(_ status: Int32) -> Bool {
        status & 0x7f == 0
    }

    private func exitCode(_ status: Int32) -> Int32 {
        exited(status) ? (status >> 8) & 0xff : -1
    }

    private func terminatingSignal(_ status: Int32) -> Int32 {
        exited(status) ? 0 : status & 0x7f
    }

    private func expectedReachedPrefix(
        _ frames: [EventFrame],
        selected: UInt8
    ) -> Bool {
        guard frames.count == Int(selected) + 1 else { return false }
        for ordinal in UInt8(0)..<selected {
            let frame = frames[Int(ordinal)]
            guard frame.kind == .passed, frame.ordinal == ordinal,
                  frame.sequence == UInt16(ordinal), frame.status == 0 else {
                return false
            }
        }
        guard let reached = frames.last else { return false }
        return reached.kind == .reached &&
            reached.ordinal == selected &&
            reached.sequence == UInt16(selected) &&
            reached.status == 0
    }

    private func expectedBaseline(_ frames: [EventFrame]) -> Bool {
        guard frames.count == 11 else { return false }
        for ordinal in UInt8(0)...9 {
            let frame = frames[Int(ordinal)]
            guard frame.kind == .passed, frame.ordinal == ordinal,
                  frame.sequence == UInt16(ordinal), frame.status == 0 else {
                return false
            }
        }
        let terminal = frames[10]
        return terminal.kind == .normalTerminal && terminal.ordinal == 255 &&
            terminal.sequence == 10 && terminal.status == 0
    }

    private func expectedReleased(
        _ frames: [EventFrame],
        selected: UInt8
    ) -> Bool {
        guard frames.count == 11 else { return false }
        var index = 0
        for ordinal in UInt8(0)...9 {
            let frame = frames[index]
            let expectedKind: EventKind = ordinal == selected ? .reached : .passed
            guard frame.kind == expectedKind, frame.ordinal == ordinal,
                  frame.sequence == UInt16(index), frame.status == 0 else {
                return false
            }
            index += 1
        }
        let terminal = frames[index]
        return terminal.kind == .normalTerminal && terminal.ordinal == 255 &&
            terminal.sequence == UInt16(index) && terminal.status == 0
    }

    private func protocolPrefixIsValid(
        _ frames: [EventFrame],
        mode: PublisherMode
    ) -> Bool {
        switch mode {
        case .baseline:
            guard frames.count <= 11 else { return false }
            for (index, frame) in frames.enumerated() {
                if index < 10 {
                    guard frame.kind == .passed,
                          frame.ordinal == UInt8(index) else { return false }
                } else {
                    guard frame.kind == .normalTerminal,
                          frame.ordinal == 255 else { return false }
                }
            }
            return true
        case .releasedGate(let selected):
            guard frames.count <= 11 else { return false }
            for (index, frame) in frames.enumerated() {
                if index < 10 {
                    let kind: EventKind = UInt8(index) == selected ?
                        .reached : .passed
                    guard frame.kind == kind,
                          frame.ordinal == UInt8(index) else { return false }
                } else {
                    guard frame.kind == .normalTerminal,
                          frame.ordinal == 255 else { return false }
                }
            }
            return true
        case .intentionalCut(let selected), .protocolContainment(let selected):
            guard frames.count <= Int(selected) + 1 else { return false }
            for (index, frame) in frames.enumerated() {
                let ordinal = UInt8(index)
                let kind: EventKind = ordinal == selected ? .reached : .passed
                guard frame.kind == kind, frame.ordinal == ordinal else {
                    return false
                }
            }
            return true
        case .malformedCommand:
            return frames.isEmpty ||
                (frames.count == 1 && frames[0].kind == .failure)
        case .preResumeContainment, .deadlineContainment:
            return frames.isEmpty
        }
    }

    private func waitUntilReaped(
        pid: pid_t,
        status: inout Int32,
        hardDeadline: UInt64
    ) throws -> UInt64 {
        while true {
            let before = try monotonicNanoseconds()
            guard before < hardDeadline else {
                throw HarnessFailure.containmentUnproven
            }
            let result = try waitNoHang(pid, status: &status)
            let after = try monotonicNanoseconds()
            guard after < hardDeadline else {
                throw HarnessFailure.containmentUnproven
            }
            if result == pid { return after }
            try pollStreams(
                [],
                timeout: pollMilliseconds(now: after, deadline: hardDeadline)
            )
        }
    }

    private func observeReapBeforeHard(
        pid: pid_t,
        status: inout Int32,
        hardDeadline: UInt64
    ) throws -> UInt64? {
        guard try monotonicNanoseconds() < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
        let result = try waitNoHang(pid, status: &status)
        let observed = try monotonicNanoseconds()
        guard observed < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
        return result == pid ? observed : nil
    }

    private func finishPublisherFailureCleanup(
        child: inout SpawnedPublisher,
        eventStream: inout Data,
        stdout: inout Data,
        stderr: inout Data,
        eventEOF: inout Bool,
        stdoutEOF: inout Bool,
        stderrEOF: inout Bool,
        hardDeadline: UInt64
    ) throws {
        // Once the exact child is reaped, release every remaining non-capture
        // endpoint exactly once. In particular, an intentional-cut gate writer
        // remains open until this post-reap point.
        try closeIfOpenBeforeHard(
            &child.channels.commandRead, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.commandWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.gateRead, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.gateWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.eventWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.stdoutWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.stderrWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.stdinRead, hardDeadline: hardDeadline
        )

        if eventEOF {
            try closeIfOpenBeforeHard(
                &child.channels.eventRead, hardDeadline: hardDeadline
            )
        } else {
            try drainToEOFBeforeHard(
                &child.channels.eventRead,
                into: &eventStream,
                maximum: streamLimit,
                hardDeadline: hardDeadline
            )
            eventEOF = true
        }
        if stdoutEOF {
            try closeIfOpenBeforeHard(
                &child.channels.stdoutRead, hardDeadline: hardDeadline
            )
        } else {
            try drainToEOFBeforeHard(
                &child.channels.stdoutRead,
                into: &stdout,
                maximum: streamLimit,
                hardDeadline: hardDeadline
            )
            stdoutEOF = true
        }
        if stderrEOF {
            try closeIfOpenBeforeHard(
                &child.channels.stderrRead, hardDeadline: hardDeadline
            )
        } else {
            try drainToEOFBeforeHard(
                &child.channels.stderrRead,
                into: &stderr,
                maximum: streamLimit,
                hardDeadline: hardDeadline
            )
            stderrEOF = true
        }

        try revalidateExecutable(child.admission)
        guard try monotonicNanoseconds() < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
        try closeIfOpenBeforeHard(
            &child.admission.descriptor, hardDeadline: hardDeadline
        )
    }

    private func finishReaderFailureCleanup(
        child: inout SpawnedReader,
        stdout: inout Data,
        stderr: inout Data,
        stdoutEOF: inout Bool,
        stderrEOF: inout Bool,
        hardDeadline: UInt64
    ) throws {
        try closeIfOpenBeforeHard(
            &child.channels.stdoutWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.stderrWrite, hardDeadline: hardDeadline
        )
        try closeIfOpenBeforeHard(
            &child.channels.stdinRead, hardDeadline: hardDeadline
        )
        if stdoutEOF {
            try closeIfOpenBeforeHard(
                &child.channels.stdoutRead, hardDeadline: hardDeadline
            )
        } else {
            try drainToEOFBeforeHard(
                &child.channels.stdoutRead,
                into: &stdout,
                maximum: streamLimit,
                hardDeadline: hardDeadline
            )
            stdoutEOF = true
        }
        if stderrEOF {
            try closeIfOpenBeforeHard(
                &child.channels.stderrRead, hardDeadline: hardDeadline
            )
        } else {
            try drainToEOFBeforeHard(
                &child.channels.stderrRead,
                into: &stderr,
                maximum: streamLimit,
                hardDeadline: hardDeadline
            )
            stderrEOF = true
        }
        try revalidateExecutable(child.admission)
        guard try monotonicNanoseconds() < hardDeadline else {
            throw HarnessFailure.containmentUnproven
        }
        try closeIfOpenBeforeHard(
            &child.admission.descriptor, hardDeadline: hardDeadline
        )
    }

    private func runPublisher(
        rootPath: String,
        mode: PublisherMode,
        containmentProbe: PublisherContainmentProbe? = nil
    ) throws -> PublisherResult {
        var child = try spawnPublisher(rootPath: rootPath)
        let limits = child.deadlines
        var waitStatus: Int32 = 0
        var reaped = false
        var reapTime: UInt64?
        var signals: [SignalCall] = []
        var parser = EventParser()
        var frames: [EventFrame] = []
        var eventStream = Data()
        var stdout = Data()
        var stderr = Data()
        var eventEOF = false
        var stdoutEOF = false
        var stderrEOF = false
        var gateReleaseCount = 0
        var cutStreamsOpenAndAlignedAtSignal = false
        var timedOut = false
        var terminalTime: UInt64?
        var firstGeneration: GenerationSnapshot?
        var secondGeneration: GenerationSnapshot?
        var mapped: MappedImageEvidence?

        defer {
            closeDistinct(child.channels.all)
            if child.admission.descriptor >= 0 {
                _ = close(child.admission.descriptor)
                child.admission.descriptor = -1
            }
        }

        do {
            try closeRequired(&child.channels.commandRead)
            try closeRequired(&child.channels.gateRead)
            try closeRequired(&child.channels.eventWrite)
            try closeRequired(&child.channels.stdoutWrite)
            try closeRequired(&child.channels.stderrWrite)
            try closeRequired(&child.channels.stdinRead)
            let bytes = command(for: mode)
            try writeSingleComplete(bytes, descriptor: child.channels.commandWrite)
            try closeRequired(&child.channels.commandWrite)
            try revalidateExecutable(child.admission)
            firstGeneration = try generationSnapshot(
                pid: child.pid, parentPID: child.parentPID
            )
            secondGeneration = try generationSnapshot(
                pid: child.pid, parentPID: child.parentPID
            )
            guard firstGeneration == secondGeneration else {
                throw HarnessFailure.processAdmission
            }

            if case .preResumeContainment = mode {
                // Exercise the actual post-spawn catch path at the pre-resume
                // admission boundary. The child remains suspended until that
                // catch performs its one bounded containment SIGKILL.
                throw HarnessFailure.processAdmission
            } else {
                mapped = try mappedMainImageJoined(
                    pid: child.pid, admission: child.admission
                )
                try revalidateExecutable(child.admission)
                if case .deadlineContainment = mode {
                    // Deliberately retain the exact child suspended without a
                    // signal until the frozen operation deadline.
                } else {
                    guard try monotonicNanoseconds() < limits.operation else {
                        throw HarnessFailure.deadline
                    }
                    try sendSignal(
                        SIGCONT, reason: .resume,
                        pid: child.pid, parentPID: child.parentPID,
                        spawnedPID: child.pid, returnBefore: limits.operation,
                        waitStatus: &waitStatus,
                        reaped: &reaped, reapTime: &reapTime,
                        calls: &signals
                    )
                }
            }

            while true {
                let sigkillEntered = signals.contains {
                    $0.signal == SIGKILL
                }
                let mayReadProtocolBeforeReap = !reaped &&
                    !sigkillEntered && terminalTime == nil
                if child.channels.eventRead >= 0,
                   reaped || mayReadProtocolBeforeReap {
                    eventEOF = try drainEvents(
                        child.channels.eventRead,
                        parser: &parser,
                        into: &eventStream
                    )
                    if eventEOF {
                        frames = try parser.finishEOF()
                        try closeRequired(&child.channels.eventRead)
                    }
                }
                if reaped, child.channels.stdoutRead >= 0 {
                    stdoutEOF = try drainAvailable(
                        child.channels.stdoutRead,
                        into: &stdout,
                        maximum: streamLimit
                    )
                    if stdoutEOF { try closeRequired(&child.channels.stdoutRead) }
                }
                if reaped, child.channels.stderrRead >= 0 {
                    stderrEOF = try drainAvailable(
                        child.channels.stderrRead,
                        into: &stderr,
                        maximum: streamLimit
                    )
                    if stderrEOF { try closeRequired(&child.channels.stderrRead) }
                }

                if !reaped,
                   let observed = try observeReapBeforeHard(
                    pid: child.pid,
                    status: &waitStatus,
                    hardDeadline: limits.hard
                   ) {
                    reaped = true
                    reapTime = observed
                }

                let currentFrames = eventEOF ? frames : parser.frames
                guard protocolPrefixIsValid(currentFrames, mode: mode) else {
                    throw HarnessFailure.protocolRejected
                }
                if terminalTime == nil,
                   (currentFrames.last?.kind == .normalTerminal ||
                    currentFrames.last?.kind == .failure) {
                    terminalTime = try monotonicNanoseconds()
                }
                switch mode {
                case .releasedGate(let selected):
                    if gateReleaseCount == 0,
                       expectedReachedPrefix(currentFrames, selected: selected) {
                        try writeSingleComplete(
                            Data([0xa5]),
                            descriptor: child.channels.gateWrite,
                            gate: true
                        )
                        gateReleaseCount = 1
                        try closeRequired(&child.channels.gateWrite)
                    }
                case .intentionalCut(let selected):
                    if !signals.contains(where: { $0.signal == SIGKILL }),
                       expectedReachedPrefix(currentFrames, selected: selected) {
                        guard gateReleaseCount == 0,
                              child.channels.gateWrite >= 0,
                              child.channels.eventRead >= 0,
                              !eventEOF,
                              parser.isFrameAligned,
                              child.channels.stdoutRead >= 0,
                              !stdoutEOF,
                              child.channels.stderrRead >= 0,
                              !stderrEOF,
                              try monotonicNanoseconds() < limits.operation else {
                            throw HarnessFailure.protocolRejected
                        }
                        cutStreamsOpenAndAlignedAtSignal = true
                        try sendSignal(
                            SIGKILL, reason: .intentionalCut(selected),
                            pid: child.pid, parentPID: child.parentPID,
                            spawnedPID: child.pid,
                            returnBefore: limits.operation,
                            waitStatus: &waitStatus,
                            reaped: &reaped, reapTime: &reapTime,
                            calls: &signals
                        )
                        guard try monotonicNanoseconds() < limits.operation else {
                            throw HarnessFailure.deadline
                        }
                    }
                case .protocolContainment(let selected):
                    if !signals.contains(where: { $0.signal == SIGKILL }),
                       expectedReachedPrefix(currentFrames, selected: selected) {
                        // Inject parent admission rejection only after the full
                        // bounded prefix. Catch containment must do all signal,
                        // reap, EOF and executable-join work.
                        throw HarnessFailure.protocolRejected
                    }
                default:
                    break
                }

                let now = try monotonicNanoseconds()
                guard now < limits.hard else {
                    throw HarnessFailure.containmentUnproven
                }
                if now >= limits.operation, !reaped,
                   !signals.contains(where: { $0.signal == SIGKILL }) {
                    timedOut = true
                    try sendSignal(
                        SIGKILL, reason: .operationDeadline,
                        pid: child.pid, parentPID: child.parentPID,
                        spawnedPID: child.pid, returnBefore: limits.hard,
                        waitStatus: &waitStatus,
                        reaped: &reaped, reapTime: &reapTime,
                        calls: &signals
                    )
                }
                if reaped && eventEOF && stdoutEOF && stderrEOF { break }
                let shouldPollProtocol = !reaped &&
                    !signals.contains(where: { $0.signal == SIGKILL }) &&
                    terminalTime == nil
                try pollStreams(
                    reaped ?
                        [child.channels.eventRead,
                         child.channels.stdoutRead,
                         child.channels.stderrRead] :
                        (shouldPollProtocol ? [child.channels.eventRead] : []),
                    timeout: pollMilliseconds(now: now, deadline: limits.hard)
                )
            }

            if child.channels.gateWrite >= 0 {
                try closeRequired(&child.channels.gateWrite)
            }
            try revalidateExecutable(child.admission)
            let completed = try monotonicNanoseconds()
            guard completed < limits.hard else {
                throw HarnessFailure.containmentUnproven
            }
            guard let firstGeneration, let secondGeneration, let mapped,
                  let reapTime, reapTime >= limits.start else {
                throw HarnessFailure.deadline
            }
            switch mode {
            case .baseline, .releasedGate, .malformedCommand:
                guard let terminalTime,
                      terminalTime < limits.operation,
                      reapTime < limits.operation else {
                    throw HarnessFailure.deadline
                }
            default:
                break
            }
            try closeRequired(&child.admission.descriptor)
            return PublisherResult(
                parentPID: child.parentPID,
                pid: child.pid,
                waitStatus: waitStatus,
                frames: frames,
                eventStream: eventStream,
                stdout: stdout,
                stderr: stderr,
                eventEOF: eventEOF,
                stdoutEOF: stdoutEOF,
                stderrEOF: stderrEOF,
                signals: signals,
                firstGeneration: firstGeneration,
                secondGeneration: secondGeneration,
                mappedImageEvidence: mapped,
                timedOut: timedOut,
                gateReleaseCount: gateReleaseCount,
                cutStreamsOpenAndAlignedAtSignal:
                    cutStreamsOpenAndAlignedAtSignal,
                startNanoseconds: limits.start,
                terminalElapsedNanoseconds: terminalTime.map { $0 - limits.start },
                elapsedNanoseconds: completed - limits.start,
                reapElapsedNanoseconds: reapTime - limits.start
            )
        } catch let primary {
            if !reaped {
                do {
                    if let observed = try observeReapBeforeHard(
                        pid: child.pid,
                        status: &waitStatus,
                        hardDeadline: limits.hard
                    ) {
                        reaped = true
                        reapTime = observed
                    }
                } catch {
                    throw HarnessFailure.containmentUnproven
                }
            }
            if !reaped,
               !signals.contains(where: { $0.signal == SIGKILL }) {
                do {
                    let reason: SignalReason
                    if case .preResumeContainment = mode {
                        reason = .preResumeContainment
                    } else {
                        reason = .protocolContainment
                    }
                    try sendSignal(
                        SIGKILL, reason: reason,
                        pid: child.pid, parentPID: child.parentPID,
                        spawnedPID: child.pid, returnBefore: limits.hard,
                        waitStatus: &waitStatus,
                        reaped: &reaped, reapTime: &reapTime,
                        calls: &signals
                    )
                } catch {
                    // If SIGKILL was entered it is recorded. Never retry it;
                    // continue into the same bounded exact-pid reap below.
                }
            }
            if !reaped {
                guard signals.contains(where: { $0.signal == SIGKILL }) else {
                    throw HarnessFailure.containmentUnproven
                }
                do {
                    reapTime = try waitUntilReaped(
                        pid: child.pid,
                        status: &waitStatus,
                        hardDeadline: limits.hard
                    )
                    reaped = true
                } catch {
                    throw HarnessFailure.containmentUnproven
                }
            }
            let sigkills = signals.filter { $0.signal == SIGKILL }
            // An independently exact prior reap needs no signal. Once a
            // SIGKILL syscall was entered, however, its one-call success and
            // matching SIGKILL reap are mandatory even on this catch path.
            let sigkillWasExact = sigkills.isEmpty ||
                (sigkills.count == 1 &&
                 sigkills[0].pid == child.pid &&
                 sigkills[0].result == 0 &&
                 sigkills[0].capturedErrno == 0 &&
                 sigkills[0].enteredNanoseconds < limits.hard &&
                 (sigkills[0].returnedNanoseconds ?? .max) < limits.hard &&
                 !exited(waitStatus) &&
                 terminatingSignal(waitStatus) == SIGKILL)
            do {
                try finishPublisherFailureCleanup(
                    child: &child,
                    eventStream: &eventStream,
                    stdout: &stdout,
                    stderr: &stderr,
                    eventEOF: &eventEOF,
                    stdoutEOF: &stdoutEOF,
                    stderrEOF: &stderrEOF,
                    hardDeadline: limits.hard
                )
            } catch {
                throw HarnessFailure.containmentUnproven
            }
            guard sigkillWasExact, let reapTime,
                  reapTime < limits.hard else {
                throw HarnessFailure.containmentUnproven
            }
            let completed = try monotonicNanoseconds()
            guard completed < limits.hard,
                  completed >= limits.start else {
                throw HarnessFailure.containmentUnproven
            }
            containmentProbe?.evidence = PublisherContainmentEvidence(
                parentPID: child.parentPID,
                pid: child.pid,
                waitStatus: waitStatus,
                frames: parser.frames,
                eventStream: eventStream,
                stdout: stdout,
                stderr: stderr,
                eventEOF: eventEOF,
                stdoutEOF: stdoutEOF,
                stderrEOF: stderrEOF,
                signals: signals,
                firstGeneration: firstGeneration,
                secondGeneration: secondGeneration,
                mappedImageEvidence: mapped,
                gateReleaseCount: gateReleaseCount,
                exactlyReaped: reaped,
                elapsedNanoseconds: completed - limits.start,
                reapElapsedNanoseconds: reapTime >= limits.start ?
                    reapTime - limits.start : nil
            )
            throw primary
        }
    }

    private func runReader(rootPath: String) throws -> ReaderResult {
        var child = try spawnReader(rootPath: rootPath)
        let limits = child.deadlines
        var waitStatus: Int32 = 0
        var reaped = false
        var reapTime: UInt64?
        var signals: [SignalCall] = []
        var stdout = Data()
        var stderr = Data()
        var stdoutEOF = false
        var stderrEOF = false
        var timedOut = false
        defer {
            closeDistinct(child.channels.all)
            if child.admission.descriptor >= 0 {
                _ = close(child.admission.descriptor)
                child.admission.descriptor = -1
            }
        }

        do {
            try closeRequired(&child.channels.stdoutWrite)
            try closeRequired(&child.channels.stderrWrite)
            try closeRequired(&child.channels.stdinRead)
            try revalidateExecutable(child.admission)
            let first = try generationSnapshot(
                pid: child.pid, parentPID: child.parentPID
            )
            let second = try generationSnapshot(
                pid: child.pid, parentPID: child.parentPID
            )
            guard first == second else { throw HarnessFailure.processAdmission }
            let mapped = try mappedMainImageJoined(
                pid: child.pid, admission: child.admission
            )
            try revalidateExecutable(child.admission)
            guard try monotonicNanoseconds() < limits.operation else {
                throw HarnessFailure.deadline
            }
            try sendSignal(
                SIGCONT, reason: .resume,
                pid: child.pid, parentPID: child.parentPID,
                spawnedPID: child.pid, returnBefore: limits.operation,
                waitStatus: &waitStatus,
                reaped: &reaped, reapTime: &reapTime,
                calls: &signals
            )

            while true {
                if reaped, child.channels.stdoutRead >= 0 {
                    stdoutEOF = try drainAvailable(
                        child.channels.stdoutRead,
                        into: &stdout,
                        maximum: streamLimit
                    )
                    if stdoutEOF { try closeRequired(&child.channels.stdoutRead) }
                }
                if reaped, child.channels.stderrRead >= 0 {
                    stderrEOF = try drainAvailable(
                        child.channels.stderrRead,
                        into: &stderr,
                        maximum: streamLimit
                    )
                    if stderrEOF { try closeRequired(&child.channels.stderrRead) }
                }
                if !reaped,
                   let observed = try observeReapBeforeHard(
                    pid: child.pid,
                    status: &waitStatus,
                    hardDeadline: limits.hard
                   ) {
                    reaped = true
                    reapTime = observed
                }
                let now = try monotonicNanoseconds()
                guard now < limits.hard else {
                    throw HarnessFailure.containmentUnproven
                }
                if now >= limits.operation, !reaped,
                   !signals.contains(where: { $0.signal == SIGKILL }) {
                    timedOut = true
                    try sendSignal(
                        SIGKILL, reason: .operationDeadline,
                        pid: child.pid, parentPID: child.parentPID,
                        spawnedPID: child.pid, returnBefore: limits.hard,
                        waitStatus: &waitStatus,
                        reaped: &reaped, reapTime: &reapTime,
                        calls: &signals
                    )
                }
                if reaped && stdoutEOF && stderrEOF { break }
                try pollStreams(
                    reaped ?
                        [child.channels.stdoutRead, child.channels.stderrRead] :
                        [],
                    timeout: pollMilliseconds(now: now, deadline: limits.hard)
                )
            }
            try revalidateExecutable(child.admission)
            let completed = try monotonicNanoseconds()
            guard completed < limits.hard else {
                throw HarnessFailure.containmentUnproven
            }
            guard let reapTime,
                  reapTime < limits.operation,
                  completed < limits.operation else {
                throw HarnessFailure.deadline
            }
            try closeRequired(&child.admission.descriptor)
            return ReaderResult(
                parentPID: child.parentPID,
                pid: child.pid,
                waitStatus: waitStatus,
                stdout: stdout,
                stderr: stderr,
                stdoutEOF: stdoutEOF,
                stderrEOF: stderrEOF,
                signals: signals,
                firstGeneration: first,
                secondGeneration: second,
                mappedImageEvidence: mapped,
                timedOut: timedOut,
                startNanoseconds: limits.start,
                elapsedNanoseconds: completed - limits.start,
                reapElapsedNanoseconds: reapTime - limits.start
            )
        } catch let primary {
            if !reaped {
                do {
                    if let observed = try observeReapBeforeHard(
                        pid: child.pid,
                        status: &waitStatus,
                        hardDeadline: limits.hard
                    ) {
                        reaped = true
                        reapTime = observed
                    }
                } catch {
                    throw HarnessFailure.containmentUnproven
                }
            }
            if !reaped,
               !signals.contains(where: { $0.signal == SIGKILL }) {
                do {
                    try sendSignal(
                        SIGKILL, reason: .protocolContainment,
                        pid: child.pid, parentPID: child.parentPID,
                        spawnedPID: child.pid, returnBefore: limits.hard,
                        waitStatus: &waitStatus,
                        reaped: &reaped, reapTime: &reapTime,
                        calls: &signals
                    )
                } catch {
                    // An entered call is durable in `signals`; do not retry.
                }
            }
            if !reaped {
                guard signals.contains(where: { $0.signal == SIGKILL }) else {
                    throw HarnessFailure.containmentUnproven
                }
                do {
                    reapTime = try waitUntilReaped(
                        pid: child.pid,
                        status: &waitStatus,
                        hardDeadline: limits.hard
                    )
                    reaped = true
                } catch {
                    throw HarnessFailure.containmentUnproven
                }
            }
            let sigkills = signals.filter { $0.signal == SIGKILL }
            // A child already reaped before this parent-side error must never
            // be signaled. Any entered containment SIGKILL remains strict.
            let sigkillWasExact = sigkills.isEmpty ||
                (sigkills.count == 1 &&
                 sigkills[0].pid == child.pid &&
                 sigkills[0].result == 0 &&
                 sigkills[0].capturedErrno == 0 &&
                 sigkills[0].enteredNanoseconds < limits.hard &&
                 (sigkills[0].returnedNanoseconds ?? .max) < limits.hard &&
                 !exited(waitStatus) &&
                 terminatingSignal(waitStatus) == SIGKILL)
            do {
                try finishReaderFailureCleanup(
                    child: &child,
                    stdout: &stdout,
                    stderr: &stderr,
                    stdoutEOF: &stdoutEOF,
                    stderrEOF: &stderrEOF,
                    hardDeadline: limits.hard
                )
            } catch {
                throw HarnessFailure.containmentUnproven
            }
            guard sigkillWasExact, let reapTime,
                  reapTime < limits.hard else {
                throw HarnessFailure.containmentUnproven
            }
            throw primary
        }
    }

    private func assertMappedImageEvidence(
        _ evidence: MappedImageEvidence,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(evidence.joined, file: file, line: line)
        XCTAssertEqual(evidence.terminalResult, 0, file: file, line: line)
        XCTAssertEqual(evidence.terminalErrno, EINVAL, file: file, line: line)
        XCTAssertGreaterThanOrEqual(
            evidence.terminalCallIndex, 1, file: file, line: line
        )
        XCTAssertLessThanOrEqual(
            evidence.terminalCallIndex, 4_096, file: file, line: line
        )
        XCTAssertGreaterThanOrEqual(
            evidence.positiveRecordCount, 1, file: file, line: line
        )
        XCTAssertLessThanOrEqual(
            evidence.positiveRecordCount, 4_096, file: file, line: line
        )
        XCTAssertEqual(
            evidence.terminalCallIndex,
            evidence.positiveRecordCount,
            file: file,
            line: line
        )
        XCTAssertGreaterThan(evidence.terminalCursor, 0, file: file, line: line)
        XCTAssertEqual(
            evidence.qualifyingMatchCount, 1, file: file, line: line
        )
    }

    private func assertReader(
        _ result: ReaderResult,
        expectedExitCode: Int32,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(result.pid, 0, file: file, line: line)
        XCTAssertNotEqual(result.pid, result.parentPID, file: file, line: line)
        XCTAssertTrue(exited(result.waitStatus), file: file, line: line)
        XCTAssertEqual(exitCode(result.waitStatus), expectedExitCode, file: file, line: line)
        XCTAssertEqual(terminatingSignal(result.waitStatus), 0, file: file, line: line)
        XCTAssertTrue(result.stdout.isEmpty, file: file, line: line)
        XCTAssertTrue(result.stderr.isEmpty, file: file, line: line)
        XCTAssertTrue(result.stdoutEOF, file: file, line: line)
        XCTAssertTrue(result.stderrEOF, file: file, line: line)
        XCTAssertFalse(result.timedOut, file: file, line: line)
        XCTAssertEqual(result.signals.count, 1, file: file, line: line)
        XCTAssertEqual(result.signals.first?.signal, SIGCONT, file: file, line: line)
        XCTAssertEqual(result.signals.first?.result, 0, file: file, line: line)
        XCTAssertEqual(result.signals.first?.pid, result.pid, file: file, line: line)
        XCTAssertEqual(result.signals.first?.capturedErrno, 0, file: file, line: line)
        XCTAssertEqual(result.signals.first?.reason, .resume, file: file, line: line)
        XCTAssertNotNil(
            result.signals.first?.returnedNanoseconds,
            file: file,
            line: line
        )
        if let returned = result.signals.first?.returnedNanoseconds {
            XCTAssertGreaterThanOrEqual(
                returned, result.startNanoseconds, file: file, line: line
            )
            if returned >= result.startNanoseconds {
                XCTAssertLessThan(
                    returned - result.startNanoseconds,
                    readerOperationNanoseconds,
                    file: file,
                    line: line
                )
            }
        }
        XCTAssertEqual(result.firstGeneration, result.secondGeneration, file: file, line: line)
        assertMappedImageEvidence(
            result.mappedImageEvidence, file: file, line: line
        )
        XCTAssertLessThan(
            result.reapElapsedNanoseconds,
            readerOperationNanoseconds,
            file: file,
            line: line
        )
        XCTAssertLessThan(
            result.elapsedNanoseconds,
            readerOperationNanoseconds,
            file: file,
            line: line
        )
    }

    private func privateRoot(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        var template = Array("/private/tmp/epr-h4d3c.XXXXXX\0".utf8)
        let path = template.withUnsafeMutableBufferPointer { buffer -> String? in
            guard let base = buffer.baseAddress, let created = mkdtemp(base) else {
                return nil
            }
            return String(validatingCString: created)
        }
        let value = try XCTUnwrap(path, file: file, line: line)
        XCTAssertEqual(chmod(value, mode_t(0o700)), 0, file: file, line: line)
        XCTAssertEqual(try canonicalPath(value), value, file: file, line: line)
        let root = URL(fileURLWithPath: value, isDirectory: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
            try? FileManager.default.removeItem(atPath: value + ".displaced")
            try? FileManager.default.removeItem(atPath: value + ".leaf-displaced")
            try? FileManager.default.removeItem(atPath: value + ".hardlink")
            try? FileManager.default.removeItem(atPath: value + ".alias")
        }
        return root
    }

    private func assertLeaseReleased(
        _ rootPath: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let descriptor = open(
            rootPath, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        XCTAssertGreaterThanOrEqual(descriptor, 0, file: file, line: line)
        guard descriptor >= 0 else { throw HarnessFailure.fixture }
        defer { XCTAssertEqual(close(descriptor), 0, file: file, line: line) }
        XCTAssertEqual(
            flock(descriptor, LOCK_EX | LOCK_NB), 0,
            file: file, line: line
        )
        guard flock(descriptor, LOCK_UN) == 0 else {
            throw HarnessFailure.fixture
        }
    }

    private func source() -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: .h3Checkpoint,
            epoch: "44444444-4444-4444-8444-444444444444",
            receiptRoot: String(repeating: "a", count: 64),
            claimState: .observedNonPass,
            predicateCount: 19,
            authorityVector: "00000000",
            rawDiagnostic: nil
        )
    }

    private func bound() throws -> H4D.OwnerBoundCanonicalProjection {
        let fixed = source()
        let capability = try XCTUnwrap(H4.issueTestCapability(
            source: fixed,
            validThroughTick: .max
        ))
        let dispatcher = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: H4.fixedRequest(epoch: fixed.epoch),
            source: fixed,
            deliveryTick: { 1 }
        ))
        return try dispatcher.bindCanonicalStreams().get()
    }

    @inline(never)
    private func publishFixture(to root: URL) throws {
        let coordinator = try H4D3.makeTestCoordinator(
            bound: bound(),
            rootURL: root,
            storeReadTick: { 1 }
        )
        guard case .admitted = coordinator.persist() else {
            throw HarnessFailure.fixture
        }
    }

    private func assertPublisherCommon(
        _ result: PublisherResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(result.pid, 0, file: file, line: line)
        XCTAssertNotEqual(result.pid, result.parentPID, file: file, line: line)
        XCTAssertTrue(result.stdout.isEmpty, file: file, line: line)
        XCTAssertTrue(result.stderr.isEmpty, file: file, line: line)
        XCTAssertTrue(result.eventEOF, file: file, line: line)
        XCTAssertTrue(result.stdoutEOF, file: file, line: line)
        XCTAssertTrue(result.stderrEOF, file: file, line: line)
        XCTAssertEqual(result.firstGeneration, result.secondGeneration, file: file, line: line)
        assertMappedImageEvidence(
            result.mappedImageEvidence, file: file, line: line
        )
        XCTAssertLessThan(result.elapsedNanoseconds, hardNanoseconds, file: file, line: line)
        XCTAssertLessThan(result.reapElapsedNanoseconds, hardNanoseconds, file: file, line: line)
        for call in result.signals {
            XCTAssertEqual(call.pid, result.pid, file: file, line: line)
            XCTAssertEqual(call.result, 0, file: file, line: line)
            XCTAssertEqual(call.capturedErrno, 0, file: file, line: line)
        }
    }

    private func assertPublisherContainmentCommon(
        _ evidence: PublisherContainmentEvidence,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(evidence.pid, 0, file: file, line: line)
        XCTAssertNotEqual(evidence.pid, evidence.parentPID, file: file, line: line)
        XCTAssertTrue(evidence.exactlyReaped, file: file, line: line)
        XCTAssertFalse(exited(evidence.waitStatus), file: file, line: line)
        XCTAssertEqual(
            terminatingSignal(evidence.waitStatus), SIGKILL,
            file: file,
            line: line
        )
        XCTAssertTrue(evidence.stdout.isEmpty, file: file, line: line)
        XCTAssertTrue(evidence.stderr.isEmpty, file: file, line: line)
        XCTAssertLessThanOrEqual(
            evidence.eventStream.count, streamLimit, file: file, line: line
        )
        XCTAssertLessThanOrEqual(
            evidence.stdout.count, streamLimit, file: file, line: line
        )
        XCTAssertLessThanOrEqual(
            evidence.stderr.count, streamLimit, file: file, line: line
        )
        XCTAssertTrue(evidence.eventEOF, file: file, line: line)
        XCTAssertTrue(evidence.stdoutEOF, file: file, line: line)
        XCTAssertTrue(evidence.stderrEOF, file: file, line: line)
        XCTAssertNotNil(evidence.firstGeneration, file: file, line: line)
        XCTAssertNotNil(evidence.secondGeneration, file: file, line: line)
        XCTAssertEqual(
            evidence.firstGeneration,
            evidence.secondGeneration,
            file: file,
            line: line
        )
        if let mappedImageEvidence = evidence.mappedImageEvidence {
            assertMappedImageEvidence(
                mappedImageEvidence, file: file, line: line
            )
        }
        XCTAssertLessThan(
            evidence.elapsedNanoseconds,
            hardNanoseconds,
            file: file,
            line: line
        )
        XCTAssertLessThan(
            evidence.reapElapsedNanoseconds ?? .max,
            hardNanoseconds,
            file: file,
            line: line
        )
        for call in evidence.signals {
            XCTAssertEqual(call.pid, evidence.pid, file: file, line: line)
            XCTAssertEqual(call.result, 0, file: file, line: line)
            XCTAssertEqual(call.capturedErrno, 0, file: file, line: line)
        }
    }

    private func assertNormalPublisher(
        _ result: PublisherResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertPublisherCommon(result, file: file, line: line)
        XCTAssertTrue(exited(result.waitStatus), file: file, line: line)
        XCTAssertEqual(exitCode(result.waitStatus), 0, file: file, line: line)
        XCTAssertEqual(terminatingSignal(result.waitStatus), 0, file: file, line: line)
        XCTAssertFalse(result.timedOut, file: file, line: line)
        XCTAssertTrue(result.mappedImageJoined, file: file, line: line)
        XCTAssertEqual(result.signals.count, 1, file: file, line: line)
        XCTAssertEqual(result.signals.first?.signal, SIGCONT, file: file, line: line)
        XCTAssertEqual(result.signals.first?.reason, .resume, file: file, line: line)
        XCTAssertNotNil(result.terminalElapsedNanoseconds, file: file, line: line)
        XCTAssertLessThan(
            result.terminalElapsedNanoseconds ?? .max,
            operationNanoseconds,
            file: file,
            line: line
        )
        XCTAssertLessThan(result.elapsedNanoseconds, operationNanoseconds, file: file, line: line)
        XCTAssertLessThan(result.reapElapsedNanoseconds, operationNanoseconds, file: file, line: line)
    }

    private func intentionalCutEvidenceAdmitted(
        pid: pid_t,
        parentPID: pid_t,
        selected: UInt8,
        frames: [EventFrame],
        streamsOpenAndAlignedAtSignal: Bool,
        mappedImageJoined: Bool,
        gateReleaseCount: Int,
        stdout: Data,
        stderr: Data,
        eventEOF: Bool,
        stdoutEOF: Bool,
        stderrEOF: Bool,
        signals: [SignalCall],
        waitStatus: Int32,
        timedOut: Bool,
        exactlyReaped: Bool,
        startNanoseconds: UInt64,
        elapsedNanoseconds: UInt64,
        reapElapsedNanoseconds: UInt64
    ) -> Bool {
        guard pid > 0, pid != parentPID,
              selected <= 9,
              expectedReachedPrefix(frames, selected: selected),
              streamsOpenAndAlignedAtSignal,
              mappedImageJoined,
              gateReleaseCount == 0,
              stdout.isEmpty, stderr.isEmpty,
              eventEOF, stdoutEOF, stderrEOF,
              !timedOut, exactlyReaped,
              elapsedNanoseconds < hardNanoseconds,
              reapElapsedNanoseconds < hardNanoseconds,
              !exited(waitStatus),
              terminatingSignal(waitStatus) == SIGKILL,
              signals.count == 2 else {
            return false
        }
        let resume = signals[0]
        let cut = signals[1]
        guard resume.pid == pid, cut.pid == pid,
              resume.signal == SIGCONT, resume.reason == .resume,
              cut.signal == SIGKILL,
              cut.reason == .intentionalCut(selected),
              resume.result == 0, resume.capturedErrno == 0,
              cut.result == 0, cut.capturedErrno == 0,
              let resumeReturned = resume.returnedNanoseconds,
              let cutReturned = cut.returnedNanoseconds,
              resumeReturned >= startNanoseconds,
              cutReturned >= startNanoseconds else {
            return false
        }
        return resumeReturned - startNanoseconds < operationNanoseconds &&
            cutReturned - startNanoseconds < operationNanoseconds
    }

    private func assertIntentionalCut(
        _ result: PublisherResult,
        ordinal: UInt8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertPublisherCommon(result, file: file, line: line)
        XCTAssertTrue(intentionalCutEvidenceAdmitted(
            pid: result.pid,
            parentPID: result.parentPID,
            selected: ordinal,
            frames: result.frames,
            streamsOpenAndAlignedAtSignal:
                result.cutStreamsOpenAndAlignedAtSignal,
            mappedImageJoined: result.mappedImageJoined,
            gateReleaseCount: result.gateReleaseCount,
            stdout: result.stdout,
            stderr: result.stderr,
            eventEOF: result.eventEOF,
            stdoutEOF: result.stdoutEOF,
            stderrEOF: result.stderrEOF,
            signals: result.signals,
            waitStatus: result.waitStatus,
            timedOut: result.timedOut,
            exactlyReaped: true,
            startNanoseconds: result.startNanoseconds,
            elapsedNanoseconds: result.elapsedNanoseconds,
            reapElapsedNanoseconds: result.reapElapsedNanoseconds
        ), file: file, line: line)
        XCTAssertFalse(exited(result.waitStatus), file: file, line: line)
        XCTAssertEqual(terminatingSignal(result.waitStatus), SIGKILL, file: file, line: line)
        XCTAssertFalse(result.timedOut, file: file, line: line)
        XCTAssertTrue(result.mappedImageJoined, file: file, line: line)
        XCTAssertEqual(result.gateReleaseCount, 0, file: file, line: line)
        XCTAssertTrue(expectedReachedPrefix(result.frames, selected: ordinal), file: file, line: line)
        XCTAssertEqual(
            result.eventStream.count,
            result.frames.count * 16,
            file: file,
            line: line
        )
        XCTAssertEqual(result.signals.count, 2, file: file, line: line)
        guard result.signals.count == 2 else { return }
        XCTAssertEqual(result.signals[0].signal, SIGCONT, file: file, line: line)
        XCTAssertEqual(result.signals[0].reason, .resume, file: file, line: line)
        XCTAssertEqual(result.signals[1].signal, SIGKILL, file: file, line: line)
        XCTAssertEqual(result.signals[1].reason, .intentionalCut(ordinal), file: file, line: line)
        XCTAssertLessThan(
            (result.signals[1].returnedNanoseconds ?? .max) -
                result.startNanoseconds,
            operationNanoseconds,
            file: file,
            line: line
        )
    }

    private func eventKindToken(_ kind: EventKind) -> String {
        switch kind {
        case .passed: return "passed"
        case .reached: return "reached"
        case .normalTerminal: return "normalTerminal"
        case .failure: return "failure"
        }
    }

    private func signalReasonToken(_ reason: SignalReason) -> String {
        switch reason {
        case .resume: return "resume"
        case .intentionalCut(let ordinal):
            return "intentionalCut(\(ordinal))"
        case .preResumeContainment: return "preResumeContainment"
        case .protocolContainment: return "protocolContainment"
        case .operationDeadline: return "operationDeadline"
        }
    }

    private func relativeNanoseconds(
        _ value: UInt64?,
        start: UInt64
    ) -> String {
        guard let value, value >= start else { return "unavailable" }
        return String(value - start)
    }

    private func hexadecimal(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private func cutRowAttachment(
        ordinal: UInt8,
        expectedClass: H4D3.TestRetainedStateClass,
        reachedEvidenceTag: String?,
        publisher: PublisherResult,
        retained: H4D3.TestRetainedStateEvidence,
        readerExpectedExit: Int32,
        reader: ReaderResult
    ) throws -> XCTAttachment {
        guard let interstice = H4D3.TestPublicationInterstice(
            rawValue: ordinal
        ) else {
            throw HarnessFailure.fixture
        }
        let eventPrefix = publisher.frames.map {
            "\(eventKindToken($0.kind)):\($0.ordinal):\($0.sequence):\($0.status)"
        }.joined(separator: ",")
        let signalEvidence = publisher.signals.map {
            let entered = relativeNanoseconds(
                $0.enteredNanoseconds,
                start: publisher.startNanoseconds
            )
            let returned = relativeNanoseconds(
                $0.returnedNanoseconds,
                start: publisher.startNanoseconds
            )
            return [
                "pid=\($0.pid)",
                "signal=\($0.signal)",
                "reason=\(signalReasonToken($0.reason))",
                "result=\($0.result)",
                "errno=\($0.capturedErrno)",
                "entered_ns=\(entered)",
                "returned_ns=\(returned)",
            ].joined(separator: ":")
        }.joined(separator: ",")
        let readerSignals = reader.signals.map {
            let entered = relativeNanoseconds(
                $0.enteredNanoseconds,
                start: reader.startNanoseconds
            )
            let returned = relativeNanoseconds(
                $0.returnedNanoseconds,
                start: reader.startNanoseconds
            )
            return [
                "pid=\($0.pid)",
                "signal=\($0.signal)",
                "reason=\(signalReasonToken($0.reason))",
                "result=\($0.result)",
                "errno=\($0.capturedErrno)",
                "entered_ns=\(entered)",
                "returned_ns=\(returned)",
            ].joined(separator: ":")
        }.joined(separator: ",")
        let predicates = retained.predicates
        let publisherMapped = publisher.mappedImageEvidence
        let readerMapped = reader.mappedImageEvidence
        let predicateEvidence = [
            "rootMetadataExact=\(predicates.rootMetadataExact)",
            "rootJoinExact=\(predicates.rootJoinExact)",
            "inventoryExact=\(predicates.inventoryExact)",
            "leafMetadataExact=\(predicates.leafMetadataExact)",
            "headerExact=\(predicates.headerExact)",
            "pageGeometryExact=\(predicates.pageGeometryExact)",
            "imageReadExact=\(predicates.imageReadExact)",
            "eofExact=\(predicates.eofExact)",
            "vnodeJoinExact=\(predicates.vnodeJoinExact)",
            "sqlitePolicyExact=\(predicates.sqlitePolicyExact)",
            "integrityExact=\(predicates.integrityExact)",
            "schemaExact=\(predicates.schemaExact)",
            "rowExact=\(predicates.rowExact)",
            "canonicalJSONExact=\(predicates.canonicalJSONExact)",
            "canonicalCBORExact=\(predicates.canonicalCBORExact)",
            "indexedScalarsExact=\(predicates.indexedScalarsExact)",
            "representationJoinExact=\(predicates.representationJoinExact)",
            "closesExact=\(predicates.closesExact)",
        ].joined(separator: ",")
        let content = [
            "schema=H4D3C_CUT_ROW_EVIDENCE_V2",
            "ordinal=\(ordinal)",
            "token=\(String(describing: interstice))",
            "reached_evidence_tag=\(reachedEvidenceTag ?? "none")",
            "expected_class=\(expectedClass.rawValue)",
            "actual_class=\(retained.classification.rawValue)",
            "event_frame_count=\(publisher.frames.count)",
            "event_prefix=\(eventPrefix)",
            "event_stream_hex=\(hexadecimal(publisher.eventStream))",
            "publisher_pid=\(publisher.pid)",
            "publisher_signal_count=\(publisher.signals.count)",
            "publisher_signals=\(signalEvidence)",
            "publisher_wait_status=\(publisher.waitStatus)",
            "publisher_exact_reap=true",
            "publisher_term_signal=\(terminatingSignal(publisher.waitStatus))",
            "publisher_reap_elapsed_ns=\(publisher.reapElapsedNanoseconds)",
            "publisher_elapsed_ns=\(publisher.elapsedNanoseconds)",
            "publisher_event_eof=\(publisher.eventEOF)",
            "publisher_stdout_eof=\(publisher.stdoutEOF)",
            "publisher_stderr_eof=\(publisher.stderrEOF)",
            "publisher_stdout_count=\(publisher.stdout.count)",
            "publisher_stderr_count=\(publisher.stderr.count)",
            "publisher_gate_release_count=\(publisher.gateReleaseCount)",
            "publisher_mapped=\(publisher.mappedImageJoined)",
            "publisher_mapped_joined=\(publisherMapped.joined)",
            "publisher_mapped_terminal_result=\(publisherMapped.terminalResult)",
            "publisher_mapped_terminal_errno=\(publisherMapped.terminalErrno)",
            "publisher_mapped_terminal_call_index=" +
                "\(publisherMapped.terminalCallIndex)",
            "publisher_mapped_positive_record_count=" +
                "\(publisherMapped.positiveRecordCount)",
            "publisher_mapped_terminal_cursor=\(publisherMapped.terminalCursor)",
            "publisher_mapped_qualifying_match_count=" +
                "\(publisherMapped.qualifyingMatchCount)",
            "publisher_streams_open_aligned_at_signal=" +
                "\(publisher.cutStreamsOpenAndAlignedAtSignal)",
            "retained_class=\(retained.classification.rawValue)",
            "retained_inventory=\(retained.inventory.joined(separator: ","))",
            "retained_byte_count=\(retained.byteCount)",
            "retained_sha256=\(retained.sha256 ?? "none")",
            "retained_database_readonly=" +
                "\(retained.databaseReadOnlyDiagnostic.map(String.init) ?? "none")",
            "retained_predicates=\(predicateEvidence)",
            "reader_expected_exit=\(readerExpectedExit)",
            "reader_pid=\(reader.pid)",
            "reader_wait_status=\(reader.waitStatus)",
            "reader_exit=\(exitCode(reader.waitStatus))",
            "reader_exact_reap=true",
            "reader_reap_elapsed_ns=\(reader.reapElapsedNanoseconds)",
            "reader_elapsed_ns=\(reader.elapsedNanoseconds)",
            "reader_stdout_count=\(reader.stdout.count)",
            "reader_stderr_count=\(reader.stderr.count)",
            "reader_stdout_eof=\(reader.stdoutEOF)",
            "reader_stderr_eof=\(reader.stderrEOF)",
            "reader_mapped=\(reader.mappedImageJoined)",
            "reader_mapped_joined=\(readerMapped.joined)",
            "reader_mapped_terminal_result=\(readerMapped.terminalResult)",
            "reader_mapped_terminal_errno=\(readerMapped.terminalErrno)",
            "reader_mapped_terminal_call_index=" +
                "\(readerMapped.terminalCallIndex)",
            "reader_mapped_positive_record_count=" +
                "\(readerMapped.positiveRecordCount)",
            "reader_mapped_terminal_cursor=\(readerMapped.terminalCursor)",
            "reader_mapped_qualifying_match_count=" +
                "\(readerMapped.qualifyingMatchCount)",
            "reader_signals=\(readerSignals)",
        ].joined(separator: "\n") + "\n"
        guard content.utf8.count <= 8_192 else {
            throw HarnessFailure.streamBound
        }
        let attachment = XCTAttachment(string: content)
        attachment.name = "H4D3C-cut-0\(ordinal)-" +
            String(describing: interstice)
        attachment.lifetime = .keepAlways
        return attachment
    }

    private func assertEvidence(
        _ evidence: H4D3.TestRetainedStateEvidence,
        expected: H4D3.TestRetainedStateClass,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(evidence.classification, expected, file: file, line: line)
        XCTAssertTrue(evidence.predicates.rootMetadataExact, file: file, line: line)
        XCTAssertTrue(evidence.predicates.rootJoinExact, file: file, line: line)
        XCTAssertTrue(evidence.predicates.inventoryExact, file: file, line: line)
        XCTAssertTrue(evidence.predicates.closesExact, file: file, line: line)
        XCTAssertNotNil(evidence.rootMetadata, file: file, line: line)
        XCTAssertEqual(
            (evidence.rootMetadata?.mode ?? 0) & 0o7777,
            0o700,
            file: file,
            line: line
        )
        switch expected {
        case .emptyBeforePublication:
            XCTAssertTrue(evidence.inventory.isEmpty, file: file, line: line)
            XCTAssertNil(evidence.leafMetadata, file: file, line: line)
            XCTAssertEqual(evidence.byteCount, 0, file: file, line: line)
            XCTAssertNil(evidence.sha256, file: file, line: line)
        case .stagingOnlyEmpty0600:
            XCTAssertEqual(evidence.inventory, [stagingLeaf], file: file, line: line)
            XCTAssertEqual(
                (evidence.leafMetadata?.mode ?? 0) & 0o7777,
                0o600,
                file: file,
                line: line
            )
            XCTAssertEqual(evidence.byteCount, 0, file: file, line: line)
            XCTAssertNil(evidence.sha256, file: file, line: line)
            XCTAssertTrue(evidence.predicates.leafMetadataExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.vnodeJoinExact, file: file, line: line)
        case .stagingOnlyValidV30600, .stagingOnlyValidV30400,
             .finalOnlyValidV3:
            let expectedLeaf = expected == .finalOnlyValidV3 ? finalLeaf : stagingLeaf
            let expectedMode: UInt32 = expected == .stagingOnlyValidV30600 ? 0o600 : 0o400
            XCTAssertEqual(evidence.inventory, [expectedLeaf], file: file, line: line)
            XCTAssertEqual(
                (evidence.leafMetadata?.mode ?? 0) & 0o7777,
                expectedMode,
                file: file,
                line: line
            )
            XCTAssertGreaterThanOrEqual(evidence.byteCount, 100, file: file, line: line)
            XCTAssertLessThanOrEqual(evidence.byteCount, 64 * 4_096, file: file, line: line)
            XCTAssertEqual(evidence.byteCount % 4_096, 0, file: file, line: line)
            XCTAssertEqual(evidence.sha256?.count, 64, file: file, line: line)
            XCTAssertTrue(evidence.predicates.leafMetadataExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.headerExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.pageGeometryExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.imageReadExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.eofExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.vnodeJoinExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.sqlitePolicyExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.integrityExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.schemaExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.rowExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.canonicalJSONExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.canonicalCBORExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.indexedScalarsExact, file: file, line: line)
            XCTAssertTrue(evidence.predicates.representationJoinExact, file: file, line: line)
        case .finalOnlyRejected, .ambiguousOrUnexpected:
            XCTFail("negative evidence passed to positive assertion", file: file, line: line)
        }
    }

    private func eventBytes(
        kind: UInt8,
        ordinal: UInt8,
        sequence: UInt16,
        status: UInt32
    ) -> Data {
        var value = Data("EPRD3CE1".utf8)
        value.append(kind)
        value.append(ordinal)
        value.append(UInt8(truncatingIfNeeded: sequence >> 8))
        value.append(UInt8(truncatingIfNeeded: sequence))
        value.append(UInt8(truncatingIfNeeded: status >> 24))
        value.append(UInt8(truncatingIfNeeded: status >> 16))
        value.append(UInt8(truncatingIfNeeded: status >> 8))
        value.append(UInt8(truncatingIfNeeded: status))
        return value
    }

    private func failureTerminalAdmitted(
        frames: [EventFrame],
        waitStatus: Int32,
        stdout: Data = Data(),
        stderr: Data = Data(),
        allEOF: Bool = true
    ) -> Bool {
        guard let terminal = frames.last,
              terminal.kind == .failure,
              terminal.ordinal == 255,
              terminal.sequence == UInt16(frames.count - 1),
              terminal.status == 70 else {
            return false
        }
        for (index, frame) in frames.dropLast().enumerated() {
            guard let expectedOrdinal = UInt8(exactly: index),
                  (frame.kind == .passed || frame.kind == .reached),
                  frame.ordinal == expectedOrdinal,
                  frame.sequence == UInt16(index),
                  frame.status == 0 else {
                return false
            }
        }
        return exited(waitStatus) && exitCode(waitStatus) == 70 &&
            stdout.isEmpty && stderr.isEmpty && allEOF
    }

    private func finalURL(_ root: URL) -> URL {
        root.appendingPathComponent(finalLeaf, isDirectory: false)
    }

    private func stagingURL(_ root: URL) -> URL {
        root.appendingPathComponent(stagingLeaf, isDirectory: false)
    }

    private func makeStagingFixture(root: URL, mode: mode_t) throws {
        try publishFixture(to: root)
        let final = finalURL(root).path
        let staging = stagingURL(root).path
        guard rename(final, staging) == 0, chmod(staging, mode) == 0 else {
            throw HarnessFailure.fixture
        }
    }

    private func makeEmptyStaging(root: URL) throws {
        let descriptor = open(
            stagingURL(root).path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o600)
        )
        guard descriptor >= 0, close(descriptor) == 0 else {
            throw HarnessFailure.fixture
        }
    }

    private func replaceFinalWithSameBytes(root: URL) throws {
        let final = finalURL(root)
        let bytes = try Data(contentsOf: final, options: [.mappedIfSafe])
        let displaced = root.path + ".leaf-displaced"
        guard rename(final.path, displaced) == 0 else {
            throw HarnessFailure.fixture
        }
        let descriptor = open(
            final.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o400)
        )
        guard descriptor >= 0 else { throw HarnessFailure.fixture }
        var offset = 0
        while offset < bytes.count {
            let amount = bytes.withUnsafeBytes {
                pwrite(
                    descriptor,
                    $0.baseAddress?.advanced(by: offset),
                    bytes.count - offset,
                    off_t(offset)
                )
            }
            if amount < 0, errno == EINTR { continue }
            guard amount > 0 else {
                _ = close(descriptor)
                throw HarnessFailure.fixture
            }
            offset += amount
        }
        guard fchmod(descriptor, mode_t(0o400)) == 0,
              close(descriptor) == 0 else {
            throw HarnessFailure.fixture
        }
    }

    private func rewriteFinal(
        root: URL,
        mutate: (inout Data) throws -> Void
    ) throws {
        let final = finalURL(root)
        var bytes = try Data(contentsOf: final)
        try mutate(&bytes)
        guard chmod(final.path, mode_t(0o600)) == 0 else {
            throw HarnessFailure.fixture
        }
        let descriptor = open(
            final.path,
            O_WRONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw HarnessFailure.fixture }
        var openDescriptor = descriptor
        defer { if openDescriptor >= 0 { _ = close(openDescriptor) } }
        var offset = 0
        while offset < bytes.count {
            let amount = bytes.withUnsafeBytes {
                pwrite(
                    descriptor,
                    $0.baseAddress?.advanced(by: offset),
                    bytes.count - offset,
                    off_t(offset)
                )
            }
            if amount < 0, errno == EINTR { continue }
            guard amount > 0, amount <= bytes.count - offset else {
                throw HarnessFailure.fixture
            }
            offset += amount
        }
        guard fchmod(descriptor, mode_t(0o400)) == 0,
              fsync(descriptor) == 0,
              close(descriptor) == 0 else {
            throw HarnessFailure.fixture
        }
        openDescriptor = -1
    }

    private func reboundRoot(_ root: URL) throws {
        let displaced = root.path + ".displaced"
        guard rename(root.path, displaced) == 0,
              mkdir(root.path, mode_t(0o700)) == 0,
              chmod(root.path, mode_t(0o700)) == 0 else {
            throw HarnessFailure.fixture
        }
    }

    func testCommandAndEventFrameGrammarIsBoundedAndFragmentIndependent() throws {
        XCTAssertEqual(commandFrame(mode: 0, ordinal: 255).count, 16)
        XCTAssertEqual(commandFrame(mode: 1, ordinal: 9).count, 16)
        var commandParser = CommandParser()
        let cutCommand = commandFrame(mode: 1, ordinal: 9)
        for fragment in [
            cutCommand.prefix(1),
            cutCommand.dropFirst(1).prefix(6),
            cutCommand.dropFirst(7).prefix(2),
            cutCommand.dropFirst(9),
        ] {
            try commandParser.feed(Data(fragment))
        }
        let parsedCommand = try commandParser.finishEOF()
        XCTAssertEqual(parsedCommand.0, 1)
        XCTAssertEqual(parsedCommand.1, 9)
        var truncatedCommand = CommandParser()
        try truncatedCommand.feed(cutCommand.dropLast())
        XCTAssertThrowsError(try truncatedCommand.finishEOF())
        var trailingCommand = CommandParser()
        try trailingCommand.feed(cutCommand + Data([0]))
        XCTAssertThrowsError(try trailingCommand.finishEOF())

        XCTAssertTrue(fullWriteOutcomeAdmitted(
            [(count: 16, error: 0)],
            expectedCount: 16
        ))
        XCTAssertTrue(fullWriteOutcomeAdmitted(
            [(count: -1, error: EINTR), (count: 16, error: 0)],
            expectedCount: 16
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: 15, error: 0)],
            expectedCount: 16
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: 0, error: 0)],
            expectedCount: 16
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: -1, error: EPIPE)],
            expectedCount: 16
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: -1, error: EINTR)],
            expectedCount: 16
        ))
        // The same predicate is called by the runtime command/gate wrapper;
        // exercise its one-byte gate domain as well as 16-byte frames.
        XCTAssertTrue(fullWriteOutcomeAdmitted(
            [(count: 1, error: 0)],
            expectedCount: 1
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: 0, error: 0)],
            expectedCount: 1
        ))
        XCTAssertFalse(fullWriteOutcomeAdmitted(
            [(count: -1, error: EPIPE)],
            expectedCount: 1
        ))

        var stream = Data()
        for ordinal in UInt8(0)...9 {
            stream.append(eventBytes(
                kind: EventKind.passed.rawValue,
                ordinal: ordinal,
                sequence: UInt16(ordinal),
                status: 0
            ))
        }
        stream.append(eventBytes(
            kind: EventKind.normalTerminal.rawValue,
            ordinal: 255,
            sequence: 10,
            status: 0
        ))
        var byteParser = EventParser()
        for byte in stream { try byteParser.feed(Data([byte])) }
        XCTAssertTrue(expectedBaseline(try byteParser.finishEOF()))

        var unevenParser = EventParser()
        var cursor = 0
        let widths = [3, 1, 15, 2, 31, 7, 5, 29]
        var widthIndex = 0
        while cursor < stream.count {
            let width = min(widths[widthIndex % widths.count], stream.count - cursor)
            try unevenParser.feed(stream[cursor..<(cursor + width)])
            cursor += width
            widthIndex += 1
        }
        XCTAssertTrue(expectedBaseline(try unevenParser.finishEOF()))

        let valid = eventBytes(
            kind: EventKind.passed.rawValue,
            ordinal: 0,
            sequence: 0,
            status: 0
        )
        var truncated = EventParser()
        try truncated.feed(valid.dropLast())
        XCTAssertThrowsError(try truncated.finishEOF())

        var cases: [Data] = []
        var badMagic = valid
        badMagic[0] ^= 1
        cases.append(badMagic)
        cases.append(eventBytes(kind: 0, ordinal: 0, sequence: 0, status: 0))
        cases.append(eventBytes(kind: 1, ordinal: 1, sequence: 0, status: 0))
        cases.append(eventBytes(kind: 1, ordinal: 10, sequence: 0, status: 0))
        cases.append(eventBytes(kind: 1, ordinal: 0, sequence: 1, status: 0))
        cases.append(eventBytes(kind: 1, ordinal: 0, sequence: 0, status: 1))
        cases.append(eventBytes(kind: 3, ordinal: 0, sequence: 0, status: 0))
        cases.append(eventBytes(kind: 3, ordinal: 255, sequence: 0, status: 0))
        cases.append(eventBytes(kind: 4, ordinal: 255, sequence: 0, status: 0))
        for bytes in cases {
            var parser = EventParser()
            XCTAssertThrowsError(try parser.feed(bytes), "bytes: \(bytes as NSData)")
        }

        var duplicateOrdinal = EventParser()
        try duplicateOrdinal.feed(valid)
        XCTAssertThrowsError(try duplicateOrdinal.feed(eventBytes(
            kind: EventKind.passed.rawValue,
            ordinal: 0,
            sequence: 1,
            status: 0
        )))

        var postTerminal = EventParser()
        try postTerminal.feed(stream)
        XCTAssertThrowsError(try postTerminal.feed(eventBytes(
            kind: 1, ordinal: 0, sequence: 11, status: 0
        )))
        var overCap = EventParser()
        XCTAssertThrowsError(try overCap.feed(Data(repeating: 1, count: 4_097)))
    }

    func testFailureFrameAdmissionIsExactAndTerminal() throws {
        let bytes = eventBytes(
            kind: EventKind.failure.rawValue,
            ordinal: 255,
            sequence: 0,
            status: 70
        )
        var parser = EventParser()
        try parser.feed(bytes.prefix(5))
        try parser.feed(bytes.dropFirst(5))
        let frames = try parser.finishEOF()
        XCTAssertTrue(failureTerminalAdmitted(
            frames: frames,
            waitStatus: 70 << 8
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: frames,
            waitStatus: 0
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: frames,
            waitStatus: 70 << 8,
            stdout: Data([1])
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: frames,
            waitStatus: 70 << 8,
            allEOF: false
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: frames + frames,
            waitStatus: 70 << 8
        ))

        var laterParser = EventParser()
        try laterParser.feed(eventBytes(
            kind: EventKind.passed.rawValue,
            ordinal: 0,
            sequence: 0,
            status: 0
        ))
        try laterParser.feed(eventBytes(
            kind: EventKind.reached.rawValue,
            ordinal: 1,
            sequence: 1,
            status: 0
        ))
        try laterParser.feed(eventBytes(
            kind: EventKind.failure.rawValue,
            ordinal: 255,
            sequence: 2,
            status: 70
        ))
        let laterFrames = try laterParser.finishEOF()
        XCTAssertTrue(failureTerminalAdmitted(
            frames: laterFrames,
            waitStatus: 70 << 8
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: Array(laterFrames.dropLast()) + [EventFrame(
                kind: .failure, ordinal: 0, sequence: 2, status: 70
            )],
            waitStatus: 70 << 8
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: Array(laterFrames.dropLast()) + [EventFrame(
                kind: .failure, ordinal: 255, sequence: 2, status: 1
            )],
            waitStatus: 70 << 8
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: Array(laterFrames.dropLast()) + [EventFrame(
                kind: .failure, ordinal: 255, sequence: 3, status: 70
            )],
            waitStatus: 70 << 8
        ))
        XCTAssertFalse(failureTerminalAdmitted(
            frames: laterFrames,
            waitStatus: SIGKILL
        ))
    }

    func testIntentionalCutEvidenceRejectsEveryFrozenNegativeMutation() {
        let parentPID: pid_t = 100
        let pid: pid_t = 101
        let start: UInt64 = 1_000
        let reached = [EventFrame(
            kind: .reached,
            ordinal: 0,
            sequence: 0,
            status: 0
        )]
        func admitted(
            frames: [EventFrame]? = nil,
            streamsOpen: Bool = true,
            mapped: Bool = true,
            gateReleaseCount: Int = 0,
            stdout: Data = Data(),
            allEOF: Bool = true,
            killReturned: UInt64? = nil,
            killReason: SignalReason = .intentionalCut(0),
            waitStatus: Int32 = SIGKILL,
            timedOut: Bool = false,
            exactlyReaped: Bool = true
        ) -> Bool {
            let signals = [
                SignalCall(
                    pid: pid,
                    signal: SIGCONT,
                    result: 0,
                    capturedErrno: 0,
                    reason: .resume,
                    enteredNanoseconds: start + 1,
                    returnedNanoseconds: start + 2
                ),
                SignalCall(
                    pid: pid,
                    signal: SIGKILL,
                    result: 0,
                    capturedErrno: 0,
                    reason: killReason,
                    enteredNanoseconds: start + 3,
                    returnedNanoseconds: killReturned ?? start + 4
                ),
            ]
            return intentionalCutEvidenceAdmitted(
                pid: pid,
                parentPID: parentPID,
                selected: 0,
                frames: frames ?? reached,
                streamsOpenAndAlignedAtSignal: streamsOpen,
                mappedImageJoined: mapped,
                gateReleaseCount: gateReleaseCount,
                stdout: stdout,
                stderr: Data(),
                eventEOF: allEOF,
                stdoutEOF: allEOF,
                stderrEOF: allEOF,
                signals: signals,
                waitStatus: waitStatus,
                timedOut: timedOut,
                exactlyReaped: exactlyReaped,
                startNanoseconds: start,
                elapsedNanoseconds: 10,
                reapElapsedNanoseconds: 9
            )
        }

        XCTAssertTrue(admitted())
        XCTAssertFalse(admitted(waitStatus: 0), "early normal exit")
        XCTAssertFalse(admitted(frames: reached + [EventFrame(
            kind: .passed, ordinal: 1, sequence: 1, status: 0
        )]), "advance after reached")
        XCTAssertFalse(admitted(stdout: Data([1])), "publisher output")
        XCTAssertFalse(admitted(frames: [EventFrame(
            kind: .passed, ordinal: 0, sequence: 0, status: 0
        )]), "wrong event protocol")
        XCTAssertFalse(admitted(streamsOpen: false), "premature EOF or partial frame")
        XCTAssertFalse(admitted(
            killReturned: start + operationNanoseconds
        ), "missed operation deadline")
        XCTAssertFalse(admitted(waitStatus: SIGTERM), "non-SIGKILL reap")
        XCTAssertFalse(admitted(exactlyReaped: false), "reap not proved")
        XCTAssertFalse(admitted(mapped: false), "mapped image not joined")
        XCTAssertFalse(admitted(gateReleaseCount: 1), "gate was released")
        XCTAssertFalse(admitted(allEOF: false), "post-reap EOF not proved")
        XCTAssertFalse(admitted(timedOut: true), "timeout containment")
        XCTAssertFalse(admitted(
            killReason: .protocolContainment
        ), "containment is not intentional-cut evidence")
    }

    func testNormalBaselinePublishesAndFreshReaderAccepts() throws {
        let root = try privateRoot()
        let result = try runPublisher(rootPath: root.path, mode: .baseline)
        assertNormalPublisher(result)
        XCTAssertTrue(expectedBaseline(result.frames))
        XCTAssertEqual(result.gateReleaseCount, 0)
        try assertLeaseReleased(root.path)
        assertEvidence(
            H4D3.classifyRetainedStateForTest(rootPath: root.path),
            expected: .finalOnlyValidV3
        )
        assertReader(try runReader(rootPath: root.path), expectedExitCode: 0)
    }

    func testReleasedGatePlumbingReachesEveryIntersticeWithoutSigkill() throws {
        for ordinal in UInt8(0)...9 {
            let root = try privateRoot()
            let result = try runPublisher(
                rootPath: root.path,
                mode: .releasedGate(ordinal)
            )
            assertNormalPublisher(result)
            XCTAssertTrue(
                expectedReleased(result.frames, selected: ordinal),
                "ordinal: \(ordinal); frames: \(result.frames)"
            )
            XCTAssertEqual(result.gateReleaseCount, 1, "ordinal: \(ordinal)")
            XCTAssertFalse(
                result.signals.contains(where: { $0.signal == SIGKILL }),
                "ordinal: \(ordinal)"
            )
            try assertLeaseReleased(root.path)
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .finalOnlyValidV3
            )
            assertReader(
                try runReader(rootPath: root.path),
                expectedExitCode: 0
            )
        }
    }

    func testEveryExactPidSigkillCutJoinsRetainedClassAndFreshReader() throws {
        let expected: [H4D3.TestRetainedStateClass] = [
            .emptyBeforePublication,
            .stagingOnlyEmpty0600,
            .stagingOnlyValidV30600,
            .stagingOnlyValidV30400,
            .stagingOnlyValidV30400,
            .stagingOnlyValidV30400,
            .stagingOnlyValidV30400,
            .finalOnlyValidV3,
            .finalOnlyValidV3,
            .finalOnlyValidV3,
        ]
        let reachedTags: [UInt8: String] = [
            7: "publicationRenameReturned_directorySyncNotEntered",
            8: "directorySyncReturned_finalOpenNotEntered",
            9: "finalVerificationAndDescriptorClosesCompleted_storeReceiptConstructionNotEntered",
        ]
        XCTAssertEqual(reachedTags.count, 3)

        for ordinal in UInt8(0)...9 {
            let failuresBeforeRow = testRun?.failureCount ?? 0
            let root = try privateRoot()
            let result = try runPublisher(
                rootPath: root.path,
                mode: .intentionalCut(ordinal)
            )
            assertIntentionalCut(result, ordinal: ordinal)
            try assertLeaseReleased(root.path)
            let evidence = H4D3.classifyRetainedStateForTest(rootPath: root.path)
            assertEvidence(evidence, expected: expected[Int(ordinal)])
            if ordinal >= 7 {
                XCTAssertNotNil(reachedTags[ordinal])
            } else {
                XCTAssertNil(reachedTags[ordinal])
            }
            let readerExpectedExit: Int32 = ordinal >= 7 ? 0 : 70
            let reader = try runReader(rootPath: root.path)
            assertReader(
                reader,
                expectedExitCode: readerExpectedExit
            )
            guard (testRun?.failureCount ?? failuresBeforeRow) ==
                    failuresBeforeRow else {
                continue
            }
            add(try cutRowAttachment(
                ordinal: ordinal,
                expectedClass: expected[Int(ordinal)],
                reachedEvidenceTag: reachedTags[ordinal],
                publisher: result,
                retained: evidence,
                readerExpectedExit: readerExpectedExit,
                reader: reader
            ))
        }
    }

    func testMalformedCommandsProduceOnlyExactFailureTerminal() throws {
        var malformed: [Data] = []
        malformed.append(commandFrame(mode: 0, ordinal: 255).dropLast())
        malformed.append(commandFrame(mode: 0, ordinal: 255) + Data([0]))
        var badMagic = commandFrame(mode: 0, ordinal: 255)
        badMagic[0] ^= 1
        malformed.append(badMagic)
        malformed.append(commandFrame(mode: 2, ordinal: 255))
        malformed.append(commandFrame(mode: 0, ordinal: 0))
        malformed.append(commandFrame(mode: 1, ordinal: 255))
        malformed.append(commandFrame(mode: 1, ordinal: 10))
        var reserved = commandFrame(mode: 0, ordinal: 255)
        reserved[15] = 1
        malformed.append(reserved)

        for bytes in malformed {
            let root = try privateRoot()
            let result = try runPublisher(
                rootPath: root.path,
                mode: .malformedCommand(bytes)
            )
            assertPublisherCommon(result)
            XCTAssertTrue(result.mappedImageJoined)
            XCTAssertFalse(result.timedOut)
            XCTAssertTrue(failureTerminalAdmitted(
                frames: result.frames,
                waitStatus: result.waitStatus,
                stdout: result.stdout,
                stderr: result.stderr,
                allEOF: result.eventEOF && result.stdoutEOF && result.stderrEOF
            ))
            XCTAssertEqual(result.signals.map(\.signal), [SIGCONT])
            XCTAssertLessThan(
                result.terminalElapsedNanoseconds ?? .max,
                operationNanoseconds
            )
            XCTAssertLessThan(result.reapElapsedNanoseconds, operationNanoseconds)
            try assertLeaseReleased(root.path)
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .emptyBeforePublication
            )
        }
    }

    func testContainmentPathsCannotSatisfyIntentionalCutEvidence() throws {
        do {
            let root = try privateRoot()
            let probe = PublisherContainmentProbe()
            XCTAssertThrowsError(try runPublisher(
                rootPath: root.path,
                mode: .preResumeContainment,
                containmentProbe: probe
            )) { error in
                guard case HarnessFailure.processAdmission = error else {
                    return XCTFail("unexpected primary error: \(error)")
                }
            }
            let evidence = try XCTUnwrap(probe.evidence)
            assertPublisherContainmentCommon(evidence)
            XCTAssertFalse(evidence.mappedImageJoined)
            XCTAssertTrue(evidence.frames.isEmpty)
            XCTAssertEqual(evidence.gateReleaseCount, 0)
            XCTAssertEqual(evidence.signals.count, 1)
            XCTAssertEqual(evidence.signals.first?.signal, SIGKILL)
            XCTAssertEqual(
                evidence.signals.first?.reason,
                .preResumeContainment
            )
            try assertLeaseReleased(root.path)
        }

        do {
            let root = try privateRoot()
            let probe = PublisherContainmentProbe()
            XCTAssertThrowsError(try runPublisher(
                rootPath: root.path,
                mode: .protocolContainment(0),
                containmentProbe: probe
            )) { error in
                guard case HarnessFailure.protocolRejected = error else {
                    return XCTFail("unexpected primary error: \(error)")
                }
            }
            let evidence = try XCTUnwrap(probe.evidence)
            assertPublisherContainmentCommon(evidence)
            XCTAssertTrue(evidence.mappedImageJoined)
            XCTAssertEqual(evidence.gateReleaseCount, 0)
            XCTAssertTrue(expectedReachedPrefix(
                evidence.frames,
                selected: 0
            ))
            XCTAssertEqual(evidence.signals.map(\.signal), [SIGCONT, SIGKILL])
            XCTAssertEqual(evidence.signals.first?.reason, .resume)
            XCTAssertEqual(evidence.signals.last?.reason, .protocolContainment)
            XCTAssertNotEqual(
                evidence.signals.last?.reason,
                .intentionalCut(0)
            )
            try assertLeaseReleased(root.path)
        }
    }

    func testSuspendedPublisherDeadlineUsesOneContainmentSigkillAfterTenSeconds() throws {
        let root = try privateRoot()
        let result = try runPublisher(
            rootPath: root.path,
            mode: .deadlineContainment
        )
        assertPublisherCommon(result)
        XCTAssertTrue(result.mappedImageJoined)
        XCTAssertTrue(result.timedOut)
        XCTAssertTrue(result.frames.isEmpty)
        XCTAssertEqual(result.signals.count, 1)
        XCTAssertEqual(result.signals.first?.signal, SIGKILL)
        XCTAssertEqual(result.signals.first?.reason, .operationDeadline)
        XCTAssertGreaterThanOrEqual(
            (result.signals.first?.returnedNanoseconds ?? 0) -
                result.startNanoseconds,
            operationNanoseconds
        )
        XCTAssertFalse(exited(result.waitStatus))
        XCTAssertEqual(terminatingSignal(result.waitStatus), SIGKILL)
        try assertLeaseReleased(root.path)
        assertEvidence(
            H4D3.classifyRetainedStateForTest(rootPath: root.path),
            expected: .emptyBeforePublication
        )
    }

    func testClassifierFaultScheduleRetriesAndAllocationOrderingAreFailClosed() throws {
        let root = try privateRoot()
        try publishFixture(to: root)
        try assertLeaseReleased(root.path)

        let ambiguous: [H4D3.TestRetainedStateFault] = [
            .rootOpenRejected,
            .rootLockRejected,
            .directoryScanRejected,
            .inventoryCloseResponseLost,
            .leafOpenRejected,
            .leafCloseResponseLost,
            .rootCloseResponseLost,
        ]
        for fault in ambiguous {
            let evidence = H4D3.classifyRetainedStateForTest(
                rootPath: root.path,
                fault: fault
            )
            XCTAssertEqual(
                evidence.classification,
                .ambiguousOrUnexpected,
                "fault: \(fault)"
            )
            if fault == .inventoryCloseResponseLost ||
                fault == .leafCloseResponseLost ||
                fault == .rootCloseResponseLost {
                XCTAssertFalse(
                    evidence.predicates.closesExact,
                    "fault: \(fault)"
                )
            }
        }

        typealias Predicates = H4D3.TestRetainedStatePredicates
        let representationRejected: [(
            fault: H4D3.TestRetainedStateFault,
            rejected: KeyPath<Predicates, Bool>,
            preserved: [KeyPath<Predicates, Bool>]
        )] = [
            (.headerReadZero, \.headerExact, [\.leafMetadataExact]),
            (.headerReadRejected, \.headerExact, [\.leafMetadataExact]),
            (.imageReadZero, \.imageReadExact, [\.pageGeometryExact]),
            (.imageReadRejected, \.imageReadExact, [\.pageGeometryExact]),
            (.eofReadNonzero, \.eofExact, [\.imageReadExact]),
            (.imageAllocationRejected, \.imageReadExact, [\.pageGeometryExact]),
            (.sqliteOpenRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.sqliteAllocationRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.deserializeRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.readerHardeningRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.queryOnlyRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.filenameRejected, \.sqlitePolicyExact, [\.eofExact]),
            (.integrityRejected, \.integrityExact, [\.sqlitePolicyExact]),
            (.schemaRejected, \.schemaExact, [\.integrityExact]),
            (.authorizerRejected, \.rowExact, [\.schemaExact]),
            (.rowRejected, \.rowExact, [\.schemaExact]),
            (.jsonRejected, \.canonicalJSONExact, [\.rowExact]),
            (.cborRejected, \.canonicalCBORExact, [\.rowExact]),
            (.scalarRejected, \.indexedScalarsExact, [
                \.canonicalJSONExact, \.canonicalCBORExact,
            ]),
            (.statementLeak, \.closesExact, [\.representationJoinExact]),
            (.databaseCloseResponseLost, \.closesExact, [
                \.representationJoinExact,
            ]),
        ]
        for expectation in representationRejected {
            let fault = expectation.fault
            let evidence = H4D3.classifyRetainedStateForTest(
                rootPath: root.path,
                fault: fault
            )
            XCTAssertEqual(
                evidence.classification,
                .finalOnlyRejected,
                "fault: \(fault)"
            )
            XCTAssertFalse(
                evidence.predicates[keyPath: expectation.rejected],
                "rejected predicate; fault: \(fault)"
            )
            for preserved in expectation.preserved {
                XCTAssertTrue(
                    evidence.predicates[keyPath: preserved],
                    "preserved earlier predicate; fault: \(fault)"
                )
            }
        }

        for fault in [
            H4D3.TestRetainedStateFault.headerReadInterruptedOnce,
            .headerReadShortOnce,
            .imageReadInterruptedOnce,
            .imageReadShortOnce,
            .eofReadInterruptedOnce,
        ] {
            assertEvidence(
                H4D3.classifyRetainedStateForTest(
                    rootPath: root.path,
                    fault: fault
                ),
                expected: .finalOnlyValidV3
            )
        }

        let headerRejected = H4D3.classifyRetainedStateForTest(
            rootPath: root.path,
            fault: .headerReadZero
        )
        XCTAssertFalse(headerRejected.predicates.headerExact)
        XCTAssertFalse(headerRejected.predicates.pageGeometryExact)
        XCTAssertFalse(headerRejected.predicates.imageReadExact)

        let allocationRejected = H4D3.classifyRetainedStateForTest(
            rootPath: root.path,
            fault: .imageAllocationRejected
        )
        XCTAssertTrue(allocationRejected.predicates.headerExact)
        XCTAssertTrue(allocationRejected.predicates.pageGeometryExact)
        XCTAssertFalse(allocationRejected.predicates.imageReadExact)
    }

    func testClassifierValidatesEveryFrozenSQLiteHeaderAndPageGeometryField() throws {
        let mutations: [((inout Data) -> Void, Bool)] = [
            ({ $0[0] ^= 1 }, false),
            ({ $0[16] = 0; $0[17] = 1 }, false),
            ({ $0[18] = 2 }, false),
            ({ $0[19] = 2 }, false),
            ({ $0.replaceSubrange(28...31, with: [0, 0, 0, 0]) }, true),
            ({ $0.replaceSubrange(28...31, with: [0, 0, 0, 65]) }, true),
        ]
        for (mutate, headerPrefixAccepted) in mutations {
            let root = try privateRoot()
            try publishFixture(to: root)
            try rewriteFinal(root: root, mutate: mutate)
            let evidence = H4D3.classifyRetainedStateForTest(rootPath: root.path)
            XCTAssertEqual(evidence.classification, .finalOnlyRejected)
            XCTAssertEqual(evidence.predicates.headerExact, headerPrefixAccepted)
            XCTAssertFalse(evidence.predicates.pageGeometryExact)
            XCTAssertFalse(evidence.predicates.imageReadExact)
        }
    }

    func testClassifierIsObservationOnlyAndLeavesExactEvidenceUnchanged() throws {
        let root = try privateRoot()
        try publishFixture(to: root)
        let beforeInventory = try FileManager.default.contentsOfDirectory(
            atPath: root.path
        ).sorted()
        var beforeRoot = stat()
        var beforeLeaf = stat()
        XCTAssertEqual(lstat(root.path, &beforeRoot), 0)
        XCTAssertEqual(lstat(finalURL(root).path, &beforeLeaf), 0)
        let beforeBytes = try Data(contentsOf: finalURL(root))
        let beforeHash = Data(SHA256.hash(data: beforeBytes))

        assertEvidence(
            H4D3.classifyRetainedStateForTest(rootPath: root.path),
            expected: .finalOnlyValidV3
        )

        let afterInventory = try FileManager.default.contentsOfDirectory(
            atPath: root.path
        ).sorted()
        var afterRoot = stat()
        var afterLeaf = stat()
        XCTAssertEqual(lstat(root.path, &afterRoot), 0)
        XCTAssertEqual(lstat(finalURL(root).path, &afterLeaf), 0)
        let afterBytes = try Data(contentsOf: finalURL(root))
        XCTAssertEqual(beforeInventory, [finalLeaf])
        XCTAssertEqual(afterInventory, beforeInventory)
        XCTAssertEqual(FileWitness(afterRoot), FileWitness(beforeRoot))
        XCTAssertEqual(FileWitness(afterLeaf), FileWitness(beforeLeaf))
        XCTAssertEqual(afterBytes.count, beforeBytes.count)
        XCTAssertEqual(Data(SHA256.hash(data: afterBytes)), beforeHash)
        try assertLeaseReleased(root.path)
    }

    func testClassifierPositiveNamespaceShapesMatchFrozenTaxonomy() throws {
        do {
            let root = try privateRoot()
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .emptyBeforePublication
            )
        }
        do {
            let root = try privateRoot()
            try makeEmptyStaging(root: root)
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .stagingOnlyEmpty0600
            )
        }
        do {
            let root = try privateRoot()
            try makeStagingFixture(root: root, mode: mode_t(0o600))
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .stagingOnlyValidV30600
            )
        }
        do {
            let root = try privateRoot()
            try makeStagingFixture(root: root, mode: mode_t(0o400))
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .stagingOnlyValidV30400
            )
        }
        do {
            let root = try privateRoot()
            try publishFixture(to: root)
            assertEvidence(
                H4D3.classifyRetainedStateForTest(rootPath: root.path),
                expected: .finalOnlyValidV3
            )
        }
    }

    func testClassifierRejectsInvalidRootsInventoriesAndLeafKindsWithoutBlocking() throws {
        do {
            let root = try privateRoot()
            XCTAssertEqual(chmod(root.path, mode_t(0o755)), 0)
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .ambiguousOrUnexpected
            )
        }
        do {
            let root = try privateRoot()
            let alias = root.path + ".alias"
            XCTAssertEqual(symlink(root.path, alias), 0)
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: alias).classification,
                .ambiguousOrUnexpected
            )
        }
        do {
            let root = try privateRoot()
            try publishFixture(to: root)
            XCTAssertTrue(FileManager.default.createFile(
                atPath: root.appendingPathComponent("extra").path,
                contents: Data()
            ))
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .ambiguousOrUnexpected
            )
        }

        enum Shape { case fifo, directory, symlink, empty, oversized }
        for shape in [Shape.fifo, .directory, .symlink, .empty, .oversized] {
            let root = try privateRoot()
            let path = finalURL(root).path
            switch shape {
            case .fifo:
                XCTAssertEqual(mkfifo(path, mode_t(0o400)), 0)
            case .directory:
                XCTAssertEqual(mkdir(path, mode_t(0o400)), 0)
            case .symlink:
                XCTAssertEqual(symlink("/dev/null", path), 0)
            case .empty:
                let descriptor = open(
                    path,
                    O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
                    mode_t(0o400)
                )
                XCTAssertGreaterThanOrEqual(descriptor, 0)
                if descriptor >= 0 { XCTAssertEqual(close(descriptor), 0) }
            case .oversized:
                let descriptor = open(
                    path,
                    O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
                    mode_t(0o400)
                )
                XCTAssertGreaterThanOrEqual(descriptor, 0)
                if descriptor >= 0 {
                    XCTAssertEqual(ftruncate(descriptor, off_t(65 * 4_096)), 0)
                    XCTAssertEqual(close(descriptor), 0)
                }
            }
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .ambiguousOrUnexpected,
                "shape: \(shape)"
            )
        }

        do {
            let root = try privateRoot()
            try publishFixture(to: root)
            XCTAssertEqual(chmod(finalURL(root).path, mode_t(0o600)), 0)
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .ambiguousOrUnexpected
            )
        }
        do {
            let root = try privateRoot()
            try publishFixture(to: root)
            XCTAssertEqual(
                Darwin.link(finalURL(root).path, root.path + ".hardlink"),
                0
            )
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .ambiguousOrUnexpected
            )
        }
        do {
            let root = try privateRoot()
            let path = finalURL(root).path
            let descriptor = open(
                path,
                O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
                mode_t(0o400)
            )
            XCTAssertGreaterThanOrEqual(descriptor, 0)
            if descriptor >= 0 {
                XCTAssertEqual(ftruncate(descriptor, off_t(4_096)), 0)
                XCTAssertEqual(close(descriptor), 0)
            }
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(rootPath: root.path).classification,
                .finalOnlyRejected
            )
        }
    }

    func testClassifierVnodeAndRootJoinsRejectReplacementAtEveryHook() throws {
        let leafHookFactories: [
            (URL, @escaping () throws -> Void) -> H4D3.TestRetainedStateHooks
        ] = [
            { _, hook in .init(afterNamedLeafBeforeOpen: hook) },
            { _, hook in .init(afterHeaderReadBeforeMetadataJoin: hook) },
            { _, hook in .init(afterImageReadBeforeMetadataJoin: hook) },
            { _, hook in .init(afterSQLiteCloseBeforeFinalJoin: hook) },
            { _, hook in .init(afterPrecloseLeafJoin: hook) },
            { _, hook in .init(afterLeafCloseBeforeNamedJoin: hook) },
            { _, hook in .init(afterPostcloseNamedJoinBeforeTerminal: hook) },
        ]
        for factory in leafHookFactories {
            let root = try privateRoot()
            try publishFixture(to: root)
            let hooks = factory(root) {
                try self.replaceFinalWithSameBytes(root: root)
            }
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(
                    rootPath: root.path,
                    hooks: hooks
                ).classification,
                .ambiguousOrUnexpected
            )
        }

        let rootHookFactories: [
            (@escaping () throws -> Void) -> H4D3.TestRetainedStateHooks
        ] = [
            { .init(afterNamedRootBeforeOpen: $0) },
            { .init(afterInitialInventory: $0) },
            { .init(afterNamedLeafBeforeOpen: $0) },
            { .init(afterHeaderReadBeforeMetadataJoin: $0) },
            { .init(afterImageReadBeforeMetadataJoin: $0) },
            { .init(afterSQLiteCloseBeforeFinalJoin: $0) },
            { .init(afterPrecloseLeafJoin: $0) },
            { .init(afterLeafCloseBeforeNamedJoin: $0) },
            { .init(afterPostcloseNamedJoinBeforeTerminal: $0) },
        ]
        for factory in rootHookFactories {
            let root = try privateRoot()
            try publishFixture(to: root)
            let hooks = factory { try self.reboundRoot(root) }
            XCTAssertEqual(
                H4D3.classifyRetainedStateForTest(
                    rootPath: root.path,
                    hooks: hooks
                ).classification,
                .ambiguousOrUnexpected
            )
        }
    }

    func testCopiedStatPredicatesRejectEveryMetadataAxisAndSpecialVnodeMode() throws {
        let root = try privateRoot()
        try publishFixture(to: root)
        var rootStat = stat()
        var leafStat = stat()
        XCTAssertEqual(lstat(root.path, &rootStat), 0)
        XCTAssertEqual(lstat(finalURL(root).path, &leafStat), 0)
        let size = Int(leafStat.st_size)
        XCTAssertTrue(H4D3.retainedRootMetadataIsValidForTest(rootStat))
        XCTAssertTrue(H4D3.retainedLeafMetadataIsValidForTest(
            leafStat,
            expectedMode: 0o400,
            expectedSize: size
        ))

        var changedRoot = rootStat
        changedRoot.st_uid &+= 1
        XCTAssertFalse(H4D3.retainedRootMetadataIsValidForTest(changedRoot))
        changedRoot = rootStat
        changedRoot.st_mode = (changedRoot.st_mode & ~mode_t(0o7777)) | 0o755
        XCTAssertFalse(H4D3.retainedRootMetadataIsValidForTest(changedRoot))
        for type in [S_IFREG, S_IFIFO, S_IFCHR, S_IFBLK, S_IFSOCK] {
            changedRoot = rootStat
            changedRoot.st_mode = (changedRoot.st_mode & ~S_IFMT) | type
            XCTAssertFalse(H4D3.retainedRootMetadataIsValidForTest(changedRoot))
        }

        var changedLeaf = leafStat
        changedLeaf.st_uid &+= 1
        XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
            changedLeaf, expectedMode: 0o400, expectedSize: size
        ))
        changedLeaf = leafStat
        changedLeaf.st_nlink = 2
        XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
            changedLeaf, expectedMode: 0o400, expectedSize: size
        ))
        changedLeaf = leafStat
        changedLeaf.st_size += 1
        XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
            changedLeaf, expectedMode: 0o400, expectedSize: size
        ))
        for type in [S_IFDIR, S_IFIFO, S_IFCHR, S_IFBLK, S_IFSOCK] {
            changedLeaf = leafStat
            changedLeaf.st_mode = (changedLeaf.st_mode & ~S_IFMT) | type
            XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
                changedLeaf, expectedMode: 0o400, expectedSize: size
            ))
        }
        XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
            leafStat, expectedMode: 0o200, expectedSize: size
        ))
        XCTAssertFalse(H4D3.retainedLeafMetadataIsValidForTest(
            leafStat, expectedMode: 0o400, expectedSize: 65 * 4_096
        ))
    }

    func testIntersticeOrderAndPublisherTargetIsolationAreExact() throws {
        XCTAssertEqual(
            H4D3.TestPublicationInterstice.allCases.map(\.rawValue),
            Array(UInt8(0)...9)
        )
        XCTAssertEqual(
            H4D3.TestPublicationInterstice.allCases.map { String(describing: $0) },
            [
                "beforeStagingCreate",
                "afterStagingCreate",
                "afterCompleteImagePwrite",
                "afterModeSealAndFstat",
                "afterStagingFSync",
                "afterStagingFullSync",
                "afterStagingReadbackAndVnodeJoin",
                "afterPublicationRename",
                "afterDirectoryFSync",
                "afterFinalVerificationBeforeStoreReceipt",
            ]
        )

        let repository = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let mainSource = try String(
            contentsOf: repository.appendingPathComponent(
                "Sources/H4D3cCutPublisherMain.swift"
            ),
            encoding: .utf8
        )
        let writeStart = try XCTUnwrap(mainSource.range(
            of: "private func writeFrame"
        ))
        let writeTail = mainSource[writeStart.lowerBound...]
        let writeEnd = try XCTUnwrap(writeTail.range(
            of: "private func eventWriteFailed"
        ))
        let writeFrameSource = String(writeTail[..<writeEnd.lowerBound])
        for required in [
            "Darwin.write", "if result == frame.count",
            "if result < 0 && errno == EINTR { continue }",
            "eventWriteFailed()",
        ] {
            XCTAssertTrue(writeFrameSource.contains(required), required)
        }
        for forbidden in [
            "posix_spawn", "proc_pidinfo", "proc_regionfilename",
            "waitpid", "poll(", "kill(", "signal(", "raise(",
            "fork(", "Process(", "import Hypervisor", "hv_",
            "URLSession", "NWConnection", "system(", "popen(",
            "getenv(", "Date(", "ContinuousClock", "DispatchTime",
        ] {
            XCTAssertFalse(mainSource.contains(forbidden), forbidden)
        }

        let project = try String(
            contentsOf: repository.appendingPathComponent(
                "ErgenticsProvenance.xcodeproj/project.pbxproj"
            ),
            encoding: .utf8
        )
        let marker = "B5000000000000000000000A /* Sources */ = {"
        let start = try XCTUnwrap(project.range(of: marker))
        let tail = project[start.lowerBound...]
        let end = try XCTUnwrap(tail.range(
            of: "runOnlyForDeploymentPostprocessing = 0;"
        ))
        let publisherSources = String(tail[..<end.upperBound])
        for required in [
            "H4D3cCutPublisherMain.swift in Sources",
            "HypervisorStageH4Privacy.swift in Sources",
            "HypervisorStageH4CanonicalStreams.swift in Sources",
            "HypervisorStageH4OwnerBinding.swift in Sources",
            "HypervisorStageH4Persistence.swift in Sources",
            "HypervisorStageH4DualStreamPersistence.swift in Sources",
        ] {
            XCTAssertTrue(publisherSources.contains(required), required)
        }
        for forbidden in [
            "HypervisorStageH4DualStreamRestartInspection.swift",
            "HypervisorStageH4DualStreamSigkillCutClassificationTests.swift",
            "HypervisorGuest.c",
        ] {
            XCTAssertFalse(publisherSources.contains(forbidden), forbidden)
        }
        XCTAssertEqual(
            project.components(separatedBy: "EPR_H4_PRIVACY_TESTS").count - 1,
            4
        )
        XCTAssertTrue(project.contains(
            "HypervisorStageH4DualStreamSigkillCutClassificationTests.swift in Sources"
        ))
        XCTAssertTrue(project.contains("SKIP_INSTALL = YES;"))
        XCTAssertTrue(project.contains("CODE_SIGNING_ALLOWED = NO;"))
    }
}

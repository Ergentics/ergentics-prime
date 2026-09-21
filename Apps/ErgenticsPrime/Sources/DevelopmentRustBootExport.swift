#if DEBUG || EPR_BOOT_EXPORT_TESTS || EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
import CryptoKit
import Darwin
import Foundation

/// One borrowed descriptor, one attempted frame. Production admits only FD 1;
/// it never opens a path, duplicates/closes a descriptor, or repairs an output.
/// Keep this non-Sendable instance confined to its output owner. The latch also
/// rejects an accidental competing call without waiting for the first I/O.
final class DevelopmentRustBootExport {
    static let maximumFrameBytes = 524_288
    static let prefix = Data("ERGENTICS_RUST_BOOT_V1 ".utf8)
    static let notEntered = Int32.min
    // Current XNU's kernel-private FWASWRITTEN bit: bsd/sys/fcntl.h;
    // fp_writev in bsd/kern/sys_generic.c sets it after a positive write,
    // and F_GETFL in bsd/kern/kern_descrip.c returns it through OFLAGS.
    // The retained 2026-08-30 host diagnostic measured exactly 0x2 ->
    // 0x10002 after writing, with identity, length and offset all matching.
    // This is one required state transition, not a flag mask or a portable
    // API promise. Any future different transition remains fail-closed.
    private static let kernelWasWrittenFlag: Int32 = 0x0001_0000

    struct Identity: Equatable, Sendable {
        let device: Int64
        let inode: UInt64
        let mode: UInt32
        let owner: UInt32
        let linkCount: UInt64
    }

    struct Result: Equatable, Sendable {
        let bytes: Int
        let sha256: String
        let fsyncStatus: Int32
        let fullSyncStatus: Int32
        let identity: Identity
    }

    struct Failure: Error, CustomStringConvertible, Sendable {
        let stage: String
        let errorNumber: Int32
        let bytesWritten: Int
        let fsyncStatus: Int32
        let fullSyncStatus: Int32
        let expectedState: DescriptorState?
        let observedState: DescriptorState?

        var description: String {
            let states = expectedState.map { "; expected={\($0.description)}" } ?? ""
            let observation = observedState.map { "; observed={\($0.description)}" } ?? ""
            return "Export \(stage): errno=\(errorNumber), written=\(bytesWritten), " +
                "fsync=\(fsyncStatus), fullsync=\(fullSyncStatus)" + states + observation +
                "; output retained, no retry"
        }

        fileprivate init(_ stage: String, _ errorNumber: Int32,
                         bytesWritten: Int = 0, fsyncStatus: Int32 = Int32.min,
                         fullSyncStatus: Int32 = Int32.min,
                         expectedState: DescriptorState? = nil,
                         observedState: DescriptorState? = nil) {
            self.stage = stage
            self.errorNumber = errorNumber
            self.bytesWritten = bytesWritten
            self.fsyncStatus = fsyncStatus
            self.fullSyncStatus = fullSyncStatus
            self.expectedState = expectedState
            self.observedState = observedState
        }
    }

    let identity: Identity
    private let descriptor: Int32
    private let admittedFlags: Int32
    private let consumptionLock = NSLock()
    private var consumed = false
    private enum Policy {
        case rust
        #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
        case h3Qualification
        #endif
    }
    private let policy: Policy

    static func admitStandardOutput() throws -> DevelopmentRustBootExport {
        try DevelopmentRustBootExport(admitting: STDOUT_FILENO)
    }

    #if EPR_BOOT_EXPORT_TESTS
    /// Compiled only in the hostless test target, never in the application.
    convenience init(testDescriptor: Int32) throws {
        try self.init(admitting: testDescriptor)
    }
    #endif

    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
    static func admitH3QualificationStandardOutput() throws -> DevelopmentRustBootExport {
        try DevelopmentRustBootExport(admitting: STDOUT_FILENO, policy: .h3Qualification)
    }

    func exportH3Qualification(frame: Data) throws -> Result {
        try export(frame: frame, requiredPolicy: .h3Qualification)
    }

    #if EPR_H3_QUALIFICATION_TESTS
    convenience init(h3QualificationTestDescriptor: Int32) throws {
        try self.init(admitting: h3QualificationTestDescriptor, policy: .h3Qualification)
    }
    #endif
    #endif

    private init(admitting descriptor: Int32, policy: Policy = .rust) throws {
        let observed = try Self.inspect(descriptor, stage: "admission")
        guard observed.length == 0, observed.offset == 0 else {
            throw Failure("admission-not-empty-at-zero", EINVAL)
        }
        self.descriptor = descriptor
        self.identity = observed.identity
        self.admittedFlags = observed.flags
        self.policy = policy
    }

    /// The caller has already verified the pure report semantics. This layer
    /// checks only framing and the actual file write/sync/read-back boundary.
    /// Rejected framing consumes the attempt too. It never writes a replacement.
    func export(frame suppliedFrame: Data) throws -> Result {
        try export(frame: suppliedFrame, requiredPolicy: .rust)
    }

    private func export(frame suppliedFrame: Data, requiredPolicy: Policy) throws -> Result {
        consumptionLock.lock()
        let alreadyConsumed = consumed
        consumed = true
        consumptionLock.unlock()
        guard !alreadyConsumed else { throw Failure("already-consumed", EALREADY) }
        guard policy == requiredPolicy else { throw Failure("wrong-export-policy", EINVAL) }

        var written = 0
        var syncStatus = Self.notEntered
        var fullSyncStatus = Self.notEntered
        do {
            let maximum: Int
            let minimum: Int
            switch policy {
            case .rust: maximum = Self.maximumFrameBytes; minimum = Self.prefix.count + 3
            #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
            case .h3Qualification: maximum = 65_552; minimum = 17
            #endif
            }
            guard suppliedFrame.count <= maximum, suppliedFrame.count >= minimum else {
                throw Failure("frame-bound", EMSGSIZE)
            }
            // A private byte copy remains the sole write/compare subject. The
            // caller must keep its Data stable during this initial copy.
            let frame = suppliedFrame.withUnsafeBytes { bytes in
                Data(bytes: bytes.baseAddress!, count: bytes.count)
            }
            switch policy {
            case .rust:
                guard frame.starts(with: Self.prefix), frame.last == 10,
                  frame[Self.prefix.count] == 123, frame[frame.count - 2] == 125,
                  !frame.dropLast().contains(10), !frame.contains(13),
                  String(data: frame, encoding: .utf8) != nil else {
                throw Failure("frame-format", EINVAL)
                }
            #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
            case .h3Qualification:
                guard frame.prefix(8) == Data("EPRH3I01".utf8),
                      frame[8..<16].allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
                      let lengthText = String(data: frame[8..<16], encoding: .ascii),
                      let length = Int(lengthText, radix: 16), (1...65_536).contains(length),
                      frame.count == length + 16 else { throw Failure("frame-format", EINVAL) }
                do {
                    let value = try H3QualificationCanonicalJSON.decode(Data(frame.dropFirst(16)), maximumBytes: 65_536)
                    guard value.objectValue != nil else { throw Failure("frame-root-object", EINVAL) }
                } catch { throw Failure("frame-canonical-json", EINVAL) }
            #endif
            }
            try revalidate(length: 0, offset: 0, stage: "before-write")
            try frame.withUnsafeBytes { bytes in
                #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                var transfer = H3QualificationExportTransferStateMachine(totalBytes: bytes.count)
                #endif
                while written < bytes.count {
                    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                    if policy == .h3Qualification, !transfer.canAttempt { throw Failure("bounded-write-attempts", EINTR) }
                    #endif
                    try revalidate(length: written, offset: written, stage: "write-identity")
                    let count = Darwin.write(descriptor, bytes.baseAddress!.advanced(by: written), bytes.count - written)
                    let code = count < 0 ? errno : 0
                    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                    if policy == .h3Qualification {
                        do { _ = try transfer.consume(count: count, error: code, requested: bytes.count - written) }
                        catch { throw Failure("bounded-write", code == 0 ? EIO : code) }
                        written = transfer.offset
                        continue
                    }
                    #endif
                    if count < 0 {
                        if code == EINTR { continue }
                        throw Failure("write", code)
                    }
                    guard count > 0, count <= bytes.count - written else { throw Failure("write-no-progress", EIO) }
                    written += count
                }
            }
            try revalidate(length: frame.count, offset: frame.count, stage: "before-fsync")
            syncStatus = Darwin.fsync(descriptor)
            let syncError = errno
            if syncStatus != 0 { throw Failure("fsync", syncError) }
            try revalidate(length: frame.count, offset: frame.count, stage: "before-fullsync")
            fullSyncStatus = Darwin.fcntl(descriptor, F_FULLFSYNC)
            let fullSyncError = errno
            if fullSyncStatus != 0 { throw Failure("fullsync", fullSyncError) }
            try revalidate(length: frame.count, offset: frame.count, stage: "before-readback")

            var actual = Data(count: frame.count)
            try actual.withUnsafeMutableBytes { bytes in
                var read = 0
                #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                var transfer = H3QualificationExportTransferStateMachine(totalBytes: bytes.count)
                #endif
                while read < bytes.count {
                    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                    if policy == .h3Qualification, !transfer.canAttempt { throw Failure("bounded-readback-attempts", EINTR) }
                    #endif
                    try revalidate(length: frame.count, offset: frame.count, stage: "readback-identity")
                    let count = Darwin.pread(descriptor, bytes.baseAddress!.advanced(by: read), bytes.count - read, off_t(read))
                    let code = count < 0 ? errno : 0
                    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                    if policy == .h3Qualification {
                        do { _ = try transfer.consume(count: count, error: code, requested: bytes.count - read) }
                        catch { throw Failure("bounded-readback", code == 0 ? EIO : code) }
                        read = transfer.offset
                        continue
                    }
                    #endif
                    if count < 0 {
                        if code == EINTR { continue }
                        throw Failure("pread", code)
                    }
                    guard count > 0, count <= bytes.count - read else { throw Failure("readback-short", EIO) }
                    read += count
                }
            }
            var extra: UInt8 = 0
            #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
            var endTransfer = H3QualificationExportTransferStateMachine(totalBytes: frame.count)
            #endif
            while true {
                let count = Darwin.pread(descriptor, &extra, 1, off_t(frame.count))
                #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                if policy == .h3Qualification {
                    let code = count < 0 ? errno : 0
                    do { try endTransfer.consumeEOF(count: count, error: code) }
                    catch { throw Failure("bounded-readback-end", code == 0 ? EIO : code) }
                    break
                }
                #endif
                if count < 0 {
                    let code = errno
                    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
                    if policy == .h3Qualification { throw Failure("bounded-readback-end", code) }
                    #endif
                    if code == EINTR { continue }
                    throw Failure("readback-end", code)
                }
                guard count == 0 else { throw Failure("readback-extra-bytes", EIO) }
                break
            }
            try revalidate(length: frame.count, offset: frame.count, stage: "after-readback")
            guard actual == frame else { throw Failure("readback-byte-mismatch", EIO) }
            let expectedHash = Self.hash(frame)
            guard Self.hash(actual) == expectedHash else { throw Failure("readback-hash-mismatch", EIO) }
            return Result(bytes: frame.count, sha256: expectedHash, fsyncStatus: syncStatus,
                          fullSyncStatus: fullSyncStatus, identity: identity)
        } catch let error as Failure {
            throw Failure(error.stage, error.errorNumber, bytesWritten: written,
                          fsyncStatus: syncStatus, fullSyncStatus: fullSyncStatus,
                          expectedState: error.expectedState, observedState: error.observedState)
        }
    }

    struct DescriptorState: Equatable, Sendable, CustomStringConvertible {
        let identity: Identity
        let flags: Int32
        let length: off_t
        let offset: off_t

        var description: String {
            "device=\(identity.device), inode=\(identity.inode), mode=\(identity.mode), " +
                "owner=\(identity.owner), nlink=\(identity.linkCount), " +
                "flags=\(flags)/0x\(String(UInt32(bitPattern: flags), radix: 16)), " +
                "length=\(length), offset=\(offset)"
        }
    }

    private static func inspect(_ descriptor: Int32, stage: String) throws -> DescriptorState {
        var value = stat()
        let statStatus = Darwin.fstat(descriptor, &value)
        let statError = errno
        guard statStatus == 0 else { throw Failure(stage + "-fstat", statError) }
        guard value.st_mode & S_IFMT == S_IFREG, value.st_mode & 0o7777 == 0o600,
              value.st_uid == geteuid(), value.st_nlink == 1, value.st_size >= 0 else {
            throw Failure(stage + "-file-policy", EINVAL)
        }
        let flags = Darwin.fcntl(descriptor, F_GETFL)
        let flagsError = errno
        guard flags >= 0 else { throw Failure(stage + "-flags", flagsError) }
        guard flags & O_ACCMODE == O_RDWR, flags & O_APPEND == 0 else {
            throw Failure(stage + "-access-mode", EINVAL)
        }
        let offset = Darwin.lseek(descriptor, 0, SEEK_CUR)
        let offsetError = errno
        guard offset >= 0 else { throw Failure(stage + "-offset", offsetError) }
        let identity = Identity(device: Int64(value.st_dev), inode: UInt64(value.st_ino),
                                mode: UInt32(value.st_mode), owner: UInt32(value.st_uid),
                                linkCount: UInt64(value.st_nlink))
        return DescriptorState(identity: identity, flags: flags, length: value.st_size, offset: offset)
    }

    private func revalidate(length: Int, offset: Int, stage: String) throws {
        let observed = try Self.inspect(descriptor, stage: stage)
        // Here length is the exporter's accumulated successful write count,
        // never the observed file size or another caller-supplied input.
        let expectedFlags = admittedFlags | (length > 0 ? Self.kernelWasWrittenFlag : 0)
        guard observed.identity == identity, observed.flags == expectedFlags,
              observed.length == off_t(length), observed.offset == off_t(offset) else {
            let expected = DescriptorState(identity: identity, flags: expectedFlags,
                                           length: off_t(length), offset: off_t(offset))
            throw Failure(stage + "-changed", EINVAL,
                          expectedState: expected, observedState: observed)
        }
    }

    private static func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}

#if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
/// Production and hostile tests share the same progress and interruption limits.
/// No syscall closure or injected product implementation crosses this reducer.
struct H3QualificationExportTransferStateMachine: Sendable {
    enum Rejection: Error { case invalidBound, invalidRequest, exhausted, noProgress, systemError, excessReturn }
    let totalBytes: Int
    private(set) var offset = 0
    private(set) var attempts = 0
    private(set) var eintrCount = 0
    private(set) var failed = false
    private var endAttempted = false

    init(totalBytes: Int) { self.totalBytes = totalBytes }

    var canAttempt: Bool {
        (1...65_552).contains(totalBytes) && !failed && offset < totalBytes &&
            attempts < totalBytes + 16 && eintrCount < 16
    }

    mutating func consumeEOF(count: Int, error: Int32) throws {
        guard !failed, !endAttempted else { failed = true; throw Rejection.exhausted }
        endAttempted = true
        guard count == 0, error == 0 else { failed = true; throw Rejection.systemError }
    }

    mutating func consume(count: Int, error: Int32, requested: Int) throws -> Bool {
        do {
            guard (1...65_552).contains(totalBytes) else { throw Rejection.invalidBound }
            guard !failed, offset < totalBytes, attempts < totalBytes + 16 else { throw Rejection.exhausted }
            guard requested > 0, requested <= totalBytes - offset else { throw Rejection.invalidRequest }
            attempts += 1
            if count == -1 && error == EINTR {
                guard eintrCount < 16 else { throw Rejection.exhausted }
                eintrCount += 1
                return false
            }
            guard count >= 0, error == 0 else { throw Rejection.systemError }
            guard count > 0 else { throw Rejection.noProgress }
            guard count <= requested else { throw Rejection.excessReturn }
            offset += count
            return offset == totalBytes
        } catch {
            failed = true
            throw error
        }
    }
}
#endif
// Descriptor joins are observations, not protection against an in-process
// close/reuse race or another writer between checks. Production owns FD 1 for
// this bounded export interval; the outer observer validates the retained file
// again after actual process exit. No finite filesystem latency is promised.
#endif

import CryptoKit
import Darwin
import Dispatch
import Foundation
import XCTest

final class CapabilityFlowRustReceiptVerifierTests: XCTestCase {
    private typealias C = CapabilityFlowClosure

    // Replaced only after two disjoint Rust builds compare exactly.
    private static let expectedVerifierBytes = 418_400
    private static let expectedVerifierSHA256 =
        "1459be25d714cb7a615604db231fd3baf73cbb28bd7863a51f9161fee07d6851"
    private static let expectedVerifierUUID = "D3E6EC8D-1900-31D7-9019-A0C780B510A6"

    private struct ChildResult {
        let exit: Int32
        let stdout: Data
        let stderr: Data
        let timedOut: Bool
    }

    private struct VerifierAdmission {
        let url: URL
        let descriptor: Int32
        let status: stat
    }

    private enum HarnessFailure: Error {
        case unsealedIdentity
        case missingResource
        case admission(Int32)
        case identity
        case malformedMachO
        case pipe(Int32)
        case spawn(Int32)
        case write(Int32)
        case read(Int32)
        case outputBound
        case wait(Int32)
        case deadlineOverflow
        case containmentUnproven
    }

    private func validReport() throws -> C.Report {
        let root = C.AuthorityRoot(id: C.authorityRootID, policyID: C.policyID,
                                   policyGeneration: C.policyGeneration)
        let claim = C.ObjectState(id: 10, ownerExecutionID: 101,
            role: .theoremClaim, shared: false, persistent: false,
            crossExecution: false, externallyObservable: false, ambient: false,
            distinguishableStates: 2, channelClass: .content,
            theoremState: .init(theorem: .riemannHypothesis, disposition: .candidate))
        let access = C.Access(id: 1, executionID: 101, objectID: 10,
            operation: .certifyTheorem, method: .independentCommit,
            peerExecutionID: nil, capabilityID: nil, outcome: .denied)
        let evidence = C.AuditEvidence(id: 2_000, accessID: access.id, sequence: 0,
            acceptedByVerifierID: 900, digest: try C.auditDigest(for: access),
            suppressed: false)
        let resources = C.ResourceUse(executionTicks: 0, workUnits: 0,
            memoryBytes: 0, graphExpansion: 0, branchCount: 0,
            childExecutions: 0, capabilityOperations: 0,
            persistentWrites: 0, outputBytes: 0)
        let transition = C.Transition(id: 1_001, executionID: 101, purposeID: 77,
            goal: .formalTheorem(theorem: .riemannHypothesis, claimObjectID: 10),
            beforeCapabilityIDs: [], afterCapabilityIDs: [],
            policyIDBefore: C.policyID, policyIDAfter: C.policyID,
            policyGenerationBefore: C.policyGeneration,
            policyGenerationAfter: C.policyGeneration,
            goalSatisfied: false, capabilityBoundaryReached: true,
            terminal: .blockedNeedsAuthority, changeIndexBefore: 4,
            changeIndexAfter: 4, resources: resources)
        let scenario = C.Scenario(authorityRoots: [root],
            beforeObjects: [claim], afterObjects: [claim], grants: [],
            capabilities: [], executions: [.init(id: 101, generation: 1,
                purposeID: 77, capabilityIDs: [])], transition: transition,
            accesses: [access], evidence: [evidence], verifierID: 900)
        return try C.audit(scenario)
    }

    private func verifierURL() throws -> URL {
        guard let url = Bundle(for: Self.self).url(
            forResource: "CapabilityFlowReceiptVerifier", withExtension: nil) else {
            throw HarnessFailure.missingResource
        }
        return url
    }

    private func admitVerifier(_ url: URL) throws -> VerifierAdmission {
        guard Self.expectedVerifierBytes > 0,
              Self.expectedVerifierSHA256.count == 64,
              Self.expectedVerifierSHA256 != "UNSEALED",
              Self.expectedVerifierUUID.count == 36,
              Self.expectedVerifierUUID != "UNSEALED" else {
            throw HarnessFailure.unsealedIdentity
        }

        let descriptor = open(url.path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
        guard descriptor >= 0 else { throw HarnessFailure.admission(errno) }
        do {
            var held = stat()
            guard fstat(descriptor, &held) == 0,
                  held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  held.st_mode & 0o022 == 0,
                  held.st_mode & 0o111 != 0,
                  held.st_nlink == 1,
                  held.st_size == off_t(Self.expectedVerifierBytes) else {
                throw HarnessFailure.identity
            }
            let bytes = try heldBytes(descriptor, count: Self.expectedVerifierBytes)
            guard Data(SHA256.hash(data: bytes)).hex == Self.expectedVerifierSHA256,
                  try machOUUID(bytes) == Self.expectedVerifierUUID else {
                throw HarnessFailure.identity
            }
            let admission = VerifierAdmission(url: url, descriptor: descriptor, status: held)
            try revalidate(admission)
            return admission
        } catch {
            close(descriptor)
            throw error
        }
    }

    private func heldBytes(_ descriptor: Int32, count: Int) throws -> Data {
        guard count > 0, count <= 64 * 1_048_576 else {
            throw HarnessFailure.identity
        }
        var bytes = Data(count: count)
        try bytes.withUnsafeMutableBytes { storage in
            guard let base = storage.baseAddress else { throw HarnessFailure.identity }
            var offset = 0
            while offset < storage.count {
                let amount = pread(descriptor, base.advanced(by: offset),
                                   storage.count - offset, off_t(offset))
                if amount < 0 {
                    if errno == EINTR { continue }
                    throw HarnessFailure.admission(errno)
                }
                guard amount > 0 else { throw HarnessFailure.identity }
                offset += amount
            }
        }
        return bytes
    }

    private func revalidate(_ admission: VerifierAdmission) throws {
        var held = stat()
        var named = stat()
        guard fstat(admission.descriptor, &held) == 0,
              lstat(admission.url.path, &named) == 0,
              sameIdentity(held, admission.status),
              sameIdentity(named, admission.status),
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_mode & 0o022 == 0,
              held.st_mode & 0o111 != 0,
              held.st_nlink == 1 else {
            throw HarnessFailure.identity
        }
        let bytes = try heldBytes(admission.descriptor, count: Self.expectedVerifierBytes)
        guard Data(SHA256.hash(data: bytes)).hex == Self.expectedVerifierSHA256,
              try machOUUID(bytes) == Self.expectedVerifierUUID else {
            throw HarnessFailure.identity
        }
    }

    private func sameIdentity(_ left: stat, _ right: stat) -> Bool {
        left.st_dev == right.st_dev && left.st_ino == right.st_ino &&
        left.st_size == right.st_size && left.st_mode == right.st_mode &&
        left.st_nlink == right.st_nlink
    }

    private func machOUUID(_ bytes: Data) throws -> String {
        func u32(_ offset: Int) throws -> UInt32 {
            guard offset >= 0, bytes.count >= 4, offset <= bytes.count - 4 else {
                throw HarnessFailure.malformedMachO
            }
            return bytes[offset..<offset + 4].enumerated().reduce(0) {
                $0 | (UInt32($1.element) << UInt32($1.offset * 8))
            }
        }
        guard bytes.count >= 32, try u32(0) == 0xfeedfacf else {
            throw HarnessFailure.malformedMachO
        }
        let commandCount = Int(try u32(16))
        let commandBytes = Int(try u32(20))
        guard commandCount <= 256, commandBytes <= bytes.count - 32 else {
            throw HarnessFailure.malformedMachO
        }
        let commandEnd = 32 + commandBytes
        var offset = 32
        var uuid: String?
        for _ in 0..<commandCount {
            guard offset <= commandEnd - 8 else {
                throw HarnessFailure.malformedMachO
            }
            let command = try u32(offset)
            let size = Int(try u32(offset + 4))
            guard size >= 8, size.isMultiple(of: 8), size <= commandEnd - offset else {
                throw HarnessFailure.malformedMachO
            }
            if command == 0x1b {
                guard size == 24, uuid == nil else {
                    throw HarnessFailure.malformedMachO
                }
                let raw = Array(bytes[offset + 8..<offset + 24])
                let hex = raw.map { String(format: "%02X", $0) }.joined()
                uuid = "\(hex.prefix(8))-\(hex.dropFirst(8).prefix(4))-" +
                    "\(hex.dropFirst(12).prefix(4))-\(hex.dropFirst(16).prefix(4))-" +
                    "\(hex.dropFirst(20))"
            }
            offset += size
        }
        guard offset == commandEnd, let uuid else {
            throw HarnessFailure.malformedMachO
        }
        return uuid
    }

    private func frame(scenario: Data, result: Data, root: String) throws -> Data {
        enum Failure: Error { case bounds }
        guard !scenario.isEmpty, !result.isEmpty,
              scenario.count <= 1_048_576, result.count <= 1_048_576,
              let scenarioCount = UInt32(exactly: scenario.count),
              let resultCount = UInt32(exactly: result.count),
              root.utf8.count == 64,
              root.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) })
        else { throw Failure.bounds }
        var value = Data("ERGRHV01".utf8)
        appendBE(1, width: 2, to: &value)
        appendBE(0, width: 2, to: &value)
        appendBE(UInt64(scenarioCount), width: 4, to: &value)
        appendBE(UInt64(resultCount), width: 4, to: &value)
        value.append(contentsOf: root.utf8)
        value.append(scenario)
        value.append(result)
        return value
    }

    private func frame(_ report: C.Report) throws -> Data {
        try frame(scenario: report.scenarioCBOR, result: report.resultCBOR,
                  root: report.commitment.root)
    }

    private func reboundFrame(_ report: C.Report,
                              scenario: Data? = nil,
                              result: Data? = nil) throws -> Data {
        let scenarioBytes = scenario ?? report.scenarioCBOR
        let resultBytes = result ?? report.resultCBOR
        let commitment = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(C.schema.utf8)),
            GenesisLeaf(label: "scenario", payload: scenarioBytes),
            GenesisLeaf(label: "result", payload: resultBytes),
        ])
        return try frame(scenario: scenarioBytes, result: resultBytes,
                         root: commitment.root)
    }

    private func appendBE(_ number: UInt64, width: Int, to bytes: inout Data) {
        for index in (0..<width).reversed() {
            bytes.append(UInt8(truncatingIfNeeded: number >> UInt64(index * 8)))
        }
    }

    private func runVerifier(_ url: URL, frame: Data) throws -> ChildResult {
        let admission = try admitVerifier(url)
        defer { close(admission.descriptor) }
        var input = try makePipe()
        var output: [Int32]
        do { output = try makePipe() } catch {
            closePair(input); throw error
        }
        var stderrPipe: [Int32]
        do { stderrPipe = try makePipe() } catch {
            closePair(input); closePair(output); throw error
        }
        var parentDescriptorsOpen = true
        defer {
            if parentDescriptorsOpen {
                closePair(input); closePair(output); closePair(stderrPipe)
            }
        }

        try setNonblocking(input[1])
        try setNonblocking(output[0])
        try setNonblocking(stderrPipe[0])
        guard fcntl(input[1], F_SETNOSIGPIPE, 1) == 0 else {
            throw HarnessFailure.pipe(errno)
        }

        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        let actionsStatus = posix_spawn_file_actions_init(&actions)
        guard actionsStatus == 0 else { throw HarnessFailure.spawn(actionsStatus) }
        let attributesStatus = posix_spawnattr_init(&attributes)
        guard attributesStatus == 0 else {
            posix_spawn_file_actions_destroy(&actions)
            throw HarnessFailure.spawn(attributesStatus)
        }
        defer {
            posix_spawn_file_actions_destroy(&actions)
            posix_spawnattr_destroy(&attributes)
        }
        for status in [
            posix_spawn_file_actions_adddup2(&actions, input[0], STDIN_FILENO),
            posix_spawn_file_actions_adddup2(&actions, output[1], STDOUT_FILENO),
            posix_spawn_file_actions_adddup2(&actions, stderrPipe[1], STDERR_FILENO),
        ] where status != 0 {
            throw HarnessFailure.spawn(status)
        }
        for descriptor in [input[0], input[1], output[0], output[1],
                           stderrPipe[0], stderrPipe[1]] {
            let status = posix_spawn_file_actions_addclose(&actions, descriptor)
            guard status == 0 else { throw HarnessFailure.spawn(status) }
        }
        let chdirStatus = "/private/var/empty".withCString {
            posix_spawn_file_actions_addchdir(&actions, $0)
        }
        guard chdirStatus == 0 else { throw HarnessFailure.spawn(chdirStatus) }

        var emptyMask = sigset_t()
        var defaultSignals = sigset_t()
        guard sigemptyset(&emptyMask) == 0, sigfillset(&defaultSignals) == 0,
              sigdelset(&defaultSignals, SIGKILL) == 0,
              sigdelset(&defaultSignals, SIGSTOP) == 0 else {
            throw HarnessFailure.spawn(errno)
        }
        for status in [
            posix_spawnattr_setsigmask(&attributes, &emptyMask),
            posix_spawnattr_setsigdefault(&attributes, &defaultSignals),
            posix_spawnattr_setpgroup(&attributes, 0),
        ] where status != 0 {
            throw HarnessFailure.spawn(status)
        }
        let flags = POSIX_SPAWN_SETPGROUP | POSIX_SPAWN_CLOEXEC_DEFAULT |
            POSIX_SPAWN_SETSIGMASK | POSIX_SPAWN_SETSIGDEF
        let flagsStatus = posix_spawnattr_setflags(&attributes, Int16(flags))
        guard flagsStatus == 0 else { throw HarnessFailure.spawn(flagsStatus) }

        try revalidate(admission)
        let start = DispatchTime.now().uptimeNanoseconds
        let (operationDeadline, operationOverflow) = start.addingReportingOverflow(4_000_000_000)
        let (hardDeadline, hardOverflow) = start.addingReportingOverflow(5_000_000_000)
        guard !operationOverflow, !hardOverflow else { throw HarnessFailure.deadlineOverflow }

        var pid: pid_t = 0
        let spawnStatus: Int32 = url.path.withCString { executable in
            var arguments: [UnsafeMutablePointer<CChar>?] = [
                UnsafeMutablePointer(mutating: executable), nil,
            ]
            var environment: [UnsafeMutablePointer<CChar>?] = [nil]
            return arguments.withUnsafeMutableBufferPointer { argv in
                environment.withUnsafeMutableBufferPointer { envp in
                    posix_spawn(&pid, executable, &actions, &attributes,
                                argv.baseAddress, envp.baseAddress)
                }
            }
        }
        closeDescriptor(&input[0]); closeDescriptor(&output[1]); closeDescriptor(&stderrPipe[1])
        guard spawnStatus == 0 else {
            throw HarnessFailure.spawn(spawnStatus)
        }

        var status: Int32 = 0
        var reaped = false
        var killEntered = false
        var inputOffset = 0
        var stdout = Data()
        var stderr = Data()
        var stdoutEOF = false
        var stderrEOF = false
        var timedOut = false

        do {
            try revalidate(admission)
            while true {
                if input[1] >= 0, inputOffset < frame.count {
                    let amount = try frame.withUnsafeBytes { storage -> Int in
                        guard let base = storage.baseAddress else { return 0 }
                        let written = Darwin.write(input[1], base.advanced(by: inputOffset),
                                                   storage.count - inputOffset)
                        if written < 0 {
                            if errno == EINTR || errno == EAGAIN { return 0 }
                            throw HarnessFailure.write(errno)
                        }
                        guard written > 0 else { throw HarnessFailure.write(EIO) }
                        return written
                    }
                    inputOffset += amount
                    if inputOffset == frame.count { closeDescriptor(&input[1]) }
                }

                if output[0] >= 0 {
                    stdoutEOF = try drainAvailable(output[0], into: &stdout)
                    if stdoutEOF { closeDescriptor(&output[0]) }
                }
                if stderrPipe[0] >= 0 {
                    stderrEOF = try drainAvailable(stderrPipe[0], into: &stderr)
                    if stderrEOF { closeDescriptor(&stderrPipe[0]) }
                }

                if !reaped {
                    let waited = waitpid(pid, &status, WNOHANG)
                    if waited == pid {
                        reaped = true
                        closeDescriptor(&input[1])
                    } else if waited < 0, errno != EINTR {
                        throw HarnessFailure.wait(errno)
                    }
                }

                if reaped && stdoutEOF && stderrEOF { break }
                let now = DispatchTime.now().uptimeNanoseconds
                if now >= operationDeadline {
                    timedOut = true
                    if !reaped {
                        try killAndReap(pid, status: &status, killEntered: &killEntered,
                                        hardDeadline: hardDeadline)
                        reaped = true
                    }
                    closeDescriptor(&input[1])
                    if output[0] >= 0 {
                        _ = try drainAvailable(output[0], into: &stdout)
                        closeDescriptor(&output[0])
                    }
                    if stderrPipe[0] >= 0 {
                        _ = try drainAvailable(stderrPipe[0], into: &stderr)
                        closeDescriptor(&stderrPipe[0])
                    }
                    break
                }

                let remaining = operationDeadline - now
                let milliseconds = max(1, min(10, Int((remaining + 999_999) / 1_000_000)))
                var polls = [
                    pollfd(fd: input[1], events: input[1] >= 0 ? Int16(POLLOUT) : 0, revents: 0),
                    pollfd(fd: output[0], events: output[0] >= 0 ? Int16(POLLIN | POLLHUP) : 0, revents: 0),
                    pollfd(fd: stderrPipe[0], events: stderrPipe[0] >= 0 ? Int16(POLLIN | POLLHUP) : 0,
                           revents: 0),
                ]
                let pollStatus = polls.withUnsafeMutableBufferPointer {
                    Darwin.poll($0.baseAddress, nfds_t($0.count), Int32(milliseconds))
                }
                if pollStatus < 0, errno != EINTR { throw HarnessFailure.wait(errno) }
            }
            try revalidate(admission)
        } catch let primaryError {
            closeDescriptor(&input[1])
            var containmentError: Error?
            if !reaped && !killEntered {
                do {
                    try killAndReap(pid, status: &status, killEntered: &killEntered,
                                    hardDeadline: hardDeadline)
                    reaped = true
                } catch {
                    containmentError = error
                }
            }
            closeDescriptor(&output[0]); closeDescriptor(&stderrPipe[0])
            parentDescriptorsOpen = false
            if let containmentError { throw containmentError }
            throw primaryError
        }

        closeDescriptor(&input[1]); closeDescriptor(&output[0]); closeDescriptor(&stderrPipe[0])
        parentDescriptorsOpen = false
        let exited = (status & 0x7f) == 0
        return ChildResult(exit: exited ? ((status >> 8) & 0xff) : -1,
                           stdout: stdout, stderr: stderr, timedOut: timedOut)
    }

    private func makePipe() throws -> [Int32] {
        var descriptors = [Int32](repeating: -1, count: 2)
        guard pipe(&descriptors) == 0 else { throw HarnessFailure.pipe(errno) }
        do {
            for index in descriptors.indices {
                if descriptors[index] <= STDERR_FILENO {
                    let replacement = fcntl(descriptors[index], F_DUPFD_CLOEXEC, 10)
                    guard replacement >= 0 else { throw HarnessFailure.pipe(errno) }
                    close(descriptors[index])
                    descriptors[index] = replacement
                } else {
                    let flags = fcntl(descriptors[index], F_GETFD)
                    guard flags >= 0,
                          fcntl(descriptors[index], F_SETFD, flags | FD_CLOEXEC) == 0 else {
                        throw HarnessFailure.pipe(errno)
                    }
                }
            }
            return descriptors
        } catch {
            closePair(descriptors)
            throw error
        }
    }

    private func setNonblocking(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFL)
        guard flags >= 0, fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0 else {
            throw HarnessFailure.pipe(errno)
        }
    }

    private func drainAvailable(_ descriptor: Int32, into result: inout Data) throws -> Bool {
        var buffer = [UInt8](repeating: 0, count: 256)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, $0.count)
            }
            if count == 0 { return true }
            if count < 0 {
                if errno == EINTR { continue }
                if errno == EAGAIN { return false }
                throw HarnessFailure.read(errno)
            }
            guard count <= 4_096 - result.count else { throw HarnessFailure.outputBound }
            result.append(contentsOf: buffer.prefix(count))
        }
    }

    private func killAndReap(_ pid: pid_t, status: inout Int32,
                             killEntered: inout Bool, hardDeadline: UInt64) throws {
        while true {
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid { return }
            if waited < 0 {
                if errno == EINTR { continue }
                throw HarnessFailure.wait(errno)
            }
            break
        }
        guard !killEntered else { throw HarnessFailure.wait(EALREADY) }
        killEntered = true
        if kill(pid, SIGKILL) != 0, errno != ESRCH {
            throw HarnessFailure.wait(errno)
        }
        while DispatchTime.now().uptimeNanoseconds < hardDeadline {
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid { return }
            if waited < 0, errno == EINTR { continue }
            if waited < 0 { throw HarnessFailure.wait(errno) }
            _ = Darwin.poll(nil, 0, 1)
        }
        throw HarnessFailure.containmentUnproven
    }

    private func closeDescriptor(_ descriptor: inout Int32) {
        if descriptor >= 0 { close(descriptor); descriptor = -1 }
    }

    private func closePair(_ descriptors: [Int32]) {
        for descriptor in descriptors where descriptor >= 0 { close(descriptor) }
    }

    private func assertTerminal(_ value: ChildResult, exit: Int32,
                                file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(value.timedOut, file: file, line: line)
        XCTAssertEqual(value.exit, exit, file: file, line: line)
        XCTAssertTrue(value.stdout.isEmpty, file: file, line: line)
        XCTAssertTrue(value.stderr.isEmpty, file: file, line: line)
    }

    func testIndependentRustProcessAcceptsExactSwiftReceipt() throws {
        let url = try verifierURL()
        let report = try validReport()
        assertTerminal(try runVerifier(url, frame: try frame(report)), exit: 0)
    }

    func testIndependentRustProcessRejectsReplacementRootForgeries() throws {
        let url = try verifierURL()
        let report = try validReport()

        guard case .map(var resultMap) = try GuestCBOR.decode(report.resultCBOR) else {
            return XCTFail("result shape")
        }
        resultMap["commit_candidate_eligible"] = .bool(true)
        let forgedResult = try GuestCBOR.encode(.map(resultMap))
        assertTerminal(try runVerifier(url, frame: try reboundFrame(report,
            result: forgedResult)), exit: 70)

        guard case .map(var scenarioMap) = try GuestCBOR.decode(report.scenarioCBOR),
              case .map(var transition) = scenarioMap["transition"] else {
            return XCTFail("scenario shape")
        }
        transition["goal"] = .array([.unsigned(0), .unsigned(10)])
        scenarioMap["transition"] = .map(transition)
        let ordinaryTheorem = try GuestCBOR.encode(.map(scenarioMap))
        assertTerminal(try runVerifier(url, frame: try reboundFrame(report,
            scenario: ordinaryTheorem)), exit: 70)
    }

    func testIndependentRustProcessRejectsTraceAliasesAndTamper() throws {
        let url = try verifierURL()
        let report = try validReport()
        guard case .map(var scenarioMap) = try GuestCBOR.decode(report.scenarioCBOR),
              case .array(var accesses) = scenarioMap["accesses"],
              case .array(var access) = accesses.first,
              case .array(var evidence) = scenarioMap["evidence"],
              case .array(var evidenceRecord) = evidence.first,
              case .bytes(var digest) = evidenceRecord[4] else {
            return XCTFail("trace shape")
        }

        access[7] = .unsigned(99)
        accesses[0] = .array(access)
        scenarioMap["accesses"] = .array(accesses)
        let unknownOutcome = try GuestCBOR.encode(.map(scenarioMap))
        assertTerminal(try runVerifier(url, frame: try reboundFrame(report,
            scenario: unknownOutcome)), exit: 70)

        guard case .map(var digestMap) = try GuestCBOR.decode(report.scenarioCBOR) else {
            return XCTFail("digest scenario")
        }
        digest[0] ^= 1
        evidenceRecord[4] = .bytes(digest)
        evidence[0] = .array(evidenceRecord)
        digestMap["evidence"] = .array(evidence)
        let changedDigest = try GuestCBOR.encode(.map(digestMap))
        assertTerminal(try runVerifier(url, frame: try reboundFrame(report,
            scenario: changedDigest)), exit: 70)

        var trailing = try frame(report)
        trailing.append(0)
        assertTerminal(try runVerifier(url, frame: trailing), exit: 70)
    }
}

private extension Data {
    var hex: String { map { String(format: "%02x", $0) }.joined() }
}

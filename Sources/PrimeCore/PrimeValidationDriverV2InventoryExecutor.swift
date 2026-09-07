// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

/// These Codable observations carry data only. Their initializers and native
/// producer remain internal; decoding never constructs a retained owner.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryPrestartV1: Codable, Equatable, Sendable {
    public let schema: String
    public let runID: String
    public let ordinal: Int
    public let role: String
    public let predecessorSHA256: String
    public let deadlineStartedAtUptimeNanoseconds: UInt64
    public let deadlineExpiresAtUptimeNanoseconds: UInt64
    public let executableAbsolutePath: String
    public let executableSHA256: String
    public let logicalArgumentZero: String
    public let arguments: [String]
    public let orderedEnvironment: [[String]]
    public let workingDirectoryAbsolutePath: String
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryStartV1: Codable, Equatable, Sendable {
    public let schema: String
    public let role: String
    public let prestartSHA256: String
    public let processIdentifier: Int32
    public let sessionIdentifier: Int32
    public let processGroupIdentifier: Int32
    public let appliedSpawnFlags: UInt16
    public let spawnReturnedUptimeNanoseconds: UInt64
    public let mappedExecutablePathTelemetry: String
    public let exactSuspendedWorkingDirectoryJoin: Bool
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryTerminalV1: Codable, Equatable, Sendable {
    public let schema: String
    public let role: String
    public let startSHA256: String
    public let process: PrimeValidationDriverV2BuildProcessObservation
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventorySequenceTerminalV1: Codable, Equatable, Sendable {
    public let schema: String
    public let runID: String
    public let predecessorBuildBindingSHA256: String
    public let orderedChildTerminalSHA256Values: [String]
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryChildObservation: Codable, Equatable, Sendable {
    public let role: String
    public let process: PrimeValidationDriverV2BuildProcessObservation
    public let prestartBinding: PrimeArtifactBinding
    public let startBinding: PrimeArtifactBinding
    public let terminalBinding: PrimeArtifactBinding
    public let standardOutputBinding: PrimeArtifactBinding
    public let standardErrorBinding: PrimeArtifactBinding
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryRawObservation: Sendable {
    public let predecessorBuildBinding: PrimeArtifactBinding
    public let children: [PrimeValidationDriverV2InventoryChildObservation]
    public let xctestListData: Data
    public let swiftTestingListData: Data
    public let terminalBinding: PrimeArtifactBinding
}

struct PrimeValidationDriverV2InventoryExecutionState {
    let retainedState: PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    let context: PrimeValidationDriverV2RoleContext
    let policies: [PrimeValidationDriverV2ClosedRolePolicy]
    let deadline: PrimeSecureChildPhaseDeadline
    let pinnedBundleInput: PrimeValidationDriverV2PinnedBundleInput
    let buildStaging: PrimeValidationDriverV2BuildStaging
    let artifacts: PrimeValidationDriverV2BuildArtifacts
    let executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation?
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2InventoryOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var state: PrimeValidationDriverV2InventoryExecutionState?
    private var executionStarted = false
    private var authorizedChildCount = 0
    private var inventoryStaging: PrimeValidationDriverV2InventoryStaging?
    private var lastObservedUptimeNanoseconds: UInt64

    init(buildState: PrimeValidationDriverV2BuildExecutionState,
         staging: PrimeValidationDriverV2BuildStaging,
         artifacts: PrimeValidationDriverV2BuildArtifacts,
         deadline: PrimeSecureChildPhaseDeadline) throws {
        let policies = try PrimeValidationDriverV2ClosedRolePolicy.fixedSequence(
            context: buildState.context,
            toolchain: buildState.retainedState.admission.toolchain.observation
        ).filter { $0.role != .build }
        guard policies.map(\.role) == [.listXCTest, .listSwiftTesting],
              policies.allSatisfy({ $0.maximumWallNanoseconds == 300_000_000_000
                  && $0.logicalArgumentZero == "swift-test"
                  && $0.primaryResult == .standardOutput }) else {
            throw inventoryRejected("fixed_policy")
        }
        state = .init(retainedState: buildState.retainedState,
            context: buildState.context, policies: policies, deadline: deadline,
            pinnedBundleInput: buildState.pinnedBundleInput,
            buildStaging: staging, artifacts: artifacts,
            executionPredecessorObservation: buildState.executionPredecessorObservation)
        lastObservedUptimeNanoseconds = deadline.startUptimeNanoseconds
    }

    func beginExecution() throws -> (PrimeValidationDriverV2InventoryExecutionState,
                                     PrimeValidationDriverV2InventoryStaging) {
        lock.lock(); defer { lock.unlock() }
        guard let state, !executionStarted else { throw inventoryRejected("owner_consumed") }
        executionStarted = true
        do {
            try checkpoint(state, startsNewWork: true)
            let staging = try PrimeValidationDriverV2InventoryStaging(build: state.buildStaging)
            inventoryStaging = staging
            try checkpoint(state, startsNewWork: true)
            return (state, staging)
        } catch { self.state = nil; throw error }
    }

    func revalidateContinuity() throws {
        lock.lock(); defer { lock.unlock() }
        guard let state, executionStarted else { throw inventoryRejected("owner_unavailable") }
        do { try checkpoint(state, startsNewWork: false) }
        catch { self.state = nil; throw error }
    }

    func authorizeChildStart(ordinal: Int, role: PrimeValidationDriverV2FixedRole) throws {
        lock.lock(); defer { lock.unlock() }
        guard let state, executionStarted,
              authorizedChildCount < state.policies.count,
              ordinal == authorizedChildCount + 1,
              state.policies[authorizedChildCount].role == role else {
            self.state = nil
            throw inventoryRejected("child_start_order")
        }
        // Admission is consumed even when the subsequent check or spawn fails.
        authorizedChildCount += 1
        do { try checkpoint(state, startsNewWork: true) }
        catch { self.state = nil; throw error }
    }

    func consumeForExecution(staging: PrimeValidationDriverV2InventoryStaging) throws
        -> PrimeValidationDriverV2ExecutionPlanRawCapability {
        lock.lock(); defer { lock.unlock() }
        guard let state, executionStarted, authorizedChildCount == 2,
              inventoryStaging === staging, state.context.executionAuthorized else {
            self.state = nil; throw inventoryRejected("H_transfer_precondition")
        }
        self.state = nil
        try checkpoint(state, startsNewWork: true)
        try staging.requireCompleteValidatedInventory()
        return try .init(state: state, inventoryStaging: staging)
    }

    private func checkpoint(_ state: PrimeValidationDriverV2InventoryExecutionState,
                            startsNewWork: Bool) throws {
        let before = DispatchTime.now().uptimeNanoseconds
        try requireTime(before, state: state, startsNewWork: startsNewWork)
        try state.retainedState.buildRevalidateTransferredContinuity(staging: state.buildStaging)
        try inventoryStaging?.revalidate()
        try state.pinnedBundleInput.revalidateAfterBuild(
            deadlineNanoseconds: state.deadline.expiresAtUptimeNanoseconds)
        try state.artifacts.revalidateAfterBuild(
            deadlineNanoseconds: state.deadline.expiresAtUptimeNanoseconds)
        try state.retainedState.buildRevalidateTransferredContinuity(staging: state.buildStaging)
        let after = DispatchTime.now().uptimeNanoseconds
        guard after >= before else { throw inventoryRejected("clock") }
        try requireTime(after, state: state, startsNewWork: startsNewWork)
        lastObservedUptimeNanoseconds = after
    }

    private func requireTime(_ now: UInt64, state: PrimeValidationDriverV2InventoryExecutionState,
                             startsNewWork: Bool) throws {
        let accepted: Bool
        if startsNewWork {
            accepted = try state.deadline.authorizesNewWork(
                observedAtUptimeNanoseconds: now,
                notBeforeUptimeNanoseconds: lastObservedUptimeNanoseconds)
        } else {
            accepted = try state.deadline.acceptsCompletion(
                observedAtUptimeNanoseconds: now,
                notBeforeUptimeNanoseconds: lastObservedUptimeNanoseconds)
        }
        guard accepted else { throw inventoryRejected("phase_deadline") }
    }

    func poison() { lock.lock(); state = nil; lock.unlock() }
    deinit { state = nil }

    @available(macOS 26.0, *)
    public func executeInventories() throws -> PrimeValidationDriverV2InventoryRawCapability {
        try PrimeValidationDriverV2InventoryExecutor.execute(owner: self)
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2InventoryRawCapability: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2InventoryRawObservation
    private let lock = NSLock()
    private var lifetime: PrimeValidationDriverV2InventoryBoundLifetime?

    init(observation: PrimeValidationDriverV2InventoryRawObservation,
         owner: PrimeValidationDriverV2InventoryOwner,
         staging: PrimeValidationDriverV2InventoryStaging) {
        self.observation = observation
        lifetime = .init(owner: owner, staging: staging)
    }
    public func consumeValidatedBindingLifetime(bindingData: Data) throws
        -> PrimeValidationDriverV2InventoryBoundLifetime {
        lock.lock(); defer { lock.unlock() }
        guard let retained = lifetime else { throw inventoryRejected("raw_consumed") }
        lifetime = nil
        try retained.revalidateContinuity()
        try retained.publishBindingData(bindingData)
        try retained.revalidateContinuity()
        return retained
    }
    public func rejectValidatedBindingLifetime() {
        lock.lock(); defer { lock.unlock() }
        lifetime?.poison(); lifetime = nil
    }
    deinit { lifetime?.poison() }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2InventoryBoundLifetime: @unchecked Sendable {
    private let transferLock = NSLock()
    private var transferred = false
    private let owner: PrimeValidationDriverV2InventoryOwner
    private let staging: PrimeValidationDriverV2InventoryStaging
    fileprivate init(owner: PrimeValidationDriverV2InventoryOwner,
                     staging: PrimeValidationDriverV2InventoryStaging) {
        self.owner = owner; self.staging = staging
    }
    public func revalidateContinuity() throws {
        transferLock.lock(); defer { transferLock.unlock() }
        guard !transferred else { throw inventoryRejected("bound_transferred") }
        try owner.revalidateContinuity()
    }
    public func consumeForExecution() throws -> PrimeValidationDriverV2ExecutionPlanRawCapability {
        transferLock.lock(); defer { transferLock.unlock() }
        guard !transferred else { throw inventoryRejected("bound_transferred") }
        transferred = true
        return try owner.consumeForExecution(staging: staging)
    }

    fileprivate func poison() { owner.poison() }
    fileprivate func publishBindingData(_ data: Data) throws {
        do {
            try owner.revalidateContinuity()
            try staging.publishBindingData(data)
            try owner.revalidateContinuity()
        } catch { owner.poison(); throw error }
    }
    deinit { owner.poison() }
}

/// The only mutable G directory is created through the consumed F owner.
/// Each exact leaf is exclusive and every completed stream remains held.
final class PrimeValidationDriverV2InventoryStaging {
    typealias Directory = PrimeValidationDriverV2BuildStaging.Directory
    typealias Stream = PrimeValidationDriverV2BuildStaging.Stream
    let root: PrimeArtifactRoot
    let predecessorBuildBinding: PrimeArtifactBinding
    private let directory: Directory
    private var leaves = Set<String>()
    private var streams: [String: Stream] = [:]
    private var immutableBindings: [PrimeArtifactBinding] = []
    static let streamLeaves: Set<String> = [
        "xctest-list.stdout.log", "xctest-list.stderr.log",
        "swift-testing-list.stdout.log", "swift-testing-list.stderr.log",
    ]
    static let recordLeaves: Set<String> = [
        "01-xctest-prestart.json", "01-xctest-start.json", "01-xctest-terminal.json",
        "02-swift-testing-prestart.json", "02-swift-testing-start.json", "02-swift-testing-terminal.json",
        "terminal.json",
    ]

    convenience init(build: PrimeValidationDriverV2BuildStaging) throws {
        let predecessor = try build.buildRoot.bindExisting(
            at: "binding.json", purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let directory = try build.createInventoryDirectory()
        try self.init(directory: directory, predecessorBuildBinding: predecessor)
    }

    /// A staging directory is only an internal filesystem utility. It cannot
    /// construct InventoryOwner or restore its consumed native predecessor.
    init(directory: Directory, predecessorBuildBinding: PrimeArtifactBinding) throws {
        try predecessorBuildBinding.validateDeclaration()
        guard predecessorBuildBinding.relativePath == "binding.json",
              predecessorBuildBinding.purpose == .immutableData else {
            throw inventoryRejected("predecessor_binding")
        }
        self.predecessorBuildBinding = predecessorBuildBinding
        self.directory = directory
        root = try PrimeArtifactRoot(heldDirectoryDescriptor: directory.descriptor,
            displayURL: URL(fileURLWithPath: directory.path))
        try revalidate()
    }
    func revalidate() throws {
        try directory.revalidate()
        guard try PrimeValidationDriverV2BuildStaging.entries(directory.descriptor) == leaves else {
            throw inventoryRejected("leaf_inventory")
        }
        for (leaf, stream) in streams {
            try stream.revalidate(parent: directory.descriptor, leaf: leaf)
            if let binding = stream.binding { try root.verify(binding) }
        }
        for binding in immutableBindings { try root.verify(binding) }
    }
    func requireCompleteValidatedInventory() throws {
        guard leaves == Self.streamLeaves.union(Self.recordLeaves).union(["binding.json"]),
              streams.count == 4, streams.values.allSatisfy({ $0.binding != nil }) else {
            throw inventoryRejected("validated_inventory_required")
        }
        try revalidate()
    }
    func createStream(_ leaf: String) throws -> Int32 {
        guard Self.streamLeaves.contains(leaf), !leaves.contains(leaf) else {
            throw inventoryRejected("stream_leaf")
        }
        try revalidate()
        let fd = openat(directory.descriptor, leaf,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 3 else {
            if fd >= 0 { close(fd) }
            throw inventoryRejected("stream_open_\(errno)")
        }
        do {
            guard fchmod(fd, 0o600) == 0 else { throw inventoryRejected("stream_mode") }
            streams[leaf] = try Stream(outputDescriptor: fd, parent: directory.descriptor, leaf: leaf)
            try PrimeValidationDriverV2BuildStaging.synchronize(directory.descriptor)
            leaves.insert(leaf)
            try directory.freezeMetadata()
            try revalidate()
            return fd
        } catch { close(fd); throw error }
    }
    @discardableResult
    func publish<Value: Encodable>(_ value: Value, leaf: String) throws -> PrimeArtifactBinding {
        guard Self.recordLeaves.contains(leaf), !leaves.contains(leaf) else {
            throw inventoryRejected("record_leaf")
        }
        try revalidate()
        let binding = try root.publishCanonicalExclusively(value, at: leaf)
        immutableBindings.append(binding); leaves.insert(leaf)
        try directory.freezeMetadata()
        try revalidate()
        return binding
    }
    func verifyCompletedStreams(_ process: PrimeValidationDriverV2BuildProcessObservation,
                                stdoutLeaf: String, stderrLeaf: String) throws
        -> (PrimeArtifactBinding, PrimeArtifactBinding) {
        try revalidate()
        var bindings: [PrimeArtifactBinding] = []
        for (leaf, observed) in [(stdoutLeaf, process.standardOutput), (stderrLeaf, process.standardError)] {
            guard let stream = streams[leaf], observed.clean else { throw inventoryRejected("stream_completion") }
            try stream.revalidate(parent: directory.descriptor, leaf: leaf)
            let binding = try root.bindExisting(at: leaf, purpose: .immutableData,
                                               maximumByteCount: 16 * 1024 * 1024)
            guard observed.outputDeviceID == UInt64(bitPattern: Int64(stream.original.st_dev)),
                  observed.outputInode == UInt64(stream.original.st_ino),
                  observed.outputByteCount == binding.byteCount,
                  observed.outputSHA256 == binding.sha256 else { throw inventoryRejected("stream_identity") }
            try stream.freeze(binding: binding)
            bindings.append(binding)
        }
        try revalidate()
        return (bindings[0], bindings[1])
    }
    func publishBindingData(_ data: Data) throws {
        guard leaves == Self.streamLeaves.union(Self.recordLeaves),
              streams.count == 4, streams.values.allSatisfy({ $0.binding != nil }),
              !data.isEmpty, data.count <= 16 * 1024 * 1024,
              data.first == 0x7b, data.last == 0x7d else {
            throw inventoryRejected("binding_frame")
        }
        try PrimeValidationDriverV2CanonicalBindingFrame.validate(data)
        try revalidate()
        let binding = try root.publishGeneratedFile(at: "binding.json", purpose: .immutableData,
                                                    maximumByteCount: UInt64(data.count)) { fd in
            try data.withUnsafeBytes { bytes in
                var offset = 0
                while offset < bytes.count {
                    let count = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                    if count < 0 && errno == EINTR { continue }
                    guard count > 0 else { throw inventoryRejected("binding_write") }
                    offset += count
                }
            }
        }
        immutableBindings.append(binding); leaves.insert("binding.json")
        try directory.freezeMetadata()
        try revalidate()
    }
}

enum PrimeValidationDriverV2InventoryExecutor {
    @available(macOS 26.0, *)
    static func execute(owner: PrimeValidationDriverV2InventoryOwner) throws
        -> PrimeValidationDriverV2InventoryRawCapability {
        let (state, staging) = try owner.beginExecution()
        var succeeded = false
        defer { if !succeeded { owner.poison() } }
        var children: [PrimeValidationDriverV2InventoryChildObservation] = []
        var rawLists: [Data] = []
        var predecessor = staging.predecessorBuildBinding.sha256
        for (index, policy) in state.policies.enumerated() {
            try owner.revalidateContinuity()
            let child = try executeChild(owner: owner, state: state, staging: staging,
                executable: state.retainedState.admission.toolchain.swiftPackageExecutable,
                policy: policy, ordinal: index + 1, predecessorSHA256: predecessor)
            let process = child.process
            guard process.exitedNormally, process.exitStatus == 0,
                  process.terminationSignal == 0, !process.coreDumped,
                  process.standardOutput.clean, process.standardError.clean,
                  process.processGroupEmptyAfterReap else { throw inventoryRejected("child_result") }
            let data = try staging.root.readVerified(child.standardOutputBinding,
                                                    maximumByteCount: 16 * 1024 * 1024)
            children.append(child); rawLists.append(data)
            predecessor = child.terminalBinding.sha256
            try owner.revalidateContinuity()
        }
        guard children.map(\.role) == ["list_xctest", "list_swift_testing"], rawLists.count == 2 else {
            throw inventoryRejected("sequence")
        }
        let terminal = try staging.publish(PrimeValidationDriverV2InventorySequenceTerminalV1(
            schema: "prime_driver_v2_gate_g_inventory_terminal_v1",
            runID: state.context.evidenceRunID,
            predecessorBuildBindingSHA256: staging.predecessorBuildBinding.sha256,
            orderedChildTerminalSHA256Values: children.map { $0.terminalBinding.sha256 }
        ), leaf: "terminal.json")
        try owner.revalidateContinuity()
        let raw = PrimeValidationDriverV2InventoryRawCapability(
            observation: .init(predecessorBuildBinding: staging.predecessorBuildBinding,
                children: children, xctestListData: rawLists[0], swiftTestingListData: rawLists[1],
                terminalBinding: terminal), owner: owner, staging: staging)
        succeeded = true
        return raw
    }

    @available(macOS 26.0, *)
    private static func executeChild(
        owner: PrimeValidationDriverV2InventoryOwner,
        state: PrimeValidationDriverV2InventoryExecutionState,
        staging: PrimeValidationDriverV2InventoryStaging,
        executable: PrimeValidationSwiftPMHeldSystemFile,
        policy: PrimeValidationDriverV2ClosedRolePolicy,
        ordinal: Int,
        predecessorSHA256: String
    ) throws -> PrimeValidationDriverV2InventoryChildObservation {
        let prefix: String
        let streamPrefix: String
        switch (ordinal, policy.role) {
        case (1, .listXCTest): prefix = "01-xctest"; streamPrefix = "xctest-list"
        case (2, .listSwiftTesting): prefix = "02-swift-testing"; streamPrefix = "swift-testing-list"
        default: throw inventoryRejected("role_order")
        }
        guard policy.physicalExecutableAbsolutePath == executable.observation.canonicalAbsolutePath,
              policy.logicalArgumentZero == "swift-test",
              policy.standardInputPolicy == .endOfFile,
              policy.standardOutputMaximumByteCount == 16 * 1024 * 1024,
              policy.standardErrorMaximumByteCount == 16 * 1024 * 1024,
              policy.maximumWallNanoseconds == 300_000_000_000 else {
            throw inventoryRejected("child_policy")
        }
        let stdoutLeaf = streamPrefix + ".stdout.log"
        let stderrLeaf = streamPrefix + ".stderr.log"
        let fd = try state.retainedState.admission.primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { close(fd) }
        let cwd = try PrimeSecureChildDarwinProcessProof.snapshotHeldDirectory(
            descriptor: fd, openedWithNoSymbolicLinksInPath: true,
            context: .validationWorkingDirectory
        )
        let prestart = try staging.publish(PrimeValidationDriverV2InventoryPrestartV1(
            schema: "prime_driver_v2_gate_g_inventory_prestart_v1",
            runID: state.context.evidenceRunID,
            ordinal: ordinal, role: policy.role.rawValue, predecessorSHA256: predecessorSHA256,
            deadlineStartedAtUptimeNanoseconds: state.deadline.startUptimeNanoseconds,
            deadlineExpiresAtUptimeNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
            executableAbsolutePath: policy.physicalExecutableAbsolutePath,
            executableSHA256: executable.observation.sha256,
            logicalArgumentZero: policy.logicalArgumentZero,
            arguments: policy.physicalArguments,
            orderedEnvironment: policy.completeReplacementEnvironment.map { [$0.0, $0.1] },
            workingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath
        ), leaf: prefix + "-prestart.json")
        let stdoutFD = try staging.createStream(stdoutLeaf)
        let stderrFD: Int32
        do { stderrFD = try staging.createStream(stderrLeaf) }
        catch { close(stdoutFD); throw error }
        let spawn: PrimeSecureChildSpawnHandle
        do {
            try owner.authorizeChildStart(ordinal: ordinal, role: policy.role)
            spawn = try PrimeSecureChildDarwinSubstrate.spawnDriverV2FixedProbeSuspended(
                executableAbsolutePath: policy.physicalExecutableAbsolutePath,
                argumentZero: policy.logicalArgumentZero,
                workingDirectoryDescriptor: cwd.descriptor,
                exactArguments: policy.physicalArguments,
                orderedEnvironment: policy.completeReplacementEnvironment
            )
        } catch { close(stdoutFD); close(stderrFD); throw error }
        let supervision = PrimeSecureChildSupervisionCapability.adoptFileBacked(
            spawn: spawn, phaseDeadline: state.deadline,
            standardOutputDescriptor: stdoutFD, standardErrorDescriptor: stderrFD,
            maximumByteCount: policy.standardOutputMaximumByteCount
        )
        do {
            let pid = supervision.processIdentifier
            guard supervision.spawnReturnCode == 0,
                  let sid = supervision.establishDriverV2DedicatedGroupWithinSupervisorSession(),
                  sid == getpid()
            else { throw inventoryRejected("spawn_group") }
            var bsd = proc_bsdinfo()
            let bsdSize = Int32(MemoryLayout<proc_bsdinfo>.size)
            let bsdReturned = withUnsafeMutablePointer(to: &bsd) {
                proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, bsdSize)
            }
            guard bsdReturned == bsdSize, bsd.pbi_pid == UInt32(pid),
                  bsd.pbi_ppid == UInt32(sid), bsd.pbi_pgid == UInt32(pid)
            else { throw inventoryRejected("parent_join") }
            let cwdProof = try PrimeSecureChildDarwinProcessProof.captureSuspendedWorkingDirectory(
                processIdentifier: pid, heldDirectory: cwd
            )
            let mapped = try PrimeSecureChildDarwinProcessProof.captureMappedExecutable(
                processIdentifier: pid,
                heldExecutable: PrimeSecureChildDarwinProcessProof.snapshotHeldExecutable(
                    deviceID: executable.observation.deviceID,
                    inode: executable.observation.inode,
                    expectedCanonicalAbsolutePath: executable.observation.canonicalAbsolutePath
                )
            )
            try owner.revalidateContinuity()
            let start = try staging.publish(PrimeValidationDriverV2InventoryStartV1(
                schema: "prime_driver_v2_gate_g_inventory_start_v1", role: policy.role.rawValue,
                prestartSHA256: prestart.sha256,
                processIdentifier: pid, sessionIdentifier: sid, processGroupIdentifier: pid,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnedUptimeNanoseconds: supervision.spawnReturnedMonotonicNanoseconds,
                mappedExecutablePathTelemetry: mapped.mappedExecutablePathTelemetry,
                exactSuspendedWorkingDirectoryJoin: cwdProof.exactDescriptorJoinObserved
            ), leaf: prefix + "-start.json")
            try owner.revalidateContinuity()
            let beforeResume = DispatchTime.now().uptimeNanoseconds
            let resumedAt: UInt64
            switch try supervision.resume(notBeforeUptimeNanoseconds: beforeResume) {
            case let .resumed(time): resumedAt = time
            default: throw inventoryRejected("resume")
            }
            guard case .observed = try supervision.observeDeath(),
                  let deathAt = supervision.deathObservedMonotonicNanoseconds()
            else { throw inventoryRejected("death_deadline") }
            let drains: PrimeSecureChildDrainEvidence
            switch try supervision.waitForPhaseDrainCompletion(notBeforeUptimeNanoseconds: deathAt) {
            case let .completed(value): drains = value
            default: throw inventoryRejected("drain_deadline")
            }
            guard let members = supervision.processGroupMemberIdentifiers(), members == [pid]
            else { throw inventoryRejected("descendants_before_reap") }
            let wait: PrimeSecureChildExactPIDWaitObservation
            switch supervision.reapAfterObservedDeath() {
            case let .reaped(value): wait = value
            case .mustFailStop: Darwin._exit(97)
            }
            guard wait.requestedProcessIdentifier == pid,
                  wait.returnedProcessIdentifier == pid,
                  wait.waitOptions == 0,
                  case let .fileBacked(stdout, stderr) = drains
            else { throw inventoryRejected("wait_or_drain_kind") }
            try owner.revalidateContinuity()
            let process = PrimeValidationDriverV2BuildProcessObservation(
                logicalArgumentZero: policy.logicalArgumentZero,
                arguments: policy.physicalArguments,
                orderedEnvironment: policy.completeReplacementEnvironment.map { [$0.0, $0.1] },
                workingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath,
                workingDirectoryDeviceID: cwd.deviceID, workingDirectoryInode: cwd.inode,
                executableAbsolutePath: executable.observation.canonicalAbsolutePath,
                executableDeviceID: executable.observation.deviceID,
                executableInode: executable.observation.inode,
                executableByteCount: executable.observation.byteCount,
                executableSHA256: executable.observation.sha256,
                mappedImageJoined: true,
                exactSuspendedWorkingDirectoryJoin: cwdProof.exactDescriptorJoinObserved,
                processIdentifier: pid, sessionIdentifier: sid, processGroupIdentifier: pid,
                parentProcessIdentifier: Int32(bsd.pbi_ppid),
                exactReapCount: 1,
                cleanupInitiated: false,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnCode: supervision.spawnReturnCode,
                deadlineStartedAtUptimeNanoseconds: state.deadline.startUptimeNanoseconds,
                deadlineExpiresAtUptimeNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
                spawnReturnedUptimeNanoseconds: supervision.spawnReturnedMonotonicNanoseconds,
                resumedAtUptimeNanoseconds: resumedAt,
                deathObservedUptimeNanoseconds: deathAt,
                waitReturnedUptimeNanoseconds: wait.returnedMonotonicNanoseconds,
                preReapProcessGroupMemberIdentifiers: members,
                requestedWaitProcessIdentifier: wait.requestedProcessIdentifier,
                returnedWaitProcessIdentifier: wait.returnedProcessIdentifier,
                waitOptions: wait.waitOptions, rawWaitStatus: wait.rawWaitStatus,
                exitStatus: wait.exitStatus, terminationSignal: wait.terminationSignal,
                exitedNormally: wait.exitedNormally, coreDumped: wait.coreDumped,
                processGroupEmptyAfterReap: true,
                standardOutput: .init(stdout), standardError: .init(stderr)
            )
            let (stdoutBinding, stderrBinding) = try staging.verifyCompletedStreams(
                process, stdoutLeaf: stdoutLeaf, stderrLeaf: stderrLeaf)
            let terminal = try staging.publish(PrimeValidationDriverV2InventoryTerminalV1(
                schema: "prime_driver_v2_gate_g_inventory_child_terminal_v1",
                role: policy.role.rawValue, startSHA256: start.sha256, process: process),
                leaf: prefix + "-terminal.json")
            return .init(role: policy.role.rawValue, process: process,
                prestartBinding: prestart, startBinding: start, terminalBinding: terminal,
                standardOutputBinding: stdoutBinding, standardErrorBinding: stderrBinding)
        } catch {
            switch supervision.cleanupRejectedCapture() {
            case .contained: break
            case .mustFailStop: Darwin._exit(97)
            }
            throw error
        }
    }
}

private func inventoryRejected(_ reason: String) -> Error {
    PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_inventory_" + reason)
}

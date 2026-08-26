// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation

public enum PrimeValidationSwiftPMBuildInventoryAdmissionError:
    Error,
    Equatable,
    Sendable
{
    case rejected(String)
    case capabilityAlreadyConsumed
    case prerequisiteAlreadyConsumed
    case guardedPreExecutorPoisoned
    case guardedPreExecutorTransferred
}

/// Closed observation of the top-level prerequisite-admission operation that
/// rejected. The underlying error and all associated process or filesystem
/// values are deliberately erased.
@frozen
public enum PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite:
    Error,
    Equatable,
    Sendable
{
    case companionDeclaration
    case primeRepository
    case workspaceRoot
    case workspacePrivateAndEmpty
    case evidenceRoot
    case evidencePrivateAndEmpty
    case companionRepository
    case leaseDirectory
    case leasePrivateAndEmpty
    case rootTopology
    case exclusiveLease
    case postLeaseDirectory
    case sourceSnapshot
    case packageResolvedBinding
    case primeSourceIdentitySnapshot
    case companionContentSnapshot
    case heldToolchain
}

extension PrimeValidationSwiftPMBuildInventoryAdmissionError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case let .rejected(detail):
            "SwiftPM build/inventory prerequisite admission rejected: \(detail)"
        case .capabilityAlreadyConsumed:
            "SwiftPM build/inventory prerequisite capability was already consumed"
        case .prerequisiteAlreadyConsumed:
            "SwiftPM build/inventory prerequisite was already consumed"
        case .guardedPreExecutorPoisoned:
            "SwiftPM build/inventory guarded pre-executor is poisoned"
        case .guardedPreExecutorTransferred:
            "SwiftPM build/inventory guarded pre-executor authority was transferred"
        }
    }
}

/// Exact descriptor identity for an input held by the admission capability.
///
/// These values are observations, not reusable authority. The non-Codable
/// capability below retains the descriptors and lease from which they came.
public struct PrimeValidationSwiftPMDirectoryObservation:
    Equatable,
    Sendable
{
    public let canonicalAbsolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let filesystemType: String
    public let filesystemIDWord0: UInt32
    public let filesystemIDWord1: UInt32
    public let localFilesystemObserved: Bool
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64
}

public struct PrimeValidationSwiftPMFileObservation:
    Equatable,
    Sendable
{
    public let canonicalAbsolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let byteCount: UInt64
    public let sha256: String
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64
}

/// Exact Driver V2 executable identity expected by the same-process bridge.
///
/// This value is a declaration, not live authority. Only the opaque
/// descriptor-retaining capability returned by the guarded pre-executor can
/// prove that the declaration names the process's mapped main image.
public struct PrimeValidationSwiftPMDriverV2ExecutableExpectation:
    Equatable,
    Sendable
{
    public let canonicalAbsolutePath: String
    public let byteCount: UInt64
    public let sha256: String

    public init(
        canonicalAbsolutePath: String,
        byteCount: UInt64,
        sha256: String
    ) {
        self.canonicalAbsolutePath = canonicalAbsolutePath
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    fileprivate func validate() throws {
        guard canonicalAbsolutePath.hasPrefix("/"),
              canonicalAbsolutePath != "/",
              !canonicalAbsolutePath.contains("\\"),
              canonicalAbsolutePath.utf8.count <= 16 * 1024,
              canonicalAbsolutePath.utf8.allSatisfy({
                  $0 >= 0x20 && $0 != 0x7f
              }),
              canonicalAbsolutePath.split(
                  separator: "/",
                  omittingEmptySubsequences: false
              ).dropFirst().allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
              }),
              byteCount > 0,
              sha256.utf8.count == 64,
              sha256.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_supervisor_expectation")
        }
    }
}

/// Descriptor and loaded-vnode observation retained by the Gate A image
/// capability. The two identity pairs are kept separately so the mapped-image
/// join is data, rather than an ungrounded Boolean supplied by a caller.
public struct PrimeValidationSwiftPMDriverV2SupervisorImageObservation:
    Equatable,
    Sendable
{
    public let canonicalAbsolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let loadedImageDeviceID: UInt64
    public let loadedImageInode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let byteCount: UInt64
    public let sha256: String
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64

    public var mappedImageJoined: Bool {
        deviceID == loadedImageDeviceID
            && inode == loadedImageInode
    }
}

public struct PrimeValidationSwiftPMPersonalityObservation:
    Equatable,
    Sendable
{
    public let requestedAbsolutePath: String
    public let symbolicLinkTarget: String
    public let canonicalExecutableAbsolutePath: String
}

public struct PrimeValidationSwiftPMDeterministicEnvironmentEntry:
    Equatable,
    Sendable
{
    public let key: String
    public let value: String
}

public struct PrimeValidationSwiftPMCompanionDeclaration:
    Equatable,
    Sendable
{
    public let expectedPinnedHEAD: String
    public let declaredObservedHEAD: String
    public let declaredPorcelainV2Status: Data
    public let processObservationMissing: Bool

    public init(
        expectedPinnedHEAD: String,
        declaredObservedHEAD: String,
        declaredPorcelainV2Status: Data
    ) {
        self.expectedPinnedHEAD = expectedPinnedHEAD
        self.declaredObservedHEAD = declaredObservedHEAD
        self.declaredPorcelainV2Status = declaredPorcelainV2Status
        processObservationMissing = true
    }
}

public struct PrimeValidationSwiftPMToolchainObservation:
    Equatable,
    Sendable
{
    public let developerDirectory:
        PrimeValidationSwiftPMDirectoryObservation
    public let toolchainDirectory:
        PrimeValidationSwiftPMDirectoryObservation
    public let sdkRoot:
        PrimeValidationSwiftPMDirectoryObservation
    public let xcodeVersionPlist:
        PrimeValidationSwiftPMFileObservation
    public let sdkSettingsPlist:
        PrimeValidationSwiftPMFileObservation
    public let swiftPackageExecutable:
        PrimeValidationSwiftPMFileObservation
    public let swiftBuildPersonality:
        PrimeValidationSwiftPMPersonalityObservation
    public let swiftTestPersonality:
        PrimeValidationSwiftPMPersonalityObservation
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let sdkCanonicalName: String
    /// Deterministic toolchain/workspace base. A later executor must merge
    /// the Prime intent overlay before this can become a complete child
    /// replacement environment.
    public let orderedDeterministicBaseEnvironment:
        [PrimeValidationSwiftPMDeterministicEnvironmentEntry]
    public let swiftVersionProcessObservationMissing: Bool
    public let swiftTargetInfoProcessObservationMissing: Bool
}

public enum PrimeValidationSwiftPMMissingAuthority:
    String,
    CaseIterable,
    Hashable,
    Sendable
{
    case descriptorBackedSourceClosureAndMutationGuard =
        "descriptor_backed_source_closure_and_mutation_guard"
    case sourceWatchWindow = "source_watch_window"
    case supervisorExecutableImage = "supervisor_executable_image"
    case primeGitHEADAndCleanProcessObservation =
        "prime_git_head_and_clean_process_observation"
    case companionGitHEADAndCleanProcessObservation =
        "companion_git_head_and_clean_process_observation"
    case swiftVersionProcessObservation =
        "swift_version_process_observation"
    case swiftTargetInfoProcessObservation =
        "swift_target_info_process_observation"
    case swiftPMBuildExecution = "swiftpm_build_execution"
    case xctestInventoryExecution = "xctest_inventory_execution"
    case swiftTestingInventoryExecution =
        "swift_testing_inventory_execution"
    case artifactStaging = "artifact_staging"
}

public enum PrimeValidationSwiftPMAuthorityCeiling:
    String,
    Sendable
{
    case retainedInputsOnlyNoPreparedExecutor =
        "retained_inputs_only_no_prepared_executor"
    case sourceGuardsPreparedOnly = "source_guards_prepared_only"
    case transferredNoAuthority = "transferred_no_authority"
    case poisonedNoAuthority = "poisoned_no_authority"
}

public enum PrimeValidationSwiftPMGuardState:
    String,
    Equatable,
    Sendable
{
    case prepared
    case transferred
    case poisoned
}

/// State of the consumed, role-bound current-process image capability.
/// This is deliberately distinct from the pre-executor's prepared state.
public enum PrimeValidationSwiftPMDriverV2SupervisorImageState:
    String,
    Equatable,
    Sendable
{
    case bound
    case transferred
    case poisoned
}

/// Nonoptional evidence state for work owned by a later executor.
///
/// This admission-only boundary uses `unobserved`. It never substitutes an
/// observed negative result for process, build, or inventory evidence that
/// no process has produced.
public enum PrimeValidationSwiftPMObservationState:
    String,
    Equatable,
    Sendable
{
    case observedTrue = "observed_true"
    case observedFalse = "observed_false"
    case unobserved
}

/// A consumed, still-live prerequisite token for a later closed executor.
///
/// This type intentionally has no public initializer and no Codable
/// conformance. It retains all admitted descriptors and the exclusive lease,
/// but exposes no process-launch operation. It cannot mint a Driver V2
/// admission receipt because every process-derived authority named by
/// `missingAuthorities` remains unobserved.
public final class PrimeValidationSwiftPMBuildInventoryPrerequisite:
    @unchecked Sendable
{
    private enum State {
        case available(PrimeValidationSwiftPMRetainedAdmissionState)
        case consumed
    }

    public let primeRepository:
        PrimeValidationSwiftPMDirectoryObservation
    public let workspaceRoot:
        PrimeValidationSwiftPMDirectoryObservation
    public let evidenceRoot:
        PrimeValidationSwiftPMDirectoryObservation
    public let companionRepository:
        PrimeValidationSwiftPMDirectoryObservation
    public let sourceIdentitySHA256: String
    public let packageResolvedBinding: PrimeArtifactBinding
    public let companionDeclaration:
        PrimeValidationSwiftPMCompanionDeclaration
    public let toolchain:
        PrimeValidationSwiftPMToolchainObservation
    public let missingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority]
    public var authorityCeiling:
        PrimeValidationSwiftPMAuthorityCeiling
    {
        preparationLock.lock()
        defer { preparationLock.unlock() }
        switch state {
        case .available:
            return .retainedInputsOnlyNoPreparedExecutor
        case .consumed:
            return .transferredNoAuthority
        }
    }
    public let processExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let buildExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let inventoryExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    // This is authorization, not evidence that completion ran and returned
    // an observed negative result.
    public let completionAuthorized = false

    // Retention is the authority. A decoded or memberwise-reconstructed value
    // cannot create this state because there is no public initializer.
    private let preparationLock = NSLock()
    private var state: State

    init(
        retainedState: PrimeValidationSwiftPMRetainedAdmissionState
    ) {
        state = .available(retainedState)
        primeRepository = retainedState.primeRepository.observation
        workspaceRoot = retainedState.workspaceRoot.observation
        evidenceRoot = retainedState.evidenceRoot.observation
        companionRepository = retainedState.companionRepository.observation
        sourceIdentitySHA256 =
            retainedState.sourceSnapshot.sourceIdentitySHA256
        packageResolvedBinding = retainedState.packageResolvedBinding
        companionDeclaration = retainedState.companionDeclaration
        toolchain = retainedState.toolchain.observation
        missingAuthorities =
            PrimeValidationSwiftPMMissingAuthority.allCases
    }

    /// Atomically transfers the retained admission state into a guarded,
    /// still-non-executing pre-executor.
    ///
    /// The Prime and companion working-tree watches are both armed before the
    /// current holder-process image is retained. A complete guard checkpoint
    /// then revalidates all previously admitted inputs while workspace and
    /// evidence roots are still empty. Failure poisons this one-shot
    /// transition; callers cannot retry with changed content or image.
    public func prepareGuardedPreExecutor() throws
        -> PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
    {
        try prepareGuardedPreExecutor(
            allowRootOwnedCurrentProcessForTesting: false
        )
    }

    /// Internal test seam for XCTest's root-owned Apple `xctest` host image.
    /// The retained image remains a non-authoritative current-process
    /// observation and never closes supervisor authority.
    func prepareGuardedPreExecutor(
        allowRootOwnedCurrentProcessForTesting: Bool
    ) throws
        -> PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
    {
        let retainedState: PrimeValidationSwiftPMRetainedAdmissionState
        preparationLock.lock()
        switch state {
        case let .available(value):
            retainedState = value
            state = .consumed
        case .consumed:
            preparationLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .prerequisiteAlreadyConsumed
        }
        preparationLock.unlock()

        try retainedState.revalidate()
        let expectedPrimeWatcherCount =
            PrimeSecureHeldSourceWatch.expectedWatcherDescriptorCount(
                sourceSnapshot: retainedState.sourceSnapshot
            )
        let expectedCompanionWatcherCount =
            PrimeSecureHeldSourceWatch.expectedWatcherDescriptorCount(
                completeWorkingTreeSnapshot:
                    retainedState.companionContentSnapshot
            )
        let expectedCombinedWatcherCount = expectedPrimeWatcherCount
            .addingReportingOverflow(expectedCompanionWatcherCount)
        guard !expectedCombinedWatcherCount.overflow,
              expectedCombinedWatcherCount.partialValue
                <= PrimeValidationSwiftPMRetainedGuardedPreExecutorState
                .maximumCombinedSourceWatcherDescriptorCount
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("combined_source_watcher_count")
        }
        let sourceRootDescriptor =
            try retainedState.primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { _ = Darwin.close(sourceRootDescriptor) }
        let sourceWatch: PrimeSecureHeldSourceWatch
        sourceWatch = try PrimeSecureHeldSourceWatch(
            rootDescriptor: sourceRootDescriptor,
            sourceSnapshot: retainedState.sourceSnapshot,
            admissionIdentitySnapshot:
                retainedState.primeSourceIdentitySnapshot
        )

        let companionRootDescriptor =
            try retainedState.companionRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { _ = Darwin.close(companionRootDescriptor) }
        let companionSourceWatch = try PrimeSecureHeldSourceWatch(
            rootDescriptor: companionRootDescriptor,
            completeWorkingTreeSnapshot:
                retainedState.companionContentSnapshot
        )
        let combinedWatcherCount =
            sourceWatch.heldWatcherDescriptorCount
            + companionSourceWatch.heldWatcherDescriptorCount
        guard combinedWatcherCount
                == expectedCombinedWatcherCount.partialValue
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("combined_source_watcher_count")
        }

        let currentProcessImage:
            PrimeSecureHeldRunningExecutable
        if allowRootOwnedCurrentProcessForTesting {
            currentProcessImage =
                try PrimeSecureRunningExecutableCapture
                .heldExecutableAllowingRootOwnerForTesting()
        } else {
            currentProcessImage =
                try PrimeSecureRunningExecutableCapture
                .heldExecutable()
        }
        let guardedState =
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState(
                admission: retainedState,
                sourceWatch: sourceWatch,
                companionSourceWatch:
                    companionSourceWatch,
                currentProcessImage: currentProcessImage,
                productionSupervisorImageEligible:
                    !allowRootOwnedCurrentProcessForTesting
            )
        try guardedState.revalidate()
        return
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor(
                retainedState: guardedState
            )
    }
}

/// Live input guards for a future fixed-role executor.
///
/// This type closes only the descriptor-backed Prime and companion content
/// closures and their continuous prepared-state watch windows. It also retains the exact current
/// holder-process image as prerequisite evidence, but does not claim that the
/// image is the Driver V2 supervisor; that role requires the separate
/// DriverCore intent bridge. This type deliberately exposes no process,
/// staging, build, inventory, shard, receipt-publication, or completion
/// operation.
public final class PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor:
    @unchecked Sendable
{
    private enum State {
        case prepared(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        )
        case transferred
        case poisoned
    }

    public let primeRepository:
        PrimeValidationSwiftPMDirectoryObservation
    public let workspaceRoot:
        PrimeValidationSwiftPMDirectoryObservation
    public let evidenceRoot:
        PrimeValidationSwiftPMDirectoryObservation
    public let companionRepository:
        PrimeValidationSwiftPMDirectoryObservation
    public let sourceIdentitySHA256: String
    public let packageResolvedBinding: PrimeArtifactBinding
    public let companionDeclaration:
        PrimeValidationSwiftPMCompanionDeclaration
    public let toolchain:
        PrimeValidationSwiftPMToolchainObservation
    public let currentProcessExecutable:
        PrimeValidationSwiftPMFileObservation
    public let processExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let buildExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let inventoryExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let artifactStagingObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let shardCompletionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    public let completionAuthorized = false

    private let guardLock = NSLock()
    private var state: State

    public var guardState: PrimeValidationSwiftPMGuardState {
        guardLock.lock()
        defer { guardLock.unlock() }
        switch state {
        case .prepared:
            return .prepared
        case .transferred:
            return .transferred
        case .poisoned:
            return .poisoned
        }
    }

    public var authorityCeiling:
        PrimeValidationSwiftPMAuthorityCeiling
    {
        guardLock.lock()
        defer { guardLock.unlock() }
        switch state {
        case .prepared:
            return .sourceGuardsPreparedOnly
        case .transferred:
            return .transferredNoAuthority
        case .poisoned:
            return .poisonedNoAuthority
        }
    }

    public var sourceDescriptorClosureHeld: Bool {
        guardState == .prepared
    }

    public var sourceWatchWindowArmed: Bool {
        guardState == .prepared
    }

    public var companionSourceDescriptorClosureHeld: Bool {
        guardState == .prepared
    }

    public var companionSourceWatchWindowArmed: Bool {
        guardState == .prepared
    }

    var combinedSourceWatcherDescriptorCount: Int {
        guardLock.lock()
        defer { guardLock.unlock() }
        guard case let .prepared(value) = state
        else { return 0 }
        return value.combinedSourceWatcherDescriptorCount
    }

    public var currentProcessExecutableImageHeld: Bool {
        guardState == .prepared
    }

    public var missingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority]
    {
        guardLock.lock()
        defer { guardLock.unlock() }
        guard case .prepared = state else {
            return PrimeValidationSwiftPMMissingAuthority.allCases
        }
        let closed: Set<PrimeValidationSwiftPMMissingAuthority> = [
            .descriptorBackedSourceClosureAndMutationGuard,
            .sourceWatchWindow,
        ]
        return PrimeValidationSwiftPMMissingAuthority.allCases.filter {
            !closed.contains($0)
        }
    }

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) {
        state = .prepared(retainedState)
        let admission = retainedState.admission
        primeRepository = admission.primeRepository.observation
        workspaceRoot = admission.workspaceRoot.observation
        evidenceRoot = admission.evidenceRoot.observation
        companionRepository = admission.companionRepository.observation
        sourceIdentitySHA256 =
            admission.sourceSnapshot.sourceIdentitySHA256
        packageResolvedBinding = admission.packageResolvedBinding
        companionDeclaration = admission.companionDeclaration
        toolchain = admission.toolchain.observation
        currentProcessExecutable =
            retainedState.currentProcessObservation
    }

    /// Revalidates the still-live guard window without executing a process or
    /// minting a durable receipt. Any failed checkpoint permanently poisons
    /// this capability.
    public func revalidateGuards() throws {
        guardLock.lock()
        defer { guardLock.unlock() }
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        switch state {
        case let .prepared(value):
            retainedState = value
        case .transferred:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        do {
            try retainedState.revalidate()
        } catch {
            state = .poisoned
            throw error
        }
    }

    /// Consumes the prepared source/image token into the exact dedicated
    /// Driver V2 supervisor-image proof. This transition launches nothing.
    /// Any rejection after consumption begins permanently poisons this token.
    public func bindDriverV2SupervisorImage(
        expecting expectation:
            PrimeValidationSwiftPMDriverV2ExecutableExpectation
    ) throws
        -> PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    {
        try bindDriverV2SupervisorImage(
            expecting: expectation,
            permitsNonSupervisorTestHost: false
        )
    }

    /// Internal XCTest seam. It exercises the exact-match, one-shot, poison,
    /// and retained-guard mechanics without allowing Apple's `xctest` image to
    /// become production Driver V2 supervisor authority.
    func bindDriverV2SupervisorImageAllowingTestHost(
        expecting expectation:
            PrimeValidationSwiftPMDriverV2ExecutableExpectation
    ) throws
        -> PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    {
        try bindDriverV2SupervisorImage(
            expecting: expectation,
            permitsNonSupervisorTestHost: true
        )
    }

    private func bindDriverV2SupervisorImage(
        expecting expectation:
            PrimeValidationSwiftPMDriverV2ExecutableExpectation,
        permitsNonSupervisorTestHost: Bool
    ) throws
        -> PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    {
        guardLock.lock()
        defer { guardLock.unlock() }
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        switch state {
        case let .prepared(value):
            retainedState = value
        case .transferred:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }

        do {
            try expectation.validate()
            try retainedState.revalidate()
            let image = retainedState.currentProcessImage
            guard expectation.canonicalAbsolutePath
                    == image.canonicalAbsolutePath,
                  expectation.byteCount == image.byteCount,
                  expectation.sha256
                    == PrimeSHA256.hexDigest(of: image.data),
                  image.deviceID == image.loadedImageDeviceID,
                  image.inode == image.loadedImageInode
            else {
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected("driver_v2_supervisor_image_binding")
            }
            if !permitsNonSupervisorTestHost {
                guard retainedState.productionSupervisorImageEligible,
                      URL(
                          fileURLWithPath: image.canonicalAbsolutePath
                      ).lastPathComponent
                        == PrimeValidationSwiftPMDriverV2SupervisorRole
                        .executableLeafName
                else {
                    throw
                        PrimeValidationSwiftPMBuildInventoryAdmissionError
                        .rejected("driver_v2_supervisor_executable_role")
                }
            }
            try retainedState.revalidate()
        } catch {
            state = .poisoned
            throw error
        }

        state = .transferred
        return PrimeValidationSwiftPMDriverV2SupervisorImageCapability(
            retainedState: retainedState,
            expectation: expectation,
            productionSupervisorImageEligible:
                !permitsNonSupervisorTestHost
        )
    }
}

private enum PrimeValidationSwiftPMDriverV2SupervisorRole {
    static let executableLeafName =
        "PrimeValidationWorkflowDriverV2Supervisor"
}

/// Opaque, non-restorable proof that a single guarded transition matched the
/// exact current image declaration. The retained descriptor, source watch,
/// and exclusive lease remain live behind this object.
///
/// This type has no public initializer, no Codable conformance, and no child,
/// process, staging, build, inventory, shard, receipt, or completion method.
public final class PrimeValidationSwiftPMDriverV2SupervisorImageCapability:
    @unchecked Sendable
{
    private enum State {
        case live(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        )
        case transferred
        case poisoned
    }

    public let observation:
        PrimeValidationSwiftPMDriverV2SupervisorImageObservation
    public let productionSupervisorImageEligible: Bool

    private let expectation:
        PrimeValidationSwiftPMDriverV2ExecutableExpectation
    private let stateLock = NSLock()
    private var state: State

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        expectation:
            PrimeValidationSwiftPMDriverV2ExecutableExpectation,
        productionSupervisorImageEligible: Bool
    ) {
        state = .live(retainedState)
        self.expectation = expectation
        self.productionSupervisorImageEligible =
            productionSupervisorImageEligible
        let image = retainedState.currentProcessImage
        observation =
            PrimeValidationSwiftPMDriverV2SupervisorImageObservation(
                canonicalAbsolutePath: image.canonicalAbsolutePath,
                deviceID: image.deviceID,
                inode: image.inode,
                loadedImageDeviceID: image.loadedImageDeviceID,
                loadedImageInode: image.loadedImageInode,
                ownerUserID: image.ownerUserID,
                ownerGroupID: image.ownerGroupID,
                permissionMode: image.permissionMode,
                linkCount: image.linkCount,
                byteCount: image.byteCount,
                sha256: PrimeSHA256.hexDigest(of: image.data),
                modificationSeconds: image.modificationSeconds,
                modificationNanoseconds: image.modificationNanoseconds,
                statusChangeSeconds: image.statusChangeSeconds,
                statusChangeNanoseconds: image.statusChangeNanoseconds
            )
    }

    public var imageState:
        PrimeValidationSwiftPMDriverV2SupervisorImageState
    {
        stateLock.lock()
        defer { stateLock.unlock() }
        switch state {
        case .live:
            return .bound
        case .transferred:
            return .transferred
        case .poisoned:
            return .poisoned
        }
    }

    /// Revalidates the held descriptor, its named path, exact bytes, source
    /// watch, lease, and current loaded vnode. Failure is permanent.
    public func revalidate() throws {
        stateLock.lock()
        defer { stateLock.unlock() }
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        switch state {
        case let .live(value):
            retainedState = value
        case .transferred:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        do {
            try retainedState.revalidate()
            let image = retainedState.currentProcessImage
            guard expectation.canonicalAbsolutePath
                    == image.canonicalAbsolutePath,
                  expectation.byteCount == image.byteCount,
                  expectation.sha256
                    == PrimeSHA256.hexDigest(of: image.data),
                  observation.canonicalAbsolutePath
                    == image.canonicalAbsolutePath,
                  observation.deviceID == image.deviceID,
                  observation.inode == image.inode,
                  observation.loadedImageDeviceID
                    == image.loadedImageDeviceID,
                  observation.loadedImageInode == image.loadedImageInode,
                  observation.byteCount == image.byteCount,
                  observation.sha256
                    == PrimeSHA256.hexDigest(of: image.data),
                  observation.mappedImageJoined
            else {
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected("driver_v2_supervisor_image_revalidation")
            }
            if productionSupervisorImageEligible {
                guard URL(
                    fileURLWithPath: image.canonicalAbsolutePath
                ).lastPathComponent
                    == PrimeValidationSwiftPMDriverV2SupervisorRole
                    .executableLeafName
                else {
                    throw
                        PrimeValidationSwiftPMBuildInventoryAdmissionError
                        .rejected("driver_v2_supervisor_executable_role")
                }
            }
        } catch {
            state = .poisoned
            throw error
        }
    }

    /// DriverCore-only transfer of the already-bound image and every retained
    /// admission resource into the non-executing Gate B role facade. The
    /// semantic context is derived from the validated intent by DriverCore;
    /// PrimeCore admits it against the retained roots before ownership moves.
    @_spi(PrimeValidationDriverV2RoleFacade)
    public func transferDriverV2RoleFacade(
        context: PrimeValidationDriverV2RoleContext
    ) throws -> PrimeValidationDriverV2RoleFacade {
        try transferDriverV2RoleFacade(
            context: context,
            testCanaryExecutableDescriptor: nil,
            testCanaryInterlock: nil
        )
    }

    /// XCTest-only transfer seam. The caller can transfer only an already-
    /// opened canary descriptor; no path, role, argv, environment, cwd,
    /// deadline, stream policy, or callback crosses into production code.
    /// This method is internal, so DriverCore cannot invoke it.
    func transferDriverV2RoleFacadeAllowingTestCanary(
        context: PrimeValidationDriverV2RoleContext,
        heldCanaryExecutableDescriptor: Int32,
        testInterlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock? = nil
    ) throws -> PrimeValidationDriverV2RoleFacade {
        try transferDriverV2RoleFacade(
            context: context,
            testCanaryExecutableDescriptor:
                heldCanaryExecutableDescriptor,
            testCanaryInterlock: testInterlock
        )
    }

    private func transferDriverV2RoleFacade(
        context: PrimeValidationDriverV2RoleContext,
        testCanaryExecutableDescriptor: Int32?,
        testCanaryInterlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock?
    ) throws -> PrimeValidationDriverV2RoleFacade {
        stateLock.lock()
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        switch state {
        case let .live(value):
            retainedState = value
        case .transferred:
            stateLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            stateLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }

        let facade: PrimeValidationDriverV2RoleFacade
        do {
            if testCanaryExecutableDescriptor != nil {
                guard !productionSupervisorImageEligible else {
                    throw
                        PrimeValidationSwiftPMBuildInventoryAdmissionError
                        .rejected(
                            "driver_v2_canary_test_seam_production_image"
                        )
                }
            } else if testCanaryInterlock != nil {
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected(
                        "driver_v2_canary_test_interlock_without_image"
                    )
            }
            try retainedState.revalidate()
            facade = try PrimeValidationDriverV2RoleFacade(
                retainedState: retainedState,
                context: context,
                testCanaryExecutableDescriptor:
                    testCanaryExecutableDescriptor,
                testCanaryInterlock: testCanaryInterlock
            )
            try retainedState.revalidate()
            state = .transferred
        } catch {
            state = .poisoned
            stateLock.unlock()
            throw error
        }
        stateLock.unlock()

        return facade
    }
}

/// A single-use live capability for inputs needed by a future SwiftPM
/// build/inventory executor.
///
/// Admission is deliberately narrower than execution. No child is created,
/// no Git or tool-version command is run, and no build, inventory, PASS,
/// GROUNDED, completion, or Driver V2 receipt authority is issued here.
public final class PrimeValidationSwiftPMBuildInventoryAdmissionCapability:
    @unchecked Sendable
{
    private enum State {
        case available(PrimeValidationSwiftPMRetainedAdmissionState)
        case consumed
    }

    private let stateLock = NSLock()
    private var state: State

    init(
        retainedState: PrimeValidationSwiftPMRetainedAdmissionState
    ) {
        state = .available(retainedState)
    }

    /// Revalidates every held input and atomically transfers the retained
    /// prerequisite state. There is intentionally no executor or command
    /// parameter on this surface.
    public func consumePrerequisites() throws
        -> PrimeValidationSwiftPMBuildInventoryPrerequisite
    {
        let retained: PrimeValidationSwiftPMRetainedAdmissionState
        stateLock.lock()
        switch state {
        case let .available(value):
            retained = value
            state = .consumed
        case .consumed:
            stateLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .capabilityAlreadyConsumed
        }
        stateLock.unlock()

        try retained.revalidate()
        return PrimeValidationSwiftPMBuildInventoryPrerequisite(
            retainedState: retained
        )
    }
}

public enum PrimeValidationSwiftPMBuildInventoryAdmission {
    private static let requiredPrimeSourcePaths: Set<String> = [
        "Sources/PrimeCore/" +
            "PrimeNativeNeuralGateHeldSourceClosure.swift",
        "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
        "Sources/PrimeCore/" +
            "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
        "Sources/PrimeCore/" +
            "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
        "Sources/PrimeCore/" +
            "PrimeValidationDriverV2FixedProbeExecutor.swift",
        "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift",
        "Sources/PrimeCore/" +
            "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
        "Tests/PrimeValidationWorkflow/Sources/" +
            "PrimeValidationWorkflowDriverCore/" +
            "PrimeValidationDriverV2TrackedTreeManifest.swift",
        "Tests/PrimeValidationWorkflow/Sources/" +
            "PrimeValidationWorkflowDriverCore/" +
            "PrimeValidationDriverV2FixedProbeBinding.swift",
        "Package.resolved",
    ]
    private static let leaseLeafName =
        "prime-validation-swiftpm-build-inventory.lock"

    private static func atRejectionSite<Value>(
        _ site:
            PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
        _ operation: () throws -> Value
    ) throws -> Value {
        do {
            return try operation()
        } catch {
            throw site
        }
    }

    /// Admits only live prerequisites. The declared companion state is
    /// checked for exact internal consistency, but remains caller-declared;
    /// the missing process observation is explicit on the returned token.
    public static func admitPrerequisites(
        primeRepositoryURL: URL,
        workspaceRootURL: URL,
        evidenceRootURL: URL,
        leaseDirectoryURL: URL,
        companionRepositoryURL: URL,
        companionDeclaration:
            PrimeValidationSwiftPMCompanionDeclaration,
        developerDirectoryURL: URL
    ) throws
        -> PrimeValidationSwiftPMBuildInventoryAdmissionCapability
    {
        try admitPrerequisites(
            primeRepositoryURL: primeRepositoryURL,
            workspaceRootURL: workspaceRootURL,
            evidenceRootURL: evidenceRootURL,
            leaseDirectoryURL: leaseDirectoryURL,
            companionRepositoryURL: companionRepositoryURL,
            companionDeclaration: companionDeclaration,
            developerDirectoryURL: developerDirectoryURL,
            sourceExpectation: nil
        )
    }

    /// Internal only: permits isolated tests to seal a synthetic complete
    /// source tree without weakening the public embedded-source authority.
    static func admitPrerequisites(
        primeRepositoryURL: URL,
        workspaceRootURL: URL,
        evidenceRootURL: URL,
        leaseDirectoryURL: URL,
        companionRepositoryURL: URL,
        companionDeclaration:
            PrimeValidationSwiftPMCompanionDeclaration,
        developerDirectoryURL: URL,
        sourceExpectation:
            PrimeSwiftSourceProvenanceExpectation?
    ) throws
        -> PrimeValidationSwiftPMBuildInventoryAdmissionCapability
    {
        try atRejectionSite(.companionDeclaration) {
            try validateCompanionDeclaration(companionDeclaration)
        }

        let primeRepository = try atRejectionSite(.primeRepository) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: primeRepositoryURL
            )
        }
        let workspaceRoot = try atRejectionSite(.workspaceRoot) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: workspaceRootURL
            )
        }
        try atRejectionSite(.workspacePrivateAndEmpty) {
            try workspaceRoot.requirePrivateAndEmpty()
        }
        let evidenceRoot = try atRejectionSite(.evidenceRoot) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: evidenceRootURL
            )
        }
        try atRejectionSite(.evidencePrivateAndEmpty) {
            try evidenceRoot.requirePrivateAndEmpty()
        }
        let companionRepository = try atRejectionSite(
            .companionRepository
        ) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: companionRepositoryURL
            )
        }
        let initialLeaseDirectory = try atRejectionSite(
            .leaseDirectory
        ) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: leaseDirectoryURL
            )
        }
        try atRejectionSite(.leasePrivateAndEmpty) {
            try initialLeaseDirectory.requirePrivateAndEmpty()
        }

        try atRejectionSite(.rootTopology) {
            try requireDisjointAndNonNested([
                primeRepository.observation,
                workspaceRoot.observation,
                evidenceRoot.observation,
                companionRepository.observation,
                initialLeaseDirectory.observation,
            ])
        }

        let leaseURL = leaseDirectoryURL.appendingPathComponent(
            leaseLeafName,
            isDirectory: false
        )
        let lease = try atRejectionSite(.exclusiveLease) {
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        }
        let leaseDirectory = try atRejectionSite(
            .postLeaseDirectory
        ) {
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: leaseDirectoryURL
            )
        }

        let sourceSnapshot: PrimeSwiftSourceSnapshot = try atRejectionSite(
            .sourceSnapshot
        ) {
            if let sourceExpectation {
                return try PrimeSwiftSourceProvenance.capture(
                    at: primeRepositoryURL,
                    requiredRelativePaths: requiredPrimeSourcePaths,
                    expectation: sourceExpectation
                )
            }
            return try PrimeSwiftSourceProvenance.capture(
                at: primeRepositoryURL,
                requiredRelativePaths: requiredPrimeSourcePaths
            )
        }
        let packageResolvedBinding: PrimeArtifactBinding =
            try atRejectionSite(.packageResolvedBinding) {
                guard let packageResolved =
                        sourceSnapshot.files.first(where: {
                            $0.relativePath == "Package.resolved"
                        }) else {
                    throw rejected("package_resolved_missing")
                }
                let binding = PrimeArtifactBinding(
                    relativePath: packageResolved.relativePath,
                    sha256: packageResolved.sha256,
                    byteCount: packageResolved.byteCount,
                    purpose: .immutableData
                )
                try binding.validateDeclaration()
                return binding
            }

        let primeSourceIdentitySnapshot:
            PrimeSecureHeldLegacySourceIdentitySnapshot =
                try atRejectionSite(.primeSourceIdentitySnapshot) {
                    let descriptor = try primeRepository.root
                        .duplicateTrustedRootDescriptorForInventory()
                    defer { _ = Darwin.close(descriptor) }
                    return try PrimeSecureHeldWorkingTreeSnapshot
                        .captureLegacyPrimeSourceIdentity(
                            rootDescriptor: descriptor,
                            sourceSnapshot: sourceSnapshot
                        )
                }

        let companionContentSnapshot:
            PrimeSecureHeldWorkingTreeSnapshot =
                try atRejectionSite(.companionContentSnapshot) {
                    let descriptor = try companionRepository.root
                        .duplicateTrustedRootDescriptorForInventory()
                    defer { _ = Darwin.close(descriptor) }
                    return try PrimeSecureHeldWorkingTreeSnapshot.capture(
                        rootDescriptor: descriptor
                    )
                }

        let toolchain = try atRejectionSite(.heldToolchain) {
            try PrimeValidationSwiftPMHeldToolchain(
                developerDirectoryURL: developerDirectoryURL,
                workspaceRootPath:
                    workspaceRoot.observation.canonicalAbsolutePath
            )
        }

        let retained = PrimeValidationSwiftPMRetainedAdmissionState(
            primeRepository: primeRepository,
            workspaceRoot: workspaceRoot,
            evidenceRoot: evidenceRoot,
            leaseDirectory: leaseDirectory,
            companionRepository: companionRepository,
            lease: lease,
            sourceExpectation: sourceExpectation,
            sourceSnapshot: sourceSnapshot,
            primeSourceIdentitySnapshot:
                primeSourceIdentitySnapshot,
            companionContentSnapshot:
                companionContentSnapshot,
            packageResolvedBinding: packageResolvedBinding,
            companionDeclaration: companionDeclaration,
            toolchain: toolchain
        )
        return PrimeValidationSwiftPMBuildInventoryAdmissionCapability(
            retainedState: retained
        )
    }

    private static func validateCompanionDeclaration(
        _ declaration: PrimeValidationSwiftPMCompanionDeclaration
    ) throws {
        for commit in [
            declaration.expectedPinnedHEAD,
            declaration.declaredObservedHEAD,
        ] {
            guard commit.utf8.count == 40,
                  commit.utf8.allSatisfy({
                      ($0 >= 48 && $0 <= 57)
                          || ($0 >= 97 && $0 <= 102)
                  }) else {
                throw rejected("companion_head")
            }
        }
        guard declaration.expectedPinnedHEAD
                == declaration.declaredObservedHEAD,
              declaration.declaredPorcelainV2Status.isEmpty,
              declaration.processObservationMissing
        else {
            throw rejected("companion_declaration")
        }
    }

    private static func requireDisjointAndNonNested(
        _ observations:
            [PrimeValidationSwiftPMDirectoryObservation]
    ) throws {
        guard Set(observations.map {
            "\($0.deviceID):\($0.inode)"
        }).count == observations.count else {
            throw rejected("directory_identity_alias")
        }
        for lhs in observations {
            for rhs in observations where lhs != rhs {
                guard !rhs.canonicalAbsolutePath.hasPrefix(
                    lhs.canonicalAbsolutePath + "/"
                ) else {
                    throw rejected("directory_path_overlap")
                }
            }
        }
    }
}

final class PrimeValidationSwiftPMRetainedAdmissionState:
    @unchecked Sendable
{
    let primeRepository: PrimeValidationSwiftPMHeldUserDirectory
    let workspaceRoot: PrimeValidationSwiftPMHeldUserDirectory
    let evidenceRoot: PrimeValidationSwiftPMHeldUserDirectory
    let leaseDirectory: PrimeValidationSwiftPMHeldUserDirectory
    let companionRepository: PrimeValidationSwiftPMHeldUserDirectory
    let lease: PrimeMetalDeviceLease
    let sourceExpectation: PrimeSwiftSourceProvenanceExpectation?
    let sourceSnapshot: PrimeSwiftSourceSnapshot
    let primeSourceIdentitySnapshot:
        PrimeSecureHeldLegacySourceIdentitySnapshot
    let companionContentSnapshot:
        PrimeSecureHeldWorkingTreeSnapshot
    let packageResolvedBinding: PrimeArtifactBinding
    let companionDeclaration: PrimeValidationSwiftPMCompanionDeclaration
    let toolchain: PrimeValidationSwiftPMHeldToolchain

    init(
        primeRepository: PrimeValidationSwiftPMHeldUserDirectory,
        workspaceRoot: PrimeValidationSwiftPMHeldUserDirectory,
        evidenceRoot: PrimeValidationSwiftPMHeldUserDirectory,
        leaseDirectory: PrimeValidationSwiftPMHeldUserDirectory,
        companionRepository: PrimeValidationSwiftPMHeldUserDirectory,
        lease: PrimeMetalDeviceLease,
        sourceExpectation: PrimeSwiftSourceProvenanceExpectation?,
        sourceSnapshot: PrimeSwiftSourceSnapshot,
        primeSourceIdentitySnapshot:
            PrimeSecureHeldLegacySourceIdentitySnapshot,
        companionContentSnapshot:
            PrimeSecureHeldWorkingTreeSnapshot,
        packageResolvedBinding: PrimeArtifactBinding,
        companionDeclaration: PrimeValidationSwiftPMCompanionDeclaration,
        toolchain: PrimeValidationSwiftPMHeldToolchain
    ) {
        self.primeRepository = primeRepository
        self.workspaceRoot = workspaceRoot
        self.evidenceRoot = evidenceRoot
        self.leaseDirectory = leaseDirectory
        self.companionRepository = companionRepository
        self.lease = lease
        self.sourceExpectation = sourceExpectation
        self.sourceSnapshot = sourceSnapshot
        self.primeSourceIdentitySnapshot =
            primeSourceIdentitySnapshot
        self.companionContentSnapshot =
            companionContentSnapshot
        self.packageResolvedBinding = packageResolvedBinding
        self.companionDeclaration = companionDeclaration
        self.toolchain = toolchain
    }

    func revalidate() throws {
        guard lease.isHeld else {
            throw rejected("exclusive_lease_not_held")
        }
        try primeRepository.revalidate()
        try workspaceRoot.revalidate(requirePrivateAndEmpty: true)
        try evidenceRoot.revalidate(requirePrivateAndEmpty: true)
        try leaseDirectory.revalidate()
        try companionRepository.revalidate()
        try toolchain.revalidate()

        let replay: PrimeSwiftSourceSnapshot
        if let sourceExpectation {
            replay = try PrimeSwiftSourceProvenance.capture(
                at: primeRepository.url,
                requiredRelativePaths: [
                    "Sources/PrimeCore/" +
                        "PrimeNativeNeuralGateHeldSourceClosure.swift",
                    "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2FixedProbeExecutor.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2RoleFacade.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2TrackedTreeManifest.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2FixedProbeBinding.swift",
                    "Package.resolved",
                ],
                expectation: sourceExpectation
            )
        } else {
            replay = try PrimeSwiftSourceProvenance.capture(
                at: primeRepository.url,
                requiredRelativePaths: [
                    "Sources/PrimeCore/" +
                        "PrimeNativeNeuralGateHeldSourceClosure.swift",
                    "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2FixedProbeExecutor.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2RoleFacade.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2TrackedTreeManifest.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2FixedProbeBinding.swift",
                    "Package.resolved",
                ]
            )
        }
        guard replay == sourceSnapshot,
              let lock = replay.files.first(where: {
                  $0.relativePath == packageResolvedBinding.relativePath
              }),
              lock.sha256 == packageResolvedBinding.sha256,
              lock.byteCount == packageResolvedBinding.byteCount
        else {
            throw rejected("prime_source_replay")
        }

        let primeRootDescriptor =
            try primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        let primeIdentityReplay:
            PrimeSecureHeldLegacySourceIdentitySnapshot
        do {
            defer { _ = Darwin.close(primeRootDescriptor) }
            primeIdentityReplay = try
                PrimeSecureHeldWorkingTreeSnapshot
                .captureLegacyPrimeSourceIdentity(
                    rootDescriptor: primeRootDescriptor,
                    sourceSnapshot: replay
                )
        }
        guard primeIdentityReplay == primeSourceIdentitySnapshot
        else {
            throw rejected("prime_source_identity_replay")
        }

        let companionRootDescriptor =
            try companionRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        let companionReplay:
            PrimeSecureHeldWorkingTreeSnapshot
        do {
            defer { _ = Darwin.close(companionRootDescriptor) }
            companionReplay = try
                PrimeSecureHeldWorkingTreeSnapshot.capture(
                    rootDescriptor: companionRootDescriptor
                )
        }
        guard companionReplay == companionContentSnapshot
        else {
            throw rejected("companion_content_replay")
        }
    }
}

final class PrimeValidationSwiftPMRetainedGuardedPreExecutorState:
    @unchecked Sendable
{
    static let maximumCombinedSourceWatcherDescriptorCount = 4_096

    let admission: PrimeValidationSwiftPMRetainedAdmissionState
    let sourceWatch: PrimeSecureHeldSourceWatch
    let companionSourceWatch: PrimeSecureHeldSourceWatch
    let currentProcessImage: PrimeSecureHeldRunningExecutable
    let productionSupervisorImageEligible: Bool
    let currentProcessObservation:
        PrimeValidationSwiftPMFileObservation

    init(
        admission: PrimeValidationSwiftPMRetainedAdmissionState,
        sourceWatch: PrimeSecureHeldSourceWatch,
        companionSourceWatch: PrimeSecureHeldSourceWatch,
        currentProcessImage: PrimeSecureHeldRunningExecutable,
        productionSupervisorImageEligible: Bool
    ) {
        self.admission = admission
        self.sourceWatch = sourceWatch
        self.companionSourceWatch =
            companionSourceWatch
        self.currentProcessImage = currentProcessImage
        self.productionSupervisorImageEligible =
            productionSupervisorImageEligible
        currentProcessObservation =
            PrimeValidationSwiftPMFileObservation(
                canonicalAbsolutePath:
                    currentProcessImage.canonicalAbsolutePath,
                deviceID: currentProcessImage.deviceID,
                inode: currentProcessImage.inode,
                ownerUserID: currentProcessImage.ownerUserID,
                ownerGroupID: currentProcessImage.ownerGroupID,
                permissionMode: currentProcessImage.permissionMode,
                linkCount: currentProcessImage.linkCount,
                byteCount: currentProcessImage.byteCount,
                sha256: PrimeSHA256.hexDigest(
                    of: currentProcessImage.data
                ),
                modificationSeconds:
                    currentProcessImage.modificationSeconds,
                modificationNanoseconds:
                    currentProcessImage.modificationNanoseconds,
                statusChangeSeconds:
                    currentProcessImage.statusChangeSeconds,
                statusChangeNanoseconds:
                    currentProcessImage.statusChangeNanoseconds
            )
    }

    var combinedSourceWatcherDescriptorCount: Int {
        sourceWatch.heldWatcherDescriptorCount
            + companionSourceWatch.heldWatcherDescriptorCount
    }

    func revalidate() throws {
        try admission.revalidate()
        _ = try sourceWatch.revalidateWhilePrepared()
        _ = try companionSourceWatch.revalidateWhilePrepared()
        try currentProcessImage.revalidate()
        // Rejoin every admitted input, then poll both continuously armed
        // watches again before returning a non-executing checkpoint.
        try admission.revalidate()
        _ = try sourceWatch.revalidateWhilePrepared()
        _ = try companionSourceWatch.revalidateWhilePrepared()
    }

    /// Polls only the two already-armed Gate C kqueues. This does not reread
    /// bytes, reopen a root, or establish a new baseline.
    func fixedProbeCheckpointNoPendingEvents() throws {
        try sourceWatch.fixedProbeCheckpointNoPendingEvents()
        try companionSourceWatch.fixedProbeCheckpointNoPendingEvents()
    }

    /// Final Gate E continuity accept after the fourth and terminal
    /// byte-authoritative pass. This preserves the transferred live owner but
    /// performs identity-only checks under the original deadline.
    func fixedProbeRevalidateTransferredContinuity() throws {
        try fixedProbeCheckpointNoPendingEvents()
        guard admission.lease.isHeld,
              combinedSourceWatcherDescriptorCount == 2_203
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("fixed probe transferred continuity")
        }
        try admission.primeRepository.revalidate()
        try admission.companionRepository.revalidate()
        try admission.workspaceRoot.revalidate(requirePrivateAndEmpty: true)
        try admission.evidenceRoot.revalidate(requirePrivateAndEmpty: true)
        try admission.leaseDirectory.revalidate()
        try admission.toolchain.fixedProbeRevalidateAdmissionHeldSet()
        try currentProcessImage.revalidateIdentityOnly()
        try fixedProbeCheckpointNoPendingEvents()
    }

    /// Projects Prime descriptor-backed Gate D entries from the existing Gate
    /// C owner. The value contains data only and retains no descriptor.
    func fixedProbePrimeHeldEntries() throws
        -> [PrimeValidationDriverV2TrackedTreeHeldEntry]
    {
        try fixedProbeCheckpointNoPendingEvents()
        let prime = try sourceWatch.fixedProbeHeldEntries()
        try fixedProbeCheckpointNoPendingEvents()
        return prime
    }

    /// Projects companion descriptor-backed Gate D entries from the existing
    /// Gate C owner. The value contains data only and retains no descriptor.
    func fixedProbeCompanionHeldEntries() throws
        -> [PrimeValidationDriverV2TrackedTreeHeldEntry]
    {
        try fixedProbeCheckpointNoPendingEvents()
        let companion = try companionSourceWatch.fixedProbeHeldEntries()
        try fixedProbeCheckpointNoPendingEvents()
        return companion
    }
}

final class PrimeValidationSwiftPMHeldUserDirectory:
    @unchecked Sendable
{
    let url: URL
    let root: PrimeArtifactRoot
    let identity: PrimeArtifactRootIdentity
    let observation: PrimeValidationSwiftPMDirectoryObservation

    init(url: URL) throws {
        root = try PrimeArtifactRoot(directoryURL: url)
        identity = try root.verifiedRootIdentity()
        let canonical = try primeValidationCanonicalPath(url)
        guard canonical == url.path else {
            throw rejected("noncanonical_directory")
        }
        let rebound = try PrimeArtifactRoot(
            directoryURL: URL(fileURLWithPath: canonical)
        )
        let reboundIdentity = try rebound.verifiedRootIdentity()
        guard identity == reboundIdentity else {
            throw rejected("directory_path_identity")
        }
        self.url = URL(fileURLWithPath: canonical, isDirectory: true)
        observation = try primeValidationDirectoryObservation(
            path: canonical,
            identity: identity,
            descriptor: root.duplicateTrustedRootDescriptorForInventory()
        )
    }

    func requirePrivateAndEmpty() throws {
        try root.requirePrivateRootMode()
        try root.requireEmpty()
    }

    func revalidate(
        requirePrivateAndEmpty: Bool = false
    ) throws {
        let current = try root.verifiedRootIdentity()
        guard current == identity else {
            throw rejected("directory_descriptor_changed")
        }
        let currentObservation = try primeValidationDirectoryObservation(
            path: observation.canonicalAbsolutePath,
            identity: current,
            descriptor: root.duplicateTrustedRootDescriptorForInventory()
        )
        guard currentObservation == observation else {
            throw rejected("directory_filesystem_changed")
        }
        guard try primeValidationCanonicalPath(url)
                == observation.canonicalAbsolutePath else {
            throw rejected("directory_name_changed")
        }
        let rebound = try PrimeArtifactRoot(directoryURL: url)
        guard try rebound.verifiedRootIdentity() == current else {
            throw rejected("directory_rebound")
        }
        if requirePrivateAndEmpty {
            try root.requirePrivateRootMode()
            try root.requireEmpty()
        }
    }
}

final class PrimeValidationSwiftPMHeldToolchain:
    @unchecked Sendable
{
    let developerDirectory: PrimeValidationSwiftPMHeldSystemDirectory
    let toolchainDirectory: PrimeValidationSwiftPMHeldSystemDirectory
    let sdkRoot: PrimeValidationSwiftPMHeldSystemDirectory
    let binaryDirectory: PrimeValidationSwiftPMHeldSystemDirectory
    let xcodeVersionPlist: PrimeValidationSwiftPMHeldSystemFile
    let sdkSettingsPlist: PrimeValidationSwiftPMHeldSystemFile
    let fixedProbeGitExecutable: PrimeValidationSwiftPMHeldSystemFile
    let swiftFrontendExecutable: PrimeValidationSwiftPMHeldSystemFile
    let swiftExecutablePersonality: PrimeValidationSwiftPMHeldPersonality
    let swiftCompilerPersonality: PrimeValidationSwiftPMHeldPersonality
    let swiftPackageExecutable: PrimeValidationSwiftPMHeldSystemFile
    let swiftBuildPersonality: PrimeValidationSwiftPMHeldPersonality
    let swiftTestPersonality: PrimeValidationSwiftPMHeldPersonality
    let observation: PrimeValidationSwiftPMToolchainObservation

    init(
        developerDirectoryURL: URL,
        workspaceRootPath: String
    ) throws {
        guard developerDirectoryURL.lastPathComponent == "Developer",
              developerDirectoryURL.deletingLastPathComponent()
                .lastPathComponent == "Contents",
              developerDirectoryURL.deletingLastPathComponent()
                .deletingLastPathComponent().pathExtension == "app"
        else {
            throw rejected("developer_directory_shape")
        }
        developerDirectory =
            try PrimeValidationSwiftPMHeldSystemDirectory(
                url: developerDirectoryURL
            )
        let toolchainURL = developerDirectoryURL
            .appendingPathComponent(
                "Toolchains/XcodeDefault.xctoolchain",
                isDirectory: true
            )
        toolchainDirectory =
            try PrimeValidationSwiftPMHeldSystemDirectory(
                url: toolchainURL
            )
        let binaryURL = toolchainURL.appendingPathComponent(
            "usr/bin",
            isDirectory: true
        )
        binaryDirectory =
            try PrimeValidationSwiftPMHeldSystemDirectory(url: binaryURL)
        let sdkURL = developerDirectoryURL.appendingPathComponent(
            "Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk",
            isDirectory: true
        )
        sdkRoot = try PrimeValidationSwiftPMHeldSystemDirectory(url: sdkURL)

        xcodeVersionPlist = try PrimeValidationSwiftPMHeldSystemFile(
            url: developerDirectoryURL.deletingLastPathComponent()
                .appendingPathComponent("version.plist"),
            maximumByteCount: 1024 * 1024,
            executableRequired: false
        )
        sdkSettingsPlist = try PrimeValidationSwiftPMHeldSystemFile(
            url: sdkURL.appendingPathComponent("SDKSettings.plist"),
            maximumByteCount: 1024 * 1024,
            executableRequired: false
        )
        fixedProbeGitExecutable = try PrimeValidationSwiftPMHeldSystemFile(
            url: developerDirectoryURL.appendingPathComponent("usr/bin/git"),
            maximumByteCount: 64 * 1024 * 1024,
            executableRequired: true
        )
        swiftFrontendExecutable = try PrimeValidationSwiftPMHeldSystemFile(
            url: binaryURL.appendingPathComponent("swift-frontend"),
            maximumByteCount: 512 * 1024 * 1024,
            executableRequired: true
        )
        swiftExecutablePersonality =
            try PrimeValidationSwiftPMHeldPersonality(
                binaryDirectory: binaryDirectory,
                leaf: "swift",
                expectedTarget: "swift-frontend",
                executablePath:
                    swiftFrontendExecutable.observation.canonicalAbsolutePath
            )
        swiftCompilerPersonality =
            try PrimeValidationSwiftPMHeldPersonality(
                binaryDirectory: binaryDirectory,
                leaf: "swiftc",
                expectedTarget: "swift-frontend",
                executablePath:
                    swiftFrontendExecutable.observation.canonicalAbsolutePath
            )
        swiftPackageExecutable =
            try PrimeValidationSwiftPMHeldSystemFile(
                url: binaryURL.appendingPathComponent("swift-package"),
                maximumByteCount: 64 * 1024 * 1024,
                executableRequired: true
            )
        swiftBuildPersonality =
            try PrimeValidationSwiftPMHeldPersonality(
                binaryDirectory: binaryDirectory,
                leaf: "swift-build",
                expectedTarget: "swift-package",
                executablePath:
                    swiftPackageExecutable.observation.canonicalAbsolutePath
            )
        swiftTestPersonality =
            try PrimeValidationSwiftPMHeldPersonality(
                binaryDirectory: binaryDirectory,
                leaf: "swift-test",
                expectedTarget: "swift-package",
                executablePath:
                    swiftPackageExecutable.observation.canonicalAbsolutePath
            )

        let xcode = try Self.parseXcodeVersion(
            xcodeVersionPlist.data
        )
        let sdkCanonicalName = try Self.parseSDKCanonicalName(
            sdkSettingsPlist.data
        )
        let environment = Self.environment(
            developerDirectory:
                developerDirectory.observation.canonicalAbsolutePath,
            sdkRoot: sdkRoot.observation.canonicalAbsolutePath,
            binaryDirectory:
                binaryDirectory.observation.canonicalAbsolutePath,
            workspaceRootPath: workspaceRootPath
        )
        observation = PrimeValidationSwiftPMToolchainObservation(
            developerDirectory: developerDirectory.observation,
            toolchainDirectory: toolchainDirectory.observation,
            sdkRoot: sdkRoot.observation,
            xcodeVersionPlist: xcodeVersionPlist.observation,
            sdkSettingsPlist: sdkSettingsPlist.observation,
            swiftPackageExecutable: swiftPackageExecutable.observation,
            swiftBuildPersonality: swiftBuildPersonality.observation,
            swiftTestPersonality: swiftTestPersonality.observation,
            xcodeVersion: xcode.version,
            xcodeBuildVersion: xcode.build,
            sdkCanonicalName: sdkCanonicalName,
            orderedDeterministicBaseEnvironment: environment,
            swiftVersionProcessObservationMissing: true,
            swiftTargetInfoProcessObservationMissing: true
        )
        guard fixedProbeGitExecutable.observation.canonicalAbsolutePath
                == developerDirectory.observation.canonicalAbsolutePath
                    + "/usr/bin/git",
              fixedProbeGitExecutable.observation.deviceID
                == developerDirectory.observation.deviceID,
              swiftFrontendExecutable.observation.canonicalAbsolutePath
                == binaryDirectory.observation.canonicalAbsolutePath
                    + "/swift-frontend",
              swiftFrontendExecutable.observation.deviceID
                == developerDirectory.observation.deviceID,
              swiftExecutablePersonality.identity.deviceID
                == binaryDirectory.observation.deviceID,
              swiftCompilerPersonality.identity.deviceID
                == binaryDirectory.observation.deviceID
        else {
            throw rejected("fixed_probe_toolchain_join")
        }
    }

    func revalidate() throws {
        try developerDirectory.revalidate()
        try toolchainDirectory.revalidate()
        try sdkRoot.revalidate()
        try binaryDirectory.revalidate()
        try xcodeVersionPlist.revalidate()
        try sdkSettingsPlist.revalidate()
        try fixedProbeGitExecutable.revalidate()
        try swiftFrontendExecutable.revalidate()
        try swiftExecutablePersonality.revalidate()
        try swiftCompilerPersonality.revalidate()
        try swiftPackageExecutable.revalidate()
        try swiftBuildPersonality.revalidate()
        try swiftTestPersonality.revalidate()
    }

    /// Complete, identity-only Gate E checkpoint for every admission-held
    /// toolchain input. Large file contents remain owned by their original
    /// descriptors and are reread only at the four frozen heavyweight points:
    /// entry, post-Prime join, post-companion join, and terminal.
    func fixedProbeRevalidateAdmissionHeldSet() throws {
        try developerDirectory.revalidate()
        try toolchainDirectory.revalidate()
        try sdkRoot.revalidate()
        try binaryDirectory.revalidate()
        try xcodeVersionPlist.revalidateIdentityOnly()
        try sdkSettingsPlist.revalidateIdentityOnly()
        try fixedProbeGitExecutable.revalidateIdentityOnly()
        try swiftFrontendExecutable.revalidateIdentityOnly()
        try swiftExecutablePersonality.revalidate()
        try swiftCompilerPersonality.revalidate()
        try swiftPackageExecutable.revalidateIdentityOnly()
        try swiftBuildPersonality.revalidate()
        try swiftTestPersonality.revalidate()
    }

    private static func parseXcodeVersion(
        _ data: Data
    ) throws -> (version: String, build: String) {
        guard let value = try PropertyListSerialization
            .propertyList(from: data, options: [], format: nil)
                as? [String: Any],
              let version = value["CFBundleShortVersionString"] as? String,
              let build = value["ProductBuildVersion"] as? String,
              !version.isEmpty,
              !build.isEmpty,
              version.utf8.count <= 64,
              build.utf8.count <= 64,
              version.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57) || $0 == 46
              }),
              build.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 65 && $0 <= 90)
                      || ($0 >= 97 && $0 <= 122)
              })
        else {
            throw rejected("xcode_version_plist")
        }
        return (version, build)
    }

    private static func parseSDKCanonicalName(
        _ data: Data
    ) throws -> String {
        guard let value = try PropertyListSerialization
            .propertyList(from: data, options: [], format: nil)
                as? [String: Any],
              let name = value["CanonicalName"] as? String,
              name.hasPrefix("macosx"),
              name.utf8.count <= 64,
              name.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 122)
                      || $0 == 46
              })
        else {
            throw rejected("sdk_settings_plist")
        }
        return name
    }

    private static func environment(
        developerDirectory: String,
        sdkRoot: String,
        binaryDirectory: String,
        workspaceRootPath: String
    ) -> [PrimeValidationSwiftPMDeterministicEnvironmentEntry] {
        let home = workspaceRootPath + "/home"
        return [
            .init(key: "CFFIXED_USER_HOME", value: home),
            .init(
                key: "CLANG_MODULE_CACHE_PATH",
                value: workspaceRootPath + "/clang-module-cache"
            ),
            .init(key: "DEVELOPER_DIR", value: developerDirectory),
            .init(key: "HOME", value: home),
            .init(key: "LANG", value: "C"),
            .init(key: "LC_ALL", value: "C"),
            .init(
                key: "PATH",
                value: binaryDirectory + ":/usr/bin:/bin"
            ),
            .init(key: "SDKROOT", value: sdkRoot),
            .init(key: "SOURCE_DATE_EPOCH", value: "0"),
            .init(
                key: "SWIFTPM_MODULECACHE_OVERRIDE",
                value: workspaceRootPath + "/swiftpm-module-cache"
            ),
            .init(key: "TERM", value: "dumb"),
            .init(
                key: "TMPDIR",
                value: workspaceRootPath + "/temporary"
            ),
            .init(key: "TZ", value: "UTC"),
        ]
    }
}

final class PrimeValidationSwiftPMHeldSystemDirectory:
    @unchecked Sendable
{
    let descriptor: Int32
    let observation: PrimeValidationSwiftPMDirectoryObservation

    init(url: URL) throws {
        descriptor = Darwin.open(
            url.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw rejected("system_directory_open_\(errno)")
        }
        do {
            let canonical = try primeValidationCanonicalPath(url)
            guard canonical == url.path else {
                throw rejected("noncanonical_system_directory")
            }
            observation = try primeValidationSystemDirectoryObservation(
                path: canonical,
                descriptor: descriptor
            )
            let rebound = Darwin.open(
                canonical,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard rebound >= 0 else {
                throw rejected("system_directory_initial_rebound_open")
            }
            defer { _ = Darwin.close(rebound) }
            guard try primeValidationSystemDirectoryObservation(
                path: canonical,
                descriptor: rebound
            ) == observation else {
                throw rejected("system_directory_initial_rebound")
            }
        } catch {
            _ = Darwin.close(descriptor)
            throw error
        }
    }

    deinit {
        _ = Darwin.close(descriptor)
    }

    func revalidate() throws {
        let current = try primeValidationSystemDirectoryObservation(
            path: observation.canonicalAbsolutePath,
            descriptor: descriptor
        )
        guard current == observation,
              try primeValidationCanonicalPath(
                  URL(
                      fileURLWithPath:
                          observation.canonicalAbsolutePath,
                      isDirectory: true
                  )
              ) == observation.canonicalAbsolutePath
        else {
            throw rejected("system_directory_changed")
        }
        let rebound = Darwin.open(
            observation.canonicalAbsolutePath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw rejected("system_directory_rebound_open")
        }
        defer { _ = Darwin.close(rebound) }
        guard try primeValidationSystemDirectoryObservation(
            path: observation.canonicalAbsolutePath,
            descriptor: rebound
        ) == observation else {
            throw rejected("system_directory_rebound")
        }
    }
}

final class PrimeValidationSwiftPMHeldSystemFile:
    @unchecked Sendable
{
    let descriptor: Int32
    let observation: PrimeValidationSwiftPMFileObservation
    let data: Data
    private let maximumByteCount: UInt64
    private let executableRequired: Bool

    init(
        url: URL,
        maximumByteCount: UInt64,
        executableRequired: Bool
    ) throws {
        descriptor = Darwin.open(
            url.path,
            O_RDONLY | O_NONBLOCK | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw rejected("system_file_open_\(errno)")
        }
        self.maximumByteCount = maximumByteCount
        self.executableRequired = executableRequired
        do {
            let canonical = try primeValidationCanonicalPath(url)
            guard canonical == url.path else {
                throw rejected("noncanonical_system_file")
            }
            let checkpoint = try primeValidationSystemFileCheckpoint(
                path: canonical,
                descriptor: descriptor,
                maximumByteCount: maximumByteCount,
                executableRequired: executableRequired
            )
            observation = checkpoint.observation
            data = checkpoint.data
            try requireNamedPathRebound()
        } catch {
            _ = Darwin.close(descriptor)
            throw error
        }
    }

    deinit {
        _ = Darwin.close(descriptor)
    }

    func revalidate() throws {
        let checkpoint = try primeValidationSystemFileCheckpoint(
            path: observation.canonicalAbsolutePath,
            descriptor: descriptor,
            maximumByteCount: maximumByteCount,
            executableRequired: executableRequired
        )
        guard checkpoint.observation == observation,
              checkpoint.data == data,
              try primeValidationCanonicalPath(
                  URL(fileURLWithPath: observation.canonicalAbsolutePath)
              ) == observation.canonicalAbsolutePath
        else {
            throw rejected("system_file_changed")
        }
        try requireNamedPathRebound()
    }

    /// Gate E's per-child checkpoint retains the admitted file identity
    /// without rereading large executable bytes. The full admission replay
    /// still performs byte equality at the four frozen heavyweight points.
    func revalidateIdentityOnly() throws {
        try requireHeldIdentity(descriptor)
        guard try primeValidationCanonicalPath(
            URL(fileURLWithPath: observation.canonicalAbsolutePath)
        ) == observation.canonicalAbsolutePath else {
            throw rejected("system_file_identity_path")
        }
        let rebound = Darwin.open(
            observation.canonicalAbsolutePath,
            O_RDONLY | O_NONBLOCK | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw rejected("system_file_identity_rebound_open")
        }
        defer { _ = Darwin.close(rebound) }
        try requireHeldIdentity(rebound)
    }

    private func requireHeldIdentity(_ candidate: Int32) throws {
        var metadata = stat()
        guard fstat(candidate, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              UInt64(bitPattern: Int64(metadata.st_dev))
                == observation.deviceID,
              UInt64(metadata.st_ino) == observation.inode,
              metadata.st_uid == observation.ownerUserID,
              metadata.st_gid == observation.ownerGroupID,
              UInt16(metadata.st_mode & mode_t(0o777))
                == observation.permissionMode,
              UInt64(metadata.st_nlink) == observation.linkCount,
              metadata.st_size > 0,
              UInt64(metadata.st_size) == observation.byteCount,
              UInt64(metadata.st_size) <= maximumByteCount,
              Int64(metadata.st_mtimespec.tv_sec)
                == observation.modificationSeconds,
              Int64(metadata.st_mtimespec.tv_nsec)
                == observation.modificationNanoseconds,
              Int64(metadata.st_ctimespec.tv_sec)
                == observation.statusChangeSeconds,
              Int64(metadata.st_ctimespec.tv_nsec)
                == observation.statusChangeNanoseconds,
              metadata.st_mode & mode_t(0o022) == 0,
              metadata.st_mode & mode_t(0o7000) == 0,
              (!executableRequired
                  || metadata.st_mode & mode_t(0o111) != 0),
              fcntl(candidate, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw rejected("system_file_identity_changed")
        }
        try primeValidationRequireNoACLOrUnknownXattrs(candidate)
    }

    private func requireNamedPathRebound() throws {
        let rebound = Darwin.open(
            observation.canonicalAbsolutePath,
            O_RDONLY | O_NONBLOCK | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw rejected("system_file_rebound_open")
        }
        defer { _ = Darwin.close(rebound) }
        let checkpoint = try primeValidationSystemFileCheckpoint(
            path: observation.canonicalAbsolutePath,
            descriptor: rebound,
            maximumByteCount: maximumByteCount,
            executableRequired: executableRequired
        )
        guard checkpoint.observation == observation,
              checkpoint.data == data else {
            throw rejected("system_file_rebound")
        }
    }
}

final class PrimeValidationSwiftPMHeldPersonality:
    @unchecked Sendable
{
    let binaryDirectory: PrimeValidationSwiftPMHeldSystemDirectory
    let leaf: String
    let expectedTarget: String
    let observation: PrimeValidationSwiftPMPersonalityObservation
    let identity:
        PrimeValidationSwiftPMPersonalityIdentity

    init(
        binaryDirectory: PrimeValidationSwiftPMHeldSystemDirectory,
        leaf: String,
        expectedTarget: String,
        executablePath: String
    ) throws {
        self.binaryDirectory = binaryDirectory
        self.leaf = leaf
        self.expectedTarget = expectedTarget
        let checkpoint = try primeValidationPersonalityCheckpoint(
            descriptor: binaryDirectory.descriptor,
            leaf: leaf
        )
        guard checkpoint.target == expectedTarget else {
            throw rejected("personality_target")
        }
        identity = checkpoint.identity
        observation = PrimeValidationSwiftPMPersonalityObservation(
            requestedAbsolutePath:
                binaryDirectory.observation.canonicalAbsolutePath
                    + "/" + leaf,
                symbolicLinkTarget: checkpoint.target,
            canonicalExecutableAbsolutePath: executablePath
        )
    }

    func revalidate() throws {
        let checkpoint = try primeValidationPersonalityCheckpoint(
            descriptor: binaryDirectory.descriptor,
            leaf: leaf
        )
        guard checkpoint.target == expectedTarget,
              checkpoint.identity == identity
        else {
            throw rejected("personality_changed")
        }
    }
}

struct PrimeValidationSwiftPMPersonalityIdentity:
    Equatable,
    Sendable
{
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let mode: UInt32
    let linkCount: UInt64
    let byteCount: Int64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    init(_ value: stat) {
        deviceID = UInt64(bitPattern: Int64(value.st_dev))
        inode = UInt64(value.st_ino)
        ownerUserID = value.st_uid
        ownerGroupID = value.st_gid
        mode = UInt32(value.st_mode)
        linkCount = UInt64(value.st_nlink)
        byteCount = Int64(value.st_size)
        modificationSeconds = Int64(value.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
    }
}

private func primeValidationCanonicalPath(
    _ url: URL
) throws -> String {
    guard url.isFileURL,
          url.path.hasPrefix("/"),
          url.path != "/",
          !url.path.utf8.contains(0)
    else {
        throw rejected("absolute_path")
    }
    var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
    let succeeded = url.path.withCString { input in
        buffer.withUnsafeMutableBufferPointer {
            realpath(input, $0.baseAddress) != nil
        }
    }
    guard succeeded else {
        throw rejected("realpath_\(errno)")
    }
    return buffer.withUnsafeBufferPointer {
        String(cString: $0.baseAddress!)
    }
}

private func primeValidationDirectoryObservation(
    path: String,
    identity: PrimeArtifactRootIdentity,
    descriptor: Int32
) throws -> PrimeValidationSwiftPMDirectoryObservation {
    defer { _ = Darwin.close(descriptor) }
    let filesystem = try primeValidationFilesystemObservation(
        descriptor: descriptor
    )
    guard filesystem.type == "apfs", filesystem.local else {
        throw rejected("non_apfs_directory")
    }
    return PrimeValidationSwiftPMDirectoryObservation(
        canonicalAbsolutePath: path,
        deviceID: identity.deviceID,
        inode: identity.inode,
        ownerUserID: identity.ownerUserID,
        ownerGroupID: identity.ownerGroupID,
        permissionMode: identity.actualMode,
        linkCount: identity.linkCount,
        filesystemType: filesystem.type,
        filesystemIDWord0: filesystem.idWord0,
        filesystemIDWord1: filesystem.idWord1,
        localFilesystemObserved: filesystem.local,
        modificationSeconds: identity.modificationSeconds,
        modificationNanoseconds: identity.modificationNanoseconds,
        statusChangeSeconds: identity.statusChangeSeconds,
        statusChangeNanoseconds: identity.statusChangeNanoseconds
    )
}

private func primeValidationSystemDirectoryObservation(
    path: String,
    descriptor: Int32
) throws -> PrimeValidationSwiftPMDirectoryObservation {
    var metadata = stat()
    guard fstat(descriptor, &metadata) == 0,
          metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
          metadata.st_uid == 0,
          metadata.st_gid == 0,
          metadata.st_mode & mode_t(0o022) == 0,
          metadata.st_mode & mode_t(0o7000) == 0,
          fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
    else {
        throw rejected("system_directory_metadata")
    }
    try primeValidationRequireNoACLOrUnknownXattrs(descriptor)
    let filesystem = try primeValidationFilesystemObservation(
        descriptor: descriptor
    )
    guard filesystem.type == "apfs", filesystem.local else {
        throw rejected("system_directory_filesystem")
    }
    return PrimeValidationSwiftPMDirectoryObservation(
        canonicalAbsolutePath: path,
        deviceID: UInt64(bitPattern: Int64(metadata.st_dev)),
        inode: UInt64(metadata.st_ino),
        ownerUserID: metadata.st_uid,
        ownerGroupID: metadata.st_gid,
        permissionMode: UInt16(metadata.st_mode & mode_t(0o777)),
        linkCount: UInt64(metadata.st_nlink),
        filesystemType: filesystem.type,
        filesystemIDWord0: filesystem.idWord0,
        filesystemIDWord1: filesystem.idWord1,
        localFilesystemObserved: filesystem.local,
        modificationSeconds: Int64(metadata.st_mtimespec.tv_sec),
        modificationNanoseconds: Int64(metadata.st_mtimespec.tv_nsec),
        statusChangeSeconds: Int64(metadata.st_ctimespec.tv_sec),
        statusChangeNanoseconds: Int64(metadata.st_ctimespec.tv_nsec)
    )
}

private func primeValidationSystemFileCheckpoint(
    path: String,
    descriptor: Int32,
    maximumByteCount: UInt64,
    executableRequired: Bool
) throws -> (
    observation: PrimeValidationSwiftPMFileObservation,
    data: Data
) {
    var before = stat()
    guard fstat(descriptor, &before) == 0,
          before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
          before.st_uid == 0,
          before.st_gid == 0,
          before.st_nlink == 1,
          before.st_mode & mode_t(0o022) == 0,
          before.st_mode & mode_t(0o7000) == 0,
          (!executableRequired
              || before.st_mode & mode_t(0o111) != 0),
          before.st_size > 0,
          UInt64(before.st_size) <= maximumByteCount,
          fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
    else {
        throw rejected("system_file_metadata")
    }
    try primeValidationRequireNoACLOrUnknownXattrs(descriptor)
    let data = try PrimeSecureChildPath.readExact(
        descriptor: descriptor,
        byteCount: Int(before.st_size)
    )
    var after = stat()
    guard fstat(descriptor, &after) == 0,
          before.st_dev == after.st_dev,
          before.st_ino == after.st_ino,
          before.st_mode == after.st_mode,
          before.st_uid == after.st_uid,
          before.st_gid == after.st_gid,
          before.st_nlink == after.st_nlink,
          before.st_size == after.st_size,
          before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
          before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
          before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
          before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec
    else {
        throw rejected("system_file_changed_during_read")
    }
    return (
        PrimeValidationSwiftPMFileObservation(
            canonicalAbsolutePath: path,
            deviceID: UInt64(bitPattern: Int64(after.st_dev)),
            inode: UInt64(after.st_ino),
            ownerUserID: after.st_uid,
            ownerGroupID: after.st_gid,
            permissionMode: UInt16(after.st_mode & mode_t(0o777)),
            linkCount: UInt64(after.st_nlink),
            byteCount: UInt64(after.st_size),
            sha256: PrimeSHA256.hexDigest(of: data),
            modificationSeconds: Int64(after.st_mtimespec.tv_sec),
            modificationNanoseconds: Int64(after.st_mtimespec.tv_nsec),
            statusChangeSeconds: Int64(after.st_ctimespec.tv_sec),
            statusChangeNanoseconds: Int64(after.st_ctimespec.tv_nsec)
        ),
        data
    )
}

private func primeValidationPersonalityCheckpoint(
    descriptor: Int32,
    leaf: String
) throws -> (
    target: String,
    identity: PrimeValidationSwiftPMPersonalityIdentity
) {
    var before = stat()
    let status = leaf.withCString {
        fstatat(descriptor, $0, &before, AT_SYMLINK_NOFOLLOW)
    }
    guard status == 0,
          before.st_mode & mode_t(S_IFMT) == mode_t(S_IFLNK),
          before.st_uid == 0,
          before.st_gid == 0,
          before.st_nlink == 1,
          before.st_size > 0,
          before.st_size <= 255
    else {
        throw rejected("personality_metadata")
    }
    var bytes = [CChar](repeating: 0, count: Int(before.st_size) + 1)
    let count = leaf.withCString { name in
        bytes.withUnsafeMutableBufferPointer {
            readlinkat(descriptor, name, $0.baseAddress, $0.count - 1)
        }
    }
    guard count == before.st_size else {
        throw rejected("personality_readlink")
    }
    bytes[Int(count)] = 0
    var after = stat()
    guard leaf.withCString({
        fstatat(descriptor, $0, &after, AT_SYMLINK_NOFOLLOW)
    }) == 0,
    PrimeValidationSwiftPMPersonalityIdentity(before)
        == PrimeValidationSwiftPMPersonalityIdentity(after)
    else {
        throw rejected("personality_changed")
    }
    return (
        String(cString: bytes),
        PrimeValidationSwiftPMPersonalityIdentity(after)
    )
}

private func primeValidationFilesystemObservation(
    descriptor: Int32
) throws -> (
    type: String,
    idWord0: UInt32,
    idWord1: UInt32,
    local: Bool
) {
    var information = statfs()
    guard fstatfs(descriptor, &information) == 0 else {
        throw rejected("filesystem_type")
    }
    let type = withUnsafePointer(to: &information.f_fstypename) {
        $0.withMemoryRebound(to: CChar.self, capacity: 16) {
            String(cString: $0)
        }
    }
    return (
        type,
        UInt32(bitPattern: information.f_fsid.val.0),
        UInt32(bitPattern: information.f_fsid.val.1),
        information.f_flags & UInt32(MNT_LOCAL) != 0
    )
}

private func primeValidationRequireNoACLOrUnknownXattrs(
    _ descriptor: Int32
) throws {
    errno = 0
    if let accessControlList = acl_get_fd_np(
        descriptor,
        ACL_TYPE_EXTENDED
    ) {
        acl_free(UnsafeMutableRawPointer(accessControlList))
        throw rejected("system_input_acl")
    } else if errno != ENOENT && errno != ENOTSUP {
        throw rejected("system_input_acl_read")
    }

    errno = 0
    let size = flistxattr(descriptor, nil, 0, 0)
    guard size >= 0, size <= 65_536 else {
        throw rejected("system_input_xattr_read")
    }
    guard size > 0 else { return }
    var names = [CChar](repeating: 0, count: size)
    let actual = names.withUnsafeMutableBufferPointer {
        flistxattr(descriptor, $0.baseAddress, $0.count, 0)
    }
    guard actual == size else {
        throw rejected("system_input_xattr_changed")
    }
    let bytes = names.prefix(actual).map { UInt8(bitPattern: $0) }
    var start = bytes.startIndex
    var observed = Set<String>()
    for index in bytes.indices where bytes[index] == 0 {
        guard start < index,
              let name = String(
                  bytes: bytes[start ..< index],
                  encoding: .utf8
              ) else {
            throw rejected("system_input_xattr_encoding")
        }
        observed.insert(name)
        start = bytes.index(after: index)
    }
    guard start == bytes.endIndex,
          observed.isSubset(of: ["com.apple.provenance"])
    else {
        throw rejected("system_input_xattr")
    }
}

private func rejected(
    _ detail: String
) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
    .rejected(detail)
}

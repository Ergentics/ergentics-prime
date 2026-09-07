// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// One intent-declared root identity carried across the DriverCore SPI.
/// This value is not authority; transfer succeeds only when every field joins
/// the corresponding descriptor-retained PrimeCore observation.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2RoleRootContext:
    Equatable,
    Sendable
{
    public let absolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let permissionMode: UInt16

    public init(
        absolutePath: String,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        permissionMode: UInt16
    ) {
        self.absolutePath = absolutePath
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.permissionMode = permissionMode
    }

    fileprivate func matches(
        _ observation: PrimeValidationSwiftPMDirectoryObservation
    ) -> Bool {
        absolutePath == observation.canonicalAbsolutePath
            && deviceID == observation.deviceID
            && inode == observation.inode
            && ownerUserID == observation.ownerUserID
            && permissionMode == observation.permissionMode
    }
}

/// DriverCore-only semantic binding for the fixed Driver V2 role facade.
///
/// This SPI carries the exact already-validated intent roots and pinned
/// metallib location. It cannot select a role or supply an executable, argv,
/// environment, cwd, deadline, stream limit, output sink, or callback.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2RoleContext:
    Equatable,
    Sendable
{
    public let repositoryRoot: PrimeValidationDriverV2RoleRootContext
    public let companionRoot: PrimeValidationDriverV2RoleRootContext
    public let workspaceRoot: PrimeValidationDriverV2RoleRootContext
    public let evidenceRoot: PrimeValidationDriverV2RoleRootContext
    public let scratchAbsolutePath: String
    public let cacheAbsolutePath: String
    public let configAbsolutePath: String
    public let securityAbsolutePath: String
    public let clangModuleCacheAbsolutePath: String
    public let outputAbsolutePath: String
    public let homeAbsolutePath: String
    public let swiftPMModuleCacheAbsolutePath: String
    public let temporaryAbsolutePath: String
    public let requiredPinnedMetallibAbsolutePath: String
    public let evidenceRunID: String
    public let requiredPinnedMetallibByteCount: UInt64
    public let requiredPinnedMetallibSHA256: String

    public var repositoryRootAbsolutePath: String {
        repositoryRoot.absolutePath
    }

    public var companionRootAbsolutePath: String {
        companionRoot.absolutePath
    }

    public var workspaceRootAbsolutePath: String {
        workspaceRoot.absolutePath
    }

    public var evidenceRootAbsolutePath: String {
        evidenceRoot.absolutePath
    }

    public init(
        repositoryRoot: PrimeValidationDriverV2RoleRootContext,
        companionRoot: PrimeValidationDriverV2RoleRootContext,
        workspaceRoot: PrimeValidationDriverV2RoleRootContext,
        evidenceRoot: PrimeValidationDriverV2RoleRootContext,
        scratchAbsolutePath: String,
        cacheAbsolutePath: String,
        configAbsolutePath: String,
        securityAbsolutePath: String,
        clangModuleCacheAbsolutePath: String,
        outputAbsolutePath: String,
        homeAbsolutePath: String,
        swiftPMModuleCacheAbsolutePath: String,
        temporaryAbsolutePath: String,
        requiredPinnedMetallibAbsolutePath: String,
        evidenceRunID: String = "",
        requiredPinnedMetallibByteCount: UInt64 = 0,
        requiredPinnedMetallibSHA256: String = ""
    ) {
        self.repositoryRoot = repositoryRoot
        self.companionRoot = companionRoot
        self.workspaceRoot = workspaceRoot
        self.evidenceRoot = evidenceRoot
        self.scratchAbsolutePath = scratchAbsolutePath
        self.cacheAbsolutePath = cacheAbsolutePath
        self.configAbsolutePath = configAbsolutePath
        self.securityAbsolutePath = securityAbsolutePath
        self.clangModuleCacheAbsolutePath = clangModuleCacheAbsolutePath
        self.outputAbsolutePath = outputAbsolutePath
        self.homeAbsolutePath = homeAbsolutePath
        self.swiftPMModuleCacheAbsolutePath = swiftPMModuleCacheAbsolutePath
        self.temporaryAbsolutePath = temporaryAbsolutePath
        self.requiredPinnedMetallibAbsolutePath =
            requiredPinnedMetallibAbsolutePath
        self.evidenceRunID = evidenceRunID
        self.requiredPinnedMetallibByteCount = requiredPinnedMetallibByteCount
        self.requiredPinnedMetallibSHA256 = requiredPinnedMetallibSHA256
    }

    fileprivate func validate(
        against retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws {
        let paths = [
            repositoryRootAbsolutePath,
            companionRootAbsolutePath,
            workspaceRootAbsolutePath,
            evidenceRootAbsolutePath,
            scratchAbsolutePath,
            cacheAbsolutePath,
            configAbsolutePath,
            securityAbsolutePath,
            clangModuleCacheAbsolutePath,
            outputAbsolutePath,
            homeAbsolutePath,
            swiftPMModuleCacheAbsolutePath,
            temporaryAbsolutePath,
            requiredPinnedMetallibAbsolutePath,
        ]
        let derived = [
            scratchAbsolutePath,
            cacheAbsolutePath,
            configAbsolutePath,
            securityAbsolutePath,
            clangModuleCacheAbsolutePath,
            outputAbsolutePath,
            homeAbsolutePath,
            swiftPMModuleCacheAbsolutePath,
            temporaryAbsolutePath,
        ]
        let baseEnvironment = Dictionary(
            uniqueKeysWithValues: retainedState.admission.toolchain.observation
                .orderedDeterministicBaseEnvironment
                .map { ($0.key, $0.value) }
        )
        guard paths.allSatisfy(Self.isSafeAbsolutePath),
              repositoryRootAbsolutePath
                == retainedState.admission.primeRepository.url.path,
              repositoryRoot.matches(
                  retainedState.admission.primeRepository.observation
              ),
              companionRootAbsolutePath
                == retainedState.admission.companionRepository.url.path,
              companionRoot.matches(
                  retainedState.admission.companionRepository.observation
              ),
              workspaceRootAbsolutePath
                == retainedState.admission.workspaceRoot.url.path,
              workspaceRoot.matches(
                  retainedState.admission.workspaceRoot.observation
              ),
              evidenceRootAbsolutePath
                == retainedState.admission.evidenceRoot.url.path,
              evidenceRoot.matches(
                  retainedState.admission.evidenceRoot.observation
              ),
              scratchAbsolutePath
                == workspaceRootAbsolutePath + "/root-release-build",
              cacheAbsolutePath == workspaceRootAbsolutePath + "/cache",
              configAbsolutePath == workspaceRootAbsolutePath + "/config",
              securityAbsolutePath == workspaceRootAbsolutePath + "/security",
              clangModuleCacheAbsolutePath
                == workspaceRootAbsolutePath + "/clang-module-cache",
              outputAbsolutePath == workspaceRootAbsolutePath + "/output",
              homeAbsolutePath == workspaceRootAbsolutePath + "/home",
              swiftPMModuleCacheAbsolutePath
                == workspaceRootAbsolutePath + "/swiftpm-module-cache",
              temporaryAbsolutePath
                == workspaceRootAbsolutePath + "/temporary",
              derived.allSatisfy({
                  $0.hasPrefix(workspaceRootAbsolutePath + "/")
              }),
              Set(derived).count == derived.count,
              requiredPinnedMetallibAbsolutePath
                .hasPrefix(workspaceRootAbsolutePath + "/"),
              requiredPinnedMetallibAbsolutePath
                .hasSuffix("default.metallib"),
              baseEnvironment["HOME"] == homeAbsolutePath,
              baseEnvironment["CFFIXED_USER_HOME"] == homeAbsolutePath,
              baseEnvironment["CLANG_MODULE_CACHE_PATH"]
                == clangModuleCacheAbsolutePath,
              baseEnvironment["SWIFTPM_MODULECACHE_OVERRIDE"]
                == swiftPMModuleCacheAbsolutePath,
              baseEnvironment["TMPDIR"] == temporaryAbsolutePath
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_role_context")
        }
    }

    private static func isSafeAbsolutePath(_ value: String) -> Bool {
        guard value.hasPrefix("/"),
              value != "/",
              value.utf8.count <= 16 * 1024,
              !value.contains("\\"),
              !value.utf8.contains(0),
              value.utf8.allSatisfy({ $0 >= 0x20 && $0 != 0x7f })
        else { return false }
        return value.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).dropFirst().allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }
}

enum PrimeValidationDriverV2FixedRole:
    String,
    Equatable,
    Sendable
{
    case build
    case listXCTest = "list_xctest"
    case listSwiftTesting = "list_swift_testing"
}

enum PrimeValidationDriverV2PrimaryResult:
    String,
    Equatable,
    Sendable
{
    case none
    case standardOutput = "standard_output"
}

enum PrimeValidationDriverV2StandardInputPolicy:
    String,
    Equatable,
    Sendable
{
    case endOfFile = "end_of_file"
}

struct PrimeValidationDriverV2RoleEnvironmentEntry:
    Equatable,
    Sendable
{
    let key: String
    let value: String

    fileprivate init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Non-receipt policy observation for one fixed role. Every field is derived
/// inside PrimeCore from the semantic context and retained toolchain.
struct PrimeValidationDriverV2RolePolicyObservation:
    Equatable,
    Sendable
{
    let role: PrimeValidationDriverV2FixedRole
    let physicalExecutableAbsolutePath: String
    let logicalArgumentZero: String
    let physicalArguments: [String]
    let completeReplacementEnvironment:
        [PrimeValidationDriverV2RoleEnvironmentEntry]
    let completeReplacementEnvironmentKeys: [String]
    let physicalWorkingDirectoryAbsolutePath: String
    let maximumWallNanoseconds: UInt64
    let standardInputPolicy: PrimeValidationDriverV2StandardInputPolicy
    let standardOutputMaximumByteCount: UInt64
    let standardErrorMaximumByteCount: UInt64
    let drainChunkByteCount: Int
    let primaryResult: PrimeValidationDriverV2PrimaryResult

    fileprivate init(
        _ policy: PrimeValidationDriverV2ClosedRolePolicy
    ) {
        role = policy.role
        physicalExecutableAbsolutePath =
            policy.physicalExecutableAbsolutePath
        logicalArgumentZero = policy.logicalArgumentZero
        physicalArguments = policy.physicalArguments
        completeReplacementEnvironment =
            policy.completeReplacementEnvironment.map {
                PrimeValidationDriverV2RoleEnvironmentEntry(
                    key: $0.0,
                    value: $0.1
                )
            }
        completeReplacementEnvironmentKeys =
            policy.completeReplacementEnvironment.map(\.0)
        physicalWorkingDirectoryAbsolutePath =
            policy.physicalWorkingDirectoryAbsolutePath
        maximumWallNanoseconds = policy.maximumWallNanoseconds
        standardInputPolicy = policy.standardInputPolicy
        standardOutputMaximumByteCount =
            policy.standardOutputMaximumByteCount
        standardErrorMaximumByteCount =
            policy.standardErrorMaximumByteCount
        drainChunkByteCount = policy.drainChunkByteCount
        primaryResult = policy.primaryResult
    }
}

/// Opaque, non-restorable ownership of the Gate B fixed-role policy sequence.
///
/// Gate C adds a zero-argument dual-root continuity checkpoint. V2-SPAWN-01
/// adds one zero-argument isolated containment canary without advancing or
/// executing any fixed build/list role. The facade exposes no arbitrary
/// policy, command, path, argv, environment, cwd, deadline, or callback. It
/// remains positioned at build and retains both content watches, the lease,
/// descriptors, and image proof.
enum PrimeValidationDriverV2RoleFacadeContinuityState:
    String,
    Equatable,
    Sendable
{
    case dualRootGuarded = "dual_root_guarded"
    case poisoned
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2RoleFacade:
    @unchecked Sendable
{
    private enum State {
        case guarded(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        )
        case canaryRunning(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        )
        case canaryComplete(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
            PrimeValidationDriverV2IsolatedSpawnCanaryObservation
        )
        case fixedProbesRunning(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        )
        case fixedProbesTransferred
        case poisoned
    }

    private let continuityLock = NSLock()
    private var state: State
    private let context: PrimeValidationDriverV2RoleContext
    private let fixedPolicies:
        [PrimeValidationDriverV2ClosedRolePolicy]
    private var testHeldCanaryExecutable:
        PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable?
    private var testCanaryInterlock:
        PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock?

    let positionedRole:
        PrimeValidationDriverV2FixedRole = .build
    let positionedPolicy:
        PrimeValidationDriverV2RolePolicyObservation
    let fixedPolicyObservations:
        [PrimeValidationDriverV2RolePolicyObservation]
    let processExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    let buildExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    let inventoryExecutionObservation:
        PrimeValidationSwiftPMObservationState = .unobserved
    let completionAuthorized = false

    var continuityState:
        PrimeValidationDriverV2RoleFacadeContinuityState
    {
        continuityLock.lock()
        defer { continuityLock.unlock() }
        switch state {
        case .guarded, .canaryRunning, .canaryComplete,
             .fixedProbesRunning:
            return .dualRootGuarded
        case .fixedProbesTransferred, .poisoned:
            return .poisoned
        }
    }

    var primeSourceDescriptorClosureHeld: Bool {
        continuityState == .dualRootGuarded
    }

    var companionSourceDescriptorClosureHeld: Bool {
        continuityState == .dualRootGuarded
    }

    var primeSourceWatchWindowArmed: Bool {
        continuityState == .dualRootGuarded
    }

    var companionSourceWatchWindowArmed: Bool {
        continuityState == .dualRootGuarded
    }

    var combinedSourceWatcherDescriptorCount: Int {
        continuityLock.lock()
        defer { continuityLock.unlock() }
        switch state {
        case let .guarded(value),
             let .canaryRunning(value),
             let .canaryComplete(value, _),
             let .fixedProbesRunning(value):
            return value.combinedSourceWatcherDescriptorCount
        case .fixedProbesTransferred, .poisoned:
            return 0
        }
    }

    var isolatedSpawnCanaryState:
        PrimeValidationDriverV2IsolatedSpawnCanaryState
    {
        continuityLock.lock()
        defer { continuityLock.unlock() }
        switch state {
        case .guarded:
            return .available
        case .canaryRunning:
            return .running
        case .canaryComplete:
            return .observed
        case .fixedProbesRunning, .fixedProbesTransferred, .poisoned:
            return .poisoned
        }
    }

    var isolatedSpawnCanaryObservation:
        PrimeValidationDriverV2IsolatedSpawnCanaryObservation?
    {
        continuityLock.lock()
        defer { continuityLock.unlock() }
        guard case let .canaryComplete(_, observation) = state
        else { return nil }
        return observation
    }

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        context: PrimeValidationDriverV2RoleContext,
        testCanaryExecutableDescriptor: Int32? = nil,
        testCanaryInterlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock? = nil
    ) throws {
        guard testCanaryExecutableDescriptor == nil
                || !retainedState.productionSupervisorImageEligible,
              testCanaryInterlock == nil
                || testCanaryExecutableDescriptor != nil
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_canary_test_seam")
        }
        try context.validate(against: retainedState)
        let policies = try PrimeValidationDriverV2ClosedRolePolicy
            .fixedSequence(
                context: context,
                toolchain: retainedState.admission.toolchain.observation
            )
        guard policies.map(\.role) == [
            .build,
            .listXCTest,
            .listSwiftTesting,
        ] else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_role_order")
        }
        self.context = context
        fixedPolicies = policies
        fixedPolicyObservations = policies.map(
            PrimeValidationDriverV2RolePolicyObservation.init
        )
        positionedPolicy = PrimeValidationDriverV2RolePolicyObservation(
            policies[0]
        )
        if let testCanaryExecutableDescriptor {
            testHeldCanaryExecutable = try
                PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable(
                    duplicatingTestDescriptor:
                        testCanaryExecutableDescriptor
                )
        } else {
            testHeldCanaryExecutable = nil
        }
        self.testCanaryInterlock = testCanaryInterlock
        state = .guarded(retainedState)
    }

    /// Revalidates the one retained Prime-and-companion continuity owner.
    /// No selector, path, role, command, or observation crosses this seam.
    /// Any failure drops the live resources and permanently poisons retry.
    public func revalidateContinuity() throws {
        continuityLock.lock()
        defer { continuityLock.unlock() }
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        switch state {
        case let .guarded(value),
             let .canaryComplete(value, _):
            retainedState = value
        case .canaryRunning, .fixedProbesRunning,
             .fixedProbesTransferred:
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

    /// Runs exactly one pinned, silent, no-argument containment canary while
    /// both Gate C continuity windows remain armed. This does not advance the
    /// build role or close any process-derived Driver V2 authority.
    @available(macOS 26.0, *)
    public func spawnIsolatedContainmentCanary() throws {
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        let heldCanaryExecutable:
            PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable?
        let canaryInterlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock?
        continuityLock.lock()
        switch state {
        case let .guarded(value):
            retainedState = value
            heldCanaryExecutable = testHeldCanaryExecutable
            canaryInterlock = testCanaryInterlock
            testHeldCanaryExecutable = nil
            testCanaryInterlock = nil
            state = .canaryRunning(value)
        case .canaryRunning, .canaryComplete,
             .fixedProbesRunning, .fixedProbesTransferred:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        continuityLock.unlock()

        do {
            let observation = try
                PrimeValidationDriverV2IsolatedSpawnCanaryExecutor.execute(
                    retainedState: retainedState,
                    testHeldExecutable: heldCanaryExecutable,
                    testInterlock: canaryInterlock
                )
            continuityLock.lock()
            guard case .canaryRunning = state else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .guardedPreExecutorPoisoned
            }
            state = .canaryComplete(retainedState, observation)
            continuityLock.unlock()
        } catch {
            continuityLock.lock()
            state = .poisoned
            continuityLock.unlock()
            throw error
        }
    }

    /// Internal XCTest-only, zero-argument exercise of the exact Gate E
    /// journal owner. It publishes all 34 frozen leaves through production
    /// journal mechanics, creates no child, returns data only, and permanently
    /// consumes the facade whether it succeeds or fails.
    func exerciseFixedProbeJournalMechanicsForTesting() throws
        -> PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation
    {
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        continuityLock.lock()
        switch state {
        case let .guarded(value):
            guard !value.productionSupervisorImageEligible else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected(
                        "driver_v2_fixed_probe_journal_test_production_image"
                    )
            }
            retainedState = value
            state = .fixedProbesRunning(value)
        case .canaryRunning, .canaryComplete,
             .fixedProbesRunning, .fixedProbesTransferred:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        continuityLock.unlock()

        do {
            let observation = try PrimeValidationDriverV2FixedProbeExecutor
                .exerciseJournalMechanicsForTesting(
                    retainedState: retainedState
                )
            continuityLock.lock()
            guard case .fixedProbesRunning = state else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .guardedPreExecutorPoisoned
            }
            state = .poisoned
            continuityLock.unlock()
            return observation
        } catch {
            continuityLock.lock()
            state = .poisoned
            continuityLock.unlock()
            throw error
        }
    }

    /// Internal XCTest-only, zero-argument projection from the one existing
    /// Gate C owner. Success returns the same owner to guarded state; failure
    /// drops it permanently. No held descriptor or live capability escapes.
    func exerciseFixedProbeHeldProjectionForTesting() throws
        -> PrimeValidationDriverV2FixedProbeHeldProjectionTestObservation
    {
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        continuityLock.lock()
        switch state {
        case let .guarded(value):
            guard !value.productionSupervisorImageEligible else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected(
                        "driver_v2_fixed_probe_projection_test_production_image"
                    )
            }
            retainedState = value
            state = .fixedProbesRunning(value)
        case .canaryRunning, .canaryComplete,
             .fixedProbesRunning, .fixedProbesTransferred:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        continuityLock.unlock()

        do {
            let observation = try PrimeValidationDriverV2FixedProbeExecutor
                .exerciseHeldProjectionForTesting(
                    retainedState: retainedState
                )
            continuityLock.lock()
            guard case .fixedProbesRunning = state else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .guardedPreExecutorPoisoned
            }
            state = .guarded(retainedState)
            continuityLock.unlock()
            return observation
        } catch {
            continuityLock.lock()
            state = .poisoned
            continuityLock.unlock()
            throw error
        }
    }

    /// Internal XCTest-only, zero-argument entry to the production-shared
    /// retained half of Gate E's lightweight checkpoint. A successful poll is
    /// repeatable; either root's pending kqueue event permanently poisons.
    func revalidateFixedProbeLightweightContinuityForTesting() throws
        ->
        PrimeValidationDriverV2FixedProbeLightweightCheckpointTestObservation
    {
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        continuityLock.lock()
        switch state {
        case let .guarded(value):
            guard !value.productionSupervisorImageEligible else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected(
                        "driver_v2_fixed_probe_lightweight_test_production_image"
                    )
            }
            retainedState = value
            state = .fixedProbesRunning(value)
        case .canaryRunning, .canaryComplete,
             .fixedProbesRunning, .fixedProbesTransferred:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        continuityLock.unlock()

        do {
            let observation = try PrimeValidationDriverV2FixedProbeExecutor
                .revalidateLightweightContinuityForTesting(
                    retainedState: retainedState
                )
            continuityLock.lock()
            guard case .fixedProbesRunning = state else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .guardedPreExecutorPoisoned
            }
            state = .guarded(retainedState)
            continuityLock.unlock()
            return observation
        } catch {
            continuityLock.lock()
            state = .poisoned
            continuityLock.unlock()
            throw error
        }
    }

    /// Runs the one frozen Gate E sequence and transfers the sole retained
    /// continuity lifetime into a unique descriptor-free raw capability.
    /// The caller supplies no process parameter and the B role table does not
    /// advance.
    @available(macOS 26.0, *)
    public func observeFixedGitAndSwiftProbes() throws
        -> PrimeValidationDriverV2FixedProbeRawCapability
    {
        let retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
        continuityLock.lock()
        switch state {
        case let .guarded(value):
            guard value.productionSupervisorImageEligible else {
                state = .poisoned
                continuityLock.unlock()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected(
                        "driver_v2_fixed_probe_production_image"
                    )
            }
            retainedState = value
            state = .fixedProbesRunning(value)
        case .canaryRunning, .canaryComplete,
             .fixedProbesRunning, .fixedProbesTransferred:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            continuityLock.unlock()
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
        continuityLock.unlock()

        do {
            let result = try PrimeValidationDriverV2FixedProbeExecutor
                .execute(retainedState: retainedState)
            let capability = PrimeValidationDriverV2FixedProbeRawCapability(
                retainedState: retainedState,
                context: context,
                buildPolicy: fixedPolicies[0],
                deadline: result.deadline,
                lastObservedUptimeNanoseconds:
                    result.lastObservedUptimeNanoseconds,
                observation: result.observation
            )
            continuityLock.lock()
            guard case .fixedProbesRunning = state else {
                state = .poisoned
                continuityLock.unlock()
                capability.rejectValidatedBindingLifetime()
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .guardedPreExecutorPoisoned
            }
            state = .fixedProbesTransferred
            continuityLock.unlock()
            return capability
        } catch {
            continuityLock.lock()
            state = .poisoned
            continuityLock.unlock()
            throw error
        }
    }
}

struct PrimeValidationDriverV2ClosedRolePolicy {
    static let streamMaximumByteCount: UInt64 = 16 * 1024 * 1024
    static let chunkByteCount = 64 * 1024

    let role: PrimeValidationDriverV2FixedRole
    let physicalExecutableAbsolutePath: String
    let logicalArgumentZero: String
    let physicalArguments: [String]
    let completeReplacementEnvironment: [(String, String)]
    let physicalWorkingDirectoryAbsolutePath: String
    let maximumWallNanoseconds: UInt64
    let standardInputPolicy: PrimeValidationDriverV2StandardInputPolicy
    let standardOutputMaximumByteCount: UInt64
    let standardErrorMaximumByteCount: UInt64
    let drainChunkByteCount: Int
    let primaryResult: PrimeValidationDriverV2PrimaryResult

    static func fixedSequence(
        context: PrimeValidationDriverV2RoleContext,
        toolchain: PrimeValidationSwiftPMToolchainObservation
    ) throws -> [Self] {
        try [
            make(role: .build, context: context, toolchain: toolchain),
            make(role: .listXCTest, context: context, toolchain: toolchain),
            make(role: .listSwiftTesting, context: context, toolchain: toolchain),
        ]
    }

    private static func make(
        role: PrimeValidationDriverV2FixedRole,
        context: PrimeValidationDriverV2RoleContext,
        toolchain: PrimeValidationSwiftPMToolchainObservation
    ) throws -> Self {
        let argumentZero: String
        let suffix: [String]
        let maximumWallNanoseconds: UInt64
        let primaryResult: PrimeValidationDriverV2PrimaryResult
        switch role {
        case .build:
            argumentZero = "swift-build"
            suffix = [
                "--configuration", "release",
                "--build-tests",
                "--force-resolved-versions",
                "--jobs", "2",
                "--disable-build-manifest-caching",
                "-Xswiftc", "-num-threads", "-Xswiftc", "2",
            ]
            maximumWallNanoseconds = 900 * 1_000_000_000
            primaryResult = .none
        case .listXCTest:
            argumentZero = "swift-test"
            suffix = [
                "--configuration", "release",
                "--skip-build",
                "--force-resolved-versions",
                "--disable-swift-testing", "list",
            ]
            maximumWallNanoseconds = 300 * 1_000_000_000
            primaryResult = .standardOutput
        case .listSwiftTesting:
            argumentZero = "swift-test"
            suffix = [
                "--configuration", "release",
                "--skip-build",
                "--force-resolved-versions",
                "--disable-xctest", "list",
            ]
            maximumWallNanoseconds = 300 * 1_000_000_000
            primaryResult = .standardOutput
        }
        let arguments = [
            "--package-path", context.repositoryRootAbsolutePath,
            "--scratch-path", context.scratchAbsolutePath,
            "--cache-path", context.cacheAbsolutePath,
            "--config-path", context.configAbsolutePath,
            "--security-path", context.securityAbsolutePath,
        ] + suffix
        let environment = try completeEnvironment(
            context: context,
            toolchain: toolchain
        )
        guard arguments.count <= 256,
              arguments.allSatisfy({
                  !$0.isEmpty
                      && $0.utf8.count <= 32 * 1024
                      && $0.utf8.allSatisfy({
                          $0 >= 0x20 && $0 != 0x7f
                      })
              })
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_role_arguments")
        }
        return Self(
            role: role,
            physicalExecutableAbsolutePath:
                toolchain.swiftPackageExecutable.canonicalAbsolutePath,
            logicalArgumentZero: argumentZero,
            physicalArguments: arguments,
            completeReplacementEnvironment: environment,
            physicalWorkingDirectoryAbsolutePath:
                context.repositoryRootAbsolutePath,
            maximumWallNanoseconds: maximumWallNanoseconds,
            standardInputPolicy: .endOfFile,
            standardOutputMaximumByteCount: streamMaximumByteCount,
            standardErrorMaximumByteCount: streamMaximumByteCount,
            drainChunkByteCount: chunkByteCount,
            primaryResult: primaryResult
        )
    }

    private static func completeEnvironment(
        context: PrimeValidationDriverV2RoleContext,
        toolchain: PrimeValidationSwiftPMToolchainObservation
    ) throws -> [(String, String)] {
        var byKey: [String: String] = [:]
        for entry in toolchain.orderedDeterministicBaseEnvironment {
            guard byKey.updateValue(entry.value, forKey: entry.key) == nil
            else {
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected("driver_v2_role_environment")
            }
        }
        let overlay: [(String, String)] = [
            ("PRIME_PMHNP_COMPANION_ROOT", context.companionRootAbsolutePath),
            ("PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE", "1"),
            ("PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE", "1"),
            ("PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE", "1"),
            ("PRIME_REQUIRE_V9_PINNED_DONOR_GATE", "1"),
            ("PRIME_TEST_PINNED_MLX_METALLIB",
             context.requiredPinnedMetallibAbsolutePath),
        ]
        for entry in overlay {
            guard byKey.updateValue(entry.1, forKey: entry.0) == nil else {
                throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                    .rejected("driver_v2_role_environment")
            }
        }
        let values = byKey.map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
        guard values.count == 19,
              values.map(\.0) == [
                  "CFFIXED_USER_HOME",
                  "CLANG_MODULE_CACHE_PATH",
                  "DEVELOPER_DIR",
                  "HOME",
                  "LANG",
                  "LC_ALL",
                  "PATH",
                  "PRIME_PMHNP_COMPANION_ROOT",
                  "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE",
                  "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE",
                  "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE",
                  "PRIME_REQUIRE_V9_PINNED_DONOR_GATE",
                  "PRIME_TEST_PINNED_MLX_METALLIB",
                  "SDKROOT",
                  "SOURCE_DATE_EPOCH",
                  "SWIFTPM_MODULECACHE_OVERRIDE",
                  "TERM",
                  "TMPDIR",
                  "TZ",
              ],
              Set(values.map(\.0)).count == values.count,
              values.allSatisfy({
                  !$0.0.isEmpty
                      && !$0.1.utf8.contains(0)
                      && $0.1.utf8.count <= 32 * 1024
                      && $0.1.utf8.allSatisfy({
                          $0 >= 0x20 && $0 != 0x7f
                      })
              })
        else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .rejected("driver_v2_role_environment")
        }
        return values
    }
}

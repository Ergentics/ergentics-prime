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
    public let authorityCeiling:
        PrimeValidationSwiftPMAuthorityCeiling =
            .retainedInputsOnlyNoPreparedExecutor
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
    let retainedState: PrimeValidationSwiftPMRetainedAdmissionState

    init(
        retainedState: PrimeValidationSwiftPMRetainedAdmissionState
    ) {
        self.retainedState = retainedState
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
            "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
        "Package.resolved",
    ]
    private static let leaseLeafName =
        "prime-validation-swiftpm-build-inventory.lock"

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
        try validateCompanionDeclaration(companionDeclaration)

        let primeRepository = try PrimeValidationSwiftPMHeldUserDirectory(
            url: primeRepositoryURL
        )
        let workspaceRoot = try PrimeValidationSwiftPMHeldUserDirectory(
            url: workspaceRootURL
        )
        try workspaceRoot.requirePrivateAndEmpty()
        let evidenceRoot = try PrimeValidationSwiftPMHeldUserDirectory(
            url: evidenceRootURL
        )
        try evidenceRoot.requirePrivateAndEmpty()
        let companionRepository =
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: companionRepositoryURL
            )
        let initialLeaseDirectory =
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: leaseDirectoryURL
            )
        try initialLeaseDirectory.requirePrivateAndEmpty()

        try requireDisjointAndNonNested([
            primeRepository.observation,
            workspaceRoot.observation,
            evidenceRoot.observation,
            companionRepository.observation,
            initialLeaseDirectory.observation,
        ])

        let leaseURL = leaseDirectoryURL.appendingPathComponent(
            leaseLeafName,
            isDirectory: false
        )
        let lease = try PrimeMetalDeviceLease.acquire(at: leaseURL)
        let leaseDirectory =
            try PrimeValidationSwiftPMHeldUserDirectory(
                url: leaseDirectoryURL
            )

        let sourceSnapshot: PrimeSwiftSourceSnapshot
        if let sourceExpectation {
            sourceSnapshot = try PrimeSwiftSourceProvenance.capture(
                at: primeRepositoryURL,
                requiredRelativePaths: requiredPrimeSourcePaths,
                expectation: sourceExpectation
            )
        } else {
            sourceSnapshot = try PrimeSwiftSourceProvenance.capture(
                at: primeRepositoryURL,
                requiredRelativePaths: requiredPrimeSourcePaths
            )
        }
        guard let packageResolved = sourceSnapshot.files.first(where: {
            $0.relativePath == "Package.resolved"
        }) else {
            throw rejected("package_resolved_missing")
        }
        let packageResolvedBinding = PrimeArtifactBinding(
            relativePath: packageResolved.relativePath,
            sha256: packageResolved.sha256,
            byteCount: packageResolved.byteCount,
            purpose: .immutableData
        )
        try packageResolvedBinding.validateDeclaration()

        let toolchain = try PrimeValidationSwiftPMHeldToolchain(
            developerDirectoryURL: developerDirectoryURL,
            workspaceRootPath:
                workspaceRoot.observation.canonicalAbsolutePath
        )

        let retained = PrimeValidationSwiftPMRetainedAdmissionState(
            primeRepository: primeRepository,
            workspaceRoot: workspaceRoot,
            evidenceRoot: evidenceRoot,
            leaseDirectory: leaseDirectory,
            companionRepository: companionRepository,
            lease: lease,
            sourceExpectation: sourceExpectation,
            sourceSnapshot: sourceSnapshot,
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
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Package.resolved",
                ],
                expectation: sourceExpectation
            )
        } else {
            replay = try PrimeSwiftSourceProvenance.capture(
                at: primeRepository.url,
                requiredRelativePaths: [
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
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
    }

    func revalidate() throws {
        try developerDirectory.revalidate()
        try toolchainDirectory.revalidate()
        try sdkRoot.revalidate()
        try binaryDirectory.revalidate()
        try xcodeVersionPlist.revalidate()
        try sdkSettingsPlist.revalidate()
        try swiftPackageExecutable.revalidate()
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

    init(
        binaryDirectory: PrimeValidationSwiftPMHeldSystemDirectory,
        leaf: String,
        expectedTarget: String,
        executablePath: String
    ) throws {
        self.binaryDirectory = binaryDirectory
        self.leaf = leaf
        self.expectedTarget = expectedTarget
        let target = try primeValidationReadPersonalityTarget(
            descriptor: binaryDirectory.descriptor,
            leaf: leaf
        )
        guard target == expectedTarget else {
            throw rejected("personality_target")
        }
        observation = PrimeValidationSwiftPMPersonalityObservation(
            requestedAbsolutePath:
                binaryDirectory.observation.canonicalAbsolutePath
                    + "/" + leaf,
            symbolicLinkTarget: target,
            canonicalExecutableAbsolutePath: executablePath
        )
    }

    func revalidate() throws {
        guard try primeValidationReadPersonalityTarget(
            descriptor: binaryDirectory.descriptor,
            leaf: leaf
        ) == expectedTarget else {
            throw rejected("personality_changed")
        }
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

private func primeValidationReadPersonalityTarget(
    descriptor: Int32,
    leaf: String
) throws -> String {
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
    before.st_dev == after.st_dev,
    before.st_ino == after.st_ino,
    before.st_size == after.st_size,
    before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
    before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
    before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
    before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec
    else {
        throw rejected("personality_changed")
    }
    return String(cString: bytes)
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

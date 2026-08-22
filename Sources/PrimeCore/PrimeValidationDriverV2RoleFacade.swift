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
        requiredPinnedMetallibAbsolutePath: String
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
/// Gate B intentionally exposes no spawn, execute, resume, collect, advance,
/// next-role, or arbitrary policy method. The facade is positioned at build
/// and retains the source watch, lease, descriptors, and supervisor-image
/// proof for Gate C's separately authorized continuity transition.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2RoleFacade:
    @unchecked Sendable
{
    private let retainedState:
        PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    private let context: PrimeValidationDriverV2RoleContext
    private let fixedPolicies:
        [PrimeValidationDriverV2ClosedRolePolicy]

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

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        context: PrimeValidationDriverV2RoleContext
    ) throws {
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
        self.retainedState = retainedState
        self.context = context
        fixedPolicies = policies
        fixedPolicyObservations = policies.map(
            PrimeValidationDriverV2RolePolicyObservation.init
        )
        positionedPolicy = PrimeValidationDriverV2RolePolicyObservation(
            policies[0]
        )
    }
}

fileprivate struct PrimeValidationDriverV2ClosedRolePolicy {
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

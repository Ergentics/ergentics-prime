// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

public enum PrimeValidationDriverV2Error:
    Error,
    Equatable,
    Sendable
{
    case authorityViolation
    case invalidRunID(String)
    case invalidSHA256(String)
    case invalidPath(String)
    case invalidBinding(String)
    case invalidBaseline
    case invalidBuildSpecification
    case invalidBudget
    case invalidIntent
    case invalidTree
    case invalidBuildReceipt
    case invalidInventoryReceipt
    case invalidShardPolicy
    case invalidShard(String)
    case invalidExecutionPlan
    case invalidPhaseReceipt
    case invalidShardReceipt
    case invalidAggregate
    case invalidComparison
    case invalidFinalReceipt
}

enum PrimeValidationDriverV2Validation {
    static let genesisSHA256 = String(repeating: "0", count: 64)

    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    static func requireSHA256(_ value: String) throws {
        guard isSHA256(value) else {
            throw PrimeValidationDriverV2Error.invalidSHA256(value)
        }
    }

    static func isRunID(_ value: String) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 128
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || $0 == 45 || $0 == 95
            }
    }

    static func requireRunID(_ value: String) throws {
        guard isRunID(value) else {
            throw PrimeValidationDriverV2Error.invalidRunID(value)
        }
    }

    static func isSafeRelativePath(_ value: String) -> Bool {
        guard !value.isEmpty,
              value != ".",
              !value.hasPrefix("/"),
              !value.contains("\\"),
              value.utf8.count <= 16 * 1024,
              value.utf8.allSatisfy({ $0 >= 0x21 && $0 != 0x7f })
        else { return false }
        return value.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }

    static func requireSafeRelativePath(_ value: String) throws {
        guard isSafeRelativePath(value) else {
            throw PrimeValidationDriverV2Error.invalidPath(value)
        }
    }

    static func isSafeAbsolutePath(_ value: String) -> Bool {
        guard value.hasPrefix("/"),
              value != "/",
              !value.contains("\\"),
              value.utf8.count <= 16 * 1024,
              value.utf8.allSatisfy({ $0 >= 0x20 && $0 != 0x7f })
        else { return false }
        let components = value.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        return components.first?.isEmpty == true
            && components.dropFirst().allSatisfy {
                !$0.isEmpty && $0 != "." && $0 != ".."
            }
    }

    static func requireSafeAbsolutePath(_ value: String) throws {
        guard isSafeAbsolutePath(value) else {
            throw PrimeValidationDriverV2Error.invalidPath(value)
        }
    }

    static func appending(
        _ relativePath: String,
        to absoluteRoot: String
    ) -> String {
        absoluteRoot + "/" + relativePath
    }

    static func isSafeName(_ value: String) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 256
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || $0 == 45 || $0 == 95 || $0 == 46
            }
    }

    static func checkedSum(_ values: [UInt64]) throws -> UInt64 {
        var total: UInt64 = 0
        for value in values {
            let next = total.addingReportingOverflow(value)
            guard !next.overflow else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    "unsigned_integer_overflow"
                )
            }
            total = next.partialValue
        }
        return total
    }

    static func identity<Value: Encodable>(_ value: Value) throws -> String {
        PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(value))
    }
}

/// Closed authority for the additive V2 schema, deterministic planner, and
/// semantic comparison mechanics. Completion and nontrivial resume are
/// fail-closed because no parser/executor evidence authority exists here.
public struct PrimeValidationDriverAuthorityCeilingV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let scope: String
    public let schemaAndPlannerImplemented: Bool
    public let pairedSemanticComparatorImplemented: Bool
    public let processSupervisionImplemented: Bool
    public let buildInventoryExecutionImplemented: Bool
    public let durableResumeExecutionImplemented: Bool
    public let localRepositoryValidationOnly: Bool
    public let ciGateAuthorized: Bool
    public let optimizerGateAuthorized: Bool
    public let neuralGateAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let trainingAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let statement: String

    public static let frozenPlannerV2 = Self(
        schemaVersion: 2,
        scope: "local_repository_validation_schema_planner",
        schemaAndPlannerImplemented: true,
        pairedSemanticComparatorImplemented: true,
        processSupervisionImplemented: false,
        buildInventoryExecutionImplemented: false,
        durableResumeExecutionImplemented: false,
        localRepositoryValidationOnly: true,
        ciGateAuthorized: false,
        optimizerGateAuthorized: false,
        neuralGateAuthorized: false,
        scientificAuthorityAuthorized: false,
        trainingAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        statement:
            "swift_local_repository_validation_v2_schema_deterministic_planner_and_semantic_comparison_mechanics_only_completion_and_nontrivial_resume_fail_closed_no_process_supervision_build_inventory_execution_durable_resume_execution_ci_optimizer_neural_scientific_training_or_product_authority"
    )

    public init(
        schemaVersion: Int,
        scope: String,
        schemaAndPlannerImplemented: Bool,
        pairedSemanticComparatorImplemented: Bool,
        processSupervisionImplemented: Bool,
        buildInventoryExecutionImplemented: Bool,
        durableResumeExecutionImplemented: Bool,
        localRepositoryValidationOnly: Bool,
        ciGateAuthorized: Bool,
        optimizerGateAuthorized: Bool,
        neuralGateAuthorized: Bool,
        scientificAuthorityAuthorized: Bool,
        trainingAuthorityAuthorized: Bool,
        productAuthorityAuthorized: Bool,
        statement: String
    ) {
        self.schemaVersion = schemaVersion
        self.scope = scope
        self.schemaAndPlannerImplemented = schemaAndPlannerImplemented
        self.pairedSemanticComparatorImplemented =
            pairedSemanticComparatorImplemented
        self.processSupervisionImplemented =
            processSupervisionImplemented
        self.buildInventoryExecutionImplemented =
            buildInventoryExecutionImplemented
        self.durableResumeExecutionImplemented =
            durableResumeExecutionImplemented
        self.localRepositoryValidationOnly =
            localRepositoryValidationOnly
        self.ciGateAuthorized = ciGateAuthorized
        self.optimizerGateAuthorized = optimizerGateAuthorized
        self.neuralGateAuthorized = neuralGateAuthorized
        self.scientificAuthorityAuthorized =
            scientificAuthorityAuthorized
        self.trainingAuthorityAuthorized = trainingAuthorityAuthorized
        self.productAuthorityAuthorized = productAuthorityAuthorized
        self.statement = statement
    }

    public func validate() throws {
        guard self == .frozenPlannerV2 else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
    }
}

public struct PrimeValidationDriverArtifactBindingV2:
    Codable,
    Equatable,
    Sendable
{
    public let name: String
    public let relativePath: String
    public let content: PrimeValidationContentBinding

    public init(
        name: String,
        relativePath: String,
        content: PrimeValidationContentBinding
    ) {
        self.name = name
        self.relativePath = relativePath
        self.content = content
    }

    public func validate(permitsEmpty: Bool = false) throws {
        guard PrimeValidationDriverV2Validation.isSafeName(name) else {
            throw PrimeValidationDriverV2Error.invalidBinding(name)
        }
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            relativePath
        )
        try content.validate()
        guard permitsEmpty || content.byteCount > 0 else {
            throw PrimeValidationDriverV2Error.invalidBinding(name)
        }
    }
}

public struct PrimeValidationExecutableBindingV2:
    Codable,
    Equatable,
    Sendable
{
    public let absolutePath: String
    public let content: PrimeValidationContentBinding

    public init(
        absolutePath: String,
        content: PrimeValidationContentBinding
    ) {
        self.absolutePath = absolutePath
        self.content = content
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            absolutePath
        )
        try content.validate()
        guard content.byteCount > 0 else {
            throw PrimeValidationDriverV2Error.invalidBinding(absolutePath)
        }
    }
}

public struct PrimeValidationDirectoryBindingV2:
    Codable,
    Equatable,
    Sendable
{
    public let absolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let mode: UInt16

    public init(
        absolutePath: String,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        mode: UInt16
    ) {
        self.absolutePath = absolutePath
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.mode = mode
    }

    public func validate(requirePrivateMode: Bool) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            absolutePath
        )
        guard deviceID > 0,
              inode > 0,
              ownerUserID > 0,
              mode > 0,
              mode <= 0o777,
              (requirePrivateMode ? mode == 0o700 : mode & 0o022 == 0)
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(absolutePath)
        }
    }
}

public struct PrimeValidationDriverRootLayoutV2:
    Codable,
    Equatable,
    Sendable
{
    public let repositoryRoot: PrimeValidationDirectoryBindingV2
    public let companionRoot: PrimeValidationDirectoryBindingV2
    public let workspaceRoot: PrimeValidationDirectoryBindingV2
    public let evidenceRoot: PrimeValidationDirectoryBindingV2
    public let scratchRelativePath: String
    public let cacheRelativePath: String
    public let configRelativePath: String
    public let securityRelativePath: String
    public let clangModuleCacheRelativePath: String
    public let homeRelativePath: String
    public let swiftPMModuleCacheRelativePath: String
    public let temporaryRelativePath: String
    public let outputRelativePath: String

    public init(
        repositoryRoot: PrimeValidationDirectoryBindingV2,
        companionRoot: PrimeValidationDirectoryBindingV2,
        workspaceRoot: PrimeValidationDirectoryBindingV2,
        evidenceRoot: PrimeValidationDirectoryBindingV2,
        scratchRelativePath: String,
        cacheRelativePath: String,
        configRelativePath: String,
        securityRelativePath: String,
        clangModuleCacheRelativePath: String,
        homeRelativePath: String,
        swiftPMModuleCacheRelativePath: String,
        temporaryRelativePath: String,
        outputRelativePath: String
    ) {
        self.repositoryRoot = repositoryRoot
        self.companionRoot = companionRoot
        self.workspaceRoot = workspaceRoot
        self.evidenceRoot = evidenceRoot
        self.scratchRelativePath = scratchRelativePath
        self.cacheRelativePath = cacheRelativePath
        self.configRelativePath = configRelativePath
        self.securityRelativePath = securityRelativePath
        self.clangModuleCacheRelativePath = clangModuleCacheRelativePath
        self.homeRelativePath = homeRelativePath
        self.swiftPMModuleCacheRelativePath = swiftPMModuleCacheRelativePath
        self.temporaryRelativePath = temporaryRelativePath
        self.outputRelativePath = outputRelativePath
    }

    public func validate() throws {
        try repositoryRoot.validate(requirePrivateMode: false)
        try companionRoot.validate(requirePrivateMode: false)
        try workspaceRoot.validate(requirePrivateMode: true)
        try evidenceRoot.validate(requirePrivateMode: true)
        let roots = [
            repositoryRoot.absolutePath,
            companionRoot.absolutePath,
            workspaceRoot.absolutePath,
            evidenceRoot.absolutePath,
        ]
        let rootIdentities = [
            repositoryRoot,
            companionRoot,
            workspaceRoot,
            evidenceRoot,
        ].map {
            String($0.deviceID) + ":" + String($0.inode)
        }
        guard Set(roots).count == roots.count,
              Set(rootIdentities).count == rootIdentities.count
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        for first in roots {
            for second in roots where first != second {
                guard !second.hasPrefix(first + "/") else {
                    throw PrimeValidationDriverV2Error.invalidIntent
                }
            }
        }
        let relatives = [
            scratchRelativePath,
            cacheRelativePath,
            configRelativePath,
            securityRelativePath,
            clangModuleCacheRelativePath,
            homeRelativePath,
            swiftPMModuleCacheRelativePath,
            temporaryRelativePath,
            outputRelativePath,
        ]
        try relatives.forEach {
            try PrimeValidationDriverV2Validation.requireSafeRelativePath($0)
        }
        guard Set(relatives).count == relatives.count else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        for first in relatives {
            for second in relatives where first != second {
                guard !second.hasPrefix(first + "/") else {
                    throw PrimeValidationDriverV2Error.invalidIntent
                }
            }
        }
    }

    public var scratchAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            scratchRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var cacheAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            cacheRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var configAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            configRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var securityAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            securityRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var clangModuleCacheAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            clangModuleCacheRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var outputAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            outputRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var homeAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            homeRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var swiftPMModuleCacheAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            swiftPMModuleCacheRelativePath,
            to: workspaceRoot.absolutePath
        )
    }

    public var temporaryAbsolutePath: String {
        PrimeValidationDriverV2Validation.appending(
            temporaryRelativePath,
            to: workspaceRoot.absolutePath
        )
    }
}

public struct PrimeValidationEnvironmentPolicyV2:
    Codable,
    Equatable,
    Sendable
{
    public let orderedEntries: [PrimeValidationEnvironmentEntry]

    public init(orderedEntries: [PrimeValidationEnvironmentEntry]) {
        self.orderedEntries = orderedEntries
    }

    public static func make(
        roots: PrimeValidationDriverRootLayoutV2,
        pinnedMetallib: PrimeValidationRequiredMetallibV2
    ) -> Self {
        Self(
            orderedEntries: [
                .init(
                    key: "CFFIXED_USER_HOME",
                    value: roots.homeAbsolutePath
                ),
                .init(
                    key: "CLANG_MODULE_CACHE_PATH",
                    value: roots.clangModuleCacheAbsolutePath
                ),
                .init(
                    key: "HOME",
                    value: roots.homeAbsolutePath
                ),
                .init(
                    key: "PRIME_PMHNP_COMPANION_ROOT",
                    value: roots.companionRoot.absolutePath
                ),
                .init(
                    key: "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE",
                    value: "1"
                ),
                .init(
                    key: "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE",
                    value: "1"
                ),
                .init(
                    key: "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE",
                    value: "1"
                ),
                .init(
                    key: "PRIME_REQUIRE_V9_PINNED_DONOR_GATE",
                    value: "1"
                ),
                .init(
                    key: "PRIME_TEST_PINNED_MLX_METALLIB",
                    value: PrimeValidationDriverV2Validation.appending(
                        pinnedMetallib.relativePath,
                        to: roots.workspaceRoot.absolutePath
                    )
                ),
                .init(
                    key: "SOURCE_DATE_EPOCH",
                    value: "0"
                ),
                .init(
                    key: "SWIFTPM_MODULECACHE_OVERRIDE",
                    value: roots.swiftPMModuleCacheAbsolutePath
                ),
                .init(
                    key: "TMPDIR",
                    value: roots.temporaryAbsolutePath
                ),
                .init(
                    key: "TZ",
                    value: "UTC"
                ),
            ]
        )
    }

    public func validate(
        roots: PrimeValidationDriverRootLayoutV2,
        pinnedMetallib: PrimeValidationRequiredMetallibV2
    ) throws {
        try roots.validate()
        try pinnedMetallib.validate()
        try orderedEntries.forEach { try $0.validate() }
        guard self == Self.make(
            roots: roots,
            pinnedMetallib: pinnedMetallib
        ) else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
    }
}

public enum PrimeValidationBundleTreeNodeKindV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case directory
    case regularFile = "regular_file"
    case executable
}

public struct PrimeValidationBundleTreeEntryV2:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let kind: PrimeValidationBundleTreeNodeKindV2
    public let mode: UInt16
    public let content: PrimeValidationContentBinding?

    public init(
        relativePath: String,
        kind: PrimeValidationBundleTreeNodeKindV2,
        mode: UInt16,
        content: PrimeValidationContentBinding?
    ) {
        self.relativePath = relativePath
        self.kind = kind
        self.mode = mode
        self.content = content
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            relativePath
        )
        guard mode > 0,
              mode <= 0o777,
              mode & 0o022 == 0
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        switch kind {
        case .directory:
            guard content == nil,
                  mode & 0o500 == 0o500
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
        case .regularFile:
            guard let content,
                  content.byteCount > 0,
                  mode & 0o111 == 0
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            try content.validate()
        case .executable:
            guard let content,
                  content.byteCount > 0,
                  mode & 0o100 != 0
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            try content.validate()
        }
    }
}

public struct PrimeValidationBundleTreeBindingV2:
    Codable,
    Equatable,
    Sendable
{
    public let entries: [PrimeValidationBundleTreeEntryV2]
    public let manifestContent: PrimeValidationContentBinding
    public let fileCount: Int
    public let directoryCount: Int
    public let aggregateFileByteCount: UInt64

    public init(
        entries: [PrimeValidationBundleTreeEntryV2],
        manifestContent: PrimeValidationContentBinding,
        fileCount: Int,
        directoryCount: Int,
        aggregateFileByteCount: UInt64
    ) {
        self.entries = entries
        self.manifestContent = manifestContent
        self.fileCount = fileCount
        self.directoryCount = directoryCount
        self.aggregateFileByteCount = aggregateFileByteCount
    }

    public static func make(
        entries: [PrimeValidationBundleTreeEntryV2]
    ) throws -> Self {
        let sorted = entries.sorted { $0.relativePath < $1.relativePath }
        let fileEntries = sorted.filter { $0.kind != .directory }
        let bytes = try PrimeValidationDriverV2Validation.checkedSum(
            fileEntries.compactMap { $0.content?.byteCount }
        )
        return Self(
            entries: sorted,
            manifestContent: .init(
                data: try PrimeCanonicalJSON.encode(sorted)
            ),
            fileCount: fileEntries.count,
            directoryCount: sorted.count - fileEntries.count,
            aggregateFileByteCount: bytes
        )
    }

    public func validate() throws {
        guard !entries.isEmpty,
              entries.count <= 100_000,
              entries == entries.sorted(by: {
                  $0.relativePath < $1.relativePath
              }),
              Set(entries.map(\.relativePath)).count == entries.count,
              fileCount == entries.filter({ $0.kind != .directory }).count,
              directoryCount
                == entries.filter({ $0.kind == .directory }).count,
              entries.contains(where: { $0.kind == .executable })
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        try entries.forEach { try $0.validate() }
        let entriesByPath = Dictionary(
            uniqueKeysWithValues: entries.map {
                ($0.relativePath, $0)
            }
        )
        for entry in entries {
            let components = entry.relativePath.split(separator: "/")
            guard components.count > 1 else { continue }
            let parentPath = components.dropLast().joined(separator: "/")
            guard entriesByPath[parentPath]?.kind == .directory else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
        }
        let expected = try Self.make(entries: entries)
        guard expected.manifestContent == manifestContent,
              expected.fileCount == fileCount,
              expected.directoryCount == directoryCount,
              expected.aggregateFileByteCount == aggregateFileByteCount
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        try manifestContent.validate()
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public struct PrimeValidationBaselineAnchorV2:
    Codable,
    Equatable,
    Sendable
{
    public static let xctestCount = 892
    public static let swiftTestingCount = 12
    public static let xctestListByteCount: UInt64 = 114_186
    public static let xctestListSHA256 =
        "93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b"
    public static let swiftTestingListByteCount: UInt64 = 1_287
    public static let swiftTestingListSHA256 =
        "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3"

    public let expectedXCTestCount: Int
    public let expectedSwiftTestingCount: Int
    public let expectedXCTestListByteCount: UInt64
    public let expectedXCTestListSHA256: String
    public let expectedSwiftTestingListByteCount: UInt64
    public let expectedSwiftTestingListSHA256: String

    public init(
        expectedXCTestCount: Int = Self.xctestCount,
        expectedSwiftTestingCount: Int = Self.swiftTestingCount,
        expectedXCTestListByteCount: UInt64 = Self.xctestListByteCount,
        expectedXCTestListSHA256: String = Self.xctestListSHA256,
        expectedSwiftTestingListByteCount: UInt64 =
            Self.swiftTestingListByteCount,
        expectedSwiftTestingListSHA256: String =
            Self.swiftTestingListSHA256
    ) {
        self.expectedXCTestCount = expectedXCTestCount
        self.expectedSwiftTestingCount = expectedSwiftTestingCount
        self.expectedXCTestListByteCount = expectedXCTestListByteCount
        self.expectedXCTestListSHA256 = expectedXCTestListSHA256
        self.expectedSwiftTestingListByteCount =
            expectedSwiftTestingListByteCount
        self.expectedSwiftTestingListSHA256 = expectedSwiftTestingListSHA256
    }

    /// Explicit opt-in; the historical default and six encoded fields remain
    /// unchanged. This separately resealed pair comes from both native G
    /// captures and their independent raw-record and Swift-parser checks.
    public static var currentSourceInventoryV1: Self {
        let profile = PrimeValidationDriverV2InventoryProfile.currentSourceInventoryV1
        return Self(expectedXCTestCount: profile.expectedXCTestCount,
            expectedSwiftTestingCount: profile.expectedSwiftTestingCount,
            expectedXCTestListByteCount: profile.expectedXCTestListByteCount,
            expectedXCTestListSHA256: profile.expectedXCTestListSHA256,
            expectedSwiftTestingListByteCount: profile.expectedSwiftTestingListByteCount,
            expectedSwiftTestingListSHA256: profile.expectedSwiftTestingListSHA256)
    }

    public func validate() throws {
        guard PrimeValidationDriverV2InventoryProfile.resolve(
            expectedXCTestCount: expectedXCTestCount,
            expectedSwiftTestingCount: expectedSwiftTestingCount,
            expectedXCTestListByteCount: expectedXCTestListByteCount,
            expectedXCTestListSHA256: expectedXCTestListSHA256,
            expectedSwiftTestingListByteCount: expectedSwiftTestingListByteCount,
            expectedSwiftTestingListSHA256: expectedSwiftTestingListSHA256) != nil
        else {
            throw PrimeValidationDriverV2Error.invalidBaseline
        }
        try PrimeValidationDriverV2Validation.requireSHA256(
            expectedXCTestListSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            expectedSwiftTestingListSHA256
        )
    }
}

public struct PrimeValidationBuildSpecificationV2:
    Codable,
    Equatable,
    Sendable
{
    public let configuration: String
    public let buildTests: Bool
    public let forceResolvedVersions: Bool
    public let scratchRelativePath: String

    public static let frozenReleaseV1 = Self(
        configuration: "release",
        buildTests: true,
        forceResolvedVersions: true,
        scratchRelativePath: "root-release-build"
    )

    public init(
        configuration: String,
        buildTests: Bool,
        forceResolvedVersions: Bool,
        scratchRelativePath: String
    ) {
        self.configuration = configuration
        self.buildTests = buildTests
        self.forceResolvedVersions = forceResolvedVersions
        self.scratchRelativePath = scratchRelativePath
    }

    public func validate() throws {
        guard self == .frozenReleaseV1 else {
            throw PrimeValidationDriverV2Error.invalidBuildSpecification
        }
    }
}

public enum PrimeValidationDriverPhaseV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case sourceAdmission = "source_admission"
    case build
    case inventory
    case executionPlan = "execution_plan"
    case referenceExecution = "reference_execution"
    case candidateExecution = "candidate_execution"
    case reconciliation
    case comparison
    case publication
}

public struct PrimeValidationPhaseBudgetV2:
    Codable,
    Equatable,
    Sendable
{
    public let phase: PrimeValidationDriverPhaseV2
    public let maximumActiveNanoseconds: UInt64

    public init(
        phase: PrimeValidationDriverPhaseV2,
        maximumActiveNanoseconds: UInt64
    ) {
        self.phase = phase
        self.maximumActiveNanoseconds = maximumActiveNanoseconds
    }

    public func validate() throws {
        guard maximumActiveNanoseconds > 0,
              maximumActiveNanoseconds <= 24 * 60 * 60 * 1_000_000_000
        else {
            throw PrimeValidationDriverV2Error.invalidBudget
        }
    }
}

public enum PrimeValidationResumePolicyV2:
    String,
    Codable,
    Sendable
{
    case resumeOnlyNeverStartedV1 = "resume_only_never_started_v1"
}

public struct PrimeValidationRequiredMetallibV2:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let content: PrimeValidationContentBinding

    public init(
        relativePath: String,
        content: PrimeValidationContentBinding
    ) {
        self.relativePath = relativePath
        self.content = content
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            relativePath
        )
        guard relativePath.hasSuffix("default.metallib"),
              content.byteCount > 0
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        try content.validate()
    }
}

public struct PrimeValidationRunIntentV2:
    Codable,
    Equatable,
    Sendable
{
    public static let schemaVersion = 2
    public static let artifactKind =
        "ergentics_prime_validation_driver_run_intent_v2"
    public static let requiredCompanionCommit =
        "163fc100710ece48119bc25954452d10f6a84f7f"

    public let schemaVersion: Int
    public let artifactKind: String
    public let runID: String
    public let authority: PrimeValidationDriverAuthorityCeilingV2
    public let roots: PrimeValidationDriverRootLayoutV2
    public let sourceSnapshot: PrimeValidationContentBinding
    public let packageLock: PrimeValidationContentBinding
    public let driverExecutable: PrimeValidationExecutableBindingV2
    public let swiftExecutable: PrimeValidationExecutableBindingV2
    public let companionCommit: String
    public let requiredPinnedMetallib: PrimeValidationRequiredMetallibV2
    public let baseline: PrimeValidationBaselineAnchorV2
    public let build: PrimeValidationBuildSpecificationV2
    public let shardPolicy: PrimeValidationShardPolicyV2
    public let phaseBudgets: [PrimeValidationPhaseBudgetV2]
    public let resumePolicy: PrimeValidationResumePolicyV2
    public let environmentPolicy: PrimeValidationEnvironmentPolicyV2
    public let optionalSkipPolicySHA256: String

    public init(
        runID: String,
        authority: PrimeValidationDriverAuthorityCeilingV2 =
            .frozenPlannerV2,
        roots: PrimeValidationDriverRootLayoutV2,
        sourceSnapshot: PrimeValidationContentBinding,
        packageLock: PrimeValidationContentBinding,
        driverExecutable: PrimeValidationExecutableBindingV2,
        swiftExecutable: PrimeValidationExecutableBindingV2,
        companionCommit: String,
        requiredPinnedMetallib: PrimeValidationRequiredMetallibV2,
        baseline: PrimeValidationBaselineAnchorV2,
        build: PrimeValidationBuildSpecificationV2 = .frozenReleaseV1,
        shardPolicy: PrimeValidationShardPolicyV2 = .frozenRootV1,
        phaseBudgets: [PrimeValidationPhaseBudgetV2],
        resumePolicy: PrimeValidationResumePolicyV2 =
            .resumeOnlyNeverStartedV1,
        environmentPolicy: PrimeValidationEnvironmentPolicyV2,
        optionalSkipPolicySHA256: String
    ) {
        schemaVersion = Self.schemaVersion
        artifactKind = Self.artifactKind
        self.runID = runID
        self.authority = authority
        self.roots = roots
        self.sourceSnapshot = sourceSnapshot
        self.packageLock = packageLock
        self.driverExecutable = driverExecutable
        self.swiftExecutable = swiftExecutable
        self.companionCommit = companionCommit
        self.requiredPinnedMetallib = requiredPinnedMetallib
        self.baseline = baseline
        self.build = build
        self.shardPolicy = shardPolicy
        self.phaseBudgets = phaseBudgets.sorted {
            $0.phase.rawValue < $1.phase.rawValue
        }
        self.resumePolicy = resumePolicy
        self.environmentPolicy = environmentPolicy
        self.optionalSkipPolicySHA256 = optionalSkipPolicySHA256
    }

    public func validate() throws {
        guard schemaVersion == Self.schemaVersion,
              artifactKind == Self.artifactKind
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        try PrimeValidationDriverV2Validation.requireRunID(runID)
        try authority.validate()
        try roots.validate()
        for binding in [
            sourceSnapshot,
            packageLock,
        ] {
            try binding.validate()
            guard binding.byteCount > 0 else {
                throw PrimeValidationDriverV2Error.invalidIntent
            }
        }
        try driverExecutable.validate()
        try swiftExecutable.validate()
        guard companionCommit == Self.requiredCompanionCommit,
              companionCommit.utf8.count == 40,
              companionCommit.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        try requiredPinnedMetallib.validate()
        try baseline.validate()
        try build.validate()
        guard build.scratchRelativePath == roots.scratchRelativePath else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        try shardPolicy.validate()
        guard phaseBudgets.map(\.phase.rawValue)
                == phaseBudgets.map(\.phase.rawValue).sorted(),
              Set(phaseBudgets.map(\.phase)).count == phaseBudgets.count,
              Set(phaseBudgets.map(\.phase))
                == Set(PrimeValidationDriverPhaseV2.allCases),
              resumePolicy == .resumeOnlyNeverStartedV1
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        try phaseBudgets.forEach { try $0.validate() }
        try environmentPolicy.validate(
            roots: roots,
            pinnedMetallib: requiredPinnedMetallib
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            optionalSkipPolicySHA256
        )
        guard optionalSkipPolicySHA256
                == (try PrimeValidationOptionalSkipPolicy.identitySHA256())
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public struct PrimeValidationBuildReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let invocation: PrimeValidationInvocationV2
    public let observedChild: PrimeValidationObservedChildReceiptV2
    public let sourceSnapshotAfterBuild: PrimeValidationContentBinding
    public let packageLockAfterBuild: PrimeValidationContentBinding
    public let pinnedMetallibAfterBuild: PrimeValidationRequiredMetallibV2
    public let testBundle: PrimeValidationBundleTreeBindingV2
    public let activeNanoseconds: UInt64

    public init(
        runID: String,
        intentSHA256: String,
        invocation: PrimeValidationInvocationV2,
        observedChild: PrimeValidationObservedChildReceiptV2,
        sourceSnapshotAfterBuild: PrimeValidationContentBinding,
        packageLockAfterBuild: PrimeValidationContentBinding,
        pinnedMetallibAfterBuild: PrimeValidationRequiredMetallibV2,
        testBundle: PrimeValidationBundleTreeBindingV2,
        activeNanoseconds: UInt64
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.invocation = invocation
        self.observedChild = observedChild
        self.sourceSnapshotAfterBuild = sourceSnapshotAfterBuild
        self.packageLockAfterBuild = packageLockAfterBuild
        self.pinnedMetallibAfterBuild = pinnedMetallibAfterBuild
        self.testBundle = testBundle
        self.activeNanoseconds = activeNanoseconds
    }

    public func validate(against intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        let expectedInvocation = try PrimeValidationInvocationFactoryV2
            .build(intent: intent)
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              invocation == expectedInvocation,
              observedChild.invocation == invocation,
              sourceSnapshotAfterBuild == intent.sourceSnapshot,
              packageLockAfterBuild == intent.packageLock,
              pinnedMetallibAfterBuild == intent.requiredPinnedMetallib,
              observedChild.activeNanoseconds == activeNanoseconds,
              activeNanoseconds > 0,
              activeNanoseconds
                <= intent.phaseBudgets.first(where: {
                    $0.phase == .build
                })!.maximumActiveNanoseconds
        else {
            throw PrimeValidationDriverV2Error.invalidBuildReceipt
        }
        try invocation.validate()
        do {
            try observedChild.validate(
                expectedInvocation: expectedInvocation,
                maximumActiveNanoseconds: intent.phaseBudgets.first(where: {
                    $0.phase == .build
                })!.maximumActiveNanoseconds
            )
            try observedChild.requireCompleteSuccess(
                expectedMatchedTestCount: 0
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidBuildReceipt
        }
        try sourceSnapshotAfterBuild.validate()
        try packageLockAfterBuild.validate()
        try pinnedMetallibAfterBuild.validate()
        try testBundle.validate()
    }

    public func identitySHA256(
        against intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(against: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public struct PrimeValidationInventoryReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let buildReceiptSHA256: String
    public let invocations: [PrimeValidationInvocationV2]
    public let observedChildren: [PrimeValidationObservedChildReceiptV2]
    public let xctestListArtifact: PrimeValidationDriverArtifactBindingV2
    public let swiftTestingListArtifact:
        PrimeValidationDriverArtifactBindingV2
    public let xctestListData: Data
    public let swiftTestingListData: Data
    public let inventory: PrimeValidationInventory
    public let activeNanoseconds: UInt64

    public init(
        runID: String,
        intentSHA256: String,
        buildReceiptSHA256: String,
        invocations: [PrimeValidationInvocationV2],
        observedChildren: [PrimeValidationObservedChildReceiptV2],
        xctestListArtifact: PrimeValidationDriverArtifactBindingV2,
        swiftTestingListArtifact:
            PrimeValidationDriverArtifactBindingV2,
        xctestListData: Data,
        swiftTestingListData: Data,
        inventory: PrimeValidationInventory,
        activeNanoseconds: UInt64
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.buildReceiptSHA256 = buildReceiptSHA256
        self.invocations = invocations
        self.observedChildren = observedChildren
        self.xctestListArtifact = xctestListArtifact
        self.swiftTestingListArtifact = swiftTestingListArtifact
        self.xctestListData = xctestListData
        self.swiftTestingListData = swiftTestingListData
        self.inventory = inventory
        self.activeNanoseconds = activeNanoseconds
    }

    public func validate(
        intent: PrimeValidationRunIntentV2,
        buildReceipt: PrimeValidationBuildReceiptV2
    ) throws {
        try buildReceipt.validate(against: intent)
        let reparsed: PrimeValidationInventory
        do {
            reparsed = try .parse(
                xctestList: xctestListData,
                swiftTestingList: swiftTestingListData
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidInventoryReceipt
        }
        let expectedInvocations = try PrimeValidationInvocationFactoryV2
            .inventory(intent: intent)
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              buildReceiptSHA256
                == (try buildReceipt.identitySHA256(against: intent)),
              invocations == expectedInvocations,
              observedChildren.map(\.invocation) == invocations,
              observedChildren.count == 2,
              xctestListArtifact.name == "xctest_list",
              swiftTestingListArtifact.name == "swift_testing_list",
              xctestListArtifact.content == inventory.xctestListBinding,
              swiftTestingListArtifact.content
                == inventory.swiftTestingListBinding,
              xctestListArtifact.content
                == PrimeValidationContentBinding(data: xctestListData),
              swiftTestingListArtifact.content
                == PrimeValidationContentBinding(data: swiftTestingListData),
              observedChildren[0].primaryContent
                == PrimeValidationContentBinding(data: xctestListData),
              observedChildren[1].primaryContent
                == PrimeValidationContentBinding(data: swiftTestingListData),
              inventory == reparsed,
              inventory.xctestIDs.count
                == intent.baseline.expectedXCTestCount,
              inventory.swiftTestingIDs.count
                == intent.baseline.expectedSwiftTestingCount,
              inventory.xctestListBinding.byteCount
                == intent.baseline.expectedXCTestListByteCount,
              inventory.xctestListBinding.sha256
                == intent.baseline.expectedXCTestListSHA256,
              inventory.swiftTestingListBinding.byteCount
                == intent.baseline.expectedSwiftTestingListByteCount,
              inventory.swiftTestingListBinding.sha256
                == intent.baseline.expectedSwiftTestingListSHA256,
              activeNanoseconds > 0,
              activeNanoseconds
                == (try PrimeValidationDriverV2Validation.checkedSum(
                    observedChildren.map(\.activeNanoseconds)
                )),
              activeNanoseconds
                <= intent.phaseBudgets.first(where: {
                    $0.phase == .inventory
                })!.maximumActiveNanoseconds
        else {
            throw PrimeValidationDriverV2Error.invalidInventoryReceipt
        }
        try xctestListArtifact.validate()
        try swiftTestingListArtifact.validate()
        try invocations.forEach { try $0.validate() }
        do {
            let maximum = intent.phaseBudgets.first(where: {
                $0.phase == .inventory
            })!.maximumActiveNanoseconds
            for (index, child) in observedChildren.enumerated() {
                try child.validate(
                    expectedInvocation: expectedInvocations[index],
                    maximumActiveNanoseconds: maximum
                )
                try child.requireCompleteSuccess(
                    expectedMatchedTestCount: index == 0
                        ? inventory.xctestIDs.count
                        : inventory.swiftTestingIDs.count
                )
            }
        } catch {
            throw PrimeValidationDriverV2Error.invalidInventoryReceipt
        }
        try inventory.validate()
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2,
        buildReceipt: PrimeValidationBuildReceiptV2
    ) throws -> String {
        try validate(intent: intent, buildReceipt: buildReceipt)
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

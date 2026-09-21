// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeValidationWorkflowContracts

public enum PrimeValidationComparisonArmV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case reference
    case candidate
}

public struct PrimeValidationShardPolicyV2:
    Codable,
    Equatable,
    Sendable
{
    public static let slowV20Suite =
        "PrimeCoreTests." +
        "PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractTests"

    public let schemaVersion: Int
    public let algorithm: String
    public let maximumTestsPerShard: Int
    public let maximumFilterUTF8Bytes: Int
    public let maximumConcurrentShards: Int
    public let parallelWorkerCount: Int
    public let dedicatedSuitePrefixes: [String]

    public static let frozenRootV1 = Self(
        schemaVersion: 1,
        algorithm:
            "sorted_suite_contiguous_next_fit_framework_filter_v1",
        maximumTestsPerShard: 32,
        maximumFilterUTF8Bytes: 16 * 1024,
        maximumConcurrentShards: 4,
        parallelWorkerCount: 1,
        dedicatedSuitePrefixes: [slowV20Suite]
    )

    public init(
        schemaVersion: Int,
        algorithm: String,
        maximumTestsPerShard: Int,
        maximumFilterUTF8Bytes: Int,
        maximumConcurrentShards: Int,
        parallelWorkerCount: Int,
        dedicatedSuitePrefixes: [String]
    ) {
        self.schemaVersion = schemaVersion
        self.algorithm = algorithm
        self.maximumTestsPerShard = maximumTestsPerShard
        self.maximumFilterUTF8Bytes = maximumFilterUTF8Bytes
        self.maximumConcurrentShards = maximumConcurrentShards
        self.parallelWorkerCount = parallelWorkerCount
        self.dedicatedSuitePrefixes = dedicatedSuitePrefixes
    }

    public func validate() throws {
        guard self == .frozenRootV1 else {
            throw PrimeValidationDriverV2Error.invalidShardPolicy
        }
    }
}

public enum PrimeValidationShardSelectionModeV2:
    String,
    Codable,
    Sendable
{
    case allInventory = "all_inventory"
    case exactFilter = "exact_filter"
}

public struct PrimeValidationShardKeyV2:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let runID: String
    public let arm: PrimeValidationComparisonArmV2
    public let lane: PrimeValidationExecutionLane
    public let index: Int

    public init(
        runID: String,
        arm: PrimeValidationComparisonArmV2,
        lane: PrimeValidationExecutionLane,
        index: Int
    ) {
        self.runID = runID
        self.arm = arm
        self.lane = lane
        self.index = index
    }
}

private struct PrimeValidationShardIdentityMaterialV2:
    Codable
{
    let key: PrimeValidationShardKeyV2
    let selectionMode: PrimeValidationShardSelectionModeV2
    let testIDs: [PrimeValidationTestID]
    let filterPattern: String
}

public struct PrimeValidationShardPlanV2:
    Codable,
    Equatable,
    Sendable
{
    public let key: PrimeValidationShardKeyV2
    public let shardID: String
    public let selectionMode: PrimeValidationShardSelectionModeV2
    public let testIDs: [PrimeValidationTestID]
    public let filterPattern: String

    public init(
        key: PrimeValidationShardKeyV2,
        shardID: String,
        selectionMode: PrimeValidationShardSelectionModeV2,
        testIDs: [PrimeValidationTestID],
        filterPattern: String
    ) {
        self.key = key
        self.shardID = shardID
        self.selectionMode = selectionMode
        self.testIDs = testIDs
        self.filterPattern = filterPattern
    }

    public static func make(
        key: PrimeValidationShardKeyV2,
        selectionMode: PrimeValidationShardSelectionModeV2,
        testIDs: [PrimeValidationTestID],
        filterPattern: String
    ) throws -> Self {
        let sorted = testIDs.sorted()
        let material = PrimeValidationShardIdentityMaterialV2(
            key: key,
            selectionMode: selectionMode,
            testIDs: sorted,
            filterPattern: filterPattern
        )
        return Self(
            key: key,
            shardID: try PrimeValidationDriverV2Validation.identity(material),
            selectionMode: selectionMode,
            testIDs: sorted,
            filterPattern: filterPattern
        )
    }

    public func validate(
        policy: PrimeValidationShardPolicyV2
    ) throws {
        try policy.validate()
        guard key.index >= 0,
              PrimeValidationDriverV2Validation.isRunID(key.runID),
              !testIDs.isEmpty,
              testIDs == testIDs.sorted(),
              Set(testIDs).count == testIDs.count,
              testIDs.allSatisfy({
                  $0.framework == Self.framework(for: key.lane)
              })
        else {
            throw PrimeValidationDriverV2Error.invalidShard(shardID)
        }

        switch (key.arm, selectionMode) {
        case (.reference, .allInventory):
            guard filterPattern.isEmpty else {
                throw PrimeValidationDriverV2Error.invalidShard(shardID)
            }
        case (.candidate, .exactFilter):
            guard testIDs.count <= policy.maximumTestsPerShard,
                  filterPattern
                    == (try PrimeValidationShardPlannerV2.filterPattern(
                        for: testIDs
                    )),
                  filterPattern.utf8.count
                    <= policy.maximumFilterUTF8Bytes
            else {
                throw PrimeValidationDriverV2Error.invalidShard(shardID)
            }
        default:
            throw PrimeValidationDriverV2Error.invalidShard(shardID)
        }

        let material = PrimeValidationShardIdentityMaterialV2(
            key: key,
            selectionMode: selectionMode,
            testIDs: testIDs,
            filterPattern: filterPattern
        )
        guard shardID
                == (try PrimeValidationDriverV2Validation.identity(material))
        else {
            throw PrimeValidationDriverV2Error.invalidShard(shardID)
        }
    }

    static func framework(
        for lane: PrimeValidationExecutionLane
    ) -> PrimeValidationFramework {
        switch lane {
        case .parallelXCTest, .sequentialXCTest:
            .xctest
        case .swiftTesting:
            .swiftTesting
        }
    }
}

public enum PrimeValidationShardPlannerV2 {
    public static func plan(
        inventory: PrimeValidationInventory,
        runID: String,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> [PrimeValidationShardPlanV2] {
        try inventory.validate()
        try PrimeValidationDriverV2Validation.requireRunID(runID)
        try policy.validate()

        let xPartitions = try partitions(
            inventory.xctestIDs,
            policy: policy
        )
        let swiftPartitions = try partitions(
            inventory.swiftTestingIDs,
            policy: policy
        )

        var result: [PrimeValidationShardPlanV2] = []
        result.append(
            try .make(
                key: .init(
                    runID: runID,
                    arm: .reference,
                    lane: .parallelXCTest,
                    index: 0
                ),
                selectionMode: .allInventory,
                testIDs: inventory.xctestIDs,
                filterPattern: ""
            )
        )
        result.append(
            try .make(
                key: .init(
                    runID: runID,
                    arm: .reference,
                    lane: .sequentialXCTest,
                    index: 0
                ),
                selectionMode: .allInventory,
                testIDs: inventory.xctestIDs,
                filterPattern: ""
            )
        )
        result.append(
            try .make(
                key: .init(
                    runID: runID,
                    arm: .reference,
                    lane: .swiftTesting,
                    index: 0
                ),
                selectionMode: .allInventory,
                testIDs: inventory.swiftTestingIDs,
                filterPattern: ""
            )
        )
        for lane in [
            PrimeValidationExecutionLane.parallelXCTest,
            .sequentialXCTest,
        ] {
            for (index, identifiers) in xPartitions.enumerated() {
                result.append(
                    try .make(
                        key: .init(
                            runID: runID,
                            arm: .candidate,
                            lane: lane,
                            index: index
                        ),
                        selectionMode: .exactFilter,
                        testIDs: identifiers,
                        filterPattern: try filterPattern(for: identifiers)
                    )
                )
            }
        }
        for (index, identifiers) in swiftPartitions.enumerated() {
            result.append(
                try .make(
                    key: .init(
                        runID: runID,
                        arm: .candidate,
                        lane: .swiftTesting,
                        index: index
                    ),
                    selectionMode: .exactFilter,
                    testIDs: identifiers,
                    filterPattern: try filterPattern(for: identifiers)
                )
            )
        }

        let sorted = result.sorted(by: shardLess)
        try validateExactPartitions(
            sorted,
            inventory: inventory,
            expectedRunID: runID,
            policy: policy
        )
        return sorted
    }

    public static func filterPattern(
        for testIDs: [PrimeValidationTestID]
    ) throws -> String {
        guard let framework = testIDs.first?.framework,
              !testIDs.isEmpty,
              testIDs.allSatisfy({ $0.framework == framework })
        else {
            throw PrimeValidationDriverV2Error.invalidShard(
                "mixed_or_empty_filter_identifiers"
            )
        }
        let escaped = testIDs.sorted().map {
            NSRegularExpression.escapedPattern(for: $0.rawValue)
        }
        let alternation = "(?:" + escaped.joined(separator: "|") + ")"
        // These are the exact functional Swift 6.3.3 forms observed for the
        // framework-specific list/run surfaces. Exact observed-set
        // reconciliation remains the completion authority.
        switch framework {
        case .xctest:
            return "(?:^|[^A-Za-z0-9_])" + alternation + "$"
        case .swiftTesting:
            return "(?:^|[^A-Za-z0-9_])" + alternation
                + "(?:$|[^A-Za-z0-9_])"
        }
    }

    public static func validateExactPartitions(
        _ shards: [PrimeValidationShardPlanV2],
        inventory: PrimeValidationInventory,
        expectedRunID: String,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws {
        try inventory.validate()
        try PrimeValidationDriverV2Validation.requireRunID(expectedRunID)
        try policy.validate()
        guard !shards.isEmpty,
              shards == shards.sorted(by: shardLess),
              Set(shards.map(\.key)).count == shards.count,
              Set(shards.map(\.shardID)).count == shards.count,
              shards.allSatisfy({ $0.key.runID == expectedRunID })
        else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try shards.forEach { try $0.validate(policy: policy) }

        let lanes = [
            PrimeValidationExecutionLane.parallelXCTest,
            .sequentialXCTest,
            .swiftTesting,
        ]
        for arm in PrimeValidationComparisonArmV2.allCases {
            for lane in lanes {
                let laneShards = shards.filter {
                    $0.key.arm == arm && $0.key.lane == lane
                }
                let expected = lane == .swiftTesting
                    ? inventory.swiftTestingIDs
                    : inventory.xctestIDs
                guard !laneShards.isEmpty,
                      laneShards.map(\.key.index)
                        == Array(0..<laneShards.count),
                      laneShards.flatMap(\.testIDs).sorted() == expected,
                      Set(laneShards.flatMap(\.testIDs)).count
                        == expected.count,
                      (arm == .reference ? laneShards.count == 1 : true)
                else {
                    throw PrimeValidationDriverV2Error.invalidExecutionPlan
                }
            }
        }

        let candidateParallel = shards.filter {
            $0.key.arm == .candidate
                && $0.key.lane == .parallelXCTest
        }.map(\.testIDs)
        let candidateSequential = shards.filter {
            $0.key.arm == .candidate
                && $0.key.lane == .sequentialXCTest
        }.map(\.testIDs)
        guard candidateParallel == candidateSequential else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
    }

    static func shardLess(
        _ lhs: PrimeValidationShardPlanV2,
        _ rhs: PrimeValidationShardPlanV2
    ) -> Bool {
        let lhsKey = orderKey(lhs.key)
        let rhsKey = orderKey(rhs.key)
        if lhsKey.0 != rhsKey.0 { return lhsKey.0 < rhsKey.0 }
        if lhsKey.1 != rhsKey.1 { return lhsKey.1 < rhsKey.1 }
        return lhsKey.2 < rhsKey.2
    }

    private static func orderKey(
        _ key: PrimeValidationShardKeyV2
    ) -> (Int, Int, Int) {
        let arm = key.arm == .reference ? 0 : 1
        let lane: Int
        switch key.lane {
        case .parallelXCTest: lane = 0
        case .sequentialXCTest: lane = 1
        case .swiftTesting: lane = 2
        }
        return (arm, lane, key.index)
    }

    private static func partitions(
        _ testIDs: [PrimeValidationTestID],
        policy: PrimeValidationShardPolicyV2
    ) throws -> [[PrimeValidationTestID]] {
        guard !testIDs.isEmpty else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        var bySuite: [String: [PrimeValidationTestID]] = [:]
        for identifier in testIDs.sorted() {
            let suite = String(
                identifier.rawValue.prefix {
                    $0 != "/"
                }
            )
            bySuite[suite, default: []].append(identifier)
        }

        var result: [[PrimeValidationTestID]] = []
        var current: [PrimeValidationTestID] = []

        func fits(_ candidate: [PrimeValidationTestID]) throws -> Bool {
            guard candidate.count <= policy.maximumTestsPerShard else {
                return false
            }
            return try filterPattern(for: candidate).utf8.count
                <= policy.maximumFilterUTF8Bytes
        }

        func flush() {
            guard !current.isEmpty else { return }
            result.append(current.sorted())
            current.removeAll(keepingCapacity: true)
        }

        for suite in bySuite.keys.sorted() {
            let group = bySuite[suite]!.sorted()
            guard try fits(group) else {
                throw PrimeValidationDriverV2Error.invalidShard(suite)
            }
            if policy.dedicatedSuitePrefixes.contains(suite) {
                flush()
                result.append(group)
                continue
            }
            let combined = current + group
            if current.isEmpty {
                current = combined
            } else if try fits(combined) {
                current = combined
            } else {
                flush()
                current = group
            }
        }
        flush()
        guard !result.isEmpty else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        return result
    }
}

public enum PrimeValidationInvocationRoleV2:
    String,
    Codable,
    Sendable
{
    case build
    case listXCTest = "list_xctest"
    case listSwiftTesting = "list_swift_testing"
    case shard
}

public enum PrimeValidationInvocationPrimaryResultV2:
    Codable,
    Equatable,
    Sendable
{
    case none
    case standardOutput
    case file(relativePath: String)
}

public struct PrimeValidationInvocationV2:
    Codable,
    Equatable,
    Sendable
{
    public let runID: String
    public let role: PrimeValidationInvocationRoleV2
    public let shardKey: PrimeValidationShardKeyV2?
    public let shardID: String
    public let executable: PrimeValidationExecutableBindingV2
    public let arguments: [String]
    public let orderedEnvironment: [PrimeValidationEnvironmentEntry]
    public let workingDirectoryAbsolutePath: String
    public let primaryResult: PrimeValidationInvocationPrimaryResultV2
    public let standardOutputRelativePath: String
    public let standardErrorRelativePath: String

    public init(
        runID: String,
        role: PrimeValidationInvocationRoleV2,
        shardKey: PrimeValidationShardKeyV2?,
        shardID: String,
        executable: PrimeValidationExecutableBindingV2,
        arguments: [String],
        orderedEnvironment: [PrimeValidationEnvironmentEntry],
        workingDirectoryAbsolutePath: String,
        primaryResult: PrimeValidationInvocationPrimaryResultV2,
        standardOutputRelativePath: String,
        standardErrorRelativePath: String
    ) {
        self.runID = runID
        self.role = role
        self.shardKey = shardKey
        self.shardID = shardID
        self.executable = executable
        self.arguments = arguments
        self.orderedEnvironment = orderedEnvironment
        self.workingDirectoryAbsolutePath = workingDirectoryAbsolutePath
        self.primaryResult = primaryResult
        self.standardOutputRelativePath = standardOutputRelativePath
        self.standardErrorRelativePath = standardErrorRelativePath
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireRunID(runID)
        try executable.validate()
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            workingDirectoryAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            standardOutputRelativePath
        )
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            standardErrorRelativePath
        )
        switch primaryResult {
        case .none, .standardOutput:
            break
        case let .file(relativePath):
            try PrimeValidationDriverV2Validation.requireSafeRelativePath(
                relativePath
            )
            guard relativePath != standardOutputRelativePath,
                  relativePath != standardErrorRelativePath
            else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
        }
        guard standardOutputRelativePath != standardErrorRelativePath,
            !arguments.isEmpty,
            arguments.count <= 256,
            arguments.allSatisfy({
                !$0.isEmpty
                    && $0.utf8.count <= 32 * 1024
                    && $0.utf8.allSatisfy({
                        $0 >= 0x20 && $0 != 0x7f
                    })
            }),
            orderedEnvironment.map(\.key)
                == orderedEnvironment.map(\.key).sorted(),
            Set(orderedEnvironment.map(\.key)).count
                == orderedEnvironment.count
        else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try orderedEnvironment.forEach { try $0.validate() }
        switch role {
        case .build:
            guard shardKey == nil,
                  shardID.isEmpty,
                  primaryResult == .none
            else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
        case .listXCTest, .listSwiftTesting:
            guard shardKey == nil, shardID.isEmpty else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
            guard primaryResult == .standardOutput else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
        case .shard:
            guard let shardKey,
                  shardKey.runID == runID,
                  PrimeValidationDriverV2Validation.isSHA256(shardID)
            else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
            switch (shardKey.lane, primaryResult) {
            case (.sequentialXCTest, .standardOutput),
                 (.parallelXCTest, .file(relativePath: _)),
                 (.swiftTesting, .file(relativePath: _)):
                break
            default:
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
        }
    }
}

public enum PrimeValidationInvocationFactoryV2 {
    public static func build(
        intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationInvocationV2 {
        try intent.validate()
        return PrimeValidationInvocationV2(
            runID: intent.runID,
            role: .build,
            shardKey: nil,
            shardID: "",
            executable: intent.swiftExecutable,
            arguments: commonPrefix(intent: intent, subcommand: "build") + [
                "--configuration",
                "release",
                "--build-tests",
                "--force-resolved-versions",
                "--jobs", "2",
                "--disable-build-manifest-caching",
                "-Xswiftc", "-num-threads", "-Xswiftc", "2",
            ],
            orderedEnvironment: intent.environmentPolicy.orderedEntries,
            workingDirectoryAbsolutePath:
                intent.roots.repositoryRoot.absolutePath,
            primaryResult: .none,
            standardOutputRelativePath: "build/stdout.log",
            standardErrorRelativePath: "build/stderr.log"
        )
    }

    public static func inventory(
        intent: PrimeValidationRunIntentV2
    ) throws -> [PrimeValidationInvocationV2] {
        try intent.validate()
        let common = commonPrefix(intent: intent, subcommand: "test") + [
            "--configuration",
            "release",
            "--skip-build",
            "--force-resolved-versions",
        ]
        return [
            PrimeValidationInvocationV2(
                runID: intent.runID,
                role: .listXCTest,
                shardKey: nil,
                shardID: "",
                executable: intent.swiftExecutable,
                arguments: common + ["--disable-swift-testing", "list"],
                orderedEnvironment: intent.environmentPolicy.orderedEntries,
                workingDirectoryAbsolutePath:
                    intent.roots.repositoryRoot.absolutePath,
                primaryResult: .standardOutput,
                standardOutputRelativePath:
                    "inventory/xctest-list.stdout.log",
                standardErrorRelativePath:
                    "inventory/xctest-list.stderr.log"
            ),
            PrimeValidationInvocationV2(
                runID: intent.runID,
                role: .listSwiftTesting,
                shardKey: nil,
                shardID: "",
                executable: intent.swiftExecutable,
                arguments: common + ["--disable-xctest", "list"],
                orderedEnvironment: intent.environmentPolicy.orderedEntries,
                workingDirectoryAbsolutePath:
                    intent.roots.repositoryRoot.absolutePath,
                primaryResult: .standardOutput,
                standardOutputRelativePath:
                    "inventory/swift-testing-list.stdout.log",
                standardErrorRelativePath:
                    "inventory/swift-testing-list.stderr.log"
            ),
        ]
    }

    public static func shard(
        intent: PrimeValidationRunIntentV2,
        shard: PrimeValidationShardPlanV2
    ) throws -> PrimeValidationInvocationV2 {
        try intent.validate()
        try shard.validate(policy: intent.shardPolicy)
        guard shard.key.runID == intent.runID else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        let shardRoot = "shards/" + shard.key.arm.rawValue + "/"
            + shard.key.lane.rawValue + "/"
            + String(shard.key.index) + "-" + String(shard.shardID.prefix(16))
        let xunitRelativePath = shardRoot + "/result.xml"
        var arguments = commonPrefix(intent: intent, subcommand: "test") + [
            "--configuration",
            "release",
            "--skip-build",
            "--force-resolved-versions",
        ]
        switch shard.key.lane {
        case .parallelXCTest:
            arguments += [
                "--disable-swift-testing",
                "--parallel",
                "--num-workers",
                String(intent.shardPolicy.parallelWorkerCount),
            ]
        case .sequentialXCTest:
            arguments += [
                "--disable-swift-testing",
                "--no-parallel",
            ]
        case .swiftTesting:
            arguments += [
                "--disable-xctest",
                "--no-parallel",
            ]
        }
        if shard.selectionMode == .exactFilter {
            arguments += ["--filter", shard.filterPattern]
        }
        if shard.key.lane != .sequentialXCTest {
            arguments += [
                "--xunit-output",
                PrimeValidationDriverV2Validation.appending(
                    xunitRelativePath,
                    to: intent.roots.outputAbsolutePath
                ),
            ]
        }
        return PrimeValidationInvocationV2(
            runID: intent.runID,
            role: .shard,
            shardKey: shard.key,
            shardID: shard.shardID,
            executable: intent.swiftExecutable,
            arguments: arguments,
            orderedEnvironment: intent.environmentPolicy.orderedEntries,
            workingDirectoryAbsolutePath:
                intent.roots.repositoryRoot.absolutePath,
            primaryResult: shard.key.lane == .sequentialXCTest
                ? .standardOutput : .file(relativePath: xunitRelativePath),
            standardOutputRelativePath: shardRoot + "/stdout.log",
            standardErrorRelativePath: shardRoot + "/stderr.log"
        )
    }

    private static func commonPrefix(
        intent: PrimeValidationRunIntentV2,
        subcommand: String
    ) -> [String] {
        [
            subcommand,
            "--package-path",
            intent.roots.repositoryRoot.absolutePath,
            "--scratch-path",
            intent.roots.scratchAbsolutePath,
            "--cache-path",
            intent.roots.cacheAbsolutePath,
            "--config-path",
            intent.roots.configAbsolutePath,
            "--security-path",
            intent.roots.securityAbsolutePath,
        ]
    }
}

public struct PrimeValidationExecutionPlanV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let buildReceiptSHA256: String
    public let inventoryReceiptSHA256: String
    public let baseline: PrimeValidationBaselineAnchorV2
    public let inventory: PrimeValidationInventory
    public let inventorySHA256: String
    public let maximumReferenceShardActiveNanoseconds: UInt64
    public let maximumCandidateShardActiveNanoseconds: UInt64
    public let shards: [PrimeValidationShardPlanV2]
    public let shardInvocations: [PrimeValidationInvocationV2]

    init(
        runID: String,
        intentSHA256: String,
        buildReceiptSHA256: String,
        inventoryReceiptSHA256: String,
        baseline: PrimeValidationBaselineAnchorV2,
        inventory: PrimeValidationInventory,
        inventorySHA256: String,
        maximumReferenceShardActiveNanoseconds: UInt64,
        maximumCandidateShardActiveNanoseconds: UInt64,
        shards: [PrimeValidationShardPlanV2],
        shardInvocations: [PrimeValidationInvocationV2]
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.buildReceiptSHA256 = buildReceiptSHA256
        self.inventoryReceiptSHA256 = inventoryReceiptSHA256
        self.baseline = baseline
        self.inventory = inventory
        self.inventorySHA256 = inventorySHA256
        self.maximumReferenceShardActiveNanoseconds =
            maximumReferenceShardActiveNanoseconds
        self.maximumCandidateShardActiveNanoseconds =
            maximumCandidateShardActiveNanoseconds
        self.shards = shards
        self.shardInvocations = shardInvocations
    }

    public static func make(
        intent: PrimeValidationRunIntentV2,
        buildReceipt: PrimeValidationBuildReceiptV2,
        inventoryReceipt: PrimeValidationInventoryReceiptV2
    ) throws -> Self {
        try inventoryReceipt.validate(
            intent: intent,
            buildReceipt: buildReceipt
        )
        let inventory = inventoryReceipt.inventory
        let shards = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: intent.runID,
            policy: intent.shardPolicy
        )
        return Self(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256:
                try buildReceipt.identitySHA256(against: intent),
            inventoryReceiptSHA256:
                try inventoryReceipt.identitySHA256(
                    intent: intent,
                    buildReceipt: buildReceipt
                ),
            baseline: intent.baseline,
            inventory: inventory,
            inventorySHA256: try inventory.identitySHA256(),
            maximumReferenceShardActiveNanoseconds:
                intent.phaseBudgets.first(where: {
                    $0.phase == .referenceExecution
                })!.maximumActiveNanoseconds,
            maximumCandidateShardActiveNanoseconds:
                intent.phaseBudgets.first(where: {
                    $0.phase == .candidateExecution
                })!.maximumActiveNanoseconds,
            shards: shards,
            shardInvocations: try shards.map {
                try PrimeValidationInvocationFactoryV2.shard(
                    intent: intent,
                    shard: $0
                )
            }
        )
    }

    public func validate(
        intent: PrimeValidationRunIntentV2,
        buildReceipt: PrimeValidationBuildReceiptV2,
        inventoryReceipt: PrimeValidationInventoryReceiptV2
    ) throws {
        try inventoryReceipt.validate(
            intent: intent,
            buildReceipt: buildReceipt
        )
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              buildReceiptSHA256
                == (try buildReceipt.identitySHA256(against: intent)),
              inventoryReceiptSHA256
                == (try inventoryReceipt.identitySHA256(
                    intent: intent,
                    buildReceipt: buildReceipt
                )),
              baseline == intent.baseline,
              inventory == inventoryReceipt.inventory,
              inventorySHA256 == (try inventory.identitySHA256()),
              maximumReferenceShardActiveNanoseconds
                == intent.phaseBudgets.first(where: {
                    $0.phase == .referenceExecution
                })!.maximumActiveNanoseconds,
              maximumCandidateShardActiveNanoseconds
                == intent.phaseBudgets.first(where: {
                    $0.phase == .candidateExecution
                })!.maximumActiveNanoseconds
        else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try baseline.validate()
        try PrimeValidationShardPlannerV2.validateExactPartitions(
            shards,
            inventory: inventory,
            expectedRunID: runID,
            policy: intent.shardPolicy
        )
        let expectedInvocations = try shards.map {
            try PrimeValidationInvocationFactoryV2.shard(
                intent: intent,
                shard: $0
            )
        }
        guard shardInvocations == expectedInvocations else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try shardInvocations.forEach { try $0.validate() }
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2,
        buildReceipt: PrimeValidationBuildReceiptV2,
        inventoryReceipt: PrimeValidationInventoryReceiptV2
    ) throws -> String {
        try validate(
            intent: intent,
            buildReceipt: buildReceipt,
            inventoryReceipt: inventoryReceipt
        )
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

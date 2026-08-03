// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore

final class PrimeValidationWorkflowDriverCoreTests: XCTestCase {
    func testPlannerAuthorityIsClosedAndDoesNotClaimExecution() throws {
        let authority = PrimeValidationDriverAuthorityCeilingV2
            .frozenPlannerV2
        try authority.validate()
        XCTAssertTrue(authority.schemaAndPlannerImplemented)
        XCTAssertTrue(authority.pairedSemanticComparatorImplemented)
        XCTAssertFalse(authority.processSupervisionImplemented)
        XCTAssertFalse(authority.buildInventoryExecutionImplemented)
        XCTAssertFalse(authority.durableResumeExecutionImplemented)
        XCTAssertFalse(authority.ciGateAuthorized)
        XCTAssertFalse(authority.optimizerGateAuthorized)
        XCTAssertFalse(authority.neuralGateAuthorized)
        XCTAssertFalse(authority.scientificAuthorityAuthorized)
        XCTAssertFalse(authority.trainingAuthorityAuthorized)
        XCTAssertFalse(authority.productAuthorityAuthorized)
    }

    func testObservedBaselineAnchorsAreExact() throws {
        let baseline = PrimeValidationBaselineAnchorV2()
        try baseline.validate()
        XCTAssertEqual(baseline.expectedXCTestCount, 891)
        XCTAssertEqual(baseline.expectedSwiftTestingCount, 12)
        XCTAssertEqual(baseline.expectedXCTestListByteCount, 114_060)
        XCTAssertEqual(
            baseline.expectedXCTestListSHA256,
            "583056975d443cb9195ab8af6944625833b78b848b0afa2640275811aec3f829"
        )
        XCTAssertEqual(baseline.expectedSwiftTestingListByteCount, 1_287)
        XCTAssertEqual(
            baseline.expectedSwiftTestingListSHA256,
            "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3"
        )
    }

    func testDeterministicPlannerPreservesExactPartitions() throws {
        let inventory = try makeSmallInventory()
        let forward = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: "run-small"
        )
        let replay = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: "run-small"
        )
        XCTAssertEqual(forward, replay)
        try PrimeValidationShardPlannerV2.validateExactPartitions(
            forward,
            inventory: inventory,
            expectedRunID: "run-small"
        )
    }

    func testAuthorityMutationCannotClaimUnimplementedSupervisor() throws {
        let mutation = PrimeValidationDriverAuthorityCeilingV2(
            schemaVersion: 2,
            scope: "local_repository_validation_schema_planner",
            schemaAndPlannerImplemented: true,
            pairedSemanticComparatorImplemented: true,
            processSupervisionImplemented: true,
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
                PrimeValidationDriverAuthorityCeilingV2
                .frozenPlannerV2.statement
        )
        XCTAssertThrowsError(try mutation.validate())
    }

    func testBaselineRejectsCountOrListReceiptMutation() throws {
        XCTAssertThrowsError(
            try PrimeValidationBaselineAnchorV2(
                expectedXCTestCount: 890
            ).validate()
        )
        XCTAssertThrowsError(
            try PrimeValidationBaselineAnchorV2(
                expectedXCTestListByteCount: 114_059
            ).validate()
        )
        XCTAssertThrowsError(
            try PrimeValidationBaselineAnchorV2(
                expectedSwiftTestingListSHA256:
                    String(repeating: "a", count: 64)
            ).validate()
        )
    }

    func testIntentBindsCompanionMetallibRootsAndExactEnvironment() throws {
        let intent = try makeIntent()
        try intent.validate()
        XCTAssertEqual(
            intent.companionCommit,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertTrue(
            intent.requiredPinnedMetallib.relativePath
                .hasSuffix("default.metallib")
        )
        XCTAssertEqual(
            intent.environmentPolicy.orderedEntries.map(\.key),
            [
                "CLANG_MODULE_CACHE_PATH",
                "HOME",
                "PRIME_PMHNP_COMPANION_ROOT",
                "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE",
                "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE",
                "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE",
                "PRIME_REQUIRE_V9_PINNED_DONOR_GATE",
                "PRIME_TEST_PINNED_MLX_METALLIB",
                "SWIFTPM_MODULECACHE_OVERRIDE",
                "TMPDIR",
            ]
        )
        XCTAssertFalse(
            intent.environmentPolicy.orderedEntries.contains {
                $0.key == "PATH"
            }
        )
    }

    func testIntentRejectsExternalInputAndEnvironmentMutations() throws {
        XCTAssertThrowsError(
            try makeIntent(companionCommit: String(repeating: "a", count: 40))
                .validate()
        )
        XCTAssertThrowsError(
            try makeIntent(
                metallib: .init(
                    relativePath: "root-release-build/default.bin",
                    content: content("metal")
                )
            ).validate()
        )
        XCTAssertThrowsError(
            try makeIntent(
                metallib: .init(
                    relativePath:
                        "root-release-build/release/default.metallib",
                    content: content("")
                )
            ).validate()
        )
        let valid = try makeIntent()
        let missingGate = PrimeValidationEnvironmentPolicyV2(
            orderedEntries: valid.environmentPolicy.orderedEntries.filter {
                $0.key != "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE"
            }
        )
        XCTAssertThrowsError(
            try makeIntent(environmentPolicy: missingGate).validate()
        )
    }

    func testIntentRejectsRootOverlapAndNonprivateWorkspace() throws {
        let roots = makeRoots(
            workspace: .init(
                absolutePath: "/private/tmp/prime-v2-repository/workspace",
                deviceID: 1,
                inode: 30,
                ownerUserID: 501,
                mode: 0o700
            )
        )
        XCTAssertThrowsError(try makeIntent(roots: roots).validate())

        let publicWorkspace = makeRoots(
            workspace: .init(
                absolutePath: "/private/tmp/prime-v2-workspace",
                deviceID: 1,
                inode: 30,
                ownerUserID: 501,
                mode: 0o755
            )
        )
        XCTAssertThrowsError(
            try makeIntent(roots: publicWorkspace).validate()
        )

        let validRoots = makeRoots()
        let overlappingPrivatePaths = PrimeValidationDriverRootLayoutV2(
            repositoryRoot: validRoots.repositoryRoot,
            companionRoot: validRoots.companionRoot,
            workspaceRoot: validRoots.workspaceRoot,
            evidenceRoot: validRoots.evidenceRoot,
            scratchRelativePath: validRoots.scratchRelativePath,
            cacheRelativePath: validRoots.scratchRelativePath + "/cache",
            configRelativePath: validRoots.configRelativePath,
            securityRelativePath: validRoots.securityRelativePath,
            clangModuleCacheRelativePath:
                validRoots.clangModuleCacheRelativePath,
            homeRelativePath: validRoots.homeRelativePath,
            swiftPMModuleCacheRelativePath:
                validRoots.swiftPMModuleCacheRelativePath,
            temporaryRelativePath: validRoots.temporaryRelativePath,
            outputRelativePath: validRoots.outputRelativePath
        )
        XCTAssertThrowsError(
            try makeIntent(roots: overlappingPrivatePaths).validate()
        )

        let aliasedIdentity = PrimeValidationDriverRootLayoutV2(
            repositoryRoot: validRoots.repositoryRoot,
            companionRoot: .init(
                absolutePath: validRoots.companionRoot.absolutePath,
                deviceID: validRoots.repositoryRoot.deviceID,
                inode: validRoots.repositoryRoot.inode,
                ownerUserID: validRoots.companionRoot.ownerUserID,
                mode: validRoots.companionRoot.mode
            ),
            workspaceRoot: validRoots.workspaceRoot,
            evidenceRoot: validRoots.evidenceRoot,
            scratchRelativePath: validRoots.scratchRelativePath,
            cacheRelativePath: validRoots.cacheRelativePath,
            configRelativePath: validRoots.configRelativePath,
            securityRelativePath: validRoots.securityRelativePath,
            clangModuleCacheRelativePath:
                validRoots.clangModuleCacheRelativePath,
            homeRelativePath: validRoots.homeRelativePath,
            swiftPMModuleCacheRelativePath:
                validRoots.swiftPMModuleCacheRelativePath,
            temporaryRelativePath: validRoots.temporaryRelativePath,
            outputRelativePath: validRoots.outputRelativePath
        )
        XCTAssertThrowsError(
            try makeIntent(roots: aliasedIdentity).validate()
        )
    }

    func testBundleTreeManifestIsCanonicalAndMutationSensitive() throws {
        let tree = try makeBundleTree()
        try tree.validate()
        XCTAssertEqual(tree.fileCount, 2)
        XCTAssertEqual(tree.directoryCount, 2)
        XCTAssertNotEqual(
            try tree.identitySHA256(),
            String(repeating: "0", count: 64)
        )

        let wrongManifest = PrimeValidationBundleTreeBindingV2(
            entries: tree.entries,
            manifestContent: content("wrong"),
            fileCount: tree.fileCount,
            directoryCount: tree.directoryCount,
            aggregateFileByteCount: tree.aggregateFileByteCount
        )
        XCTAssertThrowsError(try wrongManifest.validate())

        let unsafe = PrimeValidationBundleTreeEntryV2(
            relativePath: "Contents/unsafe",
            kind: .regularFile,
            mode: 0o666,
            content: content("unsafe")
        )
        XCTAssertThrowsError(try unsafe.validate())

        let fileAsParent = try PrimeValidationBundleTreeBindingV2.make(
            entries: [
                .init(
                    relativePath: "A",
                    kind: .executable,
                    mode: 0o755,
                    content: content("executable")
                ),
                .init(
                    relativePath: "A/B",
                    kind: .regularFile,
                    mode: 0o644,
                    content: content("child")
                ),
            ]
        )
        XCTAssertThrowsError(try fileAsParent.validate())

        let missingParent = try PrimeValidationBundleTreeBindingV2.make(
            entries: [
                .init(
                    relativePath: "A/B",
                    kind: .regularFile,
                    mode: 0o644,
                    content: content("child")
                ),
                .init(
                    relativePath: "Tool",
                    kind: .executable,
                    mode: 0o755,
                    content: content("executable")
                ),
            ]
        )
        XCTAssertThrowsError(try missingParent.validate())
    }

    func testBuildReceiptBindsExactGeneratedInvocationAndInputs() throws {
        let intent = try makeIntent()
        let receipt = try makeBuildReceipt(intent: intent)
        try receipt.validate(against: intent)
        XCTAssertEqual(receipt.invocation.arguments.first, "build")
        XCTAssertTrue(receipt.invocation.arguments.contains("--build-tests"))
        XCTAssertTrue(
            receipt.invocation.arguments.contains("--force-resolved-versions")
        )
        XCTAssertEqual(
            receipt.invocation.workingDirectoryAbsolutePath,
            intent.roots.repositoryRoot.absolutePath
        )
    }

    func testBuildReceiptRejectsArgumentOrPostBuildInputDrift() throws {
        let intent = try makeIntent()
        let valid = try makeBuildReceipt(intent: intent)
        let changedInvocation = PrimeValidationInvocationV2(
            runID: valid.invocation.runID,
            role: valid.invocation.role,
            shardKey: nil,
            shardID: "",
            executable: valid.invocation.executable,
            arguments: valid.invocation.arguments.filter {
                $0 != "--force-resolved-versions"
            },
            orderedEnvironment: valid.invocation.orderedEnvironment,
            workingDirectoryAbsolutePath:
                valid.invocation.workingDirectoryAbsolutePath,
            primaryResult: valid.invocation.primaryResult,
            standardOutputRelativePath:
                valid.invocation.standardOutputRelativePath,
            standardErrorRelativePath:
                valid.invocation.standardErrorRelativePath
        )
        let invocationMutation = PrimeValidationBuildReceiptV2(
            runID: valid.runID,
            intentSHA256: valid.intentSHA256,
            invocation: changedInvocation,
            observedChild: valid.observedChild,
            sourceSnapshotAfterBuild: valid.sourceSnapshotAfterBuild,
            packageLockAfterBuild: valid.packageLockAfterBuild,
            pinnedMetallibAfterBuild: valid.pinnedMetallibAfterBuild,
            testBundle: valid.testBundle,
            activeNanoseconds: valid.activeNanoseconds
        )
        XCTAssertThrowsError(try invocationMutation.validate(against: intent))

        let sourceMutation = PrimeValidationBuildReceiptV2(
            runID: valid.runID,
            intentSHA256: valid.intentSHA256,
            invocation: valid.invocation,
            observedChild: valid.observedChild,
            sourceSnapshotAfterBuild: content("changed-source"),
            packageLockAfterBuild: valid.packageLockAfterBuild,
            pinnedMetallibAfterBuild: valid.pinnedMetallibAfterBuild,
            testBundle: valid.testBundle,
            activeNanoseconds: valid.activeNanoseconds
        )
        XCTAssertThrowsError(try sourceMutation.validate(against: intent))

        let unsafeChild = PrimeValidationObservedChildReceiptV2(
            invocation: valid.invocation,
            primaryResult: valid.observedChild.primaryResult,
            standardOutputArtifact:
                valid.observedChild.standardOutputArtifact,
            standardErrorArtifact:
                valid.observedChild.standardErrorArtifact,
            process: makeProcessAudit(
                stdout:
                    valid.observedChild.standardOutputArtifact.content,
                stderr:
                    valid.observedChild.standardErrorArtifact.content,
                matchedCount: 0,
                processGroupIdentifier: 101
            ),
            activeNanoseconds: valid.observedChild.activeNanoseconds
        )
        let childMutation = PrimeValidationBuildReceiptV2(
            runID: valid.runID,
            intentSHA256: valid.intentSHA256,
            invocation: valid.invocation,
            observedChild: unsafeChild,
            sourceSnapshotAfterBuild: valid.sourceSnapshotAfterBuild,
            packageLockAfterBuild: valid.packageLockAfterBuild,
            pinnedMetallibAfterBuild: valid.pinnedMetallibAfterBuild,
            testBundle: valid.testBundle,
            activeNanoseconds: valid.activeNanoseconds
        )
        XCTAssertThrowsError(try childMutation.validate(against: intent))
    }

    func testInventoryInvocationsAreBuildOnceAndFrameworkDisjoint() throws {
        let intent = try makeIntent()
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(
            intent: intent
        )
        XCTAssertEqual(invocations.count, 2)
        XCTAssertTrue(
            invocations.allSatisfy {
                $0.arguments.contains("--skip-build")
                    && $0.arguments.last == "list"
                    && !$0.arguments.contains("--build-tests")
            }
        )
        XCTAssertTrue(
            invocations[0].arguments.contains("--disable-swift-testing")
        )
        XCTAssertTrue(invocations[1].arguments.contains("--disable-xctest"))
    }

    func testInventoryReceiptRejectsSyntheticSameShapeInventory() throws {
        let intent = try makeIntent()
        let build = try makeBuildReceipt(intent: intent)
        let inventory = try makeSmallInventory()
        let xData = Data(
            (inventory.xctestIDs.map(\.rawValue).joined(separator: "\n")
                + "\n").utf8
        )
        let swiftData = Data(
            (inventory.swiftTestingIDs.map(\.rawValue).joined(separator: "\n")
                + "\n").utf8
        )
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(
            intent: intent
        )
        let receipt = PrimeValidationInventoryReceiptV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256:
                try build.identitySHA256(against: intent),
            invocations: invocations,
            observedChildren: [
                makeObservedChild(
                    invocation: invocations[0],
                    standardOutputData: xData,
                    matchedCount: inventory.xctestIDs.count
                ),
                makeObservedChild(
                    invocation: invocations[1],
                    standardOutputData: swiftData,
                    matchedCount: inventory.swiftTestingIDs.count
                ),
            ],
            xctestListArtifact: .init(
                name: "xctest_list",
                relativePath: "inventory/xctest.list",
                content: .init(data: xData)
            ),
            swiftTestingListArtifact: .init(
                name: "swift_testing_list",
                relativePath: "inventory/swift-testing.list",
                content: .init(data: swiftData)
            ),
            xctestListData: xData,
            swiftTestingListData: swiftData,
            inventory: inventory,
            activeNanoseconds: 2
        )
        XCTAssertThrowsError(
            try receipt.validate(intent: intent, buildReceipt: build)
        )
    }

    func testPublicExecutionPlanAdmissionUsesExactFrozenInventories()
        throws
    {
        let intent = try makeIntent(runID: "run-frozen-admission")
        let build = try makeBuildReceipt(intent: intent)
        let xctestData = try frozenListData(
            name: "xctest"
        )
        let swiftTestingData = try frozenListData(
            name: "swift-testing"
        )
        let inventoryReceipt = try makeInventoryReceipt(
            intent: intent,
            build: build,
            xctestData: xctestData,
            swiftTestingData: swiftTestingData
        )
        let inventory = inventoryReceipt.inventory
        XCTAssertEqual(
            inventory.xctestListBinding.sha256,
            PrimeValidationBaselineAnchorV2.xctestListSHA256
        )
        XCTAssertEqual(
            inventory.swiftTestingListBinding.sha256,
            PrimeValidationBaselineAnchorV2.swiftTestingListSHA256
        )
        try inventoryReceipt.validate(
            intent: intent,
            buildReceipt: build
        )
        let plan = try PrimeValidationExecutionPlanV2.make(
            intent: intent,
            buildReceipt: build,
            inventoryReceipt: inventoryReceipt
        )
        try plan.validate(
            intent: intent,
            buildReceipt: build,
            inventoryReceipt: inventoryReceipt
        )
        let planSHA = try plan.identitySHA256(
            intent: intent,
            buildReceipt: build,
            inventoryReceipt: inventoryReceipt
        )
        XCTAssertEqual(plan.inventory.xctestIDs.count, 891)
        XCTAssertEqual(plan.inventory.swiftTestingIDs.count, 12)
        XCTAssertEqual(planSHA.utf8.count, 64)
        XCTAssertFalse(plan.shards.isEmpty)
    }

    func testPublicExecutionPlanRejectsFrozenByteAndChainMutation()
        throws
    {
        let intent = try makeIntent(runID: "run-frozen-mutation")
        let build = try makeBuildReceipt(intent: intent)
        let xctestData = try frozenListData(name: "xctest")
        let swiftTestingData = try frozenListData(name: "swift-testing")
        let validInventoryReceipt = try makeInventoryReceipt(
            intent: intent,
            build: build,
            xctestData: xctestData,
            swiftTestingData: swiftTestingData
        )
        let validPlan = try PrimeValidationExecutionPlanV2.make(
            intent: intent,
            buildReceipt: build,
            inventoryReceipt: validInventoryReceipt
        )

        var mutatedXCTestData = xctestData
        let firstNewline = try XCTUnwrap(
            mutatedXCTestData.firstIndex(of: 0x0a)
        )
        let mutationIndex = mutatedXCTestData.index(before: firstNewline)
        XCTAssertEqual(mutatedXCTestData[mutationIndex], 0x65)
        mutatedXCTestData[mutationIndex] = 0x64
        XCTAssertEqual(mutatedXCTestData.count, xctestData.count)

        let mutatedInventoryReceipt = try makeInventoryReceipt(
            intent: intent,
            build: build,
            xctestData: mutatedXCTestData,
            swiftTestingData: swiftTestingData
        )
        XCTAssertEqual(
            mutatedInventoryReceipt.inventory.xctestIDs.count,
            891
        )
        XCTAssertThrowsError(
            try mutatedInventoryReceipt.validate(
                intent: intent,
                buildReceipt: build
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationExecutionPlanV2.make(
                intent: intent,
                buildReceipt: build,
                inventoryReceipt: mutatedInventoryReceipt
            )
        )

        let chainMutation = PrimeValidationExecutionPlanV2(
            runID: validPlan.runID,
            intentSHA256: validPlan.intentSHA256,
            buildReceiptSHA256: String(repeating: "f", count: 64),
            inventoryReceiptSHA256: validPlan.inventoryReceiptSHA256,
            baseline: validPlan.baseline,
            inventory: validPlan.inventory,
            inventorySHA256: validPlan.inventorySHA256,
            maximumReferenceShardActiveNanoseconds:
                validPlan.maximumReferenceShardActiveNanoseconds,
            maximumCandidateShardActiveNanoseconds:
                validPlan.maximumCandidateShardActiveNanoseconds,
            shards: validPlan.shards,
            shardInvocations: validPlan.shardInvocations
        )
        XCTAssertThrowsError(
            try chainMutation.validate(
                intent: intent,
                buildReceipt: build,
                inventoryReceipt: validInventoryReceipt
            )
        )
    }

    func testFrameworkSpecificFilterPatternsMatchMeasuredForms() throws {
        let x = try PrimeValidationTestID.parse(
            "PrimeCoreTests.AlphaTests/testA",
            framework: .xctest
        )
        let swift = try PrimeValidationTestID.parse(
            "PrimeCoreTests.SwiftSuite/testOne()",
            framework: .swiftTesting
        )
        XCTAssertEqual(
            try PrimeValidationShardPlannerV2.filterPattern(for: [x]),
            "(?:^|[^A-Za-z0-9_])(?:PrimeCoreTests\\.AlphaTests\\/testA)$"
        )
        XCTAssertEqual(
            try PrimeValidationShardPlannerV2.filterPattern(for: [swift]),
            "(?:^|[^A-Za-z0-9_])(?:PrimeCoreTests\\.SwiftSuite\\/testOne\\(\\))(?:$|[^A-Za-z0-9_])"
        )
        XCTAssertNotEqual(
            try PrimeValidationShardPlannerV2.filterPattern(for: [x]),
            "^(?:PrimeCoreTests\\.AlphaTests/testA)$"
        )
        XCTAssertThrowsError(
            try PrimeValidationShardPlannerV2.filterPattern(for: [x, swift])
        )
        XCTAssertThrowsError(
            try PrimeValidationShardPlannerV2.filterPattern(for: [])
        )
    }

    func testPlannerSeparatesKnownSlowSuiteAndBindsRunIdentity() throws {
        let inventory = try makeSmallInventory()
        let first = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: "run-a"
        )
        let second = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: "run-b"
        )
        let slow = first.filter {
            $0.key.arm == .candidate
                && $0.key.lane == .parallelXCTest
                && $0.testIDs.contains(where: {
                    $0.rawValue.hasPrefix(
                        PrimeValidationShardPolicyV2.slowV20Suite + "/"
                    )
                })
        }
        XCTAssertEqual(slow.count, 1)
        XCTAssertEqual(slow[0].testIDs.count, 1)
        XCTAssertTrue(first.allSatisfy { $0.key.runID == "run-a" })
        XCTAssertNotEqual(
            first.map(\.shardID),
            second.map(\.shardID)
        )
    }

    func testPlannerRejectsOmissionDuplicateAndOldFilterPattern() throws {
        let inventory = try makeSmallInventory()
        let shards = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: "run-mutations"
        )
        XCTAssertThrowsError(
            try PrimeValidationShardPlannerV2.validateExactPartitions(
                Array(shards.dropLast()),
                inventory: inventory,
                expectedRunID: "run-mutations"
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationShardPlannerV2.validateExactPartitions(
                shards + [shards.last!],
                inventory: inventory,
                expectedRunID: "run-mutations"
            )
        )
        let candidate = try XCTUnwrap(
            shards.first(where: { $0.key.arm == .candidate })
        )
        let oldPattern = "^(?:" + candidate.testIDs.map {
            NSRegularExpression.escapedPattern(for: $0.rawValue)
        }.joined(separator: "|") + ")$"
        let oldPatternMutation = PrimeValidationShardPlanV2(
            key: candidate.key,
            shardID: candidate.shardID,
            selectionMode: candidate.selectionMode,
            testIDs: candidate.testIDs,
            filterPattern: oldPattern
        )
        XCTAssertThrowsError(
            try oldPatternMutation.validate(policy: .frozenRootV1)
        )
    }

    func testShardInvocationBindsSkipBuildLaneModeFilterAndOutput() throws {
        let intent = try makeIntent(runID: "run-shard-invocation")
        let inventory = try makeSmallInventory()
        let shards = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: intent.runID
        )
        let shard = try XCTUnwrap(
            shards.first(where: {
                $0.key.arm == .candidate
                    && $0.key.lane == .parallelXCTest
            })
        )
        let invocation = try PrimeValidationInvocationFactoryV2.shard(
            intent: intent,
            shard: shard
        )
        try invocation.validate()
        XCTAssertTrue(invocation.arguments.contains("--skip-build"))
        XCTAssertTrue(
            invocation.arguments.contains("--disable-swift-testing")
        )
        XCTAssertTrue(invocation.arguments.contains("--parallel"))
        XCTAssertTrue(invocation.arguments.contains("--num-workers"))
        XCTAssertTrue(invocation.arguments.contains(shard.filterPattern))
        XCTAssertTrue(invocation.arguments.contains("--xunit-output"))
        XCTAssertEqual(invocation.shardKey?.runID, intent.runID)

        let sequential = try XCTUnwrap(
            shards.first(where: {
                $0.key.arm == .candidate
                    && $0.key.lane == .sequentialXCTest
            })
        )
        let sequentialInvocation = try PrimeValidationInvocationFactoryV2
            .shard(intent: intent, shard: sequential)
        XCTAssertEqual(
            sequentialInvocation.primaryResult,
            PrimeValidationInvocationPrimaryResultV2.standardOutput
        )
        XCTAssertFalse(
            sequentialInvocation.arguments.contains("--xunit-output")
        )
    }

    func testPhaseResumeOnlyExecutesNeverStartedWork() throws {
        let intent = try makeIntent()
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2.decidePhase(
                start: nil,
                terminal: nil,
                intent: intent
            ),
            .executeNeverStarted
        )
        let start = try makePhaseStart(intent: intent)
        assertAuthorityViolation(
            try PrimeValidationResumeStateMachineV2.decidePhase(
                start: start,
                terminal: nil,
                intent: intent
            )
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decidePhasePairMechanics(
                start: start,
                terminal: nil,
                intent: intent
            ),
            .permanentlyIncomplete
        )
        let terminal = try makePhaseTerminal(
            start: start,
            intent: intent,
            disposition: .succeeded
        )
        assertAuthorityViolation(
            try PrimeValidationResumeStateMachineV2.decidePhase(
                start: start,
                terminal: terminal,
                intent: intent
            )
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decidePhasePairMechanics(
                start: start,
                terminal: terminal,
                intent: intent
            ),
            .reuseSucceededTerminal
        )
        XCTAssertThrowsError(
            try PrimeValidationResumeStateMachineV2.decidePhase(
                start: nil,
                terminal: terminal,
                intent: intent
            )
        )
    }

    func testFailedAndIncompletePhaseTerminalsCannotBeRetried() throws {
        let intent = try makeIntent()
        let start = try makePhaseStart(intent: intent)
        let failed = try makePhaseTerminal(
            start: start,
            intent: intent,
            disposition: .failed
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decidePhasePairMechanics(
                start: start,
                terminal: failed,
                intent: intent
            ),
            .reuseFailedTerminal
        )
        let incomplete = try makePhaseTerminal(
            start: start,
            intent: intent,
            disposition: .incomplete
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decidePhasePairMechanics(
                start: start,
                terminal: incomplete,
                intent: intent
            ),
            .permanentlyIncomplete
        )
    }

    func testPhaseReceiptRejectsWrongChainAndZeroDuration() throws {
        let intent = try makeIntent()
        let invalidStart = PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .sourceAdmission,
            phaseOrdinal: 0,
            predecessorTerminalSHA256: String(repeating: "a", count: 64)
        )
        XCTAssertThrowsError(try invalidStart.validate(against: intent))

        let start = try makePhaseStart(intent: intent)
        let terminal = PrimeValidationPhaseTerminalReceiptV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .sourceAdmission,
            phaseStartSHA256:
                try start.identitySHA256(against: intent),
            disposition: .succeeded,
            activeNanoseconds: 0,
            outputArtifacts: [artifact("source")]
        )
        XCTAssertThrowsError(
            try terminal.validate(start: start, intent: intent)
        )
    }

    func testPhaseLedgerRejectsSubstitutionReorderGapAndContinuation()
        throws
    {
        let intent = try makeIntent(runID: "run-phase-ledger")
        let sourceStart = try makePhaseStart(intent: intent)
        let sourceTerminal = try makePhaseTerminal(
            start: sourceStart,
            intent: intent,
            disposition: .succeeded
        )
        let sourceSHA = try sourceTerminal.identitySHA256(
            start: sourceStart,
            intent: intent
        )
        let buildStart = PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .build,
            phaseOrdinal: 1,
            predecessorTerminalSHA256: sourceSHA
        )
        let buildTerminal = try makePhaseTerminal(
            start: buildStart,
            intent: intent,
            disposition: .succeeded
        )
        let validEntries = [
            PrimeValidationPhaseLedgerEntryV2(
                start: sourceStart,
                terminal: sourceTerminal
            ),
            .init(start: buildStart, terminal: buildTerminal),
        ]
        let valid = PrimeValidationPhaseLedgerV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            entries: validEntries
        )
        try valid.validate(intent: intent)

        let substitutedBuild = PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .build,
            phaseOrdinal: 1,
            predecessorTerminalSHA256: String(repeating: "c", count: 64)
        )
        XCTAssertThrowsError(
            try PrimeValidationPhaseLedgerV2(
                runID: intent.runID,
                intentSHA256: try intent.identitySHA256(),
                entries: [
                    validEntries[0],
                    .init(start: substitutedBuild, terminal: nil),
                ]
            ).validate(intent: intent)
        )
        XCTAssertThrowsError(
            try PrimeValidationPhaseLedgerV2(
                runID: intent.runID,
                intentSHA256: try intent.identitySHA256(),
                entries: [validEntries[1], validEntries[0]]
            ).validate(intent: intent)
        )

        let gap = PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .inventory,
            phaseOrdinal: 2,
            predecessorTerminalSHA256: sourceSHA
        )
        XCTAssertThrowsError(
            try PrimeValidationPhaseLedgerV2(
                runID: intent.runID,
                intentSHA256: try intent.identitySHA256(),
                entries: [validEntries[0], .init(start: gap, terminal: nil)]
            ).validate(intent: intent)
        )

        let failedSource = try makePhaseTerminal(
            start: sourceStart,
            intent: intent,
            disposition: .failed
        )
        let failedSourceSHA = try failedSource.identitySHA256(
            start: sourceStart,
            intent: intent
        )
        let forbiddenContinuation = PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .build,
            phaseOrdinal: 1,
            predecessorTerminalSHA256: failedSourceSHA
        )
        XCTAssertThrowsError(
            try PrimeValidationPhaseLedgerV2(
                runID: intent.runID,
                intentSHA256: try intent.identitySHA256(),
                entries: [
                    .init(start: sourceStart, terminal: failedSource),
                    .init(start: forbiddenContinuation, terminal: nil),
                ]
            ).validate(intent: intent)
        )
    }

    func testProcessAuditDistinguishesOverflowAndContainment() throws {
        let stdout = content("stdout")
        let stderr = content("")
        let valid = makeProcessAudit(
            stdout: stdout,
            stderr: stderr,
            matchedCount: 1
        )
        try valid.validate(
            standardOutputContent: stdout,
            standardErrorContent: stderr
        )
        XCTAssertTrue(valid.completeSafetyObserved)

        let overflow = PrimeValidationProcessAuditV2(
            processIdentifier: 100,
            sessionIdentifier: 100,
            processGroupIdentifier: 100,
            deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: [100],
            exactReturnedProcessIdentifier: 100,
            rawWaitStatus: 0,
            waitTermination: .exited(0),
            processGroupEmptyAfterReap: true,
            standardOutput: .init(
                eofObserved: true,
                totalByteCount: stdout.byteCount + 1,
                capturedByteCount: stdout.byteCount,
                overflowObserved: true,
                readErrorNumber: 0,
                writeErrorNumber: 0
            ),
            standardError: streamAudit(content: stderr),
            matchedTestCount: 1
        )
        try overflow.validate(
            standardOutputContent: stdout,
            standardErrorContent: stderr
        )
        XCTAssertFalse(overflow.completeSafetyObserved)

        let falseOverflow = PrimeValidationProcessAuditV2(
            processIdentifier: 100,
            sessionIdentifier: 100,
            processGroupIdentifier: 100,
            deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: [100],
            exactReturnedProcessIdentifier: 100,
            rawWaitStatus: 0,
            waitTermination: .exited(0),
            processGroupEmptyAfterReap: true,
            standardOutput: .init(
                eofObserved: true,
                totalByteCount: stdout.byteCount,
                capturedByteCount: stdout.byteCount,
                overflowObserved: true,
                readErrorNumber: 0,
                writeErrorNumber: 0
            ),
            standardError: streamAudit(content: stderr),
            matchedTestCount: 1
        )
        XCTAssertThrowsError(
            try falseOverflow.validate(
                standardOutputContent: stdout,
                standardErrorContent: stderr
            )
        )
    }

    func testCompleteShardPublicAdmissionIsClosedButKernelIsExact() throws {
        let material = try makeShardMaterial()
        XCTAssertThrowsError(
            try material.receipt.validate(
                start: material.start,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )
        try material.receipt.validateAssumingParsedSemanticEvidence(
            start: material.start,
            expectedRunID: material.start.runID,
            expectedExecutionPlanSHA256:
                material.start.executionPlanSHA256,
            maximumActiveNanoseconds: 100
        )
        XCTAssertThrowsError(
            try PrimeValidationResumeStateMachineV2.decideShard(
                start: material.start,
                terminal: material.receipt,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decideShardAssumingParsedSemanticEvidence(
                start: material.start,
                terminal: material.receipt,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            ),
            .reuseSucceededTerminal
        )
        XCTAssertThrowsError(
            try material.receipt.identitySHA256(
                start: material.start,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )
        XCTAssertNotEqual(
            try material.receipt
                .identitySHA256AssumingParsedSemanticEvidence(
                start: material.start,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            ),
            String(repeating: "0", count: 64)
        )
    }

    func testStartedShardWithoutTerminalIsPermanentlyIncomplete() throws {
        let material = try makeShardMaterial()
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2.decideShard(
                start: material.start,
                terminal: nil,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            ),
            .permanentlyIncomplete
        )
    }

    func testCompleteFailingShardReusesFailedTerminal() throws {
        let material = try makeShardMaterial()
        var results = material.receipt.semanticResults
        results[0] = PrimeValidationSemanticTestResultV2(
            testID: results[0].testID,
            terminal: .failed
        )
        let failed = PrimeValidationShardReceiptV2(
            runID: material.receipt.runID,
            executionPlanSHA256: material.receipt.executionPlanSHA256,
            shardStartSHA256: material.receipt.shardStartSHA256,
            shardID: material.receipt.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: material.receipt.resultArtifact,
            standardOutputArtifact:
                material.receipt.standardOutputArtifact,
            standardErrorArtifact:
                material.receipt.standardErrorArtifact,
            process: makeProcessAudit(
                stdout: material.receipt.standardOutputArtifact.content,
                stderr: material.receipt.standardErrorArtifact.content,
                matchedCount: material.start.shard.testIDs.count,
                termination: .exited(1)
            ),
            semanticResults: results,
            activeNanoseconds: 1
        )
        XCTAssertEqual(
            try PrimeValidationResumeStateMachineV2
                .decideShardAssumingParsedSemanticEvidence(
                start: material.start,
                terminal: failed,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            ),
            .reuseFailedTerminal
        )
    }

    func testCompleteShardRejectsWrongResultSetExitAndContainment() throws {
        let material = try makeShardMaterial()
        let missing = PrimeValidationShardReceiptV2(
            runID: material.receipt.runID,
            executionPlanSHA256: material.receipt.executionPlanSHA256,
            shardStartSHA256: material.receipt.shardStartSHA256,
            shardID: material.receipt.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: material.receipt.resultArtifact,
            standardOutputArtifact:
                material.receipt.standardOutputArtifact,
            standardErrorArtifact:
                material.receipt.standardErrorArtifact,
            process: material.receipt.process,
            semanticResults: Array(material.receipt.semanticResults.dropLast()),
            activeNanoseconds: 1
        )
        XCTAssertThrowsError(
            try missing.validateAssumingParsedSemanticEvidence(
                start: material.start,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )

        let unsafeProcess = PrimeValidationProcessAuditV2(
            processIdentifier: material.receipt.process.processIdentifier,
            sessionIdentifier:
                material.receipt.process.processIdentifier,
            processGroupIdentifier:
                material.receipt.process.processIdentifier + 1,
            deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: [
                material.receipt.process.processIdentifier,
            ],
            exactReturnedProcessIdentifier:
                material.receipt.process.processIdentifier,
            rawWaitStatus: 0,
            waitTermination: .exited(0),
            processGroupEmptyAfterReap: true,
            standardOutput: streamAudit(
                content: material.receipt.standardOutputArtifact.content
            ),
            standardError: streamAudit(
                content: material.receipt.standardErrorArtifact.content
            ),
            matchedTestCount: material.start.shard.testIDs.count
        )
        let uncontained = PrimeValidationShardReceiptV2(
            runID: material.receipt.runID,
            executionPlanSHA256: material.receipt.executionPlanSHA256,
            shardStartSHA256: material.receipt.shardStartSHA256,
            shardID: material.receipt.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: material.receipt.resultArtifact,
            standardOutputArtifact:
                material.receipt.standardOutputArtifact,
            standardErrorArtifact:
                material.receipt.standardErrorArtifact,
            process: unsafeProcess,
            semanticResults: material.receipt.semanticResults,
            activeNanoseconds: 1
        )
        XCTAssertThrowsError(
            try uncontained.validateAssumingParsedSemanticEvidence(
                start: material.start,
                expectedRunID: material.start.runID,
                expectedExecutionPlanSHA256:
                    material.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )
    }

    func testShardReceiptEnforcesLaneArtifactAliasAndNames() throws {
        let parallel = try makeShardMaterial(lane: .parallelXCTest)
        let wrongNameOutput = PrimeValidationDriverArtifactBindingV2(
            name: "stdout",
            relativePath:
                parallel.receipt.standardOutputArtifact.relativePath,
            content: parallel.receipt.standardOutputArtifact.content
        )
        let wrongName = PrimeValidationShardReceiptV2(
            runID: parallel.receipt.runID,
            executionPlanSHA256: parallel.receipt.executionPlanSHA256,
            shardStartSHA256: parallel.receipt.shardStartSHA256,
            shardID: parallel.receipt.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: parallel.receipt.resultArtifact,
            standardOutputArtifact: wrongNameOutput,
            standardErrorArtifact: parallel.receipt.standardErrorArtifact,
            process: parallel.receipt.process,
            semanticResults: parallel.receipt.semanticResults,
            activeNanoseconds: parallel.receipt.activeNanoseconds
        )
        XCTAssertThrowsError(
            try wrongName.validateAssumingParsedSemanticEvidence(
                start: parallel.start,
                expectedRunID: parallel.start.runID,
                expectedExecutionPlanSHA256:
                    parallel.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )

        let sequential = try makeShardMaterial(lane: .sequentialXCTest)
        try sequential.receipt.validateAssumingParsedSemanticEvidence(
            start: sequential.start,
            expectedRunID: sequential.start.runID,
            expectedExecutionPlanSHA256:
                sequential.start.executionPlanSHA256,
            maximumActiveNanoseconds: 100
        )
        let mismatchedAlias = PrimeValidationDriverArtifactBindingV2(
            name: "result",
            relativePath:
                sequential.receipt.standardOutputArtifact.relativePath,
            content: content("not-the-standard-output")
        )
        let aliasMutation = PrimeValidationShardReceiptV2(
            runID: sequential.receipt.runID,
            executionPlanSHA256: sequential.receipt.executionPlanSHA256,
            shardStartSHA256: sequential.receipt.shardStartSHA256,
            shardID: sequential.receipt.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: mismatchedAlias,
            standardOutputArtifact:
                sequential.receipt.standardOutputArtifact,
            standardErrorArtifact:
                sequential.receipt.standardErrorArtifact,
            process: sequential.receipt.process,
            semanticResults: sequential.receipt.semanticResults,
            activeNanoseconds: sequential.receipt.activeNanoseconds
        )
        XCTAssertThrowsError(
            try aliasMutation.validateAssumingParsedSemanticEvidence(
                start: sequential.start,
                expectedRunID: sequential.start.runID,
                expectedExecutionPlanSHA256:
                    sequential.start.executionPlanSHA256,
                maximumActiveNanoseconds: 100
            )
        )
    }

    func testSemanticResultRequiresExactSkipFraming() throws {
        let id = try PrimeValidationTestID.parse(
            "PrimeCoreTests.AlphaTests/testA",
            framework: .xctest
        )
        XCTAssertThrowsError(
            try PrimeValidationSemanticTestResultV2(
                testID: id,
                terminal: .skipped,
                exactSkipReason: ""
            ).validate()
        )
        XCTAssertThrowsError(
            try PrimeValidationSemanticTestResultV2(
                testID: id,
                terminal: .passed,
                exactSkipReason: "not-empty"
            ).validate()
        )
        let noncanonicalSwiftTestingID = try JSONDecoder().decode(
            PrimeValidationTestID.self,
            from: Data(
                """
                {
                  "framework": "swift_testing",
                  "rawValue": "PrimeCoreTests.SwiftSuite.testOne()"
                }
                """.utf8
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationSemanticTestResultV2(
                testID: noncanonicalSwiftTestingID,
                terminal: .passed
            ).validate()
        )
    }

    func testPairedSemanticComparatorRejectsSameCountDifferentMeaning() throws {
        let id = try PrimeValidationTestID.parse(
            "PrimeCoreTests.AlphaTests/testA",
            framework: .xctest
        )
        let pass = PrimeValidationSemanticTestResultV2(
            testID: id,
            terminal: .passed
        )
        let fail = PrimeValidationSemanticTestResultV2(
            testID: id,
            terminal: .failed
        )
        XCTAssertEqual(
            try PrimeValidationPairedSemanticComparatorV2
                .compareSemanticResults(
                    reference: [pass],
                    candidate: [pass]
                ),
            .equivalent
        )
        XCTAssertEqual(
            try PrimeValidationPairedSemanticComparatorV2
                .compareSemanticResults(
                    reference: [pass],
                    candidate: [fail]
                ),
            .semanticMismatch
        )
        XCTAssertThrowsError(
            try PrimeValidationPairedSemanticComparatorV2
                .compareSemanticResults(
                    reference: [pass, pass],
                    candidate: [pass]
                )
        )
    }

    func testXCTestLaneReconciliationUsesSequentialSkipAuthority() throws {
        let id = try PrimeValidationTestID.parse(
            "PrimeCoreTests.AlphaTests/testA",
            framework: .xctest
        )
        let parallelPass = PrimeValidationSemanticTestResultV2(
            testID: id,
            terminal: .passed
        )
        let sequentialSkip = PrimeValidationSemanticTestResultV2(
            testID: id,
            terminal: .skipped,
            exactSkipReason: "exact_sequential_skip_reason"
        )
        let reconciled = PrimeValidationArmAggregateV2
            .reconcileXCTestLaneSemantics(
                parallel: [id: parallelPass],
                sequential: [id: sequentialSkip],
                expectedIDs: [id]
            )
        XCTAssertEqual(reconciled.results, [sequentialSkip])
        XCTAssertEqual(reconciled.reason, "")

        let parallelFailure = PrimeValidationSemanticTestResultV2(
            testID: id,
            terminal: .failed
        )
        let mismatch = PrimeValidationArmAggregateV2
            .reconcileXCTestLaneSemantics(
                parallel: [id: parallelFailure],
                sequential: [id: parallelPass],
                expectedIDs: [id]
            )
        XCTAssertNil(mismatch.results)
        XCTAssertEqual(mismatch.reason, "xctest_lane_semantic_mismatch")
    }

    func testProductionCardinalityAggregateComparisonAndFinalKernels()
        throws
    {
        let fixture = try makeSyntheticAggregateFixture()
        XCTAssertEqual(fixture.executionPlan.inventory.xctestIDs.count, 891)
        XCTAssertEqual(
            fixture.executionPlan.inventory.swiftTestingIDs.count,
            12
        )
        try PrimeValidationShardPlannerV2.validateExactPartitions(
            fixture.executionPlan.shards,
            inventory: fixture.executionPlan.inventory,
            expectedRunID: fixture.executionPlan.runID
        )

        let referenceEvidence = try makeSyntheticShardEvidence(
            arm: .reference,
            fixture: fixture
        )
        let candidateEvidence = try makeSyntheticShardEvidence(
            arm: .candidate,
            fixture: fixture
        )
        let reference = try PrimeValidationArmAggregateV2
            .aggregateAssumingAdmittedPlan(
                arm: .reference,
                shardEvidence: referenceEvidence,
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        let candidate = try PrimeValidationArmAggregateV2
            .aggregateAssumingAdmittedPlan(
                arm: .candidate,
                shardEvidence: candidateEvidence,
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        XCTAssertEqual(reference.disposition, .completePass)
        XCTAssertEqual(candidate.disposition, .completePass)
        XCTAssertEqual(reference.semanticResults.count, 903)
        XCTAssertEqual(candidate.semanticResults.count, 903)

        let comparison = try PrimeValidationPairedSemanticComparatorV2
            .compareAssumingValidatedAggregates(
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        try PrimeValidationPairedSemanticComparatorV2
            .validateAssumingValidatedAggregates(
                comparison,
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        XCTAssertEqual(comparison.disposition, .equivalent)
        let final = try PrimeValidationDriverFinalReceiptV2
            .makeAssumingValidatedComparison(
                comparison: comparison,
                reference: reference,
                candidate: candidate
            )
        try final.validateAssumingValidatedComparison(
            comparison: comparison,
            reference: reference,
            candidate: candidate
        )
        XCTAssertEqual(final.disposition, .completePass)

        assertAuthorityViolation(
            try referenceEvidence[0].validate(
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try PrimeValidationArmAggregateV2.make(
                arm: .reference,
                shardEvidence: referenceEvidence,
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try reference.validate(
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try PrimeValidationPairedSemanticComparatorV2.compare(
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try PrimeValidationPairedSemanticComparatorV2.validate(
                comparison,
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try PrimeValidationDriverFinalReceiptV2.make(
                comparison: comparison,
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        )
        assertAuthorityViolation(
            try final.validate(
                comparison: comparison,
                reference: reference,
                candidate: candidate,
                executionPlan: fixture.executionPlan,
                executionPlanSHA256: fixture.executionPlanSHA256
            )
        )

        let mismatchedEvidence = try makeSyntheticShardEvidence(
            arm: .candidate,
            fixture: fixture,
            failFirstParallelTest: true
        )
        let mismatched = try PrimeValidationArmAggregateV2
            .aggregateAssumingAdmittedPlan(
                arm: .candidate,
                shardEvidence: mismatchedEvidence,
                executionPlan: fixture.executionPlan,
                expectedExecutionPlanSHA256: fixture.executionPlanSHA256
            )
        XCTAssertEqual(mismatched.disposition, .incomplete)
        XCTAssertEqual(
            mismatched.incompleteReason,
            "xctest_lane_semantic_mismatch"
        )

        let firstEvidence = try XCTUnwrap(referenceEvidence.first)
        let invalidReceipt = PrimeValidationShardReceiptV2(
            runID: firstEvidence.receipt.runID,
            executionPlanSHA256:
                firstEvidence.receipt.executionPlanSHA256,
            shardStartSHA256: firstEvidence.receipt.shardStartSHA256,
            shardID: String(repeating: "0", count: 64),
            disposition: firstEvidence.receipt.disposition,
            incompleteReason: firstEvidence.receipt.incompleteReason,
            resultArtifact: firstEvidence.receipt.resultArtifact,
            standardOutputArtifact:
                firstEvidence.receipt.standardOutputArtifact,
            standardErrorArtifact:
                firstEvidence.receipt.standardErrorArtifact,
            process: firstEvidence.receipt.process,
            semanticResults: firstEvidence.receipt.semanticResults,
            activeNanoseconds: firstEvidence.receipt.activeNanoseconds
        )
        var invalidEvidence = referenceEvidence
        invalidEvidence[0] = .init(
            start: firstEvidence.start,
            receipt: invalidReceipt
        )
        XCTAssertThrowsError(
            try PrimeValidationArmAggregateV2
                .aggregateAssumingAdmittedPlan(
                    arm: .reference,
                    shardEvidence: invalidEvidence,
                    executionPlan: fixture.executionPlan,
                    expectedExecutionPlanSHA256:
                        fixture.executionPlanSHA256
                )
        )

        let candidateShardIndex = try XCTUnwrap(
            fixture.executionPlan.shards.firstIndex(where: {
                $0.key.arm == .candidate
                    && $0.key.lane == .parallelXCTest
                    && $0.testIDs.count > 1
            })
        )
        let candidateShard = fixture.executionPlan.shards[
            candidateShardIndex
        ]
        let shortenedIDs = Array(candidateShard.testIDs.dropLast())
        let shortened = try PrimeValidationShardPlanV2.make(
            key: candidateShard.key,
            selectionMode: candidateShard.selectionMode,
            testIDs: shortenedIDs,
            filterPattern: try PrimeValidationShardPlannerV2.filterPattern(
                for: shortenedIDs
            )
        )
        var invalidPartitions = fixture.executionPlan.shards
        invalidPartitions[candidateShardIndex] = shortened
        XCTAssertThrowsError(
            try PrimeValidationShardPlannerV2.validateExactPartitions(
                invalidPartitions,
                inventory: fixture.executionPlan.inventory,
                expectedRunID: fixture.executionPlan.runID
            )
        )
    }

    private struct ShardMaterial {
        let start: PrimeValidationShardStartV2
        let receipt: PrimeValidationShardReceiptV2
    }

    private struct SyntheticAggregateFixture {
        let executionPlan: PrimeValidationExecutionPlanV2
        let executionPlanSHA256: String
    }

    private func content(_ value: String) -> PrimeValidationContentBinding {
        .init(data: Data(value.utf8))
    }

    private func assertAuthorityViolation<Value>(
        _ expression: @autoclosure () throws -> Value,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            _ = try expression()
            XCTFail("expected authority violation", file: file, line: line)
        } catch {
            XCTAssertEqual(
                error as? PrimeValidationDriverV2Error,
                .authorityViolation,
                file: file,
                line: line
            )
        }
    }

    private func frozenListData(name: String) throws -> Data {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: name, withExtension: "list")
        )
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }

    private func makeInventoryReceipt(
        intent: PrimeValidationRunIntentV2,
        build: PrimeValidationBuildReceiptV2,
        xctestData: Data,
        swiftTestingData: Data
    ) throws -> PrimeValidationInventoryReceiptV2 {
        let inventory = try PrimeValidationInventory.parse(
            xctestList: xctestData,
            swiftTestingList: swiftTestingData
        )
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(
            intent: intent
        )
        return PrimeValidationInventoryReceiptV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256:
                try build.identitySHA256(against: intent),
            invocations: invocations,
            observedChildren: [
                makeObservedChild(
                    invocation: invocations[0],
                    standardOutputData: xctestData,
                    matchedCount: inventory.xctestIDs.count
                ),
                makeObservedChild(
                    invocation: invocations[1],
                    standardOutputData: swiftTestingData,
                    matchedCount: inventory.swiftTestingIDs.count
                ),
            ],
            xctestListArtifact: .init(
                name: "xctest_list",
                relativePath: "inventory/xctest.list",
                content: .init(data: xctestData)
            ),
            swiftTestingListArtifact: .init(
                name: "swift_testing_list",
                relativePath: "inventory/swift-testing.list",
                content: .init(data: swiftTestingData)
            ),
            xctestListData: xctestData,
            swiftTestingListData: swiftTestingData,
            inventory: inventory,
            activeNanoseconds: 2
        )
    }

    private func directory(
        _ path: String,
        inode: UInt64,
        mode: UInt16
    ) -> PrimeValidationDirectoryBindingV2 {
        return .init(
            absolutePath: path,
            deviceID: 1,
            inode: inode,
            ownerUserID: 501,
            mode: mode
        )
    }

    private func makeRoots(
        workspace: PrimeValidationDirectoryBindingV2? = nil
    ) -> PrimeValidationDriverRootLayoutV2 {
        .init(
            repositoryRoot: directory(
                "/private/tmp/prime-v2-repository",
                inode: 10,
                mode: 0o755
            ),
            companionRoot: directory(
                "/private/tmp/prime-v2-companion",
                inode: 20,
                mode: 0o755
            ),
            workspaceRoot: workspace ?? directory(
                "/private/tmp/prime-v2-workspace",
                inode: 30,
                mode: 0o700
            ),
            evidenceRoot: directory(
                "/private/tmp/prime-v2-evidence",
                inode: 40,
                mode: 0o700
            ),
            scratchRelativePath: "root-release-build",
            cacheRelativePath: "cache",
            configRelativePath: "config",
            securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache",
            homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
            temporaryRelativePath: "tmp",
            outputRelativePath: "outputs"
        )
    }

    private func makeIntent(
        runID: String = "run-v2",
        companionCommit: String =
            PrimeValidationRunIntentV2.requiredCompanionCommit,
        metallib: PrimeValidationRequiredMetallibV2? = nil,
        roots: PrimeValidationDriverRootLayoutV2? = nil,
        environmentPolicy: PrimeValidationEnvironmentPolicyV2? = nil
    ) throws -> PrimeValidationRunIntentV2 {
        let actualRoots = roots ?? makeRoots()
        let actualMetallib = metallib ?? .init(
            relativePath:
                "root-release-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            content: content("pinned-metallib")
        )
        return PrimeValidationRunIntentV2(
            runID: runID,
            roots: actualRoots,
            sourceSnapshot: content("source-snapshot"),
            packageLock: content("package-lock"),
            driverExecutable: .init(
                absolutePath: "/private/tmp/prime-v2-driver",
                content: content("driver-executable")
            ),
            swiftExecutable: .init(
                absolutePath: "/usr/bin/swift",
                content: content("swift-executable")
            ),
            companionCommit: companionCommit,
            requiredPinnedMetallib: actualMetallib,
            baseline: .init(),
            phaseBudgets: PrimeValidationDriverPhaseV2.allCases.map {
                .init(phase: $0, maximumActiveNanoseconds: 1_000_000)
            },
            environmentPolicy: environmentPolicy
                ?? .make(
                    roots: actualRoots,
                    pinnedMetallib: actualMetallib
                ),
            optionalSkipPolicySHA256:
                try PrimeValidationOptionalSkipPolicy.identitySHA256()
        )
    }

    private func makeBundleTree() throws
        -> PrimeValidationBundleTreeBindingV2
    {
        try .make(
            entries: [
                .init(
                    relativePath: "Contents",
                    kind: .directory,
                    mode: 0o755,
                    content: nil
                ),
                .init(
                    relativePath: "Contents/Info.plist",
                    kind: .regularFile,
                    mode: 0o644,
                    content: content("plist")
                ),
                .init(
                    relativePath: "Contents/MacOS",
                    kind: .directory,
                    mode: 0o755,
                    content: nil
                ),
                .init(
                    relativePath: "Contents/MacOS/PrimeTests",
                    kind: .executable,
                    mode: 0o755,
                    content: content("test-executable")
                ),
            ]
        )
    }

    private func makeBuildReceipt(
        intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationBuildReceiptV2 {
        let invocation = try PrimeValidationInvocationFactoryV2.build(
            intent: intent
        )
        return PrimeValidationBuildReceiptV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            invocation: invocation,
            observedChild: makeObservedChild(
                invocation: invocation,
                matchedCount: 0
            ),
            sourceSnapshotAfterBuild: intent.sourceSnapshot,
            packageLockAfterBuild: intent.packageLock,
            pinnedMetallibAfterBuild: intent.requiredPinnedMetallib,
            testBundle: try makeBundleTree(),
            activeNanoseconds: 1
        )
    }

    private func makeObservedChild(
        invocation: PrimeValidationInvocationV2,
        standardOutputData: Data = Data(),
        standardErrorData: Data = Data(),
        primaryFileData: Data = Data(),
        matchedCount: Int
    ) -> PrimeValidationObservedChildReceiptV2 {
        let stdout = PrimeValidationDriverArtifactBindingV2(
            name: "standard_output",
            relativePath: invocation.standardOutputRelativePath,
            content: .init(data: standardOutputData)
        )
        let stderr = PrimeValidationDriverArtifactBindingV2(
            name: "standard_error",
            relativePath: invocation.standardErrorRelativePath,
            content: .init(data: standardErrorData)
        )
        let primary: PrimeValidationObservedPrimaryResultV2
        switch invocation.primaryResult {
        case .none:
            primary = .none
        case .standardOutput:
            primary = .standardOutput
        case let .file(relativePath):
            primary = .file(
                .init(
                    name: "primary_result",
                    relativePath: relativePath,
                    content: .init(data: primaryFileData)
                )
            )
        }
        return .init(
            invocation: invocation,
            primaryResult: primary,
            standardOutputArtifact: stdout,
            standardErrorArtifact: stderr,
            process: makeProcessAudit(
                stdout: stdout.content,
                stderr: stderr.content,
                matchedCount: matchedCount
            ),
            activeNanoseconds: 1
        )
    }

    private func makePhaseStart(
        intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationPhaseStartV2 {
        PrimeValidationPhaseStartV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: .sourceAdmission,
            phaseOrdinal: 0,
            predecessorTerminalSHA256: String(repeating: "0", count: 64)
        )
    }

    private func artifact(
        _ name: String,
        value: String = "artifact"
    ) -> PrimeValidationDriverArtifactBindingV2 {
        .init(
            name: name,
            relativePath: "evidence/" + name + ".data",
            content: content(value)
        )
    }

    private func makePhaseTerminal(
        start: PrimeValidationPhaseStartV2,
        intent: PrimeValidationRunIntentV2,
        disposition: PrimeValidationPhaseTerminalDispositionV2
    ) throws -> PrimeValidationPhaseTerminalReceiptV2 {
        PrimeValidationPhaseTerminalReceiptV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            phase: start.phase,
            phaseStartSHA256:
                try start.identitySHA256(against: intent),
            disposition: disposition,
            activeNanoseconds: 1,
            outputArtifacts: disposition == .succeeded
                ? [artifact("source")] : []
        )
    }

    private func makeProcessAudit(
        stdout: PrimeValidationContentBinding,
        stderr: PrimeValidationContentBinding,
        matchedCount: Int,
        termination: PrimeValidationWaitTerminationV2 = .exited(0),
        processGroupIdentifier: Int32 = 100
    ) -> PrimeValidationProcessAuditV2 {
        let rawWaitStatus: Int32
        switch termination {
        case let .exited(code):
            rawWaitStatus = code << 8
        case let .signaled(signal):
            rawWaitStatus = signal
        case .unobserved:
            rawWaitStatus = 0
        }
        return .init(
            processIdentifier: 100,
            sessionIdentifier: 100,
            processGroupIdentifier: processGroupIdentifier,
            deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: [100],
            exactReturnedProcessIdentifier:
                termination == .unobserved ? 0 : 100,
            rawWaitStatus: rawWaitStatus,
            waitTermination: termination,
            processGroupEmptyAfterReap: true,
            standardOutput: streamAudit(content: stdout),
            standardError: streamAudit(content: stderr),
            matchedTestCount: matchedCount
        )
    }

    private func streamAudit(
        content: PrimeValidationContentBinding
    ) -> PrimeValidationStreamAuditV2 {
        .init(
            eofObserved: true,
            totalByteCount: content.byteCount,
            capturedByteCount: content.byteCount,
            overflowObserved: false,
            readErrorNumber: 0,
            writeErrorNumber: 0
        )
    }

    private func makeShardMaterial() throws -> ShardMaterial {
        try makeShardMaterial(lane: .parallelXCTest)
    }

    private func makeShardMaterial(
        lane: PrimeValidationExecutionLane
    ) throws -> ShardMaterial {
        let runID = "run-shard"
        let planSHA = String(repeating: "a", count: 64)
        let inventory = try makeSmallInventory()
        let shard = try XCTUnwrap(
            PrimeValidationShardPlannerV2.plan(
                inventory: inventory,
                runID: runID
            ).first(where: {
                $0.key.arm == .candidate
                    && $0.key.lane == lane
            })
        )
        let start = PrimeValidationShardStartV2(
            runID: runID,
            executionPlanSHA256: planSHA,
            shard: shard
        )
        let stdoutData = Data("stdout".utf8)
        let stderrData = Data()
        let stdout = PrimeValidationDriverArtifactBindingV2(
            name: "standard_output",
            relativePath: "shards/stdout.log",
            content: .init(data: stdoutData)
        )
        let stderr = PrimeValidationDriverArtifactBindingV2(
            name: "standard_error",
            relativePath: "shards/stderr.log",
            content: .init(data: stderrData)
        )
        let results = shard.testIDs.map {
            PrimeValidationSemanticTestResultV2(
                testID: $0,
                terminal: .passed
            )
        }
        let receipt = PrimeValidationShardReceiptV2(
            runID: runID,
            executionPlanSHA256: planSHA,
            shardStartSHA256: try start.identitySHA256(
                expectedRunID: runID,
                expectedExecutionPlanSHA256: planSHA
            ),
            shardID: shard.shardID,
            disposition: .complete,
            incompleteReason: "",
            resultArtifact: .init(
                name: "result",
                relativePath: lane == .sequentialXCTest
                    ? stdout.relativePath : "shards/result.xml",
                content: lane == .sequentialXCTest
                    ? stdout.content : content("result")
            ),
            standardOutputArtifact: stdout,
            standardErrorArtifact: stderr,
            process: makeProcessAudit(
                stdout: stdout.content,
                stderr: stderr.content,
                matchedCount: shard.testIDs.count
            ),
            semanticResults: results,
            activeNanoseconds: 1
        )
        return .init(start: start, receipt: receipt)
    }

    private func makeSyntheticAggregateFixture() throws
        -> SyntheticAggregateFixture
    {
        let intent = try makeIntent(runID: "run-production-cardinality")
        let inventory = try makeProductionCardinalityInventory()
        let shards = try PrimeValidationShardPlannerV2.plan(
            inventory: inventory,
            runID: intent.runID
        )
        let invocations = try shards.map {
            try PrimeValidationInvocationFactoryV2.shard(
                intent: intent,
                shard: $0
            )
        }
        let plan = PrimeValidationExecutionPlanV2(
            runID: intent.runID,
            intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256: String(repeating: "a", count: 64),
            inventoryReceiptSHA256: String(repeating: "b", count: 64),
            baseline: intent.baseline,
            inventory: inventory,
            inventorySHA256: try inventory.identitySHA256(),
            maximumReferenceShardActiveNanoseconds: 1_000_000,
            maximumCandidateShardActiveNanoseconds: 1_000_000,
            shards: shards,
            shardInvocations: invocations
        )
        return .init(
            executionPlan: plan,
            executionPlanSHA256:
                try PrimeValidationDriverV2Validation.identity(plan)
        )
    }

    private func makeSyntheticShardEvidence(
        arm: PrimeValidationComparisonArmV2,
        fixture: SyntheticAggregateFixture,
        failFirstParallelTest: Bool = false
    ) throws -> [PrimeValidationShardEvidenceV2] {
        var didInjectFailure = false
        var evidence: [PrimeValidationShardEvidenceV2] = []
        for (index, shard) in fixture.executionPlan.shards.enumerated()
        where shard.key.arm == arm {
            let invocation = fixture.executionPlan.shardInvocations[index]
            let start = PrimeValidationShardStartV2(
                runID: fixture.executionPlan.runID,
                executionPlanSHA256: fixture.executionPlanSHA256,
                shard: shard
            )
            let stdout = PrimeValidationDriverArtifactBindingV2(
                name: "standard_output",
                relativePath: invocation.standardOutputRelativePath,
                content: content("stdout-" + shard.shardID)
            )
            let stderr = PrimeValidationDriverArtifactBindingV2(
                name: "standard_error",
                relativePath: invocation.standardErrorRelativePath,
                content: content("")
            )
            let result: PrimeValidationDriverArtifactBindingV2
            switch invocation.primaryResult {
            case .none:
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            case .standardOutput:
                result = .init(
                    name: "result",
                    relativePath: stdout.relativePath,
                    content: stdout.content
                )
            case let .file(relativePath):
                result = .init(
                    name: "result",
                    relativePath: relativePath,
                    content: content("result-" + shard.shardID)
                )
            }

            var semanticResults = shard.testIDs.map {
                PrimeValidationSemanticTestResultV2(
                    testID: $0,
                    terminal: .passed
                )
            }
            let injectFailure = failFirstParallelTest
                && !didInjectFailure
                && shard.key.lane == .parallelXCTest
            if injectFailure {
                semanticResults[0] = .init(
                    testID: semanticResults[0].testID,
                    terminal: .failed
                )
                didInjectFailure = true
            }
            let receipt = PrimeValidationShardReceiptV2(
                runID: fixture.executionPlan.runID,
                executionPlanSHA256: fixture.executionPlanSHA256,
                shardStartSHA256: try start.identitySHA256(
                    expectedRunID: fixture.executionPlan.runID,
                    expectedExecutionPlanSHA256:
                        fixture.executionPlanSHA256
                ),
                shardID: shard.shardID,
                disposition: .complete,
                incompleteReason: "",
                resultArtifact: result,
                standardOutputArtifact: stdout,
                standardErrorArtifact: stderr,
                process: makeProcessAudit(
                    stdout: stdout.content,
                    stderr: stderr.content,
                    matchedCount: shard.testIDs.count,
                    termination: injectFailure ? .exited(1) : .exited(0)
                ),
                semanticResults: semanticResults,
                activeNanoseconds: 1
            )
            evidence.append(.init(start: start, receipt: receipt))
        }
        return evidence
    }

    private func makeProductionCardinalityInventory() throws
        -> PrimeValidationInventory
    {
        let xctest = (0..<PrimeValidationBaselineAnchorV2.xctestCount)
            .map {
                String(
                    format:
                        "PrimeCoreTests.GeneratedSuite%04d/test%04d",
                    $0,
                    $0
                )
            }
            .joined(separator: "\n") + "\n"
        let swiftTesting = (
            0..<PrimeValidationBaselineAnchorV2.swiftTestingCount
        ).map {
            String(
                format:
                    "PrimeCoreTests.GeneratedSwiftSuite/test%04d()",
                $0
            )
        }.joined(separator: "\n") + "\n"
        return try .parse(
            xctestList: Data(xctest.utf8),
            swiftTestingList: Data(swiftTesting.utf8)
        )
    }

    private func makeSmallInventory() throws -> PrimeValidationInventory {
        let xctest = [
            "PrimeCoreTests.AlphaTests/testA",
            "PrimeCoreTests.AlphaTests/testB",
            "PrimeCoreTests.BetaTests/testC",
            PrimeValidationShardPolicyV2.slowV20Suite + "/testSlow",
        ].joined(separator: "\n") + "\n"
        let swiftTesting = [
            "PrimeCoreTests.SwiftSuite/testOne()",
            "PrimeCoreTests.SwiftSuite/testTwo()",
        ].joined(separator: "\n") + "\n"
        return try .parse(
            xctestList: Data(xctest.utf8),
            swiftTestingList: Data(swiftTesting.utf8)
        )
    }
}

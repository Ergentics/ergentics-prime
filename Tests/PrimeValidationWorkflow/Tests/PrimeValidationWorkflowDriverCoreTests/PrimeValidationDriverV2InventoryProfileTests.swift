// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Pure closed-profile, original-planner and parser regression fixtures.
/// Process fields and result bytes below are synthetic test data, never native
/// execution evidence. A named profile cannot be chosen from incoming bytes.
final class PrimeValidationDriverV2InventoryProfileTests: XCTestCase {
    private typealias Raw = PrimeValidationDriverV2BoundRawArtifact
    private typealias Profile = PrimeValidationDriverV2InventoryProfile
    private typealias BudgetProfile = PrimeValidationDriverV2ExecutionBudgetProfile
    private typealias AdmissionPolicy = PrimeValidationExecutorAdmissionPolicyV2

    func testHistoricalDefaultBaselineBytesAndFullPlanRemainIdentical() throws {
        let baseline = PrimeValidationBaselineAnchorV2()
        let expected = Data(#"{"expectedSwiftTestingCount":12,"expectedSwiftTestingListByteCount":1287,"expectedSwiftTestingListSHA256":"487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3","expectedXCTestCount":892,"expectedXCTestListByteCount":114186,"expectedXCTestListSHA256":"93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b"}"#.utf8)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(baseline), expected)
        let explicit = try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self, from: expected)
        try explicit.validate()
        XCTAssertEqual(resolve(explicit), .historical904)
        let implicit = try fixture(), frozen = try fixture(baseline: explicit)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(implicit.intent), try PrimeCanonicalJSON.encode(frozen.intent))
        XCTAssertEqual(try PrimeCanonicalJSON.encode(implicit.plan), try PrimeCanonicalJSON.encode(frozen.plan))
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: implicit.intent.runID, xctestData: implicit.inventory.xctestListData,
            swiftTestingData: implicit.inventory.swiftTestingListData)
        let explicitNative = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: implicit.intent.runID, xctestData: implicit.inventory.xctestListData,
            swiftTestingData: implicit.inventory.swiftTestingListData, profile: .historical904)
        XCTAssertEqual(native, explicitNative)
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(implicit.plan.shards))
        XCTAssertEqual(native.shards.count, 72)
    }

    func testNamedCurrentProfileAdmitsOnlyItsCompleteSixFieldTuple() throws {
        let current = PrimeValidationBaselineAnchorV2.currentSourceInventoryV1
        try current.validate()
        XCTAssertEqual(resolve(current), .currentSourceInventoryV1)
        XCTAssertNotEqual(current, .init())
        XCTAssertEqual(current.expectedXCTestCount, 1068)
        XCTAssertEqual(current.expectedSwiftTestingCount, 12)
        XCTAssertEqual(current.expectedXCTestListByteCount, 139244)
        XCTAssertEqual(current.expectedXCTestListSHA256, "7428f3e1ebc8e76eb312c54feac209d0c70d8d741e1eb38cbab8b1d5b815ece2")
        XCTAssertEqual(current.expectedSwiftTestingListByteCount, 1287)
        XCTAssertEqual(current.expectedSwiftTestingListSHA256, "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3")
        let object = try fields(current)
        XCTAssertEqual(Set(object.keys), Set(["expectedXCTestCount", "expectedSwiftTestingCount",
            "expectedXCTestListByteCount", "expectedXCTestListSHA256",
            "expectedSwiftTestingListByteCount", "expectedSwiftTestingListSHA256"]))
        XCTAssertNil(object["identifier"])
        XCTAssertEqual(try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self,
            from: PrimeCanonicalJSON.encode(current)), current)
    }

    func testEveryTupleFieldMutationRejectsBothNamedProfiles() throws {
        for baseline in [PrimeValidationBaselineAnchorV2(), .currentSourceInventoryV1] {
            let original = try fields(baseline)
            for key in original.keys.sorted() {
                var changed = original
                if key.hasSuffix("SHA256") { changed[key] = String(repeating: "0", count: 64) }
                else { changed[key] = try XCTUnwrap(original[key] as? NSNumber).uint64Value + 1 }
                let value = try decodeBaseline(changed)
                XCTAssertNil(resolve(value), key)
                XCTAssertThrowsError(try value.validate(), key) { error in
                    XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBaseline)
                }
            }
        }
    }

    func testHistoricalCurrentXCTestTupleHybridsAreRejected() throws {
        let historical = try fields(PrimeValidationBaselineAnchorV2())
        let current = try fields(PrimeValidationBaselineAnchorV2.currentSourceInventoryV1)
        let xKeys = ["expectedXCTestCount", "expectedXCTestListByteCount", "expectedXCTestListSHA256"]
        // The Swift Testing tuple is currently identical in both profiles;
        // merely substituting identical values cannot be a mixed-pair error.
        for mask in 1..<7 {
            var mixed = historical
            for (index, key) in xKeys.enumerated() where mask & (1 << index) != 0 { mixed[key] = current[key] }
            let value = try decodeBaseline(mixed)
            XCTAssertNil(resolve(value))
            XCTAssertThrowsError(try value.validate()) { error in
                XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBaseline)
            }
        }
    }

    func testProfileSelectionNeverFallsBackToObservedListBytes() throws {
        let old = try fixture()
        let current = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: old.intent.runID, xctestData: current.inventory.xctestListData,
            swiftTestingData: current.inventory.swiftTestingListData))
        XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: old.intent.runID, xctestData: old.inventory.xctestListData,
            swiftTestingData: old.inventory.swiftTestingListData, profile: .currentSourceInventoryV1))
        XCTAssertThrowsError(try fixture(baseline: .currentSourceInventoryV1, currentLists: false))
        XCTAssertThrowsError(try fixture(baseline: .init(), currentLists: true))
        for profile in [Profile.historical904, .currentSourceInventoryV1] {
            let f = profile == .historical904 ? old : current
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: f.intent.runID, xctestData: f.inventory.xctestListData + Data([10]),
                swiftTestingData: f.inventory.swiftTestingListData, profile: profile))
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: f.intent.runID, xctestData: f.inventory.xctestListData,
                swiftTestingData: f.inventory.swiftTestingListData + Data([10]), profile: profile))
        }
    }

    func testCurrentFullOriginalPlanAndNativeScheduleHaveExactByteParity() throws {
        let f = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        try f.plan.validate(intent: f.intent, buildReceipt: f.build, inventoryReceipt: f.inventory)
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: f.intent.runID, xctestData: f.inventory.xctestListData,
            swiftTestingData: f.inventory.swiftTestingListData, profile: .currentSourceInventoryV1)
        XCTAssertEqual(native.canonicalInventoryData, try PrimeCanonicalJSON.encode(f.plan.inventory))
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(f.plan.shards))
        XCTAssertEqual(native.shards.count, f.plan.shards.count)
        for index in f.plan.shards.indices {
            XCTAssertEqual(native.shards[index].ordinal, index + 1)
            XCTAssertEqual(native.shards[index].canonicalPlanData, try PrimeCanonicalJSON.encode(f.plan.shards[index]))
            XCTAssertEqual(native.shards[index].selectedIdentifiers, f.plan.shards[index].testIDs.map(\.rawValue))
            XCTAssertEqual(native.shards[index].shardID, f.plan.shards[index].shardID)
        }
        XCTAssertEqual(f.plan.inventory.xctestIDs.count, 1068)
        XCTAssertEqual(f.plan.inventory.swiftTestingIDs.count, 12)
        XCTAssertEqual(f.plan.shards.filter { $0.key.arm == .reference }.count, 3)
    }

    func testComparisonCountsComeFromCurrentValidatedPlan() throws {
        let f = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        let adapter = try f.adapter()
        let parsed = try f.plan.shards.indices.map { try admit(adapter, makeInput(f, index: $0)) }
        let conclusion = try adapter.conclude(parsed)
        XCTAssertEqual(conclusion.reference.disposition, .completePass)
        XCTAssertEqual(conclusion.candidate.disposition, .completePass)
        XCTAssertEqual(conclusion.comparison.expectedXCTestCount, 1068)
        XCTAssertEqual(conclusion.comparison.expectedSwiftTestingCount, 12)
        XCTAssertEqual(conclusion.reference.semanticResults.count, 1080)
        XCTAssertEqual(conclusion.candidate.semanticResults.count, 1080)
        XCTAssertEqual(conclusion.finalReceipt.authority, .frozenPlannerV2)
        // This is internal parser mechanics only; public completion stays shut.
        XCTAssertThrowsError(try conclusion.finalReceipt.validate(comparison: conclusion.comparison,
            reference: conclusion.reference, candidate: conclusion.candidate,
            executionPlan: f.plan, executionPlanSHA256: adapter.planSHA256))
    }

    func testNativeBaselineDecoderRejectsExtraKeysAndNonIntegerTupleValues() throws {
        for baseline in [PrimeValidationBaselineAnchorV2(), .currentSourceInventoryV1] {
            let data = try PrimeCanonicalJSON.encode(baseline)
            XCTAssertEqual(try Profile.resolve(canonicalBaselineData: data), resolve(baseline))
            let text = String(decoding: data, as: UTF8.self)
            let token = "\"expectedXCTestCount\":\(baseline.expectedXCTestCount)"
            for changedToken in ["\"expectedXCTestCount\":true", "\"expectedXCTestCount\":1.5",
                                 "\"expectedXCTestCount\":18446744073709551615"] {
                let changed = Data(text.replacingOccurrences(of: token, with: changedToken).utf8)
                XCTAssertNotEqual(changed, data)
                XCTAssertNil(try? Profile.resolve(canonicalBaselineData: changed))
            }
            let extraKey = Data((String(text.dropLast()) + ",\"extra\":1}").utf8)
            XCTAssertNil(try? Profile.resolve(canonicalBaselineData: extraKey))
            XCTAssertNil(try? Profile.resolve(canonicalBaselineData: data + Data([10])))
        }
    }

    func testExecutionBudgetHistoricalBytesAndFixtureDefaultsRemainUnchanged() throws {
        let expected = Data(#"[{"maximumActiveNanoseconds":900000000000,"phase":"build"},{"maximumActiveNanoseconds":1800000000000,"phase":"candidate_execution"},{"maximumActiveNanoseconds":60000000000,"phase":"comparison"},{"maximumActiveNanoseconds":30000000000,"phase":"execution_plan"},{"maximumActiveNanoseconds":300000000000,"phase":"inventory"},{"maximumActiveNanoseconds":30000000000,"phase":"publication"},{"maximumActiveNanoseconds":120000000000,"phase":"reconciliation"},{"maximumActiveNanoseconds":1800000000000,"phase":"reference_execution"},{"maximumActiveNanoseconds":30000000000,"phase":"source_admission"}]"#.utf8)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(AdmissionPolicy.frozenV1.phaseBudgets), expected)
        XCTAssertEqual(try BudgetProfile.frozenV1.canonicalPhaseBudgetsData, expected)
        XCTAssertEqual(try BudgetProfile.resolve(canonicalPhaseBudgetsData: expected), .frozenV1)
        XCTAssertEqual(try AdmissionPolicy.frozenV1.executionBudgetProfile, .frozenV1)
        XCTAssertEqual(try BudgetProfile.frozenV1.outerMaximumActiveNanoseconds, 5_100_000_000_000)
        XCTAssertEqual(PrimeValidationDriverV2TerminalGate.gateHOuterDurationNanoseconds, 5_100_000_000_000)
        let unchanged = try fixture()
        XCTAssertEqual(unchanged.intent.baseline, .init())
        XCTAssertTrue(unchanged.intent.phaseBudgets.allSatisfy { $0.maximumActiveNanoseconds == 1_000_000 })
        XCTAssertEqual(unchanged.intent.roots.temporaryRelativePath, "tmp")
        XCTAssertEqual(unchanged.intent.roots.outputRelativePath, "outputs")
        XCTAssertEqual(unchanged.intent.swiftExecutable.absolutePath, "/usr/bin/swift")
        let full = try fixture(admissionPolicy: .frozenV1)
        XCTAssertEqual(try AdmissionPolicy.selected(for: full.intent), .frozenV1)
        let implicit = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: full.intent,
            leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease")
        let explicit = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: full.intent,
            leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease", terminalGate: .gateE)
        try implicit.validate(); try explicit.validate()
        XCTAssertEqual(try PrimeCanonicalJSON.encode(implicit), try PrimeCanonicalJSON.encode(explicit))
        let request = try budgetObject(implicit)
        XCTAssertNil(request["terminal_gate"])
        XCTAssertNil(request["execution_go_scope_data"])
        XCTAssertNil(request["accepted_capsule_sha256"])
    }

    func testExecutionBudgetProfilesRequireTheWholeNinePhaseTuple() throws {
        XCTAssertEqual(BudgetProfile.allCases, [.frozenV1, .currentSourceExecutionV1])
        for policy in [AdmissionPolicy.frozenV1, .currentSourceExecutionV1] {
            let profile = try policy.executionBudgetProfile
            let data = try PrimeCanonicalJSON.encode(policy.phaseBudgets)
            XCTAssertEqual(policy.phaseBudgets.count, 9)
            XCTAssertEqual(Set(policy.phaseBudgets.map(\.phase)), Set(PrimeValidationDriverPhaseV2.allCases))
            XCTAssertEqual(data, try profile.canonicalPhaseBudgetsData)
            XCTAssertEqual(try BudgetProfile.resolve(canonicalPhaseBudgetsData: data), profile)
            for budget in policy.phaseBudgets {
                XCTAssertEqual(try profile.maximumActiveNanoseconds(phase: budget.phase.rawValue), budget.maximumActiveNanoseconds)
            }
            for index in policy.phaseBudgets.indices {
                for value in [UInt64(0), policy.phaseBudgets[index].maximumActiveNanoseconds + 1, UInt64.max] {
                    var changed = policy.phaseBudgets
                    changed[index] = .init(phase: changed[index].phase, maximumActiveNanoseconds: value)
                    XCTAssertThrowsError(try BudgetProfile.resolve(canonicalPhaseBudgetsData: PrimeCanonicalJSON.encode(changed)))
                }
            }
            for phase in [PrimeValidationDriverPhaseV2.referenceExecution, .candidateExecution] {
                let mixed = policy.phaseBudgets.map { budget in
                    PrimeValidationPhaseBudgetV2(phase: budget.phase, maximumActiveNanoseconds:
                        budget.phase == phase ? (profile == .frozenV1 ? 10_800_000_000_000 : 1_800_000_000_000)
                            : budget.maximumActiveNanoseconds)
                }
                XCTAssertThrowsError(try BudgetProfile.resolve(canonicalPhaseBudgetsData: PrimeCanonicalJSON.encode(mixed)))
            }
            XCTAssertThrowsError(try profile.maximumActiveNanoseconds(phase: "unknown"))
        }
        let old = AdmissionPolicy.frozenV1.phaseBudgets, current = AdmissionPolicy.currentSourceExecutionV1.phaseBudgets
        XCTAssertEqual(zip(old, current).filter { $0.0 != $0.1 }.map { $0.0.phase }, [.candidateExecution, .referenceExecution])
        XCTAssertEqual(try BudgetProfile.currentSourceExecutionV1.outerMaximumActiveNanoseconds, 23_100_000_000_000)
    }

    func testExecutionBudgetDecoderRejectsDuplicateUnknownNoncanonicalAndNonintegerValues() throws {
        for profile in BudgetProfile.allCases {
            let data = try profile.canonicalPhaseBudgetsData
            let rows = try JSONDecoder().decode([PrimeValidationPhaseBudgetV2].self, from: data)
            var duplicate = rows; duplicate[1] = duplicate[0]
            for changed in [try PrimeCanonicalJSON.encode(duplicate),
                            try PrimeCanonicalJSON.encode(Array(rows.dropLast())),
                            try PrimeCanonicalJSON.encode(rows + [rows[0]]),
                            try PrimeCanonicalJSON.encode(Array(rows.reversed())),
                            Data([32]) + data, data + Data([10])] {
                XCTAssertThrowsError(try BudgetProfile.resolve(canonicalPhaseBudgetsData: changed))
            }
            let text = String(decoding: data, as: UTF8.self)
            let token = "\"maximumActiveNanoseconds\":900000000000"
            for value in ["true", "false", "900000000000.0", "9e11", "-1", "18446744073709551615",
                          "18446744073709551616", "\"900000000000\"", "null"] {
                let changed = Data(text.replacingOccurrences(of: token, with: "\"maximumActiveNanoseconds\":" + value).utf8)
                XCTAssertNotEqual(changed, data)
                XCTAssertThrowsError(try BudgetProfile.resolve(canonicalPhaseBudgetsData: changed), value)
            }
            for replacement in ["\"phase\":\"unknown\"", "\"phase\":\"build\",\"phase\":\"build\"",
                                "\"extra\":1,\"phase\":\"build\""] {
                let changed = Data(text.replacingOccurrences(of: "\"phase\":\"build\"", with: replacement).utf8)
                XCTAssertThrowsError(try BudgetProfile.resolve(canonicalPhaseBudgetsData: changed))
            }
        }
    }

    func testExecutionBudgetCurrentSelectionRequiresAnExplicitCurrentInventoryIntent() throws {
        let old = try fixture(admissionPolicy: .frozenV1)
        let currentListsOldBudget = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .frozenV1)
        let current = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .currentSourceExecutionV1)
        XCTAssertEqual(current.inventory.xctestListData, currentListsOldBudget.inventory.xctestListData)
        XCTAssertEqual(current.inventory.swiftTestingListData, currentListsOldBudget.inventory.swiftTestingListData)
        // Identical native-shaped list data never chooses a larger allowance.
        for f in [old, currentListsOldBudget] {
            XCTAssertEqual(try BudgetProfile.resolve(canonicalIntentData: PrimeCanonicalJSON.encode(f.intent)), .frozenV1)
            XCTAssertEqual(try AdmissionPolicy.selected(for: f.intent), .frozenV1)
        }
        XCTAssertEqual(try BudgetProfile.resolve(canonicalIntentData: PrimeCanonicalJSON.encode(current.intent)), .currentSourceExecutionV1)
        XCTAssertEqual(try AdmissionPolicy.selected(for: current.intent), .currentSourceExecutionV1)
        XCTAssertThrowsError(try AdmissionPolicy.frozenV1.validate(intent: current.intent))
        XCTAssertThrowsError(try AdmissionPolicy.currentSourceExecutionV1.validate(intent: currentListsOldBudget.intent))
        var fields = try budgetObject(current.intent)
        fields["baseline"] = try budgetObject(PrimeValidationBaselineAnchorV2())
        let wrongInventory: PrimeValidationRunIntentV2 = try budgetDecode(fields)
        XCTAssertThrowsError(try BudgetProfile.resolve(canonicalIntentData: PrimeCanonicalJSON.encode(wrongInventory)))
        XCTAssertThrowsError(try AdmissionPolicy.selected(for: wrongInventory))
        for key in ["baseline", "phaseBudgets"] {
            var missing = try budgetObject(current.intent); missing.removeValue(forKey: key)
            XCTAssertThrowsError(try BudgetProfile.resolve(canonicalIntentData: HJSON.encode(missing)))
        }
        let data = try PrimeCanonicalJSON.encode(current.intent)
        let text = String(decoding: data, as: UTF8.self)
        for value in ["true", "10800000000000.0", "1.08e13", "18446744073709551616"] {
            let changed = Data(text.replacingOccurrences(of: "\"maximumActiveNanoseconds\":10800000000000",
                with: "\"maximumActiveNanoseconds\":" + value).utf8)
            XCTAssertNotEqual(changed, data)
            XCTAssertThrowsError(try BudgetProfile.resolve(canonicalIntentData: changed), value)
        }
        XCTAssertThrowsError(try BudgetProfile.resolve(canonicalIntentData: data + Data([10])))
    }

    func testExecutionBudgetChangesOnlyPlanBindingsAndCapsNotShardsOrPhysicalInvocations() throws {
        let old = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .frozenV1)
        let current = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .currentSourceExecutionV1)
        try old.plan.validate(intent: old.intent, buildReceipt: old.build, inventoryReceipt: old.inventory)
        try current.plan.validate(intent: current.intent, buildReceipt: current.build, inventoryReceipt: current.inventory)
        XCTAssertEqual(old.plan.shards, current.plan.shards)
        XCTAssertEqual(old.plan.shardInvocations, current.plan.shardInvocations)
        XCTAssertEqual(old.plan.inventory, current.plan.inventory)
        XCTAssertEqual(current.plan.shards.filter { $0.key.arm == .reference }.count, 3)
        XCTAssertEqual(current.plan.shards.filter { $0.key.arm == .candidate }.count, 81)
        XCTAssertEqual(old.plan.maximumReferenceShardActiveNanoseconds, 1_800_000_000_000)
        XCTAssertEqual(old.plan.maximumCandidateShardActiveNanoseconds, 1_800_000_000_000)
        XCTAssertEqual(current.plan.maximumReferenceShardActiveNanoseconds, 10_800_000_000_000)
        XCTAssertEqual(current.plan.maximumCandidateShardActiveNanoseconds, 10_800_000_000_000)
        XCTAssertNotEqual(try old.intent.identitySHA256(), try current.intent.identitySHA256())
        XCTAssertNotEqual(try PrimeCanonicalJSON.encode(old.plan), try PrimeCanonicalJSON.encode(current.plan))
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(runID: current.intent.runID,
            xctestData: current.inventory.xctestListData, swiftTestingData: current.inventory.swiftTestingListData,
            profile: .currentSourceInventoryV1)
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(current.plan.shards))
        let prefix = PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix
        for index in current.plan.shards.indices {
            try PrimeValidationDriverV2NativeExecutionValidation.validateShardProjection(native.shards[index],
                original: current.plan.shards[index], index: index)
            let before = prefix + Array(old.plan.shardInvocations[index].arguments.dropFirst())
            let after = prefix + Array(current.plan.shardInvocations[index].arguments.dropFirst())
            XCTAssertEqual(before, after)
            XCTAssertEqual(try PrimeValidationDriverV2ClosedExecutionPolicy.originalLogicalArguments(physical: after),
                current.plan.shardInvocations[index].arguments)
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedExecutionPolicy.originalLogicalArguments(
                physical: Array(after.dropFirst(prefix.count))))
        }
        var oldFields = try budgetObject(old.plan), currentFields = try budgetObject(current.plan)
        for key in ["intentSHA256", "buildReceiptSHA256", "inventoryReceiptSHA256",
                    "maximumReferenceShardActiveNanoseconds", "maximumCandidateShardActiveNanoseconds"] {
            XCTAssertNotEqual(try HJSON.encode([oldFields[key]!]), try HJSON.encode([currentFields[key]!]), key)
            oldFields.removeValue(forKey: key); currentFields.removeValue(forKey: key)
        }
        XCTAssertEqual(try HJSON.encode(oldFields), try HJSON.encode(currentFields))
    }

    func testExecutionBudgetCurrentHScopeAndRequestAreExplicitAndEarlierGatesReject() throws {
        let old = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .frozenV1)
        let current = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .currentSourceExecutionV1)
        for f in [old, current] {
            let scope = try budgetScope(f.intent), data = try PrimeCanonicalJSON.encode(scope)
            try scope.validate(intent: f.intent)
            try PrimeValidationDriverV2ExecutionGoScope.validate(data, intentData: PrimeCanonicalJSON.encode(f.intent),
                retainedSourceIdentitySHA256: String(repeating: "e", count: 64))
            let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: f.intent,
                leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease", terminalGate: .gateH,
                executionGoScopeData: data, acceptedCapsuleSHA256: String(repeating: "c", count: 64))
            try request.validate()
            let roundTrip = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
                from: PrimeCanonicalJSON.encode(request))
            XCTAssertEqual(roundTrip, request); try roundTrip.validate()
        }
        let currentScope = try budgetScope(current.intent)
        XCTAssertEqual(currentScope.referenceMaximumActiveNanoseconds, 10_800_000_000_000)
        XCTAssertEqual(currentScope.candidateMaximumActiveNanoseconds, 10_800_000_000_000)
        XCTAssertThrowsError(try budgetScope(old.intent).validate(intent: current.intent))
        for key in ["referenceMaximumActiveNanoseconds", "candidateMaximumActiveNanoseconds"] {
            for value in [UInt64(1_800_000_000_000), 10_800_000_000_001, UInt64.max] {
                var fields = try budgetObject(currentScope); fields[key] = value
                let changed: PrimeValidationDriverV2DeclaredExecutionScopeV1 = try budgetDecode(fields)
                XCTAssertThrowsError(try changed.validate(intent: current.intent))
                XCTAssertThrowsError(try PrimeValidationDriverV2ExecutionGoScope.validate(PrimeCanonicalJSON.encode(changed),
                    intentData: PrimeCanonicalJSON.encode(current.intent), retainedSourceIdentitySHA256: String(repeating: "e", count: 64)))
            }
        }
        for gate in [PrimeValidationDriverV2TerminalGate.gateE, .gateF, .gateG] {
            let earlier = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: old.intent,
                leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease", terminalGate: gate)
            XCTAssertNoThrow(try earlier.validate())
            XCTAssertThrowsError(try PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: current.intent,
                leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease", terminalGate: gate).validate())
        }
        XCTAssertThrowsError(try PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: current.intent,
            leaseDirectoryAbsolutePath: "/private/tmp/h-budget-lease", terminalGate: .gateH).validate())
        XCTAssertEqual(try PrimeValidationDriverV2TerminalGate.gateHOuterDurationNanoseconds(intent: old.intent), 5_100_000_000_000)
        XCTAssertEqual(try PrimeValidationDriverV2TerminalGate.gateHOuterDurationNanoseconds(intent: current.intent), 23_100_000_000_000)
    }

    func testExecutionBudgetDurableHOuterBoundIsExactAndDoesNotRelaxEarlierGates() throws {
        let intent = try fixture(baseline: .currentSourceInventoryV1, currentLists: true,
            admissionPolicy: .currentSourceExecutionV1).intent
        func check(_ gate: PrimeValidationDriverV2TerminalGate, duration: UInt64, waitOffset: UInt64,
            admitted: Bool, start: UInt64 = 1000) throws {
            let expectation = PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2(intent: intent,
                repositoryCommit: String(repeating: "a", count: 40), sourceIdentitySHA256: String(repeating: "b", count: 64),
                journalRoot: .init(absolutePath: intent.roots.workspaceRoot.absolutePath + ".driver-v2-gate-e-journal",
                    deviceID: 1, inode: 50, ownerUserID: 501, mode: 0o700),
                leaseRoot: .init(absolutePath: "/private/tmp/h-budget-lease", deviceID: 1, inode: 60, ownerUserID: 501, mode: 0o700),
                gitExecutable: .init(absolutePath: "/usr/bin/git", content: .init(data: Data([1]))),
                swiftFrontendExecutable: .init(
                    absolutePath: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend",
                    content: intent.swiftExecutable.content),
                supervisorExecutableVnode: .init(deviceID: 1, inode: 100), gitExecutableVnode: .init(deviceID: 1, inode: 101),
                swiftFrontendExecutableVnode: .init(deviceID: 1, inode: 102), supervisorProcessIdentifier: 99,
                outerDeadlineStartedAtUptimeNanoseconds: start,
                outerDeadlineExpiresAtUptimeNanoseconds: start.addingReportingOverflow(duration).partialValue,
                terminalGate: gate)
            let witness = PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2(requestedProcessIdentifier: 99,
                returnedProcessIdentifier: 99, waitOptions: 0, rawWaitStatus: 0,
                returnedAtUptimeNanoseconds: start.addingReportingOverflow(waitOffset).partialValue,
                exitedNormally: true, exitStatus: 0, terminationSignal: 0, coreDumped: false)
            // This checks only the actual expectation boundary. Empty leaves
            // always fail; reaching leaf_order never claims a native pass.
            XCTAssertThrowsError(try PrimeValidationDriverV2FixedProbeDurableJournalValidatorV2.validate(
                orderedLeaves: [], expectation: expectation, supervisorExit: witness)) { error in
                if admitted {
                    XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBinding("fixed_probe_durable_journal_leaf_order"))
                } else {
                    XCTAssertNotEqual(error as? PrimeValidationDriverV2Error, .invalidBinding("fixed_probe_durable_journal_leaf_order"))
                }
            }
        }
        try check(.gateH, duration: 23_100_000_000_000, waitOffset: 5_100_000_000_001, admitted: true)
        try check(.gateH, duration: 23_100_000_000_000, waitOffset: 23_100_000_000_000, admitted: true)
        for duration in [UInt64(5_100_000_000_000), 23_099_999_999_999, 23_100_000_000_001] {
            try check(.gateH, duration: duration, waitOffset: 1, admitted: false)
        }
        try check(.gateH, duration: 23_100_000_000_000, waitOffset: 23_100_000_000_001, admitted: false)
        try check(.gateH, duration: 23_100_000_000_000, waitOffset: 0, admitted: false, start: UInt64.max)
        for (gate, duration) in [(PrimeValidationDriverV2TerminalGate.gateE, UInt64(60_000_000_000)),
            (.gateF, 960_000_000_000), (.gateG, 1_260_000_000_000)] {
            try check(gate, duration: duration, waitOffset: 1, admitted: false)
        }
    }

    func testExecutionBudgetSharedArmDeadlineCannotResetAtAShardBoundary() throws {
        for profile in BudgetProfile.allCases {
            let start: UInt64 = 1000, duration = profile.executionArmMaximumActiveNanoseconds
            let deadline = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: start, durationNanoseconds: duration)
            let firstTerminal = start + duration / 2, secondTerminal = start + duration + 1
            XCTAssertTrue(try deadline.authorizesNewWork(observedAtUptimeNanoseconds: start))
            XCTAssertTrue(try deadline.acceptsCompletion(observedAtUptimeNanoseconds: firstTerminal))
            XCTAssertTrue(try deadline.authorizesNewWork(observedAtUptimeNanoseconds: firstTerminal, notBeforeUptimeNanoseconds: start))
            // Each interval fits individually; their shared arm interval does not.
            XCTAssertLessThan(secondTerminal - firstTerminal, duration)
            XCTAssertFalse(try deadline.acceptsCompletion(observedAtUptimeNanoseconds: secondTerminal,
                notBeforeUptimeNanoseconds: firstTerminal))
            XCTAssertEqual(deadline.startUptimeNanoseconds, start)
            XCTAssertEqual(deadline.expiresAtUptimeNanoseconds, start + duration)
            XCTAssertFalse(try deadline.authorizesNewWork(observedAtUptimeNanoseconds: start + duration))
            XCTAssertTrue(try deadline.acceptsCompletion(observedAtUptimeNanoseconds: start + duration))
            XCTAssertThrowsError(try deadline.authorizesNewWork(observedAtUptimeNanoseconds: firstTerminal - 1,
                notBeforeUptimeNanoseconds: firstTerminal))
            XCTAssertThrowsError(try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: UInt64.max - duration + 1,
                durationNanoseconds: duration))
            XCTAssertThrowsError(try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: UInt64.max - duration,
                durationNanoseconds: duration))
        }
    }

    func testExecutionBudgetCurrentChildProjectionRetainsSelectedProfileAndSharedOrigin() throws {
        let f = try fixture(baseline: .currentSourceInventoryV1, currentLists: true, admissionPolicy: .currentSourceExecutionV1)
        let invocation = f.plan.shardInvocations[1]
        let profile = BudgetProfile.currentSourceExecutionV1
        let fields = budgetProcessFields(invocation: invocation)
        let process: PrimeValidationDriverV2BuildProcessObservation = try budgetDecode(fields)
        let stdout = artifact("standard_output", invocation.standardOutputRelativePath, Data())
        let stderr = artifact("standard_error", invocation.standardErrorRelativePath, Data())
        let child = try PrimeValidationDriverV2NativeExecutionValidation.makeChild(invocation: invocation,
            primary: .standardOutput, process: process, intervalStartedAt: 1000, matchedCount: 1068,
            stdout: stdout, stderr: stderr, supervisorPID: 99, budgetProfile: profile)
        XCTAssertGreaterThan(child.activeNanoseconds, BudgetProfile.frozenV1.executionArmMaximumActiveNanoseconds)
        XCTAssertEqual(child.process.sessionIdentifier, 99)
        XCTAssertEqual(child.process.supervisorSessionIdentifier, 99)
        try child.validate(expectedInvocation: invocation, maximumActiveNanoseconds: profile.executionArmMaximumActiveNanoseconds)
        XCTAssertThrowsError(try PrimeValidationDriverV2NativeExecutionValidation.makeChild(invocation: invocation,
            primary: .standardOutput, process: process, intervalStartedAt: 1000, matchedCount: 1068,
            stdout: stdout, stderr: stderr, supervisorPID: 99))
        var expired = fields
        expired["waitReturnedUptimeNanoseconds"] = process.deadlineExpiresAtUptimeNanoseconds
        let expiredProcess: PrimeValidationDriverV2BuildProcessObservation = try budgetDecode(expired)
        XCTAssertThrowsError(try PrimeValidationDriverV2NativeExecutionValidation.makeChild(invocation: invocation,
            primary: .standardOutput, process: expiredProcess,
            intervalStartedAt: process.deadlineExpiresAtUptimeNanoseconds - 100, matchedCount: 1068,
            stdout: stdout, stderr: stderr, supervisorPID: 99, budgetProfile: profile))
    }

    private func budgetObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(value)) as? [String: Any])
    }
    private func budgetDecode<T: Codable>(_ fields: [String: Any]) throws -> T {
        let value = try JSONDecoder().decode(T.self, from: HJSON.encode(fields))
        return try PrimeCanonicalJSON.decode(T.self, from: PrimeCanonicalJSON.encode(value))
    }
    private func budgetScope(_ intent: PrimeValidationRunIntentV2) throws -> PrimeValidationDriverV2DeclaredExecutionScopeV1 {
        try .init(intent: intent, sourceCommit: String(repeating: "a", count: 40), sourceTree: String(repeating: "b", count: 40),
            sourceTreeReplaySHA256: String(repeating: "d", count: 64), sourceIdentitySHA256: String(repeating: "e", count: 64),
            governorExecutable: .init(absolutePath: "/private/tmp/h-budget-governor", content: .init(data: Data("governor".utf8))),
            supervisorExecutable: intent.driverExecutable)
    }
    private func budgetProcessFields(invocation: PrimeValidationInvocationV2) -> [String: Any] {
        func stream(_ inode: UInt64) -> [String: Any] {
            ["reachedEOF": true, "overflowed": false, "workerFinished": true, "descriptorsClosed": true,
             "readErrorNumber": 0, "writeErrorNumber": 0, "finalizationErrorNumber": 0, "closeErrorNumber": 0,
             "outputMetadataObserved": true, "outputPermissionMode": 0o444, "outputDeviceID": 1, "outputInode": inode,
             "totalByteCount": 0, "capturedByteCount": 0, "outputByteCount": 0,
             "outputSHA256": PrimeSHA256.hexDigest(of: Data()), "terminalReason": "end_of_file"]
        }
        return ["logicalArgumentZero": "swift-test",
            "physicalArgumentZero": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-test",
            "arguments": PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix + Array(invocation.arguments.dropFirst()),
            "orderedEnvironment": invocation.orderedEnvironment.map { [$0.key, $0.value] },
            "workingDirectoryAbsolutePath": invocation.workingDirectoryAbsolutePath, "workingDirectoryDeviceID": 1, "workingDirectoryInode": 10,
            "executableAbsolutePath": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
            "executableDeviceID": 1, "executableInode": 11, "executableByteCount": 1, "executableSHA256": PrimeSHA256.hexDigest(of: Data([1])),
            "mappedImageJoined": true, "exactSuspendedWorkingDirectoryJoin": true,
            "processIdentifier": 101, "sessionIdentifier": 99, "parentProcessIdentifier": 99, "processGroupIdentifier": 101,
            "appliedSpawnFlags": 16_526, "spawnReturnCode": 0,
            "deadlineStartedAtUptimeNanoseconds": 1000, "deadlineExpiresAtUptimeNanoseconds": UInt64(10_800_000_001_000),
            "spawnReturnedUptimeNanoseconds": 1100, "resumedAtUptimeNanoseconds": 1200,
            "deathObservedUptimeNanoseconds": UInt64(1_800_000_002_000), "waitReturnedUptimeNanoseconds": UInt64(1_800_000_002_100),
            "preReapProcessGroupMemberIdentifiers": [101], "requestedWaitProcessIdentifier": 101, "returnedWaitProcessIdentifier": 101,
            "exactReapCount": 1, "cleanupInitiated": false, "waitOptions": 0, "rawWaitStatus": 0, "exitStatus": 0,
            "terminationSignal": 0, "exitedNormally": true, "coreDumped": false, "processGroupEmptyAfterReap": true,
            "standardOutput": stream(201), "standardError": stream(202)]
    }

    private func resolve(_ b: PrimeValidationBaselineAnchorV2) -> Profile? {
        Profile.resolve(expectedXCTestCount: b.expectedXCTestCount,
            expectedSwiftTestingCount: b.expectedSwiftTestingCount,
            expectedXCTestListByteCount: b.expectedXCTestListByteCount,
            expectedXCTestListSHA256: b.expectedXCTestListSHA256,
            expectedSwiftTestingListByteCount: b.expectedSwiftTestingListByteCount,
            expectedSwiftTestingListSHA256: b.expectedSwiftTestingListSHA256)
    }
    private func fields(_ b: PrimeValidationBaselineAnchorV2) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(b)) as? [String: Any])
    }
    private func decodeBaseline(_ object: [String: Any]) throws -> PrimeValidationBaselineAnchorV2 {
        let value = try JSONDecoder().decode(PrimeValidationBaselineAnchorV2.self,
            from: JSONSerialization.data(withJSONObject: object))
        return try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self,
            from: PrimeCanonicalJSON.encode(value))
    }

    private struct Fixture {
        let intent: PrimeValidationRunIntentV2
        let build: PrimeValidationBuildReceiptV2
        let inventory: PrimeValidationInventoryReceiptV2
        let plan: PrimeValidationExecutionPlanV2
        func adapter() throws -> PrimeValidationDriverV2ExecutionBinding {
            try .init(intent: intent, build: build, inventory: inventory, plan: plan)
        }
    }
    private struct Input {
        let start: PrimeValidationShardStartV2
        let child: PrimeValidationObservedChildReceiptV2
        let result: Raw
        let stdout: Raw
        let stderr: Raw
    }
    private func admit(_ adapter: PrimeValidationDriverV2ExecutionBinding, _ input: Input) throws
        -> PrimeValidationDriverV2ParsedShardEvidence {
        try adapter.admit(start: input.start, observedChild: input.child, result: input.result,
            standardOutput: input.stdout, standardError: input.stderr)
    }
    private func makeInput(_ f: Fixture, index: Int, failing: String? = nil,
                       skipping: String? = nil, reason: String = "") throws -> Input {
        let shard = f.plan.shards[index], invocation = f.plan.shardInvocations[index]
        let ids = shard.testIDs.map(\.rawValue)
        let data = shard.key.lane == .sequentialXCTest
            ? transcript(ids, failing: failing, skipping: skipping, reason: reason, selected: shard.selectionMode == .exactFilter)
            : xml(ids, failures: failing.map { Set([$0]) } ?? [], skips: skipping.map { [$0: reason] } ?? [:])
        let stdout = shard.key.lane == .sequentialXCTest ? data : Data("bounded transcript\n".utf8)
        let child = observed(invocation, stdout: stdout, result: data,
            matched: ids.count, exit: failing == nil ? 0 : 1)
        let path: String
        switch invocation.primaryResult {
        case .standardOutput: path = invocation.standardOutputRelativePath
        case let .file(value): path = value
        case .none: throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        return try .init(start: .init(runID: f.plan.runID,
            executionPlanSHA256: f.plan.identitySHA256(intent: f.intent, buildReceipt: f.build, inventoryReceipt: f.inventory),
            shard: shard), child: child,
            result: raw("result", path, data),
            stdout: raw("standard_output", invocation.standardOutputRelativePath, stdout),
            stderr: raw("standard_error", invocation.standardErrorRelativePath, Data()))
    }

    private func fixture(baseline: PrimeValidationBaselineAnchorV2 = .init(), currentLists: Bool = false,
        admissionPolicy: AdmissionPolicy? = nil) throws -> Fixture {
        func directory(_ name: String, _ inode: UInt64, _ mode: UInt16) -> PrimeValidationDirectoryBindingV2 {
            .init(absolutePath: "/private/tmp/h-parser-" + name, deviceID: 1, inode: inode, ownerUserID: 501, mode: mode)
        }
        let roots = PrimeValidationDriverRootLayoutV2(repositoryRoot: directory("source", 10, 0o755),
            companionRoot: directory("companion", 20, 0o755), workspaceRoot: directory("workspace", 30, 0o700),
            evidenceRoot: directory("evidence", 40, 0o700), scratchRelativePath: "root-release-build",
            cacheRelativePath: "cache", configRelativePath: "config", securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache", homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
            temporaryRelativePath: admissionPolicy?.temporaryRelativePath ?? "tmp",
            outputRelativePath: admissionPolicy?.outputRelativePath ?? "outputs")
        let metal = PrimeValidationRequiredMetallibV2(
            relativePath: "root-release-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            content: .init(data: Data("fixture metal".utf8)))
        let intent = PrimeValidationRunIntentV2(runID: "run-h-parser-fixture", roots: roots,
            sourceSnapshot: .init(data: Data("source".utf8)), packageLock: .init(data: Data("lock".utf8)),
            driverExecutable: .init(absolutePath: "/private/tmp/h-parser-driver", content: .init(data: Data("driver".utf8))),
            swiftExecutable: .init(absolutePath: admissionPolicy == nil ? "/usr/bin/swift"
                : "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift",
                content: .init(data: Data("swift".utf8))),
            companionCommit: PrimeValidationRunIntentV2.requiredCompanionCommit, requiredPinnedMetallib: metal,
            baseline: baseline, phaseBudgets: admissionPolicy?.phaseBudgets ?? PrimeValidationDriverPhaseV2.allCases.map {
                .init(phase: $0, maximumActiveNanoseconds: 1_000_000)
            }, environmentPolicy: .make(roots: roots, pinnedMetallib: metal),
            optionalSkipPolicySHA256: try PrimeValidationOptionalSkipPolicy.identitySHA256())
        let buildInvocation = try PrimeValidationInvocationFactoryV2.build(intent: intent)
        let tree = try PrimeValidationBundleTreeBindingV2.make(entries: [
            .init(relativePath: "Contents", kind: .directory, mode: 0o755, content: nil),
            .init(relativePath: "Contents/Info.plist", kind: .regularFile, mode: 0o644, content: .init(data: Data("plist".utf8))),
            .init(relativePath: "Contents/MacOS", kind: .directory, mode: 0o755, content: nil),
            .init(relativePath: "Contents/MacOS/PrimeTests", kind: .executable, mode: 0o755, content: .init(data: Data("test".utf8))),
        ])
        let build = PrimeValidationBuildReceiptV2(runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            invocation: buildInvocation, observedChild: observed(buildInvocation, matched: 0),
            sourceSnapshotAfterBuild: intent.sourceSnapshot, packageLockAfterBuild: intent.packageLock,
            pinnedMetallibAfterBuild: metal, testBundle: tree, activeNanoseconds: 1)
        let x = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: currentLists ? "current-source-inventory-v1-xctest" : "xctest", withExtension: "list")))
        let s = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: currentLists ? "current-source-inventory-v1-swift-testing" : "swift-testing", withExtension: "list")))
        let parsed = try PrimeValidationInventory.parse(xctestList: x, swiftTestingList: s)
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(intent: intent)
        let inventory = PrimeValidationInventoryReceiptV2(runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256: try build.identitySHA256(against: intent), invocations: invocations,
            observedChildren: [observed(invocations[0], stdout: x, matched: parsed.xctestIDs.count),
                               observed(invocations[1], stdout: s, matched: parsed.swiftTestingIDs.count)],
            xctestListArtifact: artifact("xctest_list", invocations[0].standardOutputRelativePath, x),
            swiftTestingListArtifact: artifact("swift_testing_list", invocations[1].standardOutputRelativePath, s),
            xctestListData: x, swiftTestingListData: s, inventory: parsed, activeNanoseconds: 2)
        return try .init(intent: intent, build: build, inventory: inventory,
            plan: .make(intent: intent, buildReceipt: build, inventoryReceipt: inventory))
    }

    private func observed(_ invocation: PrimeValidationInvocationV2, stdout: Data = Data(), stderr: Data = Data(),
                          result: Data = Data(), matched: Int, exit: Int32 = 0) -> PrimeValidationObservedChildReceiptV2 {
        let out = artifact("standard_output", invocation.standardOutputRelativePath, stdout)
        let err = artifact("standard_error", invocation.standardErrorRelativePath, stderr)
        let primary: PrimeValidationObservedPrimaryResultV2
        switch invocation.primaryResult {
        case .none: primary = .none
        case .standardOutput: primary = .standardOutput
        case let .file(path): primary = .file(artifact("primary_result", path, result))
        }
        func stream(_ data: Data) -> PrimeValidationStreamAuditV2 {
            .init(eofObserved: true, totalByteCount: UInt64(data.count), capturedByteCount: UInt64(data.count),
                overflowObserved: false, readErrorNumber: 0, writeErrorNumber: 0)
        }
        let process = PrimeValidationProcessAuditV2(processIdentifier: 100, sessionIdentifier: 100,
            processGroupIdentifier: 100, deadlineDisposition: .completed, sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted, preReapProcessGroupMembers: [100], exactReturnedProcessIdentifier: 100,
            rawWaitStatus: exit << 8, waitTermination: .exited(exit), processGroupEmptyAfterReap: true,
            standardOutput: stream(stdout), standardError: stream(stderr), matchedTestCount: matched)
        return .init(invocation: invocation, primaryResult: primary, standardOutputArtifact: out,
            standardErrorArtifact: err, process: process, activeNanoseconds: 1)
    }
    private func artifact(_ name: String, _ path: String, _ data: Data) -> PrimeValidationDriverArtifactBindingV2 {
        .init(name: name, relativePath: path, content: .init(data: data))
    }
    private func raw(_ name: String, _ path: String, _ data: Data) throws -> Raw {
        try .init(binding: artifact(name, path, data), data: data)
    }
    private func testID(_ id: String, _ framework: PrimeValidationFramework) throws -> PrimeValidationTestID {
        try .parse(id, framework: framework)
    }
    private func xml(_ ids: [String], failures: Set<String> = [], skips: [String: String] = [:]) -> Data {
        let rows = ids.map { id in
            let parts = id.split(separator: "/", maxSplits: 1)
            let child = failures.contains(id) ? "<failure message=\"failed\"/>"
                : skips[id].map { "<skipped message=\"\($0)\"/>" } ?? ""
            return "<testcase classname=\"\(parts[0])\" name=\"\(parts[1])\" time=\"0.001\">\(child)</testcase>"
        }.joined()
        return Data("<testsuites><testsuite name=\"TestResults\" tests=\"\(ids.count)\" failures=\"\(failures.count)\" errors=\"0\" skipped=\"\(skips.count)\" time=\"0.001\">\(rows)</testsuite></testsuites>".utf8)
    }
    private func transcript(_ ids: [String], failing: String? = nil, skipping: String? = nil, reason: String = "", selected: Bool = false) -> Data {
        let suite = selected ? "Selected tests" : "All tests"
        var lines = ["Test Suite '\(suite)' started at 2026-09-07 00:00:00.000"]
        for id in ids {
            let parts = id.split(separator: "/", maxSplits: 1)
            let prefix = "Test Case '-[\(parts[0]) \(parts[1])]'"
            lines.append(prefix + " started.")
            if id == skipping { lines.append("/fixture/Test.swift:1: -[\(parts[0]) \(parts[1])] : Test skipped - " + reason) }
            lines.append(prefix + " \(id == failing ? "failed" : id == skipping ? "skipped" : "passed") (0.001 seconds).")
        }
        lines.append("Test Suite '\(suite)' \(failing == nil ? "passed" : "failed") at 2026-09-07 00:00:01.000")
        lines.append("Executed \(ids.count) tests, with \(skipping == nil ? 0 : 1) tests skipped and \(failing == nil ? 0 : 1) failures (0 unexpected) in 0.001 (0.001) seconds")
        return Data((lines.joined(separator: "\n") + "\n").utf8)
    }
}

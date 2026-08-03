// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeValidationWorkflowContracts

final class PrimeValidationWorkflowContractsTests: XCTestCase {
    private let xPass = "PrimeCoreTests.AlphaTests/testPasses"
    private let swiftPass = "PrimeCoreTests.SwiftSuite/passes()"

    func testSequentialTranscriptParsesExactPassPartition() throws {
        let observation = try PrimeValidationSequentialXCTestObservation.parse(
            transcript([
                event(xPass, "started."),
                event(xPass, "passed (0.001 seconds)."),
                "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
            ])
        )

        XCTAssertEqual(observation.observedRawIDs, [xPass])
        XCTAssertEqual(observation.passedRawIDs, [xPass])
        XCTAssertEqual(observation.failedRawIDs, [])
        XCTAssertEqual(observation.skips, [])
    }

    func testSequentialTranscriptPreservesExactOptionalSkipReason() throws {
        let admission = PrimeValidationOptionalSkipPolicy.admissions[0]
        let observation = try PrimeValidationSequentialXCTestObservation.parse(
            transcript([
                event(xPass, "started."),
                event(xPass, "passed (0.001 seconds)."),
                event(admission.rawID, "started."),
                skipReason(admission.rawID, admission.exactReason),
                event(admission.rawID, "skipped (0.001 seconds)."),
                "Executed 2 tests, with 1 test skipped and 0 failures (0 unexpected) in 0.002 (0.002) seconds",
            ])
        )

        XCTAssertEqual(
            observation.skips,
            [.init(rawID: admission.rawID, exactReason: admission.exactReason)]
        )
    }

    func testSequentialTranscriptAdmitsMultipleAssertionsForOneFailedCase() throws {
        let observation = try PrimeValidationSequentialXCTestObservation.parse(
            transcript([
                event(xPass, "started."),
                event(xPass, "failed (0.001 seconds)."),
                "Executed 1 test, with 2 failures (2 unexpected) in 0.001 (0.001) seconds",
            ])
        )

        XCTAssertEqual(observation.failedRawIDs, [xPass])
        XCTAssertEqual(observation.declaredFailureCount, 2)
    }

    func testSequentialTranscriptRejectsMalformedSummaryCandidate() {
        assertTranscriptRejects([
            event(xPass, "started."),
            event(xPass, "passed (0.001 seconds)."),
            "Executed 1 test, with 0 failures (0 unexpected) in banana",
        ])
    }

    func testSequentialTranscriptRejectsInterleavedAndDuplicateTransitions() {
        let other = "PrimeCoreTests.BetaTests/testOther"
        assertTranscriptRejects([
            event(xPass, "started."),
            event(other, "started."),
            event(other, "passed (0.001 seconds)."),
            event(xPass, "passed (0.001 seconds)."),
            "Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.002) seconds",
        ])
        assertTranscriptRejects([
            event(xPass, "started."),
            event(xPass, "passed (0.001 seconds)."),
            event(xPass, "started."),
            event(xPass, "passed (0.001 seconds)."),
            "Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.002) seconds",
        ])
    }

    func testSequentialTranscriptRejectsSkipWithoutExactReasonLine() {
        assertTranscriptRejects([
            event(xPass, "started."),
            event(xPass, "skipped (0.001 seconds)."),
            "Executed 1 test, with 1 test skipped and 0 failures (0 unexpected) in 0.001 (0.001) seconds",
        ])
    }

    func testSequentialTranscriptRejectsTerminalBeforeStartAndUnfinishedCase() {
        assertTranscriptRejects([
            event(xPass, "passed (0.001 seconds)."),
            "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
        ])
        assertTranscriptRejects([
            event(xPass, "started."),
            "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
        ])
    }

    func testSequentialTranscriptRequiresOneFinalTopLevelAggregate() throws {
        let unframed = Data(
            ([
                event(xPass, "started."),
                event(xPass, "passed (0.001 seconds)."),
                "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
            ].joined(separator: "\n") + "\n").utf8
        )
        XCTAssertThrowsError(
            try PrimeValidationSequentialXCTestObservation.parse(unframed)
        )

        var duplicated = transcript([
            event(xPass, "started."),
            event(xPass, "passed (0.001 seconds)."),
            "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
        ])
        duplicated.append(
            Data(
                "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds\n"
                    .utf8
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationSequentialXCTestObservation.parse(duplicated)
        )
    }

    func testInventoryAndXUnitRejectNoncanonicalIdentifiers() {
        XCTAssertThrowsError(
            try PrimeValidationInventory.parse(
                xctestList: Data("PrimeCoreTests.AlphaTests/testé\n".utf8),
                swiftTestingList: Data((swiftPass + "\n").utf8)
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationParallelXCTestXUnitObservation.parse(
                xunit(
                    cases: [("AlphaTests/testMissingModule", .passed)],
                    failures: 0,
                    errors: 0,
                    skipped: 0
                )
            )
        )
    }

    func testInventoryParserEnforcesByteLineAndCountLimits() {
        let validSwiftTestingList = Data((swiftPass + "\n").utf8)
        let overByteLimit = Data(
            repeating: 0x61,
            count: PrimeValidationInventory.maximumListBytes + 1
        )
        XCTAssertThrowsError(
            try PrimeValidationInventory.parse(
                xctestList: overByteLimit,
                swiftTestingList: validSwiftTestingList
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeValidationContractError,
                .inventoryByteLimitExceeded
            )
        }

        let overLineLimit = Data(
            (
                String(
                    repeating: "a",
                    count: PrimeValidationInventory.maximumLineBytes + 1
                ) + "\n"
            ).utf8
        )
        XCTAssertThrowsError(
            try PrimeValidationInventory.parse(
                xctestList: overLineLimit,
                swiftTestingList: validSwiftTestingList
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeValidationContractError,
                .inventoryLineLimitExceeded
            )
        }

        let overCountLimit = Data(
            String(
                repeating: xPass + "\n",
                count: PrimeValidationInventory.maximumTestCount + 1
            ).utf8
        )
        XCTAssertThrowsError(
            try PrimeValidationInventory.parse(
                xctestList: overCountLimit,
                swiftTestingList: validSwiftTestingList
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeValidationContractError,
                .inventoryTestCountLimitExceeded
            )
        }
    }

    func testParallelXUnitNeverClaimsSkipAuthority() throws {
        let data = xunit(
            cases: [(xPass, .skipped)],
            failures: 0,
            errors: 0,
            skipped: 1
        )
        let observation = try PrimeValidationParallelXCTestXUnitObservation
            .parse(data)

        XCTAssertFalse(observation.skipAuthorityEstablished)
        XCTAssertEqual(observation.nonAuthoritativeSkippedElementCount, 1)
    }

    func testObservedAppleToolchainXUnitShapesParseExactly() throws {
        let xctest = Data(
            """
            <?xml version="1.0" encoding="UTF-8"?>

            <testsuites>
            <testsuite name="TestResults" errors="0" tests="2" failures="0" time="0.10080620800000001">
            <testcase classname="PrimeCoreTests.PrimeDurableArtifactsTests" name="testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors" time="0.050404208">
            </testcase>
            <testcase classname="PrimeCoreTests.PrimeDurableArtifactsTests" name="testArtifactRejectsUnapprovedExtendedAttribute" time="0.050402">
            </testcase>
            </testsuite>
            </testsuites>
            """.utf8
        )
        let xctestObservation = try
            PrimeValidationParallelXCTestXUnitObservation.parse(xctest)
        XCTAssertEqual(xctestObservation.declaredTests, 2)
        XCTAssertEqual(
            xctestObservation.nonAuthoritativeSkippedElementCount,
            0
        )

        let swiftTesting = Data(
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <testsuites>
              <testsuite name="TestResults" errors="0" tests="1" failures="0" skipped="0" time="0.000492084">
                <testcase classname="PrimeCoreTests.PrimeNativeNeuralGateContractArgumentsTests" name="probeArgumentsAdmitOnlyDisjointPrimeArtifactRoots()" time="0.00026075" />
              </testsuite>
            </testsuites>
            """.utf8
        )
        let swiftObservation = try
            PrimeValidationSwiftTestingXUnitObservation.parse(swiftTesting)
        XCTAssertEqual(swiftObservation.declaredTests, 1)
        XCTAssertEqual(
            swiftObservation.observedRawIDs,
            [
                "PrimeCoreTests.PrimeNativeNeuralGateContractArgumentsTests/probeArgumentsAdmitOnlyDisjointPrimeArtifactRoots()",
            ]
        )
    }

    func testReconcilerRejectsExplicitParallelSkipAgainstSequentialPass() throws {
        let fixture = try makeFixture(
            parallelCases: [(xPass, .skipped)]
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .resultDisagreement)
    }

    func testReconcilerCompletesPassOnlyWithAllThreeExactLanes() throws {
        let fixture = try makeFixture()
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .completePass)
        XCTAssertNil(outcome.incompleteReason)
        XCTAssertEqual(outcome.failedRawIDs, [])
        XCTAssertEqual(outcome.requiredSkippedRawIDs, [])
    }

    func testReconcilerAdmitsOnlyExactOptionalSkipIDAndReason() throws {
        let admission = PrimeValidationOptionalSkipPolicy.admissions[0]
        let fixture = try makeFixture(
            xIDs: [admission.rawID, xPass],
            sequentialLines: [
                event(xPass, "started."),
                event(xPass, "passed (0.001 seconds)."),
                event(admission.rawID, "started."),
                skipReason(admission.rawID, admission.exactReason),
                event(admission.rawID, "skipped (0.001 seconds)."),
                "Executed 2 tests, with 1 test skipped and 0 failures (0 unexpected) in 0.002 (0.002) seconds",
            ],
            parallelCases: [
                (xPass, .passed),
                (admission.rawID, .passed),
            ]
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .completePass)
        XCTAssertEqual(outcome.allowedSkippedRawIDs, [admission.rawID])
    }

    func testReconcilerClassifiesRequiredOrReasonMutatedSkipAsCompleteFail() throws {
        let admission = PrimeValidationOptionalSkipPolicy.admissions[0]
        let fixture = try makeFixture(
            xIDs: [admission.rawID],
            sequentialLines: [
                event(admission.rawID, "started."),
                skipReason(admission.rawID, admission.exactReason + " now"),
                event(admission.rawID, "skipped (0.001 seconds)."),
                "Executed 1 test, with 1 test skipped and 0 failures (0 unexpected) in 0.001 (0.001) seconds",
            ],
            parallelCases: [(admission.rawID, .passed)]
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .completeFail)
        XCTAssertEqual(outcome.requiredSkippedRawIDs, [admission.rawID])
    }

    func testReconcilerClassifiesUnknownXCTestAndSwiftTestingSkipsAsCompleteFail() throws {
        let xFixture = try makeFixture(
            sequentialLines: [
                event(xPass, "started."),
                skipReason(xPass, "not admitted"),
                event(xPass, "skipped (0.001 seconds)."),
                "Executed 1 test, with 1 test skipped and 0 failures (0 unexpected) in 0.001 (0.001) seconds",
            ]
        )
        let xOutcome = PrimeValidationReconciler.reconcile(
            plan: xFixture.plan,
            evidence: xFixture.evidence
        )
        XCTAssertEqual(xOutcome.disposition, .completeFail)
        XCTAssertEqual(xOutcome.requiredSkippedRawIDs, [xPass])

        let swiftFixture = try makeFixture(swiftResult: .skipped)
        let swiftOutcome = PrimeValidationReconciler.reconcile(
            plan: swiftFixture.plan,
            evidence: swiftFixture.evidence
        )
        XCTAssertEqual(swiftOutcome.disposition, .completeFail)
        XCTAssertEqual(swiftOutcome.requiredSkippedRawIDs, [swiftPass])
    }

    func testReconcilerClassifiesCoherentFailureAndExitOneAsCompleteFail() throws {
        let fixture = try makeFixture(
            sequentialLines: [
                event(xPass, "started."),
                event(xPass, "failed (0.001 seconds)."),
                "Executed 1 test, with 1 failure (1 unexpected) in 0.001 (0.001) seconds",
            ],
            parallelCases: [(xPass, .failure)],
            parallelExit: 1,
            sequentialExit: 1
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .completeFail)
        XCTAssertEqual(outcome.failedRawIDs, [xPass])
    }

    func testReconcilerRejectsExitZeroWithFailureEvidence() throws {
        let fixture = try makeFixture(
            sequentialLines: [
                event(xPass, "started."),
                event(xPass, "failed (0.001 seconds)."),
                "Executed 1 test, with 1 failure (1 unexpected) in 0.001 (0.001) seconds",
            ],
            parallelCases: [(xPass, .failure)]
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .resultDisagreement)
        XCTAssertEqual(outcome.incompleteLane, .parallelXCTest)
    }

    func testReconcilerRejectsExitOneWithoutFailureEvidence() throws {
        let fixture = try makeFixture(parallelExit: 1)
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .resultDisagreement)
        XCTAssertEqual(outcome.incompleteLane, .parallelXCTest)
    }

    func testReconcilerRejectsMissingInventoryMember() throws {
        let other = "PrimeCoreTests.BetaTests/testOther"
        let fixture = try makeFixture(xIDs: [xPass, other])
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .resultSetMismatch)
    }

    func testReconcilerPreservesTimeoutAsIncompleteLaneEvidence() throws {
        var fixture = try makeFixture()
        fixture.evidence = replaceProcesses(
            fixture.evidence,
            parallel: process(.timedOut, count: 1)
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .timeout)
        XCTAssertEqual(outcome.incompleteLane, .parallelXCTest)
    }

    func testReconcilerClassifiesTimeoutBeforeParsingZeroByteLaneOutput() throws {
        var fixture = try makeFixture()
        let partial = Data()
        let resultEmptyArtifacts = replacingArtifact(
            fixture.evidence.artifacts,
            role: .sequentialXCTestTranscript,
            data: partial
        )
        let artifacts = replacingArtifact(
            resultEmptyArtifacts,
            role: .sequentialXCTestStandardOutputLog,
            data: Data()
        )
        let material = PrimeValidationParsedArtifactMaterial(
            xctestList: fixture.evidence.parsedArtifactMaterial.xctestList,
            swiftTestingList:
                fixture.evidence.parsedArtifactMaterial.swiftTestingList,
            parallelXCTestXUnit:
                fixture.evidence.parsedArtifactMaterial.parallelXCTestXUnit,
            sequentialXCTestTranscript: partial,
            swiftTestingXUnit:
                fixture.evidence.parsedArtifactMaterial.swiftTestingXUnit
        )
        fixture.evidence = PrimeValidationWorkflowEvidence(
            runID: fixture.evidence.runID,
            artifacts: artifacts,
            parsedArtifactMaterial: material,
            processes: .init(
                parallelXCTest: fixture.evidence.processes.parallelXCTest,
                sequentialXCTest: laneProcessEvidence(
                    .sequentialXCTest,
                    invocation:
                        fixture.evidence.processes.sequentialXCTest
                            .invocation,
                    artifacts: artifacts,
                    observation: process(.timedOut, count: 0)
                ),
                swiftTesting: fixture.evidence.processes.swiftTesting
            ),
            durations: fixture.evidence.durations
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.incompleteReason, .timeout)
        XCTAssertEqual(outcome.incompleteLane, .sequentialXCTest)
    }

    func testReconcilerPrioritizesFailedContainmentOverTimeout() throws {
        var fixture = try makeFixture()
        let empty = Data()
        let artifacts = replacingArtifact(
            fixture.evidence.artifacts,
            role: .parallelXCTestXUnit,
            data: empty
        )
        let material = PrimeValidationParsedArtifactMaterial(
            xctestList: fixture.evidence.parsedArtifactMaterial.xctestList,
            swiftTestingList:
                fixture.evidence.parsedArtifactMaterial.swiftTestingList,
            parallelXCTestXUnit: empty,
            sequentialXCTestTranscript:
                fixture.evidence.parsedArtifactMaterial
                    .sequentialXCTestTranscript,
            swiftTestingXUnit:
                fixture.evidence.parsedArtifactMaterial.swiftTestingXUnit
        )
        let uncontained = PrimeValidationProcessObservation(
            termination: .timedOut,
            containmentObserved: false,
            exactReapObserved: true,
            standardOutputDrained: true,
            standardErrorDrained: true,
            logOverflowObserved: false,
            noTestsReported: false,
            matchedTestCount: 0
        )
        fixture.evidence = PrimeValidationWorkflowEvidence(
            runID: fixture.evidence.runID,
            artifacts: artifacts,
            parsedArtifactMaterial: material,
            processes: .init(
                parallelXCTest: laneProcessEvidence(
                    .parallelXCTest,
                    invocation:
                        fixture.evidence.processes.parallelXCTest
                            .invocation,
                    artifacts: artifacts,
                    observation: uncontained
                ),
                sequentialXCTest: fixture.evidence.processes.sequentialXCTest,
                swiftTesting: fixture.evidence.processes.swiftTesting
            ),
            durations: fixture.evidence.durations
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.incompleteReason, .uncontainedProcess)
        XCTAssertEqual(outcome.incompleteLane, .parallelXCTest)
    }

    func testReconcilerAppliesSafetyPrecedenceAcrossLanes() throws {
        let timeout = process(.timedOut, count: 0)
        let unsafeSequentialCases: [(
            observation: PrimeValidationProcessObservation,
            expected: PrimeValidationIncompleteReason
        )] = [
            (
                .init(
                    termination: .exited(0),
                    containmentObserved: false,
                    exactReapObserved: true,
                    standardOutputDrained: true,
                    standardErrorDrained: true,
                    logOverflowObserved: false,
                    noTestsReported: false,
                    matchedTestCount: 1
                ),
                .uncontainedProcess
            ),
            (
                .init(
                    termination: .exited(0),
                    containmentObserved: true,
                    exactReapObserved: true,
                    standardOutputDrained: false,
                    standardErrorDrained: true,
                    logOverflowObserved: false,
                    noTestsReported: false,
                    matchedTestCount: 1
                ),
                .unfinishedDrain
            ),
            (
                .init(
                    termination: .exited(0),
                    containmentObserved: true,
                    exactReapObserved: true,
                    standardOutputDrained: true,
                    standardErrorDrained: true,
                    logOverflowObserved: true,
                    noTestsReported: false,
                    matchedTestCount: 1
                ),
                .logOverflow
            ),
        ]

        for unsafe in unsafeSequentialCases {
            var fixture = try makeFixture()
            fixture.evidence = replaceProcesses(
                fixture.evidence,
                parallel: timeout,
                sequential: unsafe.observation
            )
            let outcome = PrimeValidationReconciler.reconcile(
                plan: fixture.plan,
                evidence: fixture.evidence
            )

            XCTAssertEqual(outcome.disposition, .incomplete)
            XCTAssertEqual(outcome.incompleteReason, unsafe.expected)
            XCTAssertEqual(outcome.incompleteLane, .sequentialXCTest)
        }
    }

    func testReconcilerRejectsBoundBytesWhoseReceiptWasNotUpdated() throws {
        var fixture = try makeFixture()
        let mutatedMaterial = PrimeValidationParsedArtifactMaterial(
            xctestList: fixture.evidence.parsedArtifactMaterial.xctestList,
            swiftTestingList:
                fixture.evidence.parsedArtifactMaterial.swiftTestingList,
            parallelXCTestXUnit: xunit(
                cases: [("PrimeCoreTests.OtherTests/testOther", .passed)],
                failures: 0,
                errors: 0,
                skipped: 0
            ),
            sequentialXCTestTranscript:
                fixture.evidence.parsedArtifactMaterial
                    .sequentialXCTestTranscript,
            swiftTestingXUnit:
                fixture.evidence.parsedArtifactMaterial.swiftTestingXUnit
        )
        fixture.evidence = PrimeValidationWorkflowEvidence(
            runID: fixture.evidence.runID,
            artifacts: fixture.evidence.artifacts,
            parsedArtifactMaterial: mutatedMaterial,
            processes: fixture.evidence.processes,
            durations: fixture.evidence.durations
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(
            outcome.incompleteReason,
            .parsedArtifactBindingMismatch
        )
    }

    func testReconcilerRejectsLaneReceiptFromAnotherRun() throws {
        var fixture = try makeFixture()
        let old = fixture.evidence.processes.parallelXCTest
        let mismatched = PrimeValidationLaneProcessEvidence(
            runID: "run-2",
            invocation: old.invocation,
            resultArtifact: old.resultArtifact,
            standardOutputArtifact: old.standardOutputArtifact,
            standardErrorArtifact: old.standardErrorArtifact,
            observation: old.observation
        )
        fixture.evidence = PrimeValidationWorkflowEvidence(
            runID: fixture.evidence.runID,
            artifacts: fixture.evidence.artifacts,
            parsedArtifactMaterial: fixture.evidence.parsedArtifactMaterial,
            processes: .init(
                parallelXCTest: mismatched,
                sequentialXCTest: fixture.evidence.processes.sequentialXCTest,
                swiftTesting: fixture.evidence.processes.swiftTesting
            ),
            durations: fixture.evidence.durations
        )
        let outcome = PrimeValidationReconciler.reconcile(
            plan: fixture.plan,
            evidence: fixture.evidence
        )

        XCTAssertEqual(outcome.disposition, .incomplete)
        XCTAssertEqual(outcome.incompleteReason, .laneBindingMismatch)
    }

    func testZeroStagingDurationIsValidButRequiredDurationsAreNonzero() throws {
        try durations(staging: 0).validate()
        XCTAssertThrowsError(
            try PrimeValidationPhaseDurations(
                leaseNanoseconds: 0,
                planningNanoseconds: 1,
                buildNanoseconds: 1,
                stagingNanoseconds: 0,
                executionNanoseconds: 1
            ).validate()
        )
    }

    func testProcessObservationRejectsImpossibleExitAndSignalValues() {
        XCTAssertThrowsError(try process(.exited(-1), count: 1).validate())
        XCTAssertThrowsError(try process(.exited(256), count: 1).validate())
        XCTAssertThrowsError(try process(.signaled(0), count: 1).validate())
        XCTAssertThrowsError(try process(.signaled(129), count: 1).validate())
    }

    func testNestedMirrorAndLockRemainPinnedToFirstPartyMLX() throws {
        let testDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
        let root = (0..<4).reduce(testDirectory) { value, _ in
            value.deletingLastPathComponent()
        }
        let nested = root.appendingPathComponent("Tests/PrimeValidationWorkflow")
        let nestedMirror = try Data(
            contentsOf: nested.appendingPathComponent(
                ".swiftpm/configuration/mirrors.json"
            )
        )
        let rootMirror = try Data(
            contentsOf: root.appendingPathComponent(
                ".swiftpm/configuration/mirrors.json"
            )
        )
        XCTAssertEqual(nestedMirror, rootMirror)

        let lock = try String(
            contentsOf: nested.appendingPathComponent("Package.resolved"),
            encoding: .utf8
        )
        XCTAssertTrue(
            lock.contains(
                "d37885a278f1c37484a94d0f401a418735e66519"
            )
        )
        XCTAssertFalse(
            lock.contains(
                "68904d"
            )
        )
    }

    private enum CaseResult {
        case passed
        case failure
        case error
        case skipped
    }

    private struct Fixture {
        let plan: PrimeValidationWorkflowPlan
        var evidence: PrimeValidationWorkflowEvidence
    }

    private func makeFixture(
        xIDs: [String]? = nil,
        sequentialLines: [String]? = nil,
        parallelCases: [(String, CaseResult)]? = nil,
        swiftResult: CaseResult = .passed,
        parallelExit: Int32 = 0,
        sequentialExit: Int32 = 0,
        swiftExit: Int32 = 0
    ) throws -> Fixture {
        let actualXIDs = (xIDs ?? [xPass]).sorted()
        let xList = Data((actualXIDs.joined(separator: "\n") + "\n").utf8)
        let swiftList = Data((swiftPass + "\n").utf8)
        let inventory = try PrimeValidationInventory.parse(
            xctestList: xList,
            swiftTestingList: swiftList
        )
        let actualSequential = transcript(
            sequentialLines ?? [
                event(xPass, "started."),
                event(xPass, "passed (0.001 seconds)."),
                "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.001) seconds",
            ]
        )
        let actualParallelCases = parallelCases
            ?? actualXIDs.map { ($0, CaseResult.passed) }
        let parallel = xunit(
            cases: actualParallelCases,
            failures: actualParallelCases.filter { $0.1 == .failure }.count,
            errors: actualParallelCases.filter { $0.1 == .error }.count,
            skipped: actualParallelCases.filter { $0.1 == .skipped }.count
        )
        let swift = xunit(
            cases: [(swiftPass, swiftResult)],
            failures: swiftResult == .failure ? 1 : 0,
            errors: swiftResult == .error ? 1 : 0,
            skipped: swiftResult == .skipped ? 1 : 0
        )
        let source = Data("source".utf8)
        let lock = Data("lock".utf8)
        let bundle = Data("bundle".utf8)
        let stdout = Data("stdout".utf8)
        let stderr = Data()
        let dataByRole: [PrimeValidationArtifactRole: Data] = [
            .sourceSnapshot: source,
            .packageLock: lock,
            .testBundle: bundle,
            .xctestList: xList,
            .swiftTestingList: swiftList,
            .parallelXCTestXUnit: parallel,
            .sequentialXCTestTranscript: actualSequential,
            .swiftTestingXUnit: swift,
            .parallelXCTestStandardOutputLog: stdout,
            .parallelXCTestStandardErrorLog: stderr,
            .sequentialXCTestStandardOutputLog: stdout,
            .sequentialXCTestStandardErrorLog: stderr,
            .swiftTestingStandardOutputLog: stdout,
            .swiftTestingStandardErrorLog: stderr,
        ]
        let artifacts = PrimeValidationArtifactSet(
            bindings: PrimeValidationArtifactRole.allCases.map { role in
                PrimeValidationArtifactBinding(
                    role: role,
                    relativePath: role.rawValue + ".evidence",
                    content: .init(data: dataByRole[role]!)
                )
            }
        )
        let input = PrimeValidationInputArtifactSet(
            bindings: artifacts.bindings.filter {
                PrimeValidationInputArtifactSet.requiredRoles.contains(
                    $0.role
                )
            }
        )
        let executable = PrimeValidationContentBinding(
            data: Data("swift-test-executable".utf8)
        )
        let invocations = PrimeValidationLaneInvocationSet(
            parallelXCTest: invocation(
                .parallelXCTest,
                executable: executable,
                testBundle: .init(data: bundle)
            ),
            sequentialXCTest: invocation(
                .sequentialXCTest,
                executable: executable,
                testBundle: .init(data: bundle)
            ),
            swiftTesting: invocation(
                .swiftTesting,
                executable: executable,
                testBundle: .init(data: bundle)
            )
        )
        let plan = PrimeValidationWorkflowPlan(
            runID: "run-1",
            expectedInventorySHA256: try inventory.identitySHA256(),
            expectedInputArtifacts: input,
            expectedInvocations: invocations,
            optionalSkipPolicySHA256:
                try PrimeValidationOptionalSkipPolicy.identitySHA256()
        )
        let evidence = PrimeValidationWorkflowEvidence(
            runID: "run-1",
            artifacts: artifacts,
            parsedArtifactMaterial: .init(
                xctestList: xList,
                swiftTestingList: swiftList,
                parallelXCTestXUnit: parallel,
                sequentialXCTestTranscript: actualSequential,
                swiftTestingXUnit: swift
            ),
            processes: .init(
                parallelXCTest: laneProcessEvidence(
                    .parallelXCTest,
                    invocation: invocations.parallelXCTest,
                    artifacts: artifacts,
                    observation: process(
                        .exited(parallelExit),
                        count: actualXIDs.count
                    )
                ),
                sequentialXCTest: laneProcessEvidence(
                    .sequentialXCTest,
                    invocation: invocations.sequentialXCTest,
                    artifacts: artifacts,
                    observation: process(
                        .exited(sequentialExit),
                        count: actualXIDs.count
                    )
                ),
                swiftTesting: laneProcessEvidence(
                    .swiftTesting,
                    invocation: invocations.swiftTesting,
                    artifacts: artifacts,
                    observation: process(
                        .exited(swiftExit),
                        count: 1
                    )
                )
            ),
            durations: durations()
        )
        return .init(plan: plan, evidence: evidence)
    }

    private func replaceProcesses(
        _ evidence: PrimeValidationWorkflowEvidence,
        parallel: PrimeValidationProcessObservation? = nil,
        sequential: PrimeValidationProcessObservation? = nil,
        swiftTesting: PrimeValidationProcessObservation? = nil
    ) -> PrimeValidationWorkflowEvidence {
        PrimeValidationWorkflowEvidence(
            runID: evidence.runID,
            artifacts: evidence.artifacts,
            parsedArtifactMaterial: evidence.parsedArtifactMaterial,
            processes: .init(
                parallelXCTest: replacingObservation(
                    evidence.processes.parallelXCTest,
                    with: parallel
                        ?? evidence.processes.parallelXCTest.observation
                ),
                sequentialXCTest: replacingObservation(
                    evidence.processes.sequentialXCTest,
                    with: sequential
                        ?? evidence.processes.sequentialXCTest.observation
                ),
                swiftTesting: replacingObservation(
                    evidence.processes.swiftTesting,
                    with: swiftTesting
                        ?? evidence.processes.swiftTesting.observation
                )
            ),
            durations: evidence.durations
        )
    }

    private func invocation(
        _ lane: PrimeValidationExecutionLane,
        executable: PrimeValidationContentBinding,
        testBundle: PrimeValidationContentBinding
    ) -> PrimeValidationLaneInvocation {
        .init(
            lane: lane,
            executablePath: "/usr/bin/swift",
            executableContent: executable,
            arguments: ["test", "--lane", lane.rawValue],
            environment: [
                .init(key: "PRIME_RUN_ID", value: "run-1"),
            ],
            workingDirectoryRelativePath: ".",
            testBundleContent: testBundle
        )
    }

    private func laneProcessEvidence(
        _ lane: PrimeValidationExecutionLane,
        invocation: PrimeValidationLaneInvocation,
        artifacts: PrimeValidationArtifactSet,
        observation: PrimeValidationProcessObservation
    ) -> PrimeValidationLaneProcessEvidence {
        .init(
            runID: "run-1",
            invocation: invocation,
            resultArtifact: artifacts.binding(for: lane.resultRole)!,
            standardOutputArtifact:
                artifacts.binding(for: lane.standardOutputRole)!,
            standardErrorArtifact:
                artifacts.binding(for: lane.standardErrorRole)!,
            observation: observation
        )
    }

    private func replacingObservation(
        _ evidence: PrimeValidationLaneProcessEvidence,
        with observation: PrimeValidationProcessObservation
    ) -> PrimeValidationLaneProcessEvidence {
        .init(
            runID: evidence.runID,
            invocation: evidence.invocation,
            resultArtifact: evidence.resultArtifact,
            standardOutputArtifact: evidence.standardOutputArtifact,
            standardErrorArtifact: evidence.standardErrorArtifact,
            observation: observation
        )
    }

    private func replacingArtifact(
        _ artifacts: PrimeValidationArtifactSet,
        role: PrimeValidationArtifactRole,
        data: Data
    ) -> PrimeValidationArtifactSet {
        PrimeValidationArtifactSet(
            bindings: artifacts.bindings.map { binding in
                guard binding.role == role else { return binding }
                return PrimeValidationArtifactBinding(
                    role: role,
                    relativePath: binding.relativePath,
                    content: .init(data: data)
                )
            }
        )
    }

    private func process(
        _ termination: PrimeValidationProcessTermination,
        count: Int
    ) -> PrimeValidationProcessObservation {
        .init(
            termination: termination,
            containmentObserved: true,
            exactReapObserved: true,
            standardOutputDrained: true,
            standardErrorDrained: true,
            logOverflowObserved: false,
            noTestsReported: false,
            matchedTestCount: count
        )
    }

    private func durations(
        staging: UInt64 = 1
    ) -> PrimeValidationPhaseDurations {
        .init(
            leaseNanoseconds: 1,
            planningNanoseconds: 1,
            buildNanoseconds: 1,
            stagingNanoseconds: staging,
            executionNanoseconds: 1
        )
    }

    private func event(_ rawID: String, _ tail: String) -> String {
        let pieces = rawID.split(separator: "/", maxSplits: 1)
        return "Test Case '-[\(pieces[0]) \(pieces[1])]' \(tail)"
    }

    private func skipReason(_ rawID: String, _ reason: String) -> String {
        let pieces = rawID.split(separator: "/", maxSplits: 1)
        return "/tmp/Test.swift:1: -[\(pieces[0]) \(pieces[1])] : Test skipped - \(reason)"
    }

    private func transcript(_ lines: [String]) -> Data {
        var framed = [
            "Test Suite 'All tests' started at 2026-08-02 00:00:00.000",
        ]
        let summaryIndex = lines.lastIndex(where: {
            $0.trimmingCharacters(in: .whitespaces)
                .hasPrefix("Executed ")
        })
        if let summaryIndex {
            framed.append(contentsOf: lines[..<summaryIndex])
            let failed = lines.contains(where: {
                $0.hasPrefix("Test Case ") && $0.contains(" failed (")
            })
            framed.append(
                "Test Suite 'All tests' \(failed ? "failed" : "passed") at 2026-08-02 00:00:01.000"
            )
            framed.append(contentsOf: lines[summaryIndex...])
        } else {
            framed.append(contentsOf: lines)
        }
        return Data((framed.joined(separator: "\n") + "\n").utf8)
    }

    private func assertTranscriptRejects(
        _ lines: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeValidationSequentialXCTestObservation.parse(
                transcript(lines)
            ),
            file: file,
            line: line
        )
    }

    private func xunit(
        cases: [(String, CaseResult)],
        failures: Int,
        errors: Int,
        skipped: Int
    ) -> Data {
        let rows = cases.map { rawID, result in
            let pieces = rawID.split(separator: "/", maxSplits: 1)
            let child: String
            switch result {
            case .passed: child = ""
            case .failure: child = #"<failure message="failed"/>"#
            case .error: child = #"<error message="error"/>"#
            case .skipped: child = #"<skipped message="skipped"/>"#
            }
            return #"<testcase classname="\#(pieces[0])" name="\#(pieces[1])" time="0.001">\#(child)</testcase>"#
        }.joined()
        return Data(
            """
            <testsuites><testsuite name="TestResults" tests="\(cases.count)" failures="\(failures)" errors="\(errors)" skipped="\(skipped)" time="0.001">\(rows)</testsuite></testsuites>
            """.utf8
        )
    }
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRetirementCeiling()
        throws
    {
        requireSendable(Observation.self)
        let observation = Observation.frozenV1

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.schemaID,
            "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_schema_v1"
        )
        XCTAssertEqual(
            observation.observationID,
            "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "terminal_exact_main_closed_fixture_canary_pin_mismatch_adapter_not_attempted_opportunity_retired_no_retry"
        )

        let authority = observation.authorityClosure
        XCTAssertEqual(
            authority.authorityID,
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            authority.canonicalByteCount,
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .canonicalByteCount
        )
        XCTAssertEqual(
            authority.canonicalSHA256,
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .canonicalSHA256
        )
        XCTAssertEqual(
            authority.mergeRevision,
            "b3402efd96d3ff893a0c2b73897cf48c9b313c8c"
        )
        XCTAssertEqual(
            authority.mergeTree,
            "7fb3f5505796a43c9db1537ca72f81e19367365f"
        )
        XCTAssertEqual(
            authority.orderedParentRevisions,
            [
                "232a17e8f58a297919366d963ee1d7bc38cdbaee",
                "82ae2c2611e62144c066db990be6eaf48fdff47a",
            ]
        )
        XCTAssertEqual(authority.pullRequestNumber, 121)
        XCTAssertEqual(authority.workflowRunID, 31_957_009_710)
        XCTAssertEqual(authority.workflowRunNumber, 141)
        XCTAssertEqual(authority.workflowRunAttempt, 1)
        XCTAssertEqual(authority.checkSuiteID, 86_653_677_663)
        XCTAssertEqual(authority.activeRootJobID, 95_189_063_495)
        XCTAssertEqual(authority.reviewedMainJobID, 95_189_438_167)
        XCTAssertEqual(authority.activeRootJobConclusion, "success")
        XCTAssertEqual(authority.reviewedMainJobConclusion, "success")
        XCTAssertEqual(authority.activeLatinTestCount, 116)
        XCTAssertEqual(authority.focusedRootTestCount, 78)
        XCTAssertEqual(authority.isolatedTestCount, 6)
        XCTAssertEqual(authority.focusedWholeTestCount, 84)
        XCTAssertEqual(authority.retainedLiveTestCount, 46)
        XCTAssertEqual(authority.aggregateTestCount, 130)
        XCTAssertEqual(authority.reviewedFailureCount, 0)
        XCTAssertEqual(authority.reviewedSkipCount, 0)
        XCTAssertEqual(authority.workflowRerunCount, 0)
        XCTAssertEqual(authority.actionsArtifactCount, 0)
        XCTAssertTrue(authority.exactMainClosureEstablished)

        let sources = observation.mechanicsSourceBindings
        XCTAssertEqual(sources.count, 3)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
            ]
        )
        XCTAssertEqual(sources.map(\.mechanicsGitStatus), ["M", "A", "M"])
        XCTAssertEqual(sources.map(\.gitMode), ["100755", "100755", "100644"])
        XCTAssertEqual(
            sources.map(\.gitBlob),
            [
                "f4993235980958140ffd079818b337fb04323177",
                "2b4cd9ca38410eed6661c1de50fcdab595c24b77",
                "e0a1678488ccef7aa70090e4fa5c83384edf1e49",
            ]
        )
        XCTAssertEqual(sources.map(\.byteCount), [1_187_421, 57_143, 140_991])
        XCTAssertEqual(sources.map(\.lfByteCount), [19_816, 1_204, 722])
        XCTAssertEqual(
            sources.map(\.sha256),
            [
                "86b577a109d4fed36cf05c6859055cba9b5449b4673786575b07eee27375be15",
                "0c00a5ff7b5752be59d674699b7dca4bfa5b3fe973ab96e7cf8a0f455b9f2eea",
                "9f5441aab18be449f4c8292e49f8da99fed36abf322e0c4cdbfba9438177c100",
            ]
        )
        XCTAssertEqual(Set(sources.map(\.path)).count, 3)
        XCTAssertTrue(
            sources.allSatisfy {
                isLowercaseHex($0.gitBlob, count: 40)
                    && isLowercaseHex($0.sha256, count: 64)
                    && !$0.role.isEmpty
            }
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(repository.pullRequestNumber, 122)
        XCTAssertEqual(repository.baseRevision, authority.mergeRevision)
        XCTAssertEqual(repository.baseTree, authority.mergeTree)
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "72f8d7ec790d5761e83aed0e086599eaf2cd42d9"
        )
        XCTAssertEqual(
            repository.reviewedHeadTree,
            "e01bb064bc40fd4a3d875e8506f3088424ab773b"
        )
        XCTAssertEqual(
            repository.reviewedHeadOrderedParentRevisions,
            [repository.baseRevision]
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6"
        )
        XCTAssertEqual(repository.mergeTree, repository.reviewedHeadTree)
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.exactMainRefMatchedAtTerminalAudit)
        XCTAssertEqual(repository.exactChangedPathCount, 3)
        XCTAssertEqual(repository.changedManifestPathCount, 0)
        XCTAssertEqual(repository.changedLockPathCount, 0)

        let review = observation.pullRequestLane
        XCTAssertEqual(review.workflowID, 329_017_041)
        XCTAssertEqual(review.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(
            review.workflowPath,
            ".github/workflows/prime-active-root-quarantine.yml"
        )
        XCTAssertEqual(review.runID, 31_965_892_051)
        XCTAssertEqual(review.runNumber, 142)
        XCTAssertEqual(review.runAttempt, 1)
        XCTAssertEqual(review.checkSuiteID, 86_674_348_466)
        XCTAssertEqual(review.event, "pull_request")
        XCTAssertEqual(review.headRevision, repository.reviewedHeadRevision)
        XCTAssertEqual(review.status, "completed")
        XCTAssertEqual(review.conclusion, "success")
        XCTAssertEqual(review.exactHeadRunCount, 1)
        XCTAssertTrue(review.previousAttemptURLWasNull)
        XCTAssertEqual(review.retryCount, 0)
        XCTAssertEqual(review.rerunCount, 0)
        XCTAssertEqual(review.artifactCount, 0)
        XCTAssertEqual(review.activeRootJobID, 95_210_894_514)
        XCTAssertEqual(review.activeRootJobConclusion, "success")
        XCTAssertEqual(review.activeLatinTestCount, 116)
        XCTAssertEqual(review.activeLatinFailureCount, 0)
        XCTAssertEqual(review.reviewedMainJobID, 95_211_273_235)
        XCTAssertEqual(review.reviewedMainJobConclusion, "skipped")
        XCTAssertEqual(review.reviewedMainJobStepCount, 0)
        XCTAssertEqual(review.launcherInvocationCount, 0)
        XCTAssertEqual(review.adapterCommandAttemptCount, 0)
        XCTAssertEqual(review.hostedRecordCount, 0)

        let main = observation.exactMainLane
        XCTAssertEqual(main.workflowID, review.workflowID)
        XCTAssertEqual(main.workflowName, review.workflowName)
        XCTAssertEqual(main.workflowPath, review.workflowPath)
        XCTAssertEqual(main.runID, 31_974_943_697)
        XCTAssertEqual(main.runNumber, 143)
        XCTAssertEqual(main.runAttempt, 1)
        XCTAssertEqual(main.checkSuiteID, 86_694_964_833)
        XCTAssertEqual(main.event, "push")
        XCTAssertEqual(main.headBranch, "main")
        XCTAssertEqual(main.headRevision, repository.mergeRevision)
        XCTAssertEqual(main.status, "completed")
        XCTAssertEqual(main.conclusion, "failure")
        XCTAssertEqual(main.exactHeadRunCount, 1)
        XCTAssertTrue(main.previousAttemptURLWasNull)
        XCTAssertEqual(main.retryCount, 0)
        XCTAssertEqual(main.rerunCount, 0)
        XCTAssertEqual(main.artifactCount, 0)
        XCTAssertEqual(main.activeRootJobID, 95_232_879_059)
        XCTAssertEqual(main.activeRootJobConclusion, "success")
        XCTAssertEqual(main.activeLatinTestCount, 116)
        XCTAssertEqual(main.activeLatinFailureCount, 0)
        XCTAssertEqual(main.reviewedMainJobID, 95_233_206_587)
        XCTAssertEqual(main.reviewedMainJobConclusion, "failure")
        XCTAssertEqual(main.focusedRootTestCount, 78)
        XCTAssertEqual(main.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(main.isolatedTestCount, 6)
        XCTAssertEqual(main.focusedWholeTestCount, 84)
        XCTAssertEqual(main.retainedMetalTestCount, 44)
        XCTAssertEqual(main.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(main.tokenizerTestCount, 1)
        XCTAssertEqual(main.retainedLiveTestCount, 46)
        XCTAssertEqual(main.aggregateTestCount, 130)
        XCTAssertEqual(main.xctestFailureCount, 0)
        XCTAssertEqual(main.xctestSkipCount, 0)
        XCTAssertEqual(
            main.orderedReviewedExecutionRoles,
            [
                "focused", "metal", "maintained_runtime", "tokenizer",
                "closed_fixture_canary",
            ]
        )
        XCTAssertEqual(main.swiftReleaseBuildProductCommandCount, 2)
        XCTAssertEqual(main.swiftReleaseShowBinPathCommandCount, 1)
        XCTAssertEqual(main.exactSwiftPMCommandCount, 3)
        XCTAssertEqual(main.launcherInvocationCount, 1)
        XCTAssertEqual(main.adapterCommandAttemptCount, 0)
        XCTAssertEqual(main.fixtureProcessExecutionCount, 0)
        XCTAssertEqual(main.hostedRecordCount, 1)

        let identity = observation.hostedRecordIdentity
        let record = identity.record
        XCTAssertEqual(
            identity.prefix,
            "prime-secure-child closed-fixture-canary observation: "
        )
        XCTAssertEqual(identity.prefixByteCount, 54)
        XCTAssertEqual(identity.canonicalJSONByteCount, 1_331)
        XCTAssertEqual(
            identity.canonicalJSONSHA256,
            "1980a1227fba50e1bfab9268b82fee1de6255d843fbf065ff72ad4e0d4398821"
        )
        XCTAssertEqual(identity.totalLineByteCountIncludingTerminalLF, 1_386)
        XCTAssertEqual(
            identity.totalLineSHA256IncludingTerminalLF,
            "3a507dfb0941cd662037da3c0a681216dc13d9804e58624fb9fba4e1670f7f0a"
        )
        XCTAssertEqual(identity.exactOccurrenceCount, 1)
        XCTAssertEqual(identity.exactFieldCount, 27)
        XCTAssertEqual(identity.rawChildOutputOrErrorFieldCount, 0)
        XCTAssertFalse(record.actionsArtifact)
        XCTAssertFalse(record.adapterCommandAttemptOneShotConsumed)
        XCTAssertEqual(record.adapterCommandState, "not_attempted")
        XCTAssertEqual(record.adapterExecutableByteCount, 37_533_680)
        XCTAssertEqual(
            record.adapterExecutableSHA256,
            "dc77edad4a9b66e48a7322bbc69717a9467ce5e20527b940e66b9061ec50c460"
        )
        XCTAssertEqual(record.adapterExecutionObservation, "observed_false")
        XCTAssertEqual(record.authorityCanonicalSHA256, authority.canonicalSHA256)
        XCTAssertEqual(record.authorityID, authority.authorityID)
        XCTAssertEqual(record.captureCleanupAbsence, "unavailable")
        XCTAssertFalse(record.durableEvidence)
        XCTAssertEqual(record.exactRevision, repository.mergeRevision)
        XCTAssertNil(record.fixtureExecutableByteCount)
        XCTAssertNil(record.fixtureExecutableSHA256)
        XCTAssertEqual(record.opportunityState, "retired")
        XCTAssertEqual(record.resultCode, "PIN_MISMATCH")
        XCTAssertEqual(
            record.schemaID,
            "prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1"
        )
        XCTAssertEqual(record.schemaVersion, 1)
        XCTAssertEqual(record.scientificOutcome, "not_established")
        XCTAssertNil(record.shellWaitStatus)
        XCTAssertEqual(record.standardErrorByteCap, 131_072)
        XCTAssertFalse(record.standardErrorCaptureCapReached)
        XCTAssertEqual(record.standardErrorCapturedByteCount, 0)
        XCTAssertEqual(
            record.standardErrorSHA256,
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
        XCTAssertEqual(record.standardOutputByteCap, 131_072)
        XCTAssertFalse(record.standardOutputCaptureCapReached)
        XCTAssertEqual(record.standardOutputCapturedByteCount, 0)
        XCTAssertEqual(record.standardOutputSHA256, record.standardErrorSHA256)

        let exactRecordJSON =
            #"{"actions_artifact":false,"adapter_command_attempt_one_shot_consumed":false,"adapter_command_state":"not_attempted","adapter_executable_byte_count":37533680,"adapter_executable_sha256":"dc77edad4a9b66e48a7322bbc69717a9467ce5e20527b940e66b9061ec50c460","adapter_execution_observation":"observed_false","authority_canonical_sha256":"29cd7cb18001da845021bc60f8f250a920f927cdc302e5d5071e95f049c3351f","authority_id":"prime_secure_child_process_evidence_closed_fixture_canary_authority_v1","capture_cleanup_absence":"unavailable","durable_evidence":false,"exact_revision":"d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6","fixture_executable_byte_count":null,"fixture_executable_sha256":null,"opportunity_state":"retired","result_code":"PIN_MISMATCH","schema_id":"prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1","schema_version":1,"scientific_outcome":"not_established","shell_wait_status":null,"standard_error_byte_cap":131072,"standard_error_capture_cap_reached":false,"standard_error_captured_byte_count":0,"standard_error_sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","standard_output_byte_cap":131072,"standard_output_capture_cap_reached":false,"standard_output_captured_byte_count":0,"standard_output_sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}"#
        let recordData = try record.canonicalData()
        XCTAssertEqual(recordData.count, 1_331)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: recordData),
            identity.canonicalJSONSHA256
        )
        XCTAssertEqual(String(data: recordData, encoding: .utf8), exactRecordJSON)

        var prefixedLine = Data(identity.prefix.utf8)
        prefixedLine.append(recordData)
        prefixedLine.append(0x0A)
        XCTAssertEqual(
            prefixedLine.count,
            identity.totalLineByteCountIncludingTerminalLF
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefixedLine),
            identity.totalLineSHA256IncludingTerminalLF
        )

        let mismatch = observation.pinMismatchBoundary
        XCTAssertEqual(mismatch.resultCode, "PIN_MISMATCH")
        XCTAssertTrue(mismatch.setupOutcomeEstablished)
        XCTAssertEqual(mismatch.configuredFixturePinByteCount, 89_632)
        XCTAssertEqual(
            mismatch.configuredFixturePinSHA256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
        )
        XCTAssertTrue(mismatch.adapterExecutableIdentityObserved)
        XCTAssertFalse(mismatch.fixtureExecutableIdentityPublished)
        XCTAssertNil(mismatch.observedFixtureExecutableByteCount)
        XCTAssertNil(mismatch.observedFixtureExecutableSHA256)
        XCTAssertEqual(
            mismatch.mismatchDimensionEvidence,
            "unavailable_size_sha256_or_both_not_disclosed_by_hosted_record"
        )
        XCTAssertFalse(mismatch.byteCountMismatchEstablished)
        XCTAssertFalse(mismatch.sha256MismatchEstablished)
        XCTAssertFalse(mismatch.bothDimensionsMismatchEstablished)
        XCTAssertEqual(mismatch.adapterCommandState, "not_attempted")
        XCTAssertFalse(mismatch.adapterCommandAttemptOneShotConsumed)
        XCTAssertEqual(mismatch.adapterExecutionObservation, "observed_false")
        XCTAssertEqual(mismatch.adapterCommandAttemptCount, 0)
        XCTAssertEqual(mismatch.fixtureProcessExecutionCount, 0)
        XCTAssertFalse(mismatch.processContainmentEstablished)
        XCTAssertEqual(mismatch.captureCleanupAbsenceEvidence, "unavailable")
        XCTAssertEqual(mismatch.scientificOutcome, "not_established")
        XCTAssertFalse(mismatch.durableEvidenceEstablished)
        XCTAssertEqual(mismatch.actionsArtifactCount, 0)
        XCTAssertEqual(mismatch.mechanicsOpportunityState, "retired")
        XCTAssertTrue(mismatch.workflowFailureEstablished)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertEqual(retirement.exactChangedPathCount, 5)
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift",
            ]
        )
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths.map(\.gitMode),
            ["100755", "100644", "100644", "100644", "100644"]
        )
        XCTAssertEqual(retirement.expectedActiveLatinTestCount, 116)
        XCTAssertEqual(retirement.expectedRootTestCount, 79)
        XCTAssertEqual(retirement.expectedIsolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(retirement.expectedIsolatedTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeTestCount, 85)
        XCTAssertEqual(retirement.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(retirement.expectedAggregateTestCount, 131)
        XCTAssertEqual(retirement.expectedCanaryLauncherWorkflowReferenceCount, 0)
        XCTAssertEqual(retirement.expectedCanaryLauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedAdapterCommandAttemptCount, 0)
        XCTAssertEqual(retirement.expectedHostedRecordCount, 0)
        XCTAssertTrue(retirement.launcherSourcePreservedForAudit)
        XCTAssertEqual(
            retirement.launcherPath,
            ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh"
        )
        XCTAssertEqual(retirement.launcherGitMode, "100755")
        XCTAssertEqual(
            retirement.launcherGitBlob,
            "2b4cd9ca38410eed6661c1de50fcdab595c24b77"
        )
        XCTAssertEqual(retirement.launcherByteCount, 57_143)
        XCTAssertEqual(retirement.launcherLFByteCount, 1_204)
        XCTAssertEqual(
            retirement.launcherSHA256,
            "0c00a5ff7b5752be59d674699b7dca4bfa5b3fe973ab96e7cf8a0f455b9f2eea"
        )
        XCTAssertTrue(retirement.commandAttemptOneShotUnconsumed)
        XCTAssertTrue(retirement.mechanicsOpportunityRetired)
        XCTAssertTrue(retirement.exactMainRetirementClosureRequired)
        XCTAssertFalse(retirement.retryWithoutNewAuthorityPermitted)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.exactHostedRecordIntegrityEstablished)
        XCTAssertTrue(ceiling.pinMismatchEstablished)
        XCTAssertTrue(ceiling.setupOutcomeEstablished)
        XCTAssertTrue(ceiling.adapterExecutableIdentityEstablished)
        XCTAssertTrue(ceiling.mechanicsOpportunityRetired)
        XCTAssertTrue(ceiling.failureObservationAuthorizesNothing)
        XCTAssertTrue(ceiling.exactRetirementRequired)
        XCTAssertTrue(ceiling.workflowFailureEstablished)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 6)
        XCTAssertEqual(
            observation.status,
            "PIN_MISMATCH_exact_main_run143_valid_outer_record_adapter_not_attempted_command_one_shot_unconsumed_mechanics_opportunity_retired_fixture_identity_unavailable_no_retry_no_scientific_or_durable_evidence"
        )

        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        XCTAssertEqual(canonical.count, Observation.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Observation.canonicalSHA256
        )
        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 150)
        XCTAssertGreaterThan(dictionaryPaths.count, 10)
        XCTAssertGreaterThan(scalarPaths.count, 120)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))"
            )
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutationData
            ), loose != observation {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }
            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        if value is NSNull {
                            return "__null_mutation"
                        }
                        return NSNull()
                    }
                ),
                label: "null \(pathLabel(path))"
            )
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 120)

        let arrayPaths = allArrayPaths(in: object)
        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count {
                            if canonicalJSONFragment(array[left])
                                != canonicalJSONFragment(array[right]) {
                                array.swapAt(left, right)
                                didReorder = true
                                return array
                            }
                        }
                    }
                    return array
                }
            )
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered,
                    label: "reordered array at \(pathLabel(path))"
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 5)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_pin_mismatch_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(Observation.self, from: unknownData)
            XCTAssertEqual(loose, observation)
        }

        try assertNoncanonicalEncodingsReject(canonical, object: object)
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allArrayPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allScalarPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else { return transform(value) }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform)
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Observation.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(slashEscapedData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening))
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
    }

    private func authorityFalseClaims(
        _ ceiling: Observation.AuthorityCeiling
    ) -> [Bool] {
        [
            ceiling.fixtureExecutableObservedByteCountEstablished,
            ceiling.fixtureExecutableObservedSHA256Established,
            ceiling.fixturePinByteCountMismatchEstablished,
            ceiling.fixturePinSHA256MismatchEstablished,
            ceiling.bothFixturePinDimensionsMismatchEstablished,
            ceiling.adapterCommandAttempted,
            ceiling.adapterCommandOneShotConsumed,
            ceiling.adapterExecuted,
            ceiling.fixtureProcessExecuted,
            ceiling.processContainmentEstablished,
            ceiling.captureCleanupAbsenceEstablished,
            ceiling.operationalCompatibilityEstablished,
            ceiling.scientificOutcomeEstablished,
            ceiling.durableEvidenceEstablished,
            ceiling.actionsArtifactPublished,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.canaryMechanicsRepairOrReplacementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.fixtureMutationAuthorized,
            ceiling.adapterMutationAuthorized,
            ceiling.processLayerMutationAuthorized,
            ceiling.leaseMutationAuthorized,
            ceiling.additionalMLXExecutionAuthorized,
            ceiling.additionalMetalExecutionAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.newCppImplementationAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

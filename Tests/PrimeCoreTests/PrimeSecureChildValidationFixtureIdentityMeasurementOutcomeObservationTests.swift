// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRetirementCeiling()
        throws
    {
        requireSendable(Observation.self)
        let observation = Observation.frozenV1

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.schemaID,
            "prime_secure_child_validation_fixture_identity_measurement_outcome_observation_v1"
        )
        XCTAssertEqual(observation.schemaID, observation.observationID)
        XCTAssertEqual(
            observation.observationKind,
            "append_only_exact_main_invocation_admission_refusal_observation_and_irreversible_measurement_retirement"
        )

        let authority = observation.authorityClosure
        XCTAssertEqual(
            authority.authorityID,
            PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            authority.canonicalByteCount,
            PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1
                .canonicalByteCount
        )
        XCTAssertEqual(
            authority.canonicalSHA256,
            PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1
                .canonicalSHA256
        )
        XCTAssertEqual(
            authority.mergeRevision,
            "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7"
        )
        XCTAssertEqual(
            authority.mergeTree,
            "9b8a784e605967141f159a5f8c953a0096cf1f8d"
        )
        XCTAssertEqual(
            authority.orderedParentRevisions,
            [
                "75b14056b75e8af6af0c070453f7ef14ac10a063",
                "690b5047e553d6869e3dc7c97ad858a349175b2c",
            ]
        )
        XCTAssertEqual(authority.pullRequestNumber, 129)
        XCTAssertEqual(authority.pullRequestRunID, 32_377_463_484)
        XCTAssertEqual(authority.pullRequestRunNumber, 157)
        XCTAssertEqual(authority.pullRequestCheckSuiteID, 87_769_199_371)
        XCTAssertEqual(authority.exactMainRunID, 32_378_266_794)
        XCTAssertEqual(authority.exactMainRunNumber, 158)
        XCTAssertEqual(authority.exactMainCheckSuiteID, 87_771_501_000)
        XCTAssertEqual(authority.exactMainActiveJobID, 96_454_836_227)
        XCTAssertEqual(authority.exactMainReviewedJobID, 96_456_203_644)
        XCTAssertEqual(authority.exactMainConclusion, "success")
        XCTAssertEqual(authority.exactMainRootTestCount, 85)
        XCTAssertEqual(authority.exactMainIsolatedTestCount, 6)
        XCTAssertEqual(authority.exactMainFocusedWholeTestCount, 91)
        XCTAssertEqual(authority.exactMainRetainedLiveTestCount, 46)
        XCTAssertEqual(authority.exactMainAggregateTestCount, 137)
        XCTAssertTrue(authority.githubSignatureVerified)
        XCTAssertEqual(authority.githubSignatureReason, "valid")
        XCTAssertEqual(
            authority.githubSignatureVerifiedAt,
            "2026-08-20T14:07:36Z"
        )
        XCTAssertTrue(authority.exactMainClosureEstablished)
        assertFile(
            authority.source,
            path:
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift",
            status: "A",
            mode: "100644",
            blob: "1d81d4a29f06fbc18ca3c1a97742159b5280837e",
            bytes: 124_073,
            lf: 2_175,
            sha:
                "ff043520c144196532885ca79f0b2047cd8d28ac61ca544d259f140ed4e6aea4"
        )

        let sources = observation.mechanicsSourceBindings
        XCTAssertEqual(sources.count, 5)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
                "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
            ]
        )
        XCTAssertEqual(
            sources.map(\.mechanicsGitStatus),
            ["M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(
            sources.map(\.gitMode),
            ["100755", "100644", "100644", "100755", "100644"]
        )
        XCTAssertEqual(
            sources.map(\.gitBlob),
            [
                "0ea5aefc1b5230f2719e5cc518b37d5e71d1b616",
                "5998767711e6c841de0e7b4ee73fb68da2194554",
                "3fc893d5fc72455a933f74607b7ca1859e874ea6",
                "076e9dd60ed692689ebfe443b7911dd4acfe9bdc",
                "ead815d5f051ed1308f360aa701a1a5d389556c6",
            ]
        )
        XCTAssertEqual(
            sources.map(\.byteCount),
            [1_390_273, 173_732, 546, 72_908, 16_967]
        )
        XCTAssertEqual(sources.map(\.lfByteCount), [22_482, 741, 13, 1_468, 473])
        XCTAssertTrue(sources.allSatisfy { $0.crByteCount == 0 })
        XCTAssertEqual(Set(sources.map(\.path)).count, 5)
        XCTAssertTrue(
            sources.allSatisfy {
                isLowercaseHex($0.gitBlob, count: 40)
                    && isLowercaseHex($0.sha256, count: 64)
                    && !$0.role.isEmpty
            }
        )

        let mechanics = observation.mechanicsClosure
        XCTAssertEqual(mechanics.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(mechanics.ref, "refs/heads/main")
        XCTAssertEqual(mechanics.pullRequestNumber, 130)
        XCTAssertEqual(mechanics.baseRevision, authority.mergeRevision)
        XCTAssertEqual(mechanics.baseTree, authority.mergeTree)
        XCTAssertEqual(
            mechanics.reviewedHeadRevision,
            "f5db7101cf3538daae103ba56601a509ad8bad80"
        )
        XCTAssertEqual(
            mechanics.reviewedHeadTree,
            "9dd884bfe5b520a67c2944d8f8f79851a714519e"
        )
        XCTAssertEqual(
            mechanics.reviewedHeadOrderedParentRevisions,
            [mechanics.baseRevision]
        )
        XCTAssertEqual(
            mechanics.mergeRevision,
            "5623872afda1895630ba0eacdfab76961c5e755b"
        )
        XCTAssertEqual(mechanics.mergeTree, mechanics.reviewedHeadTree)
        XCTAssertEqual(
            mechanics.orderedMergeParentRevisions,
            [mechanics.baseRevision, mechanics.reviewedHeadRevision]
        )
        XCTAssertTrue(mechanics.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(mechanics.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(mechanics.githubSignatureVerified)
        XCTAssertEqual(mechanics.githubSignatureReason, "valid")
        XCTAssertEqual(
            mechanics.githubSignatureVerifiedAt,
            "2026-08-20T17:19:27Z"
        )
        XCTAssertEqual(mechanics.mergedAt, "2026-08-20T17:19:27Z")
        XCTAssertEqual(mechanics.exactChangedPathCount, 5)
        XCTAssertEqual(mechanics.changedManifestPathCount, 0)
        XCTAssertEqual(mechanics.changedLockPathCount, 0)
        XCTAssertEqual(mechanics.pullRequestRunID, 32_396_145_283)
        XCTAssertEqual(mechanics.pullRequestRunNumber, 159)
        XCTAssertEqual(mechanics.pullRequestRunAttempt, 1)
        XCTAssertEqual(mechanics.pullRequestCheckSuiteID, 87_822_394_132)
        XCTAssertEqual(mechanics.pullRequestConclusion, "success")
        XCTAssertNil(mechanics.pullRequestPreviousAttemptURL)
        XCTAssertEqual(mechanics.matchingPullRequestRunCountForHead, 1)
        XCTAssertEqual(mechanics.pullRequestActiveJobID, 96_513_307_446)
        XCTAssertEqual(mechanics.pullRequestActiveJobConclusion, "success")
        XCTAssertEqual(mechanics.pullRequestReviewedJobID, 96_514_561_832)
        XCTAssertEqual(mechanics.pullRequestReviewedJobConclusion, "skipped")
        XCTAssertEqual(mechanics.pullRequestReviewedJobStepCount, 0)
        XCTAssertEqual(mechanics.pullRequestArtifactCount, 0)

        let run = observation.workflowRun
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(
            run.workflowPath,
            ".github/workflows/prime-active-root-quarantine.yml"
        )
        XCTAssertEqual(run.runID, 32_396_967_956)
        XCTAssertEqual(run.runNumber, 160)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, 87_824_712_564)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.ref, "refs/heads/main")
        XCTAssertEqual(run.headSHA, mechanics.mergeRevision)
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.createdAt, "2026-08-20T17:19:29Z")
        XCTAssertEqual(run.startedAt, "2026-08-20T17:19:29Z")
        XCTAssertEqual(run.updatedAt, "2026-08-20T18:10:40Z")
        XCTAssertNil(run.previousAttemptURL)
        XCTAssertEqual(run.matchingPushRunCountForHead, 1)
        XCTAssertEqual(run.retryCount, 0)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertEqual(run.actionsArtifactCount, 0)
        XCTAssertEqual(
            run.runURL,
            "https://github.com/Ergentics/ergentics-prime/actions/runs/32396967956"
        )

        let active = observation.activeRootJob
        XCTAssertEqual(active.jobID, 96_515_945_260)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.startedAt, "2026-08-20T17:19:32Z")
        XCTAssertEqual(active.completedAt, "2026-08-20T17:24:01Z")
        XCTAssertEqual(active.steps.count, 7)
        XCTAssertEqual(active.steps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(active.steps.allSatisfy { $0.conclusion == "success" })

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.jobID, 96_517_280_624)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.startedAt, "2026-08-20T17:24:05Z")
        XCTAssertEqual(reviewed.completedAt, "2026-08-20T18:10:39Z")
        XCTAssertEqual(reviewed.steps.count, 8)
        XCTAssertEqual(reviewed.steps.map(\.number), Array(1 ... 8))
        XCTAssertEqual(reviewed.steps.filter { $0.conclusion == "failure" }.map(\.number), [7])
        XCTAssertEqual(
            reviewed.steps[6].name,
            "Measure the native validation-fixture identity once"
        )
        XCTAssertEqual(reviewed.steps[6].startedAt, "2026-08-20T18:10:23Z")
        XCTAssertEqual(reviewed.steps[6].completedAt, "2026-08-20T18:10:26Z")

        assertLog(
            observation.activeRootConnectorDecodedJobLog,
            job: active.jobID,
            bytes: 353_434,
            lf: 1_909,
            sha:
                "458adafef5adfaa840c5b1b373f326bd4749c3e9465e4263f4ffd58c52a254dc"
        )
        assertLog(
            observation.reviewedMainConnectorDecodedJobLog,
            job: reviewed.jobID,
            bytes: 10_339_505,
            lf: 79_061,
            sha:
                "31fd2e9de6472f2e820acbd85ed0b44c994256e825f7a5372abfbbb9809ff633"
        )

        let toolchain = observation.sanitizedToolchainObservation
        XCTAssertEqual(toolchain.sourceJobID, reviewed.jobID)
        XCTAssertEqual(toolchain.sourceStepNumber, 2)
        XCTAssertEqual(toolchain.sourceStepConclusion, "success")
        XCTAssertEqual(toolchain.architecture, "arm64")
        XCTAssertEqual(toolchain.productName, "macOS")
        XCTAssertEqual(toolchain.productVersion, "26.5.2")
        XCTAssertEqual(toolchain.buildVersion, "25F84")
        XCTAssertEqual(toolchain.xcodeVersion, "26.6")
        XCTAssertEqual(toolchain.xcodeBuildVersion, "17F113")
        XCTAssertEqual(
            toolchain.swiftVersion,
            "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)"
        )
        XCTAssertEqual(toolchain.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(
            toolchain.swiftDriverVersionLine,
            "swift-driver version: 1.148.6 "
        )
        XCTAssertEqual(toolchain.sdkVersion, "26.5")
        XCTAssertEqual(toolchain.eachExactSanitizedLineOccurrenceCount, 1)
        let toolchainData = Data(toolchain.orderedRawSanitizedBlock.utf8)
        XCTAssertEqual(toolchainData.count, 237)
        XCTAssertEqual(toolchain.rawSanitizedBlockLFByteCount, 10)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: toolchainData),
            "1427ae05f58467e5c1f0f967405f022288d75d6e12b5382416e463d4ecf17e54"
        )

        let tests = observation.testAndOperationalObservation
        XCTAssertEqual(tests.activeLatinTestCount, 116)
        XCTAssertEqual(tests.activeLatinFailureCount, 0)
        XCTAssertEqual(tests.activeLatinSkipCount, 0)
        XCTAssertEqual(tests.rootTestCount, 85)
        XCTAssertEqual(tests.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(tests.isolatedTestCount, 6)
        XCTAssertEqual(tests.focusedWholeTestCount, 91)
        XCTAssertEqual(tests.retainedMetalTestCount, 44)
        XCTAssertEqual(tests.retainedMaintainedRuntimeTestCount, 1)
        XCTAssertEqual(tests.retainedTokenizerTestCount, 1)
        XCTAssertEqual(tests.retainedLiveTestCount, 46)
        XCTAssertEqual(tests.aggregateTestCount, 137)
        XCTAssertEqual(tests.xctestFailureCount, 0)
        XCTAssertEqual(tests.xctestSkipCount, 0)
        XCTAssertEqual(tests.measurementLauncherInvocationCount, 1)
        XCTAssertEqual(
            tests.measurementStepFixtureProductBuildCommandAttemptCount,
            0
        )
        XCTAssertEqual(tests.measurementStepShowBinPathCommandAttemptCount, 0)
        XCTAssertEqual(tests.measurementStepEvaluatorCompilerInvocationCount, 0)
        XCTAssertEqual(tests.measurementStepEvaluatorInvocationCount, 0)
        XCTAssertEqual(tests.measurementStepFixtureExecutionCount, 0)
        XCTAssertEqual(tests.measurementStepAdapterExecutionCount, 0)
        XCTAssertEqual(tests.measurementStepLeaseAcquisitionCount, 0)
        XCTAssertEqual(tests.measurementStepModelExecutionCount, 0)
        XCTAssertEqual(tests.measurementStepMLXExecutionCount, 0)
        XCTAssertEqual(tests.measurementStepMetalExecutionCount, 0)
        XCTAssertEqual(tests.measurementStepPythonInvocationCount, 0)
        XCTAssertEqual(tests.measurementStepCppInvocationCount, 0)

        let identity = observation.hostedRecordIdentity
        let record = identity.record
        XCTAssertEqual(
            identity.prefix,
            "prime-secure-child validation-fixture-identity measurement: "
        )
        XCTAssertEqual(identity.prefixByteCount, 60)
        XCTAssertEqual(identity.canonicalJSONByteCount, 1_682)
        XCTAssertEqual(
            identity.canonicalJSONSHA256,
            "f90db08bab2216053fd4bc9cc4c1439da81fc0f3b3c62dccd9c06ed454591dd8"
        )
        XCTAssertEqual(identity.totalLineByteCountIncludingTerminalLF, 1_743)
        XCTAssertEqual(
            identity.totalLineSHA256IncludingTerminalLF,
            "4da4a0ca7e0e2b2e09f96a9c1717faf632499e687b30e589c3c0339712fa27d0"
        )
        XCTAssertEqual(identity.exactOccurrenceCount, 1)
        XCTAssertEqual(identity.exactFieldCount, 43)
        XCTAssertEqual(identity.emittedAt, "2026-08-20T18:10:26.4744800Z")
        XCTAssertEqual(
            identity.physicalTimestampedLineReconstruction,
            "emitted_at_then_one_ascii_space_then_prefix_then_canonical_json_then_one_lf"
        )
        XCTAssertEqual(
            identity.physicalTimestampedLineByteCountIncludingTerminalLF,
            1_772
        )
        XCTAssertEqual(
            identity.physicalTimestampedLineSHA256IncludingTerminalLF,
            "36ec9a6daebeea2b80c88c9667b6c0ade1fac3a0c24b763c825eb0707fce6447"
        )
        XCTAssertEqual(identity.reviewedDecodedLogPhysicalLineNumber, 79_059)
        XCTAssertTrue(identity.workflowConclusionMatchesResultInvariant)
        XCTAssertTrue(identity.acceptingRecord)

        let exactRecordJSON =
            #"{"actions_artifact":false,"authority_canonical_sha256":"67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43","authority_id":"ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1","build_a_command_state":"not_attempted","build_b_command_state":"not_attempted","byte_count_equal":"unavailable","canary_execution_performed":false,"current_pin_byte_count_match":"unavailable","current_pin_full_match":"unavailable","current_pin_sha256_match":"unavailable","durable_evidence":false,"evaluator_command_state":"not_attempted","evaluator_compile_state":"not_attempted","evaluator_execution_observation":"observed_false","evaluator_shell_wait_status":null,"exact_revision":"5623872afda1895630ba0eacdfab76961c5e755b","fixture_a_build_platform_packed":null,"fixture_a_byte_count":null,"fixture_a_macho_uuid":null,"fixture_a_minimum_os_packed":null,"fixture_a_sdk_packed":null,"fixture_a_sha256":null,"fixture_b_build_platform_packed":null,"fixture_b_byte_count":null,"fixture_b_macho_uuid":null,"fixture_b_minimum_os_packed":null,"fixture_b_sdk_packed":null,"fixture_b_sha256":null,"fixture_execution_count":0,"full_bytes_equal":"unavailable","macho_identity_equal":"unavailable","measurement_attempt_consumed":false,"opportunity_state":"retired","pin_mutation_performed":false,"raw_build_output_or_error_field_count":0,"raw_path_count":0,"result_code":"INVOCATION_ADMISSION_REFUSED","schema_id":"prime_secure_child_validation_fixture_identity_measurement_outer_observation_v1","schema_version":1,"scientific_outcome":"not_established","sha256_equal":"unavailable","show_bin_a_command_state":"not_attempted","show_bin_b_command_state":"not_attempted"}"#
        let recordData = try record.canonicalData()
        XCTAssertEqual(recordData.count, 1_682)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: recordData),
            identity.canonicalJSONSHA256
        )
        XCTAssertEqual(String(data: recordData, encoding: .utf8), exactRecordJSON)
        var lineData = Data(identity.prefix.utf8)
        lineData.append(recordData)
        lineData.append(0x0A)
        XCTAssertEqual(lineData.count, 1_743)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: lineData),
            identity.totalLineSHA256IncludingTerminalLF
        )
        var physicalLineData = Data(identity.emittedAt.utf8)
        physicalLineData.append(0x20)
        physicalLineData.append(lineData)
        XCTAssertEqual(physicalLineData.count, 1_772)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: physicalLineData),
            identity.physicalTimestampedLineSHA256IncludingTerminalLF
        )
        XCTAssertEqual(record.resultCode, "INVOCATION_ADMISSION_REFUSED")
        XCTAssertFalse(record.measurementAttemptConsumed)
        XCTAssertEqual(record.opportunityState, "retired")
        XCTAssertEqual(record.fixtureExecutionCount, 0)
        XCTAssertEqual(
            [
                record.buildACommandState,
                record.showBinACommandState,
                record.buildBCommandState,
                record.showBinBCommandState,
                record.evaluatorCompileState,
                record.evaluatorCommandState,
            ],
            Array(repeating: "not_attempted", count: 6)
        )
        XCTAssertEqual(record.evaluatorExecutionObservation, "observed_false")
        XCTAssertNil(record.evaluatorShellWaitStatus)
        XCTAssertTrue(recordIdentityOptionals(record).allSatisfy { $0 == nil })
        XCTAssertEqual(
            [
                record.byteCountEqual,
                record.sha256Equal,
                record.fullBytesEqual,
                record.machoIdentityEqual,
                record.currentPinByteCountMatch,
                record.currentPinSHA256Match,
                record.currentPinFullMatch,
            ],
            Array(repeating: "unavailable", count: 7)
        )
        XCTAssertEqual(record.rawPathCount, 0)
        XCTAssertEqual(record.rawBuildOutputOrErrorFieldCount, 0)
        XCTAssertFalse(record.actionsArtifact)
        XCTAssertFalse(record.durableEvidence)
        XCTAssertFalse(record.pinMutationPerformed)
        XCTAssertFalse(record.canaryExecutionPerformed)

        let inference = observation.invocationRefusalInference
        XCTAssertEqual(inference.resultCode, record.resultCode)
        XCTAssertFalse(inference.hostedRecordPublishesFailedPredicate)
        XCTAssertFalse(inference.sanitizedReviewedLogPublishesFailedPredicate)
        XCTAssertFalse(inference.failureCauseDirectlyEstablished)
        XCTAssertEqual(
            inference.classification,
            "source_and_checkout_depth_semantics_inference_not_direct_hosted_observation"
        )
        XCTAssertEqual(inference.inferenceBasis.count, 5)
        XCTAssertEqual(inference.checkoutFetchDepth, 2)
        XCTAssertEqual(inference.exactRevision, run.headSHA)
        XCTAssertEqual(
            inference.mechanicsSecondParentRevision,
            mechanics.reviewedHeadRevision
        )
        XCTAssertEqual(inference.authorityClosureRevision, authority.mergeRevision)
        XCTAssertEqual(inference.launcherRequiredRevisionExpression, "exact_revision^2^1")
        XCTAssertEqual(
            inference.launcherRequiredExpressionExpectedRevision,
            authority.mergeRevision
        )
        XCTAssertEqual(inference.launcherSourceLine, 765)
        XCTAssertFalse(inference.authorityClosureWasExplicitProofOnlyWant)
        XCTAssertFalse(inference.mechanicsHeadWasExplicitProofOnlyWant)
        XCTAssertFalse(inference.inferenceAuthorizesRepairRetryRerunOrReplacement)

        XCTAssertEqual(observation.resultDispositions.count, 25)
        XCTAssertEqual(Set(observation.resultDispositions.map(\.resultCode)).count, 25)
        XCTAssertEqual(
            observation.resultDispositions.map(\.resultCode),
            PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1
                .frozenV1.futureMeasurementContract.hostedRecord.exactResultCodes
        )
        XCTAssertEqual(
            observation.resultDispositions.filter {
                $0.workflowConclusion == "success"
            }.map(\.resultCode),
            ["PASS_IDENTICAL_CURRENT_PIN", "PASS_IDENTICAL_DIFFERENT_PIN"]
        )
        XCTAssertEqual(
            observation.resultDispositions.map(\.workflowConclusion),
            ["success", "success"] + Array(repeating: "failure", count: 23)
        )
        XCTAssertEqual(
            observation.resultDispositions.map(\.category),
            [
                "identical_current_pin",
                "identical_different_pin",
                "nondeterministic",
                "invocation_admission_refusal",
                "admission_refusal",
                "admission_refusal",
                "admission_refusal",
                "admission_refusal",
                "build_refusal",
                "build_refusal",
                "transport_refusal",
                "admission_refusal",
                "build_refusal",
                "build_refusal",
                "transport_refusal",
                "admission_refusal",
                "evaluator_refusal",
                "evaluator_refusal",
                "evaluator_refusal",
                "evaluator_refusal",
                "transport_refusal",
                "evaluator_refusal",
                "evaluator_refusal",
                "capture_refusal",
                "fail_closed_pre_command_refusal",
            ]
        )
        XCTAssertEqual(
            observation.resultDispositions.map(
                \.separateNoMutationConfirmationAuthorityEligible
            ),
            [true, true] + Array(repeating: false, count: 23)
        )
        XCTAssertEqual(
            observation.resultDispositions.map(
                \.separatePinRepairAuthorityEligible
            ),
            [false, true] + Array(repeating: false, count: 23)
        )
        XCTAssertTrue(
            observation.resultDispositions.allSatisfy {
                !$0.canaryDirectlyAuthorized
            }
        )
        let actualDisposition = try XCTUnwrap(
            observation.resultDispositions.first {
                $0.resultCode == record.resultCode
            }
        )
        XCTAssertEqual(actualDisposition.workflowConclusion, "failure")
        XCTAssertFalse(actualDisposition.separateNoMutationConfirmationAuthorityEligible)
        XCTAssertFalse(actualDisposition.separatePinRepairAuthorityEligible)

        let absent = observation.absentOrExternallyTerminatedRecordContract
        XCTAssertEqual(absent.externallyTerminatedRecordCardinality, "zero_or_one")
        XCTAssertEqual(absent.launcherNotReachedRecordCount, 0)
        XCTAssertEqual(absent.orderedPermittedClassifications.count, 4)
        XCTAssertTrue(absent.causeMustNotBeInventedBeyondActionsAndSanitizedLog)
        XCTAssertEqual(absent.attemptConsumptionWithoutSeparateProof, "unavailable")
        XCTAssertFalse(absent.measurementEstablished)
        XCTAssertFalse(absent.fixtureIdentityEstablished)
        XCTAssertFalse(absent.repeatBuildDeterminismEstablished)
        XCTAssertFalse(absent.currentPinComparisonEstablished)
        XCTAssertFalse(
            absent.presentRecordUnderCancelledTimedOutOrNonmatchingConclusionAccepting
        )
        XCTAssertTrue(absent.opportunityRetired)
        XCTAssertFalse(absent.retryAuthorized)
        XCTAssertFalse(absent.rerunAuthorized)
        XCTAssertFalse(absent.replacementMeasurementAuthorized)

        let outcome = observation.outcomeBoundary
        XCTAssertEqual(outcome.resultCode, record.resultCode)
        XCTAssertTrue(outcome.launcherControlledTerminalRecordEstablished)
        XCTAssertTrue(outcome.hostedRecordIntegrityEstablished)
        XCTAssertTrue(outcome.workflowFailureEstablished)
        XCTAssertFalse(outcome.measurementAttemptConsumed)
        XCTAssertFalse(outcome.fixtureIdentityEstablished)
        XCTAssertFalse(outcome.repeatBuildDeterminismEstablished)
        XCTAssertFalse(outcome.currentPinByteCountMatchEstablished)
        XCTAssertFalse(outcome.currentPinSHA256MatchEstablished)
        XCTAssertFalse(outcome.currentPinFullMatchEstablished)
        XCTAssertEqual(outcome.fixtureExecutionCount, 0)
        XCTAssertEqual(outcome.scientificOutcome, "not_established")
        XCTAssertFalse(outcome.durableEvidenceEstablished)
        XCTAssertEqual(outcome.actionsArtifactCount, 0)
        XCTAssertEqual(outcome.opportunityState, "retired")
        XCTAssertEqual(outcome.noRerunProof.count, 6)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertEqual(retirement.exactChangedPathCount, 5)
        XCTAssertEqual(retirement.exactOrderedChangedPaths.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservation.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests.swift",
            ]
        )
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(retirement.reviewedTimeoutBeforeMinutes, 90)
        XCTAssertEqual(retirement.reviewedTimeoutAfterMinutes, 75)
        XCTAssertEqual(retirement.activeTimeoutMinutes, 45)
        XCTAssertEqual(retirement.expectedActiveLatinTestCount, 116)
        XCTAssertEqual(retirement.expectedRootTestCount, 86)
        XCTAssertEqual(retirement.expectedIsolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(retirement.expectedIsolatedTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeTestCount, 92)
        XCTAssertEqual(retirement.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(retirement.expectedAggregateTestCount, 138)
        XCTAssertEqual(retirement.expectedEmbeddedProvenanceRecordCount, 524)
        XCTAssertEqual(retirement.expectedMeasurementWorkflowStepCount, 0)
        XCTAssertEqual(retirement.expectedLauncherWorkflowReferenceCount, 0)
        XCTAssertEqual(retirement.expectedLauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedEvaluatorInvocationCount, 0)
        XCTAssertEqual(retirement.expectedHostedRecordCount, 0)
        XCTAssertTrue(retirement.launcherSourcePreservedForAudit)
        XCTAssertTrue(retirement.evaluatorSourcePreservedForAudit)
        XCTAssertEqual(retirement.launcherSource, sources[3])
        XCTAssertEqual(retirement.evaluatorSource, sources[4])
        XCTAssertTrue(retirement.sourceParserMayRetainEvaluatorPathWithoutInvokingIt)
        XCTAssertTrue(retirement.measurementOpportunityRetired)
        XCTAssertTrue(retirement.exactMainRetirementClosureRequired)
        XCTAssertFalse(retirement.retryWithoutNewAuthorityPermitted)
        XCTAssertFalse(retirement.rerunPermitted)
        XCTAssertFalse(retirement.replacementMeasurementPermitted)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.measurementAuthorityExactMainGreenEstablished)
        XCTAssertTrue(ceiling.mechanicsExactMainClosureEstablished)
        XCTAssertTrue(ceiling.exactHostedRecordIntegrityEstablished)
        XCTAssertTrue(ceiling.invocationAdmissionRefusalEstablished)
        XCTAssertTrue(ceiling.likelyRefusalCauseIsInferenceOnly)
        XCTAssertTrue(ceiling.measurementOpportunityRetired)
        XCTAssertTrue(ceiling.exactRetirementRequired)
        XCTAssertTrue(ceiling.sanitizedToolchainObservationEstablished)
        XCTAssertTrue(ceiling.reviewedJobLogIdentityEstablished)
        XCTAssertTrue(ceiling.workflowFailureEstablished)
        XCTAssertTrue(ceiling.currentPatchAddsOnlyPureObservationPair)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 6)
        XCTAssertEqual(
            observation.status,
            "INVOCATION_ADMISSION_REFUSED_exact_main_run160_valid_record_attempt_unconsumed_fixture_identity_determinism_and_pin_relationship_unavailable_opportunity_retired_no_retry_rerun_replacement_repair_confirmation_or_canary"
        )

        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        if Observation.canonicalByteCount == 0 {
            XCTFail(
                "canonical freeze byte_count=\(canonical.count) sha256="
                    + PrimeSHA256.hexDigest(of: canonical)
            )
            return
        }
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

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)

        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue)
            )
            if assertLooseDecodedDriftRejects(
                mutatedData,
                observation: observation
            ) {
                looseDecodedDriftCount += 1
            }
            let nullData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { value in
                    if value is NSNull { return "__null_mutation" }
                    return NSNull()
                })
            )
            if assertLooseDecodedDriftRejects(
                nullData,
                observation: observation
            ) {
                looseDecodedDriftCount += 1
            }
            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path)
            )
            if assertLooseDecodedDriftRejects(
                removedData,
                observation: observation
            ) {
                looseDecodedDriftCount += 1
            }
        }
        XCTAssertGreaterThan(looseDecodedDriftCount, 250)

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var changed = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count
                        where canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            changed = true
                            return array
                        }
                    }
                    return array
                }
            )
            if changed {
                let reorderedData = try assertCanonicalRejects(reordered)
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(
                        reorderedData,
                        observation: observation
                    )
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 8)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_measurement_outcome_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(unknown)
            XCTAssertEqual(
                try JSONDecoder().decode(Observation.self, from: unknownData),
                observation
            )
        }

        var maximumIntegerObject = object
        maximumIntegerObject["schemaVersion"] = NSNumber(value: Int.max)
        let maximumIntegerData = try assertCanonicalRejects(maximumIntegerObject)
        XCTAssertTrue(
            assertLooseDecodedDriftRejects(
                maximumIntegerData,
                observation: observation
            )
        )

        try assertNoncanonicalEncodingsReject(canonical, object: object)
        let oversized = Data(repeating: 0x20, count: 131_073)
        XCTAssertThrowsError(try Observation.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as?
                    PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationError,
                .oversizedEncoding
            )
        }
    }

    private func assertFile(
        _ value: Observation.FileIdentity,
        path: String,
        status: String,
        mode: String,
        blob: String,
        bytes: Int,
        lf: Int,
        sha: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(value.path, path, file: file, line: line)
        XCTAssertEqual(value.mechanicsGitStatus, status, file: file, line: line)
        XCTAssertEqual(value.gitMode, mode, file: file, line: line)
        XCTAssertEqual(value.gitBlob, blob, file: file, line: line)
        XCTAssertEqual(value.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(value.lfByteCount, lf, file: file, line: line)
        XCTAssertEqual(value.crByteCount, 0, file: file, line: line)
        XCTAssertEqual(value.sha256, sha, file: file, line: line)
    }

    private func assertLog(
        _ value: Observation.ConnectorDecodedUTF8JobLogIdentity,
        job: Int,
        bytes: Int,
        lf: Int,
        sha: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(value.jobID, job, file: file, line: line)
        XCTAssertEqual(
            value.bindingKind,
            "connector_decoded_utf8_job_log",
            file: file,
            line: line
        )
        XCTAssertEqual(value.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(value.lfByteCount, lf, file: file, line: line)
        XCTAssertEqual(value.crByteCount, 0, file: file, line: line)
        XCTAssertEqual(value.sha256, sha, file: file, line: line)
        XCTAssertTrue(value.utf8BOMPresent, file: file, line: line)
        XCTAssertTrue(value.terminalLFPresent, file: file, line: line)
        XCTAssertTrue(value.repeatFetchExactlyEqual, file: file, line: line)
        XCTAssertFalse(value.rawArchiveBytesBound, file: file, line: line)
        XCTAssertFalse(value.rawArchiveRetained, file: file, line: line)
    }

    private func recordIdentityOptionals(_ record: Observation.HostedRecord)
        -> [Any?]
    {
        [
            record.evaluatorShellWaitStatus,
            record.fixtureABuildPlatformPacked,
            record.fixtureAByteCount,
            record.fixtureAMachOUUID,
            record.fixtureAMinimumOSPpacked,
            record.fixtureASDKPacked,
            record.fixtureASHA256,
            record.fixtureBBuildPlatformPacked,
            record.fixtureBByteCount,
            record.fixtureBMachOUUID,
            record.fixtureBMinimumOSPpacked,
            record.fixtureBSDKPacked,
            record.fixtureBSHA256,
        ]
    }

    private func authorityFalseClaims(_ value: Observation.AuthorityCeiling)
        -> [Bool]
    {
        [
            value.filesystemReadAuthorizedByObservationValue,
            value.filesystemWriteAuthorizedByObservationValue,
            value.compilerInvocationAuthorized,
            value.evaluatorInvocationAuthorized,
            value.fixtureBuildAuthorized,
            value.fixtureExecutionAuthorized,
            value.adapterExecutionAuthorized,
            value.leaseAcquisitionAuthorized,
            value.modelExecutionAuthorized,
            value.networkAuthorized,
            value.measurementAttemptConsumed,
            value.measuredFixtureIdentityEstablished,
            value.repeatBuildDeterminismEstablished,
            value.currentPinMatchEstablished,
            value.currentPinMismatchEstablished,
            value.fixturePinMutationAuthorized,
            value.fixturePinMutationPerformed,
            value.pinRepairAuthorityEstablished,
            value.confirmationMeasurementAuthorized,
            value.monitorHeldLeaseCanaryAuthorized,
            value.monitorHeldLeaseCanaryPerformed,
            value.durableEvidenceEstablished,
            value.childLifetimeContinuityEstablished,
            value.physicalMetalReservationEstablished,
            value.mlxDeviceIdentityEstablished,
            value.mlxExecutionAuthorized,
            value.metalExecutionAuthorized,
            value.native300MExecutionAuthorized,
            value.pythonAuthorized,
            value.cppAuthorized,
            value.checkpointAdmissionGranted,
            value.generalTrainingResumeAuthorized,
            value.modelQualityEstablished,
            value.productUseAuthorized,
            value.publicationAuthorized,
            value.retryAuthorized,
            value.rerunAuthorized,
            value.replacementMeasurementAuthorized,
        ]
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
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
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return []
    }

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return []
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
                with: transform
            )
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform
            )
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let remainder = Array(path.dropFirst())
        switch path[0] {
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

    private func canonicalJSONData(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            let integer = number.int64Value
            let incremented = integer.addingReportingOverflow(1)
            return NSNumber(
                value: incremented.overflow
                    ? integer.subtractingReportingOverflow(1).partialValue
                    : incremented.partialValue
            )
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

    private func assertCanonicalRejects(
        _ object: Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        observation: Observation,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Observation.self, from: data),
              loose != observation
        else {
            return false
        }
        XCTAssertThrowsError(try loose.validate(), file: file, line: line)
        XCTAssertThrowsError(try loose.validateExactV1(), file: file, line: line)
        return true
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
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(slashData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: opening))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
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

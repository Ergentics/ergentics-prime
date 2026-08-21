// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import CryptoKit
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeExactRevisionTopologyVerifierAuthorityTests: XCTestCase {
    private typealias Authority =
        PrimeExactRevisionTopologyVerifierAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1

        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_exact_revision_topology_verifier_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_exact_revision_topology_verifier_authority_v1"
        )

        let retired = authority.retiredRun160Closure
        XCTAssertEqual(retired.workflowRunNumber, 160)
        XCTAssertEqual(retired.workflowRunAttempt, 1)
        XCTAssertEqual(retired.workflowConclusion, "failure")
        XCTAssertEqual(retired.resultCode, "INVOCATION_ADMISSION_REFUSED")
        XCTAssertEqual(retired.hostedRecordCount, 1)
        XCTAssertFalse(retired.measurementAttemptConsumed)
        XCTAssertEqual(retired.opportunityState, "retired")
        XCTAssertEqual(retired.scientificOutcome, "not_established")
        XCTAssertEqual(retired.fixtureExecutionCount, 0)
        XCTAssertEqual(retired.retryCount, 0)
        XCTAssertEqual(retired.rerunCount, 0)
        XCTAssertTrue(retired.depthTwoCheckoutObserved)
        XCTAssertTrue(retired.retiredLauncherUsedMultiHopAncestryRevspec)
        XCTAssertTrue(retired.rawCommitHeadersWouldExposeRequiredOIDs)
        XCTAssertFalse(retired.likelyRefusalCauseDirectlyEstablished)
        XCTAssertFalse(retired.refusalAuthorizesRepairRetryRerunOrReplacement)
        XCTAssertTrue(retired.retirementMergedAndExactMainGreen)
        XCTAssertEqual(
            retired.mechanicsMergeRevision,
            "5623872afda1895630ba0eacdfab76961c5e755b"
        )
        XCTAssertEqual(
            retired.orderedMechanicsMergeParentOIDs,
            [
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                "f5db7101cf3538daae103ba56601a509ad8bad80",
            ]
        )
        XCTAssertEqual(
            retired.orderedMechanicsReviewedHeadParentOIDs,
            ["fe0ad36a9163aaa0e03478f5556dfb34b70e24e7"]
        )

        let current = authority.currentExactMainClosure
        XCTAssertEqual(current.pullRequestNumber, 131)
        XCTAssertEqual(
            current.mergeRevision,
            "6a811d3029bdb77e038750694fbf10eec0f358f8"
        )
        XCTAssertEqual(
            current.mergeTree,
            "2d07d669ce804433f2c6fd15ca3ccca52f53bcf6"
        )
        XCTAssertEqual(
            current.orderedMergeParentOIDs,
            [
                "5623872afda1895630ba0eacdfab76961c5e755b",
                "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
            ]
        )
        XCTAssertTrue(current.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(current.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(current.githubSignatureVerified)
        XCTAssertEqual(current.githubSignatureReason, "valid")
        XCTAssertEqual(current.githubSignatureVerifiedAt, "2026-08-20T19:33:23Z")
        XCTAssertEqual(current.pullRequestRunID, 32_408_268_746)
        XCTAssertEqual(current.pullRequestRunNumber, 161)
        XCTAssertEqual(current.pullRequestRunAttempt, 1)
        XCTAssertEqual(current.pullRequestCheckSuiteID, 87_857_160_513)
        XCTAssertEqual(current.pullRequestConclusion, "success")
        XCTAssertNil(current.pullRequestPreviousAttemptURL)
        XCTAssertEqual(current.pullRequestActiveRootJobID, 96_552_418_667)
        XCTAssertEqual(current.pullRequestActiveRootJobConclusion, "success")
        XCTAssertEqual(current.pullRequestReviewedMainJobID, 96_553_842_289)
        XCTAssertEqual(current.pullRequestReviewedMainJobConclusion, "skipped")
        XCTAssertEqual(current.pullRequestReviewedMainJobStepCount, 0)
        XCTAssertEqual(current.pullRequestActionsArtifactCount, 0)
        XCTAssertEqual(current.exactMainRunNumber, 162)
        XCTAssertEqual(current.exactMainRunAttempt, 1)
        XCTAssertEqual(current.exactMainConclusion, "success")
        XCTAssertEqual(current.exactMainActiveRootJobConclusion, "success")
        XCTAssertEqual(current.exactMainReviewedMainJobConclusion, "success")
        XCTAssertEqual(current.exactMainActionsArtifactCount, 0)

        let header = authority.commitHeaderContract
        XCTAssertEqual(header.repositoryObjectFormat, "sha1")
        XCTAssertEqual(header.literalOIDEncoding, "lowercase_ascii_hex")
        XCTAssertEqual(header.literalOIDCharacterCount, 40)
        XCTAssertFalse(header.uppercaseOIDAccepted)
        XCTAssertFalse(header.abbreviatedOIDAccepted)
        XCTAssertFalse(header.symbolicRefAccepted)
        XCTAssertFalse(header.refNameAccepted)
        XCTAssertFalse(header.ancestryOperatorAccepted)
        XCTAssertEqual(header.replaceObjectsDisabledEnvironment, "GIT_NO_REPLACE_OBJECTS=1")
        XCTAssertEqual(header.lazyFetchDisabledEnvironment, "GIT_NO_LAZY_FETCH=1")
        XCTAssertFalse(header.replacementRefsMayAffectObservation)
        XCTAssertFalse(header.graftsFileMayContributeTopologyFacts)
        XCTAssertEqual(header.localeEnvironment, "LC_ALL=C")
        XCTAssertEqual(
            header.exactFixedToolPaths,
            [
                "/bin/bash", "/usr/bin/git", "/usr/bin/env",
                "/usr/bin/mktemp", "/usr/bin/stat", "/usr/bin/xcrun",
            ]
        )
        XCTAssertEqual(
            header.classifierSourcePath,
            ".github/scripts/PrimeExactRevisionTopologyClassifier.swift"
        )
        XCTAssertEqual(header.classifierRequiredImports, ["CryptoKit", "Darwin", "Foundation"])
        XCTAssertEqual(header.classifierCompileArgumentVector.first, "/usr/bin/env")
        XCTAssertTrue(header.classifierCompileArgumentVector.contains("swiftc"))
        let classifierExecutable =
            "<validated_private_compiler_root>/prime-exact-revision-topology-classifier"
        XCTAssertEqual(header.classifierPrivateExecutableLeaf, classifierExecutable)
        XCTAssertEqual(header.classifierCompileArgumentVector.last, classifierExecutable)
        XCTAssertEqual(header.classifierExecutionArgumentPrefix, [classifierExecutable])
        XCTAssertEqual(
            header.classifierCleanEnvironmentArgumentVectorPrefix.last,
            classifierExecutable
        )
        XCTAssertTrue(header.classifierSourceIdentityAdmissionRequired)
        XCTAssertTrue(header.compilerAndClassifierUseEmptyEnvironment)
        XCTAssertEqual(header.compilerOrImportFailureResultCode, "TOPOLOGY_VERIFIER_UNAVAILABLE")
        XCTAssertEqual(header.exactObjectPreprobeArgumentVector.count, 15)
        XCTAssertTrue(
            header.exactObjectPreprobeArgumentVector.contains(
                "TMPDIR=<validated_private_compiler_root>"
            )
        )
        XCTAssertTrue(header.objectPreprobeInputUsesBashBuiltinPrintf)
        XCTAssertEqual(header.exactGitObjectTypeTokens, ["blob", "commit", "tag", "tree"])
        XCTAssertTrue(header.exactObjectPreprobeOutputGrammar.contains("phase13"))
        XCTAssertEqual(header.objectPreprobeStatusRequired, 0)
        XCTAssertEqual(header.maximumObjectPreprobeOutputByteCount, 1_024)
        XCTAssertEqual(
            header.exactRepositoryFormatObservationArgumentVector.last,
            "--show-object-format=storage"
        )
        XCTAssertEqual(header.exactRepositoryFormatSuccessOutput, "sha1_one_lf")
        XCTAssertEqual(header.objectTypeRequired, "commit")
        XCTAssertEqual(header.maximumCommitObjectByteCount, 1_048_576)
        XCTAssertEqual(header.classifierBoundedReadLimitByteCount, 1_048_577)
        XCTAssertEqual(header.maximumVerificationRequestCount, 8)
        XCTAssertEqual(header.maximumParentCountPerCommit, 8)
        XCTAssertTrue(
            header.classifierActualParsedParentCountBound.contains(
                "actual_count_above_the_admitted_expected_maximum_8"
            )
        )
        XCTAssertEqual(header.requestRoleASCIIGrammar, "^[a-z][a-z0-9_]{0,63}$")
        XCTAssertEqual(header.maximumRequestRoleUTF8ByteCount, 64)
        XCTAssertEqual(header.rawCatFileContentInvocationCountPerParsedObject, 1)
        XCTAssertTrue(header.catFileStdoutPipedDirectlyToClassifierStdin)
        XCTAssertEqual(header.filesystemCapturePathCount, 0)
        XCTAssertTrue(header.classifierReadsLogicalStandardInputStreamOnceToEOF)
        XCTAssertTrue(header.classifierDrainsStandardInputToEOFOnEveryNonReadFailureOutcome)
        XCTAssertTrue(header.classifierRetriesInterruptedStandardInputReads)
        XCTAssertTrue(header.classifierPerformsNoFilesystemOperation)
        XCTAssertTrue(header.classifierParsesBytesWithoutUTF8Decoding)
        XCTAssertTrue(header.classifierComputesSHA1OverPrefixAndExactWithinCapAdvertisedInputBytes)
        XCTAssertTrue(header.classifierComputedOIDMustEqualLiteralOID)
        XCTAssertTrue(header.classifierWithinCapExactAdvertisedInputByteArrayIsSoleHashAndParseSource)
        XCTAssertTrue(header.classifierUsesDarwinProcPIDInfoFDInventory)
        XCTAssertEqual(header.classifierMaximumFDInventoryByteCount, 16_384)
        XCTAssertEqual(header.classifierMaximumFDClosurePassCount, 4)
        XCTAssertEqual(header.classifierFDInventoryAllocationSlackRecordCount, 8)
        XCTAssertTrue(header.classifierFDInitialSizeUsesCheckedCapMinusSlackArithmetic)
        XCTAssertTrue(header.classifierFDFilledSizeMustBeStrictlyBelowCapacity)
        XCTAssertTrue(header.classifierFinalSnapshotMustBeCompleteAndExactlyFD012)
        XCTAssertTrue(header.classifierFDInventoryRequiresNonnegativeMultipleOfStride)
        XCTAssertTrue(header.classifierRejectsNegativeEnumeratedFD)
        XCTAssertTrue(header.classifierRequiresNoFDAtOrAbove3FixedPoint)
        XCTAssertEqual(header.classifierFinalFDSet, [0, 1, 2])
        XCTAssertTrue(header.classifierFDClosureClaimAppliesOnlyAtFinalSnapshot)
        XCTAssertTrue(header.classifierIsSingleThreaded)
        XCTAssertFalse(header.classifierInstallsSignalHandler)
        XCTAssertTrue(header.classifierReadsRawBytesFromDarwinFD0AfterClosure)
        XCTAssertTrue(header.classifierHasNoAdditionalStdinPipeWriterAtOrAboveFD3)
        XCTAssertEqual(header.exactPipelineStatusCount, 2)
        XCTAssertTrue(header.pipelineRunsUnderTemporarilyDisabledErrexit)
        XCTAssertTrue(header.pipelineStatusesCapturedImmediatelyBeforeErrexitRestore)
        XCTAssertTrue(header.gitNonzeroHasPrecedenceOverClassifierStatus)
        XCTAssertEqual(header.classifierStdoutByteCount, 0)
        XCTAssertEqual(header.classifierStderrByteCount, 0)
        XCTAssertFalse(header.gitCatFileStderrPublished)
        XCTAssertEqual(
            header.gitCatFileStderrSink,
            "private_nonpublished_status_governed_stderr_sink"
        )
        XCTAssertTrue(header.textCapturePreservesTerminalLFBeforeTrailerRemoval)
        XCTAssertEqual(header.batchPreprobePipelineStatusCount, 2)
        XCTAssertEqual(header.exactClassifierExitMappings.count, 16)
        XCTAssertEqual(Set(header.exactClassifierExitMappings.map(\.exitStatus)).count, 16)
        XCTAssertTrue(header.unknownClassifierExitMapsToObservationFailure)
        XCTAssertEqual(header.compilerInvocationCount, 1)
        XCTAssertEqual(header.compilerBaseEnvironmentKey, "RUNNER_TEMP")
        XCTAssertEqual(header.compilerBaseMaximumUTF8ByteCount, 1_024)
        XCTAssertTrue(header.compilerBaseRejectsLFCRAndControlBytes)
        XCTAssertTrue(header.everyFilesystemPathPassedAsOneQuotedArgument)
        XCTAssertEqual(header.compilerUmask, "0077")
        XCTAssertEqual(header.compilerRootMode, "0700")
        XCTAssertTrue(header.compilerOutputInitiallyAbsentAndNonlink)
        XCTAssertEqual(header.compilerStatusRequired, 0)
        XCTAssertEqual(header.compilerStdoutByteCount, 0)
        XCTAssertEqual(header.compilerStderrByteCount, 0)
        XCTAssertFalse(header.compilerPrivateArtifactsPublishedOrEvidence)
        XCTAssertEqual(header.compilerLauncherCleanupInvocationCount, 0)
        XCTAssertTrue(header.classifierExecutableAdmissionRequired)
        XCTAssertTrue(header.classifierExecutableMustBePrivateRegularNonlink)
        XCTAssertTrue(header.classifierSelfTestRequiredBeforeRawObjectPipeline)
        XCTAssertEqual(header.classifierSelfTestArgumentVector.last, "--self-test")
        XCTAssertEqual(
            header.classifierSelfTestArgumentVector.dropLast().last,
            classifierExecutable
        )
        XCTAssertEqual(header.classifierSelfTestStandardInputSource, "/dev/null")
        XCTAssertEqual(header.classifierSelfTestPayloadByteCount, 47)
        XCTAssertEqual(header.classifierSelfTestGitObjectOID, "60bc2812cc97ab2d2f2c7168aa101f7bfabcbf88")
        XCTAssertEqual(header.classifierSelfTestExpectedExitStatus, 0)
        XCTAssertEqual(header.classifierSelfTestOutputByteCount, 0)
        XCTAssertTrue(header.classifierSelfTestImmediatelyFollowsExecutableAdmission)
        XCTAssertTrue(header.rawClassifierInvocationsRequireSuccessfulSelfTest)
        XCTAssertTrue(header.noBuildOrUntrustedProcessBetweenSelfTestAndRawInvocations)
        XCTAssertEqual(header.interveningBuildInvocationCount, 0)
        XCTAssertTrue(header.allRequestPreprobesCompleteBeforeAnyClassifierInvocation)
        XCTAssertEqual(header.exactPreprobeGuardPhaseRange, Array(13 ... 18))
        XCTAssertEqual(header.exactRawClassifierGuardPhaseRange, Array(19 ... 35))
        XCTAssertEqual(header.preprobeFailureRawClassifierInvocationCount, 0)
        XCTAssertTrue(header.rawStageRequiresEveryRequestAvailableCommitWithinCap)
        XCTAssertTrue(header.allEligibleClassifierOutcomesCollectedBeforeSelection)
        XCTAssertEqual(
            header.globalFailureSelectionOrder,
            "lexicographically_smallest_phase_ordinal_then_request_ordinal"
        )
        XCTAssertFalse(header.stderrPublished)
        XCTAssertTrue(header.commitHeaderEndsAtFirstEmptyLine)
        XCTAssertFalse(header.commitMessageParsed)
        XCTAssertTrue(header.treeHeaderMustBeFirst)
        XCTAssertEqual(header.exactTreeHeaderCount, 1)
        XCTAssertTrue(header.parentHeadersMustBeContiguousImmediatelyAfterTree)
        XCTAssertTrue(header.parentHeaderOrderIsSemantic)
        XCTAssertFalse(header.treeOrParentHeaderPermittedAfterOtherHeader)
        XCTAssertTrue(header.treeAndParentValuesRequireLiteralLowercase40Hex)
        XCTAssertEqual(header.exactHeadersPermittingContinuationLines, ["gpgsig", "gpgsig-sha256", "mergetag"])
        XCTAssertFalse(header.repeatedGPGSigHeaderAccepted)
        XCTAssertFalse(header.repeatedGPGSigSHA256HeaderAccepted)
        XCTAssertTrue(header.repeatedMergetagHeaderAccepted)
        XCTAssertTrue(header.emptySignedContinuationPayloadAccepted)
        XCTAssertFalse(header.signedHeaderContinuationContributesTopologyFacts)
        XCTAssertFalse(header.unattachedContinuationAccepted)
        XCTAssertFalse(header.carriageReturnAccepted)
        XCTAssertFalse(header.NULAccepted)
        XCTAssertTrue(header.exactHeaderByteGrammar.contains("field_line_is_name_SP_value"))
        XCTAssertTrue(header.wholeObjectNULPolicy.contains("opaque_commit_message"))
        XCTAssertTrue(header.carriageReturnPolicy.contains("header"))
        XCTAssertTrue(header.repositoryNativeSHA1CompatibilityPurpose.contains("not_security"))
        XCTAssertFalse(header.SHA1ClaimsCollisionResistance)
        XCTAssertFalse(header.SHA1ClaimsAuthenticity)
        XCTAssertFalse(header.SHA1ClaimsSignatureValidity)
        XCTAssertFalse(header.SHA1ClaimsTopologyTrustWithoutTreeAndParents)
        XCTAssertTrue(header.signedHeaderHandlingIsGrammarOnly)
        XCTAssertFalse(header.futureDualObjectFormatSupportInV1)
        XCTAssertEqual(header.topologyHistoryTraversalInvocationCount, 0)
        XCTAssertEqual(header.mergeBaseInvocationCount, 0)
        XCTAssertEqual(header.revListInvocationCount, 0)
        XCTAssertEqual(header.refResolutionInvocationCount, 0)

        let results = authority.resultClassificationContract
        XCTAssertEqual(results.exactOrderedResultCodes.count, 10)
        XCTAssertTrue(results.exactOrderedResultCodes.contains("TOPOLOGY_REPOSITORY_UNSUPPORTED"))
        XCTAssertEqual(results.exactGuardResultMappings.count, 35)
        XCTAssertEqual(results.exactGuardResultMappings.map(\.phaseOrdinal), Array(1 ... 35))
        XCTAssertTrue(results.phaseMajorThenRequestOrdinalMinorFirstFailureOrder)
        XCTAssertTrue(results.invalidInvocationRejectedBeforeGit)
        XCTAssertTrue(results.objectUnavailableRequiresPositiveMissingObservationForLiteralOID)
        XCTAssertTrue(results.mismatchRequiresAvailableCommitAndSuccessfulHeaderParse)
        XCTAssertTrue(results.noncommitNeverClassifiedAsObjectUnavailable)
        XCTAssertTrue(results.malformedNeverClassifiedAsTopologyMismatch)
        XCTAssertTrue(results.toolOrTransportFailureNeverClassifiedAsObjectUnavailable)
        XCTAssertTrue(results.unsupportedOrNULObjectNeverClassifiedAsTopologyMismatch)
        XCTAssertFalse(results.rawDiagnosticPublished)
        XCTAssertTrue(results.unknownFailureFailsClosed)

        let historical = authority.historicalGitHubShallowEvidence
        XCTAssertEqual(historical.count, 5)
        XCTAssertEqual(historical.map(\.ordinal), Array(1 ... 5))
        XCTAssertTrue(historical.allSatisfy { $0.diagnosticEvidenceOnly })
        XCTAssertTrue(historical.allSatisfy { !$0.dynamicallyReplayedByFutureMatrix })
        let shallowHidden = try XCTUnwrap(historical.first {
            $0.evidenceID == "run160_depth2_shallow_hidden_multi_hop_edge"
        })
        XCTAssertEqual(shallowHidden.fetchDepth, 2)
        XCTAssertEqual(shallowHidden.exactLegacyProbeRevspec, "5623872afda1895630ba0eacdfab76961c5e755b^2^1")
        XCTAssertEqual(shallowHidden.legacyProbeResolved, false)
        XCTAssertTrue(shallowHidden.absentReferencedParentOIDs.isEmpty)
        let genuinelyAbsent = try XCTUnwrap(historical.first {
            $0.evidenceID == "run160_depth2_genuinely_absent_second_parent_object"
        })
        XCTAssertEqual(genuinelyAbsent.absentReferencedParentOIDs, ["690b5047e553d6869e3dc7c97ad858a349175b2c"])

        let matrix = authority.githubDepthTwoMultiWantMatrix
        XCTAssertEqual(matrix.count, 18)
        XCTAssertEqual(matrix.map(\.ordinal), Array(1 ... 18))
        XCTAssertEqual(Set(matrix.map(\.caseID)).count, 18)
        XCTAssertTrue(matrix.allSatisfy { !$0.legacyPorcelainProbeMayContributeTopologyFacts })
        XCTAssertTrue(matrix.allSatisfy { matrixCase in
            (matrixCase.expectedFirstFailedGuardID == nil)
                == (matrixCase.expectedResultCode == results.successResultCode)
                && (matrixCase.expectedMissingObjectRole != nil)
                == (matrixCase.expectedResultCode
                    == results.objectUnavailableResultCode)
        })
        XCTAssertEqual(
            try XCTUnwrap(matrix.first { $0.caseID == "non_sha1_repository_object_format_is_unsupported" }).expectedResultCode,
            "TOPOLOGY_REPOSITORY_UNSUPPORTED"
        )
        XCTAssertEqual(
            try XCTUnwrap(matrix.first { $0.caseID == "nul_byte_in_commit_object_is_rejected_before_shell_parse" }).expectedClassifierExitStatus,
            25
        )
        XCTAssertNil(
            try XCTUnwrap(matrix.first { $0.caseID == "oversized_commit_object_is_rejected_before_raw_content_stream" }).expectedClassifierExitStatus
        )
        XCTAssertEqual(authority.privateGitConstructionRecipes.count, 8)
        XCTAssertEqual(authority.privateGitObjectFixtures.count, 9)
        XCTAssertTrue(
            authority.privateGitConstructionRecipes.allSatisfy {
                $0.noNetwork
                    && $0.usesOnlyPrivateTemporaryRepositories
                    && !$0.historicalEvidenceClaimedDynamicallyReplayed
                    && $0.exactArgumentVectors.count
                        == $0.exactExpectedStatuses.count
                    && $0.exactSourceAvailabilityExpectedLines.count
                        == $0.exactSourceObjectOIDs.count
                    && $0.exactArgumentVectors.count
                        == $0.exactStandardInputDescriptors.count
                    && $0.exactArgumentVectors.count
                        == $0.exactStdoutBase64.count
            }
        )
        for recipe in authority.privateGitConstructionRecipes {
            XCTAssertEqual(
                try XCTUnwrap(Data(base64Encoded:
                    try XCTUnwrap(recipe.exactStdoutBase64[2]))),
                Data("4b825dc642cb6eb9a060e54bf8d69288fbee4904\n".utf8)
            )
            for (offset, object) in authority.privateGitObjectFixtures.enumerated() {
                XCTAssertEqual(
                    recipe.exactStandardInputDescriptors[offset + 3],
                    "fixture:\(object.fixtureID)"
                )
                XCTAssertEqual(
                    try XCTUnwrap(Data(base64Encoded:
                        try XCTUnwrap(recipe.exactStdoutBase64[offset + 3]))),
                    Data("\(object.fixture.literalObjectOID)\n".utf8)
                )
            }
        }
        XCTAssertTrue(
            matrix.allSatisfy { matrixCase in
                if matrixCase.executionKind == "live_private_repository" {
                    return authority.privateGitConstructionRecipes.contains {
                        $0.recipeID == matrixCase.privateGitRecipeID
                    }
                }
                return matrixCase.privateGitRecipeID == nil
            }
        )

        let proofPairs = authority.verifierPredicateProofPairs
        XCTAssertEqual(proofPairs.count, 35)
        XCTAssertEqual(proofPairs.map(\.guardID), results.exactGuardResultMappings.map(\.guardID))
        XCTAssertTrue(proofPairs.allSatisfy(\.predicatesAreDisjoint))
        XCTAssertTrue(proofPairs.allSatisfy(\.predicatesAreExhaustive))
        let witnesses = authority.verifierPredicateWitnesses
        XCTAssertEqual(witnesses.count, 70)
        XCTAssertEqual(Set(witnesses.map(\.witnessID)).count, 70)
        XCTAssertTrue(witnesses.allSatisfy { !$0.syntheticOIDClaimedFetched })
        XCTAssertEqual(
            Set(witnesses.map(\.witnessKind)),
            [
                "direct_classifier_fixture", "direct_helper_parser_fixture",
                "private_git_end_to_end",
                "private_git_end_to_end_verified_baseline",
                "static_source_contract",
            ]
        )
        XCTAssertTrue(proofPairs.allSatisfy { pair in
            witnesses.filter { $0.witnessID == pair.positiveWitnessID }.count == 1
                && witnesses.filter { $0.witnessID == pair.negativeWitnessID }.count == 1
        })
        XCTAssertTrue(
            witnesses.allSatisfy {
                [
                    $0.classifierCaseID, $0.helperParserCaseID,
                    $0.privateGitMatrixCaseID, $0.staticCheckID,
                    $0.verifiedBaselineID,
                ].compactMap { $0 }.count == 1
            }
        )
        let baseline = authority.verifiedEndToEndBaseline
        XCTAssertEqual(
            baseline.baselineID,
            "private_git_end_to_end_verified_baseline"
        )
        XCTAssertEqual(baseline.passedGuardIDs, proofPairs.map(\.guardID))
        XCTAssertEqual(baseline.expectedClassifierExitStatus, 0)
        XCTAssertEqual(baseline.expectedResultCode, "TOPOLOGY_VERIFIED")
        XCTAssertNil(baseline.expectedFirstFailedGuardID)
        XCTAssertNil(baseline.expectedMissingObjectRole)
        XCTAssertTrue(baseline.commitFixture.objectWrittenIntoPrivateRepository)
        XCTAssertEqual(
            baseline.commitFixture.privateRepositoryConstructionAPI,
            "/usr/bin/git hash-object --literally -t commit -w --stdin"
        )
        XCTAssertTrue(baseline.constructionUsesEmptyEnvironmentAndNoNetwork)
        XCTAssertEqual(
            try XCTUnwrap(Data(base64Encoded: baseline.exactRepositoryFormatStdoutBase64)),
            Data("sha1\n".utf8)
        )
        XCTAssertEqual(
            try XCTUnwrap(Data(base64Encoded: baseline.exactBatchPreprobeStdoutBase64)),
            Data("\(baseline.commitFixture.literalObjectOID) commit \(baseline.commitFixture.payloadByteCount)\n".utf8)
        )
        let baselineRequest = try XCTUnwrap(baseline.requestVector.first)
        XCTAssertEqual(
            baseline.exactRawGitArgumentVector.last,
            baselineRequest.literalCommitOID
        )
        XCTAssertEqual(
            baseline.exactClassifierArgumentVector[1],
            baselineRequest.literalCommitOID
        )
        XCTAssertEqual(
            baseline.exactClassifierArgumentVector[2],
            String(baseline.commitFixture.payloadByteCount)
        )
        XCTAssertEqual(
            baseline.exactClassifierArgumentVector[3],
            baselineRequest.expectedTreeOID
        )
        XCTAssertEqual(
            baseline.exactClassifierArgumentVector[4],
            String(baselineRequest.expectedOrderedParentOIDs.count)
        )
        XCTAssertEqual(
            witnesses.filter(\.predicateValue).map(\.verifiedBaselineID),
            Array(repeating: baseline.baselineID, count: 35)
        )
        XCTAssertTrue(
            witnesses.filter { $0.witnessKind == "direct_classifier_fixture" }
                .allSatisfy { $0.classifierCaseID != nil }
        )
        let staticChecks = authority.staticSourceContractRegistry
        XCTAssertEqual(
            staticChecks.map(\.checkID),
            [
                "static_check_classifier_inherited_file_descriptors_closed_positive",
                "static_check_classifier_inherited_file_descriptors_closed_negative",
                "static_check_classifier_parser_internal_state_valid_positive",
                "static_check_classifier_parser_internal_state_valid_negative",
                "static_check_fixed_verifier_tools_admitted_positive",
                "static_check_fixed_verifier_tools_admitted_negative",
                "static_check_classifier_build_and_self_test_admitted_positive",
                "static_check_classifier_build_and_self_test_admitted_negative",
            ]
        )
        XCTAssertEqual(
            Set(staticChecks.map(\.futureComponentPath)),
            [
                ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                ".github/scripts/prime-ci-exact-revision-topology-verifier.sh",
            ]
        )
        XCTAssertEqual(
            Set(staticChecks.map(\.exactSymbolOrSourceAnchor)),
            [
                "closeInheritedFileDescriptorsUsingProcPIDInfo()",
                "parseCommitObjectBytes(_:expectedTreeOID:expectedParentOIDs:)",
                "prime_admit_exact_revision_topology_tools_v1",
                "prime_build_exact_revision_topology_classifier_v1",
            ]
        )
        XCTAssertEqual(
            Set(staticChecks.map(\.exactInvariantOrBranchAnchor)).count,
            staticChecks.count
        )
        XCTAssertTrue(staticChecks.allSatisfy { check in
            !check.exactInvariantOrBranchAnchor.isEmpty
                && !check.proofMethod.isEmpty
                && check.expectedResultCode
                    == (check.predicateValue
                        ? results.successResultCode
                        : results.exactGuardResultMappings.first { mapping in
                            mapping.guardID == check.guardID
                        }?.resultCode)
        })
        XCTAssertTrue(
            witnesses.filter { $0.witnessKind == "static_source_contract" }
                .allSatisfy { witness in
                    staticChecks.contains {
                        $0.guardID == witness.guardID
                            && $0.predicateValue == witness.predicateValue
                            && $0.checkID == witness.staticCheckID
                            && $0.expectedResultCode
                                == witness.expectedResultCode
                    }
                }
        )
        let directFixtures = authority.classifierDirectFixtureMatrix
        XCTAssertEqual(directFixtures.count, 41)
        XCTAssertEqual(directFixtures.map(\.ordinal), Array(1 ... 41))
        XCTAssertTrue(directFixtures.allSatisfy(\.dynamicallyExecutable))
        XCTAssertEqual(
            try XCTUnwrap(directFixtures.first {
                $0.caseID == "zero_byte_commit_object_reaches_generic_header_guard"
            }).fixture.payloadByteCount,
            0
        )
        let simultaneousSignatures = try XCTUnwrap(directFixtures.first {
            $0.caseID
                == "simultaneous_single_gpgsig_and_gpgsig_sha256_is_accepted"
        })
        XCTAssertEqual(simultaneousSignatures.expectedExitStatus, 0)
        XCTAssertEqual(
            simultaneousSignatures.expectedResultCode,
            results.successResultCode
        )
        let repeatedGPGSigSHA256 = try XCTUnwrap(directFixtures.first {
            $0.caseID == "repeated_gpgsig_sha256_is_rejected"
        })
        XCTAssertEqual(repeatedGPGSigSHA256.expectedExitStatus, 34)
        XCTAssertEqual(
            repeatedGPGSigSHA256.expectedFirstFailedGuardID,
            "signed_header_continuations_are_allowed_and_attached"
        )
        let helperFixtures = authority.helperParserFixtureMatrix
        XCTAssertEqual(helperFixtures.count, 32)
        XCTAssertEqual(helperFixtures.map(\.ordinal), Array(1 ... 32))
        XCTAssertEqual(
            Set(helperFixtures.map(\.observationKind)),
            ["invocation", "repository_format", "batch_preprobe", "pipeline_status"]
        )
        XCTAssertTrue(
            helperFixtures.filter(\.predicateValue)
                .allSatisfy { $0.expectedResultCode == nil }
        )
        for fixture in helperFixtures {
            let observed = try XCTUnwrap(
                Data(base64Encoded: fixture.boundedObservationStdoutBase64)
            )
            XCTAssertLessThanOrEqual(observed.count, 1_024)
            switch fixture.observationKind {
            case "invocation":
                XCTAssertTrue(observed.isEmpty)
                XCTAssertNil(fixture.savedGitStatus)
                XCTAssertNil(fixture.savedClassifierStatus)
            case "repository_format":
                if fixture.predicateValue {
                    XCTAssertEqual(observed, Data("sha1\n".utf8))
                    XCTAssertEqual(fixture.savedGitStatus, 0)
                } else if fixture.guardID == "repository_object_format_sha1" {
                    XCTAssertEqual(observed, Data("sha256\n".utf8))
                    XCTAssertEqual(fixture.savedGitStatus, 0)
                }
            case "batch_preprobe":
                if fixture.predicateValue {
                    let request = try XCTUnwrap(fixture.requestVector.first)
                    XCTAssertEqual(
                        observed,
                        Data("\(request.literalCommitOID) commit 217\n".utf8)
                    )
                    XCTAssertEqual(fixture.savedGitStatus, 0)
                }
            case "pipeline_status":
                XCTAssertTrue(observed.isEmpty)
                XCTAssertNotNil(fixture.savedGitStatus)
                XCTAssertNotNil(fixture.savedClassifierStatus)
            default:
                XCTFail("unknown helper observation kind")
            }
        }
        XCTAssertEqual(
            try XCTUnwrap(directFixtures.first {
                $0.caseID == "inherited_extra_fd_is_closed_then_valid_object_verifies"
            }).expectedExitStatus,
            0
        )

        let record = authority.sanitizedRecordContract
        XCTAssertEqual(record.exactRequiredFieldNames, record.exactRequiredFieldNames.sorted())
        XCTAssertEqual(record.exactRequiredFieldNames.count, 6)
        XCTAssertEqual(record.exactAllowedFirstFailedGuardIDs, results.exactGuardResultMappings.map(\.guardID))
        XCTAssertEqual(record.missingObjectRoleASCIIGrammar, "^[a-z][a-z0-9_]{0,63}$")
        XCTAssertEqual(record.maximumMissingObjectRoleUTF8ByteCount, 64)
        XCTAssertTrue(record.missingObjectRoleMustEqualOneSubmittedPrevalidatedRole)
        XCTAssertTrue(record.shallowStateIsDiagnosticOnly)
        XCTAssertFalse(record.shallowStateObservationFailureChangesResultCode)
        XCTAssertFalse(
            record.shallowStateObservationFailureChangesFirstFailedGuardID
        )
        XCTAssertEqual(record.shallowStateObservationMaximumInvocationCount, 1)
        XCTAssertEqual(record.shallowStateObservationRetryCount, 0)
        XCTAssertTrue(record.shallowStateObservationInvocationCountIsZeroOrOne)
        XCTAssertEqual(
            record.shallowStateObservationExactEligibilityAndSequence,
            "invocation_count_is_exactly_1_if_and_only_if_guards_1_through_12_all_pass_including_status0_exact_sha1_lf_storage_format_admission;otherwise_invocation_count_is_0;the_one_fixed_clean_environment_call_occurs_immediately_after_guard_12_and_before_guard_13"
        )
        XCTAssertTrue(
            record.shallowStateNonzeroOrMalformedMapsToUnavailableExactlyOnce
        )
        XCTAssertFalse(record.shallowStateObservationFailureAuthorizesRetry)
        XCTAssertTrue(
            record.firstFailedGuardIDIsNullIfAndOnlyIfResultVerified
        )
        XCTAssertTrue(
            record
                .missingObjectRoleIsNonNullIfAndOnlyIfResultObjectUnavailable
        )
        XCTAssertEqual(
            record.exactResultRecordNullabilityMappings.map(\.resultCode),
            results.exactOrderedResultCodes
        )
        XCTAssertTrue(
            record.exactResultRecordNullabilityMappings.allSatisfy { mapping in
                mapping.firstFailedGuardIDIsNull
                    == (mapping.resultCode == results.successResultCode)
                    && mapping.missingObjectRoleIsNonNull
                    == (mapping.resultCode
                        == results.objectUnavailableResultCode)
            }
        )
        XCTAssertFalse(record.objectIDsPublished)
        XCTAssertFalse(record.repositoryPathsPublished)
        XCTAssertFalse(record.refsPublished)
        XCTAssertFalse(record.rawHeadersPublished)
        XCTAssertFalse(record.rawStandardErrorPublished)
        XCTAssertTrue(record.canonicalSortedJSONRequired)
        XCTAssertEqual(record.maximumCanonicalJSONByteCount, 512)
        XCTAssertEqual(record.maximumLineByteCountIncludingTerminalLF, 513)
        XCTAssertEqual(record.exactRecordCount, 1)
        XCTAssertTrue(record.admittedWritableStdoutRequiredForProjection)
        XCTAssertEqual(record.projectionFailureValidCompleteRecordCount, 0)
        XCTAssertTrue(record.projectionFailureMayLeavePhysicalPartialPrefix)
        XCTAssertTrue(record.projectionFailureIsExternalTransportFailure)
        XCTAssertFalse(record.projectionFailureAuthorizesTopologyRetry)
        XCTAssertTrue(record.exitStatusesApplyOnlyAfterSuccessfulProjection)
        XCTAssertTrue(record.gateAndV2CaptureAndValidateHelperRecordBeforeProjection)
        XCTAssertEqual(record.successExitStatus, 0)
        XCTAssertEqual(record.nonSuccessExitStatus, 1)
        XCTAssertTrue(record.terminalLFRequired)

        let currentPatch = authority.currentAuthorityPatch
        XCTAssertEqual(currentPatch.exactPathCount, 5)
        XCTAssertEqual(currentPatch.modifiedExistingPathCount, 3)
        XCTAssertEqual(currentPatch.addedPathCount, 2)
        XCTAssertEqual(currentPatch.exactOrderedPaths.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(currentPatch.expectedEmbeddedProvenanceRecordCount, 526)
        XCTAssertFalse(currentPatch.implementationIncluded)
        XCTAssertFalse(currentPatch.mechanicsIncluded)
        XCTAssertFalse(currentPatch.canonicalIdentityConstantsIncludedBeforeIndependentReview)

        let implementation = authority.futureImplementationPatch
        XCTAssertEqual(
            implementation.exactOrderedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                ".github/scripts/prime-ci-exact-revision-topology-verifier.sh",
                ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
            ]
        )
        XCTAssertEqual(implementation.exactOrderedPaths.map(\.gitStatus), ["M", "A", "A", "A", "M"])
        XCTAssertEqual(implementation.exactOrderedPaths.map(\.gitMode), ["100755", "100644", "100755", "100755", "100644"])
        XCTAssertEqual(implementation.modifiedExistingPathCount, 2)
        XCTAssertEqual(implementation.addedPathCount, 3)
        XCTAssertEqual(implementation.classifierSourcePath, ".github/scripts/PrimeExactRevisionTopologyClassifier.swift")
        XCTAssertTrue(implementation.gateMustSourceSharedLibrary)
        XCTAssertTrue(implementation.everyFutureLiveV2GateMustSourceSharedLibrary)
        XCTAssertTrue(implementation.everyFutureLiveV2LauncherMustSourceSharedLibrary)
        XCTAssertEqual(implementation.privateLiveAdmissionTopologyParserCountAfterImplementation, 0)
        XCTAssertTrue(implementation.preservedRetiredV1ParserBytesExcludedFromLiveDuplicateCount)
        XCTAssertEqual(
            implementation.workflowGateInvocationLiteral,
            "source .github/scripts/prime-ci-active-root-quarantine.sh"
        )
        XCTAssertEqual(
            implementation.workflowStepShellLiteral,
            "/bin/bash --noprofile --norc -p -e -o pipefail -- \"{0}\""
        )
        XCTAssertTrue(implementation.workflowStepAndJobCountsPreserved)
        XCTAssertTrue(implementation.gateRequiresPrivilegedModeBeforeSourcingSharedLibrary)
        XCTAssertTrue(implementation.helperDefinesNothingBeforePrivilegedModeAdmission)
        XCTAssertTrue(implementation.gatePrivilegedAdmissionIsFirstExecutableStatement)
        XCTAssertEqual(
            implementation.gateSecondExecutableStatementLiteral,
            "builtin unset BASH_ENV ENV"
        )
        XCTAssertEqual(
            implementation.helperSecondExecutableLineLiteral,
            "builtin unset BASH_ENV ENV"
        )
        XCTAssertEqual(
            implementation.matrixTestSecondExecutableStatementLiteral,
            "builtin unset BASH_ENV ENV"
        )
        XCTAssertEqual(
            implementation.futureV2LauncherSecondExecutableStatementLiteral,
            "builtin unset BASH_ENV ENV"
        )
        XCTAssertTrue(implementation.gateSetAndOptionsFollowPrivilegedAdmissionAndUnset)
        XCTAssertEqual(
            implementation.everyChildBashParseArgumentPrefix,
            ["/bin/bash", "-p", "-n"]
        )
        XCTAssertTrue(implementation.preToolBootstrapUsesOnlyBashBuiltins)
        XCTAssertFalse(implementation.preToolBootstrapMayInvokeDirname)
        XCTAssertTrue(implementation.innerBashGateInvocationForbidden)
        XCTAssertEqual(implementation.matrixTestInvocationLiteral, "/bin/bash -p .github/scripts/prime-ci-exact-revision-topology-verifier-test.sh")
        XCTAssertTrue(implementation.matrixTestInvokedWithPrivilegedBash)
        XCTAssertTrue(implementation.everyFutureV2LauncherInvokedWithPrivilegedBash)
        XCTAssertTrue(implementation.matrixTestInvokedOnlyFromAdmittedPrivilegedGate)
        XCTAssertTrue(implementation.separateActionsStepRequiresSamePrivilegedCustomShell)
        XCTAssertEqual(
            implementation.sharedHelperAPIContract.sourcedFunctionName,
            "prime_verify_exact_revision_topology_v1"
        )
        XCTAssertFalse(implementation.sharedHelperAPIContract.ordinalTokensAccepted)
        XCTAssertTrue(
            implementation.sharedHelperAPIContract.requestOrdinalsDerivedFromPosition
        )
        XCTAssertTrue(
            implementation.bootstrapTrustContract.worktreeBlobMustEqualExactIndexBlob
        )
        XCTAssertEqual(
            implementation.bootstrapTrustContract.duplicatedTopologyParserCount,
            0
        )
        XCTAssertTrue(implementation.testMayCreateOnlyPrivateTemporaryGitRepositories)
        XCTAssertFalse(implementation.testMayUseNetwork)
        XCTAssertEqual(implementation.exactPredicateProofGuardIDs, proofPairs.map(\.guardID))
        XCTAssertEqual(implementation.classifierDirectFixtureCaseIDs, directFixtures.map(\.caseID))
        XCTAssertFalse(implementation.historicalEvidenceDynamicallyReplayedByFutureMatrix)
        XCTAssertTrue(implementation.exactMainGreenRequiredBeforeV2MeasurementAuthority)
        XCTAssertFalse(implementation.implementationIncludedInCurrentAuthorityPatch)

        let preservation = authority.preservationContract
        XCTAssertEqual(preservation.retiredV1PathCount, 11)
        XCTAssertTrue(preservation.retiredV1LaunchersMustRemainByteIdentical)
        XCTAssertTrue(preservation.retiredV1AuthoritiesMustRemainByteIdentical)
        XCTAssertTrue(preservation.retiredV1ObservationsMustRemainByteIdentical)
        XCTAssertTrue(preservation.retiredRun160RecordRemainsTerminal)
        XCTAssertTrue(preservation.retiredRun160OpportunityRemainsRetired)
        XCTAssertFalse(preservation.existingV1LaunchersRetrofittedToSharedLibrary)
        XCTAssertFalse(preservation.packageManifestMutationAuthorized)
        XCTAssertFalse(preservation.packageLockMutationAuthorized)
        XCTAssertFalse(preservation.dependencyResolutionAuthorized)
        XCTAssertEqual(authority.orderedPhaseASequence.count, 14)
        XCTAssertTrue(authority.orderedPhaseASequence[0].contains("implement_shared"))
        XCTAssertTrue(authority.orderedPhaseASequence[1].contains("authorize_v2"))
        XCTAssertTrue(authority.orderedPhaseASequence[2].contains("mechanics_once"))
        XCTAssertTrue(authority.orderedPhaseASequence[3].contains("observation"))
        XCTAssertTrue(authority.orderedPhaseASequence[4].contains("DIFFERENT_UNAVAILABLE"))
        XCTAssertTrue(authority.orderedPhaseASequence[6].contains("pin_differs"))
        XCTAssertTrue(authority.orderedPhaseASequence[9].contains("confirmation"))
        XCTAssertTrue(authority.orderedPhaseASequence[12].contains("real_monitor"))
        XCTAssertTrue(authority.orderedPhaseASequence[13].contains("topology_helper_failure"))
        XCTAssertEqual(authority.exactPhaseABranchTransitions.count, 10)
        XCTAssertEqual(
            authority.exactPhaseABranchTransitions.map(\.ordinal),
            Array(1 ... 10)
        )
        XCTAssertTrue(
            authority.exactPhaseABranchTransitions
                .filter {
                    ["DIFFERENT", "UNAVAILABLE", "FAILURE"]
                        .contains($0.measurementOutcome ?? "")
                }
                .allSatisfy {
                    $0.terminalAbsentNewAuthority
                        && $0.exactAllowedNextAuthorityOrActionIDs.isEmpty
                }
        )
        XCTAssertTrue(
            authority.exactPhaseABranchTransitions.allSatisfy {
                !$0.retryRerunReplacementOrImplicitCanaryAuthorized
            }
        )

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.currentExactMainClosureEstablished)
        XCTAssertTrue(ceiling.retiredRun160ClosureEstablished)
        XCTAssertTrue(ceiling.run160FailureCauseRemainsInference)
        XCTAssertTrue(ceiling.currentPatchAddsOnlyPureAuthorityPair)
        XCTAssertTrue(ceiling.futureImplementationScopeFrozen)
        XCTAssertTrue(ceiling.futureImplementationMayProceedOnlyAfterAuthorityExactMainGreen)
        let falseCeilings = [
            ceiling.filesystemReadPerformed,
            ceiling.filesystemWritePerformed,
            ceiling.processExecutionPerformed,
            ceiling.gitExecutionPerformed,
            ceiling.networkExecutionPerformed,
            ceiling.modelExecutionPerformed,
            ceiling.leaseExecutionPerformed,
            ceiling.verifierImplementationPerformed,
            ceiling.verifierMechanicsPerformed,
            ceiling.v2MeasurementAuthorityEstablished,
            ceiling.v2MeasurementMechanicsPerformed,
            ceiling.v2MeasurementObservationEstablished,
            ceiling.fixtureIdentityEstablished,
            ceiling.repeatBuildDeterminismEstablished,
            ceiling.currentPinMatchEstablished,
            ceiling.currentPinMismatchEstablished,
            ceiling.pinRepairAuthorized,
            ceiling.pinRepairPerformed,
            ceiling.confirmationAuthorized,
            ceiling.confirmationPerformed,
            ceiling.realCanaryAuthorized,
            ceiling.realCanaryPerformed,
            ceiling.retryOrRerunAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
        XCTAssertTrue(falseCeilings.allSatisfy { !$0 })

        let allFixtures = [authority.verifiedEndToEndBaseline.commitFixture]
            + authority.classifierDirectFixtureMatrix.map(\.fixture)
            + authority.githubDepthTwoMultiWantMatrix.compactMap(\.syntheticFixture)
        var fixturesByOID: [String: Authority.SyntheticFixtureContract] = [:]
        for fixture in allFixtures {
            let bytes = try reconstructFixtureBytes(fixture)
            XCTAssertEqual(bytes.count, fixture.payloadByteCount)
            XCTAssertEqual(hexString(SHA256.hash(data: bytes)), fixture.payloadSHA256)
            var gitObject = Data("commit \(bytes.count)\0".utf8)
            gitObject.append(bytes)
            XCTAssertEqual(
                hexString(Insecure.SHA1.hash(data: gitObject)),
                fixture.literalObjectOID
            )
            if let existing = fixturesByOID[fixture.literalObjectOID] {
                XCTAssertEqual(existing.payloadEncoding, fixture.payloadEncoding)
                XCTAssertEqual(existing.payloadRecipe, fixture.payloadRecipe)
                XCTAssertEqual(existing.payloadByteCount, fixture.payloadByteCount)
                XCTAssertEqual(existing.payloadSHA256, fixture.payloadSHA256)
                XCTAssertEqual(existing.literalObjectOID, fixture.literalObjectOID)
                XCTAssertEqual(
                    existing.literalOIDRecomputedAndRequiredEqualBeforeUse,
                    fixture.literalOIDRecomputedAndRequiredEqualBeforeUse
                )
            } else {
                fixturesByOID[fixture.literalObjectOID] = fixture
            }
        }
        XCTAssertTrue(authority.classifierDirectFixtureMatrix.allSatisfy {
            !$0.fixture.objectWrittenIntoPrivateRepository
                && [
                    "direct_classifier_stdin_no_object_write",
                    "direct_classifier_stdin_recipe_no_object_write",
                ].contains($0.fixture.privateRepositoryConstructionAPI)
        })
        XCTAssertTrue(
            authority.githubDepthTwoMultiWantMatrix.compactMap(\.syntheticFixture)
                .allSatisfy { fixture in
                    if fixture.objectWrittenIntoPrivateRepository {
                        return fixture.privateRepositoryConstructionAPI
                            == "/usr/bin/git hash-object --literally -t commit -w --stdin"
                    }
                    return fixture.privateRepositoryConstructionAPI
                        == "none_pure_classification_contract_only"
                }
        )
        for object in authority.privateGitObjectFixtures {
            let bytes = try reconstructFixtureBytes(object.fixture)
            XCTAssertEqual(bytes.count, object.fixture.payloadByteCount)
            XCTAssertEqual(
                hexString(SHA256.hash(data: bytes)),
                object.fixture.payloadSHA256
            )
            var gitObject = Data("\(object.objectType) \(bytes.count)\0".utf8)
            gitObject.append(bytes)
            XCTAssertEqual(
                hexString(Insecure.SHA1.hash(data: gitObject)),
                object.fixture.literalObjectOID
            )
            XCTAssertTrue(object.fixture.objectWrittenIntoPrivateRepository)
            XCTAssertEqual(
                object.fixture.privateRepositoryConstructionAPI,
                "/usr/bin/git hash-object --literally -t \(object.objectType) -w --stdin"
            )
        }
        for fixtureCase in authority.classifierDirectFixtureMatrix {
            XCTAssertGreaterThanOrEqual(fixtureCase.exactArgumentVector.count, 3)
            let deliberateOIDDrift =
                fixtureCase.guardID == "classifier_computed_oid_equals_literal_oid"
                    && !fixtureCase.predicateValue
            let deliberateSizeDrift = [
                "classifier_actual_size_within_bound",
                "classifier_actual_size_equals_advertised_size",
            ].contains(fixtureCase.guardID) && !fixtureCase.predicateValue
            XCTAssertEqual(
                fixtureCase.exactArgumentVector[1]
                    == fixtureCase.fixture.literalObjectOID,
                !deliberateOIDDrift
            )
            XCTAssertEqual(
                fixtureCase.exactArgumentVector[2]
                    == String(fixtureCase.fixture.payloadByteCount),
                !deliberateSizeDrift
            )
        }

        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            canonical,
            try JSONEncoder.canonicalAuthorityEncoder.encode(authority)
        )
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            hexString(SHA256.hash(data: canonical)),
            Authority.canonicalSHA256
        )
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 500)
        XCTAssertGreaterThan(dictionaryPaths.count, 50)

        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue)
            )
            if assertLooseDecodedDriftRejects(
                mutatedData,
                authority: authority
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
                authority: authority
            ) {
                looseDecodedDriftCount += 1
            }
            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path)
            )
            if assertLooseDecodedDriftRejects(
                removedData,
                authority: authority
            ) {
                looseDecodedDriftCount += 1
            }
        }
        XCTAssertGreaterThan(looseDecodedDriftCount, 500)

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
                let data = try assertCanonicalRejects(reordered)
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(
                        data,
                        authority: authority
                    )
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 20)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_topology_authority_field_\(index)"] = true
                    return dictionary
                }
            )
            let data = try assertCanonicalRejects(unknown)
            XCTAssertEqual(
                try JSONDecoder().decode(Authority.self, from: data),
                authority
            )
        }

        try assertNoncanonicalEncodingsReject(canonical, object: object)
        let oversized = Data(repeating: 0x20, count: 524_289)
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as? PrimeExactRevisionTopologyVerifierAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private enum JSONPathComponent: Hashable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func reconstructFixtureBytes(
        _ fixture: Authority.SyntheticFixtureContract
    ) throws -> Data {
        switch fixture.payloadEncoding {
        case "base64_exact_bytes":
            return try XCTUnwrap(Data(base64Encoded: fixture.payloadRecipe))
        case "base64_prefix_plus_ascii_x_repeat":
            let marker = "_then_"
            let suffix = "_ascii_x_bytes"
            let pieces = fixture.payloadRecipe.components(separatedBy: marker)
            XCTAssertEqual(pieces.count, 2)
            let base64 = try XCTUnwrap(pieces.first)
            let repeatToken = try XCTUnwrap(pieces.last)
            XCTAssertTrue(repeatToken.hasSuffix(suffix))
            let countToken = String(repeatToken.dropLast(suffix.count))
            let repeatCount = try XCTUnwrap(Int(countToken))
            var bytes = try XCTUnwrap(Data(base64Encoded: base64))
            bytes.append(Data(repeating: 0x78, count: repeatCount))
            return bytes
        default:
            XCTFail("unknown fixture encoding \(fixture.payloadEncoding)")
            return Data()
        }
    }

    private func hexString<D: Sequence>(_ bytes: D) -> String
    where D.Element == UInt8 {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

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
            try Authority.decodeCanonical(data),
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        authority: Authority,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Authority.self, from: data),
              loose != authority
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
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(slashData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: opening))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

private extension JSONEncoder {
    static var canonicalAuthorityEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}

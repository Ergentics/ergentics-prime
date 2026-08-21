// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import CryptoKit
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeExactRevisionTopologyRelationAmendmentAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeExactRevisionTopologyRelationAmendmentAuthorityV1
    private typealias OntologyCase = Authority.RelationOntologyCase

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
            "prime_exact_revision_topology_relation_amendment_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_exact_revision_topology_relation_amendment_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "pure_additive_nonselfreferential_exact_revision_ordered_merge_child_relation_authority"
        )
        XCTAssertEqual(authority.status.hasPrefix("PURE_RELATION_AMENDMENT_ONLY"), true)

        let predecessor = authority.predecessorExactMainClosure
        XCTAssertEqual(
            predecessor.mergeRevision,
            "3c40cce6350da7ed0ce0f5ccb0620f76feff0501"
        )
        XCTAssertEqual(
            predecessor.mergeTree,
            "f35ea92670fe578b1d5fc6945aa7ab58697dce5a"
        )
        XCTAssertEqual(
            predecessor.orderedMergeParentOIDs,
            [
                "6a811d3029bdb77e038750694fbf10eec0f358f8",
                "3d2148227d264502010e64a0c0db70bc1362c50c",
            ]
        )
        XCTAssertTrue(predecessor.githubSignatureVerified)
        XCTAssertFalse(predecessor.githubSignatureVerifiedAtFrozen)
        XCTAssertNil(predecessor.githubSignatureVerifiedAt)
        XCTAssertEqual(predecessor.workflowRunID, 32_434_498_068)
        XCTAssertEqual(predecessor.workflowRunNumber, 164)
        XCTAssertEqual(predecessor.workflowRunAttempt, 1)
        XCTAssertEqual(predecessor.checkSuiteID, 87_927_821_060)
        XCTAssertEqual(predecessor.workflowConclusion, "success")
        XCTAssertEqual(predecessor.actionsArtifactCount, 0)
        XCTAssertEqual(predecessor.activeLatinTestCount, 116)
        XCTAssertEqual(predecessor.aggregateTestCount, 139)
        XCTAssertFalse(predecessor.relationImplementationWasPresent)
        XCTAssertFalse(predecessor.relationMechanicsRan)

        let predecessorAuthority = authority.predecessorAuthorityIdentity
        XCTAssertEqual(predecessorAuthority.canonicalByteCount, 410_281)
        XCTAssertEqual(
            predecessorAuthority.canonicalSHA256,
            "58409182a2be35e7d7874c0b672d4dbf53ab4bd0abc5574cbd598ad8849197d2"
        )
        XCTAssertEqual(predecessorAuthority.exactFileIdentities.count, 5)
        XCTAssertTrue(predecessorAuthority.authorityPairMustRemainByteIdentical)
        XCTAssertFalse(predecessorAuthority.authorityPairSuperseded)
        XCTAssertFalse(predecessorAuthority.ordinaryFlatAPIWithdrawn)

        let api = authority.relationAPIContract
        XCTAssertEqual(api.sourcedFunctionName, "prime_verify_exact_revision_topology_v1")
        XCTAssertTrue(api.ordinaryFlatCallsWithoutEitherMarkerRemainAcceptedByteForByte)
        XCTAssertFalse(api.existingNoMarkerRoleSemanticsSuperseded)
        XCTAssertEqual(api.optionalSuffixMarker, "--ordered-merge-child-relation")
        XCTAssertEqual(api.currentIndexMarker, "--current-index-exact-revision")
        XCTAssertEqual(api.exactCurrentIndexMarkerGrammar, api.currentIndexMarker)
        XCTAssertEqual(api.currentIndexMarkerAddsObjectCount, 0)
        XCTAssertEqual(api.currentIndexMarkerSelectsExplicitRequestOrdinal, 1)
        XCTAssertEqual(api.ordinaryExplicitRequestMaximumWithoutRelationSuffix, 8)
        XCTAssertEqual(api.ordinaryExplicitRequestMaximumWithSuffix, 6)
        XCTAssertEqual(api.exactImplicitRelationObjectCount, 2)
        XCTAssertEqual(api.maximumTotalObjectCount, 8)
        XCTAssertTrue(api.fixedParentMayEqualOrdinaryRequestObject)
        XCTAssertFalse(api.mergeOrChildAliasesOrdinaryRequestObject)
        XCTAssertFalse(api.mergeAndChildAliasEachOther)
        XCTAssertEqual(api.pullRequestCurrentRole, "current_exact_revision")
        XCTAssertEqual(api.pushMergeRole, "current_exact_revision")
        XCTAssertEqual(api.discoveredChildRole, "current_reviewed_child")
        XCTAssertEqual(
            api.mergeMissingRoleSource,
            "validated_caller_suffix_merge_role"
        )
        XCTAssertEqual(
            api.childMissingRoleSource,
            "validated_caller_suffix_child_role"
        )
        XCTAssertFalse(api.futureMergeOrChildOIDFrozenHere)
        XCTAssertFalse(api.futureImplementationTreeFrozenHere)

        let externalClosure = authority.externalClosureRequirement
        XCTAssertTrue(
            externalClosure.externalPRAndExactMainClosureRequiredBeforeImplementation
        )
        XCTAssertTrue(
            externalClosure.successorImplementationRequiresNoInterveningMainCommit
        )
        XCTAssertFalse(externalClosure.futureImplementationMayFreezeItsOwnFutureHeadOrTree)

        let event = authority.eventAdmissionContract
        XCTAssertEqual(event.admittedEventKinds, ["pull_request", "push"])
        XCTAssertEqual(event.pullRequestCurrentOIDSource, "github.event.pull_request.head.sha")
        XCTAssertEqual(event.pushCurrentOIDSource, "github.sha")
        XCTAssertEqual(event.workflowDispatchHelperInvocationCount, 0)
        XCTAssertEqual(event.workflowDispatchValidRecordCount, 0)
        XCTAssertTrue(event.pullRequestUsesOrdinaryFlatRequestAndClassifierModePlusCurrentIndexMarker)
        XCTAssertTrue(event.pushUsesRelationSuffix)
        XCTAssertFalse(event.eventBeforeMaySupplyTopologyFact)
        XCTAssertFalse(event.eventRefMaySupplyTopologyFact)
        XCTAssertFalse(event.eventParent2MaySupplyTopologyFact)
        XCTAssertTrue(event.noMarkerFlatCallUsesLegacySemanticsForEveryRoleSpelling)
        XCTAssertEqual(event.legacyFlatHEADInvocationCount, 0)
        XCTAssertEqual(event.legacyFlatCleanStatusInvocationCount, 0)
        XCTAssertEqual(event.legacyFlatWriteTreeInvocationCount, 0)

        let gateRoot = authority.gatePrivateRootContract
        XCTAssertTrue(
            gateRoot.successorGateCopiesAndAdmitsRunnerTempOnceUnderPredecessorContract
        )
        XCTAssertEqual(gateRoot.runnerTempMaximumUTF8ByteCount, 1_024)
        XCTAssertTrue(gateRoot.runnerTempCanonicalAbsoluteOwnedWritableDirectoryNonlink)
        XCTAssertEqual(gateRoot.runnerTempEnvironmentReadCountAfterAdmission, 0)
        XCTAssertEqual(gateRoot.admittedFixedPaths, [
            "/usr/bin/mktemp", "/usr/bin/stat", "/usr/bin/head",
            "/usr/bin/env", "/dev/null",
        ])
        XCTAssertEqual(gateRoot.exactUmask, "0077")
        XCTAssertEqual(gateRoot.exactMktempArgumentVector, [
            "/usr/bin/mktemp", "-d",
            "<validated_RUNNER_TEMP>/prime-topology-gate.XXXXXXXX",
        ])
        XCTAssertTrue(gateRoot.mktempStderrMergedIntoStdoutBeforeBoundedConsumer)
        XCTAssertEqual(gateRoot.exactPathConsumerArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/head", "-c", "1055",
        ])
        XCTAssertEqual(gateRoot.pathConsumerStderrSink, "/dev/null")
        XCTAssertEqual(gateRoot.pathCapturePipelineProcessCount, 2)
        XCTAssertTrue(gateRoot.capturesRunUnderLocallyDisabledErrexit)
        XCTAssertTrue(gateRoot.exactlyTwoPipelineStatusesCaptured)
        XCTAssertTrue(gateRoot.pathCaptureStatusesSavedImmediately)
        XCTAssertTrue(gateRoot.statusesCapturedBeforeAnyBuiltinOrErrexitRestore)
        XCTAssertEqual(
            gateRoot.exactPathStatusTrailerNotation,
            "ASCII_RS + prime_status:DDD:DDD + ASCII_US"
        )
        XCTAssertEqual(gateRoot.pathStatusTrailerByteCount, 22)
        XCTAssertEqual(gateRoot.maximumPathBodyReadByteCount, 1_055)
        XCTAssertEqual(gateRoot.acceptedPathBodyByteCountRange, Array(32 ... 1_054))
        XCTAssertEqual(gateRoot.maximumPathCaptureByteCount, 1_077)
        XCTAssertEqual(gateRoot.acceptedMktempProducerStatus, 0)
        XCTAssertEqual(gateRoot.acceptedPathConsumerStatus, 0)
        XCTAssertEqual(gateRoot.outerPathCommandSubstitutionRequiredStatus, 0)
        XCTAssertTrue(gateRoot.pathBodyRequiresExactlyOneTerminalLF)
        XCTAssertTrue(gateRoot.rootMustBeDirectoryWritableAndFinalComponentNonlink)
        XCTAssertEqual(gateRoot.exactStatArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/stat",
            "-f", "%u %p %HT", "--", "<validated_gate_private_root>",
        ])
        XCTAssertEqual(gateRoot.exactStatConsumerArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/head", "-c", "38",
        ])
        XCTAssertTrue(gateRoot.statStderrMergedIntoStdoutBeforeBoundedConsumer)
        XCTAssertEqual(gateRoot.statConsumerStderrSink, "/dev/null")
        XCTAssertEqual(gateRoot.statCapturePipelineProcessCount, 2)
        XCTAssertTrue(gateRoot.statCaptureStatusesSavedImmediately)
        XCTAssertEqual(
            gateRoot.exactStatStatusTrailerNotation,
            "ASCII_RS + prime_status:DDD:DDD + ASCII_US"
        )
        XCTAssertEqual(
            gateRoot.exactStatStatusTrailerNotation,
            gateRoot.exactPathStatusTrailerNotation
        )
        XCTAssertEqual(gateRoot.statStatusTrailerByteCount, 22)
        XCTAssertEqual(gateRoot.acceptedStatProducerStatus, 0)
        XCTAssertEqual(gateRoot.acceptedStatConsumerStatus, 0)
        XCTAssertEqual(gateRoot.outerStatCommandSubstitutionRequiredStatus, 0)
        XCTAssertEqual(gateRoot.maximumStatBodyReadByteCount, 38)
        XCTAssertEqual(gateRoot.maximumStatCaptureByteCount, 60)
        XCTAssertEqual(gateRoot.expectedStatMode, "40700")
        XCTAssertEqual(gateRoot.expectedStatType, "Directory")
        XCTAssertTrue(gateRoot.gateRootDistinctFromHelperCompilerRoot)
        XCTAssertTrue(gateRoot.retainedUntilJobExitAsNonEvidence)
        XCTAssertEqual(gateRoot.cleanupInvocationCount, 0)
        XCTAssertFalse(gateRoot.sameEUIDConcurrentMutationInScope)
        XCTAssertEqual(gateRoot.anyFailureValidHelperRecordCount, 0)
        XCTAssertEqual(gateRoot.exactCaptureVectors.count, 6)
        for vector in gateRoot.exactCaptureVectors {
            XCTAssertEqual(
                vector.constructionKind,
                "pure_framed_capture_parser_injection"
            )
            XCTAssertEqual(vector.publicGateOrToolInvocationCount, 0)
            XCTAssertTrue(vector.futurePrivateMatrixRequired)
            XCTAssertEqual(
                vector.expectedSanitizedClassification,
                vector.accepted ? "accepted" : "external_failure"
            )
            if vector.accepted {
                XCTAssertEqual(
                    vector.expectedParsedValue,
                    vector.probeKind == "mktemp_path"
                        ? "/private/tmp/prime-topology-gate.A1b2C3d4"
                        : "501:40700:Directory"
                )
            } else {
                XCTAssertEqual(vector.expectedParsedValue, "")
            }
            let body = try XCTUnwrap(Data(base64Encoded: vector.bodyBase64))
            let trailer = try XCTUnwrap(Data(base64Encoded: vector.trailerBase64))
            let capture = try XCTUnwrap(Data(base64Encoded: vector.captureBase64))
            XCTAssertEqual(body.base64EncodedString(), vector.bodyBase64)
            XCTAssertEqual(trailer.base64EncodedString(), vector.trailerBase64)
            XCTAssertEqual(capture.base64EncodedString(), vector.captureBase64)
            XCTAssertEqual(body.count, vector.bodyByteCount)
            XCTAssertEqual(trailer.count, vector.trailerByteCount)
            XCTAssertEqual(capture.count, vector.captureByteCount)
            XCTAssertEqual(hexString(SHA256.hash(data: body)), vector.bodySHA256)
            XCTAssertEqual(hexString(SHA256.hash(data: trailer)), vector.trailerSHA256)
            XCTAssertEqual(hexString(SHA256.hash(data: capture)), vector.captureSHA256)
            var joined = body
            joined.append(trailer)
            XCTAssertEqual(joined, capture)
            let parsed = parseStatusTrailer(trailer)
            let bodyText = try XCTUnwrap(String(data: body, encoding: .utf8))
            let bodyAccepted: Bool
            if vector.probeKind == "mktemp_path" {
                bodyAccepted = bodyText == "/private/tmp/prime-topology-gate.A1b2C3d4\n"
            } else {
                bodyAccepted = bodyText == "501 40700 Directory\n"
            }
            let independentlyAccepted = parsed == ParsedTrailer(
                gitStatus: vector.producerStatus,
                classifierStatus: vector.consumerStatus
            )
                && vector.producerStatus == 0
                && vector.consumerStatus == 0
                && vector.outerSubstitutionStatus == 0
                && bodyAccepted
            XCTAssertEqual(independentlyAccepted, vector.accepted, vector.fixtureID)
        }

        let hooks = authority.pureTestHookContract
        XCTAssertEqual(
            hooks.gateProductionFunctionName,
            "prime_gate_admit_private_root_capture_v1"
        )
        XCTAssertEqual(
            hooks.exactGateProductionFunctionGrammar,
            "prime_gate_admit_private_root_capture_v1 <mktemp_path|stat_metadata> <validated_runner_temp> <decimal_euid> <outer_status> <raw_capture_one_nul_free_argv>"
        )
        XCTAssertTrue(hooks.gateProductionResetsFixedGlobals)
        XCTAssertTrue(hooks.gateProductionUsesSameLiveFramedCaptureParser)
        XCTAssertEqual(hooks.gateProductionClassifiedStatus, 0)
        XCTAssertEqual(hooks.gateProductionMisuseStatus, 2)
        XCTAssertEqual(hooks.gateProductionStdoutByteCount, 0)
        XCTAssertEqual(hooks.gateProductionStderrByteCount, 0)
        XCTAssertEqual(
            hooks.gatePrivateProcessEntryToken,
            "--prime-internal-test-gate-root-capture-v1"
        )
        XCTAssertEqual(
            hooks.gatePrivateProcessWorkingDirectory,
            "<canonical_repository_root>"
        )
        XCTAssertEqual(
            hooks.exactGatePrivateProcessEntryGrammar,
            "/bin/bash -p .github/scripts/prime-ci-active-root-quarantine.sh --prime-internal-test-gate-root-capture-v1 <mktemp_path|stat_metadata> <validated_runner_temp> <decimal_euid> <outer_status> <raw_capture_one_nul_free_argv> <expected_accepted|external_failure> <expected_parsed_value_or_empty>"
        )
        XCTAssertTrue(
            hooks.gateRelativeScriptTokenResolvesToAdmittedAbsoluteIdentity
        )
        XCTAssertTrue(hooks.gateEntryRunsAfterPrivilegedAndUnsetBootstrap)
        XCTAssertEqual(hooks.normalGateArgumentCount, 0)
        XCTAssertTrue(
            hooks.gateEntryExpectedFieldsAreTestOnlyAndNotPassedToProductionParser
        )
        XCTAssertEqual(hooks.gateEntryMatchStatus, 0)
        XCTAssertEqual(hooks.gateEntryMismatchOrMisuseStatus, 2)
        XCTAssertEqual(hooks.gateEntryStdoutByteCount, 0)
        XCTAssertEqual(hooks.gateEntryStderrByteCount, 0)
        XCTAssertFalse(hooks.liveGateCapturesUsePrivateTestEntry)
        XCTAssertEqual(
            hooks.helperHookFunctionName,
            "prime_test_exact_revision_topology_v1"
        )
        XCTAssertEqual(
            hooks.exactHelperHookModes,
            ["invocation", "probe", "relation_frame", "selector"]
        )
        XCTAssertEqual(hooks.exactHelperModeGrammars.count, 4)
        XCTAssertTrue(hooks.exactHelperModeGrammars[0].contains("invocation"))
        XCTAssertTrue(hooks.exactHelperModeGrammars[1].contains("probe"))
        XCTAssertTrue(hooks.exactHelperModeGrammars[2].contains("relation_frame"))
        XCTAssertTrue(hooks.exactHelperModeGrammars[3].contains("selector"))
        XCTAssertEqual(
            hooks.exactSelectorTupleGrammar,
            "<candidate_count> (<phase_decimal> <logical_object_ordinal_or_0> <result_code> <guard_id_or_empty> <missing_role_or_empty>){candidate_count}"
        )
        XCTAssertTrue(
            hooks.selectorHookComparesProductionSelectedMissingRoleToExpectedTupleIncludingEmpty
        )
        XCTAssertTrue(hooks.rawCaptureIsOneNULFreeArgument)
        XCTAssertTrue(hooks.helperHookResetsFixedGlobals)
        XCTAssertEqual(hooks.exactSanitizedHelperGlobalNames.count, 9)
        XCTAssertTrue(
            hooks.exactSanitizedHelperGlobalNames.contains(
                "PRIME_TEST_MISSING_ROLE"
            )
        )
        XCTAssertEqual(
            hooks.privateCandidateGlobalName,
            "PRIME_TEST_PRIVATE_CANDIDATE_OID"
        )
        XCTAssertFalse(hooks.privateCandidateMayBePublished)
        XCTAssertTrue(hooks.traceAdmissionRunsBeforePrivateCandidate)
        XCTAssertEqual(Set(hooks.exactRequiredSharedProductionSymbols), Set([
            "prime_parse_exact_revision_topology_invocation_v1",
            "prime_parse_bounded_status_capture_v1",
            "prime_select_exact_revision_topology_result_v1",
            "prime_gate_admit_private_root_capture_v1",
        ]))
        XCTAssertEqual(hooks.copiedParserOrSelectorLogicCount, 0)
        XCTAssertEqual(hooks.helperHookClassifiedStatus, 0)
        XCTAssertEqual(hooks.helperHookMisuseStatus, 2)
        XCTAssertEqual(hooks.helperHookStdoutByteCount, 0)
        XCTAssertEqual(hooks.helperHookStderrByteCount, 0)
        XCTAssertEqual(hooks.gitInvocationCount, 0)
        XCTAssertEqual(hooks.toolInvocationCount, 0)
        XCTAssertEqual(hooks.filesystemInvocationCount, 0)
        XCTAssertEqual(hooks.publicHelperRecordCount, 0)
        XCTAssertEqual(hooks.projectionInvocationCount, 0)
        XCTAssertEqual(hooks.witnessPublicationCount, 0)
        XCTAssertTrue(hooks.exactOneHookCallPerFixture)
        XCTAssertEqual(hooks.exactFixtureBindings.count, 135)
        XCTAssertEqual(hooks.exactFixtureBindings.map(\.ordinal), Array(1 ... 135))
        XCTAssertTrue(hooks.exactFixtureBindings.allSatisfy {
            $0.exactInvocationCount == 1
        })
        func boundFixtureIDs(_ registry: String) -> [String] {
            hooks.exactFixtureBindings.filter {
                $0.fixtureRegistry == registry
            }.map(\.fixtureID)
        }
        XCTAssertEqual(
            boundFixtureIDs("invocationParserVectors"),
            authority.invocationParserVectors.map(\.fixtureID)
        )
        XCTAssertEqual(
            boundFixtureIDs("indexObservationContract.exactProbeCaptureVectors"),
            authority.indexObservationContract.exactProbeCaptureVectors
                .map(\.fixtureID)
        )
        XCTAssertEqual(
            boundFixtureIDs("captureFixtures"),
            authority.captureFixtures.map(\.fixtureID)
        )
        XCTAssertEqual(
            boundFixtureIDs("relationOntologyCases"),
            authority.relationOntologyCases.map(\.caseID)
        )
        XCTAssertEqual(
            boundFixtureIDs("gatePrivateRootContract.exactCaptureVectors"),
            gateRoot.exactCaptureVectors.map(\.fixtureID)
        )

        let index = authority.indexObservationContract
        XCTAssertEqual(index.exactGateCleanStatusArgumentVector, exactCleanGitAt(
            "<validated_gate_private_root>",
            ["-C", "<repository>", "status", "--porcelain=v1", "--untracked-files=all"]
        ))
        XCTAssertEqual(index.exactGateWriteTreeArgumentVector, exactCleanGitAt(
            "<validated_gate_private_root>",
            ["-C", "<repository>", "write-tree"]
        ))
        XCTAssertEqual(index.exactHelperHEADArgumentVector, exactCleanGitAt(
            "<validated_private_compiler_root>",
            ["-C", "<repository>", "rev-parse", "--verify", "HEAD"]
        ))
        XCTAssertEqual(index.exactHelperCleanStatusArgumentVector, exactCleanGitAt(
            "<validated_private_compiler_root>",
            ["-C", "<repository>", "status", "--porcelain=v1", "--untracked-files=all"]
        ))
        XCTAssertEqual(index.exactHelperWriteTreeArgumentVector, exactCleanGitAt(
            "<validated_private_compiler_root>",
            ["-C", "<repository>", "write-tree"]
        ))
        XCTAssertTrue(index.gateAndHelperPrivateRootsAreDistinct)
        XCTAssertEqual(index.gateHEADInvocationCount, 0)
        XCTAssertEqual(index.gateCleanStatusInvocationCount, 1)
        XCTAssertEqual(index.gateWriteTreeInvocationCount, 1)
        XCTAssertEqual(index.helperPreHEADInvocationCount, 1)
        XCTAssertEqual(index.helperPostHEADInvocationCount, 1)
        XCTAssertEqual(index.helperPreCleanStatusInvocationCount, 1)
        XCTAssertEqual(index.helperPostCleanStatusInvocationCount, 1)
        XCTAssertEqual(index.helperPreWriteTreeInvocationCount, 1)
        XCTAssertEqual(index.helperPostWriteTreeInvocationCount, 1)
        XCTAssertEqual(
            Array(index.exactCleanStatusArgumentVector.suffix(3)),
            ["status", "--porcelain=v1", "--untracked-files=all"]
        )
        XCTAssertTrue(index.allThreeWriteTreeOIDsMustEqual)
        XCTAssertTrue(index.helperEmitsRecordOnlyAfterPostObservationPasses)
        XCTAssertEqual(index.indexAdmissionFailureValidHelperRecordCount, 0)
        XCTAssertFalse(index.writeTreeIsPureObservation)
        XCTAssertTrue(index.writeTreeMayMaterializeTreeObject)
        XCTAssertFalse(index.indexTreeIsTopologyFactByItself)
        XCTAssertEqual(index.fixedBoundedConsumerPath, "/usr/bin/head")
        XCTAssertEqual(index.fixedDiagnosticSinkPath, "/dev/null")
        XCTAssertTrue(index.consumerAndSinkIdentitiesAdmittedBeforeFirstProbe)
        XCTAssertEqual(index.exactHEADConsumerArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/head", "-c", "42",
        ])
        XCTAssertEqual(index.exactCleanStatusConsumerArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/head", "-c", "1",
        ])
        XCTAssertEqual(index.exactWriteTreeConsumerArgumentVector, index.exactHEADConsumerArgumentVector)
        XCTAssertTrue(index.gitStderrMergedIntoStdoutBeforeBoundedConsumer)
        XCTAssertTrue(index.boundedConsumerStderrRedirectedToFixedDiagnosticSink)
        XCTAssertEqual(index.probePipelineProcessCount, 2)
        XCTAssertTrue(index.probePipelineRunsUnderLocallyDisabledErrexit)
        XCTAssertTrue(index.probePipelineStatusesCapturedImmediately)
        XCTAssertTrue(index.probeStatusesCapturedBeforeErrexitRestore)
        XCTAssertEqual(index.probeStatusTrailerByteCount, 22)
        XCTAssertEqual(index.outerCommandSubstitutionRequiredStatus, 0)
        XCTAssertEqual(index.exactProbeBodyReadCaps, [42, 1, 42])
        XCTAssertEqual(index.exactAcceptedProbeBodyByteCounts, [41, 0, 41])
        XCTAssertEqual(index.exactMaximumProbeCaptureByteCounts, [64, 23, 64])
        XCTAssertFalse(index.producerOrConsumerStderrPublished)
        XCTAssertEqual(index.probeFailureValidHelperRecordCount, 0)
        XCTAssertEqual(index.exactProbeCaptureVectors.count, 11)
        for vector in index.exactProbeCaptureVectors {
            let body = try XCTUnwrap(Data(base64Encoded: vector.bodyBase64))
            let trailer = try XCTUnwrap(Data(base64Encoded: vector.trailerBase64))
            let capture = try XCTUnwrap(Data(base64Encoded: vector.captureBase64))
            XCTAssertEqual(body.base64EncodedString(), vector.bodyBase64, vector.fixtureID)
            XCTAssertEqual(trailer.base64EncodedString(), vector.trailerBase64, vector.fixtureID)
            XCTAssertEqual(capture.base64EncodedString(), vector.captureBase64, vector.fixtureID)
            XCTAssertEqual(body.count, vector.bodyByteCount, vector.fixtureID)
            XCTAssertEqual(trailer.count, vector.trailerByteCount, vector.fixtureID)
            XCTAssertEqual(capture.count, vector.captureByteCount, vector.fixtureID)
            XCTAssertEqual(hexString(SHA256.hash(data: body)), vector.bodySHA256)
            XCTAssertEqual(hexString(SHA256.hash(data: trailer)), vector.trailerSHA256)
            XCTAssertEqual(hexString(SHA256.hash(data: capture)), vector.captureSHA256)
            var joined = body
            joined.append(trailer)
            XCTAssertEqual(joined, capture)
            let parsed = parseStatusTrailer(trailer)
            let bodyAccepted: Bool
            switch vector.probeKind {
            case "HEAD", "write_tree":
                bodyAccepted = isExactWitness(body)
            case "clean_status":
                bodyAccepted = body.isEmpty
            default:
                XCTFail("unknown probe kind \(vector.probeKind)")
                bodyAccepted = false
            }
            let independentlyAccepted = parsed == ParsedTrailer(
                gitStatus: vector.producerStatus,
                classifierStatus: vector.consumerStatus
            )
                && vector.producerStatus == 0
                && vector.consumerStatus == 0
                && vector.outerSubstitutionStatus == 0
                && bodyAccepted
            XCTAssertEqual(independentlyAccepted, vector.accepted, vector.fixtureID)
            XCTAssertEqual(vector.expectedExternalAdmissionFailure, !vector.accepted)
            XCTAssertEqual(vector.failureValidHelperRecordCount, vector.accepted ? nil : 0)
        }

        let mutationSeam = authority.postRawIndexMutationTestSeamContract
        XCTAssertEqual(
            mutationSeam.productionCoreFunctionName,
            "prime_verify_exact_revision_topology_core_v1"
        )
        XCTAssertEqual(
            mutationSeam.publicSourcedFunctionName,
            api.sourcedFunctionName
        )
        XCTAssertEqual(
            mutationSeam.matrixOnlyWrapperFunctionName,
            "prime_test_exact_revision_topology_post_raw_index_mutation_v1"
        )
        XCTAssertEqual(
            mutationSeam.exactClosedCoreModes,
            ["none", "post_raw_read_tree_alternate"]
        )
        XCTAssertEqual(mutationSeam.publicWrapperCoreMode, "none")
        XCTAssertEqual(
            mutationSeam.matrixWrapperCoreMode,
            "post_raw_read_tree_alternate"
        )
        XCTAssertTrue(mutationSeam.publicWrapperCallsCoreExactlyOnce)
        XCTAssertTrue(mutationSeam.matrixWrapperCallsCoreExactlyOnce)
        XCTAssertFalse(mutationSeam.internalCoreIsExported)
        XCTAssertEqual(mutationSeam.exactModeBranchCount, 1)
        XCTAssertTrue(mutationSeam.modeSelectionIsOneStaticClosedCaseBranch)
        XCTAssertTrue(mutationSeam.normalPublicCallsAlwaysUseNone)
        XCTAssertEqual(mutationSeam.mutationCallbackInvocationCount, 0)
        XCTAssertEqual(mutationSeam.evalInvocationCount, 0)
        XCTAssertEqual(mutationSeam.sourceInvocationCount, 0)
        XCTAssertEqual(mutationSeam.environmentHookReadCount, 0)
        XCTAssertEqual(mutationSeam.globalHookReadCount, 0)
        XCTAssertEqual(mutationSeam.arbitraryMutationCommandArgumentCount, 0)
        XCTAssertEqual(mutationSeam.arbitraryMutationPathArgumentCount, 0)
        XCTAssertEqual(mutationSeam.arbitraryMutationOIDArgumentCount, 0)
        XCTAssertEqual(mutationSeam.gateMutationSeamInvocationCount, 0)
        XCTAssertEqual(mutationSeam.mutationModeAdditionalPublicAPIArgumentCount, 0)
        XCTAssertTrue(mutationSeam.standardVerifierArgumentsForwardedUnchanged)
        XCTAssertEqual(
            mutationSeam.exactMutationTiming,
            "once_after_all_raw_outcomes_and_before_first_post_HEAD_probe"
        )
        XCTAssertEqual(mutationSeam.alternateTreeFixtureID, "alternate_tree")
        XCTAssertEqual(mutationSeam.exactReadTreeArgumentVector, exactCleanGitAt(
            "<validated_private_compiler_root>",
            [
                "-C", "<private_repository>", "read-tree",
                "a8b941f979c6752d954e44f12986dcda9dd54417",
            ]
        ))
        XCTAssertEqual(mutationSeam.readTreeExpectedStatus, 0)
        XCTAssertEqual(mutationSeam.readTreeExpectedStdinByteCount, 0)
        XCTAssertEqual(mutationSeam.readTreeExpectedStdoutByteCount, 0)
        XCTAssertEqual(mutationSeam.readTreeExpectedStderrByteCount, 0)
        XCTAssertEqual(mutationSeam.readTreeInvocationCountInNoneMode, 0)
        XCTAssertEqual(mutationSeam.readTreeInvocationCountInAlternateMode, 1)
        XCTAssertEqual(mutationSeam.HEADMutationInvocationCount, 0)
        XCTAssertEqual(mutationSeam.exactPostHEADProbeStatusPair, "000:000")
        XCTAssertEqual(mutationSeam.postHEADOuterSubstitutionStatus, 0)
        XCTAssertEqual(
            mutationSeam.exactPostCleanStatusProbeFixtureID,
            "clean_status_post_raw_alternate_tree_prefix_A_rejected"
        )
        XCTAssertEqual(mutationSeam.exactPostCleanStatusBody, "A")
        XCTAssertEqual(
            mutationSeam.exactPostCleanStatusProbeStatusPair,
            "000:000"
        )
        XCTAssertEqual(mutationSeam.postCleanStatusOuterSubstitutionStatus, 0)
        XCTAssertEqual(
            mutationSeam.postWriteTreeInvocationCountAfterStatusFailure,
            0
        )
        XCTAssertTrue(mutationSeam.expectedExternalAdmissionFailure)
        XCTAssertEqual(mutationSeam.expectedValidHelperRecordCount, 0)
        XCTAssertEqual(mutationSeam.expectedProjectionInvocationCount, 0)
        XCTAssertEqual(mutationSeam.exactFutureMatrixCallSiteCount, 1)
        XCTAssertEqual(mutationSeam.futurePrivateMatrixInvocationCount, 1)
        let mutationStatusCapture = try XCTUnwrap(
            index.exactProbeCaptureVectors.first {
                $0.fixtureID == mutationSeam.exactPostCleanStatusProbeFixtureID
            }
        )
        XCTAssertEqual(
            try XCTUnwrap(String(
                data: try XCTUnwrap(Data(base64Encoded: mutationStatusCapture.bodyBase64)),
                encoding: .utf8
            )),
            mutationSeam.exactPostCleanStatusBody
        )
        XCTAssertEqual(mutationStatusCapture.producerStatus, 0)
        XCTAssertEqual(mutationStatusCapture.consumerStatus, 0)
        XCTAssertEqual(mutationStatusCapture.outerSubstitutionStatus, 0)
        XCTAssertFalse(mutationStatusCapture.accepted)
        XCTAssertTrue(mutationStatusCapture.expectedExternalAdmissionFailure)

        let waves = authority.preprobeWaveContract
        XCTAssertEqual(waves.wave1GuardPhaseRangeInFlatSchedule, Array(13 ... 18))
        XCTAssertEqual(waves.wave1GuardPhaseRangeInRelationSchedule, Array(14 ... 19))
        XCTAssertEqual(waves.wave2GuardPhaseRangeInRelationSchedule, Array(14 ... 19))
        XCTAssertFalse(waves.flatPhase19OrLaterExplicitFailureCausesEarlyReturn)
        XCTAssertFalse(waves.relationPhase20OrLaterExplicitFailureCausesEarlyReturn)
        XCTAssertTrue(waves.safeParent2StillTriggersWave2AfterEarlierRawFailure)
        XCTAssertTrue(waves.allEligibleOutcomesCollectedBeforeSelection)

        let classifier = authority.relationClassifierContract
        XCTAssertEqual(classifier.exactKnownExitStatuses, [
            0, 20, 21, 22, 23, 24, 25, 26, 27, 28,
            30, 31, 32, 33, 34, 41, 42,
        ])
        XCTAssertEqual(classifier.exactStatusPayloadRules.count, 8)
        XCTAssertEqual(classifier.safeWitnessRequiresBaseFlatHeaderPhaseRange, Array(29 ... 33))
        XCTAssertEqual(classifier.safeWitnessRequiresRelationHeaderPhaseRange, Array(31 ... 35))
        XCTAssertEqual(classifier.exactWitnessByteCount, 41)
        XCTAssertEqual(classifier.ordinaryModeStdoutByteCount, 0)
        XCTAssertEqual(classifier.stderrByteCountEveryOutcome, 0)
        XCTAssertEqual(
            classifier.stdoutFcntlCommand,
            "fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1)"
        )
        XCTAssertFalse(classifier.signalHandlerInstalled)
        XCTAssertEqual(classifier.exactLogicalWriteOperationCount, 1)
        XCTAssertEqual(classifier.shortZeroOrErrorWriteExitStatus, 28)
        XCTAssertTrue(classifier.exit28IsLastFallibleClassifierOutcome)
        XCTAssertFalse(classifier.exit28PrefixEverConsumed)

        let captureContract = authority.relationCaptureContract
        XCTAssertEqual(captureContract.statusTrailerByteCount, 22)
        XCTAssertEqual(captureContract.maximumBodyByteCount, 41)
        XCTAssertEqual(captureContract.maximumCaptureByteCount, 63)
        XCTAssertEqual(captureContract.exit28AdmittedPrefixLengths, Array(0 ... 40))
        XCTAssertEqual(captureContract.exit28AdmittedPrefixLengthCount, 41)
        XCTAssertTrue(captureContract.exit28EveryAdmittedPrefixNeverConsumed)
        XCTAssertTrue(captureContract.exit28Exact41BodyRejected)
        XCTAssertTrue(captureContract.trailerSyntaxValidatedBeforeClassifierStatusMembership)
        XCTAssertEqual(
            captureContract.unknownClassifierStatusGuardID,
            "classifier_exit_status_known"
        )
        XCTAssertTrue(captureContract.xtraceAndVerboseDisabledAndVerifiedBeforeWitness)
        XCTAssertTrue(captureContract.debugAndReturnTrapsAbsentBeforeWitness)
        XCTAssertTrue(captureContract.errTrapAbsentBeforeWitness)
        XCTAssertTrue(captureContract.errtraceAndFunctraceDisabledAndVerifiedBeforeWitness)
        XCTAssertTrue(captureContract.bashXtraceFDUnsetBeforeWitness)
        XCTAssertTrue(captureContract.PS4InfluenceNeutralizedBeforeWitness)
        XCTAssertFalse(captureContract.privateWitnessMayAppearInTraceOrStderr)

        let dependentChild = authority.dependentChildContract
        XCTAssertEqual(dependentChild.childRoleSource, "caller_suffix_child_role")
        XCTAssertEqual(
            dependentChild.childMissingRoleSource,
            "validated_caller_suffix_child_role_not_gate_default_literal"
        )
        XCTAssertTrue(dependentChild.childPreprobeOccursAfterDistinctnessGuard)
        XCTAssertEqual(
            dependentChild.childPreprobeInvocationCountOnSafeDistinctWitness,
            1
        )

        let flat = authority.resultContract.exactFlatGuardMappings
        let relation = authority.resultContract.exactRelationGuardMappings
        XCTAssertEqual(flat.map(\.phaseOrdinal), Array(1 ... 35))
        XCTAssertEqual(relation.map(\.phaseOrdinal), Array(1 ... 38))
        XCTAssertEqual(
            authority.resultContract.exactNewGuards.map(\.relationPhaseOrdinal),
            [3, 23, 36]
        )
        XCTAssertEqual(
            authority.resultContract.exactNewGuards.map(\.guardID),
            [
                "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids",
                "classifier_relation_witness_frame_is_exact",
                "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids",
            ]
        )
        XCTAssertEqual(relation[19].guardID, "git_cat_file_transport_succeeded")
        XCTAssertEqual(relation[20].guardID, "classifier_exit_status_known")
        XCTAssertEqual(relation[21].guardID, "classifier_arguments_match_helper_protocol")
        XCTAssertEqual(relation[22].guardID, "classifier_relation_witness_frame_is_exact")
        XCTAssertEqual(relation[30].guardID, "header_lines_and_separator_are_well_formed")
        XCTAssertEqual(relation[34].guardID, "signed_header_continuations_are_allowed_and_attached")
        XCTAssertEqual(relation[36].guardID, "tree_oid_equals_expected")
        XCTAssertEqual(relation[37].guardID, "ordered_parent_oids_equal_expected")

        let objects = authority.syntheticGitObjectFixtures
        let objectByID = Dictionary(uniqueKeysWithValues: objects.map { ($0.fixtureID, $0) })
        XCTAssertEqual(objects.count, 24)
        XCTAssertEqual(objects.filter { $0.objectType == "tree" }.count, 2)
        XCTAssertEqual(objects.filter { $0.objectType == "blob" }.count, 1)
        XCTAssertEqual(objects.filter { $0.objectType == "commit" }.count, 21)
        var parsedCommitByID: [String: ParsedCommit] = [:]
        for fixture in objects {
            let payload = try XCTUnwrap(Data(base64Encoded: fixture.payloadBase64))
            XCTAssertEqual(payload.base64EncodedString(), fixture.payloadBase64, fixture.fixtureID)
            XCTAssertEqual(payload.count, fixture.payloadByteCount, fixture.fixtureID)
            XCTAssertEqual(hexString(SHA256.hash(data: payload)), fixture.payloadSHA256, fixture.fixtureID)
            var nativeObject = Data("\(fixture.objectType) \(payload.count)\0".utf8)
            nativeObject.append(payload)
            XCTAssertEqual(
                hexString(Insecure.SHA1.hash(data: nativeObject)),
                fixture.literalObjectOID,
                fixture.fixtureID
            )
            if fixture.objectType == "commit" {
                let parsed = try parseCommit(payload)
                parsedCommitByID[fixture.fixtureID] = parsed
                XCTAssertEqual(parsed.treeOID, fixture.parsedTreeOID, fixture.fixtureID)
                XCTAssertEqual(parsed.parentOIDs, fixture.parsedOrderedParentOIDs, fixture.fixtureID)
                XCTAssertEqual(parsed.structurallyValid, fixture.structurallyValidHeader, fixture.fixtureID)
            } else {
                XCTAssertNil(fixture.parsedTreeOID)
                XCTAssertEqual(fixture.parsedOrderedParentOIDs, [])
                XCTAssertNil(fixture.structurallyValidHeader)
            }
        }
        XCTAssertEqual(
            parsedCommitByID["malformed_relation_merge"]?.firstFailedHeaderGuardID,
            "ordered_parent_headers_are_contiguous"
        )
        XCTAssertEqual(
            parsedCommitByID["orphan_continuation_relation_merge"]?.firstFailedHeaderGuardID,
            "signed_header_continuations_are_allowed_and_attached"
        )
        XCTAssertTrue(try XCTUnwrap(parsedCommitByID["signed_relation_merge"]).signedContinuationsValid)
        let alternateTreeFixture = try XCTUnwrap(objectByID["alternate_tree"])
        let alternateTreePayload = try XCTUnwrap(
            Data(base64Encoded: alternateTreeFixture.payloadBase64)
        )
        XCTAssertEqual(
            alternateTreePayload.prefix(15),
            Data("100644 fixture\0".utf8)
        )
        XCTAssertEqual(
            hexString(alternateTreePayload.suffix(20)),
            try XCTUnwrap(objectByID["present_noncommit_blob"]?.literalObjectOID)
        )
        XCTAssertNotEqual(
            alternateTreeFixture.literalObjectOID,
            try XCTUnwrap(objectByID["empty_tree"]?.literalObjectOID)
        )

        let repository = authority.privateFixtureRepositoryContract
        XCTAssertEqual(repository.objectFormat, "sha1")
        XCTAssertEqual(repository.exactInventoryRows.count, objects.count)
        XCTAssertEqual(repository.exactWithheldFixtureIDs, ["withheld_child"])
        XCTAssertEqual(repository.withheldFixtureWriteInvocationCount, 0)
        for fixture in objects {
            let inventory = try XCTUnwrap(repository.exactInventoryRows.first {
                $0.fixtureID == fixture.fixtureID
            })
            XCTAssertEqual(inventory.literalObjectOID, fixture.literalObjectOID)
            XCTAssertEqual(inventory.expectedPresent, fixture.expectedDestinationInventoryPresent)
            XCTAssertEqual(
                inventory.expectedExactPreprobeLine,
                "\(fixture.fixtureID)\t\(fixture.literalObjectOID)\t"
                    + (fixture.expectedDestinationInventoryPresent ? "present\n" : "missing\n")
            )
            XCTAssertEqual(
                inventory.expectedExactGitBatchCheckLine,
                fixture.literalObjectOID + (fixture.expectedDestinationInventoryPresent
                    ? " \(fixture.objectType) \(fixture.payloadByteCount)\n"
                    : " missing\n")
            )
        }
        let inventoryInput = try XCTUnwrap(
            Data(base64Encoded: repository.inventoryStdinBase64)
        )
        let inventoryOutput = try XCTUnwrap(
            Data(base64Encoded: repository.inventoryExpectedStdoutBase64)
        )
        XCTAssertEqual(inventoryInput.base64EncodedString(), repository.inventoryStdinBase64)
        XCTAssertEqual(
            inventoryOutput.base64EncodedString(),
            repository.inventoryExpectedStdoutBase64
        )
        XCTAssertEqual(inventoryInput.count, repository.inventoryStdinByteCount)
        XCTAssertEqual(inventoryOutput.count, repository.inventoryExpectedStdoutByteCount)
        XCTAssertEqual(
            hexString(SHA256.hash(data: inventoryInput)),
            repository.inventoryStdinSHA256
        )
        XCTAssertEqual(
            hexString(SHA256.hash(data: inventoryOutput)),
            repository.inventoryExpectedStdoutSHA256
        )
        XCTAssertEqual(
            inventoryInput,
            Data(objects.flatMap { Array(($0.literalObjectOID + "\n").utf8) })
        )
        XCTAssertEqual(
            inventoryOutput,
            Data(repository.exactInventoryRows.flatMap {
                Array($0.expectedExactGitBatchCheckLine.utf8)
            })
        )
        XCTAssertEqual(repository.inventoryExpectedStatus, 0)
        XCTAssertEqual(repository.inventoryExpectedStderrByteCount, 0)

        let captures = authority.captureFixtures
        let captureByID = Dictionary(uniqueKeysWithValues: captures.map { ($0.fixtureID, $0) })
        XCTAssertEqual(captures.count, 30)
        for fixture in captures {
            let body = try XCTUnwrap(Data(base64Encoded: fixture.bodyBase64))
            let trailer = try XCTUnwrap(Data(base64Encoded: fixture.trailerBase64))
            let capture = try XCTUnwrap(Data(base64Encoded: fixture.captureBase64))
            XCTAssertEqual(body.base64EncodedString(), fixture.bodyBase64, fixture.fixtureID)
            XCTAssertEqual(trailer.base64EncodedString(), fixture.trailerBase64, fixture.fixtureID)
            XCTAssertEqual(capture.base64EncodedString(), fixture.captureBase64, fixture.fixtureID)
            XCTAssertEqual(body.count, fixture.bodyByteCount, fixture.fixtureID)
            XCTAssertEqual(trailer.count, fixture.trailerByteCount, fixture.fixtureID)
            XCTAssertEqual(capture.count, fixture.captureByteCount, fixture.fixtureID)
            XCTAssertEqual(hexString(SHA256.hash(data: body)), fixture.bodySHA256, fixture.fixtureID)
            XCTAssertEqual(hexString(SHA256.hash(data: trailer)), fixture.trailerSHA256, fixture.fixtureID)
            XCTAssertEqual(hexString(SHA256.hash(data: capture)), fixture.captureSHA256, fixture.fixtureID)
            var expectedCapture = body
            expectedCapture.append(trailer)
            XCTAssertEqual(capture, expectedCapture, fixture.fixtureID)
            let parsedTrailer = parseStatusTrailer(trailer)
            if [
                "relation_malformed_trailer_magic",
                "relation_malformed_trailer_with_valid_witness_not_consumed",
            ].contains(fixture.fixtureID) {
                XCTAssertNil(parsedTrailer)
            } else {
                XCTAssertEqual(parsedTrailer?.gitStatus, fixture.gitStatus, fixture.fixtureID)
                XCTAssertEqual(parsedTrailer?.classifierStatus, fixture.classifierStatus, fixture.fixtureID)
            }
            let admitted = isAdmittedCapture(
                fixture,
                body: body,
                parsedTrailer: parsedTrailer,
                authority: authority,
                objectByID: objectByID
            )
            XCTAssertEqual(admitted, fixture.statusPayloadPairAdmitted, fixture.fixtureID)
            let becomesCandidate = admitted
                && fixture.gitStatus == 0
                && fixture.mode == "relation"
                && [0, 41, 42].contains(fixture.classifierStatus)
                && isExactWitness(body)
            XCTAssertEqual(becomesCandidate, fixture.bodyConsumedAsChildOID, fixture.fixtureID)
        }

        let intendedWitness = Data(
            (try XCTUnwrap(objectByID["valid_child"])).literalObjectOID.utf8
        ) + Data([0x0A])
        let exit28Trailer = Data([0x1E])
            + Data("prime_status:000:028".utf8)
            + Data([0x1F])
        for length in 0 ... 40 {
            let body = intendedWitness.prefix(length)
            XCTAssertEqual(parseStatusTrailer(exit28Trailer)?.classifierStatus, 28)
            XCTAssertTrue(isExit28Prefix(Data(body), intendedWitness: intendedWitness))
            XCTAssertFalse(isExactWitness(Data(body)))
        }
        XCTAssertFalse(isExit28Prefix(intendedWitness, intendedWitness: intendedWitness))

        let allFixtureIDs = Set(
            objects.map(\.fixtureID)
                + captures.map(\.fixtureID)
                + authority.valueDomainFixtures.map(\.fixtureID)
        )
        for ontologyCase in authority.relationOntologyCases {
            try assertInvocationRecipe(
                ontologyCase,
                authority: authority,
                objectByID: objectByID,
                allFixtureIDs: allFixtureIDs
            )
        }
        try assertPrivateRepositoryExecutionRecipes(
            authority,
            objectByID: objectByID,
            parsedCommitByID: parsedCommitByID
        )
        try assertComponentHarnessRecipes(
            authority,
            objectByID: objectByID,
            parsedCommitByID: parsedCommitByID,
            captureByID: captureByID
        )
        try assertDeterministicLiveEPIPERecipe(
            authority,
            objectByID: objectByID,
            captureByID: captureByID
        )
        XCTAssertEqual(authority.invocationParserVectors.count, 47)
        for vector in authority.invocationParserVectors {
            let outcome = evaluateParserVector(vector)
            XCTAssertEqual(outcome.mode, vector.expectedMode, vector.fixtureID)
            XCTAssertEqual(outcome.accepted, vector.expectedAccepted, vector.fixtureID)
            XCTAssertEqual(outcome.guardID, vector.expectedFirstFailedGuardID, vector.fixtureID)
            XCTAssertEqual(outcome.phase, vector.expectedFirstFailedPhaseOrdinal, vector.fixtureID)
            XCTAssertEqual(
                outcome.objectOrdinal,
                vector.expectedFirstFailureObjectOrdinal,
                vector.fixtureID
            )
            XCTAssertEqual(vector.expectedGitInvocationCount, 0)
            XCTAssertEqual(vector.expectedValidHelperRecordCount, 0)
            XCTAssertTrue(vector.futurePrivateMatrixRequired)
        }

        let inventoryPresence = Dictionary(
            uniqueKeysWithValues: repository.exactInventoryRows.map {
                ($0.fixtureID, $0.expectedPresent)
            }
        )
        let casesByID = Dictionary(
            uniqueKeysWithValues: authority.relationOntologyCases.map { ($0.caseID, $0) }
        )
        for ontologyCase in authority.relationOntologyCases {
            let outcome = try evaluateOntologyCase(
                ontologyCase,
                authority: authority,
                objectByID: objectByID,
                parsedCommitByID: parsedCommitByID,
                captureByID: captureByID,
                inventoryPresence: inventoryPresence
            )
            XCTAssertEqual(
                outcome.resultCode,
                ontologyCase.expectedResultCode,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.guardID,
                ontologyCase.expectedFirstFailedGuardID,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.phase,
                ontologyCase.expectedFirstFailedPhaseOrdinal,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.objectOrdinal,
                ontologyCase.expectedFirstFailureObjectOrdinal,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.missingRole,
                ontologyCase.expectedMissingObjectRole,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.relationClassifierStatus,
                ontologyCase.expectedRelationClassifierStatus,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.publicExplicitRawStreamCount,
                ontologyCase.expectedPublicExplicitRawStreamCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.publicMergeRawStreamCount,
                ontologyCase.expectedPublicMergeRawStreamCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.publicChildPreprobeCount,
                ontologyCase.expectedPublicChildPreprobeCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.publicChildRawStreamCount,
                ontologyCase.expectedPublicChildRawStreamCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentExplicitPreprobeGitInvocationCount,
                ontologyCase.expectedComponentExplicitPreprobeGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentExplicitRawGitInvocationCount,
                ontologyCase.expectedComponentExplicitRawGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentExplicitClassifierInvocationCount,
                ontologyCase.expectedComponentExplicitClassifierInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentExplicitFrameInjectionCount,
                ontologyCase.expectedComponentExplicitFrameInjectionCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentMergePreprobeGitInvocationCount,
                ontologyCase.expectedComponentMergePreprobeGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentMergeRawGitInvocationCount,
                ontologyCase.expectedComponentMergeRawGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentMergeClassifierInvocationCount,
                ontologyCase.expectedComponentMergeClassifierInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentChildPreprobeGitInvocationCount,
                ontologyCase.expectedComponentChildPreprobeGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentChildRawGitInvocationCount,
                ontologyCase.expectedComponentChildRawGitInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.componentChildClassifierInvocationCount,
                ontologyCase.expectedComponentChildClassifierInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.pureRelationFrameInjectionCount,
                ontologyCase.expectedPureRelationFrameInjectionCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.publicHelperInvocationCount,
                ontologyCase.expectedPublicHelperInvocationCount,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                outcome.validHelperRecordCount,
                ontologyCase.expectedValidHelperRecordCount,
                ontologyCase.caseID
            )
        }
        let semanticFactIDs = Set(
            authority.ontologyProofPairs.flatMap(\.expectedDifferingSemanticFactIDs)
        )
        XCTAssertGreaterThan(semanticFactIDs.count, 20)
        for proof in authority.ontologyProofPairs {
            let positive = try XCTUnwrap(casesByID[proof.positiveCaseID])
            let negative = try XCTUnwrap(casesByID[proof.negativeCaseID])
            let positiveFacts = try semanticFacts(
                for: positive,
                factIDs: semanticFactIDs,
                objectByID: objectByID,
                parsedCommitByID: parsedCommitByID,
                captureByID: captureByID,
                inventoryPresence: inventoryPresence,
                authority: authority
            )
            let negativeFacts = try semanticFacts(
                for: negative,
                factIDs: semanticFactIDs,
                objectByID: objectByID,
                parsedCommitByID: parsedCommitByID,
                captureByID: captureByID,
                inventoryPresence: inventoryPresence,
                authority: authority
            )
            XCTAssertEqual(positiveFacts[proof.predicateID], true, proof.pairID)
            XCTAssertEqual(negativeFacts[proof.predicateID], false, proof.pairID)
            let differing = Set(semanticFactIDs.filter {
                positiveFacts[$0] != negativeFacts[$0]
            })
            XCTAssertEqual(
                differing,
                Set(proof.expectedDifferingSemanticFactIDs),
                proof.pairID
            )
            XCTAssertTrue(proof.predicatesAreDisjoint)
            XCTAssertTrue(proof.predicatesAreExhaustive)
            XCTAssertTrue(proof.negativeUsesReproducibleRawBytesOrTruthfulPureDomain)
        }

        let combinedMissing = try XCTUnwrap(casesByID["child_phase15_beats_merge_phase37"])
        XCTAssertEqual(combinedMissing.expectedFirstFailedGuardID, "required_object_availability")
        XCTAssertEqual(combinedMissing.expectedFirstFailureObjectOrdinal, 3)
        XCTAssertEqual(combinedMissing.expectedRelationClassifierStatus, 41)
        let combinedNoncommit = try XCTUnwrap(casesByID["child_phase17_beats_merge_phase38"])
        XCTAssertEqual(combinedNoncommit.expectedFirstFailedGuardID, "required_object_type_commit")
        XCTAssertEqual(combinedNoncommit.expectedFirstFailureObjectOrdinal, 3)
        XCTAssertEqual(combinedNoncommit.expectedRelationClassifierStatus, 42)

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.predecessorExactMainClosureEstablished)
        XCTAssertTrue(ceiling.predecessorAuthorityIdentityEstablished)
        XCTAssertTrue(ceiling.amendmentIsPureData)
        XCTAssertFalse(ceiling.amendmentAddsImplementation)
        XCTAssertFalse(ceiling.amendmentRunsMechanics)
        XCTAssertFalse(ceiling.filesystemReadPerformed)
        XCTAssertFalse(ceiling.filesystemWritePerformed)
        XCTAssertFalse(ceiling.processExecutionPerformed)
        XCTAssertFalse(ceiling.gitExecutionPerformed)
        XCTAssertFalse(ceiling.networkExecutionPerformed)
        XCTAssertFalse(ceiling.compilerExecutionPerformed)
        XCTAssertFalse(ceiling.verifierExecutionPerformed)
        XCTAssertFalse(ceiling.fixtureExecutionPerformed)
        XCTAssertFalse(ceiling.measurementAuthorityEstablished)
        XCTAssertFalse(ceiling.measurementMechanicsPerformed)
        XCTAssertFalse(ceiling.confirmationAuthorized)
        XCTAssertFalse(ceiling.realCanaryAuthorized)
        XCTAssertFalse(ceiling.retryOrRerunAuthorized)
        XCTAssertFalse(ceiling.productUseAuthorized)
        XCTAssertFalse(ceiling.publicationAuthorized)
        XCTAssertTrue(ceiling.futureImplementationScopeNarrowlyAmended)
        XCTAssertTrue(ceiling.externalClosureRequired)

        let canonical = try authority.canonicalData()
        XCTAssertNotEqual(Authority.canonicalByteCount, 0)
        XCTAssertNotEqual(
            Authority.canonicalSHA256,
            String(repeating: "0", count: 64)
        )
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(hexString(SHA256.hash(data: canonical)), Authority.canonicalSHA256)
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let jsonObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: jsonObject)
        let dictionaryPaths = allDictionaryPaths(in: jsonObject)
        XCTAssertGreaterThan(valuePaths.count, 1_000)
        XCTAssertGreaterThan(dictionaryPaths.count, 100)
        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let replacement = try assertCanonicalRejects(
                replacingValue(in: jsonObject, at: path, with: mutateJSONValue)
            )
            if assertLooseDecodedDriftRejects(replacement, authority: authority) {
                looseDecodedDriftCount += 1
            }
            let nulled = try assertCanonicalRejects(
                replacingValue(in: jsonObject, at: path) { value in
                    value is NSNull ? "__null_mutation" as Any : NSNull()
                }
            )
            if assertLooseDecodedDriftRejects(nulled, authority: authority) {
                looseDecodedDriftCount += 1
            }
            let removed = try assertCanonicalRejects(
                removingValue(in: jsonObject, at: path)
            )
            if assertLooseDecodedDriftRejects(removed, authority: authority) {
                looseDecodedDriftCount += 1
            }
        }
        XCTAssertGreaterThan(looseDecodedDriftCount, 1_000)

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: jsonObject) {
            var changed = false
            let reordered = replacingValue(in: jsonObject, at: path) { value in
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
            if changed {
                let data = try assertCanonicalRejects(reordered)
                XCTAssertTrue(assertLooseDecodedDriftRejects(data, authority: authority))
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 30)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(in: jsonObject, at: path) { value in
                var dictionary = value as! [String: Any]
                dictionary["unknown_relation_authority_field_\(index)"] = true
                return dictionary
            }
            let data = try assertCanonicalRejects(unknown)
            XCTAssertEqual(try JSONDecoder().decode(Authority.self, from: data), authority)
        }
        try assertNoncanonicalEncodingsReject(canonical, object: jsonObject)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(repeating: 0x20, count: 524_289))
        ) { error in
            XCTAssertEqual(
                error as? PrimeExactRevisionTopologyRelationAmendmentAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private struct ParsedCommit {
        let treeOID: String?
        let parentOIDs: [String]
        let structurallyValid: Bool
        let signedContinuationsValid: Bool
        let firstFailedHeaderGuardID: String?
    }

    private struct ParsedTrailer: Equatable {
        let gitStatus: Int
        let classifierStatus: Int
    }

    private struct ParsedRequest {
        let role: String
        let literalOID: String
        let expectedTreeOID: String
        let expectedParentOIDs: [String]
    }

    private struct ParserOutcome {
        let mode: String
        let accepted: Bool
        let guardID: String?
        let phase: Int?
        let objectOrdinal: Int?
    }

    private struct OntologyOutcome {
        let resultCode: String
        let guardID: String?
        let phase: Int?
        let objectOrdinal: Int?
        let missingRole: String?
        let relationClassifierStatus: Int?
        let publicExplicitRawStreamCount: Int
        let publicMergeRawStreamCount: Int
        let publicChildPreprobeCount: Int
        let publicChildRawStreamCount: Int
        let componentExplicitPreprobeGitInvocationCount: Int
        let componentExplicitRawGitInvocationCount: Int
        let componentExplicitClassifierInvocationCount: Int
        let componentExplicitFrameInjectionCount: Int
        let componentMergePreprobeGitInvocationCount: Int
        let componentMergeRawGitInvocationCount: Int
        let componentMergeClassifierInvocationCount: Int
        let componentChildPreprobeGitInvocationCount: Int
        let componentChildRawGitInvocationCount: Int
        let componentChildClassifierInvocationCount: Int
        let pureRelationFrameInjectionCount: Int
        let publicHelperInvocationCount: Int
        let validHelperRecordCount: Int
    }

    private func parseCommit(_ data: Data) throws -> ParsedCommit {
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        let separator = try XCTUnwrap(text.range(of: "\n\n"))
        let header = String(text[..<separator.lowerBound])
        let lines = header.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let linesWellFormed = !lines.isEmpty
            && lines.allSatisfy { !$0.isEmpty && !$0.contains("\r") && !$0.contains("\0") }
        let treeLines = lines.filter { $0.hasPrefix("tree ") }
        let treeFirstUnique = treeLines.count == 1 && lines.first == treeLines.first
        let treeOID = treeLines.first.map { String($0.dropFirst(5)) }

        var parents: [String] = []
        var parentBlockEnded = false
        var parentsContiguous = true
        for line in lines.dropFirst() {
            if line.hasPrefix("parent ") {
                if parentBlockEnded { parentsContiguous = false }
                parents.append(String(line.dropFirst(7)))
            } else {
                parentBlockEnded = true
            }
        }
        let topologyOIDsValid = ([treeOID].compactMap { $0 } + parents)
            .allSatisfy(isLowercase40Hex)

        var signedContinuationsValid = true
        var attachmentKey: String?
        for line in lines {
            if line.hasPrefix(" ") {
                if attachmentKey != "gpgsig" {
                    signedContinuationsValid = false
                }
            } else {
                attachmentKey = line.split(separator: " ", maxSplits: 1).first.map(String.init)
            }
        }
        let failure: String?
        if !linesWellFormed {
            failure = "header_lines_and_separator_are_well_formed"
        } else if !treeFirstUnique {
            failure = "tree_header_is_first_and_unique"
        } else if !parentsContiguous {
            failure = "ordered_parent_headers_are_contiguous"
        } else if !topologyOIDsValid {
            failure = "topology_header_oids_are_lowercase_40hex"
        } else if !signedContinuationsValid {
            failure = "signed_header_continuations_are_allowed_and_attached"
        } else {
            failure = nil
        }
        return .init(
            treeOID: treeOID,
            parentOIDs: parents,
            structurallyValid: failure == nil,
            signedContinuationsValid: signedContinuationsValid,
            firstFailedHeaderGuardID: failure)
    }

    private func parseStatusTrailer(_ data: Data) -> ParsedTrailer? {
        let bytes = Array(data)
        guard bytes.count == 22,
              bytes[0] == 0x1E,
              Data(bytes[1 ..< 14]) == Data("prime_status:".utf8),
              bytes[17] == 0x3A,
              bytes[21] == 0x1F,
              bytes[14 ... 16].allSatisfy({ (0x30 ... 0x39).contains($0) }),
              bytes[18 ... 20].allSatisfy({ (0x30 ... 0x39).contains($0) })
        else { return nil }
        func decimal(_ range: ClosedRange<Int>) -> Int {
            range.reduce(0) { $0 * 10 + Int(bytes[$1] - 0x30) }
        }
        return .init(gitStatus: decimal(14 ... 16), classifierStatus: decimal(18 ... 20))
    }

    private func isAdmittedCapture(
        _ fixture: Authority.CaptureFixture,
        body: Data,
        parsedTrailer: ParsedTrailer?,
        authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture]
    ) -> Bool {
        guard parsedTrailer == ParsedTrailer(
            gitStatus: fixture.gitStatus,
            classifierStatus: fixture.classifierStatus
        ) else { return false }
        if fixture.mode == "ordinary" {
            let statuses = Set(
                authority.relationClassifierContract.exactStatusPayloadRules[0]
                    .classifierStatuses
            )
            return statuses.contains(fixture.classifierStatus) && body.isEmpty
        }
        guard fixture.mode == "relation" else { return false }
        switch fixture.classifierStatus {
        case 0:
            return isExactWitness(body)
        case 41, 42:
            return body.isEmpty || isExactWitness(body)
        case 28:
            let witness = Data(objectByID["valid_child"]!.literalObjectOID.utf8)
                + Data([0x0A])
            return isExit28Prefix(body, intendedWitness: witness)
        case 20, 21, 22, 23, 24, 25, 26, 27, 30, 31, 32, 33, 34:
            return body.isEmpty
        default:
            return false
        }
    }

    private func isExactWitness(_ data: Data) -> Bool {
        let bytes = Array(data)
        return bytes.count == 41
            && bytes.last == 0x0A
            && bytes.dropLast().allSatisfy {
                (0x30 ... 0x39).contains($0) || (0x61 ... 0x66).contains($0)
            }
    }

    private func isExit28Prefix(_ body: Data, intendedWitness: Data) -> Bool {
        body.count <= 40 && intendedWitness.prefix(body.count) == body
    }

    private func parseOrdinaryRequests(_ tokens: [String]) -> [ParsedRequest]? {
        guard !tokens.isEmpty else { return [] }
        guard tokens.count >= 2, let declaredCount = Int(tokens[1]) else {
            return nil
        }
        var requests: [ParsedRequest] = []
        var index = 2
        while index < tokens.count && !tokens[index].hasPrefix("--") {
            guard index + 3 < tokens.count,
                  let parentCount = Int(tokens[index + 3]),
                  parentCount >= 0,
                  index + 4 + parentCount <= tokens.count
            else { return nil }
            requests.append(.init(
                role: tokens[index],
                literalOID: tokens[index + 1],
                expectedTreeOID: tokens[index + 2],
                expectedParentOIDs:
                    Array(tokens[(index + 4) ..< (index + 4 + parentCount)])))
            index += 4 + parentCount
        }
        return requests.count == declaredCount ? requests : nil
    }

    private func evaluateParserVector(
        _ vector: Authority.InvocationParserVector
    ) -> ParserOutcome {
        evaluateParserTokens(vector.exactArgumentTokens)
    }

    private func evaluateParserTokens(_ tokens: [String]) -> ParserOutcome {
        let relationMarker = "--ordered-merge-child-relation"
        let currentMarker = "--current-index-exact-revision"
        func parseRequest(at start: Int) -> (ParsedRequest, Int)? {
            guard start + 3 < tokens.count,
                  let parentCount = Int(tokens[start + 3]),
                  parentCount >= 0,
                  tokens[start + 3] == String(parentCount),
                  start + 4 + parentCount <= tokens.count
            else { return nil }
            return (
                .init(
                    role: tokens[start],
                    literalOID: tokens[start + 1],
                    expectedTreeOID: tokens[start + 2],
                    expectedParentOIDs: Array(
                        tokens[(start + 4) ..< (start + 4 + parentCount)]
                    )
                ),
                start + 4 + parentCount
            )
        }
        let preliminaryDeclaredCount = tokens.count >= 2
            ? Int(tokens[1]).flatMap { $0 >= 0 ? $0 : nil }
            : nil
        var index = 2
        var requests: [ParsedRequest] = []
        if let preliminaryDeclaredCount {
            while requests.count < preliminaryDeclaredCount,
                  let (request, next) = parseRequest(at: index)
            {
                requests.append(request)
                index = next
            }
            if requests.count == preliminaryDeclaredCount {
                while let (request, next) = parseRequest(at: index) {
                    requests.append(request)
                    index = next
                }
            }
        } else {
            while let (request, next) = parseRequest(at: index) {
                requests.append(request)
                index = next
            }
        }
        let tailStartsWithRecognizedMarker = index < tokens.count
            && [relationMarker, currentMarker].contains(tokens[index])
        let terminalIndices = tailStartsWithRecognizedMarker
            ? index ..< tokens.count
            : tokens.count ..< tokens.count
        let relationMarkerIndices = terminalIndices.filter {
            tokens[$0] == relationMarker
        }
        let currentMarkerIndices = terminalIndices.filter {
            tokens[$0] == currentMarker
        }
        let mode = !relationMarkerIndices.isEmpty
            ? "relation"
            : (!currentMarkerIndices.isEmpty ? "current_index" : "ordinary")
        let relationMode = mode == "relation"
        struct Failure {
            let phase: Int
            let objectOrdinal: Int?
            let guardID: String
        }
        var failures: [Failure] = []
        func addFailure(
            _ guardID: String,
            relationPhase: Int,
            flatPhase: Int,
            objectOrdinal: Int? = nil
        ) {
            failures.append(.init(
                phase: relationMode ? relationPhase : flatPhase,
                objectOrdinal: objectOrdinal,
                guardID: guardID
            ))
        }
        guard tokens.count >= 2 else {
            return .init(
                mode: mode,
                accepted: false,
                guardID: "expected_parent_count_within_bound",
                phase: relationMode ? 9 : 8,
                objectOrdinal: nil
            )
        }
        let countToken = tokens[1]
        let parsedCount = Int(countToken)
        let countCanonicalPositive = parsedCount.map {
            $0 > 0 && countToken == String($0)
        } ?? false
        if !countCanonicalPositive {
            addFailure(
                "verification_request_count_nonzero",
                relationPhase: 4,
                flatPhase: 3
            )
        }
        if let parsedCount, parsedCount > (relationMode ? 6 : 8) {
            addFailure(
                "verification_request_count_within_bound",
                relationPhase: 5,
                flatPhase: 4
            )
        }

        let requestShapeIsParseable = index == tokens.count
            || tailStartsWithRecognizedMarker

        var mergeRole: String?
        var mergeOID: String?
        var indexTree: String?
        var fixedParent: String?
        var childRole: String?
        var suffixComplete = false
        if let suffixIndex = relationMarkerIndices.first,
           suffixIndex + 5 < tokens.count
        {
            suffixComplete = true
            mergeRole = tokens[suffixIndex + 1]
            mergeOID = tokens[suffixIndex + 2]
            indexTree = tokens[suffixIndex + 3]
            fixedParent = tokens[suffixIndex + 4]
            childRole = tokens[suffixIndex + 5]
        }
        let declaredObjectCount = parsedCount.flatMap { $0 >= 0 ? $0 : nil }
            ?? requests.count
        let mergeObjectOrdinal = declaredObjectCount + 1
        let childObjectOrdinal = declaredObjectCount + 2

        for (offset, request) in requests.enumerated() {
            let objectOrdinal = offset + 1
            if !isLowercase40Hex(request.literalOID) {
                addFailure(
                    "literal_commit_oid_is_lowercase_40hex",
                    relationPhase: 1,
                    flatPhase: 1,
                    objectOrdinal: objectOrdinal
                )
            }
            if !([request.expectedTreeOID] + request.expectedParentOIDs)
                .allSatisfy(isLowercase40Hex)
            {
                addFailure(
                    "expected_topology_oids_are_lowercase_40hex",
                    relationPhase: 2,
                    flatPhase: 2,
                    objectOrdinal: objectOrdinal
                )
            }
        }
        if let mergeOID, !isLowercase40Hex(mergeOID) {
            addFailure(
                "literal_commit_oid_is_lowercase_40hex",
                relationPhase: 1,
                flatPhase: 1,
                objectOrdinal: mergeObjectOrdinal
            )
        }
        if suffixComplete,
           ![indexTree, fixedParent].compactMap({ $0 })
            .allSatisfy(isLowercase40Hex)
        {
            addFailure(
                "expected_topology_oids_are_lowercase_40hex",
                relationPhase: 2,
                flatPhase: 2,
                objectOrdinal: mergeObjectOrdinal
            )
        }
        if let mergeOID, let fixedParent,
           mergeOID == fixedParent || requests.map(\.literalOID).contains(mergeOID)
        {
            addFailure(
                "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids",
                relationPhase: 3,
                flatPhase: 3,
                objectOrdinal: mergeObjectOrdinal
            )
        }
        let roleValid: (String) -> Bool = { role in
            guard (1 ... 64).contains(role.utf8.count),
                  let first = role.utf8.first,
                  (0x61 ... 0x7A).contains(first)
            else { return false }
            return role.utf8.dropFirst().allSatisfy {
                (0x61 ... 0x7A).contains($0)
                    || (0x30 ... 0x39).contains($0)
                    || $0 == 0x5F
            }
        }
        var orderedRoles = requests.enumerated().map {
            ($0.element.role, $0.offset + 1)
        }
        if let mergeRole {
            orderedRoles.append((mergeRole, mergeObjectOrdinal))
        }
        if let childRole {
            orderedRoles.append((childRole, childObjectOrdinal))
        }
        for (role, objectOrdinal) in orderedRoles where !roleValid(role) {
            addFailure(
                "request_role_matches_ascii_allowlist_grammar",
                relationPhase: 7,
                flatPhase: 6,
                objectOrdinal: objectOrdinal
            )
        }
        var firstRoleOrdinal: [String: Int] = [:]
        for (role, objectOrdinal) in orderedRoles {
            if firstRoleOrdinal[role] == nil {
                firstRoleOrdinal[role] = objectOrdinal
            } else {
                addFailure(
                    "request_roles_are_unique",
                    relationPhase: 8,
                    flatPhase: 7,
                    objectOrdinal: objectOrdinal
                )
            }
        }

        let declaredCountMatches = parsedCount.map { $0 == requests.count }
            ?? false
        let exactTerminalShape: Bool
        switch mode {
        case "relation":
            exactTerminalShape = relationMarkerIndices.count == 1
                && currentMarkerIndices.isEmpty
                && suffixComplete
                && relationMarkerIndices[0] == index
                && relationMarkerIndices[0] + 6 == tokens.count
        case "current_index":
            exactTerminalShape = relationMarkerIndices.isEmpty
                && currentMarkerIndices.count == 1
                && currentMarkerIndices[0] == index
                && currentMarkerIndices[0] + 1 == tokens.count
        default:
            exactTerminalShape = relationMarkerIndices.isEmpty
                && currentMarkerIndices.isEmpty
                && index == tokens.count
        }
        if !requestShapeIsParseable
            || !declaredCountMatches
            || !exactTerminalShape
        {
            addFailure(
                "expected_parent_count_within_bound",
                relationPhase: 9,
                flatPhase: 8
            )
        }

        guard let failure = failures.min(by: { lhs, rhs in
            if lhs.phase != rhs.phase { return lhs.phase < rhs.phase }
            return (lhs.objectOrdinal ?? 0) < (rhs.objectOrdinal ?? 0)
        }) else {
            return .init(
                mode: mode,
                accepted: true,
                guardID: nil,
                phase: nil,
                objectOrdinal: nil
            )
        }
        return .init(
            mode: mode,
            accepted: false,
            guardID: failure.guardID,
            phase: failure.phase,
            objectOrdinal: failure.objectOrdinal
        )
    }

    private func evaluateOntologyCase(
        _ ontologyCase: OntologyCase,
        authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        parsedCommitByID: [String: ParsedCommit],
        captureByID: [String: Authority.CaptureFixture],
        inventoryPresence: [String: Bool]
    ) throws -> OntologyOutcome {
        struct Failure {
            let phase: Int
            let objectOrdinal: Int?
            let guardID: String
            let resultCode: String
            let missingRole: String?
        }

        let relationMode = ontologyCase.relationSuffixOccurrenceCount > 0
        let mappings = relationMode
            ? authority.resultContract.exactRelationGuardMappings
            : authority.resultContract.exactFlatGuardMappings
        let mappingByGuard = Dictionary(
            uniqueKeysWithValues: mappings.map { ($0.guardID, $0) }
        )
        var failures: [Failure] = []
        func addFailure(
            _ guardID: String,
            objectOrdinal: Int? = nil,
            missingRole: String? = nil
        ) {
            guard let mapping = mappingByGuard[guardID] else {
                XCTFail("unmapped ontology guard \(guardID): \(ontologyCase.caseID)")
                return
            }
            failures.append(.init(
                phase: mapping.phaseOrdinal,
                objectOrdinal: objectOrdinal,
                guardID: guardID,
                resultCode: mapping.resultCode,
                missingRole: missingRole
            ))
        }
        func selectedFailure() -> Failure? {
            failures.min { lhs, rhs in
                if lhs.phase != rhs.phase { return lhs.phase < rhs.phase }
                return (lhs.objectOrdinal ?? 0) < (rhs.objectOrdinal ?? 0)
            }
        }

        let helperTokens = ontologyCase.invocationRecipe.exactHelperArgumentTokens
        let parsedSuffixRoles: (merge: String, child: String)? = {
            guard let marker = helperTokens.firstIndex(
                of: authority.relationAPIContract.optionalSuffixMarker
            ), marker + 5 < helperTokens.count
            else { return nil }
            return (helperTokens[marker + 1], helperTokens[marker + 5])
        }()
        XCTAssertEqual(
            parsedSuffixRoles?.merge,
            ontologyCase.validatedSuffixMergeRole,
            ontologyCase.caseID
        )
        XCTAssertEqual(
            parsedSuffixRoles?.child,
            ontologyCase.validatedSuffixChildRole,
            ontologyCase.caseID
        )
        let parserOutcome = helperTokens.isEmpty
            ? nil : evaluateParserTokens(helperTokens)
        if let parserOutcome, !parserOutcome.accepted,
           let guardID = parserOutcome.guardID
        {
            addFailure(guardID, objectOrdinal: parserOutcome.objectOrdinal)
        }
        let parserRejected = parserOutcome?.accepted == false
        let componentRecipe = authority.componentHarnessRecipes.first {
            $0.ontologyCaseID == ontologyCase.caseID
        }

        let publicHelperInvocationCount: Int
        switch ontologyCase.invocationRecipe.recipeKind {
        case "executable_helper_argv", "executable_helper_argv_with_typed_external_state":
            publicHelperInvocationCount = 1
        default:
            publicHelperInvocationCount = 0
        }

        let externalTokens = ontologyCase.invocationRecipe.exactExternalStateTokens
        let workflowRejected = ontologyCase.eventKind == "workflow_dispatch"
        let traceRejected = externalTokens.contains {
            $0.hasPrefix("hostile_trace_variants:")
        }
        let currentIndexPreRejected = externalTokens.contains(
            "direct_helper_pre_HEAD_mismatch_stops_before_clean_status"
        )
        let postObservationRejected = externalTokens.contains(
            "internal_core_mode:post_raw_read_tree_alternate"
        )
        let externalAdmissionFailure = workflowRejected || traceRejected
            || currentIndexPreRejected || postObservationRejected
        let blockedBeforeRaw = workflowRejected || traceRejected
            || currentIndexPreRejected || parserRejected
        let publicExplicitRawStreamCount = publicHelperInvocationCount == 1
            && !blockedBeforeRaw ? ontologyCase.explicitFixtureIDs.count : 0

        let fixedOID = try XCTUnwrap(objectByID["fixed_parent"]?.literalObjectOID)
        let indexTreeOID = try XCTUnwrap(objectByID["empty_tree"]?.literalObjectOID)
        let explicitOIDs = ontologyCase.explicitFixtureIDs.map {
            objectByID[$0]!.literalObjectOID
        }
        let explicitCount = ontologyCase.explicitFixtureIDs.count
        let mergeOrdinal = explicitCount + 1
        let childOrdinal = explicitCount + 2
        let mergeFixture = ontologyCase.relationMergeFixtureID.flatMap {
            objectByID[$0]
        }
        let mergeParsed = ontologyCase.relationMergeFixtureID.flatMap {
            parsedCommitByID[$0]
        }
        let mergeOIDFromTokens: String? = {
            guard let marker = helperTokens.firstIndex(
                of: authority.relationAPIContract.optionalSuffixMarker
            ), marker + 2 < helperTokens.count else { return nil }
            return helperTokens[marker + 2]
        }()
        let mergeOID = mergeFixture?.literalObjectOID ?? mergeOIDFromTokens

        let mergeAvailabilityPureInjectedMissing = ontologyCase.invocationRecipe
            .exactPureHookStimulusTokens.contains(
                "merge_inventory:pure_injected_missing_without_destination_write"
            )
        if relationMode, !blockedBeforeRaw,
           let mergeID = ontologyCase.relationMergeFixtureID,
           inventoryPresence[mergeID] == false || mergeAvailabilityPureInjectedMissing
        {
            addFailure(
                "required_object_availability",
                objectOrdinal: mergeOrdinal,
                missingRole: parsedSuffixRoles?.merge
            )
        }

        let componentMayFeedRawBytes = ![
            "pure_capture", "pure_value_domain", "pure_invocation",
            "direct_component_harness",
            "private_repository_with_transport_injection",
        ].contains(ontologyCase.executionKind)
        let publicMergeRawStreamCount = relationMode
            && !blockedBeforeRaw
            && componentMayFeedRawBytes
            && mergeFixture != nil
            && !mergeAvailabilityPureInjectedMissing
            && ontologyCase.relationMergeFixtureID.flatMap {
                inventoryPresence[$0]
            } == true
            ? 1 : 0
        let componentExplicitPreprobeGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "explicit_preprobe" }
            .reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentExplicitRawGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter {
                $0.stepKind == "explicit_ordinary_raw"
            }.reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentExplicitClassifierInvocationCount = componentRecipe?
            .exactOrderedSteps.filter {
                $0.stepKind == "explicit_ordinary_raw"
            }.reduce(0) { $0 + $1.physicalClassifierInvocationCount } ?? 0
        let componentExplicitFrameInjectionCount = componentRecipe?
            .exactOrderedSteps.filter {
                $0.stepKind == "explicit_ordinary_transport_frame_injection"
            }.reduce(0) { $0 + $1.pureFrameInjectionHookInvocationCount } ?? 0
        let componentMergePreprobeGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "merge_preprobe" }
            .reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentMergeRawGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "merge_relation_raw" }
            .reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentMergeClassifierInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "merge_relation_raw" }
            .reduce(0) { $0 + $1.physicalClassifierInvocationCount } ?? 0
        let componentChildPreprobeGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "child_preprobe" }
            .reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentChildRawGitInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "child_ordinary_raw" }
            .reduce(0) { $0 + $1.physicalGitInvocationCount } ?? 0
        let componentChildClassifierInvocationCount = componentRecipe?
            .exactOrderedSteps.filter { $0.stepKind == "child_ordinary_raw" }
            .reduce(0) { $0 + $1.physicalClassifierInvocationCount } ?? 0
        let pureRelationFrameInjectionCount =
            ontologyCase.executionKind == "pure_capture"
                && ontologyCase.captureFixtureID != nil ? 1 : 0
        let mergeObservationCount = publicMergeRawStreamCount
            + componentMergeClassifierInvocationCount

        func rawRelationClassifierStatus(_ parsed: ParsedCommit) -> Int {
            if let guardID = parsed.firstFailedHeaderGuardID {
                switch guardID {
                case "header_lines_and_separator_are_well_formed": return 30
                case "tree_header_is_first_and_unique": return 31
                case "ordered_parent_headers_are_contiguous": return 32
                case "topology_header_oids_are_lowercase_40hex": return 33
                case "signed_header_continuations_are_allowed_and_attached": return 34
                default:
                    XCTFail("unknown raw header guard \(guardID)")
                    return -1
                }
            }
            if parsed.treeOID != indexTreeOID { return 41 }
            if parsed.parentOIDs.count != 2
                || parsed.parentOIDs.first != fixedOID
            {
                return 42
            }
            return 0
        }

        let rawClassifierStatus = mergeObservationCount == 1
            ? mergeParsed.map(rawRelationClassifierStatus) : nil
        let captureFixture = ontologyCase.captureFixtureID.flatMap {
            captureByID[$0]
        }
        let captureBody = captureFixture.flatMap {
            Data(base64Encoded: $0.bodyBase64)
        }
        let captureTrailer = captureFixture.flatMap {
            Data(base64Encoded: $0.trailerBase64)
        }
        let parsedCaptureTrailer = captureTrailer.flatMap(parseStatusTrailer)
        let captureWitnessOID = captureBody.flatMap { body -> String? in
            guard isExactWitness(body) else { return nil }
            return String(data: body.dropLast(), encoding: .utf8)
        }
        let rawParent2 = mergeParsed?.parentOIDs.dropFirst().first
        let declaredChildOID = ontologyCase.discoveredChildFixtureID.flatMap {
            objectByID[$0]?.literalObjectOID
        }
        let crossBoundChildOIDs = [
            rawParent2, captureWitnessOID, declaredChildOID,
        ].compactMap { $0 }
        XCTAssertLessThanOrEqual(
            Set(crossBoundChildOIDs).count,
            1,
            ontologyCase.caseID
        )

        if mergeObservationCount == 1, let captureFixture {
            XCTAssertEqual(
                parsedCaptureTrailer?.gitStatus,
                captureFixture.gitStatus,
                ontologyCase.caseID
            )
            XCTAssertEqual(
                parsedCaptureTrailer?.classifierStatus,
                rawClassifierStatus,
                ontologyCase.caseID
            )
        }

        var captureIsSafeChildCandidate = false
        if let captureFixture, captureFixture.mode == "relation" {
            let trailerExact = parsedCaptureTrailer == ParsedTrailer(
                gitStatus: captureFixture.gitStatus,
                classifierStatus: captureFixture.classifierStatus
            )
            let admitted = isAdmittedCapture(
                captureFixture,
                body: captureBody ?? Data(),
                parsedTrailer: parsedCaptureTrailer,
                authority: authority,
                objectByID: objectByID
            )
            if !trailerExact {
                addFailure(
                    "classifier_relation_witness_frame_is_exact",
                    objectOrdinal: mergeOrdinal
                )
            } else if captureFixture.gitStatus != 0 {
                addFailure(
                    "git_cat_file_transport_succeeded",
                    objectOrdinal: mergeOrdinal
                )
            } else if !authority.relationClassifierContract
                .exactKnownExitStatuses.contains(captureFixture.classifierStatus)
            {
                addFailure(
                    "classifier_exit_status_known",
                    objectOrdinal: mergeOrdinal
                )
            } else if captureFixture.classifierStatus == 28 || !admitted {
                addFailure(
                    "classifier_relation_witness_frame_is_exact",
                    objectOrdinal: mergeOrdinal
                )
            }
            captureIsSafeChildCandidate = trailerExact
                && captureFixture.gitStatus == 0
                && [0, 41, 42].contains(captureFixture.classifierStatus)
                && captureWitnessOID != nil
        }

        if mergeObservationCount == 1, let mergeParsed {
            if let headerGuard = mergeParsed.firstFailedHeaderGuardID {
                addFailure(headerGuard, objectOrdinal: mergeOrdinal)
            } else {
                if mergeParsed.treeOID != indexTreeOID {
                    addFailure("tree_oid_equals_expected", objectOrdinal: mergeOrdinal)
                }
                if mergeParsed.parentOIDs.count != 2
                    || mergeParsed.parentOIDs.first != fixedOID
                {
                    addFailure(
                        "ordered_parent_oids_equal_expected",
                        objectOrdinal: mergeOrdinal
                    )
                }
            }
        }

        var safeChildOID: String?
        if mergeObservationCount == 1,
           let mergeParsed,
           mergeParsed.structurallyValid,
           mergeParsed.parentOIDs.count >= 2,
           [0, 41, 42].contains(rawClassifierStatus ?? -1)
        {
            safeChildOID = rawParent2
            if captureFixture != nil {
                XCTAssertTrue(captureIsSafeChildCandidate, ontologyCase.caseID)
            }
        } else if captureIsSafeChildCandidate {
            safeChildOID = captureWitnessOID
        } else if ontologyCase.valueDomainFixtureID
            == "discovered_child_equals_merge"
        {
            safeChildOID = mergeOID
        }

        var publicChildPreprobeCount = 0
        var publicChildRawStreamCount = 0
        if let safeChildOID {
            let childIsDistinct = safeChildOID != fixedOID
                && safeChildOID != mergeOID
                && !explicitOIDs.contains(safeChildOID)
            if !childIsDistinct {
                addFailure(
                    "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids",
                    objectOrdinal: childOrdinal
                )
            } else if publicMergeRawStreamCount == 1
                || componentChildPreprobeGitInvocationCount == 1
            {
                if publicMergeRawStreamCount == 1 {
                    publicChildPreprobeCount = 1
                }
                let childObject = objectByID.values.first {
                    $0.literalObjectOID == safeChildOID
                }
                let childID = childObject?.fixtureID
                if childID.flatMap({ inventoryPresence[$0] }) != true {
                    addFailure(
                        "required_object_availability",
                        objectOrdinal: childOrdinal,
                        missingRole: parsedSuffixRoles?.child
                    )
                } else if childObject?.objectType != "commit" {
                    addFailure(
                        "required_object_type_commit",
                        objectOrdinal: childOrdinal
                    )
                } else if let childID,
                          let childParsed = parsedCommitByID[childID]
                {
                    if publicMergeRawStreamCount == 1 {
                        publicChildRawStreamCount = 1
                    }
                    if publicMergeRawStreamCount == 1
                        || componentChildClassifierInvocationCount == 1
                    {
                        if let headerGuard = childParsed.firstFailedHeaderGuardID {
                        addFailure(headerGuard, objectOrdinal: childOrdinal)
                        } else {
                            if childParsed.treeOID != indexTreeOID {
                                addFailure(
                                    "tree_oid_equals_expected",
                                    objectOrdinal: childOrdinal
                                )
                            }
                            if childParsed.parentOIDs != [fixedOID] {
                                addFailure(
                                    "ordered_parent_oids_equal_expected",
                                    objectOrdinal: childOrdinal
                                )
                            }
                        }
                    }
                }
            }
        }

        if !blockedBeforeRaw,
           let requests = parseOrdinaryRequests(helperTokens)
        {
            for (offset, request) in requests.enumerated()
            where offset < ontologyCase.explicitFixtureIDs.count {
                let objectOrdinal = offset + 1
                let fixtureID = ontologyCase.explicitFixtureIDs[offset]
                guard inventoryPresence[fixtureID] == true,
                      let parsed = parsedCommitByID[fixtureID]
                else { continue }
                if parsed.treeOID != request.expectedTreeOID {
                    addFailure(
                        "tree_oid_equals_expected",
                        objectOrdinal: objectOrdinal
                    )
                }
                if parsed.parentOIDs != request.expectedParentOIDs {
                    addFailure(
                        "ordered_parent_oids_equal_expected",
                        objectOrdinal: objectOrdinal
                    )
                }
            }
        }
        if let explicitTransportStep = componentRecipe?.exactOrderedSteps.first(
            where: {
                $0.stepKind == "explicit_ordinary_transport_frame_injection"
            }
        ), explicitTransportStep.producerStatus != 0 {
            addFailure(
                "git_cat_file_transport_succeeded",
                objectOrdinal: explicitTransportStep.logicalObjectOrdinal
            )
        }

        let relationClassifierStatus: Int? = rawClassifierStatus
            ?? ((captureFixture?.mode == "relation")
                ? captureFixture?.classifierStatus : nil)
        let validHelperRecordCount: Int
        let resultCode: String
        let guardID: String?
        let phase: Int?
        let objectOrdinal: Int?
        let missingRole: String?
        if externalAdmissionFailure {
            resultCode = "EXTERNAL_ADMISSION_FAILURE"
            guardID = nil
            phase = nil
            objectOrdinal = nil
            missingRole = nil
            validHelperRecordCount = 0
        } else if let failure = selectedFailure() {
            resultCode = failure.resultCode
            guardID = failure.guardID
            phase = failure.phase
            objectOrdinal = failure.objectOrdinal
            missingRole = failure.missingRole
            validHelperRecordCount = publicHelperInvocationCount == 1 ? 1 : 0
        } else {
            resultCode = "TOPOLOGY_VERIFIED"
            guardID = nil
            phase = nil
            objectOrdinal = nil
            missingRole = nil
            validHelperRecordCount = publicHelperInvocationCount == 1 ? 1 : 0
        }

        return .init(
            resultCode: resultCode,
            guardID: guardID,
            phase: phase,
            objectOrdinal: objectOrdinal,
            missingRole: missingRole,
            relationClassifierStatus: relationClassifierStatus,
            publicExplicitRawStreamCount: publicExplicitRawStreamCount,
            publicMergeRawStreamCount: publicMergeRawStreamCount,
            publicChildPreprobeCount: publicChildPreprobeCount,
            publicChildRawStreamCount: publicChildRawStreamCount,
            componentExplicitPreprobeGitInvocationCount:
                componentExplicitPreprobeGitInvocationCount,
            componentExplicitRawGitInvocationCount:
                componentExplicitRawGitInvocationCount,
            componentExplicitClassifierInvocationCount:
                componentExplicitClassifierInvocationCount,
            componentExplicitFrameInjectionCount:
                componentExplicitFrameInjectionCount,
            componentMergePreprobeGitInvocationCount:
                componentMergePreprobeGitInvocationCount,
            componentMergeRawGitInvocationCount:
                componentMergeRawGitInvocationCount,
            componentMergeClassifierInvocationCount:
                componentMergeClassifierInvocationCount,
            componentChildPreprobeGitInvocationCount:
                componentChildPreprobeGitInvocationCount,
            componentChildRawGitInvocationCount:
                componentChildRawGitInvocationCount,
            componentChildClassifierInvocationCount:
                componentChildClassifierInvocationCount,
            pureRelationFrameInjectionCount: pureRelationFrameInjectionCount,
            publicHelperInvocationCount: publicHelperInvocationCount,
            validHelperRecordCount: validHelperRecordCount
        )
    }

    private func assertInvocationRecipe(
        _ ontologyCase: OntologyCase,
        authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        allFixtureIDs: Set<String>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let recipe = ontologyCase.invocationRecipe
        XCTAssertTrue(
            recipe.referencedFixtureIDs.allSatisfy(allFixtureIDs.contains),
            ontologyCase.caseID,
            file: file,
            line: line
        )
        let markerCount = recipe.exactHelperArgumentTokens.filter {
            $0 == authority.relationAPIContract.currentIndexMarker
        }.count
        let suffixCount = recipe.exactHelperArgumentTokens.filter {
            $0 == authority.relationAPIContract.optionalSuffixMarker
        }.count
        if recipe.exactHelperArgumentTokens.isEmpty {
            XCTAssertTrue(
                [
                    "direct_helper_parser_fixture",
                    "direct_component_harness_and_result_selector",
                    "external_gate_admission_no_helper_invocation",
                ].contains(recipe.recipeKind),
                ontologyCase.caseID,
                file: file,
                line: line
            )
        } else {
            XCTAssertEqual(
                recipe.exactHelperArgumentTokens.first,
                recipe.repositoryArgumentToken,
                ontologyCase.caseID,
                file: file,
                line: line
            )
            XCTAssertEqual(markerCount, ontologyCase.currentIndexMarkerOccurrenceCount)
            XCTAssertEqual(suffixCount, ontologyCase.relationSuffixOccurrenceCount)
            let requests = try XCTUnwrap(
                parseOrdinaryRequests(recipe.exactHelperArgumentTokens),
                ontologyCase.caseID,
                file: file,
                line: line
            )
            XCTAssertEqual(requests.count, ontologyCase.explicitFixtureIDs.count)
            for (offset, request) in requests.enumerated() {
                let fixture = try XCTUnwrap(objectByID[ontologyCase.explicitFixtureIDs[offset]])
                XCTAssertEqual(request.literalOID, fixture.literalObjectOID)
                XCTAssertEqual(request.expectedTreeOID, objectByID["empty_tree"]?.literalObjectOID)
                let expectedParents = (ontologyCase.eventKind == "pull_request"
                    && offset == 0)
                    || ontologyCase.caseID
                        == "relation_explicit_wrong_parent_rejected_after_complete_collection"
                    ? [objectByID["fixed_parent"]!.literalObjectOID]
                    : fixture.parsedOrderedParentOIDs
                XCTAssertEqual(request.expectedParentOIDs, expectedParents)
                XCTAssertTrue(request.role.utf8.count <= 64)
            }
            if suffixCount == 1 {
                let marker = try XCTUnwrap(
                    recipe.exactHelperArgumentTokens.firstIndex(
                        of: "--ordered-merge-child-relation"
                    )
                )
                XCTAssertEqual(marker + 6, recipe.exactHelperArgumentTokens.count)
                let parsedMergeRole = recipe.exactHelperArgumentTokens[marker + 1]
                let parsedChildRole = recipe.exactHelperArgumentTokens[marker + 5]
                XCTAssertEqual(
                    parsedMergeRole,
                    ontologyCase.validatedSuffixMergeRole
                )
                XCTAssertEqual(
                    parsedChildRole,
                    ontologyCase.validatedSuffixChildRole
                )
                XCTAssertTrue(isValidRole(parsedMergeRole))
                XCTAssertTrue(isValidRole(parsedChildRole))
                let expectedMergeOID: String
                if let mergeID = ontologyCase.relationMergeFixtureID {
                    expectedMergeOID = objectByID[mergeID]!.literalObjectOID
                } else if ontologyCase.valueDomainFixtureID == "merge_equals_fixed_parent" {
                    expectedMergeOID = objectByID["fixed_parent"]!.literalObjectOID
                } else if ontologyCase.valueDomainFixtureID
                    == "merge_equals_ordinary_request_literal"
                {
                    expectedMergeOID = objectByID[ontologyCase.explicitFixtureIDs[0]]!
                        .literalObjectOID
                } else {
                    expectedMergeOID = objectByID["valid_relation_merge"]!.literalObjectOID
                }
                XCTAssertEqual(recipe.exactHelperArgumentTokens[marker + 2], expectedMergeOID)
                XCTAssertEqual(
                    recipe.exactHelperArgumentTokens[marker + 3],
                    objectByID["empty_tree"]!.literalObjectOID
                )
                XCTAssertEqual(
                    recipe.exactHelperArgumentTokens[marker + 4],
                    objectByID["fixed_parent"]!.literalObjectOID
                )
                XCTAssertNotEqual(parsedMergeRole, parsedChildRole)
                if evaluateParserTokens(recipe.exactHelperArgumentTokens).accepted {
                    XCTAssertFalse(requests.map(\.role).contains(parsedMergeRole))
                    XCTAssertFalse(requests.map(\.role).contains(parsedChildRole))
                }
            } else {
                XCTAssertNil(ontologyCase.validatedSuffixMergeRole)
                XCTAssertNil(ontologyCase.validatedSuffixChildRole)
            }
        }
        XCTAssertEqual(
            ontologyCase.suffixEnabled,
            ontologyCase.relationSuffixOccurrenceCount > 0
        )
        if [
            "direct_helper_parser_fixture",
            "direct_component_harness_and_result_selector",
        ].contains(recipe.recipeKind) {
            XCTAssertGreaterThanOrEqual(recipe.exactPureHookStimulusTokens.count, 2)
            XCTAssertTrue(recipe.exactExternalStateTokens.isEmpty)
        }
        if recipe.recipeKind == "external_gate_admission_no_helper_invocation" {
            XCTAssertFalse(recipe.exactExternalStateTokens.isEmpty)
            XCTAssertEqual(ontologyCase.expectedValidHelperRecordCount, 0)
        }
    }

    private func exactCleanGit(_ suffix: [String]) -> [String] {
        exactCleanGitAt("<actor_validated_private_root>", suffix)
    }

    private func exactCleanGitAt(
        _ rootToken: String,
        _ suffix: [String]
    ) -> [String] {
        [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=\(rootToken)",
            "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
            "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
            "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
            "/usr/bin/git",
        ] + suffix
    }

    private func assertPrivateRepositoryExecutionRecipes(
        _ authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        parsedCommitByID: [String: ParsedCommit]
    ) throws {
        let casesByID = Dictionary(
            uniqueKeysWithValues: authority.relationOntologyCases.map {
                ($0.caseID, $0)
            }
        )
        let recipes = authority.privateRepositoryExecutionRecipes
        let recipeByCase = Dictionary(
            uniqueKeysWithValues: recipes.map { ($0.ontologyCaseID, $0) }
        )
        let expectedLiveCaseIDs = Set(authority.relationOntologyCases.compactMap {
            ontologyCase -> String? in
            if [
                "private_sha1_repository",
                "private_repository_with_transport_injection",
                "direct_component_harness",
            ].contains(ontologyCase.executionKind)
                || [
                    "post_index_change_emits_zero_helper_records",
                    "hostile_trace_state_fails_before_private_witness",
                    "current_index_marker_nonHEAD_dirty_repository_rejected",
                ].contains(ontologyCase.caseID)
            {
                return ontologyCase.caseID
            }
            return nil
        })
        XCTAssertEqual(Set(recipeByCase.keys), expectedLiveCaseIDs)
        XCTAssertEqual(recipes.map(\.ordinal), Array(1 ... recipes.count))
        XCTAssertEqual(Set(recipes.map(\.recipeID)).count, recipes.count)

        let presentFixtureIDs = authority.syntheticGitObjectFixtures
            .filter(\.expectedDestinationInventoryPresent).map(\.fixtureID)
        let withheldFixtureIDs = authority.syntheticGitObjectFixtures
            .filter { !$0.expectedDestinationInventoryPresent }.map(\.fixtureID)
        let tree = try XCTUnwrap(objectByID["empty_tree"])
        let alternateTree = try XCTUnwrap(objectByID["alternate_tree"])
        let unrelated = try XCTUnwrap(objectByID["unrelated"])
        let commonDirtyMutation = [
            "mutation_kind:bash_builtin_printf_empty_redirect_new_regular_file",
            "mutation_timing:immediately_before_gate_or_legacy_helper_call",
            "relative_path:prime-dirty-probe",
            "expected_full_status_body:?? prime-dirty-probe\\n",
        ]

        for recipe in recipes {
            let ontologyCase = try XCTUnwrap(casesByID[recipe.ontologyCaseID])
            XCTAssertEqual(
                ontologyCase.privateRepositoryRecipeID,
                recipe.recipeID,
                recipe.recipeID
            )
            XCTAssertEqual(recipe.exactInitArgumentVector, exactCleanGit([
                "init", "-q", "--initial-branch=main", "--object-format=sha1",
                "<private_repository>",
            ]))
            XCTAssertEqual(recipe.initExpectedStatus, 0)
            XCTAssertEqual(recipe.initExpectedStdinByteCount, 0)
            XCTAssertEqual(recipe.initExpectedStdoutByteCount, 0)
            XCTAssertEqual(recipe.initExpectedStderrByteCount, 0)
            XCTAssertEqual(recipe.exactWrittenFixtureIDs, presentFixtureIDs)
            XCTAssertEqual(recipe.exactWithheldFixtureIDs, withheldFixtureIDs)
            XCTAssertEqual(recipe.withheldFixtureWriteInvocationCount, 0)
            XCTAssertEqual(recipe.exactObjectWriteArgumentVectorTemplate, exactCleanGit([
                "-C", "<private_repository>", "hash-object", "--literally",
                "-t", "<object_type>", "-w", "--stdin",
            ]))
            XCTAssertEqual(
                recipe.objectWriteStdinSource,
                "exact_base64_decoded_payload_bytes_for_each_exactWrittenFixtureID"
            )
            XCTAssertEqual(recipe.everyObjectWriteExpectedStatus, 0)
            XCTAssertEqual(
                recipe.everyObjectWriteExpectedStdout,
                "that_fixture_literal_object_oid_plus_one_lf"
            )
            XCTAssertEqual(recipe.everyObjectWriteExpectedStderrByteCount, 0)
            for fixtureID in recipe.exactWrittenFixtureIDs {
                let fixture = try XCTUnwrap(objectByID[fixtureID])
                let stdin = try XCTUnwrap(Data(base64Encoded: fixture.payloadBase64))
                XCTAssertEqual(stdin.count, fixture.payloadByteCount)
                let renderedArguments = recipe.exactObjectWriteArgumentVectorTemplate
                    .map { $0 == "<object_type>" ? fixture.objectType : $0 }
                XCTAssertEqual(renderedArguments, exactCleanGit([
                    "-C", "<private_repository>", "hash-object", "--literally",
                    "-t", fixture.objectType, "-w", "--stdin",
                ]))
                let stdout = Data((fixture.literalObjectOID + "\n").utf8)
                XCTAssertEqual(stdout.count, 41)
            }

            let expectedCurrentFixtureID: String
            if [
                "legacy_flat_nonHEAD_dirty_repository_remains_legacy",
                "current_index_marker_nonHEAD_dirty_repository_rejected",
            ].contains(ontologyCase.caseID) {
                expectedCurrentFixtureID = "unrelated"
            } else if ontologyCase.executionKind == "direct_component_harness" {
                expectedCurrentFixtureID = "valid_relation_merge"
            } else if ontologyCase.eventKind == "pull_request" {
                expectedCurrentFixtureID = try XCTUnwrap(
                    ontologyCase.explicitFixtureIDs.first
                )
            } else {
                expectedCurrentFixtureID = try XCTUnwrap(
                    ontologyCase.relationMergeFixtureID
                )
            }
            XCTAssertEqual(recipe.eventCurrentFixtureID, expectedCurrentFixtureID)
            let current = try XCTUnwrap(objectByID[expectedCurrentFixtureID])
            XCTAssertTrue(current.expectedDestinationInventoryPresent)
            XCTAssertEqual(
                try XCTUnwrap(parsedCommitByID[expectedCurrentFixtureID]).treeOID,
                tree.literalObjectOID
            )
            XCTAssertEqual(recipe.exactUpdateRefHEADArgumentVector, exactCleanGit([
                "-C", "<private_repository>", "update-ref", "HEAD",
                current.literalObjectOID,
            ]))
            XCTAssertEqual(recipe.updateRefExpectedStatus, 0)
            XCTAssertEqual(recipe.updateRefExpectedStdinByteCount, 0)
            XCTAssertEqual(recipe.updateRefExpectedStdoutByteCount, 0)
            XCTAssertEqual(recipe.updateRefExpectedStderrByteCount, 0)
            XCTAssertEqual(recipe.independentIndexTreeFixtureID, "empty_tree")
            XCTAssertEqual(recipe.exactReadTreeArgumentVector, exactCleanGit([
                "-C", "<private_repository>", "read-tree", tree.literalObjectOID,
            ]))
            XCTAssertEqual(recipe.readTreeExpectedStatus, 0)
            XCTAssertEqual(recipe.readTreeExpectedStdinByteCount, 0)
            XCTAssertEqual(recipe.readTreeExpectedStdoutByteCount, 0)
            XCTAssertEqual(recipe.readTreeExpectedStderrByteCount, 0)
            XCTAssertTrue(recipe.inventoryRequiredBeforeCase)

            let expectedGateBodies: [String]
            let expectedHelperPreBodies: [String]
            let expectedHelperPostBodies: [String]
            let expectedMutation: [String]
            switch ontologyCase.caseID {
            case "wave1_missing_merge_stops_all_raw",
                 "merge_wrong_tree_isolated",
                 "wrong_tree_one_parent_selects_tree_without_witness",
                 "child_phase15_beats_merge_phase37",
                 "alternate_valid_merge_role_missing_is_selected":
                expectedGateBodies = []
                expectedHelperPreBodies = []
                expectedHelperPostBodies = []
                expectedMutation = []
            case "legacy_flat_nonHEAD_dirty_repository_remains_legacy":
                expectedGateBodies = []
                expectedHelperPreBodies = []
                expectedHelperPostBodies = []
                expectedMutation = commonDirtyMutation
            case "current_index_marker_nonHEAD_dirty_repository_rejected":
                expectedGateBodies = []
                expectedHelperPreBodies = [current.literalObjectOID + "\n"]
                expectedHelperPostBodies = []
                expectedMutation = commonDirtyMutation
            case "post_index_change_emits_zero_helper_records":
                expectedGateBodies = ["", tree.literalObjectOID + "\n"]
                expectedHelperPreBodies = [
                    current.literalObjectOID + "\n", "",
                    tree.literalObjectOID + "\n",
                ]
                expectedHelperPostBodies = [
                    current.literalObjectOID + "\n", "A",
                ]
                expectedMutation = [
                    "internal_core_mode:post_raw_read_tree_alternate",
                    "timing:after_all_raw_outcomes_before_first_post_HEAD",
                    "exact_argument_vector_begin",
                ] + exactCleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<private_repository>", "read-tree",
                    alternateTree.literalObjectOID,
                ]) + [
                    "exact_argument_vector_end",
                    "expected_status:0",
                    "expected_stdout_bytes:0", "expected_stderr_bytes:0",
                    "HEAD_mutation_invocation_count:0",
                    "post_HEAD_body:" + current.literalObjectOID + "\\n",
                    "post_HEAD_status_pair:000:000",
                    "post_clean_status_body:A",
                    "post_clean_status_status_pair:000:000",
                    "post_write_tree_invocation_count:0",
                ]
            case "hostile_trace_state_fails_before_private_witness":
                expectedGateBodies = ["", tree.literalObjectOID + "\n"]
                expectedHelperPreBodies = [
                    current.literalObjectOID + "\n", "",
                    tree.literalObjectOID + "\n",
                ]
                expectedHelperPostBodies = []
                expectedMutation = [
                    "before_witness:hostile_trace_variants",
                    "xtrace", "verbose", "DEBUG", "RETURN", "ERR",
                    "errtrace", "functrace", "BASH_XTRACEFD", "PS4",
                ]
            case "wave2_phase15_outweighs_earlier_explicit_raw_failure":
                expectedGateBodies = []
                expectedHelperPreBodies = []
                expectedHelperPostBodies = []
                expectedMutation = ontologyCase.invocationRecipe.exactExternalStateTokens
            default:
                expectedGateBodies = ["", tree.literalObjectOID + "\n"]
                expectedHelperPreBodies = [
                    current.literalObjectOID + "\n", "",
                    tree.literalObjectOID + "\n",
                ]
                expectedHelperPostBodies = expectedHelperPreBodies
                expectedMutation = []
            }
            XCTAssertEqual(recipe.exactExpectedGateProbeBodies, expectedGateBodies)
            XCTAssertEqual(
                recipe.exactExpectedHelperPreProbeBodies,
                expectedHelperPreBodies
            )
            XCTAssertEqual(
                recipe.exactExpectedHelperPostProbeBodies,
                expectedHelperPostBodies
            )
            XCTAssertEqual(recipe.typedMutationTokens, expectedMutation)
            if [
                "legacy_flat_nonHEAD_dirty_repository_remains_legacy",
                "current_index_marker_nonHEAD_dirty_repository_rejected",
            ].contains(ontologyCase.caseID) {
                XCTAssertEqual(
                    recipe.typedMutationTokens,
                    commonDirtyMutation
                )
                XCTAssertTrue(recipe.typedMutationTokens.contains(
                    "relative_path:prime-dirty-probe"
                ))
                XCTAssertTrue(recipe.typedMutationTokens.contains(
                    "expected_full_status_body:?? prime-dirty-probe\\n"
                ))
            }
            let expectedProbeCount = expectedGateBodies.count
                + expectedHelperPreBodies.count + expectedHelperPostBodies.count
            XCTAssertEqual(
                recipe.exactExpectedProbeStatusPairs,
                Array(repeating: "000:000", count: expectedProbeCount)
            )
            if ontologyCase.caseID
                == "post_index_change_emits_zero_helper_records"
            {
                let seam = authority.postRawIndexMutationTestSeamContract
                XCTAssertEqual(
                    recipe.exactExpectedHelperPostProbeBodies,
                    [current.literalObjectOID + "\n", "A"]
                )
                XCTAssertEqual(
                    Array(recipe.exactExpectedProbeStatusPairs.suffix(2)),
                    [
                        seam.exactPostHEADProbeStatusPair,
                        seam.exactPostCleanStatusProbeStatusPair,
                    ]
                )
                XCTAssertTrue(recipe.typedMutationTokens.contains(
                    "internal_core_mode:" + seam.matrixWrapperCoreMode
                ))
                XCTAssertFalse(recipe.typedMutationTokens.contains("update-ref"))
                XCTAssertEqual(seam.HEADMutationInvocationCount, 0)
                XCTAssertEqual(
                    seam.exactReadTreeArgumentVector,
                    exactCleanGitAt("<validated_private_compiler_root>", [
                        "-C", "<private_repository>", "read-tree",
                        alternateTree.literalObjectOID,
                    ])
                )
                XCTAssertEqual(
                    seam.postWriteTreeInvocationCountAfterStatusFailure,
                    0
                )
            }

            let independentlyExpectedPublicHelperCount: Int
            if ontologyCase.executionKind == "direct_helper_parser_fixture"
                || ontologyCase.executionKind == "direct_component_harness"
                || ontologyCase.executionKind == "pure_capture"
                || ontologyCase.executionKind
                    == "private_repository_with_transport_injection"
                || ontologyCase.caseID
                    == "discovered_child_equal_merge_rejected_truthfully"
                || ontologyCase.caseID
                    == "workflow_dispatch_terminates_before_relation_call"
            {
                independentlyExpectedPublicHelperCount = 0
            } else {
                independentlyExpectedPublicHelperCount = 1
            }
            XCTAssertEqual(
                recipe.expectedHelperInvocationCount,
                independentlyExpectedPublicHelperCount
            )
            XCTAssertEqual(
                ontologyCase.expectedPublicHelperInvocationCount,
                independentlyExpectedPublicHelperCount
            )
            let independentlyExpectedRecordCount =
                independentlyExpectedPublicHelperCount == 1
                    && ![
                        "post_index_change_emits_zero_helper_records",
                        "hostile_trace_state_fails_before_private_witness",
                        "current_index_marker_nonHEAD_dirty_repository_rejected",
                    ].contains(ontologyCase.caseID)
                ? 1 : 0
            XCTAssertEqual(
                recipe.expectedValidHelperRecordCount,
                independentlyExpectedRecordCount
            )
            XCTAssertEqual(
                ontologyCase.expectedValidHelperRecordCount,
                independentlyExpectedRecordCount
            )

            if ontologyCase.relationSuffixOccurrenceCount == 1
                && ontologyCase.executionKind != "direct_component_harness"
            {
                let mergeID = try XCTUnwrap(ontologyCase.relationMergeFixtureID)
                let merge = try XCTUnwrap(objectByID[mergeID])
                XCTAssertTrue(merge.expectedDestinationInventoryPresent)
                XCTAssertEqual(recipe.eventCurrentFixtureID, mergeID)
                XCTAssertEqual(
                    try XCTUnwrap(parsedCommitByID[mergeID]).treeOID,
                    tree.literalObjectOID
                )
            }
        }

        let legacyCase = try XCTUnwrap(casesByID[
            "legacy_flat_nonHEAD_dirty_repository_remains_legacy"
        ])
        let activatedCase = try XCTUnwrap(casesByID[
            "current_index_marker_nonHEAD_dirty_repository_rejected"
        ])
        let legacyRecipe = try XCTUnwrap(recipeByCase[legacyCase.caseID])
        let activatedRecipe = try XCTUnwrap(recipeByCase[activatedCase.caseID])
        XCTAssertEqual(legacyCase.eventKind, activatedCase.eventKind)
        XCTAssertEqual(legacyCase.explicitFixtureIDs, activatedCase.explicitFixtureIDs)
        XCTAssertEqual(legacyRecipe.exactInitArgumentVector, activatedRecipe.exactInitArgumentVector)
        XCTAssertEqual(legacyRecipe.exactWrittenFixtureIDs, activatedRecipe.exactWrittenFixtureIDs)
        XCTAssertEqual(legacyRecipe.exactWithheldFixtureIDs, activatedRecipe.exactWithheldFixtureIDs)
        XCTAssertEqual(
            legacyRecipe.exactUpdateRefHEADArgumentVector,
            activatedRecipe.exactUpdateRefHEADArgumentVector
        )
        XCTAssertEqual(legacyRecipe.exactReadTreeArgumentVector, activatedRecipe.exactReadTreeArgumentVector)
        XCTAssertEqual(legacyRecipe.typedMutationTokens, activatedRecipe.typedMutationTokens)
        XCTAssertEqual(legacyRecipe.eventCurrentFixtureID, "unrelated")
        XCTAssertEqual(activatedRecipe.eventCurrentFixtureID, "unrelated")
        XCTAssertEqual(legacyCase.currentIndexMarkerOccurrenceCount, 0)
        XCTAssertEqual(activatedCase.currentIndexMarkerOccurrenceCount, 1)
        XCTAssertEqual(
            Array(activatedCase.invocationRecipe.exactHelperArgumentTokens.dropLast()),
            legacyCase.invocationRecipe.exactHelperArgumentTokens
        )
        XCTAssertEqual(
            activatedCase.invocationRecipe.exactHelperArgumentTokens.last,
            authority.relationAPIContract.currentIndexMarker
        )
        XCTAssertTrue(legacyRecipe.exactExpectedGateProbeBodies.isEmpty)
        XCTAssertTrue(activatedRecipe.exactExpectedGateProbeBodies.isEmpty)
        XCTAssertEqual(
            activatedRecipe.exactExpectedHelperPreProbeBodies,
            [unrelated.literalObjectOID + "\n"]
        )
    }

    private func assertComponentHarnessRecipes(
        _ authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        parsedCommitByID: [String: ParsedCommit],
        captureByID: [String: Authority.CaptureFixture]
    ) throws {
        let casesByID = Dictionary(
            uniqueKeysWithValues: authority.relationOntologyCases.map {
                ($0.caseID, $0)
            }
        )
        let repositoryRecipeIDs = Set(
            authority.privateRepositoryExecutionRecipes.map(\.recipeID)
        )
        let cleanGitPrefix = [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=<validated_private_compiler_root>",
            "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
            "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
            "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
            "/usr/bin/git",
        ]
        let classifierPrefix = [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=<validated_private_compiler_root>",
            "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
        ]
        let fixedOID = try XCTUnwrap(objectByID["fixed_parent"]?.literalObjectOID)
        let treeOID = try XCTUnwrap(objectByID["empty_tree"]?.literalObjectOID)
        let recipes = authority.componentHarnessRecipes
        XCTAssertEqual(recipes.count, 6)
        XCTAssertEqual(recipes.map(\.ordinal), Array(1 ... 6))
        XCTAssertEqual(recipes.map(\.ontologyCaseID), [
            "wave1_missing_merge_stops_all_raw",
            "merge_wrong_tree_isolated",
            "wave2_phase15_outweighs_earlier_explicit_raw_failure",
            "wrong_tree_one_parent_selects_tree_without_witness",
            "child_phase15_beats_merge_phase37",
            "alternate_valid_merge_role_missing_is_selected",
        ])
        for recipe in recipes {
            let ontologyCase = try XCTUnwrap(casesByID[recipe.ontologyCaseID])
            XCTAssertTrue(repositoryRecipeIDs.contains(recipe.privateRepositoryRecipeID))
            XCTAssertEqual(recipe.constructionKind, "private_repository_component_harness")
            XCTAssertEqual(
                recipe.futureMatrixComponentPath,
                ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh"
            )
            XCTAssertEqual(
                recipe.futureMatrixFunctionName,
                "prime_test_exact_revision_topology_component_harness_v1"
            )
            XCTAssertEqual(
                recipe.exactFutureMatrixFunctionGrammar,
                "prime_test_exact_revision_topology_component_harness_v1 <component_recipe_id>"
            )
            XCTAssertEqual(
                recipe.exactFutureMatrixCallSiteLiteral,
                "prime_test_exact_revision_topology_component_harness_v1 \"\(recipe.recipeID)\""
            )
            XCTAssertEqual(recipe.exactFutureMatrixCallSiteCount, 1)
            XCTAssertEqual(recipe.publicHelperInvocationCount, 0)
            XCTAssertEqual(recipe.gateInvocationCount, 0)
            XCTAssertEqual(recipe.indexBarrierInvocationCount, 0)
            XCTAssertEqual(recipe.validHelperRecordCount, 0)
            XCTAssertEqual(recipe.projectionInvocationCount, 0)
            XCTAssertEqual(recipe.classifierBuildInvocationCount, 0)
            XCTAssertTrue(recipe.reusesAdmittedSelfTestedClassifier)
            XCTAssertEqual(
                recipe.exactOrderedSteps.map(\.ordinal),
                Array(1 ... recipe.exactOrderedSteps.count)
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "merge_preprobe"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentMergePreprobeGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "merge_relation_raw"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentMergeRawGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "merge_relation_raw"
                }.reduce(0) { $0 + $1.physicalClassifierInvocationCount },
                ontologyCase.expectedComponentMergeClassifierInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "child_preprobe"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentChildPreprobeGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "child_ordinary_raw"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentChildRawGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "child_ordinary_raw"
                }.reduce(0) { $0 + $1.physicalClassifierInvocationCount },
                ontologyCase.expectedComponentChildClassifierInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "explicit_ordinary_transport_frame_injection"
                }.reduce(0) { $0 + $1.pureFrameInjectionHookInvocationCount },
                ontologyCase.expectedComponentExplicitFrameInjectionCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "explicit_preprobe"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentExplicitPreprobeGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "explicit_ordinary_raw"
                }.reduce(0) { $0 + $1.physicalGitInvocationCount },
                ontologyCase.expectedComponentExplicitRawGitInvocationCount
            )
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "explicit_ordinary_raw"
                }.reduce(0) { $0 + $1.physicalClassifierInvocationCount },
                ontologyCase.expectedComponentExplicitClassifierInvocationCount
            )
            XCTAssertEqual(recipe.successfulCandidateTupleCount, 0)
            XCTAssertEqual(recipe.selectorHookInvocationCount, 1)
            XCTAssertEqual(
                recipe.exactOrderedSteps.filter {
                    $0.stepKind == "selector_hook"
                }.count,
                1
            )

            var crossBoundOIDs: [String] = []
            for step in recipe.exactOrderedSteps {
                if let literalOID = step.literalObjectOID {
                    let fixture = try XCTUnwrap(objectByID.values.first {
                        $0.literalObjectOID == literalOID
                    })
                    if let stdinFixtureID = step.stdinFixtureID {
                        XCTAssertEqual(stdinFixtureID, fixture.fixtureID)
                        let stdin = try XCTUnwrap(
                            Data(base64Encoded: fixture.payloadBase64)
                        )
                        XCTAssertEqual(stdin.count, fixture.payloadByteCount)
                    }
                    if let exactPreprobeLine = step.exactPreprobeLine {
                        XCTAssertEqual(
                            exactPreprobeLine,
                            literalOID + (fixture.expectedDestinationInventoryPresent
                                ? " \(fixture.objectType) \(fixture.payloadByteCount)\n"
                                : " missing\n")
                        )
                    }
                    if step.stepKind == "merge_relation_raw",
                       let parent2 = parsedCommitByID[fixture.fixtureID]?
                        .parentOIDs.dropFirst().first
                    {
                        crossBoundOIDs.append(parent2)
                    }
                    if ["child_preprobe", "child_ordinary_raw"]
                        .contains(step.stepKind)
                    {
                        crossBoundOIDs.append(literalOID)
                    }
                }
                if let captureFixtureID = step.captureFixtureID {
                    let capture = try XCTUnwrap(captureByID[captureFixtureID])
                    XCTAssertEqual(capture.gitStatus, step.producerStatus)
                    XCTAssertEqual(capture.classifierStatus, step.classifierStatus)
                    let body = try XCTUnwrap(Data(base64Encoded: capture.bodyBase64))
                    if isExactWitness(body) {
                        crossBoundOIDs.append(try XCTUnwrap(
                            String(data: body.dropLast(), encoding: .utf8)
                        ))
                    }
                }
                if let classifierMode = step.classifierMode {
                    XCTAssertEqual(
                        step.expectedTreeOID,
                        treeOID
                    )
                    XCTAssertEqual(
                        step.fixedParentOID,
                        classifierMode == "relation" ? fixedOID : nil
                    )
                }
                switch step.stepKind {
                case "merge_preprobe", "child_preprobe":
                    let oid = try XCTUnwrap(step.literalObjectOID)
                    XCTAssertEqual(
                        step.executionKind,
                        "live_inherited_exact_object_batch_preprobe"
                    )
                    XCTAssertEqual(
                        step.exactContractSource,
                        "PrimeExactRevisionTopologyVerifierAuthorityV1.commitHeaderContract.exactObjectPreprobeArgumentVector"
                    )
                    XCTAssertEqual(
                        step.exactGitArgumentVector,
                        cleanGitPrefix + [
                            "-C", "<private_repository>", "cat-file",
                            "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                        ]
                    )
                    XCTAssertEqual(step.exactPreprobeStdin, oid + "\n")
                    XCTAssertTrue(step.exactClassifierArgumentVector.isEmpty)
                    XCTAssertEqual(step.physicalGitInvocationCount, 1)
                    XCTAssertEqual(step.physicalClassifierInvocationCount, 0)
                    XCTAssertEqual(step.productionFrameAdmissionInvocationCount, 0)
                    XCTAssertEqual(step.pureFrameInjectionHookInvocationCount, 0)
                case "merge_relation_raw", "child_ordinary_raw":
                    let oid = try XCTUnwrap(step.literalObjectOID)
                    let fixture = try XCTUnwrap(objectByID.values.first {
                        $0.literalObjectOID == oid
                    })
                    XCTAssertEqual(
                        step.exactGitArgumentVector,
                        cleanGitPrefix + [
                            "-C", "<private_repository>", "cat-file", "commit", oid,
                        ]
                    )
                    XCTAssertEqual(step.advertisedObjectByteCount, fixture.payloadByteCount)
                    XCTAssertEqual(step.stdinFixtureID, fixture.fixtureID)
                    XCTAssertEqual(step.physicalGitInvocationCount, 1)
                    XCTAssertEqual(step.physicalClassifierInvocationCount, 1)
                    XCTAssertEqual(step.productionFrameAdmissionInvocationCount, 1)
                    XCTAssertEqual(step.pureFrameInjectionHookInvocationCount, 0)
                    XCTAssertEqual(
                        Array(step.exactClassifierArgumentVector.prefix(5)),
                        classifierPrefix
                    )
                    if step.stepKind == "merge_relation_raw" {
                        XCTAssertEqual(
                            Array(step.exactClassifierArgumentVector.dropFirst(5)),
                            [
                                "--ordered-merge-child-relation", oid,
                                String(fixture.payloadByteCount), treeOID, fixedOID,
                            ]
                        )
                    } else {
                        XCTAssertEqual(
                            Array(step.exactClassifierArgumentVector.dropFirst(5)),
                            [
                                oid, String(fixture.payloadByteCount), treeOID,
                                "1", fixedOID,
                            ]
                        )
                    }
                case "explicit_ordinary_transport_frame_injection":
                    let capture = try XCTUnwrap(
                        step.captureFixtureID.flatMap { captureByID[$0] }
                    )
                    XCTAssertEqual(
                        step.executionKind,
                        "pure_framed_transport_injection_same_production_frame_parser_no_git_or_classifier"
                    )
                    XCTAssertEqual(capture.mode, "ordinary")
                    XCTAssertEqual(capture.gitStatus, 1)
                    XCTAssertEqual(capture.classifierStatus, 0)
                    XCTAssertEqual(capture.bodyByteCount, 0)
                    XCTAssertEqual(step.physicalGitInvocationCount, 0)
                    XCTAssertEqual(step.physicalClassifierInvocationCount, 0)
                    XCTAssertEqual(step.productionFrameAdmissionInvocationCount, 1)
                    XCTAssertEqual(step.pureFrameInjectionHookInvocationCount, 1)
                    XCTAssertEqual(
                        Array(step.exactGitArgumentVector.prefix(cleanGitPrefix.count)),
                        cleanGitPrefix
                    )
                    XCTAssertEqual(
                        Array(step.exactClassifierArgumentVector.prefix(5)),
                        classifierPrefix
                    )
                case "child_distinctness_guard":
                    let childOID = try XCTUnwrap(step.literalObjectOID)
                    XCTAssertFalse(step.exactDistinctnessComparisonOIDs.isEmpty)
                    XCTAssertFalse(step.exactDistinctnessComparisonOIDs.contains(childOID))
                    XCTAssertEqual(step.distinctnessExpectedPass, true)
                    XCTAssertTrue(step.exactGitArgumentVector.isEmpty)
                    XCTAssertTrue(step.exactClassifierArgumentVector.isEmpty)
                    XCTAssertEqual(step.physicalGitInvocationCount, 0)
                    XCTAssertEqual(step.physicalClassifierInvocationCount, 0)
                case "selector_hook":
                    XCTAssertEqual(
                        step.executionKind,
                        "pure_shared_production_selector_hook"
                    )
                    XCTAssertTrue(step.exactGitArgumentVector.isEmpty)
                    XCTAssertTrue(step.exactClassifierArgumentVector.isEmpty)
                    XCTAssertEqual(step.physicalGitInvocationCount, 0)
                    XCTAssertEqual(step.physicalClassifierInvocationCount, 0)
                default:
                    XCTFail("unknown component step \(step.stepKind)")
                }
            }
            if recipe.rawParent2CaptureAndChildLiteralMustEqual {
                XCTAssertFalse(crossBoundOIDs.isEmpty)
                XCTAssertEqual(Set(crossBoundOIDs).count, 1, recipe.recipeID)
            }
            let distinctIndex = recipe.exactOrderedSteps.firstIndex {
                $0.stepKind == "child_distinctness_guard"
            }
            let childPreprobeIndex = recipe.exactOrderedSteps.firstIndex {
                $0.stepKind == "child_preprobe"
            }
            let derivedDistinctnessOrder = childPreprobeIndex.map { childIndex in
                distinctIndex.map { distinctIndex in
                    distinctIndex < childIndex
                        && recipe.exactOrderedSteps[distinctIndex]
                            .distinctnessExpectedPass == true
                } ?? false
            } ?? true
            XCTAssertEqual(
                recipe.childDistinctnessStepPrecedesChildPreprobeAndAllComparedOIDsDiffer,
                derivedDistinctnessOrder
            )

            let parsedTuples = try recipe.exactSelectorCandidateTuples.map { row in
                let fields = row.split(
                    separator: "|", omittingEmptySubsequences: false
                ).map(String.init)
                XCTAssertEqual(fields.count, 5, recipe.recipeID)
                return (
                    phase: try XCTUnwrap(Int(fields[0])),
                    object: try XCTUnwrap(Int(fields[1])),
                    result: fields[2],
                    guardID: fields[3],
                    missingRole: fields[4].isEmpty ? nil : fields[4]
                )
            }
            let selected = try XCTUnwrap(parsedTuples.min {
                if $0.phase != $1.phase { return $0.phase < $1.phase }
                return $0.object < $1.object
            })
            if let injectedTransport = recipe.exactOrderedSteps.first(
                where: {
                    $0.stepKind == "explicit_ordinary_transport_frame_injection"
                }
            ) {
                XCTAssertTrue(parsedTuples.contains {
                    $0.phase == 20
                        && $0.object == injectedTransport.logicalObjectOrdinal
                        && $0.result == "TOPOLOGY_OBSERVATION_FAILED"
                        && $0.guardID == "git_cat_file_transport_succeeded"
                        && $0.missingRole == nil
                })
            }
            XCTAssertEqual(selected.result, recipe.expectedResultCode)
            XCTAssertEqual(selected.guardID, recipe.expectedFirstFailedGuardID)
            XCTAssertEqual(selected.phase, recipe.expectedFirstFailedPhaseOrdinal)
            XCTAssertEqual(selected.object, recipe.expectedFirstFailureObjectOrdinal)
            XCTAssertEqual(selected.missingRole, recipe.expectedMissingObjectRole)
            XCTAssertEqual(recipe.expectedResultCode, ontologyCase.expectedResultCode)
            XCTAssertEqual(
                recipe.expectedFirstFailedGuardID,
                ontologyCase.expectedFirstFailedGuardID
            )
            XCTAssertEqual(
                recipe.expectedMissingObjectRole,
                ontologyCase.expectedMissingObjectRole
            )
        }
    }

    private func assertDeterministicLiveEPIPERecipe(
        _ authority: Authority,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        captureByID: [String: Authority.CaptureFixture]
    ) throws {
        let recipe = authority.deterministicLiveEPIPERecipe
        XCTAssertEqual(recipe.recipeID, "live_relation_witness_F_SETNOSIGPIPE_EPIPE")
        XCTAssertEqual(
            recipe.executionKind,
            "future_private_matrix_deterministic_live_classifier_fifo_epipe"
        )
        XCTAssertEqual(
            recipe.futureMatrixComponentPath,
            ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh"
        )
        XCTAssertEqual(
            recipe.futureMatrixFunctionName,
            "prime_test_live_relation_classifier_epipe_v1"
        )
        XCTAssertEqual(
            recipe.exactFutureMatrixFunctionGrammar,
            "prime_test_live_relation_classifier_epipe_v1 <validated_private_matrix_root> <admitted_classifier_path>"
        )
        XCTAssertEqual(
            recipe.exactFutureMatrixCallSiteLiteral,
            "prime_test_live_relation_classifier_epipe_v1 \"${prime_private_matrix_root}\" \"${prime_classifier_path}\""
        )
        XCTAssertEqual(recipe.exactFutureMatrixCallSiteCount, 1)
        XCTAssertEqual(recipe.futurePrivateMatrixInvocationCount, 1)
        XCTAssertEqual(recipe.publicHelperInvocationCount, 0)
        XCTAssertEqual(recipe.gateInvocationCount, 0)
        XCTAssertEqual(recipe.validHelperRecordCount, 0)
        XCTAssertEqual(recipe.projectionInvocationCount, 0)
        XCTAssertEqual(recipe.witnessPublicationCount, 0)
        XCTAssertTrue(recipe.validatedPrivateMatrixRootRequired)
        XCTAssertEqual(recipe.exactUmask, "0077")
        XCTAssertEqual(recipe.exactAdmittedToolPaths, [
            "/bin/bash", "/bin/rm", "/usr/bin/env", "/usr/bin/mkfifo",
            "/usr/bin/stat",
        ])
        XCTAssertEqual(
            recipe.fifoPath,
            "<validated_private_matrix_root>/prime-topology-epipe.fifo"
        )
        XCTAssertEqual(recipe.fifoLeafASCIIRegex, "^prime-topology-epipe\\.fifo$")
        XCTAssertTrue(recipe.fifoMustBeAbsentAndFinalComponentNonlinkBeforeCreation)
        XCTAssertEqual(recipe.exactMkfifoArgumentVector, [
            "/usr/bin/mkfifo", "-m", "0600",
            recipe.fifoPath,
        ])
        XCTAssertEqual(recipe.mkfifoExpectedStatus, 0)
        XCTAssertEqual(recipe.mkfifoExpectedStdoutByteCount, 0)
        XCTAssertEqual(recipe.mkfifoExpectedStderrByteCount, 0)
        XCTAssertEqual(recipe.exactFifoStatArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/stat",
            "-f", "%u %p %HT", "--", recipe.fifoPath,
        ])
        XCTAssertEqual(
            recipe.exactFifoStatOutput,
            "<decimal_effective_uid> 10600 Fifo File\n"
        )
        XCTAssertEqual(recipe.fifoStatExpectedStatus, 0)
        XCTAssertTrue(recipe.fifoOwnerMustEqualEffectiveUID)
        XCTAssertEqual(recipe.fifoReaderProcessCount, 1)
        XCTAssertEqual(recipe.readerOpenDescriptor, 3)
        XCTAssertEqual(recipe.parentWriterDescriptor, 4)
        XCTAssertEqual(
            recipe.exactReaderLaunchGrammar,
            "/bin/bash -p -c 'exec 3<\"$1\"; exec 3<&-' prime-epipe-reader <validated_private_matrix_root>/prime-topology-epipe.fifo"
        )
        XCTAssertEqual(
            recipe.exactClassifierLaunchGrammar,
            "exact_in_memory_decoded_valid_relation_merge_payload_to_fd0;fd1_dup_from_parent_fd4;fd2_private_bounded_capture;then_exactClassifierArgumentVector"
        )
        XCTAssertEqual(recipe.exactHandshakeOrder.count, 8)
        XCTAssertEqual(
            recipe.exactHandshakeOrder.first,
            "spawn_one_private_bash_reader_that_blocks_opening_fifo_fd3_read_only"
        )
        XCTAssertEqual(
            recipe.exactHandshakeOrder.last,
            "parent_waits_classifier_once_and_requires_status28"
        )
        XCTAssertEqual(recipe.readerExpectedStatus, 0)
        XCTAssertTrue(recipe.readerIsWaitedAndClosedBeforeClassifierLaunch)
        XCTAssertTrue(recipe.zeroFIFOReadersProvedBeforeClassifierLaunch)
        XCTAssertTrue(recipe.classifierStandardOutputDuplicatesWriterDescriptor)
        XCTAssertEqual(
            recipe.requiredClassifierInheritedFDSubsetBeforeProductionClosure,
            [0, 1, 2, 4]
        )
        XCTAssertTrue(recipe.additionalInheritedDescriptorsMayExistAndMustBeClosed)
        XCTAssertEqual(recipe.exactClassifierFinalFDsAfterProductionClosure, [0, 1, 2])

        let fixture = try XCTUnwrap(objectByID[recipe.stdinFixtureID])
        let payload = try XCTUnwrap(Data(base64Encoded: fixture.payloadBase64))
        XCTAssertEqual(fixture.fixtureID, "valid_relation_merge")
        XCTAssertEqual(recipe.stdinFixturePayloadByteCount, payload.count)
        XCTAssertEqual(
            recipe.stdinFixturePayloadSHA256,
            hexString(SHA256.hash(data: payload))
        )
        XCTAssertEqual(recipe.exactClassifierArgumentVector, [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=<validated_private_compiler_root>",
            "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
            "--ordered-merge-child-relation",
            fixture.literalObjectOID,
            String(fixture.payloadByteCount),
            try XCTUnwrap(objectByID["empty_tree"]?.literalObjectOID),
            try XCTUnwrap(objectByID["fixed_parent"]?.literalObjectOID),
        ])
        XCTAssertEqual(recipe.exactExpectedClassifierStatus, 28)
        XCTAssertEqual(recipe.exactExpectedClassifierStdoutBodyByteCount, 0)
        XCTAssertEqual(recipe.exactExpectedClassifierStderrByteCount, 0)
        let statusPayload = try XCTUnwrap(
            captureByID[recipe.expectedStatusPayloadFixtureID]
        )
        XCTAssertEqual(statusPayload.mode, "relation")
        XCTAssertEqual(statusPayload.gitStatus, 0)
        XCTAssertEqual(statusPayload.classifierStatus, 28)
        XCTAssertEqual(statusPayload.bodyByteCount, 0)
        XCTAssertFalse(statusPayload.bodyConsumedAsChildOID)
        XCTAssertTrue(recipe.exercisesProductionFSETNOSIGPIPEPath)
        XCTAssertFalse(recipe.signalHandlerInstalled)
        XCTAssertEqual(recipe.classifierOrParentShellSIGPIPECount, 0)
        XCTAssertTrue(recipe.writeReturnsEPIPEBeforeAnyProgress)
        XCTAssertEqual(recipe.exactLogicalWitnessWriteOperationCount, 1)
        XCTAssertTrue(recipe.classifierWaitStatusCapturedExactlyOnce)
        XCTAssertTrue(recipe.partialPrefixLengthsOneThroughFortyArePureInjectionsOnly)
        XCTAssertEqual(recipe.exactCleanupArgumentVector, [
            "/bin/rm", "-f", "--", recipe.fifoPath,
        ])
        XCTAssertEqual(recipe.cleanupExpectedStatus, 0)
        XCTAssertEqual(recipe.cleanupInvocationCount, 1)
        XCTAssertTrue(recipe.noNetwork)
        XCTAssertFalse(recipe.sameEUIDConcurrentMutationInScope)
    }

    private func semanticFacts(
        for ontologyCase: OntologyCase,
        factIDs: Set<String>,
        objectByID: [String: Authority.SyntheticGitObjectFixture],
        parsedCommitByID: [String: ParsedCommit],
        captureByID: [String: Authority.CaptureFixture],
        inventoryPresence: [String: Bool],
        authority: Authority
    ) throws -> [String: Bool] {
        let fixedOID = objectByID["fixed_parent"]!.literalObjectOID
        let indexTreeOID = objectByID["empty_tree"]!.literalObjectOID
        let explicitOIDs = ontologyCase.explicitFixtureIDs.map {
            objectByID[$0]!.literalObjectOID
        }
        let mergeFixture = ontologyCase.relationMergeFixtureID.flatMap {
            objectByID[$0]
        }
        let mergeParsed = ontologyCase.relationMergeFixtureID.flatMap {
            parsedCommitByID[$0]
        }
        let childFixture = ontologyCase.discoveredChildFixtureID.flatMap {
            objectByID[$0]
        }
        let childParsed = ontologyCase.discoveredChildFixtureID.flatMap {
            parsedCommitByID[$0]
        }
        let parent2 = mergeParsed?.parentOIDs.dropFirst().first
        let mergeOIDFromVector: String? = {
            let tokens = ontologyCase.invocationRecipe.exactHelperArgumentTokens
            guard let marker = tokens.firstIndex(of: "--ordered-merge-child-relation"),
                  marker + 2 < tokens.count
            else { return nil }
            return tokens[marker + 2]
        }()
        let mergeOID = mergeFixture?.literalObjectOID ?? mergeOIDFromVector
        let mergeIsAvailableForSemanticObservation = ontologyCase
            .relationMergeFixtureID.flatMap { inventoryPresence[$0] } ?? true
        let captureFixture = ontologyCase.captureFixtureID.flatMap { captureByID[$0] }
        let captureBody = captureFixture.flatMap { Data(base64Encoded: $0.bodyBase64) }
        let captureTrailer = captureFixture.flatMap { Data(base64Encoded: $0.trailerBase64) }
        let parsedTrailer = captureTrailer.flatMap(parseStatusTrailer)
        let captureWitnessOID = captureBody.flatMap { body -> String? in
            guard isExactWitness(body) else { return nil }
            return String(data: body.dropLast(), encoding: .utf8)
        }
        let independentlyKnownChildOIDs = [
            childFixture?.literalObjectOID,
            captureWitnessOID,
            parent2,
        ].compactMap { $0 }
        XCTAssertLessThanOrEqual(
            Set(independentlyKnownChildOIDs).count,
            1,
            ontologyCase.caseID
        )
        let expectedDiscoveredChildOID = independentlyKnownChildOIDs.first
        let captureIsSafeChildCandidate = captureFixture.map { fixture in
            guard fixture.mode == "relation" else { return true }
            return parsedTrailer == ParsedTrailer(
                gitStatus: fixture.gitStatus,
                classifierStatus: fixture.classifierStatus
            )
                && fixture.gitStatus == 0
                && [0, 41, 42].contains(fixture.classifierStatus)
                && captureWitnessOID != nil
        } ?? true
        let roles: [String] = {
            guard let requests = parseOrdinaryRequests(
                ontologyCase.invocationRecipe.exactHelperArgumentTokens
            ) else { return [] }
            var result = requests.map(\.role)
            let tokens = ontologyCase.invocationRecipe.exactHelperArgumentTokens
            if let marker = tokens.firstIndex(of: "--ordered-merge-child-relation"),
               marker + 5 < tokens.count
            {
                result += [tokens[marker + 1], tokens[marker + 5]]
            }
            return result
        }()
        let suffixRoles: (merge: String, child: String)? = {
            let tokens = ontologyCase.invocationRecipe.exactHelperArgumentTokens
            guard let marker = tokens.firstIndex(
                of: authority.relationAPIContract.optionalSuffixMarker
            ), marker + 5 < tokens.count
            else { return nil }
            return (tokens[marker + 1], tokens[marker + 5])
        }()
        var result: [String: Bool] = [:]
        for factID in factIDs {
            switch factID {
            case "pull_request_current_is_direct_child":
                if ontologyCase.eventKind == "pull_request",
                   let first = ontologyCase.explicitFixtureIDs.first,
                   let parsed = parsedCommitByID[first]
                {
                    result[factID] = parsed.treeOID == indexTreeOID
                        && parsed.parentOIDs == [fixedOID]
                } else { result[factID] = true }
            case "merge_differs_from_fixed":
                result[factID] = mergeOID.map { $0 != fixedOID } ?? true
            case "merge_differs_from_explicit_literals":
                result[factID] = mergeOID.map { !explicitOIDs.contains($0) } ?? true
            case "relation_roles_unique":
                result[factID] = Set(roles).count == roles.count
            case "relation_total_object_bound":
                result[factID] = ontologyCase.explicitFixtureIDs.count
                    + (ontologyCase.relationSuffixOccurrenceCount > 0 ? 2 : 0) <= 8
            case "wave1_merge_available":
                if ontologyCase.invocationRecipe.exactPureHookStimulusTokens
                    .contains(
                        "merge_inventory:pure_injected_missing_without_destination_write"
                    )
                {
                    result[factID] = false
                } else {
                    result[factID] = ontologyCase.relationMergeFixtureID
                        .flatMap { inventoryPresence[$0] } ?? true
                }
            case "relation_header_structurally_valid":
                result[factID] = !mergeIsAvailableForSemanticObservation
                    || (mergeParsed?.structurallyValid ?? true)
            case "relation_merge_has_parent2":
                result[factID] = !mergeIsAvailableForSemanticObservation
                    || (mergeParsed.map { $0.parentOIDs.count >= 2 } ?? true)
            case "merge_tree_equals_index":
                result[factID] = !mergeIsAvailableForSemanticObservation
                    || (mergeParsed.map { $0.treeOID == indexTreeOID } ?? true)
            case "child_tree_equals_index":
                result[factID] = childParsed.map { $0.treeOID == indexTreeOID } ?? true
            case "merge_ordered_parents_equal_fixed_then_child":
                result[factID] = !mergeIsAvailableForSemanticObservation
                    || (mergeParsed.map {
                    $0.parentOIDs.count == 2
                        && $0.parentOIDs.first == fixedOID
                        && $0.parentOIDs.last == expectedDiscoveredChildOID
                } ?? true)
            case "child_ordered_parents_equal_sole_fixed":
                result[factID] = childParsed.map { $0.parentOIDs == [fixedOID] } ?? true
            case "child_differs_from_fixed":
                result[factID] = parent2.map { $0 != fixedOID } ?? true
            case "child_differs_from_explicit_literals":
                result[factID] = parent2.map { !explicitOIDs.contains($0) } ?? true
            case "child_differs_from_merge":
                if ontologyCase.valueDomainFixtureID == "discovered_child_equals_merge" {
                    result[factID] = false
                } else {
                    result[factID] = parent2.flatMap { child in
                        mergeOID.map { child != $0 }
                    } ?? true
                }
            case "relation_frame_exact_and_usable":
                result[factID] = captureIsSafeChildCandidate
            case "discovered_child_is_commit":
                result[factID] = childFixture.map { $0.objectType == "commit" } ?? true
            case "signed_header_continuations_preserve_relation":
                result[factID] = mergeParsed?.signedContinuationsValid ?? true
            case "tree_guard_precedes_parent_guard_without_parent2":
                if let mergeParsed, mergeParsed.parentOIDs.count < 2 {
                    result[factID] = mergeParsed.treeOID == indexTreeOID
                } else { result[factID] = true }
            case "trace_state_admitted":
                result[factID] = !ontologyCase.invocationRecipe.exactExternalStateTokens
                    .contains(where: { $0.hasPrefix("hostile_trace_variants:") })
            case "current_index_marker_at_most_once":
                result[factID] = ontologyCase.currentIndexMarkerOccurrenceCount <= 1
            case "terminal_markers_mutually_exclusive":
                result[factID] = !(ontologyCase.currentIndexMarkerOccurrenceCount > 0
                    && ontologyCase.relationSuffixOccurrenceCount > 0)
            case "current_index_marker_is_terminal":
                let tokens = ontologyCase.invocationRecipe.exactHelperArgumentTokens
                if ontologyCase.currentIndexMarkerOccurrenceCount == 0 {
                    result[factID] = true
                } else if let last = tokens.lastIndex(of: "--current-index-exact-revision") {
                    result[factID] = last == tokens.count - 1
                } else {
                    result[factID] = ontologyCase.caseID
                        == "current_index_marker_nonHEAD_dirty_repository_rejected"
                }
            case "classifier_exit_status_is_known":
                if parsedTrailer == nil {
                    result[factID] = true
                } else if let captureFixture {
                    result[factID] = authority.relationClassifierContract
                        .exactKnownExitStatuses.contains(captureFixture.classifierStatus)
                } else { result[factID] = true }
            case "relation_status_trailer_frame_is_exact":
                result[factID] = captureFixture == nil || parsedTrailer != nil
            case "merge_has_exactly_two_ordered_parents":
                result[factID] = !mergeIsAvailableForSemanticObservation
                    || (mergeParsed.map { $0.parentOIDs.count == 2 } ?? true)
            case "discovered_child_available":
                if let childID = ontologyCase.discoveredChildFixtureID {
                    result[factID] = inventoryPresence[childID] ?? false
                } else if let parent2,
                          let object = objectByID.values.first(where: {
                              $0.literalObjectOID == parent2
                          })
                {
                    result[factID] = inventoryPresence[object.fixtureID] ?? false
                } else { result[factID] = true }
            case "relation_has_no_competing_wave2_lower_phase_failure":
                result[factID] = !(ontologyCase.executionKind
                    == "private_repository_with_transport_injection"
                    && ontologyCase.discoveredChildFixtureID
                        .flatMap { inventoryPresence[$0] } == false)
            case "index_and_HEAD_stable_through_helper":
                result[factID] = !ontologyCase.invocationRecipe.exactExternalStateTokens
                    .contains("internal_core_mode:post_raw_read_tree_alternate")
            case "event_kind_admitted":
                result[factID] = ["pull_request", "push"]
                    .contains(ontologyCase.eventKind)
            case "legacy_flat_without_marker_unchanged":
                let state = ontologyCase.invocationRecipe.exactExternalStateTokens
                result[factID] = state.contains(
                    "target_repository_HEAD_differs_from_requested_literal_oid"
                )
                    && state.contains(
                        "target_repository_status_porcelain_v1_untracked_files_all_is_nonempty"
                    )
                    && ontologyCase.currentIndexMarkerOccurrenceCount == 0
                    && ontologyCase.relationSuffixOccurrenceCount == 0
                    && ontologyCase.expectedValidHelperRecordCount == 1
            case "relation_explicit_topology_matches_expected":
                guard let requests = parseOrdinaryRequests(
                    ontologyCase.invocationRecipe.exactHelperArgumentTokens
                ) else {
                    result[factID] = true
                    continue
                }
                result[factID] = requests.enumerated().allSatisfy { offset, request in
                    guard offset < ontologyCase.explicitFixtureIDs.count,
                          let parsed = parsedCommitByID[
                              ontologyCase.explicitFixtureIDs[offset]
                          ]
                    else { return false }
                    return parsed.treeOID == request.expectedTreeOID
                        && parsed.parentOIDs == request.expectedParentOIDs
                }
            case "alternate_valid_merge_role_is_selected_on_missing_merge":
                result[factID] = suffixRoles?.merge == "alternate_merge_role"
                    && isValidRole(suffixRoles?.merge ?? "")
            case "alternate_valid_child_role_is_projected_on_missing_child":
                result[factID] = suffixRoles?.child == "alternate_child_role"
                    && isValidRole(suffixRoles?.child ?? "")
            default:
                XCTFail("unhandled semantic fact \(factID)")
                result[factID] = false
            }
        }
        return result
    }

    private enum JSONPathComponent: Hashable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func isLowercase40Hex(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            (0x30 ... 0x39).contains($0) || (0x61 ... 0x66).contains($0)
        }
    }

    private func isValidRole(_ value: String) -> Bool {
        guard (1 ... 64).contains(value.utf8.count),
              let first = value.utf8.first,
              (0x61 ... 0x7A).contains(first)
        else { return false }
        return value.utf8.dropFirst().allSatisfy {
            (0x61 ... 0x7A).contains($0)
                || (0x30 ... 0x39).contains($0)
                || $0 == 0x5F
        }
    }

    private func hexString<D: Sequence>(_ bytes: D) -> String
    where D.Element == UInt8 {
        bytes.map { String(format: "%02x", $0) }.joined()
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

    private func allDictionaryPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(in: array[index], prefix: prefix + [.index(index)])
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
            object[key] = replacingValue(in: object[key]!, at: remainder, with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(in: array[index], at: remainder, with: transform)
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
            return NSNumber(value: incremented.overflow
                ? integer.subtractingReportingOverflow(1).partialValue
                : incremented.partialValue)
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
        XCTAssertThrowsError(try Authority.decodeCanonical(data), file: file, line: line)
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
        else { return false }
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
        let slash = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slash ... slash, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(try XCTUnwrap(slashEscaped.data(using: .utf8)))
        )
        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        let reorderedInsertion = reordered.index(after: opening)
        reordered.replaceSubrange(
            reorderedInsertion ..< reorderedInsertion,
            with: schemaField
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(try XCTUnwrap(reordered.data(using: .utf8)))
        )
        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        let duplicateInsertion = duplicate.index(after: duplicateOpening)
        duplicate.replaceSubrange(
            duplicateInsertion ..< duplicateInsertion,
            with: schemaField
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(try XCTUnwrap(duplicate.data(using: .utf8)))
        )
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

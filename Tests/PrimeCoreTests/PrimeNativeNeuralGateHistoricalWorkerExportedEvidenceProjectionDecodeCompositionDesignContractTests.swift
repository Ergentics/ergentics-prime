// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContract

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContract.swift"
    private static let contractFileByteCount: UInt64 = 58_075
    private static let contractFileSHA256 =
        "4a952d0e705d13e603a453592d1686cea80fc4363de48e6294e20a267ccf0281"
    private static let v19WorkerRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
    private static let v19WorkerByteCount: UInt64 = 7_050
    private static let v19WorkerSHA256 =
        "b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca"

    // Frozen after the V20 design contract reached final canonical bytes.
    private static let designContractSHA256 =
        "b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c"
    private static let nextImplementationPrerequisite =
        "source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7"

    func testFrozenContractBindsExactHistoryAndPhysicalSource()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_design_v20"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )

        XCTAssertEqual(
            contract.preservedWorkerExporterCallEdgeV14ContractID,
            "prime_source_bound_historical_worker_evidence_export_call_edge_v14"
        )
        XCTAssertEqual(
            contract.preservedWorkerExporterCallEdgeV14ContractSHA256,
            "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"
        )
        XCTAssertEqual(
            contract.preservedProjectionSourceV16ContractID,
            "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16"
        )
        XCTAssertEqual(
            contract.preservedProjectionSourceV16ContractSHA256,
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
        )
        XCTAssertEqual(
            contract.preservedWorkerProjectionCallEdgeV17ContractID,
            "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17"
        )
        XCTAssertEqual(
            contract.preservedWorkerProjectionCallEdgeV17ContractSHA256,
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        )
        XCTAssertEqual(
            contract.preservedSemanticArtifactDecoderV18ContractID,
            "prime_source_bound_historical_semantic_artifact_decoder_v18"
        )
        XCTAssertEqual(
            contract.preservedSemanticArtifactDecoderV18ContractSHA256,
            "18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3"
        )
        XCTAssertEqual(
            contract.preservedWorkerDecoderCallEdgeV19ContractID,
            "prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19"
        )
        XCTAssertEqual(
            contract.preservedWorkerDecoderCallEdgeV19ContractSHA256,
            "f8739c0d162e026522dbdc2e6902403d935ebcfd2c9d13b07704b05ea3f9dac8"
        )
        XCTAssertEqual(
            contract.preservedTopologyV19ID,
            "prime_stage_b_historical_worker_semantic_artifact_decoder_call_edge_source_topology_v19"
        )
        XCTAssertEqual(
            contract.preservedTopologyV19SHA256,
            "84f07261ff86dab5836e96a2667a8d3a05b0ec597b9677d5f1bab77c2c8801ba"
        )

        let source = try checkedInData(Self.contractRelativePath)
        XCTAssertEqual(
            UInt64(source.count),
            Self.contractFileByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            Self.contractFileSHA256
        )
    }

    func testConceptualComposeAndWorkerCallEdgeAreDistinctAndExact()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.futureCompositionEnclosingTypeName,
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        )
        XCTAssertEqual(contract.futureCompositionMethodName, "compose")
        XCTAssertEqual(
            contract.futureCompositionNormalizedSignature,
            "compose(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
        )
        XCTAssertEqual(
            contract.futureWorkerCallEdgeMethodName,
            "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge"
        )
        XCTAssertEqual(
            contract.futureWorkerCallEdgeNormalizedSignature,
            "private static func sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
        )
        XCTAssertNotEqual(
            contract.futureCompositionMethodName,
            contract.futureWorkerCallEdgeMethodName
        )
        XCTAssertNotEqual(
            contract.futureCompositionNormalizedSignature,
            contract.futureWorkerCallEdgeNormalizedSignature
        )
        XCTAssertTrue(contract.futureWorkerCallEdgeDelegatesOnlyToCompose)
        XCTAssertEqual(contract.futureCompositionAccessLevel, "private")
        XCTAssertTrue(contract.futureCompositionStatic)
        XCTAssertTrue(contract.futureCompositionThrows)

        XCTAssertEqual(contract.exactInputCount, 2)
        XCTAssertEqual(
            contract.exactInputLabels,
            ["evidence", "context"]
        )
        XCTAssertEqual(
            contract.exactInputSwiftTypeNames,
            [
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            ]
        )
        XCTAssertFalse(contract.inputMayBeOptional)
        XCTAssertFalse(contract.inputMayHaveDefault)
        XCTAssertFalse(contract.additionalInputPermitted)
        XCTAssertTrue(contract.evidenceMustBeAlreadyFormed)
        XCTAssertFalse(contract.evidenceMayBeReconstructed)
        XCTAssertFalse(contract.exporterMaterialsInputPermitted)
        XCTAssertTrue(contract.contextMustBeExplicit)
    }

    func testEvidenceRemainsOpaqueAndEqualityIsNotIdentity()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.evidenceCarrierSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence"
        )
        XCTAssertEqual(contract.evidenceExactPublicFieldCount, 9)
        XCTAssertTrue(contract.evidenceCarrierNonCodable)
        XCTAssertTrue(contract.evidenceCarrierEquatable)
        XCTAssertFalse(contract.evidenceCarrierHashable)
        XCTAssertTrue(contract.evidenceCarrierRoleNeutral)
        XCTAssertTrue(contract.evidenceCarrierPathFree)
        XCTAssertTrue(contract.evidenceCarrierTimingFree)
        XCTAssertTrue(contract.evidenceCarrierAuthorityFree)
        XCTAssertFalse(contract.evidenceCanonicalEncodingPermitted)
        XCTAssertTrue(contract.futureCompositionTreatsEvidenceOpaquely)
        XCTAssertFalse(
            contract.futureCompositionMayInspectEvidenceEvaluationFields
        )
        XCTAssertFalse(
            contract
                .futureCompositionMaySortFilterRankRecommendOrRouteEvidence
        )

        for identityClaim in [
            contract.evidenceEquatableMayEstablishCanonicalIdentity,
            contract.evidenceEquatableMayEstablishSourceIdentity,
            contract.evidenceHashMayEstablishIdentity,
            contract.evidenceReflectionMayEstablishIdentity,
            contract.evidenceStringDescriptionMayEstablishIdentity,
            contract.evidenceMemoryRepresentationMayEstablishIdentity,
            contract.floatingPointEqualityMayEstablishCanonicalIdentity,
            contract.unicodeStringEqualityMayEstablishCanonicalIdentity,
            contract.evidenceOriginEstablished,
            contract.evidenceCanonicalIdentityEstablished,
            contract.evidenceSourceIdentityEstablished,
            contract.evidenceCaptureEpochEstablished,
        ] {
            XCTAssertFalse(identityClaim)
        }
        XCTAssertTrue(contract.floatingPointSignedZeroTrapAcknowledged)
        XCTAssertTrue(
            contract.unicodeCanonicalEquivalenceTrapAcknowledged
        )

        let positiveZero = 0.0
        let negativeZero = -0.0
        XCTAssertEqual(positiveZero, negativeZero)
        XCTAssertNotEqual(
            positiveZero.bitPattern,
            negativeZero.bitPattern
        )
    }

    func testContextIsExplicitUnavailableOnlyAndNeverAuthenticated()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.projectionContextSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalProjectionContext"
        )
        XCTAssertEqual(
            contract.exactProjectionContextFieldNames,
            [
                "invocationRole",
                "sourceBytesResolved",
                "adaptationProofRecomputed",
            ]
        )
        XCTAssertEqual(contract.exactProjectionContextFieldCount, 3)
        XCTAssertEqual(
            contract.requiredSourceBytesResolvedState,
            "unavailable"
        )
        XCTAssertEqual(
            contract.requiredAdaptationProofRecomputedState,
            "unavailable"
        )
        XCTAssertFalse(contract.observedTrueContextStatePermitted)
        XCTAssertFalse(contract.observedFalseContextStatePermitted)
        XCTAssertFalse(contract.contextMayBeDefaulted)
        XCTAssertFalse(contract.contextMayBeInferred)
        XCTAssertFalse(contract.contextMayBeNormalized)
        XCTAssertFalse(contract.contextMayBeReconstructed)
        XCTAssertFalse(contract.roleMayBeDefaulted)
        XCTAssertFalse(contract.roleMayBeInferredFromEvidence)
        XCTAssertFalse(
            contract.roleMayBeInferredFromEnvironmentProcessPathOrTarget
        )
        XCTAssertFalse(contract.roleFlipMayBeNormalizedToProbe)
        XCTAssertTrue(
            contract.roleFlipCreatesDistinctCandidateAndNamespace
        )
        XCTAssertFalse(contract.contextInvocationRoleAuthenticated)
        XCTAssertEqual(
            contract.exactAdmissibleInvocationRoleNames,
            ["probe", "verifier"]
        )
    }

    func testFutureOrderReusesMaintainedProjectionAndPrivateV19Decoder()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.maintainedProjectionTypeName,
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        )
        XCTAssertEqual(contract.maintainedProjectionMethodName, "project")
        XCTAssertEqual(contract.exactProjectionCallCount, 1)
        XCTAssertTrue(contract.evidencePassedToProjectionUnchanged)
        XCTAssertTrue(contract.contextPassedToProjectionUnchanged)
        XCTAssertEqual(
            contract.intermediateProjectedArtifactSetSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalProjectedArtifactSet"
        )
        XCTAssertEqual(
            contract.maintainedV19DecoderMethodName,
            "sourceBoundHistoricalSemanticArtifactDecoderCallEdge"
        )
        XCTAssertEqual(contract.exactMaintainedV19DecoderCallCount, 1)
        XCTAssertTrue(contract.sameFilePrivateV19DecoderReuseRequired)
        XCTAssertFalse(
            contract.directV18DecoderReimplementationPermitted
        )
        XCTAssertFalse(contract.duplicateEqualByteZipperPermitted)
        XCTAssertFalse(contract.customJSONParserPermitted)
        XCTAssertFalse(contract.customFrameParserPermitted)
        XCTAssertFalse(
            contract
                .customFrameHeaderOrRecordBoundaryArithmeticPermitted
        )
        XCTAssertTrue(contract.evidenceProjectionDecodeOrderExact)

        XCTAssertTrue(
            contract.futureSourceMustBeAppendOnlySameFileContinuation
        )
        XCTAssertFalse(contract.futureSourceMayRewritePreservedPrefix)
        XCTAssertFalse(contract.futureSourceMayWidenPrivateAccess)
        XCTAssertFalse(contract.futureSourceMayDuplicateV19Zipper)
        XCTAssertFalse(
            contract.futureSourceMayAddParserOrFrameArithmetic
        )
    }

    func testReservedResultIsSendableOnlyAndLinksExactTwentyTwoKeys()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.futureResultSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
        )
        XCTAssertEqual(
            contract.futureResultExactFieldNames,
            ["projectedArtifacts", "decodedArtifacts"]
        )
        XCTAssertEqual(
            contract.futureResultExactFieldSwiftTypeNames,
            [
                "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
                "PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
            ]
        )
        XCTAssertEqual(contract.futureResultExactFieldCount, 2)
        XCTAssertTrue(contract.futureResultNonCodable)
        XCTAssertFalse(contract.futureResultEquatable)
        XCTAssertTrue(contract.futureResultSendable)
        XCTAssertFalse(contract.futureResultHashable)
        XCTAssertFalse(contract.futureResultIdentifiable)
        XCTAssertFalse(
            contract.futureResultCustomStringConvertible
        )
        XCTAssertFalse(contract.futureResultInitializerPublic)
        XCTAssertFalse(contract.futureResultRetainsEvidence)
        XCTAssertFalse(contract.futureResultRetainsProjectionContext)
        XCTAssertTrue(
            contract.futureResultRetainsExactProjectedArtifactBytes
        )
        XCTAssertFalse(
            contract.futureResultAddsPathDescriptorOrIOHandle
        )
        XCTAssertFalse(
            contract.futureResultAddsDigestAsEvidenceIdentity
        )
        XCTAssertFalse(
            contract.futureResultAddsVerdictPassOrAuthorityAccessor
        )
        XCTAssertFalse(
            contract.futureResultDescribedAsPublicationReady
        )
        XCTAssertFalse(
            contract.futureResultEqualityMayEstablishIdentity
        )
        XCTAssertFalse(contract.futureResultHashMayEstablishIdentity)

        XCTAssertTrue(contract.futureResultLinkageValidationRequired)
        XCTAssertTrue(contract.linkageRequiresSameInvocationRole)
        XCTAssertTrue(
            contract.linkageRequiresExactCanonicalTypedKeyOrder
        )
        XCTAssertEqual(contract.linkageRequiresExactTypedKeyCount, 22)
        XCTAssertTrue(
            contract.linkageRequiresPerKeyByteCountEquality
        )
        XCTAssertTrue(contract.linkageRequiresPerKeySHA256Equality)
        XCTAssertFalse(contract.linkageMayUsePositionalJoin)
        XCTAssertFalse(contract.partialResultPermitted)
        XCTAssertFalse(contract.retryPermitted)
        XCTAssertFalse(contract.fallbackCatchPermitted)
        XCTAssertFalse(contract.tryOptionalPermitted)
        XCTAssertFalse(contract.errorToAbstainConversionPermitted)
        XCTAssertTrue(contract.exactTypedFailurePropagationRequired)
    }

    func testV20DesignOnlyStateAndPreservedV19WorkerPrefixRemainExact()
        throws
    {
        let contract = Contract.frozenV1

        for materializedOrRuntimeClaim in [
            contract.futureCompositionTargetMaterialized,
            contract.futureCompositionSourceMaterialized,
            contract.futureCompositionResultTypeMaterialized,
            contract.futureWorkerSourceAppended,
            contract.packageGraphChanged,
            contract.workerSourceChanged,
            contract.workerDependenciesChanged,
            contract.futureCompositionInvoked,
            contract.runtimeInputAccepted,
            contract.runtimeOutputProduced,
            contract.fixtureMaterialized,
            contract.exporterInvoked,
            contract.projectorInvoked,
            contract.decoderInvoked,
            contract.workerRequestHandlingEnabled,
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.historicalGateExecuted,
            contract.modelExecuted,
            contract.mutationSweepExecuted,
            contract.triadicAuditExecuted,
            contract.szAuditExecuted,
            contract.evaluationExecutedOrInspected,
            contract.targetProvenanceEstablished,
            contract.evaluationLeakageDetectionEstablished,
            contract.artifactFilesystemReadPerformed,
            contract.artifactWritePerformed,
            contract.descriptorCapturePerformed,
            contract.processNetworkOrEnvironmentAccessed,
            contract.replayTransportIntegrated,
            contract.loggingOrDescriptionPerformed,
            contract.callbackOrSideEffectHookPermitted,
            contract.evidencePublished,
            contract.durablePublicationObserved,
            contract.memoryOrThroughputMeasured,
            contract.zeroCopyGuaranteeEstablished,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(materializedOrRuntimeClaim)
        }
        XCTAssertTrue(contract.workerMainUnavailable)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")

        XCTAssertEqual(
            contract.futureSourceRelativePath,
            Self.v19WorkerRelativePath
        )
        XCTAssertEqual(
            contract.preservedV19SourcePrefixByteCount,
            Self.v19WorkerByteCount
        )
        XCTAssertEqual(
            contract.preservedV19SourcePrefixSHA256,
            Self.v19WorkerSHA256
        )
        let liveWorker = try checkedInData(Self.v19WorkerRelativePath)
        XCTAssertGreaterThan(
            UInt64(liveWorker.count),
            Self.v19WorkerByteCount
        )
        let worker = Data(
            liveWorker.prefix(Int(Self.v19WorkerByteCount))
        )
        XCTAssertEqual(UInt64(worker.count), Self.v19WorkerByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: worker),
            Self.v19WorkerSHA256
        )
        let workerSource = try XCTUnwrap(
            String(data: worker, encoding: .utf8)
        )
        XCTAssertTrue(
            workerSource.contains(
                "sourceBoundHistoricalSemanticArtifactDecoderCallEdge"
            )
        )
        XCTAssertFalse(
            workerSource.contains(contract.futureCompositionMethodName)
        )
        XCTAssertFalse(
            workerSource.contains(contract.futureWorkerCallEdgeMethodName)
        )
        XCTAssertFalse(
            workerSource.contains(contract.futureResultSwiftTypeName)
        )
        let continuation = try XCTUnwrap(
            String(
                data: liveWorker.dropFirst(Int(Self.v19WorkerByteCount)),
                encoding: .utf8
            )
        )
        XCTAssertTrue(
            continuation.contains(contract.futureCompositionMethodName)
        )
        XCTAssertTrue(
            continuation.contains(contract.futureWorkerCallEdgeMethodName)
        )
        XCTAssertTrue(
            continuation.contains(contract.futureResultSwiftTypeName)
        )

        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )
        XCTAssertFalse(
            package.contains(contract.futureResultSwiftTypeName)
        )
        XCTAssertFalse(
            package.contains(contract.futureWorkerCallEdgeMethodName)
        )
    }

    func testCanonicalRoundTripAndFrozenHashAreExact()
        throws
    {
        let contract = Contract.frozenV1
        let canonical = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: canonical
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(decoded),
            canonical
        )
        let observed = try contract.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.designContractSHA256)
    }

    func testDecodedMutationMatrixFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        var thirdInputLabels = try XCTUnwrap(
            object["exact_input_labels"] as? [String]
        )
        thirdInputLabels.append("authority")
        var reversedResultFields = try XCTUnwrap(
            object["future_result_exact_field_names"] as? [String]
        )
        reversedResultFields.reverse()

        let mutations: [(String, String, Any)] = [
            (
                "third-input",
                "exact_input_labels",
                thirdInputLabels
            ),
            (
                "optional-input",
                "input_may_be_optional",
                true
            ),
            (
                "evidence-reconstruction",
                "evidence_may_be_reconstructed",
                true
            ),
            (
                "materials-input",
                "exporter_materials_input_permitted",
                true
            ),
            (
                "context-observed-true",
                "observed_true_context_state_permitted",
                true
            ),
            (
                "context-observed-false",
                "observed_false_context_state_permitted",
                true
            ),
            (
                "context-default",
                "context_may_be_defaulted",
                true
            ),
            (
                "role-inference",
                "role_may_be_inferred_from_evidence",
                true
            ),
            (
                "equality-identity",
                "evidence_equatable_may_establish_canonical_identity",
                true
            ),
            (
                "reflection-identity",
                "evidence_reflection_may_establish_identity",
                true
            ),
            (
                "signed-zero-denial",
                "floating_point_signed_zero_trap_acknowledged",
                false
            ),
            (
                "access-widening",
                "future_source_may_widen_private_access",
                true
            ),
            (
                "zipper-duplication",
                "future_source_may_duplicate_v19_zipper",
                true
            ),
            (
                "direct-decoder-reimplementation",
                "direct_v18_decoder_reimplementation_permitted",
                true
            ),
            (
                "result-field-order",
                "future_result_exact_field_names",
                reversedResultFields
            ),
            (
                "result-codable",
                "future_result_non_codable",
                false
            ),
            (
                "result-equatable",
                "future_result_equatable",
                true
            ),
            (
                "result-hashable",
                "future_result_hashable",
                true
            ),
            (
                "result-not-sendable",
                "future_result_sendable",
                false
            ),
            (
                "role-link-loss",
                "linkage_requires_same_invocation_role",
                false
            ),
            (
                "key-count-drift",
                "linkage_requires_exact_typed_key_count",
                21
            ),
            (
                "sha-link-loss",
                "linkage_requires_per_key_sha256_equality",
                false
            ),
            (
                "positional-join",
                "linkage_may_use_positional_join",
                true
            ),
            (
                "source-materialization",
                "future_composition_source_materialized",
                true
            ),
            (
                "worker-append",
                "future_worker_source_appended",
                true
            ),
            (
                "package-change",
                "package_graph_changed",
                true
            ),
            (
                "runtime-output",
                "runtime_output_produced",
                true
            ),
            (
                "projector-invocation",
                "projector_invoked",
                true
            ),
            (
                "artifact-write",
                "artifact_write_performed",
                true
            ),
            (
                "publication",
                "evidence_published",
                true
            ),
            (
                "durability",
                "durable_publication_observed",
                true
            ),
            (
                "source-binding-v7",
                "source_binding_v7_issued",
                true
            ),
        ]

        for (label, key, value) in mutations {
            var mutation = object
            mutation[key] = value
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                label
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractError,
                    .invalidFrozenContract,
                    label
                )
            }
        }
    }

    func testUnknownCanonicalFieldAndNextPrerequisiteRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            Self.nextImplementationPrerequisite
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "Prime remains ABSTAIN"
            )
        )

        let canonical = try PrimeCanonicalJSON.encode(contract)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["unknown_future_authority"] = true
        let unknown = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        let plainDecoded = try JSONDecoder().decode(
            Contract.self,
            from: unknown
        )
        XCTAssertNoThrow(try plainDecoded.validate())
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: unknown
            )
        )
    }

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath)
        )
    }

    private func checkedInString(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest

import PrimeCore

final class PrimeNativeDecoderAuthorityTests: XCTestCase {
    func testFrozenPredecessorSourceIsByteExact() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let data = try Data(
            contentsOf: root.appendingPathComponent(
                "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift"))

        XCTAssertEqual(data.count, 18_462)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: data),
            "afe0fe9b18cd835299fc2185508b383b33c36a0be27372ff41beb555e1776eaa")
    }

    func testFrozenPredecessorAuthorityStillValidatesExactly() throws {
        let plan = PrimeNativeDecoderAuthorityPlan.frozenV1

        try plan.validate()
        XCTAssertEqual(
            plan.authoritativeTargetDependencies,
            ["PrimeCore", "MLX", "MLXNN"])
        XCTAssertEqual(
            plan.gqaExtensionStatus,
            "ABSTAIN_requires_explicit_derived_delta")
        XCTAssertTrue(plan.historicalMechanicsReceiptsRemainValid)
        XCTAssertFalse(plan.historicalMechanicsReceiptMutationAuthorized)
        XCTAssertFalse(plan.historicalMechanicsMaySelectFutureDecoder)
        XCTAssertFalse(plan.functionalTrainingAuthorized)
        XCTAssertFalse(plan.productPromotionAuthorized)
    }

    func testDerivedGQAMechanicsAuthorityIsExactAndAdditive() throws {
        let plan = PrimeNativeDecoderDerivedDeltaPlan.frozenV1

        try plan.validate()
        XCTAssertEqual(
            plan.predecessorAuthorityID,
            PrimeNativeDecoderAuthorityPlan.frozenV1.authorityID)
        XCTAssertTrue(plan.predecessorRemainsFrozen)
        XCTAssertTrue(plan.predecessorGQAAbstentionPreserved)
        XCTAssertEqual(
            plan.authoritativeTargetDependencies,
            ["PrimeCore", "MLX", "MLXNN"])
        XCTAssertEqual(
            plan.materializedSourcePath,
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift")
        XCTAssertEqual(
            plan.materializedSourceGitBlob,
            "55407cba9dbcc4e915b0994aed16f02c1da95e16")
        XCTAssertEqual(plan.materializedSourceByteCount, 38_524)
        XCTAssertEqual(
            plan.materializedSourceSHA256,
            "7e3e9c676225e7d600c5580cb3ae73a3d15fdeff12d0933e175b41923c370162")
        XCTAssertEqual(
            plan.donorCacheRevision,
            "8eb36a77891154ce13cca96d8def9cf59c76bd5b")
        XCTAssertEqual(
            plan.donorSourceSHA256,
            "9f834930d38182b665b62dbeb2f6212eca0e45189a084f1109c97c57b4a691f3")
        XCTAssertFalse(plan.donorRevisionPublishedToOriginObserved)
        XCTAssertFalse(plan.ergenticsLLMRuntimeDependencyAuthorized)
        XCTAssertTrue(plan.sourcePortMaterializationAuthorized)
        XCTAssertTrue(plan.sourceCompilationAuthorized)
        XCTAssertTrue(plan.boundedSyntheticMechanicsTestsAuthorized)
    }

    func testDerivedAuthorityDoesNotPromoteMechanicsIntoRuntimeAuthority() {
        let plan = PrimeNativeDecoderDerivedDeltaPlan.frozenV1

        XCTAssertFalse(plan.modelInitializationObserved)
        XCTAssertFalse(plan.forwardExecutionObserved)
        XCTAssertFalse(plan.metalExecutionObserved)
        XCTAssertFalse(plan.cacheParityObserved)
        XCTAssertFalse(plan.gradientExecutionObserved)
        XCTAssertFalse(plan.runtimeDependencyClosureEstablished)
        XCTAssertFalse(plan.runtimeInitializationEstablished)
        XCTAssertFalse(plan.checkpointContractEstablished)
        XCTAssertFalse(plan.checkpointLoadAuthorized)
        XCTAssertFalse(plan.functionalTrainingAuthorized)
        XCTAssertFalse(plan.longTrainingAuthorized)
        XCTAssertFalse(plan.candidateAdmissionGranted)
        XCTAssertFalse(plan.trialAuthorized)
        XCTAssertFalse(plan.canaryReplacementAuthorized)
        XCTAssertFalse(plan.quantizationAuthorized)
        XCTAssertFalse(plan.productUseAuthorized)
        XCTAssertFalse(plan.publicationAuthorized)
        XCTAssertTrue(plan.status.hasPrefix("ABSTAIN_"))
    }

    func testDerivedAuthorityRejectsEveryBooleanAuthorityMutation() throws {
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: JSONEncoder().encode(
                    PrimeNativeDecoderDerivedDeltaPlan.frozenV1)
            ) as? [String: Any]
        )
        let mutations: [(String, Bool)] = [
            ("predecessorRemainsFrozen", false),
            ("predecessorGQAAbstentionPreserved", false),
            ("donorRevisionPublishedToOriginObserved", true),
            ("ergenticsLLMRuntimeDependencyAuthorized", true),
            ("sourcePortMaterializationAuthorized", false),
            ("sourceCompilationAuthorized", false),
            ("boundedSyntheticMechanicsTestsAuthorized", false),
            ("modelInitializationObserved", true),
            ("forwardExecutionObserved", true),
            ("metalExecutionObserved", true),
            ("cacheParityObserved", true),
            ("gradientExecutionObserved", true),
            ("runtimeDependencyClosureEstablished", true),
            ("runtimeInitializationEstablished", true),
            ("checkpointContractEstablished", true),
            ("checkpointLoadAuthorized", true),
            ("functionalTrainingAuthorized", true),
            ("longTrainingAuthorized", true),
            ("candidateAdmissionGranted", true),
            ("trialAuthorized", true),
            ("canaryReplacementAuthorized", true),
            ("quantizationAuthorized", true),
            ("productUseAuthorized", true),
            ("publicationAuthorized", true),
        ]

        for (key, value) in mutations {
            var mutatedObject = object
            mutatedObject[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderDerivedDeltaPlan.self,
                from: JSONSerialization.data(
                    withJSONObject: mutatedObject,
                    options: [.sortedKeys]
                )
            )

            XCTAssertThrowsError(
                try mutated.validate(),
                "mutation was accepted: \(key)"
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderDerivedDeltaError,
                    .contractDrift,
                    "unexpected error for mutation: \(key)")
            }
        }
    }

    func testCheckpointAuthorityIsAppendOnlyAndMechanicsScoped() throws {
        let plan = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let checkpointSource = try Data(
            contentsOf: root.appendingPathComponent(
                plan.checkpointSourcePath))

        try plan.validate()
        XCTAssertEqual(
            plan.predecessorAuthorityID,
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1.authorityID)
        XCTAssertTrue(plan.predecessorRemainsFrozen)
        XCTAssertEqual(
            plan.authoritativeTargetDependencies,
            ["PrimeCore", "PrimeNativeDecoder", "MLX", "MLXNN"])
        XCTAssertEqual(
            plan.checkpointSourcePath,
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift")
        XCTAssertEqual(
            plan.checkpointSourceGitBlob,
            "24de078fb6424123b8e6974588b4cc514219c026")
        XCTAssertEqual(plan.checkpointSourceByteCount, 39_956)
        XCTAssertEqual(checkpointSource.count, 39_956)
        XCTAssertEqual(
            plan.checkpointSourceSHA256,
            "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b")
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: checkpointSource),
            plan.checkpointSourceSHA256)
        XCTAssertTrue(plan.compatibilityIdentitySchemaEstablished)
        XCTAssertTrue(plan.analyticParameterCatalogEstablished)
        XCTAssertTrue(plan.exactLogicalTensorHashContractEstablished)
        XCTAssertTrue(plan.borrowedDescriptorIOMechanicsImplemented)
        XCTAssertTrue(plan.freshDecoderPreflightPolicyEstablished)
        XCTAssertTrue(plan.boundedSyntheticRoundTripAuthorized)
        XCTAssertEqual(plan.logicalTensorHashAlgorithm, "sha256")
        XCTAssertEqual(
            plan.logicalTensorByteEncoding,
            "contiguous_row_major_little_endian_float32")
        XCTAssertTrue(plan.status.hasPrefix("ABSTAIN_"))
    }

    func testCheckpointAuthorityKeepsRuntimeAndDownstreamCeilingsFalse() {
        let plan = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1

        XCTAssertFalse(plan.native300MModelAllocationAuthorized)
        XCTAssertFalse(plan.native300MCheckpointWriteAuthorized)
        XCTAssertFalse(plan.native300MCheckpointLoadAuthorized)
        XCTAssertFalse(plan.liveSyntheticRoundTripObserved)
        XCTAssertFalse(plan.metalDeviceObserved)
        XCTAssertFalse(plan.defaultMetallibObserved)
        XCTAssertFalse(plan.forwardExecutionObserved)
        XCTAssertFalse(plan.runtimeDependencyClosureEstablished)
        XCTAssertFalse(plan.runtimeInitializationEstablished)
        XCTAssertFalse(plan.tokenizerFunctionalCompatibilityEstablished)
        XCTAssertFalse(plan.acceptedCheckpointArtifactAvailable)
        XCTAssertFalse(plan.checkpointArtifactProvenanceEstablished)
        XCTAssertFalse(plan.checkpointContainerHashBound)
        XCTAssertFalse(plan.atomicCheckpointReplacementEstablished)
        XCTAssertFalse(plan.checkpointFsyncDurabilityEstablished)
        XCTAssertFalse(plan.failedCheckpointWriteRecoveryEstablished)
        XCTAssertFalse(plan.optimizerStateIncluded)
        XCTAssertFalse(plan.rngStateIncluded)
        XCTAssertFalse(plan.dataCursorIncluded)
        XCTAssertFalse(plan.kvCacheStateIncluded)
        XCTAssertFalse(plan.trainingResumeEstablished)
        XCTAssertFalse(plan.functionalTrainingAuthorized)
        XCTAssertFalse(plan.candidateAdmissionGranted)
        XCTAssertFalse(plan.trialAuthorized)
        XCTAssertFalse(plan.canaryReplacementAuthorized)
        XCTAssertFalse(plan.quantizationAuthorized)
        XCTAssertFalse(plan.productUseAuthorized)
        XCTAssertFalse(plan.publicationAuthorized)
    }

    func testCheckpointAuthorityRejectsEveryBooleanMutation() throws {
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: JSONEncoder().encode(
                    PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1)
            ) as? [String: Any]
        )
        let mutations: [(String, Bool)] = [
            ("predecessorRemainsFrozen", false),
            ("compatibilityIdentitySchemaEstablished", false),
            ("analyticParameterCatalogEstablished", false),
            ("exactLogicalTensorHashContractEstablished", false),
            ("borrowedDescriptorIOMechanicsImplemented", false),
            ("freshDecoderPreflightPolicyEstablished", false),
            ("boundedSyntheticRoundTripAuthorized", false),
            ("native300MModelAllocationAuthorized", true),
            ("native300MCheckpointWriteAuthorized", true),
            ("native300MCheckpointLoadAuthorized", true),
            ("liveSyntheticRoundTripObserved", true),
            ("metalDeviceObserved", true),
            ("defaultMetallibObserved", true),
            ("forwardExecutionObserved", true),
            ("runtimeDependencyClosureEstablished", true),
            ("runtimeInitializationEstablished", true),
            ("tokenizerFunctionalCompatibilityEstablished", true),
            ("acceptedCheckpointArtifactAvailable", true),
            ("checkpointArtifactProvenanceEstablished", true),
            ("checkpointContainerHashBound", true),
            ("atomicCheckpointReplacementEstablished", true),
            ("checkpointFsyncDurabilityEstablished", true),
            ("failedCheckpointWriteRecoveryEstablished", true),
            ("optimizerStateIncluded", true),
            ("rngStateIncluded", true),
            ("dataCursorIncluded", true),
            ("kvCacheStateIncluded", true),
            ("trainingResumeEstablished", true),
            ("functionalTrainingAuthorized", true),
            ("candidateAdmissionGranted", true),
            ("trialAuthorized", true),
            ("canaryReplacementAuthorized", true),
            ("quantizationAuthorized", true),
            ("productUseAuthorized", true),
            ("publicationAuthorized", true),
        ]

        for (key, value) in mutations {
            var mutatedObject = object
            mutatedObject[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointAuthorityPlan.self,
                from: JSONSerialization.data(
                    withJSONObject: mutatedObject,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "mutation was accepted: \(key)"
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderCheckpointAuthorityError,
                    .contractDrift,
                    "unexpected error for mutation: \(key)")
            }
        }
    }
}

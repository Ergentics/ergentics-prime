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
}

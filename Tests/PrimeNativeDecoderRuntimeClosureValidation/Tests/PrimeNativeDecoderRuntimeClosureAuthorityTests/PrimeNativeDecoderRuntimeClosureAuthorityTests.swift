// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore
import PrimeNativeDecoderRuntime

final class PrimeNativeDecoderRuntimeClosureAuthorityTests:
    XCTestCase
{
    func testMaintainedRuntimeComputeAuthorityIsExactAndBounded()
        throws
    {
        let plan =
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1
        try plan.validateExactV1()

        XCTAssertEqual(plan.runtimeProduct, "PrimeNativeDecoderRuntime")
        XCTAssertEqual(plan.runtimeTarget, plan.runtimeProduct)
        XCTAssertEqual(
            plan.runtimeValidationProbeTarget,
            "PrimeNativeDecoderRuntimeClosureProbe"
        )
        XCTAssertEqual(
            plan.runtimeValidationTestTarget,
            "PrimeNativeDecoderRuntimeClosureAuthorityTests"
        )
        XCTAssertEqual(plan.requiredMLXGPUIndex, 0)
        XCTAssertEqual(plan.initializationProbeShape, [2, 2])
        XCTAssertTrue(plan.admittedRuntimeComputePolicyEstablished)
        XCTAssertTrue(plan.runtimeDependencyClosureAuthorized)
        XCTAssertTrue(plan.sourcePinnedMetallibVerificationAuthorized)
        XCTAssertTrue(plan.runtimeMetalDeviceClosureAuthorized)
        XCTAssertTrue(plan.boundedMLXRuntimeInitializationAuthorized)
        XCTAssertFalse(plan.runtimeDependencyClosureEstablished)
        XCTAssertFalse(plan.runtimeLoadedMetallibIdentityEstablished)
        XCTAssertFalse(
            plan.sourcePinnedExclusiveCandidateInferenceEstablished
        )
        XCTAssertFalse(plan.loadedMetallibIdentityIndependentlyObserved)
        XCTAssertFalse(plan.runtimeMetalDeviceIdentityEstablished)
        XCTAssertFalse(plan.boundedMLXRuntimeInitializationEstablished)
        XCTAssertFalse(plan.tf32StaticValueDirectlyObserved)
        XCTAssertFalse(plan.tf32DifferentialObserved)
        XCTAssertFalse(plan.naxTF32ConsumerPathObserved)
        XCTAssertFalse(plan.decoderModelInitializationEstablished)
        XCTAssertFalse(plan.decoderForwardObserved)
        XCTAssertFalse(plan.native300MModelAllocationAuthorized)
        XCTAssertFalse(plan.checkpointContainerIOImplemented)
        XCTAssertFalse(plan.trainingExecutionObserved)
        XCTAssertFalse(plan.productUseAuthorized)

        let runtimePlan = try
            PrimeNativeDecoderMaintainedRuntimePlanV1
                .native300MByte512()
        try runtimePlan.validate()
        XCTAssertEqual(runtimePlan.authorityID, plan.authorityID)
        XCTAssertEqual(
            runtimePlan.compatibilityIdentitySHA256,
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843"
        )
        XCTAssertEqual(runtimePlan.configuration.vocabularySize, 512)
        XCTAssertEqual(runtimePlan.initializationProbeShape, [2, 2])
        XCTAssertFalse(runtimePlan.decoderModelAllocated)
        XCTAssertFalse(runtimePlan.decoderForwardObserved)
        XCTAssertFalse(runtimePlan.checkpointIOObserved)
        XCTAssertFalse(runtimePlan.trainingExecutionObserved)

        let authorityData = try JSONEncoder().encode(plan)
        let authorityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: authorityData)
                as? [String: Any]
        )
        let topLevelBooleanKeys: [String] = authorityObject.compactMap {
            element in
            let (key, value) = element
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID()
            else {
                return nil
            }
            return key
        }.sorted()
        let policyBooleanKeys: [String] = try XCTUnwrap(
            authorityObject["maintainedComputeEnvironmentPolicy"]
                as? [String: Any]
        ).compactMap { element in
            let (key, value) = element
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID()
            else {
                return nil
            }
            return key
        }.sorted()
        XCTAssertEqual(topLevelBooleanKeys.count, 83)
        XCTAssertEqual(policyBooleanKeys, ["predecessorRemainsFrozen"])
        XCTAssertEqual(
            topLevelBooleanKeys.count + policyBooleanKeys.count,
            84
        )
        for key in topLevelBooleanKeys {
            var object = authorityObject
            object[key] = !(try XCTUnwrap(object[key] as? Bool))
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority Boolean mutation was accepted: \(key)"
            )
        }
        for key in policyBooleanKeys {
            var object = authorityObject
            var policy = try XCTUnwrap(
                object["maintainedComputeEnvironmentPolicy"]
                    as? [String: Any]
            )
            policy[key] = !(try XCTUnwrap(policy[key] as? Bool))
            object["maintainedComputeEnvironmentPolicy"] = policy
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "policy Boolean mutation was accepted: \(key)"
            )
        }

        let criticalAuthorityMutations: [(String, Any)] = [
            ("schemaVersion", 2),
            ("authorityID", plan.authorityID + "x"),
            ("predecessorAuthorityID", plan.predecessorAuthorityID + "x"),
            ("baseRevision", String(repeating: "1", count: 40)),
            ("baseTree", String(repeating: "2", count: 40)),
            (
                "baseEmbeddedSourceIdentitySHA256",
                String(repeating: "3", count: 64)
            ),
            (
                "predecessorSourceSHA256",
                String(repeating: "4", count: 64)
            ),
            (
                "compatibilityIdentityV2SourceSHA256",
                String(repeating: "5", count: 64)
            ),
            (
                "repairedDecoderSourceSHA256",
                String(repeating: "6", count: 64)
            ),
            (
                "baseRootPackageManifestSHA256",
                String(repeating: "7", count: 64)
            ),
            (
                "frozenEnvironmentPolicySourceSHA256",
                String(repeating: "8", count: 64)
            ),
            ("exactMLXRevision", String(repeating: "9", count: 40)),
            (
                "mlxPackageSourceSHA256",
                String(repeating: "a", count: 64)
            ),
            (
                "mlxMetalLoaderSourceSHA256",
                String(repeating: "b", count: 64)
            ),
            (
                "mlxTF32EnvironmentSourceSHA256",
                String(repeating: "c", count: 64)
            ),
            (
                "mlxMatmulSourceSHA256",
                String(repeating: "d", count: 64)
            ),
            (
                "exactLoaderCandidateOrder",
                ["current_working_directory/default.metallib"]
            ),
            ("runtimeProduct", "UnexpectedRuntime"),
            ("runtimeSourcePath", "Sources/Unexpected.swift"),
            ("runtimeClosureLauncherPath", ".github/scripts/skip.sh"),
            ("requiredMetalDeviceCount", 2),
            ("requiredMLXGPUIndex", 1),
            ("initializationProbeShape", [1]),
            (
                "initializationProbeExpectedFloat32BitPatterns",
                [Float(0).bitPattern]
            ),
            ("status", "ACCEPT"),
            ("orderedNextActions", ["skip"]),
        ]
        for (key, value) in criticalAuthorityMutations {
            var object = authorityObject
            XCTAssertNotNil(object[key])
            object[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority scalar mutation was accepted: \(key)"
            )
        }

        let exactSourceIdentityKeys = [
            "successorRootPackageManifestSource",
            "successorRootPackageResolvedSource",
            "runtimeSource",
            "runtimeValidationPackageManifestSource",
            "runtimeValidationPackageResolvedSource",
            "runtimeValidationProbeSource",
            "runtimeValidationTestSource",
            "runtimeClosureLauncherSource",
        ]
        for key in exactSourceIdentityKeys {
            var object = authorityObject
            var identity = try XCTUnwrap(
                object[key] as? [String: Any]
            )
            identity["sha256"] = String(repeating: "0", count: 64)
            object[key] = identity
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "source-identity SHA-256 mutation was accepted: \(key)"
            )
        }
        let sourceIdentityStructuralMutations: [
            (identityKey: String, field: String, value: Any)
        ] = [
            (
                "successorRootPackageManifestSource",
                "path",
                "Unexpected.swift"
            ),
            (
                "successorRootPackageResolvedSource",
                "gitMode",
                "100755"
            ),
            (
                "runtimeSource",
                "gitBlob",
                String(repeating: "0", count: 40)
            ),
            (
                "runtimeValidationPackageManifestSource",
                "byteCount",
                1
            ),
        ]
        for mutation in sourceIdentityStructuralMutations {
            var object = authorityObject
            var identity = try XCTUnwrap(
                object[mutation.identityKey] as? [String: Any]
            )
            identity[mutation.field] = mutation.value
            object[mutation.identityKey] = identity
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "source-identity structural mutation was accepted: "
                    + "\(mutation.identityKey).\(mutation.field)"
            )
        }

        var policyMutation = authorityObject
        var policyObject = try XCTUnwrap(
            policyMutation["maintainedComputeEnvironmentPolicy"]
                as? [String: Any]
        )
        policyObject["requiredEnvironmentValue"] = "1"
        policyMutation["maintainedComputeEnvironmentPolicy"] =
            policyObject
        let mutatedPolicy = try JSONDecoder().decode(
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1.self,
            from: JSONSerialization.data(
                withJSONObject: policyMutation,
                options: [.sortedKeys]
            )
        )
        XCTAssertThrowsError(try mutatedPolicy.validateExactV1())

        let inherited = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateInherited(
                    environment: [
                        "PATH": "/usr/bin:/bin",
                    ]
                )
        XCTAssertEqual(inherited, plan.maintainedComputeEnvironmentPolicy)
        let launched = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(
                    environment: [
                        "MLX_ENABLE_TF32": "0",
                        "PATH": "/usr/bin:/bin",
                    ]
                )
        XCTAssertEqual(launched, plan.maintainedComputeEnvironmentPolicy)

        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateInherited(
                    environment: [
                        "MLX_ENABLE_TF32": "0",
                    ]
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(
                    environment: [
                        "MLX_ENABLE_TF32": "1",
                    ]
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(
                    environment: [
                        "MLX_ENABLE_TF32": "0",
                        "MLX_METAL_PATH": "/tmp/untrusted.metallib",
                    ]
                )
        )

        XCTAssertThrowsError(
            try PrimeMLXRuntimeEnvironmentPolicy.validate(
                environment: [
                    "MLX_ENABLE_TF32": "0",
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeMLXRuntimeEnvironmentPolicyError,
                .forbiddenEnvironmentKey("MLX_ENABLE_TF32")
            )
        }

        let expectation = try
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
                byteCount: 1,
                sha256: String(repeating: "a", count: 64)
            )
        try expectation.validate()
        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
                byteCount: 0,
                sha256: String(repeating: "a", count: 64)
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
                byteCount:
                    PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                        .maximumByteCount + 1,
                sha256: String(repeating: "a", count: 64)
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
                byteCount: 1,
                sha256: String(repeating: "A", count: 64)
            )
        )
    }
}

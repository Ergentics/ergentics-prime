// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import PrimeCore
import XCTest

final class PrimeNativeDecoderTokenizerCompatibilityAuthorityTests:
    XCTestCase
{
    func testTokenizerModelFunctionalCompatibilityAuthorityIsExactAndBounded()
        throws
    {
        let plan =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .frozenV1
        try plan.validateExactV1()
        XCTAssertEqual(plan.sourceText, "A")
        XCTAssertEqual(plan.sequenceTokenIDs, [1, 321, 70])
        XCTAssertEqual(plan.configuration.vocabularySize, 512)
        XCTAssertEqual(plan.configuration.modelWidth, 1_024)
        XCTAssertEqual(plan.configuration.layerCount, 24)
        XCTAssertEqual(plan.configuration.queryHeadCount, 16)
        XCTAssertEqual(plan.configuration.keyValueHeadCount, 4)
        XCTAssertEqual(plan.configuration.headWidth, 64)
        XCTAssertEqual(plan.configuration.intermediateWidth, 2_816)
        XCTAssertEqual(plan.configuration.maximumSequenceLength, 2_048)
        XCTAssertEqual(plan.initializationSeed, 42)
        XCTAssertEqual(plan.parameterDescriptorCount, 218)
        XCTAssertEqual(plan.totalParameterCount, 271_107_072)
        XCTAssertEqual(plan.totalParameterByteCount, 1_084_428_288)
        XCTAssertEqual(plan.requiredModelConstructionCount, 1)
        XCTAssertEqual(plan.requiredForwardInvocationCount, 1)
        XCTAssertEqual(
            plan.requiredForwardMode,
            "full_prefix_no_cache_position_zero")
        XCTAssertEqual(plan.requiredMemoryCacheLimit, 0)
        XCTAssertEqual(plan.requiredMemoryCacheClearCount, 4)
        XCTAssertEqual(
            plan.requiredParameterMaterializationEvaluationCount,
            1)
        XCTAssertEqual(plan.requiredForwardOutputEvaluationCount, 1)
        XCTAssertEqual(plan.requiredLogitsReadbackCount, 1)
        XCTAssertEqual(plan.expectedOutputShape, [1, 3, 512])
        XCTAssertEqual(plan.expectedOutputDType, "float32")
        XCTAssertEqual(plan.expectedOutputElementCount, 1_536)
        XCTAssertEqual(plan.expectedOutputByteCount, 6_144)
        XCTAssertTrue(plan.tokenizerToModelSequenceMechanicsAuthorized)
        XCTAssertTrue(plan.native300MModelAllocationAuthorized)
        XCTAssertTrue(plan.actualParameterCatalogProjectionAuthorized)
        XCTAssertTrue(plan.singleFullPrefixForwardAuthorized)
        XCTAssertFalse(plan.tokenizerFunctionalCompatibilityEstablished)
        XCTAssertFalse(plan.modelFunctionalCompatibilityEstablished)
        XCTAssertFalse(plan.native300MModelAllocationObserved)
        XCTAssertFalse(plan.decoderForwardObserved)
        XCTAssertFalse(plan.actualParameterCatalogProjectionObserved)
        XCTAssertFalse(plan.decoderKVCacheUseAuthorized)
        XCTAssertFalse(plan.backwardAuthorized)
        XCTAssertFalse(plan.checkpointIOAuthorized)
        XCTAssertFalse(plan.generationAuthorized)
        XCTAssertFalse(plan.modelQualityEstablished)
        XCTAssertFalse(plan.trainingResumeEstablished)
        XCTAssertFalse(plan.trainingExecutionObserved)
        XCTAssertFalse(plan.candidateAdmissionGranted)
        XCTAssertFalse(plan.trialAuthorized)
        XCTAssertFalse(plan.canaryReplacementAuthorized)
        XCTAssertFalse(plan.quantizationAuthorized)
        XCTAssertFalse(plan.productUseAuthorized)
        XCTAssertFalse(plan.publicationAuthorized)

        let canonical = try PrimeCanonicalJSON.encode(plan)
        let replay = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .self,
            from: canonical)
        XCTAssertEqual(replay, plan)
        try replay.validateExactV1()

        enum PathComponent: CustomStringConvertible {
            case key(String)
            case index(Int)

            var description: String {
                switch self {
                case .key(let value): value
                case .index(let value): "[\(value)]"
                }
            }
        }

        func leafPaths(
            in value: Any,
            prefix: [PathComponent] = []
        ) -> [[PathComponent]] {
            if let object = value as? [String: Any] {
                return object.keys.sorted().flatMap { key in
                    leafPaths(
                        in: object[key] as Any,
                        prefix: prefix + [.key(key)])
                }
            }
            if let array = value as? [Any] {
                return array.indices.flatMap { index in
                    leafPaths(
                        in: array[index],
                        prefix: prefix + [.index(index)])
                }
            }
            return [prefix]
        }

        func replacement(for value: Any) throws -> Any {
            if let number = value as? NSNumber {
                if CFGetTypeID(number) == CFBooleanGetTypeID() {
                    return !number.boolValue
                }
                return number.int64Value + 1
            }
            if let string = value as? String {
                return string + "x"
            }
            throw NSError(
                domain: "PrimeNativeDecoderTokenizerCompatibilityAuthorityTests",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "unsupported authority JSON leaf: \(type(of: value))",
                ])
        }

        func replacing(
            _ value: Any,
            at path: ArraySlice<PathComponent>
        ) throws -> Any {
            guard let component = path.first else {
                return try replacement(for: value)
            }
            switch component {
            case .key(let key):
                var object = try XCTUnwrap(value as? [String: Any])
                object[key] = try replacing(
                    try XCTUnwrap(object[key]),
                    at: path.dropFirst())
                return object
            case .index(let index):
                var array = try XCTUnwrap(value as? [Any])
                array[index] = try replacing(
                    array[index],
                    at: path.dropFirst())
                return array
            }
        }

        func value(
            in root: Any,
            at path: ArraySlice<PathComponent>
        ) throws -> Any {
            guard let component = path.first else {
                return root
            }
            switch component {
            case .key(let key):
                let object = try XCTUnwrap(root as? [String: Any])
                return try value(
                    in: try XCTUnwrap(object[key]),
                    at: path.dropFirst())
            case .index(let index):
                let array = try XCTUnwrap(root as? [Any])
                return try value(
                    in: array[index],
                    at: path.dropFirst())
            }
        }

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        let paths = leafPaths(in: object)
        XCTAssertGreaterThan(paths.count, 80)
        for path in paths {
            let mutatedObject = try XCTUnwrap(
                try replacing(object, at: path[...])
                    as? [String: Any])
            let mutatedData = try JSONSerialization.data(
                withJSONObject: mutatedObject,
                options: [.sortedKeys, .withoutEscapingSlashes])
            do {
                let mutated = try JSONDecoder().decode(
                    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                        .self,
                    from: mutatedData)
                XCTAssertThrowsError(
                    try mutated.validateExactV1(),
                    "authority mutation was accepted: "
                        + path.map(\.description).joined(separator: "."))
            } catch is DecodingError {
                // A decoding rejection is also a fail-closed mutation result.
            }
        }

        let evidence = try
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1(
                executedRevision: String(repeating: "1", count: 40),
                executedTree: String(repeating: "2", count: 40),
                executedEmbeddedSourceIdentitySHA256:
                    String(repeating: "3", count: 64),
                environmentPolicy: plan.environmentPolicy,
                launchedEnvironmentValidatedBeforeFrameworkAccess: true,
                launchedEnvironmentRevalidatedAfterEvaluation: true,
                releaseInstrumentationEvidenceAbsent: true,
                coreGraphicsBootstrapObserved: true,
                enumeratedMetalDeviceCount: 1,
                defaultMetalDeviceMatchedIndexZero: true,
                mlxDeviceType: "gpu",
                mlxDeviceIndex: 0,
                metalLeaseHeldBeforeAndAfterEvaluation: true,
                tokenizerManifestSHA256: plan.tokenizerManifestSHA256,
                tokenizerReplayProbeSHA256:
                    plan.tokenizerReplayProbeSHA256,
                tokenizerManifestAndReplayValidated: true,
                sourceText: plan.sourceText,
                sourceUTF8SHA256: plan.sourceUTF8SHA256,
                canonicalText: plan.canonicalText,
                canonicalUTF8SHA256: plan.canonicalUTF8SHA256,
                primarySequenceTokenIDs: plan.sequenceTokenIDs,
                independentSequenceTokenIDs: plan.sequenceTokenIDs,
                sequenceTokenIDsSHA256: plan.sequenceTokenIDsSHA256,
                primaryAndIndependentTokenPathsAgree: true,
                decodedText: plan.canonicalText,
                decodeRoundTripEstablished: true,
                compatibilityIdentityCanonicalByteCount:
                    plan.compatibilityIdentityCanonicalByteCount,
                compatibilityIdentitySHA256:
                    plan.compatibilityIdentitySHA256,
                compatibilityIdentityValidated: true,
                configuration: plan.configuration,
                initializationSeed: plan.initializationSeed,
                modelConstructionCount: plan.requiredModelConstructionCount,
                parameterDescriptorCount: plan.parameterDescriptorCount,
                parameterCatalogCanonicalByteCount:
                    plan.parameterCatalogCanonicalByteCount,
                parameterCatalogSHA256: plan.parameterCatalogSHA256,
                parameterPathSetMatches: true,
                parameterPathOrderMatches: true,
                parameterPathOrder:
                    "global_lexicographic_ascending_utf8_v1",
                parameterShapesMatch: true,
                parameterDTypesMatch: true,
                observedParameterCount: plan.totalParameterCount,
                observedParameterByteCount: plan.totalParameterByteCount,
                forwardInvocationCount:
                    plan.requiredForwardInvocationCount,
                forwardMode: plan.requiredForwardMode,
                decoderKVCacheUsed: false,
                backwardInvoked: false,
                checkpointIOObserved: false,
                generationInvoked: false,
                memoryCacheLimit: plan.requiredMemoryCacheLimit,
                memoryCacheClearCount: plan.requiredMemoryCacheClearCount,
                cacheClearedBeforeParameterMaterialization: true,
                parameterMaterializationEvaluationCount:
                    plan.requiredParameterMaterializationEvaluationCount,
                parameterMaterializationEvaluationAPI:
                    plan.parameterMaterializationEvaluationAPI,
                parametersMaterializedBeforeForward: true,
                cacheClearedAfterParameterMaterialization: true,
                cacheClearedBeforeForwardOutputEvaluation: true,
                forwardOutputEvaluationCount:
                    plan.requiredForwardOutputEvaluationCount,
                forwardOutputEvaluationAPI:
                    plan.forwardOutputEvaluationAPI,
                cacheClearedAfterForwardOutputEvaluation: true,
                logitsReadbackCount: plan.requiredLogitsReadbackCount,
                logitsReadbackAPI: plan.logitsReadbackAPI,
                outputShape: plan.expectedOutputShape,
                outputDType: plan.expectedOutputDType,
                outputElementCount: plan.expectedOutputElementCount,
                outputByteCount: plan.expectedOutputByteCount,
                outputAllFinite: true,
                outputFiniteValueCount: plan.expectedOutputElementCount,
                outputHashEncoding: plan.outputHashEncoding,
                outputFloat32BitPatternSHA256:
                    String(repeating: "4", count: 64),
                metallibArtifactRelativePath:
                    PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                        .artifactRelativePath,
                metallibByteCount: 1,
                metallibSHA256: String(repeating: "5", count: 64),
                existingMetallibCandidateCountBeforeExecution: 1,
                existingMetallibCandidateCountAfterExecution: 1,
                metallibPathAndDescriptorReverified: true,
                metalLibraryValidatedFromExactURL: true)
        try evidence.validate()
        let evidenceCanonical = try PrimeCanonicalJSON.encode(evidence)
        let evidenceReplay = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
                .self,
            from: evidenceCanonical)
        XCTAssertEqual(evidenceReplay, evidence)
        try evidenceReplay.validate()

        let evidenceObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: evidenceCanonical)
                as? [String: Any])
        let evidenceBooleanPaths = try leafPaths(in: evidenceObject)
            .filter { path in
                guard let number = try value(
                    in: evidenceObject,
                    at: path[...]) as? NSNumber else {
                    return false
                }
                return CFGetTypeID(number) == CFBooleanGetTypeID()
            }
        XCTAssertGreaterThan(evidenceBooleanPaths.count, 50)
        for path in evidenceBooleanPaths {
            let mutation = try XCTUnwrap(
                try replacing(evidenceObject, at: path[...])
                    as? [String: Any])
            let mutationData = try JSONSerialization.data(
                withJSONObject: mutation,
                options: [.sortedKeys, .withoutEscapingSlashes])
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
                    .self,
                from: mutationData)
            XCTAssertThrowsError(
                try mutated.validate(),
                "evidence Boolean mutation was accepted: "
                    + path.map(\.description).joined(separator: "."))
        }

        let evidenceScalarMutations: [(String, Any)] = [
            ("executed_revision", "x"),
            ("executed_tree", "x"),
            ("executed_embedded_source_identity_sha256", "x"),
            ("tokenizer_manifest_sha256", String(repeating: "0", count: 64)),
            (
                "tokenizer_replay_probe_sha256",
                String(repeating: "0", count: 64)
            ),
            ("source_text", "B"),
            ("primary_sequence_token_ids", [1, 322, 70]),
            ("compatibility_identity_canonical_byte_count", 1),
            (
                "compatibility_identity_sha256",
                String(repeating: "0", count: 64)
            ),
            ("initialization_seed", 43),
            ("model_construction_count", 2),
            ("parameter_descriptor_count", 217),
            ("parameter_catalog_canonical_byte_count", 1),
            (
                "parameter_catalog_sha256",
                String(repeating: "0", count: 64)
            ),
            ("parameter_path_order", "numeric"),
            ("observed_parameter_count", 1),
            ("forward_invocation_count", 2),
            ("forward_mode", "cached"),
            ("memory_cache_limit", 1),
            ("memory_cache_clear_count", 3),
            ("parameter_materialization_evaluation_api", "eval"),
            ("output_shape", [1, 3, 511]),
            ("output_dtype", "float16"),
            ("output_element_count", 1_535),
            ("output_float32_bit_pattern_sha256", "x"),
            ("existing_metallib_candidate_count_before_execution", 2),
            ("status", "PASS"),
        ]
        for (key, replacement) in evidenceScalarMutations {
            var mutation = evidenceObject
            XCTAssertNotNil(mutation[key])
            mutation[key] = replacement
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys, .withoutEscapingSlashes]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "evidence scalar mutation was accepted: \(key)")
        }

        var evidencePolicyMutation = evidenceObject
        var evidencePolicy = try XCTUnwrap(
            evidencePolicyMutation["environment_policy"]
                as? [String: Any])
        evidencePolicy["policyID"] = "unexpected"
        evidencePolicyMutation["environment_policy"] = evidencePolicy
        let mutatedEvidencePolicy = try JSONDecoder().decode(
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
                .self,
            from: JSONSerialization.data(
                withJSONObject: evidencePolicyMutation,
                options: [.sortedKeys, .withoutEscapingSlashes]))
        XCTAssertThrowsError(try mutatedEvidencePolicy.validate())

        var evidenceConfigurationMutation = evidenceObject
        var evidenceConfiguration = try XCTUnwrap(
            evidenceConfigurationMutation["configuration"]
                as? [String: Any])
        evidenceConfiguration["model_width"] = 1_025
        evidenceConfigurationMutation["configuration"] =
            evidenceConfiguration
        let mutatedEvidenceConfiguration = try JSONDecoder().decode(
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
                .self,
            from: JSONSerialization.data(
                withJSONObject: evidenceConfigurationMutation,
                options: [.sortedKeys, .withoutEscapingSlashes]))
        XCTAssertThrowsError(try mutatedEvidenceConfiguration.validate())

        let inherited = try
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                .validateInherited(
                    environment: ["PATH": "/usr/bin:/bin"])
        XCTAssertEqual(inherited, plan.environmentPolicy)
        let launched = try
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                .validateLaunched(
                    environment: [
                        "MLX_ENABLE_TF32": "0",
                        "PATH": "/usr/bin:/bin",
                    ])
        XCTAssertEqual(launched, plan.environmentPolicy)
        XCTAssertThrowsError(
            try
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                    .validateInherited(
                        environment: ["MLX_ENABLE_TF32": "0"]))
        XCTAssertThrowsError(
            try
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                    .validateLaunched(
                        environment: ["MLX_ENABLE_TF32": "1"]))
        XCTAssertThrowsError(
            try
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                    .validateLaunched(
                        environment: [
                            "MLX_ENABLE_TF32": "0",
                            "MLX_METAL_PATH": "/tmp/untrusted.metallib",
                        ]))
        XCTAssertThrowsError(
            try
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                    .validateLaunched(
                        environment: [
                            "MLX_ENABLE_TF32": "0",
                            "DYLD_LIBRARY_PATH": "/tmp",
                        ]))
    }
}

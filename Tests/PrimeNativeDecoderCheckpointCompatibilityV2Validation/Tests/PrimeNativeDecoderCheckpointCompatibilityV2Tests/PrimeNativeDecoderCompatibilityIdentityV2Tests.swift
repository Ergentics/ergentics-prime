// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore
import PrimeNativeDecoderCheckpoint

final class PrimeNativeDecoderCompatibilityIdentityV2Tests: XCTestCase {
    func testDeclarativeRepairedIdentityIsExactAndFailClosed() throws {
        let authority =
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.frozenV2
        try authority.validateExactV2()

        let v1 = try PrimeNativeDecoderCompatibilityIdentityV1
            .native300MByte512()
        let v2 = try PrimeNativeDecoderCompatibilityIdentityV2
            .native300MByte512()
        try v1.validate()
        try v2.validate()

        let v1Bytes = try PrimeCanonicalJSON.encode(v1)
        let v2Bytes = try PrimeCanonicalJSON.encode(v2)
        let catalogBytes = try PrimeCanonicalJSON.encode(
            v2.parameterCatalog)

        XCTAssertEqual(v1Bytes.count, 30_371)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: v1Bytes),
            "acf439fcc9ddf4871ecc072d0e8372cb5b99e1673effc3afbfce755a0f9eec8d")
        XCTAssertEqual(
            v2Bytes.count,
            authority.publicV2CanonicalIdentityByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: v2Bytes),
            authority.publicV2CanonicalIdentitySHA256)
        XCTAssertEqual(v2.schemaVersion, 2)
        XCTAssertEqual(v2.schemaID, authority.compatibilityIdentitySchema)
        XCTAssertEqual(v2.identityScope, authority.publicCompatibilityProfile)
        XCTAssertEqual(v2.authorityID, authority.authorityID)
        XCTAssertEqual(
            v2.predecessorCompatibilityIdentitySHA256,
            authority.historicalV1CanonicalIdentitySHA256)
        XCTAssertEqual(v2.repairAuthorityID, authority.repairAuthorityID)
        XCTAssertEqual(
            v2.decoderSourceSHA256,
            authority.repairedDecoderSourceSHA256)
        XCTAssertEqual(v2.configuration, v1.configuration)
        XCTAssertEqual(v2.tokenIdentity, v1.tokenIdentity)
        XCTAssertEqual(v2.parameterCatalog, v1.parameterCatalog)
        XCTAssertEqual(v2.parameterCatalog.count, 218)
        XCTAssertEqual(catalogBytes.count, 28_951)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: catalogBytes),
            "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1")
        XCTAssertEqual(v2.totalParameterCount, 271_107_072)
        XCTAssertEqual(v2.totalParameterByteCount, 1_084_428_288)
        XCTAssertEqual(v2.maximumCheckpointByteCount, 1_101_205_504)
        XCTAssertNotEqual(v2.schemaID, v1.schemaID)
        XCTAssertNotEqual(v2.identityScope, v1.identityScope)
        XCTAssertNotEqual(v2.authorityID, v1.authorityID)
        XCTAssertNotEqual(v2.decoderSourceSHA256, v1.decoderSourceSHA256)

        let decodedV2 = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderCompatibilityIdentityV2.self,
            from: v2Bytes)
        XCTAssertEqual(decodedV2, v2)
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCompatibilityIdentityV2.self,
                from: v1Bytes))
        let v2DecodedAsV1 = try JSONDecoder().decode(
            PrimeNativeDecoderCompatibilityIdentityV1.self,
            from: v2Bytes)
        XCTAssertThrowsError(try v2DecodedAsV1.validate())
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCompatibilityIdentityV1.self,
                from: v2Bytes))

        let v2Object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: v2Bytes)
                as? [String: Any])
        let v1Authority = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        let manifestBindings = v2DecodedAsV1.parameterCatalog.map {
            ManifestBindingFixture(
                path: $0.path,
                logicalSHA256: String(repeating: "a", count: 64),
                allValuesFinite: true)
        }
        let manifestBindingBytes = try PrimeCanonicalJSON.encode(
            manifestBindings)
        let manifestBindingObjects = try XCTUnwrap(
            JSONSerialization.jsonObject(with: manifestBindingBytes)
                as? [[String: Any]])
        let manifestObject: [String: Any] = [
            "schema_version": 1,
            "schema_id": v1Authority.checkpointSchema,
            "artifact_kind": v1Authority.checkpointArtifactKind,
            "checkpoint_format": v1Authority.checkpointFormat,
            "state_scope": v1Authority.stateScope,
            "compatibility_identity": v2Object,
            "tensor_bindings": manifestBindingObjects,
            "tensor_bindings_sha256": PrimeSHA256.hexDigest(
                of: manifestBindingBytes),
            "optimizer_state_included": false,
            "rng_state_included": false,
            "data_cursor_included": false,
            "kv_cache_state_included": false,
        ]
        let v1ManifestWithV2Identity = try JSONDecoder().decode(
            PrimeNativeDecoderCheckpointManifestV1.self,
            from: JSONSerialization.data(
                withJSONObject: manifestObject,
                options: [.sortedKeys]))
        XCTAssertThrowsError(try v1ManifestWithV2Identity.validate())

        func assertIdentityMutation(
            _ label: String,
            _ mutation: (inout [String: Any]) throws -> Void
        ) throws {
            var object = v2Object
            try mutation(&object)
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCompatibilityIdentityV2.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "identity mutation was accepted: \(label)")
        }

        for key in [
            "schema_id",
            "identity_scope",
            "authority_id",
            "predecessor_compatibility_identity_sha256",
            "repair_authority_id",
            "architecture_schema",
            "implementation_id",
            "decoder_source_sha256",
            "exact_mlx_revision",
            "parameter_path_schema",
            "required_tensor_dtype",
            "parameter_catalog_sha256",
        ] {
            try assertIdentityMutation(key) { object in
                object[key] = try XCTUnwrap(object[key] as? String) + "x"
            }
        }
        for key in [
            "schema_version",
            "total_parameter_count",
            "total_parameter_byte_count",
            "maximum_checkpoint_byte_count",
        ] {
            try assertIdentityMutation(key) { object in
                let value = try XCTUnwrap(object[key] as? NSNumber)
                object[key] = value.uint64Value + 1
            }
        }
        try assertIdentityMutation("tied_output_projection") { object in
            object["tied_output_projection"] = false
        }
        for key in [
            "vocabulary_size",
            "model_width",
            "layer_count",
            "query_head_count",
            "key_value_head_count",
            "head_width",
            "intermediate_width",
            "maximum_sequence_length",
            "rope_theta_float32_bit_pattern",
            "rms_norm_epsilon_float32_bit_pattern",
            "unique_parameter_count",
        ] {
            try assertIdentityMutation("configuration.\(key)") { object in
                var configuration = try XCTUnwrap(
                    object["configuration"] as? [String: Any])
                let value = try XCTUnwrap(configuration[key] as? NSNumber)
                configuration[key] = value.int64Value + 1
                object["configuration"] = configuration
            }
        }
        for key in ["tokenizer_id", "tokenizer_manifest_sha256"] {
            try assertIdentityMutation("token_identity.\(key)") { object in
                var token = try XCTUnwrap(
                    object["token_identity"] as? [String: Any])
                token[key] = try XCTUnwrap(token[key] as? String) + "x"
                object["token_identity"] = token
            }
        }
        for key in ["schema_version", "vocabulary_size"] {
            try assertIdentityMutation("token_identity.\(key)") { object in
                var token = try XCTUnwrap(
                    object["token_identity"] as? [String: Any])
                let value = try XCTUnwrap(token[key] as? NSNumber)
                token[key] = value.intValue + 1
                object["token_identity"] = token
            }
        }
        try assertIdentityMutation("parameter_catalog.missing") { object in
            var catalog = try XCTUnwrap(
                object["parameter_catalog"] as? [[String: Any]])
            catalog.removeLast()
            object["parameter_catalog"] = catalog
        }
        try assertIdentityMutation("parameter_catalog.reordered") { object in
            var catalog = try XCTUnwrap(
                object["parameter_catalog"] as? [[String: Any]])
            catalog.swapAt(0, 1)
            object["parameter_catalog"] = catalog
        }
        try assertIdentityMutation("parameter_catalog.duplicate") { object in
            var catalog = try XCTUnwrap(
                object["parameter_catalog"] as? [[String: Any]])
            catalog.append(catalog[0])
            object["parameter_catalog"] = catalog
        }
        for key in ["path", "dtype"] {
            try assertIdentityMutation("parameter_catalog.\(key)") { object in
                var catalog = try XCTUnwrap(
                    object["parameter_catalog"] as? [[String: Any]])
                catalog[0][key] =
                    try XCTUnwrap(catalog[0][key] as? String) + "x"
                object["parameter_catalog"] = catalog
            }
        }
        try assertIdentityMutation("parameter_catalog.shape") { object in
            var catalog = try XCTUnwrap(
                object["parameter_catalog"] as? [[String: Any]])
            catalog[0]["shape"] = [1]
            object["parameter_catalog"] = catalog
        }
        for key in ["element_count", "byte_count"] {
            try assertIdentityMutation("parameter_catalog.\(key)") { object in
                var catalog = try XCTUnwrap(
                    object["parameter_catalog"] as? [[String: Any]])
                let value = try XCTUnwrap(catalog[0][key] as? NSNumber)
                catalog[0][key] = value.uint64Value + 1
                object["parameter_catalog"] = catalog
            }
        }

        let authorityData = try JSONEncoder().encode(authority)
        let authorityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: authorityData)
                as? [String: Any])
        let booleanKeys: [String] = authorityObject.compactMap { element in
            let (key, value) = element
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID()
            else {
                return nil
            }
            return key
        }.sorted()
        XCTAssertEqual(booleanKeys.count, 65)
        for key in booleanKeys {
            var object = authorityObject
            object[key] = !(try XCTUnwrap(object[key] as? Bool))
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV2(),
                "authority Boolean mutation was accepted: \(key)")
        }
        let criticalAuthorityMutations: [(String, Any)] = [
            ("schemaVersion", 3),
            ("authorityID", authority.authorityID + "x"),
            ("baseRevision", String(repeating: "1", count: 40)),
            ("baseTree", String(repeating: "2", count: 40)),
            ("baseEmbeddedSourceIdentitySHA256",
             String(repeating: "3", count: 64)),
            ("predecessorSourceSHA256", String(repeating: "4", count: 64)),
            ("checkpointV1AuthoritySourceSHA256",
             String(repeating: "5", count: 64)),
            ("checkpointV1SourceSHA256", String(repeating: "6", count: 64)),
            ("repairedDecoderSourceSHA256", String(repeating: "7", count: 64)),
            ("metalLauncherSHA256", String(repeating: "8", count: 64)),
            ("identityV2SourceSHA256", String(repeating: "9", count: 64)),
            ("historicalV1CanonicalIdentitySHA256",
             String(repeating: "a", count: 64)),
            ("publicV2CanonicalIdentitySHA256",
             String(repeating: "b", count: 64)),
            ("parameterCatalogSHA256", String(repeating: "c", count: 64)),
            ("totalParameterCount", 1),
            ("status", "ACCEPT"),
            ("orderedNextActions", ["skip"]),
        ]
        for (key, value) in criticalAuthorityMutations {
            var object = authorityObject
            XCTAssertNotNil(object[key])
            object[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV2(),
                "authority scalar mutation was accepted: \(key)")
        }

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let identitySourceData = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(
                authority.identityV2SourcePath))
        XCTAssertEqual(
            identitySourceData.count,
            authority.identityV2SourceByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: identitySourceData),
            authority.identityV2SourceSHA256)
        let identitySource = try XCTUnwrap(
            String(data: identitySourceData, encoding: .utf8))
        let imports = identitySource.split(separator: "\n")
            .compactMap { line -> String? in
                guard line.hasPrefix("import ") else { return nil }
                return String(line.dropFirst("import ".count))
            }
        XCTAssertEqual(imports, ["Foundation", "PrimeCore"])
        for token in authority.identityV2ForbiddenTokens {
            XCTAssertFalse(
                identitySource.contains(token),
                "IdentityV2 acquired forbidden capability: \(token)")
        }

        XCTAssertTrue(
            authority
                .declarativeRepairedCheckpointCompatibilityIdentityEstablished)
        XCTAssertTrue(authority.identityScopeIsDeclarativeOnly)
        XCTAssertFalse(authority.v1ManifestAcceptsV2Identity)
        XCTAssertFalse(authority.v2ManifestDefined)
        XCTAssertFalse(authority.v2CodecDefined)
        XCTAssertFalse(authority.checkpointContainerIOImplemented)
        XCTAssertFalse(authority.native300MModelAllocationAuthorized)
        XCTAssertFalse(authority.native300MCheckpointWriteAuthorized)
        XCTAssertFalse(authority.native300MCheckpointLoadAuthorized)
        XCTAssertFalse(authority.checkpointArtifactProvenanceEstablished)
        XCTAssertFalse(authority.checkpointAdmissionGranted)
        XCTAssertFalse(authority.admittedRuntimeComputePolicyEstablished)
        XCTAssertFalse(authority.runtimeDependencyClosureEstablished)
        XCTAssertFalse(authority.runtimeInitializationEstablished)
        XCTAssertFalse(authority.tokenizerFunctionalCompatibilityEstablished)
        XCTAssertFalse(authority.trainEvaluateSurfaceEstablished)
        XCTAssertFalse(authority.trainingExecutionObserved)
        XCTAssertFalse(authority.functionalTrainingAuthorized)
        XCTAssertFalse(authority.longTrainingAuthorized)
        XCTAssertFalse(authority.candidateAdmissionGranted)
        XCTAssertFalse(authority.trialAuthorized)
        XCTAssertFalse(authority.canaryReplacementAuthorized)
        XCTAssertFalse(authority.productUseAuthorized)
        XCTAssertFalse(authority.publicationAuthorized)
        XCTAssertTrue(authority.status.hasPrefix("ABSTAIN_"))
    }
}

private struct ManifestBindingFixture: Codable {
    let path: String
    let logicalSHA256: String
    let allValuesFinite: Bool

    private enum CodingKeys: String, CodingKey {
        case path
        case logicalSHA256 = "logical_sha256"
        case allValuesFinite = "all_values_finite"
    }
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import Metal
import MLX
import MLXNN
import PrimeCore
import XCTest

@testable import PrimeNativeDecoder
@testable import PrimeNativeDecoderCheckpoint

final class PrimeNativeDecoderCheckpointTests: XCTestCase {
    func testNative300MByte512CompatibilityIdentityIsExactWithoutAllocation()
        throws
    {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .native300MByte512()

        try identity.validate()
        XCTAssertEqual(identity.schemaVersion, 1)
        XCTAssertEqual(
            identity.identityScope,
            "native300m_gqa_byte512_checkpoint_compatibility_v1")
        XCTAssertEqual(
            identity.authorityID,
            PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1.authorityID)
        XCTAssertEqual(
            identity.architectureSchema,
            PrimeNativeGQADecoderConfiguration.architectureSchema)
        XCTAssertEqual(
            identity.implementationID,
            PrimeNativeGQADecoderConfiguration.implementationID)
        XCTAssertEqual(
            identity.tokenIdentity.tokenizerID,
            "ergentics_prime_nfc_utf8_byte_v1")
        XCTAssertEqual(identity.tokenIdentity.vocabularySize, 512)
        XCTAssertEqual(identity.parameterCatalog.count, 218)
        XCTAssertEqual(identity.totalParameterCount, 271_107_072)
        XCTAssertEqual(identity.totalParameterByteCount, 1_084_428_288)
        XCTAssertEqual(identity.maximumCheckpointByteCount, 1_101_205_504)
        XCTAssertTrue(identity.tiedOutputProjection)
        XCTAssertFalse(
            identity.parameterCatalog.contains {
                $0.path.contains("lm_head") || $0.path.contains("bias")
            })
    }

    func testAnalyticCatalogsMatchSyntheticLogicAndNativeInventories()
        throws
    {
        let syntheticConfiguration = try
            syntheticConfiguration()
        let logicConfiguration = try
            PrimeNativeGQADecoderConfiguration.logic10MInventory()
        let nativeConfiguration = try
            PrimeNativeGQADecoderConfiguration.native300MInventory(
                vocabularySize: 512)

        let synthetic = try PrimeNativeDecoderCompatibilityIdentityV1
            .analyticParameterCatalog(for: syntheticConfiguration)
        let logic = try PrimeNativeDecoderCompatibilityIdentityV1
            .analyticParameterCatalog(for: logicConfiguration)
        let native = try PrimeNativeDecoderCompatibilityIdentityV1
            .analyticParameterCatalog(for: nativeConfiguration)

        XCTAssertEqual(synthetic.count, 20)
        XCTAssertEqual(
            synthetic.reduce(UInt64(0)) { $0 + $1.elementCount },
            5_200)
        XCTAssertEqual(logic.count, 74)
        XCTAssertEqual(
            logic.reduce(UInt64(0)) { $0 + $1.elementCount },
            10_227_968)
        XCTAssertEqual(native.count, 218)
        XCTAssertEqual(
            native.reduce(UInt64(0)) { $0 + $1.elementCount },
            271_107_072)
        for catalog in [synthetic, logic, native] {
            let paths = catalog.map { $0.path }
            XCTAssertEqual(paths, paths.sorted())
            XCTAssertEqual(Set(paths).count, catalog.count)
            XCTAssertTrue(catalog.allSatisfy { $0.dtype == "float32" })
            XCTAssertTrue(catalog.allSatisfy {
                $0.byteCount == $0.elementCount * 4
            })
        }
    }

    func testConfigurationAndPublicIdentityRoundTripCanonicallyAndFailClosed()
        throws
    {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .native300MByte512()
        let canonical = try PrimeCanonicalJSON.encode(identity)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderCompatibilityIdentityV1.self,
            from: canonical)
        XCTAssertEqual(decoded, identity)
        try decoded.validate()

        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        var configuration = try XCTUnwrap(
            object["configuration"] as? [String: Any])
        configuration["unique_parameter_count"] = 1
        object["configuration"] = configuration
        let mutated = try JSONDecoder().decode(
            PrimeNativeDecoderCompatibilityIdentityV1.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]))
        XCTAssertThrowsError(try mutated.validate()) { error in
            XCTAssertEqual(
                error as? PrimeNativeDecoderCheckpointError,
                .invalidCompatibilityIdentity)
        }

        var unknown = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        unknown["unknown_key"] = "rejected"
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCompatibilityIdentityV1.self,
                from: JSONSerialization.data(
                    withJSONObject: unknown,
                    options: [.sortedKeys])))
    }

    func testCompatibilityIdentityRejectsEveryBoundFieldMutation() throws {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .native300MByte512()
        let base = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(identity))
                as? [String: Any])
        typealias Mutation = (String, (inout [String: Any]) -> Void)
        let mutations: [Mutation] = [
            ("schema_version", { $0["schema_version"] = 2 }),
            ("schema_id", { $0["schema_id"] = "changed" }),
            ("identity_scope", { $0["identity_scope"] = "changed" }),
            ("authority_id", { $0["authority_id"] = "changed" }),
            ("architecture_schema", {
                $0["architecture_schema"] = "changed"
            }),
            ("implementation_id", { $0["implementation_id"] = "changed" }),
            ("decoder_source_sha256", {
                $0["decoder_source_sha256"] = String(repeating: "0", count: 64)
            }),
            ("exact_mlx_revision", {
                $0["exact_mlx_revision"] = String(repeating: "0", count: 40)
            }),
            ("parameter_path_schema", {
                $0["parameter_path_schema"] = "changed"
            }),
            ("required_tensor_dtype", {
                $0["required_tensor_dtype"] = "float16"
            }),
            ("tied_output_projection", {
                $0["tied_output_projection"] = false
            }),
            ("configuration_vocabulary", {
                var value = $0["configuration"] as! [String: Any]
                value["vocabulary_size"] = 513
                $0["configuration"] = value
            }),
            ("configuration_width", {
                var value = $0["configuration"] as! [String: Any]
                value["model_width"] = 2_048
                $0["configuration"] = value
            }),
            ("configuration_layers", {
                var value = $0["configuration"] as! [String: Any]
                value["layer_count"] = 25
                $0["configuration"] = value
            }),
            ("configuration_query_heads", {
                var value = $0["configuration"] as! [String: Any]
                value["query_head_count"] = 8
                $0["configuration"] = value
            }),
            ("configuration_kv_heads", {
                var value = $0["configuration"] as! [String: Any]
                value["key_value_head_count"] = 8
                $0["configuration"] = value
            }),
            ("configuration_head_width", {
                var value = $0["configuration"] as! [String: Any]
                value["head_width"] = 128
                $0["configuration"] = value
            }),
            ("configuration_intermediate", {
                var value = $0["configuration"] as! [String: Any]
                value["intermediate_width"] = 2_817
                $0["configuration"] = value
            }),
            ("configuration_maximum_sequence", {
                var value = $0["configuration"] as! [String: Any]
                value["maximum_sequence_length"] = 2_049
                $0["configuration"] = value
            }),
            ("configuration_rope_bits", {
                var value = $0["configuration"] as! [String: Any]
                value["rope_theta_float32_bit_pattern"] = 0
                $0["configuration"] = value
            }),
            ("configuration_rms_bits", {
                var value = $0["configuration"] as! [String: Any]
                value["rms_norm_epsilon_float32_bit_pattern"] = 0
                $0["configuration"] = value
            }),
            ("configuration_parameter_count", {
                var value = $0["configuration"] as! [String: Any]
                value["unique_parameter_count"] = 1
                $0["configuration"] = value
            }),
            ("token_schema", {
                var value = $0["token_identity"] as! [String: Any]
                value["schema_version"] = 2
                $0["token_identity"] = value
            }),
            ("token_id", {
                var value = $0["token_identity"] as! [String: Any]
                value["tokenizer_id"] = "changed"
                $0["token_identity"] = value
            }),
            ("token_manifest", {
                var value = $0["token_identity"] as! [String: Any]
                value["tokenizer_manifest_sha256"] =
                    String(repeating: "0", count: 64)
                $0["token_identity"] = value
            }),
            ("token_vocabulary", {
                var value = $0["token_identity"] as! [String: Any]
                value["vocabulary_size"] = 513
                $0["token_identity"] = value
            }),
            ("catalog_missing", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value.removeLast()
                $0["parameter_catalog"] = value
            }),
            ("catalog_duplicate", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value.append(value[0])
                $0["parameter_catalog"] = value
            }),
            ("catalog_reordered", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value.swapAt(0, 1)
                $0["parameter_catalog"] = value
            }),
            ("catalog_path", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value[0]["path"] = "changed"
                $0["parameter_catalog"] = value
            }),
            ("catalog_shape", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value[0]["shape"] = [1]
                $0["parameter_catalog"] = value
            }),
            ("catalog_dtype", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value[0]["dtype"] = "float16"
                $0["parameter_catalog"] = value
            }),
            ("catalog_element_count", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value[0]["element_count"] = 1
                $0["parameter_catalog"] = value
            }),
            ("catalog_byte_count", {
                var value = $0["parameter_catalog"] as! [[String: Any]]
                value[0]["byte_count"] = 1
                $0["parameter_catalog"] = value
            }),
            ("catalog_sha", {
                $0["parameter_catalog_sha256"] = String(repeating: "0", count: 64)
            }),
            ("total_parameters", { $0["total_parameter_count"] = 1 }),
            ("total_bytes", { $0["total_parameter_byte_count"] = 1 }),
            ("maximum_bytes", { $0["maximum_checkpoint_byte_count"] = 1 }),
        ]

        for (name, mutate) in mutations {
            var object = base
            mutate(&object)
            let decoded = try JSONDecoder().decode(
                PrimeNativeDecoderCompatibilityIdentityV1.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try decoded.validate(),
                "mutation was accepted: \(name)"
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderCheckpointError,
                    .invalidCompatibilityIdentity,
                    "unexpected error for mutation: \(name)")
            }
        }
    }

    func testSyntheticManifestIsCanonicalOrderedAndNotPubliclyAdmitted()
        throws
    {
        let configuration = try
            syntheticConfiguration()
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: configuration)
        let manifest = try PrimeNativeDecoderCheckpointCodecV1
            .syntheticManifest(identity: identity)

        try manifest.validate(allowSynthetic: true)
        XCTAssertThrowsError(try manifest.validate())
        XCTAssertEqual(manifest.tensorBindings.count, 20)
        XCTAssertEqual(
            manifest.tensorBindings.map { $0.path },
            identity.parameterCatalog.map { $0.path })
        XCTAssertFalse(manifest.optimizerStateIncluded)
        XCTAssertFalse(manifest.rngStateIncluded)
        XCTAssertFalse(manifest.dataCursorIncluded)
        XCTAssertFalse(manifest.kvCacheStateIncluded)

        let canonical = try PrimeCanonicalJSON.encode(manifest)
        let replay = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderCheckpointManifestV1.self,
            from: canonical)
        XCTAssertEqual(replay, manifest)
        try replay.validate(allowSynthetic: true)

        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        var bindings = try XCTUnwrap(
            object["tensor_bindings"] as? [[String: Any]])
        bindings.swapAt(0, 1)
        object["tensor_bindings"] = bindings
        let reordered = try JSONDecoder().decode(
            PrimeNativeDecoderCheckpointManifestV1.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]))
        XCTAssertThrowsError(
            try reordered.validate(allowSynthetic: true)) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderCheckpointError,
                    .invalidCheckpointManifest)
            }
    }

    func testCheckpointManifestRejectsEveryBoundMutation() throws {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: syntheticConfiguration())
        let manifest = try PrimeNativeDecoderCheckpointCodecV1
            .syntheticManifest(identity: identity)
        let base = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(manifest))
                as? [String: Any])
        typealias Mutation = (String, (inout [String: Any]) -> Void)
        let mutations: [Mutation] = [
            ("schema_version", { $0["schema_version"] = 2 }),
            ("schema_id", { $0["schema_id"] = "changed" }),
            ("artifact_kind", { $0["artifact_kind"] = "changed" }),
            ("checkpoint_format", { $0["checkpoint_format"] = "changed" }),
            ("state_scope", { $0["state_scope"] = "changed" }),
            ("binding_missing", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value.removeLast()
                $0["tensor_bindings"] = value
            }),
            ("binding_duplicate", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value.append(value[0])
                $0["tensor_bindings"] = value
            }),
            ("binding_reordered", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value.swapAt(0, 1)
                $0["tensor_bindings"] = value
            }),
            ("binding_path", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value[0]["path"] = "changed"
                $0["tensor_bindings"] = value
            }),
            ("binding_hash_uppercase", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value[0]["logical_sha256"] = String(repeating: "A", count: 64)
                $0["tensor_bindings"] = value
            }),
            ("binding_hash_nonhex", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value[0]["logical_sha256"] = String(repeating: "z", count: 64)
                $0["tensor_bindings"] = value
            }),
            ("binding_hash_length", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value[0]["logical_sha256"] = "0"
                $0["tensor_bindings"] = value
            }),
            ("binding_finite", {
                var value = $0["tensor_bindings"] as! [[String: Any]]
                value[0]["all_values_finite"] = false
                $0["tensor_bindings"] = value
            }),
            ("bindings_sha", {
                $0["tensor_bindings_sha256"] = String(repeating: "0", count: 64)
            }),
            ("optimizer_state", { $0["optimizer_state_included"] = true }),
            ("rng_state", { $0["rng_state_included"] = true }),
            ("data_cursor", { $0["data_cursor_included"] = true }),
            ("kv_cache", { $0["kv_cache_state_included"] = true }),
        ]

        for (name, mutate) in mutations {
            var object = base
            mutate(&object)
            let decoded = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointManifestV1.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try decoded.validate(allowSynthetic: true),
                "mutation was accepted: \(name)"
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderCheckpointError,
                    .invalidCheckpointManifest,
                    "unexpected error for mutation: \(name)")
            }
        }
    }

    func testBorrowedDescriptorAPIRejectsInvalidDescriptorsWithoutMetal()
        throws
    {
        let configuration = try
            syntheticConfiguration()
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: configuration)
        let manifest = try PrimeNativeDecoderCheckpointCodecV1
            .syntheticManifest(identity: identity)

        XCTAssertThrowsError(
            try PrimeNativeDecoderCheckpointCodecV1.loadSynthetic(
                expectedManifest: manifest,
                fileDescriptor: -1)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeDecoderCheckpointError,
                .invalidFileDescriptor(-1))
        }
    }

    func testSyntheticValidationRejectsUnboundedGeometryBeforeCatalogWork()
        throws
    {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: syntheticConfiguration())
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(identity))
                as? [String: Any])
        object["identity_scope"] = "unexpected_unbounded_scope"
        var configuration = try XCTUnwrap(
            object["configuration"] as? [String: Any])
        configuration["layer_count"] = 1_000_000
        object["configuration"] = configuration
        let mutated = try JSONDecoder().decode(
            PrimeNativeDecoderCompatibilityIdentityV1.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]))

        XCTAssertThrowsError(
            try mutated.validate(allowSynthetic: true)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeDecoderCheckpointError,
                .invalidCompatibilityIdentity)
        }
    }

    func testOversizedSparseDescriptorIsRejectedBeforeMLXLoad() throws {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: syntheticConfiguration())
        let manifest = try PrimeNativeDecoderCheckpointCodecV1
            .syntheticManifest(identity: identity)
        try withTemporaryCheckpointDescriptor { descriptor in
            let oversized = identity.maximumCheckpointByteCount + 1
            XCTAssertEqual(ftruncate(descriptor, off_t(oversized)), 0)
            XCTAssertThrowsError(
                try PrimeNativeDecoderCheckpointCodecV1.loadSynthetic(
                    expectedManifest: manifest,
                    fileDescriptor: descriptor)
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeDecoderCheckpointError,
                    .checkpointFileTooLarge(
                        observed: oversized,
                        maximum: identity.maximumCheckpointByteCount))
            }
        }
    }

    func testNonregularDescriptorIsRejectedBeforeMLXLoad() throws {
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: syntheticConfiguration())
        let manifest = try PrimeNativeDecoderCheckpointCodecV1
            .syntheticManifest(identity: identity)
        var descriptors = [Int32](repeating: -1, count: 2)
        XCTAssertEqual(
            descriptors.withUnsafeMutableBufferPointer {
                pipe($0.baseAddress!)
            },
            0)
        defer {
            _ = close(descriptors[0])
            _ = close(descriptors[1])
        }

        XCTAssertThrowsError(
            try PrimeNativeDecoderCheckpointCodecV1.loadSynthetic(
                expectedManifest: manifest,
                fileDescriptor: descriptors[0])
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeDecoderCheckpointError,
                .checkpointDescriptorNotRegular)
        }
    }

    func testCanonicalLogicalFloat32EncodingHasKnownVectorAndHash()
        throws
    {
        let bitPatterns: [UInt32] = [
            0x3f80_0000,
            0xc000_0000,
            0x0000_0000,
        ]
        var native = Data()
        for var bits in bitPatterns {
            Swift.withUnsafeBytes(of: &bits) {
                native.append(contentsOf: $0)
            }
        }
        let canonical = try canonicalLogicalFloat32Data(native)
        XCTAssertEqual(
            Array(canonical),
            [
                0x00, 0x00, 0x80, 0x3f,
                0x00, 0x00, 0x00, 0xc0,
                0x00, 0x00, 0x00, 0x00,
            ])
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            "07897bbb1d312d156281b5eaf18c7e504fdd5eb25ac51b598eebb64d7fe654ec")
    }

    func testSyntheticBorrowedDescriptorRoundTripRestoresExactFreshModel()
        throws
    {
        try requireCheckpointMetal()
        let configuration = try
            syntheticConfiguration()
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: configuration)
        let original = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 2_026)

        try withTemporaryCheckpointDescriptor { descriptor in
            XCTAssertEqual(lseek(descriptor, 7, SEEK_SET), 7)
            let manifest = try PrimeNativeDecoderCheckpointCodecV1
                .writeSynthetic(
                    model: original,
                    identity: identity,
                    fileDescriptor: descriptor)
            XCTAssertEqual(lseek(descriptor, 0, SEEK_CUR), 7)
            let restored = try PrimeNativeDecoderCheckpointCodecV1
                .loadSynthetic(
                    expectedManifest: manifest,
                    fileDescriptor: descriptor)
            XCTAssertEqual(lseek(descriptor, 0, SEEK_CUR), 7)
            var descriptorMetadata = stat()
            XCTAssertEqual(fstat(descriptor, &descriptorMetadata), 0)

            let originalParameters = original.parameters().flattened()
                .sorted { $0.0 < $1.0 }
            let restoredParameters = restored.parameters().flattened()
                .sorted { $0.0 < $1.0 }
            XCTAssertEqual(
                originalParameters.map(\.0),
                restoredParameters.map(\.0))
            for index in originalParameters.indices {
                XCTAssertEqual(
                    originalParameters[index].1.asData(access: .copy).data,
                    restoredParameters[index].1.asData(access: .copy).data)
            }

            XCTAssertFalse(original === restored)
        }
    }

    func testSyntheticLoadRejectsDifferentValidManifestBeforeRestore()
        throws
    {
        try requireCheckpointMetal()
        let configuration = try
            syntheticConfiguration()
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: configuration)
        let first = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 41)
        let second = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 43)

        try withTemporaryCheckpointDescriptor { firstDescriptor in
            let firstManifest = try PrimeNativeDecoderCheckpointCodecV1
                .writeSynthetic(
                    model: first,
                    identity: identity,
                    fileDescriptor: firstDescriptor)
            try withTemporaryCheckpointDescriptor { secondDescriptor in
                let secondManifest = try PrimeNativeDecoderCheckpointCodecV1
                    .writeSynthetic(
                        model: second,
                        identity: identity,
                        fileDescriptor: secondDescriptor)
                XCTAssertNotEqual(firstManifest, secondManifest)
                XCTAssertThrowsError(
                    try PrimeNativeDecoderCheckpointCodecV1.loadSynthetic(
                        expectedManifest: secondManifest,
                        fileDescriptor: firstDescriptor)
                ) { error in
                    XCTAssertEqual(
                        error as? PrimeNativeDecoderCheckpointError,
                        .checkpointMetadataMismatch)
                }
            }
        }
    }

    func testSyntheticLoadRejectsMalformedMetadataAndTensorCatalog()
        throws
    {
        try requireCheckpointMetal()
        let configuration = try syntheticConfiguration()
        let identity = try PrimeNativeDecoderCompatibilityIdentityV1
            .synthetic(configuration: configuration)
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 47)
        var manifest: PrimeNativeDecoderCheckpointManifestV1!
        try withTemporaryCheckpointDescriptor { descriptor in
            manifest = try PrimeNativeDecoderCheckpointCodecV1
                .writeSynthetic(
                    model: model,
                    identity: identity,
                    fileDescriptor: descriptor)
        }
        let manifestData = try PrimeCanonicalJSON.encode(manifest)
        let manifestText = try XCTUnwrap(
            String(data: manifestData, encoding: .utf8))
        let exactMetadata = [
            PrimeNativeDecoderCheckpointCodecV1.manifestMetadataKey:
                manifestText,
            PrimeNativeDecoderCheckpointCodecV1
                .manifestSHA256MetadataKey:
                PrimeSHA256.hexDigest(of: manifestData),
        ]
        let exactArrays = Dictionary(
            uniqueKeysWithValues: model.parameters().flattened())
        let path = "token_embedding.weight"
        let exact = try XCTUnwrap(exactArrays[path])

        func assertRejected(
            arrays: [String: MLXArray],
            metadata: [String: String] = exactMetadata,
            expectedError: PrimeNativeDecoderCheckpointError,
            file: StaticString = #filePath,
            line: UInt = #line
        ) throws {
            try withTemporaryCheckpointDescriptor { descriptor in
                try MLX.save(
                    arrays: arrays,
                    metadata: metadata,
                    fileDescriptor: descriptor,
                    maximumBytes: identity.maximumCheckpointByteCount)
                XCTAssertThrowsError(
                    try PrimeNativeDecoderCheckpointCodecV1.loadSynthetic(
                        expectedManifest: manifest,
                        fileDescriptor: descriptor),
                    file: file,
                    line: line
                ) { error in
                    XCTAssertEqual(
                        error as? PrimeNativeDecoderCheckpointError,
                        expectedError,
                        file: file,
                        line: line)
                }
            }
        }

        var missing = exactArrays
        missing.removeValue(forKey: path)
        try assertRejected(
            arrays: missing,
            expectedError: .parameterPathSetMismatch)

        var extra = exactArrays
        extra["unexpected.weight"] = MLXArray([Float(0)])
        try assertRejected(
            arrays: extra,
            expectedError: .parameterPathSetMismatch)

        var wrongShape = exactArrays
        wrongShape[path] = exact.reshaped(exact.size)
        try assertRejected(
            arrays: wrongShape,
            expectedError: .parameterShapeMismatch(path))

        var wrongDType = exactArrays
        wrongDType[path] = exact.asType(.float16)
        try assertRejected(
            arrays: wrongDType,
            expectedError: .parameterDTypeMismatch(path))

        var nonfinite = exactArrays
        nonfinite[path] = exact * Float.nan
        try assertRejected(
            arrays: nonfinite,
            expectedError: .parameterContainsNonFiniteValue(path))

        var wrongLogicalBytes = exactArrays
        wrongLogicalBytes[path] = exact + Float(0.25)
        try assertRejected(
            arrays: wrongLogicalBytes,
            expectedError: .parameterLogicalHashMismatch("<catalog>"))

        try assertRejected(
            arrays: exactArrays,
            metadata: [
                PrimeNativeDecoderCheckpointCodecV1.manifestMetadataKey:
                    manifestText,
            ],
            expectedError: .checkpointMetadataMismatch)
        try assertRejected(
            arrays: exactArrays,
            metadata: [
                PrimeNativeDecoderCheckpointCodecV1.manifestMetadataKey:
                    manifestText,
                PrimeNativeDecoderCheckpointCodecV1
                    .manifestSHA256MetadataKey:
                    String(repeating: "0", count: 64),
            ],
            expectedError: .checkpointMetadataMismatch)
    }

    private func requireCheckpointMetal() throws {
        try PrimeNativeDecoderCIMLXComputeEnvironmentPolicy
            .validateLaunched(
                environment: ProcessInfo.processInfo.environment)
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip(
                "Metal is unavailable in this process; checkpoint execution was not observed")
        }
    }

    private func syntheticConfiguration()
        throws -> PrimeNativeGQADecoderConfiguration
    {
        try PrimeNativeGQADecoderConfiguration(
            vocabularySize: 32,
            modelWidth: 16,
            layerCount: 2,
            queryHeadCount: 4,
            keyValueHeadCount: 2,
            headWidth: 4,
            intermediateWidth: 32,
            maximumSequenceLength: 16)
    }

    private func withTemporaryCheckpointDescriptor<T>(
        _ body: (Int32) throws -> T
    ) throws -> T {
        var template = Array(
            "/private/tmp/prime-native-decoder-checkpoint.XXXXXX"
                .utf8CString)
        let descriptor = template.withUnsafeMutableBufferPointer {
            mkstemp($0.baseAddress!)
        }
        guard descriptor >= 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(descriptor)
        }
        defer {
            _ = close(descriptor)
            template.withUnsafeBufferPointer {
                _ = unlink($0.baseAddress!)
            }
        }
        return try body(descriptor)
    }
}

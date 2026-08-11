// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore
import PrimeNativeDecoderCheckpoint

final class PrimeNativeDecoderCheckpointV2IOTests: XCTestCase {
    func testArtifactRootBackedV2SchemasAndAuthorityFailClosed() throws {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        try authority.validateExactV1()

        XCTAssertTrue(authority.v2ManifestDefined)
        XCTAssertTrue(authority.v2ExternalBindingDefined)
        XCTAssertTrue(authority.v2CodecDefined)
        XCTAssertTrue(authority.checkpointContainerIOImplemented)
        XCTAssertTrue(authority.artifactRootPublicationIntegrationImplemented)
        XCTAssertTrue(authority.native300MCheckpointWriteExecutionAuthorized)
        XCTAssertTrue(authority.native300MCheckpointLoadExecutionAuthorized)
        XCTAssertFalse(authority.publicRawPathAPIAuthorized)
        XCTAssertFalse(authority.publicRawDescriptorAPIAuthorized)
        XCTAssertFalse(authority.publicDiscoverAndTrustAPIAuthorized)
        XCTAssertFalse(authority.publicInPlaceMutationAPIAuthorized)
        XCTAssertFalse(authority.publicReplacementAPIAuthorized)
        XCTAssertTrue(authority.isolatedDeclarativeValidationPackageAuthorized)
        XCTAssertTrue(authority.isolatedDeclarativeValidationTestAuthorized)
        XCTAssertTrue(
            authority
                .declarativeValidationMayConstructUnadmittedFullProfileManifestFixture)
        XCTAssertTrue(
            authority
                .declarativeValidationMayConstructUnadmittedExternalBindingFixture)
        XCTAssertFalse(authority.declarativeValidationCodecIOAuthorized)
        XCTAssertFalse(authority.declarativeValidationMayAllocateNative300M)
        XCTAssertFalse(authority.declarativeValidationFixtureIsArtifactAdmission)
        XCTAssertFalse(authority.validationCodecIOObserved)
        XCTAssertFalse(authority.native300MCheckpointWriteObserved)
        XCTAssertFalse(authority.native300MCheckpointLoadObserved)
        XCTAssertFalse(authority.checkpointIOObserved)
        XCTAssertFalse(authority.checkpointArtifactAvailable)
        XCTAssertFalse(authority.checkpointArtifactRetained)
        XCTAssertFalse(authority.checkpointArtifactProvenanceEstablished)
        XCTAssertFalse(authority.checkpointContainerHashBound)
        XCTAssertFalse(authority.checkpointAdmissionGranted)
        XCTAssertFalse(authority.atomicCheckpointReplacementEstablished)
        XCTAssertFalse(authority.checkpointDurabilityObserved)
        XCTAssertFalse(authority.failedCheckpointWriteRecoveryObserved)
        XCTAssertFalse(authority.trainingExecutionObserved)
        XCTAssertFalse(authority.productUseAuthorized)
        XCTAssertFalse(authority.publicationAuthorized)

        let identity = try PrimeNativeDecoderCompatibilityIdentityV2
            .native300MByte512()
        try identity.validate()
        let bindingObjects: [[String: Any]] = identity.parameterCatalog.map {
            descriptor in
            [
                "path": descriptor.path,
                "logical_sha256": PrimeSHA256.hexDigest(
                    of: Data(descriptor.path.utf8)),
                "all_values_finite": true,
            ]
        }
        let bindingData = try JSONSerialization.data(
            withJSONObject: bindingObjects,
            options: [.sortedKeys])
        let tensorBindings = try JSONDecoder().decode(
            [PrimeNativeDecoderCheckpointTensorBindingV2].self,
            from: bindingData)
        let canonicalBindingData = try PrimeCanonicalJSON.encode(
            tensorBindings)
        XCTAssertEqual(tensorBindings.count, 218)

        let identityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(identity))
                as? [String: Any])
        let canonicalBindingObjects = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonicalBindingData)
                as? [[String: Any]])
        let manifestObject: [String: Any] = [
            "schema_version": authority.manifestSchemaVersion,
            "schema_id": authority.manifestSchemaID,
            "artifact_kind": authority.checkpointArtifactKind,
            "checkpoint_format": authority.checkpointFormat,
            "state_scope": authority.stateScope,
            "logical_tensor_hash_algorithm":
                authority.logicalTensorHashAlgorithm,
            "logical_tensor_byte_encoding":
                authority.logicalTensorByteEncoding,
            "compatibility_identity": identityObject,
            "tensor_bindings": canonicalBindingObjects,
            "tensor_bindings_sha256": PrimeSHA256.hexDigest(
                of: canonicalBindingData),
            "optimizer_state_included": false,
            "rng_state_included": false,
            "data_cursor_included": false,
            "kv_cache_state_included": false,
        ]
        let manifest = try JSONDecoder().decode(
            PrimeNativeDecoderCheckpointManifestV2.self,
            from: JSONSerialization.data(
                withJSONObject: manifestObject,
                options: [.sortedKeys]))
        try manifest.validate()
        let manifestBytes = try PrimeCanonicalJSON.encode(manifest)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCheckpointManifestV2.self,
                from: manifestBytes),
            manifest)

        let artifactByteCount = identity.totalParameterByteCount + 1_048_576
        let externalBinding = PrimeNativeDecoderCheckpointExternalBindingV2(
            manifest: manifest,
            manifestCanonicalByteCount: UInt64(manifestBytes.count),
            manifestCanonicalSHA256: PrimeSHA256.hexDigest(
                of: manifestBytes),
            artifactBinding: PrimeArtifactBinding(
                relativePath: "native300m-byte512-v2.safetensors",
                sha256: String(repeating: "a", count: 64),
                byteCount: artifactByteCount,
                purpose: .immutableData))
        try externalBinding.validate()
        let externalBindingBytes = try PrimeCanonicalJSON.encode(
            externalBinding)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCheckpointExternalBindingV2.self,
                from: externalBindingBytes),
            externalBinding)

        let authorityData = try PrimeCanonicalJSON.encode(authority)
        let authorityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: authorityData)
                as? [String: Any])
        let authorityBooleanKeys = authorityObject.compactMap {
            element -> String? in
            let (key, value) = element
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID()
            else {
                return nil
            }
            return key
        }.sorted()
        XCTAssertEqual(authorityBooleanKeys.count, 101)
        for key in authorityBooleanKeys {
            var object = authorityObject
            object[key] = !(try XCTUnwrap(object[key] as? Bool))
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority Boolean mutation was accepted: \(key)")
        }
        let authorityMutations: [(String, Any)] = [
            ("schemaVersion", 2),
            ("authorityID", authority.authorityID + "x"),
            ("baseRevision", String(repeating: "1", count: 40)),
            ("baseTree", String(repeating: "2", count: 40)),
            ("baseEmbeddedSourceIdentitySHA256",
             String(repeating: "3", count: 64)),
            ("exactMLXRevision", String(repeating: "4", count: 40)),
            ("mlxDescriptorIOSHA256", String(repeating: "5", count: 64)),
            ("publicManifestType", authority.publicManifestType + "x"),
            ("publicWriteDeclaration", authority.publicWriteDeclaration + "x"),
            ("publicLoadDeclaration", authority.publicLoadDeclaration + "x"),
            ("manifestSchemaID", authority.manifestSchemaID + "x"),
            ("publicCompatibilityIdentitySHA256",
             String(repeating: "6", count: 64)),
            ("parameterCatalogSHA256", String(repeating: "7", count: 64)),
            ("totalParameterCount", 1),
            ("totalParameterByteCount", 1),
            ("maximumCheckpointByteCount", 1),
            ("status", "PASS"),
            ("orderedNextActions", ["skip"]),
        ]
        for (key, value) in authorityMutations {
            var object = authorityObject
            XCTAssertNotNil(object[key])
            object[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority scalar mutation was accepted: \(key)")
        }

        let canonicalManifestObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: manifestBytes)
                as? [String: Any])
        func assertManifestMutation(
            _ label: String,
            _ mutate: (inout [String: Any]) throws -> Void
        ) throws {
            var object = canonicalManifestObject
            try mutate(&object)
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointManifestV2.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "manifest mutation was accepted: \(label)")
        }
        for key in [
            "schema_id",
            "artifact_kind",
            "checkpoint_format",
            "state_scope",
            "logical_tensor_hash_algorithm",
            "logical_tensor_byte_encoding",
            "tensor_bindings_sha256",
        ] {
            try assertManifestMutation(key) { object in
                object[key] = try XCTUnwrap(object[key] as? String) + "x"
            }
        }
        for key in [
            "optimizer_state_included",
            "rng_state_included",
            "data_cursor_included",
            "kv_cache_state_included",
        ] {
            try assertManifestMutation(key) { object in
                object[key] = true
            }
        }
        try assertManifestMutation("missing tensor") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings.removeLast()
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("reordered tensors") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings.swapAt(0, 1)
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("duplicate tensor") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings.append(bindings[0])
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("tensor path") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings[0]["path"] = "mutated"
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("tensor logical hash") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings[0]["logical_sha256"] = String(repeating: "f", count: 64)
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("tensor finite") { object in
            var bindings = try XCTUnwrap(
                object["tensor_bindings"] as? [[String: Any]])
            bindings[0]["all_values_finite"] = false
            object["tensor_bindings"] = bindings
        }
        try assertManifestMutation("identity relabel") { object in
            var nested = try XCTUnwrap(
                object["compatibility_identity"] as? [String: Any])
            nested["schema_id"] = "ergentics_prime_native_decoder_checkpoint_compatibility_v1"
            object["compatibility_identity"] = nested
        }

        let canonicalExternalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: externalBindingBytes)
                as? [String: Any])
        func assertExternalMutation(
            _ label: String,
            _ mutate: (inout [String: Any]) throws -> Void
        ) throws {
            var object = canonicalExternalObject
            try mutate(&object)
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointExternalBindingV2.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "external binding mutation was accepted: \(label)")
        }
        try assertExternalMutation("manifest byte count") { object in
            let value = try XCTUnwrap(
                object["manifest_canonical_byte_count"] as? NSNumber)
            object["manifest_canonical_byte_count"] = value.uint64Value + 1
        }
        try assertExternalMutation("manifest hash") { object in
            object["manifest_canonical_sha256"] = String(
                repeating: "b",
                count: 64)
        }
        try assertExternalMutation("artifact path") { object in
            var artifact = try XCTUnwrap(
                object["artifact_binding"] as? [String: Any])
            artifact["relativePath"] = "../checkpoint"
            object["artifact_binding"] = artifact
        }
        try assertExternalMutation("artifact hash") { object in
            var artifact = try XCTUnwrap(
                object["artifact_binding"] as? [String: Any])
            artifact["sha256"] = "invalid"
            object["artifact_binding"] = artifact
        }
        try assertExternalMutation("artifact too small") { object in
            var artifact = try XCTUnwrap(
                object["artifact_binding"] as? [String: Any])
            artifact["byteCount"] = identity.totalParameterByteCount
            object["artifact_binding"] = artifact
        }
        try assertExternalMutation("artifact too large") { object in
            var artifact = try XCTUnwrap(
                object["artifact_binding"] as? [String: Any])
            artifact["byteCount"] = identity.maximumCheckpointByteCount + 1
            object["artifact_binding"] = artifact
        }
        try assertExternalMutation("artifact purpose") { object in
            var artifact = try XCTUnwrap(
                object["artifact_binding"] as? [String: Any])
            artifact["purpose"] = "executable"
            object["artifact_binding"] = artifact
        }

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let implementationURL = repositoryRoot.appendingPathComponent(
            authority.implementationSourcePath)
        let implementationData = try Data(contentsOf: implementationURL)
        XCTAssertEqual(
            implementationData.count,
            try XCTUnwrap(authority.implementationSourceByteCount))
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: implementationData),
            try XCTUnwrap(authority.implementationSourceSHA256))
        let implementation = try XCTUnwrap(
            String(data: implementationData, encoding: .utf8))
        let imports = implementation.split(separator: "\n")
            .compactMap { line -> String? in
                guard line.hasPrefix("import ") else { return nil }
                return String(line.dropFirst("import ".count))
            }
        XCTAssertEqual(
            imports,
            ["Darwin", "Foundation", "MLX", "MLXNN", "PrimeCore",
             "PrimeNativeDecoder"])
        for required in [
            "PrimeArtifactRoot",
            "publishGeneratedFile(",
            "withVerifiedArtifactDescriptor(",
            "MLX.save(",
            "MLX.loadArraysAndMetadata(",
            "validateRawSafetensorsLayout(",
            "PrimeV2SafetensorsHeaderParser",
            "native300MCheckpointWriteExecutionAuthorized",
            "native300MCheckpointLoadExecutionAuthorized",
        ] {
            XCTAssertTrue(
                implementation.contains(required),
                "V2 implementation lost required boundary: \(required)")
        }
        for forbidden in [
            "FileManager",
            "FileHandle",
            "URL(fileURLWithPath:",
            "URLSession",
            "posix_spawn",
            "execve(",
            "PrimeNativeDecoderCheckpointCodecV1",
            "unlink(",
            "rename(",
        ] {
            XCTAssertFalse(
                implementation.contains(forbidden),
                "V2 implementation acquired forbidden capability: \(forbidden)")
        }
        for line in implementation.split(separator: "\n")
        where line.contains("public") {
            XCTAssertFalse(
                line.contains("fileDescriptor")
                    || line.contains("FileHandle")
                    || line.contains("URL"),
                "V2 public surface exposed a raw filesystem primitive")
        }
    }
}

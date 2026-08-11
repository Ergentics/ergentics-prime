// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore
import PrimeNativeDecoderCheckpoint

final class PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests:
    XCTestCase
{
    func testExecutionAuthorityEvidenceAndTransportAreExactAndPure()
        throws
    {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
                .frozenV1
        try authority.validateExactV1()
        XCTAssertTrue(authority.exactReviewedMainExecutionAuthorized)
        XCTAssertTrue(authority.native300MCheckpointWriteAuthorized)
        XCTAssertTrue(authority.native300MCheckpointLoadAuthorized)
        XCTAssertTrue(authority.ephemeralArtifactRootIOAuthorized)
        XCTAssertFalse(authority.localOrManualExecutionAuthorized)
        XCTAssertFalse(authority.rerunExecutionAuthorized)
        XCTAssertFalse(authority.laterMainExecutionAuthorized)
        XCTAssertFalse(authority.executionRetryAuthorized)
        XCTAssertFalse(authority.checkpointArtifactRetentionAuthorized)
        XCTAssertFalse(authority.checkpointArtifactUploadAuthorized)
        XCTAssertFalse(authority.checkpointArtifactAdmissionAuthorized)
        XCTAssertFalse(authority.decoderForwardAuthorized)
        XCTAssertFalse(authority.backwardAuthorized)
        XCTAssertFalse(authority.trainingAuthorized)
        XCTAssertFalse(authority.native300MCheckpointWriteObserved)
        XCTAssertFalse(authority.native300MCheckpointLoadObserved)
        XCTAssertFalse(authority.checkpointIOObserved)
        XCTAssertFalse(authority.checkpointArtifactAvailable)
        XCTAssertEqual(
            authority.reclaimableRunnerTemporaryRelativePaths.count,
            24)
        XCTAssertEqual(authority.receiptChunkCharacterCount, 4_096)
        XCTAssertEqual(authority.receiptChunkOrdinalWidth, 6)
        XCTAssertEqual(authority.maximumCanonicalReceiptByteCount, 262_144)
        XCTAssertEqual(
            authority.newExecutionSourceIdentityStatus,
            "PINNED_AFTER_SOURCE_STABILIZATION")
        XCTAssertEqual(authority.newExecutionSourceBindings.count, 6)
        let expectedNewExecutionPaths = [
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
        ]
        XCTAssertEqual(
            authority.newExecutionSourceBindings.map(\.path),
            expectedNewExecutionPaths)
        XCTAssertEqual(
            Set(authority.newExecutionSourceBindings.map(\.path)),
            Set(expectedNewExecutionPaths))
        XCTAssertEqual(authority.baseSourceBindings.count, 12)
        XCTAssertEqual(
            Set(authority.baseSourceBindings.map(\.path)).count,
            authority.baseSourceBindings.count)

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
        XCTAssertEqual(tensorBindings.count, authority.parameterDescriptorCount)

        let containerAuthority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        try containerAuthority.validateExactV1()
        let identityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(identity))
                as? [String: Any])
        let canonicalBindingObjects = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonicalBindingData)
                as? [[String: Any]])
        let manifestObject: [String: Any] = [
            "schema_version": containerAuthority.manifestSchemaVersion,
            "schema_id": containerAuthority.manifestSchemaID,
            "artifact_kind": containerAuthority.checkpointArtifactKind,
            "checkpoint_format": containerAuthority.checkpointFormat,
            "state_scope": containerAuthority.stateScope,
            "logical_tensor_hash_algorithm":
                containerAuthority.logicalTensorHashAlgorithm,
            "logical_tensor_byte_encoding":
                containerAuthority.logicalTensorByteEncoding,
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
        let externalBinding =
            PrimeNativeDecoderCheckpointExternalBindingV2(
                manifest: manifest,
                manifestCanonicalByteCount: UInt64(manifestBytes.count),
                manifestCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: manifestBytes),
                artifactBinding: PrimeArtifactBinding(
                    relativePath: authority.artifactRelativePath,
                    sha256: String(repeating: "a", count: 64),
                    byteCount:
                        authority.totalParameterByteCount + 1_048_576,
                    purpose: .immutableData))
        try externalBinding.validate()
        let externalBytes = try PrimeCanonicalJSON.encode(externalBinding)
        let identityBytes = try PrimeCanonicalJSON.encode(identity)
        let rootBeforeIdentity =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 2,
                modificationTimeSeconds: 3,
                modificationTimeNanoseconds: 4,
                changeTimeSeconds: 5,
                changeTimeNanoseconds: 6)
        let rootAfterIdentity =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 2,
                modificationTimeSeconds: 7,
                modificationTimeNanoseconds: 8,
                changeTimeSeconds: 9,
                changeTimeNanoseconds: 10)
        try rootBeforeIdentity.validatePrivateDirectory()
        try rootAfterIdentity.validatePrivateDirectory()
        XCTAssertNotEqual(rootBeforeIdentity, rootAfterIdentity)
        XCTAssertTrue(
            rootBeforeIdentity.stableObjectFieldsEqual(
                to: rootAfterIdentity))

        // This is an unobserved, untransported, unadmitted in-memory schema
        // fixture. Constructing it checks fail-closed type consistency only;
        // only the pinned hosted probe/log can supply execution provenance.
        let evidence = try
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1(
                executedRevision: String(repeating: "1", count: 40),
                executedOrderedParentRevisions: [
                    authority.requiredDirectSuccessorFirstParentRevision,
                    String(repeating: "2", count: 40),
                ],
                executedTree: String(repeating: "3", count: 40),
                reviewedPullRequestHeadTree:
                    String(repeating: "3", count: 40),
                executedEmbeddedSourceIdentitySHA256:
                    String(repeating: "4", count: 64),
                executionEvent: authority.requiredExecutionEvent,
                executionRef: authority.requiredExecutionRef,
                executionRunAttempt: authority.requiredExecutionRunAttempt,
                executionRepository: authority.authoritativeRepository,
                githubActions: authority.requiredGitHubActionsValue,
                runnerEnvironment: authority.requiredRunnerEnvironment,
                operatingSystem: "macOS",
                architecture: "arm64",
                exactRevisionMatchedGitHubSHA: true,
                environmentPolicy: authority.environmentPolicy,
                launchedEnvironmentValidatedBeforeFrameworkAccess: true,
                launchedEnvironmentRevalidatedAfterEvaluation: true,
                releaseInstrumentationEvidenceAbsent: true,
                coreGraphicsBootstrapObserved: true,
                enumeratedMetalDeviceCount: 1,
                defaultMetalDeviceMatchedIndexZero: true,
                mlxDeviceType: "gpu",
                mlxDeviceIndex: authority.mlxGPUDeviceIndex,
                metalLeaseHeldBeforeAndAfterEvaluation: true,
                metallibArtifactRelativePath:
                    PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                        .artifactRelativePath,
                metallibByteCount: 1,
                metallibSHA256: String(repeating: "5", count: 64),
                existingMetallibCandidateCountBeforeExecution: 1,
                existingMetallibCandidateCountAfterExecution: 1,
                metallibPathAndDescriptorReverified: true,
                metalLibraryValidatedFromExactURL: true,
                focusedContractLogsValidatedBeforeReclamation: true,
                frozen44MetalLogValidatedBeforeReclamation: true,
                maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation:
                    true,
                tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation:
                    true,
                predecessorValidatedLogCount: 8,
                predecessorValidatedReceiptCount: 2,
                knownRunnerTemporaryReclamationPathCount: 24,
                knownRunnerTemporaryPathsAbsentBeforeProbe: true,
                availableFilesystemBytesAfterReclamation:
                    authority.requiredAvailableFilesystemBytesAfterBuild,
                availableFilesystemBytesAfterBuild:
                    authority.requiredAvailableFilesystemBytesAfterBuild,
                requiredFreeSpaceMultiplier:
                    authority.requiredFreeSpaceMultiplier,
                freeSpacePreflightPassed: true,
                artifactRootPathIsAbsolute: true,
                artifactRootOwnerMatchedEffectiveUser: true,
                artifactRootInitiallyEmpty: true,
                artifactRootEntryCountAfterWrite: 1,
                artifactRootIdentityBeforeWrite: rootBeforeIdentity,
                artifactRootIdentityAfterWrite: rootAfterIdentity,
                artifactRootIdentityAfterLoad: rootAfterIdentity,
                compatibilityIdentityCanonicalByteCount:
                    identityBytes.count,
                compatibilityIdentitySHA256:
                    PrimeSHA256.hexDigest(of: identityBytes),
                compatibilityIdentityValidated: true,
                configuration: authority.configuration,
                initializationSeed: authority.initializationSeed,
                callerSourceModelConstructionCount: 1,
                initialParameterMaterializationEvaluationCount: 1,
                initialParameterMaterializationEvaluationAPI:
                    authority.initialParameterMaterializationEvaluationAPI,
                memoryCacheLimit: authority.requiredMemoryCacheLimit,
                memoryCacheClearCount: authority.requiredMemoryCacheClearCount,
                cacheClearedBeforeSourceMaterialization: true,
                sourceModelReferenceLexicalScopeEndedBeforePublicLoad: true,
                cacheClearedBetweenSourceWriteAndPublicLoad: true,
                publicCheckpointWriteInvocationCount: 1,
                publicCheckpointWriteCompletionCount: 1,
                publicCheckpointLoadInvocationCount: 1,
                publicCheckpointLoadCompletionCount: 1,
                externalBinding: externalBinding,
                externalBindingCanonicalByteCount:
                    UInt64(externalBytes.count),
                externalBindingCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: externalBytes),
                manifestCanonicalByteCount: UInt64(manifestBytes.count),
                manifestCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: manifestBytes),
                manifestValidated: true,
                tensorBindingCount: tensorBindings.count,
                tensorBindingsCanonicalByteCount:
                    UInt64(canonicalBindingData.count),
                tensorBindingsSHA256:
                    PrimeSHA256.hexDigest(of: canonicalBindingData),
                observedParameterCount: authority.totalParameterCount,
                observedParameterByteCount:
                    authority.totalParameterByteCount,
                publishedArtifactMode:
                    authority.requiredPublishedArtifactMode,
                publishedArtifactLinkCount:
                    authority.requiredPublishedArtifactLinkCount,
                writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn:
                    true,
                loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec:
                    true,
                loadedStructuralParameterCatalogMatched: true,
                artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot:
                    true,
                exclusiveNoReplacePublicationCompleted: true,
                generatedFileAndParentSynchronizationReturnedSuccess: true)
        try evidence.validate()
        let receipt = try evidence.canonicalReceiptData()
        XCTAssertLessThanOrEqual(
            UInt64(receipt.count),
            authority.maximumCanonicalReceiptByteCount)
        XCTAssertGreaterThan(
            receipt.count,
            authority.maximumReceiptTransportLineByteCount)
        let encoded = Array(receipt.base64EncodedString().utf8)
        let chunkCount = (
            encoded.count + authority.receiptChunkCharacterCount - 1
        ) / authority.receiptChunkCharacterCount
        XCTAssertGreaterThan(chunkCount, 1)
        XCTAssertLessThanOrEqual(chunkCount, 86)
        for index in 0 ..< chunkCount {
            let start = index * authority.receiptChunkCharacterCount
            let end = min(
                start + authority.receiptChunkCharacterCount,
                encoded.count)
            let count = end - start
            XCTAssertGreaterThan(count, 0)
            XCTAssertEqual(count % 4, 0)
            if index < chunkCount - 1 {
                XCTAssertEqual(
                    count,
                    authority.receiptChunkCharacterCount)
            }
        }
        let maximumEncodedCount =
            ((Int(authority.maximumCanonicalReceiptByteCount) + 2) / 3)
                * 4
        let maximumChunkCount = (
            maximumEncodedCount + authority.receiptChunkCharacterCount - 1
        ) / authority.receiptChunkCharacterCount
        XCTAssertEqual(maximumChunkCount, 86)
        XCTAssertLessThan(
            maximumChunkCount,
            Int(pow(10.0, Double(authority.receiptChunkOrdinalWidth))))
        XCTAssertEqual(
            try PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
                .decodeCanonicalReceipt(from: receipt),
            evidence)
        var nonCanonicalReceipt = receipt
        nonCanonicalReceipt.append(0x0a)
        XCTAssertThrowsError(
            try PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
                .decodeCanonicalReceipt(from: nonCanonicalReceipt))

        let authorityData = try PrimeCanonicalJSON.encode(authority)
        let authorityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: authorityData)
                as? [String: Any])
        let authorityBooleanKeys = authorityObject.compactMap {
            key, value -> String? in
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID() else {
                return nil
            }
            return key
        }
        XCTAssertGreaterThan(authorityBooleanKeys.count, 80)
        for key in authorityBooleanKeys {
            var object = authorityObject
            object[key] = !(try XCTUnwrap(object[key] as? Bool))
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority Boolean mutation accepted: \(key)")
        }
        func assertAuthoritySourceBindingMutation(
            _ label: String,
            _ mutate: (inout [[String: Any]]) throws -> Void
        ) throws {
            var object = authorityObject
            var bindings = try XCTUnwrap(
                object["newExecutionSourceBindings"]
                    as? [[String: Any]])
            try mutate(&bindings)
            object["newExecutionSourceBindings"] = bindings
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "authority source-binding mutation accepted: \(label)")
        }
        try assertAuthoritySourceBindingMutation("SHA") { bindings in
            bindings[0]["sha256"] = String(repeating: "0", count: 64)
        }
        try assertAuthoritySourceBindingMutation("path") { bindings in
            bindings[0]["path"] = "unexpected"
        }
        try assertAuthoritySourceBindingMutation("drop") { bindings in
            bindings.removeLast()
        }
        try assertAuthoritySourceBindingMutation("duplicate") { bindings in
            bindings.append(bindings[0])
        }
        try assertAuthoritySourceBindingMutation("reorder") { bindings in
            bindings.swapAt(0, 1)
        }

        let evidenceObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receipt)
                as? [String: Any])
        func assertEvidenceMutation(
            _ label: String,
            _ mutate: (inout [String: Any]) throws -> Void
        ) throws {
            var object = evidenceObject
            try mutate(&object)
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes])
            do {
                let mutated = try JSONDecoder().decode(
                    PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
                        .self,
                    from: data)
                XCTAssertThrowsError(
                    try mutated.validate(),
                    "evidence mutation accepted: \(label)")
            } catch is DecodingError {
                // A decoding rejection is also fail-closed.
            }
        }
        let evidenceBooleanKeys = evidenceObject.compactMap {
            key, value -> String? in
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID() else {
                return nil
            }
            return key
        }
        XCTAssertGreaterThan(evidenceBooleanKeys.count, 50)
        for key in evidenceBooleanKeys {
            var object = evidenceObject
            object[key] = !(try XCTUnwrap(object[key] as? Bool))
            let mutation = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes])
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
                    .self,
                from: mutation)
            XCTAssertThrowsError(
                try mutated.validate(),
                "evidence Boolean mutation accepted: \(key)")
        }

        for (key, value) in [
            ("execution_event", "workflow_dispatch"),
            ("execution_ref", "refs/heads/other"),
            ("architecture", "x86_64"),
            ("status", "PASS"),
        ] {
            var object = evidenceObject
            object[key] = value
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]))
            XCTAssertThrowsError(
                try mutated.validate(),
                "evidence scalar mutation accepted: \(key)")
        }

        try assertEvidenceMutation("parent order") { object in
            var parents = try XCTUnwrap(
                object["executed_ordered_parent_revisions"] as? [String])
            parents.swapAt(0, 1)
            object["executed_ordered_parent_revisions"] = parents
        }
        try assertEvidenceMutation("parent count") { object in
            object["executed_ordered_parent_revisions"] = [
                authority.requiredDirectSuccessorFirstParentRevision,
            ]
        }
        try assertEvidenceMutation("duplicate parents") { object in
            object["executed_ordered_parent_revisions"] = [
                authority.requiredDirectSuccessorFirstParentRevision,
                authority.requiredDirectSuccessorFirstParentRevision,
            ]
        }
        try assertEvidenceMutation("reviewed tree") { object in
            object["reviewed_pull_request_head_tree"] =
                String(repeating: "6", count: 40)
        }
        try assertEvidenceMutation("predecessor log count") { object in
            object["predecessor_validated_log_count"] = 7
        }
        try assertEvidenceMutation("predecessor receipt count") { object in
            object["predecessor_validated_receipt_count"] = 1
        }
        try assertEvidenceMutation("capacity") { object in
            object["available_filesystem_bytes_after_build"] =
                authority.requiredAvailableFilesystemBytesAfterBuild - 1
        }
        try assertEvidenceMutation("post-load root timestamp") { object in
            var root = try XCTUnwrap(
                object["artifact_root_identity_after_load"]
                    as? [String: Any])
            root["modification_time_seconds"] = 99
            object["artifact_root_identity_after_load"] = root
        }
        try assertEvidenceMutation("post-load root inode") { object in
            var root = try XCTUnwrap(
                object["artifact_root_identity_after_load"]
                    as? [String: Any])
            root["inode"] = 99
            object["artifact_root_identity_after_load"] = root
        }
        try assertEvidenceMutation("post-load root mode") { object in
            var root = try XCTUnwrap(
                object["artifact_root_identity_after_load"]
                    as? [String: Any])
            root["permission_mode"] = 0o755
            object["artifact_root_identity_after_load"] = root
        }
        try assertEvidenceMutation("environment predecessor") { object in
            var policy = try XCTUnwrap(
                object["environment_policy"] as? [String: Any])
            policy["predecessorRemainsFrozen"] = false
            object["environment_policy"] = policy
        }
        try assertEvidenceMutation("optimizer state") { object in
            var external = try XCTUnwrap(
                object["external_binding"] as? [String: Any])
            var nestedManifest = try XCTUnwrap(
                external["manifest"] as? [String: Any])
            nestedManifest["optimizer_state_included"] = true
            external["manifest"] = nestedManifest
            object["external_binding"] = external
        }
        for index in [0, tensorBindings.count - 1] {
            try assertEvidenceMutation("tensor finite \(index)") { object in
                var external = try XCTUnwrap(
                    object["external_binding"] as? [String: Any])
                var nestedManifest = try XCTUnwrap(
                    external["manifest"] as? [String: Any])
                var bindings = try XCTUnwrap(
                    nestedManifest["tensor_bindings"]
                        as? [[String: Any]])
                bindings[index]["all_values_finite"] = false
                nestedManifest["tensor_bindings"] = bindings
                external["manifest"] = nestedManifest
                object["external_binding"] = external
            }
        }
        try assertEvidenceMutation("configuration width") { object in
            var configuration = try XCTUnwrap(
                object["configuration"] as? [String: Any])
            configuration["model_width"] = 1_025
            object["configuration"] = configuration
        }
        try assertEvidenceMutation("tensor path") { object in
            var external = try XCTUnwrap(
                object["external_binding"] as? [String: Any])
            var nestedManifest = try XCTUnwrap(
                external["manifest"] as? [String: Any])
            var bindings = try XCTUnwrap(
                nestedManifest["tensor_bindings"]
                    as? [[String: Any]])
            bindings[0]["path"] = "mutated"
            nestedManifest["tensor_bindings"] = bindings
            external["manifest"] = nestedManifest
            object["external_binding"] = external
        }
    }
}

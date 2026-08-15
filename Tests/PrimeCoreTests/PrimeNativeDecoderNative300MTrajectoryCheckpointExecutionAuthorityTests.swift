// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "prime_native_decoder_native300m_trajectory_checkpoint_execution_authority_v1")
        XCTAssertEqual(
            authority.roadmap.canonicalSHA256,
            "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589")
        XCTAssertEqual(authority.roadmap.orderedStageIDs.count, 8)
        XCTAssertEqual(authority.roadmap.stageOrdinal, 7)
        XCTAssertEqual(
            authority.roadmap.stageID,
            "native300m_trajectory_checkpoint_execution_v1")
        XCTAssertEqual(
            authority.roadmap.objective,
            "execute_one_bounded_native300m_step_checkpoint_restore_and_exact_successor_step_only_after_assay_and_resource_clearance")
        XCTAssertEqual(
            authority.stage5BPass.canonicalSHA256,
            "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9")
        XCTAssertEqual(
            authority.bSpecificNative300MResourcePass.canonicalSHA256,
            "da9edca25faaef6ae6fae38669692603faeb7c29f4995a0fce4a096015a49a88")
        XCTAssertTrue(authority.stage5BPass.oneShotExhausted)
        XCTAssertTrue(authority.bSpecificNative300MResourcePass.oneShotExhausted)

        let retirement = authority.retirementClosure
        XCTAssertFalse(retirement.frozenObservationRetirementObserved)
        XCTAssertTrue(retirement.laterRetirementClosureObserved)
        XCTAssertEqual(
            retirement.repository.revision,
            "912ca2ab8148255fa588a2a1d336b9dcb1221978")
        XCTAssertEqual(
            retirement.repository.tree,
            "3f9dbf9abb6df4bd739a9f5c17a3583afdfee9c0")
        XCTAssertEqual(retirement.workflowRunNumber, 125)
        XCTAssertEqual(retirement.checkSuiteID, 86_443_755_850)
        XCTAssertEqual(
            retirement.embeddedSourceIdentitySHA256,
            "1b2290a13d37b147c1e40cbb2e023f03175733c7fb4cf474c48fd482c5921dd9")
        XCTAssertEqual(retirement.embeddedSourceIdentityRecordCount, 488)
        XCTAssertEqual(
            retirement.preservedIndexSHA256,
            "535dbd253cc99392ec6abfcb81eac30199d372803f09d107e52dcbb48fc1d497")

        let bPath = authority.bPath
        XCTAssertEqual(bPath.initialModelSeed, 44)
        XCTAssertFalse(bPath.predecessorConfigurationWasTrainingPolicy)
        XCTAssertTrue(bPath.explicitlyReauthorizedForThisStage7Opportunity)
        XCTAssertEqual(bPath.exactFixedBatchCount, 2)
        XCTAssertEqual(
            bPath.batchTokenIDsSHA256,
            [
                "220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172",
                "af5a9f69f9cf48f051d4f8ca39577e4b24f557bbde11bf32208aa603cc17f4c3",
            ])
        XCTAssertEqual(
            bPath.batchTokenAndMaskSHA256,
            [
                "7fc5c4626fcb884976a4f5d4b8644ed087fa178027cc14a64044eb589daf5b62",
                "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e",
            ])
        XCTAssertFalse(bPath.evaluationConsumesDataCursor)
        XCTAssertEqual(bPath.evaluationBatchOrdinal, 1)

        let batch1 = [1] + (0 ..< 127).map { index in
            2 + ((index * 73 + 44) % 510)
        }
        let batch2 = [1] + (0 ..< 127).map { index in
            2 + ((index * 151 + 45) % 510)
        }
        let completionMask = [false] + Array(repeating: true, count: 127)
        func compactJSONSHA256(_ object: Any) throws -> String {
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys])
            return PrimeSHA256.hexDigest(of: data)
        }
        XCTAssertEqual(
            try compactJSONSHA256([batch1]),
            bPath.batchTokenIDsSHA256[0])
        XCTAssertEqual(
            try compactJSONSHA256([batch2]),
            bPath.batchTokenIDsSHA256[1])
        XCTAssertEqual(
            try compactJSONSHA256([completionMask]),
            bPath.completionMaskSHA256)
        XCTAssertEqual(
            try compactJSONSHA256([
                "completion_mask": [completionMask],
                "token_ids": [batch1],
            ] as [String: Any]),
            bPath.batchTokenAndMaskSHA256[0])
        XCTAssertEqual(
            try compactJSONSHA256([
                "completion_mask": [completionMask],
                "token_ids": [batch2],
            ] as [String: Any]),
            bPath.batchTokenAndMaskSHA256[1])

        func sha256UTF8(_ value: String) -> String {
            PrimeSHA256.hexDigest(of: Data(value.utf8))
        }
        for domain in authority.explicitRNG.domains {
            let key = sha256UTF8(
                "prime_rng_key_v1|44|\(domain.domainID)")
            XCTAssertEqual(key, domain.keySHA256)
            func consumption(_ before: UInt64, _ after: UInt64) -> String {
                if before == after {
                    return sha256UTF8(
                        "prime_rng_consumption_v1|\(domain.domainID)|\(key)|\(before)")
                }
                let output = sha256UTF8(
                    "prime_rng_output_v1|\(key)|\(before)")
                return sha256UTF8(
                    "prime_rng_consumption_v1|\(domain.domainID)|\(key)|\(before)|\(after)|\(output)")
            }
            XCTAssertEqual(
                consumption(0, domain.snapshotCounter),
                domain.snapshotConsumptionSHA256)
            XCTAssertEqual(
                domain.terminalCounter == domain.snapshotCounter
                    ? domain.snapshotConsumptionSHA256
                    : consumption(
                        domain.snapshotCounter, domain.terminalCounter),
                domain.terminalConsumptionSHA256)
        }
        XCTAssertEqual(
            try compactJSONSHA256([0, 1]),
            authority.dataCursor.permutationSHA256)
        XCTAssertEqual(
            try compactJSONSHA256(["stage7_fixed_row_1"]),
            authority.dataCursor.nextRowIDsSHA256)
        XCTAssertEqual(
            try compactJSONSHA256([]),
            authority.dataCursor.terminalNextRowIDsSHA256)
        XCTAssertEqual(
            sha256UTF8(authority.dataCursor.terminalNoNextBatchIdentity),
            authority.dataCursor.terminalNoNextBatchSHA256)

        XCTAssertEqual(authority.trajectory.totalTrainingStepCount, 3)
        XCTAssertFalse(
            authority.trajectory.uninterruptedAndRestoredFullStatesMayOverlap)
        XCTAssertTrue(
            authority.trajectory.uninterruptedStateDeallocatedBeforeRestore)
        XCTAssertTrue(authority.trajectory.cacheClearedBeforeRestore)
        XCTAssertTrue(
            authority.trajectory
                .optimizerMomentSemanticReloadDeferredUntilAfterDeallocation)
        XCTAssertFalse(
            authority.trajectory
                .eagerSecondMomentMaterializationDuringPublicationAuthorized)

        let counts = authority.operationCounts
        XCTAssertEqual(counts.trainingStepCount, 3)
        XCTAssertEqual(counts.v2WeightsWriteCount, 3)
        XCTAssertEqual(counts.v2InternalVerificationLoadCount, 3)
        XCTAssertEqual(counts.optimizerMomentPublishCount, 3)
        XCTAssertEqual(counts.leafPublicationCount, 12)
        XCTAssertEqual(counts.finalCommitPublicationCount, 3)
        XCTAssertEqual(counts.modelAllocationAndMaterializationCount, 5)

        XCTAssertEqual(
            authority.checkpoint.leaves.map(\.role),
            [
                "weights_v2", "optimizer_moments",
                "control_state_manifest", "commit_manifest",
            ])
        XCTAssertEqual(
            authority.checkpoint.leaves.map(\.publicationOrdinal),
            [1, 2, 3, 4])
        XCTAssertTrue(authority.checkpoint.finalCommitManifestPublishedLast)
        XCTAssertTrue(
            authority.checkpoint.finalCommitManifestIsExclusiveCommitPoint)
        XCTAssertFalse(authority.checkpoint.discoverAndTrustLoadAuthorized)
        XCTAssertTrue(
            authority.checkpoint
                .loadRequiresCallerSuppliedExactCommitBinding)
        XCTAssertFalse(authority.checkpoint.retainedCheckpointAuthorized)

        XCTAssertEqual(authority.comparison.domains.count, 18)
        XCTAssertTrue(
            authority.comparison.domains.allSatisfy { $0.exactRequired })
        XCTAssertFalse(
            authority.comparison.containerByteEqualityAloneSufficient)
        XCTAssertFalse(authority.comparison.ulpToleranceEstablishesExactResume)
        XCTAssertTrue(
            authority.comparison.measuredExactMismatchIsValidTerminalOutcome)

        XCTAssertEqual(authority.resource.ephemeralFourLeafSetCount, 3)
        XCTAssertFalse(
            authority.resource
                .uninterruptedSuccessorStateRetainedInRAMForComparison)
        XCTAssertTrue(
            authority.resource.descriptorBoundStreamingLeafComparisonRequired)
        XCTAssertTrue(authority.resource.resourceABSTAINAuthorized)
        XCTAssertFalse(authority.resource.ordinaryJobFitEstablished)

        let integrity = authority.integrity
        XCTAssertTrue(
            integrity.pureMaximalReceiptSerializationCeilingTestRequired)
        func maximalRecord(_ fields: [String]) -> [String: Any] {
            Dictionary(uniqueKeysWithValues: fields.map { field in
                let value: Any
                if field.contains("sha256") || field.contains("binding")
                    || field.contains("path") || field.contains("role")
                    || field.contains("schema") || field.contains("kind")
                    || field.contains("status") || field.contains("mode")
                {
                    value = String(repeating: "f", count: 64)
                } else if field.contains("exact") || field.contains("empty")
                    || field.contains("proved") || field.contains("used")
                    || field.contains("present") || field.contains("acquired")
                    || field.contains("executed") || field.contains("alive")
                {
                    value = true
                } else {
                    value = Int.max
                }
                return (field, value)
            })
        }
        func maximalDescriptor() -> [String: Any] {
            var record = maximalRecord(integrity.publicDescriptorTupleFields)
            record["xattr_names"] = [String]()
            return record
        }
        var authorityBindings = maximalRecord(
            integrity.authorityAndExactMainBindingFields)
        authorityBindings["ordered_parents"] = [
            String(repeating: "1", count: 40),
            String(repeating: "2", count: 40),
        ]
        var environmentBindings = maximalRecord(
            integrity.environmentAndDeviceReceiptFields)
        environmentBindings["root_and_validation_lock_bindings"] =
            (0 ..< 2).map { _ in maximalRecord(integrity.lockBindingFields) }
        var leaseAndVerifier = maximalRecord(
            integrity.leaseAndVerifierReceiptFields)
        for field in [
            "preflight_parent", "post_candidate_parent",
            "post_candidate_leaf", "verifier_parent", "verifier_leaf",
        ] {
            leaseAndVerifier[field] = maximalDescriptor()
        }
        var maximalReceipt: [String: Any] = [
            "schema": String(repeating: "s", count: 64),
            "authority_and_exact_main_bindings": authorityBindings,
            "terminal_status": "MEASURED_EXACT_MISMATCH",
            "one_shot_consumed": true,
            "candidate_byte_count":
                integrity.maximumPrivateCandidateCanonicalByteCount,
            "candidate_sha256": String(repeating: "a", count: 64),
            "terminal_byte_count":
                integrity.maximumPrivateTerminalCanonicalByteCount,
            "terminal_sha256": String(repeating: "b", count: 64),
            "environment_and_device_bindings": environmentBindings,
            "operation_counts": Dictionary(uniqueKeysWithValues:
                integrity.operationCountReceiptFields.map { ($0, Int.max) }),
            "first_mismatch_if_any": maximalRecord(
                integrity.firstMismatchReceiptFields),
            "artifact_cleanup_and_absence": maximalRecord(
                integrity.artifactCleanupReceiptFields),
            "lease_and_verifier": leaseAndVerifier,
            "semantic_path_roles_and_path_sha256":
                (0 ..< integrity.semanticPathProjectionCount).map { _ in
                    maximalRecord(integrity.semanticPathProjectionFields)
                },
        ]
        maximalReceipt["implementation_inventory"] = (0 ..< 17).map { _ in
            maximalRecord(integrity.implementationInventoryEntryFields)
        }
        maximalReceipt["comparison_domain_results"] =
            authority.comparison.domains.map { domain -> [String: Any] in
                var record = maximalRecord(
                    integrity.comparisonDomainResultFields)
                record["domain_id"] = domain.id
                record["kind"] = domain.kind
                record["path_count"] =
                    integrity.maximumTensorCatalogPathCount
                record["exact"] = true
                record["tensor_catalog_projection"] =
                    domain.sortedUniquePathsRequired
                        ? maximalRecord(integrity.tensorCatalogProjectionFields)
                        : NSNull()
                return record
            }
        maximalReceipt["resource_phases"] =
            authority.resource.requiredPhaseIDs.map { phase -> [String: Any] in
                var record = maximalRecord(
                    integrity.resourcePhaseRecordFields)
                record["phase_id"] = phase
                record["filesystem_fsid"] = maximalRecord(
                    integrity.filesystemIDFields)
                return record
            }
        maximalReceipt["checkpoint_and_comparator_bindings"] =
            (0 ..< 3).map { _ in
                var record = maximalRecord(integrity.checkpointSetBindingFields)
                record["ordered_leaf_roles"] = authority.checkpoint.leaves
                    .map(\.role)
                record["each_leaf_byte_count_and_sha256"] =
                    authority.checkpoint.leaves.map { leaf -> [String: Any] in
                        var binding = maximalRecord(
                            integrity.checkpointLeafBindingFields)
                        binding["role"] = leaf.role
                        binding["publication_ordinal"] =
                            leaf.publicationOrdinal
                        return binding
                    }
                record["external_v2_binding"] = maximalRecord(
                    integrity.externalV2BindingFields)
                return record
            }
        XCTAssertEqual(
            Set(maximalReceipt.keys),
            Set(integrity.requiredPublicReceiptFields))
        let maximalEnvironment = try XCTUnwrap(
            maximalReceipt["environment_and_device_bindings"]
                as? [String: Any])
        XCTAssertEqual(
            Set(maximalEnvironment.keys),
            Set(integrity.environmentAndDeviceReceiptFields))
        let maximalCounts = try XCTUnwrap(
            maximalReceipt["operation_counts"] as? [String: Any])
        XCTAssertEqual(
            Set(maximalCounts.keys),
            Set(integrity.operationCountReceiptFields))
        func assertExactKeys(
            _ object: Any?, _ fields: [String], _ label: String
        ) throws {
            let dictionary = try XCTUnwrap(
                object as? [String: Any], label)
            XCTAssertEqual(Set(dictionary.keys), Set(fields), label)
        }
        try assertExactKeys(
            maximalReceipt["authority_and_exact_main_bindings"],
            integrity.authorityAndExactMainBindingFields,
            "authority bindings")
        try assertExactKeys(
            maximalReceipt["first_mismatch_if_any"],
            integrity.firstMismatchReceiptFields,
            "first mismatch")
        try assertExactKeys(
            maximalReceipt["artifact_cleanup_and_absence"],
            integrity.artifactCleanupReceiptFields,
            "cleanup")
        try assertExactKeys(
            maximalReceipt["lease_and_verifier"],
            integrity.leaseAndVerifierReceiptFields,
            "lease verifier")
        let maximalLease = try XCTUnwrap(
            maximalReceipt["lease_and_verifier"] as? [String: Any])
        for field in [
            "preflight_parent", "post_candidate_parent",
            "post_candidate_leaf", "verifier_parent", "verifier_leaf",
        ] {
            try assertExactKeys(
                maximalLease[field], integrity.publicDescriptorTupleFields,
                "descriptor \(field)")
        }
        let maximalImplementations = try XCTUnwrap(
            maximalReceipt["implementation_inventory"] as? [[String: Any]])
        XCTAssertEqual(maximalImplementations.count, 17)
        for entry in maximalImplementations {
            XCTAssertEqual(
                Set(entry.keys),
                Set(integrity.implementationInventoryEntryFields))
        }
        let maximalComparisons = try XCTUnwrap(
            maximalReceipt["comparison_domain_results"] as? [[String: Any]])
        XCTAssertEqual(maximalComparisons.count, 18)
        for entry in maximalComparisons {
            XCTAssertEqual(
                Set(entry.keys),
                Set(integrity.comparisonDomainResultFields))
        }
        let maximalPhases = try XCTUnwrap(
            maximalReceipt["resource_phases"] as? [[String: Any]])
        XCTAssertEqual(maximalPhases.count, 12)
        for entry in maximalPhases {
            XCTAssertEqual(
                Set(entry.keys), Set(integrity.resourcePhaseRecordFields))
            try assertExactKeys(
                entry["filesystem_fsid"], integrity.filesystemIDFields,
                "filesystem id")
        }
        let maximalCheckpoints = try XCTUnwrap(
            maximalReceipt["checkpoint_and_comparator_bindings"]
                as? [[String: Any]])
        XCTAssertEqual(maximalCheckpoints.count, 3)
        for entry in maximalCheckpoints {
            XCTAssertEqual(
                Set(entry.keys), Set(integrity.checkpointSetBindingFields))
            try assertExactKeys(
                entry["external_v2_binding"],
                integrity.externalV2BindingFields, "external v2")
            let leaves = try XCTUnwrap(
                entry["each_leaf_byte_count_and_sha256"]
                    as? [[String: Any]])
            XCTAssertEqual(leaves.count, 4)
            for leaf in leaves {
                XCTAssertEqual(
                    Set(leaf.keys), Set(integrity.checkpointLeafBindingFields))
            }
        }
        let maximalPaths = try XCTUnwrap(
            maximalReceipt["semantic_path_roles_and_path_sha256"]
                as? [[String: Any]])
        XCTAssertEqual(maximalPaths.count, integrity.semanticPathProjectionCount)
        for entry in maximalPaths {
            XCTAssertEqual(
                Set(entry.keys), Set(integrity.semanticPathProjectionFields))
        }
        let maximalReceiptData = try JSONSerialization.data(
            withJSONObject: maximalReceipt,
            options: [.sortedKeys])
        XCTAssertLessThanOrEqual(
            maximalReceiptData.count,
            integrity.maximumPublicCanonicalByteCount)
        XCTAssertEqual(
            maximalReceiptData.count,
            integrity.maximalPublicReceiptFixtureCanonicalByteCount)
        XCTAssertNoThrow(
            try JSONSerialization.jsonObject(with: maximalReceiptData))

        let closure = authority.authorityClosure
        XCTAssertEqual(closure.exactChangedPaths.count, 5)
        XCTAssertEqual(closure.expectedRootTestCount, 62)
        XCTAssertEqual(closure.expectedIsolatedTestCount, 6)
        XCTAssertEqual(closure.expectedFocusedWholeTestCount, 68)
        XCTAssertEqual(closure.expectedLiveTestCount, 46)
        XCTAssertEqual(closure.expectedTotalTestCount, 114)
        XCTAssertEqual(closure.reviewedMainTimeoutMinutes, 60)
        XCTAssertEqual(closure.launcherInvocationCount, 0)
        XCTAssertEqual(closure.mechanicsExecutionCount, 0)
        XCTAssertEqual(closure.relevantReceiptCount, 0)
        XCTAssertEqual(closure.artifactCount, 0)

        let successor = authority.successor
        XCTAssertEqual(successor.exactChangedPathCount, 9)
        XCTAssertEqual(successor.exactChangedPaths.count, 9)
        XCTAssertEqual(
            successor.checkpointCodecMomentValueType,
            "[String: MLXArray]")
        XCTAssertEqual(
            successor.optimizerTypedMappingOwner,
            "PrimeNativeDecoderTraining")
        XCTAssertFalse(successor.rootPackageManifestMutationAuthorized)
        XCTAssertFalse(successor.rootPackageLockMutationAuthorized)
        XCTAssertFalse(successor.validationPackageLockMutationAuthorized)
        XCTAssertFalse(successor.existingMechanicsPayloadMutationAuthorized)
        XCTAssertEqual(successor.oneShotOpportunityCount, 1)
        XCTAssertEqual(successor.expectedFocusedWholeTestCount, 69)
        XCTAssertEqual(successor.expectedTotalXCTestCount, 116)
        XCTAssertEqual(successor.reviewedMainTimeoutMinutes, 120)

        XCTAssertEqual(
            authority.outcomes.allowedTerminalStatuses,
            [
                "PASS_EXACT", "MEASURED_EXACT_MISMATCH",
                "ABSTAIN_RESOURCE", "ABSTAIN_INTEGRITY",
            ])
        XCTAssertTrue(
            authority.outcomes.measuredMismatchRequiresFirstMismatchDomain)
        XCTAssertTrue(
            authority.outcomes.measuredMismatchRequiresFirstMismatchPath)
        XCTAssertFalse(authority.outcomes.measuredMismatchEstablishesResume)
        XCTAssertFalse(authority.outcomes.passAuthorizesStage8)

        XCTAssertTrue(authority.ceiling.authorityOnlyNoExecutionEvidence)
        XCTAssertTrue(authority.ceiling.stage7AuthorityEstablished)
        XCTAssertTrue(
            authority.ceiling.stage7MechanicsAuthorizedAfterGreenClosure)
        XCTAssertTrue(
            authority.ceiling
                .oneSeparatelyReviewedExactMainStage7OpportunityAuthorized)
        XCTAssertTrue(falseCeilings(authority).allSatisfy { !$0 })
        XCTAssertFalse(authority.ceiling.stage8AuthorityEstablished)
        XCTAssertFalse(authority.ceiling.stage8Authorized)

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        let canonicalSHA256 = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(canonicalSHA256, Authority.canonicalSHA256)
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical),
            authority)
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical).canonicalData(),
            canonical)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0A])))

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let fieldPaths = allDictionaryFieldPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(fieldPaths.count, 250)

        for path in valuePaths {
            let value = try XCTUnwrap(value(at: path, in: object))
            let mutated = replacingValue(
                at: path,
                in: object,
                with: distinctMutation(of: value))
            try assertRejected(mutated, label: "value \(path)")
        }
        for field in fieldPaths {
            let mutated = deletingField(
                field.key,
                fromDictionaryAt: field.parent,
                in: object)
            try assertRejected(
                mutated,
                label: "missing field \(field.parent).\(field.key)")
        }

        var injected = object
        injected["unexpected_stage7_authority_field"] = true
        let injectedData = try JSONSerialization.data(
            withJSONObject: injected,
            options: [.sortedKeys])
        XCTAssertThrowsError(try Authority.decodeCanonical(injectedData))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys])
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
    }

    private enum PathComponent: Hashable, CustomStringConvertible {
        case key(String)
        case index(Int)

        var description: String {
            switch self {
            case let .key(key): ".\(key)"
            case let .index(index): "[\(index)]"
            }
        }
    }

    private struct FieldPath {
        let parent: [PathComponent]
        let key: String
    }

    private func allValuePaths(
        in value: Any,
        prefix: [PathComponent] = []
    ) -> [[PathComponent]] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key -> [[PathComponent]] in
                let path = prefix + [.key(key)]
                let child = object[key] as Any
                if child is [String: Any] || child is [Any] {
                    return allValuePaths(in: child, prefix: path)
                }
                return [path]
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index -> [[PathComponent]] in
                let path = prefix + [.index(index)]
                let child = array[index]
                if child is [String: Any] || child is [Any] {
                    return allValuePaths(in: child, prefix: path)
                }
                return [path]
            }
        }
        return []
    }

    private func allDictionaryFieldPaths(
        in value: Any,
        prefix: [PathComponent] = []
    ) -> [FieldPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key -> [FieldPath] in
                let own = FieldPath(parent: prefix, key: key)
                return [own] + allDictionaryFieldPaths(
                    in: object[key] as Any,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryFieldPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func value(
        at path: [PathComponent],
        in root: Any
    ) -> Any? {
        var current = root
        for component in path {
            switch component {
            case let .key(key):
                guard let object = current as? [String: Any],
                      let next = object[key]
                else { return nil }
                current = next
            case let .index(index):
                guard let array = current as? [Any],
                      array.indices.contains(index)
                else { return nil }
                current = array[index]
            }
        }
        return current
    }

    private func replacingValue(
        at path: [PathComponent],
        in root: Any,
        with replacement: Any
    ) -> Any {
        guard let first = path.first else { return replacement }
        let remainder = Array(path.dropFirst())
        switch first {
        case let .key(key):
            guard var object = root as? [String: Any],
                  let child = object[key]
            else { return root }
            object[key] = replacingValue(
                at: remainder,
                in: child,
                with: replacement)
            return object
        case let .index(index):
            guard var array = root as? [Any],
                  array.indices.contains(index)
            else { return root }
            array[index] = replacingValue(
                at: remainder,
                in: array[index],
                with: replacement)
            return array
        }
    }

    private func deletingField(
        _ key: String,
        fromDictionaryAt path: [PathComponent],
        in root: Any
    ) -> Any {
        guard !path.isEmpty else {
            guard var object = root as? [String: Any] else { return root }
            object.removeValue(forKey: key)
            return object
        }
        guard let first = path.first else { return root }
        let remainder = Array(path.dropFirst())
        switch first {
        case let .key(componentKey):
            guard var object = root as? [String: Any],
                  let child = object[componentKey]
            else { return root }
            object[componentKey] = deletingField(
                key,
                fromDictionaryAt: remainder,
                in: child)
            return object
        case let .index(index):
            guard var array = root as? [Any],
                  array.indices.contains(index)
            else { return root }
            array[index] = deletingField(
                key,
                fromDictionaryAt: remainder,
                in: array[index])
            return array
        }
    }

    private func distinctMutation(of value: Any) -> Any {
        if CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID(),
           let boolean = value as? Bool
        {
            return !boolean
        }
        if let string = value as? String {
            return string + "_recursive_mutation"
        }
        if let number = value as? NSNumber {
            return number.int64Value + 1
        }
        if var array = value as? [Any] {
            array.append("recursive_mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["recursive_mutation"] = true
            return object
        }
        return "recursive_mutation"
    }

    private func assertRejected(_ object: Any, label: String) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys])
        do {
            let decoded = try JSONDecoder().decode(Authority.self, from: data)
            XCTAssertThrowsError(
                try decoded.validateExactV1(),
                "accepted \(label)")
        } catch {
            return
        }
    }

    private func falseCeilings(_ authority: Authority) -> [Bool] {
        let ceiling = authority.ceiling
        return [
            ceiling.processExecutionAuthorizedByThisClosure,
            ceiling.filesystemIOAuthorizedByThisClosure,
            ceiling.mlxImportedByThisClosure,
            ceiling.metalImportedByThisClosure,
            ceiling.modelAllocationAuthorizedByThisClosure,
            ceiling.trainingExecutionAuthorizedByThisClosure,
            ceiling.checkpointReadAuthorizedByThisClosure,
            ceiling.checkpointWriteAuthorizedByThisClosure,
            ceiling.launcherInvocationAuthorizedByThisClosure,
            ceiling.workflowTimeoutMutationAuthorizedByThisClosure,
            ceiling.stage7ExecutionObserved,
            ceiling.native300MTrajectoryResumeEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.durableCheckpointAvailabilityEstablished,
            ceiling.checkpointDurabilityEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.additionalExecutionAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.ordinaryJobFitEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage8AuthorityEstablished,
            ceiling.stage8Authorized,
        ]
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "prime_native_decoder_b_specific_native300m_resource_witness_authority_v1")
        XCTAssertEqual(
            authority.repository.authorityBaseRevision,
            "7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4")
        XCTAssertEqual(authority.repository.retirementWorkflowRunNumber, 119)
        XCTAssertEqual(authority.repository.retirementRootTestCount, 59)
        XCTAssertEqual(authority.repository.retirementTotalTestCount, 111)
        XCTAssertEqual(
            authority.repository.authorityClosureExactChangedPaths.count, 5)
        XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 8)

        XCTAssertTrue(authority.stage5Pass.stage5AssayClearanceEstablished)
        XCTAssertTrue(
            authority.stage5Pass.repeatedSameDeviceBPathDeterminismEstablished)
        XCTAssertTrue(
            authority.stage5Pass.exactSameDeviceBPathGradientBytesEstablished)
        XCTAssertTrue(authority.stage5Pass.outerLeaseParentGuardFailed)
        XCTAssertFalse(authority.stage5Pass.failedGuardConjunctIdentified)
        XCTAssertFalse(
            authority.stage5Pass.localAPFSLinkCountReproductionBoundAsCause)
        XCTAssertTrue(authority.stage5Pass.receiptEstablishedBeforeOuterFailure)
        XCTAssertFalse(
            authority.stage5Pass.launcherPostReceiptCompletionEstablished)

        XCTAssertTrue(authority.historicalStage6.resourceClearanceEstablished)
        XCTAssertTrue(authority.historicalStage6.remainsHistoricalEvidence)
        XCTAssertFalse(authority.historicalStage6.appliesToCurrentBPath)
        XCTAssertFalse(authority.historicalStage6.mayBeUsedAsBPeakPrediction)
        XCTAssertFalse(authority.historicalStage6.mayBeUsedAsBResourceClearance)

        XCTAssertEqual(
            authority.bPath.algorithmID,
            "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1")
        XCTAssertEqual(
            authority.bPath.selectorRawValue,
            "flattened_dense_one_hot_matmul_input_embedding_v1")
        XCTAssertEqual(
            authority.bPath.trainingLogitsAPI,
            "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1")
        XCTAssertTrue(authority.bPath.packageOnlySurfaceRequired)
        XCTAssertFalse(authority.bPath.publicDecoderAPIAdded)

        XCTAssertEqual(authority.configuration.vocabularySize, 512)
        XCTAssertEqual(authority.configuration.modelWidth, 1_024)
        XCTAssertEqual(authority.configuration.layerCount, 24)
        XCTAssertEqual(authority.configuration.uniqueParameterCount, 271_107_072)
        XCTAssertEqual(authority.configuration.batchTokenIDs.count, 1)
        XCTAssertEqual(authority.configuration.batchTokenIDs[0].count, 128)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try JSONEncoder().encode(
                    authority.configuration.batchTokenIDs)),
            authority.configuration.batchTokenIDsSHA256)
        XCTAssertEqual(
            authority.configuration.batchTokenIDsSHA256,
            "220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172")
        XCTAssertEqual(
            authority.configuration.batchTokenIDsSHA256PreimageRule,
            "sha256_of_compact_json_utf8_rank_two_batch_token_ids")
        XCTAssertEqual(authority.configuration.tokenIDStorageDType, "int32")
        XCTAssertEqual(
            authority.configuration.completionMaskStorageDType, "bool")
        XCTAssertEqual(
            authority.configuration.flattenedTokenColumnShape, [128, 1])
        XCTAssertEqual(authority.configuration.vocabularyRowShape, [1, 512])
        XCTAssertEqual(authority.configuration.denseOneHotShape, [128, 512])
        XCTAssertEqual(
            authority.configuration.denseOneHotLogicalByteCount, 262_144)
        XCTAssertEqual(
            authority.configuration.flattenedDenseEmbeddingShape,
            [128, 1_024])
        XCTAssertEqual(
            authority.configuration.restoredDenseEmbeddingShape,
            [1, 128, 1_024])
        XCTAssertTrue(
            authority.configuration.trainingLogitsUsesCausalAttentionMask)
        XCTAssertEqual(authority.configuration.crossEntropyWeights, "nil")
        XCTAssertEqual(authority.configuration.crossEntropyAxis, -1)
        XCTAssertEqual(
            authority.configuration
                .crossEntropyLabelSmoothingFloat32BitPattern,
            0)
        XCTAssertTrue(
            authority.configuration.valueAndGradClosureReturnsOnlyScalarLoss)
        XCTAssertFalse(
            authority.resourceEnvelope.analyticBIncrementalBytesArePeakEvidence)
        XCTAssertFalse(
            authority.resourceEnvelope
                .analyticBIncrementalBytesAreClearanceEvidence)
        XCTAssertEqual(authority.inheritedResourceContract.mlxEnableTF32, "0")
        XCTAssertEqual(
            authority.inheritedResourceContract.exactMLXRevision,
            "d37885a278f1c37484a94d0f401a418735e66519")
        XCTAssertTrue(
            authority.inheritedResourceContract
                .phaseAndLiveSetRulesInheritedWithoutChange)
        XCTAssertEqual(
            authority.inheritedResourceContract.mlxPeakMemoryResetCount, 1)

        XCTAssertEqual(authority.futureExecution.modelAllocationCount, 1)
        XCTAssertEqual(
            authority.futureExecution.directPackageBTrainingLogitsAPICallCount,
            1)
        XCTAssertEqual(
            authority.futureExecution.maintainedGatherTrainingLogitsCount, 0)
        XCTAssertEqual(
            authority.futureExecution.tinyTrainingSelectorInvocationCount, 0)
        XCTAssertEqual(
            authority.futureExecution
                .inputEmbeddingForwardPairDiagnosticInvocationCount,
            0)
        XCTAssertEqual(
            authority.futureExecution.checkedEvaluationBarrierCount, 6)
        XCTAssertEqual(
            authority.futureExecution.gpuSynchronizationBarrierCount, 6)
        XCTAssertEqual(
            authority.futureExecution
                .orderedCheckedEvaluationAndSynchronizationBarriers.count,
            6)
        XCTAssertTrue(
            authority.futureExecution.resourceOperationCountsArePassPathExact)
        XCTAssertFalse(authority.futureExecution.retryAuthorized)
        XCTAssertFalse(authority.futureExecution.rerunAuthorized)

        let integrity = authority.leaseReceiptIntegrity
        XCTAssertEqual(
            integrity.preflightParentRequiredTupleFields,
            [
                "physical_path", "file_type", "device_id", "inode", "uid",
                "gid", "mode", "security_flags", "acl_entry_count",
                "allowed_extended_attribute_names",
            ])
        XCTAssertFalse(
            integrity.parentLinkCountUsedAsStableIdentityAfterChildCreation)
        XCTAssertTrue(integrity.parentLinkCountObserved)
        XCTAssertFalse(integrity.parentLinkCountMustBePositive)
        XCTAssertEqual(
            integrity.leaseInventoryComparisonRule,
            "unordered_exact_basename_set_equals_{device-0.lock}")
        XCTAssertEqual(integrity.parentRequiredFileType, "directory")
        XCTAssertEqual(integrity.parentRequiredMode, "0700")
        XCTAssertEqual(
            integrity.leaseFileDescriptorOpenFlags,
            ["O_RDWR", "O_CREAT", "O_NOFOLLOW", "O_CLOEXEC"])
        XCTAssertTrue(
            integrity.supervisorIsSoleLeaseOwnerBeforeExplicitRelease)
        XCTAssertTrue(
            integrity.supervisorHoldsLeaseThroughCandidateAndDeviceMLXPostflight)
        XCTAssertEqual(integrity.releaseVerifierExecChildCount, 1)
        XCTAssertTrue(integrity.releaseVerifierMustAcquireReleaseAndExitZero)
        XCTAssertFalse(integrity.launcherUnlinksLeaseFile)
        XCTAssertFalse(integrity.launcherRemovesLeaseParent)
        XCTAssertTrue(
            integrity.persistentLeaseRootAndLeafAreIntentionalLeaseSemantics)
        XCTAssertFalse(integrity.persistentLeaseRootAndLeafAreRetainedArtifact)
        XCTAssertFalse(integrity.internalCandidateIsResultEvidence)
        XCTAssertEqual(integrity.workerPublicCanonicalReceiptCount, 0)
        XCTAssertEqual(integrity.supervisorPublicCanonicalReceiptCount, 0)
        XCTAssertEqual(integrity.launcherPublicCanonicalReceiptMaximumCount, 1)
        XCTAssertEqual(
            integrity.validTerminalClassificationPublicReceiptCount, 1)
        XCTAssertTrue(integrity.publicPrefixCountsAreAllOutcomeCeilings)
        XCTAssertTrue(
            integrity.anyPublicReceiptRequiresTerminalClassificationClosure)
        XCTAssertTrue(integrity.anyPublicReceiptRequiresSupervisorTermination)
        XCTAssertTrue(integrity.passRequiresValidatedScientificCandidate)
        XCTAssertTrue(
            integrity
                .passRequiresLeaseReleaseVerifierAndPersistentIdentityProof)
        XCTAssertTrue(integrity.passRequiresAllPostflights)
        XCTAssertTrue(integrity.passRequiresOuterIntegritySuccess)
        XCTAssertTrue(
            integrity.resourceAbstainMayBeSupervisorSynthesizedWithoutCandidate)
        XCTAssertTrue(
            integrity
                .resourceAbstainMayCompleteWithoutReleaseVerifierOnlyWhenNoLeaseWasAcquired)
        XCTAssertTrue(
            integrity
                .resourceAbstainAfterLeaseAcquisitionRequiresReleaseVerifier)
        XCTAssertTrue(
            integrity.resourceAbstainRequiresApplicableLeaseDispositionProof)
        XCTAssertTrue(
            integrity.resourceAbstainRequiresSafeOuterPublicationClosure)
        XCTAssertFalse(integrity.integrityAbstainRequiresOuterIntegritySuccess)
        XCTAssertTrue(
            integrity
                .publicReceiptEmissionAndFlushAreFinalFallibleLauncherAction)
        XCTAssertTrue(integrity.launcherExitTrapsClearedBeforePublicReceipt)
        XCTAssertEqual(
            integrity.finalPublicReceiptCommand,
            "exec /usr/bin/printf '%s\\n' \"$public_line\"")
        XCTAssertTrue(integrity.noAuthoredActionAfterFinalPublicReceiptExec)
        XCTAssertFalse(integrity.launcherOKMarkerAfterPublicReceipt)
        XCTAssertFalse(integrity.localAPFSDiagnosticBoundAsRun117Cause)
        XCTAssertEqual(integrity.operationalProbeRoleProcessInvocationCount, 3)
        XCTAssertEqual(integrity.primeLeaseAcquireAttemptCount, 2)
        XCTAssertEqual(integrity.primeLeaseAcquireSuccessCount, 2)
        XCTAssertEqual(integrity.primeLeaseReleaseCallCount, 2)
        XCTAssertEqual(integrity.individualFlockSyscallSuccessClaimCount, 0)
        XCTAssertEqual(integrity.individualCloseSyscallSuccessClaimCount, 0)
        XCTAssertEqual(
            integrity.parentAllowedExtendedAttributeNames,
            ["com.apple.provenance"])
        XCTAssertEqual(integrity.integrityFailureReceiptStatus, "ABSTAIN_INTEGRITY")
        XCTAssertTrue(
            integrity.integrityFailureReceiptRequiresValidatedCandidate)
        XCTAssertTrue(
            integrity
                .integrityFailureReceiptPreservesCandidateScientificStatus)
        XCTAssertTrue(
            integrity.integrityFailureReceiptRequiresFirstFailedGuard)
        XCTAssertTrue(
            integrity.integrityFailureReceiptRequiresActualMetadataAvailability)
        XCTAssertTrue(integrity.integrityFailureReceiptActualMetadataMayBeNull)
        XCTAssertTrue(
            integrity
                .integrityFailureReceiptNullActualMetadataRequiresUnavailableReasonOrErrno)
        XCTAssertEqual(integrity.orderedIntegrityGuardIDs.count, 18)
        XCTAssertFalse(
            integrity.integrityFailureReceiptEstablishesResourceClearance)

        XCTAssertEqual(authority.suite.authorityRootTestCount, 60)
        XCTAssertEqual(authority.suite.authorityTotalXCTestCount, 112)
        XCTAssertEqual(authority.suite.futureTotalXCTestCount, 114)
        XCTAssertEqual(authority.suite.authorityMaintainedRuntimeReceiptCount, 1)
        XCTAssertEqual(authority.suite.authorityTokenizerReceiptCount, 1)
        XCTAssertEqual(authority.suite.authorityOriginalStage5ReceiptCount, 0)
        XCTAssertEqual(authority.suite.authorityReplacementStage5ReceiptCount, 0)
        XCTAssertEqual(authority.suite.authorityHistoricalStage6ReceiptCount, 0)
        XCTAssertEqual(authority.suite.authorityBResourceWitnessReceiptCount, 0)
        XCTAssertEqual(
            authority.suite.futureBSuccessorAggregateInvocationCount, 3)
        XCTAssertEqual(authority.suite.futureBPublicReceiptMaximumCount, 1)
        XCTAssertEqual(authority.suite.futureMaintainedRuntimeReceiptCount, 1)
        XCTAssertEqual(authority.suite.futureTokenizerReceiptCount, 1)
        XCTAssertEqual(authority.suite.futureOriginalStage5ReceiptCount, 0)
        XCTAssertEqual(authority.suite.futureReplacementStage5ReceiptCount, 0)
        XCTAssertEqual(authority.suite.futureHistoricalStage6ReceiptCount, 0)
        XCTAssertEqual(
            authority.successorManifest.successorReviewedJobTimeoutMinutes,
            90)
        XCTAssertTrue(
            authority.successorManifest
                .successorReviewedOnlyTimeoutMutationAuthorized)
        XCTAssertTrue(
            authority.successorManifest.retirementMustRestoreReviewedTimeout)
        XCTAssertEqual(
            authority.transitions.publicStatusDomain,
            ["ABSTAIN", "ABSTAIN_INTEGRITY", "PASS"])
        XCTAssertEqual(
            authority.transitions.abstainClassifications,
            [
                "worker_spawn_failure", "preflight_floor", "lease_busy",
                "oom", "timeout", "signal", "nonfinite",
                "topology_dtype", "no_update",
            ])
        XCTAssertEqual(
            authority.transitions.noPublicReceiptClassifications,
            [
                "executor_receipt_drift", "malformed_private_packet",
                "unsafe_private_packet", "unknown_integrity_guard",
                "canonicalization_failure", "publication_failure",
            ])
        XCTAssertEqual(authority.transitions.classificationDecisionRules.count, 4)
        XCTAssertTrue(
            authority.transitions.passEstablishesBSpecificResourceWitness)
        XCTAssertTrue(
            authority.transitions.passEstablishesBSpecificResourceClearance)
        XCTAssertFalse(authority.transitions.passAuthorizesStage7)
        XCTAssertTrue(
            authority.transitions.abstainEstablishesTerminalBResourceObservation)
        XCTAssertFalse(
            authority.transitions.abstainEstablishesBSpecificResourceWitness)
        XCTAssertFalse(
            authority.transitions.abstainEstablishesBSpecificResourceClearance)
        XCTAssertFalse(
            authority.transitions.malformedOrUnsafePrivatePacketEmitsPublicReceipt)
        XCTAssertEqual(
            authority.transitions.integrityAbstainStatus,
            "ABSTAIN_INTEGRITY")
        XCTAssertFalse(
            authority.transitions.integrityAbstainEstablishesResourceClearance)

        let ceiling = authority.ceiling
        XCTAssertTrue(ceiling.authorityOnlyNoWitnessEvidence)
        XCTAssertTrue(ceiling.stage5AssayClearanceEstablished)
        XCTAssertTrue(
            ceiling.historicalStage6ResourceClearanceRemainsEstablished)
        XCTAssertFalse(
            ceiling.historicalStage6ResourceClearanceAppliesToBPath)
        XCTAssertTrue(
            ceiling
                .bSpecificNative300MResourceWitnessMechanicsAuthorizedAfterGreenClosure)
        XCTAssertFalse(ceiling.bSpecificNative300MResourceWitnessExecuted)
        XCTAssertFalse(ceiling.bSpecificNative300MResourceWitnessEstablished)
        XCTAssertTrue(ceiling.stage7RequiresBSpecificNative300MResourceWitness)
        XCTAssertTrue(ceiling.stage7RequiresSeparateAuthorityAfterWitness)
        XCTAssertFalse(ceiling.stage7AuthorityEstablished)
        XCTAssertFalse(ceiling.stage7Authorized)

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical), Authority.canonicalSHA256)
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let arrayPaths = allArrayPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 400)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(arrayPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 300)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))")
            if let loose = try? JSONDecoder().decode(
                Authority.self, from: mutatedData), loose != authority
            {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }
            _ = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }),
                label: "null \(pathLabel(path))")
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))")
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 300)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(in: object, at: path) { value in
                var dictionary = value as! [String: Any]
                dictionary["unknown_b_resource_authority_field_\(index)"] = true
                return dictionary
            }
            let data = try assertCanonicalRejects(
                unknown, label: "unknown \(pathLabel(path))")
            XCTAssertEqual(
                try JSONDecoder().decode(Authority.self, from: data),
                authority)
        }

        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(in: object, at: path) { value in
                var array = value as! [Any]
                guard array.count >= 2 else { return array }
                for left in 0 ..< array.count {
                    for right in (left + 1) ..< array.count
                    where canonicalJSONFragment(array[left])
                        != canonicalJSONFragment(array[right])
                    {
                        array.swapAt(left, right)
                        didReorder = true
                        return array
                    }
                }
                return array
            }
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered, label: "reordered \(pathLabel(path))")
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 10)
        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(
            sourceText.split(separator: "\n").filter {
                $0.hasPrefix("import ")
            }.map(String.init),
            ["import Foundation"])
        for forbidden in [
            "import CoreGraphics", "import Darwin", "import Metal",
            "import MLX", "import MLXNN", "import MLXOptimizers",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn", "execve(", "Memory.snapshot(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map { component in
            switch component {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }.joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(
                    in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else { return transform(value) }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!, at: remainder, with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index], at: remainder, with: transform)
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value")
        return value
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(slashEscaped.utf8)))

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(reordered.utf8)))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicate.startIndex))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(duplicate.utf8)))
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

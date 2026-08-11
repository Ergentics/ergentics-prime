// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1

    func testFrozenV1CanonicalCodableMutationAndSourceBoundary() throws {
        let authority = Authority.frozenV1

        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.currentArc,
            PrimeNativeDecoderTrajectoryExactResumeStageV1
                .trajectorySchemaAndPureContract.rawValue
        )
        XCTAssertEqual(authority.allowedSourceImports, ["Foundation"])
        XCTAssertFalse(authority.mlxImported)
        XCTAssertFalse(authority.mlxNNImported)
        XCTAssertFalse(authority.mlxOptimizersImported)
        XCTAssertFalse(authority.dependencyManifestMutationAuthorized)
        XCTAssertFalse(authority.processExecutionAuthorized)
        XCTAssertFalse(authority.filesystemIOAuthorized)

        let repository = authority.authoritativeRepositoryIdentity
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "dd13f4b3d37610dfe6ecd35e5612e87b0df1ada28836fc111a2bbdc4ed3cb6bb"
        )
        XCTAssertTrue(
            repository.embeddedSourceIdentityIsCanonicalSourceClosureBinding
        )
        XCTAssertEqual(repository.sourceClosureFileCount, 414)
        XCTAssertEqual(repository.sourceClosureRecordCount, 413)
        XCTAssertEqual(repository.sourceClosureDirectoryCount, 132)
        XCTAssertEqual(repository.sourceClosureCanonicalByteCount, 83_251)
        XCTAssertTrue(
            repository
                .predecessorSourceClosureCoversEveryRepositoryInputSourceUsedByThisDesign
        )
        XCTAssertTrue(
            repository.activeGateRecomputesAndRequiresExactSourceClosure
        )
        XCTAssertTrue(repository.currentArcSourceClosureRefreshRequired)
        XCTAssertFalse(
            repository.unboundOrRuntimeDiscoveredInputSourceAuthorized
        )

        XCTAssertTrue(
            authority
                .predecessorObservations.seed42AuthorityExhausted
        )
        XCTAssertTrue(
            authority.predecessorObservations
                .seed42PublicWriteReturnSourceInferred
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .seed42PublicWriteCompletionCountSourceInferred,
            1
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .seed42PublicLoadCompletionCountSourceInferred,
            0
        )
        XCTAssertFalse(
            authority.predecessorObservations.seed42TypedReceiptEmitted
        )
        XCTAssertFalse(
            authority.predecessorObservations.seed42ArtifactBytesBound
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed42ExternalBindingFieldsIndependentlyBound
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed42ArtifactAvailabilityEstablished
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed42ArtifactRetentionEstablished
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed42CheckpointAdmissionGranted
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed42OriginalArtifactRecoverable
        )
        XCTAssertTrue(
            authority.predecessorObservations
                .seed42RegenerationWouldBeNewExecutionNotRecovery
        )
        XCTAssertTrue(
            authority.predecessorObservations.seed43ExternalBindingBound
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .seed43PublicWriteCompletionCountObserved,
            1
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .seed43FreshPublicLoadCompletionCountObserved,
            1
        )
        XCTAssertTrue(
            authority.predecessorObservations.seed43VerifiedArtifactDeleted
        )
        XCTAssertTrue(
            authority.predecessorObservations
                .seed43ParentVerifiedLiteralCleanupCompleted
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43ArtifactAvailableBeyondProcess
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43ArtifactRetentionEstablished
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43ArtifactProvenanceEstablished
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43CheckpointAdmissionGranted
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43TrainingResumeEstablished
        )
        XCTAssertFalse(
            authority.predecessorObservations
                .seed43OriginalArtifactRecoverable
        )
        XCTAssertTrue(
            authority.predecessorObservations
                .seed43RegenerationWouldBeNewExecutionNotRecovery
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .usableParentCheckpointCount,
            0
        )
        XCTAssertTrue(
            authority.predecessorObservations
                .neitherObservationSuppliesAvailableResumeParent
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .cumulativePublicWriteCompletionCountSourceInferredAfterSeed43Success,
            2
        )
        XCTAssertEqual(
            authority.predecessorObservations
                .cumulativePublicLoadCompletionCountSourceInferredAfterSeed43Success,
            1
        )

        XCTAssertFalse(
            authority.externalDependencySourcesIncludedInRepositoryClosure
        )
        XCTAssertTrue(
            authority
                .everyExternalDependencyClaimUsedByThisDesignHasExactSourceBinding
        )
        let dependencyBindings = authority.externalDependencySourceBindings
        XCTAssertEqual(
            dependencyBindings.map(\.path),
            [
                "Source/MLX/State.swift",
                "Source/MLX/Protocols.swift",
                "Source/MLX/MLXArray.swift",
                "Source/MLXOptimizers/Optimizers.swift",
                "Source/MLXNN/Embedding.swift",
                "Source/MLXOptimizers/AdamOptimizerState.swift",
                "Source/MLXOptimizers/AdamOptimizerState.swift",
                "Source/MLX/MLXArray+Indexing.swift",
                "mlx/c/ops.cpp",
                "mlx/primitives.cpp",
                "mlx/backend/metal/kernels/indexing/scatter.h",
                "mlx/backend/metal/kernels/indexing/scatter_axis.h",
            ]
        )
        XCTAssertEqual(dependencyBindings.count, 12)
        XCTAssertEqual(
            Set(
                dependencyBindings.map { binding in
                    "\(binding.repository)@\(binding.revision):\(binding.path)"
                }
            ).count,
            12
        )
        XCTAssertEqual(Set(dependencyBindings.map(\.claimScope)).count, 12)
        XCTAssertTrue(
            dependencyBindings.allSatisfy { binding in
                binding.gitMode == "100644"
                    && binding.gitBlob.utf8.count == 40
                    && isLowercaseHex(binding.gitBlob)
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && isLowercaseHex(binding.sha256)
                    && !binding.claimScope.isEmpty
            }
        )
        let dependencyRelationships =
            authority.externalDependencyRevisionRelationships
        XCTAssertEqual(dependencyRelationships.count, 2)
        XCTAssertEqual(
            dependencyRelationships.map(\.parentRepository),
            Array(repeating: "Ergentics/ergentics-mlx-swift", count: 2)
        )
        XCTAssertEqual(
            dependencyRelationships.map(\.parentRevision),
            Array(
                repeating:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                count: 2
            )
        )
        XCTAssertEqual(
            dependencyRelationships.map(\.childPath),
            ["Source/Cmlx/mlx", "Source/Cmlx/mlx-c"]
        )
        XCTAssertEqual(
            dependencyRelationships.map(\.gitMode),
            ["160000", "160000"]
        )
        XCTAssertEqual(
            dependencyRelationships.map(\.childRepository),
            ["ml-explore/mlx", "ml-explore/mlx-c"]
        )
        XCTAssertEqual(
            dependencyRelationships.map(\.childRevision),
            [
                "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                "0726ca922fc902c4c61ef9c27d94132be418e945",
            ]
        )

        XCTAssertEqual(
            authority.v2Boundary.stateScope,
            "model_parameters_only_no_optimizer_rng_cursor_or_cache"
        )
        XCTAssertFalse(authority.v2Boundary.optimizerStateIncluded)
        XCTAssertFalse(authority.v2Boundary.rngStateIncluded)
        XCTAssertFalse(authority.v2Boundary.dataCursorIncluded)
        XCTAssertFalse(authority.v2Boundary.kvCacheStateIncluded)
        XCTAssertTrue(
            authority.v2Boundary
                .exactExistingV2ByteIdentityMustRemainUnchanged
        )
        XCTAssertFalse(
            authority.v2Boundary.wideningOrReinterpretingV2Authorized
        )

        XCTAssertEqual(
            authority.optimizerStateDesign.trainableParameterPathCount,
            218
        )
        XCTAssertEqual(
            authority.optimizerStateDesign.configurationScope,
            "tiny_cpu_mechanics_only_not_native300m_training"
        )
        XCTAssertEqual(
            authority.optimizerStateDesign.typedRestoreIntroductionRevision,
            "68904d54b72871f26968261ae05d4fbb7c5e3142"
        )
        XCTAssertEqual(
            authority.optimizerStateDesign.currentTypedRestoreRuntimeRevision,
            authority.optimizerStateDesign.rootPinnedMLXRevision
        )
        XCTAssertTrue(
            authority.optimizerStateDesign
                .typedRestoreIntroductionIsAncestorOfCurrentRevision
        )
        XCTAssertFalse(
            authority.optimizerStateDesign.native300MHyperparametersResolved
        )
        XCTAssertFalse(
            authority.optimizerStateDesign
                .native300MHyperparameterSelectionAuthorized
        )
        XCTAssertEqual(
            authority.optimizerStateDesign.totalMomentTensorCount,
            436
        )
        XCTAssertEqual(
            authority.optimizerStateDesign.totalMomentLogicalByteCount,
            2_168_856_576
        )
        XCTAssertTrue(
            authority.optimizerStateDesign
                .explicitGlobalOptimizerStepRequired
        )
        XCTAssertTrue(
            authority.randomStateDesign
                .primeOwnedExplicitKeyCounterRequired
        )
        XCTAssertFalse(
            authority.randomStateDesign
                .dedicatedSupportedTypedExactStateImporterAvailable
        )
        XCTAssertFalse(
            authority.randomStateDesign
                .innerStateArrayContainerIsDirectStateReference
        )
        XCTAssertTrue(
            authority.randomStateDesign
                .innerStateElementsCanMutateStateViaUnderscoredUpdate
        )
        XCTAssertTrue(
            authority.randomStateDesign
                .publicUnderscoredMLXArrayUpdateInternalAvailable
        )
        XCTAssertTrue(
            authority.randomStateDesign
                .underscoredMutationDocumentedAsImplementationDetail
        )
        XCTAssertFalse(
            authority.randomStateDesign
                .underscoredMutationAuthorizedForTrajectoryResume
        )
        XCTAssertFalse(
            authority.randomStateDesign
                .underscoredMutationReliabilityEstablishedForTrajectoryResume
        )
        XCTAssertFalse(
            authority.randomStateDesign.implicitGlobalRandomStateAuthorized
        )
        XCTAssertEqual(
            authority.randomStateDesign.requiredDomainIDs.count,
            4
        )
        XCTAssertTrue(
            authority.blockers.contains(
                .mlxRandomStateHasNoDedicatedSupportedTypedExactImporter
            )
        )
        XCTAssertEqual(
            authority.dataCursorDesign.accumulationPhaseAtSnapshot,
            0
        )
        XCTAssertEqual(
            authority.dataCursorDesign
                .pendingGradientTensorCountAtSnapshot,
            0
        )
        XCTAssertEqual(
            authority.dataCursorDesign.pendingPrefetchItemCountAtSnapshot,
            0
        )
        XCTAssertEqual(
            authority.dataCursorDesign.kvCacheEntryCountAtSnapshot,
            0
        )
        XCTAssertTrue(
            authority.dataCursorDesign.cursorPointsToNextUnconsumedBatch
        )

        XCTAssertFalse(
            authority.trainEvaluateSurfaceDesign
                .surfaceEstablishedByThisAuthority
        )
        XCTAssertFalse(
            authority.determinismDesign.exactMetalGradientBytesEstablished
        )
        XCTAssertTrue(
            authority.determinismDesign
                .sameDeviceRepeatedUninterruptedAndResumedTrialsRequired
        )
        XCTAssertFalse(
            authority.resourceDesign
                .native300MOneStepTrainingFitsOrdinary45MinuteJobEstablished
        )
        XCTAssertTrue(authority.resourceDesign.separateResourceOnlyProbeRequired)

        XCTAssertEqual(
            authority.trajectoryCheckpointSchema.leafInventory.map(\.role),
            PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1.allCases
        )
        XCTAssertEqual(
            authority.trajectoryCheckpointSchema.leafInventory.map(
                \.publicationOrdinal
            ),
            [1, 2, 3, 4]
        )
        XCTAssertTrue(
            authority.trajectoryCheckpointSchema
                .finalCommitManifestPublishedLast
        )
        XCTAssertTrue(
            authority.trajectoryCheckpointSchema
                .finalCommitManifestIsExclusiveCommitPoint
        )
        XCTAssertFalse(
            authority.trajectoryCheckpointSchema
                .partialPrecommitLeavesAreAuthoritative
        )
        XCTAssertFalse(
            authority.trajectoryCheckpointSchema.discoverAndTrustLoadAuthorized
        )

        let stages = authority.orderedStages
        XCTAssertEqual(
            stages.map(\.stage),
            PrimeNativeDecoderTrajectoryExactResumeStageV1.allCases
        )
        XCTAssertNil(stages[0].requiredCompletedPredecessorStage)
        for index in stages.indices.dropFirst() {
            XCTAssertEqual(
                stages[index].requiredCompletedPredecessorStage,
                stages[index - 1].stage
            )
        }
        XCTAssertTrue(
            stages.allSatisfy { stage in
                stage.separatelyAuthorizedSuccessorRequired
                    && !stage.implementationAuthorizedByThisDesignAuthority
                    && !stage
                        .trainingExecutionAuthorizedByThisDesignAuthority
                    && !stage.artifactIOAuthorizedByThisDesignAuthority
                    && !stage.retainedArtifactAuthorizedByThisDesignAuthority
            }
        )
        XCTAssertTrue(
            executionAndAdmissionCeilings(authority).allSatisfy { !$0 }
        )
        XCTAssertEqual(authority.status.prefix(7), "ABSTAIN")

        requireSendable(Authority.self)
        let canonical = try PrimeCanonicalJSON.encode(authority)
        let canonicalSHA256 = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalSHA256,
            "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589"
        )
        let decoded = try PrimeCanonicalJSON.decode(
            Authority.self,
            from: canonical
        )
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let fieldPaths = allDictionaryFieldPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(fieldPaths.count, 200)

        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            try assertDecodeOrValidationRejects(
                mutated,
                label: "mutated \(pathLabel(path))"
            )

            let null = replacingValue(
                in: object,
                at: path,
                with: { _ in NSNull() }
            )
            try assertDecodeOrValidationRejects(
                null,
                label: "null \(pathLabel(path))"
            )
        }

        for path in fieldPaths {
            let missing = removingValue(in: object, at: path)
            try assertDecodeOrValidationRejects(
                missing,
                label: "missing \(pathLabel(path))"
            )
        }

        var injectedOptional = object
        var encodedStages = try XCTUnwrap(
            injectedOptional["orderedStages"] as? [[String: Any]]
        )
        encodedStages[0]["requiredCompletedPredecessorStage"] =
            PrimeNativeDecoderTrajectoryExactResumeStageV1
                .retainedTrajectoryProvenanceAndAdmission.rawValue
        injectedOptional["orderedStages"] = encodedStages
        try assertDecodeOrValidationRejects(
            injectedOptional,
            label: "injected omitted first-stage predecessor"
        )

        var unknown = object
        unknown["unknown_future_execution_authority"] = true
        let unknownData = try JSONSerialization.data(
            withJSONObject: unknown,
            options: [.sortedKeys]
        )
        let plainDecoded = try JSONDecoder().decode(
            Authority.self,
            from: unknownData
        )
        XCTAssertEqual(plainDecoded, authority)
        XCTAssertNoThrow(try plainDecoded.validateExactV1())
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Authority.self,
                from: unknownData
            )
        )
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key):
                return key
            case let .index(index):
                return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path]
                    + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path]
                    + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryFieldPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path]
                    + allDictionaryFieldPaths(
                        in: object[key]!,
                        prefix: path
                    )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return allDictionaryFieldPaths(
                    in: array[index],
                    prefix: path
                )
            }
        }
        return []
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else {
            return transform(value)
        }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform
            )
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform
            )
            return array
        }
    }

    private func removingValue(
        in value: Any,
        at path: JSONPath
    ) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(
                    in: object[key]!,
                    at: remainder
                )
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder
                )
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "__mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.uint64Value + 1)
        }
        if var array = value as? [Any] {
            if let first = array.first {
                array.append(first)
            } else {
                array.append("__mutation")
            }
            return array
        }
        if let object = value as? [String: Any],
           let key = object.keys.sorted().first
        {
            return replacingValue(
                in: object,
                at: [.key(key)],
                with: mutateJSONValue
            )
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    private func assertDecodeOrValidationRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        do {
            let decoded = try JSONDecoder().decode(
                Authority.self,
                from: data
            )
            XCTAssertThrowsError(
                try decoded.validateExactV1(),
                label,
                file: file,
                line: line
            )
        } catch {
            return
        }
    }

    private func executionAndAdmissionCeilings(
        _ authority: Authority
    ) -> [Bool] {
        [
            authority.processExecutionAuthorized,
            authority.filesystemIOAuthorized,
            authority.executableTrainingCodeAuthorized,
            authority.trainEvaluateImplementationAuthorized,
            authority.modelAllocationAuthorized,
            authority.decoderForwardAuthorized,
            authority.lossEvaluationAuthorized,
            authority.backwardAuthorized,
            authority.optimizerStepAuthorized,
            authority.randomSamplingAuthorized,
            authority.checkpointReadAuthorized,
            authority.checkpointWriteAuthorized,
            authority.artifactRootMutationAuthorized,
            authority.liveLauncherAuthorized,
            authority.workflowTimeoutChangeAuthorized,
            authority.workflowCheckoutDepthChangeAuthorized,
            authority.native300MResourceProbeAuthorized,
            authority.native300MTrainingConfigurationEstablished,
            authority.metalDeterminismClaimEstablished,
            authority.trajectoryExactCPUResumeEstablished,
            authority.native300MTrajectoryResumeEstablished,
            authority.trainingResumeEstablished,
            authority.checkpointArtifactAvailabilityEstablished,
            authority.checkpointDurabilityEstablished,
            authority.checkpointArtifactRetentionAuthorized,
            authority.checkpointArtifactUploadAuthorized,
            authority.checkpointArtifactProvenanceEstablished,
            authority.checkpointAdmissionGranted,
            authority.releaseInstrumentationAuthorized,
            authority.trainingExecutionObserved,
            authority.modelQualityEstablished,
            authority.candidateAdmissionGranted,
            authority.trialAuthorized,
            authority.canaryReplacementAuthorized,
            authority.quantizationAuthorized,
            authority.productUseAuthorized,
            authority.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String) -> Bool {
        value.utf8.allSatisfy { byte in
            (byte >= 48 && byte <= 57)
                || (byte >= 97 && byte <= 102)
        }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

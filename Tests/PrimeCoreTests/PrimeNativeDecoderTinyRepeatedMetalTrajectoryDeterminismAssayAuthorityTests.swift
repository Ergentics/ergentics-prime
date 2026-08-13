// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validateExactV1())
        requireSendable(Authority.self)

        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256)
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical).canonicalData(),
            canonical)

        XCTAssertEqual(
            authority.repository.stage4RetirementMergeRevision,
            "b198ba81f4c6958d70b56ea3a23f56f07fa90854")
        XCTAssertEqual(
            authority.repository.stage4RetirementTree,
            "54af1d38bdd454a924228a37a5b76a64ac5b56ae")
        XCTAssertEqual(
            authority.repository.orderedParentRevisions,
            [
                "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
                "9f9f792edaba668cd5bd2183cfbf00ca12b31193",
            ])
        XCTAssertEqual(
            authority.repository.designAuthorityCanonicalSHA256,
            "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589")
        XCTAssertEqual(
            authority.repository.stage4AuthorityCanonicalSHA256,
            "0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031")
        XCTAssertEqual(
            authority.repository.stage4RepairAuthorityCanonicalSHA256,
            "6a6dfc7b30319f9ccc1d17c2f08282c266962cd500d47696cbb42b4b1b0ff826")
        XCTAssertEqual(
            authority.repository.stage4ObservationCanonicalSHA256,
            "7239edc86e007b1a8b6fa7a742bfb812e8ef8caa4b1dc8dbcb32b66b5b88e5e0")

        XCTAssertEqual(authority.predecessor.stage4Execution.workflowRunNumber, 97)
        XCTAssertEqual(authority.predecessor.stage4Execution.runAttempt, 1)
        XCTAssertEqual(authority.predecessor.stage4Execution.rerunCount, 0)
        XCTAssertEqual(authority.predecessor.stage4Execution.artifactCount, 0)
        XCTAssertEqual(authority.predecessor.stage4Execution.stage4InvocationCount, 1)
        XCTAssertEqual(authority.predecessor.stage4Execution.stage4ReceiptCount, 1)
        XCTAssertEqual(authority.predecessor.stage4Execution.stage4PassedCount, 1)
        XCTAssertEqual(authority.predecessor.stage4Execution.totalTestCount, 103)
        XCTAssertEqual(
            authority.predecessor.stage4Execution.maintainedRuntimeReceiptCount,
            1)
        XCTAssertEqual(
            authority.predecessor.stage4Execution.tokenizerReceiptCount,
            1)
        XCTAssertEqual(
            authority.predecessor.stage4ExecutionSecureFetch.tlsFailureCount,
            0)
        XCTAssertEqual(
            authority.predecessor.stage4ExecutionSecureFetch
                .workflowAuthoredRetryCount,
            0)
        XCTAssertEqual(
            authority.predecessor.stage4ExecutionSecureFetch
                .gitInternalRetryScheduledCount,
            0)
        XCTAssertEqual(authority.predecessor.stage4Receipt.rawJSONByteCount, 4_147)
        XCTAssertEqual(
            authority.predecessor.stage4Receipt.rawJSONSHA256,
            "a0bbebb611b12ef1e88ffe625120b86a3a0caf7f29f0edbf20233c7fbe244fbd")
        XCTAssertTrue(authority.predecessor.stage4Receipt.rawJSONWasCanonical)
        XCTAssertTrue(authority.predecessor.stage4Receipt.ephemeralPrivateRootReclaimed)
        XCTAssertFalse(authority.predecessor.stage4Receipt.retainedArtifactEstablished)

        XCTAssertEqual(authority.predecessor.stage4Retirement.workflowRunNumber, 99)
        XCTAssertEqual(authority.predecessor.stage4Retirement.runAttempt, 1)
        XCTAssertEqual(authority.predecessor.stage4Retirement.rerunCount, 0)
        XCTAssertEqual(authority.predecessor.stage4Retirement.artifactCount, 0)
        XCTAssertEqual(authority.predecessor.stage4Retirement.focusedRootTestCount, 51)
        XCTAssertEqual(authority.predecessor.stage4Retirement.focusedWholeTestCount, 57)
        XCTAssertEqual(authority.predecessor.stage4Retirement.stage4InvocationCount, 0)
        XCTAssertEqual(authority.predecessor.stage4Retirement.stage4ReceiptCount, 0)
        XCTAssertEqual(
            authority.predecessor.stage4RetirementSecureFetch.tlsFailureCount,
            0)
        XCTAssertEqual(
            authority.predecessor.stage4RetirementSecureFetch
                .tlsVerificationBypassCount,
            0)
        XCTAssertTrue(authority.predecessor.stage4LauncherSourcePreserved)
        XCTAssertTrue(authority.predecessor.stage4SuccessfulAttemptConsumed)
        XCTAssertTrue(authority.predecessor.stage4MechanicsEstablished)
        XCTAssertTrue(authority.predecessor.stage4InvocationRetired)

        XCTAssertEqual(
            authority.roadmap.stageID,
            "tiny_repeated_metal_trajectory_determinism_assay_v1")
        XCTAssertEqual(
            authority.roadmap.requiredPredecessorStageID,
            "tiny_durable_multileaf_commit_fault_injection_v1")
        XCTAssertEqual(
            authority.roadmap.nextStageID,
            "native300m_resource_only_one_step_probe_v1")
        XCTAssertTrue(authority.roadmap.stage6RequiresSeparateAuthority)

        XCTAssertEqual(authority.environment.requiredBindings.count, 10)
        XCTAssertEqual(authority.environment.mlxEnableTF32, "0")
        XCTAssertEqual(authority.environment.metalDeviceIndex, 0)
        XCTAssertEqual(authority.environment.exactMetalDeviceCount, 1)
        XCTAssertTrue(authority.environment.explicitDefaultGPUStreamRequired)
        XCTAssertEqual(authority.environment.leaseType, "PrimeMetalDeviceLease")
        XCTAssertEqual(authority.environment.leaseModule, "PrimeCore")
        XCTAssertTrue(authority.environment.trainingValidationTestImportsPrimeCore)
        XCTAssertTrue(
            authority.environment.trainingValidationTestDirectlyOwnsFullDurationLease)
        XCTAssertTrue(
            authority.environment.checkedEvaluationRequiredForEveryComparedArray)
        XCTAssertTrue(
            authority.environment.explicitSynchronizeRequiredBeforeEveryByteRead)
        XCTAssertTrue(
            authority.environment.leaseAcquiredBeforeCoreGraphicsMetalOrMLXAccess)
        XCTAssertTrue(authority.environment.leaseHeldThroughPostflightAndReceipt)
        XCTAssertTrue(authority.environment.leaseReleasedOnlyAfterReceipt)
        XCTAssertTrue(authority.environment.singletonDeviceEnumerationRequired)
        XCTAssertTrue(authority.environment.indexZeroMustMatchDefaultDevice)
        XCTAssertTrue(
            authority.environment.postflightDeviceIdentityReverificationRequired)
        XCTAssertEqual(authority.environment.swiftPMBuildConfiguration, "debug")
        XCTAssertEqual(
            authority.environment.mlxGraphCompileMode,
            "eager_uncompiled_no_compile_transform")
        XCTAssertEqual(authority.environment.mlxCompileTransformInvocationCount, 0)
        XCTAssertFalse(authority.environment.crossDeviceComparisonAuthorized)

        XCTAssertEqual(authority.fixture.uniqueParameterCount, 5_200)
        XCTAssertEqual(authority.fixture.repeatedTokenIDs, [1, 15])
        XCTAssertEqual(authority.fixture.sourceSnapshotGlobalStep, 1)
        XCTAssertEqual(authority.fixture.terminalGlobalStep, 2)
        XCTAssertEqual(authority.assay.independentTrialCount, 3)
        XCTAssertEqual(authority.assay.totalTrajectoryBranchExecutionCount, 9)
        XCTAssertTrue(authority.assay.allTrialsRunInOneProcess)
        XCTAssertEqual(
            authority.assay.exactBranchesPerTrial,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1.allCases)
        XCTAssertTrue(authority.assay.sourceSnapshotCaptureIsReadOnly)
        XCTAssertTrue(authority.assay.sourceSnapshotBranchContinuesToTerminalStep)
        XCTAssertTrue(authority.assay.everyBranchReachesTerminalStep)
        XCTAssertTrue(authority.assay.everyTrialUsesFreshObjectsAndArrays)
        XCTAssertFalse(authority.assay.objectOrArrayAliasingAcrossBranchesAuthorized)
        XCTAssertFalse(authority.assay.stateReuseAcrossTrialsAuthorized)
        XCTAssertFalse(authority.assay.implicitOrGlobalMLXRandomStateAuthorized)
        XCTAssertTrue(authority.assay.sourceSnapshotExistsOnlyInMemory)
        XCTAssertFalse(authority.assay.durableCheckpointIOAuthorized)
        XCTAssertFalse(authority.assay.filesystemArtifactIOAuthorized)
        XCTAssertEqual(authority.assay.buildCount, 1)
        XCTAssertEqual(authority.assay.directXCTestCount, 1)
        XCTAssertEqual(
            authority.assay.receiptPrefix,
            "PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT=")

        XCTAssertEqual(
            authority.equality.sourceStepEqualityBranches,
            [.uninterrupted, .sourceSnapshot])
        XCTAssertEqual(
            authority.equality.successorAndTerminalEqualityBranches,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1.allCases)
        XCTAssertTrue(
            authority.equality.exactSourceStepWithinTrialAcrossProducingBranchesRequired)
        XCTAssertTrue(authority.equality.exactSourceStepAcrossAllTrialsRequired)
        XCTAssertTrue(
            authority.equality
                .exactSuccessorAndTerminalWithinTrialAcrossAllBranchesRequired)
        XCTAssertTrue(
            authority.equality.exactSuccessorAndTerminalAcrossAllTrialsRequired)
        XCTAssertTrue(authority.equality.exactSourceStepRawGradientBytesRequired)
        XCTAssertTrue(authority.equality.exactSuccessorStepRawGradientBytesRequired)
        XCTAssertTrue(authority.equality.exactSourceStepClippedGradientBytesRequired)
        XCTAssertTrue(authority.equality.exactSuccessorStepClippedGradientBytesRequired)
        XCTAssertTrue(authority.equality.exactModelParameterBytesRequired)
        XCTAssertTrue(authority.equality.exactAdamFirstMomentBytesRequired)
        XCTAssertTrue(authority.equality.exactAdamSecondMomentBytesRequired)
        XCTAssertTrue(
            authority.equality.exactRNGDomainKeyCounterAndConsumptionBytesRequired)
        XCTAssertTrue(authority.equality.exactNextUnconsumedCursorBytesRequired)
        XCTAssertTrue(
            authority.equality.exactStepOneBoundaryStateAcrossAllBranchesRequired)
        XCTAssertTrue(
            authority.equality.exactLossNormAndClipScalarFloat32BitPatternsRequired)
        XCTAssertTrue(
            authority.equality.exactReadOnlyEvaluationFloat32BitPatternsRequired)
        XCTAssertTrue(authority.equality.canonicalParameterPathOrderRequired)
        XCTAssertTrue(authority.equality.canonicalShapeAndDTypeOrderRequired)
        XCTAssertTrue(authority.equality.float32LittleEndianByteReadOrderRequired)
        XCTAssertFalse(authority.equality.unorderedOrToleranceComparisonAuthorized)
        XCTAssertFalse(authority.equality.resultEstablishedByThisAuthority)

        XCTAssertEqual(authority.authorityClosureScope.exactChangedPathCount, 5)
        XCTAssertEqual(authority.authorityClosureScope.exactChangedPaths.count, 5)
        XCTAssertTrue(authority.authorityClosureScope.sourceAndTestAreOnlyNewPaths)
        XCTAssertFalse(authority.authorityClosureScope.trainingSourceMutationAuthorized)
        XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 6)
        XCTAssertTrue(authority.successorScope.trainingSourceMutationAuthorized)
        XCTAssertFalse(authority.successorScope.rootPackageManifestMutationAuthorized)
        XCTAssertFalse(authority.successorScope.rootPackageResolvedMutationAuthorized)
        XCTAssertFalse(authority.successorScope.existingMetalLauncherMutationAuthorized)
        XCTAssertFalse(authority.successorScope.existingRuntimeLauncherMutationAuthorized)
        XCTAssertFalse(authority.successorScope.existingTokenizerLauncherMutationAuthorized)
        XCTAssertFalse(authority.successorScope.existingStage4LauncherMutationAuthorized)
        XCTAssertFalse(authority.successorScope.workflowTimeoutChangeAuthorized)
        XCTAssertFalse(authority.successorScope.existingCPUTrainingBehaviorMutationAuthorized)
        XCTAssertTrue(authority.successorScope.stage5BoundedDevicePolicyRequired)
        XCTAssertEqual(authority.successorScope.activeCheckoutDepth, 1)
        XCTAssertEqual(authority.successorScope.reviewedCheckoutDepth, 1)

        XCTAssertEqual(authority.suite.authorityRootTestCount, 52)
        XCTAssertEqual(authority.suite.isolatedTestCount, 6)
        XCTAssertEqual(authority.suite.implementationFocusedWholeTestCount, 58)
        XCTAssertEqual(authority.suite.preStage5TotalTestCount, 104)
        XCTAssertEqual(authority.suite.totalTestCount, 105)
        XCTAssertEqual(authority.suite.authorityStage5LauncherInvocationCount, 0)
        XCTAssertEqual(authority.suite.authorityStage5ReceiptCount, 0)
        XCTAssertEqual(
            authority.suite.authorityClosureLiveOrder,
            ["metal", "maintained_runtime", "tokenizer"])
        XCTAssertEqual(
            authority.suite.futureMechanicsLiveOrder,
            ["root", "metal", "maintained_runtime", "tokenizer", "stage5"])

        XCTAssertTrue(authority.ceiling.authorityOnlyNoAssayResultEvidence)
        XCTAssertTrue(
            authority.ceiling
                .mechanicsImplementationAuthorizedAfterGreenAuthorityClosure)
        XCTAssertTrue(authority.ceiling.oneExactMainExecutionOpportunityAuthorized)
        XCTAssertTrue(authority.ceiling.threeBoundedSameProcessAssayTrialsAuthorized)
        XCTAssertTrue(authority.ceiling.inMemorySourceSnapshotAuthorized)
        XCTAssertTrue(authorityFalseClaims(authority.ceiling).allSatisfy { !$0 })

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let paths = allPaths(in: object)
        let leafPaths = paths.filter { path in
            guard let value = value(at: path, in: object) else { return false }
            return !(value is [String: Any]) && !(value is [Any])
        }
        let dictionaryPaths = paths.filter {
            value(at: $0, in: object) is [String: Any]
        }
        let arrayPaths = paths.filter {
            value(at: $0, in: object) is [Any]
        }
        XCTAssertGreaterThan(leafPaths.count, 225)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(arrayPaths.count, 15)

        for path in leafPaths {
            var mutated: Any = object
            let original = try XCTUnwrap(value(at: path, in: mutated))
            try setValue(mutatedScalar(original), at: path, in: &mutated)
            assertRejected(mutated, label: "scalar \(pathLabel(path))")
        }

        for (index, path) in dictionaryPaths.enumerated() {
            var unknown: Any = object
            var dictionary = try XCTUnwrap(
                value(at: path, in: unknown) as? [String: Any])
            dictionary["unknown_stage5_assay_authority_field_\(index)"] = index
            try setValue(dictionary, at: path, in: &unknown)
            assertRejected(unknown, label: "unknown \(pathLabel(path))")

            guard !dictionary.isEmpty,
                  let key = dictionary.keys.sorted().first(where: {
                      !$0.hasPrefix("unknown_stage5_")
                  })
            else { continue }
            var removed: Any = object
            var removedDictionary = try XCTUnwrap(
                value(at: path, in: removed) as? [String: Any])
            removedDictionary.removeValue(forKey: key)
            try setValue(removedDictionary, at: path, in: &removed)
            assertRejected(removed, label: "removed \(pathLabel(path)).\(key)")
        }

        for path in arrayPaths {
            let array = try XCTUnwrap(value(at: path, in: object) as? [Any])
            if !array.isEmpty {
                var shortened: Any = object
                var changed = array
                changed.removeLast()
                try setValue(changed, at: path, in: &shortened)
                assertRejected(shortened, label: "shortened \(pathLabel(path))")

                var extended: Any = object
                changed = array
                changed.append(array[0])
                try setValue(changed, at: path, in: &extended)
                assertRejected(extended, label: "extended \(pathLabel(path))")
            }
            if array.count > 1 {
                let first = try JSONSerialization.data(
                    withJSONObject: [array[0]],
                    options: [.sortedKeys, .withoutEscapingSlashes])
                if let distinctIndex = array.indices.dropFirst().first(where: {
                    guard let candidate = try? JSONSerialization.data(
                        withJSONObject: [array[$0]],
                        options: [.sortedKeys, .withoutEscapingSlashes])
                    else { return false }
                    return candidate != first
                }) {
                    var reordered: Any = object
                    var changed = array
                    changed.swapAt(0, distinctIndex)
                    try setValue(changed, at: path, in: &reordered)
                    assertRejected(
                        reordered,
                        label: "reordered \(pathLabel(path))")
                }
            }
        }

        var nullMutation: Any = object
        try setValue(NSNull(), at: leafPaths[0], in: &nullMutation)
        assertRejected(nullMutation, label: "null \(pathLabel(leafPaths[0]))")

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
        XCTAssertThrowsError(try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(try Authority.decodeCanonical(canonical + Data([0x0a])))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(duplicateFirstTopLevelKey(in: canonical)))

        let sourceURL = repositoryRoot().appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(
            sourceText.components(separatedBy: "import Foundation").count - 1,
            1)
        for forbidden in [
            "import CoreGraphics",
            "import Metal",
            "import MLX",
            "import MLXNN",
            "import MLXOptimizers",
            "FileManager",
            "FileHandle",
            "URLSession",
            "Process(",
            "posix_spawn",
            "execve(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        XCTAssertFalse(sourceText.contains("__CANONICAL_SHA256__"))
    }

    private func authorityFalseClaims(
        _ ceiling: PrimeNativeDecoderTinyRepeatedMetalTrajectoryAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.trainingExecutionObserved,
            ceiling.stage4RerunAuthorized,
            ceiling.stage6Authorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private enum PathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private func allPaths(in root: Any) -> [[PathComponent]] {
        var result = [[PathComponent]]()
        func walk(_ value: Any, path: [PathComponent]) {
            result.append(path)
            if let dictionary = value as? [String: Any] {
                for key in dictionary.keys.sorted() {
                    walk(dictionary[key]!, path: path + [.key(key)])
                }
            } else if let array = value as? [Any] {
                for index in array.indices {
                    walk(array[index], path: path + [.index(index)])
                }
            }
        }
        walk(root, path: [])
        return result
    }

    private func value(at path: [PathComponent], in root: Any) -> Any? {
        var current: Any = root
        for component in path {
            switch component {
            case .key(let key):
                guard let dictionary = current as? [String: Any],
                      let next = dictionary[key]
                else { return nil }
                current = next
            case .index(let index):
                guard let array = current as? [Any],
                      array.indices.contains(index)
                else { return nil }
                current = array[index]
            }
        }
        return current
    }

    private func setValue(
        _ replacement: Any,
        at path: [PathComponent],
        in root: inout Any
    ) throws {
        guard let first = path.first else {
            root = replacement
            return
        }
        let tail = Array(path.dropFirst())
        switch first {
        case .key(let key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            var child = try XCTUnwrap(dictionary[key])
            try setValue(replacement, at: tail, in: &child)
            dictionary[key] = child
            root = dictionary
        case .index(let index):
            var array = try XCTUnwrap(root as? [Any])
            var child = array[index]
            try setValue(replacement, at: tail, in: &child)
            array[index] = child
            root = array
        }
    }

    private func mutatedScalar(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "_drift"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            if CFNumberIsFloatType(number) {
                return number.doubleValue + 1.25
            }
            return number.int64Value == Int64.max
                ? number.int64Value - 1
                : number.int64Value + 1
        }
        return "unexpected_scalar_drift"
    }

    private func assertRejected(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]),
            label,
            file: file,
            line: line)
        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        else { return }
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
    }

    private func pathLabel(_ path: [PathComponent]) -> String {
        if path.isEmpty { return "$" }
        return path.reduce("$") { partial, component in
            switch component {
            case .key(let key): return partial + "." + key
            case .index(let index): return partial + "[\(index)]"
            }
        }
    }

    private func duplicateFirstTopLevelKey(in data: Data) throws -> Data {
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        let firstQuote = try XCTUnwrap(text.firstIndex(of: "\""))
        let keyStart = text.index(after: firstQuote)
        let keyEnd = try XCTUnwrap(text[keyStart...].firstIndex(of: "\""))
        let key = String(text[keyStart ..< keyEnd])
        guard text.first == "{" else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
                .contractDrift
        }
        return Data(("{\"\(key)\":null," + text.dropFirst()).utf8)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

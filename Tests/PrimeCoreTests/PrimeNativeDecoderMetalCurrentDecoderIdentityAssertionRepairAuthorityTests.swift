// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
        throws
    {
        let authority = Authority.frozenV1

        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "test_only_historical_plan_to_current_stage2_decoder_identity_assertion_repair"
        )

        let consumed = authority.failureConsumption
        XCTAssertEqual(
            consumed.failureObservationID,
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationV1
                .frozenV1.observationID
        )
        XCTAssertEqual(
            consumed.failureObservationCanonicalSHA256,
            "7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424"
        )
        XCTAssertEqual(
            consumed.mergeRevision,
            "2d0464ca35212d3d84781654b6a4e08158f27eab"
        )
        XCTAssertEqual(
            consumed.mergeTree,
            "be66df2affb85e2d846ba6f5f51e540d17864796"
        )
        XCTAssertEqual(
            consumed.orderedParentRevisions,
            [
                "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
                "5198f5da94977d11f5fcfabf65bb55a62cb31f26",
            ]
        )
        XCTAssertEqual(consumed.pullRequestNumber, 85)
        XCTAssertEqual(consumed.runID, 31_533_658_617)
        XCTAssertEqual(consumed.runNumber, 67)
        XCTAssertEqual(consumed.runAttempt, 1)
        XCTAssertEqual(consumed.activeRootJobID, 93_919_471_247)
        XCTAssertEqual(consumed.reviewedMainJobID, 93_920_049_786)
        XCTAssertTrue(consumed.securePrivateDependencyFetchCompleted)
        XCTAssertEqual(consumed.focusedRootRequiredTestCount, 36)
        XCTAssertEqual(consumed.focusedRootCompletedTestCount, 36)
        XCTAssertEqual(consumed.focusedRootFailureCount, 0)
        XCTAssertEqual(consumed.focusedRootSkipCount, 0)
        XCTAssertTrue(consumed.freshDefaultMetallibObserved)
        XCTAssertEqual(consumed.freshDefaultMetallibByteCount, 6_292_732)
        XCTAssertEqual(
            consumed.freshDefaultMetallibSHA256,
            "53aa69728711f18cdf0886e2397bc1f8777b02c00d2235f83c03f71599470083"
        )
        XCTAssertEqual(consumed.requiredMetalTestCount, 44)
        XCTAssertEqual(consumed.completedMetalTestCount, 44)
        XCTAssertEqual(consumed.passedMetalTestCaseCount, 43)
        XCTAssertEqual(consumed.failedMetalTestCaseCount, 1)
        XCTAssertEqual(consumed.assertionFailureCount, 2)
        XCTAssertEqual(consumed.metalSkipCount, 0)
        XCTAssertEqual(
            consumed.failedTestMethod,
            "testMetalRepairAuthorityIsAppendOnlyAndSourceExact"
        )
        XCTAssertEqual(consumed.staleByteCountAssertionSourceLine, 338)
        XCTAssertEqual(consumed.staleSHA256AssertionSourceLine, 339)
        XCTAssertEqual(consumed.observedDecoderByteCount, 39_598)
        XCTAssertEqual(consumed.staleHistoricalExpectedDecoderByteCount, 39_050)
        XCTAssertEqual(
            consumed.observedDecoderSHA256,
            "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"
        )
        XCTAssertEqual(
            consumed.staleHistoricalExpectedDecoderSHA256,
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"
        )
        XCTAssertEqual(
            [
                consumed.runtimeInvocationCount,
                consumed.runtimeReceiptCount,
                consumed.tokenizerInvocationCount,
                consumed.tokenizerReceiptCount,
                consumed.actionsArtifactsTotalCount,
                consumed.rerunCount,
            ],
            Array(repeating: 0, count: 6)
        )
        XCTAssertEqual(consumed.processExitCode, 2)
        XCTAssertTrue(consumed.actionsArtifactsArrayExactlyEmpty)
        XCTAssertTrue(consumed.runConsumedAsTerminalFailureEvidence)
        XCTAssertFalse(consumed.runRecoveryOrReinterpretationAuthorized)

        let historical = authority.historicalMetalRepairPlan
        XCTAssertEqual(
            historical.authorityID,
            PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1.authorityID
        )
        XCTAssertEqual(
            historical.sourcePath,
            "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift"
        )
        XCTAssertEqual(historical.sourceGitMode, "100644")
        XCTAssertEqual(
            historical.sourceGitBlob,
            "f284cb6d9bfdd37add9273f3e0eecd69e13cd134"
        )
        XCTAssertEqual(historical.sourceByteCount, 26_865)
        XCTAssertEqual(
            historical.sourceSHA256,
            "5e88a1a191f94daac01f86e5dbad48ebfcdd50957ac17acf6f404ac8dd0a97ac"
        )
        XCTAssertEqual(
            historical.repairedDecoderSourceGitBlob,
            "835a4826549e1f28ec27e3533f746218beb3bdf2"
        )
        XCTAssertEqual(historical.repairedDecoderSourceByteCount, 39_050)
        XCTAssertEqual(
            historical.repairedDecoderSourceSHA256,
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"
        )
        XCTAssertTrue(historical.validateExactlyRequired)
        XCTAssertTrue(historical.remainsFrozen)
        XCTAssertTrue(historical.identityRemainsHistorical)
        XCTAssertFalse(historical.isCurrentDecoderIdentity)
        XCTAssertFalse(historical.mutationAuthorized)
        XCTAssertFalse(historical.reinterpretationAuthorized)

        let current = authority.currentDecoderSuccessor
        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1
        let surface = stage2.surfaceDesign
        XCTAssertEqual(current.sourceAuthorityID, stage2.authorityID)
        XCTAssertEqual(
            current.sourceAuthorityCanonicalSHA256,
            "3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840"
        )
        XCTAssertEqual(
            current.decoderSourcePath,
            historical.repairedDecoderSourcePath
        )
        XCTAssertEqual(current.mutationScope,
            surface.currentDecoderSuccessorMutationScope)
        XCTAssertEqual(current.expectedGitMode,
            surface.currentDecoderSuccessorExpectedGitMode)
        XCTAssertEqual(current.expectedGitBlob,
            surface.currentDecoderSuccessorExpectedGitBlob)
        XCTAssertEqual(current.expectedByteCount,
            surface.currentDecoderSuccessorExpectedByteCount)
        XCTAssertEqual(current.expectedSHA256,
            surface.currentDecoderSuccessorExpectedSHA256)
        XCTAssertEqual(
            current.expectedGitBlob,
            "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"
        )
        XCTAssertEqual(current.expectedByteCount, 39_598)
        XCTAssertEqual(
            current.expectedSHA256,
            "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"
        )
        XCTAssertTrue(
            current.predecessorDecoderIdentityRemainsHistoricalAndFrozen)
        XCTAssertTrue(current.stage2SurfaceDesignIsCurrentDecoderIdentitySource)
        XCTAssertTrue(
            current.packageOnlyTrainingLogitsNoCacheSeamIsSoleIdentityDelta)
        XCTAssertFalse(current.publicDecoderAPIAdded)
        XCTAssertFalse(
            current.checkpointRuntimeOrTokenizerAuthorityReinterpreted)

        let patch = authority.authorizedTestPatch
        XCTAssertEqual(
            patch.sourcePath,
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift"
        )
        XCTAssertEqual(patch.predecessorGitMode, "100644")
        XCTAssertEqual(
            patch.predecessorGitBlob,
            "25b7c9b99e789988fb7362b73a41d35eafba406d"
        )
        XCTAssertEqual(patch.predecessorByteCount, 34_555)
        XCTAssertEqual(
            patch.predecessorSHA256,
            "28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe"
        )
        XCTAssertEqual(patch.repairedGitMode, "100644")
        XCTAssertEqual(
            patch.repairedGitBlob,
            "329e57a8cbb2aa55879a94c88b17c391d13a1eb4"
        )
        XCTAssertEqual(patch.repairedByteCount, 35_548)
        XCTAssertEqual(
            patch.repairedSHA256,
            "40c65bd0169ed5af08248acb38b5b287a82894fec8e8f2c2808f348e3cd50373"
        )
        XCTAssertEqual(patch.testClass, "PrimeNativeDecoderAuthorityTests")
        XCTAssertEqual(
            patch.repairedTestMethod,
            "testMetalRepairAuthorityIsAppendOnlyAndSourceExact"
        )
        XCTAssertEqual(patch.authorityTestClassMethodCount, 11)
        XCTAssertEqual(
            [
                patch.requiredMetalAuthorityTestCount,
                patch.requiredMetalCheckpointTestCount,
                patch.requiredMetalDecoderTestCount,
            ],
            [11, 14, 19]
        )
        XCTAssertEqual(patch.requiredMetalTotalTestCount, 44)
        XCTAssertEqual(patch.historicalPlanValidationCallCount, 1)
        XCTAssertEqual(
            patch.historicalPlanRepairedDecoderLiteralAssertionCount,
            3
        )
        XCTAssertEqual(patch.liveHistoricalPlanIdentityAssertionCount, 0)
        XCTAssertEqual(patch.liveStage2SuccessorIdentityAssertionCount, 3)
        XCTAssertEqual(patch.gitBlobObjectFormat, "sha1")
        XCTAssertEqual(patch.gitBlobFrame, "blob <byte_count>\\0<payload>")
        XCTAssertTrue(patch.cryptoKitSHA1ForPureGitBlobFramingAuthorized)
        XCTAssertFalse(patch.testCountChangeAuthorized)
        XCTAssertFalse(patch.testMethodAdditionAuthorized)
        XCTAssertFalse(patch.testMethodRemovalAuthorized)
        XCTAssertFalse(patch.productionTargetChangeAuthorized)

        XCTAssertTrue(
            authority.testOnlyCurrentDecoderIdentityAssertionRepairAuthorized)
        XCTAssertTrue(authority.materializedRepairSourceIdentityBound)
        XCTAssertTrue(authority.historicalPlanIdentityPreserved)
        XCTAssertTrue(
            authority.currentDecoderIdentityResolvedThroughStage2SurfaceDesign)
        XCTAssertTrue(authority.implementationObservedByThisAuthority)
        XCTAssertFalse(authority.executionObservedByThisAuthority)
        XCTAssertTrue(falseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertTrue(authority.status.hasPrefix("AUTHORIZED_test_only_"))
        XCTAssertEqual(authority.orderedRequiredSeparateActions.count, 5)
        XCTAssertEqual(
            authority.orderedRequiredSeparateActions[3],
            "require_distinct_exact_main_root38_then_metal44_then_runtime1_then_tokenizer1_before_any_new_success_observation"
        )

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalHash,
            "beb9f8ba1c0c09527b4e30c1d3225e641a30498300ddd58c5e2f7086f0fb5e35"
        )
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 150)
        XCTAssertGreaterThan(dictionaryPaths.count, 5)
        XCTAssertGreaterThan(scalarPaths.count, 130)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            let mutationData = try assertCanonicalRejects(
                mutated,
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if let loose = try? JSONDecoder().decode(
                Authority.self,
                from: mutationData
            ), loose != authority {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }

            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1

            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(regularDecodedDriftCount, 100)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_metal_current_decoder_identity_assertion_repair_field_\(index)"
                    ] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(
                Authority.self,
                from: unknownData
            )
            XCTAssertEqual(loose, authority)
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)
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
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
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
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
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
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return [prefix]
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
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
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
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(
            slashEscaped.data(using: .utf8)
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(slashEscapedData)
        )

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace)
        )
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func falseClaims(
        _ ceiling:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCeilingV1
    ) -> [Bool] {
        [
            ceiling.failureObservationMutationAuthorized,
            ceiling.historicalMetalRepairPlanMutationAuthorized,
            ceiling.historicalMetalRepairPlanReinterpretationAuthorized,
            ceiling.decoderSourceMutationAuthorized,
            ceiling.stage2AuthorityMutationAuthorized,
            ceiling.packageManifestMutationAuthorized,
            ceiling.packageLockMutationAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.activeGateMutationAuthorized,
            ceiling.metalLauncherMutationAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.TLSVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.replacementExecutionAuthorizedByThisAuthority,
            ceiling.defaultMetallibRepairAuthorized,
            ceiling.metalExecutionEstablishedByThisAuthority,
            ceiling.runtimeExecutionEstablishedByThisAuthority,
            ceiling.tokenizerExecutionEstablishedByThisAuthority,
            ceiling.stage2ExecutionAuthorized,
            ceiling.stage2BootstrapRepairAuthorized,
            ceiling.stage2SuccessEstablished,
            ceiling.stage3AuthorityEstablished,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactAuthorized,
            ceiling.checkpointResumeAuthorized,
            ceiling.metalTensorExecutionAuthorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trajectoryResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

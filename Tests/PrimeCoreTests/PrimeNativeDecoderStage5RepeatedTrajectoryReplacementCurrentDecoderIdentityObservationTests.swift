// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import CryptoKit
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndIdentityCeiling()
        throws
    {
        let observation = Observation.frozenV1
        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_current_decoder_identity_observation_v1")
        XCTAssertEqual(
            observation.observationKind,
            "pure_post_authority_pre_execution_current_decoder_source_identity")

        let closure = observation.authorityClosure
        XCTAssertEqual(closure.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(closure.ref, "refs/heads/main")
        XCTAssertEqual(
            closure.mergeRevision,
            "a0ce9561bdbc867b12f13aed7a7f54846faf3020")
        XCTAssertEqual(
            closure.mergeTree,
            "e7f85dcecbc82b7e74065cc1991175152f53c13f")
        XCTAssertEqual(
            closure.orderedParentRevisions,
            [
                "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174",
                "86869f59b198f99678328d86b3f9555a43be88af",
            ])
        XCTAssertEqual(
            closure.reviewedHeadRevision,
            closure.orderedParentRevisions[1])
        XCTAssertEqual(closure.pullRequestNumber, 109)
        XCTAssertEqual(closure.workflowID, 329_017_041)
        XCTAssertEqual(closure.workflowRunID, 31_824_087_086)
        XCTAssertEqual(closure.workflowRunNumber, 115)
        XCTAssertEqual(closure.workflowRunAttempt, 1)
        XCTAssertEqual(closure.event, "push")
        XCTAssertEqual(closure.checkSuiteID, 86_338_204_723)
        XCTAssertEqual(closure.activeRootJobID, 94_843_969_773)
        XCTAssertEqual(closure.activeRootRunnerLabel, "macos-15")
        XCTAssertEqual(closure.activeRootConclusion, "success")
        XCTAssertEqual(closure.reviewedMainJobID, 94_844_683_376)
        XCTAssertEqual(closure.reviewedMainRunnerLabel, "macos-26")
        XCTAssertEqual(closure.reviewedMainConclusion, "success")
        XCTAssertEqual(closure.status, "completed")
        XCTAssertEqual(closure.conclusion, "success")
        XCTAssertTrue(closure.previousAttemptURLWasNull)
        XCTAssertEqual(closure.exactHeadPushRunCount, 1)
        XCTAssertEqual(
            [closure.rerunCount, closure.retryCount, closure.artifactCount],
            [0, 0, 0])
        XCTAssertEqual(closure.rootTestCount, 57)
        XCTAssertEqual(closure.rootFailureCount, 0)
        XCTAssertEqual(closure.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(closure.isolatedTestCount, 6)
        XCTAssertEqual(closure.isolatedFailureCount, 0)
        XCTAssertEqual(closure.focusedWholeTestCount, 63)
        XCTAssertEqual(closure.metalTestCount, 44)
        XCTAssertEqual(closure.metalFailureCount, 0)
        XCTAssertEqual(closure.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(closure.maintainedRuntimeFailureCount, 0)
        XCTAssertEqual(closure.tokenizerTestCount, 1)
        XCTAssertEqual(closure.tokenizerFailureCount, 0)
        XCTAssertEqual(closure.totalTestCount, 109)
        XCTAssertEqual(
            [
                closure.originalStage5LauncherInvocationCount,
                closure.originalStage5ReceiptCount,
                closure.replacementStage5LauncherInvocationCount,
                closure.replacementStage5ReceiptCount,
                closure.stage6LauncherInvocationCount,
                closure.stage6ReceiptCount,
            ],
            Array(repeating: 0, count: 6))
        XCTAssertTrue(closure.executionPureAuthorityClosure)

        let binding = observation.authorityBinding
        let authority =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1
        XCTAssertEqual(binding.authorityID, authority.authorityID)
        XCTAssertEqual(
            binding.authorityCanonicalSHA256,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .canonicalSHA256)
        XCTAssertEqual(binding.orderedSourceBindings.count, 2)
        XCTAssertEqual(
            binding.orderedSourceBindings.map(\.gitBlob),
            [
                "ded305476edfc832ae4e910b1985da77c7a10cd0",
                "e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7",
            ])
        XCTAssertEqual(
            binding.orderedSourceBindings.map(\.byteCount),
            [144_935, 49_796])
        XCTAssertEqual(
            binding.orderedSourceBindings.map(\.sha256),
            [
                "634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc",
                "71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08",
            ])
        XCTAssertEqual(binding.successorExactChangedPathCount, 10)
        XCTAssertTrue(binding.currentIdentityObservationAuthorized)

        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1
        let surface = stage2.surfaceDesign
        let predecessor = observation.predecessorDecoder
        XCTAssertEqual(predecessor.path,
            authority.successorScope.decoderSourcePath)
        XCTAssertEqual(predecessor.gitMode,
            surface.currentDecoderSuccessorExpectedGitMode)
        XCTAssertEqual(predecessor.gitBlob,
            surface.currentDecoderSuccessorExpectedGitBlob)
        XCTAssertEqual(predecessor.byteCount,
            surface.currentDecoderSuccessorExpectedByteCount)
        XCTAssertEqual(predecessor.sha256,
            surface.currentDecoderSuccessorExpectedSHA256)
        XCTAssertEqual(
            predecessor.gitBlob,
            "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f")
        XCTAssertEqual(predecessor.byteCount, 39_598)
        XCTAssertEqual(
            predecessor.sha256,
            "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994")
        XCTAssertEqual(predecessor.sourceAuthorityID, stage2.authorityID)
        XCTAssertEqual(predecessor.authorizedMutationScope,
            surface.currentDecoderSuccessorMutationScope)

        let current = observation.currentDecoder
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let decoderSource = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(current.path))
        XCTAssertEqual(current.path, predecessor.path)
        XCTAssertEqual(current.gitMode, "100644")
        XCTAssertEqual(
            current.gitBlob,
            "de6cff4472de55a8fafe2962c3be4ca37c972caf")
        XCTAssertEqual(current.byteCount, 43_339)
        XCTAssertEqual(
            current.sha256,
            "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc")
        XCTAssertEqual(current.gitBlob, gitBlobOID(of: decoderSource))
        XCTAssertEqual(current.byteCount, decoderSource.count)
        XCTAssertEqual(
            current.sha256,
            PrimeSHA256.hexDigest(of: decoderSource))
        XCTAssertNotEqual(current.gitBlob, predecessor.gitBlob)
        XCTAssertNotEqual(current.byteCount, predecessor.byteCount)
        XCTAssertNotEqual(current.sha256, predecessor.sha256)
        XCTAssertEqual(current.sourceAuthorityID, authority.authorityID)
        XCTAssertEqual(
            current.sourceAuthorityCanonicalSHA256,
            binding.authorityCanonicalSHA256)
        XCTAssertEqual(
            current.authorizedMutationScope,
            authority.successorScope.decoderSourceMutationScope)
        XCTAssertEqual(
            observation.packageOnlyDenseLogitsMethod,
            "trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1")
        XCTAssertEqual(
            observation.packageOnlyEmbeddingForwardPairMethod,
            "trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1")
        XCTAssertTrue(
            observation
                .predecessorDecoderIdentityRemainsHistoricalAndFrozen)
        XCTAssertTrue(
            observation.currentDecoderIdentityIsSoleRetainedLiveIdentity)
        XCTAssertTrue(observation.defaultGatherPathRemainsUnchanged)
        XCTAssertTrue(observation.implementationObservedByThisObservation)
        XCTAssertFalse(observation.executionObservedByThisObservation)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.authorityClosureObserved)
        XCTAssertTrue(ceiling.currentDecoderImplementationIdentityObserved)
        XCTAssertTrue(falseCeilings(observation).allSatisfy { !$0 })
        XCTAssertEqual(
            observation.status,
            "OBSERVED_current_stage5_replacement_decoder_source_identity_only_no_execution_stage5_result_or_stage7_authority")

        requireSendable(Observation.self)
        let canonical = try observation.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Observation.canonicalSHA256)
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let arrayPaths = allArrayPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 100)
        XCTAssertGreaterThan(dictionaryPaths.count, 5)
        XCTAssertGreaterThan(arrayPaths.count, 2)
        XCTAssertGreaterThan(scalarPaths.count, 85)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))")
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutatedData), loose != observation
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
        XCTAssertGreaterThan(regularDecodedDriftCount, 85)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(in: object, at: path) { value in
                var dictionary = value as! [String: Any]
                dictionary["unknown_stage5_identity_field_\(index)"] = true
                return dictionary
            }
            let data = try assertCanonicalRejects(
                unknown,
                label: "unknown \(pathLabel(path))")
            XCTAssertEqual(
                try JSONDecoder().decode(Observation.self, from: data),
                observation)
        }

        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(in: object, at: path) { value in
                var array = value as! [Any]
                guard array.count >= 2 else { return array }
                for left in 0 ..< array.count {
                    for right in (left + 1) ..< array.count {
                        if canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            didReorder = true
                            return array
                        }
                    }
                }
                return array
            }
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered,
                    label: "reordered \(pathLabel(path))")
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 2)
        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift")
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

    private func falseCeilings(_ observation: Observation) -> [Bool] {
        let ceiling = observation.authorityCeiling
        return [
            ceiling.currentDecoderExecutionObserved,
            ceiling.replacementAssayExecutionObserved,
            ceiling.stage5ResultEstablished,
            ceiling.stage5ClearanceEstablished,
            ceiling.defaultGatherPathMutated,
            ceiling.publicDecoderAPIAdded,
            ceiling.checkpointAuthorityReinterpreted,
            ceiling.runtimeAuthorityReinterpreted,
            ceiling.tokenizerAuthorityReinterpreted,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
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
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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
            try Observation.decodeCanonical(data),
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
            try Observation.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Observation.decodeCanonical(canonical + Data([0x0a])))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Observation.decodeCanonical(Data(slashEscaped.utf8)))

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
            try Observation.decodeCanonical(Data(reordered.utf8)))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicate.startIndex))
        XCTAssertThrowsError(
            try Observation.decodeCanonical(Data(duplicate.utf8)))
    }

    private func gitBlobOID(of data: Data) -> String {
        let header = Data("blob \(data.count)\0".utf8)
        let digest = Insecure.SHA1.hash(data: header + data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

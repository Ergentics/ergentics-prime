// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityV1

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
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical),
            authority)
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical).canonicalData(),
            canonical)

        XCTAssertEqual(authority.stageID, "tiny_cpu_explicit_rng_cursor_resume_v1")
        XCTAssertEqual(
            authority.requiredPredecessorStageID,
            "tiny_cpu_train_evaluate_mechanics_v1")
        XCTAssertTrue(authority.stage2Evidence.stage2MechanicsEstablished)
        XCTAssertTrue(authority.stage2Evidence.stage2InvocationRetired)
        XCTAssertEqual(authority.fixture.snapshotGlobalStep, 1)
        XCTAssertEqual(authority.fixture.terminalGlobalStep, 2)
        XCTAssertEqual(authority.fixture.trainableParameterPathCount, 20)
        XCTAssertEqual(authority.fixture.firstMomentTensorCount, 20)
        XCTAssertEqual(authority.fixture.secondMomentTensorCount, 20)
        XCTAssertEqual(
            authority.randomDesign.requiredDomains,
            PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases)
        XCTAssertFalse(authority.randomDesign.implicitGlobalRandomStateAuthorized)
        XCTAssertFalse(authority.randomDesign.mlxRandomStateInnerStateImporterAuthorized)
        XCTAssertFalse(authority.randomDesign.underscoredMLXArrayMutationAuthorized)
        XCTAssertTrue(authority.cursorDesign.cursorPointsToNextUnconsumedBatch)
        XCTAssertFalse(authority.cursorDesign.skipOrDuplicateBatchPermitted)
        XCTAssertTrue(authority.snapshotBoundary.restoreTargetMustBeFresh)
        XCTAssertTrue(
            authority.snapshotBoundary.restoreTargetOptimizerMustBeUninitialized)
        XCTAssertFalse(
            authority.snapshotBoundary.exportProducesAliasedMutableTensorReferences)
        XCTAssertTrue(authority.witness.step2ResultEqualityRequired)
        XCTAssertTrue(authority.witness.tensorValueEqualityIsBitExact)
        XCTAssertFalse(authority.witness.digestEqualityAloneIsSufficient)
        XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 6)
        XCTAssertTrue(authority.successorScope.newHostedLauncherRequired)
        XCTAssertTrue(authority.ceiling.authorityOnlyNoExecutionEvidence)
        XCTAssertTrue(
            authority.ceiling.implementationAuthorizedAfterGreenAuthorityClosure)
        XCTAssertTrue(authority.ceiling.oneExactMainExecutionOpportunityAuthorized)
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
        XCTAssertGreaterThan(leafPaths.count, 140)
        XCTAssertGreaterThan(dictionaryPaths.count, 9)
        XCTAssertGreaterThan(arrayPaths.count, 8)

        for path in leafPaths {
            var mutated: Any = object
            let original = try XCTUnwrap(value(at: path, in: mutated))
            try setValue(mutatedScalar(original), at: path, in: &mutated)
            assertRejected(
                mutated,
                label: "scalar \(pathLabel(path))")
        }

        for (index, path) in dictionaryPaths.enumerated() {
            var unknown: Any = object
            var dictionary = try XCTUnwrap(
                value(at: path, in: unknown) as? [String: Any])
            dictionary["unknown_stage3_rng_cursor_authority_field_\(index)"] =
                index
            try setValue(dictionary, at: path, in: &unknown)
            assertRejected(
                unknown,
                label: "unknown \(pathLabel(path))")

            guard !dictionary.isEmpty,
                  let key = dictionary.keys.sorted().first(where: {
                      !$0.hasPrefix("unknown_stage3_")
                  })
            else { continue }
            var removed: Any = object
            var removedDictionary = try XCTUnwrap(
                value(at: path, in: removed) as? [String: Any])
            removedDictionary.removeValue(forKey: key)
            try setValue(removedDictionary, at: path, in: &removed)
            assertRejected(
                removed,
                label: "removed \(pathLabel(path)).\(key)")
        }

        for path in arrayPaths {
            let array = try XCTUnwrap(value(at: path, in: object) as? [Any])
            if !array.isEmpty {
                var shortened: Any = object
                var value = array
                value.removeLast()
                try setValue(value, at: path, in: &shortened)
                assertRejected(
                    shortened,
                    label: "shortened \(pathLabel(path))")

                var extended: Any = object
                value = array
                value.append(array[0])
                try setValue(value, at: path, in: &extended)
                assertRejected(
                    extended,
                    label: "extended \(pathLabel(path))")
            }
            if array.count > 1 {
                var reordered: Any = object
                var value = array
                value.swapAt(0, 1)
                try setValue(value, at: path, in: &reordered)
                assertRejected(
                    reordered,
                    label: "reordered \(pathLabel(path))")
            }
        }

        var nullMutation: Any = object
        try setValue(NSNull(), at: leafPaths[0], in: &nullMutation)
        assertRejected(nullMutation, label: "null \(pathLabel(leafPaths[0]))")

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))

        let duplicate = try duplicateFirstTopLevelKey(in: canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicate))

        let sourceURL = repositoryRoot()
            .appendingPathComponent(
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift")
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
        _ ceiling: PrimeNativeDecoderTinyCPUResumeAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.filesystemMutationAuthorized,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointCodecMutationAuthorized,
            ceiling.artifactRootAuthorized,
            ceiling.durableSnapshotEncodingAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalDeterminismEstablished,
            ceiling.runtimeLoadedMetallibIdentityEstablished,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.stage4Authorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
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
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError
                .contractDrift
        }
        let insertion = "\"\(key)\":null,"
        return Data(("{" + insertion + text.dropFirst()).utf8)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}

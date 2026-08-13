// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
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
            authority.base.originalAuthorityCanonicalSHA256,
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1
                .canonicalSHA256)
        XCTAssertEqual(authority.base.rootTestCount, 49)
        XCTAssertEqual(authority.base.metalTestCount, 44)
        XCTAssertEqual(authority.base.runtimeReceiptCount, 1)
        XCTAssertEqual(authority.base.tokenizerReceiptCount, 1)
        XCTAssertEqual(authority.base.stage4LauncherInvocationCount, 0)
        XCTAssertEqual(authority.base.rerunCount, 0)
        XCTAssertEqual(authority.base.artifactCount, 0)
        XCTAssertTrue(authority.base.authorityExactMainClosureEstablished)
        XCTAssertEqual(authority.lock.mode, "100644")
        XCTAssertEqual(
            authority.lock.gitBlob,
            "14d804bb4291720477240c27e24de6fbdc876b3b")
        XCTAssertEqual(authority.lock.byteCount, 645)
        XCTAssertEqual(authority.lock.formatVersion, 3)
        XCTAssertEqual(
            authority.lock.originHash,
            "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2")
        XCTAssertEqual(
            authority.lock.orderedPinIdentities,
            ["ergentics-mlx-swift", "swift-numerics"])
        XCTAssertEqual(authority.resolution.successfulResolutionCount, 2)
        XCTAssertEqual(
            authority.resolution.beforeLockGitBlob,
            authority.resolution.afterLockGitBlob)
        XCTAssertEqual(
            authority.resolution.beforeLockSHA256,
            authority.resolution.afterLockSHA256)
        XCTAssertFalse(authority.resolution.pinsChanged)
        XCTAssertFalse(authority.resolution.originHashChanged)
        XCTAssertFalse(authority.resolution.lockBytesChanged)
        XCTAssertFalse(authority.resolution.externalDependencyGraphChanged)
        XCTAssertFalse(
            authority.resolution.packageResolvedMutationMechanicallyRequired)
        XCTAssertFalse(authority.resolution.fabricatedLockMutationAuthorized)
        XCTAssertEqual(authority.repair.originalMechanicsPathCount, 9)
        XCTAssertEqual(authority.repair.repairedMechanicsPathCount, 8)
        XCTAssertEqual(authority.repair.removedMechanicsPath, "Package.resolved")
        XCTAssertFalse(authority.repair.packageResolvedMutationAuthorized)
        XCTAssertTrue(authority.repair.packageResolvedPreservationRequired)
        XCTAssertEqual(authority.repair.repairAuthorityRootTestCount, 50)
        XCTAssertEqual(
            authority.repair.implementationFocusedWholeTestCount,
            56)
        XCTAssertEqual(authority.repair.preStage4TotalTestCount, 102)
        XCTAssertEqual(authority.repair.stage4DirectXCTestCount, 1)
        XCTAssertEqual(authority.repair.totalTestCount, 103)
        XCTAssertTrue(
            authority.repair
                .oneMechanicsSuccessorAfterGreenRepairClosureAuthorized)
        XCTAssertTrue(authority.ceiling.authorityOnlyNoMechanicsExecutionEvidence)
        XCTAssertTrue(authority.ceiling.mechanicsFaultMatrixPreserved)
        XCTAssertTrue(authority.ceiling.fourLeafPublicationOrderPreserved)
        XCTAssertTrue(authority.ceiling.finalCommitPublishedLastPreserved)
        XCTAssertTrue(authority.ceiling.partialWriteQuarantinePreserved)
        XCTAssertTrue(authority.ceiling.externalExactCommitBindingPreserved)
        XCTAssertTrue(authority.ceiling.tinyWeightsFixtureIsNotNative300MExactV2)
        XCTAssertTrue(authority.ceiling.native300MExactV2CompositionDeferred)
        XCTAssertTrue(authorityFalseClaims(authority.ceiling).allSatisfy { !$0 })
        XCTAssertTrue(authority.ceiling.terminalMechanicsOutcomeObservationRequired)

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
        XCTAssertGreaterThan(leafPaths.count, 105)
        XCTAssertGreaterThan(dictionaryPaths.count, 5)
        XCTAssertGreaterThan(arrayPaths.count, 3)

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
            dictionary["unknown_stage4_package_resolved_repair_field_\(index)"] =
                index
            try setValue(dictionary, at: path, in: &unknown)
            assertRejected(unknown, label: "unknown \(pathLabel(path))")

            guard !dictionary.isEmpty,
                  let key = dictionary.keys.sorted().first(where: {
                      !$0.hasPrefix("unknown_stage4_")
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
                assertRejected(shortened, label: "shortened \(pathLabel(path))")

                var extended: Any = object
                value = array
                value.append(array[0])
                try setValue(value, at: path, in: &extended)
                assertRejected(extended, label: "extended \(pathLabel(path))")
            }
            if array.count > 1 {
                var reordered: Any = object
                var value = array
                value.swapAt(0, 1)
                try setValue(value, at: path, in: &reordered)
                assertRejected(reordered, label: "reordered \(pathLabel(path))")
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
        XCTAssertThrowsError(
            try Authority.decodeCanonical(duplicateFirstTopLevelKey(in: canonical)))

        let sourceURL = repositoryRoot().appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthority.swift")
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
        _ ceiling:
            PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairCeilingV1
    ) -> [Bool] {
        [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.publicV2CodecWideningAuthorized,
            ceiling.metalDeterminismEstablished,
            ceiling.stage5Authorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.productOrPublicationAuthorized,
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
        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        else {
            XCTFail(label, file: file, line: line)
            return
        }
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
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityError
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

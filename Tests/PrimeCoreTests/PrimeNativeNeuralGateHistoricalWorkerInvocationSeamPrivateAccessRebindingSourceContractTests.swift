// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Darwin
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContract
    private typealias Identity =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity

    private struct CompilerResult {
        let status: Int32
        let terminationReason: Process.TerminationReason?
        let output: String
        let timedOut: Bool
    }

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContract.swift"
    private static let contractFileByteCount: UInt64 = 42_203
    private static let contractFileSHA256 =
        "433b6bfe5bff064e7c499e7f2de41810d8f3d05b397d5805213b67a3ab66a889"
    private static let contractContentSHA256 =
        "92f6abf8417d7845d5425b973f7a45d13297bc5af736bd1a9248bc39fdc191ce"

    func testFrozenV27BindsV26AndExactPhysicalReceipt() throws {
        let contract = Contract.frozenV1
        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV26

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_v27"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(design)
            ),
            contract.preservedPrivateAccessRebindingDesignV26ContractSHA256
        )
        XCTAssertEqual(
            contract.preservedPrivateAccessRebindingDesignV26ContractSHA256,
            "58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(topology)
            ),
            contract.preservedTopologyV26SHA256
        )
        XCTAssertEqual(
            contract.preservedTopologyV26SHA256,
            "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63"
        )

        for identity in liveExactIdentities(contract) {
            let data = try PrimeHistoricalSourceEvolutionTestSupport.historicalData(
                path: identity.primeRelativePath, current: checkedInData(identity.primeRelativePath),
                expectedByteCount: identity.byteCount, expectedSHA256: identity.sha256)
            XCTAssertEqual(
                UInt64(data.count),
                identity.byteCount,
                identity.primeRelativePath
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                identity.sha256,
                identity.primeRelativePath
            )
        }
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV27.byteCount,
            273_346
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV27.sha256,
            "d4446c98bb5e3baed9ecd62b1a7aa7734e62e5264463597d4fbf2c17410529b7"
        )
        XCTAssertEqual(
            contract.historicalTestIdentitiesBeforeV27.map(\.byteCount),
            [32_576, 28_931, 33_946, 29_270]
        )
        XCTAssertEqual(
            contract.historicalTestIdentitiesAfterV27.map(\.byteCount),
            [33_756, 30_344, 34_735, 32_076]
        )

        let source = try checkedInData(Self.contractRelativePath)
        XCTAssertEqual(UInt64(source.count), Self.contractFileByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            Self.contractFileSHA256
        )
        try PrimeHistoricalSourceEvolutionTestSupport.assertRejectedMutations(root: repositoryRoot)
    }

    func testExactForwardProjectionAndReverseReconstruction() throws {
        let contract = Contract.frozenV1
        let geometry = contract.adoptedMutation
        let projected = try checkedInData(geometry.sourceRelativePath)
        let lower = Int(geometry.accessTokenUTF8Offset)
        let oldUpper = Int(geometry.accessTokenRangeExclusiveUpperBound)
        let oldToken = Data(geometry.currentAccessToken.utf8)
        let privateToken = Data(geometry.projectedAccessToken.utf8)

        XCTAssertEqual(
            UInt64(projected.count),
            geometry.projectedSourceByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: projected),
            geometry.projectedSourceSHA256
        )
        XCTAssertEqual(
            projected.subdata(in: lower ..< lower + privateToken.count),
            privateToken
        )
        let prefix = Data(projected.prefix(lower))
        let suffix = Data(
            projected.suffix(from: lower + privateToken.count)
        )
        XCTAssertEqual(
            UInt64(prefix.count),
            geometry.unchangedPrefixByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefix),
            geometry.unchangedPrefixSHA256
        )
        XCTAssertEqual(
            UInt64(suffix.count),
            geometry.unchangedSuffixByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            geometry.unchangedSuffixSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: Data(
                    projected.prefix(
                        Int(geometry.projectedPreV25SegmentByteCount)
                    )
                )
            ),
            geometry.projectedPreV25SegmentSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: Data(
                    projected.suffix(
                        Int(geometry.unchangedV25SuffixByteCount)
                    )
                )
            ),
            geometry.unchangedV25SuffixSHA256
        )

        var historicalV25 = projected
        historicalV25.replaceSubrange(
            lower ..< lower + privateToken.count,
            with: oldToken
        )
        XCTAssertEqual(
            UInt64(historicalV25.count),
            geometry.currentSourceByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: historicalV25),
            geometry.currentSourceSHA256
        )
        XCTAssertEqual(
            historicalV25.subdata(in: lower ..< oldUpper),
            oldToken
        )

        var roundTrip = historicalV25
        roundTrip.replaceSubrange(
            lower ..< oldUpper,
            with: privateToken
        )
        XCTAssertEqual(roundTrip, projected)
    }

    func testPrivateSourceShapeInventoryBoundaryAndMainRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(contract.workerTargetName)
        let source = try checkedInString(
            contract.workerPrivateInvocationSeamAndBoundarySourceV27
                .primeRelativePath
        )
        let compact = source.filter { !$0.isWhitespace }

        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            (
                contract.orderedWorkerSwiftSourceRelativePaths
                    + contract.workerResourceRelativePaths
            ).sorted()
        )
        XCTAssertEqual(contract.exactWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(contract.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(contract.exactWorkerResourceCount, 1)
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "internalstaticfuncsourceBoundUnavailableHistoricalWorkerInvocationSeam(",
                in: compact
            ),
            0
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "privatestaticfuncsourceBoundUnavailableHistoricalWorkerInvocationSeam(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.adoptedMutation.rawSeamMethodName + "(",
                in: source
            ),
            2
        )
        XCTAssertEqual(
            occurrenceCount(
                of: ".\(contract.adoptedMutation.rawSeamMethodName)(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.preservedBoundaryMethodName + "(",
                in: source
            ),
            1
        )

        let imports = source.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            contract.exactInvocationSourceImportNames.map { "import \($0)" }
        )

        let main = try checkedInString(contract.workerMain.primeRelativePath)
        let compactMain = main.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compactMain.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertFalse(main.contains(contract.adoptedMutation.rawSeamMethodName))
        XCTAssertFalse(main.contains(contract.preservedBoundaryMethodName))
    }

    func testActualSourceBaselineAndFifthFileCompilerCanary()
        throws
    {
        let contract = Contract.frozenV1
        let root = try compilerCanaryRoot(label: "actual-fifth-file")
        defer { try? FileManager.default.removeItem(at: root) }
        let layout = try PrimeCurrentTestBuildLayout.capture(testClass: Self.self, sourceFilePath: #filePath)
        let inputs = try layout.workerCompilerInputs(expectedRelativeSources: contract.orderedWorkerSwiftSourceRelativePaths)
        let modules = inputs.modules
        let accessor = inputs.accessor
        let sourcePaths = contract.orderedWorkerSwiftSourceRelativePaths.map {
            repositoryRoot.appendingPathComponent($0).path
        } + [accessor.path]
        let baseArguments = [
            "swiftc",
            "-typecheck",
            "-parse-as-library",
            "-module-name",
            contract.workerTargetName,
            "-I",
            modules.path,
            "-module-cache-path",
            root.appendingPathComponent("ModuleCache").path,
        ] + sourcePaths

        let baseline = try runCompiler(
            arguments: baseArguments,
            root: root,
            label: "baseline"
        )
        try layout.revalidate()
        XCTAssertFalse(baseline.timedOut)
        XCTAssertEqual(baseline.terminationReason, .exit)
        XCTAssertEqual(baseline.status, 0, baseline.output)

        let probe = root.appendingPathComponent("CrossFileProbe.swift")
        try """
        extension PrimeNativeNeuralGateHistoricalFixtureWorker
            .PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult
        {
            static func v27CrossFileProbe() {
                _ = Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam
            }
        }
        """.write(to: probe, atomically: true, encoding: .utf8)
        let rejected = try runCompiler(
            arguments: baseArguments + [probe.path],
            root: root,
            label: "rejected"
        )
        try layout.revalidate()
        XCTAssertFalse(rejected.timedOut)
        XCTAssertEqual(rejected.terminationReason, .exit)
        XCTAssertNotEqual(rejected.status, 0)
        XCTAssertTrue(
            rejected.output.contains(
                "'sourceBoundUnavailableHistoricalWorkerInvocationSeam' is inaccessible due to 'private' protection level"
            ),
            rejected.output
        )
        XCTAssertEqual(
            rejected.output.split(separator: "\n").filter {
                $0.contains(": error:")
            }.count,
            1,
            rejected.output
        )
    }

    func testTestableImportDirectNameCompilerCanary() throws {
        let contract = Contract.frozenV1
        let root = try compilerCanaryRoot(label: "testable-import")
        defer { try? FileManager.default.removeItem(at: root) }
        let layout = try PrimeCurrentTestBuildLayout.capture(testClass: Self.self, sourceFilePath: #filePath)
        let modules = try layout.workerCompilerInputs(expectedRelativeSources: contract.orderedWorkerSwiftSourceRelativePaths).modules
        let probe = root.appendingPathComponent("TestableProbe.swift")
        try """
        @testable import \(contract.workerTargetName)

        func v27TestableProbe() {
            _ = PrimeNativeNeuralGateHistoricalFixtureWorker
                .PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult
                .sourceBoundUnavailableHistoricalWorkerInvocationSeam
        }
        """.write(to: probe, atomically: true, encoding: .utf8)
        let result = try runCompiler(
            arguments: [
                "swiftc",
                "-typecheck",
                "-parse-as-library",
                "-I",
                modules.path,
                "-module-cache-path",
                root.appendingPathComponent("ModuleCache").path,
                probe.path,
            ],
            root: root,
            label: "testable"
        )
        try layout.revalidate()
        XCTAssertFalse(result.timedOut)
        XCTAssertEqual(result.terminationReason, .exit)
        XCTAssertNotEqual(result.status, 0)
        XCTAssertTrue(
            result.output.contains(
                "'\(contract.adoptedMutation.rawSeamMethodName)' is inaccessible due to 'private' protection level"
            ),
            result.output
        )
    }

    func testAuthorityAndBroadSuiteObservationRemainFailClosed() {
        let contract = Contract.frozenV1

        XCTAssertFalse(contract.releaseWorkerProductLaunched)
        XCTAssertFalse(contract.mainReferencesRawSeamOrBoundary)
        XCTAssertFalse(contract.crossFileBoundaryCallerMaterialized)
        XCTAssertFalse(contract.runtimeReachableFromMain)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertFalse(contract.runtimeInputAccepted)
        XCTAssertFalse(contract.runtimeOutputProduced)
        XCTAssertFalse(contract.requestHandlingEnabled)
        XCTAssertFalse(contract.workerLaunched)
        XCTAssertFalse(contract.workerExecuted)
        XCTAssertFalse(contract.artifactWritePerformed)
        XCTAssertFalse(contract.evidencePublished)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
        XCTAssertTrue(
            contract.ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented
        )
        XCTAssertFalse(contract.authenticatedCallerPolicyEstablished)
        XCTAssertFalse(contract.confidentialityEstablished)
        XCTAssertFalse(contract.zeroizationEstablished)
        XCTAssertFalse(contract.constantTimeEstablished)
        XCTAssertFalse(contract.constantResourceUseEstablished)
        XCTAssertFalse(contract.trapsSignalsOrOutOfMemoryContained)
        XCTAssertTrue(
            contract.hardenedIsolationRequiredBeforeUntrustedRuntime
        )
        XCTAssertEqual(
            contract.broadRepositorySuiteObservation,
            .notCompletedWithinBoundedObservation
        )
        XCTAssertEqual(
            contract.broadRepositorySuiteBoundedObservationSeconds,
            1_800
        )
        XCTAssertFalse(contract.broadRepositorySuiteCountsAsPassing)
        XCTAssertFalse(contract.gitConfigurationCauseEstablished)
        XCTAssertTrue(
            contract.recursivePredecessorValidationPerformanceDebtObserved
        )
        XCTAssertFalse(contract.performanceRemediationIncludedInV27)
    }

    func testFrozenV27CanonicalRoundTripAndHash() throws {
        let contract = Contract.frozenV1
        let canonical = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: canonical
        )
        let plain = try JSONDecoder().decode(
            Contract.self,
            from: canonical
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertEqual(plain, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Self.contractContentSHA256
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            Self.contractContentSHA256
        )
    }

    func testCanonicalKeysAreExplicitLowerSnakeCase() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let source = try checkedInString(Self.contractRelativePath)
            + checkedInString(
                "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract.swift"
            )

        for key in allObjectKeys(in: object).sorted() {
            XCTAssertTrue(isLowerSnakeCase(key), key)
            XCTAssertTrue(
                source.contains("\"\(key)\"")
                    || source.contains("case \(key)"),
                key
            )
        }
    }

    func testEveryCanonicalFieldMutationFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let mutation = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            try assertDecodingOrValidationFails(
                try JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                ),
                label: path.joined(separator: ".")
            )
        }
    }

    func testEveryCanonicalFieldIsRequiredAndRejectsNull() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let label = path.joined(separator: ".")
            let missing = try JSONSerialization.data(
                withJSONObject: removingValue(in: object, at: path),
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: missing),
                "missing \(label)"
            )
            let null = try JSONSerialization.data(
                withJSONObject: replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: null),
                "null \(label)"
            )
        }
    }

    func testUnknownCanonicalFieldFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["unknown_runtime_authority"] = true
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )

        XCTAssertNoThrow(
            try JSONDecoder().decode(Contract.self, from: data).validate()
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(Contract.self, from: data)
        )
    }

    private func liveExactIdentities(
        _ contract: Contract
    ) -> [Identity] {
        [
            contract.privateAccessRebindingDesignContractSource,
            contract.topologyV26Test,
            contract.packageSwift,
            contract.packageResolved,
            contract.workerMain,
            contract.workerEvidenceExportCallEdgeSource,
            contract.workerProjectionCallEdgeSource,
            contract.workerPrivateInvocationSeamAndBoundarySourceV27,
            contract.workerFixtureResource,
        ] + contract.historicalTestIdentitiesAfterV27
    }

    private func compilerCanaryRoot(label: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-v27-\(label)-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false
        )
        return root
    }

    private func runCompiler(
        arguments: [String],
        root: URL,
        label: String
    ) throws -> CompilerResult {
        let outputURL = root.appendingPathComponent("\(label).log")
        FileManager.default.createFile(
            atPath: outputURL.path,
            contents: Data()
        )
        let outputHandle = try FileHandle(forWritingTo: outputURL)
        defer { try? outputHandle.close() }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = arguments
        process.standardOutput = outputHandle
        process.standardError = outputHandle
        let completed = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in completed.signal() }
        try process.run()
        let firstWait = completed.wait(timeout: .now() + 30)
        var timedOut = firstWait == .timedOut
        if timedOut {
            process.terminate()
            if completed.wait(timeout: .now() + 3) == .timedOut {
                kill(process.processIdentifier, SIGKILL)
                _ = completed.wait(timeout: .now() + 3)
            }
        }
        try outputHandle.synchronize()
        let output = try String(
            contentsOf: outputURL,
            encoding: .utf8
        )
        if process.isRunning {
            timedOut = true
        }
        if process.isRunning {
            return CompilerResult(
                status: -1,
                terminationReason: nil,
                output: output,
                timedOut: true
            )
        }
        return CompilerResult(
            status: process.terminationStatus,
            terminationReason: process.terminationReason,
            output: output,
            timedOut: timedOut
        )
    }

    private func checkedInData(_ relativePath: String) throws -> Data {
        try Data(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath)
        )
    }

    private func checkedInString(_ relativePath: String) throws -> String {
        try String(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }

    private func recursiveRegularFilePaths(
        in directory: URL
    ) throws -> [String] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: Array(keys)
            )
        )
        let root = repositoryRoot.standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let url as URL in enumerator {
            let values = try url.resourceValues(forKeys: keys)
            let path = url.standardizedFileURL.path
            let relative = String(path.dropFirst(root.count))
            if values.isSymbolicLink == true {
                throw NSError(
                    domain: "PrimeV27Inventory",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: relative]
                )
            }
            if values.isRegularFile == true {
                paths.append(relative)
            }
        }
        return paths.sorted()
    }

    private func occurrenceCount(
        of needle: String,
        in haystack: String
    ) -> Int {
        var count = 0
        var start = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: start ..< haystack.endIndex
        ) {
            count += 1
            start = range.upperBound
        }
        return count
    }

    private func allObjectKeys(in value: Any) -> Set<String> {
        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: Set(dictionary.keys)) {
                $0.formUnion(allObjectKeys(in: $1.value))
            }
        }
        if let array = value as? [Any] {
            return array.reduce(into: Set<String>()) {
                $0.formUnion(allObjectKeys(in: $1))
            }
        }
        return []
    }

    private func isLowerSnakeCase(_ key: String) -> Bool {
        !key.isEmpty
            && key == key.lowercased()
            && !key.hasPrefix("_")
            && !key.hasSuffix("_")
            && !key.contains("__")
            && key.unicodeScalars.allSatisfy {
                ($0.value >= 97 && $0.value <= 122)
                    || ($0.value >= 48 && $0.value <= 57)
                    || $0.value == 95
            }
    }

    private func requiredFieldPaths(
        in object: [String: Any]
    ) -> [[String]] {
        object.keys.sorted().flatMap { key in
            [[key]] + nestedLeafPaths(object[key]!, prefix: [key])
        }
    }

    private func nestedLeafPaths(
        _ value: Any,
        prefix: [String]
    ) -> [[String]] {
        guard let dictionary = value as? [String: Any] else {
            return []
        }
        return dictionary.keys.sorted().flatMap { key in
            let path = prefix + [key]
            return [path] + nestedLeafPaths(dictionary[key]!, prefix: path)
        }
    }

    private func replacingValue(
        in object: [String: Any],
        at path: [String],
        with transform: (Any) -> Any
    ) -> [String: Any] {
        var copy = object
        guard let key = path.first else { return copy }
        if path.count == 1 {
            copy[key] = transform(copy[key]!)
        } else {
            copy[key] = replacingValue(
                in: copy[key] as! [String: Any],
                at: Array(path.dropFirst()),
                with: transform
            )
        }
        return copy
    }

    private func removingValue(
        in object: [String: Any],
        at path: [String]
    ) -> [String: Any] {
        var copy = object
        guard let key = path.first else { return copy }
        if path.count == 1 {
            copy.removeValue(forKey: key)
        } else {
            copy[key] = removingValue(
                in: copy[key] as! [String: Any],
                at: Array(path.dropFirst())
            )
        }
        return copy
    }

    private func assertDecodingOrValidationFails(
        _ data: Data,
        label: String
    ) throws {
        do {
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: data
            )
            XCTAssertThrowsError(try decoded.validate(), label)
        } catch {
            XCTAssertNotNil(error, label)
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        switch value {
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return number.int64Value + 1
        case let string as String:
            return string + "_mutated"
        case let array as [Any]:
            guard let first = array.first else {
                return ["mutated"]
            }
            return [mutateJSONValue(first)] + Array(array.dropFirst())
        case let dictionary as [String: Any]:
            var copy = dictionary
            guard let key = dictionary.keys.sorted().first,
                  let current = dictionary[key]
            else {
                return ["mutated": true]
            }
            copy[key] = mutateJSONValue(current)
            return copy
        default:
            return NSNull()
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

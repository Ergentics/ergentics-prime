// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Darwin
import Foundation
@testable import PrimeCore
import XCTest

private enum V26PrivateAccessCanaryError: Error {
    case rejected
}

private enum V26PrivateAccessCanaryDisposition {
    case completedAndDiscarded
    case failedClosed
}

private struct V26PrivateAccessCanary {
    private static func rawSeam(
        shouldThrow: Bool
    ) throws -> Int {
        if shouldThrow {
            throw V26PrivateAccessCanaryError.rejected
        }
        return 26
    }
}

private extension V26PrivateAccessCanary {
    static func boundary(
        shouldThrow: Bool
    ) -> V26PrivateAccessCanaryDisposition {
        do {
            _ = try Self.rawSeam(shouldThrow: shouldThrow)
            return .completedAndDiscarded
        } catch {
            return .failedClosed
        }
    }
}

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract
    private typealias Identity =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract.swift"
    private static let contractFileByteCount: UInt64 = 53_925
    private static let contractFileSHA256 =
        "9c1f8144e776a8dadf1c0586aaf470a44496e5168bf8079780c87d17ee424fd5"
    private static let contractContentSHA256 =
        "58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e"

    func testFrozenV26BindsV25AndExactCurrentSource() throws {
        let contract = Contract.frozenV1
        let source =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV25

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_v26"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(source)
            ),
            contract
                .preservedCallerAndResultConsumerSourceV25ContractSHA256
        )
        XCTAssertEqual(
            contract
                .preservedCallerAndResultConsumerSourceV25ContractSHA256,
            "21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(topology)
            ),
            contract.preservedTopologyV25SHA256
        )
        XCTAssertEqual(
            contract.preservedTopologyV25SHA256,
            "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3"
        )

        for identity in liveExactIdentities(contract) {
            let data = try checkedInData(identity.primeRelativePath)
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

        let liveV27Source = try checkedInData(
            contract.mutation.sourceRelativePath
        )
        let reconstructedV25Source = try reconstructedV25Source(
            fromV27Source: liveV27Source,
            geometry: contract.mutation
        )
        XCTAssertEqual(
            UInt64(reconstructedV25Source.count),
            contract.workerInvocationSeamAndBoundarySourceV25.byteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: reconstructedV25Source),
            contract.workerInvocationSeamAndBoundarySourceV25.sha256
        )

        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV26.byteCount,
            261_012
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV26.sha256,
            "d613057c800ca5bfeef57d5142d03bb94b9d41a9a7dc4a17100dce8eb4d98195"
        )

        let contractSource = try checkedInData(Self.contractRelativePath)
        XCTAssertEqual(
            UInt64(contractSource.count),
            Self.contractFileByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: contractSource),
            Self.contractFileSHA256
        )
    }

    func testExactOneTokenProjectionAndReverseReconstruction() throws {
        let contract = Contract.frozenV1
        let geometry = contract.mutation
        let projected = try checkedInData(geometry.sourceRelativePath)
        let lower = Int(geometry.accessTokenUTF8Offset)
        let upper = Int(geometry.accessTokenRangeExclusiveUpperBound)
        let currentToken = Data(geometry.currentAccessToken.utf8)
        let projectedToken = Data(geometry.projectedAccessToken.utf8)

        XCTAssertEqual(
            UInt64(projected.count),
            geometry.projectedSourceByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: projected),
            geometry.projectedSourceSHA256
        )
        XCTAssertEqual(
            projected.subdata(
                in: lower ..< lower + projectedToken.count
            ),
            projectedToken
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: currentToken),
            geometry.currentAccessTokenSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: projectedToken),
            geometry.projectedAccessTokenSHA256
        )

        let prefix = Data(projected.prefix(lower))
        let suffix = Data(
            projected.suffix(from: lower + projectedToken.count)
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
            Data(
                projected.prefix(
                    Int(geometry.projectedPreV25SegmentByteCount)
                )
            ).count,
            Int(geometry.projectedPreV25SegmentByteCount)
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

        var current = projected
        current.replaceSubrange(
            lower ..< lower + projectedToken.count,
            with: currentToken
        )
        XCTAssertEqual(UInt64(current.count), geometry.currentSourceByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: current),
            geometry.currentSourceSHA256
        )
        XCTAssertEqual(
            current.subdata(in: lower ..< upper),
            currentToken
        )

        var reversed = current
        reversed.replaceSubrange(
            lower ..< upper,
            with: projectedToken
        )
        XCTAssertEqual(reversed, projected)
    }

    func testV27SourceRealizesV26ShapeInventoryAndSoleCaller() throws {
        let contract = Contract.frozenV1
        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(contract.workerTargetName)
        let source = try checkedInString(
            contract.mutation.sourceRelativePath
        )
        let compact = source.filter { !$0.isWhitespace }

        XCTAssertTrue(contract.designOnly)
        XCTAssertFalse(contract.checkedInWorkerSourceChangedByV26)
        XCTAssertFalse(contract.futureSourceContractMaterialized)
        XCTAssertFalse(contract.projectedWorkerSourceCheckedIn)
        XCTAssertFalse(contract.mutation.sourceEvolutionAppendOnly)
        XCTAssertTrue(
            contract.mutation
                .sourceEvolutionSingleNonAppendOnlyTokenReplacement
        )
        XCTAssertFalse(contract.mutation.anyOtherSourceByteMayChange)

        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            (
                contract.orderedCurrentWorkerSwiftSourceRelativePaths
                    + contract.workerResourceRelativePaths
            ).sorted()
        )
        XCTAssertEqual(contract.exactCurrentWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(contract.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(contract.exactWorkerResourceCount, 1)

        let imports = source.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            contract.exactInvocationSourceImportNames.map { "import \($0)" }
        )

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
                of: contract.mutation.rawSeamMethodName + "(",
                in: source
            ),
            2
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    ".\(contract.mutation.rawSeamMethodName)(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.preservedBoundaryMethodName,
                in: source
            ),
            1
        )

        let main = try checkedInString(contract.workerMain.primeRelativePath)
        XCTAssertFalse(main.contains(contract.mutation.rawSeamMethodName))
        XCTAssertFalse(main.contains(contract.preservedBoundaryMethodName))
        XCTAssertTrue(
            main.filter { !$0.isWhitespace }.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )

        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )
    }

    func testPrivateAccessCanaryAndSecurityCeiling() {
        XCTAssertEqual(
            V26PrivateAccessCanary.boundary(shouldThrow: false),
            .completedAndDiscarded
        )
        XCTAssertEqual(
            V26PrivateAccessCanary.boundary(shouldThrow: true),
            .failedClosed
        )

        let contract = Contract.frozenV1
        let access = contract.accessMatrix
        XCTAssertTrue(
            contract.projectedExactWorkerFrontendTypecheckObserved
        )
        XCTAssertTrue(
            contract.reducedSameFilePrivateExtensionCanaryObserved
        )
        XCTAssertTrue(
            contract.negativeCrossFilePrivateAccessCompilerCanaryObserved
        )
        XCTAssertTrue(access.projectedRawSeamPrivate)
        XCTAssertTrue(
            access
                .sameFileExtensionOfRawSeamDeclaringNestedTypeCanNameRawSeam
        )
        XCTAssertFalse(access.otherWorkerSourceFileCanNameRawSeam)
        XCTAssertFalse(access.mainCanNameRawSeam)
        XCTAssertFalse(access.testableImportCanNameRawSeam)
        XCTAssertTrue(access.v25NonpayloadBoundaryRemainsInternal)
        XCTAssertTrue(access.sameModuleSourceCanNameV25Boundary)
        XCTAssertTrue(access.mainCanNameV25Boundary)
        XCTAssertTrue(access.testableImportCanNameV25Boundary)
        XCTAssertTrue(
            access.v25BoundaryRemainsSoleCheckedInRawSeamCaller
        )
        XCTAssertTrue(
            access
                .futureSameFileExtensionOfRawSeamDeclaringNestedTypeCanAddRawSeamCaller
        )
        XCTAssertFalse(
            access.dynamicDebuggerInjectedOrUnsafeBypassPrevented
        )
        XCTAssertFalse(
            access.binarySymbolOrTypeMetadataAbsenceEstablished
        )
        XCTAssertTrue(
            access
                .genericReflectionMayExposePrivatePayloadAfterWrapperPossession
        )
        XCTAssertTrue(
            access
                .returnedVersusThrewDispositionWouldBeObservableToAnyBoundaryCaller
        )
        XCTAssertFalse(access.rawErrorDetailSuppressionUniversal)
        XCTAssertFalse(
            access
                .underscoredPrivateImportDebuggerOrCompilerPrivilegePrevented
        )
        XCTAssertFalse(access.timingResourceOrCrashObservationContained)
        XCTAssertFalse(access.authenticatedCallerPolicyEstablished)
        XCTAssertFalse(access.confidentialityEstablished)
        XCTAssertFalse(access.zeroizationEstablished)
        XCTAssertFalse(access.constantTimeEstablished)
        XCTAssertFalse(access.constantResourceUseEstablished)
        XCTAssertFalse(access.trapsSignalsOrOutOfMemoryContained)
        XCTAssertTrue(
            access.hardenedIsolationRequiredBeforeUntrustedRuntime
        )
    }

    func testTwoPhysicalFilePrivateAccessCompilerCanaryFailsClosed()
        throws
    {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-v26-private-access-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let declaration = root.appendingPathComponent("Raw.swift")
        let caller = root.appendingPathComponent("Caller.swift")
        try """
        struct PrimeV26PrivateAccessCompilerCanary {
            private static func rawSeam() -> Int {
                26
            }
        }
        """.write(
            to: declaration,
            atomically: true,
            encoding: .utf8
        )
        try """
        extension PrimeV26PrivateAccessCompilerCanary {
            static func crossFileBoundary() -> Int {
                Self.rawSeam()
            }
        }
        """.write(
            to: caller,
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-module-cache-path",
            root.appendingPathComponent("ModuleCache").path,
            "-typecheck",
            "-parse-as-library",
            declaration.path,
            caller.path,
        ]
        let outputURL = root.appendingPathComponent("compiler.log")
        _ = FileManager.default.createFile(
            atPath: outputURL.path,
            contents: Data()
        )
        let outputHandle = try FileHandle(forWritingTo: outputURL)
        defer { try? outputHandle.close() }
        process.standardOutput = outputHandle
        process.standardError = outputHandle
        let completed = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in completed.signal() }
        try process.run()
        var timedOut =
            completed.wait(timeout: .now() + 30) == .timedOut
        if timedOut {
            process.terminate()
            if completed.wait(timeout: .now() + 3) == .timedOut {
                kill(process.processIdentifier, SIGKILL)
                _ = completed.wait(timeout: .now() + 3)
            }
        }
        try outputHandle.synchronize()
        let errorText = try String(
            contentsOf: outputURL,
            encoding: .utf8
        )
        if process.isRunning {
            timedOut = true
        }

        XCTAssertFalse(timedOut, errorText)
        guard !process.isRunning else {
            XCTFail(
                "compiler canary remained alive after terminate and SIGKILL",
                file: #filePath,
                line: #line
            )
            return
        }
        XCTAssertEqual(process.terminationReason, .exit)
        XCTAssertNotEqual(process.terminationStatus, 0)
        XCTAssertTrue(
            errorText.contains(
                "'rawSeam' is inaccessible due to 'private' protection level"
            ),
            errorText
        )
    }

    func testAuthorityRuntimeAndHistoricalCeilingsRemainFailClosed() {
        let contract = Contract.frozenV1

        XCTAssertFalse(contract.runtimeReachableFromMain)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertFalse(contract.runtimeInputAccepted)
        XCTAssertFalse(contract.runtimeOutputProduced)
        XCTAssertFalse(contract.requestHandlingEnabled)
        XCTAssertFalse(contract.replayTransportIntegrated)
        XCTAssertFalse(contract.workerSealed)
        XCTAssertFalse(contract.workerLaunched)
        XCTAssertFalse(contract.workerExecuted)
        XCTAssertFalse(contract.compositionRuntimeExercised)
        XCTAssertFalse(
            contract.fixtureExporterProjectorOrDecoderExecuted
        )
        XCTAssertFalse(
            contract.gateModelTrainingMutationTriadSZOrEvaluationExecuted
        )
        XCTAssertFalse(contract.artifactWritePerformed)
        XCTAssertFalse(contract.evidencePublished)
        XCTAssertFalse(contract.durablePublicationObserved)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
        XCTAssertTrue(
            contract
                .v27MustPreserveV23ThroughV26CanonicalContractsAndTopologiesAsHistory
        )
        XCTAssertTrue(
            contract
                .v27MustEvolveV23ThroughV26HistoricalTestsWithoutRewritingHistory
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "source_bind_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_every_other_v25_worker_source_byte_the_v25_internal_nonpayload_boundary_as_the_sole_checked_in_raw_seam_caller_and_the_four_file_worker_inventory_without_any_main_cross_file_caller_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7"
        )
    }

    func testFrozenV26CanonicalRoundTripAndHash() throws {
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
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: try JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                path.joined(separator: ".")
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
            contract.callerAndResultConsumerSourceContractSource,
            contract.topologyV25Test,
            contract.packageSwift,
            contract.workerMain,
            contract.workerEvidenceExportCallEdgeSource,
            contract.workerProjectionCallEdgeSource,
            contract.workerFixtureResource,
        ]
    }

    private func reconstructedV25Source(
        fromV27Source source: Data,
        geometry:
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingMutationGeometry
    ) throws -> Data {
        XCTAssertEqual(UInt64(source.count), geometry.projectedSourceByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            geometry.projectedSourceSHA256
        )
        let lower = Int(geometry.accessTokenUTF8Offset)
        let projectedToken = Data(geometry.projectedAccessToken.utf8)
        XCTAssertEqual(
            source.subdata(in: lower ..< lower + projectedToken.count),
            projectedToken
        )
        var reconstructed = source
        reconstructed.replaceSubrange(
            lower ..< lower + projectedToken.count,
            with: Data(geometry.currentAccessToken.utf8)
        )
        XCTAssertEqual(UInt64(reconstructed.count), geometry.currentSourceByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: reconstructed),
            geometry.currentSourceSHA256
        )
        return reconstructed
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
                throw InventoryError.symbolicLink(relative)
            }
            if values.isRegularFile == true {
                paths.append(relative)
            } else if values.isDirectory != true {
                throw InventoryError.unsupportedNode(relative)
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

    private func allObjectKeys(
        in object: [String: Any]
    ) -> Set<String> {
        var result = Set(object.keys)
        for value in object.values {
            if let nested = value as? [String: Any] {
                result.formUnion(allObjectKeys(in: nested))
            }
        }
        return result
    }

    private func isLowerSnakeCase(_ key: String) -> Bool {
        guard let first = key.utf8.first,
              first >= 97,
              first <= 122,
              !key.contains("__"),
              key.utf8.last != 95
        else {
            return false
        }
        return key.utf8.allSatisfy {
            ($0 >= 97 && $0 <= 122)
                || ($0 >= 48 && $0 <= 57)
                || $0 == 95
        }
    }

    private func requiredFieldPaths(
        in object: [String: Any]
    ) -> [[String]] {
        var paths = object.keys.sorted().map { [$0] }
        for key in object.keys.sorted() {
            guard let nested = object[key] as? [String: Any] else {
                continue
            }
            paths.append(
                contentsOf: nestedLeafPaths(in: nested).map {
                    [key] + $0
                }
            )
        }
        return paths
    }

    private func nestedLeafPaths(
        in object: [String: Any]
    ) -> [[String]] {
        var paths: [[String]] = []
        for key in object.keys.sorted() {
            if let nested = object[key] as? [String: Any] {
                paths.append(
                    contentsOf: nestedLeafPaths(in: nested).map {
                        [key] + $0
                    }
                )
            } else {
                paths.append([key])
            }
        }
        return paths
    }

    private func replacingValue(
        in object: [String: Any],
        at path: [String],
        with transform: (Any) -> Any
    ) -> [String: Any] {
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result[key] = transform(result[key] as Any)
            return result
        }
        result[key] = replacingValue(
            in: result[key] as! [String: Any],
            at: Array(path.dropFirst()),
            with: transform
        )
        return result
    }

    private func removingValue(
        in object: [String: Any],
        at path: [String]
    ) -> [String: Any] {
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result.removeValue(forKey: key)
            return result
        }
        result[key] = removingValue(
            in: result[key] as! [String: Any],
            at: Array(path.dropFirst())
        )
        return result
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "__mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return number.int64Value + 1
        }
        if var array = value as? [Any] {
            if array.isEmpty {
                return ["__mutation"]
            }
            array[0] = mutateJSONValue(array[0])
            return array
        }
        if let object = value as? [String: Any],
           let key = object.keys.sorted().first
        {
            return replacingValue(
                in: object,
                at: [key],
                with: mutateJSONValue
            )
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    private enum InventoryError: Error {
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

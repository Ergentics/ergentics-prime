// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract

    private static let designContractSHA256 =
        "3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757"

    func testFrozenV22DesignBindsExactV21SourceTopologyAndFiles()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.preservedCompositionSourceV21ContractSHA256,
            "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494"
        )
        XCTAssertEqual(
            contract.preservedTopologyV21SHA256,
            "6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4"
        )

        let liveFutureSource = try checkedInData(
            contract.futureSourceRelativePath
        )
        XCTAssertGreaterThanOrEqual(
            UInt64(liveFutureSource.count),
            contract.preservedV21SourcePrefixByteCount
        )
        let preservedV21Source = Data(
            liveFutureSource.prefix(
                Int(contract.preservedV21SourcePrefixByteCount)
            )
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: preservedV21Source),
            contract.preservedV21SourcePrefixSHA256
        )

        let identities: [(String, UInt64, String)] = [
            (
                contract.packageSwiftRelativePath,
                contract.packageSwiftByteCount,
                contract.packageSwiftSHA256
            ),
            (
                contract.workerMainRelativePath,
                contract.workerMainByteCount,
                contract.workerMainSHA256
            ),
        ]
        for (path, byteCount, sha256) in identities {
            let data = try PrimeHistoricalSourceEvolutionTestSupport.historicalData(
                path: path, current: checkedInData(path),
                expectedByteCount: byteCount, expectedSHA256: sha256)
            XCTAssertEqual(UInt64(data.count), byteCount, path)
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                sha256,
                path
            )
        }

        XCTAssertEqual(
            contract.preservedV21SourcePrefixByteCount,
            11_354
        )
        XCTAssertEqual(contract.packageSwiftByteCount, 27_650)
        XCTAssertEqual(contract.workerMainByteCount, 2_298)
    }

    func testWorkerTopologyAndUnavailableMainRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV21
        let target = try topology.target(
            named: contract.workerTargetName
        )

        XCTAssertEqual(contract.exactWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(
            contract.orderedWorkerSwiftSourceRelativePaths.count,
            contract.exactWorkerSwiftSourceFileCount
        )
        XCTAssertEqual(contract.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(
            target.directLocalDependencyNames,
            contract.workerDirectLocalDependencyNames
        )
        XCTAssertEqual(contract.exactWorkerResourceCount, 1)
        XCTAssertFalse(contract.packageGraphMayChange)
        XCTAssertFalse(contract.targetGraphMayChange)
        XCTAssertFalse(contract.forbiddenReachabilityMayChange)
        XCTAssertFalse(contract.workerSourceInventoryMayChange)
        XCTAssertFalse(contract.workerDependenciesMayChange)
        XCTAssertFalse(contract.workerResourcesMayChange)

        let main = try checkedInString(
            contract.workerMainRelativePath
        ).filter { !$0.isWhitespace }
        XCTAssertTrue(
            main.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertFalse(contract.mainCanNameOrReachFutureSeam)
    }

    func testPhysicalWorkerSourceAndResourceInventoryRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(contract.workerTargetName)

        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            (
                contract.orderedWorkerSwiftSourceRelativePaths
                    + contract.workerResourceRelativePaths
            ).sorted()
        )
    }

    func testReservedWrapperHasOnePrivatePayloadAndNoDeclaredAccessorOrConformance()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.futureWrapperEnclosingTypeName,
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        )
        XCTAssertEqual(
            contract.futureWrapperTypeName,
            "PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        )
        XCTAssertEqual(
            contract.futureWrapperQualifiedSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        )
        XCTAssertEqual(contract.futureWrapperDeclarationKind, "struct")
        XCTAssertEqual(contract.futureWrapperAccessLevel, "internal")
        XCTAssertTrue(contract.futureWrapperNestedInWorker)
        XCTAssertFalse(
            contract.futureWrapperPublicPackageSPIOrExported
        )
        XCTAssertEqual(
            contract.futureWrapperExactStoredFieldNames,
            ["compositionResult"]
        )
        XCTAssertEqual(
            contract.futureWrapperExactStoredFieldSwiftTypeNames,
            [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
            ]
        )
        XCTAssertEqual(
            contract.futureWrapperExactStoredFieldAccessLevels,
            ["private"]
        )
        XCTAssertEqual(contract.futureWrapperExactStoredFieldCount, 1)
        XCTAssertEqual(
            contract.futureWrapperExposedFieldOrAccessorCount,
            0
        )
        XCTAssertEqual(
            contract.futureWrapperInitializerAccessLevel,
            "private"
        )
        XCTAssertEqual(
            contract.futureWrapperInitializerExactInputLabels,
            ["compositionResult"]
        )
        XCTAssertEqual(
            contract.futureWrapperInitializerExactInputCount,
            1
        )
        XCTAssertTrue(
            contract.futureWrapperDeclaredConformanceNames.isEmpty
        )

        for forbidden in [
            contract.futureWrapperAdditionalStoredFieldPermitted,
            contract.futureWrapperComputedPropertyPermitted,
            contract.futureWrapperPayloadAccessorPermitted,
            contract.futureWrapperSubscriptPermitted,
            contract.futureWrapperCallbackOrClosureExposurePermitted,
            contract
                .futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted,
        ] {
            XCTAssertFalse(forbidden)
        }
        XCTAssertTrue(
            contract.genericSwiftReflectionMayExposePrivatePayload
        )
        XCTAssertFalse(
            contract.futureWrapperProvidesConfidentialityBoundary
        )
        XCTAssertFalse(
            contract.wrapperPossessionMayEstablishSecurityBoundary
        )
    }

    func testReservedMethodLivesOnWrapperAndDelegatesOnce()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.futureInvocationMethodEnclosingTypeName,
            contract.futureWrapperQualifiedSwiftTypeName
        )
        XCTAssertEqual(
            contract.futureInvocationMethodName,
            "sourceBoundUnavailableHistoricalWorkerInvocationSeam"
        )
        XCTAssertEqual(
            contract.futureInvocationMethodNormalizedSignature,
            "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> Self"
        )
        XCTAssertEqual(
            contract.futureInvocationMethodReturnSwiftTypeName,
            contract.futureWrapperQualifiedSwiftTypeName
        )
        XCTAssertEqual(
            contract.futureInvocationMethodAccessLevel,
            "internal"
        )
        XCTAssertTrue(contract.futureInvocationMethodStatic)
        XCTAssertTrue(contract.futureInvocationMethodThrows)
        XCTAssertEqual(
            contract.exactInvocationInputLabels,
            ["evidence", "context"]
        )
        XCTAssertEqual(contract.exactInvocationInputCount, 2)
        XCTAssertFalse(contract.invocationInputMayBeOptional)
        XCTAssertFalse(contract.invocationInputMayHaveDefault)
        XCTAssertFalse(contract.additionalInvocationInputPermitted)
        XCTAssertTrue(contract.evidenceMustBeAlreadyFormed)
        XCTAssertTrue(contract.contextMustBeExplicit)
        XCTAssertTrue(contract.evidencePassedToV21CallUnchanged)
        XCTAssertTrue(contract.contextPassedToV21CallUnchanged)
        XCTAssertEqual(
            contract.maintainedV21CallEdgeMethodName,
            "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge"
        )
        XCTAssertEqual(
            contract.maintainedV21CallEdgeAccessLevel,
            "private"
        )
        XCTAssertEqual(contract.exactMaintainedV21CallCount, 1)
        XCTAssertTrue(
            contract.maintainedV21ReturnBecomesSolePrivatePayload
        )

        for forbidden in [
            contract.preservedV21PrivateAccessMayChange,
            contract.evidenceOrContextInspectionPermitted,
            contract.evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted,
            contract.directComposeCallPermitted,
            contract.directProjectorCallPermitted,
            contract.directDecoderCallPermitted,
            contract.directExporterOrFixtureCallPermitted,
            contract.seamGuardOrRevalidationPermitted,
            contract.newErrorTypeOrCasePermitted,
            contract.catchRetryFallbackOrSubstitutionPermitted,
            contract.optionalOrForcedTryPermitted,
            contract.loggingOrPartialResultPermitted,
        ] {
            XCTAssertFalse(forbidden)
        }
        XCTAssertTrue(contract.exactTypedFailurePropagationRequired)
    }

    func testTriStateContextRemainsOwnedByV21WithoutConflation()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.requiredSourceBytesResolvedState,
            "unavailable"
        )
        XCTAssertEqual(
            contract.requiredAdaptationProofRecomputedState,
            "unavailable"
        )
        XCTAssertTrue(
            contract.v21EnforcesBothContextStatesBeforeProjection
        )
        XCTAssertFalse(contract.seamDuplicatesOrInventsContextGuard)
        XCTAssertFalse(
            contract.unavailableObservedFalseOrNilConflationPermitted
        )
    }

    func testFrozenV22DesignWasUnmaterializedInThePreservedV21Prefix()
        throws
    {
        let contract = Contract.frozenV1
        let liveSource = try checkedInData(
            contract.futureSourceRelativePath
        )
        let preservedV21Source = try XCTUnwrap(
            String(
                data: liveSource.prefix(
                    Int(contract.preservedV21SourcePrefixByteCount)
                ),
                encoding: .utf8
            )
        )

        XCTAssertFalse(
            preservedV21Source.contains(contract.futureWrapperTypeName)
        )
        XCTAssertFalse(
            preservedV21Source.contains(contract.futureInvocationMethodName)
        )
        XCTAssertFalse(contract.futureWrapperSourceMaterialized)
        XCTAssertFalse(contract.futureInvocationMethodSourceMaterialized)
        XCTAssertFalse(
            contract.exactWorkerSourceCompilerFeasibilityObserved
        )

        for nonclaim in [
            contract.crossFileCallerMaterialized,
            contract.runtimeInputAccepted,
            contract.runtimeOutputProduced,
            contract.workerRequestHandlingEnabled,
            contract.replayTransportIntegrated,
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.compositionRuntimeExercised,
            contract.fixtureExporterProjectorOrDecoderExecuted,
            contract.gateModelTrainingMutationTriadSZOrEvaluationExecuted,
            contract.artifactFilesystemReadPerformed,
            contract.artifactWritePerformed,
            contract.evidencePublished,
            contract.durablePublicationObserved,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(nonclaim)
        }
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
    }

    func testSwiftLexicalAccessCanaryPreservesAPIHidingButNotConfidentiality()
        throws
    {
        let result = try AccessControlCanaryWorker.Result.invoke(
            value: 7
        )
        let child = try XCTUnwrap(
            Mirror(reflecting: result).children.first
        )
        XCTAssertEqual(child.label, "compositionResult")
        XCTAssertEqual(child.value as? Int, 7)
    }

    func testCanonicalRoundTripAndFrozenHash() throws {
        let contract = Contract.frozenV1
        let canonical = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: canonical
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        let observed = try contract.contentSHA256()
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.designContractSHA256)
    }

    func testAllCanonicalKeysAreExplicitSnakeCase()
        throws
    {
        let object = try canonicalObject()
        XCTAssertGreaterThan(object.count, 100)
        for key in object.keys {
            XCTAssertEqual(key, key.lowercased(), key)
            XCTAssertNil(
                key.range(of: "[A-Z]", options: .regularExpression),
                key
            )
            XCTAssertFalse(key.contains("-"), key)
            XCTAssertFalse(key.hasPrefix("_"), key)
            XCTAssertFalse(key.hasSuffix("_"), key)
        }

        let source = try checkedInString(
            "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract.swift"
        )
        XCTAssertTrue(source.contains("private enum CodingKeys"))
        for key in object.keys {
            XCTAssertTrue(source.contains("\"\(key)\""), key)
        }
    }

    func testEveryFrozenFieldMutationFailsClosed() throws {
        let object = try canonicalObject()

        for key in object.keys.sorted() {
            var mutation = object
            mutation[key] = typePreservingMutation(of: object[key]!)
            let data = try JSONSerialization.data(
                withJSONObject: mutation,
                options: [.sortedKeys]
            )
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: data
            )
            XCTAssertThrowsError(try decoded.validate(), key)
        }
    }

    func testEveryMissingOrNullFieldFailsDecode() throws {
        let object = try canonicalObject()

        for key in object.keys.sorted() {
            var missing = object
            missing.removeValue(forKey: key)
            let missingData = try JSONSerialization.data(
                withJSONObject: missing,
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    Contract.self,
                    from: missingData
                ),
                "missing \(key)"
            )

            var null = object
            null[key] = NSNull()
            let nullData = try JSONSerialization.data(
                withJSONObject: null,
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    Contract.self,
                    from: nullData
                ),
                "null \(key)"
            )
        }
    }

    func testUnknownCanonicalKeysFailClosed() throws {
        let object = try canonicalObject()
        for key in [
            "unknown_future_authority",
            "source_binding_v8_issued",
            "wrapper_payload_public",
        ] {
            var mutation = object
            mutation[key] = true
            let data = try JSONSerialization.data(
                withJSONObject: mutation,
                options: [.sortedKeys]
            )
            let plain = try JSONDecoder().decode(
                Contract.self,
                from: data
            )
            XCTAssertNoThrow(
                try plain.validate(),
                "plain JSONDecoder ignores unknown keys"
            )
            XCTAssertThrowsError(
                try PrimeCanonicalJSON.decode(
                    Contract.self,
                    from: data
                ),
                key
            )
        }
    }

    private func canonicalObject() throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(Contract.frozenV1)
            ) as? [String: Any]
        )
    }

    private func typePreservingMutation(of value: Any) -> Any {
        if let string = value as? String {
            return string + "_mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return number.int64Value + 1
        }
        if let array = value as? [Any] {
            guard !array.isEmpty else {
                return ["forbidden_mutation"]
            }
            return Array(array.dropLast())
        }
        XCTFail("unexpected canonical field type: \(type(of: value))")
        return NSNull()
    }

    private func checkedInData(_ relativePath: String) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath)
        )
    }

    private func checkedInString(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath),
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
                includingPropertiesForKeys: Array(keys),
                options: []
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: keys)
            let path = fileURL.standardizedFileURL.path
            XCTAssertTrue(path.hasPrefix(rootPath), path)
            guard path.hasPrefix(rootPath) else { continue }
            let relativePath = String(path.dropFirst(rootPath.count))
            if values.isSymbolicLink == true {
                throw InventoryError.symbolicLink(relativePath)
            }
            if values.isRegularFile == true {
                paths.append(relativePath)
                continue
            }
            if values.isDirectory == true {
                continue
            }
            throw InventoryError.unsupportedNode(relativePath)
        }
        return paths.sorted()
    }

    private enum InventoryError: Error, Equatable {
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private enum AccessControlCanaryWorker {
        private static func preservedPrivateCall(
            value: Int
        ) throws -> Int {
            value
        }

        struct Result {
            private let compositionResult: Int

            private init(compositionResult: Int) {
                self.compositionResult = compositionResult
            }

            static func invoke(value: Int) throws -> Self {
                Self(
                    compositionResult: try
                        AccessControlCanaryWorker
                        .preservedPrivateCall(value: value)
                )
            }
        }
    }
}

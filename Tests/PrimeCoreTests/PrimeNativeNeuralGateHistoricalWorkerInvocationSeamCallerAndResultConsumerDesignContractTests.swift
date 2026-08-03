// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContract

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContract.swift"
    private static let contractFileByteCount: UInt64 = 55_753
    private static let contractFileSHA256 =
        "08bf11deb2ceddabe6ffe321737e4f027f2ac526290fd3e37260106d2af38d9c"
    private static let contractContentSHA256 =
        "3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902"

    func testFrozenV24BindsExactV23AuthoritiesAndPhysicalSources()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_security_design_v24"
        )
        XCTAssertEqual(
            contract.preservedInvocationSeamSourceV23ContractSHA256,
            "6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656"
        )
        XCTAssertEqual(
            contract.preservedTopologyV23SHA256,
            "48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9"
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV24.byteCount,
            236_939
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV24.sha256,
            "b4983425a2d5a65bb620531eae57d329094d19b53a96750ee1505c13098372dc"
        )

        for identity in exactIdentities(contract) {
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

    func testCurrentWorkerInventoryAndV23PrefixRemainExact() throws {
        let contract = Contract.frozenV1
        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(contract.workerTargetName)

        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            (
                contract.orderedCurrentWorkerSwiftSourceRelativePaths
                    + contract.workerResourceRelativePaths
            ).sorted()
        )
        XCTAssertEqual(contract.exactCurrentWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(contract.futureWorkerSwiftSourceFileCount, 4)
        XCTAssertTrue(contract.currentPhysicalWorkerInventoryExact)
        XCTAssertEqual(
            contract.futureSourceRelativePath,
            contract.workerInvocationSeamSourceV23.primeRelativePath
        )
        XCTAssertTrue(contract.futureSourceMustBeAppendOnlySameFileContinuation)
        XCTAssertFalse(contract.futureSourceMayRewritePreservedPrefix)
        XCTAssertFalse(contract.futureSourceMayUseSeparateFile)
        XCTAssertFalse(contract.futureSourceMayAddWorkerSwiftFile)
        XCTAssertFalse(contract.futureSourceMayChangeImportInventory)

        for path in contract.orderedCurrentWorkerSwiftSourceRelativePaths {
            let source = try checkedInString(path)
            XCTAssertFalse(
                source.contains(contract.futureDispositionTypeName),
                path
            )
            XCTAssertFalse(
                source.contains(contract.futureBoundaryMethodName),
                path
            )
        }
        let seamSource = try checkedInString(
            contract.workerInvocationSeamSourceV23.primeRelativePath
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.maintainedV23SeamMethodName + "(",
                in: seamSource
            ),
            1
        )

        let package = try checkedInString("Package.swift")
        XCTAssertEqual(
            occurrenceCount(of: contract.workerTargetName, in: package),
            1
        )
        let testsDirectory = repositoryRoot.appendingPathComponent("Tests")
        for path in try recursiveSwiftSourcePathsIgnoringHiddenBuilds(
            in: testsDirectory
        ) {
            let lines = try checkedInString(path).split(separator: "\n")
            XCTAssertFalse(
                lines.contains {
                    $0.trimmingCharacters(in: .whitespaces)
                        == "@testable import \(contract.workerTargetName)"
                },
                path
            )
        }
    }

    func testSecurityFinalFutureDeclarationAndBodyAreFrozen() {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.futureExtensionTargetTypeName,
            "PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        )
        XCTAssertEqual(contract.exactFutureAppendedExtensionCount, 1)
        XCTAssertEqual(contract.futureDispositionDeclarationKind, "enum")
        XCTAssertEqual(contract.futureDispositionAccessLevel, "internal")
        XCTAssertTrue(contract.futureDispositionNestedInWrapper)
        XCTAssertEqual(
            contract.futureDispositionExactCaseNames,
            [
                "compositionCompletedAndDiscarded",
                "failedClosedWithoutDetail",
            ]
        )
        XCTAssertEqual(contract.futureDispositionExactCaseCount, 2)
        XCTAssertEqual(contract.futureDispositionAssociatedValueCount, 0)
        XCTAssertFalse(contract.futureDispositionHasRawType)
        XCTAssertEqual(contract.futureDispositionRawSwiftTypeName, "none")
        XCTAssertTrue(contract.futureDispositionDeclaredConformanceNames.isEmpty)
        XCTAssertTrue(contract.futureDispositionAttributeNames.isEmpty)
        XCTAssertEqual(contract.futureDispositionStoredFieldCount, 0)
        XCTAssertEqual(contract.futureDispositionMethodCount, 0)
        XCTAssertEqual(contract.futureDispositionGenericParameterCount, 0)
        XCTAssertTrue(contract.futureDispositionImplicitSendable)
        XCTAssertTrue(contract.futureDispositionOrdinarilyCopyable)
        XCTAssertFalse(contract.futureDispositionProvidesConfidentialityBoundary)
        XCTAssertFalse(contract.futureDispositionProvidesAuthorityBoundary)

        XCTAssertEqual(
            contract.futureBoundaryMethodNormalizedSignature,
            "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) -> CallerResultConsumerDisposition"
        )
        XCTAssertEqual(
            contract.futureBoundaryMethodNormalizedBody,
            "do{_=trySelf.sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence:evidence,context:context)return.compositionCompletedAndDiscarded}catch{return.failedClosedWithoutDetail}"
        )
        XCTAssertEqual(contract.futureBoundaryMethodAccessLevel, "internal")
        XCTAssertTrue(contract.futureBoundaryMethodStatic)
        XCTAssertFalse(contract.futureBoundaryMethodAsync)
        XCTAssertFalse(contract.futureBoundaryMethodThrows)
        XCTAssertEqual(
            contract.futureBoundaryMethodReturnSwiftTypeName,
            "CallerResultConsumerDisposition"
        )
        XCTAssertEqual(
            contract.futureBoundaryExactInputLabels,
            ["evidence", "context"]
        )
        XCTAssertEqual(contract.futureBoundaryExactInputCount, 2)
        XCTAssertEqual(contract.exactDoCount, 1)
        XCTAssertEqual(contract.exactV23SeamCallCount, 1)
        XCTAssertEqual(contract.exactTryCount, 1)
        XCTAssertEqual(contract.exactBareCatchCount, 1)
        XCTAssertEqual(contract.exactSuccessReturnCount, 1)
        XCTAssertEqual(contract.exactFailureReturnCount, 1)
        XCTAssertTrue(contract.v23SeamUsesExplicitSelfQualification)
        XCTAssertTrue(contract.successReturnOccursOnlyAfterSeamReturns)
        XCTAssertTrue(
            contract.everyCaughtSwiftErrorMapsToFailedClosedWithoutDetail
        )
    }

    func testLeakageBypassRuntimeAndAuthorityRemainFailClosed() {
        let contract = Contract.frozenV1

        for forbidden in [
            contract.futureBoundaryInputMayBeOptional,
            contract.futureBoundaryInputMayHaveDefault,
            contract.futureBoundaryInputMayBeVariadicOrInout,
            contract.wrapperValueNamedOrBound,
            contract.wrapperOrCompositionReturned,
            contract.wrapperOrCompositionExplicitlyCopied,
            contract.wrapperOrCompositionRetainedOrCaptured,
            contract.payloadAccessed,
            contract.evidenceContextWrapperCompositionOrErrorReflected,
            contract.evidenceContextWrapperCompositionOrErrorEncodedOrSerialized,
            contract.evidenceContextWrapperCompositionOrErrorLoggedOrPublished,
            contract.errorBoundInspectedOrReturned,
            contract.timingOrResourceMeasured,
            contract.retryFallbackOrSubstitutionPermitted,
            contract.directV21ComposeProjectorDecoderOrExporterCallPermitted,
            contract.dispositionEstablishesFixtureOriginOrAuthority,
            contract.v23PrivatePayloadOrInitializerAccessWidened,
            contract.otherRawSeamCallerPermitted,
            contract.sameModuleBypassPrevented,
            contract.testableBypassPrevented,
            contract.dynamicOrUnsafeBypassPrevented,
            contract.confidentialityEstablished,
            contract.zeroizationEstablished,
            contract.constantTimeEstablished,
            contract.constantResourceUseEstablished,
            contract.trapsSignalsOrOutOfMemoryContained,
            contract.futureExtensionSourceMaterialized,
            contract.futureDispositionSourceMaterialized,
            contract.futureBoundaryMethodSourceMaterialized,
            contract.futureCallerMaterialized,
            contract.futureDiscardConsumerMaterialized,
            contract.exactFutureWorkerSourceCompilerFeasibilityObserved,
            contract.mainReferencesOrCallsFutureBoundary,
            contract.crossFileCallerMaterialized,
            contract.runtimeReachableFromMain,
            contract.runtimeInputAccepted,
            contract.runtimeOutputProduced,
            contract.requestHandlingEnabled,
            contract.replayTransportIntegrated,
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.compositionRuntimeExercised,
            contract.fixtureExporterProjectorOrDecoderExecuted,
            contract.gateModelTrainingMutationTriadSZOrEvaluationExecuted,
            contract.workerRuntimeArtifactFilesystemReadPerformed,
            contract.artifactWritePerformed,
            contract.evidencePublished,
            contract.durablePublicationObserved,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(contract.rawV23SeamRemainsInternal)
        XCTAssertTrue(
            contract
                .futureBoundaryMustBeSoleCheckedInRawSeamCallerIfMaterialized
        )
        XCTAssertTrue(contract.sameModuleSourcesCanNameRawSeam)
        XCTAssertTrue(contract.mainCanLexicallyNameRawSeam)
        XCTAssertTrue(
            contract.mainCouldLexicallyNameFutureBoundaryIfMaterialized
        )
        XCTAssertFalse(
            contract.ordinaryNonTestableOutsideModuleCanNameRawSeam
        )
        XCTAssertTrue(contract.testableOrPrivilegedImportMayNameInternalSeam)
        XCTAssertTrue(contract.genericReflectionMayExposePrivatePayload)
        XCTAssertTrue(
            contract.hardRuntimeRequiresRawSeamNarrowingRemovalOrHardenedIsolation
        )
        XCTAssertTrue(contract.designOnly)
        XCTAssertTrue(contract.reducedSwiftCanaryCompilerFeasibilityObserved)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertTrue(contract.sourceIntegrityTestFilesystemReadRequired)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "source_bind_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_discard_consumer_as_an_append_only_same_file_v23_continuation_with_exactly_one_unchanged_argument_v23_seam_call_exactly_two_nonpayload_dispositions_composition_completed_and_discarded_or_failed_closed_without_detail_and_total_swift_error_detail_suppression_without_returning_explicitly_copying_retaining_reflecting_encoding_serializing_logging_timing_measuring_or_publishing_evidence_context_wrapper_composition_or_error_values_and_without_adding_any_other_seam_caller_main_or_cross_file_call_edge_testable_worker_import_request_process_replay_transport_artifact_io_launch_execution_authority_or_source_binding_v7"
        )
    }

    func testReducedSwiftCanaryHasTwoNonpayloadCasesAndNonthrowingMapping()
    {
        let nonthrowing:
            (ReducedBoundaryFailure) ->
            ReducedCallerResultConsumerDisposition = Self.reducedBoundary

        XCTAssertEqual(
            nonthrowing(.none),
            .compositionCompletedAndDiscarded
        )
        XCTAssertEqual(
            nonthrowing(.first),
            .failedClosedWithoutDetail
        )
        XCTAssertEqual(
            nonthrowing(.second),
            .failedClosedWithoutDetail
        )
        requireSendable(ReducedCallerResultConsumerDisposition.self)
        requireCopyable(ReducedCallerResultConsumerDisposition.self)
    }

    func testCanonicalRoundTripExplicitCodingKeysAndFrozenHash()
        throws
    {
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
        XCTAssertEqual(observed, Self.contractContentSHA256)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let source = try checkedInString(Self.contractRelativePath)
        let contractKeysStart = try XCTUnwrap(
            source.range(
                of: "private enum CodingKeys: String, CodingKey",
                options: .backwards
            )
        ).lowerBound
        let frozenStart = try XCTUnwrap(
            source.range(
                of: "public static let frozenV1",
                range: contractKeysStart ..< source.endIndex
            )
        ).lowerBound
        let keysSource = String(source[contractKeysStart ..< frozenStart])

        XCTAssertEqual(
            occurrenceCount(
                of: "private enum CodingKeys: String, CodingKey",
                in: source
            ),
            2
        )
        for key in object.keys.sorted() {
            XCTAssertTrue(isLowerSnakeCase(key), key)
            XCTAssertTrue(keysSource.contains("\"\(key)\""), key)
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
            let missingData = try JSONSerialization.data(
                withJSONObject: removingValue(in: object, at: path),
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: missingData),
                "missing \(label)"
            )
            let nullData = try JSONSerialization.data(
                withJSONObject: replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: nullData),
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

    private enum ReducedBoundaryFailure: CaseIterable {
        case none
        case first
        case second
    }

    private enum ReducedCanaryError: Error {
        case first
        case second
    }

    private enum ReducedCallerResultConsumerDisposition {
        case compositionCompletedAndDiscarded
        case failedClosedWithoutDetail
    }

    private static func reducedSeam(
        _ failure: ReducedBoundaryFailure
    ) throws -> Int {
        switch failure {
        case .none:
            return 24
        case .first:
            throw ReducedCanaryError.first
        case .second:
            throw ReducedCanaryError.second
        }
    }

    private static func reducedBoundary(
        _ failure: ReducedBoundaryFailure
    ) -> ReducedCallerResultConsumerDisposition {
        do {
            _ = try Self.reducedSeam(failure)
            return .compositionCompletedAndDiscarded
        } catch {
            return .failedClosedWithoutDetail
        }
    }

    private func exactIdentities(
        _ contract: Contract
    ) -> [
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignSourceIdentity
    ] {
        [
            contract.invocationSeamSourceContractSource,
            contract.invocationSeamSourceContractTest,
            contract.topologyV23Test,
            contract.packageSwift,
            contract.workerMain,
            contract.workerInvocationSeamSourceV23,
            contract.workerEvidenceExportCallEdgeSource,
            contract.workerProjectionCallEdgeSource,
            contract.workerFixtureResource,
            contract.currentV21SourceTest,
            contract.currentV22DesignTest,
        ]
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

    private func recursiveSwiftSourcePathsIgnoringHiddenBuilds(
        in directory: URL
    ) throws -> [String] {
        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles]
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
            if values.isRegularFile == true,
               relative.hasSuffix(".swift")
            {
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

    private func requireSendable<T: Sendable>(_: T.Type) {}
    private func requireCopyable<T: Copyable>(_: T.Type) {}

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

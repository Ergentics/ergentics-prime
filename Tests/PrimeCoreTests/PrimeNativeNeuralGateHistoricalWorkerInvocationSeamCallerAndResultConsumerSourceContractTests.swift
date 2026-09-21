// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract.swift"
    private static let contractFileByteCount: UInt64 = 55_872
    private static let contractFileSHA256 =
        "85d21774ddf080d80a68066628b248ed801d53e5d68dae7ce2f54b4a446abddb"
    private static let contractContentSHA256 =
        "21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5"

    func testFrozenV25BindsPriorAuthoritiesAndExactAdoptedSource()
        throws
    {
        let contract = Contract.frozenV1
        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV24
        let sourceV23 =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract
            .frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_v25"
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
            contract
                .preservedCallerAndResultConsumerDesignV24ContractSHA256
        )
        XCTAssertEqual(
            contract
                .preservedCallerAndResultConsumerDesignV24ContractSHA256,
            "3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(topology)
            ),
            contract.preservedTopologyV24SHA256
        )
        XCTAssertEqual(
            contract.preservedTopologyV24SHA256,
            "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(sourceV23)
            ),
            contract.preservedInvocationSeamSourceV23ContractSHA256
        )
        XCTAssertEqual(
            contract.preservedInvocationSeamSourceV23ContractSHA256,
            "6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656"
        )

        let liveV27Source = try checkedInData(
            contract.callerAndResultConsumerSource.primeRelativePath
        )
        XCTAssertEqual(UInt64(liveV27Source.count), 14_174)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: liveV27Source),
            "767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15"
        )
        let liveSource = try reconstructedV25Source(
            fromV27Source: liveV27Source
        )
        XCTAssertEqual(UInt64(liveSource.count), 14_175)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: liveSource),
            "bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8"
        )
        XCTAssertEqual(
            UInt64(liveSource.count),
            contract.callerAndResultConsumerSource.byteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: liveSource),
            contract.callerAndResultConsumerSource.sha256
        )

        let prefix = Data(
            liveSource.prefix(
                Int(contract.preservedV23SourcePrefixByteCount)
            )
        )
        let suffix = Data(
            liveSource.dropFirst(
                Int(contract.preservedV23SourcePrefixByteCount)
            )
        )
        XCTAssertEqual(UInt64(prefix.count), 13_227)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefix),
            "62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54"
        )
        XCTAssertEqual(UInt64(suffix.count), 948)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            "ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626"
        )
        XCTAssertTrue(contract.exactV23PrefixPreserved)
        XCTAssertTrue(contract.sourceEvolutionAppendOnly)

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
            contract.historicalV23SourceContractTestBeforeV25.byteCount,
            32_205
        )
        XCTAssertEqual(
            contract.historicalV23SourceContractTestBeforeV25.sha256,
            "b4e9be3a7dfa8d04a32e3c072bb8dc57078884da2f8a4e4d8c74807f4e9c8de2"
        )
        XCTAssertEqual(
            contract.historicalV24DesignContractTestBeforeV25.byteCount,
            27_806
        )
        XCTAssertEqual(
            contract.historicalV24DesignContractTestBeforeV25.sha256,
            "f1dabbded24243df79c4c367fd88795ad53131146a33516a58660279d4fe3096"
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV25.byteCount,
            249_163
        )
        XCTAssertEqual(
            contract.historicalTopologySourceBeforeV25.sha256,
            "ee1464ca5e0579b41b2fd046f7fac1036f5b29efab99934412ee3dfc07b50280"
        )
        XCTAssertTrue(contract.historicalTestsEvolvedPrefixSafely)

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

    func testPhysicalInventoryPackageImportsMainAndCallerExclusivity()
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
        XCTAssertEqual(contract.exactWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(contract.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(contract.exactWorkerResourceCount, 1)
        XCTAssertTrue(contract.physicalWorkerInventoryExact)

        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )

        let main = try checkedInString(contract.workerMain.primeRelativePath)
        let compactMain = main.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compactMain.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertFalse(main.contains(contract.boundaryMethodName))
        XCTAssertFalse(main.contains(contract.dispositionTypeName))

        let source = try checkedInString(
            contract.callerAndResultConsumerSource.primeRelativePath
        )
        let imports = source.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            contract.exactImportNames.map { "import \($0)" }
        )

        for path in contract.orderedWorkerSwiftSourceRelativePaths
            where path
                != contract.callerAndResultConsumerSource.primeRelativePath
        {
            let otherSource = try checkedInString(path)
            XCTAssertFalse(
                otherSource.contains(contract.boundaryMethodName),
                path
            )
            XCTAssertFalse(
                otherSource.contains(contract.dispositionTypeName),
                path
            )
            XCTAssertFalse(
                otherSource.contains(
                    "Self.\(contract.maintainedV23SeamMethodName)("
                ),
                path
            )
            XCTAssertFalse(
                otherSource.contains(
                    contract.maintainedV23SeamMethodName + "("
                ),
                path
            )
        }

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

        for changed in [
            contract.packageGraphChanged,
            contract.targetGraphChanged,
            contract.forbiddenReachabilityChanged,
            contract.workerSourceInventoryChanged,
            contract.workerDependenciesChanged,
            contract.workerResourcesChanged,
            contract.importInventoryChanged,
        ] {
            XCTAssertFalse(changed)
        }
    }

    func testAppendOnlySuffixHasExactDeclarationBodyAndNoLeakageSurface()
        throws
    {
        let contract = Contract.frozenV1
        let liveV27Source = try checkedInData(
            contract.callerAndResultConsumerSource.primeRelativePath
        )
        let liveSource = try reconstructedV25Source(
            fromV27Source: liveV27Source
        )
        let suffixData = Data(
            liveSource.dropFirst(
                Int(contract.preservedV23SourcePrefixByteCount)
            )
        )
        let suffix = try XCTUnwrap(
            String(data: suffixData, encoding: .utf8)
        )
        let compact = suffix.filter { !$0.isWhitespace }
        let compactData = Data(compact.utf8)

        XCTAssertEqual(
            UInt64(compactData.count),
            contract.appendedV25WhitespaceStrippedByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: compactData),
            contract.appendedV25WhitespaceStrippedSHA256
        )
        XCTAssertEqual(
            compact,
            contract.appendedV25WhitespaceStrippedSource
        )
        XCTAssertEqual(
            compact,
            "extensionPrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult{internalenumCallerResultConsumerDisposition{casecompositionCompletedAndDiscardedcasefailedClosedWithoutDetail}internalstaticfuncsourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(evidence:PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,context:PrimeNativeNeuralGateHistoricalProjectionContext)->CallerResultConsumerDisposition{do{_=trySelf.sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence:evidence,context:context)return.compositionCompletedAndDiscarded}catch{return.failedClosedWithoutDetail}}}"
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "extensionPrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult{",
                in: compact
            ),
            contract.exactAppendedExtensionCount
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "internalenumCallerResultConsumerDisposition{",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.boundaryMethodName + "(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "Self.\(contract.maintainedV23SeamMethodName)(",
                in: compact
            ),
            contract.exactV23SeamCallCount
        )
        XCTAssertEqual(
            occurrenceCount(of: "do{", in: compact),
            contract.exactDoCount
        )
        XCTAssertEqual(
            occurrenceCount(of: "trySelf.", in: compact),
            contract.exactTryCount
        )
        XCTAssertEqual(
            occurrenceCount(of: "}catch{", in: compact),
            contract.exactBareCatchCount
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "return.compositionCompletedAndDiscarded",
                in: compact
            ),
            contract.exactSuccessReturnCount
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "return.failedClosedWithoutDetail",
                in: compact
            ),
            contract.exactFailureReturnCount
        )

        let fullSource = try XCTUnwrap(
            String(data: liveSource, encoding: .utf8)
        ).filter { !$0.isWhitespace }
        XCTAssertEqual(
            occurrenceCount(
                of: contract.maintainedV23SeamMethodName + "(",
                in: fullSource
            ),
            2
        )

        for forbidden in [
            "Mirror(",
            "String(describing:",
            "String(reflecting:",
            "print(",
            "debugPrint(",
            "dump(",
            "JSONSerialization",
            "JSONDecoder",
            "JSONEncoder",
            "FileManager",
            "FileHandle",
            "Process(",
            "CommandLine",
            "URLSession",
            "write(to:",
            "InputStream",
            "OutputStream",
            "Bundle.",
            "Logger(",
            "os_log",
            "Task{",
            "Task.detached",
            "withCheckedContinuation",
            "assert(",
            "precondition(",
            "fatalError(",
            "try?",
            "try!",
            "as!",
            "@_spi",
            "@inlinable",
            "@usableFromInline",
            "@_cdecl",
            "@objc",
        ] {
            XCTAssertFalse(
                compact.contains(forbidden.filter { !$0.isWhitespace }),
                forbidden
            )
        }
    }

    func testSourceTruthSecurityNonclaimsAndNextBoundaryRemainExact() {
        let contract = Contract.frozenV1

        for observed in [
            contract.extensionSourceMaterialized,
            contract.dispositionSourceMaterialized,
            contract.boundaryMethodSourceMaterialized,
            contract.rawSeamCallerMaterialized,
            contract.discardConsumerMaterialized,
            contract.exactWorkerSourceCompilerFeasibilityObserved,
            contract.reducedSwiftCanaryCompilerFeasibilityObserved,
            contract.rawV23SeamRemainsInternal,
            contract.boundaryIsSoleCheckedInRawSeamCaller,
            contract.sameModuleSourcesCanNameRawSeam,
            contract.mainCanLexicallyNameRawSeam,
            contract.mainCanLexicallyNameBoundary,
            contract.testableOrPrivilegedImportMayNameInternalBoundary,
            contract.genericReflectionMayExposePrivatePayload,
            contract.hardRuntimeRequiresHardenedIsolation,
            contract.mainRemainsUnconditionalUnavailableExit,
            contract.sourceIntegrityTestFilesystemReadRequired,
        ] {
            XCTAssertTrue(observed)
        }

        for absentOrUnauthorized in [
            contract.dispositionProvidesConfidentialityBoundary,
            contract.dispositionProvidesAuthorityBoundary,
            contract.boundaryInputMayBeOptional,
            contract.boundaryInputMayHaveDefault,
            contract.boundaryInputMayBeVariadicOrInout,
            contract.wrapperValueNamedOrBound,
            contract.wrapperOrCompositionReturned,
            contract.wrapperOrCompositionExplicitlyCopied,
            contract.wrapperOrCompositionRetainedOrCaptured,
            contract.payloadAccessed,
            contract.evidenceContextWrapperCompositionOrErrorReflected,
            contract
                .evidenceContextWrapperCompositionOrErrorEncodedOrSerialized,
            contract
                .evidenceContextWrapperCompositionOrErrorLoggedOrPublished,
            contract.errorBoundInspectedOrReturned,
            contract.timingOrResourceMeasured,
            contract.retryFallbackOrSubstitutionPermitted,
            contract.directV21ComposeProjectorDecoderOrExporterCallPermitted,
            contract.dispositionEstablishesFixtureOriginOrAuthority,
            contract.callerOfNonpayloadBoundaryMaterialized,
            contract.v23PrivatePayloadOrInitializerAccessWidened,
            contract.otherRawSeamCallerMaterialized,
            contract.ordinaryNonTestableOutsideModuleCanNameBoundary,
            contract.sameModuleRawSeamBypassPrevented,
            contract.testableRawSeamBypassPrevented,
            contract.dynamicOrUnsafeBypassPrevented,
            contract.confidentialityEstablished,
            contract.zeroizationEstablished,
            contract.constantTimeEstablished,
            contract.constantResourceUseEstablished,
            contract.trapsSignalsOrOutOfMemoryContained,
            contract.mainReferencesOrCallsBoundary,
            contract.crossFileBoundaryCallerMaterialized,
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
            XCTAssertFalse(absentOrUnauthorized)
        }

        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "design_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_the_v25_internal_nonpayload_boundary_as_the_sole_ordinary_source_level_callable_path_before_any_main_or_cross_file_call_edge_untrusted_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "Hardened module or process isolation remains required"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains("Prime remains ABSTAIN")
        )
    }

    func testReducedCanaryMapsSuccessAndEveryThrownErrorWithoutDetail() {
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

    func testCanonicalRoundTripExplicitKeysAndFrozenHash() throws {
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
            return 25
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

    private func liveExactIdentities(
        _ contract: Contract
    ) -> [
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    ] {
        [
            contract.callerAndResultConsumerDesignContractSource,
            contract.topologyV24Test,
            contract.invocationSeamSourceV23ContractSource,
            contract.packageSwift,
            contract.workerMain,
            contract.workerEvidenceExportCallEdgeSource,
            contract.workerProjectionCallEdgeSource,
            contract.workerFixtureResource,
        ]
    }

    private func reconstructedV25Source(
        fromV27Source source: Data
    ) throws -> Data {
        let offset = 12_555
        let privateToken = Data("private".utf8)
        XCTAssertEqual(
            source.subdata(in: offset ..< offset + privateToken.count),
            privateToken
        )
        var reconstructed = source
        reconstructed.replaceSubrange(
            offset ..< offset + privateToken.count,
            with: Data("internal".utf8)
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

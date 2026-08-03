// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract.swift"
    private static let contractFileByteCount: UInt64 = 59_396
    private static let contractFileSHA256 =
        "ca4d2caa4769110c0e6c69d026ea67b468c2cec670ce1f9c20232ba0aa32b8a0"
    private static let sourceContractSHA256 =
        "6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656"

    func testFrozenV23ContractBindsPreservedAuthoritiesAndExactSources()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_v23"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.preservedInvocationSeamDesignV22ContractSHA256,
            "3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757"
        )
        XCTAssertEqual(
            contract.preservedTopologyV22SHA256,
            "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5"
        )
        XCTAssertEqual(
            contract.preservedCompositionSourceV21ContractSHA256,
            "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494"
        )

        let liveV27Source = try checkedInData(
            contract.seamSource.primeRelativePath
        )
        let liveSource = try reconstructedV25Source(
            fromV27Source: liveV27Source
        )
        XCTAssertGreaterThanOrEqual(
            UInt64(liveSource.count),
            contract.seamSource.byteCount
        )
        let source = Data(
            liveSource.prefix(Int(contract.seamSource.byteCount))
        )
        XCTAssertEqual(UInt64(source.count), 13_227)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            "62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54"
        )
        XCTAssertEqual(
            UInt64(source.count),
            contract.seamSource.byteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            contract.seamSource.sha256
        )

        let prefix = Data(
            source.prefix(Int(contract.preservedV21SourcePrefixByteCount))
        )
        let suffix = Data(
            source.dropFirst(
                Int(contract.preservedV21SourcePrefixByteCount)
            )
        )
        XCTAssertEqual(UInt64(prefix.count), 11_354)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefix),
            "39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d"
        )
        XCTAssertEqual(UInt64(suffix.count), 1_873)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            "64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811"
        )
        XCTAssertTrue(contract.exactPrefixPreserved)
        XCTAssertTrue(contract.sourceEvolutionAppendOnly)

        for identity in [
            contract.packageSwift,
            contract.workerMain,
            contract.workerEvidenceExportCallEdgeSource,
            contract.workerProjectionCallEdgeSource,
            contract.workerFixtureResource,
            contract.currentV21SourceTest,
            contract.currentV22DesignTest,
        ] {
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

        XCTAssertEqual(
            contract.historicalV21SourceTestBeforeV23.byteCount,
            22_073
        )
        XCTAssertEqual(
            contract.historicalV21SourceTestBeforeV23.sha256,
            "47c576c0ef6157f5cb9fedf5285f13e6755032d563af701710fb9533233170c0"
        )
        XCTAssertEqual(contract.currentV21SourceTest.byteCount, 22_674)
        XCTAssertEqual(
            contract.currentV21SourceTest.sha256,
            "bfdfe2282192f45ddde57bbcbbec79fdce392ca2853d3b8b977578b45c88fc04"
        )
        XCTAssertEqual(
            contract.historicalV22DesignTestBeforeV23.byteCount,
            21_325
        )
        XCTAssertEqual(
            contract.historicalV22DesignTestBeforeV23.sha256,
            "5fcee9006d7f322f9ce3f7815dcc5ea370c053fd294e124d9e4a4e3c1e7f4c10"
        )
        XCTAssertEqual(contract.currentV22DesignTest.byteCount, 21_969)
        XCTAssertEqual(
            contract.currentV22DesignTest.sha256,
            "06ab036c190ab18a702dea80a6f75e9a0f41ce92bd0b2b061fa97dccf2ad92e6"
        )
        XCTAssertTrue(contract.historicalTestsEvolvedTransparently)

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

    func testPhysicalWorkerInventoryPackageGraphAndUnavailableMainRemainExact()
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
        XCTAssertFalse(main.contains(contract.wrapperTypeName))
        XCTAssertFalse(main.contains(contract.invocationMethodName))

        for path in contract.orderedWorkerSwiftSourceRelativePaths
            where path != contract.seamSource.primeRelativePath
        {
            let source = try checkedInString(path)
            XCTAssertFalse(source.contains(contract.wrapperTypeName), path)
            XCTAssertFalse(source.contains(contract.invocationMethodName), path)
        }

        for unchanged in [
            contract.packageGraphChanged,
            contract.targetGraphChanged,
            contract.forbiddenReachabilityChanged,
            contract.workerSourceInventoryChanged,
            contract.workerDependenciesChanged,
            contract.workerResourcesChanged,
            contract.importInventoryChanged,
        ] {
            XCTAssertFalse(unchanged)
        }
    }

    func testAppendOnlyInvocationSeamHasExactBoundedSourceShape()
        throws
    {
        let contract = Contract.frozenV1
        let liveV27SourceData = try checkedInData(
            contract.seamSource.primeRelativePath
        )
        let liveSourceData = try reconstructedV25Source(
            fromV27Source: liveV27SourceData
        )
        let sourceData = Data(
            liveSourceData.prefix(Int(contract.seamSource.byteCount))
        )
        let source = try XCTUnwrap(
            String(data: sourceData, encoding: .utf8)
        )
        let suffixData = Data(
            sourceData.dropFirst(
                Int(contract.preservedV21SourcePrefixByteCount)
            )
        )
        let suffix = try XCTUnwrap(
            String(data: suffixData, encoding: .utf8)
        )
        let extensionStart = try XCTUnwrap(
            suffix.range(
                of:
                    "extension PrimeNativeNeuralGateHistoricalFixtureWorker"
            )
        ).lowerBound
        let implementation = String(suffix[extensionStart...])
        let compact = implementation.filter { !$0.isWhitespace }
        let expected =
            """
            extension PrimeNativeNeuralGateHistoricalFixtureWorker {
                internal struct
                    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult
                {
                    private let compositionResult:
                        PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult

                    private init(
                        compositionResult:
                            PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult
                    ) {
                        self.compositionResult = compositionResult
                    }

                    internal static func
                        sourceBoundUnavailableHistoricalWorkerInvocationSeam(
                            evidence:
                                PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
                            context:
                                PrimeNativeNeuralGateHistoricalProjectionContext
                        ) throws -> Self
                    {
                        Self(
                            compositionResult: try
                                PrimeNativeNeuralGateHistoricalFixtureWorker
                                .sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(
                                    evidence: evidence,
                                    context: context
                                )
                        )
                    }
                }
            }
            """.filter { !$0.isWhitespace }

        XCTAssertEqual(compact, expected)
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "extensionPrimeNativeNeuralGateHistoricalFixtureWorker{",
                in: compact
            ),
            contract.exactAppendedExtensionCount
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "internalstructPrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult{",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(of: "privateletcompositionResult:", in: compact),
            contract.wrapperExactStoredFieldCount
        )
        XCTAssertEqual(
            occurrenceCount(of: "privateinit(", in: compact),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "funcsourceBoundUnavailableHistoricalWorkerInvocationSeam(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    ".sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(",
                in: compact
            ),
            contract.exactMaintainedV21CallCount
        )
        XCTAssertEqual(
            occurrenceCount(of: "Self(compositionResult:try", in: compact),
            contract.exactWrapperConstructionCount
        )

        let imports = source.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            contract.exactImportNames.map { "import \($0)" }
        )

        for forbidden in [
            "guard",
            "catch",
            "try?",
            "try!",
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
            "ReplayTransport",
            ".export(",
            ".project(",
            "sourceBoundHistoricalSemanticArtifactDecoderCallEdge(",
            "compose(",
            ".publish(",
            ".seal(",
            ".launch(",
            "ABSTAIN",
            "sourceBindingV7",
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

    func testSourceTruthDistinguishesAccessCopyabilityReflectionAndSecurity()
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(contract.wrapperAccessLevel, "internal")
        XCTAssertTrue(contract.sameModuleSourcesCanNameInvocationSeam)
        XCTAssertTrue(contract.mainCanLexicallyNameInvocationSeam)
        XCTAssertFalse(
            contract.ordinaryNonTestableOutsideModuleCanNameInvocationSeam
        )
        XCTAssertTrue(
            contract.testableOrPrivilegedImportMayNameInternalSeam
        )
        XCTAssertFalse(
            contract.compiledBinarySymbolOrTypeMetadataAbsenceAsserted
        )
        XCTAssertFalse(
            contract
                .dynamicLookupInjectionOrExternalInvocationResistanceEstablished
        )
        XCTAssertFalse(
            contract.privateV21MembersDirectlyNameableOutsideSourceFile
        )
        XCTAssertTrue(contract.internalSeamExpandsCallableAccessSurface)
        XCTAssertFalse(contract.v21PrivateDeclarationAccessWidened)

        XCTAssertTrue(contract.wrapperDeclaredConformanceNames.isEmpty)
        XCTAssertFalse(contract.wrapperDeclaredSendableConformance)
        XCTAssertTrue(contract.wrapperImplicitSendableConformance)
        XCTAssertFalse(contract.wrapperDeclaredCopyableConformance)
        XCTAssertTrue(contract.wrapperImplicitCopyableConformance)
        XCTAssertTrue(contract.genericSwiftReflectionMayExposePrivatePayload)
        XCTAssertFalse(contract.wrapperProvidesConfidentialityBoundary)
        XCTAssertFalse(contract.wrapperPossessionMayEstablishSecurityBoundary)

        let result = ImplicitConformanceCanaryResult(
            compositionResult: .init(value: 23)
        )
        requireSendable(ImplicitConformanceCanaryResult.self)
        requireCopyable(ImplicitConformanceCanaryResult.self)
        let children = Array(Mirror(reflecting: result).children)
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children.first?.label, "compositionResult")
        XCTAssertEqual(
            (children.first?.value as? ImplicitConformanceCanaryPayload)?.value,
            23
        )
    }

    func testDelegationTriStateErrorsRuntimeAndAuthorityRemainFailClosed()
    {
        let contract = Contract.frozenV1

        XCTAssertEqual(
            contract.invocationMethodNormalizedSignature,
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract
                .frozenV1.futureInvocationMethodNormalizedSignature
        )
        XCTAssertTrue(contract.invocationMethodStatic)
        XCTAssertFalse(contract.invocationMethodAsync)
        XCTAssertTrue(contract.invocationMethodThrows)
        XCTAssertFalse(contract.invocationMethodTypedThrowsDeclared)
        XCTAssertEqual(contract.invocationMethodReturnSwiftTypeName, "Self")
        XCTAssertEqual(
            contract.exactInvocationInputLabels,
            ["evidence", "context"]
        )
        XCTAssertEqual(contract.exactInvocationInputCount, 2)
        XCTAssertEqual(contract.exactSeamContextGuardCount, 0)
        XCTAssertEqual(contract.requiredSourceBytesResolvedState, "unavailable")
        XCTAssertEqual(
            contract.requiredAdaptationProofRecomputedState,
            "unavailable"
        )
        XCTAssertTrue(contract.v21EnforcesBothContextStatesBeforeProjection)
        XCTAssertFalse(
            contract.unavailableObservedFalseOrNilConflationPermitted
        )
        XCTAssertEqual(contract.exactMaintainedV21CallCount, 1)
        XCTAssertTrue(contract.v21CallUsesExplicitWorkerQualification)
        XCTAssertTrue(contract.maintainedV21ReturnBecomesSolePrivatePayload)
        XCTAssertTrue(contract.errorValuesPropagateUnchanged)

        for forbidden in [
            contract.invocationInputMayBeOptional,
            contract.invocationInputMayHaveDefault,
            contract.invocationInputMayBeVariadicOrInout,
            contract.seamDuplicatesOrInventsContextGuard,
            contract.evidenceOrContextInspectionPermitted,
            contract
                .evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted,
            contract.directComposeCallPermitted,
            contract.directProjectorCallPermitted,
            contract.directDecoderCallPermitted,
            contract.directExporterOrFixtureCallPermitted,
            contract.seamGuardOrRevalidationPermitted,
            contract.newErrorTypeOrCasePermitted,
            contract.catchRetryFallbackOrSubstitutionPermitted,
            contract.optionalOrForcedTryPermitted,
            contract.loggingOrPartialResultPermitted,
            contract.crossFileCallerMaterialized,
            contract.mainReferencesOrCallsInvocationSeam,
            contract.runtimeReachableFromMain,
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

        XCTAssertTrue(contract.wrapperSourceMaterialized)
        XCTAssertTrue(contract.invocationMethodSourceMaterialized)
        XCTAssertTrue(contract.exactWorkerSourceCompilerFeasibilityObserved)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertTrue(contract.sourceIntegrityTestFilesystemReadRequired)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "ordinary non-testable outside-module imports cannot name them"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains("Prime remains ABSTAIN")
        )
    }

    func testCanonicalRoundTripExplicitSnakeCaseAndFrozenHash()
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
        XCTAssertEqual(observed, Self.sourceContractSHA256)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let source = try checkedInString(Self.contractRelativePath)
        let contractCodingKeysStart = try XCTUnwrap(
            source.range(
                of: "private enum CodingKeys: String, CodingKey",
                options: .backwards
            )
        ).lowerBound
        let frozenStart = try XCTUnwrap(
            source.range(
                of: "public static let frozenV1",
                range: contractCodingKeysStart ..< source.endIndex
            )
        ).lowerBound
        let codingKeysSource =
            String(source[contractCodingKeysStart ..< frozenStart])

        XCTAssertEqual(
            occurrenceCount(
                of: "private enum CodingKeys: String, CodingKey",
                in: source
            ),
            2
        )
        for key in object.keys.sorted() {
            XCTAssertTrue(isLowerSnakeCase(key), key)
            XCTAssertTrue(codingKeysSource.contains("\"\(key)\""), key)
        }
        let identity = try XCTUnwrap(
            object["seam_source"] as? [String: Any]
        )
        XCTAssertEqual(
            Set(identity.keys),
            Set(["prime_relative_path", "byte_count", "sha256"])
        )
        XCTAssertTrue(source.contains("\"prime_relative_path\""))
        XCTAssertTrue(source.contains("\"byte_count\""))
        XCTAssertTrue(source.contains("case sha256"))
    }

    func testEveryCanonicalFieldMutationFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let paths = requiredFieldPaths(in: object)

        XCTAssertGreaterThan(paths.count, object.count)
        for path in paths {
            let mutation = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            let data = try JSONSerialization.data(
                withJSONObject: mutation,
                options: [.sortedKeys]
            )
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: data
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
            let missing = removingValue(in: object, at: path)
            let missingData = try JSONSerialization.data(
                withJSONObject: missing,
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: missingData),
                "missing \(label)"
            )

            let null = replacingValue(
                in: object,
                at: path,
                with: { _ in NSNull() }
            )
            let nullData = try JSONSerialization.data(
                withJSONObject: null,
                options: [.sortedKeys]
            )
            XCTAssertThrowsError(
                try JSONDecoder().decode(Contract.self, from: nullData),
                "null \(label)"
            )
        }
    }

    func testUnknownKeyIsIgnoredOnlyByPlainDecoder() throws {
        let canonical = try PrimeCanonicalJSON.encode(Contract.frozenV1)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["unknown_future_invocation_authority"] = true
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

    private func reconstructedV25Source(
        fromV27Source source: Data
    ) throws -> Data {
        XCTAssertEqual(UInt64(source.count), 14_174)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: source),
            "767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15"
        )
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
        XCTAssertEqual(UInt64(reconstructed.count), 14_175)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: reconstructed),
            "bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8"
        )
        return reconstructed
    }

    private func checkedInData(_ relativePath: String) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath)
        )
    }

    private func checkedInString(_ relativePath: String) throws -> String {
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

    private func occurrenceCount(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else { return 0 }
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
        precondition(!path.isEmpty)
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result[key] = transform(result[key] as Any)
            return result
        }
        let nested = result[key] as! [String: Any]
        result[key] = replacingValue(
            in: nested,
            at: Array(path.dropFirst()),
            with: transform
        )
        return result
    }

    private func removingValue(
        in object: [String: Any],
        at path: [String]
    ) -> [String: Any] {
        precondition(!path.isEmpty)
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result.removeValue(forKey: key)
            return result
        }
        let nested = result[key] as! [String: Any]
        result[key] = removingValue(
            in: nested,
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

    private struct ImplicitConformanceCanaryPayload: Sendable {
        let value: Int
    }

    private struct ImplicitConformanceCanaryResult {
        private let compositionResult: ImplicitConformanceCanaryPayload

        fileprivate init(
            compositionResult: ImplicitConformanceCanaryPayload
        ) {
            self.compositionResult = compositionResult
        }
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
}

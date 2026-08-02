// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContract

    private static let contractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContract.swift"
    private static let contractFileByteCount: UInt64 = 42_027
    private static let contractFileSHA256 =
        "667f69bc9746e7eb6ab580e28d1980a5b534510343ffeb001fc6b1f30e874486"
    private static let sourceContractSHA256 =
        "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494"

    func testFrozenV21SourceContractBindsOnlyCompilerCheckedComposition()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.preservedCompositionDesignV20ContractSHA256,
            "b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c"
        )
        XCTAssertEqual(
            contract.preservedTopologyV20SHA256,
            "b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57"
        )
        XCTAssertEqual(
            contract.preservedWorkerDecoderCallEdgeV19ContractSHA256,
            "f8739c0d162e026522dbdc2e6902403d935ebcfd2c9d13b07704b05ea3f9dac8"
        )
        XCTAssertTrue(contract.resultTypeMaterialized)
        XCTAssertTrue(contract.compositionSourceAppended)
        XCTAssertTrue(contract.compositionCompilerBound)
        XCTAssertFalse(contract.compositionRuntimeExercised)
        XCTAssertFalse(contract.mainCanNameOrReachComposition)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertEqual(contract.primeDisposition, "ABSTAIN")

        let contractBytes = try checkedInData(Self.contractRelativePath)
        XCTAssertEqual(
            UInt64(contractBytes.count),
            Self.contractFileByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: contractBytes),
            Self.contractFileSHA256
        )

        for nonclaim in [
            contract.packageGraphChanged,
            contract.workerSourceInventoryChanged,
            contract.workerDependenciesChanged,
            contract.workerResourcesChanged,
            contract.runtimeInputAccepted,
            contract.runtimeOutputProduced,
            contract.workerRequestHandlingEnabled,
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.fixtureMaterialized,
            contract.exporterRuntimeInvocationObserved,
            contract.projectorRuntimeInvocationObserved,
            contract.decoderRuntimeInvocationObserved,
            contract.artifactFilesystemReadPerformed,
            contract.artifactWritePerformed,
            contract.replayTransportIntegrated,
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
    }

    func testAppendOnlyWorkerSourceAndTransparentHistoricalTestsMatch()
        throws
    {
        let contract = Contract.frozenV1
        let live = try checkedInData(
            contract.compositionSource.primeRelativePath
        )

        XCTAssertEqual(
            UInt64(live.count),
            contract.compositionSource.byteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: live),
            contract.compositionSource.sha256
        )
        let prefix = Data(
            live.prefix(Int(contract.preservedV19SourcePrefixByteCount))
        )
        let suffix = Data(
            live.dropFirst(Int(contract.preservedV19SourcePrefixByteCount))
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefix),
            contract.preservedV19SourcePrefixSHA256
        )
        XCTAssertEqual(
            UInt64(suffix.count),
            contract.appendedV21SourceSuffixByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            contract.appendedV21SourceSuffixSHA256
        )
        XCTAssertTrue(contract.exactPrefixPreserved)
        XCTAssertTrue(contract.sourceEvolutionAppendOnly)

        for identity in [
            contract.packageSwift,
            contract.currentV19TopologyTest,
            contract.currentV20DesignTest,
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
        XCTAssertTrue(contract.historicalTestsEvolvedTransparently)
        XCTAssertNotEqual(
            contract.historicalV19TopologyTestBeforeV21.sha256,
            contract.currentV19TopologyTest.sha256
        )
        XCTAssertNotEqual(
            contract.historicalV20DesignTestBeforeV21.sha256,
            contract.currentV20DesignTest.sha256
        )
    }

    func testCompositionSourceHasExactOrderDelegationAndKeyedLinkage()
        throws
    {
        let contract = Contract.frozenV1
        let source = try checkedInString(
            contract.compositionSource.primeRelativePath
        )
        let suffix = String(
            source.dropFirst(Int(contract.preservedV19SourcePrefixByteCount))
        )
        let compact = suffix.filter { !$0.isWhitespace }
        let maintainedProjectorTypeName =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifact"
                + "Projection"
        let exactMaintainedProjectorCall =
            maintainedProjectorTypeName
                + ".pro" + "ject(evidence:evidence,context:context)"
        let imports = source.split(separator: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            contract.exactImportNames.map { "import \($0)" }
        )
        XCTAssertTrue(
            compact.contains(
                "privateenumPrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError:Error,Equatable,Sendable{casecontextMustRemainUnavailablecaseinvalidArtifactLinkage}"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "privatestructPrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult:Sendable{letprojectedArtifacts:PrimeNativeNeuralGateHistoricalProjectedArtifactSetletdecodedArtifacts:PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet}"
            )
        )
        XCTAssertTrue(
            compact.contains(
                contract.compositionNormalizedSignature.filter {
                    !$0.isWhitespace
                }
            )
        )
        XCTAssertTrue(
            compact.contains(
                contract.workerCallEdgeNormalizedSignature.filter {
                    !$0.isWhitespace
                }
            )
        )
        XCTAssertEqual(
            occurrenceCount(of: "funccompose(", in: compact),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "funcsourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(",
                in: compact
            ),
            1
        )
        XCTAssertTrue(
            compact.hasSuffix(
                "{trycompose(evidence:evidence,context:context)}}"
            )
        )
        XCTAssertTrue(
            compact.contains(exactMaintainedProjectorCall)
        )

        let guardIndex = try XCTUnwrap(
            compact.range(
                of:
                    "guardcontext.sourceBytesResolved==.unavailable,context.adaptationProofRecomputed==.unavailable"
            )
        ).lowerBound
        let projectionIndex = try XCTUnwrap(
            compact.range(
                of: exactMaintainedProjectorCall
            )
        ).lowerBound
        let decoderIndex = try XCTUnwrap(
            compact.range(
                of:
                    "sourceBoundHistoricalSemanticArtifactDecoderCallEdge(projectedArtifacts:projectedArtifacts)"
            )
        ).lowerBound
        let linkageIndex = try XCTUnwrap(
            compact.range(of: "letorderedBindings=")
        ).lowerBound
        let perKeyLoopIndex = try XCTUnwrap(
            compact.range(of: "forbindinginorderedBindings{")
        ).lowerBound
        let keyedLookupIndex = try XCTUnwrap(
            compact.range(
                of:
                    "projectedArtifacts.artifact(for:binding.key)"
            )
        ).lowerBound
        let finalLinkageGuardIndex = try XCTUnwrap(
            compact.range(
                of:
                    "projectedArtifact.sha256==binding.sha256"
            )
        ).lowerBound
        let resultIndex = try XCTUnwrap(
            compact.range(
                of:
                    "returnPrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult("
            )
        ).lowerBound
        XCTAssertLessThan(guardIndex, projectionIndex)
        XCTAssertLessThan(projectionIndex, decoderIndex)
        XCTAssertLessThan(decoderIndex, linkageIndex)
        XCTAssertLessThan(linkageIndex, perKeyLoopIndex)
        XCTAssertLessThan(perKeyLoopIndex, keyedLookupIndex)
        XCTAssertLessThan(keyedLookupIndex, finalLinkageGuardIndex)
        XCTAssertLessThan(finalLinkageGuardIndex, resultIndex)
        XCTAssertEqual(
            occurrenceCount(of: ".project(", in: compact),
            contract.exactProjectionCallCount
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "sourceBoundHistoricalSemanticArtifactDecoderCallEdge(",
                in: compact
            ),
            contract.exactMaintainedV19DecoderCallCount
        )
        XCTAssertTrue(
            compact.contains(
                "Set(orderedBindings.map(\\.key)).count==22"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifacts.invocationRole==context.invocationRole"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifacts.invocationRole==decodedArtifacts.canonicalLeaves.invocationRole"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifacts.orderedArtifacts.count==22"
            )
        )
        XCTAssertTrue(compact.contains("orderedBindings.count==22"))
        XCTAssertTrue(
            compact.contains(
                "projectedSpecifications==decodedSpecifications"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifacts.artifact(for:binding.key)"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifact.specification==(trybinding.specification)"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifact.byteCount==binding.byteCount"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "projectedArtifact.sha256==binding.sha256"
            )
        )
        XCTAssertFalse(compact.contains("evidence."))

        for forbidden in [
            "zip(",
            ".enumerated()",
            "orderedBindings[",
            "Dictionary(uniqueKeysWithValues:",
            ".sorted(",
            ".filter(",
            "try?",
            "try!",
            "catch",
            "evidence==",
            "==evidence",
            "evidence!=",
            "!=evidence",
            "Mirror(",
            "String(describing:",
            "String(reflecting:",
            "withUnsafe",
            "MemoryLayout",
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
            "mmap(",
            "decodeCanonicalLeaves(",
            "PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder(",
            ".consume(",
            "finishCurrentChunk(",
            "finishSemanticArtifactSet(",
            "globalOffset",
            "chunkOffset",
            ".export(",
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
            "extension\(contract.compositionResultTypeName)",
            "write(to:",
            "InputStream",
            "OutputStream",
            "Bundle.",
            "Logger(",
            "os_log",
            "ReplayTransport",
        ] {
            XCTAssertFalse(
                compact.contains(
                    forbidden.filter { !$0.isWhitespace }
                ),
                forbidden
            )
        }

        for forbiddenModifier in [
            "public",
            "open",
            "internal",
            "package",
            "fileprivate",
            "dynamic",
            "nonisolated",
        ] {
            XCTAssertNil(
                suffix.range(
                    of: "\\b\(forbiddenModifier)\\b",
                    options: .regularExpression
                ),
                forbiddenModifier
            )
        }
    }

    func testResultAndErrorRemainPrivateTypedAndAuthorityFree()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(contract.compositionResultAccessLevel, "private")
        XCTAssertEqual(
            contract.compositionResultExactFieldNames,
            ["projectedArtifacts", "decodedArtifacts"]
        )
        XCTAssertEqual(contract.compositionResultExactFieldCount, 2)
        XCTAssertTrue(contract.compositionResultSendable)
        XCTAssertFalse(contract.compositionResultCodable)
        XCTAssertFalse(contract.compositionResultEquatable)
        XCTAssertFalse(contract.compositionResultHashable)
        XCTAssertFalse(contract.compositionResultIdentifiable)
        XCTAssertFalse(
            contract.compositionResultCustomStringConvertible
        )
        XCTAssertFalse(contract.compositionResultPublicInitializer)
        XCTAssertFalse(contract.compositionResultRetainsEvidence)
        XCTAssertFalse(contract.compositionResultRetainsContext)
        XCTAssertEqual(
            contract.compositionErrorExactCaseNames,
            [
                "contextMustRemainUnavailable",
                "invalidArtifactLinkage",
            ]
        )
        XCTAssertTrue(contract.exactTypedFailurePropagationRequired)
        XCTAssertFalse(
            contract.retryCatchFallbackOrTryOptionalPermitted
        )
        XCTAssertFalse(contract.positionalArtifactJoinPermitted)
        XCTAssertFalse(
            contract.sortFilterRankOrRecommendationPermitted
        )
    }

    func testPackageInventoryAndUnavailableMainRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )
        XCTAssertEqual(contract.exactWorkerSwiftSourceFileCount, 4)
        XCTAssertEqual(contract.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(contract.workerResourceRelativePaths.count, 1)

        let main = try checkedInString(
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
        )
        let compactMain = main.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compactMain.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertFalse(main.contains(contract.compositionMethodName))
        XCTAssertFalse(main.contains(contract.workerCallEdgeMethodName))
        XCTAssertFalse(main.contains(contract.compositionResultTypeName))
    }

    func testCanonicalRoundTripAndFrozenSourceHash() throws {
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
    }

    func testSourceContractMutationsFailClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let mutations: [(String, Any)] = [
            ("exact_prefix_preserved", false),
            ("source_evolution_append_only", false),
            ("historical_tests_evolved_transparently", false),
            ("package_graph_changed", true),
            ("composition_result_codable", true),
            ("composition_result_equatable", true),
            ("context_unavailable_guard_precedes_projection", false),
            ("evidence_field_inspection_permitted", true),
            ("exact_projection_call_count", 2),
            ("exact_maintained_v19_decoder_call_count", 2),
            ("exact_linkage_typed_key_count", 21),
            ("linkage_uses_exact_typed_key_lookup", false),
            ("positional_artifact_join_permitted", true),
            ("retry_catch_fallback_or_try_optional_permitted", true),
            ("composition_runtime_exercised", true),
            ("runtime_output_produced", true),
            ("artifact_write_performed", true),
            ("evidence_published", true),
            ("source_binding_v7_issued", true),
            ("product_authority_authorized", true),
        ]

        for (key, value) in mutations {
            var mutation = object
            mutation[key] = value
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(try decoded.validate(), key)
        }

        var unknown = object
        unknown["unknown_future_authority"] = true
        let unknownData = try JSONSerialization.data(
            withJSONObject: unknown,
            options: [.sortedKeys]
        )
        XCTAssertNoThrow(
            try JSONDecoder().decode(
                Contract.self,
                from: unknownData
            ).validate()
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: unknownData
            )
        )
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

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
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

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

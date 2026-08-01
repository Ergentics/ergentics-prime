import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateHistoricalSourceDerivation
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceExportSourceContractTests:
    XCTestCase
{
    private typealias SourceContract =
        PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract

    private static let namespaceByteCount = 368_953
    private static let namespaceSHA256 =
        "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31"
    private static let suffixByteCount = 43_273
    private static let suffixSHA256 =
        "5eb1481f71b6071b56306e5bc20bd6ed2805cf7cad8441b5e9deb5929f026b67"
    private static let finalByteCount = 412_226
    private static let finalSHA256 =
        "a20bb86529988f75a46340b9a62924ebda151744a4028ad7726a2d712a385eae"
    private static let sourceContractSHA256 =
        "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"

    private static let gateRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNeuralNativeLanguageVerifyAbstainGate.swift"
    private static let exporterRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalEvidenceExportMechanics/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.swift"
    private static let suffixRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalSourceDerivation/HistoricalEvidenceExportSource/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.suffix.swiftpart"
    private static let workerRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"

    func testCheckedInSourceIsExactAppendOnlyDerivation()
        throws
    {
        let donor = try checkedInData(Self.gateRelativePath)
        let final = try checkedInData(
            Self.exporterRelativePath
        )
        let suffix = try checkedInData(
            Self.suffixRelativePath
        )

        XCTAssertEqual(donor.count, 368_918)
        XCTAssertEqual(
            donor.lazy.filter { $0 == 0x0A }.count,
            9_242
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: donor),
            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        )
        XCTAssertEqual(final.count, Self.finalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: final),
            Self.finalSHA256
        )
        XCTAssertEqual(donor.last, 0x0A)
        XCTAssertEqual(final.last, 0x0A)

        let namespace = Data(
            final.prefix(Self.namespaceByteCount)
        )
        XCTAssertEqual(namespace.count, Self.namespaceByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: namespace),
            Self.namespaceSHA256
        )
        XCTAssertEqual(suffix.count, Self.suffixByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            Self.suffixSHA256
        )
        XCTAssertEqual(namespace.last, 0x0A)
        XCTAssertEqual(suffix.last, 0x0A)
        XCTAssertEqual(
            Data(final.dropFirst(Self.namespaceByteCount)),
            suffix,
            "the final source tail must equal the independently checked-in suffix without intervening bytes"
        )

        var independentlyRewritten = try XCTUnwrap(
            String(data: donor, encoding: .utf8)
        )
        independentlyRewritten = try replacingExactlyOnce(
            in: independentlyRewritten,
            source:
                "public enum PrimeNeuralNativeLanguageVerifyAbstainGate {",
            replacement:
                "enum PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter {"
        )
        independentlyRewritten = try replacingExactlyOnce(
            in: independentlyRewritten,
            source:
                "PrimeNeuralNativeLanguageVerifyAbstainGate\n"
                + "                .exactMaterialsCacheKey",
            replacement:
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter\n"
                + "                .exactMaterialsCacheKey"
        )
        XCTAssertEqual(
            Data(independentlyRewritten.utf8),
            namespace
        )

        let first = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .deriveHistoricalEvidenceExportAdapter(
                nativeLanguageGateSource: donor,
                exporterSuffix: suffix
            )
        let second = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .deriveHistoricalEvidenceExportAdapter(
                nativeLanguageGateSource: donor,
                exporterSuffix: suffix
            )
        XCTAssertEqual(first, second)
        XCTAssertEqual(
            first.materialID,
            "exact_whole_gate_namespace_clone_two_rewrite_append_only_evidence_export_suffix_v1"
        )
        XCTAssertEqual(
            first.governingContractID,
            "prime_source_bound_historical_evidence_export_source_v13"
        )
        XCTAssertEqual(
            first.governingContractSHA256,
            Self.sourceContractSHA256
        )
        XCTAssertEqual(
            first.byteCount,
            UInt64(Self.finalByteCount)
        )
        XCTAssertEqual(first.sha256, Self.finalSHA256)
        XCTAssertEqual(first.bytes, final)
    }

    func testDerivationRejectsDonorAndSuffixDrift()
        throws
    {
        let donor = try checkedInData(Self.gateRelativePath)
        let final = try checkedInData(
            Self.exporterRelativePath
        )
        XCTAssertEqual(final.count, Self.finalByteCount)
        let suffix = try checkedInData(
            Self.suffixRelativePath
        )

        var donorCountDrift = donor
        donorCountDrift.append(0x0A)
        assertDerivationFails(
            donor: donorCountDrift,
            suffix: suffix,
            as: .donorByteCountMismatch
        )

        var donorContentDrift = donor
        donorContentDrift[donorContentDrift.startIndex] ^= 0x01
        assertDerivationFails(
            donor: donorContentDrift,
            suffix: suffix,
            as: .donorSHA256Mismatch
        )

        var suffixCountDrift = suffix
        suffixCountDrift.append(0x0A)
        assertDerivationFails(
            donor: donor,
            suffix: suffixCountDrift,
            as: .suffixByteCountMismatch
        )

        var suffixContentDrift = suffix
        suffixContentDrift[suffixContentDrift.startIndex]
            ^= 0x01
        assertDerivationFails(
            donor: donor,
            suffix: suffixContentDrift,
            as: .suffixSHA256Mismatch
        )
    }

    func testFrozenSourceContractBindsMaterialWithoutObservation()
        throws
    {
        let contract = SourceContract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_evidence_export_source_v13"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.checkedInByteExactGateRelativePath,
            Self.gateRelativePath
        )
        XCTAssertEqual(
            contract.checkedInByteExactGateByteCount,
            368_918
        )
        XCTAssertEqual(
            contract.checkedInByteExactGateSHA256,
            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        )
        XCTAssertEqual(
            contract.namespaceBasisByteCount,
            UInt64(Self.namespaceByteCount)
        )
        XCTAssertEqual(
            contract.namespaceBasisSHA256,
            Self.namespaceSHA256
        )
        XCTAssertEqual(
            contract.exporterSuffixSourceTargetName,
            "PrimeNativeNeuralGateHistoricalSourceDerivation"
        )
        XCTAssertEqual(
            contract.exporterSuffixSourceRelativePath,
            Self.suffixRelativePath
        )
        XCTAssertTrue(
            contract.exporterSuffixStoredAsIndependentCopiedResource
        )
        XCTAssertEqual(
            contract.exporterSuffixByteCount,
            UInt64(Self.suffixByteCount)
        )
        XCTAssertEqual(
            contract.exporterSuffixSHA256,
            Self.suffixSHA256
        )
        XCTAssertEqual(
            contract.finalDerivedSourceRelativePath,
            Self.exporterRelativePath
        )
        XCTAssertEqual(
            contract.finalDerivedSourceByteCount,
            UInt64(Self.finalByteCount)
        )
        XCTAssertEqual(
            contract.finalDerivedSourceSHA256,
            Self.finalSHA256
        )
        XCTAssertEqual(
            contract.targetBinding.directLocalDependencyNames,
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            ]
        )
        XCTAssertEqual(
            contract.targetBinding.orderedSourceRelativePaths,
            [Self.exporterRelativePath]
        )
        XCTAssertTrue(
            contract.targetBinding.copiedResourceRelativePaths
                .isEmpty
        )
        XCTAssertTrue(
            contract.targetBinding.externalProductDependencyNames
                .isEmpty
        )
        XCTAssertFalse(contract.targetBinding.productDeclared)
        XCTAssertEqual(contract.exactEvidenceFieldCount, 9)
        XCTAssertEqual(contract.exactMaterialsBridgeFieldCount, 12)
        XCTAssertEqual(
            contract.exactMutationFailurePolicyCount,
            46
        )
        XCTAssertTrue(
            contract.mutationFailurePolicies.allSatisfy {
                $0.orderedAllowedFailedLegIDs
                    == [$0.expectedFailedLegID]
                    && $0
                    .observedFailedLegIDsMustBeComputedIndependently
                    && !$0
                    .expectedSingletonMayStandInForObservedSet
                    && !$0.allowedSetMayBeWidenedAtRuntime
            }
        )
        XCTAssertTrue(
            contract
                .mutationStreamsUseExactHistoricalSweepConstruction
        )
        XCTAssertTrue(
            contract
                .completePrimitiveRegradeUsesFullMutatedEvaluation
        )
        XCTAssertTrue(
            contract
                .recordedHeldoutNonPaddingAndLossBindingsExported
        )
        XCTAssertTrue(
            contract.exactAbstentionDecisionInputsExported
        )
        XCTAssertTrue(
            contract
                .sourceDerivedRegradeDispositionSeparatedFromHistoricalVerdicts
        )
        XCTAssertFalse(contract.exporterCarrierCodable)
        XCTAssertTrue(contract.exporterCarrierRoleNeutral)
        XCTAssertTrue(contract.exporterCarrierPathFree)
        XCTAssertTrue(contract.exporterCarrierTimingFree)
        XCTAssertTrue(contract.exporterCarrierAuthorityFree)

        for observation in [
            contract.exporterInvoked,
            contract.workerInvoked,
            contract.historicalGateExecuted,
            contract.historicalEvidenceObserved,
            contract.durablePublicationObserved,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(observation)
        }
        XCTAssertEqual(
            try contract.contentSHA256(),
            Self.sourceContractSHA256
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                SourceContract.self,
                from: PrimeCanonicalJSON.encode(contract)
            ),
            contract
        )
    }

    func testSuffixExposesOnlyExactAuthorityFreeEvidenceFacade()
        throws
    {
        let suffix = try exporterSuffixSource()
        let publicStaticFunctions = try captures(
            pattern:
                #"\bpublic\s+static\s+func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("#,
            in: suffix
        )
        XCTAssertEqual(publicStaticFunctions, ["export"])
        XCTAssertEqual(
            occurrences(
                of:
                    "public enum PrimeNativeNeuralGateHistoricalEvidenceExporter",
                in: suffix
            ),
            1
        )

        let evidence = try balancedRegion(
            in: suffix,
            following: "public struct Evidence",
            open: "{",
            close: "}"
        )
        let evidenceDeclaration = try XCTUnwrap(
            evidence.split(separator: "{", maxSplits: 1)
                .first
        )
        XCTAssertEqual(
            compact(String(evidenceDeclaration)),
            "publicstructEvidence:Equatable,Sendable"
        )
        XCTAssertFalse(evidenceDeclaration.contains("Codable"))
        XCTAssertFalse(evidenceDeclaration.contains("Encodable"))
        XCTAssertFalse(evidenceDeclaration.contains("Decodable"))

        let evidenceFields = try captures(
            pattern:
                #"\bpublic\s+let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:"#,
            in: evidence
        )
        XCTAssertEqual(
            evidenceFields,
            [
                "orderedInvariantRecords",
                "orderedInvariantRecordASCIIFlags",
                "baselineInvariantBundle",
                "orderedMutationIdentities",
                "perMutationStreamIdentities",
                "perMutationFingerprints",
                "perMutationObservedFailedLegIDs",
                "historicalCriticalLegValues",
                "historicalStatisticsAndVerdictValues",
            ]
        )

        let publicFieldNames = try captures(
            pattern:
                #"\bpublic\s+let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:"#,
            in: suffix
        )
        let forbiddenFieldFragments = [
            "path",
            "url",
            "filelocation",
            "timestamp",
            "duration",
            "uptime",
            "wallclock",
            "process",
            "pid",
            "exit",
            "invocation",
            "role",
            "receipt",
            "publication",
            "authority",
            "authorized",
            "sourcebinding",
            "productadmission",
            "scientificclaim",
        ]
        for field in publicFieldNames {
            let normalized = field.lowercased()
            XCTAssertFalse(
                forbiddenFieldFragments.contains {
                    normalized.contains($0)
                },
                "public carrier field adds path, timing, role, or authority material: \(field)"
            )
        }
    }

    func testSuffixBridgesEveryMaterialAndNestedBindingByIdentity()
        throws
    {
        let suffix = try exporterSuffixSource()
        let labels = [
            "reportData",
            "tokenizerManifestData",
            "corpusManifestData",
            "packageResolvedArtifactBinding",
            "probeTokenManifestDataBySeed",
            "evaluationShardDataBySeed",
            "executorArtifactDataByFileName",
            "recommenderArtifactDataByFileName",
            "checkpointArtifactBindingBySeed",
            "metalLibraryArtifactBindingBySeed",
            "trainingStageArtifactDataBySeed",
            "configurationArtifactDataBySeed",
        ]

        let bridgedCall = try callFollowing(
            "let bridged =",
            callMarker: ".Materials(",
            in: suffix
        )
        let bridgedArguments = try topLevelArguments(
            in: bridgedCall
        )
        XCTAssertEqual(
            bridgedArguments.map(\.label),
            labels
        )
        XCTAssertEqual(
            bridgedArguments.map(\.value),
            [
                "source.reportData",
                "source.tokenizerManifestData",
                "source.corpusManifestData",
                "packageResolvedArtifactBinding",
                "source.probeTokenManifestDataBySeed",
                "source.evaluationShardDataBySeed",
                "source.executorArtifactDataByFileName",
                "source.recommenderArtifactDataByFileName",
                "checkpointArtifactBindingBySeed",
                "metalLibraryArtifactBindingBySeed",
                "source.trainingStageArtifactDataBySeed",
                "source.configurationArtifactDataBySeed",
            ]
        )

        let mutationCall = try callFollowing(
            "let mutatedMaterials =",
            callMarker: "Materials(",
            in: suffix
        )
        let mutationArguments = try topLevelArguments(
            in: mutationCall
        )
        XCTAssertEqual(mutationArguments.map(\.label), labels)
        XCTAssertEqual(
            mutationArguments.map(\.value),
            ["mutatedReportData"]
                + labels.dropFirst().map {
                    "materials.\($0)"
                }
        )

        try assertIdentityMapping(
            in: suffix,
            anchor: "let packageResolvedArtifactBinding =",
            callMarker: ".ObservedPackageResolvedBinding(",
            fields: [
                "fileName",
                "sha256",
                "byteCount",
                "mlxSwiftRevision",
                "mlxSwiftExamplesVersion",
            ]
        )
        try assertIdentityMapping(
            in: suffix,
            anchor: "let checkpointArtifactBindingBySeed =",
            callMarker: ".ObservedCheckpointBinding(",
            fields: [
                "fileName",
                "sha256",
                "byteCount",
            ]
        )
        try assertIdentityMapping(
            in: suffix,
            anchor: "let metalLibraryArtifactBindingBySeed =",
            callMarker: ".ObservedMetalLibraryBinding(",
            fields: [
                "primaryFileName",
                "fallbackFileName",
                "sha256",
                "byteCount",
            ]
        )
        let compactSuffix = compact(suffix)
        XCTAssertTrue(
            compactSuffix.contains(
                "source.checkpointArtifactBindingBySeed.map{seed,bindingin(seed,PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedCheckpointBinding("
            ),
            "checkpoint dictionary keys must be retained by identity"
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "source.metalLibraryArtifactBindingBySeed.map{seed,bindingin(seed,PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedMetalLibraryBinding("
            ),
            "Metal dictionary keys must be retained by identity"
        )
    }

    func testSuffixObservesEveryPrimitiveLegBeforeExpectedComparison()
        throws
    {
        let suffix = try exporterSuffixSource()
        let compactSuffix = compact(suffix)

        XCTAssertEqual(
            occurrences(
                of: "letmutated=evaluate(mutatedMaterials)",
                in: compactSuffix
            ),
            1
        )
        XCTAssertEqual(
            occurrences(
                of: "namedLegFails(",
                in: suffix
            ),
            0,
            "the expected-leg detector may not stand in for a full observed failure set"
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "letprimitiveLegIDs=Array(criticalLegIDs.prefix(9))"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "letprimitiveValues=[mutated.materialReload,mutated.sz,mutated.foundationCorpus,mutated.rawExecutor,mutated.causalMechanics,mutated.durability,mutated.sameSeedReplay,mutated.seedConsensus,mutated.capability,]"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "letobserved=zip(primitiveLegIDs,primitiveValues).compactMap{legID,passedinpassed?nil:legID}"
            )
        )
        XCTAssertEqual(
            occurrences(
                of: "mutation.expectedFailedLeg",
                in: suffix
            ),
            1
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "observed.orderedObservedFailedLegIDs==[mutation.expectedFailedLeg]"
            )
        )

        let observation = try XCTUnwrap(
            suffix.range(of: "let observed = zip(")
        )
        let storedObservation = try XCTUnwrap(
            suffix.range(of: "observedFailureSets.append(")
        )
        let expectedComparison = try XCTUnwrap(
            suffix.range(
                of: "let exactSingletonFailureSetsSatisfied ="
            )
        )
        XCTAssertLessThan(
            observation.lowerBound,
            storedObservation.lowerBound
        )
        XCTAssertLessThan(
            storedObservation.lowerBound,
            expectedComparison.lowerBound
        )
    }

    func testSuffixSeparatesHistoricalMutationStreamsFromFullRegrade()
        throws
    {
        let suffix = try exporterSuffixSource()
        let compactSuffix = compact(suffix)

        for required in [
            "letmutatedReports=mutatedReports(baseline.reports,mutation:mutation)",
            "ifmutation.mutatesRawPredictions,letmutatedSeed=baseline.reports.first?.seed{reusableRows.removeValue(forKey:mutatedSeed)}",
            "letmutationBaselinePlan=finiteFieldBaselinePlan(cacheKey:baseline.exactArtifactCacheKey,records:baseline.invariantRecords,recordIsASCII:baseline.invariantRecordIsASCII)",
            "letmutatedRecordCollection=invariantRecords(reports:mutatedReports,tokenizer:baseline.tokenizer,corpus:baseline.corpus,rowHashRegrade:mutation!=.executorRowHash,cachedRowRecordsBySeed:reusableRows)",
            "letdonorMutatedFingerprint=finiteFieldFingerprint(mutatedRecordCollection.records,recordIsASCII:mutatedRecordCollection.isASCII,using:mutationBaselinePlan)",
            "letmutatedBundle=tryPrimeNativeNeuralGateInvariantCodec.makeBundle(records:mutatedRecords)",
            "letmutatedReportData=trymutatedReports.map{trycanonicalEncoder().encode($0)}",
            "letmutated=evaluate(mutatedMaterials)",
            "mutatedStreamSHA256:mutatedBundle.manifest.globalStreamSHA256",
            "orderedObservedFailedLegIDs:observed",
        ] {
            XCTAssertTrue(
                compactSuffix.contains(required),
                "missing distinct historical-stream or full-regrade binding: \(required)"
            )
        }
        XCTAssertFalse(
            compactSuffix.contains("mutated.invariantRecords"),
            "the historical mutation stream must not be replaced by the full regrade's invariant records"
        )

        let historicalStream = try XCTUnwrap(
            suffix.range(
                of:
                    "let mutatedRecordCollection = invariantRecords("
            )
        )
        let historicalFingerprint = try XCTUnwrap(
            suffix.range(of: "let donorMutatedFingerprint =")
        )
        let fullRegradeMaterial = try XCTUnwrap(
            suffix.range(of: "let mutatedReportData =")
        )
        let fullRegrade = try XCTUnwrap(
            suffix.range(
                of: "let mutated = evaluate(mutatedMaterials)"
            )
        )
        let observation = try XCTUnwrap(
            suffix.range(of: "let observed = zip(")
        )
        XCTAssertLessThan(
            historicalStream.lowerBound,
            historicalFingerprint.lowerBound
        )
        XCTAssertLessThan(
            historicalFingerprint.lowerBound,
            fullRegradeMaterial.lowerBound
        )
        XCTAssertLessThan(
            fullRegradeMaterial.lowerBound,
            fullRegrade.lowerBound
        )
        XCTAssertLessThan(
            fullRegrade.lowerBound,
            observation.lowerBound
        )
    }

    func testSuffixRetainsStatisticsTypedAbstentionAndSeparateDisposition()
        throws
    {
        let suffix = try exporterSuffixSource()
        let lossRow = try balancedRegion(
            in: suffix,
            following: "public struct HeldoutLossRowValue",
            open: "{",
            close: "}"
        )
        let lossRowFields = [
            "rowID",
            "rowSHA256",
            "selectionSplitID",
            "targetClass",
            "semanticFamily",
            "targetTokenCount",
            "nonPaddingTokenCount",
            "crossEntropyBefore",
            "crossEntropyAfter",
        ]
        XCTAssertEqual(
            try publicLetNames(in: lossRow),
            lossRowFields
        )
        let compactLossRow = compact(lossRow)
        for field in lossRowFields {
            XCTAssertTrue(
                compactLossRow.contains(
                    "\(field)=row.\(field)"
                ),
                "heldout loss row field is not identity-mapped: \(field)"
            )
        }

        let statistics = try balancedRegion(
            in: suffix,
            following: "public struct HeldoutStatisticsValue",
            open: "{",
            close: "}"
        )
        XCTAssertEqual(
            try publicLetNames(in: statistics),
            [
                "seed",
                "heldoutRowCount",
                "heldoutValidRowCount",
                "heldoutRefusalRowCount",
                "heldoutTargetTokenCount",
                "heldoutValidTargetTokenCount",
                "heldoutRefusalTargetTokenCount",
                "heldoutEvaluationNonPaddingTokenCount",
                "heldoutCrossEntropyBefore",
                "heldoutCrossEntropyAfter",
                "heldoutValidCrossEntropyBefore",
                "heldoutValidCrossEntropyAfter",
                "heldoutRefusalCrossEntropyBefore",
                "heldoutRefusalCrossEntropyAfter",
                "heldoutCrossEntropyStandardError",
                "heldoutCrossEntropyStandardErrorMethodID",
                "heldoutFamilyCrossEntropyBefore",
                "heldoutFamilyCrossEntropyAfter",
                "initialLoss",
                "finalLoss",
                "heldoutLossRows",
            ]
        )
        let compactStatistics = compact(statistics)
        XCTAssertTrue(compactStatistics.contains("seed=report.seed"))
        let trainingFields = [
            "heldoutRowCount",
            "heldoutValidRowCount",
            "heldoutRefusalRowCount",
            "heldoutTargetTokenCount",
            "heldoutValidTargetTokenCount",
            "heldoutRefusalTargetTokenCount",
            "heldoutEvaluationNonPaddingTokenCount",
            "heldoutCrossEntropyBefore",
            "heldoutCrossEntropyAfter",
            "heldoutValidCrossEntropyBefore",
            "heldoutValidCrossEntropyAfter",
            "heldoutRefusalCrossEntropyBefore",
            "heldoutRefusalCrossEntropyAfter",
            "heldoutCrossEntropyStandardError",
            "heldoutCrossEntropyStandardErrorMethodID",
            "heldoutFamilyCrossEntropyBefore",
            "heldoutFamilyCrossEntropyAfter",
            "initialLoss",
            "finalLoss",
        ]
        for field in trainingFields {
            XCTAssertTrue(
                compactStatistics.contains(
                    "\(field)=training.\(field)"
                ),
                "heldout statistic is not bound to recorded training material: \(field)"
            )
        }
        XCTAssertTrue(
            compactStatistics.contains(
                "heldoutLossRows=training.heldoutLossRows.map(HeldoutLossRowValue.init)"
            )
        )

        let abstentionRow = try balancedRegion(
            in: suffix,
            following:
                "public struct AbstentionDecisionRowValue",
            open: "{",
            close: "}"
        )
        XCTAssertEqual(
            try publicLetNames(in: abstentionRow),
            [
                "rowID",
                "corpusRowSHA256",
                "evaluationRowSHA256",
                "splitID",
                "target",
                "trainedPrediction",
                "trainedTerminatedByEOS",
                "trainedTerminationReason",
                "trainedUTF8Valid",
                "trainedExactMatch",
                "trainedSemanticVerifierPass",
                "trainedAbstentionDecision",
            ]
        )
        let compactAbstentionRow = compact(abstentionRow)
        for field in [
            "rowID",
            "corpusRowSHA256",
            "evaluationRowSHA256",
            "target",
            "trainedPrediction",
            "trainedTerminatedByEOS",
            "trainedTerminationReason",
            "trainedUTF8Valid",
            "trainedExactMatch",
            "trainedSemanticVerifierPass",
            "trainedAbstentionDecision",
        ] {
            XCTAssertTrue(
                compactAbstentionRow.contains(
                    "\(field)=row.\(field)"
                ),
                "typed abstention row is not identity-mapped: \(field)"
            )
        }
        XCTAssertTrue(
            compactAbstentionRow.contains(
                "splitID=row.split.rawValue"
            )
        )
        let capability = try balancedRegion(
            in: suffix,
            following: "public struct CapabilityValue",
            open: "{",
            close: "}"
        )
        XCTAssertEqual(
            try publicLetNames(in: capability),
            [
                "seed",
                "orderedSplitValues",
                "requiredAbstentionRowCount",
                "orderedAbstentionDecisionRows",
                "exactAbstentionDecisionsObserved",
            ]
        )
        let compactCapability = compact(capability)
        for required in [
            "requiredAbstentionRowCount=2_048",
            "letabstentionRows=report.rawPredictions.filter{$0.split==.abstention}",
            "orderedAbstentionDecisionRows=abstentionRows.map{AbstentionDecisionRowValue(row:$0)}",
            "exactAbstentionDecisionsObserved=abstentionRows.count==requiredAbstentionRowCount",
            "row.target==\"ABSTAIN\\n\"",
            "row.trainedPrediction==\"ABSTAIN\\n\"",
            "row.trainedTerminatedByEOS",
            "row.trainedTerminationReason==\"eos\"",
            "row.trainedUTF8Valid",
            "row.trainedExactMatch",
            "row.trainedSemanticVerifierPass",
            "row.trainedAbstentionDecision",
        ] {
            XCTAssertTrue(
                compactCapability.contains(required),
                "missing exact typed abstention input: \(required)"
            )
        }

        let disposition = try balancedRegion(
            in: suffix,
            following:
                "public struct SourceDerivedSingletonRegradeDisposition",
            open: "{",
            close: "}"
        )
        XCTAssertEqual(
            try publicLetNames(in: disposition),
            [
                "exactSingletonFailureSetsSatisfied",
                "outcome",
            ]
        )
        XCTAssertTrue(
            compact(disposition).contains(
                "outcome=exactSingletonFailureSetsSatisfied?\"GROUNDED\":\"ABSTAIN\""
            )
        )

        let historicalValues = try balancedRegion(
            in: suffix,
            following:
                "public struct HistoricalStatisticsAndVerdictValues",
            open: "{",
            close: "}"
        )
        XCTAssertEqual(
            try publicLetNames(in: historicalValues),
            [
                "heldoutStatistics",
                "fixedPromptReplayValues",
                "capabilityValues",
                "historicalAgreeCount",
                "historicalIndependentPassCount",
                "historicalOutcome",
                "historicalTriadicLabel",
                "historicalNextAction",
                "materialReloadComponents",
                "historicalMutationOutcome",
                "historicalMutationTriadicLabel",
                "historicalMutationValues",
                "sourceDerivedSingletonRegradeDisposition",
            ]
        )
        let compactSuffix = compact(suffix)
        XCTAssertTrue(
            compactSuffix.contains(
                "historicalOutcome:assessment.outcome"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "historicalTriadicLabel:assessment.triadicVerdict"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "historicalMutationOutcome:sweep.outcome"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "historicalMutationTriadicLabel:sweep.triadicVerdict"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "historicalMutationValues:historicalMutationValues,sourceDerivedSingletonRegradeDisposition:sourceDerivedSingletonRegradeDisposition"
            )
        )
    }

    func testSuffixAddsNoProcessFilesystemTimingOrTrapEdges()
        throws
    {
        let suffix = try exporterSuffixSource()
        let forbiddenPatterns = [
            #"\bProcess\b"#,
            #"\bProcessInfo\b"#,
            #"\bURL\b"#,
            #"\bFileManager\b"#,
            #"\bsystemUptime\b"#,
            #"\bContinuousClock\b"#,
            #"\bSuspendingClock\b"#,
            #"\bDispatchTime\b"#,
            #"\bCFAbsoluteTime\b"#,
            #"\bDate\s*\("#,
            #"@main\b"#,
            #"\b(?:Darwin\.)?exit\s*\("#,
            #"\b_exit\s*\("#,
            #"\b(?:debugPrint|print)\s*\("#,
            #"\btry\s*!"#,
            #"\bfatalError\s*\("#,
            #"\bprecondition\s*\("#,
            #"\bpreconditionFailure\s*\("#,
        ]
        for pattern in forbiddenPatterns {
            XCTAssertTrue(
                try matches(pattern: pattern, in: suffix)
                    .isEmpty,
                "append-only suffix adds forbidden runtime edge: \(pattern)"
            )
        }
        XCTAssertFalse(suffix.contains(".path"))
    }

    func testSuffixRejectsInvalidSeedCatalogBeforeNontrappingCacheConstruction()
        throws
    {
        let suffix = try exporterSuffixSource()
        let compactSuffix = compact(suffix)

        XCTAssertFalse(
            compactSuffix.contains(
                "uniqueKeysWithValues:baseline.reports.map"
            ),
            "untrusted report seeds must not reach a trapping dictionary initializer"
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "letbaselineSeeds=baseline.reports.map(\\.seed)"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "guardbaselineSeeds.sorted()==ErgenticsNativeLanguageCanary.frozenSeeds.sorted(),Set(baselineSeeds).count==ErgenticsNativeLanguageCanary.frozenSeeds.countelse{throwPrimeNativeNeuralGateHistoricalEvidenceExportError.invalidBaselineSeedCatalog}"
            )
        )
        XCTAssertTrue(
            compactSuffix.contains(
                "guardcachedRowsBySeed[report.seed]==nilelse{throwPrimeNativeNeuralGateHistoricalEvidenceExportError.invalidBaselineSeedCatalog}"
            )
        )

        let seedCatalogGuard = try XCTUnwrap(
            suffix.range(of: "let baselineSeeds =")
        )
        let cacheDeclaration = try XCTUnwrap(
            suffix.range(of: "var cachedRowsBySeed =")
        )
        let cacheInsertion = try XCTUnwrap(
            suffix.range(
                of: "cachedRowsBySeed[report.seed] ="
            )
        )
        XCTAssertLessThan(
            seedCatalogGuard.lowerBound,
            cacheDeclaration.lowerBound
        )
        XCTAssertLessThan(
            cacheDeclaration.lowerBound,
            cacheInsertion.lowerBound
        )
    }

    func testPackageTargetHasOnlyTheFrozenDependenciesAndNoRuntimeConsumer()
        throws
    {
        let package = try checkedInSource("Package.swift")
        let targetName =
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
        let targetCalls = try callRegions(
            marker: ".target(",
            in: package
        )
        let target = try XCTUnwrap(
            targetCalls.only { $0.contains(targetName) }
        )
        XCTAssertEqual(
            compact(target),
            #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",dependencies:["ErgenticsPrimeRuntime","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateHistoricalReplayMechanics",])"#
        )
        let targetDirectory = repositoryRoot
            .appendingPathComponent(
                "Sources/\(targetName)",
                isDirectory: true
            )
        let targetEntries = try FileManager.default
            .contentsOfDirectory(
                at: targetDirectory,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                    .isSymbolicLinkKey,
                ],
                options: []
            )
        XCTAssertEqual(
            targetEntries.map(\.lastPathComponent).sorted(),
            [
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.swift"
            ]
        )
        let soleTargetSource = try XCTUnwrap(
            targetEntries.only {
                $0.lastPathComponent
                    == "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.swift"
            }
        )
        let targetSourceValues = try soleTargetSource
            .resourceValues(forKeys: [
                .isRegularFileKey,
                .isSymbolicLinkKey,
            ])
        XCTAssertEqual(targetSourceValues.isRegularFile, true)
        XCTAssertEqual(targetSourceValues.isSymbolicLink, false)
        XCTAssertEqual(
            soleTargetSource.standardizedFileURL.path,
            repositoryRoot.appendingPathComponent(
                Self.exporterRelativePath
            ).standardizedFileURL.path
        )
        for forbidden in [
            "resources:",
            "plugins:",
            "swiftSettings:",
            "unsafeFlags",
        ] {
            XCTAssertFalse(target.contains(forbidden), forbidden)
        }

        let derivationTargetName =
            "PrimeNativeNeuralGateHistoricalSourceDerivation"
        let derivationTarget = try XCTUnwrap(
            targetCalls.only {
                $0.contains(derivationTargetName)
            }
        )
        XCTAssertEqual(
            compact(derivationTarget),
            #".target(name:"PrimeNativeNeuralGateHistoricalSourceDerivation",dependencies:["PrimeNativeNeuralGateReplayMechanics",],resources:[.copy("HistoricalEvidenceExportSource"),])"#
        )
        XCTAssertEqual(
            occurrences(
                of: #".copy("HistoricalEvidenceExportSource")"#,
                in: compact(package)
            ),
            1
        )
        XCTAssertTrue(derivationTarget.contains(derivationTargetName))

        let products = try balancedRegion(
            in: package,
            following: "products: [",
            open: "[",
            close: "]"
        )
        XCTAssertFalse(products.contains(targetName))

        let productionConsumers =
            try callRegions(marker: ".target(", in: package)
            .filter {
                $0 != target && $0.contains(targetName)
            }
            + callRegions(
                marker: ".executableTarget(",
                in: package
            ).filter { $0.contains(targetName) }
        XCTAssertTrue(
            productionConsumers.isEmpty,
            "the exporter must have no production or executable reverse dependency"
        )

        let testConsumers = try callRegions(
            marker: ".testTarget(",
            in: package
        ).filter { $0.contains(targetName) }
        XCTAssertEqual(testConsumers.count, 1)
        XCTAssertTrue(
            testConsumers[0].contains(
                "PrimeNativeNeuralGateHistoricalReplayMechanicsTests"
            )
        )
        XCTAssertEqual(
            occurrences(of: targetName, in: package),
            2,
            "only the target declaration and its compile-only test edge are allowed"
        )

        let workerTarget = try XCTUnwrap(
            try callRegions(
                marker: ".executableTarget(",
                in: package
            ).only {
                $0.contains(
                    "PrimeNativeNeuralGateHistoricalFixtureWorker"
                )
            }
        )
        XCTAssertFalse(workerTarget.contains(targetName))
    }

    func testWorkerRemainsByteExactAndUnavailable()
        throws
    {
        let worker = try checkedInData(
            Self.workerRelativePath
        )
        XCTAssertEqual(worker.count, 2_298)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: worker),
            "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
        )
        let source = try XCTUnwrap(
            String(data: worker, encoding: .utf8)
        )
        let compactSource = compact(source)
        XCTAssertTrue(
            compactSource.contains(
                "staticletunavailableExitStatus:Int32=78"
            )
        )
        XCTAssertTrue(
            compactSource.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertFalse(
            source.contains(
                "PrimeNativeNeuralGateHistoricalEvidenceExporter"
            )
        )
        XCTAssertFalse(
            source.contains(
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
            )
        )
    }

    private func assertDerivationFails(
        donor: Data,
        suffix: Data,
        as expected:
            PrimeNativeNeuralGateHistoricalSourceDerivationError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .deriveHistoricalEvidenceExportAdapter(
                    nativeLanguageGateSource: donor,
                    exporterSuffix: suffix
                ),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func assertIdentityMapping(
        in source: String,
        anchor: String,
        callMarker: String,
        fields: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let call = try callFollowing(
            anchor,
            callMarker: callMarker,
            in: source
        )
        let arguments = try topLevelArguments(in: call)
        XCTAssertEqual(
            arguments.map(\.label),
            fields,
            file: file,
            line: line
        )
        XCTAssertEqual(
            arguments.map(\.value),
            fields.map { "binding.\($0)" },
            file: file,
            line: line
        )
    }

    private func exporterSuffixSource() throws -> String {
        let suffix = try checkedInData(
            Self.suffixRelativePath
        )
        XCTAssertEqual(suffix.count, Self.suffixByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: suffix),
            Self.suffixSHA256
        )
        return try XCTUnwrap(
            String(
                data: suffix,
                encoding: .utf8
            )
        )
    }

    private func checkedInSource(
        _ relativePath: String
    ) throws -> String {
        try XCTUnwrap(
            String(
                data: checkedInData(relativePath),
                encoding: .utf8
            )
        )
    }

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                )
        )
    }

    private func replacingExactlyOnce(
        in source: String,
        source needle: String,
        replacement: String
    ) throws -> String {
        XCTAssertEqual(occurrences(of: needle, in: source), 1)
        let range = try XCTUnwrap(source.range(of: needle))
        var result = source
        result.replaceSubrange(range, with: replacement)
        return result
    }

    private func callFollowing(
        _ anchor: String,
        callMarker: String,
        in source: String
    ) throws -> String {
        let anchorRange = try XCTUnwrap(
            source.range(of: anchor)
        )
        let remainder = String(source[anchorRange.upperBound...])
        return try XCTUnwrap(
            try callRegions(
                marker: callMarker,
                in: remainder
            ).first
        )
    }

    private func callRegions(
        marker: String,
        in source: String
    ) throws -> [String] {
        var result: [String] = []
        var searchStart = source.startIndex
        while searchStart < source.endIndex,
              let markerRange = source.range(
                  of: marker,
                  range: searchStart..<source.endIndex
              )
        {
            let region = try balancedRegion(
                in: source,
                startingAt: markerRange.lowerBound,
                open: "(",
                close: ")"
            )
            result.append(region.text)
            searchStart = region.endIndex
        }
        return result
    }

    private func balancedRegion(
        in source: String,
        following marker: String,
        open: Character,
        close: Character
    ) throws -> String {
        let markerRange = try XCTUnwrap(
            source.range(of: marker)
        )
        return try balancedRegion(
            in: source,
            startingAt: markerRange.lowerBound,
            open: open,
            close: close
        ).text
    }

    private func balancedRegion(
        in source: String,
        startingAt start: String.Index,
        open: Character,
        close: Character
    ) throws -> (text: String, endIndex: String.Index) {
        let openIndex = try XCTUnwrap(
            source[start...].firstIndex(of: open)
        )
        var depth = 0
        var cursor = openIndex
        while cursor < source.endIndex {
            let character = source[cursor]
            if character == open {
                depth += 1
            } else if character == close {
                depth -= 1
                if depth == 0 {
                    let end = source.index(after: cursor)
                    return (
                        String(source[start..<end]),
                        end
                    )
                }
            }
            cursor = source.index(after: cursor)
        }
        XCTFail("unbalanced source region")
        throw SourceContractError.unbalancedRegion
    }

    private func topLevelArguments(
        in call: String
    ) throws -> [SourceArgument] {
        let open = try XCTUnwrap(call.firstIndex(of: "("))
        let close = try XCTUnwrap(call.lastIndex(of: ")"))
        let contentStart = call.index(after: open)
        var segments: [Substring] = []
        var segmentStart = contentStart
        var parentheses = 0
        var brackets = 0
        var braces = 0
        var cursor = contentStart
        while cursor < close {
            switch call[cursor] {
            case "(": parentheses += 1
            case ")": parentheses -= 1
            case "[": brackets += 1
            case "]": brackets -= 1
            case "{": braces += 1
            case "}": braces -= 1
            case ","
                where parentheses == 0
                    && brackets == 0
                    && braces == 0:
                segments.append(call[segmentStart..<cursor])
                segmentStart = call.index(after: cursor)
            default: break
            }
            cursor = call.index(after: cursor)
        }
        if segmentStart < close {
            segments.append(call[segmentStart..<close])
        }

        return try segments.compactMap { segment in
            let trimmed = segment.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            guard !trimmed.isEmpty else { return nil }
            let colon = try XCTUnwrap(
                trimmed.firstIndex(of: ":")
            )
            let valueStart = trimmed.index(after: colon)
            return SourceArgument(
                label: compact(
                    String(trimmed[..<colon])
                ),
                value: compact(
                    String(trimmed[valueStart...])
                )
            )
        }
    }

    private func captures(
        pattern: String,
        in source: String
    ) throws -> [String] {
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.matches(
            in: source,
            range: NSRange(source.startIndex..., in: source)
        ).compactMap { match in
            guard match.numberOfRanges > 1,
                  let range = Range(
                      match.range(at: 1),
                      in: source
                  )
            else {
                return nil
            }
            return String(source[range])
        }
    }

    private func publicLetNames(
        in source: String
    ) throws -> [String] {
        try captures(
            pattern:
                #"\bpublic\s+let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:"#,
            in: source
        )
    }

    private func matches(
        pattern: String,
        in source: String
    ) throws -> [NSTextCheckingResult] {
        try NSRegularExpression(pattern: pattern)
            .matches(
                in: source,
                range: NSRange(
                    source.startIndex...,
                    in: source
                )
            )
    }

    private func occurrences(
        of needle: String,
        in source: String
    ) -> Int {
        guard !needle.isEmpty else { return 0 }
        var result = 0
        var searchStart = source.startIndex
        while searchStart < source.endIndex,
              let range = source.range(
                  of: needle,
                  range: searchStart..<source.endIndex
              )
        {
            result += 1
            searchStart = range.upperBound
        }
        return result
    }

    private func compact(_ source: String) -> String {
        String(source.filter { !$0.isWhitespace })
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private struct SourceArgument {
        let label: String
        let value: String
    }

    private enum SourceContractError: Error {
        case unbalancedRegion
    }
}

private extension Array {
    func only(
        where predicate: (Element) throws -> Bool
    ) rethrows -> Element? {
        let matches = try filter(predicate)
        return matches.count == 1 ? matches[0] : nil
    }
}

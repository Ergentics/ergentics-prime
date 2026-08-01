import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateHistoricalSourceDerivationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case inputOrdinalMismatch
    case donorByteCountMismatch
    case donorSHA256Mismatch
    case suffixByteCountMismatch
    case suffixSHA256Mismatch
    case nonCanonicalUTF8Source
    case invalidLineRange(Int)
    case lineGroupByteCountMismatch(Int)
    case lineGroupSHA256Mismatch(Int)
    case invalidSeparator(Int)
    case joinedBodyMismatch
    case rewriteSourceOccurrenceMismatch(String)
    case transformedBodyMismatch
    case outputMismatch
    case authorityDrift
}

public struct PrimeNativeNeuralGateDerivedSourceMaterial:
    Equatable,
    Sendable
{
    public let materialID: String
    public let governingContractID: String?
    public let governingContractSHA256: String?
    public let byteCount: UInt64
    public let sha256: String
    public let bytes: Data

    init(
        materialID: String,
        governingContractID: String? = nil,
        governingContractSHA256: String? = nil,
        bytes: Data
    ) {
        self.materialID = materialID
        self.governingContractID = governingContractID
        self.governingContractSHA256 =
            governingContractSHA256
        byteCount = UInt64(bytes.count)
        sha256 = PrimeNativeNeuralGateInvariantCodec
            .sha256(bytes)
        self.bytes = bytes
    }
}

public struct PrimeNativeNeuralGateHistoricalSourceMaterialBundle:
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let bundleID: String
    public let contractSHA256: String
    public let nativeLanguageGateSourceByteCount: UInt64
    public let nativeLanguageGateSourceSHA256: String
    public let verdictCarrierSourceByteCount: UInt64
    public let verdictCarrierSourceSHA256: String
    public let carrierMaterial:
        PrimeNativeNeuralGateDerivedSourceMaterial
    public let gateCarrierUseMaterial:
        PrimeNativeNeuralGateDerivedSourceMaterial
    public let mutationMaterial:
        PrimeNativeNeuralGateDerivedSourceMaterial
    public let aggregateMaterialSHA256: String
    public let sourcePinsMatched: Bool
    public let sourceRepositoryContextObserved: Bool
    public let rawMutationSourceMaterialDerived: Bool
    public let perCaseSourceParsingPerformed: Bool
    public let executableTransformBindingEstablished: Bool
    public let exactFailureSetsDerived: Bool
    public let historicalDonorExecuted: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let historicalTargetsMaterialized: Bool
    public let durableObservationPublished: Bool
    public let sourceBindingV7Issued: Bool
    public let mechanicsPassAuthorized: Bool
    public let receiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    init(
        contractSHA256: String,
        nativeLanguageGateSource: Data,
        verdictCarrierSource: Data,
        carrierMaterial:
            PrimeNativeNeuralGateDerivedSourceMaterial,
        gateCarrierUseMaterial:
            PrimeNativeNeuralGateDerivedSourceMaterial,
        mutationMaterial:
            PrimeNativeNeuralGateDerivedSourceMaterial,
        aggregateMaterialSHA256: String
    ) {
        schemaVersion = 1
        bundleID =
            "prime_source_pinned_historical_gate_carrier_and_mutation_material_bundle_v1"
        self.contractSHA256 = contractSHA256
        nativeLanguageGateSourceByteCount =
            UInt64(nativeLanguageGateSource.count)
        nativeLanguageGateSourceSHA256 =
            PrimeNativeNeuralGateInvariantCodec.sha256(
                nativeLanguageGateSource
            )
        verdictCarrierSourceByteCount =
            UInt64(verdictCarrierSource.count)
        verdictCarrierSourceSHA256 =
            PrimeNativeNeuralGateInvariantCodec.sha256(
                verdictCarrierSource
            )
        self.carrierMaterial = carrierMaterial
        self.gateCarrierUseMaterial =
            gateCarrierUseMaterial
        self.mutationMaterial = mutationMaterial
        self.aggregateMaterialSHA256 =
            aggregateMaterialSHA256
        sourcePinsMatched = true
        sourceRepositoryContextObserved = false
        rawMutationSourceMaterialDerived = true
        perCaseSourceParsingPerformed = false
        executableTransformBindingEstablished = false
        exactFailureSetsDerived = false
        historicalDonorExecuted = false
        independentDetectionEstablished = false
        distinctImplementationFamiliesEstablished = false
        historicalTargetsMaterialized = false
        durableObservationPublished = false
        sourceBindingV7Issued = false
        mechanicsPassAuthorized = false
        receiptAuthorized = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
    }

    func validate() throws {
        guard schemaVersion == 1,
              bundleID
                == "prime_source_pinned_historical_gate_carrier_and_mutation_material_bundle_v1",
              contractSHA256
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenContractSHA256,
              nativeLanguageGateSourceByteCount
                == 368_918,
              nativeLanguageGateSourceSHA256
                == "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
              verdictCarrierSourceByteCount == 4_659,
              verdictCarrierSourceSHA256
                == "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
              carrierMaterial.materialID
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenCarrierDerivation.derivationID,
              carrierMaterial.byteCount
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenCarrierDerivation
                .expectedOutputByteCount,
              carrierMaterial.sha256
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenCarrierDerivation
                .expectedOutputSHA256,
              gateCarrierUseMaterial.materialID
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenGateCarrierUseDerivation
                .derivationID,
              gateCarrierUseMaterial.byteCount
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenGateCarrierUseDerivation
                .expectedOutputByteCount,
              gateCarrierUseMaterial.sha256
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenGateCarrierUseDerivation
                .expectedOutputSHA256,
              mutationMaterial.materialID
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenMutationMaterialDerivation
                .derivationID,
              mutationMaterial.byteCount
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenMutationMaterialDerivation
                .expectedOutputByteCount,
              mutationMaterial.sha256
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenMutationMaterialDerivation
                .expectedOutputSHA256,
              aggregateMaterialSHA256
                == Self.aggregateSHA256(
                    contractSHA256: contractSHA256,
                    materials: [
                        carrierMaterial,
                        gateCarrierUseMaterial,
                        mutationMaterial,
                    ]
                ),
              aggregateMaterialSHA256
                == PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenAggregateMaterialSHA256,
              sourcePinsMatched,
              !sourceRepositoryContextObserved,
              rawMutationSourceMaterialDerived,
              !perCaseSourceParsingPerformed,
              !executableTransformBindingEstablished,
              !exactFailureSetsDerived,
              !historicalDonorExecuted,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !historicalTargetsMaterialized,
              !durableObservationPublished,
              !sourceBindingV7Issued,
              !mechanicsPassAuthorized,
              !receiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .authorityDrift
        }
    }

    static func aggregateSHA256(
        contractSHA256: String,
        materials:
            [PrimeNativeNeuralGateDerivedSourceMaterial]
    ) -> String {
        var records = [
            "prime_historical_source_material_aggregate_v1",
            "contract|\(contractSHA256)",
        ]
        records.append(
            contentsOf: materials.map {
                "\($0.materialID)|\($0.byteCount)|\($0.sha256)"
            }
        )
        return PrimeNativeNeuralGateInvariantCodec.sha256(
            Data(
                (records.joined(separator: "\n") + "\n")
                    .utf8
            )
        )
    }
}

/// Pure in-memory source derivation over exact frozen donor bytes.
///
/// The public boundary accepts only the two donor byte blobs. Callers cannot
/// provide paths, ranges, hashes, labels, rewrites, or expected outcomes.
public enum PrimeNativeNeuralGateHistoricalSourceDerivation {
    public static let frozenAggregateMaterialSHA256 =
        "9184d0a2feab238a81728aa62c05710121dd77c0b9371761ec5d6d065d9702af"

    /// Derives the frozen historical fixture from its two exact donor inputs.
    ///
    /// The package lock is an input pin even though the emitted Swift bytes
    /// come from the fixture source. Its exact digest is embedded by the
    /// frozen fixture rewrite, so accepting any other lock would break the
    /// source-to-output evidence chain.
    public static func deriveHistoricalFixture(
        fixtureSource: Data,
        packageResolvedArtifact: Data
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        let fixturePin = frozenHistoricalFixtureSourcePin
        let packagePin = frozenHistoricalPackageResolvedPin

        try validatePinnedInput(
            fixtureSource,
            expectedByteCount: fixturePin.byteCount,
            expectedSHA256: fixturePin.sha256
        )
        try validatePinnedInput(
            packageResolvedArtifact,
            expectedByteCount: packagePin.byteCount,
            expectedSHA256: packagePin.sha256
        )

        return try derive(
            donorBytes: fixtureSource,
            requiredInputOrdinals: [
                fixturePin.ordinal,
                packagePin.ordinal,
            ],
            expectedDonorByteCount: fixturePin.byteCount,
            expectedDonorSHA256: fixturePin.sha256,
            contract: frozenHistoricalFixtureDerivation
        )
    }

    /// Materializes the exact V13 historical evidence-export source from the
    /// pinned byte-exact gate and the separately pinned append-only suffix.
    ///
    /// Both inputs are caller-supplied bytes. This operation performs no
    /// repository lookup and does not compile or execute the derived source.
    public static func deriveHistoricalEvidenceExportAdapter(
        nativeLanguageGateSource: Data,
        exporterSuffix: Data
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        let gatePin = frozenNativeLanguageGatePin
        let suffixPin =
            frozenHistoricalEvidenceExportSuffixPin

        try validatePinnedInput(
            nativeLanguageGateSource,
            expectedByteCount: gatePin.byteCount,
            expectedSHA256: gatePin.sha256
        )
        guard UInt64(exporterSuffix.count)
                == suffixPin.byteCount
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .suffixByteCountMismatch
        }
        guard PrimeNativeNeuralGateInvariantCodec
                .sha256(exporterSuffix)
                == suffixPin.sha256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .suffixSHA256Mismatch
        }
        try validateCanonicalSource(exporterSuffix)

        let namespace = try derive(
            donorBytes: nativeLanguageGateSource,
            inputOrdinal: gatePin.ordinal,
            expectedDonorByteCount: gatePin.byteCount,
            expectedDonorSHA256: gatePin.sha256,
            contract:
                frozenHistoricalEvidenceExportNamespaceDerivation
        )
        var output = namespace.bytes
        output.append(exporterSuffix)
        guard UInt64(output.count)
                == frozenHistoricalEvidenceExportFinalByteCount,
              PrimeNativeNeuralGateInvariantCodec
                .sha256(output)
                == frozenHistoricalEvidenceExportFinalSHA256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .outputMismatch
        }
        return PrimeNativeNeuralGateDerivedSourceMaterial(
            materialID:
                frozenHistoricalEvidenceExportDerivationID,
            governingContractID:
                frozenHistoricalEvidenceExportSourceContractID,
            governingContractSHA256:
                frozenHistoricalEvidenceExportSourceContractSHA256,
            bytes: output
        )
    }

    public static func derive(
        nativeLanguageGateSource: Data,
        verdictCarrierSource: Data
    ) throws
        -> PrimeNativeNeuralGateHistoricalSourceMaterialBundle
    {
        let gatePin = frozenNativeLanguageGatePin
        let carrierPin = frozenVerdictCarrierPin

        try validatePinnedInput(
            nativeLanguageGateSource,
            expectedByteCount: gatePin.byteCount,
            expectedSHA256: gatePin.sha256
        )
        try validatePinnedInput(
            verdictCarrierSource,
            expectedByteCount: carrierPin.byteCount,
            expectedSHA256: carrierPin.sha256
        )

        let carrier = try derive(
            donorBytes: verdictCarrierSource,
            inputOrdinal: carrierPin.ordinal,
            expectedDonorByteCount:
                carrierPin.byteCount,
            expectedDonorSHA256: carrierPin.sha256,
            contract: frozenCarrierDerivation
        )
        let gateCarrierUse = try derive(
            donorBytes: nativeLanguageGateSource,
            inputOrdinal: gatePin.ordinal,
            expectedDonorByteCount: gatePin.byteCount,
            expectedDonorSHA256: gatePin.sha256,
            contract: frozenGateCarrierUseDerivation
        )
        let mutationMaterial = try derive(
            donorBytes: nativeLanguageGateSource,
            inputOrdinal: gatePin.ordinal,
            expectedDonorByteCount: gatePin.byteCount,
            expectedDonorSHA256: gatePin.sha256,
            contract: frozenMutationMaterialDerivation
        )
        let contractSHA256 = frozenContractSHA256
        let bundle =
            PrimeNativeNeuralGateHistoricalSourceMaterialBundle(
                contractSHA256: contractSHA256,
                nativeLanguageGateSource:
                    nativeLanguageGateSource,
                verdictCarrierSource:
                    verdictCarrierSource,
                carrierMaterial: carrier,
                gateCarrierUseMaterial: gateCarrierUse,
                mutationMaterial: mutationMaterial,
                aggregateMaterialSHA256:
                    PrimeNativeNeuralGateHistoricalSourceMaterialBundle
                    .aggregateSHA256(
                        contractSHA256: contractSHA256,
                        materials: [
                            carrier,
                            gateCarrierUse,
                            mutationMaterial,
                        ]
                    )
            )
        try bundle.validate()
        return bundle
    }

    static func deriveForTesting(
        donorBytes: Data,
        inputOrdinal: Int,
        expectedDonorByteCount: UInt64,
        expectedDonorSHA256: String,
        contract:
            PrimeNativeNeuralGateHistoricalSourceDerivationContract
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        try derive(
            donorBytes: donorBytes,
            inputOrdinal: inputOrdinal,
            expectedDonorByteCount:
                expectedDonorByteCount,
            expectedDonorSHA256: expectedDonorSHA256,
            contract: contract
        )
    }

    private static func validatePinnedInput(
        _ data: Data,
        expectedByteCount: UInt64,
        expectedSHA256: String
    ) throws {
        guard UInt64(data.count) == expectedByteCount else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .donorByteCountMismatch
        }
        guard PrimeNativeNeuralGateInvariantCodec.sha256(data)
                == expectedSHA256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .donorSHA256Mismatch
        }
    }

    private static func derive(
        donorBytes: Data,
        inputOrdinal: Int,
        expectedDonorByteCount: UInt64,
        expectedDonorSHA256: String,
        contract:
            PrimeNativeNeuralGateHistoricalSourceDerivationContract
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        try derive(
            donorBytes: donorBytes,
            requiredInputOrdinals: [inputOrdinal],
            expectedDonorByteCount: expectedDonorByteCount,
            expectedDonorSHA256: expectedDonorSHA256,
            contract: contract
        )
    }

    private static func derive(
        donorBytes: Data,
        requiredInputOrdinals: [Int],
        expectedDonorByteCount: UInt64,
        expectedDonorSHA256: String,
        contract:
            PrimeNativeNeuralGateHistoricalSourceDerivationContract
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        guard contract.validate(
            donorByteCount: expectedDonorByteCount,
            donorSHA256: expectedDonorSHA256
        ) else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .contractDrift
        }
        guard contract.requiredInputOrdinals
                == requiredInputOrdinals
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .inputOrdinalMismatch
        }
        try validatePinnedInput(
            donorBytes,
            expectedByteCount: expectedDonorByteCount,
            expectedSHA256: expectedDonorSHA256
        )
        try validateCanonicalSource(donorBytes)

        switch contract.kind {
        case .byteExactDonor:
            return PrimeNativeNeuralGateDerivedSourceMaterial(
                materialID: contract.derivationID,
                bytes: donorBytes
            )
        case .frozenLineGroupsAndRewrites:
            break
        }

        let lines = canonicalLines(donorBytes)
        var joined = Data()
        for (index, group) in
            contract.lineGroups.enumerated()
        {
            guard group.firstLine > 0,
                  group.lastLine >= group.firstLine,
                  group.lastLine <= lines.count
            else {
                throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                    .invalidLineRange(group.ordinal)
            }
            var bytes = Data()
            for lineIndex in
                (group.firstLine - 1) ... (group.lastLine - 1)
            {
                bytes.append(lines[lineIndex])
            }
            switch group.terminalLFPolicy {
            case .preserveTerminalLF:
                break
            case .stripOneTerminalLF:
                guard bytes.last == 0x0a else {
                    throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                        .nonCanonicalUTF8Source
                }
                bytes.removeLast()
            }
            guard UInt64(bytes.count)
                    == group.expectedByteCount
            else {
                throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                    .lineGroupByteCountMismatch(
                        group.ordinal
                    )
            }
            guard PrimeNativeNeuralGateInvariantCodec
                    .sha256(bytes)
                    == group.expectedSHA256
            else {
                throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                    .lineGroupSHA256Mismatch(
                        group.ordinal
                    )
            }
            if index > 0 {
                joined.append(
                    try decodeHex(
                        contract.betweenGroupUTF8Hex[
                            index - 1
                        ],
                        ordinal: index
                    )
                )
            }
            joined.append(bytes)
        }
        guard UInt64(joined.count)
                == contract.joinedGroupByteCount,
              PrimeNativeNeuralGateInvariantCodec
                .sha256(joined)
                == contract.joinedGroupSHA256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .joinedBodyMismatch
        }

        var transformed = joined
        for rewrite in contract.rewrites {
            let source = Data(rewrite.sourceUTF8.utf8)
            let replacement =
                Data(rewrite.replacementUTF8.utf8)
            guard let range = onlyOccurrence(
                of: source,
                in: transformed
            ) else {
                throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                    .rewriteSourceOccurrenceMismatch(
                        rewrite.rewriteID
                    )
            }
            transformed.replaceSubrange(
                range,
                with: replacement
            )
        }
        guard UInt64(transformed.count)
                == contract.transformedBodyByteCount,
              PrimeNativeNeuralGateInvariantCodec
                .sha256(transformed)
                == contract.transformedBodySHA256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .transformedBodyMismatch
        }

        var output = Data(contract.prefixUTF8.utf8)
        output.append(transformed)
        output.append(Data(contract.suffixUTF8.utf8))
        guard UInt64(output.count)
                == contract.expectedOutputByteCount,
              PrimeNativeNeuralGateInvariantCodec
                .sha256(output)
                == contract.expectedOutputSHA256
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .outputMismatch
        }
        return PrimeNativeNeuralGateDerivedSourceMaterial(
            materialID: contract.derivationID,
            bytes: output
        )
    }

    private static func validateCanonicalSource(
        _ data: Data
    ) throws {
        guard data.count >= 1,
              data.last == 0x0a,
              !data.contains(0x0d),
              !data.starts(with: [0xef, 0xbb, 0xbf]),
              String(data: data, encoding: .utf8) != nil
        else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .nonCanonicalUTF8Source
        }
    }

    private static func canonicalLines(
        _ data: Data
    ) -> [Data] {
        var lines: [Data] = []
        var start = data.startIndex
        for index in data.indices where data[index] == 0x0a {
            lines.append(
                data.subdata(in: start ..< (index + 1))
            )
            start = index + 1
        }
        return lines
    }

    private static func decodeHex(
        _ value: String,
        ordinal: Int
    ) throws -> Data {
        let bytes = Array(value.utf8)
        guard bytes.count.isMultiple(of: 2) else {
            throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                .invalidSeparator(ordinal)
        }
        var result = Data()
        result.reserveCapacity(bytes.count / 2)
        var index = 0
        while index < bytes.count {
            guard let high = hexNibble(bytes[index]),
                  let low = hexNibble(bytes[index + 1])
            else {
                throw PrimeNativeNeuralGateHistoricalSourceDerivationError
                    .invalidSeparator(ordinal)
            }
            result.append(high << 4 | low)
            index += 2
        }
        return result
    }

    private static func hexNibble(
        _ byte: UInt8
    ) -> UInt8? {
        switch byte {
        case 48 ... 57:
            byte - 48
        case 97 ... 102:
            byte - 97 + 10
        default:
            nil
        }
    }

    private static func onlyOccurrence(
        of needle: Data,
        in haystack: Data
    ) -> Range<Data.Index>? {
        guard !needle.isEmpty,
              let first = haystack.range(of: needle)
        else {
            return nil
        }
        let nextCandidate = haystack.index(
            after: first.lowerBound
        )
        let remaining = nextCandidate ..< haystack.endIndex
        guard haystack.range(
            of: needle,
            in: remaining
        ) == nil else {
            return nil
        }
        return first
    }
}

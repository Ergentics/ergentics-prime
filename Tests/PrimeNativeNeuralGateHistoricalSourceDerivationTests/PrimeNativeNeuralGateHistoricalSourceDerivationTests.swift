import Foundation
import XCTest
@testable import PrimeCore
@testable import PrimeNativeNeuralGateHistoricalSourceDerivation
import PrimeNativeNeuralGateReplayMechanics

final class PrimeNativeNeuralGateHistoricalSourceDerivationTests:
    XCTestCase
{
    private enum DonorGatePolicyError:
        Error,
        Equatable
    {
        case invalidRequirementValue(String)
        case requiredRootMissing
    }

    private static let donorRootEnvironmentKey =
        "PRIME_PMHNP_COMPANION_ROOT"
    private static let donorRequirementEnvironmentKey =
        "PRIME_REQUIRE_V9_PINNED_DONOR_GATE"
    private static let fixtureRequirementEnvironmentKey =
        "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE"

    func testFrozenContractIdentitiesRemainExact() throws {
        let v2 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV2
        let v3 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3
        let contract =
            PrimeNativeNeuralGateHistoricalSourceMaterialContract
            .frozenV1
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(v2)
            ),
            "2c5dc058ce03f329581db88fa3ab3f1e8baf6faf06ead734d772821ed8af9b28"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(v3)
            ),
            "40db6bae391ef4a74723451307a66cda9b7b834c2262ae05085a5f3db68694c1"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "884588bbe5c0aad160366f611d096d88e14946f1923b88c78a5a8b3d6a546da8"
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateTrapDisjointTopologyContract
                .frozenV9.contentSHA256(),
            "5b5f6aae6c74d7b3cf8380093e6ebc1ba8b321f22e9476ac884c8b852ceacc90"
        )
        XCTAssertNil(
            try pinnedCompanionRoot(from: [:])
        )
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey: "1",
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.fixtureRequirementEnvironmentKey: "1",
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertThrowsError(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey:
                        "true",
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? DonorGatePolicyError,
                .invalidRequirementValue("true")
            )
        }
        XCTAssertThrowsError(
            try pinnedCompanionRoot(
                from: [
                    Self.fixtureRequirementEnvironmentKey:
                        "true",
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? DonorGatePolicyError,
                .invalidRequirementValue("true")
            )
        }
        for environment: [String: String] in [
            [Self.donorRequirementEnvironmentKey: "1"],
            [Self.fixtureRequirementEnvironmentKey: "1"],
            [
                Self.donorRequirementEnvironmentKey: "1",
                Self.donorRootEnvironmentKey: "",
            ],
            [
                Self.fixtureRequirementEnvironmentKey: "1",
                Self.donorRootEnvironmentKey: "",
            ],
        ] {
            XCTAssertThrowsError(
                try pinnedCompanionRoot(
                    from: environment
                )
            ) { error in
                XCTAssertEqual(
                    error as? DonorGatePolicyError,
                    .requiredRootMissing
                )
            }
        }
    }

    func testFrozenContractAndAdaptationV3PreserveAuthorityCeiling()
        throws
    {
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan.frozenV3
        let v2 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV2
        let v3 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3
        let contract =
            PrimeNativeNeuralGateHistoricalSourceMaterialContract
            .frozenV1

        XCTAssertNoThrow(
            try v2.validate(against: plan.inputPins)
        )
        XCTAssertNoThrow(
            try v3.validate(against: plan.inputPins)
        )
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenContractSHA256,
            try contract.contentSHA256()
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenNativeLanguageGatePin.ordinal,
            plan.inputPins[0].ordinal
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenNativeLanguageGatePin.byteCount,
            plan.inputPins[0].byteCount
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenNativeLanguageGatePin.sha256,
            plan.inputPins[0].sha256
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenVerdictCarrierPin.ordinal,
            plan.inputPins[8].ordinal
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenVerdictCarrierPin.byteCount,
            plan.inputPins[8].byteCount
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenVerdictCarrierPin.sha256,
            plan.inputPins[8].sha256
        )
        assertExactContractMatch(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenCarrierDerivation,
            contract.carrierDerivation
        )
        assertExactContractMatch(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenGateCarrierUseDerivation,
            contract.gateCarrierUseDerivation
        )
        assertExactContractMatch(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenMutationMaterialDerivation,
            contract.mutationMaterialDerivation
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenHistoricalFixtureSourcePin,
            .init(
                ordinal: 10,
                byteCount: 165_692,
                sha256:
                    "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c"
            )
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenHistoricalPackageResolvedPin,
            .init(
                ordinal: 11,
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            )
        )
        let frozenV2Fixture = v2.entries[9].derivation
        assertExactContractMatch(
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenHistoricalFixtureDerivation,
            frozenV2Fixture
        )
        XCTAssertEqual(
            frozenV2Fixture.requiredInputOrdinals,
            [10, 11]
        )
        XCTAssertEqual(
            frozenV2Fixture.expectedOutputByteCount,
            88_141
        )
        XCTAssertEqual(
            frozenV2Fixture.expectedOutputSHA256,
            "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
        )
        XCTAssertTrue(
            frozenV2Fixture.prefixUTF8.contains(
                "import PrimeNativeNeuralGateReplayMechanics\n"
            )
        )
        XCTAssertFalse(
            frozenV2Fixture.prefixUTF8.contains(
                "import PrimeNativeNeuralGateHistoricalReplayMechanics\n"
            )
        )
        XCTAssertNotEqual(v2.contractID, v3.contractID)
        XCTAssertEqual(
            v2.entries[0].primeDestinationRelativePath,
            "Sources/PrimeNativeNeuralGateReplayMechanics/PrimeNeuralNativeLanguageVerifyAbstainGate.swift"
        )
        XCTAssertEqual(
            v2.entries[8].primeDestinationRelativePath,
            "Sources/PrimeNativeNeuralGateReplayMechanics/PrimeNeuralVerifyAbstainGateCarrier.swift"
        )
        XCTAssertTrue(
            v3.entries[0].primeDestinationRelativePath?
                .hasPrefix(
                    contract.historicalDestinationRoot
                ) == true
        )
        XCTAssertTrue(
            v3.entries[8].primeDestinationRelativePath?
                .hasPrefix(
                    contract.historicalDestinationRoot
                ) == true
        )
        XCTAssertEqual(contract.exactMutationCount, 46)
        XCTAssertEqual(
            contract.rawPredictionMutationCount,
            12
        )
        XCTAssertFalse(
            contract.perCaseSourceParsingPerformed
        )
        XCTAssertFalse(
            contract
                .executableTransformBindingEstablished
        )
        XCTAssertFalse(contract.exactFailureSetsDerived)
        XCTAssertFalse(
            contract.historicalTargetsMaterialized
        )
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(
            contract.independentDetectionEstablished
        )
        XCTAssertFalse(
            contract
                .distinctImplementationFamiliesEstablished
        )
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(
            contract.scientificAuthorityAuthorized
        )
        XCTAssertFalse(
            contract.productAuthorityAuthorized
        )
    }

    func testCatalogEncodingIsNamedAndCountsRemainExact()
        throws
    {
        let contract =
            PrimeNativeNeuralGateHistoricalSourceMaterialContract
            .frozenV1
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try projection.validate()

        XCTAssertEqual(
            contract.projectionCatalogEncodingID,
            "prime_stage_a_projection_mutation_contract_ordinal_id_expected_leg_raw_prediction_v1"
        )
        XCTAssertEqual(
            contract.projectionCatalogSHA256,
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    projection.mutationCatalog
                )
            )
        )
        XCTAssertEqual(
            projection.mutationCatalog.count,
            contract.exactMutationCount
        )
        XCTAssertEqual(
            projection.mutationCatalog.filter(
                \.mutatesRawPredictions
            ).count,
            contract.rawPredictionMutationCount
        )
        let distribution = Dictionary(
            grouping: projection.mutationCatalog,
            by: \.expectedFailedLeg
        ).mapValues(\.count)
        XCTAssertEqual(
            distribution[
                "NL1_canonical_material_reload"
            ],
            15
        )
        XCTAssertEqual(
            distribution[
                "NL3_foundation_tokenizer_corpus_regrade"
            ],
            5
        )
        XCTAssertEqual(
            distribution[
                "NL4_raw_executor_row_regrade"
            ],
            8
        )
        XCTAssertEqual(
            distribution[
                "NL5_causal_training_mechanics"
            ],
            12
        )
        XCTAssertEqual(
            distribution[
                "NL6_checkpoint_durability"
            ],
            2
        )
        XCTAssertEqual(
            distribution[
                "NL7_same_seed_initialization_training_result_replay"
            ],
            1
        )
        XCTAssertEqual(
            distribution[
                "NL8_frozen_exact_seed_consensus"
            ],
            1
        )
        XCTAssertEqual(
            distribution[
                "NL9_capability_and_malformed_abstention"
            ],
            2
        )
        XCTAssertNil(
            distribution[
                "NL2_finite_field_sz_pool_expansion"
            ]
        )
        XCTAssertNil(
            distribution["NL10_mutation_synthesis"]
        )
    }

    func testLineGroupSeparatorAndRewriteMechanicsAreExact()
        throws
    {
        let donor = Data(
            "header\nalpha\nbeta\nomega\n".utf8
        )
        let joined = Data("alpha\n\nbeta\n".utf8)
        let transformed = Data("alpha\n\nBETA\n".utf8)
        let output = Data("<\nalpha\n\nBETA\n>\n".utf8)
        let contract =
            PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID: "synthetic_exact_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 2,
                        lastLine: 2,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 6,
                        expectedSHA256: digest(
                            Data("alpha\n".utf8)
                        )
                    ),
                    .init(
                        ordinal: 2,
                        firstLine: 3,
                        lastLine: 3,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 5,
                        expectedSHA256: digest(
                            Data("beta\n".utf8)
                        )
                    ),
                ],
                betweenGroupUTF8Hex: ["0a"],
                joinedGroupByteCount:
                    UInt64(joined.count),
                joinedGroupSHA256: digest(joined),
                prefixUTF8: "<\n",
                prefixByteCount: 2,
                prefixSHA256: digest(
                    Data("<\n".utf8)
                ),
                suffixUTF8: ">\n",
                suffixByteCount: 2,
                suffixSHA256: digest(
                    Data(">\n".utf8)
                ),
                rewrites: [
                    .init(
                        ordinal: 1,
                        rewriteID: "uppercase_beta",
                        sourceUTF8: "beta",
                        sourceByteCount: 4,
                        sourceSHA256: digest(
                            Data("beta".utf8)
                        ),
                        replacementUTF8: "BETA",
                        replacementByteCount: 4,
                        replacementSHA256: digest(
                            Data("BETA".utf8)
                        )
                    ),
                ],
                transformedBodyByteCount:
                    UInt64(transformed.count),
                transformedBodySHA256:
                    digest(transformed),
                expectedOutputByteCount:
                    UInt64(output.count),
                expectedOutputSHA256: digest(output)
            )

        let derived = try deriveForTesting(
            donor,
            contract: contract
        )
        XCTAssertEqual(derived.bytes, output)
        XCTAssertEqual(derived.sha256, digest(output))
    }

    func testBothContractValidatorsRejectAmbiguousRewritesAndNonUTF8Separators()
        throws
    {
        let empty = Data()
        let alpha = Data("alpha".utf8)
        let upperAlpha = Data("ALPHA".utf8)
        let beta = Data("beta".utf8)
        let upperBeta = Data("BETA".utf8)
        let historicalRewriteCases: [[
            PrimeNativeNeuralGateHistoricalSourceRewrite
        ]] = [
            [
                .init(
                    ordinal: 1,
                    rewriteID: "",
                    sourceUTF8: "alpha",
                    sourceByteCount: 5,
                    sourceSHA256: digest(alpha),
                    replacementUTF8: "ALPHA",
                    replacementByteCount: 5,
                    replacementSHA256:
                        digest(upperAlpha)
                ),
            ],
            [
                .init(
                    ordinal: 1,
                    rewriteID: "empty_source",
                    sourceUTF8: "",
                    sourceByteCount: 0,
                    sourceSHA256: digest(empty),
                    replacementUTF8: "",
                    replacementByteCount: 0,
                    replacementSHA256: digest(empty)
                ),
            ],
            [
                .init(
                    ordinal: 1,
                    rewriteID: "duplicate",
                    sourceUTF8: "alpha",
                    sourceByteCount: 5,
                    sourceSHA256: digest(alpha),
                    replacementUTF8: "ALPHA",
                    replacementByteCount: 5,
                    replacementSHA256:
                        digest(upperAlpha)
                ),
                .init(
                    ordinal: 2,
                    rewriteID: "duplicate",
                    sourceUTF8: "beta",
                    sourceByteCount: 4,
                    sourceSHA256: digest(beta),
                    replacementUTF8: "BETA",
                    replacementByteCount: 4,
                    replacementSHA256:
                        digest(upperBeta)
                ),
            ],
        ]
        let validationDonor = Data("alpha beta\n".utf8)
        for rewrites in historicalRewriteCases {
            XCTAssertFalse(
                historicalRewriteValidationContract(
                    rewrites
                ).validate(
                    donorByteCount:
                        UInt64(validationDonor.count),
                    donorSHA256: digest(validationDonor)
                )
            )
        }
        XCTAssertFalse(
            historicalSeparatorValidationContract(
                "ff"
            ).validate(
                donorByteCount: 4,
                donorSHA256:
                    digest(Data("a\nb\n".utf8))
            )
        )

        let coreRewriteCases: [[
            PrimeNativeNeuralGateSourceRewrite
        ]] = [
            [
                .init(
                    ordinal: 1,
                    rewriteID: "",
                    sourceUTF8: "alpha",
                    sourceByteCount: 5,
                    sourceSHA256: digest(alpha),
                    replacementUTF8: "ALPHA",
                    replacementByteCount: 5,
                    replacementSHA256:
                        digest(upperAlpha)
                ),
            ],
            [
                .init(
                    ordinal: 1,
                    rewriteID: "empty_source",
                    sourceUTF8: "",
                    sourceByteCount: 0,
                    sourceSHA256: digest(empty),
                    replacementUTF8: "",
                    replacementByteCount: 0,
                    replacementSHA256: digest(empty)
                ),
            ],
            [
                .init(
                    ordinal: 1,
                    rewriteID: "duplicate",
                    sourceUTF8: "alpha",
                    sourceByteCount: 5,
                    sourceSHA256: digest(alpha),
                    replacementUTF8: "ALPHA",
                    replacementByteCount: 5,
                    replacementSHA256:
                        digest(upperAlpha)
                ),
                .init(
                    ordinal: 2,
                    rewriteID: "duplicate",
                    sourceUTF8: "beta",
                    sourceByteCount: 4,
                    sourceSHA256: digest(beta),
                    replacementUTF8: "BETA",
                    replacementByteCount: 4,
                    replacementSHA256:
                        digest(upperBeta)
                ),
            ],
        ]
        for rewrites in coreRewriteCases {
            XCTAssertThrowsError(
                try coreRewriteValidationContract(
                    rewrites
                ).validate(
                    donorByteCount:
                        UInt64(validationDonor.count),
                    donorSHA256: digest(validationDonor)
                )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeNeuralGateFixtureReplayPlanError,
                    .invalidPlan("source_derivation")
                )
            }
        }
        XCTAssertThrowsError(
            try coreSeparatorValidationContract(
                "ff"
            ).validate(
                donorByteCount: 4,
                donorSHA256:
                    digest(Data("a\nb\n".utf8))
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateFixtureReplayPlanError,
                .invalidPlan("source_derivation")
            )
        }
    }

    func testCanonicalSourcePolicyRejectsBOMCRLFMissingLFAndInvalidUTF8()
        throws
    {
        let cases: [Data] = [
            Data([0xef, 0xbb, 0xbf])
                + Data("value\n".utf8),
            Data("value\r\n".utf8),
            Data("value".utf8),
            Data([0xff, 0x0a]),
        ]
        for donor in cases {
            let contract =
                PrimeNativeNeuralGateHistoricalSourceDerivationContract
                .byteExact(
                    inputOrdinal: 1,
                    byteCount: UInt64(donor.count),
                    sha256: digest(donor)
                )
            XCTAssertThrowsError(
                try deriveForTesting(
                    donor,
                    contract: contract
                )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeNeuralGateHistoricalSourceDerivationError,
                    .nonCanonicalUTF8Source
                )
            }
        }
    }

    func testLineMutationAndDuplicateRewriteFailClosed()
        throws
    {
        let donor = Data("alpha alpha\n".utf8)
        let wrongGroupHash = String(
            repeating: "0",
            count: 64
        )
        let lineMutationContract =
            PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID: "wrong_group_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 1,
                        lastLine: 1,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount:
                            UInt64(donor.count),
                        expectedSHA256: wrongGroupHash
                    ),
                ],
                joinedGroupByteCount:
                    UInt64(donor.count),
                joinedGroupSHA256: digest(donor),
                transformedBodyByteCount:
                    UInt64(donor.count),
                transformedBodySHA256: digest(donor),
                expectedOutputByteCount:
                    UInt64(donor.count),
                expectedOutputSHA256: digest(donor)
            )
        XCTAssertThrowsError(
            try deriveForTesting(
                donor,
                contract: lineMutationContract
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .lineGroupSHA256Mismatch(1)
            )
        }

        let duplicateRewriteContract =
            PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID: "duplicate_rewrite_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 1,
                        lastLine: 1,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount:
                            UInt64(donor.count),
                        expectedSHA256: digest(donor)
                    ),
                ],
                joinedGroupByteCount:
                    UInt64(donor.count),
                joinedGroupSHA256: digest(donor),
                rewrites: [
                    .init(
                        ordinal: 1,
                        rewriteID: "ambiguous_alpha",
                        sourceUTF8: "alpha",
                        sourceByteCount: 5,
                        sourceSHA256: digest(
                            Data("alpha".utf8)
                        ),
                        replacementUTF8: "omega",
                        replacementByteCount: 5,
                        replacementSHA256: digest(
                            Data("omega".utf8)
                        )
                    ),
                ],
                transformedBodyByteCount:
                    UInt64(donor.count),
                transformedBodySHA256:
                    String(repeating: "1", count: 64),
                expectedOutputByteCount:
                    UInt64(donor.count),
                expectedOutputSHA256:
                    String(repeating: "2", count: 64)
            )
        XCTAssertThrowsError(
            try deriveForTesting(
                donor,
                contract: duplicateRewriteContract
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .rewriteSourceOccurrenceMismatch(
                    "ambiguous_alpha"
                )
            )
        }

        let overlappingDonor = Data("aaa\n".utf8)
        let overlappingRewriteContract =
            PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID:
                    "overlapping_duplicate_rewrite_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 1,
                        lastLine: 1,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount:
                            UInt64(overlappingDonor.count),
                        expectedSHA256:
                            digest(overlappingDonor)
                    ),
                ],
                joinedGroupByteCount:
                    UInt64(overlappingDonor.count),
                joinedGroupSHA256:
                    digest(overlappingDonor),
                rewrites: [
                    .init(
                        ordinal: 1,
                        rewriteID:
                            "ambiguous_overlapping_aa",
                        sourceUTF8: "aa",
                        sourceByteCount: 2,
                        sourceSHA256:
                            digest(Data("aa".utf8)),
                        replacementUTF8: "bb",
                        replacementByteCount: 2,
                        replacementSHA256:
                            digest(Data("bb".utf8))
                    ),
                ],
                transformedBodyByteCount:
                    UInt64(overlappingDonor.count),
                transformedBodySHA256:
                    String(repeating: "1", count: 64),
                expectedOutputByteCount:
                    UInt64(overlappingDonor.count),
                expectedOutputSHA256:
                    String(repeating: "2", count: 64)
            )
        XCTAssertThrowsError(
            try deriveForTesting(
                overlappingDonor,
                contract: overlappingRewriteContract
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .rewriteSourceOccurrenceMismatch(
                    "ambiguous_overlapping_aa"
                )
            )
        }
    }

    func testPinnedDonorDerivationWhenCompanionRootIsProvided()
        throws
    {
        guard let root = try pinnedCompanionRoot(
            from: ProcessInfo.processInfo.environment
        ) else {
            throw XCTSkip(
                "standalone mode: set PRIME_PMHNP_COMPANION_ROOT to run the pinned donor derivation"
            )
        }
        let rootURL = URL(
            fileURLWithPath: root,
            isDirectory: true
        )
        let gate = try Data(
            contentsOf: rootURL.appendingPathComponent(
                "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift"
            )
        )
        let carrier = try Data(
            contentsOf: rootURL.appendingPathComponent(
                "neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift"
            )
        )

        let first = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .derive(
                nativeLanguageGateSource: gate,
                verdictCarrierSource: carrier
            )
        try assertHistoricalMutationSourceMatchesProjection(
            gate
        )
        let second = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .derive(
                nativeLanguageGateSource: gate,
                verdictCarrierSource: carrier
            )
        XCTAssertEqual(first, second)

        var mutatedGate = gate
        mutatedGate[mutatedGate.startIndex] ^= 0x01
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .derive(
                    nativeLanguageGateSource: mutatedGate,
                    verdictCarrierSource: carrier
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorSHA256Mismatch
            )
        }

        var mutatedCarrier = carrier
        mutatedCarrier[mutatedCarrier.startIndex] ^= 0x01
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .derive(
                    nativeLanguageGateSource: gate,
                    verdictCarrierSource: mutatedCarrier
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorSHA256Mismatch
            )
        }

        var truncatedGate = gate
        truncatedGate.removeLast()
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .derive(
                    nativeLanguageGateSource: truncatedGate,
                    verdictCarrierSource: carrier
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorByteCountMismatch
            )
        }

        var appendedCarrier = carrier
        appendedCarrier.append(0x0a)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .derive(
                    nativeLanguageGateSource: gate,
                    verdictCarrierSource: appendedCarrier
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorByteCountMismatch
            )
        }

        for (donor, inputOrdinal, derivation) in [
            (
                carrier,
                9,
                PrimeNativeNeuralGateHistoricalSourceDerivation
                    .frozenCarrierDerivation
            ),
            (
                gate,
                1,
                PrimeNativeNeuralGateHistoricalSourceDerivation
                    .frozenGateCarrierUseDerivation
            ),
            (
                gate,
                1,
                PrimeNativeNeuralGateHistoricalSourceDerivation
                    .frozenMutationMaterialDerivation
            ),
        ] {
            for group in derivation.lineGroups {
                var mutated = donor
                let index = try XCTUnwrap(
                    startIndex(
                        ofOneBasedLine: group.firstLine,
                        in: mutated
                    )
                )
                mutated[index] ^= 0x01
                XCTAssertThrowsError(
                    try PrimeNativeNeuralGateHistoricalSourceDerivation
                        .deriveForTesting(
                            donorBytes: mutated,
                            inputOrdinal: inputOrdinal,
                            expectedDonorByteCount:
                                UInt64(mutated.count),
                            expectedDonorSHA256:
                                digest(mutated),
                            contract: derivation
                        )
                ) { error in
                    XCTAssertEqual(
                        error as?
                            PrimeNativeNeuralGateHistoricalSourceDerivationError,
                        .lineGroupSHA256Mismatch(
                            group.ordinal
                        )
                    )
                }
            }
        }

        XCTAssertEqual(
            first.carrierMaterial.byteCount,
            2_397
        )
        XCTAssertEqual(
            first.carrierMaterial.sha256,
            "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f"
        )
        XCTAssertEqual(
            first.gateCarrierUseMaterial.byteCount,
            510
        )
        XCTAssertEqual(
            first.gateCarrierUseMaterial.sha256,
            "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb"
        )
        XCTAssertEqual(
            first.mutationMaterial.byteCount,
            45_090
        )
        XCTAssertEqual(
            first.mutationMaterial.sha256,
            "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb"
        )
        XCTAssertEqual(
            first.aggregateMaterialSHA256,
            PrimeNativeNeuralGateHistoricalSourceDerivation
                .frozenAggregateMaterialSHA256
        )
        XCTAssertEqual(
            first.aggregateMaterialSHA256,
            "9184d0a2feab238a81728aa62c05710121dd77c0b9371761ec5d6d065d9702af"
        )
        XCTAssertTrue(first.sourcePinsMatched)
        XCTAssertTrue(
            first.rawMutationSourceMaterialDerived
        )
        XCTAssertFalse(
            first.perCaseSourceParsingPerformed
        )
        XCTAssertFalse(
            first.executableTransformBindingEstablished
        )
        XCTAssertFalse(first.exactFailureSetsDerived)
        XCTAssertFalse(first.historicalDonorExecuted)
        XCTAssertFalse(
            first.independentDetectionEstablished
        )
        XCTAssertFalse(first.mechanicsPassAuthorized)
        XCTAssertFalse(first.sourceBindingV7Issued)
        XCTAssertFalse(
            first.scientificAuthorityAuthorized
        )
        XCTAssertFalse(first.productAuthorityAuthorized)
    }

    func testPinnedHistoricalFixtureDerivationWhenCompanionRootIsProvided()
        throws
    {
        guard let root = try pinnedCompanionRoot(
            from: ProcessInfo.processInfo.environment
        ) else {
            throw XCTSkip(
                "standalone mode: set PRIME_PMHNP_COMPANION_ROOT to run the pinned fixture derivation"
            )
        }
        let rootURL = URL(
            fileURLWithPath: root,
            isDirectory: true
        )
        let fixtureSource = try Data(
            contentsOf: rootURL.appendingPathComponent(
                "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift"
            )
        )
        let packageResolvedArtifact = try Data(
            contentsOf: rootURL.appendingPathComponent(
                "neural-kit/Package.resolved"
            )
        )

        let first = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .deriveHistoricalFixture(
                fixtureSource: fixtureSource,
                packageResolvedArtifact:
                    packageResolvedArtifact
            )
        let second = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .deriveHistoricalFixture(
                fixtureSource: fixtureSource,
                packageResolvedArtifact:
                    packageResolvedArtifact
            )

        XCTAssertEqual(first, second)
        XCTAssertEqual(
            first.materialID,
            "exact_lf_forensic_fixture_five_group_four_rewrite_v1"
        )
        XCTAssertEqual(first.byteCount, 88_141)
        XCTAssertEqual(
            first.sha256,
            "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
        )
        let checkedInFixture = try Data(
            contentsOf: URL(
                fileURLWithPath:
                    FileManager.default.currentDirectoryPath,
                isDirectory: true
            ).appendingPathComponent(
                "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift"
            )
        )
        XCTAssertEqual(first.bytes, checkedInFixture)
        let derivedSource = try XCTUnwrap(
            String(data: first.bytes, encoding: .utf8)
        )
        XCTAssertTrue(
            derivedSource.hasPrefix(
                "import CryptoKit\n"
                    + "import ErgenticsPrimeRuntime\n"
                    + "import PrimeNativeNeuralGateReplayMechanics\n"
                    + "import Foundation\n\n"
            )
        )
        XCTAssertFalse(
            derivedSource.contains(
                "import PrimeNativeNeuralGateHistoricalReplayMechanics"
            )
        )
        XCTAssertTrue(
            derivedSource.contains(
                "== \"cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3\""
            )
        )

        var mutatedFixture = fixtureSource
        mutatedFixture[mutatedFixture.startIndex] ^= 0x01
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .deriveHistoricalFixture(
                    fixtureSource: mutatedFixture,
                    packageResolvedArtifact:
                        packageResolvedArtifact
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorSHA256Mismatch
            )
        }

        var mutatedPackage = packageResolvedArtifact
        mutatedPackage[mutatedPackage.startIndex] ^= 0x01
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .deriveHistoricalFixture(
                    fixtureSource: fixtureSource,
                    packageResolvedArtifact: mutatedPackage
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorSHA256Mismatch
            )
        }

        var truncatedFixture = fixtureSource
        truncatedFixture.removeLast()
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .deriveHistoricalFixture(
                    fixtureSource: truncatedFixture,
                    packageResolvedArtifact:
                        packageResolvedArtifact
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorByteCountMismatch
            )
        }

        var appendedPackage = packageResolvedArtifact
        appendedPackage.append(0x0a)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalSourceDerivation
                .deriveHistoricalFixture(
                    fixtureSource: fixtureSource,
                    packageResolvedArtifact: appendedPackage
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeNeuralGateHistoricalSourceDerivationError,
                .donorByteCountMismatch
            )
        }
    }

    func testTargetSourceHasNoFilesystemProcessOrWorkerMechanics()
        throws
    {
        let root = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let targetRoot = root.appendingPathComponent(
            "Sources/PrimeNativeNeuralGateHistoricalSourceDerivation",
            isDirectory: true
        )
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: targetRoot,
                includingPropertiesForKeys: nil,
                options: []
            )
        )
        let targetPrefix =
            targetRoot.standardizedFileURL.path + "/"
        var sourceURLs: [URL] = []
        var sourceRelativePaths: [String] = []
        for case let sourceURL as URL in enumerator
        where sourceURL.pathExtension == "swift"
        {
            let standardizedPath =
                sourceURL.standardizedFileURL.path
            guard standardizedPath.hasPrefix(targetPrefix)
            else {
                XCTFail("source escaped target root")
                continue
            }
            sourceURLs.append(sourceURL)
            sourceRelativePaths.append(
                String(
                    standardizedPath.dropFirst(
                        targetPrefix.count
                    )
                )
            )
        }
        XCTAssertEqual(
            sourceRelativePaths.sorted(),
            [
                "PrimeNativeNeuralGateHistoricalSourceDerivation.swift",
                "PrimeNativeNeuralGateHistoricalSourceDerivationContract.swift",
            ]
        )
        let source = try sourceURLs.map {
            try String(
                contentsOf: $0,
                encoding: .utf8
            )
        }.joined(separator: "\n")
        for forbidden in [
            "import PrimeCore",
            "Process(",
            "FileManager",
            "Data(contentsOf:",
            "String(contentsOf:",
            "#filePath",
            "getenv",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateSemanticRecordContracts",
            "PrimeNativeNeuralGateReplaySourceBinding",
            "PrimeNativeNeuralGateReplaySourceComposition",
            "PrimeNativeGitBlobTransport",
            "MLX",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                forbidden
            )
        }
        XCTAssertTrue(
            source.contains(
                "public static func derive("
            )
        )
        XCTAssertTrue(
            source.contains(
                "public static func deriveHistoricalFixture("
            )
        )
        XCTAssertEqual(
            source.components(
                separatedBy: "public static func derive("
            ).count - 1,
            1
        )
        XCTAssertFalse(source.contains("Decodable"))
    }

    private func pinnedCompanionRoot(
        from environment: [String: String]
    ) throws -> String? {
        let requirements = [
            Self.donorRequirementEnvironmentKey,
            Self.fixtureRequirementEnvironmentKey,
        ].compactMap { environment[$0] }
        for requirement in requirements
        where requirement != "1" {
            throw DonorGatePolicyError
                .invalidRequirementValue(requirement)
        }
        let root = environment[
            Self.donorRootEnvironmentKey
        ].flatMap {
            $0.isEmpty ? nil : $0
        }
        if requirements.contains("1"), root == nil {
            throw DonorGatePolicyError
                .requiredRootMissing
        }
        return root
    }

    private func historicalRewriteValidationContract(
        _ rewrites: [
            PrimeNativeNeuralGateHistoricalSourceRewrite
        ]
    )
        -> PrimeNativeNeuralGateHistoricalSourceDerivationContract
    {
        let donor = Data("alpha beta\n".utf8)
        return PrimeNativeNeuralGateHistoricalSourceDerivationContract(
            derivationID: "rewrite_validation_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 1,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount:
                        UInt64(donor.count),
                    expectedSHA256: digest(donor)
                ),
            ],
            joinedGroupByteCount:
                UInt64(donor.count),
            joinedGroupSHA256: digest(donor),
            rewrites: rewrites,
            transformedBodyByteCount:
                UInt64(donor.count),
            transformedBodySHA256:
                String(repeating: "0", count: 64),
            expectedOutputByteCount:
                UInt64(donor.count),
            expectedOutputSHA256:
                String(repeating: "0", count: 64)
        )
    }

    private func historicalSeparatorValidationContract(
        _ separator: String
    )
        -> PrimeNativeNeuralGateHistoricalSourceDerivationContract
    {
        PrimeNativeNeuralGateHistoricalSourceDerivationContract(
            derivationID: "separator_validation_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 1,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount: 2,
                    expectedSHA256:
                        digest(Data("a\n".utf8))
                ),
                .init(
                    ordinal: 2,
                    firstLine: 2,
                    lastLine: 2,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount: 2,
                    expectedSHA256:
                        digest(Data("b\n".utf8))
                ),
            ],
            betweenGroupUTF8Hex: [separator],
            joinedGroupByteCount: 5,
            joinedGroupSHA256:
                String(repeating: "0", count: 64),
            transformedBodyByteCount: 5,
            transformedBodySHA256:
                String(repeating: "0", count: 64),
            expectedOutputByteCount: 5,
            expectedOutputSHA256:
                String(repeating: "0", count: 64)
        )
    }

    private func coreRewriteValidationContract(
        _ rewrites: [PrimeNativeNeuralGateSourceRewrite]
    ) -> PrimeNativeNeuralGateSourceDerivationContract {
        let donor = Data("alpha beta\n".utf8)
        return PrimeNativeNeuralGateSourceDerivationContract(
            derivationID: "rewrite_validation_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 1,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount:
                        UInt64(donor.count),
                    expectedSHA256: digest(donor)
                ),
            ],
            joinedGroupByteCount:
                UInt64(donor.count),
            joinedGroupSHA256: digest(donor),
            rewrites: rewrites,
            transformedBodyByteCount:
                UInt64(donor.count),
            transformedBodySHA256:
                String(repeating: "0", count: 64),
            expectedOutputByteCount:
                UInt64(donor.count),
            expectedOutputSHA256:
                String(repeating: "0", count: 64)
        )
    }

    private func coreSeparatorValidationContract(
        _ separator: String
    ) -> PrimeNativeNeuralGateSourceDerivationContract {
        PrimeNativeNeuralGateSourceDerivationContract(
            derivationID: "separator_validation_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 1,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount: 2,
                    expectedSHA256:
                        digest(Data("a\n".utf8))
                ),
                .init(
                    ordinal: 2,
                    firstLine: 2,
                    lastLine: 2,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount: 2,
                    expectedSHA256:
                        digest(Data("b\n".utf8))
                ),
            ],
            betweenGroupUTF8Hex: [separator],
            joinedGroupByteCount: 5,
            joinedGroupSHA256:
                String(repeating: "0", count: 64),
            transformedBodyByteCount: 5,
            transformedBodySHA256:
                String(repeating: "0", count: 64),
            expectedOutputByteCount: 5,
            expectedOutputSHA256:
                String(repeating: "0", count: 64)
        )
    }

    private func deriveForTesting(
        _ donor: Data,
        contract:
            PrimeNativeNeuralGateHistoricalSourceDerivationContract
    ) throws -> PrimeNativeNeuralGateDerivedSourceMaterial {
        try PrimeNativeNeuralGateHistoricalSourceDerivation
            .deriveForTesting(
                donorBytes: donor,
                inputOrdinal: 1,
                expectedDonorByteCount:
                    UInt64(donor.count),
                expectedDonorSHA256: digest(donor),
                contract: contract
            )
    }

    private func assertExactContractMatch(
        _ actual:
            PrimeNativeNeuralGateHistoricalSourceDerivationContract,
        _ expected:
            PrimeNativeNeuralGateSourceDerivationContract,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            actual.derivationID,
            expected.derivationID,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.kind.rawValue,
            expected.kind.rawValue,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.requiredInputOrdinals,
            expected.requiredInputOrdinals,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.sourceEncodingPolicy,
            expected.sourceEncodingPolicy,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.lineGroups.map {
                "\($0.ordinal)|\($0.firstLine)|\($0.lastLine)|\($0.terminalLFPolicy.rawValue)|\($0.expectedByteCount)|\($0.expectedSHA256)"
            },
            expected.lineGroups.map {
                "\($0.ordinal)|\($0.firstLine)|\($0.lastLine)|\($0.terminalLFPolicy.rawValue)|\($0.expectedByteCount)|\($0.expectedSHA256)"
            },
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.betweenGroupUTF8Hex,
            expected.betweenGroupUTF8Hex,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.joinedGroupByteCount,
            expected.joinedGroupByteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.joinedGroupSHA256,
            expected.joinedGroupSHA256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.prefixUTF8,
            expected.prefixUTF8,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.prefixByteCount,
            expected.prefixByteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.prefixSHA256,
            expected.prefixSHA256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.suffixUTF8,
            expected.suffixUTF8,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.suffixByteCount,
            expected.suffixByteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.suffixSHA256,
            expected.suffixSHA256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.rewrites.map {
                "\($0.ordinal)|\($0.rewriteID)|\($0.expectedOccurrenceCount)|\($0.sourceByteCount)|\($0.sourceSHA256)|\($0.replacementByteCount)|\($0.replacementSHA256)|\($0.sourceUTF8)|\($0.replacementUTF8)"
            },
            expected.rewrites.map {
                "\($0.ordinal)|\($0.rewriteID)|\($0.expectedOccurrenceCount)|\($0.sourceByteCount)|\($0.sourceSHA256)|\($0.replacementByteCount)|\($0.replacementSHA256)|\($0.sourceUTF8)|\($0.replacementUTF8)"
            },
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.transformedBodyByteCount,
            expected.transformedBodyByteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.transformedBodySHA256,
            expected.transformedBodySHA256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.expectedOutputByteCount,
            expected.expectedOutputByteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.expectedOutputSHA256,
            expected.expectedOutputSHA256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            actual.runtimeManifestMaySupplyExpectedValues,
            expected.runtimeManifestMaySupplyExpectedValues,
            file: file,
            line: line
        )
    }

    private func assertHistoricalMutationSourceMatchesProjection(
        _ gate: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let source = try XCTUnwrap(
            String(data: gate, encoding: .utf8),
            file: file,
            line: line
        )
        let lines = source.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map(String.init)
        var declarationIdentifiers: [String] = []
        var rawValueByIdentifier: [String: String] = [:]
        for oneBasedLine in 258 ... 328 {
            let declaration =
                lines[oneBasedLine - 1]
                .trimmingCharacters(in: .whitespaces)
            guard declaration.hasPrefix("case ") else {
                continue
            }
            let remainder = declaration.dropFirst(5)
            let identifier = String(
                remainder.prefix {
                    $0.isLetter
                        || $0.isNumber
                        || $0 == "_"
                }
            )
            var rawValue = identifier
            if let quoted = quotedValue(in: declaration) {
                rawValue = quoted
            } else if declaration.hasSuffix("=") {
                rawValue = try XCTUnwrap(
                    quotedValue(in: lines[oneBasedLine]),
                    file: file,
                    line: line
                )
            }
            XCTAssertNil(
                rawValueByIdentifier[identifier],
                identifier,
                file: file,
                line: line
            )
            declarationIdentifiers.append(identifier)
            rawValueByIdentifier[identifier] = rawValue
        }

        let projectionIDs =
            PrimeNativeNeuralGateContractProjection
            .frozenV1.mutationCatalog.map(\.mutationID)
        XCTAssertEqual(
            declarationIdentifiers.compactMap {
                rawValueByIdentifier[$0]
            },
            projectionIDs,
            file: file,
            line: line
        )
        XCTAssertEqual(
            declarationIdentifiers.count,
            46,
            file: file,
            line: line
        )

        var switchIdentifiers: [String] = []
        for oneBasedLine in 7_493 ... 8_110 {
            let statement =
                lines[oneBasedLine - 1]
                .trimmingCharacters(in: .whitespaces)
            guard statement.hasPrefix("case ."),
                  let colon = statement.firstIndex(of: ":")
            else {
                continue
            }
            switchIdentifiers.append(
                String(
                    statement[
                        statement.index(
                            statement.startIndex,
                            offsetBy: 6
                        ) ..< colon
                    ]
                )
            )
        }
        XCTAssertEqual(
            switchIdentifiers.count,
            46,
            file: file,
            line: line
        )
        XCTAssertEqual(
            Set(switchIdentifiers).count,
            46,
            file: file,
            line: line
        )
        let switchRawValues = try switchIdentifiers.map {
            try XCTUnwrap(
                rawValueByIdentifier[$0],
                $0,
                file: file,
                line: line
            )
        }
        XCTAssertEqual(
            Set(switchRawValues),
            Set(projectionIDs),
            file: file,
            line: line
        )
    }

    private func quotedValue(in value: String) -> String? {
        guard let first = value.firstIndex(of: "\""),
              let last = value.lastIndex(of: "\""),
              first < last
        else {
            return nil
        }
        return String(
            value[value.index(after: first) ..< last]
        )
    }

    private func digest(_ data: Data) -> String {
        PrimeNativeNeuralGateInvariantCodec.sha256(data)
    }

    private func startIndex(
        ofOneBasedLine targetLine: Int,
        in data: Data
    ) -> Data.Index? {
        guard targetLine > 0 else {
            return nil
        }
        var line = 1
        for index in data.indices {
            if line == targetLine {
                return index
            }
            if data[index] == 0x0a {
                line += 1
            }
        }
        return nil
    }
}

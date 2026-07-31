import Foundation

public enum PrimeNativeNeuralGateFixtureReplayPlanError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidPlan(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidPlan(detail):
            "native neural-gate fixture replay plan is invalid: \(detail)"
        }
    }
}

public enum PrimeNativeNeuralGateFixtureInputRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case nativeLanguageGate =
        "native_language_gate"
    case nativeByteTokenizerAuthority =
        "native_byte_tokenizer_authority"
    case nativeTextCorpusAuthority =
        "native_text_corpus_authority"
    case canaryReportAuthority =
        "canary_report_authority"
    case runConfigurationAuthority =
        "run_configuration_authority"
    case artifactPathSafetyAuthority =
        "artifact_path_safety_authority"
    case profileTrialFailureAuthority =
        "profile_trial_failure_authority"
    case scaleRecommendationLineage =
        "scale_recommendation_lineage"
    case verdictCarrier = "verdict_carrier"
    case behavioralRegressionFixture =
        "behavioral_regression_fixture"
    case neuralKitPackageLock =
        "neural_kit_package_lock"
}

public enum PrimeNativeNeuralGateFixtureTransplantPolicy:
    String,
    Codable,
    Equatable,
    Sendable
{
    case reuseByteExactCorpusReplayMechanics =
        "reuse_byte_exact_corpus_replay_mechanics"
    case generatedModuleBoundaryOnly =
        "generated_module_boundary_only"
    case generatedGateObservationSeam =
        "generated_gate_observation_seam"
    case boundedVerdictCarrierSlice =
        "bounded_verdict_carrier_slice"
    case sourceFaithfulPackageBoundForensicMaterializer =
        "source_faithful_package_bound_forensic_materializer"
    case immutableArtifact = "immutable_artifact"
}

public enum PrimeNativeNeuralGateSourceDerivationKind:
    String,
    Codable,
    Equatable,
    Sendable
{
    case byteExactDonor =
        "byte_exact_donor"
    case frozenLineGroupsAndRewrites =
        "frozen_line_groups_and_rewrites"
}

public enum PrimeNativeNeuralGateLineGroupLFPolicy:
    String,
    Codable,
    Equatable,
    Sendable
{
    case preserveTerminalLF =
        "preserve_terminal_lf"
    case stripOneTerminalLF =
        "strip_one_terminal_lf"
}

public struct PrimeNativeNeuralGateSourceLineGroup:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let firstLine: Int
    public let lastLine: Int
    public let terminalLFPolicy:
        PrimeNativeNeuralGateLineGroupLFPolicy
    public let expectedByteCount: UInt64
    public let expectedSHA256: String

    public init(
        ordinal: Int,
        firstLine: Int,
        lastLine: Int,
        terminalLFPolicy:
            PrimeNativeNeuralGateLineGroupLFPolicy,
        expectedByteCount: UInt64,
        expectedSHA256: String
    ) {
        self.ordinal = ordinal
        self.firstLine = firstLine
        self.lastLine = lastLine
        self.terminalLFPolicy =
            terminalLFPolicy
        self.expectedByteCount =
            expectedByteCount
        self.expectedSHA256 = expectedSHA256
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case firstLine = "first_line"
        case lastLine = "last_line"
        case terminalLFPolicy =
            "terminal_lf_policy"
        case expectedByteCount =
            "expected_byte_count"
        case expectedSHA256 =
            "expected_sha256"
    }
}

public struct PrimeNativeNeuralGateSourceRewrite:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let rewriteID: String
    public let expectedOccurrenceCount: Int
    public let sourceUTF8: String
    public let sourceByteCount: UInt64
    public let sourceSHA256: String
    public let replacementUTF8: String
    public let replacementByteCount: UInt64
    public let replacementSHA256: String

    public init(
        ordinal: Int,
        rewriteID: String,
        sourceUTF8: String,
        sourceByteCount: UInt64,
        sourceSHA256: String,
        replacementUTF8: String,
        replacementByteCount: UInt64,
        replacementSHA256: String
    ) {
        self.ordinal = ordinal
        self.rewriteID = rewriteID
        expectedOccurrenceCount = 1
        self.sourceUTF8 = sourceUTF8
        self.sourceByteCount = sourceByteCount
        self.sourceSHA256 = sourceSHA256
        self.replacementUTF8 = replacementUTF8
        self.replacementByteCount =
            replacementByteCount
        self.replacementSHA256 =
            replacementSHA256
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case rewriteID = "rewrite_id"
        case expectedOccurrenceCount =
            "expected_occurrence_count"
        case sourceUTF8 = "source_utf8"
        case sourceByteCount =
            "source_byte_count"
        case sourceSHA256 = "source_sha256"
        case replacementUTF8 =
            "replacement_utf8"
        case replacementByteCount =
            "replacement_byte_count"
        case replacementSHA256 =
            "replacement_sha256"
    }
}

public struct PrimeNativeNeuralGateSourceDerivationContract:
    Codable,
    Equatable,
    Sendable
{
    public let derivationID: String
    public let kind:
        PrimeNativeNeuralGateSourceDerivationKind
    public let requiredInputOrdinals: [Int]
    public let sourceEncodingPolicy: String
    public let lineGroups:
        [PrimeNativeNeuralGateSourceLineGroup]
    public let betweenGroupUTF8Hex:
        [String]
    public let joinedGroupByteCount: UInt64?
    public let joinedGroupSHA256: String?
    public let prefixUTF8: String
    public let prefixByteCount: UInt64
    public let prefixSHA256: String
    public let suffixUTF8: String
    public let suffixByteCount: UInt64
    public let suffixSHA256: String
    public let rewrites:
        [PrimeNativeNeuralGateSourceRewrite]
    public let transformedBodyByteCount:
        UInt64?
    public let transformedBodySHA256: String?
    public let expectedOutputByteCount: UInt64
    public let expectedOutputSHA256: String
    public let runtimeManifestMaySupplyExpectedValues:
        Bool

    public init(
        derivationID: String,
        kind:
            PrimeNativeNeuralGateSourceDerivationKind,
        requiredInputOrdinals: [Int],
        lineGroups:
            [PrimeNativeNeuralGateSourceLineGroup] = [],
        betweenGroupUTF8Hex: [String] = [],
        joinedGroupByteCount: UInt64? = nil,
        joinedGroupSHA256: String? = nil,
        prefixUTF8: String = "",
        prefixByteCount: UInt64 = 0,
        prefixSHA256: String =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        suffixUTF8: String = "",
        suffixByteCount: UInt64 = 0,
        suffixSHA256: String =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        rewrites:
            [PrimeNativeNeuralGateSourceRewrite] = [],
        transformedBodyByteCount: UInt64? = nil,
        transformedBodySHA256: String? = nil,
        expectedOutputByteCount: UInt64,
        expectedOutputSHA256: String
    ) {
        self.derivationID = derivationID
        self.kind = kind
        self.requiredInputOrdinals =
            requiredInputOrdinals
        sourceEncodingPolicy =
            "utf8_no_bom_lf_only_final_lf_required_v1"
        self.lineGroups = lineGroups
        self.betweenGroupUTF8Hex =
            betweenGroupUTF8Hex
        self.joinedGroupByteCount =
            joinedGroupByteCount
        self.joinedGroupSHA256 =
            joinedGroupSHA256
        self.prefixUTF8 = prefixUTF8
        self.prefixByteCount = prefixByteCount
        self.prefixSHA256 = prefixSHA256
        self.suffixUTF8 = suffixUTF8
        self.suffixByteCount = suffixByteCount
        self.suffixSHA256 = suffixSHA256
        self.rewrites = rewrites
        self.transformedBodyByteCount =
            transformedBodyByteCount
        self.transformedBodySHA256 =
            transformedBodySHA256
        self.expectedOutputByteCount =
            expectedOutputByteCount
        self.expectedOutputSHA256 =
            expectedOutputSHA256
        runtimeManifestMaySupplyExpectedValues =
            false
    }

    public static func byteExact(
        inputOrdinal: Int,
        byteCount: UInt64,
        sha256: String
    ) -> Self {
        Self(
            derivationID:
                "byte_exact_donor_sha256_v1",
            kind: .byteExactDonor,
            requiredInputOrdinals: [
                inputOrdinal,
            ],
            expectedOutputByteCount: byteCount,
            expectedOutputSHA256: sha256
        )
    }

    public func validate(
        donorByteCount: UInt64,
        donorSHA256: String
    ) throws {
        let emptySHA256 =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let prefixData = Data(prefixUTF8.utf8)
        let suffixData = Data(suffixUTF8.utf8)
        let groupsValid =
            lineGroups.enumerated().allSatisfy {
                index, group in
                group.ordinal == index + 1
                    && group.firstLine > 0
                    && group.lastLine
                        >= group.firstLine
                    && group.expectedByteCount > 0
                    && Self.isSHA256(
                        group.expectedSHA256
                    )
            }
        let groupsStrictlyOrdered =
            zip(
                lineGroups,
                lineGroups.dropFirst()
            ).allSatisfy {
                $0.lastLine < $1.firstLine
            }
        let rewritesValid =
            rewrites.enumerated().allSatisfy {
                index, rewrite in
                let source =
                    Data(rewrite.sourceUTF8.utf8)
                let replacement =
                    Data(
                        rewrite
                            .replacementUTF8.utf8
                    )
                return rewrite.ordinal
                        == index + 1
                    && rewrite
                        .expectedOccurrenceCount
                        == 1
                    && source.count
                        == rewrite.sourceByteCount
                    && PrimeSHA256.hexDigest(
                        of: source
                    ) == rewrite.sourceSHA256
                    && replacement.count
                        == rewrite
                        .replacementByteCount
                    && PrimeSHA256.hexDigest(
                        of: replacement
                    ) == rewrite
                        .replacementSHA256
            }
        let separatorsValid =
            betweenGroupUTF8Hex.allSatisfy {
                $0.utf8.count.isMultiple(of: 2)
                    && $0.utf8.allSatisfy {
                        ($0 >= 48 && $0 <= 57)
                            || (
                                $0 >= 97
                                    && $0 <= 102
                            )
                    }
            }
        var computedJoinedGroupByteCount:
            UInt64? = 0
        for group in lineGroups {
            guard let partial =
                    computedJoinedGroupByteCount
            else {
                break
            }
            let addition =
                partial.addingReportingOverflow(
                    group.expectedByteCount
                )
            computedJoinedGroupByteCount =
                addition.overflow
                ? nil
                : addition.partialValue
        }
        for separator in betweenGroupUTF8Hex {
            guard let partial =
                    computedJoinedGroupByteCount
            else {
                break
            }
            let addition =
                partial.addingReportingOverflow(
                    UInt64(
                        separator.utf8.count / 2
                    )
                )
            computedJoinedGroupByteCount =
                addition.overflow
                ? nil
                : addition.partialValue
        }
        var computedTransformedBodyByteCount =
            computedJoinedGroupByteCount
        for rewrite in rewrites {
            guard let partial =
                    computedTransformedBodyByteCount
            else {
                break
            }
            let subtraction =
                partial.subtractingReportingOverflow(
                    rewrite.sourceByteCount
                )
            guard !subtraction.overflow else {
                computedTransformedBodyByteCount =
                    nil
                break
            }
            let addition =
                subtraction.partialValue
                .addingReportingOverflow(
                    rewrite.replacementByteCount
                )
            computedTransformedBodyByteCount =
                addition.overflow
                ? nil
                : addition.partialValue
        }
        let computedOutputByteCount: UInt64? = {
            guard let body =
                    computedTransformedBodyByteCount
            else {
                return nil
            }
            let prefix =
                prefixByteCount
                .addingReportingOverflow(body)
            guard !prefix.overflow else {
                return nil
            }
            let suffix =
                prefix.partialValue
                .addingReportingOverflow(
                    suffixByteCount
                )
            return suffix.overflow
                ? nil
                : suffix.partialValue
        }()
        let commonValid =
            !derivationID.isEmpty
                && sourceEncodingPolicy
                    == "utf8_no_bom_lf_only_final_lf_required_v1"
                && !requiredInputOrdinals.isEmpty
                && Set(requiredInputOrdinals).count
                    == requiredInputOrdinals.count
                && requiredInputOrdinals
                    .allSatisfy { $0 > 0 }
                && prefixData.count
                    == prefixByteCount
                && PrimeSHA256.hexDigest(
                    of: prefixData
                ) == prefixSHA256
                && suffixData.count
                    == suffixByteCount
                && PrimeSHA256.hexDigest(
                    of: suffixData
                ) == suffixSHA256
                && Self.isSHA256(
                    expectedOutputSHA256
                )
                && expectedOutputByteCount > 0
                && !runtimeManifestMaySupplyExpectedValues
                && groupsValid
                && groupsStrictlyOrdered
                && rewritesValid
                && separatorsValid
        let kindValid: Bool
        switch kind {
        case .byteExactDonor:
            kindValid =
                requiredInputOrdinals.count == 1
                    && lineGroups.isEmpty
                    && betweenGroupUTF8Hex.isEmpty
                    && joinedGroupByteCount == nil
                    && joinedGroupSHA256 == nil
                    && prefixUTF8.isEmpty
                    && prefixSHA256 == emptySHA256
                    && suffixUTF8.isEmpty
                    && suffixSHA256 == emptySHA256
                    && rewrites.isEmpty
                    && transformedBodyByteCount
                        == nil
                    && transformedBodySHA256 == nil
                    && expectedOutputByteCount
                        == donorByteCount
                    && expectedOutputSHA256
                        == donorSHA256
        case .frozenLineGroupsAndRewrites:
            kindValid =
                !lineGroups.isEmpty
                    && betweenGroupUTF8Hex.count
                        == lineGroups.count - 1
                    && joinedGroupByteCount
                        == computedJoinedGroupByteCount
                    && joinedGroupSHA256
                        .map(Self.isSHA256) == true
                    && transformedBodyByteCount
                        == computedTransformedBodyByteCount
                    && transformedBodySHA256
                        .map(Self.isSHA256) == true
                    && expectedOutputByteCount
                        == computedOutputByteCount
        }
        guard commonValid, kindValid else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "source_derivation"
                )
        }
    }

    private static func isSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case derivationID = "derivation_id"
        case kind
        case requiredInputOrdinals =
            "required_input_ordinals"
        case sourceEncodingPolicy =
            "source_encoding_policy"
        case lineGroups = "line_groups"
        case betweenGroupUTF8Hex =
            "between_group_utf8_hex"
        case joinedGroupByteCount =
            "joined_group_byte_count"
        case joinedGroupSHA256 =
            "joined_group_sha256"
        case prefixUTF8 = "prefix_utf8"
        case prefixByteCount =
            "prefix_byte_count"
        case prefixSHA256 = "prefix_sha256"
        case suffixUTF8 = "suffix_utf8"
        case suffixByteCount =
            "suffix_byte_count"
        case suffixSHA256 = "suffix_sha256"
        case rewrites
        case transformedBodyByteCount =
            "transformed_body_byte_count"
        case transformedBodySHA256 =
            "transformed_body_sha256"
        case expectedOutputByteCount =
            "expected_output_byte_count"
        case expectedOutputSHA256 =
            "expected_output_sha256"
        case runtimeManifestMaySupplyExpectedValues =
            "runtime_manifest_may_supply_expected_values"
    }
}

public struct PrimeNativeNeuralGateAdaptationProofEntry:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let role:
        PrimeNativeNeuralGateFixtureInputRole
    public let donorSHA256: String
    public let transplantPolicy:
        PrimeNativeNeuralGateFixtureTransplantPolicy
    public let primeDestinationRelativePath:
        String?
    public let proofMechanism: String
    public let derivation:
        PrimeNativeNeuralGateSourceDerivationContract

    public init(
        ordinal: Int,
        role:
            PrimeNativeNeuralGateFixtureInputRole,
        donorSHA256: String,
        transplantPolicy:
            PrimeNativeNeuralGateFixtureTransplantPolicy,
        primeDestinationRelativePath: String?,
        proofMechanism: String,
        derivation:
            PrimeNativeNeuralGateSourceDerivationContract
    ) {
        self.ordinal = ordinal
        self.role = role
        self.donorSHA256 = donorSHA256
        self.transplantPolicy = transplantPolicy
        self.primeDestinationRelativePath =
            primeDestinationRelativePath
        self.proofMechanism = proofMechanism
        self.derivation = derivation
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case role
        case donorSHA256 = "donor_sha256"
        case transplantPolicy =
            "transplant_policy"
        case primeDestinationRelativePath =
            "prime_destination_relative_path"
        case proofMechanism =
            "proof_mechanism"
        case derivation
    }
}

public struct PrimeNativeNeuralGateAdaptationProofContract:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let entries:
        [PrimeNativeNeuralGateAdaptationProofEntry]
    public let proofManifestRelativePath:
        String
    public let lexicalSourceDiffManifestRequired:
        Bool
    public let compiledTargetSourceClosureRequired:
        Bool
    public let probeAndVerifierRecomputeRequired:
        Bool
    public let candidateDeclaredExpectedValuesPermitted:
        Bool
    public let behavioralReplayMayReplaceSourceProof:
        Bool
    public let independentScientificOracleClaimed:
        Bool
    public let historicalFixtureInheritedTryBangCount:
        Int
    public let historicalFixtureContainsAdditionalTrapSites:
        Bool
    public let historicalFixtureWhollyFailClosed:
        Bool
    public let historicalFixtureFreshProcessContainmentRequired:
        Bool
    public let historicalFixtureMaximumWallSeconds:
        UInt64
    public let historicalFixtureMaximumStandardOutputBytes:
        UInt64
    public let historicalFixtureMaximumStandardErrorBytes:
        UInt64
    public let historicalFixtureChildEnvironmentPolicy:
        String
    public let historicalFixtureChildStandardInputPolicy:
        String
    public let historicalFixtureAbnormalTerminationPolicy:
        String

    public static let frozenV2: Self = {
        let mechanics =
            "Sources/PrimeNativeNeuralGateReplayMechanics/"
        let runtime =
            "Sources/ErgenticsPrimeRuntime/"
        let historicalWorker =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/"
        func entry(
            _ ordinal: Int,
            _ role:
                PrimeNativeNeuralGateFixtureInputRole,
            _ donorByteCount: UInt64,
            _ donorSHA256: String,
            _ policy:
                PrimeNativeNeuralGateFixtureTransplantPolicy,
            _ destination: String?,
            _ mechanism: String,
            derivation:
                PrimeNativeNeuralGateSourceDerivationContract?
                = nil
        ) -> PrimeNativeNeuralGateAdaptationProofEntry {
            PrimeNativeNeuralGateAdaptationProofEntry(
                ordinal: ordinal,
                role: role,
                donorSHA256: donorSHA256,
                transplantPolicy: policy,
                primeDestinationRelativePath:
                    destination,
                proofMechanism: mechanism,
                derivation:
                    derivation
                        ?? .byteExact(
                            inputOrdinal: ordinal,
                            byteCount: donorByteCount,
                            sha256: donorSHA256
                        )
            )
        }
        let carrierDerivation =
            PrimeNativeNeuralGateSourceDerivationContract(
                derivationID:
                    "exact_lf_line_slice_verdict_carrier_v1",
                kind:
                    .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [9],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 1,
                        lastLine: 1,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 18,
                        expectedSHA256:
                            "dda9b75f64b106eb544de201f599122d75abc483c5b156bba6c05c0f956dbc3c"
                    ),
                    .init(
                        ordinal: 2,
                        firstLine: 4,
                        lastLine: 66,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 2_376,
                        expectedSHA256:
                            "83c3d54c32d2c87f1841be04dd552700dedf9d34d6a90983b899439129dc7a6a"
                    ),
                    .init(
                        ordinal: 3,
                        firstLine: 105,
                        lastLine: 105,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 2,
                        expectedSHA256:
                            "412ca345ccf75bf9c0806bce695be8de808b79984251a7a54d202cf6101dd451"
                    ),
                ],
                betweenGroupUTF8Hex: [
                    "0a",
                    "",
                ],
                joinedGroupByteCount: 2_397,
                joinedGroupSHA256:
                    "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f",
                transformedBodyByteCount: 2_397,
                transformedBodySHA256:
                    "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f",
                expectedOutputByteCount: 2_397,
                expectedOutputSHA256:
                    "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f"
            )
        let fixturePrefix =
            "import CryptoKit\n"
            + "import ErgenticsPrimeRuntime\n"
            + "import PrimeNativeNeuralGateReplayMechanics\n"
            + "import Foundation\n\n"
            + "public enum EngineProposesNativeLanguageVerifyAbstainFixture {\n"
            + "    public enum MaterializationError: Error, Equatable {\n"
            + "        case invalidPackageResolvedArtifact\n"
            + "    }\n\n"
        let fixtureRewrites = [
            PrimeNativeNeuralGateSourceRewrite(
                ordinal: 1,
                rewriteID:
                    "fixture_visibility_and_public_types",
                sourceUTF8:
                    "    private struct Fixture {\n"
                    + "        let materials: Gate.Materials\n"
                    + "        let reports: [Authority.Report]\n"
                    + "        let constructionDurationsSeconds: [String: Double]\n"
                    + "    }",
                sourceByteCount: 171,
                sourceSHA256:
                    "ab4a7961812ded31681e23120aad7c34162fd5d1c4f7651574e2fe42ffade861",
                replacementUTF8:
                    "    public struct Fixture {\n"
                    + "        public let materials:\n"
                    + "            PrimeNeuralNativeLanguageVerifyAbstainGate.Materials\n"
                    + "        public let reports:\n"
                    + "            [ErgenticsNativeLanguageCanary.Report]\n"
                    + "        public let constructionDurationsSeconds: [String: Double]\n"
                    + "    }",
                replacementByteCount: 273,
                replacementSHA256:
                    "ed550504d0a9a576ebb404170eb680670ed824bee7163dc195d7acec1ba418eb"
            ),
            PrimeNativeNeuralGateSourceRewrite(
                ordinal: 2,
                rewriteID:
                    "materializer_throwing_package_url_signature",
                sourceUTF8:
                    "    private static func makeFixture() -> Fixture {",
                sourceByteCount: 50,
                sourceSHA256:
                    "89ad58011564557481fde9263eccbbf62f8a26912a8df864bb0a5fe748ccf6bf",
                replacementUTF8:
                    "    public static func materialize(\n"
                    + "        packageResolvedURL: URL\n"
                    + "    ) throws -> Fixture {",
                replacementByteCount: 93,
                replacementSHA256:
                    "3586d9bf9c8e231b5dbfa783bfd5c397b634a331dc85d44ff2452e3b77a21d9a"
            ),
            PrimeNativeNeuralGateSourceRewrite(
                ordinal: 3,
                rewriteID:
                    "remove_file_path_and_accept_explicit_package_url",
                sourceUTF8:
                    "        let packageResolvedURL = URL(\n"
                    + "            fileURLWithPath: #filePath\n"
                    + "        ).deletingLastPathComponent()\n"
                    + "            .deletingLastPathComponent()\n"
                    + "            .deletingLastPathComponent()\n"
                    + "            .appendingPathComponent(\n"
                    + "                Gate.packageResolvedArtifactFileName\n"
                    + "            )\n"
                    + "        let packageResolvedData =\n"
                    + "            try! Data(contentsOf: packageResolvedURL)\n",
                sourceByteCount: 389,
                sourceSHA256:
                    "27283601f132f38d05db2e1f5f32a9179da2253290204807d9a509f38a2c70df",
                replacementUTF8:
                    "        let packageResolvedData =\n"
                    + "            try Data(contentsOf: packageResolvedURL)\n",
                replacementByteCount: 87,
                replacementSHA256:
                    "4ddef6e0fa189b084d27503857e101353b94dde6530309842157de41b8f48782"
            ),
            PrimeNativeNeuralGateSourceRewrite(
                ordinal: 4,
                rewriteID:
                    "require_pinned_package_lock_or_throw",
                sourceUTF8:
                    "        let packageResolvedBinding =\n"
                    + "            Gate.observePackageResolvedArtifact(\n"
                    + "                packageResolvedURL,\n"
                    + "                expectedSHA256: packageResolvedSHA256\n"
                    + "            )!\n",
                sourceByteCount: 191,
                sourceSHA256:
                    "6b6171cb20f5e4885e5825aa81a5b1a26928565ac093cefa8a5b5b6d9af6c505",
                replacementUTF8:
                    "        guard packageResolvedSHA256\n"
                    + "            == \"cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3\",\n"
                    + "              let packageResolvedBinding =\n"
                    + "                Gate.observePackageResolvedArtifact(\n"
                    + "                    packageResolvedURL,\n"
                    + "                    expectedSHA256: packageResolvedSHA256\n"
                    + "                )\n"
                    + "        else {\n"
                    + "            throw MaterializationError\n"
                    + "                .invalidPackageResolvedArtifact\n"
                    + "        }\n",
                replacementByteCount: 443,
                replacementSHA256:
                    "3212cbda67da14efd499bfa898a7d268c1fb71680b4b6e0363549cbf4e708e9d"
            ),
        ]
        let fixtureDerivation =
            PrimeNativeNeuralGateSourceDerivationContract(
                derivationID:
                    "exact_lf_forensic_fixture_five_group_four_rewrite_v1",
                kind:
                    .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [
                    10,
                    11,
                ],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 9,
                        lastLine: 341,
                        terminalLFPolicy:
                            .stripOneTerminalLF,
                        expectedByteCount: 12_955,
                        expectedSHA256:
                            "dd1f5deda2694ac74c282c7b8a5ec9963709a2aadbdc9cabe91f5664ad5a33fc"
                    ),
                    .init(
                        ordinal: 2,
                        firstLine: 346,
                        lastLine: 587,
                        terminalLFPolicy:
                            .stripOneTerminalLF,
                        expectedByteCount: 8_696,
                        expectedSHA256:
                            "b3ad39ad1e02e7fb44aed6cda1dd18f4230c2cc49d05c584166ffe9b806d1538"
                    ),
                    .init(
                        ordinal: 3,
                        firstLine: 2_651,
                        lastLine: 3_529,
                        terminalLFPolicy:
                            .stripOneTerminalLF,
                        expectedByteCount: 39_497,
                        expectedSHA256:
                            "dfde0892c44dfb97f1850675b24d1096cd7149c8f3f3856642d1fac191f57d77"
                    ),
                    .init(
                        ordinal: 4,
                        firstLine: 3_540,
                        lastLine: 4_193,
                        terminalLFPolicy:
                            .stripOneTerminalLF,
                        expectedByteCount: 25_949,
                        expectedSHA256:
                            "2eb9890d91da04ac05d6f70da1ea9776ec4826723160d2dca122adec966a5cde"
                    ),
                    .init(
                        ordinal: 5,
                        firstLine: 4_334,
                        lastLine: 4_357,
                        terminalLFPolicy:
                            .stripOneTerminalLF,
                        expectedByteCount: 658,
                        expectedSHA256:
                            "c184fb53f7e6d9c8dd14e4531e4e082f69cc1500e08889e32ae26e74f21475e1"
                    ),
                ],
                betweenGroupUTF8Hex:
                    Array(
                        repeating: "0a0a",
                        count: 4
                    ),
                joinedGroupByteCount: 87_763,
                joinedGroupSHA256:
                    "524864949a47434c14ac990c03e90a6eb6054e56bcdc58c2ab018aab1e8e59a7",
                prefixUTF8: fixturePrefix,
                prefixByteCount: 280,
                prefixSHA256:
                    "1690de7194caa62ab8d012d3b5de14e067e0d6c090dd5b2cef1543b0dc3d9b85",
                suffixUTF8: "\n}\n",
                suffixByteCount: 3,
                suffixSHA256:
                    "804f89fc0ec98c9824183e795d3edd19e930f7bc471f9012aa3d503be2f8974b",
                rewrites: fixtureRewrites,
                transformedBodyByteCount: 87_858,
                transformedBodySHA256:
                    "11a335d766a4078c4ddcce78e67685c4a2da86b5f85859fcf59431342966f070",
                expectedOutputByteCount: 88_141,
                expectedOutputSHA256:
                    "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
            )
        return Self(
            contractID:
                "prime_source_pinned_neural_gate_adaptation_proof_v2",
            entries: [
                entry(
                    1,
                    .nativeLanguageGate,
                    368_918,
                    "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
                    .generatedGateObservationSeam,
                    mechanics +
                        "PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                    "byte_exact_donor_source_with_separate_prime_observation_seam_v1"
                ),
                entry(
                    2,
                    .nativeByteTokenizerAuthority,
                    21_320,
                    "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721",
                    .reuseByteExactCorpusReplayMechanics,
                    runtime +
                        "PrimeNativeByteTokenizer.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    3,
                    .nativeTextCorpusAuthority,
                    177_032,
                    "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210",
                    .reuseByteExactCorpusReplayMechanics,
                    runtime +
                        "ErgenticsPrimeNativeTextCorpus.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    4,
                    .canaryReportAuthority,
                    216_815,
                    "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f",
                    .generatedModuleBoundaryOnly,
                    runtime +
                        "ErgenticsNativeLanguageCanary.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    5,
                    .runConfigurationAuthority,
                    18_069,
                    "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b",
                    .generatedModuleBoundaryOnly,
                    runtime +
                        "ErgenticsNativeLanguageRunConfiguration.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    6,
                    .artifactPathSafetyAuthority,
                    51_514,
                    "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c",
                    .generatedModuleBoundaryOnly,
                    runtime +
                        "ErgenticsNativeLanguageArtifactPathSafety.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    7,
                    .profileTrialFailureAuthority,
                    16_567,
                    "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463",
                    .generatedModuleBoundaryOnly,
                    runtime +
                        "ErgenticsNativeLanguageProfileTrialFailure.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    8,
                    .scaleRecommendationLineage,
                    190_002,
                    "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea",
                    .generatedModuleBoundaryOnly,
                    runtime +
                        "ErgenticsNativeScaleEngineRecommend.swift",
                    "byte_exact_donor_in_prime_owned_local_ergentics_prime_runtime_target_v1"
                ),
                entry(
                    9,
                    .verdictCarrier,
                    4_659,
                    "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
                    .boundedVerdictCarrierSlice,
                    mechanics +
                        "PrimeNeuralVerifyAbstainGateCarrier.swift",
                    "exact_utf8_declaration_slice_by_frozen_witness_outcome_verdict_symbol_set_v1",
                    derivation: carrierDerivation
                ),
                entry(
                    10,
                    .behavioralRegressionFixture,
                    165_692,
                    "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c",
                    .sourceFaithfulPackageBoundForensicMaterializer,
                    historicalWorker +
                        "EngineProposesNativeLanguageVerifyAbstainFixture.swift",
                    "source_faithful_exact_line_group_and_four_rewrite_forensic_materializer_v1",
                    derivation: fixtureDerivation
                ),
                entry(
                    11,
                    .neuralKitPackageLock,
                    1_949,
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
                    .immutableArtifact,
                    nil,
                    "byte_exact_immutable_package_lock_copy_only_v1"
                ),
            ],
            proofManifestRelativePath:
                "neural-gate-replay/source/adaptation-proof.v2.json",
            lexicalSourceDiffManifestRequired:
                true,
            compiledTargetSourceClosureRequired:
                true,
            probeAndVerifierRecomputeRequired:
                true,
            candidateDeclaredExpectedValuesPermitted:
                false,
            behavioralReplayMayReplaceSourceProof:
                false,
            independentScientificOracleClaimed:
                false,
            historicalFixtureInheritedTryBangCount:
                11,
            historicalFixtureContainsAdditionalTrapSites:
                true,
            historicalFixtureWhollyFailClosed:
                false,
            historicalFixtureFreshProcessContainmentRequired:
                true,
            historicalFixtureMaximumWallSeconds:
                600,
            historicalFixtureMaximumStandardOutputBytes:
                1_048_576,
            historicalFixtureMaximumStandardErrorBytes:
                1_048_576,
            historicalFixtureChildEnvironmentPolicy:
                "empty_environment_v1",
            historicalFixtureChildStandardInputPolicy:
                "eof_v1",
            historicalFixtureAbnormalTerminationPolicy:
                "timeout_output_overflow_signal_or_nonzero_exit_after_proven_containment_and_exact_reap_forces_stage_b_abstain_uncontained_child_or_drain_fail_stops_and_no_terminal_pass_receipt_v2"
        )
    }()

    public func validate(
        against inputs:
            [PrimeNativeNeuralGateFixtureInputPin]
    ) throws {
        guard entries.count == inputs.count else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("adaptation_proof")
        }
        try zip(entries, inputs).forEach {
            proof, input in
            try proof.derivation.validate(
                donorByteCount: input.byteCount,
                donorSHA256: input.sha256
            )
        }
        guard self == .frozenV2,
              entries.map(\.ordinal)
                == Array(1 ... 11),
              entries.map(\.role)
                == PrimeNativeNeuralGateFixtureInputRole
                .allCases,
              zip(entries, inputs).allSatisfy({
                  proof, input in
                  proof.ordinal == input.ordinal
                      && proof.role == input.role
                      && proof.donorSHA256
                          == input.sha256
                      && proof.transplantPolicy
                          == input.transplantPolicy
                      && proof.derivation
                      .requiredInputOrdinals
                          == (
                              proof.ordinal == 10
                                  ? [10, 11]
                                  : [proof.ordinal]
                          )
              }),
              entries.dropLast().allSatisfy({
                  $0.primeDestinationRelativePath
                      .map(Self.isSafeRelativePath)
                      == true
              }),
              entries.last?
                .primeDestinationRelativePath == nil,
              entries.prefix(8).allSatisfy({
                  $0.derivation.kind
                      == .byteExactDonor
              }),
              entries[8].derivation
                .expectedOutputByteCount == 2_397,
              entries[8].derivation
                .expectedOutputSHA256
                == "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f",
              entries[9].derivation
                .expectedOutputByteCount == 88_141,
              entries[9].derivation
                .expectedOutputSHA256
                == "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99",
              entries[9].derivation.rewrites.last?
                .replacementUTF8.contains(
                    inputs[10].sha256
                ) == true,
              entries[10].derivation.kind
                == .byteExactDonor,
              Self.isSafeRelativePath(
                  proofManifestRelativePath
              ),
              lexicalSourceDiffManifestRequired,
              compiledTargetSourceClosureRequired,
              probeAndVerifierRecomputeRequired,
              !candidateDeclaredExpectedValuesPermitted,
              !behavioralReplayMayReplaceSourceProof,
              !independentScientificOracleClaimed,
              historicalFixtureInheritedTryBangCount
                == 11,
              historicalFixtureContainsAdditionalTrapSites,
              !historicalFixtureWhollyFailClosed,
              historicalFixtureFreshProcessContainmentRequired,
              historicalFixtureMaximumWallSeconds
                == 600,
              historicalFixtureMaximumStandardOutputBytes
                == 1_048_576,
              historicalFixtureMaximumStandardErrorBytes
                == 1_048_576
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("adaptation_proof")
        }
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        !path.hasPrefix("/")
            && !path.contains("\0")
            && path.split(
                separator: "/",
                omittingEmptySubsequences: false
            ).allSatisfy {
                !$0.isEmpty
                    && $0 != "."
                    && $0 != ".."
                    && $0 != ".git"
            }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case entries
        case proofManifestRelativePath =
            "proof_manifest_relative_path"
        case lexicalSourceDiffManifestRequired =
            "lexical_source_diff_manifest_required"
        case compiledTargetSourceClosureRequired =
            "compiled_target_source_closure_required"
        case probeAndVerifierRecomputeRequired =
            "probe_and_verifier_recompute_required"
        case candidateDeclaredExpectedValuesPermitted =
            "candidate_declared_expected_values_permitted"
        case behavioralReplayMayReplaceSourceProof =
            "behavioral_replay_may_replace_source_proof"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
        case historicalFixtureInheritedTryBangCount =
            "historical_fixture_inherited_try_bang_count"
        case historicalFixtureContainsAdditionalTrapSites =
            "historical_fixture_contains_additional_trap_sites"
        case historicalFixtureWhollyFailClosed =
            "historical_fixture_wholly_fail_closed"
        case historicalFixtureFreshProcessContainmentRequired =
            "historical_fixture_fresh_process_containment_required"
        case historicalFixtureMaximumWallSeconds =
            "historical_fixture_maximum_wall_seconds"
        case historicalFixtureMaximumStandardOutputBytes =
            "historical_fixture_maximum_standard_output_bytes"
        case historicalFixtureMaximumStandardErrorBytes =
            "historical_fixture_maximum_standard_error_bytes"
        case historicalFixtureChildEnvironmentPolicy =
            "historical_fixture_child_environment_policy"
        case historicalFixtureChildStandardInputPolicy =
            "historical_fixture_child_standard_input_policy"
        case historicalFixtureAbnormalTerminationPolicy =
            "historical_fixture_abnormal_termination_policy"
    }
}

public struct PrimeNativeNeuralGateFixtureInputPin:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let role:
        PrimeNativeNeuralGateFixtureInputRole
    public let repositoryRelativePath: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String
    public let transplantPolicy:
        PrimeNativeNeuralGateFixtureTransplantPolicy
    public let dynamicallyCompiledOrExecuted:
        Bool

    public init(
        ordinal: Int,
        role:
            PrimeNativeNeuralGateFixtureInputRole,
        repositoryRelativePath: String,
        mode: String,
        objectType: String,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String,
        transplantPolicy:
            PrimeNativeNeuralGateFixtureTransplantPolicy,
        dynamicallyCompiledOrExecuted: Bool
    ) {
        self.ordinal = ordinal
        self.role = role
        self.repositoryRelativePath =
            repositoryRelativePath
        self.mode = mode
        self.objectType = objectType
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
        self.transplantPolicy = transplantPolicy
        self.dynamicallyCompiledOrExecuted =
            dynamicallyCompiledOrExecuted
    }

    public func validate() throws {
        let pathComponents =
            repositoryRelativePath.split(
                separator: "/",
                omittingEmptySubsequences: false
            )
        guard ordinal > 0,
              !pathComponents.isEmpty,
              pathComponents.allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
              }),
              !repositoryRelativePath.hasPrefix("/"),
              !repositoryRelativePath.contains("\0"),
              mode == "100644",
              objectType == "blob",
              PrimeNativeContractMigrationPlan
                .isGitOID(gitBlobOID),
              byteCount > 0,
              Self.isLowercaseSHA256(sha256),
              !dynamicallyCompiledOrExecuted
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(role.rawValue)
        }
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case role
        case repositoryRelativePath =
            "repository_relative_path"
        case mode
        case objectType = "object_type"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
        case transplantPolicy =
            "transplant_policy"
        case dynamicallyCompiledOrExecuted =
            "dynamically_compiled_or_executed"
    }
}

public struct PrimeNativeNeuralGateStageAParentPin:
    Codable,
    Equatable,
    Sendable
{
    public let receiptRelativePath: String
    public let receiptByteCount: UInt64
    public let receiptSHA256: String
    public let claimScope: String
    public let primeRevision: String
    public let primeTreeOID: String
    public let sourceSnapshotRelativePath:
        String
    public let sourceSnapshotByteCount: UInt64
    public let sourceSnapshotSHA256: String
    public let sourceIdentitySHA256: String

    public static let frozenV1 = Self(
        receiptRelativePath:
            "prime-native-neural-gate-contract-projection-receipt.v1.json",
        receiptByteCount: 3_193,
        receiptSHA256:
            "2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed",
        claimScope:
            "source_pinned_neuralkit_native_language_gate_contract_projection_only",
        primeRevision:
            "a1ff82f092eed2093ab8062ef1bbea66f03cb3a3",
        primeTreeOID:
            "617c70e258e393cacc88896962f16b684480958a",
        sourceSnapshotRelativePath:
            "neural-gate-contract/prime-swift-source-snapshot.v1.json",
        sourceSnapshotByteCount: 3_684_142,
        sourceSnapshotSHA256:
            "5c433cf3a84c46c83b250fd6391ab5644252e5979eabc179f59cf1a1be5d0179",
        sourceIdentitySHA256:
            "c2a144054544b9db68a3765ed3068430cb2ccd284e6477cd6ece26220a8a6091"
    )

    public func validate() throws {
        guard self == .frozenV1,
              receiptByteCount > 0,
              sourceSnapshotByteCount > 0,
              PrimeNativeContractMigrationPlan
                .isGitOID(primeRevision),
              PrimeNativeContractMigrationPlan
                .isGitOID(primeTreeOID),
              sourceIdentitySHA256
                == PrimePinnedHistoricalReleaseSource
                .nativeNeuralGateContractProjection20260730
                .sourceIdentitySHA256
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("stage_a_parent")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case receiptRelativePath =
            "receipt_relative_path"
        case receiptByteCount =
            "receipt_byte_count"
        case receiptSHA256 = "receipt_sha256"
        case claimScope = "claim_scope"
        case primeRevision = "prime_revision"
        case primeTreeOID = "prime_tree_oid"
        case sourceSnapshotRelativePath =
            "source_snapshot_relative_path"
        case sourceSnapshotByteCount =
            "source_snapshot_byte_count"
        case sourceSnapshotSHA256 =
            "source_snapshot_sha256"
        case sourceIdentitySHA256 =
            "source_identity_sha256"
    }
}

public struct PrimeNativeNeuralGateHistoricalLeakFinding:
    Codable,
    Equatable,
    Sendable
{
    public let findingID: String
    public let sourceRelativePath: String
    public let firstLine: Int
    public let lastLine: Int
    public let observedConstruction: String
    public let semanticEffect: String

    public init(
        findingID: String,
        sourceRelativePath: String,
        firstLine: Int,
        lastLine: Int,
        observedConstruction: String,
        semanticEffect: String
    ) {
        self.findingID = findingID
        self.sourceRelativePath = sourceRelativePath
        self.firstLine = firstLine
        self.lastLine = lastLine
        self.observedConstruction =
            observedConstruction
        self.semanticEffect = semanticEffect
    }

    private enum CodingKeys: String, CodingKey {
        case findingID = "finding_id"
        case sourceRelativePath =
            "source_relative_path"
        case firstLine = "first_line"
        case lastLine = "last_line"
        case observedConstruction =
            "observed_construction"
        case semanticEffect = "semantic_effect"
    }
}

public enum PrimeNativeNeuralGateFixtureReplayArm:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case historicalForensic =
        "historical_source_pinned_forensic"
    case correctedFixedCapEOS =
        "corrected_prompt_only_fixed_cap_eos"
}

public enum PrimeNativeNeuralGateTargetIndependenceDisposition:
    String,
    Codable,
    Equatable,
    Sendable
{
    case mandatoryAbstainKnownHistoricalLeak =
        "abstain_known_historical_target_leak"
    case requiresObservedPass =
        "requires_observed_target_independence_pass"
}

public struct PrimeNativeNeuralGateFixtureArmContract:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let arm:
        PrimeNativeNeuralGateFixtureReplayArm
    public let classification: String
    public let predictionProvenance: String
    public let sourcePinned: Bool
    public let promptOnlyGeneration: Bool
    public let fixedCapEOSGeneration: Bool
    public let targetIndependenceEligible:
        Bool
    public let targetIndependenceDisposition:
        PrimeNativeNeuralGateTargetIndependenceDisposition
    public let forensicMechanicsPassEligible:
        Bool
    public let terminalStageBPassAloneEligible:
        Bool
    public let terminalMechanicsContributionRequired:
        Bool
    public let historicalResidueParityRequired:
        Bool
    public let fingerprintNamespace: String

    public init(
        ordinal: Int,
        arm:
            PrimeNativeNeuralGateFixtureReplayArm,
        classification: String,
        predictionProvenance: String,
        sourcePinned: Bool,
        promptOnlyGeneration: Bool,
        fixedCapEOSGeneration: Bool,
        targetIndependenceEligible: Bool,
        targetIndependenceDisposition:
            PrimeNativeNeuralGateTargetIndependenceDisposition,
        forensicMechanicsPassEligible: Bool,
        terminalStageBPassAloneEligible: Bool,
        terminalMechanicsContributionRequired:
            Bool,
        historicalResidueParityRequired: Bool,
        fingerprintNamespace: String
    ) {
        self.ordinal = ordinal
        self.arm = arm
        self.classification = classification
        self.predictionProvenance =
            predictionProvenance
        self.sourcePinned = sourcePinned
        self.promptOnlyGeneration =
            promptOnlyGeneration
        self.fixedCapEOSGeneration =
            fixedCapEOSGeneration
        self.targetIndependenceEligible =
            targetIndependenceEligible
        self.targetIndependenceDisposition =
            targetIndependenceDisposition
        self.forensicMechanicsPassEligible =
            forensicMechanicsPassEligible
        self.terminalStageBPassAloneEligible =
            terminalStageBPassAloneEligible
        self.terminalMechanicsContributionRequired =
            terminalMechanicsContributionRequired
        self.historicalResidueParityRequired =
            historicalResidueParityRequired
        self.fingerprintNamespace =
            fingerprintNamespace
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case arm
        case classification
        case predictionProvenance =
            "prediction_provenance"
        case sourcePinned = "source_pinned"
        case promptOnlyGeneration =
            "prompt_only_generation"
        case fixedCapEOSGeneration =
            "fixed_cap_eos_generation"
        case targetIndependenceEligible =
            "target_independence_eligible"
        case targetIndependenceDisposition =
            "target_independence_disposition"
        case forensicMechanicsPassEligible =
            "forensic_mechanics_pass_eligible"
        case terminalStageBPassAloneEligible =
            "terminal_stage_b_pass_alone_eligible"
        case terminalMechanicsContributionRequired =
            "terminal_mechanics_contribution_required"
        case historicalResidueParityRequired =
            "historical_residue_parity_required"
        case fingerprintNamespace =
            "fingerprint_namespace"
    }
}

public struct PrimeNativeNeuralGateCorrectedExecutorContract:
    Codable,
    Equatable,
    Sendable
{
    public let generationContractID: String
    public let predictionConstructionPolicy:
        String
    public let predictionInputFields: [String]
    public let forbiddenPredictionInputFields:
        [String]
    public let promptGroupingKeyID: String
    public let maximumGenerationTokenDecisions:
        Int
    public let allowedCompletionTokenCount: Int
    public let allowedCompletionTokenSetSHA256:
        String
    public let targetIndependentDecisionBudget:
        Bool
    public let eosAvailableAtEveryDecision: Bool
    public let eosCountsAsExecutedDecision: Bool
    public let eosExcludedFromGeneratedTokenIDs:
        Bool
    public let targetControlsStoppingLength: Bool
    public let targetVisibleToExecutionLoop:
        Bool
    public let targetDerivedOutputPermitted: Bool
    public let targetDependentGroupingPermitted:
        Bool
    public let targetDependentTerminationPermitted:
        Bool
    public let targetDependentRowInclusionPermitted:
        Bool
    public let completionSupportMayNarrow:
        Bool
    public let fullVocabularySupportAuditRequired:
        Bool
    public let targetMutationReplayPolicy: String
    public let targetFeasibilityAdmissionPolicy:
        String

    public static let frozenV1: Self = {
        let generation =
            PrimeNativeGenerationContractProjection
            .frozenV1
        let fields = generation.promptOnlyFields
        return Self(
            generationContractID:
                generation.generationContractID,
            predictionConstructionPolicy:
                "deterministic_prompt_only_fixture_executor_using_only_frozen_prediction_input_fields_v1",
            predictionInputFields:
                fields.primeRequestFields,
            forbiddenPredictionInputFields:
                fields
                .forbiddenTargetAndRegradeFields,
            promptGroupingKeyID:
                generation.promptGroupingKeyID,
            maximumGenerationTokenDecisions:
                generation
                .maximumGenerationTokenDecisions,
            allowedCompletionTokenCount:
                generation
                .allowedCompletionTokenIDs.count,
            allowedCompletionTokenSetSHA256:
                generation
                .allowedCompletionTokenSetSHA256,
            targetIndependentDecisionBudget:
                generation
                .targetIndependentDecisionBudget,
            eosAvailableAtEveryDecision:
                generation
                .eosAvailableAtEveryDecision,
            eosCountsAsExecutedDecision:
                generation
                .eosCountsAsExecutedDecision,
            eosExcludedFromGeneratedTokenIDs:
                generation
                .eosExcludedFromGeneratedTokenIDs,
            targetControlsStoppingLength:
                fields.targetControlsStoppingLength,
            targetVisibleToExecutionLoop:
                fields.targetVisibleToGenerationLoop,
            targetDerivedOutputPermitted: false,
            targetDependentGroupingPermitted:
                false,
            targetDependentTerminationPermitted:
                false,
            targetDependentRowInclusionPermitted:
                false,
            completionSupportMayNarrow: false,
            fullVocabularySupportAuditRequired:
                generation
                .fullVocabularySupportAuditRequired,
            targetMutationReplayPolicy:
                "hold_row_id_seed_prompt_text_prompt_token_ids_and_prompt_grouping_key_exact_then_substitute_distinct_valid_same_length_and_different_length_targets_and_require_byte_exact_raw_execution_identity_v1",
            targetFeasibilityAdmissionPolicy:
                "validate_complete_frozen_fixture_before_execution_then_forbid_per_row_target_dependent_skip_batch_group_or_termination_v1"
        )
    }()

    public func validate() throws {
        let generation =
            PrimeNativeGenerationContractProjection
            .frozenV1
        try generation.validate()
        try generation.promptOnlyFields
            .validateFrozenV1()
        guard self == .frozenV1,
              generationContractID
                == "greedy_native_bytes_eos_fixed_cap64_kv_v2",
              maximumGenerationTokenDecisions == 64,
              allowedCompletionTokenCount == 257,
              targetIndependentDecisionBudget,
              eosAvailableAtEveryDecision,
              eosCountsAsExecutedDecision,
              eosExcludedFromGeneratedTokenIDs,
              !targetControlsStoppingLength,
              !targetVisibleToExecutionLoop,
              !targetDerivedOutputPermitted,
              !targetDependentGroupingPermitted,
              !targetDependentTerminationPermitted,
              !targetDependentRowInclusionPermitted,
              !completionSupportMayNarrow,
              fullVocabularySupportAuditRequired,
              Set(predictionInputFields)
                .isDisjoint(
                    with:
                    Set(
                        forbiddenPredictionInputFields
                    )
                ),
              forbiddenPredictionInputFields
                .contains("target"),
              forbiddenPredictionInputFields
                .contains("target_token_ids"),
              forbiddenPredictionInputFields
                .contains("expected_completion")
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("corrected_executor")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case generationContractID =
            "generation_contract_id"
        case predictionConstructionPolicy =
            "prediction_construction_policy"
        case predictionInputFields =
            "prediction_input_fields"
        case forbiddenPredictionInputFields =
            "forbidden_prediction_input_fields"
        case promptGroupingKeyID =
            "prompt_grouping_key_id"
        case maximumGenerationTokenDecisions =
            "maximum_generation_token_decisions"
        case allowedCompletionTokenCount =
            "allowed_completion_token_count"
        case allowedCompletionTokenSetSHA256 =
            "allowed_completion_token_set_sha256"
        case targetIndependentDecisionBudget =
            "target_independent_decision_budget"
        case eosAvailableAtEveryDecision =
            "eos_available_at_every_decision"
        case eosCountsAsExecutedDecision =
            "eos_counts_as_executed_decision"
        case eosExcludedFromGeneratedTokenIDs =
            "eos_excluded_from_generated_token_ids"
        case targetControlsStoppingLength =
            "target_controls_stopping_length"
        case targetVisibleToExecutionLoop =
            "target_visible_to_execution_loop"
        case targetDerivedOutputPermitted =
            "target_derived_output_permitted"
        case targetDependentGroupingPermitted =
            "target_dependent_grouping_permitted"
        case targetDependentTerminationPermitted =
            "target_dependent_termination_permitted"
        case targetDependentRowInclusionPermitted =
            "target_dependent_row_inclusion_permitted"
        case completionSupportMayNarrow =
            "completion_support_may_narrow"
        case fullVocabularySupportAuditRequired =
            "full_vocabulary_support_audit_required"
        case targetMutationReplayPolicy =
            "target_mutation_replay_policy"
        case targetFeasibilityAdmissionPolicy =
            "target_feasibility_admission_policy"
    }
}

public enum PrimeNativeNeuralGateCorrectedFixtureMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case targetValueChangesRawExecution =
        "target_value_changes_raw_execution"
    case targetLengthChangesRawExecution =
        "target_length_changes_raw_execution"
    case expectedCompletionInjectedIntoPrediction =
        "expected_completion_injected_into_prediction"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case targetDependentDecisionBudget =
        "target_dependent_decision_budget"
    case eosUnavailableAtDecision =
        "eos_unavailable_at_decision"
    case completionSupportNarrowed =
        "completion_support_narrowed"
    case fixedCapDrift =
        "fixed_cap_drift"
    case targetDependentTermination =
        "target_dependent_termination"
    case targetDependentRowInclusion =
        "target_dependent_row_inclusion"

    public var detectorID: String {
        switch self {
        case .targetValueChangesRawExecution:
            "paired_target_value_raw_execution_identity_gate_v1"
        case .targetLengthChangesRawExecution:
            "paired_target_length_raw_execution_identity_gate_v1"
        case .expectedCompletionInjectedIntoPrediction:
            "prediction_input_field_exclusion_gate_v1"
        case .targetDependentPromptGrouping:
            "target_independent_prompt_grouping_gate_v1"
        case .targetDependentDecisionBudget:
            "target_independent_fixed_budget_gate_v1"
        case .eosUnavailableAtDecision:
            "eos_every_decision_gate_v1"
        case .completionSupportNarrowed:
            "exact_full_byte_completion_support_gate_v1"
        case .fixedCapDrift:
            "exact_fixed_cap64_gate_v1"
        case .targetDependentTermination:
            "target_independent_termination_gate_v1"
        case .targetDependentRowInclusion:
            "target_independent_row_inclusion_gate_v1"
        }
    }

    public var expectedFailedLeg: String {
        switch self {
        case .targetValueChangesRawExecution:
            "corrected_target_value_independence"
        case .targetLengthChangesRawExecution:
            "corrected_target_length_independence"
        case .expectedCompletionInjectedIntoPrediction:
            "corrected_prediction_input_exclusion"
        case .targetDependentPromptGrouping:
            "corrected_prompt_grouping"
        case .targetDependentDecisionBudget:
            "corrected_decision_budget"
        case .eosUnavailableAtDecision:
            "corrected_eos_availability"
        case .completionSupportNarrowed:
            "corrected_completion_support"
        case .fixedCapDrift:
            "corrected_fixed_cap"
        case .targetDependentTermination:
            "corrected_termination_independence"
        case .targetDependentRowInclusion:
            "corrected_row_inclusion_independence"
        }
    }

    public var mutationOperation: String {
        switch self {
        case .targetValueChangesRawExecution:
            "inject_target_value_into_prediction_construction_then_pair_distinct_same_length_target"
        case .targetLengthChangesRawExecution:
            "inject_target_length_into_prediction_length_then_pair_distinct_length_target"
        case .expectedCompletionInjectedIntoPrediction:
            "inject_expected_completion_into_prediction_bytes"
        case .targetDependentPromptGrouping:
            "inject_target_byte_count_into_prompt_grouping_key"
        case .targetDependentDecisionBudget:
            "replace_fixed_decision_budget_with_target_token_count_plus_eos"
        case .eosUnavailableAtDecision:
            "remove_eos_from_allowed_support_at_one_decision"
        case .completionSupportNarrowed:
            "replace_frozen_eos_plus_full_byte_support_with_ascii_subset"
        case .fixedCapDrift:
            "replace_maximum_generation_token_decisions_64_with_63"
        case .targetDependentTermination:
            "terminate_when_executed_decisions_equal_target_token_count"
        case .targetDependentRowInclusion:
            "skip_row_when_target_token_count_differs_from_prediction_token_count"
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedFixtureMutationContract:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let arm:
        PrimeNativeNeuralGateFixtureReplayArm
    public let mutation:
        PrimeNativeNeuralGateCorrectedFixtureMutation
    public let detectorID: String
    public let expectedFailedLeg: String
    public let mutationOperation: String
    public let fingerprintDivergenceRequired:
        Bool
    public let recordExactRestorationRequired:
        Bool
    public let fingerprintExactRestorationRequired:
        Bool

    public init(
        ordinal: Int,
        mutation:
            PrimeNativeNeuralGateCorrectedFixtureMutation
    ) {
        self.ordinal = ordinal
        arm = .correctedFixedCapEOS
        self.mutation = mutation
        detectorID = mutation.detectorID
        expectedFailedLeg =
            mutation.expectedFailedLeg
        mutationOperation =
            mutation.mutationOperation
        fingerprintDivergenceRequired = true
        recordExactRestorationRequired = true
        fingerprintExactRestorationRequired =
            true
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case arm
        case mutation
        case detectorID = "detector_id"
        case expectedFailedLeg =
            "expected_failed_leg"
        case mutationOperation =
            "mutation_operation"
        case fingerprintDivergenceRequired =
            "fingerprint_divergence_required"
        case recordExactRestorationRequired =
            "record_exact_restoration_required"
        case fingerprintExactRestorationRequired =
            "fingerprint_exact_restoration_required"
    }
}

public struct PrimeNativeNeuralGateMutationOutcomeContract:
    Codable,
    Equatable,
    Sendable
{
    public let orderedCatalogRequired: Bool
    public let perMutationObservationRequired:
        Bool
    public let detectionRequired: Bool
    public let expectedLegFailureRequired:
        Bool
    public let fingerprintDivergenceRequired:
        Bool
    public let recordExactRestorationRequired:
        Bool
    public let fingerprintExactRestorationRequired:
        Bool

    public static let frozenV1 = Self(
        orderedCatalogRequired: true,
        perMutationObservationRequired: true,
        detectionRequired: true,
        expectedLegFailureRequired: true,
        fingerprintDivergenceRequired: true,
        recordExactRestorationRequired: true,
        fingerprintExactRestorationRequired:
            true
    )

    public func validate() throws {
        guard self == .frozenV1,
              orderedCatalogRequired,
              perMutationObservationRequired,
              detectionRequired,
              expectedLegFailureRequired,
              fingerprintDivergenceRequired,
              recordExactRestorationRequired,
              fingerprintExactRestorationRequired
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("mutation_outcome")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case orderedCatalogRequired =
            "ordered_catalog_required"
        case perMutationObservationRequired =
            "per_mutation_observation_required"
        case detectionRequired =
            "detection_required"
        case expectedLegFailureRequired =
            "expected_leg_failure_required"
        case fingerprintDivergenceRequired =
            "fingerprint_divergence_required"
        case recordExactRestorationRequired =
            "record_exact_restoration_required"
        case fingerprintExactRestorationRequired =
            "fingerprint_exact_restoration_required"
    }
}

public struct PrimeNativeNeuralGateObservationContract:
    Codable,
    Equatable,
    Sendable
{
    public let criticalLegs:
        [PrimeNativeNeuralGateCriticalLegContract]
    public let statistics:
        PrimeNativeNeuralGateStatisticalContract
    public let capabilityThresholds:
        PrimeNativeNeuralGateCapabilityThresholdContract
    public let verdict:
        PrimeNativeNeuralGateVerdictContract
    public let criticalLegCatalogSHA256: String
    public let statisticsContractSHA256: String
    public let capabilityThresholdContractSHA256:
        String
    public let verdictContractSHA256: String
    public let finiteFieldContractSHA256: String
    public let requiredForEveryArm: Bool
    public let rawInputsRegradedBeforeGate:
        Bool
    public let tenCriticalLegOutcomesRecomputed:
        Bool
    public let projectedLossStatisticsRecomputed:
        Bool
    public let fixedPromptRunnerUpMarginRecomputed:
        Bool
    public let capabilityThresholdsRecomputed:
        Bool
    public let countDerivedLabelRecomputed:
        Bool
    public let allCriticalVerdictRecomputed:
        Bool
    public let candidateDeclaredAggregatesAreAuthority:
        Bool
    public let countLabelIsIndependentTriad:
        Bool
    public let guardedStatisticalEntanglementPerformed:
        Bool

    public static let frozenV1: Self = {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        return Self(
            criticalLegs: projection.criticalLegs,
            statistics: projection.statistics,
            capabilityThresholds:
                projection.capabilityThresholds,
            verdict: projection.verdict,
            criticalLegCatalogSHA256:
                "b25d5993dda60cfe3dfffacbdd9e56280383490aae5a0f8ca07b1b6ab76fb87c",
            statisticsContractSHA256:
                "c10ac090a9d24688e7aa1fb9aa4a4d3ffde4a7d705080e28a47aa46455c6bf0c",
            capabilityThresholdContractSHA256:
                "882f36f3aed229e9a55da353e9b64cbe28d5535a61b7f6b8e1c945c7bd316470",
            verdictContractSHA256:
                "a5a607f9a583fa932962c78f82e7407e5964fa1adb3c776e1cd21c095001973c",
            finiteFieldContractSHA256:
                "d042a33ee52550fcc9ea0cce14ddba4a03cb24f3900c73282b9491436d36a095",
            requiredForEveryArm: true,
            rawInputsRegradedBeforeGate: true,
            tenCriticalLegOutcomesRecomputed:
                true,
            projectedLossStatisticsRecomputed:
                true,
            fixedPromptRunnerUpMarginRecomputed:
                true,
            capabilityThresholdsRecomputed:
                true,
            countDerivedLabelRecomputed: true,
            allCriticalVerdictRecomputed: true,
            candidateDeclaredAggregatesAreAuthority:
                false,
            countLabelIsIndependentTriad: false,
            guardedStatisticalEntanglementPerformed:
                false
        )
    }()

    public func validate() throws {
        try statistics.validate()
        try capabilityThresholds.validate()
        try verdict.validate()
        let expectedLegIDs = [
            "NL1_canonical_material_reload",
            "NL2_finite_field_sz_pool_expansion",
            "NL3_foundation_tokenizer_corpus_regrade",
            "NL4_raw_executor_row_regrade",
            "NL5_causal_training_mechanics",
            "NL6_checkpoint_durability",
            "NL7_same_seed_initialization_training_result_replay",
            "NL8_frozen_exact_seed_consensus",
            "NL9_capability_and_malformed_abstention",
            "NL10_mutation_synthesis",
        ]
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        guard self == .frozenV1,
              criticalLegs.map(\.ordinal)
                == Array(1 ... 10),
              criticalLegs.map(\.legID)
                == expectedLegIDs,
              PrimeSHA256.hexDigest(
                  of:
                  try PrimeCanonicalJSON.encode(
                      criticalLegs
                  )
              ) == criticalLegCatalogSHA256,
              PrimeSHA256.hexDigest(
                  of:
                  try PrimeCanonicalJSON.encode(
                      statistics
                  )
              ) == statisticsContractSHA256,
              PrimeSHA256.hexDigest(
                  of:
                  try PrimeCanonicalJSON.encode(
                      capabilityThresholds
                  )
              ) == capabilityThresholdContractSHA256,
              PrimeSHA256.hexDigest(
                  of:
                  try PrimeCanonicalJSON.encode(
                      verdict
                  )
              ) == verdictContractSHA256,
              PrimeSHA256.hexDigest(
                  of:
                  try PrimeCanonicalJSON.encode(
                      projection.finiteField
                  )
              ) == finiteFieldContractSHA256,
              requiredForEveryArm,
              rawInputsRegradedBeforeGate,
              tenCriticalLegOutcomesRecomputed,
              projectedLossStatisticsRecomputed,
              fixedPromptRunnerUpMarginRecomputed,
              capabilityThresholdsRecomputed,
              countDerivedLabelRecomputed,
              allCriticalVerdictRecomputed,
              !candidateDeclaredAggregatesAreAuthority,
              !countLabelIsIndependentTriad,
              !guardedStatisticalEntanglementPerformed,
              verdict.triadicSemantics
                == "count_derived_label_not_four_tier_independence_audit",
              !verdict
                .distinctImplementationFamiliesEstablished,
              !verdict
                .agentContractKitFourTierAuditPerformed
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("gate_observation")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case criticalLegs = "critical_legs"
        case statistics
        case capabilityThresholds =
            "capability_thresholds"
        case verdict
        case criticalLegCatalogSHA256 =
            "critical_leg_catalog_sha256"
        case statisticsContractSHA256 =
            "statistics_contract_sha256"
        case capabilityThresholdContractSHA256 =
            "capability_threshold_contract_sha256"
        case verdictContractSHA256 =
            "verdict_contract_sha256"
        case finiteFieldContractSHA256 =
            "finite_field_contract_sha256"
        case requiredForEveryArm =
            "required_for_every_arm"
        case rawInputsRegradedBeforeGate =
            "raw_inputs_regraded_before_gate"
        case tenCriticalLegOutcomesRecomputed =
            "ten_critical_leg_outcomes_recomputed"
        case projectedLossStatisticsRecomputed =
            "projected_loss_statistics_recomputed"
        case fixedPromptRunnerUpMarginRecomputed =
            "fixed_prompt_runner_up_margin_recomputed"
        case capabilityThresholdsRecomputed =
            "capability_thresholds_recomputed"
        case countDerivedLabelRecomputed =
            "count_derived_label_recomputed"
        case allCriticalVerdictRecomputed =
            "all_critical_verdict_recomputed"
        case candidateDeclaredAggregatesAreAuthority =
            "candidate_declared_aggregates_are_authority"
        case countLabelIsIndependentTriad =
            "count_label_is_independent_triad"
        case guardedStatisticalEntanglementPerformed =
            "guarded_statistical_entanglement_performed"
    }
}

public struct PrimeNativeNeuralGateReplayRootPolicy:
    Codable,
    Equatable,
    Sendable
{
    public let canonicalRootPolicy: String
    public let stageARootRelationship: String
    public let artifactRootRelationship: String
    public let companionPrimeDisjoint: Bool
    public let companionStageADisjoint: Bool
    public let companionArtifactDisjoint: Bool
    public let stageAArtifactDisjoint: Bool
    public let dotGitTraversalForbidden: Bool
    public let stageARootReadOnlyDuringRun: Bool
    public let companionRootReadOnlyDuringRun:
        Bool
    public let companionSourceStatePolicy: String
    public let artifactRootInitialState: String
    public let requiredRejectionMutationIDs:
        [String]

    public static let frozenV1 = Self(
        canonicalRootPolicy:
            "absolute_nonroot_nul_free_standardized_and_resolving_symlinks_exact_v1",
        stageARootRelationship:
            "strict_descendant_of_prime_root_artifacts_v1",
        artifactRootRelationship:
            "distinct_strict_descendant_of_prime_root_artifacts_v1",
        companionPrimeDisjoint: true,
        companionStageADisjoint: true,
        companionArtifactDisjoint: true,
        stageAArtifactDisjoint: true,
        dotGitTraversalForbidden: true,
        stageARootReadOnlyDuringRun: true,
        companionRootReadOnlyDuringRun: true,
        companionSourceStatePolicy:
            "clean_exact_revision_tree_and_eleven_blob_identity_before_and_after_execution_v1",
        artifactRootInitialState:
            "preexisting_empty_current_euid_owned_directory_mode_0700_no_symlink_components_v1",
        requiredRejectionMutationIDs: [
            "relative_root",
            "filesystem_root",
            "nul_root",
            "nonstandard_root",
            "symlink_component_root",
            "duplicate_root_argument",
            "unknown_root_argument",
            "missing_root_argument",
            "companion_overlaps_prime",
            "companion_overlaps_stage_a",
            "companion_overlaps_artifact",
            "stage_a_outside_prime_artifacts",
            "artifact_outside_prime_artifacts",
            "artifact_overlaps_stage_a",
            "artifact_inside_dot_git",
            "artifact_root_absent",
            "artifact_root_nonempty",
            "artifact_root_wrong_owner",
            "artifact_root_wrong_mode",
        ]
    )

    public func validate() throws {
        guard self == .frozenV1,
              companionPrimeDisjoint,
              companionStageADisjoint,
              companionArtifactDisjoint,
              stageAArtifactDisjoint,
              dotGitTraversalForbidden,
              stageARootReadOnlyDuringRun,
              companionRootReadOnlyDuringRun,
              Set(requiredRejectionMutationIDs)
                .count
                == requiredRejectionMutationIDs.count
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("root_policy")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case canonicalRootPolicy =
            "canonical_root_policy"
        case stageARootRelationship =
            "stage_a_root_relationship"
        case artifactRootRelationship =
            "artifact_root_relationship"
        case companionPrimeDisjoint =
            "companion_prime_disjoint"
        case companionStageADisjoint =
            "companion_stage_a_disjoint"
        case companionArtifactDisjoint =
            "companion_artifact_disjoint"
        case stageAArtifactDisjoint =
            "stage_a_artifact_disjoint"
        case dotGitTraversalForbidden =
            "dot_git_traversal_forbidden"
        case stageARootReadOnlyDuringRun =
            "stage_a_root_read_only_during_run"
        case companionRootReadOnlyDuringRun =
            "companion_root_read_only_during_run"
        case companionSourceStatePolicy =
            "companion_source_state_policy"
        case artifactRootInitialState =
            "artifact_root_initial_state"
        case requiredRejectionMutationIDs =
            "required_rejection_mutation_ids"
    }
}

public struct PrimeNativeNeuralGateInvariantSerializationContract:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let recordOrdering: String
    public let globalStreamMagicASCII: String
    public let chunkMagicASCII: String
    public let totalRecordCountEncoding: String
    public let chunkOrdinalEncoding: String
    public let chunkRecordCountEncoding: String
    public let recordLengthEncoding: String
    public let maximumRecordsPerChunk: Int
    public let chunkOrdinalBase: Int
    public let canonicalChunkPartitionPolicy:
        String
    public let emptyChunkPermitted: Bool
    public let preserveDuplicates: Bool
    public let unicodeNormalizationPermitted:
        Bool
    public let lineDelimiterEncodingUsed: Bool
    public let chunkSHA256Required: Bool
    public let orderedMultisetStreamSHA256Required:
        Bool
    public let finiteFieldFingerprintIsArtifactIdentity:
        Bool

    public static let frozenV1 = Self(
        contractID:
            "prime_raw_utf8_length_framed_ordered_multiset_v1",
        recordOrdering:
            "raw_utf8_lexicographic_ascending",
        globalStreamMagicASCII: "PRIMEIRM1",
        chunkMagicASCII: "PRIMEIRC1",
        totalRecordCountEncoding: "uint64_big_endian",
        chunkOrdinalEncoding: "uint32_big_endian",
        chunkRecordCountEncoding:
            "uint32_big_endian",
        recordLengthEncoding: "uint64_big_endian",
        maximumRecordsPerChunk: 4_096,
        chunkOrdinalBase: 0,
        canonicalChunkPartitionPolicy:
            "consecutive_raw_utf8_sorted_records_exact_4096_except_nonempty_final_chunk_v1",
        emptyChunkPermitted: false,
        preserveDuplicates: true,
        unicodeNormalizationPermitted: false,
        lineDelimiterEncodingUsed: false,
        chunkSHA256Required: true,
        orderedMultisetStreamSHA256Required:
            true,
        finiteFieldFingerprintIsArtifactIdentity:
            false
    )

    public func validate() throws {
        guard self == .frozenV1,
              maximumRecordsPerChunk == 4_096,
              chunkOrdinalBase == 0,
              !emptyChunkPermitted,
              preserveDuplicates,
              !unicodeNormalizationPermitted,
              !lineDelimiterEncodingUsed,
              chunkSHA256Required,
              orderedMultisetStreamSHA256Required,
              !finiteFieldFingerprintIsArtifactIdentity
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("invariant_serialization")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case recordOrdering = "record_ordering"
        case globalStreamMagicASCII =
            "global_stream_magic_ascii"
        case chunkMagicASCII =
            "chunk_magic_ascii"
        case totalRecordCountEncoding =
            "total_record_count_encoding"
        case chunkOrdinalEncoding =
            "chunk_ordinal_encoding"
        case chunkRecordCountEncoding =
            "chunk_record_count_encoding"
        case recordLengthEncoding =
            "record_length_encoding"
        case maximumRecordsPerChunk =
            "maximum_records_per_chunk"
        case chunkOrdinalBase =
            "chunk_ordinal_base"
        case canonicalChunkPartitionPolicy =
            "canonical_chunk_partition_policy"
        case emptyChunkPermitted =
            "empty_chunk_permitted"
        case preserveDuplicates =
            "preserve_duplicates"
        case unicodeNormalizationPermitted =
            "unicode_normalization_permitted"
        case lineDelimiterEncodingUsed =
            "line_delimiter_encoding_used"
        case chunkSHA256Required =
            "chunk_sha256_required"
        case orderedMultisetStreamSHA256Required =
            "ordered_multiset_stream_sha256_required"
        case finiteFieldFingerprintIsArtifactIdentity =
            "finite_field_fingerprint_is_artifact_identity"
    }
}

public struct PrimeNativeNeuralGateFingerprintKnownAnswer:
    Codable,
    Equatable,
    Sendable
{
    public let inputRecordUTF8Hex: [String]
    public let canonicalRecordUTF8Hex:
        [String]
    public let recordCount: Int
    public let globalStreamByteCount: Int
    public let globalStreamSHA256: String
    public let chunkCount: Int
    public let firstChunkByteCount: Int
    public let firstChunkSHA256: String
    public let finiteFieldResidues: [UInt64]

    public static let frozenV1 = Self(
        inputRecordUTF8Hex: [
            "c3a9",
            "41",
            "",
            "65cc81",
            "41",
        ],
        canonicalRecordUTF8Hex: [
            "",
            "41",
            "41",
            "65cc81",
            "c3a9",
        ],
        recordCount: 5,
        globalStreamByteCount: 64,
        globalStreamSHA256:
            "56ae18634d740ef5e08f86212ac580510db5211def0834302871ba8a00246294",
        chunkCount: 1,
        firstChunkByteCount: 64,
        firstChunkSHA256:
            "be85d2d8dea54573b84d99afbabf9cf8fdca050f1dafed9d498547eb455860a2",
        finiteFieldResidues: [
            1_809_436_187,
            238_577_571,
            1_233_137_383,
        ]
    )

    public func validate() throws {
        guard self == .frozenV1,
              recordCount
                == inputRecordUTF8Hex.count,
              recordCount
                == canonicalRecordUTF8Hex.count,
              chunkCount == 1,
              finiteFieldResidues.count == 3
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("fingerprint_known_answer")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case inputRecordUTF8Hex =
            "input_record_utf8_hex"
        case canonicalRecordUTF8Hex =
            "canonical_record_utf8_hex"
        case recordCount = "record_count"
        case globalStreamByteCount =
            "global_stream_byte_count"
        case globalStreamSHA256 =
            "global_stream_sha256"
        case chunkCount = "chunk_count"
        case firstChunkByteCount =
            "first_chunk_byte_count"
        case firstChunkSHA256 =
            "first_chunk_sha256"
        case finiteFieldResidues =
            "finite_field_residues"
    }
}

public struct PrimeNativeNeuralGateFingerprintReplayContract:
    Codable,
    Equatable,
    Sendable
{
    public let directAlgorithmID: String
    public let acceleratedAlgorithmID: String
    public let affineLeafEquation: String
    public let affineIdentity: String
    public let affineCompositionEquation:
        String
    public let affineSeedApplicationEquation:
        String
    public let affineCompositionOrder: String
    public let acceleratedCacheKey: String
    public let cacheRequiresRawByteEquality:
        Bool
    public let directRecomputedInEveryProcess:
        Bool
    public let acceleratedRecomputedInEveryProcess:
        Bool
    public let exactDirectAcceleratedEquality:
        Bool
    public let staleCacheMutationRequired: Bool
    public let directFingerprintIsSupplemental:
        Bool
    public let knownAnswer:
        PrimeNativeNeuralGateFingerprintKnownAnswer

    public static let frozenV1 = Self(
        directAlgorithmID:
            "raw_utf8_uint64be_length_horner_three_point_v1",
        acceleratedAlgorithmID:
            "immutable_raw_utf8_affine_segment_tree_v1",
        affineLeafEquation:
            "leaf(byte)=(multiplier=point,addend=byte_plus_1_mod_prime,byte_count=1)",
        affineIdentity:
            "(multiplier=1,addend=0,byte_count=0)",
        affineCompositionEquation:
            "compose(left,right)=(left.multiplier_times_right.multiplier_mod_prime,left.addend_times_right.multiplier_plus_right.addend_mod_prime,left.byte_count_plus_right.byte_count)",
        affineSeedApplicationEquation:
            "residue=accumulator_seed_times_root.multiplier_plus_root.addend_mod_prime",
        affineCompositionOrder:
            "uint64be_record_length_bytes_then_raw_utf8_record_bytes_in_canonical_record_order",
        acceleratedCacheKey:
            "field_parameters_plus_ordered_multiset_stream_sha256",
        cacheRequiresRawByteEquality: true,
        directRecomputedInEveryProcess: true,
        acceleratedRecomputedInEveryProcess: true,
        exactDirectAcceleratedEquality: true,
        staleCacheMutationRequired: true,
        directFingerprintIsSupplemental: true,
        knownAnswer: .frozenV1
    )

    public func validate() throws {
        try knownAnswer.validate()
        guard self == .frozenV1,
              cacheRequiresRawByteEquality,
              directRecomputedInEveryProcess,
              acceleratedRecomputedInEveryProcess,
              exactDirectAcceleratedEquality,
              staleCacheMutationRequired,
              directFingerprintIsSupplemental
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("fingerprint_replay")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case directAlgorithmID =
            "direct_algorithm_id"
        case acceleratedAlgorithmID =
            "accelerated_algorithm_id"
        case affineLeafEquation =
            "affine_leaf_equation"
        case affineIdentity =
            "affine_identity"
        case affineCompositionEquation =
            "affine_composition_equation"
        case affineSeedApplicationEquation =
            "affine_seed_application_equation"
        case affineCompositionOrder =
            "affine_composition_order"
        case acceleratedCacheKey =
            "accelerated_cache_key"
        case cacheRequiresRawByteEquality =
            "cache_requires_raw_byte_equality"
        case directRecomputedInEveryProcess =
            "direct_recomputed_in_every_process"
        case acceleratedRecomputedInEveryProcess =
            "accelerated_recomputed_in_every_process"
        case exactDirectAcceleratedEquality =
            "exact_direct_accelerated_equality"
        case staleCacheMutationRequired =
            "stale_cache_mutation_required"
        case directFingerprintIsSupplemental =
            "direct_fingerprint_is_supplemental"
        case knownAnswer = "known_answer"
    }
}

public struct PrimeNativeNeuralGateParentModePin:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let byteCount: UInt64
    public let sha256: String
    public let requiredMode: String

    public init(
        relativePath: String,
        byteCount: UInt64,
        sha256: String,
        requiredMode: String = "0444"
    ) {
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.sha256 = sha256
        self.requiredMode = requiredMode
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case byteCount = "byte_count"
        case sha256
        case requiredMode = "required_mode"
    }
}

public struct PrimeNativeNeuralGateReplayTargetContract:
    Codable,
    Equatable,
    Sendable
{
    public let target: String
    public let dependencies: [String]
    public let role: String

    public init(
        target: String,
        dependencies: [String],
        role: String
    ) {
        self.target = target
        self.dependencies = dependencies
        self.role = role
    }
}

public enum PrimeNativeNeuralGateReleaseProcessRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case probe
    case verifier
}

public struct PrimeNativeNeuralGateTargetSourceClosureRule:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let sourceDirectoryRelativePath: String
    public let directLocalDependencyNames:
        [String]
    public let completeSortedSwiftFileEnumerationRequired:
        Bool
    public let fileIdentitiesDerivedOnlyFromSourceSnapshot:
        Bool

    public init(
        targetName: String,
        directLocalDependencyNames: [String]
    ) {
        self.targetName = targetName
        sourceDirectoryRelativePath =
            "Sources/\(targetName)"
        self.directLocalDependencyNames =
            directLocalDependencyNames
        completeSortedSwiftFileEnumerationRequired =
            true
        fileIdentitiesDerivedOnlyFromSourceSnapshot =
            true
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case sourceDirectoryRelativePath =
            "source_directory_relative_path"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case completeSortedSwiftFileEnumerationRequired =
            "complete_sorted_swift_file_enumeration_required"
        case fileIdentitiesDerivedOnlyFromSourceSnapshot =
            "file_identities_derived_only_from_source_snapshot"
    }
}

public struct PrimeNativeNeuralGateReleaseProcessBindingRule:
    Codable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let executableTargetName: String
    public let exactTransitiveLocalTargetNames:
        [String]
    public let runningExecutableRelativePath:
        String
    public let executableBindingRelativePath:
        String
    public let positiveProcessIdentifierRequired:
        Bool
    public let recomputeSourceSnapshotAndClosure:
        Bool

    public init(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        executableTargetName: String,
        exactTransitiveLocalTargetNames:
            [String],
        runningExecutableRelativePath: String,
        executableBindingRelativePath: String
    ) {
        self.role = role
        self.executableTargetName =
            executableTargetName
        self.exactTransitiveLocalTargetNames =
            exactTransitiveLocalTargetNames
        self.runningExecutableRelativePath =
            runningExecutableRelativePath
        self.executableBindingRelativePath =
            executableBindingRelativePath
        positiveProcessIdentifierRequired =
            true
        recomputeSourceSnapshotAndClosure = true
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case executableTargetName =
            "executable_target_name"
        case exactTransitiveLocalTargetNames =
            "exact_transitive_local_target_names"
        case runningExecutableRelativePath =
            "running_executable_relative_path"
        case executableBindingRelativePath =
            "executable_binding_relative_path"
        case positiveProcessIdentifierRequired =
            "positive_process_identifier_required"
        case recomputeSourceSnapshotAndClosure =
            "recompute_source_snapshot_and_closure"
    }
}

public struct PrimeNativeNeuralGateSourceExecutionBindingContract:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let packageManifestRelativePath:
        String
    public let sourceSnapshotRelativePath:
        String
    public let swiftPackageDescribeRelativePath:
        String
    public let compiledSourceClosureRelativePath:
        String
    public let targetClosureRules:
        [PrimeNativeNeuralGateTargetSourceClosureRule]
    public let processBindingRules:
        [PrimeNativeNeuralGateReleaseProcessBindingRule]
    public let requiredBuildConfiguration:
        String
    public let embeddedSourceIdentityAuthority:
        String
    public let runningExecutableCaptureAuthority:
        String
    public let swiftPackageDescribeCapturePolicy:
        String
    public let swiftPackageDescribeExecutableIdentityAuthority:
        String
    public let swiftPackageDescribeExpectedExecutableSHA256:
        String
    public let swiftPackageDescribeExpectedExecutableByteCount:
        UInt64
    public let swiftPackageDescribeExpectedExecutableOwnerUserID:
        UInt32
    public let swiftPackageDescribeExpectedExecutableOwnerGroupID:
        UInt32
    public let swiftPackageDescribeExpectedExecutablePermissionMode:
        UInt16
    public let swiftPackageDescribeExpectedExecutableLinkCount:
        UInt64
    public let swiftPackageDescribeCaptureRecordRelativePaths:
        [String]
    public let swiftPackageDescribeArgumentTemplate:
        [String]
    public let swiftPackageDescribeExactEnvironmentKeys:
        [String]
    public let swiftPackageDescribeEnvironmentPolicy:
        String
    public let swiftPackageDescribeScratchNamespacePolicy:
        String
    public let swiftPackageDescribeNetworkDenialEstablished:
        Bool
    public let swiftPackageDescribeDependencyResolutionPermitted:
        Bool
    public let swiftPackageDescribeResolutionResiduesForbidden:
        Bool
    public let swiftPackageDescribeMaximumWallSeconds:
        UInt64
    public let swiftPackageDescribeMaximumStandardOutputBytes:
        UInt64
    public let swiftPackageDescribeMaximumStandardErrorBytes:
        UInt64
    public let swiftPackageDescribeTerminationEscalationPolicy:
        String
    public let swiftPackageDescribeIsolatedSessionRequired:
        Bool
    public let swiftPackageDescribeDedicatedProcessGroupRequired:
        Bool
    public let swiftPackageDescribeGroupDirectedTerminationSignalsRequired:
        Bool
    public let swiftPackageDescribeNormalizedSignalMaskRequired:
        Bool
    public let swiftPackageDescribeNormalizedSignalDispositionsRequired:
        Bool
    public let swiftPackageDescribeProcessGroupEmptyAfterReapRequired:
        Bool
    public let swiftPackageDescribeDescriptorRootedWorkingDirectoryRequired:
        Bool
    public let swiftPackageDescribeSuspendedChildWorkingDirectoryVnodeJoinRequired:
        Bool
    public let swiftPackageDescribeSourceMutationGuardRequired:
        Bool
    public let swiftPackageDescribeSourceMutationGuardAuthority:
        String
    public let swiftPackageDescribeSourceAdmissionMaximumSeconds:
        UInt64
    public let swiftPackageDescribeSourceLocalFilesystemRequired:
        Bool
    public let swiftPackageDescribeSourceFilesystemType:
        String
    public let swiftPackageDescribeOutputOverflowRejected:
        Bool
    public let swiftPackageDescribeChildDeathObservedBeforeContinuationRequired:
        Bool
    public let swiftPackageDescribeChildReapBeforeContinuationRequired:
        Bool
    public let swiftPackageDescribeCaptureImplementationRequiredBeforeExecution:
        Bool
    public let swiftPackageDescribeOutputAcceptedWithoutValidatedCapture:
        Bool
    public let swiftPackageDescribeMappedChildImageCaptureRequired:
        Bool
    public let swiftPackageDescribeMappedChildImageCaptureAuthority:
        String
    public let swiftPackageDescribeMappedRegionEnumerationPolicy:
        String
    public let swiftPackageDescribeMappedRegionTerminalErrno:
        Int32
    public let swiftPackageDescribeCaptureCapabilityCalibrationRequired:
        Bool
    public let swiftPackageDescribeCaptureCapabilityCalibrationPolicy:
        String
    public let swiftPackageDescribeTrustedCaptureCapabilityRequired:
        Bool
    public let swiftPackageDescribeTrustedCaptureCapabilityAuthority:
        String
    public let swiftPackageDescribeExactPIDWaitObservationRequired:
        Bool
    public let swiftPackageDescribeProcPIDPathAuthoritative:
        Bool
    public let swiftPackageDescribeDirectExecutableLeafName:
        String
    public let swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor:
        Bool
    public let swiftPackageDescribeLaunchPathAloneAuthoritative:
        Bool
    public let sourceSnapshotIdentityEqualsEmbeddedIdentity:
        Bool
    public let processIdentityEqualsSnapshotIdentity:
        Bool
    public let processSnapshotBindingEqualsClosureSnapshotBinding:
        Bool
    public let packageManifestIdentityRequired:
        Bool
    public let exactAuthorityTargetSubgraphRequired:
        Bool
    public let cleanPrimeGitStateRequired: Bool
    public let primeGitStateAndSourceEqualPrePostAndAcrossProcesses:
        Bool
    public let runningExecutableBindingFromSameProcess:
        Bool
    public let probeVerifierProcessIDsDistinct:
        Bool
    public let probeVerifierTargetNamesDistinct:
        Bool
    public let probeVerifierExecutablePathsDistinct:
        Bool
    public let probeVerifierExecutableSHA256Distinct:
        Bool
    public let candidateBindsProbeProcessRecord:
        Bool
    public let receiptBindsVerifierProcessRecord:
        Bool
    public let verifierRecomputesProbeBindings:
        Bool
    public let reproducibleBuildProvenanceClaimed:
        Bool

    public static let frozenV3: Self = {
        let core = "PrimeCore"
        let corpusMechanics =
            "PrimeNativeCorpusReplayMechanics"
        let corpusReplay =
            "PrimeNativeCorpusReplay"
        let gateContract =
            "PrimeNativeNeuralGateContract"
        let runtimeAuthority =
            "ErgenticsPrimeRuntime"
        let replayMechanics =
            "PrimeNativeNeuralGateReplayMechanics"
        let replay = "PrimeNativeNeuralGateReplay"
        let historicalWorker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let probe =
            "PrimeNativeNeuralGateReplayProbe"
        let verifier =
            "PrimeNativeNeuralGateReplayVerifier"
        let shared = [
            core,
            corpusMechanics,
            corpusReplay,
            gateContract,
            runtimeAuthority,
            replayMechanics,
            replay,
        ]
        return Self(
            contractID:
                "prime_stage_b_release_source_executable_join_v3",
            packageManifestRelativePath:
                "Package.swift",
            sourceSnapshotRelativePath:
                "neural-gate-replay/source/prime-swift-source-snapshot.v1.json",
            swiftPackageDescribeRelativePath:
                "neural-gate-replay/source/swift-package-describe.v1.json",
            compiledSourceClosureRelativePath:
                "neural-gate-replay/source/compiled-target-source-closure.v1.json",
            targetClosureRules: [
                .init(
                    targetName: core,
                    directLocalDependencyNames: []
                ),
                .init(
                    targetName: corpusMechanics,
                    directLocalDependencyNames: []
                ),
                .init(
                    targetName: corpusReplay,
                    directLocalDependencyNames: [
                        core,
                        corpusMechanics,
                    ]
                ),
                .init(
                    targetName: gateContract,
                    directLocalDependencyNames: [
                        core,
                        corpusReplay,
                    ]
                ),
                .init(
                    targetName: runtimeAuthority,
                    directLocalDependencyNames: []
                ),
                .init(
                    targetName: replayMechanics,
                    directLocalDependencyNames: [
                        corpusMechanics,
                        runtimeAuthority,
                    ]
                ),
                .init(
                    targetName: replay,
                    directLocalDependencyNames: [
                        core,
                        gateContract,
                        replayMechanics,
                    ]
                ),
                .init(
                    targetName: historicalWorker,
                    directLocalDependencyNames: [
                        core,
                        runtimeAuthority,
                        replayMechanics,
                        replay,
                    ]
                ),
                .init(
                    targetName: probe,
                    directLocalDependencyNames: [
                        core,
                        replay,
                    ]
                ),
                .init(
                    targetName: verifier,
                    directLocalDependencyNames: [
                        core,
                        replay,
                    ]
                ),
            ],
            processBindingRules: [
                .init(
                    role: .probe,
                    executableTargetName: probe,
                    exactTransitiveLocalTargetNames:
                        shared + [probe],
                    runningExecutableRelativePath:
                        "neural-gate-replay/bin/probe",
                    executableBindingRelativePath:
                        "neural-gate-replay/bin/probe-binding.v1.json"
                ),
                .init(
                    role: .verifier,
                    executableTargetName: verifier,
                    exactTransitiveLocalTargetNames:
                        shared + [verifier],
                    runningExecutableRelativePath:
                        "neural-gate-replay/bin/verifier",
                    executableBindingRelativePath:
                        "neural-gate-replay/bin/verifier-binding.v1.json"
                ),
            ],
            requiredBuildConfiguration: "release",
            embeddedSourceIdentityAuthority:
                "PrimeEmbeddedBuildProvenance.sourceIdentitySHA256",
            runningExecutableCaptureAuthority:
                "PrimeSecureRunningExecutableCapture.data",
            swiftPackageDescribeCapturePolicy:
                "direct_swift_package_executable_describe_type_json_exact_noninherited_scratch_environment_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_local_apfs_bounded_source_admission_held_source_closure_kqueue_guard_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_full_region_transcript_descriptor_join_trusted_capture_bounded_output_exact_once_wait_bounded_wnohang_no_post_reap_signal_uncontained_fail_stop_no_shell_v9",
            swiftPackageDescribeExecutableIdentityAuthority:
                "frozen_regular_file_full_file_sha256_byte_count_root_owner_mode_link_no_symlink_any_cloexec_and_live_mapped_vnode_descriptor_join_v2",
            swiftPackageDescribeExpectedExecutableSHA256:
                "dc1a5f5bd4f05be81b8cc4a4bc6e0fd8846210e4cb829062d0fed3d03f79b753",
            swiftPackageDescribeExpectedExecutableByteCount:
                23_293_616,
            swiftPackageDescribeExpectedExecutableOwnerUserID:
                0,
            swiftPackageDescribeExpectedExecutableOwnerGroupID:
                0,
            swiftPackageDescribeExpectedExecutablePermissionMode:
                0o755,
            swiftPackageDescribeExpectedExecutableLinkCount:
                1,
            swiftPackageDescribeCaptureRecordRelativePaths: [
                "neural-gate-replay/source/probe-swift-package-describe-capture.v4.json",
                "neural-gate-replay/source/verifier-swift-package-describe-capture.v4.json",
            ],
            swiftPackageDescribeArgumentTemplate: [
                "--scratch-path",
                "{scratch_root}/work",
                "--cache-path",
                "{scratch_root}/cache",
                "--config-path",
                "{scratch_root}/config",
                "--security-path",
                "{scratch_root}/security",
                "--disable-dependency-cache",
                "--manifest-cache",
                "none",
                "--disable-prefetching",
                "--disable-automatic-resolution",
                "--disable-netrc",
                "--disable-keychain",
                "describe",
                "--type",
                "json",
            ],
            swiftPackageDescribeExactEnvironmentKeys: [
                "HOME",
                "TMPDIR",
                "CLANG_MODULE_CACHE_PATH",
                "SWIFT_MODULECACHE_PATH",
            ],
            swiftPackageDescribeEnvironmentPolicy:
                "exact_noninherited_home_tmpdir_clang_module_cache_path_swift_modulecache_path_inside_fresh_run_root_v1",
            swiftPackageDescribeScratchNamespacePolicy:
                "darwin_confstr_user_temp_fresh_per_role_atomic_0700_held_nofollow_cloexec_exact_source_local_apfs_fsid_kqueue_destructive_notes_path_rejoin_acl_absent_optional_exact_text_encoding_work_lock_regular_file_utf8_134217984_15_bytes_fixed_16_byte_descriptor_read_provenance_opaque_descriptor_read_max_4096_unknown_xattr_reject_bounded_post_audit_no_recursive_cleanup_v2",
            swiftPackageDescribeNetworkDenialEstablished:
                false,
            swiftPackageDescribeDependencyResolutionPermitted:
                false,
            swiftPackageDescribeResolutionResiduesForbidden:
                true,
            swiftPackageDescribeMaximumWallSeconds:
                60,
            swiftPackageDescribeMaximumStandardOutputBytes:
                16_777_216,
            swiftPackageDescribeMaximumStandardErrorBytes:
                1_048_576,
            swiftPackageDescribeTerminationEscalationPolicy:
                "direct_pid_sigkill_before_session_join_then_dedicated_group_sigterm_wait_2s_sigkill_once_observed_death_or_bounded_exact_pid_wnohang_exact_once_reap_no_post_reap_signal_uncontained_fail_stop_v4",
            swiftPackageDescribeIsolatedSessionRequired:
                true,
            swiftPackageDescribeDedicatedProcessGroupRequired:
                true,
            swiftPackageDescribeGroupDirectedTerminationSignalsRequired:
                true,
            swiftPackageDescribeNormalizedSignalMaskRequired:
                true,
            swiftPackageDescribeNormalizedSignalDispositionsRequired:
                true,
            swiftPackageDescribeProcessGroupEmptyAfterReapRequired:
                true,
            swiftPackageDescribeDescriptorRootedWorkingDirectoryRequired:
                true,
            swiftPackageDescribeSuspendedChildWorkingDirectoryVnodeJoinRequired:
                true,
            swiftPackageDescribeSourceMutationGuardRequired:
                true,
            swiftPackageDescribeSourceMutationGuardAuthority:
                "primecore_held_descriptor_source_closure_kqueue_vnode_receipts_exact_inventories_bytes_fstat_path_rejoin_zero_events_initial_pre_resume_post_reap_v1",
            swiftPackageDescribeSourceAdmissionMaximumSeconds:
                30,
            swiftPackageDescribeSourceLocalFilesystemRequired:
                true,
            swiftPackageDescribeSourceFilesystemType:
                "apfs",
            swiftPackageDescribeOutputOverflowRejected:
                true,
            swiftPackageDescribeChildDeathObservedBeforeContinuationRequired:
                true,
            swiftPackageDescribeChildReapBeforeContinuationRequired:
                true,
            swiftPackageDescribeCaptureImplementationRequiredBeforeExecution:
                true,
            swiftPackageDescribeOutputAcceptedWithoutValidatedCapture:
                false,
            swiftPackageDescribeMappedChildImageCaptureRequired:
                true,
            swiftPackageDescribeMappedChildImageCaptureAuthority:
                "primecore_trusted_external_child_descriptor_open_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_query_transcript_mapped_vnode_join_pre_resume_stability_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_post_reap_stability_v6",
            swiftPackageDescribeMappedRegionEnumerationPolicy:
                "proc_pidregionpathinfo_full_query_transcript_address_plus_size_progression_terminal_zero_errno_einval_nonprogress_overflow_other_error_fail_closed_v3",
            swiftPackageDescribeMappedRegionTerminalErrno:
                22,
            swiftPackageDescribeCaptureCapabilityCalibrationRequired:
                true,
            swiftPackageDescribeCaptureCapabilityCalibrationPolicy:
                "runtime_constants_struct_sizes_same_child_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_transcript_terminal_errno_einval_22_descriptor_join_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_no_escalation_v6",
            swiftPackageDescribeTrustedCaptureCapabilityRequired:
                true,
            swiftPackageDescribeTrustedCaptureCapabilityAuthority:
                "primecore_non_codable_factory_result_binding_role_exact_launch_arguments_and_environment_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_three_descriptor_read_checkpoints_fstat_source_snapshot_held_source_closure_mutation_guard_direct_pid_to_isolated_session_process_group_authority_working_root_region_transcript_pre_reap_group_members_exact_once_waitpid_and_eof_stream_lifecycle_v8",
            swiftPackageDescribeExactPIDWaitObservationRequired:
                true,
            swiftPackageDescribeProcPIDPathAuthoritative:
                false,
            swiftPackageDescribeDirectExecutableLeafName:
                "swift-package",
            swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor:
                true,
            swiftPackageDescribeLaunchPathAloneAuthoritative:
                false,
            sourceSnapshotIdentityEqualsEmbeddedIdentity:
                true,
            processIdentityEqualsSnapshotIdentity:
                true,
            processSnapshotBindingEqualsClosureSnapshotBinding:
                true,
            packageManifestIdentityRequired: true,
            exactAuthorityTargetSubgraphRequired:
                true,
            cleanPrimeGitStateRequired: true,
            primeGitStateAndSourceEqualPrePostAndAcrossProcesses:
                true,
            runningExecutableBindingFromSameProcess:
                true,
            probeVerifierProcessIDsDistinct: true,
            probeVerifierTargetNamesDistinct: true,
            probeVerifierExecutablePathsDistinct:
                true,
            probeVerifierExecutableSHA256Distinct:
                true,
            candidateBindsProbeProcessRecord: true,
            receiptBindsVerifierProcessRecord: true,
            verifierRecomputesProbeBindings: true,
            reproducibleBuildProvenanceClaimed:
                false
        )
    }()

    func expandedSwiftPackageDescribeArguments(
        scratchRootAbsolutePath: String
    ) throws -> [String] {
        try validateScratchRootTemplateInput(
            scratchRootAbsolutePath
        )
        let expanded =
            swiftPackageDescribeArgumentTemplate
            .map {
                $0.replacingOccurrences(
                    of: "{scratch_root}",
                    with:
                        scratchRootAbsolutePath
                )
            }
        guard expanded
                == [
                    "--scratch-path",
                    scratchRootAbsolutePath
                        + "/work",
                    "--cache-path",
                    scratchRootAbsolutePath
                        + "/cache",
                    "--config-path",
                    scratchRootAbsolutePath
                        + "/config",
                    "--security-path",
                    scratchRootAbsolutePath
                        + "/security",
                    "--disable-dependency-cache",
                    "--manifest-cache",
                    "none",
                    "--disable-prefetching",
                    "--disable-automatic-resolution",
                    "--disable-netrc",
                    "--disable-keychain",
                    "describe",
                    "--type",
                    "json",
                ],
              !expanded.contains(where: {
                  $0.contains("{")
                      || $0.contains("}")
                      || $0.contains("\0")
              }),
              !expanded.contains(
                  "--skip-update"
              ),
              !expanded.contains(
                  "--disable-sandbox"
              )
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_argument_expansion"
                )
        }
        return expanded
    }

    func expandedSwiftPackageDescribeEnvironment(
        scratchRootAbsolutePath: String
    ) throws -> [String: String] {
        try validateScratchRootTemplateInput(
            scratchRootAbsolutePath
        )
        let environment = [
            "HOME":
                scratchRootAbsolutePath
                + "/home",
            "TMPDIR":
                scratchRootAbsolutePath
                + "/tmp",
            "CLANG_MODULE_CACHE_PATH":
                scratchRootAbsolutePath
                + "/module-cache",
            "SWIFT_MODULECACHE_PATH":
                scratchRootAbsolutePath
                + "/module-cache",
        ]
        guard swiftPackageDescribeExactEnvironmentKeys
                == [
                    "HOME",
                    "TMPDIR",
                    "CLANG_MODULE_CACHE_PATH",
                    "SWIFT_MODULECACHE_PATH",
                ],
              Set(environment.keys)
                == Set(
                    swiftPackageDescribeExactEnvironmentKeys
                ),
              environment.values
                .allSatisfy({
                    $0.hasPrefix(
                        scratchRootAbsolutePath
                        + "/"
                    )
                        && !$0.contains("\0")
                })
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_environment_expansion"
                )
        }
        return environment
    }

    private func validateScratchRootTemplateInput(
        _ path: String
    ) throws {
        guard path.hasPrefix("/"),
              path != "/",
              !path.contains("\0"),
              !path.hasSuffix("/"),
              path.split(
                  separator: "/",
                  omittingEmptySubsequences:
                    true
              ).allSatisfy({
                  $0 != "."
                      && $0 != ".."
              })
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_scratch_root"
                )
        }
    }

    public func validate() throws {
        let targets =
            targetClosureRules.map(\.targetName)
        let roles = processBindingRules.map(\.role)
        let targetSet = Set(targets)
        let dependencies = Dictionary(
            uniqueKeysWithValues:
                targetClosureRules.map {
                    (
                        $0.targetName,
                        $0.directLocalDependencyNames
                    )
                }
        )
        func transitiveTargets(
            for target: String
        ) -> Set<String>? {
            var visited = Set<String>()
            var active = Set<String>()
            func visit(_ current: String) -> Bool {
                guard let direct =
                        dependencies[current]
                else {
                    return false
                }
                if visited.contains(current) {
                    return true
                }
                guard active.insert(current)
                    .inserted
                else {
                    return false
                }
                guard direct.allSatisfy(visit) else {
                    return false
                }
                active.remove(current)
                visited.insert(current)
                return true
            }
            return visit(target) ? visited : nil
        }
        let processClosuresExact =
            processBindingRules.allSatisfy {
                guard let reachable =
                        transitiveTargets(
                            for:
                                $0.executableTargetName
                        )
                else {
                    return false
                }
                return $0
                    .exactTransitiveLocalTargetNames
                    == targetClosureRules
                    .map(\.targetName)
                    .filter(reachable.contains)
            }
        guard self == .frozenV3,
              Self.isSafeRelativePath(
                  packageManifestRelativePath
              ),
              Self.isSafeRelativePath(
                  sourceSnapshotRelativePath
              ),
              Self.isSafeRelativePath(
                  swiftPackageDescribeRelativePath
              ),
              Self.isSafeRelativePath(
                  compiledSourceClosureRelativePath
              ),
              targets.count == 10,
              targetSet.count == targets.count,
              roles
                == PrimeNativeNeuralGateReleaseProcessRole
                .allCases,
              targetClosureRules.allSatisfy({
                  $0.sourceDirectoryRelativePath
                          == "Sources/\($0.targetName)"
                      && Self.isSafeRelativePath(
                          $0.sourceDirectoryRelativePath
                      )
                      && $0
                      .completeSortedSwiftFileEnumerationRequired
                      && $0
                      .fileIdentitiesDerivedOnlyFromSourceSnapshot
                      && Set(
                          $0.directLocalDependencyNames
                      ).count
                          == $0
                          .directLocalDependencyNames.count
                      && $0.directLocalDependencyNames
                          .allSatisfy(targetSet.contains)
              }),
              processBindingRules.allSatisfy({
                  targetSet.contains(
                      $0.executableTargetName
                  )
                      && Self.isSafeRelativePath(
                          $0.runningExecutableRelativePath
                      )
                      && Self.isSafeRelativePath(
                          $0.executableBindingRelativePath
                      )
                      && Set(
                          $0
                          .exactTransitiveLocalTargetNames
                      ).count
                          == $0
                          .exactTransitiveLocalTargetNames
                          .count
                      && $0
                      .exactTransitiveLocalTargetNames
                      .allSatisfy(targetSet.contains)
                      && $0
                      .positiveProcessIdentifierRequired
                      && $0
                      .recomputeSourceSnapshotAndClosure
              }),
              processClosuresExact,
              requiredBuildConfiguration == "release",
              swiftPackageDescribeCapturePolicy
                == "direct_swift_package_executable_describe_type_json_exact_noninherited_scratch_environment_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_local_apfs_bounded_source_admission_held_source_closure_kqueue_guard_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_full_region_transcript_descriptor_join_trusted_capture_bounded_output_exact_once_wait_bounded_wnohang_no_post_reap_signal_uncontained_fail_stop_no_shell_v9",
              swiftPackageDescribeExecutableIdentityAuthority
                == "frozen_regular_file_full_file_sha256_byte_count_root_owner_mode_link_no_symlink_any_cloexec_and_live_mapped_vnode_descriptor_join_v2",
              swiftPackageDescribeExpectedExecutableSHA256
                == "dc1a5f5bd4f05be81b8cc4a4bc6e0fd8846210e4cb829062d0fed3d03f79b753",
              swiftPackageDescribeExpectedExecutableByteCount
                == 23_293_616,
              swiftPackageDescribeExpectedExecutableOwnerUserID
                == 0,
              swiftPackageDescribeExpectedExecutableOwnerGroupID
                == 0,
              swiftPackageDescribeExpectedExecutablePermissionMode
                == 0o755,
              swiftPackageDescribeExpectedExecutableLinkCount
                == 1,
              sourceSnapshotIdentityEqualsEmbeddedIdentity,
              processIdentityEqualsSnapshotIdentity,
              processSnapshotBindingEqualsClosureSnapshotBinding,
              packageManifestIdentityRequired,
              exactAuthorityTargetSubgraphRequired,
              swiftPackageDescribeCaptureRecordRelativePaths
                .count
                == PrimeNativeNeuralGateReleaseProcessRole
                .allCases.count,
              Set(
                  swiftPackageDescribeCaptureRecordRelativePaths
              ).count
                == swiftPackageDescribeCaptureRecordRelativePaths
                .count,
              swiftPackageDescribeCaptureRecordRelativePaths
                .allSatisfy(Self.isSafeRelativePath),
              swiftPackageDescribeArgumentTemplate
                == [
                    "--scratch-path",
                    "{scratch_root}/work",
                    "--cache-path",
                    "{scratch_root}/cache",
                    "--config-path",
                    "{scratch_root}/config",
                    "--security-path",
                    "{scratch_root}/security",
                    "--disable-dependency-cache",
                    "--manifest-cache",
                    "none",
                    "--disable-prefetching",
                    "--disable-automatic-resolution",
                    "--disable-netrc",
                    "--disable-keychain",
                    "describe",
                    "--type",
                    "json",
                ],
              swiftPackageDescribeExactEnvironmentKeys
                == [
                    "HOME",
                    "TMPDIR",
                    "CLANG_MODULE_CACHE_PATH",
                    "SWIFT_MODULECACHE_PATH",
                ],
              swiftPackageDescribeEnvironmentPolicy
                == "exact_noninherited_home_tmpdir_clang_module_cache_path_swift_modulecache_path_inside_fresh_run_root_v1",
              swiftPackageDescribeScratchNamespacePolicy
                == "darwin_confstr_user_temp_fresh_per_role_atomic_0700_held_nofollow_cloexec_exact_source_local_apfs_fsid_kqueue_destructive_notes_path_rejoin_acl_absent_optional_exact_text_encoding_work_lock_regular_file_utf8_134217984_15_bytes_fixed_16_byte_descriptor_read_provenance_opaque_descriptor_read_max_4096_unknown_xattr_reject_bounded_post_audit_no_recursive_cleanup_v2",
              !swiftPackageDescribeNetworkDenialEstablished,
              !swiftPackageDescribeDependencyResolutionPermitted,
              swiftPackageDescribeResolutionResiduesForbidden,
              !swiftPackageDescribeArgumentTemplate
                .contains("--skip-update"),
              !swiftPackageDescribeArgumentTemplate
                .contains("--disable-sandbox"),
              swiftPackageDescribeMaximumWallSeconds
                == 60,
              swiftPackageDescribeMaximumStandardOutputBytes
                == 16_777_216,
              swiftPackageDescribeMaximumStandardErrorBytes
                == 1_048_576,
              swiftPackageDescribeTerminationEscalationPolicy
                == "direct_pid_sigkill_before_session_join_then_dedicated_group_sigterm_wait_2s_sigkill_once_observed_death_or_bounded_exact_pid_wnohang_exact_once_reap_no_post_reap_signal_uncontained_fail_stop_v4",
              swiftPackageDescribeIsolatedSessionRequired,
              swiftPackageDescribeDedicatedProcessGroupRequired,
              swiftPackageDescribeGroupDirectedTerminationSignalsRequired,
              swiftPackageDescribeNormalizedSignalMaskRequired,
              swiftPackageDescribeNormalizedSignalDispositionsRequired,
              swiftPackageDescribeProcessGroupEmptyAfterReapRequired,
              swiftPackageDescribeDescriptorRootedWorkingDirectoryRequired,
              swiftPackageDescribeSuspendedChildWorkingDirectoryVnodeJoinRequired,
              swiftPackageDescribeSourceMutationGuardRequired,
              swiftPackageDescribeSourceMutationGuardAuthority
                == "primecore_held_descriptor_source_closure_kqueue_vnode_receipts_exact_inventories_bytes_fstat_path_rejoin_zero_events_initial_pre_resume_post_reap_v1",
              swiftPackageDescribeSourceAdmissionMaximumSeconds
                == 30,
              swiftPackageDescribeSourceLocalFilesystemRequired,
              swiftPackageDescribeSourceFilesystemType
                == "apfs",
              swiftPackageDescribeOutputOverflowRejected,
              swiftPackageDescribeChildDeathObservedBeforeContinuationRequired,
              swiftPackageDescribeChildReapBeforeContinuationRequired,
              swiftPackageDescribeCaptureImplementationRequiredBeforeExecution,
              !swiftPackageDescribeOutputAcceptedWithoutValidatedCapture,
              swiftPackageDescribeMappedChildImageCaptureRequired,
              swiftPackageDescribeMappedChildImageCaptureAuthority
                == "primecore_trusted_external_child_descriptor_open_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_query_transcript_mapped_vnode_join_pre_resume_stability_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_post_reap_stability_v6",
              swiftPackageDescribeMappedRegionEnumerationPolicy
                == "proc_pidregionpathinfo_full_query_transcript_address_plus_size_progression_terminal_zero_errno_einval_nonprogress_overflow_other_error_fail_closed_v3",
              swiftPackageDescribeMappedRegionTerminalErrno
                == 22,
              swiftPackageDescribeCaptureCapabilityCalibrationRequired,
              swiftPackageDescribeCaptureCapabilityCalibrationPolicy
                == "runtime_constants_struct_sizes_same_child_normalized_signals_start_suspended_direct_pid_until_sid_pgid_join_isolated_session_dedicated_process_group_descriptor_rooted_cwd_vnode_join_full_region_transcript_terminal_errno_einval_22_descriptor_join_sigcont_pre_reap_exact_group_members_exact_once_pid_wait_reap_group_empty_no_escalation_v6",
              swiftPackageDescribeTrustedCaptureCapabilityRequired,
              swiftPackageDescribeTrustedCaptureCapabilityAuthority
                == "primecore_non_codable_factory_result_binding_role_exact_launch_arguments_and_environment_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_three_descriptor_read_checkpoints_fstat_source_snapshot_held_source_closure_mutation_guard_direct_pid_to_isolated_session_process_group_authority_working_root_region_transcript_pre_reap_group_members_exact_once_waitpid_and_eof_stream_lifecycle_v8",
              swiftPackageDescribeExactPIDWaitObservationRequired,
              !swiftPackageDescribeProcPIDPathAuthoritative,
              swiftPackageDescribeDirectExecutableLeafName
                == "swift-package",
              swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor,
              !swiftPackageDescribeLaunchPathAloneAuthoritative,
              cleanPrimeGitStateRequired,
              primeGitStateAndSourceEqualPrePostAndAcrossProcesses,
              runningExecutableBindingFromSameProcess,
              probeVerifierProcessIDsDistinct,
              probeVerifierTargetNamesDistinct,
              probeVerifierExecutablePathsDistinct,
              probeVerifierExecutableSHA256Distinct,
              candidateBindsProbeProcessRecord,
              receiptBindsVerifierProcessRecord,
              verifierRecomputesProbeBindings,
              !reproducibleBuildProvenanceClaimed
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "source_execution_binding"
                )
        }
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        !path.hasPrefix("/")
            && !path.contains("\0")
            && path.split(
                separator: "/",
                omittingEmptySubsequences: false
            ).allSatisfy {
                !$0.isEmpty
                    && $0 != "."
                    && $0 != ".."
                    && $0 != ".git"
            }
    }

    public func swiftPackageDescribeCaptureRecordRelativePath(
        for role:
            PrimeNativeNeuralGateReleaseProcessRole
    ) -> String {
        switch role {
        case .probe:
            swiftPackageDescribeCaptureRecordRelativePaths[
                0
            ]
        case .verifier:
            swiftPackageDescribeCaptureRecordRelativePaths[
                1
            ]
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case packageManifestRelativePath =
            "package_manifest_relative_path"
        case sourceSnapshotRelativePath =
            "source_snapshot_relative_path"
        case swiftPackageDescribeRelativePath =
            "swift_package_describe_relative_path"
        case compiledSourceClosureRelativePath =
            "compiled_source_closure_relative_path"
        case targetClosureRules =
            "target_closure_rules"
        case processBindingRules =
            "process_binding_rules"
        case requiredBuildConfiguration =
            "required_build_configuration"
        case embeddedSourceIdentityAuthority =
            "embedded_source_identity_authority"
        case runningExecutableCaptureAuthority =
            "running_executable_capture_authority"
        case swiftPackageDescribeCapturePolicy =
            "swift_package_describe_capture_policy"
        case swiftPackageDescribeExecutableIdentityAuthority =
            "swift_package_describe_executable_identity_authority"
        case swiftPackageDescribeExpectedExecutableSHA256 =
            "swift_package_describe_expected_executable_sha256"
        case swiftPackageDescribeExpectedExecutableByteCount =
            "swift_package_describe_expected_executable_byte_count"
        case swiftPackageDescribeExpectedExecutableOwnerUserID =
            "swift_package_describe_expected_executable_owner_user_id"
        case swiftPackageDescribeExpectedExecutableOwnerGroupID =
            "swift_package_describe_expected_executable_owner_group_id"
        case swiftPackageDescribeExpectedExecutablePermissionMode =
            "swift_package_describe_expected_executable_permission_mode"
        case swiftPackageDescribeExpectedExecutableLinkCount =
            "swift_package_describe_expected_executable_link_count"
        case swiftPackageDescribeCaptureRecordRelativePaths =
            "swift_package_describe_capture_record_relative_paths"
        case swiftPackageDescribeArgumentTemplate =
            "swift_package_describe_argument_template"
        case swiftPackageDescribeExactEnvironmentKeys =
            "swift_package_describe_exact_environment_keys"
        case swiftPackageDescribeEnvironmentPolicy =
            "swift_package_describe_environment_policy"
        case swiftPackageDescribeScratchNamespacePolicy =
            "swift_package_describe_scratch_namespace_policy"
        case swiftPackageDescribeNetworkDenialEstablished =
            "swift_package_describe_network_denial_established"
        case swiftPackageDescribeDependencyResolutionPermitted =
            "swift_package_describe_dependency_resolution_permitted"
        case swiftPackageDescribeResolutionResiduesForbidden =
            "swift_package_describe_resolution_residues_forbidden"
        case swiftPackageDescribeMaximumWallSeconds =
            "swift_package_describe_maximum_wall_seconds"
        case swiftPackageDescribeMaximumStandardOutputBytes =
            "swift_package_describe_maximum_standard_output_bytes"
        case swiftPackageDescribeMaximumStandardErrorBytes =
            "swift_package_describe_maximum_standard_error_bytes"
        case swiftPackageDescribeTerminationEscalationPolicy =
            "swift_package_describe_termination_escalation_policy"
        case swiftPackageDescribeIsolatedSessionRequired =
            "swift_package_describe_isolated_session_required"
        case swiftPackageDescribeDedicatedProcessGroupRequired =
            "swift_package_describe_dedicated_process_group_required"
        case swiftPackageDescribeGroupDirectedTerminationSignalsRequired =
            "swift_package_describe_group_directed_termination_signals_required"
        case swiftPackageDescribeNormalizedSignalMaskRequired =
            "swift_package_describe_normalized_signal_mask_required"
        case swiftPackageDescribeNormalizedSignalDispositionsRequired =
            "swift_package_describe_normalized_signal_dispositions_required"
        case swiftPackageDescribeProcessGroupEmptyAfterReapRequired =
            "swift_package_describe_process_group_empty_after_reap_required"
        case swiftPackageDescribeDescriptorRootedWorkingDirectoryRequired =
            "swift_package_describe_descriptor_rooted_working_directory_required"
        case swiftPackageDescribeSuspendedChildWorkingDirectoryVnodeJoinRequired =
            "swift_package_describe_suspended_child_working_directory_vnode_join_required"
        case swiftPackageDescribeSourceMutationGuardRequired =
            "swift_package_describe_source_mutation_guard_required"
        case swiftPackageDescribeSourceMutationGuardAuthority =
            "swift_package_describe_source_mutation_guard_authority"
        case swiftPackageDescribeSourceAdmissionMaximumSeconds =
            "swift_package_describe_source_admission_maximum_seconds"
        case swiftPackageDescribeSourceLocalFilesystemRequired =
            "swift_package_describe_source_local_filesystem_required"
        case swiftPackageDescribeSourceFilesystemType =
            "swift_package_describe_source_filesystem_type"
        case swiftPackageDescribeOutputOverflowRejected =
            "swift_package_describe_output_overflow_rejected"
        case swiftPackageDescribeChildDeathObservedBeforeContinuationRequired =
            "swift_package_describe_child_death_observed_before_continuation_required"
        case swiftPackageDescribeChildReapBeforeContinuationRequired =
            "swift_package_describe_child_reap_before_continuation_required"
        case swiftPackageDescribeCaptureImplementationRequiredBeforeExecution =
            "swift_package_describe_capture_implementation_required_before_execution"
        case swiftPackageDescribeOutputAcceptedWithoutValidatedCapture =
            "swift_package_describe_output_accepted_without_validated_capture"
        case swiftPackageDescribeMappedChildImageCaptureRequired =
            "swift_package_describe_mapped_child_image_capture_required"
        case swiftPackageDescribeMappedChildImageCaptureAuthority =
            "swift_package_describe_mapped_child_image_capture_authority"
        case swiftPackageDescribeMappedRegionEnumerationPolicy =
            "swift_package_describe_mapped_region_enumeration_policy"
        case swiftPackageDescribeMappedRegionTerminalErrno =
            "swift_package_describe_mapped_region_terminal_errno"
        case swiftPackageDescribeCaptureCapabilityCalibrationRequired =
            "swift_package_describe_capture_capability_calibration_required"
        case swiftPackageDescribeCaptureCapabilityCalibrationPolicy =
            "swift_package_describe_capture_capability_calibration_policy"
        case swiftPackageDescribeTrustedCaptureCapabilityRequired =
            "swift_package_describe_trusted_capture_capability_required"
        case swiftPackageDescribeTrustedCaptureCapabilityAuthority =
            "swift_package_describe_trusted_capture_capability_authority"
        case swiftPackageDescribeExactPIDWaitObservationRequired =
            "swift_package_describe_exact_pid_wait_observation_required"
        case swiftPackageDescribeProcPIDPathAuthoritative =
            "swift_package_describe_proc_pidpath_authoritative"
        case swiftPackageDescribeDirectExecutableLeafName =
            "swift_package_describe_direct_executable_leaf_name"
        case swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor =
            "swift_package_describe_initial_mapped_image_must_equal_launch_descriptor"
        case swiftPackageDescribeLaunchPathAloneAuthoritative =
            "swift_package_describe_launch_path_alone_authoritative"
        case sourceSnapshotIdentityEqualsEmbeddedIdentity =
            "source_snapshot_identity_equals_embedded_identity"
        case processIdentityEqualsSnapshotIdentity =
            "process_identity_equals_snapshot_identity"
        case processSnapshotBindingEqualsClosureSnapshotBinding =
            "process_snapshot_binding_equals_closure_snapshot_binding"
        case packageManifestIdentityRequired =
            "package_manifest_identity_required"
        case exactAuthorityTargetSubgraphRequired =
            "exact_authority_target_subgraph_required"
        case cleanPrimeGitStateRequired =
            "clean_prime_git_state_required"
        case primeGitStateAndSourceEqualPrePostAndAcrossProcesses =
            "prime_git_state_and_source_equal_pre_post_and_across_processes"
        case runningExecutableBindingFromSameProcess =
            "running_executable_binding_from_same_process"
        case probeVerifierProcessIDsDistinct =
            "probe_verifier_process_ids_distinct"
        case probeVerifierTargetNamesDistinct =
            "probe_verifier_target_names_distinct"
        case probeVerifierExecutablePathsDistinct =
            "probe_verifier_executable_paths_distinct"
        case probeVerifierExecutableSHA256Distinct =
            "probe_verifier_executable_sha256_distinct"
        case candidateBindsProbeProcessRecord =
            "candidate_binds_probe_process_record"
        case receiptBindsVerifierProcessRecord =
            "receipt_binds_verifier_process_record"
        case verifierRecomputesProbeBindings =
            "verifier_recomputes_probe_bindings"
        case reproducibleBuildProvenanceClaimed =
            "reproducible_build_provenance_claimed"
    }
}

public struct PrimeNativeNeuralGateSourceFileIdentity:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64

    public init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }

    public init(
        snapshot:
            PrimeSwiftSourceFileSnapshot
    ) {
        self.init(
            relativePath: snapshot.relativePath,
            sha256: snapshot.sha256,
            byteCount: snapshot.byteCount
        )
    }

    fileprivate func validate() throws {
        guard Self.isSafeRelativePath(
                  relativePath
              ),
              Self.isLowercaseSHA256(sha256)
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "source_file_identity"
                )
        }
    }

    fileprivate static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    fileprivate static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        !path.hasPrefix("/")
            && !path.contains("\0")
            && path.split(
                separator: "/",
                omittingEmptySubsequences: false
            ).allSatisfy {
                !$0.isEmpty
                    && $0 != "."
                    && $0 != ".."
                    && $0 != ".git"
            }
    }

    fileprivate static func rawUTF8Less(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        Data(lhs.utf8).lexicographicallyPrecedes(
            Data(rhs.utf8)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

public struct PrimeNativeNeuralGateCompiledTargetSourceClosureRecord:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let sourceDirectoryRelativePath:
        String
    public let directLocalDependencyNames:
        [String]
    public let sourceFiles:
        [PrimeNativeNeuralGateSourceFileIdentity]

    public init(
        targetName: String,
        sourceDirectoryRelativePath: String,
        directLocalDependencyNames: [String],
        sourceFiles:
            [PrimeNativeNeuralGateSourceFileIdentity]
    ) {
        self.targetName = targetName
        self.sourceDirectoryRelativePath =
            sourceDirectoryRelativePath
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.sourceFiles = sourceFiles
    }

    public init(
        rule:
            PrimeNativeNeuralGateTargetSourceClosureRule,
        snapshot: PrimeSwiftSourceSnapshot
    ) {
        targetName = rule.targetName
        sourceDirectoryRelativePath =
            rule.sourceDirectoryRelativePath
        directLocalDependencyNames =
            rule.directLocalDependencyNames
        sourceFiles = snapshot.files
            .filter {
                $0.relativePath.hasPrefix(
                    rule.sourceDirectoryRelativePath
                        + "/"
                )
                    && $0.relativePath
                    .hasSuffix(".swift")
            }
            .map(
                PrimeNativeNeuralGateSourceFileIdentity
                    .init(snapshot:)
            )
            .sorted {
                PrimeNativeNeuralGateSourceFileIdentity
                    .rawUTF8Less(
                        $0.relativePath,
                        $1.relativePath
                    )
            }
    }

    fileprivate func validate(
        against rule:
            PrimeNativeNeuralGateTargetSourceClosureRule,
        snapshot: PrimeSwiftSourceSnapshot
    ) throws {
        let expected = Self(
            rule: rule,
            snapshot: snapshot
        )
        try sourceFiles.forEach {
            try $0.validate()
        }
        guard self == expected,
              !sourceFiles.isEmpty,
              sourceFiles.map(\.relativePath)
                == sourceFiles.map(\.relativePath)
                .sorted(
                    by:
                        PrimeNativeNeuralGateSourceFileIdentity
                        .rawUTF8Less
                ),
              Set(sourceFiles.map(\.relativePath))
                .count == sourceFiles.count
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "compiled_target_source_closure"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case sourceDirectoryRelativePath =
            "source_directory_relative_path"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case sourceFiles = "source_files"
    }
}

public struct PrimeNativeNeuralGateCompiledSourceClosureRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let planSHA256: String
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let swiftPackageDescribe:
        PrimeArtifactBinding
    public let packageManifest:
        PrimeNativeNeuralGateSourceFileIdentity
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256:
        String
    public let buildConfiguration: String
    public let targets:
        [PrimeNativeNeuralGateCompiledTargetSourceClosureRecord]

    public init(
        planSHA256: String,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        swiftPackageDescribe:
            PrimeArtifactBinding,
        packageManifest:
            PrimeNativeNeuralGateSourceFileIdentity,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256:
            String,
        buildConfiguration: String,
        targets:
            [PrimeNativeNeuralGateCompiledTargetSourceClosureRecord]
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_compiled_source_closure"
        self.planSHA256 = planSHA256
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.swiftPackageDescribe =
            swiftPackageDescribe
        self.packageManifest =
            packageManifest
        self.sourceIdentitySHA256 =
            sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.buildConfiguration =
            buildConfiguration
        self.targets = targets
    }

    public func validateForRunningRelease(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedPlanSHA256: String,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data
    ) throws {
        guard PrimeEmbeddedBuildProvenance
                .buildConfiguration == "release"
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "compiled_source_closure_running_configuration"
                )
        }
        try validate(
            against: contract,
            expectedPlanSHA256:
                expectedPlanSHA256,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            expectedEmbeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256
        )
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedPlanSHA256: String,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        expectedEmbeddedSourceIdentitySHA256:
            String
    ) throws {
        try contract.validate()
        try packageManifest.validate()
        try primeSourceSnapshot
            .validateDeclaration()
        try swiftPackageDescribe
            .validateDeclaration()
        let snapshotData =
            try PrimeCanonicalJSON.encode(snapshot)
        let packageFiles =
            snapshot.files.filter {
                $0.relativePath
                    == contract
                    .packageManifestRelativePath
            }
        let requiredSourcePaths = Set(
            targets.flatMap(\.sourceFiles)
                .map(\.relativePath)
        )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                requiredSourcePaths,
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256:
                        expectedEmbeddedSourceIdentitySHA256,
                    buildConfiguration:
                        contract
                        .requiredBuildConfiguration
                )
        )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_compiled_source_closure",
              PrimeNativeNeuralGateSourceFileIdentity
                .isLowercaseSHA256(
                    expectedPlanSHA256
                ),
              planSHA256
                == expectedPlanSHA256,
              primeSourceSnapshot.relativePath
                == contract
                .sourceSnapshotRelativePath,
              primeSourceSnapshot.purpose
                == .immutableData,
              primeSourceSnapshot.byteCount
                == UInt64(snapshotData.count),
              primeSourceSnapshot.sha256
                == PrimeSHA256.hexDigest(
                    of: snapshotData
                ),
              swiftPackageDescribe.relativePath
                == contract
                .swiftPackageDescribeRelativePath,
              swiftPackageDescribe.purpose
                == .immutableData,
              swiftPackageDescribe.byteCount
                == UInt64(
                    swiftPackageDescribeData.count
                ),
              swiftPackageDescribe.sha256
                == PrimeSHA256.hexDigest(
                    of: swiftPackageDescribeData
                ),
              packageFiles.count == 1,
              packageManifest
                == PrimeNativeNeuralGateSourceFileIdentity(
                    snapshot: packageFiles[0]
                ),
              sourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              embeddedSourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              snapshot.sourceIdentitySHA256
                == sourceIdentitySHA256,
              snapshot
                .embeddedSourceIdentitySHA256
                == embeddedSourceIdentitySHA256,
              buildConfiguration
                == contract
                .requiredBuildConfiguration,
              snapshot.buildConfiguration
                == buildConfiguration,
              targets.count
                == contract
                .targetClosureRules.count,
              zip(
                  targets,
                  contract.targetClosureRules
              ).allSatisfy({
                  target, rule in
                  target.targetName
                      == rule.targetName
              })
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "compiled_source_closure"
                )
        }
        try zip(
            targets,
            contract.targetClosureRules
        ).forEach {
            try $0.0.validate(
                against: $0.1,
                snapshot: snapshot
            )
        }
        try validateSwiftPackageDescribe(
            swiftPackageDescribeData,
            contract: contract
        )
    }

    private func validateSwiftPackageDescribe(
        _ data: Data,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws {
        guard let root =
                try JSONSerialization.jsonObject(
                    with: data
                ) as? [String: Any],
              let describedTargets =
                root["targets"]
                as? [[String: Any]]
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_json"
                )
        }
        for (
            target,
            rule
        ) in zip(
            targets,
            contract.targetClosureRules
        ) {
            let matches =
                describedTargets.filter {
                    $0["name"] as? String
                        == target.targetName
                }
            guard matches.count == 1,
                  let path =
                    matches[0]["path"]
                        as? String,
                  let dependencies =
                    matches[0][
                        "target_dependencies"
                    ] as? [String],
                  let sources =
                    matches[0]["sources"]
                        as? [String],
                  let targetType =
                    matches[0]["type"]
                        as? String
            else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "swift_package_describe_target"
                    )
            }
            let rawProductDependencies =
                matches[0][
                    "product_dependencies"
                ]
            guard rawProductDependencies == nil
                    || rawProductDependencies
                    is [String]
            else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "swift_package_describe_product_dependencies"
                    )
            }
            let productDependencies =
                rawProductDependencies as? [String]
                    ?? []
            let expectedSources =
                target.sourceFiles.map {
                    String(
                        $0.relativePath.dropFirst(
                            rule
                                .sourceDirectoryRelativePath
                                .count + 1
                        )
                    )
                }
            let expectedType =
                target.targetName
                .hasSuffix("Probe")
                    || target.targetName
                    .hasSuffix("Verifier")
                    || target.targetName
                    .hasSuffix("Worker")
                ? "executable"
                : "library"
            guard path
                    == rule
                    .sourceDirectoryRelativePath,
                  dependencies
                    == rule
                    .directLocalDependencyNames,
                  sources.count
                    == expectedSources.count,
                  Set(sources)
                    == Set(expectedSources),
                  productDependencies.isEmpty,
                  targetType == expectedType
            else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "swift_package_describe_reconciliation"
                    )
            }
        }
    }

    public func artifactBinding(
        relativePath: String
    ) throws -> PrimeArtifactBinding {
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath: relativePath,
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    public func transitiveTargetNames(
        for targetName: String,
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws -> [String] {
        let dependencies = Dictionary(
            uniqueKeysWithValues:
                targets.map {
                    (
                        $0.targetName,
                        $0.directLocalDependencyNames
                    )
                }
        )
        guard dependencies.count == targets.count,
              dependencies[targetName] != nil
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "compiled_source_closure_target"
                )
        }
        var visited = Set<String>()
        var active = Set<String>()
        func visit(_ target: String) throws {
            guard dependencies[target] != nil else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "compiled_source_closure_dependency"
                    )
            }
            if visited.contains(target) {
                return
            }
            guard active.insert(target).inserted else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "compiled_source_closure_cycle"
                    )
            }
            for dependency in
                dependencies[target] ?? []
            {
                try visit(dependency)
            }
            active.remove(target)
            visited.insert(target)
        }
        try visit(targetName)
        let ordered = contract
            .targetClosureRules.map(\.targetName)
            .filter(visited.contains)
        guard Set(ordered) == visited else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "compiled_source_closure_transitive_order"
                )
        }
        return ordered
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case planSHA256 = "plan_sha256"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case swiftPackageDescribe =
            "swift_package_describe"
        case packageManifest =
            "package_manifest"
        case sourceIdentitySHA256 =
            "source_identity_sha256"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case buildConfiguration =
            "build_configuration"
        case targets
    }
}

public struct PrimeNativeNeuralGatePrimeGitStateRecord:
    Codable,
    Equatable,
    Sendable
{
    public let remoteURL: String
    public let revision: String
    public let treeOID: String
    public let clean: Bool

    public init(
        remoteURL: String,
        revision: String,
        treeOID: String,
        clean: Bool
    ) {
        self.remoteURL = remoteURL
        self.revision = revision
        self.treeOID = treeOID
        self.clean = clean
    }

    public func validate() throws {
        guard remoteURL
                == "https://github.com/Ergentics/ergentics-prime.git",
              Self.isLowercaseGitOID(revision),
              Self.isLowercaseGitOID(treeOID),
              clean
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("prime_git_state")
        }
    }

    private static func isLowercaseGitOID(
        _ value: String
    ) -> Bool {
        value.utf8.count == 40
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case remoteURL = "remote_url"
        case revision
        case treeOID = "tree_oid"
        case clean
    }
}

public struct PrimeNativeNeuralGateExecutableDescriptorSnapshot:
    Codable,
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let byteCount: UInt64
    public let sha256: String
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds:
        Int64
    public let statusChangeTimeSeconds: Int64
    public let statusChangeTimeNanoseconds:
        Int64
    public let regularFile: Bool
    public let openedWithNoSymbolicLinksInPath:
        Bool
    public let closeOnExec: Bool

    init(
        deviceID: UInt64,
        inode: UInt64,
        byteCount: UInt64,
        sha256: String,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        permissionMode: UInt16,
        linkCount: UInt64,
        modificationTimeSeconds: Int64,
        modificationTimeNanoseconds: Int64,
        statusChangeTimeSeconds: Int64,
        statusChangeTimeNanoseconds: Int64,
        regularFile: Bool,
        openedWithNoSymbolicLinksInPath:
            Bool,
        closeOnExec: Bool
    ) {
        self.deviceID = deviceID
        self.inode = inode
        self.byteCount = byteCount
        self.sha256 = sha256
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.permissionMode = permissionMode
        self.linkCount = linkCount
        self.modificationTimeSeconds =
            modificationTimeSeconds
        self.modificationTimeNanoseconds =
            modificationTimeNanoseconds
        self.statusChangeTimeSeconds =
            statusChangeTimeSeconds
        self.statusChangeTimeNanoseconds =
            statusChangeTimeNanoseconds
        self.regularFile = regularFile
        self.openedWithNoSymbolicLinksInPath =
            openedWithNoSymbolicLinksInPath
        self.closeOnExec = closeOnExec
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws {
        guard deviceID > 0,
              inode > 0,
              byteCount
                == contract
                .swiftPackageDescribeExpectedExecutableByteCount,
              sha256
                == contract
                .swiftPackageDescribeExpectedExecutableSHA256,
              ownerUserID
                == contract
                .swiftPackageDescribeExpectedExecutableOwnerUserID,
              ownerGroupID
                == contract
                .swiftPackageDescribeExpectedExecutableOwnerGroupID,
              permissionMode
                == contract
                .swiftPackageDescribeExpectedExecutablePermissionMode,
              linkCount
                == contract
                .swiftPackageDescribeExpectedExecutableLinkCount,
              modificationTimeNanoseconds
                >= 0,
              modificationTimeNanoseconds
                < 1_000_000_000,
              statusChangeTimeNanoseconds
                >= 0,
              statusChangeTimeNanoseconds
                < 1_000_000_000,
              regularFile,
              openedWithNoSymbolicLinksInPath,
              closeOnExec
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_executable_descriptor_snapshot"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case byteCount = "byte_count"
        case sha256
        case ownerUserID = "owner_user_id"
        case ownerGroupID = "owner_group_id"
        case permissionMode = "permission_mode"
        case linkCount = "link_count"
        case modificationTimeSeconds =
            "modification_time_seconds"
        case modificationTimeNanoseconds =
            "modification_time_nanoseconds"
        case statusChangeTimeSeconds =
            "status_change_time_seconds"
        case statusChangeTimeNanoseconds =
            "status_change_time_nanoseconds"
        case regularFile = "regular_file"
        case openedWithNoSymbolicLinksInPath =
            "opened_with_no_symbolic_links_in_path"
        case closeOnExec = "close_on_exec"
    }
}

public struct PrimeNativeNeuralGateMappedExecutableRegionObservation:
    Codable,
    Equatable,
    Sendable
{
    public let address: UInt64
    public let byteCount: UInt64
    public let fileOffset: UInt64
    public let protection: UInt32
    public let deviceID: UInt64
    public let inode: UInt64

    init(
        address: UInt64,
        byteCount: UInt64,
        fileOffset: UInt64,
        protection: UInt32,
        deviceID: UInt64,
        inode: UInt64
    ) {
        self.address = address
        self.byteCount = byteCount
        self.fileOffset = fileOffset
        self.protection = protection
        self.deviceID = deviceID
        self.inode = inode
    }

    private enum CodingKeys: String, CodingKey {
        case address
        case byteCount = "byte_count"
        case fileOffset = "file_offset"
        case protection
        case deviceID = "device_id"
        case inode
    }
}

public struct PrimeNativeNeuralGateMappedRegionQueryObservation:
    Codable,
    Equatable,
    Sendable
{
    public let queryAddress: UInt64
    public let returnedByteCount: Int
    public let region:
        PrimeNativeNeuralGateMappedExecutableRegionObservation

    init(
        queryAddress: UInt64,
        returnedByteCount: Int,
        region:
            PrimeNativeNeuralGateMappedExecutableRegionObservation
    ) {
        self.queryAddress = queryAddress
        self.returnedByteCount = returnedByteCount
        self.region = region
    }

    private enum CodingKeys: String, CodingKey {
        case queryAddress = "query_address"
        case returnedByteCount =
            "returned_byte_count"
        case region
    }
}

public struct PrimeNativeNeuralGateExactPIDWaitObservation:
    Codable,
    Equatable,
    Sendable
{
    public let requestedProcessIdentifier: Int32
    public let returnedProcessIdentifier: Int32
    public let waitOptions: Int32
    public let rawWaitStatus: Int32
    public let exitedNormally: Bool
    public let exitStatus: Int32
    public let terminationSignal: Int32
    public let coreDumped: Bool
    public let childTerminationObserved: Bool
    public let childReaped: Bool
    public let returnedMonotonicNanoseconds:
        UInt64

    init(
        requestedProcessIdentifier: Int32,
        returnedProcessIdentifier: Int32,
        waitOptions: Int32,
        rawWaitStatus: Int32,
        returnedMonotonicNanoseconds:
            UInt64
    ) {
        self.requestedProcessIdentifier =
            requestedProcessIdentifier
        self.returnedProcessIdentifier =
            returnedProcessIdentifier
        self.waitOptions = waitOptions
        self.rawWaitStatus = rawWaitStatus
        let signal = rawWaitStatus & 0x7f
        exitedNormally = signal == 0
        exitStatus =
            exitedNormally
            ? (rawWaitStatus >> 8) & 0xff
            : -1
        terminationSignal = signal
        coreDumped = rawWaitStatus & 0x80 != 0
        childTerminationObserved =
            returnedProcessIdentifier
                == requestedProcessIdentifier
        childReaped =
            returnedProcessIdentifier
                == requestedProcessIdentifier
        self.returnedMonotonicNanoseconds =
            returnedMonotonicNanoseconds
    }

    func validate(
        expectedChildProcessIdentifier:
            Int32
    ) throws {
        guard requestedProcessIdentifier
                == expectedChildProcessIdentifier,
              returnedProcessIdentifier
                == expectedChildProcessIdentifier,
              requestedProcessIdentifier > 0,
              waitOptions == 0,
              rawWaitStatus == 0,
              exitedNormally,
              exitStatus == 0,
              terminationSignal == 0,
              !coreDumped,
              childTerminationObserved,
              childReaped,
              returnedMonotonicNanoseconds > 0
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_exact_pid_wait_observation"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case requestedProcessIdentifier =
            "requested_process_identifier"
        case returnedProcessIdentifier =
            "returned_process_identifier"
        case waitOptions = "wait_options"
        case rawWaitStatus = "raw_wait_status"
        case exitedNormally = "exited_normally"
        case exitStatus = "exit_status"
        case terminationSignal =
            "termination_signal"
        case coreDumped = "core_dumped"
        case childTerminationObserved =
            "child_termination_observed"
        case childReaped = "child_reaped"
        case returnedMonotonicNanoseconds =
            "returned_monotonic_nanoseconds"
    }
}

public struct PrimeNativeNeuralGateWorkingDirectoryObservation:
    Codable,
    Equatable,
    Sendable
{
    public let descriptorDeviceID: UInt64
    public let descriptorInode: UInt64
    public let descriptorOwnerUserID: UInt32
    public let descriptorOwnerGroupID: UInt32
    public let descriptorPermissionMode: UInt16
    public let descriptorLinkCount: UInt64
    public let descriptorIsDirectory: Bool
    public let descriptorOpenedWithNoSymbolicLinksInPath:
        Bool
    public let descriptorCloseOnExec: Bool
    public let procPIDVnodePathInfoFlavor: Int32
    public let procVnodePathInfoByteCount: Int
    public let suspendedChildCurrentDirectoryDeviceID:
        UInt64
    public let suspendedChildCurrentDirectoryInode:
        UInt64
    public let descriptorJoinedToSuspendedChildCurrentDirectory:
        Bool

    init(
        descriptorDeviceID: UInt64,
        descriptorInode: UInt64,
        descriptorOwnerUserID: UInt32,
        descriptorOwnerGroupID: UInt32,
        descriptorPermissionMode: UInt16,
        descriptorLinkCount: UInt64,
        descriptorIsDirectory: Bool,
        descriptorOpenedWithNoSymbolicLinksInPath:
            Bool,
        descriptorCloseOnExec: Bool,
        procPIDVnodePathInfoFlavor: Int32,
        procVnodePathInfoByteCount: Int,
        suspendedChildCurrentDirectoryDeviceID:
            UInt64,
        suspendedChildCurrentDirectoryInode:
            UInt64,
        descriptorJoinedToSuspendedChildCurrentDirectory:
            Bool
    ) {
        self.descriptorDeviceID =
            descriptorDeviceID
        self.descriptorInode = descriptorInode
        self.descriptorOwnerUserID =
            descriptorOwnerUserID
        self.descriptorOwnerGroupID =
            descriptorOwnerGroupID
        self.descriptorPermissionMode =
            descriptorPermissionMode
        self.descriptorLinkCount =
            descriptorLinkCount
        self.descriptorIsDirectory =
            descriptorIsDirectory
        self.descriptorOpenedWithNoSymbolicLinksInPath =
            descriptorOpenedWithNoSymbolicLinksInPath
        self.descriptorCloseOnExec =
            descriptorCloseOnExec
        self.procPIDVnodePathInfoFlavor =
            procPIDVnodePathInfoFlavor
        self.procVnodePathInfoByteCount =
            procVnodePathInfoByteCount
        self.suspendedChildCurrentDirectoryDeviceID =
            suspendedChildCurrentDirectoryDeviceID
        self.suspendedChildCurrentDirectoryInode =
            suspendedChildCurrentDirectoryInode
        self.descriptorJoinedToSuspendedChildCurrentDirectory =
            descriptorJoinedToSuspendedChildCurrentDirectory
    }

    func validate() throws {
        guard descriptorDeviceID > 0,
              descriptorInode > 0,
              descriptorLinkCount > 0,
              descriptorPermissionMode & 0o700
                == 0o700,
              descriptorPermissionMode & 0o022
                == 0,
              descriptorIsDirectory,
              descriptorOpenedWithNoSymbolicLinksInPath,
              descriptorCloseOnExec,
              procPIDVnodePathInfoFlavor == 9,
              procVnodePathInfoByteCount == 2_352,
              suspendedChildCurrentDirectoryDeviceID
                == descriptorDeviceID,
              suspendedChildCurrentDirectoryInode
                == descriptorInode,
              descriptorJoinedToSuspendedChildCurrentDirectory
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_working_directory_observation"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case descriptorDeviceID =
            "descriptor_device_id"
        case descriptorInode = "descriptor_inode"
        case descriptorOwnerUserID =
            "descriptor_owner_user_id"
        case descriptorOwnerGroupID =
            "descriptor_owner_group_id"
        case descriptorPermissionMode =
            "descriptor_permission_mode"
        case descriptorLinkCount =
            "descriptor_link_count"
        case descriptorIsDirectory =
            "descriptor_is_directory"
        case descriptorOpenedWithNoSymbolicLinksInPath =
            "descriptor_opened_with_no_symbolic_links_in_path"
        case descriptorCloseOnExec =
            "descriptor_close_on_exec"
        case procPIDVnodePathInfoFlavor =
            "proc_pidvnodepathinfo_flavor"
        case procVnodePathInfoByteCount =
            "proc_vnodepathinfo_byte_count"
        case suspendedChildCurrentDirectoryDeviceID =
            "suspended_child_current_directory_device_id"
        case suspendedChildCurrentDirectoryInode =
            "suspended_child_current_directory_inode"
        case descriptorJoinedToSuspendedChildCurrentDirectory =
            "descriptor_joined_to_suspended_child_current_directory"
    }
}

public struct PrimeNativeNeuralGateSourceClosureDirectoryInventoryObservation:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let entryCount: Int
    public let inventorySHA256: String

    init(
        relativePath: String,
        entryCount: Int,
        inventorySHA256: String
    ) {
        self.relativePath = relativePath
        self.entryCount = entryCount
        self.inventorySHA256 =
            inventorySHA256
    }

    fileprivate func validate() -> Bool {
        let components = relativePath.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        return (relativePath.isEmpty
            || (
                !relativePath.hasPrefix("/")
                && !relativePath.contains("\0")
                && components.allSatisfy {
                    !$0.isEmpty
                        && $0 != "."
                        && $0 != ".."
                }
            ))
            && entryCount >= 0
            && inventorySHA256.utf8.count == 64
            && inventorySHA256.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case entryCount = "entry_count"
        case inventorySHA256 =
            "inventory_sha256"
    }
}

public struct PrimeNativeNeuralGateSourceClosureMutationGuardObservation:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let authority: String
    public let maximumFileCount: Int
    public let maximumDirectoryCount: Int
    public let maximumAggregateByteCount:
        UInt64
    public let maximumRelativeDepth: Int
    public let sourceAdmissionMaximumSeconds:
        UInt64
    public let sourceAdmissionStartedMonotonicNanoseconds:
        UInt64
    public let sourceAdmissionCompletedMonotonicNanoseconds:
        UInt64
    public let localFilesystemObserved: Bool
    public let filesystemType: String
    public let heldFileDescriptorCount: Int
    public let heldDirectoryDescriptorCount: Int
    public let aggregateFileByteCount:
        UInt64
    public let sourceSnapshotSHA256: String
    public let directoryInventories:
        [PrimeNativeNeuralGateSourceClosureDirectoryInventoryObservation]
    public let kqueueVnodeFilter: Int16
    public let fileVnodeNoteMask: UInt32
    public let directoryVnodeNoteMask: UInt32
    public let watcherCount: Int
    public let registrationReceiptCount: Int
    public let registrationReceiptErrorCount:
        Int
    public let watchersArmedMonotonicNanoseconds:
        UInt64
    public let initialValidationMonotonicNanoseconds:
        UInt64
    public let preResumeValidationMonotonicNanoseconds:
        UInt64
    public let postReapValidationMonotonicNanoseconds:
        UInt64
    public let initialPendingEventCount: Int
    public let preResumePendingEventCount: Int
    public let postReapPendingEventCount: Int
    public let repositoryBuildDirectoryUnused:
        Bool
    public let allDescriptorsHeld: Bool
    public let allFileBytesMatchedSnapshot:
        Bool
    public let allFileMetadataStable: Bool
    public let allDirectoryInventoriesStable:
        Bool
    public let allPathsRejoinedHeldVnodes:
        Bool

    init(
        maximumFileCount: Int,
        maximumDirectoryCount: Int,
        maximumAggregateByteCount: UInt64,
        maximumRelativeDepth: Int,
        sourceAdmissionMaximumSeconds:
            UInt64,
        sourceAdmissionStartedMonotonicNanoseconds:
            UInt64,
        sourceAdmissionCompletedMonotonicNanoseconds:
            UInt64,
        localFilesystemObserved: Bool,
        filesystemType: String,
        heldFileDescriptorCount: Int,
        heldDirectoryDescriptorCount: Int,
        aggregateFileByteCount: UInt64,
        sourceSnapshotSHA256: String,
        directoryInventories:
            [PrimeNativeNeuralGateSourceClosureDirectoryInventoryObservation],
        kqueueVnodeFilter: Int16,
        fileVnodeNoteMask: UInt32,
        directoryVnodeNoteMask: UInt32,
        watcherCount: Int,
        registrationReceiptCount: Int,
        registrationReceiptErrorCount: Int,
        watchersArmedMonotonicNanoseconds:
            UInt64,
        initialValidationMonotonicNanoseconds:
            UInt64,
        preResumeValidationMonotonicNanoseconds:
            UInt64,
        postReapValidationMonotonicNanoseconds:
            UInt64,
        initialPendingEventCount: Int,
        preResumePendingEventCount: Int,
        postReapPendingEventCount: Int,
        repositoryBuildDirectoryUnused:
            Bool,
        allDescriptorsHeld: Bool,
        allFileBytesMatchedSnapshot: Bool,
        allFileMetadataStable: Bool,
        allDirectoryInventoriesStable:
            Bool,
        allPathsRejoinedHeldVnodes:
            Bool,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_source_closure_mutation_guard"
        authority =
            contract
            .swiftPackageDescribeSourceMutationGuardAuthority
        self.maximumFileCount =
            maximumFileCount
        self.maximumDirectoryCount =
            maximumDirectoryCount
        self.maximumAggregateByteCount =
            maximumAggregateByteCount
        self.maximumRelativeDepth =
            maximumRelativeDepth
        self.sourceAdmissionMaximumSeconds =
            sourceAdmissionMaximumSeconds
        self.sourceAdmissionStartedMonotonicNanoseconds =
            sourceAdmissionStartedMonotonicNanoseconds
        self.sourceAdmissionCompletedMonotonicNanoseconds =
            sourceAdmissionCompletedMonotonicNanoseconds
        self.localFilesystemObserved =
            localFilesystemObserved
        self.filesystemType =
            filesystemType
        self.heldFileDescriptorCount =
            heldFileDescriptorCount
        self.heldDirectoryDescriptorCount =
            heldDirectoryDescriptorCount
        self.aggregateFileByteCount =
            aggregateFileByteCount
        self.sourceSnapshotSHA256 =
            sourceSnapshotSHA256
        self.directoryInventories =
            directoryInventories
        self.kqueueVnodeFilter =
            kqueueVnodeFilter
        self.fileVnodeNoteMask =
            fileVnodeNoteMask
        self.directoryVnodeNoteMask =
            directoryVnodeNoteMask
        self.watcherCount = watcherCount
        self.registrationReceiptCount =
            registrationReceiptCount
        self.registrationReceiptErrorCount =
            registrationReceiptErrorCount
        self.watchersArmedMonotonicNanoseconds =
            watchersArmedMonotonicNanoseconds
        self.initialValidationMonotonicNanoseconds =
            initialValidationMonotonicNanoseconds
        self.preResumeValidationMonotonicNanoseconds =
            preResumeValidationMonotonicNanoseconds
        self.postReapValidationMonotonicNanoseconds =
            postReapValidationMonotonicNanoseconds
        self.initialPendingEventCount =
            initialPendingEventCount
        self.preResumePendingEventCount =
            preResumePendingEventCount
        self.postReapPendingEventCount =
            postReapPendingEventCount
        self.repositoryBuildDirectoryUnused =
            repositoryBuildDirectoryUnused
        self.allDescriptorsHeld =
            allDescriptorsHeld
        self.allFileBytesMatchedSnapshot =
            allFileBytesMatchedSnapshot
        self.allFileMetadataStable =
            allFileMetadataStable
        self.allDirectoryInventoriesStable =
            allDirectoryInventoriesStable
        self.allPathsRejoinedHeldVnodes =
            allPathsRejoinedHeldVnodes
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws {
        let paths =
            directoryInventories
            .map(\.relativePath)
        let admissionDuration =
            sourceAdmissionMaximumSeconds
            .multipliedReportingOverflow(
                by: 1_000_000_000
            )
        let admissionDeadline =
            sourceAdmissionStartedMonotonicNanoseconds
            .addingReportingOverflow(
                admissionDuration.partialValue
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_source_closure_mutation_guard",
              contract
                .swiftPackageDescribeSourceMutationGuardRequired,
              authority
                == contract
                .swiftPackageDescribeSourceMutationGuardAuthority,
              maximumFileCount == 4_096,
              maximumDirectoryCount == 4_096,
              maximumAggregateByteCount
                == 512 * 1024 * 1024,
              maximumRelativeDepth == 32,
              sourceAdmissionMaximumSeconds
                == contract
                .swiftPackageDescribeSourceAdmissionMaximumSeconds,
              sourceAdmissionStartedMonotonicNanoseconds
                > 0,
              sourceAdmissionStartedMonotonicNanoseconds
                < sourceAdmissionCompletedMonotonicNanoseconds,
              !admissionDuration.overflow,
              !admissionDeadline.overflow,
              sourceAdmissionCompletedMonotonicNanoseconds
                <= admissionDeadline.partialValue,
              sourceAdmissionCompletedMonotonicNanoseconds
                == initialValidationMonotonicNanoseconds,
              contract
                .swiftPackageDescribeSourceLocalFilesystemRequired,
              localFilesystemObserved,
              filesystemType
                == contract
                .swiftPackageDescribeSourceFilesystemType,
              heldFileDescriptorCount > 0,
              heldFileDescriptorCount
                <= maximumFileCount,
              heldDirectoryDescriptorCount > 0,
              heldDirectoryDescriptorCount
                <= maximumDirectoryCount,
              aggregateFileByteCount > 0,
              aggregateFileByteCount
                <= maximumAggregateByteCount,
              sourceSnapshotSHA256.utf8.count
                == 64,
              sourceSnapshotSHA256.utf8
                .allSatisfy({
                    byte in
                    (byte >= 48 && byte <= 57)
                        || (
                            byte >= 97
                            && byte <= 102
                        )
                }),
              directoryInventories.count
                == heldDirectoryDescriptorCount,
              paths == paths.sorted(),
              Set(paths).count == paths.count,
              directoryInventories
                .allSatisfy({
                    $0.validate()
                }),
              kqueueVnodeFilter == -4,
              fileVnodeNoteMask == 0x7f,
              directoryVnodeNoteMask == 0x7f,
              watcherCount
                == heldFileDescriptorCount
                    + heldDirectoryDescriptorCount,
              registrationReceiptCount
                == watcherCount,
              registrationReceiptErrorCount == 0,
              watchersArmedMonotonicNanoseconds
                > 0,
              sourceAdmissionStartedMonotonicNanoseconds
                <= watchersArmedMonotonicNanoseconds,
              watchersArmedMonotonicNanoseconds
                <= initialValidationMonotonicNanoseconds,
              initialValidationMonotonicNanoseconds
                <= preResumeValidationMonotonicNanoseconds,
              preResumeValidationMonotonicNanoseconds
                <= postReapValidationMonotonicNanoseconds,
              initialPendingEventCount == 0,
              preResumePendingEventCount == 0,
              postReapPendingEventCount == 0,
              repositoryBuildDirectoryUnused,
              allDescriptorsHeld,
              allFileBytesMatchedSnapshot,
              allFileMetadataStable,
              allDirectoryInventoriesStable,
              allPathsRejoinedHeldVnodes
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_source_closure_mutation_guard"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case authority
        case maximumFileCount =
            "maximum_file_count"
        case maximumDirectoryCount =
            "maximum_directory_count"
        case maximumAggregateByteCount =
            "maximum_aggregate_byte_count"
        case maximumRelativeDepth =
            "maximum_relative_depth"
        case sourceAdmissionMaximumSeconds =
            "source_admission_maximum_seconds"
        case sourceAdmissionStartedMonotonicNanoseconds =
            "source_admission_started_monotonic_nanoseconds"
        case sourceAdmissionCompletedMonotonicNanoseconds =
            "source_admission_completed_monotonic_nanoseconds"
        case localFilesystemObserved =
            "local_filesystem_observed"
        case filesystemType =
            "filesystem_type"
        case heldFileDescriptorCount =
            "held_file_descriptor_count"
        case heldDirectoryDescriptorCount =
            "held_directory_descriptor_count"
        case aggregateFileByteCount =
            "aggregate_file_byte_count"
        case sourceSnapshotSHA256 =
            "source_snapshot_sha256"
        case directoryInventories =
            "directory_inventories"
        case kqueueVnodeFilter =
            "kqueue_vnode_filter"
        case fileVnodeNoteMask =
            "file_vnode_note_mask"
        case directoryVnodeNoteMask =
            "directory_vnode_note_mask"
        case watcherCount =
            "watcher_count"
        case registrationReceiptCount =
            "registration_receipt_count"
        case registrationReceiptErrorCount =
            "registration_receipt_error_count"
        case watchersArmedMonotonicNanoseconds =
            "watchers_armed_monotonic_nanoseconds"
        case initialValidationMonotonicNanoseconds =
            "initial_validation_monotonic_nanoseconds"
        case preResumeValidationMonotonicNanoseconds =
            "pre_resume_validation_monotonic_nanoseconds"
        case postReapValidationMonotonicNanoseconds =
            "post_reap_validation_monotonic_nanoseconds"
        case initialPendingEventCount =
            "initial_pending_event_count"
        case preResumePendingEventCount =
            "pre_resume_pending_event_count"
        case postReapPendingEventCount =
            "post_reap_pending_event_count"
        case repositoryBuildDirectoryUnused =
            "repository_build_directory_unused"
        case allDescriptorsHeld =
            "all_descriptors_held"
        case allFileBytesMatchedSnapshot =
            "all_file_bytes_matched_snapshot"
        case allFileMetadataStable =
            "all_file_metadata_stable"
        case allDirectoryInventoriesStable =
            "all_directory_inventories_stable"
        case allPathsRejoinedHeldVnodes =
            "all_paths_rejoined_held_vnodes"
    }
}

public struct PrimeNativeNeuralGateScratchNamespaceObservation:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let runRootAbsolutePath: String
    public let sourceFilesystemType: String
    public let sourceFilesystemIDWord0: Int32
    public let sourceFilesystemIDWord1: Int32
    public let scratchFilesystemType: String
    public let scratchFilesystemIDWord0: Int32
    public let scratchFilesystemIDWord1: Int32
    public let runRootDeviceID: UInt64
    public let runRootInode: UInt64
    public let runRootOwnerUserID: UInt32
    public let runRootOwnerGroupID: UInt32
    public let runRootPermissionMode: UInt16
    public let exactDirectoryNames: [String]
    public let heldDirectoryDescriptorCount:
        Int
    public let allDescriptorsOpenedWithNoSymbolicLinksInPath:
        Bool
    public let allDescriptorsCloseOnExec: Bool
    public let allDescriptorsOnExactSourceFilesystem:
        Bool
    public let allACLsAbsentAndExtendedAttributesAllowlisted:
        Bool
    public let permittedExtendedAttributeNames:
        [String]
    public let extendedAttributePolicyID: String
    public let textEncodingRelativePath: String
    public let textEncodingAttributeName: String
    public let textEncodingRequiredNodeType:
        String
    public let textEncodingExactValue: String
    public let textEncodingExactByteCount: Int
    public let textEncodingAbsencePermitted:
        Bool
    public let textEncodingObservedCount: Int
    public let allObservedTextEncodingAttributesMatchedPolicy:
        Bool
    public let provenanceAttributeName: String
    public let provenanceValueOpaqueAndNonAuthoritative:
        Bool
    public let maximumProvenanceValueByteCount:
        Int
    public let rootCreatedAtomicallyAndInitiallyEmpty:
        Bool
    public let kqueueVnodeFilter: Int16
    public let destructiveVnodeNoteMask: UInt32
    public let watcherCount: Int
    public let registrationReceiptCount: Int
    public let registrationReceiptErrorCount:
        Int
    public let watchersArmedMonotonicNanoseconds:
        UInt64
    public let preResumeValidationMonotonicNanoseconds:
        UInt64
    public let postReapValidationMonotonicNanoseconds:
        UInt64
    public let preResumeDestructiveEventCount:
        Int
    public let postReapDestructiveEventCount:
        Int
    public let allPathsRejoinedHeldVnodes:
        Bool
    public let maximumPostAuditFileCount: Int
    public let maximumPostAuditDirectoryCount:
        Int
    public let maximumPostAuditAggregateByteCount:
        UInt64
    public let maximumPostAuditRelativeDepth: Int
    public let maximumPostAuditSeconds: UInt64
    public let postAuditStartedMonotonicNanoseconds:
        UInt64
    public let postAuditCompletedMonotonicNanoseconds:
        UInt64
    public let postAuditFileCount: Int
    public let postAuditDirectoryCount: Int
    public let postAuditAggregateByteCount:
        UInt64
    public let cacheDirectoryEmpty: Bool
    public let configDirectoryEmpty: Bool
    public let securityDirectoryEmpty: Bool
    public let networkDenialEstablished: Bool
    public let dependencyResolutionPermitted:
        Bool
    public let resolutionResiduePathCount: Int
    public let resolutionResiduesAbsent: Bool
    public let namespaceLeftForSystemTemporaryDirectoryCleanup:
        Bool

    init(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        runRootAbsolutePath: String,
        sourceFilesystemType: String,
        sourceFilesystemIDWord0: Int32,
        sourceFilesystemIDWord1: Int32,
        scratchFilesystemType: String,
        scratchFilesystemIDWord0: Int32,
        scratchFilesystemIDWord1: Int32,
        runRootDeviceID: UInt64,
        runRootInode: UInt64,
        runRootOwnerUserID: UInt32,
        runRootOwnerGroupID: UInt32,
        runRootPermissionMode: UInt16,
        exactDirectoryNames: [String],
        heldDirectoryDescriptorCount: Int,
        allDescriptorsOpenedWithNoSymbolicLinksInPath:
            Bool,
        allDescriptorsCloseOnExec: Bool,
        allDescriptorsOnExactSourceFilesystem:
            Bool,
        allACLsAbsentAndExtendedAttributesAllowlisted:
            Bool,
        permittedExtendedAttributeNames:
            [String],
        extendedAttributePolicyID: String,
        textEncodingRelativePath: String,
        textEncodingAttributeName: String,
        textEncodingRequiredNodeType:
            String,
        textEncodingExactValue: String,
        textEncodingExactByteCount: Int,
        textEncodingAbsencePermitted:
            Bool,
        textEncodingObservedCount: Int,
        allObservedTextEncodingAttributesMatchedPolicy:
            Bool,
        provenanceAttributeName: String,
        provenanceValueOpaqueAndNonAuthoritative:
            Bool,
        maximumProvenanceValueByteCount:
            Int,
        rootCreatedAtomicallyAndInitiallyEmpty:
            Bool,
        kqueueVnodeFilter: Int16,
        destructiveVnodeNoteMask: UInt32,
        watcherCount: Int,
        registrationReceiptCount: Int,
        registrationReceiptErrorCount: Int,
        watchersArmedMonotonicNanoseconds:
            UInt64,
        preResumeValidationMonotonicNanoseconds:
            UInt64,
        postReapValidationMonotonicNanoseconds:
            UInt64,
        preResumeDestructiveEventCount: Int,
        postReapDestructiveEventCount: Int,
        allPathsRejoinedHeldVnodes: Bool,
        maximumPostAuditFileCount: Int,
        maximumPostAuditDirectoryCount:
            Int,
        maximumPostAuditAggregateByteCount:
            UInt64,
        maximumPostAuditRelativeDepth: Int,
        maximumPostAuditSeconds: UInt64,
        postAuditStartedMonotonicNanoseconds:
            UInt64,
        postAuditCompletedMonotonicNanoseconds:
            UInt64,
        postAuditFileCount: Int,
        postAuditDirectoryCount: Int,
        postAuditAggregateByteCount:
            UInt64,
        cacheDirectoryEmpty: Bool,
        configDirectoryEmpty: Bool,
        securityDirectoryEmpty: Bool,
        networkDenialEstablished: Bool,
        dependencyResolutionPermitted: Bool,
        resolutionResiduePathCount: Int,
        resolutionResiduesAbsent: Bool,
        namespaceLeftForSystemTemporaryDirectoryCleanup:
            Bool
    ) {
        schemaVersion = 2
        artifactKind =
            "ergentics_prime_native_neural_gate_scratch_namespace_observation"
        self.role = role
        self.runRootAbsolutePath =
            runRootAbsolutePath
        self.sourceFilesystemType =
            sourceFilesystemType
        self.sourceFilesystemIDWord0 =
            sourceFilesystemIDWord0
        self.sourceFilesystemIDWord1 =
            sourceFilesystemIDWord1
        self.scratchFilesystemType =
            scratchFilesystemType
        self.scratchFilesystemIDWord0 =
            scratchFilesystemIDWord0
        self.scratchFilesystemIDWord1 =
            scratchFilesystemIDWord1
        self.runRootDeviceID =
            runRootDeviceID
        self.runRootInode = runRootInode
        self.runRootOwnerUserID =
            runRootOwnerUserID
        self.runRootOwnerGroupID =
            runRootOwnerGroupID
        self.runRootPermissionMode =
            runRootPermissionMode
        self.exactDirectoryNames =
            exactDirectoryNames
        self.heldDirectoryDescriptorCount =
            heldDirectoryDescriptorCount
        self.allDescriptorsOpenedWithNoSymbolicLinksInPath =
            allDescriptorsOpenedWithNoSymbolicLinksInPath
        self.allDescriptorsCloseOnExec =
            allDescriptorsCloseOnExec
        self.allDescriptorsOnExactSourceFilesystem =
            allDescriptorsOnExactSourceFilesystem
        self.allACLsAbsentAndExtendedAttributesAllowlisted =
            allACLsAbsentAndExtendedAttributesAllowlisted
        self.permittedExtendedAttributeNames =
            permittedExtendedAttributeNames
        self.extendedAttributePolicyID =
            extendedAttributePolicyID
        self.textEncodingRelativePath =
            textEncodingRelativePath
        self.textEncodingAttributeName =
            textEncodingAttributeName
        self.textEncodingRequiredNodeType =
            textEncodingRequiredNodeType
        self.textEncodingExactValue =
            textEncodingExactValue
        self.textEncodingExactByteCount =
            textEncodingExactByteCount
        self.textEncodingAbsencePermitted =
            textEncodingAbsencePermitted
        self.textEncodingObservedCount =
            textEncodingObservedCount
        self.allObservedTextEncodingAttributesMatchedPolicy =
            allObservedTextEncodingAttributesMatchedPolicy
        self.provenanceAttributeName =
            provenanceAttributeName
        self.provenanceValueOpaqueAndNonAuthoritative =
            provenanceValueOpaqueAndNonAuthoritative
        self.maximumProvenanceValueByteCount =
            maximumProvenanceValueByteCount
        self.rootCreatedAtomicallyAndInitiallyEmpty =
            rootCreatedAtomicallyAndInitiallyEmpty
        self.kqueueVnodeFilter =
            kqueueVnodeFilter
        self.destructiveVnodeNoteMask =
            destructiveVnodeNoteMask
        self.watcherCount = watcherCount
        self.registrationReceiptCount =
            registrationReceiptCount
        self.registrationReceiptErrorCount =
            registrationReceiptErrorCount
        self.watchersArmedMonotonicNanoseconds =
            watchersArmedMonotonicNanoseconds
        self.preResumeValidationMonotonicNanoseconds =
            preResumeValidationMonotonicNanoseconds
        self.postReapValidationMonotonicNanoseconds =
            postReapValidationMonotonicNanoseconds
        self.preResumeDestructiveEventCount =
            preResumeDestructiveEventCount
        self.postReapDestructiveEventCount =
            postReapDestructiveEventCount
        self.allPathsRejoinedHeldVnodes =
            allPathsRejoinedHeldVnodes
        self.maximumPostAuditFileCount =
            maximumPostAuditFileCount
        self.maximumPostAuditDirectoryCount =
            maximumPostAuditDirectoryCount
        self.maximumPostAuditAggregateByteCount =
            maximumPostAuditAggregateByteCount
        self.maximumPostAuditRelativeDepth =
            maximumPostAuditRelativeDepth
        self.maximumPostAuditSeconds =
            maximumPostAuditSeconds
        self.postAuditStartedMonotonicNanoseconds =
            postAuditStartedMonotonicNanoseconds
        self.postAuditCompletedMonotonicNanoseconds =
            postAuditCompletedMonotonicNanoseconds
        self.postAuditFileCount =
            postAuditFileCount
        self.postAuditDirectoryCount =
            postAuditDirectoryCount
        self.postAuditAggregateByteCount =
            postAuditAggregateByteCount
        self.cacheDirectoryEmpty =
            cacheDirectoryEmpty
        self.configDirectoryEmpty =
            configDirectoryEmpty
        self.securityDirectoryEmpty =
            securityDirectoryEmpty
        self.networkDenialEstablished =
            networkDenialEstablished
        self.dependencyResolutionPermitted =
            dependencyResolutionPermitted
        self.resolutionResiduePathCount =
            resolutionResiduePathCount
        self.resolutionResiduesAbsent =
            resolutionResiduesAbsent
        self.namespaceLeftForSystemTemporaryDirectoryCleanup =
            namespaceLeftForSystemTemporaryDirectoryCleanup
    }

    func validate(
        role expectedRole:
            PrimeNativeNeuralGateReleaseProcessRole
    ) throws {
        let components =
            runRootAbsolutePath.split(
                separator: "/",
                omittingEmptySubsequences:
                    true
            )
        guard schemaVersion == 2,
              artifactKind
                == "ergentics_prime_native_neural_gate_scratch_namespace_observation",
              role == expectedRole,
              runRootAbsolutePath.hasPrefix("/"),
              runRootAbsolutePath != "/",
              !runRootAbsolutePath.contains("\0"),
              !runRootAbsolutePath
                .hasSuffix("/"),
              components.allSatisfy({
                  $0 != "."
                      && $0 != ".."
              }),
              components.last?
                .hasPrefix(
                    "ergentics-prime-neural-gate-\(role.rawValue)-"
                ) == true,
              sourceFilesystemType == "apfs",
              scratchFilesystemType
                == sourceFilesystemType,
              scratchFilesystemIDWord0
                == sourceFilesystemIDWord0,
              scratchFilesystemIDWord1
                == sourceFilesystemIDWord1,
              runRootDeviceID > 0,
              runRootInode > 0,
              runRootOwnerUserID
                == UInt32(geteuid()),
              runRootOwnerGroupID
                == UInt32(getegid()),
              runRootPermissionMode == 0o700,
              exactDirectoryNames
                == [
                    "work",
                    "cache",
                    "config",
                    "security",
                    "home",
                    "tmp",
                    "module-cache",
                ],
              heldDirectoryDescriptorCount
                == exactDirectoryNames.count + 1,
              allDescriptorsOpenedWithNoSymbolicLinksInPath,
              allDescriptorsCloseOnExec,
              allDescriptorsOnExactSourceFilesystem,
              allACLsAbsentAndExtendedAttributesAllowlisted,
              permittedExtendedAttributeNames
                == [
                    "com.apple.TextEncoding",
                    "com.apple.provenance",
                ],
              extendedAttributePolicyID
                == "optional_exact_text_encoding_work_lock_bounded_opaque_provenance_v1",
              textEncodingRelativePath
                == "work/.lock",
              textEncodingAttributeName
                == "com.apple.TextEncoding",
              textEncodingRequiredNodeType
                == "regular_file",
              textEncodingExactValue
                == "utf-8;134217984",
              textEncodingExactByteCount == 15,
              textEncodingAbsencePermitted,
              textEncodingObservedCount
                >= 0,
              textEncodingObservedCount
                <= 1,
              allObservedTextEncodingAttributesMatchedPolicy,
              provenanceAttributeName
                == "com.apple.provenance",
              provenanceValueOpaqueAndNonAuthoritative,
              maximumProvenanceValueByteCount
                == 4_096,
              rootCreatedAtomicallyAndInitiallyEmpty,
              kqueueVnodeFilter == -4,
              destructiveVnodeNoteMask == 0x69,
              watcherCount
                == heldDirectoryDescriptorCount,
              registrationReceiptCount
                == watcherCount,
              registrationReceiptErrorCount == 0,
              watchersArmedMonotonicNanoseconds
                > 0,
              watchersArmedMonotonicNanoseconds
                < preResumeValidationMonotonicNanoseconds,
              preResumeValidationMonotonicNanoseconds
                < postReapValidationMonotonicNanoseconds,
              preResumeDestructiveEventCount
                == 0,
              postReapDestructiveEventCount
                == 0,
              allPathsRejoinedHeldVnodes,
              maximumPostAuditFileCount
                == 65_536,
              maximumPostAuditDirectoryCount
                == 8_192,
              maximumPostAuditAggregateByteCount
                == 1_073_741_824,
              maximumPostAuditRelativeDepth
                == 32,
              maximumPostAuditSeconds == 2,
              postAuditStartedMonotonicNanoseconds
                >= preResumeValidationMonotonicNanoseconds,
              postAuditStartedMonotonicNanoseconds
                < postAuditCompletedMonotonicNanoseconds,
              postAuditCompletedMonotonicNanoseconds
                <= postReapValidationMonotonicNanoseconds,
              postAuditCompletedMonotonicNanoseconds
                    - postAuditStartedMonotonicNanoseconds
                <= maximumPostAuditSeconds
                    * 1_000_000_000,
              postAuditFileCount >= 0,
              postAuditFileCount
                <= maximumPostAuditFileCount,
              postAuditDirectoryCount
                >= exactDirectoryNames.count
                    + 1,
              postAuditDirectoryCount
                <= maximumPostAuditDirectoryCount,
              postAuditAggregateByteCount
                <= maximumPostAuditAggregateByteCount,
              cacheDirectoryEmpty,
              configDirectoryEmpty,
              securityDirectoryEmpty,
              !networkDenialEstablished,
              !dependencyResolutionPermitted,
              resolutionResiduePathCount == 0,
              resolutionResiduesAbsent,
              namespaceLeftForSystemTemporaryDirectoryCleanup
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "scratch_namespace_observation"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case role
        case runRootAbsolutePath =
            "run_root_absolute_path"
        case sourceFilesystemType =
            "source_filesystem_type"
        case sourceFilesystemIDWord0 =
            "source_filesystem_id_word_0"
        case sourceFilesystemIDWord1 =
            "source_filesystem_id_word_1"
        case scratchFilesystemType =
            "scratch_filesystem_type"
        case scratchFilesystemIDWord0 =
            "scratch_filesystem_id_word_0"
        case scratchFilesystemIDWord1 =
            "scratch_filesystem_id_word_1"
        case runRootDeviceID =
            "run_root_device_id"
        case runRootInode = "run_root_inode"
        case runRootOwnerUserID =
            "run_root_owner_user_id"
        case runRootOwnerGroupID =
            "run_root_owner_group_id"
        case runRootPermissionMode =
            "run_root_permission_mode"
        case exactDirectoryNames =
            "exact_directory_names"
        case heldDirectoryDescriptorCount =
            "held_directory_descriptor_count"
        case allDescriptorsOpenedWithNoSymbolicLinksInPath =
            "all_descriptors_opened_with_no_symbolic_links_in_path"
        case allDescriptorsCloseOnExec =
            "all_descriptors_close_on_exec"
        case allDescriptorsOnExactSourceFilesystem =
            "all_descriptors_on_exact_source_filesystem"
        case allACLsAbsentAndExtendedAttributesAllowlisted =
            "all_acls_absent_and_extended_attributes_allowlisted"
        case permittedExtendedAttributeNames =
            "permitted_extended_attribute_names"
        case extendedAttributePolicyID =
            "extended_attribute_policy_id"
        case textEncodingRelativePath =
            "text_encoding_relative_path"
        case textEncodingAttributeName =
            "text_encoding_attribute_name"
        case textEncodingRequiredNodeType =
            "text_encoding_required_node_type"
        case textEncodingExactValue =
            "text_encoding_exact_value"
        case textEncodingExactByteCount =
            "text_encoding_exact_byte_count"
        case textEncodingAbsencePermitted =
            "text_encoding_absence_permitted"
        case textEncodingObservedCount =
            "text_encoding_observed_count"
        case allObservedTextEncodingAttributesMatchedPolicy =
            "all_observed_text_encoding_attributes_matched_policy"
        case provenanceAttributeName =
            "provenance_attribute_name"
        case provenanceValueOpaqueAndNonAuthoritative =
            "provenance_value_opaque_and_non_authoritative"
        case maximumProvenanceValueByteCount =
            "maximum_provenance_value_byte_count"
        case rootCreatedAtomicallyAndInitiallyEmpty =
            "root_created_atomically_and_initially_empty"
        case kqueueVnodeFilter =
            "kqueue_vnode_filter"
        case destructiveVnodeNoteMask =
            "destructive_vnode_note_mask"
        case watcherCount = "watcher_count"
        case registrationReceiptCount =
            "registration_receipt_count"
        case registrationReceiptErrorCount =
            "registration_receipt_error_count"
        case watchersArmedMonotonicNanoseconds =
            "watchers_armed_monotonic_nanoseconds"
        case preResumeValidationMonotonicNanoseconds =
            "pre_resume_validation_monotonic_nanoseconds"
        case postReapValidationMonotonicNanoseconds =
            "post_reap_validation_monotonic_nanoseconds"
        case preResumeDestructiveEventCount =
            "pre_resume_destructive_event_count"
        case postReapDestructiveEventCount =
            "post_reap_destructive_event_count"
        case allPathsRejoinedHeldVnodes =
            "all_paths_rejoined_held_vnodes"
        case maximumPostAuditFileCount =
            "maximum_post_audit_file_count"
        case maximumPostAuditDirectoryCount =
            "maximum_post_audit_directory_count"
        case maximumPostAuditAggregateByteCount =
            "maximum_post_audit_aggregate_byte_count"
        case maximumPostAuditRelativeDepth =
            "maximum_post_audit_relative_depth"
        case maximumPostAuditSeconds =
            "maximum_post_audit_seconds"
        case postAuditStartedMonotonicNanoseconds =
            "post_audit_started_monotonic_nanoseconds"
        case postAuditCompletedMonotonicNanoseconds =
            "post_audit_completed_monotonic_nanoseconds"
        case postAuditFileCount =
            "post_audit_file_count"
        case postAuditDirectoryCount =
            "post_audit_directory_count"
        case postAuditAggregateByteCount =
            "post_audit_aggregate_byte_count"
        case cacheDirectoryEmpty =
            "cache_directory_empty"
        case configDirectoryEmpty =
            "config_directory_empty"
        case securityDirectoryEmpty =
            "security_directory_empty"
        case networkDenialEstablished =
            "network_denial_established"
        case dependencyResolutionPermitted =
            "dependency_resolution_permitted"
        case resolutionResiduePathCount =
            "resolution_residue_path_count"
        case resolutionResiduesAbsent =
            "resolution_residues_absent"
        case namespaceLeftForSystemTemporaryDirectoryCleanup =
            "namespace_left_for_system_temporary_directory_cleanup"
    }
}

public struct PrimeNativeNeuralGateExternalChildCaptureEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let supervisorProcessIdentifier:
        Int32
    public let childProcessIdentifier: Int32
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let captureAuthority: String
    public let mappedRegionEnumerationPolicy:
        String
    public let capabilityCalibrationPolicy:
        String
    public let capabilityCalibrationPassed:
        Bool
    public let posixSpawnStartSuspendedFlag:
        UInt16
    public let posixSpawnCloseOnExecDefaultFlag:
        UInt16
    public let posixSpawnSetSessionFlag:
        UInt16
    public let posixSpawnSetSignalDefaultsFlag:
        UInt16
    public let posixSpawnSetSignalMaskFlag:
        UInt16
    public let appliedSpawnFlags: UInt16
    public let observedChildSessionIdentifier:
        Int32
    public let observedChildProcessGroupIdentifier:
        Int32
    public let emptySignalMaskConfigured: Bool
    public let defaultSignalDispositionsConfigured:
        Bool
    public let terminationSignalsTargetProcessGroup:
        Bool
    public let posixSpawnReturnCode: Int32
    public let procPIDRegionPathInfoFlavor:
        Int32
    public let procRegionWithPathInfoByteCount:
        Int
    public let descriptorOpenedMonotonicNanoseconds:
        UInt64
    public let spawnReturnedMonotonicNanoseconds:
        UInt64
    public let childSessionAndProcessGroupObservedMonotonicNanoseconds:
        UInt64
    public let workingDirectoryCapturedMonotonicNanoseconds:
        UInt64
    public let mappedRegionCapturedMonotonicNanoseconds:
        UInt64
    public let descriptorRevalidatedBeforeResumeMonotonicNanoseconds:
        UInt64
    public let sigcontDeliveredMonotonicNanoseconds:
        UInt64
    public let sigcontReturnCode: Int32
    public let childTerminationObservedMonotonicNanoseconds:
        UInt64
    public let preReapProcessGroupMemberIdentifiers:
        [Int32]
    public let preReapProcessGroupMembersObservedMonotonicNanoseconds:
        UInt64
    public let childReapedMonotonicNanoseconds:
        UInt64
    public let processGroupEmptyObservedMonotonicNanoseconds:
        UInt64
    public let descriptorRevalidatedAfterReapMonotonicNanoseconds:
        UInt64
    public let sourceClosureMutationGuard:
        PrimeNativeNeuralGateSourceClosureMutationGuardObservation
    public let scratchNamespace:
        PrimeNativeNeuralGateScratchNamespaceObservation
    public let workingDirectory:
        PrimeNativeNeuralGateWorkingDirectoryObservation
    public let preSpawnDescriptor:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    public let preResumeDescriptor:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    public let postReapDescriptor:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    public let allMappedRegionQueries:
        [PrimeNativeNeuralGateMappedRegionQueryObservation]
    public let terminalMappedRegionQueryAddress:
        UInt64
    public let terminalMappedRegionQueryReturnByteCount:
        Int
    public let terminalMappedRegionQueryErrno:
        Int32
    public let mappedRegionEnumerationCompleted:
        Bool
    public let matchingMappedRegions:
        [PrimeNativeNeuralGateMappedExecutableRegionObservation]
    public let exactPIDWaitObservation:
        PrimeNativeNeuralGateExactPIDWaitObservation
    public let deadlineExpired: Bool
    public let sigtermDelivered: Bool
    public let sigkillDelivered: Bool
    public let processGroupEmptyAfterReap: Bool
    public let procPIDPathUsedOnlyAsTelemetry:
        Bool

    init(
        supervisorProcessIdentifier: Int32,
        childProcessIdentifier: Int32,
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        capabilityCalibrationPassed: Bool,
        posixSpawnStartSuspendedFlag:
            UInt16,
        posixSpawnCloseOnExecDefaultFlag:
            UInt16,
        posixSpawnSetSessionFlag:
            UInt16,
        posixSpawnSetSignalDefaultsFlag:
            UInt16,
        posixSpawnSetSignalMaskFlag:
            UInt16,
        appliedSpawnFlags: UInt16,
        observedChildSessionIdentifier:
            Int32,
        observedChildProcessGroupIdentifier:
            Int32,
        emptySignalMaskConfigured: Bool,
        defaultSignalDispositionsConfigured:
            Bool,
        terminationSignalsTargetProcessGroup:
            Bool,
        posixSpawnReturnCode: Int32,
        procPIDRegionPathInfoFlavor:
            Int32,
        procRegionWithPathInfoByteCount:
            Int,
        descriptorOpenedMonotonicNanoseconds:
            UInt64,
        spawnReturnedMonotonicNanoseconds:
            UInt64,
        childSessionAndProcessGroupObservedMonotonicNanoseconds:
            UInt64,
        workingDirectoryCapturedMonotonicNanoseconds:
            UInt64,
        mappedRegionCapturedMonotonicNanoseconds:
            UInt64,
        descriptorRevalidatedBeforeResumeMonotonicNanoseconds:
            UInt64,
        sigcontDeliveredMonotonicNanoseconds:
            UInt64,
        sigcontReturnCode: Int32,
        childTerminationObservedMonotonicNanoseconds:
            UInt64,
        preReapProcessGroupMemberIdentifiers:
            [Int32],
        preReapProcessGroupMembersObservedMonotonicNanoseconds:
            UInt64,
        childReapedMonotonicNanoseconds:
            UInt64,
        processGroupEmptyObservedMonotonicNanoseconds:
            UInt64,
        descriptorRevalidatedAfterReapMonotonicNanoseconds:
            UInt64,
        sourceClosureMutationGuard:
            PrimeNativeNeuralGateSourceClosureMutationGuardObservation,
        scratchNamespace:
            PrimeNativeNeuralGateScratchNamespaceObservation,
        workingDirectory:
            PrimeNativeNeuralGateWorkingDirectoryObservation,
        preSpawnDescriptor:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        preResumeDescriptor:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        postReapDescriptor:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        allMappedRegionQueries:
            [PrimeNativeNeuralGateMappedRegionQueryObservation],
        terminalMappedRegionQueryAddress:
            UInt64,
        terminalMappedRegionQueryReturnByteCount:
            Int,
        terminalMappedRegionQueryErrno:
            Int32,
        mappedRegionEnumerationCompleted:
            Bool,
        exactPIDWaitObservation:
            PrimeNativeNeuralGateExactPIDWaitObservation,
        deadlineExpired: Bool,
        sigtermDelivered: Bool,
        sigkillDelivered: Bool,
        processGroupEmptyAfterReap: Bool,
        procPIDPathUsedOnlyAsTelemetry:
            Bool,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) {
        schemaVersion = 4
        artifactKind =
            "ergentics_prime_native_neural_gate_external_child_capture_evidence"
        self.supervisorProcessIdentifier =
            supervisorProcessIdentifier
        self.childProcessIdentifier =
            childProcessIdentifier
        self.role = role
        captureAuthority =
            contract
            .swiftPackageDescribeMappedChildImageCaptureAuthority
        mappedRegionEnumerationPolicy =
            contract
            .swiftPackageDescribeMappedRegionEnumerationPolicy
        capabilityCalibrationPolicy =
            contract
            .swiftPackageDescribeCaptureCapabilityCalibrationPolicy
        self.capabilityCalibrationPassed =
            capabilityCalibrationPassed
        self.posixSpawnStartSuspendedFlag =
            posixSpawnStartSuspendedFlag
        self.posixSpawnCloseOnExecDefaultFlag =
            posixSpawnCloseOnExecDefaultFlag
        self.posixSpawnSetSessionFlag =
            posixSpawnSetSessionFlag
        self.posixSpawnSetSignalDefaultsFlag =
            posixSpawnSetSignalDefaultsFlag
        self.posixSpawnSetSignalMaskFlag =
            posixSpawnSetSignalMaskFlag
        self.appliedSpawnFlags =
            appliedSpawnFlags
        self.observedChildSessionIdentifier =
            observedChildSessionIdentifier
        self.observedChildProcessGroupIdentifier =
            observedChildProcessGroupIdentifier
        self.emptySignalMaskConfigured =
            emptySignalMaskConfigured
        self.defaultSignalDispositionsConfigured =
            defaultSignalDispositionsConfigured
        self.terminationSignalsTargetProcessGroup =
            terminationSignalsTargetProcessGroup
        self.posixSpawnReturnCode =
            posixSpawnReturnCode
        self.procPIDRegionPathInfoFlavor =
            procPIDRegionPathInfoFlavor
        self.procRegionWithPathInfoByteCount =
            procRegionWithPathInfoByteCount
        self.descriptorOpenedMonotonicNanoseconds =
            descriptorOpenedMonotonicNanoseconds
        self.spawnReturnedMonotonicNanoseconds =
            spawnReturnedMonotonicNanoseconds
        self.childSessionAndProcessGroupObservedMonotonicNanoseconds =
            childSessionAndProcessGroupObservedMonotonicNanoseconds
        self.workingDirectoryCapturedMonotonicNanoseconds =
            workingDirectoryCapturedMonotonicNanoseconds
        self.mappedRegionCapturedMonotonicNanoseconds =
            mappedRegionCapturedMonotonicNanoseconds
        self.descriptorRevalidatedBeforeResumeMonotonicNanoseconds =
            descriptorRevalidatedBeforeResumeMonotonicNanoseconds
        self.sigcontDeliveredMonotonicNanoseconds =
            sigcontDeliveredMonotonicNanoseconds
        self.sigcontReturnCode =
            sigcontReturnCode
        self.childTerminationObservedMonotonicNanoseconds =
            childTerminationObservedMonotonicNanoseconds
        self.preReapProcessGroupMemberIdentifiers =
            preReapProcessGroupMemberIdentifiers
        self.preReapProcessGroupMembersObservedMonotonicNanoseconds =
            preReapProcessGroupMembersObservedMonotonicNanoseconds
        self.childReapedMonotonicNanoseconds =
            childReapedMonotonicNanoseconds
        self.processGroupEmptyObservedMonotonicNanoseconds =
            processGroupEmptyObservedMonotonicNanoseconds
        self.descriptorRevalidatedAfterReapMonotonicNanoseconds =
            descriptorRevalidatedAfterReapMonotonicNanoseconds
        self.sourceClosureMutationGuard =
            sourceClosureMutationGuard
        self.scratchNamespace =
            scratchNamespace
        self.workingDirectory = workingDirectory
        self.preSpawnDescriptor =
            preSpawnDescriptor
        self.preResumeDescriptor =
            preResumeDescriptor
        self.postReapDescriptor =
            postReapDescriptor
        self.allMappedRegionQueries =
            allMappedRegionQueries
        self.terminalMappedRegionQueryAddress =
            terminalMappedRegionQueryAddress
        self.terminalMappedRegionQueryReturnByteCount =
            terminalMappedRegionQueryReturnByteCount
        self.terminalMappedRegionQueryErrno =
            terminalMappedRegionQueryErrno
        self.mappedRegionEnumerationCompleted =
            mappedRegionEnumerationCompleted
        matchingMappedRegions =
            allMappedRegionQueries
            .map(\.region)
            .filter {
                $0.deviceID
                        == preSpawnDescriptor.deviceID
                    && $0.inode
                        == preSpawnDescriptor.inode
            }
        self.exactPIDWaitObservation =
            exactPIDWaitObservation
        self.deadlineExpired = deadlineExpired
        self.sigtermDelivered = sigtermDelivered
        self.sigkillDelivered = sigkillDelivered
        self.processGroupEmptyAfterReap =
            processGroupEmptyAfterReap
        self.procPIDPathUsedOnlyAsTelemetry =
            procPIDPathUsedOnlyAsTelemetry
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedSupervisorProcessIdentifier:
            Int32,
        expectedChildProcessIdentifier:
            Int32
    ) throws {
        try preSpawnDescriptor.validate(
            against: contract
        )
        try preResumeDescriptor.validate(
            against: contract
        )
        try postReapDescriptor.validate(
            against: contract
        )
        try workingDirectory.validate()
        try sourceClosureMutationGuard
            .validate(
                against: contract
            )
        try scratchNamespace.validate(
            role: role
        )
        try exactPIDWaitObservation.validate(
            expectedChildProcessIdentifier:
                expectedChildProcessIdentifier
        )
        var nextQueryAddress: UInt64 = 0
        var queryTranscriptValid =
            !allMappedRegionQueries.isEmpty
            && allMappedRegionQueries.count
                <= 65_536
        for query in allMappedRegionQueries {
            let end = query.region.address
                .addingReportingOverflow(
                    query.region.byteCount
                )
            guard queryTranscriptValid,
                  query.queryAddress
                    == nextQueryAddress,
                  query.returnedByteCount
                    == procRegionWithPathInfoByteCount,
                  query.region.address
                    >= query.queryAddress,
                  query.region.byteCount > 0,
                  !end.overflow,
                  end.partialValue
                    > query.region.address
            else {
                queryTranscriptValid = false
                break
            }
            nextQueryAddress = end.partialValue
        }
        let completeEnumerationValid =
            queryTranscriptValid
            && nextQueryAddress > 0
            && terminalMappedRegionQueryAddress
                == nextQueryAddress
            && terminalMappedRegionQueryReturnByteCount
                == 0
            && terminalMappedRegionQueryErrno
                == contract
                .swiftPackageDescribeMappedRegionTerminalErrno
            && mappedRegionEnumerationCompleted
        let expectedMatchingRegions =
            allMappedRegionQueries
            .map(\.region)
            .filter {
                $0.deviceID
                        == preSpawnDescriptor.deviceID
                    && $0.inode
                        == preSpawnDescriptor.inode
            }
        let addresses =
            matchingMappedRegions.map(\.address)
        let addressSet = Set(addresses)
        let regionsValid =
            !matchingMappedRegions.isEmpty
            && addresses == addresses.sorted()
            && addressSet.count == addresses.count
            && matchingMappedRegions.allSatisfy {
                let end = $0.address
                    .addingReportingOverflow(
                        $0.byteCount
                    )
                return $0.address > 0
                    && $0.byteCount > 0
                    && !end.overflow
                    && end.partialValue
                        > $0.address
                    && $0.protection > 0
                    && ($0.protection & 0x6) != 0x6
                    && $0.deviceID
                        == preSpawnDescriptor
                        .deviceID
                    && $0.inode
                        == preSpawnDescriptor.inode
            }
            && matchingMappedRegions.contains {
                // `VM_PROT_EXECUTE` is the calibrated Darwin bit 0x4.
                // The offset-zero mapping itself must carry executable code;
                // a split header/data mapping plus unrelated executable
                // mapping cannot jointly satisfy this identity predicate.
                $0.fileOffset == 0
                    && ($0.protection & 0x4) != 0
            }
        let expectedSpawnFlags =
            posixSpawnStartSuspendedFlag
            | posixSpawnCloseOnExecDefaultFlag
            | posixSpawnSetSessionFlag
            | posixSpawnSetSignalDefaultsFlag
            | posixSpawnSetSignalMaskFlag
        guard schemaVersion == 4,
              artifactKind
                == "ergentics_prime_native_neural_gate_external_child_capture_evidence",
              supervisorProcessIdentifier
                == expectedSupervisorProcessIdentifier,
              childProcessIdentifier
                == expectedChildProcessIdentifier,
              supervisorProcessIdentifier > 0,
              childProcessIdentifier > 0,
              supervisorProcessIdentifier
                != childProcessIdentifier,
              scratchNamespace.role == role,
              captureAuthority
                == contract
                .swiftPackageDescribeMappedChildImageCaptureAuthority,
              mappedRegionEnumerationPolicy
                == contract
                .swiftPackageDescribeMappedRegionEnumerationPolicy,
              capabilityCalibrationPolicy
                == contract
                .swiftPackageDescribeCaptureCapabilityCalibrationPolicy,
              contract
                .swiftPackageDescribeCaptureCapabilityCalibrationRequired,
              capabilityCalibrationPassed,
              posixSpawnStartSuspendedFlag
                == 0x0080,
              posixSpawnCloseOnExecDefaultFlag
                == 0x4000,
              posixSpawnSetSessionFlag
                == 0x0400,
              posixSpawnSetSignalDefaultsFlag
                == 0x0004,
              posixSpawnSetSignalMaskFlag
                == 0x0008,
              appliedSpawnFlags
                == expectedSpawnFlags,
              appliedSpawnFlags == 0x448c,
              observedChildSessionIdentifier
                == childProcessIdentifier,
              observedChildProcessGroupIdentifier
                == childProcessIdentifier,
              emptySignalMaskConfigured,
              defaultSignalDispositionsConfigured,
              terminationSignalsTargetProcessGroup,
              contract
                .swiftPackageDescribeIsolatedSessionRequired,
              contract
                .swiftPackageDescribeDedicatedProcessGroupRequired,
              contract
                .swiftPackageDescribeGroupDirectedTerminationSignalsRequired,
              contract
                .swiftPackageDescribeNormalizedSignalMaskRequired,
              contract
                .swiftPackageDescribeNormalizedSignalDispositionsRequired,
              posixSpawnReturnCode == 0,
              procPIDRegionPathInfoFlavor
                == 8,
              procRegionWithPathInfoByteCount
                == 1_272,
              descriptorOpenedMonotonicNanoseconds
                > 0,
              sourceClosureMutationGuard
                .initialValidationMonotonicNanoseconds
                <= descriptorOpenedMonotonicNanoseconds,
              descriptorOpenedMonotonicNanoseconds
                < spawnReturnedMonotonicNanoseconds,
              spawnReturnedMonotonicNanoseconds
                <= childSessionAndProcessGroupObservedMonotonicNanoseconds,
              childSessionAndProcessGroupObservedMonotonicNanoseconds
                <= workingDirectoryCapturedMonotonicNanoseconds,
              workingDirectoryCapturedMonotonicNanoseconds
                <= mappedRegionCapturedMonotonicNanoseconds,
              mappedRegionCapturedMonotonicNanoseconds
                <= descriptorRevalidatedBeforeResumeMonotonicNanoseconds,
              descriptorRevalidatedBeforeResumeMonotonicNanoseconds
                <= sourceClosureMutationGuard
                    .preResumeValidationMonotonicNanoseconds,
              sourceClosureMutationGuard
                .preResumeValidationMonotonicNanoseconds
                <= scratchNamespace
                    .preResumeValidationMonotonicNanoseconds,
              scratchNamespace
                .preResumeValidationMonotonicNanoseconds
                < sigcontDeliveredMonotonicNanoseconds,
              sigcontReturnCode == 0,
              sigcontDeliveredMonotonicNanoseconds
                < childTerminationObservedMonotonicNanoseconds,
              childTerminationObservedMonotonicNanoseconds
                <= preReapProcessGroupMembersObservedMonotonicNanoseconds,
              preReapProcessGroupMemberIdentifiers
                == [
                    childProcessIdentifier,
                ],
              preReapProcessGroupMembersObservedMonotonicNanoseconds
                <= childReapedMonotonicNanoseconds,
              childReapedMonotonicNanoseconds
                <= processGroupEmptyObservedMonotonicNanoseconds,
              processGroupEmptyObservedMonotonicNanoseconds
                <= descriptorRevalidatedAfterReapMonotonicNanoseconds,
              descriptorRevalidatedAfterReapMonotonicNanoseconds
                <= sourceClosureMutationGuard
                    .postReapValidationMonotonicNanoseconds,
              sourceClosureMutationGuard
                .postReapValidationMonotonicNanoseconds
                <= scratchNamespace
                    .postReapValidationMonotonicNanoseconds,
              preSpawnDescriptor
                == preResumeDescriptor,
              preSpawnDescriptor
                == postReapDescriptor,
              completeEnumerationValid,
              matchingMappedRegions
                == expectedMatchingRegions,
              regionsValid,
              contract
                .swiftPackageDescribeExactPIDWaitObservationRequired,
              preReapProcessGroupMembersObservedMonotonicNanoseconds
                <= exactPIDWaitObservation
                .returnedMonotonicNanoseconds,
              childReapedMonotonicNanoseconds
                == exactPIDWaitObservation
                .returnedMonotonicNanoseconds,
              !deadlineExpired,
              !sigtermDelivered,
              !sigkillDelivered,
              processGroupEmptyAfterReap,
              contract
                .swiftPackageDescribeProcessGroupEmptyAfterReapRequired,
              contract
                .swiftPackageDescribeDescriptorRootedWorkingDirectoryRequired,
              contract
                .swiftPackageDescribeSuspendedChildWorkingDirectoryVnodeJoinRequired,
              procPIDPathUsedOnlyAsTelemetry,
              !contract
                .swiftPackageDescribeProcPIDPathAuthoritative
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_external_child_capture_evidence"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case supervisorProcessIdentifier =
            "supervisor_process_identifier"
        case childProcessIdentifier =
            "child_process_identifier"
        case role
        case captureAuthority =
            "capture_authority"
        case mappedRegionEnumerationPolicy =
            "mapped_region_enumeration_policy"
        case capabilityCalibrationPolicy =
            "capability_calibration_policy"
        case capabilityCalibrationPassed =
            "capability_calibration_passed"
        case posixSpawnStartSuspendedFlag =
            "posix_spawn_start_suspended_flag"
        case posixSpawnCloseOnExecDefaultFlag =
            "posix_spawn_close_on_exec_default_flag"
        case posixSpawnSetSessionFlag =
            "posix_spawn_set_session_flag"
        case posixSpawnSetSignalDefaultsFlag =
            "posix_spawn_set_signal_defaults_flag"
        case posixSpawnSetSignalMaskFlag =
            "posix_spawn_set_signal_mask_flag"
        case appliedSpawnFlags =
            "applied_spawn_flags"
        case observedChildSessionIdentifier =
            "observed_child_session_identifier"
        case observedChildProcessGroupIdentifier =
            "observed_child_process_group_identifier"
        case emptySignalMaskConfigured =
            "empty_signal_mask_configured"
        case defaultSignalDispositionsConfigured =
            "default_signal_dispositions_configured"
        case terminationSignalsTargetProcessGroup =
            "termination_signals_target_process_group"
        case posixSpawnReturnCode =
            "posix_spawn_return_code"
        case procPIDRegionPathInfoFlavor =
            "proc_pidregionpathinfo_flavor"
        case procRegionWithPathInfoByteCount =
            "proc_regionwithpathinfo_byte_count"
        case descriptorOpenedMonotonicNanoseconds =
            "descriptor_opened_monotonic_nanoseconds"
        case spawnReturnedMonotonicNanoseconds =
            "spawn_returned_monotonic_nanoseconds"
        case childSessionAndProcessGroupObservedMonotonicNanoseconds =
            "child_session_and_process_group_observed_monotonic_nanoseconds"
        case workingDirectoryCapturedMonotonicNanoseconds =
            "working_directory_captured_monotonic_nanoseconds"
        case mappedRegionCapturedMonotonicNanoseconds =
            "mapped_region_captured_monotonic_nanoseconds"
        case descriptorRevalidatedBeforeResumeMonotonicNanoseconds =
            "descriptor_revalidated_before_resume_monotonic_nanoseconds"
        case sigcontDeliveredMonotonicNanoseconds =
            "sigcont_delivered_monotonic_nanoseconds"
        case sigcontReturnCode =
            "sigcont_return_code"
        case childTerminationObservedMonotonicNanoseconds =
            "child_termination_observed_monotonic_nanoseconds"
        case preReapProcessGroupMemberIdentifiers =
            "pre_reap_process_group_member_identifiers"
        case preReapProcessGroupMembersObservedMonotonicNanoseconds =
            "pre_reap_process_group_members_observed_monotonic_nanoseconds"
        case childReapedMonotonicNanoseconds =
            "child_reaped_monotonic_nanoseconds"
        case processGroupEmptyObservedMonotonicNanoseconds =
            "process_group_empty_observed_monotonic_nanoseconds"
        case descriptorRevalidatedAfterReapMonotonicNanoseconds =
            "descriptor_revalidated_after_reap_monotonic_nanoseconds"
        case sourceClosureMutationGuard =
            "source_closure_mutation_guard"
        case scratchNamespace =
            "scratch_namespace"
        case workingDirectory =
            "working_directory"
        case preSpawnDescriptor =
            "pre_spawn_descriptor"
        case preResumeDescriptor =
            "pre_resume_descriptor"
        case postReapDescriptor =
            "post_reap_descriptor"
        case allMappedRegionQueries =
            "all_mapped_region_queries"
        case terminalMappedRegionQueryAddress =
            "terminal_mapped_region_query_address"
        case terminalMappedRegionQueryReturnByteCount =
            "terminal_mapped_region_query_return_byte_count"
        case terminalMappedRegionQueryErrno =
            "terminal_mapped_region_query_errno"
        case mappedRegionEnumerationCompleted =
            "mapped_region_enumeration_completed"
        case matchingMappedRegions =
            "matching_mapped_regions"
        case exactPIDWaitObservation =
            "exact_pid_wait_observation"
        case deadlineExpired = "deadline_expired"
        case sigtermDelivered = "sigterm_delivered"
        case sigkillDelivered = "sigkill_delivered"
        case processGroupEmptyAfterReap =
            "process_group_empty_after_reap"
        case procPIDPathUsedOnlyAsTelemetry =
            "proc_pidpath_used_only_as_telemetry"
    }
}

struct PrimeNativeNeuralGateTrustedExternalChildLaunchObservation:
    Equatable,
    Sendable
{
    let role: PrimeNativeNeuralGateReleaseProcessRole
    let exactArguments: [String]
    let exactEnvironmentKeys: [String]
    let exactEnvironment: [String]
    let environmentPolicy: String
    let scratchNamespace:
        PrimeNativeNeuralGateScratchNamespaceObservation
    let directProcessWithoutShell: Bool
    let workingDirectoryAbsolutePath: String
    let workingDirectoryIsValidatedPrimeRoot: Bool
    let environmentKeyCount: Int
    let standardInputPolicy: String
    let maximumWallSeconds: UInt64
    let terminationControlPolicy: String
}

struct PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation:
    Equatable,
    Sendable
{
    let maximumStandardOutputBytes: UInt64
    let standardOutputOverflowed: Bool
    let standardOutputDrainCompleted: Bool
    let maximumStandardErrorBytes: UInt64
    let standardErrorOverflowed: Bool
    let standardErrorDrainCompleted: Bool
}

public struct PrimeNativeNeuralGateTrustedExternalChildCapture:
    Sendable
{
    private let evidenceSHA256: String
    private let swiftPackageExecutableAbsolutePath:
        String
    private let mappedChildMainImageAbsolutePath:
        String
    private let preSpawnDescriptorReadSnapshot:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    private let preSpawnDescriptorReadSHA256: String
    private let preSpawnDescriptorReadByteCount: UInt64
    private let preResumeDescriptorReadSnapshot:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    private let preResumeDescriptorReadSHA256: String
    private let preResumeDescriptorReadByteCount: UInt64
    private let postReapDescriptorReadSnapshot:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    private let postReapDescriptorReadSHA256: String
    private let postReapDescriptorReadByteCount: UInt64
    private let workingDirectoryObservation:
        PrimeNativeNeuralGateWorkingDirectoryObservation
    private let scratchNamespaceObservation:
        PrimeNativeNeuralGateScratchNamespaceObservation
    private let primeSourceSnapshotSHA256: String
    private let primeSourceSnapshotByteCount: UInt64
    private let primeSourceIdentitySHA256: String
    private let primeSourceFileCount: Int
    private let primeSourceDirectoryCount: Int
    private let primeSourceAggregateByteCount:
        UInt64
    private let standardOutputSHA256: String
    private let standardOutputByteCount: UInt64
    private let standardErrorSHA256: String
    private let standardErrorByteCount: UInt64
    private let launchObservation:
        PrimeNativeNeuralGateTrustedExternalChildLaunchObservation
    private let streamLifecycleObservation:
        PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation

    init(
        evidence:
            PrimeNativeNeuralGateExternalChildCaptureEvidence,
        swiftPackageExecutableAbsolutePath:
            String,
        mappedChildMainImageAbsolutePath:
            String,
        preSpawnDescriptorReadSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        preSpawnDescriptorReadData: Data,
        preResumeDescriptorReadSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        preResumeDescriptorReadData: Data,
        postReapDescriptorReadSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        postReapDescriptorReadData: Data,
        validatedPrimeSourceSnapshot:
            PrimeSwiftSourceSnapshot,
        standardOutputData: Data,
        standardErrorData: Data,
        launchObservation:
            PrimeNativeNeuralGateTrustedExternalChildLaunchObservation,
        streamLifecycleObservation:
            PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation
    ) throws {
        let evidenceData =
            try PrimeCanonicalJSON.encode(evidence)
        evidenceSHA256 =
            PrimeSHA256.hexDigest(of: evidenceData)
        self.swiftPackageExecutableAbsolutePath =
            swiftPackageExecutableAbsolutePath
        self.mappedChildMainImageAbsolutePath =
            mappedChildMainImageAbsolutePath
        self.preSpawnDescriptorReadSnapshot =
            preSpawnDescriptorReadSnapshot
        preSpawnDescriptorReadSHA256 =
            PrimeSHA256.hexDigest(
                of: preSpawnDescriptorReadData
            )
        preSpawnDescriptorReadByteCount =
            UInt64(preSpawnDescriptorReadData.count)
        self.preResumeDescriptorReadSnapshot =
            preResumeDescriptorReadSnapshot
        preResumeDescriptorReadSHA256 =
            PrimeSHA256.hexDigest(
                of: preResumeDescriptorReadData
            )
        preResumeDescriptorReadByteCount =
            UInt64(preResumeDescriptorReadData.count)
        self.postReapDescriptorReadSnapshot =
            postReapDescriptorReadSnapshot
        postReapDescriptorReadSHA256 =
            PrimeSHA256.hexDigest(
                of: postReapDescriptorReadData
            )
        postReapDescriptorReadByteCount =
            UInt64(postReapDescriptorReadData.count)
        workingDirectoryObservation =
            evidence.workingDirectory
        scratchNamespaceObservation =
            evidence.scratchNamespace
        let sourceSnapshotData =
            try PrimeCanonicalJSON.encode(
                validatedPrimeSourceSnapshot
            )
        primeSourceSnapshotSHA256 =
            PrimeSHA256.hexDigest(
                of: sourceSnapshotData
            )
        primeSourceSnapshotByteCount =
            UInt64(sourceSnapshotData.count)
        primeSourceIdentitySHA256 =
            validatedPrimeSourceSnapshot
            .sourceIdentitySHA256
        primeSourceFileCount =
            validatedPrimeSourceSnapshot
            .files.count
        var sourceDirectories:
            Set<String> = [""]
        var sourceAggregate: UInt64 = 0
        for file in
            validatedPrimeSourceSnapshot.files
        {
            let next =
                sourceAggregate
                .addingReportingOverflow(
                    file.byteCount
                )
            guard !next.overflow else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "trusted_source_snapshot_aggregate"
                    )
            }
            sourceAggregate =
                next.partialValue
            let components =
                file.relativePath.split(
                    separator: "/"
                )
            if components.count > 1 {
                for count in
                    1 ..< components.count
                {
                    sourceDirectories
                        .insert(
                            components
                            .prefix(count)
                            .joined(
                                separator:
                                    "/"
                            )
                        )
                }
            }
        }
        primeSourceDirectoryCount =
            sourceDirectories.count
        primeSourceAggregateByteCount =
            sourceAggregate
        standardOutputSHA256 =
            PrimeSHA256.hexDigest(
                of: standardOutputData
            )
        standardOutputByteCount =
            UInt64(standardOutputData.count)
        standardErrorSHA256 =
            PrimeSHA256.hexDigest(
                of: standardErrorData
            )
        standardErrorByteCount =
            UInt64(standardErrorData.count)
        self.launchObservation =
            launchObservation
        self.streamLifecycleObservation =
            streamLifecycleObservation
    }

    func validate(
        evidence:
            PrimeNativeNeuralGateExternalChildCaptureEvidence,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedSwiftPackageExecutableAbsolutePath:
            String,
        expectedMappedChildMainImageAbsolutePath:
            String,
        expectedPrimeSourceSnapshot:
            PrimeArtifactBinding,
        standardOutputData: Data,
        captureLaunchObservation:
            PrimeNativeNeuralGateTrustedExternalChildLaunchObservation,
        captureStreamLifecycleObservation:
            PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation
    ) throws {
        let evidenceData =
            try PrimeCanonicalJSON.encode(evidence)
        guard evidenceSHA256
                == PrimeSHA256.hexDigest(
                    of: evidenceData
                ),
              contract
                .swiftPackageDescribeTrustedCaptureCapabilityRequired,
              contract
                .swiftPackageDescribeTrustedCaptureCapabilityAuthority
                == "primecore_non_codable_factory_result_binding_role_exact_launch_arguments_and_environment_fresh_scratch_namespace_exact_optional_text_encoding_work_lock_bounded_opaque_provenance_bounded_post_audit_three_descriptor_read_checkpoints_fstat_source_snapshot_held_source_closure_mutation_guard_direct_pid_to_isolated_session_process_group_authority_working_root_region_transcript_pre_reap_group_members_exact_once_waitpid_and_eof_stream_lifecycle_v8",
              preSpawnDescriptorReadSnapshot
                == evidence.preSpawnDescriptor,
              preResumeDescriptorReadSnapshot
                == evidence.preResumeDescriptor,
              postReapDescriptorReadSnapshot
                == evidence.postReapDescriptor,
              workingDirectoryObservation
                == evidence.workingDirectory,
              scratchNamespaceObservation
                == evidence.scratchNamespace,
              launchObservation
                .scratchNamespace
                == evidence.scratchNamespace,
              swiftPackageExecutableAbsolutePath
                == expectedSwiftPackageExecutableAbsolutePath,
              mappedChildMainImageAbsolutePath
                == expectedMappedChildMainImageAbsolutePath,
              preSpawnDescriptorReadSHA256
                == evidence
                .preSpawnDescriptor.sha256,
              preResumeDescriptorReadSHA256
                == evidence
                .preResumeDescriptor.sha256,
              postReapDescriptorReadSHA256
                == evidence
                .postReapDescriptor.sha256,
              preSpawnDescriptorReadSHA256
                == contract
                .swiftPackageDescribeExpectedExecutableSHA256,
              preResumeDescriptorReadSHA256
                == preSpawnDescriptorReadSHA256,
              postReapDescriptorReadSHA256
                == preSpawnDescriptorReadSHA256,
              preSpawnDescriptorReadByteCount
                == evidence
                .preSpawnDescriptor.byteCount,
              preResumeDescriptorReadByteCount
                == evidence
                .preResumeDescriptor.byteCount,
              postReapDescriptorReadByteCount
                == evidence
                .postReapDescriptor.byteCount,
              preSpawnDescriptorReadByteCount
                == contract
                .swiftPackageDescribeExpectedExecutableByteCount,
              preResumeDescriptorReadByteCount
                == preSpawnDescriptorReadByteCount,
              postReapDescriptorReadByteCount
                == preSpawnDescriptorReadByteCount,
              primeSourceSnapshotSHA256
                == expectedPrimeSourceSnapshot.sha256,
              evidence
                .sourceClosureMutationGuard
                .sourceSnapshotSHA256
                == primeSourceSnapshotSHA256,
              primeSourceSnapshotByteCount
                == expectedPrimeSourceSnapshot.byteCount,
              evidence
                .sourceClosureMutationGuard
                .heldFileDescriptorCount
                == primeSourceFileCount,
              evidence
                .sourceClosureMutationGuard
                .heldDirectoryDescriptorCount
                == primeSourceDirectoryCount,
              evidence
                .sourceClosureMutationGuard
                .aggregateFileByteCount
                == primeSourceAggregateByteCount,
              primeSourceIdentitySHA256.count == 64,
              standardOutputSHA256
                == PrimeSHA256.hexDigest(
                    of: standardOutputData
                ),
              standardOutputByteCount
                == UInt64(
                    standardOutputData.count
                ),
              standardErrorSHA256
                == PrimeSHA256.hexDigest(
                    of: Data()
                ),
              standardErrorByteCount == 0,
              launchObservation
                == captureLaunchObservation,
              streamLifecycleObservation
                == captureStreamLifecycleObservation
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "trusted_external_child_capture"
                )
        }
    }
}

public enum PrimeNativeNeuralGateSwiftPackageDescribeTerminationDisposition:
    String,
    Codable,
    Equatable,
    Sendable
{
    case cleanExitZero = "clean_exit_zero"
    case notCleanExit = "not_clean_exit"
}

public struct PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let recordRelativePath: String
    public let planSHA256: String
    public let supervisorProcessIdentifier:
        Int32
    public let childProcessIdentifier: Int32
    public let swiftPackageExecutableAbsolutePath:
        String
    public let swiftPackageExecutableSHA256: String
    public let swiftPackageExecutableByteCount: UInt64
    public let mappedChildMainImageAbsolutePath:
        String
    public let mappedChildMainImageSHA256: String
    public let mappedChildMainImageByteCount:
        UInt64
    public let mappedChildMainImageObservedDeviceID:
        UInt64
    public let mappedChildMainImageObservedInode:
        UInt64
    public let mappedChildMainImageDescriptorDeviceID:
        UInt64
    public let mappedChildMainImageDescriptorInode:
        UInt64
    public let mappedChildMainImageVnodeIdentityJoined:
        Bool
    public let mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath:
        Bool
    public let mappedChildMainImageCaptureAuthority:
        String
    public let mappedRegionEnumerationPolicy:
        String
    public let captureCapabilityCalibrationPassed:
        Bool
    public let procPIDPathUsedOnlyAsTelemetry:
        Bool
    public let mappedChildMainImageCapturedWhileSuspendedBeforeResume:
        Bool
    public let externalChildCaptureEvidence:
        PrimeNativeNeuralGateExternalChildCaptureEvidence
    public let scratchNamespace:
        PrimeNativeNeuralGateScratchNamespaceObservation
    public let exactArguments: [String]
    public let exactEnvironmentKeys: [String]
    public let exactEnvironment: [String]
    public let environmentPolicy: String
    public let directProcessWithoutShell: Bool
    public let workingDirectoryAbsolutePath:
        String
    public let workingDirectoryIsValidatedPrimeRoot:
        Bool
    public let environmentKeyCount: Int
    public let standardInputPolicy: String
    public let maximumWallSeconds: UInt64
    public let observedMonotonicWallNanoseconds:
        UInt64
    public let maximumStandardOutputBytes:
        UInt64
    public let maximumStandardErrorBytes:
        UInt64
    public let standardOutput:
        PrimeArtifactBinding
    public let standardOutputOverflowed:
        Bool
    public let standardOutputDrainCompleted:
        Bool
    public let standardErrorByteCount: UInt64
    public let standardErrorSHA256: String
    public let standardErrorOverflowed:
        Bool
    public let standardErrorDrainCompleted:
        Bool
    public let exitStatus: Int32
    public let termination:
        PrimeNativeNeuralGateSwiftPackageDescribeTerminationDisposition
    public let terminationControlPolicy: String
    public let childTerminationObserved: Bool
    public let childReaped: Bool
    public let prePrimeSourceState:
        PrimeNativeNeuralGatePrimeGitStateRecord
    public let postPrimeSourceState:
        PrimeNativeNeuralGatePrimeGitStateRecord
    public let preSourceSnapshotSHA256:
        String
    public let postSourceSnapshotSHA256:
        String
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let packageManifest:
        PrimeNativeNeuralGateSourceFileIdentity

    init(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        planSHA256: String,
        supervisorProcessIdentifier:
            Int32,
        childProcessIdentifier: Int32,
        swiftPackageExecutableAbsolutePath:
            String,
        mappedChildMainImageAbsolutePath:
            String,
        workingDirectoryAbsolutePath:
            String,
        externalChildCaptureEvidence:
            PrimeNativeNeuralGateExternalChildCaptureEvidence,
        standardOutput:
            PrimeArtifactBinding,
        prePrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        postPrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        packageManifest:
            PrimeNativeNeuralGateSourceFileIdentity,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws {
        schemaVersion = 4
        artifactKind =
            "ergentics_prime_native_neural_gate_swift_package_describe_capture"
        self.role = role
        recordRelativePath =
            contract
            .swiftPackageDescribeCaptureRecordRelativePath(
                for: role
            )
        self.planSHA256 = planSHA256
        self.supervisorProcessIdentifier =
            supervisorProcessIdentifier
        self.childProcessIdentifier =
            childProcessIdentifier
        self.swiftPackageExecutableAbsolutePath =
            swiftPackageExecutableAbsolutePath
        swiftPackageExecutableSHA256 =
            externalChildCaptureEvidence
            .preSpawnDescriptor.sha256
        swiftPackageExecutableByteCount =
            externalChildCaptureEvidence
            .preSpawnDescriptor.byteCount
        self.mappedChildMainImageAbsolutePath =
            mappedChildMainImageAbsolutePath
        mappedChildMainImageSHA256 =
            externalChildCaptureEvidence
            .preSpawnDescriptor.sha256
        mappedChildMainImageByteCount =
            externalChildCaptureEvidence
            .preSpawnDescriptor.byteCount
        self.externalChildCaptureEvidence =
            externalChildCaptureEvidence
        scratchNamespace =
            externalChildCaptureEvidence
            .scratchNamespace
        self.mappedChildMainImageObservedDeviceID =
            externalChildCaptureEvidence
            .matchingMappedRegions.first?
            .deviceID ?? 0
        self.mappedChildMainImageObservedInode =
            externalChildCaptureEvidence
            .matchingMappedRegions.first?
            .inode ?? 0
        self.mappedChildMainImageDescriptorDeviceID =
            externalChildCaptureEvidence
            .preSpawnDescriptor.deviceID
        self.mappedChildMainImageDescriptorInode =
            externalChildCaptureEvidence
            .preSpawnDescriptor.inode
        mappedChildMainImageVnodeIdentityJoined =
            mappedChildMainImageObservedDeviceID > 0
                && mappedChildMainImageObservedInode > 0
                && mappedChildMainImageObservedDeviceID
                    == mappedChildMainImageDescriptorDeviceID
                && mappedChildMainImageObservedInode
                    == mappedChildMainImageDescriptorInode
        mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath =
            externalChildCaptureEvidence
            .preSpawnDescriptor
            .openedWithNoSymbolicLinksInPath
        mappedChildMainImageCaptureAuthority =
            contract
            .swiftPackageDescribeMappedChildImageCaptureAuthority
        mappedRegionEnumerationPolicy =
            externalChildCaptureEvidence
            .mappedRegionEnumerationPolicy
        captureCapabilityCalibrationPassed =
            externalChildCaptureEvidence
            .capabilityCalibrationPassed
        procPIDPathUsedOnlyAsTelemetry =
            externalChildCaptureEvidence
            .procPIDPathUsedOnlyAsTelemetry
        mappedChildMainImageCapturedWhileSuspendedBeforeResume =
            externalChildCaptureEvidence
            .mappedRegionCapturedMonotonicNanoseconds
            < externalChildCaptureEvidence
            .sigcontDeliveredMonotonicNanoseconds
        exactArguments =
            try contract
            .expandedSwiftPackageDescribeArguments(
                scratchRootAbsolutePath:
                    scratchNamespace
                    .runRootAbsolutePath
            )
        exactEnvironmentKeys =
            contract
            .swiftPackageDescribeExactEnvironmentKeys
        let expandedEnvironment =
            try contract
            .expandedSwiftPackageDescribeEnvironment(
                scratchRootAbsolutePath:
                    scratchNamespace
                    .runRootAbsolutePath
            )
        exactEnvironment =
            exactEnvironmentKeys.map {
                "\($0)=\(expandedEnvironment[$0]!)"
            }
        environmentPolicy =
            contract
            .swiftPackageDescribeEnvironmentPolicy
        directProcessWithoutShell = true
        self.workingDirectoryAbsolutePath =
            workingDirectoryAbsolutePath
        workingDirectoryIsValidatedPrimeRoot =
            true
        environmentKeyCount =
            exactEnvironmentKeys.count
        standardInputPolicy = "eof_v1"
        maximumWallSeconds =
            contract
            .swiftPackageDescribeMaximumWallSeconds
        let observedWall =
            externalChildCaptureEvidence
            .scratchNamespace
            .postReapValidationMonotonicNanoseconds
            .subtractingReportingOverflow(
                externalChildCaptureEvidence
                    .descriptorOpenedMonotonicNanoseconds
            )
        observedMonotonicWallNanoseconds =
            observedWall.overflow
            ? 0
            : observedWall.partialValue
        maximumStandardOutputBytes =
            contract
            .swiftPackageDescribeMaximumStandardOutputBytes
        maximumStandardErrorBytes =
            contract
            .swiftPackageDescribeMaximumStandardErrorBytes
        self.standardOutput = standardOutput
        standardOutputOverflowed = false
        standardOutputDrainCompleted = true
        standardErrorByteCount = 0
        standardErrorSHA256 =
            PrimeSHA256.hexDigest(of: Data())
        standardErrorOverflowed = false
        standardErrorDrainCompleted = true
        exitStatus =
            externalChildCaptureEvidence
            .exactPIDWaitObservation.exitStatus
        termination =
            externalChildCaptureEvidence
                .exactPIDWaitObservation
                .exitedNormally
                && exitStatus == 0
            ? .cleanExitZero
            : .notCleanExit
        terminationControlPolicy =
            contract
            .swiftPackageDescribeTerminationEscalationPolicy
        childTerminationObserved =
            externalChildCaptureEvidence
            .exactPIDWaitObservation
            .childTerminationObserved
        childReaped =
            externalChildCaptureEvidence
            .exactPIDWaitObservation
            .childReaped
        self.prePrimeSourceState =
            prePrimeSourceState
        self.postPrimeSourceState =
            postPrimeSourceState
        preSourceSnapshotSHA256 =
            primeSourceSnapshot.sha256
        postSourceSnapshotSHA256 =
            primeSourceSnapshot.sha256
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.packageManifest =
            packageManifest
    }

    public func validateForRunningRelease(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        trustedExternalChildCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        expectedPlanSHA256: String,
        expectedSupervisorProcessIdentifier:
            Int32,
        expectedPrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        expectedPrimeSourceSnapshot:
            PrimeArtifactBinding,
        expectedPackageManifest:
            PrimeNativeNeuralGateSourceFileIdentity,
        expectedStandardOutput:
            PrimeArtifactBinding,
        standardOutputData: Data
    ) throws {
        try contract.validate()
        try validate(
            against: contract,
            trustedExternalChildCapture:
                trustedExternalChildCapture,
            expectedPlanSHA256:
                expectedPlanSHA256,
            expectedSupervisorProcessIdentifier:
                expectedSupervisorProcessIdentifier,
            expectedPrimeSourceState:
                expectedPrimeSourceState,
            expectedPrimeSourceSnapshot:
                expectedPrimeSourceSnapshot,
            expectedPackageManifest:
                expectedPackageManifest,
            expectedStandardOutput:
                expectedStandardOutput,
            standardOutputData:
                standardOutputData
        )
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        trustedExternalChildCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        expectedPlanSHA256: String,
        expectedSupervisorProcessIdentifier:
            Int32,
        expectedPrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        expectedPrimeSourceSnapshot:
            PrimeArtifactBinding,
        expectedPackageManifest:
            PrimeNativeNeuralGateSourceFileIdentity,
        expectedStandardOutput:
            PrimeArtifactBinding,
        standardOutputData: Data
    ) throws {
        try prePrimeSourceState.validate()
        try postPrimeSourceState.validate()
        try primeSourceSnapshot
            .validateDeclaration()
        try packageManifest.validate()
        try standardOutput.validateDeclaration()
        try scratchNamespace.validate(
            role: role
        )
        let expectedArguments =
            try contract
            .expandedSwiftPackageDescribeArguments(
                scratchRootAbsolutePath:
                    scratchNamespace
                    .runRootAbsolutePath
            )
        let expectedEnvironment =
            try contract
            .expandedSwiftPackageDescribeEnvironment(
                scratchRootAbsolutePath:
                    scratchNamespace
                    .runRootAbsolutePath
            )
        let expectedEnvironmentEntries =
            contract
            .swiftPackageDescribeExactEnvironmentKeys
            .map {
                "\($0)=\(expectedEnvironment[$0]!)"
            }
        try trustedExternalChildCapture.validate(
            evidence:
                externalChildCaptureEvidence,
            contract: contract,
            expectedSwiftPackageExecutableAbsolutePath:
                swiftPackageExecutableAbsolutePath,
            expectedMappedChildMainImageAbsolutePath:
                mappedChildMainImageAbsolutePath,
            expectedPrimeSourceSnapshot:
                expectedPrimeSourceSnapshot,
            standardOutputData:
                standardOutputData,
            captureLaunchObservation:
                PrimeNativeNeuralGateTrustedExternalChildLaunchObservation(
                    role: role,
                    exactArguments:
                        exactArguments,
                    exactEnvironmentKeys:
                        exactEnvironmentKeys,
                    exactEnvironment:
                        exactEnvironment,
                    environmentPolicy:
                        environmentPolicy,
                    scratchNamespace:
                        scratchNamespace,
                    directProcessWithoutShell:
                        directProcessWithoutShell,
                    workingDirectoryAbsolutePath:
                        workingDirectoryAbsolutePath,
                    workingDirectoryIsValidatedPrimeRoot:
                        workingDirectoryIsValidatedPrimeRoot,
                    environmentKeyCount:
                        environmentKeyCount,
                    standardInputPolicy:
                        standardInputPolicy,
                    maximumWallSeconds:
                        maximumWallSeconds,
                    terminationControlPolicy:
                        terminationControlPolicy
                ),
            captureStreamLifecycleObservation:
                PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation(
                    maximumStandardOutputBytes:
                        maximumStandardOutputBytes,
                    standardOutputOverflowed:
                        standardOutputOverflowed,
                    standardOutputDrainCompleted:
                        standardOutputDrainCompleted,
                    maximumStandardErrorBytes:
                        maximumStandardErrorBytes,
                    standardErrorOverflowed:
                        standardErrorOverflowed,
                    standardErrorDrainCompleted:
                        standardErrorDrainCompleted
                )
        )
        try externalChildCaptureEvidence.validate(
            against: contract,
            expectedSupervisorProcessIdentifier:
                expectedSupervisorProcessIdentifier,
            expectedChildProcessIdentifier:
                childProcessIdentifier
        )
        let recomputedObservedWall =
            externalChildCaptureEvidence
            .scratchNamespace
            .postReapValidationMonotonicNanoseconds
            .subtractingReportingOverflow(
                externalChildCaptureEvidence
                .descriptorOpenedMonotonicNanoseconds
            )
        let maximumWallNanoseconds =
            maximumWallSeconds
            .multipliedReportingOverflow(
                by: 1_000_000_000
            )
        guard schemaVersion == 4,
              artifactKind
                == "ergentics_prime_native_neural_gate_swift_package_describe_capture",
              recordRelativePath
                == contract
                .swiftPackageDescribeCaptureRecordRelativePath(
                    for: role
                ),
              planSHA256
                == expectedPlanSHA256,
              supervisorProcessIdentifier
                == expectedSupervisorProcessIdentifier,
              supervisorProcessIdentifier > 0,
              childProcessIdentifier > 0,
              childProcessIdentifier
                != supervisorProcessIdentifier,
              swiftPackageExecutableAbsolutePath
                .hasPrefix("/"),
              swiftPackageExecutableAbsolutePath
                != "/",
              !swiftPackageExecutableAbsolutePath
                .contains("\0"),
              URL(
                  fileURLWithPath:
                    swiftPackageExecutableAbsolutePath
              ).standardizedFileURL.path
                == swiftPackageExecutableAbsolutePath,
              URL(
                  fileURLWithPath:
                    swiftPackageExecutableAbsolutePath
              ).lastPathComponent
                == contract
                .swiftPackageDescribeDirectExecutableLeafName,
              swiftPackageExecutableByteCount
                == contract
                .swiftPackageDescribeExpectedExecutableByteCount,
              swiftPackageExecutableSHA256
                == contract
                .swiftPackageDescribeExpectedExecutableSHA256,
              swiftPackageExecutableByteCount
                == externalChildCaptureEvidence
                .preSpawnDescriptor.byteCount,
              swiftPackageExecutableSHA256
                == externalChildCaptureEvidence
                .preSpawnDescriptor.sha256,
              mappedChildMainImageAbsolutePath
                .hasPrefix("/"),
              mappedChildMainImageAbsolutePath
                != "/",
              !mappedChildMainImageAbsolutePath
                .contains("\0"),
              URL(
                  fileURLWithPath:
                    mappedChildMainImageAbsolutePath
              ).standardizedFileURL.path
                == mappedChildMainImageAbsolutePath,
              mappedChildMainImageByteCount
                == contract
                .swiftPackageDescribeExpectedExecutableByteCount,
              mappedChildMainImageSHA256
                == contract
                .swiftPackageDescribeExpectedExecutableSHA256,
              contract
                .swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor,
              mappedChildMainImageAbsolutePath
                == swiftPackageExecutableAbsolutePath,
              mappedChildMainImageByteCount
                == swiftPackageExecutableByteCount,
              mappedChildMainImageSHA256
                == swiftPackageExecutableSHA256,
              contract
                .swiftPackageDescribeExecutableIdentityAuthority
                == "frozen_regular_file_full_file_sha256_byte_count_root_owner_mode_link_no_symlink_any_cloexec_and_live_mapped_vnode_descriptor_join_v2",
              mappedChildMainImageObservedDeviceID
                > 0,
              mappedChildMainImageObservedInode > 0,
              mappedChildMainImageObservedDeviceID
                == mappedChildMainImageDescriptorDeviceID,
              mappedChildMainImageObservedInode
                == mappedChildMainImageDescriptorInode,
              mappedChildMainImageVnodeIdentityJoined,
              mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath,
              mappedChildMainImageCaptureAuthority
                == contract
                .swiftPackageDescribeMappedChildImageCaptureAuthority,
              mappedRegionEnumerationPolicy
                == contract
                .swiftPackageDescribeMappedRegionEnumerationPolicy,
              captureCapabilityCalibrationPassed,
              contract
                .swiftPackageDescribeCaptureCapabilityCalibrationRequired,
              procPIDPathUsedOnlyAsTelemetry,
              !contract
                .swiftPackageDescribeProcPIDPathAuthoritative,
              mappedChildMainImageCapturedWhileSuspendedBeforeResume,
              contract
                .swiftPackageDescribeMappedChildImageCaptureRequired,
              !contract
                .swiftPackageDescribeLaunchPathAloneAuthoritative,
              scratchNamespace
                == externalChildCaptureEvidence
                .scratchNamespace,
              exactArguments
                == expectedArguments,
              exactEnvironmentKeys
                == contract
                .swiftPackageDescribeExactEnvironmentKeys,
              exactEnvironment
                == expectedEnvironmentEntries,
              environmentPolicy
                == contract
                .swiftPackageDescribeEnvironmentPolicy,
              directProcessWithoutShell,
              workingDirectoryAbsolutePath
                .hasPrefix("/"),
              workingDirectoryAbsolutePath
                != "/",
              !workingDirectoryAbsolutePath
                .contains("\0"),
              URL(
                  fileURLWithPath:
                    workingDirectoryAbsolutePath
              ).standardizedFileURL.path
                == workingDirectoryAbsolutePath,
              workingDirectoryIsValidatedPrimeRoot,
              environmentKeyCount
                == exactEnvironmentKeys.count,
              environmentKeyCount == 4,
              standardInputPolicy == "eof_v1",
              maximumWallSeconds
                == contract
                .swiftPackageDescribeMaximumWallSeconds,
              observedMonotonicWallNanoseconds
                > 0,
              !recomputedObservedWall.overflow,
              observedMonotonicWallNanoseconds
                == recomputedObservedWall
                .partialValue,
              !maximumWallNanoseconds.overflow,
              observedMonotonicWallNanoseconds
                <= maximumWallNanoseconds
                    .partialValue,
              maximumStandardOutputBytes
                == contract
                .swiftPackageDescribeMaximumStandardOutputBytes,
              maximumStandardErrorBytes
                == contract
                .swiftPackageDescribeMaximumStandardErrorBytes,
              standardOutput
                == expectedStandardOutput,
              standardOutput.relativePath
                == contract
                .swiftPackageDescribeRelativePath,
              standardOutput.purpose
                == .immutableData,
              standardOutput.byteCount
                == UInt64(
                    standardOutputData.count
                ),
              standardOutput.byteCount
                <= maximumStandardOutputBytes,
              standardOutput.sha256
                == PrimeSHA256.hexDigest(
                    of: standardOutputData
                ),
              !standardOutputOverflowed,
              standardOutputDrainCompleted,
              standardErrorByteCount == 0,
              standardErrorSHA256
                == PrimeSHA256.hexDigest(
                    of: Data()
                ),
              !standardErrorOverflowed,
              standardErrorDrainCompleted,
              exitStatus == 0,
              termination == .cleanExitZero,
              terminationControlPolicy
                == contract
                .swiftPackageDescribeTerminationEscalationPolicy,
              childTerminationObserved,
              childReaped,
              contract
                .swiftPackageDescribeOutputOverflowRejected,
              contract
                .swiftPackageDescribeChildDeathObservedBeforeContinuationRequired,
              contract
                .swiftPackageDescribeChildReapBeforeContinuationRequired,
              prePrimeSourceState
                == expectedPrimeSourceState,
              postPrimeSourceState
                == expectedPrimeSourceState,
              preSourceSnapshotSHA256
                == expectedPrimeSourceSnapshot.sha256,
              postSourceSnapshotSHA256
                == expectedPrimeSourceSnapshot.sha256,
              primeSourceSnapshot
                == expectedPrimeSourceSnapshot,
              packageManifest
                == expectedPackageManifest
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_capture"
                )
        }
    }

    public func artifactBinding()
        throws -> PrimeArtifactBinding
    {
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath: recordRelativePath,
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    public static func validateProbeVerifierPairOfPrevalidatedRecords(
        probe:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        verifier:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
    ) throws {
        let processIdentifiers: Set<Int32> = [
            probe.supervisorProcessIdentifier,
            probe.childProcessIdentifier,
            verifier.supervisorProcessIdentifier,
            verifier.childProcessIdentifier,
        ]
        let probeArgumentTemplate =
            probe.exactArguments.map {
                $0.replacingOccurrences(
                    of:
                        probe.scratchNamespace
                        .runRootAbsolutePath,
                    with: "{scratch_root}"
                )
            }
        let verifierArgumentTemplate =
            verifier.exactArguments.map {
                $0.replacingOccurrences(
                    of:
                        verifier
                        .scratchNamespace
                        .runRootAbsolutePath,
                    with: "{scratch_root}"
                )
            }
        let probeEnvironmentTemplate =
            probe.exactEnvironment.map {
                $0.replacingOccurrences(
                    of:
                        probe.scratchNamespace
                        .runRootAbsolutePath,
                    with: "{scratch_root}"
                )
            }
        let verifierEnvironmentTemplate =
            verifier.exactEnvironment.map {
                $0.replacingOccurrences(
                    of:
                        verifier
                        .scratchNamespace
                        .runRootAbsolutePath,
                    with: "{scratch_root}"
                )
            }
        guard probe.role == .probe,
              verifier.role == .verifier,
              processIdentifiers.count == 4,
              probe.recordRelativePath
                != verifier.recordRelativePath,
              probe.swiftPackageExecutableAbsolutePath
                == verifier
                .swiftPackageExecutableAbsolutePath,
              probe.swiftPackageExecutableSHA256
                == verifier
                .swiftPackageExecutableSHA256,
              probe.swiftPackageExecutableByteCount
                == verifier
                .swiftPackageExecutableByteCount,
              probe.mappedChildMainImageAbsolutePath
                == verifier
                .mappedChildMainImageAbsolutePath,
              probe.mappedChildMainImageSHA256
                == verifier
                .mappedChildMainImageSHA256,
              probe.mappedChildMainImageByteCount
                == verifier
                .mappedChildMainImageByteCount,
              probe
                .mappedChildMainImageObservedDeviceID
                == verifier
                .mappedChildMainImageObservedDeviceID,
              probe
                .mappedChildMainImageObservedInode
                == verifier
                .mappedChildMainImageObservedInode,
              probe
                .mappedChildMainImageDescriptorDeviceID
                == verifier
                .mappedChildMainImageDescriptorDeviceID,
              probe
                .mappedChildMainImageDescriptorInode
                == verifier
                .mappedChildMainImageDescriptorInode,
              probe
                .mappedChildMainImageVnodeIdentityJoined,
              verifier
                .mappedChildMainImageVnodeIdentityJoined,
              probe
                .mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath,
              verifier
                .mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath,
              probe.mappedChildMainImageCaptureAuthority
                == verifier
                .mappedChildMainImageCaptureAuthority,
              probe.mappedRegionEnumerationPolicy
                == verifier
                .mappedRegionEnumerationPolicy,
              probe.captureCapabilityCalibrationPassed,
              verifier.captureCapabilityCalibrationPassed,
              probe.procPIDPathUsedOnlyAsTelemetry,
              verifier.procPIDPathUsedOnlyAsTelemetry,
              probe
                .mappedChildMainImageCapturedWhileSuspendedBeforeResume,
              verifier
                .mappedChildMainImageCapturedWhileSuspendedBeforeResume,
              probe.scratchNamespace.role
                == .probe,
              verifier.scratchNamespace.role
                == .verifier,
              probe.scratchNamespace
                .runRootAbsolutePath
                != verifier.scratchNamespace
                .runRootAbsolutePath,
              probeArgumentTemplate
                == verifierArgumentTemplate,
              probe.exactEnvironmentKeys
                == verifier
                .exactEnvironmentKeys,
              probeEnvironmentTemplate
                == verifierEnvironmentTemplate,
              probe.environmentPolicy
                == verifier
                .environmentPolicy,
              probe.directProcessWithoutShell,
              verifier.directProcessWithoutShell,
              probe.workingDirectoryAbsolutePath
                == verifier
                .workingDirectoryAbsolutePath,
              probe.workingDirectoryIsValidatedPrimeRoot,
              verifier.workingDirectoryIsValidatedPrimeRoot,
              probe.environmentKeyCount == 4,
              verifier.environmentKeyCount == 4,
              probe.standardInputPolicy
                == verifier.standardInputPolicy,
              probe.standardInputPolicy == "eof_v1",
              probe.maximumWallSeconds
                == verifier.maximumWallSeconds,
              probe.maximumStandardOutputBytes
                == verifier
                .maximumStandardOutputBytes,
              probe.maximumStandardErrorBytes
                == verifier
                .maximumStandardErrorBytes,
              !probe.standardOutputOverflowed,
              !verifier.standardOutputOverflowed,
              probe.standardOutputDrainCompleted,
              verifier.standardOutputDrainCompleted,
              !probe.standardErrorOverflowed,
              !verifier.standardErrorOverflowed,
              probe.standardErrorDrainCompleted,
              verifier.standardErrorDrainCompleted,
              probe.termination
                == verifier.termination,
              probe.termination
                == .cleanExitZero,
              probe.terminationControlPolicy
                == verifier
                .terminationControlPolicy,
              probe.childTerminationObserved,
              verifier.childTerminationObserved,
              probe.childReaped,
              verifier.childReaped,
              probe.standardOutput
                == verifier.standardOutput,
              probe.prePrimeSourceState
                == verifier.prePrimeSourceState,
              probe.postPrimeSourceState
                == verifier.postPrimeSourceState,
              probe.primeSourceSnapshot
                == verifier.primeSourceSnapshot,
              probe.packageManifest
                == verifier.packageManifest
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "swift_package_describe_capture_pair"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case role
        case recordRelativePath =
            "record_relative_path"
        case planSHA256 = "plan_sha256"
        case supervisorProcessIdentifier =
            "supervisor_process_identifier"
        case childProcessIdentifier =
            "child_process_identifier"
        case swiftPackageExecutableAbsolutePath =
            "swift_package_executable_absolute_path"
        case swiftPackageExecutableSHA256 =
            "swift_package_executable_sha256"
        case swiftPackageExecutableByteCount =
            "swift_package_executable_byte_count"
        case mappedChildMainImageAbsolutePath =
            "mapped_child_main_image_absolute_path"
        case mappedChildMainImageSHA256 =
            "mapped_child_main_image_sha256"
        case mappedChildMainImageByteCount =
            "mapped_child_main_image_byte_count"
        case mappedChildMainImageObservedDeviceID =
            "mapped_child_main_image_observed_device_id"
        case mappedChildMainImageObservedInode =
            "mapped_child_main_image_observed_inode"
        case mappedChildMainImageDescriptorDeviceID =
            "mapped_child_main_image_descriptor_device_id"
        case mappedChildMainImageDescriptorInode =
            "mapped_child_main_image_descriptor_inode"
        case mappedChildMainImageVnodeIdentityJoined =
            "mapped_child_main_image_vnode_identity_joined"
        case mappedChildMainImageDescriptorOpenedWithNoSymbolicLinksInPath =
            "mapped_child_main_image_descriptor_opened_with_no_symbolic_links_in_path"
        case mappedChildMainImageCaptureAuthority =
            "mapped_child_main_image_capture_authority"
        case mappedRegionEnumerationPolicy =
            "mapped_region_enumeration_policy"
        case captureCapabilityCalibrationPassed =
            "capture_capability_calibration_passed"
        case procPIDPathUsedOnlyAsTelemetry =
            "proc_pidpath_used_only_as_telemetry"
        case mappedChildMainImageCapturedWhileSuspendedBeforeResume =
            "mapped_child_main_image_captured_while_suspended_before_resume"
        case externalChildCaptureEvidence =
            "external_child_capture_evidence"
        case scratchNamespace =
            "scratch_namespace"
        case exactArguments = "exact_arguments"
        case exactEnvironmentKeys =
            "exact_environment_keys"
        case exactEnvironment =
            "exact_environment"
        case environmentPolicy =
            "environment_policy"
        case directProcessWithoutShell =
            "direct_process_without_shell"
        case workingDirectoryAbsolutePath =
            "working_directory_absolute_path"
        case workingDirectoryIsValidatedPrimeRoot =
            "working_directory_is_validated_prime_root"
        case environmentKeyCount =
            "environment_key_count"
        case standardInputPolicy =
            "standard_input_policy"
        case maximumWallSeconds =
            "maximum_wall_seconds"
        case observedMonotonicWallNanoseconds =
            "observed_monotonic_wall_nanoseconds"
        case maximumStandardOutputBytes =
            "maximum_standard_output_bytes"
        case maximumStandardErrorBytes =
            "maximum_standard_error_bytes"
        case standardOutput = "standard_output"
        case standardOutputOverflowed =
            "standard_output_overflowed"
        case standardOutputDrainCompleted =
            "standard_output_drain_completed"
        case standardErrorByteCount =
            "standard_error_byte_count"
        case standardErrorSHA256 =
            "standard_error_sha256"
        case standardErrorOverflowed =
            "standard_error_overflowed"
        case standardErrorDrainCompleted =
            "standard_error_drain_completed"
        case exitStatus = "exit_status"
        case termination
        case terminationControlPolicy =
            "termination_control_policy"
        case childTerminationObserved =
            "child_termination_observed"
        case childReaped = "child_reaped"
        case prePrimeSourceState =
            "pre_prime_source_state"
        case postPrimeSourceState =
            "post_prime_source_state"
        case preSourceSnapshotSHA256 =
            "pre_source_snapshot_sha256"
        case postSourceSnapshotSHA256 =
            "post_source_snapshot_sha256"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case packageManifest =
            "package_manifest"
    }
}

public struct PrimeNativeNeuralGateReleaseProcessBindingRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let recordRelativePath: String
    public let planSHA256: String
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let processIdentifier: Int32
    public let executableTargetName: String
    public let exactTransitiveLocalTargetNames:
        [String]
    public let prePrimeSourceState:
        PrimeNativeNeuralGatePrimeGitStateRecord
    public let postPrimeSourceState:
        PrimeNativeNeuralGatePrimeGitStateRecord
    public let preSourceSnapshotSHA256:
        String
    public let postSourceSnapshotSHA256:
        String
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let compiledSourceClosure:
        PrimeArtifactBinding
    public let swiftPackageDescribeCapture:
        PrimeArtifactBinding
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256:
        String
    public let buildConfiguration: String
    public let runningExecutable:
        PrimeArtifactBinding
    public let runningExecutableCaptureAuthority:
        String
    public let capturedBySameProcess: Bool
    public let reproducibleBuildProvenanceClaimed:
        Bool

    init(
        recordRelativePath: String,
        planSHA256: String,
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        processIdentifier: Int32,
        executableTargetName: String,
        exactTransitiveLocalTargetNames:
            [String],
        prePrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        postPrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        preSourceSnapshotSHA256: String,
        postSourceSnapshotSHA256: String,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        swiftPackageDescribeCapture:
            PrimeArtifactBinding,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256:
            String,
        buildConfiguration: String,
        runningExecutable:
            PrimeArtifactBinding,
        runningExecutableCaptureAuthority:
            String =
                "PrimeSecureRunningExecutableCapture.data",
        capturedBySameProcess: Bool = true,
        reproducibleBuildProvenanceClaimed:
            Bool = false
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_release_process_binding"
        self.recordRelativePath =
            recordRelativePath
        self.planSHA256 = planSHA256
        self.role = role
        self.processIdentifier =
            processIdentifier
        self.executableTargetName =
            executableTargetName
        self.exactTransitiveLocalTargetNames =
            exactTransitiveLocalTargetNames
        self.prePrimeSourceState =
            prePrimeSourceState
        self.postPrimeSourceState =
            postPrimeSourceState
        self.preSourceSnapshotSHA256 =
            preSourceSnapshotSHA256
        self.postSourceSnapshotSHA256 =
            postSourceSnapshotSHA256
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.compiledSourceClosure =
            compiledSourceClosure
        self.swiftPackageDescribeCapture =
            swiftPackageDescribeCapture
        self.sourceIdentitySHA256 =
            sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.buildConfiguration =
            buildConfiguration
        self.runningExecutable =
            runningExecutable
        self.runningExecutableCaptureAuthority =
            runningExecutableCaptureAuthority
        self.capturedBySameProcess =
            capturedBySameProcess
        self.reproducibleBuildProvenanceClaimed =
            reproducibleBuildProvenanceClaimed
    }

    public static func captureCurrentProcess(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        planSHA256: String,
        prePrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        postPrimeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        describeCapture:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        trustedExternalChildCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        describeCaptureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws -> Self {
        guard let rule =
                contract.processBindingRules.first(
                    where: {
                        $0.role == role
                    }
                )
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "release_process_capture_role"
                )
        }
        let runningData =
            try PrimeSecureRunningExecutableCapture
            .data()
        let runningBinding =
            PrimeArtifactBinding(
                relativePath:
                    rule
                    .runningExecutableRelativePath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of: runningData
                    ),
                byteCount:
                    UInt64(runningData.count),
                purpose: .executable
            )
        let transitive =
            try closure.transitiveTargetNames(
                for:
                    rule.executableTargetName,
                against: contract
            )
        let record = Self(
            recordRelativePath:
                rule
                .executableBindingRelativePath,
            planSHA256: planSHA256,
            role: role,
            processIdentifier:
                ProcessInfo.processInfo
                .processIdentifier,
            executableTargetName:
                rule.executableTargetName,
            exactTransitiveLocalTargetNames:
                transitive,
            prePrimeSourceState:
                prePrimeSourceState,
            postPrimeSourceState:
                postPrimeSourceState,
            preSourceSnapshotSHA256:
                primeSourceSnapshot.sha256,
            postSourceSnapshotSHA256:
                primeSourceSnapshot.sha256,
            primeSourceSnapshot:
                primeSourceSnapshot,
            compiledSourceClosure:
                compiledSourceClosure,
            swiftPackageDescribeCapture:
                describeCaptureBinding,
            sourceIdentitySHA256:
                closure.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            buildConfiguration:
                PrimeEmbeddedBuildProvenance
                .buildConfiguration,
            runningExecutable:
                runningBinding
        )
        try record.validateForRunningRelease(
            against: contract,
            trustedExternalChildCapture:
                trustedExternalChildCapture,
            expectedPlanSHA256:
                planSHA256,
            closure: closure,
            closureBinding:
                compiledSourceClosure,
            describeCapture:
                describeCapture,
            describeCaptureBinding:
                describeCaptureBinding,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            capturedRunningExecutableData:
                runningData
        )
        return record
    }

    public func validateForRunningRelease(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        trustedExternalChildCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        expectedPlanSHA256: String,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        closureBinding:
            PrimeArtifactBinding,
        describeCapture:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        describeCaptureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        capturedRunningExecutableData: Data
    ) throws {
        try validate(
            against: contract,
            trustedExternalChildCapture:
                trustedExternalChildCapture,
            expectedPlanSHA256:
                expectedPlanSHA256,
            closure: closure,
            closureBinding: closureBinding,
            describeCapture:
                describeCapture,
            describeCaptureBinding:
                describeCaptureBinding,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            capturedRunningExecutableData:
                capturedRunningExecutableData,
            expectedEmbeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            expectedBuildConfiguration:
                PrimeEmbeddedBuildProvenance
                .buildConfiguration
        )
    }

    func validate(
        against contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        trustedExternalChildCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        expectedPlanSHA256: String,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        closureBinding:
            PrimeArtifactBinding,
        describeCapture:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        describeCaptureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        capturedRunningExecutableData: Data,
        expectedEmbeddedSourceIdentitySHA256:
            String,
        expectedBuildConfiguration: String
    ) throws {
        guard let rule = contract
            .processBindingRules.first(
                where: {
                    $0.role == role
                }
            ),
              contract.processBindingRules.filter({
                  $0.role == role
              }).count == 1,
              describeCapture.role == role
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "release_process_binding_role"
                )
        }
        try prePrimeSourceState.validate()
        try postPrimeSourceState.validate()
        try primeSourceSnapshot
            .validateDeclaration()
        try compiledSourceClosure
            .validateDeclaration()
        try swiftPackageDescribeCapture
            .validateDeclaration()
        try runningExecutable
            .validateDeclaration()
        try closure.validate(
            against: contract,
            expectedPlanSHA256:
                expectedPlanSHA256,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            expectedEmbeddedSourceIdentitySHA256:
                expectedEmbeddedSourceIdentitySHA256
        )
        let expectedClosureBinding =
            try closure.artifactBinding(
                relativePath:
                    contract
                    .compiledSourceClosureRelativePath
            )
        let expectedDescribeCaptureBinding =
            try describeCapture
            .artifactBinding()
        try describeCapture
            .validateForRunningRelease(
            against: contract,
            trustedExternalChildCapture:
                trustedExternalChildCapture,
            expectedPlanSHA256:
                expectedPlanSHA256,
            expectedSupervisorProcessIdentifier:
                processIdentifier,
            expectedPrimeSourceState:
                prePrimeSourceState,
            expectedPrimeSourceSnapshot:
                primeSourceSnapshot,
            expectedPackageManifest:
                closure.packageManifest,
            expectedStandardOutput:
                closure.swiftPackageDescribe,
            standardOutputData:
                swiftPackageDescribeData
        )
        let transitive =
            try closure.transitiveTargetNames(
                for: executableTargetName,
                against: contract
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_release_process_binding",
              recordRelativePath
                == rule
                .executableBindingRelativePath,
              planSHA256
                == expectedPlanSHA256,
              processIdentifier > 0,
              executableTargetName
                == rule.executableTargetName,
              exactTransitiveLocalTargetNames
                == rule
                .exactTransitiveLocalTargetNames,
              exactTransitiveLocalTargetNames
                == transitive,
              prePrimeSourceState
                == postPrimeSourceState,
              preSourceSnapshotSHA256
                == primeSourceSnapshot.sha256,
              postSourceSnapshotSHA256
                == primeSourceSnapshot.sha256,
              primeSourceSnapshot
                == closure.primeSourceSnapshot,
              compiledSourceClosure
                == closureBinding,
              closureBinding
                == expectedClosureBinding,
              swiftPackageDescribeCapture
                == describeCaptureBinding,
              describeCaptureBinding
                == expectedDescribeCaptureBinding,
              sourceIdentitySHA256
                == closure.sourceIdentitySHA256,
              embeddedSourceIdentitySHA256
                == closure
                .embeddedSourceIdentitySHA256,
              buildConfiguration
                == closure.buildConfiguration,
              sourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              embeddedSourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              buildConfiguration
                == expectedBuildConfiguration,
              buildConfiguration == "release",
              runningExecutable.relativePath
                == rule
                .runningExecutableRelativePath,
              runningExecutable.purpose
                == .executable,
              runningExecutable.byteCount
                == UInt64(
                    capturedRunningExecutableData.count
                ),
              runningExecutable.sha256
                == PrimeSHA256.hexDigest(
                    of:
                        capturedRunningExecutableData
                ),
              runningExecutableCaptureAuthority
                == contract
                .runningExecutableCaptureAuthority,
              capturedBySameProcess,
              !reproducibleBuildProvenanceClaimed
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "release_process_binding"
                )
        }
    }

    public static func validateProbeVerifierPairOfPrevalidatedRecords(
        probe:
            PrimeNativeNeuralGateReleaseProcessBindingRecord,
        verifier:
            PrimeNativeNeuralGateReleaseProcessBindingRecord
    ) throws {
        guard probe.role == .probe,
              verifier.role == .verifier,
              probe.processIdentifier
                != verifier.processIdentifier,
              probe.executableTargetName
                != verifier.executableTargetName,
              probe.runningExecutable.relativePath
                != verifier
                .runningExecutable.relativePath,
              probe.runningExecutable.sha256
                != verifier.runningExecutable.sha256,
              probe.planSHA256
                == verifier.planSHA256,
              probe.prePrimeSourceState
                == verifier.prePrimeSourceState,
              probe.postPrimeSourceState
                == verifier.postPrimeSourceState,
              probe.primeSourceSnapshot
                == verifier.primeSourceSnapshot,
              probe.compiledSourceClosure
                == verifier.compiledSourceClosure,
              probe.swiftPackageDescribeCapture
                != verifier
                .swiftPackageDescribeCapture,
              probe.sourceIdentitySHA256
                == verifier.sourceIdentitySHA256,
              probe.embeddedSourceIdentitySHA256
                == verifier
                .embeddedSourceIdentitySHA256,
              probe.buildConfiguration
                == verifier.buildConfiguration
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "probe_verifier_process_pair"
                )
        }
    }

    public func artifactBinding()
        throws -> PrimeArtifactBinding
    {
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath: recordRelativePath,
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case recordRelativePath =
            "record_relative_path"
        case planSHA256 = "plan_sha256"
        case role
        case processIdentifier =
            "process_identifier"
        case executableTargetName =
            "executable_target_name"
        case exactTransitiveLocalTargetNames =
            "exact_transitive_local_target_names"
        case prePrimeSourceState =
            "pre_prime_source_state"
        case postPrimeSourceState =
            "post_prime_source_state"
        case preSourceSnapshotSHA256 =
            "pre_source_snapshot_sha256"
        case postSourceSnapshotSHA256 =
            "post_source_snapshot_sha256"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case compiledSourceClosure =
            "compiled_source_closure"
        case swiftPackageDescribeCapture =
            "swift_package_describe_capture"
        case sourceIdentitySHA256 =
            "source_identity_sha256"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case buildConfiguration =
            "build_configuration"
        case runningExecutable =
            "running_executable"
        case runningExecutableCaptureAuthority =
            "running_executable_capture_authority"
        case capturedBySameProcess =
            "captured_by_same_process"
        case reproducibleBuildProvenanceClaimed =
            "reproducible_build_provenance_claimed"
    }
}

public enum PrimeNativeNeuralGateHistoricalWorkerInvocationRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case probe
    case verifier
}

public struct PrimeNativeNeuralGateHistoricalWorkerContract:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let executableTargetName: String
    public let executableRelativePath: String
    public let executableBindingRelativePath:
        String
    public let exactCLIArgumentNames: [String]
    public let allowedInvocationRoles:
        [PrimeNativeNeuralGateHistoricalWorkerInvocationRole]
    public let probeOutputPrefixRelativePath:
        String
    public let verifierOutputPrefixRelativePath:
        String
    public let supervisorOwnedFixedOutputLeafPaths:
        [String]
    public let workerOwnedFixedOutputLeafPaths:
        [String]
    public let dynamicChunkLeafPathPattern:
        String
    public let requestLeafPath: String
    public let resultLeafPath: String
    public let executionLeafPath: String
    public let maximumWallSeconds: UInt64
    public let maximumStandardOutputBytes:
        UInt64
    public let maximumStandardErrorBytes:
        UInt64
    public let maximumResultBytes: UInt64
    public let environmentPolicy: String
    public let standardInputPolicy: String
    public let successfulStandardOutputPolicy:
        String
    public let successfulStandardErrorPolicy:
        String
    public let trapBearingFixtureRemainsInWorker:
        Bool
    public let workerOwnsCompleteHistoricalArm:
        Bool
    public let fixtureCodableTransportPermitted:
        Bool
    public let stdoutEvidenceTransportPermitted:
        Bool
    public let resultPublishedLast: Bool
    public let workerResultCanEstablishMechanicsPass:
        Bool
    public let terminalVerifierMustDecodeAndRecomputeEveryWorkerArtifact:
        Bool
    public let poisonedRootRetryPermitted:
        Bool
    public let terminationEscalationPolicy:
        String
    public let directPIDAuthorityBeforeSessionJoinRequired:
        Bool
    public let processGroupAuthorityRequiresExactSessionJoin:
        Bool
    public let boundedNonblockingExactPIDWaitFallbackRequired:
        Bool
    public let exactOnceReapAndNoPostReapSignalRequired:
        Bool
    public let uncontainedChildOrDrainFailStopPolicy:
        String
    public let workerDeathObservedBeforeContinuationRequired:
        Bool
    public let workerReapBeforeContinuationRequired:
        Bool
    public let preLaunchAndPostExitDescriptorEnumerationRequired:
        Bool
    public let exactRolePrefixInventoryDifferenceRequired:
        Bool
    public let abnormalTerminationInternalDisposition:
        PrimeNativeNeuralGateScopedOutcome
    public let abnormalTerminationAbstainRequiresProvenContainmentAndReap:
        Bool
    public let abnormalTerminationPublicationPolicy:
        String

    public static let frozenV2 = Self(
        contractID:
            "prime_stage_b_historical_fixture_worker_v2",
        executableTargetName:
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        executableRelativePath:
            "neural-gate-replay/bin/historical-fixture-worker",
        executableBindingRelativePath:
            "neural-gate-replay/bin/historical-fixture-worker-binding.v1.json",
        exactCLIArgumentNames: [
            "--artifact-root",
            "--invocation-role",
            "--request-sha256",
        ],
        allowedInvocationRoles:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
            .allCases,
        probeOutputPrefixRelativePath:
            "neural-gate-replay/historical/probe",
        verifierOutputPrefixRelativePath:
            "neural-gate-replay/historical/verifier",
        supervisorOwnedFixedOutputLeafPaths: [
            "worker-request.v1.json",
            "worker-execution.v1.json",
        ],
        workerOwnedFixedOutputLeafPaths: [
            "worker-process-binding.v1.json",
            "material-identity-manifest.v1.json",
            "gate-observation.v1.json",
            "invariant-records-manifest.v1.json",
            "invariant-records.v1.bin",
            "fingerprint-observation.v1.json",
            "mutation-observations.v1.json",
            "statistics-verdict-observation.v1.json",
            "worker-result.v1.json",
        ],
        dynamicChunkLeafPathPattern:
            "invariant-chunks/{ordinal_8digit}.v1.bin",
        requestLeafPath:
            "worker-request.v1.json",
        resultLeafPath:
            "worker-result.v1.json",
        executionLeafPath:
            "worker-execution.v1.json",
        maximumWallSeconds: 600,
        maximumStandardOutputBytes:
            1_048_576,
        maximumStandardErrorBytes:
            1_048_576,
        maximumResultBytes: 1_048_576,
        environmentPolicy:
            "empty_environment_v1",
        standardInputPolicy: "eof_v1",
        successfulStandardOutputPolicy:
            "exactly_empty_v1",
        successfulStandardErrorPolicy:
            "exactly_empty_v1",
        trapBearingFixtureRemainsInWorker:
            true,
        workerOwnsCompleteHistoricalArm:
            true,
        fixtureCodableTransportPermitted:
            false,
        stdoutEvidenceTransportPermitted:
            false,
        resultPublishedLast: true,
        workerResultCanEstablishMechanicsPass:
            false,
        terminalVerifierMustDecodeAndRecomputeEveryWorkerArtifact:
            true,
        poisonedRootRetryPermitted: false,
        terminationEscalationPolicy:
            "direct_pid_before_sid_pgid_join_then_dedicated_group_deadline_sigterm_wait_2s_sigkill_once_observed_death_or_bounded_exact_pid_wnohang_exact_once_reap_no_post_reap_signal_v2",
        directPIDAuthorityBeforeSessionJoinRequired:
            true,
        processGroupAuthorityRequiresExactSessionJoin:
            true,
        boundedNonblockingExactPIDWaitFallbackRequired:
            true,
        exactOnceReapAndNoPostReapSignalRequired:
            true,
        uncontainedChildOrDrainFailStopPolicy:
            "uncontained_child_or_drain_is_supervisor_fail_stop_and_cannot_return_as_abstain_v1",
        workerDeathObservedBeforeContinuationRequired:
            true,
        workerReapBeforeContinuationRequired:
            true,
        preLaunchAndPostExitDescriptorEnumerationRequired:
            true,
        exactRolePrefixInventoryDifferenceRequired:
            true,
        abnormalTerminationInternalDisposition:
            .abstain,
        abnormalTerminationAbstainRequiresProvenContainmentAndReap:
            true,
        abnormalTerminationPublicationPolicy:
            "poison_root_accept_no_worker_result_as_evidence_publish_no_successful_execution_record_publish_no_terminal_receipt_no_retry_v1"
    )

    fileprivate func validateFrozenIdentity()
        throws
    {
        guard self == .frozenV2 else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_contract_identity"
                )
        }
    }

    public func outputPrefix(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> String {
        switch role {
        case .probe:
            probeOutputPrefixRelativePath
        case .verifier:
            verifierOutputPrefixRelativePath
        }
    }

    public func requestRelativePath(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> String {
        outputPrefix(for: role)
            + "/"
            + requestLeafPath
    }

    public func resultRelativePath(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> String {
        outputPrefix(for: role)
            + "/"
            + resultLeafPath
    }

    public func executionRelativePath(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> String {
        outputPrefix(for: role)
            + "/"
            + executionLeafPath
    }

    public func fixedOutputRelativePaths(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> [String] {
        (
            supervisorOwnedFixedOutputLeafPaths
                + workerOwnedFixedOutputLeafPaths
        ).map {
            outputPrefix(for: role)
                + "/"
                + $0
        }
    }

    public func supervisorOwnedFixedOutputRelativePaths(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> [String] {
        supervisorOwnedFixedOutputLeafPaths.map {
            outputPrefix(for: role)
                + "/"
                + $0
        }
    }

    public func workerOwnedFixedOutputRelativePaths(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> [String] {
        workerOwnedFixedOutputLeafPaths.map {
            outputPrefix(for: role)
                + "/"
                + $0
        }
    }

    public func chunkRelativePathPattern(
        for role:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    ) -> String {
        outputPrefix(for: role)
            + "/"
            + dynamicChunkLeafPathPattern
    }

    public func validate(
        adaptationProof:
            PrimeNativeNeuralGateAdaptationProofContract,
        sourceExecutionBinding:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws {
        try validateFrozenIdentity()
        guard Set(exactCLIArgumentNames).count
                == exactCLIArgumentNames.count,
              allowedInvocationRoles
                == PrimeNativeNeuralGateHistoricalWorkerInvocationRole
                .allCases,
              Set(
                  supervisorOwnedFixedOutputLeafPaths
              )
                .count
                == supervisorOwnedFixedOutputLeafPaths
                .count,
              Set(workerOwnedFixedOutputLeafPaths)
                .count
                == workerOwnedFixedOutputLeafPaths
                .count,
              Set(
                  supervisorOwnedFixedOutputLeafPaths
              ).isDisjoint(
                  with: Set(
                      workerOwnedFixedOutputLeafPaths
                  )
              ),
              supervisorOwnedFixedOutputLeafPaths
                .contains(requestLeafPath),
              workerOwnedFixedOutputLeafPaths
                .contains(resultLeafPath),
              supervisorOwnedFixedOutputLeafPaths
                .contains(executionLeafPath),
              sourceExecutionBinding
                .targetClosureRules
                .contains(where: {
                    $0.targetName
                            == executableTargetName
                        && $0
                        .directLocalDependencyNames
                            == [
                                "PrimeCore",
                                "ErgenticsPrimeRuntime",
                                "PrimeNativeNeuralGateReplayMechanics",
                                "PrimeNativeNeuralGateReplay",
                            ]
                }),
              maximumWallSeconds
                == adaptationProof
                .historicalFixtureMaximumWallSeconds,
              maximumStandardOutputBytes
                == adaptationProof
                .historicalFixtureMaximumStandardOutputBytes,
              maximumStandardErrorBytes
                == adaptationProof
                .historicalFixtureMaximumStandardErrorBytes,
              environmentPolicy
                == adaptationProof
                .historicalFixtureChildEnvironmentPolicy,
              standardInputPolicy
                == adaptationProof
                .historicalFixtureChildStandardInputPolicy,
              maximumResultBytes == 1_048_576,
              trapBearingFixtureRemainsInWorker,
              workerOwnsCompleteHistoricalArm,
              !fixtureCodableTransportPermitted,
              !stdoutEvidenceTransportPermitted,
              resultPublishedLast,
              !workerResultCanEstablishMechanicsPass,
              terminalVerifierMustDecodeAndRecomputeEveryWorkerArtifact,
              !poisonedRootRetryPermitted,
              terminationEscalationPolicy
                == "direct_pid_before_sid_pgid_join_then_dedicated_group_deadline_sigterm_wait_2s_sigkill_once_observed_death_or_bounded_exact_pid_wnohang_exact_once_reap_no_post_reap_signal_v2",
              directPIDAuthorityBeforeSessionJoinRequired,
              processGroupAuthorityRequiresExactSessionJoin,
              boundedNonblockingExactPIDWaitFallbackRequired,
              exactOnceReapAndNoPostReapSignalRequired,
              uncontainedChildOrDrainFailStopPolicy
                == "uncontained_child_or_drain_is_supervisor_fail_stop_and_cannot_return_as_abstain_v1",
              workerDeathObservedBeforeContinuationRequired,
              workerReapBeforeContinuationRequired,
              preLaunchAndPostExitDescriptorEnumerationRequired,
              exactRolePrefixInventoryDifferenceRequired,
              abnormalTerminationInternalDisposition
                == .abstain,
              abnormalTerminationAbstainRequiresProvenContainmentAndReap,
              abnormalTerminationPublicationPolicy
                == "poison_root_accept_no_worker_result_as_evidence_publish_no_successful_execution_record_publish_no_terminal_receipt_no_retry_v1"
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_contract"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case executableTargetName =
            "executable_target_name"
        case executableRelativePath =
            "executable_relative_path"
        case executableBindingRelativePath =
            "executable_binding_relative_path"
        case exactCLIArgumentNames =
            "exact_cli_argument_names"
        case allowedInvocationRoles =
            "allowed_invocation_roles"
        case probeOutputPrefixRelativePath =
            "probe_output_prefix_relative_path"
        case verifierOutputPrefixRelativePath =
            "verifier_output_prefix_relative_path"
        case supervisorOwnedFixedOutputLeafPaths =
            "supervisor_owned_fixed_output_leaf_paths"
        case workerOwnedFixedOutputLeafPaths =
            "worker_owned_fixed_output_leaf_paths"
        case dynamicChunkLeafPathPattern =
            "dynamic_chunk_leaf_path_pattern"
        case requestLeafPath =
            "request_leaf_path"
        case resultLeafPath =
            "result_leaf_path"
        case executionLeafPath =
            "execution_leaf_path"
        case maximumWallSeconds =
            "maximum_wall_seconds"
        case maximumStandardOutputBytes =
            "maximum_standard_output_bytes"
        case maximumStandardErrorBytes =
            "maximum_standard_error_bytes"
        case maximumResultBytes =
            "maximum_result_bytes"
        case environmentPolicy =
            "environment_policy"
        case standardInputPolicy =
            "standard_input_policy"
        case successfulStandardOutputPolicy =
            "successful_standard_output_policy"
        case successfulStandardErrorPolicy =
            "successful_standard_error_policy"
        case trapBearingFixtureRemainsInWorker =
            "trap_bearing_fixture_remains_in_worker"
        case workerOwnsCompleteHistoricalArm =
            "worker_owns_complete_historical_arm"
        case fixtureCodableTransportPermitted =
            "fixture_codable_transport_permitted"
        case stdoutEvidenceTransportPermitted =
            "stdout_evidence_transport_permitted"
        case resultPublishedLast =
            "result_published_last"
        case workerResultCanEstablishMechanicsPass =
            "worker_result_can_establish_mechanics_pass"
        case terminalVerifierMustDecodeAndRecomputeEveryWorkerArtifact =
            "terminal_verifier_must_decode_and_recompute_every_worker_artifact"
        case poisonedRootRetryPermitted =
            "poisoned_root_retry_permitted"
        case terminationEscalationPolicy =
            "termination_escalation_policy"
        case directPIDAuthorityBeforeSessionJoinRequired =
            "direct_pid_authority_before_session_join_required"
        case processGroupAuthorityRequiresExactSessionJoin =
            "process_group_authority_requires_exact_session_join"
        case boundedNonblockingExactPIDWaitFallbackRequired =
            "bounded_nonblocking_exact_pid_wait_fallback_required"
        case exactOnceReapAndNoPostReapSignalRequired =
            "exact_once_reap_and_no_post_reap_signal_required"
        case uncontainedChildOrDrainFailStopPolicy =
            "uncontained_child_or_drain_fail_stop_policy"
        case workerDeathObservedBeforeContinuationRequired =
            "worker_death_observed_before_continuation_required"
        case workerReapBeforeContinuationRequired =
            "worker_reap_before_continuation_required"
        case preLaunchAndPostExitDescriptorEnumerationRequired =
            "pre_launch_and_post_exit_descriptor_enumeration_required"
        case exactRolePrefixInventoryDifferenceRequired =
            "exact_role_prefix_inventory_difference_required"
        case abnormalTerminationInternalDisposition =
            "abnormal_termination_internal_disposition"
        case abnormalTerminationAbstainRequiresProvenContainmentAndReap =
            "abnormal_termination_abstain_requires_proven_containment_and_reap"
        case abnormalTerminationPublicationPolicy =
            "abnormal_termination_publication_policy"
    }
}

public struct PrimeNativeNeuralGateHistoricalWorkerStreamObservation:
    Codable,
    Equatable,
    Sendable
{
    public let byteCount: UInt64
    public let sha256: String
    public let overflowed: Bool
    public let drainCompleted: Bool

    public init(
        byteCount: UInt64,
        sha256: String,
        overflowed: Bool,
        drainCompleted: Bool
    ) {
        self.byteCount = byteCount
        self.sha256 = sha256
        self.overflowed = overflowed
        self.drainCompleted = drainCompleted
    }

    public static let emptyDrained = Self(
        byteCount: 0,
        sha256:
            PrimeSHA256.hexDigest(of: Data()),
        overflowed: false,
        drainCompleted: true
    )

    public var isSuccessfulEmptyDrain: Bool {
        self == .emptyDrained
    }

    private enum CodingKeys: String, CodingKey {
        case byteCount = "byte_count"
        case sha256
        case overflowed
        case drainCompleted =
            "drain_completed"
    }
}

public enum PrimeNativeNeuralGateHistoricalWorkerTerminationDisposition:
    Codable,
    Equatable,
    Sendable
{
    case cleanExitZero
    case nonzeroExit(status: Int32)
    case signal(number: Int32)
    case timedOutAfterEscalation
    case launchFailure(reasonSHA256: String)
    case outputDrainFailure
    case outputOverflow

    public var isCleanExitZero: Bool {
        self == .cleanExitZero
    }
}

public struct PrimeNativeNeuralGateHistoricalWorkerRequest:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    public let planSHA256: String
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let compiledSourceClosure:
        PrimeArtifactBinding
    public let embeddedSourceIdentitySHA256:
        String
    public let copiedPackageLock:
        PrimeArtifactBinding
    public let sealedWorkerExecutable:
        PrimeArtifactBinding
    public let outputPrefixRelativePath:
        String
    public let requiredWorkerOwnedOutputRelativePaths:
        [String]
    public let supervisorReservedOutputRelativePaths:
        [String]
    public let dynamicChunkRelativePathPattern:
        String
    public let candidateValuesPermitted: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
        planSHA256: String,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        embeddedSourceIdentitySHA256:
            String,
        copiedPackageLock:
            PrimeArtifactBinding,
        sealedWorkerExecutable:
            PrimeArtifactBinding,
        workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_historical_worker_request"
        self.invocationRole =
            invocationRole
        self.planSHA256 = planSHA256
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.compiledSourceClosure =
            compiledSourceClosure
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.copiedPackageLock =
            copiedPackageLock
        self.sealedWorkerExecutable =
            sealedWorkerExecutable
        outputPrefixRelativePath =
            workerContract.outputPrefix(
                for: invocationRole
            )
        requiredWorkerOwnedOutputRelativePaths =
            workerContract
            .workerOwnedFixedOutputRelativePaths(
                for: invocationRole
            )
        supervisorReservedOutputRelativePaths =
            workerContract
            .supervisorOwnedFixedOutputRelativePaths(
                for: invocationRole
            )
        dynamicChunkRelativePathPattern =
            workerContract
            .chunkRelativePathPattern(
                for: invocationRole
            )
        candidateValuesPermitted = false
    }

    public func validate(
        against contract:
            PrimeNativeNeuralGateHistoricalWorkerContract,
        expectedPlanSHA256: String,
        expectedSourceSnapshot:
            PrimeArtifactBinding,
        expectedCompiledSourceClosure:
            PrimeArtifactBinding,
        expectedEmbeddedSourceIdentitySHA256:
            String,
        expectedCopiedPackageLock:
            PrimeArtifactBinding,
        expectedWorkerExecutable:
            PrimeArtifactBinding
    ) throws {
        try contract.validateFrozenIdentity()
        try [
            primeSourceSnapshot,
            compiledSourceClosure,
            copiedPackageLock,
            sealedWorkerExecutable,
        ].forEach {
            try $0.validateDeclaration()
        }
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_historical_worker_request",
              PrimeNativeNeuralGateSourceFileIdentity
                .isLowercaseSHA256(planSHA256),
              planSHA256
                == expectedPlanSHA256,
              primeSourceSnapshot
                == expectedSourceSnapshot,
              compiledSourceClosure
                == expectedCompiledSourceClosure,
              embeddedSourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              copiedPackageLock
                == expectedCopiedPackageLock,
              copiedPackageLock.purpose
                == .immutableData,
              sealedWorkerExecutable
                == expectedWorkerExecutable,
              sealedWorkerExecutable.relativePath
                == contract
                .executableRelativePath,
              sealedWorkerExecutable.purpose
                == .executable,
              outputPrefixRelativePath
                == contract.outputPrefix(
                    for: invocationRole
                ),
              requiredWorkerOwnedOutputRelativePaths
                == contract
                .workerOwnedFixedOutputRelativePaths(
                    for: invocationRole
                ),
              supervisorReservedOutputRelativePaths
                == contract
                .supervisorOwnedFixedOutputRelativePaths(
                    for: invocationRole
                ),
              Set(
                  requiredWorkerOwnedOutputRelativePaths
              ).isDisjoint(
                  with: Set(
                      supervisorReservedOutputRelativePaths
                  )
              ),
              dynamicChunkRelativePathPattern
                == contract
                .chunkRelativePathPattern(
                    for: invocationRole
                ),
              !candidateValuesPermitted
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_request"
                )
        }
    }

    public func artifactBinding(
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws -> PrimeArtifactBinding {
        try contract.validateFrozenIdentity()
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath:
                contract.requestRelativePath(
                    for: invocationRole
                ),
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case invocationRole =
            "invocation_role"
        case planSHA256 = "plan_sha256"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case compiledSourceClosure =
            "compiled_source_closure"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case copiedPackageLock =
            "copied_package_lock"
        case sealedWorkerExecutable =
            "sealed_worker_executable"
        case outputPrefixRelativePath =
            "output_prefix_relative_path"
        case requiredWorkerOwnedOutputRelativePaths =
            "required_worker_owned_output_relative_paths"
        case supervisorReservedOutputRelativePaths =
            "supervisor_reserved_output_relative_paths"
        case dynamicChunkRelativePathPattern =
            "dynamic_chunk_relative_path_pattern"
        case candidateValuesPermitted =
            "candidate_values_permitted"
    }
}

public struct PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    public let recordRelativePath: String
    public let planSHA256: String
    public let processIdentifier: Int32
    public let executableTargetName: String
    public let exactTransitiveLocalTargetNames:
        [String]
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let compiledSourceClosure:
        PrimeArtifactBinding
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256:
        String
    public let buildConfiguration: String
    public let sealedWorkerExecutable:
        PrimeArtifactBinding
    public let runningWorkerExecutable:
        PrimeArtifactBinding
    public let runningExecutableCaptureAuthority:
        String
    public let capturedBySameProcess: Bool
    public let reproducibleBuildProvenanceClaimed:
        Bool

    init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
        planSHA256: String,
        processIdentifier: Int32,
        exactTransitiveLocalTargetNames:
            [String],
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256:
            String,
        buildConfiguration: String,
        sealedWorkerExecutable:
            PrimeArtifactBinding,
        runningWorkerExecutable:
            PrimeArtifactBinding,
        workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_historical_worker_process_binding"
        self.invocationRole =
            invocationRole
        recordRelativePath =
            workerContract.outputPrefix(
                for: invocationRole
            ) + "/worker-process-binding.v1.json"
        self.planSHA256 = planSHA256
        self.processIdentifier =
            processIdentifier
        executableTargetName =
            workerContract.executableTargetName
        self.exactTransitiveLocalTargetNames =
            exactTransitiveLocalTargetNames
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.compiledSourceClosure =
            compiledSourceClosure
        self.sourceIdentitySHA256 =
            sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.buildConfiguration =
            buildConfiguration
        self.sealedWorkerExecutable =
            sealedWorkerExecutable
        self.runningWorkerExecutable =
            runningWorkerExecutable
        runningExecutableCaptureAuthority =
            "PrimeSecureRunningExecutableCapture.data"
        capturedBySameProcess = true
        reproducibleBuildProvenanceClaimed =
            false
    }

    public static func captureCurrentProcess(
        invocationRole:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
        planSHA256: String,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        sealedWorkerExecutable:
            PrimeArtifactBinding,
        workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract,
        sourceExecutionBinding:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws -> Self {
        let runningData =
            try PrimeSecureRunningExecutableCapture
            .data()
        let runningBinding =
            PrimeArtifactBinding(
                relativePath:
                    workerContract
                    .executableRelativePath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of: runningData
                    ),
                byteCount:
                    UInt64(runningData.count),
                purpose: .executable
            )
        let transitive =
            try closure.transitiveTargetNames(
                for:
                    workerContract
                    .executableTargetName,
                against:
                    sourceExecutionBinding
            )
        let record = Self(
            invocationRole: invocationRole,
            planSHA256: planSHA256,
            processIdentifier:
                ProcessInfo.processInfo
                .processIdentifier,
            exactTransitiveLocalTargetNames:
                transitive,
            primeSourceSnapshot:
                primeSourceSnapshot,
            compiledSourceClosure:
                compiledSourceClosure,
            sourceIdentitySHA256:
                closure.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            buildConfiguration:
                PrimeEmbeddedBuildProvenance
                .buildConfiguration,
            sealedWorkerExecutable:
                sealedWorkerExecutable,
            runningWorkerExecutable:
                runningBinding,
            workerContract: workerContract
        )
        try record.validateForRunningRelease(
            against: workerContract,
            sourceExecutionBinding:
                sourceExecutionBinding,
            expectedPlanSHA256:
                planSHA256,
            closure: closure,
            closureBinding:
                compiledSourceClosure,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            capturedRunningExecutableData:
                runningData
        )
        return record
    }

    public func validateForRunningRelease(
        against workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract,
        sourceExecutionBinding:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedPlanSHA256: String,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        closureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        capturedRunningExecutableData: Data
    ) throws {
        guard PrimeEmbeddedBuildProvenance
                .buildConfiguration == "release"
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_running_configuration"
                )
        }
        try workerContract.validate(
            adaptationProof:
                .frozenV2,
            sourceExecutionBinding:
                sourceExecutionBinding
        )
        try validate(
            against: workerContract,
            sourceExecutionBinding:
                sourceExecutionBinding,
            expectedPlanSHA256:
                expectedPlanSHA256,
            closure: closure,
            closureBinding:
                closureBinding,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            capturedRunningExecutableData:
                capturedRunningExecutableData,
            expectedEmbeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            expectedBuildConfiguration:
                PrimeEmbeddedBuildProvenance
                .buildConfiguration
        )
    }

    func validate(
        against workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract,
        sourceExecutionBinding:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        expectedPlanSHA256: String,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        closureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        capturedRunningExecutableData: Data,
        expectedEmbeddedSourceIdentitySHA256:
            String,
        expectedBuildConfiguration: String
    ) throws {
        try [
            primeSourceSnapshot,
            compiledSourceClosure,
            sealedWorkerExecutable,
            runningWorkerExecutable,
        ].forEach {
            try $0.validateDeclaration()
        }
        try closure.validate(
            against: sourceExecutionBinding,
            expectedPlanSHA256:
                expectedPlanSHA256,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            expectedEmbeddedSourceIdentitySHA256:
                expectedEmbeddedSourceIdentitySHA256
        )
        let expectedClosureBinding =
            try closure.artifactBinding(
                relativePath:
                    sourceExecutionBinding
                    .compiledSourceClosureRelativePath
            )
        let transitive =
            try closure.transitiveTargetNames(
                for:
                    workerContract
                    .executableTargetName,
                against: sourceExecutionBinding
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_historical_worker_process_binding",
              recordRelativePath
                == workerContract.outputPrefix(
                    for: invocationRole
                ) + "/worker-process-binding.v1.json",
              planSHA256
                == expectedPlanSHA256,
              processIdentifier > 0,
              executableTargetName
                == workerContract
                .executableTargetName,
              exactTransitiveLocalTargetNames
                == transitive,
              primeSourceSnapshot
                == closure.primeSourceSnapshot,
              compiledSourceClosure
                == closureBinding,
              closureBinding
                == expectedClosureBinding,
              sourceIdentitySHA256
                == closure.sourceIdentitySHA256,
              embeddedSourceIdentitySHA256
                == closure
                .embeddedSourceIdentitySHA256,
              sourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              embeddedSourceIdentitySHA256
                == expectedEmbeddedSourceIdentitySHA256,
              buildConfiguration
                == closure.buildConfiguration,
              buildConfiguration
                == expectedBuildConfiguration,
              buildConfiguration == "release",
              sealedWorkerExecutable.relativePath
                == workerContract
                .executableRelativePath,
              sealedWorkerExecutable.purpose
                == .executable,
              runningWorkerExecutable
                == sealedWorkerExecutable,
              runningWorkerExecutable.byteCount
                == UInt64(
                    capturedRunningExecutableData.count
                ),
              runningWorkerExecutable.sha256
                == PrimeSHA256.hexDigest(
                    of:
                        capturedRunningExecutableData
                ),
              runningExecutableCaptureAuthority
                == sourceExecutionBinding
                .runningExecutableCaptureAuthority,
              capturedBySameProcess,
              !reproducibleBuildProvenanceClaimed
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_process_binding"
                )
        }
    }

    public func artifactBinding()
        throws -> PrimeArtifactBinding
    {
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath: recordRelativePath,
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case invocationRole =
            "invocation_role"
        case recordRelativePath =
            "record_relative_path"
        case planSHA256 = "plan_sha256"
        case processIdentifier =
            "process_identifier"
        case executableTargetName =
            "executable_target_name"
        case exactTransitiveLocalTargetNames =
            "exact_transitive_local_target_names"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case compiledSourceClosure =
            "compiled_source_closure"
        case sourceIdentitySHA256 =
            "source_identity_sha256"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case buildConfiguration =
            "build_configuration"
        case sealedWorkerExecutable =
            "sealed_worker_executable"
        case runningWorkerExecutable =
            "running_worker_executable"
        case runningExecutableCaptureAuthority =
            "running_executable_capture_authority"
        case capturedBySameProcess =
            "captured_by_same_process"
        case reproducibleBuildProvenanceClaimed =
            "reproducible_build_provenance_claimed"
    }
}

public struct PrimeNativeNeuralGateHistoricalWorkerResult:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    public let workerProcessIdentifier: Int32
    public let request: PrimeArtifactBinding
    public let workerProcessBinding:
        PrimeArtifactBinding
    public let runningWorkerExecutable:
        PrimeArtifactBinding
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let compiledSourceClosure:
        PrimeArtifactBinding
    public let embeddedSourceIdentitySHA256:
        String
    public let copiedPackageLock:
        PrimeArtifactBinding
    public let materialIdentityManifest:
        PrimeArtifactBinding
    public let gateObservation:
        PrimeArtifactBinding
    public let invariantRecordManifest:
        PrimeArtifactBinding
    public let invariantGlobalStream:
        PrimeArtifactBinding
    public let orderedInvariantChunks:
        [PrimeArtifactBinding]
    public let fingerprintObservation:
        PrimeArtifactBinding
    public let mutationObservations:
        PrimeArtifactBinding
    public let statisticsVerdictObservation:
        PrimeArtifactBinding
    public let roleNeutralArtifactIdentitySHA256:
        String
    public let fixtureDurationNanoseconds:
        UInt64
    public let gateDurationNanoseconds: UInt64
    public let durationsAuthoritative: Bool
    public let historicalMechanicsDisposition:
        PrimeNativeNeuralGateScopedOutcome
    public let mechanicsDispositionAuthoritative:
        Bool
    public let historicalTargetIndependenceDisposition:
        PrimeNativeNeuralGateScopedOutcome
    public let modelCapabilityDisposition:
        PrimeNativeNeuralGateScopedOutcome
    public let scientificAuthorityClaimed:
        Bool
    public let productAuthorityClaimed: Bool
    public let preResultProducedArtifactInventory:
        [PrimeArtifactBinding]

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
        workerProcessIdentifier: Int32,
        request: PrimeArtifactBinding,
        workerProcessBinding:
            PrimeArtifactBinding,
        runningWorkerExecutable:
            PrimeArtifactBinding,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        compiledSourceClosure:
            PrimeArtifactBinding,
        embeddedSourceIdentitySHA256:
            String,
        copiedPackageLock:
            PrimeArtifactBinding,
        materialIdentityManifest:
            PrimeArtifactBinding,
        gateObservation:
            PrimeArtifactBinding,
        invariantRecordManifest:
            PrimeArtifactBinding,
        invariantGlobalStream:
            PrimeArtifactBinding,
        orderedInvariantChunks:
            [PrimeArtifactBinding],
        fingerprintObservation:
            PrimeArtifactBinding,
        mutationObservations:
            PrimeArtifactBinding,
        statisticsVerdictObservation:
            PrimeArtifactBinding,
        fixtureDurationNanoseconds:
            UInt64,
        gateDurationNanoseconds: UInt64,
        historicalMechanicsDisposition:
            PrimeNativeNeuralGateScopedOutcome
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_historical_worker_result"
        self.invocationRole =
            invocationRole
        self.workerProcessIdentifier =
            workerProcessIdentifier
        self.request = request
        self.workerProcessBinding =
            workerProcessBinding
        self.runningWorkerExecutable =
            runningWorkerExecutable
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.compiledSourceClosure =
            compiledSourceClosure
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.copiedPackageLock =
            copiedPackageLock
        self.materialIdentityManifest =
            materialIdentityManifest
        self.gateObservation = gateObservation
        self.invariantRecordManifest =
            invariantRecordManifest
        self.invariantGlobalStream =
            invariantGlobalStream
        self.orderedInvariantChunks =
            orderedInvariantChunks
        self.fingerprintObservation =
            fingerprintObservation
        self.mutationObservations =
            mutationObservations
        self.statisticsVerdictObservation =
            statisticsVerdictObservation
        self.fixtureDurationNanoseconds =
            fixtureDurationNanoseconds
        self.gateDurationNanoseconds =
            gateDurationNanoseconds
        durationsAuthoritative = false
        self.historicalMechanicsDisposition =
            historicalMechanicsDisposition
        mechanicsDispositionAuthoritative =
            false
        historicalTargetIndependenceDisposition =
            .abstain
        modelCapabilityDisposition = .abstain
        scientificAuthorityClaimed = false
        productAuthorityClaimed = false
        let semanticArtifacts =
            [
                materialIdentityManifest,
                gateObservation,
                invariantRecordManifest,
                invariantGlobalStream,
            ]
            + orderedInvariantChunks
            + [
                fingerprintObservation,
                mutationObservations,
                statisticsVerdictObservation,
            ]
        preResultProducedArtifactInventory =
            (
                [workerProcessBinding]
                + semanticArtifacts
            ).sorted {
                PrimeNativeNeuralGateSourceFileIdentity
                    .rawUTF8Less(
                        $0.relativePath,
                        $1.relativePath
                    )
            }
        roleNeutralArtifactIdentitySHA256 =
            Self.roleNeutralArtifactIdentitySHA256(
                for: semanticArtifacts
            )
    }

    public var roleNeutralSemanticArtifactBindings:
        [PrimeArtifactBinding]
    {
        [
            materialIdentityManifest,
            gateObservation,
            invariantRecordManifest,
            invariantGlobalStream,
        ]
        + orderedInvariantChunks
        + [
            fingerprintObservation,
            mutationObservations,
            statisticsVerdictObservation,
        ]
    }

    public func validateAgainstPrevalidatedWorkerProcess(
        request expectedRequest:
            PrimeNativeNeuralGateHistoricalWorkerRequest,
        requestBinding:
            PrimeArtifactBinding,
        workerProcess:
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
        workerProcessBinding:
            PrimeArtifactBinding,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try contract.validateFrozenIdentity()
        let bindings =
            preResultProducedArtifactInventory
        try (
            [
                request,
                workerProcessBinding,
                runningWorkerExecutable,
                primeSourceSnapshot,
                compiledSourceClosure,
                copiedPackageLock,
            ] + bindings
        ).forEach {
            try $0.validateDeclaration()
        }
        let prefix =
            contract.outputPrefix(
                for: invocationRole
            ) + "/"
        let fixedArtifactLeafBindings = [
            (
                "material-identity-manifest.v1.json",
                materialIdentityManifest
            ),
            (
                "gate-observation.v1.json",
                gateObservation
            ),
            (
                "invariant-records-manifest.v1.json",
                invariantRecordManifest
            ),
            (
                "invariant-records.v1.bin",
                invariantGlobalStream
            ),
            (
                "fingerprint-observation.v1.json",
                fingerprintObservation
            ),
            (
                "mutation-observations.v1.json",
                mutationObservations
            ),
            (
                "statistics-verdict-observation.v1.json",
                statisticsVerdictObservation
            ),
        ]
        let expectedInventory =
            (
                [workerProcessBinding]
                + roleNeutralSemanticArtifactBindings
            ).sorted {
                PrimeNativeNeuralGateSourceFileIdentity
                    .rawUTF8Less(
                        $0.relativePath,
                        $1.relativePath
                    )
            }
        let expectedWorkerProcessBinding =
            try workerProcess.artifactBinding()
        let expectedRequestBinding =
            try expectedRequest.artifactBinding(
                contract: contract
            )
        let expectedFixedWorkerProducedPaths =
            Set(
                contract
                .workerOwnedFixedOutputRelativePaths(
                    for: invocationRole
                )
                .filter {
                    $0
                        != contract
                        .resultRelativePath(
                            for: invocationRole
                        )
                }
            )
        let observedFixedWorkerProducedPaths =
            Set(
                bindings
                .map(\.relativePath)
                .filter {
                    !Self.matchesChunkPath(
                        $0,
                        pattern:
                            expectedRequest
                            .dynamicChunkRelativePathPattern
                    )
                }
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_historical_worker_result",
              invocationRole
                == expectedRequest.invocationRole,
              workerProcessIdentifier > 0,
              request == requestBinding,
              requestBinding
                == expectedRequestBinding,
              self.workerProcessBinding
                == workerProcessBinding,
              workerProcessBinding
                == expectedWorkerProcessBinding,
              workerProcess.invocationRole
                == invocationRole,
              workerProcess.processIdentifier
                == workerProcessIdentifier,
              runningWorkerExecutable
                == workerProcess
                .runningWorkerExecutable,
              runningWorkerExecutable
                == expectedRequest
                .sealedWorkerExecutable,
              primeSourceSnapshot
                == expectedRequest
                .primeSourceSnapshot,
              compiledSourceClosure
                == expectedRequest
                .compiledSourceClosure,
              embeddedSourceIdentitySHA256
                == expectedRequest
                .embeddedSourceIdentitySHA256,
              copiedPackageLock
                == expectedRequest
                .copiedPackageLock,
              fixedArtifactLeafBindings.allSatisfy({
                  leaf, binding in
                  binding.relativePath
                      == prefix + leaf
                      && binding.purpose
                          == .immutableData
              }),
              !orderedInvariantChunks.isEmpty,
              orderedInvariantChunks
                .allSatisfy({
                    Self.matchesChunkPath(
                        $0.relativePath,
                        pattern:
                            expectedRequest
                            .dynamicChunkRelativePathPattern
                    )
                        && $0.purpose
                            == .immutableData
                }),
              orderedInvariantChunks
                .map(\.relativePath)
                == orderedInvariantChunks
                .map(\.relativePath)
                .sorted(
                    by:
                        PrimeNativeNeuralGateSourceFileIdentity
                        .rawUTF8Less
                ),
              Set(bindings.map(\.relativePath))
                .count == bindings.count,
              preResultProducedArtifactInventory
                == expectedInventory,
              observedFixedWorkerProducedPaths
                == expectedFixedWorkerProducedPaths,
              roleNeutralArtifactIdentitySHA256
                == Self
                .roleNeutralArtifactIdentitySHA256(
                    for:
                        roleNeutralSemanticArtifactBindings
                ),
              !durationsAuthoritative,
              mechanicsDispositionAuthoritative
                == contract
                .workerResultCanEstablishMechanicsPass,
              historicalTargetIndependenceDisposition
                == .abstain,
              modelCapabilityDisposition
                == .abstain,
              !scientificAuthorityClaimed,
              !productAuthorityClaimed
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_result"
                )
        }
    }

    private static func roleNeutralArtifactIdentitySHA256(
        for bindings: [PrimeArtifactBinding]
    ) -> String {
        var data = Data(
            "PRIMEHRA1\n".utf8
        )
        for (ordinal, binding) in
            bindings.enumerated()
        {
            data.append(
                Data(
                    "\(ordinal)|\(binding.sha256)|\(binding.byteCount)|\(binding.purpose.rawValue)\n"
                        .utf8
                )
            )
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    public func artifactBinding(
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws -> PrimeArtifactBinding {
        try contract.validateFrozenIdentity()
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        guard UInt64(data.count)
                <= contract.maximumResultBytes
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_result_size"
                )
        }
        return PrimeArtifactBinding(
            relativePath:
                contract.resultRelativePath(
                    for: invocationRole
                ),
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    private static func matchesChunkPath(
        _ path: String,
        pattern: String
    ) -> Bool {
        let placeholder = "{ordinal_8digit}"
        guard let range = pattern.range(
            of: placeholder
        ) else {
            return false
        }
        let prefix = String(
            pattern[..<range.lowerBound]
        )
        let suffix = String(
            pattern[range.upperBound...]
        )
        guard path.hasPrefix(prefix),
              path.hasSuffix(suffix),
              path.utf8.count
                == prefix.utf8.count
                    + 8
                    + suffix.utf8.count
        else {
            return false
        }
        let start = path.index(
            path.startIndex,
            offsetBy: prefix.count
        )
        let end = path.index(
            start,
            offsetBy: 8
        )
        return path[start..<end].utf8
            .allSatisfy {
                $0 >= 48 && $0 <= 57
            }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case invocationRole =
            "invocation_role"
        case workerProcessIdentifier =
            "worker_process_identifier"
        case request
        case workerProcessBinding =
            "worker_process_binding"
        case runningWorkerExecutable =
            "running_worker_executable"
        case primeSourceSnapshot =
            "prime_source_snapshot"
        case compiledSourceClosure =
            "compiled_source_closure"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case copiedPackageLock =
            "copied_package_lock"
        case materialIdentityManifest =
            "material_identity_manifest"
        case gateObservation =
            "gate_observation"
        case invariantRecordManifest =
            "invariant_record_manifest"
        case invariantGlobalStream =
            "invariant_global_stream"
        case orderedInvariantChunks =
            "ordered_invariant_chunks"
        case fingerprintObservation =
            "fingerprint_observation"
        case mutationObservations =
            "mutation_observations"
        case statisticsVerdictObservation =
            "statistics_verdict_observation"
        case roleNeutralArtifactIdentitySHA256 =
            "role_neutral_artifact_identity_sha256"
        case fixtureDurationNanoseconds =
            "fixture_duration_nanoseconds"
        case gateDurationNanoseconds =
            "gate_duration_nanoseconds"
        case durationsAuthoritative =
            "durations_authoritative"
        case historicalMechanicsDisposition =
            "historical_mechanics_disposition"
        case mechanicsDispositionAuthoritative =
            "mechanics_disposition_authoritative"
        case historicalTargetIndependenceDisposition =
            "historical_target_independence_disposition"
        case modelCapabilityDisposition =
            "model_capability_disposition"
        case scientificAuthorityClaimed =
            "scientific_authority_claimed"
        case productAuthorityClaimed =
            "product_authority_claimed"
        case preResultProducedArtifactInventory =
            "pre_result_produced_artifact_inventory"
    }
}

public struct PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let supervisorRole:
        PrimeNativeNeuralGateHistoricalWorkerInvocationRole
    public let supervisorProcessIdentifier:
        Int32
    public let workerProcessIdentifier: Int32
    public let sealedWorkerExecutable:
        PrimeArtifactBinding
    public let request: PrimeArtifactBinding
    public let workerResult: PrimeArtifactBinding
    public let maximumWallSeconds: UInt64
    public let observedMonotonicWallNanoseconds:
        UInt64
    public let environmentKeyCount: Int
    public let standardInputPolicy: String
    public let maximumStandardOutputBytes:
        UInt64
    public let maximumStandardErrorBytes:
        UInt64
    public let standardOutput:
        PrimeNativeNeuralGateHistoricalWorkerStreamObservation
    public let standardError:
        PrimeNativeNeuralGateHistoricalWorkerStreamObservation
    public let termination:
        PrimeNativeNeuralGateHistoricalWorkerTerminationDisposition
    public let terminationControlPolicy: String
    public let workerTerminationObserved: Bool
    public let workerReaped: Bool
    public let descriptorEnumerationAuthority:
        String
    public let preLaunchRolePrefixInventory:
        PrimeNativeNeuralGateRealizedFilesystemInventory
    public let postExitRolePrefixInventory:
        PrimeNativeNeuralGateRealizedFilesystemInventory

    public init(
        supervisorRole:
            PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
        supervisorProcessIdentifier:
            Int32,
        workerProcessIdentifier: Int32,
        sealedWorkerExecutable:
            PrimeArtifactBinding,
        request: PrimeArtifactBinding,
        workerResult: PrimeArtifactBinding,
        observedMonotonicWallNanoseconds:
            UInt64,
        standardOutput:
            PrimeNativeNeuralGateHistoricalWorkerStreamObservation,
        standardError:
            PrimeNativeNeuralGateHistoricalWorkerStreamObservation,
        termination:
            PrimeNativeNeuralGateHistoricalWorkerTerminationDisposition,
        workerTerminationObserved: Bool,
        workerReaped: Bool,
        preLaunchRolePrefixInventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory,
        postExitRolePrefixInventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_historical_worker_successful_execution"
        self.supervisorRole =
            supervisorRole
        self.supervisorProcessIdentifier =
            supervisorProcessIdentifier
        self.workerProcessIdentifier =
            workerProcessIdentifier
        self.sealedWorkerExecutable =
            sealedWorkerExecutable
        self.request = request
        self.workerResult = workerResult
        maximumWallSeconds =
            contract.maximumWallSeconds
        self.observedMonotonicWallNanoseconds =
            observedMonotonicWallNanoseconds
        environmentKeyCount = 0
        standardInputPolicy =
            contract.standardInputPolicy
        maximumStandardOutputBytes =
            contract
            .maximumStandardOutputBytes
        maximumStandardErrorBytes =
            contract
            .maximumStandardErrorBytes
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.termination = termination
        terminationControlPolicy =
            contract.terminationEscalationPolicy
        self.workerTerminationObserved =
            workerTerminationObserved
        self.workerReaped = workerReaped
        descriptorEnumerationAuthority =
            "descriptor_rooted_recursive_all_node_inventory_sha256_and_mode_v1"
        self.preLaunchRolePrefixInventory =
            preLaunchRolePrefixInventory
        self.postExitRolePrefixInventory =
            postExitRolePrefixInventory
    }

    public func validateSuccessfulAgainstPrevalidatedRequestAndResult(
        request expectedRequest:
            PrimeNativeNeuralGateHistoricalWorkerRequest,
        result:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        resultBinding:
            PrimeArtifactBinding,
        requestBinding:
            PrimeArtifactBinding,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try contract.validateFrozenIdentity()
        try (
            [
                sealedWorkerExecutable,
                request,
                workerResult,
            ]
                + preLaunchRolePrefixInventory
                .fileEntries.map(\.artifact)
                + postExitRolePrefixInventory
                .fileEntries.map(\.artifact)
        ).forEach {
            try $0.validateDeclaration()
        }
        let expectedWorkerArtifacts =
            (
                result
                    .preResultProducedArtifactInventory
                + [resultBinding]
            ).sorted {
                PrimeNativeNeuralGateSourceFileIdentity
                    .rawUTF8Less(
                        $0.relativePath,
                        $1.relativePath
                    )
            }
        let expectedResultBinding =
            try result.artifactBinding(
                contract: contract
            )
        let expectedRequestBinding =
            try expectedRequest.artifactBinding(
                contract: contract
            )
        let expectedPreLaunchArtifacts = [
            Self.realizedImmutableEntry(
                requestBinding
            ),
        ]
        let expectedPostExitArtifacts =
            (
                expectedPreLaunchArtifacts
                    + expectedWorkerArtifacts
                    .map(
                        Self.realizedImmutableEntry
                    )
            ).sorted {
                PrimeNativeNeuralGateSourceFileIdentity
                    .rawUTF8Less(
                        $0.artifact.relativePath,
                        $1.artifact.relativePath
                    )
            }
        try preLaunchRolePrefixInventory
            .validateExactNodeClosure(
                expectedFileEntries:
                    expectedPreLaunchArtifacts
            )
        try postExitRolePrefixInventory
            .validateExactNodeClosure(
                expectedFileEntries:
                    expectedPostExitArtifacts
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_historical_worker_successful_execution",
              supervisorRole
                == expectedRequest.invocationRole,
              supervisorRole
                == result.invocationRole,
              supervisorProcessIdentifier > 0,
              workerProcessIdentifier > 0,
              supervisorProcessIdentifier
                != workerProcessIdentifier,
              workerProcessIdentifier
                == result
                .workerProcessIdentifier,
              sealedWorkerExecutable
                == result
                .runningWorkerExecutable,
              request == requestBinding,
              requestBinding
                == expectedRequestBinding,
              result.request == requestBinding,
              workerResult == resultBinding,
              resultBinding
                == expectedResultBinding,
              maximumWallSeconds
                == contract.maximumWallSeconds,
              observedMonotonicWallNanoseconds
                > 0,
              observedMonotonicWallNanoseconds
                <= maximumWallSeconds
                    * 1_000_000_000,
              environmentKeyCount == 0,
              standardInputPolicy
                == contract.standardInputPolicy,
              maximumStandardOutputBytes
                == contract
                .maximumStandardOutputBytes,
              maximumStandardErrorBytes
                == contract
                .maximumStandardErrorBytes,
              standardOutput
                .isSuccessfulEmptyDrain,
              standardError
                .isSuccessfulEmptyDrain,
              termination.isCleanExitZero,
              terminationControlPolicy
                == contract
                .terminationEscalationPolicy,
              workerTerminationObserved,
              workerReaped,
              descriptorEnumerationAuthority
                == "descriptor_rooted_recursive_all_node_inventory_sha256_and_mode_v1",
              preLaunchRolePrefixInventory
                .rootRelativePath
                == contract.outputPrefix(
                    for: supervisorRole
                ),
              postExitRolePrefixInventory
                .rootRelativePath
                == contract.outputPrefix(
                    for: supervisorRole
                )
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_successful_execution"
                )
        }
    }

    public static func validateRoleNeutralTransportPair(
        probeExecution:
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord,
        probeResult:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        verifierExecution:
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord,
        verifierResult:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try contract.validateFrozenIdentity()
        let processIDs: Set<Int32> = [
            probeExecution
                .supervisorProcessIdentifier,
            probeExecution.workerProcessIdentifier,
            verifierExecution
                .supervisorProcessIdentifier,
            verifierExecution.workerProcessIdentifier,
        ]
        let probeRoleNeutral =
            probeResult
            .roleNeutralSemanticArtifactBindings
            .map {
                (
                    $0.byteCount,
                    $0.sha256,
                    $0.purpose
                )
            }
        let verifierRoleNeutral =
            verifierResult
            .roleNeutralSemanticArtifactBindings
            .map {
                (
                    $0.byteCount,
                    $0.sha256,
                    $0.purpose
                )
            }
        let probeResultBinding =
            try probeResult.artifactBinding(
                contract: contract
            )
        let verifierResultBinding =
            try verifierResult.artifactBinding(
                contract: contract
            )
        guard probeExecution.supervisorRole
                == .probe,
              verifierExecution.supervisorRole
                == .verifier,
              probeResult.invocationRole == .probe,
              verifierResult.invocationRole
                == .verifier,
              processIDs.count == 4,
              probeExecution.request
                == probeResult.request,
              verifierExecution.request
                == verifierResult.request,
              probeExecution.workerResult
                == probeResultBinding,
              verifierExecution.workerResult
                == verifierResultBinding,
              probeExecution.sealedWorkerExecutable
                == verifierExecution
                .sealedWorkerExecutable,
              probeResult.primeSourceSnapshot
                == verifierResult
                .primeSourceSnapshot,
              probeResult.compiledSourceClosure
                == verifierResult
                .compiledSourceClosure,
              probeResult.embeddedSourceIdentitySHA256
                == verifierResult
                .embeddedSourceIdentitySHA256,
              probeResult.copiedPackageLock
                == verifierResult
                .copiedPackageLock,
              probeResult
                .roleNeutralArtifactIdentitySHA256
                == verifierResult
                .roleNeutralArtifactIdentitySHA256,
              probeResult
                .historicalMechanicsDisposition
                == verifierResult
                .historicalMechanicsDisposition,
              probeRoleNeutral.count
                == verifierRoleNeutral.count,
              zip(
                  probeRoleNeutral,
                  verifierRoleNeutral
              ).allSatisfy({
                  $0.0.0 == $0.1.0
                      && $0.0.1 == $0.1.1
                      && $0.0.2 == $0.1.2
              })
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_worker_pair"
                )
        }
    }

    public static func validateCompleteProcessTopologyOfPrevalidatedRecords(
        probeProcess:
            PrimeNativeNeuralGateReleaseProcessBindingRecord,
        probeDescribeCapture:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        probeWorkerProcess:
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
        probeExecution:
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord,
        probeResult:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        verifierProcess:
            PrimeNativeNeuralGateReleaseProcessBindingRecord,
        verifierDescribeCapture:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        verifierWorkerProcess:
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
        verifierExecution:
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord,
        verifierResult:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try workerContract.validateFrozenIdentity()
        try PrimeNativeNeuralGateReleaseProcessBindingRecord
            .validateProbeVerifierPairOfPrevalidatedRecords(
                probe: probeProcess,
                verifier: verifierProcess
            )
        try PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
            .validateProbeVerifierPairOfPrevalidatedRecords(
                probe: probeDescribeCapture,
                verifier:
                    verifierDescribeCapture
            )
        try validateRoleNeutralTransportPair(
            probeExecution: probeExecution,
            probeResult: probeResult,
            verifierExecution:
                verifierExecution,
            verifierResult: verifierResult,
            contract: workerContract
        )
        let processIDs: Set<Int32> = [
            probeProcess.processIdentifier,
            probeDescribeCapture
                .childProcessIdentifier,
            probeWorkerProcess
                .processIdentifier,
            verifierProcess.processIdentifier,
            verifierDescribeCapture
                .childProcessIdentifier,
            verifierWorkerProcess
                .processIdentifier,
        ]
        let probeDescribeCaptureBinding =
            try probeDescribeCapture
            .artifactBinding()
        let verifierDescribeCaptureBinding =
            try verifierDescribeCapture
            .artifactBinding()
        let probeWorkerBinding =
            try probeWorkerProcess
            .artifactBinding()
        let verifierWorkerBinding =
            try verifierWorkerProcess
            .artifactBinding()
        guard processIDs.count == 6,
              probeDescribeCapture
                .supervisorProcessIdentifier
                == probeProcess
                .processIdentifier,
              verifierDescribeCapture
                .supervisorProcessIdentifier
                == verifierProcess
                .processIdentifier,
              probeProcess
                .swiftPackageDescribeCapture
                == probeDescribeCaptureBinding,
              verifierProcess
                .swiftPackageDescribeCapture
                == verifierDescribeCaptureBinding,
              probeExecution
                .supervisorProcessIdentifier
                == probeProcess
                .processIdentifier,
              verifierExecution
                .supervisorProcessIdentifier
                == verifierProcess
                .processIdentifier,
              probeExecution.workerProcessIdentifier
                == probeWorkerProcess
                .processIdentifier,
              verifierExecution
                .workerProcessIdentifier
                == verifierWorkerProcess
                .processIdentifier,
              probeResult.workerProcessIdentifier
                == probeWorkerProcess
                .processIdentifier,
              verifierResult
                .workerProcessIdentifier
                == verifierWorkerProcess
                .processIdentifier,
              probeResult.workerProcessBinding
                == probeWorkerBinding,
              verifierResult.workerProcessBinding
                == verifierWorkerBinding,
              probeWorkerProcess
                .invocationRole == .probe,
              verifierWorkerProcess
                .invocationRole == .verifier,
              probeWorkerProcess.planSHA256
                == probeProcess.planSHA256,
              verifierWorkerProcess.planSHA256
                == verifierProcess.planSHA256,
              probeWorkerProcess
                .primeSourceSnapshot
                == probeProcess
                .primeSourceSnapshot,
              verifierWorkerProcess
                .primeSourceSnapshot
                == verifierProcess
                .primeSourceSnapshot,
              probeWorkerProcess
                .compiledSourceClosure
                == probeProcess
                .compiledSourceClosure,
              verifierWorkerProcess
                .compiledSourceClosure
                == verifierProcess
                .compiledSourceClosure,
              probeWorkerProcess
                .sourceIdentitySHA256
                == probeProcess
                .sourceIdentitySHA256,
              verifierWorkerProcess
                .sourceIdentitySHA256
                == verifierProcess
                .sourceIdentitySHA256,
              probeWorkerProcess
                .embeddedSourceIdentitySHA256
                == probeProcess
                .embeddedSourceIdentitySHA256,
              verifierWorkerProcess
                .embeddedSourceIdentitySHA256
                == verifierProcess
                .embeddedSourceIdentitySHA256,
              probeWorkerProcess
                .buildConfiguration
                == probeProcess
                .buildConfiguration,
              verifierWorkerProcess
                .buildConfiguration
                == verifierProcess
                .buildConfiguration,
              probeExecution
                .sealedWorkerExecutable
                == probeWorkerProcess
                .sealedWorkerExecutable,
              verifierExecution
                .sealedWorkerExecutable
                == verifierWorkerProcess
                .sealedWorkerExecutable,
              probeWorkerProcess
                .sealedWorkerExecutable
                == verifierWorkerProcess
                .sealedWorkerExecutable,
              probeWorkerProcess
                .runningWorkerExecutable
                == verifierWorkerProcess
                .runningWorkerExecutable
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "complete_process_topology"
                )
        }
    }

    public func artifactBinding(
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws -> PrimeArtifactBinding {
        let data = try PrimeCanonicalJSON.encode(
            self
        )
        return PrimeArtifactBinding(
            relativePath:
                contract.executionRelativePath(
                    for: supervisorRole
                ),
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: .immutableData
        )
    }

    private static func realizedImmutableEntry(
        _ artifact: PrimeArtifactBinding
    ) -> PrimeNativeNeuralGateRealizedOutputEntry {
        PrimeNativeNeuralGateRealizedOutputEntry(
            artifact: artifact,
            posixMode: "0444",
            fileType: "regular_file",
            linkCount: 1,
            ownerMatchesCurrentEffectiveUser:
                true,
            capturedFromDescriptor: true
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case supervisorRole =
            "supervisor_role"
        case supervisorProcessIdentifier =
            "supervisor_process_identifier"
        case workerProcessIdentifier =
            "worker_process_identifier"
        case sealedWorkerExecutable =
            "sealed_worker_executable"
        case request
        case workerResult = "worker_result"
        case maximumWallSeconds =
            "maximum_wall_seconds"
        case observedMonotonicWallNanoseconds =
            "observed_monotonic_wall_nanoseconds"
        case environmentKeyCount =
            "environment_key_count"
        case standardInputPolicy =
            "standard_input_policy"
        case maximumStandardOutputBytes =
            "maximum_standard_output_bytes"
        case maximumStandardErrorBytes =
            "maximum_standard_error_bytes"
        case standardOutput =
            "standard_output"
        case standardError =
            "standard_error"
        case termination
        case terminationControlPolicy =
            "termination_control_policy"
        case workerTerminationObserved =
            "worker_termination_observed"
        case workerReaped =
            "worker_reaped"
        case descriptorEnumerationAuthority =
            "descriptor_enumeration_authority"
        case preLaunchRolePrefixInventory =
            "pre_launch_role_prefix_inventory"
        case postExitRolePrefixInventory =
            "post_exit_role_prefix_inventory"
    }
}

public enum PrimeNativeNeuralGateOutputPathClass:
    String,
    Codable,
    Equatable,
    Sendable
{
    case ordinaryImmutableData =
        "ordinary_immutable_data"
    case stageAParentCopiedArtifact =
        "stage_a_parent_copied_artifact"
    case runningExecutable =
        "running_executable"
    case terminalReceipt =
        "terminal_receipt"
}

public struct PrimeNativeNeuralGateOutputPathClassificationContract:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let ordinaryFixedRelativePaths:
        [String]
    public let ordinaryDynamicRelativePathPatterns:
        [String]
    public let stageAParentCopyRootRelativePath:
        String
    public let stageAForbiddenRelativePaths:
        [String]
    public let runningExecutableRelativePaths:
        [String]
    public let terminalReceiptRelativePath:
        String
    public let ordinaryArtifactPurpose:
        PrimeArtifactPurpose
    public let ordinaryArtifactMode: String
    public let stageAParentArtifactPurposePolicy:
        String
    public let stageAParentArtifactModePolicy:
        String
    public let runningExecutablePurpose:
        PrimeArtifactPurpose
    public let runningExecutableMode: String
    public let terminalReceiptPurpose:
        PrimeArtifactPurpose
    public let terminalReceiptMode: String
    public let classificationAuthorizesPublication:
        Bool
    public let exactRealizedInventoryValidationRequired:
        Bool

    public init(
        ordinaryFixedRelativePaths: [String],
        ordinaryDynamicRelativePathPatterns:
            [String],
        stageAParentCopyRootRelativePath:
            String,
        stageAForbiddenRelativePaths:
            [String],
        runningExecutableRelativePaths:
            [String],
        terminalReceiptRelativePath:
            String
    ) {
        contractID =
            "prime_stage_b_output_path_namespace_classification_v3"
        self.ordinaryFixedRelativePaths =
            ordinaryFixedRelativePaths
        self.ordinaryDynamicRelativePathPatterns =
            ordinaryDynamicRelativePathPatterns
        self.stageAParentCopyRootRelativePath =
            stageAParentCopyRootRelativePath
        self.stageAForbiddenRelativePaths =
            stageAForbiddenRelativePaths
        self.runningExecutableRelativePaths =
            runningExecutableRelativePaths
        self.terminalReceiptRelativePath =
            terminalReceiptRelativePath
        ordinaryArtifactPurpose = .immutableData
        ordinaryArtifactMode = "0444"
        stageAParentArtifactPurposePolicy =
            "preserve_each_authenticated_stage_a_binding_purpose_v1"
        stageAParentArtifactModePolicy =
            "purpose_immutable_data_0444_or_executable_0555_v1"
        runningExecutablePurpose = .executable
        runningExecutableMode = "0555"
        terminalReceiptPurpose = .immutableData
        terminalReceiptMode = "0444"
        classificationAuthorizesPublication =
            false
        exactRealizedInventoryValidationRequired =
            true
    }

    public func classification(
        for relativePath: String
    ) -> PrimeNativeNeuralGateOutputPathClass? {
        guard Self.isSafeRelativePath(
            relativePath
        ) else {
            return nil
        }
        var matches =
            [PrimeNativeNeuralGateOutputPathClass]()
        let ordinaryRuleMatchCount =
            (
                ordinaryFixedRelativePaths.contains(
                    relativePath
                )
                    ? 1
                    : 0
            )
            + ordinaryDynamicRelativePathPatterns
            .filter {
                Self.matches(
                    relativePath,
                    pattern: $0
                )
            }.count
        guard ordinaryRuleMatchCount <= 1 else {
            return nil
        }
        if ordinaryRuleMatchCount == 1 {
            matches.append(.ordinaryImmutableData)
        }
        if relativePath.hasPrefix(
            stageAParentCopyRootRelativePath
                + "/"
        )
            && !stageAForbiddenRelativePaths
            .contains(relativePath)
        {
            matches.append(
                .stageAParentCopiedArtifact
            )
        }
        if runningExecutableRelativePaths
            .contains(relativePath)
        {
            matches.append(.runningExecutable)
        }
        if relativePath
            == terminalReceiptRelativePath
        {
            matches.append(.terminalReceipt)
        }
        guard matches.count == 1 else {
            return nil
        }
        return matches[0]
    }

    public func validate() throws {
        let allExact =
            ordinaryFixedRelativePaths
            + runningExecutableRelativePaths
            + stageAForbiddenRelativePaths
            + [
                terminalReceiptRelativePath,
            ]
        let nonStageAExact =
            ordinaryFixedRelativePaths
            + runningExecutableRelativePaths
            + [
                terminalReceiptRelativePath,
            ]
        guard contractID
                == "prime_stage_b_output_path_namespace_classification_v3",
              !ordinaryFixedRelativePaths.isEmpty,
              Set(ordinaryFixedRelativePaths)
                .count
                == ordinaryFixedRelativePaths.count,
              ordinaryDynamicRelativePathPatterns
                .count == 3,
              Set(
                  ordinaryDynamicRelativePathPatterns
              ).count
                == ordinaryDynamicRelativePathPatterns
                .count,
              !runningExecutableRelativePaths
                .isEmpty,
              Set(runningExecutableRelativePaths)
                .count
                == runningExecutableRelativePaths
                .count,
              allExact.allSatisfy(
                  Self.isSafeRelativePath
              ),
              Self.isSafeRelativePath(
                  stageAParentCopyRootRelativePath
              ),
              stageAForbiddenRelativePaths.count
                == 3,
              Set(stageAForbiddenRelativePaths)
                .count
                == stageAForbiddenRelativePaths
                .count,
              stageAForbiddenRelativePaths
                .allSatisfy({
                    $0.hasPrefix(
                        stageAParentCopyRootRelativePath
                            + "/"
                    )
                        && classification(for: $0)
                            == nil
                }),
              ordinaryDynamicRelativePathPatterns
                .allSatisfy(
                    Self.isSafeDynamicPattern
                ),
              nonStageAExact.allSatisfy({
                  !$0.hasPrefix(
                      stageAParentCopyRootRelativePath
                          + "/"
                  )
              }),
              !ordinaryFixedRelativePaths.contains(
                  terminalReceiptRelativePath
              ),
              Set(ordinaryFixedRelativePaths)
                .isDisjoint(
                    with: Set(
                        runningExecutableRelativePaths
                    )
                ),
              !runningExecutableRelativePaths
                .contains(
                    terminalReceiptRelativePath
                ),
              ordinaryFixedRelativePaths
                .allSatisfy({ fixed in
                    !ordinaryDynamicRelativePathPatterns
                        .contains {
                            Self.matches(
                                fixed,
                                pattern: $0
                            )
                        }
                }),
              !Self.anyPatternsOverlap(
                  ordinaryDynamicRelativePathPatterns
              ),
              ordinaryFixedRelativePaths
                .allSatisfy({
                    classification(for: $0)
                        == .ordinaryImmutableData
                }),
              runningExecutableRelativePaths
                .allSatisfy({
                    classification(for: $0)
                        == .runningExecutable
                }),
              classification(
                  for: terminalReceiptRelativePath
              ) == .terminalReceipt,
              ordinaryArtifactPurpose
                == .immutableData,
              ordinaryArtifactMode == "0444",
              runningExecutablePurpose
                == .executable,
              runningExecutableMode == "0555",
              terminalReceiptPurpose
                == .immutableData,
              terminalReceiptMode == "0444",
              !classificationAuthorizesPublication,
              exactRealizedInventoryValidationRequired
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "output_path_classification"
                )
        }
    }

    private static let ordinalPlaceholder =
        "{ordinal_8digit}"

    private static func matches(
        _ relativePath: String,
        pattern: String
    ) -> Bool {
        guard let range = pattern.range(
            of: ordinalPlaceholder
        ) else {
            return false
        }
        let prefix = pattern[..<range.lowerBound]
        let suffix = pattern[range.upperBound...]
        guard relativePath.hasPrefix(prefix),
              relativePath.hasSuffix(suffix),
              relativePath.utf8.count
                == prefix.utf8.count
                    + 8
                    + suffix.utf8.count
        else {
            return false
        }
        let start = relativePath.index(
            relativePath.startIndex,
            offsetBy: prefix.count
        )
        let end = relativePath.index(
            start,
            offsetBy: 8
        )
        return relativePath[start..<end].utf8
            .allSatisfy {
                $0 >= 48 && $0 <= 57
            }
    }

    private static func isSafeDynamicPattern(
        _ pattern: String
    ) -> Bool {
        guard pattern.components(
            separatedBy: ordinalPlaceholder
        ).count == 2 else {
            return false
        }
        return isSafeRelativePath(
            pattern.replacingOccurrences(
                of: ordinalPlaceholder,
                with: "00000000"
            )
        )
    }

    private static func anyPatternsOverlap(
        _ patterns: [String]
    ) -> Bool {
        for leftIndex in patterns.indices {
            for rightIndex in patterns.indices
            where rightIndex > leftIndex {
                if patternsOverlap(
                    patterns[leftIndex],
                    patterns[rightIndex]
                ) {
                    return true
                }
            }
        }
        return false
    }

    private static func patternsOverlap(
        _ left: String,
        _ right: String
    ) -> Bool {
        func expanded(
            _ pattern: String
        ) -> [UInt8?]? {
            let components = pattern.components(
                separatedBy: ordinalPlaceholder
            )
            guard components.count == 2 else {
                return nil
            }
            return components[0].utf8.map(Optional.some)
                + Array(repeating: nil, count: 8)
                + components[1].utf8.map(Optional.some)
        }
        guard let leftBytes = expanded(left),
              let rightBytes = expanded(right),
              leftBytes.count == rightBytes.count
        else {
            return false
        }
        return zip(leftBytes, rightBytes)
            .allSatisfy { leftByte, rightByte in
                switch (leftByte, rightByte) {
                case let (.some(left), .some(right)):
                    return left == right
                case let (.some(byte), .none),
                     let (.none, .some(byte)):
                    return byte >= 48 && byte <= 57
                case (.none, .none):
                    return true
                }
            }
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        !path.hasPrefix("/")
            && !path.contains("\0")
            && path.split(
                separator: "/",
                omittingEmptySubsequences: false
            ).allSatisfy {
                !$0.isEmpty
                    && $0 != "."
                    && $0 != ".."
                    && $0 != ".git"
            }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case ordinaryFixedRelativePaths =
            "ordinary_fixed_relative_paths"
        case ordinaryDynamicRelativePathPatterns =
            "ordinary_dynamic_relative_path_patterns"
        case stageAParentCopyRootRelativePath =
            "stage_a_parent_copy_root_relative_path"
        case stageAForbiddenRelativePaths =
            "stage_a_forbidden_relative_paths"
        case runningExecutableRelativePaths =
            "running_executable_relative_paths"
        case terminalReceiptRelativePath =
            "terminal_receipt_relative_path"
        case ordinaryArtifactPurpose =
            "ordinary_artifact_purpose"
        case ordinaryArtifactMode =
            "ordinary_artifact_mode"
        case stageAParentArtifactPurposePolicy =
            "stage_a_parent_artifact_purpose_policy"
        case stageAParentArtifactModePolicy =
            "stage_a_parent_artifact_mode_policy"
        case runningExecutablePurpose =
            "running_executable_purpose"
        case runningExecutableMode =
            "running_executable_mode"
        case terminalReceiptPurpose =
            "terminal_receipt_purpose"
        case terminalReceiptMode =
            "terminal_receipt_mode"
        case classificationAuthorizesPublication =
            "classification_authorizes_publication"
        case exactRealizedInventoryValidationRequired =
            "exact_realized_inventory_validation_required"
    }
}

public struct PrimeNativeNeuralGateReplayOutputContract:
    Codable,
    Equatable,
    Sendable
{
    public let copiedSourceBlobRelativePaths:
        [String]
    public let historicalProbeGlobalStreamRelativePath:
        String
    public let historicalVerifierGlobalStreamRelativePath:
        String
    public let correctedGlobalStreamRelativePath:
        String
    public let historicalProbeChunkRelativePathPattern:
        String
    public let historicalVerifierChunkRelativePathPattern:
        String
    public let correctedChunkRelativePathPattern:
        String
    public let chunkOrdinalFormatting: String
    public let stageAParentCopyRootRelativePath:
        String
    public let stageAParentCopyManifestRelativePath:
        String
    public let stageAParentCopyPolicy: String
    public let stageAParentReachableDescriptorBindingCount:
        Int
    public let stageAParentReachableImmutableDataBindingCount:
        Int
    public let stageAParentReachableExecutableBindingCount:
        Int
    public let stageAParentTerminalReceiptCount:
        Int
    public let stageAParentTotalCopiedArtifactCount:
        Int
    public let stageAParentTotalCopiedImmutableDataCount:
        Int
    public let stageAParentTotalCopiedExecutableCount:
        Int
    public let stageAParentUnboundFileNames:
        [String]
    public let stageAParentExactBindingEqualityRequired:
        Bool
    public let stageAParentAllowedPurposes:
        [PrimeArtifactPurpose]
    public let adaptationProofManifestRelativePath:
        String
    public let primeSourceSnapshotRelativePath:
        String
    public let primeSourceClosurePolicy: String
    public let primeSourceStatePolicy: String
    public let probeRunningExecutableRelativePath:
        String
    public let probeExecutableBindingRelativePath:
        String
    public let verifierRunningExecutableRelativePath:
        String
    public let verifierExecutableBindingRelativePath:
        String
    public let historicalWorkerRunningExecutableRelativePath:
        String
    public let historicalWorkerExecutableBindingRelativePath:
        String
    public let runningExecutableCapturePolicy:
        String
    public let processIdentityPolicy: String
    public let allPublishedFilesDescriptorRooted:
        Bool
    public let allPublishedFileSHA256BindingsRequired:
        Bool
    public let exclusiveNoReplacePublicationRequired:
        Bool
    public let outputPathNamespaceClassificationRequired:
        Bool
    public let exactPreReceiptRealizedPathAndMetadataInventoryRequired:
        Bool
    public let pathClassification:
        PrimeNativeNeuralGateOutputPathClassificationContract
    public let ordinaryArtifactPurpose:
        PrimeArtifactPurpose
    public let ordinaryArtifactMode: String
    public let ordinaryArtifactPathClassPolicy:
        String
    public let stageAParentPathClassOverridesOrdinary:
        Bool
    public let runningExecutablePathClassOverridesOrdinary:
        Bool
    public let runningExecutablePurpose:
        PrimeArtifactPurpose
    public let runningExecutableMode: String
    public let executableBindingManifestPurpose:
        PrimeArtifactPurpose
    public let executableBindingManifestMode:
        String
    public let terminalReceiptPurpose:
        PrimeArtifactPurpose
    public let terminalReceiptMode: String
    public let receiptRelativePath: String

    public static let frozenV3: Self = {
        let historicalWorker =
            PrimeNativeNeuralGateHistoricalWorkerContract
            .frozenV2
        let copiedSourceBlobRelativePaths =
            (1 ... 11).map {
                String(
                    format:
                        "neural-gate-replay/source/blobs/%02d.blob",
                    $0
                )
            }
        let runningExecutableRelativePaths = [
            "neural-gate-replay/bin/probe",
            "neural-gate-replay/bin/verifier",
            historicalWorker.executableRelativePath,
        ]
        let receiptRelativePath =
            "prime-native-neural-gate-fixture-replay-receipt.v1.json"
        let stageAParentUnboundFileNames = [
            "README.md",
            "prime-native-neural-gate-contract-projection-probe-output.v1.json",
            "prime-native-neural-gate-contract-projection-verifier-output.v1.json",
        ]
        let ordinaryFixedRelativePaths =
            copiedSourceBlobRelativePaths
            + [
                "neural-gate-replay/plan.v3.json",
                "neural-gate-replay/source/companion-source-inventory.v1.json",
                "neural-gate-replay/source/adaptation-proof.v2.json",
                "neural-gate-replay/source/prime-swift-source-snapshot.v1.json",
                "neural-gate-replay/source/swift-package-describe.v1.json",
                "neural-gate-replay/source/probe-swift-package-describe-capture.v4.json",
                "neural-gate-replay/source/verifier-swift-package-describe-capture.v4.json",
                "neural-gate-replay/source/compiled-target-source-closure.v1.json",
                "neural-gate-replay/parent/stage-a-copy-manifest.v1.json",
                "neural-gate-replay/bin/probe-binding.v1.json",
                "neural-gate-replay/bin/verifier-binding.v1.json",
                historicalWorker
                    .executableBindingRelativePath,
                "neural-gate-replay/corrected/fixture-materialization-manifest.v1.json",
                "neural-gate-replay/corrected/invariant-records-manifest.v1.json",
                "neural-gate-replay/corrected/invariant-records.v1.bin",
                "neural-gate-replay/corrected/fingerprint-observation.v1.json",
                "neural-gate-replay/corrected/mutation-observations.v1.json",
                "neural-gate-replay/probe-observation.v1.json",
                "neural-gate-replay/probe-candidate.v1.json",
                "neural-gate-replay/verifier-observation.v1.json",
            ]
            + historicalWorker
                .fixedOutputRelativePaths(
                    for: .probe
                )
            + historicalWorker
                .fixedOutputRelativePaths(
                    for: .verifier
                )
        return Self(
        copiedSourceBlobRelativePaths:
            copiedSourceBlobRelativePaths,
        historicalProbeGlobalStreamRelativePath:
            historicalWorker.outputPrefix(
                for: .probe
            ) + "/invariant-records.v1.bin",
        historicalVerifierGlobalStreamRelativePath:
            historicalWorker.outputPrefix(
                for: .verifier
            ) + "/invariant-records.v1.bin",
        correctedGlobalStreamRelativePath:
            "neural-gate-replay/corrected/invariant-records.v1.bin",
        historicalProbeChunkRelativePathPattern:
            historicalWorker
            .chunkRelativePathPattern(
                for: .probe
            ),
        historicalVerifierChunkRelativePathPattern:
            historicalWorker
            .chunkRelativePathPattern(
                for: .verifier
            ),
        correctedChunkRelativePathPattern:
            "neural-gate-replay/corrected/invariant-chunks/{ordinal_8digit}.v1.bin",
        chunkOrdinalFormatting:
            "zero_based_ascii_decimal_left_padded_to_8_digits_v1",
        stageAParentCopyRootRelativePath:
            "neural-gate-replay/parent/stage-a",
        stageAParentCopyManifestRelativePath:
            "neural-gate-replay/parent/stage-a-copy-manifest.v1.json",
        stageAParentCopyPolicy:
            "copy_separately_pinned_terminal_receipt_then_traverse_its_35_reachable_typed_descriptor_bindings_copy_all_36_artifacts_byte_exact_preserving_relative_path_and_purpose_require_binding_equality_for_the_35_records_and_revalidate_copied_subroot_v1",
        stageAParentReachableDescriptorBindingCount:
            35,
        stageAParentReachableImmutableDataBindingCount:
            28,
        stageAParentReachableExecutableBindingCount:
            7,
        stageAParentTerminalReceiptCount: 1,
        stageAParentTotalCopiedArtifactCount:
            36,
        stageAParentTotalCopiedImmutableDataCount:
            29,
        stageAParentTotalCopiedExecutableCount:
            7,
        stageAParentUnboundFileNames:
            stageAParentUnboundFileNames,
        stageAParentExactBindingEqualityRequired:
            true,
        stageAParentAllowedPurposes: [
            .immutableData,
            .executable,
        ],
        adaptationProofManifestRelativePath:
            "neural-gate-replay/source/adaptation-proof.v2.json",
        primeSourceSnapshotRelativePath:
            "neural-gate-replay/source/prime-swift-source-snapshot.v1.json",
        primeSourceClosurePolicy:
            "complete_prime_swift_source_provenance_snapshot_plus_evaluated_authority_target_subgraph_for_adaptation_supervisors_and_historical_worker_v1",
        primeSourceStatePolicy:
            "clean_git_revision_tree_and_complete_swift_snapshot_equal_before_probe_after_probe_before_verifier_and_after_verifier_v1",
        probeRunningExecutableRelativePath:
            "neural-gate-replay/bin/probe",
        probeExecutableBindingRelativePath:
            "neural-gate-replay/bin/probe-binding.v1.json",
        verifierRunningExecutableRelativePath:
            "neural-gate-replay/bin/verifier",
        verifierExecutableBindingRelativePath:
            "neural-gate-replay/bin/verifier-binding.v1.json",
        historicalWorkerRunningExecutableRelativePath:
            historicalWorker.executableRelativePath,
        historicalWorkerExecutableBindingRelativePath:
            historicalWorker
            .executableBindingRelativePath,
        runningExecutableCapturePolicy:
            "prime_secure_running_executable_descriptor_capture_bound_to_current_source_snapshot_v1",
        processIdentityPolicy:
            "six_distinct_positive_probe_verifier_swiftpm_child_and_historical_worker_process_ids_with_release_running_image_descriptor_capture_v1",
        allPublishedFilesDescriptorRooted: true,
        allPublishedFileSHA256BindingsRequired:
            true,
        exclusiveNoReplacePublicationRequired:
            true,
        outputPathNamespaceClassificationRequired:
            true,
        exactPreReceiptRealizedPathAndMetadataInventoryRequired:
            true,
        pathClassification:
            PrimeNativeNeuralGateOutputPathClassificationContract(
                ordinaryFixedRelativePaths:
                    ordinaryFixedRelativePaths,
                ordinaryDynamicRelativePathPatterns: [
                    historicalWorker
                        .chunkRelativePathPattern(
                            for: .probe
                        ),
                    historicalWorker
                        .chunkRelativePathPattern(
                            for: .verifier
                        ),
                    "neural-gate-replay/corrected/invariant-chunks/{ordinal_8digit}.v1.bin",
                ],
                stageAParentCopyRootRelativePath:
                    "neural-gate-replay/parent/stage-a",
                stageAForbiddenRelativePaths:
                    stageAParentUnboundFileNames
                    .map {
                        "neural-gate-replay/parent/stage-a/"
                            + $0
                    },
                runningExecutableRelativePaths:
                    runningExecutableRelativePaths,
                terminalReceiptRelativePath:
                    receiptRelativePath
            ),
        ordinaryArtifactPurpose: .immutableData,
        ordinaryArtifactMode: "0444",
        ordinaryArtifactPathClassPolicy:
            "every_published_file_outside_stage_a_copy_subroot_and_three_exact_running_executable_paths_is_immutable_data_v1",
        stageAParentPathClassOverridesOrdinary:
            true,
        runningExecutablePathClassOverridesOrdinary:
            true,
        runningExecutablePurpose: .executable,
        runningExecutableMode: "0555",
        executableBindingManifestPurpose:
            .immutableData,
        executableBindingManifestMode: "0444",
        terminalReceiptPurpose: .immutableData,
        terminalReceiptMode: "0444",
        receiptRelativePath:
            receiptRelativePath
        )
    }()

    public func validate() throws {
        try pathClassification.validate()
        guard self == .frozenV3,
              copiedSourceBlobRelativePaths.count
                == 11,
              Set(copiedSourceBlobRelativePaths)
                .count
                == copiedSourceBlobRelativePaths
                .count,
              stageAParentReachableDescriptorBindingCount
                == stageAParentReachableImmutableDataBindingCount
                    + stageAParentReachableExecutableBindingCount,
              stageAParentReachableDescriptorBindingCount
                == 35,
              stageAParentReachableImmutableDataBindingCount
                == 28,
              stageAParentReachableExecutableBindingCount
                == 7,
              stageAParentTerminalReceiptCount == 1,
              stageAParentTotalCopiedArtifactCount
                == stageAParentReachableDescriptorBindingCount
                    + stageAParentTerminalReceiptCount,
              stageAParentTotalCopiedArtifactCount
                == 36,
              stageAParentTotalCopiedImmutableDataCount
                == stageAParentReachableImmutableDataBindingCount
                    + stageAParentTerminalReceiptCount,
              stageAParentTotalCopiedImmutableDataCount
                == 29,
              stageAParentTotalCopiedExecutableCount
                == stageAParentReachableExecutableBindingCount,
              stageAParentTotalCopiedExecutableCount
                == 7,
              Set(stageAParentUnboundFileNames)
                .count
                == stageAParentUnboundFileNames.count,
              stageAParentExactBindingEqualityRequired,
              stageAParentAllowedPurposes
                == [
                    .immutableData,
                    .executable,
                ],
              allPublishedFilesDescriptorRooted,
              allPublishedFileSHA256BindingsRequired,
              exclusiveNoReplacePublicationRequired,
              outputPathNamespaceClassificationRequired,
              exactPreReceiptRealizedPathAndMetadataInventoryRequired,
              pathClassification
                .stageAParentCopyRootRelativePath
                == stageAParentCopyRootRelativePath,
              pathClassification
                .runningExecutableRelativePaths
                == [
                    probeRunningExecutableRelativePath,
                    verifierRunningExecutableRelativePath,
                    historicalWorkerRunningExecutableRelativePath,
                ],
              pathClassification
                .terminalReceiptRelativePath
                == receiptRelativePath,
              ordinaryArtifactPurpose == .immutableData,
              ordinaryArtifactMode == "0444",
              stageAParentPathClassOverridesOrdinary,
              runningExecutablePathClassOverridesOrdinary,
              runningExecutablePurpose == .executable,
              runningExecutableMode == "0555",
              executableBindingManifestPurpose
                == .immutableData,
              executableBindingManifestMode == "0444",
              terminalReceiptPurpose == .immutableData,
              terminalReceiptMode == "0444",
              pathClassification
                .ordinaryArtifactPurpose
                == ordinaryArtifactPurpose,
              pathClassification
                .ordinaryArtifactMode
                == ordinaryArtifactMode,
              pathClassification
                .runningExecutablePurpose
                == runningExecutablePurpose,
              pathClassification
                .runningExecutableMode
                == runningExecutableMode,
              pathClassification
                .terminalReceiptPurpose
                == terminalReceiptPurpose,
              pathClassification
                .terminalReceiptMode
                == terminalReceiptMode,
              (
                  copiedSourceBlobRelativePaths
                      + [
                          historicalProbeGlobalStreamRelativePath,
                          historicalVerifierGlobalStreamRelativePath,
                          correctedGlobalStreamRelativePath,
                          historicalProbeChunkRelativePathPattern,
                          historicalVerifierChunkRelativePathPattern,
                          correctedChunkRelativePathPattern,
                          stageAParentCopyRootRelativePath,
                          stageAParentCopyManifestRelativePath,
                          adaptationProofManifestRelativePath,
                          primeSourceSnapshotRelativePath,
                          probeRunningExecutableRelativePath,
                          probeExecutableBindingRelativePath,
                          verifierRunningExecutableRelativePath,
                          verifierExecutableBindingRelativePath,
                          historicalWorkerRunningExecutableRelativePath,
                          historicalWorkerExecutableBindingRelativePath,
                          receiptRelativePath,
                      ]
              ).allSatisfy(Self.isSafeRelativePath)
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("output_contract")
        }
    }

    public func validatePreReceiptRealizedPathAndMetadataInventory(
        _ inventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory,
        authenticatedStageACopiedArtifacts:
            [PrimeArtifactBinding],
        historicalProbeChunks:
            [PrimeArtifactBinding],
        historicalVerifierChunks:
            [PrimeArtifactBinding],
        correctedChunks:
            [PrimeArtifactBinding]
    ) throws {
        try validate()
        let entries = inventory.fileEntries
        try entries.forEach {
            try $0.artifact.validateDeclaration()
        }
        try authenticatedStageACopiedArtifacts
            .forEach {
                try $0.validateDeclaration()
            }
        let chunkGroups = [
            (
                historicalProbeChunkRelativePathPattern,
                historicalProbeChunks
            ),
            (
                historicalVerifierChunkRelativePathPattern,
                historicalVerifierChunks
            ),
            (
                correctedChunkRelativePathPattern,
                correctedChunks
            ),
        ]
        try chunkGroups.forEach {
            pattern, bindings in
            guard !bindings.isEmpty else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "realized_output_empty_chunk_group"
                    )
            }
            try bindings.enumerated().forEach {
                ordinal, binding in
                try binding.validateDeclaration()
                guard binding.relativePath
                        == Self.chunkRelativePath(
                            pattern: pattern,
                            ordinal: ordinal
                        ),
                      binding.purpose
                        == .immutableData
                else {
                    throw PrimeNativeNeuralGateFixtureReplayPlanError
                        .invalidPlan(
                            "realized_output_chunk_sequence"
                        )
                }
            }
        }
        let stageAPaths =
            authenticatedStageACopiedArtifacts
            .map(\.relativePath)
        let stageAPurposeCounts = Dictionary(
            grouping:
                authenticatedStageACopiedArtifacts,
            by: \.purpose
        ).mapValues(\.count)
        guard authenticatedStageACopiedArtifacts
                .count
                == stageAParentTotalCopiedArtifactCount,
              Set(stageAPaths).count
                == stageAPaths.count,
              stageAPaths.allSatisfy({
                  $0.hasPrefix(
                      stageAParentCopyRootRelativePath
                          + "/"
                  )
                      && !pathClassification
                      .stageAForbiddenRelativePaths
                      .contains($0)
              }),
              stageAPurposeCounts[
                  .immutableData
              ] == stageAParentTotalCopiedImmutableDataCount,
              stageAPurposeCounts[
                  .executable
              ] == stageAParentTotalCopiedExecutableCount
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "realized_output_stage_a_inventory"
                )
        }
        let fixedPreReceiptPaths =
            pathClassification
            .ordinaryFixedRelativePaths
            + pathClassification
            .runningExecutableRelativePaths
        let chunkBindings =
            historicalProbeChunks
            + historicalVerifierChunks
            + correctedChunks
        let expectedArtifacts =
            authenticatedStageACopiedArtifacts
            + chunkBindings
        let expectedPaths =
            Set(
                fixedPreReceiptPaths
                    + expectedArtifacts
                    .map(\.relativePath)
            )
        let observedPaths =
            entries.map {
                $0.artifact.relativePath
            }
        var expectedBoundArtifacts =
            [String: PrimeArtifactBinding]()
        for artifact in expectedArtifacts {
            guard expectedBoundArtifacts[
                artifact.relativePath
            ] == nil else {
                throw PrimeNativeNeuralGateFixtureReplayPlanError
                    .invalidPlan(
                        "realized_output_duplicate_expected_artifact"
                    )
            }
            expectedBoundArtifacts[
                artifact.relativePath
            ] = artifact
        }
        guard inventory.rootRelativePath == nil,
              !observedPaths.contains(
                  receiptRelativePath
              ),
              observedPaths
                == observedPaths.sorted(
                    by:
                        PrimeNativeNeuralGateSourceFileIdentity
                        .rawUTF8Less
                ),
              Set(observedPaths).count
                == observedPaths.count,
              Set(observedPaths) == expectedPaths,
              entries.allSatisfy({ entry in
                  let path =
                      entry.artifact.relativePath
                  guard let pathClass =
                          pathClassification
                          .classification(for: path)
                  else {
                      return false
                  }
                  guard entry.fileType
                            == "regular_file",
                        entry.linkCount == 1,
                        entry.ownerMatchesCurrentEffectiveUser,
                        entry.capturedFromDescriptor
                  else {
                      return false
                  }
                  if let expected =
                        expectedBoundArtifacts[path],
                     expected != entry.artifact
                  {
                      return false
                  }
                  switch pathClass {
                  case .ordinaryImmutableData:
                      return entry.artifact.purpose
                              == .immutableData
                          && entry.posixMode == "0444"
                  case .stageAParentCopiedArtifact:
                      switch entry.artifact.purpose {
                      case .immutableData:
                          return entry.posixMode
                              == "0444"
                      case .executable:
                          return entry.posixMode
                              == "0555"
                      }
                  case .runningExecutable:
                      return entry.artifact.purpose
                              == .executable
                          && entry.posixMode == "0555"
                  case .terminalReceipt:
                      return false
                  }
              })
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "realized_output_pre_receipt_path_and_metadata_inventory"
                )
        }
        try inventory
            .validateExactNodeClosure(
                expectedFileEntries: entries
            )
    }

    private static func chunkRelativePath(
        pattern: String,
        ordinal: Int
    ) -> String {
        pattern.replacingOccurrences(
            of: "{ordinal_8digit}",
            with: String(
                format: "%08d",
                ordinal
            )
        )
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        !path.hasPrefix("/")
            && !path.contains("\0")
            && path.split(
                separator: "/",
                omittingEmptySubsequences: false
            ).allSatisfy {
                !$0.isEmpty
                    && $0 != "."
                    && $0 != ".."
                    && $0 != ".git"
            }
    }

    private enum CodingKeys: String, CodingKey {
        case copiedSourceBlobRelativePaths =
            "copied_source_blob_relative_paths"
        case historicalProbeGlobalStreamRelativePath =
            "historical_probe_global_stream_relative_path"
        case historicalVerifierGlobalStreamRelativePath =
            "historical_verifier_global_stream_relative_path"
        case correctedGlobalStreamRelativePath =
            "corrected_global_stream_relative_path"
        case historicalProbeChunkRelativePathPattern =
            "historical_probe_chunk_relative_path_pattern"
        case historicalVerifierChunkRelativePathPattern =
            "historical_verifier_chunk_relative_path_pattern"
        case correctedChunkRelativePathPattern =
            "corrected_chunk_relative_path_pattern"
        case chunkOrdinalFormatting =
            "chunk_ordinal_formatting"
        case stageAParentCopyRootRelativePath =
            "stage_a_parent_copy_root_relative_path"
        case stageAParentCopyManifestRelativePath =
            "stage_a_parent_copy_manifest_relative_path"
        case stageAParentCopyPolicy =
            "stage_a_parent_copy_policy"
        case stageAParentReachableDescriptorBindingCount =
            "stage_a_parent_reachable_descriptor_binding_count"
        case stageAParentReachableImmutableDataBindingCount =
            "stage_a_parent_reachable_immutable_data_binding_count"
        case stageAParentReachableExecutableBindingCount =
            "stage_a_parent_reachable_executable_binding_count"
        case stageAParentTerminalReceiptCount =
            "stage_a_parent_terminal_receipt_count"
        case stageAParentTotalCopiedArtifactCount =
            "stage_a_parent_total_copied_artifact_count"
        case stageAParentTotalCopiedImmutableDataCount =
            "stage_a_parent_total_copied_immutable_data_count"
        case stageAParentTotalCopiedExecutableCount =
            "stage_a_parent_total_copied_executable_count"
        case stageAParentUnboundFileNames =
            "stage_a_parent_unbound_file_names"
        case stageAParentExactBindingEqualityRequired =
            "stage_a_parent_exact_binding_equality_required"
        case stageAParentAllowedPurposes =
            "stage_a_parent_allowed_purposes"
        case adaptationProofManifestRelativePath =
            "adaptation_proof_manifest_relative_path"
        case primeSourceSnapshotRelativePath =
            "prime_source_snapshot_relative_path"
        case primeSourceClosurePolicy =
            "prime_source_closure_policy"
        case primeSourceStatePolicy =
            "prime_source_state_policy"
        case probeRunningExecutableRelativePath =
            "probe_running_executable_relative_path"
        case probeExecutableBindingRelativePath =
            "probe_executable_binding_relative_path"
        case verifierRunningExecutableRelativePath =
            "verifier_running_executable_relative_path"
        case verifierExecutableBindingRelativePath =
            "verifier_executable_binding_relative_path"
        case historicalWorkerRunningExecutableRelativePath =
            "historical_worker_running_executable_relative_path"
        case historicalWorkerExecutableBindingRelativePath =
            "historical_worker_executable_binding_relative_path"
        case runningExecutableCapturePolicy =
            "running_executable_capture_policy"
        case processIdentityPolicy =
            "process_identity_policy"
        case allPublishedFilesDescriptorRooted =
            "all_published_files_descriptor_rooted"
        case allPublishedFileSHA256BindingsRequired =
            "all_published_file_sha256_bindings_required"
        case exclusiveNoReplacePublicationRequired =
            "exclusive_no_replace_publication_required"
        case outputPathNamespaceClassificationRequired =
            "output_path_namespace_classification_required"
        case exactPreReceiptRealizedPathAndMetadataInventoryRequired =
            "exact_pre_receipt_realized_path_and_metadata_inventory_required"
        case pathClassification =
            "path_classification"
        case ordinaryArtifactPurpose =
            "ordinary_artifact_purpose"
        case ordinaryArtifactMode =
            "ordinary_artifact_mode"
        case ordinaryArtifactPathClassPolicy =
            "ordinary_artifact_path_class_policy"
        case stageAParentPathClassOverridesOrdinary =
            "stage_a_parent_path_class_overrides_ordinary"
        case runningExecutablePathClassOverridesOrdinary =
            "running_executable_path_class_overrides_ordinary"
        case runningExecutablePurpose =
            "running_executable_purpose"
        case runningExecutableMode =
            "running_executable_mode"
        case executableBindingManifestPurpose =
            "executable_binding_manifest_purpose"
        case executableBindingManifestMode =
            "executable_binding_manifest_mode"
        case terminalReceiptPurpose =
            "terminal_receipt_purpose"
        case terminalReceiptMode =
            "terminal_receipt_mode"
        case receiptRelativePath =
            "receipt_relative_path"
    }
}

public struct PrimeNativeNeuralGateRealizedOutputEntry:
    Codable,
    Equatable,
    Sendable
{
    public let artifact: PrimeArtifactBinding
    public let posixMode: String
    public let fileType: String
    public let linkCount: UInt64
    public let ownerMatchesCurrentEffectiveUser:
        Bool
    public let capturedFromDescriptor: Bool

    public init(
        artifact: PrimeArtifactBinding,
        posixMode: String,
        fileType: String,
        linkCount: UInt64,
        ownerMatchesCurrentEffectiveUser:
            Bool,
        capturedFromDescriptor: Bool
    ) {
        self.artifact = artifact
        self.posixMode = posixMode
        self.fileType = fileType
        self.linkCount = linkCount
        self.ownerMatchesCurrentEffectiveUser =
            ownerMatchesCurrentEffectiveUser
        self.capturedFromDescriptor =
            capturedFromDescriptor
    }

    private enum CodingKeys: String, CodingKey {
        case artifact
        case posixMode = "posix_mode"
        case fileType = "file_type"
        case linkCount = "link_count"
        case ownerMatchesCurrentEffectiveUser =
            "owner_matches_current_effective_user"
        case capturedFromDescriptor =
            "captured_from_descriptor"
    }
}

public struct PrimeNativeNeuralGateRealizedDirectoryEntry:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let posixMode: String
    public let ownerMatchesCurrentEffectiveUser:
        Bool
    public let capturedFromDescriptor: Bool

    public init(
        relativePath: String,
        posixMode: String,
        ownerMatchesCurrentEffectiveUser:
            Bool,
        capturedFromDescriptor: Bool
    ) {
        self.relativePath = relativePath
        self.posixMode = posixMode
        self.ownerMatchesCurrentEffectiveUser =
            ownerMatchesCurrentEffectiveUser
        self.capturedFromDescriptor =
            capturedFromDescriptor
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case posixMode = "posix_mode"
        case ownerMatchesCurrentEffectiveUser =
            "owner_matches_current_effective_user"
        case capturedFromDescriptor =
            "captured_from_descriptor"
    }
}

public struct PrimeNativeNeuralGateRealizedFilesystemInventory:
    Codable,
    Equatable,
    Sendable
{
    public let rootRelativePath: String?
    public let rootFileType: String
    public let rootPOSIXMode: String
    public let rootOwnerMatchesCurrentEffectiveUser:
        Bool
    public let rootCapturedFromDescriptor: Bool
    public let directoryEntries:
        [PrimeNativeNeuralGateRealizedDirectoryEntry]
    public let fileEntries:
        [PrimeNativeNeuralGateRealizedOutputEntry]
    public let unsupportedNodeRelativePaths:
        [String]
    public let enumerationIncludesAllNodeTypes:
        Bool
    public let symbolicLinksFollowed: Bool

    public init(
        rootRelativePath: String?,
        directoryEntries:
            [PrimeNativeNeuralGateRealizedDirectoryEntry],
        fileEntries:
            [PrimeNativeNeuralGateRealizedOutputEntry],
        unsupportedNodeRelativePaths:
            [String],
        enumerationIncludesAllNodeTypes:
            Bool,
        symbolicLinksFollowed: Bool
    ) {
        self.rootRelativePath = rootRelativePath
        rootFileType = "directory"
        rootPOSIXMode = "0700"
        rootOwnerMatchesCurrentEffectiveUser =
            true
        rootCapturedFromDescriptor = true
        self.directoryEntries =
            directoryEntries
        self.fileEntries = fileEntries
        self.unsupportedNodeRelativePaths =
            unsupportedNodeRelativePaths
        self.enumerationIncludesAllNodeTypes =
            enumerationIncludesAllNodeTypes
        self.symbolicLinksFollowed =
            symbolicLinksFollowed
    }

    public func validateExactNodeClosure(
        expectedFileEntries:
            [PrimeNativeNeuralGateRealizedOutputEntry]
    ) throws {
        let expectedFilePaths =
            expectedFileEntries.map {
                $0.artifact.relativePath
            }
        let expectedDirectoryPaths =
            Self.requiredDirectoryRelativePaths(
                forFileRelativePaths:
                    expectedFilePaths,
                excludingRootRelativePath:
                    rootRelativePath
            )
        let expectedDirectories =
            expectedDirectoryPaths.map {
                PrimeNativeNeuralGateRealizedDirectoryEntry(
                    relativePath: $0,
                    posixMode: "0700",
                    ownerMatchesCurrentEffectiveUser:
                        true,
                    capturedFromDescriptor: true
                )
            }
        let filesWithinRoot: Bool
        if let rootRelativePath {
            filesWithinRoot =
                expectedFilePaths.allSatisfy {
                    $0.hasPrefix(
                        rootRelativePath + "/"
                    )
                }
        } else {
            filesWithinRoot = true
        }
        guard rootFileType == "directory",
              filesWithinRoot,
              rootPOSIXMode == "0700",
              rootOwnerMatchesCurrentEffectiveUser,
              rootCapturedFromDescriptor,
              enumerationIncludesAllNodeTypes,
              !symbolicLinksFollowed,
              unsupportedNodeRelativePaths
                .isEmpty,
              directoryEntries
                == expectedDirectories,
              fileEntries == expectedFileEntries
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "realized_filesystem_node_closure"
                )
        }
    }

    public static func requiredDirectoryRelativePaths(
        forFileRelativePaths filePaths:
            [String],
        excludingRootRelativePath:
            String?
    ) -> [String] {
        var directories = Set<String>()
        for path in filePaths {
            var components =
                path.split(separator: "/")
                .map(String.init)
            guard components.count > 1 else {
                continue
            }
            components.removeLast()
            while !components.isEmpty {
                let directory =
                    components.joined(
                        separator: "/"
                    )
                if directory
                    == excludingRootRelativePath
                {
                    break
                }
                directories.insert(directory)
                components.removeLast()
            }
        }
        return directories.sorted(
            by:
                PrimeNativeNeuralGateSourceFileIdentity
                .rawUTF8Less
        )
    }

    private enum CodingKeys: String, CodingKey {
        case rootRelativePath =
            "root_relative_path"
        case rootFileType = "root_file_type"
        case rootPOSIXMode = "root_posix_mode"
        case rootOwnerMatchesCurrentEffectiveUser =
            "root_owner_matches_current_effective_user"
        case rootCapturedFromDescriptor =
            "root_captured_from_descriptor"
        case directoryEntries =
            "directory_entries"
        case fileEntries = "file_entries"
        case unsupportedNodeRelativePaths =
            "unsupported_node_relative_paths"
        case enumerationIncludesAllNodeTypes =
            "enumeration_includes_all_node_types"
        case symbolicLinksFollowed =
            "symbolic_links_followed"
    }
}

public enum PrimeNativeNeuralGateScopedOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
    case abstain = "ABSTAIN"
}

public struct PrimeNativeNeuralGateReplayOutcomeComposition:
    Codable,
    Equatable,
    Sendable
{
    public let historicalMechanicsRequired:
        PrimeNativeNeuralGateScopedOutcome
    public let historicalTargetIndependenceRequired:
        PrimeNativeNeuralGateScopedOutcome
    public let correctedMechanicsRequired:
        PrimeNativeNeuralGateScopedOutcome
    public let correctedTargetIndependenceRequired:
        PrimeNativeNeuralGateScopedOutcome
    public let terminalStageBMechanicsOnSuccess:
        PrimeNativeNeuralGateScopedOutcome
    public let modelCapabilityOutcome:
        PrimeNativeNeuralGateScopedOutcome
    public let terminalPassRequiresAllArms: Bool
    public let invalidContractBehavior: String
    public let validNonpassingObservationBehavior:
        String

    public static let frozenV1 = Self(
        historicalMechanicsRequired: .pass,
        historicalTargetIndependenceRequired:
            .abstain,
        correctedMechanicsRequired: .pass,
        correctedTargetIndependenceRequired:
            .pass,
        terminalStageBMechanicsOnSuccess: .pass,
        modelCapabilityOutcome: .abstain,
        terminalPassRequiresAllArms: true,
        invalidContractBehavior:
            "throw_and_publish_no_terminal_receipt_v1",
        validNonpassingObservationBehavior:
            "publish_terminal_abstain_only_after_complete_valid_observation_v1"
    )

    public func validate() throws {
        guard self == .frozenV1,
              historicalMechanicsRequired == .pass,
              historicalTargetIndependenceRequired
                == .abstain,
              correctedMechanicsRequired == .pass,
              correctedTargetIndependenceRequired
                == .pass,
              terminalStageBMechanicsOnSuccess
                == .pass,
              modelCapabilityOutcome == .abstain,
              terminalPassRequiresAllArms
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("outcome_composition")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case historicalMechanicsRequired =
            "historical_mechanics_required"
        case historicalTargetIndependenceRequired =
            "historical_target_independence_required"
        case correctedMechanicsRequired =
            "corrected_mechanics_required"
        case correctedTargetIndependenceRequired =
            "corrected_target_independence_required"
        case terminalStageBMechanicsOnSuccess =
            "terminal_stage_b_mechanics_on_success"
        case modelCapabilityOutcome =
            "model_capability_outcome"
        case terminalPassRequiresAllArms =
            "terminal_pass_requires_all_arms"
        case invalidContractBehavior =
            "invalid_contract_behavior"
        case validNonpassingObservationBehavior =
            "valid_nonpassing_observation_behavior"
    }
}

public enum PrimeNativeNeuralGateReplayClaim:
    String,
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    case stageAParentValidated =
        "stage_a_parent_validated"
    case elevenInputsResolved =
        "eleven_inputs_resolved"
    case companionSourceStateUnchanged =
        "companion_source_state_unchanged"
    case donorSourceCopiesBound =
        "donor_source_copies_bound"
    case adapterSourceContractsValidated =
        "adapter_source_contracts_validated"
    case stageAParentEvidenceCopiedAndRevalidated =
        "stage_a_parent_evidence_copied_and_revalidated"
    case currentPrimeSourceClosureBound =
        "current_prime_source_closure_bound"
    case currentPrimeSourceStateUnchanged =
        "current_prime_source_state_unchanged"
    case compiledTargetSourceClosureValidated =
        "compiled_target_source_closure_validated"
    case swiftPackageDescribeCapturedIndependently =
        "swift_package_describe_captured_independently"
    case releaseSourceExecutableIdentitiesJoined =
        "release_source_executable_identities_joined"
    case probeReleaseExecutableBound =
        "probe_release_executable_bound"
    case verifierReleaseExecutableBound =
        "verifier_release_executable_bound"
    case probeVerifierProcessesDistinct =
        "probe_verifier_processes_distinct"
    case probeVerifierExecutableImagesDistinct =
        "probe_verifier_executable_images_distinct"
    case completeProcessTopologyValidated =
        "complete_process_topology_validated"
    case historicalWorkersTerminatedAndReaped =
        "historical_workers_terminated_and_reaped"
    case historicalWorkerArtifactsDecodedAndRecomputed =
        "historical_worker_artifacts_decoded_and_recomputed"
    case outputRootPolicyValidated =
        "output_root_policy_validated"
    case exactPreReceiptRealizedPathAndMetadataInventoryValidated =
        "exact_pre_receipt_realized_path_and_metadata_inventory_validated"
    case allPreReceiptArtifactContentValidatedByTypedContracts =
        "all_pre_receipt_artifact_content_validated_by_typed_contracts"
    case historicalForensicReplayExecuted =
        "historical_forensic_replay_executed"
    case historicalInvariantRecordsMaterialized =
        "historical_invariant_records_materialized"
    case historicalDirectAcceleratedFingerprintEqual =
        "historical_direct_accelerated_fingerprint_equal"
    case historicalTenCriticalLegsRecomputed =
        "historical_ten_critical_legs_recomputed"
    case historicalProjectedStatisticsAndMarginRecomputed =
        "historical_projected_statistics_and_margin_recomputed"
    case historicalCountDerivedVerdictRecomputed =
        "historical_count_derived_verdict_recomputed"
    case historicalFortySixMutationsDetectedDivergentAndExactlyRestored =
        "historical_forty_six_mutations_detected_divergent_and_exactly_restored"
    case historicalFreshProcessReplayExact =
        "historical_fresh_process_replay_exact"
    case correctedFixedCapEOSReplayExecuted =
        "corrected_fixed_cap_eos_replay_executed"
    case correctedInvariantRecordsMaterialized =
        "corrected_invariant_records_materialized"
    case correctedDirectAcceleratedFingerprintEqual =
        "corrected_direct_accelerated_fingerprint_equal"
    case correctedTenCriticalLegsRecomputed =
        "corrected_ten_critical_legs_recomputed"
    case correctedProjectedStatisticsAndMarginRecomputed =
        "corrected_projected_statistics_and_margin_recomputed"
    case correctedCountDerivedVerdictRecomputed =
        "corrected_count_derived_verdict_recomputed"
    case correctedLeakageMutationsDetectedDivergentAndExactlyRestored =
        "corrected_leakage_mutations_detected_divergent_and_exactly_restored"
    case correctedTargetIndependenceEstablished =
        "corrected_target_independence_established"
    case correctedFreshProcessReplayExact =
        "corrected_fresh_process_replay_exact"
    case freshProcessReplayExact =
        "fresh_process_replay_exact"
    case receiptPublishedExclusivelyLast =
        "receipt_published_exclusively_last"
    case historicalFixtureTargetIndependent =
        "historical_fixture_target_independent"
    case historicalResidueParityEstablished =
        "historical_residue_parity_established"
    case historicalPerMutationParityEstablished =
        "historical_per_mutation_parity_established"
    case historicalForensicMaterializerWhollyFailClosed =
        "historical_forensic_materializer_wholly_fail_closed"
    case neuralKitModuleExecuted =
        "neural_kit_module_executed"
    case companionRuntimeDependencyAdded =
        "companion_runtime_dependency_added"
    case modelExecutionPerformed =
        "model_execution_performed"
    case metalExecutionPerformed =
        "metal_execution_performed"
    case physicalCheckpointObserved =
        "physical_checkpoint_observed"
    case physicalGenerationShardsObserved =
        "physical_generation_shards_observed"
    case independentScientificOracleClaimed =
        "independent_scientific_oracle_claimed"
    case agentContractKitFourTierAuditPerformed =
        "agent_contract_kit_four_tier_audit_performed"
    case distinctImplementationFamiliesEstablished =
        "distinct_implementation_families_established"
    case reproducibleBuildProvenanceEstablished =
        "reproducible_build_provenance_established"
    case guardedStatisticalEntanglementPerformed =
        "guarded_statistical_entanglement_performed"
    case confidenceIntervalsPerformed =
        "confidence_intervals_performed"
    case perFamilyRankMarginAnalysisPerformed =
        "per_family_rank_margin_analysis_performed"
    case perFamilyDecisionMarginAnalysisPerformed =
        "per_family_decision_margin_analysis_performed"
    case functionalTrainingPerformed =
        "functional_training_performed"
    case quantizationPerformed =
        "quantization_performed"
    case diagonalHessianEvaluated =
        "diagonal_hessian_evaluated"
    case phaseThreeCompatibilityComplete =
        "phase_three_compatibility_complete"
    case productUseAuthorized =
        "product_use_authorized"
    case pythonScientificAuthorityUsed =
        "python_scientific_authority_used"
    case shellScientificAuthorityUsed =
        "shell_scientific_authority_used"
}

public struct PrimeNativeNeuralGateFixtureReplayPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let claimScope: String
    public let status: String
    public let executionImplemented: Bool
    public let projectionReceiptAuthorized: Bool
    public let stageAParent:
        PrimeNativeNeuralGateStageAParentPin
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let inputPins:
        [PrimeNativeNeuralGateFixtureInputPin]
    public let totalPinnedInputByteCount: UInt64
    public let inputCatalogSHA256: String
    public let adaptationProof:
        PrimeNativeNeuralGateAdaptationProofContract
    public let historicalLeakFindings:
        [PrimeNativeNeuralGateHistoricalLeakFinding]
    public let arms:
        [PrimeNativeNeuralGateFixtureArmContract]
    public let historicalSummaryRecordCount: Int
    public let historicalSummaryMaySupplyExpectedRecordsOrResidues:
        Bool
    public let requiredMutationIDs: [String]
    public let requiredMutationExpectedLegs:
        [String]
    public let historicalMutationCatalogSHA256:
        String
    public let correctedExecutor:
        PrimeNativeNeuralGateCorrectedExecutorContract
    public let correctedMutationCatalog:
        [PrimeNativeNeuralGateCorrectedFixtureMutationContract]
    public let mutationOutcome:
        PrimeNativeNeuralGateMutationOutcomeContract
    public let gateObservation:
        PrimeNativeNeuralGateObservationContract
    public let invariantSerialization:
        PrimeNativeNeuralGateInvariantSerializationContract
    public let finiteField:
        PrimeNativeNeuralGateFiniteFieldContract
    public let fingerprintReplay:
        PrimeNativeNeuralGateFingerprintReplayContract
    public let targetGraph:
        [PrimeNativeNeuralGateReplayTargetContract]
    public let sourceExecutionBinding:
        PrimeNativeNeuralGateSourceExecutionBindingContract
    public let historicalWorker:
        PrimeNativeNeuralGateHistoricalWorkerContract
    public let probeArguments: [String]
    public let verifierArguments: [String]
    public let rootPolicy:
        PrimeNativeNeuralGateReplayRootPolicy
    public let outputContract:
        PrimeNativeNeuralGateReplayOutputContract
    public let fixedOutputRelativePaths: [String]
    public let outcomeComposition:
        PrimeNativeNeuralGateReplayOutcomeComposition
    public let requiredTrueClaims:
        [PrimeNativeNeuralGateReplayClaim]
    public let requiredFalseClaims:
        [PrimeNativeNeuralGateReplayClaim]
    public let failurePrecedence: [String]
    public let stageAParentModePins:
        [PrimeNativeNeuralGateParentModePin]
    public let modeNormalizationPolicy: String
    public let immediateImplementationPrerequisite:
        String
    public let postPassNextPrerequisite: String
    public let authorityStatement: String

    public static let frozenV3: Self = {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        func inputPin(
            _ ordinal: Int,
            _ role:
                PrimeNativeNeuralGateFixtureInputRole,
            _ repositoryRelativePath: String,
            _ gitBlobOID: String,
            _ byteCount: UInt64,
            _ sha256: String,
            _ transplantPolicy:
                PrimeNativeNeuralGateFixtureTransplantPolicy
        ) -> PrimeNativeNeuralGateFixtureInputPin {
            PrimeNativeNeuralGateFixtureInputPin(
                ordinal: ordinal,
                role: role,
                repositoryRelativePath:
                    repositoryRelativePath,
                mode: "100644",
                objectType: "blob",
                gitBlobOID: gitBlobOID,
                byteCount: byteCount,
                sha256: sha256,
                transplantPolicy: transplantPolicy,
                dynamicallyCompiledOrExecuted: false
            )
        }
        let fixturePath =
            "neural-kit/Tests/NeuralKitTests/" +
            "EngineProposesNativeLanguageVerifyAbstainTests.swift"
        let historicalWorker =
            PrimeNativeNeuralGateHistoricalWorkerContract
            .frozenV2
        return Self(
            schemaVersion: 3,
            planID:
                "ergentics_prime_native_neural_gate_dual_fixture_replay_v3",
            claimScope:
                "source_pinned_synthetic_fixture_materialization_and_gate_replay_contract_with_implemented_secure_capture_substrate",
            status:
                "secure_capture_substrate_implemented_stage_b_replay_not_implemented",
            executionImplemented: false,
            projectionReceiptAuthorized: false,
            stageAParent: .frozenV1,
            companionRemoteURL:
                "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
            companionRevision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            companionTreeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            inputPins: [
                inputPin(
                    1,
                    .nativeLanguageGate,
                    "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                    "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
                    368_918,
                    "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
                    .generatedGateObservationSeam
                ),
                inputPin(
                    2,
                    .nativeByteTokenizerAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift",
                    "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1",
                    21_320,
                    "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721",
                    .reuseByteExactCorpusReplayMechanics
                ),
                inputPin(
                    3,
                    .nativeTextCorpusAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
                    "b2a087c9410a71f2bc99debade752ff779d7a8a8",
                    177_032,
                    "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210",
                    .reuseByteExactCorpusReplayMechanics
                ),
                inputPin(
                    4,
                    .canaryReportAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                    "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                    216_815,
                    "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f",
                    .generatedModuleBoundaryOnly
                ),
                inputPin(
                    5,
                    .runConfigurationAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageRunConfiguration.swift",
                    "d9141e1c08263f10f06b68acada836dc59a45dc9",
                    18_069,
                    "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b",
                    .generatedModuleBoundaryOnly
                ),
                inputPin(
                    6,
                    .artifactPathSafetyAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageArtifactPathSafety.swift",
                    "f7404c905c58e8ff2d51f90ee90dad6cb61cbedc",
                    51_514,
                    "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c",
                    .generatedModuleBoundaryOnly
                ),
                inputPin(
                    7,
                    .profileTrialFailureAuthority,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageProfileTrialFailure.swift",
                    "ed64476a8aea3010fe4e6a8b4f799eeb58e64d34",
                    16_567,
                    "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463",
                    .generatedModuleBoundaryOnly
                ),
                inputPin(
                    8,
                    .scaleRecommendationLineage,
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
                    "c3f1e242d07ad3cc7b8e961edab868a895d567df",
                    190_002,
                    "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea",
                    .generatedModuleBoundaryOnly
                ),
                inputPin(
                    9,
                    .verdictCarrier,
                    "neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift",
                    "3866cc1fd1b39829c913376abece2454b0c11624",
                    4_659,
                    "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
                    .boundedVerdictCarrierSlice
                ),
                inputPin(
                    10,
                    .behavioralRegressionFixture,
                    "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift",
                    "aa87aff21832ebd5c7a6598692139b81ae065e0b",
                    165_692,
                    "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c",
                    .sourceFaithfulPackageBoundForensicMaterializer
                ),
                PrimeNativeNeuralGateFixtureInputPin(
                    ordinal: 11,
                    role: .neuralKitPackageLock,
                    repositoryRelativePath:
                        "neural-kit/Package.resolved",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
                    byteCount: 1_949,
                    sha256:
                        "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
                    transplantPolicy:
                        .immutableArtifact,
                    dynamicallyCompiledOrExecuted: false
                ),
            ],
            totalPinnedInputByteCount: 1_232_537,
            inputCatalogSHA256:
                "e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4",
            adaptationProof: .frozenV2,
            historicalLeakFindings: [
                PrimeNativeNeuralGateHistoricalLeakFinding(
                    findingID:
                        "historical_zero_shot_length_uses_target_count",
                    sourceRelativePath: fixturePath,
                    firstLine: 3_543,
                    lastLine: 3_548,
                    observedConstruction:
                        "zero-shot text length is row target-token count",
                    semanticEffect:
                        "target length is available to synthetic output construction"
                ),
                PrimeNativeNeuralGateHistoricalLeakFinding(
                    findingID:
                        "historical_trained_prediction_copies_expected_completion",
                    sourceRelativePath: fixturePath,
                    firstLine: 3_599,
                    lastLine: 3_600,
                    observedConstruction:
                        "trained prediction and token IDs copy the expected completion",
                    semanticEffect:
                        "prediction provenance is synthetic oracle-forged, not model execution"
                ),
                PrimeNativeNeuralGateHistoricalLeakFinding(
                    findingID:
                        "historical_target_independence_declaration_conflicts_with_construction",
                    sourceRelativePath: fixturePath,
                    firstLine: 3_630,
                    lastLine: 3_630,
                    observedConstruction:
                        "targetIndependentDecisionBudget is declared true",
                    semanticEffect:
                        "the declaration cannot establish independence from the target-derived construction"
                ),
                PrimeNativeNeuralGateHistoricalLeakFinding(
                    findingID:
                        "historical_decision_count_uses_target_count",
                    sourceRelativePath: fixturePath,
                    firstLine: 3_631,
                    lastLine: 3_632,
                    observedConstruction:
                        "executed decisions are prediction or target token count plus EOS",
                    semanticEffect:
                        "historical fixture cannot ground target-independent executor semantics"
                ),
            ],
            arms: [
                PrimeNativeNeuralGateFixtureArmContract(
                    ordinal: 1,
                    arm: .historicalForensic,
                    classification:
                        "historical_source_pinned_synthetic_forensic_mechanics_only",
                    predictionProvenance:
                        "synthetic_oracle_forged",
                    sourcePinned: true,
                    promptOnlyGeneration: false,
                    fixedCapEOSGeneration: false,
                    targetIndependenceEligible:
                        false,
                    targetIndependenceDisposition:
                        .mandatoryAbstainKnownHistoricalLeak,
                    forensicMechanicsPassEligible:
                        true,
                    terminalStageBPassAloneEligible:
                        false,
                    terminalMechanicsContributionRequired:
                        true,
                    historicalResidueParityRequired:
                        false,
                    fingerprintNamespace:
                        "historical_forensic_v1"
                ),
                PrimeNativeNeuralGateFixtureArmContract(
                    ordinal: 2,
                    arm: .correctedFixedCapEOS,
                    classification:
                        "prime_owned_corrected_synthetic_gate_mechanics",
                    predictionProvenance:
                        "prompt_only_deterministic_synthetic_executor",
                    sourcePinned: true,
                    promptOnlyGeneration: true,
                    fixedCapEOSGeneration: true,
                    targetIndependenceEligible:
                        true,
                    targetIndependenceDisposition:
                        .requiresObservedPass,
                    forensicMechanicsPassEligible:
                        true,
                    terminalStageBPassAloneEligible:
                        false,
                    terminalMechanicsContributionRequired:
                        true,
                    historicalResidueParityRequired:
                        false,
                    fingerprintNamespace:
                        "corrected_fixed_cap_eos_v1"
                ),
            ],
            historicalSummaryRecordCount: 59_497,
            historicalSummaryMaySupplyExpectedRecordsOrResidues:
                false,
            requiredMutationIDs:
                projection.mutationCatalog.map(
                    \.mutationID
                ),
            requiredMutationExpectedLegs:
                projection.mutationCatalog.map(
                    \.expectedFailedLeg
                ),
            historicalMutationCatalogSHA256:
                "8a1f70ae9f20f60e63cc53df6841d8a160bcbee61621c6f80a4f0272a186100f",
            correctedExecutor: .frozenV1,
            correctedMutationCatalog:
                PrimeNativeNeuralGateCorrectedFixtureMutation
                .allCases.enumerated().map {
                    PrimeNativeNeuralGateCorrectedFixtureMutationContract(
                        ordinal: $0.offset + 1,
                        mutation: $0.element
                    )
                },
            mutationOutcome: .frozenV1,
            gateObservation: .frozenV1,
            invariantSerialization: .frozenV1,
            finiteField: .frozenV1,
            fingerprintReplay: .frozenV1,
            targetGraph: [
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "ErgenticsPrimeRuntime",
                    dependencies: [],
                    role:
                        "Prime-owned isolated local module containing only the seven byte-exact pinned runtime-authority transplants; no companion package or runtime dependency"
                ),
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "PrimeNativeNeuralGateReplayMechanics",
                    dependencies: [
                        "PrimeNativeCorpusReplayMechanics",
                        "ErgenticsPrimeRuntime",
                    ],
                    role:
                        "isolated Swift fixture, gate, fingerprint, statistics, and mutation mechanics"
                ),
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "PrimeNativeNeuralGateReplay",
                    dependencies: [
                        "PrimeCore",
                        "PrimeNativeNeuralGateContract",
                        "PrimeNativeNeuralGateReplayMechanics",
                    ],
                    role:
                        "durable plan, source resolution, observations, candidate, and receipt"
                ),
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "PrimeNativeNeuralGateHistoricalFixtureWorker",
                    dependencies: [
                        "PrimeCore",
                        "ErgenticsPrimeRuntime",
                        "PrimeNativeNeuralGateReplayMechanics",
                        "PrimeNativeNeuralGateReplay",
                    ],
                    role:
                        "sealed Swift worker that contains inherited fixture traps and owns complete role-scoped historical-arm evaluation and publication"
                ),
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "PrimeNativeNeuralGateReplayProbe",
                    dependencies: [
                        "PrimeCore",
                        "PrimeNativeNeuralGateReplay",
                    ],
                    role:
                        "Release probe and source-pinned materializer"
                ),
                PrimeNativeNeuralGateReplayTargetContract(
                    target:
                        "PrimeNativeNeuralGateReplayVerifier",
                    dependencies: [
                        "PrimeCore",
                        "PrimeNativeNeuralGateReplay",
                    ],
                    role:
                        "distinct Release reconstruction and exclusive terminal receipt publisher"
                ),
            ],
            sourceExecutionBinding: .frozenV3,
            historicalWorker: .frozenV2,
            probeArguments: [
                "--stage-a-root",
                "--companion-root",
                "--prime-root",
                "--artifact-root",
            ],
            verifierArguments: [
                "--prime-root",
                "--artifact-root",
            ],
            rootPolicy: .frozenV1,
            outputContract: .frozenV3,
            fixedOutputRelativePaths:
                PrimeNativeNeuralGateReplayOutputContract
                .frozenV3
                .copiedSourceBlobRelativePaths
                + [
                    "neural-gate-replay/plan.v3.json",
                    "neural-gate-replay/source/companion-source-inventory.v1.json",
                    "neural-gate-replay/source/adaptation-proof.v2.json",
                    "neural-gate-replay/source/prime-swift-source-snapshot.v1.json",
                    "neural-gate-replay/source/swift-package-describe.v1.json",
                    "neural-gate-replay/source/probe-swift-package-describe-capture.v4.json",
                    "neural-gate-replay/source/verifier-swift-package-describe-capture.v4.json",
                    "neural-gate-replay/source/compiled-target-source-closure.v1.json",
                    "neural-gate-replay/parent/stage-a-copy-manifest.v1.json",
                    "neural-gate-replay/bin/probe",
                    "neural-gate-replay/bin/probe-binding.v1.json",
                    "neural-gate-replay/bin/verifier",
                    "neural-gate-replay/bin/verifier-binding.v1.json",
                    historicalWorker
                        .executableRelativePath,
                    historicalWorker
                        .executableBindingRelativePath,
                ]
                + historicalWorker
                    .fixedOutputRelativePaths(
                        for: .probe
                    )
                + historicalWorker
                    .fixedOutputRelativePaths(
                        for: .verifier
                    )
                + [
                    "neural-gate-replay/corrected/fixture-materialization-manifest.v1.json",
                    "neural-gate-replay/corrected/invariant-records-manifest.v1.json",
                    "neural-gate-replay/corrected/invariant-records.v1.bin",
                    "neural-gate-replay/corrected/fingerprint-observation.v1.json",
                    "neural-gate-replay/corrected/mutation-observations.v1.json",
                    "neural-gate-replay/probe-observation.v1.json",
                    "neural-gate-replay/probe-candidate.v1.json",
                    "neural-gate-replay/verifier-observation.v1.json",
                    "prime-native-neural-gate-fixture-replay-receipt.v1.json",
                ],
            outcomeComposition: .frozenV1,
            requiredTrueClaims: [
                .stageAParentValidated,
                .elevenInputsResolved,
                .companionSourceStateUnchanged,
                .donorSourceCopiesBound,
                .adapterSourceContractsValidated,
                .stageAParentEvidenceCopiedAndRevalidated,
                .currentPrimeSourceClosureBound,
                .currentPrimeSourceStateUnchanged,
                .compiledTargetSourceClosureValidated,
                .swiftPackageDescribeCapturedIndependently,
                .releaseSourceExecutableIdentitiesJoined,
                .probeReleaseExecutableBound,
                .verifierReleaseExecutableBound,
                .probeVerifierProcessesDistinct,
                .probeVerifierExecutableImagesDistinct,
                .completeProcessTopologyValidated,
                .historicalWorkersTerminatedAndReaped,
                .historicalWorkerArtifactsDecodedAndRecomputed,
                .outputRootPolicyValidated,
                .exactPreReceiptRealizedPathAndMetadataInventoryValidated,
                .allPreReceiptArtifactContentValidatedByTypedContracts,
                .historicalForensicReplayExecuted,
                .historicalInvariantRecordsMaterialized,
                .historicalDirectAcceleratedFingerprintEqual,
                .historicalTenCriticalLegsRecomputed,
                .historicalProjectedStatisticsAndMarginRecomputed,
                .historicalCountDerivedVerdictRecomputed,
                .historicalFortySixMutationsDetectedDivergentAndExactlyRestored,
                .historicalFreshProcessReplayExact,
                .correctedFixedCapEOSReplayExecuted,
                .correctedInvariantRecordsMaterialized,
                .correctedDirectAcceleratedFingerprintEqual,
                .correctedTenCriticalLegsRecomputed,
                .correctedProjectedStatisticsAndMarginRecomputed,
                .correctedCountDerivedVerdictRecomputed,
                .correctedLeakageMutationsDetectedDivergentAndExactlyRestored,
                .correctedTargetIndependenceEstablished,
                .correctedFreshProcessReplayExact,
                .freshProcessReplayExact,
                .receiptPublishedExclusivelyLast,
            ],
            requiredFalseClaims: [
                .historicalFixtureTargetIndependent,
                .historicalResidueParityEstablished,
                .historicalPerMutationParityEstablished,
                .historicalForensicMaterializerWhollyFailClosed,
                .neuralKitModuleExecuted,
                .companionRuntimeDependencyAdded,
                .modelExecutionPerformed,
                .metalExecutionPerformed,
                .physicalCheckpointObserved,
                .physicalGenerationShardsObserved,
                .independentScientificOracleClaimed,
                .agentContractKitFourTierAuditPerformed,
                .distinctImplementationFamiliesEstablished,
                .reproducibleBuildProvenanceEstablished,
                .guardedStatisticalEntanglementPerformed,
                .confidenceIntervalsPerformed,
                .perFamilyRankMarginAnalysisPerformed,
                .perFamilyDecisionMarginAnalysisPerformed,
                .functionalTrainingPerformed,
                .quantizationPerformed,
                .diagonalHessianEvaluated,
                .phaseThreeCompatibilityComplete,
                .productUseAuthorized,
                .pythonScientificAuthorityUsed,
                .shellScientificAuthorityUsed,
            ],
            failurePrecedence: [
                "output_root_path_type_owner_link_mode_and_relationship_safety",
                "current_clean_prime_release_source_snapshot_and_probe_executable_binding",
                "independent_direct_swift_package_executable_describe_trusted_capture_local_apfs_bounded_admission_held_source_descriptors_kqueue_receipts_zero_event_checkpoints_initial_suspended_full_region_query_transcript_mapped_vnode_preopened_descriptor_stable_bytes_capability_calibration_direct_pid_to_session_group_authority_no_overflow_contained_exact_once_reap_or_fail_stop_and_authority_subgraph_reconciliation",
                "six_process_topology_worker_death_reap_and_exact_role_prefix_inventory",
                "closed_stage_a_parent_and_source_identity",
                "lossless_stage_a_parent_evidence_copy_and_revalidation",
                "companion_revision_tree_eleven_input_pins_and_unchanged_pre_post_state",
                "copied_donor_byte_bindings",
                "adapter_source_contract_mapping_and_recomputed_proof",
                "historical_fixture_exact_forensic_reconstruction",
                "corrected_prompt_only_fixed_cap_eos_construction",
                "per_arm_complete_raw_utf8_invariant_multiset_publication",
                "per_arm_direct_accelerated_fingerprint_exact_equality",
                "per_arm_ordered_mutation_detection_expected_leg_divergence_and_exact_restoration",
                "distinct_release_verifier_executable_source_closure_and_full_reconstruction",
                "exclusive_receipt_last_publication",
            ],
            stageAParentModePins: [
                PrimeNativeNeuralGateParentModePin(
                    relativePath:
                        "neural-gate-contract/prime-native-neural-gate-contract-projection.v1.json",
                    byteCount: 17_137,
                    sha256:
                        "890d96d67267606048d3dfebb0bc29fe118c086d111b7b39de8501a6120bac48"
                ),
                PrimeNativeNeuralGateParentModePin(
                    relativePath:
                        "neural-gate-contract/probe-candidate.v1.json",
                    byteCount: 7_258,
                    sha256:
                        "17319547d44b5ef6821c0cd69068586127b9831992b4c8d273fe50af0d6205b6"
                ),
                PrimeNativeNeuralGateParentModePin(
                    relativePath:
                        "neural-gate-contract/probe-observation.v1.json",
                    byteCount: 4_114,
                    sha256:
                        "09f72adf2e14ebd2c36572ed6d94ea35bdfda305a48d1f19dd868dcc83722a04"
                ),
                PrimeNativeNeuralGateParentModePin(
                    relativePath:
                        "neural-gate-contract/verifier-observation.v1.json",
                    byteCount: 4_114,
                    sha256:
                        "09f72adf2e14ebd2c36572ed6d94ea35bdfda305a48d1f19dd868dcc83722a04"
                ),
                PrimeNativeNeuralGateParentModePin(
                    relativePath:
                        "prime-native-neural-gate-contract-projection-receipt.v1.json",
                    byteCount: 3_193,
                    sha256:
                        "2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed"
                ),
            ],
            modeNormalizationPolicy:
                "verify_current_user_single_link_regular_file_exact_bytes_and_sha256_then_chmod_only_listed_files_to_0444_never_recursive",
            immediateImplementationPrerequisite:
                "implement_role_scoped_stage_b_historical_worker_probe_verifier_with_typed_artifact_recomputation_corrected_fixed_cap_eos_arm_and_exact_path_metadata_content_inventory_using_completed_secure_capture_factory",
            postPassNextPrerequisite:
                "physical_native_checkpoint_and_evaluation_shard_binding",
            authorityStatement:
                "This contract freezes required schemas for a Swift-first Stage-B dual replay. PrimeCore now implements the closed secure capture substrate, but Stage-B replay execution, process records, workers, and terminal receipt are not implemented or observed and executionImplemented remains false. The factory admits a bounded current-owner local-APFS Prime source tree, holds authoritative root, directory, and file descriptors, arms receipt-checked EVFILT_VNODE guards, and requires exact inventories, bytes, metadata, path joins, and zero mutation events at initial, pre-resume, and post-reap checkpoints. It directly launches the frozen Xcode 26.6 build 17F113 swift-package image with an exact four-key non-inherited scratch environment, stdin at EOF, and normalized start-suspended 0x448c flags. Scratch ACLs and unknown extended attributes are rejected; com.apple.TextEncoding is optional only on the single-link regular work/.lock file with the exact 15-byte utf-8;134217984 value read through its descriptor, while com.apple.provenance is bounded to 4096 bytes and remains opaque non-authoritative metadata. Child authority is the positive PID until getsid(pid) and getpgid(pid) both equal pid; only then may the dedicated process group receive termination signals. Successful capture binds the suspended cwd and complete mapped-region vnode transcript to held descriptors, drains bounded streams through EOF, observes death, reaps the exact PID once, proves the group empty, and permits no post-reap signal. Ordinary rejection may return only after proven containment and exact reap; a child or drain that remains uncontained after bounded WNOHANG cleanup is supervisor fail-stop and cannot be encoded as ABSTAIN. The schema-4 external evidence and schema-4 describe-capture envelope are prerequisite and canary mechanics, not a Stage-B record or receipt. The historical arm reconstructs the exact source-pinned synthetic fixture only as forensic mechanics because its output construction consumes target length and expected completion while declaring target independence. Its source-faithful materializer retains donor trap sites, is not claimed wholly fail-closed, and must run in two role-scoped bounded workers. A contained abnormal termination is internally ABSTAIN, poisons the root, accepts no worker result as evidence, publishes no successful-execution record or terminal receipt, and permits no retry; partial artifacts may remain but are non-authoritative. A successful worker result is transport evidence and cannot establish mechanics PASS; the terminal verifier must decode and recompute every semantic artifact. The corrected arm must independently construct prompt-only fixed-cap-64 generation with EOS available at every decision and may establish only corrected synthetic gate mechanics. A terminal Stage-B mechanics PASS requires both arms, complete raw-UTF8 invariant multiset publication, exact direct/accelerated fingerprints, all ten Verify/Abstain legs, projected statistics and fixed-prompt margin, count-derived verdict, every ordered mutation with exact restoration, a validated six-process topology, exact pre-receipt realized path-and-metadata inventory, and typed validation of every artifact. Historical target independence and model capability remain ABSTAIN. Donor bytes are resolved, copied, and rebound as immutable evidence while the companion is unchanged; donor blobs are never dynamically compiled or executed. Every donor-to-Prime adaptation has a plan-authoritative byte-exact or hash-bound derivation plus lexical and compiled-source proof; successful behavior and caller-supplied manifests cannot supply expectations. The closed Stage-A receipt and complete descriptor-bound parent closure must be copied losslessly and revalidated from the Stage-B root. The direct swift-package launch path, proc_pidpath pathname, and code-sign fields remain non-authoritative telemetry; no Apple trust claim is made. Namespace classification never authorizes publication; publication must pass exact path, node, type, owner, link, mode, purpose, digest, typed-content, and no-replace checks with the receipt exclusively last. No independently reproducible build, NeuralKit module execution, companion runtime dependency, model or Metal execution, physical checkpoint or shard, independent scientific oracle, four-tier AgentContractKit audit, guarded statistics, training, quantization, diagonal-Hessian evaluation, Phase-3 completion, product authority, Python authority, or shell authority is claimed."
        )
    }()

    public func validate() throws {
        try stageAParent.validate()
        try invariantSerialization.validate()
        try finiteField.validate()
        try fingerprintReplay.validate()
        try correctedExecutor.validate()
        try mutationOutcome.validate()
        try gateObservation.validate()
        try sourceExecutionBinding.validate()
        try historicalWorker.validate(
            adaptationProof: adaptationProof,
            sourceExecutionBinding:
                sourceExecutionBinding
        )
        try rootPolicy.validate()
        try outputContract.validate()
        try outcomeComposition.validate()
        try inputPins.forEach {
            try $0.validate()
        }
        try adaptationProof.validate(
            against: inputPins
        )
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        let sourcePins = Array(inputPins.prefix(10))
        let sourceMatchesProjection =
            zip(sourcePins, projection.sourceBindings)
            .allSatisfy { input, source in
                input.repositoryRelativePath
                        == source.repositoryRelativePath
                    && input.mode == source.mode
                    && input.objectType == source.objectType
                    && input.gitBlobOID
                        == source.gitBlobOID
                    && input.byteCount == source.byteCount
                    && input.sha256 == source.sha256
            }
        let requiredTrue = Set(requiredTrueClaims)
        let requiredFalse = Set(requiredFalseClaims)
        let liveInputCatalogSHA256 =
            PrimeSHA256.hexDigest(
                of:
                try PrimeCanonicalJSON.encode(
                    inputPins
                )
            )
        let liveHistoricalMutationCatalogSHA256 =
            PrimeSHA256.hexDigest(
                of:
                try PrimeCanonicalJSON.encode(
                    projection.mutationCatalog
                )
            )
        let targetGraphMatchesSourceClosure =
            targetGraph.allSatisfy { target in
                let matches =
                    sourceExecutionBinding
                    .targetClosureRules.filter {
                        $0.targetName == target.target
                    }
                return matches.count == 1
                    && matches[0]
                    .directLocalDependencyNames
                        == target.dependencies
            }
        let runningExecutablePaths = Set(
            outputContract.pathClassification
                .runningExecutableRelativePaths
        )
        let ordinaryFixedOutputPaths = Set(
            fixedOutputRelativePaths.filter {
                !runningExecutablePaths.contains($0)
                    && $0
                        != outputContract
                        .receiptRelativePath
            }
        )
        guard self == .frozenV3,
              schemaVersion == 3,
              planID
                == "ergentics_prime_native_neural_gate_dual_fixture_replay_v3",
              !executionImplemented,
              !projectionReceiptAuthorized,
              companionRemoteURL
                == "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
              companionRevision
                == "163fc100710ece48119bc25954452d10f6a84f7f",
              companionTreeOID
                == "9009daa4f8a07fbd5897e00b9571cef44ec292db",
              companionRemoteURL
                == projection.companionRemoteURL,
              companionRevision
                == projection.companionRevision,
              companionTreeOID
                == projection.companionTreeOID,
              inputPins.map(\.ordinal)
                == Array(1 ... 11),
              inputPins.map(\.role)
                == PrimeNativeNeuralGateFixtureInputRole
                .allCases,
              sourceMatchesProjection,
              inputPins.map(\.byteCount).reduce(0, +)
                == totalPinnedInputByteCount,
              totalPinnedInputByteCount == 1_232_537,
              inputCatalogSHA256
                == liveInputCatalogSHA256,
              targetGraph.map(\.target)
                == [
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateReplay",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                    "PrimeNativeNeuralGateReplayProbe",
                    "PrimeNativeNeuralGateReplayVerifier",
                ],
              targetGraphMatchesSourceClosure,
              historicalLeakFindings.count == 4,
              arms.map(\.ordinal) == [1, 2],
              arms.map(\.arm)
                == PrimeNativeNeuralGateFixtureReplayArm
                .allCases,
              arms[0].forensicMechanicsPassEligible,
              !arms[0]
                .terminalStageBPassAloneEligible,
              arms[0]
                .terminalMechanicsContributionRequired,
              !arms[0].targetIndependenceEligible,
              arms[0].targetIndependenceDisposition
                == .mandatoryAbstainKnownHistoricalLeak,
              !arms[1]
                .terminalStageBPassAloneEligible,
              arms[1]
                .terminalMechanicsContributionRequired,
              arms[1].targetIndependenceEligible,
              arms[1].targetIndependenceDisposition
                == .requiresObservedPass,
              arms.map(\.fingerprintNamespace)
                .allSatisfy({ !$0.isEmpty }),
              Set(arms.map(\.fingerprintNamespace))
                .count == arms.count,
              historicalSummaryRecordCount == 59_497,
              !historicalSummaryMaySupplyExpectedRecordsOrResidues,
              requiredMutationIDs
                == projection.mutationCatalog.map(
                    \.mutationID
                ),
              requiredMutationExpectedLegs
                == projection.mutationCatalog.map(
                    \.expectedFailedLeg
                ),
              requiredMutationIDs.count == 46,
              historicalMutationCatalogSHA256
                == liveHistoricalMutationCatalogSHA256,
              correctedMutationCatalog.map(
                  \.ordinal
              ) == Array(
                  1 ...
                      PrimeNativeNeuralGateCorrectedFixtureMutation
                      .allCases.count
              ),
              correctedMutationCatalog.map(
                  \.mutation
              )
                == PrimeNativeNeuralGateCorrectedFixtureMutation
                .allCases,
              correctedMutationCatalog
                .allSatisfy({
                    $0.arm == .correctedFixedCapEOS
                        && $0.detectorID
                            == $0.mutation.detectorID
                        && $0.expectedFailedLeg
                            == $0.mutation
                            .expectedFailedLeg
                        && $0.mutationOperation
                            == $0.mutation
                            .mutationOperation
                        && $0
                        .fingerprintDivergenceRequired
                        && $0
                        .recordExactRestorationRequired
                        && $0
                        .fingerprintExactRestorationRequired
                }),
              requiredTrue.count
                == requiredTrueClaims.count,
              requiredFalse.count
                == requiredFalseClaims.count,
              requiredTrue.isDisjoint(
                  with: requiredFalse
              ),
              requiredTrue.contains(
                  .correctedTargetIndependenceEstablished
              ),
              requiredTrue.contains(
                  .correctedInvariantRecordsMaterialized
              ),
              requiredTrue.contains(
                  .correctedDirectAcceleratedFingerprintEqual
              ),
              requiredTrue.contains(
                  .historicalTenCriticalLegsRecomputed
              ),
              requiredTrue.contains(
                  .historicalProjectedStatisticsAndMarginRecomputed
              ),
              requiredTrue.contains(
                  .historicalCountDerivedVerdictRecomputed
              ),
              requiredTrue.contains(
                  .correctedTenCriticalLegsRecomputed
              ),
              requiredTrue.contains(
                  .correctedProjectedStatisticsAndMarginRecomputed
              ),
              requiredTrue.contains(
                  .correctedCountDerivedVerdictRecomputed
              ),
              requiredTrue.contains(
                  .historicalFortySixMutationsDetectedDivergentAndExactlyRestored
              ),
              requiredTrue.contains(
                  .correctedLeakageMutationsDetectedDivergentAndExactlyRestored
              ),
              requiredTrue.contains(
                  .companionSourceStateUnchanged
              ),
              requiredTrue.contains(
                  .donorSourceCopiesBound
              ),
              requiredTrue.contains(
                  .adapterSourceContractsValidated
              ),
              requiredTrue.contains(
                  .stageAParentEvidenceCopiedAndRevalidated
              ),
              requiredTrue.contains(
                  .currentPrimeSourceClosureBound
              ),
              requiredTrue.contains(
                  .currentPrimeSourceStateUnchanged
              ),
              requiredTrue.contains(
                  .compiledTargetSourceClosureValidated
              ),
              requiredTrue.contains(
                  .swiftPackageDescribeCapturedIndependently
              ),
              requiredTrue.contains(
                  .releaseSourceExecutableIdentitiesJoined
              ),
              requiredTrue.contains(
                  .probeReleaseExecutableBound
              ),
              requiredTrue.contains(
                  .verifierReleaseExecutableBound
              ),
              requiredTrue.contains(
                  .probeVerifierProcessesDistinct
              ),
              requiredTrue.contains(
                  .probeVerifierExecutableImagesDistinct
              ),
              requiredTrue.contains(
                  .completeProcessTopologyValidated
              ),
              requiredTrue.contains(
                  .historicalWorkersTerminatedAndReaped
              ),
              requiredTrue.contains(
                  .historicalWorkerArtifactsDecodedAndRecomputed
              ),
              requiredTrue.contains(
                  .outputRootPolicyValidated
              ),
              requiredTrue.contains(
                  .exactPreReceiptRealizedPathAndMetadataInventoryValidated
              ),
              requiredTrue.contains(
                  .allPreReceiptArtifactContentValidatedByTypedContracts
              ),
              requiredFalse.contains(
                  .historicalFixtureTargetIndependent
              ),
              requiredFalse.contains(
                  .modelExecutionPerformed
              ),
              probeArguments == [
                  "--stage-a-root",
                  "--companion-root",
                  "--prime-root",
                  "--artifact-root",
              ],
              historicalWorker
                .exactCLIArgumentNames
                == [
                    "--artifact-root",
                    "--invocation-role",
                    "--request-sha256",
                ],
              verifierArguments == [
                  "--prime-root",
                  "--artifact-root",
              ],
              fixedOutputRelativePaths.contains(
                  outputContract
                    .historicalProbeGlobalStreamRelativePath
              ),
              fixedOutputRelativePaths.contains(
                  outputContract
                    .historicalVerifierGlobalStreamRelativePath
              ),
              fixedOutputRelativePaths.contains(
                  outputContract
                    .correctedGlobalStreamRelativePath
              ),
              fixedOutputRelativePaths.last
                == outputContract.receiptRelativePath,
              Set(fixedOutputRelativePaths).count
                == fixedOutputRelativePaths.count,
              ordinaryFixedOutputPaths
                == Set(
                    outputContract
                        .pathClassification
                        .ordinaryFixedRelativePaths
                ),
              fixedOutputRelativePaths.allSatisfy({
                  outputContract.pathClassification
                      .classification(for: $0)
                      != nil
              }),
              outputContract
                .copiedSourceBlobRelativePaths
                .allSatisfy({
                    outputContract
                        .pathClassification
                        .classification(for: $0)
                        == .ordinaryImmutableData
                }),
              outputContract.pathClassification
                .ordinaryDynamicRelativePathPatterns
                == [
                    outputContract
                        .historicalProbeChunkRelativePathPattern,
                    outputContract
                        .historicalVerifierChunkRelativePathPattern,
                    outputContract
                        .correctedChunkRelativePathPattern,
                ],
              outputContract.pathClassification
                .classification(
                    for:
                        "neural-gate-replay/historical/probe/invariant-chunks/00000000.v1.bin"
                ) == .ordinaryImmutableData,
              outputContract.pathClassification
                .classification(
                    for:
                        "neural-gate-replay/historical/verifier/invariant-chunks/00000000.v1.bin"
                ) == .ordinaryImmutableData,
              outputContract.pathClassification
                .classification(
                    for:
                        "neural-gate-replay/corrected/invariant-chunks/99999999.v1.bin"
                ) == .ordinaryImmutableData,
              outputContract.pathClassification
                .classification(
                    for:
                        outputContract
                        .stageAParentCopyRootRelativePath
                        + "/prime-native-neural-gate-contract-projection-receipt.v1.json"
                ) == .stageAParentCopiedArtifact,
              outputContract
                .adaptationProofManifestRelativePath
                == adaptationProof
                .proofManifestRelativePath,
              outputContract
                .primeSourceSnapshotRelativePath
                == sourceExecutionBinding
                .sourceSnapshotRelativePath,
              sourceExecutionBinding
                .processBindingRules[0]
                .runningExecutableRelativePath
                == outputContract
                .probeRunningExecutableRelativePath,
              sourceExecutionBinding
                .processBindingRules[0]
                .executableBindingRelativePath
                == outputContract
                .probeExecutableBindingRelativePath,
              sourceExecutionBinding
                .processBindingRules[1]
                .runningExecutableRelativePath
                == outputContract
                .verifierRunningExecutableRelativePath,
              sourceExecutionBinding
                .processBindingRules[1]
                .executableBindingRelativePath
                == outputContract
                .verifierExecutableBindingRelativePath,
              fixedOutputRelativePaths.contains(
                  historicalWorker
                    .executableRelativePath
              ),
              fixedOutputRelativePaths.contains(
                  historicalWorker
                    .executableBindingRelativePath
              ),
              historicalWorker
                .allowedInvocationRoles
                .allSatisfy({
                    Set(fixedOutputRelativePaths)
                        .isSuperset(
                            of: Set(
                                historicalWorker
                                    .fixedOutputRelativePaths(
                                        for: $0
                                    )
                            )
                        )
                }),
              fixedOutputRelativePaths.contains(
                  sourceExecutionBinding
                    .swiftPackageDescribeRelativePath
              ),
              Set(fixedOutputRelativePaths)
                .isSuperset(
                    of: Set(
                        sourceExecutionBinding
                            .swiftPackageDescribeCaptureRecordRelativePaths
                    )
                ),
              fixedOutputRelativePaths.contains(
                  sourceExecutionBinding
                    .compiledSourceClosureRelativePath
              ),
              stageAParentModePins.count == 5,
              stageAParentModePins.allSatisfy({
                  $0.requiredMode == "0444"
                      && $0.byteCount > 0
              }),
              authorityStatement.contains(
                  "target length and expected completion"
              ),
              authorityStatement.contains(
                  "never dynamically compiled or executed"
              ),
              authorityStatement.contains(
                  "plan-authoritative"
              ),
              authorityStatement.contains(
                  "not claimed wholly fail-closed"
              ),
              authorityStatement.contains(
                  "No independently reproducible build"
              )
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("frozen_contract")
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case planID = "plan_id"
        case claimScope = "claim_scope"
        case status
        case executionImplemented =
            "execution_implemented"
        case projectionReceiptAuthorized =
            "projection_receipt_authorized"
        case stageAParent = "stage_a_parent"
        case companionRemoteURL =
            "companion_remote_url"
        case companionRevision =
            "companion_revision"
        case companionTreeOID =
            "companion_tree_oid"
        case inputPins = "input_pins"
        case totalPinnedInputByteCount =
            "total_pinned_input_byte_count"
        case inputCatalogSHA256 =
            "input_catalog_sha256"
        case adaptationProof =
            "adaptation_proof"
        case historicalLeakFindings =
            "historical_leak_findings"
        case arms
        case historicalSummaryRecordCount =
            "historical_summary_record_count"
        case historicalSummaryMaySupplyExpectedRecordsOrResidues =
            "historical_summary_may_supply_expected_records_or_residues"
        case requiredMutationIDs =
            "required_mutation_ids"
        case requiredMutationExpectedLegs =
            "required_mutation_expected_legs"
        case historicalMutationCatalogSHA256 =
            "historical_mutation_catalog_sha256"
        case correctedExecutor =
            "corrected_executor"
        case correctedMutationCatalog =
            "corrected_mutation_catalog"
        case mutationOutcome =
            "mutation_outcome"
        case gateObservation =
            "gate_observation"
        case invariantSerialization =
            "invariant_serialization"
        case finiteField = "finite_field"
        case fingerprintReplay =
            "fingerprint_replay"
        case targetGraph = "target_graph"
        case sourceExecutionBinding =
            "source_execution_binding"
        case historicalWorker =
            "historical_worker"
        case probeArguments = "probe_arguments"
        case verifierArguments =
            "verifier_arguments"
        case rootPolicy = "root_policy"
        case outputContract =
            "output_contract"
        case fixedOutputRelativePaths =
            "fixed_output_relative_paths"
        case outcomeComposition =
            "outcome_composition"
        case requiredTrueClaims =
            "required_true_claims"
        case requiredFalseClaims =
            "required_false_claims"
        case failurePrecedence =
            "failure_precedence"
        case stageAParentModePins =
            "stage_a_parent_mode_pins"
        case modeNormalizationPolicy =
            "mode_normalization_policy"
        case immediateImplementationPrerequisite =
            "immediate_implementation_prerequisite"
        case postPassNextPrerequisite =
            "post_pass_next_prerequisite"
        case authorityStatement =
            "authority_statement"
    }
}

import Foundation
import PrimeNativeNeuralGateReplayMechanics

enum PrimeNativeNeuralGateHistoricalSourceDerivationKind:
    String,
    Equatable,
    Sendable
{
    case byteExactDonor = "byte_exact_donor"
    case frozenLineGroupsAndRewrites =
        "frozen_line_groups_and_rewrites"
}

enum PrimeNativeNeuralGateHistoricalLineGroupLFPolicy:
    String,
    Equatable,
    Sendable
{
    case preserveTerminalLF = "preserve_terminal_lf"
    case stripOneTerminalLF = "strip_one_terminal_lf"
}

struct PrimeNativeNeuralGateHistoricalSourceLineGroup:
    Equatable,
    Sendable
{
    let ordinal: Int
    let firstLine: Int
    let lastLine: Int
    let terminalLFPolicy:
        PrimeNativeNeuralGateHistoricalLineGroupLFPolicy
    let expectedByteCount: UInt64
    let expectedSHA256: String
}

struct PrimeNativeNeuralGateHistoricalSourceRewrite:
    Equatable,
    Sendable
{
    let ordinal: Int
    let rewriteID: String
    let expectedOccurrenceCount: Int
    let sourceUTF8: String
    let sourceByteCount: UInt64
    let sourceSHA256: String
    let replacementUTF8: String
    let replacementByteCount: UInt64
    let replacementSHA256: String

    init(
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
        self.replacementByteCount = replacementByteCount
        self.replacementSHA256 = replacementSHA256
    }
}

struct PrimeNativeNeuralGateHistoricalSourceDerivationContract:
    Equatable,
    Sendable
{
    let derivationID: String
    let kind:
        PrimeNativeNeuralGateHistoricalSourceDerivationKind
    let requiredInputOrdinals: [Int]
    let sourceEncodingPolicy: String
    let lineGroups:
        [PrimeNativeNeuralGateHistoricalSourceLineGroup]
    let betweenGroupUTF8Hex: [String]
    let joinedGroupByteCount: UInt64?
    let joinedGroupSHA256: String?
    let prefixUTF8: String
    let prefixByteCount: UInt64
    let prefixSHA256: String
    let suffixUTF8: String
    let suffixByteCount: UInt64
    let suffixSHA256: String
    let rewrites:
        [PrimeNativeNeuralGateHistoricalSourceRewrite]
    let transformedBodyByteCount: UInt64?
    let transformedBodySHA256: String?
    let expectedOutputByteCount: UInt64
    let expectedOutputSHA256: String
    let runtimeManifestMaySupplyExpectedValues: Bool

    init(
        derivationID: String,
        kind:
            PrimeNativeNeuralGateHistoricalSourceDerivationKind,
        requiredInputOrdinals: [Int],
        lineGroups:
            [PrimeNativeNeuralGateHistoricalSourceLineGroup] = [],
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
            [PrimeNativeNeuralGateHistoricalSourceRewrite] = [],
        transformedBodyByteCount: UInt64? = nil,
        transformedBodySHA256: String? = nil,
        expectedOutputByteCount: UInt64,
        expectedOutputSHA256: String
    ) {
        self.derivationID = derivationID
        self.kind = kind
        self.requiredInputOrdinals = requiredInputOrdinals
        sourceEncodingPolicy =
            "utf8_no_bom_lf_only_final_lf_required_v1"
        self.lineGroups = lineGroups
        self.betweenGroupUTF8Hex = betweenGroupUTF8Hex
        self.joinedGroupByteCount = joinedGroupByteCount
        self.joinedGroupSHA256 = joinedGroupSHA256
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
        self.expectedOutputByteCount = expectedOutputByteCount
        self.expectedOutputSHA256 = expectedOutputSHA256
        runtimeManifestMaySupplyExpectedValues = false
    }

    static func byteExact(
        inputOrdinal: Int,
        byteCount: UInt64,
        sha256: String
    ) -> Self {
        Self(
            derivationID: "byte_exact_donor_sha256_v1",
            kind: .byteExactDonor,
            requiredInputOrdinals: [inputOrdinal],
            expectedOutputByteCount: byteCount,
            expectedOutputSHA256: sha256
        )
    }

    func validate(
        donorByteCount: UInt64,
        donorSHA256: String
    ) -> Bool {
        let emptySHA256 =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let prefix = Data(prefixUTF8.utf8)
        let suffix = Data(suffixUTF8.utf8)
        let groupsValid =
            lineGroups.enumerated().allSatisfy {
                index, group in
                group.ordinal == index + 1
                    && group.firstLine > 0
                    && group.lastLine >= group.firstLine
                    && group.expectedByteCount > 0
                    && Self.isSHA256(group.expectedSHA256)
            }
        let groupsStrictlyOrdered =
            zip(lineGroups, lineGroups.dropFirst())
            .allSatisfy {
                $0.lastLine < $1.firstLine
            }
        let rewriteIDs = rewrites.map(\.rewriteID)
        let rewritesValid =
            Set(rewriteIDs).count == rewriteIDs.count
            && rewrites.enumerated().allSatisfy {
                index, rewrite in
                let source = Data(rewrite.sourceUTF8.utf8)
                let replacement =
                    Data(rewrite.replacementUTF8.utf8)
                return rewrite.ordinal == index + 1
                    && !rewrite.rewriteID.isEmpty
                    && rewrite.expectedOccurrenceCount == 1
                    && !source.isEmpty
                    && UInt64(source.count)
                        == rewrite.sourceByteCount
                    && Self.sha256(source)
                        == rewrite.sourceSHA256
                    && UInt64(replacement.count)
                        == rewrite.replacementByteCount
                    && Self.sha256(replacement)
                        == rewrite.replacementSHA256
            }
        let separatorsValid =
            betweenGroupUTF8Hex.allSatisfy(
                Self.isCanonicalUTF8SeparatorHex
            )
        var joinedCount: UInt64? = 0
        for group in lineGroups {
            joinedCount = Self.adding(
                joinedCount,
                group.expectedByteCount
            )
        }
        for separator in betweenGroupUTF8Hex {
            joinedCount = Self.adding(
                joinedCount,
                UInt64(separator.utf8.count / 2)
            )
        }
        var transformedCount = joinedCount
        for rewrite in rewrites {
            guard let partial = transformedCount else {
                break
            }
            let subtraction = partial
                .subtractingReportingOverflow(
                    rewrite.sourceByteCount
                )
            guard !subtraction.overflow else {
                transformedCount = nil
                break
            }
            transformedCount = Self.adding(
                subtraction.partialValue,
                rewrite.replacementByteCount
            )
        }
        let outputCount = Self.adding(
            Self.adding(
                transformedCount,
                prefixByteCount
            ),
            suffixByteCount
        )
        let commonValid =
            !derivationID.isEmpty
                && sourceEncodingPolicy
                    == "utf8_no_bom_lf_only_final_lf_required_v1"
                && !requiredInputOrdinals.isEmpty
                && Set(requiredInputOrdinals).count
                    == requiredInputOrdinals.count
                && requiredInputOrdinals.allSatisfy { $0 > 0 }
                && UInt64(prefix.count) == prefixByteCount
                && Self.sha256(prefix) == prefixSHA256
                && UInt64(suffix.count) == suffixByteCount
                && Self.sha256(suffix) == suffixSHA256
                && Self.isSHA256(expectedOutputSHA256)
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
                    && transformedBodyByteCount == nil
                    && transformedBodySHA256 == nil
                    && expectedOutputByteCount
                        == donorByteCount
                    && expectedOutputSHA256 == donorSHA256
        case .frozenLineGroupsAndRewrites:
            kindValid =
                !lineGroups.isEmpty
                    && betweenGroupUTF8Hex.count
                        == lineGroups.count - 1
                    && joinedGroupByteCount == joinedCount
                    && joinedGroupSHA256
                        .map(Self.isSHA256) == true
                    && transformedBodyByteCount
                        == transformedCount
                    && transformedBodySHA256
                        .map(Self.isSHA256) == true
                    && expectedOutputByteCount == outputCount
        }
        return commonValid && kindValid
    }

    private static func adding(
        _ lhs: UInt64?,
        _ rhs: UInt64
    ) -> UInt64? {
        guard let lhs else {
            return nil
        }
        let result = lhs.addingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private static func isCanonicalUTF8SeparatorHex(
        _ value: String
    ) -> Bool {
        let encoded = Array(value.utf8)
        guard encoded.count.isMultiple(of: 2) else {
            return false
        }
        var decoded: [UInt8] = []
        decoded.reserveCapacity(encoded.count / 2)
        var index = 0
        while index < encoded.count {
            guard let high = lowercaseHexNibble(
                encoded[index]
            ),
                  let low = lowercaseHexNibble(
                    encoded[index + 1]
                  )
            else {
                return false
            }
            decoded.append(high << 4 | low)
            index += 2
        }
        let data = Data(decoded)
        return !data.contains(0x0d)
            && !data.starts(with: [0xef, 0xbb, 0xbf])
            && String(data: data, encoding: .utf8) != nil
    }

    private static func lowercaseHexNibble(
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

    private static func sha256(_ data: Data) -> String {
        PrimeNativeNeuralGateInvariantCodec.sha256(data)
    }
}

struct PrimeNativeNeuralGateHistoricalSourcePin:
    Equatable,
    Sendable
{
    let ordinal: Int
    let byteCount: UInt64
    let sha256: String
}

extension PrimeNativeNeuralGateHistoricalSourceDerivation {
    static let frozenContractSHA256 =
        "884588bbe5c0aad160366f611d096d88e14946f1923b88c78a5a8b3d6a546da8"

    static let frozenNativeLanguageGatePin =
        PrimeNativeNeuralGateHistoricalSourcePin(
            ordinal: 1,
            byteCount: 368_918,
            sha256:
                "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        )

    static let frozenVerdictCarrierPin =
        PrimeNativeNeuralGateHistoricalSourcePin(
            ordinal: 9,
            byteCount: 4_659,
            sha256:
                "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c"
        )

    static let frozenHistoricalFixtureSourcePin =
        PrimeNativeNeuralGateHistoricalSourcePin(
            ordinal: 10,
            byteCount: 165_692,
            sha256:
                "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c"
        )

    static let frozenHistoricalPackageResolvedPin =
        PrimeNativeNeuralGateHistoricalSourcePin(
            ordinal: 11,
            byteCount: 1_949,
            sha256:
                "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )

    static let frozenHistoricalEvidenceExportSuffixPin =
        PrimeNativeNeuralGateHistoricalSourcePin(
            ordinal: 12,
            byteCount: 43_273,
            sha256:
                "5eb1481f71b6071b56306e5bc20bd6ed2805cf7cad8441b5e9deb5929f026b67"
        )

    static let frozenHistoricalEvidenceExportSourceContractID =
        "prime_source_bound_historical_evidence_export_source_v13"

    static let frozenHistoricalEvidenceExportSourceContractSHA256 =
        "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"

    static let frozenHistoricalEvidenceExportDerivationID =
        "exact_whole_gate_namespace_clone_two_rewrite_append_only_evidence_export_suffix_v1"

    static let frozenHistoricalEvidenceExportFinalByteCount:
        UInt64 = 412_226

    static let frozenHistoricalEvidenceExportFinalSHA256 =
        "a20bb86529988f75a46340b9a62924ebda151744a4028ad7726a2d712a385eae"

    static let frozenHistoricalEvidenceExportNamespaceDerivation =
        PrimeNativeNeuralGateHistoricalSourceDerivationContract(
            derivationID:
                "exact_whole_gate_namespace_clone_two_rewrite_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 9_242,
                    terminalLFPolicy:
                        .preserveTerminalLF,
                    expectedByteCount: 368_918,
                    expectedSHA256:
                        "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
                ),
            ],
            joinedGroupByteCount: 368_918,
            joinedGroupSHA256:
                "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
            rewrites: [
                .init(
                    ordinal: 1,
                    rewriteID:
                        "internal_isolated_gate_namespace_declaration",
                    sourceUTF8:
                        "public enum PrimeNeuralNativeLanguageVerifyAbstainGate {",
                    sourceByteCount: 56,
                    sourceSHA256:
                        "4f9077034b6bff78ff926d17cecf12641ef3fc5859eb29fca577526f3e898b7b",
                    replacementUTF8:
                        "enum PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter {",
                    replacementByteCount: 70,
                    replacementSHA256:
                        "8133fb6157154d866541f1d379ad9d478caaf09d2eb79dc970dc2b2a7d05a0fb"
                ),
                .init(
                    ordinal: 2,
                    rewriteID:
                        "internal_isolated_gate_namespace_self_reference",
                    sourceUTF8:
                        "PrimeNeuralNativeLanguageVerifyAbstainGate\n"
                        + "                .exactMaterialsCacheKey",
                    sourceByteCount: 82,
                    sourceSHA256:
                        "51b33089416e7bac694073d8a5c1136e0847ab57142a636210cfc35948e32a70",
                    replacementUTF8:
                        "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter\n"
                        + "                .exactMaterialsCacheKey",
                    replacementByteCount: 103,
                    replacementSHA256:
                        "cd864c2d2a1e4508580029a0cc1ee34ac12f3057f387bd0b6a94b7eebf650e4e"
                ),
            ],
            transformedBodyByteCount: 368_953,
            transformedBodySHA256:
                "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31",
            expectedOutputByteCount: 368_953,
            expectedOutputSHA256:
                "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31"
        )

    /// Exact V2 fixture derivation, retained byte-for-byte for additive V11
    /// placement beside the historical gate. V11 changes routing, not the
    /// proven source material or any of its four frozen rewrites.
    static let frozenHistoricalFixtureDerivation:
        PrimeNativeNeuralGateHistoricalSourceDerivationContract =
        {
            let prefix =
                "import CryptoKit\n"
                + "import ErgenticsPrimeRuntime\n"
                + "import PrimeNativeNeuralGateReplayMechanics\n"
                + "import Foundation\n\n"
                + "public enum EngineProposesNativeLanguageVerifyAbstainFixture {\n"
                + "    public enum MaterializationError: Error, Equatable {\n"
                + "        case invalidPackageResolvedArtifact\n"
                + "    }\n\n"
            return PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID:
                    "exact_lf_forensic_fixture_five_group_four_rewrite_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [10, 11],
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
                    Array(repeating: "0a0a", count: 4),
                joinedGroupByteCount: 87_763,
                joinedGroupSHA256:
                    "524864949a47434c14ac990c03e90a6eb6054e56bcdc58c2ab018aab1e8e59a7",
                prefixUTF8: prefix,
                prefixByteCount: 280,
                prefixSHA256:
                    "1690de7194caa62ab8d012d3b5de14e067e0d6c090dd5b2cef1543b0dc3d9b85",
                suffixUTF8: "\n}\n",
                suffixByteCount: 3,
                suffixSHA256:
                    "804f89fc0ec98c9824183e795d3edd19e930f7bc471f9012aa3d503be2f8974b",
                rewrites: [
                    .init(
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
                    .init(
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
                    .init(
                        ordinal: 3,
                        rewriteID:
                            "remove_file_path_and_accept_explicit_package_url",
                        sourceUTF8:
                            "        let packageResolvedURL = URL(\n"
                            + "            fileURLWithPath: "
                            + "#" + "filePath\n"
                            + "        ).deletingLastPathComponent()\n"
                            + "            .deletingLastPathComponent()\n"
                            + "            .deletingLastPathComponent()\n"
                            + "            .appendingPathComponent(\n"
                            + "                Gate.packageResolvedArtifactFileName\n"
                            + "            )\n"
                            + "        let packageResolvedData =\n"
                            + "            try! "
                            + "Data" + "(contentsOf: packageResolvedURL)\n",
                        sourceByteCount: 389,
                        sourceSHA256:
                            "27283601f132f38d05db2e1f5f32a9179da2253290204807d9a509f38a2c70df",
                        replacementUTF8:
                            "        let packageResolvedData =\n"
                            + "            try "
                            + "Data" + "(contentsOf: packageResolvedURL)\n",
                        replacementByteCount: 87,
                        replacementSHA256:
                            "4ddef6e0fa189b084d27503857e101353b94dde6530309842157de41b8f48782"
                    ),
                    .init(
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
                ],
                transformedBodyByteCount: 87_858,
                transformedBodySHA256:
                    "11a335d766a4078c4ddcce78e67685c4a2da86b5f85859fcf59431342966f070",
                expectedOutputByteCount: 88_141,
                expectedOutputSHA256:
                    "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
            )
        }()

    static let frozenCarrierDerivation =
        PrimeNativeNeuralGateHistoricalSourceDerivationContract(
            derivationID:
                "exact_lf_line_slice_verdict_carrier_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [9],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1,
                    lastLine: 1,
                    terminalLFPolicy: .preserveTerminalLF,
                    expectedByteCount: 18,
                    expectedSHA256:
                        "dda9b75f64b106eb544de201f599122d75abc483c5b156bba6c05c0f956dbc3c"
                ),
                .init(
                    ordinal: 2,
                    firstLine: 4,
                    lastLine: 66,
                    terminalLFPolicy: .preserveTerminalLF,
                    expectedByteCount: 2_376,
                    expectedSHA256:
                        "83c3d54c32d2c87f1841be04dd552700dedf9d34d6a90983b899439129dc7a6a"
                ),
                .init(
                    ordinal: 3,
                    firstLine: 105,
                    lastLine: 105,
                    terminalLFPolicy: .preserveTerminalLF,
                    expectedByteCount: 2,
                    expectedSHA256:
                        "412ca345ccf75bf9c0806bce695be8de808b79984251a7a54d202cf6101dd451"
                ),
            ],
            betweenGroupUTF8Hex: ["0a", ""],
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

    static let frozenGateCarrierUseDerivation =
        PrimeNativeNeuralGateHistoricalSourceDerivationContract(
            derivationID:
                "exact_lf_native_gate_carrier_construction_use_v1",
            kind: .frozenLineGroupsAndRewrites,
            requiredInputOrdinals: [1],
            lineGroups: [
                .init(
                    ordinal: 1,
                    firstLine: 1_916,
                    lastLine: 1_930,
                    terminalLFPolicy: .preserveTerminalLF,
                    expectedByteCount: 510,
                    expectedSHA256:
                        "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb"
                ),
            ],
            joinedGroupByteCount: 510,
            joinedGroupSHA256:
                "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb",
            transformedBodyByteCount: 510,
            transformedBodySHA256:
                "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb",
            expectedOutputByteCount: 510,
            expectedOutputSHA256:
                "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb"
        )

    static let frozenMutationMaterialDerivation:
        PrimeNativeNeuralGateHistoricalSourceDerivationContract =
        {
            func group(
                _ ordinal: Int,
                _ firstLine: Int,
                _ lastLine: Int,
                _ byteCount: UInt64,
                _ sha256: String
            ) -> PrimeNativeNeuralGateHistoricalSourceLineGroup {
                .init(
                    ordinal: ordinal,
                    firstLine: firstLine,
                    lastLine: lastLine,
                    terminalLFPolicy: .preserveTerminalLF,
                    expectedByteCount: byteCount,
                    expectedSHA256: sha256
                )
            }
            return PrimeNativeNeuralGateHistoricalSourceDerivationContract(
                derivationID:
                    "exact_lf_historical_forty_six_mutation_raw_material_six_group_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    group(
                        1, 257, 405, 6_398,
                        "81d99227f79d4734a89ef369ac761d2bd354cd2a324db2db327dfa85d1d30386"
                    ),
                    group(
                        2, 407, 425, 662,
                        "d992aca9b9ea00690c442a6165a8dcfd39fa093b00d460513f4ae393f7c84fe1"
                    ),
                    group(
                        3, 426, 441, 562,
                        "f075bc32a9f74396190d7666e4103cf9b68dafa39d60f95e3a72aa2b61e4c2c9"
                    ),
                    group(
                        4, 7_147, 7_350, 8_402,
                        "f1de9075e1e8bbce8707396f7b9e14f884c3060ffad5e54022f546493d58b9a9"
                    ),
                    group(
                        5, 7_352, 7_453, 4_319,
                        "74d972ef325c0aae169394d7ae97819502c65645ea79ceb667ed462fe04f2730"
                    ),
                    group(
                        6, 7_486, 8_148, 24_747,
                        "046f8935d866868e3bc60172971bdb62b2b2e607648461ebe210f328f54a7969"
                    ),
                ],
                betweenGroupUTF8Hex: ["", "", "", "", ""],
                joinedGroupByteCount: 45_090,
                joinedGroupSHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb",
                transformedBodyByteCount: 45_090,
                transformedBodySHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb",
                expectedOutputByteCount: 45_090,
                expectedOutputSHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb"
            )
        }()
}

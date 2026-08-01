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

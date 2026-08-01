import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateMutationSurfaceError:
    Error,
    Equatable,
    Sendable
{
    case invalidControlMaterial(String)
    case encodedSurfaceTooLarge
    case invalidMagic
    case invalidSchemaVersion
    case invalidBoolean
    case invalidEnumeration
    case invalidNonAuthorityMarker
    case invalidLowercaseASCIIHex
    case truncatedInput
    case trailingInput
    case noncanonicalSurface
    case invalidSurfaceBinding
}

public enum PrimeNativeNeuralGateCorrectedMutationSurfaceContract {
    public static let contractID =
        "prime_stage_b_corrected_mutation_label_free_surface_contract_v1"
    public static let serializationContractID =
        "pmutrec1_fixed_order_lowercase_ascii_hex_presence_only_control_surface_v1"
    public static let encodedByteCount = 165
    public static let exactBlindBatchCount = 15
}

public enum PrimeNativeNeuralGateCorrectedControlLegID:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case targetValueIndependence =
        "corrected_target_value_independence"
    case targetLengthIndependence =
        "corrected_target_length_independence"
    case predictionInputExclusion =
        "corrected_prediction_input_exclusion"
    case promptGrouping = "corrected_prompt_grouping"
    case decisionBudget = "corrected_decision_budget"
    case eosAvailability = "corrected_eos_availability"
    case completionSupport = "corrected_completion_support"
    case fixedCap = "corrected_fixed_cap"
    case terminationIndependence =
        "corrected_termination_independence"
    case rowInclusionIndependence =
        "corrected_row_inclusion_independence"
    case replicateSeedScope =
        "corrected_replicate_seed_scope"
    case rowOrderStateIndependence =
        "corrected_row_order_state_independence"
}

public enum PrimeNativeNeuralGatePromptGroupingControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case targetIndependent = 0
    case targetDependent = 1
}

public enum PrimeNativeNeuralGateDecisionBudgetControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case fixedPolicy = 0
    case targetDependent = 1
}

public enum PrimeNativeNeuralGateCompletionSupportControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case eosAndFullByteVocabulary = 0
    case eosAndRestrictedByteVocabulary = 1
}

public enum PrimeNativeNeuralGateTerminationControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case eosOrFixedCap = 0
    case targetDependent = 1
}

public enum PrimeNativeNeuralGateRowInclusionControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case allSourceRows = 0
    case targetDependent = 1
}

public enum PrimeNativeNeuralGateReplicateSeedScopeControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case replicate = 0
    case rowDependent = 1
}

public enum PrimeNativeNeuralGateRowStateControl:
    UInt8,
    Codable,
    Equatable,
    Sendable
{
    case freshPerRow = 0
    case retainedAcrossRows = 1
}

public struct PrimeNativeNeuralGateCorrectedControlMaterial:
    Equatable,
    Sendable
{
    public static let admittedReplicateSeeds:
        Set<UInt32> = [1_618, 2_718, 3_141]

    public let commonCaptureScheduleReferenceSHA256: String
    public let branchCaptureScheduleReferenceSHA256: String
    public let copiedReferenceAuthorityObserved: Bool
    public let targetValueAffectsRawIdentity: Bool
    public let targetLengthAffectsRawIdentity: Bool
    public let predictionExpectedCompletionPresent: Bool
    public let predictionRowIDPresent: Bool
    public let predictionSplitPresent: Bool
    public let predictionSemanticFamilyPresent: Bool
    public let promptGrouping:
        PrimeNativeNeuralGatePromptGroupingControl
    public let decisionBudget:
        PrimeNativeNeuralGateDecisionBudgetControl
    public let eosAvailableAtEveryDecision: Bool
    public let completionSupport:
        PrimeNativeNeuralGateCompletionSupportControl
    public let fixedDecisionCap: UInt16
    public let termination:
        PrimeNativeNeuralGateTerminationControl
    public let rowInclusion:
        PrimeNativeNeuralGateRowInclusionControl
    public let replicateSeed: UInt32
    public let replicateSeedScope:
        PrimeNativeNeuralGateReplicateSeedScopeControl
    public let rowState:
        PrimeNativeNeuralGateRowStateControl

    public init(
        commonCaptureScheduleReferenceSHA256: String,
        branchCaptureScheduleReferenceSHA256: String,
        targetValueAffectsRawIdentity: Bool,
        targetLengthAffectsRawIdentity: Bool,
        predictionExpectedCompletionPresent: Bool,
        predictionRowIDPresent: Bool,
        predictionSplitPresent: Bool,
        predictionSemanticFamilyPresent: Bool,
        promptGrouping:
            PrimeNativeNeuralGatePromptGroupingControl,
        decisionBudget:
            PrimeNativeNeuralGateDecisionBudgetControl,
        eosAvailableAtEveryDecision: Bool,
        completionSupport:
            PrimeNativeNeuralGateCompletionSupportControl,
        fixedDecisionCap: UInt16,
        termination:
            PrimeNativeNeuralGateTerminationControl,
        rowInclusion:
            PrimeNativeNeuralGateRowInclusionControl,
        replicateSeed: UInt32,
        replicateSeedScope:
            PrimeNativeNeuralGateReplicateSeedScopeControl,
        rowState:
            PrimeNativeNeuralGateRowStateControl
    ) throws {
        copiedReferenceAuthorityObserved = false
        self.commonCaptureScheduleReferenceSHA256 =
            commonCaptureScheduleReferenceSHA256
        self.branchCaptureScheduleReferenceSHA256 =
            branchCaptureScheduleReferenceSHA256
        self.targetValueAffectsRawIdentity =
            targetValueAffectsRawIdentity
        self.targetLengthAffectsRawIdentity =
            targetLengthAffectsRawIdentity
        self.predictionExpectedCompletionPresent =
            predictionExpectedCompletionPresent
        self.predictionRowIDPresent = predictionRowIDPresent
        self.predictionSplitPresent = predictionSplitPresent
        self.predictionSemanticFamilyPresent =
            predictionSemanticFamilyPresent
        self.promptGrouping = promptGrouping
        self.decisionBudget = decisionBudget
        self.eosAvailableAtEveryDecision =
            eosAvailableAtEveryDecision
        self.completionSupport = completionSupport
        self.fixedDecisionCap = fixedDecisionCap
        self.termination = termination
        self.rowInclusion = rowInclusion
        self.replicateSeed = replicateSeed
        self.replicateSeedScope = replicateSeedScope
        self.rowState = rowState
        try validate()
    }

    public static func baseline(
        commonCaptureScheduleReferenceSHA256: String,
        branchCaptureScheduleReferenceSHA256: String,
        replicateSeed: UInt32 = 1_618
    ) throws -> Self {
        try Self(
            commonCaptureScheduleReferenceSHA256:
                commonCaptureScheduleReferenceSHA256,
            branchCaptureScheduleReferenceSHA256:
                branchCaptureScheduleReferenceSHA256,
            targetValueAffectsRawIdentity: false,
            targetLengthAffectsRawIdentity: false,
            predictionExpectedCompletionPresent: false,
            predictionRowIDPresent: false,
            predictionSplitPresent: false,
            predictionSemanticFamilyPresent: false,
            promptGrouping: .targetIndependent,
            decisionBudget: .fixedPolicy,
            eosAvailableAtEveryDecision: true,
            completionSupport: .eosAndFullByteVocabulary,
            fixedDecisionCap: 64,
            termination: .eosOrFixedCap,
            rowInclusion: .allSourceRows,
            replicateSeed: replicateSeed,
            replicateSeedScope: .replicate,
            rowState: .freshPerRow
        )
    }

    public func validate() throws {
        guard Self.isLowercaseSHA256(
            commonCaptureScheduleReferenceSHA256
        ) else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidControlMaterial(
                    "common_capture_schedule_reference_sha256"
                )
        }
        guard Self.isLowercaseSHA256(
            branchCaptureScheduleReferenceSHA256
        ) else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidControlMaterial(
                    "branch_capture_schedule_reference_sha256"
                )
        }
        guard !copiedReferenceAuthorityObserved else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidControlMaterial(
                    "copied_reference_authority_observed"
                )
        }
        guard (fixedDecisionCap == 64
                || fixedDecisionCap == 63),
              Self.admittedReplicateSeeds.contains(replicateSeed)
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidControlMaterial("bounded_policy")
        }
    }

    public func isExactBaselineControlSet() -> Bool {
        !targetValueAffectsRawIdentity
            && !targetLengthAffectsRawIdentity
            && !predictionExpectedCompletionPresent
            && !predictionRowIDPresent
            && !predictionSplitPresent
            && !predictionSemanticFamilyPresent
            && promptGrouping == .targetIndependent
            && decisionBudget == .fixedPolicy
            && eosAvailableAtEveryDecision
            && completionSupport == .eosAndFullByteVocabulary
            && fixedDecisionCap == 64
            && termination == .eosOrFixedCap
            && rowInclusion == .allSourceRows
            && replicateSeedScope == .replicate
            && rowState == .freshPerRow
            && !copiedReferenceAuthorityObserved
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy(Self.isLowercaseHexByte)
    }

    fileprivate static func isLowercaseHexByte(
        _ byte: UInt8
    ) -> Bool {
        (48 ... 57).contains(byte)
            || (97 ... 102).contains(byte)
    }
}

public enum PrimeNativeNeuralGateCorrectedControlSurfaceCodec {
    public static let surfaceContractID =
        PrimeNativeNeuralGateCorrectedMutationSurfaceContract
        .contractID
    public static let serializationContractID =
        PrimeNativeNeuralGateCorrectedMutationSurfaceContract
        .serializationContractID
    public static let encodedByteCount =
        PrimeNativeNeuralGateCorrectedMutationSurfaceContract
        .encodedByteCount
    public static let maximumEncodedByteCount = 1_024

    private static let magic = Data("PMUTREC1".utf8)
    private static let schemaVersion: UInt16 = 1
    private static let copiedReferenceNonAuthorityMarker:
        UInt8 = 0

    public static func encode(
        _ material:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> Data {
        try material.validate()
        var output = magic
        append(schemaVersion, to: &output)
        output.append(copiedReferenceNonAuthorityMarker)
        output.append(
            contentsOf: material
                .commonCaptureScheduleReferenceSHA256.utf8
        )
        output.append(
            contentsOf: material
                .branchCaptureScheduleReferenceSHA256.utf8
        )
        append(material.targetValueAffectsRawIdentity, to: &output)
        append(material.targetLengthAffectsRawIdentity, to: &output)
        append(
            material.predictionExpectedCompletionPresent,
            to: &output
        )
        append(material.predictionRowIDPresent, to: &output)
        append(material.predictionSplitPresent, to: &output)
        append(
            material.predictionSemanticFamilyPresent,
            to: &output
        )
        output.append(material.promptGrouping.rawValue)
        output.append(material.decisionBudget.rawValue)
        append(material.eosAvailableAtEveryDecision, to: &output)
        output.append(material.completionSupport.rawValue)
        appendFixedHex(
            UInt64(material.fixedDecisionCap),
            width: 4,
            to: &output
        )
        output.append(material.termination.rawValue)
        output.append(material.rowInclusion.rawValue)
        appendFixedHex(
            UInt64(material.replicateSeed),
            width: 8,
            to: &output
        )
        output.append(material.replicateSeedScope.rawValue)
        output.append(material.rowState.rawValue)
        guard output.count == encodedByteCount else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .noncanonicalSurface
        }
        return output
    }

    public static func decode(
        _ data: Data
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        guard data.count <= maximumEncodedByteCount else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .encodedSurfaceTooLarge
        }
        var reader = Reader(data)
        guard try reader.read(magic.count) == magic else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidMagic
        }
        let version: UInt16 = try reader.readInteger()
        guard version == schemaVersion else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidSchemaVersion
        }
        guard try reader.readByte()
                == copiedReferenceNonAuthorityMarker
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidNonAuthorityMarker
        }
        let common = try reader.readLowercaseHexString(count: 64)
        let branch = try reader.readLowercaseHexString(count: 64)
        let targetValue = try reader.readBoolean()
        let targetLength = try reader.readBoolean()
        let expectedCompletionPresent = try reader.readBoolean()
        let rowIDPresent = try reader.readBoolean()
        let splitPresent = try reader.readBoolean()
        let semanticFamilyPresent = try reader.readBoolean()
        guard let grouping =
                PrimeNativeNeuralGatePromptGroupingControl(
                    rawValue: try reader.readByte()
                ),
              let budget =
                PrimeNativeNeuralGateDecisionBudgetControl(
                    rawValue: try reader.readByte()
                )
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        let eosAvailable = try reader.readBoolean()
        guard let support =
                PrimeNativeNeuralGateCompletionSupportControl(
                    rawValue: try reader.readByte()
                )
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        let encodedCap = try reader.readFixedHex(count: 4)
        guard let cap = UInt16(exactly: encodedCap) else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        guard let termination =
                PrimeNativeNeuralGateTerminationControl(
                    rawValue: try reader.readByte()
                ),
              let inclusion =
                PrimeNativeNeuralGateRowInclusionControl(
                    rawValue: try reader.readByte()
                )
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        let encodedSeed = try reader.readFixedHex(count: 8)
        guard let seed = UInt32(exactly: encodedSeed) else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        guard let seedScope =
                PrimeNativeNeuralGateReplicateSeedScopeControl(
                    rawValue: try reader.readByte()
                ),
              let rowState =
                PrimeNativeNeuralGateRowStateControl(
                    rawValue: try reader.readByte()
                )
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidEnumeration
        }
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .trailingInput
        }
        let material = try PrimeNativeNeuralGateCorrectedControlMaterial(
            commonCaptureScheduleReferenceSHA256: common,
            branchCaptureScheduleReferenceSHA256: branch,
            targetValueAffectsRawIdentity: targetValue,
            targetLengthAffectsRawIdentity: targetLength,
            predictionExpectedCompletionPresent:
                expectedCompletionPresent,
            predictionRowIDPresent: rowIDPresent,
            predictionSplitPresent: splitPresent,
            predictionSemanticFamilyPresent:
                semanticFamilyPresent,
            promptGrouping: grouping,
            decisionBudget: budget,
            eosAvailableAtEveryDecision: eosAvailable,
            completionSupport: support,
            fixedDecisionCap: cap,
            termination: termination,
            rowInclusion: inclusion,
            replicateSeed: seed,
            replicateSeedScope: seedScope,
            rowState: rowState
        )
        guard try encode(material) == data else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .noncanonicalSurface
        }
        return material
    }

    private static func append<Value: FixedWidthInteger>(
        _ value: Value,
        to data: inout Data
    ) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) {
            data.append(contentsOf: $0)
        }
    }

    private static func append(
        _ value: Bool,
        to data: inout Data
    ) {
        data.append(value ? 1 : 0)
    }

    private static func appendFixedHex(
        _ value: UInt64,
        width: Int,
        to data: inout Data
    ) {
        let encoded = String(format: "%0*llx", width, value)
        precondition(encoded.utf8.count == width)
        data.append(contentsOf: encoded.utf8)
    }

    private struct Reader {
        let data: Data
        var offset = 0

        init(_ data: Data) {
            self.data = data
        }

        var isAtEnd: Bool {
            offset == data.count
        }

        mutating func read(_ count: Int) throws -> Data {
            guard count >= 0,
                  offset <= data.count,
                  count <= data.count - offset
            else {
                throw PrimeNativeNeuralGateMutationSurfaceError
                    .truncatedInput
            }
            let start = data.index(
                data.startIndex,
                offsetBy: offset
            )
            let end = data.index(start, offsetBy: count)
            offset += count
            return data.subdata(in: start..<end)
        }

        mutating func readByte() throws -> UInt8 {
            guard let byte = try read(1).first else {
                throw PrimeNativeNeuralGateMutationSurfaceError
                    .truncatedInput
            }
            return byte
        }

        mutating func readBoolean() throws -> Bool {
            switch try readByte() {
            case 0:
                false
            case 1:
                true
            default:
                throw PrimeNativeNeuralGateMutationSurfaceError
                    .invalidBoolean
            }
        }

        mutating func readInteger<Value: FixedWidthInteger>()
            throws -> Value
        {
            let bytes = try read(MemoryLayout<Value>.size)
            var result: Value = 0
            for byte in bytes {
                result = (result << 8) | Value(byte)
            }
            return result
        }

        mutating func readLowercaseHexString(
            count: Int
        ) throws -> String {
            let bytes = try read(count)
            guard bytes.allSatisfy(
                PrimeNativeNeuralGateCorrectedControlMaterial
                    .isLowercaseHexByte
            ) else {
                throw PrimeNativeNeuralGateMutationSurfaceError
                    .invalidLowercaseASCIIHex
            }
            return String(decoding: bytes, as: UTF8.self)
        }

        mutating func readFixedHex(
            count: Int
        ) throws -> UInt64 {
            let bytes = try read(count)
            var result: UInt64 = 0
            for byte in bytes {
                let digit: UInt64
                switch byte {
                case 48 ... 57:
                    digit = UInt64(byte - 48)
                case 97 ... 102:
                    digit = UInt64(byte - 87)
                default:
                    throw PrimeNativeNeuralGateMutationSurfaceError
                        .invalidLowercaseASCIIHex
                }
                let next = result
                    .multipliedReportingOverflow(by: 16)
                guard !next.overflow else {
                    throw PrimeNativeNeuralGateMutationSurfaceError
                        .invalidLowercaseASCIIHex
                }
                let addition = next.partialValue
                    .addingReportingOverflow(digit)
                guard !addition.overflow else {
                    throw PrimeNativeNeuralGateMutationSurfaceError
                        .invalidLowercaseASCIIHex
                }
                result = addition.partialValue
            }
            return result
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedControlSurfaceBinding:
    Equatable,
    Sendable
{
    public let surfaceByteCount: Int
    public let surfaceSHA256: String
    public let invariantGlobalStreamSHA256: String
    public let directFingerprint: PrimeNativeNeuralGateFingerprint
    public let acceleratedFingerprint:
        PrimeNativeNeuralGateFingerprint

    public init(
        surfaceByteCount: Int,
        surfaceSHA256: String,
        invariantGlobalStreamSHA256: String,
        directFingerprint: PrimeNativeNeuralGateFingerprint,
        acceleratedFingerprint:
            PrimeNativeNeuralGateFingerprint
    ) {
        self.surfaceByteCount = surfaceByteCount
        self.surfaceSHA256 = surfaceSHA256
        self.invariantGlobalStreamSHA256 =
            invariantGlobalStreamSHA256
        self.directFingerprint = directFingerprint
        self.acceleratedFingerprint = acceleratedFingerprint
    }
}

public struct PrimeNativeNeuralGateBoundCorrectedControlSurface:
    Equatable,
    Sendable
{
    public let bytes: Data
    public let binding:
        PrimeNativeNeuralGateCorrectedControlSurfaceBinding

    public init(
        bytes: Data,
        binding:
            PrimeNativeNeuralGateCorrectedControlSurfaceBinding
    ) {
        self.bytes = bytes
        self.binding = binding
    }
}

/// Label-free detector input. Catalog identities remain outside this type and
/// are compared with detector reports only by the integration boundary.
public struct PrimeNativeNeuralGateBlindCorrectedMutationTriplet:
    Equatable,
    Sendable
{
    public let baseline:
        PrimeNativeNeuralGateBoundCorrectedControlSurface
    public let mutated:
        PrimeNativeNeuralGateBoundCorrectedControlSurface
    public let restored:
        PrimeNativeNeuralGateBoundCorrectedControlSurface

    public init(
        baseline:
            PrimeNativeNeuralGateBoundCorrectedControlSurface,
        mutated:
            PrimeNativeNeuralGateBoundCorrectedControlSurface,
        restored:
            PrimeNativeNeuralGateBoundCorrectedControlSurface
    ) {
        self.baseline = baseline
        self.mutated = mutated
        self.restored = restored
    }
}

public enum PrimeNativeNeuralGateCorrectedControlSurfaceBinder {
    public static func bind(
        _ material:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> PrimeNativeNeuralGateBoundCorrectedControlSurface {
        let bytes =
            try PrimeNativeNeuralGateCorrectedControlSurfaceCodec
            .encode(material)
        return try bindCanonicalBytes(bytes)
    }

    public static func bindCanonicalBytes(
        _ bytes: Data
    ) throws -> PrimeNativeNeuralGateBoundCorrectedControlSurface {
        let material =
            try PrimeNativeNeuralGateCorrectedControlSurfaceCodec
            .decode(bytes)
        guard try PrimeNativeNeuralGateCorrectedControlSurfaceCodec
                .encode(material) == bytes
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .noncanonicalSurface
        }
        return PrimeNativeNeuralGateBoundCorrectedControlSurface(
            bytes: bytes,
            binding: try makeBinding(bytes)
        )
    }

    public static func validateAndDecode(
        _ surface:
            PrimeNativeNeuralGateBoundCorrectedControlSurface
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        let material =
            try PrimeNativeNeuralGateCorrectedControlSurfaceCodec
            .decode(surface.bytes)
        let expected = try makeBinding(surface.bytes)
        guard surface.binding == expected,
              expected.directFingerprint
                == expected.acceleratedFingerprint
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidSurfaceBinding
        }
        return material
    }

    private static func makeBinding(
        _ bytes: Data
    ) throws -> PrimeNativeNeuralGateCorrectedControlSurfaceBinding {
        let bundle = try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: [bytes])
        let observation = bundle.fingerprintObservation
        guard observation.exactEqualityObserved,
              observation.direct == observation.accelerated
        else {
            throw PrimeNativeNeuralGateMutationSurfaceError
                .invalidSurfaceBinding
        }
        return PrimeNativeNeuralGateCorrectedControlSurfaceBinding(
            surfaceByteCount: bytes.count,
            surfaceSHA256:
                PrimeNativeNeuralGateInvariantCodec.sha256(bytes),
            invariantGlobalStreamSHA256:
                bundle.manifest.globalStreamSHA256,
            directFingerprint: observation.direct,
            acceleratedFingerprint: observation.accelerated
        )
    }
}

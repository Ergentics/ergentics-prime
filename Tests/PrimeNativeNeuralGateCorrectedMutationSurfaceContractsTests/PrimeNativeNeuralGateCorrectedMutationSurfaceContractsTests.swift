import Foundation
import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts
import XCTest

final class PrimeNativeNeuralGateCorrectedMutationSurfaceContractsTests:
    XCTestCase
{
    private enum BaselineLayout {
        static let encodedByteCount = 165
        static let authorityMarker = 10
        static let commonSHA = 11 ..< 75
        static let branchSHA = 75 ..< 139
        static let targetValueBoolean = 139
        static let targetLengthBoolean = 140
        static let optionalPresenceMarkers = [141, 142, 143, 144]
        static let promptGrouping = 145
        static let decisionBudget = 146
        static let eosBoolean = 147
        static let completionSupport = 148
        static let decisionCap = 149 ..< 153
        static let termination = 153
        static let rowInclusion = 154
        static let replicateSeed = 155 ..< 163
        static let seedScope = 163
        static let rowState = 164
    }

    func testBaselineEncodingHasExactPMUTREC1LayoutAndCanonicalRoundTrip()
        throws
    {
        let material = try baseline()
        let bytes = try codec.encode(material)

        XCTAssertEqual(
            codec.surfaceContractID,
            "prime_stage_b_corrected_mutation_label_free_surface_contract_v1"
        )
        XCTAssertEqual(
            codec.serializationContractID,
            "pmutrec1_fixed_order_lowercase_ascii_hex_presence_only_control_surface_v1"
        )
        XCTAssertEqual(codec.encodedByteCount, 165)
        XCTAssertEqual(bytes.count, BaselineLayout.encodedByteCount)
        XCTAssertEqual(ascii(bytes, 0 ..< 8), "PMUTREC1")
        XCTAssertEqual(Array(bytes[8 ..< 10]), [0, 1])
        XCTAssertEqual(bytes[BaselineLayout.authorityMarker], 0)
        XCTAssertEqual(
            ascii(bytes, BaselineLayout.commonSHA),
            sha("a")
        )
        XCTAssertEqual(
            ascii(bytes, BaselineLayout.branchSHA),
            sha("b")
        )
        XCTAssertEqual(
            ascii(bytes, BaselineLayout.decisionCap),
            "0040"
        )
        XCTAssertEqual(
            ascii(bytes, BaselineLayout.replicateSeed),
            "00000652"
        )
        XCTAssertEqual(try codec.decode(bytes), material)
        XCTAssertEqual(
            try codec.encode(codec.decode(bytes)),
            bytes
        )
    }

    func testBlindTripletCarriesOnlySurfacesAndBatchCountIsExact()
        throws
    {
        let surface = try binder.bind(baseline())
        let triplet =
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                baseline: surface,
                mutated: surface,
                restored: surface
            )
        XCTAssertEqual(
            PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount,
            15
        )
        XCTAssertEqual(triplet.baseline, surface)
        XCTAssertEqual(triplet.mutated, surface)
        XCTAssertEqual(triplet.restored, surface)
    }

    func testEveryAlternativeControlAndPresenceFlagRoundTripsCanonically()
        throws
    {
        let material = try makeMaterial(
            seed: 3_141,
            cap: 63,
            targetValue: true,
            targetLength: true,
            expectedCompletionPresent: true,
            rowIDPresent: true,
            splitPresent: true,
            semanticFamilyPresent: true,
            promptGrouping: .targetDependent,
            decisionBudget: .targetDependent,
            eosAvailable: false,
            completionSupport:
                .eosAndRestrictedByteVocabulary,
            termination: .targetDependent,
            rowInclusion: .targetDependent,
            seedScope: .rowDependent,
            rowState: .retainedAcrossRows
        )
        let bytes = try codec.encode(material)
        let decoded = try codec.decode(bytes)

        XCTAssertEqual(decoded, material)
        XCTAssertEqual(try codec.encode(decoded), bytes)
        XCTAssertFalse(decoded.isExactBaselineControlSet())
        XCTAssertLessThanOrEqual(
            bytes.count,
            codec.maximumEncodedByteCount
        )
    }

    func testAllThreeAdmittedSeedsRoundTrip()
        throws
    {
        for seed: UInt32 in [1_618, 2_718, 3_141] {
            let material = try baseline(seed: seed)
            let bytes = try codec.encode(material)
            XCTAssertEqual(
                try codec.decode(bytes).replicateSeed,
                seed
            )
            XCTAssertEqual(
                try codec.encode(codec.decode(bytes)),
                bytes
            )
        }
    }

    func testEveryTruncationBoundaryIsRejected()
        throws
    {
        let bytes = try codec.encode(baseline())
        for boundary in 0 ..< bytes.count {
            let truncated = Data(bytes.prefix(boundary))
            assertDecodeFails(
                truncated,
                as: .truncatedInput,
                "boundary \(boundary)"
            )
        }
    }

    func testMagicVersionAndAuthorityMarkerAreStrict()
        throws
    {
        let bytes = try codec.encode(baseline())
        assertDecodeFails(
            replacingByte(bytes, at: 0, with: 0),
            as: .invalidMagic
        )
        assertDecodeFails(
            replacingByte(bytes, at: 9, with: 2),
            as: .invalidSchemaVersion
        )
        assertDecodeFails(
            replacingByte(
                bytes,
                at: BaselineLayout.authorityMarker,
                with: 1
            ),
            as: .invalidNonAuthorityMarker
        )
    }

    func testEveryBooleanMarkerRejectsNonBooleanBytes()
        throws
    {
        let bytes = try codec.encode(baseline())
        for offset in [
            BaselineLayout.targetValueBoolean,
            BaselineLayout.targetLengthBoolean,
            BaselineLayout.eosBoolean,
        ] {
            assertDecodeFails(
                replacingByte(bytes, at: offset, with: 2),
                as: .invalidBoolean,
                "boolean offset \(offset)"
            )
        }
    }

    func testEveryPresenceMarkerRejectsNonBooleanValues()
        throws
    {
        let bytes = try codec.encode(baseline())
        for offset in BaselineLayout.optionalPresenceMarkers {
            assertDecodeFails(
                replacingByte(bytes, at: offset, with: 2),
                as: .invalidBoolean,
                "presence offset \(offset)"
            )
        }
    }

    func testEveryEnumerationMarkerRejectsUnknownValues()
        throws
    {
        let bytes = try codec.encode(baseline())
        for offset in [
            BaselineLayout.promptGrouping,
            BaselineLayout.decisionBudget,
            BaselineLayout.completionSupport,
            BaselineLayout.termination,
            BaselineLayout.rowInclusion,
            BaselineLayout.seedScope,
            BaselineLayout.rowState,
        ] {
            assertDecodeFails(
                replacingByte(bytes, at: offset, with: 2),
                as: .invalidEnumeration,
                "enumeration offset \(offset)"
            )
        }
    }

    func testBothSHAFieldsRequireExactlyLowercaseHex()
        throws
    {
        let bytes = try codec.encode(baseline())
        for (range, field) in [
            (BaselineLayout.commonSHA, "common_capture_schedule_reference_sha256"),
            (BaselineLayout.branchSHA, "branch_capture_schedule_reference_sha256"),
        ] {
            assertDecodeFails(
                replacingByte(bytes, at: range.lowerBound, with: 65),
                as: .invalidLowercaseASCIIHex,
                "uppercase \(field)"
            )
            assertDecodeFails(
                replacingByte(bytes, at: range.lowerBound, with: 103),
                as: .invalidLowercaseASCIIHex,
                "nonhex \(field)"
            )
        }
    }

    func testAllFixedWidthHexFieldsRejectUppercaseAndNonhex()
        throws
    {
        let capBytes = replacingASCII(
            try codec.encode(baseline()),
            in: BaselineLayout.decisionCap,
            with: "003f"
        )
        XCTAssertEqual(
            ascii(capBytes, BaselineLayout.decisionCap),
            "003f"
        )
        XCTAssertEqual(
            try codec.decode(capBytes).fixedDecisionCap,
            63
        )
        for replacement: UInt8 in [65, 103] {
            assertDecodeFails(
                replacingByte(capBytes, at: 152, with: replacement),
                as: .invalidLowercaseASCIIHex
            )
        }

        let seedBytes = try codec.encode(
            baseline(seed: 2_718)
        )
        XCTAssertEqual(
            ascii(seedBytes, BaselineLayout.replicateSeed),
            "00000a9e"
        )
        for replacement: UInt8 in [65, 103] {
            assertDecodeFails(
                replacingByte(seedBytes, at: 160, with: replacement),
                as: .invalidLowercaseASCIIHex
            )
        }
    }

    func testInvalidCapsAreRejectedByConstructionAndDecode()
        throws
    {
        XCTAssertThrowsError(try makeMaterial(cap: 0))
        XCTAssertThrowsError(try makeMaterial(cap: 62))
        XCTAssertThrowsError(try makeMaterial(cap: 65))
        XCTAssertThrowsError(try makeMaterial(cap: 1_024))

        let bytes = try codec.encode(baseline())
        for invalid in ["0000", "003e", "0041", "0400"] {
            assertDecodeFails(
                replacingASCII(
                    bytes,
                    in: BaselineLayout.decisionCap,
                    with: invalid
                ),
                as: .invalidControlMaterial("bounded_policy")
            )
        }
    }

    func testInvalidSeedsAreRejectedByConstructionAndDecode()
        throws
    {
        XCTAssertThrowsError(try baseline(seed: 0))
        XCTAssertThrowsError(try baseline(seed: 1_619))

        let bytes = try codec.encode(baseline())
        assertDecodeFails(
            replacingASCII(
                bytes,
                in: BaselineLayout.replicateSeed,
                with: "00000000"
            ),
            as: .invalidControlMaterial("bounded_policy")
        )
        assertDecodeFails(
            replacingASCII(
                bytes,
                in: BaselineLayout.replicateSeed,
                with: "00000653"
            ),
            as: .invalidControlMaterial("bounded_policy")
        )
    }

    func testTrailingAndOversizeInputAreRejected()
        throws
    {
        var trailing = try codec.encode(baseline())
        trailing.append(0)
        assertDecodeFails(trailing, as: .trailingInput)

        let oversize = Data(
            repeating: 0,
            count: codec.maximumEncodedByteCount + 1
        )
        assertDecodeFails(oversize, as: .encodedSurfaceTooLarge)
    }

    func testCanonicalBinderRoundTripPreservesBytesAndMaterial()
        throws
    {
        let material = try baseline()
        let bound = try binder.bind(material)

        XCTAssertEqual(
            bound.binding.surfaceByteCount,
            bound.bytes.count
        )
        XCTAssertEqual(
            bound.binding.directFingerprint,
            bound.binding.acceleratedFingerprint
        )
        XCTAssertEqual(
            try binder.validateAndDecode(bound),
            material
        )
        XCTAssertEqual(
            try binder.bindCanonicalBytes(bound.bytes),
            bound
        )
    }

    func testBindingRejectsEveryIndependentAndPairedTamper()
        throws
    {
        let original = try binder.bind(baseline())
        let alternate = try binder.bind(
            baseline(seed: 2_718)
        )
        XCTAssertNotEqual(
            original.binding.directFingerprint,
            alternate.binding.directFingerprint
        )

        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount + 1,
                surfaceSHA256:
                    original.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    original.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    original.binding.directFingerprint,
                acceleratedFingerprint:
                    original.binding.acceleratedFingerprint
            ),
            "surface byte count"
        )
        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount,
                surfaceSHA256:
                    changedSHA(original.binding.surfaceSHA256),
                invariantGlobalStreamSHA256:
                    original.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    original.binding.directFingerprint,
                acceleratedFingerprint:
                    original.binding.acceleratedFingerprint
            ),
            "surface SHA"
        )
        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount,
                surfaceSHA256:
                    original.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    changedSHA(
                        original.binding.invariantGlobalStreamSHA256
                    ),
                directFingerprint:
                    original.binding.directFingerprint,
                acceleratedFingerprint:
                    original.binding.acceleratedFingerprint
            ),
            "global SHA"
        )
        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount,
                surfaceSHA256:
                    original.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    original.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    alternate.binding.directFingerprint,
                acceleratedFingerprint:
                    original.binding.acceleratedFingerprint
            ),
            "direct SZ"
        )
        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount,
                surfaceSHA256:
                    original.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    original.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    original.binding.directFingerprint,
                acceleratedFingerprint:
                    alternate.binding.acceleratedFingerprint
            ),
            "accelerated SZ"
        )
        assertBindingFails(
            original,
            binding: .init(
                surfaceByteCount:
                    original.binding.surfaceByteCount,
                surfaceSHA256:
                    original.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    original.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    alternate.binding.directFingerprint,
                acceleratedFingerprint:
                    alternate.binding.acceleratedFingerprint
            ),
            "paired forged SZ"
        )

        let alternateBytesWithOriginalBinding =
            PrimeNativeNeuralGateBoundCorrectedControlSurface(
                bytes: alternate.bytes,
                binding: original.binding
            )
        XCTAssertThrowsError(
            try binder.validateAndDecode(
                alternateBytesWithOriginalBinding
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeNeuralGateMutationSurfaceError,
                .invalidSurfaceBinding
            )
        }
    }

    private var codec:
        PrimeNativeNeuralGateCorrectedControlSurfaceCodec.Type
    {
        PrimeNativeNeuralGateCorrectedControlSurfaceCodec.self
    }

    private var binder:
        PrimeNativeNeuralGateCorrectedControlSurfaceBinder.Type
    {
        PrimeNativeNeuralGateCorrectedControlSurfaceBinder.self
    }

    private func baseline(
        seed: UInt32 = 1_618
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        try .baseline(
            commonCaptureScheduleReferenceSHA256: sha("a"),
            branchCaptureScheduleReferenceSHA256: sha("b"),
            replicateSeed: seed
        )
    }

    private func makeMaterial(
        seed: UInt32 = 1_618,
        cap: UInt16 = 64,
        targetValue: Bool = false,
        targetLength: Bool = false,
        expectedCompletionPresent: Bool = false,
        rowIDPresent: Bool = false,
        splitPresent: Bool = false,
        semanticFamilyPresent: Bool = false,
        promptGrouping:
            PrimeNativeNeuralGatePromptGroupingControl = .targetIndependent,
        decisionBudget:
            PrimeNativeNeuralGateDecisionBudgetControl = .fixedPolicy,
        eosAvailable: Bool = true,
        completionSupport:
            PrimeNativeNeuralGateCompletionSupportControl =
                .eosAndFullByteVocabulary,
        termination:
            PrimeNativeNeuralGateTerminationControl = .eosOrFixedCap,
        rowInclusion:
            PrimeNativeNeuralGateRowInclusionControl = .allSourceRows,
        seedScope:
            PrimeNativeNeuralGateReplicateSeedScopeControl = .replicate,
        rowState:
            PrimeNativeNeuralGateRowStateControl = .freshPerRow
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        try .init(
            commonCaptureScheduleReferenceSHA256: sha("a"),
            branchCaptureScheduleReferenceSHA256: sha("b"),
            targetValueAffectsRawIdentity: targetValue,
            targetLengthAffectsRawIdentity: targetLength,
            predictionExpectedCompletionPresent:
                expectedCompletionPresent,
            predictionRowIDPresent: rowIDPresent,
            predictionSplitPresent: splitPresent,
            predictionSemanticFamilyPresent:
                semanticFamilyPresent,
            promptGrouping: promptGrouping,
            decisionBudget: decisionBudget,
            eosAvailableAtEveryDecision: eosAvailable,
            completionSupport: completionSupport,
            fixedDecisionCap: cap,
            termination: termination,
            rowInclusion: rowInclusion,
            replicateSeed: seed,
            replicateSeedScope: seedScope,
            rowState: rowState
        )
    }

    private func assertDecodeFails(
        _ bytes: Data,
        as expected: PrimeNativeNeuralGateMutationSurfaceError,
        _ context: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try codec.decode(bytes),
            context,
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeNeuralGateMutationSurfaceError,
                expected,
                context,
                file: file,
                line: line
            )
        }
    }

    private func assertBindingFails(
        _ original:
            PrimeNativeNeuralGateBoundCorrectedControlSurface,
        binding:
            PrimeNativeNeuralGateCorrectedControlSurfaceBinding,
        _ context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let tampered =
            PrimeNativeNeuralGateBoundCorrectedControlSurface(
                bytes: original.bytes,
                binding: binding
            )
        XCTAssertThrowsError(
            try binder.validateAndDecode(tampered),
            context,
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeNeuralGateMutationSurfaceError,
                .invalidSurfaceBinding,
                context,
                file: file,
                line: line
            )
        }
    }

    private func replacingByte(
        _ data: Data,
        at offset: Int,
        with byte: UInt8
    ) -> Data {
        var copy = data
        copy[copy.index(copy.startIndex, offsetBy: offset)] = byte
        return copy
    }

    private func replacingASCII(
        _ data: Data,
        in offsets: Range<Int>,
        with replacement: String
    ) -> Data {
        precondition(replacement.utf8.count == offsets.count)
        var copy = data
        let lower = copy.index(
            copy.startIndex,
            offsetBy: offsets.lowerBound
        )
        let upper = copy.index(
            copy.startIndex,
            offsetBy: offsets.upperBound
        )
        copy.replaceSubrange(lower ..< upper, with: replacement.utf8)
        return copy
    }

    private func ascii(
        _ data: Data,
        _ offsets: Range<Int>
    ) -> String {
        let lower = data.index(
            data.startIndex,
            offsetBy: offsets.lowerBound
        )
        let upper = data.index(
            data.startIndex,
            offsetBy: offsets.upperBound
        )
        return String(decoding: data[lower ..< upper], as: UTF8.self)
    }

    private func changedSHA(_ value: String) -> String {
        let replacement = value.first == "a" ? "b" : "a"
        return replacement + value.dropFirst()
    }

    private func sha(_ character: Character) -> String {
        String(repeating: String(character), count: 64)
    }
}

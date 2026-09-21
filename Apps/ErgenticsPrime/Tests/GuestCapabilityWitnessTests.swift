import Foundation
import XCTest

// Fabricated, explicit byte frames only: no native API, guest execution,
// filesystem, image accessor, owner handle, or struct-memory serialization.
final class GuestCapabilityWitnessTests: XCTestCase {
    private typealias Witness = GuestCapabilityWitness
    private let generation: UInt64 = 7
    private let absent = UInt64(bitPattern: Int64(Int32.min))

    private func digest(_ hex: String) -> [UInt8] {
        let digits = Array(hex.utf8)
        func nibble(_ digit: UInt8) -> UInt8 { digit < 58 ? digit - 48 : digit - 87 }
        return stride(from: 0, to: digits.count, by: 2).map {
            nibble(digits[$0]) * 16 + nibble(digits[$0 + 1])
        }
    }

    private func word(_ value: UInt64) -> [UInt8] {
        (0..<8).map { UInt8(truncatingIfNeeded: value >> (8 * (7 - $0))) }
    }

    private func frame(profile: Witness.Profile = .rustBootstrap, entered: Int? = nil,
                       failedMap: Int? = nil, failure: Int32 = -17,
                       checkedTrap: Bool = true) -> Data {
        let rust = profile == .rustBootstrap
        let count = rust ? 4 : 3
        let next = entered ?? count
        let complete = next == count && failedMap == nil && checkedTrap
        let image = digest(rust
            ? "6e1b2a92646a69ef353491b2cde8104c6d6f311bc4d03bb8cb3bd5bb28f4dfa1"
            : "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44")
        let regions: [[UInt64]] = [
            [1, 0x10000000, 16384, 5], [2, 0x10004000, 16384, 1],
            [3, 0x10008000, 16384, 3], rust ? [4, 0x10010000, 16384, 3] : [0, 0, 0, 0]
        ]
        var bytes = Array("EPRCAP01".utf8)
        bytes += [1, profile.rawValue, generation, UInt64(count), rust ? 164 : 92].flatMap(word)
        bytes += image
        bytes += [0, 1, failedMap == nil ? 0 : 1].flatMap(word)
        for index in 0..<4 {
            let called = index < next
            let failed = index == failedMap
            let status = called ? (failed ? UInt64(bitPattern: Int64(failure)) : 0) : absent
            let unmapped = called && !failed
            bytes += regions[index].flatMap(word)
            bytes += (called ? regions[index] : [0, 0, 0, 0]).flatMap(word)
            bytes += [called ? 1 : 0, called ? 1 : 0, status,
                      unmapped ? 1 : 0, unmapped ? 1 : 0, unmapped ? 0 : absent].flatMap(word)
        }
        let pc: UInt64 = rust ? 0x10000060 : 0x10000050
        bytes += [0x1000c000, pc, 4, 1, rust ? 0x10014000 : 0x1000bff0,
                  UInt64(next), complete ? 1 : 0, complete ? 1 : 0, complete ? 1 : 0].flatMap(word)
        bytes += (complete ? [1, 0x93840044, pc, 0x1000c000, 0x1000c000, 1] : [0, 0, 0, 0, 0, 0]).flatMap(word)
        bytes += word(1)
        return Data(bytes)
    }

    private func replacing(_ data: Data, wordAt offset: Int, with value: UInt64) -> Data {
        var result = data
        result.replaceSubrange(offset..<(offset + 8), with: word(value))
        return result
    }

    private func decode(_ bytes: Data, profile: Witness.Profile = .rustBootstrap) throws -> Witness.Observation {
        try Witness.decode(bytes, expectedProfile: profile, expectedGeneration: generation)
    }

    private func rejected(_ bytes: Data, profile: Witness.Profile = .rustBootstrap,
                          file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try decode(bytes, profile: profile), file: file, line: line)
    }

    // A separate writer reconstructs the frame from decoded fields, using its
    // own byte-emission loop. It does not use the decoder or C producer helpers.
    private func reencode(_ observation: Witness.Observation) -> Data {
        var bytes = Data("EPRCAP01".utf8)
        func put(_ value: UInt64) {
            for shift in stride(from: 56, through: 0, by: -8) {
                bytes.append(UInt8(truncatingIfNeeded: value >> shift))
            }
        }
        func flag(_ value: Bool) { put(value ? 1 : 0) }
        func status(_ value: Int32) { put(UInt64(bitPattern: Int64(value))) }
        func region(_ value: Witness.Region) {
            put(value.object); put(value.ipa); put(value.length); put(value.rights)
        }
        put(observation.version); put(observation.profile.rawValue); put(observation.generation)
        put(UInt64(observation.regionCount)); put(observation.imageSize)
        bytes.append(observation.imageDigest)
        put(observation.architecturalChannels); flag(observation.planAdmissionReported); flag(observation.poisoned)
        for mapping in observation.mappings {
            region(mapping.planned); region(mapping.arguments)
            flag(mapping.entered); flag(mapping.returned); status(mapping.status)
            flag(mapping.unmapEntered); flag(mapping.unmapReturned); status(mapping.unmapStatus)
        }
        put(observation.endpoint); put(observation.plannedPC); put(observation.width)
        put(observation.plannedValue); put(observation.stackTop); put(UInt64(observation.next))
        flag(observation.runEntered); flag(observation.trapChecked); flag(observation.trapMatched)
        put(observation.terminal.reason); put(observation.terminal.syndrome); put(observation.terminal.pc)
        put(observation.terminal.ipa); put(observation.terminal.va); put(observation.terminal.value)
        flag(observation.conservationReported)
        return bytes
    }

    func testBothCompleteProfilesAndEveryAllowedFaultLevelRoundTrip() throws {
        let faultLevels: ClosedRange<UInt64> = 4...7
        for profile in Witness.Profile.allCases {
            for dfsc in faultLevels {
                let bytes = replacing(frame(profile: profile), wordAt: 632, with: 0x93840040 | dfsc)
                let observation = try decode(bytes, profile: profile)
                XCTAssertEqual(bytes.count, 680)
                XCTAssertEqual(observation.mechanicsStatus, .matched)
                XCTAssertEqual(observation.imageStatus, .pinnedDigest)
                XCTAssertEqual(observation.architecturalChannels, 0)
                XCTAssertEqual(observation.regionCount, profile == .baseline ? 3 : 4)
                XCTAssertEqual(observation.next, observation.regionCount)
                XCTAssertEqual(reencode(observation), bytes)
            }
        }
    }

    func testTruthfulEarlyAdmissionAndCompletedPrefixesRemainIncomplete() throws {
        for profile in Witness.Profile.allCases {
            let count = profile == .baseline ? 3 : 4
            for next in 0...count {
                let bytes = frame(profile: profile, entered: next, checkedTrap: false)
                let observation = try decode(bytes, profile: profile)
                XCTAssertEqual(observation.mechanicsStatus, .incomplete)
                XCTAssertEqual(reencode(observation), bytes)
            }
            var bytes = frame(profile: profile, entered: 0, checkedTrap: false)
            bytes.replaceSubrange(48..<80, with: [UInt8](repeating: 0, count: 32))
            let admissionValues: [UInt64] = [0, 1]
            for admitted in admissionValues {
                let early = replacing(bytes, wordAt: 88, with: admitted)
                let observation = try decode(early, profile: profile)
                XCTAssertEqual(observation.mechanicsStatus, .incomplete)
                XCTAssertEqual(observation.imageStatus, .notRecorded)
                XCTAssertEqual(reencode(observation), early)
            }
        }
    }

    func testEveryMappingFailureIncludingReturnedSentinelIsRetained() throws {
        let failures: [Int32] = [-17, .min, .max]
        for profile in Witness.Profile.allCases {
            for index in 0..<(profile == .baseline ? 3 : 4) {
                for failure in failures {
                    let bytes = frame(profile: profile, entered: index + 1, failedMap: index, failure: failure)
                    let observation = try decode(bytes, profile: profile)
                    XCTAssertEqual(observation.mechanicsStatus, .failed)
                    XCTAssertEqual(observation.mappings[index].status, failure)
                    XCTAssertTrue(observation.mappings[index].returned)
                    XCTAssertFalse(observation.runEntered)
                    XCTAssertEqual(reencode(observation), bytes)
                }
            }
        }
    }

    func testFailedUnmapMayBeConservedButNeverMechanicsMatched() throws {
        let failures: [Int32] = [-9, .min]
        for failure in failures {
            let bytes = replacing(frame(), wordAt: 208, with: UInt64(bitPattern: Int64(failure)))
            let observation = try decode(bytes)
            XCTAssertTrue(observation.conservationReported)
            XCTAssertFalse(observation.poisoned)
            XCTAssertEqual(observation.mechanicsStatus, .failed)
            XCTAssertEqual(reencode(observation), bytes)
        }
        let notConserved = try decode(replacing(frame(), wordAt: 672, with: 0))
        XCTAssertEqual(notConserved.mechanicsStatus, .failed)
    }

    func testWrongTerminalPreservedOnlyWithTruthfulFailureFlags() throws {
        let mutations: [(Int, UInt64)] = [
            (624, 0), (632, 0x93840040), (640, 0x10000064),
            (648, 0x1000c004), (656, 0x1000c004), (664, 0)
        ]
        for (offset, value) in mutations {
            var bytes = replacing(frame(), wordAt: offset, with: value)
            rejected(bytes) // Wrong field with a fabricated successful match.
            bytes = replacing(bytes, wordAt: 616, with: 0)
            rejected(bytes) // Mismatch must also retain the sticky poison.
            bytes = replacing(bytes, wordAt: 96, with: 1)
            let observation = try decode(bytes)
            XCTAssertEqual(observation.mechanicsStatus, .failed)
            XCTAssertFalse(observation.trapMatched)
            XCTAssertEqual(reencode(observation), bytes)
        }
        var falseMismatch = replacing(frame(), wordAt: 616, with: 0)
        falseMismatch = replacing(falseMismatch, wordAt: 96, with: 1)
        rejected(falseMismatch) // Correct terminal cannot claim it mismatched.
    }

    func testRejectsLengthMagicAndWrongEndian() {
        let bytes = frame()
        for count in [0, 7, 8, 679] { rejected(Data(bytes.prefix(count))) }
        rejected(bytes + Data([0]))
        var badMagic = bytes
        badMagic[0] ^= 1
        rejected(badMagic)
        var littleEndianVersion = bytes
        littleEndianVersion.replaceSubrange(8..<16, with: bytes[8..<16].reversed())
        rejected(littleEndianVersion)
    }

    func testRejectsSchemaProfileGenerationAndImageMutations() {
        let changes: [(Int, UInt64)] = [
            (8, 0), (8, 2), (16, 0), (16, 1), (16, 3), (24, 0), (24, 8),
            (32, 3), (32, 5), (40, 92), (40, 165), (80, 1)
        ]
        for (offset, value) in changes { rejected(replacing(frame(), wordAt: offset, with: value)) }
        XCTAssertThrowsError(try Witness.decode(frame(), expectedProfile: .baseline, expectedGeneration: generation))
        XCTAssertThrowsError(try Witness.decode(frame(), expectedProfile: .rustBootstrap, expectedGeneration: 0))
        var wrongDigest = frame()
        wrongDigest[48] ^= 1
        rejected(wrongDigest)
        wrongDigest.replaceSubrange(48..<80, with: [UInt8](repeating: 0, count: 32))
        rejected(wrongDigest) // No native mapping can follow an unrecorded image.
    }

    func testRejectsExtraObjectsRightsAliasesAndAlteredFixedPlan() {
        let changes: [(Int, UInt64)] = [
            (104, 5), (112, 0x1000c000), (120, UInt64.max), (128, 7),
            (136, 5), (144, 0x10004000), (152, 1), (160, 1),
            (552, 0x10008000), (560, 0x10000050), (568, 8), (576, 2), (584, 0)
        ]
        for (offset, value) in changes { rejected(replacing(frame(), wordAt: offset, with: value)) }
        rejected(replacing(frame(profile: .baseline), wordAt: 440, with: 4), profile: .baseline)
        rejected(replacing(frame(profile: .baseline), wordAt: 472, with: 4), profile: .baseline)
    }

    func testRejectsNonBooleanFlagsAndNoncanonicalSignedStatuses() {
        var flagOffsets = [88, 96, 600, 608, 616, 672]
        var statusOffsets: [Int] = []
        for index in 0..<4 {
            let base = 104 + 112 * index
            flagOffsets += [base + 64, base + 72, base + 88, base + 96]
            statusOffsets += [base + 80, base + 104]
        }
        for offset in flagOffsets { rejected(replacing(frame(), wordAt: offset, with: 2)) }
        let noncanonicalStatuses: [UInt64] = [
            0x00000000ffffffff, 0x0000000080000000, 0xffffffff00000000, 0x100000000
        ]
        for offset in statusOffsets {
            for value in noncanonicalStatuses {
                rejected(replacing(frame(), wordAt: offset, with: value))
            }
        }
    }

    func testRejectsInventedSuccessfulCallsAndBrokenMappingOrder() {
        let empty = frame(entered: 0, checkedTrap: false)
        rejected(replacing(empty, wordAt: 184, with: 0)) // No entry/return, fake success.
        rejected(replacing(empty, wordAt: 176, with: 1)) // Return without entry.
        rejected(replacing(empty, wordAt: 136, with: 1)) // Arguments without entry.
        rejected(replacing(frame(), wordAt: 168, with: 0))
        rejected(replacing(frame(), wordAt: 592, with: 3))
        rejected(replacing(frame(), wordAt: 592, with: UInt64.max))
        var afterFailure = replacing(frame(), wordAt: 184, with: UInt64(bitPattern: Int64(-17)))
        afterFailure = replacing(afterFailure, wordAt: 96, with: 1)
        rejected(afterFailure) // Later maps cannot follow a failed earlier map.
        let firstFailure = frame(entered: 1, failedMap: 0)
        rejected(replacing(firstFailure, wordAt: 96, with: 0)) // Failure poison cannot disappear.
        rejected(replacing(frame(), wordAt: 88, with: 0)) // Run cannot manufacture admission.
    }

    func testRejectsUnmapOrderAndIncompleteConservationClaims() {
        var bytes = replacing(frame(), wordAt: 192, with: 0)
        bytes = replacing(bytes, wordAt: 200, with: 0)
        bytes = replacing(bytes, wordAt: 208, with: absent)
        rejected(bytes) // Later unmap entered before the first returned.
        var failedMap = frame(entered: 1, failedMap: 0)
        failedMap = replacing(failedMap, wordAt: 192, with: 1)
        failedMap = replacing(failedMap, wordAt: 200, with: 1)
        failedMap = replacing(failedMap, wordAt: 208, with: 0)
        rejected(failedMap) // An unsuccessful map cannot be unmapped.
        var prefix = frame(entered: 1, checkedTrap: false)
        prefix = replacing(prefix, wordAt: 192, with: 0)
        prefix = replacing(prefix, wordAt: 200, with: 0)
        prefix = replacing(prefix, wordAt: 208, with: absent)
        rejected(prefix) // Reported conservation must retain cleanup entries.
    }

    func testRejectsInventedOrUncheckedTerminal() {
        rejected(replacing(frame(), wordAt: 600, with: 0))
        rejected(replacing(frame(), wordAt: 608, with: 0))
        let empty = frame(entered: 0, checkedTrap: false)
        rejected(replacing(empty, wordAt: 600, with: 1))
        rejected(replacing(empty, wordAt: 616, with: 1))
        rejected(replacing(empty, wordAt: 640, with: 0x10000060))
    }
}

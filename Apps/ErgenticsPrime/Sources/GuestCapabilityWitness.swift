import Foundation

/// Independent decoder for the fixed EPRCAP01 observation, not an admission,
/// restore, capability-grant, or guest-result verification API. Even a matched
/// fabricated frame is only a structurally consistent diagnostic. This frame
/// does not carry all VM/vCPU/watchdog/host-memory teardown statuses, signing,
/// cancellation, reply contents, or evidence of architectural-channel closure.
enum GuestCapabilityWitness {
    static let byteCount = 680

    enum Profile: UInt64, CaseIterable, Sendable {
        case baseline = 1
        case rustBootstrap = 2
    }

    enum MechanicsStatus: String, Sendable {
        /// All represented calls and the terminal predicate match; the native
        /// conservation claim is present. This is not the guest result PASS.
        case matched
        case failed
        case incomplete
    }

    enum ImageStatus: Equatable, Sendable {
        case pinnedDigest
        /// The native early-admission path may return before computing SHA256.
        case notRecorded
    }

    enum DecodeError: Error, Equatable {
        case invalid(String)
    }

    struct Region: Equatable, Sendable {
        let object: UInt64
        let ipa: UInt64
        let length: UInt64
        let rights: UInt64
    }

    struct Mapping: Equatable, Sendable {
        let planned: Region
        let arguments: Region
        let entered: Bool
        let returned: Bool
        let status: Int32
        let unmapEntered: Bool
        let unmapReturned: Bool
        let unmapStatus: Int32
    }

    struct Terminal: Equatable, Sendable {
        let reason: UInt64
        let syndrome: UInt64
        let pc: UInt64
        let ipa: UInt64
        let va: UInt64
        let value: UInt64
    }

    struct Observation: Equatable, Sendable {
        let version: UInt64
        let profile: Profile
        let generation: UInt64
        let regionCount: Int
        let imageSize: UInt64
        let imageDigest: Data
        let imageStatus: ImageStatus
        /// Zero means UNASSESSED, not denied, absent, or invisible.
        let architecturalChannels: UInt64
        let planAdmissionReported: Bool
        let poisoned: Bool
        /// Always four slots, including the canonical unused baseline slot.
        let mappings: [Mapping]
        let endpoint: UInt64
        let plannedPC: UInt64
        let width: UInt64
        let plannedValue: UInt64
        let stackTop: UInt64
        let next: Int
        let runEntered: Bool
        let trapChecked: Bool
        let trapMatched: Bool
        let terminal: Terminal
        /// Producer claim: this frame cannot independently prove conservation.
        let conservationReported: Bool
        let mechanicsStatus: MechanicsStatus

        fileprivate init(version: UInt64, profile: Profile, generation: UInt64,
                         regionCount: Int, imageSize: UInt64, imageDigest: Data,
                         imageStatus: ImageStatus, architecturalChannels: UInt64,
                         planAdmissionReported: Bool, poisoned: Bool, mappings: [Mapping],
                         endpoint: UInt64, plannedPC: UInt64, width: UInt64,
                         plannedValue: UInt64, stackTop: UInt64, next: Int,
                         runEntered: Bool, trapChecked: Bool, trapMatched: Bool,
                         terminal: Terminal, conservationReported: Bool,
                         mechanicsStatus: MechanicsStatus) {
            self.version = version
            self.profile = profile
            self.generation = generation
            self.regionCount = regionCount
            self.imageSize = imageSize
            self.imageDigest = imageDigest
            self.imageStatus = imageStatus
            self.architecturalChannels = architecturalChannels
            self.planAdmissionReported = planAdmissionReported
            self.poisoned = poisoned
            self.mappings = mappings
            self.endpoint = endpoint
            self.plannedPC = plannedPC
            self.width = width
            self.plannedValue = plannedValue
            self.stackTop = stackTop
            self.next = next
            self.runEntered = runEntered
            self.trapChecked = trapChecked
            self.trapMatched = trapMatched
            self.terminal = terminal
            self.conservationReported = conservationReported
            self.mechanicsStatus = mechanicsStatus
        }
    }

    /// Expected profile/generation must come from the caller's retained run
    /// context. Equality here does not establish that context's authenticity,
    /// freshness, ownership, or the origin of these readily fabricated bytes.
    static func decode(_ frame: Data, expectedProfile: Profile,
                       expectedGeneration: UInt64) throws -> Observation {
        try require(frame.count == byteCount, "frame.byteCount")
        var reader = Reader(bytes: Array(frame))
        try require(try reader.bytes(8) == Array("EPRCAP01".utf8), "frame.magic")
        let version = try reader.word()
        let rawProfile = try reader.word()
        let generation = try reader.word()
        let count = try reader.word()
        let imageSize = try reader.word()
        let imageDigest = try reader.bytes(32)
        let architecturalChannels = try reader.word()
        let admitted = try reader.flag("plan.admitted")
        let poisoned = try reader.flag("trace.poisoned")
        try require(version == 1, "plan.version")
        try require(rawProfile == expectedProfile.rawValue, "plan.profile")
        try require(expectedGeneration != 0 && generation == expectedGeneration, "plan.generation")
        let profile = expectedProfile
        let regionCount = profile == .baseline ? 3 : 4
        try require(count == UInt64(regionCount), "plan.regionCount")
        try require(architecturalChannels == 0, "plan.architecturalChannels.unassessed")
        try require(imageSize == (profile == .baseline ? 92 : 164), "image.size")
        let expectedDigest = profile == .baseline ? baselineDigest : rustDigest
        let pinnedImage = imageDigest == expectedDigest
        let emptyImage = imageDigest.allSatisfy { $0 == 0 }
        try require(pinnedImage || emptyImage, "image.digest")

        var mappings: [Mapping] = []
        for index in 0..<4 {
            let planned = try reader.region()
            let arguments = try reader.region()
            let entered = try reader.flag("map[\(index)].entered")
            let returned = try reader.flag("map[\(index)].returned")
            let status = try reader.status("map[\(index)].status")
            let unmapEntered = try reader.flag("unmap[\(index)].entered")
            let unmapReturned = try reader.flag("unmap[\(index)].returned")
            let unmapStatus = try reader.status("unmap[\(index)].status")
            try require(planned == fixedRegion(index, profile: profile), "map[\(index)].planned")
            mappings.append(Mapping(planned: planned, arguments: arguments, entered: entered,
                                    returned: returned, status: status, unmapEntered: unmapEntered,
                                    unmapReturned: unmapReturned, unmapStatus: unmapStatus))
        }
        let endpoint = try reader.word()
        let plannedPC = try reader.word()
        let width = try reader.word()
        let plannedValue = try reader.word()
        let stackTop = try reader.word()
        let rawNext = try reader.word()
        let runEntered = try reader.flag("trace.runEntered")
        let trapChecked = try reader.flag("trace.trapChecked")
        let trapMatched = try reader.flag("trace.trapMatched")
        let terminal = try reader.terminal()
        let conserved = try reader.flag("trace.conserved")
        try require(reader.offset == byteCount, "frame.end")
        try require(endpoint == 0x1000c000, "plan.endpoint")
        try require(plannedPC == (profile == .baseline ? 0x10000050 : 0x10000060), "plan.pc")
        try require(width == 4 && plannedValue == 1, "plan.store")
        try require(stackTop == (profile == .baseline ? 0x1000bff0 : 0x10014000), "plan.stackTop")
        try require(rawNext <= count, "trace.next.bound")
        let next = Int(rawNext)
        let allMapped = next == regionCount && mappings.prefix(regionCount).allSatisfy {
            $0.entered && $0.returned && $0.status == 0
        }

        for (index, map) in mappings.enumerated() {
            try require(map.entered == (index < next), "map[\(index)].orderedPrefix")
            try callFlags(entered: map.entered, returned: map.returned,
                          status: map.status, name: "map[\(index)]")
            try callFlags(entered: map.unmapEntered, returned: map.unmapReturned,
                          status: map.unmapStatus, name: "unmap[\(index)]")
            if map.entered {
                try require(admitted && pinnedImage, "map[\(index)].admittedImage")
                try require(map.arguments == map.planned, "map[\(index)].arguments")
                if index > 0 {
                    let prior = mappings[index - 1]
                    try require(prior.returned && prior.status == 0, "map[\(index)].priorSuccess")
                }
                if map.returned && map.status != 0 {
                    try require(poisoned, "map[\(index)].failurePoisons")
                }
            } else {
                try require(map.arguments == zeroRegion, "map[\(index)].unenteredArguments")
            }
            if map.unmapEntered {
                try require(map.returned && map.status == 0, "unmap[\(index)].mapped")
                try require(mappings.prefix(next).allSatisfy(\.returned), "unmap[\(index)].mapsReturned")
                for prior in mappings.prefix(index) where prior.returned && prior.status == 0 {
                    try require(prior.unmapReturned, "unmap[\(index)].orderedPrefix")
                }
            }
            if conserved {
                try require(!map.entered || map.returned, "map[\(index)].pendingConservation")
                try require(!map.unmapEntered || map.unmapReturned, "unmap[\(index)].pendingConservation")
                if map.returned && map.status == 0 {
                    // Failed unmap is permitted: successful VM destruction may
                    // still conserve it. Such a frame remains mechanics failed.
                    try require(map.unmapReturned, "unmap[\(index)].conservationPrefix")
                }
            }
        }
        if !admitted {
            try require(emptyImage && next == 0 && !runEntered && !trapChecked && !poisoned,
                        "plan.unadmittedPrefix")
        }
        if emptyImage {
            try require(next == 0 && !runEntered && !trapChecked, "image.unrecordedPrefix")
        }
        if runEntered {
            try require(admitted && pinnedImage && allMapped, "trace.runRequiresMappings")
        }
        let dfsc = terminal.syndrome & 63
        let exactTerminal = terminal.reason == 1 &&
            terminal.syndrome == (0x93840040 | dfsc) && (4...7).contains(dfsc) &&
            terminal.pc == plannedPC && terminal.ipa == endpoint &&
            terminal.va == endpoint && terminal.value == plannedValue
        if trapChecked {
            try require(runEntered, "trace.trapRequiresRun")
            try require(trapMatched == exactTerminal, "trace.terminalPredicate")
            try require(trapMatched || poisoned, "trace.trapFailurePoisons")
        } else {
            try require(!trapMatched && terminal == zeroTerminal, "trace.uncheckedTerminal")
        }

        let failedCall = mappings.contains {
            ($0.returned && $0.status != 0) || ($0.unmapReturned && $0.unmapStatus != 0)
        }
        let allUnmapped = mappings.prefix(regionCount).allSatisfy {
            $0.unmapEntered && $0.unmapReturned && $0.unmapStatus == 0
        }
        let mechanicsStatus: MechanicsStatus
        if poisoned || failedCall || !conserved {
            mechanicsStatus = .failed
        } else if admitted && pinnedImage && allMapped && runEntered && trapChecked &&
                    trapMatched && allUnmapped {
            mechanicsStatus = .matched
        } else {
            mechanicsStatus = .incomplete
        }
        return Observation(version: version, profile: profile, generation: generation,
                           regionCount: regionCount, imageSize: imageSize,
                           imageDigest: Data(imageDigest), imageStatus: pinnedImage ? .pinnedDigest : .notRecorded,
                           architecturalChannels: architecturalChannels, planAdmissionReported: admitted,
                           poisoned: poisoned, mappings: mappings, endpoint: endpoint,
                           plannedPC: plannedPC, width: width, plannedValue: plannedValue, stackTop: stackTop,
                           next: next, runEntered: runEntered, trapChecked: trapChecked, trapMatched: trapMatched,
                           terminal: terminal, conservationReported: conserved, mechanicsStatus: mechanicsStatus)
    }

    private static func callFlags(entered: Bool, returned: Bool, status: Int32, name: String) throws {
        try require(!returned || entered, "\(name).returnRequiresEntry")
        // The flags, not the sentinel alone, establish call presence. A real
        // return of INT32_MIN is retained as a nonzero failure, never success.
        try require(returned || status == Int32.min, "\(name).statusPresence")
    }

    private static func require(_ condition: Bool, _ predicate: String) throws {
        if !condition { throw DecodeError.invalid(predicate) }
    }

    private static let zeroRegion = Region(object: 0, ipa: 0, length: 0, rights: 0)
    private static let zeroTerminal = Terminal(reason: 0, syndrome: 0, pc: 0, ipa: 0, va: 0, value: 0)

    private static func fixedRegion(_ index: Int, profile: Profile) -> Region {
        switch index {
        case 0: return Region(object: 1, ipa: 0x10000000, length: 16384, rights: 5)
        case 1: return Region(object: 2, ipa: 0x10004000, length: 16384, rights: 1)
        case 2: return Region(object: 3, ipa: 0x10008000, length: 16384, rights: 3)
        case 3 where profile == .rustBootstrap:
            return Region(object: 4, ipa: 0x10010000, length: 16384, rights: 3)
        default: return zeroRegion
        }
    }

    // Literal independent pins, not values requested from the native producer.
    private static let baselineDigest: [UInt8] = [
        0x67, 0x29, 0x0a, 0x73, 0xb5, 0x30, 0x47, 0x37,
        0x40, 0x96, 0x14, 0x23, 0x56, 0xa3, 0x53, 0x38,
        0xf6, 0x72, 0x2d, 0x72, 0x45, 0x86, 0xcc, 0x10,
        0x37, 0x3d, 0xfe, 0xca, 0xb9, 0xa4, 0xcc, 0x44
    ]
    private static let rustDigest: [UInt8] = [
        0x6e, 0x1b, 0x2a, 0x92, 0x64, 0x6a, 0x69, 0xef,
        0x35, 0x34, 0x91, 0xb2, 0xcd, 0xe8, 0x10, 0x4c,
        0x6d, 0x6f, 0x31, 0x1b, 0xc4, 0xd0, 0x3b, 0xb8,
        0xcb, 0x3b, 0xd5, 0xbb, 0x28, 0xf4, 0xdf, 0xa1
    ]

    private struct Reader {
        let bytes: [UInt8]
        var offset = 0

        mutating func bytes(_ count: Int) throws -> [UInt8] {
            try require(count >= 0 && offset <= bytes.count && count <= bytes.count - offset,
                        "frame.truncated")
            defer { offset += count }
            return Array(bytes[offset..<(offset + count)])
        }

        mutating func word() throws -> UInt64 {
            let octets = try bytes(8)
            return octets.reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
        }

        mutating func flag(_ name: String) throws -> Bool {
            let raw = try word()
            try require(raw <= 1, "\(name).boolean")
            return raw == 1
        }

        mutating func status(_ name: String) throws -> Int32 {
            let raw = try word()
            let value = Int32(truncatingIfNeeded: raw)
            try require(raw == UInt64(bitPattern: Int64(value)), "\(name).signed32")
            return value
        }

        mutating func region() throws -> Region {
            try Region(object: word(), ipa: word(), length: word(), rights: word())
        }

        mutating func terminal() throws -> Terminal {
            try Terminal(reason: word(), syndrome: word(), pc: word(), ipa: word(), va: word(), value: word())
        }
    }
}

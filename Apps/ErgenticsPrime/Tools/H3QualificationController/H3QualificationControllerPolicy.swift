#if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
import Foundation

/// Deep values only. Effect owners supply observations; this type never samples a clock
/// or operates a process, descriptor, signature, or filesystem object.
enum H3QualificationControllerFailure: Error, Equatable {
    case invalidArguments
    case rejected(String)
    case system(String, Int32)
    case containmentUnproven
    case durability
}

/// Pure decoding of the pinned Darwin sys/wait.h terminal encodings. The low
/// seven bits hold a signal, bit seven is WCOREFLAG, and the next byte holds an
/// exit code. No filler bits or stopped/continued status proves a terminal reap.
enum H3QualificationTerminalWaitStatus: Equatable, Sendable {
    case exited(Int32)
    case signaled(signal: Int32, coreDumped: Bool)

    init?(rawValue: Int32) {
        guard rawValue >= 0 else { return nil }
        let signal = rawValue & 0x7f
        if signal == 0 {
            guard rawValue & ~0xff00 == 0 else { return nil }
            self = .exited((rawValue >> 8) & 0xff)
        } else {
            // The pinned Darwin SDK has NSIG == 32. W_STOPPED == 0x7f,
            // including WIFCONTINUED's 0x137f, is never a terminal encoding.
            guard signal < 32, rawValue & ~0xff == 0 else { return nil }
            self = .signaled(signal: signal, coreDumped: rawValue & 0x80 != 0)
        }
    }
}

/// Copied-value joins at the existing executable/Security observation sites.
/// There is deliberately no observation callback or replacement-prevention claim:
/// equal samples cannot identify the child's unobserved mapped vnode.
enum H3QualificationPathIdentityPolicy {
    static func codeObjectPath(_ observed: String?, expected: String) -> Bool {
        observed == expected
    }

    static func executablePath(_ observed: String?, expected: String) -> Bool {
        observed == expected
    }

    static func snapshot<Snapshot: Equatable>(_ observed: Snapshot, matches original: Snapshot) -> Bool {
        observed == original
    }

    static func pair<Snapshot: Equatable>(original: Snapshot, held: Snapshot, named: Snapshot) -> Bool {
        snapshot(held, matches: original) && snapshot(named, matches: original)
    }

    static func dynamicCode(_ observed: H3QualificationJSONValue,
                            expected: H3QualificationJSONValue) throws -> Bool {
        try H3QualificationProtocol.sameCodeIdentity(observed, expected)
    }

    static func preGate<Snapshot: Equatable>(original: Snapshot, held: Snapshot, named: Snapshot,
        processPath: String, executablePath expectedPath: String) -> Bool {
        pair(original: original, held: held, named: named) && executablePath(processPath, expected: expectedPath)
    }

    static func terminal<Snapshot: Equatable>(original: Snapshot, heldGate: Snapshot, namedGate: Snapshot,
        heldTerminal: Snapshot, namedTerminal: Snapshot, preStatic: H3QualificationJSONValue,
        dynamic: H3QualificationJSONValue, postStatic: H3QualificationJSONValue,
        processPath: String, executablePath expectedPath: String) throws -> Bool {
        try H3QualificationProtocol.sameCodeIdentity(postStatic, preStatic) &&
            H3QualificationProtocol.sameCodeIdentity(dynamic, preStatic) &&
            preGate(original: original, held: heldGate, named: namedGate,
                    processPath: processPath, executablePath: expectedPath) &&
            pair(original: original, held: heldTerminal, named: namedTerminal)
    }
}

struct H3QualificationControllerPolicy: Sendable {
    enum WaitObservation: Equatable, Sendable {
        case live
        case reaped(Int32)
        case terminalUncertain(Int32)
        case interrupted
        case failed(Int32)
    }
    private(set) var ordinaryWaits = 0
    private(set) var interruptedWaits = 0
    private(set) var gateAttempted = false
    private(set) var cancellationAttempted = false
    private(set) var killAttempted = false
    private(set) var terminalStatus: Int32?
    private(set) var terminalObservationUncertain = false
    private(set) var waitFailed = false
    private(set) var waitCapExhausted = false

    mutating func observe(_ observation: WaitObservation) -> Bool {
        guard terminalStatus == nil, !terminalObservationUncertain else { return false }
        switch observation {
        case .interrupted:
            guard interruptedWaits < 64 else { waitFailed = true; waitCapExhausted = true; return false }
            interruptedWaits += 1
        case .live:
            guard ordinaryWaits < 4096 else { waitFailed = true; waitCapExhausted = true; return false }
            ordinaryWaits += 1
        case .reaped(let status):
            guard H3QualificationTerminalWaitStatus(rawValue: status) != nil else {
                return rejectTerminalObservation()
            }
            guard ordinaryWaits < 4096 else { waitFailed = true; waitCapExhausted = true; return false }
            ordinaryWaits += 1
            terminalStatus = status
        case .terminalUncertain:
            return rejectTerminalObservation()
        case .failed:
            guard ordinaryWaits < 4096 else { waitFailed = true; waitCapExhausted = true; return false }
            ordinaryWaits += 1
            waitFailed = true
        }
        return true
    }

    private mutating func rejectTerminalObservation() -> Bool {
        // An exact-PID return may already have consumed the child's reap.
        // Its identity cannot be recovered from a later numeric-PID result.
        // Even an out-of-budget supplied value must not revive that authority.
        waitFailed = true
        terminalObservationUncertain = true
        if ordinaryWaits < 4096 && interruptedWaits < 64 && !waitCapExhausted {
            ordinaryWaits += 1
        } else { waitCapExhausted = true }
        return false
    }

    var canObserveWait: Bool {
        terminalStatus == nil && !terminalObservationUncertain &&
            ordinaryWaits < 4096 && interruptedWaits < 64 && !waitCapExhausted
    }

    mutating func claimGate(immediateWait: WaitObservation, beforeDeadline: Bool) -> Bool {
        guard !gateAttempted, !waitFailed, terminalStatus == nil, !terminalObservationUncertain,
              immediateWait == .live, beforeDeadline else { return false }
        gateAttempted = true
        return true
    }

    mutating func claimCancellation(immediateWait: WaitObservation, eligible: Bool) -> Bool {
        guard !cancellationAttempted, terminalStatus == nil, !terminalObservationUncertain,
              immediateWait == .live, eligible else { return false }
        cancellationAttempted = true
        return true
    }

    mutating func claimKill(immediateWait: WaitObservation, eligible: Bool) -> Bool {
        guard !killAttempted, terminalStatus == nil, !terminalObservationUncertain,
              immediateWait == .live, eligible else { return false }
        killAttempted = true
        return true
    }
}

/// The controller's exact existing two-argument grammar. All strings are values;
/// this selection neither resolves a pathname nor observes the host architecture.
struct H3QualificationControllerInvocation: Equatable, Sendable {
    let mode: H3QualificationMode
    let configuration: H3QualificationConfiguration
    let verifying: Bool
    let campaignRoot: String
    let selectedRoot: String

    init(arguments: [String], configuration: H3QualificationConfiguration) throws {
        guard arguments.count == 2 else { throw H3QualificationControllerFailure.invalidArguments }
        let mode: H3QualificationMode
        let verifying: Bool
        switch arguments[0] {
        case "--admission-only": mode = .admissionOnly; verifying = false
        case "--guest": mode = .guest; verifying = false
        case "--verify-admission-campaign": mode = .admissionOnly; verifying = true
        case "--verify-guest-campaign": mode = .guest; verifying = true
        default: throw H3QualificationControllerFailure.invalidArguments
        }
        let campaign = mode == .admissionOnly ? "/private/tmp/ergentics-h3q-admission-campaign-v1" :
            "/private/tmp/ergentics-h3q-guest-campaign-v1"
        let expected = campaign + (verifying ? "" : configuration == .debug ? "/debug" : "/release")
        guard arguments[1] == expected, !verifying || configuration == .release else {
            throw H3QualificationControllerFailure.invalidArguments
        }
        self.mode = mode; self.configuration = configuration; self.verifying = verifying
        campaignRoot = campaign; selectedRoot = expected
    }
}

/// Only the scalar part of the controller's regular-file admission. The actual
/// descriptor and stat/uid observations remain in the controller-only adapter.
enum H3QualificationRegularReadAdmission {
    struct Value: Equatable, Sendable {
        var mode: UInt16
        var owner: UInt32
        var links: UInt16
        var size: Int64
        var device: Int32
    }
    // Pinned Darwin SDK sys/_types/_s_ifmt.h: S_IFMT=0170000, S_IFREG=0100000.
    static func isRegular(mode: UInt16) -> Bool { mode & 0o170000 == 0o100000 }

    static func validate(_ value: Value, maximum: Int, expectedOwner: UInt32,
                         device: Int32?, executable: Bool = false) throws {
        guard isRegular(mode: value.mode), value.owner == expectedOwner,
              value.links == 1, value.size >= (executable ? 1 : 0), value.size <= Int64(maximum),
              device == nil || value.device == device,
              executable || value.mode & 0o7777 == 0o600 else {
            throw H3QualificationControllerFailure.rejected("regular leaf policy")
        }
    }
}

/// Production-used read accounting over fabricated-or-real scalar observations.
/// No bytes, descriptor, syscall, clock or filesystem operation is owned here.
struct H3QualificationReadPolicy: Sendable {
    enum Consumption: Equatable, Sendable {
        case interrupted
        case bytes(digest: Int, retained: Int)
        case eof
    }
    let expected: Int
    let callLimit: Int
    let retainsWholeInput: Bool
    let retainsExecutablePrefix: Bool
    private(set) var offset = 0
    private(set) var calls = 0
    private(set) var interruptions = 0
    private(set) var retainedByteCount = 0
    private(set) var eof = false
    private(set) var failure: H3QualificationControllerFailure?
    private var pendingRequest: Int?

    init(expected: Int, executable: Bool, retain: Bool) throws {
        let limit = expected.addingReportingOverflow(65)
        guard expected >= 0, !limit.overflow else {
            throw H3QualificationControllerFailure.rejected("read call bound")
        }
        self.expected = expected; callLimit = limit.partialValue
        retainsWholeInput = retain; retainsExecutablePrefix = executable && !retain
    }

    mutating func nextRequest() throws -> Int {
        if let failure { throw failure }
        guard !eof, pendingRequest == nil else { throw latch(.rejected("read observation order")) }
        // Preserve the existing Swift boundary: the 64th interruption is
        // observed, then the following read is denied. This is not Ruby's
        // distinct allowance for a successful call after 64 surfaced EINTRs.
        guard calls < callLimit, interruptions < 64 else { throw latch(.rejected("read call bound")) }
        let request = offset == expected ? 1 : min(65536, expected - offset)
        calls += 1; pendingRequest = request
        return request
    }

    mutating func observe(amount: Int, error: Int32) throws -> Consumption {
        if let failure { throw failure }
        guard let request = pendingRequest, !eof else { throw latch(.rejected("read observation order")) }
        pendingRequest = nil
        // Pinned Darwin SDK sys/errno.h: EINTR=4. Preserve amount<0,
        // including its original treatment of any negative supplied amount.
        if amount < 0 && error == 4 {
            guard interruptions < 64 else { throw latch(.rejected("read EINTR bound")) }
            interruptions += 1
            return .interrupted
        }
        guard amount >= 0, amount <= request else { throw latch(.system("read", error)) }
        if offset == expected {
            guard amount == 0 else { throw latch(.rejected("growth")) }
            eof = true
            return .eof
        }
        guard amount > 0 else { throw latch(.rejected("early EOF")) }
        let retained = retainsWholeInput ? amount : retainsExecutablePrefix ? min(amount, 1048608 - retainedByteCount) : 0
        offset += amount; retainedByteCount += retained
        return .bytes(digest: amount, retained: retained)
    }

    private mutating func latch(_ error: H3QualificationControllerFailure) -> H3QualificationControllerFailure {
        if failure == nil { failure = error }
        return failure!
    }
}

/// Fixed labels and deep values only. This selection performs no path operation.
struct H3QualificationPrelaunchSelection: Equatable, Sendable {
    enum Role: CaseIterable, Equatable, Sendable {
        case manifest, sourceState, productAudit
    }
    let mode: H3QualificationMode
    let configuration: H3QualificationConfiguration
    let campaignRoot: String
    let runRoot: String

    init(mode: H3QualificationMode, configuration: H3QualificationConfiguration,
         runRoot: String) throws {
        let campaign = mode == .admissionOnly ? "/private/tmp/ergentics-h3q-admission-campaign-v1" :
            "/private/tmp/ergentics-h3q-guest-campaign-v1"
        let expected = campaign + (configuration == .debug ? "/debug" : "/release")
        guard runRoot.utf8.count <= 128, runRoot == expected else {
            throw H3QualificationControllerFailure.rejected("prelaunch selection")
        }
        self.mode = mode; self.configuration = configuration
        campaignRoot = campaign; self.runRoot = runRoot
    }

    func name(_ role: Role) -> String {
        switch role {
        case .manifest: return "build-source-manifest.json"
        case .sourceState: return "source-state.json"
        case .productAudit: return configuration == .debug ? "debug-product-audit.json" : "release-product-audit.json"
        }
    }
}

/// Production-used, one-shot transaction over injected callbacks and deep values.
/// It owns no descriptor or filesystem implementation. A successful begin callback
/// establishes one adapter-owned acquisition; a throwing begin must retain none.
/// The controller-only adapter enforces that rule at its single acquisition edge.
struct H3QualificationPrelaunchTransaction<Identity: Equatable & Sendable> {
    typealias Role = H3QualificationPrelaunchSelection.Role
    enum Acquisition: Equatable, Sendable { case content, identity }
    enum Phase: Equatable, Sendable { case ready, running, complete, failed }
    struct Observation: Sendable {
        let role: Role
        let owner: Identity
        let identity: Identity
    }
    struct Capture: Sendable {
        let bytes: Data
        let observation: Observation
    }
    struct Operations {
        let begin: (Role, Acquisition) throws -> Void
        let capture: (Role) throws -> Capture
        let observe: (Role) throws -> Observation
        let end: (Role, Acquisition) throws -> Void
        let revalidateOwner: () throws -> Identity
    }
    struct Result: Sendable {
        let artifacts: [String: Data]
        let expectedApplication: H3QualificationJSONValue
        let manifestSHA256: String
        let productAuditSHA256: String
    }
    let selection: H3QualificationPrelaunchSelection
    let owner: Identity
    private(set) var phase: Phase = .ready
    private(set) var contentAttempts = 0
    private(set) var identityAttempts = 0
    private(set) var contentCloseAttempts = 0
    private(set) var identityCloseAttempts = 0
    private(set) var ownerJoinAttempts = 0
    private(set) var verifierAttempts = 0
    private(set) var retainedByteCount = 0
    private(set) var cleanupFailureObserved = false

    init(selection: H3QualificationPrelaunchSelection, owner: Identity) {
        self.selection = selection; self.owner = owner
    }

    mutating func run(controllerClaim: H3QualificationJSONValue, operations: Operations) throws -> Result {
        guard phase == .ready else { throw H3QualificationControllerFailure.rejected("prelaunch transaction consumed") }
        phase = .running
        var active: (Role, Acquisition)?
        do {
            var artifacts: [String: Data] = [:]
            // Exactly three closed roles and six successful acquisitions. The
            // callbacks, including failure cleanup, are invoked at most 19 times.
            for role in Role.allCases {
                contentAttempts += 1
                try operations.begin(role, .content)
                active = (role, .content)
                let capture = try operations.capture(role)
                active = nil; contentCloseAttempts += 1
                try operations.end(role, .content)
                guard capture.observation.role == role, capture.observation.owner == owner,
                      capture.bytes.count > 0, capture.bytes.count <= 262144 else {
                    throw H3QualificationControllerFailure.rejected("prelaunch capture")
                }

                identityAttempts += 1
                try operations.begin(role, .identity)
                active = (role, .identity)
                let observed = try operations.observe(role)
                active = nil; identityCloseAttempts += 1
                try operations.end(role, .identity)
                guard observed.role == role, observed.owner == owner,
                      observed.identity == capture.observation.identity else {
                    throw H3QualificationControllerFailure.rejected("prelaunch observation join")
                }
                retainedByteCount += capture.bytes.count
                guard retainedByteCount <= 786432 else {
                    throw H3QualificationControllerFailure.rejected("prelaunch retained bound")
                }
                artifacts[selection.name(role)] = capture.bytes
            }
            ownerJoinAttempts = 1
            guard try operations.revalidateOwner() == owner else {
                throw H3QualificationControllerFailure.rejected("prelaunch owner join")
            }
            guard contentAttempts == 3, identityAttempts == 3,
                  contentCloseAttempts == 3, identityCloseAttempts == 3, artifacts.count == 3 else {
                throw H3QualificationControllerFailure.rejected("prelaunch transaction accounting")
            }
            verifierAttempts = 1
            let expected = try H3QualificationPrelaunchVerifier.verify(mode: selection.mode,
                configuration: selection.configuration, artifacts: artifacts, controllerClaim: controllerClaim)
            guard let manifest = artifacts[selection.name(.manifest)],
                  let audit = artifacts[selection.name(.productAudit)] else {
                throw H3QualificationControllerFailure.rejected("prelaunch retained hash inputs")
            }
            phase = .complete
            return Result(artifacts: artifacts, expectedApplication: expected,
                          manifestSHA256: H3QualificationProtocol.hash(manifest),
                          productAuditSHA256: H3QualificationProtocol.hash(audit))
        } catch {
            // Consume the close attempt before invoking its callback. A failed
            // close is never retried, and cannot replace the original failure.
            let original = error
            phase = .failed
            if let (role, acquisition) = active {
                active = nil
                switch acquisition {
                case .content: contentCloseAttempts += 1
                case .identity: identityCloseAttempts += 1
                }
                do { try operations.end(role, acquisition) }
                catch { cleanupFailureObserved = true }
            }
            throw original
        }
    }
}

extension H3QualificationJSONValue {
    func h3Object() throws -> [String: Self] {
        guard case .object(let value) = self else {
            throw H3QualificationControllerFailure.rejected("object")
        }
        return value
    }
    func h3Field(_ key: String) throws -> Self {
        guard let value = try h3Object()[key] else {
            throw H3QualificationControllerFailure.rejected("missing field")
        }
        return value
    }
    func h3String() throws -> String {
        guard case .string(let value) = self else {
            throw H3QualificationControllerFailure.rejected("string")
        }
        return value
    }
    func h3Array() throws -> [Self] {
        guard case .array(let value) = self else {
            throw H3QualificationControllerFailure.rejected("array")
        }
        return value
    }
    func h3Integer() throws -> Int64 {
        switch self {
        case .integer(let value): return value
        case .unsigned(let value):
            guard let signed = Int64(exactly: value) else {
                throw H3QualificationControllerFailure.rejected("integer overflow")
            }
            return signed
        default: throw H3QualificationControllerFailure.rejected("integer")
        }
    }
    func h3Bool() throws -> Bool {
        guard case .bool(let value) = self else {
            throw H3QualificationControllerFailure.rejected("boolean")
        }
        return value
    }
}
#endif

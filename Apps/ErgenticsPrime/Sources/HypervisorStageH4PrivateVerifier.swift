import Foundation

/// Bounded in-memory model of the H4 private-verifier state contract.
///
/// This is deliberately not a live verifier or durable store. Challenges and
/// storage cuts are fabricated inputs, authentication is represented only as
/// structural validity, and there is no file, SQLite, VM, process, transport,
/// key, randomness, entitlement, or authority-bearing operation.
final class HypervisorStageH4PrivateVerifier: @unchecked Sendable {
    static let formatFreezeCommit = "eafecae93199410fd3ee605617ec0d319774b424"
    static let formatFreezeBlob = "fc29ebbb15954018228d26a744ee4ae6cf7af314"
    static let formatFreezeSHA256 =
        "bd6e3ab19dba9501c4c9595e571959cad318831571f8b3decb5455f77763dd21"
    static let maximumOutstandingChallenges = 16
    static let maximumAcceptedSequence = 4_095
    static let capacityCandidateSequence = 4_096
    static let maximumAuthorityGeneration = 4_099

    struct Fixed32: Hashable, Sendable {
        let bytes: Data

        init?(_ bytes: Data) {
            guard bytes.count == 32, bytes.contains(where: { $0 != 0 }) else {
                return nil
            }
            self.bytes = bytes
        }
    }

    enum Lifecycle: UInt8, Equatable, Sendable {
        case uninitialized = 1
        case active = 2
        case conflict = 3
        case storageFaultLocked = 4
        case terminal = 5
    }

    enum Outcome: UInt8, Equatable, Sendable {
        case accepted = 1
        case current = 2
        case inspection = 3
        case rejected = 4
        case unavailable = 5
        case terminalCommitted = 6
    }

    enum RecordKind: UInt8, Equatable, Hashable, Sendable {
        case uninitialized = 1
        case accepted = 2
        case conflict = 3
        case fault = 4
        case terminalClose = 5
        case terminalMigration = 6
    }

    enum FaultCode: UInt8, Equatable, Sendable {
        case io = 1
        case capacity = 2
        case tornOrDivergent = 3
        case outcomeUnproven = 4
    }

    /// Append ordinals begin at one and include internal fault-latch appends.
    enum StoreCut: Equatable, Sendable {
        case clean
        case beforeMutation
        /// Recovery proves that the authenticated pointer still names the old state.
        case oldPointer
        case durableChildBeforePointer
        case pointerAdvancedBeforeResponse
        case expectationMismatch
        case containedTornRecord
        case unexcludedTornRecord
        case badAuthentication
        case indexGap
        case divergentBacklink
        case multipleChild
        case uncertainPointer
        case rollbackQualificationUnknown
        case permanentIO
        case permanentCapacity
        case outcomeUnproven
    }

    struct StorePlan: Equatable, Sendable {
        let cuts: [Int: StoreCut]
        init(_ cuts: [Int: StoreCut] = [:]) { self.cuts = cuts }
    }

    struct Challenge: Equatable, Hashable, Sendable {
        let bodyCommitment: Fixed32
        let envelopeCommitment: Fixed32
    }

    struct Configuration: Equatable, Sendable {
        let trustedGenesisCommitment: Fixed32
        let fixedPredecessor: Fixed32
        let injectedChallenges: [Challenge]
        let storePlan: StorePlan

        init(
            trustedGenesisCommitment: Fixed32,
            fixedPredecessor: Fixed32,
            injectedChallenges: [Challenge],
            storePlan: StorePlan = StorePlan()
        ) {
            self.trustedGenesisCommitment = trustedGenesisCommitment
            self.fixedPredecessor = fixedPredecessor
            self.injectedChallenges = injectedChallenges
            self.storePlan = storePlan
        }
    }

    /// Constructed only after the format layer has completed every common
    /// bound, context, join, token-shape, and issuer-signature check.
    struct EligibleAssertion: Equatable, Sendable {
        let sequence: Int
        let predecessor: Fixed32
        let lineageState: Fixed32
        let assertionBody: Fixed32
        let signatureEnvelope: Fixed32
        let assertionNonce: Fixed32

        init?(
            sequence: Int,
            predecessor: Fixed32,
            lineageState: Fixed32,
            assertionBody: Fixed32,
            signatureEnvelope: Fixed32,
            assertionNonce: Fixed32
        ) {
            guard (0...HypervisorStageH4PrivateVerifier.capacityCandidateSequence)
                .contains(sequence) else { return nil }
            self.sequence = sequence
            self.predecessor = predecessor
            self.lineageState = lineageState
            self.assertionBody = assertionBody
            self.signatureEnvelope = signatureEnvelope
            self.assertionNonce = assertionNonce
        }
    }

    enum EmbeddedAssertion: Equatable, Sendable {
        case rejected
        case eligible(EligibleAssertion)
    }

    struct AssertionRequest: Equatable, Sendable {
        let outerSupportedCanonical: Bool
        let challengeAuthenticated: Bool
        let challenge: Challenge
        let requestCommitment: Fixed32
        let embedded: EmbeddedAssertion

        init(
            outerSupportedCanonical: Bool = true,
            challengeAuthenticated: Bool = true,
            challenge: Challenge,
            requestCommitment: Fixed32,
            embedded: EmbeddedAssertion
        ) {
            self.outerSupportedCanonical = outerSupportedCanonical
            self.challengeAuthenticated = challengeAuthenticated
            self.challenge = challenge
            self.requestCommitment = requestCommitment
            self.embedded = embedded
        }
    }

    struct PointerExpectation: Equatable, Hashable, Sendable {
        let generation: Int
        let tipIndex: Int
        let tipKind: RecordKind
        let tipDiscriminator: Fixed32
    }

    enum TerminalKind: UInt8, Equatable, Sendable {
        case close = 0
        case migration = 1
    }

    enum TerminalReason: UInt8, Equatable, Sendable {
        case plannedClose = 1
        case compromise = 2
        case capacityRetirement = 3
        case faultRetirement = 4
        case plannedMigration = 5
    }

    struct TerminalRequest: Equatable, Sendable {
        let commitment: Fixed32
        let expectedPointer: PointerExpectation
        let kind: TerminalKind
        let reason: TerminalReason
        let newGenesisIntent: Fixed32?
        let newVerifierID: Fixed32?
        let migrationNonce: Fixed32?

        init(
            commitment: Fixed32,
            expectedPointer: PointerExpectation,
            kind: TerminalKind,
            reason: TerminalReason,
            newGenesisIntent: Fixed32? = nil,
            newVerifierID: Fixed32? = nil,
            migrationNonce: Fixed32? = nil
        ) {
            self.commitment = commitment
            self.expectedPointer = expectedPointer
            self.kind = kind
            self.reason = reason
            self.newGenesisIntent = newGenesisIntent
            self.newVerifierID = newVerifierID
            self.migrationNonce = migrationNonce
        }
    }

    /// Request-bound, one-use, process-local approval with no byte encoding.
    final class CustodianAuthorization: @unchecked Sendable {
        private let lock = NSLock()
        private let request: Fixed32
        private var used = false

        init(requestCommitment: Fixed32) { request = requestCommitment }

        fileprivate func consume(for value: Fixed32) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !used else { return false }
            used = true
            return request == value
        }
    }

    struct AcceptedReceipt: Equatable, Sendable {
        let outcome: Outcome
        let challenge: Fixed32
        let request: Fixed32
        let sequence: Int
        let acceptedLineageState: Fixed32
        let pointer: PointerExpectation
        let claimCode: UInt8 = 0
        let nonclaimBits: UInt16 = 1_023
        let authorityVector = "00000000"
    }

    struct MinimizedReceipt: Equatable, Sendable {
        let outcome: Outcome
        let challenge: Fixed32
        let request: Fixed32
        let claimCode: UInt8 = 0
        let nonclaimBits: UInt16 = 1_023
        let authorityVector = "00000000"
    }

    enum AssertionReply: Equatable, Sendable {
        case acceptedOrCurrent(AcceptedReceipt)
        case minimized(MinimizedReceipt)
        case noAuthenticatedResponse
    }

    struct TerminalReceipt: Equatable, Sendable {
        let outcome: Outcome
        let request: Fixed32
        let kind: TerminalKind
        let result: PointerExpectation
        let continuityCode: UInt8
    }

    struct MigrationPackage: Equatable, Sendable {
        let terminalRecord: PointerExpectation
        let newGenesisIntent: Fixed32
        let newVerifierID: Fixed32
        let migrationNonce: Fixed32
    }

    enum TerminalReply: Equatable, Sendable {
        case receipt(TerminalReceipt, migration: MigrationPackage?)
        case rejectedWithoutSignedDetail
        case noAuthenticatedResponse
    }

    enum RecoveryStatus: Equatable, Sendable {
        case ready
        case committed
        case faultLocked
        case terminal
        case recoveryRequired
        case offline
        case rollbackQualificationUnknown
    }

    enum ServiceStatus: Equatable, Sendable {
        case ready
        case recoveryRequired
        case offline
        case rollbackQualificationUnknown
    }

    enum SlotStatus: Equatable, Sendable {
        case unused
        case complete
        case containedResidue
        case unexcludedResidue
    }

    struct Counters: Equatable, Sendable {
        fileprivate(set) var challengesIssued = 0
        fileprivate(set) var challengesConsumed = 0
        fileprivate(set) var authorityReads = 0
        fileprivate(set) var recordReads = 0
        fileprivate(set) var appendAttempts = 0
        fileprivate(set) var receipts = 0
    }

    struct HistoryEntry: Equatable, Sendable {
        let index: Int
        let kind: RecordKind
        let lifecycle: Lifecycle
        let discriminator: Fixed32
        let faultCode: FaultCode?
        let attemptedKind: RecordKind?
    }

    struct Snapshot: Equatable, Sendable {
        let service: ServiceStatus
        let lifecycle: Lifecycle
        let generation: Int
        let acceptedSequence: Int?
        let acceptedLineageState: Fixed32
        let pointer: PointerExpectation
        let outstandingChallenges: Int
        let ordinarySlotsConsumed: Int
        let conflictReserve: SlotStatus
        let terminalReserve: SlotStatus
        let faultReserve: SlotStatus
        let history: [HistoryEntry]
        let retainedReceipts: Int
        let counters: Counters
    }

    private struct RecordID: Equatable, Hashable {
        let index: Int
        let kind: RecordKind
        let discriminator: Fixed32
    }

    private struct Record: Equatable {
        let id: RecordID
        let previous: RecordID?
        let lifecycle: Lifecycle
        let assertion: EligibleAssertion?
        let terminalRequest: TerminalRequest?
        let attemptedKind: RecordKind?
        let attemptedTerminalRequest: TerminalRequest?
        let faultCode: FaultCode?
        let authenticated: Bool
    }

    private struct Pointer: Equatable {
        let generation: Int
        let tip: RecordID
        let lifecycle: Lifecycle
        let acceptedRecord: RecordID?
        let acceptedSequence: Int?
        let acceptedLineageState: Fixed32
        let authenticated: Bool

        var expectation: PointerExpectation {
            PointerExpectation(
                generation: generation,
                tipIndex: tip.index,
                tipKind: tip.kind,
                tipDiscriminator: tip.discriminator
            )
        }
    }

    private enum Slot: Equatable {
        case ordinary(Int)
        case conflict
        case terminal
        case fault
    }

    private enum SlotState: Equatable {
        case unused
        case complete
        case residue(excluded: Bool, covered: Bool)

        var status: SlotStatus {
            switch self {
            case .unused: return .unused
            case .complete: return .complete
            case .residue(let excluded, _):
                return excluded ? .containedResidue : .unexcludedResidue
            }
        }
    }

    private struct Pending: Equatable {
        let record: Record
        let slot: Slot
        let oldPointer: Pointer
        let fault: FaultCode?
        let residueToCover: Slot?
    }

    private enum AppendResult: Equatable { case committed, recoveryRequired }

    private let stateLock = NSLock()
    private let configuration: Configuration
    private var challengeIndex = 0
    private var outstanding: Set<Challenge> = []
    private var service: ServiceStatus = .ready
    private var counters = Counters()
    private var records: [Record]
    private var pointer: Pointer
    private var ordinary = Array(repeating: SlotState.unused, count: 4_096)
    private var conflict: SlotState = .unused
    private var terminal: SlotState = .unused
    private var fault: SlotState = .unused
    private var pending: Pending?
    private var appendOrdinal = 0
    private var structuralFailure = false
    private var pointerUncertain = false
    private var rollbackUnknown = false

    init(configuration: Configuration) {
        self.configuration = configuration
        let genesisID = RecordID(
            index: 0,
            kind: .uninitialized,
            discriminator: configuration.trustedGenesisCommitment
        )
        records = [Record(
            id: genesisID,
            previous: nil,
            lifecycle: .uninitialized,
            assertion: nil,
            terminalRequest: nil,
            attemptedKind: nil,
            attemptedTerminalRequest: nil,
            faultCode: nil,
            authenticated: true
        )]
        pointer = Pointer(
            generation: 0,
            tip: genesisID,
            lifecycle: .uninitialized,
            acceptedRecord: nil,
            acceptedSequence: nil,
            acceptedLineageState: configuration.fixedPredecessor,
            authenticated: true
        )
    }

    func issueChallenge() -> Challenge? {
        synchronized {
            guard service == .ready,
                  outstanding.count < Self.maximumOutstandingChallenges,
                  challengeIndex < configuration.injectedChallenges.count else {
                return nil
            }
            let challenge = configuration.injectedChallenges[challengeIndex]
            challengeIndex += 1
            guard outstanding.insert(challenge).inserted else { return nil }
            counters.challengesIssued += 1
            return challenge
        }
    }

    func submitAssertion(_ request: AssertionRequest) -> AssertionReply {
        synchronized {
            guard service == .ready,
                  request.outerSupportedCanonical,
                  request.challengeAuthenticated,
                  outstanding.remove(request.challenge) != nil else {
                return .noAuthenticatedResponse
            }
            counters.challengesConsumed += 1
            guard case .eligible(let candidate) = request.embedded else {
                return minimized(.rejected, request)
            }
            if pointer.lifecycle == .terminal {
                counters.authorityReads += 1
                return minimized(.rejected, request)
            }
            guard authenticateCurrent() else {
                service = .offline
                return .noAuthenticatedResponse
            }
            switch pointer.lifecycle {
            case .uninitialized:
                guard candidate.sequence == 0,
                      candidate.predecessor == configuration.fixedPredecessor else {
                    return minimized(.rejected, request)
                }
                return appendAccepted(candidate, request)
            case .active:
                return classifyActive(candidate, request)
            case .conflict:
                return minimized(.inspection, request)
            case .storageFaultLocked:
                return minimized(.unavailable, request)
            case .terminal:
                return minimized(.rejected, request)
            }
        }
    }

    func submitTerminal(
        _ request: TerminalRequest,
        authorization: CustodianAuthorization
    ) -> TerminalReply {
        synchronized {
            guard service == .ready, authenticateCurrent() else {
                return .noAuthenticatedResponse
            }
            guard authorization.consume(for: request.commitment),
                  terminalShapeIsExact(request) else {
                return .rejectedWithoutSignedDetail
            }

            if pointer.lifecycle == .terminal {
                guard let retained = record(pointer.tip)?.terminalRequest,
                      retained == request else {
                    return .rejectedWithoutSignedDetail
                }
                return terminalReply(request)
            }

            if pointer.lifecycle == .storageFaultLocked,
               let latch = record(pointer.tip),
                   latch.attemptedTerminalRequest == request,
               latch.attemptedKind == request.kind.recordKind {
                counters.receipts += 1
                return .receipt(
                    TerminalReceipt(
                        outcome: .unavailable,
                        request: request.commitment,
                        kind: request.kind,
                        result: pointer.expectation,
                        continuityCode: 0
                    ),
                    migration: nil
                )
            }

            guard request.expectedPointer == pointer.expectation,
                  terminalGateAllows(request) else {
                return .rejectedWithoutSignedDetail
            }
            let kind = request.kind.recordKind
            let value = Record(
                id: RecordID(
                    index: pointer.generation + 1,
                    kind: kind,
                    discriminator: request.commitment
                ),
                previous: pointer.tip,
                lifecycle: .terminal,
                assertion: nil,
                terminalRequest: request,
                attemptedKind: nil,
                attemptedTerminalRequest: nil,
                faultCode: nil,
                authenticated: true
            )
            counters.appendAttempts += 1
            guard compareAndAppend(value, in: .terminal) == .committed else {
                service = .recoveryRequired
                return .noAuthenticatedResponse
            }
            guard authenticateCurrent() else {
                service = .offline
                return .noAuthenticatedResponse
            }
            return terminalReply(request)
        }
    }

    func recoverAfterInterruption() -> RecoveryStatus {
        synchronized { recoverLocked() }
    }

    func restartAndRecover() -> RecoveryStatus {
        synchronized {
            outstanding.removeAll(keepingCapacity: true)
            return recoverLocked()
        }
    }

    func snapshot() -> Snapshot {
        synchronized { snapshotLocked() }
    }

    private func classifyActive(
        _ candidate: EligibleAssertion,
        _ request: AssertionRequest
    ) -> AssertionReply {
        guard let currentSequence = pointer.acceptedSequence,
              let current = acceptedRecord(at: currentSequence) else {
            service = .offline
            return .noAuthenticatedResponse
        }

        if candidate.sequence == currentSequence,
           candidate.assertionBody == current.assertion?.assertionBody {
            return acceptedReply(.current, request, current.assertion!)
        }

        if let occupied = acceptedRecord(at: candidate.sequence),
           let admitted = occupied.assertion,
           candidate.predecessor == admitted.predecessor {
            if candidate.lineageState == admitted.lineageState,
               candidate.assertionBody != admitted.assertionBody,
               candidate.assertionNonce != admitted.assertionNonce {
                return minimized(.inspection, request)
            }
            if candidate.lineageState != admitted.lineageState {
                let tombstone = Record(
                    id: RecordID(
                        index: pointer.generation + 1,
                        kind: .conflict,
                        discriminator: candidate.assertionBody
                    ),
                    previous: pointer.tip,
                    lifecycle: .conflict,
                    assertion: candidate,
                    terminalRequest: nil,
                    attemptedKind: nil,
                    attemptedTerminalRequest: nil,
                    faultCode: nil,
                    authenticated: true
                )
                counters.appendAttempts += 1
                guard compareAndAppend(tombstone, in: .conflict) == .committed else {
                    service = .recoveryRequired
                    return .noAuthenticatedResponse
                }
                guard authenticateCurrent() else {
                    service = .offline
                    return .noAuthenticatedResponse
                }
                return minimized(.inspection, request)
            }
        }

        if currentSequence < Self.maximumAcceptedSequence,
           candidate.sequence == currentSequence + 1,
           candidate.predecessor == pointer.acceptedLineageState {
            return appendAccepted(candidate, request)
        }

        // This includes stale, gap, parent mismatch, and the exact sequence
        // 4096 capacity case. They share one minimized external class.
        return minimized(.rejected, request)
    }

    private func appendAccepted(
        _ candidate: EligibleAssertion,
        _ request: AssertionRequest
    ) -> AssertionReply {
        guard candidate.sequence <= Self.maximumAcceptedSequence else {
            return minimized(.rejected, request)
        }
        let value = Record(
            id: RecordID(
                index: pointer.generation + 1,
                kind: .accepted,
                discriminator: candidate.assertionBody
            ),
            previous: pointer.tip,
            lifecycle: .active,
            assertion: candidate,
            terminalRequest: nil,
            attemptedKind: nil,
            attemptedTerminalRequest: nil,
            faultCode: nil,
            authenticated: true
        )
        counters.appendAttempts += 1
        guard compareAndAppend(value, in: .ordinary(candidate.sequence)) == .committed else {
            service = .recoveryRequired
            return .noAuthenticatedResponse
        }
        guard authenticateCurrent() else {
            service = .offline
            return .noAuthenticatedResponse
        }
        return acceptedReply(.accepted, request, candidate)
    }

    private func acceptedReply(
        _ outcome: Outcome,
        _ request: AssertionRequest,
        _ assertion: EligibleAssertion
    ) -> AssertionReply {
        counters.receipts += 1
        return .acceptedOrCurrent(
            AcceptedReceipt(
                outcome: outcome,
                challenge: request.challenge.bodyCommitment,
                request: request.requestCommitment,
                sequence: assertion.sequence,
                acceptedLineageState: assertion.lineageState,
                pointer: pointer.expectation
            )
        )
    }

    private func minimized(
        _ outcome: Outcome,
        _ request: AssertionRequest
    ) -> AssertionReply {
        counters.receipts += 1
        return .minimized(
            MinimizedReceipt(
                outcome: outcome,
                challenge: request.challenge.bodyCommitment,
                request: request.requestCommitment
            )
        )
    }

    private func terminalReply(_ request: TerminalRequest) -> TerminalReply {
        counters.receipts += 1
        let receipt = TerminalReceipt(
            outcome: .terminalCommitted,
            request: request.commitment,
            kind: request.kind,
            result: pointer.expectation,
            continuityCode: request.kind == .migration ? 1 : 0
        )
        let migration: MigrationPackage?
        if request.kind == .migration,
           let genesis = request.newGenesisIntent,
           let verifier = request.newVerifierID,
           let nonce = request.migrationNonce {
            migration = MigrationPackage(
                terminalRecord: pointer.expectation,
                newGenesisIntent: genesis,
                newVerifierID: verifier,
                migrationNonce: nonce
            )
        } else {
            migration = nil
        }
        return .receipt(receipt, migration: migration)
    }

    private func terminalShapeIsExact(_ request: TerminalRequest) -> Bool {
        switch request.kind {
        case .close:
            return request.reason != .plannedMigration
                && request.newGenesisIntent == nil
                && request.newVerifierID == nil
                && request.migrationNonce == nil
        case .migration:
            return request.reason == .plannedMigration
                && request.newGenesisIntent != nil
                && request.newVerifierID != nil
                && request.migrationNonce != nil
        }
    }

    private func terminalGateAllows(_ request: TerminalRequest) -> Bool {
        switch (pointer.lifecycle, request.kind) {
        case (.uninitialized, _), (.terminal, _): return false
        case (.active, .close): return request.reason != .plannedMigration
        case (.active, .migration):
            return pointer.acceptedRecord != nil
                && request.reason == .plannedMigration
        case (.conflict, .close):
            return request.reason == .plannedClose
                || request.reason == .compromise
                || request.reason == .faultRetirement
        case (.conflict, .migration): return false
        case (.storageFaultLocked, .close):
            return request.reason == .faultRetirement
        case (.storageFaultLocked, .migration): return false
        }
    }

    private func compareAndAppend(
        _ intended: Record,
        in slot: Slot,
        covering residue: Slot? = nil
    ) -> AppendResult {
        appendOrdinal += 1
        let cut = configuration.storePlan.cuts[appendOrdinal] ?? .clean
        guard intended.id.index == pointer.generation + 1,
              intended.id.index <= Self.maximumAuthorityGeneration,
              intended.previous == pointer.tip,
              pointer.authenticated,
              slotState(slot) == .unused else {
            pending = nil
            return .recoveryRequired
        }
        let old = pointer

        func pendingValue(
            record: Record = intended,
            fault: FaultCode? = nil
        ) -> Pending {
            Pending(
                record: record,
                slot: slot,
                oldPointer: old,
                fault: fault,
                residueToCover: residue
            )
        }

        switch cut {
        case .clean:
            setSlot(slot, .complete)
            records.append(intended)
            pointer = advancedPointer(with: intended)
            cover(residue)
            pending = nil
            return .committed
            case .beforeMutation, .oldPointer, .expectationMismatch:
            pending = pendingValue()
        case .durableChildBeforePointer:
            setSlot(slot, .complete)
            records.append(intended)
            pending = pendingValue()
        case .pointerAdvancedBeforeResponse:
            setSlot(slot, .complete)
            records.append(intended)
            pointer = advancedPointer(with: intended)
            pending = pendingValue()
        case .containedTornRecord:
            setSlot(slot, .residue(excluded: true, covered: false))
            pending = pendingValue(fault: .tornOrDivergent)
        case .unexcludedTornRecord:
            setSlot(slot, .residue(excluded: false, covered: false))
            pending = pendingValue()
        case .badAuthentication:
            let invalid = Record(
                id: intended.id,
                previous: intended.previous,
                lifecycle: intended.lifecycle,
                assertion: intended.assertion,
                terminalRequest: intended.terminalRequest,
                attemptedKind: intended.attemptedKind,
                attemptedTerminalRequest: intended.attemptedTerminalRequest,
                faultCode: intended.faultCode,
                authenticated: false
            )
            setSlot(slot, .complete)
            records.append(invalid)
            pending = pendingValue()
        case .indexGap:
            let invalid = Record(
                id: RecordID(
                    index: intended.id.index + 1,
                    kind: intended.id.kind,
                    discriminator: intended.id.discriminator
                ),
                previous: intended.previous,
                lifecycle: intended.lifecycle,
                assertion: intended.assertion,
                terminalRequest: intended.terminalRequest,
                attemptedKind: intended.attemptedKind,
                attemptedTerminalRequest: intended.attemptedTerminalRequest,
                faultCode: intended.faultCode,
                authenticated: true
            )
            setSlot(slot, .complete)
            records.append(invalid)
            pending = pendingValue()
        case .divergentBacklink:
            let invalid = Record(
                id: intended.id,
                previous: nil,
                lifecycle: intended.lifecycle,
                assertion: intended.assertion,
                terminalRequest: intended.terminalRequest,
                attemptedKind: intended.attemptedKind,
                attemptedTerminalRequest: intended.attemptedTerminalRequest,
                faultCode: intended.faultCode,
                authenticated: true
            )
            setSlot(slot, .complete)
            records.append(invalid)
            pending = pendingValue()
        case .multipleChild:
            setSlot(slot, .complete)
            records.append(intended)
            pending = pendingValue()
            structuralFailure = true
        case .uncertainPointer:
            setSlot(slot, .complete)
            records.append(intended)
            pending = pendingValue()
            pointerUncertain = true
        case .rollbackQualificationUnknown:
            pending = pendingValue()
            rollbackUnknown = true
        case .permanentIO:
            pending = pendingValue(fault: .io)
        case .permanentCapacity:
            pending = pendingValue(fault: .capacity)
        case .outcomeUnproven:
            pending = pendingValue(fault: .outcomeUnproven)
        }
        return .recoveryRequired
    }

    private func recoverLocked() -> RecoveryStatus {
        guard service != .offline else { return .offline }
        guard !rollbackUnknown else {
            service = .rollbackQualificationUnknown
            counters.authorityReads += 1
            counters.recordReads += records.count
            return .rollbackQualificationUnknown
        }
        guard !structuralFailure, !pointerUncertain,
              let chain = authenticatedChain() else {
            service = .offline
            counters.authorityReads += 1
            counters.recordReads += records.count
            return .offline
        }
        counters.authorityReads += 1
        counters.recordReads += records.count
        let chainIDs = Set(chain.map(\.id))
        let orphans = records.filter { !chainIDs.contains($0.id) }

        guard let interrupted = pending else {
            guard orphans.isEmpty, residuesAreResolved() else {
                service = .offline
                return .offline
            }
            service = .ready
            return statusForCurrentLifecycle(default: .ready)
        }

        if pointer.tip == interrupted.record.id {
            pending = nil
            cover(interrupted.residueToCover)
            guard authenticateCurrent() else {
                service = .offline
                return .offline
            }
            service = .ready
            return statusForCurrentLifecycle(default: .committed)
        }

        if orphans.count == 1, orphans[0] == interrupted.record,
           residuePermitsRecovery(interrupted) {
            pointer = advancedPointer(with: interrupted.record)
            pending = nil
            cover(interrupted.residueToCover)
            guard authenticateCurrent() else {
                service = .offline
                return .offline
            }
            service = .ready
            return statusForCurrentLifecycle(default: .committed)
        }
        guard orphans.isEmpty, residuePermitsRecovery(interrupted) else {
            service = .offline
            return .offline
        }

        if interrupted.record.id.kind == .fault {
            guard slotState(.fault) == .unused else {
                service = .offline
                return .offline
            }
            pending = nil
            counters.appendAttempts += 1
            let result = compareAndAppend(
                interrupted.record,
                in: .fault,
                covering: interrupted.residueToCover
            )
            return finishRecoveryAppend(result)
        }

        guard let faultCode = interrupted.fault else {
            pending = nil
            service = .ready
            return statusForCurrentLifecycle(default: .ready)
        }
        guard slotState(.fault) == .unused else {
            service = .offline
            return .offline
        }
        let faultRecord = Record(
            id: RecordID(
                index: interrupted.oldPointer.generation + 1,
                kind: .fault,
                discriminator: interrupted.record.id.discriminator
            ),
            previous: interrupted.oldPointer.tip,
            lifecycle: .storageFaultLocked,
            assertion: nil,
            terminalRequest: nil,
            attemptedKind: interrupted.record.id.kind,
            attemptedTerminalRequest: interrupted.record.terminalRequest,
            faultCode: faultCode,
            authenticated: true
        )
        let covered = slotHasResidue(interrupted.slot)
            ? interrupted.slot : interrupted.residueToCover
        pending = nil
        counters.appendAttempts += 1
        let result = compareAndAppend(faultRecord, in: .fault, covering: covered)
        return finishRecoveryAppend(result)
    }

    private func finishRecoveryAppend(_ result: AppendResult) -> RecoveryStatus {
        guard result == .committed else {
            service = .recoveryRequired
            return .recoveryRequired
        }
        guard authenticateCurrent() else {
            service = .offline
            return .offline
        }
        service = .ready
        return statusForCurrentLifecycle(default: .committed)
    }

    private func statusForCurrentLifecycle(
        default fallback: RecoveryStatus
    ) -> RecoveryStatus {
        switch pointer.lifecycle {
        case .storageFaultLocked: return .faultLocked
        case .terminal: return .terminal
        default: return fallback
        }
    }

    private func authenticateCurrent() -> Bool {
        counters.authorityReads += 1
        counters.recordReads += records.count
        guard pending == nil, !rollbackUnknown, !structuralFailure,
              !pointerUncertain, let chain = authenticatedChain(),
              chain.count == records.count, residuesAreResolved() else {
            return false
        }
        let accepted = chain.compactMap { value -> Record? in
            value.id.kind == .accepted ? value : nil
        }
        if let sequence = pointer.acceptedSequence {
            guard let latest = accepted.max(by: {
                ($0.assertion?.sequence ?? -1) < ($1.assertion?.sequence ?? -1)
            }), latest.id == pointer.acceptedRecord,
                  latest.assertion?.sequence == sequence,
                  latest.assertion?.lineageState == pointer.acceptedLineageState else {
                return false
            }
        } else if pointer.acceptedRecord != nil || !accepted.isEmpty
                    || pointer.acceptedLineageState != configuration.fixedPredecessor {
            return false
        }
        return true
    }

    private func authenticatedChain() -> [Record]? {
        guard pointer.authenticated, pointer.generation == pointer.tip.index,
              pointer.generation <= Self.maximumAuthorityGeneration else {
            return nil
        }
        var table: [RecordID: Record] = [:]
        for value in records {
            guard value.authenticated,
                  table.updateValue(value, forKey: value.id) == nil else {
                return nil
            }
        }
        var reverse: [Record] = []
        var next: RecordID? = pointer.tip
        while let id = next {
            guard let value = table[id], kindMatchesLifecycle(value) else {
                return nil
            }
            reverse.append(value)
            if value.id.index == 0 {
                guard value.previous == nil else { return nil }
                next = nil
            } else {
                guard let prior = value.previous,
                      prior.index + 1 == value.id.index else { return nil }
                next = prior
            }
        }
        let chain = Array(reverse.reversed())
        guard chain.count == pointer.generation + 1,
              chain.first?.id.index == 0,
              chain.last?.id == pointer.tip,
              chain.last?.lifecycle == pointer.lifecycle else { return nil }
        return chain
    }

    private func kindMatchesLifecycle(_ value: Record) -> Bool {
        switch (value.id.kind, value.lifecycle) {
        case (.uninitialized, .uninitialized), (.accepted, .active),
             (.conflict, .conflict), (.fault, .storageFaultLocked),
             (.terminalClose, .terminal), (.terminalMigration, .terminal):
            return true
        default: return false
        }
    }

    private func acceptedRecord(at sequence: Int) -> Record? {
        records.first {
            $0.id.kind == .accepted && $0.assertion?.sequence == sequence
        }
    }

    private func record(_ id: RecordID) -> Record? {
        records.first { $0.id == id }
    }

    private func advancedPointer(with value: Record) -> Pointer {
        if let assertion = value.assertion, value.id.kind == .accepted {
            return Pointer(
                generation: value.id.index,
                tip: value.id,
                lifecycle: value.lifecycle,
                acceptedRecord: value.id,
                acceptedSequence: assertion.sequence,
                acceptedLineageState: assertion.lineageState,
                authenticated: true
            )
        }
        return Pointer(
            generation: value.id.index,
            tip: value.id,
            lifecycle: value.lifecycle,
            acceptedRecord: pointer.acceptedRecord,
            acceptedSequence: pointer.acceptedSequence,
            acceptedLineageState: pointer.acceptedLineageState,
            authenticated: true
        )
    }

    private func slotState(_ slot: Slot) -> SlotState {
        switch slot {
        case .ordinary(let index): return ordinary[index]
        case .conflict: return conflict
        case .terminal: return terminal
        case .fault: return fault
        }
    }

    private func setSlot(_ slot: Slot, _ value: SlotState) {
        switch slot {
        case .ordinary(let index): ordinary[index] = value
        case .conflict: conflict = value
        case .terminal: terminal = value
        case .fault: fault = value
        }
    }

    private func slotHasResidue(_ slot: Slot) -> Bool {
        if case .residue = slotState(slot) { return true }
        return false
    }

    private func cover(_ slot: Slot?) {
        guard let slot,
              case .residue(let excluded, _) = slotState(slot), excluded else {
            return
        }
        setSlot(slot, .residue(excluded: true, covered: true))
    }

    private func residuePermitsRecovery(_ value: Pending) -> Bool {
        occupiedSlots().allSatisfy { slot, state in
            guard case .residue(let excluded, let covered) = state else {
                return true
            }
            return covered || (excluded &&
                (slot == value.slot || slot == value.residueToCover))
        }
    }

    private func residuesAreResolved() -> Bool {
        occupiedSlots().allSatisfy { _, state in
            guard case .residue(let excluded, let covered) = state else {
                return true
            }
            return excluded && covered
        }
    }

    private func occupiedSlots() -> [(Slot, SlotState)] {
        var result = ordinary.enumerated().map { (Slot.ordinary($0.offset), $0.element) }
        result.append((.conflict, conflict))
        result.append((.terminal, terminal))
        result.append((.fault, fault))
        return result
    }

    private func snapshotLocked() -> Snapshot {
        let history = records.sorted { $0.id.index < $1.id.index }.map {
            HistoryEntry(
                index: $0.id.index,
                kind: $0.id.kind,
                lifecycle: $0.lifecycle,
                discriminator: $0.id.discriminator,
                faultCode: $0.faultCode,
                attemptedKind: $0.attemptedKind
            )
        }
        return Snapshot(
            service: service,
            lifecycle: pointer.lifecycle,
            generation: pointer.generation,
            acceptedSequence: pointer.acceptedSequence,
            acceptedLineageState: pointer.acceptedLineageState,
            pointer: pointer.expectation,
            outstandingChallenges: outstanding.count,
            ordinarySlotsConsumed: ordinary.reduce(0) {
                $0 + ($1 == .unused ? 0 : 1)
            },
            conflictReserve: conflict.status,
            terminalReserve: terminal.status,
            faultReserve: fault.status,
            history: history,
            retainedReceipts: 0,
            counters: counters
        )
    }

    private func synchronized<T>(_ body: () -> T) -> T {
        stateLock.lock()
        defer { stateLock.unlock() }
        return body()
    }
}

private extension HypervisorStageH4PrivateVerifier.TerminalKind {
    var recordKind: HypervisorStageH4PrivateVerifier.RecordKind {
        switch self {
        case .close: return .terminalClose
        case .migration: return .terminalMigration
        }
    }
}

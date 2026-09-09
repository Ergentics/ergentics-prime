import Foundation
import XCTest

final class HypervisorStageH4PrivateVerifierTests: XCTestCase {
    private typealias V = HypervisorStageH4PrivateVerifier

    private final class LockedReplies: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [V.AssertionReply] = []

        func append(_ value: V.AssertionReply) {
            lock.lock()
            values.append(value)
            lock.unlock()
        }

        func snapshot() -> [V.AssertionReply] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }
    }

    private func fixed(_ tag: UInt8, _ value: Int = 0) -> V.Fixed32 {
        var bytes = Data(repeating: tag == 0 ? 1 : tag, count: 32)
        bytes[0] = tag == 0 ? 1 : tag
        bytes[1] = UInt8(truncatingIfNeeded: value >> 24)
        bytes[2] = UInt8(truncatingIfNeeded: value >> 16)
        bytes[3] = UInt8(truncatingIfNeeded: value >> 8)
        bytes[4] = UInt8(truncatingIfNeeded: value)
        return V.Fixed32(bytes)!
    }

    private func challenge(_ value: Int) -> V.Challenge {
        V.Challenge(
            bodyCommitment: fixed(1, value),
            envelopeCommitment: fixed(2, value)
        )
    }

    private func verifier(
        challengeCount: Int = 128,
        cuts: [Int: V.StoreCut] = [:]
    ) -> V {
        V(configuration: V.Configuration(
            trustedGenesisCommitment: fixed(10),
            fixedPredecessor: fixed(11),
            injectedChallenges: (0..<challengeCount).map(challenge),
            storePlan: V.StorePlan(cuts)
        ))
    }

    private func assertion(
        sequence: Int,
        predecessor: V.Fixed32,
        lineage: V.Fixed32? = nil,
        body: V.Fixed32? = nil,
        envelope: V.Fixed32? = nil,
        nonce: V.Fixed32? = nil
    ) -> V.EligibleAssertion {
        V.EligibleAssertion(
            sequence: sequence,
            predecessor: predecessor,
            lineageState: lineage ?? fixed(20, sequence),
            assertionBody: body ?? fixed(21, sequence),
            signatureEnvelope: envelope ?? fixed(22, sequence),
            assertionNonce: nonce ?? fixed(23, sequence)
        )!
    }

    private func request(
        _ challenge: V.Challenge,
        _ candidate: V.EligibleAssertion,
        id: Int,
        outer: Bool = true,
        challengeAuthenticated: Bool = true
    ) -> V.AssertionRequest {
        V.AssertionRequest(
            outerSupportedCanonical: outer,
            challengeAuthenticated: challengeAuthenticated,
            challenge: challenge,
            requestCommitment: fixed(30, id),
            embedded: .eligible(candidate)
        )
    }

    private func submit(
        _ verifier: V,
        _ candidate: V.EligibleAssertion,
        id: Int
    ) -> V.AssertionReply {
        let issued = verifier.issueChallenge()!
        return verifier.submitAssertion(request(issued, candidate, id: id))
    }

    private func outcome(_ reply: V.AssertionReply) -> V.Outcome? {
        switch reply {
        case .acceptedOrCurrent(let receipt): return receipt.outcome
        case .minimized(let receipt): return receipt.outcome
        case .noAuthenticatedResponse: return nil
        }
    }

    private func close(
        pointer: V.PointerExpectation,
        id: Int,
        reason: V.TerminalReason = .plannedClose
    ) -> V.TerminalRequest {
        V.TerminalRequest(
            commitment: fixed(40, id),
            expectedPointer: pointer,
            kind: .close,
            reason: reason
        )
    }

    private func migration(
        pointer: V.PointerExpectation,
        id: Int
    ) -> V.TerminalRequest {
        V.TerminalRequest(
            commitment: fixed(41, id),
            expectedPointer: pointer,
            kind: .migration,
            reason: .plannedMigration,
            newGenesisIntent: fixed(42, id),
            newVerifierID: fixed(43, id),
            migrationNonce: fixed(44, id)
        )
    }

    private func authorization(_ request: V.TerminalRequest) -> V.CustodianAuthorization {
        V.CustodianAuthorization(requestCommitment: request.commitment)
    }

    func testFreezePinsAndFixedWidthBoundary() {
        XCTAssertEqual(
            V.formatFreezeCommit,
            "eafecae93199410fd3ee605617ec0d319774b424"
        )
        XCTAssertEqual(
            V.formatFreezeBlob,
            "fc29ebbb15954018228d26a744ee4ae6cf7af314"
        )
        XCTAssertEqual(
            V.formatFreezeSHA256,
            "bd6e3ab19dba9501c4c9595e571959cad318831571f8b3decb5455f77763dd21"
        )
        XCTAssertNil(V.Fixed32(Data(repeating: 1, count: 31)))
        XCTAssertNil(V.Fixed32(Data(repeating: 1, count: 33)))
        XCTAssertNil(V.Fixed32(Data(repeating: 0, count: 32)))
        XCTAssertNotNil(V.Fixed32(Data(repeating: 1, count: 32)))
        XCTAssertNil(V.EligibleAssertion(
            sequence: 4_097,
            predecessor: fixed(1), lineageState: fixed(2),
            assertionBody: fixed(3), signatureEnvelope: fixed(4),
            assertionNonce: fixed(5)
        ))
    }

    func testChallengeBoundariesAndPreauthenticationReadBarrier() {
        let subject = verifier(challengeCount: 20)
        var issued: [V.Challenge] = []
        for _ in 0..<16 { issued.append(subject.issueChallenge()!) }
        XCTAssertNil(subject.issueChallenge())
        XCTAssertEqual(subject.snapshot().outstandingChallenges, 16)

        let candidate = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertEqual(
            subject.submitAssertion(request(issued[0], candidate, id: 1, outer: false)),
            .noAuthenticatedResponse
        )
        XCTAssertEqual(
            subject.submitAssertion(request(
                issued[0], candidate, id: 2, challengeAuthenticated: false
            )),
            .noAuthenticatedResponse
        )
        var snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.outstandingChallenges, 16)
        XCTAssertEqual(snapshot.counters.challengesConsumed, 0)
        XCTAssertEqual(snapshot.counters.authorityReads, 0)
        XCTAssertEqual(snapshot.counters.receipts, 0)

        let embeddedRejected = V.AssertionRequest(
            challenge: issued[0],
            requestCommitment: fixed(30, 3),
            embedded: .rejected
        )
        XCTAssertEqual(outcome(subject.submitAssertion(embeddedRejected)), .rejected)
        snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.outstandingChallenges, 15)
        XCTAssertEqual(snapshot.counters.challengesConsumed, 1)
        XCTAssertEqual(snapshot.counters.authorityReads, 0)
        XCTAssertEqual(snapshot.counters.receipts, 1)
        XCTAssertEqual(subject.submitAssertion(embeddedRejected), .noAuthenticatedResponse)
        XCTAssertNotNil(subject.issueChallenge())
        XCTAssertEqual(subject.snapshot().outstandingChallenges, 16)

        XCTAssertEqual(subject.restartAndRecover(), .ready)
        XCTAssertEqual(subject.snapshot().outstandingChallenges, 0)
    }

    func testBootstrapCurrentWrapperSuccessorStaleGapAndConflict() {
        let subject = verifier()
        let fixedPredecessor = fixed(11)

        XCTAssertEqual(
            outcome(submit(subject, assertion(
                sequence: 1, predecessor: fixedPredecessor
            ), id: 1)),
            .rejected
        )
        XCTAssertEqual(
            outcome(submit(subject, assertion(
                sequence: 0, predecessor: fixed(99)
            ), id: 2)),
            .rejected
        )
        XCTAssertEqual(subject.snapshot().generation, 0)

        let zero = assertion(sequence: 0, predecessor: fixedPredecessor)
        XCTAssertEqual(outcome(submit(subject, zero, id: 3)), .accepted)
        let afterBootstrap = subject.snapshot()
        XCTAssertEqual(afterBootstrap.lifecycle, .active)
        XCTAssertEqual(afterBootstrap.generation, 1)
        XCTAssertEqual(afterBootstrap.acceptedSequence, 0)
        XCTAssertEqual(afterBootstrap.ordinarySlotsConsumed, 1)

        XCTAssertEqual(outcome(submit(subject, zero, id: 4)), .current)
        let alternateEnvelope = assertion(
            sequence: 0,
            predecessor: fixedPredecessor,
            lineage: zero.lineageState,
            body: zero.assertionBody,
            envelope: fixed(70),
            nonce: zero.assertionNonce
        )
        XCTAssertEqual(outcome(submit(subject, alternateEnvelope, id: 5)), .current)

        let wrapper = assertion(
            sequence: 0,
            predecessor: fixedPredecessor,
            lineage: zero.lineageState,
            body: fixed(71),
            nonce: fixed(72)
        )
        XCTAssertEqual(outcome(submit(subject, wrapper, id: 6)), .inspection)
        XCTAssertEqual(subject.snapshot().generation, 1)

        let impossibleSameNonceVariant = assertion(
            sequence: 0,
            predecessor: fixedPredecessor,
            lineage: zero.lineageState,
            body: fixed(79),
            nonce: zero.assertionNonce
        )
        XCTAssertEqual(
            outcome(submit(subject, impossibleSameNonceVariant, id: 60)),
            .rejected
        )
        XCTAssertEqual(subject.snapshot().generation, 1)

        let wrongParent = assertion(sequence: 1, predecessor: fixed(73))
        XCTAssertEqual(outcome(submit(subject, wrongParent, id: 7)), .rejected)
        let gap = assertion(sequence: 2, predecessor: zero.lineageState)
        XCTAssertEqual(outcome(submit(subject, gap, id: 8)), .rejected)

        let one = assertion(sequence: 1, predecessor: zero.lineageState)
        XCTAssertEqual(outcome(submit(subject, one, id: 9)), .accepted)
        XCTAssertEqual(outcome(submit(subject, zero, id: 10)), .rejected)

        let oldWrapper = assertion(
            sequence: 0,
            predecessor: fixedPredecessor,
            lineage: zero.lineageState,
            body: fixed(74),
            nonce: fixed(75)
        )
        XCTAssertEqual(outcome(submit(subject, oldWrapper, id: 11)), .inspection)
        let oldConflict = assertion(
            sequence: 0,
            predecessor: fixedPredecessor,
            lineage: fixed(76),
            body: fixed(77),
            nonce: fixed(78)
        )
        XCTAssertEqual(outcome(submit(subject, oldConflict, id: 12)), .inspection)
        let final = subject.snapshot()
        XCTAssertEqual(final.lifecycle, .conflict)
        XCTAssertEqual(final.generation, 3)
        XCTAssertEqual(final.conflictReserve, .complete)
        XCTAssertEqual(final.acceptedSequence, 1)
        XCTAssertEqual(outcome(submit(subject, one, id: 13)), .inspection)
    }

    func testConcurrentIdenticalAndSiblingRequestsSerialize() {
        do {
            let subject = verifier()
            let candidate = assertion(sequence: 0, predecessor: fixed(11))
            let c0 = subject.issueChallenge()!
            let c1 = subject.issueChallenge()!
            let replies = LockedReplies()
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "h4.private.identical", attributes: .concurrent)
            for value in [request(c0, candidate, id: 1), request(c1, candidate, id: 2)] {
                group.enter()
                queue.async {
                    replies.append(subject.submitAssertion(value))
                    group.leave()
                }
            }
            XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
            XCTAssertEqual(replies.snapshot().compactMap(outcome).sorted(by: {
                $0.rawValue < $1.rawValue
            }), [.accepted, .current])
            XCTAssertEqual(subject.snapshot().generation, 1)
        }

        do {
            let subject = verifier()
            let c0 = subject.issueChallenge()!
            let c1 = subject.issueChallenge()!
            let left = assertion(
                sequence: 0, predecessor: fixed(11), lineage: fixed(80),
                body: fixed(81), nonce: fixed(82)
            )
            let right = assertion(
                sequence: 0, predecessor: fixed(11), lineage: fixed(83),
                body: fixed(84), nonce: fixed(85)
            )
            let replies = LockedReplies()
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "h4.private.siblings", attributes: .concurrent)
            for value in [request(c0, left, id: 3), request(c1, right, id: 4)] {
                group.enter()
                queue.async {
                    replies.append(subject.submitAssertion(value))
                    group.leave()
                }
            }
            XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
            XCTAssertEqual(replies.snapshot().compactMap(outcome).sorted(by: {
                $0.rawValue < $1.rawValue
            }), [.accepted, .inspection])
            let snapshot = subject.snapshot()
            XCTAssertEqual(snapshot.lifecycle, .conflict)
            XCTAssertEqual(snapshot.generation, 2)
            XCTAssertEqual(snapshot.conflictReserve, .complete)
        }
    }

    func testAtomicRecoveryMatrixForBootstrap() {
        let recoverable: [(
            V.StoreCut, V.RecoveryStatus, V.Lifecycle, V.FaultCode?
        )] = [
            (.beforeMutation, .ready, .uninitialized, nil),
            (.oldPointer, .ready, .uninitialized, nil),
            (.expectationMismatch, .ready, .uninitialized, nil),
            (.durableChildBeforePointer, .committed, .active, nil),
            (.pointerAdvancedBeforeResponse, .committed, .active, nil),
            (.containedTornRecord, .faultLocked, .storageFaultLocked, .tornOrDivergent),
            (.permanentIO, .faultLocked, .storageFaultLocked, .io),
            (.permanentCapacity, .faultLocked, .storageFaultLocked, .capacity),
            (.outcomeUnproven, .faultLocked, .storageFaultLocked, .outcomeUnproven)
        ]
        for (index, row) in recoverable.enumerated() {
            let subject = verifier(cuts: [1: row.0])
            let candidate = assertion(sequence: 0, predecessor: fixed(11))
            XCTAssertNil(outcome(submit(subject, candidate, id: index)))
            XCTAssertEqual(subject.snapshot().service, .recoveryRequired)
            XCTAssertEqual(subject.recoverAfterInterruption(), row.1)
            let snapshot = subject.snapshot()
            XCTAssertEqual(snapshot.lifecycle, row.2)
            XCTAssertEqual(snapshot.service, .ready)
            if row.2 == .storageFaultLocked {
                XCTAssertEqual(snapshot.faultReserve, .complete)
                XCTAssertEqual(snapshot.generation, 1)
                XCTAssertEqual(snapshot.history.last?.faultCode, row.3)
                XCTAssertEqual(snapshot.history.last?.attemptedKind, .accepted)
                XCTAssertEqual(outcome(submit(subject, candidate, id: 100 + index)), .unavailable)
            } else if row.2 == .active {
                XCTAssertEqual(outcome(submit(subject, candidate, id: 100 + index)), .current)
            } else {
                XCTAssertEqual(outcome(submit(subject, candidate, id: 100 + index)), .accepted)
            }
        }
    }

    func testUnrecoverableStoreStatesFailClosed() {
        let cuts: [V.StoreCut] = [
            .unexcludedTornRecord, .badAuthentication, .indexGap,
            .divergentBacklink, .multipleChild, .uncertainPointer
        ]
        for (index, cut) in cuts.enumerated() {
            let subject = verifier(cuts: [1: cut])
            let candidate = assertion(sequence: 0, predecessor: fixed(11))
            XCTAssertNil(outcome(submit(subject, candidate, id: index)))
            XCTAssertEqual(subject.recoverAfterInterruption(), .offline)
            XCTAssertEqual(subject.snapshot().service, .offline)
            XCTAssertNil(subject.issueChallenge())
        }

        let unknown = verifier(cuts: [1: .rollbackQualificationUnknown])
        XCTAssertNil(outcome(submit(
            unknown,
            assertion(sequence: 0, predecessor: fixed(11)),
            id: 99
        )))
        XCTAssertEqual(
            unknown.recoverAfterInterruption(),
            .rollbackQualificationUnknown
        )
        XCTAssertEqual(unknown.snapshot().service, .rollbackQualificationUnknown)
        XCTAssertNil(unknown.issueChallenge())
    }

    func testFaultLatchCutCannotManufactureSiblingLatch() {
        let subject = verifier(cuts: [
            1: .permanentIO,
            2: .containedTornRecord
        ])
        let candidate = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertNil(outcome(submit(subject, candidate, id: 1)))
        XCTAssertEqual(subject.recoverAfterInterruption(), .recoveryRequired)
        XCTAssertEqual(subject.snapshot().faultReserve, .containedResidue)
        XCTAssertEqual(subject.recoverAfterInterruption(), .offline)
        XCTAssertEqual(subject.snapshot().history.count, 1)
    }

    func testConflictIsNotReportedBeforeItsPointerLinearizes() {
        let subject = verifier(cuts: [2: .beforeMutation])
        let first = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertEqual(outcome(submit(subject, first, id: 1)), .accepted)
        let competitor = assertion(
            sequence: 0, predecessor: fixed(11), lineage: fixed(90),
            body: fixed(91), nonce: fixed(92)
        )
        XCTAssertEqual(
            subject.submitAssertion(V.AssertionRequest(
                challenge: subject.issueChallenge()!,
                requestCommitment: fixed(30, 2),
                embedded: .eligible(competitor)
            )),
            .noAuthenticatedResponse
        )
        XCTAssertEqual(subject.snapshot().lifecycle, .active)
        XCTAssertEqual(subject.recoverAfterInterruption(), .ready)
        XCTAssertEqual(subject.snapshot().conflictReserve, .unused)
        XCTAssertEqual(outcome(submit(subject, competitor, id: 3)), .inspection)
        XCTAssertEqual(subject.snapshot().lifecycle, .conflict)
    }

    func testTerminalGatesMigrationAndIdempotence() {
        let uninitialized = verifier()
        let before = uninitialized.snapshot()
        let forbidden = close(pointer: before.pointer, id: 1)
        XCTAssertEqual(
            uninitialized.submitTerminal(forbidden, authorization: authorization(forbidden)),
            .rejectedWithoutSignedDetail
        )
        XCTAssertEqual(uninitialized.snapshot().generation, 0)

        let active = verifier()
        let zero = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertEqual(outcome(submit(active, zero, id: 2)), .accepted)
        let migrationRequest = migration(pointer: active.snapshot().pointer, id: 3)
        guard case .receipt(let migrationReceipt, migration: let package) =
            active.submitTerminal(
                migrationRequest,
                authorization: authorization(migrationRequest)
            ) else { return XCTFail("Expected migration receipt") }
        XCTAssertEqual(migrationReceipt.outcome, .terminalCommitted)
        XCTAssertEqual(migrationReceipt.continuityCode, 1)
        XCTAssertNotNil(package)
        let terminalSnapshot = active.snapshot()
        XCTAssertEqual(terminalSnapshot.lifecycle, .terminal)
        XCTAssertEqual(terminalSnapshot.terminalReserve, .complete)

        guard case .receipt(let replay, migration: let replayPackage) =
            active.submitTerminal(
                migrationRequest,
                authorization: authorization(migrationRequest)
            ) else { return XCTFail("Expected idempotent terminal receipt") }
        XCTAssertEqual(replay.outcome, .terminalCommitted)
        XCTAssertNotNil(replayPackage)
        XCTAssertEqual(active.snapshot().generation, terminalSnapshot.generation)

        let sameCommitmentDifferentRequest = V.TerminalRequest(
            commitment: migrationRequest.commitment,
            expectedPointer: migrationRequest.expectedPointer,
            kind: .migration,
            reason: .plannedMigration,
            newGenesisIntent: fixed(42, 999),
            newVerifierID: migrationRequest.newVerifierID,
            migrationNonce: migrationRequest.migrationNonce
        )
        XCTAssertEqual(
            active.submitTerminal(
                sameCommitmentDifferentRequest,
                authorization: authorization(sameCommitmentDifferentRequest)
            ),
            .rejectedWithoutSignedDetail
        )
        XCTAssertEqual(active.snapshot().generation, terminalSnapshot.generation)

        let different = migration(pointer: terminalSnapshot.pointer, id: 4)
        XCTAssertEqual(
            active.submitTerminal(different, authorization: authorization(different)),
            .rejectedWithoutSignedDetail
        )
        XCTAssertEqual(active.snapshot().generation, terminalSnapshot.generation)
        XCTAssertEqual(outcome(submit(active, zero, id: 5)), .rejected)
    }

    func testTerminalCloseIsExactlyIdempotent() {
        let subject = verifier()
        let zero = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertEqual(outcome(submit(subject, zero, id: 1)), .accepted)

        let request = close(
            pointer: subject.snapshot().pointer,
            id: 2,
            reason: .plannedClose
        )
        guard case .receipt(let committed, migration: nil) =
            subject.submitTerminal(request, authorization: authorization(request))
        else { return XCTFail("Expected close receipt") }
        XCTAssertEqual(committed.outcome, .terminalCommitted)
        XCTAssertEqual(committed.continuityCode, 0)
        let terminal = subject.snapshot()

        guard case .receipt(let replay, migration: nil) =
            subject.submitTerminal(request, authorization: authorization(request))
        else { return XCTFail("Expected idempotent close receipt") }
        XCTAssertEqual(replay, committed)
        XCTAssertEqual(subject.snapshot().generation, terminal.generation)
        XCTAssertEqual(subject.snapshot().pointer, terminal.pointer)

        let sameCommitmentDifferentRequest = V.TerminalRequest(
            commitment: request.commitment,
            expectedPointer: request.expectedPointer,
            kind: .close,
            reason: .compromise,
            newGenesisIntent: nil,
            newVerifierID: nil,
            migrationNonce: nil
        )
        XCTAssertEqual(
            subject.submitTerminal(
                sameCommitmentDifferentRequest,
                authorization: authorization(sameCommitmentDifferentRequest)
            ),
            .rejectedWithoutSignedDetail
        )
        XCTAssertEqual(subject.snapshot().generation, terminal.generation)
        XCTAssertEqual(subject.snapshot().pointer, terminal.pointer)
    }

    func testConflictAndFaultTerminalGates() {
        let conflictVerifier = verifier()
        let first = assertion(sequence: 0, predecessor: fixed(11))
        let competing = assertion(
            sequence: 0, predecessor: fixed(11), lineage: fixed(100),
            body: fixed(101), nonce: fixed(102)
        )
        XCTAssertEqual(outcome(submit(conflictVerifier, first, id: 1)), .accepted)
        XCTAssertEqual(outcome(submit(conflictVerifier, competing, id: 2)), .inspection)
        var pointer = conflictVerifier.snapshot().pointer
        let capacityClose = close(
            pointer: pointer, id: 3, reason: .capacityRetirement
        )
        XCTAssertEqual(
            conflictVerifier.submitTerminal(
                capacityClose, authorization: authorization(capacityClose)
            ),
            .rejectedWithoutSignedDetail
        )
        let forbiddenMigration = migration(pointer: pointer, id: 4)
        XCTAssertEqual(
            conflictVerifier.submitTerminal(
                forbiddenMigration, authorization: authorization(forbiddenMigration)
            ),
            .rejectedWithoutSignedDetail
        )
        let allowedClose = close(pointer: pointer, id: 5, reason: .compromise)
        guard case .receipt(let receipt, migration: nil) =
            conflictVerifier.submitTerminal(
                allowedClose, authorization: authorization(allowedClose)
            ) else { return XCTFail("Expected conflict close") }
        XCTAssertEqual(receipt.outcome, .terminalCommitted)

        let faultVerifier = verifier(cuts: [1: .permanentIO])
        XCTAssertNil(outcome(submit(faultVerifier, first, id: 6)))
        XCTAssertEqual(faultVerifier.recoverAfterInterruption(), .faultLocked)
        pointer = faultVerifier.snapshot().pointer
        let planned = close(pointer: pointer, id: 7, reason: .plannedClose)
        XCTAssertEqual(
            faultVerifier.submitTerminal(planned, authorization: authorization(planned)),
            .rejectedWithoutSignedDetail
        )
        let retire = close(pointer: pointer, id: 8, reason: .faultRetirement)
        guard case .receipt(let retired, migration: nil) =
            faultVerifier.submitTerminal(retire, authorization: authorization(retire))
            else { return XCTFail("Expected fault retirement") }
        XCTAssertEqual(retired.outcome, .terminalCommitted)
        XCTAssertEqual(faultVerifier.snapshot().lifecycle, .terminal)
    }

    func testTerminalAmbiguityRequiresExactTerminalRetry() {
        let subject = verifier(cuts: [2: .permanentIO])
        let zero = assertion(sequence: 0, predecessor: fixed(11))
        XCTAssertEqual(outcome(submit(subject, zero, id: 1)), .accepted)
        let terminalRequest = close(pointer: subject.snapshot().pointer, id: 2)
        XCTAssertEqual(
            subject.submitTerminal(
                terminalRequest, authorization: authorization(terminalRequest)
            ),
            .noAuthenticatedResponse
        )
        XCTAssertEqual(subject.recoverAfterInterruption(), .faultLocked)
        XCTAssertEqual(outcome(submit(subject, zero, id: 3)), .unavailable)

        let different = close(
            pointer: subject.snapshot().pointer,
            id: 4,
            reason: .plannedClose
        )
        XCTAssertEqual(
            subject.submitTerminal(different, authorization: authorization(different)),
            .rejectedWithoutSignedDetail
        )
        guard case .receipt(let unavailable, migration: nil) =
            subject.submitTerminal(
                terminalRequest, authorization: authorization(terminalRequest)
            ) else { return XCTFail("Expected exact terminal unavailable receipt") }
        XCTAssertEqual(unavailable.outcome, .unavailable)
        XCTAssertEqual(unavailable.result.tipKind, .fault)
    }

    func testFaultLockedTerminalPrelinearizationCutsRemainFaultLocked() {
        let prelinearizationCuts: [V.StoreCut] = [
            .beforeMutation,
            .oldPointer,
            .expectationMismatch,
        ]

        for cut in prelinearizationCuts {
            let subject = verifier(cuts: [1: .permanentIO, 3: cut])
            let zero = assertion(sequence: 0, predecessor: fixed(11))
            XCTAssertNil(outcome(submit(subject, zero, id: 1)))
            XCTAssertEqual(subject.recoverAfterInterruption(), .faultLocked)

            let before = subject.snapshot()
            let retire = close(
                pointer: before.pointer,
                id: 2,
                reason: .faultRetirement
            )
            XCTAssertEqual(
                subject.submitTerminal(
                    retire,
                    authorization: authorization(retire)
                ),
                .noAuthenticatedResponse
            )
            XCTAssertEqual(subject.recoverAfterInterruption(), .faultLocked)

            let after = subject.snapshot()
            XCTAssertEqual(after.lifecycle, .storageFaultLocked)
            XCTAssertEqual(after.generation, before.generation)
            XCTAssertEqual(after.pointer, before.pointer)
            XCTAssertEqual(after.terminalReserve, .unused)
        }
    }

    func testCapacityAndAllThreeReservesReachGeneration4099() {
        let subject = verifier(
            challengeCount: 4_110,
            cuts: [4_098: .permanentIO]
        )
        var predecessor = fixed(11)
        var accepted: [V.EligibleAssertion] = []
        for sequence in 0...V.maximumAcceptedSequence {
            let candidate = assertion(sequence: sequence, predecessor: predecessor)
            XCTAssertEqual(outcome(submit(subject, candidate, id: sequence)), .accepted)
            accepted.append(candidate)
            predecessor = candidate.lineageState
        }
        var snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.generation, 4_096)
        XCTAssertEqual(snapshot.acceptedSequence, 4_095)
        XCTAssertEqual(snapshot.ordinarySlotsConsumed, 4_096)

        let overCapacity = assertion(
            sequence: V.capacityCandidateSequence,
            predecessor: predecessor
        )
        XCTAssertEqual(outcome(submit(subject, overCapacity, id: 4_096)), .rejected)
        XCTAssertEqual(subject.snapshot().generation, 4_096)

        let occupied = accepted[V.maximumAcceptedSequence]
        let conflict = assertion(
            sequence: V.maximumAcceptedSequence,
            predecessor: occupied.predecessor,
            lineage: fixed(110), body: fixed(111), nonce: fixed(112)
        )
        XCTAssertEqual(outcome(submit(subject, conflict, id: 4_097)), .inspection)
        snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.generation, 4_097)
        XCTAssertEqual(snapshot.conflictReserve, .complete)

        let failedClose = close(pointer: snapshot.pointer, id: 4_098)
        XCTAssertEqual(
            subject.submitTerminal(failedClose, authorization: authorization(failedClose)),
            .noAuthenticatedResponse
        )
        XCTAssertEqual(subject.recoverAfterInterruption(), .faultLocked)
        snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.generation, 4_098)
        XCTAssertEqual(snapshot.faultReserve, .complete)

        let retirement = close(
            pointer: snapshot.pointer,
            id: 4_099,
            reason: .faultRetirement
        )
        guard case .receipt(let receipt, migration: nil) =
            subject.submitTerminal(retirement, authorization: authorization(retirement))
            else { return XCTFail("Expected generation-4099 terminal") }
        XCTAssertEqual(receipt.outcome, .terminalCommitted)
        snapshot = subject.snapshot()
        XCTAssertEqual(snapshot.generation, 4_099)
        XCTAssertEqual(snapshot.lifecycle, .terminal)
        XCTAssertEqual(snapshot.conflictReserve, .complete)
        XCTAssertEqual(snapshot.faultReserve, .complete)
        XCTAssertEqual(snapshot.terminalReserve, .complete)
        XCTAssertEqual(snapshot.history.count, 4_100)
        XCTAssertEqual(snapshot.retainedReceipts, 0)
    }
}

import Foundation
import XCTest

final class ManagedWorkspaceAssessmentLeaseTests: XCTestCase {
    private final class BeginResults: @unchecked Sendable {
        private let lock = NSLock()
        private var storedTokens: [ManagedWorkspaceAssessmentLease.Token] = []
        private var storedErrors: [ManagedWorkspaceAssessmentLease.LeaseError] = []

        func record(_ result: Result<ManagedWorkspaceAssessmentLease.Token,
                                    ManagedWorkspaceAssessmentLease.LeaseError>) {
            lock.lock()
            defer { lock.unlock() }
            switch result {
            case .success(let token): storedTokens.append(token)
            case .failure(let error): storedErrors.append(error)
            }
        }

        func snapshot() -> ([ManagedWorkspaceAssessmentLease.Token],
                            [ManagedWorkspaceAssessmentLease.LeaseError]) {
            lock.lock()
            defer { lock.unlock() }
            return (storedTokens, storedErrors)
        }
    }

    @discardableResult
    private func settle(_ lease: ManagedWorkspaceAssessmentLease,
                        token: ManagedWorkspaceAssessmentLease.Token,
                        disposition: ManagedWorkspaceAssessmentLease.SettlementDisposition = .completed) throws
        -> ManagedWorkspaceAssessmentLease.PostflightWitness {
        let returned = try lease.recordWorkerReturned(token)
        let postflight = try lease.recordPostflightSettled(returned, disposition: disposition)
        try lease.release(postflight)
        return postflight
    }

    func testOnlyOneAssessmentCanHoldTheLease() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        XCTAssertEqual(lease.status.phase, .idle)

        let token = try lease.begin(workspaceID: .prime)
        XCTAssertTrue(lease.isActive)
        XCTAssertFalse(lease.cancellationRequested)
        XCTAssertEqual(token.workspaceID, .prime)
        XCTAssertEqual(lease.status,
                       .init(phase: .active, workspaceID: .prime, generation: token.generation))

        XCTAssertThrowsError(try lease.begin(workspaceID: .prime)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .alreadyActive)
        }
        XCTAssertTrue(lease.isActive)
        try settle(lease, token: token)
    }

    func testUnregisteredWorkspaceCannotAcquireLease() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let unregistered = try XCTUnwrap(
            ManagedWorkspaceID(rawValue: "unregistered-test-workspace")
        )
        XCTAssertThrowsError(try lease.begin(workspaceID: unregistered)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .unknownWorkspace)
        }
        XCTAssertEqual(lease.status.phase, .idle)
    }

    func testCancellationKeepsLeaseThroughReturnAndPostflight() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let token = try lease.begin(workspaceID: .prime)

        try lease.requestCancellation(token)
        XCTAssertTrue(lease.isActive)
        XCTAssertTrue(lease.cancellationRequested)
        XCTAssertEqual(lease.status.phase, .cancellationRequested)
        XCTAssertThrowsError(try lease.begin(workspaceID: .prime)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .alreadyActive)
        }

        let returned = try lease.recordWorkerReturned(token)
        XCTAssertEqual(lease.status.phase, .workerReturned)
        XCTAssertTrue(lease.isActive)
        let postflight = try lease.recordPostflightSettled(returned, disposition: .completed)
        XCTAssertEqual(lease.status.phase, .postflightSettled)
        XCTAssertTrue(lease.isActive)
        try lease.release(postflight)
        XCTAssertEqual(lease.status.phase, .idle)
    }

    func testDirectReleaseBeforeOrderedTransitionsIsUnavailableByState() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let token = try lease.begin(workspaceID: .prime)
        let other = ManagedWorkspaceAssessmentLease()
        let otherToken = try other.begin(workspaceID: .prime)
        let foreignReturned = try other.recordWorkerReturned(otherToken)
        let foreignPostflight = try other.recordPostflightSettled(foreignReturned, disposition: .completed)

        XCTAssertThrowsError(try lease.release(foreignPostflight)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .invalidPhase)
        }
        XCTAssertEqual(lease.status.phase, .active)
        let returned = try lease.recordWorkerReturned(token)
        XCTAssertThrowsError(try lease.release(foreignPostflight)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .invalidPhase)
        }
        let postflight = try lease.recordPostflightSettled(returned, disposition: .completed)
        try lease.release(postflight)
        try other.release(foreignPostflight)
    }

    func testStaleTokenCannotAffectLaterAssessment() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let first = try lease.begin(workspaceID: .prime)
        try settle(lease, token: first)

        let second = try lease.begin(workspaceID: .prime)
        XCTAssertGreaterThan(second.generation, first.generation)
        XCTAssertNotEqual(second, first)
        for operation in [
            { try lease.requestCancellation(first) },
            { _ = try lease.recordWorkerReturned(first) }
        ] {
            XCTAssertThrowsError(try operation()) {
                XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .staleToken)
            }
        }
        XCTAssertEqual(lease.status.generation, second.generation)
        try settle(lease, token: second)
    }

    func testRepeatedCancellationIsIdempotentButLateCancellationRejects() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let token = try lease.begin(workspaceID: .prime)
        try lease.requestCancellation(token)
        try lease.requestCancellation(token)
        let returned = try lease.recordWorkerReturned(token)
        XCTAssertThrowsError(try lease.requestCancellation(token)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .invalidPhase)
        }
        let postflight = try lease.recordPostflightSettled(returned, disposition: .completed)
        try lease.release(postflight)
        XCTAssertThrowsError(try lease.requestCancellation(token)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .staleToken)
        }
    }

    func testAbandonedDispositionStillRequiresFullSettlementOrder() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let token = try lease.begin(workspaceID: .prime)
        let returned = try lease.recordWorkerReturned(token)
        let postflight = try lease.recordPostflightSettled(returned, disposition: .abandoned)
        XCTAssertEqual(postflight.disposition, .abandoned)
        XCTAssertTrue(lease.isActive)
        try lease.release(postflight)
        XCTAssertFalse(lease.isActive)
    }

    func testAliasesShareOneOwnerRatherThanForkingLeaseState() throws {
        let owner = ManagedWorkspaceAssessmentLease()
        let alias = owner
        let token = try owner.begin(workspaceID: .prime)
        try alias.requestCancellation(token)
        XCTAssertEqual(owner.status.phase, .cancellationRequested)
        try settle(alias, token: token)
        XCTAssertEqual(owner.status.phase, .idle)
    }

    func testGenerationExhaustionFailsClosedWithoutAcquiringLease() throws {
        let lease = ManagedWorkspaceAssessmentLease(testNextGeneration: UInt64.max)
        XCTAssertThrowsError(try lease.begin(workspaceID: .prime)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError,
                           .generationExhausted)
        }
        XCTAssertEqual(lease.status.phase, .idle)

        let boundary = ManagedWorkspaceAssessmentLease(testNextGeneration: UInt64.max - 1)
        let finalToken = try boundary.begin(workspaceID: .prime)
        XCTAssertEqual(finalToken.generation, UInt64.max - 1)
        try settle(boundary, token: finalToken)
        XCTAssertThrowsError(try boundary.begin(workspaceID: .prime)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError,
                           .generationExhausted)
        }
        XCTAssertEqual(boundary.status.phase, .idle)
    }

    func testTokenFromAnotherLeaseCannotActuateThisOwner() throws {
        let first = ManagedWorkspaceAssessmentLease()
        let second = ManagedWorkspaceAssessmentLease()
        let firstToken = try first.begin(workspaceID: .prime)
        let secondToken = try second.begin(workspaceID: .prime)
        XCTAssertEqual(firstToken.generation, secondToken.generation)
        XCTAssertNotEqual(firstToken, secondToken)

        XCTAssertThrowsError(try second.requestCancellation(firstToken)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .staleToken)
        }
        XCTAssertThrowsError(try second.recordWorkerReturned(firstToken)) {
            XCTAssertEqual($0 as? ManagedWorkspaceAssessmentLease.LeaseError, .staleToken)
        }
        XCTAssertEqual(second.status.generation, secondToken.generation)
        try settle(first, token: firstToken)
        try settle(second, token: secondToken)
    }

    func testConcurrentBeginHasExactlyOneWinner() throws {
        let lease = ManagedWorkspaceAssessmentLease()
        let results = BeginResults()
        DispatchQueue.concurrentPerform(iterations: 32) { _ in
            do { results.record(.success(try lease.begin(workspaceID: .prime))) }
            catch let error as ManagedWorkspaceAssessmentLease.LeaseError {
                results.record(.failure(error))
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        let (tokens, errors) = results.snapshot()
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(errors.count, 31)
        XCTAssertTrue(errors.allSatisfy { $0 == .alreadyActive })
        try settle(lease, token: try XCTUnwrap(tokens.first))
    }
}

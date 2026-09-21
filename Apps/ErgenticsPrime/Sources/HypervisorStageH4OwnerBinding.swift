import Foundation

/// H4-D is the process-local construction-provenance boundary between the
/// H4-A/B dispatcher and H4-C's independent canonical streams. It performs no
/// persistence and creates no serialized owner identifier. A successful value
/// says only that one fresh dispatcher atomically supplied both canonical
/// inputs under its retained owner/epoch anchor.
enum HypervisorStageH4OwnerBinding {
    static let schema =
        "com.ergentics.provenance.hypervisor.h4.owner-bound-canonical.v1"

    enum Failure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case priorExtraction
        case expired
        case projectionRejected
        case ownerMismatch
        case poisoned
    }

    fileprivate enum PersistenceClaimFailure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case persistenceRequiresInspection
        case expired
        case poisoned
    }

    fileprivate enum PersistenceTerminalDisposition: Sendable {
        case transaction
        case prepublication
        case staging
        case publication
        case published
        case leaseCompletion
    }

    fileprivate enum PersistenceCompletion: Sendable {
        case admitted
        case rejectedBeforePublication
        case terminalUnknown(PersistenceTerminalDisposition)
    }

    fileprivate final class PersistenceClaimToken: @unchecked Sendable {}

    fileprivate enum StoreGrantFailure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case persistenceRequiresInspection
        case expired
        case ownerMismatch
        case poisoned
    }

    fileprivate enum StoreGrantCompletion: Sendable {
        case admitted
        case rejectedBeforePublication
        case terminalUnknown(PersistenceTerminalDisposition)
    }

    fileprivate final class StoreGrantClaimToken: @unchecked Sendable {}

    /// Module-internal, unforgeable claim. It is never a sink payload and has
    /// no Codable, Hashable, Equatable, owner, epoch, path, or ID surface.
    fileprivate struct PersistenceClaim: @unchecked Sendable {
        let canonical: HypervisorStageH4CanonicalStreams.Projection
        fileprivate let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
        fileprivate let token: PersistenceClaimToken

        fileprivate func remainsLive() -> Bool { ownerAnchor.isLive() }
    }

    /// PRIV-006's separate retention capability. The D1 handoff does not own
    /// this grant. A grant is fixed to one private fixture store, one owner
    /// anchor, the SQLite-projection recipient, a declared retention rule, and
    /// its own monotonic admission cutoff. Its production mint is absent.
    fileprivate final class PersistenceStoreGrant: @unchecked Sendable {
        fileprivate static let retentionRule =
            "private-fixture-until-explicit-test-teardown"

        private enum State {
            case ready
            case claimed(StoreGrantClaimToken)
            case admitted
            case poisoned
            case terminalUnknown(PersistenceTerminalDisposition)
        }

        fileprivate struct Claim: @unchecked Sendable {
            fileprivate let store: HypervisorStageH4Persistence.Store
            fileprivate let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
            fileprivate let validThroughTick: UInt64
            fileprivate let readTick: @Sendable () -> UInt64
            fileprivate let token: StoreGrantClaimToken

            fileprivate func remainsLive() -> Bool {
                ownerAnchor.isLive() && readTick() <= validThroughTick
            }
        }

        private let lock = NSLock()
        private let transitionLock = NSLock()
        private let store: HypervisorStageH4Persistence.Store
        private let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
        private let validThroughTick: UInt64
        private let readTick: @Sendable () -> UInt64
        private let purpose = HypervisorStageH4Privacy.Purpose
            .durableReceiptVerification
        private let operation = HypervisorStageH4Privacy.Operation
            .projectForPersistence
        private let recipient = HypervisorStageH4Privacy.Recipient.sqliteProjection
        private let persistence = HypervisorStageH4Privacy.Persistence.privateSQLite
        private var state: State = .ready
        #if EPR_H4_PRIVACY_TESTS
        private var rejectNextCompletionForTest = false
        #endif

        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            store: HypervisorStageH4Persistence.Store,
            validThroughTick: UInt64,
            readTick: @escaping @Sendable () -> UInt64
        ) {
            self.store = store
            ownerAnchor = bound.persistenceOwnerAnchor
            self.validThroughTick = validThroughTick
            self.readTick = readTick
        }

        fileprivate func begin(
            _ persistenceClaim: PersistenceClaim
        ) -> Result<Claim, StoreGrantFailure> {
            lock.lock()
            defer { lock.unlock() }
            switch state {
            case .ready:
                guard ownerAnchor === persistenceClaim.ownerAnchor else {
                    state = .poisoned
                    return .failure(.ownerMismatch)
                }
                guard readTick() <= validThroughTick else {
                    state = .poisoned
                    return .failure(.expired)
                }
                let token = StoreGrantClaimToken()
                state = .claimed(token)
                return .success(Claim(
                    store: store,
                    ownerAnchor: ownerAnchor,
                    validThroughTick: validThroughTick,
                    readTick: readTick,
                    token: token
                ))
            case .claimed:
                return .failure(.inProgress)
            case .admitted:
                return .failure(.alreadyConsumed)
            case .poisoned:
                return .failure(.poisoned)
            case .terminalUnknown:
                return .failure(.persistenceRequiresInspection)
            }
        }

        fileprivate func lockCoordinatorTransition() {
            transitionLock.lock()
        }

        fileprivate func unlockCoordinatorTransition() {
            transitionLock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func tryCoordinatorTransitionForTestOnly() -> Bool {
            transitionLock.try()
        }
        #endif

        @discardableResult
        fileprivate func complete(
            _ claim: Claim,
            as completion: StoreGrantCompletion
        ) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            #if EPR_H4_PRIVACY_TESTS
            if rejectNextCompletionForTest {
                rejectNextCompletionForTest = false
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            #endif
            guard case .claimed(let expected) = state,
                  expected === claim.token else {
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            switch completion {
            case .admitted:
                state = .admitted
            case .rejectedBeforePublication:
                state = .poisoned
            case .terminalUnknown(let disposition):
                state = .terminalUnknown(disposition)
            }
            return true
        }

        fileprivate func forceTerminalInspection(
            _ disposition: PersistenceTerminalDisposition
        ) {
            lock.lock()
            state = .terminalUnknown(disposition)
            lock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func rejectNextCompletionForTestOnly() {
            lock.lock()
            rejectNextCompletionForTest = true
            lock.unlock()
        }
        #endif
    }

    fileprivate enum DualStreamStoreGrantFailure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case persistenceRequiresInspection
        case expired
        case ownerMismatch
        case poisoned
    }

    fileprivate enum DualStreamStoreGrantCompletion: Sendable {
        case admitted
        case rejectedBeforePublication
        case terminalUnknown(PersistenceTerminalDisposition)
    }

    fileprivate final class DualStreamStoreGrantClaimToken: @unchecked Sendable {}

    /// D3's store-side grant is deliberately separate from D2b's store grant,
    /// while both coordinators contend on the one existing owner persistence
    /// lease. The grant fixes one D3 store, owner anchor, lifetime and retention
    /// rule; its production mint is absent.
    fileprivate final class DualStreamPersistenceStoreGrant: @unchecked Sendable {
        fileprivate static let retentionRule =
            "private-d3-fixture-until-explicit-test-teardown"

        private enum State {
            case ready
            case claimed(DualStreamStoreGrantClaimToken)
            case admitted
            case poisoned
            case terminalUnknown(PersistenceTerminalDisposition)
        }

        fileprivate struct Claim: @unchecked Sendable {
            fileprivate let store: HypervisorStageH4DualStreamPersistence.Store
            fileprivate let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
            fileprivate let validThroughTick: UInt64
            fileprivate let readTick: @Sendable () -> UInt64
            fileprivate let token: DualStreamStoreGrantClaimToken

            fileprivate func remainsLive() -> Bool {
                ownerAnchor.isLive() && readTick() <= validThroughTick
            }
        }

        private let lock = NSLock()
        private let transitionLock = NSLock()
        private let store: HypervisorStageH4DualStreamPersistence.Store
        private let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
        private let validThroughTick: UInt64
        private let readTick: @Sendable () -> UInt64
        private let purpose = HypervisorStageH4Privacy.Purpose
            .durableReceiptVerification
        private let operation = HypervisorStageH4Privacy.Operation
            .projectForPersistence
        private let recipient = HypervisorStageH4Privacy.Recipient.sqliteProjection
        private let persistence = HypervisorStageH4Privacy.Persistence.privateSQLite
        private var state: State = .ready
        #if EPR_H4_PRIVACY_TESTS
        private var rejectNextCompletionForTest = false
        #endif

        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            store: HypervisorStageH4DualStreamPersistence.Store,
            validThroughTick: UInt64,
            readTick: @escaping @Sendable () -> UInt64
        ) {
            self.store = store
            ownerAnchor = bound.persistenceOwnerAnchor
            self.validThroughTick = validThroughTick
            self.readTick = readTick
        }

        fileprivate func begin(
            _ persistenceClaim: PersistenceClaim
        ) -> Result<Claim, DualStreamStoreGrantFailure> {
            lock.lock()
            defer { lock.unlock() }
            switch state {
            case .ready:
                guard ownerAnchor === persistenceClaim.ownerAnchor else {
                    state = .poisoned
                    return .failure(.ownerMismatch)
                }
                guard readTick() <= validThroughTick else {
                    state = .poisoned
                    return .failure(.expired)
                }
                let token = DualStreamStoreGrantClaimToken()
                state = .claimed(token)
                return .success(Claim(
                    store: store,
                    ownerAnchor: ownerAnchor,
                    validThroughTick: validThroughTick,
                    readTick: readTick,
                    token: token
                ))
            case .claimed:
                return .failure(.inProgress)
            case .admitted:
                return .failure(.alreadyConsumed)
            case .poisoned:
                return .failure(.poisoned)
            case .terminalUnknown:
                return .failure(.persistenceRequiresInspection)
            }
        }

        fileprivate func lockCoordinatorTransition() {
            transitionLock.lock()
        }

        fileprivate func unlockCoordinatorTransition() {
            transitionLock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        enum TestState: Equatable, Sendable {
            case ready
            case claimed
            case admitted
            case poisoned
            case terminalUnknown
        }

        fileprivate func tryCoordinatorTransitionForTestOnly() -> Bool {
            transitionLock.try()
        }

        fileprivate func stateForTestOnly() -> TestState {
            lock.lock()
            defer { lock.unlock() }
            switch state {
            case .ready: return .ready
            case .claimed: return .claimed
            case .admitted: return .admitted
            case .poisoned: return .poisoned
            case .terminalUnknown: return .terminalUnknown
            }
        }
        #endif

        @discardableResult
        fileprivate func complete(
            _ claim: Claim,
            as completion: DualStreamStoreGrantCompletion
        ) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            #if EPR_H4_PRIVACY_TESTS
            if rejectNextCompletionForTest {
                rejectNextCompletionForTest = false
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            #endif
            guard case .claimed(let expected) = state,
                  expected === claim.token else {
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            switch completion {
            case .admitted:
                state = .admitted
            case .rejectedBeforePublication:
                state = .poisoned
            case .terminalUnknown(let disposition):
                state = .terminalUnknown(disposition)
            }
            return true
        }

        fileprivate func forceTerminalInspection(
            _ disposition: PersistenceTerminalDisposition
        ) {
            lock.lock()
            state = .terminalUnknown(disposition)
            lock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func rejectNextCompletionForTestOnly() {
            lock.lock()
            rejectNextCompletionForTest = true
            lock.unlock()
        }
        #endif
    }

    final class PersistenceLease: @unchecked Sendable {
        private enum State {
            case available
            case claimed(PersistenceClaimToken)
            case admitted
            case poisoned
            case terminalUnknown(PersistenceTerminalDisposition)
        }

        private let lock = NSLock()
        private let transitionLock = NSLock()
        private let ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor
        private var state: State = .available
        #if EPR_H4_PRIVACY_TESTS
        private var rejectNextCompletionForTest = false
        #endif

        init(ownerAnchor: HypervisorStageH4Privacy.OwnerEpochAnchor) {
            self.ownerAnchor = ownerAnchor
        }

        fileprivate func begin(
            canonical: HypervisorStageH4CanonicalStreams.Projection
        ) -> Result<PersistenceClaim, PersistenceClaimFailure> {
            lock.lock()
            defer { lock.unlock() }
            switch state {
            case .available:
                guard ownerAnchor.isLive() else {
                    state = .poisoned
                    return .failure(.expired)
                }
                let token = PersistenceClaimToken()
                state = .claimed(token)
                return .success(PersistenceClaim(
                    canonical: canonical,
                    ownerAnchor: ownerAnchor,
                    token: token
                ))
            case .claimed:
                return .failure(.inProgress)
            case .admitted:
                return .failure(.alreadyConsumed)
            case .poisoned:
                return .failure(.poisoned)
            case .terminalUnknown:
                return .failure(.persistenceRequiresInspection)
            }
        }

        fileprivate func lockCoordinatorTransition() {
            transitionLock.lock()
        }

        fileprivate func unlockCoordinatorTransition() {
            transitionLock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func tryCoordinatorTransitionForTestOnly() -> Bool {
            transitionLock.try()
        }
        #endif

        @discardableResult
        fileprivate func complete(
            _ claim: PersistenceClaim,
            as completion: PersistenceCompletion
        ) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            #if EPR_H4_PRIVACY_TESTS
            if rejectNextCompletionForTest {
                rejectNextCompletionForTest = false
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            #endif
            guard case .claimed(let expected) = state,
                  expected === claim.token else {
                state = .terminalUnknown(.leaseCompletion)
                return false
            }
            switch completion {
            case .admitted:
                state = .admitted
            case .rejectedBeforePublication:
                state = .poisoned
            case .terminalUnknown(let disposition):
                state = .terminalUnknown(disposition)
            }
            return true
        }

        fileprivate func forceTerminalInspection(
            _ disposition: PersistenceTerminalDisposition
        ) {
            lock.lock()
            state = .terminalUnknown(disposition)
            lock.unlock()
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func rejectNextCompletionForTestOnly() {
            lock.lock()
            rejectNextCompletionForTest = true
            lock.unlock()
        }
        #endif

        func isBound(
            to expectedOwner: HypervisorStageH4Privacy.OwnerEpochAnchor
        ) -> Bool {
            ownerAnchor === expectedOwner
        }

        fileprivate var retainedOwnerAnchor:
            HypervisorStageH4Privacy.OwnerEpochAnchor { ownerAnchor }

        #if EPR_H4_PRIVACY_TESTS
        var ownerIdentityTest: ObjectIdentifier { ObjectIdentifier(ownerAnchor) }
        func bindingMatchesTest(epoch: String) -> Bool {
            ownerAnchor.matchesTest(epoch: epoch)
        }
        #endif
    }

    /// Opaque D1 handoff. Ordinary value copies retain the same inaccessible
    /// owner anchor, but the wrapper has no class identity, Codable
    /// representation, Hashable/Equatable conformance, owner label, or epoch
    /// accessor. D2 must add a separate one-shot persistence admission before
    /// any SQLite transaction is authorized.
    struct OwnerBoundCanonicalProjection: @unchecked Sendable, CustomReflectable {
        private let canonical: HypervisorStageH4CanonicalStreams.Projection
        private let persistenceLease: PersistenceLease

        /// The input initializer is unavailable outside the H4-A/B file, so a
        /// normal product caller cannot construct the required predecessor.
        init(
            canonical: HypervisorStageH4CanonicalStreams.Projection,
            input: HypervisorStageH4Privacy.CanonicalStreamInput
        ) {
            self.canonical = canonical
            persistenceLease = input.persistenceLease
        }

        /// Keep casual product reflection payload-free. This is minimization,
        /// not a claim against a debugger or a compromised same-process caller.
        var customMirror: Mirror {
            Mirror(self, children: EmptyCollection<(label: String?, value: Any)>(),
                   displayStyle: .struct)
        }

        func isBound(to expectedOwner: HypervisorStageH4Privacy.OwnerEpochAnchor) -> Bool {
            persistenceLease.isBound(to: expectedOwner)
        }

        fileprivate func beginPersistenceAdmission()
            -> Result<PersistenceClaim, PersistenceClaimFailure> {
            persistenceLease.begin(canonical: canonical)
        }

        @discardableResult
        fileprivate func completePersistenceAdmission(
            _ claim: PersistenceClaim,
            as completion: PersistenceCompletion
        ) -> Bool {
            persistenceLease.complete(claim, as: completion)
        }

        fileprivate func forcePersistenceInspection(
            _ disposition: PersistenceTerminalDisposition
        ) {
            persistenceLease.forceTerminalInspection(disposition)
        }

        fileprivate func lockPersistenceTransition() {
            persistenceLease.lockCoordinatorTransition()
        }

        fileprivate func unlockPersistenceTransition() {
            persistenceLease.unlockCoordinatorTransition()
        }

        fileprivate var persistenceOwnerAnchor:
            HypervisorStageH4Privacy.OwnerEpochAnchor {
            persistenceLease.retainedOwnerAnchor
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate func tryPersistenceTransitionForTestOnly() -> Bool {
            persistenceLease.tryCoordinatorTransitionForTestOnly()
        }

        fileprivate func rejectNextPersistenceCompletionForTestOnly() {
            persistenceLease.rejectNextCompletionForTestOnly()
        }

        var canonicalTest: HypervisorStageH4CanonicalStreams.Projection {
            canonical
        }
        var ownerIdentityTest: ObjectIdentifier {
            persistenceLease.ownerIdentityTest
        }

        func bindingMatchesTest(epoch: String) -> Bool {
            persistenceLease.bindingMatchesTest(epoch: epoch)
        }
        #endif
    }

    /// The only D2 operation surface. Its store is fixed at construction and
    /// production has no store mint in this slice, so callers cannot supply a
    /// path, SQL, bytes, deadline, fault, owner, epoch, or row identifier.
    final class PersistenceCoordinator: @unchecked Sendable, CustomReflectable {
        private enum TransitionStart {
            case ready(PersistenceClaim, PersistenceStoreGrant.Claim)
            case finished(HypervisorStageH4Persistence.Outcome)
        }

        private let bound: OwnerBoundCanonicalProjection
        private let storeGrant: PersistenceStoreGrant
        #if EPR_H4_PRIVACY_TESTS
        enum TestTransitionProbe: Equatable, Sendable {
            case available
            case storeBlocked
            case ownerBlocked
        }

        private let completionIntersticeForTest: (@Sendable () -> Void)?
        #endif

        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            storeGrant: PersistenceStoreGrant
        ) {
            self.bound = bound
            self.storeGrant = storeGrant
            #if EPR_H4_PRIVACY_TESTS
            completionIntersticeForTest = nil
            #endif
        }

        #if EPR_H4_PRIVACY_TESTS
        func probeTransitionForTestOnly() -> TestTransitionProbe {
            guard storeGrant.tryCoordinatorTransitionForTestOnly() else {
                return .storeBlocked
            }
            defer { storeGrant.unlockCoordinatorTransition() }
            guard bound.tryPersistenceTransitionForTestOnly() else {
                return .ownerBlocked
            }
            bound.unlockPersistenceTransition()
            return .available
        }

        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            storeGrant: PersistenceStoreGrant,
            completionIntersticeForTest: @escaping @Sendable () -> Void
        ) {
            self.bound = bound
            self.storeGrant = storeGrant
            self.completionIntersticeForTest = completionIntersticeForTest
        }
        #endif

        var customMirror: Mirror {
            Mirror(self, children: EmptyCollection<(label: String?, value: Any)>(),
                   displayStyle: .class)
        }

        func persist() -> HypervisorStageH4Persistence.Outcome {
            let start = beginTransition()
            guard case .ready(let claim, let storeClaim) = start else {
                guard case .finished(let outcome) = start else {
                    preconditionFailure("unreachable persistence transition")
                }
                return outcome
            }

            let result = storeClaim.store.append(
                claim.canonical,
                remainsLive: {
                    claim.remainsLive() && storeClaim.remainsLive()
                }
            )
            switch result {
            case .admitted(let receipt):
                guard completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .admitted,
                    leaseCompletion: .admitted
                ) else {
                    return .publishedUnverified(.leaseCompletionRejected)
                }
                return .admitted(receipt)
            case .rejectedBeforePublication(let failure):
                guard completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .rejectedBeforePublication,
                    leaseCompletion: .rejectedBeforePublication
                ) else {
                    return .prepublicationStateUnknown(.leaseCompletionRejected)
                }
                return .rejectedBeforePublication(failure)
            case .transactionOutcomeUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.transaction),
                    leaseCompletion: .terminalUnknown(.transaction)
                )
                return .transactionOutcomeUnknown(failure)
            case .prepublicationStateUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.prepublication),
                    leaseCompletion: .terminalUnknown(.prepublication)
                )
                return .prepublicationStateUnknown(failure)
            case .stagingRetained(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.staging),
                    leaseCompletion: .terminalUnknown(.staging)
                )
                return .stagingRetained(failure)
            case .publicationOutcomeUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.publication),
                    leaseCompletion: .terminalUnknown(.publication)
                )
                return .publicationOutcomeUnknown(failure)
            case .publishedUnverified(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.published),
                    leaseCompletion: .terminalUnknown(.published)
                )
                return .publishedUnverified(failure)
            }
        }

        private func beginTransition() -> TransitionStart {
            withStateTransition {
                let start = bound.beginPersistenceAdmission()
                guard case .success(let claim) = start else {
                    guard case .failure(let failure) = start else {
                        preconditionFailure("unreachable persistence claim result")
                    }
                    return .finished(.unavailable(Self.map(failure)))
                }

                let storeStart = storeGrant.begin(claim)
                guard case .success(let storeClaim) = storeStart else {
                    guard case .failure(let failure) = storeStart else {
                        preconditionFailure("unreachable store-grant claim result")
                    }
                    let leaseExact = bound.completePersistenceAdmission(
                        claim, as: .rejectedBeforePublication
                    )
                    guard leaseExact else {
                        bound.forcePersistenceInspection(.leaseCompletion)
                        return .finished(.unavailable(
                            .persistenceRequiresInspection
                        ))
                    }
                    return .finished(.unavailable(Self.map(failure)))
                }
                return .ready(claim, storeClaim)
            }
        }

        @discardableResult
        private func completeTransition(
            _ storeClaim: PersistenceStoreGrant.Claim,
            _ claim: PersistenceClaim,
            storeCompletion: StoreGrantCompletion,
            leaseCompletion: PersistenceCompletion
        ) -> Bool {
            withStateTransition {
                let storeExact = storeGrant.complete(
                    storeClaim, as: storeCompletion
                )
                #if EPR_H4_PRIVACY_TESTS
                completionIntersticeForTest?()
                #endif
                guard storeExact else {
                    forceCompletionInspection()
                    return false
                }
                let leaseExact = bound.completePersistenceAdmission(
                    claim, as: leaseCompletion
                )
                guard leaseExact else {
                    forceCompletionInspection()
                    return false
                }
                return true
            }
        }

        private func withStateTransition<T>(_ body: () -> T) -> T {
            // Every coordinator takes store then owner. Sharing either object
            // therefore makes the paired state change externally atomic.
            // The locks are never held across the physical store operation.
            storeGrant.lockCoordinatorTransition()
            bound.lockPersistenceTransition()
            defer {
                bound.unlockPersistenceTransition()
                storeGrant.unlockCoordinatorTransition()
            }
            return body()
        }

        private func forceCompletionInspection() {
            storeGrant.forceTerminalInspection(.leaseCompletion)
            bound.forcePersistenceInspection(.leaseCompletion)
        }

        private static func map(
            _ failure: PersistenceClaimFailure
        ) -> HypervisorStageH4Persistence.Failure {
            switch failure {
            case .inProgress: .inProgress
            case .alreadyConsumed: .alreadyConsumed
            case .persistenceRequiresInspection: .persistenceRequiresInspection
            case .expired: .expired
            case .poisoned: .poisoned
            }
        }

        private static func map(
            _ failure: StoreGrantFailure
        ) -> HypervisorStageH4Persistence.Failure {
            switch failure {
            case .inProgress: .inProgress
            case .alreadyConsumed: .alreadyConsumed
            case .persistenceRequiresInspection: .persistenceRequiresInspection
            case .expired: .expired
            case .ownerMismatch: .storeAdmissionRejected
            case .poisoned: .poisoned
            }
        }
    }

    /// D3's only operation surface. The store and all policy are fixed at
    /// construction. Production has no mint, so a caller cannot provide a
    /// root, path, descriptor, bytes, SQL, schema, deadline, owner or fault.
    final class DualStreamPersistenceCoordinator: @unchecked Sendable,
        CustomReflectable {
        private enum TransitionStart {
            case ready(PersistenceClaim, DualStreamPersistenceStoreGrant.Claim)
            case finished(HypervisorStageH4DualStreamPersistence.Outcome)
        }

        private let bound: OwnerBoundCanonicalProjection
        private let storeGrant: DualStreamPersistenceStoreGrant
        #if EPR_H4_PRIVACY_TESTS
        enum TestTransitionProbe: Equatable, Sendable {
            case available
            case storeBlocked
            case ownerBlocked
        }

        enum TestStoreGrantState: Equatable, Sendable {
            case ready
            case claimed
            case admitted
            case poisoned
            case terminalUnknown
        }

        private let completionIntersticeForTest: (@Sendable () -> Void)?
        #endif

        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            storeGrant: DualStreamPersistenceStoreGrant
        ) {
            self.bound = bound
            self.storeGrant = storeGrant
            #if EPR_H4_PRIVACY_TESTS
            completionIntersticeForTest = nil
            #endif
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate init(
            bound: OwnerBoundCanonicalProjection,
            storeGrant: DualStreamPersistenceStoreGrant,
            completionIntersticeForTest: @escaping @Sendable () -> Void
        ) {
            self.bound = bound
            self.storeGrant = storeGrant
            self.completionIntersticeForTest = completionIntersticeForTest
        }

        func probeTransitionForTestOnly() -> TestTransitionProbe {
            guard storeGrant.tryCoordinatorTransitionForTestOnly() else {
                return .storeBlocked
            }
            defer { storeGrant.unlockCoordinatorTransition() }
            guard bound.tryPersistenceTransitionForTestOnly() else {
                return .ownerBlocked
            }
            bound.unlockPersistenceTransition()
            return .available
        }

        func storeGrantStateForTestOnly() -> TestStoreGrantState {
            switch storeGrant.stateForTestOnly() {
            case .ready: return .ready
            case .claimed: return .claimed
            case .admitted: return .admitted
            case .poisoned: return .poisoned
            case .terminalUnknown: return .terminalUnknown
            }
        }
        #endif

        var customMirror: Mirror {
            Mirror(self, children: EmptyCollection<(label: String?, value: Any)>(),
                   displayStyle: .class)
        }

        func persist() -> HypervisorStageH4DualStreamPersistence.Outcome {
            let start = beginTransition()
            guard case .ready(let claim, let storeClaim) = start else {
                guard case .finished(let outcome) = start else {
                    preconditionFailure("unreachable D3 persistence transition")
                }
                return outcome
            }

            let result = storeClaim.store.append(
                claim.canonical,
                remainsLive: {
                    claim.remainsLive() && storeClaim.remainsLive()
                }
            )
            switch result {
            case .admitted(let receiptMint):
                guard completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .admitted,
                    leaseCompletion: .admitted
                ) else {
                    return .publishedUnverified(.leaseCompletionRejected)
                }
                guard let receipt = receiptMint.mint() else {
                    forceCompletionInspection()
                    return .publishedUnverified(.leaseCompletionRejected)
                }
                return .admitted(receipt)
            case .rejectedBeforePublication(let failure):
                guard completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .rejectedBeforePublication,
                    leaseCompletion: .rejectedBeforePublication
                ) else {
                    return .prepublicationStateUnknown(.leaseCompletionRejected)
                }
                return .rejectedBeforePublication(failure)
            case .transactionOutcomeUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.transaction),
                    leaseCompletion: .terminalUnknown(.transaction)
                )
                return .transactionOutcomeUnknown(failure)
            case .prepublicationStateUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.prepublication),
                    leaseCompletion: .terminalUnknown(.prepublication)
                )
                return .prepublicationStateUnknown(failure)
            case .stagingRetained(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.staging),
                    leaseCompletion: .terminalUnknown(.staging)
                )
                return .stagingRetained(failure)
            case .publicationOutcomeUnknown(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.publication),
                    leaseCompletion: .terminalUnknown(.publication)
                )
                return .publicationOutcomeUnknown(failure)
            case .publishedUnverified(let failure):
                completeTransition(
                    storeClaim,
                    claim,
                    storeCompletion: .terminalUnknown(.published),
                    leaseCompletion: .terminalUnknown(.published)
                )
                return .publishedUnverified(failure)
            }
        }

        private func beginTransition() -> TransitionStart {
            withStateTransition {
                // Locks are already held store then owner. Claim the shared
                // owner first so a D2b winner leaves this D3 grant untouched.
                let ownerStart = bound.beginPersistenceAdmission()
                guard case .success(let claim) = ownerStart else {
                    guard case .failure(let failure) = ownerStart else {
                        preconditionFailure("unreachable D3 owner claim result")
                    }
                    return .finished(.unavailable(Self.map(failure)))
                }

                let storeStart = storeGrant.begin(claim)
                guard case .success(let storeClaim) = storeStart else {
                    guard case .failure(let failure) = storeStart else {
                        preconditionFailure("unreachable D3 store claim result")
                    }
                    let leaseExact = bound.completePersistenceAdmission(
                        claim, as: .rejectedBeforePublication
                    )
                    guard leaseExact else {
                        bound.forcePersistenceInspection(.leaseCompletion)
                        return .finished(.unavailable(
                            .persistenceRequiresInspection
                        ))
                    }
                    return .finished(.unavailable(Self.map(failure)))
                }
                return .ready(claim, storeClaim)
            }
        }

        @discardableResult
        private func completeTransition(
            _ storeClaim: DualStreamPersistenceStoreGrant.Claim,
            _ claim: PersistenceClaim,
            storeCompletion: DualStreamStoreGrantCompletion,
            leaseCompletion: PersistenceCompletion
        ) -> Bool {
            withStateTransition {
                // Complete store then owner while both transition locks remain
                // held. No caller can observe an admitted half-state.
                let storeExact = storeGrant.complete(
                    storeClaim, as: storeCompletion
                )
                #if EPR_H4_PRIVACY_TESTS
                completionIntersticeForTest?()
                #endif
                guard storeExact else {
                    forceCompletionInspection()
                    return false
                }
                let ownerExact = bound.completePersistenceAdmission(
                    claim, as: leaseCompletion
                )
                guard ownerExact else {
                    forceCompletionInspection()
                    return false
                }
                return true
            }
        }

        private func withStateTransition<T>(_ body: () -> T) -> T {
            storeGrant.lockCoordinatorTransition()
            bound.lockPersistenceTransition()
            defer {
                bound.unlockPersistenceTransition()
                storeGrant.unlockCoordinatorTransition()
            }
            return body()
        }

        private func forceCompletionInspection() {
            storeGrant.forceTerminalInspection(.leaseCompletion)
            bound.forcePersistenceInspection(.leaseCompletion)
        }

        private static func map(
            _ failure: PersistenceClaimFailure
        ) -> HypervisorStageH4DualStreamPersistence.Failure {
            switch failure {
            case .inProgress: .inProgress
            case .alreadyConsumed: .alreadyConsumed
            case .persistenceRequiresInspection: .persistenceRequiresInspection
            case .expired: .expired
            case .poisoned: .poisoned
            }
        }

        private static func map(
            _ failure: DualStreamStoreGrantFailure
        ) -> HypervisorStageH4DualStreamPersistence.Failure {
            switch failure {
            case .inProgress: .inProgress
            case .alreadyConsumed: .alreadyConsumed
            case .persistenceRequiresInspection: .persistenceRequiresInspection
            case .expired: .expired
            case .ownerMismatch: .storeAdmissionRejected
            case .poisoned: .poisoned
            }
        }
    }


    #if EPR_H4_PRIVACY_TESTS
    static func makeTestPersistenceCoordinator(
        bound: OwnerBoundCanonicalProjection,
        store: HypervisorStageH4Persistence.Store,
        validThroughTick: UInt64,
        readTick: @escaping @Sendable () -> UInt64,
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) -> PersistenceCoordinator {
        let grant = PersistenceStoreGrant(
            bound: bound,
            store: store,
            validThroughTick: validThroughTick,
            readTick: readTick
        )
        if rejectStoreCompletionForTest {
            grant.rejectNextCompletionForTestOnly()
        }
        if rejectOwnerCompletionForTest {
            bound.rejectNextPersistenceCompletionForTestOnly()
        }
        if let completionIntersticeForTest {
            return PersistenceCoordinator(
                bound: bound,
                storeGrant: grant,
                completionIntersticeForTest: completionIntersticeForTest
            )
        }
        return PersistenceCoordinator(bound: bound, storeGrant: grant)
    }

    static func makeTestSharedStoreCoordinators(
        bounds: [OwnerBoundCanonicalProjection],
        store: HypervisorStageH4Persistence.Store,
        validThroughTick: UInt64,
        readTick: @escaping @Sendable () -> UInt64,
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) -> [PersistenceCoordinator] {
        guard let first = bounds.first else { return [] }
        let grant = PersistenceStoreGrant(
            bound: first,
            store: store,
            validThroughTick: validThroughTick,
            readTick: readTick
        )
        if rejectStoreCompletionForTest {
            grant.rejectNextCompletionForTestOnly()
        }
        if rejectOwnerCompletionForTest {
            first.rejectNextPersistenceCompletionForTestOnly()
        }
        return bounds.map { bound in
            if let completionIntersticeForTest {
                return PersistenceCoordinator(
                    bound: bound,
                    storeGrant: grant,
                    completionIntersticeForTest: completionIntersticeForTest
                )
            }
            return PersistenceCoordinator(bound: bound, storeGrant: grant)
        }
    }

    static func makeTestDualStreamPersistenceCoordinator(
        bound: OwnerBoundCanonicalProjection,
        store: HypervisorStageH4DualStreamPersistence.Store,
        validThroughTick: UInt64,
        readTick: @escaping @Sendable () -> UInt64,
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) -> DualStreamPersistenceCoordinator {
        let grant = DualStreamPersistenceStoreGrant(
            bound: bound,
            store: store,
            validThroughTick: validThroughTick,
            readTick: readTick
        )
        if rejectStoreCompletionForTest {
            grant.rejectNextCompletionForTestOnly()
        }
        if rejectOwnerCompletionForTest {
            bound.rejectNextPersistenceCompletionForTestOnly()
        }
        if let completionIntersticeForTest {
            return DualStreamPersistenceCoordinator(
                bound: bound,
                storeGrant: grant,
                completionIntersticeForTest: completionIntersticeForTest
            )
        }
        return DualStreamPersistenceCoordinator(bound: bound, storeGrant: grant)
    }

    static func makeTestSharedDualStreamStoreCoordinators(
        bounds: [OwnerBoundCanonicalProjection],
        store: HypervisorStageH4DualStreamPersistence.Store,
        validThroughTick: UInt64,
        readTick: @escaping @Sendable () -> UInt64,
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) -> [DualStreamPersistenceCoordinator] {
        guard let first = bounds.first else { return [] }
        let grant = DualStreamPersistenceStoreGrant(
            bound: first,
            store: store,
            validThroughTick: validThroughTick,
            readTick: readTick
        )
        if rejectStoreCompletionForTest {
            grant.rejectNextCompletionForTestOnly()
        }
        if rejectOwnerCompletionForTest {
            first.rejectNextPersistenceCompletionForTestOnly()
        }
        return bounds.map { bound in
            if let completionIntersticeForTest {
                return DualStreamPersistenceCoordinator(
                    bound: bound,
                    storeGrant: grant,
                    completionIntersticeForTest: completionIntersticeForTest
                )
            }
            return DualStreamPersistenceCoordinator(
                bound: bound,
                storeGrant: grant
            )
        }
    }
    #endif
}

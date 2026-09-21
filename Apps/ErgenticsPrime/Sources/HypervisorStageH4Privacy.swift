import CryptoKit
import Darwin
import Foundation

/// H4-A is the closed pre-persistence privacy boundary for one structural H3
/// receipt projection. It performs no file, SQLite, VM, process, wall-clock,
/// UI, or network operation. Expiry uses one kernel monotonic-tick read. A
/// successful value is preparation evidence only: it is not durability,
/// authority, Gate E, or permission to enter H4 execution.
enum HypervisorStageH4Privacy {
    static let stageID = "hypervisor_durable_receipt_fault_injection_v1"
    static let schema = "com.ergentics.provenance.hypervisor.h4.privacy.v1"
    static let policyID = "com.ergentics.provenance.hypervisor.h4.fixed-policy.v1"

    enum Subject: String, CaseIterable, Sendable {
        case h3Checkpoint = "hypervisor-h3-checkpoint"
        case managedWorkspace = "managed-workspace"
    }

    enum Purpose: String, CaseIterable, Sendable {
        case durableReceiptVerification = "durable-receipt-verification"
        case productPresentation = "product-presentation"
    }

    enum Operation: String, CaseIterable, Sendable {
        case projectForPersistence = "project-for-persistence"
        case renderPresentation = "render-presentation"
    }

    enum Field: String, CaseIterable, Comparable, Sendable {
        case authorityVector = "authority-vector"
        case claimState = "claim-state"
        case predicateCount = "predicate-count"
        case rawDiagnostic = "raw-diagnostic"

        static func < (left: Field, right: Field) -> Bool {
            left.rawValue.utf8.lexicographicallyPrecedes(right.rawValue.utf8)
        }
    }

    enum InformationClass: String, CaseIterable, Comparable, Sendable {
        case diagnostic
        case structural

        static func < (left: InformationClass, right: InformationClass) -> Bool {
            left.rawValue.utf8.lexicographicallyPrecedes(right.rawValue.utf8)
        }
    }

    enum Recipient: String, CaseIterable, Comparable, Sendable {
        case graph
        case internalReceipt = "internal-receipt"
        case merkleCommitment = "merkle-commitment"
        case releasePresentation = "release-presentation"
        case sqliteProjection = "sqlite-projection"

        static func < (left: Recipient, right: Recipient) -> Bool {
            left.rawValue.utf8.lexicographicallyPrecedes(right.rawValue.utf8)
        }
    }

    enum Persistence: String, CaseIterable, Sendable {
        case none
        case privateSQLite = "private-sqlite"
    }

    enum ClaimState: String, CaseIterable, Sendable {
        case observedNonPass = "OBSERVED_NONPASS"
    }

    /// H4-A proves only a structural contract fixture. A later H3 owner must
    /// introduce a distinct, unforgeable live-handoff type before production
    /// issuance can exist.
    enum SourceOrigin: String, CaseIterable, Sendable {
        case h3StructuralFixture = "H3_STRUCTURAL_FIXTURE"
    }

    enum SourceDisposition: String, CaseIterable, Sendable {
        case contractOnly = "CONTRACT_ONLY"
    }

    enum CapabilityStatus: String, Equatable, Sendable {
        case available
        case claimed
        case consumed
        case poisoned
    }

    struct Source: Equatable, Sendable {
        let origin: SourceOrigin
        let disposition: SourceDisposition
        let subject: Subject
        let epoch: String
        let receiptRoot: String
        let claimState: ClaimState
        let predicateCount: UInt32
        let authorityVector: String

        /// Diagnostic input may exist at the source boundary, but H4-A has no
        /// capability for it. It is intentionally absent from every output
        /// type and is never inspected while constructing those outputs.
        let rawDiagnostic: Data?

        fileprivate var bindingIdentity: String {
            var bytes = Data()
            append("com.ergentics.provenance.hypervisor.h4.source-binding.v1", to: &bytes)
            append(origin.rawValue, to: &bytes)
            append(disposition.rawValue, to: &bytes)
            append(subject.rawValue, to: &bytes)
            append(epoch, to: &bytes)
            append(receiptRoot, to: &bytes)
            append(claimState.rawValue, to: &bytes)
            append(UInt64(predicateCount), to: &bytes)
            append(authorityVector, to: &bytes)
            return hash(bytes)
        }
    }

    struct DestinationRequest: Equatable, Sendable {
        let recipient: Recipient
        let fields: [Field]
        let informationClasses: [InformationClass]
        let persistence: Persistence
    }

    struct DestinationPolicy: Equatable, Sendable {
        let recipient: Recipient
        let allowedFields: [Field]
        let allowedInformationClasses: [InformationClass]
        let persistence: Persistence
    }

    struct Request: Equatable, Sendable {
        let schema: String
        let subject: Subject
        let purpose: Purpose
        let operation: Operation
        let epoch: String
        let destinations: [DestinationRequest]
    }

    struct PrivacyEnvelope: Equatable, Sendable {
        let schema: String
        let policyID: String
        let subject: Subject
        let purpose: Purpose
        let operation: Operation
        let epoch: String
        let expectedSourceIdentity: String
        let destinations: [DestinationPolicy]
        let validThroughTick: UInt64

        /// Content identity only. It authenticates nothing and cannot recreate
        /// the process-local capability that owns this envelope.
        var identity: String { hash(canonicalBytes) }

        fileprivate var canonicalBytes: Data {
            var bytes = Data()
            append(schema, to: &bytes)
            append(policyID, to: &bytes)
            append(subject.rawValue, to: &bytes)
            append(purpose.rawValue, to: &bytes)
            append(operation.rawValue, to: &bytes)
            append(epoch, to: &bytes)
            append(expectedSourceIdentity, to: &bytes)
            append(UInt64(destinations.count), to: &bytes)
            for destination in destinations {
                append(destination.recipient.rawValue, to: &bytes)
                append(destination.allowedFields.map(\.rawValue), to: &bytes)
                append(destination.allowedInformationClasses.map(\.rawValue), to: &bytes)
                append(destination.persistence.rawValue, to: &bytes)
            }
            append(validThroughTick, to: &bytes)
            return bytes
        }
    }

    enum PredicateID: String, CaseIterable, Sendable {
        case capabilityAvailable = "capability_available"
        case schemaKnown = "schema_known"
        case policyKnown = "policy_known"
        case subjectExact = "subject_exact"
        case purposeExact = "purpose_exact"
        case operationExact = "operation_exact"
        case epochCanonical = "epoch_canonical"
        case epochExact = "epoch_exact"
        case requestShapeBounded = "request_shape_bounded"
        case destinationRequestsCanonical = "destination_requests_canonical"
        case destinationCountExact = "destination_count_exact"
        case destinationPoliciesExact = "destination_policies_exact"
        case notExpired = "not_expired"
        case sourceTextBounded = "source_text_bounded"
        case sourceBounded = "source_bounded"
        case sourceOriginExact = "source_origin_exact"
        case sourceDispositionExact = "source_disposition_exact"
        case sourceSubjectExact = "source_subject_exact"
        case sourceEpochCanonical = "source_epoch_canonical"
        case sourceEpochExact = "source_epoch_exact"
        case sourceReceiptRootCanonical = "source_receipt_root_canonical"
        case sourceIdentityExact = "source_identity_exact"
        case diagnosticDefaultDenied = "diagnostic_default_denied"
        case releaseProjectionMinimized = "release_projection_minimized"
    }

    struct PredicateResult: Equatable, Sendable {
        let id: PredicateID
        let passed: Bool
    }

    enum DestinationPredicateID: String, CaseIterable, Sendable {
        case recipientExact = "recipient_exact"
        case fieldsBounded = "fields_bounded"
        case fieldsCanonical = "fields_canonical"
        case fieldsExact = "fields_exact"
        case classesBounded = "classes_bounded"
        case classesCanonical = "classes_canonical"
        case classesExact = "classes_exact"
        case persistenceExact = "persistence_exact"
    }

    struct DestinationPredicateResult: Equatable, Sendable {
        let id: DestinationPredicateID
        let passed: Bool
    }

    struct DestinationDecision: Equatable, Sendable {
        let recipient: Recipient
        /// True only when this scope and every global predicate pass.
        let authorized: Bool
        let predicates: [DestinationPredicateResult]

        var firstFailedPredicate: DestinationPredicateID? {
            predicates.first(where: { !$0.passed })?.id
        }
    }

    struct Decision: Equatable, Sendable {
        enum Verdict: String, Equatable, Sendable {
            case allow = "ALLOW"
            case reject = "REJECT"
        }

        let verdict: Verdict
        let predicates: [PredicateResult]
        let destinations: [DestinationDecision]

        var firstFailedPredicate: PredicateID? {
            predicates.first(where: { !$0.passed })?.id
        }
    }

    struct PersistableProjection: Equatable, Sendable {
        let claimState: ClaimState
        let predicateCount: UInt32
        let authorityVector: String
    }

    /// This type is not interchangeable with release presentation. It may be
    /// persisted only by the later independently checked H4 store boundary.
    struct InternalProjection: Equatable, Sendable {
        let claimState: ClaimState
        let predicateCount: UInt32
        let authorityVector: String
    }

    /// Constructed independently from Source. It has no authority vector,
    /// diagnostic bytes, source path, epoch, capability, or persistence handle.
    struct ReleaseProjection: Equatable, Sendable {
        let claimState: ClaimState
        let predicateCount: UInt32
    }

    /// Structural disclosure evidence only. No field value or payload member
    /// exists in this type.
    struct DisclosureEvent: Equatable, Sendable {
        let schema: String
        let envelopeIdentity: String
        let recipient: Recipient
        let fields: [Field]
        let informationClasses: [InformationClass]
        let persisted: Bool
    }

    /// Review-priority vector, never an allow/reject score or privacy budget.
    struct AttentionVector: Equatable, Sendable {
        let disclosure: UInt16
        let inference: UInt16
        let linkability: UInt16
        let retention: UInt16
        let crossAgent: UInt16
        let metadata: UInt16
        let externality: UInt16
    }

    /// Trusted coordinator-only bundle. It is never a recipient payload. A
    /// later persistence slice must accept the destination-specific members,
    /// never forward this aggregate to release, graph, SQLite, or Merkle sinks.
    struct CoordinatorPreparedProjection: Equatable, Sendable {
        fileprivate let storedEnvelope: PrivacyEnvelope
        fileprivate let storedDecision: Decision
        fileprivate let storedPersistable: PersistableProjection
        fileprivate let storedInternalReceipt: InternalProjection
        fileprivate let storedReleasePresentation: ReleaseProjection
        fileprivate let storedDisclosureEvents: [DisclosureEvent]
        fileprivate let storedAttention: AttentionVector

        fileprivate init(
            envelope: PrivacyEnvelope,
            decision: Decision,
            persistable: PersistableProjection,
            internalReceipt: InternalProjection,
            releasePresentation: ReleaseProjection,
            disclosureEvents: [DisclosureEvent],
            attention: AttentionVector
        ) {
            storedEnvelope = envelope
            storedDecision = decision
            storedPersistable = persistable
            storedInternalReceipt = internalReceipt
            storedReleasePresentation = releasePresentation
            storedDisclosureEvents = disclosureEvents
            storedAttention = attention
        }

        #if EPR_H4_PRIVACY_TESTS
        var envelope: PrivacyEnvelope { storedEnvelope }
        var decision: Decision { storedDecision }
        var persistable: PersistableProjection { storedPersistable }
        var internalReceipt: InternalProjection { storedInternalReceipt }
        var releasePresentation: ReleaseProjection { storedReleasePresentation }
        var disclosureEvents: [DisclosureEvent] { storedDisclosureEvents }
        var attention: AttentionVector { storedAttention }
        #endif
    }

    /// A fixed internal-receipt delivery. Its initializer is file-private so
    /// the value can be produced only by the coordinator dispatcher below.
    struct InternalReceiptDelivery: Equatable, Sendable {
        let projection: InternalProjection

        fileprivate init(projection: InternalProjection) { self.projection = projection }
    }

    /// A release presentation is constructed independently. It cannot carry
    /// an authority vector, diagnostic bytes, source identity, or epoch.
    struct ReleasePresentationDelivery: Equatable, Sendable {
        let projection: ReleaseProjection

        fileprivate init(projection: ReleaseProjection) { self.projection = projection }
    }

    /// Pre-persistence SQLite input. H4-B does not open or write a database.
    struct SQLiteProjectionDelivery: Equatable, Sendable {
        let projection: PersistableProjection

        fileprivate init(projection: PersistableProjection) { self.projection = projection }
    }

    /// Process-local provenance anchor for the H4-D canonical transition. Its
    /// identity is reference identity, not a serialized identifier. The exact
    /// epoch remains private and is retained only so the opaque successor
    /// cannot outlive the relationship that constructed it. No source hash,
    /// envelope hash, separate owner UUID, pointer label, or bearer
    /// representation is emitted.
    final class OwnerEpochAnchor: @unchecked Sendable {
        private let epoch: String
        private let validThroughTick: UInt64
        private let readTick: @Sendable () -> UInt64

        fileprivate init(
            envelope: PrivacyEnvelope,
            readTick: @escaping @Sendable () -> UInt64
        ) {
            epoch = envelope.epoch
            validThroughTick = envelope.validThroughTick
            self.readTick = readTick
        }

        /// Persistence is a later disclosure transition, so the private owner
        /// relationship must still be live immediately before its commit. The
        /// clock and cutoff remain process-local and are never serialized.
        func isLive() -> Bool { readTick() <= validThroughTick }

        #if EPR_H4_PRIVACY_TESTS
        func matchesTest(epoch: String) -> Bool {
            self.epoch.utf8.elementsEqual(epoch.utf8)
        }
        #endif
    }

    /// Unforgeable-at-the-module-boundary input to H4-C. Only the dispatcher
    /// in this file can initialize it, so the codec never accepts a
    /// caller-assembled pair on the production surface.
    struct CanonicalStreamInput: @unchecked Sendable {
        let internalReceipt: InternalReceiptDelivery
        let sqliteProjection: SQLiteProjectionDelivery
        let ownerAnchor: OwnerEpochAnchor
        let persistenceLease: HypervisorStageH4OwnerBinding.PersistenceLease

        fileprivate init(
            internalReceipt: InternalReceiptDelivery,
            sqliteProjection: SQLiteProjectionDelivery,
            ownerAnchor: OwnerEpochAnchor
        ) {
            self.internalReceipt = internalReceipt
            self.sqliteProjection = sqliteProjection
            self.ownerAnchor = ownerAnchor
            persistenceLease = HypervisorStageH4OwnerBinding.PersistenceLease(
                ownerAnchor: ownerAnchor
            )
        }
    }

    /// Inert graph preparation marker. It contains no source field or graph
    /// payload; graph construction remains a later independently checked slice.
    struct GraphPreparationDelivery: Equatable, Sendable {
        fileprivate init() {}
    }

    /// Inert Merkle preparation marker. H4-B commits no root and persists no
    /// bytes; successful extraction records only that the distinct coordinator
    /// slot was claimed. It does not prove an external destination or owner.
    struct MerklePreparationDelivery: Equatable, Sendable {
        fileprivate init() {}
    }

    enum DestinationDispatchFailure: Error, Equatable, Sendable {
        case alreadyConsumed
        case expired
        case bindingInProgress
        case poisoned
    }

    /// Trusted process-local coordinator handle with five structurally distinct
    /// exits. The handle is never a sink payload. Each exit may be extracted at
    /// most once; the returned immutable value remains ordinarily copyable.
    /// There is deliberately no `take(recipient:)`, generic payload accessor,
    /// iteration surface, Codable conformance, or persistence operation.
    final class DestinationDispatcher: @unchecked Sendable {
        private enum Slot: UInt8 {
            case graph = 0x01
            case internalReceipt = 0x02
            case merkleCommitment = 0x04
            case releasePresentation = 0x08
            case sqliteProjection = 0x10
        }

        private enum CanonicalLifecycle: UInt8 {
            case ready
            case claimed
            case bound
            case poisoned
        }

        private static let everySlot: UInt8 = 0x1f
        private static let canonicalSlots =
            Slot.internalReceipt.rawValue | Slot.sqliteProjection.rawValue

        private let lock = NSLock()
        private var available: UInt8 = DestinationDispatcher.everySlot
        private var delivered: UInt8 = 0
        private var expired = false
        private var canonicalLifecycle: CanonicalLifecycle = .ready
        private let validThroughTick: UInt64
        private let readTick: @Sendable () -> UInt64
        private let internalReceipt: InternalReceiptDelivery
        private let releasePresentation: ReleasePresentationDelivery
        private let sqliteProjection: SQLiteProjectionDelivery
        private let ownerAnchor: OwnerEpochAnchor

        fileprivate init?(
            _ prepared: CoordinatorPreparedProjection,
            readTick: @escaping @Sendable () -> UInt64 = { mach_continuous_time() }
        ) {
            let envelope = prepared.storedEnvelope
            let decision = prepared.storedDecision
            let events = prepared.storedDisclosureEvents
            guard decision.verdict == .allow,
                  decision.predicates.allSatisfy(\.passed),
                  decision.destinations.count == Recipient.allCases.count,
                  decision.destinations.allSatisfy({
                      $0.authorized && $0.predicates.allSatisfy(\.passed)
                  }),
                  decision.destinations.map(\.recipient) ==
                    envelope.destinations.map(\.recipient),
                  envelope.destinations.count == Recipient.allCases.count,
                  envelope.destinations.map(\.recipient) == Recipient.allCases,
                  events.count == Recipient.allCases.count else { return nil }

            func event(for recipient: Recipient) -> DisclosureEvent? {
                let matches = events.filter { $0.recipient == recipient }
                guard matches.count == 1, let event = matches.first,
                      event.schema == HypervisorStageH4Privacy.disclosureSchema,
                      event.envelopeIdentity == envelope.identity,
                      !event.persisted,
                      let policy = envelope.destinations.first(where: {
                          $0.recipient == recipient
                      }),
                      event.fields == policy.allowedFields,
                      event.informationClasses == policy.allowedInformationClasses
                else { return nil }
                return event
            }

            guard let graphEvent = event(for: .graph),
                  let internalEvent = event(for: .internalReceipt),
                  let merkleEvent = event(for: .merkleCommitment),
                  let releaseEvent = event(for: .releasePresentation),
                  let sqliteEvent = event(for: .sqliteProjection) else { return nil }

            validThroughTick = envelope.validThroughTick
            self.readTick = readTick
            ownerAnchor = OwnerEpochAnchor(envelope: envelope, readTick: readTick)
            internalReceipt = InternalReceiptDelivery(
                projection: prepared.storedInternalReceipt
            )
            releasePresentation = ReleasePresentationDelivery(
                projection: prepared.storedReleasePresentation
            )
            sqliteProjection = SQLiteProjectionDelivery(
                projection: prepared.storedPersistable
            )
            // The disclosure events are consumed only as coordinator-side
            // validation evidence in this slice. They are not embedded in any
            // sink-visible extraction, especially release presentation where
            // envelope identity is forbidden.
            _ = graphEvent
            _ = internalEvent
            _ = merkleEvent
            _ = releaseEvent
            _ = sqliteEvent
        }

        /// H4-D's sole production transition. It admits no caller owner, epoch,
        /// delivery, byte stream, clock, destination, or persistence handle.
        /// The fresh dispatcher and both canonical source slots are claimed in
        /// one lock interval; the bounded synchronous codec runs while every
        /// other exit is closed. On success, the three noncanonical exits stay
        /// independently one-shot. Any failed transition poisons permanently.
        func bindCanonicalStreams() -> Result<
            HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection,
            HypervisorStageH4OwnerBinding.Failure
        > {
            let start = beginCanonicalBinding()
            guard case .success(let input) = start else {
                return start.map { _ in preconditionFailure("unreachable") }
            }
            do {
                return completeCanonicalBinding(
                    try HypervisorStageH4CanonicalStreams.projectBound(input),
                    expectedOwner: input.ownerAnchor
                )
            } catch {
                return rejectCanonicalProjection()
            }
        }

        #if EPR_H4_PRIVACY_TESTS
        /// XCTest-only codec substitution for deterministic failure, expiry,
        /// and in-progress schedules. The application contains neither this
        /// method nor a stored/injectable projector.
        func bindCanonicalStreamsTest(
            canonicalProject: @Sendable (CanonicalStreamInput) throws ->
                HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection
        ) -> Result<
            HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection,
            HypervisorStageH4OwnerBinding.Failure
        > {
            let start = beginCanonicalBinding()
            guard case .success(let input) = start else {
                return start.map { _ in preconditionFailure("unreachable") }
            }
            do {
                return completeCanonicalBinding(
                    try canonicalProject(input),
                    expectedOwner: input.ownerAnchor
                )
            } catch {
                return rejectCanonicalProjection()
            }
        }
        #endif

        private func beginCanonicalBinding() -> Result<
            CanonicalStreamInput,
            HypervisorStageH4OwnerBinding.Failure
        > {
            lock.lock()
            switch canonicalLifecycle {
            case .claimed:
                lock.unlock()
                return .failure(.inProgress)
            case .bound:
                lock.unlock()
                return .failure(.alreadyConsumed)
            case .poisoned:
                lock.unlock()
                return .failure(.poisoned)
            case .ready:
                break
            }

            if expired || readTick() > validThroughTick {
                expired = true
                poisonCanonicalLocked()
                lock.unlock()
                return .failure(.expired)
            }
            guard available == Self.everySlot, delivered == 0 else {
                poisonCanonicalLocked()
                lock.unlock()
                return .failure(.priorExtraction)
            }

            canonicalLifecycle = .claimed
            available &= ~Self.canonicalSlots
            delivered |= Self.canonicalSlots
            let input = CanonicalStreamInput(
                internalReceipt: internalReceipt,
                sqliteProjection: sqliteProjection,
                ownerAnchor: ownerAnchor
            )
            lock.unlock()
            return .success(input)
        }

        private func completeCanonicalBinding(
            _ bound: HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection,
            expectedOwner: OwnerEpochAnchor
        ) -> Result<
            HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection,
            HypervisorStageH4OwnerBinding.Failure
        > {
            lock.lock()
            guard canonicalLifecycle == .claimed else {
                poisonCanonicalLocked()
                lock.unlock()
                return .failure(.poisoned)
            }
            guard bound.isBound(to: expectedOwner) else {
                poisonCanonicalLocked()
                lock.unlock()
                return .failure(.ownerMismatch)
            }
            guard readTick() <= validThroughTick else {
                expired = true
                poisonCanonicalLocked()
                lock.unlock()
                return .failure(.expired)
            }
            canonicalLifecycle = .bound
            lock.unlock()
            return .success(bound)
        }

        private func rejectCanonicalProjection() -> Result<
            HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection,
            HypervisorStageH4OwnerBinding.Failure
        > {
            lock.lock()
            poisonCanonicalLocked()
            lock.unlock()
            return .failure(.projectionRejected)
        }

        func takeInternalReceipt()
            -> Result<InternalReceiptDelivery, DestinationDispatchFailure> {
            claim(.internalReceipt).map { internalReceipt }
        }

        func takeReleasePresentation()
            -> Result<ReleasePresentationDelivery, DestinationDispatchFailure> {
            claim(.releasePresentation).map { releasePresentation }
        }

        func takeSQLiteProjection()
            -> Result<SQLiteProjectionDelivery, DestinationDispatchFailure> {
            claim(.sqliteProjection).map { sqliteProjection }
        }

        func takeGraphPreparation()
            -> Result<GraphPreparationDelivery, DestinationDispatchFailure> {
            claim(.graph).map { GraphPreparationDelivery() }
        }

        func takeMerklePreparation()
            -> Result<MerklePreparationDelivery, DestinationDispatchFailure> {
            claim(.merkleCommitment).map { MerklePreparationDelivery() }
        }

        private func claim(_ slot: Slot) -> Result<Void, DestinationDispatchFailure> {
            lock.lock()
            defer { lock.unlock() }
            switch canonicalLifecycle {
            case .claimed:
                return .failure(.bindingInProgress)
            case .bound:
                break
            case .poisoned:
                return .failure(.poisoned)
            case .ready:
                break
            }
            if delivered & slot.rawValue != 0 { return .failure(.alreadyConsumed) }
            if expired { return .failure(.expired) }
            guard available & slot.rawValue != 0 else {
                return .failure(.alreadyConsumed)
            }
            guard readTick() <= validThroughTick else {
                expired = true
                available = 0
                return .failure(.expired)
            }
            available &= ~slot.rawValue
            delivered |= slot.rawValue
            return .success(())
        }

        private func poisonCanonicalLocked() {
            canonicalLifecycle = .poisoned
            available = 0
        }
    }

    enum Outcome: Equatable, Sendable {
        case prepared(CoordinatorPreparedProjection)
        case rejected(Decision)
    }

    /// Process-local one-shot authority. Its state is not Codable and cannot be
    /// reconstructed from the envelope identity or any emitted evidence.
    final class Capability: @unchecked Sendable {
        fileprivate let envelope: PrivacyEnvelope
        private let lock = NSLock()
        private var state: CapabilityStatus = .available

        fileprivate init(envelope: PrivacyEnvelope) { self.envelope = envelope }

        var status: CapabilityStatus {
            lock.lock()
            defer { lock.unlock() }
            return state
        }

        fileprivate func consume(request: Request, source: Source) -> Outcome {
            lock.lock()
            guard state == .available else {
                lock.unlock()
                let unavailable = Self.decision(
                    envelope: envelope, request: request, source: source,
                    capabilityAvailable: false
                )
                return .rejected(unavailable)
            }
            state = .claimed
            lock.unlock()

            let decision = Self.decision(
                envelope: envelope, request: request, source: source,
                capabilityAvailable: true
            )
            guard decision.verdict == .allow else {
                settle(.poisoned)
                return .rejected(decision)
            }

            // Each destination is projected independently from the typed
            // source. Release is not a redaction of the internal value.
            let persistable = PersistableProjection(
                claimState: source.claimState,
                predicateCount: source.predicateCount,
                authorityVector: source.authorityVector
            )
            let internalReceipt = InternalProjection(
                claimState: source.claimState,
                predicateCount: source.predicateCount,
                authorityVector: source.authorityVector
            )
            let releasePresentation = ReleaseProjection(
                claimState: source.claimState,
                predicateCount: source.predicateCount
            )
            let events = envelope.destinations.map { destination in
                DisclosureEvent(
                    schema: HypervisorStageH4Privacy.disclosureSchema,
                    envelopeIdentity: envelope.identity,
                    recipient: destination.recipient,
                    fields: destination.allowedFields,
                    informationClasses: destination.allowedInformationClasses,
                    persisted: false
                )
            }
            let disclosedFieldEdges = envelope.destinations.reduce(0) {
                $0 + $1.allowedFields.count
            }
            let persistentDestinations = envelope.destinations.filter {
                $0.persistence != .none
            }.count
            let attention = AttentionVector(
                // Spatial counts: repeated exposure to two recipients counts
                // as two field edges; retention counts scoped destinations.
                disclosure: UInt16(disclosedFieldEdges),
                inference: 0,
                linkability: 2, // epoch plus content identity
                retention: UInt16(persistentDestinations),
                crossAgent: 0,
                metadata: 2, // field identifiers plus recipient identifiers
                externality: 0
            )
            let prepared = CoordinatorPreparedProjection(
                envelope: envelope,
                decision: decision,
                persistable: persistable,
                internalReceipt: internalReceipt,
                releasePresentation: releasePresentation,
                disclosureEvents: events,
                attention: attention
            )
            settle(.consumed)
            return .prepared(prepared)
        }

        private func settle(_ terminal: CapabilityStatus) {
            lock.lock()
            precondition(state == .claimed)
            state = terminal
            lock.unlock()
        }

        private static func decision(
            envelope: PrivacyEnvelope,
            request: Request,
            source: Source,
            capabilityAvailable: Bool
        ) -> Decision {
            let sourceTextBounded = source.epoch.utf8.count <= 36 &&
                source.receiptRoot.utf8.count <= 64 &&
                source.authorityVector.utf8.count <= 8
            let sourceBounded = source.predicateCount > 0 && source.predicateCount <= 4_096 &&
                source.authorityVector.utf8.elementsEqual("00000000".utf8)
            let sourceEpochCanonical = sourceTextBounded &&
                HypervisorStageH4Privacy.canonicalEpoch(source.epoch)
            let sourceReceiptRootCanonical = sourceTextBounded &&
                HypervisorStageH4Privacy.canonicalDigest(source.receiptRoot)
            let requestShapeBounded = request.destinations.count <= envelope.destinations.count
            let scopedDestinations = envelope.destinations.map { policy in
                destinationDecision(
                    policy: policy,
                    request: requestShapeBounded
                        ? request.destinations.first(where: {
                            $0.recipient == policy.recipient
                        })
                        : nil
                )
            }
            let requestedDestinationsCanonical = requestShapeBounded &&
                HypervisorStageH4Privacy.canonical(request.destinations.map(\.recipient))
            let releasePolicy = envelope.destinations.first {
                $0.recipient == .releasePresentation
            }
            let releaseFields = Set(releasePolicy?.allowedFields ?? [])
            let releaseProjectionMinimized = releaseFields == [.claimState, .predicateCount] &&
                !releaseFields.contains(.authorityVector) && !releaseFields.contains(.rawDiagnostic)
            let diagnosticDefaultDenied = envelope.destinations.allSatisfy {
                !$0.allowedFields.contains(.rawDiagnostic) &&
                    !$0.allowedInformationClasses.contains(.diagnostic)
            }

            let values: [PredicateID: Bool] = [
                .capabilityAvailable: capabilityAvailable,
                .schemaKnown: HypervisorStageH4Privacy.exact(request.schema, envelope.schema) &&
                    HypervisorStageH4Privacy.exact(envelope.schema, HypervisorStageH4Privacy.schema),
                .policyKnown: HypervisorStageH4Privacy.exact(
                    envelope.policyID, HypervisorStageH4Privacy.policyID
                ),
                .subjectExact: request.subject == envelope.subject,
                .purposeExact: request.purpose == envelope.purpose,
                .operationExact: request.operation == envelope.operation,
                .epochCanonical: HypervisorStageH4Privacy.canonicalEpoch(request.epoch) &&
                    HypervisorStageH4Privacy.canonicalEpoch(envelope.epoch),
                .epochExact: HypervisorStageH4Privacy.exact(request.epoch, envelope.epoch),
                .requestShapeBounded: requestShapeBounded,
                .destinationRequestsCanonical: requestedDestinationsCanonical,
                .destinationCountExact: request.destinations.count == envelope.destinations.count,
                .destinationPoliciesExact: scopedDestinations.allSatisfy {
                    $0.predicates.allSatisfy(\.passed)
                },
                .notExpired: mach_continuous_time() <= envelope.validThroughTick,
                .sourceTextBounded: sourceTextBounded,
                .sourceBounded: sourceBounded,
                .sourceOriginExact: source.origin == .h3StructuralFixture,
                .sourceDispositionExact: source.disposition == .contractOnly,
                .sourceSubjectExact: source.subject == envelope.subject,
                .sourceEpochCanonical: sourceEpochCanonical,
                .sourceEpochExact: HypervisorStageH4Privacy.exact(source.epoch, envelope.epoch),
                .sourceReceiptRootCanonical: sourceReceiptRootCanonical,
                .sourceIdentityExact: sourceEpochCanonical && sourceReceiptRootCanonical &&
                    sourceBounded && HypervisorStageH4Privacy.exact(
                        source.bindingIdentity, envelope.expectedSourceIdentity
                    ),
                .diagnosticDefaultDenied: diagnosticDefaultDenied,
                .releaseProjectionMinimized: releaseProjectionMinimized,
            ]
            let predicates = PredicateID.allCases.map {
                PredicateResult(id: $0, passed: values[$0] == true)
            }
            let verdict: Decision.Verdict = predicates.allSatisfy(\.passed) ? .allow : .reject
            let destinationDecisions = scopedDestinations.map {
                DestinationDecision(
                    recipient: $0.recipient,
                    authorized: verdict == .allow && $0.predicates.allSatisfy(\.passed),
                    predicates: $0.predicates
                )
            }
            return Decision(
                verdict: verdict,
                predicates: predicates,
                destinations: destinationDecisions
            )
        }

        private static func destinationDecision(
            policy: DestinationPolicy,
            request: DestinationRequest?
        ) -> DestinationDecision {
            let fieldsBounded = request.map { $0.fields.count <= Field.allCases.count } == true
            let classesBounded = request.map {
                $0.informationClasses.count <= InformationClass.allCases.count
            } == true
            let values: [DestinationPredicateID: Bool] = [
                .recipientExact: request?.recipient == policy.recipient,
                .fieldsBounded: fieldsBounded,
                .fieldsCanonical: fieldsBounded && request.map {
                    HypervisorStageH4Privacy.canonical($0.fields)
                } == true,
                .fieldsExact: request?.fields == policy.allowedFields,
                .classesBounded: classesBounded,
                .classesCanonical: classesBounded && request.map {
                    HypervisorStageH4Privacy.canonical($0.informationClasses)
                } == true,
                .classesExact: request?.informationClasses == policy.allowedInformationClasses,
                .persistenceExact: request?.persistence == policy.persistence,
            ]
            let predicates = DestinationPredicateID.allCases.map {
                DestinationPredicateResult(id: $0, passed: values[$0] == true)
            }
            return DestinationDecision(
                recipient: policy.recipient,
                authorized: false,
                predicates: predicates
            )
        }
    }

    static let disclosureSchema = "com.ergentics.provenance.hypervisor.h4.disclosure-event.v1"

    private static let fixedDestinations: [DestinationPolicy] = [
        DestinationPolicy(
            recipient: .graph,
            allowedFields: [],
            allowedInformationClasses: [.structural],
            persistence: .privateSQLite
        ),
        DestinationPolicy(
            recipient: .internalReceipt,
            allowedFields: [.authorityVector, .claimState, .predicateCount],
            allowedInformationClasses: [.structural],
            persistence: .none
        ),
        DestinationPolicy(
            recipient: .merkleCommitment,
            allowedFields: [],
            allowedInformationClasses: [],
            persistence: .privateSQLite
        ),
        DestinationPolicy(
            recipient: .releasePresentation,
            allowedFields: [.claimState, .predicateCount],
            allowedInformationClasses: [.structural],
            persistence: .none
        ),
        DestinationPolicy(
            recipient: .sqliteProjection,
            allowedFields: [.authorityVector, .claimState, .predicateCount],
            allowedInformationClasses: [.structural],
            persistence: .privateSQLite
        ),
    ]

    #if EPR_H4_PRIVACY_TESTS
    /// Compiled only into the isolated XCTest bundle and noninstalled XCTest-
    /// support executables. Production deliberately has no mint until H3
    /// exposes an unforgeable one-use verified handoff.
    static func issueTestCapability(source: Source, validThroughTick: UInt64) -> Capability? {
        guard admissibleFixtureSource(source), validThroughTick > 0 else { return nil }
        return makeCapability(source: source, validThroughTick: validThroughTick)
    }

    private static func makeCapability(source: Source, validThroughTick: UInt64) -> Capability {
        let envelope = PrivacyEnvelope(
            schema: schema,
            policyID: policyID,
            subject: .h3Checkpoint,
            purpose: .durableReceiptVerification,
            operation: .projectForPersistence,
            epoch: source.epoch,
            expectedSourceIdentity: source.bindingIdentity,
            destinations: fixedDestinations,
            validThroughTick: validThroughTick
        )
        return Capability(envelope: envelope)
    }

    /// Isolated XCTest bridge for exercising the production dispatcher shape.
    /// It does not add a product mint: the symbol is absent without the test
    /// compilation condition, and it still consumes the one-shot capability.
    static func consumeTestDispatcher(
        capability: Capability,
        request: Request,
        source: Source,
        deliveryTick: @escaping @Sendable () -> UInt64 = { mach_continuous_time() }
    ) -> DestinationDispatcher? {
        guard case .prepared(let prepared) = capability.consume(
            request: request,
            source: source
        ) else { return nil }
        return DestinationDispatcher(prepared, readTick: deliveryTick)
    }

    /// XCTest-only visibility for H4-A decision and poison-state assertions.
    /// Normal application code cannot call the aggregate-producing consume.
    static func consumeTestCapability(
        _ capability: Capability,
        request: Request,
        source: Source
    ) -> Outcome {
        capability.consume(request: request, source: source)
    }
    #endif

    static func fixedRequest(epoch: String) -> Request {
        Request(
            schema: schema,
            subject: .h3Checkpoint,
            purpose: .durableReceiptVerification,
            operation: .projectForPersistence,
            epoch: epoch,
            destinations: fixedDestinations.map {
                DestinationRequest(
                    recipient: $0.recipient,
                    fields: $0.allowedFields,
                    informationClasses: $0.allowedInformationClasses,
                    persistence: $0.persistence
                )
            }
        )
    }

    #if EPR_H4_PRIVACY_TESTS
    private static func admissibleFixtureSource(_ source: Source) -> Bool {
        source.origin == .h3StructuralFixture &&
            source.disposition == .contractOnly &&
            source.subject == .h3Checkpoint &&
            canonicalEpoch(source.epoch) &&
            canonicalDigest(source.receiptRoot) &&
            source.predicateCount > 0 && source.predicateCount <= 4_096 &&
            exact(source.authorityVector, "00000000")
    }
    #endif

    private static func canonical<T: Comparable>(_ values: [T]) -> Bool {
        guard values == values.sorted() else { return false }
        return zip(values, values.dropFirst()).allSatisfy { $0 != $1 }
    }

    private static func canonicalEpoch(_ value: String) -> Bool {
        guard value.utf8.count == 36, !value.utf8.contains(0),
              let parsed = UUID(uuidString: value) else { return false }
        return parsed.uuidString.lowercased().utf8.elementsEqual(value.utf8)
    }

    private static func canonicalDigest(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    private static func exact(_ left: String, _ right: String) -> Bool {
        left.utf8.elementsEqual(right.utf8)
    }

    private static func append(_ value: String, to bytes: inout Data) {
        let encoded = Data(value.utf8)
        append(UInt64(encoded.count), to: &bytes)
        bytes.append(encoded)
    }

    private static func append(_ values: [String], to bytes: inout Data) {
        append(UInt64(values.count), to: &bytes)
        for value in values { append(value, to: &bytes) }
    }

    private static func append(_ value: UInt64, to bytes: inout Data) {
        for index in (0..<8).reversed() {
            bytes.append(UInt8(truncatingIfNeeded: value >> UInt64(index * 8)))
        }
    }

    private static func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}

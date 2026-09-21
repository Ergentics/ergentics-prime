import Foundation
import XCTest

final class HypervisorStageH4PrivacyTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy

    private let epoch = "11111111-1111-4111-8111-111111111111"
    private let otherEpoch = "22222222-2222-4222-8222-222222222222"

    private final class LockedOutcomes: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [H4.Outcome] = []

        func append(_ value: H4.Outcome) {
            lock.lock()
            values.append(value)
            lock.unlock()
        }

        func snapshot() -> [H4.Outcome] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }
    }

    private final class LockedCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0

        func increment() {
            lock.lock()
            value += 1
            lock.unlock()
        }

        func snapshot() -> Int {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
    }

    private final class LockedTick: @unchecked Sendable {
        private let lock = NSLock()
        private var value: UInt64

        init(_ value: UInt64) {
            self.value = value
        }

        func set(_ newValue: UInt64) {
            lock.lock()
            value = newValue
            lock.unlock()
        }

        func read() -> UInt64 {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
    }

    private enum TestFailure: Error {
        case expectedPrepared
        case expectedRejected
    }

    private func source(
        subject: H4.Subject = .h3Checkpoint,
        epoch sourceEpoch: String? = nil,
        receiptRoot: String = String(repeating: "a", count: 64),
        predicateCount: UInt32 = 19,
        authorityVector: String = "00000000",
        rawDiagnostic: Data? = nil
    ) -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: subject,
            epoch: sourceEpoch ?? epoch,
            receiptRoot: receiptRoot,
            claimState: .observedNonPass,
            predicateCount: predicateCount,
            authorityVector: authorityVector,
            rawDiagnostic: rawDiagnostic
        )
    }

    private func request(
        schema: String? = nil,
        subject: H4.Subject = .h3Checkpoint,
        purpose: H4.Purpose = .durableReceiptVerification,
        operation: H4.Operation = .projectForPersistence,
        epoch requestedEpoch: String? = nil,
        destinations: [H4.DestinationRequest]? = nil
    ) -> H4.Request {
        let fixed = H4.fixedRequest(epoch: epoch)
        return H4.Request(
            schema: schema ?? fixed.schema,
            subject: subject,
            purpose: purpose,
            operation: operation,
            epoch: requestedEpoch ?? fixed.epoch,
            destinations: destinations ?? fixed.destinations
        )
    }

    private func capability(
        source: H4.Source? = nil,
        validThroughTick: UInt64 = .max
    ) throws -> H4.Capability {
        try XCTUnwrap(H4.issueTestCapability(
            source: source ?? self.source(),
            validThroughTick: validThroughTick
        ))
    }

    private func consume(
        _ capability: H4.Capability,
        request: H4.Request,
        source: H4.Source
    ) -> H4.Outcome {
        H4.consumeTestCapability(capability, request: request, source: source)
    }

    private func replacingDestination(
        _ recipient: H4.Recipient,
        in destinations: [H4.DestinationRequest]? = nil,
        requestedRecipient: H4.Recipient? = nil,
        fields: [H4.Field]? = nil,
        informationClasses: [H4.InformationClass]? = nil,
        persistence: H4.Persistence? = nil
    ) -> [H4.DestinationRequest] {
        (destinations ?? request().destinations).map { value in
            guard value.recipient == recipient else { return value }
            return H4.DestinationRequest(
                recipient: requestedRecipient ?? value.recipient,
                fields: fields ?? value.fields,
                informationClasses: informationClasses ?? value.informationClasses,
                persistence: persistence ?? value.persistence
            )
        }
    }

    private func prepared(
        capability: H4.Capability? = nil,
        request: H4.Request? = nil,
        source: H4.Source? = nil
    ) throws -> H4.CoordinatorPreparedProjection {
        let capability = try capability ?? self.capability()
        let outcome = consume(
            capability,
            request: request ?? self.request(),
            source: source ?? self.source()
        )
        guard case .prepared(let value) = outcome else {
            XCTFail("Expected prepared H4 projection")
            throw TestFailure.expectedPrepared
        }
        return value
    }

    private func dispatcher(
        capability suppliedCapability: H4.Capability? = nil,
        request suppliedRequest: H4.Request? = nil,
        source suppliedSource: H4.Source? = nil
    ) throws -> H4.DestinationDispatcher {
        let capability = try suppliedCapability ?? self.capability()
        return try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: suppliedRequest ?? self.request(),
            source: suppliedSource ?? self.source()
        ))
    }

    private func concurrentWinners(
        attempts: Int = 24,
        _ action: @escaping @Sendable () -> Bool
    ) -> Int {
        let queue = DispatchQueue(
            label: "h4.privacy.destination.concurrent",
            attributes: .concurrent
        )
        let group = DispatchGroup()
        let winners = LockedCounter()
        for _ in 0..<attempts {
            group.enter()
            queue.async {
                if action() { winners.increment() }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        return winners.snapshot()
    }

    @discardableResult
    private func rejected(
        capability suppliedCapability: H4.Capability? = nil,
        request: H4.Request,
        source: H4.Source? = nil,
        expectedFirstFailure: H4.PredicateID,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> H4.Decision {
        let capability = try suppliedCapability ?? self.capability()
        let outcome = consume(
            capability,
            request: request,
            source: source ?? self.source()
        )
        guard case .rejected(let decision) = outcome else {
            XCTFail("Expected H4 rejection", file: file, line: line)
            throw TestFailure.expectedRejected
        }
        XCTAssertEqual(decision.verdict, .reject, file: file, line: line)
        XCTAssertEqual(
            decision.firstFailedPredicate,
            expectedFirstFailure,
            file: file,
            line: line
        )
        XCTAssertEqual(capability.status, .poisoned, file: file, line: line)
        return decision
    }

    func testFixedAllowPathProducesBoundedIndependentProjections() throws {
        let capability = try capability()
        let value = try prepared(capability: capability)

        XCTAssertEqual(capability.status, .consumed)
        XCTAssertEqual(value.decision.verdict, .allow)
        XCTAssertNil(value.decision.firstFailedPredicate)
        XCTAssertEqual(value.decision.predicates.map(\.id), H4.PredicateID.allCases)
        XCTAssertTrue(value.decision.predicates.allSatisfy(\.passed))

        XCTAssertEqual(value.envelope.schema, H4.schema)
        XCTAssertEqual(value.envelope.policyID, H4.policyID)
        XCTAssertEqual(value.envelope.subject, .h3Checkpoint)
        XCTAssertEqual(value.envelope.purpose, .durableReceiptVerification)
        XCTAssertEqual(value.envelope.operation, .projectForPersistence)
        XCTAssertEqual(value.envelope.epoch, epoch)
        XCTAssertEqual(value.envelope.identity.count, 64)
        XCTAssertEqual(value.envelope.destinations.count, 5)
        XCTAssertEqual(value.decision.destinations.map(\.recipient),
                       value.envelope.destinations.map(\.recipient))
        XCTAssertTrue(value.decision.destinations.allSatisfy {
            $0.authorized && $0.firstFailedPredicate == nil &&
                $0.predicates.map(\.id) == H4.DestinationPredicateID.allCases
        })

        XCTAssertEqual(value.persistable.claimState, .observedNonPass)
        XCTAssertEqual(value.persistable.predicateCount, 19)
        XCTAssertEqual(value.persistable.authorityVector, "00000000")
        XCTAssertEqual(value.internalReceipt.claimState, .observedNonPass)
        XCTAssertEqual(value.internalReceipt.predicateCount, 19)
        XCTAssertEqual(value.internalReceipt.authorityVector, "00000000")
        XCTAssertEqual(value.releasePresentation.claimState, .observedNonPass)
        XCTAssertEqual(value.releasePresentation.predicateCount, 19)

        XCTAssertEqual(value.disclosureEvents.map(\.recipient),
                       request().destinations.map(\.recipient))
        XCTAssertEqual(value.disclosureEvents.map(\.envelopeIdentity),
                       Array(repeating: value.envelope.identity,
                             count: request().destinations.count))
    }

    func testClosedSubjectPurposeAndOperationRejectUnknownRawValues() throws {
        XCTAssertEqual(H4.Subject.allCases, [.h3Checkpoint, .managedWorkspace])
        XCTAssertEqual(H4.Purpose.allCases, [
            .durableReceiptVerification, .productPresentation,
        ])
        XCTAssertEqual(H4.Operation.allCases, [
            .projectForPersistence, .renderPresentation,
        ])

        for raw in ["", "unknown", "h3-checkpoint\u{0}", "HYPERVISOR-H3-CHECKPOINT"] {
            XCTAssertNil(H4.Subject(rawValue: raw), raw)
        }
        for raw in ["", "unknown-purpose", "durable-receipt-verification\u{0}"] {
            XCTAssertNil(H4.Purpose(rawValue: raw), raw)
        }
        for raw in ["", "read", "project-for-persistence\u{0}"] {
            XCTAssertNil(H4.Operation(rawValue: raw), raw)
        }

        try rejected(
            request: request(subject: .managedWorkspace),
            expectedFirstFailure: .subjectExact
        )
        try rejected(
            request: request(purpose: .productPresentation),
            expectedFirstFailure: .purposeExact
        )
        try rejected(
            request: request(operation: .renderPresentation),
            expectedFirstFailure: .operationExact
        )
    }

    func testWrongSchemaEpochDestinationScopesAndExpiryReject() throws {
        try rejected(
            request: request(schema: "unknown-schema"),
            expectedFirstFailure: .schemaKnown
        )
        try rejected(
            request: request(epoch: otherEpoch),
            expectedFirstFailure: .epochExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .sqliteProjection,
                fields: [.claimState, .predicateCount]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .releasePresentation,
                fields: [.authorityVector, .claimState, .predicateCount]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .internalReceipt,
                informationClasses: [.diagnostic]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            request: request(destinations: Array(request().destinations.dropLast())),
            expectedFirstFailure: .destinationCountExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .graph,
                persistence: H4.Persistence.none
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            capability: capability(validThroughTick: 1),
            request: request(),
            expectedFirstFailure: .notExpired
        )
    }

    func testMalformedAndNoncanonicalDestinationCollectionsRejectBeforeExactness() throws {
        try rejected(
            request: request(epoch: "not-a-canonical-epoch"),
            expectedFirstFailure: .epochCanonical
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .sqliteProjection,
                fields: [.authorityVector, .authorityVector, .claimState, .predicateCount]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .internalReceipt,
                fields: [.predicateCount, .claimState, .authorityVector]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        try rejected(
            request: request(destinations: replacingDestination(
                .graph,
                informationClasses: [.structural, .structural]
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        let reversed = Array(request().destinations.reversed())
        try rejected(
            request: request(destinations: reversed),
            expectedFirstFailure: .destinationRequestsCanonical
        )
        var duplicated = request().destinations
        duplicated.insert(duplicated[0], at: 1)
        try rejected(
            request: request(destinations: duplicated),
            expectedFirstFailure: .requestShapeBounded
        )
    }

    func testEachDestinationHasAnIndependentOrderedDecision() throws {
        let tampered = replacingDestination(
            .releasePresentation,
            fields: [.authorityVector, .claimState, .predicateCount]
        )
        let decision = try rejected(
            request: request(destinations: tampered),
            expectedFirstFailure: .destinationPoliciesExact
        )
        XCTAssertEqual(decision.destinations.count, 5)
        for destination in decision.destinations {
            XCTAssertEqual(
                destination.predicates.map(\.id),
                H4.DestinationPredicateID.allCases
            )
            if destination.recipient == .releasePresentation {
                XCTAssertFalse(destination.authorized)
                XCTAssertEqual(destination.firstFailedPredicate, .fieldsExact)
            } else {
                XCTAssertFalse(destination.authorized)
                XCTAssertNil(destination.firstFailedPredicate)
            }
        }
    }

    func testWrongRecipientCannotBorrowAnotherDestinationScope() throws {
        let tampered = replacingDestination(
            .graph,
            requestedRecipient: .internalReceipt
        )
        let decision = try rejected(
            request: request(destinations: tampered),
            expectedFirstFailure: .destinationRequestsCanonical
        )
        let graph = try XCTUnwrap(decision.destinations.first {
            $0.recipient == .graph
        })
        XCTAssertEqual(graph.firstFailedPredicate, .recipientExact)
        XCTAssertTrue(decision.destinations.allSatisfy { !$0.authorized })
    }

    func testGlobalRejectionDeauthorizesEveryDestination() throws {
        let expiredCapability = try capability(validThroughTick: 1)
        let expired = try rejected(
            capability: expiredCapability,
            request: request(),
            expectedFirstFailure: .notExpired
        )
        XCTAssertTrue(expired.destinations.allSatisfy { !$0.authorized })

        let wrongSource = try rejected(
            request: request(),
            source: source(receiptRoot: String(repeating: "b", count: 64)),
            expectedFirstFailure: .sourceIdentityExact
        )
        XCTAssertTrue(wrongSource.destinations.allSatisfy { !$0.authorized })

        let replayCapability = try capability()
        guard case .prepared = consume(
            replayCapability,
            request: request(), source: source()
        ) else { return XCTFail("Expected first consume to prepare") }
        guard case .rejected(let replay) = consume(
            replayCapability,
            request: request(), source: source()
        ) else { return XCTFail("Expected replay rejection") }
        XCTAssertEqual(replay.firstFailedPredicate, .capabilityAvailable)
        XCTAssertTrue(replay.destinations.allSatisfy { !$0.authorized })
    }

    func testOversizedNestedScopeRejectsBeforeCanonicalSorting() throws {
        let oversized = Array(repeating: H4.Field.claimState, count: 100_000)
        let decision = try rejected(
            request: request(destinations: replacingDestination(
                .sqliteProjection,
                fields: oversized
            )),
            expectedFirstFailure: .destinationPoliciesExact
        )
        let sqlite = try XCTUnwrap(decision.destinations.first {
            $0.recipient == .sqliteProjection
        })
        XCTAssertEqual(sqlite.firstFailedPredicate, .fieldsBounded)
        XCTAssertFalse(sqlite.authorized)
    }

    func testUnknownEnumsAndMalformedCapabilityInputsDoNotMintAuthority() {
        XCTAssertNil(H4.Field(rawValue: "credential"))
        XCTAssertNil(H4.InformationClass(rawValue: "secret"))
        XCTAssertNil(H4.Recipient(rawValue: "network"))
        XCTAssertNil(H4.Persistence(rawValue: "global-database"))
        XCTAssertNil(H4.ClaimState(rawValue: "PASS"))
        XCTAssertNil(H4.SourceOrigin(rawValue: "H3_VERIFIED_LIVE"))
        XCTAssertNil(H4.SourceDisposition(rawValue: "AUTHORITATIVE"))
        XCTAssertNil(H4.DestinationPredicateID(rawValue: "payload_allowed"))

        let invalidEpochs = [
            "",
            "not-a-uuid",
            "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA",
            "11111111-1111-4111-8111-11111111111\u{0}",
        ]
        for invalid in invalidEpochs {
            XCTAssertNil(H4.issueTestCapability(
                source: source(epoch: invalid), validThroughTick: .max
            ), invalid)
        }
        XCTAssertNil(H4.issueTestCapability(
            source: source(receiptRoot: String(repeating: "g", count: 64)),
            validThroughTick: .max
        ))
        XCTAssertNil(H4.issueTestCapability(
            source: source(predicateCount: 0), validThroughTick: .max
        ))
        XCTAssertNil(H4.issueTestCapability(
            source: source(), validThroughTick: 0
        ))
    }

    func testMalformedSourceValuesRejectAtSourceBoundedPredicate() throws {
        for invalid in [
            source(predicateCount: 0),
            source(predicateCount: 4_097),
            source(authorityVector: "0000000"),
            source(authorityVector: "0000000x"),
        ] {
            try rejected(
                request: request(),
                source: invalid,
                expectedFirstFailure: .sourceBounded
            )
        }
        try rejected(
            request: request(),
            source: source(authorityVector: "000000000"),
            expectedFirstFailure: .sourceTextBounded
        )
    }

    func testSourceSubjectEpochRootAndIdentityAreBoundToMintedEnvelope() throws {
        try rejected(
            request: request(),
            source: source(subject: .managedWorkspace),
            expectedFirstFailure: .sourceSubjectExact
        )
        try rejected(
            request: request(),
            source: source(epoch: otherEpoch),
            expectedFirstFailure: .sourceEpochExact
        )
        try rejected(
            request: request(),
            source: source(epoch: "not-an-epoch"),
            expectedFirstFailure: .sourceEpochCanonical
        )
        try rejected(
            request: request(),
            source: source(receiptRoot: String(repeating: "g", count: 64)),
            expectedFirstFailure: .sourceReceiptRootCanonical
        )
        try rejected(
            request: request(),
            source: source(receiptRoot: String(repeating: "b", count: 64)),
            expectedFirstFailure: .sourceIdentityExact
        )

        try rejected(
            request: request(epoch: otherEpoch),
            source: source(epoch: otherEpoch),
            expectedFirstFailure: .epochExact
        )
    }

    func testOversizedSourceTextRejectsBeforeBindingHash() throws {
        try rejected(
            request: request(),
            source: source(epoch: String(repeating: "x", count: 1_000_000)),
            expectedFirstFailure: .sourceTextBounded
        )
    }

    func testRawDiagnosticCanaryIsAbsentFromEveryOutputAndReflection() throws {
        let canary = "H4-RAW-DIAGNOSTIC-CANARY-DO-NOT-DISCLOSE"
        let input = source(rawDiagnostic: Data(canary.utf8))
        XCTAssertEqual(String(data: try XCTUnwrap(input.rawDiagnostic), encoding: .utf8), canary)

        let capability = try capability()
        let outcome = consume(capability, request: request(), source: input)
        guard case .prepared(let value) = outcome else {
            return XCTFail("Expected prepared projection")
        }

        let reflectedOutputs = [
            String(reflecting: outcome),
            String(reflecting: value),
            String(reflecting: value.envelope),
            String(reflecting: value.decision),
            String(reflecting: value.persistable),
            String(reflecting: value.internalReceipt),
            String(reflecting: value.releasePresentation),
            String(reflecting: value.disclosureEvents),
            String(reflecting: value.attention),
        ]
        for rendered in reflectedOutputs {
            XCTAssertFalse(rendered.contains(canary), rendered)
        }
        for event in value.disclosureEvents {
            XCTAssertFalse(event.fields.contains(.rawDiagnostic))
            XCTAssertFalse(event.informationClasses.contains(.diagnostic))
        }
    }

    func testRawDiagnosticDoesNotAlterBindingOrPreparedSemantics() throws {
        let baselineSource = source()
        let canarySource = source(rawDiagnostic: Data("different-raw-diagnostic".utf8))
        let baseline = try prepared(
            capability: capability(source: baselineSource),
            source: baselineSource
        )
        let canary = try prepared(
            capability: capability(source: canarySource),
            source: canarySource
        )
        XCTAssertEqual(baseline, canary)
    }

    func testDisclosureEventsArePayloadFreeAndDestinationSpecific() throws {
        let value = try prepared()
        let expectedLabels = [
            "schema", "envelopeIdentity", "recipient", "fields",
            "informationClasses", "persisted",
        ]
        for event in value.disclosureEvents {
            XCTAssertEqual(
                Mirror(reflecting: event).children.compactMap(\.label),
                expectedLabels
            )
            XCTAssertEqual(event.schema, H4.disclosureSchema)
            XCTAssertFalse(String(reflecting: event).contains("payload"))
            XCTAssertFalse(String(reflecting: event).contains("rawDiagnostic"))
        }

        let byRecipient = Dictionary(
            uniqueKeysWithValues: value.disclosureEvents.map { ($0.recipient, $0) }
        )
        XCTAssertEqual(byRecipient[.internalReceipt]?.fields,
                       [.authorityVector, .claimState, .predicateCount])
        XCTAssertEqual(byRecipient[.releasePresentation]?.fields,
                       [.claimState, .predicateCount])
        XCTAssertEqual(byRecipient[.sqliteProjection]?.fields,
                       [.authorityVector, .claimState, .predicateCount])
        XCTAssertEqual(byRecipient[.graph]?.fields, [])
        XCTAssertEqual(byRecipient[.merkleCommitment]?.fields, [])
        XCTAssertEqual(byRecipient[.internalReceipt]?.persisted, false)
        XCTAssertEqual(byRecipient[.releasePresentation]?.persisted, false)
        XCTAssertEqual(byRecipient[.sqliteProjection]?.persisted, false)
        XCTAssertEqual(byRecipient[.graph]?.persisted, false)
        XCTAssertEqual(byRecipient[.merkleCommitment]?.persisted, false)
    }

    func testInternalAndReleaseProjectionTypesRemainStructurallySeparate() throws {
        let value = try prepared()
        let internalLabels = Mirror(reflecting: value.internalReceipt)
            .children.compactMap(\.label)
        let releaseLabels = Mirror(reflecting: value.releasePresentation)
            .children.compactMap(\.label)

        XCTAssertEqual(internalLabels, ["claimState", "predicateCount", "authorityVector"])
        XCTAssertEqual(releaseLabels, ["claimState", "predicateCount"])
        XCTAssertTrue(internalLabels.contains("authorityVector"))
        XCTAssertFalse(releaseLabels.contains("authorityVector"))
        XCTAssertNotEqual(
            String(reflecting: type(of: value.internalReceipt)),
            String(reflecting: type(of: value.releasePresentation))
        )
        XCTAssertFalse(String(reflecting: value.releasePresentation).contains("00000000"))
    }

    func testReplayRejectsWithoutChangingConsumedDisposition() throws {
        let capability = try capability()
        guard case .prepared = consume(
            capability, request: request(), source: source()
        ) else {
            return XCTFail("Expected first consume to prepare")
        }
        XCTAssertEqual(capability.status, .consumed)

        guard case .rejected(let replay) = consume(
            capability,
            request: request(), source: source()
        ) else {
            return XCTFail("Expected replay rejection")
        }
        XCTAssertEqual(replay.verdict, .reject)
        XCTAssertEqual(replay.firstFailedPredicate, .capabilityAvailable)
        XCTAssertEqual(capability.status, .consumed)
    }

    func testAnyFailedDecisionPoisonsCapabilityAndPreventsRetry() throws {
        let capability = try capability()
        guard case .rejected(let first) = consume(
            capability,
            request: request(schema: "wrong-schema"), source: source()
        ) else {
            return XCTFail("Expected first decision to reject")
        }
        XCTAssertEqual(first.firstFailedPredicate, .schemaKnown)
        XCTAssertEqual(capability.status, .poisoned)

        guard case .rejected(let retry) = consume(
            capability,
            request: request(), source: source()
        ) else {
            return XCTFail("Expected poisoned capability retry to reject")
        }
        XCTAssertEqual(retry.firstFailedPredicate, .capabilityAvailable)
        XCTAssertEqual(capability.status, .poisoned)
    }

    func testConcurrentConsumeHasExactlyOneWinner() throws {
        let capability = try capability()
        let request = request()
        let source = source()
        let queue = DispatchQueue(label: "h4.privacy.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        let outcomes = LockedOutcomes()

        for _ in 0..<24 {
            group.enter()
            queue.async {
                outcomes.append(H4.consumeTestCapability(
                    capability, request: request, source: source
                ))
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)

        var preparedCount = 0
        var unavailableCount = 0
        for outcome in outcomes.snapshot() {
            switch outcome {
            case .prepared:
                preparedCount += 1
            case .rejected(let decision):
                if decision.firstFailedPredicate == .capabilityAvailable {
                    unavailableCount += 1
                }
            }
        }
        XCTAssertEqual(preparedCount, 1)
        XCTAssertEqual(unavailableCount, 23)
        XCTAssertEqual(capability.status, .consumed)
    }

    func testDecisionPredicateOrderingAndFailuresAreDeterministic() throws {
        let base = request()
        let badRequest = request(
            schema: "wrong-schema",
            epoch: "bad-epoch",
            destinations: Array(base.destinations.reversed())
        )
        let badSource = source(authorityVector: "UNKNOWN")
        let firstCapability = try capability(validThroughTick: 1)
        let secondCapability = try capability(validThroughTick: 1)

        guard case .rejected(let first) = consume(
            firstCapability,
            request: badRequest, source: badSource
        ), case .rejected(let second) = consume(
            secondCapability,
            request: badRequest, source: badSource
        ) else {
            return XCTFail("Expected deterministic rejections")
        }
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.predicates.map(\.id), H4.PredicateID.allCases)
        XCTAssertEqual(first.firstFailedPredicate, .schemaKnown)
        XCTAssertEqual(first.predicates.filter { !$0.passed }.map(\.id), [
            .schemaKnown,
            .epochCanonical,
            .epochExact,
            .destinationRequestsCanonical,
            .notExpired,
            .sourceBounded,
            .sourceIdentityExact,
        ])
        XCTAssertEqual(firstCapability.status, .poisoned)
        XCTAssertEqual(secondCapability.status, .poisoned)
    }

    func testAttentionVectorIsExactDiagnosticOnlyLuminosity() throws {
        let value = try prepared()
        XCTAssertEqual(value.attention, H4.AttentionVector(
            disclosure: 8,
            inference: 0,
            linkability: 2,
            retention: 3,
            crossAgent: 0,
            metadata: 2,
            externality: 0
        ))
        XCTAssertFalse(String(reflecting: value.attention).contains("allow"))
        XCTAssertFalse(String(reflecting: value.attention).contains("authority"))
    }

    func testEnvelopeIdentityAndPreparedOutputsAreDeterministic() throws {
        let first = try prepared()
        let second = try prepared()
        XCTAssertEqual(first.envelope.identity, second.envelope.identity)
        XCTAssertEqual(first.decision, second.decision)
        XCTAssertEqual(first.persistable, second.persistable)
        XCTAssertEqual(first.internalReceipt, second.internalReceipt)
        XCTAssertEqual(first.releasePresentation, second.releasePresentation)
        XCTAssertEqual(first.disclosureEvents, second.disclosureEvents)
        XCTAssertEqual(first.attention, second.attention)
    }

    func testDispatcherProvidesFiveTypedOneUseDestinations() throws {
        let value = try dispatcher()

        let internalReceipt = try value.takeInternalReceipt().get()
        let release = try value.takeReleasePresentation().get()
        let sqlite = try value.takeSQLiteProjection().get()
        let graph = try value.takeGraphPreparation().get()
        let merkle = try value.takeMerklePreparation().get()

        XCTAssertEqual(internalReceipt.projection.authorityVector, "00000000")
        XCTAssertEqual(sqlite.projection.authorityVector, "00000000")
        XCTAssertEqual(release.projection.claimState, .observedNonPass)
        XCTAssertNotEqual(String(reflecting: type(of: internalReceipt)),
                          String(reflecting: type(of: release)))
        XCTAssertNotEqual(String(reflecting: type(of: sqlite)),
                          String(reflecting: type(of: graph)))
        XCTAssertNotEqual(String(reflecting: type(of: graph)),
                          String(reflecting: type(of: merkle)))

        XCTAssertEqual(value.takeInternalReceipt(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.alreadyConsumed))
    }

    func testTakingOneDestinationDoesNotConsumeAnother() throws {
        let value = try dispatcher()
        _ = try value.takeReleasePresentation().get()
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.alreadyConsumed))
        _ = try value.takeInternalReceipt().get()
        _ = try value.takeSQLiteProjection().get()
        _ = try value.takeGraphPreparation().get()
        _ = try value.takeMerklePreparation().get()
    }

    func testEachDestinationHasExactlyOneConcurrentWinner() throws {
        let internalDispatcher = try dispatcher()
        XCTAssertEqual(concurrentWinners {
            if case .success = internalDispatcher.takeInternalReceipt() { return true }
            return false
        }, 1)

        let releaseDispatcher = try dispatcher()
        XCTAssertEqual(concurrentWinners {
            if case .success = releaseDispatcher.takeReleasePresentation() { return true }
            return false
        }, 1)

        let sqliteDispatcher = try dispatcher()
        XCTAssertEqual(concurrentWinners {
            if case .success = sqliteDispatcher.takeSQLiteProjection() { return true }
            return false
        }, 1)

        let graphDispatcher = try dispatcher()
        XCTAssertEqual(concurrentWinners {
            if case .success = graphDispatcher.takeGraphPreparation() { return true }
            return false
        }, 1)

        let merkleDispatcher = try dispatcher()
        XCTAssertEqual(concurrentWinners {
            if case .success = merkleDispatcher.takeMerklePreparation() { return true }
            return false
        }, 1)
    }

    func testAllFiveDestinationsRaceOnOneDispatcherWithoutBitInterference() throws {
        let value = try dispatcher()
        let internalWinners = LockedCounter()
        let releaseWinners = LockedCounter()
        let sqliteWinners = LockedCounter()
        let graphWinners = LockedCounter()
        let merkleWinners = LockedCounter()
        let queue = DispatchQueue(
            label: "h4.privacy.all-destinations.concurrent",
            attributes: .concurrent
        )
        let group = DispatchGroup()

        for _ in 0..<24 {
            group.enter()
            queue.async {
                if case .success = value.takeInternalReceipt() { internalWinners.increment() }
                if case .success = value.takeReleasePresentation() { releaseWinners.increment() }
                if case .success = value.takeSQLiteProjection() { sqliteWinners.increment() }
                if case .success = value.takeGraphPreparation() { graphWinners.increment() }
                if case .success = value.takeMerklePreparation() { merkleWinners.increment() }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(internalWinners.snapshot(), 1)
        XCTAssertEqual(releaseWinners.snapshot(), 1)
        XCTAssertEqual(sqliteWinners.snapshot(), 1)
        XCTAssertEqual(graphWinners.snapshot(), 1)
        XCTAssertEqual(merkleWinners.snapshot(), 1)
    }

    func testReleaseDeliveryCannotCarryInternalSourceFields() throws {
        let value = try dispatcher()
        let release = try value.takeReleasePresentation().get()
        let releaseLabels = Mirror(reflecting: release).children.compactMap(\.label)
        let projectionLabels = Mirror(reflecting: release.projection)
            .children.compactMap(\.label)

        XCTAssertEqual(releaseLabels, ["projection"])
        XCTAssertEqual(projectionLabels, ["claimState", "predicateCount"])
        for forbidden in [
            "authorityVector", "rawDiagnostic", "sourceIdentity", "epoch",
            "receiptRoot", "persistable", "internalReceipt", "envelopeIdentity",
            "disclosure",
        ] {
            XCTAssertFalse(releaseLabels.contains(forbidden))
            XCTAssertFalse(projectionLabels.contains(forbidden))
        }
        XCTAssertFalse(String(reflecting: release).contains("00000000"))
    }

    func testGraphAndMerklePreparationMarkersContainNoPayload() throws {
        let value = try dispatcher()
        let graph = try value.takeGraphPreparation().get()
        let merkle = try value.takeMerklePreparation().get()

        XCTAssertEqual(Mirror(reflecting: graph).children.compactMap(\.label), [])
        XCTAssertEqual(Mirror(reflecting: merkle).children.compactMap(\.label), [])
        for rendered in [String(reflecting: graph), String(reflecting: merkle)] {
            XCTAssertFalse(rendered.contains("payload"))
            XCTAssertFalse(rendered.contains("00000000"))
            XCTAssertFalse(rendered.contains("rawDiagnostic"))
            XCTAssertFalse(rendered.contains("envelopeIdentity"))
        }
    }

    func testRawDiagnosticCanaryIsAbsentFromEveryTypedDelivery() throws {
        let canary = "H4B-DISPATCH-RAW-DIAGNOSTIC-CANARY"
        let input = source(rawDiagnostic: Data(canary.utf8))
        let value = try dispatcher(
            capability: capability(source: input),
            source: input
        )
        let rendered = [
            String(reflecting: try value.takeInternalReceipt().get()),
            String(reflecting: try value.takeReleasePresentation().get()),
            String(reflecting: try value.takeSQLiteProjection().get()),
            String(reflecting: try value.takeGraphPreparation().get()),
            String(reflecting: try value.takeMerklePreparation().get()),
        ]
        for delivery in rendered {
            XCTAssertFalse(delivery.contains(canary))
            XCTAssertFalse(delivery.contains("rawDiagnostic"))
        }
    }

    func testConsumedCapabilityCannotProduceSecondDispatcher() throws {
        let capability = try capability()
        XCTAssertNotNil(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source()
        ))
        XCTAssertEqual(capability.status, .consumed)
        XCTAssertNil(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source()
        ))
        XCTAssertEqual(capability.status, .consumed)
    }

    func testRejectedCapabilityCannotCreateDispatcherAndStaysPoisoned() throws {
        let capability = try capability()
        XCTAssertNil(H4.consumeTestDispatcher(
            capability: capability,
            request: request(schema: "wrong-schema"),
            source: source()
        ))
        XCTAssertEqual(capability.status, .poisoned)
        XCTAssertNil(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source()
        ))
        XCTAssertEqual(capability.status, .poisoned)
    }

    func testDispatcherExpiryClosesEveryDestinationBeforeDelivery() throws {
        let capability = try capability(validThroughTick: UInt64.max - 1)
        let value = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source(),
            deliveryTick: { UInt64.max }
        ))
        XCTAssertEqual(capability.status, .consumed)

        XCTAssertEqual(value.takeReleasePresentation(), .failure(.expired))
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.expired))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.expired))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.expired))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.expired))
    }

    func testDispatcherCutoffIsInclusive() throws {
        let cutoff = UInt64.max - 1
        let tick = LockedTick(cutoff)
        let capability = try capability(validThroughTick: cutoff)
        let value = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source(),
            deliveryTick: { tick.read() }
        ))

        _ = try value.takeInternalReceipt().get()
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.alreadyConsumed))
    }

    func testExpiryAfterOneDeliveryClosesOnlyUndeliveredSlots() throws {
        let cutoff = UInt64.max - 1
        let tick = LockedTick(cutoff)
        let capability = try capability(validThroughTick: cutoff)
        let value = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: request(),
            source: source(),
            deliveryTick: { tick.read() }
        ))

        _ = try value.takeInternalReceipt().get()
        tick.set(cutoff + 1)

        XCTAssertEqual(value.takeReleasePresentation(), .failure(.expired))
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.expired))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.expired))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.expired))
    }
}

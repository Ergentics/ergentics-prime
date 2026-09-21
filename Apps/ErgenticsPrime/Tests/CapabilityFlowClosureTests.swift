import CryptoKit
import Foundation
import XCTest

final class CapabilityFlowClosureTests: XCTestCase {
    private typealias C = CapabilityFlowClosure
    private let executionA: C.ID = 101
    private let executionB: C.ID = 102
    private let verifier: C.ID = 900
    private let transitionID: C.ID = 1_001
    private let purpose: C.ID = 77

    private var root: C.AuthorityRoot {
        .init(id: C.authorityRootID, policyID: C.policyID,
              policyGeneration: C.policyGeneration)
    }

    private var resources: C.ResourceUse {
        .init(executionTicks: 10, workUnits: 20, memoryBytes: 4_096,
              graphExpansion: 4, branchCount: 1, childExecutions: 0,
              capabilityOperations: 8, persistentWrites: 0, outputBytes: 128)
    }

    private func object(_ id: C.ID = 10, owner: C.ID? = 101,
                        role: C.ObjectRole = .data, shared: Bool = false,
                        persistent: Bool = false, crossExecution: Bool = false,
                        externallyObservable: Bool = false, ambient: Bool = false,
                        states: UInt64 = 1,
                        channel: C.ChannelClass = .content,
                        theoremState: C.TheoremState? = nil) -> C.ObjectState {
        let resolvedTheoremState = theoremState ?? (role == .theoremClaim
            ? C.TheoremState(theorem: .riemannHypothesis, disposition: .candidate) : nil)
        return .init(id: id, ownerExecutionID: owner, role: role, shared: shared,
              persistent: persistent, crossExecution: crossExecution,
              externallyObservable: externallyObservable, ambient: ambient,
              distinguishableStates: states, channelClass: channel,
              theoremState: resolvedTheoremState)
    }

    private func grant(_ id: C.ID, subject: C.ID, object: C.ID,
                       operation: C.Operation, method: C.Method = .direct,
                       peer: C.ID? = nil, issuer: C.GrantIssuer? = nil,
                       external: Bool = true, persist: Bool = false,
                       issuedFor: C.ID? = nil, grantPurpose: C.ID? = nil) -> C.Grant {
        .init(id: id, issuer: issuer ?? .authorityRoot(C.authorityRootID),
              subjectExecutionID: subject, objectID: object, operation: operation,
              method: method, purposeID: grantPurpose ?? purpose,
              peerExecutionID: peer, validFromGeneration: 1,
              validThroughGeneration: 1, allowsDelegation: false,
              allowsPersistence: persist, externalPolicyDecision: external,
              issuedForTransitionID: issuedFor)
    }

    private func transition(execution: C.ID = 101, before: [C.ID] = [],
                            after: [C.ID] = [], goal: Bool = true,
                            typedGoal: C.Goal? = nil,
                            boundary: Bool = false, terminal: C.Terminal = .completed,
                            policyBefore: String = C.policyID,
                            policyAfter: String = C.policyID,
                            policyGenerationBefore: UInt64 = C.policyGeneration,
                            policyGenerationAfter: UInt64 = C.policyGeneration,
                            chiBefore: UInt64 = 4, chiAfter: UInt64 = 4,
                            resources: C.ResourceUse? = nil) -> C.Transition {
        .init(id: transitionID, executionID: execution, purposeID: purpose,
              goal: typedGoal ?? .ordinary(subjectObjectID: 10),
              beforeCapabilityIDs: before, afterCapabilityIDs: after,
              policyIDBefore: policyBefore, policyIDAfter: policyAfter,
              policyGenerationBefore: policyGenerationBefore,
              policyGenerationAfter: policyGenerationAfter,
              goalSatisfied: goal, capabilityBoundaryReached: boundary,
              terminal: terminal, changeIndexBefore: chiBefore,
              changeIndexAfter: chiAfter, resources: resources ?? self.resources)
    }

    private func evidence(_ accesses: [C.Access], suppressed: Set<C.ID> = []) -> [C.AuditEvidence] {
        accesses.enumerated().map { index, access in
            C.AuditEvidence(id: C.ID(2_000 + index), accessID: access.id,
                sequence: UInt64(index), acceptedByVerifierID: verifier,
                digest: independentAccessDigest(access),
                suppressed: suppressed.contains(access.id))
        }
    }

    private func independentAccessDigest(_ access: C.Access) -> Data {
        let frame = try! GuestCBOR.encode(.map([
            "schema": .text("ergentics.capability-flow-closure.access-evidence.v1"),
            "id": .unsigned(UInt64(access.id)),
            "execution": .unsigned(UInt64(access.executionID)),
            "object": .unsigned(UInt64(access.objectID)),
            "operation": .unsigned(access.operation.rawValue),
            "method": .unsigned(access.method.rawValue),
            "peer": .unsigned(UInt64(access.peerExecutionID ?? 0)),
            "capability": .unsigned(UInt64(access.capabilityID ?? 0)),
            "outcome": .unsigned(access.outcome.rawValue),
            "phase": .unsigned(access.capabilityPhase.rawValue),
        ]))
        return Data(SHA256.hash(data: frame))
    }

    private func scenario(beforeObjects: [C.ObjectState], afterObjects: [C.ObjectState],
                          grants: [C.Grant] = [], capabilities: [C.Capability] = [],
                          executions: [C.Execution]? = nil,
                          transition: C.Transition? = nil, accesses: [C.Access] = [],
                          evidence explicitEvidence: [C.AuditEvidence]? = nil) -> C.Scenario {
        let t = transition ?? self.transition()
        let defaultExecutions = [C.Execution(id: executionA, generation: 1,
            purposeID: purpose, capabilityIDs: t.afterCapabilityIDs)]
        return .init(authorityRoots: [root], beforeObjects: beforeObjects,
            afterObjects: afterObjects, grants: grants, capabilities: capabilities,
            executions: executions ?? defaultExecutions, transition: t,
            accesses: accesses, evidence: explicitEvidence ?? evidence(accesses),
            verifierID: verifier)
    }

    private func findingCodes(_ report: C.Report) -> Set<C.FindingCode> {
        Set(report.findings.map(\.code))
    }

    private func rebound(_ report: C.Report, scenarioCBOR: Data? = nil,
                         resultCBOR: Data? = nil,
                         commitCandidateEligible: Bool? = nil) throws -> C.Report {
        let scenario = scenarioCBOR ?? report.scenarioCBOR
        let result = resultCBOR ?? report.resultCBOR
        let commitment = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(C.schema.utf8)),
            GenesisLeaf(label: "scenario", payload: scenario),
            GenesisLeaf(label: "result", payload: result),
        ])
        return C.Report(status: report.status, findings: report.findings,
            channels: report.channels, tripwires: report.tripwires,
            commitCandidateEligible: commitCandidateEligible ?? report.commitCandidateEligible,
            changeIndexDelta: report.changeIndexDelta, scenarioCBOR: scenario,
            resultCBOR: result, commitment: commitment)
    }

    func testPrivateEphemeralGraphClosesAndReceiptRoundTrips() throws {
        let item = object()
        let report = try C.audit(scenario(beforeObjects: [item], afterObjects: [item]))
        XCTAssertEqual(report.status, .declaredGraphClosed)
        XCTAssertTrue(report.findings.isEmpty)
        XCTAssertTrue(report.channels.isEmpty)
        XCTAssertTrue(report.commitCandidateEligible)
        XCTAssertEqual(report.changeIndexDelta, 0)
        try CapabilityFlowClosureReference.verifyReceipt(report)

        // A hostile independent receipt must not reinterpret an unknown goal
        // tag as an ordinary non-theorem goal merely because the CBOR is valid.
        guard case .map(var root) = try GuestCBOR.decode(report.scenarioCBOR),
              case .map(var transition) = root["transition"] else {
            return XCTFail("scenario shape")
        }
        transition["goal"] = .array([.unsigned(99), .unsigned(10)])
        root["transition"] = .map(transition)
        let unknownGoal = try rebound(report,
            scenarioCBOR: try GuestCBOR.encode(.map(root)))
        XCTAssertThrowsError(
            try CapabilityFlowClosureReference.verifyRiemannTripwire(unknownGoal))

        // Keeping the theorem state stable does not make it an ordinary-goal
        // subject. The independent verifier must join the goal to object role.
        guard case .map(var theoremRoot) = try GuestCBOR.decode(report.scenarioCBOR),
              case .array(let beforeObjects) = theoremRoot["before_objects"],
              case .array(let afterObjects) = theoremRoot["after_objects"] else {
            return XCTFail("scenario object shape")
        }
        func rewrittenAsRiemannCandidate(_ value: GuestCBORValue) throws -> GuestCBORValue {
            guard case .array(var fields) = value, fields.count == 11 else {
                throw CapabilityFlowClosureReference.Failure.malformed
            }
            fields[2] = .unsigned(C.ObjectRole.theoremClaim.rawValue)
            fields[10] = .array([
                .unsigned(C.TheoremIdentifier.riemannHypothesis.rawValue),
                .unsigned(C.TheoremDisposition.candidate.rawValue),
            ])
            return .array(fields)
        }
        theoremRoot["before_objects"] = .array(try beforeObjects.map(rewrittenAsRiemannCandidate))
        theoremRoot["after_objects"] = .array(try afterObjects.map(rewrittenAsRiemannCandidate))
        let ordinaryTheorem = try rebound(report,
            scenarioCBOR: try GuestCBOR.encode(.map(theoremRoot)))
        XCTAssertThrowsError(
            try CapabilityFlowClosureReference.verifyRiemannTripwire(ordinaryTheorem))
    }

    func testExplicitSemanticCommunicationClosesButRemainsVisible() throws {
        let item = object(owner: nil, shared: true, persistent: true,
                          crossExecution: true, states: 256)
        let grants = [
            grant(1, subject: executionA, object: 10, operation: .write),
            grant(2, subject: executionA, object: 10, operation: .send,
                  method: .semanticMessage, peer: executionB),
            grant(3, subject: executionB, object: 10, operation: .read),
            grant(4, subject: executionB, object: 10, operation: .receive,
                  method: .semanticMessage, peer: executionA),
        ]
        let caps = zip(C.ID(11)...C.ID(14), grants).map { C.Capability(id: $0.0, grantID: $0.1.id) }
        let executions = [
            C.Execution(id: executionA, generation: 1, purposeID: purpose, capabilityIDs: [11, 12]),
            C.Execution(id: executionB, generation: 1, purposeID: purpose, capabilityIDs: [13, 14]),
        ]
        let t = transition(before: [11, 12], after: [11, 12])
        let input = scenario(beforeObjects: [item], afterObjects: [item], grants: grants,
                             capabilities: caps, executions: executions, transition: t)
        let report = try C.audit(input)
        XCTAssertEqual(report.status, .declaredGraphClosed)
        XCTAssertEqual(report.channels, CapabilityFlowClosureReference.structuralChannels(input))
        XCTAssertEqual(report.channels.count, 1)
        XCTAssertTrue(report.channels[0].explicitlyAuthorized)
        XCTAssertEqual(report.channels[0].declaredCapacityBits, 8)
        XCTAssertTrue(report.channels[0].survivesRestart)
        try CapabilityFlowClosureReference.verifyReceipt(report)
    }

    func testIncidentMessageBoardsRejectContentNameErrorAndRestartChannels() throws {
        let classes: [C.ChannelClass] = [.content, .name, .error]
        for (offset, channelClass) in classes.enumerated() {
            let id = C.ID(20 + offset)
            let item = object(id, owner: nil, role: channelClass == .error ? .diagnostic : .data,
                              shared: true, persistent: true, crossExecution: true,
                              externallyObservable: true, states: 256, channel: channelClass)
            let grants = [grant(1, subject: executionA, object: id, operation: .write),
                          grant(2, subject: executionB, object: id, operation: .discover)]
            let caps = [C.Capability(id: 11, grantID: 1), C.Capability(id: 12, grantID: 2)]
            let executions = [
                C.Execution(id: executionA, generation: 1, purposeID: purpose, capabilityIDs: [11]),
                C.Execution(id: executionB, generation: 1, purposeID: purpose, capabilityIDs: [12]),
            ]
            let input = scenario(beforeObjects: [item], afterObjects: [item], grants: grants,
                capabilities: caps, executions: executions,
                transition: transition(before: [11], after: [11],
                    typedGoal: .ordinary(subjectObjectID: id)))
            let report = try C.audit(input)
            XCTAssertEqual(report.status, .rejectedClosure)
            XCTAssertTrue(findingCodes(report).contains(.unauthorizedChannel))
            XCTAssertEqual(report.channels, CapabilityFlowClosureReference.structuralChannels(input))
            XCTAssertEqual(report.channels.first?.declaredCapacityBits, 8)
            XCTAssertEqual(report.channels.first?.survivesRestart, true)
            XCTAssertFalse(report.channels.first?.explicitlyAuthorized ?? true)
        }
    }

    func testConfigurationCannotSilentlyBecomeExecutable() throws {
        let before = object(role: .configuration, states: 2, channel: .executableInput)
        let after = object(role: .executable, states: 2, channel: .executableInput)
        let report = try C.audit(scenario(beforeObjects: [before], afterObjects: [after]))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .unauthorizedRoleChange, .executableRoleWithoutCapability,
        ]))
        XCTAssertTrue(report.tripwires.contains { $0.kind == .executableInput })
    }

    func testExplicitRoleAndPersistenceTransitionsClose() throws {
        let before = object(role: .configuration)
        let after = object(role: .executable, persistent: true)
        let grants = [
            grant(1, subject: executionA, object: 10, operation: .changeRole,
                  method: .explicitRoleTransition),
            grant(2, subject: executionA, object: 10, operation: .execute),
            grant(3, subject: executionA, object: 10, operation: .persist,
                  method: .explicitPersistence, persist: true),
        ]
        let caps = zip(C.ID(11)...C.ID(13), grants).map { C.Capability(id: $0.0, grantID: $0.1.id) }
        let measured = C.ResourceUse(executionTicks: resources.executionTicks,
            workUnits: resources.workUnits, memoryBytes: resources.memoryBytes,
            graphExpansion: resources.graphExpansion, branchCount: resources.branchCount,
            childExecutions: resources.childExecutions,
            capabilityOperations: resources.capabilityOperations,
            persistentWrites: 1, outputBytes: resources.outputBytes)
        let t = transition(before: [11, 12, 13], after: [11, 12, 13],
            resources: measured)
        let accesses = [
            C.Access(id: 1, executionID: executionA, objectID: 10,
                operation: .changeRole, method: .explicitRoleTransition,
                peerExecutionID: nil, capabilityID: 11, outcome: .performed),
            C.Access(id: 2, executionID: executionA, objectID: 10,
                operation: .persist, method: .explicitPersistence,
                peerExecutionID: nil, capabilityID: 13, outcome: .performed),
        ]
        let report = try C.audit(scenario(beforeObjects: [before], afterObjects: [after],
            grants: grants, capabilities: caps, transition: t, accesses: accesses))
        XCTAssertEqual(report.status, .declaredGraphClosed)
        XCTAssertTrue(report.findings.isEmpty)
    }

    func testExternalStorageEnvironmentReadAndCredentialUseReject() throws {
        let secret = object(role: .credential, shared: true, crossExecution: true,
                            externallyObservable: true, states: .max, channel: .content)
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: nil, outcome: .performed)
        let report = try C.audit(scenario(beforeObjects: [secret], afterObjects: [secret],
            accesses: [access]))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .performedWithoutCapability, .credentialUseWithoutGrant,
        ]))
        XCTAssertTrue(report.tripwires.contains { $0.kind == .credentialProbe })
    }

    func testCapabilityDescriptionRemainsInformationOnly() throws {
        let description = object(role: .capabilityDescription)
        let read = grant(1, subject: executionA, object: 10, operation: .read)
        let cap = C.Capability(id: 11, grantID: 1)
        let t = transition(before: [11], after: [11])
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: 11, outcome: .performed)
        let report = try C.audit(scenario(beforeObjects: [description], afterObjects: [description],
            grants: [read], capabilities: [cap], transition: t, accesses: [access]))
        XCTAssertEqual(report.status, .declaredGraphClosed)
        XCTAssertEqual(report.findings, [])
    }

    func testPeerGoCannotMintAuthority() throws {
        let item = object()
        let forged = grant(1, subject: executionA, object: 10, operation: .read,
            issuer: .execution(executionB), external: false, issuedFor: transitionID)
        let cap = C.Capability(id: 11, grantID: 1)
        let executions = [
            C.Execution(id: executionA, generation: 1, purposeID: purpose, capabilityIDs: [11]),
            C.Execution(id: executionB, generation: 1, purposeID: purpose, capabilityIDs: []),
        ]
        let report = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            grants: [forged], capabilities: [cap], executions: executions,
            transition: transition(before: [], after: [11])))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .invalidCapabilityProvenance, .selfGrant, .capabilityAmplification,
        ]))
    }

    func testBlockedNeedsAuthorityIsAClosedTerminal() throws {
        let item = object(role: .credential)
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .authenticate, method: .direct, peerExecutionID: nil,
            capabilityID: nil, outcome: .denied)
        let t = transition(goal: false, boundary: true, terminal: .blockedNeedsAuthority)
        let report = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            transition: t, accesses: [access]))
        XCTAssertEqual(report.status, .declaredGraphClosedWithBlockedExecution)
        XCTAssertTrue(report.findings.isEmpty)
        XCTAssertFalse(report.commitCandidateEligible)
        XCTAssertTrue(report.tripwires.contains { $0.kind == .credentialProbe })
    }

    func testRiemannHypothesisCandidateCannotSelfCertify() throws {
        // This fixture does not decide the theorem. It proves only that a
        // candidate proof cannot turn its own claim into committed authority.
        let claim = object(role: .theoremClaim, states: 2, channel: .content)
        let denied = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .certifyTheorem, method: .independentCommit,
            peerExecutionID: nil, capabilityID: nil, outcome: .denied)
        let blocked = transition(goal: false,
            typedGoal: .formalTheorem(theorem: .riemannHypothesis, claimObjectID: 10),
            boundary: true, terminal: .blockedNeedsAuthority)
        let compliant = try C.audit(scenario(beforeObjects: [claim], afterObjects: [claim],
            transition: blocked, accesses: [denied]))
        XCTAssertEqual(compliant.status, .declaredGraphClosedWithBlockedExecution)
        XCTAssertTrue(compliant.findings.isEmpty)
        XCTAssertTrue(compliant.tripwires.contains { $0.kind == .unverifiedTheoremClaim })
        XCTAssertEqual(compliant.changeIndexDelta, 0)
        try CapabilityFlowClosureReference.verifyReceipt(compliant)
        try CapabilityFlowClosureReference.verifyRiemannTripwire(compliant)

        // Unknown raw outcomes are not aliases for a denied certification.
        guard case .map(var outcomeRoot) = try GuestCBOR.decode(compliant.scenarioCBOR),
              case .array(var outcomeAccesses) = outcomeRoot["accesses"],
              case .array(var outcomeFields) = outcomeAccesses.first,
              outcomeFields.count == 9 else {
            return XCTFail("certification access shape")
        }
        outcomeFields[7] = .unsigned(99)
        outcomeAccesses[0] = .array(outcomeFields)
        outcomeRoot["accesses"] = .array(outcomeAccesses)
        let unknownOutcome = try rebound(compliant,
            scenarioCBOR: try GuestCBOR.encode(.map(outcomeRoot)))
        XCTAssertThrowsError(
            try CapabilityFlowClosureReference.verifyRiemannTripwire(unknownOutcome))

        let zeroAccessBlocked = try C.audit(scenario(beforeObjects: [claim],
            afterObjects: [claim], transition: blocked, accesses: []))
        XCTAssertEqual(zeroAccessBlocked.status, .declaredGraphClosedWithBlockedExecution)
        XCTAssertTrue(zeroAccessBlocked.findings.isEmpty)
        XCTAssertTrue(zeroAccessBlocked.tripwires.contains {
            $0.kind == .unverifiedTheoremClaim && $0.accessID == nil
        })
        try CapabilityFlowClosureReference.verifyRiemannTripwire(zeroAccessBlocked)

        let performed = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .certifyTheorem, method: .independentCommit,
            peerExecutionID: nil, capabilityID: nil, outcome: .performed)
        let forgedCompletion = transition(goal: true,
            typedGoal: .formalTheorem(theorem: .riemannHypothesis, claimObjectID: 10),
            boundary: false, terminal: .completed)
        let rejected = try C.audit(scenario(beforeObjects: [claim], afterObjects: [claim],
            transition: forgedCompletion, accesses: [performed]))
        XCTAssertEqual(rejected.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(rejected).contains(.unverifiedTheoremClaim))
        XCTAssertEqual(rejected.changeIndexDelta, 0)

        let omitted = try C.audit(scenario(beforeObjects: [claim], afterObjects: [claim],
            transition: forgedCompletion, accesses: []))
        XCTAssertEqual(omitted.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(omitted).contains(.unverifiedTheoremClaim))
        XCTAssertTrue(omitted.tripwires.contains {
            $0.kind == .unverifiedTheoremClaim && $0.accessID == nil
        })
        XCTAssertFalse(omitted.commitCandidateEligible)
        XCTAssertEqual(omitted.changeIndexDelta, 0)
        try CapabilityFlowClosureReference.verifyReceipt(omitted)
        try CapabilityFlowClosureReference.verifyRiemannTripwire(omitted)
    }

    func testRiemannFalseBoundaryRelabelAndVerifiedDispositionFailClosed() throws {
        let claim = object(role: .theoremClaim, states: 2, channel: .content)
        let falseBoundary = transition(goal: false,
            typedGoal: .formalTheorem(theorem: .riemannHypothesis, claimObjectID: 10),
            boundary: false, terminal: .blockedNeedsAuthority)
        let report = try C.audit(scenario(beforeObjects: [claim], afterObjects: [claim],
            transition: falseBoundary))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .unverifiedTheoremClaim, .terminalInconsistent,
        ]))
        XCTAssertEqual(report.changeIndexDelta, 0)

        XCTAssertThrowsError(try C.audit(scenario(beforeObjects: [claim],
            afterObjects: [claim], transition: transition())))

        let asserted = object(role: .theoremClaim, states: 2, channel: .content,
            theoremState: .init(theorem: .riemannHypothesis,
                                disposition: .independentlyVerified))
        let blocked = transition(goal: false,
            typedGoal: .formalTheorem(theorem: .riemannHypothesis, claimObjectID: 10),
            boundary: true, terminal: .blockedNeedsAuthority)
        let assertedReport = try C.audit(scenario(beforeObjects: [claim],
            afterObjects: [asserted], transition: blocked))
        XCTAssertEqual(assertedReport.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(assertedReport).contains(.unverifiedTheoremClaim))
        XCTAssertFalse(assertedReport.commitCandidateEligible)
        XCTAssertEqual(assertedReport.changeIndexDelta, 0)
        try CapabilityFlowClosureReference.verifyRiemannTripwire(assertedReport)

        let ordinary = object(20)
        let ordinaryGoal = transition(typedGoal: .ordinary(subjectObjectID: 20))
        let dispositionOnly = try C.audit(scenario(beforeObjects: [claim, ordinary],
            afterObjects: [asserted, ordinary], transition: ordinaryGoal))
        XCTAssertEqual(dispositionOnly.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(dispositionOnly).contains(.unverifiedTheoremClaim))
        try CapabilityFlowClosureReference.verifyRiemannTripwire(dispositionOnly)
    }

    func testRiemannClassificationCannotBeLaunderedIntoOrdinaryData() throws {
        let claim = object(role: .theoremClaim, states: 2)
        let laundered = object(role: .data, states: 2)
        let roleGrant = grant(1, subject: executionA, object: 10,
            operation: .changeRole, method: .explicitRoleTransition)
        let capability = C.Capability(id: 11, grantID: 1)
        let t = transition(before: [11], after: [11],
            typedGoal: .ordinary(subjectObjectID: 10))
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .changeRole, method: .explicitRoleTransition,
            peerExecutionID: nil, capabilityID: 11, outcome: .performed)
        let report = try C.audit(scenario(beforeObjects: [claim], afterObjects: [laundered],
            grants: [roleGrant], capabilities: [capability], transition: t,
            accesses: [access]))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).contains(.unverifiedTheoremClaim))
        XCTAssertTrue(report.tripwires.contains {
            $0.kind == .unverifiedTheoremClaim && $0.objectID == 10
        })
        XCTAssertFalse(report.commitCandidateEligible)
        XCTAssertEqual(report.changeIndexDelta, 0)
        try CapabilityFlowClosureReference.verifyRiemannTripwire(report)

        // Even a self-consistent replacement result/Merkle root cannot mark a
        // theorem-state mutation eligible merely by changing the result bit.
        guard case .map(var resultMap) = try GuestCBOR.decode(report.resultCBOR) else {
            return XCTFail("result shape")
        }
        resultMap["commit_candidate_eligible"] = .bool(true)
        let forgedResult = try GuestCBOR.encode(.map(resultMap))
        let forged = try rebound(report, resultCBOR: forgedResult,
                                 commitCandidateEligible: true)
        XCTAssertThrowsError(try CapabilityFlowClosureReference.verifyRiemannTripwire(forged))
    }

    func testTransitionIssuedCapabilityCannotBeInjectedIntoBeforeSet() throws {
        let item = object()
        let injectedGrant = grant(1, subject: executionA, object: 10,
            operation: .read, issuedFor: transitionID)
        let capability = C.Capability(id: 11, grantID: 1)
        let t = transition(before: [11], after: [11])
        let report = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            grants: [injectedGrant], capabilities: [capability], transition: t))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).contains(.capabilityAmplification))
    }

    func testPolicyWriteAliasAndStateConcealmentReject() throws {
        let policy = object(role: .policy)
        let write = grant(1, subject: executionA, object: 10, operation: .write)
        let cap = C.Capability(id: 11, grantID: 1)
        let t = transition(before: [11], after: [11])
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .write, method: .direct, peerExecutionID: nil,
            capabilityID: 11, outcome: .performed)
        let policyReport = try C.audit(scenario(beforeObjects: [policy], afterObjects: [policy],
            grants: [write], capabilities: [cap], transition: t, accesses: [access]))
        XCTAssertEqual(policyReport.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(policyReport).contains(.immutableSurfaceCapability))

        let before = object(persistent: true, states: 256)
        let after = object(persistent: false, states: 1)
        let concealment = try C.audit(scenario(beforeObjects: [before], afterObjects: [after]))
        XCTAssertEqual(concealment.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(concealment).contains(.objectStateConcealment))
    }

    func testAccessEvidenceAndCapabilityPhaseAreBound() throws {
        let item = object()
        let issued = grant(1, subject: executionA, object: 10, operation: .read,
            issuedFor: transitionID)
        let cap = C.Capability(id: 11, grantID: 1)
        let t = transition(before: [], after: [11])
        let tooEarly = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: 11, outcome: .performed, capabilityPhase: .beforeTransition)
        let temporal = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            grants: [issued], capabilities: [cap], transition: t, accesses: [tooEarly]))
        XCTAssertEqual(temporal.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(temporal).contains(.performedWithoutCapability))

        let validAfter = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: 11, outcome: .performed, capabilityPhase: .afterTransition)
        let forged = [C.AuditEvidence(id: 2_000, accessID: 1, sequence: 0,
            acceptedByVerifierID: verifier, digest: Data(repeating: 0, count: 32),
            suppressed: false)]
        let digestReport = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            grants: [issued], capabilities: [cap], transition: t,
            accesses: [validAfter], evidence: forged))
        XCTAssertEqual(digestReport.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(digestReport).contains(.auditMissing))
    }

    func testOptionalIDSentinelsAndVisibilityGrowthCannotAliasOrPass() throws {
        let item = object()
        let zeroIssued = grant(1, subject: executionA, object: 10,
            operation: .read, issuedFor: 0)
        let cap = C.Capability(id: 11, grantID: 1)
        XCTAssertThrowsError(try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            grants: [zeroIssued], capabilities: [cap],
            transition: transition(after: [11]))))

        let zeroOwner = object(owner: 0)
        XCTAssertThrowsError(try C.audit(scenario(beforeObjects: [zeroOwner],
            afterObjects: [zeroOwner])))

        let privateBefore = object(states: 1)
        let visibleAfter = object(externallyObservable: true, ambient: true, states: 2)
        let report = try C.audit(scenario(beforeObjects: [privateBefore],
            afterObjects: [visibleAfter]))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .unauthorizedSharing, .unauthorizedChannel,
        ]))
    }

    func testPolicyAuditResourceAndChangeIndexFailuresAreDataLed() throws {
        let item = object()
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: nil, outcome: .denied)
        var over = resources
        over = C.ResourceUse(executionTicks: over.executionTicks, workUnits: over.workUnits,
            memoryBytes: over.memoryBytes, graphExpansion: over.graphExpansion,
            branchCount: over.branchCount, childExecutions: 1,
            capabilityOperations: over.capabilityOperations,
            persistentWrites: over.persistentWrites, outputBytes: over.outputBytes)
        let t = transition(goal: false, boundary: true, terminal: .blockedNeedsAuthority,
            policyAfter: String(repeating: "0", count: 64), chiAfter: 5, resources: over)
        let report = try C.audit(scenario(beforeObjects: [item], afterObjects: [item],
            transition: t, accesses: [access], evidence: []))
        XCTAssertEqual(report.status, .rejectedClosure)
        XCTAssertTrue(findingCodes(report).isSuperset(of: [
            .policyMutation, .auditMissing, .resourceExceeded, .changeIndexAdvanced,
        ]))
    }

    func testInputOrderIsCanonicalAndTamperChangesTheCommitment() throws {
        let item = object(owner: nil, shared: true, persistent: true,
                          crossExecution: true, states: 2)
        let grants = [grant(1, subject: executionA, object: 10, operation: .write),
                      grant(2, subject: executionB, object: 10, operation: .read)]
        let caps = [C.Capability(id: 11, grantID: 1), C.Capability(id: 12, grantID: 2)]
        let executions = [
            C.Execution(id: executionA, generation: 1, purposeID: purpose, capabilityIDs: [11]),
            C.Execution(id: executionB, generation: 1, purposeID: purpose, capabilityIDs: [12]),
        ]
        let t = transition(before: [11], after: [11])
        let first = scenario(beforeObjects: [item], afterObjects: [item], grants: grants,
            capabilities: caps, executions: executions, transition: t)
        let second = scenario(beforeObjects: [item], afterObjects: [item],
            grants: Array(grants.reversed()), capabilities: Array(caps.reversed()),
            executions: Array(executions.reversed()), transition: t)
        let a = try C.audit(first), b = try C.audit(second)
        XCTAssertEqual(a.scenarioCBOR, b.scenarioCBOR)
        XCTAssertEqual(a.resultCBOR, b.resultCBOR)
        XCTAssertEqual(a.commitment, b.commitment)
        try CapabilityFlowClosureReference.verifyReceipt(a)

        var tampered = a.resultCBOR
        tampered[tampered.startIndex] ^= 1
        XCTAssertFalse(try MerkleGenesis.verify([
            GenesisLeaf(label: "schema", payload: Data(C.schema.utf8)),
            GenesisLeaf(label: "scenario", payload: a.scenarioCBOR),
            GenesisLeaf(label: "result", payload: tampered),
        ], expectedRoot: a.commitment.root))
    }

    func testMalformedIdentityAndEvidenceSequenceRejectAsInvalidInput() {
        let item = object()
        let access = C.Access(id: 1, executionID: executionA, objectID: 10,
            operation: .read, method: .direct, peerExecutionID: nil,
            capabilityID: nil, outcome: .denied)
        let badEvidence = [C.AuditEvidence(id: 1, accessID: 1, sequence: 1,
            acceptedByVerifierID: verifier, digest: Data(repeating: 0, count: 32),
            suppressed: false)]
        XCTAssertThrowsError(try C.audit(scenario(beforeObjects: [item, item],
            afterObjects: [item], accesses: [])))
        XCTAssertThrowsError(try C.audit(scenario(beforeObjects: [item],
            afterObjects: [item], accesses: [access], evidence: badEvidence)))
    }
}

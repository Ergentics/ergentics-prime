import Foundation

/// Test-only reconstruction. It does not call CapabilityFlowClosure.audit or
/// any of that evaluator's private helpers.
enum CapabilityFlowClosureReference {
    typealias C = CapabilityFlowClosure

    enum Failure: Error {
        case malformed
    }

    private struct DecodedTheorem: Equatable {
        let theorem: UInt64
        let disposition: UInt64
    }

    static func structuralChannels(_ scenario: C.Scenario) -> [C.ChannelCandidate] {
        let grants = Dictionary(uniqueKeysWithValues: scenario.grants.map { ($0.id, $0) })
        let capabilities = Dictionary(uniqueKeysWithValues: scenario.capabilities.map { ($0.id, $0) })

        struct Held {
            let executionID: C.ID
            let grant: C.Grant
        }
        var held: [Held] = []
        for execution in scenario.executions {
            for capabilityID in execution.capabilityIDs {
                guard let capability = capabilities[capabilityID],
                      let grant = grants[capability.grantID],
                      case .authorityRoot(let root) = grant.issuer,
                      root == C.authorityRootID,
                      grant.externalPolicyDecision,
                      !grant.allowsDelegation,
                      grant.subjectExecutionID == execution.id,
                      grant.purposeID == execution.purposeID,
                      grant.validFromGeneration <= execution.generation,
                      execution.generation <= grant.validThroughGeneration else { continue }
                held.append(Held(executionID: execution.id, grant: grant))
            }
        }

        var result = Set<C.ChannelCandidate>()
        for object in scenario.afterObjects where object.distinguishableStates >= 2 {
            let writers = held.filter { $0.grant.objectID == object.id && $0.grant.operation == .write }
            let observers = held.filter { $0.grant.objectID == object.id &&
                ($0.grant.operation == .read || $0.grant.operation == .discover) }
            for writer in writers {
                for observer in observers where writer.executionID != observer.executionID {
                    let send = held.contains { $0.executionID == writer.executionID &&
                        $0.grant.objectID == object.id && $0.grant.operation == .send &&
                        $0.grant.peerExecutionID == observer.executionID }
                    let receive = held.contains { $0.executionID == observer.executionID &&
                        $0.grant.objectID == object.id && $0.grant.operation == .receive &&
                        $0.grant.peerExecutionID == writer.executionID }
                    var value = object.distinguishableStates
                    var bits: UInt64 = 0
                    while value > 1 { bits += 1; value >>= 1 }
                    result.insert(C.ChannelCandidate(sourceExecutionID: writer.executionID,
                        sinkExecutionID: observer.executionID, objectID: object.id,
                        channelClass: object.channelClass, declaredCapacityBits: bits,
                        survivesRestart: object.persistent,
                        explicitlyAuthorized: send && receive))
                }
            }
        }
        return result.sorted {
            ($0.sourceExecutionID, $0.sinkExecutionID, $0.objectID, $0.channelClass.rawValue) <
            ($1.sourceExecutionID, $1.sinkExecutionID, $1.objectID, $1.channelClass.rawValue)
        }
    }

    static func verifyReceipt(_ report: C.Report) throws {
        let scenarioValue = try GuestCBOR.decode(report.scenarioCBOR)
        let resultValue = try GuestCBOR.decode(report.resultCBOR)
        guard try GuestCBOR.encode(scenarioValue) == report.scenarioCBOR,
              try GuestCBOR.encode(resultValue) == report.resultCBOR,
              try MerkleGenesis.verify([
                GenesisLeaf(label: "result", payload: report.resultCBOR),
                GenesisLeaf(label: "schema", payload: Data(C.schema.utf8)),
                GenesisLeaf(label: "scenario", payload: report.scenarioCBOR),
              ], expectedRoot: report.commitment.root),
              report.commitment.leafCount == 3,
              report.changeIndexDelta == 0 else { throw Failure.malformed }
        guard case .map(let map) = resultValue,
              Set(map.keys) == Set(["schema", "status", "findings", "channels", "tripwires",
                                    "commit_candidate_eligible", "change_index_delta"]),
              map["schema"] == .text(C.schema),
              map["status"] == .text(report.status.rawValue),
              map["commit_candidate_eligible"] == .bool(report.commitCandidateEligible),
              map["change_index_delta"] == .unsigned(0),
              case .array(let findings) = map["findings"], findings.count == report.findings.count,
              case .array(let channels) = map["channels"], channels.count == report.channels.count,
              case .array(let tripwires) = map["tripwires"], tripwires.count == report.tripwires.count
        else { throw Failure.malformed }

        let expectedFindings = report.findings.map {
            GuestCBORValue.array([.text($0.code.rawValue),
                .unsigned(UInt64($0.executionID ?? 0)),
                .unsigned(UInt64($0.objectID ?? 0)),
                .unsigned(UInt64($0.capabilityID ?? 0)),
                .unsigned(UInt64($0.transitionID ?? 0))])
        }
        let expectedChannels = report.channels.map {
            GuestCBORValue.array([.unsigned(UInt64($0.sourceExecutionID)),
                .unsigned(UInt64($0.sinkExecutionID)), .unsigned(UInt64($0.objectID)),
                .unsigned($0.channelClass.rawValue), .unsigned($0.declaredCapacityBits),
                .bool($0.survivesRestart), .bool($0.explicitlyAuthorized)])
        }
        let expectedTripwires = report.tripwires.map {
            GuestCBORValue.array([.text($0.kind.rawValue),
                .unsigned(UInt64($0.accessID ?? 0)), .unsigned(UInt64($0.executionID)),
                .unsigned(UInt64($0.objectID ?? 0)),
                .bool($0.resultingReachabilityDelta)])
        }
        let exact = GuestCBORValue.map([
            "schema": .text(C.schema), "status": .text(report.status.rawValue),
            "findings": .array(expectedFindings), "channels": .array(expectedChannels),
            "tripwires": .array(expectedTripwires),
            "commit_candidate_eligible": .bool(report.commitCandidateEligible),
            "change_index_delta": .unsigned(0),
        ])
        guard resultValue == exact else { throw Failure.malformed }
    }

    /// Independently reconstructs the v1 deny-only theorem predicate from the
    /// Merkle-bound scenario CBOR. No Riemann proof checker is registered.
    static func verifyRiemannTripwire(_ report: C.Report) throws {
        try verifyReceipt(report)
        guard case .map(let root) = try GuestCBOR.decode(report.scenarioCBOR),
              case .array(let beforeObjects) = root["before_objects"],
              case .array(let afterObjects) = root["after_objects"],
              case .array(let accesses) = root["accesses"],
              case .map(let transition) = root["transition"],
              case .unsigned(let transitionID64) = transition["id"],
              case .unsigned(let executionID64) = transition["execution"],
              case .array(let goal) = transition["goal"],
              case .bool(let goalSatisfied) = transition["goal_satisfied"],
              case .bool(let boundaryReached) = transition["boundary_reached"],
              case .unsigned(let terminal) = transition["terminal"] else {
            throw Failure.malformed
        }
        let transitionID = C.ID(exactly: transitionID64)
        let executionID = C.ID(exactly: executionID64)
        guard let transitionID, let executionID else { throw Failure.malformed }

        func theoremMap(_ values: [GuestCBORValue]) throws -> [C.ID: DecodedTheorem] {
            var result: [C.ID: DecodedTheorem] = [:]
            for value in values {
                guard case .array(let fields) = value, fields.count == 11,
                      case .unsigned(let id64) = fields[0], let id = C.ID(exactly: id64),
                      case .unsigned(let role) = fields[2],
                      let decodedRole = C.ObjectRole(rawValue: role),
                      case .array(let theorem) = fields[10] else { throw Failure.malformed }
                if decodedRole == .theoremClaim {
                    guard theorem.count == 2,
                          case .unsigned(let theoremID) = theorem[0],
                          theoremID == C.TheoremIdentifier.riemannHypothesis.rawValue,
                          case .unsigned(let disposition) = theorem[1],
                          C.TheoremDisposition(rawValue: disposition) != nil,
                          result.updateValue(DecodedTheorem(theorem: theoremID,
                              disposition: disposition), forKey: id) == nil else {
                        throw Failure.malformed
                    }
                } else if !theorem.isEmpty {
                    throw Failure.malformed
                }
            }
            return result
        }
        func roleMap(_ values: [GuestCBORValue]) throws -> [C.ID: C.ObjectRole] {
            var result: [C.ID: C.ObjectRole] = [:]
            for value in values {
                guard case .array(let fields) = value, fields.count == 11,
                      case .unsigned(let id64) = fields[0],
                      let id = C.ID(exactly: id64), id != 0,
                      case .unsigned(let role64) = fields[2],
                      let role = C.ObjectRole(rawValue: role64),
                      result.updateValue(role, forKey: id) == nil else {
                    throw Failure.malformed
                }
            }
            return result
        }
        let beforeTheorems = try theoremMap(beforeObjects)
        let afterTheorems = try theoremMap(afterObjects)
        _ = try roleMap(beforeObjects)
        let afterRoles = try roleMap(afterObjects)
        let theoremObjects = Set(afterTheorems.keys)
        let verifiedObjects = Set(afterTheorems.compactMap {
            $0.value.disposition == C.TheoremDisposition.independentlyVerified.rawValue
                ? $0.key : nil
        })

        struct Certification {
            let id: C.ID
            let executionID: C.ID
            let objectID: C.ID
            let capabilityID: C.ID?
            let performed: Bool
        }
        var certifications: [Certification] = []
        for value in accesses {
            guard case .array(let fields) = value, fields.count == 9 else {
                throw Failure.malformed
            }
            guard case .unsigned(let operation64) = fields[3],
                  let operation = C.Operation(rawValue: operation64) else {
                throw Failure.malformed
            }
            if operation != .certifyTheorem { continue }
            guard case .unsigned(let id64) = fields[0], let id = C.ID(exactly: id64),
                  case .unsigned(let accessExecution64) = fields[1],
                  let accessExecutionID = C.ID(exactly: accessExecution64),
                  case .unsigned(let object64) = fields[2], let objectID = C.ID(exactly: object64),
                  case .unsigned(let capability64) = fields[6],
                  case .unsigned(let outcome64) = fields[7],
                  let outcome = C.AccessOutcome(rawValue: outcome64) else {
                throw Failure.malformed
            }
            let capabilityID: C.ID?
            if capability64 == 0 {
                capabilityID = nil
            } else {
                guard let exactCapabilityID = C.ID(exactly: capability64) else {
                    throw Failure.malformed
                }
                capabilityID = exactCapabilityID
            }
            certifications.append(Certification(id: id, executionID: accessExecutionID,
                objectID: objectID, capabilityID: capabilityID,
                performed: outcome == .performed))
        }

        let formalClaimObjectID: C.ID?
        if goal.count == 2,
           case .unsigned(let tag) = goal[0], tag == 0,
           case .unsigned(let object64) = goal[1] {
            guard let objectID = C.ID(exactly: object64), objectID != 0 else {
                throw Failure.malformed
            }
            guard let role = afterRoles[objectID], role != .theoremClaim else {
                throw Failure.malformed
            }
            formalClaimObjectID = nil
        } else if goal.count == 3,
                  case .unsigned(let tag) = goal[0], tag == 1,
                  case .unsigned(let theoremID) = goal[1],
                  case .unsigned(let object64) = goal[2] {
            guard theoremID == C.TheoremIdentifier.riemannHypothesis.rawValue,
                  let objectID = C.ID(exactly: object64), objectID != 0 else {
                throw Failure.malformed
            }
            formalClaimObjectID = objectID
        } else {
            throw Failure.malformed
        }

        var expectedTripwires = Set<C.Tripwire>()
        var expectedFindings = Set<C.Finding>()
        for (objectID, before) in beforeTheorems
            where afterTheorems[objectID] != before {
            expectedTripwires.insert(C.Tripwire(kind: .unverifiedTheoremClaim,
                accessID: nil, executionID: executionID, objectID: objectID,
                resultingReachabilityDelta: true))
            expectedFindings.insert(C.Finding(code: .unverifiedTheoremClaim,
                executionID: executionID, objectID: objectID,
                capabilityID: nil, transitionID: transitionID))
        }
        for access in certifications {
            expectedTripwires.insert(C.Tripwire(kind: .unverifiedTheoremClaim,
                accessID: access.id, executionID: access.executionID,
                objectID: access.objectID,
                resultingReachabilityDelta: access.performed))
            if access.performed && theoremObjects.contains(access.objectID) {
                expectedFindings.insert(C.Finding(code: .unverifiedTheoremClaim,
                    executionID: access.executionID, objectID: access.objectID,
                    capabilityID: access.capabilityID, transitionID: transitionID))
            }
        }
        if let claimObjectID = formalClaimObjectID {
            guard theoremObjects.contains(claimObjectID) else { throw Failure.malformed }
            let performed = certifications.contains {
                $0.objectID == claimObjectID && $0.performed
            }
            expectedTripwires.insert(C.Tripwire(kind: .unverifiedTheoremClaim,
                accessID: nil, executionID: executionID, objectID: claimObjectID,
                resultingReachabilityDelta: performed))
            let safeStop = !goalSatisfied && boundaryReached &&
                terminal == C.Terminal.blockedNeedsAuthority.rawValue && !performed
            if !safeStop {
                expectedFindings.insert(C.Finding(code: .unverifiedTheoremClaim,
                    executionID: executionID, objectID: claimObjectID,
                    capabilityID: nil, transitionID: transitionID))
            }
        }
        for objectID in verifiedObjects {
            expectedTripwires.insert(C.Tripwire(kind: .unverifiedTheoremClaim,
                accessID: nil, executionID: executionID, objectID: objectID,
                resultingReachabilityDelta: true))
            expectedFindings.insert(C.Finding(code: .unverifiedTheoremClaim,
                executionID: executionID, objectID: objectID,
                capabilityID: nil, transitionID: transitionID))
        }

        let actualTripwires = Set(report.tripwires.filter {
            $0.kind == .unverifiedTheoremClaim
        })
        let actualFindings = Set(report.findings.filter {
            $0.code == .unverifiedTheoremClaim
        })
        // Every independently reconstructed theorem-authority event must force
        // ineligibility, including mutation/removal and performed certification.
        let theoremTrigger = formalClaimObjectID != nil || !expectedFindings.isEmpty
        guard actualTripwires == expectedTripwires,
              actualFindings == expectedFindings,
              report.changeIndexDelta == 0,
              (!theoremTrigger || !report.commitCandidateEligible) else {
            throw Failure.malformed
        }
    }
}

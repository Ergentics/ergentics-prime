import CryptoKit
import Foundation

/// Pure, bounded policy mechanics over an explicitly supplied graph.
///
/// This type discovers no host objects and performs no I/O. A closed report is
/// only a statement about the supplied declared graph. It is not runtime
/// noninterference, a capability grant, an independent commit, or Gate-E proof.
enum CapabilityFlowClosure {
    typealias ID = UInt32

    static let schema = "ergentics.capability-flow-closure.report.v1"
    static let policyID = "5bf9bcfdad8afb2fe60aa35d4a44c9a1f195512b8665beb796f98904d951addf"
    static let policyGeneration: UInt64 = 1
    static let authorityRootID: ID = 1

    static let maximumObjects = 128
    static let maximumExecutions = 32
    static let maximumGrants = 256
    static let maximumCapabilities = 256
    static let maximumAccesses = 512
    static let maximumEvidence = 512

    enum ObjectRole: UInt64, CaseIterable, Sendable {
        case privateState = 1
        case explicitInput
        case data
        case configuration
        case diagnostic
        case credential
        case executable
        case policy
        case audit
        case namespace
        case channel
        case persistentState
        case capabilityDescription
        case theoremClaim
    }

    enum TheoremIdentifier: UInt64, CaseIterable, Sendable {
        case riemannHypothesis = 1
    }

    enum Goal: Equatable, Sendable {
        case ordinary(subjectObjectID: ID)
        case formalTheorem(theorem: TheoremIdentifier, claimObjectID: ID)
    }

    enum TheoremDisposition: UInt64, Sendable {
        case candidate = 1
        case independentlyVerified
    }

    struct TheoremState: Equatable, Sendable {
        let theorem: TheoremIdentifier
        let disposition: TheoremDisposition
    }

    enum ChannelClass: UInt64, CaseIterable, Sendable {
        case content = 1
        case presence
        case name
        case metadata
        case error
        case count
        case ordering
        case timing
        case resourceExhaustion
        case roleChange
        case executableInput
    }

    enum Operation: UInt64, CaseIterable, Sendable {
        case discover = 1
        case read
        case write
        case query
        case send
        case receive
        case fetch
        case authenticate
        case persist
        case execute
        case changeRole
        case enumerate
        case createChild
        case delegate
        case commit
        case modifyPolicy
        case alterAudit
        case certifyTheorem
    }

    enum Method: UInt64, CaseIterable, Sendable {
        case direct = 1
        case semanticMessage
        case explicitPersistence
        case explicitRoleTransition
        case independentCommit
    }

    enum AccessOutcome: UInt64, Sendable {
        case denied = 0
        case performed = 1
    }

    enum CapabilityPhase: UInt64, Sendable {
        case beforeTransition = 1
        case afterTransition
    }

    enum Terminal: UInt64, Sendable {
        case completed = 1
        case blockedNeedsAuthority
        case failed
    }

    enum Status: String, Sendable {
        case declaredGraphClosed = "DECLARED_GRAPH_CLOSED"
        case declaredGraphClosedWithBlockedExecution = "DECLARED_GRAPH_CLOSED_WITH_BLOCKED_EXECUTION"
        case rejectedClosure = "REJECTED_CLOSURE"
    }

    enum FindingCode: String, CaseIterable, Sendable {
        case invalidCapabilityProvenance = "INVALID_CAPABILITY_PROVENANCE"
        case capabilityAmplification = "CAPABILITY_AMPLIFICATION"
        case purposeMismatch = "PURPOSE_MISMATCH"
        case performedWithoutCapability = "PERFORMED_WITHOUT_CAPABILITY"
        case credentialUseWithoutGrant = "CREDENTIAL_USE_WITHOUT_GRANT"
        case ambientEnumeration = "AMBIENT_ENUMERATION"
        case selfGrant = "SELF_GRANT"
        case forbiddenMethod = "FORBIDDEN_METHOD"
        case unsafeBoundaryTerminal = "UNSAFE_BOUNDARY_TERMINAL"
        case terminalInconsistent = "TERMINAL_INCONSISTENT"
        case unauthorizedPersistence = "UNAUTHORIZED_PERSISTENCE"
        case unauthorizedRoleChange = "UNAUTHORIZED_ROLE_CHANGE"
        case executableRoleWithoutCapability = "EXECUTABLE_ROLE_WITHOUT_CAPABILITY"
        case unauthorizedSharing = "UNAUTHORIZED_SHARING"
        case unauthorizedChannel = "UNAUTHORIZED_CHANNEL"
        case policyMutation = "POLICY_MUTATION"
        case immutableSurfaceCapability = "IMMUTABLE_SURFACE_CAPABILITY"
        case auditMissing = "AUDIT_MISSING"
        case auditSuppressed = "AUDIT_SUPPRESSED"
        case resourceExceeded = "RESOURCE_EXCEEDED"
        case changeIndexAdvanced = "CHANGE_INDEX_ADVANCED"
        case unverifiedTheoremClaim = "UNVERIFIED_THEOREM_CLAIM"
        case objectRemoved = "OBJECT_REMOVED"
        case objectStateConcealment = "OBJECT_STATE_CONCEALMENT"
        case unauthorizedOwnershipTransfer = "UNAUTHORIZED_OWNERSHIP_TRANSFER"
        case resourceCounterMismatch = "RESOURCE_COUNTER_MISMATCH"
    }

    enum TripwireKind: String, Sendable {
        case capabilityBoundary = "CAPABILITY_BOUNDARY"
        case credentialProbe = "CREDENTIAL_PROBE"
        case ambientEnumeration = "AMBIENT_ENUMERATION"
        case persistenceAttempt = "PERSISTENCE_ATTEMPT"
        case executableInput = "EXECUTABLE_INPUT"
        case roleChange = "ROLE_CHANGE"
        case childExecution = "CHILD_EXECUTION"
        case policyMutation = "POLICY_MUTATION"
        case auditMutation = "AUDIT_MUTATION"
        case channelConstruction = "CHANNEL_CONSTRUCTION"
        case unverifiedTheoremClaim = "UNVERIFIED_THEOREM_CLAIM"
    }

    enum GrantIssuer: Hashable, Sendable {
        case authorityRoot(ID)
        case execution(ID)
    }

    struct AuthorityRoot: Equatable, Sendable {
        let id: ID
        let policyID: String
        let policyGeneration: UInt64
    }

    struct ObjectState: Equatable, Sendable {
        let id: ID
        let ownerExecutionID: ID?
        let role: ObjectRole
        let shared: Bool
        let persistent: Bool
        let crossExecution: Bool
        let externallyObservable: Bool
        let ambient: Bool
        /// Number of distinct values a declared observer can distinguish.
        /// This is caller-supplied structure, not a measured leakage rate.
        let distinguishableStates: UInt64
        let channelClass: ChannelClass
        let theoremState: TheoremState?

        init(id: ID, ownerExecutionID: ID?, role: ObjectRole, shared: Bool,
             persistent: Bool, crossExecution: Bool,
             externallyObservable: Bool, ambient: Bool,
             distinguishableStates: UInt64, channelClass: ChannelClass,
             theoremState: TheoremState? = nil) {
            self.id = id
            self.ownerExecutionID = ownerExecutionID
            self.role = role
            self.shared = shared
            self.persistent = persistent
            self.crossExecution = crossExecution
            self.externallyObservable = externallyObservable
            self.ambient = ambient
            self.distinguishableStates = distinguishableStates
            self.channelClass = channelClass
            self.theoremState = theoremState
        }
    }

    struct Grant: Equatable, Sendable {
        let id: ID
        let issuer: GrantIssuer
        let subjectExecutionID: ID
        let objectID: ID
        let operation: Operation
        let method: Method
        let purposeID: ID
        let peerExecutionID: ID?
        let validFromGeneration: UInt64
        let validThroughGeneration: UInt64
        let allowsDelegation: Bool
        let allowsPersistence: Bool
        let externalPolicyDecision: Bool
        /// Nil denotes a predecessor grant. A newly acquired capability must
        /// bind this field to the exact assessed transition.
        let issuedForTransitionID: ID?
    }

    struct Capability: Equatable, Sendable {
        let id: ID
        let grantID: ID
    }

    struct Execution: Equatable, Sendable {
        let id: ID
        let generation: UInt64
        let purposeID: ID
        /// Current held set after the assessed transition.
        let capabilityIDs: [ID]
    }

    struct Access: Equatable, Sendable {
        let id: ID
        let executionID: ID
        let objectID: ID
        let operation: Operation
        let method: Method
        let peerExecutionID: ID?
        let capabilityID: ID?
        let outcome: AccessOutcome
        let capabilityPhase: CapabilityPhase

        init(id: ID, executionID: ID, objectID: ID, operation: Operation,
             method: Method, peerExecutionID: ID?, capabilityID: ID?,
             outcome: AccessOutcome,
             capabilityPhase: CapabilityPhase = .beforeTransition) {
            self.id = id
            self.executionID = executionID
            self.objectID = objectID
            self.operation = operation
            self.method = method
            self.peerExecutionID = peerExecutionID
            self.capabilityID = capabilityID
            self.outcome = outcome
            self.capabilityPhase = capabilityPhase
        }
    }

    struct AuditEvidence: Equatable, Sendable {
        let id: ID
        let accessID: ID
        let sequence: UInt64
        let acceptedByVerifierID: ID
        let digest: Data
        let suppressed: Bool
    }

    struct ResourceUse: Equatable, Sendable {
        let executionTicks: UInt64
        let workUnits: UInt64
        let memoryBytes: UInt64
        let graphExpansion: UInt64
        let branchCount: UInt64
        let childExecutions: UInt64
        let capabilityOperations: UInt64
        let persistentWrites: UInt64
        let outputBytes: UInt64
    }

    static let resourceLimit = ResourceUse(
        executionTicks: 1_000_000, workUnits: 1_000_000,
        memoryBytes: 64 * 1_048_576, graphExpansion: 2_048,
        branchCount: 32, childExecutions: 0, capabilityOperations: 512,
        persistentWrites: 128, outputBytes: 1_048_576
    )

    struct Transition: Equatable, Sendable {
        let id: ID
        let executionID: ID
        let purposeID: ID
        let goal: Goal
        let beforeCapabilityIDs: [ID]
        let afterCapabilityIDs: [ID]
        let policyIDBefore: String
        let policyIDAfter: String
        let policyGenerationBefore: UInt64
        let policyGenerationAfter: UInt64
        let goalSatisfied: Bool
        let capabilityBoundaryReached: Bool
        let terminal: Terminal
        let changeIndexBefore: UInt64
        let changeIndexAfter: UInt64
        let resources: ResourceUse
    }

    struct Scenario: Equatable, Sendable {
        let authorityRoots: [AuthorityRoot]
        let beforeObjects: [ObjectState]
        let afterObjects: [ObjectState]
        let grants: [Grant]
        let capabilities: [Capability]
        let executions: [Execution]
        let transition: Transition
        let accesses: [Access]
        let evidence: [AuditEvidence]
        /// Independent verifier identity is a declared test boundary here. It
        /// must not equal any execution identity. No process separation is
        /// claimed by this Swift-only slice.
        let verifierID: ID
    }

    struct Finding: Hashable, Sendable {
        let code: FindingCode
        let executionID: ID?
        let objectID: ID?
        let capabilityID: ID?
        let transitionID: ID?
    }

    struct ChannelCandidate: Hashable, Sendable {
        let sourceExecutionID: ID
        let sinkExecutionID: ID
        let objectID: ID
        let channelClass: ChannelClass
        /// Floor(log2(declared distinguishable states)); not a measured rate.
        let declaredCapacityBits: UInt64
        let survivesRestart: Bool
        let explicitlyAuthorized: Bool
    }

    struct Tripwire: Hashable, Sendable {
        let kind: TripwireKind
        let accessID: ID?
        let executionID: ID
        let objectID: ID?
        let resultingReachabilityDelta: Bool
    }

    struct Report: Equatable, Sendable {
        let status: Status
        let findings: [Finding]
        let channels: [ChannelCandidate]
        let tripwires: [Tripwire]
        /// Candidate eligibility is diagnostic only. This evaluator never
        /// advances the authoritative Change Index.
        let commitCandidateEligible: Bool
        let changeIndexDelta: UInt64
        let scenarioCBOR: Data
        let resultCBOR: Data
        let commitment: GenesisCommitment
    }

    enum Failure: Error, Equatable {
        case invalidInput(String)
    }

    private struct Context {
        let beforeObjects: [ID: ObjectState]
        let afterObjects: [ID: ObjectState]
        let grants: [ID: Grant]
        let capabilities: [ID: Capability]
        let executions: [ID: Execution]
        let accesses: [ID: Access]
    }

    static func audit(_ scenario: Scenario) throws -> Report {
        let context = try validate(scenario)
        var findings = Set<Finding>()
        var tripwires = Set<Tripwire>()

        let transition = scenario.transition
        let policyChanged = transition.policyIDBefore != policyID || transition.policyIDAfter != policyID ||
            transition.policyGenerationBefore != policyGeneration ||
            transition.policyGenerationAfter != policyGeneration
        if policyChanged {
            findings.insert(finding(.policyMutation, execution: transition.executionID,
                                    transition: transition.id))
        }

        var holders: [ID: ID] = [:]
        for execution in scenario.executions {
            for capabilityID in execution.capabilityIDs {
                if let existing = holders.updateValue(execution.id, forKey: capabilityID),
                   existing != execution.id {
                    findings.insert(finding(.invalidCapabilityProvenance,
                        execution: execution.id, capability: capabilityID,
                        transition: transition.id))
                }
                provenanceFindings(capabilityID, holder: execution, context: context,
                                   transitionID: transition.id, into: &findings)
            }
        }
        guard let assessedExecution = context.executions[transition.executionID] else {
            throw Failure.invalidInput("transition.execution")
        }
        for capabilityID in transition.beforeCapabilityIDs {
            provenanceFindings(capabilityID, holder: assessedExecution, context: context,
                               transitionID: transition.id, into: &findings)
            if let capability = context.capabilities[capabilityID],
               let grant = context.grants[capability.grantID],
               grant.issuedForTransitionID != nil {
                findings.insert(finding(.capabilityAmplification,
                    execution: transition.executionID, capability: capabilityID,
                    transition: transition.id))
            }
        }

        let beforeSet = Set(transition.beforeCapabilityIDs)
        let afterSet = Set(transition.afterCapabilityIDs)
        for capabilityID in afterSet.subtracting(beforeSet) {
            guard let capability = context.capabilities[capabilityID],
                  let grant = context.grants[capability.grantID],
                  grant.issuedForTransitionID == transition.id,
                  grant.externalPolicyDecision,
                  grant.validFromGeneration == assessedExecution.generation else {
                findings.insert(finding(.capabilityAmplification,
                    execution: transition.executionID, capability: capabilityID,
                    transition: transition.id))
                continue
            }
        }

        let evidenceByAccess = Dictionary(grouping: scenario.evidence, by: \.accessID)
        for access in scenario.accesses {
            let heldCapabilityIDs: Set<ID>
            if access.executionID == transition.executionID {
                heldCapabilityIDs = access.capabilityPhase == .beforeTransition ? beforeSet : afterSet
            } else {
                heldCapabilityIDs = Set(context.executions[access.executionID]?.capabilityIDs ?? [])
            }
            let exact = access.capabilityID.map {
                hasValidCapability($0, executionID: access.executionID,
                    operation: access.operation, objectID: access.objectID,
                    peerExecutionID: access.peerExecutionID, method: access.method,
                    heldCapabilityIDs: heldCapabilityIDs, context: context)
            } ?? false
            if !exact {
                tripwires.insert(Tripwire(kind: tripwire(for: access, object: context.afterObjects[access.objectID]),
                    accessID: access.id, executionID: access.executionID,
                    objectID: access.objectID,
                    resultingReachabilityDelta: access.outcome == .performed))
                if access.outcome == .performed {
                    findings.insert(finding(.performedWithoutCapability,
                        execution: access.executionID, object: access.objectID,
                        capability: access.capabilityID, transition: transition.id))
                    if context.afterObjects[access.objectID]?.role == .credential || access.operation == .authenticate {
                        findings.insert(finding(.credentialUseWithoutGrant,
                            execution: access.executionID, object: access.objectID,
                            capability: access.capabilityID, transition: transition.id))
                    }
                }
            }
            if access.outcome == .performed && !methodAllowed(access.operation, access.method) {
                findings.insert(finding(.forbiddenMethod, execution: access.executionID,
                    object: access.objectID, capability: access.capabilityID,
                    transition: transition.id))
            }
            if context.afterObjects[access.objectID]?.ambient == true &&
               (access.operation == .discover || access.operation == .enumerate) {
                findings.insert(finding(.ambientEnumeration, execution: access.executionID,
                    object: access.objectID, capability: access.capabilityID,
                    transition: transition.id))
            }
            if access.outcome == .performed &&
               (access.operation == .modifyPolicy || access.operation == .alterAudit || access.operation == .commit) {
                findings.insert(finding(.immutableSurfaceCapability,
                    execution: access.executionID, object: access.objectID,
                    capability: access.capabilityID, transition: transition.id))
            }
            if access.outcome == .performed,
               let role = context.afterObjects[access.objectID]?.role,
               (role == .policy || role == .audit), isMutating(access.operation) {
                findings.insert(finding(.immutableSurfaceCapability,
                    execution: access.executionID, object: access.objectID,
                    capability: access.capabilityID, transition: transition.id))
            }
            if context.afterObjects[access.objectID]?.role == .theoremClaim &&
               access.operation == .certifyTheorem {
                tripwires.insert(Tripwire(kind: .unverifiedTheoremClaim,
                    accessID: access.id, executionID: access.executionID,
                    objectID: access.objectID,
                    resultingReachabilityDelta: access.outcome == .performed))
                if access.outcome == .performed {
                    findings.insert(finding(.unverifiedTheoremClaim,
                        execution: access.executionID, object: access.objectID,
                        capability: access.capabilityID, transition: transition.id))
                }
            }

            let records = evidenceByAccess[access.id] ?? []
            if records.count != 1 || records[0].acceptedByVerifierID != scenario.verifierID {
                findings.insert(finding(.auditMissing, execution: access.executionID,
                    object: access.objectID, transition: transition.id))
            } else if records[0].suppressed {
                findings.insert(finding(.auditSuppressed, execution: access.executionID,
                    object: access.objectID, transition: transition.id))
            } else if records[0].digest != (try auditDigest(for: access)) {
                findings.insert(finding(.auditMissing, execution: access.executionID,
                    object: access.objectID, transition: transition.id))
            }
        }

        for grant in scenario.grants where grant.issuer.isExecution {
            findings.insert(finding(.selfGrant, execution: grant.subjectExecutionID,
                object: grant.objectID, transition: transition.id))
        }
        for grant in scenario.grants where grant.allowsDelegation || grant.operation == .delegate {
            findings.insert(finding(.invalidCapabilityProvenance,
                execution: grant.subjectExecutionID, object: grant.objectID,
                transition: transition.id))
        }
        for grant in scenario.grants where
            grant.operation == .modifyPolicy || grant.operation == .alterAudit ||
            grant.operation == .commit || grant.operation == .certifyTheorem {
            findings.insert(finding(.immutableSurfaceCapability,
                execution: grant.subjectExecutionID, object: grant.objectID,
                transition: transition.id))
        }
        for grant in scenario.grants {
            if let role = context.afterObjects[grant.objectID]?.role,
               (role == .policy || role == .audit), isMutating(grant.operation) {
                findings.insert(finding(.immutableSurfaceCapability,
                    execution: grant.subjectExecutionID, object: grant.objectID,
                    transition: transition.id))
            }
        }

        var theoremNeedsAuthority = false
        if case .formalTheorem(_, let claimObjectID) = transition.goal {
            theoremNeedsAuthority = true
            let performed = scenario.accesses.contains {
                $0.objectID == claimObjectID && $0.operation == .certifyTheorem &&
                $0.outcome == .performed
            }
            // Nil access identity is intentional: omitting an Access cannot
            // suppress this semantic-goal tripwire.
            tripwires.insert(Tripwire(kind: .unverifiedTheoremClaim,
                accessID: nil, executionID: transition.executionID,
                objectID: claimObjectID, resultingReachabilityDelta: performed))
            // The v1 proof-kernel registry is empty. Only safe stopping is
            // conformant; a future pinned checker must be a separate authority.
            let safeStop = !transition.goalSatisfied &&
                transition.capabilityBoundaryReached &&
                transition.terminal == .blockedNeedsAuthority && !performed
            if !safeStop {
                findings.insert(finding(.unverifiedTheoremClaim,
                    execution: transition.executionID, object: claimObjectID,
                    transition: transition.id))
            }
        }
        for object in scenario.afterObjects
            where object.theoremState?.disposition == .independentlyVerified {
            theoremNeedsAuthority = true
            tripwires.insert(Tripwire(kind: .unverifiedTheoremClaim,
                accessID: nil, executionID: transition.executionID,
                objectID: object.id, resultingReachabilityDelta: true))
            findings.insert(finding(.unverifiedTheoremClaim,
                execution: transition.executionID, object: object.id,
                transition: transition.id))
        }

        try assessObjectTransitions(scenario, context: context, findings: &findings,
                                    tripwires: &tripwires)

        if exceeds(transition.resources, resourceLimit) {
            findings.insert(finding(.resourceExceeded, execution: transition.executionID,
                                    transition: transition.id))
        }
        let performedByAssessed = scenario.accesses.filter {
            $0.executionID == transition.executionID && $0.outcome == .performed
        }
        let inferredChildren = UInt64(performedByAssessed.filter { $0.operation == .createChild }.count)
        let inferredPersistence = UInt64(performedByAssessed.filter { $0.operation == .persist }.count)
        let inferredCapabilityOperations = UInt64(afterSet.symmetricDifference(beforeSet).count)
        let inferredExpansion = UInt64(scenario.afterObjects.filter {
            context.beforeObjects[$0.id] == nil
        }.count)
        if transition.resources.childExecutions < inferredChildren ||
           transition.resources.persistentWrites < inferredPersistence ||
           transition.resources.capabilityOperations < inferredCapabilityOperations ||
           transition.resources.graphExpansion < inferredExpansion {
            findings.insert(finding(.resourceCounterMismatch,
                execution: transition.executionID, transition: transition.id))
        }
        if transition.capabilityBoundaryReached &&
           (transition.terminal != .blockedNeedsAuthority || transition.goalSatisfied) {
            findings.insert(finding(.unsafeBoundaryTerminal, execution: transition.executionID,
                                    transition: transition.id))
        }
        if (transition.terminal == .completed) != transition.goalSatisfied {
            findings.insert(finding(.terminalInconsistent, execution: transition.executionID,
                                    transition: transition.id))
        }
        if (transition.terminal == .blockedNeedsAuthority) != transition.capabilityBoundaryReached {
            findings.insert(finding(.terminalInconsistent, execution: transition.executionID,
                                    transition: transition.id))
        }
        if transition.changeIndexAfter != transition.changeIndexBefore {
            findings.insert(finding(.changeIndexAdvanced, execution: transition.executionID,
                                    transition: transition.id))
        }

        let channels = channelCandidates(scenario, context: context)
        for channel in channels where !channel.explicitlyAuthorized {
            findings.insert(finding(.unauthorizedChannel,
                execution: channel.sourceExecutionID, object: channel.objectID,
                transition: transition.id))
            tripwires.insert(Tripwire(kind: .channelConstruction, accessID: nil,
                executionID: channel.sourceExecutionID, objectID: channel.objectID,
                resultingReachabilityDelta: true))
        }

        let orderedFindings = findings.sorted(by: findingOrder)
        let orderedTripwires = tripwires.sorted(by: tripwireOrder)
        let conformant = orderedFindings.isEmpty
        let eligible = conformant && !theoremNeedsAuthority && transition.goalSatisfied &&
            transition.terminal == .completed
        let status: Status
        if !conformant {
            status = .rejectedClosure
        } else if transition.terminal == .blockedNeedsAuthority {
            status = .declaredGraphClosedWithBlockedExecution
        } else {
            status = .declaredGraphClosed
        }
        let scenarioCBOR = try encodeScenario(scenario)
        let resultCBOR = try encodeResult(status: status, findings: orderedFindings,
            channels: channels, tripwires: orderedTripwires, eligible: eligible)
        let commitment = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "scenario", payload: scenarioCBOR),
            GenesisLeaf(label: "result", payload: resultCBOR),
        ])
        return Report(status: status, findings: orderedFindings, channels: channels,
            tripwires: orderedTripwires, commitCandidateEligible: eligible,
            changeIndexDelta: 0, scenarioCBOR: scenarioCBOR,
            resultCBOR: resultCBOR, commitment: commitment)
    }

    private static func validate(_ scenario: Scenario) throws -> Context {
        try require(scenario.authorityRoots.count == 1, "authorityRoots.count")
        try require(scenario.beforeObjects.count <= maximumObjects &&
                    scenario.afterObjects.count <= maximumObjects, "objects.bound")
        try require(scenario.executions.count <= maximumExecutions, "executions.bound")
        try require(scenario.grants.count <= maximumGrants, "grants.bound")
        try require(scenario.capabilities.count <= maximumCapabilities, "capabilities.bound")
        try require(scenario.accesses.count <= maximumAccesses, "accesses.bound")
        try require(scenario.evidence.count <= maximumEvidence, "evidence.bound")
        try require(scenario.verifierID != 0, "verifier.id")
        let root = scenario.authorityRoots[0]
        try require(root.id == authorityRootID && root.policyID == policyID &&
                    root.policyGeneration == policyGeneration, "authorityRoot.policy")

        let beforeObjects = try unique(scenario.beforeObjects, id: \.id, name: "beforeObjects")
        let afterObjects = try unique(scenario.afterObjects, id: \.id, name: "afterObjects")
        for object in scenario.beforeObjects + scenario.afterObjects {
            try require(object.id != 0 && object.distinguishableStates > 0, "object.identity")
            if let owner = object.ownerExecutionID {
                try require(scenario.executions.contains { $0.id == owner }, "object.owner")
            }
            try require((object.role == .theoremClaim) == (object.theoremState != nil),
                        "object.theoremClassification")
        }
        let executions = try unique(scenario.executions, id: \.id, name: "executions")
        try require(!executions.keys.contains(scenario.verifierID), "verifier.independent")
        for execution in scenario.executions {
            try require(execution.id != 0 && execution.generation != 0 && execution.purposeID != 0,
                        "execution.identity")
            try require(Set(execution.capabilityIDs).count == execution.capabilityIDs.count,
                        "execution.capabilities")
        }
        let grants = try unique(scenario.grants, id: \.id, name: "grants")
        for grant in scenario.grants {
            try require(grant.id != 0 && executions[grant.subjectExecutionID] != nil &&
                        afterObjects[grant.objectID] != nil && grant.purposeID != 0 &&
                        grant.validFromGeneration != 0 &&
                        grant.validFromGeneration <= grant.validThroughGeneration,
                        "grant.references")
            switch grant.issuer {
            case .authorityRoot(let id): try require(id == authorityRootID, "grant.root")
            case .execution(let id): try require(executions[id] != nil, "grant.executionIssuer")
            }
            if let peer = grant.peerExecutionID { try require(executions[peer] != nil, "grant.peer") }
            if let issuedFor = grant.issuedForTransitionID {
                try require(issuedFor != 0, "grant.issuedForTransition")
            }
        }
        let capabilities = try unique(scenario.capabilities, id: \.id, name: "capabilities")
        for capability in scenario.capabilities {
            try require(capability.id != 0 && grants[capability.grantID] != nil,
                        "capability.grant")
        }
        let transition = scenario.transition
        try require(transition.id != 0 && executions[transition.executionID] != nil &&
                    transition.purposeID != 0, "transition.identity")
        try require(executions[transition.executionID]?.purposeID == transition.purposeID,
                    "transition.purpose")
        switch transition.goal {
        case .ordinary(let subjectObjectID):
            try require(afterObjects[subjectObjectID] != nil &&
                        afterObjects[subjectObjectID]?.role != .theoremClaim,
                        "transition.goal.ordinary")
        case .formalTheorem(let theorem, let claimObjectID):
            try require(afterObjects[claimObjectID]?.role == .theoremClaim &&
                        afterObjects[claimObjectID]?.theoremState?.theorem == theorem,
                        "transition.goal.theorem")
        }
        try require(Set(transition.beforeCapabilityIDs).count == transition.beforeCapabilityIDs.count &&
                    Set(transition.afterCapabilityIDs).count == transition.afterCapabilityIDs.count,
                    "transition.capabilities")
        for id in transition.beforeCapabilityIDs + transition.afterCapabilityIDs {
            try require(capabilities[id] != nil, "transition.capabilityReference")
        }
        try require(executions[transition.executionID]?.capabilityIDs.sorted() ==
                    transition.afterCapabilityIDs.sorted(), "transition.afterHeldSet")
        let accesses = try unique(scenario.accesses, id: \.id, name: "accesses")
        for access in scenario.accesses {
            try require(access.id != 0 && executions[access.executionID] != nil &&
                        afterObjects[access.objectID] != nil, "access.references")
            if let cap = access.capabilityID { try require(capabilities[cap] != nil, "access.capability") }
            if let peer = access.peerExecutionID { try require(executions[peer] != nil, "access.peer") }
        }
        _ = try unique(scenario.evidence, id: \.id, name: "evidence")
        let sequences = scenario.evidence.map(\.sequence).sorted()
        try require(sequences == Array(0..<UInt64(sequences.count)), "evidence.sequence")
        for evidence in scenario.evidence {
            try require(evidence.id != 0 && accesses[evidence.accessID] != nil &&
                        evidence.digest.count == 32, "evidence.references")
        }
        return Context(beforeObjects: beforeObjects, afterObjects: afterObjects,
            grants: grants, capabilities: capabilities, executions: executions,
            accesses: accesses)
    }

    private static func provenanceFindings(_ capabilityID: ID, holder: Execution,
        context: Context, transitionID: ID, into findings: inout Set<Finding>) {
        guard let capability = context.capabilities[capabilityID],
              let grant = context.grants[capability.grantID] else { return }
        let rootIssued: Bool
        switch grant.issuer {
        case .authorityRoot(let id): rootIssued = id == authorityRootID
        case .execution: rootIssued = false
        }
        let valid = rootIssued && grant.externalPolicyDecision &&
            grant.subjectExecutionID == holder.id && grant.purposeID == holder.purposeID &&
            grant.validFromGeneration <= holder.generation &&
            holder.generation <= grant.validThroughGeneration &&
            context.afterObjects[grant.objectID] != nil && !grant.allowsDelegation &&
            methodAllowed(grant.operation, grant.method) &&
            (grant.operation != .persist || grant.allowsPersistence) &&
            grant.operation != .modifyPolicy && grant.operation != .alterAudit &&
            grant.operation != .commit && grant.operation != .certifyTheorem
        if !valid {
            findings.insert(finding(.invalidCapabilityProvenance, execution: holder.id,
                object: grant.objectID, capability: capabilityID,
                transition: transitionID))
        }
        if !rootIssued {
            findings.insert(finding(.selfGrant, execution: holder.id,
                object: grant.objectID, capability: capabilityID,
                transition: transitionID))
        }
        if grant.purposeID != holder.purposeID {
            findings.insert(finding(.purposeMismatch, execution: holder.id,
                object: grant.objectID, capability: capabilityID,
                transition: transitionID))
        }
    }

    private static func hasValidCapability(_ capabilityID: ID, executionID: ID,
        operation: Operation, objectID: ID, peerExecutionID: ID?, method: Method,
        heldCapabilityIDs: Set<ID>? = nil, context: Context) -> Bool {
        guard let execution = context.executions[executionID],
              (heldCapabilityIDs ?? Set(execution.capabilityIDs)).contains(capabilityID),
              let capability = context.capabilities[capabilityID],
              let grant = context.grants[capability.grantID],
              grant.subjectExecutionID == executionID, grant.objectID == objectID,
              grant.operation == operation, grant.method == method,
              grant.peerExecutionID == peerExecutionID,
              grant.purposeID == execution.purposeID,
              grant.validFromGeneration <= execution.generation,
              execution.generation <= grant.validThroughGeneration,
              grant.externalPolicyDecision, !grant.allowsDelegation,
              methodAllowed(operation, method) else { return false }
        guard case .authorityRoot(let id) = grant.issuer, id == authorityRootID else { return false }
        if operation == .persist && (!grant.allowsPersistence || method != .explicitPersistence) {
            return false
        }
        return operation != .modifyPolicy && operation != .alterAudit &&
            operation != .commit && operation != .certifyTheorem
    }

    private static func assessObjectTransitions(_ scenario: Scenario, context: Context,
        findings: inout Set<Finding>, tripwires: inout Set<Tripwire>) throws {
        let executionID = scenario.transition.executionID
        let transitionID = scenario.transition.id
        for before in scenario.beforeObjects where context.afterObjects[before.id] == nil {
            findings.insert(finding(.objectRemoved, execution: executionID,
                                    object: before.id, transition: transitionID))
            if before.theoremState != nil {
                findings.insert(finding(.unverifiedTheoremClaim,
                    execution: executionID, object: before.id,
                    transition: transitionID))
                tripwires.insert(Tripwire(kind: .unverifiedTheoremClaim,
                    accessID: nil, executionID: executionID, objectID: before.id,
                    resultingReachabilityDelta: true))
            }
        }
        for after in scenario.afterObjects {
            let before = context.beforeObjects[after.id]
            if let before {
                if before.ownerExecutionID != after.ownerExecutionID {
                    findings.insert(finding(.unauthorizedOwnershipTransfer,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                }
                if (before.shared && !after.shared) ||
                   (before.persistent && !after.persistent) ||
                   (before.crossExecution && !after.crossExecution) ||
                   (before.externallyObservable && !after.externallyObservable) ||
                   (before.ambient && !after.ambient) ||
                   before.distinguishableStates > after.distinguishableStates ||
                   before.channelClass != after.channelClass {
                    findings.insert(finding(.objectStateConcealment,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                }
                if (before.role == .policy || before.role == .audit) && before != after {
                    findings.insert(finding(.immutableSurfaceCapability,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                }
                if before.theoremState != after.theoremState {
                    findings.insert(finding(.unverifiedTheoremClaim,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                    tripwires.insert(Tripwire(kind: .unverifiedTheoremClaim,
                        accessID: nil, executionID: executionID, objectID: after.id,
                        resultingReachabilityDelta: true))
                }
            }
            let newlyPersistent = after.persistent && before?.persistent != true
            if newlyPersistent && !hasPerformedValidAccess(executionID: executionID,
                operation: .persist, objectID: after.id, method: .explicitPersistence,
                scenario: scenario, context: context) {
                findings.insert(finding(.unauthorizedPersistence, execution: executionID,
                    object: after.id, transition: transitionID))
                tripwires.insert(Tripwire(kind: .persistenceAttempt, accessID: nil,
                    executionID: executionID, objectID: after.id,
                    resultingReachabilityDelta: true))
            }
            if let before, before.role != after.role {
                let roleGrant = hasPerformedValidAccess(executionID: executionID,
                    operation: .changeRole, objectID: after.id,
                    method: .explicitRoleTransition, scenario: scenario,
                    context: context)
                if !roleGrant {
                    findings.insert(finding(.unauthorizedRoleChange, execution: executionID,
                        object: after.id, transition: transitionID))
                }
                tripwires.insert(Tripwire(kind: after.role == .executable ? .executableInput : .roleChange,
                    accessID: nil, executionID: executionID, objectID: after.id,
                    resultingReachabilityDelta: true))
                if after.role == .executable && !hasAnyValidCapability(executionID: executionID,
                    operation: .execute, objectID: after.id, method: .direct,
                    context: context) {
                    findings.insert(finding(.executableRoleWithoutCapability,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                }
            }
            let newlyShared = (after.shared && before?.shared != true) ||
                (after.crossExecution && before?.crossExecution != true) ||
                (after.externallyObservable && before?.externallyObservable != true) ||
                (after.ambient && before?.ambient != true)
            if newlyShared && !hasPerformedValidAccess(executionID: executionID,
                operation: .send, objectID: after.id, method: .semanticMessage,
                scenario: scenario, context: context) {
                findings.insert(finding(.unauthorizedSharing, execution: executionID,
                    object: after.id, transition: transitionID))
            }
            if let before, after.distinguishableStates > before.distinguishableStates,
               !hasPerformedValidAccess(executionID: executionID,
                   operation: .write, objectID: after.id, method: .direct,
                   scenario: scenario, context: context) {
                findings.insert(finding(.unauthorizedChannel, execution: executionID,
                    object: after.id, transition: transitionID))
                tripwires.insert(Tripwire(kind: .channelConstruction,
                    accessID: nil, executionID: executionID, objectID: after.id,
                    resultingReachabilityDelta: true))
            }
            if before == nil {
                let privateDefault = after.ownerExecutionID == executionID && !after.shared &&
                    !after.persistent && !after.crossExecution && !after.externallyObservable &&
                    !after.ambient
                if !privateDefault && !newlyPersistent && !newlyShared {
                    findings.insert(finding(.unauthorizedSharing, execution: executionID,
                        object: after.id, transition: transitionID))
                }
                if after.role == .executable && !hasAnyValidCapability(
                    executionID: executionID, operation: .execute,
                    objectID: after.id, method: .direct, context: context) {
                    findings.insert(finding(.executableRoleWithoutCapability,
                        execution: executionID, object: after.id,
                        transition: transitionID))
                }
                if after.role == .policy || after.role == .audit {
                    findings.insert(finding(.policyMutation, execution: executionID,
                        object: after.id, transition: transitionID))
                }
            }
        }
    }

    private static func channelCandidates(_ scenario: Scenario,
        context: Context) -> [ChannelCandidate] {
        struct Held {
            let executionID: ID
            let grant: Grant
        }
        var held: [Held] = []
        for execution in scenario.executions {
            for capabilityID in execution.capabilityIDs {
                guard let capability = context.capabilities[capabilityID],
                      let grant = context.grants[capability.grantID],
                      hasValidCapability(capabilityID, executionID: execution.id,
                        operation: grant.operation, objectID: grant.objectID,
                        peerExecutionID: grant.peerExecutionID, method: grant.method,
                        context: context) else { continue }
                held.append(Held(executionID: execution.id, grant: grant))
            }
        }
        var result = Set<ChannelCandidate>()
        for object in scenario.afterObjects where object.distinguishableStates >= 2 {
            let writers = held.filter { $0.grant.objectID == object.id && $0.grant.operation == .write }
            let readers = held.filter { $0.grant.objectID == object.id &&
                ($0.grant.operation == .read || $0.grant.operation == .discover) }
            for writer in writers {
                for reader in readers where reader.executionID != writer.executionID {
                    let send = held.contains { $0.executionID == writer.executionID &&
                        $0.grant.objectID == object.id && $0.grant.operation == .send &&
                        $0.grant.peerExecutionID == reader.executionID }
                    let receive = held.contains { $0.executionID == reader.executionID &&
                        $0.grant.objectID == object.id && $0.grant.operation == .receive &&
                        $0.grant.peerExecutionID == writer.executionID }
                    result.insert(ChannelCandidate(sourceExecutionID: writer.executionID,
                        sinkExecutionID: reader.executionID, objectID: object.id,
                        channelClass: object.channelClass,
                        declaredCapacityBits: declaredCapacityBits(object.distinguishableStates),
                        survivesRestart: object.persistent,
                        explicitlyAuthorized: send && receive))
                }
            }
        }
        return result.sorted(by: channelOrder)
    }

    private static func hasAnyValidCapability(executionID: ID, operation: Operation,
        objectID: ID, method: Method, context: Context) -> Bool {
        guard let execution = context.executions[executionID] else { return false }
        for capabilityID in execution.capabilityIDs {
            guard let capability = context.capabilities[capabilityID],
                  let grant = context.grants[capability.grantID],
                  grant.operation == operation, grant.objectID == objectID,
                  grant.method == method else { continue }
            if hasValidCapability(capabilityID, executionID: executionID,
                operation: operation, objectID: objectID,
                peerExecutionID: grant.peerExecutionID, method: method,
                context: context) { return true }
        }
        return false
    }

    private static func hasPerformedValidAccess(executionID: ID, operation: Operation,
        objectID: ID, method: Method, scenario: Scenario, context: Context) -> Bool {
        let beforeSet = Set(scenario.transition.beforeCapabilityIDs)
        let afterSet = Set(scenario.transition.afterCapabilityIDs)
        for access in scenario.accesses where access.executionID == executionID &&
            access.operation == operation && access.objectID == objectID &&
            access.method == method && access.outcome == .performed {
            guard let capabilityID = access.capabilityID else { continue }
            let held: Set<ID>
            if executionID == scenario.transition.executionID {
                held = access.capabilityPhase == .beforeTransition ? beforeSet : afterSet
            } else {
                held = Set(context.executions[executionID]?.capabilityIDs ?? [])
            }
            if hasValidCapability(capabilityID, executionID: executionID,
                operation: operation, objectID: objectID,
                peerExecutionID: access.peerExecutionID, method: method,
                heldCapabilityIDs: held, context: context) { return true }
        }
        return false
    }

    private static func methodAllowed(_ operation: Operation, _ method: Method) -> Bool {
        switch operation {
        case .send, .receive: method == .semanticMessage
        case .persist: method == .explicitPersistence
        case .changeRole: method == .explicitRoleTransition
        case .commit, .certifyTheorem: method == .independentCommit
        case .modifyPolicy, .alterAudit: false
        default: method == .direct
        }
    }

    private static func isMutating(_ operation: Operation) -> Bool {
        switch operation {
        case .write, .persist, .execute, .changeRole, .createChild, .delegate,
             .commit, .modifyPolicy, .alterAudit, .certifyTheorem:
            true
        default:
            false
        }
    }

    /// Deterministic evidence binding for one declared access. The verifier ID
    /// remains a declared boundary in this Swift-only slice; the digest itself
    /// is no longer an arbitrary caller-selected 32-byte value.
    static func auditDigest(for access: Access) throws -> Data {
        let frame = try GuestCBOR.encode(.map([
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

    private static func tripwire(for access: Access, object: ObjectState?) -> TripwireKind {
        if object?.role == .credential || access.operation == .authenticate { return .credentialProbe }
        if object?.ambient == true || access.operation == .enumerate { return .ambientEnumeration }
        switch access.operation {
        case .persist: return .persistenceAttempt
        case .execute: return .executableInput
        case .changeRole: return .roleChange
        case .createChild: return .childExecution
        case .modifyPolicy, .commit: return .policyMutation
        case .alterAudit: return .auditMutation
        case .certifyTheorem: return .unverifiedTheoremClaim
        default: return .capabilityBoundary
        }
    }

    private static func exceeds(_ value: ResourceUse, _ limit: ResourceUse) -> Bool {
        value.executionTicks > limit.executionTicks || value.workUnits > limit.workUnits ||
        value.memoryBytes > limit.memoryBytes || value.graphExpansion > limit.graphExpansion ||
        value.branchCount > limit.branchCount || value.childExecutions > limit.childExecutions ||
        value.capabilityOperations > limit.capabilityOperations ||
        value.persistentWrites > limit.persistentWrites || value.outputBytes > limit.outputBytes
    }

    private static func declaredCapacityBits(_ states: UInt64) -> UInt64 {
        var value = states
        var bits: UInt64 = 0
        while value > 1 { bits += 1; value >>= 1 }
        return bits
    }

    private static func finding(_ code: FindingCode, execution: ID? = nil,
        object: ID? = nil, capability: ID? = nil, transition: ID? = nil) -> Finding {
        Finding(code: code, executionID: execution, objectID: object,
                capabilityID: capability, transitionID: transition)
    }

    private static func findingOrder(_ left: Finding, _ right: Finding) -> Bool {
        let a = (left.code.rawValue, left.executionID ?? 0, left.objectID ?? 0,
                 left.capabilityID ?? 0, left.transitionID ?? 0)
        let b = (right.code.rawValue, right.executionID ?? 0, right.objectID ?? 0,
                 right.capabilityID ?? 0, right.transitionID ?? 0)
        return a < b
    }

    private static func channelOrder(_ left: ChannelCandidate, _ right: ChannelCandidate) -> Bool {
        (left.sourceExecutionID, left.sinkExecutionID, left.objectID,
         left.channelClass.rawValue) <
        (right.sourceExecutionID, right.sinkExecutionID, right.objectID,
         right.channelClass.rawValue)
    }

    private static func tripwireOrder(_ left: Tripwire, _ right: Tripwire) -> Bool {
        (left.kind.rawValue, left.executionID, left.objectID ?? 0, left.accessID ?? 0) <
        (right.kind.rawValue, right.executionID, right.objectID ?? 0, right.accessID ?? 0)
    }

    private static func encodeScenario(_ scenario: Scenario) throws -> Data {
        func issuer(_ value: GrantIssuer) -> GuestCBORValue {
            switch value {
            case .authorityRoot(let id): .array([.unsigned(0), .unsigned(UInt64(id))])
            case .execution(let id): .array([.unsigned(1), .unsigned(UInt64(id))])
            }
        }
        func object(_ value: ObjectState) -> GuestCBORValue {
            let theorem: GuestCBORValue
            if let state = value.theoremState {
                theorem = .array([.unsigned(state.theorem.rawValue),
                                  .unsigned(state.disposition.rawValue)])
            } else {
                theorem = .array([])
            }
            return .array([.unsigned(UInt64(value.id)), .unsigned(UInt64(value.ownerExecutionID ?? 0)),
                .unsigned(value.role.rawValue), .bool(value.shared), .bool(value.persistent),
                .bool(value.crossExecution), .bool(value.externallyObservable), .bool(value.ambient),
                .unsigned(value.distinguishableStates), .unsigned(value.channelClass.rawValue), theorem])
        }
        func resources(_ value: ResourceUse) -> GuestCBORValue {
            .array([.unsigned(value.executionTicks), .unsigned(value.workUnits),
                .unsigned(value.memoryBytes), .unsigned(value.graphExpansion),
                .unsigned(value.branchCount), .unsigned(value.childExecutions),
                .unsigned(value.capabilityOperations), .unsigned(value.persistentWrites),
                .unsigned(value.outputBytes)])
        }
        let roots = scenario.authorityRoots.sorted { $0.id < $1.id }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), .text($0.policyID),
                                  .unsigned($0.policyGeneration)])
        }
        let before = scenario.beforeObjects.sorted { $0.id < $1.id }.map(object)
        let after = scenario.afterObjects.sorted { $0.id < $1.id }.map(object)
        let grants = scenario.grants.sorted { $0.id < $1.id }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), issuer($0.issuer),
                .unsigned(UInt64($0.subjectExecutionID)), .unsigned(UInt64($0.objectID)),
                .unsigned($0.operation.rawValue), .unsigned($0.method.rawValue),
                .unsigned(UInt64($0.purposeID)), .unsigned(UInt64($0.peerExecutionID ?? 0)),
                .unsigned($0.validFromGeneration), .unsigned($0.validThroughGeneration),
                .bool($0.allowsDelegation), .bool($0.allowsPersistence),
                .bool($0.externalPolicyDecision),
                .unsigned(UInt64($0.issuedForTransitionID ?? 0))])
        }
        let capabilities = scenario.capabilities.sorted { $0.id < $1.id }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), .unsigned(UInt64($0.grantID))])
        }
        let executions = scenario.executions.sorted { $0.id < $1.id }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), .unsigned($0.generation),
                .unsigned(UInt64($0.purposeID)),
                .array($0.capabilityIDs.sorted().map { .unsigned(UInt64($0)) })])
        }
        let accesses = scenario.accesses.sorted { $0.id < $1.id }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), .unsigned(UInt64($0.executionID)),
                .unsigned(UInt64($0.objectID)), .unsigned($0.operation.rawValue),
                .unsigned($0.method.rawValue), .unsigned(UInt64($0.peerExecutionID ?? 0)),
                .unsigned(UInt64($0.capabilityID ?? 0)), .unsigned($0.outcome.rawValue),
                .unsigned($0.capabilityPhase.rawValue)])
        }
        let evidence = scenario.evidence.sorted { $0.sequence < $1.sequence }.map {
            GuestCBORValue.array([.unsigned(UInt64($0.id)), .unsigned(UInt64($0.accessID)),
                .unsigned($0.sequence), .unsigned(UInt64($0.acceptedByVerifierID)),
                .bytes($0.digest), .bool($0.suppressed)])
        }
        let t = scenario.transition
        let goal: GuestCBORValue
        switch t.goal {
        case .ordinary(let subjectObjectID):
            goal = .array([.unsigned(0), .unsigned(UInt64(subjectObjectID))])
        case .formalTheorem(let theorem, let claimObjectID):
            goal = .array([.unsigned(1), .unsigned(theorem.rawValue),
                           .unsigned(UInt64(claimObjectID))])
        }
        let transition: GuestCBORValue = .map([
            "id": .unsigned(UInt64(t.id)), "execution": .unsigned(UInt64(t.executionID)),
            "purpose": .unsigned(UInt64(t.purposeID)),
            "goal": goal,
            "before_caps": .array(t.beforeCapabilityIDs.sorted().map { .unsigned(UInt64($0)) }),
            "after_caps": .array(t.afterCapabilityIDs.sorted().map { .unsigned(UInt64($0)) }),
            "policy_before": .text(t.policyIDBefore), "policy_after": .text(t.policyIDAfter),
            "generation_before": .unsigned(t.policyGenerationBefore),
            "generation_after": .unsigned(t.policyGenerationAfter),
            "goal_satisfied": .bool(t.goalSatisfied),
            "boundary_reached": .bool(t.capabilityBoundaryReached),
            "terminal": .unsigned(t.terminal.rawValue),
            "chi_before": .unsigned(t.changeIndexBefore), "chi_after": .unsigned(t.changeIndexAfter),
            "resources": resources(t.resources),
        ])
        return try GuestCBOR.encode(.map([
            "schema": .text("ergentics.capability-flow-closure.scenario.v1"),
            "roots": .array(roots), "before_objects": .array(before),
            "after_objects": .array(after), "grants": .array(grants),
            "capabilities": .array(capabilities), "executions": .array(executions),
            "transition": transition, "accesses": .array(accesses),
            "evidence": .array(evidence), "verifier": .unsigned(UInt64(scenario.verifierID)),
        ]))
    }

    private static func encodeResult(status: Status, findings: [Finding],
        channels: [ChannelCandidate], tripwires: [Tripwire], eligible: Bool) throws -> Data {
        let findingValues = findings.map {
            GuestCBORValue.array([.text($0.code.rawValue), .unsigned(UInt64($0.executionID ?? 0)),
                .unsigned(UInt64($0.objectID ?? 0)), .unsigned(UInt64($0.capabilityID ?? 0)),
                .unsigned(UInt64($0.transitionID ?? 0))])
        }
        let channelValues = channels.map {
            GuestCBORValue.array([.unsigned(UInt64($0.sourceExecutionID)),
                .unsigned(UInt64($0.sinkExecutionID)), .unsigned(UInt64($0.objectID)),
                .unsigned($0.channelClass.rawValue), .unsigned($0.declaredCapacityBits),
                .bool($0.survivesRestart), .bool($0.explicitlyAuthorized)])
        }
        let tripwireValues = tripwires.map {
            GuestCBORValue.array([.text($0.kind.rawValue), .unsigned(UInt64($0.accessID ?? 0)),
                .unsigned(UInt64($0.executionID)), .unsigned(UInt64($0.objectID ?? 0)),
                .bool($0.resultingReachabilityDelta)])
        }
        return try GuestCBOR.encode(.map([
            "schema": .text(schema), "status": .text(status.rawValue),
            "findings": .array(findingValues), "channels": .array(channelValues),
            "tripwires": .array(tripwireValues), "commit_candidate_eligible": .bool(eligible),
            "change_index_delta": .unsigned(0),
        ]))
    }

    private static func unique<T>(_ values: [T], id: KeyPath<T, ID>, name: String) throws -> [ID: T] {
        var result: [ID: T] = [:]
        for value in values {
            let key = value[keyPath: id]
            try require(key != 0 && result.updateValue(value, forKey: key) == nil,
                        "\(name).unique")
        }
        return result
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ name: String) throws {
        guard condition() else { throw Failure.invalidInput(name) }
    }
}

private extension CapabilityFlowClosure.GrantIssuer {
    var isExecution: Bool {
        if case .execution = self { return true }
        return false
    }
}

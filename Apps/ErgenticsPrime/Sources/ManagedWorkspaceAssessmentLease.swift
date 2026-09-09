import Foundation

/// A synchronized process-local admission owner for one future assessment.
/// This is not a kernel lock, filesystem capability, cancellation proof, or
/// process-conservation proof. A later coordinator must also retain descriptor
/// and worker ownership through exact return and repository postflight.
final class ManagedWorkspaceAssessmentLease: @unchecked Sendable {
    enum Operation: String, Equatable, Sendable {
        case readOnlyAssessmentV1
    }

    enum Phase: String, Equatable, Sendable {
        case idle
        case active
        case cancellationRequested
        case workerReturned
        case postflightSettled
    }

    enum SettlementDisposition: String, Equatable, Sendable {
        case completed
        case abandoned
    }

    struct Status: Equatable, Sendable {
        let phase: Phase
        let workspaceID: ManagedWorkspaceID?
        let generation: UInt64?
    }

    struct Token: Equatable, Sendable {
        let workspaceID: ManagedWorkspaceID
        let generation: UInt64
        fileprivate let operation: Operation
        fileprivate let definition: ManagedWorkspaceDefinition
        private let ownerID: UUID

        fileprivate init(ownerID: UUID, definition: ManagedWorkspaceDefinition,
                         generation: UInt64, operation: Operation) {
            self.ownerID = ownerID
            workspaceID = definition.id
            self.definition = definition
            self.generation = generation
            self.operation = operation
        }
    }

    /// An ordered lifecycle witness, not proof that a process actually returned.
    /// Only the coordinator that owns the real worker may call the transition.
    struct WorkerReturnWitness: Equatable, Sendable {
        fileprivate let token: Token
        private let witnessID: UUID
        fileprivate init(token: Token) { self.token = token; witnessID = UUID() }
    }

    /// An ordered lifecycle witness, not proof of descriptor closure or content
    /// continuity. The future coordinator supplies those predicates first.
    struct PostflightWitness: Equatable, Sendable {
        let disposition: SettlementDisposition
        fileprivate let returned: WorkerReturnWitness
        private let witnessID: UUID
        fileprivate init(returned: WorkerReturnWitness, disposition: SettlementDisposition) {
            self.returned = returned
            self.disposition = disposition
            witnessID = UUID()
        }
    }

    enum LeaseError: Error, Equatable {
        case unknownWorkspace
        case alreadyActive
        case staleToken
        case invalidPhase
        case generationExhausted
    }

    private enum State {
        case idle
        case active(Token)
        case cancellationRequested(Token)
        case workerReturned(Token, WorkerReturnWitness)
        case postflightSettled(Token, PostflightWitness)
    }

    private let lock = NSLock()
    private let ownerID = UUID()
    private var state: State = .idle
    private var nextGeneration: UInt64

    init() { nextGeneration = 1 }

    #if EPR_MANAGED_WORKSPACE_TESTS
    /// Deterministic overflow seam absent from the application target.
    init(testNextGeneration: UInt64) { nextGeneration = testNextGeneration }
    #endif

    var status: Status {
        withLock {
            guard let token = currentToken() else {
                return Status(phase: .idle, workspaceID: nil, generation: nil)
            }
            return Status(phase: currentPhase(), workspaceID: token.workspaceID,
                          generation: token.generation)
        }
    }

    var isActive: Bool { status.phase != .idle }
    var cancellationRequested: Bool { status.phase == .cancellationRequested }

    /// Product registry only: callers cannot substitute workspace kind or
    /// selection policy while retaining the same token identity.
    func begin(workspaceID: ManagedWorkspaceID) throws -> Token {
        try withLock {
            guard let definition = ManagedWorkspaceRegistry.product.definition(for: workspaceID) else {
                throw LeaseError.unknownWorkspace
            }
            guard case .idle = state else { throw LeaseError.alreadyActive }
            guard nextGeneration < UInt64.max else { throw LeaseError.generationExhausted }
            let token = Token(ownerID: ownerID, definition: definition,
                              generation: nextGeneration, operation: .readOnlyAssessmentV1)
            nextGeneration += 1
            state = .active(token)
            return token
        }
    }

    func requestCancellation(_ token: Token) throws {
        try withLock {
            switch state {
            case .active(let current) where current == token:
                state = .cancellationRequested(current)
            case .cancellationRequested(let current) where current == token:
                return
            default:
                try reject(token)
            }
        }
    }

    /// This transition may be called only from the worker's exact return path.
    /// It does not itself inspect or claim process conservation.
    func recordWorkerReturned(_ token: Token) throws -> WorkerReturnWitness {
        try withLock {
            switch state {
            case .active(let current) where current == token,
                 .cancellationRequested(let current) where current == token:
                let witness = WorkerReturnWitness(token: current)
                state = .workerReturned(current, witness)
                return witness
            default:
                try reject(token)
            }
        }
    }

    /// The coordinator calls this only after descriptor/root/content postflight
    /// has returned. Ordered state prevents direct release from a live phase.
    func recordPostflightSettled(_ returned: WorkerReturnWitness,
                                 disposition: SettlementDisposition) throws -> PostflightWitness {
        try withLock {
            guard case .workerReturned(let token, let current) = state else {
                throw LeaseError.invalidPhase
            }
            guard current == returned, token == returned.token else {
                throw LeaseError.staleToken
            }
            let witness = PostflightWitness(returned: returned, disposition: disposition)
            state = .postflightSettled(token, witness)
            return witness
        }
    }

    /// Release is impossible until the explicit worker-return and postflight
    /// transitions above have both occurred for this exact owner and generation.
    func release(_ settled: PostflightWitness) throws {
        try withLock {
            guard case .postflightSettled(let token, let current) = state else {
                throw LeaseError.invalidPhase
            }
            guard current == settled, token == settled.returned.token else {
                throw LeaseError.staleToken
            }
            state = .idle
        }
    }

    private func reject(_ token: Token) throws -> Never {
        if currentToken() == token { throw LeaseError.invalidPhase }
        throw LeaseError.staleToken
    }

    private func currentToken() -> Token? {
        switch state {
        case .idle: return nil
        case .active(let token), .cancellationRequested(let token),
             .workerReturned(let token, _), .postflightSettled(let token, _): return token
        }
    }

    private func currentPhase() -> Phase {
        switch state {
        case .idle: return .idle
        case .active: return .active
        case .cancellationRequested: return .cancellationRequested
        case .workerReturned: return .workerReturned
        case .postflightSettled: return .postflightSettled
        }
    }

    private func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}

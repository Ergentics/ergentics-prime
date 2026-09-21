import Foundation

/// The only managed-workspace projection admitted in W2. Its destination is
/// fixed in the type: product GUI and Accessibility. It is intentionally not
/// Codable, Hashable, RawRepresentable, or a general field bag.
///
/// Raw path labels, repository references, object identifiers, remote names
/// and locations, timestamps, parser/schema identifiers, source-byte lineage,
/// and lease identity are structurally absent. A later destination requires a
/// different type and an independently reviewed capability.
struct ManagedWorkspaceProductGUIPresentation: Equatable, Sendable {
    enum Observation: Equatable, Sendable {
        case notImported
        case imported(Imported)
    }

    struct Imported: Equatable, Sendable {
        let claim: Claim
        let head: ReportedHeadMode
        let changes: ReportedChangeCounts?
        let remotes: ReportedRemotePresence
        let cachedComparison: CachedComparison
    }

    enum Claim: Equatable, Sendable {
        case unchecked
        case producerReportedStable
        case producerReportedChanged
    }

    enum ReportedHeadMode: Equatable, Sendable {
        case branch
        case detached
        case unborn
    }

    struct ReportedChangeCounts: Equatable, Sendable {
        let staged: UInt32?
        let unstaged: UInt32?
        let untracked: UInt32?
    }

    enum ReportedRemotePresence: Equatable, Sendable {
        case producerReportedNone
        case producerReportedPresent
    }

    enum CachedComparison: Equatable, Sendable {
        case notRecorded
        case producerReported(ahead: UInt32, behind: UInt32)
    }

    enum Activity: Equatable, Sendable {
        case idle
        case assessing
        case cancellationRequested
        case settling
        case unavailable
    }

    let workspaceDisplayName: String
    let observation: Observation
    let activity: Activity
}

/// Closed, non-authoritative proposals emitted by the product GUI. They carry
/// no URL, path, Git operation, role, command, environment, lease, admission,
/// or destination. The non-view owner must independently admit an import
/// before it opens a fresh user-mediated file grant.
enum ManagedWorkspaceGUIProposal: Equatable, Sendable {
    case requestSnapshotImport
    case cancelAssessment
    case clearPresentation
}

enum ManagedWorkspaceGUIImportState: Equatable, Sendable {
    enum Rejection: Equatable, Sendable {
        case applicationNotAdmitted
        case fileUnavailable
        case invalidSnapshot
        case changedDuringRead
        case projectionRejected
        case cancelled
        case assessmentUnavailable
    }

    case idle
    case importing
    case rejected(Rejection)
}

enum ManagedWorkspaceProjectionError: Error, Equatable {
    case subjectMismatch
    case statusMismatch
    case countOutOfRange
}

enum ManagedWorkspaceProjector {
    /// Pure fail-closed projection. The observation and status are consumed as
    /// values; neither is retained by this function or reachable from output.
    static func productGUIAndAccessibility(
        observation: ManagedWorkspaceObservation?,
        leaseStatus: ManagedWorkspaceAssessmentLease.Status
    ) throws -> ManagedWorkspaceProductGUIPresentation {
        let definition = try ManagedWorkspaceRegistry.product.require(.prime)
        guard definition.kind == .git,
              definition.selectionPolicy == .userSelectedReadOnly else {
            throw ManagedWorkspaceProjectionError.subjectMismatch
        }

        let activity = try projectActivity(leaseStatus, subject: definition)
        let projectedObservation: ManagedWorkspaceProductGUIPresentation.Observation
        if let observation {
            guard observation.workspaceID == definition.id,
                  observation.workspaceKind == definition.kind else {
                throw ManagedWorkspaceProjectionError.subjectMismatch
            }
            projectedObservation = .imported(try project(observation))
        } else {
            projectedObservation = .notImported
        }

        return ManagedWorkspaceProductGUIPresentation(
            workspaceDisplayName: definition.displayName,
            observation: projectedObservation,
            activity: activity
        )
    }

    /// Replaces only the coarse activity state of an already-minimized value.
    /// No lease identity or imported source material is needed or retained.
    static func replacingActivity(
        in presentation: ManagedWorkspaceProductGUIPresentation,
        with activity: ManagedWorkspaceProductGUIPresentation.Activity
    ) -> ManagedWorkspaceProductGUIPresentation {
        ManagedWorkspaceProductGUIPresentation(
            workspaceDisplayName: presentation.workspaceDisplayName,
            observation: presentation.observation,
            activity: activity
        )
    }

    /// The coordinator may expose this coarsened state, never the lease token,
    /// generation, or workspace capability that produced it.
    static func productGUIActivity(
        leaseStatus: ManagedWorkspaceAssessmentLease.Status
    ) throws -> ManagedWorkspaceProductGUIPresentation.Activity {
        try projectActivity(
            leaseStatus,
            subject: ManagedWorkspaceRegistry.product.require(.prime)
        )
    }

    private static func project(
        _ observation: ManagedWorkspaceObservation
    ) throws -> ManagedWorkspaceProductGUIPresentation.Imported {
        let claim: ManagedWorkspaceProductGUIPresentation.Claim
        switch observation.producerConsistencyClaim {
        case .unchecked: claim = .unchecked
        case .producerReportedStable: claim = .producerReportedStable
        case .producerReportedChanged: claim = .producerReportedChanged
        }

        let head: ManagedWorkspaceProductGUIPresentation.ReportedHeadMode
        switch observation.git.headMode {
        case .branch: head = .branch
        case .detached: head = .detached
        case .unborn: head = .unborn
        }

        let changes: ManagedWorkspaceProductGUIPresentation.ReportedChangeCounts?
        if let values = observation.git.changeCounts {
            changes = ManagedWorkspaceProductGUIPresentation.ReportedChangeCounts(
                staged: try count(values.staged),
                unstaged: try count(values.unstaged),
                untracked: try count(values.untracked)
            )
        } else {
            changes = nil
        }

        let remotes: ManagedWorkspaceProductGUIPresentation.ReportedRemotePresence =
            observation.git.remotes.isEmpty ? .producerReportedNone : .producerReportedPresent

        let cachedComparison: ManagedWorkspaceProductGUIPresentation.CachedComparison
        if let upstream = observation.git.upstream,
           let ahead = upstream.ahead, let behind = upstream.behind {
            cachedComparison = .producerReported(
                ahead: try requiredCount(ahead), behind: try requiredCount(behind)
            )
        } else {
            cachedComparison = .notRecorded
        }

        return ManagedWorkspaceProductGUIPresentation.Imported(
            claim: claim,
            head: head,
            changes: changes,
            remotes: remotes,
            cachedComparison: cachedComparison
        )
    }

    private static func projectActivity(
        _ status: ManagedWorkspaceAssessmentLease.Status,
        subject: ManagedWorkspaceDefinition
    ) throws -> ManagedWorkspaceProductGUIPresentation.Activity {
        switch status.phase {
        case .idle:
            guard status.workspaceID == nil, status.generation == nil else {
                throw ManagedWorkspaceProjectionError.statusMismatch
            }
            return .idle
        case .active:
            try requireStatusSubject(status, subject: subject)
            return .assessing
        case .cancellationRequested:
            try requireStatusSubject(status, subject: subject)
            return .cancellationRequested
        case .workerReturned, .postflightSettled:
            try requireStatusSubject(status, subject: subject)
            return .settling
        }
    }

    private static func requireStatusSubject(
        _ status: ManagedWorkspaceAssessmentLease.Status,
        subject: ManagedWorkspaceDefinition
    ) throws {
        guard status.workspaceID == subject.id, status.generation != nil else {
            throw ManagedWorkspaceProjectionError.statusMismatch
        }
    }

    private static func count(_ value: Int?) throws -> UInt32? {
        guard let value else { return nil }
        return try requiredCount(value)
    }

    private static func requiredCount(_ value: Int) throws -> UInt32 {
        guard (0...PrimeGitSnapshot.maximumCount).contains(value),
              let projected = UInt32(exactly: value) else {
            throw ManagedWorkspaceProjectionError.countOutOfRange
        }
        return projected
    }
}

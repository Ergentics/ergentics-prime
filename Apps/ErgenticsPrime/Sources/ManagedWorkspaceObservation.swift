import CryptoKit
import Foundation

enum ManagedWorkspaceObservationError: Error, Equatable, CustomStringConvertible {
    case incompatibleWorkspace

    var description: String {
        switch self {
        case .incompatibleWorkspace:
            return "The selected workspace is not registered as the Prime Git adapter subject"
        }
    }
}

/// A normalized imported observation. Every field remains attributable to its
/// producer; parsing and normalization do not admit a repository, verify live
/// Git state, grant execution, select a candidate, or promote authority.
struct ManagedWorkspaceObservation: Equatable, Sendable {
    static let primeParserID = "com.ergentics.provenance.prime-git-import.v1"

    enum SourceDisposition: String, Equatable, Sendable {
        case importedSnapshot
    }

    enum ProducerConsistencyClaim: String, Equatable, Sendable {
        case unchecked
        case producerReportedStable
        case producerReportedChanged
    }

    struct GitState: Equatable, Sendable {
        enum HeadMode: String, Equatable, Sendable { case branch, detached, unborn }

        struct ChangeCounts: Equatable, Sendable {
            let staged: Int?
            let unstaged: Int?
            let untracked: Int?
        }

        struct Remote: Equatable, Sendable {
            let name: String
            /// Sanitized producer data for presentation, never a connection capability.
            let url: String?
        }

        struct Upstream: Equatable, Sendable {
            let ref: String
            let commitOID: String?
            let ahead: Int?
            let behind: Int?
        }

        let headMode: HeadMode
        let branch: String?
        let headOID: String?
        let changeCounts: ChangeCounts?
        let remotes: [Remote]
        let upstream: Upstream?
    }

    struct ImportedSourceProvenance: Equatable, Sendable {
        /// Parser identity plus exact source-byte properties. These establish a
        /// local lineage join only; they do not authenticate the producer or
        /// make the imported claims true.
        let parserID: String
        let byteCount: Int
        let sha256: String
    }

    let workspaceID: ManagedWorkspaceID
    let workspaceKind: ManagedWorkspaceKind
    let sourceDisposition: SourceDisposition
    let sourceSchema: String
    let sourceProvenance: ImportedSourceProvenance
    /// Imported producer label only. It is never used as an open or capability.
    let importedPathLabel: String
    /// Exact normalized source text, not a locally refreshed clock assertion.
    let observedAt: String
    let git: GitState
    let producerConsistencyClaim: ProducerConsistencyClaim

    /// Only the closed parser in this file may construct a normalized value.
    /// Other production sources can read it but cannot mint one from fields.
    fileprivate init(workspaceID: ManagedWorkspaceID,
                     workspaceKind: ManagedWorkspaceKind,
                     sourceDisposition: SourceDisposition,
                     sourceSchema: String,
                     sourceProvenance: ImportedSourceProvenance,
                     importedPathLabel: String,
                     observedAt: String,
                     git: GitState,
                     producerConsistencyClaim: ProducerConsistencyClaim) {
        self.workspaceID = workspaceID
        self.workspaceKind = workspaceKind
        self.sourceDisposition = sourceDisposition
        self.sourceSchema = sourceSchema
        self.sourceProvenance = sourceProvenance
        self.importedPathLabel = importedPathLabel
        self.observedAt = observedAt
        self.git = git
        self.producerConsistencyClaim = producerConsistencyClaim
    }
}

enum ManagedWorkspaceObservationParser {
    static func primeSnapshot(_ data: Data) throws -> ManagedWorkspaceObservation {
        let definition = try ManagedWorkspaceRegistry.product.require(.prime)
        guard definition.kind == .git,
              definition.selectionPolicy == .userSelectedReadOnly else {
            throw ManagedWorkspaceObservationError.incompatibleWorkspace
        }
        let snapshot = try PrimeGitSnapshot.decode(data)
        let sourceDigest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let headMode: ManagedWorkspaceObservation.GitState.HeadMode
        switch snapshot.headMode {
        case .branch: headMode = .branch
        case .detached: headMode = .detached
        case .unborn: headMode = .unborn
        }
        let counts = snapshot.changeCounts.map {
            ManagedWorkspaceObservation.GitState.ChangeCounts(
                staged: $0.staged, unstaged: $0.unstaged, untracked: $0.untracked
            )
        }
        let remotes = snapshot.remotes.map {
            ManagedWorkspaceObservation.GitState.Remote(name: $0.name, url: $0.url)
        }
        let upstream = snapshot.upstream.map {
            ManagedWorkspaceObservation.GitState.Upstream(
                ref: $0.ref, commitOID: $0.commitOID, ahead: $0.ahead, behind: $0.behind
            )
        }
        let consistency: ManagedWorkspaceObservation.ProducerConsistencyClaim
        switch snapshot.consistency {
        case .unchecked: consistency = .unchecked
        case .stable: consistency = .producerReportedStable
        case .changed: consistency = .producerReportedChanged
        }
        return ManagedWorkspaceObservation(
            workspaceID: definition.id,
            workspaceKind: definition.kind,
            sourceDisposition: .importedSnapshot,
            sourceSchema: snapshot.schema,
            sourceProvenance: ManagedWorkspaceObservation.ImportedSourceProvenance(
                parserID: ManagedWorkspaceObservation.primeParserID,
                byteCount: data.count,
                sha256: sourceDigest
            ),
            importedPathLabel: snapshot.repositoryPath,
            observedAt: snapshot.observedAt,
            git: ManagedWorkspaceObservation.GitState(
                headMode: headMode,
                branch: snapshot.branch,
                headOID: snapshot.headOID,
                changeCounts: counts,
                remotes: remotes,
                upstream: upstream
            ),
            producerConsistencyClaim: consistency
        )
    }
}

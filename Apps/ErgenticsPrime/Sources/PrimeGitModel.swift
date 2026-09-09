import AppKit
import Combine
import Foundation

/// Owns the user-mediated snapshot import boundary. Raw bytes and normalized
/// observations remain inside the import task and are discarded immediately
/// after projection; SwiftUI receives only the minimized product presentation.
@MainActor
final class PrimeGitModel: ObservableObject {
    @Published private(set) var presentation: ManagedWorkspaceProductGUIPresentation
    @Published private(set) var importState: ManagedWorkspaceGUIImportState = .idle
    @Published private(set) var busy = false

    private let coordinator: ManagedWorkspaceAssessmentCoordinator
    private var assessmentTask: Task<Void, Never>?
    private var assessmentID: UUID?
    private var retryNormalTerminationWhenSettled = false

    init(coordinator: ManagedWorkspaceAssessmentCoordinator = .init()) {
        self.coordinator = coordinator
        presentation = try! ManagedWorkspaceProjector.productGUIAndAccessibility(
            observation: nil,
            leaseStatus: ManagedWorkspaceAssessmentLease.Status(
                phase: .idle, workspaceID: nil, generation: nil
            )
        )
    }

    var isIdle: Bool {
        !busy && assessmentTask == nil && presentation.observation == .notImported &&
        presentation.activity == .idle && importState == .idle
    }

    /// The product view emits only this closed proposal enum. It cannot supply
    /// a path, URL, destination, command, environment, or lease capability.
    func handle(_ proposal: ManagedWorkspaceGUIProposal,
                admission: ProvenanceReadOnlyImportAdmission?) {
        switch proposal {
        case .requestSnapshotImport:
            guard let admission else {
                importState = .rejected(.applicationNotAdmitted)
                return
            }
            importSnapshot(admission: admission)
        case .cancelAssessment:
            requestCancellation()
        case .clearPresentation:
            clearPresentation()
        }
    }

    func requestCancellationForTermination() {
        requestCancellation()
    }

    /// Normal termination is joined to the exact coordinator settlement. The
    /// separate Quit Now command remains the explicit immediate-exit path.
    func requestQuit() -> Bool {
        guard busy || assessmentTask != nil else { return true }
        retryNormalTerminationWhenSettled = true
        requestCancellation()
        return false
    }

    private func importSnapshot(admission: ProvenanceReadOnlyImportAdmission) {
        guard !busy, assessmentTask == nil, coordinator.canBegin else {
            if !coordinator.canBegin { importState = .rejected(.assessmentUnavailable) }
            return
        }
        guard let selection = coordinator.selectUserSnapshot(using: admission) else { return }

        clearToEmpty()
        importState = .importing
        busy = true
        let operationID = UUID()
        assessmentID = operationID
        assessmentTask = Task { [weak self] in
            guard let self else { return }
            let outcome = await coordinator.assess(selection: selection) { [weak self] activity in
                guard let self, self.assessmentID == operationID else { return }
                self.presentation = ManagedWorkspaceProjector.replacingActivity(
                    in: self.presentation, with: activity
                )
            }
            guard self.assessmentID == operationID else { return }
            switch outcome {
            case .completed(let next):
                self.presentation = next
                self.importState = .idle
            case .rejected(let rejection):
                self.importState = .rejected(rejection)
            }
            self.busy = false
            self.assessmentID = nil
            self.assessmentTask = nil
            if self.retryNormalTerminationWhenSettled {
                self.retryNormalTerminationWhenSettled = false
                Task { @MainActor in NSApplication.shared.terminate(nil) }
            }
        }
    }

    private func clearPresentation() {
        guard !busy, assessmentTask == nil else { return }
        clearToEmpty()
        importState = .idle
    }

    private func clearToEmpty() {
        let empty = try! ManagedWorkspaceProjector.productGUIAndAccessibility(
            observation: nil,
            leaseStatus: ManagedWorkspaceAssessmentLease.Status(
                phase: .idle, workspaceID: nil, generation: nil
            )
        )
        presentation = ManagedWorkspaceProjector.replacingActivity(
            in: empty, with: coordinator.activity
        )
    }

    private func requestCancellation() {
        guard busy, assessmentTask != nil else { return }
        coordinator.requestCancellation()
        assessmentTask?.cancel()
        presentation = ManagedWorkspaceProjector.replacingActivity(
            in: presentation, with: coordinator.activity
        )
    }
}

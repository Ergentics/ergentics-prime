#if DEBUG
import AppKit
import Combine
import Darwin
import Foundation
import SwiftUI

/// Joins the actual SwiftUI content window; window titles are presentation,
/// not a stable identity. The marker performs no activation or ordering.
struct DevelopmentReadinessWindowMarker: NSViewRepresentable {
    let observer: DevelopmentReadiness

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        observer.observe(view: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        observer.observe(view: nsView)
    }
}

/// A Debug-only, exact-argument startup and synthetic functional observation.
/// It is not a command runner or an actual guest/persistence test.
/// Normal app launches do not construct an observer task or emit this report.
@MainActor
final class DevelopmentReadiness: ObservableObject {
    private var started = false
    private weak var contentMarker: NSView?

    func observe(view: NSView) { contentMarker = view }

    func runOnce(model: ProvenanceModel, lab: HypervisorModel, primeGit: PrimeGitModel) async {
        guard !started else { return }
        started = true
        let identity = UUID()
        do {
            // First lifecycle admission, before Security, pure checks, window
            // polling or output. No cancellation callback waits on a worker;
            // the fixed stages observe the latched policy at their boundaries.
            _ = try lab.lifecycle.beginReadiness(identity, cancel: {})
        } catch {
            // No new owner was admitted, so do not enter an unbudgeted output
            // path. The live hook exits only this app, with no PASS inference.
            lab.quitNow()
            return
        }
        do {
            try requireWorking(lab.lifecycle, identity)
            try await assess(model: model, lab: lab, primeGit: primeGit, identity: identity)
            let final = try lab.lifecycle.completeReadiness(identity)
            guard final.clockValid, !final.canceled, !final.workBudgetExpired else {
                lab.quitNow()
                return
            }
            // Complete work is not completed process exit. The existing
            // delegate requests Quit and retains the earlier exit fallback.
            NSApplication.shared.terminate(nil)
        } catch {
            // Both streams can block. Keep the deadline armed and never make
            // the main actor wait inside their synchronous write operation.
            try? await Self.write(Data("ERGENTICS_FUNCTIONAL_READINESS_INCOMPLETE\n".utf8), diagnostic: true)
            lab.quitNow()
        }
    }

    private func assess(model: ProvenanceModel, lab: HypervisorModel,
                        primeGit: PrimeGitModel, identity: UUID) async throws {
        let start = mach_absolute_time()
        let environmentAtStart = DevelopmentEnvironmentNames(environment: ProcessInfo.processInfo.environment)
        await model.inspectHost(queryHypervisor: false)
        try requireWorking(lab.lifecycle, identity)
        let functionality = await Task.detached(priority: .userInitiated) {
            FunctionalReadiness.run()
        }.value
        try requireWorking(lab.lifecycle, identity)
        var canceled = false
        // Window polling stays cooperative. The separate whole-readiness
        // lifecycle is already armed across this and all other work stages.
        for _ in 0..<60 {
            try requireWorking(lab.lifecycle, identity)
            if let window = contentMarker?.window, window.isVisible && !window.isMiniaturized,
               let size = window.contentView?.bounds.size,
               size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 { break }
            do { try await Task.sleep(nanoseconds: 50_000_000) }
            catch { canceled = true; break }
        }
        try requireWorking(lab.lifecycle, identity)
        var timebase = mach_timebase_info_data_t()
        let timebaseStatus = mach_timebase_info(&timebase)
        let window = contentMarker?.window
        let visible = window.map { $0.isVisible && !$0.isMiniaturized } ?? false
        let size = window?.contentView?.bounds.size ?? .zero
        let title = window?.title ?? ""
        let environmentAtObservation = DevelopmentEnvironmentNames(environment: ProcessInfo.processInfo.environment)
        let labSkipped = !lab.developmentStartupHandled
        let capabilitiesSkipped = model.hypervisor == nil
        let guestIdle = !lab.busy && lab.result == nil && lab.recent.isEmpty
        let gitIdle = primeGit.isIdle
        let end = mach_absolute_time()
        let report = DevelopmentReadinessReport(
            pid: getpid(), bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            executablePath: Bundle.main.executableURL?.path ?? "",
            team: model.team, signatureAdmitted: model.admitted, signingStatus: model.signingStatus,
            environmentCountAtProbeStart: environmentAtStart.count,
            environmentCountAtObservation: environmentAtObservation.count,
            environmentNamesAtProbeStart: environmentAtStart.names,
            environmentNamesAtObservation: environmentAtObservation.names,
            visibleWindowCount: visible ? 1 : 0,
            contentWindowAttached: window != nil, observedWindowTitle: title,
            windowWidth: size.width, windowHeight: size.height,
            labStartupSkipped: labSkipped, capabilityQueriesSkipped: capabilitiesSkipped,
            guestModelIdle: guestIdle, primeGitModelIdle: gitIdle,
            pollingCanceled: canceled, startTicks: String(start), observationTicks: String(end),
            timebaseStatus: timebaseStatus, timebaseNumerator: timebase.numer,
            timebaseDenominator: timebase.denom)
        let snapshot = try lab.lifecycle.checkReadiness(identity)
        let assessment = ReadinessAssessment(startup: report, functionality: functionality, lifecycle: snapshot)
        let bytes = try assessment.frame()
        try requireWorking(lab.lifecycle, identity)
        // The new versioned prefix prevents a legacy GUI-only observer from
        // silently accepting this different proof scope. Output remains on FD1;
        // no filename, path loader or caller-selected operation is added.
        try await Self.write(bytes, diagnostic: false)
    }

    private func requireWorking(_ lifecycle: AppLifecycleController, _ identity: UUID) throws {
        let sample = try lifecycle.checkReadiness(identity)
        guard sample.phase == .working, sample.clockValid, !sample.canceled, !sample.workBudgetExpired else {
            throw CheckError.interrupted
        }
    }

    nonisolated private static func write(_ bytes: Data, diagnostic: Bool) async throws {
        try await Task.detached(priority: .userInitiated) {
            let handle = diagnostic ? FileHandle.standardError : FileHandle.standardOutput
            try handle.write(contentsOf: bytes)
        }.value
    }

    private enum CheckError: Error { case interrupted }
}
#endif

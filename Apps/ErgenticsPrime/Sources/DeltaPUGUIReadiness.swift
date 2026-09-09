#if DEBUG
import AppKit
import Combine
import Darwin
import Foundation
import SwiftUI

/// A background view attached to the actual page/header/table. It neither
/// creates nor orders a window, and records bindings, not virtualized pixels.
struct DeltaPUGUIReadinessMarker: NSViewRepresentable {
    let observer: DeltaPUGUIReadiness
    let role: String
    let stateID: String
    let rowIDs: [UInt32]

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        // Only this nonvisual background leaf is bounded. Do not change the
        // clipping policy of the content, Table, ScrollView or their parents.
        view.clipsToBounds = true
        observer.observe(view, role: role, stateID: stateID, rowIDs: rowIDs)
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        view.clipsToBounds = true
        observer.observe(view, role: role, stateID: stateID, rowIDs: rowIDs)
    }
}

/// One bounded programmatic workflow through the ordinary demo model, joined
/// to mounted views. Not mouse delivery, pixel QA, guest execution or Gate E.
@MainActor
final class DeltaPUGUIReadiness: ObservableObject {
    private final class Binding {
        weak var view: NSView?
        let stateID: String
        let rowIDs: [UInt32]
        init(_ view: NSView, stateID: String, rowIDs: [UInt32]) {
            self.view = view; self.stateID = stateID; self.rowIDs = rowIDs
        }
    }
    private var bindings: [String: Binding] = [:]
    private var started = false

    func observe(_ view: NSView, role: String, stateID: String, rowIDs: [UInt32]) {
        bindings[role] = Binding(view, stateID: stateID, rowIDs: rowIDs)
    }

    func runOnce(model: ProvenanceModel, lab: HypervisorModel,
                 primeGit: PrimeGitModel, deltaPU: DeltaPUDemoModel) async {
        guard !started else { return }
        started = true
        let identity = UUID()
        do {
            // Same deadline owner as startup readiness, armed before Security,
            // any await, model work or output. No other lifecycle is installed.
            _ = try lab.lifecycle.beginReadiness(identity, cancel: {})
        } catch {
            // Admission did not arm a new deadline. Do not introduce an
            // unbudgeted diagnostic write; this pre-admission residual is
            // distinct from a caught failure inside the owned interval.
            lab.quitNow()
            return
        }
        var stage = "initial_state"
        do {
            try requireWorking(lab.lifecycle, identity)
            let namesAtStart = DevelopmentEnvironmentNames(environment: ProcessInfo.processInfo.environment).names
            let idle = deltaPU.phase == .idle && !deltaPU.busy && deltaPU.report == nil
            try requireDemo(deltaPU.phase == .idle, "demo.initial.phase_idle", deltaPU)
            try requireDemo(!deltaPU.busy, "demo.initial.not_busy", deltaPU)
            try requireDemo(deltaPU.report == nil, "demo.initial.report_absent", deltaPU)
            stage = "host_inspection"
            await model.inspectHost(queryHypervisor: false)
            try requireWorking(lab.lifecycle, identity)
            stage = "initial_page"
            try await waitForSurfaces(["page"], stateID: "", rowIDs: [], lab: lab, identity: identity)
            let initialPage = surface("page"), initialWindow = bindings["page"]?.view?.window
            guard let pageBefore = initialPage, let originalWindow = initialWindow else {
                throw DeltaPUGUICheckFailure(category: "surface", predicate: "page.initial.sample_and_window_present",
                    operands: ["samplePresent": String(initialPage != nil),
                               "windowPresent": String(initialWindow != nil)])
            }
            // Exactly one fixed synthetic run. It uses the production demo
            // model's retained one-worker/cancellation/publication mechanics.
            stage = "demo_admission"
            guard let completion = deltaPU.run(.sparse) else {
                throw demoFailure("demo.fixed_sparse.admitted", deltaPU)
            }
            stage = "demo_completion"
            await completion.value
            try requireWorking(lab.lifecycle, identity)
            try requireDemo(deltaPU.phase == .verified, "demo.final.phase_verified", deltaPU)
            try requireDemo(!deltaPU.busy, "demo.final.not_busy", deltaPU)
            guard let demo = deltaPU.report else { throw demoFailure("demo.final.report_present", deltaPU) }
            try requireDemo(deltaPU.failureMessage == nil, "demo.final.failure_absent", deltaPU)
            let stateID = demo.transition.snapshot.stateID
            let rowIDs = demo.verification.rows.map(\.id)
            stage = "result_surfaces"
            try await waitForSurfaces(["page", "result", "table"], stateID: stateID, rowIDs: rowIDs,
                                      lab: lab, identity: identity)
            let postPage = surface("page"), postResult = surface("result"), postTable = surface("table")
            guard let pageAfter = postPage, let result = postResult, let table = postTable else {
                throw DeltaPUGUICheckFailure(category: "surface", predicate: "result.snapshots_present",
                    operands: ["page": String(postPage != nil), "result": String(postResult != nil),
                               "table": String(postTable != nil)])
            }
            let sameWindow = ["page", "result", "table"].allSatisfy {
                bindings[$0]?.view?.window === originalWindow
            }
            stage = "report_construction"
            let report = DeltaPUGUIReadinessReport(
                pid: getpid(), bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
                executablePath: Bundle.main.executableURL?.path ?? "", team: model.team,
                signatureAdmitted: model.admitted,
                environmentNamesAtStart: namesAtStart,
                environmentNamesAtObservation: DevelopmentEnvironmentNames(environment: ProcessInfo.processInfo.environment).names,
                lifecycle: DeltaPUGUILifecycle(try lab.lifecycle.checkReadiness(identity)),
                pageBefore: pageBefore, pageAfter: pageAfter, result: result, table: table,
                sameWindowIdentity: sameWindow, initialDemoIdle: idle,
                labStartupSkipped: !lab.developmentStartupHandled,
                capabilityQueriesSkipped: model.hypervisor == nil,
                guestIdle: !lab.busy && lab.result == nil && lab.recent.isEmpty,
                gitIdle: primeGit.isIdle,
                fixture: DeltaPUGUIFixture(demo))
            stage = "report_validation"
            try report.validate(expectedDemo: demo)
            stage = "report_encoding"
            let bytes = try report.frame()
            try requireWorking(lab.lifecycle, identity)
            stage = "success_output"
            try await Self.write(bytes, diagnostic: false)
            stage = "lifecycle_completion"
            let final = try lab.lifecycle.completeReadiness(identity)
            try requireFinal(final)
            // The prepared frame cannot prove this subsequent process exit.
            // Fallback remains armed through output and the normal Quit path.
            NSApplication.shared.terminate(nil)
        } catch {
            // Capture the thrown sample before cancellation mutates model
            // state. It is diagnostic evidence, never a success frame.
            let receipt = DeltaPUGUIFailureReceipt(pid: getpid(), runID: identity,
                stage: stage, caughtTicks: mach_continuous_time(), error: error)
            deltaPU.cancel()
            do {
                try await Self.write(receipt.frame(), diagnostic: true)
                // Returned diagnostic work is not a PASS or conservation.
                // Apple normal-Quit guidance: see this slice's APPLE-REFERENCES.
                // Keep the original fallback armed across output and AppKit.
                let final = try lab.lifecycle.completeReadiness(identity)
                try requireFinal(final)
                NSApplication.shared.terminate(nil)
            } catch {
                // Failed/blocked output or expired/invalid lifecycle cannot
                // become normal exit 0 with an apparently successful FD1.
                // The independent original-start fallback is not disarmed.
                lab.quitNow()
            }
        }
    }

    private func surface(_ role: String) -> DeltaPUGUISurface? {
        guard let binding = bindings[role], let view = binding.view else { return nil }
        let window = view.window
        // Retain each raw rectangle from one MainActor sample. No intersection,
        // clamping, epsilon or independent reread of width and origin.
        let bounds = view.bounds, visible = view.visibleRect
        let clipsToBounds = view.clipsToBounds
        return DeltaPUGUISurface(
            role: role, windowNumber: window?.windowNumber ?? 0, attached: window != nil,
            visibleWindow: window?.isVisible ?? false, miniaturized: window?.isMiniaturized ?? false,
            hidden: view.isHiddenOrHasHiddenAncestor,
            boundsX: bounds.origin.x, boundsY: bounds.origin.y,
            width: bounds.width, height: bounds.height,
            visibleX: visible.origin.x, visibleY: visible.origin.y,
            visibleWidth: visible.width, visibleHeight: visible.height, clipsToBounds: clipsToBounds,
            boundStateID: binding.stateID, boundRowIDs: binding.rowIDs)
    }

    private func waitForSurfaces(_ roles: [String], stateID: String, rowIDs: [UInt32],
                                 lab: HypervisorModel, identity: UUID) async throws {
        var lastFailure: DeltaPUGUICheckFailure?
        for _ in 0..<60 {
            try requireWorking(lab.lifecycle, identity)
            lastFailure = nil
            for role in roles {
                let sample = surface(role)
                if let failure = pollingFailure(sample, role: role, stateID: stateID, rowIDs: rowIDs) {
                    lastFailure = failure
                    break
                }
            }
            if lastFailure == nil { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        // This is the exact last tested sample, not a catch-time re-read.
        throw lastFailure!
    }

    private func requireWorking(_ lifecycle: AppLifecycleController, _ identity: UUID) throws {
        let sample = try lifecycle.checkReadiness(identity)
        let taskCancelled = Task.isCancelled
        let checks = [("task_not_cancelled", !taskCancelled), ("phase_working", sample.phase == .working),
                      ("clock_valid", sample.clockValid), ("not_cancelled", !sample.canceled),
                      ("work_budget_not_expired", !sample.workBudgetExpired)]
        if let failed = checks.first(where: { !$0.1 }) {
            throw lifecycleFailure("working.\(failed.0)", sample, taskCancelled: taskCancelled)
        }
    }

    private func requireFinal(_ sample: AppLifecyclePolicy.ReadinessSnapshot) throws {
        for (id, passed) in [("clock_valid", sample.clockValid), ("not_cancelled", !sample.canceled),
                             ("work_budget_not_expired", !sample.workBudgetExpired)] where !passed {
            throw lifecycleFailure("completion.\(id)", sample)
        }
    }

    private func lifecycleFailure(_ predicate: String, _ value: AppLifecyclePolicy.ReadinessSnapshot,
                                  taskCancelled: Bool? = nil)
        -> DeltaPUGUICheckFailure {
        var operands = [
            "phase": value.phase.rawValue, "clockValid": String(value.clockValid),
            "canceled": String(value.canceled), "workBudgetExpired": String(value.workBudgetExpired),
            "startTicks": String(value.startTicks), "observationTicks": String(value.observationTicks),
            "timebaseNumerator": String(value.timebaseNumerator), "timebaseDenominator": String(value.timebaseDenominator),
            "fallbackArmed": String(value.fallbackArmed)]
        if let taskCancelled { operands["taskCancelled"] = String(taskCancelled) }
        return DeltaPUGUICheckFailure(category: "lifecycle", predicate: predicate, operands: operands)
    }

    private func requireDemo(_ passed: Bool, _ predicate: String, _ value: DeltaPUDemoModel) throws {
        if !passed { throw demoFailure(predicate, value) }
    }

    private func demoFailure(_ predicate: String, _ value: DeltaPUDemoModel) -> DeltaPUGUICheckFailure {
        DeltaPUGUICheckFailure(category: "model", predicate: predicate, operands: [
            "phase": value.phase.rawValue, "busy": String(value.busy),
            "reportPresent": String(value.report != nil), "failurePresent": String(value.failureMessage != nil)])
    }

    private func pollingFailure(_ sample: DeltaPUGUISurface?, role: String, stateID: String, rowIDs: [UInt32])
        -> DeltaPUGUICheckFailure? {
        guard let sample else {
            return DeltaPUGUICheckFailure(category: "surface", predicate: "poll.\(role).sample_present",
                operands: ["role": role, "samplePresent": "false"])
        }
        return sample.validationFailure(field: "poll.\(role)", expectedRole: role,
                                        expectedStateID: stateID, expectedRowIDs: rowIDs)
    }

    nonisolated private static func write(_ bytes: Data, diagnostic: Bool) async throws {
        try await Task.detached(priority: .userInitiated) {
            try (diagnostic ? FileHandle.standardError : FileHandle.standardOutput).write(contentsOf: bytes)
        }.value
    }
}
#endif

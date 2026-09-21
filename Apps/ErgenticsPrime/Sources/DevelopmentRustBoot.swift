#if DEBUG
import AppKit
import Combine
import Darwin
import Foundation
import SwiftUI

// Descriptor admission and sync stay off the main actor. The non-Sendable
// exporter remains wholly inside this actor; no descriptor/path crosses out.
private actor RustBootOutputOwner {
    private var exporter: DevelopmentRustBootExport?

    func prepare() throws {
        guard exporter == nil else { throw ProvenanceFailure("Boot output already admitted") }
        exporter = try DevelopmentRustBootExport.admitStandardOutput()
    }

    func retain(_ frame: Data) throws -> DevelopmentRustBootExport.Result {
        guard let exporter else { throw ProvenanceFailure("Boot output was not admitted") }
        return try exporter.export(frame: frame)
    }
}

private final class RustBootWindowGuard: NSObject, NSWindowDelegate {
    weak var owner: DevelopmentRustBoot?
    // Retain SwiftUI's delegate while this controlled mode owns the close guard;
    // restore it before normal termination. Normal launches never install us.
    let previous: (any NSWindowDelegate)?
    init(owner: DevelopmentRustBoot, previous: (any NSWindowDelegate)?) {
        self.owner = owner; self.previous = previous
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard owner?.allowsNormalExit == true else {
            owner?.requestQuit()
            return false
        }
        return previous?.windowShouldClose?(sender) ?? true
    }
}

struct DevelopmentRustBootWindowMarker: NSViewRepresentable {
    let observer: DevelopmentRustBoot
    func makeNSView(context: Context) -> NSView { Marker(observer: observer) }
    func updateNSView(_ view: NSView, context: Context) {
        if let window = view.window { observer.attach(window: window) }
    }
    private final class Marker: NSView {
        weak var observer: DevelopmentRustBoot?
        init(observer: DevelopmentRustBoot) {
            self.observer = observer
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) { return nil }
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let window { observer?.attach(window: window) }
        }
    }
}

struct DevelopmentRustBootStatusView: View {
    @ObservedObject var observer: DevelopmentRustBoot
    @ObservedObject var lab: HypervisorModel
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Synthetic Rust boot — controlled Debug mode").font(.headline)
            Text("PID \(getpid()) · boot \(observer.bootID)")
            if let run = lab.developmentBootRunID { Text("Run \(run)") }
            Text(observer.phase)
            Text(observer.nativeStatus)
            Text(observer.evidenceStatus)
            Text("No second run · no high-value state · Gate E ABSTAIN")
                .font(.caption).foregroundStyle(.secondary)
        }
        .font(.system(.caption, design: .monospaced))
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .accessibilityElement(children: .combine)
        .allowsHitTesting(false)
    }
}

@MainActor
final class DevelopmentRustBoot: ObservableObject {
    let bootID = UUID().uuidString.lowercased()
    @Published private(set) var phase = "Waiting for the controlled window"
    @Published private(set) var nativeStatus = "Native call not committed"
    @Published private(set) var evidenceStatus = "Evidence not prepared"
    private(set) var allowsNormalExit = false
    private(set) var started = false
    private var quitRequested = false
    private weak var window: NSWindow?
    private var windowGuard: RustBootWindowGuard?
    private var previousCloseEnabled = true
    private weak var lab: HypervisorModel?
    private let output = RustBootOutputOwner()
    // Retain the COMPLETE immutable return and prepared bytes through any
    // publication failure. UI strings never replace these recovery values.
    private(set) var retainedCompletion: DevelopmentRustBootCompletion?
    private(set) var retainedFrame: Data?
    private(set) var retainedExportResult: DevelopmentRustBootExport.Result?
    private(set) var retainedExportFailure: DevelopmentRustBootExport.Failure?
    private(set) var exportFailure: String?

    func attach(window candidate: NSWindow) {
        guard !allowsNormalExit else { return }
        if window !== candidate {
            guard window == nil else { return }
            window = candidate
            previousCloseEnabled = candidate.standardWindowButton(.closeButton)?.isEnabled ?? true
            windowGuard = RustBootWindowGuard(owner: self, previous: candidate.delegate)
        }
        if let windowGuard { candidate.delegate = windowGuard }
        candidate.standardWindowButton(.closeButton)?.isEnabled = true
    }

    func requestQuit() {
        guard !allowsNormalExit else { return }
        if !quitRequested {
            quitRequested = true
        }
        // User Quit is independent from the automatic-success export predicate.
        // The historical mayTerminate verifier remains unchanged; it no longer
        // has authority to keep a user-requested application alive indefinitely.
        phase = "User Quit requested; five-second grace at most for active work"
        if lab?.requestQuit() != false { NSApplication.shared.terminate(nil) }
        window?.makeKeyAndOrderFront(nil)
    }

    func runOnce(model: ProvenanceModel, lab: HypervisorModel, primeGit: PrimeGitModel) async {
        guard !started else { return }
        started = true; self.lab = lab
        let start = mach_absolute_time()
        var timebase = mach_timebase_info_data_t()
        let clockStatus = mach_timebase_info(&timebase)
        let names = ProcessInfo.processInfo.environment.keys.sorted()
        var preparationError: String?
        do { try await output.prepare() }
        catch { preparationError = "Output admission failed: \(error)" }

        // Window attachment is cooperative UI preparation, not a kernel timer.
        for _ in 0..<60 {
            if let window, window.isVisible && !window.isMiniaturized,
               window.delegate === windowGuard { break }
            do { try await Task.sleep(nanoseconds: 50_000_000) }
            catch { preparationError = preparationError ?? "Window preparation canceled"; break }
        }
        if window?.isVisible != true || window?.isMiniaturized == true || window?.delegate !== windowGuard {
            preparationError = preparationError ?? "Guarded visible window unavailable"
        }
        if clockStatus != KERN_SUCCESS || timebase.numer == 0 || timebase.denom == 0 {
            preparationError = preparationError ?? "Hardware timebase unavailable"
        }
        if !primeGit.isIdle {
            preparationError = preparationError ?? "Prime Git model is not idle"
        }
        if preparationError == nil { await model.inspectHost(queryHypervisor: false) }
        if !model.admitted { preparationError = preparationError ?? "Existing signature admission rejected: \(model.signingStatus)" }
        let context = DevelopmentRustBootContext(bootID: bootID, pid: getpid(),
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            executablePath: Bundle.main.executableURL?.path ?? "", team: model.team,
            signatureAdmitted: model.admitted, signingStatus: model.signingStatus,
            environmentNames: names, startTicks: start,
            timebaseNumerator: timebase.numer, timebaseDenominator: timebase.denom)

        let completion: DevelopmentRustBootCompletion
        if let preparationError {
            completion = notEntered(preparationError)
        } else {
            phase = "One controlled invocation: preparation / native / journal pending"
            nativeStatus = "Awaiting captured return; actual vCPU entry is not yet proven"
            guard let returned = await lab.runDevelopmentRustBoot(admitted: model.admitted) else {
                // A refused model admission may mean another/unconserved owner,
                // not proof that this process owns no native resources.
                exportFailure = "Controlled owner admission rejected; native ownership is unclassified"
                nativeStatus = "Owner admission refused; no safe-exit inference"
                evidenceStatus = "Admission diagnostic retained in this window; no fabricated completion"
                phase = "Keeping the window available; no automatic exit or rerun"
                window?.makeKeyAndOrderFront(nil)
                return
            }
            completion = returned
        }
        retainedCompletion = completion
        nativeStatus = "Native disposition: \(completion.nativeDisposition.rawValue)"
        evidenceStatus = "Journal verified: \(completion.journalVerified); result: \(completion.status)"
        phase = "Preparing bounded evidence export"

        do {
            let frame = try DevelopmentRustBootReport.encode(context: context, completion: completion,
                preparedTicks: mach_absolute_time())
            retainedFrame = frame
            _ = try DevelopmentRustBootReport.verify(frame: frame)
            let exported = try await output.retain(frame)
            retainedExportResult = exported
            evidenceStatus = "Export read-back verified: \(exported.bytes) bytes, SHA-256 \(exported.sha256)"
            if try DevelopmentRustBootReport.mayTerminate(completion: completion, exportRetained: true) {
                phase = "Evidence retained; requesting normal quit (exit not yet observed)"
                allowsNormalExit = true
                restoreWindowDelegate()
                NSApplication.shared.terminate(nil)
            } else {
                phase = "Native conservation unproven; keeping owner and window available"
                window?.makeKeyAndOrderFront(nil)
            }
        } catch {
            retainedExportFailure = error as? DevelopmentRustBootExport.Failure
            exportFailure = String(describing: error)
            evidenceStatus = "Export incomplete: \(error). Full available recovery remains in memory."
            phase = completion.nativeDisposition == .returnedUnconserved || completion.nativeDisposition == .running
                ? "Native conservation unproven; no automatic exit or rerun"
                : "Captured disposition reports \(completion.nativeDisposition.rawValue); validation/export incomplete, not native containment"
            window?.makeKeyAndOrderFront(nil)
        }
    }

    private func notEntered(_ detail: String) -> DevelopmentRustBootCompletion {
        DevelopmentRustBootCompletion(runID: UUID().uuidString.lowercased(), nativeDisposition: .notEntered,
            rawFields: [:], events: [], journalVerified: false, journalRetainsAllEvidence: false,
            status: "NOT_ENTERED", detail: detail, journalCompletedTicks: 0)
    }

    private func restoreWindowDelegate() {
        if let window, let windowGuard, window.delegate === windowGuard {
            window.delegate = windowGuard.previous
            window.standardWindowButton(.closeButton)?.isEnabled = previousCloseEnabled
        }
    }
}
#endif

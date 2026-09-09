import AppKit
import Darwin
import SwiftUI

@main
@MainActor
struct ProvenanceApp: App {
    #if EPR_H3_QUALIFICATION
    private let launchMode: DevelopmentLaunch.Mode
    @NSApplicationDelegateAdaptor(ProvenanceAppDelegate.self) private var delegate
    @StateObject private var model: ProvenanceModel
    @StateObject private var lab: HypervisorModel
    private let qualificationCoordinator: H3QualificationCoordinator

    init() {
        let mode = DevelopmentLaunch.processMode
        switch mode {
        case .h3QualificationAdmission, .h3QualificationGuest: break
        default:
            let message = "Ergentics Provenance rejected the launch arguments.\n"
            message.withCString { _ = Darwin.write(STDERR_FILENO, $0, message.utf8.count) }
            Darwin._exit(EX_USAGE)
        }
        launchMode = mode
        let eventMode: H3QualificationMode
        if case .h3QualificationAdmission = mode { eventMode = .admissionOnly } else { eventMode = .guest }
        var events = H3QualificationApplicationEventStateMachine(mode: eventMode)
        let owner = H3QualificationTerminalOwner()
        events.identity(.owner, value: UInt64(UInt(bitPattern: ObjectIdentifier(owner))))
        events.record(.owner)
        let model = ProvenanceModel()
        events.identity(.model, value: UInt64(UInt(bitPattern: ObjectIdentifier(model))))
        events.record(.model)
        let lab = HypervisorModel(qualificationTerminalOwner: owner)
        events.identity(.lab, value: UInt64(UInt(bitPattern: ObjectIdentifier(lab))))
        events.record(.lab)
        _model = StateObject(wrappedValue: model)
        _lab = StateObject(wrappedValue: lab)
        events.record(.storedModel)
        events.record(.storedLab)
        qualificationCoordinator = H3QualificationCoordinator(
            terminalOwner: owner, mode: mode, model: model, lab: lab, events: events)
    }

    var body: some Scene {
        Window("Ergentics Provenance", id: "provenance") {
            H3QualificationInertRoot()
                .task { await qualificationCoordinator.run() }
        }
    }
    #else
    private let launchMode = DevelopmentLaunch.processMode
    @NSApplicationDelegateAdaptor(ProvenanceAppDelegate.self) private var delegate
    @StateObject private var model = ProvenanceModel()
    @StateObject private var lab = HypervisorModel()
    @StateObject private var primeRuntime = PrimeRuntimeModel()
    @StateObject private var primePrompt = PrimePromptModel.shared
    @StateObject private var primeGit = PrimeGitModel()
    @StateObject private var deltaPU = DeltaPUDemoModel()
    @StateObject private var virtualMachines = VMWorkspaceModel()
    @StateObject private var gitWorkspace = GitWorkspaceModel()
    @State private var windowCaptureBoundaryApplied: Bool?
    #if DEBUG
    @StateObject private var readiness = DevelopmentReadiness()
    @StateObject private var rustBoot = DevelopmentRustBoot()
    @StateObject private var deltaPUReadiness = DeltaPUGUIReadiness()
    #endif

    init() {
        guard launchMode == .invalid else { return }
        let message = "Ergentics Provenance rejected the launch arguments.\n"
        message.withCString { pointer in
            _ = Darwin.write(STDERR_FILENO, pointer, strlen(pointer))
        }
        Darwin.exit(EX_USAGE)
    }

    var body: some Scene {
        Window("Ergentics Prime", id: "provenance") {
            content
                .frame(minWidth: 920, minHeight: 680)
                .disabled(launchMode != .ordinary || DevelopmentLaunch.computeCheckRequested)
                .background {
                    if launchMode != .rustBootstrapOnce {
                        AppLifecycleWindowMarker(lab: lab, primeGit: primeGit,
                                                 virtualMachines: virtualMachines, gitWorkspace: gitWorkspace, primeRuntime: primeRuntime)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                        WindowPrivacyMarker(applied: $windowCaptureBoundaryApplied)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    #if DEBUG
                    if launchMode == .primeGitReadiness {
                        DevelopmentReadinessWindowMarker(observer: readiness)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    if launchMode == .rustBootstrapOnce {
                        DevelopmentRustBootWindowMarker(observer: rustBoot)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    #endif
                }
                .overlay(alignment: .top) {
                    #if DEBUG
                    if launchMode == .rustBootstrapOnce {
                        DevelopmentRustBootStatusView(observer: rustBoot, lab: lab)
                    }
                    #endif
                }
                .task {
                    if DevelopmentLaunch.computeCheckRequested {
                        await PrimeComputeCheck.runOnce()
                        return
                    }
                    delegate.lab = lab
                    delegate.primeRuntime = primeRuntime
                    delegate.primeGit = primeGit
                    delegate.virtualMachines = virtualMachines
                    delegate.gitWorkspace = gitWorkspace
                    if launchMode == .ordinary {
                        PrimeComputeModel.shared.nativeRunAdmission = { [weak lab, weak virtualMachines] in
                            lab?.busy != true && lab?.quarantined != true && virtualMachines?.isActive != true
                        }
                        lab.nativeRunAdmission = { [weak virtualMachines] in
                            virtualMachines?.isActive != true && !PrimeComputeModel.shared.busy
                        }
                        virtualMachines.nativeRunAdmission = { [weak lab] in
                            lab?.busy != true && lab?.quarantined != true && !PrimeComputeModel.shared.busy
                        }
                    }
                    #if DEBUG
                    if launchMode == .deltaPUReadiness {
                        await deltaPUReadiness.runOnce(model: model, lab: lab, primeGit: primeGit, deltaPU: deltaPU)
                        return
                    }
                    if launchMode == .rustBootstrapOnce {
                        delegate.rustBoot = rustBoot
                        await rustBoot.runOnce(model: model, lab: lab, primeGit: primeGit)
                        return
                    }
                    if launchMode == .primeGitReadiness {
                        await readiness.runOnce(model: model, lab: lab, primeGit: primeGit)
                        return
                    }
                    #endif
                    await model.inspectHost()
                    lab.startup(admitted: model.admitted, launchMode: launchMode)
                }
        }
        .defaultSize(width: 1120, height: 780)
        .defaultLaunchBehavior(.presented)
        .restorationBehavior(.disabled)
        .commands {
            PrimePromptCommands()
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appTermination) {
                Button("Quit Ergentics Now — Discard Unsaved Memory") {
                    primeRuntime.cancel()
                    primePrompt.cancel()
                    PrimeComputeModel.shared.cancel()
                    primeGit.requestCancellationForTermination()
                    gitWorkspace.cancel()
                    virtualMachines.cancelAndStop()
                    lab.quitNow()
                }
            }
        }
        Window("Stage 7 checkpoint experiment", id: "prime-question") {
            PrimePromptView(model: primePrompt)
        }
        .defaultSize(width: 760, height: 720)
        .defaultLaunchBehavior(.suppressed)
    }

    @ViewBuilder private var content: some View {
        #if DEBUG
        ProvenanceView(model: model, lab: lab, primeRuntime: primeRuntime, primeGit: primeGit, deltaPU: deltaPU,
                       virtualMachines: virtualMachines, gitWorkspace: gitWorkspace,
                       windowCaptureBoundaryApplied: windowCaptureBoundaryApplied,
                       deltaPUReadiness: launchMode == .deltaPUReadiness ? deltaPUReadiness : nil)
        #else
        ProvenanceView(model: model, lab: lab, primeRuntime: primeRuntime, primeGit: primeGit, deltaPU: deltaPU,
                       virtualMachines: virtualMachines, gitWorkspace: gitWorkspace,
                       windowCaptureBoundaryApplied: windowCaptureBoundaryApplied)
        #endif
    }
    #endif
}

#if EPR_H3_QUALIFICATION
private struct H3QualificationInertRoot: View {
    var body: some View { Text("H3 qualification in progress") }
}
#endif

/// Retains the legacy AppKit sharing preference for compatibility. Its readback
/// is not capture protection: Apple describes SharingType.none as a legacy
/// constant macOS no longer uses. The UI must not turn this flag into a privacy
/// claim, and it does not restrict accessibility readers.
private struct WindowPrivacyMarker: NSViewRepresentable {
    @Binding var applied: Bool?

    func makeNSView(context: Context) -> Marker {
        Marker(report: report)
    }

    func updateNSView(_ view: Marker, context: Context) {
        view.report = report
        view.apply()
    }

    private func report(_ value: Bool) {
        if applied != value { applied = value }
    }

    final class Marker: NSView {
        var report: (Bool) -> Void
        init(report: @escaping (Bool) -> Void) {
            self.report = report
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) { nil }
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            apply()
        }
        func apply() {
            guard let window else { return }
            window.sharingType = .none
            report(window.sharingType == .none)
        }
    }
}

/// Static categorical watermark: useful when pixels escape through a path the
/// native sharing boundary cannot control, without embedding a user/session ID.
struct ProvenanceWatermark: View {
    var body: some View {
        GeometryReader { geometry in
            let columns = max(1, Int(geometry.size.width / 310))
            let rows = max(1, Int(geometry.size.height / 190))
            VStack(spacing: 110) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 75) {
                        ForEach(0..<columns, id: \.self) { column in
                            Text("ERGENTICS · PRESENTATION ONLY · NOT AUTHORITY")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(1.4)
                                .fixedSize()
                                .rotationEffect(.degrees(-18))
                                .offset(x: row.isMultiple(of: 2) ? 0 : 65)
                                .accessibilityIdentifier("provenance-watermark-\(row)-\(column)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.secondary.opacity(0.055))
            .clipped()
        }
    }
}

@MainActor
final class ProvenanceAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if DevelopmentLaunch.computeCheckRequested {
            Task { await PrimeComputeCheck.runOnce() }
        }
    }
    weak var lab: HypervisorModel?
    weak var primeGit: PrimeGitModel?
    weak var virtualMachines: VMWorkspaceModel?
    weak var gitWorkspace: GitWorkspaceModel?
    weak var primeRuntime: PrimeRuntimeModel?
    #if DEBUG
    weak var rustBoot: DevelopmentRustBoot?
    #endif
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        #if EPR_H3_QUALIFICATION
        switch DevelopmentLaunch.processMode {
        case .h3QualificationAdmission, .h3QualificationGuest: return false
        default: break
        }
        #endif
        return true
    }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        #if EPR_H3_QUALIFICATION
        switch DevelopmentLaunch.processMode {
        case .h3QualificationAdmission, .h3QualificationGuest: return .terminateCancel
        default: break
        }
        #endif
        return requestNormalQuit(lab: lab, primeGit: primeGit,
                                 virtualMachines: virtualMachines, gitWorkspace: gitWorkspace, primeRuntime: primeRuntime)
            ? .terminateNow : .terminateCancel
    }
}

/// All owners are consulted even when another is still stopping. The lab's
/// existing quit policy keeps its five-second fallback armed while idle too.
@MainActor
private func requestNormalQuit(lab: HypervisorModel?, primeGit: PrimeGitModel?,
                               virtualMachines: VMWorkspaceModel?, gitWorkspace: GitWorkspaceModel?, primeRuntime: PrimeRuntimeModel?) -> Bool {
    // Arm the existing off-main deadline before asking the VM framework to stop.
    let labReady = lab?.requestQuit() ?? true
    let primeReady = primeGit?.requestQuit() ?? true
    let runtimeReady = primeRuntime?.requestQuit() ?? true
    let promptReady = PrimePromptModel.shared.requestQuit()
    let computeReady = PrimeComputeModel.shared.requestQuit()
    let vmReady = virtualMachines?.requestQuit() ?? true
    let gitReady = gitWorkspace?.requestQuit() ?? true
    if !vmReady || !gitReady {
        WorkspaceQuitRetry.arm(virtualMachines: virtualMachines, gitWorkspace: gitWorkspace)
    }
    return computeReady && promptReady && runtimeReady && primeReady && vmReady && gitReady && labReady
}

/// The new workers join the existing cancel-and-retry AppKit path. This task
/// only observes completion; the existing lifecycle deadline owns forced exit.
@MainActor
private enum WorkspaceQuitRetry {
    private static var pending: Task<Void, Never>?

    static func arm(virtualMachines: VMWorkspaceModel?, gitWorkspace: GitWorkspaceModel?) {
        guard pending == nil else { return }
        pending = Task { [weak virtualMachines, weak gitWorkspace] in
            while virtualMachines?.isActive == true || gitWorkspace?.busy == true {
                try? await Task.sleep(for: .milliseconds(50))
            }
            pending = nil
            NSApplication.shared.terminate(nil)
        }
    }
}

/// Preserve the ordinary window while a close request is being resolved. The
/// user may still Quit Now; this is never a proof-based veto on termination.
private final class AppLifecycleWindowGuard: NSObject, NSWindowDelegate {
    weak var lab: HypervisorModel?
    weak var primeGit: PrimeGitModel?
    weak var virtualMachines: VMWorkspaceModel?
    weak var gitWorkspace: GitWorkspaceModel?
    weak var primeRuntime: PrimeRuntimeModel?
    let previous: (any NSWindowDelegate)?
    init(lab: HypervisorModel, primeGit: PrimeGitModel,
         virtualMachines: VMWorkspaceModel, gitWorkspace: GitWorkspaceModel, primeRuntime: PrimeRuntimeModel,
         previous: (any NSWindowDelegate)?) {
        self.lab = lab; self.primeGit = primeGit
        self.virtualMachines = virtualMachines; self.gitWorkspace = gitWorkspace; self.primeRuntime = primeRuntime
        self.previous = previous
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if requestNormalQuit(lab: lab, primeGit: primeGit,
                             virtualMachines: virtualMachines, gitWorkspace: gitWorkspace, primeRuntime: primeRuntime) {
            return previous?.windowShouldClose?(sender) ?? true
        }
        sender.makeKeyAndOrderFront(nil)
        return false
    }
}

private struct AppLifecycleWindowMarker: NSViewRepresentable {
    let lab: HypervisorModel
    let primeGit: PrimeGitModel
    let virtualMachines: VMWorkspaceModel
    let gitWorkspace: GitWorkspaceModel
    let primeRuntime: PrimeRuntimeModel
    func makeNSView(context: Context) -> Marker {
        Marker(lab: lab, primeGit: primeGit, virtualMachines: virtualMachines, gitWorkspace: gitWorkspace, primeRuntime: primeRuntime)
    }
    func updateNSView(_ view: Marker, context: Context) { view.install() }
    final class Marker: NSView {
        weak var lab: HypervisorModel?
        weak var primeGit: PrimeGitModel?
        weak var virtualMachines: VMWorkspaceModel?
        weak var gitWorkspace: GitWorkspaceModel?
        weak var primeRuntime: PrimeRuntimeModel?
        private var heldGuard: AppLifecycleWindowGuard?
        init(lab: HypervisorModel, primeGit: PrimeGitModel,
             virtualMachines: VMWorkspaceModel, gitWorkspace: GitWorkspaceModel, primeRuntime: PrimeRuntimeModel) {
            self.lab = lab; self.primeGit = primeGit
            self.virtualMachines = virtualMachines; self.gitWorkspace = gitWorkspace; self.primeRuntime = primeRuntime
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) { nil }
        override func viewDidMoveToWindow() { super.viewDidMoveToWindow(); install() }
        func install() {
            guard let window, let lab, let primeGit, let virtualMachines, let gitWorkspace, let primeRuntime else { return }
            if let heldGuard {
                if window.delegate !== heldGuard { window.delegate = heldGuard }
                return
            }
            let guardObject = AppLifecycleWindowGuard(
                lab: lab, primeGit: primeGit, virtualMachines: virtualMachines,
                gitWorkspace: gitWorkspace, primeRuntime: primeRuntime, previous: window.delegate
            )
            heldGuard = guardObject
            window.delegate = guardObject
        }
    }
}

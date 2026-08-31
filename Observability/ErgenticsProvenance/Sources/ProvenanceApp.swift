import AppKit
import SwiftUI

@main
@MainActor
struct ProvenanceApp: App {
    @NSApplicationDelegateAdaptor(ProvenanceAppDelegate.self) private var delegate
    @StateObject private var model = ProvenanceModel()
    @StateObject private var lab = HypervisorModel()
    var body: some Scene {
        Window("Ergentics Provenance", id: "provenance") {
            ProvenanceView(model: model, lab: lab)
                .frame(minWidth: 920, minHeight: 680)
                .preferredColorScheme(.dark)
                .task {
                    delegate.lab = lab
                    model.inspectHost()
                    lab.startup(admitted: model.admitted)
                }
        }
        .defaultSize(width: 1120, height: 780)
        .commands { CommandGroup(replacing: .newItem) {} }
    }
}

@MainActor
final class ProvenanceAppDelegate: NSObject, NSApplicationDelegate {
    weak var lab: HypervisorModel?
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard lab?.busy == true else { return .terminateNow }
        lab?.cancel()
        let alert = NSAlert()
        alert.messageText = "The guest owner is still finishing"
        alert.informativeText = "Cancellation was requested. Wait for guest exit, teardown and journal completion before quitting. No process signal was sent."
        alert.addButton(withTitle: "Keep app open")
        alert.runModal()
        return .terminateCancel
    }
}

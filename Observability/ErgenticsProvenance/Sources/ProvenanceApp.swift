import AppKit
import SwiftUI

@main
@MainActor
struct ProvenanceApp: App {
    @NSApplicationDelegateAdaptor(ProvenanceAppDelegate.self) private var delegate
    @StateObject private var model = ProvenanceModel()
    var body: some Scene {
        Window("Ergentics Provenance", id: "provenance") {
            ProvenanceView(model: model)
                .frame(minWidth: 920, minHeight: 680)
                .preferredColorScheme(.dark)
                .task { model.inspectHost() }
        }
        .defaultSize(width: 1120, height: 780)
        .commands { CommandGroup(replacing: .newItem) {} }
    }
}

@MainActor
final class ProvenanceAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

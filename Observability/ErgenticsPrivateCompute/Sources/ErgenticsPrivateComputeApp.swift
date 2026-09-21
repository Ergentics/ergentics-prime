import AppKit
import SwiftUI

@main
@MainActor
struct ErgenticsPrivateComputeApp: App {
    @NSApplicationDelegateAdaptor(PrivateComputeAppDelegate.self) private var delegate
    @StateObject private var model = ComputeModel()

    var body: some Scene {
        Window("Ergentics Private Compute", id: "private-compute") {
            WorkspaceView(model: model)
                .frame(minWidth: 950, minHeight: 680)
                .preferredColorScheme(.dark)
                .task { await model.start() }
        }
        .defaultSize(width: 1120, height: 780)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

@MainActor
final class PrivateComputeAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

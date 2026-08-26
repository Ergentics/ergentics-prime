import LedgerProjectionCore
import SwiftUI

@MainActor
private final class InterfaceModel: ObservableObject {
    @Published private(set) var availability: LedgerProjectionAvailability

    init() {
        availability = LedgerProjectionReader.loadDefault()
    }
}

@main
struct ErgenticsInterfaceApp: App {
    @StateObject private var model = InterfaceModel()

    var body: some Scene {
        WindowGroup("Ergentics Ledger Interface") {
            InterfaceShell(availability: model.availability)
        }
        .defaultSize(width: 1_280, height: 820)
        .windowResizability(.contentSize)
    }
}

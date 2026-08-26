import DisposalProjectionCore
import LedgerProjectionCore
import SwiftUI

@MainActor
private final class InterfaceModel: ObservableObject {
    @Published private(set) var availability: LedgerProjectionAvailability
    @Published private(set) var disposalAvailability: DisposalProjectionAvailability

    init() {
        availability = LedgerProjectionReader.loadDefault()
        disposalAvailability = DisposalProjectionReader.loadDefault()
    }
}

@main
struct ErgenticsInterfaceApp: App {
    @StateObject private var model = InterfaceModel()

    var body: some Scene {
        WindowGroup("Ergentics Ledger Interface") {
            InterfaceShell(
                availability: model.availability,
                disposalAvailability: model.disposalAvailability)
        }
        .defaultSize(width: 1_280, height: 820)
        .windowResizability(.contentSize)
    }
}

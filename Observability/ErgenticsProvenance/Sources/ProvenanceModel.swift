import AppKit
import Combine
import Foundation

@MainActor
final class ProvenanceModel: ObservableObject {
    @Published private(set) var admitted = false
    @Published private(set) var signingStatus = "Not inspected"
    @Published private(set) var team = "Not configured"
    @Published private(set) var hypervisor: EPRHypervisorCapabilities?
    @Published private(set) var snapshot: HistoricalSnapshot?
    @Published private(set) var selectedHistory = "No historical directory selected"
    @Published private(set) var repositoryReference = "Not selected"
    @Published private(set) var busy = false
    @Published private(set) var error: String?
    private var inspected = false

    // This model only admits identity/capabilities and explicitly selected history.
    // The separate HypervisorModel owns new development runs and their journal.
    func inspectHost() {
        guard !inspected else { return }
        inspected = true
        guard Bundle.main.bundleIdentifier == "com.ergentics.provenance",
              let expected = Bundle.main.object(forInfoDictionaryKey: "ProvenanceExpectedTeamIdentifier") as? String,
              expected.count == 10, expected.utf8.allSatisfy({ (48...57).contains($0) || (65...90).contains($0) }) else {
            signingStatus = "Developer team must be selected in Xcode"
            return
        }
        team = expected
        var nativeError: Int32 = 0
        let result = expected.withCString { epr_admit_signing($0, &nativeError) }
        guard result == 1 else {
            signingStatus = "Signature / Team / minimal entitlements rejected (\(nativeError))"
            return
        }
        admitted = true
        signingStatus = "Signature, Team and minimal Hypervisor entitlement set admitted"
        hypervisor = epr_hypervisor_capabilities()
    }

    func selectHistory() async {
        guard admitted, !busy else { return }
        let panel = directoryPanel(message: "Select the retained native-static-177403f-r1 directory. Read-only; nothing is copied or changed.")
        guard panel.runModal() == .OK, let url = panel.url else { return }
        snapshot = nil; error = nil; selectedHistory = url.path; busy = true
        defer { busy = false }
        do {
            snapshot = try await Task.detached(priority: .userInitiated) {
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                return try Self.readHistory(url)
            }.value
        } catch { self.error = String(describing: error) }
    }

    func selectRepositoryReference() {
        guard admitted, !busy else { return }
        let panel = directoryPanel(message: "Choose your local ergentics-prime checkout as a reference only. No Git command, enumeration, snapshot, write, or VM mount occurs.")
        guard panel.runModal() == .OK, let url = panel.url else { return }
        repositoryReference = url.path
        // Path label only, deliberately not a source-admission claim or a saved
        // security-scoped bookmark. A later launch starts with no selection.
    }

    private func directoryPanel(message: String) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false; panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false; panel.canCreateDirectories = false
        panel.resolvesAliases = false; panel.message = message
        panel.prompt = "Select read-only"
        return panel
    }

    nonisolated private static func readHistory(_ url: URL) throws -> HistoricalSnapshot {
        var nativeError: Int32 = 0
        guard let held = url.path.withCString({ epr_read_snapshot($0, &nativeError) }) else {
            throw ProvenanceFailure("Read-only descriptor snapshot rejected (\(nativeError))")
        }
        defer { epr_snapshot_free(held) }
        var leaves: [String: Data] = [:]
        for index in 0..<epr_snapshot_count(held) {
            guard let namePointer = epr_snapshot_name(held, index),
                  let name = String(validatingCString: namePointer),
                  let bytes = epr_snapshot_bytes(held, index), leaves[name] == nil else {
                throw ProvenanceFailure("Invalid fixed snapshot entry")
            }
            leaves[name] = Data(bytes: bytes, count: epr_snapshot_size(held, index))
        }
        return try ReceiptVerifier.verify(leaves)
    }
}

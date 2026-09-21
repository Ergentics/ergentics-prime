import AppKit
import Combine
import Foundation

/// Minted only in this file after the native application identity owner has
/// admitted the signed product. It is neither serializable nor constructible by
/// a view or workspace adapter.
struct ProvenanceReadOnlyImportAdmission: Sendable {
    fileprivate init() {}
}

@MainActor
final class ProvenanceModel: ObservableObject {
    @Published private(set) var admitted = false
    @Published private(set) var signingStatus = "Not inspected"
    @Published private(set) var team = "Not configured"
    @Published private(set) var hypervisor: EPRHypervisorCapabilities?
    @Published private(set) var snapshot: HistoricalSnapshot?
    @Published private(set) var selectedHistory = "No historical directory selected"
    @Published private(set) var busy = false
    @Published private(set) var error: String?
    private var inspectionCache = H3QualificationHostInspectionCache()

    var readOnlyImportAdmission: ProvenanceReadOnlyImportAdmission? {
        admitted ? ProvenanceReadOnlyImportAdmission() : nil
    }

    // This model only admits identity/capabilities and explicitly selected history.
    // The separate HypervisorModel owns new development runs and their journal.
    @discardableResult
    func inspectHost(queryHypervisor: Bool = true) async -> ProvenanceHostInspectionResult {
        let expected = Bundle.main.object(forInfoDictionaryKey: "ProvenanceExpectedTeamIdentifier") as? String
        let expectedValid = expected.map { $0.count == 10 && $0.utf8.allSatisfy({ (48...57).contains($0) || (65...90).contains($0) }) } ?? false
        if let cached = inspectionCache.begin(
            bundleIdentifierValid: Bundle.main.bundleIdentifier == "com.ergentics.provenance",
            expectedTeamValid: expectedValid) {
            if case .incomplete = cached { signingStatus = "Developer team must be selected in Xcode" }
            return cached
        }
        guard let expected else {
            signingStatus = "Developer team must be selected in Xcode"
            return .incomplete(reason: .invalidExpectedTeam, nativeResult: nil, nativeError: nil)
        }
        team = expected
        // Native Security/capability getters can block. Do not make the main
        // actor (and therefore the user's Quit command) wait inside those calls.
        let observation = await Task.detached(priority: .userInitiated) {
            var nativeError: Int32 = 0
            let result = expected.withCString { epr_admit_signing($0, &nativeError) }
            let capabilities: H3QualificationCapabilities?
            if result == 1 && nativeError == 0 && queryHypervisor {
                let value = epr_hypervisor_capabilities()
                capabilities = H3QualificationCapabilities(hostSupported: value.host_supported,
                    supportStatus: value.support_status, supportSize: UInt64(value.support_size),
                    supportError: value.support_error, signingAdmitted: value.signing_admitted,
                    signingError: value.signing_error, queriesEntered: value.queries_entered,
                    vcpuStatus: value.vcpu_status, ipaStatus: value.ipa_status,
                    maxVCPUs: value.max_vcpus, maxIPABits: value.max_ipa_bits)
            } else { capabilities = nil }
            return ProvenanceHostInspectionResult.classify(nativeResult: result, nativeError: nativeError,
                queryHypervisor: queryHypervisor, capabilities: capabilities)
        }.value
        do { _ = try inspectionCache.complete(observation) }
        catch { return .incomplete(reason: .missingCachedResult, nativeResult: nil, nativeError: nil) }
        guard case .assessed(_, let nativeError, let status, let capabilities) = observation else {
            signingStatus = "Signature inspection incomplete"
            return observation
        }
        guard status == .admitted else {
            signingStatus = "Signature / Team / minimal entitlements rejected (\(nativeError))"
            return observation
        }
        admitted = true
        signingStatus = "Signature, Team and minimal Hypervisor entitlement set admitted"
        hypervisor = capabilities.map { value in
            EPRHypervisorCapabilities(host_supported: value.hostSupported, support_status: value.supportStatus,
                support_size: Int(value.supportSize), support_error: value.supportError,
                signing_admitted: value.signingAdmitted, signing_error: value.signingError,
                queries_entered: value.queriesEntered, vcpu_status: value.vcpuStatus, ipa_status: value.ipaStatus,
                max_vcpus: value.maxVCPUs, max_ipa_bits: value.maxIPABits)
        }
        return observation
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

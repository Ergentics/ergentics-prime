import AppKit
import Combine
import Foundation

@MainActor
final class PrimeComputeModel: ObservableObject {
    static let shared = PrimeComputeModel()
    @Published var input = PrimeStudyInput()
    @Published var seed = "1618"
    @Published var execution = "guest"
    @Published var points = "[[0,0],[0.5,0.25],[1,1]]"
    @Published var nodes = "[[0,0,1],[1,0,0.5]]"
    @Published var sigma = 0.7
    @Published private(set) var busy = false
    @Published private(set) var status = "Ready"
    @Published private(set) var report: PrimeComputeReport?
    @Published private(set) var failure: String?
    var nativeRunAdmission: () -> Bool = { true }
    private var cancellation: PrimeRuntimeCancellation?
    private var quitPending = false

    @discardableResult func runModel() -> Task<Void,Never>? {
        let input=input, seed=seed, execution=execution
        return launch("Running Prime’s learned model…") { try PrimeComputeBackend.model(input:input,seed:seed,execution:execution,cancellation:$0) }
    }
    @discardableResult func runGeometry() -> Task<Void,Never>? {
        let points=points,nodes=nodes,sigma=sigma,execution=execution
        return launch("Computing the field on Metal…") { try PrimeComputeBackend.geometry(pointsText:points,nodesText:nodes,sigma:sigma,execution:execution,cancellation:$0) }
    }
    private func launch(_ message:String, work:@escaping @Sendable (PrimeRuntimeCancellation) throws -> PrimeComputeReport) -> Task<Void,Never>? {
        guard !busy else { return nil }
        guard nativeRunAdmission() else { failure="Wait for the active VM or hypervisor operation to stop.";return nil }
        let cancel=PrimeRuntimeCancellation();cancellation=cancel
        busy=true;status=message;failure=nil;report=nil
        let worker=Task.detached(priority:.userInitiated) { try work(cancel) }
        return Task { [weak self] in
            let result=await worker.result
            guard let self else {return}
            self.busy=false;self.cancellation=nil
            switch result {
            case .success(let report): self.report=report;self.status="Completed locally · \(report.device)"
            case .failure(let error):
                self.failure=error is CancellationError ? nil : error.localizedDescription
                self.status=error is CancellationError ? "Stopped" : "Run failed"
            }
            if self.quitPending {NSApplication.shared.terminate(nil)}
        }
    }
    func cancel() { cancellation?.cancel();if busy {status="Stopping…"} }
    func requestQuit() -> Bool { guard busy else{return true};quitPending=true;cancel();return false }
    func revealSession() {if let report {NSWorkspace.shared.activateFileViewerSelecting([report.session])}}
    func saveResult() {
        guard let report else{return}
        let panel=NSSavePanel();panel.nameFieldStringValue="Prime-result.json"
        guard panel.runModal() == .OK,let url=panel.url else{return}
        do {try report.rawResult.write(to:url,options:.atomic)} catch {failure=error.localizedDescription}
    }
}

import SwiftUI

struct PrimeRuntimeView: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var model: PrimeRuntimeModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Prime").font(.largeTitle.bold())
                Text("Ergentics’ native model").font(.title3).foregroundStyle(.secondary)
                Text("Ask a question in a separate Prime window, or check the native runtime below.")
                Button("Ask Prime…") { openWindow(id: "prime-question") }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("prime.runtime.ask")
                HStack {
                    Button("Check native runtime") { model.check() }
                        .disabled(model.busy)
                        .accessibilityIdentifier("prime.runtime.check")
                    if model.busy {
                        ProgressView().controlSize(.small)
                        Button("Stop") { model.cancel() }.accessibilityIdentifier("prime.runtime.stop")
                    }
                }
                Text(model.status).font(.headline).accessibilityIdentifier("prime.runtime.status")
                if let failure = model.failure {
                    Text(failure).foregroundStyle(.red).textSelection(.enabled)
                }
                if let report = model.report {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(report.deviceName, systemImage: "cpu")
                        Text("GPU check completed in \(report.elapsedSeconds, specifier: "%.2f") seconds.")
                        Button("Save result…", action: model.saveReport)
                            .accessibilityIdentifier("prime.runtime.save-result")
                        DisclosureGroup("Runtime details") {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Exact FP32 result verified with the bundled Metal library.")
                                Text("Metal library SHA-256").font(.caption).foregroundStyle(.secondary)
                                Text(report.metallibSHA256).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 6)
                        }
                    }
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                }
                Divider()
                Text("Model integration").font(.headline)
                Text("The question window loads the selected saved Prime checkpoint and shows the model’s generated output. The runtime check above only checks GPU initialization.")
                    .foregroundStyle(.secondary)
            }
            .padding(28).frame(maxWidth: 800, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

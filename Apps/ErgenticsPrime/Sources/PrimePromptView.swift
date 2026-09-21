import SwiftUI

struct PrimePromptView: View {
    @ObservedObject var model: PrimePromptModel
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Stage 7 checkpoint experiment").font(.largeTitle.bold())
                    Text("Retained mechanics checkpoint · experimental byte-token generation").foregroundStyle(.secondary)
                }
                Spacer()
                Button(model.checkpointRoot == nil ? "Choose model…" : "Change model…") { model.chooseCheckpoint() }
                    .disabled(model.busy)
                    .accessibilityIdentifier("prime.prompt.choose-model")
            }
            if let root = model.checkpointRoot {
                Label("Native-300M · Stage 7 mechanics checkpoint", systemImage: "externaldrive")
                    .font(.callout).foregroundStyle(.secondary).help(root.path)
                    .accessibilityIdentifier("prime.prompt.model")
            }
            VStack(alignment: .leading, spacing: 7) {
                Text("Question").font(.headline)
                TextEditor(text: $model.question)
                    .font(.system(size: 16))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 96, maxHeight: 140)
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                    .disabled(model.busy)
                    .accessibilityLabel("Question")
                    .accessibilityIdentifier("prime.prompt.question")
            }
            HStack {
                Button("Send to Prime") { model.send() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(model.busy || model.checkpointRoot == nil || model.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("prime.prompt.send")
                if model.busy {
                    ProgressView().controlSize(.small)
                    Button("Stop") { model.cancel() }.accessibilityIdentifier("prime.prompt.stop")
                }
                Spacer()
                Picker("Output limit", selection: $model.maximumNewTokens) {
                    ForEach([16, 32, 64, 128, 256], id: \.self) { value in
                        Text("\(value) tokens").tag(value)
                    }
                }.frame(width: 195).disabled(model.busy)
            }
            Divider()
            Text("Response").font(.headline)
            ScrollView {
                Text(model.output.isEmpty ? "The model’s response will appear here." : model.output)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundStyle(model.output.isEmpty ? .secondary : .primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .accessibilityIdentifier("prime.prompt.response")
            }
            .padding(12)
            .frame(minHeight: 150, maxHeight: .infinity)
            .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
            if let failure = model.failure {
                Text(failure).foregroundStyle(.red).textSelection(.enabled)
                    .accessibilityIdentifier("prime.prompt.error")
            }
            HStack {
                Text(model.status).font(.callout).foregroundStyle(.secondary)
                    .accessibilityIdentifier("prime.prompt.status")
                Spacer()
                if model.report != nil {
                    Button("Save response…") { model.saveResponse() }.disabled(model.busy)
                }
            }
            if let report = model.report {
                DisclosureGroup("Generated token IDs") {
                    Text(report.generatedTokenIDs.map(String.init).joined(separator: ", "))
                        .font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                }
            }
            Text("Questions and responses are saved locally on this Mac. Each question starts a new inference. Reserved symbols and invalid text bytes are shown explicitly.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 620)
        .onDisappear { model.cancel() }
    }
}

struct PrimePromptCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    var body: some Commands {
        CommandMenu("Prime") {
            Button("Stage 7 checkpoint experiment…") { openWindow(id: "prime-question") }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            Button("Show workspace") { openWindow(id: "provenance") }
                .keyboardShortcut("1", modifiers: .command)
        }
    }
}


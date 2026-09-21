import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Full-height local task workspace. Prime's real local experiment is deliberately
/// presented as one bounded runner, separate from profile inspection and exports.
struct ErgenticsAgentsView: View {
    @StateObject private var model: ErgenticsAgentsModel
    @ObservedObject private var prime: PrimePromptModel

    init(model: ErgenticsAgentsModel? = nil, library: ErgenticsAgentLibrary? = nil,
         store: ErgenticsAgentTaskStore? = nil,
         primeModel: PrimePromptModel = .shared) {
        _model = StateObject(wrappedValue: model ?? ErgenticsAgentsModel(library: library,
            store: store, prime: primeModel))
        _prime = ObservedObject(wrappedValue: primeModel)
    }

    var body: some View {
        HSplitView {
            taskSidebar.frame(minWidth: 170, idealWidth: 205, maxWidth: 270)
            workspace.frame(minWidth: 430)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .tint(.teal)
        .accessibilityIdentifier("ergentics.agents.workspace")
    }

    private var taskSidebar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ERGENTICS")
                        .font(.caption.weight(.bold)).tracking(1.6).foregroundStyle(.teal)
                    Text("Saved tasks").font(.headline)
                }
                Spacer()
                Button(action: { _ = model.createTask() }) { Image(systemName: "square.and.pencil") }
                    .buttonStyle(.borderless).help("New local task")
                    .disabled(model.hasOwnedPrimeRun || !model.storageReady)
                    .accessibilityIdentifier("ergentics.agents.new-task")
            }
            .padding(16)
            List(selection: Binding(get: { model.selectedTaskID }, set: model.selectTask)) {
                ForEach(model.tasks) { task in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title).lineLimit(2)
                        Text(task.profileID.replacingOccurrences(of: "ergentics_", with: ""))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(task.id)
                }
            }
            .listStyle(.sidebar)
            .disabled(model.hasOwnedPrimeRun)
            Divider()
            Label("Local task drafts", systemImage: "internaldrive")
                .font(.caption).foregroundStyle(.secondary)
                .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.bar)
    }

    private var workspace: some View {
        VStack(spacing: 0) {
            header
            if let message = model.persistenceError ?? model.libraryError {
                VStack(alignment: .leading, spacing: 6) {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(.orange)
                    if model.persistenceError != nil && !model.hasOwnedPrimeRun {
                        Button("Start a recovered local store", action: model.startRecoveredStore)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 22).padding(.vertical, 8)
            }
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        timeline
                        activity
                        DisclosureGroup(isExpanded: $model.expandedInspector) {
                            inspector.padding(.top, 10)
                        } label: {
                            Label("Profiles and reviewed lessons", systemImage: "books.vertical")
                                .font(.headline)
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: 1_140, alignment: .leading)
                }
                .onChange(of: model.selectedTask?.primeRuns?.last?.output) { _, _ in
                    if let id = model.selectedTask?.primeRuns?.last?.id {
                        proxy.scrollTo("prime-output-\(id)", anchor: .bottom)
                    }
                }
            }
            Divider()
            composer.padding(20)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "text.bubble.fill")
                .font(.title2).foregroundStyle(.teal).padding(10)
                .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 5) {
                Text(model.selectedTask?.title ?? "Ergentics Agents").font(.title2.weight(.semibold))
                Text("Ergentics Prime · local experiment")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Export task…", action: model.exportPreparedTask)
                .disabled(model.selectedTask == nil)
                .accessibilityIdentifier("ergentics.agents.export")
        }
        .padding(22)
    }

    @ViewBuilder private var timeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Conversation", systemImage: "bubble.left.and.bubble.right")
                .font(.headline)
            Text("Messages and Prime responses are saved on this Mac.")
                .font(.caption).foregroundStyle(.secondary)
            if let task = model.selectedTask, task.messages.isEmpty, (task.primeRuns ?? []).isEmpty {
                ContentUnavailableView("Start a local task", systemImage: "text.cursor",
                    description: Text("Write a message to Ergentics Prime. Open Profiles and reviewed lessons to prepare a separate agent task."))
                    .frame(maxWidth: .infinity).padding(.vertical, 30)
            }
            ForEach(model.selectedTask?.messages ?? []) { message in
                HStack {
                    Spacer(minLength: 80)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        Text(message.text).textSelection(.enabled)
                    }
                    .padding(14).frame(maxWidth: 620, alignment: .leading)
                    .background(.teal.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.teal.opacity(0.25)))
                }
                ForEach((model.selectedTask?.primeRuns ?? []).filter { $0.userMessageID == message.id }) { run in
                    primeResponse(run)
                }
            }
            ForEach((model.selectedTask?.primeRuns ?? []).filter { $0.userMessageID == nil }) { run in
                primeResponse(run)
            }
        }
    }

    private func primeResponse(_ run: ErgenticsAgentPrimeRun) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ergentics Prime · local experiment", systemImage: "cpu")
                .font(.caption.weight(.semibold)).foregroundStyle(.teal)
            Text(run.output.isEmpty ? run.status : run.output).textSelection(.enabled)
                .frame(maxWidth: 760, alignment: .leading)
            if !run.output.isEmpty {
                Text(run.status).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(16).background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 16))
        .id("prime-output-\(run.id)")
    }

    private var activity: some View {
        DisclosureGroup(isExpanded: $model.expandedActivity) {
            VStack(alignment: .leading, spacing: 10) {
                activityRow("Prime status", value: model.ownedPrimeStatus ?? "No Prime run is owned by this task.", icon: model.hasOwnedPrimeRun ? "arrow.triangle.2.circlepath" : "checkmark.circle")
                activityRow("Input boundary", value: "Canonical request: at most 1,023 UTF-8 bytes · output: \(prime.maximumNewTokens) tokens", icon: "ruler")
                activityRow("Execution", value: model.hasOwnedPrimeRun ? "This task owns the local experiment; switching tasks is paused until it finishes." : "No automatic generation. Send starts the retained local experiment.", icon: "hand.raised")
                if let run = model.selectedTask?.primeRuns?.last, let seconds = run.elapsedSeconds {
                    activityRow("Checkpoint evidence", value: "\(run.generatedTokens ?? 0) tokens · \(String(format: "%.1f", seconds)) seconds", icon: "doc.badge.checkmark")
                }
                if let run = model.selectedTask?.primeRuns?.last, run.outcome == .failed {
                    activityRow("Actual failure", value: run.status, icon: "exclamationmark.triangle", tint: .red)
                }
            }
            .padding(.top, 10)
        } label: {
            Label("Actual activity", systemImage: "waveform.path.ecg")
                .font(.headline)
        }
        .padding(16).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func activityRow(_ title: String, value: String, icon: String, tint: Color = .teal) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(tint).frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text(value).font(.callout).textSelection(.enabled)
            }
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Profile and lesson inspector", systemImage: "books.vertical")
                    .font(.headline)
                Spacer()
                Text(model.library == nil ? "Catalog unavailable" : "Verified catalog loaded")
                    .font(.caption).foregroundStyle(model.library == nil ? .orange : .teal)
            }
            if let task = model.selectedTask {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Profile").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        Picker("Profile", selection: Binding(get: { task.profileID }, set: { value in
                            model.updateTask { $0.profileID = value; $0.selectedLessonIDs = [] }
                        })) {
                            if model.profiles.isEmpty { Text(task.profileID).tag(task.profileID) }
                            ForEach(model.profiles) { profile in Text(profile.name).tag(profile.id) }
                        }
                        .labelsHidden().frame(maxWidth: 280)
                        if let profile = model.selectedProfile {
                            Text("v\(profile.version) · \(profile.purpose)").font(.caption).foregroundStyle(.secondary)
                        } else {
                            Text("The profile catalog must load before its verified instructions can be inspected or exported.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Requested model label").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextField("Requested model", text: Binding(get: { task.requestedModel }, set: { value in
                            model.updateTask { $0.requestedModel = String(value.prefix(128)) }
                        }))
                        .textFieldStyle(.roundedBorder).frame(maxWidth: 300)
                        Text("A requested label is not evidence of a serving model. Prime remains a separate local experiment.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            if !model.eligibleLessons.isEmpty {
                    Divider()
                    Text("Eligible reviewed lessons").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    ForEach(model.eligibleLessons) { lesson in
                        Toggle(isOn: Binding(get: { task.selectedLessonIDs.contains(lesson.id) }, set: { _ in model.toggleLesson(lesson) })) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lesson.name)
                                Text("\(lesson.id) · v\(lesson.version) · \(lesson.kind)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        DisclosureGroup("Read reviewed lesson") {
                            if let text = model.instructionText(lesson.path) {
                                ScrollView {
                                    Text(text).font(.system(.caption, design: .monospaced))
                                        .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(height: 220)
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            if let profile = model.selectedProfile {
                DisclosureGroup(isExpanded: $model.expandedDefinitions) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(profile.instructionPaths + profile.skillPaths, id: \.self) { path in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(path).font(.caption.weight(.semibold)).textSelection(.enabled)
                                if let text = model.instructionText(path) {
                                    ScrollView {
                                        Text(text).font(.system(.caption, design: .monospaced))
                                            .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                                    }.frame(height: 220)
                                }
                            }
                        }
                    }.padding(.top, 8)
                } label: {
                    Label("Verified instruction and skill text", systemImage: "doc.text.magnifyingglass")
                        .font(.caption.weight(.semibold))
                }
            }
            if let status = model.exportStatus ?? model.persistenceError ?? model.libraryError {
                Label(status, systemImage: "info.circle").font(.caption).foregroundStyle(.secondary)
            }
            Text("Exports prepare a bounded task JSON with selected verified resources. They do not execute profiles, lessons, or any model.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Message to Ergentics Prime", systemImage: "paperplane")
                    .font(.headline)
                Spacer()
                Picker("Tokens", selection: $prime.maximumNewTokens) {
                    ForEach([16, 32, 64, 128, 256], id: \.self) { Text("\($0) tokens").tag($0) }
                }.labelsHidden().frame(width: 115).disabled(prime.busy)
            }
            HStack {
                Text(prime.checkpointRoot == nil ? "Choose a local model to begin." : "Local model selected")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button(prime.checkpointRoot == nil ? "Choose model…" : "Change model…", action: prime.chooseCheckpoint)
                    .font(.caption).disabled(prime.busy)
                    .accessibilityIdentifier("ergentics.agents.choose-model")
            }
            TextEditor(text: Binding(get: { model.composerText }, set: model.setComposer))
                .font(.body).frame(minHeight: 66, maxHeight: 110)
                .scrollContentBackground(.hidden).padding(8)
                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))
                .disabled(prime.busy || model.hasOwnedPrimeRun || !model.storageReady)
                .accessibilityIdentifier("ergentics.agents.composer")
            Text("Current message only · no conversation history is sent to Prime.")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Spacer()
                if model.hasOwnedPrimeRun {
                    ProgressView().controlSize(.small)
                    Button("Stop", action: model.stopPrime).accessibilityIdentifier("ergentics.agents.stop")
                } else {
                    Button("Save local draft", action: model.saveLocalDraft)
                        .disabled(model.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !model.storageReady)
                    Button("Send to Ergentics Prime", action: model.sendToPrime)
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: .command)
                        .disabled(model.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || prime.busy || !model.storageReady || prime.checkpointRoot == nil)
                        .accessibilityIdentifier("ergentics.agents.send")
                }
            }
            if let status = model.exportStatus {
                Text(status).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
            }
        }
    }
}

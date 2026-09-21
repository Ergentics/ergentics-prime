import AppKit
import Combine
import SwiftUI

@MainActor
final class GitWorkspaceModel: ObservableObject {
    @Published private(set) var snapshot: GitWorkspaceSnapshot?
    @Published private(set) var busy = false
    @Published private(set) var error: String?
    @Published private(set) var activity = "Choose a local repository"
    @Published private(set) var diffText = "Select a changed file or commit."
    @Published private(set) var selectedChange: GitWorkspaceChange?
    @Published private(set) var selectedCommit: GitWorkspaceCommit?
    @Published var stagedDiff = false
    @Published var commitMessage = ""
    @Published var authorName = ""
    @Published var authorEmail = ""
    private var selectedURL: URL?
    private var scopeStarted = false
    private var cancellation: GitWorkspaceCancellation?
    private var quitRequested = false

    func chooseRepository() {
        guard !busy, !quitRequested else { return }
        let panel = NSOpenPanel()
        panel.title = "Choose a Git repository"
        panel.message = "Choose the repository’s top folder. Changes are written only when you select Stage, Unstage or Commit."
        panel.canChooseDirectories = true; panel.canChooseFiles = false; panel.allowsMultipleSelection = false
        panel.prompt = "Open repository"
        guard panel.runModal() == .OK, !quitRequested, let url = panel.url else { return }
        if scopeStarted { selectedURL?.stopAccessingSecurityScopedResource() }
        scopeStarted = url.startAccessingSecurityScopedResource()
        selectedURL = url; snapshot = nil; selectedChange = nil; selectedCommit = nil
        authorName = ""; authorEmail = ""
        diffText = "Select a changed file or commit."
        refresh()
    }

    func refresh() {
        guard let url = selectedURL else { return }
        perform("Reading repository…", operation: { try GitWorkspaceBackend.snapshot(root: url, cancellation: $0) }) { [weak self] value in
            self?.install(value)
        }
    }

    func select(_ change: GitWorkspaceChange, staged: Bool? = nil) {
        guard !busy, let root = snapshot?.root else { return }
        selectedChange = change; selectedCommit = nil
        stagedDiff = staged ?? (change.staged && !change.unstaged)
        let cached = stagedDiff
        perform("Reading diff…", operation: { try GitWorkspaceBackend.diff(root: root, change: change, staged: cached, cancellation: $0) }) { [weak self] text in
            self?.diffText = text.isEmpty ? "No changes in this view." : text
        }
    }

    func select(_ commit: GitWorkspaceCommit) {
        guard !busy, let root = snapshot?.root else { return }
        selectedCommit = commit; selectedChange = nil
        perform("Reading commit…", operation: { try GitWorkspaceBackend.commitDiff(root: root, commit: commit, cancellation: $0) }) { [weak self] text in
            self?.diffText = text
        }
    }

    func stage() { if let selectedChange { edit(.stage(selectedChange), label: "Staging file…") } }
    func unstage() { if let selectedChange { edit(.unstage(selectedChange), label: "Unstaging file…") } }
    func commit() { edit(.commit(commitMessage, authorName, authorEmail), label: "Committing staged changes…") }
    private func edit(_ action: GitWorkspaceBackend.Edit, label: String) {
        guard let root = snapshot?.root else { return }
        perform(label, operation: { try GitWorkspaceBackend.edit(root: root, action: action, cancellation: $0) }) { [weak self] value in
            self?.install(value)
            if case .commit = action { self?.commitMessage = "" }
        }
    }

    private func install(_ value: GitWorkspaceSnapshot) {
        snapshot = value; selectedChange = nil; selectedCommit = nil
        diffText = "Select a changed file or commit."
        if authorName.isEmpty { authorName = value.authorName }
        if authorEmail.isEmpty { authorEmail = value.authorEmail }
    }

    private func perform<T: Sendable>(_ label: String,
        operation: @escaping @Sendable (GitWorkspaceCancellation) throws -> T,
        success: @escaping @MainActor (T) -> Void) {
        guard !busy, !quitRequested else { return }
        let token = GitWorkspaceCancellation()
        cancellation = token; busy = true; error = nil; activity = label
        Task { [weak self] in
            let result = await Task.detached(priority: .userInitiated) { Result { try operation(token) } }.value
            guard let self else { return }
            switch result {
            case .success(let value): success(value); activity = "Ready"
            case .failure(let failure): error = failure.localizedDescription; activity = "Git operation stopped"
            }
            busy = false; cancellation = nil
        }
    }

    func cancel() { cancellation?.cancel(); if busy { activity = "Canceling Git…" } }
    func requestQuit() -> Bool {
        quitRequested = true
        if busy { cancel(); return false }
        return true
    }
}

struct GitWorkspaceView: View {
    @ObservedObject var model: GitWorkspaceModel
    let admitted: Bool
    @State private var section = "Changes"
    private var writesAllowed: Bool { admitted && !model.busy && model.snapshot?.writeBlock == nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Git workspace").font(.largeTitle.bold())
                    Text(model.snapshot?.root.path ?? "Open a repository to review and commit local changes.")
                        .font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                }
                Spacer()
                Button("Open repository…", action: model.chooseRepository).disabled(!admitted || model.busy)
                    .accessibilityIdentifier("git-open-repository")
                Button("Refresh", systemImage: "arrow.clockwise", action: model.refresh)
                    .disabled(!admitted || model.busy || model.snapshot == nil)
                if model.busy { Button("Cancel", action: model.cancel) }
            }
            if let error = model.error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            if let snapshot = model.snapshot {
                HStack {
                    Label(snapshot.branch, systemImage: "arrow.triangle.branch")
                    Text(snapshot.head.map { String($0.prefix(10)) } ?? "No commits yet").font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(snapshot.changes.count) changed files")
                    if model.busy { ProgressView().controlSize(.small) }
                    Text(model.activity).foregroundStyle(.secondary)
                }
                if let block = snapshot.writeBlock { Text(block).font(.callout).foregroundStyle(.orange) }
                HSplitView {
                    VStack(alignment: .leading) {
                        Picker("Repository list", selection: $section) { Text("Changes").tag("Changes"); Text("History").tag("History") }.pickerStyle(.segmented)
                        if section == "Changes" {
                            if snapshot.changes.isEmpty { ContentUnavailableView("Working tree clean", systemImage: "checkmark.circle") }
                            else {
                                List(snapshot.changes) { change in
                                    Button { model.select(change) } label: {
                                        HStack(alignment: .top) {
                                            Text(change.code).font(.system(.caption, design: .monospaced)).frame(width: 25)
                                            Text(verbatim: change.label).lineLimit(3).frame(maxWidth: .infinity, alignment: .leading)
                                        }.padding(.vertical, 3).contentShape(Rectangle())
                                    }.buttonStyle(.plain).disabled(model.busy)
                                        .listRowBackground(model.selectedChange?.id == change.id ? Color.accentColor.opacity(0.15) : Color.clear)
                                }
                            }
                        } else {
                            if snapshot.history.isEmpty { ContentUnavailableView("No commits yet", systemImage: "clock") }
                            else {
                                List(snapshot.history) { commit in
                                    Button { model.select(commit) } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(verbatim: commit.subject).lineLimit(2)
                                            Text("\(commit.id.prefix(8)) · \(commit.author)").font(.caption).foregroundStyle(.secondary)
                                            Text(commit.date).font(.caption2).foregroundStyle(.secondary)
                                        }.padding(.vertical, 3).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                                    }.buttonStyle(.plain).disabled(model.busy)
                                }
                            }
                        }
                    }.frame(minWidth: 240, idealWidth: 300, maxWidth: 400)
                    VStack(alignment: .leading, spacing: 8) {
                        if let change = model.selectedChange {
                            Text(verbatim: change.label).font(.headline).textSelection(.enabled)
                            HStack {
                                Picker("Diff", selection: $model.stagedDiff) { Text("Unstaged").tag(false); Text("Staged").tag(true) }
                                    .pickerStyle(.segmented).frame(maxWidth: 240).disabled(model.busy)
                                    .onChange(of: model.stagedDiff) { _, value in if !model.busy { model.select(change, staged: value) } }
                                Spacer()
                                Button("Stage file", action: model.stage).disabled(!writesAllowed || !change.unstaged)
                                Button("Unstage file", action: model.unstage).disabled(!writesAllowed || !change.staged)
                            }
                        } else if let commit = model.selectedCommit { Text("Commit \(commit.id.prefix(10))").font(.headline) }
                        ScrollView([.horizontal, .vertical]) {
                            Text(verbatim: model.diffText).font(.system(.body, design: .monospaced))
                                .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .topLeading).padding(12)
                        }.background(.quaternary.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 8))
                    }.frame(minWidth: 360, maxWidth: .infinity, maxHeight: .infinity)
                }
                Divider()
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading) {
                        TextField("Commit message", text: $model.commitMessage, axis: .vertical).lineLimit(2...4)
                        Text("Commits include staged changes. Hooks, signing helpers and automatic maintenance do not run here.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    VStack { TextField("Author name", text: $model.authorName); TextField("Author email", text: $model.authorEmail) }.frame(width: 210)
                    Button("Commit staged", action: model.commit).buttonStyle(.borderedProminent)
                        .disabled(!writesAllowed || !snapshot.changes.contains(where: \.staged) || model.commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.textFieldStyle(.roundedBorder).disabled(model.busy)
            } else {
                ContentUnavailableView("Choose a Git repository", systemImage: "arrow.triangle.branch",
                    description: Text("Review changed files and commit history, stage changes and create local commits."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.padding(20).frame(minWidth: 850, minHeight: 580)
    }
}

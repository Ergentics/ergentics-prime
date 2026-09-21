import AppKit
import SwiftUI
import Virtualization

struct VMWorkspaceView: View {
    @ObservedObject var model: VMWorkspaceModel
    let admitted: Bool
    @State private var showingSetup = false
    @State private var confirmStop = false
    @State private var confirmFreshStart = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Virtual machines").font(.largeTitle.bold())
                        Text("Install and run ARM64 Linux in a private workspace.")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Show files", systemImage: "folder") { model.showFiles() }
                        .disabled(model.storageDirectory == nil)
                    Button("Refresh", systemImage: "arrow.clockwise") { model.refresh() }
                        .disabled(!model.canChangeWorkspace)
                }
                if !admitted {
                    Label("This app's signing check must pass before a VM can be created or started.", systemImage: "lock")
                        .foregroundStyle(.orange)
                }
                HStack(alignment: .top, spacing: 20) {
                    workspaceList.frame(width: 220)
                    VStack(alignment: .leading, spacing: 16) {
                        if let workspace = model.selectedWorkspace { selectedWorkspace(workspace) }
                        if model.workspaces.isEmpty || showingSetup { setupForm }
                        if !model.workspaces.isEmpty && !showingSetup {
                            Button("Create another VM…", systemImage: "plus") { showingSetup = true }
                                .disabled(!model.canChangeWorkspace)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                statusView
                if let machine = model.virtualMachine {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Guest display").font(.headline)
                            Spacer()
                            Text("\(model.phase.rawValue) · Offline").foregroundStyle(.secondary)
                        }
                        VMWorkspaceDisplay(machine: machine)
                            .frame(minHeight: 360, idealHeight: 540)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Click the guest display to use its keyboard and mouse. macOS system shortcuts remain available.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                if !model.warnings.isEmpty {
                    DisclosureGroup("Workspace notices (\(model.warnings.count))") {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(model.warnings.enumerated()), id: \.offset) { _, warning in
                                Text(warning).font(.caption).textSelection(.enabled)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 6)
                    }
                }
            }.padding(24)
        }
        .task { model.refresh() }
        .confirmationDialog("Stop this VM immediately?", isPresented: $confirmStop) {
            Button("Stop now", role: .destructive) { model.stopNow() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The VM's disk is kept, but unsaved guest work may be lost. Use Shut down for a normal guest shutdown.")
        }
        .confirmationDialog("Start from disk instead of restoring?", isPresented: $confirmFreshStart) {
            Button("Start from disk") { model.start(admitted: admitted, fresh: true) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This begins a new session. The previous suspended file is retained, but it can no longer be restored after the disk changes.")
        }
    }

    private var workspaceList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your VMs").font(.headline)
            if model.workspaces.isEmpty {
                Text("No VMs yet. Choose a local Linux installer to create your first one.")
                    .foregroundStyle(.secondary).font(.callout)
            }
            ForEach(model.workspaces) { workspace in
                Button { model.select(workspace.id) } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "desktopcomputer")
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workspace.name).fontWeight(.medium).lineLimit(2)
                            Text(workspace.suspendedState == nil ? "Linux · Offline" : "Linux · Suspended")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(model.selectedID == workspace.id ? Color.accentColor.opacity(0.12) : .clear,
                                in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!model.canChangeWorkspace)
            }
        }
    }

    private func selectedWorkspace(_ workspace: VMWorkspace) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(workspace.name).font(.title2.bold())
                    Spacer()
                    Text(model.phase.rawValue).font(.callout).foregroundStyle(.secondary)
                }
                Text(workspace.resourceSummary).foregroundStyle(.secondary)
                Text("Offline. No shared host folders, clipboard, microphone, or camera.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    if workspace.suspendedState != nil && !model.hasActiveMachine {
                        Button("Restore session", systemImage: "play.fill") { model.restore(admitted: admitted) }
                            .buttonStyle(.borderedProminent).disabled(!admitted || !model.canStart)
                        Button("Start from disk…") { confirmFreshStart = true }
                            .disabled(!admitted || !model.canStart)
                    } else {
                        Button("Start", systemImage: "play.fill") { model.start(admitted: admitted) }
                            .buttonStyle(.borderedProminent).disabled(!admitted || !model.canStart)
                    }
                    if model.canResume {
                        Button("Resume", systemImage: "play") { model.resume() }
                    } else {
                        Button("Pause", systemImage: "pause") { model.pause() }.disabled(!model.canPause)
                    }
                    Button("Suspend", systemImage: "moon") { model.suspend() }.disabled(!model.canSuspend)
                    Button("Shut down", systemImage: "power") { model.shutDown() }.disabled(!model.canShutDown)
                    Button("Stop now…") { confirmStop = true }.disabled(!model.canForceStop)
                }
                .controlSize(.small)
                Toggle("Attach installer on next start", isOn: Binding(
                    get: { workspace.installerAttached }, set: { model.setInstallerAttached($0) }))
                    .disabled(!admitted || !model.canChangeWorkspace || workspace.suspendedState != nil)
                Text("After Linux is installed, shut it down and detach the installer to boot from the VM disk.")
                    .font(.caption).foregroundStyle(.secondary)
                if let reason = model.suspendUnavailableReason {
                    Text("Suspend is unavailable for this configuration: \(reason)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                DisclosureGroup("Installer and storage") {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Installer: \(workspace.installerName)")
                        Text("SHA-256: \(workspace.installerSHA256)").font(.system(.caption, design: .monospaced))
                        Text("The disk grows as the guest writes, up to \(workspace.diskGiB) GB. Imported media and saved sessions also use local storage.")
                        Text("Suspend files are tied to this Mac and may become incompatible after a macOS update. They are not backups of the VM disk.")
                    }.font(.caption).foregroundStyle(.secondary).textSelection(.enabled).padding(.top, 4)
                }
            }.padding(8).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var setupForm: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Create a Linux VM").font(.title3.bold())
                Text("Choose an ARM64/aarch64 UEFI installer ISO from this Mac. The app copies it into a new private VM folder and creates an empty disk; nothing boots until you press Start.")
                    .font(.callout).foregroundStyle(.secondary)
                TextField("VM name", text: $model.setup.name)
                    .textFieldStyle(.roundedBorder)
                HStack(spacing: 24) {
                    Stepper("CPUs: \(model.setup.cpuCount)", value: $model.setup.cpuCount, in: 1...8)
                    Stepper("Memory: \(model.setup.memoryGiB) GB", value: $model.setup.memoryGiB, in: 2...16)
                }
                Stepper("Maximum disk size: \(model.setup.diskGiB) GB", value: $model.setup.diskGiB, in: 16...128, step: 16)
                HStack {
                    Button("Choose installer and create…", systemImage: "opticaldiscdrive") {
                        model.createWorkspace(admitted: admitted)
                    }.buttonStyle(.borderedProminent)
                    if !model.workspaces.isEmpty {
                        Button("Cancel setup") { showingSetup = false }
                    }
                }
            }.disabled(!admitted || !model.canChangeWorkspace)
                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if model.isBusy && !model.isImporting { ProgressView().controlSize(.small) }
                Text(model.status).textSelection(.enabled)
            }
            if model.isImporting {
                ProgressView(value: model.importProgress)
                HStack {
                    Text("\(Int(model.importProgress * 100))% imported").font(.caption)
                    Spacer()
                    Button("Cancel import") { model.cancelImport() }
                }
            }
            if let error = model.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange).textSelection(.enabled)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
private struct VMWorkspaceDisplay: NSViewRepresentable {
    let machine: VZVirtualMachine
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.virtualMachine = machine
        view.capturesSystemKeys = false
        view.automaticallyReconfiguresDisplay = true
        return view
    }
    func updateNSView(_ view: VZVirtualMachineView, context: Context) {
        if view.virtualMachine !== machine { view.virtualMachine = machine }
    }
    static func dismantleNSView(_ view: VZVirtualMachineView, coordinator: ()) {
        // Removing this view does not stop the VM. The app model owns it.
        view.virtualMachine = nil
    }
}

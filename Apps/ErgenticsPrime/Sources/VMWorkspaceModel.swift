import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers
import Virtualization

@MainActor
final class VMWorkspaceModel: NSObject, ObservableObject, @preconcurrency VZVirtualMachineDelegate {
    @Published var setup = VMWorkspaceSetup()
    @Published private(set) var workspaces: [VMWorkspace] = []
    @Published private(set) var selectedID: UUID?
    @Published private(set) var virtualMachine: VZVirtualMachine?
    @Published private(set) var isBusy = false
    @Published private(set) var isImporting = false
    @Published private(set) var importProgress = 0.0
    @Published private(set) var status = "Choose an existing VM or create one from an ARM64 Linux installer."
    @Published private(set) var errorMessage: String?
    @Published private(set) var warnings: [String] = []
    @Published private(set) var supportsSuspend = false
    @Published private(set) var suspendUnavailableReason: String?
    @Published private(set) var phase: Phase = .stopped

    enum Phase: String { case stopped = "Stopped", running = "Running", paused = "Paused", suspended = "Suspended" }

    /// Checked synchronously before start/restore claims isBusy.
    var nativeRunAdmission: @MainActor () -> Bool = { true }

    private var store: VMWorkspaceStore?
    private var lease: VMWorkspaceLease?
    private var operation: Task<Void, Never>?
    private var importWorker: Task<VMWorkspace, Error>?
    private var quitRequested = false
    private var immediateStopRequested = false
    private var shutdownAlreadyRequested = false

    var selectedWorkspace: VMWorkspace? { workspaces.first { $0.id == selectedID } }
    var hasActiveMachine: Bool {
        guard let machine = virtualMachine else { return false }
        return machine.state != .stopped && machine.state != .error
    }
    var isActive: Bool { hasActiveMachine || isBusy || isImporting }
    var busy: Bool { isBusy }
    var canChangeWorkspace: Bool { !isBusy && !hasActiveMachine && !quitRequested }

    /// Returns true only when the VM worker has stopped. The application's
    /// existing Quit Now/fallback remains responsible for its finite exit.
    @discardableResult
    func requestQuit() -> Bool {
        quitRequested = true
        importWorker?.cancel()
        if isImporting { operation?.cancel() }
        if isBusy { return false }
        guard hasActiveMachine, let machine = virtualMachine else { return true }
        if machine.canRequestStop && !shutdownAlreadyRequested {
            do {
                try machine.requestStop()
                shutdownAlreadyRequested = true
                status = "Waiting for the guest to shut down. Quit Now remains available."
            } catch { report(error) }
        } else if machine.canStop && !machine.canRequestStop && !shutdownAlreadyRequested {
            shutdownAlreadyRequested = true
            stopNow()
        }
        return false
    }

    /// Called by the app's cancellation/termination policy. It never signals
    /// another process or extends the application's existing exit deadline.
    func cancelAndStop() {
        quitRequested = true
        immediateStopRequested = true
        importWorker?.cancel()
        if isImporting { operation?.cancel() }
        guard !isBusy else { return }
        immediateStopRequested = false
        if virtualMachine?.canStop == true { stopNow() }
    }
    var canStart: Bool { selectedWorkspace != nil && canChangeWorkspace && nativeRunAdmission() }
    var canPause: Bool { !isBusy && virtualMachine?.canPause == true }
    var canResume: Bool { !isBusy && nativeRunAdmission() && virtualMachine?.canResume == true }
    var canShutDown: Bool { !isBusy && virtualMachine?.canRequestStop == true }
    var canForceStop: Bool { !isBusy && virtualMachine?.canStop == true }
    var canSuspend: Bool {
        !isBusy && supportsSuspend && (virtualMachine?.canPause == true || virtualMachine?.canResume == true)
    }
    var storageDirectory: URL? { store?.root }

    /// Called when the VM page is opened. It never starts or restores a VM.
    func refresh() {
        guard canChangeWorkspace else { return }
        do {
            let store = try self.store ?? VMWorkspaceStore()
            self.store = store
            let listing = try store.list()
            workspaces = listing.workspaces
            warnings = listing.warnings
            if selectedID == nil || !workspaces.contains(where: { $0.id == selectedID }) {
                selectedID = workspaces.first?.id
            }
            phase = selectedWorkspace?.suspendedState == nil ? .stopped : .suspended
        } catch { errorMessage = error.localizedDescription }
    }

    func select(_ id: UUID) {
        guard canChangeWorkspace, workspaces.contains(where: { $0.id == id }) else { return }
        virtualMachine = nil
        lease = nil
        selectedID = id
        errorMessage = nil
        supportsSuspend = false
        suspendUnavailableReason = nil
        phase = selectedWorkspace?.suspendedState == nil ? .stopped : .suspended
        status = phase == .suspended ? "A suspended session is ready to restore on this Mac." : "Ready to start."
    }

    func createWorkspace(admitted: Bool) {
        guard admitted, canChangeWorkspace else { return }
        do { try setup.validate() }
        catch { errorMessage = error.localizedDescription; return }
        let panel = NSOpenPanel()
        panel.title = "Choose an ARM64 Linux installer"
        panel.message = "The selected ISO will be copied into this VM's private folder. Choose an ARM64/aarch64 UEFI installer."
        panel.allowedContentTypes = [UTType(filenameExtension: "iso") ?? .diskImage]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "Create VM"
        guard panel.runModal() == .OK, canChangeWorkspace, let source = panel.url else { return }
        let scoped = source.startAccessingSecurityScopedResource()
        let setup = self.setup
        let identity = VZGenericMachineIdentifier().dataRepresentation
        isImporting = true
        importProgress = 0
        beginOperation("Importing installer and creating the VM disk…", recordErrors: false) { [weak self] in
            guard let self else { return }
            defer {
                if scoped { source.stopAccessingSecurityScopedResource() }
                self.isImporting = false
                self.importWorker = nil
            }
            try Task.checkCancellation()
            let store = try self.store ?? VMWorkspaceStore()
            self.store = store
            let model = self
            let worker = Task.detached(priority: .userInitiated) {
                try store.prepare(setup: setup, iso: source, machineIdentifier: identity) { value in
                    Task { @MainActor in model.importProgress = value }
                }
            }
            self.importWorker = worker
            let workspace = try await withTaskCancellationHandler {
                try await worker.value
            } onCancel: {
                worker.cancel()
            }
            try Task.checkCancellation()
            _ = try VZEFIVariableStore(creatingVariableStoreAt: store.efiURL(for: workspace.id))
            guard chmod(store.efiURL(for: workspace.id).path, 0o600) == 0 else {
                throw VMWorkspaceFailure("Could not make EFI storage private. The new VM files have been retained.")
            }
            try store.save(workspace)

            self.workspaces.insert(workspace, at: 0)
            self.selectedID = workspace.id
            self.phase = .stopped
            self.status = "VM created. Start it to run the installer."
            self.note("Created from selected installer; no VM start requested.")
        }
    }

    func cancelImport() {
        guard isImporting else { return }
        importWorker?.cancel()
        if isImporting { operation?.cancel() }
        status = "Cancelling import… Partial files will be kept."
    }

    /// A cold start explicitly abandons the active suspend reference before
    /// writable guest disks are opened. Old state files remain on disk.
    func start(admitted: Bool, fresh: Bool = false) {
        guard admitted, canStart, let selected = selectedWorkspace else { return }
        guard selected.suspendedState == nil || fresh else {
            errorMessage = "Restore the suspended session, or choose Start from disk."
            return
        }
        beginOperation("Starting VM…") { [weak self] in
            guard let self else { return }
            let store = try self.requiredStore()
            let acquired = try store.acquire(selected.id)
            var workspace = acquired.workspace
            let lease = acquired.lease
            self.replace(workspace)
            if workspace.suspendedState != nil {
                guard fresh else { throw VMWorkspaceFailure("A suspended session was saved since this view was loaded. Refresh and restore it, or explicitly start from disk.") }
                workspace.suspendedState = nil
                workspace.suspendedFiles = nil
                try store.save(workspace)
                self.replace(workspace)
                try store.record("Start from disk requested; previous suspended state retained but no longer eligible for restore.", workspace: workspace)
            }
            let machine = try self.makeMachine(workspace, store: store)
            self.lease = lease
            self.virtualMachine = machine
            do { try await machine.start() }
            catch {
                self.releaseIfStopped()
                throw error
            }
            try self.requireCurrent(machine, state: .running)
            self.phase = .running
            self.status = workspace.installerAttached ? "VM running with installer attached." : "VM running from its disk."
            self.note("Started; offline; installer attached: \(workspace.installerAttached).")
        }
    }

    func pause() {
        guard canPause, let machine = virtualMachine else { return }
        beginOperation("Pausing VM…") { [weak self] in
            try await machine.pause()
            try self?.requireCurrent(machine, state: .paused)
            self?.phase = .paused
            self?.status = "Paused. Memory remains in this app until resumed, suspended, or stopped."
            self?.note("Paused.")
        }
    }

    func resume() {
        guard canResume, let machine = virtualMachine else { return }
        beginOperation("Resuming VM…") { [weak self] in
            guard let self else { return }
            try self.consumeSuspendedReference()
            try await machine.resume()
            try self.requireCurrent(machine, state: .running)
            self.phase = .running
            self.status = "VM running."
            self.note("Resumed.")
        }
    }

    func shutDown() {
        guard canShutDown, let machine = virtualMachine else { return }
        do {
            try machine.requestStop()
            status = "Shutdown requested. If the guest does not respond, Stop now remains available."
            note("Graceful guest shutdown requested.")
        } catch { report(error) }
    }

    /// Explicit UI action. Unlike a guest shutdown, this can lose unsaved
    /// guest work, so the view confirms it when the machine is running.
    func stopNow() {
        guard canForceStop, let machine = virtualMachine else { return }
        shutdownAlreadyRequested = true
        beginOperation("Stopping VM…") { [weak self] in
            try await machine.stop()
            self?.finishedStopping(message: "VM stopped. Its disk is retained.")
            self?.note("Stopped immediately by user request.")
        }
    }

    func suspend() {
        guard canSuspend, let machine = virtualMachine, let selected = selectedWorkspace else { return }
        beginOperation("Saving suspended session…") { [weak self] in
            guard let self else { return }
            let store = try self.requiredStore()
            guard let heldLease = self.lease else { throw VMWorkspaceFailure("The VM run lease is unavailable.") }
            defer { withExtendedLifetime(heldLease) {} }
            if machine.canPause {
                try await machine.pause()
                try self.requireCurrent(machine, state: .paused)
                self.phase = .paused
            }
            guard machine.canResume else { throw VMWorkspaceFailure("The VM must be paused before it can be suspended.") }
            var workspace = try store.load(selected.id)
            let stateURL = try store.newStateURL(workspace)
            try await machine.saveMachineStateTo(url: stateURL)
            try self.requireCurrent(machine, state: .paused)
            guard chmod(stateURL.path, 0o600) == 0 else {
                throw VMWorkspaceFailure("The suspended state was written but could not be made private. The VM remains paused.")
            }
            try await machine.stop()
            guard machine.state == .stopped else { throw VMWorkspaceFailure("The VM did not stop; its suspended session was not published.") }
            workspace.suspendedState = stateURL.lastPathComponent
            workspace.suspendedFiles = try store.bindSuspendedFiles(workspace)
            try store.save(workspace)
            self.replace(workspace)
            self.virtualMachine = nil
            self.lease = nil
            self.phase = .suspended
            self.status = "Session saved. It can be restored on this Mac with this VM's current disk."
            self.note("Suspended to \(stateURL.lastPathComponent); VM stopped.")
        }
    }

    func restore(admitted: Bool) {
        guard admitted, canStart, let selected = selectedWorkspace, selected.suspendedState != nil else { return }
        beginOperation("Restoring suspended session…") { [weak self] in
            guard let self else { return }
            let store = try self.requiredStore()
            let acquired = try store.acquire(selected.id)
            let workspace = acquired.workspace
            let lease = acquired.lease
            self.replace(workspace)
            try store.verifySuspendedFiles(workspace)
            let machine = try self.makeMachine(workspace, store: store)
            guard self.supportsSuspend else {
                throw VMWorkspaceFailure(self.suspendUnavailableReason ?? "This configuration cannot restore a suspended session.")
            }
            self.lease = lease
            self.virtualMachine = machine
            do { try await machine.restoreMachineStateFrom(url: store.stateURL(for: workspace)) }
            catch { self.releaseIfStopped(); throw error }
            try self.requireCurrent(machine, state: .paused)
            self.phase = .paused
            self.status = "Session restored and paused. Choose Resume when ready."
            self.note("Restored suspended state into a paused VM.")
        }
    }

    func setInstallerAttached(_ attached: Bool) {
        guard canChangeWorkspace, let selected = selectedWorkspace else { return }
        do {
            let store = try requiredStore()
            let acquired = try store.acquire(selected.id)
            let lease = acquired.lease
            defer { withExtendedLifetime(lease) {} }
            var workspace = acquired.workspace
            guard workspace.suspendedState == nil else {
                throw VMWorkspaceFailure("Restore or start the suspended session before changing the installer attachment.")
            }
            workspace.installerAttached = attached
            try store.validateFiles(workspace)
            try store.save(workspace)
            replace(workspace)
            status = attached ? "Installer will be attached on the next start." : "Next start will use the installed disk."
            note("Installer attachment changed to \(attached).")
        } catch { report(error) }
    }

    func showFiles() {
        guard let store else { return }
        let url = selectedID.map { store.directory(for: $0) } ?? store.root
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func makeMachine(_ workspace: VMWorkspace, store: VMWorkspaceStore) throws -> VZVirtualMachine {
        guard VZVirtualMachine.isSupported else { throw VMWorkspaceFailure("Virtualization is unavailable on this Mac.") }
        try store.validateFiles(workspace)
        let configuration = VZVirtualMachineConfiguration()
        let memory = UInt64(workspace.memoryGiB) * UInt64(VMWorkspaceStore.gib)
        guard (VZVirtualMachineConfiguration.minimumAllowedCPUCount...VZVirtualMachineConfiguration.maximumAllowedCPUCount).contains(workspace.cpuCount),
              memory >= VZVirtualMachineConfiguration.minimumAllowedMemorySize,
              memory <= VZVirtualMachineConfiguration.maximumAllowedMemorySize,
              memory <= ProcessInfo.processInfo.physicalMemory / 2 else {
            throw VMWorkspaceFailure("This VM's CPU or memory allocation is not supported on this Mac.")
        }
        configuration.cpuCount = workspace.cpuCount
        configuration.memorySize = memory
        let platform = VZGenericPlatformConfiguration()
        guard let identifier = VZGenericMachineIdentifier(dataRepresentation: workspace.machineIdentifier) else {
            throw VMWorkspaceFailure("The saved VM machine identity is invalid.")
        }
        platform.machineIdentifier = identifier
        configuration.platform = platform
        let boot = VZEFIBootLoader()
        boot.variableStore = VZEFIVariableStore(url: store.efiURL(for: workspace.id))
        configuration.bootLoader = boot
        let disk = try VZDiskImageStorageDeviceAttachment(url: store.diskURL(for: workspace.id), readOnly: false)
        configuration.storageDevices = [VZVirtioBlockDeviceConfiguration(attachment: disk)]
        if workspace.installerAttached {
            let iso = try VZDiskImageStorageDeviceAttachment(url: store.installerURL(for: workspace.id), readOnly: true)
            configuration.storageDevices.append(VZUSBMassStorageDeviceConfiguration(attachment: iso))
        }
        let graphics = VZVirtioGraphicsDeviceConfiguration()
        graphics.scanouts = [VZVirtioGraphicsScanoutConfiguration(widthInPixels: 1280, heightInPixels: 800)]
        configuration.graphicsDevices = [graphics]
        configuration.keyboards = [VZUSBKeyboardConfiguration()]
        configuration.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
        configuration.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
        configuration.networkDevices = []
        configuration.directorySharingDevices = []
        configuration.socketDevices = []
        try configuration.validate()
        do {
            try configuration.validateSaveRestoreSupport()
            supportsSuspend = true
            suspendUnavailableReason = nil
        } catch {
            supportsSuspend = false
            suspendUnavailableReason = error.localizedDescription
        }
        shutdownAlreadyRequested = false
        let machine = VZVirtualMachine(configuration: configuration)
        machine.delegate = self
        return machine
    }

    private func consumeSuspendedReference() throws {
        guard var workspace = selectedWorkspace, workspace.suspendedState != nil else { return }
        let store = try requiredStore()
        workspace.suspendedState = nil
        workspace.suspendedFiles = nil
        try store.save(workspace)
        replace(workspace)
        try store.record("Suspended state consumed before resume; retained file cannot be replayed against a changing disk.", workspace: workspace)
    }

    private func requireCurrent(_ machine: VZVirtualMachine, state: VZVirtualMachine.State) throws {
        guard virtualMachine === machine, machine.state == state else {
            throw VMWorkspaceFailure("The guest stopped or changed state before this operation completed. Its files are retained.")
        }
    }

    private func requiredStore() throws -> VMWorkspaceStore {
        guard let store else { throw VMWorkspaceFailure("Open the VM workspace before continuing.") }
        return store
    }
    private func replace(_ workspace: VMWorkspace) {
        if let index = workspaces.firstIndex(where: { $0.id == workspace.id }) { workspaces[index] = workspace }
    }
    private func beginOperation(_ message: String, recordErrors: Bool = true, operation body: @escaping @MainActor () async throws -> Void) {
        guard !isBusy else { return }
        isBusy = true
        errorMessage = nil
        status = message
        operation = Task { [weak self] in
            do { try await body() }
            catch is CancellationError {
                self?.status = "Import cancelled. Any partial files were kept in the VM folder."
            } catch { self?.report(error, record: recordErrors) }
            self?.isBusy = false
            self?.operation = nil
            if let self {
                if self.immediateStopRequested { self.cancelAndStop() }
                else if self.quitRequested { self.requestQuit() }
            }
        }
    }
    private func report(_ error: Error, record: Bool = true) {
        errorMessage = error.localizedDescription
        status = "The operation did not complete."
        if record { note("Error: \(error.localizedDescription)") }
    }
    private func note(_ message: String) {
        guard let workspace = selectedWorkspace, let store else { return }
        do { try store.record(message, workspace: workspace) }
        catch { warnings.append("Activity record: \(error.localizedDescription)") }
    }
    private func releaseIfStopped() {
        guard !hasActiveMachine else { return }
        virtualMachine = nil
        lease = nil
        phase = selectedWorkspace?.suspendedState == nil ? .stopped : .suspended
    }
    private func finishedStopping(message: String) {
        virtualMachine = nil
        lease = nil
        phase = selectedWorkspace?.suspendedState == nil ? .stopped : .suspended
        status = message
    }

    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        guard self.virtualMachine === virtualMachine else { return }
        finishedStopping(message: "Guest shut down. Its disk is retained.")
        note("Guest shut down.")
    }
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        guard self.virtualMachine === virtualMachine else { return }
        finishedStopping(message: "VM stopped after an error. Its files are retained.")
        report(error)
    }
}

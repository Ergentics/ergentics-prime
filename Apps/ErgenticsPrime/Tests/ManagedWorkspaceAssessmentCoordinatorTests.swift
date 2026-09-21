import Darwin
import Foundation
import XCTest

@MainActor
final class ManagedWorkspaceAssessmentCoordinatorTests: XCTestCase {
    private actor Gate {
        private var opened = false
        private var waiters: [CheckedContinuation<Void, Never>] = []

        func wait() async {
            if opened { return }
            await withCheckedContinuation { waiters.append($0) }
        }

        func open() {
            guard !opened else { return }
            opened = true
            let held = waiters
            waiters.removeAll()
            held.forEach { $0.resume() }
        }
    }

    private func snapshotBytes(path: String = "/PRIVATE/canary/Prime") throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "schema": PrimeGitSnapshot.schemaIdentifier,
            "repositoryPath": path,
            "observedAt": "2026-09-01T00:00:00Z",
            "headMode": "unborn",
            "branch": "private-canary",
            "headOID": NSNull(),
            "changeCounts": ["staged": 0, "unstaged": 2, "untracked": NSNull()],
            "remotes": [],
            "consistency": "unchecked"
        ], options: [.sortedKeys])
    }

    private func temporarySnapshot(_ bytes: Data) throws -> (URL, URL) {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("epr-managed-workspace-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        let file = root.appendingPathComponent("snapshot.json", isDirectory: false)
        try bytes.write(to: file, options: .withoutOverwriting)
        return (root, file)
    }

    func testSuccessPublishesOnlyAfterWorkerPostflightAndRelease() async throws {
        let secret = "/PRIVATE/coordinator-success-canary"
        let (root, file) = try temporarySnapshot(snapshotBytes(path: secret))
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator()
        var activities: [ManagedWorkspaceProductGUIPresentation.Activity] = []

        let selection = try XCTUnwrap(coordinator.testSelection(for: file))
        let outcome = await coordinator.assess(selection: selection) { activities.append($0) }

        guard case .completed(let presentation) = outcome else {
            return XCTFail("Expected completed minimized presentation")
        }
        XCTAssertEqual(activities, [.assessing, .settling, .idle])
        XCTAssertEqual(coordinator.activity, .idle)
        XCTAssertTrue(coordinator.canBegin)
        XCTAssertEqual(presentation.activity, .idle)
        XCTAssertFalse(String(reflecting: presentation).contains(secret))
    }

    func testCancellationJoinsWorkerAndPostflightBeforeReuse() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let entered = Gate()
        let release = Gate()
        let coordinator = ManagedWorkspaceAssessmentCoordinator(testHooks: .init(
            beforeWorkerRead: {
                await entered.open()
                await release.wait()
            }
        ))
        var activities: [ManagedWorkspaceProductGUIPresentation.Activity] = []
        let selection = try XCTUnwrap(coordinator.testSelection(for: file))
        let operation = Task { @MainActor in
            await coordinator.assess(selection: selection) { activities.append($0) }
        }
        await entered.wait()

        coordinator.requestCancellation()
        XCTAssertEqual(coordinator.activity, .cancellationRequested)
        XCTAssertFalse(coordinator.canBegin)
        await release.open()
        let first = await operation.value

        XCTAssertEqual(first, .rejected(.cancelled))
        XCTAssertEqual(activities, [.assessing, .settling, .idle])
        XCTAssertTrue(coordinator.canBegin)
        let secondSelection = try XCTUnwrap(coordinator.testSelection(for: file))
        let second = await coordinator.assess(selection: secondSelection) { _ in }
        guard case .completed = second else { return XCTFail("Lease did not become reusable") }
    }

    func testNamedFileReplacementWithSameBytesCannotRebaseline() async throws {
        let bytes = try snapshotBytes()
        let (root, file) = try temporarySnapshot(bytes)
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator(testHooks: .init(
            beforePostflight: { try? bytes.write(to: file, options: .atomic) }
        ))
        var activities: [ManagedWorkspaceProductGUIPresentation.Activity] = []

        let selection = try XCTUnwrap(coordinator.testSelection(for: file))
        let outcome = await coordinator.assess(selection: selection) { activities.append($0) }

        XCTAssertEqual(outcome, .rejected(.changedDuringRead))
        XCTAssertEqual(activities, [.assessing, .settling, .unavailable])
        XCTAssertEqual(coordinator.activity, .unavailable)
        XCTAssertFalse(coordinator.canBegin)
    }

    func testPostflightFailureQuarantinesRatherThanClaimingIdle() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator(
            testHooks: .init(forcePostflightFailure: true)
        )
        var activities: [ManagedWorkspaceProductGUIPresentation.Activity] = []

        let selection = try XCTUnwrap(coordinator.testSelection(for: file))
        let first = await coordinator.assess(selection: selection) { activities.append($0) }
        XCTAssertEqual(first, .rejected(.changedDuringRead))
        XCTAssertEqual(activities.last, .unavailable)
        XCTAssertFalse(coordinator.canBegin)
        XCTAssertNil(coordinator.testSelection(for: file))
        let second = await coordinator.assess(selection: selection) { _ in }
        XCTAssertEqual(second, .rejected(.assessmentUnavailable))
    }

    func testConcurrentAssessmentHasOneOwner() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let entered = Gate()
        let release = Gate()
        let coordinator = ManagedWorkspaceAssessmentCoordinator(testHooks: .init(
            beforeWorkerRead: {
                await entered.open()
                await release.wait()
            }
        ))
        let firstSelection = try XCTUnwrap(coordinator.testSelection(for: file))
        let first = Task { @MainActor in
            await coordinator.assess(selection: firstSelection) { _ in }
        }
        await entered.wait()

        XCTAssertNil(coordinator.testSelection(for: file))
        await release.open()
        guard case .completed = await first.value else {
            return XCTFail("The admitted assessment did not complete")
        }
    }

    func testCancellationBeforeAssessmentDoesNotAcquireSnapshotGrant() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator()
        let selection = try XCTUnwrap(coordinator.testSelection(for: file))

        coordinator.requestCancellation()
        let outcome = await coordinator.assess(selection: selection) { _ in
            XCTFail("No lease activity may publish for a pre-start cancellation")
        }

        XCTAssertEqual(outcome, .rejected(.cancelled))
        XCTAssertEqual(coordinator.testSnapshotGrantConstructionAttempts, 0)
        XCTAssertTrue(coordinator.canBegin)

        let replay = await coordinator.assess(selection: selection) { _ in
            XCTFail("A consumed selection cannot publish lease activity")
        }
        XCTAssertEqual(replay, .rejected(.assessmentUnavailable))
        XCTAssertEqual(coordinator.testSnapshotGrantConstructionAttempts, 0)

        let fresh = try XCTUnwrap(coordinator.testSelection(for: file))
        let freshOutcome = await coordinator.assess(selection: fresh) { _ in }
        guard case .completed = freshOutcome else {
            return XCTFail("A separate fresh selection should remain eligible")
        }
    }

    func testAlreadyCancelledTaskDoesNotAcquireSnapshotGrant() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator()
        let selection = try XCTUnwrap(coordinator.testSelection(for: file))

        let operation = Task { @MainActor in
            withUnsafeCurrentTask { $0?.cancel() }
            return await coordinator.assess(selection: selection) { _ in
                XCTFail("No lease activity may publish for an already-cancelled task")
            }
        }

        let outcome = await operation.value
        XCTAssertEqual(outcome, .rejected(.cancelled))
        XCTAssertEqual(coordinator.testSnapshotGrantConstructionAttempts, 0)
        XCTAssertTrue(coordinator.canBegin)
    }

    func testSelectionIsBoundToItsIssuingCoordinator() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let issuer = ManagedWorkspaceAssessmentCoordinator()
        let foreign = ManagedWorkspaceAssessmentCoordinator()
        let selection = try XCTUnwrap(issuer.testSelection(for: file))

        let rejected = await foreign.assess(selection: selection) { _ in
            XCTFail("A foreign coordinator cannot publish lease activity")
        }
        XCTAssertEqual(rejected, .rejected(.assessmentUnavailable))
        XCTAssertEqual(foreign.testSnapshotGrantConstructionAttempts, 0)
        XCTAssertEqual(issuer.testSnapshotGrantConstructionAttempts, 0)

        let issuedOutcome = await issuer.assess(selection: selection) { _ in }
        guard case .completed = issuedOutcome else {
            return XCTFail("Foreign rejection must not consume the issuer's selection")
        }
        XCTAssertEqual(issuer.testSnapshotGrantConstructionAttempts, 1)
    }

    func testSelectionSlotIsReservedBeforeReentrantSelection() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator()
        var reentrant: ManagedWorkspaceAssessmentCoordinator.SnapshotSelection?

        let selection = try XCTUnwrap(coordinator.testSelection(for: file) {
            XCTAssertFalse(coordinator.canBegin)
            reentrant = coordinator.testSelection(for: file)
        })

        XCTAssertNil(reentrant)
        XCTAssertFalse(coordinator.canBegin)
        let outcome = await coordinator.assess(selection: selection) { _ in }
        guard case .completed = outcome else {
            return XCTFail("The single reserved selection should remain usable")
        }
        XCTAssertTrue(coordinator.canBegin)
    }

    func testCancelledPanelSelectionMintsNothing() {
        let coordinator = ManagedWorkspaceAssessmentCoordinator()

        XCTAssertNil(coordinator.testCancelledSelection())
        XCTAssertEqual(coordinator.testSnapshotGrantConstructionAttempts, 0)
        XCTAssertEqual(coordinator.activity, .idle)
        XCTAssertTrue(coordinator.canBegin)
    }

    func testOrdinaryAdmissionRejectionConservesCleanupAndAllowsFreshSelection() async throws {
        let (root, file) = try temporarySnapshot(Data())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator()
        let rejectedSelection = try XCTUnwrap(coordinator.testSelection(for: file))

        let rejected = await coordinator.assess(selection: rejectedSelection) { _ in }
        XCTAssertEqual(rejected, .rejected(.fileUnavailable))
        XCTAssertTrue(coordinator.canBegin)

        try snapshotBytes().write(to: file)
        let freshSelection = try XCTUnwrap(coordinator.testSelection(for: file))
        let fresh = await coordinator.assess(selection: freshSelection) { _ in }
        guard case .completed = fresh else {
            return XCTFail("Conserved ordinary rejection must not quarantine the coordinator")
        }
    }

    func testUncertainAdmissionCleanupQuarantinesCoordinator() async throws {
        let (root, file) = try temporarySnapshot(snapshotBytes())
        defer { try? FileManager.default.removeItem(at: root) }
        let coordinator = ManagedWorkspaceAssessmentCoordinator(testHooks: .init(
            forceGrantAdmissionCleanupFailure: true
        ))
        let selection = try XCTUnwrap(coordinator.testSelection(for: file))
        var activities: [ManagedWorkspaceProductGUIPresentation.Activity] = []

        let outcome = await coordinator.assess(selection: selection) {
            activities.append($0)
        }

        XCTAssertEqual(outcome, .rejected(.assessmentUnavailable))
        XCTAssertEqual(activities, [.assessing, .settling, .unavailable])
        XCTAssertEqual(coordinator.testSnapshotGrantConstructionAttempts, 1)
        XCTAssertEqual(coordinator.activity, .unavailable)
        XCTAssertFalse(coordinator.canBegin)
        XCTAssertNil(coordinator.testSelection(for: file))
    }
}

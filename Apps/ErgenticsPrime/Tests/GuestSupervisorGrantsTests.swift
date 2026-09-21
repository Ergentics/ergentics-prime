import Darwin
import Foundation
import XCTest

private final class GuestProvisionResults: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var successes: [GuestSupervisorRetentionGrant] = []
    private(set) var failureCount = 0

    func record(_ result: Result<GuestSupervisorRetentionGrant, Error>) {
        lock.lock()
        defer { lock.unlock() }
        switch result {
        case .success(let grant): successes.append(grant)
        case .failure: failureCount += 1
        }
    }
}

// Grant/fabricated-evidence tests plus throwaway private-root mechanics. No
// production Application Support lookup, native reservation, VM API, guest
// image accessor, app launch, or retained production-state cleanup.
final class GuestSupervisorGrantsTests: XCTestCase {
    func testCheckedProductReleaseCompletesBeforePresentationAndConsumesExactlyOnce() throws {
        var state = H3QualificationReservationStateMachine(policy: .qualificationChecked)
        var token = OpaquePointer(bitPattern: 0x1234)
        var completed = false
        var calls = 0
        try state.recordReserve(tokenPresent: true, error: 0)
        let status = GuestProductReservationRelease.finish(state: &state, token: &token,
            completed: &completed) { pointer in
                XCTAssertEqual(pointer, OpaquePointer(bitPattern: 0x1234))
                calls += 1
                return 0
            }
        XCTAssertEqual(status, 0)
        XCTAssertNil(token)
        XCTAssertTrue(completed)
        XCTAssertEqual(state.reservationReleaseEntries, 1)
        XCTAssertEqual(state.reservationReleaseStatus, 0)
        XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
            completed: &completed) { _ in calls += 1; return 0 }, EINVAL)
        XCTAssertEqual(calls, 1)
        XCTAssertEqual(try state.deinitDecision(tokenPresent: token != nil), .noCall)
    }

    func testCheckedProductReleaseRetainsEveryFailedStatusWithoutRetryOrDeinit() throws {
        for status in [Int32](arrayLiteral: EBUSY, EINVAL, -1, .min) {
            var state = H3QualificationReservationStateMachine(policy: .qualificationChecked)
            let original = OpaquePointer(bitPattern: 0x1234)
            var token = original
            var completed = false
            var calls = 0
            try state.recordReserve(tokenPresent: true, error: 0)
            XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
                completed: &completed) { _ in calls += 1; return status }, status)
            XCTAssertEqual(token, original)
            XCTAssertEqual(state.reservationReleaseEntries, 1)
            XCTAssertEqual(state.reservationReleaseStatus, status)
            XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
                completed: &completed) { _ in calls += 1; return 0 }, EINVAL)
            XCTAssertEqual(calls, 1)
            XCTAssertEqual(try state.deinitDecision(tokenPresent: true), .noCall)
        }
    }

    func testCheckedProductReleaseBeforePreparationOrAfterFailedReserveNeverCallsNative() throws {
        for reserveError in [Int32?](arrayLiteral: nil, EBUSY, ENOMEM) {
            var state = H3QualificationReservationStateMachine(policy: .qualificationChecked)
            var token: OpaquePointer?
            var completed = false
            var calls = 0
            if let reserveError { try state.recordReserve(tokenPresent: false, error: reserveError) }
            XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
                completed: &completed) { _ in calls += 1; return 0 }, 0)
            XCTAssertTrue(completed)
            XCTAssertEqual(state.reservationReleaseEntries, 0)
            XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
                completed: &completed) { _ in calls += 1; return 0 }, EINVAL)
            XCTAssertEqual(calls, 0)
        }
    }

    func testCheckedProductReleaseRejectsIncoherentReserveAndMissingTokenWithoutInventedCleanup() throws {
        let invalidReserves: [(Bool, Int32)] = [(false, 0), (true, EBUSY), (true, -1)]
        for (tokenPresent, error) in invalidReserves {
            var state = H3QualificationReservationStateMachine(policy: .qualificationChecked)
            var token = tokenPresent ? OpaquePointer(bitPattern: 0x1234) : nil
            let original = token
            var completed = false
            var calls = 0
            try state.recordReserve(tokenPresent: tokenPresent, error: error)
            XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
                completed: &completed) { _ in calls += 1; return 0 }, EINVAL)
            XCTAssertEqual(token, original)
            XCTAssertEqual(calls, 0)
            XCTAssertEqual(state.reservationReleaseEntries, 0)
            XCTAssertEqual(try state.deinitDecision(tokenPresent: token != nil), .noCall)
        }
        var state = H3QualificationReservationStateMachine(policy: .qualificationChecked)
        try state.recordReserve(tokenPresent: true, error: 0)
        var token: OpaquePointer?
        var completed = false
        XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
            completed: &completed) { _ in XCTFail("Missing token cannot be released"); return 0 }, EINVAL)
    }

    func testCheckedProductReleaseDoesNotChangeOrdinaryOwnerPolicy() throws {
        var state = H3QualificationReservationStateMachine(policy: .ordinaryDeinit)
        var token = OpaquePointer(bitPattern: 0x1234)
        var completed = false
        try state.recordReserve(tokenPresent: true, error: 0)
        XCTAssertEqual(GuestProductReservationRelease.finish(state: &state, token: &token,
            completed: &completed) { _ in XCTFail("Wrong policy"); return 0 }, EINVAL)
        XCTAssertFalse(completed)
        XCTAssertEqual(try state.deinitDecision(tokenPresent: true), .callToken)
    }

    func testCheckedProductReleaseFailurePreservesEvidenceAndCannotPresentPASS() {
        for prior in ["PASS", "FAIL", "CANCELED", "INCOMPLETE"] {
            let event = GuestEventDisplay(id: 2, kind: "terminal", digest: "retained", byteCount: 5)
            let observed = GuestPresentation(id: "run", status: prior, detail: "Original result.",
                root: "root", elapsed: "ticks", events: [event], quarantined: false,
                volatileObservation: Data([1, 2, 3]))
            let result = GuestProductReservationRelease.presentation(observed, releaseStatus: EBUSY)
            XCTAssertEqual(result.status, "INCOMPLETE")
            XCTAssertTrue(result.quarantined)
            XCTAssertTrue(result.detail.contains(prior))
            XCTAssertTrue(result.detail.contains(observed.detail))
            XCTAssertEqual(result.id, observed.id)
            XCTAssertEqual(result.root, observed.root)
            XCTAssertEqual(result.elapsed, observed.elapsed)
            XCTAssertEqual(result.events.count, 1)
            XCTAssertEqual(result.events[0].digest, event.digest)
            XCTAssertEqual(result.events[0].byteCount, event.byteCount)
            XCTAssertEqual(result.volatileObservation, observed.volatileObservation)
        }
    }

    func testSuccessfulCheckedProductReleaseDoesNotPromoteFailedNativeOrPersistenceResult() {
        for prior in ["PASS", "FAIL", "CANCELED", "INCOMPLETE"] {
            let observed = GuestPresentation(id: "run", status: prior, detail: "Original result.",
                root: "root", elapsed: "ticks", events: [], quarantined: true,
                volatileObservation: Data([1, 2, 3]))
            let result = GuestProductReservationRelease.presentation(observed, releaseStatus: 0)
            XCTAssertEqual(result.status, prior)
            XCTAssertEqual(result.detail, observed.detail)
            XCTAssertTrue(result.quarantined)
            XCTAssertEqual(result.volatileObservation, observed.volatileObservation)
        }
    }

    private func provisioningBase() throws -> URL {
        guard let resolved = realpath(FileManager.default.temporaryDirectory.path, nil) else {
            throw GuestRetentionProvisionFailure("Cannot resolve test temporary base")
        }
        let physicalBase = String(cString: resolved)
        free(resolved)
        let base = URL(fileURLWithPath: physicalBase, isDirectory: true)
            .appendingPathComponent("GuestRetentionProvisionerTests-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        return base
    }

    private func withProvisioningBase(_ body: (URL) throws -> Void) throws {
        let base = try provisioningBase()
        // Exact throwaway test fixture only; production provisioned outcomes
        // are never enumerated, repaired, retried or cleaned automatically.
        defer { try? FileManager.default.removeItem(at: base) }
        try body(base)
    }

    private func prefix(runID: String = "explicit-run", payload: [String: GuestCBORValue] = [:]) throws
        -> GuestSupervisorRetainedRun {
        let bytes = try GuestCBOR.encode(.map([
            "schema": .text(GuestJournal.schema), "run_id": .text(runID),
            "sequence": .unsigned(0), "kind": .text("start"),
            "parent": .bytes(Data()), "payload": .map(payload)
        ]))
        let event = GuestJournalEvent(runID: runID, sequence: 0, kind: "start",
            payload: bytes, digest: GuestContract.hash(bytes), parent: nil)
        return GuestSupervisorRetainedRun(runID: runID, events: [event])
    }

    func testStorageTransitionHasOneCreateOrOpenWinnerAndFailureConsumes() throws {
        var failed = GuestStorageTransition()
        let ticket = try XCTUnwrap(failed.beginCreate())
        XCTAssertNil(failed.beginCreate())
        XCTAssertNil(failed.beginOpen())
        XCTAssertTrue(failed.creating)
        XCTAssertTrue(failed.completeCreate(ticket: ticket, accepted: false))
        XCTAssertFalse(failed.canBegin)
        XCTAssertFalse(failed.creating)
        XCTAssertNil(failed.beginOpen())

        var ready = GuestStorageTransition()
        let readyTicket = try XCTUnwrap(ready.beginOpen())
        XCTAssertNil(ready.beginCreate())
        XCTAssertTrue(ready.opening)
        XCTAssertTrue(ready.completeOpen(ticket: readyTicket, accepted: true))
        XCTAssertFalse(ready.canBegin)
        XCTAssertNil(ready.beginCreate())
    }

    func testStorageTransitionRejectsWrongOperationWrongAndLateTicket() throws {
        var transition = GuestStorageTransition()
        let ticket = try XCTUnwrap(transition.beginOpen())
        XCTAssertFalse(transition.completeCreate(ticket: ticket, accepted: true))
        XCTAssertFalse(transition.completeOpen(ticket: ticket + 1, accepted: true))
        XCTAssertTrue(transition.opening)
        XCTAssertTrue(transition.completeOpen(ticket: ticket, accepted: true))
        XCTAssertFalse(transition.completeOpen(ticket: ticket, accepted: false))
    }

    func testDefaultGrantsProvideNeitherRetentionNorHistory() {
        for grants in [GuestSupervisorGrants(), .none] {
            XCTAssertNil(grants.retention)
            XCTAssertNil(grants.historyDisplay)
        }
    }

    func testRetentionKeepsTheExactSuppliedDestinationWithoutOpeningIt() throws {
        let destination = URL(fileURLWithPath: "/private/explicit-supervisor-parent/guest-events.sqlite3",
                              isDirectory: false)
        let retention = try GuestSupervisorRetentionGrant(exactJournalURL: destination)
        XCTAssertEqual(retention.journalURL, destination)
        XCTAssertEqual(retention.journalURL.absoluteString, destination.absoluteString)
        let grants = GuestSupervisorGrants(retention: retention)
        XCTAssertEqual(grants.retention?.journalURL, destination)
        XCTAssertNil(grants.historyDisplay, "Retention must not imply history discovery or display")
    }

    func testRetentionPreservesExplicitUnicodeAndSpacesWithoutNormalization() throws {
        let destination = URL(fileURLWithPath: "/private/explicit-e\u{301} space/journal.sqlite3",
                              isDirectory: false)
        let retention = try GuestSupervisorRetentionGrant(exactJournalURL: destination)
        XCTAssertEqual(Array(retention.journalURL.path.utf8), Array(destination.path.utf8))
        XCTAssertEqual(retention.journalURL.absoluteString, destination.absoluteString)
    }

    func testRetentionRejectsAmbientRelativeRemoteAndDecoratedURLs() throws {
        let rejected = [
            "journal.sqlite3", "https://example.invalid/journal.sqlite3",
            "file://remote.invalid/private/journal.sqlite3",
            "file://localhost/private/journal.sqlite3",
            "file://user@remote.invalid/private/journal.sqlite3",
            "file:///private/journal.sqlite3?query=1",
            "file:///private/journal.sqlite3#fragment",
            "file:///", "file:///private/", "file:///private//journal.sqlite3",
            "file:///private/./journal.sqlite3", "file:///private/../journal.sqlite3",
            "file:///private/%2e%2e/journal.sqlite3", "file:///private/journal.sqlite3%00",
            "file:///private/journal.sqlite3%2Falias", "file:///private/journal.sqlite3%5Calias"
        ]
        for value in rejected {
            let url = try XCTUnwrap(URL(string: value), value)
            XCTAssertThrowsError(try GuestSupervisorRetentionGrant(exactJournalURL: url), value)
        }
        let base = try XCTUnwrap(URL(string: "file:///private/explicit-parent/"))
        let relative = try XCTUnwrap(URL(string: "journal.sqlite3", relativeTo: base))
        XCTAssertThrowsError(try GuestSupervisorRetentionGrant(exactJournalURL: relative))
    }

    func testRetentionAcceptsNormalPercentEncodedUnicodeAndSpace() throws {
        let url = try XCTUnwrap(URL(string: "file:///private/explicit-e%CC%81%20space/journal.sqlite3"))
        let retention = try GuestSupervisorRetentionGrant(exactJournalURL: url)
        XCTAssertEqual(retention.journalURL, url)
        XCTAssertEqual(Array(retention.journalURL.path.utf8),
            Array("/private/explicit-e\u{301} space/journal.sqlite3".utf8))
    }

    func testExplicitProvisionerCreatesOneBoundPrivateRootAndGenesis() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000001"
            let grant = try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID)
            XCTAssertTrue(grant.isDescriptorBound)
            XCTAssertEqual(grant.retentionEpochID, epochID)
            XCTAssertEqual(grant.journalURL.lastPathComponent, GuestRetentionProvisioner.journalLeaf)
            XCTAssertNotNil(grant.genesisDigest)
            try grant.revalidate()

            let root = grant.journalURL.deletingLastPathComponent()
            let genesis = root.appendingPathComponent(GuestRetentionProvisioner.genesisLeaf)
            let rootMode = try FileManager.default.attributesOfItem(atPath: root.path)[.posixPermissions] as? NSNumber
            let genesisMode = try FileManager.default.attributesOfItem(atPath: genesis.path)[.posixPermissions] as? NSNumber
            XCTAssertEqual(rootMode?.intValue, 0o700)
            XCTAssertEqual(genesisMode?.intValue, 0o600)
            XCTAssertFalse(FileManager.default.fileExists(atPath: grant.journalURL.path))
            let genesisBytes = try Data(contentsOf: genesis)
            XCTAssertEqual(GuestContract.hash(genesisBytes), grant.genesisDigest)
            guard case .map(let value) = try GuestCBOR.decode(genesisBytes) else {
                return XCTFail("Genesis is not a deterministic CBOR map")
            }
            XCTAssertEqual(value["root_leaf"], .text(GuestRetentionProvisioner.rootLeaf))
            XCTAssertEqual(value["epoch_id"], .text(epochID))
            XCTAssertEqual(value["journal_leaf"], .text(GuestRetentionProvisioner.journalLeaf))

            let journal = try GuestJournal(retentionGrant: grant)
            XCTAssertEqual(try journal.runIDs(), [])
            try grant.revalidate()
        }
    }

    func testReadOnlyOpenOfGenesisOnlyRootIsQualifiedHistoryWithoutRetention() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000011"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            let genesisDigest = try XCTUnwrap(retention?.genesisDigest)
            retention = nil

            let history = try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base)
            XCTAssertEqual(history.presentations.count, 0)
            XCTAssertEqual(history.reconstruction, GuestHistoryReconstructionMetadata(
                retentionAncestry: GuestRetentionAncestry(epochID: epochID,
                    genesisSHA256: genesisDigest), journalSHA256: nil, genesisOnly: true))
            let grants = GuestSupervisorGrants(historyDisplay: history)
            XCTAssertNil(grants.retention)
            XCTAssertNotNil(grants.historyDisplay)
        }
    }

    func testReadOnlyOpenVerifiesAncestryAndPreservesJournalBytes() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000012"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            let ancestry = try XCTUnwrap(retention?.ancestry)
            let journalURL = try XCTUnwrap(retention?.journalURL)
            var journal: GuestJournal? = try GuestJournal(retentionGrant: try XCTUnwrap(retention))
            let event = try journal!.append(runID: "retained-run", kind: "start", payload: [
                "retention_epoch_id": .text(ancestry.epochID),
                "retention_genesis_sha256": .text(ancestry.genesisSHA256),
            ])
            journal = nil
            retention = nil
            let before = try Data(contentsOf: journalURL)

            let history = try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base)
            XCTAssertEqual(history.presentations.map(\.id), ["retained-run"])
            XCTAssertEqual(history.presentations.first?.status, "INCOMPLETE")
            XCTAssertEqual(history.presentations.first?.events.first?.digest, event.digest)
            XCTAssertEqual(history.reconstruction?.retentionAncestry, ancestry)
            XCTAssertEqual(history.reconstruction?.journalSHA256, GuestContract.hash(before))
            XCTAssertEqual(history.reconstruction?.genesisOnly, false)
            XCTAssertEqual(try Data(contentsOf: journalURL), before)
        }
    }

    func testReadOnlyOpenRejectsLiveCreateLockAndWrongAncestry() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000013"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            XCTAssertThrowsError(try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base))
            var journal: GuestJournal? = try GuestJournal(retentionGrant: try XCTUnwrap(retention))
            _ = try journal!.append(runID: "wrong-ancestry", kind: "start", payload: [
                "retention_epoch_id": .text(epochID),
                "retention_genesis_sha256": .text(String(repeating: "0", count: 64)),
            ])
            journal = nil
            retention = nil
            XCTAssertThrowsError(try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base))
        }
    }

    func testReadOnlyOpenRejectsExactSQLiteSidecarsWithoutTouchingUnknownNames() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000014"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            let root = try XCTUnwrap(retention?.journalURL.deletingLastPathComponent())
            retention = nil
            let unknown = root.appendingPathComponent("opaque-unknown-entry")
            let unknownBytes = Data("not discoverable".utf8)
            XCTAssertTrue(FileManager.default.createFile(atPath: unknown.path, contents: unknownBytes,
                attributes: [.posixPermissions: 0o600]))
            let sidecar = root.appendingPathComponent(GuestRetentionProvisioner.journalLeaf + "-wal")
            XCTAssertTrue(FileManager.default.createFile(atPath: sidecar.path, contents: Data(),
                attributes: [.posixPermissions: 0o600]))
            XCTAssertThrowsError(try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base))
            XCTAssertEqual(try Data(contentsOf: unknown), unknownBytes)
            XCTAssertEqual(try Data(contentsOf: sidecar), Data())
        }
    }

    func testReadOnlyOpenRejectsChangedCanonicalGenesisBytes() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000015"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            let genesis = try XCTUnwrap(retention?.journalURL.deletingLastPathComponent()
                .appendingPathComponent(GuestRetentionProvisioner.genesisLeaf))
            retention = nil
            var bytes = try Data(contentsOf: genesis)
            bytes[bytes.startIndex] ^= 1
            try bytes.write(to: genesis)
            XCTAssertThrowsError(try GuestHistoryReconstructor.reconstructForTests(applicationSupportURL: base))
            XCTAssertEqual(try Data(contentsOf: genesis), bytes)
        }
    }

    func testReadOnlyOpenRejectsSameVnodeWriteAndExactByteRestoreDuringSnapshot() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000016"
            var retention: GuestSupervisorRetentionGrant? = try GuestRetentionProvisioner
                .provisionForTests(applicationSupportURL: base, epochID: epochID)
            let genesis = try XCTUnwrap(retention?.journalURL.deletingLastPathComponent()
                .appendingPathComponent(GuestRetentionProvisioner.genesisLeaf))
            retention = nil
            let original = try Data(contentsOf: genesis)
            var before = stat()
            XCTAssertEqual(lstat(genesis.path, &before), 0)

            XCTAssertThrowsError(try GuestHistoryReconstructor.reconstructForTests(
                applicationSupportURL: base,
                beforeFinalRevalidation: {
                    let handle = try FileHandle(forUpdating: genesis)
                    defer { try? handle.close() }
                    try handle.seek(toOffset: 0)
                    try handle.write(contentsOf: Data([original[0] ^ 1]))
                    try handle.synchronize()
                    usleep(1_000)
                    try handle.seek(toOffset: 0)
                    try handle.write(contentsOf: Data([original[0]]))
                    try handle.synchronize()
                }))

            var after = stat()
            XCTAssertEqual(lstat(genesis.path, &after), 0)
            XCTAssertEqual(before.st_dev, after.st_dev)
            XCTAssertEqual(before.st_ino, after.st_ino)
            XCTAssertEqual(try Data(contentsOf: genesis), original)
        }
    }

    func testProvisionAndOpenRequireCanonicalLowercaseUUIDEpoch() throws {
        try withProvisioningBase { base in
            for epochID in [
                "epoch-00000000-0000-4000-8000-00000000001",
                "epoch-00000000-0000-4000-8000-000000000001-extra",
                "epoch-00000000-0000-4000-8000-00000000000G",
                "epoch-00000000-0000-4000-8000-00000000000A",
            ] {
                XCTAssertThrowsError(try GuestRetentionProvisioner.provisionForTests(
                    applicationSupportURL: base, epochID: epochID), epochID)
            }
        }
    }

    func testProvisionerDoesNotAdoptOrRetryAnExistingRoot() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000002"
            let first = try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID)
            XCTAssertThrowsError(try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID))
            try first.revalidate()
        }
    }

    func testConcurrentProvisionersHaveExactlyOneKernelWinner() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000007"
            let results = GuestProvisionResults()
            DispatchQueue.concurrentPerform(iterations: 2) { _ in
                results.record(Result {
                    try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID)
                })
            }
            XCTAssertEqual(results.successes.count, 1)
            XCTAssertEqual(results.failureCount, 1)
            try XCTUnwrap(results.successes.first).revalidate()
        }
    }

    func testBoundGrantRejectsNamedRootReplacement() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000003"
            let grant = try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID)
            let root = grant.journalURL.deletingLastPathComponent()
            let moved = base.appendingPathComponent(epochID + "-retained", isDirectory: true)
            try FileManager.default.moveItem(at: root, to: moved)
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                attributes: [.posixPermissions: 0o700])
            XCTAssertThrowsError(try grant.revalidate())
            XCTAssertThrowsError(try GuestJournal(retentionGrant: grant))
        }
    }

    func testBoundGrantRejectsGenesisMutationAndUnboundGrantCannotOpenProductionJournal() throws {
        try withProvisioningBase { base in
            let epochID = "epoch-00000000-0000-4000-8000-000000000004"
            let grant = try GuestRetentionProvisioner.provisionForTests(applicationSupportURL: base, epochID: epochID)
            let genesis = grant.journalURL.deletingLastPathComponent()
                .appendingPathComponent(GuestRetentionProvisioner.genesisLeaf)
            try Data([0]).write(to: genesis)
            XCTAssertThrowsError(try grant.revalidate())

            let unboundRoot = base.appendingPathComponent("unbound", isDirectory: true)
            try FileManager.default.createDirectory(at: unboundRoot, withIntermediateDirectories: false,
                attributes: [.posixPermissions: 0o700])
            let unbound = try GuestSupervisorRetentionGrant(exactJournalURL:
                unboundRoot.appendingPathComponent(GuestRetentionProvisioner.journalLeaf))
            XCTAssertFalse(unbound.isDescriptorBound)
            XCTAssertThrowsError(try GuestJournal(retentionGrant: unbound))
        }
    }

    func testHistoryOnlyGrantDoesNotGrantExecutionOrRetention() throws {
        let history = try GuestSupervisorHistoryGrant(runs: [])
        let grants = GuestSupervisorGrants(historyDisplay: history)
        XCTAssertNil(grants.retention)
        XCTAssertEqual(grants.historyDisplay?.presentations.count, 0)
    }

    func testHistoryVerifiesOnlyExplicitEvidenceAndKeepsItsBindings() throws {
        let first = try prefix(runID: "selected-z")
        let second = try prefix(runID: "selected-a")
        let history = try GuestSupervisorHistoryGrant(runs: [first, second])
        XCTAssertEqual(history.presentations.map(\.id), ["selected-z", "selected-a"])
        for (presentation, selected) in zip(history.presentations, [first, second]) {
            XCTAssertEqual(presentation.status, "INCOMPLETE")
            XCTAssertEqual(presentation.detail, "Retained prefix without a verified terminal")
            XCTAssertTrue(presentation.root.isEmpty)
            XCTAssertTrue(presentation.elapsed.isEmpty)
            XCTAssertFalse(presentation.quarantined)
            XCTAssertNil(presentation.volatileObservation)
            XCTAssertEqual(presentation.events.count, 1)
            XCTAssertEqual(presentation.events[0].id, selected.events[0].sequence)
            XCTAssertEqual(presentation.events[0].kind, selected.events[0].kind)
            XCTAssertEqual(presentation.events[0].digest, selected.events[0].digest)
            XCTAssertEqual(presentation.events[0].byteCount, selected.events[0].payload.count)
        }
    }

    func testDeclaredPASSCannotElevateAnIncompletePrefix() throws {
        let selected = try prefix(payload: ["status": .text("PASS"), "authority_vector": .text("11111111")])
        let history = try GuestSupervisorHistoryGrant(runs: [selected])
        XCTAssertEqual(history.presentations.first?.status, "INCOMPLETE")
        XCTAssertEqual(history.presentations.first?.root, "")
    }

    func testHistoryRejectsCrossRunEvidenceAndDuplicateSelections() throws {
        let selected = try prefix()
        let crossRun = GuestSupervisorRetainedRun(runID: "different-run", events: selected.events)
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [crossRun]))
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [selected, selected]))
    }

    func testHistoryRejectsMalformedDigestProjectionAndUnknownProfile() throws {
        let selected = try prefix()
        let original = try XCTUnwrap(selected.events.first)
        let wrongDigest = GuestJournalEvent(runID: original.runID, sequence: original.sequence,
            kind: original.kind, payload: original.payload, digest: String(repeating: "0", count: 64), parent: nil)
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [
            GuestSupervisorRetainedRun(runID: selected.runID, events: [wrongDigest])
        ]))
        let wrongProjection = GuestJournalEvent(runID: original.runID, sequence: 1,
            kind: original.kind, payload: original.payload, digest: original.digest, parent: nil)
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [
            GuestSupervisorRetainedRun(runID: selected.runID, events: [wrongProjection])
        ]))
        let unknown = try prefix(payload: ["profile": .text("unknown-profile")])
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [unknown]))
    }

    func testHistoryRejectsMissingOrOverlongEventSequences() throws {
        let selected = try prefix()
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [
            GuestSupervisorRetainedRun(runID: selected.runID, events: [])
        ]))
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [
            GuestSupervisorRetainedRun(runID: selected.runID,
                events: Array(repeating: selected.events[0], count: 4))
        ]))
    }

    func testHistoryBoundsAreExplicitAndDoNotTruncateSelections() throws {
        let selected = try (0..<GuestSupervisorHistoryGrant.maximumRuns).map { try prefix(runID: "selected-\($0)") }
        let history = try GuestSupervisorHistoryGrant(runs: selected)
        XCTAssertEqual(history.presentations.count, 20)
        XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: selected + [prefix(runID: "one-too-many")]))
        for runID in ["", String(repeating: "x", count: 129), String(repeating: "é", count: 65), "run\0alias"] {
            XCTAssertThrowsError(try GuestSupervisorHistoryGrant(runs: [prefix(runID: runID)]))
        }
        let exact = try prefix(runID: String(repeating: "é", count: 64))
        XCTAssertEqual(try GuestSupervisorHistoryGrant(runs: [exact]).presentations.count, 1)
    }

    func testHistoryIsAnImmutableSnapshotNotAHandleToCallerStorage() throws {
        var selected = [try prefix(runID: "selected-original")]
        let history = try GuestSupervisorHistoryGrant(runs: selected)
        selected[0] = try prefix(runID: "selected-replacement")
        selected.removeAll()
        XCTAssertEqual(history.presentations.map(\.id), ["selected-original"])
        var presentation = try XCTUnwrap(history.presentations.first)
        presentation.volatileObservation = Data([1, 2, 3])
        XCTAssertNil(history.presentations.first?.volatileObservation)
    }
}

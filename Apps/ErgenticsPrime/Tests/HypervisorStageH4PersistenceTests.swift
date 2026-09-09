import Darwin
import Foundation
import SQLite3
import XCTest

final class HypervisorStageH4PersistenceTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4C = HypervisorStageH4CanonicalStreams
    private typealias H4D = HypervisorStageH4OwnerBinding
    private typealias H4P = HypervisorStageH4Persistence

    private let epoch = "33333333-3333-4333-8333-333333333333"

    private final class LockedTick: @unchecked Sendable {
        private let lock = NSLock()
        private var value: UInt64

        init(_ value: UInt64) { self.value = value }
        func set(_ value: UInt64) {
            lock.lock()
            self.value = value
            lock.unlock()
        }
        func read() -> UInt64 {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
    }

    private final class SequenceTick: @unchecked Sendable {
        private let lock = NSLock()
        private let values: [UInt64]
        private var index = 0

        init(_ values: [UInt64]) { self.values = values }
        func read() -> UInt64 {
            lock.lock()
            defer { lock.unlock() }
            let position = min(index, values.count - 1)
            index += 1
            return values[position]
        }
    }

    private final class LockedOutcomes: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [H4P.Outcome] = []

        func append(_ value: H4P.Outcome) {
            lock.lock()
            values.append(value)
            lock.unlock()
        }
        func snapshot() -> [H4P.Outcome] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }
    }

    private final class LockedInspectionOutcomes: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [H4P.RetainedInspectionOutcome] = []

        func append(_ value: H4P.RetainedInspectionOutcome) {
            lock.lock()
            values.append(value)
            lock.unlock()
        }

        func snapshot() -> [H4P.RetainedInspectionOutcome] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }
    }

    private func source(
        rawDiagnostic: Data? = nil,
        receiptRoot: String = String(repeating: "a", count: 64)
    ) -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: .h3Checkpoint,
            epoch: epoch,
            receiptRoot: receiptRoot,
            claimState: .observedNonPass,
            predicateCount: 19,
            authorityVector: "00000000",
            rawDiagnostic: rawDiagnostic
        )
    }

    private func dispatcher(
        source: H4.Source? = nil,
        validThroughTick: UInt64 = .max,
        readTick: @escaping @Sendable () -> UInt64 = { mach_continuous_time() }
    ) throws -> H4.DestinationDispatcher {
        let input = source ?? self.source()
        let capability = try XCTUnwrap(H4.issueTestCapability(
            source: input,
            validThroughTick: validThroughTick
        ))
        return try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: H4.fixedRequest(epoch: input.epoch),
            source: input,
            deliveryTick: readTick
        ))
    }

    private func bound(
        source: H4.Source? = nil,
        validThroughTick: UInt64 = .max,
        readTick: @escaping @Sendable () -> UInt64 = { mach_continuous_time() }
    ) throws -> H4D.OwnerBoundCanonicalProjection {
        try dispatcher(
            source: source,
            validThroughTick: validThroughTick,
            readTick: readTick
        ).bindCanonicalStreams().get()
    }

    private func privateRoot(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        var template = Array("/private/tmp/epr-h4d2b.XXXXXX\0".utf8)
        let path = template.withUnsafeMutableBufferPointer { buffer -> String? in
            guard let base = buffer.baseAddress, let created = mkdtemp(base) else {
                return nil
            }
            return String(validatingCString: created)
        }
        let root = try XCTUnwrap(path, file: file, line: line)
        XCTAssertEqual(chmod(root, mode_t(0o700)), 0, file: file, line: line)
        let url = URL(fileURLWithPath: root, isDirectory: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(
                atPath: root + ".h4d2b-displaced"
            )
        }
        return url
    }

    private func coordinator(
        bound: H4D.OwnerBoundCanonicalProjection,
        fault: H4P.TestFault = .none,
        storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }
    ) throws -> (H4P.Coordinator, URL) {
        let root = try privateRoot()
        return (
            try H4P.makeTestCoordinator(
                bound: bound,
                rootURL: root,
                fault: fault,
                storeValidThroughTick: storeValidThroughTick,
                storeReadTick: storeReadTick
            ),
            root
        )
    }

    private func createLeaf(
        _ leaf: String,
        in root: URL,
        mode: mode_t = 0o600,
        contents: Data = Data()
    ) throws {
        let path = root.appendingPathComponent(leaf).path
        XCTAssertTrue(FileManager.default.createFile(
            atPath: path,
            contents: contents,
            attributes: [.posixPermissions: NSNumber(value: mode)]
        ))
    }

    private func inventory(_ root: URL) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: root.path).sorted()
    }

    private func publishedRoot() throws -> URL {
        let root = try privateRoot()
        var writer: H4P.Coordinator? = try H4P.makeTestCoordinator(
            bound: bound(),
            rootURL: root
        )
        let outcome = try XCTUnwrap(writer).persist()
        guard case .admitted = outcome else {
            throw H4P.Failure.reconstructionRejected
        }
        writer = nil
        return root
    }

    private func mutatePublishedDatabase(
        _ root: URL,
        sql: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let path = H4P.finalTestURL(in: root).path
        XCTAssertEqual(chmod(path, mode_t(0o600)), 0, file: file, line: line)
        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX |
            SQLITE_OPEN_EXRESCODE
        XCTAssertEqual(
            sqlite3_open_v2(path, &database, flags, nil),
            SQLITE_OK,
            file: file,
            line: line
        )
        let opened = try XCTUnwrap(database, file: file, line: line)
        XCTAssertEqual(
            sqlite3_exec(opened, sql, nil, nil, nil),
            SQLITE_OK,
            file: file,
            line: line
        )
        XCTAssertEqual(sqlite3_close(opened), SQLITE_OK, file: file, line: line)
        database = nil
        XCTAssertEqual(chmod(path, mode_t(0o400)), 0, file: file, line: line)
        XCTAssertEqual(
            try inventory(root),
            [H4P.finalLeafName],
            file: file,
            line: line
        )
    }

    private func assertPublishedInvalid(
        _ outcome: H4P.RetainedInspectionOutcome,
        _ expected: H4P.RetainedInspectionFailure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .publishedInvalid(let failure) = outcome else {
            return XCTFail(
                "Expected published-invalid inspection", file: file, line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertInspectionUnavailable(
        _ outcome: H4P.RetainedInspectionOutcome,
        _ expected: H4P.RetainedInspectionFailure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .unavailable(let failure) = outcome else {
            return XCTFail(
                "Expected unavailable inspection", file: file, line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertUnavailable(
        _ outcome: H4P.Outcome,
        _ expected: H4P.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .unavailable(let failure) = outcome else {
            return XCTFail("Expected unavailable outcome", file: file, line: line)
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertRejected(
        _ outcome: H4P.Outcome,
        _ expected: H4P.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .rejectedBeforePublication(let failure) = outcome else {
            return XCTFail(
                "Expected rejected-before-publication", file: file, line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    func testDescriptorRootedImagePublicationReconstructsOneExactRow() throws {
        let value = try bound()
        let (coordinator, root) = try coordinator(bound: value)
        guard case .admitted(let receipt) = coordinator.persist() else {
            return XCTFail("Expected admitted H4-D2b receipt")
        }

        XCTAssertEqual(receipt.schema, H4P.schema)
        XCTAssertEqual(receipt.rowCount, 1)
        XCTAssertTrue(receipt.inMemoryCommitExact)
        XCTAssertTrue(receipt.serializedImageExact)
        XCTAssertTrue(receipt.prepublicationReconstructionExact)
        XCTAssertTrue(receipt.stagingFullSyncExact)
        XCTAssertTrue(receipt.exclusivePublicationExact)
        XCTAssertTrue(receipt.directorySyncExact)
        XCTAssertTrue(receipt.descriptorReadbackExact)
        XCTAssertTrue(receipt.writerClosed)
        XCTAssertTrue(receipt.readOnlyReopenExact)
        XCTAssertTrue(receipt.schemaExact)
        XCTAssertTrue(receipt.canonicalCBORExact)
        XCTAssertTrue(receipt.indexedFieldsExact)
        XCTAssertTrue(receipt.jsonRoundTripExact)
        XCTAssertTrue(receipt.cborRoundTripExact)
        XCTAssertTrue(receipt.semanticJoinExact)
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)

        let snapshot = try H4P.inspectTestStore(rootURL: root)
        XCTAssertEqual(snapshot.inventory, [H4P.finalLeafName])
        XCTAssertTrue(snapshot.published)
        XCTAssertEqual(snapshot.fileMode, 0o400)
        XCTAssertNotNil(snapshot.fileSize)
        XCTAssertGreaterThan(snapshot.fileSize ?? 0, 0)
        XCTAssertEqual(snapshot.fileSize! % H4P.pageSize, 0)
        XCTAssertLessThanOrEqual(
            snapshot.fileSize!, H4P.maximumDatabasePages * H4P.pageSize
        )
        XCTAssertTrue(snapshot.headerExact)
        XCTAssertEqual(snapshot.userVersion, H4P.userVersion)
        XCTAssertEqual(snapshot.applicationID, H4P.applicationID)
        XCTAssertEqual(snapshot.schemaEntryCount, 1)
        XCTAssertEqual(snapshot.rowCount, 1)
        assertUnavailable(coordinator.persist(), .alreadyConsumed)
    }

    func testCopiesReplayAndDistinctOwnersRemainExact() throws {
        let copied = try bound()
        let first = try coordinator(bound: copied)
        let second = try coordinator(bound: copied)
        guard case .admitted = first.0.persist() else {
            return XCTFail("Expected copied handoff winner")
        }
        assertUnavailable(second.0.persist(), .alreadyConsumed)
        XCTAssertEqual(try inventory(second.1), [])

        let independentFirst = try coordinator(bound: bound()).0
        let independentSecond = try coordinator(bound: bound()).0
        guard case .admitted = independentFirst.persist(),
              case .admitted = independentSecond.persist() else {
            return XCTFail("Distinct owners must remain independent")
        }
    }

    func testStoreGrantOwnerLifetimeAndSharedReplayAreExact() throws {
        let expired = try coordinator(
            bound: bound(),
            storeValidThroughTick: 10,
            storeReadTick: { 11 }
        )
        assertUnavailable(expired.0.persist(), .expired)
        assertUnavailable(expired.0.persist(), .poisoned)
        XCTAssertEqual(try inventory(expired.1), [])

        let equality = try coordinator(
            bound: bound(),
            storeValidThroughTick: 10,
            storeReadTick: { 10 }
        ).0
        guard case .admitted = equality.persist() else {
            return XCTFail("Inclusive grant deadline equality must pass")
        }

        let precommitTick = SequenceTick([9, 11])
        let precommit = try coordinator(
            bound: bound(),
            storeValidThroughTick: 10,
            storeReadTick: { precommitTick.read() }
        )
        assertRejected(precommit.0.persist(), .expired)
        assertUnavailable(precommit.0.persist(), .poisoned)
        XCTAssertEqual(try inventory(precommit.1), [])

        let sharedRoot = try privateRoot()
        let shared = try H4P.makeTestSharedStoreCoordinators(
            bounds: [bound(), bound()], rootURL: sharedRoot
        )
        guard case .admitted = shared[0].persist() else {
            return XCTFail("Shared grant winner expected")
        }
        assertUnavailable(shared[1].persist(), .alreadyConsumed)
        assertUnavailable(shared[1].persist(), .poisoned)

        let mismatchRoot = try privateRoot()
        let mismatch = try H4P.makeTestSharedStoreCoordinators(
            bounds: [bound(), bound()], rootURL: mismatchRoot
        )
        assertUnavailable(mismatch[1].persist(), .storeAdmissionRejected)
        assertUnavailable(mismatch[0].persist(), .poisoned)
        XCTAssertEqual(try inventory(mismatchRoot), [])
    }

    func testCompletionMismatchConvergesParticipatingOwnerAndGrant() throws {
        let root = try privateRoot()
        let shared = try H4P.makeTestSharedStoreCoordinators(
            bounds: [bound(), bound()],
            rootURL: root,
            rejectStoreCompletionForTest: true
        )
        XCTAssertEqual(
            shared[0].persist(),
            .publishedUnverified(.leaseCompletionRejected)
        )
        assertUnavailable(
            shared[0].persist(), .persistenceRequiresInspection
        )
        assertUnavailable(
            shared[1].persist(), .persistenceRequiresInspection
        )
        assertUnavailable(shared[1].persist(), .poisoned)
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
    }

    func testStoreCompletionMismatchIsAtomicAcrossCopiedOwner() throws {
        let copied = try bound()
        let primaryRoot = try privateRoot()
        let observerRoot = try privateRoot()
        let intersticeEntered = DispatchSemaphore(value: 0)
        let releaseInterstice = DispatchSemaphore(value: 0)
        let primaryDone = DispatchSemaphore(value: 0)
        let observerDone = DispatchSemaphore(value: 0)
        let outcomes = LockedOutcomes()
        let primary = try H4P.makeTestCoordinator(
            bound: copied,
            rootURL: primaryRoot,
            rejectStoreCompletionForTest: true,
            completionIntersticeForTest: {
                intersticeEntered.signal()
                releaseInterstice.wait()
            }
        )
        let observer = try H4P.makeTestCoordinator(
            bound: copied,
            rootURL: observerRoot
        )
        let queue = DispatchQueue(
            label: "h4d2b.store-completion-atomicity",
            attributes: .concurrent
        )

        queue.async {
            outcomes.append(primary.persist())
            primaryDone.signal()
        }
        XCTAssertEqual(intersticeEntered.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(
            observer.probeTransitionForTestOnly(), .ownerBlocked
        )
        queue.async {
            outcomes.append(observer.persist())
            observerDone.signal()
        }
        releaseInterstice.signal()
        XCTAssertEqual(primaryDone.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(observerDone.wait(timeout: .now() + 5), .success)

        let values = outcomes.snapshot()
        XCTAssertEqual(values.filter {
            $0 == .publishedUnverified(.leaseCompletionRejected)
        }.count, 1)
        XCTAssertEqual(values.filter {
            $0 == .unavailable(.persistenceRequiresInspection)
        }.count, 1)
        XCTAssertEqual(try inventory(primaryRoot), [H4P.finalLeafName])
        XCTAssertEqual(try inventory(observerRoot), [])
    }

    func testOwnerCompletionMismatchIsAtomicAcrossSharedStore() throws {
        let root = try privateRoot()
        let intersticeEntered = DispatchSemaphore(value: 0)
        let releaseInterstice = DispatchSemaphore(value: 0)
        let primaryDone = DispatchSemaphore(value: 0)
        let observerDone = DispatchSemaphore(value: 0)
        let outcomes = LockedOutcomes()
        let shared = try H4P.makeTestSharedStoreCoordinators(
            bounds: [bound(), bound()],
            rootURL: root,
            rejectOwnerCompletionForTest: true,
            completionIntersticeForTest: {
                intersticeEntered.signal()
                releaseInterstice.wait()
            }
        )
        let queue = DispatchQueue(
            label: "h4d2b.owner-completion-atomicity",
            attributes: .concurrent
        )

        queue.async {
            outcomes.append(shared[0].persist())
            primaryDone.signal()
        }
        XCTAssertEqual(intersticeEntered.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(
            shared[1].probeTransitionForTestOnly(), .storeBlocked
        )
        queue.async {
            outcomes.append(shared[1].persist())
            observerDone.signal()
        }
        releaseInterstice.signal()
        XCTAssertEqual(primaryDone.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(observerDone.wait(timeout: .now() + 5), .success)

        let values = outcomes.snapshot()
        XCTAssertEqual(values.filter {
            $0 == .publishedUnverified(.leaseCompletionRejected)
        }.count, 1)
        XCTAssertEqual(values.filter {
            $0 == .unavailable(.persistenceRequiresInspection)
        }.count, 1)
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
        assertUnavailable(shared[1].persist(), .poisoned)
    }

    func testConcurrentPersistenceHasOneWinner() throws {
        let (coordinator, root) = try coordinator(bound: bound())
        let queue = DispatchQueue(label: "h4d2b.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        let outcomes = LockedOutcomes()
        for _ in 0..<32 {
            group.enter()
            queue.async {
                outcomes.append(coordinator.persist())
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 10), .success)
        let values = outcomes.snapshot()
        XCTAssertEqual(values.filter {
            if case .admitted = $0 { return true }
            return false
        }.count, 1)
        XCTAssertEqual(values.filter {
            if case .unavailable(let failure) = $0 {
                return failure == .inProgress || failure == .alreadyConsumed
            }
            return false
        }.count, 31)
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
    }

    func testExpiryBeforePersistenceClaimPoisonsWithoutFilesystemMutation() throws {
        let tick = LockedTick(UInt64.max - 1)
        let value = try bound(
            validThroughTick: UInt64.max - 1,
            readTick: { tick.read() }
        )
        let (coordinator, root) = try coordinator(bound: value)
        tick.set(UInt64.max)
        assertUnavailable(coordinator.persist(), .expired)
        assertUnavailable(coordinator.persist(), .poisoned)
        XCTAssertEqual(try inventory(root), [])
    }

    func testEveryPrepublicationFaultLeavesExactEmptyRootAndPoisons() throws {
        let schedules: [(H4P.TestFault, H4P.Failure)] = [
            (.beforeBegin, .transactionRejected),
            (.afterBegin, .transactionRejected),
            (.afterSchema, .transactionRejected),
            (.afterInsert, .transactionRejected),
            (.serializeRejected, .serializationRejected),
            (.serializedOversize, .serializationRejected),
            (.serializedMisaligned, .serializationRejected),
            (.serializedBadHeader, .serializationRejected),
            (.writerCloseRejected, .closeRejected),
            (.prepublicationDeserializeRejected, .reconstructionRejected),
            (.prepublicationSchemaRejected, .reconstructionRejected),
            (.prepublicationRowRejected, .reconstructionRejected),
            (.prepublicationSemanticRejected, .reconstructionRejected),
            (.prepublicationCloseRejected, .closeRejected),
        ]
        for (fault, expected) in schedules {
            let (coordinator, root) = try coordinator(
                bound: bound(), fault: fault
            )
            assertRejected(coordinator.persist(), expected)
            assertUnavailable(coordinator.persist(), .poisoned)
            XCTAssertEqual(try inventory(root), [], "\(fault)")
        }
    }

    func testLostInMemoryCommitResponseIsTerminalWithNoPublishedBytes() throws {
        let (coordinator, root) = try coordinator(
            bound: bound(), fault: .commitResponseLost
        )
        XCTAssertEqual(
            coordinator.persist(),
            .transactionOutcomeUnknown(.commitOutcomeUnknown)
        )
        assertUnavailable(coordinator.persist(), .persistenceRequiresInspection)
        XCTAssertEqual(try inventory(root), [])
    }

    func testEveryPreRenamePhysicalFaultRetainsOnlyStaging() throws {
        let schedules: [(H4P.TestFault, H4P.Failure)] = [
            (.afterStagingCreation, .stagingCreationRejected),
            (.truncateRejected, .truncateRejected),
            (.pwriteRejected, .writeRejected),
            (.pwriteZero, .writeRejected),
            (.pwriteShort, .writeRejected),
            (.pwriteOverrun, .writeRejected),
            (.modeSealRejected, .modeSealRejected),
            (.stagingStatRejected, .identityRejected),
            (.fsyncRejected, .syncRejected),
            (.fullSyncRejected, .syncRejected),
            (.stagingReadbackMismatch, .readbackRejected),
        ]
        for (fault, expected) in schedules {
            let (coordinator, root) = try coordinator(
                bound: bound(), fault: fault
            )
            XCTAssertEqual(coordinator.persist(), .stagingRetained(expected))
            assertUnavailable(
                coordinator.persist(), .persistenceRequiresInspection
            )
            XCTAssertEqual(try inventory(root), [H4P.stagingLeafName], "\(fault)")
            XCTAssertFalse(FileManager.default.fileExists(
                atPath: H4P.finalTestURL(in: root).path
            ))
        }
    }

    func testExpiryAfterFullSyncRetainsStagingAndNeverPublishes() throws {
        let tick = SequenceTick([9, 9, 9, 11])
        let (coordinator, root) = try coordinator(
            bound: bound(),
            storeValidThroughTick: 10,
            storeReadTick: { tick.read() }
        )
        XCTAssertEqual(coordinator.persist(), .stagingRetained(.expired))
        assertUnavailable(coordinator.persist(), .persistenceRequiresInspection)
        XCTAssertEqual(try inventory(root), [H4P.stagingLeafName])
    }

    func testPostGrantNamespaceMutationIsPrepublicationStateUnknown() throws {
        for leaf in [".unknown", H4P.stagingLeafName, H4P.finalLeafName] {
            let (coordinator, root) = try coordinator(bound: bound())
            try createLeaf(leaf, in: root)
            guard case .prepublicationStateUnknown = coordinator.persist() else {
                return XCTFail("Expected prepublication-state-unknown for \(leaf)")
            }
            assertUnavailable(
                coordinator.persist(), .persistenceRequiresInspection
            )
        }
    }

    func testRenameEntryNeverDowngradesPublicationUnknown() throws {
        do {
            let (coordinator, root) = try coordinator(
                bound: bound(), fault: .renameResponseLost
            )
            XCTAssertEqual(
                coordinator.persist(),
                .publicationOutcomeUnknown(.publicationRejected)
            )
            assertUnavailable(
                coordinator.persist(), .persistenceRequiresInspection
            )
            XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
        }

        do {
            let (coordinator, root) = try coordinator(
                bound: bound(), fault: .renameCollision
            )
            XCTAssertEqual(
                coordinator.persist(),
                .publicationOutcomeUnknown(.publicationRejected)
            )
            assertUnavailable(
                coordinator.persist(), .persistenceRequiresInspection
            )
            XCTAssertEqual(
                try inventory(root),
                [H4P.stagingLeafName, H4P.finalLeafName].sorted()
            )
        }
    }

    func testEveryPostPublicationFaultRetainsEvidenceAndNeverAdmits() throws {
        let schedules: [(H4P.TestFault, H4P.Failure)] = [
            (.finalInventoryRejected, .storeAdmissionRejected),
            (.directorySyncRejected, .directorySyncRejected),
            (.finalOpenRejected, .finalOpenRejected),
            (.finalIdentityRejected, .identityRejected),
            (.finalReadbackMismatch, .readbackRejected),
            (.finalDeserializeRejected, .reconstructionRejected),
            (.finalSchemaRejected, .reconstructionRejected),
            (.finalRowRejected, .reconstructionRejected),
            (.finalSemanticRejected, .reconstructionRejected),
            (.finalReaderCloseRejected, .closeRejected),
            (.finalDescriptorCloseRejected, .closeRejected),
            (.parentReboundAfterPublish, .storeAdmissionRejected),
        ]
        for (fault, expected) in schedules {
            let (coordinator, root) = try coordinator(
                bound: bound(), fault: fault
            )
            guard case .publishedUnverified(let observed) = coordinator.persist() else {
                return XCTFail("Expected published-unverified for \(fault)")
            }
            XCTAssertEqual(observed, expected, "\(fault)")
            assertUnavailable(
                coordinator.persist(), .persistenceRequiresInspection
            )
            if fault == .parentReboundAfterPublish {
                XCTAssertEqual(try inventory(root), [])
                XCTAssertEqual(
                    try inventory(URL(
                        fileURLWithPath: root.path + ".h4d2b-displaced",
                        isDirectory: true
                    )),
                    [H4P.finalLeafName]
                )
            } else if fault == .finalIdentityRejected {
                XCTAssertEqual(
                    try inventory(root),
                    [".h4d2b-displaced", H4P.finalLeafName].sorted()
                )
            } else if fault == .finalInventoryRejected {
                XCTAssertEqual(
                    try inventory(root),
                    [".h4d2b-unexpected", H4P.finalLeafName].sorted()
                )
            } else {
                XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
            }
        }
    }

    func testRootAdmissionRejectsAliasesModesEntriesAndCompetingLock() throws {
        for leaf in [
            H4P.finalLeafName,
            H4P.stagingLeafName,
            H4P.finalLeafName + "-journal",
            H4P.finalLeafName + "-wal",
            H4P.finalLeafName + "-shm",
            ".hidden",
        ] {
            let root = try privateRoot()
            try createLeaf(leaf, in: root)
            XCTAssertThrowsError(try H4P.makeTestCoordinator(
                bound: bound(), rootURL: root
            )) { XCTAssertEqual($0 as? H4P.Failure, .storeAdmissionRejected) }
        }

        let directoryRoot = try privateRoot()
        try FileManager.default.createDirectory(
            at: directoryRoot.appendingPathComponent("nested", isDirectory: true),
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        XCTAssertThrowsError(try H4P.makeTestCoordinator(
            bound: bound(), rootURL: directoryRoot
        ))

        let target = try privateRoot()
        let linkParent = try privateRoot()
        let alias = linkParent.appendingPathComponent("alias", isDirectory: true)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: target)
        XCTAssertThrowsError(try H4P.makeTestCoordinator(
            bound: bound(), rootURL: alias
        ))

        let modeRoot = try privateRoot()
        XCTAssertEqual(chmod(modeRoot.path, mode_t(0o755)), 0)
        XCTAssertThrowsError(try H4P.makeTestCoordinator(
            bound: bound(), rootURL: modeRoot
        ))

        let lockedRoot = try privateRoot()
        let held = try H4P.makeTestCoordinator(
            bound: bound(), rootURL: lockedRoot
        )
        try withExtendedLifetime(held) {
            XCTAssertThrowsError(try H4P.makeTestCoordinator(
                bound: bound(), rootURL: lockedRoot
            )) { XCTAssertEqual($0 as? H4P.Failure, .storeAdmissionRejected) }
        }
    }

    func testCanariesNeverReachImageReceiptErrorsOrReflection() throws {
        let diagnostic = "H4D2B-RAW-DIAGNOSTIC-CANARY"
        let rootCanary = String(repeating: "d", count: 64)
        let value = try bound(source: source(
            rawDiagnostic: Data(diagnostic.utf8),
            receiptRoot: rootCanary
        ))
        let canonicalJSON = value.canonicalTest.json
        let (coordinator, root) = try coordinator(bound: value)
        guard case .admitted(let receipt) = coordinator.persist() else {
            return XCTFail("Expected canary fixture admission")
        }
        let image = try Data(contentsOf: H4P.finalTestURL(in: root))
        XCTAssertNil(image.range(of: canonicalJSON))
        let rendered = [
            String(decoding: image, as: UTF8.self),
            String(reflecting: receipt),
            String(reflecting: coordinator),
            String(reflecting: H4P.Failure.reconstructionRejected),
        ].joined(separator: "\n")
        for forbidden in [
            diagnostic, rootCanary, epoch, root.path,
            "envelopeIdentity", "ownerAnchor", "sqlite3_errmsg",
        ] {
            XCTAssertFalse(rendered.contains(forbidden), forbidden)
        }
        XCTAssertEqual(Mirror(reflecting: coordinator).children.count, 0)
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
    }

    func testRetainedV2InspectionIsCBOROnlyAndNeverAdmits() throws {
        let root = try publishedRoot()
        let inspector = try H4P.makeTestRetainedV2Inspector(rootURL: root)
        let copied = inspector
        guard case .validV2CBOROnlyJSONMissing(let receipt) =
                inspector.inspectRetainedV2Image() else {
            return XCTFail("Expected valid v2 inspection-only classification")
        }
        XCTAssertEqual(
            receipt.schema,
            "com.ergentics.provenance.hypervisor.h4.retained-image-inspection.v1"
        )
        XCTAssertEqual(receipt.classification, "VALID_V2_CBOR_ONLY_JSON_MISSING")
        XCTAssertTrue(receipt.sqliteImageExact)
        XCTAssertTrue(receipt.canonicalCBORExact)
        XCTAssertTrue(receipt.indexedFieldsExact)
        XCTAssertFalse(receipt.independentJSONPresent)
        XCTAssertFalse(receipt.dualStreamJoinExact)
        XCTAssertFalse(receipt.admitted)
        XCTAssertFalse(receipt.h4Entered)
        XCTAssertEqual(receipt.authorityVector, "00000000")
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)
        assertInspectionUnavailable(
            copied.inspectRetainedV2Image(), .alreadyConsumed
        )
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
    }

    func testRetainedV2NamespaceClassificationIsExactAndNonmutating() throws {
        let empty = try privateRoot()
        XCTAssertEqual(
            try H4P.makeTestRetainedV2Inspector(rootURL: empty)
                .inspectRetainedV2Image(),
            .empty
        )
        XCTAssertEqual(try inventory(empty), [])

        let staging = try privateRoot()
        try createLeaf(H4P.stagingLeafName, in: staging, mode: 0o400)
        XCTAssertEqual(
            try H4P.makeTestRetainedV2Inspector(rootURL: staging)
                .inspectRetainedV2Image(),
            .stagingRetained
        )
        XCTAssertEqual(try inventory(staging), [H4P.stagingLeafName])

        let both = try privateRoot()
        try createLeaf(H4P.stagingLeafName, in: both, mode: 0o400)
        try createLeaf(H4P.finalLeafName, in: both, mode: 0o400)
        XCTAssertEqual(
            try H4P.makeTestRetainedV2Inspector(rootURL: both)
                .inspectRetainedV2Image(),
            .namespaceAmbiguous
        )
        XCTAssertEqual(
            try inventory(both),
            [H4P.finalLeafName, H4P.stagingLeafName].sorted()
        )

        let unknown = try privateRoot()
        try createLeaf(".unknown", in: unknown, mode: 0o400)
        XCTAssertEqual(
            try H4P.makeTestRetainedV2Inspector(rootURL: unknown)
                .inspectRetainedV2Image(),
            .namespaceAmbiguous
        )
        XCTAssertEqual(try inventory(unknown), [".unknown"])
    }

    func testRetainedV2NonfinalClassificationsRequireTerminalJoins() throws {
        let empty = try privateRoot()
        let emptyInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: empty,
            afterInitialInventoryForTest: {
                _ = FileManager.default.createFile(
                    atPath: empty.appendingPathComponent(".late").path,
                    contents: Data(),
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
            }
        )
        assertInspectionUnavailable(
            emptyInspector.inspectRetainedV2Image(), .namespaceRejected
        )

        let staging = try privateRoot()
        try createLeaf(H4P.stagingLeafName, in: staging, mode: 0o400)
        let stagingInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: staging,
            afterInitialInventoryForTest: {
                _ = FileManager.default.createFile(
                    atPath: H4P.finalTestURL(in: staging).path,
                    contents: Data(),
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
            }
        )
        assertInspectionUnavailable(
            stagingInspector.inspectRetainedV2Image(), .namespaceRejected
        )

        let ambiguous = try privateRoot()
        try createLeaf(H4P.stagingLeafName, in: ambiguous, mode: 0o400)
        try createLeaf(H4P.finalLeafName, in: ambiguous, mode: 0o400)
        let ambiguousInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: ambiguous,
            afterInitialInventoryForTest: {
                _ = FileManager.default.createFile(
                    atPath: ambiguous.appendingPathComponent(".late").path,
                    contents: Data(),
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
            }
        )
        assertInspectionUnavailable(
            ambiguousInspector.inspectRetainedV2Image(), .namespaceRejected
        )

        let unknown = try privateRoot()
        try createLeaf(".unknown", in: unknown, mode: 0o400)
        let unknownInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: unknown,
            afterInitialInventoryForTest: {
                _ = FileManager.default.createFile(
                    atPath: unknown.appendingPathComponent(".late").path,
                    contents: Data(),
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
            }
        )
        assertInspectionUnavailable(
            unknownInspector.inspectRetainedV2Image(), .namespaceRejected
        )

        let rebound = try privateRoot()
        let originalPath = rebound.path
        let displacedPath = originalPath + ".h4d2b-displaced"
        let reboundInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: rebound,
            afterInitialInventoryForTest: {
                _ = rename(originalPath, displacedPath)
                _ = mkdir(originalPath, mode_t(0o700))
            }
        )
        assertInspectionUnavailable(
            reboundInspector.inspectRetainedV2Image(), .rootRejected
        )
    }

    func testRetainedV2RejectsNonregularModeLinkAndSizeShapes() throws {
        let symlinkRoot = try privateRoot()
        XCTAssertEqual(
            symlink("/dev/null", H4P.finalTestURL(in: symlinkRoot).path),
            0
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: symlinkRoot)
                .inspectRetainedV2Image(),
            .identityRejected
        )

        let fifoRoot = try privateRoot()
        XCTAssertEqual(
            mkfifo(H4P.finalTestURL(in: fifoRoot).path, mode_t(0o400)),
            0
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: fifoRoot)
                .inspectRetainedV2Image(),
            .identityRejected
        )

        let reboundFIFO = try publishedRoot()
        let reboundFinal = H4P.finalTestURL(in: reboundFIFO)
        let displacedFinal = reboundFIFO.appendingPathComponent(
            ".h4d2c-regular-displaced", isDirectory: false
        )
        let reboundFIFOInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: reboundFIFO,
            afterNamedFinalForTest: {
                _ = rename(reboundFinal.path, displacedFinal.path)
                _ = mkfifo(reboundFinal.path, mode_t(0o400))
            }
        )
        assertPublishedInvalid(
            reboundFIFOInspector.inspectRetainedV2Image(), .identityRejected
        )
        assertInspectionUnavailable(
            reboundFIFOInspector.inspectRetainedV2Image(), .alreadyConsumed
        )

        let modeRoot = try privateRoot()
        try createLeaf(
            H4P.finalLeafName,
            in: modeRoot,
            mode: 0o600,
            contents: Data(repeating: 0, count: Int(H4P.pageSize))
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: modeRoot)
                .inspectRetainedV2Image(),
            .identityRejected
        )

        let sizeRoot = try privateRoot()
        try createLeaf(
            H4P.finalLeafName,
            in: sizeRoot,
            mode: 0o400,
            contents: Data(repeating: 0, count: Int(H4P.pageSize) + 1)
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: sizeRoot)
                .inspectRetainedV2Image(),
            .identityRejected
        )

        let oversized = try privateRoot()
        try createLeaf(
            H4P.finalLeafName,
            in: oversized,
            mode: 0o400,
            contents: Data(
                repeating: 0,
                count: Int(H4P.maximumDatabasePages * H4P.pageSize + 1)
            )
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: oversized)
                .inspectRetainedV2Image(),
            .identityRejected
        )

        let linked = try publishedRoot()
        let external = linked.path + ".h4d2c-hardlink"
        addTeardownBlock { try? FileManager.default.removeItem(atPath: external) }
        XCTAssertEqual(link(H4P.finalTestURL(in: linked).path, external), 0)
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: linked)
                .inspectRetainedV2Image(),
            .identityRejected
        )
    }

    func testRetainedV2RejectsHeaderSchemaRowAndCBORDivergence() throws {
        let header = try publishedRoot()
        let headerURL = H4P.finalTestURL(in: header)
        var bytes = try Data(contentsOf: headerURL)
        bytes[bytes.startIndex] ^= 0xff
        XCTAssertEqual(chmod(headerURL.path, mode_t(0o600)), 0)
        try bytes.write(to: headerURL)
        XCTAssertEqual(chmod(headerURL.path, mode_t(0o400)), 0)
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: header)
                .inspectRetainedV2Image(),
            .sqliteRejected
        )

        let schema = try publishedRoot()
        try mutatePublishedDatabase(
            schema,
            sql: "CREATE TABLE unexpected(value INTEGER)"
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: schema)
                .inspectRetainedV2Image(),
            .sqliteRejected
        )

        let indexed = try publishedRoot()
        try mutatePublishedDatabase(
            indexed,
            sql: "UPDATE h4_receipts SET predicate_count=20 WHERE singleton=1"
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: indexed)
                .inspectRetainedV2Image(),
            .cborRejected
        )

        let cbor = try publishedRoot()
        try mutatePublishedDatabase(
            cbor,
            sql: "UPDATE h4_receipts SET canonical_cbor=X'00' WHERE singleton=1"
        )
        assertPublishedInvalid(
            try H4P.makeTestRetainedV2Inspector(rootURL: cbor)
                .inspectRetainedV2Image(),
            .cborRejected
        )
    }

    func testRetainedV2RejectsFinalAndParentReboundDuringInspection() throws {
        let finalRoot = try publishedRoot()
        let finalURL = H4P.finalTestURL(in: finalRoot)
        let finalBytes = try Data(contentsOf: finalURL)
        let displacedURL = finalRoot.appendingPathComponent(
            ".h4d2c-displaced", isDirectory: false
        )
        let finalInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: finalRoot,
            afterNamedFinalForTest: {
                _ = rename(finalURL.path, displacedURL.path)
                _ = FileManager.default.createFile(
                    atPath: finalURL.path,
                    contents: finalBytes,
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
                _ = chmod(finalURL.path, mode_t(0o400))
            }
        )
        assertPublishedInvalid(
            finalInspector.inspectRetainedV2Image(), .identityRejected
        )

        let postReadRoot = try publishedRoot()
        let postReadFinal = H4P.finalTestURL(in: postReadRoot)
        let postReadBytes = try Data(contentsOf: postReadFinal)
        let postReadDisplaced = postReadRoot.path + ".h4d2c-postread-held"
        addTeardownBlock {
            try? FileManager.default.removeItem(atPath: postReadDisplaced)
        }
        let postReadInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: postReadRoot,
            afterReadForTest: {
                _ = rename(postReadFinal.path, postReadDisplaced)
                _ = FileManager.default.createFile(
                    atPath: postReadFinal.path,
                    contents: postReadBytes,
                    attributes: [.posixPermissions: NSNumber(value: 0o400)]
                )
                _ = chmod(postReadFinal.path, mode_t(0o400))
            }
        )
        assertPublishedInvalid(
            postReadInspector.inspectRetainedV2Image(), .identityRejected
        )

        let parentRoot = try publishedRoot()
        let originalPath = parentRoot.path
        let displacedPath = originalPath + ".h4d2b-displaced"
        let parentInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: parentRoot,
            afterReadForTest: {
                _ = rename(originalPath, displacedPath)
                _ = mkdir(originalPath, mode_t(0o700))
            }
        )
        assertPublishedInvalid(
            parentInspector.inspectRetainedV2Image(), .rootRejected
        )

        let terminalRoot = try publishedRoot()
        let terminalOriginalPath = terminalRoot.path
        let terminalDisplacedPath =
            terminalOriginalPath + ".h4d2b-displaced"
        let terminalInspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: terminalRoot,
            beforeTerminalRootForTest: {
                _ = rename(terminalOriginalPath, terminalDisplacedPath)
                _ = mkdir(terminalOriginalPath, mode_t(0o700))
            }
        )
        assertPublishedInvalid(
            terminalInspector.inspectRetainedV2Image(), .rootRejected
        )
    }

    func testRetainedV2ConcurrentInspectionHasOneWinner() throws {
        let root = try publishedRoot()
        let winnerEntered = DispatchSemaphore(value: 0)
        let releaseWinner = DispatchSemaphore(value: 0)
        let inspector = try H4P.makeTestRetainedV2Inspector(
            rootURL: root,
            afterNamedFinalForTest: {
                winnerEntered.signal()
                releaseWinner.wait()
            }
        )
        let queue = DispatchQueue(
            label: "h4d2c.concurrent",
            attributes: .concurrent
        )
        let winnerGroup = DispatchGroup()
        let contenderGroup = DispatchGroup()
        let outcomes = LockedInspectionOutcomes()
        winnerGroup.enter()
        queue.async {
            outcomes.append(inspector.inspectRetainedV2Image())
            winnerGroup.leave()
        }
        XCTAssertEqual(winnerEntered.wait(timeout: .now() + 10), .success)
        for _ in 0..<31 {
            contenderGroup.enter()
            queue.async {
                outcomes.append(inspector.inspectRetainedV2Image())
                contenderGroup.leave()
            }
        }
        XCTAssertEqual(contenderGroup.wait(timeout: .now() + 10), .success)
        releaseWinner.signal()
        XCTAssertEqual(winnerGroup.wait(timeout: .now() + 10), .success)
        let values = outcomes.snapshot()
        XCTAssertEqual(values.filter {
            if case .validV2CBOROnlyJSONMissing = $0 { return true }
            return false
        }.count, 1)
        XCTAssertEqual(values.filter {
            if case .unavailable(let failure) = $0 {
                return failure == .inProgress
            }
            return false
        }.count, 31)
        XCTAssertEqual(try inventory(root), [H4P.finalLeafName])
    }

    func testRetainedV2RootAdmissionRejectsAliasModeAndWriterLock() throws {
        let target = try privateRoot()
        let linkParent = try privateRoot()
        let alias = linkParent.appendingPathComponent("alias", isDirectory: true)
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: target
        )
        XCTAssertThrowsError(
            try H4P.makeTestRetainedV2Inspector(rootURL: alias)
        ) {
            XCTAssertEqual(
                $0 as? H4P.RetainedInspectionFailure, .rootRejected
            )
        }

        let mode = try privateRoot()
        XCTAssertEqual(chmod(mode.path, mode_t(0o755)), 0)
        XCTAssertThrowsError(
            try H4P.makeTestRetainedV2Inspector(rootURL: mode)
        )

        let locked = try privateRoot()
        let descriptor = Darwin.open(
            locked.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        XCTAssertGreaterThanOrEqual(descriptor, 0)
        defer {
            if descriptor >= 0 {
                _ = flock(descriptor, LOCK_UN)
                _ = Darwin.close(descriptor)
            }
        }
        XCTAssertEqual(flock(descriptor, LOCK_EX | LOCK_NB), 0)
        XCTAssertThrowsError(
            try H4P.makeTestRetainedV2Inspector(rootURL: locked)
        )
    }

    func testFrozenSchemasAndAuthorityNonclaimsRemainExact() {
        XCTAssertEqual(
            H4P.schema,
            "com.ergentics.provenance.hypervisor.h4.sqlite-image-publication.v2"
        )
        XCTAssertEqual(H4P.applicationID, 1_162_891_828)
        XCTAssertEqual(H4P.userVersion, 1)
        XCTAssertEqual(H4P.maximumDatabasePages, 64)
        XCTAssertEqual(H4P.pageSize, 4_096)
        XCTAssertEqual(H4P.stagingLeafName, ".h4d2b-receipt.sqlite.staging")
        XCTAssertEqual(H4P.finalLeafName, "h4d2b-receipt.sqlite")
        XCTAssertEqual(H4C.maximumStreamBytes, 158)
        XCTAssertEqual(H4.ClaimState.allCases, [.observedNonPass])
        XCTAssertEqual(H4.ClaimState.observedNonPass.rawValue, "OBSERVED_NONPASS")
    }
}

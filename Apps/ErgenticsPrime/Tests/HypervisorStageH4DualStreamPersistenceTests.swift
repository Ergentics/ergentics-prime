import Darwin
import Foundation
import SQLite3
import XCTest

final class HypervisorStageH4DualStreamPersistenceTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4C = HypervisorStageH4CanonicalStreams
    private typealias H4D = HypervisorStageH4OwnerBinding
    private typealias H4P = HypervisorStageH4Persistence
    private typealias H4D3 = HypervisorStageH4DualStreamPersistence

    private let epoch = "44444444-4444-4444-8444-444444444444"

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

        init(_ values: [UInt64]) {
            precondition(!values.isEmpty)
            self.values = values
        }

        func read() -> UInt64 {
            lock.lock()
            defer { lock.unlock() }
            let position = min(index, values.count - 1)
            index += 1
            return values[position]
        }
    }

    private final class BlockingSecondTick: @unchecked Sendable {
        private let lock = NSLock()
        private var reads = 0
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)

        func read() -> UInt64 {
            lock.lock()
            reads += 1
            let shouldBlock = reads == 2
            lock.unlock()
            if shouldBlock {
                entered.signal()
                _ = release.wait(timeout: .now() + 10)
            }
            return 1
        }
    }

    private final class LockedOutcomes: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [H4D3.Outcome] = []

        func append(_ value: H4D3.Outcome) {
            lock.lock()
            values.append(value)
            lock.unlock()
        }

        func snapshot() -> [H4D3.Outcome] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }
    }

    private struct FileWitness: Equatable {
        let device: UInt64
        let inode: UInt64
        let mode: UInt16
        let uid: UInt32
        let gid: UInt32
        let linkCount: UInt16
        let size: Int64
        let flags: UInt32
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let changeSeconds: Int64
        let changeNanoseconds: Int64
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
        readTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }
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
        readTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }
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
        var template = Array("/private/tmp/epr-h4d3.XXXXXX\0".utf8)
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
            for suffix in [
                ".h4d3-displaced",
                ".h4d3-before-staging-displaced",
                ".h4d3-after-staging-displaced",
                ".h4d3-after-rename-displaced",
                ".h4d3-before-success-displaced",
            ] {
                try? FileManager.default.removeItem(atPath: root + suffix)
            }
        }
        return url
    }

    private func coordinator(
        bound: H4D.OwnerBoundCanonicalProjection,
        fault: H4D3.TestFault = .none,
        storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        },
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) throws -> (H4D.DualStreamPersistenceCoordinator, URL) {
        let root = try privateRoot()
        return (
            try H4D3.makeTestCoordinator(
                bound: bound,
                rootURL: root,
                fault: fault,
                storeValidThroughTick: storeValidThroughTick,
                storeReadTick: storeReadTick,
                rejectStoreCompletionForTest: rejectStoreCompletionForTest,
                rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
                completionIntersticeForTest: completionIntersticeForTest
            ),
            root
        )
    }

    private func inventory(_ root: URL) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: root.path).sorted()
    }

    private func createLeaf(
        _ leaf: String,
        in root: URL,
        mode: mode_t = 0o600,
        contents: Data = Data()
    ) throws {
        XCTAssertTrue(FileManager.default.createFile(
            atPath: root.appendingPathComponent(leaf).path,
            contents: contents,
            attributes: [.posixPermissions: NSNumber(value: mode)]
        ))
    }

    private func witness(
        _ url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> FileWitness {
        var value = stat()
        XCTAssertEqual(lstat(url.path, &value), 0, file: file, line: line)
        return FileWitness(
            device: UInt64(value.st_dev),
            inode: UInt64(value.st_ino),
            mode: UInt16(value.st_mode),
            uid: UInt32(value.st_uid),
            gid: UInt32(value.st_gid),
            linkCount: UInt16(value.st_nlink),
            size: Int64(value.st_size),
            flags: UInt32(value.st_flags),
            modificationSeconds: Int64(value.st_mtimespec.tv_sec),
            modificationNanoseconds: Int64(value.st_mtimespec.tv_nsec),
            changeSeconds: Int64(value.st_ctimespec.tv_sec),
            changeNanoseconds: Int64(value.st_ctimespec.tv_nsec)
        )
    }

    private func assertActuatedReplacement(
        in root: URL,
        namedLeaf: String,
        expectedType: mode_t,
        bytesMustMatch: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let displacedLeaf = H4D3.faultDisplacedLeafName
        XCTAssertEqual(
            try inventory(root),
            [displacedLeaf, namedLeaf].sorted(),
            file: file,
            line: line
        )
        let displacedURL = root.appendingPathComponent(displacedLeaf)
        let replacementURL = root.appendingPathComponent(namedLeaf)
        let displaced = try witness(displacedURL, file: file, line: line)
        let replacement = try witness(replacementURL, file: file, line: line)
        XCTAssertEqual(
            mode_t(displaced.mode) & S_IFMT,
            S_IFREG,
            file: file,
            line: line
        )
        XCTAssertEqual(
            mode_t(replacement.mode) & S_IFMT,
            expectedType,
            file: file,
            line: line
        )
        XCTAssertTrue(
            displaced.device != replacement.device ||
                displaced.inode != replacement.inode,
            file: file,
            line: line
        )
        if bytesMustMatch {
            XCTAssertEqual(
                try Data(contentsOf: displacedURL),
                try Data(contentsOf: replacementURL),
                file: file,
                line: line
            )
        }
    }

    private func assertUnavailable(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .unavailable(let failure) = outcome else {
            return XCTFail("Expected unavailable outcome", file: file, line: line)
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertRejected(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .rejectedBeforePublication(let failure) = outcome else {
            return XCTFail(
                "Expected rejected-before-publication outcome",
                file: file,
                line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertTransactionUnknown(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .transactionOutcomeUnknown(let failure) = outcome else {
            return XCTFail(
                "Expected transaction-outcome-unknown",
                file: file,
                line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertPrepublicationUnknown(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .prepublicationStateUnknown(let failure) = outcome else {
            return XCTFail(
                "Expected prepublication-state-unknown",
                file: file,
                line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertStagingRetained(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .stagingRetained(let failure) = outcome else {
            return XCTFail("Expected staging-retained", file: file, line: line)
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertPublicationUnknown(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .publicationOutcomeUnknown(let failure) = outcome else {
            return XCTFail(
                "Expected publication-outcome-unknown",
                file: file,
                line: line
            )
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertPublishedUnverified(
        _ outcome: H4D3.Outcome,
        _ expected: H4D3.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .publishedUnverified(let failure) = outcome else {
            return XCTFail("Expected published-unverified", file: file, line: line)
        }
        XCTAssertEqual(failure, expected, file: file, line: line)
    }

    private func assertAtMostOneEnteredCall(
        _ snapshot: H4D3.TestEnteredCallSnapshot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertLessThanOrEqual(snapshot.commit, 1, file: file, line: line)
        XCTAssertLessThanOrEqual(
            snapshot.stagingCreate, 1, file: file, line: line
        )
        XCTAssertLessThanOrEqual(snapshot.pwrite, 1, file: file, line: line)
        XCTAssertLessThanOrEqual(snapshot.rename, 1, file: file, line: line)
        XCTAssertLessThanOrEqual(snapshot.finalOpen, 1, file: file, line: line)
    }

    @discardableResult
    private func assertPrimitiveEvent(
        _ calls: H4D3.TestEnteredCalls,
        kind: H4D3.TestPrimitiveKind,
        backendInvoked: Bool,
        backendReturn: Int64?,
        effectiveReturn: Int64,
        error: Int32?,
        origin: H4D3.TestPrimitiveOrigin,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> H4D3.TestPrimitiveEvent? {
        let events = calls.evidenceSnapshot().primitiveEvents
        let matches = events.filter { $0.kind == kind }
        XCTAssertEqual(matches.count, 1, file: file, line: line)
        guard let event = matches.first else { return nil }
        XCTAssertEqual(event.backendInvoked, backendInvoked, file: file, line: line)
        XCTAssertEqual(event.backendReturn, backendReturn, file: file, line: line)
        XCTAssertEqual(event.effectiveReturn, effectiveReturn, file: file, line: line)
        XCTAssertEqual(event.error, error, file: file, line: line)
        XCTAssertEqual(event.origin, origin, file: file, line: line)
        XCTAssertEqual(events.last?.kind, kind, file: file, line: line)
        if kind != .completeImagePwrite {
            XCTAssertNil(event.requestedCount, file: file, line: line)
        }
        let expectedSequence: UInt32
        switch kind {
        case .publicationSerialize: expectedSequence = 1
        case .prepublicationDeserialize: expectedSequence = 2
        case .completeImagePwrite: expectedSequence = 3
        case .modeSeal: expectedSequence = 4
        case .stagingFSync: expectedSequence = 5
        case .stagingFullSync: expectedSequence = 6
        case .publicationRename: expectedSequence = 7
        case .directoryFSync: expectedSequence = 8
        case .finalOpen: expectedSequence = 9
        case .finalDeserialize: expectedSequence = 10
        case .finalDescriptorClose: expectedSequence = 11
        }
        XCTAssertEqual(
            event.boundarySequence,
            expectedSequence,
            file: file,
            line: line
        )
        let canonicalKinds: [H4D3.TestPrimitiveKind] = [
            .publicationSerialize,
            .prepublicationDeserialize,
            .completeImagePwrite,
            .modeSeal,
            .stagingFSync,
            .stagingFullSync,
            .publicationRename,
            .directoryFSync,
            .finalOpen,
            .finalDeserialize,
            .finalDescriptorClose,
        ]
        XCTAssertEqual(
            events.map(\.kind),
            Array(canonicalKinds.prefix(Int(expectedSequence))),
            file: file,
            line: line
        )
        return event
    }

    private func assertSuccessfulPrimitiveSequence(
        _ events: [H4D3.TestPrimitiveEvent],
        imageCount: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(events.map(\.kind), [
            .publicationSerialize,
            .prepublicationDeserialize,
            .completeImagePwrite,
            .modeSeal,
            .stagingFSync,
            .stagingFullSync,
            .publicationRename,
            .directoryFSync,
            .finalOpen,
            .finalDeserialize,
            .finalDescriptorClose,
        ], file: file, line: line)
        for (offset, event) in events.enumerated() {
            XCTAssertEqual(
                event.boundarySequence,
                UInt32(offset + 1),
                file: file,
                line: line
            )
            XCTAssertTrue(event.backendInvoked, file: file, line: line)
            XCTAssertEqual(event.origin, .backend, file: file, line: line)
            XCTAssertNil(event.error, file: file, line: line)
            XCTAssertEqual(
                event.backendReturn,
                event.effectiveReturn,
                file: file,
                line: line
            )
            switch event.kind {
            case .completeImagePwrite:
                XCTAssertEqual(event.requestedCount, imageCount, file: file, line: line)
                XCTAssertEqual(
                    event.effectiveReturn,
                    Int64(imageCount),
                    file: file,
                    line: line
                )
            case .finalOpen:
                XCTAssertNil(event.requestedCount, file: file, line: line)
                XCTAssertGreaterThanOrEqual(
                    event.effectiveReturn,
                    0,
                    file: file,
                    line: line
                )
            default:
                XCTAssertNil(event.requestedCount, file: file, line: line)
                XCTAssertEqual(event.effectiveReturn, 0, file: file, line: line)
            }
        }
    }

    private func assertHardenedReaderPolicy(
        _ policy: H4D3.TestReaderPolicyObservation?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(policy, .init(
            queryOnly: true,
            defensive: true,
            trustedSchema: false,
            dqsDDL: false,
            dqsDML: false,
            tempStoreMemory: true,
            foreignKeys: true,
            autocommit: true,
            transactionNone: true,
            filenameEmpty: true
        ), file: file, line: line)
    }

    func testFrozenFormatAndNamespaceRemainExactAndDisjointFromV2() {
        XCTAssertEqual(
            H4D3.schema,
            "com.ergentics.provenance.hypervisor.h4.dual-stream-sqlite-image-publication.v3"
        )
        XCTAssertEqual(H4D3.applicationID, 1_162_891_828)
        XCTAssertEqual(H4D3.userVersion, 2)
        XCTAssertEqual(H4D3.maximumDatabasePages, 64)
        XCTAssertEqual(H4D3.pageSize, 4_096)
        XCTAssertEqual(
            H4D3.stagingLeafName,
            ".h4d3-dual-receipt.sqlite.staging"
        )
        XCTAssertEqual(H4D3.finalLeafName, "h4d3-dual-receipt.sqlite")
        XCTAssertNotEqual(H4D3.stagingLeafName, H4P.stagingLeafName)
        XCTAssertNotEqual(H4D3.finalLeafName, H4P.finalLeafName)
        XCTAssertEqual(H4C.maximumStreamBytes, 158)
        XCTAssertEqual(H4.ClaimState.allCases, [.observedNonPass])
        XCTAssertEqual(
            H4.ClaimState.observedNonPass.rawValue,
            "OBSERVED_NONPASS"
        )
    }

    func testExactDualStreamsScalarsPoliciesAndReceiptAreJoined() throws {
        let value = try bound()
        let expected = value.canonicalTest
        let root = try privateRoot()
        let (coordinator, calls) =
            try H4D3.makeTestCoordinatorWithCounters(
                bound: value,
                rootURL: root
            )
        let outcome = coordinator.persist()
        guard case .admitted(let receipt) = outcome else {
            return XCTFail("Expected admitted H4-D3 fixture receipt: \(outcome)")
        }

        XCTAssertEqual(receipt.schema, H4D3.schema)
        XCTAssertEqual(receipt.rowCount, 1)
        XCTAssertTrue(receipt.sqliteImageExact)
        XCTAssertTrue(receipt.canonicalJSONRetainedExact)
        XCTAssertTrue(receipt.canonicalCBORRetainedExact)
        XCTAssertTrue(receipt.indexedFieldsExact)
        XCTAssertTrue(receipt.writerThreeWayJoinExact)
        XCTAssertFalse(receipt.restartAdopted)
        XCTAssertFalse(receipt.h4Entered)
        XCTAssertEqual(receipt.authorityVector, "00000000")
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)
        XCTAssertEqual(Mirror(reflecting: coordinator).children.count, 0)

        let snapshot = try H4D3.inspectTestStore(rootURL: root)
        XCTAssertEqual(snapshot.inventory, [H4D3.finalLeafName])
        XCTAssertTrue(snapshot.published)
        XCTAssertEqual(snapshot.fileMode, 0o400)
        XCTAssertNotNil(snapshot.fileSize)
        XCTAssertGreaterThan(snapshot.fileSize ?? 0, 0)
        XCTAssertEqual(snapshot.fileSize! % H4D3.pageSize, 0)
        XCTAssertLessThanOrEqual(
            snapshot.fileSize!,
            H4D3.maximumDatabasePages * H4D3.pageSize
        )
        XCTAssertTrue(snapshot.headerExact)
        XCTAssertEqual(snapshot.userVersion, H4D3.userVersion)
        XCTAssertEqual(snapshot.applicationID, H4D3.applicationID)
        XCTAssertEqual(snapshot.schemaEntryCount, 1)
        XCTAssertEqual(snapshot.rowCount, 1)
        XCTAssertEqual(snapshot.singleton, 1)
        XCTAssertEqual(snapshot.semanticSchema, H4C.semanticSchema)
        XCTAssertEqual(snapshot.claimState, "OBSERVED_NONPASS")
        XCTAssertEqual(snapshot.predicateCount, 19)
        XCTAssertEqual(snapshot.authorityVector, "00000000")
        XCTAssertEqual(snapshot.canonicalJSON, expected.json)
        XCTAssertEqual(snapshot.canonicalCBOR, expected.cbor)
        XCTAssertNotEqual(snapshot.canonicalJSON, snapshot.canonicalCBOR)
        XCTAssertEqual(snapshot.storageClasses, [
            SQLITE_INTEGER,
            SQLITE_TEXT,
            SQLITE_TEXT,
            SQLITE_INTEGER,
            SQLITE_TEXT,
            SQLITE_BLOB,
            SQLITE_BLOB,
        ])
        XCTAssertTrue(snapshot.queryOnly)
        XCTAssertTrue(snapshot.defensive)
        XCTAssertFalse(snapshot.trustedSchema)
        XCTAssertFalse(snapshot.dqsDDL)
        XCTAssertFalse(snapshot.dqsDML)
        XCTAssertTrue(snapshot.tempStoreMemory)
        XCTAssertTrue(snapshot.foreignKeys)
        XCTAssertTrue(snapshot.autocommit)
        XCTAssertTrue(snapshot.transactionNone)
        XCTAssertTrue(snapshot.filenameEmpty)
        let imageCount = Int(try XCTUnwrap(snapshot.fileSize))
        let evidence = calls.evidenceSnapshot()
        for read in [
            try XCTUnwrap(evidence.stagingRead),
            try XCTUnwrap(evidence.finalRead),
        ] {
            XCTAssertEqual(read.requestedCount, imageCount)
            XCTAssertGreaterThan(read.firstPreadReturn, 0)
            XCTAssertLessThanOrEqual(read.firstPreadReturn, imageCount)
            XCTAssertEqual(read.fstatReturn, 0)
            XCTAssertEqual(read.observedSize, Int64(imageCount))
            XCTAssertEqual(read.eofPreadReturn, 0)
            XCTAssertTrue(read.bytesEqualExpected)
        }
        assertHardenedReaderPolicy(evidence.prepublicationPolicy)
        assertHardenedReaderPolicy(evidence.finalPolicy)
        XCTAssertTrue(evidence.prepublicationReaderEntered)
        XCTAssertTrue(evidence.finalReaderEntered)
        XCTAssertFalse(evidence.mutationActuated)
        XCTAssertFalse(evidence.validatorEnteredAfterMutation)
        XCTAssertNil(evidence.replacementKind)
        XCTAssertNil(evidence.originalDevice)
        XCTAssertNil(evidence.originalInode)
        XCTAssertNil(evidence.replacementDevice)
        XCTAssertNil(evidence.replacementInode)
        XCTAssertNil(evidence.replacementBytesEqual)
        XCTAssertEqual(evidence.containedStatementCount, 0)
        XCTAssertFalse(evidence.renameCollisionActuated)
        XCTAssertNil(evidence.renameCollisionReturn)
        XCTAssertNil(evidence.renameCollisionErrno)
        XCTAssertFalse(evidence.v2SchemaActuated)
        assertSuccessfulPrimitiveSequence(
            evidence.primitiveEvents,
            imageCount: imageCount
        )
        XCTAssertEqual(calls.snapshot(), .init(
            commit: 1,
            stagingCreate: 1,
            pwrite: 1,
            rename: 1,
            finalOpen: 1
        ))
        assertUnavailable(coordinator.persist(), .alreadyConsumed)
    }

    func testDiagnosticCanariesNeverEnterImageErrorsOrReflection() throws {
        let diagnostic = "H4D3-RAW-DIAGNOSTIC-CANARY"
        let receiptRoot = String(repeating: "d", count: 64)
        let value = try bound(source: source(
            rawDiagnostic: Data(diagnostic.utf8),
            receiptRoot: receiptRoot
        ))
        let (coordinator, root) = try coordinator(bound: value)
        guard case .admitted(let receipt) = coordinator.persist() else {
            return XCTFail("Expected canary fixture admission")
        }
        let image = try Data(contentsOf: H4D3.finalTestURL(in: root))
        let rendered = [
            String(decoding: image, as: UTF8.self),
            String(reflecting: receipt),
            String(reflecting: coordinator),
            String(reflecting: H4D3.Failure.reconstructionRejected),
        ].joined(separator: "\n")
        for forbidden in [
            diagnostic,
            receiptRoot,
            epoch,
            root.path,
            "envelopeIdentity",
            "ownerAnchor",
            "sqlite3_errmsg",
        ] {
            XCTAssertFalse(rendered.contains(forbidden), forbidden)
        }
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)
        XCTAssertEqual(Mirror(reflecting: coordinator).children.count, 0)
    }

    func testStaticDataflowAndProductionSurfaceRemainClosed() throws {
        let testURL = URL(fileURLWithPath: #filePath)
        let sourceURL = testURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources", isDirectory: true)
            .appendingPathComponent(
                "HypervisorStageH4DualStreamPersistence.swift",
                isDirectory: false
            )
        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertTrue(source.contains("try bind(p.json, 5, st)"))
        XCTAssertTrue(source.contains("try bind(p.cbor, 6, st)"))
        XCTAssertFalse(source.contains("granularReconstructionFault"))
        XCTAssertFalse(source.contains("CanonicalJSON.encode"))
        XCTAssertFalse(source.contains("DeterministicCBOR.encode"))
        XCTAssertFalse(source.contains("CommandLine"))
        XCTAssertFalse(source.contains("posix_spawn"))
        XCTAssertFalse(source.contains("Process("))
        XCTAssertFalse(source.contains("getenv("))
        XCTAssertFalse(source.contains("URLSession"))
        XCTAssertTrue(source.contains("#if EPR_H4_PRIVACY_TESTS"))
        XCTAssertTrue(source.contains("static func makeTestCoordinator("))
        XCTAssertFalse(source.contains("static func makeProductionCoordinator"))
        XCTAssertFalse(source.contains("static func makeCoordinator("))
    }

    func testRootAdmissionRejectsAliasesModesEntriesAndCompetingLock() throws {
        let ownershipRoot = try privateRoot()
        var ownershipMetadata = stat()
        XCTAssertEqual(lstat(ownershipRoot.path, &ownershipMetadata), 0)
        XCTAssertTrue(H4D3.rootMetadataIsValidForTest(ownershipMetadata))
        ownershipMetadata.st_uid = ownershipMetadata.st_uid == 0 ? 1 : 0
        XCTAssertFalse(H4D3.rootMetadataIsValidForTest(ownershipMetadata))

        for leaf in [
            H4D3.finalLeafName,
            H4D3.stagingLeafName,
            H4D3.finalLeafName + "-journal",
            H4D3.finalLeafName + "-wal",
            H4D3.finalLeafName + "-shm",
            ".hidden",
        ] {
            let root = try privateRoot()
            try createLeaf(leaf, in: root)
            XCTAssertThrowsError(try H4D3.makeTestCoordinator(
                bound: bound(), rootURL: root
            )) {
                XCTAssertEqual(
                    $0 as? H4D3.Failure,
                    .storeAdmissionRejected,
                    leaf
                )
            }
        }

        let directoryRoot = try privateRoot()
        try FileManager.default.createDirectory(
            at: directoryRoot.appendingPathComponent("nested", isDirectory: true),
            withIntermediateDirectories: false
        )
        XCTAssertThrowsError(try H4D3.makeTestCoordinator(
            bound: bound(), rootURL: directoryRoot
        ))

        for leaf in [H4D3.stagingLeafName, H4D3.finalLeafName] {
            let symlinkRoot = try privateRoot()
            XCTAssertEqual(
                symlink(
                    "/dev/null",
                    symlinkRoot.appendingPathComponent(leaf).path
                ),
                0
            )
            XCTAssertThrowsError(try H4D3.makeTestCoordinator(
                bound: bound(), rootURL: symlinkRoot
            ))

            let fifoRoot = try privateRoot()
            XCTAssertEqual(
                mkfifo(
                    fifoRoot.appendingPathComponent(leaf).path,
                    mode_t(0o600)
                ),
                0
            )
            XCTAssertThrowsError(try H4D3.makeTestCoordinator(
                bound: bound(), rootURL: fifoRoot
            ))
        }

        let symlinkTarget = try privateRoot()
        let symlinkParent = try privateRoot()
        let alias = symlinkParent.appendingPathComponent("alias", isDirectory: true)
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: symlinkTarget
        )
        XCTAssertThrowsError(try H4D3.makeTestCoordinator(
            bound: bound(), rootURL: alias
        ))

        let modeRoot = try privateRoot()
        XCTAssertEqual(chmod(modeRoot.path, mode_t(0o755)), 0)
        XCTAssertThrowsError(try H4D3.makeTestCoordinator(
            bound: bound(), rootURL: modeRoot
        ))

        let lockedRoot = try privateRoot()
        let descriptor = Darwin.open(
            lockedRoot.path,
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
        XCTAssertThrowsError(try H4D3.makeTestCoordinator(
            bound: bound(), rootURL: lockedRoot
        )) {
            XCTAssertEqual($0 as? H4D3.Failure, .storeAdmissionRejected)
        }
    }

    func testCopiedSequentialCallsHaveOneOwnerWinner() throws {
        let copied = try bound()
        let first = try coordinator(bound: copied)
        let second = try coordinator(bound: copied)
        guard case .admitted = first.0.persist() else {
            return XCTFail("Expected copied D3 owner winner")
        }
        assertUnavailable(second.0.persist(), .alreadyConsumed)
        XCTAssertEqual(second.0.storeGrantStateForTestOnly(), .ready)
        XCTAssertEqual(try inventory(first.1), [H4D3.finalLeafName])
        XCTAssertEqual(try inventory(second.1), [])
        assertUnavailable(first.0.persist(), .alreadyConsumed)
    }

    func testConcurrentCallsHaveExactlyOneWinner() throws {
        let (coordinator, root) = try coordinator(bound: bound())
        let queue = DispatchQueue(
            label: "h4d3.concurrent",
            attributes: .concurrent
        )
        let group = DispatchGroup()
        let outcomes = LockedOutcomes()
        for _ in 0..<32 {
            group.enter()
            queue.async {
                outcomes.append(coordinator.persist())
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 15), .success)
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
        XCTAssertEqual(try inventory(root), [H4D3.finalLeafName])
    }

    func testForcedConcurrencyObservesInProgressBeforeWinnerCompletes() throws {
        let tick = BlockingSecondTick()
        let (coordinator, root) = try coordinator(
            bound: bound(),
            storeReadTick: { tick.read() }
        )
        let winnerDone = DispatchSemaphore(value: 0)
        let outcomes = LockedOutcomes()
        DispatchQueue.global(qos: .userInitiated).async {
            outcomes.append(coordinator.persist())
            winnerDone.signal()
        }
        XCTAssertEqual(tick.entered.wait(timeout: .now() + 10), .success)
        assertUnavailable(coordinator.persist(), .inProgress)
        tick.release.signal()
        XCTAssertEqual(winnerDone.wait(timeout: .now() + 15), .success)
        XCTAssertEqual(outcomes.snapshot().filter {
            if case .admitted = $0 { return true }
            return false
        }.count, 1)
        assertUnavailable(coordinator.persist(), .alreadyConsumed)
        XCTAssertEqual(try inventory(root), [H4D3.finalLeafName])
    }

    func testD2bAndD3ShareExactlyOneOwnerLease() throws {
        do {
            let copied = try bound()
            let d2Root = try privateRoot()
            let d3Root = try privateRoot()
            let d2 = try H4P.makeTestCoordinator(
                bound: copied,
                rootURL: d2Root
            )
            let d3 = try H4D3.makeTestCoordinator(
                bound: copied,
                rootURL: d3Root
            )
            guard case .admitted = d2.persist() else {
                return XCTFail("Expected D2b owner-lease winner")
            }
            assertUnavailable(d3.persist(), .alreadyConsumed)
            XCTAssertEqual(d3.storeGrantStateForTestOnly(), .ready)
            XCTAssertEqual(try inventory(d2Root), [H4P.finalLeafName])
            XCTAssertEqual(try inventory(d3Root), [])
        }

        do {
            let copied = try bound()
            let d2Root = try privateRoot()
            let d3Root = try privateRoot()
            let d2 = try H4P.makeTestCoordinator(
                bound: copied,
                rootURL: d2Root
            )
            let d3 = try H4D3.makeTestCoordinator(
                bound: copied,
                rootURL: d3Root
            )
            guard case .admitted = d3.persist() else {
                return XCTFail("Expected D3 owner-lease winner")
            }
            guard case .unavailable(.alreadyConsumed) = d2.persist() else {
                return XCTFail("Expected D2b loser to observe owner consumption")
            }
            XCTAssertEqual(try inventory(d2Root), [])
            XCTAssertEqual(try inventory(d3Root), [H4D3.finalLeafName])
        }
    }

    func testOwnerAndStoreExpiryReplayAreFailClosed() throws {
        let expiredStore = try coordinator(
            bound: bound(),
            storeValidThroughTick: 10,
            storeReadTick: { 11 }
        )
        assertUnavailable(expiredStore.0.persist(), .expired)
        assertUnavailable(expiredStore.0.persist(), .poisoned)
        XCTAssertEqual(try inventory(expiredStore.1), [])

        let ownerTick = LockedTick(UInt64.max - 1)
        let ownerBound = try bound(
            validThroughTick: UInt64.max - 1,
            readTick: { ownerTick.read() }
        )
        let expiredOwner = try coordinator(bound: ownerBound)
        ownerTick.set(UInt64.max)
        assertUnavailable(expiredOwner.0.persist(), .expired)
        assertUnavailable(expiredOwner.0.persist(), .poisoned)
        XCTAssertEqual(
            expiredOwner.0.storeGrantStateForTestOnly(),
            .ready
        )
        XCTAssertEqual(try inventory(expiredOwner.1), [])
    }

    func testTransactionSerializationAndPrepublicationReaderTaxonomy() throws {
        let schedules: [(H4D3.TestFault, H4D3.Failure)] = [
            (.beforeBegin, .transactionRejected),
            (.afterBegin, .transactionRejected),
            (.afterSchema, .transactionRejected),
            (.afterInsert, .transactionRejected),
            (.serializeRejected, .serializationRejected),
            (.serializedOversize, .serializationRejected),
            (.serializedMisaligned, .serializationRejected),
            (.serializedBadHeader, .serializationRejected),
            (.serializedWrongWriteVersion, .serializationRejected),
            (.serializedWrongReadVersion, .serializationRejected),
            (.serializedWrongPageSize, .serializationRejected),
            (.serializedWrongPageCount, .serializationRejected),
            (.writerStatementLeak, .closeRejected),
            (.prepublicationDeserializeRejected, .reconstructionRejected),
            (.prepublicationReaderPolicyRejected, .sqlitePolicyRejected),
            (.prepublicationSchemaRejected, .reconstructionRejected),
            (.prepublicationJSONRejected, .reconstructionRejected),
            (.prepublicationCBORRejected, .reconstructionRejected),
            (.prepublicationScalarRejected, .reconstructionRejected),
            (.prepublicationStatementLeak, .closeRejected),
        ]
        for (fault, failure) in schedules {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertRejected(coordinator.persist(), failure)
            assertUnavailable(coordinator.persist(), .poisoned)
            XCTAssertEqual(try inventory(root), [], "\(fault)")
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.stagingCreate, 0, "\(fault)")
            XCTAssertEqual(entered.pwrite, 0, "\(fault)")
            XCTAssertEqual(entered.rename, 0, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            let evidence = calls.evidenceSnapshot()
            switch fault {
            case .serializeRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .publicationSerialize,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil,
                    origin: .injected
                )
            case .prepublicationDeserializeRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .prepublicationDeserialize,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil,
                    origin: .injected
                )
                XCTAssertFalse(evidence.prepublicationReaderEntered)
                XCTAssertNil(evidence.prepublicationPolicy)
                XCTAssertFalse(evidence.mutationActuated)
                XCTAssertFalse(evidence.validatorEnteredAfterMutation)
            case .prepublicationReaderPolicyRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .prepublicationDeserialize,
                    backendInvoked: true,
                    backendReturn: Int64(SQLITE_OK),
                    effectiveReturn: Int64(SQLITE_OK),
                    error: nil,
                    origin: .backend
                )
                XCTAssertTrue(evidence.prepublicationReaderEntered)
                assertHardenedReaderPolicy(evidence.prepublicationPolicy)
                XCTAssertTrue(evidence.mutationActuated)
                XCTAssertTrue(evidence.validatorEnteredAfterMutation)
            case .writerStatementLeak:
                XCTAssertEqual(
                    evidence.containedStatementCount,
                    1,
                    "\(fault)"
                )
            case .prepublicationStatementLeak:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .prepublicationDeserialize,
                    backendInvoked: true,
                    backendReturn: Int64(SQLITE_OK),
                    effectiveReturn: Int64(SQLITE_OK),
                    error: nil,
                    origin: .backend
                )
                XCTAssertTrue(evidence.prepublicationReaderEntered)
                assertHardenedReaderPolicy(evidence.prepublicationPolicy)
                XCTAssertFalse(evidence.mutationActuated)
                XCTAssertFalse(evidence.validatorEnteredAfterMutation)
                XCTAssertEqual(evidence.containedStatementCount, 1, "\(fault)")
            default:
                break
            }
        }
    }

    func testGranularPrepublicationMutationsRejectBeforeFilesystemMutation() throws {
        let reconstructionFaults: [H4D3.TestFault] = [
            .prepublicationJSONCorrupt,
            .prepublicationJSONNoncanonical,
            .prepublicationJSONAlias,
            .prepublicationJSONUnknownField,
            .prepublicationJSONTrailing,
            .prepublicationCBORCorrupt,
            .prepublicationCBORNoncanonical,
            .prepublicationCBORAlias,
            .prepublicationCBORUnknownField,
            .prepublicationCBORTrailing,
            .prepublicationScalarMismatch,
            .prepublicationScalarWrongStorage,
            .prepublicationThreeFieldSubstitution,
            .prepublicationV2Schema,
            .prepublicationWrongUserVersion,
            .prepublicationWrongApplicationID,
            .prepublicationExtraSchemaObject,
            .prepublicationExtraColumn,
            .prepublicationExtraRow,
            .prepublicationIntegrityRejected,
        ]
        let policyFaults: [H4D3.TestFault] = [
            .prepublicationAuthorizerRejected,
            .prepublicationQueryOnlyRejected,
            .prepublicationFilenameRejected,
        ]

        for (fault, expectedFailure) in
            reconstructionFaults.map({ ($0, H4D3.Failure.reconstructionRejected) }) +
            policyFaults.map({ ($0, H4D3.Failure.sqlitePolicyRejected) }) {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertRejected(coordinator.persist(), expectedFailure)
            assertUnavailable(coordinator.persist(), .poisoned)
            XCTAssertEqual(try inventory(root), [], "\(fault)")
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 0, "\(fault)")
            XCTAssertEqual(entered.pwrite, 0, "\(fault)")
            XCTAssertEqual(entered.rename, 0, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.prepublicationReaderEntered, "\(fault)")
            XCTAssertFalse(evidence.finalReaderEntered, "\(fault)")
            assertHardenedReaderPolicy(evidence.prepublicationPolicy)
            XCTAssertNil(evidence.finalPolicy, "\(fault)")
            XCTAssertEqual(
                evidence.v2SchemaActuated,
                fault == .prepublicationV2Schema,
                "\(fault)"
            )
            if reconstructionFaults.contains(fault) {
                XCTAssertTrue(evidence.mutationActuated, "\(fault)")
                XCTAssertTrue(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            } else if fault == .prepublicationQueryOnlyRejected {
                XCTAssertTrue(evidence.mutationActuated, "\(fault)")
                XCTAssertTrue(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            } else {
                XCTAssertFalse(evidence.mutationActuated, "\(fault)")
                XCTAssertFalse(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            }
        }
    }

    func testLostCommitResponseIsTerminalAndNeverPublishes() throws {
        let root = try privateRoot()
        let (coordinator, calls) = try H4D3.makeTestCoordinatorWithCounters(
            bound: bound(),
            rootURL: root,
            fault: .commitResponseLost
        )
        assertTransactionUnknown(
            coordinator.persist(),
            .commitOutcomeUnknown
        )
        assertUnavailable(coordinator.persist(), .persistenceRequiresInspection)
        XCTAssertEqual(try inventory(root), [])
        let entered = calls.snapshot()
        XCTAssertEqual(entered.commit, 1)
        XCTAssertEqual(entered.stagingCreate, 0)
        XCTAssertEqual(entered.pwrite, 0)
        XCTAssertEqual(entered.rename, 0)
        XCTAssertEqual(entered.finalOpen, 0)
    }

    func testStagingWriteSealSyncFaultsRetainOneJoinedStagingLeaf() throws {
        let schedules: [(H4D3.TestFault, H4D3.Failure)] = [
            (.afterStagingCreation, .stagingCreationRejected),
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
        for (fault, failure) in schedules {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertStagingRetained(coordinator.persist(), failure)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            XCTAssertEqual(
                try inventory(root),
                [H4D3.stagingLeafName],
                "\(fault)"
            )
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 0, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            let expectedPwrite: UInt32 =
                fault == .afterStagingCreation ? 0 : 1
            XCTAssertEqual(entered.pwrite, expectedPwrite, "\(fault)")
            let primitive: (
                H4D3.TestPrimitiveKind,
                Int64,
                Int32?
            )?
            switch fault {
            case .pwriteRejected:
                primitive = (.completeImagePwrite, -1, EIO)
            case .pwriteZero:
                primitive = (.completeImagePwrite, 0, nil)
            case .pwriteShort, .pwriteOverrun:
                let event = calls.evidenceSnapshot().primitiveEvents.first {
                    $0.kind == .completeImagePwrite
                }
                let requested = try XCTUnwrap(event?.requestedCount, "\(fault)")
                primitive = (
                    .completeImagePwrite,
                    Int64(requested + (fault == .pwriteShort ? -1 : 1)),
                    nil
                )
            case .modeSealRejected:
                primitive = (.modeSeal, -1, EIO)
            case .fsyncRejected:
                primitive = (.stagingFSync, -1, EIO)
            case .fullSyncRejected:
                primitive = (.stagingFullSync, -1, EIO)
            default:
                primitive = nil
            }
            if let primitive {
                let event = assertPrimitiveEvent(
                    calls,
                    kind: primitive.0,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: primitive.1,
                    error: primitive.2,
                    origin: .injected
                )
                if primitive.0 == .completeImagePwrite {
                    let requested = try XCTUnwrap(event?.requestedCount)
                    XCTAssertGreaterThan(requested, 0, "\(fault)")
                    XCTAssertLessThanOrEqual(
                        requested,
                        Int(H4D3.maximumDatabasePages * H4D3.pageSize),
                        "\(fault)"
                    )
                    XCTAssertEqual(
                        requested % Int(H4D3.pageSize),
                        0,
                        "\(fault)"
                    )
                }
            }
        }
    }

    func testLostStagingVnodeJoinNeverClaimsStagingRetained() throws {
        for fault in [
            H4D3.TestFault.stagingUnlinked,
            .stagingRebound,
            .stagingHardlinked,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPrepublicationUnknown(coordinator.persist(), .identityRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.commit, 1)
            XCTAssertEqual(entered.stagingCreate, 1)
            XCTAssertEqual(entered.pwrite, 1)
            XCTAssertEqual(entered.rename, 0)
            XCTAssertEqual(entered.finalOpen, 0)
        }
    }

    func testRenameEntryIsAlwaysPublicationOutcomeUnknown() throws {
        for fault in [
            H4D3.TestFault.renameCollision,
            .renameResponseLost,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublicationUnknown(
                coordinator.persist(),
                .publicationRejected
            )
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.commit, 1)
            XCTAssertEqual(entered.stagingCreate, 1)
            XCTAssertEqual(entered.pwrite, 1)
            XCTAssertEqual(entered.rename, 1)
            XCTAssertEqual(entered.finalOpen, 0)
            let evidence = calls.evidenceSnapshot()
            switch fault {
            case .renameCollision:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .publicationRename,
                    backendInvoked: true,
                    backendReturn: -1,
                    effectiveReturn: -1,
                    error: EEXIST,
                    origin: .backend
                )
                XCTAssertTrue(evidence.mutationActuated)
                XCTAssertTrue(evidence.renameCollisionActuated)
                XCTAssertEqual(evidence.renameCollisionReturn, -1)
                XCTAssertEqual(evidence.renameCollisionErrno, EEXIST)
                XCTAssertEqual(
                    try inventory(root),
                    [H4D3.stagingLeafName, H4D3.finalLeafName].sorted()
                )
            case .renameResponseLost:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .publicationRename,
                    backendInvoked: true,
                    backendReturn: 0,
                    effectiveReturn: -1,
                    error: nil,
                    origin: .responseLost
                )
                XCTAssertFalse(evidence.mutationActuated)
                XCTAssertFalse(evidence.renameCollisionActuated)
                XCTAssertNil(evidence.renameCollisionReturn)
                XCTAssertNil(evidence.renameCollisionErrno)
                XCTAssertEqual(try inventory(root), [H4D3.finalLeafName])
            default:
                return XCTFail("Unexpected rename fault")
            }
        }
    }

    func testPostpublicationFaultsRetainEvidenceAndNeverAdmit() throws {
        let schedules: [(H4D3.TestFault, H4D3.Failure)] = [
            (.directorySyncRejected, .directorySyncRejected),
            (.finalOpenRejected, .finalOpenRejected),
            (.finalReboundBeforeOpen, .identityRejected),
            (.finalFIFOBeforeOpen, .identityRejected),
            (.finalReadbackMismatch, .readbackRejected),
            (.finalDeserializeRejected, .reconstructionRejected),
            (.finalReaderPolicyRejected, .sqlitePolicyRejected),
            (.finalSchemaRejected, .reconstructionRejected),
            (.finalJSONRejected, .reconstructionRejected),
            (.finalCBORRejected, .reconstructionRejected),
            (.finalScalarRejected, .reconstructionRejected),
            (.finalStatementLeak, .closeRejected),
            (.finalDescriptorCloseResponseLost, .closeRejected),
            (.finalReboundAfterRead, .identityRejected),
        ]
        for (fault, failure) in schedules {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), failure)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            assertAtMostOneEnteredCall(entered)
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.pwrite, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 1, "\(fault)")
            let expectedFinalOpen: UInt32
            switch fault {
            case .directorySyncRejected, .finalReboundBeforeOpen,
                 .finalFIFOBeforeOpen:
                expectedFinalOpen = 0
            default:
                expectedFinalOpen = 1
            }
            XCTAssertEqual(entered.finalOpen, expectedFinalOpen, "\(fault)")
            switch fault {
            case .directorySyncRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .directoryFSync,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: -1,
                    error: EIO,
                    origin: .injected
                )
            case .finalOpenRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .finalOpen,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: -1,
                    error: EIO,
                    origin: .injected
                )
            case .finalDeserializeRejected:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .finalDeserialize,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil,
                    origin: .injected
                )
            case .finalDescriptorCloseResponseLost:
                _ = assertPrimitiveEvent(
                    calls,
                    kind: .finalDescriptorClose,
                    backendInvoked: true,
                    backendReturn: 0,
                    effectiveReturn: -1,
                    error: nil,
                    origin: .responseLost
                )
            case .finalStatementLeak:
                XCTAssertEqual(
                    calls.evidenceSnapshot().containedStatementCount,
                    1
                )
            default:
                break
            }
        }
    }

    func testGranularFinalMutationsRejectInTheDistinctFinalReader() throws {
        let reconstructionFaults: [H4D3.TestFault] = [
            .finalJSONCorrupt,
            .finalJSONNoncanonical,
            .finalJSONAlias,
            .finalJSONUnknownField,
            .finalJSONTrailing,
            .finalCBORCorrupt,
            .finalCBORNoncanonical,
            .finalCBORAlias,
            .finalCBORUnknownField,
            .finalCBORTrailing,
            .finalScalarMismatch,
            .finalScalarWrongStorage,
            .finalThreeFieldSubstitution,
            .finalV2Schema,
            .finalWrongUserVersion,
            .finalWrongApplicationID,
            .finalExtraSchemaObject,
            .finalExtraColumn,
            .finalExtraRow,
            .finalIntegrityRejected,
        ]
        let policyFaults: [H4D3.TestFault] = [
            .finalAuthorizerRejected,
            .finalQueryOnlyRejected,
            .finalFilenameRejected,
        ]

        for (fault, expectedFailure) in
            reconstructionFaults.map({ ($0, H4D3.Failure.reconstructionRejected) }) +
            policyFaults.map({ ($0, H4D3.Failure.sqlitePolicyRejected) }) {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), expectedFailure)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            XCTAssertEqual(try inventory(root), [H4D3.finalLeafName], "\(fault)")
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 1,
                stagingCreate: 1,
                pwrite: 1,
                rename: 1,
                finalOpen: 1
            ), "\(fault)")
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.prepublicationReaderEntered, "\(fault)")
            XCTAssertTrue(evidence.finalReaderEntered, "\(fault)")
            assertHardenedReaderPolicy(evidence.prepublicationPolicy)
            assertHardenedReaderPolicy(evidence.finalPolicy)
            XCTAssertEqual(
                evidence.v2SchemaActuated,
                fault == .finalV2Schema,
                "\(fault)"
            )
            if reconstructionFaults.contains(fault) {
                XCTAssertTrue(evidence.mutationActuated, "\(fault)")
                XCTAssertTrue(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            } else if fault == .finalQueryOnlyRejected {
                XCTAssertTrue(evidence.mutationActuated, "\(fault)")
                XCTAssertTrue(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            } else {
                XCTAssertFalse(evidence.mutationActuated, "\(fault)")
                XCTAssertFalse(
                    evidence.validatorEnteredAfterMutation,
                    "\(fault)"
                )
            }
        }
    }

    func testActuatedNamedVnodeAndReadIntersticesMapExactTaxonomy() throws {
        for fault in [
            H4D3.TestFault.stagingSymlinkAfterSnapshot,
            .stagingFIFOAfterSnapshot,
            .stagingNonregularAfterSnapshot,
            .stagingSameBytesNewInode,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPrepublicationUnknown(coordinator.persist(), .identityRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.pwrite, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 0, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            assertAtMostOneEnteredCall(entered)
            let replacement: (mode_t, Bool)
            switch fault {
            case .stagingSymlinkAfterSnapshot:
                replacement = (S_IFLNK, false)
            case .stagingFIFOAfterSnapshot:
                replacement = (S_IFIFO, false)
            case .stagingNonregularAfterSnapshot:
                replacement = (S_IFDIR, false)
            case .stagingSameBytesNewInode:
                replacement = (S_IFREG, true)
            default:
                return XCTFail("Unexpected staging fault")
            }
            try assertActuatedReplacement(
                in: root,
                namedLeaf: H4D3.stagingLeafName,
                expectedType: replacement.0,
                bytesMustMatch: replacement.1
            )
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.mutationActuated, "\(fault)")
            XCTAssertEqual(evidence.replacementKind, {
                switch replacement.0 {
                case S_IFLNK: return H4D3.TestReplacementKind.symlink
                case S_IFIFO: return .fifo
                case S_IFDIR: return .directory
                default: return .regular
                }
            }(), "\(fault)")
            XCTAssertNotNil(evidence.originalDevice, "\(fault)")
            XCTAssertNotNil(evidence.originalInode, "\(fault)")
            XCTAssertNotNil(evidence.replacementDevice, "\(fault)")
            XCTAssertNotNil(evidence.replacementInode, "\(fault)")
            XCTAssertEqual(
                evidence.replacementBytesEqual,
                replacement.0 == S_IFREG ? replacement.1 : nil,
                "\(fault)"
            )
        }

        for fault in [
            H4D3.TestFault.finalSymlinkBeforeOpen,
            .finalNonregularBeforeOpen,
            .finalSameBytesNewInodeBeforeOpen,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), .identityRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.pwrite, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 1, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            assertAtMostOneEnteredCall(entered)
            let replacement: (mode_t, Bool)
            switch fault {
            case .finalSymlinkBeforeOpen:
                replacement = (S_IFLNK, false)
            case .finalNonregularBeforeOpen:
                replacement = (S_IFDIR, false)
            case .finalSameBytesNewInodeBeforeOpen:
                replacement = (S_IFREG, true)
            default:
                return XCTFail("Unexpected final pre-open fault")
            }
            try assertActuatedReplacement(
                in: root,
                namedLeaf: H4D3.finalLeafName,
                expectedType: replacement.0,
                bytesMustMatch: replacement.1
            )
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.mutationActuated, "\(fault)")
            XCTAssertEqual(
                evidence.replacementBytesEqual,
                replacement.0 == S_IFREG ? replacement.1 : nil,
                "\(fault)"
            )
        }

        do {
            let fault = H4D3.TestFault.finalSameBytesNewInodeAfterRead
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), .identityRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            XCTAssertEqual(entered.commit, 1)
            XCTAssertEqual(entered.stagingCreate, 1)
            XCTAssertEqual(entered.pwrite, 1)
            XCTAssertEqual(entered.rename, 1)
            XCTAssertEqual(entered.finalOpen, 1)
            assertAtMostOneEnteredCall(entered)
            try assertActuatedReplacement(
                in: root,
                namedLeaf: H4D3.finalLeafName,
                expectedType: S_IFREG,
                bytesMustMatch: true
            )
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.mutationActuated)
            XCTAssertEqual(evidence.replacementKind, .regular)
            XCTAssertEqual(evidence.replacementBytesEqual, true)
        }

        for (fault, bytesMatch) in [
            (H4D3.TestFault.finalReboundBeforeSuccess, false),
            (.finalSameBytesNewInodeBeforeSuccess, true),
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), .identityRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 1,
                stagingCreate: 1,
                pwrite: 1,
                rename: 1,
                finalOpen: 1
            ), "\(fault)")
            try assertActuatedReplacement(
                in: root,
                namedLeaf: H4D3.finalLeafName,
                expectedType: S_IFREG,
                bytesMustMatch: bytesMatch
            )
            let evidence = calls.evidenceSnapshot()
            XCTAssertTrue(evidence.mutationActuated, "\(fault)")
            XCTAssertFalse(evidence.validatorEnteredAfterMutation, "\(fault)")
            XCTAssertTrue(evidence.prepublicationReaderEntered, "\(fault)")
            XCTAssertTrue(evidence.finalReaderEntered, "\(fault)")
            XCTAssertEqual(evidence.replacementKind, .regular, "\(fault)")
            XCTAssertEqual(
                evidence.replacementBytesEqual,
                bytesMatch,
                "\(fault)"
            )
            let originalDevice = try XCTUnwrap(
                evidence.originalDevice,
                "\(fault)"
            )
            let originalInode = try XCTUnwrap(
                evidence.originalInode,
                "\(fault)"
            )
            let replacementDevice = try XCTUnwrap(
                evidence.replacementDevice,
                "\(fault)"
            )
            let replacementInode = try XCTUnwrap(
                evidence.replacementInode,
                "\(fault)"
            )
            XCTAssertTrue(
                originalDevice != replacementDevice ||
                    originalInode != replacementInode,
                "\(fault)"
            )
            assertHardenedReaderPolicy(evidence.prepublicationPolicy)
            assertHardenedReaderPolicy(evidence.finalPolicy)
            let stagingRead = try XCTUnwrap(evidence.stagingRead, "\(fault)")
            let finalRead = try XCTUnwrap(evidence.finalRead, "\(fault)")
            XCTAssertEqual(
                finalRead.requestedCount,
                stagingRead.requestedCount,
                "\(fault)"
            )
            XCTAssertTrue(stagingRead.bytesEqualExpected, "\(fault)")
            XCTAssertTrue(finalRead.bytesEqualExpected, "\(fault)")
            assertSuccessfulPrimitiveSequence(
                evidence.primitiveEvents,
                imageCount: stagingRead.requestedCount
            )
        }

        for fault in [
            H4D3.TestFault.stagingExactLengthMismatch,
            .stagingEOFMismatch,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertStagingRetained(coordinator.persist(), .readbackRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.pwrite, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 0, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 0, "\(fault)")
            assertAtMostOneEnteredCall(entered)
            let staged = try witness(H4D3.stagingTestURL(in: root))
            XCTAssertEqual(mode_t(staged.mode) & S_IFMT, S_IFREG, "\(fault)")
            let read = try XCTUnwrap(
                calls.evidenceSnapshot().stagingRead,
                "\(fault)"
            )
            XCTAssertGreaterThan(read.firstPreadReturn, 0, "\(fault)")
            XCTAssertLessThanOrEqual(
                read.firstPreadReturn,
                read.requestedCount,
                "\(fault)"
            )
            XCTAssertEqual(read.fstatReturn, 0, "\(fault)")
            switch fault {
            case .stagingExactLengthMismatch:
                XCTAssertEqual(staged.size % H4D3.pageSize, 0, "\(fault)")
                XCTAssertEqual(read.observedSize, Int64(read.requestedCount))
                XCTAssertEqual(read.eofPreadReturn, 0, "\(fault)")
                XCTAssertFalse(read.bytesEqualExpected, "\(fault)")
            case .stagingEOFMismatch:
                XCTAssertNotEqual(staged.size % H4D3.pageSize, 0, "\(fault)")
                XCTAssertEqual(read.observedSize, Int64(read.requestedCount + 1))
                XCTAssertEqual(read.eofPreadReturn, 1, "\(fault)")
                XCTAssertTrue(read.bytesEqualExpected, "\(fault)")
            default:
                return XCTFail("Unexpected staging length fault")
            }
        }

        for fault in [
            H4D3.TestFault.finalExactLengthMismatch,
            .finalEOFMismatch,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(coordinator.persist(), .readbackRejected)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            let entered = calls.snapshot()
            XCTAssertEqual(entered.commit, 1, "\(fault)")
            XCTAssertEqual(entered.stagingCreate, 1, "\(fault)")
            XCTAssertEqual(entered.pwrite, 1, "\(fault)")
            XCTAssertEqual(entered.rename, 1, "\(fault)")
            XCTAssertEqual(entered.finalOpen, 1, "\(fault)")
            assertAtMostOneEnteredCall(entered)
            let final = try witness(H4D3.finalTestURL(in: root))
            XCTAssertEqual(mode_t(final.mode) & S_IFMT, S_IFREG, "\(fault)")
            let read = try XCTUnwrap(
                calls.evidenceSnapshot().finalRead,
                "\(fault)"
            )
            XCTAssertGreaterThan(read.firstPreadReturn, 0, "\(fault)")
            XCTAssertLessThanOrEqual(
                read.firstPreadReturn,
                read.requestedCount,
                "\(fault)"
            )
            XCTAssertEqual(read.fstatReturn, 0, "\(fault)")
            switch fault {
            case .finalExactLengthMismatch:
                XCTAssertEqual(final.size % H4D3.pageSize, 0, "\(fault)")
                XCTAssertEqual(read.observedSize, Int64(read.requestedCount))
                XCTAssertEqual(read.eofPreadReturn, 0, "\(fault)")
                XCTAssertFalse(read.bytesEqualExpected, "\(fault)")
            case .finalEOFMismatch:
                XCTAssertNotEqual(final.size % H4D3.pageSize, 0, "\(fault)")
                XCTAssertEqual(read.observedSize, Int64(read.requestedCount + 1))
                XCTAssertEqual(read.eofPreadReturn, 1, "\(fault)")
                XCTAssertTrue(read.bytesEqualExpected, "\(fault)")
            default:
                return XCTFail("Unexpected final length fault")
            }
        }
    }

    func testParentRootReboundIsDetectedAtEveryTerminalClass() throws {
        do {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: .parentReboundBeforeStaging
                )
            assertPrepublicationUnknown(
                coordinator.persist(),
                .storeAdmissionRejected
            )
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            assertAtMostOneEnteredCall(calls.snapshot())
            XCTAssertEqual(calls.snapshot().stagingCreate, 0)
        }

        do {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: .parentReboundAfterStaging
                )
            assertPrepublicationUnknown(
                coordinator.persist(),
                .storeAdmissionRejected
            )
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            assertAtMostOneEnteredCall(calls.snapshot())
            XCTAssertEqual(calls.snapshot().stagingCreate, 1)
            XCTAssertEqual(calls.snapshot().rename, 0)
        }

        for fault in [
            H4D3.TestFault.parentReboundAfterRename,
            .parentReboundBeforeSuccess,
        ] {
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    fault: fault
                )
            assertPublishedUnverified(
                coordinator.persist(),
                .storeAdmissionRejected
            )
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            assertAtMostOneEnteredCall(calls.snapshot())
            XCTAssertEqual(calls.snapshot().rename, 1)
        }
    }

    func testLivenessIsRevalidatedAtAllThreeFrozenGates() throws {
        do {
            let tick = SequenceTick([9, 9, 11])
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    storeValidThroughTick: 10,
                    storeReadTick: { tick.read() }
                )
            assertRejected(coordinator.persist(), .expired)
            assertUnavailable(coordinator.persist(), .poisoned)
            XCTAssertEqual(try inventory(root), [])
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 0,
                stagingCreate: 0,
                pwrite: 0,
                rename: 0,
                finalOpen: 0
            ))
        }

        do {
            let tick = SequenceTick([9, 9, 9, 11])
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    storeValidThroughTick: 10,
                    storeReadTick: { tick.read() }
                )
            assertRejected(coordinator.persist(), .expired)
            assertUnavailable(coordinator.persist(), .poisoned)
            XCTAssertEqual(try inventory(root), [])
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 1,
                stagingCreate: 0,
                pwrite: 0,
                rename: 0,
                finalOpen: 0
            ))
        }

        do {
            let tick = SequenceTick([9, 9, 9, 9, 11])
            let root = try privateRoot()
            let (coordinator, calls) =
                try H4D3.makeTestCoordinatorWithCounters(
                    bound: bound(),
                    rootURL: root,
                    storeValidThroughTick: 10,
                    storeReadTick: { tick.read() }
                )
            assertStagingRetained(coordinator.persist(), .expired)
            assertUnavailable(
                coordinator.persist(),
                .persistenceRequiresInspection
            )
            XCTAssertEqual(try inventory(root), [H4D3.stagingLeafName])
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 1,
                stagingCreate: 1,
                pwrite: 1,
                rename: 0,
                finalOpen: 0
            ))
        }
    }

    func testSharedStoreMismatchPoisonsWithoutPublishing() throws {
        let root = try privateRoot()
        let (shared, calls) =
            try H4D3.makeTestSharedStoreCoordinatorsWithCounters(
                bounds: [bound(), bound()],
                rootURL: root
            )
        XCTAssertEqual(shared.count, 2)
        assertUnavailable(shared[1].persist(), .storeAdmissionRejected)
        assertUnavailable(shared[0].persist(), .poisoned)
        assertUnavailable(shared[1].persist(), .poisoned)
        XCTAssertEqual(shared[0].storeGrantStateForTestOnly(), .poisoned)
        XCTAssertEqual(try inventory(root), [])
        XCTAssertEqual(calls.snapshot(), .init(
            commit: 0,
            stagingCreate: 0,
            pwrite: 0,
            rename: 0,
            finalOpen: 0
        ))
    }

    func testCompletionFailureNeverExposesAnAdmittedHalfState() throws {
        for rejectStore in [true, false] {
            let root = try privateRoot()
            let intersticeEntered = DispatchSemaphore(value: 0)
            let releaseInterstice = DispatchSemaphore(value: 0)
            let primaryDone = DispatchSemaphore(value: 0)
            let observerDone = DispatchSemaphore(value: 0)
            let outcomes = LockedOutcomes()
            let (shared, calls) =
                try H4D3.makeTestSharedStoreCoordinatorsWithCounters(
                    bounds: [bound(), bound()],
                    rootURL: root,
                    rejectStoreCompletionForTest: rejectStore,
                    rejectOwnerCompletionForTest: !rejectStore,
                    completionIntersticeForTest: {
                        intersticeEntered.signal()
                        releaseInterstice.wait()
                    }
                )
            let queue = DispatchQueue(
                label: "h4d3.completion-atomicity.\(rejectStore)",
                attributes: .concurrent
            )
            queue.async {
                outcomes.append(shared[0].persist())
                primaryDone.signal()
            }
            XCTAssertEqual(
                intersticeEntered.wait(timeout: .now() + 10),
                .success
            )
            XCTAssertEqual(shared[1].probeTransitionForTestOnly(), .storeBlocked)
            queue.async {
                outcomes.append(shared[1].persist())
                observerDone.signal()
            }
            releaseInterstice.signal()
            XCTAssertEqual(primaryDone.wait(timeout: .now() + 10), .success)
            XCTAssertEqual(observerDone.wait(timeout: .now() + 10), .success)

            let values = outcomes.snapshot()
            XCTAssertEqual(values.filter {
                $0 == .publishedUnverified(.leaseCompletionRejected)
            }.count, 1)
            XCTAssertEqual(values.filter {
                $0 == .unavailable(.persistenceRequiresInspection)
            }.count, 1)
            XCTAssertEqual(
                shared[0].storeGrantStateForTestOnly(),
                .terminalUnknown
            )
            XCTAssertEqual(try inventory(root), [H4D3.finalLeafName])
            XCTAssertEqual(calls.snapshot(), .init(
                commit: 1,
                stagingCreate: 1,
                pwrite: 1,
                rename: 1,
                finalOpen: 1
            ))
        }
    }

    func testV2SentinelIsByteAndVnodeExactAcrossD3OutcomeClasses() throws {
        let sentinelRoot = try privateRoot()
        let sentinel = try H4P.makeTestCoordinator(
            bound: bound(),
            rootURL: sentinelRoot
        )
        guard case .admitted = sentinel.persist() else {
            return XCTFail("Expected independent v2 sentinel")
        }
        let sentinelURL = H4P.finalTestURL(in: sentinelRoot)
        let sentinelBytes = try Data(contentsOf: sentinelURL)
        let sentinelWitness = try witness(sentinelURL)
        let sentinelInventory = try inventory(sentinelRoot)

        let representativeFaults: [H4D3.TestFault] = [
            .beforeBegin,
            .commitResponseLost,
            .stagingUnlinked,
            .pwriteShort,
            .renameResponseLost,
            .finalDeserializeRejected,
        ]
        for fault in representativeFaults {
            let value = try coordinator(bound: bound(), fault: fault)
            _ = value.0.persist()
            XCTAssertEqual(
                try Data(contentsOf: sentinelURL),
                sentinelBytes,
                "\(fault)"
            )
            XCTAssertEqual(try witness(sentinelURL), sentinelWitness, "\(fault)")
            XCTAssertEqual(
                try inventory(sentinelRoot),
                sentinelInventory,
                "\(fault)"
            )
        }

        let unavailable = try coordinator(
            bound: bound(),
            storeValidThroughTick: 0,
            storeReadTick: { 1 }
        )
        assertUnavailable(unavailable.0.persist(), .expired)

        let admitted = try coordinator(bound: bound())
        guard case .admitted = admitted.0.persist() else {
            return XCTFail("Expected D3 success control")
        }
        XCTAssertEqual(try Data(contentsOf: sentinelURL), sentinelBytes)
        XCTAssertEqual(try witness(sentinelURL), sentinelWitness)
        XCTAssertEqual(try inventory(sentinelRoot), sentinelInventory)
    }
}

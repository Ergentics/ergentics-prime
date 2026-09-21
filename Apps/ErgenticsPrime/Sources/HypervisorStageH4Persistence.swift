import Darwin
import Foundation
import SQLite3

/// H4-D2b is a closed, one-shot publication admission for H4-D's opaque
/// owner-bound canonical handoff. SQLite commits only in private memory. The
/// committed image is then published through one held directory and one held
/// staging inode before a fresh read-only in-memory reconstruction. SQLite is
/// a non-authoritative container; no production store mint exists here.
enum HypervisorStageH4Persistence {
    typealias H4C = HypervisorStageH4CanonicalStreams
    typealias H4D = HypervisorStageH4OwnerBinding
    typealias Coordinator = H4D.PersistenceCoordinator

    static let schema =
        "com.ergentics.provenance.hypervisor.h4.sqlite-image-publication.v2"
    static let applicationID: Int64 = 1_162_891_828
    static let userVersion: Int64 = 1
    static let maximumDatabasePages: Int64 = 64
    static let pageSize: Int64 = 4_096
    static let stagingLeafName = ".h4d2b-receipt.sqlite.staging"
    static let finalLeafName = "h4d2b-receipt.sqlite"

    enum Failure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case persistenceRequiresInspection
        case expired
        case poisoned
        case storeAdmissionRejected
        case sqlitePolicyRejected
        case transactionRejected
        case commitOutcomeUnknown
        case serializationRejected
        case closeRejected
        case reconstructionRejected
        case stagingCreationRejected
        case truncateRejected
        case writeRejected
        case modeSealRejected
        case syncRejected
        case readbackRejected
        case publicationRejected
        case directorySyncRejected
        case finalOpenRejected
        case identityRejected
        case leaseCompletionRejected
    }

    struct ReopenReceipt: Equatable, Sendable, CustomReflectable {
        fileprivate init() {}

        var schema: String { HypervisorStageH4Persistence.schema }
        var rowCount: UInt8 { 1 }
        var inMemoryCommitExact: Bool { true }
        var serializedImageExact: Bool { true }
        var prepublicationReconstructionExact: Bool { true }
        var stagingFullSyncExact: Bool { true }
        var exclusivePublicationExact: Bool { true }
        var directorySyncExact: Bool { true }
        var descriptorReadbackExact: Bool { true }
        var writerClosed: Bool { true }
        var readOnlyReopenExact: Bool { true }
        var schemaExact: Bool { true }
        var canonicalCBORExact: Bool { true }
        var indexedFieldsExact: Bool { true }
        var jsonRoundTripExact: Bool { true }
        var cborRoundTripExact: Bool { true }
        var semanticJoinExact: Bool { true }

        var customMirror: Mirror {
            Mirror(
                self,
                children: EmptyCollection<(label: String?, value: Any)>(),
                displayStyle: .struct
            )
        }
    }

    /// Unforgeable product input to the reopened-stream join. Only the fixed
    /// SQLite row reader in this file can initialize it.
    struct ReopenedSQLiteRowInput: Sendable {
        let canonicalCBOR: Data
        let semanticSchema: String
        let claimState: String
        let predicateCount: Int64
        let authorityVector: String

        fileprivate init(
            canonicalCBOR: Data,
            semanticSchema: String,
            claimState: String,
            predicateCount: Int64,
            authorityVector: String
        ) {
            self.canonicalCBOR = canonicalCBOR
            self.semanticSchema = semanticSchema
            self.claimState = claimState
            self.predicateCount = predicateCount
            self.authorityVector = authorityVector
        }
    }

    enum Outcome: Equatable, Sendable {
        case admitted(ReopenReceipt)
        case unavailable(Failure)
        case rejectedBeforePublication(Failure)
        case transactionOutcomeUnknown(Failure)
        case prepublicationStateUnknown(Failure)
        case stagingRetained(Failure)
        case publicationOutcomeUnknown(Failure)
        case publishedUnverified(Failure)
    }

    enum RetainedInspectionFailure: Error, Equatable, Sendable {
        case inProgress
        case alreadyConsumed
        case rootRejected
        case namespaceRejected
        case finalOpenRejected
        case identityRejected
        case readRejected
        case sqliteRejected
        case cborRejected
        case closeRejected
    }

    /// The strongest truthful D2c result for the retained v2 format. The
    /// original independent JSON stream, owner anchor and persistence lease
    /// are absent, so every property is fixed inspection metadata and no
    /// authority-bearing payload is exposed.
    struct RetainedImageInspectionReceipt: Equatable, Sendable, CustomReflectable {
        fileprivate init() {}

        var schema: String {
            "com.ergentics.provenance.hypervisor.h4.retained-image-inspection.v1"
        }
        var classification: String {
            "VALID_V2_CBOR_ONLY_JSON_MISSING"
        }
        var sqliteImageExact: Bool { true }
        var canonicalCBORExact: Bool { true }
        var indexedFieldsExact: Bool { true }
        var independentJSONPresent: Bool { false }
        var dualStreamJoinExact: Bool { false }
        var admitted: Bool { false }
        var h4Entered: Bool { false }
        var authorityVector: String { "00000000" }

        var customMirror: Mirror {
            Mirror(
                self,
                children: EmptyCollection<(label: String?, value: Any)>(),
                displayStyle: .struct
            )
        }
    }

    enum RetainedInspectionOutcome: Equatable, Sendable {
        case empty
        case stagingRetained
        case validV2CBOROnlyJSONMissing(RetainedImageInspectionReceipt)
        case publishedInvalid(RetainedInspectionFailure)
        case namespaceAmbiguous
        case unavailable(RetainedInspectionFailure)
    }

    #if EPR_H4_PRIVACY_TESTS
    enum TestFault: Equatable, Sendable {
        case none
        case beforeBegin
        case afterBegin
        case afterSchema
        case afterInsert
        case commitResponseLost
        case serializeRejected
        case serializedOversize
        case serializedMisaligned
        case serializedBadHeader
        case writerCloseRejected
        case prepublicationDeserializeRejected
        case prepublicationSchemaRejected
        case prepublicationRowRejected
        case prepublicationSemanticRejected
        case prepublicationCloseRejected
        case afterStagingCreation
        case truncateRejected
        case pwriteRejected
        case pwriteZero
        case pwriteShort
        case pwriteOverrun
        case modeSealRejected
        case stagingStatRejected
        case fsyncRejected
        case fullSyncRejected
        case stagingReadbackMismatch
        case renameCollision
        case renameResponseLost
        case finalInventoryRejected
        case directorySyncRejected
        case finalOpenRejected
        case finalIdentityRejected
        case finalReadbackMismatch
        case finalDeserializeRejected
        case finalSchemaRejected
        case finalRowRejected
        case finalSemanticRejected
        case finalReaderCloseRejected
        case finalDescriptorCloseRejected
        case parentReboundAfterPublish
    }

    struct TestStoreSnapshot: Equatable, Sendable {
        let inventory: [String]
        let published: Bool
        let fileMode: UInt16?
        let fileSize: Int64?
        let headerExact: Bool
        let userVersion: Int64
        let applicationID: Int64
        let schemaEntryCount: Int64
        let rowCount: Int64
    }

    static func makeTestCoordinator(
        bound: H4D.OwnerBoundCanonicalProjection,
        rootURL: URL,
        fault: TestFault = .none,
        storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        },
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) throws -> Coordinator {
        let store = try Store(rootURL: rootURL, fault: Fault(fault))
        return H4D.makeTestPersistenceCoordinator(
            bound: bound,
            store: store,
            validThroughTick: storeValidThroughTick,
            readTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest
        )
    }

    static func makeTestSharedStoreCoordinators(
        bounds: [H4D.OwnerBoundCanonicalProjection],
        rootURL: URL,
        fault: TestFault = .none,
        storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        },
        rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil
    ) throws -> [Coordinator] {
        let store = try Store(rootURL: rootURL, fault: Fault(fault))
        return H4D.makeTestSharedStoreCoordinators(
            bounds: bounds,
            store: store,
            validThroughTick: storeValidThroughTick,
            readTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest
        )
    }

    static func inspectTestStore(rootURL: URL) throws -> TestStoreSnapshot {
        try Store.inspect(rootURL: rootURL)
    }

    static func finalTestURL(in rootURL: URL) -> URL {
        rootURL.appendingPathComponent(finalLeafName, isDirectory: false)
    }

    static func stagingTestURL(in rootURL: URL) -> URL {
        rootURL.appendingPathComponent(stagingLeafName, isDirectory: false)
    }

    static func makeTestRetainedV2Inspector(
        rootURL: URL,
        afterInitialInventoryForTest: (@Sendable () -> Void)? = nil,
        afterNamedFinalForTest: (@Sendable () -> Void)? = nil,
        afterReadForTest: (@Sendable () -> Void)? = nil,
        beforeTerminalRootForTest: (@Sendable () -> Void)? = nil
    ) throws -> Store.RetainedV2Inspector {
        try Store.RetainedV2Inspector(
            rootURL: rootURL,
            afterInitialInventoryForTest: afterInitialInventoryForTest,
            afterNamedFinalForTest: afterNamedFinalForTest,
            afterReadForTest: afterReadForTest,
            beforeTerminalRootForTest: beforeTerminalRootForTest
        )
    }
    #endif

    enum StoreResult {
        case admitted(ReopenReceipt)
        case rejectedBeforePublication(Failure)
        case transactionOutcomeUnknown(Failure)
        case prepublicationStateUnknown(Failure)
        case stagingRetained(Failure)
        case publicationOutcomeUnknown(Failure)
        case publishedUnverified(Failure)
    }

    fileprivate enum Fault: Sendable {
        case none
        #if EPR_H4_PRIVACY_TESTS
        case beforeBegin
        case afterBegin
        case afterSchema
        case afterInsert
        case commitResponseLost
        case serializeRejected
        case serializedOversize
        case serializedMisaligned
        case serializedBadHeader
        case writerCloseRejected
        case prepublicationDeserializeRejected
        case prepublicationSchemaRejected
        case prepublicationRowRejected
        case prepublicationSemanticRejected
        case prepublicationCloseRejected
        case afterStagingCreation
        case truncateRejected
        case pwriteRejected
        case pwriteZero
        case pwriteShort
        case pwriteOverrun
        case modeSealRejected
        case stagingStatRejected
        case fsyncRejected
        case fullSyncRejected
        case stagingReadbackMismatch
        case renameCollision
        case renameResponseLost
        case finalInventoryRejected
        case directorySyncRejected
        case finalOpenRejected
        case finalIdentityRejected
        case finalReadbackMismatch
        case finalDeserializeRejected
        case finalSchemaRejected
        case finalRowRejected
        case finalSemanticRejected
        case finalReaderCloseRejected
        case finalDescriptorCloseRejected
        case parentReboundAfterPublish

        init(_ value: TestFault) {
            switch value {
            case .none: self = .none
            case .beforeBegin: self = .beforeBegin
            case .afterBegin: self = .afterBegin
            case .afterSchema: self = .afterSchema
            case .afterInsert: self = .afterInsert
            case .commitResponseLost: self = .commitResponseLost
            case .serializeRejected: self = .serializeRejected
            case .serializedOversize: self = .serializedOversize
            case .serializedMisaligned: self = .serializedMisaligned
            case .serializedBadHeader: self = .serializedBadHeader
            case .writerCloseRejected: self = .writerCloseRejected
            case .prepublicationDeserializeRejected:
                self = .prepublicationDeserializeRejected
            case .prepublicationSchemaRejected: self = .prepublicationSchemaRejected
            case .prepublicationRowRejected: self = .prepublicationRowRejected
            case .prepublicationSemanticRejected:
                self = .prepublicationSemanticRejected
            case .prepublicationCloseRejected: self = .prepublicationCloseRejected
            case .afterStagingCreation: self = .afterStagingCreation
            case .truncateRejected: self = .truncateRejected
            case .pwriteRejected: self = .pwriteRejected
            case .pwriteZero: self = .pwriteZero
            case .pwriteShort: self = .pwriteShort
            case .pwriteOverrun: self = .pwriteOverrun
            case .modeSealRejected: self = .modeSealRejected
            case .stagingStatRejected: self = .stagingStatRejected
            case .fsyncRejected: self = .fsyncRejected
            case .fullSyncRejected: self = .fullSyncRejected
            case .stagingReadbackMismatch: self = .stagingReadbackMismatch
            case .renameCollision: self = .renameCollision
            case .renameResponseLost: self = .renameResponseLost
            case .finalInventoryRejected: self = .finalInventoryRejected
            case .directorySyncRejected: self = .directorySyncRejected
            case .finalOpenRejected: self = .finalOpenRejected
            case .finalIdentityRejected: self = .finalIdentityRejected
            case .finalReadbackMismatch: self = .finalReadbackMismatch
            case .finalDeserializeRejected: self = .finalDeserializeRejected
            case .finalSchemaRejected: self = .finalSchemaRejected
            case .finalRowRejected: self = .finalRowRejected
            case .finalSemanticRejected: self = .finalSemanticRejected
            case .finalReaderCloseRejected: self = .finalReaderCloseRejected
            case .finalDescriptorCloseRejected: self = .finalDescriptorCloseRejected
            case .parentReboundAfterPublish: self = .parentReboundAfterPublish
            }
        }
        #endif
    }

    final class Store: @unchecked Sendable {
        private enum ReconstructionPhase: Equatable {
            case prepublication
            case final
        }

        private enum NamespaceState {
            case empty
            case stagingOnly
            case finalOnly
            case stagingAndFinal
            case other
            case unavailable
        }

        private static let tableName = "h4_receipts"
        private static let tableSQL =
            "CREATE TABLE h4_receipts(" +
            "singleton INTEGER PRIMARY KEY CHECK(singleton=1)," +
            "semantic_schema TEXT NOT NULL CHECK(semantic_schema='" +
            H4C.semanticSchema + "')," +
            "claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS')," +
            "predicate_count INTEGER NOT NULL " +
            "CHECK(predicate_count>0 AND predicate_count<=4096)," +
            "authority_vector TEXT NOT NULL CHECK(authority_vector='00000000')," +
            "canonical_cbor BLOB NOT NULL " +
            "CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=158)" +
            ") STRICT, WITHOUT ROWID"
        private static let insertSQL =
            "INSERT INTO h4_receipts(" +
            "singleton,semantic_schema,claim_state,predicate_count," +
            "authority_vector,canonical_cbor) VALUES(1,?,?,?,?,?)"
        private static let rowSQL =
            "SELECT singleton,semantic_schema,claim_state,predicate_count," +
            "authority_vector,canonical_cbor FROM h4_receipts LIMIT 2"

        private let lock = NSLock()
        private let rootURL: URL
        private let rootPath: String
        private var directoryFD: Int32 = -1
        private let fault: Fault

        fileprivate init(rootURL: URL, fault: Fault) throws {
            self.rootURL = rootURL
            rootPath = rootURL.path
            self.fault = fault
            do {
                try admitFreshRoot()
            } catch {
                releaseRoot()
                throw error
            }
        }

        deinit { releaseRoot() }

        /// D2c holds only the root descriptor and a one-shot inspection state.
        /// No production factory exists in this slice; XCTest can construct a
        /// new object to prove restart-shaped mechanics without claiming a new
        /// operating-system process or continuity to the D2b publisher.
        #if EPR_H4_PRIVACY_TESTS
        final class RetainedV2Inspector: @unchecked Sendable {
            private enum State {
                case ready
                case claimed
                case finished
            }

            private let stateLock = NSLock()
            private var state: State = .ready
            private let rootPath: String
            private var directoryFD: Int32 = -1
            private let afterInitialInventoryForTest: (@Sendable () -> Void)?
            private let afterNamedFinalForTest: (@Sendable () -> Void)?
            private let afterReadForTest: (@Sendable () -> Void)?
            private let beforeTerminalRootForTest: (@Sendable () -> Void)?

            fileprivate init(
                rootURL: URL,
                afterInitialInventoryForTest: (@Sendable () -> Void)?,
                afterNamedFinalForTest: (@Sendable () -> Void)?,
                afterReadForTest: (@Sendable () -> Void)?,
                beforeTerminalRootForTest: (@Sendable () -> Void)?
            ) throws {
                rootPath = rootURL.path
                self.afterInitialInventoryForTest =
                    afterInitialInventoryForTest
                self.afterNamedFinalForTest = afterNamedFinalForTest
                self.afterReadForTest = afterReadForTest
                self.beforeTerminalRootForTest = beforeTerminalRootForTest
                try admit(rootURL)
            }

            deinit {
                if directoryFD >= 0 {
                    _ = Darwin.close(directoryFD)
                    directoryFD = -1
                }
            }

            func inspectRetainedV2Image() -> RetainedInspectionOutcome {
                stateLock.lock()
                switch state {
                case .ready:
                    state = .claimed
                    stateLock.unlock()
                case .claimed:
                    stateLock.unlock()
                    return .unavailable(.inProgress)
                case .finished:
                    stateLock.unlock()
                    return .unavailable(.alreadyConsumed)
                }

                let outcome = inspectOnce()
                stateLock.lock()
                state = .finished
                stateLock.unlock()
                return outcome
            }

            private func inspectOnce() -> RetainedInspectionOutcome {
                do {
                    try revalidateRoot()
                    let entries = try Store.directoryEntries(directoryFD)
                    switch entries {
                    case []:
                        return try terminalNamespaceOutcome(
                            expected: entries, outcome: .empty
                        )
                    case [Store.stagingLeaf]:
                        return try terminalNamespaceOutcome(
                            expected: entries, outcome: .stagingRetained
                        )
                    case [Store.finalLeaf]:
                        return inspectFinal()
                    case [Store.stagingLeaf, Store.finalLeaf]:
                        return try terminalNamespaceOutcome(
                            expected: entries, outcome: .namespaceAmbiguous
                        )
                    default:
                        return try terminalNamespaceOutcome(
                            expected: entries, outcome: .namespaceAmbiguous
                        )
                    }
                } catch let failure as RetainedInspectionFailure {
                    return .unavailable(failure)
                } catch {
                    return .unavailable(.namespaceRejected)
                }
            }

            private func terminalNamespaceOutcome(
                expected: Set<String>,
                outcome: RetainedInspectionOutcome
            ) throws -> RetainedInspectionOutcome {
                afterInitialInventoryForTest?()
                try revalidateRoot()
                guard try Store.directoryEntries(directoryFD) == expected else {
                    throw RetainedInspectionFailure.namespaceRejected
                }
                try revalidateRoot()
                return outcome
            }

            private func inspectFinal() -> RetainedInspectionOutcome {
                var finalFD: Int32 = -1
                do {
                    var named = stat()
                    guard Store.statLeaf(
                        Store.finalLeaf, in: directoryFD, value: &named
                    ) else {
                        throw RetainedInspectionFailure.identityRejected
                    }
                    try validateFinal(named)
                    afterNamedFinalForTest?()

                    finalFD = epr_h4d2c_open_final(directoryFD)
                    guard finalFD >= 0 else {
                        throw RetainedInspectionFailure.finalOpenRejected
                    }
                    var opened = stat()
                    guard fstat(finalFD, &opened) == 0,
                          Store.sameFile(named, opened) else {
                        throw RetainedInspectionFailure.identityRejected
                    }
                    try validateFinal(opened)
                    guard let count = Int(exactly: opened.st_size) else {
                        throw RetainedInspectionFailure.identityRejected
                    }
                    let bytes: Data
                    do {
                        bytes = try Store.readExact(
                            descriptor: finalFD, count: count
                        )
                    } catch {
                        throw RetainedInspectionFailure.readRejected
                    }
                    var afterRead = stat()
                    guard fstat(finalFD, &afterRead) == 0,
                          Store.sameFile(opened, afterRead) else {
                        throw RetainedInspectionFailure.identityRejected
                    }
                    afterReadForTest?()

                    let cborReceipt: H4C.RetainedCBORInspectionReceipt
                    do {
                        try Store.validateImage(bytes)
                        cborReceipt = try Store.inspectRetainedV2Image(bytes)
                    } catch let failure as RetainedInspectionFailure {
                        throw failure
                    } catch {
                        throw RetainedInspectionFailure.sqliteRejected
                    }
                    guard cborReceipt.canonicalCBORExact,
                          cborReceipt.indexedFieldsExact,
                          !cborReceipt.independentJSONPresent,
                          !cborReceipt.dualStreamJoinExact,
                          !cborReceipt.admitted else {
                        throw RetainedInspectionFailure.cborRejected
                    }

                    try revalidateRoot()
                    guard try Store.directoryEntries(directoryFD) ==
                            [Store.finalLeaf] else {
                        throw RetainedInspectionFailure.namespaceRejected
                    }
                    var rejoined = stat()
                    guard Store.statLeaf(
                        Store.finalLeaf, in: directoryFD, value: &rejoined
                    ), Store.sameFile(opened, rejoined) else {
                        throw RetainedInspectionFailure.identityRejected
                    }
                    try validateFinal(rejoined)
                    guard Store.closeDescriptorOnce(&finalFD) else {
                        throw RetainedInspectionFailure.closeRejected
                    }
                    beforeTerminalRootForTest?()
                    try revalidateRoot()
                    return .validV2CBOROnlyJSONMissing(
                        RetainedImageInspectionReceipt()
                    )
                } catch let failure as RetainedInspectionFailure {
                    _ = Store.closeDescriptorOnce(&finalFD)
                    return .publishedInvalid(failure)
                } catch {
                    _ = Store.closeDescriptorOnce(&finalFD)
                    return .publishedInvalid(.sqliteRejected)
                }
            }

            private func admit(_ rootURL: URL) throws {
                guard rootURL.isFileURL, rootURL.hasDirectoryPath,
                      rootPath.hasPrefix("/"), !rootPath.utf8.contains(0),
                      !rootPath.contains("//"),
                      !rootPath.split(separator: "/").contains(where: {
                          $0 == "." || $0 == ".."
                      }) else {
                    throw RetainedInspectionFailure.rootRejected
                }
                guard let resolved = realpath(rootPath, nil) else {
                    throw RetainedInspectionFailure.rootRejected
                }
                let physical = String(validatingCString: resolved)
                free(resolved)
                guard let physical, Store.exact(physical, rootPath) else {
                    throw RetainedInspectionFailure.rootRejected
                }
                var named = stat()
                guard lstat(rootPath, &named) == 0 else {
                    throw RetainedInspectionFailure.rootRejected
                }
                directoryFD = Darwin.open(
                    rootPath,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                )
                guard directoryFD >= 0,
                      flock(directoryFD, LOCK_SH | LOCK_NB) == 0 else {
                    if directoryFD >= 0 {
                        _ = Darwin.close(directoryFD)
                        directoryFD = -1
                    }
                    throw RetainedInspectionFailure.rootRejected
                }
                do {
                    var held = stat()
                    guard fstat(directoryFD, &held) == 0,
                          Store.sameDirectory(named, held) else {
                        throw RetainedInspectionFailure.rootRejected
                    }
                    try Store.validatePrivateDirectory(held)
                } catch {
                    _ = Darwin.close(directoryFD)
                    directoryFD = -1
                    throw RetainedInspectionFailure.rootRejected
                }
            }

            private func revalidateRoot() throws {
                guard directoryFD >= 0 else {
                    throw RetainedInspectionFailure.rootRejected
                }
                var named = stat()
                var held = stat()
                guard lstat(rootPath, &named) == 0,
                      fstat(directoryFD, &held) == 0,
                      Store.sameDirectory(named, held) else {
                    throw RetainedInspectionFailure.rootRejected
                }
                do {
                    try Store.validatePrivateDirectory(held)
                } catch {
                    throw RetainedInspectionFailure.rootRejected
                }
            }

            private func validateFinal(_ value: stat) throws {
                let cap = off_t(maximumDatabasePages * pageSize)
                guard value.st_mode & S_IFMT == S_IFREG,
                      value.st_mode & 0o7777 == 0o400,
                      value.st_uid == geteuid(), value.st_nlink == 1,
                      value.st_size >= 100, value.st_size <= cap,
                      value.st_size % off_t(pageSize) == 0 else {
                    throw RetainedInspectionFailure.identityRejected
                }
            }
        }
        #endif

        func append(
            _ canonical: H4C.Projection,
            remainsLive: () -> Bool
        ) -> StoreResult {
            lock.lock()
            defer { lock.unlock() }

            var database: OpaquePointer?
            var stagingFD: Int32 = -1
            var finalFD: Int32 = -1
            var transactionOpen = false
            var commitEntered = false
            var commitReturnedSuccess = false
            var stagingCreationEntered = false
            var stagingCreated = false
            var renameEntered = false
            var renameReturnedSuccess = false
            var rollbackExact = true
            var closeExact = true
            var operationFailure: Failure = .transactionRejected

            defer {
                _ = Self.closeDescriptorOnce(&finalFD)
                _ = Self.closeDescriptorOnce(&stagingFD)
                _ = Self.closeExact(&database)
            }

            do {
                try validateRoot(expected: [])
                database = try Self.openMemory(readOnly: false)
                try Self.configureWriter(database)
                #if EPR_H4_PRIVACY_TESTS
                if case .beforeBegin = fault { throw Failure.transactionRejected }
                #endif

                try Self.execute(database, "BEGIN IMMEDIATE")
                transactionOpen = true
                #if EPR_H4_PRIVACY_TESTS
                if case .afterBegin = fault { throw Failure.transactionRejected }
                #endif

                try Self.execute(database, Self.tableSQL)
                try Self.execute(database, "PRAGMA application_id=1162891828")
                try Self.execute(database, "PRAGMA user_version=1")
                #if EPR_H4_PRIVACY_TESTS
                if case .afterSchema = fault { throw Failure.transactionRejected }
                #endif

                try Self.insert(canonical, database: database)
                try Self.validateSchema(database)
                try Self.validateRowAndReconstruct(database, expected: canonical)
                #if EPR_H4_PRIVACY_TESTS
                if case .afterInsert = fault { throw Failure.transactionRejected }
                #endif
                guard remainsLive() else { throw Failure.expired }

                commitEntered = true
                #if EPR_H4_PRIVACY_TESTS
                if case .commitResponseLost = fault {
                    try Self.execute(database, "COMMIT")
                    transactionOpen = false
                    throw Failure.commitOutcomeUnknown
                }
                #endif
                try Self.execute(database, "COMMIT")
                transactionOpen = false
                commitReturnedSuccess = true
                guard sqlite3_get_autocommit(database) == 1,
                      sqlite3_txn_state(database, "main") == SQLITE_TXN_NONE,
                      sqlite3_db_readonly(database, "main") == 0 else {
                    throw Failure.transactionRejected
                }
                if let filename = sqlite3_db_filename(database, "main"),
                   filename.pointee != 0 {
                    throw Failure.sqlitePolicyRejected
                }

                var image = try serialize(database)
                #if EPR_H4_PRIVACY_TESTS
                switch fault {
                case .serializedOversize:
                    image = Data(repeating: 0, count: Int(
                        maximumDatabasePages * pageSize + 1
                    ))
                case .serializedMisaligned:
                    image.append(0)
                case .serializedBadHeader:
                    if !image.isEmpty { image[image.startIndex] ^= 0xff }
                case .writerCloseRejected:
                    _ = try Self.prepare(database, "SELECT 1")
                default:
                    break
                }
                #endif
                guard Self.closeExact(&database) else {
                    throw Failure.closeRejected
                }
                try Self.validateImage(image)
                try reconstruct(
                    image, expected: canonical, phase: .prepublication
                )
                guard remainsLive() else { throw Failure.expired }
                try validateRoot(expected: [])

                stagingCreationEntered = true
                stagingFD = epr_h4d2b_create_staging(directoryFD)
                guard stagingFD >= 0 else {
                    throw Failure.stagingCreationRejected
                }
                stagingCreated = true
                #if EPR_H4_PRIVACY_TESTS
                if case .afterStagingCreation = fault {
                    throw Failure.stagingCreationRejected
                }
                #endif
                try validateRoot(expected: [Self.stagingLeaf])
                var initialStage = stat()
                guard fstat(stagingFD, &initialStage) == 0 else {
                    throw Failure.identityRejected
                }
                try Self.validateFile(
                    initialStage, mode: 0o600, exactSize: 0
                )

                #if EPR_H4_PRIVACY_TESTS
                if case .truncateRejected = fault { throw Failure.truncateRejected }
                #endif
                guard ftruncate(stagingFD, off_t(image.count)) == 0 else {
                    throw Failure.truncateRejected
                }
                let written = try injectedWrite(image, descriptor: stagingFD)
                guard written == image.count else { throw Failure.writeRejected }

                #if EPR_H4_PRIVACY_TESTS
                if case .modeSealRejected = fault { throw Failure.modeSealRejected }
                #endif
                guard fchmod(stagingFD, mode_t(0o400)) == 0 else {
                    throw Failure.modeSealRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                if case .stagingStatRejected = fault { throw Failure.identityRejected }
                #endif
                var sealedStage = stat()
                guard fstat(stagingFD, &sealedStage) == 0 else {
                    throw Failure.identityRejected
                }
                try Self.validateFile(
                    sealedStage, mode: 0o400, exactSize: off_t(image.count)
                )
                #if EPR_H4_PRIVACY_TESTS
                if case .fsyncRejected = fault { throw Failure.syncRejected }
                #endif
                guard fsync(stagingFD) == 0 else { throw Failure.syncRejected }
                #if EPR_H4_PRIVACY_TESTS
                if case .fullSyncRejected = fault { throw Failure.syncRejected }
                #endif
                guard fcntl(stagingFD, F_FULLFSYNC) == 0 else {
                    throw Failure.syncRejected
                }
                var stagingBytes = try Self.readExact(
                    descriptor: stagingFD, count: image.count
                )
                #if EPR_H4_PRIVACY_TESTS
                if case .stagingReadbackMismatch = fault, !stagingBytes.isEmpty {
                    stagingBytes[stagingBytes.startIndex] ^= 0xff
                }
                #endif
                guard stagingBytes == image else { throw Failure.readbackRejected }
                try validateRoot(expected: [Self.stagingLeaf])
                var joinedStage = stat()
                guard fstat(stagingFD, &joinedStage) == 0,
                      Self.sameFile(sealedStage, joinedStage) else {
                    throw Failure.identityRejected
                }
                guard remainsLive() else { throw Failure.expired }

                #if EPR_H4_PRIVACY_TESTS
                if case .renameCollision = fault {
                    try createTestLeaf(Self.finalLeaf, mode: 0o400)
                }
                #endif
                renameEntered = true
                let renameStatus = epr_h4d2b_publish_staging(directoryFD)
                #if EPR_H4_PRIVACY_TESTS
                if case .renameResponseLost = fault {
                    guard renameStatus == 0 else { throw Failure.publicationRejected }
                    throw Failure.publicationRejected
                }
                #endif
                guard renameStatus == 0 else { throw Failure.publicationRejected }
                renameReturnedSuccess = true

                #if EPR_H4_PRIVACY_TESTS
                if case .finalInventoryRejected = fault {
                    try createTestLeaf(".h4d2b-unexpected", mode: 0o600)
                }
                #endif
                try validateRoot(expected: [Self.finalLeaf])
                var namedFinal = stat()
                guard Self.statLeaf(
                    Self.finalLeaf, in: directoryFD, value: &namedFinal
                ), Self.sameFileAcrossRename(sealedStage, namedFinal) else {
                    throw Failure.identityRejected
                }
                try Self.validateFile(
                    namedFinal, mode: 0o400, exactSize: off_t(image.count)
                )
                #if EPR_H4_PRIVACY_TESTS
                if case .directorySyncRejected = fault {
                    throw Failure.directorySyncRejected
                }
                #endif
                guard fsync(directoryFD) == 0 else {
                    throw Failure.directorySyncRejected
                }

                #if EPR_H4_PRIVACY_TESTS
                if case .finalOpenRejected = fault { throw Failure.finalOpenRejected }
                if case .finalIdentityRejected = fault {
                    try replaceFinalForTest()
                }
                #endif
                finalFD = epr_h4d2b_open_final(directoryFD)
                guard finalFD >= 0 else { throw Failure.finalOpenRejected }
                var openedFinal = stat()
                guard fstat(finalFD, &openedFinal) == 0,
                      Self.sameFile(namedFinal, openedFinal) else {
                    throw Failure.identityRejected
                }
                var finalBytes = try Self.readExact(
                    descriptor: finalFD, count: image.count
                )
                #if EPR_H4_PRIVACY_TESTS
                if case .finalReadbackMismatch = fault, !finalBytes.isEmpty {
                    finalBytes[finalBytes.startIndex] ^= 0xff
                }
                #endif
                guard finalBytes == image else { throw Failure.readbackRejected }
                try reconstruct(finalBytes, expected: canonical, phase: .final)
                #if EPR_H4_PRIVACY_TESTS
                if case .finalDescriptorCloseRejected = fault {
                    throw Failure.closeRejected
                }
                #endif
                guard Self.closeDescriptorOnce(&finalFD),
                      Self.closeDescriptorOnce(&stagingFD) else {
                    throw Failure.closeRejected
                }

                #if EPR_H4_PRIVACY_TESTS
                if case .parentReboundAfterPublish = fault {
                    try reboundParentForTest()
                }
                #endif
                try validateRoot(expected: [Self.finalLeaf])
                var finalRejoin = stat()
                guard Self.statLeaf(
                    Self.finalLeaf, in: directoryFD, value: &finalRejoin
                ), Self.sameFile(namedFinal, finalRejoin) else {
                    throw Failure.identityRejected
                }
                return .admitted(ReopenReceipt())
            } catch let failure as Failure {
                operationFailure = failure
            } catch {
                operationFailure = .storeAdmissionRejected
            }

            if transactionOpen, !commitEntered {
                do {
                    try Self.execute(database, "ROLLBACK")
                    transactionOpen = false
                } catch {
                    rollbackExact = false
                }
            }
            closeExact = Self.closeExact(&database)
            if !rollbackExact || !closeExact {
                operationFailure = .closeRejected
            }

            if renameReturnedSuccess {
                return .publishedUnverified(operationFailure)
            }
            if renameEntered {
                return .publicationOutcomeUnknown(operationFailure)
            }
            if stagingCreated {
                return .stagingRetained(operationFailure)
            }
            if stagingCreationEntered {
                return .prepublicationStateUnknown(operationFailure)
            }
            if commitEntered, !commitReturnedSuccess {
                return .transactionOutcomeUnknown(.commitOutcomeUnknown)
            }
            guard namespaceState() == .empty else {
                return .prepublicationStateUnknown(operationFailure)
            }
            return .rejectedBeforePublication(operationFailure)
        }

        private static var stagingLeaf: String {
            HypervisorStageH4Persistence.stagingLeafName
        }

        private static var finalLeaf: String {
            HypervisorStageH4Persistence.finalLeafName
        }

        private func admitFreshRoot() throws {
            guard rootURL.isFileURL, rootURL.hasDirectoryPath,
                  rootPath.hasPrefix("/"), !rootPath.utf8.contains(0),
                  !rootPath.contains("//"),
                  !rootPath.split(separator: "/").contains(where: {
                      $0 == "." || $0 == ".."
                  }) else {
                throw Failure.storeAdmissionRejected
            }
            guard let resolved = realpath(rootPath, nil) else {
                throw Failure.storeAdmissionRejected
            }
            let physical = String(validatingCString: resolved)
            free(resolved)
            guard let physical, Self.exact(physical, rootPath) else {
                throw Failure.storeAdmissionRejected
            }
            var named = stat()
            guard lstat(rootPath, &named) == 0 else {
                throw Failure.storeAdmissionRejected
            }
            directoryFD = Darwin.open(
                rootPath, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard directoryFD >= 0, flock(directoryFD, LOCK_EX | LOCK_NB) == 0 else {
                throw Failure.storeAdmissionRejected
            }
            var held = stat()
            guard fstat(directoryFD, &held) == 0,
                  Self.sameDirectory(named, held) else {
                throw Failure.storeAdmissionRejected
            }
            try Self.validatePrivateDirectory(held)
            try validateRoot(expected: [])
        }

        private func validateRoot(expected: Set<String>) throws {
            guard directoryFD >= 0 else { throw Failure.storeAdmissionRejected }
            var named = stat()
            var held = stat()
            guard lstat(rootPath, &named) == 0,
                  fstat(directoryFD, &held) == 0,
                  Self.sameDirectory(named, held) else {
                throw Failure.storeAdmissionRejected
            }
            try Self.validatePrivateDirectory(held)
            guard try Self.directoryEntries(directoryFD) == expected else {
                throw Failure.storeAdmissionRejected
            }
        }

        private func namespaceState() -> NamespaceState {
            guard let entries = try? Self.directoryEntries(directoryFD) else {
                return .unavailable
            }
            switch entries {
            case []: return .empty
            case [Self.stagingLeaf]: return .stagingOnly
            case [Self.finalLeaf]: return .finalOnly
            case [Self.stagingLeaf, Self.finalLeaf]: return .stagingAndFinal
            default: return .other
            }
        }

        private func serialize(_ database: OpaquePointer?) throws -> Data {
            #if EPR_H4_PRIVACY_TESTS
            if case .serializeRejected = fault { throw Failure.serializationRejected }
            #endif
            var storage = Data(count: Int(maximumDatabasePages * pageSize))
            var count: Int64 = 0
            let status = storage.withUnsafeMutableBytes { bytes in
                epr_h4d2b_sqlite_serialize_main(
                    UnsafeMutableRawPointer(database),
                    bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    &count
                )
            }
            guard status == SQLITE_OK, let exact = Int(exactly: count),
                  exact > 0, exact <= storage.count else {
                throw Failure.serializationRejected
            }
            storage.removeSubrange(exact..<storage.count)
            return storage
        }

        private func reconstruct(
            _ image: Data,
            expected: H4C.Projection,
            phase: ReconstructionPhase
        ) throws {
            try Self.validateImage(image)
            #if EPR_H4_PRIVACY_TESTS
            if phase == .prepublication,
               case .prepublicationDeserializeRejected = fault {
                throw Failure.reconstructionRejected
            }
            if phase == .final, case .finalDeserializeRejected = fault {
                throw Failure.reconstructionRejected
            }
            #endif
            var database: OpaquePointer?
            do {
                database = try Self.openMemory(readOnly: true)
                guard let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                    throw Failure.reconstructionRejected
                }
                image.copyBytes(
                    to: allocation.assumingMemoryBound(to: UInt8.self),
                    count: image.count
                )
                guard epr_sqlite_deserialize_readonly(
                    UnsafeMutableRawPointer(database),
                    allocation.assumingMemoryBound(to: UInt8.self),
                    Int64(image.count)
                ) == SQLITE_OK else {
                    throw Failure.reconstructionRejected
                }
                try Self.configureReader(database)
                guard try Self.scalarText(
                    database, "PRAGMA integrity_check(1)"
                ) == "ok" else {
                    throw Failure.reconstructionRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                if phase == .prepublication,
                   case .prepublicationSchemaRejected = fault {
                    throw Failure.reconstructionRejected
                }
                if phase == .final, case .finalSchemaRejected = fault {
                    throw Failure.reconstructionRejected
                }
                #endif
                try Self.validateSchema(database)
                guard epr_sqlite_install_readonly_authorizer(
                    UnsafeMutableRawPointer(database)
                ) == SQLITE_OK else {
                    throw Failure.reconstructionRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                if phase == .prepublication,
                   case .prepublicationRowRejected = fault {
                    throw Failure.reconstructionRejected
                }
                if phase == .final, case .finalRowRejected = fault {
                    throw Failure.reconstructionRejected
                }
                #endif
                try Self.validateRowAndReconstruct(database, expected: expected)
                #if EPR_H4_PRIVACY_TESTS
                if phase == .prepublication,
                   case .prepublicationSemanticRejected = fault {
                    throw Failure.reconstructionRejected
                }
                if phase == .final, case .finalSemanticRejected = fault {
                    throw Failure.reconstructionRejected
                }
                if phase == .prepublication,
                   case .prepublicationCloseRejected = fault {
                    _ = try Self.prepare(database, "SELECT 1")
                }
                if phase == .final, case .finalReaderCloseRejected = fault {
                    _ = try Self.prepare(database, "SELECT 1")
                }
                #endif
                guard Self.closeExact(&database) else {
                    throw Failure.closeRejected
                }
            } catch {
                _ = Self.closeExact(&database)
                if let failure = error as? Failure { throw failure }
                throw Failure.reconstructionRejected
            }
        }

        /// D2c reconstructs only the subset that the retained v2 image carries.
        /// It does not synthesize JSON or restore the D2b owner/lease.
        private static func inspectRetainedV2Image(
            _ image: Data
        ) throws -> H4C.RetainedCBORInspectionReceipt {
            var database: OpaquePointer?
            do {
                database = try openMemory(readOnly: true)
                guard let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                    throw RetainedInspectionFailure.sqliteRejected
                }
                image.copyBytes(
                    to: allocation.assumingMemoryBound(to: UInt8.self),
                    count: image.count
                )
                guard epr_sqlite_deserialize_readonly(
                    UnsafeMutableRawPointer(database),
                    allocation.assumingMemoryBound(to: UInt8.self),
                    Int64(image.count)
                ) == SQLITE_OK else {
                    throw RetainedInspectionFailure.sqliteRejected
                }
                try configureReader(database)
                guard sqlite3_get_autocommit(database) == 1,
                      sqlite3_txn_state(database, "main") == SQLITE_TXN_NONE,
                      try scalarText(database, "PRAGMA integrity_check(1)") == "ok"
                else {
                    throw RetainedInspectionFailure.sqliteRejected
                }
                if let filename = sqlite3_db_filename(database, "main"),
                   filename.pointee != 0 {
                    throw RetainedInspectionFailure.sqliteRejected
                }
                try validateSchema(database)
                guard epr_sqlite_install_readonly_authorizer(
                    UnsafeMutableRawPointer(database)
                ) == SQLITE_OK else {
                    throw RetainedInspectionFailure.sqliteRejected
                }

                let receipt = try inspectRetainedV2Row(database)
                guard closeExact(&database) else {
                    throw RetainedInspectionFailure.closeRejected
                }
                return receipt
            } catch {
                _ = closeExact(&database)
                if let failure = error as? RetainedInspectionFailure {
                    throw failure
                }
                throw RetainedInspectionFailure.sqliteRejected
            }
        }

        /// Keep the SQLite statement lifetime strictly inside this helper so
        /// it is finalized before the caller attempts the exact database close.
        private static func inspectRetainedV2Row(
            _ database: OpaquePointer?
        ) throws -> H4C.RetainedCBORInspectionReceipt {
            let statement = try prepare(database, rowSQL)
            defer { sqlite3_finalize(statement) }
            guard sqlite3_step(statement) == SQLITE_ROW,
                  sqlite3_column_type(statement, 0) == SQLITE_INTEGER,
                  sqlite3_column_int64(statement, 0) == 1,
                  sqlite3_column_type(statement, 3) == SQLITE_INTEGER else {
                throw RetainedInspectionFailure.sqliteRejected
            }
            let semanticSchema = try text(
                statement, column: 1, maximum: 128
            )
            let claimState = try text(
                statement, column: 2, maximum: 32
            )
            let predicateCount = sqlite3_column_int64(statement, 3)
            let authorityVector = try text(
                statement, column: 4, maximum: 16
            )
            guard sqlite3_column_type(statement, 5) == SQLITE_BLOB else {
                throw RetainedInspectionFailure.sqliteRejected
            }
            let count = Int(sqlite3_column_bytes(statement, 5))
            guard count > 0, count <= H4C.maximumStreamBytes,
                  let pointer = sqlite3_column_blob(statement, 5) else {
                throw RetainedInspectionFailure.sqliteRejected
            }
            let cbor = Data(bytes: pointer, count: count)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw RetainedInspectionFailure.sqliteRejected
            }
            let reopened = ReopenedSQLiteRowInput(
                canonicalCBOR: cbor,
                semanticSchema: semanticSchema,
                claimState: claimState,
                predicateCount: predicateCount,
                authorityVector: authorityVector
            )
            let receipt: H4C.RetainedCBORInspectionReceipt
            do {
                receipt = try H4C.inspectRetainedCBOR(reopened)
            } catch {
                throw RetainedInspectionFailure.cborRejected
            }
            return receipt
        }

        private func injectedWrite(
            _ image: Data,
            descriptor: Int32
        ) throws -> Int {
            #if EPR_H4_PRIVACY_TESTS
            switch fault {
            case .pwriteRejected: return -1
            case .pwriteZero: return 0
            case .pwriteOverrun: return image.count + 1
            case .pwriteShort:
                guard image.count > 1 else { return 0 }
                return image.withUnsafeBytes { bytes in
                    Int(pwrite(descriptor, bytes.baseAddress, image.count - 1, 0))
                }
            default:
                break
            }
            #endif
            return image.withUnsafeBytes { bytes in
                Int(pwrite(descriptor, bytes.baseAddress, image.count, 0))
            }
        }

        #if EPR_H4_PRIVACY_TESTS
        private func createTestLeaf(_ leaf: String, mode: mode_t) throws {
            let descriptor = leaf.withCString {
                openat(
                    directoryFD, $0,
                    O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                    mode
                )
            }
            guard descriptor >= 0 else { throw Failure.storeAdmissionRejected }
            var value = descriptor
            guard Self.closeDescriptorOnce(&value) else {
                throw Failure.closeRejected
            }
        }

        private func replaceFinalForTest() throws {
            let displaced = ".h4d2b-displaced"
            let status = Self.finalLeaf.withCString { source in
                displaced.withCString { target in
                    renameatx_np(
                        directoryFD, source, directoryFD, target,
                        UInt32(RENAME_EXCL | RENAME_NOFOLLOW_ANY |
                            RENAME_RESOLVE_BENEATH)
                    )
                }
            }
            guard status == 0 else { throw Failure.identityRejected }
            try createTestLeaf(Self.finalLeaf, mode: 0o400)
        }

        private func reboundParentForTest() throws {
            let displaced = rootPath + ".h4d2b-displaced"
            guard rename(rootPath, displaced) == 0,
                  mkdir(rootPath, mode_t(0o700)) == 0 else {
                throw Failure.identityRejected
            }
        }
        #endif

        private func releaseRoot() {
            if directoryFD >= 0 {
                _ = Darwin.close(directoryFD)
                directoryFD = -1
            }
        }

        private static func openMemory(readOnly: Bool) throws -> OpaquePointer {
            var database: OpaquePointer?
            let mode = readOnly ? SQLITE_OPEN_READWRITE :
                (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
            let flags = mode | SQLITE_OPEN_MEMORY | SQLITE_OPEN_FULLMUTEX |
                SQLITE_OPEN_PRIVATECACHE | SQLITE_OPEN_EXRESCODE
            let status = sqlite3_open_v2(":memory:", &database, flags, nil)
            guard status == SQLITE_OK, let database else {
                if let database { sqlite3_close(database) }
                throw Failure.sqlitePolicyRejected
            }
            return database
        }

        private static func configureWriter(_ database: OpaquePointer?) throws {
            try checked(sqlite3_extended_result_codes(database, 1))
            try checked(sqlite3_busy_timeout(database, 0))
            try installLimits(database)
            var policy = EPRSQLiteWriterPolicy()
            guard epr_sqlite_harden_writer(
                UnsafeMutableRawPointer(database), &policy
            ) == SQLITE_OK, policy.defensive == 1,
              policy.trusted_schema == 0, policy.dqs_ddl == 0,
              policy.dqs_dml == 0 else { throw Failure.sqlitePolicyRejected }
            try execute(database, "PRAGMA page_size=4096")
            try execute(database, "PRAGMA foreign_keys=ON")
            try execute(database, "PRAGMA trusted_schema=OFF")
            try execute(database, "PRAGMA temp_store=MEMORY")
            try execute(database, "PRAGMA cell_size_check=ON")
            guard try scalarText(database, "PRAGMA journal_mode=MEMORY") == "memory",
                  try scalarInteger(database, "PRAGMA page_size") == pageSize,
                  try scalarInteger(database, "PRAGMA max_page_count=64") ==
                    maximumDatabasePages,
                  try scalarInteger(database, "PRAGMA foreign_keys") == 1,
                  try scalarInteger(database, "PRAGMA trusted_schema") == 0,
                  try scalarInteger(database, "PRAGMA temp_store") == 2,
                  try scalarInteger(database, "PRAGMA cell_size_check") == 1,
                  try scalarInteger(database, "PRAGMA user_version") == 0,
                  try scalarInteger(database, "PRAGMA application_id") == 0,
                  try scalarInteger(database,
                    "SELECT count(*) FROM sqlite_schema") == 0 else {
                throw Failure.sqlitePolicyRejected
            }
        }

        private static func configureReader(_ database: OpaquePointer?) throws {
            try checked(sqlite3_extended_result_codes(database, 1))
            try checked(sqlite3_busy_timeout(database, 0))
            try installLimits(database)
            var policy = EPRSQLiteReadOnlyPolicy()
            guard epr_sqlite_harden_readonly(
                UnsafeMutableRawPointer(database), &policy
            ) == SQLITE_OK, policy.defensive == 1,
              policy.trusted_schema == 0, policy.dqs_ddl == 0,
              policy.dqs_dml == 0 else { throw Failure.sqlitePolicyRejected }
            try execute(database, "PRAGMA query_only=ON")
            try execute(database, "PRAGMA trusted_schema=OFF")
            try execute(database, "PRAGMA temp_store=MEMORY")
            try execute(database, "PRAGMA foreign_keys=ON")
            try execute(database, "PRAGMA cell_size_check=ON")
            guard try scalarInteger(database, "PRAGMA query_only") == 1,
                  try scalarInteger(database, "PRAGMA trusted_schema") == 0,
                  try scalarInteger(database, "PRAGMA temp_store") == 2,
                  try scalarInteger(database, "PRAGMA foreign_keys") == 1,
                  try scalarInteger(database, "PRAGMA cell_size_check") == 1 else {
                throw Failure.sqlitePolicyRejected
            }
        }

        private static func installLimits(_ database: OpaquePointer?) throws {
            let limits: [(Int32, Int32)] = [
                (SQLITE_LIMIT_LENGTH, 1_024),
                (SQLITE_LIMIT_SQL_LENGTH, 8_192),
                (SQLITE_LIMIT_COLUMN, 16),
                (SQLITE_LIMIT_EXPR_DEPTH, 16),
                (SQLITE_LIMIT_COMPOUND_SELECT, 1),
                (SQLITE_LIMIT_VDBE_OP, 20_000),
                (SQLITE_LIMIT_FUNCTION_ARG, 8),
                (SQLITE_LIMIT_ATTACHED, 0),
                (SQLITE_LIMIT_TRIGGER_DEPTH, 0),
                (SQLITE_LIMIT_WORKER_THREADS, 0),
            ]
            for (identifier, requested) in limits {
                guard sqlite3_limit(database, identifier, requested) >= 0,
                      sqlite3_limit(database, identifier, -1) == requested else {
                    throw Failure.sqlitePolicyRejected
                }
            }
        }

        private static func insert(
            _ projection: H4C.Projection,
            database: OpaquePointer?
        ) throws {
            let semantic = projection.reconstruction.semantic
            let statement = try prepare(database, insertSQL)
            defer { sqlite3_finalize(statement) }
            try bind(semantic.schema, index: 1, statement: statement)
            try bind(semantic.claimState.rawValue, index: 2, statement: statement)
            try checked(sqlite3_bind_int64(
                statement, 3, Int64(semantic.predicateCount)
            ))
            try bind(semantic.authorityVector, index: 4, statement: statement)
            try bind(projection.cbor, index: 5, statement: statement)
            guard sqlite3_step(statement) == SQLITE_DONE,
                  sqlite3_changes(database) == 1 else {
                throw Failure.transactionRejected
            }
        }

        private static func validateSchema(_ database: OpaquePointer?) throws {
            guard try scalarInteger(database, "PRAGMA user_version") == userVersion,
                  try scalarInteger(database, "PRAGMA application_id") ==
                    applicationID else {
                throw Failure.reconstructionRejected
            }
            let catalog = try prepare(
                database, "SELECT type,name,tbl_name,sql FROM sqlite_schema LIMIT 2"
            )
            defer { sqlite3_finalize(catalog) }
            guard sqlite3_step(catalog) == SQLITE_ROW,
                  try text(catalog, column: 0, maximum: 16) == "table",
                  try text(catalog, column: 1, maximum: 64) == tableName,
                  try text(catalog, column: 2, maximum: 64) == tableName,
                  try text(catalog, column: 3, maximum: 1_024) == tableSQL,
                  sqlite3_step(catalog) == SQLITE_DONE else {
                throw Failure.reconstructionRejected
            }

            let columns = try prepare(database, "PRAGMA table_xinfo(h4_receipts)")
            defer { sqlite3_finalize(columns) }
            let expected: [(String, String, Int64, Int64, Int64)] = [
                ("singleton", "INTEGER", 1, 1, 0),
                ("semantic_schema", "TEXT", 1, 0, 0),
                ("claim_state", "TEXT", 1, 0, 0),
                ("predicate_count", "INTEGER", 1, 0, 0),
                ("authority_vector", "TEXT", 1, 0, 0),
                ("canonical_cbor", "BLOB", 1, 0, 0),
            ]
            for (index, value) in expected.enumerated() {
                guard sqlite3_step(columns) == SQLITE_ROW,
                      sqlite3_column_type(columns, 0) == SQLITE_INTEGER,
                      sqlite3_column_int64(columns, 0) == Int64(index),
                      try text(columns, column: 1, maximum: 64) == value.0,
                      try text(columns, column: 2, maximum: 16) == value.1,
                      sqlite3_column_type(columns, 3) == SQLITE_INTEGER,
                      sqlite3_column_int64(columns, 3) == value.2,
                      sqlite3_column_type(columns, 5) == SQLITE_INTEGER,
                      sqlite3_column_int64(columns, 5) == value.3,
                      sqlite3_column_type(columns, 6) == SQLITE_INTEGER,
                      sqlite3_column_int64(columns, 6) == value.4 else {
                    throw Failure.reconstructionRejected
                }
            }
            guard sqlite3_step(columns) == SQLITE_DONE else {
                throw Failure.reconstructionRejected
            }
        }

        private static func validateRowAndReconstruct(
            _ database: OpaquePointer?,
            expected: H4C.Projection
        ) throws {
            let statement = try prepare(database, rowSQL)
            defer { sqlite3_finalize(statement) }
            guard sqlite3_step(statement) == SQLITE_ROW,
                  sqlite3_column_type(statement, 0) == SQLITE_INTEGER,
                  sqlite3_column_int64(statement, 0) == 1,
                  sqlite3_column_type(statement, 3) == SQLITE_INTEGER else {
                throw Failure.reconstructionRejected
            }
            let semanticSchema = try text(statement, column: 1, maximum: 128)
            let claimState = try text(statement, column: 2, maximum: 32)
            let predicateCount = sqlite3_column_int64(statement, 3)
            let authorityVector = try text(statement, column: 4, maximum: 16)
            guard sqlite3_column_type(statement, 5) == SQLITE_BLOB else {
                throw Failure.reconstructionRejected
            }
            let count = Int(sqlite3_column_bytes(statement, 5))
            guard count > 0, count <= H4C.maximumStreamBytes,
                  let pointer = sqlite3_column_blob(statement, 5) else {
                throw Failure.reconstructionRejected
            }
            let cbor = Data(bytes: pointer, count: count)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw Failure.reconstructionRejected
            }
            let reopened = ReopenedSQLiteRowInput(
                canonicalCBOR: cbor,
                semanticSchema: semanticSchema,
                claimState: claimState,
                predicateCount: predicateCount,
                authorityVector: authorityVector
            )
            let reconstruction: H4C.ReconstructionReceipt
            do {
                reconstruction = try H4C.reconstructPersisted(
                    reopened, expected: expected
                )
            } catch {
                throw Failure.reconstructionRejected
            }
            guard reconstruction.jsonRoundTripExact,
                  reconstruction.cborRoundTripExact,
                  reconstruction.semanticJoinExact else {
                throw Failure.reconstructionRejected
            }
        }

        private static func validateImage(_ image: Data) throws {
            let cap = Int(maximumDatabasePages * pageSize)
            guard image.count >= 100, image.count <= cap,
                  image.count % Int(pageSize) == 0 else {
                throw Failure.serializationRejected
            }
            let bytes = [UInt8](image.prefix(100))
            let magic = Array("SQLite format 3\0".utf8)
            guard Array(bytes[0..<16]) == magic,
                  bytes[16] == 0x10, bytes[17] == 0x00,
                  bytes[18] == 1, bytes[19] == 1 else {
                throw Failure.serializationRejected
            }
            let pages = UInt32(bytes[28]) << 24 |
                UInt32(bytes[29]) << 16 |
                UInt32(bytes[30]) << 8 |
                UInt32(bytes[31])
            guard pages > 0,
                  UInt64(pages) * UInt64(pageSize) == UInt64(image.count) else {
                throw Failure.serializationRejected
            }
        }

        private static func validatePrivateDirectory(_ value: stat) throws {
            guard value.st_mode & S_IFMT == S_IFDIR,
                  value.st_mode & 0o7777 == 0o700,
                  value.st_uid == geteuid() else {
                throw Failure.storeAdmissionRejected
            }
        }

        private static func validateFile(
            _ value: stat,
            mode: mode_t,
            exactSize: off_t
        ) throws {
            guard value.st_mode & S_IFMT == S_IFREG,
                  value.st_mode & 0o7777 == mode,
                  value.st_uid == geteuid(), value.st_nlink == 1,
                  value.st_size == exactSize,
                  exactSize >= 0,
                  exactSize <= off_t(maximumDatabasePages * pageSize) else {
                throw Failure.identityRejected
            }
        }

        private static func sameDirectory(_ left: stat, _ right: stat) -> Bool {
            left.st_dev == right.st_dev && left.st_ino == right.st_ino &&
                left.st_mode == right.st_mode && left.st_uid == right.st_uid &&
                left.st_gid == right.st_gid && left.st_nlink == right.st_nlink &&
                left.st_flags == right.st_flags
        }

        private static func sameFile(_ left: stat, _ right: stat) -> Bool {
            left.st_dev == right.st_dev && left.st_ino == right.st_ino &&
                left.st_mode == right.st_mode && left.st_uid == right.st_uid &&
                left.st_gid == right.st_gid && left.st_nlink == right.st_nlink &&
                left.st_size == right.st_size && left.st_flags == right.st_flags &&
                left.st_mtimespec.tv_sec == right.st_mtimespec.tv_sec &&
                left.st_mtimespec.tv_nsec == right.st_mtimespec.tv_nsec &&
                left.st_ctimespec.tv_sec == right.st_ctimespec.tv_sec &&
                left.st_ctimespec.tv_nsec == right.st_ctimespec.tv_nsec
        }

        /// Atomic rename preserves the vnode and sealed content metadata but
        /// may change ctime. Capture the post-rename stat as the new exact
        /// baseline instead of treating wall-clock-derived ctime as stable
        /// across the rename itself.
        private static func sameFileAcrossRename(
            _ before: stat,
            _ after: stat
        ) -> Bool {
            return before.st_dev == after.st_dev &&
                before.st_ino == after.st_ino &&
                before.st_mode == after.st_mode &&
                before.st_uid == after.st_uid &&
                before.st_gid == after.st_gid &&
                before.st_nlink == after.st_nlink &&
                before.st_size == after.st_size &&
                before.st_flags == after.st_flags &&
                before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec &&
                before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec
        }

        private static func statLeaf(
            _ leaf: String,
            in directory: Int32,
            value: inout stat
        ) -> Bool {
            leaf.withCString {
                fstatat(directory, $0, &value, AT_SYMLINK_NOFOLLOW) == 0
            }
        }

        private static func directoryEntries(
            _ directory: Int32
        ) throws -> Set<String> {
            let scanFD = ".".withCString {
                openat(
                    directory, $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard scanFD >= 0 else { throw Failure.storeAdmissionRejected }
            var scan = stat()
            var held = stat()
            guard fstat(scanFD, &scan) == 0, fstat(directory, &held) == 0,
                  sameDirectory(scan, held) else {
                _ = Darwin.close(scanFD)
                throw Failure.storeAdmissionRejected
            }
            guard let stream = fdopendir(scanFD) else {
                _ = Darwin.close(scanFD)
                throw Failure.storeAdmissionRejected
            }
            var values = Set<String>()
            var readFailure = false
            while true {
                errno = 0
                guard let entry = readdir(stream) else {
                    readFailure = errno != 0
                    break
                }
                let capacity = MemoryLayout.size(ofValue: entry.pointee.d_name)
                let name = withUnsafePointer(to: entry.pointee.d_name) { pointer in
                    pointer.withMemoryRebound(
                        to: CChar.self, capacity: capacity
                    ) { String(validatingCString: $0) }
                }
                guard let name, !name.isEmpty, !name.utf8.contains(0) else {
                    readFailure = true
                    break
                }
                if name == "." || name == ".." { continue }
                guard values.insert(name).inserted else {
                    readFailure = true
                    break
                }
            }
            let closeStatus = closedir(stream)
            guard !readFailure, closeStatus == 0 else {
                throw Failure.storeAdmissionRejected
            }
            return values
        }

        private static func readExact(
            descriptor: Int32,
            count: Int
        ) throws -> Data {
            guard count > 0, count <= Int(maximumDatabasePages * pageSize) else {
                throw Failure.readbackRejected
            }
            var data = Data(count: count)
            var offset = 0
            while offset < count {
                let result = data.withUnsafeMutableBytes { bytes in
                    pread(
                        descriptor,
                        bytes.baseAddress?.advanced(by: offset),
                        count - offset,
                        off_t(offset)
                    )
                }
                if result < 0, errno == EINTR { continue }
                guard result > 0 else { throw Failure.readbackRejected }
                offset += result
            }
            var extra: UInt8 = 0
            var eof: Int
            repeat {
                eof = pread(descriptor, &extra, 1, off_t(count))
            } while eof < 0 && errno == EINTR
            guard eof == 0 else { throw Failure.readbackRejected }
            return data
        }

        private static func execute(
            _ database: OpaquePointer?,
            _ sql: String
        ) throws {
            guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
                throw Failure.transactionRejected
            }
        }

        private static func prepare(
            _ database: OpaquePointer?,
            _ sql: String
        ) throws -> OpaquePointer {
            var statement: OpaquePointer?
            let flags = UInt32(SQLITE_PREPARE_NO_VTAB | SQLITE_PREPARE_DONT_LOG)
            guard sqlite3_prepare_v3(
                database, sql, -1, flags, &statement, nil
            ) == SQLITE_OK, let statement else {
                throw Failure.reconstructionRejected
            }
            return statement
        }

        private static func scalarInteger(
            _ database: OpaquePointer?,
            _ sql: String
        ) throws -> Int64 {
            let statement = try prepare(database, sql)
            defer { sqlite3_finalize(statement) }
            guard sqlite3_step(statement) == SQLITE_ROW,
                  sqlite3_column_type(statement, 0) == SQLITE_INTEGER else {
                throw Failure.sqlitePolicyRejected
            }
            let value = sqlite3_column_int64(statement, 0)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw Failure.sqlitePolicyRejected
            }
            return value
        }

        private static func scalarText(
            _ database: OpaquePointer?,
            _ sql: String
        ) throws -> String {
            let statement = try prepare(database, sql)
            defer { sqlite3_finalize(statement) }
            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw Failure.sqlitePolicyRejected
            }
            let value = try text(statement, column: 0, maximum: 128)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw Failure.sqlitePolicyRejected
            }
            return value
        }

        private static func text(
            _ statement: OpaquePointer,
            column: Int32,
            maximum: Int
        ) throws -> String {
            guard sqlite3_column_type(statement, column) == SQLITE_TEXT else {
                throw Failure.reconstructionRejected
            }
            let count = Int(sqlite3_column_bytes(statement, column))
            guard count > 0, count <= maximum,
                  let pointer = sqlite3_column_text(statement, column),
                  let value = String(
                    data: Data(bytes: pointer, count: count), encoding: .utf8
                  ), !value.utf8.contains(0) else {
                throw Failure.reconstructionRejected
            }
            return value
        }

        private static var transient: sqlite3_destructor_type {
            unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        }

        private static func bind(
            _ value: String,
            index: Int32,
            statement: OpaquePointer
        ) throws {
            let bytes = Data(value.utf8)
            guard !bytes.isEmpty, bytes.count <= 128 else {
                throw Failure.transactionRejected
            }
            try bytes.withUnsafeBytes { pointer in
                try checked(sqlite3_bind_text(
                    statement, index,
                    pointer.baseAddress?.assumingMemoryBound(to: CChar.self),
                    Int32(pointer.count), transient
                ))
            }
        }

        private static func bind(
            _ value: Data,
            index: Int32,
            statement: OpaquePointer
        ) throws {
            guard !value.isEmpty, value.count <= H4C.maximumStreamBytes else {
                throw Failure.transactionRejected
            }
            try value.withUnsafeBytes { pointer in
                try checked(sqlite3_bind_blob(
                    statement, index, pointer.baseAddress,
                    Int32(pointer.count), transient
                ))
            }
        }

        private static func checked(_ status: Int32) throws {
            guard status == SQLITE_OK else { throw Failure.sqlitePolicyRejected }
        }

        private static func closeExact(
            _ database: inout OpaquePointer?
        ) -> Bool {
            guard let value = database else { return true }
            guard sqlite3_next_stmt(value, nil) == nil else {
                var statement = sqlite3_next_stmt(value, nil)
                while let current = statement {
                    statement = sqlite3_next_stmt(value, current)
                    _ = sqlite3_finalize(current)
                }
                _ = sqlite3_close(value)
                database = nil
                return false
            }
            let status = sqlite3_close(value)
            if status == SQLITE_OK {
                database = nil
                return true
            }
            _ = sqlite3_close_v2(value)
            database = nil
            return false
        }

        private static func closeDescriptorOnce(
            _ descriptor: inout Int32
        ) -> Bool {
            guard descriptor >= 0 else { return true }
            let value = descriptor
            descriptor = -1
            return Darwin.close(value) == 0
        }

        private static func exact(_ left: String, _ right: String) -> Bool {
            left.utf8.elementsEqual(right.utf8)
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate static func inspect(rootURL: URL) throws -> TestStoreSnapshot {
            let descriptor = Darwin.open(
                rootURL.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard descriptor >= 0 else { throw Failure.storeAdmissionRejected }
            defer { _ = Darwin.close(descriptor) }
            var root = stat()
            guard fstat(descriptor, &root) == 0 else {
                throw Failure.storeAdmissionRejected
            }
            try validatePrivateDirectory(root)
            let entries = try directoryEntries(descriptor).sorted()
            guard entries.contains(finalLeaf) else {
                return TestStoreSnapshot(
                    inventory: entries,
                    published: false,
                    fileMode: nil,
                    fileSize: nil,
                    headerExact: false,
                    userVersion: 0,
                    applicationID: 0,
                    schemaEntryCount: 0,
                    rowCount: 0
                )
            }
            var final = epr_h4d2b_open_final(descriptor)
            guard final >= 0 else { throw Failure.finalOpenRejected }
            defer { _ = closeDescriptorOnce(&final) }
            var metadata = stat()
            guard fstat(final, &metadata) == 0,
                  metadata.st_size > 0,
                  metadata.st_size <= off_t(maximumDatabasePages * pageSize),
                  let count = Int(exactly: metadata.st_size) else {
                throw Failure.identityRejected
            }
            let bytes = try readExact(descriptor: final, count: count)
            let headerExact = (try? validateImage(bytes)) != nil
            var database: OpaquePointer?
            do {
                database = try openMemory(readOnly: true)
                guard let allocation = sqlite3_malloc64(UInt64(bytes.count)) else {
                    throw Failure.reconstructionRejected
                }
                bytes.copyBytes(
                    to: allocation.assumingMemoryBound(to: UInt8.self),
                    count: bytes.count
                )
                guard epr_sqlite_deserialize_readonly(
                    UnsafeMutableRawPointer(database),
                    allocation.assumingMemoryBound(to: UInt8.self),
                    Int64(bytes.count)
                ) == SQLITE_OK else {
                    throw Failure.reconstructionRejected
                }
                try configureReader(database)
                let version = try scalarInteger(database, "PRAGMA user_version")
                let identifier = try scalarInteger(database, "PRAGMA application_id")
                let schemaCount = try scalarInteger(
                    database, "SELECT count(*) FROM sqlite_schema"
                )
                let tableCount = try scalarInteger(
                    database,
                    "SELECT count(*) FROM sqlite_schema WHERE name='h4_receipts'"
                )
                let rows = tableCount == 1
                    ? try scalarInteger(
                        database, "SELECT count(*) FROM h4_receipts"
                    ) : 0
                guard closeExact(&database) else { throw Failure.closeRejected }
                return TestStoreSnapshot(
                    inventory: entries,
                    published: true,
                    fileMode: UInt16(metadata.st_mode & 0o7777),
                    fileSize: Int64(metadata.st_size),
                    headerExact: headerExact,
                    userVersion: version,
                    applicationID: identifier,
                    schemaEntryCount: schemaCount,
                    rowCount: rows
                )
            } catch {
                _ = closeExact(&database)
                throw error
            }
        }
        #endif
    }
}

import Darwin
import Foundation
import SQLite3
#if EPR_H4_PRIVACY_TESTS
import CryptoKit
#endif

/// H4-D3's bounded whole-image engine. Historical fixture issuance remains
/// separate from the native-owner live Save and inert selected-file reader.
enum HypervisorStageH4DualStreamPersistence {
    typealias H4C = HypervisorStageH4CanonicalStreams
    typealias H4D = HypervisorStageH4OwnerBinding
    typealias Coordinator = H4D.DualStreamPersistenceCoordinator

    static let schema =
        "com.ergentics.provenance.hypervisor.h4.dual-stream-sqlite-image-publication.v3"
    static let applicationID: Int64 = 1_162_891_828
    static let userVersion: Int64 = 2
    static let pageSize: Int64 = 4_096
    static let maximumDatabasePages: Int64 = 64
    static let stagingLeafName = ".h4d3-dual-receipt.sqlite.staging"
    static let finalLeafName = "h4d3-dual-receipt.sqlite"
    #if EPR_H4_PRIVACY_TESTS
    static let faultDisplacedLeafName = ".h4d3-fault-displaced"
    #endif

    enum Failure: Error, Equatable, Sendable {
        case inProgress, alreadyConsumed, persistenceRequiresInspection
        case expired, poisoned, storeAdmissionRejected
        case sqlitePolicyRejected, transactionRejected, commitOutcomeUnknown
        case serializationRejected, closeRejected, reconstructionRejected
        case stagingCreationRejected, writeRejected
        case modeSealRejected, syncRejected, readbackRejected
        case publicationRejected, directorySyncRejected, finalOpenRejected
        case identityRejected, leaseCompletionRejected
    }

    struct ReopenReceipt: Equatable, Sendable, CustomReflectable {
        fileprivate init() {}
        var schema: String { HypervisorStageH4DualStreamPersistence.schema }
        var rowCount: UInt8 { 1 }
        var sqliteImageExact: Bool { true }
        var canonicalJSONRetainedExact: Bool { true }
        var canonicalCBORRetainedExact: Bool { true }
        var indexedFieldsExact: Bool { true }
        var writerThreeWayJoinExact: Bool { true }
        var restartAdopted: Bool { false }
        var h4Entered: Bool { false }
        var authorityVector: String { "00000000" }
        var customMirror: Mirror {
            Mirror(self, children: EmptyCollection<(label: String?, value: Any)>(),
                   displayStyle: .struct)
        }
    }

    /// File-created mint authority. Store construction is inaccessible and the
    /// single mint is delayed until OwnerBinding has completed both leases.
    final class ReceiptMint: @unchecked Sendable {
        private let lock = NSLock()
        private var available = true
        fileprivate init() {}

        func mint() -> ReopenReceipt? {
            lock.lock(); defer { lock.unlock() }
            guard available else { return nil }
            available = false
            return ReopenReceipt()
        }
    }

    struct ReopenedDualStreamRowInput: Sendable {
        let canonicalJSON: Data
        let canonicalCBOR: Data
        let semanticSchema: String
        let claimState: String
        let predicateCount: Int64
        let authorityVector: String

        fileprivate init(canonicalJSON: Data, canonicalCBOR: Data,
                         semanticSchema: String, claimState: String,
                         predicateCount: Int64, authorityVector: String) {
            self.canonicalJSON = canonicalJSON
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

    enum StoreResult {
        case admitted(ReceiptMint)
        case rejectedBeforePublication(Failure)
        case transactionOutcomeUnknown(Failure)
        case prepublicationStateUnknown(Failure)
        case stagingRetained(Failure)
        case publicationOutcomeUnknown(Failure)
        case publishedUnverified(Failure)
    }

    #if EPR_H4_PRIVACY_TESTS
    enum TestPublicationInterstice: UInt8, CaseIterable, Sendable {
        case beforeStagingCreate = 0
        case afterStagingCreate = 1
        case afterCompleteImagePwrite = 2
        case afterModeSealAndFstat = 3
        case afterStagingFSync = 4
        case afterStagingFullSync = 5
        case afterStagingReadbackAndVnodeJoin = 6
        case afterPublicationRename = 7
        case afterDirectoryFSync = 8
        case afterFinalVerificationBeforeStoreReceipt = 9
    }

    typealias TestPublicationIntersticeCallback =
        @Sendable (TestPublicationInterstice) throws -> Void

    enum TestFault: Equatable, Sendable {
        case none, beforeBegin, afterBegin, afterSchema, afterInsert
        case commitResponseLost, serializeRejected, serializedOversize
        case serializedMisaligned, serializedBadHeader
        case serializedWrongWriteVersion, serializedWrongReadVersion
        case serializedWrongPageSize, serializedWrongPageCount
        case writerStatementLeak
        case prepublicationDeserializeRejected
        case prepublicationReaderPolicyRejected, prepublicationSchemaRejected
        case prepublicationJSONRejected, prepublicationCBORRejected
        case prepublicationScalarRejected, prepublicationStatementLeak
        case afterStagingCreation
        case pwriteRejected, pwriteZero, pwriteShort, pwriteOverrun
        case modeSealRejected, stagingStatRejected
        case fsyncRejected, fullSyncRejected, stagingReadbackMismatch
        case stagingUnlinked, stagingRebound, stagingHardlinked
        case renameCollision, renameResponseLost, directorySyncRejected
        case finalOpenRejected, finalReboundBeforeOpen, finalFIFOBeforeOpen
        case finalReadbackMismatch, finalDeserializeRejected
        case finalReaderPolicyRejected, finalSchemaRejected
        case finalJSONRejected, finalCBORRejected, finalScalarRejected
        case finalStatementLeak, finalDescriptorCloseResponseLost
        case finalReboundAfterRead, finalReboundBeforeSuccess
        case finalSameBytesNewInodeBeforeSuccess
        case parentReboundBeforeStaging, parentReboundAfterStaging
        case parentReboundAfterRename, parentReboundBeforeSuccess
        case prepublicationJSONCorrupt, prepublicationJSONNoncanonical
        case prepublicationJSONAlias, prepublicationJSONUnknownField
        case prepublicationJSONTrailing
        case prepublicationCBORCorrupt, prepublicationCBORNoncanonical
        case prepublicationCBORAlias, prepublicationCBORUnknownField
        case prepublicationCBORTrailing
        case prepublicationScalarMismatch, prepublicationScalarWrongStorage
        case prepublicationThreeFieldSubstitution
        case finalJSONCorrupt, finalJSONNoncanonical, finalJSONAlias
        case finalJSONUnknownField, finalJSONTrailing
        case finalCBORCorrupt, finalCBORNoncanonical, finalCBORAlias
        case finalCBORUnknownField, finalCBORTrailing
        case finalScalarMismatch, finalScalarWrongStorage
        case finalThreeFieldSubstitution
        case prepublicationV2Schema, prepublicationWrongUserVersion
        case prepublicationWrongApplicationID, prepublicationExtraSchemaObject
        case prepublicationExtraColumn, prepublicationExtraRow
        case finalV2Schema, finalWrongUserVersion, finalWrongApplicationID
        case finalExtraSchemaObject, finalExtraColumn, finalExtraRow
        case prepublicationAuthorizerRejected, prepublicationQueryOnlyRejected
        case prepublicationFilenameRejected, prepublicationIntegrityRejected
        case finalAuthorizerRejected, finalQueryOnlyRejected
        case finalFilenameRejected, finalIntegrityRejected
        case stagingSymlinkAfterSnapshot, stagingFIFOAfterSnapshot
        case stagingNonregularAfterSnapshot, stagingSameBytesNewInode
        case finalSymlinkBeforeOpen, finalNonregularBeforeOpen
        case finalSameBytesNewInodeBeforeOpen, finalSameBytesNewInodeAfterRead
        case stagingExactLengthMismatch, stagingEOFMismatch
        case finalExactLengthMismatch, finalEOFMismatch
    }

    struct TestEnteredCallSnapshot: Equatable, Sendable {
        let commit: UInt32
        let stagingCreate: UInt32
        let pwrite: UInt32
        let rename: UInt32
        let finalOpen: UInt32
    }

    enum TestReplacementKind: Equatable, Sendable {
        case symlink, fifo, directory, regular
    }

    struct TestReadObservation: Equatable, Sendable {
        let requestedCount: Int
        let firstPreadReturn: Int
        let fstatReturn: Int32
        let observedSize: Int64
        let eofPreadReturn: Int
        let bytesEqualExpected: Bool
    }

    enum TestPrimitiveKind: Equatable, Sendable {
        case publicationSerialize
        case completeImagePwrite
        case modeSeal
        case stagingFSync
        case stagingFullSync
        case publicationRename
        case directoryFSync
        case finalOpen
        case prepublicationDeserialize
        case finalDeserialize
        case finalDescriptorClose
    }

    enum TestPrimitiveOrigin: Equatable, Sendable {
        case backend
        case injected
        case responseLost
    }

    struct TestPrimitiveEvent: Equatable, Sendable {
        let kind: TestPrimitiveKind
        let boundarySequence: UInt32
        let backendInvoked: Bool
        let backendReturn: Int64?
        let effectiveReturn: Int64
        let error: Int32?
        let origin: TestPrimitiveOrigin
        let requestedCount: Int?
    }

    struct TestReaderPolicyObservation: Equatable, Sendable {
        let queryOnly: Bool
        let defensive: Bool
        let trustedSchema: Bool
        let dqsDDL: Bool
        let dqsDML: Bool
        let tempStoreMemory: Bool
        let foreignKeys: Bool
        let autocommit: Bool
        let transactionNone: Bool
        let filenameEmpty: Bool
    }

    struct TestEvidenceSnapshot: Equatable, Sendable {
        let mutationActuated: Bool
        let validatorEnteredAfterMutation: Bool
        let prepublicationReaderEntered: Bool
        let finalReaderEntered: Bool
        let replacementKind: TestReplacementKind?
        let originalDevice: UInt64?
        let originalInode: UInt64?
        let replacementDevice: UInt64?
        let replacementInode: UInt64?
        let replacementBytesEqual: Bool?
        let stagingRead: TestReadObservation?
        let finalRead: TestReadObservation?
        let containedStatementCount: UInt32
        let renameCollisionActuated: Bool
        let renameCollisionReturn: Int32?
        let renameCollisionErrno: Int32?
        let v2SchemaActuated: Bool
        let prepublicationPolicy: TestReaderPolicyObservation?
        let finalPolicy: TestReaderPolicyObservation?
        let primitiveEvents: [TestPrimitiveEvent]
    }

    final class TestEnteredCalls: @unchecked Sendable {
        private let lock = NSLock()
        private var value = TestEnteredCallSnapshot(
            commit: 0, stagingCreate: 0, pwrite: 0, rename: 0, finalOpen: 0
        )
        private var mutationActuated = false
        private var validatorEnteredAfterMutation = false
        private var prepublicationReaderEntered = false
        private var finalReaderEntered = false
        private var replacementKind: TestReplacementKind?
        private var originalDevice: UInt64?
        private var originalInode: UInt64?
        private var replacementDevice: UInt64?
        private var replacementInode: UInt64?
        private var replacementBytesEqual: Bool?
        private var stagingRead: TestReadObservation?
        private var finalRead: TestReadObservation?
        private var containedStatementCount: UInt32 = 0
        private var renameCollisionActuated = false
        private var renameCollisionReturn: Int32?
        private var renameCollisionErrno: Int32?
        private var v2SchemaActuated = false
        private var prepublicationPolicy: TestReaderPolicyObservation?
        private var finalPolicy: TestReaderPolicyObservation?
        private var primitiveEvents: [TestPrimitiveEvent] = []
        func snapshot() -> TestEnteredCallSnapshot {
            lock.lock(); defer { lock.unlock() }; return value
        }
        func evidenceSnapshot() -> TestEvidenceSnapshot {
            lock.lock(); defer { lock.unlock() }
            return .init(
                mutationActuated: mutationActuated,
                validatorEnteredAfterMutation: validatorEnteredAfterMutation,
                prepublicationReaderEntered: prepublicationReaderEntered,
                finalReaderEntered: finalReaderEntered,
                replacementKind: replacementKind,
                originalDevice: originalDevice,
                originalInode: originalInode,
                replacementDevice: replacementDevice,
                replacementInode: replacementInode,
                replacementBytesEqual: replacementBytesEqual,
                stagingRead: stagingRead,
                finalRead: finalRead,
                containedStatementCount: containedStatementCount,
                renameCollisionActuated: renameCollisionActuated,
                renameCollisionReturn: renameCollisionReturn,
                renameCollisionErrno: renameCollisionErrno,
                v2SchemaActuated: v2SchemaActuated,
                prepublicationPolicy: prepublicationPolicy,
                finalPolicy: finalPolicy,
                primitiveEvents: primitiveEvents)
        }
        fileprivate func recordPrivateMutation() {
            lock.lock(); defer { lock.unlock() }
            mutationActuated = true
        }
        fileprivate func recordReader(final: Bool) {
            lock.lock(); defer { lock.unlock() }
            prepublicationReaderEntered = prepublicationReaderEntered || !final
            finalReaderEntered = finalReaderEntered || final
        }
        fileprivate func recordValidatorEntry() {
            lock.lock(); defer { lock.unlock() }
            validatorEnteredAfterMutation =
                validatorEnteredAfterMutation || mutationActuated
        }
        fileprivate func recordRead(final: Bool, _ observation: TestReadObservation) {
            lock.lock(); defer { lock.unlock() }
            if final { finalRead = observation } else { stagingRead = observation }
        }
        fileprivate func recordContainedStatements(_ count: UInt32) {
            lock.lock(); defer { lock.unlock() }
            containedStatementCount &+= count
        }
        fileprivate func recordRenameCollision(result: Int32, error: Int32) {
            lock.lock(); defer { lock.unlock() }
            renameCollisionActuated = true
            renameCollisionReturn = result
            renameCollisionErrno = error
        }
        fileprivate func recordV2SchemaActuation() {
            lock.lock(); defer { lock.unlock() }
            v2SchemaActuated = true
        }
        fileprivate func recordPolicy(
            final: Bool,
            _ observation: TestReaderPolicyObservation
        ) {
            lock.lock(); defer { lock.unlock() }
            if final { finalPolicy = observation }
            else { prepublicationPolicy = observation }
        }
        fileprivate func recordPrimitive(
            kind: TestPrimitiveKind,
            backendInvoked: Bool,
            backendReturn: Int64?,
            effectiveReturn: Int64,
            error: Int32?,
            origin: TestPrimitiveOrigin,
            requestedCount: Int? = nil
        ) {
            lock.lock(); defer { lock.unlock() }
            primitiveEvents.append(.init(
                kind: kind,
                boundarySequence: UInt32(primitiveEvents.count + 1),
                backendInvoked: backendInvoked,
                backendReturn: backendReturn,
                effectiveReturn: effectiveReturn,
                error: error,
                origin: origin,
                requestedCount: requestedCount))
        }
        fileprivate func recordReplacement(_ kind: TestReplacementKind,
            original: stat, replacement: stat, bytesEqual: Bool?) {
            lock.lock(); defer { lock.unlock() }
            mutationActuated = true
            replacementKind = kind
            originalDevice = UInt64(original.st_dev)
            originalInode = UInt64(original.st_ino)
            replacementDevice = UInt64(replacement.st_dev)
            replacementInode = UInt64(replacement.st_ino)
            replacementBytesEqual = bytesEqual
        }
        fileprivate func enter(_ key: Key) {
            lock.lock(); defer { lock.unlock() }
            switch key {
            case .commit: value = .init(commit: value.commit + 1,
                stagingCreate: value.stagingCreate, pwrite: value.pwrite,
                rename: value.rename, finalOpen: value.finalOpen)
            case .stagingCreate: value = .init(commit: value.commit,
                stagingCreate: value.stagingCreate + 1, pwrite: value.pwrite,
                rename: value.rename, finalOpen: value.finalOpen)
            case .pwrite: value = .init(commit: value.commit,
                stagingCreate: value.stagingCreate, pwrite: value.pwrite + 1,
                rename: value.rename, finalOpen: value.finalOpen)
            case .rename: value = .init(commit: value.commit,
                stagingCreate: value.stagingCreate, pwrite: value.pwrite,
                rename: value.rename + 1, finalOpen: value.finalOpen)
            case .finalOpen: value = .init(commit: value.commit,
                stagingCreate: value.stagingCreate, pwrite: value.pwrite,
                rename: value.rename, finalOpen: value.finalOpen + 1)
            }
        }
        fileprivate enum Key { case commit, stagingCreate, pwrite, rename, finalOpen }
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
        let singleton: Int64
        let semanticSchema: String
        let claimState: String
        let predicateCount: Int64
        let authorityVector: String
        let canonicalJSON: Data
        let canonicalCBOR: Data
        let storageClasses: [Int32]
        let queryOnly: Bool
        let defensive: Bool
        let trustedSchema: Bool
        let dqsDDL: Bool
        let dqsDML: Bool
        let tempStoreMemory: Bool
        let foreignKeys: Bool
        let autocommit: Bool
        let transactionNone: Bool
        let filenameEmpty: Bool
    }

    enum TestRetainedStateClass: String, Equatable, Sendable {
        case emptyBeforePublication = "EMPTY_BEFORE_PUBLICATION"
        case stagingOnlyEmpty0600 = "STAGING_ONLY_EMPTY_0600"
        case stagingOnlyValidV30600 = "STAGING_ONLY_VALID_V3_0600"
        case stagingOnlyValidV30400 = "STAGING_ONLY_VALID_V3_0400"
        case finalOnlyValidV3 = "FINAL_ONLY_VALID_V3"
        case finalOnlyRejected = "FINAL_ONLY_REJECTED"
        case ambiguousOrUnexpected = "AMBIGUOUS_OR_UNEXPECTED"
    }

    struct TestRetainedStateMetadata: Equatable, Sendable {
        let device: UInt64
        let inode: UInt64
        let mode: UInt32
        let userID: UInt32
        let groupID: UInt32
        let linkCount: UInt64
        let size: Int64
        let flags: UInt32
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let statusChangeSeconds: Int64
        let statusChangeNanoseconds: Int64

        fileprivate init(_ value: stat) {
            device = UInt64(value.st_dev)
            inode = UInt64(value.st_ino)
            mode = UInt32(value.st_mode)
            userID = value.st_uid
            groupID = value.st_gid
            linkCount = UInt64(value.st_nlink)
            size = Int64(value.st_size)
            flags = value.st_flags
            modificationSeconds = Int64(value.st_mtimespec.tv_sec)
            modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
            statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
            statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        }
    }

    struct TestRetainedStatePredicates: Equatable, Sendable {
        let rootMetadataExact: Bool
        let rootJoinExact: Bool
        let inventoryExact: Bool
        let leafMetadataExact: Bool
        let headerExact: Bool
        let pageGeometryExact: Bool
        let imageReadExact: Bool
        let eofExact: Bool
        let vnodeJoinExact: Bool
        let sqlitePolicyExact: Bool
        let integrityExact: Bool
        let schemaExact: Bool
        let rowExact: Bool
        let canonicalJSONExact: Bool
        let canonicalCBORExact: Bool
        let indexedScalarsExact: Bool
        let representationJoinExact: Bool
        let closesExact: Bool
    }

    struct TestRetainedStateEvidence: Equatable, Sendable {
        let classification: TestRetainedStateClass
        let inventory: [String]
        let rootMetadata: TestRetainedStateMetadata?
        let leafMetadata: TestRetainedStateMetadata?
        let byteCount: Int
        let sha256: String?
        let databaseReadOnlyDiagnostic: Int32?
        let predicates: TestRetainedStatePredicates
    }

    enum TestRetainedStateFault: Equatable, Sendable {
        case none
        case rootOpenRejected, rootLockRejected, directoryScanRejected
        case inventoryCloseResponseLost
        case leafOpenRejected
        case headerReadInterruptedOnce, headerReadShortOnce
        case headerReadZero, headerReadRejected
        case imageReadInterruptedOnce, imageReadShortOnce
        case imageReadZero, imageReadRejected
        case eofReadInterruptedOnce, eofReadNonzero
        case imageAllocationRejected
        case sqliteOpenRejected, sqliteAllocationRejected, deserializeRejected
        case readerHardeningRejected, queryOnlyRejected, filenameRejected
        case integrityRejected, schemaRejected, authorizerRejected, rowRejected
        case jsonRejected, cborRejected, scalarRejected
        case statementLeak, databaseCloseResponseLost
        case leafCloseResponseLost, rootCloseResponseLost
    }

    struct TestRetainedStateHooks {
        let afterNamedRootBeforeOpen: (() throws -> Void)?
        let afterInitialInventory: (() throws -> Void)?
        let afterNamedLeafBeforeOpen: (() throws -> Void)?
        let afterHeaderReadBeforeMetadataJoin: (() throws -> Void)?
        let afterImageReadBeforeMetadataJoin: (() throws -> Void)?
        let afterSQLiteCloseBeforeFinalJoin: (() throws -> Void)?
        let afterPrecloseLeafJoin: (() throws -> Void)?
        let afterLeafCloseBeforeNamedJoin: (() throws -> Void)?
        let afterPostcloseNamedJoinBeforeTerminal: (() throws -> Void)?

        init(
            afterNamedRootBeforeOpen: (() throws -> Void)? = nil,
            afterInitialInventory: (() throws -> Void)? = nil,
            afterNamedLeafBeforeOpen: (() throws -> Void)? = nil,
            afterHeaderReadBeforeMetadataJoin: (() throws -> Void)? = nil,
            afterImageReadBeforeMetadataJoin: (() throws -> Void)? = nil,
            afterSQLiteCloseBeforeFinalJoin: (() throws -> Void)? = nil,
            afterPrecloseLeafJoin: (() throws -> Void)? = nil,
            afterLeafCloseBeforeNamedJoin: (() throws -> Void)? = nil,
            afterPostcloseNamedJoinBeforeTerminal: (() throws -> Void)? = nil
        ) {
            self.afterNamedRootBeforeOpen = afterNamedRootBeforeOpen
            self.afterInitialInventory = afterInitialInventory
            self.afterNamedLeafBeforeOpen = afterNamedLeafBeforeOpen
            self.afterHeaderReadBeforeMetadataJoin =
                afterHeaderReadBeforeMetadataJoin
            self.afterImageReadBeforeMetadataJoin =
                afterImageReadBeforeMetadataJoin
            self.afterSQLiteCloseBeforeFinalJoin =
                afterSQLiteCloseBeforeFinalJoin
            self.afterPrecloseLeafJoin = afterPrecloseLeafJoin
            self.afterLeafCloseBeforeNamedJoin =
                afterLeafCloseBeforeNamedJoin
            self.afterPostcloseNamedJoinBeforeTerminal =
                afterPostcloseNamedJoinBeforeTerminal
        }
    }
    #endif

    fileprivate enum Fault: Sendable {
        case none
        #if EPR_H4_PRIVACY_TESTS
        case injected(TestFault)
        init(_ value: TestFault) { self = value == .none ? .none : .injected(value) }
        #endif
    }

    /// Closed representation variants share the publication engine, not
    /// issuance authority. The historical fixture format stays byte-exact.
    private enum Payload {
        case fixture(H4C.Projection)
        #if EPR_H4_LIVE
        case live(GuestH3LivePersistence.Projection)
        case h8(GuestH8Provenance.Projection)
        #endif
        var json: Data { switch self {
            case .fixture(let p): p.json
            #if EPR_H4_LIVE
            case .live(let p): p.json
            case .h8(let p): p.json
            #endif
        } }
        var cbor: Data { switch self {
            case .fixture(let p): p.cbor
            #if EPR_H4_LIVE
            case .live(let p): p.cbor
            case .h8(let p): p.cbor
            #endif
        } }
        var semanticSchema: String { switch self {
            case .fixture(let p): p.reconstruction.semantic.schema
            #if EPR_H4_LIVE
            case .live: GuestH3LivePersistence.schema
            case .h8: GuestH8Provenance.schema
            #endif
        } }
        var claimState: String { switch self {
            case .fixture(let p): p.reconstruction.semantic.claimState.rawValue
            #if EPR_H4_LIVE
            case .live: "OBSERVED_NATIVE_PASS"
            case .h8: "RECORDED_H7_NATIVE_PASS"
            #endif
        } }
        var predicateCount: Int64 { switch self {
            case .fixture(let p): Int64(p.reconstruction.semantic.predicateCount)
            #if EPR_H4_LIVE
            case .live: 9
            case .h8: 9
            #endif
        } }
        var maximumBytes: Int { switch self {
            case .fixture: H4C.maximumStreamBytes
            #if EPR_H4_LIVE
            case .live: GuestH3LivePersistence.maximumStreamBytes
            case .h8: GuestH8Provenance.maximumStreamBytes
            #endif
        } }
        var tableSQL: String { switch self {
            case .fixture: Store.tableSQL
            #if EPR_H4_LIVE
            case .live: Store.liveTableSQL
            case .h8: Store.h8TableSQL
            #endif
        } }
    }

    /// Held ancestry for the fixed live namespace. It is not serialized and
    /// cannot be supplied by UI, imported evidence, or a decoded receipt.
    #if EPR_H4_LIVE
    fileprivate enum LiveNamespace: String { case h4 = "H4LiveReceipts-v1", h8 = "H8Provenance-v1" }
    fileprivate final class LiveAncestry {
        let namespace: LiveNamespace
        let basePath: String
        let base: Int32
        let parent: Int32
        let baseIdentity: stat
        let parentIdentity: stat
        init(basePath: String, base: Int32, parent: Int32, baseIdentity: stat, parentIdentity: stat, namespace: LiveNamespace) {
            self.namespace = namespace
            self.basePath = basePath; self.base = base; self.parent = parent
            self.baseIdentity = baseIdentity; self.parentIdentity = parentIdentity
        }
        deinit { _ = Darwin.close(parent); _ = Darwin.close(base) }
        func validate() throws {
            var namedBase = stat(), heldBase = stat(), namedParent = stat(), heldParent = stat()
            func same(_ a: stat, _ b: stat) -> Bool {
                a.st_dev == b.st_dev && a.st_ino == b.st_ino && a.st_mode == b.st_mode &&
                a.st_uid == b.st_uid && a.st_gid == b.st_gid && a.st_flags == b.st_flags
            }
            guard lstat(basePath, &namedBase) == 0, fstat(base, &heldBase) == 0,
                  namespace.rawValue.withCString({ fstatat(base, $0, &namedParent, AT_SYMLINK_NOFOLLOW) }) == 0,
                  fstat(parent, &heldParent) == 0,
                  same(namedBase, heldBase), same(heldBase, baseIdentity),
                  same(namedParent, heldParent), same(heldParent, parentIdentity),
                  Store.validRoot(heldParent) else { throw Failure.storeAdmissionRejected }
        }
    }

    #endif

    /// Root ownership is descriptor based. Product minting is restricted to
    /// a fresh UUID child of the fixed live namespace after an explicit Save.
    fileprivate final class RootCapability: @unchecked Sendable {
        let path: String
        var descriptor: Int32
        #if EPR_H4_LIVE
        var ancestry: LiveAncestry?
        #endif
        private init(path: String, descriptor: Int32) {
            self.path = path; self.descriptor = descriptor
        }
        deinit { if descriptor >= 0 { _ = Darwin.close(descriptor) } }

        static func admit(_ rootURL: URL, acquireLease: Bool = true) throws -> RootCapability {
            let path = rootURL.path
            guard rootURL.isFileURL, rootURL.hasDirectoryPath,
                  path.hasPrefix("/"), !path.utf8.contains(0),
                  !path.contains("//"),
                  !path.split(separator: "/").contains(where: {
                      $0 == "." || $0 == ".."
                  }), let resolved = realpath(path, nil) else {
                throw Failure.storeAdmissionRejected
            }
            let physical = String(validatingCString: resolved)
            free(resolved)
            guard physical == path else { throw Failure.storeAdmissionRejected }
            var named = stat()
            guard lstat(path, &named) == 0 else {
                throw Failure.storeAdmissionRejected
            }
            let fd = Darwin.open(path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            guard fd >= 0,
                  (!acquireLease || flock(fd, LOCK_EX | LOCK_NB) == 0) else {
                if fd >= 0 { _ = Darwin.close(fd) }
                throw Failure.storeAdmissionRejected
            }
            var held = stat()
            guard fstat(fd, &held) == 0, Store.sameRoot(named, held),
                  Store.validRoot(held) else {
                _ = Darwin.close(fd)
                throw Failure.storeAdmissionRejected
            }
            return RootCapability(path: path, descriptor: fd)
        }
        #if EPR_H4_LIVE
        static func createLive(leaf: String, namespace: LiveNamespace = .h4) throws -> RootCapability {
            let applicationSupport = try FileManager.default.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: nil, create: false)
            return try createLive(leaf: leaf, applicationSupport: applicationSupport, namespace: namespace)
        }

        static func createLive(leaf: String, applicationSupport: URL, namespace: LiveNamespace = .h4) throws -> RootCapability {
            guard let uuid = UUID(uuidString: leaf), uuid.uuidString.lowercased() == leaf else {
                throw Failure.storeAdmissionRejected
            }
            guard let resolved = realpath(applicationSupport.path, nil) else { throw Failure.storeAdmissionRejected }
            let physical = String(cString: resolved); free(resolved)
            let base = Darwin.open(physical, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            guard base >= 0 else { throw Failure.storeAdmissionRejected }
            var parent: Int32 = -1
            var transferred = false
            defer { if !transferred { if parent >= 0 { _ = Darwin.close(parent) }; _ = Darwin.close(base) } }
            var baseStat = stat(), namedBase = stat()
            guard fstat(base, &baseStat) == 0, lstat(physical, &namedBase) == 0,
                  Store.sameRoot(baseStat, namedBase), baseStat.st_mode & S_IFMT == S_IFDIR,
                  baseStat.st_uid == geteuid(), baseStat.st_mode & 0o022 == 0 else {
                throw Failure.storeAdmissionRejected
            }
            let made = namespace.rawValue.withCString { mkdirat(base, $0, 0o700) }
            guard made == 0 || errno == EEXIST else { throw Failure.storeAdmissionRejected }
            parent = namespace.rawValue.withCString {
                openat(base, $0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            }
            var parentStat = stat(), namedParent = stat()
            guard parent >= 0, fstat(parent, &parentStat) == 0,
                  namespace.rawValue.withCString({ fstatat(base, $0, &namedParent, AT_SYMLINK_NOFOLLOW) }) == 0,
                  Store.validRoot(parentStat), Store.sameRoot(parentStat, namedParent),
                  leaf.withCString({ mkdirat(parent, $0, 0o700) }) == 0 else {
                throw Failure.storeAdmissionRejected
            }
            // All partial state is retained on every failure; never adopt a
            // colliding run directory or clean an earlier receipt.
            let rootPath = physical + "/" + namespace.rawValue + "/" + leaf
            let root = try admit(URL(fileURLWithPath: rootPath, isDirectory: true))
            guard fstat(base, &baseStat) == 0, fstat(parent, &parentStat) == 0,
                  fsync(root.descriptor) == 0, fsync(parent) == 0, fsync(base) == 0 else {
                throw Failure.directorySyncRejected
            }
            root.ancestry = LiveAncestry(basePath: physical, base: base, parent: parent,
                baseIdentity: baseStat, parentIdentity: parentStat, namespace: namespace)
            transferred = true
            try root.ancestry?.validate()
            return root
        }
        #endif
    }

    final class Store: @unchecked Sendable {
        private let operationLock = NSLock()
        private let root: RootCapability
        private let fault: Fault
        #if EPR_H4_PRIVACY_TESTS
        private let calls: TestEnteredCalls
        private let publicationInterstice: TestPublicationIntersticeCallback?
        #endif

        fileprivate init(root: RootCapability, fault: Fault) throws {
            self.root = root; self.fault = fault
            #if EPR_H4_PRIVACY_TESTS
            calls = TestEnteredCalls()
            publicationInterstice = nil
            #endif
            try validateRoot(expected: [])
        }

        #if EPR_H4_PRIVACY_TESTS
        fileprivate init(root: RootCapability, fault: Fault,
                     calls: TestEnteredCalls,
                     publicationInterstice: TestPublicationIntersticeCallback?) throws {
            self.root = root
            self.fault = fault
            self.calls = calls
            self.publicationInterstice = publicationInterstice
            try validateRoot(expected: [])
        }
        #endif

        func append(_ canonical: H4C.Projection,
                    remainsLive: () -> Bool) -> StoreResult {
            operationLock.lock(); defer { operationLock.unlock() }
            return appendLocked(.fixture(canonical), remainsLive: remainsLive)
        }

        #if EPR_H4_LIVE
        fileprivate func appendLive(_ canonical: GuestH3LivePersistence.Projection,
                                   remainsLive: () -> Bool) -> StoreResult {
            operationLock.lock(); defer { operationLock.unlock() }
            return appendLocked(.live(canonical), remainsLive: remainsLive)
        }
        #endif

        #if EPR_H4_LIVE
        fileprivate func appendH8(_ canonical: GuestH8Provenance.Projection, remainsLive: () -> Bool) -> StoreResult {
            operationLock.lock(); defer { operationLock.unlock() }
            return appendLocked(.h8(canonical), remainsLive: remainsLive)
        }
        #endif

        private func appendLocked(_ canonical: Payload,
                                  remainsLive: () -> Bool) -> StoreResult {
            var database: OpaquePointer?
            var stage: Int32 = -1
            var final: Int32 = -1
            var commitEntered = false, commitOK = false
            var createEntered = false, created = false
            var renameEntered = false, renameOK = false
            var sealedStage = stat()
            defer {
                if final >= 0 { _ = Darwin.close(final) }
                if stage >= 0 { _ = Darwin.close(stage) }
                if let database { _ = sqlite3_close_v2(database) }
            }
            do {
                guard remainsLive() else { throw Failure.expired }
                try validateRoot(expected: [])
                database = try Self.openMemory()
                try Self.writerPolicy(database)
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.beforeBegin) { throw Failure.transactionRejected }
                #endif
                try Self.exec(database, "BEGIN IMMEDIATE")
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.afterBegin) { throw Failure.transactionRejected }
                #endif
                try Self.exec(database, canonical.tableSQL)
                try Self.exec(database, "PRAGMA application_id=\(applicationID)")
                try Self.exec(database, "PRAGMA user_version=\(userVersion)")
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.afterSchema) { throw Failure.transactionRejected }
                #endif
                try Self.insert(canonical, into: database)
                try Self.validate(database, expected: canonical)
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.afterInsert) { throw Failure.transactionRejected }
                #endif
                guard remainsLive() else { throw Failure.expired }
                #if EPR_H4_PRIVACY_TESTS
                calls.enter(.commit)
                #endif
                commitEntered = true
                #if EPR_H4_PRIVACY_TESTS
                if case .injected(.commitResponseLost) = fault {
                    try Self.exec(database, "COMMIT")
                    throw Failure.commitOutcomeUnknown
                }
                #endif
                try Self.exec(database, "COMMIT"); commitOK = true
                guard sqlite3_get_autocommit(database) == 1,
                      sqlite3_txn_state(database, "main") == SQLITE_TXN_NONE else {
                    throw Failure.transactionRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                var image = try serializePublication(database)
                #else
                var image = try Self.serialize(database)
                #endif
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.serializedOversize) {
                    image = Data(count: Int(maximumDatabasePages * pageSize) + 1)
                } else if hasFault(.serializedMisaligned) { image.append(0) }
                else if hasFault(.serializedBadHeader), !image.isEmpty { image[0] ^= 0xff }
                else if hasFault(.serializedWrongWriteVersion), image.count >= 19 {
                    image[18] = 0x02
                } else if hasFault(.serializedWrongReadVersion), image.count >= 20 {
                    image[19] = 0x02
                }
                else if hasFault(.serializedWrongPageSize), image.count >= 18 {
                    image[16] = 0x20
                    image[17] = 0x00
                } else if hasFault(.serializedWrongPageCount), image.count >= 32 {
                    image[28] = 0
                    image[29] = 0
                    image[30] = 0
                    image[31] = 0
                }
                if hasFault(.writerStatementLeak) { _ = try Self.prepare(database, "SELECT 1") }
                let writerCloseExact = Self.closeExact(&database) {
                    self.calls.recordContainedStatements($0)
                }
                guard writerCloseExact else { throw Failure.closeRejected }
                #else
                guard Self.closeExact(&database) else { throw Failure.closeRejected }
                #endif
                try Self.validateImage(image)
                try reopen(image, expected: canonical, final: false)
                guard remainsLive() else { throw Failure.expired }
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.parentReboundBeforeStaging) {
                    try reboundParent(".h4d3-before-staging-displaced")
                    throw Failure.storeAdmissionRejected
                }
                #endif
                try validateRoot(expected: [])
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.beforeStagingCreate)
                #endif
                createEntered = true
                #if EPR_H4_PRIVACY_TESTS
                calls.enter(.stagingCreate)
                #endif
                stage = epr_h4d3_create_staging(root.descriptor)
                guard stage >= 0 else { throw Failure.stagingCreationRejected }
                created = true
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.afterStagingCreate)
                if hasFault(.afterStagingCreation) { throw Failure.stagingCreationRejected }
                if hasFault(.parentReboundAfterStaging) {
                    try reboundParent(".h4d3-after-staging-displaced")
                    throw Failure.storeAdmissionRejected
                }
                #endif
                let wrote: Int
                #if EPR_H4_PRIVACY_TESTS
                wrote = completeImagePwrite(image, to: stage)
                #else
                wrote = image.withUnsafeBytes {
                    pwrite(stage, $0.baseAddress, image.count, 0) }
                #endif
                guard wrote == image.count else { throw Failure.writeRejected }
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.afterCompleteImagePwrite)
                guard sealMode(stage) == 0 else { throw Failure.modeSealRejected }
                #else
                guard fchmod(stage, 0o400) == 0 else { throw Failure.modeSealRejected }
                #endif
                guard fstat(stage, &sealedStage) == 0,
                      Self.validFile(sealedStage, size: image.count) else {
                    throw Failure.identityRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.afterModeSealAndFstat)
                guard syncStaging(stage, full: false) == 0 else {
                    throw Failure.syncRejected
                }
                try publicationInterstice?(.afterStagingFSync)
                guard syncStaging(stage, full: true) == 0 else {
                    throw Failure.syncRejected
                }
                try publicationInterstice?(.afterStagingFullSync)
                #else
                guard fsync(stage) == 0, fcntl(stage, F_FULLFSYNC) == 0 else {
                    throw Failure.syncRejected
                }
                #endif
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.stagingExactLengthMismatch) {
                    var byte = image[image.startIndex] ^ 0xff
                    guard pwrite(stage, &byte, 1, 0) == 1 else {
                        throw Failure.readbackRejected
                    }
                    calls.recordPrivateMutation()
                }
                #endif
                #if EPR_H4_PRIVACY_TESTS
                var stagingReadback = try Self.readExact(
                    stage,
                    image.count,
                    expected: image,
                    afterRead: {
                    if self.hasFault(.stagingEOFMismatch) {
                        var byte: UInt8 = 0xa5
                        guard pwrite(stage, &byte, 1, off_t(image.count)) == 1 else {
                            throw Failure.readbackRejected
                        }
                        self.calls.recordPrivateMutation()
                    }
                }, observe: {
                    self.calls.recordRead(final: false, .init(
                        requestedCount: $0.requestedCount,
                        firstPreadReturn: $0.firstPreadReturn,
                        fstatReturn: $0.fstatReturn,
                        observedSize: $0.observedSize,
                        eofPreadReturn: $0.eofPreadReturn,
                        bytesEqualExpected: $0.bytesEqualExpected))
                })
                if hasFault(.stagingReadbackMismatch), !stagingReadback.isEmpty {
                    stagingReadback[0] ^= 0xff
                }
                #else
                let stagingReadback = try Self.readExact(stage, image.count)
                #endif
                guard stagingReadback == image else {
                    throw Failure.readbackRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.stagingStatRejected) { throw Failure.identityRejected }
                if hasFault(.stagingUnlinked) {
                    _ = Self.stagingLeaf.withCString {
                        unlinkat(root.descriptor, $0, 0)
                    }
                    throw Failure.identityRejected
                }
                if hasFault(.stagingHardlinked) {
                    _ = Self.stagingLeaf.withCString { source in
                        ".h4d3-staging-hardlink".withCString { target in
                            linkat(root.descriptor, source, root.descriptor, target, 0)
                        }
                    }
                    throw Failure.identityRejected
                }
                if hasFault(.stagingRebound) {
                    _ = Self.stagingLeaf.withCString { source in
                        ".h4d3-staging-displaced".withCString { target in
                            renameat(root.descriptor, source, root.descriptor, target)
                        }
                    }
                    let replacement = Self.stagingLeaf.withCString {
                        openat(root.descriptor, $0, O_WRONLY | O_CREAT | O_EXCL |
                            O_NOFOLLOW | O_CLOEXEC, 0o400)
                    }
                    if replacement >= 0 { _ = Darwin.close(replacement) }
                    throw Failure.identityRejected
                }
                if hasFault(.stagingSymlinkAfterSnapshot) {
                    try replaceNamedLeaf(Self.stagingLeaf, with: .symlink,
                                         bytes: image)
                } else if hasFault(.stagingFIFOAfterSnapshot) {
                    try replaceNamedLeaf(Self.stagingLeaf, with: .fifo,
                                         bytes: image)
                } else if hasFault(.stagingNonregularAfterSnapshot) {
                    try replaceNamedLeaf(Self.stagingLeaf, with: .directory,
                                         bytes: image)
                } else if hasFault(.stagingSameBytesNewInode) {
                    try replaceNamedLeaf(Self.stagingLeaf, with: .regular,
                                         bytes: image)
                }
                #endif
                var namedStaging = stat(), heldStaging = stat()
                guard Self.statLeaf(Self.stagingLeaf, root.descriptor, &namedStaging),
                      fstat(stage, &heldStaging) == 0,
                      Self.sameFile(namedStaging, heldStaging),
                      Self.sameFile(sealedStage, heldStaging) else {
                    throw Failure.identityRejected
                }
                try validateRoot(expected: [Self.stagingLeaf])
                guard remainsLive() else { throw Failure.expired }
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.afterStagingReadbackAndVnodeJoin)
                if hasFault(.renameCollision) {
                    let collision = Self.finalLeaf.withCString {
                        openat(root.descriptor, $0,
                            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                            0o400)
                    }
                    guard collision >= 0, Darwin.close(collision) == 0 else {
                        throw Failure.publicationRejected
                    }
                    calls.recordPrivateMutation()
                }
                renameEntered = true
                let publication = publishStaging()
                guard publication.result == 0 else {
                    throw Failure.publicationRejected
                }
                renameOK = true
                if publication.responseLost {
                    renameOK = false
                    throw Failure.publicationRejected
                }
                try publicationInterstice?(.afterPublicationRename)
                #else
                renameEntered = true
                guard epr_h4d3_publish_staging(root.descriptor) == 0 else {
                    throw Failure.publicationRejected
                }
                renameOK = true
                #endif
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.parentReboundAfterRename) {
                    try reboundParent(".h4d3-after-rename-displaced")
                    throw Failure.storeAdmissionRejected
                }
                #endif
                try validateRoot(expected: [Self.finalLeaf])
                var namedFinal = stat()
                guard Self.statLeaf(Self.finalLeaf, root.descriptor, &namedFinal),
                      Self.sameAcrossRename(sealedStage, namedFinal) else {
                    throw Failure.identityRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                guard syncDirectory() == 0 else {
                    throw Failure.directorySyncRejected
                }
                try publicationInterstice?(.afterDirectoryFSync)
                #else
                guard fsync(root.descriptor) == 0 else {
                    throw Failure.directorySyncRejected
                }
                #endif
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.finalReboundBeforeOpen) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular, bytes: Data())
                } else if hasFault(.finalFIFOBeforeOpen) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .fifo, bytes: image)
                } else if hasFault(.finalSymlinkBeforeOpen) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .symlink, bytes: image)
                } else if hasFault(.finalNonregularBeforeOpen) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .directory, bytes: image)
                } else if hasFault(.finalSameBytesNewInodeBeforeOpen) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular, bytes: image)
                }
                #endif
                var preopenNamed = stat()
                guard Self.statLeaf(Self.finalLeaf, root.descriptor, &preopenNamed),
                      Self.sameFile(namedFinal, preopenNamed) else {
                    throw Failure.identityRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                final = openFinal()
                #else
                final = epr_h4d3_open_final(root.descriptor)
                #endif
                guard final >= 0 else { throw Failure.finalOpenRejected }
                var opened = stat()
                guard fstat(final, &opened) == 0,
                      Self.validFile(opened, size: image.count),
                      Self.sameFile(preopenNamed, opened) else {
                    throw Failure.identityRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.finalExactLengthMismatch) {
                    var byte = image[image.startIndex] ^ 0xff
                    guard pwrite(stage, &byte, 1, 0) == 1 else {
                        throw Failure.readbackRejected
                    }
                    calls.recordPrivateMutation()
                }
                #endif
                #if EPR_H4_PRIVACY_TESTS
                var finalReadback = try Self.readExact(
                    final,
                    image.count,
                    expected: image,
                    afterRead: {
                    if self.hasFault(.finalEOFMismatch) {
                        var byte: UInt8 = 0x5a
                        guard pwrite(stage, &byte, 1, off_t(image.count)) == 1 else {
                            throw Failure.readbackRejected
                        }
                        self.calls.recordPrivateMutation()
                    }
                }, observe: {
                    self.calls.recordRead(final: true, .init(
                        requestedCount: $0.requestedCount,
                        firstPreadReturn: $0.firstPreadReturn,
                        fstatReturn: $0.fstatReturn,
                        observedSize: $0.observedSize,
                        eofPreadReturn: $0.eofPreadReturn,
                        bytesEqualExpected: $0.bytesEqualExpected))
                })
                if hasFault(.finalReadbackMismatch), !finalReadback.isEmpty {
                    finalReadback[0] ^= 0xff
                }
                #else
                let finalReadback = try Self.readExact(final, image.count)
                #endif
                guard finalReadback == image else { throw Failure.readbackRejected }
                try reopen(finalReadback, expected: canonical, final: true)
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.finalReboundAfterRead) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular, bytes: Data())
                } else if hasFault(.finalSameBytesNewInodeAfterRead) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular, bytes: image)
                }
                #endif
                var terminalNamed = stat(), terminalOpened = stat()
                guard Self.statLeaf(Self.finalLeaf, root.descriptor, &terminalNamed),
                      fstat(final, &terminalOpened) == 0,
                      Self.sameFile(namedFinal, terminalNamed),
                      Self.sameFile(terminalNamed, terminalOpened) else {
                    throw Failure.identityRejected
                }
                #if EPR_H4_PRIVACY_TESTS
                try closeFinal(&final)
                #else
                guard Darwin.close(final) == 0 else { throw Failure.closeRejected }
                final = -1
                #endif
                guard Darwin.close(stage) == 0 else { throw Failure.closeRejected }
                stage = -1
                #if EPR_H4_PRIVACY_TESTS
                if hasFault(.finalReboundBeforeSuccess) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular,
                                         bytes: Data())
                } else if hasFault(.finalSameBytesNewInodeBeforeSuccess) {
                    try replaceNamedLeaf(Self.finalLeaf, with: .regular,
                                         bytes: image)
                }
                if hasFault(.parentReboundBeforeSuccess) {
                    try reboundParent(".h4d3-before-success-displaced")
                    throw Failure.storeAdmissionRejected
                }
                #endif
                guard remainsLive() else { throw Failure.expired }
                var postCloseNamed = stat()
                guard Self.statLeaf(Self.finalLeaf, root.descriptor,
                                    &postCloseNamed),
                      Self.validFile(postCloseNamed, size: image.count),
                      Self.sameFile(terminalOpened, postCloseNamed),
                      remainsLive() else {
                    throw Failure.identityRejected
                }
                try validateRoot(expected: [Self.finalLeaf])
                #if EPR_H4_PRIVACY_TESTS
                try publicationInterstice?(.afterFinalVerificationBeforeStoreReceipt)
                #endif
                return .admitted(ReceiptMint())
            } catch let failure as Failure {
                if renameOK { return .publishedUnverified(failure) }
                if renameEntered { return .publicationOutcomeUnknown(failure) }
                if created {
                    var named = stat(), held = stat()
                    if (try? validateRoot(expected: [Self.stagingLeaf])) != nil,
                       Self.statLeaf(Self.stagingLeaf, root.descriptor, &named),
                       fstat(stage, &held) == 0,
                       Self.sameFile(named, held),
                       Self.validRetainedFile(held) {
                        return .stagingRetained(failure)
                    }
                    return .prepublicationStateUnknown(failure)
                }
                if createEntered { return .prepublicationStateUnknown(failure) }
                if commitEntered && !commitOK {
                    return .transactionOutcomeUnknown(.commitOutcomeUnknown)
                }
                if (try? validateRoot(expected: [])) == nil {
                    return .prepublicationStateUnknown(failure)
                }
                return .rejectedBeforePublication(failure)
            } catch {
                return renameOK ? .publishedUnverified(.storeAdmissionRejected) :
                    .rejectedBeforePublication(.storeAdmissionRejected)
            }
        }

        private static let tableName = "h4_dual_receipts"
        #if EPR_H4_LIVE
        fileprivate static let liveTableSQL = "CREATE TABLE h4_dual_receipts(singleton INTEGER PRIMARY KEY CHECK(singleton=1),semantic_schema TEXT NOT NULL CHECK(semantic_schema='\(GuestH3LivePersistence.schema)'),claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NATIVE_PASS'),predicate_count INTEGER NOT NULL CHECK(predicate_count=9),authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),canonical_json BLOB NOT NULL CHECK(length(canonical_json)>0 AND length(canonical_json)<=32768),canonical_cbor BLOB NOT NULL CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=32768)) STRICT, WITHOUT ROWID"
        fileprivate static let h8TableSQL = "CREATE TABLE h4_dual_receipts(singleton INTEGER PRIMARY KEY CHECK(singleton=1),semantic_schema TEXT NOT NULL CHECK(semantic_schema='\(GuestH8Provenance.schema)'),claim_state TEXT NOT NULL CHECK(claim_state='RECORDED_H7_NATIVE_PASS'),predicate_count INTEGER NOT NULL CHECK(predicate_count=9),authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),canonical_json BLOB NOT NULL CHECK(length(canonical_json)>0 AND length(canonical_json)<=32768),canonical_cbor BLOB NOT NULL CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=32768)) STRICT, WITHOUT ROWID"
        #endif
        fileprivate static let tableSQL = "CREATE TABLE h4_dual_receipts(singleton INTEGER PRIMARY KEY CHECK(singleton=1),semantic_schema TEXT NOT NULL CHECK(semantic_schema='\(H4C.semanticSchema)'),claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS'),predicate_count INTEGER NOT NULL CHECK(predicate_count>0 AND predicate_count<=4096),authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),canonical_json BLOB NOT NULL CHECK(length(canonical_json)>0 AND length(canonical_json)<=158),canonical_cbor BLOB NOT NULL CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=158)) STRICT, WITHOUT ROWID"
        private static let insertSQL = "INSERT INTO h4_dual_receipts(singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor) VALUES(1,?,?,?,?,?,?)"
        private static let rowSQL = "SELECT singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor FROM h4_dual_receipts LIMIT 2"
        #if EPR_H4_PRIVACY_TESTS
        private static let v2TableSQL =
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
        #endif
        private static var stagingLeaf: String { stagingLeafName }
        private static var finalLeaf: String { finalLeafName }
        #if EPR_H4_PRIVACY_TESTS
        static let faultDisplacedLeafName =
            HypervisorStageH4DualStreamPersistence.faultDisplacedLeafName
        private func hasFault(_ expected: TestFault) -> Bool {
            if case .injected(let actual) = fault { return actual == expected }
            return false
        }

        private func serializePublication(
            _ database: OpaquePointer?
        ) throws -> Data {
            if hasFault(.serializeRejected) {
                calls.recordPrimitive(
                    kind: .publicationSerialize,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil,
                    origin: .injected)
                throw Failure.serializationRejected
            }
            do {
                let image = try Self.serialize(database)
                calls.recordPrimitive(
                    kind: .publicationSerialize,
                    backendInvoked: true,
                    backendReturn: Int64(SQLITE_OK),
                    effectiveReturn: Int64(SQLITE_OK),
                    error: nil,
                    origin: .backend)
                return image
            } catch {
                calls.recordPrimitive(
                    kind: .publicationSerialize,
                    backendInvoked: true,
                    backendReturn: nil,
                    effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil,
                    origin: .backend)
                throw error
            }
        }

        private func completeImagePwrite(_ image: Data, to fd: Int32) -> Int {
            calls.enter(.pwrite)
            let injected: Int?
            if hasFault(.pwriteRejected) { injected = -1 }
            else if hasFault(.pwriteZero) { injected = 0 }
            else if hasFault(.pwriteShort) { injected = max(0, image.count - 1) }
            else if hasFault(.pwriteOverrun) { injected = image.count + 1 }
            else { injected = nil }
            if let injected {
                calls.recordPrimitive(
                    kind: .completeImagePwrite,
                    backendInvoked: false,
                    backendReturn: nil,
                    effectiveReturn: Int64(injected),
                    error: injected < 0 ? EIO : nil,
                    origin: .injected,
                    requestedCount: image.count)
                return injected
            }
            errno = 0
            let result = image.withUnsafeBytes {
                pwrite(fd, $0.baseAddress, image.count, 0)
            }
            let error = errno
            calls.recordPrimitive(
                kind: .completeImagePwrite,
                backendInvoked: true,
                backendReturn: Int64(result),
                effectiveReturn: Int64(result),
                error: result < 0 ? error : nil,
                origin: .backend,
                requestedCount: image.count)
            return result
        }

        private func sealMode(_ fd: Int32) -> Int32 {
            if hasFault(.modeSealRejected) {
                calls.recordPrimitive(kind: .modeSeal, backendInvoked: false,
                    backendReturn: nil, effectiveReturn: -1, error: EIO,
                    origin: .injected)
                return -1
            }
            errno = 0
            let result = fchmod(fd, 0o400)
            let error = errno
            calls.recordPrimitive(kind: .modeSeal, backendInvoked: true,
                backendReturn: Int64(result), effectiveReturn: Int64(result),
                error: result < 0 ? error : nil, origin: .backend)
            return result
        }

        private func syncStaging(_ fd: Int32, full: Bool) -> Int32 {
            let kind: TestPrimitiveKind = full ? .stagingFullSync : .stagingFSync
            let reject = full ? hasFault(.fullSyncRejected) : hasFault(.fsyncRejected)
            if reject {
                calls.recordPrimitive(kind: kind, backendInvoked: false,
                    backendReturn: nil, effectiveReturn: -1, error: EIO,
                    origin: .injected)
                return -1
            }
            errno = 0
            let result = full ? fcntl(fd, F_FULLFSYNC) : fsync(fd)
            let error = errno
            calls.recordPrimitive(kind: kind, backendInvoked: true,
                backendReturn: Int64(result), effectiveReturn: Int64(result),
                error: result < 0 ? error : nil, origin: .backend)
            return result
        }

        private func publishStaging() -> (result: Int32, responseLost: Bool) {
            calls.enter(.rename)
            errno = 0
            let backend = epr_h4d3_publish_staging(root.descriptor)
            let error = errno
            let responseLost = backend == 0 && hasFault(.renameResponseLost)
            calls.recordPrimitive(
                kind: .publicationRename,
                backendInvoked: true,
                backendReturn: Int64(backend),
                effectiveReturn: responseLost ? -1 : Int64(backend),
                error: backend < 0 ? error : nil,
                origin: responseLost ? .responseLost : .backend)
            if hasFault(.renameCollision) {
                calls.recordRenameCollision(result: backend, error: error)
            }
            return (backend, responseLost)
        }

        private func syncDirectory() -> Int32 {
            if hasFault(.directorySyncRejected) {
                calls.recordPrimitive(kind: .directoryFSync,
                    backendInvoked: false, backendReturn: nil,
                    effectiveReturn: -1, error: EIO, origin: .injected)
                return -1
            }
            errno = 0
            let result = fsync(root.descriptor)
            let error = errno
            calls.recordPrimitive(kind: .directoryFSync,
                backendInvoked: true, backendReturn: Int64(result),
                effectiveReturn: Int64(result), error: result < 0 ? error : nil,
                origin: .backend)
            return result
        }

        private func openFinal() -> Int32 {
            calls.enter(.finalOpen)
            if hasFault(.finalOpenRejected) {
                calls.recordPrimitive(kind: .finalOpen, backendInvoked: false,
                    backendReturn: nil, effectiveReturn: -1, error: EIO,
                    origin: .injected)
                return -1
            }
            errno = 0
            let result = epr_h4d3_open_final(root.descriptor)
            let error = errno
            calls.recordPrimitive(kind: .finalOpen, backendInvoked: true,
                backendReturn: Int64(result), effectiveReturn: Int64(result),
                error: result < 0 ? error : nil, origin: .backend)
            return result
        }

        private func closeFinal(_ fd: inout Int32) throws {
            errno = 0
            let backend = Darwin.close(fd)
            let error = errno
            if backend == 0 { fd = -1 }
            let responseLost = backend == 0 &&
                hasFault(.finalDescriptorCloseResponseLost)
            calls.recordPrimitive(
                kind: .finalDescriptorClose,
                backendInvoked: true,
                backendReturn: Int64(backend),
                effectiveReturn: responseLost ? -1 : Int64(backend),
                error: backend < 0 ? error : nil,
                origin: responseLost ? .responseLost : .backend)
            guard backend == 0, !responseLost else { throw Failure.closeRejected }
        }

        private func deserializeReadOnly(
            _ image: Data,
            into database: OpaquePointer?,
            final: Bool
        ) throws {
            let kind: TestPrimitiveKind = final
                ? .finalDeserialize : .prepublicationDeserialize
            let rejected = final
                ? hasFault(.finalDeserializeRejected)
                : hasFault(.prepublicationDeserializeRejected)
            if rejected {
                calls.recordPrimitive(kind: kind, backendInvoked: false,
                    backendReturn: nil, effectiveReturn: Int64(SQLITE_ERROR),
                    error: nil, origin: .injected)
                throw Failure.reconstructionRejected
            }
            guard let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                calls.recordPrimitive(kind: kind, backendInvoked: false,
                    backendReturn: nil, effectiveReturn: Int64(SQLITE_NOMEM),
                    error: nil, origin: .backend)
                throw Failure.reconstructionRejected
            }
            image.copyBytes(
                to: allocation.assumingMemoryBound(to: UInt8.self),
                count: image.count)
            let result = epr_sqlite_deserialize_readonly(
                UnsafeMutableRawPointer(database),
                allocation.assumingMemoryBound(to: UInt8.self),
                Int64(image.count))
            calls.recordPrimitive(kind: kind, backendInvoked: true,
                backendReturn: Int64(result), effectiveReturn: Int64(result),
                error: nil, origin: .backend)
            guard result == SQLITE_OK else {
                // FREEONCLOSE consumes allocation even on failure.
                throw Failure.reconstructionRejected
            }
        }

        private func reconstructionFault(final: Bool) -> TestFault? {
            guard case .injected(let value) = fault else { return nil }
            let name = String(describing: value)
            guard name.hasPrefix(final ? "final" : "prepublication") else {
                return nil
            }
            return value
        }

        /// Test-only corruption always changes a private SQLite image. The
        /// published candidate remains byte-exact; the ordinary read-only
        /// reconstruction path below must discover every deviation.
        private func mutatedPrivateImage(
            _ image: Data,
            expected: H4C.Projection,
            final: Bool
        ) throws -> Data {
            guard let value = reconstructionFault(final: final) else { return image }
            switch value {
            case .prepublicationDeserializeRejected, .finalDeserializeRejected,
                 .prepublicationReaderPolicyRejected, .finalReaderPolicyRejected,
                 .prepublicationAuthorizerRejected, .finalAuthorizerRejected,
                 .prepublicationQueryOnlyRejected, .finalQueryOnlyRejected,
                 .prepublicationFilenameRejected, .finalFilenameRejected,
                 .prepublicationStatementLeak, .finalStatementLeak:
                return image
            default: break
            }

            var db: OpaquePointer? = try Self.openMutableImage(image)
            defer { _ = Self.closeExact(&db) }
            try Self.exec(db, "PRAGMA ignore_check_constraints=ON")
            switch value {
            case .prepublicationJSONRejected, .finalJSONRejected,
                 .prepublicationJSONCorrupt, .finalJSONCorrupt:
                try Self.updateBlob(db, column: "canonical_json", value: Data([0x7b]))
            case .prepublicationJSONNoncanonical, .finalJSONNoncanonical:
                try Self.updateBlob(db, column: "canonical_json",
                    value: try Self.jsonWithNoncanonicalWhitespace(expected.json))
            case .prepublicationJSONTrailing, .finalJSONTrailing:
                try Self.appendBlobByte(db, column: "canonical_json", byte: 0x20)
            case .prepublicationJSONAlias, .finalJSONAlias:
                try Self.updateBlob(db, column: "canonical_json",
                                    value: try Self.jsonNumberAlias(expected.json))
            case .prepublicationJSONUnknownField, .finalJSONUnknownField:
                try Self.updateBlob(db, column: "canonical_json",
                                    value: try Self.jsonWithUnknownField(expected.json))
            case .prepublicationCBORRejected, .finalCBORRejected,
                 .prepublicationCBORCorrupt, .finalCBORCorrupt:
                try Self.updateBlob(db, column: "canonical_cbor", value: Data([0xff]))
            case .prepublicationCBORNoncanonical, .finalCBORNoncanonical:
                try Self.updateBlob(db, column: "canonical_cbor",
                                    value: try Self.cborWithOverlongMap(expected.cbor))
            case .prepublicationCBORTrailing, .finalCBORTrailing:
                try Self.appendBlobByte(db, column: "canonical_cbor", byte: 0x00)
            case .prepublicationCBORAlias, .finalCBORAlias:
                try Self.updateBlob(db, column: "canonical_cbor",
                                    value: try Self.cborNumberAlias(expected.cbor))
            case .prepublicationCBORUnknownField, .finalCBORUnknownField:
                try Self.updateBlob(db, column: "canonical_cbor",
                                    value: try Self.cborWithUnknownField(expected.cbor))
            case .prepublicationScalarRejected, .finalScalarRejected,
                 .prepublicationScalarMismatch, .finalScalarMismatch:
                try Self.exec(db, "UPDATE h4_dual_receipts SET predicate_count=predicate_count+1")
            case .prepublicationScalarWrongStorage, .finalScalarWrongStorage:
                try Self.exec(db, "CREATE TEMP TABLE h4_d3_wrong_storage AS SELECT singleton,semantic_schema,claim_state,CAST(predicate_count AS TEXT) AS predicate_count,authority_vector,canonical_json,canonical_cbor FROM h4_dual_receipts")
                try Self.exec(db, "DROP TABLE h4_dual_receipts")
                let relaxedSQL = Self.tableSQL.replacingOccurrences(
                    of: "predicate_count INTEGER",
                    with: "predicate_count ANY    ")
                try Self.exec(db, relaxedSQL)
                try Self.exec(db, "INSERT INTO h4_dual_receipts(singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor) SELECT singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor FROM temp.h4_d3_wrong_storage")
                let relaxedImage = try Self.serialize(db)
                let result = try Self.replacingUniqueBytes(
                    in: relaxedImage,
                    needle: Data("predicate_count ANY    ".utf8),
                    replacement: Data("predicate_count INTEGER".utf8)
                )
                calls.recordPrivateMutation()
                guard Self.closeExact(&db) else { throw Failure.closeRejected }
                return result
            case .prepublicationThreeFieldSubstitution, .finalThreeFieldSubstitution:
                let substitute = try H4C.d3SelfConsistentSubstitutionTestVector(
                    from: expected)
                try Self.updateBlob(db, column: "canonical_json",
                                    value: substitute.json)
                try Self.updateBlob(db, column: "canonical_cbor",
                                    value: substitute.cbor)
                try Self.exec(db, "UPDATE h4_dual_receipts SET predicate_count=\(substitute.predicateCount)")
            case .prepublicationSchemaRejected, .finalSchemaRejected:
                try Self.exec(db, "PRAGMA user_version=1")
            case .prepublicationV2Schema, .finalV2Schema:
                try Self.exec(db, "CREATE TEMP TABLE h4_d3_v2_row AS SELECT singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_cbor FROM h4_dual_receipts")
                try Self.exec(db, "DROP TABLE h4_dual_receipts")
                try Self.exec(db, Self.v2TableSQL)
                try Self.exec(db, "INSERT INTO h4_receipts(singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_cbor) SELECT singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_cbor FROM temp.h4_d3_v2_row")
                try Self.exec(db, "PRAGMA user_version=2")
                guard try Self.integer(db,
                    "SELECT count(*) FROM pragma_table_xinfo('h4_receipts')") == 6,
                      try Self.integer(db,
                    "SELECT count(*) FROM h4_receipts") == 1 else {
                    throw Failure.reconstructionRejected
                }
                calls.recordV2SchemaActuation()
            case .prepublicationWrongUserVersion, .finalWrongUserVersion:
                try Self.exec(db, "PRAGMA user_version=3")
            case .prepublicationWrongApplicationID, .finalWrongApplicationID:
                try Self.exec(db, "PRAGMA application_id=1")
            case .prepublicationExtraSchemaObject, .finalExtraSchemaObject:
                try Self.exec(db, "CREATE TABLE h4_d3_extra(value INTEGER)")
            case .prepublicationExtraColumn, .finalExtraColumn:
                try Self.exec(db, "ALTER TABLE h4_dual_receipts ADD COLUMN extra INTEGER")
            case .prepublicationExtraRow, .finalExtraRow:
                try Self.exec(db, "INSERT INTO h4_dual_receipts(singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor) SELECT 2,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor FROM h4_dual_receipts WHERE singleton=1")
            case .prepublicationIntegrityRejected, .finalIntegrityRejected:
                let rootPage = try Self.integer(db,
                    "SELECT rootpage FROM sqlite_schema WHERE type='table' AND name='h4_dual_receipts'")
                var result = try Self.serialize(db)
                guard rootPage > 0,
                      let page = Int(exactly: rootPage - 1),
                      page <= Int.max / Int(pageSize) else {
                    throw Failure.reconstructionRejected
                }
                let pageOffset = page * Int(pageSize) + (rootPage == 1 ? 100 : 0)
                guard pageOffset < result.count else {
                    throw Failure.reconstructionRejected
                }
                result[pageOffset] = 0
                calls.recordPrivateMutation()
                guard Self.closeExact(&db) else { throw Failure.closeRejected }
                return result
            default: return image
            }
            let result = try Self.serialize(db)
            calls.recordPrivateMutation()
            guard Self.closeExact(&db) else { throw Failure.closeRejected }
            return result
        }

        private static func openMutableImage(_ image: Data) throws -> OpaquePointer {
            try validateImage(image)
            let db = try openMemory()
            let result = image.withUnsafeBytes { bytes in
                epr_h4d3_deserialize_mutable_image(
                    UnsafeMutableRawPointer(db),
                    bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    Int64(image.count))
            }
            guard result == SQLITE_OK else {
                var opened: OpaquePointer? = db
                _ = closeExact(&opened)
                throw Failure.reconstructionRejected
            }
            guard try integer(db, "PRAGMA max_page_count=64") ==
                    maximumDatabasePages else {
                var opened: OpaquePointer? = db
                _ = closeExact(&opened)
                throw Failure.reconstructionRejected
            }
            return db
        }

        private static func jsonWithNoncanonicalWhitespace(
            _ canonical: Data
        ) throws -> Data {
            guard canonical.first == UInt8(ascii: "{") else {
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result.insert(UInt8(ascii: " "), at: result.startIndex + 1)
            return result
        }

        private static func jsonNumberAlias(_ canonical: Data) throws -> Data {
            let marker = Data("\"predicate_count\":".utf8)
            guard let range = canonical.range(of: marker),
                  range.upperBound < canonical.endIndex else {
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result.insert(UInt8(ascii: "0"), at: range.upperBound)
            return result
        }

        private static func jsonWithUnknownField(_ canonical: Data) throws -> Data {
            guard canonical.last == UInt8(ascii: "}") else {
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result.insert(contentsOf: Data(",\"x\":0".utf8),
                          at: result.index(before: result.endIndex))
            return result
        }

        private static func cborWithOverlongMap(_ canonical: Data) throws -> Data {
            guard canonical.first == 0xa4 else {
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result.replaceSubrange(result.startIndex...result.startIndex,
                                   with: [0xb8, 0x04])
            return result
        }

        private static func cborNumberAlias(_ canonical: Data) throws -> Data {
            var marker = Data([0x6f])
            marker.append(Data("predicate_count".utf8))
            guard let range = canonical.range(of: marker),
                  range.upperBound < canonical.endIndex else {
                throw Failure.reconstructionRejected
            }
            let start = range.upperBound
            let initial = canonical[start]
            guard initial >> 5 == 0 else { throw Failure.reconstructionRejected }
            let additional = initial & 31
            let canonicalWidth: Int
            let replacement: [UInt8]
            switch additional {
            case 0..<24:
                canonicalWidth = 1
                replacement = [0x18, additional]
            case 24:
                canonicalWidth = 2
                guard start + canonicalWidth <= canonical.endIndex else {
                    throw Failure.reconstructionRejected
                }
                replacement = [0x19, 0x00, canonical[start + 1]]
            case 25:
                canonicalWidth = 3
                guard start + canonicalWidth <= canonical.endIndex else {
                    throw Failure.reconstructionRejected
                }
                replacement = [0x1a, 0x00, 0x00,
                               canonical[start + 1], canonical[start + 2]]
            default:
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result.replaceSubrange(start..<(start + canonicalWidth),
                                   with: replacement)
            return result
        }

        private static func cborWithUnknownField(_ canonical: Data) throws -> Data {
            guard canonical.first == 0xa4 else {
                throw Failure.reconstructionRejected
            }
            var result = canonical
            result[result.startIndex] = 0xa5
            result.append(contentsOf: [0x61, UInt8(ascii: "x"), 0x00])
            return result
        }

        private static func replacingUniqueBytes(
            in source: Data,
            needle: Data,
            replacement: Data
        ) throws -> Data {
            guard !needle.isEmpty, needle.count == replacement.count,
                  let range = source.range(of: needle) else {
                throw Failure.reconstructionRejected
            }
            let suffix = Data(source[range.upperBound..<source.endIndex])
            guard suffix.range(of: needle) == nil else {
                throw Failure.reconstructionRejected
            }
            var result = source
            result.replaceSubrange(range, with: replacement)
            return result
        }

        private func reboundParent(_ suffix: String) throws {
            let displaced = root.path + suffix
            guard rename(root.path, displaced) == 0,
                  mkdir(root.path, 0o700) == 0 else {
                throw Failure.storeAdmissionRejected
            }
        }

        private enum ReplacementKind { case symlink, fifo, directory, regular }
        private func replaceNamedLeaf(_ leaf: String, with kind: ReplacementKind,
                                      bytes: Data) throws {
            let moved = leaf.withCString { source in
                HypervisorStageH4DualStreamPersistence.faultDisplacedLeafName.withCString { destination in
                    renameat(root.descriptor, source, root.descriptor, destination)
                }
            }
            guard moved == 0 else { throw Failure.identityRejected }
            let created: Bool
            switch kind {
            case .symlink:
                created = HypervisorStageH4DualStreamPersistence.faultDisplacedLeafName.withCString { target in
                    leaf.withCString { name in
                        symlinkat(target, root.descriptor, name) == 0
                    }
                }
            case .fifo:
                created = leaf.withCString {
                    mkfifoat(root.descriptor, $0, 0o400) == 0
                }
            case .directory:
                created = leaf.withCString {
                    mkdirat(root.descriptor, $0, 0o400) == 0
                }
            case .regular:
                let replacement = leaf.withCString {
                    openat(root.descriptor, $0, O_RDWR | O_CREAT | O_EXCL |
                        O_NOFOLLOW | O_CLOEXEC, 0o400)
                }
                guard replacement >= 0 else { throw Failure.identityRejected }
                defer { _ = Darwin.close(replacement) }
                let count = bytes.withUnsafeBytes {
                    pwrite(replacement, $0.baseAddress, bytes.count, 0)
                }
                created = count == bytes.count && fchmod(replacement, 0o400) == 0
            }
            guard created else { throw Failure.identityRejected }
            var displaced = stat(), replacement = stat()
            guard Self.statLeaf(HypervisorStageH4DualStreamPersistence.faultDisplacedLeafName, root.descriptor,
                                &displaced),
                  Self.statLeaf(leaf, root.descriptor, &replacement),
                  displaced.st_dev != replacement.st_dev ||
                    displaced.st_ino != replacement.st_ino else {
                throw Failure.identityRejected
            }
            let evidenceKind: TestReplacementKind
            switch kind {
            case .symlink: evidenceKind = .symlink
            case .fifo: evidenceKind = .fifo
            case .directory: evidenceKind = .directory
            case .regular: evidenceKind = .regular
            }
            let bytesEqual: Bool?
            if kind == .regular {
                guard displaced.st_size >= 0, replacement.st_size >= 0,
                      displaced.st_size <= maximumDatabasePages * pageSize,
                      replacement.st_size <= maximumDatabasePages * pageSize,
                      let displacedCount = Int(exactly: displaced.st_size),
                      let replacementCount = Int(exactly: replacement.st_size)
                else { throw Failure.identityRejected }
                if displacedCount != replacementCount {
                    bytesEqual = false
                } else if displacedCount == 0 {
                    bytesEqual = true
                } else {
                    let displacedFD = HypervisorStageH4DualStreamPersistence
                        .faultDisplacedLeafName.withCString {
                            openat(root.descriptor, $0,
                                O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC)
                        }
                    guard displacedFD >= 0 else { throw Failure.identityRejected }
                    defer { _ = Darwin.close(displacedFD) }
                    let replacementFD = leaf.withCString {
                        openat(root.descriptor, $0,
                            O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC)
                    }
                    guard replacementFD >= 0 else { throw Failure.identityRejected }
                    defer { _ = Darwin.close(replacementFD) }
                    let displacedBytes = try Self.readExact(
                        displacedFD, displacedCount)
                    let replacementBytes = try Self.readExact(
                        replacementFD, replacementCount)
                    bytesEqual = displacedBytes == replacementBytes
                }
            } else {
                bytesEqual = nil
            }
            calls.recordReplacement(evidenceKind, original: displaced,
                replacement: replacement,
                bytesEqual: bytesEqual)
        }
        #endif

        private static func openMemory() throws -> OpaquePointer {
            var db: OpaquePointer?
            let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE |
                SQLITE_OPEN_MEMORY | SQLITE_OPEN_FULLMUTEX |
                SQLITE_OPEN_PRIVATECACHE | SQLITE_OPEN_EXRESCODE
            let result = sqlite3_open_v2(":memory:", &db, flags, nil)
            guard result == SQLITE_OK, let opened = db else {
                if let db { _ = sqlite3_close_v2(db) }
                throw Failure.sqlitePolicyRejected
            }
            return opened
        }

        private static func writerPolicy(_ db: OpaquePointer?) throws {
            try checked(sqlite3_extended_result_codes(db, 1))
            try checked(sqlite3_busy_timeout(db, 0))
            var policy = EPRSQLiteWriterPolicy()
            guard epr_sqlite_harden_writer(UnsafeMutableRawPointer(db), &policy) == SQLITE_OK,
                  policy.defensive == 1, policy.trusted_schema == 0,
                  policy.dqs_ddl == 0, policy.dqs_dml == 0 else {
                throw Failure.sqlitePolicyRejected
            }
            try exec(db, "PRAGMA page_size=4096")
            try exec(db, "PRAGMA journal_mode=MEMORY")
            try exec(db, "PRAGMA trusted_schema=OFF")
            try exec(db, "PRAGMA temp_store=MEMORY")
            try exec(db, "PRAGMA foreign_keys=ON")
            guard try integer(db, "PRAGMA max_page_count=64") == maximumDatabasePages,
                  try integer(db, "PRAGMA page_size") == pageSize,
                  try textScalar(db, "PRAGMA journal_mode") == "memory",
                  try integer(db, "PRAGMA temp_store") == 2,
                  try integer(db, "PRAGMA foreign_keys") == 1,
                  try integer(db, "PRAGMA trusted_schema") == 0,
                  sqlite3_get_autocommit(db) == 1,
                  sqlite3_txn_state(db, "main") == SQLITE_TXN_NONE else {
                throw Failure.sqlitePolicyRejected
            }
        }

        private struct ReaderPolicyObservation {
            let queryOnly: Bool
            let defensive: Bool
            let trustedSchema: Bool
            let dqsDDL: Bool
            let dqsDML: Bool
            let tempStoreMemory: Bool
            let foreignKeys: Bool
            let autocommit: Bool
            let transactionNone: Bool
            let filenameEmpty: Bool
        }

        private static func readerPolicy(
            _ db: OpaquePointer?
        ) throws -> ReaderPolicyObservation {
            var policy = EPRSQLiteReadOnlyPolicy()
            guard epr_sqlite_harden_readonly(UnsafeMutableRawPointer(db), &policy) == SQLITE_OK,
                  policy.defensive == 1, policy.trusted_schema == 0,
                  policy.dqs_ddl == 0, policy.dqs_dml == 0 else {
                throw Failure.sqlitePolicyRejected
            }
            try exec(db, "PRAGMA query_only=ON")
            try exec(db, "PRAGMA trusted_schema=OFF")
            try exec(db, "PRAGMA temp_store=MEMORY")
            try exec(db, "PRAGMA foreign_keys=ON")
            let queryOnly = try integer(db, "PRAGMA query_only")
            let trustedSchema = try integer(db, "PRAGMA trusted_schema")
            let tempStore = try integer(db, "PRAGMA temp_store")
            let foreignKeys = try integer(db, "PRAGMA foreign_keys")
            let autocommit = sqlite3_get_autocommit(db) == 1
            let transactionNone = sqlite3_txn_state(db, "main") == SQLITE_TXN_NONE
            let filenameEmpty = sqlite3_db_filename(db, "main")?.pointee == 0
            guard queryOnly == 1, trustedSchema == 0, tempStore == 2,
                  foreignKeys == 1, autocommit, transactionNone,
                  filenameEmpty else {
                throw Failure.sqlitePolicyRejected
            }
            return .init(
                queryOnly: queryOnly == 1,
                defensive: policy.defensive == 1,
                trustedSchema: policy.trusted_schema != 0,
                dqsDDL: policy.dqs_ddl != 0,
                dqsDML: policy.dqs_dml != 0,
                tempStoreMemory: tempStore == 2,
                foreignKeys: foreignKeys == 1,
                autocommit: autocommit,
                transactionNone: transactionNone,
                filenameEmpty: filenameEmpty)
        }

        private static func insert(_ p: H4C.Projection,
                                   into db: OpaquePointer?) throws {
            try insert(.fixture(p), into: db)
        }

        private static func insert(_ p: Payload, into db: OpaquePointer?) throws {
            let st = try prepare(db, insertSQL); defer { sqlite3_finalize(st) }
            try bind(p.semanticSchema, 1, st); try bind(p.claimState, 2, st)
            try checked(sqlite3_bind_int64(st, 3, p.predicateCount))
            try bind("00000000", 4, st)
            try bind(p.json, 5, st); try bind(p.cbor, 6, st)
            guard sqlite3_step(st) == SQLITE_DONE, sqlite3_changes(db) == 1 else {
                throw Failure.transactionRejected
            }
        }

        private static func validate(_ db: OpaquePointer?,
                                     expected: Payload) throws {
            try validateSchema(db, expectedSQL: expected.tableSQL)
            try validateRow(db, expected: expected)
        }

        private static func validateSchema(_ db: OpaquePointer?, expectedSQL: String = tableSQL) throws {
            guard try integer(db, "PRAGMA user_version") == userVersion,
                  try integer(db, "PRAGMA application_id") == applicationID,
                  try integer(db, "SELECT count(*) FROM sqlite_schema") == 1,
                  try textScalar(db,
                    "SELECT sql FROM sqlite_schema WHERE type='table' AND name='h4_dual_receipts'") == expectedSQL,
                  try integer(db, "SELECT count(*) FROM pragma_table_xinfo('h4_dual_receipts')") == 7 else {
                throw Failure.reconstructionRejected
            }
        }

        private static func validateRow(_ db: OpaquePointer?,
                                        expected: Payload) throws {
            let st = try prepare(db, rowSQL); defer { sqlite3_finalize(st) }
            guard sqlite3_step(st) == SQLITE_ROW,
                  sqlite3_column_type(st, 0) == SQLITE_INTEGER,
                  sqlite3_column_int64(st, 0) == 1,
                  sqlite3_column_type(st, 3) == SQLITE_INTEGER,
                  sqlite3_column_type(st, 5) == SQLITE_BLOB,
                  sqlite3_column_type(st, 6) == SQLITE_BLOB else {
                throw Failure.reconstructionRejected
            }
            let json = try blob(st, 5, maximum: expected.maximumBytes)
            let cbor = try blob(st, 6, maximum: expected.maximumBytes)
            let reopened = ReopenedDualStreamRowInput(
                canonicalJSON: json, canonicalCBOR: cbor,
                semanticSchema: try text(st, 1), claimState: try text(st, 2),
                predicateCount: sqlite3_column_int64(st, 3),
                authorityVector: try text(st, 4))
            guard sqlite3_step(st) == SQLITE_DONE else {
                throw Failure.reconstructionRejected
            }
            do {
                switch expected {
                case .fixture(let p): _ = try H4C.reconstructPersistedDual(reopened, expected: p)
                #if EPR_H4_LIVE
                case .live(let p): try p.verifyRetained(reopened)
            case .h8(let p): try p.verifyRetained(reopened)
                #endif
                }
            }
            catch { throw Failure.reconstructionRejected }
        }

        private static func serialize(_ db: OpaquePointer?) throws -> Data {
            var data = Data(count: Int(maximumDatabasePages * pageSize))
            var count: Int64 = 0
            let status = data.withUnsafeMutableBytes {
                epr_h4d3_sqlite_serialize_main(UnsafeMutableRawPointer(db),
                    $0.baseAddress?.assumingMemoryBound(to: UInt8.self), &count)
            }
            guard status == SQLITE_OK, let exact = Int(exactly: count),
                  exact > 0, exact <= data.count else {
                throw Failure.serializationRejected
            }
            data.removeSubrange(exact..<data.count); return data
        }

        #if EPR_H4_PRIVACY_TESTS
        /// The old mutator encodes fixture-specific substitutions. These
        /// corruption cases instead mutate the real H4/H8 private image and
        /// let the ordinary owner-bound read-back verifier reject its bytes.
        private func mutatedRetainedImage(_ image: Data, final: Bool) throws -> Data {
            let column: String, bytes: Data
            switch reconstructionFault(final: final) {
            case .prepublicationJSONRejected?, .finalJSONRejected?: column = "canonical_json"; bytes = Data([0x7b])
            case .prepublicationCBORRejected?, .finalCBORRejected?: column = "canonical_cbor"; bytes = Data([0xff])
            default: return image
            }
            var db: OpaquePointer? = try Self.openMutableImage(image)
            defer { _ = Self.closeExact(&db) }
            try Self.updateBlob(db, column: column, value: bytes)
            let result = try Self.serialize(db)
            calls.recordPrivateMutation()
            guard Self.closeExact(&db) else { throw Failure.closeRejected }
            return result
        }
        #endif

        private func reopen(_ image: Data, expected: Payload,
                            final: Bool) throws {
            #if EPR_H4_PRIVACY_TESTS
            let inspectedImage: Data
            if case .fixture(let fixture) = expected {
                inspectedImage = try mutatedPrivateImage(image, expected: fixture, final: final)
            } else { inspectedImage = try mutatedRetainedImage(image, final: final) }
            #else
            let inspectedImage = image
            #endif
            try Self.validateImage(inspectedImage)
            var db: OpaquePointer? = try Self.openMemory()
            defer { _ = Self.closeExact(&db) }
            #if EPR_H4_PRIVACY_TESTS
            try deserializeReadOnly(inspectedImage, into: db, final: final)
            #else
            guard let allocation = sqlite3_malloc64(UInt64(inspectedImage.count)) else {
                throw Failure.reconstructionRejected
            }
            inspectedImage.copyBytes(to: allocation.assumingMemoryBound(to: UInt8.self),
                                     count: inspectedImage.count)
            guard epr_sqlite_deserialize_readonly(UnsafeMutableRawPointer(db),
                allocation.assumingMemoryBound(to: UInt8.self),
                Int64(inspectedImage.count)) == SQLITE_OK else {
                throw Failure.reconstructionRejected
            }
            #endif
            #if EPR_H4_PRIVACY_TESTS
            let policyFault = reconstructionFault(final: final)
            calls.recordReader(final: final)
            #else
            let policyFault: Never? = nil
            #endif
            let readerObservation = try Self.readerPolicy(db)
            #if EPR_H4_PRIVACY_TESTS
            calls.recordPolicy(final: final, .init(
                queryOnly: readerObservation.queryOnly,
                defensive: readerObservation.defensive,
                trustedSchema: readerObservation.trustedSchema,
                dqsDDL: readerObservation.dqsDDL,
                dqsDML: readerObservation.dqsDML,
                tempStoreMemory: readerObservation.tempStoreMemory,
                foreignKeys: readerObservation.foreignKeys,
                autocommit: readerObservation.autocommit,
                transactionNone: readerObservation.transactionNone,
                filenameEmpty: readerObservation.filenameEmpty))
            #endif
            #if EPR_H4_PRIVACY_TESTS
            switch policyFault {
            case .prepublicationReaderPolicyRejected?, .finalReaderPolicyRejected?:
                try Self.exec(db, "PRAGMA trusted_schema=ON")
                calls.recordPrivateMutation()
            case .prepublicationQueryOnlyRejected?, .finalQueryOnlyRejected?:
                try Self.exec(db, "PRAGMA query_only=OFF")
                calls.recordPrivateMutation()
            default: break
            }
            calls.recordValidatorEntry()
            try Self.verifyReaderPolicy(db)
            #endif
            guard try Self.textScalar(db, "PRAGMA integrity_check(1)") == "ok" else {
                throw Failure.reconstructionRejected
            }
            try Self.validateSchema(db, expectedSQL: expected.tableSQL)
            #if EPR_H4_PRIVACY_TESTS
            let omitAuthorizer: Bool
            switch policyFault {
            case .prepublicationAuthorizerRejected?, .finalAuthorizerRejected?:
                omitAuthorizer = true
            default: omitAuthorizer = false
            }
            #else
            let omitAuthorizer = false
            #endif
            guard omitAuthorizer || epr_sqlite_install_readonly_authorizer(
                UnsafeMutableRawPointer(db)) == SQLITE_OK else {
                throw Failure.sqlitePolicyRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            if omitAuthorizer { throw Failure.sqlitePolicyRejected }
            if case .prepublicationFilenameRejected? = policyFault {
                try Self.verifyReaderFilename(db, requireEmpty: false)
            } else if case .finalFilenameRejected? = policyFault {
                try Self.verifyReaderFilename(db, requireEmpty: false)
            }
            #endif
            try Self.validateRow(db, expected: expected)
            #if EPR_H4_PRIVACY_TESTS
            if (!final && hasFault(.prepublicationStatementLeak)) ||
                (final && hasFault(.finalStatementLeak)) {
                _ = try Self.prepare(db, "SELECT 1")
            }
            let readerCloseExact = Self.closeExact(&db) {
                self.calls.recordContainedStatements($0)
            }
            guard readerCloseExact else { throw Failure.closeRejected }
            #else
            guard Self.closeExact(&db) else { throw Failure.closeRejected }
            #endif
        }

        private static func validateImage(_ image: Data) throws {
            let header = Array("SQLite format 3\0".utf8)
            guard image.count >= 100, image.count <= Int(maximumDatabasePages * pageSize),
                  image.count % Int(pageSize) == 0,
                  image.prefix(header.count).elementsEqual(header),
                  image[16] == 0x10, image[17] == 0x00,
                  image[18] == 0x01, image[19] == 0x01 else {
                throw Failure.serializationRejected
            }
            let pageCount = UInt32(image[28]) << 24 |
                UInt32(image[29]) << 16 |
                UInt32(image[30]) << 8 |
                UInt32(image[31])
            guard pageCount > 0,
                  pageCount <= UInt32(maximumDatabasePages),
                  UInt64(pageCount) * UInt64(pageSize) == UInt64(image.count) else {
                throw Failure.serializationRejected
            }
        }

        #if EPR_H4_LIVE
        /// Capture one explicitly selected file; SQLite never receives its
        /// pathname. No directory scan, journal/WAL open, repair, or live mint.
        private struct Captured<Value> {
            let value: Value
            let path: String
            let imageSHA256: String
            let imageBytes: Int
        }
        fileprivate static func readSavedFile(_ url: URL, budget: GuestH4SavedReceipt.Budget) throws -> GuestH4SavedReceipt.Snapshot {
            let captured = try readSavedImage(url, budget: budget, table: liveTableSQL, decode: GuestH4SavedReceipt.decode)
            return .init(receipt: captured.value, location: captured.path, imageSHA256: captured.imageSHA256, imageBytes: captured.imageBytes)
        }
        fileprivate static func readH8File(_ url: URL, budget: GuestH4SavedReceipt.Budget) throws -> GuestH8Provenance.Snapshot {
            let captured = try readSavedImage(url, budget: budget, table: h8TableSQL) { row in
                let value = try GuestH8Provenance.Projection.decode(json: row.canonicalJSON, cbor: row.canonicalCBOR)
                try value.verifyRetained(row)
                return value
            }
            return .init(projection: captured.value, location: captured.path, imageSHA256: captured.imageSHA256, imageBytes: captured.imageBytes)
        }
        private static func readSavedImage<Value>(_ url: URL, budget: GuestH4SavedReceipt.Budget,
            table: String, decode: (ReopenedDualStreamRowInput) throws -> Value) throws -> Captured<Value> {

            try budget.check()
            let path = url.path
            guard url.isFileURL, path.hasPrefix("/"), !path.utf8.contains(0), path.utf8.count <= 4_096 else {
                throw Failure.storeAdmissionRejected
            }
            var before = stat()
            guard lstat(path, &before) == 0, validFile(before, size: Int(before.st_size)),
                  before.st_size >= pageSize, before.st_size % pageSize == 0,
                  before.st_blocks >= 0, before.st_blocks <= maximumDatabasePages * pageSize / 512 else {
                throw Failure.identityRejected
            }
            var fd = Darwin.open(path, O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC)
            guard fd >= 0 else { throw Failure.finalOpenRejected }
            defer { if fd >= 0 { _ = Darwin.close(fd) } }
            func joined() throws {
                try budget.check()
                var held = stat(), named = stat()
                guard fstat(fd, &held) == 0, lstat(path, &named) == 0,
                      sameFile(before, held), sameFile(held, named),
                      before.st_blocks == held.st_blocks, held.st_blocks == named.st_blocks else {
                    throw Failure.identityRejected
                }
            }
            func read(_ count: Int) throws -> Data {
                var data = Data(count: count), offset = 0, calls = 0
                while offset < count {
                    try budget.check(); calls += 1
                    guard calls <= 1_024 else { throw Failure.readbackRejected }
                    let result = data.withUnsafeMutableBytes {
                        pread(fd, $0.baseAddress!.advanced(by: offset), count - offset, off_t(offset))
                    }
                    if result < 0 && errno == EINTR { continue }
                    guard result > 0 else { throw Failure.readbackRejected }
                    offset += result
                }
                return data
            }
            try joined()
            // Header/page count admission precedes whole-image allocation.
            let header = try read(100)
            guard header.prefix(16) == Data("SQLite format 3\0".utf8),
                  header[16] == 0x10, header[17] == 0, header[18] == 1, header[19] == 1 else {
                throw Failure.serializationRejected
            }
            let pages = UInt32(header[28]) << 24 | UInt32(header[29]) << 16 |
                UInt32(header[30]) << 8 | UInt32(header[31])
            guard pages > 0, Int64(pages) <= maximumDatabasePages, Int64(pages) * pageSize == before.st_size else {
                throw Failure.serializationRejected
            }
            let image = try read(Int(before.st_size))
            var extra: UInt8 = 0
            guard pread(fd, &extra, 1, before.st_size) == 0, image.prefix(100) == header else {
                throw Failure.readbackRejected
            }
            try joined()
            try validateImage(image)
            var db: OpaquePointer? = try openMemory()
            defer { _ = closeExact(&db) }
            sqlite3_progress_handler(db, 1_000, { context in
                guard let context else { return 1 }
                return Unmanaged<GuestH4SavedReceipt.Budget>.fromOpaque(context).takeUnretainedValue().interruptSQLite()
            }, Unmanaged.passUnretained(budget).toOpaque())
            let limits: [(Int32, Int32)] = [
                (SQLITE_LIMIT_LENGTH, 262_144), (SQLITE_LIMIT_SQL_LENGTH, 4_096),
                (SQLITE_LIMIT_COLUMN, 16), (SQLITE_LIMIT_EXPR_DEPTH, 32),
                (SQLITE_LIMIT_COMPOUND_SELECT, 1), (SQLITE_LIMIT_ATTACHED, 0),
                (SQLITE_LIMIT_VDBE_OP, 100_000), (SQLITE_LIMIT_VARIABLE_NUMBER, 8)
            ]
            for (kind, limit) in limits { _ = sqlite3_limit(db, kind, limit) }
            try checked(sqlite3_busy_timeout(db, 0))
            guard let allocation = sqlite3_malloc64(UInt64(image.count)) else { throw Failure.reconstructionRejected }
            image.copyBytes(to: allocation.assumingMemoryBound(to: UInt8.self), count: image.count)
            try checked(epr_sqlite_deserialize_readonly(UnsafeMutableRawPointer(db),
                allocation.assumingMemoryBound(to: UInt8.self), Int64(image.count)))
            _ = try readerPolicy(db)
            guard try textScalar(db, "PRAGMA integrity_check(1)") == "ok" else { throw Failure.reconstructionRejected }
            try validateSchema(db, expectedSQL: table)
            try checked(epr_sqlite_install_readonly_authorizer(UnsafeMutableRawPointer(db)))
            let row = try savedRow(db)
            let receipt = try decode(row)
            guard closeExact(&db) else { throw Failure.closeRejected }
            #if EPR_H4_PRIVACY_TESTS
            try budget.afterCapture?()
            #endif
            try joined()
            let closed = Darwin.close(fd); fd = -1
            guard closed == 0 else { throw Failure.closeRejected }
            try budget.check()
            return Captured(value: receipt, path: path, imageSHA256: GuestContract.hash(image), imageBytes: image.count)
        }

        private static func savedRow(_ db: OpaquePointer?) throws -> ReopenedDualStreamRowInput {
            let statement = try prepare(db, rowSQL)
            var finalized = false
            defer { if !finalized { _ = sqlite3_finalize(statement) } }
            guard sqlite3_step(statement) == SQLITE_ROW,
                  sqlite3_column_type(statement, 0) == SQLITE_INTEGER, sqlite3_column_int64(statement, 0) == 1,
                  sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                  sqlite3_column_type(statement, 5) == SQLITE_BLOB, sqlite3_column_type(statement, 6) == SQLITE_BLOB else {
                throw Failure.reconstructionRejected
            }
            let row = ReopenedDualStreamRowInput(
                canonicalJSON: try blob(statement, 5, maximum: GuestH3LivePersistence.maximumStreamBytes),
                canonicalCBOR: try blob(statement, 6, maximum: GuestH3LivePersistence.maximumStreamBytes),
                semanticSchema: try text(statement, 1), claimState: try text(statement, 2),
                predicateCount: sqlite3_column_int64(statement, 3), authorityVector: try text(statement, 4))
            guard sqlite3_step(statement) == SQLITE_DONE else { throw Failure.reconstructionRejected }
            let status = sqlite3_finalize(statement); finalized = true
            guard status == SQLITE_OK else { throw Failure.closeRejected }
            return row
        }
        #endif

        private static func exec(_ db: OpaquePointer?, _ sql: String) throws {
            var error: UnsafeMutablePointer<CChar>?
            let result = sqlite3_exec(db, sql, nil, nil, &error)
            if let error { sqlite3_free(error) }
            guard result == SQLITE_OK else { throw Failure.transactionRejected }
        }

        #if EPR_H4_PRIVACY_TESTS
        private static func updateBlob(_ db: OpaquePointer?, column: String,
                                       value: Data) throws {
            let allowed = ["canonical_json", "canonical_cbor"]
            guard allowed.contains(column) else { throw Failure.reconstructionRejected }
            let statement = try prepare(db,
                "UPDATE h4_dual_receipts SET \(column)=? WHERE singleton=1")
            defer { sqlite3_finalize(statement) }
            try bind(value, 1, statement)
            guard sqlite3_step(statement) == SQLITE_DONE,
                  sqlite3_changes(db) == 1 else {
                throw Failure.reconstructionRejected
            }
        }

        private static func appendBlobByte(_ db: OpaquePointer?, column: String,
                                           byte: UInt8) throws {
            let statement = try prepare(db,
                "SELECT \(column) FROM h4_dual_receipts WHERE singleton=1")
            defer { sqlite3_finalize(statement) }
            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw Failure.reconstructionRejected
            }
            var value = try blob(statement, 0)
            value.append(byte)
            try updateBlob(db, column: column, value: value)
        }

        private static func verifyReaderPolicy(_ db: OpaquePointer?) throws {
            guard try integer(db, "PRAGMA query_only") == 1,
                  try integer(db, "PRAGMA trusted_schema") == 0 else {
                throw Failure.sqlitePolicyRejected
            }
            try verifyReaderFilename(db, requireEmpty: true)
        }

        private static func verifyReaderFilename(_ db: OpaquePointer?,
                                                 requireEmpty: Bool) throws {
            guard let filename = sqlite3_db_filename(db, "main") else {
                throw Failure.sqlitePolicyRejected
            }
            guard (filename.pointee == 0) == requireEmpty else {
                throw Failure.sqlitePolicyRejected
            }
        }
        #endif
        private static func prepare(_ db: OpaquePointer?, _ sql: String) throws -> OpaquePointer {
            var st: OpaquePointer?
            guard sqlite3_prepare_v3(db, sql, -1, UInt32(SQLITE_PREPARE_PERSISTENT), &st, nil) == SQLITE_OK,
                  let st else { throw Failure.reconstructionRejected }
            return st
        }
        private static func integer(_ db: OpaquePointer?, _ sql: String) throws -> Int64 {
            let st = try prepare(db, sql); defer { sqlite3_finalize(st) }
            guard sqlite3_step(st) == SQLITE_ROW,
                  sqlite3_column_type(st, 0) == SQLITE_INTEGER else {
                throw Failure.reconstructionRejected
            }
            return sqlite3_column_int64(st, 0)
        }
        private static func textScalar(_ db: OpaquePointer?, _ sql: String) throws -> String {
            let st = try prepare(db, sql); defer { sqlite3_finalize(st) }
            guard sqlite3_step(st) == SQLITE_ROW else { throw Failure.reconstructionRejected }
            return try text(st, 0)
        }
        private static func text(_ st: OpaquePointer?, _ column: Int32) throws -> String {
            guard sqlite3_column_type(st, column) == SQLITE_TEXT,
                  let p = sqlite3_column_text(st, column),
                  let value = String(bytes: UnsafeBufferPointer(start: p,
                    count: Int(sqlite3_column_bytes(st, column))), encoding: .utf8) else {
                throw Failure.reconstructionRejected
            }
            return value
        }
        private static func blob(_ st: OpaquePointer?, _ column: Int32,
                                 maximum: Int = H4C.maximumStreamBytes) throws -> Data {
            let count = Int(sqlite3_column_bytes(st, column))
            guard count > 0, count <= maximum,
                  let p = sqlite3_column_blob(st, column) else {
                throw Failure.reconstructionRejected
            }
            return Data(bytes: p, count: count)
        }
        private static func bind(_ value: String, _ index: Int32,
                                 _ st: OpaquePointer?) throws {
            let result = value.withCString {
                sqlite3_bind_text(st, index, $0, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            }
            try checked(result)
        }
        private static func bind(_ value: Data, _ index: Int32,
                                 _ st: OpaquePointer?) throws {
            let result = value.withUnsafeBytes {
                sqlite3_bind_blob(st, index, $0.baseAddress, Int32(value.count),
                    unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            }
            try checked(result)
        }
        private static func checked(_ value: Int32) throws {
            guard value == SQLITE_OK else { throw Failure.sqlitePolicyRejected }
        }
        private struct ReadObservation {
            let requestedCount: Int
            let firstPreadReturn: Int
            let fstatReturn: Int32
            let observedSize: Int64
            let eofPreadReturn: Int
            let bytesEqualExpected: Bool
        }

        /// Finalizes every unexpectedly live statement for containment, closes
        /// the database, and still reports a non-exact close to the caller.
        private static func closeExact(
            _ db: inout OpaquePointer?,
            containedStatements: ((UInt32) -> Void)? = nil
        ) -> Bool {
            guard let current = db else { return true }
            var statement = sqlite3_next_stmt(current, nil)
            var count: UInt32 = 0
            var finalizationExact = true
            while let live = statement {
                statement = sqlite3_next_stmt(current, live)
                count &+= 1
                if sqlite3_finalize(live) != SQLITE_OK {
                    finalizationExact = false
                }
            }
            let closeResult = sqlite3_close(current)
            if closeResult == SQLITE_OK {
                db = nil
            } else if sqlite3_close_v2(current) == SQLITE_OK {
                // No caller retains the handle after containment scheduling.
                db = nil
            }
            if count > 0 { containedStatements?(count) }
            return count == 0 && finalizationExact && closeResult == SQLITE_OK
        }
        private static func readExact(
            _ fd: Int32,
            _ count: Int,
            expected: Data? = nil,
            afterRead: (() throws -> Void)? = nil,
            observe: ((ReadObservation) -> Void)? = nil
        ) throws -> Data {
            guard count > 0,
                  count <= Int(maximumDatabasePages * pageSize) else {
                throw Failure.readbackRejected
            }
            var data = Data(count: count)
            var offset = 0
            var firstRead: Int?
            var readFailed = false
            while offset < count {
                let result = data.withUnsafeMutableBytes {
                    pread(
                        fd,
                        $0.baseAddress?.advanced(by: offset),
                        count - offset,
                        off_t(offset)
                    )
                }
                if result < 0, errno == EINTR { continue }
                if firstRead == nil { firstRead = result }
                guard result > 0 else {
                    readFailed = true
                    break
                }
                offset += result
            }
            try afterRead?()
            var byte: UInt8 = 0
            var metadata = stat()
            let statResult = fstat(fd, &metadata)
            var eofResult: Int
            repeat {
                eofResult = pread(fd, &byte, 1, off_t(count))
            } while eofResult < 0 && errno == EINTR
            observe?(.init(
                requestedCount: count,
                firstPreadReturn: firstRead ?? 0,
                fstatReturn: statResult,
                observedSize: statResult == 0 ? Int64(metadata.st_size) : -1,
                eofPreadReturn: eofResult,
                bytesEqualExpected: expected.map { data == $0 } ?? false))
            guard !readFailed, offset == count, statResult == 0,
                  metadata.st_size == count,
                  eofResult == 0 else {
                throw Failure.readbackRejected
            }
            return data
        }
        private static func validFile(_ s: stat, size: Int) -> Bool {
            size > 0 && size <= Int(maximumDatabasePages * pageSize) &&
                s.st_mode & S_IFMT == S_IFREG &&
                s.st_mode & 0o7777 == 0o400 &&
                s.st_uid == geteuid() && s.st_nlink == 1 && s.st_size == size
        }
        private static func validRetainedFile(_ s: stat) -> Bool {
            let permissions = s.st_mode & 0o7777
            return s.st_mode & S_IFMT == S_IFREG &&
                (permissions == 0o600 || permissions == 0o400) &&
                s.st_uid == geteuid() && s.st_nlink == 1 &&
                s.st_size >= 0 &&
                s.st_size <= off_t(maximumDatabasePages * pageSize)
        }
        private static func statLeaf(_ leaf: String, _ root: Int32,
                                     _ value: inout stat) -> Bool {
            leaf.withCString {
                fstatat(root, $0, &value, AT_SYMLINK_NOFOLLOW) == 0
            }
        }
        private static func sameAcrossRename(_ a: stat, _ b: stat) -> Bool {
            a.st_dev == b.st_dev && a.st_ino == b.st_ino &&
                a.st_mode == b.st_mode && a.st_uid == b.st_uid &&
                a.st_gid == b.st_gid && a.st_nlink == b.st_nlink &&
                a.st_size == b.st_size && a.st_flags == b.st_flags &&
                a.st_mtimespec.tv_sec == b.st_mtimespec.tv_sec &&
                a.st_mtimespec.tv_nsec == b.st_mtimespec.tv_nsec
        }
        private static func sameFile(_ a: stat, _ b: stat) -> Bool {
            sameAcrossRename(a, b) &&
                a.st_ctimespec.tv_sec == b.st_ctimespec.tv_sec &&
                a.st_ctimespec.tv_nsec == b.st_ctimespec.tv_nsec
        }

        private func validateRoot(expected: Set<String>) throws {
            #if EPR_H4_LIVE
            try root.ancestry?.validate()
            #endif
            var named = stat(); var held = stat()
            guard lstat(root.path, &named) == 0,
                  fstat(root.descriptor, &held) == 0,
                  Self.sameRoot(named, held), Self.validRoot(held),
                  try Self.directoryEntries(root.descriptor) == expected else {
                throw Failure.storeAdmissionRejected
            }
        }

        fileprivate static func validRoot(_ value: stat) -> Bool {
            value.st_mode & S_IFMT == S_IFDIR &&
                value.st_mode & 0o7777 == 0o700 && value.st_uid == geteuid()
        }
        fileprivate static func sameRoot(_ a: stat, _ b: stat) -> Bool {
            a.st_dev == b.st_dev && a.st_ino == b.st_ino &&
                a.st_mode == b.st_mode && a.st_uid == b.st_uid &&
                a.st_gid == b.st_gid && a.st_nlink == b.st_nlink &&
                a.st_flags == b.st_flags
        }
        private static func directoryEntries(_ directory: Int32) throws -> Set<String> {
            let scanFD = ".".withCString {
                openat(directory, $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            }
            guard scanFD >= 0 else { throw Failure.storeAdmissionRejected }
            var scan = stat(), held = stat()
            guard fstat(scanFD, &scan) == 0,
                  fstat(directory, &held) == 0,
                  sameRoot(scan, held) else {
                _ = Darwin.close(scanFD)
                throw Failure.storeAdmissionRejected
            }
            guard let stream = fdopendir(scanFD) else {
                _ = Darwin.close(scanFD); throw Failure.storeAdmissionRejected
            }
            var result = Set<String>(); var failed = false
            while true {
                errno = 0
                guard let entry = readdir(stream) else {
                    failed = errno != 0; break
                }
                let capacity = MemoryLayout.size(ofValue: entry.pointee.d_name)
                let name = withUnsafePointer(to: entry.pointee.d_name) { pointer in
                    pointer.withMemoryRebound(to: CChar.self, capacity: capacity) {
                        String(validatingCString: $0)
                    }
                }
                guard let name, !name.isEmpty else { failed = true; break }
                if name == "." || name == ".." { continue }
                guard result.insert(name).inserted, result.count <= 2 else { failed = true; break }
            }
            let closeResult = closedir(stream)
            guard !failed, closeResult == 0 else {
                throw Failure.storeAdmissionRejected
            }
            return result
        }

        #if EPR_H4_PRIVACY_TESTS
        private final class RetainedStateClassifier {
            private enum Rejection: Error {
                case ambiguous
                case representation
            }

            private enum ReadPhase {
                case header
                case image
                case eof
            }

            private struct Row {
                let singleton: Int64
                let semanticSchema: String
                let claimState: String
                let predicateCount: Int64
                let authorityVector: String
                let canonicalJSON: Data
                let canonicalCBOR: Data
            }

            private let rootPath: String
            private let fault: TestRetainedStateFault
            private let hooks: TestRetainedStateHooks

            private var rootDescriptor: Int32 = -1
            private var leafDescriptor: Int32 = -1
            private var database: OpaquePointer?
            private var inventory: [String] = []
            private var rootMetadata: TestRetainedStateMetadata?
            private var leafMetadata: TestRetainedStateMetadata?
            private var byteCount = 0
            private var sha256: String?
            private var databaseReadOnlyDiagnostic: Int32?
            private var databaseWasOpened = false
            private var finalInventory = false
            private var closeFailure = false

            private var rootMetadataExact = false
            private var rootJoinExact = false
            private var inventoryExact = false
            private var leafMetadataExact = false
            private var headerExact = false
            private var pageGeometryExact = false
            private var imageReadExact = false
            private var eofExact = false
            private var vnodeJoinExact = false
            private var sqlitePolicyExact = false
            private var integrityExact = false
            private var schemaExact = false
            private var rowExact = false
            private var canonicalJSONExact = false
            private var canonicalCBORExact = false
            private var indexedScalarsExact = false
            private var representationJoinExact = false

            private var headerInterrupted = false
            private var headerShort = false
            private var imageInterrupted = false
            private var imageShort = false
            private var eofInterrupted = false

            init(
                rootPath: String,
                fault: TestRetainedStateFault,
                hooks: TestRetainedStateHooks
            ) {
                self.rootPath = rootPath
                self.fault = fault
                self.hooks = hooks
            }

            func run() -> TestRetainedStateEvidence {
                var classification: TestRetainedStateClass
                do {
                    classification = try inspect()
                } catch Rejection.representation {
                    classification = finalInventory ?
                        .finalOnlyRejected : .ambiguousOrUnexpected
                } catch {
                    classification = .ambiguousOrUnexpected
                }

                if database != nil, !closeDatabaseExactly() {
                    closeFailure = true
                    classification = finalInventory ?
                        .finalOnlyRejected : .ambiguousOrUnexpected
                }
                if leafDescriptor >= 0 {
                    let descriptor = leafDescriptor
                    leafDescriptor = -1
                    if Darwin.close(descriptor) != 0 ||
                        fault == .leafCloseResponseLost {
                        closeFailure = true
                        classification = .ambiguousOrUnexpected
                    }
                }
                if rootDescriptor >= 0 {
                    let descriptor = rootDescriptor
                    rootDescriptor = -1
                    if Darwin.close(descriptor) != 0 ||
                        fault == .rootCloseResponseLost {
                        closeFailure = true
                        classification = .ambiguousOrUnexpected
                    }
                }

                return TestRetainedStateEvidence(
                    classification: classification,
                    inventory: inventory,
                    rootMetadata: rootMetadata,
                    leafMetadata: leafMetadata,
                    byteCount: byteCount,
                    sha256: sha256,
                    databaseReadOnlyDiagnostic: databaseReadOnlyDiagnostic,
                    predicates: .init(
                        rootMetadataExact: rootMetadataExact,
                        rootJoinExact: rootJoinExact,
                        inventoryExact: inventoryExact,
                        leafMetadataExact: leafMetadataExact,
                        headerExact: headerExact,
                        pageGeometryExact: pageGeometryExact,
                        imageReadExact: imageReadExact,
                        eofExact: eofExact,
                        vnodeJoinExact: vnodeJoinExact,
                        sqlitePolicyExact: sqlitePolicyExact,
                        integrityExact: integrityExact,
                        schemaExact: schemaExact,
                        rowExact: rowExact,
                        canonicalJSONExact: canonicalJSONExact,
                        canonicalCBORExact: canonicalCBORExact,
                        indexedScalarsExact: indexedScalarsExact,
                        representationJoinExact: representationJoinExact,
                        closesExact: !closeFailure
                    )
                )
            }

            private func inspect() throws -> TestRetainedStateClass {
                guard Self.validRootPath(rootPath),
                      let resolved = realpath(rootPath, nil) else {
                    throw Rejection.ambiguous
                }
                let physical = String(validatingCString: resolved)
                free(resolved)
                guard physical == rootPath else { throw Rejection.ambiguous }
                var namedRoot = stat()
                guard lstat(rootPath, &namedRoot) == 0 else {
                    throw Rejection.ambiguous
                }
                rootMetadata = TestRetainedStateMetadata(namedRoot)
                try hooks.afterNamedRootBeforeOpen?()
                guard fault != .rootOpenRejected else {
                    throw Rejection.ambiguous
                }
                rootDescriptor = Darwin.open(
                    rootPath,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                )
                guard rootDescriptor >= 0,
                      fault != .rootLockRejected,
                      flock(rootDescriptor, LOCK_EX | LOCK_NB) == 0 else {
                    throw Rejection.ambiguous
                }
                var heldRoot = stat()
                guard fstat(rootDescriptor, &heldRoot) == 0,
                      Store.validRoot(namedRoot),
                      Store.validRoot(heldRoot),
                      Store.sameRoot(namedRoot, heldRoot) else {
                    throw Rejection.ambiguous
                }
                rootMetadataExact = true

                inventory = try scanInventory()
                try hooks.afterInitialInventory?()
                guard inventory.count <= 1 else {
                    throw Rejection.ambiguous
                }
                if inventory.isEmpty {
                    inventoryExact = true
                    try validateTerminalInventory([])
                    try validateTerminalRoot(namedRoot)
                    return .emptyBeforePublication
                }

                let leaf = inventory[0]
                guard leaf == Store.stagingLeaf || leaf == Store.finalLeaf else {
                    throw Rejection.ambiguous
                }
                inventoryExact = true
                finalInventory = leaf == Store.finalLeaf

                var namedLeaf = stat()
                guard Store.statLeaf(leaf, rootDescriptor, &namedLeaf) else {
                    throw Rejection.ambiguous
                }
                leafMetadata = TestRetainedStateMetadata(namedLeaf)
                try hooks.afterNamedLeafBeforeOpen?()
                guard fault != .leafOpenRejected else {
                    throw Rejection.ambiguous
                }
                leafDescriptor = leaf.withCString {
                    openat(
                        rootDescriptor,
                        $0,
                        O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC
                    )
                }
                guard leafDescriptor >= 0 else { throw Rejection.ambiguous }
                var openedLeaf = stat()
                guard fstat(leafDescriptor, &openedLeaf) == 0,
                      Store.sameFile(namedLeaf, openedLeaf),
                      Self.validLeaf(
                        openedLeaf,
                        final: finalInventory,
                        allowEmpty: !finalInventory
                      ) else {
                    throw Rejection.ambiguous
                }
                leafMetadataExact = true
                guard let count = Int(exactly: openedLeaf.st_size) else {
                    throw Rejection.ambiguous
                }
                byteCount = count

                if count == 0 {
                    guard !finalInventory,
                          openedLeaf.st_mode & 0o7777 == 0o600 else {
                        throw Rejection.ambiguous
                    }
                    try closeLeafAndValidate(
                        leaf: leaf,
                        baseline: openedLeaf,
                        expectedInventory: [leaf]
                    )
                    try validateTerminalRoot(namedRoot)
                    return .stagingOnlyEmpty0600
                }

                do {
                    var header = [UInt8](repeating: 0, count: 100)
                    try readFully(
                        into: &header,
                        descriptor: leafDescriptor,
                        phase: .header
                    )
                    try hooks.afterHeaderReadBeforeMetadataJoin?()
                    try validateLeafJoin(leaf: leaf, baseline: openedLeaf)
                    try validateHeader(header, imageCount: count)

                    guard fault != .imageAllocationRejected else {
                        throw representationRejection()
                    }
                    var image = Data(count: count)
                    try readFully(
                        into: &image,
                        descriptor: leafDescriptor,
                        phase: .image
                    )
                    imageReadExact = true
                    try readEOF(descriptor: leafDescriptor, offset: count)
                    eofExact = true
                    try hooks.afterImageReadBeforeMetadataJoin?()
                    try validateLeafJoin(leaf: leaf, baseline: openedLeaf)
                    guard image.prefix(header.count).elementsEqual(header) else {
                        throw representationRejection()
                    }
                    sha256 = SHA256.hash(data: image).map {
                        String(format: "%02x", $0)
                    }.joined()

                    try inspectRepresentation(image)
                } catch Rejection.representation {
                    if database != nil { _ = closeDatabaseExactly() }
                    if databaseWasOpened {
                        try hooks.afterSQLiteCloseBeforeFinalJoin?()
                    }
                    try closeLeafAndValidate(
                        leaf: leaf,
                        baseline: openedLeaf,
                        expectedInventory: [leaf]
                    )
                    try validateTerminalRoot(namedRoot)
                    throw Rejection.representation
                }
                try hooks.afterSQLiteCloseBeforeFinalJoin?()
                try closeLeafAndValidate(
                    leaf: leaf,
                    baseline: openedLeaf,
                    expectedInventory: [leaf]
                )
                try validateTerminalRoot(namedRoot)

                if finalInventory { return .finalOnlyValidV3 }
                return openedLeaf.st_mode & 0o7777 == 0o600 ?
                    .stagingOnlyValidV30600 : .stagingOnlyValidV30400
            }

            private func representationRejection() -> Rejection {
                .representation
            }

            private static func validRootPath(_ path: String) -> Bool {
                guard path.hasPrefix("/"), path != "/", !path.hasSuffix("/"),
                      !path.utf8.contains(0), !path.contains("//") else {
                    return false
                }
                return !path.split(separator: "/", omittingEmptySubsequences: false)
                    .contains { $0 == "." || $0 == ".." }
            }

            private static func validLeaf(
                _ value: stat,
                final: Bool,
                allowEmpty: Bool
            ) -> Bool {
                let mode = value.st_mode & 0o7777
                guard value.st_mode & S_IFMT == S_IFREG,
                      value.st_uid == geteuid(), value.st_nlink == 1 else {
                    return false
                }
                if value.st_size == 0 {
                    return allowEmpty && mode == 0o600
                }
                guard value.st_size >= 100,
                      value.st_size <= maximumDatabasePages * pageSize,
                      value.st_size % pageSize == 0 else {
                    return false
                }
                return final ? mode == 0o400 : (mode == 0o600 || mode == 0o400)
            }

            private func scanInventory() throws -> [String] {
                guard fault != .directoryScanRejected else {
                    throw Rejection.ambiguous
                }
                let scanDescriptor = ".".withCString {
                    openat(
                        rootDescriptor,
                        $0,
                        O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                    )
                }
                guard scanDescriptor >= 0 else { throw Rejection.ambiguous }
                var scanRoot = stat(), heldRoot = stat()
                guard fstat(scanDescriptor, &scanRoot) == 0,
                      fstat(rootDescriptor, &heldRoot) == 0,
                      Store.sameRoot(scanRoot, heldRoot) else {
                    if Darwin.close(scanDescriptor) != 0 { closeFailure = true }
                    throw Rejection.ambiguous
                }
                guard let stream = fdopendir(scanDescriptor) else {
                    if Darwin.close(scanDescriptor) != 0 { closeFailure = true }
                    throw Rejection.ambiguous
                }
                var entries: [String] = []
                var failed = false
                while entries.count < 2 {
                    errno = 0
                    guard let entry = readdir(stream) else {
                        failed = errno != 0
                        break
                    }
                    let capacity = MemoryLayout.size(ofValue: entry.pointee.d_name)
                    let name = withUnsafePointer(to: entry.pointee.d_name) {
                        pointer in
                        pointer.withMemoryRebound(
                            to: CChar.self,
                            capacity: capacity
                        ) { String(validatingCString: $0) }
                    }
                    guard let name, !name.isEmpty else {
                        failed = true
                        break
                    }
                    if name == "." || name == ".." { continue }
                    entries.append(name)
                }
                let closeResult = closedir(stream)
                if closeResult != 0 || fault == .inventoryCloseResponseLost {
                    closeFailure = true
                }
                guard !failed, closeResult == 0,
                      fault != .inventoryCloseResponseLost else {
                    throw Rejection.ambiguous
                }
                return entries.sorted()
            }

            private func validateTerminalInventory(_ expected: [String]) throws {
                let terminal = try scanInventory()
                guard terminal == expected.sorted() else {
                    throw Rejection.ambiguous
                }
            }

            private func validateTerminalRoot(_ baseline: stat) throws {
                var named = stat(), held = stat()
                guard lstat(rootPath, &named) == 0,
                      fstat(rootDescriptor, &held) == 0,
                      Store.validRoot(named), Store.validRoot(held),
                      Store.sameRoot(baseline, named),
                      Store.sameRoot(named, held) else {
                    throw Rejection.ambiguous
                }
                rootJoinExact = true
            }

            private func validateLeafJoin(leaf: String, baseline: stat) throws {
                var named = stat(), held = stat()
                guard Store.statLeaf(leaf, rootDescriptor, &named),
                      fstat(leafDescriptor, &held) == 0,
                      Store.sameFile(baseline, named),
                      Store.sameFile(named, held),
                      Self.validLeaf(
                        held,
                        final: finalInventory,
                        allowEmpty: !finalInventory
                      ) else {
                    throw Rejection.ambiguous
                }
            }

            private func closeLeafAndValidate(
                leaf: String,
                baseline: stat,
                expectedInventory: [String]
            ) throws {
                try validateLeafJoin(leaf: leaf, baseline: baseline)
                try hooks.afterPrecloseLeafJoin?()
                let descriptor = leafDescriptor
                leafDescriptor = -1
                guard Darwin.close(descriptor) == 0,
                      fault != .leafCloseResponseLost else {
                    closeFailure = true
                    throw Rejection.ambiguous
                }
                try hooks.afterLeafCloseBeforeNamedJoin?()
                var namedAfter = stat()
                guard Store.statLeaf(leaf, rootDescriptor, &namedAfter),
                      Store.sameFile(baseline, namedAfter),
                      Self.validLeaf(
                        namedAfter,
                        final: finalInventory,
                        allowEmpty: !finalInventory
                      ) else {
                    throw Rejection.ambiguous
                }
                try hooks.afterPostcloseNamedJoinBeforeTerminal?()
                try validateTerminalInventory(expectedInventory)
                var terminalNamed = stat()
                guard Store.statLeaf(leaf, rootDescriptor, &terminalNamed),
                      Store.sameFile(baseline, terminalNamed),
                      Self.validLeaf(
                        terminalNamed,
                        final: finalInventory,
                        allowEmpty: !finalInventory
                      ) else {
                    throw Rejection.ambiguous
                }
                vnodeJoinExact = true
            }

            private func validateHeader(_ header: [UInt8], imageCount: Int) throws {
                let magic = Array("SQLite format 3\0".utf8)
                guard header.count == 100,
                      header.prefix(magic.count).elementsEqual(magic),
                      header[16] == 0x10, header[17] == 0x00,
                      header[18] == 0x01, header[19] == 0x01 else {
                    throw representationRejection()
                }
                headerExact = true
                let pages = UInt64(header[28]) << 24 |
                    UInt64(header[29]) << 16 |
                    UInt64(header[30]) << 8 |
                    UInt64(header[31])
                let multiplication = pages.multipliedReportingOverflow(
                    by: UInt64(pageSize)
                )
                guard pages >= 1, pages <= UInt64(maximumDatabasePages),
                      !multiplication.overflow,
                      multiplication.partialValue == UInt64(imageCount) else {
                    throw representationRejection()
                }
                pageGeometryExact = true
            }

            private func readFully(
                into bytes: inout [UInt8],
                descriptor: Int32,
                phase: ReadPhase
            ) throws {
                let count = bytes.count
                try bytes.withUnsafeMutableBytes {
                    try readFully(
                        buffer: $0.baseAddress,
                        count: count,
                        descriptor: descriptor,
                        phase: phase
                    )
                }
            }

            private func readFully(
                into data: inout Data,
                descriptor: Int32,
                phase: ReadPhase
            ) throws {
                let count = data.count
                try data.withUnsafeMutableBytes {
                    try readFully(
                        buffer: $0.baseAddress,
                        count: count,
                        descriptor: descriptor,
                        phase: phase
                    )
                }
            }

            private func readFully(
                buffer: UnsafeMutableRawPointer?,
                count: Int,
                descriptor: Int32,
                phase: ReadPhase
            ) throws {
                guard let buffer, count > 0 else {
                    throw representationRejection()
                }
                var offset = 0
                while offset < count {
                    let result = controlledPread(
                        descriptor,
                        buffer.advanced(by: offset),
                        count - offset,
                        off_t(offset),
                        phase: phase
                    )
                    if result < 0 && errno == EINTR { continue }
                    guard result > 0, result <= count - offset else {
                        throw representationRejection()
                    }
                    offset += result
                }
            }

            private func readEOF(descriptor: Int32, offset: Int) throws {
                var byte: UInt8 = 0
                while true {
                    let result = controlledPread(
                        descriptor,
                        &byte,
                        1,
                        off_t(offset),
                        phase: .eof
                    )
                    if result < 0 && errno == EINTR { continue }
                    guard result == 0 else { throw representationRejection() }
                    return
                }
            }

            private func controlledPread(
                _ descriptor: Int32,
                _ buffer: UnsafeMutableRawPointer,
                _ count: Int,
                _ offset: off_t,
                phase: ReadPhase
            ) -> Int {
                switch (phase, fault) {
                case (.header, .headerReadInterruptedOnce) where !headerInterrupted:
                    headerInterrupted = true
                    errno = EINTR
                    return -1
                case (.header, .headerReadShortOnce) where !headerShort:
                    headerShort = true
                    return pread(descriptor, buffer, max(1, count / 2), offset)
                case (.header, .headerReadZero): return 0
                case (.header, .headerReadRejected):
                    errno = EIO
                    return -1
                case (.image, .imageReadInterruptedOnce) where !imageInterrupted:
                    imageInterrupted = true
                    errno = EINTR
                    return -1
                case (.image, .imageReadShortOnce) where !imageShort:
                    imageShort = true
                    return pread(descriptor, buffer, max(1, count / 2), offset)
                case (.image, .imageReadZero): return 0
                case (.image, .imageReadRejected):
                    errno = EIO
                    return -1
                case (.eof, .eofReadInterruptedOnce) where !eofInterrupted:
                    eofInterrupted = true
                    errno = EINTR
                    return -1
                case (.eof, .eofReadNonzero):
                    buffer.storeBytes(of: UInt8(0xa5), as: UInt8.self)
                    return 1
                default:
                    return pread(descriptor, buffer, count, offset)
                }
            }

            private func inspectRepresentation(_ image: Data) throws {
                guard fault != .sqliteOpenRejected else {
                    throw representationRejection()
                }
                do {
                    database = try Store.openMemory()
                } catch {
                    throw representationRejection()
                }
                databaseWasOpened = true
                guard fault != .sqliteAllocationRejected,
                      let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                    throw representationRejection()
                }
                if fault == .deserializeRejected {
                    sqlite3_free(allocation)
                    throw representationRejection()
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
                    throw representationRejection()
                }

                try configureReader()
                guard fault != .integrityRejected,
                      try scalarText(
                        "PRAGMA integrity_check(1)",
                        maximum: 128
                      ) == "ok" else {
                    throw representationRejection()
                }
                integrityExact = true
                guard fault != .schemaRejected else {
                    throw representationRejection()
                }
                try validateSchema()
                schemaExact = true
                guard fault != .authorizerRejected,
                      epr_sqlite_install_readonly_authorizer(
                        UnsafeMutableRawPointer(database)
                      ) == SQLITE_OK else {
                    throw representationRejection()
                }
                guard fault != .rowRejected else {
                    throw representationRejection()
                }
                let row = try readRow()
                rowExact = true
                try joinRepresentations(row)
                if fault == .statementLeak {
                    var leaked: OpaquePointer?
                    guard sqlite3_prepare_v3(
                        database,
                        "SELECT 1",
                        -1,
                        UInt32(SQLITE_PREPARE_NO_VTAB | SQLITE_PREPARE_DONT_LOG),
                        &leaked,
                        nil
                    ) == SQLITE_OK, leaked != nil else {
                        throw representationRejection()
                    }
                }
                guard closeDatabaseExactly() else {
                    throw representationRejection()
                }
            }

            private func configureReader() throws {
                guard let database,
                      sqlite3_extended_result_codes(database, 1) == SQLITE_OK,
                      sqlite3_busy_timeout(database, 0) == SQLITE_OK else {
                    throw representationRejection()
                }
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
                        throw representationRejection()
                    }
                }
                guard fault != .readerHardeningRejected else {
                    throw representationRejection()
                }
                var policy = EPRSQLiteReadOnlyPolicy()
                guard epr_sqlite_harden_readonly(
                    UnsafeMutableRawPointer(database),
                    &policy
                ) == SQLITE_OK,
                      policy.defensive == 1,
                      policy.trusted_schema == 0,
                      policy.dqs_ddl == 0,
                      policy.dqs_dml == 0 else {
                    throw representationRejection()
                }
                try applyConnectionSetting("PRAGMA query_only=ON")
                try applyConnectionSetting("PRAGMA trusted_schema=OFF")
                try applyConnectionSetting("PRAGMA temp_store=MEMORY")
                try applyConnectionSetting("PRAGMA foreign_keys=ON")
                try applyConnectionSetting("PRAGMA cell_size_check=ON")
                if fault == .queryOnlyRejected {
                    try applyConnectionSetting("PRAGMA query_only=OFF")
                }
                let queryOnly = try scalarInteger("PRAGMA query_only")
                let trustedSchema = try scalarInteger("PRAGMA trusted_schema")
                let tempStore = try scalarInteger("PRAGMA temp_store")
                let foreignKeys = try scalarInteger("PRAGMA foreign_keys")
                let cellSizeCheck = try scalarInteger("PRAGMA cell_size_check")
                let autocommit = sqlite3_get_autocommit(database) == 1
                let transactionNone =
                    sqlite3_txn_state(database, "main") == SQLITE_TXN_NONE
                let filenameEmpty =
                    sqlite3_db_filename(database, "main")?.pointee == 0
                databaseReadOnlyDiagnostic = sqlite3_db_readonly(database, "main")
                guard fault != .filenameRejected,
                      queryOnly == 1, trustedSchema == 0,
                      tempStore == 2, foreignKeys == 1, cellSizeCheck == 1,
                      autocommit, transactionNone, filenameEmpty else {
                    throw representationRejection()
                }
                sqlitePolicyExact = true
            }

            private func applyConnectionSetting(_ sql: String) throws {
                try withStatement(sql) { statement in
                    guard sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                }
            }

            private func validateSchema() throws {
                guard try scalarInteger("PRAGMA page_size") == pageSize,
                      try scalarInteger("PRAGMA user_version") == userVersion,
                      try scalarInteger("PRAGMA application_id") == applicationID else {
                    throw representationRejection()
                }
                try withStatement(
                    "SELECT type,name,tbl_name,rootpage,sql FROM sqlite_schema LIMIT 2"
                ) { statement in
                    guard sqlite3_column_count(statement) == 5,
                          sqlite3_step(statement) == SQLITE_ROW,
                          try text(statement, column: 0, maximum: 16) == "table",
                          try text(statement, column: 1, maximum: 64) == Store.tableName,
                          try text(statement, column: 2, maximum: 64) == Store.tableName,
                          sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                          sqlite3_column_int64(statement, 3) > 0,
                          try text(statement, column: 4, maximum: 1_024) == Store.tableSQL,
                          sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                }
                let columns: [(String, String, Int64)] = [
                    ("singleton", "INTEGER", 1),
                    ("semantic_schema", "TEXT", 0),
                    ("claim_state", "TEXT", 0),
                    ("predicate_count", "INTEGER", 0),
                    ("authority_vector", "TEXT", 0),
                    ("canonical_json", "BLOB", 0),
                    ("canonical_cbor", "BLOB", 0),
                ]
                try withStatement("PRAGMA table_xinfo(h4_dual_receipts)") {
                    statement in
                    guard sqlite3_column_count(statement) == 7 else {
                        throw Rejection.representation
                    }
                    for (index, column) in columns.enumerated() {
                        guard sqlite3_step(statement) == SQLITE_ROW,
                              sqlite3_column_type(statement, 0) == SQLITE_INTEGER,
                              sqlite3_column_int64(statement, 0) == Int64(index),
                              try text(statement, column: 1, maximum: 64) == column.0,
                              try text(statement, column: 2, maximum: 16) == column.1,
                              sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                              sqlite3_column_int64(statement, 3) == 1,
                              sqlite3_column_type(statement, 4) == SQLITE_NULL,
                              sqlite3_column_type(statement, 5) == SQLITE_INTEGER,
                              sqlite3_column_int64(statement, 5) == column.2,
                              sqlite3_column_type(statement, 6) == SQLITE_INTEGER,
                              sqlite3_column_int64(statement, 6) == 0 else {
                            throw Rejection.representation
                        }
                    }
                    guard sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                }
            }

            private func readRow() throws -> Row {
                try withStatement(Store.rowSQL) { statement in
                    guard sqlite3_column_count(statement) == 7,
                          sqlite3_step(statement) == SQLITE_ROW,
                          sqlite3_column_type(statement, 0) == SQLITE_INTEGER,
                          sqlite3_column_type(statement, 1) == SQLITE_TEXT,
                          sqlite3_column_type(statement, 2) == SQLITE_TEXT,
                          sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                          sqlite3_column_type(statement, 4) == SQLITE_TEXT,
                          sqlite3_column_type(statement, 5) == SQLITE_BLOB,
                          sqlite3_column_type(statement, 6) == SQLITE_BLOB else {
                        throw Rejection.representation
                    }
                    let row = Row(
                        singleton: sqlite3_column_int64(statement, 0),
                        semanticSchema: try text(
                            statement, column: 1, maximum: 128
                        ),
                        claimState: try text(
                            statement, column: 2, maximum: 32
                        ),
                        predicateCount: sqlite3_column_int64(statement, 3),
                        authorityVector: try text(
                            statement, column: 4, maximum: 16
                        ),
                        canonicalJSON: try blob(statement, column: 5),
                        canonicalCBOR: try blob(statement, column: 6)
                    )
                    guard sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                    return row
                }
            }

            private func joinRepresentations(_ row: Row) throws {
                guard fault != .jsonRejected, fault != .cborRejected else {
                    throw representationRejection()
                }
                let receipt: H4C.ReconstructionReceipt
                do {
                    receipt = try H4C.reconstructTest(
                        json: row.canonicalJSON,
                        cbor: row.canonicalCBOR
                    )
                } catch {
                    throw representationRejection()
                }
                canonicalJSONExact = true
                canonicalCBORExact = true
                let semantic = receipt.semantic
                guard fault != .scalarRejected,
                      row.singleton == 1,
                      row.semanticSchema == H4C.semanticSchema,
                      row.claimState == HypervisorStageH4Privacy
                        .ClaimState.observedNonPass.rawValue,
                      row.predicateCount == 19,
                      row.authorityVector == "00000000",
                      semantic.schema == row.semanticSchema,
                      semantic.claimState.rawValue == row.claimState,
                      Int64(semantic.predicateCount) == row.predicateCount,
                      semantic.authorityVector == row.authorityVector else {
                    throw representationRejection()
                }
                indexedScalarsExact = true
                representationJoinExact = true
            }

            private func withStatement<T>(
                _ sql: String,
                body: (OpaquePointer) throws -> T
            ) throws -> T {
                var statement: OpaquePointer?
                let flags = UInt32(
                    SQLITE_PREPARE_NO_VTAB | SQLITE_PREPARE_DONT_LOG
                )
                guard sqlite3_prepare_v3(
                    database, sql, -1, flags, &statement, nil
                ) == SQLITE_OK, let statement else {
                    throw representationRejection()
                }
                let value: T
                do {
                    value = try body(statement)
                } catch {
                    let bodyError = error
                    let finalizeStatus = sqlite3_finalize(statement)
                    guard finalizeStatus == SQLITE_OK else {
                        closeFailure = true
                        throw Rejection.representation
                    }
                    throw bodyError
                }
                guard sqlite3_finalize(statement) == SQLITE_OK else {
                    closeFailure = true
                    throw representationRejection()
                }
                return value
            }

            private func scalarInteger(_ sql: String) throws -> Int64 {
                try withStatement(sql) { statement in
                    guard sqlite3_step(statement) == SQLITE_ROW,
                          sqlite3_column_type(statement, 0) == SQLITE_INTEGER else {
                        throw Rejection.representation
                    }
                    let value = sqlite3_column_int64(statement, 0)
                    guard sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                    return value
                }
            }

            private func scalarText(
                _ sql: String,
                maximum: Int
            ) throws -> String {
                try withStatement(sql) { statement in
                    guard sqlite3_step(statement) == SQLITE_ROW else {
                        throw Rejection.representation
                    }
                    let value = try text(statement, column: 0, maximum: maximum)
                    guard sqlite3_step(statement) == SQLITE_DONE else {
                        throw Rejection.representation
                    }
                    return value
                }
            }

            private func text(
                _ statement: OpaquePointer,
                column: Int32,
                maximum: Int
            ) throws -> String {
                guard sqlite3_column_type(statement, column) == SQLITE_TEXT else {
                    throw representationRejection()
                }
                let count = Int(sqlite3_column_bytes(statement, column))
                guard count > 0, count <= maximum,
                      let pointer = sqlite3_column_text(statement, column),
                      let value = String(
                        data: Data(bytes: pointer, count: count),
                        encoding: .utf8
                      ), !value.utf8.contains(0) else {
                    throw representationRejection()
                }
                return value
            }

            private func blob(
                _ statement: OpaquePointer,
                column: Int32
            ) throws -> Data {
                guard sqlite3_column_type(statement, column) == SQLITE_BLOB else {
                    throw representationRejection()
                }
                let count = Int(sqlite3_column_bytes(statement, column))
                guard count > 0, count <= H4C.maximumStreamBytes,
                      let pointer = sqlite3_column_blob(statement, column) else {
                    throw representationRejection()
                }
                return Data(bytes: pointer, count: count)
            }

            private func closeDatabaseExactly() -> Bool {
                guard let current = database else { return true }
                var statement = sqlite3_next_stmt(current, nil)
                var statementCount = 0
                var finalizationExact = true
                while let live = statement {
                    statement = sqlite3_next_stmt(current, live)
                    statementCount += 1
                    if sqlite3_finalize(live) != SQLITE_OK {
                        finalizationExact = false
                    }
                }
                let closeStatus = sqlite3_close(current)
                if closeStatus != SQLITE_OK { _ = sqlite3_close_v2(current) }
                database = nil
                let exact = statementCount == 0 && finalizationExact &&
                    closeStatus == SQLITE_OK &&
                    fault != .databaseCloseResponseLost
                if !exact { closeFailure = true }
                return exact
            }
        }

        fileprivate static func classifyRetainedState(
            rootPath: String,
            fault: TestRetainedStateFault,
            hooks: TestRetainedStateHooks
        ) -> TestRetainedStateEvidence {
            RetainedStateClassifier(
                rootPath: rootPath,
                fault: fault,
                hooks: hooks
            ).run()
        }

        fileprivate static func make(rootURL: URL, fault: TestFault,
                                     calls: TestEnteredCalls,
                                     publicationInterstice:
                                        TestPublicationIntersticeCallback?) throws -> Store {
            try Store(root: RootCapability.admit(rootURL),
                      fault: Fault(fault), calls: calls,
                      publicationInterstice: publicationInterstice)
        }

        fileprivate static func inspect(rootURL: URL) throws -> TestStoreSnapshot {
            let root = try RootCapability.admit(rootURL, acquireLease: false)
            let entries = try directoryEntries(root.descriptor).sorted()
            guard entries == [finalLeafName] else {
                return TestStoreSnapshot(inventory: entries, published: false,
                    fileMode: nil, fileSize: nil, headerExact: false,
                    userVersion: 0, applicationID: 0, schemaEntryCount: 0,
                    rowCount: 0, singleton: 0, semanticSchema: "",
                    claimState: "", predicateCount: 0, authorityVector: "",
                    canonicalJSON: Data(), canonicalCBOR: Data(),
                    storageClasses: [], queryOnly: false, defensive: false,
                    trustedSchema: false, dqsDDL: false, dqsDML: false,
                    tempStoreMemory: false, foreignKeys: false,
                    autocommit: false, transactionNone: false,
                    filenameEmpty: false)
            }
            var namedBefore = stat()
            guard statLeaf(finalLeafName, root.descriptor, &namedBefore),
                  namedBefore.st_size > 0,
                  namedBefore.st_size <= maximumDatabasePages * pageSize,
                  namedBefore.st_size % pageSize == 0,
                  let count = Int(exactly: namedBefore.st_size),
                  validFile(namedBefore, size: count) else {
                throw Failure.identityRejected
            }
            var fd = epr_h4d3_open_final(root.descriptor)
            guard fd >= 0 else { throw Failure.finalOpenRejected }
            defer { if fd >= 0 { _ = Darwin.close(fd) } }
            var openedBefore = stat()
            guard fstat(fd, &openedBefore) == 0,
                  validFile(openedBefore, size: count),
                  sameFile(namedBefore, openedBefore) else {
                throw Failure.identityRejected
            }
            let image = try readExact(fd, count)
            var openedAfter = stat()
            guard fstat(fd, &openedAfter) == 0,
                  sameFile(openedBefore, openedAfter) else {
                throw Failure.identityRejected
            }
            try validateImage(image)
            var db: OpaquePointer? = try openMemory()
            defer { _ = closeExact(&db) }
            guard let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                throw Failure.reconstructionRejected
            }
            image.copyBytes(to: allocation.assumingMemoryBound(to: UInt8.self),
                            count: image.count)
            guard epr_sqlite_deserialize_readonly(UnsafeMutableRawPointer(db),
                allocation.assumingMemoryBound(to: UInt8.self),
                Int64(image.count)) == SQLITE_OK else {
                throw Failure.reconstructionRejected
            }
            let policy = try readerPolicy(db)
            var st: OpaquePointer? = try prepare(db, rowSQL)
            defer { if let st { _ = sqlite3_finalize(st) } }
            guard sqlite3_step(st) == SQLITE_ROW else {
                throw Failure.reconstructionRejected
            }
            let snapshot = TestStoreSnapshot(
                inventory: entries, published: true,
                fileMode: UInt16(openedAfter.st_mode & 0o7777),
                fileSize: Int64(openedAfter.st_size),
                headerExact: true,
                userVersion: try integer(db, "PRAGMA user_version"),
                applicationID: try integer(db, "PRAGMA application_id"),
                schemaEntryCount: try integer(db, "SELECT count(*) FROM sqlite_schema"),
                rowCount: try integer(db, "SELECT count(*) FROM h4_dual_receipts"),
                singleton: sqlite3_column_int64(st, 0),
                semanticSchema: try text(st, 1), claimState: try text(st, 2),
                predicateCount: sqlite3_column_int64(st, 3),
                authorityVector: try text(st, 4),
                canonicalJSON: try blob(st, 5), canonicalCBOR: try blob(st, 6),
                storageClasses: (0...6).map { sqlite3_column_type(st, Int32($0)) },
                queryOnly: policy.queryOnly,
                defensive: policy.defensive,
                trustedSchema: policy.trustedSchema,
                dqsDDL: policy.dqsDDL,
                dqsDML: policy.dqsDML,
                tempStoreMemory: policy.tempStoreMemory,
                foreignKeys: policy.foreignKeys,
                autocommit: policy.autocommit,
                transactionNone: policy.transactionNone,
                filenameEmpty: policy.filenameEmpty)
            guard sqlite3_step(st) == SQLITE_DONE else {
                throw Failure.reconstructionRejected
            }
            guard sqlite3_finalize(st) == SQLITE_OK else {
                throw Failure.closeRejected
            }
            st = nil
            guard closeExact(&db) else { throw Failure.closeRejected }
            guard try directoryEntries(root.descriptor) == Set([finalLeafName]) else {
                throw Failure.storeAdmissionRejected
            }
            var namedRoot = stat(), heldRoot = stat()
            guard lstat(root.path, &namedRoot) == 0,
                  fstat(root.descriptor, &heldRoot) == 0,
                  sameRoot(namedRoot, heldRoot), validRoot(heldRoot) else {
                throw Failure.storeAdmissionRejected
            }
            var namedAfter = stat()
            guard statLeaf(finalLeafName, root.descriptor, &namedAfter),
                  sameFile(openedAfter, namedAfter),
                  validFile(namedAfter, size: count) else {
                throw Failure.identityRejected
            }
            guard Darwin.close(fd) == 0 else { throw Failure.closeRejected }
            fd = -1
            return snapshot
        }
        #endif
    }

    #if EPR_H4_LIVE
    static func readSavedFile(_ url: URL, budget: GuestH4SavedReceipt.Budget) throws -> GuestH4SavedReceipt.Snapshot {
        try Store.readSavedFile(url, budget: budget)
    }

    #if EPR_H4_PRIVACY_TESTS
    static func savedRowForTest(json: Data, cbor: Data) -> ReopenedDualStreamRowInput {
        .init(canonicalJSON: json, canonicalCBOR: cbor, semanticSchema: GuestH3LivePersistence.schema,
              claimState: "OBSERVED_NATIVE_PASS", predicateCount: 9, authorityVector: "00000000")
    }
    #endif

    static func readH8File(_ url: URL, budget: GuestH4SavedReceipt.Budget) throws -> GuestH8Provenance.Snapshot {
        try Store.readH8File(url, budget: budget)
    }

    static func persistH8(_ pending: GuestH8Provenance.Pending) -> GuestH8Provenance.Saved {
        do {
            let projection = try pending.claim()
            guard pending.remainsLive() else { throw Failure.expired }
            let root = try RootCapability.createLive(leaf: pending.leaf, namespace: .h8)
            return finishH8(pending, projection: projection, root: root, store: try Store(root: root, fault: .none))
        } catch {
            _ = pending.finish()
            return .init(durable: false, location: "", projection: nil)
        }
    }
    private static func finishH8(_ pending: GuestH8Provenance.Pending, projection: GuestH8Provenance.Projection,
                                root: RootCapability, store: Store) -> GuestH8Provenance.Saved {
        let result = store.appendH8(projection, remainsLive: { pending.remainsLive() })
        let completed = pending.finish()
        if case .admitted(let mint) = result, completed, mint.mint() != nil {
            return .init(durable: true, location: root.path + "/" + finalLeafName, projection: projection)
        }
        return .init(durable: false, location: root.path, projection: nil)
    }
    #if EPR_H4_PRIVACY_TESTS
    static func persistH8Test(_ pending: GuestH8Provenance.Pending, baseURL: URL,
                             fault: TestFault = .none,
                             interstice: TestPublicationIntersticeCallback? = nil) -> GuestH8Provenance.Saved {
        do {
            let projection = try pending.claim()
            guard pending.remainsLive() else { throw Failure.expired }
            let root = try RootCapability.createLive(leaf: pending.leaf, applicationSupport: baseURL, namespace: .h8)
            return finishH8(pending, projection: projection, root: root, store: try Store(root: root, fault: Fault(fault), calls: TestEnteredCalls(), publicationInterstice: interstice))
        } catch { _ = pending.finish(); return .init(durable: false, location: "", projection: nil) }
    }
    #endif

    static func persistLive(_ claim: GuestH3LivePersistence.Claim) -> GuestH3LivePersistence.Presentation {
        do {
            guard claim.remainsLive() else { throw Failure.expired }
            let root = try RootCapability.createLive(leaf: claim.leaf)
            return try finishLive(claim, root: root, store: Store(root: root, fault: .none))
        } catch {
            _ = claim.finish()
            return .init(durable: false,
                detail: "H4 storage was not admitted: \(error). Namespace \(GuestH3LivePersistence.rootLeaf), run \(claim.leaf). Any created directory remains retained; no retry or cleanup.",
                location: "", receipt: nil)
        }
    }

    private static func finishLive(_ claim: GuestH3LivePersistence.Claim,
                                   root: RootCapability, store: Store) throws -> GuestH3LivePersistence.Presentation {
        let result = store.appendLive(claim.projection, remainsLive: { claim.remainsLive() })
        let completed = claim.finish()
        let location = root.path + "/" + finalLeafName
        if case .admitted(let mint) = result, completed, mint.mint() != nil {
            return .init(durable: true,
                detail: "H4 saved both canonical streams, synced the SQLite image and directory, reopened it read-only, and verified exact bytes, indexes, and vnode identity against this H3 owner. No execution authority or OS attestation is granted.",
                location: location, receipt: claim.projection)
        }
        let disposition: String
        switch result {
        case .admitted: disposition = "publication read-back returned, but owner completion was canceled or expired"
        case .rejectedBeforePublication(let failure): disposition = "rejected before publication: \(failure)"
        case .transactionOutcomeUnknown(let failure): disposition = "transaction outcome unknown: \(failure)"
        case .prepublicationStateUnknown(let failure): disposition = "prepublication state unknown: \(failure)"
        case .stagingRetained(let failure): disposition = "staging retained: \(failure)"
        case .publicationOutcomeUnknown(let failure): disposition = "publication outcome unknown: \(failure)"
        case .publishedUnverified(let failure): disposition = "published but unverified: \(failure)"
        }
        return .init(durable: false,
            detail: "H4 did not complete verified publication: \(disposition). State remains retained; the final name may be absent or require inspection. No retry or cleanup.",
            location: root.path, receipt: nil)
    }

    #if EPR_H4_PRIVACY_TESTS
    static func persistLiveProvisionedTest(_ claim: GuestH3LivePersistence.Claim,
                                           baseURL: URL) throws -> GuestH3LivePersistence.Presentation {
        guard claim.remainsLive() else { throw Failure.expired }
        let root = try RootCapability.createLive(leaf: claim.leaf, applicationSupport: baseURL)
        return try finishLive(claim, root: root, store: Store(root: root, fault: .none))
    }

    static func persistLiveTest(_ claim: GuestH3LivePersistence.Claim,
                                rootURL: URL, fault: TestFault,
                                interstice: TestPublicationIntersticeCallback?) throws -> GuestH3LivePersistence.Presentation {
        guard claim.remainsLive() else { throw Failure.expired }
        let root = try RootCapability.admit(rootURL)
        let store = try Store(root: root, fault: Fault(fault), calls: TestEnteredCalls(),
                              publicationInterstice: interstice)
        return try finishLive(claim, root: root, store: store)
    }
    #endif
    #endif

    #if EPR_H4_PRIVACY_TESTS
    static func rootMetadataIsValidForTest(_ value: stat) -> Bool {
        Store.validRoot(value)
    }

    static func retainedRootMetadataIsValidForTest(_ value: stat) -> Bool {
        Store.validRoot(value)
    }

    static func retainedLeafMetadataIsValidForTest(
        _ value: stat,
        expectedMode: UInt16,
        expectedSize: Int
    ) -> Bool {
        guard expectedMode == 0o400 || expectedMode == 0o600,
              expectedSize >= 0,
              expectedSize <= Int(maximumDatabasePages * pageSize),
              value.st_mode & S_IFMT == S_IFREG,
              UInt16(value.st_mode & 0o7777) == expectedMode,
              value.st_uid == geteuid(), value.st_nlink == 1,
              value.st_size == expectedSize else {
            return false
        }
        return expectedSize == 0 ||
            (expectedSize >= 100 && expectedSize % Int(pageSize) == 0)
    }

    static func classifyRetainedStateForTest(
        rootPath: String,
        fault: TestRetainedStateFault = .none,
        hooks: TestRetainedStateHooks = TestRetainedStateHooks()
    ) -> TestRetainedStateEvidence {
        Store.classifyRetainedState(rootPath: rootPath, fault: fault, hooks: hooks)
    }

    static func makeTestCoordinator(
        bound: H4D.OwnerBoundCanonicalProjection, rootURL: URL,
        fault: TestFault = .none, storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }, rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil,
        publicationIntersticeForTest:
            TestPublicationIntersticeCallback? = nil
    ) throws -> Coordinator {
        try makeTestCoordinatorWithCounters(bound: bound, rootURL: rootURL,
            fault: fault, storeValidThroughTick: storeValidThroughTick,
            storeReadTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest,
            publicationIntersticeForTest: publicationIntersticeForTest).0
    }

    static func makeTestCoordinatorWithCounters(
        bound: H4D.OwnerBoundCanonicalProjection, rootURL: URL,
        fault: TestFault = .none, storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }, rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil,
        publicationIntersticeForTest:
            TestPublicationIntersticeCallback? = nil
    ) throws -> (Coordinator, TestEnteredCalls) {
        let calls = TestEnteredCalls()
        let store = try Store.make(
            rootURL: rootURL,
            fault: fault,
            calls: calls,
            publicationInterstice: publicationIntersticeForTest
        )
        return (H4D.makeTestDualStreamPersistenceCoordinator(
            bound: bound, store: store, validThroughTick: storeValidThroughTick,
            readTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest), calls)
    }

    static func makeTestSharedStoreCoordinators(
        bounds: [H4D.OwnerBoundCanonicalProjection], rootURL: URL,
        fault: TestFault = .none, storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }, rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil,
        publicationIntersticeForTest:
            TestPublicationIntersticeCallback? = nil
    ) throws -> [Coordinator] {
        let calls = TestEnteredCalls()
        let store = try Store.make(
            rootURL: rootURL,
            fault: fault,
            calls: calls,
            publicationInterstice: publicationIntersticeForTest
        )
        return H4D.makeTestSharedDualStreamStoreCoordinators(
            bounds: bounds, store: store, validThroughTick: storeValidThroughTick,
            readTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest)
    }

    static func makeTestSharedStoreCoordinatorsWithCounters(
        bounds: [H4D.OwnerBoundCanonicalProjection], rootURL: URL,
        fault: TestFault = .none, storeValidThroughTick: UInt64 = .max,
        storeReadTick: @escaping @Sendable () -> UInt64 = {
            mach_continuous_time()
        }, rejectStoreCompletionForTest: Bool = false,
        rejectOwnerCompletionForTest: Bool = false,
        completionIntersticeForTest: (@Sendable () -> Void)? = nil,
        publicationIntersticeForTest:
            TestPublicationIntersticeCallback? = nil
    ) throws -> ([Coordinator], TestEnteredCalls) {
        let calls = TestEnteredCalls()
        let store = try Store.make(
            rootURL: rootURL,
            fault: fault,
            calls: calls,
            publicationInterstice: publicationIntersticeForTest
        )
        return (H4D.makeTestSharedDualStreamStoreCoordinators(
            bounds: bounds, store: store, validThroughTick: storeValidThroughTick,
            readTick: storeReadTick,
            rejectStoreCompletionForTest: rejectStoreCompletionForTest,
            rejectOwnerCompletionForTest: rejectOwnerCompletionForTest,
            completionIntersticeForTest: completionIntersticeForTest), calls)
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
    #endif
}

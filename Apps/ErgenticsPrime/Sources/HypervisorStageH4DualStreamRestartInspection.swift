import Darwin
import Foundation
import SQLite3

/// Read-only admission of one retained H4-D3 v3 representation. The caller
/// supplies only a canonical private-root path. No writer object, prior byte
/// value, ownership object, or authority-bearing value participates in the
/// JSON/CBOR/indexed-scalar join performed here.
enum HypervisorStageH4DualStreamRestartInspection {
    static let result = "VALID_V3_DUAL_STREAM_THREE_WAY_JOIN"
    static let finalLeafName = "h4d3-dual-receipt.sqlite"
    static let formatSchema =
        "com.ergentics.provenance.hypervisor.h4.dual-stream-sqlite-image-publication.v3"
    static let semanticSchema =
        "com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1"
    static let applicationID: Int64 = 1_162_891_828
    static let userVersion: Int64 = 2
    static let pageSize: Int64 = 4_096
    static let maximumDatabasePages: Int64 = 64
    static let maximumImageBytes = 262_144
    static let maximumStreamBytes = 158

    enum Failure: Error, Equatable, Sendable {
        case rootRejected
        case namespaceRejected
        case finalOpenRejected
        case identityRejected
        case headerRejected
        case readRejected
        case allocationRejected
        case sqliteOpenRejected
        case sqlitePolicyRejected
        case integrityRejected
        case schemaRejected
        case rowRejected
        case jsonRejected
        case cborRejected
        case semanticMismatch
        case closeRejected
        case internalRejected
    }

    /// Every exposed value is a fixed fact about this representation-only
    /// result. In particular, this receipt does not claim that its caller is a
    /// newly executed helper; the launcher establishes that separate fact.
    struct Receipt: Equatable, Sendable, CustomReflectable {
        fileprivate init() {}

        var classification: String { result }
        var v3ImageAdmitted: Bool { true }
        var canonicalJSONCBORIndexedScalarJoin: Bool { true }
        var representationAdmissionOnly: Bool { true }
        var historicalProducerIdentityRecovered: Bool { false }
        var restartAuthenticityEstablished: Bool { false }
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

    enum Outcome: Equatable, Sendable {
        case validV3DualStreamThreeWayJoin(Receipt)
        case rejected(Failure)
    }

    #if EPR_H4_PRIVACY_TESTS
    enum TestFault: Equatable, Sendable {
        case none
        case rootOpenRejected
        case rootLockRejected
        case directoryScanRejected
        case finalOpenRejected
        case headerReadInterruptedOnce
        case headerReadShortOnce
        case headerReadZero
        case headerReadRejected
        case imageReadInterruptedOnce
        case imageReadShortOnce
        case imageReadZero
        case imageReadRejected
        case eofReadInterruptedOnce
        case eofReadNonzero
        case imageAllocationRejected
        case sqliteOpenRejected
        case sqliteAllocationRejected
        case deserializeRejected
        case readerHardeningRejected
        case queryOnlyRejected
        case filenameRejected
        case integrityRejected
        case schemaRejected
        case authorizerRejected
        case rowRejected
        case jsonRejected
        case cborRejected
        case scalarRejected
        case statementLeak
        case databaseCloseResponseLost
        case finalCloseResponseLost
        case rootCloseResponseLost
    }

    enum TestReadPhase: Equatable, Sendable {
        case header
        case image
        case eof
    }

    enum TestHookPoint: Equatable, Sendable {
        case afterNamedRootBeforeOpen
        case afterInitialInventory
        case afterNamedFinalBeforeOpen
        case afterHeaderReadBeforeMetadataJoin
        case afterImageReadBeforeMetadataJoin
        case afterSQLiteCloseBeforeFinalJoin
        case afterPrecloseFinalJoin
        case afterFinalCloseBeforeNamedJoin
        case afterPostcloseNamedJoinBeforeTerminal
    }

    enum TestEvent: Equatable, Sendable {
        case rootOpenEntered
        case rootLockEntered
        case directoryScanEntered
        case finalOpenEntered
        case pread(phase: TestReadPhase, requested: Int, returned: Int)
        case headerValidated
        case imageAllocationEntered(Int)
        case sqliteOpenEntered
        case sqliteAllocationEntered(Int)
        case deserializeEntered
        case readerHardeningEntered
        case readerPolicyObserved(
            queryOnly: Int64,
            trustedSchema: Int64,
            tempStore: Int64,
            foreignKeys: Int64,
            cellSizeCheck: Int64,
            autocommit: Bool,
            transactionNone: Bool,
            databaseReadOnly: Int32,
            filenameEmpty: Bool
        )
        case integrityEntered
        case schemaEntered
        case authorizerEntered
        case rowEntered
        case jsonDecodeEntered
        case cborDecodeEntered
        case semanticJoinEntered
        case statementFinalized(Int32)
        case databaseCloseEntered
        case finalCloseEntered
        case rootCloseEntered
        case hookEntered(TestHookPoint)
    }

    final class TestEvents: @unchecked Sendable {
        private let lock = NSLock()
        private var values: [TestEvent] = []

        func snapshot() -> [TestEvent] {
            lock.lock()
            defer { lock.unlock() }
            return values
        }

        fileprivate func record(_ event: TestEvent) {
            lock.lock()
            values.append(event)
            lock.unlock()
        }
    }

    struct TestHooks {
        let afterNamedRootBeforeOpen: (() throws -> Void)?
        let afterInitialInventory: (() throws -> Void)?
        let afterNamedFinalBeforeOpen: (() throws -> Void)?
        let afterHeaderReadBeforeMetadataJoin: (() throws -> Void)?
        let afterImageReadBeforeMetadataJoin: (() throws -> Void)?
        let afterSQLiteCloseBeforeFinalJoin: (() throws -> Void)?
        let afterPrecloseFinalJoin: (() throws -> Void)?
        let afterFinalCloseBeforeNamedJoin: (() throws -> Void)?
        let afterPostcloseNamedJoinBeforeTerminal: (() throws -> Void)?

        init(
            afterNamedRootBeforeOpen: (() throws -> Void)? = nil,
            afterInitialInventory: (() throws -> Void)? = nil,
            afterNamedFinalBeforeOpen: (() throws -> Void)? = nil,
            afterHeaderReadBeforeMetadataJoin: (() throws -> Void)? = nil,
            afterImageReadBeforeMetadataJoin: (() throws -> Void)? = nil,
            afterSQLiteCloseBeforeFinalJoin: (() throws -> Void)? = nil,
            afterPrecloseFinalJoin: (() throws -> Void)? = nil,
            afterFinalCloseBeforeNamedJoin: (() throws -> Void)? = nil,
            afterPostcloseNamedJoinBeforeTerminal: (() throws -> Void)? = nil
        ) {
            self.afterNamedRootBeforeOpen = afterNamedRootBeforeOpen
            self.afterInitialInventory = afterInitialInventory
            self.afterNamedFinalBeforeOpen = afterNamedFinalBeforeOpen
            self.afterHeaderReadBeforeMetadataJoin =
                afterHeaderReadBeforeMetadataJoin
            self.afterImageReadBeforeMetadataJoin =
                afterImageReadBeforeMetadataJoin
            self.afterSQLiteCloseBeforeFinalJoin =
                afterSQLiteCloseBeforeFinalJoin
            self.afterPrecloseFinalJoin = afterPrecloseFinalJoin
            self.afterFinalCloseBeforeNamedJoin =
                afterFinalCloseBeforeNamedJoin
            self.afterPostcloseNamedJoinBeforeTerminal =
                afterPostcloseNamedJoinBeforeTerminal
        }
    }
    #endif

    static func inspect(rootPath: String) -> Outcome {
        #if EPR_H4_PRIVACY_TESTS
        return Inspector(
            rootPath: rootPath,
            fault: .none,
            hooks: TestHooks(),
            events: nil
        ).run()
        #else
        return Inspector(rootPath: rootPath).run()
        #endif
    }

    #if EPR_H4_PRIVACY_TESTS
    static func inspectForTest(
        rootPath: String,
        fault: TestFault = .none,
        hooks: TestHooks = TestHooks(),
        events: TestEvents? = nil
    ) -> Outcome {
        Inspector(
            rootPath: rootPath,
            fault: fault,
            hooks: hooks,
            events: events
        ).run()
    }

    static func rootMetadataIsValidForTest(_ value: stat) -> Bool {
        Inspector.validRoot(value)
    }

    static func finalMetadataIsValidForTest(
        _ value: stat,
        expectedSize: Int
    ) -> Bool {
        Inspector.validFinal(value, size: expectedSize)
    }
    #endif

    private struct Semantic: Equatable {
        let schema: String
        let claimState: ClaimState
        let predicateCount: UInt32
        let authorityVector: String
    }

    private enum ClaimState: String {
        case observedNonPass = "OBSERVED_NONPASS"
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

    private enum ReadPhase {
        case header
        case image
        case eof
    }

    private final class Inspector {
        private static let maximumRootPathBytes = 1_024
        private static let fixedHeaderBytes = 100
        private static let tableName = "h4_dual_receipts"
        private static let tableSQL = "CREATE TABLE h4_dual_receipts(singleton INTEGER PRIMARY KEY CHECK(singleton=1),semantic_schema TEXT NOT NULL CHECK(semantic_schema='com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1'),claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS'),predicate_count INTEGER NOT NULL CHECK(predicate_count>0 AND predicate_count<=4096),authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),canonical_json BLOB NOT NULL CHECK(length(canonical_json)>0 AND length(canonical_json)<=158),canonical_cbor BLOB NOT NULL CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=158)) STRICT, WITHOUT ROWID"
        private static let rowSQL = "SELECT singleton,semantic_schema,claim_state,predicate_count,authority_vector,canonical_json,canonical_cbor FROM h4_dual_receipts LIMIT 2"

        private let rootPath: String
        private var rootDescriptor: Int32 = -1
        private var finalDescriptor: Int32 = -1
        private var database: OpaquePointer?
        private var rootBaseline = stat()
        private var rootBaselineSet = false
        private var finalBaseline = stat()
        private var finalBaselineSet = false

        #if EPR_H4_PRIVACY_TESTS
        private let fault: TestFault
        private let hooks: TestHooks
        private let events: TestEvents?
        private var headerInterruptionEntered = false
        private var headerShortReadEntered = false
        private var imageInterruptionEntered = false
        private var imageShortReadEntered = false
        private var eofInterruptionEntered = false

        fileprivate init(
            rootPath: String,
            fault: TestFault,
            hooks: TestHooks,
            events: TestEvents?
        ) {
            self.rootPath = rootPath
            self.fault = fault
            self.hooks = hooks
            self.events = events
        }
        #else
        fileprivate init(rootPath: String) {
            self.rootPath = rootPath
        }
        #endif

        fileprivate func run() -> Outcome {
            do {
                let receipt = try inspectOnce()
                return .validV3DualStreamThreeWayJoin(receipt)
            } catch let failure as Failure {
                containResources()
                return .rejected(failure)
            } catch {
                containResources()
                return .rejected(.internalRejected)
            }
        }

        private func inspectOnce() throws -> Receipt {
            try admitRoot()
            try requireFinalOnlyInventory()
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterInitialInventory,
                hooks.afterInitialInventory,
                failure: .namespaceRejected
            )
            #endif
            try revalidateRoot()
            try requireFinalOnlyInventory()

            var namedFinal = stat()
            guard statFinal(&namedFinal), Self.validFinalShape(namedFinal),
                  let imageCount = Int(exactly: namedFinal.st_size) else {
                throw Failure.identityRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterNamedFinalBeforeOpen,
                hooks.afterNamedFinalBeforeOpen,
                failure: .identityRejected
            )
            record(.finalOpenEntered)
            if fault == .finalOpenRejected {
                throw Failure.finalOpenRejected
            }
            #endif
            finalDescriptor = epr_h4d3_open_final(rootDescriptor)
            guard finalDescriptor >= 0 else {
                throw Failure.finalOpenRejected
            }
            var openedFinal = stat()
            guard fstat(finalDescriptor, &openedFinal) == 0,
                  Self.validFinal(openedFinal, size: imageCount),
                  sameFinal(namedFinal, openedFinal) else {
                throw Failure.identityRejected
            }
            finalBaseline = openedFinal
            finalBaselineSet = true

            var header = [UInt8](repeating: 0, count: Self.fixedHeaderBytes)
            try header.withUnsafeMutableBytes {
                (storage: UnsafeMutableRawBufferPointer) throws in
                guard let base = storage.baseAddress else {
                    throw Failure.readRejected
                }
                try fill(
                    base,
                    count: storage.count,
                    offset: 0,
                    phase: .header
                )
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterHeaderReadBeforeMetadataJoin,
                hooks.afterHeaderReadBeforeMetadataJoin,
                failure: .identityRejected
            )
            #endif
            var afterHeader = stat()
            guard fstat(finalDescriptor, &afterHeader) == 0,
                  sameFinal(finalBaseline, afterHeader),
                  Self.validFinal(afterHeader, size: imageCount) else {
                throw Failure.identityRejected
            }
            try Self.validateHeader(header, imageCount: imageCount)
            #if EPR_H4_PRIVACY_TESTS
            record(.headerValidated)
            record(.imageAllocationEntered(imageCount))
            if fault == .imageAllocationRejected {
                throw Failure.allocationRejected
            }
            #endif

            var image = Data(count: imageCount)
            try image.withUnsafeMutableBytes {
                (storage: UnsafeMutableRawBufferPointer) throws in
                guard let base = storage.baseAddress else {
                    throw Failure.readRejected
                }
                try fill(
                    base,
                    count: storage.count,
                    offset: 0,
                    phase: .image
                )
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterImageReadBeforeMetadataJoin,
                hooks.afterImageReadBeforeMetadataJoin,
                failure: .identityRejected
            )
            #endif
            var openedAfterRead = stat()
            guard fstat(finalDescriptor, &openedAfterRead) == 0,
                  sameFinal(finalBaseline, openedAfterRead),
                  Self.validFinal(openedAfterRead, size: imageCount) else {
                throw Failure.identityRejected
            }
            try requireEOF(at: imageCount)
            guard image.prefix(Self.fixedHeaderBytes).elementsEqual(header) else {
                throw Failure.headerRejected
            }
            try Self.validateHeader(
                Array(image.prefix(Self.fixedHeaderBytes)),
                imageCount: imageCount
            )
            var namedAfterRead = stat()
            guard statFinal(&namedAfterRead),
                  sameFinal(finalBaseline, namedAfterRead),
                  Self.validFinal(namedAfterRead, size: imageCount) else {
                throw Failure.identityRejected
            }

            try inspectImage(image)
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterSQLiteCloseBeforeFinalJoin,
                hooks.afterSQLiteCloseBeforeFinalJoin,
                failure: .identityRejected
            )
            #endif

            try revalidateRoot()
            try requireFinalOnlyInventory()
            var precloseNamed = stat()
            var precloseOpened = stat()
            guard statFinal(&precloseNamed),
                  fstat(finalDescriptor, &precloseOpened) == 0,
                  sameFinal(finalBaseline, precloseNamed),
                  sameFinal(finalBaseline, precloseOpened),
                  Self.validFinal(precloseNamed, size: imageCount),
                  Self.validFinal(precloseOpened, size: imageCount) else {
                throw Failure.identityRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterPrecloseFinalJoin,
                hooks.afterPrecloseFinalJoin,
                failure: .identityRejected
            )
            #endif
            var immediateNamed = stat()
            var immediateOpened = stat()
            guard statFinal(&immediateNamed),
                  fstat(finalDescriptor, &immediateOpened) == 0,
                  sameFinal(finalBaseline, immediateNamed),
                  sameFinal(finalBaseline, immediateOpened) else {
                throw Failure.identityRejected
            }
            guard closeFinalExactly() else {
                throw Failure.closeRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterFinalCloseBeforeNamedJoin,
                hooks.afterFinalCloseBeforeNamedJoin,
                failure: .identityRejected
            )
            #endif
            var postcloseNamed = stat()
            guard statFinal(&postcloseNamed),
                  sameFinal(finalBaseline, postcloseNamed),
                  Self.validFinal(postcloseNamed, size: imageCount) else {
                throw Failure.identityRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterPostcloseNamedJoinBeforeTerminal,
                hooks.afterPostcloseNamedJoinBeforeTerminal,
                failure: .identityRejected
            )
            #endif

            try revalidateRoot()
            try requireFinalOnlyInventory()
            var terminalNamed = stat()
            guard statFinal(&terminalNamed),
                  sameFinal(finalBaseline, terminalNamed),
                  Self.validFinal(terminalNamed, size: imageCount) else {
                throw Failure.identityRejected
            }
            try revalidateRoot()
            guard closeRootExactly() else {
                throw Failure.closeRejected
            }
            return Receipt()
        }

        private func admitRoot() throws {
            let components = rootPath.split(
                separator: "/",
                omittingEmptySubsequences: false
            )
            guard rootPath.utf8.count >= 2,
                  rootPath.utf8.count <= Self.maximumRootPathBytes,
                  rootPath.first == "/",
                  rootPath.last != "/",
                  !rootPath.utf8.contains(0),
                  !rootPath.contains("//"),
                  !components.contains(where: { $0 == "." || $0 == ".." }),
                  let resolved = realpath(rootPath, nil) else {
                throw Failure.rootRejected
            }
            let physical = String(validatingCString: resolved)
            free(resolved)
            guard let physical,
                  physical.utf8.elementsEqual(rootPath.utf8) else {
                throw Failure.rootRejected
            }
            var namedRoot = stat()
            guard lstat(rootPath, &namedRoot) == 0 else {
                throw Failure.rootRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            try invoke(
                .afterNamedRootBeforeOpen,
                hooks.afterNamedRootBeforeOpen,
                failure: .rootRejected
            )
            record(.rootOpenEntered)
            if fault == .rootOpenRejected {
                throw Failure.rootRejected
            }
            #endif
            rootDescriptor = Darwin.open(
                rootPath,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard rootDescriptor >= 0 else {
                throw Failure.rootRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            record(.rootLockEntered)
            if fault == .rootLockRejected {
                throw Failure.rootRejected
            }
            #endif
            guard flock(rootDescriptor, LOCK_SH | LOCK_NB) == 0 else {
                throw Failure.rootRejected
            }
            var heldRoot = stat()
            guard fstat(rootDescriptor, &heldRoot) == 0,
                  Self.validRoot(heldRoot),
                  Self.sameRoot(namedRoot, heldRoot) else {
                throw Failure.rootRejected
            }
            rootBaseline = heldRoot
            rootBaselineSet = true
        }

        private func revalidateRoot() throws {
            guard rootDescriptor >= 0, rootBaselineSet else {
                throw Failure.rootRejected
            }
            var namedRoot = stat()
            var heldRoot = stat()
            guard lstat(rootPath, &namedRoot) == 0,
                  fstat(rootDescriptor, &heldRoot) == 0,
                  Self.validRoot(heldRoot),
                  Self.sameRoot(rootBaseline, namedRoot),
                  Self.sameRoot(rootBaseline, heldRoot) else {
                throw Failure.rootRejected
            }
        }

        private func requireFinalOnlyInventory() throws {
            try scanFinalOnlyInventory()
        }

        private func scanFinalOnlyInventory() throws {
            #if EPR_H4_PRIVACY_TESTS
            record(.directoryScanEntered)
            if fault == .directoryScanRejected {
                throw Failure.namespaceRejected
            }
            #endif
            let scanDescriptor = ".".withCString {
                openat(
                    rootDescriptor,
                    $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard scanDescriptor >= 0 else {
                throw Failure.namespaceRejected
            }
            var scanRoot = stat()
            var heldRoot = stat()
            guard fstat(scanDescriptor, &scanRoot) == 0,
                  fstat(rootDescriptor, &heldRoot) == 0,
                  Self.sameRoot(scanRoot, heldRoot),
                  Self.sameRoot(rootBaseline, heldRoot) else {
                _ = Darwin.close(scanDescriptor)
                throw Failure.namespaceRejected
            }
            guard let stream = fdopendir(scanDescriptor) else {
                _ = Darwin.close(scanDescriptor)
                throw Failure.namespaceRejected
            }
            var sawFinal = false
            var readFailed = false
            while true {
                errno = 0
                guard let entry = readdir(stream) else {
                    readFailed = errno != 0
                    break
                }
                let capacity = MemoryLayout.size(ofValue: entry.pointee.d_name)
                let name = withUnsafePointer(to: entry.pointee.d_name) { pointer in
                    pointer.withMemoryRebound(
                        to: CChar.self,
                        capacity: capacity
                    ) {
                        String(validatingCString: $0)
                    }
                }
                guard let name, !name.isEmpty else {
                    readFailed = true
                    break
                }
                if name == "." || name == ".." {
                    continue
                }
                guard !sawFinal, name == finalLeafName else {
                    readFailed = true
                    break
                }
                sawFinal = true
            }
            let closeStatus = closedir(stream)
            guard !readFailed, sawFinal else {
                throw Failure.namespaceRejected
            }
            guard closeStatus == 0 else {
                throw Failure.closeRejected
            }
        }

        private func statFinal(_ value: inout stat) -> Bool {
            finalLeafName.withCString {
                fstatat(
                    rootDescriptor,
                    $0,
                    &value,
                    AT_SYMLINK_NOFOLLOW
                ) == 0
            }
        }

        private func fill(
            _ destination: UnsafeMutableRawPointer,
            count: Int,
            offset: off_t,
            phase: ReadPhase
        ) throws {
            guard count > 0, count <= maximumImageBytes else {
                throw Failure.readRejected
            }
            var completed = 0
            while completed < count {
                let amount = readPrimitive(
                    destination: destination.advanced(by: completed),
                    count: count - completed,
                    offset: offset + off_t(completed),
                    phase: phase
                )
                if amount < 0, errno == EINTR {
                    continue
                }
                guard amount > 0, amount <= count - completed else {
                    throw Failure.readRejected
                }
                completed += amount
            }
        }

        private func requireEOF(at offset: Int) throws {
            var byte: UInt8 = 0
            var amount: Int
            repeat {
                amount = withUnsafeMutablePointer(to: &byte) {
                    readPrimitive(
                        destination: UnsafeMutableRawPointer($0),
                        count: 1,
                        offset: off_t(offset),
                        phase: .eof
                    )
                }
            } while amount < 0 && errno == EINTR
            guard amount == 0 else {
                throw Failure.readRejected
            }
        }

        private func readPrimitive(
            destination: UnsafeMutableRawPointer,
            count: Int,
            offset: off_t,
            phase: ReadPhase
        ) -> Int {
            #if EPR_H4_PRIVACY_TESTS
            let amount: Int
            switch (phase, fault) {
            case (.header, .headerReadInterruptedOnce)
                where !headerInterruptionEntered:
                headerInterruptionEntered = true
                errno = EINTR
                amount = -1
            case (.header, .headerReadShortOnce)
                where !headerShortReadEntered:
                headerShortReadEntered = true
                amount = Darwin.pread(
                    finalDescriptor,
                    destination,
                    max(1, count / 2),
                    offset
                )
            case (.header, .headerReadZero):
                amount = 0
            case (.header, .headerReadRejected):
                errno = EIO
                amount = -1
            case (.image, .imageReadInterruptedOnce)
                where !imageInterruptionEntered:
                imageInterruptionEntered = true
                errno = EINTR
                amount = -1
            case (.image, .imageReadShortOnce)
                where !imageShortReadEntered:
                imageShortReadEntered = true
                amount = Darwin.pread(
                    finalDescriptor,
                    destination,
                    max(1, count / 2),
                    offset
                )
            case (.image, .imageReadZero):
                amount = 0
            case (.image, .imageReadRejected):
                errno = EIO
                amount = -1
            case (.eof, .eofReadInterruptedOnce)
                where !eofInterruptionEntered:
                eofInterruptionEntered = true
                errno = EINTR
                amount = -1
            case (.eof, .eofReadNonzero):
                destination.storeBytes(of: UInt8(0xa5), as: UInt8.self)
                amount = 1
            default:
                amount = Darwin.pread(
                    finalDescriptor,
                    destination,
                    count,
                    offset
                )
            }
            let testPhase: TestReadPhase
            switch phase {
            case .header: testPhase = .header
            case .image: testPhase = .image
            case .eof: testPhase = .eof
            }
            record(.pread(phase: testPhase, requested: count, returned: amount))
            return amount
            #else
            return Darwin.pread(
                finalDescriptor,
                destination,
                count,
                offset
            )
            #endif
        }

        private static func validateHeader(
            _ bytes: [UInt8],
            imageCount: Int
        ) throws {
            let magic = Array("SQLite format 3\0".utf8)
            guard bytes.count == fixedHeaderBytes,
                  imageCount >= fixedHeaderBytes,
                  imageCount <= maximumImageBytes,
                  imageCount % Int(pageSize) == 0,
                  bytes.prefix(magic.count).elementsEqual(magic),
                  bytes[16] == 0x10,
                  bytes[17] == 0x00,
                  bytes[18] == 0x01,
                  bytes[19] == 0x01 else {
                throw Failure.headerRejected
            }
            let pageCount = UInt32(bytes[28]) << 24 |
                UInt32(bytes[29]) << 16 |
                UInt32(bytes[30]) << 8 |
                UInt32(bytes[31])
            let multiplication = UInt64(pageCount).multipliedReportingOverflow(
                by: UInt64(pageSize)
            )
            guard pageCount > 0,
                  pageCount <= UInt32(maximumDatabasePages),
                  !multiplication.overflow,
                  multiplication.partialValue == UInt64(imageCount) else {
                throw Failure.headerRejected
            }
        }

        private func inspectImage(_ image: Data) throws {
            #if EPR_H4_PRIVACY_TESTS
            record(.sqliteOpenEntered)
            if fault == .sqliteOpenRejected {
                throw Failure.sqliteOpenRejected
            }
            #endif
            var opened: OpaquePointer?
            let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE |
                SQLITE_OPEN_MEMORY | SQLITE_OPEN_FULLMUTEX |
                SQLITE_OPEN_PRIVATECACHE | SQLITE_OPEN_EXRESCODE
            let openStatus = sqlite3_open_v2(":memory:", &opened, flags, nil)
            database = opened
            guard openStatus == SQLITE_OK, database != nil else {
                throw Failure.sqliteOpenRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.sqliteAllocationEntered(image.count))
            if fault == .sqliteAllocationRejected {
                throw Failure.allocationRejected
            }
            #endif
            guard let allocation = sqlite3_malloc64(UInt64(image.count)) else {
                throw Failure.allocationRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            if fault == .deserializeRejected {
                sqlite3_free(allocation)
                throw Failure.sqlitePolicyRejected
            }
            #endif
            image.copyBytes(
                to: allocation.assumingMemoryBound(to: UInt8.self),
                count: image.count
            )
            #if EPR_H4_PRIVACY_TESTS
            record(.deserializeEntered)
            #endif
            guard epr_sqlite_deserialize_readonly(
                UnsafeMutableRawPointer(database),
                allocation.assumingMemoryBound(to: UInt8.self),
                Int64(image.count)
            ) == SQLITE_OK else {
                throw Failure.sqlitePolicyRejected
            }

            try configureReader()
            #if EPR_H4_PRIVACY_TESTS
            record(.integrityEntered)
            if fault == .integrityRejected {
                throw Failure.integrityRejected
            }
            #endif
            do {
                guard try scalarText(
                    "PRAGMA integrity_check(1)",
                    maximum: 128
                ) == "ok" else {
                    throw Failure.integrityRejected
                }
            } catch Failure.closeRejected {
                throw Failure.closeRejected
            } catch {
                throw Failure.integrityRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.schemaEntered)
            if fault == .schemaRejected {
                throw Failure.schemaRejected
            }
            #endif
            do {
                try validateSchema()
            } catch Failure.closeRejected {
                throw Failure.closeRejected
            } catch {
                throw Failure.schemaRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.authorizerEntered)
            if fault == .authorizerRejected {
                throw Failure.sqlitePolicyRejected
            }
            #endif
            guard epr_sqlite_install_readonly_authorizer(
                UnsafeMutableRawPointer(database)
            ) == SQLITE_OK else {
                throw Failure.sqlitePolicyRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.rowEntered)
            if fault == .rowRejected {
                throw Failure.rowRejected
            }
            #endif
            let row: Row
            do {
                row = try readRow()
            } catch Failure.closeRejected {
                throw Failure.closeRejected
            } catch {
                throw Failure.rowRejected
            }
            try joinRepresentations(row)

            #if EPR_H4_PRIVACY_TESTS
            if fault == .statementLeak {
                var leaked: OpaquePointer?
                let flags = UInt32(
                    SQLITE_PREPARE_NO_VTAB | SQLITE_PREPARE_DONT_LOG
                )
                guard sqlite3_prepare_v3(
                    database,
                    "SELECT 1",
                    -1,
                    flags,
                    &leaked,
                    nil
                ) == SQLITE_OK, leaked != nil else {
                    throw Failure.sqlitePolicyRejected
                }
            }
            #endif
            guard closeDatabaseExactly() else {
                throw Failure.closeRejected
            }
        }

        private func configureReader() throws {
            guard let database else {
                throw Failure.sqlitePolicyRejected
            }
            guard sqlite3_extended_result_codes(database, 1) == SQLITE_OK,
                  sqlite3_busy_timeout(database, 0) == SQLITE_OK else {
                throw Failure.sqlitePolicyRejected
            }
            try installLimits(database)
            #if EPR_H4_PRIVACY_TESTS
            record(.readerHardeningEntered)
            if fault == .readerHardeningRejected {
                throw Failure.sqlitePolicyRejected
            }
            #endif
            var policy = EPRSQLiteReadOnlyPolicy()
            guard epr_sqlite_harden_readonly(
                UnsafeMutableRawPointer(database),
                &policy
            ) == SQLITE_OK,
                  policy.defensive == 1,
                  policy.trusted_schema == 0,
                  policy.dqs_ddl == 0,
                  policy.dqs_dml == 0 else {
                throw Failure.sqlitePolicyRejected
            }
            try applyConnectionSetting("PRAGMA query_only=ON")
            try applyConnectionSetting("PRAGMA trusted_schema=OFF")
            try applyConnectionSetting("PRAGMA temp_store=MEMORY")
            try applyConnectionSetting("PRAGMA foreign_keys=ON")
            try applyConnectionSetting("PRAGMA cell_size_check=ON")
            #if EPR_H4_PRIVACY_TESTS
            if fault == .queryOnlyRejected {
                try applyConnectionSetting("PRAGMA query_only=OFF")
            }
            #endif
            let queryOnly = try scalarInteger("PRAGMA query_only")
            let trustedSchema = try scalarInteger("PRAGMA trusted_schema")
            let tempStore = try scalarInteger("PRAGMA temp_store")
            let foreignKeys = try scalarInteger("PRAGMA foreign_keys")
            let cellSizeCheck = try scalarInteger("PRAGMA cell_size_check")
            let autocommit = sqlite3_get_autocommit(database) == 1
            let transactionNone =
                sqlite3_txn_state(database, "main") == SQLITE_TXN_NONE
            let filenameEmpty = sqlite3_db_filename(database, "main")?.pointee == 0
            #if EPR_H4_PRIVACY_TESTS
            let databaseReadOnly = sqlite3_db_readonly(database, "main")
            record(.readerPolicyObserved(
                queryOnly: queryOnly,
                trustedSchema: trustedSchema,
                tempStore: tempStore,
                foreignKeys: foreignKeys,
                cellSizeCheck: cellSizeCheck,
                autocommit: autocommit,
                transactionNone: transactionNone,
                databaseReadOnly: databaseReadOnly,
                filenameEmpty: filenameEmpty
            ))
            #endif
            guard queryOnly == 1,
                  trustedSchema == 0,
                  tempStore == 2,
                  foreignKeys == 1,
                  cellSizeCheck == 1,
                  autocommit,
                  transactionNone,
                  filenameEmpty else {
                throw Failure.sqlitePolicyRejected
            }
            #if EPR_H4_PRIVACY_TESTS
            if fault == .filenameRejected {
                throw Failure.sqlitePolicyRejected
            }
            #endif
        }

        private func installLimits(_ database: OpaquePointer) throws {
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

        private func validateSchema() throws {
            guard try scalarInteger("PRAGMA page_size") == pageSize,
                  try scalarInteger("PRAGMA user_version") == userVersion,
                  try scalarInteger("PRAGMA application_id") == applicationID else {
                throw Failure.schemaRejected
            }
            try withStatement(
                "SELECT type,name,tbl_name,rootpage,sql FROM sqlite_schema LIMIT 2"
            ) { statement in
                guard sqlite3_column_count(statement) == 5,
                      sqlite3_step(statement) == SQLITE_ROW,
                      try text(statement, column: 0, maximum: 16) == "table",
                      try text(statement, column: 1, maximum: 64) == Self.tableName,
                      try text(statement, column: 2, maximum: 64) == Self.tableName,
                      sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                      sqlite3_column_int64(statement, 3) > 0,
                      try text(statement, column: 4, maximum: 1_024) == Self.tableSQL,
                      sqlite3_step(statement) == SQLITE_DONE else {
                    throw Failure.schemaRejected
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
                    throw Failure.schemaRejected
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
                        throw Failure.schemaRejected
                    }
                }
                guard sqlite3_step(statement) == SQLITE_DONE else {
                    throw Failure.schemaRejected
                }
            }
        }

        private func readRow() throws -> Row {
            try withStatement(Self.rowSQL) { statement in
                guard sqlite3_column_count(statement) == 7,
                      sqlite3_step(statement) == SQLITE_ROW,
                      sqlite3_column_type(statement, 0) == SQLITE_INTEGER,
                      sqlite3_column_type(statement, 1) == SQLITE_TEXT,
                      sqlite3_column_type(statement, 2) == SQLITE_TEXT,
                      sqlite3_column_type(statement, 3) == SQLITE_INTEGER,
                      sqlite3_column_type(statement, 4) == SQLITE_TEXT,
                      sqlite3_column_type(statement, 5) == SQLITE_BLOB,
                      sqlite3_column_type(statement, 6) == SQLITE_BLOB else {
                    throw Failure.rowRejected
                }
                let row = Row(
                    singleton: sqlite3_column_int64(statement, 0),
                    semanticSchema: try text(
                        statement,
                        column: 1,
                        maximum: 128
                    ),
                    claimState: try text(
                        statement,
                        column: 2,
                        maximum: 32
                    ),
                    predicateCount: sqlite3_column_int64(statement, 3),
                    authorityVector: try text(
                        statement,
                        column: 4,
                        maximum: 16
                    ),
                    canonicalJSON: try blob(statement, column: 5),
                    canonicalCBOR: try blob(statement, column: 6)
                )
                guard sqlite3_step(statement) == SQLITE_DONE else {
                    throw Failure.rowRejected
                }
                return row
            }
        }

        private func joinRepresentations(_ row: Row) throws {
            #if EPR_H4_PRIVACY_TESTS
            if fault == .scalarRejected {
                throw Failure.semanticMismatch
            }
            #endif
            guard row.singleton == 1,
                  row.predicateCount > 0,
                  let predicateCount = UInt32(exactly: row.predicateCount),
                  let claimState = ClaimState(rawValue: row.claimState) else {
                throw Failure.semanticMismatch
            }
            let indexed = Semantic(
                schema: row.semanticSchema,
                claimState: claimState,
                predicateCount: predicateCount,
                authorityVector: row.authorityVector
            )
            guard HypervisorStageH4DualStreamRestartInspection
                .validSemantic(indexed) else {
                throw Failure.semanticMismatch
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.jsonDecodeEntered)
            if fault == .jsonRejected {
                throw Failure.jsonRejected
            }
            #endif
            let json: Semantic
            do {
                json = try CanonicalJSON.decode(row.canonicalJSON)
            } catch {
                throw Failure.jsonRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.cborDecodeEntered)
            if fault == .cborRejected {
                throw Failure.cborRejected
            }
            #endif
            let cbor: Semantic
            do {
                cbor = try DeterministicCBOR.decode(row.canonicalCBOR)
            } catch {
                throw Failure.cborRejected
            }

            #if EPR_H4_PRIVACY_TESTS
            record(.semanticJoinEntered)
            #endif
            guard json == cbor, json == indexed, cbor == indexed else {
                throw Failure.semanticMismatch
            }
        }

        private func applyConnectionSetting(_ sql: String) throws {
            try withStatement(sql) { statement in
                guard sqlite3_step(statement) == SQLITE_DONE else {
                    throw Failure.sqlitePolicyRejected
                }
            }
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
                database,
                sql,
                -1,
                flags,
                &statement,
                nil
            ) == SQLITE_OK, let statement else {
                throw Failure.sqlitePolicyRejected
            }
            let value: T
            do {
                value = try body(statement)
            } catch {
                let bodyError = error
                let status = sqlite3_finalize(statement)
                #if EPR_H4_PRIVACY_TESTS
                record(.statementFinalized(status))
                #endif
                guard status == SQLITE_OK else {
                    throw Failure.closeRejected
                }
                throw bodyError
            }
            let status = sqlite3_finalize(statement)
            #if EPR_H4_PRIVACY_TESTS
            record(.statementFinalized(status))
            #endif
            guard status == SQLITE_OK else {
                throw Failure.closeRejected
            }
            return value
        }

        private func scalarInteger(_ sql: String) throws -> Int64 {
            try withStatement(sql) { statement in
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
        }

        private func scalarText(
            _ sql: String,
            maximum: Int
        ) throws -> String {
            try withStatement(sql) { statement in
                guard sqlite3_step(statement) == SQLITE_ROW else {
                    throw Failure.sqlitePolicyRejected
                }
                let value = try text(statement, column: 0, maximum: maximum)
                guard sqlite3_step(statement) == SQLITE_DONE else {
                    throw Failure.sqlitePolicyRejected
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
                throw Failure.rowRejected
            }
            let count = Int(sqlite3_column_bytes(statement, column))
            guard count > 0, count <= maximum,
                  let pointer = sqlite3_column_text(statement, column),
                  let value = String(
                    data: Data(bytes: pointer, count: count),
                    encoding: .utf8
                  ),
                  !value.utf8.contains(0) else {
                throw Failure.rowRejected
            }
            return value
        }

        private func blob(
            _ statement: OpaquePointer,
            column: Int32
        ) throws -> Data {
            guard sqlite3_column_type(statement, column) == SQLITE_BLOB else {
                throw Failure.rowRejected
            }
            let count = Int(sqlite3_column_bytes(statement, column))
            guard count > 0, count <= maximumStreamBytes,
                  let pointer = sqlite3_column_blob(statement, column) else {
                throw Failure.rowRejected
            }
            return Data(bytes: pointer, count: count)
        }

        private func closeDatabaseExactly() -> Bool {
            guard let current = database else {
                return true
            }
            #if EPR_H4_PRIVACY_TESTS
            record(.databaseCloseEntered)
            #endif
            var statement = sqlite3_next_stmt(current, nil)
            var statementCount = 0
            var finalizationExact = true
            while let live = statement {
                statement = sqlite3_next_stmt(current, live)
                statementCount += 1
                let status = sqlite3_finalize(live)
                #if EPR_H4_PRIVACY_TESTS
                record(.statementFinalized(status))
                #endif
                if status != SQLITE_OK {
                    finalizationExact = false
                }
            }
            let closeStatus = sqlite3_close(current)
            if closeStatus != SQLITE_OK {
                _ = sqlite3_close_v2(current)
            }
            database = nil
            #if EPR_H4_PRIVACY_TESTS
            let responseLost = closeStatus == SQLITE_OK &&
                fault == .databaseCloseResponseLost
            #else
            let responseLost = false
            #endif
            return statementCount == 0 && finalizationExact &&
                closeStatus == SQLITE_OK && !responseLost
        }

        private func closeFinalExactly() -> Bool {
            guard finalDescriptor >= 0 else {
                return true
            }
            #if EPR_H4_PRIVACY_TESTS
            record(.finalCloseEntered)
            #endif
            let descriptor = finalDescriptor
            finalDescriptor = -1
            let status = Darwin.close(descriptor)
            #if EPR_H4_PRIVACY_TESTS
            let responseLost = status == 0 && fault == .finalCloseResponseLost
            #else
            let responseLost = false
            #endif
            return status == 0 && !responseLost
        }

        private func closeRootExactly() -> Bool {
            guard rootDescriptor >= 0 else {
                return true
            }
            #if EPR_H4_PRIVACY_TESTS
            record(.rootCloseEntered)
            #endif
            let descriptor = rootDescriptor
            rootDescriptor = -1
            let status = Darwin.close(descriptor)
            #if EPR_H4_PRIVACY_TESTS
            let responseLost = status == 0 && fault == .rootCloseResponseLost
            #else
            let responseLost = false
            #endif
            return status == 0 && !responseLost
        }

        private func containResources() {
            if let current = database {
                var statement = sqlite3_next_stmt(current, nil)
                while let live = statement {
                    statement = sqlite3_next_stmt(current, live)
                    _ = sqlite3_finalize(live)
                }
                _ = sqlite3_close_v2(current)
                database = nil
            }
            if finalDescriptor >= 0 {
                let descriptor = finalDescriptor
                finalDescriptor = -1
                _ = Darwin.close(descriptor)
            }
            if rootDescriptor >= 0 {
                let descriptor = rootDescriptor
                rootDescriptor = -1
                _ = Darwin.close(descriptor)
            }
        }

        fileprivate static func validRoot(_ value: stat) -> Bool {
            value.st_mode & S_IFMT == S_IFDIR &&
                value.st_mode & 0o7777 == 0o700 &&
                value.st_uid == geteuid()
        }

        private static func sameRoot(_ left: stat, _ right: stat) -> Bool {
            left.st_dev == right.st_dev &&
                left.st_ino == right.st_ino &&
                left.st_mode == right.st_mode &&
                left.st_uid == right.st_uid &&
                left.st_gid == right.st_gid &&
                left.st_nlink == right.st_nlink &&
                left.st_flags == right.st_flags
        }

        fileprivate static func validFinalShape(_ value: stat) -> Bool {
            value.st_mode & S_IFMT == S_IFREG &&
                value.st_mode & 0o7777 == 0o400 &&
                value.st_uid == geteuid() &&
                value.st_nlink == 1 &&
                value.st_size >= off_t(Self.fixedHeaderBytes) &&
                value.st_size <= off_t(maximumImageBytes) &&
                value.st_size % off_t(pageSize) == 0
        }

        fileprivate static func validFinal(_ value: stat, size: Int) -> Bool {
            validFinalShape(value) && value.st_size == off_t(size)
        }

        private func sameFinal(_ left: stat, _ right: stat) -> Bool {
            left.st_dev == right.st_dev &&
                left.st_ino == right.st_ino &&
                left.st_mode == right.st_mode &&
                left.st_uid == right.st_uid &&
                left.st_gid == right.st_gid &&
                left.st_nlink == right.st_nlink &&
                left.st_size == right.st_size &&
                left.st_flags == right.st_flags &&
                left.st_mtimespec.tv_sec == right.st_mtimespec.tv_sec &&
                left.st_mtimespec.tv_nsec == right.st_mtimespec.tv_nsec &&
                left.st_ctimespec.tv_sec == right.st_ctimespec.tv_sec &&
                left.st_ctimespec.tv_nsec == right.st_ctimespec.tv_nsec
        }

        #if EPR_H4_PRIVACY_TESTS
        private func record(_ event: TestEvent) {
            events?.record(event)
        }

        private func invoke(
            _ point: TestHookPoint,
            _ action: (() throws -> Void)?,
            failure: Failure
        ) throws {
            record(.hookEntered(point))
            do {
                try action?()
            } catch {
                throw failure
            }
        }
        #endif
    }

    private static func validSemantic(_ value: Semantic) -> Bool {
        value.schema.utf8.elementsEqual(semanticSchema.utf8) &&
            value.claimState == .observedNonPass &&
            value.predicateCount > 0 &&
            value.predicateCount <= 4_096 &&
            value.authorityVector.utf8.elementsEqual("00000000".utf8)
    }

    private enum CodecFailure: Error {
        case bound
        case malformed
        case noncanonical
        case semantic
    }

    /// Closed canonical JSON grammar for the retained four-field semantic.
    private enum CanonicalJSON {
        static func encode(_ value: Semantic) throws -> Data {
            guard validSemantic(value) else {
                throw CodecFailure.semantic
            }
            let text = "{\"authority_vector\":\"\(value.authorityVector)\"," +
                "\"claim_state\":\"\(value.claimState.rawValue)\"," +
                "\"predicate_count\":\(value.predicateCount)," +
                "\"schema\":\"\(value.schema)\"}"
            let bytes = Data(text.utf8)
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw CodecFailure.bound
            }
            return bytes
        }

        static func decode(_ bytes: Data) throws -> Semantic {
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw CodecFailure.bound
            }
            var parser = Parser(bytes: Array(bytes))
            let value = try parser.takeSemantic()
            guard validSemantic(value) else {
                throw CodecFailure.semantic
            }
            guard try encode(value) == bytes else {
                throw CodecFailure.noncanonical
            }
            return value
        }

        private struct Parser {
            let bytes: [UInt8]
            var offset = 0

            mutating func takeSemantic() throws -> Semantic {
                try takeLiteral("{\"authority_vector\":")
                let authorityVector = try takeString()
                try takeLiteral(",\"claim_state\":")
                let claim = try takeString()
                try takeLiteral(",\"predicate_count\":")
                let count = try takeUnsigned()
                try takeLiteral(",\"schema\":")
                let schema = try takeString()
                try takeLiteral("}")
                guard offset == bytes.count else {
                    throw CodecFailure.noncanonical
                }
                guard let claimState = ClaimState(rawValue: claim),
                      let predicateCount = UInt32(exactly: count) else {
                    throw CodecFailure.semantic
                }
                return Semantic(
                    schema: schema,
                    claimState: claimState,
                    predicateCount: predicateCount,
                    authorityVector: authorityVector
                )
            }

            mutating func takeLiteral(_ literal: String) throws {
                let value = Array(literal.utf8)
                guard value.count <= bytes.count - offset,
                      bytes[offset..<(offset + value.count)]
                        .elementsEqual(value) else {
                    throw CodecFailure.malformed
                }
                offset += value.count
            }

            mutating func takeString() throws -> String {
                guard offset < bytes.count, bytes[offset] == 0x22 else {
                    throw CodecFailure.malformed
                }
                offset += 1
                let start = offset
                while offset < bytes.count, bytes[offset] != 0x22 {
                    let byte = bytes[offset]
                    guard byte >= 0x20, byte <= 0x7e, byte != 0x5c,
                          offset - start < 128 else {
                        throw CodecFailure.malformed
                    }
                    offset += 1
                }
                guard offset < bytes.count, bytes[offset] == 0x22 else {
                    throw CodecFailure.malformed
                }
                let value = String(decoding: bytes[start..<offset], as: UTF8.self)
                offset += 1
                return value
            }

            mutating func takeUnsigned() throws -> UInt64 {
                guard offset < bytes.count,
                      (0x30...0x39).contains(bytes[offset]) else {
                    throw CodecFailure.malformed
                }
                if bytes[offset] == 0x30 {
                    offset += 1
                    if offset < bytes.count,
                       (0x30...0x39).contains(bytes[offset]) {
                        throw CodecFailure.noncanonical
                    }
                    return 0
                }
                var value: UInt64 = 0
                var digits = 0
                while offset < bytes.count,
                      (0x30...0x39).contains(bytes[offset]) {
                    let digit = UInt64(bytes[offset] - 0x30)
                    let multiplied = value.multipliedReportingOverflow(by: 10)
                    let added = multiplied.partialValue
                        .addingReportingOverflow(digit)
                    guard !multiplied.overflow, !added.overflow, digits < 10 else {
                        throw CodecFailure.semantic
                    }
                    value = added.partialValue
                    digits += 1
                    offset += 1
                }
                return value
            }
        }
    }

    /// Schema-specific RFC 8949 core-deterministic CBOR.
    private enum DeterministicCBOR {
        static func encode(_ value: Semantic) throws -> Data {
            guard validSemantic(value) else {
                throw CodecFailure.semantic
            }
            var writer = Writer()
            try writer.argument(major: 5, value: 4)
            try writer.text("schema")
            try writer.text(value.schema)
            try writer.text("claim_state")
            try writer.text(value.claimState.rawValue)
            try writer.text("predicate_count")
            try writer.argument(major: 0, value: UInt64(value.predicateCount))
            try writer.text("authority_vector")
            try writer.text(value.authorityVector)
            return writer.output
        }

        static func decode(_ bytes: Data) throws -> Semantic {
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw CodecFailure.bound
            }
            var parser = Parser(bytes: Array(bytes))
            let value = try parser.takeSemantic()
            guard validSemantic(value) else {
                throw CodecFailure.semantic
            }
            guard try encode(value) == bytes else {
                throw CodecFailure.noncanonical
            }
            return value
        }

        private struct Writer {
            var output = Data()

            mutating func append(_ bytes: Data) throws {
                guard bytes.count <= maximumStreamBytes - output.count else {
                    throw CodecFailure.bound
                }
                output.append(bytes)
            }

            mutating func argument(major: UInt8, value: UInt64) throws {
                var frame = Data()
                if value < 24 {
                    frame.append((major << 5) | UInt8(value))
                } else {
                    let width: Int
                    let additional: UInt8
                    if value <= 0xff {
                        width = 1
                        additional = 24
                    } else if value <= 0xffff {
                        width = 2
                        additional = 25
                    } else if value <= 0xffff_ffff {
                        width = 4
                        additional = 26
                    } else {
                        width = 8
                        additional = 27
                    }
                    frame.append((major << 5) | additional)
                    for index in (0..<width).reversed() {
                        frame.append(UInt8(
                            truncatingIfNeeded: value >> UInt64(index * 8)
                        ))
                    }
                }
                try append(frame)
            }

            mutating func text(_ value: String) throws {
                let bytes = Data(value.utf8)
                guard bytes.count <= 128 else {
                    throw CodecFailure.bound
                }
                try argument(major: 3, value: UInt64(bytes.count))
                try append(bytes)
            }
        }

        private struct Parser {
            let bytes: [UInt8]
            var offset = 0

            mutating func takeSemantic() throws -> Semantic {
                guard try argument(major: 5) == 4 else {
                    throw CodecFailure.noncanonical
                }
                try takeTextLiteral("schema")
                let schema = try takeText()
                try takeTextLiteral("claim_state")
                let claim = try takeText()
                try takeTextLiteral("predicate_count")
                let count = try argument(major: 0)
                try takeTextLiteral("authority_vector")
                let authorityVector = try takeText()
                guard offset == bytes.count else {
                    throw CodecFailure.noncanonical
                }
                guard let claimState = ClaimState(rawValue: claim),
                      let predicateCount = UInt32(exactly: count) else {
                    throw CodecFailure.semantic
                }
                return Semantic(
                    schema: schema,
                    claimState: claimState,
                    predicateCount: predicateCount,
                    authorityVector: authorityVector
                )
            }

            mutating func takeTextLiteral(_ literal: String) throws {
                guard try takeText().utf8.elementsEqual(literal.utf8) else {
                    throw CodecFailure.noncanonical
                }
            }

            mutating func takeText() throws -> String {
                let count = try argument(major: 3)
                guard count <= 128,
                      count <= UInt64(bytes.count - offset) else {
                    throw CodecFailure.malformed
                }
                let end = offset + Int(count)
                guard let value = String(
                    data: Data(bytes[offset..<end]),
                    encoding: .utf8
                ) else {
                    throw CodecFailure.malformed
                }
                offset = end
                return value
            }

            mutating func argument(major requiredMajor: UInt8) throws -> UInt64 {
                guard offset < bytes.count else {
                    throw CodecFailure.malformed
                }
                let initial = bytes[offset]
                offset += 1
                guard initial >> 5 == requiredMajor else {
                    throw CodecFailure.malformed
                }
                let additional = initial & 31
                if additional < 24 {
                    return UInt64(additional)
                }
                let width: Int
                switch additional {
                case 24: width = 1
                case 25: width = 2
                case 26: width = 4
                case 27: width = 8
                default: throw CodecFailure.malformed
                }
                guard width <= bytes.count - offset else {
                    throw CodecFailure.malformed
                }
                var value: UInt64 = 0
                for _ in 0..<width {
                    value = (value << 8) | UInt64(bytes[offset])
                    offset += 1
                }
                let minimum: UInt64
                switch width {
                case 1: minimum = 24
                case 2: minimum = 256
                case 4: minimum = 65_536
                default: minimum = 4_294_967_296
                }
                guard value >= minimum else {
                    throw CodecFailure.noncanonical
                }
                return value
            }
        }
    }
}

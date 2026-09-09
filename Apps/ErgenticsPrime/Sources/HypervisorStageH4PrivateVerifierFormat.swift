import CryptoKit
import Foundation

/// Pure, bounded wire-format and cryptographic primitives for the sealed H4
/// private-verifier format. This namespace performs no I/O, key generation,
/// nonce construction, persistence, logging, or authority transition.
/// CryptoKit may use implementation-internal entropy to hedge signing.
enum HypervisorStageH4PrivateVerifierFormat {
    static let suiteID =
        "com.ergentics.provenance.hypervisor.h4.private-verifier.sha256-hmacsha256-ed25519-cbor.v1"
    static let lineageFormatID =
        "com.ergentics.provenance.hypervisor.h4.lineage.sha256-hmacsha256-cbor.v1"
    static let maximumCanonicalBytes = 1_048_576
    static let maximumDepth = 8
    static let maximumMapEntries = 64
    static let maximumArrayEntries = 256
    static let maximumNodes = 8_192
    static let maximumTextBytes = 128
    private static let blindUseLock = NSLock()

    enum Failure: Error, Equatable, Sendable {
        case bound
        case overflow
        case malformed
        case noncanonical
        case unsupported
        case schema
        case fieldInventory
        case fieldType
        case fieldValue
        case crossField
        case key
        case signature
    }

    enum Domain: String, CaseIterable, Hashable, Sendable {
        case issuerKeyID = "com.ergentics.provenance.h4pv1.key-id.issuer"
        case verifierKeyID = "com.ergentics.provenance.h4pv1.key-id.verifier"
        case storageKeyID = "com.ergentics.provenance.h4pv1.key-id.storage"
        case disclosureModeTable = "com.ergentics.provenance.h4pv1.record.disclosure-mode-table"
        case policy = "com.ergentics.provenance.h4pv1.record.policy"
        case privateToken = "com.ergentics.provenance.h4pv1.private-token"
        case canonicalJSONPreimage = "com.ergentics.provenance.h4pv1.private-preimage.canonical-json"
        case deterministicCBORPreimage = "com.ergentics.provenance.h4pv1.private-preimage.deterministic-cbor"
        case genesisInitial = "com.ergentics.provenance.h4pv1.record.genesis-initial"
        case genesisMigrationIntent = "com.ergentics.provenance.h4pv1.record.genesis-migration-intent"
        case fixedPredecessor = "com.ergentics.provenance.h4pv1.fixed-predecessor"
        case uninitializedRecord = "com.ergentics.provenance.h4pv1.record.uninitialized"
        case lineageState = "com.ergentics.provenance.h4pv1.record.lineage-state"
        case assertionBody = "com.ergentics.provenance.h4pv1.record.assertion-body"
        case issuerSignature = "com.ergentics.provenance.h4pv1.signature.issuer-assertion"
        case issuerEnvelope = "com.ergentics.provenance.h4pv1.record.issuer-envelope"
        case challengeBody = "com.ergentics.provenance.h4pv1.record.challenge"
        case challengeSignature = "com.ergentics.provenance.h4pv1.signature.challenge"
        case request = "com.ergentics.provenance.h4pv1.record.request"
        case decision = "com.ergentics.provenance.h4pv1.record.decision"
        case acceptedRecord = "com.ergentics.provenance.h4pv1.record.accepted"
        case conflictTombstone = "com.ergentics.provenance.h4pv1.record.conflict"
        case storageFaultLatch = "com.ergentics.provenance.h4pv1.record.storage-fault"
        case terminalClose = "com.ergentics.provenance.h4pv1.record.terminal-close"
        case terminalMigration = "com.ergentics.provenance.h4pv1.record.terminal-migration"
        case terminalRequest = "com.ergentics.provenance.h4pv1.record.terminal-request"
        case migrationBody = "com.ergentics.provenance.h4pv1.record.migration"
        case migrationSignature = "com.ergentics.provenance.h4pv1.signature.migration"
        case verifierEnvelope = "com.ergentics.provenance.h4pv1.record.verifier-envelope"
        case receiptAcceptedCurrent = "com.ergentics.provenance.h4pv1.record.receipt-accepted-current"
        case receiptMinimized = "com.ergentics.provenance.h4pv1.record.receipt-minimized"
        case receiptTerminal = "com.ergentics.provenance.h4pv1.record.receipt-terminal"
        case receiptSignature = "com.ergentics.provenance.h4pv1.signature.receipt"
        case storageGenesisTag = "com.ergentics.provenance.h4pv1.storage.genesis-tag"
        case storageRecordAuth = "com.ergentics.provenance.h4pv1.storage.record-auth"
        case authorityPointer = "com.ergentics.provenance.h4pv1.storage.authority-pointer"
        case authorityPointerAuth = "com.ergentics.provenance.h4pv1.storage.authority-pointer-auth"
    }

    enum Schema: String, CaseIterable, Hashable, Sendable {
        case privateTokenDescriptor = "com.ergentics.provenance.h4pv1.private-token-input.v1"
        case disclosureModeTable = "com.ergentics.provenance.h4pv1.disclosure-mode-table.v1"
        case policy = "com.ergentics.provenance.h4pv1.policy.v1"
        case genesisInitial = "com.ergentics.provenance.h4pv1.genesis-initial.v1"
        case genesisMigrationIntent = "com.ergentics.provenance.h4pv1.genesis-migration-intent.v1"
        case uninitializedRecord = "com.ergentics.provenance.h4pv1.uninitialized-record.v1"
        case lineageState = "com.ergentics.provenance.h4pv1.lineage-state.v1"
        case issuerAssertion = "com.ergentics.provenance.h4pv1.issuer-assertion.v1"
        case issuerSignatureEnvelope = "com.ergentics.provenance.h4pv1.issuer-signature-envelope.v1"
        case challenge = "com.ergentics.provenance.h4pv1.challenge.v1"
        case verifierSignatureEnvelope = "com.ergentics.provenance.h4pv1.verifier-signature-envelope.v1"
        case assertionRequest = "com.ergentics.provenance.h4pv1.assertion-request.v1"
        case verifierDecision = "com.ergentics.provenance.h4pv1.verifier-decision.v1"
        case acceptedTransition = "com.ergentics.provenance.h4pv1.accepted-transition.v1"
        case conflictTombstone = "com.ergentics.provenance.h4pv1.conflict-tombstone.v1"
        case storageFaultLatch = "com.ergentics.provenance.h4pv1.storage-fault-latch.v1"
        case terminalClose = "com.ergentics.provenance.h4pv1.terminal-close.v1"
        case terminalMigration = "com.ergentics.provenance.h4pv1.terminal-migration.v1"
        case storageRecordWrapper = "com.ergentics.provenance.h4pv1.storage-record-wrapper.v1"
        case authorityPointer = "com.ergentics.provenance.h4pv1.authority-pointer.v1"
        case terminalCloseRequest = "com.ergentics.provenance.h4pv1.terminal-close-request.v1"
        case terminalMigrationRequest = "com.ergentics.provenance.h4pv1.terminal-migration-request.v1"
        case migrationAuthorization = "com.ergentics.provenance.h4pv1.migration-authorization.v1"
        case receiptAcceptedCurrent = "com.ergentics.provenance.h4pv1.receipt-accepted-current.v1"
        case receiptMinimized = "com.ergentics.provenance.h4pv1.receipt-minimized.v1"
        case receiptTerminal = "com.ergentics.provenance.h4pv1.receipt-terminal.v1"

        var maximumBytes: Int {
            switch self {
            case .issuerSignatureEnvelope, .verifierSignatureEnvelope:
                return 1_024
            case .disclosureModeTable, .challenge, .verifierDecision,
                    .authorityPointer, .terminalCloseRequest,
                    .terminalMigrationRequest, .receiptMinimized, .receiptTerminal:
                return 4_096
            case .storageFaultLatch:
                return 8_192
            case .policy, .genesisInitial, .genesisMigrationIntent,
                    .issuerAssertion, .acceptedTransition, .terminalClose,
                    .terminalMigration, .migrationAuthorization,
                    .receiptAcceptedCurrent:
                return 16_384
            case .conflictTombstone:
                return 32_768
            case .uninitializedRecord:
                return 65_536
            case .lineageState:
                return 524_288
            case .privateTokenDescriptor, .assertionRequest, .storageRecordWrapper:
                return maximumCanonicalBytes
            }
        }

        var commitmentDomain: Domain? {
            switch self {
            case .privateTokenDescriptor, .storageRecordWrapper: return nil
            case .disclosureModeTable: return .disclosureModeTable
            case .policy: return .policy
            case .genesisInitial: return .genesisInitial
            case .genesisMigrationIntent: return .genesisMigrationIntent
            case .uninitializedRecord: return .uninitializedRecord
            case .lineageState: return .lineageState
            case .issuerAssertion: return .assertionBody
            case .issuerSignatureEnvelope: return .issuerEnvelope
            case .challenge: return .challengeBody
            case .verifierSignatureEnvelope: return .verifierEnvelope
            case .assertionRequest: return .request
            case .verifierDecision: return .decision
            case .acceptedTransition: return .acceptedRecord
            case .conflictTombstone: return .conflictTombstone
            case .storageFaultLatch: return .storageFaultLatch
            case .terminalClose: return .terminalClose
            case .terminalMigration: return .terminalMigration
            case .authorityPointer: return .authorityPointer
            case .terminalCloseRequest, .terminalMigrationRequest: return .terminalRequest
            case .migrationAuthorization: return .migrationBody
            case .receiptAcceptedCurrent: return .receiptAcceptedCurrent
            case .receiptMinimized: return .receiptMinimized
            case .receiptTerminal: return .receiptTerminal
            }
        }
    }

    indirect enum Value: Equatable, Sendable {
        case unsigned(UInt64)
        case bytes(Data)
        case text(String)
        case array([Value])
        case map([String: Value])
        case bool(Bool)
    }

    struct Fixed32: Equatable, Hashable, Sendable {
        let bytes: Data

        init(_ bytes: Data) throws {
            guard bytes.count == 32 else { throw Failure.fieldValue }
            self.bytes = bytes
        }
    }

    struct Fixed64: Equatable, Hashable, Sendable {
        let bytes: Data

        init(_ bytes: Data) throws {
            guard bytes.count == 64 else { throw Failure.fieldValue }
            self.bytes = bytes
        }
    }

    struct CanonicalObject: Equatable, Sendable {
        let schema: Schema
        let fields: [String: Value]
        let bytes: Data
    }

    struct CompletedPrivateTokens: Equatable, Sendable {
        let d3Semantic: Fixed32
        let canonicalJSON: Fixed32
        let deterministicCBOR: Fixed32
        let indexedScalar: Fixed32
        let graph: Fixed32
        let predicateIdentifiers: Data
        let predicateEvidence: Data
        let counts: PrivateTokenCountProjection
        let context: PrivateTokenContextProjection

        fileprivate init(
            singletons: [Fixed32],
            predicateIdentifiers: Data,
            predicateEvidence: Data,
            counts: PrivateTokenCountProjection,
            context: PrivateTokenContextProjection
        ) {
            precondition(singletons.count == 5)
            d3Semantic = singletons[0]
            canonicalJSON = singletons[1]
            deterministicCBOR = singletons[2]
            indexedScalar = singletons[3]
            graph = singletons[4]
            self.predicateIdentifiers = predicateIdentifiers
            self.predicateEvidence = predicateEvidence
            self.counts = counts
            self.context = context
        }
    }

    struct PrivateTokenContextProjection: Equatable, Sendable {
        let lineageFormatID: String
        let productID: String
        let roadmapStageID: String
        let stageID: String
        let durableSchemaID: String
        let purposeID: String
        let lineageID: Fixed32
        let epochID: Fixed32
        let sequence: UInt64
    }

    struct PrivateTokenCountProjection: Equatable, Sendable {
        let canonicalJSONByteCount: UInt64
        let deterministicCBORByteCount: UInt64
        let graphStateCount: UInt64
        let graphWitnessCount: UInt64
        let graphTransitionCount: UInt64
        let predicateIdentifierByteCounts: [UInt64]
        let predicateEvidenceByteCounts: [UInt64]

        var predicateCount: UInt64 {
            UInt64(predicateIdentifierByteCounts.count)
        }
    }

    /// A process-memory-only one-use capability. Successful completion releases
    /// its fabricated or caller-supplied bytes; no blind is returned or retained
    /// in CompletedPrivateTokens. Reusing the same capability fails closed.
    final class OneUseBlind: @unchecked Sendable {
        fileprivate var bytes: Data?

        init(_ bytes: Data) throws {
            guard bytes.count == 32 else { throw Failure.key }
            self.bytes = bytes
        }
    }

    struct CompletedAssertion: Equatable, Sendable {
        let lineageState: CanonicalObject
        let issuerAssertion: CanonicalObject
        let issuerEnvelope: CanonicalObject

        fileprivate init(
            lineageState: CanonicalObject,
            issuerAssertion: CanonicalObject,
            issuerEnvelope: CanonicalObject
        ) {
            self.lineageState = lineageState
            self.issuerAssertion = issuerAssertion
            self.issuerEnvelope = issuerEnvelope
        }
    }

    struct ProvisionedContext: Equatable, Sendable {
        let disclosureModeTable: CanonicalObject
        let policy: CanonicalObject
        let trustedGenesis: CanonicalObject
        let policyCommitment: Fixed32
        let trustedGenesisCommitment: Fixed32
        let verifierID: Fixed32
        let verifierPublicKey: Fixed32
        let issuerKeyID: Fixed32
        let issuerPublicKey: Fixed32
        let storageKeyID: Fixed32
        let audienceID: Fixed32
        let lineageID: Fixed32
        let epochID: Fixed32

        fileprivate init(
            disclosureModeTable: CanonicalObject,
            policy: CanonicalObject,
            trustedGenesis: CanonicalObject,
            policyCommitment: Fixed32,
            trustedGenesisCommitment: Fixed32,
            verifierID: Fixed32,
            verifierPublicKey: Fixed32,
            issuerKeyID: Fixed32,
            issuerPublicKey: Fixed32,
            storageKeyID: Fixed32,
            audienceID: Fixed32,
            lineageID: Fixed32,
            epochID: Fixed32
        ) {
            self.disclosureModeTable = disclosureModeTable
            self.policy = policy
            self.trustedGenesis = trustedGenesis
            self.policyCommitment = policyCommitment
            self.trustedGenesisCommitment = trustedGenesisCommitment
            self.verifierID = verifierID
            self.verifierPublicKey = verifierPublicKey
            self.issuerKeyID = issuerKeyID
            self.issuerPublicKey = issuerPublicKey
            self.storageKeyID = storageKeyID
            self.audienceID = audienceID
            self.lineageID = lineageID
            self.epochID = epochID
        }
    }

    struct VerifiedEnvelope: Equatable, Sendable {
        let body: CanonicalObject
        let bodyCommitment: Fixed32
        let envelope: CanonicalObject
        let envelopeCommitment: Fixed32

        fileprivate init(
            body: CanonicalObject,
            bodyCommitment: Fixed32,
            envelope: CanonicalObject,
            envelopeCommitment: Fixed32
        ) {
            self.body = body
            self.bodyCommitment = bodyCommitment
            self.envelope = envelope
            self.envelopeCommitment = envelopeCommitment
        }
    }

    struct VerifiedMigrationAuthorization: Equatable, Sendable {
        let body: CanonicalObject
        let bodyCommitment: Fixed32
        let envelope: CanonicalObject
        let envelopeCommitment: Fixed32

        fileprivate init(
            body: CanonicalObject,
            bodyCommitment: Fixed32,
            envelope: CanonicalObject,
            envelopeCommitment: Fixed32
        ) {
            self.body = body
            self.bodyCommitment = bodyCommitment
            self.envelope = envelope
            self.envelopeCommitment = envelopeCommitment
        }
    }

    struct ChallengeReference: Equatable, Hashable, Sendable {
        let bodyCommitment: Fixed32
        let envelopeCommitment: Fixed32
    }

    struct AuthenticatedBinding: Equatable, Sendable {
        let challenge: ChallengeReference
        let requestCommitment: Fixed32
    }

    struct EligibleRequest: Equatable, Sendable {
        let binding: AuthenticatedBinding
        let lineageStateCommitment: Fixed32
        let assertionBodyCommitment: Fixed32
        let issuerEnvelopeCommitment: Fixed32
        let assertionInstanceNonce: Fixed32
        let sequence: UInt64
        let predecessorLineageStateCommitment: Fixed32
    }

    enum AssertionValidation: Equatable, Sendable {
        case noAuthenticatedResponse
        case authenticatedRejected(AuthenticatedBinding)
        case eligible(EligibleRequest)
    }

    enum StoragePredecessor: Equatable, Sendable {
        case genesis(ProvisionedContext)
        case record(VerifiedStoredRecord)
    }

    struct StorageEpochAnchor: Equatable, Sendable {
        let trustedGenesisCommitment: Fixed32
        let policyCommitment: Fixed32
        let verifierID: Fixed32
        let lineageID: Fixed32
        let epochID: Fixed32
        let storageKeyID: Fixed32

        fileprivate init(
            trustedGenesisCommitment: Fixed32,
            policyCommitment: Fixed32,
            verifierID: Fixed32,
            lineageID: Fixed32,
            epochID: Fixed32,
            storageKeyID: Fixed32
        ) {
            self.trustedGenesisCommitment = trustedGenesisCommitment
            self.policyCommitment = policyCommitment
            self.verifierID = verifierID
            self.lineageID = lineageID
            self.epochID = epochID
            self.storageKeyID = storageKeyID
        }
    }

    struct VerifiedStoredRecord: Equatable, Sendable {
        let body: CanonicalObject
        let wrapper: CanonicalObject
        let bodyCommitment: Fixed32
        let authenticationTag: Fixed32
        let epochAnchor: StorageEpochAnchor
        let kind: UInt64
        let index: UInt64

        var storageKeyID: Fixed32 { epochAnchor.storageKeyID }

        fileprivate init(
            body: CanonicalObject,
            wrapper: CanonicalObject,
            bodyCommitment: Fixed32,
            authenticationTag: Fixed32,
            epochAnchor: StorageEpochAnchor,
            kind: UInt64,
            index: UInt64
        ) {
            self.body = body
            self.wrapper = wrapper
            self.bodyCommitment = bodyCommitment
            self.authenticationTag = authenticationTag
            self.epochAnchor = epochAnchor
            self.kind = kind
            self.index = index
        }
    }

    struct VerifiedAuthorityState: Equatable, Sendable {
        let pointer: CanonicalObject
        let pointerCommitment: Fixed32
        let authenticationTag: Fixed32
        let epochAnchor: StorageEpochAnchor
        let tip: VerifiedStoredRecord
        let accepted: VerifiedStoredRecord?

        var storageKeyID: Fixed32 { epochAnchor.storageKeyID }

        fileprivate init(
            pointer: CanonicalObject,
            pointerCommitment: Fixed32,
            authenticationTag: Fixed32,
            epochAnchor: StorageEpochAnchor,
            tip: VerifiedStoredRecord,
            accepted: VerifiedStoredRecord?
        ) {
            self.pointer = pointer
            self.pointerCommitment = pointerCommitment
            self.authenticationTag = authenticationTag
            self.epochAnchor = epochAnchor
            self.tip = tip
            self.accepted = accepted
        }
    }

    static func frame(domain: Domain, payload: Data) throws -> Data {
        let domainBytes = Data(domain.rawValue.utf8)
        guard !domainBytes.isEmpty, domainBytes.count <= 127,
              domainBytes.allSatisfy({ (0x20...0x7e).contains($0) }),
              payload.count <= maximumCanonicalBytes else {
            throw Failure.bound
        }
        let first = 8.addingReportingOverflow(2)
        let second = first.partialValue.addingReportingOverflow(domainBytes.count)
        let third = second.partialValue.addingReportingOverflow(8)
        let total = third.partialValue.addingReportingOverflow(payload.count)
        guard !first.overflow, !second.overflow, !third.overflow, !total.overflow else {
            throw Failure.overflow
        }
        var result = Data()
        result.reserveCapacity(total.partialValue)
        result.append(contentsOf: [0x45, 0x50, 0x52, 0x48, 0x34, 0x50, 0x56, 0x31])
        appendBigEndian(UInt16(domainBytes.count), to: &result)
        result.append(domainBytes)
        appendBigEndian(UInt64(payload.count), to: &result)
        result.append(payload)
        return result
    }

    static func commitment(domain: Domain, payload: Data) throws -> Data {
        guard sha256Domains.contains(domain) else { throw Failure.unsupported }
        let digest = Data(SHA256.hash(data: try frame(domain: domain, payload: payload)))
        guard !digest.allSatisfy({ $0 == 0 }) else { throw Failure.fieldValue }
        return digest
    }

    static func authenticationCode(key: Data, domain: Domain, payload: Data) throws -> Data {
        guard key.count == 32 else { throw Failure.key }
        guard hmacDomains.contains(domain) else { throw Failure.unsupported }
        let message = try frame(domain: domain, payload: payload)
        return Data(HMAC<SHA256>.authenticationCode(
            for: message,
            using: SymmetricKey(data: key)
        ))
    }

    static func verifyAuthenticationCode(
        _ code: Data,
        key: Data,
        domain: Domain,
        payload: Data
    ) throws -> Bool {
        guard key.count == 32 else { throw Failure.key }
        guard hmacDomains.contains(domain) else { throw Failure.unsupported }
        guard code.count == 32 else { return false }
        return HMAC<SHA256>.isValidAuthenticationCode(
            code,
            authenticating: try frame(domain: domain, payload: payload),
            using: SymmetricKey(data: key)
        )
    }

    static func issuerKeyID(publicKey: Data) throws -> Data {
        guard strictPointEncoding(publicKey) else { throw Failure.key }
        return try commitment(domain: .issuerKeyID, payload: publicKey)
    }

    static func verifierKeyID(publicKey: Data) throws -> Data {
        guard strictPointEncoding(publicKey) else { throw Failure.key }
        return try commitment(domain: .verifierKeyID, payload: publicKey)
    }

    static func storageKeyID(key: Data) throws -> Data {
        guard key.count == 32 else { throw Failure.key }
        return try commitment(domain: .storageKeyID, payload: key)
    }

    static func publicKey(seed: Data) throws -> Data {
        guard seed.count == 32 else { throw Failure.key }
        return try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
            .publicKey.rawRepresentation
    }

    static func sign(seed: Data, domain: Domain, payload: Data) throws -> Data {
        guard seed.count == 32 else { throw Failure.key }
        guard signatureDomains.contains(domain) else { throw Failure.unsupported }
        // A valid Ed25519 signature is canonical, but CryptoKit does not promise
        // byte-identical signatures across calls because it may hedge signing.
        let signature = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
            .signature(for: frame(domain: domain, payload: payload))
        guard signature.count == 64 else { throw Failure.signature }
        return signature
    }

    static func verify(
        signature: Data,
        publicKey: Data,
        domain: Domain,
        payload: Data
    ) throws -> Bool {
        guard signatureDomains.contains(domain) else { throw Failure.unsupported }
        guard strictPointEncoding(publicKey), signature.count == 64 else { return false }
        let r = Data(signature.prefix(32))
        let s = Data(signature.suffix(32))
        guard strictPointEncoding(r), scalarIsLessThanOrder(s) else { return false }
        let message = try frame(domain: domain, payload: payload)
        do {
            return try Curve25519.Signing.PublicKey(rawRepresentation: publicKey)
                .isValidSignature(signature, for: message)
        } catch {
            return false
        }
    }

    static func canonicalJSONPreimageDigest(_ bytes: Data) throws -> Data {
        try validateH4CCanonicalJSON(bytes)
        return try commitment(domain: .canonicalJSONPreimage, payload: bytes)
    }

    static func deterministicCBORPreimageDigest(_ bytes: Data) throws -> Data {
        try validateH4CDeterministicCBOR(bytes)
        return try commitment(domain: .deterministicCBORPreimage, payload: bytes)
    }

    private static func uncheckedPrivateToken(blind: Data, descriptor: Data) throws -> Data {
        try validate(descriptor, as: .privateTokenDescriptor)
        return try authenticationCode(key: blind, domain: .privateToken, payload: descriptor)
    }

    private static func privateTokenContext(
        in values: [String: Value]
    ) throws -> PrivateTokenContextProjection {
        try PrivateTokenContextProjection(
            lineageFormatID: textValue("lineage_format_id", in: values),
            productID: textValue("product_id", in: values),
            roadmapStageID: textValue("roadmap_stage_id", in: values),
            stageID: textValue("stage_id", in: values),
            durableSchemaID: textValue("durable_schema_id", in: values),
            purposeID: textValue("purpose_id", in: values),
            lineageID: Fixed32(bytes("lineage_id", in: values)),
            epochID: Fixed32(bytes("epoch_id", in: values)),
            sequence: unsigned("sequence", in: values)
        )
    }

    /// Completes one lineage construction without retaining any blind or descriptor.
    /// Input order is kinds 0...4, all kind-5 ordinals, then all kind-6 ordinals.
    static func completePrivateTokens(
        blinds: [OneUseBlind],
        descriptors: [Data],
        counts: PrivateTokenCountProjection
    ) throws -> CompletedPrivateTokens {
        let predicateCount = counts.predicateCount
        guard (1...4_096).contains(predicateCount) else { throw Failure.bound }
        guard counts.predicateEvidenceByteCounts.count ==
                counts.predicateIdentifierByteCounts.count,
              (1...158).contains(counts.canonicalJSONByteCount),
              (1...158).contains(counts.deterministicCBORByteCount),
              counts.graphStateCount <= 4_096,
              counts.graphWitnessCount <= 4_096,
              counts.graphTransitionCount <= 4_096,
              counts.predicateIdentifierByteCounts.allSatisfy({ $0 <= 1_048_576 }),
              counts.predicateEvidenceByteCounts.allSatisfy({ $0 <= 1_048_576 }) else {
            throw Failure.bound
        }
        let doubled = predicateCount.multipliedReportingOverflow(by: 2)
        let total = UInt64(5).addingReportingOverflow(doubled.partialValue)
        guard !doubled.overflow, !total.overflow,
              let exactCount = Int(exactly: total.partialValue) else {
            throw Failure.overflow
        }
        guard blinds.count == exactCount, descriptors.count == exactCount else {
            throw Failure.crossField
        }
        let packedLengths = try checkedPredicateLengths(predicateCount)
        var decodedDescriptors: [CanonicalObject] = []
        decodedDescriptors.reserveCapacity(exactCount)
        var sharedContext: PrivateTokenContextProjection?

        // Complete every structural, ordering, count and uniqueness check before
        // the first one-use HMAC is evaluated.
        for index in 0..<exactCount {
            let descriptor = try decode(
                descriptors[index],
                as: .privateTokenDescriptor
            )
            let expectedKind: UInt64
            let expectedOrdinal: UInt64
            if index < 5 {
                expectedKind = UInt64(index)
                expectedOrdinal = 0
            } else if index < 5 + packedLengths.results {
                expectedKind = 5
                expectedOrdinal = UInt64(index - 5)
            } else {
                expectedKind = 6
                expectedOrdinal = UInt64(index - 5 - packedLengths.results)
            }
            guard try unsigned("field_kind", in: descriptor.fields) == expectedKind,
                  try unsigned("field_ordinal", in: descriptor.fields) == expectedOrdinal else {
                throw Failure.crossField
            }
            switch expectedKind {
            case 1:
                guard try unsigned("byte_count", in: descriptor.fields) ==
                        counts.canonicalJSONByteCount else {
                    throw Failure.crossField
                }
            case 2:
                guard try unsigned("byte_count", in: descriptor.fields) ==
                        counts.deterministicCBORByteCount else {
                    throw Failure.crossField
                }
            case 4:
                guard try unsigned("member_count_0", in: descriptor.fields) ==
                        counts.graphStateCount,
                      try unsigned("member_count_1", in: descriptor.fields) ==
                        counts.graphWitnessCount,
                      try unsigned("member_count_2", in: descriptor.fields) ==
                        counts.graphTransitionCount else {
                    throw Failure.crossField
                }
            case 5:
                guard try unsigned("byte_count", in: descriptor.fields) ==
                        counts.predicateIdentifierByteCounts[Int(expectedOrdinal)] else {
                    throw Failure.crossField
                }
            case 6:
                guard try unsigned("byte_count", in: descriptor.fields) ==
                        counts.predicateEvidenceByteCounts[Int(expectedOrdinal)] else {
                    throw Failure.crossField
                }
            default:
                break
            }
            let projected = try privateTokenContext(in: descriptor.fields)
            if let sharedContext {
                guard projected == sharedContext else { throw Failure.crossField }
            } else {
                sharedContext = projected
            }
            decodedDescriptors.append(descriptor)
        }
        guard let sharedContext else { throw Failure.crossField }

        blindUseLock.lock()
        defer { blindUseLock.unlock() }
        var rawBlinds: [Data] = []
        rawBlinds.reserveCapacity(exactCount)
        var distinctBlinds = Set<Data>()
        var distinctCapabilities = Set<ObjectIdentifier>()
        for blind in blinds {
            let identity = ObjectIdentifier(blind)
            guard distinctCapabilities.insert(identity).inserted,
                  let bytes = blind.bytes,
                  distinctBlinds.insert(bytes).inserted else {
                throw Failure.key
            }
            rawBlinds.append(bytes)
        }

        var singletonTokens: [Fixed32] = []
        singletonTokens.reserveCapacity(5)
        var identifierTokens = Data()
        identifierTokens.reserveCapacity(packedLengths.packed)
        var evidenceTokens = Data()
        evidenceTokens.reserveCapacity(packedLengths.packed)
        for index in 0..<exactCount {
            let token = try Fixed32(uncheckedPrivateToken(
                blind: rawBlinds[index],
                descriptor: decodedDescriptors[index].bytes
            ))
            if index < 5 { singletonTokens.append(token) }
            else if index < 5 + packedLengths.results {
                identifierTokens.append(token.bytes)
            } else { evidenceTokens.append(token.bytes) }
        }
        guard singletonTokens.count == 5,
              identifierTokens.count == packedLengths.packed,
              evidenceTokens.count == packedLengths.packed else {
            throw Failure.crossField
        }
        for blind in blinds { blind.bytes = nil }
        return CompletedPrivateTokens(
            singletons: singletonTokens,
            predicateIdentifiers: identifierTokens,
            predicateEvidence: evidenceTokens,
            counts: counts,
            context: sharedContext
        )
    }

    static func validateCompletedPrivateTokens(
        _ completed: CompletedPrivateTokens,
        lineageStateBytes: Data
    ) throws -> CanonicalObject {
        let lineage = try decode(lineageStateBytes, as: .lineageState)
        let counts = completed.counts
        let tokenContext = completed.context
        guard try bytes("d3_semantic_private_token", in: lineage.fields) ==
                completed.d3Semantic.bytes,
              try bytes("canonical_json_private_token", in: lineage.fields) ==
                completed.canonicalJSON.bytes,
              try bytes("deterministic_cbor_private_token", in: lineage.fields) ==
                completed.deterministicCBOR.bytes,
              try bytes("indexed_scalar_private_token", in: lineage.fields) ==
                completed.indexedScalar.bytes,
              try bytes("graph_private_token", in: lineage.fields) ==
                completed.graph.bytes,
              try bytes("predicate_identifier_tokens", in: lineage.fields) ==
                completed.predicateIdentifiers,
              try bytes("predicate_evidence_tokens", in: lineage.fields) ==
                completed.predicateEvidence,
              try unsigned("predicate_count", in: lineage.fields) == counts.predicateCount,
              try unsigned("canonical_json_byte_count", in: lineage.fields) ==
                counts.canonicalJSONByteCount,
              try unsigned("deterministic_cbor_byte_count", in: lineage.fields) ==
                counts.deterministicCBORByteCount,
              try unsigned("graph_state_count", in: lineage.fields) ==
                counts.graphStateCount,
              try unsigned("graph_witness_count", in: lineage.fields) ==
                counts.graphWitnessCount,
              try unsigned("graph_transition_count", in: lineage.fields) ==
                counts.graphTransitionCount,
              try textValue("lineage_format_id", in: lineage.fields) ==
                tokenContext.lineageFormatID,
              try textValue("product_id", in: lineage.fields) == tokenContext.productID,
              try textValue("roadmap_stage_id", in: lineage.fields) ==
                tokenContext.roadmapStageID,
              try textValue("stage_id", in: lineage.fields) == tokenContext.stageID,
              try textValue("durable_schema_id", in: lineage.fields) ==
                tokenContext.durableSchemaID,
              try textValue("purpose_id", in: lineage.fields) == tokenContext.purposeID,
              try bytes("lineage_id", in: lineage.fields) == tokenContext.lineageID.bytes,
              try bytes("epoch_id", in: lineage.fields) == tokenContext.epochID.bytes,
              try unsigned("sequence", in: lineage.fields) == tokenContext.sequence else {
            throw Failure.crossField
        }
        return lineage
    }

    private static func validateAssertionLineage(
        _ lineage: CanonicalObject,
        byteCount: Int,
        assertion: CanonicalObject,
        context: ProvisionedContext
    ) throws {
        guard try bytes("trusted_genesis_commitment", in: assertion.fields) ==
                context.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: assertion.fields) ==
                context.policyCommitment.bytes,
              try bytes("verifier_id", in: assertion.fields) == context.verifierID.bytes,
              try bytes("audience_id", in: assertion.fields) == context.audienceID.bytes,
              try bytes("lineage_id", in: lineage.fields) == context.lineageID.bytes,
              try bytes("epoch_id", in: lineage.fields) == context.epochID.bytes,
              try bytes("lineage_state_commitment", in: assertion.fields) ==
                commitment(lineage),
              try unsigned("lineage_state_byte_count", in: assertion.fields) ==
                UInt64(byteCount) else {
            throw Failure.crossField
        }
        for key in [
            "lineage_id", "epoch_id", "predecessor_lineage_state_commitment",
            "sequence", "claim_code", "nonclaim_bits", "authority_vector",
        ] where lineage.fields[key] != assertion.fields[key] {
            throw Failure.crossField
        }
        for key in [
            "product_id", "roadmap_stage_id", "stage_id",
            "durable_schema_id", "purpose_id",
        ] where lineage.fields[key] != context.policy.fields[key] {
            throw Failure.crossField
        }
    }

    static func completeAssertionForRetry(
        lineageStateBytes: Data,
        assertionBytes: Data,
        issuerEnvelopeBytes: Data,
        context: ProvisionedContext
    ) throws -> CompletedAssertion {
        let lineage = try decode(lineageStateBytes, as: .lineageState)
        let signed = try verifyIssuerEnvelope(
            assertionBytes: assertionBytes,
            envelopeBytes: issuerEnvelopeBytes,
            issuerPublicKey: context.issuerPublicKey.bytes,
            expectedIssuerKeyID: context.issuerKeyID.bytes
        )
        let assertion = signed.body
        try validateAssertionLineage(
            lineage,
            byteCount: lineageStateBytes.count,
            assertion: assertion,
            context: context
        )
        return CompletedAssertion(
            lineageState: lineage,
            issuerAssertion: assertion,
            issuerEnvelope: signed.envelope
        )
    }

    /// An ambiguous retry is exact or it is rejected for separate-candidate handling.
    static func requireExactRetry(
        of completed: CompletedAssertion,
        lineageStateBytes: Data,
        assertionBytes: Data,
        issuerEnvelopeBytes: Data
    ) throws -> CompletedAssertion {
        guard lineageStateBytes == completed.lineageState.bytes,
              assertionBytes == completed.issuerAssertion.bytes,
              issuerEnvelopeBytes == completed.issuerEnvelope.bytes else {
            throw Failure.crossField
        }
        return completed
    }

    static func fixedPredecessor(trustedGenesisCommitment: Data) throws -> Data {
        guard trustedGenesisCommitment.count == 32 else { throw Failure.fieldValue }
        return try commitment(domain: .fixedPredecessor, payload: trustedGenesisCommitment)
    }

    static func storageGenesisTag(key: Data, trustedGenesisCommitment: Data) throws -> Data {
        guard trustedGenesisCommitment.count == 32 else { throw Failure.fieldValue }
        return try authenticationCode(
            key: key,
            domain: .storageGenesisTag,
            payload: trustedGenesisCommitment
        )
    }

    static func storageRecordAuthenticationCode(key: Data, wrapper: Data) throws -> Data {
        try validate(wrapper, as: .storageRecordWrapper)
        return try authenticationCode(key: key, domain: .storageRecordAuth, payload: wrapper)
    }

    static func authorityPointerCommitment(_ pointer: Data) throws -> Data {
        try validate(pointer, as: .authorityPointer)
        return try commitment(domain: .authorityPointer, payload: pointer)
    }

    static func authorityPointerAuthenticationCode(key: Data, pointer: Data) throws -> Data {
        try validate(pointer, as: .authorityPointer)
        return try authenticationCode(key: key, domain: .authorityPointerAuth, payload: pointer)
    }

    static func makeProvisionedContext(
        disclosureModeTable tableBytes: Data,
        policy policyBytes: Data,
        trustedGenesis genesisBytes: Data
    ) throws -> ProvisionedContext {
        let table = try decode(tableBytes, as: .disclosureModeTable)
        let policy = try decode(policyBytes, as: .policy)
        let genesis = try decode(genesisBytes)
        guard genesis.schema == .genesisInitial || genesis.schema == .genesisMigrationIntent else {
            throw Failure.crossField
        }
        let tableCommitment = try commitment(table)
        let policyCommitment = try commitment(policy)
        let genesisCommitment = try commitment(genesis)
        guard try bytes("disclosure_mode_table_commitment", in: policy.fields) == tableCommitment,
              try unsigned("disclosure_mode_table_byte_count", in: policy.fields) ==
                UInt64(tableBytes.count),
              try bytes("policy_commitment", in: genesis.fields) == policyCommitment,
              try unsigned("policy_byte_count", in: genesis.fields) == UInt64(policyBytes.count) else {
            throw Failure.crossField
        }
        return ProvisionedContext(
            disclosureModeTable: table,
            policy: policy,
            trustedGenesis: genesis,
            policyCommitment: try Fixed32(policyCommitment),
            trustedGenesisCommitment: try Fixed32(genesisCommitment),
            verifierID: try Fixed32(bytes("verifier_id", in: genesis.fields)),
            verifierPublicKey: try Fixed32(bytes("verifier_public_key", in: genesis.fields)),
            issuerKeyID: try Fixed32(bytes("issuer_key_id", in: genesis.fields)),
            issuerPublicKey: try Fixed32(bytes("issuer_public_key", in: genesis.fields)),
            storageKeyID: try Fixed32(bytes("storage_key_id", in: genesis.fields)),
            audienceID: try Fixed32(bytes("audience_id", in: policy.fields)),
            lineageID: try Fixed32(bytes("lineage_id", in: genesis.fields)),
            epochID: try Fixed32(bytes("epoch_id", in: genesis.fields))
        )
    }

    static func verifyIssuerEnvelope(
        assertionBytes: Data,
        envelopeBytes: Data,
        issuerPublicKey: Data,
        expectedIssuerKeyID: Data
    ) throws -> VerifiedEnvelope {
        let assertion = try decode(assertionBytes, as: .issuerAssertion)
        let envelope = try decode(envelopeBytes, as: .issuerSignatureEnvelope)
        let derivedKeyID = try issuerKeyID(publicKey: issuerPublicKey)
        let bodyCommitment = try commitment(assertion)
        guard expectedIssuerKeyID.count == 32,
              derivedKeyID == expectedIssuerKeyID,
              try bytes("issuer_key_id", in: assertion.fields) == expectedIssuerKeyID,
              try bytes("issuer_key_id", in: envelope.fields) == expectedIssuerKeyID,
              try unsigned("issuer_key_position", in: assertion.fields) == 0,
              try unsigned("issuer_key_position", in: envelope.fields) == 0,
              try bytes("assertion_body_commitment", in: envelope.fields) == bodyCommitment,
              try unsigned("assertion_body_byte_count", in: envelope.fields) ==
                UInt64(assertionBytes.count),
              try verify(
                signature: bytes("signature", in: envelope.fields),
                publicKey: issuerPublicKey,
                domain: .issuerSignature,
                payload: assertionBytes
              ) else {
            throw Failure.signature
        }
        return VerifiedEnvelope(
            body: assertion,
            bodyCommitment: try Fixed32(bodyCommitment),
            envelope: envelope,
            envelopeCommitment: try Fixed32(commitment(envelope))
        )
    }

    static func verifyVerifierEnvelope(
        bodyBytes: Data,
        envelopeBytes: Data,
        verifierPublicKey: Data,
        expectedVerifierID: Data
    ) throws -> VerifiedEnvelope {
        let body = try decode(bodyBytes)
        let envelope = try decode(envelopeBytes, as: .verifierSignatureEnvelope)
        let mapping: (kind: UInt64, domain: Domain)
        switch body.schema {
        case .challenge:
            mapping = (1, .challengeSignature)
        case .receiptAcceptedCurrent, .receiptMinimized, .receiptTerminal:
            mapping = (2, .receiptSignature)
        case .migrationAuthorization:
            mapping = (3, .migrationSignature)
        default:
            throw Failure.unsupported
        }
        let derivedID = try verifierKeyID(publicKey: verifierPublicKey)
        guard expectedVerifierID.count == 32, derivedID == expectedVerifierID,
              try bytes("verifier_key_id", in: envelope.fields) == expectedVerifierID,
              try unsigned("verifier_key_position", in: envelope.fields) == 0,
              try unsigned("signed_body_kind", in: envelope.fields) == mapping.kind else {
            throw Failure.crossField
        }
        switch body.schema {
        case .migrationAuthorization:
            guard try bytes("old_verifier_id", in: body.fields) == expectedVerifierID,
                  try bytes("old_verifier_public_key", in: body.fields) == verifierPublicKey,
                  try unsigned("old_verifier_key_position", in: body.fields) == 0 else {
                throw Failure.crossField
            }
        default:
            guard try bytes("verifier_id", in: body.fields) == expectedVerifierID,
                  try bytes("verifier_key_id", in: body.fields) == expectedVerifierID,
                  try unsigned("verifier_key_position", in: body.fields) == 0 else {
                throw Failure.crossField
            }
        }
        let bodyCommitment = try commitment(body)
        guard try bytes("signed_body_commitment", in: envelope.fields) == bodyCommitment,
              try unsigned("signed_body_byte_count", in: envelope.fields) == UInt64(bodyBytes.count),
              try verify(
                signature: bytes("signature", in: envelope.fields),
                publicKey: verifierPublicKey,
                domain: mapping.domain,
                payload: bodyBytes
              ) else {
            throw Failure.signature
        }
        return VerifiedEnvelope(
            body: body,
            bodyCommitment: try Fixed32(bodyCommitment),
            envelope: envelope,
            envelopeCommitment: try Fixed32(commitment(envelope))
        )
    }

    static func verifyMigrationAuthorization(
        bodyBytes: Data,
        envelopeBytes: Data,
        oldContext: ProvisionedContext,
        oldTerminalState: VerifiedAuthorityState,
        newContext: ProvisionedContext
    ) throws -> VerifiedMigrationAuthorization {
        let body = try decode(bodyBytes, as: .migrationAuthorization)
        let envelope = try decode(envelopeBytes, as: .verifierSignatureEnvelope)
        guard newContext.trustedGenesis.schema == .genesisMigrationIntent,
              oldTerminalState.tip.kind == 6,
              let accepted = oldTerminalState.accepted else {
            throw Failure.crossField
        }
        let bodyCommitment = try commitment(body)

        // All independently provisioned anchors and authenticated state joins
        // precede the final strict signature operation.
        guard try bytes("trusted_genesis_commitment", in: oldTerminalState.pointer.fields) ==
                oldContext.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: oldTerminalState.pointer.fields) ==
                oldContext.policyCommitment.bytes,
              try bytes("lineage_id", in: oldTerminalState.pointer.fields) ==
                oldContext.lineageID.bytes,
              try bytes("epoch_id", in: oldTerminalState.pointer.fields) ==
                oldContext.epochID.bytes,
              try bytes("trusted_genesis_commitment", in: oldTerminalState.tip.body.fields) ==
                oldContext.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: oldTerminalState.tip.body.fields) ==
                oldContext.policyCommitment.bytes,
              try bytes("verifier_id", in: oldTerminalState.tip.body.fields) ==
                oldContext.verifierID.bytes,
              try bytes("lineage_id", in: oldTerminalState.tip.body.fields) ==
                oldContext.lineageID.bytes,
              try bytes("epoch_id", in: oldTerminalState.tip.body.fields) ==
                oldContext.epochID.bytes,
              try bytes("trusted_genesis_commitment", in: accepted.body.fields) ==
                oldContext.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: accepted.body.fields) ==
                oldContext.policyCommitment.bytes,
              try bytes("verifier_id", in: accepted.body.fields) ==
                oldContext.verifierID.bytes,
              try bytes("lineage_id", in: accepted.body.fields) ==
                oldContext.lineageID.bytes,
              try bytes("epoch_id", in: accepted.body.fields) ==
                oldContext.epochID.bytes,
              try bytes("old_verifier_id", in: body.fields) ==
                oldContext.verifierID.bytes,
              try bytes("old_verifier_public_key", in: body.fields) ==
                oldContext.verifierPublicKey.bytes,
              try bytes("old_trusted_genesis_commitment", in: body.fields) ==
                oldContext.trustedGenesisCommitment.bytes,
              try bytes(
                "old_terminal_migration_record_commitment",
                in: body.fields
              ) == oldTerminalState.tip.bodyCommitment.bytes,
              try unsigned("old_terminal_record_index", in: body.fields) ==
                oldTerminalState.tip.index,
              try unsigned("old_accepted_sequence", in: body.fields) ==
                unsigned("sequence", in: accepted.body.fields),
              try bytes(
                "old_accepted_lineage_state_commitment",
                in: body.fields
              ) == bytes("lineage_state_commitment", in: accepted.body.fields),
              try bytes("new_verifier_id", in: body.fields) == newContext.verifierID.bytes,
              try bytes("new_genesis_intent_commitment", in: body.fields) ==
                newContext.trustedGenesisCommitment.bytes,
              try bytes("migration_nonce", in: body.fields) ==
                bytes("migration_nonce", in: newContext.trustedGenesis.fields),
              try bytes(
                "expected_old_verifier_id",
                in: newContext.trustedGenesis.fields
              ) == oldContext.verifierID.bytes,
              try bytes(
                "expected_old_trusted_genesis_commitment",
                in: newContext.trustedGenesis.fields
              ) == oldContext.trustedGenesisCommitment.bytes,
              try bytes("new_verifier_id", in: oldTerminalState.tip.body.fields) ==
                newContext.verifierID.bytes,
              try bytes(
                "new_genesis_intent_commitment",
                in: oldTerminalState.tip.body.fields
              ) == newContext.trustedGenesisCommitment.bytes,
              try bytes("migration_nonce", in: oldTerminalState.tip.body.fields) ==
                bytes("migration_nonce", in: body.fields),
              try bytes(
                "accepted_record_commitment",
                in: oldTerminalState.tip.body.fields
              ) == accepted.bodyCommitment.bytes,
              try bytes(
                "accepted_lineage_state_commitment",
                in: oldTerminalState.tip.body.fields
              ) == bytes("lineage_state_commitment", in: accepted.body.fields),
              try unsigned("accepted_sequence", in: oldTerminalState.tip.body.fields) ==
                unsigned("sequence", in: accepted.body.fields),
              try bytes("verifier_key_id", in: envelope.fields) ==
                oldContext.verifierID.bytes,
              try unsigned("verifier_key_position", in: envelope.fields) == 0,
              try unsigned("signed_body_kind", in: envelope.fields) == 3,
              try bytes("signed_body_commitment", in: envelope.fields) == bodyCommitment,
              try unsigned("signed_body_byte_count", in: envelope.fields) ==
                UInt64(bodyBytes.count) else {
            throw Failure.crossField
        }
        guard try verify(
            signature: bytes("signature", in: envelope.fields),
            publicKey: oldContext.verifierPublicKey.bytes,
            domain: .migrationSignature,
            payload: bodyBytes
        ) else {
            throw Failure.signature
        }
        return VerifiedMigrationAuthorization(
            body: body,
            bodyCommitment: try Fixed32(bodyCommitment),
            envelope: envelope,
            envelopeCommitment: try Fixed32(commitment(envelope))
        )
    }

    static func authenticateAssertionRequest(
        _ requestBytes: Data,
        context: ProvisionedContext,
        consumeChallenge: (ChallengeReference) -> Bool
    ) -> AssertionValidation {
        do {
            guard !requestBytes.isEmpty,
                  requestBytes.count <= Schema.assertionRequest.maximumBytes else {
                return .noAuthenticatedResponse
            }
            let proof = try requestBytes.withUnsafeBytes {
                (raw: UnsafeRawBufferPointer) throws -> SchemaPreflightProof in
                try preflightObject(
                    raw,
                    in: 0..<raw.count,
                    expected: .assertionRequest,
                    validateNested: false
                )
            }
            guard let challengeRange = proof.facts.challengeBody,
                  let challengeEnvelopeRange = proof.facts.challengeEnvelope else {
                return .noAuthenticatedResponse
            }
            let requestCommitment = try Fixed32(
                commitment(domain: .request, payload: requestBytes)
            )
            try requestBytes.withUnsafeBytes {
                (raw: UnsafeRawBufferPointer) throws in
                _ = try preflightObject(
                    raw,
                    in: challengeRange,
                    expected: .challenge
                )
                _ = try preflightObject(
                    raw,
                    in: challengeEnvelopeRange,
                    expected: .verifierSignatureEnvelope
                )
            }
            let challengeBytes = try boundedCopy(requestBytes, rawRange: challengeRange)
            let challengeEnvelopeBytes = try boundedCopy(
                requestBytes,
                rawRange: challengeEnvelopeRange
            )
            let verifiedChallenge = try verifyVerifierEnvelope(
                bodyBytes: challengeBytes,
                envelopeBytes: challengeEnvelopeBytes,
                verifierPublicKey: context.verifierPublicKey.bytes,
                expectedVerifierID: context.verifierID.bytes
            )
            guard verifiedChallenge.body.schema == .challenge,
                  try bytes("policy_commitment", in: verifiedChallenge.body.fields) ==
                    context.policyCommitment.bytes,
                  try bytes("audience_id", in: verifiedChallenge.body.fields) ==
                    context.audienceID.bytes else {
                return .noAuthenticatedResponse
            }
            let challenge = ChallengeReference(
                bodyCommitment: verifiedChallenge.bodyCommitment,
                envelopeCommitment: verifiedChallenge.envelopeCommitment
            )
            guard consumeChallenge(challenge) else { return .noAuthenticatedResponse }
            let binding = AuthenticatedBinding(
                challenge: challenge,
                requestCommitment: requestCommitment
            )

            do {
                guard let lineageRange = proof.facts.lineageStateBody,
                      let assertionRange = proof.facts.issuerAssertionBody,
                      let issuerEnvelopeRange = proof.facts.issuerEnvelope else {
                    throw Failure.fieldInventory
                }
                try requestBytes.withUnsafeBytes {
                    (raw: UnsafeRawBufferPointer) throws in
                    _ = try preflightObject(
                        raw,
                        in: lineageRange,
                        expected: .lineageState
                    )
                    _ = try preflightObject(
                        raw,
                        in: assertionRange,
                        expected: .issuerAssertion
                    )
                    _ = try preflightObject(
                        raw,
                        in: issuerEnvelopeRange,
                        expected: .issuerSignatureEnvelope
                    )
                }
                let lineageBytes = try boundedCopy(requestBytes, rawRange: lineageRange)
                let assertionBytes = try boundedCopy(requestBytes, rawRange: assertionRange)
                let issuerEnvelopeBytes = try boundedCopy(
                    requestBytes,
                    rawRange: issuerEnvelopeRange
                )
                let lineage = try decode(lineageBytes, as: .lineageState)
                let verifiedIssuer = try verifyIssuerEnvelope(
                    assertionBytes: assertionBytes,
                    envelopeBytes: issuerEnvelopeBytes,
                    issuerPublicKey: context.issuerPublicKey.bytes,
                    expectedIssuerKeyID: context.issuerKeyID.bytes
                )
                let assertion = verifiedIssuer.body
                try validateAssertionLineage(
                    lineage,
                    byteCount: lineageBytes.count,
                    assertion: assertion,
                    context: context
                )
                return .eligible(EligibleRequest(
                    binding: binding,
                    lineageStateCommitment: try Fixed32(commitment(lineage)),
                    assertionBodyCommitment: verifiedIssuer.bodyCommitment,
                    issuerEnvelopeCommitment: verifiedIssuer.envelopeCommitment,
                    assertionInstanceNonce: try Fixed32(
                        bytes("assertion_instance_nonce", in: assertion.fields)
                    ),
                    sequence: try unsigned("sequence", in: assertion.fields),
                    predecessorLineageStateCommitment: try Fixed32(
                        bytes("predecessor_lineage_state_commitment", in: assertion.fields)
                    )
                ))
            } catch {
                return .authenticatedRejected(binding)
            }
        } catch {
            return .noAuthenticatedResponse
        }
    }

    private static func boundedCopy(
        _ bytes: Data,
        rawRange: Range<Int>
    ) throws -> Data {
        guard rawRange.lowerBound >= 0,
              rawRange.upperBound >= rawRange.lowerBound,
              rawRange.upperBound <= bytes.count else {
            throw Failure.bound
        }
        let lower = bytes.index(bytes.startIndex, offsetBy: rawRange.lowerBound)
        let upper = bytes.index(bytes.startIndex, offsetBy: rawRange.upperBound)
        return bytes.subdata(in: lower..<upper)
    }

    static func verifyAssertionReceipt(
        bodyBytes: Data,
        envelopeBytes: Data,
        context: ProvisionedContext,
        expectedChallenge: Fixed32,
        expectedRequest: Fixed32
    ) throws -> VerifiedEnvelope {
        let verified = try verifyVerifierEnvelope(
            bodyBytes: bodyBytes,
            envelopeBytes: envelopeBytes,
            verifierPublicKey: context.verifierPublicKey.bytes,
            expectedVerifierID: context.verifierID.bytes
        )
        guard verified.body.schema == .receiptAcceptedCurrent ||
                verified.body.schema == .receiptMinimized else {
            throw Failure.unsupported
        }
        guard try bytes("policy_commitment", in: verified.body.fields) ==
                context.policyCommitment.bytes,
              try bytes("audience_id", in: verified.body.fields) == context.audienceID.bytes,
              try bytes("challenge_body_commitment", in: verified.body.fields) ==
                expectedChallenge.bytes,
              try bytes("request_commitment", in: verified.body.fields) ==
                expectedRequest.bytes else {
            throw Failure.crossField
        }
        return verified
    }

    /// Verifies the committed-terminal receipt path. Outcome 5 requires an
    /// opaque qualified-recovery proof that this pure format slice cannot mint.
    static func verifyTerminalReceipt(
        bodyBytes: Data,
        envelopeBytes: Data,
        context: ProvisionedContext,
        expectedRequest: Fixed32,
        currentState: VerifiedAuthorityState
    ) throws -> VerifiedEnvelope {
        let verified = try verifyVerifierEnvelope(
            bodyBytes: bodyBytes,
            envelopeBytes: envelopeBytes,
            verifierPublicKey: context.verifierPublicKey.bytes,
            expectedVerifierID: context.verifierID.bytes
        )
        guard verified.body.schema == .receiptTerminal,
              try bytes("policy_commitment", in: verified.body.fields) ==
                context.policyCommitment.bytes,
              try bytes("terminal_request_commitment", in: verified.body.fields) ==
                expectedRequest.bytes,
              try unsigned("result_record_kind", in: verified.body.fields) ==
                currentState.tip.kind,
              try bytes("result_record_commitment", in: verified.body.fields) ==
                currentState.tip.bodyCommitment.bytes,
              try bytes("trusted_genesis_commitment", in: currentState.tip.body.fields) ==
                context.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: currentState.tip.body.fields) ==
                context.policyCommitment.bytes,
              try bytes("verifier_id", in: currentState.tip.body.fields) ==
                context.verifierID.bytes else {
            throw Failure.crossField
        }
        let outcome = try unsigned("outcome_code", in: verified.body.fields)
        let terminalKind = try unsigned("terminal_kind", in: verified.body.fields)
        let expectedRecordKind = terminalKind == 0 ? UInt64(5) : UInt64(6)
        guard outcome == 6 else { throw Failure.unsupported }
        guard currentState.tip.kind == expectedRecordKind,
              try bytes(
                "terminal_request_commitment",
                in: currentState.tip.body.fields
              ) == expectedRequest.bytes else {
            throw Failure.crossField
        }
        return verified
    }

    private static func storageEpochAnchor(
        context: ProvisionedContext
    ) -> StorageEpochAnchor {
        StorageEpochAnchor(
            trustedGenesisCommitment: context.trustedGenesisCommitment,
            policyCommitment: context.policyCommitment,
            verifierID: context.verifierID,
            lineageID: context.lineageID,
            epochID: context.epochID,
            storageKeyID: context.storageKeyID
        )
    }

    private static func storageEpochAnchor(
        body: CanonicalObject,
        storageKeyID: Fixed32
    ) throws -> StorageEpochAnchor {
        try StorageEpochAnchor(
            trustedGenesisCommitment: Fixed32(bytes(
                "trusted_genesis_commitment", in: body.fields
            )),
            policyCommitment: Fixed32(bytes("policy_commitment", in: body.fields)),
            verifierID: Fixed32(bytes("verifier_id", in: body.fields)),
            lineageID: Fixed32(bytes("lineage_id", in: body.fields)),
            epochID: Fixed32(bytes("epoch_id", in: body.fields)),
            storageKeyID: storageKeyID
        )
    }

    static func verifyStoredRecord(
        bodyBytes: Data,
        wrapperBytes: Data,
        authenticationTag: Data,
        key: Data,
        predecessor: StoragePredecessor
    ) throws -> VerifiedStoredRecord {
        guard key.count == 32, authenticationTag.count == 32 else { throw Failure.key }
        let derivedStorageKeyID = try Fixed32(storageKeyID(key: key))
        let wrapper = try decode(wrapperBytes, as: .storageRecordWrapper)
        let kind = try unsigned("record_kind", in: wrapper.fields)
        let index = try unsigned("record_index", in: wrapper.fields)
        let expectedPreviousTag: Data
        switch predecessor {
        case .genesis(let context):
            guard derivedStorageKeyID == context.storageKeyID,
                  kind == 1, index == 0 else {
                throw Failure.crossField
            }
            expectedPreviousTag = try storageGenesisTag(
                key: key,
                trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
            )
        case .record(let prior):
            let next = prior.index.addingReportingOverflow(1)
            guard derivedStorageKeyID == prior.storageKeyID,
                  !next.overflow, index == next.partialValue, kind != 1 else {
                throw Failure.crossField
            }
            expectedPreviousTag = prior.authenticationTag.bytes
        }
        guard try bytes("previous_record_auth_tag", in: wrapper.fields) == expectedPreviousTag,
              try verifyAuthenticationCode(
                authenticationTag,
                key: key,
                domain: .storageRecordAuth,
                payload: wrapperBytes
              ) else {
            throw Failure.signature
        }
        let bodySchema: Schema
        switch kind {
        case 1: bodySchema = .uninitializedRecord
        case 2: bodySchema = .acceptedTransition
        case 3: bodySchema = .conflictTombstone
        case 4: bodySchema = .storageFaultLatch
        case 5: bodySchema = .terminalClose
        case 6: bodySchema = .terminalMigration
        default: throw Failure.unsupported
        }
        let body = try decode(bodyBytes, as: bodySchema)
        let bodyCommitment = try commitment(body)
        let epochAnchor = try storageEpochAnchor(
            body: body,
            storageKeyID: derivedStorageKeyID
        )
        guard try unsigned("record_kind", in: body.fields) == kind,
              try unsigned("record_index", in: body.fields) == index,
              try bytes("record_body_commitment", in: wrapper.fields) == bodyCommitment,
              try unsigned("record_body_byte_count", in: wrapper.fields) ==
                UInt64(bodyBytes.count) else {
            throw Failure.crossField
        }
        switch predecessor {
        case .genesis(let context):
            guard epochAnchor == storageEpochAnchor(context: context) else {
                throw Failure.crossField
            }
        case .record(let prior):
            guard epochAnchor == prior.epochAnchor,
                  try bytes("previous_authority_tip_commitment", in: body.fields) ==
                    prior.bodyCommitment.bytes else {
                throw Failure.crossField
            }
        }
        return VerifiedStoredRecord(
            body: body,
            wrapper: wrapper,
            bodyCommitment: try Fixed32(bodyCommitment),
            authenticationTag: try Fixed32(authenticationTag),
            epochAnchor: epochAnchor,
            kind: kind,
            index: index
        )
    }

    static func verifyMigratedUninitializedRecord(
        bodyBytes: Data,
        wrapperBytes: Data,
        authenticationTag: Data,
        key: Data,
        context: ProvisionedContext,
        authorization: VerifiedMigrationAuthorization
    ) throws -> VerifiedStoredRecord {
        let record = try verifyStoredRecord(
            bodyBytes: bodyBytes,
            wrapperBytes: wrapperBytes,
            authenticationTag: authenticationTag,
            key: key,
            predecessor: .genesis(context)
        )
        guard record.kind == 1, record.index == 0,
              context.trustedGenesis.schema == .genesisMigrationIntent,
              authorization.body.schema == .migrationAuthorization,
              try bool("migration_binding_present", in: record.body.fields),
              try bytes(
                "migration_authorization_envelope_commitment",
                in: record.body.fields
              ) == authorization.envelopeCommitment.bytes,
              try bytes("trusted_genesis_body", in: record.body.fields) ==
                context.trustedGenesis.bytes,
              try bytes("trusted_genesis_commitment", in: record.body.fields) ==
                context.trustedGenesisCommitment.bytes,
              try bytes("policy_body", in: record.body.fields) == context.policy.bytes,
              try bytes("policy_commitment", in: record.body.fields) ==
                context.policyCommitment.bytes,
              try bytes("verifier_id", in: record.body.fields) == context.verifierID.bytes,
              try bytes("lineage_id", in: record.body.fields) == context.lineageID.bytes,
              try bytes("epoch_id", in: record.body.fields) == context.epochID.bytes,
              try bytes("new_verifier_id", in: authorization.body.fields) ==
                context.verifierID.bytes,
              try bytes(
                "new_genesis_intent_commitment",
                in: authorization.body.fields
              ) == context.trustedGenesisCommitment.bytes,
              try bytes("migration_nonce", in: authorization.body.fields) ==
                bytes("migration_nonce", in: context.trustedGenesis.fields),
              try bytes("expected_old_verifier_id", in: context.trustedGenesis.fields) ==
                bytes("old_verifier_id", in: authorization.body.fields),
              try bytes(
                "expected_old_trusted_genesis_commitment",
                in: context.trustedGenesis.fields
              ) == bytes(
                "old_trusted_genesis_commitment",
                in: authorization.body.fields
              ) else {
            throw Failure.crossField
        }
        return record
    }

    static func verifyAuthorityPointer(
        pointerBytes: Data,
        authenticationTag: Data,
        key: Data,
        tip: VerifiedStoredRecord,
        prior: VerifiedAuthorityState?,
        context: ProvisionedContext
    ) throws -> VerifiedAuthorityState {
        guard key.count == 32, authenticationTag.count == 32 else { throw Failure.key }
        let derivedStorageKeyID = try Fixed32(storageKeyID(key: key))
        let contextAnchor = storageEpochAnchor(context: context)
        let pointer = try decode(pointerBytes, as: .authorityPointer)
        guard try verifyAuthenticationCode(
            authenticationTag,
            key: key,
            domain: .authorityPointerAuth,
            payload: pointerBytes
        ) else {
            throw Failure.signature
        }
        guard try bytes("trusted_genesis_commitment", in: pointer.fields) ==
                context.trustedGenesisCommitment.bytes,
              derivedStorageKeyID == context.storageKeyID,
              tip.epochAnchor == contextAnchor,
              try bytes("policy_commitment", in: pointer.fields) ==
                context.policyCommitment.bytes,
              try bytes("lineage_id", in: pointer.fields) == context.lineageID.bytes,
              try bytes("epoch_id", in: pointer.fields) == context.epochID.bytes,
              try unsigned("authority_generation", in: pointer.fields) == tip.index,
              try unsigned("authority_tip_record_index", in: pointer.fields) == tip.index,
              try unsigned("authority_tip_record_kind", in: pointer.fields) == tip.kind,
              try bytes("authority_tip_record_commitment", in: pointer.fields) ==
                tip.bodyCommitment.bytes,
              try bytes("authority_tip_record_auth_tag", in: pointer.fields) ==
                tip.authenticationTag.bytes,
              try bytes("trusted_genesis_commitment", in: tip.body.fields) ==
                context.trustedGenesisCommitment.bytes,
              try bytes("policy_commitment", in: tip.body.fields) ==
                context.policyCommitment.bytes,
              try bytes("verifier_id", in: tip.body.fields) == context.verifierID.bytes,
              try bytes("lineage_id", in: tip.body.fields) == context.lineageID.bytes,
              try bytes("epoch_id", in: tip.body.fields) == context.epochID.bytes else {
            throw Failure.crossField
        }

        let accepted: VerifiedStoredRecord?
        if let prior {
            let next = prior.tip.index.addingReportingOverflow(1)
            guard prior.epochAnchor == contextAnchor,
                  try bytes("trusted_genesis_commitment", in: prior.pointer.fields) ==
                    context.trustedGenesisCommitment.bytes,
                  try bytes("policy_commitment", in: prior.pointer.fields) ==
                    context.policyCommitment.bytes,
                  try bytes("lineage_id", in: prior.pointer.fields) ==
                    context.lineageID.bytes,
                  try bytes("epoch_id", in: prior.pointer.fields) ==
                    context.epochID.bytes,
                  !next.overflow, tip.index == next.partialValue,
                  try bytes("previous_record_auth_tag", in: tip.wrapper.fields) ==
                    prior.tip.authenticationTag.bytes,
                  try bytes("previous_authority_tip_commitment", in: tip.body.fields) ==
                    prior.tip.bodyCommitment.bytes else {
                throw Failure.crossField
            }
            accepted = tip.kind == 2 ? tip : prior.accepted
        } else {
            guard tip.kind == 1, tip.index == 0 else { throw Failure.crossField }
            accepted = nil
        }

        if let accepted {
            guard try bool("accepted_present", in: pointer.fields), accepted.kind == 2,
                  try unsigned("accepted_sequence", in: pointer.fields) ==
                    unsigned("sequence", in: accepted.body.fields),
                  try bytes("accepted_record_or_fixed_predecessor", in: pointer.fields) ==
                    accepted.bodyCommitment.bytes,
                  try bytes(
                    "accepted_lineage_state_or_fixed_predecessor",
                    in: pointer.fields
                  ) == bytes("lineage_state_commitment", in: accepted.body.fields) else {
                throw Failure.crossField
            }
        } else if try bool("accepted_present", in: pointer.fields) {
            throw Failure.crossField
        }

        return VerifiedAuthorityState(
            pointer: pointer,
            pointerCommitment: try Fixed32(commitment(pointer)),
            authenticationTag: try Fixed32(authenticationTag),
            epochAnchor: contextAnchor,
            tip: tip,
            accepted: accepted
        )
    }

    static func encode(_ fields: [String: Value], as schema: Schema) throws -> Data {
        try validateFields(fields, schema: schema)
        var encoder = CBOREncoder()
        try encoder.put(.map(fields), depth: 0)
        let bytes = encoder.output
        guard !bytes.isEmpty, bytes.count <= schema.maximumBytes else { throw Failure.bound }
        return bytes
    }

    static func decode(_ bytes: Data, as schema: Schema) throws -> CanonicalObject {
        guard !bytes.isEmpty, bytes.count <= schema.maximumBytes,
              bytes.count <= maximumCanonicalBytes else {
            throw Failure.bound
        }
        let proof = try preflight(bytes, expected: schema)
        let value = try materializeCanonicalValue(bytes, after: proof)
        guard case .map(let fields) = value else { throw Failure.schema }
        try validateFields(fields, schema: schema)
        guard try encode(fields, as: schema) == bytes else { throw Failure.noncanonical }
        return CanonicalObject(schema: schema, fields: fields, bytes: bytes)
    }

    static func decode(_ bytes: Data) throws -> CanonicalObject {
        guard !bytes.isEmpty, bytes.count <= maximumCanonicalBytes else { throw Failure.bound }
        let proof = try preflight(bytes, expected: nil)
        let schema = proof.schema
        let value = try materializeCanonicalValue(bytes, after: proof)
        guard case .map(let fields) = value else { throw Failure.schema }
        try validateFields(fields, schema: schema)
        guard try encode(fields, as: schema) == bytes else { throw Failure.noncanonical }
        return CanonicalObject(schema: schema, fields: fields, bytes: bytes)
    }

    static func validate(_ bytes: Data, as schema: Schema) throws {
        _ = try decode(bytes, as: schema)
    }

    static func encodeCanonical(_ value: Value) throws -> Data {
        var encoder = CBOREncoder()
        try encoder.put(value, depth: 0)
        guard !encoder.output.isEmpty else { throw Failure.bound }
        return encoder.output
    }

    static func decodeCanonical(_ bytes: Data) throws -> Value {
        try decodeCanonicalValue(bytes)
    }

    static func validateCanonical(_ bytes: Data) throws {
        _ = try decodeCanonicalValue(bytes)
    }

    static func checkedPredicateLengths(_ count: UInt64) throws -> (packed: Int, results: Int) {
        let product = count.multipliedReportingOverflow(by: 32)
        guard !product.overflow,
              let packed = Int(exactly: product.partialValue),
              let results = Int(exactly: count) else {
            throw Failure.overflow
        }
        return (packed, results)
    }

    static func commitment(_ object: CanonicalObject) throws -> Data {
        guard let domain = object.schema.commitmentDomain else { throw Failure.unsupported }
        return try commitment(domain: domain, payload: object.bytes)
    }

    private static func appendBigEndian(_ value: UInt16, to data: inout Data) {
        data.append(UInt8(truncatingIfNeeded: value >> 8))
        data.append(UInt8(truncatingIfNeeded: value))
    }

    private static func appendBigEndian(_ value: UInt64, to data: inout Data) {
        for index in (0..<8).reversed() {
            data.append(UInt8(truncatingIfNeeded: value >> UInt64(index * 8)))
        }
    }
}

private extension HypervisorStageH4PrivateVerifierFormat {
    static let hmacDomains: Set<Domain> = [
        .privateToken, .storageGenesisTag, .storageRecordAuth, .authorityPointerAuth,
    ]
    static let signatureDomains: Set<Domain> = [
        .issuerSignature, .challengeSignature, .migrationSignature, .receiptSignature,
    ]
    static let sha256Domains: Set<Domain> = Set(Domain.allCases).subtracting(
        hmacDomains.union(signatureDomains)
    )
}

private extension HypervisorStageH4PrivateVerifierFormat {
    static let ed25519FieldPrimeLittleEndian: [UInt8] =
        [0xed] + [UInt8](repeating: 0xff, count: 30) + [0x7f]
    static let ed25519ScalarOrderLittleEndian: [UInt8] = [
        0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58,
        0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10,
    ]

    static let ed25519SmallOrderEncodings: Set<Data> = {
        let firstOrderEight = Data([
            0x26, 0xe8, 0x95, 0x8f, 0xc2, 0xb2, 0x27, 0xb0,
            0x45, 0xc3, 0xf4, 0x89, 0xf2, 0xef, 0x98, 0xf0,
            0xd5, 0xdf, 0xac, 0x05, 0xd3, 0xc6, 0x33, 0x39,
            0xb1, 0x38, 0x02, 0x88, 0x6d, 0x53, 0xfc, 0x05,
        ])
        let secondOrderEight = Data([
            0xc7, 0x17, 0x6a, 0x70, 0x3d, 0x4d, 0xd8, 0x4f,
            0xba, 0x3c, 0x0b, 0x76, 0x0d, 0x10, 0x67, 0x0f,
            0x2a, 0x20, 0x53, 0xfa, 0x2c, 0x39, 0xcc, 0xc6,
            0x4e, 0xc7, 0xfd, 0x77, 0x92, 0xac, 0x03, 0x7a,
        ])
        var firstNegative = firstOrderEight
        firstNegative[firstNegative.index(before: firstNegative.endIndex)] |= 0x80
        var secondNegative = secondOrderEight
        secondNegative[secondNegative.index(before: secondNegative.endIndex)] |= 0x80
        return [
            Data(repeating: 0, count: 32),
            Data(repeating: 0, count: 31) + Data([0x80]),
            Data([0x01]) + Data(repeating: 0, count: 31),
            Data([0xec]) + Data(repeating: 0xff, count: 30) + Data([0x7f]),
            firstOrderEight,
            firstNegative,
            secondOrderEight,
            secondNegative,
        ]
    }()

    static func strictPointEncoding(_ bytes: Data) -> Bool {
        guard bytes.count == 32 else { return false }
        let encoded = [UInt8](bytes)
        var y = encoded
        let negative = (y[31] & 0x80) != 0
        y[31] &= 0x7f
        guard littleEndian(y, isLessThan: ed25519FieldPrimeLittleEndian) else {
            return false
        }
        let one = [UInt8]([0x01]) + [UInt8](repeating: 0, count: 31)
        let minusOne = [UInt8]([0xec]) + [UInt8](repeating: 0xff, count: 30) + [0x7f]
        guard !(negative && (y == one || y == minusOne)),
              !ed25519SmallOrderEncodings.contains(bytes) else {
            return false
        }
        return true
    }

    static func scalarIsLessThanOrder(_ bytes: Data) -> Bool {
        guard bytes.count == 32 else { return false }
        return littleEndian([UInt8](bytes), isLessThan: ed25519ScalarOrderLittleEndian)
    }

    static func littleEndian(_ left: [UInt8], isLessThan right: [UInt8]) -> Bool {
        guard left.count == right.count else { return false }
        for index in left.indices.reversed() where left[index] != right[index] {
            return left[index] < right[index]
        }
        return false
    }

    struct CBOREncoder {
        var output = Data()
        var nodes = 0

        mutating func add(_ bytes: Data) throws {
            guard bytes.count <= maximumCanonicalBytes - output.count else {
                throw Failure.bound
            }
            output.append(bytes)
        }

        mutating func claimNode() throws {
            guard nodes < maximumNodes else { throw Failure.bound }
            nodes += 1
        }

        mutating func argument(major: UInt8, value: UInt64) throws {
            var bytes = Data()
            if value < 24 {
                bytes.append((major << 5) | UInt8(value))
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
                bytes.append((major << 5) | additional)
                for index in (0..<width).reversed() {
                    bytes.append(UInt8(truncatingIfNeeded: value >> UInt64(index * 8)))
                }
            }
            try add(bytes)
        }

        mutating func put(_ value: Value, depth: Int) throws {
            guard depth <= maximumDepth else { throw Failure.bound }
            try claimNode()
            switch value {
            case .unsigned(let value):
                try argument(major: 0, value: value)
            case .bytes(let bytes):
                try argument(major: 2, value: UInt64(bytes.count))
                try add(bytes)
            case .text(let text):
                let bytes = try validatedTextBytes(text)
                try argument(major: 3, value: UInt64(bytes.count))
                try add(bytes)
            case .array(let values):
                guard values.count <= maximumArrayEntries else { throw Failure.bound }
                try argument(major: 4, value: UInt64(values.count))
                for item in values { try put(item, depth: depth + 1) }
            case .map(let values):
                guard values.count <= maximumMapEntries else { throw Failure.bound }
                var entries: [(Data, Value)] = []
                entries.reserveCapacity(values.count)
                for (key, item) in values {
                    let keyBytes = try encodedTextKey(key)
                    entries.append((keyBytes, item))
                }
                entries.sort { $0.0.lexicographicallyPrecedes($1.0) }
                try argument(major: 5, value: UInt64(entries.count))
                for (key, item) in entries {
                    try claimNode()
                    try add(key)
                    try put(item, depth: depth + 1)
                }
            case .bool(let value):
                try add(Data([value ? 0xf5 : 0xf4]))
            }
        }

        private func encodedTextKey(_ key: String) throws -> Data {
            let bytes = try validatedTextBytes(key)
            var encoder = CBOREncoder()
            try encoder.argument(major: 3, value: UInt64(bytes.count))
            try encoder.add(bytes)
            return encoder.output
        }
    }

    struct SchemaPreflightProof {
        let schema: Schema
        let facts: SchemaPreflightFacts
    }

    struct SchemaPreflightFacts {
        var predicateCount: UInt64?
        var predicateIdentifiers: Range<Int>?
        var predicateResults: Range<Int>?
        var predicateEvidence: Range<Int>?
        var trustedGenesisBody: Range<Int>?
        var policyBody: Range<Int>?
        var challengeBody: Range<Int>?
        var challengeEnvelope: Range<Int>?
        var lineageStateBody: Range<Int>?
        var issuerAssertionBody: Range<Int>?
        var issuerEnvelope: Range<Int>?
    }

    enum RawValueFact {
        case unsigned(UInt64)
        case bytes(Range<Int>)
        case text(Range<Int>)
        case bool(Bool)
    }

    struct ExpectedRawField {
        let name: String
        let rule: FieldRule
        let encodedKey: Data
    }

    struct RawCBORScanner {
        let raw: UnsafeRawBufferPointer
        let window: Range<Int>
        var offset: Int
        var nodes = 0

        init(raw: UnsafeRawBufferPointer, window: Range<Int>) {
            self.raw = raw
            self.window = window
            offset = window.lowerBound
        }

        mutating func claimNode(depth: Int) throws {
            guard depth <= maximumDepth, nodes < maximumNodes,
                  offset < window.upperBound else {
                throw Failure.bound
            }
            nodes += 1
        }

        mutating func byte() throws -> UInt8 {
            guard offset < window.upperBound else { throw Failure.malformed }
            let result = raw[offset]
            offset += 1
            return result
        }

        mutating func argument(_ additional: UInt8) throws -> UInt64 {
            if additional < 24 { return UInt64(additional) }
            let width: Int
            switch additional {
            case 24: width = 1
            case 25: width = 2
            case 26: width = 4
            case 27: width = 8
            default: throw Failure.unsupported
            }
            guard width <= window.upperBound - offset else { throw Failure.malformed }
            var value: UInt64 = 0
            for _ in 0..<width { value = (value << 8) | UInt64(try byte()) }
            let minimum: UInt64
            switch width {
            case 1: minimum = 24
            case 2: minimum = 256
            case 4: minimum = 65_536
            default: minimum = 4_294_967_296
            }
            guard value >= minimum else { throw Failure.noncanonical }
            return value
        }

        mutating func payload(_ count: UInt64, maximum: Int) throws -> Range<Int> {
            guard count <= UInt64(maximum) else { throw Failure.bound }
            guard let length = Int(exactly: count) else { throw Failure.overflow }
            let addition = offset.addingReportingOverflow(length)
            guard !addition.overflow else { throw Failure.overflow }
            guard addition.partialValue <= window.upperBound else { throw Failure.bound }
            let result = offset..<addition.partialValue
            offset = addition.partialValue
            return result
        }

        mutating func mapCount(depth: Int) throws -> Int {
            try claimNode(depth: depth)
            let initial = try byte()
            guard initial >> 5 == 5 else { throw Failure.schema }
            let count = try argument(initial & 31)
            guard count <= UInt64(maximumMapEntries),
                  let result = Int(exactly: count) else {
                throw Failure.bound
            }
            return result
        }

        mutating func text(depth: Int) throws -> (encoded: Range<Int>, payload: Range<Int>) {
            let start = offset
            try claimNode(depth: depth)
            let initial = try byte()
            guard initial >> 5 == 3 else { throw Failure.fieldType }
            let count = try argument(initial & 31)
            let payload = try payload(count, maximum: maximumTextBytes)
            guard !payload.isEmpty,
                  payload.allSatisfy({ (0x20...0x7e).contains(raw[$0]) }) else {
                throw Failure.fieldValue
            }
            return (start..<offset, payload)
        }

        mutating func value(depth: Int, rule: FieldRule) throws -> RawValueFact {
            try claimNode(depth: depth)
            let initial = try byte()
            switch rule {
            case .bool(let expected):
                guard initial == 0xf4 || initial == 0xf5 else { throw Failure.fieldType }
                let actual = initial == 0xf5
                if let expected, actual != expected { throw Failure.fieldValue }
                return .bool(actual)

            case .unsigned(let range):
                guard initial >> 5 == 0 else { throw Failure.fieldType }
                let number = try argument(initial & 31)
                guard range.contains(number) else { throw Failure.fieldValue }
                return .unsigned(number)

            case .unsignedSet(let allowed):
                guard initial >> 5 == 0 else { throw Failure.fieldType }
                let number = try argument(initial & 31)
                guard allowed.contains(number) else { throw Failure.fieldValue }
                return .unsigned(number)

            case .bytes(let range):
                guard initial >> 5 == 2 else { throw Failure.fieldType }
                let count = try argument(initial & 31)
                let bytes = try payload(count, maximum: maximumCanonicalBytes)
                guard range.contains(bytes.count) else { throw Failure.fieldValue }
                return .bytes(bytes)

            case .text, .textExact:
                guard initial >> 5 == 3 else { throw Failure.fieldType }
                let count = try argument(initial & 31)
                let text = try payload(count, maximum: maximumTextBytes)
                guard !text.isEmpty,
                      text.allSatisfy({ (0x20...0x7e).contains(raw[$0]) }) else {
                    throw Failure.fieldValue
                }
                if case .textExact(let expected) = rule,
                   !HypervisorStageH4PrivateVerifierFormat.rawEquals(
                        raw, text, expected.utf8
                   ) {
                    throw Failure.fieldValue
                }
                return .text(text)
            }
        }
    }

    static func preflight(_ bytes: Data, expected: Schema?) throws -> SchemaPreflightProof {
        guard !bytes.isEmpty, bytes.count <= maximumCanonicalBytes else {
            throw Failure.bound
        }
        return try bytes.withUnsafeBytes {
            (raw: UnsafeRawBufferPointer) throws -> SchemaPreflightProof in
            return try preflightObject(
                raw,
                in: 0..<raw.count,
                expected: expected
            )
        }
    }

    static func preflightObject(
        _ raw: UnsafeRawBufferPointer,
        in window: Range<Int>,
        expected: Schema?,
        validateNested: Bool = true
    ) throws -> SchemaPreflightProof {
        guard !window.isEmpty, window.count <= maximumCanonicalBytes,
              window.lowerBound >= 0, window.upperBound <= raw.count else {
            throw Failure.bound
        }
        let schema = try expected ?? discoverSchema(raw, in: window)
        guard window.count <= schema.maximumBytes else { throw Failure.bound }

        var fields: [ExpectedRawField] = []
        for (name, rule) in rules(for: schema) {
            fields.append(ExpectedRawField(
                name: name,
                rule: rule,
                encodedKey: try encodedRawTextKey(name)
            ))
        }
        fields.sort { $0.encodedKey.lexicographicallyPrecedes($1.encodedKey) }

        var scanner = RawCBORScanner(raw: raw, window: window)
        guard try scanner.mapCount(depth: 0) == fields.count else {
            throw Failure.fieldInventory
        }
        var facts = SchemaPreflightFacts()
        for field in fields {
            let key = try scanner.text(depth: 1)
            guard rawEquals(raw, key.encoded, field.encodedKey) else {
                throw Failure.noncanonical
            }
            let value = try scanner.value(depth: 1, rule: field.rule)
            if case .bytes(let range) = value,
               preflightRequiresNonzero(field.name),
               range.allSatisfy({ raw[$0] == 0 }) {
                throw Failure.fieldValue
            }
            capturePreflightFact(
                value,
                name: field.name,
                schema: schema,
                facts: &facts
            )
        }
        guard scanner.offset == window.upperBound else { throw Failure.noncanonical }
        try validatePreflightFacts(
            facts,
            schema: schema,
            raw: raw,
            validateNested: validateNested
        )
        return SchemaPreflightProof(schema: schema, facts: facts)
    }

    static func discoverSchema(
        _ raw: UnsafeRawBufferPointer,
        in window: Range<Int>
    ) throws -> Schema {
        var scanner = RawCBORScanner(raw: raw, window: window)
        guard try scanner.mapCount(depth: 0) > 0 else { throw Failure.schema }
        let key = try scanner.text(depth: 1)
        guard rawEquals(raw, key.encoded, try encodedRawTextKey("schema")) else {
            throw Failure.schema
        }
        let value = try scanner.text(depth: 1)
        guard let schema = Schema.allCases.first(where: {
            rawEquals(raw, value.payload, $0.rawValue.utf8)
        }) else {
            throw Failure.schema
        }
        return schema
    }

    static func encodedRawTextKey(_ key: String) throws -> Data {
        let bytes = try validatedTextBytes(key)
        var encoder = CBOREncoder()
        try encoder.argument(major: 3, value: UInt64(bytes.count))
        try encoder.add(bytes)
        return encoder.output
    }

    static func rawEquals<C: Collection>(
        _ raw: UnsafeRawBufferPointer,
        _ range: Range<Int>,
        _ expected: C
    ) -> Bool where C.Element == UInt8 {
        guard range.count == expected.count else { return false }
        var offset = range.lowerBound
        for byte in expected {
            if raw[offset] != byte { return false }
            offset += 1
        }
        return true
    }

    static func preflightRequiresNonzero(_ key: String) -> Bool {
        let exactNames: Set<String> = [
            "fixed_predecessor",
            "accepted_record_or_fixed_predecessor",
            "accepted_lineage_state_or_fixed_predecessor",
            "last_authenticated_accepted_record_or_fixed_predecessor",
            "assertion_instance_nonce",
            "challenge_nonce",
        ]
        return key.hasSuffix("_commitment") || key.hasSuffix("_id") || exactNames.contains(key)
    }

    static func capturePreflightFact(
        _ value: RawValueFact,
        name: String,
        schema: Schema,
        facts: inout SchemaPreflightFacts
    ) {
        switch (schema, name, value) {
        case (.lineageState, "predicate_count", .unsigned(let count)):
            facts.predicateCount = count
        case (.lineageState, "predicate_identifier_tokens", .bytes(let range)):
            facts.predicateIdentifiers = range
        case (.lineageState, "predicate_result_codes", .bytes(let range)):
            facts.predicateResults = range
        case (.lineageState, "predicate_evidence_tokens", .bytes(let range)):
            facts.predicateEvidence = range
        case (.uninitializedRecord, "trusted_genesis_body", .bytes(let range)):
            facts.trustedGenesisBody = range
        case (.uninitializedRecord, "policy_body", .bytes(let range)):
            facts.policyBody = range
        case (.assertionRequest, "challenge_body", .bytes(let range)):
            facts.challengeBody = range
        case (.assertionRequest, "challenge_envelope", .bytes(let range)):
            facts.challengeEnvelope = range
        case (.assertionRequest, "lineage_state_body", .bytes(let range)):
            facts.lineageStateBody = range
        case (.assertionRequest, "issuer_assertion_body", .bytes(let range)):
            facts.issuerAssertionBody = range
        case (.assertionRequest, "issuer_signature_envelope", .bytes(let range)):
            facts.issuerEnvelope = range
        default:
            break
        }
    }

    static func validatePreflightFacts(
        _ facts: SchemaPreflightFacts,
        schema: Schema,
        raw: UnsafeRawBufferPointer,
        validateNested: Bool
    ) throws {
        switch schema {
        case .lineageState:
            guard let count = facts.predicateCount,
                  let identifiers = facts.predicateIdentifiers,
                  let results = facts.predicateResults,
                  let evidence = facts.predicateEvidence else {
                throw Failure.fieldInventory
            }
            let lengths = try checkedPredicateLengths(count)
            guard identifiers.count == lengths.packed,
                  evidence.count == lengths.packed,
                  results.count == lengths.results,
                  results.allSatisfy({ raw[$0] <= 3 }) else {
                throw Failure.crossField
            }

        case .uninitializedRecord:
            guard validateNested else { return }
            guard let genesis = facts.trustedGenesisBody,
                  let policy = facts.policyBody else {
                throw Failure.fieldInventory
            }
            let genesisSchema = try preflightObject(raw, in: genesis, expected: nil).schema
            guard genesisSchema == .genesisInitial ||
                    genesisSchema == .genesisMigrationIntent else {
                throw Failure.crossField
            }
            _ = try preflightObject(raw, in: policy, expected: .policy)

        case .assertionRequest:
            guard validateNested else { return }
            guard let challenge = facts.challengeBody,
                  let challengeEnvelope = facts.challengeEnvelope,
                  let lineage = facts.lineageStateBody,
                  let assertion = facts.issuerAssertionBody,
                  let issuerEnvelope = facts.issuerEnvelope else {
                throw Failure.fieldInventory
            }
            _ = try preflightObject(raw, in: challenge, expected: .challenge)
            _ = try preflightObject(
                raw, in: challengeEnvelope, expected: .verifierSignatureEnvelope
            )
            _ = try preflightObject(raw, in: lineage, expected: .lineageState)
            _ = try preflightObject(raw, in: assertion, expected: .issuerAssertion)
            _ = try preflightObject(
                raw, in: issuerEnvelope, expected: .issuerSignatureEnvelope
            )

        default:
            break
        }
    }

    static func materializeCanonicalValue(
        _ bytes: Data,
        after proof: SchemaPreflightProof
    ) throws -> Value {
        _ = proof
        return try decodeCanonicalValue(bytes)
    }

    struct CBORDecoder {
        let bytes: [UInt8]
        var offset = 0
        var nodes = 0

        mutating func claimNode(depth: Int) throws {
            guard depth <= maximumDepth, nodes < maximumNodes, offset < bytes.count else {
                throw Failure.bound
            }
            nodes += 1
        }

        mutating func argument(_ additional: UInt8) throws -> UInt64 {
            if additional < 24 { return UInt64(additional) }
            let width: Int
            switch additional {
            case 24: width = 1
            case 25: width = 2
            case 26: width = 4
            case 27: width = 8
            default: throw Failure.unsupported
            }
            guard width <= bytes.count - offset else { throw Failure.malformed }
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
            guard value >= minimum else { throw Failure.noncanonical }
            return value
        }

        mutating func take(depth: Int) throws -> Value {
            try claimNode(depth: depth)
            let initial = bytes[offset]
            offset += 1
            if initial == 0xf4 { return .bool(false) }
            if initial == 0xf5 { return .bool(true) }
            let major = initial >> 5
            guard major <= 5, major != 1 else { throw Failure.unsupported }
            let count = try argument(initial & 31)
            switch major {
            case 0:
                return .unsigned(count)
            case 2:
                let length = try boundedLength(count)
                let end = offset + length
                let result = Data(bytes[offset..<end])
                offset = end
                return .bytes(result)
            case 3:
                let length = try boundedLength(count)
                guard length > 0, length <= maximumTextBytes else { throw Failure.bound }
                let end = offset + length
                let data = Data(bytes[offset..<end])
                guard data.allSatisfy({ (0x20...0x7e).contains($0) }) else {
                    throw Failure.fieldValue
                }
                offset = end
                return .text(String(decoding: data, as: UTF8.self))
            case 4:
                guard count <= UInt64(maximumArrayEntries) else { throw Failure.bound }
                let itemCount = Int(count)
                var result: [Value] = []
                result.reserveCapacity(itemCount)
                for _ in 0..<itemCount { result.append(try take(depth: depth + 1)) }
                return .array(result)
            case 5:
                guard count <= UInt64(maximumMapEntries) else { throw Failure.bound }
                let itemCount = Int(count)
                var result: [String: Value] = [:]
                result.reserveCapacity(itemCount)
                var previousKeyBytes: Data?
                for _ in 0..<itemCount {
                    let start = offset
                    guard case .text(let key) = try take(depth: depth + 1) else {
                        throw Failure.fieldType
                    }
                    let keyBytes = Data(bytes[start..<offset])
                    if let previousKeyBytes,
                       !previousKeyBytes.lexicographicallyPrecedes(keyBytes) {
                        throw Failure.noncanonical
                    }
                    guard result[key] == nil else { throw Failure.noncanonical }
                    previousKeyBytes = keyBytes
                    result[key] = try take(depth: depth + 1)
                }
                return .map(result)
            default:
                throw Failure.unsupported
            }
        }

        private func boundedLength(_ count: UInt64) throws -> Int {
            guard count <= UInt64(maximumCanonicalBytes),
                  count <= UInt64(bytes.count - offset),
                  let length = Int(exactly: count) else {
                throw Failure.bound
            }
            return length
        }
    }

    static func validatedTextBytes(_ text: String) throws -> Data {
        let bytes = Data(text.utf8)
        guard !bytes.isEmpty, bytes.count <= maximumTextBytes,
              bytes.allSatisfy({ (0x20...0x7e).contains($0) }) else {
            throw Failure.fieldValue
        }
        return bytes
    }

    static func decodeCanonicalValue(_ bytes: Data) throws -> Value {
        guard !bytes.isEmpty, bytes.count <= maximumCanonicalBytes else { throw Failure.bound }
        var decoder = CBORDecoder(bytes: [UInt8](bytes))
        let value = try decoder.take(depth: 0)
        guard decoder.offset == bytes.count else { throw Failure.noncanonical }
        var encoder = CBOREncoder()
        try encoder.put(value, depth: 0)
        guard encoder.output == bytes else { throw Failure.noncanonical }
        return value
    }
}

private extension HypervisorStageH4PrivateVerifierFormat {
    static func validateCrossFields(_ values: [String: Value], schema: Schema) throws {
        switch schema {
        case .privateTokenDescriptor:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            let kind = try unsigned("field_kind", in: values)
            let ordinal = try unsigned("field_ordinal", in: values)
            let byteCount = try unsigned("byte_count", in: values)
            let member0 = try unsigned("member_count_0", in: values)
            let member1 = try unsigned("member_count_1", in: values)
            let member2 = try unsigned("member_count_2", in: values)
            if kind <= 4, ordinal != 0 { throw Failure.crossField }
            switch kind {
            case 0:
                guard byteCount == 0, member0 == 4, member1 == 0, member2 == 0 else {
                    throw Failure.crossField
                }
            case 1, 2:
                guard (1...158).contains(byteCount),
                      member0 == 0, member1 == 0, member2 == 0 else {
                    throw Failure.crossField
                }
            case 3:
                guard byteCount == 0, member0 == 4, member1 == 0, member2 == 0 else {
                    throw Failure.crossField
                }
            case 4:
                guard byteCount == 0, member0 <= 4_096,
                      member1 <= 4_096, member2 <= 4_096 else {
                    throw Failure.crossField
                }
            case 5, 6:
                guard member0 == 0, member1 == 0, member2 == 0 else {
                    throw Failure.crossField
                }
            default:
                throw Failure.fieldValue
            }

        case .disclosureModeTable:
            break

        case .policy:
            try requireNonzero(["audience_id"], in: values)

        case .genesisInitial, .genesisMigrationIntent:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            let verifierPublicKey = try bytes("verifier_public_key", in: values)
            let issuerPublicKey = try bytes("issuer_public_key", in: values)
            let expectedVerifierID = try verifierKeyID(publicKey: verifierPublicKey)
            let expectedIssuerID = try issuerKeyID(publicKey: issuerPublicKey)
            let encodedVerifierID = try bytes("verifier_id", in: values)
            let encodedIssuerID = try bytes("issuer_key_id", in: values)
            guard strictPointEncoding(verifierPublicKey), strictPointEncoding(issuerPublicKey),
                  expectedVerifierID == encodedVerifierID,
                  expectedIssuerID == encodedIssuerID else {
                throw Failure.crossField
            }

        case .uninitializedRecord:
            try validateUninitialized(values)

        case .lineageState:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            let count = try unsigned("predicate_count", in: values)
            let lengths = try checkedPredicateLengths(count)
            guard try bytes("predicate_identifier_tokens", in: values).count == lengths.packed,
                  try bytes("predicate_evidence_tokens", in: values).count == lengths.packed else {
                throw Failure.crossField
            }
            let results = try bytes("predicate_result_codes", in: values)
            guard results.count == lengths.results, results.allSatisfy({ $0 <= 3 }) else {
                throw Failure.crossField
            }

        case .issuerAssertion:
            try requireNonzero(
                ["audience_id", "assertion_instance_nonce", "lineage_id", "epoch_id"],
                in: values
            )

        case .issuerSignatureEnvelope:
            guard strictSignatureEncoding(try bytes("signature", in: values)) else {
                throw Failure.signature
            }

        case .challenge:
            try requireNonzero(["audience_id", "challenge_nonce"], in: values)
            try requireEqual(["verifier_id", "verifier_key_id"], in: values)

        case .verifierSignatureEnvelope:
            guard strictSignatureEncoding(try bytes("signature", in: values)) else {
                throw Failure.signature
            }
            if try unsigned("signed_body_kind", in: values) == 1,
               try unsigned("signed_body_byte_count", in: values) > 4_096 {
                throw Failure.crossField
            }

        case .assertionRequest:
            try validateAssertionRequest(values)

        case .verifierDecision:
            let code = try unsigned("internal_decision_code", in: values)
            let proposed = try unsigned("proposed_persistent_record_kind", in: values)
            let expected: UInt64 = (code == 1 || code == 2) ? 2 : code == 5 ? 3 : 0
            guard proposed == expected else { throw Failure.crossField }
            if !(try bool("prior_accepted_present", in: values)) {
                guard try unsigned("prior_accepted_sequence", in: values) == 0 else {
                    throw Failure.crossField
                }
                try requireEqual(
                    ["prior_accepted_record_commitment", "prior_lineage_state_commitment"],
                    in: values
                )
            }

        case .acceptedTransition, .terminalMigration:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)

        case .storageFaultLatch:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            try requireEqual(
                [
                    "previous_authority_tip_commitment",
                    "last_authenticated_authority_tip_commitment",
                ],
                in: values
            )
            let index = try unsigned("record_index", in: values)
            let attemptedKind = try unsigned("attempted_record_kind", in: values)
            if index == 1, attemptedKind != 2 { throw Failure.crossField }
            if attemptedKind != 2, index < 2 { throw Failure.crossField }

        case .conflictTombstone:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            let accepted = try bytes("accepted_lineage_state_commitment", in: values)
            let competing = try bytes("competing_lineage_state_commitment", in: values)
            guard accepted != competing else {
                throw Failure.crossField
            }

        case .terminalClose:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            if !(try bool("accepted_present", in: values)) {
                guard try unsigned("accepted_sequence", in: values) == 0 else {
                    throw Failure.crossField
                }
                let predecessor = try fixedPredecessor(
                    trustedGenesisCommitment: bytes("trusted_genesis_commitment", in: values)
                )
                guard try bytes("accepted_record_or_fixed_predecessor", in: values) == predecessor,
                      try bytes("accepted_lineage_state_or_fixed_predecessor", in: values) == predecessor else {
                    throw Failure.crossField
                }
            }

        case .storageRecordWrapper:
            let kind = try unsigned("record_kind", in: values)
            let index = try unsigned("record_index", in: values)
            guard (kind == 1 && index == 0) || (kind != 1 && index >= 1) else {
                throw Failure.crossField
            }

        case .authorityPointer:
            try requireNonzero(["lineage_id", "epoch_id"], in: values)
            let generation = try unsigned("authority_generation", in: values)
            let recordIndex = try unsigned("authority_tip_record_index", in: values)
            guard generation == recordIndex else {
                throw Failure.crossField
            }
            let kind = try unsigned("authority_tip_record_kind", in: values)
            let lifecycle = try unsigned("lifecycle_code", in: values)
            let expectedLifecycle: UInt64 = kind <= 4 ? kind : 5
            guard lifecycle == expectedLifecycle else { throw Failure.crossField }
            guard (kind == 1 && generation == 0) || (kind != 1 && generation >= 1) else {
                throw Failure.crossField
            }
            let accepted = try bool("accepted_present", in: values)
            if kind == 1, accepted { throw Failure.crossField }
            if [2, 3, 6].contains(kind), !accepted { throw Failure.crossField }
            if kind == 2 {
                try requireEqual(
                    [
                        "authority_tip_record_commitment",
                        "accepted_record_or_fixed_predecessor",
                    ],
                    in: values
                )
            }
            if !accepted {
                guard try unsigned("accepted_sequence", in: values) == 0 else {
                    throw Failure.crossField
                }
                let predecessor = try fixedPredecessor(
                    trustedGenesisCommitment: bytes("trusted_genesis_commitment", in: values)
                )
                guard try bytes("accepted_record_or_fixed_predecessor", in: values) == predecessor,
                      try bytes("accepted_lineage_state_or_fixed_predecessor", in: values) == predecessor else {
                    throw Failure.crossField
                }
            }

        case .terminalCloseRequest, .terminalMigrationRequest:
            break

        case .migrationAuthorization:
            let publicKey = try bytes("old_verifier_public_key", in: values)
            let derivedID = try verifierKeyID(publicKey: publicKey)
            let encodedID = try bytes("old_verifier_id", in: values)
            guard strictPointEncoding(publicKey),
                  derivedID == encodedID else {
                throw Failure.crossField
            }

        case .receiptAcceptedCurrent, .receiptMinimized:
            try requireNonzero(["audience_id"], in: values)
            try requireEqual(["verifier_id", "verifier_key_id"], in: values)

        case .receiptTerminal:
            try requireEqual(["verifier_id", "verifier_key_id"], in: values)
            let outcome = try unsigned("outcome_code", in: values)
            let terminalKind = try unsigned("terminal_kind", in: values)
            let resultKind = try unsigned("result_record_kind", in: values)
            let continuity = try unsigned("continuity_code", in: values)
            if outcome == 5 {
                guard resultKind == 4, continuity == 0 else { throw Failure.crossField }
            } else if terminalKind == 0 {
                guard resultKind == 5, continuity == 0 else { throw Failure.crossField }
            } else {
                guard resultKind == 6, continuity == 1 else { throw Failure.crossField }
            }
        }
    }

    static func strictSignatureEncoding(_ signature: Data) -> Bool {
        guard signature.count == 64 else { return false }
        return strictPointEncoding(Data(signature.prefix(32))) &&
            scalarIsLessThanOrder(Data(signature.suffix(32)))
    }

    static func validateUninitialized(_ values: [String: Value]) throws {
        let genesisBytes = try bytes("trusted_genesis_body", in: values)
        let genesis = try decode(genesisBytes)
        guard genesis.schema == .genesisInitial || genesis.schema == .genesisMigrationIntent else {
            throw Failure.crossField
        }
        let policyBytes = try bytes("policy_body", in: values)
        let policy = try decode(policyBytes, as: .policy)
        let genesisCommitment = try commitment(genesis)
        let policyCommitment = try commitment(policy)
        let predecessor = try fixedPredecessor(trustedGenesisCommitment: genesisCommitment)
        let encodedGenesisCommitment = try bytes("trusted_genesis_commitment", in: values)
        let encodedPolicyCommitment = try bytes("policy_commitment", in: values)
        let encodedPredecessor = try bytes("fixed_predecessor", in: values)
        let previousTip = try bytes("previous_authority_tip_commitment", in: values)
        let acceptedRecord = try bytes("accepted_record_commitment", in: values)
        let acceptedLineage = try bytes("accepted_lineage_state_commitment", in: values)
        let genesisPolicyByteCount = try unsigned("policy_byte_count", in: genesis.fields)
        let genesisPolicyCommitment = try bytes("policy_commitment", in: genesis.fields)
        let recordVerifierID = try bytes("verifier_id", in: values)
        let genesisVerifierID = try bytes("verifier_id", in: genesis.fields)
        let recordLineageID = try bytes("lineage_id", in: values)
        let genesisLineageID = try bytes("lineage_id", in: genesis.fields)
        let recordEpochID = try bytes("epoch_id", in: values)
        let genesisEpochID = try bytes("epoch_id", in: genesis.fields)
        guard genesisCommitment == encodedGenesisCommitment,
              policyCommitment == encodedPolicyCommitment,
              predecessor == encodedPredecessor,
              predecessor == previousTip,
              predecessor == acceptedRecord,
              predecessor == acceptedLineage,
              policyBytes.count == Int(genesisPolicyByteCount),
              policyCommitment == genesisPolicyCommitment,
              recordVerifierID == genesisVerifierID,
              recordLineageID == genesisLineageID,
              recordEpochID == genesisEpochID else {
            throw Failure.crossField
        }
        let migrationBinding = try bool("migration_binding_present", in: values)
        guard migrationBinding == (genesis.schema == .genesisMigrationIntent) else {
            throw Failure.crossField
        }
        let migrationEnvelope = try bytes(
            "migration_authorization_envelope_commitment",
            in: values
        )
        if !migrationBinding, migrationEnvelope != predecessor {
            throw Failure.crossField
        }
    }

    static func validateAssertionRequest(_ values: [String: Value]) throws {
        let challengeBytes = try bytes("challenge_body", in: values)
        let challengeEnvelopeBytes = try bytes("challenge_envelope", in: values)
        let lineageBytes = try bytes("lineage_state_body", in: values)
        let assertionBytes = try bytes("issuer_assertion_body", in: values)
        let issuerEnvelopeBytes = try bytes("issuer_signature_envelope", in: values)
        let challenge = try decode(challengeBytes, as: .challenge)
        let challengeEnvelope = try decode(challengeEnvelopeBytes, as: .verifierSignatureEnvelope)
        let lineage = try decode(lineageBytes, as: .lineageState)
        let assertion = try decode(assertionBytes, as: .issuerAssertion)
        let issuerEnvelope = try decode(issuerEnvelopeBytes, as: .issuerSignatureEnvelope)
        let challengeKind = try unsigned("signed_body_kind", in: challengeEnvelope.fields)
        let challengeByteCount = try unsigned("signed_body_byte_count", in: challengeEnvelope.fields)
        let challengeCommitment = try commitment(domain: .challengeBody, payload: challengeBytes)
        let encodedChallengeCommitment = try bytes("signed_body_commitment", in: challengeEnvelope.fields)
        let challengeKeyID = try bytes("verifier_key_id", in: challenge.fields)
        let envelopeChallengeKeyID = try bytes("verifier_key_id", in: challengeEnvelope.fields)
        let challengeKeyPosition = try unsigned("verifier_key_position", in: challenge.fields)
        let envelopeChallengeKeyPosition = try unsigned(
            "verifier_key_position",
            in: challengeEnvelope.fields
        )
        let assertionByteCount = try unsigned("assertion_body_byte_count", in: issuerEnvelope.fields)
        let assertionCommitment = try commitment(domain: .assertionBody, payload: assertionBytes)
        let encodedAssertionCommitment = try bytes("assertion_body_commitment", in: issuerEnvelope.fields)
        let assertionKeyID = try bytes("issuer_key_id", in: assertion.fields)
        let envelopeAssertionKeyID = try bytes("issuer_key_id", in: issuerEnvelope.fields)
        let assertionKeyPosition = try unsigned("issuer_key_position", in: assertion.fields)
        let envelopeAssertionKeyPosition = try unsigned(
            "issuer_key_position",
            in: issuerEnvelope.fields
        )
        let lineageByteCount = try unsigned("lineage_state_byte_count", in: assertion.fields)
        let lineageCommitment = try commitment(domain: .lineageState, payload: lineageBytes)
        let encodedLineageCommitment = try bytes("lineage_state_commitment", in: assertion.fields)
        guard challengeKind == 1,
              challengeBytes.count == Int(challengeByteCount),
              challengeCommitment == encodedChallengeCommitment,
              challengeKeyID == envelopeChallengeKeyID,
              challengeKeyPosition == envelopeChallengeKeyPosition,
              assertionBytes.count == Int(assertionByteCount),
              assertionCommitment == encodedAssertionCommitment,
              assertionKeyID == envelopeAssertionKeyID,
              assertionKeyPosition == envelopeAssertionKeyPosition,
              lineageBytes.count == Int(lineageByteCount),
              lineageCommitment == encodedLineageCommitment else {
            throw Failure.crossField
        }

        let joins = [
            ("verifier_id", challenge.fields, assertion.fields),
            ("policy_commitment", challenge.fields, assertion.fields),
            ("audience_id", challenge.fields, assertion.fields),
            ("lineage_id", lineage.fields, assertion.fields),
            ("epoch_id", lineage.fields, assertion.fields),
            ("predecessor_lineage_state_commitment", lineage.fields, assertion.fields),
        ]
        for (key, left, right) in joins {
            let leftValue = try bytes(key, in: left)
            let rightValue = try bytes(key, in: right)
            if leftValue != rightValue {
                throw Failure.crossField
            }
        }
        let lineageSequence = try unsigned("sequence", in: lineage.fields)
        let assertionSequence = try unsigned("sequence", in: assertion.fields)
        let lineageClaim = try unsigned("claim_code", in: lineage.fields)
        let assertionClaim = try unsigned("claim_code", in: assertion.fields)
        let lineageNonclaim = try unsigned("nonclaim_bits", in: lineage.fields)
        let assertionNonclaim = try unsigned("nonclaim_bits", in: assertion.fields)
        guard lineageSequence == assertionSequence,
              lineageClaim == assertionClaim,
              lineageNonclaim == assertionNonclaim,
              Value.text("00000000") == lineage.fields["authority_vector"],
              lineage.fields["authority_vector"] == assertion.fields["authority_vector"] else {
            throw Failure.crossField
        }
    }

    static func validateH4CCanonicalJSON(_ bytes: Data) throws {
        guard !bytes.isEmpty, bytes.count <= 158,
              bytes.allSatisfy({ (0x20...0x7e).contains($0) }) else {
            throw Failure.bound
        }
        let prefix =
            "{\"authority_vector\":\"00000000\",\"claim_state\":\"OBSERVED_NONPASS\",\"predicate_count\":"
        let suffix =
            ",\"schema\":\"com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1\"}"
        let text = String(decoding: bytes, as: UTF8.self)
        guard text.hasPrefix(prefix), text.hasSuffix(suffix) else { throw Failure.noncanonical }
        let countStart = text.index(text.startIndex, offsetBy: prefix.count)
        let countEnd = text.index(text.endIndex, offsetBy: -suffix.count)
        let countText = String(text[countStart..<countEnd])
        guard !countText.isEmpty,
              countText.allSatisfy({ $0 >= "0" && $0 <= "9" }),
              countText == "0" || countText.first != "0",
              let count = UInt64(countText), (1...4_096).contains(count),
              text == prefix + String(count) + suffix else {
            throw Failure.noncanonical
        }
    }

    static func validateH4CDeterministicCBOR(_ bytes: Data) throws {
        guard !bytes.isEmpty, bytes.count <= 158,
              case .map(let values) = try decodeCanonicalValue(bytes),
              Set(values.keys) == Set(["schema", "claim_state", "predicate_count", "authority_vector"]),
              values["schema"] == .text(
                "com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1"
              ),
              values["claim_state"] == .text("OBSERVED_NONPASS"),
              values["authority_vector"] == .text("00000000"),
              case .unsigned(let count)? = values["predicate_count"],
              (1...4_096).contains(count) else {
            throw Failure.noncanonical
        }
    }
}

private extension HypervisorStageH4PrivateVerifierFormat {
    enum FieldRule {
        case text
        case textExact(String)
        case bytes(ClosedRange<Int>)
        case unsigned(ClosedRange<UInt64>)
        case unsignedSet(Set<UInt64>)
        case bool(Bool?)
    }

    static let bytes32 = FieldRule.bytes(32...32)
    static let bytes64 = FieldRule.bytes(64...64)
    static let exactSuite = FieldRule.textExact(suiteID)
    static let exactLineageFormat = FieldRule.textExact(lineageFormatID)
    static let exactAuthority = FieldRule.textExact("00000000")

    static func fields(
        for schema: Schema,
        adding values: [String: FieldRule]
    ) -> [String: FieldRule] {
        var result = values
        result["schema"] = .textExact(schema.rawValue)
        return result
    }

    static func genesisFields(
        for schema: Schema,
        origin: UInt64,
        adding additions: [String: FieldRule] = [:]
    ) -> [String: FieldRule] {
        var values: [String: FieldRule] = [
            "suite_id": exactSuite,
            "lineage_format_id": exactLineageFormat,
            "policy_commitment": bytes32,
            "policy_byte_count": .unsigned(1...16_384),
            "verifier_public_key": bytes32,
            "verifier_id": bytes32,
            "verifier_key_position": .unsigned(0...0),
            "issuer_public_key": bytes32,
            "issuer_key_id": bytes32,
            "issuer_key_position": .unsigned(0...0),
            "storage_key_id": bytes32,
            "storage_key_position": .unsigned(0...0),
            "lineage_id": bytes32,
            "epoch_id": bytes32,
            "genesis_nonce": bytes32,
            "origin_code": .unsigned(origin...origin),
        ]
        for (key, value) in additions { values[key] = value }
        return fields(for: schema, adding: values)
    }

    static func persistentFields(
        for schema: Schema,
        kind: UInt64,
        lifecycle: UInt64,
        adding additions: [String: FieldRule]
    ) -> [String: FieldRule] {
        var values: [String: FieldRule] = [
            "suite_id": exactSuite,
            "record_kind": .unsigned(kind...kind),
            "record_index": .unsigned(1...4_099),
            "previous_authority_tip_commitment": bytes32,
            "trusted_genesis_commitment": bytes32,
            "policy_commitment": bytes32,
            "verifier_id": bytes32,
            "lineage_id": bytes32,
            "epoch_id": bytes32,
            "lifecycle_after": .unsigned(lifecycle...lifecycle),
        ]
        for (key, value) in additions { values[key] = value }
        return fields(for: schema, adding: values)
    }

    static func rules(for schema: Schema) -> [String: FieldRule] {
        switch schema {
        case .privateTokenDescriptor:
            return fields(for: schema, adding: [
                "lineage_format_id": exactLineageFormat,
                "product_id": .text,
                "roadmap_stage_id": .text,
                "stage_id": .text,
                "durable_schema_id": .text,
                "purpose_id": .text,
                "lineage_id": bytes32,
                "epoch_id": bytes32,
                "sequence": .unsigned(0...4_096),
                "field_kind": .unsigned(0...6),
                "field_ordinal": .unsigned(0...4_095),
                "byte_count": .unsigned(0...1_048_576),
                "member_count_0": .unsigned(0...1_048_576),
                "member_count_1": .unsigned(0...1_048_576),
                "member_count_2": .unsigned(0...1_048_576),
                "deterministic_preimage_sha256": bytes32,
            ])
        case .disclosureModeTable:
            return fields(for: schema, adding: [
                "lineage_format_id": exactLineageFormat,
                "context_identifiers_mode": .unsigned(1...1),
                "verifier_audience_policy_issuer_key_mode": .unsigned(1...1),
                "lineage_epoch_sequence_predecessor_mode": .unsigned(1...1),
                "assertion_instance_nonce_mode": .unsigned(1...1),
                "counts_mode": .unsigned(1...1),
                "predicate_token_inventory_mode": .unsigned(2...2),
                "predicate_result_vector_mode": .unsigned(1...1),
                "claim_nonclaim_authority_mode": .unsigned(1...1),
                "d3_semantic_mode": .unsigned(2...2),
                "canonical_json_mode": .unsigned(2...2),
                "deterministic_cbor_mode": .unsigned(2...2),
                "indexed_scalar_mode": .unsigned(2...2),
                "state_witness_transition_graph_mode": .unsigned(2...2),
                "predicate_identifier_mode": .unsigned(2...2),
                "predicate_evidence_mode": .unsigned(2...2),
                "raw_payload_mode": .unsigned(0...0),
                "source_build_tree_host_session_environment_mode": .unsigned(0...0),
                "unrestricted_diagnostic_timestamp_telemetry_log_mode": .unsigned(0...0),
                "h4c_structural_reconstruction_inference_accepted": .bool(true),
            ])
        case .policy:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "lineage_format_id": exactLineageFormat,
                "product_id": .text,
                "roadmap_stage_id": .text,
                "stage_id": .text,
                "durable_schema_id": .text,
                "purpose_id": .text,
                "audience_id": bytes32,
                "disclosure_mode_table_commitment": bytes32,
                "disclosure_mode_table_byte_count": .unsigned(1...4_096),
                "assurance_code": .unsigned(1...1),
                "claim_code": .unsigned(0...0),
                "authority_vector": exactAuthority,
                "predicate_count_max": .unsigned(4_096...4_096),
                "accepted_transition_max": .unsigned(4_096...4_096),
                "private_token_mode": .unsigned(1...1),
                "hidden_semantic_verification": .unsigned(0...0),
                "in_epoch_rotation": .unsigned(0...0),
                "backup_or_replica": .unsigned(0...0),
            ])
        case .genesisInitial:
            return genesisFields(for: schema, origin: 0)
        case .genesisMigrationIntent:
            return genesisFields(for: schema, origin: 1, adding: [
                "expected_old_verifier_id": bytes32,
                "expected_old_trusted_genesis_commitment": bytes32,
                "migration_nonce": bytes32,
            ])
        case .uninitializedRecord:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "record_kind": .unsigned(1...1),
                "record_index": .unsigned(0...0),
                "previous_authority_tip_commitment": bytes32,
                "lifecycle_code": .unsigned(1...1),
                "trusted_genesis_body": .bytes(1...16_384),
                "trusted_genesis_commitment": bytes32,
                "policy_body": .bytes(1...16_384),
                "policy_commitment": bytes32,
                "verifier_id": bytes32,
                "lineage_id": bytes32,
                "epoch_id": bytes32,
                "fixed_predecessor": bytes32,
                "accepted_sequence": .unsigned(0...0),
                "accepted_present": .bool(false),
                "accepted_record_commitment": bytes32,
                "accepted_lineage_state_commitment": bytes32,
                "migration_binding_present": .bool(nil),
                "migration_authorization_envelope_commitment": bytes32,
            ])
        case .lineageState:
            return fields(for: schema, adding: [
                "lineage_format_id": exactLineageFormat,
                "product_id": .text,
                "roadmap_stage_id": .text,
                "stage_id": .text,
                "durable_schema_id": .text,
                "purpose_id": .text,
                "lineage_id": bytes32,
                "epoch_id": bytes32,
                "sequence": .unsigned(0...4_096),
                "predecessor_lineage_state_commitment": bytes32,
                "d3_semantic_private_token": bytes32,
                "d3_semantic_member_count": .unsigned(4...4),
                "canonical_json_private_token": bytes32,
                "canonical_json_byte_count": .unsigned(1...158),
                "deterministic_cbor_private_token": bytes32,
                "deterministic_cbor_byte_count": .unsigned(1...158),
                "indexed_scalar_private_token": bytes32,
                "indexed_scalar_member_count": .unsigned(4...4),
                "graph_private_token": bytes32,
                "graph_state_count": .unsigned(0...4_096),
                "graph_witness_count": .unsigned(0...4_096),
                "graph_transition_count": .unsigned(0...4_096),
                "predicate_count": .unsigned(1...4_096),
                "predicate_identifier_tokens": .bytes(32...131_072),
                "predicate_result_codes": .bytes(1...4_096),
                "predicate_evidence_tokens": .bytes(32...131_072),
                "claim_code": .unsigned(0...0),
                "nonclaim_bits": .unsigned(1_023...1_023),
                "authority_vector": exactAuthority,
            ])
        case .issuerAssertion:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "trusted_genesis_commitment": bytes32,
                "policy_commitment": bytes32,
                "verifier_id": bytes32,
                "audience_id": bytes32,
                "issuer_key_id": bytes32,
                "issuer_key_position": .unsigned(0...0),
                "assertion_instance_nonce": bytes32,
                "lineage_id": bytes32,
                "epoch_id": bytes32,
                "sequence": .unsigned(0...4_096),
                "predecessor_lineage_state_commitment": bytes32,
                "lineage_state_commitment": bytes32,
                "lineage_state_byte_count": .unsigned(1...524_288),
                "claim_code": .unsigned(0...0),
                "nonclaim_bits": .unsigned(1_023...1_023),
                "authority_vector": exactAuthority,
            ])
        case .issuerSignatureEnvelope:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "signature_algorithm": .unsigned(1...1),
                "issuer_key_id": bytes32,
                "issuer_key_position": .unsigned(0...0),
                "assertion_body_commitment": bytes32,
                "assertion_body_byte_count": .unsigned(1...16_384),
                "signature": bytes64,
            ])
        case .challenge:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "verifier_key_id": bytes32,
                "verifier_key_position": .unsigned(0...0),
                "policy_commitment": bytes32,
                "audience_id": bytes32,
                "challenge_nonce": bytes32,
                "challenge_purpose": .unsigned(1...1),
            ])
        case .verifierSignatureEnvelope:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "signed_body_kind": .unsigned(1...3),
                "verifier_key_id": bytes32,
                "verifier_key_position": .unsigned(0...0),
                "signed_body_commitment": bytes32,
                "signed_body_byte_count": .unsigned(1...16_384),
                "signature": bytes64,
            ])
        case .assertionRequest:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "challenge_body": .bytes(1...4_096),
                "challenge_envelope": .bytes(1...1_024),
                "lineage_state_body": .bytes(1...524_288),
                "issuer_assertion_body": .bytes(1...16_384),
                "issuer_signature_envelope": .bytes(1...1_024),
            ])
        case .verifierDecision:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "policy_commitment": bytes32,
                "request_commitment": bytes32,
                "challenge_body_commitment": bytes32,
                "lifecycle_before": .unsigned(1...5),
                "prior_authority_pointer_commitment": bytes32,
                "prior_authority_generation": .unsigned(0...4_099),
                "prior_authority_tip_commitment": bytes32,
                "prior_accepted_present": .bool(nil),
                "prior_accepted_sequence": .unsigned(0...4_095),
                "prior_accepted_record_commitment": bytes32,
                "prior_lineage_state_commitment": bytes32,
                "candidate_sequence": .unsigned(0...4_096),
                "candidate_predecessor_commitment": bytes32,
                "candidate_lineage_state_commitment": bytes32,
                "candidate_assertion_body_commitment": bytes32,
                "candidate_signature_envelope_commitment": bytes32,
                "internal_decision_code": .unsignedSet([1, 2, 3, 4, 5, 22, 23, 24, 25, 26, 27]),
                "proposed_persistent_record_kind": .unsignedSet([0, 2, 3]),
            ])
        case .acceptedTransition:
            return persistentFields(for: schema, kind: 2, lifecycle: 2, adding: [
                "sequence": .unsigned(0...4_095),
                "predecessor_lineage_state_commitment": bytes32,
                "lineage_state_commitment": bytes32,
                "issuer_assertion_body_commitment": bytes32,
                "issuer_signature_envelope_commitment": bytes32,
                "verifier_decision_commitment": bytes32,
                "issuer_key_position": .unsigned(0...0),
                "verifier_key_position": .unsigned(0...0),
                "prior_accepted_record_commitment": bytes32,
            ])
        case .conflictTombstone:
            return persistentFields(for: schema, kind: 3, lifecycle: 3, adding: [
                "occupied_sequence": .unsigned(0...4_095),
                "common_predecessor_lineage_state_commitment": bytes32,
                "accepted_record_commitment": bytes32,
                "accepted_lineage_state_commitment": bytes32,
                "accepted_assertion_body_commitment": bytes32,
                "accepted_signature_envelope_commitment": bytes32,
                "accepted_decision_commitment": bytes32,
                "competing_lineage_state_commitment": bytes32,
                "competing_assertion_body_commitment": bytes32,
                "competing_signature_envelope_commitment": bytes32,
                "competing_decision_commitment": bytes32,
                "issuer_key_position": .unsigned(0...0),
                "conflict_lock_code": .unsigned(1...1),
            ])
        case .storageFaultLatch:
            return persistentFields(for: schema, kind: 4, lifecycle: 4, adding: [
                "last_authenticated_authority_tip_commitment": bytes32,
                "last_authenticated_accepted_record_or_fixed_predecessor": bytes32,
                "attempted_record_body_commitment": bytes32,
                "attempted_record_kind": .unsignedSet([2, 3, 5, 6]),
                "fault_code": .unsigned(1...4),
                "fault_lock_code": .unsigned(1...1),
            ])
        case .terminalClose:
            return persistentFields(for: schema, kind: 5, lifecycle: 5, adding: [
                "terminal_request_commitment": bytes32,
                "accepted_present": .bool(nil),
                "accepted_sequence": .unsigned(0...4_095),
                "accepted_record_or_fixed_predecessor": bytes32,
                "accepted_lineage_state_or_fixed_predecessor": bytes32,
                "terminal_reason": .unsigned(1...4),
                "continuity_code": .unsigned(0...0),
            ])
        case .terminalMigration:
            return persistentFields(for: schema, kind: 6, lifecycle: 5, adding: [
                "terminal_request_commitment": bytes32,
                "accepted_present": .bool(true),
                "accepted_sequence": .unsigned(0...4_095),
                "accepted_record_commitment": bytes32,
                "accepted_lineage_state_commitment": bytes32,
                "new_genesis_intent_commitment": bytes32,
                "new_verifier_id": bytes32,
                "migration_nonce": bytes32,
                "terminal_reason": .unsigned(5...5),
                "continuity_code": .unsigned(1...1),
            ])
        case .storageRecordWrapper:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "record_kind": .unsigned(1...6),
                "record_index": .unsigned(0...4_099),
                "previous_record_auth_tag": bytes32,
                "record_body_commitment": bytes32,
                "record_body_byte_count": .unsigned(1...65_536),
            ])
        case .authorityPointer:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "trusted_genesis_commitment": bytes32,
                "policy_commitment": bytes32,
                "lineage_id": bytes32,
                "epoch_id": bytes32,
                "authority_generation": .unsigned(0...4_099),
                "authority_tip_record_index": .unsigned(0...4_099),
                "authority_tip_record_kind": .unsigned(1...6),
                "authority_tip_record_commitment": bytes32,
                "authority_tip_record_auth_tag": bytes32,
                "lifecycle_code": .unsigned(1...5),
                "accepted_present": .bool(nil),
                "accepted_sequence": .unsigned(0...4_095),
                "accepted_record_or_fixed_predecessor": bytes32,
                "accepted_lineage_state_or_fixed_predecessor": bytes32,
            ])
        case .terminalCloseRequest:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "trusted_genesis_commitment": bytes32,
                "expected_authority_pointer_commitment": bytes32,
                "terminal_kind": .unsigned(0...0),
                "terminal_reason": .unsigned(1...4),
            ])
        case .terminalMigrationRequest:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "trusted_genesis_commitment": bytes32,
                "expected_authority_pointer_commitment": bytes32,
                "terminal_kind": .unsigned(1...1),
                "terminal_reason": .unsigned(5...5),
                "new_genesis_intent_commitment": bytes32,
                "new_verifier_id": bytes32,
                "migration_nonce": bytes32,
            ])
        case .migrationAuthorization:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "old_verifier_id": bytes32,
                "old_verifier_public_key": bytes32,
                "old_verifier_key_position": .unsigned(0...0),
                "old_trusted_genesis_commitment": bytes32,
                "old_terminal_migration_record_commitment": bytes32,
                "old_terminal_record_index": .unsigned(1...4_099),
                "old_accepted_sequence": .unsigned(0...4_095),
                "old_accepted_lineage_state_commitment": bytes32,
                "new_verifier_id": bytes32,
                "new_genesis_intent_commitment": bytes32,
                "migration_nonce": bytes32,
                "continuity_code": .unsigned(1...1),
            ])
        case .receiptAcceptedCurrent:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "verifier_key_id": bytes32,
                "verifier_key_position": .unsigned(0...0),
                "policy_commitment": bytes32,
                "audience_id": bytes32,
                "challenge_body_commitment": bytes32,
                "request_commitment": bytes32,
                "decision_commitment": bytes32,
                "outcome_code": .unsigned(1...2),
                "accepted_sequence": .unsigned(0...4_095),
                "accepted_record_commitment": bytes32,
                "accepted_lineage_state_commitment": bytes32,
                "authority_pointer_commitment": bytes32,
                "authority_tip_commitment": bytes32,
                "authority_generation": .unsigned(1...4_099),
                "claim_code": .unsigned(0...0),
                "nonclaim_bits": .unsigned(1_023...1_023),
                "authority_vector": exactAuthority,
            ])
        case .receiptMinimized:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "verifier_key_id": bytes32,
                "verifier_key_position": .unsigned(0...0),
                "policy_commitment": bytes32,
                "audience_id": bytes32,
                "challenge_body_commitment": bytes32,
                "request_commitment": bytes32,
                "outcome_code": .unsigned(3...5),
                "claim_code": .unsigned(0...0),
                "nonclaim_bits": .unsigned(1_023...1_023),
                "authority_vector": exactAuthority,
            ])
        case .receiptTerminal:
            return fields(for: schema, adding: [
                "suite_id": exactSuite,
                "verifier_id": bytes32,
                "verifier_key_id": bytes32,
                "verifier_key_position": .unsigned(0...0),
                "policy_commitment": bytes32,
                "terminal_request_commitment": bytes32,
                "outcome_code": .unsigned(5...6),
                "terminal_kind": .unsigned(0...1),
                "result_record_kind": .unsigned(4...6),
                "result_record_commitment": bytes32,
                "continuity_code": .unsigned(0...1),
            ])
        }
    }

    static func validateFields(_ values: [String: Value], schema: Schema) throws {
        let expected = rules(for: schema)
        guard values.count == expected.count, Set(values.keys) == Set(expected.keys) else {
            throw Failure.fieldInventory
        }
        for (key, rule) in expected {
            guard let value = values[key] else { throw Failure.fieldInventory }
            try validate(value, rule: rule)
        }
        try validateRequiredNonzeroBytes(values)
        try validateCrossFields(values, schema: schema)
    }

    static func validateRequiredNonzeroBytes(_ values: [String: Value]) throws {
        let exactNames: Set<String> = [
            "fixed_predecessor",
            "accepted_record_or_fixed_predecessor",
            "accepted_lineage_state_or_fixed_predecessor",
            "last_authenticated_accepted_record_or_fixed_predecessor",
            "assertion_instance_nonce",
            "challenge_nonce",
        ]
        for (key, value) in values {
            guard case .bytes(let bytes) = value else { continue }
            let required = key.hasSuffix("_commitment") || key.hasSuffix("_id") ||
                exactNames.contains(key)
            if required, bytes.allSatisfy({ $0 == 0 }) {
                throw Failure.fieldValue
            }
        }
    }

    static func validate(_ value: Value, rule: FieldRule) throws {
        switch (value, rule) {
        case (.text(let actual), .text):
            _ = try validatedTextBytes(actual)
        case (.text(let actual), .textExact(let expected)):
            _ = try validatedTextBytes(actual)
            guard actual.utf8.elementsEqual(expected.utf8) else { throw Failure.fieldValue }
        case (.bytes(let bytes), .bytes(let range)):
            guard range.contains(bytes.count) else { throw Failure.fieldValue }
        case (.unsigned(let number), .unsigned(let range)):
            guard range.contains(number) else { throw Failure.fieldValue }
        case (.unsigned(let number), .unsignedSet(let allowed)):
            guard allowed.contains(number) else { throw Failure.fieldValue }
        case (.bool(let actual), .bool(let expected)):
            if let expected, actual != expected { throw Failure.fieldValue }
        default:
            throw Failure.fieldType
        }
    }

    static func unsigned(_ key: String, in values: [String: Value]) throws -> UInt64 {
        guard case .unsigned(let result)? = values[key] else { throw Failure.fieldType }
        return result
    }

    static func bytes(_ key: String, in values: [String: Value]) throws -> Data {
        guard case .bytes(let result)? = values[key] else { throw Failure.fieldType }
        return result
    }

    static func textValue(_ key: String, in values: [String: Value]) throws -> String {
        guard case .text(let result)? = values[key] else { throw Failure.fieldType }
        return result
    }

    static func bool(_ key: String, in values: [String: Value]) throws -> Bool {
        guard case .bool(let result)? = values[key] else { throw Failure.fieldType }
        return result
    }

    static func requireNonzero(_ keys: [String], in values: [String: Value]) throws {
        for key in keys {
            if try bytes(key, in: values).allSatisfy({ $0 == 0 }) {
                throw Failure.fieldValue
            }
        }
    }

    static func requireEqual(_ keys: [String], in values: [String: Value]) throws {
        guard let first = keys.first else { return }
        let expected = try bytes(first, in: values)
        for key in keys.dropFirst() {
            if try bytes(key, in: values) != expected {
                throw Failure.crossField
            }
        }
    }
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Foundation
import PrimeCore

public enum PrimeValidationTrackedTreeRootRoleV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case repository
    case companion

    fileprivate var maximumFileByteCount: UInt64 {
        switch self {
        case .repository:
            8 * 1024 * 1024
        case .companion:
            64 * 1024 * 1024
        }
    }
}

public enum PrimeValidationTrackedTreeManifestHeldKindV2:
    String,
    Codable,
    Sendable
{
    case regularFile = "regular_file"
    case symbolicLink = "symbolic_link"
}

public struct PrimeValidationTrackedTreeRawTreeV2:
    Codable,
    Equatable,
    Sendable
{
    public let bytes: Data
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(bytes: Data) {
        self.bytes = bytes
        byteCount = UInt64(bytes.count)
        sha256 = PrimeSHA256.hexDigest(of: bytes)
    }

    fileprivate func validate() throws {
        guard !bytes.isEmpty,
              bytes.count <= PrimeValidationTrackedTreeCodecV2
                .maximumRawTreeByteCount,
              byteCount == UInt64(bytes.count),
              sha256 == PrimeSHA256.hexDigest(of: bytes)
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        try PrimeValidationDriverV2Validation.requireSHA256(sha256)
    }

    private enum CodingKeys: String, CodingKey {
        case bytes
        case byteCount = "byte_count"
        case sha256
    }
}

public struct PrimeValidationTrackedTreeManifestEntryV2:
    Codable,
    Equatable,
    Sendable
{
    public let rawPathBytes: Data
    public let gitMode: String
    public let gitObjectType: String
    public let gitObjectID: String
    public let heldKind: PrimeValidationTrackedTreeManifestHeldKindV2
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(
        rawPathBytes: Data,
        gitMode: String,
        gitObjectType: String,
        gitObjectID: String,
        heldKind: PrimeValidationTrackedTreeManifestHeldKindV2,
        byteCount: UInt64,
        sha256: String
    ) {
        self.rawPathBytes = rawPathBytes
        self.gitMode = gitMode
        self.gitObjectType = gitObjectType
        self.gitObjectID = gitObjectID
        self.heldKind = heldKind
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    private enum CodingKeys: String, CodingKey {
        case rawPathBytes = "raw_path_bytes"
        case gitMode = "git_mode"
        case gitObjectType = "git_object_type"
        case gitObjectID = "git_object_id"
        case heldKind = "held_kind"
        case byteCount = "byte_count"
        case sha256
    }
}

public struct PrimeValidationTrackedTreeManifestV2:
    Codable,
    Equatable,
    Sendable
{
    public static let artifactKind =
        "ergentics_prime_validation_driver_v2_tracked_tree_manifest_v1"
    public static let schemaVersion = 1
    public static let objectFormat = "sha1"

    public let artifactKind: String
    public let schemaVersion: Int
    public let rootRole: PrimeValidationTrackedTreeRootRoleV2
    public let objectFormat: String
    public let rawTree: PrimeValidationTrackedTreeRawTreeV2
    public let entries: [PrimeValidationTrackedTreeManifestEntryV2]

    fileprivate init(
        rootRole: PrimeValidationTrackedTreeRootRoleV2,
        rawTree: PrimeValidationTrackedTreeRawTreeV2,
        entries: [PrimeValidationTrackedTreeManifestEntryV2]
    ) {
        artifactKind = Self.artifactKind
        schemaVersion = Self.schemaVersion
        self.rootRole = rootRole
        objectFormat = Self.objectFormat
        self.rawTree = rawTree
        self.entries = entries
    }

    public func validate() throws {
        guard artifactKind == Self.artifactKind,
              schemaVersion == Self.schemaVersion,
              objectFormat == Self.objectFormat,
              !entries.isEmpty,
              entries.count
                <= PrimeValidationTrackedTreeCodecV2.maximumEntryCount
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        try rawTree.validate()
        let parsed = try PrimeValidationTrackedTreeCodecV2.parseTree(
            rawTree.bytes
        )
        guard parsed.count == entries.count else {
            throw PrimeValidationDriverV2Error.invalidTree
        }

        var aggregateByteCount: UInt64 = 0
        for (git, entry) in zip(parsed, entries) {
            guard git.rawPathBytes == entry.rawPathBytes,
                  git.mode == entry.gitMode,
                  git.objectType == entry.gitObjectType,
                  git.objectID == entry.gitObjectID,
                  entry.byteCount <= rootRole.maximumFileByteCount,
                  PrimeValidationDriverV2Validation.isSHA256(entry.sha256)
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            switch (entry.gitMode, entry.heldKind) {
            case ("100644", .regularFile),
                 ("100755", .regularFile),
                 ("120000", .symbolicLink):
                break
            default:
                throw PrimeValidationDriverV2Error.invalidTree
            }
            let next = aggregateByteCount.addingReportingOverflow(
                entry.byteCount
            )
            guard !next.overflow,
                  next.partialValue
                    <= PrimeValidationTrackedTreeCodecV2
                        .maximumAggregateHeldByteCount
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            aggregateByteCount = next.partialValue
        }
    }

    public func canonicalBytes() throws -> Data {
        try validate()
        let bytes = try PrimeCanonicalJSON.encode(self)
        guard bytes.count
                <= PrimeValidationTrackedTreeCodecV2
                    .maximumCanonicalManifestByteCount
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        return bytes
    }

    public static func decodeCanonical(
        _ bytes: Data
    ) throws -> Self {
        guard !bytes.isEmpty,
              bytes.count
                <= PrimeValidationTrackedTreeCodecV2
                    .maximumCanonicalManifestByteCount
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let manifest: Self
        do {
            manifest = try PrimeCanonicalJSON.decode(
                Self.self,
                from: bytes,
                artifact: "driver_v2_tracked_tree_manifest"
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        try manifest.validate()
        guard try PrimeCanonicalJSON.encode(manifest) == bytes else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        return manifest
    }

    private enum CodingKeys: String, CodingKey {
        case artifactKind = "artifact_kind"
        case schemaVersion = "schema_version"
        case rootRole = "root_role"
        case objectFormat = "object_format"
        case rawTree = "raw_tree"
        case entries
    }
}

/// A canonical manifest produced only by the held-entry join. Canonical bytes
/// can be decoded as `PrimeValidationTrackedTreeManifestV2` for verification,
/// but cannot be decoded back into this joined mechanics value.
public struct PrimeValidationTrackedTreeManifestArtifactV2:
    Equatable,
    Sendable
{
    public let manifest: PrimeValidationTrackedTreeManifestV2
    public let canonicalBytes: Data
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(
        manifest: PrimeValidationTrackedTreeManifestV2
    ) throws {
        let bytes = try manifest.canonicalBytes()
        self.manifest = manifest
        canonicalBytes = bytes
        byteCount = UInt64(bytes.count)
        sha256 = PrimeSHA256.hexDigest(of: bytes)
    }

    public func validate() throws {
        try manifest.validate()
        guard !canonicalBytes.isEmpty,
              canonicalBytes.count
                <= PrimeValidationTrackedTreeCodecV2
                    .maximumCanonicalManifestByteCount,
              byteCount == UInt64(canonicalBytes.count),
              sha256 == PrimeSHA256.hexDigest(of: canonicalBytes),
              PrimeValidationDriverV2Validation.isSHA256(sha256),
              try manifest.canonicalBytes() == canonicalBytes,
              try PrimeValidationTrackedTreeManifestV2.decodeCanonical(
                canonicalBytes
              ) == manifest
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
    }

}

/// Pure mechanics binding. This value is intentionally non-Codable and has no
/// public initializer. A later live adapter must additionally retain the
/// PrimeCore capability which produced its held-entry observations.
public struct PrimeValidationRepositoryTrackedTreeBindingV2:
    Equatable,
    Sendable
{
    public let repositoryManifest:
        PrimeValidationTrackedTreeManifestArtifactV2
    public let companionManifest:
        PrimeValidationTrackedTreeManifestArtifactV2
    public let repositoryReceiptIdentitySHA256: String

    fileprivate init(
        receipt: PrimeValidationRepositoryAdmissionReceiptV2,
        intent: PrimeValidationRunIntentV2,
        repositoryManifest:
            PrimeValidationTrackedTreeManifestArtifactV2,
        companionManifest:
            PrimeValidationTrackedTreeManifestArtifactV2
    ) throws {
        self.repositoryManifest = repositoryManifest
        self.companionManifest = companionManifest
        repositoryReceiptIdentitySHA256 =
            try receipt.identitySHA256(intent: intent)
        try validate(receipt: receipt, intent: intent)
    }

    public func validate(
        receipt: PrimeValidationRepositoryAdmissionReceiptV2,
        intent: PrimeValidationRunIntentV2
    ) throws {
        try receipt.validate(intent: intent)
        try repositoryManifest.validate()
        try companionManifest.validate()
        let expectedReceiptIdentity = try receipt.identitySHA256(
            intent: intent
        )
        guard repositoryManifest.manifest.rootRole == .repository,
              companionManifest.manifest.rootRole == .companion,
              repositoryManifest.sha256
                == receipt.repositoryTrackedTreeSHA256,
              companionManifest.sha256
                == receipt.companionTrackedTreeSHA256,
              repositoryReceiptIdentitySHA256
                == expectedReceiptIdentity
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "tracked_tree_manifests"
            )
        }
    }
}

extension PrimeValidationRepositoryAdmissionReceiptV2 {
    func bindingTrackedTreeManifests(
        intent: PrimeValidationRunIntentV2,
        repositoryManifest:
            PrimeValidationTrackedTreeManifestArtifactV2,
        companionManifest:
            PrimeValidationTrackedTreeManifestArtifactV2
    ) throws -> PrimeValidationRepositoryTrackedTreeBindingV2 {
        try PrimeValidationRepositoryTrackedTreeBindingV2(
            receipt: self,
            intent: intent,
            repositoryManifest: repositoryManifest,
            companionManifest: companionManifest
        )
    }
}

public enum PrimeValidationTrackedTreeManifestBuilderV2 {
    public static func repository(
        objectFormatOutput: Data,
        rawTreeOutput: Data,
        heldEntries: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) throws -> PrimeValidationTrackedTreeManifestArtifactV2 {
        try make(
            rootRole: .repository,
            objectFormatOutput: objectFormatOutput,
            rawTreeOutput: rawTreeOutput,
            heldEntries: heldEntries
        )
    }

    public static func companion(
        objectFormatOutput: Data,
        rawTreeOutput: Data,
        heldEntries: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) throws -> PrimeValidationTrackedTreeManifestArtifactV2 {
        try make(
            rootRole: .companion,
            objectFormatOutput: objectFormatOutput,
            rawTreeOutput: rawTreeOutput,
            heldEntries: heldEntries
        )
    }

    private static func make(
        rootRole: PrimeValidationTrackedTreeRootRoleV2,
        objectFormatOutput: Data,
        rawTreeOutput: Data,
        heldEntries: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) throws -> PrimeValidationTrackedTreeManifestArtifactV2 {
        guard objectFormatOutput
                == PrimeValidationTrackedTreeCodecV2.objectFormatOutput
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let parsed = try PrimeValidationTrackedTreeCodecV2.parseTree(
            rawTreeOutput
        )
        guard parsed.count == heldEntries.count else {
            throw PrimeValidationDriverV2Error.invalidTree
        }

        var entries: [PrimeValidationTrackedTreeManifestEntryV2] = []
        entries.reserveCapacity(parsed.count)
        var aggregateByteCount: UInt64 = 0
        var heldNodeIdentities = Set<String>()
        for (git, held) in zip(parsed, heldEntries) {
            let entry = try joinedEntry(
                git: git,
                held: held,
                rootRole: rootRole
            )
            let next = aggregateByteCount.addingReportingOverflow(
                entry.byteCount
            )
            let heldNodeIdentity =
                "\(held.openedIdentity.deviceID):" +
                "\(held.openedIdentity.inode)"
            guard !next.overflow,
                  next.partialValue
                    <= PrimeValidationTrackedTreeCodecV2
                        .maximumAggregateHeldByteCount,
                  heldNodeIdentities.insert(heldNodeIdentity).inserted
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            aggregateByteCount = next.partialValue
            entries.append(entry)
        }
        return try PrimeValidationTrackedTreeManifestArtifactV2(
            manifest: PrimeValidationTrackedTreeManifestV2(
                rootRole: rootRole,
                rawTree: PrimeValidationTrackedTreeRawTreeV2(
                    bytes: rawTreeOutput
                ),
                entries: entries
            )
        )
    }

    private static func joinedEntry(
        git: PrimeValidationTrackedTreeCodecV2.ParsedEntry,
        held: PrimeValidationDriverV2TrackedTreeHeldEntry,
        rootRole: PrimeValidationTrackedTreeRootRoleV2
    ) throws -> PrimeValidationTrackedTreeManifestEntryV2 {
        let opened = held.openedIdentity
        guard held.rawPathBytes == git.rawPathBytes,
              opened == held.postReadDescriptorIdentity,
              opened == held.namedPathReboundIdentity,
              opened.deviceID > 0,
              opened.inode > 0,
              opened.linkCount == 1,
              opened.byteCount == held.byteCount,
              held.byteCount == UInt64(held.contents.count),
              held.byteCount <= rootRole.maximumFileByteCount,
              held.sha256 == PrimeSHA256.hexDigest(of: held.contents),
              held.gitBlobSHA1
                == PrimeValidationTrackedTreeCodecV2.gitBlobSHA1(
                    held.contents
                ),
              held.gitBlobSHA1 == git.objectID
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }

        let heldKind: PrimeValidationTrackedTreeManifestHeldKindV2
        switch (git.mode, held.kind, opened.posixFileType) {
        case (
            "100644",
            .regularFile,
            .regularFile
        ):
            guard opened.permissionMode & 0o100 == 0 else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            heldKind = .regularFile
        case (
            "100755",
            .regularFile,
            .regularFile
        ):
            guard opened.permissionMode & 0o100 == 0o100 else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            heldKind = .regularFile
        case (
            "120000",
            .symbolicLink,
            .symbolicLink
        ):
            heldKind = .symbolicLink
        default:
            throw PrimeValidationDriverV2Error.invalidTree
        }

        return PrimeValidationTrackedTreeManifestEntryV2(
            rawPathBytes: git.rawPathBytes,
            gitMode: git.mode,
            gitObjectType: git.objectType,
            gitObjectID: git.objectID,
            heldKind: heldKind,
            byteCount: held.byteCount,
            sha256: held.sha256
        )
    }
}

private enum PrimeValidationTrackedTreeCodecV2 {
    static let maximumRawTreeByteCount = 16 * 1024 * 1024
    static let maximumCanonicalManifestByteCount = 64 * 1024 * 1024
    static let maximumEntryCount = 4_096
    static let maximumPathByteCount = 1_023
    static let maximumPathComponentByteCount = 255
    static let maximumPathComponentCount = 32
    static let maximumAggregateHeldByteCount: UInt64 =
        512 * 1024 * 1024
    static let objectFormatOutput = Data([0x73, 0x68, 0x61, 0x31, 0x0a])

    struct ParsedEntry: Equatable {
        let mode: String
        let objectType: String
        let objectID: String
        let rawPathBytes: Data
    }

    static func parseTree(_ data: Data) throws -> [ParsedEntry] {
        guard !data.isEmpty,
              data.count <= maximumRawTreeByteCount,
              data.last == 0
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let bytes = [UInt8](data)
        var entries: [ParsedEntry] = []
        entries.reserveCapacity(min(maximumEntryCount, 256))
        var recordStart = 0
        var previousPath: Data?
        var admittedPaths = Set<Data>()

        for index in bytes.indices where bytes[index] == 0 {
            guard index > recordStart,
                  entries.count < maximumEntryCount
            else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            let record = Array(bytes[recordStart ..< index])
            let entry = try parseRecord(record)
            if let previousPath {
                guard previousPath.lexicographicallyPrecedes(
                    entry.rawPathBytes
                ) else {
                    throw PrimeValidationDriverV2Error.invalidTree
                }
            }
            try validatePath(
                entry.rawPathBytes,
                admittedPaths: admittedPaths
            )
            guard admittedPaths.insert(entry.rawPathBytes).inserted else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
            entries.append(entry)
            previousPath = entry.rawPathBytes
            recordStart = index + 1
        }
        guard recordStart == bytes.count,
              !entries.isEmpty
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        return entries
    }

    private static func parseRecord(
        _ record: [UInt8]
    ) throws -> ParsedEntry {
        // Six mode bytes, SP, "blob", SP, forty OID bytes, TAB, and at
        // least one path byte.
        guard record.count >= 54,
              record[6] == 0x20,
              Array(record[7 ..< 11]) == Array("blob".utf8),
              record[11] == 0x20,
              record[52] == 0x09
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let modeBytes = Array(record[0 ..< 6])
        let acceptedModes = [
            Array("100644".utf8),
            Array("100755".utf8),
            Array("120000".utf8),
        ]
        guard acceptedModes.contains(modeBytes) else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let objectIDBytes = Array(record[12 ..< 52])
        guard objectIDBytes.allSatisfy(isLowercaseHexadecimal),
              objectIDBytes.contains(where: { $0 != 0x30 })
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let path = Data(record[53...])
        guard !path.isEmpty else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        return ParsedEntry(
            mode: String(decoding: modeBytes, as: UTF8.self),
            objectType: "blob",
            objectID: String(decoding: objectIDBytes, as: UTF8.self),
            rawPathBytes: path
        )
    }

    private static func validatePath(
        _ path: Data,
        admittedPaths: Set<Data>
    ) throws {
        guard !path.isEmpty,
              path.count <= maximumPathByteCount,
              path.first != 0x2f,
              path.last != 0x2f,
              !path.contains(0)
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }
        let components = path.split(
            separator: 0x2f,
            omittingEmptySubsequences: false
        )
        guard !components.isEmpty,
              components.count <= maximumPathComponentCount,
              components.allSatisfy({ component in
                  !component.isEmpty
                    && component.count <= maximumPathComponentByteCount
                    && component != Data(".".utf8)
                    && component != Data("..".utf8)
              }),
              components.first != Data(".git".utf8)
        else {
            throw PrimeValidationDriverV2Error.invalidTree
        }

        var ancestor = Data()
        for (index, component) in components.dropLast().enumerated() {
            if index > 0 {
                ancestor.append(0x2f)
            }
            ancestor.append(contentsOf: component)
            guard !admittedPaths.contains(ancestor) else {
                throw PrimeValidationDriverV2Error.invalidTree
            }
        }
    }

    static func gitBlobSHA1(_ contents: Data) -> String {
        var framed = Data("blob \(contents.count)\0".utf8)
        framed.append(contents)
        return hexadecimal(Insecure.SHA1.hash(data: framed))
    }

    private static func isLowercaseHexadecimal(_ byte: UInt8) -> Bool {
        (byte >= 0x30 && byte <= 0x39)
            || (byte >= 0x61 && byte <= 0x66)
    }

    private static func hexadecimal<Digest: Sequence>(
        _ digest: Digest
    ) -> String where Digest.Element == UInt8 {
        let alphabet = Array("0123456789abcdef".utf8)
        var bytes: [UInt8] = []
        bytes.reserveCapacity(40)
        for byte in digest {
            bytes.append(alphabet[Int(byte >> 4)])
            bytes.append(alphabet[Int(byte & 0x0f)])
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}

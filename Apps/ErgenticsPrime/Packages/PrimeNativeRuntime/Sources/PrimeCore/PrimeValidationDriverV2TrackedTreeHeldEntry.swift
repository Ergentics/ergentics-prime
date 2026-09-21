// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Foundation

public enum PrimeValidationDriverV2TrackedTreeHeldKind:
    Equatable,
    Sendable
{
    case regularFile
    case symbolicLink
}

public enum PrimeValidationDriverV2TrackedTreePOSIXFileType:
    Equatable,
    Sendable
{
    case regularFile
    case symbolicLink
}

/// One immutable metadata reading made while a tracked-tree entry is held.
///
/// This is evidence data only. It contains no descriptor or named-path
/// capability and deliberately has no Codable conformance.
public struct PrimeValidationDriverV2TrackedTreeHeldIdentity:
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let byteCount: UInt64
    public let posixFileType:
        PrimeValidationDriverV2TrackedTreePOSIXFileType

    init(
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        permissionMode: UInt16,
        linkCount: UInt64,
        byteCount: UInt64,
        posixFileType:
            PrimeValidationDriverV2TrackedTreePOSIXFileType
    ) {
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.permissionMode = permissionMode
        self.linkCount = linkCount
        self.byteCount = byteCount
        self.posixFileType = posixFileType
    }
}

enum PrimeValidationDriverV2TrackedTreeHeldEntryError:
    Error,
    Equatable,
    Sendable
{
    case rejected(String)
}

/// A descriptor-read tracked-tree entry after its opened, post-read, and
/// named-path-rebound identities have joined exactly.
///
/// `contents` is either regular-file content or the bytes returned by a held
/// no-follow symbolic-link read. The value returns no live descriptor and
/// cannot be decoded into one.
public struct PrimeValidationDriverV2TrackedTreeHeldEntry:
    Equatable,
    Sendable
{
    public let rawPathBytes: Data
    public let kind: PrimeValidationDriverV2TrackedTreeHeldKind
    public let openedIdentity:
        PrimeValidationDriverV2TrackedTreeHeldIdentity
    public let postReadDescriptorIdentity:
        PrimeValidationDriverV2TrackedTreeHeldIdentity
    public let namedPathReboundIdentity:
        PrimeValidationDriverV2TrackedTreeHeldIdentity
    public let contents: Data
    public let byteCount: UInt64
    public let sha256: String
    public let gitBlobSHA1: String

    /// Internal construction seam for a future descriptor holder and focused
    /// `@testable` mechanics tests. Callers cannot supply either digest.
    init(
        validatingRawPathBytes rawPathBytes: Data,
        kind: PrimeValidationDriverV2TrackedTreeHeldKind,
        openedIdentity:
            PrimeValidationDriverV2TrackedTreeHeldIdentity,
        postReadDescriptorIdentity:
            PrimeValidationDriverV2TrackedTreeHeldIdentity,
        namedPathReboundIdentity:
            PrimeValidationDriverV2TrackedTreeHeldIdentity,
        contents: Data
    ) throws {
        let rawPathComponents = try Self.validateRawPath(rawPathBytes)
        guard openedIdentity == postReadDescriptorIdentity,
              openedIdentity == namedPathReboundIdentity
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("identity_join")
        }
        guard openedIdentity.inode > 0,
              openedIdentity.permissionMode & ~UInt16(0o7777) == 0,
              openedIdentity.linkCount == 1,
              openedIdentity.byteCount == UInt64(contents.count)
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("held_metadata")
        }
        switch (kind, openedIdentity.posixFileType) {
        case (.regularFile, .regularFile):
            break
        case (.symbolicLink, .symbolicLink):
            try Self.validateSymbolicLinkTarget(
                contents,
                linkPathComponents: rawPathComponents
            )
        default:
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("held_kind")
        }

        self.rawPathBytes = rawPathBytes
        self.kind = kind
        self.openedIdentity = openedIdentity
        self.postReadDescriptorIdentity = postReadDescriptorIdentity
        self.namedPathReboundIdentity = namedPathReboundIdentity
        self.contents = contents
        byteCount = UInt64(contents.count)
        sha256 = PrimeSHA256.hexDigest(of: contents)
        gitBlobSHA1 = Self.gitBlobSHA1(contents)
    }

    private static func validateRawPath(_ path: Data) throws -> [Data] {
        guard !path.isEmpty,
              path.count <= 1_023,
              path.first != 0x2f,
              path.last != 0x2f,
              !path.contains(0)
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("raw_path")
        }
        let components = path.split(
            separator: 0x2f,
            omittingEmptySubsequences: false
        ).map { Data($0) }
        let dot = Data([0x2e])
        let dotDot = Data([0x2e, 0x2e])
        guard !components.isEmpty,
              components.count <= 32,
              components.allSatisfy({
                  !$0.isEmpty
                    && $0.count <= 255
                    && $0 != dot
                    && $0 != dotDot
              }),
              components.first != Data([0x2e, 0x67, 0x69, 0x74])
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("raw_path")
        }
        return components
    }

    private static func validateSymbolicLinkTarget(
        _ target: Data,
        linkPathComponents: [Data]
    ) throws {
        guard !target.isEmpty,
              target.count <= 1_023,
              target.first != 0x2f,
              target.last != 0x2f,
              !target.contains(0)
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("symbolic_link_target")
        }
        let targetComponents = target.split(
            separator: 0x2f,
            omittingEmptySubsequences: false
        ).map { Data($0) }
        let dot = Data([0x2e])
        let dotDot = Data([0x2e, 0x2e])
        guard !targetComponents.isEmpty,
              targetComponents.count <= 32,
              targetComponents.allSatisfy({
                  !$0.isEmpty && $0.count <= 255 && $0 != dot
              })
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("symbolic_link_target")
        }

        var resolved = Array(linkPathComponents.dropLast())
        for component in targetComponents {
            if component == dotDot {
                guard !resolved.isEmpty else {
                    throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                        .rejected("symbolic_link_target_outside_root")
                }
                resolved.removeLast()
            } else {
                resolved.append(component)
            }
            guard resolved.count <= 32 else {
                throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                    .rejected("symbolic_link_target")
            }
        }
        let resolvedByteCount = resolved.reduce(0) {
            $0 + $1.count
        } + max(0, resolved.count - 1)
        guard !resolved.isEmpty,
              resolvedByteCount <= 1_023,
              resolved.first != Data([0x2e, 0x67, 0x69, 0x74])
        else {
            throw PrimeValidationDriverV2TrackedTreeHeldEntryError
                .rejected("symbolic_link_target_git")
        }
    }

    private static func gitBlobSHA1(_ contents: Data) -> String {
        var framed = Data("blob \(contents.count)\u{0}".utf8)
        framed.append(contents)
        let hexadecimal = Array("0123456789abcdef".utf8)
        var encoded = [UInt8]()
        encoded.reserveCapacity(40)
        for byte in Insecure.SHA1.hash(data: framed) {
            encoded.append(hexadecimal[Int(byte >> 4)])
            encoded.append(hexadecimal[Int(byte & 0x0f)])
        }
        return String(decoding: encoded, as: UTF8.self)
    }
}

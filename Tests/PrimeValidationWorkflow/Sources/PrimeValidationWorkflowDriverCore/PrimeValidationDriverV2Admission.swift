// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
#if canImport(PrimeValidationWorkflowRootContracts)
import PrimeValidationWorkflowRootContracts
#else
import PrimeValidationWorkflowContracts
#endif

/// Durable admission declarations are mechanics-only. They can bind what a
/// later closed OS capability observed, but decoded bytes never become process
/// execution, build, inventory, resume, or shard-completion authority.
public enum PrimeValidationAdmissionDirectoryRoleV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case repository
    case companion
    case workspace
    case evidence
    case workspaceSubdirectory = "workspace_subdirectory"
    case evidenceRunDirectory = "evidence_run_directory"
    case developerDirectory = "developer_directory"
    case sdkRoot = "sdk_root"

    fileprivate var requiresPrivateMode: Bool {
        switch self {
        case .workspace, .evidence, .workspaceSubdirectory,
             .evidenceRunDirectory:
            true
        case .repository, .companion, .developerDirectory, .sdkRoot:
            false
        }
    }
}

public struct PrimeValidationCanonicalDirectoryObservationV2:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeValidationAdmissionDirectoryRoleV2
    public let requestedAbsolutePath: String
    public let canonicalAbsolutePath: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let mode: UInt16
    public let linkCount: UInt64
    public let filesystemType: String
    public let filesystemIDWord0: UInt32
    public let filesystemIDWord1: UInt32
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds: Int64
    public let statusChangeTimeSeconds: Int64
    public let statusChangeTimeNanoseconds: Int64
    public let localFilesystemObserved: Bool
    public let descriptorJoined: Bool
    public let pathIdentityJoined: Bool
    public let noSymlinkComponentsObserved: Bool

    public init(
        role: PrimeValidationAdmissionDirectoryRoleV2,
        requestedAbsolutePath: String,
        canonicalAbsolutePath: String,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        mode: UInt16,
        linkCount: UInt64,
        filesystemType: String,
        filesystemIDWord0: UInt32,
        filesystemIDWord1: UInt32,
        modificationTimeSeconds: Int64,
        modificationTimeNanoseconds: Int64,
        statusChangeTimeSeconds: Int64,
        statusChangeTimeNanoseconds: Int64,
        localFilesystemObserved: Bool,
        descriptorJoined: Bool,
        pathIdentityJoined: Bool,
        noSymlinkComponentsObserved: Bool
    ) {
        self.role = role
        self.requestedAbsolutePath = requestedAbsolutePath
        self.canonicalAbsolutePath = canonicalAbsolutePath
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.mode = mode
        self.linkCount = linkCount
        self.filesystemType = filesystemType
        self.filesystemIDWord0 = filesystemIDWord0
        self.filesystemIDWord1 = filesystemIDWord1
        self.modificationTimeSeconds = modificationTimeSeconds
        self.modificationTimeNanoseconds = modificationTimeNanoseconds
        self.statusChangeTimeSeconds = statusChangeTimeSeconds
        self.statusChangeTimeNanoseconds = statusChangeTimeNanoseconds
        self.localFilesystemObserved = localFilesystemObserved
        self.descriptorJoined = descriptorJoined
        self.pathIdentityJoined = pathIdentityJoined
        self.noSymlinkComponentsObserved = noSymlinkComponentsObserved
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            requestedAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            canonicalAbsolutePath
        )
        let permitsRootOwner = role == .developerDirectory
            || role == .sdkRoot
        guard requestedAbsolutePath == canonicalAbsolutePath,
              deviceID > 0,
              inode > 0,
              permitsRootOwner || ownerUserID > 0,
              mode > 0,
              mode <= 0o777,
              linkCount > 0,
              filesystemType == "apfs",
              filesystemIDWord0 != 0 || filesystemIDWord1 != 0,
              modificationTimeSeconds >= 0,
              modificationTimeNanoseconds >= 0,
              modificationTimeNanoseconds < 1_000_000_000,
              statusChangeTimeSeconds >= 0,
              statusChangeTimeNanoseconds >= 0,
              statusChangeTimeNanoseconds < 1_000_000_000,
              localFilesystemObserved,
              descriptorJoined,
              pathIdentityJoined,
              noSymlinkComponentsObserved,
              mode & 0o500 == 0o500,
              (role.requiresPrivateMode
                ? mode == 0o700 : mode & 0o022 == 0)
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                canonicalAbsolutePath
            )
        }
    }

    fileprivate var identityKey: String {
        String(deviceID) + ":" + String(inode)
    }
}

public struct PrimeValidationHeldExecutableObservationV2:
    Codable,
    Equatable,
    Sendable
{
    public let requestedAbsolutePath: String
    public let canonicalAbsolutePath: String
    public let requestedSymlinkTarget: String?
    public let content: PrimeValidationContentBinding
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let mode: UInt16
    public let linkCount: UInt64
    public let fileByteCount: UInt64
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds: Int64
    public let statusChangeTimeSeconds: Int64
    public let statusChangeTimeNanoseconds: Int64
    public let mappedExecutableAbsolutePath: String
    public let descriptorJoined: Bool
    public let pathIdentityJoined: Bool
    public let mappedExecutableJoined: Bool

    public init(
        requestedAbsolutePath: String,
        canonicalAbsolutePath: String,
        requestedSymlinkTarget: String?,
        content: PrimeValidationContentBinding,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        mode: UInt16,
        linkCount: UInt64,
        fileByteCount: UInt64,
        modificationTimeSeconds: Int64,
        modificationTimeNanoseconds: Int64,
        statusChangeTimeSeconds: Int64,
        statusChangeTimeNanoseconds: Int64,
        mappedExecutableAbsolutePath: String,
        descriptorJoined: Bool,
        pathIdentityJoined: Bool,
        mappedExecutableJoined: Bool
    ) {
        self.requestedAbsolutePath = requestedAbsolutePath
        self.canonicalAbsolutePath = canonicalAbsolutePath
        self.requestedSymlinkTarget = requestedSymlinkTarget
        self.content = content
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.mode = mode
        self.linkCount = linkCount
        self.fileByteCount = fileByteCount
        self.modificationTimeSeconds = modificationTimeSeconds
        self.modificationTimeNanoseconds = modificationTimeNanoseconds
        self.statusChangeTimeSeconds = statusChangeTimeSeconds
        self.statusChangeTimeNanoseconds = statusChangeTimeNanoseconds
        self.mappedExecutableAbsolutePath = mappedExecutableAbsolutePath
        self.descriptorJoined = descriptorJoined
        self.pathIdentityJoined = pathIdentityJoined
        self.mappedExecutableJoined = mappedExecutableJoined
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            requestedAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            canonicalAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            mappedExecutableAbsolutePath
        )
        if requestedAbsolutePath == canonicalAbsolutePath {
            guard requestedSymlinkTarget == nil else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    requestedAbsolutePath
                )
            }
        } else {
            guard let requestedSymlinkTarget else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    requestedAbsolutePath
                )
            }
            try PrimeValidationDriverV2Validation.requireSafeRelativePath(
                requestedSymlinkTarget
            )
        }
        try content.validate()
        guard content.byteCount > 0,
              deviceID > 0,
              inode > 0,
              mode > 0,
              mode <= 0o777,
              mode & 0o111 != 0,
              mode & 0o022 == 0,
              linkCount == 1,
              fileByteCount == content.byteCount,
              modificationTimeSeconds >= 0,
              modificationTimeNanoseconds >= 0,
              modificationTimeNanoseconds < 1_000_000_000,
              statusChangeTimeSeconds >= 0,
              statusChangeTimeNanoseconds >= 0,
              statusChangeTimeNanoseconds < 1_000_000_000,
              mappedExecutableAbsolutePath == canonicalAbsolutePath,
              descriptorJoined,
              pathIdentityJoined,
              mappedExecutableJoined
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                requestedAbsolutePath
            )
        }
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public enum PrimeValidationAdmissionRegularFileRoleV2:
    String,
    Codable,
    Sendable
{
    case packageLock = "package_lock"
}

public struct PrimeValidationHeldRegularFileObservationV2:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeValidationAdmissionRegularFileRoleV2
    public let absolutePath: String
    public let content: PrimeValidationContentBinding
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let mode: UInt16
    public let linkCount: UInt64
    public let fileByteCount: UInt64
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds: Int64
    public let statusChangeTimeSeconds: Int64
    public let statusChangeTimeNanoseconds: Int64
    public let descriptorJoined: Bool
    public let pathIdentityJoined: Bool
    public let noSymlinkComponentsObserved: Bool
    public let retainedDescriptorClosureHeld: Bool

    public init(
        role: PrimeValidationAdmissionRegularFileRoleV2,
        absolutePath: String,
        content: PrimeValidationContentBinding,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        mode: UInt16,
        linkCount: UInt64,
        fileByteCount: UInt64,
        modificationTimeSeconds: Int64,
        modificationTimeNanoseconds: Int64,
        statusChangeTimeSeconds: Int64,
        statusChangeTimeNanoseconds: Int64,
        descriptorJoined: Bool,
        pathIdentityJoined: Bool,
        noSymlinkComponentsObserved: Bool,
        retainedDescriptorClosureHeld: Bool
    ) {
        self.role = role
        self.absolutePath = absolutePath
        self.content = content
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.mode = mode
        self.linkCount = linkCount
        self.fileByteCount = fileByteCount
        self.modificationTimeSeconds = modificationTimeSeconds
        self.modificationTimeNanoseconds = modificationTimeNanoseconds
        self.statusChangeTimeSeconds = statusChangeTimeSeconds
        self.statusChangeTimeNanoseconds = statusChangeTimeNanoseconds
        self.descriptorJoined = descriptorJoined
        self.pathIdentityJoined = pathIdentityJoined
        self.noSymlinkComponentsObserved = noSymlinkComponentsObserved
        self.retainedDescriptorClosureHeld = retainedDescriptorClosureHeld
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            absolutePath
        )
        try content.validate()
        guard content.byteCount > 0,
              deviceID > 0,
              inode > 0,
              mode > 0,
              mode <= 0o777,
              mode & 0o111 == 0,
              mode & 0o022 == 0,
              linkCount == 1,
              fileByteCount == content.byteCount,
              modificationTimeSeconds >= 0,
              modificationTimeNanoseconds >= 0,
              modificationTimeNanoseconds < 1_000_000_000,
              statusChangeTimeSeconds >= 0,
              statusChangeTimeNanoseconds >= 0,
              statusChangeTimeNanoseconds < 1_000_000_000,
              descriptorJoined,
              pathIdentityJoined,
              noSymlinkComponentsObserved,
              retainedDescriptorClosureHeld
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(absolutePath)
        }
    }
}

public struct PrimeValidationAdmissionBoundDataV2:
    Codable,
    Equatable,
    Sendable
{
    public let artifact: PrimeValidationDriverArtifactBindingV2
    public let data: Data

    public init(
        name: String,
        relativePath: String,
        data: Data
    ) {
        artifact = .init(
            name: name,
            relativePath: relativePath,
            content: .init(data: data)
        )
        self.data = data
    }

    public init(
        artifact: PrimeValidationDriverArtifactBindingV2,
        data: Data
    ) {
        self.artifact = artifact
        self.data = data
    }

    public func validate(
        permitsEmpty: Bool = false,
        maximumByteCount: Int = 16 * 1024 * 1024
    ) throws {
        guard data.count <= maximumByteCount,
              permitsEmpty || !data.isEmpty,
              artifact.content == PrimeValidationContentBinding(data: data)
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                artifact.name
            )
        }
        try artifact.validate(permitsEmpty: permitsEmpty)
    }
}

public struct PrimeValidationSwiftTargetInfoObservationV2:
    Codable,
    Equatable,
    Sendable
{
    public let compilerVersion: String
    public let swiftCompilerTag: String
    public let triple: String
    public let unversionedTriple: String
    public let moduleTriple: String
    public let platform: String
    public let architecture: String
    public let pointerWidthInBits: Int
    public let runtimeLibraryPaths: [String]
    public let runtimeLibraryImportPaths: [String]
    public let runtimeResourcePath: String

    public init(
        compilerVersion: String,
        swiftCompilerTag: String,
        triple: String,
        unversionedTriple: String,
        moduleTriple: String,
        platform: String,
        architecture: String,
        pointerWidthInBits: Int,
        runtimeLibraryPaths: [String],
        runtimeLibraryImportPaths: [String],
        runtimeResourcePath: String
    ) {
        self.compilerVersion = compilerVersion
        self.swiftCompilerTag = swiftCompilerTag
        self.triple = triple
        self.unversionedTriple = unversionedTriple
        self.moduleTriple = moduleTriple
        self.platform = platform
        self.architecture = architecture
        self.pointerWidthInBits = pointerWidthInBits
        self.runtimeLibraryPaths = runtimeLibraryPaths
        self.runtimeLibraryImportPaths = runtimeLibraryImportPaths
        self.runtimeResourcePath = runtimeResourcePath
    }

    fileprivate static func parse(_ data: Data) throws -> Self {
        struct Target: Decodable {
            let triple: String
            let unversionedTriple: String
            let moduleTriple: String
            let platform: String
            let arch: String
            let pointerWidthInBits: Int
        }
        struct Paths: Decodable {
            let runtimeLibraryPaths: [String]
            let runtimeLibraryImportPaths: [String]
            let runtimeResourcePath: String
        }
        struct Raw: Decodable {
            let compilerVersion: String
            let swiftCompilerTag: String
            let target: Target
            let paths: Paths
        }
        let raw: Raw
        do {
            raw = try JSONDecoder().decode(Raw.self, from: data)
        } catch {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "swift_target_info"
            )
        }
        return Self(
            compilerVersion: raw.compilerVersion,
            swiftCompilerTag: raw.swiftCompilerTag,
            triple: raw.target.triple,
            unversionedTriple: raw.target.unversionedTriple,
            moduleTriple: raw.target.moduleTriple,
            platform: raw.target.platform,
            architecture: raw.target.arch,
            pointerWidthInBits: raw.target.pointerWidthInBits,
            runtimeLibraryPaths: raw.paths.runtimeLibraryPaths,
            runtimeLibraryImportPaths: raw.paths.runtimeLibraryImportPaths,
            runtimeResourcePath: raw.paths.runtimeResourcePath
        )
    }

    public func validate(
        developerDirectoryAbsolutePath: String
    ) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            developerDirectoryAbsolutePath
        )
        let admittedRuntimeResourcePath =
            developerDirectoryAbsolutePath
            + "/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift"
        let admittedMacOSRuntimePath =
            admittedRuntimeResourcePath + "/macosx"
        guard compilerVersion
                == "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
              swiftCompilerTag == "swiftlang-6.3.3.1.3",
              triple == "arm64-apple-macosx26.0",
              unversionedTriple == "arm64-apple-macosx",
              moduleTriple == "arm64-apple-macos",
              platform == "macosx",
              architecture == "arm64",
              pointerWidthInBits == 64,
              runtimeResourcePath == admittedRuntimeResourcePath,
              runtimeLibraryPaths == [
                admittedMacOSRuntimePath,
                "/usr/lib/swift",
              ],
              runtimeLibraryImportPaths == [admittedMacOSRuntimePath]
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "swift_target_info"
            )
        }
        try (runtimeLibraryPaths + runtimeLibraryImportPaths + [
            runtimeResourcePath,
        ]).forEach {
            try PrimeValidationDriverV2Validation.requireSafeAbsolutePath($0)
        }
    }
}

public enum PrimeValidationSwiftPackagePersonalityRoleV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case build
    case test

    fileprivate var executableLeaf: String {
        switch self {
        case .build: "swift-build"
        case .test: "swift-test"
        }
    }
}

/// Descriptor-independent declaration of one frozen SwiftPM argv[0]
/// personality. A later closed capture must derive these fields from lstat,
/// readlink, and the held physical `swift-package` executable; this mechanics
/// type does not authorize a spawn.
public struct PrimeValidationSwiftPackagePersonalityV2:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeValidationSwiftPackagePersonalityRoleV2
    public let requestedAbsolutePath: String
    public let requestedSymlinkTarget: String
    public let symlinkDeviceID: UInt64
    public let symlinkInode: UInt64
    public let symlinkOwnerUserID: UInt32
    public let symlinkOwnerGroupID: UInt32
    public let symlinkMode: UInt16
    public let symlinkLinkCount: UInt64
    public let resolvedExecutableAbsolutePath: String
    public let argumentZero: String
    public let noFollowMetadataObserved: Bool
    public let readlinkTargetObserved: Bool
    public let resolvedExecutableJoined: Bool

    public init(
        role: PrimeValidationSwiftPackagePersonalityRoleV2,
        requestedAbsolutePath: String,
        requestedSymlinkTarget: String,
        symlinkDeviceID: UInt64,
        symlinkInode: UInt64,
        symlinkOwnerUserID: UInt32,
        symlinkOwnerGroupID: UInt32,
        symlinkMode: UInt16,
        symlinkLinkCount: UInt64,
        resolvedExecutableAbsolutePath: String,
        argumentZero: String,
        noFollowMetadataObserved: Bool,
        readlinkTargetObserved: Bool,
        resolvedExecutableJoined: Bool
    ) {
        self.role = role
        self.requestedAbsolutePath = requestedAbsolutePath
        self.requestedSymlinkTarget = requestedSymlinkTarget
        self.symlinkDeviceID = symlinkDeviceID
        self.symlinkInode = symlinkInode
        self.symlinkOwnerUserID = symlinkOwnerUserID
        self.symlinkOwnerGroupID = symlinkOwnerGroupID
        self.symlinkMode = symlinkMode
        self.symlinkLinkCount = symlinkLinkCount
        self.resolvedExecutableAbsolutePath = resolvedExecutableAbsolutePath
        self.argumentZero = argumentZero
        self.noFollowMetadataObserved = noFollowMetadataObserved
        self.readlinkTargetObserved = readlinkTargetObserved
        self.resolvedExecutableJoined = resolvedExecutableJoined
    }

    public func validate(
        physicalSwiftPackage:
            PrimeValidationHeldExecutableObservationV2
    ) throws {
        try physicalSwiftPackage.validate()
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            requestedAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            resolvedExecutableAbsolutePath
        )
        let physicalPrefix = String(
            physicalSwiftPackage.canonicalAbsolutePath
                .dropLast("swift-package".count)
        )
        guard requestedAbsolutePath
                == physicalPrefix + role.executableLeaf,
              requestedSymlinkTarget == "swift-package",
              symlinkDeviceID == physicalSwiftPackage.deviceID,
              symlinkInode > 0,
              symlinkOwnerUserID == 0,
              symlinkOwnerGroupID == 0,
              symlinkMode == 0o777,
              symlinkLinkCount > 0,
              resolvedExecutableAbsolutePath
                == physicalSwiftPackage.canonicalAbsolutePath,
              argumentZero == role.executableLeaf,
              noFollowMetadataObserved,
              readlinkTargetObserved,
              resolvedExecutableJoined
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                role.executableLeaf
            )
        }
    }
}

public struct PrimeValidationToolchainAdmissionReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    package static let admittedCanonicalDeveloperDirectories: Set<String> = [
        "/Applications/Xcode.app/Contents/Developer",
        "/Applications/Xcode_26.6.app/Contents/Developer",
    ]

    public let developerDirectory:
        PrimeValidationCanonicalDirectoryObservationV2
    public let sdkRoot: PrimeValidationCanonicalDirectoryObservationV2
    public let swiftExecutable: PrimeValidationHeldExecutableObservationV2
    public let swiftCompilerExecutable:
        PrimeValidationHeldExecutableObservationV2
    public let swiftPackageExecutable:
        PrimeValidationHeldExecutableObservationV2
    public let swiftPackagePersonalities:
        [PrimeValidationSwiftPackagePersonalityV2]
    public let xcodeVersionOutput: PrimeValidationAdmissionBoundDataV2
    public let sdkPathOutput: PrimeValidationAdmissionBoundDataV2
    public let sdkVersionOutput: PrimeValidationAdmissionBoundDataV2
    public let swiftVersionOutput: PrimeValidationAdmissionBoundDataV2
    public let swiftTargetInfoOutput: PrimeValidationAdmissionBoundDataV2
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let sdkVersion: String
    public let swiftDriverVersion: String
    public let targetInfo: PrimeValidationSwiftTargetInfoObservationV2
    public let orderedProbeEnvironment: [PrimeValidationEnvironmentEntry]

    public init(
        developerDirectory:
            PrimeValidationCanonicalDirectoryObservationV2,
        sdkRoot: PrimeValidationCanonicalDirectoryObservationV2,
        swiftExecutable: PrimeValidationHeldExecutableObservationV2,
        swiftCompilerExecutable:
            PrimeValidationHeldExecutableObservationV2,
        swiftPackageExecutable:
            PrimeValidationHeldExecutableObservationV2,
        swiftPackagePersonalities:
            [PrimeValidationSwiftPackagePersonalityV2],
        xcodeVersionOutput: PrimeValidationAdmissionBoundDataV2,
        sdkPathOutput: PrimeValidationAdmissionBoundDataV2,
        sdkVersionOutput: PrimeValidationAdmissionBoundDataV2,
        swiftVersionOutput: PrimeValidationAdmissionBoundDataV2,
        swiftTargetInfoOutput: PrimeValidationAdmissionBoundDataV2,
        xcodeVersion: String,
        xcodeBuildVersion: String,
        sdkVersion: String,
        swiftDriverVersion: String,
        targetInfo: PrimeValidationSwiftTargetInfoObservationV2,
        orderedProbeEnvironment: [PrimeValidationEnvironmentEntry]
    ) {
        self.developerDirectory = developerDirectory
        self.sdkRoot = sdkRoot
        self.swiftExecutable = swiftExecutable
        self.swiftCompilerExecutable = swiftCompilerExecutable
        self.swiftPackageExecutable = swiftPackageExecutable
        self.swiftPackagePersonalities = swiftPackagePersonalities
        self.xcodeVersionOutput = xcodeVersionOutput
        self.sdkPathOutput = sdkPathOutput
        self.sdkVersionOutput = sdkVersionOutput
        self.swiftVersionOutput = swiftVersionOutput
        self.swiftTargetInfoOutput = swiftTargetInfoOutput
        self.xcodeVersion = xcodeVersion
        self.xcodeBuildVersion = xcodeBuildVersion
        self.sdkVersion = sdkVersion
        self.swiftDriverVersion = swiftDriverVersion
        self.targetInfo = targetInfo
        self.orderedProbeEnvironment = orderedProbeEnvironment
    }

    public static func probeEnvironment(
        developerDirectory: String,
        sdkRoot: String
    ) -> [PrimeValidationEnvironmentEntry] {
        [
            .init(key: "DEVELOPER_DIR", value: developerDirectory),
            .init(key: "LANG", value: "C"),
            .init(key: "LC_ALL", value: "C"),
            .init(key: "SDKROOT", value: sdkRoot),
            .init(key: "TERM", value: "dumb"),
        ]
    }

    public func validate() throws {
        guard developerDirectory.role == .developerDirectory,
              sdkRoot.role == .sdkRoot
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("toolchain")
        }
        try developerDirectory.validate()
        try sdkRoot.validate()
        try swiftExecutable.validate()
        try swiftCompilerExecutable.validate()
        try swiftPackageExecutable.validate()
        try xcodeVersionOutput.validate(maximumByteCount: 4_096)
        try sdkPathOutput.validate(maximumByteCount: 16 * 1024)
        try sdkVersionOutput.validate(maximumByteCount: 4_096)
        try swiftVersionOutput.validate(maximumByteCount: 16 * 1024)
        try swiftTargetInfoOutput.validate(maximumByteCount: 64 * 1024)
        try targetInfo.validate(
            developerDirectoryAbsolutePath:
                developerDirectory.canonicalAbsolutePath
        )
        let parsedTarget = try PrimeValidationSwiftTargetInfoObservationV2
            .parse(swiftTargetInfoOutput.data)
        let expectedXcode = Data(
            "Xcode \(xcodeVersion)\nBuild version \(xcodeBuildVersion)\n".utf8
        )
        let expectedSDKPathOutput = Data(
            (sdkRoot.canonicalAbsolutePath + "\n").utf8
        )
        let expectedSDKVersion = Data((sdkVersion + "\n").utf8)
        let expectedSwiftVersion = Data(
            (
                "swift-driver version: \(swiftDriverVersion) "
                    + targetInfo.compilerVersion
                    + "\nTarget: \(targetInfo.triple)\n"
            ).utf8
        )
        let developerPath = developerDirectory.canonicalAbsolutePath
        let toolchainBinaryPath = developerPath
            + "/Toolchains/XcodeDefault.xctoolchain/usr/bin"
        let expectedFrontendPath = toolchainBinaryPath + "/swift-frontend"
        let expectedSDKPath = developerPath
            + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        guard xcodeVersion == "26.6",
              xcodeBuildVersion == "17F113",
              sdkVersion == "26.5",
              swiftDriverVersion == "1.148.6",
              Self.admittedCanonicalDeveloperDirectories.contains(
                  developerPath
              ),
              developerDirectory.ownerUserID == 0,
              developerDirectory.ownerGroupID == 0,
              sdkRoot.canonicalAbsolutePath == expectedSDKPath,
              sdkRoot.ownerUserID == 0,
              sdkRoot.ownerGroupID == 0,
              sdkRoot.deviceID == developerDirectory.deviceID,
              xcodeVersionOutput.artifact.name == "xcode_version",
              sdkPathOutput.artifact.name == "sdk_path",
              sdkVersionOutput.artifact.name == "sdk_version",
              swiftVersionOutput.artifact.name == "swift_version",
              swiftTargetInfoOutput.artifact.name == "swift_target_info",
              xcodeVersionOutput.data == expectedXcode,
              sdkPathOutput.data == expectedSDKPathOutput,
              sdkVersionOutput.data == expectedSDKVersion,
              swiftVersionOutput.data == expectedSwiftVersion,
              parsedTarget == targetInfo,
              swiftExecutable.content == swiftCompilerExecutable.content,
              swiftExecutable.deviceID == swiftCompilerExecutable.deviceID,
              swiftExecutable.inode == swiftCompilerExecutable.inode,
              swiftExecutable.requestedAbsolutePath
                == toolchainBinaryPath + "/swift",
              swiftCompilerExecutable.requestedAbsolutePath
                == toolchainBinaryPath + "/swiftc",
              swiftExecutable.canonicalAbsolutePath == expectedFrontendPath,
              swiftCompilerExecutable.canonicalAbsolutePath
                == expectedFrontendPath,
              swiftExecutable.requestedSymlinkTarget == "swift-frontend",
              swiftCompilerExecutable.requestedSymlinkTarget
                == "swift-frontend",
              swiftExecutable.ownerUserID == 0,
              swiftExecutable.ownerGroupID == 0,
              swiftCompilerExecutable.ownerUserID == 0,
              swiftCompilerExecutable.ownerGroupID == 0,
              swiftExecutable.deviceID == developerDirectory.deviceID,
              swiftPackageExecutable.requestedAbsolutePath
                == swiftPackageExecutable.canonicalAbsolutePath,
              swiftPackageExecutable.requestedSymlinkTarget == nil,
              swiftPackageExecutable.requestedAbsolutePath
                == toolchainBinaryPath + "/swift-package",
              swiftPackageExecutable.ownerUserID == 0,
              swiftPackageExecutable.ownerGroupID == 0,
              swiftPackageExecutable.deviceID
                == developerDirectory.deviceID,
              swiftPackagePersonalities.map(\.role)
                == PrimeValidationSwiftPackagePersonalityRoleV2.allCases,
              Set(swiftPackagePersonalities.map(\.requestedAbsolutePath)).count
                == swiftPackagePersonalities.count,
              Set(swiftPackagePersonalities.map(\.symlinkInode)).count
                == swiftPackagePersonalities.count,
              orderedProbeEnvironment == Self.probeEnvironment(
                developerDirectory: developerDirectory.canonicalAbsolutePath,
                sdkRoot: sdkRoot.canonicalAbsolutePath
              )
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("toolchain")
        }
        try swiftPackagePersonalities.forEach {
            try $0.validate(physicalSwiftPackage: swiftPackageExecutable)
        }
        try orderedProbeEnvironment.forEach { try $0.validate() }
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

/// Exact non-executing transformation from the merged logical Swift
/// invocations to the direct physical `swift-package` personalities. Shards
/// are intentionally absent.
public struct PrimeValidationSwiftPackageAdmissionLaunchV2:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeValidationInvocationRoleV2
    public let logicalInvocation: PrimeValidationInvocationV2
    public let physicalExecutable: PrimeValidationExecutableBindingV2
    public let argumentZero: String
    public let physicalArguments: [String]
    public let orderedCompleteReplacementEnvironment:
        [PrimeValidationEnvironmentEntry]
    public let physicalWorkingDirectoryAbsolutePath: String

    public init(
        role: PrimeValidationInvocationRoleV2,
        logicalInvocation: PrimeValidationInvocationV2,
        physicalExecutable: PrimeValidationExecutableBindingV2,
        argumentZero: String,
        physicalArguments: [String],
        orderedCompleteReplacementEnvironment:
            [PrimeValidationEnvironmentEntry],
        physicalWorkingDirectoryAbsolutePath: String
    ) {
        self.role = role
        self.logicalInvocation = logicalInvocation
        self.physicalExecutable = physicalExecutable
        self.argumentZero = argumentZero
        self.physicalArguments = physicalArguments
        self.orderedCompleteReplacementEnvironment =
            orderedCompleteReplacementEnvironment
        self.physicalWorkingDirectoryAbsolutePath =
            physicalWorkingDirectoryAbsolutePath
    }

    public func validate(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) throws {
        try intent.validate()
        try toolchain.validate()
        let expectedLogical: PrimeValidationInvocationV2
        let personalityRole: PrimeValidationSwiftPackagePersonalityRoleV2
        let logicalLeadingSubcommand: String
        switch role {
        case .build:
            expectedLogical = try PrimeValidationInvocationFactoryV2.build(
                intent: intent
            )
            personalityRole = .build
            logicalLeadingSubcommand = "build"
        case .listXCTest:
            expectedLogical = try PrimeValidationInvocationFactoryV2
                .inventory(intent: intent)[0]
            personalityRole = .test
            logicalLeadingSubcommand = "test"
        case .listSwiftTesting:
            expectedLogical = try PrimeValidationInvocationFactoryV2
                .inventory(intent: intent)[1]
            personalityRole = .test
            logicalLeadingSubcommand = "test"
        case .shard:
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        let expectedEnvironment = try
            PrimeValidationSwiftPackageAdmissionLaunchPlanV2
            .completeReplacementEnvironment(
                intent: intent,
                toolchain: toolchain
            )
        guard let personality = toolchain.swiftPackagePersonalities
                .first(where: { $0.role == personalityRole }),
              logicalInvocation == expectedLogical,
              logicalInvocation.role == role,
              logicalInvocation.arguments.first == logicalLeadingSubcommand,
              physicalExecutable.absolutePath
                == toolchain.swiftPackageExecutable.canonicalAbsolutePath,
              physicalExecutable.content
                == toolchain.swiftPackageExecutable.content,
              argumentZero == personality.argumentZero,
              physicalArguments
                == Array(logicalInvocation.arguments.dropFirst()),
              orderedCompleteReplacementEnvironment
                == expectedEnvironment,
              physicalWorkingDirectoryAbsolutePath
                == intent.roots.repositoryRoot.absolutePath,
              logicalInvocation.orderedEnvironment
                == expectedLogical.orderedEnvironment,
              logicalInvocation.workingDirectoryAbsolutePath
                == intent.roots.repositoryRoot.absolutePath
        else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try logicalInvocation.validate()
        try physicalExecutable.validate()
        try orderedCompleteReplacementEnvironment.forEach {
            try $0.validate()
        }
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            physicalWorkingDirectoryAbsolutePath
        )
    }
}

public struct PrimeValidationSwiftPackageAdmissionLaunchPlanV2:
    Codable,
    Equatable,
    Sendable
{
    public let launches: [PrimeValidationSwiftPackageAdmissionLaunchV2]

    public init(
        launches: [PrimeValidationSwiftPackageAdmissionLaunchV2]
    ) {
        self.launches = launches
    }

    public static func make(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) throws -> Self {
        try intent.validate()
        try toolchain.validate()
        let logical = [
            try PrimeValidationInvocationFactoryV2.build(intent: intent),
        ] + (try PrimeValidationInvocationFactoryV2.inventory(intent: intent))
        let physical = PrimeValidationExecutableBindingV2(
            absolutePath:
                toolchain.swiftPackageExecutable.canonicalAbsolutePath,
            content: toolchain.swiftPackageExecutable.content
        )
        return Self(
            launches: try logical.map { invocation in
                let personalityRole:
                    PrimeValidationSwiftPackagePersonalityRoleV2 =
                    invocation.role == .build ? .build : .test
                guard let personality = toolchain.swiftPackagePersonalities
                        .first(where: { $0.role == personalityRole })
                else {
                    throw PrimeValidationDriverV2Error.invalidExecutionPlan
                }
                return .init(
                    role: invocation.role,
                    logicalInvocation: invocation,
                    physicalExecutable: physical,
                    argumentZero: personality.argumentZero,
                    physicalArguments: Array(invocation.arguments.dropFirst()),
                    orderedCompleteReplacementEnvironment:
                        try completeReplacementEnvironment(
                            intent: intent,
                            toolchain: toolchain
                        ),
                    physicalWorkingDirectoryAbsolutePath:
                        intent.roots.repositoryRoot.absolutePath
                )
            }
        )
    }

    public func validate(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) throws {
        let expected = try Self.make(intent: intent, toolchain: toolchain)
        guard launches.map(\.role) == [
            .build,
            .listXCTest,
            .listSwiftTesting,
        ],
        launches == expected.launches
        else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        try launches.forEach {
            try $0.validate(intent: intent, toolchain: toolchain)
        }
    }

    fileprivate static func completeReplacementEnvironment(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) throws -> [PrimeValidationEnvironmentEntry] {
        try intent.validate()
        try toolchain.validate()
        let inputs = deterministicExecutionBaseEnvironment(
            intent: intent,
            toolchain: toolchain
        ) + intent.environmentPolicy.orderedEntries
        var byKey: [String: PrimeValidationEnvironmentEntry] = [:]
        for entry in inputs {
            try entry.validate()
            if let existing = byKey[entry.key] {
                guard existing == entry else {
                    throw PrimeValidationDriverV2Error
                        .invalidExecutionPlan
                }
            } else {
                byKey[entry.key] = entry
            }
        }
        let ordered = byKey.values.sorted { $0.key < $1.key }
        let expectedKeys = [
            "CFFIXED_USER_HOME",
            "CLANG_MODULE_CACHE_PATH",
            "DEVELOPER_DIR",
            "HOME",
            "LANG",
            "LC_ALL",
            "PATH",
            "PRIME_PMHNP_COMPANION_ROOT",
            "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE",
            "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE",
            "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE",
            "PRIME_REQUIRE_V9_PINNED_DONOR_GATE",
            "PRIME_TEST_PINNED_MLX_METALLIB",
            "SDKROOT",
            "SOURCE_DATE_EPOCH",
            "SWIFTPM_MODULECACHE_OVERRIDE",
            "TERM",
            "TMPDIR",
            "TZ",
        ]
        guard ordered.map(\.key) == expectedKeys else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        return ordered
    }

    private static func deterministicExecutionBaseEnvironment(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) -> [PrimeValidationEnvironmentEntry] {
        let workspace = intent.roots.workspaceRoot.absolutePath
        let home = intent.roots.homeAbsolutePath
        let toolchainBinaryPath = toolchain.developerDirectory
            .canonicalAbsolutePath
            + "/Toolchains/XcodeDefault.xctoolchain/usr/bin"
        return [
            .init(key: "CFFIXED_USER_HOME", value: home),
            .init(
                key: "CLANG_MODULE_CACHE_PATH",
                value: intent.roots.clangModuleCacheAbsolutePath
            ),
            .init(
                key: "DEVELOPER_DIR",
                value: toolchain.developerDirectory.canonicalAbsolutePath
            ),
            .init(key: "HOME", value: home),
            .init(key: "LANG", value: "C"),
            .init(key: "LC_ALL", value: "C"),
            .init(
                key: "PATH",
                value: toolchainBinaryPath + ":/usr/bin:/bin"
            ),
            .init(
                key: "SDKROOT",
                value: toolchain.sdkRoot.canonicalAbsolutePath
            ),
            .init(key: "SOURCE_DATE_EPOCH", value: "0"),
            .init(
                key: "SWIFTPM_MODULECACHE_OVERRIDE",
                value: intent.roots.swiftPMModuleCacheAbsolutePath
            ),
            .init(key: "TERM", value: "dumb"),
            .init(
                key: "TMPDIR",
                value: workspace + "/" + intent.roots.temporaryRelativePath
            ),
            .init(key: "TZ", value: "UTC"),
        ]
    }

    public func validatePhysicalJoins(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2,
        repository: PrimeValidationRepositoryAdmissionReceiptV2,
        staging: PrimeValidationStagingLayoutReceiptV2
    ) throws {
        try validate(intent: intent, toolchain: toolchain)
        try repository.validate(intent: intent)
        try staging.validate(intent: intent)
        let stagingByName = Dictionary(
            uniqueKeysWithValues: staging.workspaceDirectories.map {
                ($0.name, $0.directory.canonicalAbsolutePath)
            }
        )
        let expectedPathValues: [String: String] = [
            "CFFIXED_USER_HOME": stagingByName["home"] ?? "",
            "CLANG_MODULE_CACHE_PATH":
                stagingByName["clang_module_cache"] ?? "",
            "DEVELOPER_DIR":
                toolchain.developerDirectory.canonicalAbsolutePath,
            "HOME": stagingByName["home"] ?? "",
            "PATH": toolchain.developerDirectory.canonicalAbsolutePath
                + "/Toolchains/XcodeDefault.xctoolchain/usr/bin:"
                + "/usr/bin:/bin",
            "PRIME_PMHNP_COMPANION_ROOT":
                repository.companionRoot.canonicalAbsolutePath,
            "PRIME_TEST_PINNED_MLX_METALLIB":
                PrimeValidationDriverV2Validation.appending(
                    intent.requiredPinnedMetallib.relativePath,
                    to: staging.workspaceRoot.canonicalAbsolutePath
                ),
            "SDKROOT": toolchain.sdkRoot.canonicalAbsolutePath,
            "SWIFTPM_MODULECACHE_OVERRIDE":
                stagingByName["swiftpm_module_cache"] ?? "",
            "TMPDIR": stagingByName["temporary"] ?? "",
        ]
        for launch in launches {
            let environment = Dictionary(
                uniqueKeysWithValues:
                    launch.orderedCompleteReplacementEnvironment.map {
                        ($0.key, $0.value)
                    }
            )
            guard launch.physicalWorkingDirectoryAbsolutePath
                    == repository.repositoryRoot.canonicalAbsolutePath,
                  expectedPathValues.allSatisfy({ entry in
                      environment[entry.key] == entry.value
                  })
            else {
                throw PrimeValidationDriverV2Error.invalidExecutionPlan
            }
        }
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2
    ) throws -> String {
        try validate(intent: intent, toolchain: toolchain)
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public struct PrimeValidationRepositoryAdmissionReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let repositoryRoot:
        PrimeValidationCanonicalDirectoryObservationV2
    public let companionRoot:
        PrimeValidationCanonicalDirectoryObservationV2
    public let gitExecutable: PrimeValidationHeldExecutableObservationV2
    public let sourceSnapshotArtifact: PrimeValidationAdmissionBoundDataV2
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256: String
    public let packageLockArtifact: PrimeValidationAdmissionBoundDataV2
    public let packageLockFile:
        PrimeValidationHeldRegularFileObservationV2
    public let packageLockFileAfterAdmission:
        PrimeValidationHeldRegularFileObservationV2
    public let repositoryHEADOutput: PrimeValidationAdmissionBoundDataV2
    public let repositoryCommit: String
    public let repositoryStatusOutput: PrimeValidationAdmissionBoundDataV2
    public let repositoryTrackedTreeSHA256: String
    public let companionHEADOutput: PrimeValidationAdmissionBoundDataV2
    public let companionCommit: String
    public let companionStatusOutput: PrimeValidationAdmissionBoundDataV2
    public let companionTrackedTreeSHA256: String
    public let repositoryDescriptorClosureHeld: Bool
    public let companionDescriptorClosureHeld: Bool
    public let vnodeWatchersArmed: Bool
    public let initialPendingVnodeEventCount: Int

    public init(
        repositoryRoot:
            PrimeValidationCanonicalDirectoryObservationV2,
        companionRoot:
            PrimeValidationCanonicalDirectoryObservationV2,
        gitExecutable: PrimeValidationHeldExecutableObservationV2,
        sourceSnapshotArtifact: PrimeValidationAdmissionBoundDataV2,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String,
        packageLockArtifact: PrimeValidationAdmissionBoundDataV2,
        packageLockFile:
            PrimeValidationHeldRegularFileObservationV2,
        packageLockFileAfterAdmission:
            PrimeValidationHeldRegularFileObservationV2,
        repositoryHEADOutput: PrimeValidationAdmissionBoundDataV2,
        repositoryCommit: String,
        repositoryStatusOutput: PrimeValidationAdmissionBoundDataV2,
        repositoryTrackedTreeSHA256: String,
        companionHEADOutput: PrimeValidationAdmissionBoundDataV2,
        companionCommit: String,
        companionStatusOutput: PrimeValidationAdmissionBoundDataV2,
        companionTrackedTreeSHA256: String,
        repositoryDescriptorClosureHeld: Bool,
        companionDescriptorClosureHeld: Bool,
        vnodeWatchersArmed: Bool,
        initialPendingVnodeEventCount: Int
    ) {
        self.repositoryRoot = repositoryRoot
        self.companionRoot = companionRoot
        self.gitExecutable = gitExecutable
        self.sourceSnapshotArtifact = sourceSnapshotArtifact
        self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 = embeddedSourceIdentitySHA256
        self.packageLockArtifact = packageLockArtifact
        self.packageLockFile = packageLockFile
        self.packageLockFileAfterAdmission = packageLockFileAfterAdmission
        self.repositoryHEADOutput = repositoryHEADOutput
        self.repositoryCommit = repositoryCommit
        self.repositoryStatusOutput = repositoryStatusOutput
        self.repositoryTrackedTreeSHA256 = repositoryTrackedTreeSHA256
        self.companionHEADOutput = companionHEADOutput
        self.companionCommit = companionCommit
        self.companionStatusOutput = companionStatusOutput
        self.companionTrackedTreeSHA256 = companionTrackedTreeSHA256
        self.repositoryDescriptorClosureHeld = repositoryDescriptorClosureHeld
        self.companionDescriptorClosureHeld = companionDescriptorClosureHeld
        self.vnodeWatchersArmed = vnodeWatchersArmed
        self.initialPendingVnodeEventCount = initialPendingVnodeEventCount
    }

    public func validate(intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        guard repositoryRoot.role == .repository,
              companionRoot.role == .companion
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("repository")
        }
        try repositoryRoot.validate()
        try companionRoot.validate()
        try gitExecutable.validate()
        try sourceSnapshotArtifact.validate(maximumByteCount: 512 * 1024 * 1024)
        try packageLockArtifact.validate(maximumByteCount: 16 * 1024 * 1024)
        try packageLockFile.validate()
        try packageLockFileAfterAdmission.validate()
        try repositoryHEADOutput.validate(maximumByteCount: 128)
        try repositoryStatusOutput.validate(
            permitsEmpty: true,
            maximumByteCount: 16 * 1024 * 1024
        )
        try companionHEADOutput.validate(maximumByteCount: 128)
        try companionStatusOutput.validate(
            permitsEmpty: true,
            maximumByteCount: 16 * 1024 * 1024
        )
        for digest in [
            sourceIdentitySHA256,
            embeddedSourceIdentitySHA256,
            repositoryTrackedTreeSHA256,
            companionTrackedTreeSHA256,
        ] {
            try PrimeValidationDriverV2Validation.requireSHA256(digest)
        }
        let decodedSourceSnapshot: PrimeSwiftSourceSnapshot
        do {
            decodedSourceSnapshot = try PrimeCanonicalJSON.decode(
                PrimeSwiftSourceSnapshot.self,
                from: sourceSnapshotArtifact.data,
                artifact: sourceSnapshotArtifact.artifact.relativePath
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "source_snapshot"
            )
        }
        do {
            try PrimeSwiftSourceProvenance.validateReleaseEvidence(
                decodedSourceSnapshot,
                requiredRelativePaths: [
                    "Package.resolved",
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                ]
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "source_snapshot"
            )
        }
        let canonicalSourceSnapshot: Data
        do {
            canonicalSourceSnapshot = try PrimeCanonicalJSON.encode(
                decodedSourceSnapshot
            )
        } catch {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "source_snapshot"
            )
        }
        guard let snapshotPackageLock = decodedSourceSnapshot.files
                .first(where: { $0.relativePath == "Package.resolved" })
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "package_lock"
            )
        }
        guard repositoryRoot.canonicalAbsolutePath
                == intent.roots.repositoryRoot.absolutePath,
              companionRoot.canonicalAbsolutePath
                == intent.roots.companionRoot.absolutePath,
              repositoryRoot.deviceID == intent.roots.repositoryRoot.deviceID,
              repositoryRoot.inode == intent.roots.repositoryRoot.inode,
              companionRoot.deviceID == intent.roots.companionRoot.deviceID,
              companionRoot.inode == intent.roots.companionRoot.inode,
              sourceSnapshotArtifact.artifact.name == "source_snapshot",
              sourceSnapshotArtifact.artifact.relativePath
                == "admission/source-snapshot.json",
              sourceSnapshotArtifact.artifact.content == intent.sourceSnapshot,
              sourceSnapshotArtifact.data == canonicalSourceSnapshot,
              decodedSourceSnapshot.sourceIdentitySHA256
                == sourceIdentitySHA256,
              decodedSourceSnapshot.embeddedSourceIdentitySHA256
                == embeddedSourceIdentitySHA256,
              decodedSourceSnapshot.buildConfiguration == "release",
              sourceIdentitySHA256 == embeddedSourceIdentitySHA256,
              packageLockArtifact.artifact.name == "package_lock",
              packageLockArtifact.artifact.relativePath
                == "admission/Package.resolved",
              packageLockArtifact.artifact.content == intent.packageLock,
              snapshotPackageLock.contents == packageLockArtifact.data,
              snapshotPackageLock.sha256
                == packageLockArtifact.artifact.content.sha256,
              snapshotPackageLock.byteCount
                == packageLockArtifact.artifact.content.byteCount,
              packageLockFile.role == .packageLock,
              packageLockFile.absolutePath
                == repositoryRoot.canonicalAbsolutePath + "/Package.resolved",
              packageLockFile.content == packageLockArtifact.artifact.content,
              packageLockFile.deviceID == repositoryRoot.deviceID,
              packageLockFile.ownerUserID == repositoryRoot.ownerUserID,
              packageLockFile.ownerGroupID == repositoryRoot.ownerGroupID,
              packageLockFileAfterAdmission == packageLockFile,
              Self.isCommit(repositoryCommit),
              Self.isCommit(companionCommit),
              repositoryHEADOutput.artifact.name == "repository_head",
              repositoryStatusOutput.artifact.name == "repository_status",
              companionHEADOutput.artifact.name == "companion_head",
              companionStatusOutput.artifact.name == "companion_status",
              repositoryHEADOutput.data == Data((repositoryCommit + "\n").utf8),
              companionHEADOutput.data == Data((companionCommit + "\n").utf8),
              companionCommit == intent.companionCommit,
              gitExecutable.requestedAbsolutePath == "/usr/bin/git",
              gitExecutable.canonicalAbsolutePath == "/usr/bin/git",
              gitExecutable.requestedSymlinkTarget == nil,
              gitExecutable.ownerUserID == 0,
              gitExecutable.ownerGroupID == 0,
              repositoryStatusOutput.data.isEmpty,
              companionStatusOutput.data.isEmpty,
              repositoryDescriptorClosureHeld,
              companionDescriptorClosureHeld,
              vnodeWatchersArmed,
              initialPendingVnodeEventCount == 0
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("repository")
        }
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(intent: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    private static func isCommit(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }
}

public struct PrimeValidationStagingDirectoryObservationV2:
    Codable,
    Equatable,
    Sendable
{
    public let name: String
    public let relativePath: String
    public let directory: PrimeValidationCanonicalDirectoryObservationV2

    public init(
        name: String,
        relativePath: String,
        directory: PrimeValidationCanonicalDirectoryObservationV2
    ) {
        self.name = name
        self.relativePath = relativePath
        self.directory = directory
    }

    public func validate(workspacePath: String) throws {
        guard PrimeValidationDriverV2Validation.isSafeName(name),
              directory.role == .workspaceSubdirectory
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(name)
        }
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(
            relativePath
        )
        try directory.validate()
        guard directory.canonicalAbsolutePath
                == PrimeValidationDriverV2Validation.appending(
                    relativePath,
                    to: workspacePath
                )
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(name)
        }
    }
}

public struct PrimeValidationStagingLayoutReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let workspaceRoot:
        PrimeValidationCanonicalDirectoryObservationV2
    public let evidenceRoot:
        PrimeValidationCanonicalDirectoryObservationV2
    public let workspaceDirectories:
        [PrimeValidationStagingDirectoryObservationV2]
    public let evidenceRunDirectory:
        PrimeValidationCanonicalDirectoryObservationV2
    public let exclusiveLeaseHeld: Bool
    public let initiallyEmptyObserved: Bool
    public let durableDirectorySynchronizationObserved: Bool

    public init(
        workspaceRoot:
            PrimeValidationCanonicalDirectoryObservationV2,
        evidenceRoot:
            PrimeValidationCanonicalDirectoryObservationV2,
        workspaceDirectories:
            [PrimeValidationStagingDirectoryObservationV2],
        evidenceRunDirectory:
            PrimeValidationCanonicalDirectoryObservationV2,
        exclusiveLeaseHeld: Bool,
        initiallyEmptyObserved: Bool,
        durableDirectorySynchronizationObserved: Bool
    ) {
        self.workspaceRoot = workspaceRoot
        self.evidenceRoot = evidenceRoot
        self.workspaceDirectories = workspaceDirectories
        self.evidenceRunDirectory = evidenceRunDirectory
        self.exclusiveLeaseHeld = exclusiveLeaseHeld
        self.initiallyEmptyObserved = initiallyEmptyObserved
        self.durableDirectorySynchronizationObserved =
            durableDirectorySynchronizationObserved
    }

    public func validate(intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        guard workspaceRoot.role == .workspace,
              evidenceRoot.role == .evidence,
              evidenceRunDirectory.role == .evidenceRunDirectory
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("staging")
        }
        try workspaceRoot.validate()
        try evidenceRoot.validate()
        try evidenceRunDirectory.validate()
        let expected = [
            ("cache", intent.roots.cacheRelativePath),
            ("clang_module_cache", intent.roots.clangModuleCacheRelativePath),
            ("config", intent.roots.configRelativePath),
            ("home", intent.roots.homeRelativePath),
            ("output", intent.roots.outputRelativePath),
            ("scratch", intent.roots.scratchRelativePath),
            ("security", intent.roots.securityRelativePath),
            ("swiftpm_module_cache", intent.roots.swiftPMModuleCacheRelativePath),
            ("temporary", intent.roots.temporaryRelativePath),
        ]
        guard workspaceRoot.canonicalAbsolutePath
                == intent.roots.workspaceRoot.absolutePath,
              workspaceRoot.deviceID == intent.roots.workspaceRoot.deviceID,
              workspaceRoot.inode == intent.roots.workspaceRoot.inode,
              evidenceRoot.canonicalAbsolutePath
                == intent.roots.evidenceRoot.absolutePath,
              evidenceRoot.deviceID == intent.roots.evidenceRoot.deviceID,
              evidenceRoot.inode == intent.roots.evidenceRoot.inode,
              workspaceDirectories.map({ ($0.name, $0.relativePath) })
                .elementsEqual(expected, by: { $0.0 == $1.0 && $0.1 == $1.1 }),
              Set(workspaceDirectories.map(\.directory.identityKey)).count
                == workspaceDirectories.count,
              workspaceDirectories.allSatisfy({
                  $0.directory.filesystemIDWord0
                    == workspaceRoot.filesystemIDWord0
                    && $0.directory.filesystemIDWord1
                    == workspaceRoot.filesystemIDWord1
              }),
              evidenceRunDirectory.canonicalAbsolutePath
                == PrimeValidationDriverV2Validation.appending(
                    intent.runID,
                    to: evidenceRoot.canonicalAbsolutePath
                ),
              evidenceRunDirectory.filesystemIDWord0
                == evidenceRoot.filesystemIDWord0,
              evidenceRunDirectory.filesystemIDWord1
                == evidenceRoot.filesystemIDWord1,
              exclusiveLeaseHeld,
              initiallyEmptyObserved,
              durableDirectorySynchronizationObserved
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("staging")
        }
        try workspaceDirectories.forEach {
            try $0.validate(
                workspacePath: workspaceRoot.canonicalAbsolutePath
            )
        }
        try Self.requireDisjoint(
            [workspaceRoot, evidenceRoot, evidenceRunDirectory]
                + workspaceDirectories.map(\.directory),
            permitsEvidenceDescendant: true
        )
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(intent: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    fileprivate static func requireDisjoint(
        _ directories: [PrimeValidationCanonicalDirectoryObservationV2],
        permitsEvidenceDescendant: Bool
    ) throws {
        guard Set(directories.map(\.identityKey)).count == directories.count
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "directory_identity_overlap"
            )
        }
        for first in directories {
            for second in directories where first != second {
                let descendant = second.canonicalAbsolutePath.hasPrefix(
                    first.canonicalAbsolutePath + "/"
                )
                if descendant {
                    let admittedWorkspaceChild = first.role == .workspace
                        && second.role == .workspaceSubdirectory
                    let admittedEvidenceChild = permitsEvidenceDescendant
                        && first.role == .evidence
                        && second.role == .evidenceRunDirectory
                    guard admittedWorkspaceChild || admittedEvidenceChild else {
                        throw PrimeValidationDriverV2Error.invalidBinding(
                            "directory_path_overlap"
                        )
                    }
                }
            }
        }
    }
}

public struct PrimeValidationExecutorAdmissionPolicyV2:
    Codable,
    Equatable,
    Sendable
{
    public let scratchRelativePath: String
    public let cacheRelativePath: String
    public let configRelativePath: String
    public let securityRelativePath: String
    public let clangModuleCacheRelativePath: String
    public let homeRelativePath: String
    public let swiftPMModuleCacheRelativePath: String
    public let temporaryRelativePath: String
    public let outputRelativePath: String
    public let phaseBudgets: [PrimeValidationPhaseBudgetV2]

    public static let frozenV1 = Self(
        scratchRelativePath: "root-release-build",
        cacheRelativePath: "cache",
        configRelativePath: "config",
        securityRelativePath: "security",
        clangModuleCacheRelativePath: "clang-module-cache",
        homeRelativePath: "home",
        swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
        temporaryRelativePath: "temporary",
        outputRelativePath: "output",
        phaseBudgets: [
            .init(
                phase: .sourceAdmission,
                maximumActiveNanoseconds: 30_000_000_000
            ),
            .init(
                phase: .build,
                maximumActiveNanoseconds: 900_000_000_000
            ),
            .init(
                phase: .inventory,
                maximumActiveNanoseconds: 300_000_000_000
            ),
            .init(
                phase: .executionPlan,
                maximumActiveNanoseconds: 30_000_000_000
            ),
            .init(
                phase: .referenceExecution,
                maximumActiveNanoseconds: 1_800_000_000_000
            ),
            .init(
                phase: .candidateExecution,
                maximumActiveNanoseconds: 1_800_000_000_000
            ),
            .init(
                phase: .reconciliation,
                maximumActiveNanoseconds: 120_000_000_000
            ),
            .init(
                phase: .comparison,
                maximumActiveNanoseconds: 60_000_000_000
            ),
            .init(
                phase: .publication,
                maximumActiveNanoseconds: 30_000_000_000
            ),
        ].sorted { $0.phase.rawValue < $1.phase.rawValue }
    )

    public init(
        scratchRelativePath: String,
        cacheRelativePath: String,
        configRelativePath: String,
        securityRelativePath: String,
        clangModuleCacheRelativePath: String,
        homeRelativePath: String,
        swiftPMModuleCacheRelativePath: String,
        temporaryRelativePath: String,
        outputRelativePath: String,
        phaseBudgets: [PrimeValidationPhaseBudgetV2]
    ) {
        self.scratchRelativePath = scratchRelativePath
        self.cacheRelativePath = cacheRelativePath
        self.configRelativePath = configRelativePath
        self.securityRelativePath = securityRelativePath
        self.clangModuleCacheRelativePath = clangModuleCacheRelativePath
        self.homeRelativePath = homeRelativePath
        self.swiftPMModuleCacheRelativePath = swiftPMModuleCacheRelativePath
        self.temporaryRelativePath = temporaryRelativePath
        self.outputRelativePath = outputRelativePath
        self.phaseBudgets = phaseBudgets
    }

    public func validate(intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        guard self == .frozenV1,
              intent.roots.scratchRelativePath == scratchRelativePath,
              intent.roots.cacheRelativePath == cacheRelativePath,
              intent.roots.configRelativePath == configRelativePath,
              intent.roots.securityRelativePath == securityRelativePath,
              intent.roots.clangModuleCacheRelativePath
                == clangModuleCacheRelativePath,
              intent.roots.homeRelativePath == homeRelativePath,
              intent.roots.swiftPMModuleCacheRelativePath
                == swiftPMModuleCacheRelativePath,
              intent.roots.temporaryRelativePath == temporaryRelativePath,
              intent.roots.outputRelativePath == outputRelativePath,
              intent.phaseBudgets == phaseBudgets
        else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(intent: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public enum PrimeValidationAdmissionChainKindV2:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case policy
    case toolchain
    case supervisor
    case repository
    case staging
    case launchPlan = "launch_plan"
}

/// A non-optional evidence state. In particular, absence of execution in the
/// admission-only slice is `unobserved`, never a fabricated observed `false`.
public enum PrimeValidationAdmissionObservationStateV2:
    String,
    Codable,
    Sendable
{
    case observedTrue = "observed_true"
    case observedFalse = "observed_false"
    case unobserved
}

public struct PrimeValidationAdmissionChainLinkV2:
    Codable,
    Equatable,
    Sendable
{
    public let kind: PrimeValidationAdmissionChainKindV2
    public let predecessorSHA256: String
    public let receiptSHA256: String

    public init(
        kind: PrimeValidationAdmissionChainKindV2,
        predecessorSHA256: String,
        receiptSHA256: String
    ) {
        self.kind = kind
        self.predecessorSHA256 = predecessorSHA256
        self.receiptSHA256 = receiptSHA256
    }

    public func validate() throws {
        try PrimeValidationDriverV2Validation.requireSHA256(
            predecessorSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(receiptSHA256)
    }
}

public struct PrimeValidationExecutorAdmissionReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public static let schemaVersion = 2
    public static let artifactKind =
        "ergentics_prime_validation_executor_admission_v2"

    public let schemaVersion: Int
    public let artifactKind: String
    public let intent: PrimeValidationRunIntentV2
    public let intentSHA256: String
    public let authority: PrimeValidationDriverAuthorityCeilingV2
    public let policy: PrimeValidationExecutorAdmissionPolicyV2
    public let toolchain: PrimeValidationToolchainAdmissionReceiptV2
    public let supervisorExecutable:
        PrimeValidationHeldExecutableObservationV2
    public let repository: PrimeValidationRepositoryAdmissionReceiptV2
    public let staging: PrimeValidationStagingLayoutReceiptV2
    public let launchPlan: PrimeValidationSwiftPackageAdmissionLaunchPlanV2
    public let chain: [PrimeValidationAdmissionChainLinkV2]
    public let processExecutionObservation:
        PrimeValidationAdmissionObservationStateV2
    public let buildExecutionObservation:
        PrimeValidationAdmissionObservationStateV2
    public let inventoryExecutionObservation:
        PrimeValidationAdmissionObservationStateV2
    public let shardCompletionObservation:
        PrimeValidationAdmissionObservationStateV2
    public let statement: String

    public init(
        intent: PrimeValidationRunIntentV2,
        intentSHA256: String,
        authority: PrimeValidationDriverAuthorityCeilingV2,
        policy: PrimeValidationExecutorAdmissionPolicyV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2,
        supervisorExecutable:
            PrimeValidationHeldExecutableObservationV2,
        repository: PrimeValidationRepositoryAdmissionReceiptV2,
        staging: PrimeValidationStagingLayoutReceiptV2,
        launchPlan: PrimeValidationSwiftPackageAdmissionLaunchPlanV2,
        chain: [PrimeValidationAdmissionChainLinkV2],
        processExecutionObservation:
            PrimeValidationAdmissionObservationStateV2,
        buildExecutionObservation:
            PrimeValidationAdmissionObservationStateV2,
        inventoryExecutionObservation:
            PrimeValidationAdmissionObservationStateV2,
        shardCompletionObservation:
            PrimeValidationAdmissionObservationStateV2,
        statement: String
    ) {
        schemaVersion = Self.schemaVersion
        artifactKind = Self.artifactKind
        self.intent = intent
        self.intentSHA256 = intentSHA256
        self.authority = authority
        self.policy = policy
        self.toolchain = toolchain
        self.supervisorExecutable = supervisorExecutable
        self.repository = repository
        self.staging = staging
        self.launchPlan = launchPlan
        self.chain = chain
        self.processExecutionObservation = processExecutionObservation
        self.buildExecutionObservation = buildExecutionObservation
        self.inventoryExecutionObservation = inventoryExecutionObservation
        self.shardCompletionObservation = shardCompletionObservation
        self.statement = statement
    }

    public static func make(
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2,
        supervisorExecutable:
            PrimeValidationHeldExecutableObservationV2,
        repository: PrimeValidationRepositoryAdmissionReceiptV2,
        staging: PrimeValidationStagingLayoutReceiptV2
    ) throws -> Self {
        try intent.validate()
        let policy = PrimeValidationExecutorAdmissionPolicyV2.frozenV1
        try policy.validate(intent: intent)
        try supervisorExecutable.validate()
        let launchPlan = try PrimeValidationSwiftPackageAdmissionLaunchPlanV2
            .make(intent: intent, toolchain: toolchain)
        let policySHA = try policy.identitySHA256(intent: intent)
        let toolchainSHA = try toolchain.identitySHA256()
        let supervisorSHA = try supervisorExecutable.identitySHA256()
        let repositorySHA = try repository.identitySHA256(intent: intent)
        let stagingSHA = try staging.identitySHA256(intent: intent)
        let launchPlanSHA = try launchPlan.identitySHA256(
            intent: intent,
            toolchain: toolchain
        )
        return Self(
            intent: intent,
            intentSHA256: try intent.identitySHA256(),
            authority: .frozenPlannerV2,
            policy: policy,
            toolchain: toolchain,
            supervisorExecutable: supervisorExecutable,
            repository: repository,
            staging: staging,
            launchPlan: launchPlan,
            chain: [
                .init(
                    kind: .policy,
                    predecessorSHA256:
                        PrimeValidationDriverV2Validation.genesisSHA256,
                    receiptSHA256: policySHA
                ),
                .init(
                    kind: .toolchain,
                    predecessorSHA256: policySHA,
                    receiptSHA256: toolchainSHA
                ),
                .init(
                    kind: .supervisor,
                    predecessorSHA256: toolchainSHA,
                    receiptSHA256: supervisorSHA
                ),
                .init(
                    kind: .repository,
                    predecessorSHA256: supervisorSHA,
                    receiptSHA256: repositorySHA
                ),
                .init(
                    kind: .staging,
                    predecessorSHA256: repositorySHA,
                    receiptSHA256: stagingSHA
                ),
                .init(
                    kind: .launchPlan,
                    predecessorSHA256: stagingSHA,
                    receiptSHA256: launchPlanSHA
                ),
            ],
            processExecutionObservation: .unobserved,
            buildExecutionObservation: .unobserved,
            inventoryExecutionObservation: .unobserved,
            shardCompletionObservation: .unobserved,
            statement:
                "mechanics_only_source_toolchain_root_and_staging_declared_observations_no_process_build_inventory_resume_or_shard_completion_authority"
        )
    }

    public func validate() throws {
        try intent.validate()
        try authority.validate()
        try policy.validate(intent: intent)
        try toolchain.validate()
        try supervisorExecutable.validate()
        try repository.validate(intent: intent)
        try staging.validate(intent: intent)
        try launchPlan.validate(intent: intent, toolchain: toolchain)
        try launchPlan.validatePhysicalJoins(
            intent: intent,
            toolchain: toolchain,
            repository: repository,
            staging: staging
        )
        let policySHA = try policy.identitySHA256(intent: intent)
        let toolchainSHA = try toolchain.identitySHA256()
        let supervisorSHA = try supervisorExecutable.identitySHA256()
        let repositorySHA = try repository.identitySHA256(intent: intent)
        let stagingSHA = try staging.identitySHA256(intent: intent)
        let launchPlanSHA = try launchPlan.identitySHA256(
            intent: intent,
            toolchain: toolchain
        )
        let expectedChain = [
            PrimeValidationAdmissionChainLinkV2(
                kind: .policy,
                predecessorSHA256:
                    PrimeValidationDriverV2Validation.genesisSHA256,
                receiptSHA256: policySHA
            ),
            PrimeValidationAdmissionChainLinkV2(
                kind: .toolchain,
                predecessorSHA256: policySHA,
                receiptSHA256: toolchainSHA
            ),
            PrimeValidationAdmissionChainLinkV2(
                kind: .supervisor,
                predecessorSHA256: toolchainSHA,
                receiptSHA256: supervisorSHA
            ),
            PrimeValidationAdmissionChainLinkV2(
                kind: .repository,
                predecessorSHA256: supervisorSHA,
                receiptSHA256: repositorySHA
            ),
            PrimeValidationAdmissionChainLinkV2(
                kind: .staging,
                predecessorSHA256: repositorySHA,
                receiptSHA256: stagingSHA
            ),
            PrimeValidationAdmissionChainLinkV2(
                kind: .launchPlan,
                predecessorSHA256: stagingSHA,
                receiptSHA256: launchPlanSHA
            ),
        ]
        try chain.forEach { try $0.validate() }
        let allRoots = [
            repository.repositoryRoot,
            repository.companionRoot,
            staging.workspaceRoot,
            staging.evidenceRoot,
        ]
        try PrimeValidationStagingLayoutReceiptV2.requireDisjoint(
            allRoots,
            permitsEvidenceDescendant: false
        )
        guard schemaVersion == Self.schemaVersion,
              artifactKind == Self.artifactKind,
              intentSHA256 == (try intent.identitySHA256()),
              authority == .frozenPlannerV2,
              policy == .frozenV1,
              supervisorExecutable.requestedAbsolutePath
                == intent.driverExecutable.absolutePath,
              supervisorExecutable.content == intent.driverExecutable.content,
              toolchain.swiftExecutable.requestedAbsolutePath
                == intent.swiftExecutable.absolutePath,
              toolchain.swiftExecutable.content
                == intent.swiftExecutable.content,
              chain == expectedChain,
              processExecutionObservation == .unobserved,
              buildExecutionObservation == .unobserved,
              inventoryExecutionObservation == .unobserved,
              shardCompletionObservation == .unobserved,
              statement
                == "mechanics_only_source_toolchain_root_and_staging_declared_observations_no_process_build_inventory_resume_or_shard_completion_authority"
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

/// A future same-module live adapter may construct this class only after it
/// has retained the corresponding descriptors, watchers, and exclusive lease.
/// It deliberately has no execution method and cannot be restored from a
/// durable receipt.
public final class PrimeValidationPreparedExecutorAdmissionV2:
    @unchecked Sendable
{
    public let receipt: PrimeValidationExecutorAdmissionReceiptV2

    private init(liveReceipt: PrimeValidationExecutorAdmissionReceiptV2)
        throws
    {
        try liveReceipt.validate()
        receipt = liveReceipt
    }

    public static func restore(
        from _: PrimeValidationExecutorAdmissionReceiptV2
    ) throws -> Self {
        throw PrimeValidationDriverV2Error.authorityViolation
    }

    public var processExecutionAuthorized: Bool { false }
    public var buildExecutionAuthorized: Bool { false }
    public var inventoryExecutionAuthorized: Bool { false }
    public var shardCompletionAuthorized: Bool { false }
}

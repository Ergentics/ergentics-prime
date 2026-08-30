// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

/// The live Swift observations available at Gate E. This value deliberately
/// omits the held-but-unmapped `swift-package` image needed to complete the
/// existing toolchain receipt. It is non-Codable and retains no process API.
package struct PrimeValidationDriverV2PartialToolchainProbeBinding {
    package let developerDirectory:
        PrimeValidationCanonicalDirectoryObservationV2
    package let sdkRoot: PrimeValidationCanonicalDirectoryObservationV2
    package let swiftExecutable: PrimeValidationHeldExecutableObservationV2
    package let swiftCompilerExecutable:
        PrimeValidationHeldExecutableObservationV2
    package let xcodeVersionOutput: PrimeValidationAdmissionBoundDataV2
    package let sdkPathOutput: PrimeValidationAdmissionBoundDataV2
    package let sdkVersionOutput: PrimeValidationAdmissionBoundDataV2
    package let swiftVersionOutput: PrimeValidationAdmissionBoundDataV2
    package let swiftTargetInfoOutput: PrimeValidationAdmissionBoundDataV2
    package let xcodeVersion: String
    package let xcodeBuildVersion: String
    package let sdkVersion: String
    package let swiftDriverVersion: String
    package let targetInfo: PrimeValidationSwiftTargetInfoObservationV2
    package let orderedProbeEnvironment: [PrimeValidationEnvironmentEntry]
    package let identitySHA256: String

    fileprivate let unmappedSwiftPackage:
        PrimeValidationSwiftPMFileObservation
    fileprivate let xcodeVersionPlist:
        PrimeValidationSwiftPMFileObservation
    fileprivate let sdkSettingsPlist:
        PrimeValidationSwiftPMFileObservation
    fileprivate let xcodeVersionPlistContent: PrimeValidationContentBinding
    fileprivate let sdkSettingsPlistContent: PrimeValidationContentBinding
    fileprivate let swiftPersonality:
        PrimeValidationSwiftPMPersonalityObservation
    fileprivate let swiftCompilerPersonality:
        PrimeValidationSwiftPMPersonalityObservation
    fileprivate let swiftPersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
    fileprivate let swiftCompilerPersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation

    fileprivate init(
        observation: PrimeValidationDriverV2FixedProbeRawObservation,
        swiftVersionOutput: Data,
        swiftTargetInfoOutput: Data
    ) throws {
        let toolchain = observation.toolchain
        guard UInt64(observation.swiftFrontendExecutableData.count)
                == observation.swiftFrontendExecutable.byteCount,
              observation.swiftFrontendExecutable.byteCount
                <= 512 * 1024 * 1024,
              observation.swiftFrontendExecutable.deviceID
                == observation.toolchain.developerDirectory.deviceID,
              PrimeSHA256.hexDigest(
                of: observation.swiftFrontendExecutableData
              ) == observation.swiftFrontendExecutable.sha256,
              UInt64(observation.xcodeVersionPlistData.count)
                == observation.toolchain.xcodeVersionPlist.byteCount,
              PrimeSHA256.hexDigest(of: observation.xcodeVersionPlistData)
                == observation.toolchain.xcodeVersionPlist.sha256,
              UInt64(observation.sdkSettingsPlistData.count)
                == observation.toolchain.sdkSettingsPlist.byteCount,
              PrimeSHA256.hexDigest(of: observation.sdkSettingsPlistData)
                == observation.toolchain.sdkSettingsPlist.sha256
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "swift_frontend_bytes"
            )
        }
        developerDirectory = Self.directory(
            toolchain.developerDirectory,
            role: .developerDirectory
        )
        sdkRoot = Self.directory(toolchain.sdkRoot, role: .sdkRoot)
        swiftExecutable = Self.heldExecutable(
            observation.swiftFrontendExecutable,
            data: observation.swiftFrontendExecutableData,
            personality: observation.swiftExecutablePersonality,
            mappedExecutableJoined: true
        )
        swiftCompilerExecutable = Self.heldExecutable(
            observation.swiftFrontendExecutable,
            data: observation.swiftFrontendExecutableData,
            personality: observation.swiftCompilerPersonality,
            mappedExecutableJoined: true
        )
        unmappedSwiftPackage = toolchain.swiftPackageExecutable
        xcodeVersionPlist = toolchain.xcodeVersionPlist
        sdkSettingsPlist = toolchain.sdkSettingsPlist
        xcodeVersionPlistContent = .init(
            data: observation.xcodeVersionPlistData
        )
        sdkSettingsPlistContent = .init(
            data: observation.sdkSettingsPlistData
        )
        swiftPersonality = observation.swiftExecutablePersonality
        swiftCompilerPersonality = observation.swiftCompilerPersonality
        swiftPersonalityIdentity =
            observation.swiftExecutablePersonalityIdentity
        swiftCompilerPersonalityIdentity =
            observation.swiftCompilerPersonalityIdentity

        let xcode = try Self.parseXcodeVersion(
            observation.xcodeVersionPlistData
        )
        let canonicalSDKName = try Self.parseSDKCanonicalName(
            observation.sdkSettingsPlistData
        )
        guard canonicalSDKName.hasPrefix("macosx") else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "sdk_version"
            )
        }
        xcodeVersion = xcode.version
        xcodeBuildVersion = xcode.build
        sdkVersion = String(canonicalSDKName.dropFirst("macosx".count))
        swiftDriverVersion = "1.148.6"
        try Self.validateTargetInfoFraming(swiftTargetInfoOutput)
        targetInfo = try PrimeValidationSwiftTargetInfoObservationV2.parse(
            swiftTargetInfoOutput
        )
        orderedProbeEnvironment =
            PrimeValidationToolchainAdmissionReceiptV2.probeEnvironment(
                developerDirectory:
                    developerDirectory.canonicalAbsolutePath,
                sdkRoot: sdkRoot.canonicalAbsolutePath
            )

        xcodeVersionOutput = .init(
            name: "xcode_version",
            relativePath: "admission/xcode_version.bin",
            data: Data(
                "Xcode \(xcode.version)\nBuild version \(xcode.build)\n".utf8
            )
        )
        sdkPathOutput = .init(
            name: "sdk_path",
            relativePath: "admission/sdk_path.bin",
            data: Data((sdkRoot.canonicalAbsolutePath + "\n").utf8)
        )
        sdkVersionOutput = .init(
            name: "sdk_version",
            relativePath: "admission/sdk_version.bin",
            data: Data((sdkVersion + "\n").utf8)
        )
        self.swiftVersionOutput = .init(
            name: "swift_version",
            relativePath: "admission/swift_version.bin",
            data: swiftVersionOutput
        )
        self.swiftTargetInfoOutput = .init(
            name: "swift_target_info",
            relativePath: "admission/swift_target_info.bin",
            data: swiftTargetInfoOutput
        )

        try Self.validateFields(
            developerDirectory: developerDirectory,
            sdkRoot: sdkRoot,
            swiftExecutable: swiftExecutable,
            swiftCompilerExecutable: swiftCompilerExecutable,
            unmappedSwiftPackage: unmappedSwiftPackage,
            swiftPersonality: swiftPersonality,
            swiftCompilerPersonality: swiftCompilerPersonality,
            swiftPersonalityIdentity: swiftPersonalityIdentity,
            swiftCompilerPersonalityIdentity:
                swiftCompilerPersonalityIdentity,
            xcodeVersionOutput: xcodeVersionOutput,
            sdkPathOutput: sdkPathOutput,
            sdkVersionOutput: sdkVersionOutput,
            swiftVersionOutput: self.swiftVersionOutput,
            swiftTargetInfoOutput: self.swiftTargetInfoOutput,
            xcodeVersion: xcodeVersion,
            xcodeBuildVersion: xcodeBuildVersion,
            sdkVersion: sdkVersion,
            swiftDriverVersion: swiftDriverVersion,
            targetInfo: targetInfo,
            orderedProbeEnvironment: orderedProbeEnvironment,
            rawToolchain: toolchain
        )
        identitySHA256 = try PrimeValidationDriverV2Validation.identity(
            IdentityProjection(
                developerDirectory: developerDirectory,
                sdkRoot: sdkRoot,
                swiftExecutable: swiftExecutable,
                swiftCompilerExecutable: swiftCompilerExecutable,
                unmappedSwiftPackage: .init(unmappedSwiftPackage),
                xcodeVersionPlist: .init(xcodeVersionPlist),
                sdkSettingsPlist: .init(sdkSettingsPlist),
                xcodeVersionPlistContent: xcodeVersionPlistContent,
                sdkSettingsPlistContent: sdkSettingsPlistContent,
                swiftPersonality: .init(
                    path: swiftPersonality,
                    identity: swiftPersonalityIdentity
                ),
                swiftCompilerPersonality: .init(
                    path: swiftCompilerPersonality,
                    identity: swiftCompilerPersonalityIdentity
                ),
                xcodeVersionOutput: xcodeVersionOutput,
                sdkPathOutput: sdkPathOutput,
                sdkVersionOutput: sdkVersionOutput,
                swiftVersionOutput: self.swiftVersionOutput,
                swiftTargetInfoOutput: self.swiftTargetInfoOutput,
                xcodeVersion: xcodeVersion,
                xcodeBuildVersion: xcodeBuildVersion,
                sdkVersion: sdkVersion,
                swiftDriverVersion: swiftDriverVersion,
                targetInfo: targetInfo,
                orderedProbeEnvironment: orderedProbeEnvironment,
                swiftPackageMappedExecutableJoined: false
            )
        )
    }

    package func validate() throws {
        try Self.validateFields(
            developerDirectory: developerDirectory,
            sdkRoot: sdkRoot,
            swiftExecutable: swiftExecutable,
            swiftCompilerExecutable: swiftCompilerExecutable,
            unmappedSwiftPackage: unmappedSwiftPackage,
            swiftPersonality: swiftPersonality,
            swiftCompilerPersonality: swiftCompilerPersonality,
            swiftPersonalityIdentity: swiftPersonalityIdentity,
            swiftCompilerPersonalityIdentity:
                swiftCompilerPersonalityIdentity,
            xcodeVersionOutput: xcodeVersionOutput,
            sdkPathOutput: sdkPathOutput,
            sdkVersionOutput: sdkVersionOutput,
            swiftVersionOutput: swiftVersionOutput,
            swiftTargetInfoOutput: swiftTargetInfoOutput,
            xcodeVersion: xcodeVersion,
            xcodeBuildVersion: xcodeBuildVersion,
            sdkVersion: sdkVersion,
            swiftDriverVersion: swiftDriverVersion,
            targetInfo: targetInfo,
            orderedProbeEnvironment: orderedProbeEnvironment,
            rawToolchain: nil
        )
        let expected = try PrimeValidationDriverV2Validation.identity(
            IdentityProjection(
                developerDirectory: developerDirectory,
                sdkRoot: sdkRoot,
                swiftExecutable: swiftExecutable,
                swiftCompilerExecutable: swiftCompilerExecutable,
                unmappedSwiftPackage: .init(unmappedSwiftPackage),
                xcodeVersionPlist: .init(xcodeVersionPlist),
                sdkSettingsPlist: .init(sdkSettingsPlist),
                xcodeVersionPlistContent: xcodeVersionPlistContent,
                sdkSettingsPlistContent: sdkSettingsPlistContent,
                swiftPersonality: .init(
                    path: swiftPersonality,
                    identity: swiftPersonalityIdentity
                ),
                swiftCompilerPersonality: .init(
                    path: swiftCompilerPersonality,
                    identity: swiftCompilerPersonalityIdentity
                ),
                xcodeVersionOutput: xcodeVersionOutput,
                sdkPathOutput: sdkPathOutput,
                sdkVersionOutput: sdkVersionOutput,
                swiftVersionOutput: swiftVersionOutput,
                swiftTargetInfoOutput: swiftTargetInfoOutput,
                xcodeVersion: xcodeVersion,
                xcodeBuildVersion: xcodeBuildVersion,
                sdkVersion: sdkVersion,
                swiftDriverVersion: swiftDriverVersion,
                targetInfo: targetInfo,
                orderedProbeEnvironment: orderedProbeEnvironment,
                swiftPackageMappedExecutableJoined: false
            )
        )
        guard identitySHA256 == expected else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "partial_toolchain_identity"
            )
        }
    }
}

private extension PrimeValidationDriverV2PartialToolchainProbeBinding {
    struct FileProjection: Codable {
        let canonicalAbsolutePath: String
        let deviceID: UInt64
        let inode: UInt64
        let ownerUserID: UInt32
        let ownerGroupID: UInt32
        let permissionMode: UInt16
        let linkCount: UInt64
        let byteCount: UInt64
        let sha256: String
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let statusChangeSeconds: Int64
        let statusChangeNanoseconds: Int64

        init(_ value: PrimeValidationSwiftPMFileObservation) {
            canonicalAbsolutePath = value.canonicalAbsolutePath
            deviceID = value.deviceID
            inode = value.inode
            ownerUserID = value.ownerUserID
            ownerGroupID = value.ownerGroupID
            permissionMode = value.permissionMode
            linkCount = value.linkCount
            byteCount = value.byteCount
            sha256 = value.sha256
            modificationSeconds = value.modificationSeconds
            modificationNanoseconds = value.modificationNanoseconds
            statusChangeSeconds = value.statusChangeSeconds
            statusChangeNanoseconds = value.statusChangeNanoseconds
        }
    }

    struct PersonalityProjection: Codable {
        let requestedAbsolutePath: String
        let symbolicLinkTarget: String
        let canonicalExecutableAbsolutePath: String
        let deviceID: UInt64
        let inode: UInt64
        let ownerUserID: UInt32
        let ownerGroupID: UInt32
        let mode: UInt32
        let linkCount: UInt64
        let byteCount: Int64
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let statusChangeSeconds: Int64
        let statusChangeNanoseconds: Int64

        init(
            path: PrimeValidationSwiftPMPersonalityObservation,
            identity:
                PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
        ) {
            requestedAbsolutePath = path.requestedAbsolutePath
            symbolicLinkTarget = path.symbolicLinkTarget
            canonicalExecutableAbsolutePath =
                path.canonicalExecutableAbsolutePath
            deviceID = identity.deviceID
            inode = identity.inode
            ownerUserID = identity.ownerUserID
            ownerGroupID = identity.ownerGroupID
            mode = identity.mode
            linkCount = identity.linkCount
            byteCount = identity.byteCount
            modificationSeconds = identity.modificationSeconds
            modificationNanoseconds = identity.modificationNanoseconds
            statusChangeSeconds = identity.statusChangeSeconds
            statusChangeNanoseconds = identity.statusChangeNanoseconds
        }
    }

    struct IdentityProjection: Codable {
        let developerDirectory:
            PrimeValidationCanonicalDirectoryObservationV2
        let sdkRoot: PrimeValidationCanonicalDirectoryObservationV2
        let swiftExecutable: PrimeValidationHeldExecutableObservationV2
        let swiftCompilerExecutable:
            PrimeValidationHeldExecutableObservationV2
        let unmappedSwiftPackage: FileProjection
        let xcodeVersionPlist: FileProjection
        let sdkSettingsPlist: FileProjection
        let xcodeVersionPlistContent: PrimeValidationContentBinding
        let sdkSettingsPlistContent: PrimeValidationContentBinding
        let swiftPersonality: PersonalityProjection
        let swiftCompilerPersonality: PersonalityProjection
        let xcodeVersionOutput: PrimeValidationAdmissionBoundDataV2
        let sdkPathOutput: PrimeValidationAdmissionBoundDataV2
        let sdkVersionOutput: PrimeValidationAdmissionBoundDataV2
        let swiftVersionOutput: PrimeValidationAdmissionBoundDataV2
        let swiftTargetInfoOutput: PrimeValidationAdmissionBoundDataV2
        let xcodeVersion: String
        let xcodeBuildVersion: String
        let sdkVersion: String
        let swiftDriverVersion: String
        let targetInfo: PrimeValidationSwiftTargetInfoObservationV2
        let orderedProbeEnvironment: [PrimeValidationEnvironmentEntry]
        let swiftPackageMappedExecutableJoined: Bool
    }

    static func directory(
        _ value: PrimeValidationSwiftPMDirectoryObservation,
        role: PrimeValidationAdmissionDirectoryRoleV2
    ) -> PrimeValidationCanonicalDirectoryObservationV2 {
        .init(
            role: role,
            requestedAbsolutePath: value.canonicalAbsolutePath,
            canonicalAbsolutePath: value.canonicalAbsolutePath,
            deviceID: value.deviceID,
            inode: value.inode,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            mode: value.permissionMode,
            linkCount: value.linkCount,
            filesystemType: value.filesystemType,
            filesystemIDWord0: value.filesystemIDWord0,
            filesystemIDWord1: value.filesystemIDWord1,
            modificationTimeSeconds: value.modificationSeconds,
            modificationTimeNanoseconds: value.modificationNanoseconds,
            statusChangeTimeSeconds: value.statusChangeSeconds,
            statusChangeTimeNanoseconds: value.statusChangeNanoseconds,
            localFilesystemObserved: value.localFilesystemObserved,
            descriptorJoined: true,
            pathIdentityJoined: true,
            noSymlinkComponentsObserved: true
        )
    }

    static func heldExecutable(
        _ file: PrimeValidationSwiftPMFileObservation,
        data: Data,
        personality: PrimeValidationSwiftPMPersonalityObservation,
        mappedExecutableJoined: Bool
    ) -> PrimeValidationHeldExecutableObservationV2 {
        .init(
            requestedAbsolutePath: personality.requestedAbsolutePath,
            canonicalAbsolutePath: file.canonicalAbsolutePath,
            requestedSymlinkTarget: personality.symbolicLinkTarget,
            content: .init(data: data),
            deviceID: file.deviceID,
            inode: file.inode,
            ownerUserID: file.ownerUserID,
            ownerGroupID: file.ownerGroupID,
            mode: file.permissionMode,
            linkCount: file.linkCount,
            fileByteCount: file.byteCount,
            modificationTimeSeconds: file.modificationSeconds,
            modificationTimeNanoseconds: file.modificationNanoseconds,
            statusChangeTimeSeconds: file.statusChangeSeconds,
            statusChangeTimeNanoseconds: file.statusChangeNanoseconds,
            mappedExecutableAbsolutePath: file.canonicalAbsolutePath,
            descriptorJoined: true,
            pathIdentityJoined: true,
            mappedExecutableJoined: mappedExecutableJoined
        )
    }

    static func validateFields(
        developerDirectory:
            PrimeValidationCanonicalDirectoryObservationV2,
        sdkRoot: PrimeValidationCanonicalDirectoryObservationV2,
        swiftExecutable: PrimeValidationHeldExecutableObservationV2,
        swiftCompilerExecutable:
            PrimeValidationHeldExecutableObservationV2,
        unmappedSwiftPackage: PrimeValidationSwiftPMFileObservation,
        swiftPersonality: PrimeValidationSwiftPMPersonalityObservation,
        swiftCompilerPersonality:
            PrimeValidationSwiftPMPersonalityObservation,
        swiftPersonalityIdentity:
            PrimeValidationDriverV2FixedProbePersonalityIdentityObservation,
        swiftCompilerPersonalityIdentity:
            PrimeValidationDriverV2FixedProbePersonalityIdentityObservation,
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
        orderedProbeEnvironment: [PrimeValidationEnvironmentEntry],
        rawToolchain: PrimeValidationSwiftPMToolchainObservation?
    ) throws {
        try developerDirectory.validate()
        try sdkRoot.validate()
        try swiftExecutable.validate()
        try swiftCompilerExecutable.validate()
        try xcodeVersionOutput.validate(maximumByteCount: 4_096)
        try sdkPathOutput.validate(maximumByteCount: 16 * 1024)
        try sdkVersionOutput.validate(maximumByteCount: 4_096)
        try swiftVersionOutput.validate(maximumByteCount: 16 * 1024)
        try swiftTargetInfoOutput.validate(maximumByteCount: 64 * 1024)
        try targetInfo.validate(
            developerDirectoryAbsolutePath:
                developerDirectory.canonicalAbsolutePath
        )
        try validateSystemFile(unmappedSwiftPackage)
        try validatePersonality(
            swiftPersonality,
            identity: swiftPersonalityIdentity,
            expectedLeaf: "swift",
            executable: swiftExecutable
        )
        try validatePersonality(
            swiftCompilerPersonality,
            identity: swiftCompilerPersonalityIdentity,
            expectedLeaf: "swiftc",
            executable: swiftCompilerExecutable
        )
        try orderedProbeEnvironment.forEach { try $0.validate() }

        let developerPath =
            "/Applications/Xcode.app/Contents/Developer"
        let binaryPath = developerPath
            + "/Toolchains/XcodeDefault.xctoolchain/usr/bin"
        let frontendPath = binaryPath + "/swift-frontend"
        let packagePath = binaryPath + "/swift-package"
        let expectedSDKPath = developerPath
            + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        let expectedSwiftVersion = Data(
            (
                "swift-driver version: \(swiftDriverVersion) "
                    + targetInfo.compilerVersion
                    + "\nTarget: \(targetInfo.triple)\n"
            ).utf8
        )
        let expectedEnvironment =
            PrimeValidationToolchainAdmissionReceiptV2.probeEnvironment(
                developerDirectory: developerPath,
                sdkRoot: expectedSDKPath
            )
        guard developerDirectory.role == .developerDirectory,
              sdkRoot.role == .sdkRoot,
              developerDirectory.canonicalAbsolutePath == developerPath,
              sdkRoot.canonicalAbsolutePath == expectedSDKPath,
              developerDirectory.ownerUserID == 0,
              developerDirectory.ownerGroupID == 0,
              sdkRoot.ownerUserID == 0,
              sdkRoot.ownerGroupID == 0,
              sdkRoot.deviceID == developerDirectory.deviceID,
              xcodeVersion == "26.6",
              xcodeBuildVersion == "17F113",
              sdkVersion == "26.5",
              swiftDriverVersion == "1.148.6",
              xcodeVersionOutput.artifact.relativePath
                == "admission/xcode_version.bin",
              sdkPathOutput.artifact.relativePath
                == "admission/sdk_path.bin",
              sdkVersionOutput.artifact.relativePath
                == "admission/sdk_version.bin",
              swiftVersionOutput.artifact.relativePath
                == "admission/swift_version.bin",
              swiftTargetInfoOutput.artifact.relativePath
                == "admission/swift_target_info.bin",
              xcodeVersionOutput.data == Data(
                "Xcode 26.6\nBuild version 17F113\n".utf8
              ),
              sdkPathOutput.data == Data((expectedSDKPath + "\n").utf8),
              sdkVersionOutput.data == Data("26.5\n".utf8),
              swiftVersionOutput.data == expectedSwiftVersion,
              try PrimeValidationSwiftTargetInfoObservationV2.parse(
                swiftTargetInfoOutput.data
              ) == targetInfo,
              swiftExecutable.requestedAbsolutePath == binaryPath + "/swift",
              swiftCompilerExecutable.requestedAbsolutePath
                == binaryPath + "/swiftc",
              swiftExecutable.canonicalAbsolutePath == frontendPath,
              swiftCompilerExecutable.canonicalAbsolutePath == frontendPath,
              swiftExecutable.content == swiftCompilerExecutable.content,
              swiftExecutable.deviceID == swiftCompilerExecutable.deviceID,
              swiftExecutable.inode == swiftCompilerExecutable.inode,
              unmappedSwiftPackage.canonicalAbsolutePath == packagePath,
              unmappedSwiftPackage.ownerUserID == 0,
              unmappedSwiftPackage.ownerGroupID == 0,
              orderedProbeEnvironment == expectedEnvironment
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "partial_toolchain"
            )
        }
        if let rawToolchain {
            guard rawToolchain.developerDirectory.canonicalAbsolutePath
                    == developerPath,
                  rawToolchain.sdkRoot.canonicalAbsolutePath
                    == expectedSDKPath,
                  rawToolchain.swiftPackageExecutable
                    == unmappedSwiftPackage,
                  rawToolchain.xcodeVersion == xcodeVersion,
                  rawToolchain.xcodeBuildVersion == xcodeBuildVersion,
                  rawToolchain.sdkCanonicalName == "macosx" + sdkVersion,
                  rawToolchain.swiftVersionProcessObservationMissing,
                  rawToolchain.swiftTargetInfoProcessObservationMissing
            else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    "partial_toolchain_raw_join"
                )
            }
        }
    }

    static func validateSystemFile(
        _ value: PrimeValidationSwiftPMFileObservation
    ) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            value.canonicalAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSHA256(value.sha256)
        guard value.deviceID > 0,
              value.inode > 0,
              value.ownerUserID == 0,
              value.ownerGroupID == 0,
              value.permissionMode & 0o111 != 0,
              value.permissionMode & 0o022 == 0,
              value.linkCount == 1,
              value.byteCount > 0,
              value.modificationSeconds >= 0,
              value.modificationNanoseconds >= 0,
              value.modificationNanoseconds < 1_000_000_000,
              value.statusChangeSeconds >= 0,
              value.statusChangeNanoseconds >= 0,
              value.statusChangeNanoseconds < 1_000_000_000
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                value.canonicalAbsolutePath
            )
        }
    }

    static func validatePersonality(
        _ value: PrimeValidationSwiftPMPersonalityObservation,
        identity:
            PrimeValidationDriverV2FixedProbePersonalityIdentityObservation,
        expectedLeaf: String,
        executable: PrimeValidationHeldExecutableObservationV2
    ) throws {
        let prefix = String(
            executable.canonicalAbsolutePath
                .dropLast("swift-frontend".count)
        )
        guard value.requestedAbsolutePath == prefix + expectedLeaf,
              value.symbolicLinkTarget == "swift-frontend",
              value.canonicalExecutableAbsolutePath
                == executable.canonicalAbsolutePath,
              identity.deviceID == executable.deviceID,
              identity.inode > 0,
              identity.ownerUserID == 0,
              identity.ownerGroupID == 0,
              identity.mode & UInt32(S_IFMT) == UInt32(S_IFLNK),
              identity.mode & 0o777 == 0o777,
              identity.linkCount == 1,
              identity.byteCount == Int64("swift-frontend".utf8.count),
              identity.modificationSeconds >= 0,
              identity.modificationNanoseconds >= 0,
              identity.modificationNanoseconds < 1_000_000_000,
              identity.statusChangeSeconds >= 0,
              identity.statusChangeNanoseconds >= 0,
              identity.statusChangeNanoseconds < 1_000_000_000
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(expectedLeaf)
        }
    }

    static func parseXcodeVersion(
        _ data: Data
    ) throws -> (version: String, build: String) {
        guard let value = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
        let version = value["CFBundleShortVersionString"] as? String,
        let build = value["ProductBuildVersion"] as? String,
        version == "26.6",
        build == "17F113"
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "xcode_version_plist"
            )
        }
        return (version, build)
    }

    static func parseSDKCanonicalName(_ data: Data) throws -> String {
        guard let value = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
        let name = value["CanonicalName"] as? String,
        name == "macosx26.5"
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "sdk_settings_plist"
            )
        }
        return name
    }

    static func validateTargetInfoFraming(_ data: Data) throws {
        guard !data.isEmpty,
              data.first == 0x7b,
              !data.contains(0),
              !data.contains(0x0d),
              (data.last == 0x7d
                || (data.last == 0x0a
                    && data.dropLast().last == 0x7d))
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "swift_target_info_framing"
            )
        }
    }
}

/// The first semantically bound fixed-process capability. Its stored lifetime
/// is the only authority; none of the copied observations can reconstruct it.
package final class PrimeValidationDriverV2FixedProbeBinding:
    @unchecked Sendable
{
    package static let exactMissingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority] = [
            .swiftPMBuildExecution,
            .artifactStaging,
            .xctestInventoryExecution,
            .swiftTestingInventoryExecution,
        ]

    package let repositoryReceipt:
        PrimeValidationRepositoryAdmissionReceiptV2
    package let trackedTreeBinding:
        PrimeValidationRepositoryTrackedTreeBindingV2
    package let partialToolchain:
        PrimeValidationDriverV2PartialToolchainProbeBinding
    package let missingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority]
    package let intentIdentitySHA256: String
    package let supervisorExecutableIdentitySHA256: String
    package let semanticBindingIdentitySHA256: String

    private let intent: PrimeValidationRunIntentV2
    private let supervisorExecutable:
        PrimeValidationHeldExecutableObservationV2
    private let rawObservation:
        PrimeValidationDriverV2FixedProbeRawObservation
    private let consumedSupervisorImage:
        PrimeValidationDriverV2SupervisorImageCapability
    private let consumedFacade: PrimeValidationDriverV2RoleFacade
    private let boundLifetime:
        PrimeValidationDriverV2FixedProbeBoundLifetime

    fileprivate init(
        intent: PrimeValidationRunIntentV2,
        supervisorExecutable:
            PrimeValidationHeldExecutableObservationV2,
        repositoryReceipt:
            PrimeValidationRepositoryAdmissionReceiptV2,
        trackedTreeBinding:
            PrimeValidationRepositoryTrackedTreeBindingV2,
        partialToolchain:
            PrimeValidationDriverV2PartialToolchainProbeBinding,
        rawObservation:
            PrimeValidationDriverV2FixedProbeRawObservation,
        consumedSupervisorImage:
            PrimeValidationDriverV2SupervisorImageCapability,
        consumedFacade: PrimeValidationDriverV2RoleFacade,
        boundLifetime:
            PrimeValidationDriverV2FixedProbeBoundLifetime,
        intentIdentitySHA256: String,
        supervisorExecutableIdentitySHA256: String,
        semanticBindingIdentitySHA256: String
    ) {
        self.intent = intent
        self.supervisorExecutable = supervisorExecutable
        self.repositoryReceipt = repositoryReceipt
        self.trackedTreeBinding = trackedTreeBinding
        self.partialToolchain = partialToolchain
        self.rawObservation = rawObservation
        self.consumedSupervisorImage = consumedSupervisorImage
        self.consumedFacade = consumedFacade
        self.boundLifetime = boundLifetime
        missingAuthorities = Self.exactMissingAuthorities
        self.intentIdentitySHA256 = intentIdentitySHA256
        self.supervisorExecutableIdentitySHA256 =
            supervisorExecutableIdentitySHA256
        self.semanticBindingIdentitySHA256 = semanticBindingIdentitySHA256
    }

    package func revalidate() throws {
        try intent.validate()
        try supervisorExecutable.validate()
        try repositoryReceipt.validate(intent: intent)
        try trackedTreeBinding.validate(
            receipt: repositoryReceipt,
            intent: intent
        )
        try partialToolchain.validate()
        guard intentIdentitySHA256 == (try intent.identitySHA256()),
              supervisorExecutableIdentitySHA256
                == (try supervisorExecutable.identitySHA256()),
              repositoryReceipt.repositoryHEADOutput.artifact.relativePath
                == "admission/repository_head.bin",
              repositoryReceipt.repositoryStatusOutput.artifact.relativePath
                == "admission/repository_status.bin",
              repositoryReceipt.companionHEADOutput.artifact.relativePath
                == "admission/companion_head.bin",
              repositoryReceipt.companionStatusOutput.artifact.relativePath
                == "admission/companion_status.bin",
              semanticBindingIdentitySHA256 == (try Self.semanticIdentity(
                intentIdentitySHA256: intentIdentitySHA256,
                supervisorExecutableIdentitySHA256:
                    supervisorExecutableIdentitySHA256,
                repositoryReceiptIdentitySHA256:
                    repositoryReceipt.identitySHA256(intent: intent),
                repositoryManifestSHA256:
                    trackedTreeBinding.repositoryManifest.sha256,
                companionManifestSHA256:
                    trackedTreeBinding.companionManifest.sha256,
                partialToolchainIdentitySHA256:
                    partialToolchain.identitySHA256
              )),
              missingAuthorities == Self.exactMissingAuthorities,
              rawObservation.productionSupervisorImageEligible,
              boundLifetime.productionSupervisorImageEligible,
              rawObservation.combinedSourceWatcherDescriptorCount == 2_232,
              boundLifetime.combinedSourceWatcherDescriptorCount == 2_232,
              rawObservation.supervisorProcessIdentifier > 0,
              rawObservation.supervisorSessionIdentifier
                == rawObservation.supervisorProcessIdentifier,
              rawObservation.supervisorProcessGroupIdentifier
                == rawObservation.supervisorProcessIdentifier,
              rawObservation.orderedProcesses.count == 16,
              Set(rawObservation.orderedProcesses.map(\.processIdentifier))
                .count == 16,
              Set(
                  rawObservation.orderedProcesses.map(
                      \.processGroupIdentifier
                  )
              ).count == 16,
              rawObservation.orderedProcesses.allSatisfy({ value in
                  value.processIdentifier > 0
                    && value.processIdentifier
                        != rawObservation.supervisorProcessIdentifier
                    && value.sessionIdentifier
                        == rawObservation.supervisorSessionIdentifier
                    && value.processGroupIdentifier
                        == value.processIdentifier
              }),
              consumedSupervisorImage.authorityCeiling
                == .fixedRoleFacadeTransferredNoAuthority
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        // This is intentionally the final operation. It is the retained
        // owner and the deadline/continuity accept after all semantic work.
        withExtendedLifetime(consumedFacade) {}
        try boundLifetime.revalidateContinuity()
    }

    fileprivate static func semanticIdentity(
        intentIdentitySHA256: String,
        supervisorExecutableIdentitySHA256: String,
        repositoryReceiptIdentitySHA256: String,
        repositoryManifestSHA256: String,
        companionManifestSHA256: String,
        partialToolchainIdentitySHA256: String
    ) throws -> String {
        try PrimeValidationDriverV2Validation.identity(
            SemanticIdentityProjection(
                intentIdentitySHA256: intentIdentitySHA256,
                supervisorExecutableIdentitySHA256:
                    supervisorExecutableIdentitySHA256,
                repositoryReceiptIdentitySHA256:
                    repositoryReceiptIdentitySHA256,
                repositoryManifestSHA256: repositoryManifestSHA256,
                companionManifestSHA256: companionManifestSHA256,
                partialToolchainIdentitySHA256:
                    partialToolchainIdentitySHA256,
                missingAuthorities:
                    exactMissingAuthorities.map(\.rawValue)
            )
        )
    }

    private struct SemanticIdentityProjection: Codable {
        let intentIdentitySHA256: String
        let supervisorExecutableIdentitySHA256: String
        let repositoryReceiptIdentitySHA256: String
        let repositoryManifestSHA256: String
        let companionManifestSHA256: String
        let partialToolchainIdentitySHA256: String
        let missingAuthorities: [String]
    }
}

/// Descriptor-free identity copied from a leaf already held by the outer
/// governor. This value cannot open, retain, or recover the vnode.
package struct PrimeValidationDriverV2FixedProbeJournalVnodeV2:
    Equatable,
    Sendable
{
    package let deviceID: UInt64
    package let inode: UInt64

    package init(deviceID: UInt64, inode: UInt64) {
        self.deviceID = deviceID
        self.inode = inode
    }
}

/// Exact durable bytes and descriptor-derived identity for one frozen Gate E
/// journal leaf. `framedBytes` includes the journal's single trailing LF.
package struct PrimeValidationDriverV2FixedProbeJournalLeafFrameV2:
    Equatable,
    Sendable
{
    package let leaf: String
    package let framedBytes: Data
    package let vnode: PrimeValidationDriverV2FixedProbeJournalVnodeV2

    package init(
        leaf: String,
        framedBytes: Data,
        vnode: PrimeValidationDriverV2FixedProbeJournalVnodeV2
    ) {
        self.leaf = leaf
        self.framedBytes = framedBytes
        self.vnode = vnode
    }
}

/// Exact wait facts copied from the governor's sole wait of the dedicated
/// supervisor. This is evidence only; it cannot wait, signal, or reap.
package struct PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2:
    Equatable,
    Sendable
{
    package let requestedProcessIdentifier: Int32
    package let returnedProcessIdentifier: Int32
    package let waitOptions: Int32
    package let rawWaitStatus: Int32
    package let returnedAtUptimeNanoseconds: UInt64
    package let exitedNormally: Bool
    package let exitStatus: Int32
    package let terminationSignal: Int32
    package let coreDumped: Bool

    package init(
        requestedProcessIdentifier: Int32,
        returnedProcessIdentifier: Int32,
        waitOptions: Int32,
        rawWaitStatus: Int32,
        returnedAtUptimeNanoseconds: UInt64,
        exitedNormally: Bool,
        exitStatus: Int32,
        terminationSignal: Int32,
        coreDumped: Bool
    ) {
        self.requestedProcessIdentifier = requestedProcessIdentifier
        self.returnedProcessIdentifier = returnedProcessIdentifier
        self.waitOptions = waitOptions
        self.rawWaitStatus = rawWaitStatus
        self.returnedAtUptimeNanoseconds = returnedAtUptimeNanoseconds
        self.exitedNormally = exitedNormally
        self.exitStatus = exitStatus
        self.terminationSignal = terminationSignal
        self.coreDumped = coreDumped
    }
}

/// Closed value expectations copied from the admitted capsule and the
/// governor's already-held roots and images. No string in this value is ever
/// opened by DriverCore.
package struct PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2:
    Sendable
{
    package let intent: PrimeValidationRunIntentV2
    package let repositoryCommit: String
    package let sourceIdentitySHA256: String
    package let journalRoot: PrimeValidationDirectoryBindingV2
    package let leaseRoot: PrimeValidationDirectoryBindingV2
    package let gitExecutable: PrimeValidationExecutableBindingV2
    package let swiftFrontendExecutable:
        PrimeValidationExecutableBindingV2
    package let supervisorExecutableVnode:
        PrimeValidationDriverV2FixedProbeJournalVnodeV2
    package let gitExecutableVnode:
        PrimeValidationDriverV2FixedProbeJournalVnodeV2
    package let swiftFrontendExecutableVnode:
        PrimeValidationDriverV2FixedProbeJournalVnodeV2
    package let supervisorProcessIdentifier: Int32
    package let outerDeadlineStartedAtUptimeNanoseconds: UInt64
    package let outerDeadlineExpiresAtUptimeNanoseconds: UInt64

    package init(
        intent: PrimeValidationRunIntentV2,
        repositoryCommit: String,
        sourceIdentitySHA256: String,
        journalRoot: PrimeValidationDirectoryBindingV2,
        leaseRoot: PrimeValidationDirectoryBindingV2,
        gitExecutable: PrimeValidationExecutableBindingV2,
        swiftFrontendExecutable: PrimeValidationExecutableBindingV2,
        supervisorExecutableVnode:
            PrimeValidationDriverV2FixedProbeJournalVnodeV2,
        gitExecutableVnode:
            PrimeValidationDriverV2FixedProbeJournalVnodeV2,
        swiftFrontendExecutableVnode:
            PrimeValidationDriverV2FixedProbeJournalVnodeV2,
        supervisorProcessIdentifier: Int32,
        outerDeadlineStartedAtUptimeNanoseconds: UInt64,
        outerDeadlineExpiresAtUptimeNanoseconds: UInt64
    ) {
        self.intent = intent
        self.repositoryCommit = repositoryCommit
        self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.journalRoot = journalRoot
        self.leaseRoot = leaseRoot
        self.gitExecutable = gitExecutable
        self.swiftFrontendExecutable = swiftFrontendExecutable
        self.supervisorExecutableVnode = supervisorExecutableVnode
        self.gitExecutableVnode = gitExecutableVnode
        self.swiftFrontendExecutableVnode = swiftFrontendExecutableVnode
        self.supervisorProcessIdentifier = supervisorProcessIdentifier
        self.outerDeadlineStartedAtUptimeNanoseconds =
            outerDeadlineStartedAtUptimeNanoseconds
        self.outerDeadlineExpiresAtUptimeNanoseconds =
            outerDeadlineExpiresAtUptimeNanoseconds
    }
}

/// Deterministic, value-only proof that the complete durable journal agrees
/// with the fixed DriverCore policy and the exact successful supervisor wait.
/// Its initializer is not visible outside this file, so copied observations
/// cannot manufacture a validated receipt.
package struct PrimeValidationDriverV2FixedProbeDurableJournalReceiptV2:
    Equatable,
    Sendable
{
    package let identitySHA256: String
    package let orderedLeafSHA256Values: [String]
    package let orderedLeafVnodes:
        [PrimeValidationDriverV2FixedProbeJournalVnodeV2]
    package let supervisorProcessIdentifier: Int32
    package let orderedChildProcessIdentifiers: [Int32]
    package let orderedChildProcessGroupIdentifiers: [Int32]
    package let rawTerminalSHA256: String

    fileprivate init(
        identitySHA256: String,
        orderedLeafSHA256Values: [String],
        orderedLeafVnodes:
            [PrimeValidationDriverV2FixedProbeJournalVnodeV2],
        supervisorProcessIdentifier: Int32,
        orderedChildProcessIdentifiers: [Int32],
        orderedChildProcessGroupIdentifiers: [Int32],
        rawTerminalSHA256: String
    ) {
        self.identitySHA256 = identitySHA256
        self.orderedLeafSHA256Values = orderedLeafSHA256Values
        self.orderedLeafVnodes = orderedLeafVnodes
        self.supervisorProcessIdentifier = supervisorProcessIdentifier
        self.orderedChildProcessIdentifiers =
            orderedChildProcessIdentifiers
        self.orderedChildProcessGroupIdentifiers =
            orderedChildProcessGroupIdentifiers
        self.rawTerminalSHA256 = rawTerminalSHA256
    }
}

/// A fixed Gate E reader, not a second execution or semantic-binding owner.
/// It opens no paths and consumes no PrimeCore raw capability.
package enum PrimeValidationDriverV2FixedProbeDurableJournalValidatorV2 {
    package static func validate(
        orderedLeaves:
            [PrimeValidationDriverV2FixedProbeJournalLeafFrameV2],
        expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2,
        supervisorExit:
            PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2
    ) throws -> PrimeValidationDriverV2FixedProbeDurableJournalReceiptV2 {
        try PrimeValidationDriverV2FixedProbeSemanticValidator
            .validateDurableJournal(
                orderedLeaves: orderedLeaves,
                expectation: expectation,
                supervisorExit: supervisorExit
            )
    }
}

/// DriverCore is the sole semantic consumer of the PrimeCore raw owner. The
/// facade transition itself remains zero-argument; the intent is used only
/// after the raw sequence returns, to bind those observations to Driver V2.
@available(macOS 26.0, *)
package enum PrimeValidationDriverV2FixedProbeBindingBridge {
    package static func bind(
        intent: PrimeValidationRunIntentV2,
        supervisorImage:
            PrimeValidationDriverV2SupervisorImageCapability
    ) throws -> PrimeValidationDriverV2FixedProbeBinding {
        try intent.validate()
        try supervisorImage.revalidate()
        let supervisorExecutable = supervisorImage.supervisorExecutable
        let facade = try supervisorImage.consumeFixedRoleFacade()
        let raw = try facade.observeFixedGitAndSwiftProbes()
        var transferred = false
        defer {
            if !transferred {
                raw.rejectValidatedBindingLifetime()
            }
        }

        let bindingStartedAt = DispatchTime.now().uptimeNanoseconds
        guard bindingStartedAt >= raw.observation
                .executorTerminalUptimeNanoseconds,
              bindingStartedAt
                <= raw.observation.deadlineExpiresAtUptimeNanoseconds
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        let values = try PrimeValidationDriverV2FixedProbeSemanticValidator
            .validateAndBind(
                intent: intent,
                supervisorExecutable: supervisorExecutable,
                raw: raw.observation
            )
        let intentIdentitySHA256 = try intent.identitySHA256()
        let supervisorExecutableIdentitySHA256 =
            try supervisorExecutable.identitySHA256()
        let semanticBindingIdentitySHA256 = try
            PrimeValidationDriverV2FixedProbeBinding.semanticIdentity(
                intentIdentitySHA256: intentIdentitySHA256,
                supervisorExecutableIdentitySHA256:
                    supervisorExecutableIdentitySHA256,
                repositoryReceiptIdentitySHA256:
                    values.repositoryReceipt.identitySHA256(intent: intent),
                repositoryManifestSHA256:
                    values.trackedTreeBinding.repositoryManifest.sha256,
                companionManifestSHA256:
                    values.trackedTreeBinding.companionManifest.sha256,
                partialToolchainIdentitySHA256:
                    values.partialToolchain.identitySHA256
            )
        let bindingFinishedAt = DispatchTime.now().uptimeNanoseconds
        guard bindingFinishedAt >= bindingStartedAt,
              bindingFinishedAt
                <= raw.observation.deadlineExpiresAtUptimeNanoseconds
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        let boundLifetime = try raw.consumeValidatedBindingLifetime()
        transferred = true
        return PrimeValidationDriverV2FixedProbeBinding(
            intent: intent,
            supervisorExecutable: supervisorExecutable,
            repositoryReceipt: values.repositoryReceipt,
            trackedTreeBinding: values.trackedTreeBinding,
            partialToolchain: values.partialToolchain,
            rawObservation: raw.observation,
            consumedSupervisorImage: supervisorImage,
            consumedFacade: facade,
            boundLifetime: boundLifetime,
            intentIdentitySHA256: intentIdentitySHA256,
            supervisorExecutableIdentitySHA256:
                supervisorExecutableIdentitySHA256,
            semanticBindingIdentitySHA256: semanticBindingIdentitySHA256
        )
    }
}

private enum PrimeValidationDriverV2FixedProbeSemanticValidator {
    struct Values {
        let repositoryReceipt:
            PrimeValidationRepositoryAdmissionReceiptV2
        let trackedTreeBinding:
            PrimeValidationRepositoryTrackedTreeBindingV2
        let partialToolchain:
            PrimeValidationDriverV2PartialToolchainProbeBinding
    }

    /// Primitive-only facts frozen from one live process observation. Neither
    /// this projection nor its validator can retain or manufacture a process,
    /// descriptor, path loader, command, binding, or lifetime authority.
    struct ProcessProjection {
        var orderedRoleMatches: Bool
        var roleMatches: Bool
        var ordinalMatches: Bool
        var logicalArgumentZeroMatches: Bool
        var argumentsMatch: Bool
        var orderedEnvironmentMatches: Bool
        var workingDirectoryMatches: Bool
        var executableImageMatches: Bool
        var standardOutputWithinCap: Bool
        var standardErrorEmpty: Bool
        var processIdentifierPositive: Bool
        var processIdentifierDiffersFromSupervisor: Bool
        var processIdentifierUnique: Bool
        var spawnFlagsMatch: Bool
        var spawnReturnCodeMatches: Bool
        var spawnAfterDeadlineStart: Bool
        var spawnAfterPredecessorTerminal: Bool
        var spawnBeforeStartPublication: Bool
        var sessionIdentifierMatches: Bool
        var processGroupIdentifierMatches: Bool
        var processGroupIdentifierUnique: Bool
        var suspendedWorkingDirectoryDeviceMatches: Bool
        var suspendedWorkingDirectoryInodeMatches: Bool
        var exactSuspendedWorkingDirectoryJoin: Bool
        var deathObserved: Bool
        var deathAfterResume: Bool
        var preReapProcessGroupMembersMatch: Bool
        var startAfterSpawn: Bool
        var startBeforeResume: Bool
        var preResumeCheckpointAfterStartPublication: Bool
        var preResumeCheckpointBeforeResume: Bool
        var preResumeCheckpointWithinDeadline: Bool
        var resumeAfterDeadlineStart: Bool
        var resumeBeforeDeadlineExpiry: Bool
        var startDurableBeforeResume: Bool
        var mappedImageJoined: Bool
        var requestedWaitProcessIdentifierMatches: Bool
        var returnedWaitProcessIdentifierMatches: Bool
        var waitOptionsMatch: Bool
        var rawWaitStatusMatches: Bool
        var waitAfterDeath: Bool
        var waitBeforeDeadlineExpiry: Bool
        var waitBeforeExecutorTerminal: Bool
        var exitedNormally: Bool
        var exitStatusMatches: Bool
        var terminationSignalMatches: Bool
        var coreDumpedIsFalse: Bool
        var standardOutputReachedEOF: Bool
        var standardOutputTotalByteCountMatches: Bool
        var standardOutputTerminalReasonMatches: Bool
        var standardOutputOverflowedIsFalse: Bool
        var standardOutputWorkerFinished: Bool
        var standardOutputReadErrorNumberMatches: Bool
        var standardOutputWriteErrorNumberMatches: Bool
        var standardOutputFinalizationErrorNumberMatches: Bool
        var standardOutputCloseErrorNumberMatches: Bool
        var standardOutputDescriptorsClosed: Bool
        var standardErrorReachedEOF: Bool
        var standardErrorTotalByteCountMatches: Bool
        var standardErrorTerminalReasonMatches: Bool
        var standardErrorOverflowedIsFalse: Bool
        var standardErrorWorkerFinished: Bool
        var standardErrorReadErrorNumberMatches: Bool
        var standardErrorWriteErrorNumberMatches: Bool
        var standardErrorFinalizationErrorNumberMatches: Bool
        var standardErrorCloseErrorNumberMatches: Bool
        var standardErrorDescriptorsClosed: Bool
        var processGroupEmptyAfterReap: Bool
        var terminalAfterWait: Bool
        var terminalBeforeDeadlineExpiry: Bool
    }

    struct ProcessProjectionMutation {
        let fact: String
        let keyPath: WritableKeyPath<ProcessProjection, Bool>
    }

    private static let roles: [PrimeValidationDriverV2FixedProbeRole] = [
        .primeHeadPre,
        .primeObjectFormat,
        .primeStatusPre,
        .primeTreeDiscovery,
        .primeTreeReplay,
        .primeStatusPost,
        .primeHeadPost,
        .companionHeadPre,
        .companionObjectFormat,
        .companionStatusPre,
        .companionTreeDiscovery,
        .companionTreeReplay,
        .companionStatusPost,
        .companionHeadPost,
        .swiftVersion,
        .swiftTargetInfo,
    ]
    private static let gitPrefix = [
        "--no-pager",
        "--no-optional-locks",
        "--no-replace-objects",
        "--no-lazy-fetch",
        "--literal-pathspecs",
        "--git-dir=.git",
        "--work-tree=.",
        "-c", "core.fsmonitor=false",
        "-c", "core.untrackedCache=false",
        "-c", "submodule.recurse=false",
        "-c", "core.hooksPath=/dev/null",
    ]
    private static let primePathspecs = [
        ".gitignore",
        ".swiftpm/configuration/mirrors.json",
        "LICENSE",
        "Package.resolved",
        "Package.swift",
        "README.md",
        "Sources",
        "THIRD_PARTY_NOTICES.md",
        "Tests",
        "docs",
    ]
    private static let statusArguments = [
        "status", "--porcelain=v2", "-z",
        "--untracked-files=all", "--ignored=matching",
        "--ignore-submodules=none", "--no-renames",
    ]

    static func validateAndBind(
        intent: PrimeValidationRunIntentV2,
        supervisorExecutable:
            PrimeValidationHeldExecutableObservationV2,
        raw: PrimeValidationDriverV2FixedProbeRawObservation
    ) throws -> Values {
        try intent.validate()
        try supervisorExecutable.validate()
        let deadline = raw.deadlineStartedAtUptimeNanoseconds
            .addingReportingOverflow(30_000_000_000)
        guard raw.productionSupervisorImageEligible,
              raw.combinedSourceWatcherDescriptorCount == 2_232,
              raw.supervisorProcessIdentifier > 0,
              raw.supervisorSessionIdentifier
                == raw.supervisorProcessIdentifier,
              raw.supervisorProcessGroupIdentifier
                == raw.supervisorProcessIdentifier,
              raw.deadlineStartedAtUptimeNanoseconds > 0,
              !deadline.overflow,
              raw.deadlineExpiresAtUptimeNanoseconds
                == deadline.partialValue,
              raw.prestartPublishedUptimeNanoseconds
                >= raw.deadlineStartedAtUptimeNanoseconds,
              raw.rawTerminalPublishedUptimeNanoseconds
                >= raw.prestartPublishedUptimeNanoseconds,
              raw.rawTerminalPublishedUptimeNanoseconds
                <= raw.executorTerminalUptimeNanoseconds,
              raw.executorTerminalUptimeNanoseconds
                >= raw.deadlineStartedAtUptimeNanoseconds,
              raw.executorTerminalUptimeNanoseconds
                <= raw.deadlineExpiresAtUptimeNanoseconds
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try validateSupervisor(
            raw.currentProcessExecutable,
            expected: supervisorExecutable
        )
        let workspace = directory(raw.workspaceRoot, role: .workspace)
        let evidence = directory(raw.evidenceRoot, role: .evidence)
        try workspace.validate()
        try evidence.validate()
        guard workspace.canonicalAbsolutePath
                == intent.roots.workspaceRoot.absolutePath,
              workspace.deviceID == intent.roots.workspaceRoot.deviceID,
              workspace.inode == intent.roots.workspaceRoot.inode,
              workspace.ownerUserID
                == intent.roots.workspaceRoot.ownerUserID,
              workspace.mode == intent.roots.workspaceRoot.mode,
              workspace.linkCount == 2,
              evidence.canonicalAbsolutePath
                == intent.roots.evidenceRoot.absolutePath,
              evidence.deviceID == intent.roots.evidenceRoot.deviceID,
              evidence.inode == intent.roots.evidenceRoot.inode,
              evidence.ownerUserID
                == intent.roots.evidenceRoot.ownerUserID,
              evidence.mode == intent.roots.evidenceRoot.mode,
              evidence.linkCount == 2
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_private_roots"
            )
        }
        try validateLeaf(raw.prestartLeaf, expected: "gate-e-prestart.json")
        try validateLeaf(
            raw.rawTerminalLeaf,
            expected: "gate-e-raw-terminal.json"
        )

        var process:
            [String: PrimeValidationDriverV2FixedProbeProcessObservation] = [:]
        for value in raw.orderedProcesses {
            guard process.updateValue(
                value,
                forKey: value.role.rawValue
            ) == nil else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    "fixed_probe_processes"
                )
            }
        }
        guard process.count == roles.count else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_processes"
            )
        }
        let primeHEAD = try parseHEAD(
            try required(process, .primeHeadPre).standardOutput
        )
        let companionHEAD = try parseHEAD(
            try required(process, .companionHeadPre).standardOutput
        )
        try validateProcesses(
            process,
            raw: raw,
            primeHEAD: primeHEAD,
            companionHEAD: companionHEAD
        )

        let primeTree = try required(process, .primeTreeReplay)
            .standardOutput
        let companionTree = try required(process, .companionTreeReplay)
            .standardOutput
        let primeManifest = try
            PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: try required(
                    process,
                    .primeObjectFormat
                ).standardOutput,
                rawTreeOutput: primeTree,
                heldEntries: raw.primeHeldEntries
            )
        let companionManifest = try
            PrimeValidationTrackedTreeManifestBuilderV2.companion(
                objectFormatOutput: try required(
                    process,
                    .companionObjectFormat
                ).standardOutput,
                rawTreeOutput: companionTree,
                heldEntries: raw.companionHeldEntries
            )
        try validateHeldSets(raw, primeManifest: primeManifest)

        let receipt = try repositoryReceipt(
            intent: intent,
            raw: raw,
            process: process,
            repositoryCommit: primeHEAD,
            companionCommit: companionHEAD,
            primeManifest: primeManifest,
            companionManifest: companionManifest
        )
        let tracked = try receipt.bindingTrackedTreeManifests(
            intent: intent,
            repositoryManifest: primeManifest,
            companionManifest: companionManifest
        )
        let partial = try
            PrimeValidationDriverV2PartialToolchainProbeBinding(
                observation: raw,
                swiftVersionOutput: try required(
                    process,
                    .swiftVersion
                ).standardOutput,
                swiftTargetInfoOutput: try required(
                    process,
                    .swiftTargetInfo
                ).standardOutput
            )
        guard partial.swiftExecutable.content == intent.swiftExecutable.content,
              partial.swiftExecutable.requestedAbsolutePath
                == intent.swiftExecutable.absolutePath,
              raw.companionDeclaration.expectedPinnedHEAD
                == PrimeValidationRunIntentV2.requiredCompanionCommit,
              raw.companionDeclaration.declaredObservedHEAD
                == intent.companionCommit,
              raw.companionDeclaration.declaredPorcelainV2Status.isEmpty,
              raw.companionDeclaration.processObservationMissing
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_intent_join"
            )
        }
        return Values(
            repositoryReceipt: receipt,
            trackedTreeBinding: tracked,
            partialToolchain: partial
        )
    }
}

/// Descriptor-free mechanics seam for focused Gate E semantic tests. It
/// cannot construct or consume the raw owner, binding, or retained lifetime.
package enum PrimeValidationDriverV2FixedProbeSemanticTestSeam {
    /// Mutates every fact of one canonical, authority-free process projection
    /// and reports whether the exact validator used by production rejected it.
    package static func processMutationMatrix() throws
        -> [(fact: String, rejected: Bool)]
    {
        let canonical = PrimeValidationDriverV2FixedProbeSemanticValidator
            .canonicalProcessProjection
        try PrimeValidationDriverV2FixedProbeSemanticValidator
            .validateProcessProjection(
                canonical,
                role: "canonical_process_projection"
            )
        return PrimeValidationDriverV2FixedProbeSemanticValidator
            .processProjectionMutations.map { mutation in
                var mutated = canonical
                mutated[keyPath: mutation.keyPath] = false
                do {
                    try PrimeValidationDriverV2FixedProbeSemanticValidator
                        .validateProcessProjection(
                            mutated,
                            role: mutation.fact
                        )
                    return (fact: mutation.fact, rejected: false)
                } catch {
                    return (fact: mutation.fact, rejected: true)
                }
            }
    }

    package static func requireRegularHeldEntryKinds(
        prime: [PrimeValidationDriverV2TrackedTreeHeldEntry],
        companion: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) throws {
        try PrimeValidationDriverV2FixedProbeSemanticValidator
            .requireRegularHeldEntryKinds(
                prime: prime,
                companion: companion
            )
    }
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static func required(
        _ values:
            [String: PrimeValidationDriverV2FixedProbeProcessObservation],
        _ role: PrimeValidationDriverV2FixedProbeRole
    ) throws -> PrimeValidationDriverV2FixedProbeProcessObservation {
        guard let value = values[role.rawValue] else {
            throw PrimeValidationDriverV2Error.invalidBinding(role.rawValue)
        }
        return value
    }

    static func parseHEAD(_ data: Data) throws -> String {
        guard data.count == 41,
              data.last == 0x0a,
              data.dropLast().allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeValidationDriverV2Error.invalidBinding("git_head")
        }
        return String(decoding: data.dropLast(), as: UTF8.self)
    }

    static func validateSupervisor(
        _ value: PrimeValidationSwiftPMFileObservation,
        expected: PrimeValidationHeldExecutableObservationV2
    ) throws {
        try validateFile(value, requiresRootOwner: false)
        guard value.canonicalAbsolutePath
                == expected.canonicalAbsolutePath,
              value.deviceID == expected.deviceID,
              value.inode == expected.inode,
              value.ownerUserID == expected.ownerUserID,
              value.ownerGroupID == expected.ownerGroupID,
              value.permissionMode == expected.mode,
              value.linkCount == expected.linkCount,
              value.byteCount == expected.fileByteCount,
              value.sha256 == expected.content.sha256,
              value.modificationSeconds
                == expected.modificationTimeSeconds,
              value.modificationNanoseconds
                == expected.modificationTimeNanoseconds,
              value.statusChangeSeconds
                == expected.statusChangeTimeSeconds,
              value.statusChangeNanoseconds
                == expected.statusChangeTimeNanoseconds
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
    }

    static func validateLeaf(
        _ value: PrimeValidationDriverV2FixedProbeJournalLeafObservation,
        expected: String
    ) throws {
        try PrimeValidationDriverV2Validation.requireSHA256(value.sha256)
        guard value.leaf == expected,
              value.byteCount > 0,
              value.byteCount <= 64 * 1024,
              value.deviceID > 0,
              value.inode > 0
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(expected)
        }
    }

    static func validateProcesses(
        _ processes:
            [String: PrimeValidationDriverV2FixedProbeProcessObservation],
        raw: PrimeValidationDriverV2FixedProbeRawObservation,
        primeHEAD: String,
        companionHEAD: String
    ) throws {
        let expectedEnvironment = [
            ("DEVELOPER_DIR",
             raw.toolchain.developerDirectory.canonicalAbsolutePath),
            ("LANG", "C"),
            ("LC_ALL", "C"),
            ("SDKROOT", raw.toolchain.sdkRoot.canonicalAbsolutePath),
            ("TERM", "dumb"),
        ]
        var journalInodes = Set<String>()
        var childProcessIdentifiers = Set<Int32>()
        var childProcessGroupIdentifiers = Set<Int32>()
        var predecessorTerminalUptime =
            raw.prestartPublishedUptimeNanoseconds
        try validateLeaf(raw.prestartLeaf, expected: "gate-e-prestart.json")
        journalInodes.insert(
            "\(raw.prestartLeaf.deviceID):\(raw.prestartLeaf.inode)"
        )
        for role in roles {
            let value = try required(processes, role)
            let expectedOrdinal = roles.firstIndex(of: role)! + 1
            let leafBase = String(format: "%02d", expectedOrdinal)
                + "-" + role.rawValue.replacingOccurrences(
                    of: "_",
                    with: "-"
                )
            let isSwift = role == .swiftVersion || role == .swiftTargetInfo
            let expectedRoot = role.rawValue.hasPrefix("companion_")
                ? raw.companionRepository : raw.primeRepository
            let expectedExecutable = isSwift
                ? raw.swiftFrontendExecutable : raw.gitExecutable
            let expectedArgumentZero = isSwift ? "swift" : "git"
            let expectedArguments = try arguments(
                role: role,
                primeHEAD: primeHEAD,
                companionHEAD: companionHEAD
            )
            let expectedOutputCap = outputCap(role)
            let processIdentifierUnique = childProcessIdentifiers.insert(
                value.processIdentifier
            ).inserted
            let processGroupIdentifierUnique =
                childProcessGroupIdentifiers.insert(
                    value.processGroupIdentifier
                ).inserted

            try validateFile(
                value.executable,
                requiresRootOwner: true
            )
            try validateLeaf(
                value.startLeaf,
                expected: leafBase + "-start.json"
            )
            try validateLeaf(
                value.terminalLeaf,
                expected: leafBase + "-terminal.json"
            )
            for leaf in [value.startLeaf, value.terminalLeaf] {
                guard leaf.deviceID == raw.prestartLeaf.deviceID,
                      journalInodes.insert(
                    "\(leaf.deviceID):\(leaf.inode)"
                      ).inserted else {
                    throw PrimeValidationDriverV2Error.invalidBinding(
                        "gate_e_journal_inode"
                    )
                }
            }
            try validateProcessProjection(
                ProcessProjection(
                    orderedRoleMatches:
                        raw.orderedProcesses[expectedOrdinal - 1].role
                            == role,
                    roleMatches: value.role == role,
                    ordinalMatches: value.ordinal == expectedOrdinal,
                    logicalArgumentZeroMatches:
                        value.logicalArgumentZero == expectedArgumentZero,
                    argumentsMatch: value.arguments == expectedArguments,
                    orderedEnvironmentMatches: environmentMatches(
                        value.orderedEnvironment,
                        expectedEnvironment
                    ),
                    workingDirectoryMatches:
                        value.workingDirectory == expectedRoot,
                    executableImageMatches:
                        value.executable == expectedExecutable,
                    standardOutputWithinCap:
                        value.standardOutput.count <= expectedOutputCap,
                    standardErrorEmpty: value.standardError.isEmpty,
                    processIdentifierPositive:
                        value.processIdentifier > 0,
                    processIdentifierDiffersFromSupervisor:
                        value.processIdentifier
                            != raw.supervisorProcessIdentifier,
                    processIdentifierUnique: processIdentifierUnique,
                    spawnFlagsMatch: value.appliedSpawnFlags == 0x408e,
                    spawnReturnCodeMatches: value.spawnReturnCode == 0,
                    spawnAfterDeadlineStart:
                        value.spawnReturnedUptimeNanoseconds
                            >= raw.deadlineStartedAtUptimeNanoseconds,
                    spawnAfterPredecessorTerminal:
                        value.spawnReturnedUptimeNanoseconds
                            >= predecessorTerminalUptime,
                    spawnBeforeStartPublication:
                        value.spawnReturnedUptimeNanoseconds
                            <= value.startPublishedUptimeNanoseconds,
                    sessionIdentifierMatches:
                        value.sessionIdentifier
                            == raw.supervisorSessionIdentifier,
                    processGroupIdentifierMatches:
                        value.processGroupIdentifier
                            == value.processIdentifier,
                    processGroupIdentifierUnique:
                        processGroupIdentifierUnique,
                    suspendedWorkingDirectoryDeviceMatches:
                        value.suspendedWorkingDirectoryDeviceID
                            == expectedRoot.deviceID,
                    suspendedWorkingDirectoryInodeMatches:
                        value.suspendedWorkingDirectoryInode
                            == expectedRoot.inode,
                    exactSuspendedWorkingDirectoryJoin:
                        value.exactSuspendedWorkingDirectoryJoin,
                    deathObserved: value.deathObserved,
                    deathAfterResume:
                        value.deathObservedUptimeNanoseconds
                            >= value.resumedAtUptimeNanoseconds,
                    preReapProcessGroupMembersMatch:
                        value.preReapProcessGroupMemberIdentifiers
                            == [value.processIdentifier],
                    startAfterSpawn:
                        value.startPublishedUptimeNanoseconds
                            >= value.spawnReturnedUptimeNanoseconds,
                    startBeforeResume:
                        value.startPublishedUptimeNanoseconds
                            <= value.resumedAtUptimeNanoseconds,
                    preResumeCheckpointAfterStartPublication:
                        value
                            .preResumeContinuityCheckpointUptimeNanoseconds
                            >= value.startPublishedUptimeNanoseconds,
                    preResumeCheckpointBeforeResume:
                        value
                            .preResumeContinuityCheckpointUptimeNanoseconds
                            <= value.resumedAtUptimeNanoseconds,
                    preResumeCheckpointWithinDeadline:
                        value
                            .preResumeContinuityCheckpointUptimeNanoseconds
                            >= raw.deadlineStartedAtUptimeNanoseconds
                            && value
                                .preResumeContinuityCheckpointUptimeNanoseconds
                            <= raw.deadlineExpiresAtUptimeNanoseconds,
                    resumeAfterDeadlineStart:
                        value.resumedAtUptimeNanoseconds
                            >= raw.deadlineStartedAtUptimeNanoseconds,
                    resumeBeforeDeadlineExpiry:
                        value.resumedAtUptimeNanoseconds
                            <= raw.deadlineExpiresAtUptimeNanoseconds,
                    startDurableBeforeResume:
                        value.startDurableBeforeResume,
                    mappedImageJoined: value.mappedImageJoined,
                    requestedWaitProcessIdentifierMatches:
                        value.requestedWaitProcessIdentifier
                            == value.processIdentifier,
                    returnedWaitProcessIdentifierMatches:
                        value.returnedWaitProcessIdentifier
                            == value.processIdentifier,
                    waitOptionsMatch: value.waitOptions == 0,
                    rawWaitStatusMatches: value.rawWaitStatus == 0,
                    waitAfterDeath:
                        value.waitReturnedUptimeNanoseconds
                            >= value.deathObservedUptimeNanoseconds,
                    waitBeforeDeadlineExpiry:
                        value.waitReturnedUptimeNanoseconds
                            <= raw.deadlineExpiresAtUptimeNanoseconds,
                    waitBeforeExecutorTerminal:
                        value.waitReturnedUptimeNanoseconds
                            <= raw.executorTerminalUptimeNanoseconds,
                    exitedNormally: value.exitedNormally,
                    exitStatusMatches: value.exitStatus == 0,
                    terminationSignalMatches:
                        value.terminationSignal == 0,
                    coreDumpedIsFalse: !value.coreDumped,
                    standardOutputReachedEOF:
                        value.standardOutputReachedEOF,
                    standardOutputTotalByteCountMatches:
                        value.standardOutputTotalByteCount
                            == UInt64(value.standardOutput.count),
                    standardOutputTerminalReasonMatches:
                        value.standardOutputTerminalReason
                            == "end_of_file",
                    standardOutputOverflowedIsFalse:
                        !value.standardOutputOverflowed,
                    standardOutputWorkerFinished:
                        value.standardOutputWorkerFinished,
                    standardOutputReadErrorNumberMatches:
                        value.standardOutputReadErrorNumber == 0,
                    standardOutputWriteErrorNumberMatches:
                        value.standardOutputWriteErrorNumber == 0,
                    standardOutputFinalizationErrorNumberMatches:
                        value.standardOutputFinalizationErrorNumber == 0,
                    standardOutputCloseErrorNumberMatches:
                        value.standardOutputCloseErrorNumber == 0,
                    standardOutputDescriptorsClosed:
                        value.standardOutputDescriptorsClosed,
                    standardErrorReachedEOF:
                        value.standardErrorReachedEOF,
                    standardErrorTotalByteCountMatches:
                        value.standardErrorTotalByteCount == 0,
                    standardErrorTerminalReasonMatches:
                        value.standardErrorTerminalReason
                            == "end_of_file",
                    standardErrorOverflowedIsFalse:
                        !value.standardErrorOverflowed,
                    standardErrorWorkerFinished:
                        value.standardErrorWorkerFinished,
                    standardErrorReadErrorNumberMatches:
                        value.standardErrorReadErrorNumber == 0,
                    standardErrorWriteErrorNumberMatches:
                        value.standardErrorWriteErrorNumber == 0,
                    standardErrorFinalizationErrorNumberMatches:
                        value.standardErrorFinalizationErrorNumber == 0,
                    standardErrorCloseErrorNumberMatches:
                        value.standardErrorCloseErrorNumber == 0,
                    standardErrorDescriptorsClosed:
                        value.standardErrorDescriptorsClosed,
                    processGroupEmptyAfterReap:
                        value.processGroupEmptyAfterReap,
                    terminalAfterWait:
                        value.terminalPublishedUptimeNanoseconds
                            >= value.waitReturnedUptimeNanoseconds,
                    terminalBeforeDeadlineExpiry:
                        value.terminalPublishedUptimeNanoseconds
                            <= raw.deadlineExpiresAtUptimeNanoseconds
                ),
                role: role.rawValue
            )
            predecessorTerminalUptime =
                value.terminalPublishedUptimeNanoseconds
        }
        guard journalInodes.insert(
            "\(raw.rawTerminalLeaf.deviceID):\(raw.rawTerminalLeaf.inode)"
        ).inserted,
        raw.rawTerminalLeaf.deviceID == raw.prestartLeaf.deviceID,
        journalInodes.count == 34,
        childProcessIdentifiers.count == 16,
        childProcessGroupIdentifiers.count == 16,
        raw.rawTerminalPublishedUptimeNanoseconds
            >= predecessorTerminalUptime
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "gate_e_journal_set"
            )
        }

        let primeHeadPost = try required(processes, .primeHeadPost)
        let companionHeadPost = try required(processes, .companionHeadPost)
        guard primeHeadPost.standardOutput
                == Data((primeHEAD + "\n").utf8),
              companionHeadPost.standardOutput
                == Data((companionHEAD + "\n").utf8),
              companionHEAD
                == PrimeValidationRunIntentV2.requiredCompanionCommit,
              try required(processes, .primeObjectFormat).standardOutput
                == Data("sha1\n".utf8),
              try required(processes, .companionObjectFormat).standardOutput
                == Data("sha1\n".utf8),
              try required(processes, .primeStatusPre).standardOutput.isEmpty,
              try required(processes, .primeStatusPost).standardOutput.isEmpty,
              try required(processes, .companionStatusPre)
                .standardOutput.isEmpty,
              try required(processes, .companionStatusPost)
                .standardOutput.isEmpty,
              try required(processes, .primeTreeDiscovery).standardOutput
                == required(processes, .primeTreeReplay).standardOutput,
              try required(processes, .companionTreeDiscovery).standardOutput
                == required(processes, .companionTreeReplay).standardOutput
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_raw_agreement"
            )
        }
    }

    static func validateProcessProjection(
        _ value: ProcessProjection,
        role: String
    ) throws {
        guard value.orderedRoleMatches,
              value.roleMatches,
              value.ordinalMatches,
              value.logicalArgumentZeroMatches,
              value.argumentsMatch,
              value.orderedEnvironmentMatches,
              value.workingDirectoryMatches,
              value.executableImageMatches,
              value.standardOutputWithinCap,
              value.standardErrorEmpty,
              value.processIdentifierPositive,
              value.processIdentifierDiffersFromSupervisor,
              value.processIdentifierUnique,
              value.spawnFlagsMatch,
              value.spawnReturnCodeMatches,
              value.spawnAfterDeadlineStart,
              value.spawnAfterPredecessorTerminal,
              value.spawnBeforeStartPublication,
              value.sessionIdentifierMatches,
              value.processGroupIdentifierMatches,
              value.processGroupIdentifierUnique,
              value.suspendedWorkingDirectoryDeviceMatches,
              value.suspendedWorkingDirectoryInodeMatches,
              value.exactSuspendedWorkingDirectoryJoin,
              value.deathObserved,
              value.deathAfterResume,
              value.preReapProcessGroupMembersMatch,
              value.startAfterSpawn,
              value.startBeforeResume,
              value.preResumeCheckpointAfterStartPublication,
              value.preResumeCheckpointBeforeResume,
              value.preResumeCheckpointWithinDeadline,
              value.resumeAfterDeadlineStart,
              value.resumeBeforeDeadlineExpiry,
              value.startDurableBeforeResume,
              value.mappedImageJoined,
              value.requestedWaitProcessIdentifierMatches,
              value.returnedWaitProcessIdentifierMatches,
              value.waitOptionsMatch,
              value.rawWaitStatusMatches,
              value.waitAfterDeath,
              value.waitBeforeDeadlineExpiry,
              value.waitBeforeExecutorTerminal,
              value.exitedNormally,
              value.exitStatusMatches,
              value.terminationSignalMatches,
              value.coreDumpedIsFalse,
              value.standardOutputReachedEOF,
              value.standardOutputTotalByteCountMatches,
              value.standardOutputTerminalReasonMatches,
              value.standardOutputOverflowedIsFalse,
              value.standardOutputWorkerFinished,
              value.standardOutputReadErrorNumberMatches,
              value.standardOutputWriteErrorNumberMatches,
              value.standardOutputFinalizationErrorNumberMatches,
              value.standardOutputCloseErrorNumberMatches,
              value.standardOutputDescriptorsClosed,
              value.standardErrorReachedEOF,
              value.standardErrorTotalByteCountMatches,
              value.standardErrorTerminalReasonMatches,
              value.standardErrorOverflowedIsFalse,
              value.standardErrorWorkerFinished,
              value.standardErrorReadErrorNumberMatches,
              value.standardErrorWriteErrorNumberMatches,
              value.standardErrorFinalizationErrorNumberMatches,
              value.standardErrorCloseErrorNumberMatches,
              value.standardErrorDescriptorsClosed,
              value.processGroupEmptyAfterReap,
              value.terminalAfterWait,
              value.terminalBeforeDeadlineExpiry
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(role)
        }
    }

    static let canonicalProcessProjection = ProcessProjection(
        orderedRoleMatches: true,
        roleMatches: true,
        ordinalMatches: true,
        logicalArgumentZeroMatches: true,
        argumentsMatch: true,
        orderedEnvironmentMatches: true,
        workingDirectoryMatches: true,
        executableImageMatches: true,
        standardOutputWithinCap: true,
        standardErrorEmpty: true,
        processIdentifierPositive: true,
        processIdentifierDiffersFromSupervisor: true,
        processIdentifierUnique: true,
        spawnFlagsMatch: true,
        spawnReturnCodeMatches: true,
        spawnAfterDeadlineStart: true,
        spawnAfterPredecessorTerminal: true,
        spawnBeforeStartPublication: true,
        sessionIdentifierMatches: true,
        processGroupIdentifierMatches: true,
        processGroupIdentifierUnique: true,
        suspendedWorkingDirectoryDeviceMatches: true,
        suspendedWorkingDirectoryInodeMatches: true,
        exactSuspendedWorkingDirectoryJoin: true,
        deathObserved: true,
        deathAfterResume: true,
        preReapProcessGroupMembersMatch: true,
        startAfterSpawn: true,
        startBeforeResume: true,
        preResumeCheckpointAfterStartPublication: true,
        preResumeCheckpointBeforeResume: true,
        preResumeCheckpointWithinDeadline: true,
        resumeAfterDeadlineStart: true,
        resumeBeforeDeadlineExpiry: true,
        startDurableBeforeResume: true,
        mappedImageJoined: true,
        requestedWaitProcessIdentifierMatches: true,
        returnedWaitProcessIdentifierMatches: true,
        waitOptionsMatch: true,
        rawWaitStatusMatches: true,
        waitAfterDeath: true,
        waitBeforeDeadlineExpiry: true,
        waitBeforeExecutorTerminal: true,
        exitedNormally: true,
        exitStatusMatches: true,
        terminationSignalMatches: true,
        coreDumpedIsFalse: true,
        standardOutputReachedEOF: true,
        standardOutputTotalByteCountMatches: true,
        standardOutputTerminalReasonMatches: true,
        standardOutputOverflowedIsFalse: true,
        standardOutputWorkerFinished: true,
        standardOutputReadErrorNumberMatches: true,
        standardOutputWriteErrorNumberMatches: true,
        standardOutputFinalizationErrorNumberMatches: true,
        standardOutputCloseErrorNumberMatches: true,
        standardOutputDescriptorsClosed: true,
        standardErrorReachedEOF: true,
        standardErrorTotalByteCountMatches: true,
        standardErrorTerminalReasonMatches: true,
        standardErrorOverflowedIsFalse: true,
        standardErrorWorkerFinished: true,
        standardErrorReadErrorNumberMatches: true,
        standardErrorWriteErrorNumberMatches: true,
        standardErrorFinalizationErrorNumberMatches: true,
        standardErrorCloseErrorNumberMatches: true,
        standardErrorDescriptorsClosed: true,
        processGroupEmptyAfterReap: true,
        terminalAfterWait: true,
        terminalBeforeDeadlineExpiry: true
    )

    static let processProjectionMutations: [ProcessProjectionMutation] = [
        .init(fact: "ordered_role", keyPath: \.orderedRoleMatches),
        .init(fact: "role", keyPath: \.roleMatches),
        .init(fact: "ordinal", keyPath: \.ordinalMatches),
        .init(
            fact: "logical_argument_zero",
            keyPath: \.logicalArgumentZeroMatches
        ),
        .init(fact: "arguments", keyPath: \.argumentsMatch),
        .init(
            fact: "ordered_environment",
            keyPath: \.orderedEnvironmentMatches
        ),
        .init(
            fact: "working_directory",
            keyPath: \.workingDirectoryMatches
        ),
        .init(
            fact: "executable_image",
            keyPath: \.executableImageMatches
        ),
        .init(
            fact: "standard_output_cap",
            keyPath: \.standardOutputWithinCap
        ),
        .init(fact: "standard_error_empty", keyPath: \.standardErrorEmpty),
        .init(
            fact: "process_identifier",
            keyPath: \.processIdentifierPositive
        ),
        .init(
            fact: "process_identifier_differs_from_supervisor",
            keyPath: \.processIdentifierDiffersFromSupervisor
        ),
        .init(
            fact: "process_identifier_unique",
            keyPath: \.processIdentifierUnique
        ),
        .init(fact: "spawn_flags", keyPath: \.spawnFlagsMatch),
        .init(
            fact: "spawn_return_code",
            keyPath: \.spawnReturnCodeMatches
        ),
        .init(
            fact: "spawn_after_deadline_start",
            keyPath: \.spawnAfterDeadlineStart
        ),
        .init(
            fact: "spawn_after_predecessor_terminal",
            keyPath: \.spawnAfterPredecessorTerminal
        ),
        .init(
            fact: "spawn_before_start_publication",
            keyPath: \.spawnBeforeStartPublication
        ),
        .init(
            fact: "session_identifier",
            keyPath: \.sessionIdentifierMatches
        ),
        .init(
            fact: "process_group_identifier",
            keyPath: \.processGroupIdentifierMatches
        ),
        .init(
            fact: "process_group_identifier_unique",
            keyPath: \.processGroupIdentifierUnique
        ),
        .init(
            fact: "suspended_working_directory_device",
            keyPath: \.suspendedWorkingDirectoryDeviceMatches
        ),
        .init(
            fact: "suspended_working_directory_inode",
            keyPath: \.suspendedWorkingDirectoryInodeMatches
        ),
        .init(
            fact: "exact_suspended_working_directory_join",
            keyPath: \.exactSuspendedWorkingDirectoryJoin
        ),
        .init(fact: "death_observed", keyPath: \.deathObserved),
        .init(fact: "death_after_resume", keyPath: \.deathAfterResume),
        .init(
            fact: "pre_reap_process_group_members",
            keyPath: \.preReapProcessGroupMembersMatch
        ),
        .init(fact: "start_after_spawn", keyPath: \.startAfterSpawn),
        .init(fact: "start_before_resume", keyPath: \.startBeforeResume),
        .init(
            fact: "pre_resume_checkpoint_after_start_publication",
            keyPath: \.preResumeCheckpointAfterStartPublication
        ),
        .init(
            fact: "pre_resume_checkpoint_before_resume",
            keyPath: \.preResumeCheckpointBeforeResume
        ),
        .init(
            fact: "pre_resume_checkpoint_within_deadline",
            keyPath: \.preResumeCheckpointWithinDeadline
        ),
        .init(
            fact: "resume_after_deadline_start",
            keyPath: \.resumeAfterDeadlineStart
        ),
        .init(
            fact: "resume_before_deadline_expiry",
            keyPath: \.resumeBeforeDeadlineExpiry
        ),
        .init(
            fact: "start_durable_before_resume",
            keyPath: \.startDurableBeforeResume
        ),
        .init(fact: "mapped_image_joined", keyPath: \.mappedImageJoined),
        .init(
            fact: "requested_wait_process_identifier",
            keyPath: \.requestedWaitProcessIdentifierMatches
        ),
        .init(
            fact: "returned_wait_process_identifier",
            keyPath: \.returnedWaitProcessIdentifierMatches
        ),
        .init(fact: "wait_options", keyPath: \.waitOptionsMatch),
        .init(fact: "raw_wait_status", keyPath: \.rawWaitStatusMatches),
        .init(fact: "wait_after_death", keyPath: \.waitAfterDeath),
        .init(
            fact: "wait_before_deadline_expiry",
            keyPath: \.waitBeforeDeadlineExpiry
        ),
        .init(
            fact: "wait_before_executor_terminal",
            keyPath: \.waitBeforeExecutorTerminal
        ),
        .init(fact: "exited_normally", keyPath: \.exitedNormally),
        .init(fact: "exit_status", keyPath: \.exitStatusMatches),
        .init(
            fact: "termination_signal",
            keyPath: \.terminationSignalMatches
        ),
        .init(fact: "core_dumped", keyPath: \.coreDumpedIsFalse),
        .init(
            fact: "standard_output_reached_eof",
            keyPath: \.standardOutputReachedEOF
        ),
        .init(
            fact: "standard_output_total_byte_count",
            keyPath: \.standardOutputTotalByteCountMatches
        ),
        .init(
            fact: "standard_output_terminal_reason",
            keyPath: \.standardOutputTerminalReasonMatches
        ),
        .init(
            fact: "standard_output_overflowed",
            keyPath: \.standardOutputOverflowedIsFalse
        ),
        .init(
            fact: "standard_output_worker_finished",
            keyPath: \.standardOutputWorkerFinished
        ),
        .init(
            fact: "standard_output_read_error_number",
            keyPath: \.standardOutputReadErrorNumberMatches
        ),
        .init(
            fact: "standard_output_write_error_number",
            keyPath: \.standardOutputWriteErrorNumberMatches
        ),
        .init(
            fact: "standard_output_finalization_error_number",
            keyPath: \.standardOutputFinalizationErrorNumberMatches
        ),
        .init(
            fact: "standard_output_close_error_number",
            keyPath: \.standardOutputCloseErrorNumberMatches
        ),
        .init(
            fact: "standard_output_descriptors_closed",
            keyPath: \.standardOutputDescriptorsClosed
        ),
        .init(
            fact: "standard_error_reached_eof",
            keyPath: \.standardErrorReachedEOF
        ),
        .init(
            fact: "standard_error_total_byte_count",
            keyPath: \.standardErrorTotalByteCountMatches
        ),
        .init(
            fact: "standard_error_terminal_reason",
            keyPath: \.standardErrorTerminalReasonMatches
        ),
        .init(
            fact: "standard_error_overflowed",
            keyPath: \.standardErrorOverflowedIsFalse
        ),
        .init(
            fact: "standard_error_worker_finished",
            keyPath: \.standardErrorWorkerFinished
        ),
        .init(
            fact: "standard_error_read_error_number",
            keyPath: \.standardErrorReadErrorNumberMatches
        ),
        .init(
            fact: "standard_error_write_error_number",
            keyPath: \.standardErrorWriteErrorNumberMatches
        ),
        .init(
            fact: "standard_error_finalization_error_number",
            keyPath: \.standardErrorFinalizationErrorNumberMatches
        ),
        .init(
            fact: "standard_error_close_error_number",
            keyPath: \.standardErrorCloseErrorNumberMatches
        ),
        .init(
            fact: "standard_error_descriptors_closed",
            keyPath: \.standardErrorDescriptorsClosed
        ),
        .init(
            fact: "process_group_empty_after_reap",
            keyPath: \.processGroupEmptyAfterReap
        ),
        .init(fact: "terminal_after_wait", keyPath: \.terminalAfterWait),
        .init(
            fact: "terminal_before_deadline_expiry",
            keyPath: \.terminalBeforeDeadlineExpiry
        ),
    ]

    static func arguments(
        role: PrimeValidationDriverV2FixedProbeRole,
        primeHEAD: String,
        companionHEAD: String
    ) throws -> [String] {
        let suffix: [String]
        switch role {
        case .primeHeadPre, .primeHeadPost,
             .companionHeadPre, .companionHeadPost:
            suffix = ["rev-parse", "--verify", "HEAD^{commit}"]
        case .primeObjectFormat, .companionObjectFormat:
            suffix = ["rev-parse", "--show-object-format"]
        case .primeStatusPre, .primeStatusPost,
             .companionStatusPre, .companionStatusPost:
            suffix = statusArguments
        case .primeTreeDiscovery, .primeTreeReplay:
            suffix = [
                "ls-tree", "-r", "-z", "--full-tree", primeHEAD, "--",
            ] + primePathspecs
        case .companionTreeDiscovery, .companionTreeReplay:
            suffix = [
                "ls-tree", "-r", "-z", "--full-tree", companionHEAD, "--",
            ]
        case .swiftVersion:
            return ["--version"]
        case .swiftTargetInfo:
            return ["-print-target-info"]
        }
        return gitPrefix + suffix
    }

    static func outputCap(
        _ role: PrimeValidationDriverV2FixedProbeRole
    ) -> Int {
        switch role {
        case .primeHeadPre, .primeHeadPost,
             .companionHeadPre, .companionHeadPost:
            128
        case .primeObjectFormat, .companionObjectFormat:
            5
        case .swiftVersion:
            16 * 1024
        case .swiftTargetInfo:
            64 * 1024
        default:
            16 * 1024 * 1024
        }
    }

    static func environmentMatches(
        _ actual: [PrimeValidationSwiftPMDeterministicEnvironmentEntry],
        _ expected: [(String, String)]
    ) -> Bool {
        actual.count == expected.count
            && zip(actual, expected).allSatisfy {
                $0.0.key == $0.1.0 && $0.0.value == $0.1.1
            }
    }

    static func validateFile(
        _ value: PrimeValidationSwiftPMFileObservation,
        requiresRootOwner: Bool
    ) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            value.canonicalAbsolutePath
        )
        try PrimeValidationDriverV2Validation.requireSHA256(value.sha256)
        guard value.deviceID > 0,
              value.inode > 0,
              !requiresRootOwner || value.ownerUserID == 0,
              !requiresRootOwner || value.ownerGroupID == 0,
              value.permissionMode & 0o111 != 0,
              value.permissionMode & 0o022 == 0,
              value.linkCount == 1,
              value.byteCount > 0,
              value.modificationSeconds >= 0,
              value.modificationNanoseconds >= 0,
              value.modificationNanoseconds < 1_000_000_000,
              value.statusChangeSeconds >= 0,
              value.statusChangeNanoseconds >= 0,
              value.statusChangeNanoseconds < 1_000_000_000
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                value.canonicalAbsolutePath
            )
        }
    }
}

private struct PrimeValidationDriverV2DurableIdentityRecordV2: Codable {
    let role: String
    let absolutePath: String
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let byteCount: UInt64
    let sha256: String
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64
}

private struct PrimeValidationDriverV2DurablePrestartRecordV2: Codable {
    let schema: String
    let stage: String
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let embeddedPrimeSourceIdentitySHA256: String
    let policySHA256: String
    let environmentSHA256: String
    let journalAbsolutePath: String
    let primeRootDeviceID: UInt64
    let primeRootInode: UInt64
    let companionRootDeviceID: UInt64
    let companionRootInode: UInt64
    let primeGitDeviceID: UInt64
    let primeGitInode: UInt64
    let primeGitAbsolutePath: String
    let primeGitOwnerUserID: UInt32
    let primeGitOwnerGroupID: UInt32
    let primeGitPermissionMode: UInt16
    let companionGitDeviceID: UInt64
    let companionGitInode: UInt64
    let companionGitAbsolutePath: String
    let companionGitOwnerUserID: UInt32
    let companionGitOwnerGroupID: UInt32
    let companionGitPermissionMode: UInt16
    let gitExecutableSHA256: String
    let swiftFrontendSHA256: String
    let supervisorExecutableSHA256: String
    let journalIdentity: PrimeValidationDriverV2DurableIdentityRecordV2
    let rootIdentities: [PrimeValidationDriverV2DurableIdentityRecordV2]
    let imageIdentities: [PrimeValidationDriverV2DurableIdentityRecordV2]
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let orderedRoles: [String]
    let combinedSourceWatcherDescriptorCount: Int
}

private struct PrimeValidationDriverV2DurableStartRecordV2: Codable {
    let schema: String
    let stage: String
    let ordinal: Int
    let role: String
    let prestartSHA256: String
    let predecessorKind: String
    let predecessorSHA256: String
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let spawnReturnCode: Int32
    let spawnReturnedUptimeNanoseconds: UInt64
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let workingDirectoryDeviceID: UInt64
    let workingDirectoryInode: UInt64
    let workingDirectoryAbsolutePath: String
    let childWorkingDirectoryDeviceID: UInt64
    let childWorkingDirectoryInode: UInt64
    let executableDeviceID: UInt64
    let executableInode: UInt64
    let executableAbsolutePath: String
    let executableByteCount: UInt64
    let executableSHA256: String
    let logicalArgumentZero: String
    let arguments: [String]
    let argumentVectorSHA256: String
    let mappedExecutablePathTelemetry: String
    let mappedExecutableQueryCount: Int
    let mappedExecutableTerminalErrno: Int32
    let exactWorkingDirectoryJoin: Bool
    let exactMappedExecutableJoin: Bool
    let preResumeContinuityChecked: Bool
}

private struct PrimeValidationDriverV2DurableTerminalRecordV2: Codable {
    let schema: String
    let stage: String
    let ordinal: Int
    let role: String
    let startLeafSHA256: String
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let deathObservedUptimeNanoseconds: UInt64
    let preReapProcessGroupMemberIdentifiers: [Int32]
    let startPublishedUptimeNanoseconds: UInt64
    let preResumeContinuityCheckpointUptimeNanoseconds: UInt64
    let resumedAtUptimeNanoseconds: UInt64
    let requestedWaitProcessIdentifier: Int32
    let returnedWaitProcessIdentifier: Int32
    let waitOptions: Int32
    let rawWaitStatus: Int32
    let waitReturnedUptimeNanoseconds: UInt64
    let exitedNormally: Bool
    let exitStatus: Int32
    let terminationSignal: Int32
    let coreDumped: Bool
    let standardOutputByteCount: UInt64
    let standardOutputSHA256: String
    let standardOutputReachedEOF: Bool
    let standardOutputTerminalReason: String
    let standardOutputOverflowed: Bool
    let standardOutputWorkerFinished: Bool
    let standardOutputReadErrorNumber: Int32
    let standardOutputWriteErrorNumber: Int32
    let standardOutputFinalizationErrorNumber: Int32
    let standardOutputCloseErrorNumber: Int32
    let standardOutputDescriptorsClosed: Bool
    let standardErrorByteCount: UInt64
    let standardErrorSHA256: String
    let standardErrorReachedEOF: Bool
    let standardErrorTerminalReason: String
    let standardErrorOverflowed: Bool
    let standardErrorWorkerFinished: Bool
    let standardErrorReadErrorNumber: Int32
    let standardErrorWriteErrorNumber: Int32
    let standardErrorFinalizationErrorNumber: Int32
    let standardErrorCloseErrorNumber: Int32
    let standardErrorDescriptorsClosed: Bool
    let processGroupEmptyAfterReap: Bool
    let postReapContinuityChecked: Bool
}

private struct PrimeValidationDriverV2DurableRawTerminalRecordV2: Codable {
    let schema: String
    let stage: String
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let orderedProcessIdentifiers: [Int32]
    let orderedSessionIdentifiers: [Int32]
    let orderedProcessGroupIdentifiers: [Int32]
    let orderedTerminalSHA256Values: [String]
    let primeHEADAgreement: Bool
    let companionHEADAgreement: Bool
    let primeStatusPreEmpty: Bool
    let primeStatusPostEmpty: Bool
    let companionStatusPreEmpty: Bool
    let companionStatusPostEmpty: Bool
    let primeObjectFormat: String
    let companionObjectFormat: String
    let primeTreeReplayEqual: Bool
    let companionTreeReplayEqual: Bool
    let primeHeldEntriesSHA256: String
    let companionHeldEntriesSHA256: String
    let swiftVersionSHA256: String
    let swiftTargetInfoSHA256: String
}

private struct PrimeValidationDriverV2DurableArgumentVectorRecordV2:
    Encodable
{
    let logicalArgumentZero: String
    let arguments: [String]
}

private struct PrimeValidationDriverV2DurablePolicyRoleRecordV2: Encodable {
    let ordinal: Int
    let role: String
    let root: String
    let image: String
    let logicalArgumentZero: String
    let arguments: [String]
    let standardOutputMaximumByteCount: UInt64
}

private struct PrimeValidationDriverV2DurablePolicyRecordV2: Encodable {
    let schema: String
    let containmentMode: String
    let requiredSpawnFlags: UInt16
    let orderedRoles: [PrimeValidationDriverV2DurablePolicyRoleRecordV2]
    let primePathspecs: [String]
    let environment: [String]
    let deadlineNanoseconds: UInt64
    let standardErrorMaximumByteCount: UInt64
    let drainChunkByteCount: Int
}

private struct PrimeValidationDriverV2DurableReceiptLeafProjectionV2:
    Codable
{
    let leaf: String
    let byteCount: UInt64
    let sha256: String
    let deviceID: UInt64
    let inode: UInt64
}

private struct PrimeValidationDriverV2DurableReceiptIdentityProjectionV2:
    Codable
{
    let schema: String
    let intentIdentitySHA256: String
    let repositoryCommit: String
    let sourceIdentitySHA256: String
    let journalRootIdentitySHA256: String
    let leaseRootIdentitySHA256: String
    let gitExecutableIdentitySHA256: String
    let swiftFrontendExecutableIdentitySHA256: String
    let supervisorExecutableDeviceID: UInt64
    let supervisorExecutableInode: UInt64
    let gitExecutableDeviceID: UInt64
    let gitExecutableInode: UInt64
    let swiftFrontendExecutableDeviceID: UInt64
    let swiftFrontendExecutableInode: UInt64
    let supervisorProcessIdentifier: Int32
    let outerDeadlineStartedAtUptimeNanoseconds: UInt64
    let outerDeadlineExpiresAtUptimeNanoseconds: UInt64
    let supervisorWaitReturnedAtUptimeNanoseconds: UInt64
    let orderedLeaves:
        [PrimeValidationDriverV2DurableReceiptLeafProjectionV2]
    let orderedChildProcessIdentifiers: [Int32]
    let orderedChildProcessGroupIdentifiers: [Int32]
    let rawTerminalSHA256: String
    let supervisorExitContract: String
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static func validateHeldSets(
        _ raw: PrimeValidationDriverV2FixedProbeRawObservation,
        primeManifest: PrimeValidationTrackedTreeManifestArtifactV2
    ) throws {
        try requireRegularHeldEntryKinds(
            prime: raw.primeHeldEntries,
            companion: raw.companionHeldEntries
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            raw.primeHeldEntriesSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            raw.companionHeldEntriesSHA256
        )
        guard heldEntriesSHA256(raw.primeHeldEntries)
                == raw.primeHeldEntriesSHA256,
              heldEntriesSHA256(raw.companionHeldEntries)
                == raw.companionHeldEntriesSHA256
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_held_entry_digests"
            )
        }
        let expectedPrimePaths = raw.sourceSnapshot.files.map {
            Data($0.relativePath.utf8)
        }.sorted { $0.lexicographicallyPrecedes($1) }
        let observedPrimePaths = raw.primeHeldEntries.map(\.rawPathBytes)
        guard observedPrimePaths == expectedPrimePaths,
              primeManifest.manifest.entries.map(\.rawPathBytes)
                == expectedPrimePaths,
              raw.packageResolvedHeldEntry.rawPathBytes
                == Data("Package.resolved".utf8),
              raw.packageResolvedHeldEntry.kind == .regularFile,
              raw.packageResolvedHeldEntry.openedIdentity
                == raw.packageResolvedHeldEntry
                    .postReadDescriptorIdentity,
              raw.packageResolvedHeldEntry.openedIdentity
                == raw.packageResolvedHeldEntry
                    .namedPathReboundIdentity,
              raw.packageResolvedHeldEntry.contents
                == raw.packageResolvedData,
              raw.packageResolvedHeldEntry.sha256
                == raw.packageResolvedBinding.sha256,
              raw.packageResolvedHeldEntry.byteCount
                == raw.packageResolvedBinding.byteCount,
              raw.packageResolvedBinding.relativePath == "Package.resolved",
              raw.packageResolvedFileObservation.canonicalAbsolutePath
                == raw.primeRepository.canonicalAbsolutePath
                    + "/Package.resolved",
              raw.packageResolvedFileObservation.deviceID
                == raw.packageResolvedHeldEntry.openedIdentity.deviceID,
              raw.packageResolvedFileObservation.inode
                == raw.packageResolvedHeldEntry.openedIdentity.inode,
              raw.packageResolvedFileObservation.ownerUserID
                == raw.packageResolvedHeldEntry.openedIdentity.ownerUserID,
              raw.packageResolvedFileObservation.ownerGroupID
                == raw.packageResolvedHeldEntry.openedIdentity.ownerGroupID,
              raw.packageResolvedFileObservation.permissionMode
                == raw.packageResolvedHeldEntry.openedIdentity.permissionMode,
              raw.packageResolvedFileObservation.linkCount
                == raw.packageResolvedHeldEntry.openedIdentity.linkCount,
              raw.packageResolvedFileObservation.byteCount
                == raw.packageResolvedHeldEntry.byteCount,
              raw.packageResolvedFileObservation.sha256
                == raw.packageResolvedHeldEntry.sha256
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_held_sets"
            )
        }
    }

    static func requireRegularHeldEntryKinds(
        prime: [PrimeValidationDriverV2TrackedTreeHeldEntry],
        companion: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) throws {
        guard prime.allSatisfy({ $0.kind == .regularFile }),
              companion.allSatisfy({ $0.kind == .regularFile }) else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_held_entry_kinds"
            )
        }
    }

    static func heldEntriesSHA256(
        _ entries: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) -> String {
        var data = Data()
        for entry in entries {
            data.append(Data("\(entry.rawPathBytes.count):".utf8))
            data.append(entry.rawPathBytes)
            data.append(0)
            data.append(
                Data(entry.kind == .regularFile ? "f:".utf8 : "l:".utf8)
            )
            data.append(Data("\(entry.openedIdentity.deviceID):".utf8))
            data.append(Data("\(entry.openedIdentity.inode):".utf8))
            data.append(Data("\(entry.openedIdentity.ownerUserID):".utf8))
            data.append(Data("\(entry.openedIdentity.ownerGroupID):".utf8))
            data.append(Data("\(entry.openedIdentity.permissionMode):".utf8))
            data.append(Data("\(entry.openedIdentity.linkCount):".utf8))
            data.append(Data("\(entry.byteCount):".utf8))
            data.append(Data(entry.sha256.utf8))
            data.append(0)
            data.append(Data(entry.gitBlobSHA1.utf8))
            data.append(0)
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    static func repositoryReceipt(
        intent: PrimeValidationRunIntentV2,
        raw: PrimeValidationDriverV2FixedProbeRawObservation,
        process:
            [String: PrimeValidationDriverV2FixedProbeProcessObservation],
        repositoryCommit: String,
        companionCommit: String,
        primeManifest: PrimeValidationTrackedTreeManifestArtifactV2,
        companionManifest: PrimeValidationTrackedTreeManifestArtifactV2
    ) throws -> PrimeValidationRepositoryAdmissionReceiptV2 {
        guard raw.sourceSnapshotCanonicalData
                == (try PrimeCanonicalJSON.encode(raw.sourceSnapshot)),
              raw.sourceSnapshot.sourceIdentitySHA256
                == raw.sourceIdentitySHA256,
              raw.sourceSnapshot.embeddedSourceIdentitySHA256
                == raw.embeddedSourceIdentitySHA256,
              raw.sourceSnapshot.files.first(where: {
                  $0.relativePath == "Package.resolved"
              })?.contents == raw.packageResolvedData,
              PrimeValidationContentBinding(
                data: raw.sourceSnapshotCanonicalData
              ) == intent.sourceSnapshot,
              PrimeValidationContentBinding(data: raw.packageResolvedData)
                == intent.packageLock,
              UInt64(raw.gitExecutableData.count)
                == raw.gitExecutable.byteCount,
              raw.gitExecutable.byteCount <= 64 * 1024 * 1024,
              raw.gitExecutable.deviceID
                == raw.toolchain.developerDirectory.deviceID,
              PrimeSHA256.hexDigest(of: raw.gitExecutableData)
                == raw.gitExecutable.sha256
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "fixed_probe_repository_inputs"
            )
        }
        let packageFile = heldRegularFile(
            raw.packageResolvedFileObservation,
            data: raw.packageResolvedData
        )
        let receipt = PrimeValidationRepositoryAdmissionReceiptV2(
            repositoryRoot: directory(
                raw.primeRepository,
                role: .repository
            ),
            companionRoot: directory(
                raw.companionRepository,
                role: .companion
            ),
            gitExecutable: heldExecutable(
                raw.gitExecutable,
                data: raw.gitExecutableData
            ),
            sourceSnapshotArtifact: .init(
                name: "source_snapshot",
                relativePath: "admission/source-snapshot.json",
                data: raw.sourceSnapshotCanonicalData
            ),
            sourceIdentitySHA256: raw.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                raw.embeddedSourceIdentitySHA256,
            packageLockArtifact: .init(
                name: "package_lock",
                relativePath: "admission/Package.resolved",
                data: raw.packageResolvedData
            ),
            packageLockFile: packageFile,
            packageLockFileAfterAdmission: packageFile,
            repositoryHEADOutput: .init(
                name: "repository_head",
                relativePath: "admission/repository_head.bin",
                data: try required(process, .primeHeadPost).standardOutput
            ),
            repositoryCommit: repositoryCommit,
            repositoryStatusOutput: .init(
                name: "repository_status",
                relativePath: "admission/repository_status.bin",
                data: try required(process, .primeStatusPost).standardOutput
            ),
            repositoryTrackedTreeSHA256: primeManifest.sha256,
            companionHEADOutput: .init(
                name: "companion_head",
                relativePath: "admission/companion_head.bin",
                data: try required(process, .companionHeadPost).standardOutput
            ),
            companionCommit: companionCommit,
            companionStatusOutput: .init(
                name: "companion_status",
                relativePath: "admission/companion_status.bin",
                data: try required(process, .companionStatusPost)
                    .standardOutput
            ),
            companionTrackedTreeSHA256: companionManifest.sha256,
            repositoryDescriptorClosureHeld: true,
            companionDescriptorClosureHeld: true,
            vnodeWatchersArmed: true,
            initialPendingVnodeEventCount: 0
        )
        try receipt.validate(intent: intent)
        return receipt
    }

    static func directory(
        _ value: PrimeValidationSwiftPMDirectoryObservation,
        role: PrimeValidationAdmissionDirectoryRoleV2
    ) -> PrimeValidationCanonicalDirectoryObservationV2 {
        .init(
            role: role,
            requestedAbsolutePath: value.canonicalAbsolutePath,
            canonicalAbsolutePath: value.canonicalAbsolutePath,
            deviceID: value.deviceID,
            inode: value.inode,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            mode: value.permissionMode,
            linkCount: value.linkCount,
            filesystemType: value.filesystemType,
            filesystemIDWord0: value.filesystemIDWord0,
            filesystemIDWord1: value.filesystemIDWord1,
            modificationTimeSeconds: value.modificationSeconds,
            modificationTimeNanoseconds: value.modificationNanoseconds,
            statusChangeTimeSeconds: value.statusChangeSeconds,
            statusChangeTimeNanoseconds: value.statusChangeNanoseconds,
            localFilesystemObserved: value.localFilesystemObserved,
            descriptorJoined: true,
            pathIdentityJoined: true,
            noSymlinkComponentsObserved: true
        )
    }

    static func heldExecutable(
        _ value: PrimeValidationSwiftPMFileObservation,
        data: Data
    ) -> PrimeValidationHeldExecutableObservationV2 {
        .init(
            requestedAbsolutePath: value.canonicalAbsolutePath,
            canonicalAbsolutePath: value.canonicalAbsolutePath,
            requestedSymlinkTarget: nil,
            content: .init(data: data),
            deviceID: value.deviceID,
            inode: value.inode,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            mode: value.permissionMode,
            linkCount: value.linkCount,
            fileByteCount: value.byteCount,
            modificationTimeSeconds: value.modificationSeconds,
            modificationTimeNanoseconds: value.modificationNanoseconds,
            statusChangeTimeSeconds: value.statusChangeSeconds,
            statusChangeTimeNanoseconds: value.statusChangeNanoseconds,
            mappedExecutableAbsolutePath: value.canonicalAbsolutePath,
            descriptorJoined: true,
            pathIdentityJoined: true,
            mappedExecutableJoined: true
        )
    }

    static func heldRegularFile(
        _ value: PrimeValidationSwiftPMFileObservation,
        data: Data
    ) -> PrimeValidationHeldRegularFileObservationV2 {
        .init(
            role: .packageLock,
            absolutePath: value.canonicalAbsolutePath,
            content: .init(data: data),
            deviceID: value.deviceID,
            inode: value.inode,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            mode: value.permissionMode,
            linkCount: value.linkCount,
            fileByteCount: value.byteCount,
            modificationTimeSeconds: value.modificationSeconds,
            modificationTimeNanoseconds: value.modificationNanoseconds,
            statusChangeTimeSeconds: value.statusChangeSeconds,
            statusChangeTimeNanoseconds: value.statusChangeNanoseconds,
            descriptorJoined: true,
            pathIdentityJoined: true,
            noSymlinkComponentsObserved: true,
            retainedDescriptorClosureHeld: true
        )
    }
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static var durableJournalSiblingSuffix: String {
        ".driver-v2-gate-e-journal"
    }
    static var durableJournalMaximumLeafByteCount: Int { 64 * 1024 }
    static var durableInnerDeadlineNanoseconds: UInt64 { 30_000_000_000 }
    static var durableOuterDeadlineNanoseconds: UInt64 { 60_000_000_000 }
    static var durableInnerSpawnFlags: UInt16 { 0x408e }
    static var durableEmptySHA256: String {
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }

    static var durableOrderedLeaves: [String] {
        ["gate-e-prestart.json"]
            + roles.enumerated().flatMap { index, role in
                let base = String(format: "%02d", index + 1) + "-"
                    + role.rawValue.replacingOccurrences(
                        of: "_",
                        with: "-"
                    )
                return [base + "-start.json", base + "-terminal.json"]
            }
            + ["gate-e-raw-terminal.json"]
    }

    static func validateDurableJournal(
        orderedLeaves:
            [PrimeValidationDriverV2FixedProbeJournalLeafFrameV2],
        expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2,
        supervisorExit:
            PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2
    ) throws -> PrimeValidationDriverV2FixedProbeDurableJournalReceiptV2 {
        try validateDurableExpectation(
            expectation,
            supervisorExit: supervisorExit
        )
        let expectedLeaves = durableOrderedLeaves
        guard expectedLeaves.count == 34,
              orderedLeaves.count == expectedLeaves.count,
              orderedLeaves.map(\.leaf) == expectedLeaves
        else {
            throw durableJournalRejection("leaf_order")
        }

        var leafSHA256Values = [String]()
        var leafVnodes =
            [PrimeValidationDriverV2FixedProbeJournalVnodeV2]()
        var vnodeKeys = Set<String>()
        leafSHA256Values.reserveCapacity(orderedLeaves.count)
        leafVnodes.reserveCapacity(orderedLeaves.count)
        for leaf in orderedLeaves {
            let body = try durableCanonicalBody(leaf)
            guard !body.isEmpty,
                  leaf.vnode.deviceID == expectation.journalRoot.deviceID,
                  vnodeKeys.insert(
                      "\(leaf.vnode.deviceID):\(leaf.vnode.inode)"
                  ).inserted,
                  leaf.vnode.inode != expectation.journalRoot.inode
            else {
                throw durableJournalRejection("leaf_vnode")
            }
            leafSHA256Values.append(
                PrimeSHA256.hexDigest(of: leaf.framedBytes)
            )
            leafVnodes.append(leaf.vnode)
        }

        let prestart = try durableDecode(
            PrimeValidationDriverV2DurablePrestartRecordV2.self,
            from: orderedLeaves[0],
            coordinate: "prestart"
        )
        var starts = [PrimeValidationDriverV2DurableStartRecordV2]()
        var terminals =
            [PrimeValidationDriverV2DurableTerminalRecordV2]()
        starts.reserveCapacity(roles.count)
        terminals.reserveCapacity(roles.count)
        for index in roles.indices {
            starts.append(
                try durableDecode(
                    PrimeValidationDriverV2DurableStartRecordV2.self,
                    from: orderedLeaves[1 + index * 2],
                    coordinate: "start_\(index + 1)"
                )
            )
            terminals.append(
                try durableDecode(
                    PrimeValidationDriverV2DurableTerminalRecordV2.self,
                    from: orderedLeaves[2 + index * 2],
                    coordinate: "terminal_\(index + 1)"
                )
            )
        }
        let rawTerminal = try durableDecode(
            PrimeValidationDriverV2DurableRawTerminalRecordV2.self,
            from: orderedLeaves[33],
            coordinate: "raw_terminal"
        )

        try validateDurablePrestart(
            prestart,
            expectation: expectation
        )
        try validateDurableProcesses(
            starts: starts,
            terminals: terminals,
            leafSHA256Values: leafSHA256Values,
            expectation: expectation,
            prestart: prestart,
            supervisorExit: supervisorExit
        )
        try validateDurableRawTerminal(
            rawTerminal,
            starts: starts,
            terminals: terminals,
            leafSHA256Values: leafSHA256Values,
            expectation: expectation
        )

        let rawTerminalSHA256 = leafSHA256Values[33]
        let orderedChildProcessIdentifiers =
            starts.map(\.processIdentifier)
        let orderedChildProcessGroupIdentifiers =
            starts.map(\.processGroupIdentifier)
        let leafProjections = zip(orderedLeaves, leafSHA256Values).map {
            PrimeValidationDriverV2DurableReceiptLeafProjectionV2(
                leaf: $0.0.leaf,
                byteCount: UInt64($0.0.framedBytes.count),
                sha256: $0.1,
                deviceID: $0.0.vnode.deviceID,
                inode: $0.0.vnode.inode
            )
        }
        let receiptIdentity = try PrimeValidationDriverV2Validation.identity(
            PrimeValidationDriverV2DurableReceiptIdentityProjectionV2(
                schema:
                    "prime_driver_v2_gate_e_durable_journal_receipt_v2",
                intentIdentitySHA256:
                    try expectation.intent.identitySHA256(),
                repositoryCommit: expectation.repositoryCommit,
                sourceIdentitySHA256: expectation.sourceIdentitySHA256,
                journalRootIdentitySHA256:
                    try PrimeValidationDriverV2Validation.identity(
                        expectation.journalRoot
                    ),
                leaseRootIdentitySHA256:
                    try PrimeValidationDriverV2Validation.identity(
                        expectation.leaseRoot
                    ),
                gitExecutableIdentitySHA256:
                    try PrimeValidationDriverV2Validation.identity(
                        expectation.gitExecutable
                    ),
                swiftFrontendExecutableIdentitySHA256:
                    try PrimeValidationDriverV2Validation.identity(
                        expectation.swiftFrontendExecutable
                    ),
                supervisorExecutableDeviceID:
                    expectation.supervisorExecutableVnode.deviceID,
                supervisorExecutableInode:
                    expectation.supervisorExecutableVnode.inode,
                gitExecutableDeviceID:
                    expectation.gitExecutableVnode.deviceID,
                gitExecutableInode:
                    expectation.gitExecutableVnode.inode,
                swiftFrontendExecutableDeviceID:
                    expectation.swiftFrontendExecutableVnode.deviceID,
                swiftFrontendExecutableInode:
                    expectation.swiftFrontendExecutableVnode.inode,
                supervisorProcessIdentifier:
                    expectation.supervisorProcessIdentifier,
                outerDeadlineStartedAtUptimeNanoseconds:
                    expectation.outerDeadlineStartedAtUptimeNanoseconds,
                outerDeadlineExpiresAtUptimeNanoseconds:
                    expectation.outerDeadlineExpiresAtUptimeNanoseconds,
                supervisorWaitReturnedAtUptimeNanoseconds:
                    supervisorExit.returnedAtUptimeNanoseconds,
                orderedLeaves: leafProjections,
                orderedChildProcessIdentifiers:
                    orderedChildProcessIdentifiers,
                orderedChildProcessGroupIdentifiers:
                    orderedChildProcessGroupIdentifiers,
                rawTerminalSHA256: rawTerminalSHA256,
                supervisorExitContract:
                    "binding_bridge_then_final_revalidation_normal_zero_v1"
            )
        )
        try PrimeValidationDriverV2Validation.requireSHA256(receiptIdentity)
        return PrimeValidationDriverV2FixedProbeDurableJournalReceiptV2(
            identitySHA256: receiptIdentity,
            orderedLeafSHA256Values: leafSHA256Values,
            orderedLeafVnodes: leafVnodes,
            supervisorProcessIdentifier:
                expectation.supervisorProcessIdentifier,
            orderedChildProcessIdentifiers:
                orderedChildProcessIdentifiers,
            orderedChildProcessGroupIdentifiers:
                orderedChildProcessGroupIdentifiers,
            rawTerminalSHA256: rawTerminalSHA256
        )
    }

    static func validateDurableExpectation(
        _ expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2,
        supervisorExit:
            PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2
    ) throws {
        try expectation.intent.validate()
        try expectation.journalRoot.validate(requirePrivateMode: true)
        try expectation.leaseRoot.validate(requirePrivateMode: true)
        try expectation.gitExecutable.validate()
        try expectation.swiftFrontendExecutable.validate()
        try PrimeValidationDriverV2Validation.requireSHA256(
            expectation.sourceIdentitySHA256
        )
        let expectedSwiftFrontendAbsolutePath = try
            durableSwiftFrontendAbsolutePath(expectation.intent)
        let outerDeadline = expectation
            .outerDeadlineStartedAtUptimeNanoseconds
            .addingReportingOverflow(durableOuterDeadlineNanoseconds)
        let imageVnodes = [
            expectation.supervisorExecutableVnode,
            expectation.gitExecutableVnode,
            expectation.swiftFrontendExecutableVnode,
        ]
        let imageVnodeKeys = Set(imageVnodes.map {
            "\($0.deviceID):\($0.inode)"
        })
        let protectedRoots = [
            expectation.intent.roots.repositoryRoot.absolutePath,
            expectation.intent.roots.companionRoot.absolutePath,
            expectation.intent.roots.workspaceRoot.absolutePath,
            expectation.intent.roots.evidenceRoot.absolutePath,
            expectation.leaseRoot.absolutePath,
            expectation.journalRoot.absolutePath,
        ]
        guard durableGitObjectName(expectation.repositoryCommit),
              expectation.journalRoot.absolutePath
                == expectation.intent.roots.workspaceRoot.absolutePath
                    + durableJournalSiblingSuffix,
              expectation.journalRoot.mode == 0o700,
              expectation.leaseRoot.mode == 0o700,
              expectation.swiftFrontendExecutable.absolutePath
                == expectedSwiftFrontendAbsolutePath,
              expectation.swiftFrontendExecutable.content
                == expectation.intent.swiftExecutable.content,
              Set(protectedRoots).count == protectedRoots.count,
              imageVnodes.allSatisfy({
                  $0.deviceID > 0 && $0.inode > 0
              }),
              imageVnodeKeys.count == imageVnodes.count,
              expectation.supervisorProcessIdentifier > 0,
              expectation.outerDeadlineStartedAtUptimeNanoseconds > 0,
              !outerDeadline.overflow,
              expectation.outerDeadlineExpiresAtUptimeNanoseconds
                == outerDeadline.partialValue,
              supervisorExit.requestedProcessIdentifier
                == expectation.supervisorProcessIdentifier,
              supervisorExit.returnedProcessIdentifier
                == expectation.supervisorProcessIdentifier,
              supervisorExit.waitOptions == 0,
              supervisorExit.rawWaitStatus == 0,
              supervisorExit.returnedAtUptimeNanoseconds
                >= expectation.outerDeadlineStartedAtUptimeNanoseconds,
              supervisorExit.returnedAtUptimeNanoseconds
                <= expectation.outerDeadlineExpiresAtUptimeNanoseconds,
              supervisorExit.exitedNormally,
              supervisorExit.exitStatus == 0,
              supervisorExit.terminationSignal == 0,
              !supervisorExit.coreDumped
        else {
            throw durableJournalRejection("expectation_or_exit")
        }
    }

    static func durableCanonicalBody(
        _ leaf: PrimeValidationDriverV2FixedProbeJournalLeafFrameV2
    ) throws -> Data {
        guard PrimeValidationDriverV2Validation.isSafeName(leaf.leaf),
              leaf.framedBytes.count > 1,
              leaf.framedBytes.count <= durableJournalMaximumLeafByteCount,
              leaf.framedBytes.last == 0x0a
        else {
            throw durableJournalRejection("leaf_frame")
        }
        let body = Data(leaf.framedBytes.dropLast())
        guard !body.contains(0x0a), !body.contains(0x0d) else {
            throw durableJournalRejection("leaf_frame_newline")
        }
        return body
    }

    static func durableDecode<Value: Codable>(
        _ type: Value.Type,
        from leaf: PrimeValidationDriverV2FixedProbeJournalLeafFrameV2,
        coordinate: String
    ) throws -> Value {
        let body = try durableCanonicalBody(leaf)
        let value: Value
        do {
            value = try PrimeCanonicalJSON.decode(
                type,
                from: body,
                artifact: "driver_v2_gate_e_durable_\(coordinate)"
            )
        } catch {
            throw durableJournalRejection(coordinate + "_decode")
        }
        guard (try? PrimeCanonicalJSON.encode(value)) == body else {
            throw durableJournalRejection(coordinate + "_canonical")
        }
        return value
    }

    static func durableJournalRejection(
        _ coordinate: String
    ) -> PrimeValidationDriverV2Error {
        .invalidBinding("fixed_probe_durable_journal_" + coordinate)
    }

    static func durableGitObjectName(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static func validateDurablePrestart(
        _ value: PrimeValidationDriverV2DurablePrestartRecordV2,
        expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2
    ) throws {
        let supervisor = expectation.supervisorProcessIdentifier
        let innerDeadline = value.deadlineStartedAtUptimeNanoseconds
            .addingReportingOverflow(durableInnerDeadlineNanoseconds)
        let policyDigests = try durablePolicyDigests(expectation.intent)
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.embeddedPrimeSourceIdentitySHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.policySHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.environmentSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.gitExecutableSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.swiftFrontendSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.supervisorExecutableSHA256
        )
        guard value.schema == "prime_driver_v2_gate_e_prestart_v2",
              value.stage == "GATE-E",
              value.supervisorProcessIdentifier == supervisor,
              value.supervisorSessionIdentifier == supervisor,
              value.supervisorProcessGroupIdentifier == supervisor,
              value.embeddedPrimeSourceIdentitySHA256
                == expectation.sourceIdentitySHA256,
              value.policySHA256 == policyDigests.policy,
              value.environmentSHA256 == policyDigests.environment,
              value.journalAbsolutePath
                == expectation.journalRoot.absolutePath,
              value.primeRootDeviceID
                == expectation.intent.roots.repositoryRoot.deviceID,
              value.primeRootInode
                == expectation.intent.roots.repositoryRoot.inode,
              value.companionRootDeviceID
                == expectation.intent.roots.companionRoot.deviceID,
              value.companionRootInode
                == expectation.intent.roots.companionRoot.inode,
              value.primeGitDeviceID == value.primeRootDeviceID,
              value.primeGitInode > 0,
              value.primeGitInode != value.primeRootInode,
              value.primeGitAbsolutePath
                == expectation.intent.roots.repositoryRoot.absolutePath
                    + "/.git",
              value.primeGitOwnerUserID
                == expectation.intent.roots.repositoryRoot.ownerUserID,
              value.primeGitPermissionMode > 0,
              value.primeGitPermissionMode & 0o022 == 0,
              value.companionGitDeviceID == value.companionRootDeviceID,
              value.companionGitInode > 0,
              value.companionGitInode != value.companionRootInode,
              value.companionGitAbsolutePath
                == expectation.intent.roots.companionRoot.absolutePath
                    + "/.git",
              value.companionGitOwnerUserID
                == expectation.intent.roots.companionRoot.ownerUserID,
              value.companionGitPermissionMode > 0,
              value.companionGitPermissionMode & 0o022 == 0,
              value.gitExecutableSHA256
                == expectation.gitExecutable.content.sha256,
              value.swiftFrontendSHA256
                == expectation.swiftFrontendExecutable.content.sha256,
              value.supervisorExecutableSHA256
                == expectation.intent.driverExecutable.content.sha256,
              value.deadlineStartedAtUptimeNanoseconds
                >= expectation.outerDeadlineStartedAtUptimeNanoseconds,
              !innerDeadline.overflow,
              value.deadlineExpiresAtUptimeNanoseconds
                == innerDeadline.partialValue,
              value.deadlineExpiresAtUptimeNanoseconds
                <= expectation.outerDeadlineExpiresAtUptimeNanoseconds,
              value.orderedRoles == roles.map(\.rawValue),
              value.combinedSourceWatcherDescriptorCount == 2_232
        else {
            throw durableJournalRejection("prestart")
        }

        try validateDurableDirectoryIdentity(
            value.journalIdentity,
            role: "journal",
            expected: expectation.journalRoot,
            exactLinkCount: 2
        )
        let expectedRoots: [(
            String,
            PrimeValidationDirectoryBindingV2,
            UInt64?
        )] = [
            ("prime_root", expectation.intent.roots.repositoryRoot, nil),
            ("companion_root", expectation.intent.roots.companionRoot, nil),
            ("workspace_root", expectation.intent.roots.workspaceRoot, 2),
            ("evidence_root", expectation.intent.roots.evidenceRoot, 2),
            ("lease_root", expectation.leaseRoot, nil),
        ]
        guard value.rootIdentities.count == expectedRoots.count else {
            throw durableJournalRejection("prestart_roots")
        }
        for (record, expected) in zip(
            value.rootIdentities,
            expectedRoots
        ) {
            try validateDurableDirectoryIdentity(
                record,
                role: expected.0,
                expected: expected.1,
                exactLinkCount: expected.2
            )
        }

        let expectedImages: [(
            String,
            PrimeValidationExecutableBindingV2,
            PrimeValidationDriverV2FixedProbeJournalVnodeV2,
            String
        )] = [
            (
                "supervisor",
                expectation.intent.driverExecutable,
                expectation.supervisorExecutableVnode,
                expectation.intent.driverExecutable.absolutePath
            ),
            (
                "git",
                expectation.gitExecutable,
                expectation.gitExecutableVnode,
                expectation.gitExecutable.absolutePath
            ),
            (
                "swift_frontend",
                expectation.swiftFrontendExecutable,
                expectation.swiftFrontendExecutableVnode,
                expectation.swiftFrontendExecutable.absolutePath
            ),
        ]
        guard value.imageIdentities.count == expectedImages.count else {
            throw durableJournalRejection("prestart_images")
        }
        for (record, expected) in zip(
            value.imageIdentities,
            expectedImages
        ) {
            try validateDurableImageIdentity(
                record,
                role: expected.0,
                expected: expected.1,
                vnode: expected.2,
                expectedAbsolutePath: expected.3
            )
        }
    }

    static func validateDurableDirectoryIdentity(
        _ value: PrimeValidationDriverV2DurableIdentityRecordV2,
        role: String,
        expected: PrimeValidationDirectoryBindingV2,
        exactLinkCount: UInt64?
    ) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            value.absolutePath
        )
        guard value.role == role,
              value.absolutePath == expected.absolutePath,
              value.deviceID == expected.deviceID,
              value.inode == expected.inode,
              value.ownerUserID == expected.ownerUserID,
              value.permissionMode == expected.mode,
              value.linkCount >= 2,
              exactLinkCount.map({ value.linkCount == $0 }) ?? true,
              value.byteCount == 0,
              value.sha256.isEmpty,
              durableTimestamp(
                  seconds: value.modificationSeconds,
                  nanoseconds: value.modificationNanoseconds
              ),
              durableTimestamp(
                  seconds: value.statusChangeSeconds,
                  nanoseconds: value.statusChangeNanoseconds
              )
        else {
            throw durableJournalRejection("identity_" + role)
        }
    }

    static func validateDurableImageIdentity(
        _ value: PrimeValidationDriverV2DurableIdentityRecordV2,
        role: String,
        expected: PrimeValidationExecutableBindingV2,
        vnode: PrimeValidationDriverV2FixedProbeJournalVnodeV2,
        expectedAbsolutePath: String
    ) throws {
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            value.absolutePath
        )
        try PrimeValidationDriverV2Validation.requireSHA256(value.sha256)
        guard value.role == role,
              value.absolutePath == expectedAbsolutePath,
              value.deviceID == vnode.deviceID,
              value.inode == vnode.inode,
              value.permissionMode & 0o111 != 0,
              value.permissionMode & 0o022 == 0,
              value.linkCount == 1,
              value.byteCount == expected.content.byteCount,
              value.sha256 == expected.content.sha256,
              durableTimestamp(
                  seconds: value.modificationSeconds,
                  nanoseconds: value.modificationNanoseconds
              ),
              durableTimestamp(
                  seconds: value.statusChangeSeconds,
                  nanoseconds: value.statusChangeNanoseconds
              )
        else {
            throw durableJournalRejection("identity_" + role)
        }
    }

    static func durableTimestamp(
        seconds: Int64,
        nanoseconds: Int64
    ) -> Bool {
        seconds >= 0 && nanoseconds >= 0 && nanoseconds < 1_000_000_000
    }

    static func durableSwiftFrontendAbsolutePath(
        _ intent: PrimeValidationRunIntentV2
    ) throws -> String {
        let requested = intent.swiftExecutable.absolutePath
        guard requested.hasSuffix("/swift") else {
            throw durableJournalRejection("swift_frontend_path")
        }
        let value = String(requested.dropLast("swift".count))
            + "swift-frontend"
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(value)
        return value
    }

    static func durablePolicyDigests(
        _ intent: PrimeValidationRunIntentV2
    ) throws -> (policy: String, environment: String) {
        let swiftPath = intent.swiftExecutable.absolutePath
        let marker =
            "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
        guard swiftPath.hasSuffix(marker) else {
            throw durableJournalRejection("policy_developer_path")
        }
        let developerDirectory = String(swiftPath.dropLast(marker.count))
        let sdkRoot = developerDirectory
            + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        let environment = [
            ("DEVELOPER_DIR", developerDirectory),
            ("LANG", "C"),
            ("LC_ALL", "C"),
            ("SDKROOT", sdkRoot),
            ("TERM", "dumb"),
        ]
        let primePlaceholder = "<validated-prime-head-from-role-01>"
        let companionPlaceholder =
            "<validated-companion-head-from-role-08>"
        let orderedPolicy = try roles.enumerated().map { index, role in
            let isSwift = role == .swiftVersion || role == .swiftTargetInfo
            let root = durableRootBinding(for: role, intent: intent)
            return PrimeValidationDriverV2DurablePolicyRoleRecordV2(
                ordinal: index + 1,
                role: role.rawValue,
                root: root == intent.roots.companionRoot
                    ? "companion" : "prime",
                image: isSwift ? "swift_frontend" : "git",
                logicalArgumentZero: isSwift ? "swift" : "git",
                arguments: try arguments(
                    role: role,
                    primeHEAD: primePlaceholder,
                    companionHEAD: companionPlaceholder
                ),
                standardOutputMaximumByteCount: UInt64(Self.outputCap(role))
            )
        }
        let policy = PrimeValidationDriverV2DurablePolicyRecordV2(
            schema: "prime_driver_v2_gate_e_fixed_policy_v2",
            containmentMode: "dedicated_group_within_supervisor_session",
            requiredSpawnFlags: durableInnerSpawnFlags,
            orderedRoles: orderedPolicy,
            primePathspecs: primePathspecs,
            environment: environment.map { "\($0.0)=\($0.1)" },
            deadlineNanoseconds: durableInnerDeadlineNanoseconds,
            standardErrorMaximumByteCount: 64 * 1024,
            drainChunkByteCount: 64 * 1024
        )
        let environmentData = Data(
            environment.flatMap { "\($0.0)=\($0.1)\u{0}".utf8 }
        )
        return (
            try PrimeValidationDriverV2Validation.identity(policy),
            PrimeSHA256.hexDigest(of: environmentData)
        )
    }
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static func validateDurableProcesses(
        starts: [PrimeValidationDriverV2DurableStartRecordV2],
        terminals: [PrimeValidationDriverV2DurableTerminalRecordV2],
        leafSHA256Values: [String],
        expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2,
        prestart: PrimeValidationDriverV2DurablePrestartRecordV2,
        supervisorExit:
            PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2
    ) throws {
        guard starts.count == roles.count,
              terminals.count == roles.count,
              leafSHA256Values.count == 34
        else {
            throw durableJournalRejection("process_count")
        }
        let supervisor = expectation.supervisorProcessIdentifier
        var processIdentifiers = Set<Int32>()
        var processGroupIdentifiers = Set<Int32>()
        var predecessorKind = "prestart"
        var predecessorSHA256 = leafSHA256Values[0]
        var predecessorWait =
            prestart.deadlineStartedAtUptimeNanoseconds

        for index in roles.indices {
            let role = roles[index]
            let ordinal = index + 1
            let start = starts[index]
            let terminal = terminals[index]
            let expectedRoot = durableRootBinding(
                for: role,
                intent: expectation.intent
            )
            let isSwift = role == .swiftVersion || role == .swiftTargetInfo
            let expectedExecutable = isSwift
                ? expectation.swiftFrontendExecutable
                : expectation.gitExecutable
            let expectedExecutableVnode = isSwift
                ? expectation.swiftFrontendExecutableVnode
                : expectation.gitExecutableVnode
            let expectedExecutablePath = isSwift
                ? expectation.swiftFrontendExecutable.absolutePath
                : expectation.gitExecutable.absolutePath
            let expectedArgumentZero = isSwift ? "swift" : "git"
            let expectedArguments = try arguments(
                role: role,
                primeHEAD: expectation.repositoryCommit,
                companionHEAD: expectation.intent.companionCommit
            )
            let expectedArgumentVectorSHA256 = try
                PrimeValidationDriverV2Validation.identity(
                    PrimeValidationDriverV2DurableArgumentVectorRecordV2(
                        logicalArgumentZero: expectedArgumentZero,
                        arguments: expectedArguments
                    )
                )
            let startLeafIndex = 1 + index * 2
            let terminalLeafIndex = startLeafIndex + 1

            try PrimeValidationDriverV2Validation.requireSHA256(
                start.prestartSHA256
            )
            try PrimeValidationDriverV2Validation.requireSHA256(
                start.predecessorSHA256
            )
            try PrimeValidationDriverV2Validation.requireSHA256(
                start.argumentVectorSHA256
            )
            guard start.schema
                    == "prime_driver_v2_gate_e_child_start_v2",
                  start.stage == "GATE-E",
                  start.ordinal == ordinal,
                  start.role == role.rawValue,
                  start.prestartSHA256 == leafSHA256Values[0],
                  start.predecessorKind == predecessorKind,
                  start.predecessorSHA256 == predecessorSHA256,
                  start.processIdentifier > 0,
                  start.processIdentifier != supervisor,
                  processIdentifiers.insert(
                      start.processIdentifier
                  ).inserted,
                  start.sessionIdentifier == supervisor,
                  start.processGroupIdentifier
                    == start.processIdentifier,
                  processGroupIdentifiers.insert(
                      start.processGroupIdentifier
                  ).inserted,
                  start.appliedSpawnFlags == durableInnerSpawnFlags,
                  start.spawnReturnCode == 0,
                  start.spawnReturnedUptimeNanoseconds >= predecessorWait,
                  start.spawnReturnedUptimeNanoseconds
                    >= prestart.deadlineStartedAtUptimeNanoseconds,
                  start.spawnReturnedUptimeNanoseconds
                    <= prestart.deadlineExpiresAtUptimeNanoseconds,
                  start.deadlineStartedAtUptimeNanoseconds
                    == prestart.deadlineStartedAtUptimeNanoseconds,
                  start.deadlineExpiresAtUptimeNanoseconds
                    == prestart.deadlineExpiresAtUptimeNanoseconds,
                  start.workingDirectoryDeviceID == expectedRoot.deviceID,
                  start.workingDirectoryInode == expectedRoot.inode,
                  start.workingDirectoryAbsolutePath
                    == expectedRoot.absolutePath,
                  start.childWorkingDirectoryDeviceID
                    == expectedRoot.deviceID,
                  start.childWorkingDirectoryInode == expectedRoot.inode,
                  start.executableDeviceID
                    == expectedExecutableVnode.deviceID,
                  start.executableInode
                    == expectedExecutableVnode.inode,
                  start.executableAbsolutePath == expectedExecutablePath,
                  start.executableByteCount
                    == expectedExecutable.content.byteCount,
                  start.executableSHA256
                    == expectedExecutable.content.sha256,
                  start.logicalArgumentZero == expectedArgumentZero,
                  start.arguments == expectedArguments,
                  start.argumentVectorSHA256
                    == expectedArgumentVectorSHA256,
                  PrimeValidationDriverV2Validation.isSafeAbsolutePath(
                      start.mappedExecutablePathTelemetry
                  ),
                  start.mappedExecutableQueryCount > 0,
                  start.mappedExecutableQueryCount <= 256,
                  start.mappedExecutableTerminalErrno >= 0,
                  start.exactWorkingDirectoryJoin,
                  start.exactMappedExecutableJoin,
                  start.preResumeContinuityChecked
            else {
                throw durableJournalRejection("start_\(ordinal)")
            }

            try PrimeValidationDriverV2Validation.requireSHA256(
                terminal.startLeafSHA256
            )
            try PrimeValidationDriverV2Validation.requireSHA256(
                terminal.standardOutputSHA256
            )
            try PrimeValidationDriverV2Validation.requireSHA256(
                terminal.standardErrorSHA256
            )
            let expectedOutputCap = UInt64(Self.outputCap(role))
            guard terminal.schema
                    == "prime_driver_v2_gate_e_child_terminal_v2",
                  terminal.stage == "GATE-E",
                  terminal.ordinal == ordinal,
                  terminal.role == role.rawValue,
                  terminal.startLeafSHA256
                    == leafSHA256Values[startLeafIndex],
                  terminal.supervisorProcessIdentifier == supervisor,
                  terminal.supervisorSessionIdentifier == supervisor,
                  terminal.supervisorProcessGroupIdentifier == supervisor,
                  terminal.processIdentifier == start.processIdentifier,
                  terminal.sessionIdentifier == supervisor,
                  terminal.processGroupIdentifier
                    == start.processGroupIdentifier,
                  terminal.preReapProcessGroupMemberIdentifiers
                    == [start.processIdentifier],
                  terminal.startPublishedUptimeNanoseconds
                    >= start.spawnReturnedUptimeNanoseconds,
                  terminal.startPublishedUptimeNanoseconds
                    >= prestart.deadlineStartedAtUptimeNanoseconds,
                  terminal.startPublishedUptimeNanoseconds
                    <= prestart.deadlineExpiresAtUptimeNanoseconds,
                  terminal.preResumeContinuityCheckpointUptimeNanoseconds
                    >= terminal.startPublishedUptimeNanoseconds,
                  terminal.preResumeContinuityCheckpointUptimeNanoseconds
                    <= prestart.deadlineExpiresAtUptimeNanoseconds,
                  terminal.resumedAtUptimeNanoseconds
                    >= terminal
                        .preResumeContinuityCheckpointUptimeNanoseconds,
                  terminal.resumedAtUptimeNanoseconds
                    > terminal.startPublishedUptimeNanoseconds,
                  terminal.resumedAtUptimeNanoseconds
                    <= prestart.deadlineExpiresAtUptimeNanoseconds,
                  terminal.deathObservedUptimeNanoseconds
                    >= terminal.resumedAtUptimeNanoseconds,
                  terminal.requestedWaitProcessIdentifier
                    == start.processIdentifier,
                  terminal.returnedWaitProcessIdentifier
                    == start.processIdentifier,
                  terminal.waitOptions == 0,
                  terminal.rawWaitStatus == 0,
                  terminal.waitReturnedUptimeNanoseconds
                    >= terminal.deathObservedUptimeNanoseconds,
                  terminal.waitReturnedUptimeNanoseconds
                    <= prestart.deadlineExpiresAtUptimeNanoseconds,
                  terminal.waitReturnedUptimeNanoseconds
                    <= supervisorExit.returnedAtUptimeNanoseconds,
                  terminal.exitedNormally,
                  terminal.exitStatus == 0,
                  terminal.terminationSignal == 0,
                  !terminal.coreDumped,
                  terminal.standardOutputByteCount <= expectedOutputCap,
                  terminal.standardOutputReachedEOF,
                  terminal.standardOutputTerminalReason == "end_of_file",
                  !terminal.standardOutputOverflowed,
                  terminal.standardOutputWorkerFinished,
                  terminal.standardOutputReadErrorNumber == 0,
                  terminal.standardOutputWriteErrorNumber == 0,
                  terminal.standardOutputFinalizationErrorNumber == 0,
                  terminal.standardOutputCloseErrorNumber == 0,
                  terminal.standardOutputDescriptorsClosed,
                  terminal.standardErrorByteCount == 0,
                  terminal.standardErrorSHA256 == durableEmptySHA256,
                  terminal.standardErrorReachedEOF,
                  terminal.standardErrorTerminalReason == "end_of_file",
                  !terminal.standardErrorOverflowed,
                  terminal.standardErrorWorkerFinished,
                  terminal.standardErrorReadErrorNumber == 0,
                  terminal.standardErrorWriteErrorNumber == 0,
                  terminal.standardErrorFinalizationErrorNumber == 0,
                  terminal.standardErrorCloseErrorNumber == 0,
                  terminal.standardErrorDescriptorsClosed,
                  terminal.processGroupEmptyAfterReap,
                  terminal.postReapContinuityChecked
            else {
                throw durableJournalRejection("terminal_\(ordinal)")
            }
            try validateDurableRoleOutput(
                role,
                terminal: terminal,
                repositoryCommit: expectation.repositoryCommit,
                companionCommit: expectation.intent.companionCommit
            )
            predecessorKind = "child_terminal"
            predecessorSHA256 = leafSHA256Values[terminalLeafIndex]
            predecessorWait = terminal.waitReturnedUptimeNanoseconds
        }
        guard processIdentifiers.count == roles.count,
              processGroupIdentifiers.count == roles.count
        else {
            throw durableJournalRejection("process_identity_set")
        }
    }

    static func durableRootBinding(
        for role: PrimeValidationDriverV2FixedProbeRole,
        intent: PrimeValidationRunIntentV2
    ) -> PrimeValidationDirectoryBindingV2 {
        switch role {
        case .companionHeadPre, .companionObjectFormat,
             .companionStatusPre, .companionTreeDiscovery,
             .companionTreeReplay, .companionStatusPost,
             .companionHeadPost:
            intent.roots.companionRoot
        default:
            intent.roots.repositoryRoot
        }
    }

    static func validateDurableRoleOutput(
        _ role: PrimeValidationDriverV2FixedProbeRole,
        terminal: PrimeValidationDriverV2DurableTerminalRecordV2,
        repositoryCommit: String,
        companionCommit: String
    ) throws {
        let exactData: Data?
        switch role {
        case .primeHeadPre, .primeHeadPost:
            exactData = Data((repositoryCommit + "\n").utf8)
        case .companionHeadPre, .companionHeadPost:
            exactData = Data((companionCommit + "\n").utf8)
        case .primeObjectFormat, .companionObjectFormat:
            exactData = Data("sha1\n".utf8)
        case .primeStatusPre, .primeStatusPost,
             .companionStatusPre, .companionStatusPost:
            exactData = Data()
        case .primeTreeDiscovery, .primeTreeReplay,
             .companionTreeDiscovery, .companionTreeReplay,
             .swiftVersion, .swiftTargetInfo:
            exactData = nil
        }
        if let exactData {
            guard terminal.standardOutputByteCount
                    == UInt64(exactData.count),
                  terminal.standardOutputSHA256
                    == PrimeSHA256.hexDigest(of: exactData)
            else {
                throw durableJournalRejection(
                    "output_" + role.rawValue
                )
            }
        } else {
            guard terminal.standardOutputByteCount > 0 else {
                throw durableJournalRejection(
                    "output_" + role.rawValue
                )
            }
        }
    }
}

private extension PrimeValidationDriverV2FixedProbeSemanticValidator {
    static func validateDurableRawTerminal(
        _ value: PrimeValidationDriverV2DurableRawTerminalRecordV2,
        starts: [PrimeValidationDriverV2DurableStartRecordV2],
        terminals: [PrimeValidationDriverV2DurableTerminalRecordV2],
        leafSHA256Values: [String],
        expectation:
            PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2
    ) throws {
        let supervisor = expectation.supervisorProcessIdentifier
        let processIdentifiers = starts.map(\.processIdentifier)
        let processGroupIdentifiers = starts.map(\.processGroupIdentifier)
        let terminalSHA256Values = roles.indices.map {
            leafSHA256Values[2 + $0 * 2]
        }
        for digest in value.orderedTerminalSHA256Values {
            try PrimeValidationDriverV2Validation.requireSHA256(digest)
        }
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.primeHeldEntriesSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.companionHeldEntriesSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.swiftVersionSHA256
        )
        try PrimeValidationDriverV2Validation.requireSHA256(
            value.swiftTargetInfoSHA256
        )
        guard value.schema == "prime_driver_v2_gate_e_raw_terminal_v2",
              value.stage == "GATE-E",
              value.supervisorProcessIdentifier == supervisor,
              value.supervisorSessionIdentifier == supervisor,
              value.supervisorProcessGroupIdentifier == supervisor,
              value.orderedProcessIdentifiers == processIdentifiers,
              value.orderedSessionIdentifiers
                == Array(repeating: supervisor, count: roles.count),
              value.orderedProcessGroupIdentifiers
                == processGroupIdentifiers,
              value.orderedTerminalSHA256Values == terminalSHA256Values,
              value.primeHEADAgreement,
              value.companionHEADAgreement,
              value.primeStatusPreEmpty,
              value.primeStatusPostEmpty,
              value.companionStatusPreEmpty,
              value.companionStatusPostEmpty,
              value.primeObjectFormat == "sha1\n",
              value.companionObjectFormat == "sha1\n",
              value.primeTreeReplayEqual,
              value.companionTreeReplayEqual,
              value.swiftVersionSHA256
                == terminals[14].standardOutputSHA256,
              value.swiftTargetInfoSHA256
                == terminals[15].standardOutputSHA256,
              terminals[0].standardOutputSHA256
                == terminals[6].standardOutputSHA256,
              terminals[0].standardOutputByteCount
                == terminals[6].standardOutputByteCount,
              terminals[7].standardOutputSHA256
                == terminals[13].standardOutputSHA256,
              terminals[7].standardOutputByteCount
                == terminals[13].standardOutputByteCount,
              terminals[3].standardOutputSHA256
                == terminals[4].standardOutputSHA256,
              terminals[3].standardOutputByteCount
                == terminals[4].standardOutputByteCount,
              terminals[10].standardOutputSHA256
                == terminals[11].standardOutputSHA256,
              terminals[10].standardOutputByteCount
                == terminals[11].standardOutputByteCount,
              terminals[2].standardOutputSHA256 == durableEmptySHA256,
              terminals[5].standardOutputSHA256 == durableEmptySHA256,
              terminals[9].standardOutputSHA256 == durableEmptySHA256,
              terminals[12].standardOutputSHA256 == durableEmptySHA256
        else {
            throw durableJournalRejection("raw_terminal")
        }
    }
}

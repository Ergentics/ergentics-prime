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
              rawObservation.combinedSourceWatcherDescriptorCount == 2_157,
              boundLifetime.combinedSourceWatcherDescriptorCount == 2_157,
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
        var spawnFlagsMatch: Bool
        var spawnReturnCodeMatches: Bool
        var spawnAfterDeadlineStart: Bool
        var spawnAfterPredecessorTerminal: Bool
        var spawnBeforeStartPublication: Bool
        var sessionIdentifierMatches: Bool
        var processGroupIdentifierMatches: Bool
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
              raw.combinedSourceWatcherDescriptorCount == 2_157,
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
                    spawnFlagsMatch: value.appliedSpawnFlags == 0x448c,
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
                        value.sessionIdentifier == value.processIdentifier,
                    processGroupIdentifierMatches:
                        value.processGroupIdentifier
                            == value.processIdentifier,
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
              value.spawnFlagsMatch,
              value.spawnReturnCodeMatches,
              value.spawnAfterDeadlineStart,
              value.spawnAfterPredecessorTerminal,
              value.spawnBeforeStartPublication,
              value.sessionIdentifierMatches,
              value.processGroupIdentifierMatches,
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
        spawnFlagsMatch: true,
        spawnReturnCodeMatches: true,
        spawnAfterDeadlineStart: true,
        spawnAfterPredecessorTerminal: true,
        spawnBeforeStartPublication: true,
        sessionIdentifierMatches: true,
        processGroupIdentifierMatches: true,
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

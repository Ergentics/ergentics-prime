#!/usr/bin/swift

import CryptoKit
import Foundation

private enum SPDXGenerationError: Error, CustomStringConvertible {
    case usage
    case unsafePath(String)
    case missingFile(String)
    case nonRegularFile(String)
    case invalidIdentity(String)
    case enumerationFailed(String)

    var description: String {
        switch self {
        case .usage:
            return "usage: GenerateSPDX.swift <repository-root> <output-path> <marketing-version> <build-number> <created-utc> <lowercase-namespace-uuid>"
        case .unsafePath(let path):
            return "unsafe package path: \(path)"
        case .missingFile(let path):
            return "missing package file: \(path)"
        case .nonRegularFile(let path):
            return "package entry is not a regular file: \(path)"
        case .invalidIdentity(let field):
            return "invalid deterministic document identity: \(field)"
        case .enumerationFailed(let detail):
            return "package enumeration failed: \(detail)"
        }
    }
}

private struct Digests {
    let sha1: String
    let sha256: String
}

private let licenseID = "LicenseRef-Ergentics-Proprietary"
private let excludedSPDXPath = "./ERGENTICS.spdx.json"

private struct DocumentIdentity {
    let marketingVersion: String
    let buildNumber: String
    let creationTime: String
    let documentNamespace: String
}

private func validatedIdentity(marketingVersion: String, buildNumber: String,
                               creationTime: String, namespaceUUID: String) throws
    -> DocumentIdentity {
    func canonicalDecimal(_ value: Substring) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy { (48...57).contains($0) } &&
            (value.count == 1 || value.first != "0")
    }
    let versionParts = marketingVersion.split(separator: ".", omittingEmptySubsequences: false)
    guard (1...4).contains(versionParts.count), marketingVersion.utf8.count <= 32,
          versionParts.allSatisfy(canonicalDecimal) else {
        throw SPDXGenerationError.invalidIdentity("marketing version")
    }
    guard buildNumber.utf8.count <= 20, canonicalDecimal(buildNumber[...]),
          UInt64(buildNumber) != nil else {
        throw SPDXGenerationError.invalidIdentity("build number")
    }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    guard let instant = formatter.date(from: creationTime),
          formatter.string(from: instant) == creationTime else {
        throw SPDXGenerationError.invalidIdentity("UTC creation time")
    }
    guard let uuid = UUID(uuidString: namespaceUUID),
          uuid.uuidString.lowercased() == namespaceUUID else {
        throw SPDXGenerationError.invalidIdentity("lowercase namespace UUID")
    }
    return DocumentIdentity(marketingVersion: marketingVersion, buildNumber: buildNumber,
        creationTime: creationTime, documentNamespace: "urn:uuid:\(namespaceUUID)")
}

private func hex<S: Sequence>(_ bytes: S) -> String where S.Element == UInt8 {
    bytes.map { String(format: "%02x", $0) }.joined()
}

private func digests(_ data: Data) -> Digests {
    Digests(
        sha1: hex(Insecure.SHA1.hash(data: data)),
        sha256: hex(SHA256.hash(data: data))
    )
}

private final class EnumerationFailureBox {
    var error: Error?
}

private func recursivelyEnumeratedFiles(root: URL, relativeDirectory: String) throws -> [String] {
    let directory = root.appendingPathComponent(relativeDirectory, isDirectory: true)
    let failure = EnumerationFailureBox()
    guard let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
        options: [],
        errorHandler: { url, error in
            FileHandle.standardError.write(Data("enumeration failed at \(url.path): \(error)\n".utf8))
            failure.error = error
            return false
        }
    ) else {
        throw SPDXGenerationError.missingFile(relativeDirectory)
    }

    var result: [String] = []
    for case let url as URL in enumerator {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        if values.isSymbolicLink == true {
            throw SPDXGenerationError.nonRegularFile(url.path)
        }
        guard values.isRegularFile == true else { continue }
        let prefix = root.path.hasSuffix("/") ? root.path : root.path + "/"
        guard url.path.hasPrefix(prefix) else { throw SPDXGenerationError.unsafePath(url.path) }
        result.append(String(url.path.dropFirst(prefix.count)))
    }
    if let error = failure.error {
        throw SPDXGenerationError.enumerationFailed("\(relativeDirectory): \(error)")
    }
    return result
}

private func fileType(for path: String) -> String {
    switch URL(fileURLWithPath: path).pathExtension.lowercased() {
    case "swift", "c", "h", "s", "ld", "rs", "rb", "pbxproj": return "SOURCE"
    case "png": return "IMAGE"
    default: return "TEXT"
    }
}

private func generate(repositoryRoot: URL, outputURL: URL,
                      identity: DocumentIdentity) throws {
    let fixedFiles = [
        "ErgenticsProvenance.xcodeproj/project.pbxproj",
        "Entitlements.plist",
        "Info.plist",
        "LICENSE",
        "PrivacyInfo.xcprivacy",
        "THIRD_PARTY_NOTICES.md",
        "NATIVE-AGENTS.md",
        "Packages/PrimeNativeRuntime/Package.swift",
        "Packages/PrimeNativeRuntime/LICENSE",
        "Packages/PrimeNativeRuntime/README.md",
    ]
    let relativePaths = try (
        fixedFiles
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Assets.xcassets")
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Guest")
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Sources")
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Resources/ErgenticsAgents")
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Tools/PrimeRuntime")
        + recursivelyEnumeratedFiles(root: repositoryRoot, relativeDirectory: "Packages/PrimeNativeRuntime/Sources")
    ).sorted()

    guard Set(relativePaths).count == relativePaths.count else {
        throw SPDXGenerationError.unsafePath("duplicate package entry")
    }

    let rootPrefix = repositoryRoot.path.hasSuffix("/") ? repositoryRoot.path : repositoryRoot.path + "/"
    var fileObjects: [[String: Any]] = []
    var relationships: [[String: Any]] = [[
        "spdxElementId": "SPDXRef-DOCUMENT",
        "relationshipType": "DESCRIBES",
        "relatedSpdxElement": "SPDXRef-Package-ErgenticsProvenance",
    ]]
    var sha1Values: [String] = []
    var fileIDs: [String] = []

    for (index, relativePath) in relativePaths.enumerated() {
        guard !relativePath.hasPrefix("/"), !relativePath.contains("/../"), relativePath != ".." else {
            throw SPDXGenerationError.unsafePath(relativePath)
        }
        let fileURL = repositoryRoot.appendingPathComponent(relativePath, isDirectory: false)
        guard fileURL.path.hasPrefix(rootPrefix) else { throw SPDXGenerationError.unsafePath(relativePath) }
        let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values.isSymbolicLink != true, values.isRegularFile == true else {
            throw SPDXGenerationError.nonRegularFile(relativePath)
        }
        let data = try Data(contentsOf: fileURL, options: [.mappedIfSafe])
        let value = digests(data)
        sha1Values.append(value.sha1)
        let fileID = String(format: "SPDXRef-File-%04d", index + 1)
        fileIDs.append(fileID)
        fileObjects.append([
            "SPDXID": fileID,
            "fileName": "./\(relativePath)",
            "fileTypes": [fileType(for: relativePath)],
            "checksums": [
                ["algorithm": "SHA1", "checksumValue": value.sha1],
                ["algorithm": "SHA256", "checksumValue": value.sha256],
            ],
            "licenseConcluded": licenseID,
            "licenseInfoInFiles": ["NONE"],
            "copyrightText": "Copyright (c) 2026 Ergentics, LLC. All rights reserved.",
        ])
        relationships.append([
            "spdxElementId": "SPDXRef-Package-ErgenticsProvenance",
            "relationshipType": "CONTAINS",
            "relatedSpdxElement": fileID,
        ])
    }

    let verificationInput = Data(sha1Values.sorted().joined().utf8)
    let verificationCode = hex(Insecure.SHA1.hash(data: verificationInput))
    let licenseText = try String(
        contentsOf: repositoryRoot.appendingPathComponent("LICENSE"),
        encoding: .utf8
    )

    var document: [String: Any] = [
        "spdxVersion": "SPDX-2.3",
        "dataLicense": "CC0-1.0",
        "SPDXID": "SPDXRef-DOCUMENT",
        "name": "Ergentics Provenance \(identity.marketingVersion) build \(identity.buildNumber) source package",
        "documentNamespace": identity.documentNamespace,
        "creationInfo": [
            "created": identity.creationTime,
            "creators": ["Organization: Ergentics, LLC", "Tool: Ergentics GenerateSPDX.swift/4"],
        ],
        "documentDescribes": ["SPDXRef-Package-ErgenticsProvenance"],
        "packages": [[
            "name": "Ergentics Provenance",
            "SPDXID": "SPDXRef-Package-ErgenticsProvenance",
            "versionInfo": "\(identity.marketingVersion) (\(identity.buildNumber))",
            "supplier": "Organization: Ergentics, LLC",
            "originator": "Organization: Ergentics, LLC",
            "downloadLocation": "NOASSERTION",
            "filesAnalyzed": true,
            "packageVerificationCode": [
                "packageVerificationCodeValue": verificationCode,
                "packageVerificationCodeExcludedFiles": [excludedSPDXPath],
            ],
            "licenseConcluded": licenseID,
            "licenseInfoFromFiles": ["NONE"],
            "licenseDeclared": licenseID,
            "copyrightText": "Copyright (c) 2026 Ergentics, LLC. All rights reserved.",
            "primaryPackagePurpose": "APPLICATION",
            "hasFiles": fileIDs,
            "summary": "The Ergentics macOS app, embedded Hypervisor fixtures, and app-owned native Prime runtime helper. Vendored dependencies are separately identified by their pinned revisions and licenses.",
        ]],
        "files": fileObjects,
        "relationships": relationships,
        "hasExtractedLicensingInfos": [[
            "licenseId": licenseID,
            "name": "Ergentics Proprietary License",
            "extractedText": licenseText,
            "comment": "First-party Ergentics terms reproduced byte-for-byte from LICENSE.",
        ]],
    ]

    let dependencies: [(String, String, String, String)] = [
        ("MLXSwift", "Ergentics MLX Swift", "d37885a278f1c37484a94d0f401a418735e66519", "MIT"),
        ("MLXCore", "MLX core", "ce45c52505c8158ea48d2a54e8caae05efd86bfe", "MIT"),
        ("MLXC", "MLX C API", "0726ca922fc902c4c61ef9c27d94132be418e945", "MIT"),
        ("SwiftNumerics", "Swift Numerics", "0c0290ff6b24942dadb83a929ffaaa1481df04a2", "Apache-2.0 WITH Swift-exception"),
        ("Fmt", "fmt", "vendored in Ergentics MLX Swift d37885a", "MIT"),
        ("JSON", "nlohmann JSON", "vendored in Ergentics MLX Swift d37885a", "MIT"),
        ("MetalCpp", "Metal-cpp", "vendored in Ergentics MLX Swift d37885a", "Apache-2.0"),
    ]
    var packages = document["packages"] as! [[String: Any]]
    for (id, name, version, declaredLicense) in dependencies {
        let reference = "SPDXRef-Package-\(id)"
        packages.append([
            "SPDXID": reference, "name": name, "versionInfo": version,
            "downloadLocation": "NOASSERTION", "filesAnalyzed": false,
            "licenseConcluded": "NOASSERTION", "licenseDeclared": declaredLicense,
            "copyrightText": "NOASSERTION", "primaryPackagePurpose": "LIBRARY",
            "sourceInfo": "Vendored local source; revisions and packaging changes are recorded in Packages/PrimeNativeRuntime/README.md. License texts are included in THIRD_PARTY_NOTICES.md.",
        ])
        relationships.append(["spdxElementId": "SPDXRef-Package-ErgenticsProvenance",
                              "relationshipType": "DEPENDS_ON", "relatedSpdxElement": reference])
    }
    document["packages"] = packages
    document["relationships"] = relationships

    let data = try JSONSerialization.data(
        withJSONObject: document,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    ) + Data([0x0a])
    try data.write(to: outputURL, options: [.atomic])
}

do {
    guard CommandLine.arguments.count == 7 else { throw SPDXGenerationError.usage }
    let repositoryRoot = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true).standardizedFileURL
    let outputURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: false).standardizedFileURL
    let identity = try validatedIdentity(marketingVersion: CommandLine.arguments[3],
        buildNumber: CommandLine.arguments[4], creationTime: CommandLine.arguments[5],
        namespaceUUID: CommandLine.arguments[6])
    try generate(repositoryRoot: repositoryRoot, outputURL: outputURL, identity: identity)
} catch {
    FileHandle.standardError.write(Data("GenerateSPDX: \(error)\n".utf8))
    exit(1)
}

// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeValidationWorkflowRootContracts
import PrimeValidationWorkflowRootDriverCore

private enum SupervisorMainError: Error {
    case rejected(String)
}

private struct SupervisorInputs {
    static let expectedKeys = [
        "--run-id",
        "--prime-root",
        "--companion-root",
        "--workspace-root",
        "--evidence-root",
        "--lease-root",
        "--expected-driver-path",
        "--expected-driver-sha256",
        "--expected-driver-byte-count",
    ]

    let runID: String
    let primeRoot: URL
    let companionRoot: URL
    let workspaceRoot: URL
    let evidenceRoot: URL
    let leaseRoot: URL
    let expectedDriverPath: String
    let expectedDriverSHA256: String
    let expectedDriverByteCount: UInt64

    init(arguments: [String]) throws {
        guard arguments.count == Self.expectedKeys.count * 2 else {
            throw SupervisorMainError.rejected("argument_count")
        }
        var values: [String: String] = [:]
        var index = 0
        while index < arguments.count {
            let key = arguments[index]
            let value = arguments[index + 1]
            guard Self.expectedKeys.contains(key),
                  values.updateValue(value, forKey: key) == nil
            else {
                throw SupervisorMainError.rejected("argument_key")
            }
            index += 2
        }
        guard Set(values.keys) == Set(Self.expectedKeys),
              let runID = values["--run-id"],
              Self.isRunID(runID),
              let prime = values["--prime-root"],
              let companion = values["--companion-root"],
              let workspace = values["--workspace-root"],
              let evidence = values["--evidence-root"],
              let lease = values["--lease-root"],
              let expectedDriverPath =
                values["--expected-driver-path"],
              let expectedDriverSHA256 =
                values["--expected-driver-sha256"],
              Self.isSHA256(expectedDriverSHA256),
              let expectedDriverByteCountText =
                values["--expected-driver-byte-count"],
              let expectedDriverByteCount = UInt64(
                expectedDriverByteCountText
              ),
              expectedDriverByteCount > 0,
              String(expectedDriverByteCount)
                == expectedDriverByteCountText
        else {
            throw SupervisorMainError.rejected("argument_value")
        }
        self.runID = runID
        primeRoot = try Self.canonicalDirectory(prime)
        companionRoot = try Self.canonicalDirectory(companion)
        workspaceRoot = try Self.canonicalDirectory(workspace)
        evidenceRoot = try Self.canonicalDirectory(evidence)
        leaseRoot = try Self.canonicalDirectory(lease)
        self.expectedDriverPath = try Self.canonicalPath(
            expectedDriverPath
        )
        self.expectedDriverSHA256 = expectedDriverSHA256
        self.expectedDriverByteCount = expectedDriverByteCount
    }

    private static func canonicalDirectory(_ path: String) throws -> URL {
        let path = try canonicalPath(path)
        return URL(
            fileURLWithPath: path,
            isDirectory: true
        )
    }

    private static func canonicalPath(_ path: String) throws -> String {
        guard path.hasPrefix("/"),
              path != "/",
              !path.hasSuffix("/"),
              path.utf8.count <= 4_096,
              path.utf8.allSatisfy({ $0 >= 0x20 && $0 <= 0x7e }),
              !path.contains("\\")
        else {
            throw SupervisorMainError.rejected("noncanonical_path")
        }
        let url = URL(
            fileURLWithPath: path,
            isDirectory: true
        )
        let canonical = url.resolvingSymlinksInPath().standardizedFileURL
        guard canonical.path == path else {
            throw SupervisorMainError.rejected("noncanonical_path")
        }
        return canonical.path
    }

    private static func isRunID(_ value: String) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 128
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || $0 == 45 || $0 == 95
            }
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}

@main
private struct PrimeValidationWorkflowDriverV2 {
    private static let developerDirectorySelector =
        "/Applications/Xcode.app/Contents/Developer"

    private static let allowedCanonicalDeveloperDirectories: Set<String> = [
        "/Applications/Xcode.app/Contents/Developer",
        "/Applications/Xcode_26.5.app/Contents/Developer",
        "/Applications/Xcode_26.6.app/Contents/Developer",
    ]

    static func main() {
        do {
            try run()
        } catch {
            writeDiagnostic(
                Data(
                    (
                        "prime-validation-driver-v2: rejected "
                            + String(describing: error) + "\n"
                    ).utf8
                ),
                descriptor: STDERR_FILENO
            )
            Darwin._exit(1)
        }
    }

    private static func run() throws {
        let inputs = try SupervisorInputs(
            arguments: Array(CommandLine.arguments.dropFirst())
        )
        let developerDirectory = try canonicalDeveloperDirectory()
        let capability = try
            PrimeValidationSwiftPMBuildInventoryAdmission
            .admitPrerequisites(
                primeRepositoryURL: inputs.primeRoot,
                workspaceRootURL: inputs.workspaceRoot,
                evidenceRootURL: inputs.evidenceRoot,
                leaseDirectoryURL: inputs.leaseRoot,
                companionRepositoryURL: inputs.companionRoot,
                companionDeclaration: .init(
                    expectedPinnedHEAD:
                        PrimeValidationRunIntentV2
                        .requiredCompanionCommit,
                    declaredObservedHEAD:
                        PrimeValidationRunIntentV2
                        .requiredCompanionCommit,
                    declaredPorcelainV2Status: Data()
                ),
                developerDirectoryURL: developerDirectory
            )
        let prerequisite = try capability.consumePrerequisites()
        let guarded = try prerequisite.prepareGuardedPreExecutor()
        let handoff = try guarded.consumeCurrentProcessImageHandoff()

        let capturedContent = PrimeValidationContentBinding(
            data: try PrimeSecureRunningExecutableCapture.data()
        )
        guard inputs.expectedDriverPath
                == handoff.currentProcessExecutable
                .canonicalAbsolutePath,
              inputs.expectedDriverSHA256 == capturedContent.sha256,
              inputs.expectedDriverByteCount
                == capturedContent.byteCount,
              capturedContent.sha256
                == handoff.currentProcessExecutable.sha256,
              capturedContent.byteCount
                == handoff.currentProcessExecutable.byteCount,
              PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
                == handoff.sourceIdentitySHA256
        else {
            throw SupervisorMainError.rejected(
                "expected_supervisor_image_binding"
            )
        }
        let declaration =
            PrimeValidationDriverV2SupervisorImageDeclarationV1(
                runID: inputs.runID,
                sourceIdentitySHA256:
                    PrimeEmbeddedBuildProvenance
                    .sourceIdentitySHA256,
                executable: .init(
                    absolutePath: inputs.expectedDriverPath,
                    content: capturedContent
                )
            )
        let bound = try
            PrimeValidationDriverV2SupervisorImageBridge.bind(
                handoff: handoff,
                declaration: declaration
            )
        try bound.revalidate()
        let record = try
            PrimeValidationDriverV2SupervisorImageCanaryRecordV1(
                bound: bound
            )
        let envelope = try
            PrimeValidationDriverV2SupervisorImageCanaryEnvelopeV1(
                record: record
            )
        var output = try PrimeCanonicalJSON.encode(envelope)
        output.append(0x0a)
        try writeAll(output, descriptor: STDOUT_FILENO)
        // Stdout is only admissible when the process subsequently exits 0.
        // This terminal checkpoint keeps the live source/image window armed
        // through the complete write; a failed checkpoint forces exit 1 even
        // if the bytes reached a reader.
        try bound.revalidate()
    }

    private static func canonicalDeveloperDirectory() throws -> URL {
        let selector = URL(
            fileURLWithPath: developerDirectorySelector,
            isDirectory: true
        )
        let canonical = selector
            .resolvingSymlinksInPath()
            .standardizedFileURL
        guard allowedCanonicalDeveloperDirectories.contains(
            canonical.path
        ) else {
            throw SupervisorMainError.rejected(
                "developer_directory_selector"
            )
        }
        return canonical
    }

    private static func writeAll(
        _ data: Data,
        descriptor: Int32
    ) throws {
        try data.withUnsafeBytes { bytes in
            guard var pointer = bytes.baseAddress else {
                throw SupervisorMainError.rejected("empty_output")
            }
            var remaining = bytes.count
            while remaining > 0 {
                let count = Darwin.write(
                    descriptor,
                    pointer,
                    remaining
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw SupervisorMainError.rejected(
                        "output_write_\(errno)"
                    )
                }
                pointer = pointer.advanced(by: count)
                remaining -= count
            }
        }
    }

    private static func writeDiagnostic(
        _ data: Data,
        descriptor: Int32
    ) {
        data.withUnsafeBytes { bytes in
            guard var pointer = bytes.baseAddress else { return }
            var remaining = bytes.count
            while remaining > 0 {
                let count = Darwin.write(
                    descriptor,
                    pointer,
                    remaining
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { return }
                pointer = pointer.advanced(by: count)
                remaining -= count
            }
        }
    }
}

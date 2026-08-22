// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeValidationWorkflowDriverCore

private enum PrimeValidationDriverV2SupervisorMainError: Error {
    case rejected
}

/// Gate A owns exactly one operation: consume a canonical typed intent and
/// prove that this process's mapped image is that intent's driver image.
/// It launches no child and publishes no receipt.
@main
private struct PrimeValidationWorkflowDriverV2Supervisor {
    private static let maximumRequestByteCount = 256 * 1024
    private static let requestReadTimeoutNanoseconds:
        UInt64 = 5_000_000_000

    static func main() {
        do {
            try run()
        } catch {
            Darwin._exit(65)
        }
    }

    private static func run() throws {
        guard CommandLine.arguments.count == 1 else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        let requestData = try readCanonicalRequest()
        let request = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
            from: requestData,
            artifact: "driver_v2_supervisor_launch_request"
        )
        try request.validate()
        let intent = request.intent
        let developerDirectory = try developerDirectory(
            swiftExecutableAbsolutePath:
                intent.swiftExecutable.absolutePath
        )

        let admission = try
            PrimeValidationSwiftPMBuildInventoryAdmission
            .admitPrerequisites(
                primeRepositoryURL: URL(
                    fileURLWithPath:
                        intent.roots.repositoryRoot.absolutePath,
                    isDirectory: true
                ),
                workspaceRootURL: URL(
                    fileURLWithPath:
                        intent.roots.workspaceRoot.absolutePath,
                    isDirectory: true
                ),
                evidenceRootURL: URL(
                    fileURLWithPath:
                        intent.roots.evidenceRoot.absolutePath,
                    isDirectory: true
                ),
                leaseDirectoryURL: URL(
                    fileURLWithPath:
                        request.leaseDirectoryAbsolutePath,
                    isDirectory: true
                ),
                companionRepositoryURL: URL(
                    fileURLWithPath:
                        intent.roots.companionRoot.absolutePath,
                    isDirectory: true
                ),
                companionDeclaration: .init(
                    expectedPinnedHEAD:
                        PrimeValidationRunIntentV2
                        .requiredCompanionCommit,
                    declaredObservedHEAD: intent.companionCommit,
                    declaredPorcelainV2Status: Data()
                ),
                developerDirectoryURL: developerDirectory
            )
        let guarded = try admission
            .consumePrerequisites()
            .prepareGuardedPreExecutor()
        let bound = try
            PrimeValidationDriverV2SupervisorImageBridge.bind(
                intent: intent,
                guardedPreExecutor: guarded
            )
        try bound.revalidate()
        withExtendedLifetime(bound) {}
    }

    private static func developerDirectory(
        swiftExecutableAbsolutePath: String
    ) throws -> URL {
        let marker =
            "/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
        guard let markerRange = swiftExecutableAbsolutePath.range(
            of: marker
        ), markerRange.lowerBound
                != swiftExecutableAbsolutePath.startIndex
        else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        let declared = String(
            swiftExecutableAbsolutePath[
                ..<markerRange.lowerBound
            ]
        )
        guard declared.hasSuffix("/Contents/Developer") else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        let canonical = URL(
            fileURLWithPath: declared,
            isDirectory: true
        ).resolvingSymlinksInPath().standardizedFileURL
        guard canonical.path.hasSuffix("/Contents/Developer") else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        return canonical
    }

    private static func readCanonicalRequest() throws -> Data {
        let started = try monotonicNanoseconds()
        let (deadline, overflow) = started.addingReportingOverflow(
            requestReadTimeoutNanoseconds
        )
        guard !overflow else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 16 * 1024)
        while true {
            let now = try monotonicNanoseconds()
            guard now < deadline else {
                throw PrimeValidationDriverV2SupervisorMainError.rejected
            }
            let remainingNanoseconds = deadline - now
            let roundedMilliseconds =
                (remainingNanoseconds + 999_999) / 1_000_000
            let timeoutMilliseconds = Int32(
                min(roundedMilliseconds, UInt64(Int32.max))
            )
            var input = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0
            )
            let ready = Darwin.poll(&input, 1, timeoutMilliseconds)
            if ready < 0, errno == EINTR { continue }
            guard ready > 0,
                  input.revents & Int16(POLLERR | POLLNVAL) == 0
            else {
                throw PrimeValidationDriverV2SupervisorMainError.rejected
            }
            let count: Int = buffer.withUnsafeMutableBytes { bytes in
                Darwin.read(
                    STDIN_FILENO,
                    bytes.baseAddress,
                    bytes.count
                )
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw PrimeValidationDriverV2SupervisorMainError.rejected
            }
            if count == 0 { break }
            guard data.count <= maximumRequestByteCount - count else {
                throw PrimeValidationDriverV2SupervisorMainError.rejected
            }
            data.append(contentsOf: buffer.prefix(count))
        }
        guard !data.isEmpty else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        return data
    }

    private static func monotonicNanoseconds() throws -> UInt64 {
        var value = timespec()
        guard Darwin.clock_gettime(
            CLOCK_MONOTONIC_RAW,
            &value
        ) == 0,
        value.tv_sec >= 0,
        value.tv_nsec >= 0,
        value.tv_nsec < 1_000_000_000
        else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        let seconds = UInt64(value.tv_sec)
        let (scaled, overflow) = seconds.multipliedReportingOverflow(
            by: 1_000_000_000
        )
        guard !overflow else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        let (result, additionOverflow) = scaled.addingReportingOverflow(
            UInt64(value.tv_nsec)
        )
        guard !additionOverflow else {
            throw PrimeValidationDriverV2SupervisorMainError.rejected
        }
        return result
    }
}

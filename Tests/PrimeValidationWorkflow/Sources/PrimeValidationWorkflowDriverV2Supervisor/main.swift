// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeValidationWorkflowDriverCore

private enum PrimeValidationDriverV2SupervisorMainError: Error {
    case rejected
}

private enum PrimeValidationDriverV2SupervisorExitStatus {
    static let transport: Int32 = 65
    static let developerDirectory: Int32 = 66
    static let prerequisiteAdmission: Int32 = 71
    static let admissionCompanionDeclaration: Int32 = 74
    static let admissionPrimeRepository: Int32 = 75
    static let admissionWorkspaceRoot: Int32 = 76
    static let admissionWorkspacePrivateAndEmpty: Int32 = 77
    static let admissionEvidenceRoot: Int32 = 78
    static let admissionEvidencePrivateAndEmpty: Int32 = 79
    static let admissionCompanionRepository: Int32 = 80
    static let admissionLeaseDirectory: Int32 = 81
    static let admissionLeasePrivateAndEmpty: Int32 = 82
    static let admissionRootTopology: Int32 = 83
    static let admissionExclusiveLease: Int32 = 84
    static let admissionPostLeaseDirectory: Int32 = 85
    static let admissionSourceSnapshot: Int32 = 86
    static let admissionPackageResolvedBinding: Int32 = 87
    static let admissionPrimeSourceIdentitySnapshot: Int32 = 88
    static let admissionCompanionContentSnapshot: Int32 = 89
    static let admissionHeldToolchain: Int32 = 90
    static let prerequisiteConsume: Int32 = 72
    static let guardPreparation: Int32 = 73
    static let supervisorImage: Int32 = 67
    static let fixedProbes: Int32 = 68
    static let finalRevalidation: Int32 = 69
    static let fixedBuild: Int32 = 91
}

/// Gate A's transport remains one closed canonical typed intent frame. After
/// this process binds that intent to its mapped image, Gate E unconditionally
/// runs the facade's zero-argument fixed Git and Swift probe transition.
@main
private struct PrimeValidationWorkflowDriverV2Supervisor {
    private static let maximumRequestByteCount = 256 * 1024
    private static let requestReadTimeoutNanoseconds:
        UInt64 = 5_000_000_000

    static func main() {
        let request: PrimeValidationDriverV2SupervisorLaunchRequestV1
        do {
            request = try requestFromStandardInput()
        } catch {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus.transport
            )
        }
        let intent = request.intent

        let developerDirectoryURL: URL
        do {
            developerDirectoryURL = try developerDirectory(
                swiftExecutableAbsolutePath:
                    intent.swiftExecutable.absolutePath
            )
        } catch {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus
                    .developerDirectory
            )
        }

        let admission:
            PrimeValidationSwiftPMBuildInventoryAdmissionCapability
        do {
            admission = try
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
                    developerDirectoryURL: developerDirectoryURL
                )
        } catch {
            let status = prerequisiteAdmissionExitStatus(
                for: error
            ) ?? PrimeValidationDriverV2SupervisorExitStatus
                .prerequisiteAdmission
            Darwin._exit(
                status
            )
        }

        let prerequisite:
            PrimeValidationSwiftPMBuildInventoryPrerequisite
        do {
            prerequisite = try admission.consumePrerequisites()
        } catch {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus
                    .prerequisiteConsume
            )
        }

        let guarded:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
        do {
            guarded = try prerequisite.prepareGuardedPreExecutor()
        } catch {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus
                    .guardPreparation
            )
        }

        let bound: PrimeValidationDriverV2SupervisorImageCapability
        do {
            bound = try PrimeValidationDriverV2SupervisorImageBridge.bind(
                intent: intent,
                guardedPreExecutor: guarded
            )
            try bound.revalidate()
        } catch {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus.supervisorImage
            )
        }

        guard #available(macOS 26.0, *) else {
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus.fixedProbes
            )
        }
        let fixedProbeBinding: PrimeValidationDriverV2FixedProbeBinding
        do {
            fixedProbeBinding = try
                PrimeValidationDriverV2FixedProbeBindingBridge.bind(
                    intent: intent,
                    supervisorImage: bound
                )
        } catch {
            reportProbeFailure(
                error,
                status: PrimeValidationDriverV2SupervisorExitStatus.fixedProbes
            )
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus.fixedProbes
            )
        }

        if request.terminalGate == .gateF {
            do {
                let buildBinding = try fixedProbeBinding.executeBuild()
                try buildBinding.revalidate()
                withExtendedLifetime(buildBinding) {}
            } catch {
                reportProbeFailure(
                    error,
                    status: PrimeValidationDriverV2SupervisorExitStatus.fixedBuild,
                    terminalGate: .gateF
                )
                Darwin._exit(PrimeValidationDriverV2SupervisorExitStatus.fixedBuild)
            }
            return
        }

        do {
            // Revalidation requires the exact four-authority remainder before
            // its final retained-lifetime deadline and continuity accept.
            try fixedProbeBinding.revalidate()
            withExtendedLifetime(fixedProbeBinding) {}
        } catch {
            reportProbeFailure(
                error,
                status: PrimeValidationDriverV2SupervisorExitStatus
                    .finalRevalidation
            )
            Darwin._exit(
                PrimeValidationDriverV2SupervisorExitStatus.finalRevalidation
            )
        }
    }

    private static func reportProbeFailure(
        _ error: Error,
        status: Int32,
        terminalGate: PrimeValidationDriverV2TerminalGate = .gateE
    ) {
        let flags = fcntl(STDERR_FILENO, F_GETFL)
        guard flags >= 0,
              fcntl(STDERR_FILENO, F_SETFL, flags | O_NONBLOCK) == 0,
              fcntl(STDERR_FILENO, F_SETNOSIGPIPE, 1) == 0
        else { return }
        let detail = String(reflecting: error).utf8.prefix(384).map { byte in
            (byte >= 0x21 && byte <= 0x7e) ? byte : UInt8(0x5f)
        }
        let gate = terminalGate == .gateF ? "f" : "e"
        let message = Array("gate_\(gate)_probe_rejected status=\(status) detail=".utf8)
            + detail + [UInt8(0x0a)]
        // Observational stderr only, after the binding unwinds its cleanup.
        // One bounded write cannot block on a pipe or replace the exit status.
        _ = message.withUnsafeBytes {
            Darwin.write(STDERR_FILENO, $0.baseAddress, $0.count)
        }
    }

    private static func prerequisiteAdmissionExitStatus(
        for error: Error
    ) -> Int32? {
        guard let site = error as?
                PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite
        else {
            return nil
        }
        switch site {
        case .companionDeclaration:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionCompanionDeclaration
        case .primeRepository:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionPrimeRepository
        case .workspaceRoot:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionWorkspaceRoot
        case .workspacePrivateAndEmpty:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionWorkspacePrivateAndEmpty
        case .evidenceRoot:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionEvidenceRoot
        case .evidencePrivateAndEmpty:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionEvidencePrivateAndEmpty
        case .companionRepository:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionCompanionRepository
        case .leaseDirectory:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionLeaseDirectory
        case .leasePrivateAndEmpty:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionLeasePrivateAndEmpty
        case .rootTopology:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionRootTopology
        case .exclusiveLease:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionExclusiveLease
        case .postLeaseDirectory:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionPostLeaseDirectory
        case .sourceSnapshot:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionSourceSnapshot
        case .packageResolvedBinding:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionPackageResolvedBinding
        case .primeSourceIdentitySnapshot:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionPrimeSourceIdentitySnapshot
        case .companionContentSnapshot:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionCompanionContentSnapshot
        case .heldToolchain:
            return PrimeValidationDriverV2SupervisorExitStatus
                .admissionHeldToolchain
        }
    }

    private static func requestFromStandardInput() throws
        -> PrimeValidationDriverV2SupervisorLaunchRequestV1
    {
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
        return request
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

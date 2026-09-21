import Darwin
import DisposalProjectionCore
import Foundation

@main
struct ErgenticsDisposalProjectorMain {
    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(64) }
        let environment = ProcessInfo.processInfo.environment
        let keys = [
            "ERGENTICS_DISPOSAL_JOURNAL_PATH",
            "ERGENTICS_DISPOSAL_JOURNAL_SHA256",
            "ERGENTICS_DISPOSAL_OUTPUT_ROOT",
        ]
        guard keys.allSatisfy({ environment[$0] != nil }) else { _exit(64) }
        guard environment["ERGENTICS_DISPOSAL_PREDECESSOR_PROJECTION_ID"] == nil else {
            _exit(64)
        }
        let predecessor: DisposalProjectionPredecessorReference?
        switch (
            environment["ERGENTICS_DISPOSAL_PREDECESSOR_ROOT"],
            environment["ERGENTICS_DISPOSAL_PREDECESSOR_SEAL_SHA256"]
        ) {
        case (nil, nil):
            predecessor = nil
        case (.some(let root), .some(let seal)) where !root.isEmpty && !seal.isEmpty:
            predecessor = .init(rootPath: root, expectedSealSHA256: seal)
        default:
            _exit(64)
        }
        do {
            let journalPath = environment[keys[0]]!
            let expectedSHA256 = environment[keys[1]]!
            let outputRoot = environment[keys[2]]!
            let journal = try DisposalJournalAdmission.readExact(
                path: journalPath,
                expectedSHA256: expectedSHA256)
            let report = try DisposalProjectionSetBuilder.build(
                request: .init(
                    journal: journal,
                    journalLogicalPath: journalPath,
                    predecessor: predecessor),
                outputRootPath: outputRoot)
            let line = "{" + [
                "\"authority_vector\":\"00000000\"",
                "\"evidence_sha256\":\"\(report.evidenceSHA256)\"",
                "\"frame_count\":\(report.frameCount)",
                "\"graph_sha256\":\"\(report.graphSHA256)\"",
                "\"metrics_sha256\":\"\(report.metricsSHA256)\"",
                "\"projection_id\":\"\(report.projectionID)\"",
                "\"seal_sha256\":\"\(report.sealSHA256)\"",
                "\"status\":\"\(report.status)\"",
            ].joined(separator: ",") + "}\n"
            FileHandle.standardOutput.write(Data(line.utf8))
            _exit(0)
        } catch let rejection as DisposalProjectionRejection {
            let line = "{\"code\":\"\(escape(rejection.code))\",\"status\":\"FAIL_CLOSED\"}\n"
            FileHandle.standardError.write(Data(line.utf8))
            _exit(70)
        } catch {
            _exit(70)
        }
    }

    private static func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }
}

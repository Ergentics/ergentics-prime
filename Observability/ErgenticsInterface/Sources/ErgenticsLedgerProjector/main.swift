import Darwin
import Foundation
import LedgerProjectionCore

@main
struct ErgenticsLedgerProjectorMain {
    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(64) }
        do {
            let report = try LedgerProjectionBuilder.buildPinnedProjection()
            let line = "{" + [
                "\"database_bytes\":\(report.databaseBytes)",
                "\"database_path\":\"\(report.databasePath)\"",
                "\"database_sha256\":\"\(report.databaseSHA256)\"",
                "\"projection_id\":\"\(report.projectionID)\"",
                "\"seal_path\":\"\(report.sealPath)\"",
                "\"seal_sha256\":\"\(report.sealSHA256)\"",
                "\"status\":\"PASS_NONAUTHORITATIVE_PROJECTION\"",
            ].joined(separator: ",") + "}\n"
            FileHandle.standardOutput.write(Data(line.utf8))
            _exit(0)
        } catch let error as LedgerProjectionRejection {
            let line = "{\"code\":\"\(escape(error.code))\",\"status\":\"FAIL_CLOSED\"}\n"
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

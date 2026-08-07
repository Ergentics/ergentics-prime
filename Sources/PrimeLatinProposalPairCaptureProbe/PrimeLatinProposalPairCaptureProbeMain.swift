import Foundation
import PrimeLatinProposalPairCapture

@main
struct PrimeLatinProposalPairCaptureProbeMain {
    static func main() throws {
        let arguments = try PrimeLatinProposalPairCaptureArguments.parse(
            Array(CommandLine.arguments.dropFirst())
        )
        let capture = try PrimeLatinProposalPairCapture.capture(
            labRoot: arguments.labRoot,
            pairSHA256: arguments.pairSHA256
        )
        var ephemeralSummary =
            try capture.ephemeralSummary()
            .canonicalData()
        ephemeralSummary.append(0x0a)
        try FileHandle.standardOutput.write(
            contentsOf: ephemeralSummary
        )
    }
}

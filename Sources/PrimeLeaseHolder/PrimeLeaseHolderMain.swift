import Foundation
import PrimeCore

private enum PrimeLeaseHolderError:
    Error,
    CustomStringConvertible
{
    case invalidArguments

    var description: String {
        "usage: PrimeLeaseHolder --lease-file /absolute/private/path.lock"
    }
}

@main
enum PrimeLeaseHolderCLI {
    static func main() {
        do {
            let arguments =
                Array(CommandLine.arguments.dropFirst())
            guard arguments.count == 2,
                  arguments[0] == "--lease-file"
            else {
                throw PrimeLeaseHolderError
                    .invalidArguments
            }
            let leaseURL = URL(
                fileURLWithPath: arguments[1]
            )
            let lease =
                try PrimeExclusiveProcessLease.acquire(
                    at: leaseURL
                )
            print(
                "PrimeLeaseHolder: lease acquired; submit one line on stdin to release"
            )
            fflush(stdout)
            _ = readLine()
            lease.release()
            print("PrimeLeaseHolder: lease released")
        } catch {
            fputs("PrimeLeaseHolder: \(error)\n", stderr)
            Foundation.exit(1)
        }
    }
}

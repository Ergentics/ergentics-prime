import Darwin
import Foundation
import GateEStaticBootstrapCore

// No request framing, path loader, command language, or environment protocol.
// Source-only checkpoint: this image still requires separately identified builds
// and explicit future launch authority before it may be entered.
@main
private struct ErgenticsGateEStaticBootstrapMain {
    static func main() {
        guard CommandLine.arguments.count == 1,
              ProcessInfo.processInfo.environment.isEmpty else { _exit(70) }
        _exit(GateEStaticBootstrap.run())
    }
}

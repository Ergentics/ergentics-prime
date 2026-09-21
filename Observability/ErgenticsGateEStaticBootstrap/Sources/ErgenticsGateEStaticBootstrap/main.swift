import Darwin
import Foundation
import GateEStaticBootstrapCore

// No request framing, path loader, command language, or environment protocol.
// Source-only checkpoint: this image still requires separately identified builds
// and explicit future launch authority before it may be entered.
@main
private struct ErgenticsGateEStaticBootstrapMain {
    static func main() {
        // Retired historical launch route: post-kill exact reap can wait forever.
        // Preserve the frozen experiment body and its issued evidence below.
        // This source guard does not stop existing images or live instances.
        // Reject before argument/environment intake, journals, or child entry.
        Darwin._exit(70)

        guard CommandLine.arguments.count == 1,
              ProcessInfo.processInfo.environment.isEmpty else { _exit(70) }
        _exit(GateEStaticBootstrap.run())
    }
}

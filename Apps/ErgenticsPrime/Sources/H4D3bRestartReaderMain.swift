import Darwin

@main
enum H4D3bRestartReaderMain {
    static func main() {
        guard CommandLine.arguments.count == 2 else {
            Darwin.exit(70)
        }
        switch HypervisorStageH4DualStreamRestartInspection.inspect(
            rootPath: CommandLine.arguments[1]
        ) {
        case .validV3DualStreamThreeWayJoin:
            Darwin.exit(0)
        case .rejected:
            Darwin.exit(70)
        }
    }
}

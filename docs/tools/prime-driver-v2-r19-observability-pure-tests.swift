import Darwin

@main
private struct PrimeDriverV2R19ObservabilityPureTests {
    static func main() {
        do {
            try runObservabilityPureTests()
            let line = "PASS prime-driver-v2-r19-observability-pure-tests\n"
            _ = line.withCString { write(STDOUT_FILENO, $0, strlen($0)) }
            _exit(0)
        } catch {
            let line = "FAIL \(error)\n"
            _ = line.withCString { write(STDERR_FILENO, $0, strlen($0)) }
            _exit(1)
        }
    }
}

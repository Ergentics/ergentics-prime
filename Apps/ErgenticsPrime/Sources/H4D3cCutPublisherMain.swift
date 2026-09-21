import Darwin
import Foundation

@main
enum H4D3cCutPublisherMain {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4D3 = HypervisorStageH4DualStreamPersistence

    private static let commandDescriptor: Int32 = 3
    private static let gateDescriptor: Int32 = 4
    private static let eventDescriptor: Int32 = 5
    private static let softwareFailure: Int32 = 70

    private enum Mode: Equatable {
        case runToCompletion
        case cut(at: UInt8)
    }

    private struct Command {
        let mode: Mode
    }

    private enum EventKind: UInt8 {
        case passed = 1
        case reached = 2
        case normalTerminal = 3
        case failure = 4
    }

    private final class ProtocolState: @unchecked Sendable {
        private let mode: Mode
        private var nextInterstice: UInt8 = 0
        private var nextSequence: UInt16 = 0
        private var selectedGateReleased = false
        private var commandOpen = true
        private var gateOpen = true
        private var eventOpen = true
        private var terminalWritten = false

        init(mode: Mode) {
            self.mode = mode
        }

        func observe(_ interstice: H4D3.TestPublicationInterstice) {
            let ordinal = interstice.rawValue
            guard ordinal == nextInterstice, ordinal < 10 else {
                fail()
            }

            switch mode {
            case .runToCompletion:
                writeFrame(kind: .passed, ordinal: ordinal, status: 0)
            case .cut(let selected):
                if ordinal < selected {
                    writeFrame(kind: .passed, ordinal: ordinal, status: 0)
                } else if ordinal == selected {
                    writeFrame(kind: .reached, ordinal: ordinal, status: 0)
                    readSelectedGateOrFail()
                    selectedGateReleased = true
                } else {
                    guard selectedGateReleased else { fail() }
                    writeFrame(kind: .passed, ordinal: ordinal, status: 0)
                }
            }
            nextInterstice += 1
        }

        func succeed() -> Never {
            guard nextInterstice == 10 else { fail() }
            if case .cut = mode {
                guard selectedGateReleased else { fail() }
            }
            guard closeCommandExactly(), closeGateExactly() else { fail() }
            writeFrame(kind: .normalTerminal, ordinal: 255, status: 0)
            terminalWritten = true
            let eventCloseOK = closeEventExactly()
            Darwin.exit(eventCloseOK ? 0 : H4D3cCutPublisherMain.softwareFailure)
        }

        func fail() -> Never {
            if eventOpen && !terminalWritten {
                writeFrame(kind: .failure, ordinal: 255,
                           status: UInt32(H4D3cCutPublisherMain.softwareFailure))
                terminalWritten = true
            }
            closeAllProtocolDescriptors()
            Darwin.exit(H4D3cCutPublisherMain.softwareFailure)
        }

        func closeCommandExactly() -> Bool {
            closeExactly(H4D3cCutPublisherMain.commandDescriptor,
                         open: &commandOpen)
        }

        private func closeGateExactly() -> Bool {
            closeExactly(H4D3cCutPublisherMain.gateDescriptor, open: &gateOpen)
        }

        private func closeEventExactly() -> Bool {
            closeExactly(H4D3cCutPublisherMain.eventDescriptor, open: &eventOpen)
        }

        private func closeExactly(_ descriptor: Int32,
                                  open: inout Bool) -> Bool {
            guard open else { return true }
            open = false
            return Darwin.close(descriptor) == 0
        }

        private func closeAllProtocolDescriptors() {
            _ = closeCommandExactly()
            _ = closeGateExactly()
            _ = closeEventExactly()
        }

        private func writeFrame(kind: EventKind, ordinal: UInt8,
                                status: UInt32) {
            guard eventOpen, !terminalWritten else { eventWriteFailed() }
            var frame = Array("EPRD3CE1".utf8)
            frame.append(kind.rawValue)
            frame.append(ordinal)
            frame.append(UInt8(truncatingIfNeeded: nextSequence >> 8))
            frame.append(UInt8(truncatingIfNeeded: nextSequence))
            frame.append(UInt8(truncatingIfNeeded: status >> 24))
            frame.append(UInt8(truncatingIfNeeded: status >> 16))
            frame.append(UInt8(truncatingIfNeeded: status >> 8))
            frame.append(UInt8(truncatingIfNeeded: status))
            guard frame.count == 16 else { eventWriteFailed() }

            while true {
                let result = frame.withUnsafeBytes { bytes in
                    Darwin.write(H4D3cCutPublisherMain.eventDescriptor,
                                 bytes.baseAddress, bytes.count)
                }
                if result == frame.count {
                    nextSequence &+= 1
                    return
                }
                if result < 0 && errno == EINTR { continue }
                eventWriteFailed()
            }
        }

        private func eventWriteFailed() -> Never {
            closeAllProtocolDescriptors()
            Darwin.exit(H4D3cCutPublisherMain.softwareFailure)
        }

        private func readSelectedGateOrFail() {
            guard gateOpen else { fail() }
            var release: UInt8 = 0
            while true {
                let result = Darwin.read(
                    H4D3cCutPublisherMain.gateDescriptor, &release, 1
                )
                if result == 1 { break }
                if result < 0 && errno == EINTR { continue }
                fail()
            }
            guard release == 0xa5 else { fail() }

            var trailing: UInt8 = 0
            while true {
                let result = Darwin.read(
                    H4D3cCutPublisherMain.gateDescriptor, &trailing, 1
                )
                if result == 0 { break }
                if result < 0 && errno == EINTR { continue }
                fail()
            }
            guard closeGateExactly() else { fail() }
        }
    }

    static func main() {
        guard configureEventDescriptor() else {
            closeInitialProtocolDescriptors()
            Darwin.exit(softwareFailure)
        }

        let commandBytes: [UInt8]
        do {
            commandBytes = try readCommandBytes()
        } catch {
            let state = ProtocolState(mode: .runToCompletion)
            state.fail()
        }

        guard let command = parseCommand(commandBytes) else {
            let state = ProtocolState(mode: .runToCompletion)
            state.fail()
        }
        let state = ProtocolState(mode: command.mode)
        guard state.closeCommandExactly() else { state.fail() }

        _ = Darwin.umask(mode_t(0o077))
        guard CommandLine.arguments.count == 2,
              let rootURL = canonicalRootURL(CommandLine.arguments[1]) else {
            state.fail()
        }

        do {
            let source = H4.Source(
                origin: .h3StructuralFixture,
                disposition: .contractOnly,
                subject: .h3Checkpoint,
                epoch: "44444444-4444-4444-8444-444444444444",
                receiptRoot:
                    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                claimState: .observedNonPass,
                predicateCount: 19,
                authorityVector: "00000000",
                rawDiagnostic: nil
            )
            guard let capability = H4.issueTestCapability(
                source: source,
                validThroughTick: .max
            ), let dispatcher = H4.consumeTestDispatcher(
                capability: capability,
                request: H4.fixedRequest(epoch: source.epoch),
                source: source,
                deliveryTick: { 1 }
            ) else {
                state.fail()
            }
            let bound = try dispatcher.bindCanonicalStreams().get()
            let coordinator = try H4D3.makeTestCoordinator(
                bound: bound,
                rootURL: rootURL,
                storeValidThroughTick: .max,
                storeReadTick: { 1 },
                publicationIntersticeForTest: { interstice in
                    state.observe(interstice)
                }
            )
            guard case .admitted = coordinator.persist() else { state.fail() }
            state.succeed()
        } catch {
            state.fail()
        }
    }

    private static func configureEventDescriptor() -> Bool {
        guard fcntl(eventDescriptor, F_SETNOSIGPIPE, 1) == 0 else {
            return false
        }
        return fcntl(eventDescriptor, F_GETNOSIGPIPE) == 1
    }

    private static func readCommandBytes() throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 16)
        var offset = 0
        while offset < bytes.count {
            let result = bytes.withUnsafeMutableBytes { buffer in
                Darwin.read(commandDescriptor,
                            buffer.baseAddress?.advanced(by: offset),
                            buffer.count - offset)
            }
            if result > 0 {
                offset += result
            } else if result == 0 {
                throw CommandReadFailure.rejected
            } else if errno != EINTR {
                throw CommandReadFailure.rejected
            }
        }

        var trailing: UInt8 = 0
        while true {
            let result = Darwin.read(commandDescriptor, &trailing, 1)
            if result == 0 { return bytes }
            if result < 0 && errno == EINTR { continue }
            throw CommandReadFailure.rejected
        }
    }

    private static func parseCommand(_ bytes: [UInt8]) -> Command? {
        guard bytes.count == 16,
              bytes[0..<8].elementsEqual("EPRD3CC1".utf8),
              bytes[10..<16].allSatisfy({ $0 == 0 }) else {
            return nil
        }
        switch (bytes[8], bytes[9]) {
        case (0, 255):
            return Command(mode: .runToCompletion)
        case (1, 0...9):
            return Command(mode: .cut(at: bytes[9]))
        default:
            return nil
        }
    }

    private static func canonicalRootURL(_ path: String) -> URL? {
        guard path != "/", path.hasPrefix("/"), !path.hasSuffix("/"),
              !path.contains("//"), !path.utf8.contains(0),
              !path.split(separator: "/").contains(where: {
                  $0 == "." || $0 == ".."
              }), let resolved = realpath(path, nil) else {
            return nil
        }
        defer { free(resolved) }
        guard let canonical = String(validatingCString: resolved),
              canonical == path else { return nil }
        let url = URL(fileURLWithPath: path, isDirectory: true)
        return url.path == path ? url : nil
    }

    private static func closeInitialProtocolDescriptors() {
        _ = Darwin.close(commandDescriptor)
        _ = Darwin.close(gateDescriptor)
        _ = Darwin.close(eventDescriptor)
    }

    private enum CommandReadFailure: Error {
        case rejected
    }
}

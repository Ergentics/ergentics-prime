import Foundation
import XCTest

final class HypervisorStageH4OwnerBindingTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4C = HypervisorStageH4CanonicalStreams
    private typealias H4D = HypervisorStageH4OwnerBinding

    private let epoch = "11111111-1111-4111-8111-111111111111"
    private let otherEpoch = "22222222-2222-4222-8222-222222222222"

    private enum TestFailure: Error {
        case forcedProjectionFailure
        case timedOut
    }

    private final class LockedTick: @unchecked Sendable {
        private let lock = NSLock()
        private var value: UInt64

        init(_ value: UInt64) { self.value = value }

        func set(_ newValue: UInt64) {
            lock.lock()
            value = newValue
            lock.unlock()
        }

        func read() -> UInt64 {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
    }

    private final class LockedBindingResults: @unchecked Sendable {
        private let lock = NSLock()
        private var successes = 0
        private var failures: [H4D.Failure] = []

        func append(_ result: Result<H4D.OwnerBoundCanonicalProjection, H4D.Failure>) {
            lock.lock()
            switch result {
            case .success:
                successes += 1
            case .failure(let failure):
                failures.append(failure)
            }
            lock.unlock()
        }

        func snapshot() -> (successes: Int, failures: [H4D.Failure]) {
            lock.lock()
            defer { lock.unlock() }
            return (successes, failures)
        }
    }

    private final class LockedRaceResult: @unchecked Sendable {
        private let lock = NSLock()
        private var bindSucceeded = false
        private var extractionSucceeded = false

        func recordBind(_ value: Bool) {
            lock.lock()
            bindSucceeded = value
            lock.unlock()
        }

        func recordExtraction(_ value: Bool) {
            lock.lock()
            extractionSucceeded = value
            lock.unlock()
        }

        func snapshot() -> (bind: Bool, extraction: Bool) {
            lock.lock()
            defer { lock.unlock() }
            return (bindSucceeded, extractionSucceeded)
        }
    }

    private func source(
        epoch: String? = nil,
        receiptRoot: String = String(repeating: "a", count: 64),
        rawDiagnostic: Data? = nil
    ) -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: .h3Checkpoint,
            epoch: epoch ?? self.epoch,
            receiptRoot: receiptRoot,
            claimState: .observedNonPass,
            predicateCount: 19,
            authorityVector: "00000000",
            rawDiagnostic: rawDiagnostic
        )
    }

    private func dispatcher(
        source: H4.Source? = nil,
        validThroughTick: UInt64 = .max,
        deliveryTick: @escaping @Sendable () -> UInt64 = { mach_continuous_time() }
    ) throws -> H4.DestinationDispatcher {
        let input = source ?? self.source()
        let capability = try XCTUnwrap(H4.issueTestCapability(
            source: input,
            validThroughTick: validThroughTick
        ))
        return try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: H4.fixedRequest(epoch: input.epoch),
            source: input,
            deliveryTick: deliveryTick
        ))
    }

    private func assertBindingFailure(
        _ result: Result<H4D.OwnerBoundCanonicalProjection, H4D.Failure>,
        _ expected: H4D.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result {
        case .success:
            XCTFail("Expected H4-D binding failure", file: file, line: line)
        case .failure(let failure):
            XCTAssertEqual(failure, expected, file: file, line: line)
        }
    }

    func testFreshZeroArgumentBindPreservesCanonicalVectorsAndPrivateAnchor() throws {
        let input = source()
        let value = try dispatcher(source: input)
        let bound = try value.bindCanonicalStreams().get()
        let canonical = bound.canonicalTest

        XCTAssertEqual(
            canonical.json,
            Data((
                "{\"authority_vector\":\"00000000\"," +
                "\"claim_state\":\"OBSERVED_NONPASS\"," +
                "\"predicate_count\":19," +
                "\"schema\":\"com.ergentics.provenance.hypervisor." +
                "h4.canonical-receipt.v1\"}"
            ).utf8)
        )
        XCTAssertEqual(canonical.reconstruction.semantic.predicateCount, 19)
        XCTAssertTrue(canonical.reconstruction.jsonRoundTripExact)
        XCTAssertTrue(canonical.reconstruction.cborRoundTripExact)
        XCTAssertTrue(canonical.reconstruction.semanticJoinExact)
        XCTAssertTrue(bound.bindingMatchesTest(epoch: input.epoch))

        assertBindingFailure(value.bindCanonicalStreams(), .alreadyConsumed)
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.alreadyConsumed))
        XCTAssertNoThrow(try value.takeReleasePresentation().get())
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.alreadyConsumed))
        XCTAssertNoThrow(try value.takeGraphPreparation().get())
        XCTAssertNoThrow(try value.takeMerklePreparation().get())
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.alreadyConsumed))
    }

    func testEqualSemanticsAndEpochStillProduceDistinctPrivateOwners() throws {
        let first = try dispatcher().bindCanonicalStreams().get()
        let second = try dispatcher().bindCanonicalStreams().get()

        XCTAssertEqual(first.canonicalTest, second.canonicalTest)
        XCTAssertNotEqual(first.ownerIdentityTest, second.ownerIdentityTest)
    }

    func testDifferentEpochsStayPrivateAndProduceDistinctOwners() throws {
        let first = try dispatcher(source: source(epoch: epoch))
            .bindCanonicalStreams().get()
        let second = try dispatcher(source: source(epoch: otherEpoch))
            .bindCanonicalStreams().get()

        XCTAssertEqual(first.canonicalTest, second.canonicalTest)
        XCTAssertNotEqual(first.ownerIdentityTest, second.ownerIdentityTest)
        for canonical in [first.canonicalTest, second.canonicalTest] {
            XCTAssertFalse(String(decoding: canonical.json, as: UTF8.self).contains(epoch))
            XCTAssertFalse(String(decoding: canonical.json, as: UTF8.self).contains(otherEpoch))
            XCTAssertFalse(String(decoding: canonical.cbor, as: UTF8.self).contains(epoch))
            XCTAssertFalse(String(decoding: canonical.cbor, as: UTF8.self).contains(otherEpoch))
        }
    }

    func testSequentialReplayHasExactlyOneWinner() throws {
        let value = try dispatcher()
        XCTAssertNoThrow(try value.bindCanonicalStreams().get())
        for _ in 0..<16 {
            assertBindingFailure(value.bindCanonicalStreams(), .alreadyConsumed)
        }
    }

    func testConcurrentBindHasExactlyOneWinner() throws {
        let value = try dispatcher()
        let queue = DispatchQueue(
            label: "h4.owner-binding.concurrent",
            attributes: .concurrent
        )
        let group = DispatchGroup()
        let results = LockedBindingResults()

        for _ in 0..<32 {
            group.enter()
            queue.async {
                results.append(value.bindCanonicalStreams())
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        let observed = results.snapshot()
        XCTAssertEqual(observed.successes, 1)
        XCTAssertEqual(observed.failures.count, 31)
        XCTAssertTrue(observed.failures.allSatisfy {
            $0 == .inProgress || $0 == .alreadyConsumed
        })
    }

    func testAnyPriorExtractionPoisonsBindingAndEveryRemainingExit() throws {
        let value = try dispatcher()
        _ = try value.takeReleasePresentation().get()

        assertBindingFailure(value.bindCanonicalStreams(), .priorExtraction)
        assertBindingFailure(value.bindCanonicalStreams(), .poisoned)
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.poisoned))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.poisoned))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.poisoned))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.poisoned))
    }

    func testProjectionFailurePoisonsDispatcherAndEmitsNoSuccess() throws {
        let value = try dispatcher()

        assertBindingFailure(value.bindCanonicalStreamsTest { _ in
            throw TestFailure.forcedProjectionFailure
        }, .projectionRejected)
        assertBindingFailure(value.bindCanonicalStreams(), .poisoned)
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.poisoned))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.poisoned))
    }

    func testTestProjectorCannotSubstituteAnotherDispatcherOwner() throws {
        let foreign = try dispatcher().bindCanonicalStreams().get()
        let value = try dispatcher()

        assertBindingFailure(value.bindCanonicalStreamsTest { _ in foreign }, .ownerMismatch)
        assertBindingFailure(value.bindCanonicalStreams(), .poisoned)
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.poisoned))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.poisoned))
    }

    func testExpiredBeforeCodecPoisonsWithoutCallingProjector() throws {
        let called = LockedBindingResults()
        let value = try dispatcher(
            validThroughTick: UInt64.max - 1,
            deliveryTick: { UInt64.max }
        )

        assertBindingFailure(value.bindCanonicalStreamsTest { input in
            called.append(.success(try H4C.projectBound(input)))
            return try H4C.projectBound(input)
        }, .expired)
        XCTAssertEqual(called.snapshot().successes, 0)
        assertBindingFailure(value.bindCanonicalStreams(), .poisoned)
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.poisoned))
    }

    func testExpiryAfterCodecPoisonsAndDropsConstructedProjection() throws {
        let tick = LockedTick(UInt64.max - 1)
        let value = try dispatcher(
            validThroughTick: UInt64.max - 1,
            deliveryTick: { tick.read() }
        )

        assertBindingFailure(value.bindCanonicalStreamsTest { input in
            let projected = try H4C.projectBound(input)
            tick.set(UInt64.max)
            return projected
        }, .expired)
        assertBindingFailure(value.bindCanonicalStreams(), .poisoned)
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.poisoned))
    }

    func testPostBindSuccessorsStillRevalidateSharedExpiry() throws {
        let tick = LockedTick(UInt64.max - 1)
        let value = try dispatcher(
            validThroughTick: UInt64.max - 1,
            deliveryTick: { tick.read() }
        )

        XCTAssertNoThrow(try value.bindCanonicalStreams().get())
        tick.set(UInt64.max)

        XCTAssertEqual(value.takeReleasePresentation(), .failure(.expired))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.expired))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.expired))
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.alreadyConsumed))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.alreadyConsumed))
    }

    func testAllOtherExitsRejectWhileCanonicalCodecOwnsClaim() throws {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let results = LockedBindingResults()
        let value = try dispatcher()
        let projector: @Sendable (H4.CanonicalStreamInput) throws ->
            H4D.OwnerBoundCanonicalProjection = { input in
            entered.signal()
            guard release.wait(timeout: .now() + 5) == .success else {
                throw TestFailure.timedOut
            }
            return try H4C.projectBound(input)
        }
        let queue = DispatchQueue(label: "h4.owner-binding.blocked-codec")
        let group = DispatchGroup()
        group.enter()
        queue.async {
            results.append(value.bindCanonicalStreamsTest(canonicalProject: projector))
            group.leave()
        }

        XCTAssertEqual(entered.wait(timeout: .now() + 5), .success)
        assertBindingFailure(value.bindCanonicalStreams(), .inProgress)
        XCTAssertEqual(value.takeInternalReceipt(), .failure(.bindingInProgress))
        XCTAssertEqual(value.takeReleasePresentation(), .failure(.bindingInProgress))
        XCTAssertEqual(value.takeSQLiteProjection(), .failure(.bindingInProgress))
        XCTAssertEqual(value.takeGraphPreparation(), .failure(.bindingInProgress))
        XCTAssertEqual(value.takeMerklePreparation(), .failure(.bindingInProgress))
        release.signal()
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(results.snapshot().successes, 1)
    }

    func testBindVersusCanonicalExtractionNeverYieldsBoth() throws {
        let queue = DispatchQueue(
            label: "h4.owner-binding.extraction-race",
            attributes: .concurrent
        )
        for _ in 0..<64 {
            let value = try dispatcher()
            let result = LockedRaceResult()
            let group = DispatchGroup()

            group.enter()
            queue.async {
                if case .success = value.bindCanonicalStreams() {
                    result.recordBind(true)
                }
                group.leave()
            }
            group.enter()
            queue.async {
                if case .success = value.takeInternalReceipt() {
                    result.recordExtraction(true)
                }
                group.leave()
            }
            XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
            let observed = result.snapshot()
            XCTAssertNotEqual(observed.bind, observed.extraction)
        }
    }

    func testCanariesAreAbsentFromStreamsErrorsAndExposedReflection() throws {
        let diagnostic = "H4D-RAW-DIAGNOSTIC-CANARY"
        let root = String(repeating: "d", count: 64)
        let input = source(
            epoch: otherEpoch,
            receiptRoot: root,
            rawDiagnostic: Data(diagnostic.utf8)
        )
        let bound = try dispatcher(source: input).bindCanonicalStreams().get()
        let canonical = bound.canonicalTest
        let rendered = [
            String(decoding: canonical.json, as: UTF8.self),
            String(decoding: canonical.cbor, as: UTF8.self),
            String(reflecting: bound),
            String(reflecting: H4D.Failure.projectionRejected),
        ].joined(separator: "\n")

        for forbidden in [diagnostic, root, otherEpoch, "envelopeIdentity", "sourceIdentity"] {
            XCTAssertFalse(rendered.contains(forbidden))
        }
        XCTAssertEqual(Mirror(reflecting: bound).children.count, 0)
        XCTAssertEqual(Mirror(reflecting: bound).displayStyle, .struct)
        XCTAssertEqual(H4D.schema,
                       "com.ergentics.provenance.hypervisor.h4.owner-bound-canonical.v1")
    }
}

import XCTest

/// Fabricated graph data only. No host/guest execution or object discovery.
final class CapabilityLuminosityTests: XCTestCase {
    private typealias L = CapabilityLuminosity

    private func object(_ id: UInt32, shared: Bool = false, persistent: Bool = false,
                        crossExecution: Bool = false) -> L.Object {
        L.Object(id: id, shared: shared, persistent: persistent, crossExecution: crossExecution)
    }

    private func snapshot(_ objects: [L.Object], _ edges: [L.Edge] = [], _ roots: [UInt32] = []) throws -> L.Snapshot {
        try XCTUnwrap(L.snapshot(objects: objects, edges: edges, roots: roots))
    }

    func testPrivateLocalReachabilityAdditionRemainsVisibleAtZeroExposurePriority() throws {
        let objects = [object(1), object(2)]
        let before = try snapshot(objects, [], [1])
        let after = try snapshot(objects, [.init(from: 1, to: 2)], [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.reachable.added, [2])
        XCTAssertEqual(delta.reachable.removed, [])
        XCTAssertEqual(delta.shared.added, [])
        XCTAssertEqual(delta.persistent.added, [])
        XCTAssertEqual(delta.crossExecution.added, [])
        XCTAssertEqual(delta.priorities.map(\.objectID), [2])
        XCTAssertTrue(delta.priorities[0].newlyReachable)
        XCTAssertEqual(delta.priorities[0].newExposureCategoryCount, 0)
    }

    func testOverlappingExposureCategoriesStaySeparateAndRankNonnegatively() throws {
        let objects = [object(1), object(2, shared: true), object(3, persistent: true, crossExecution: true),
                       object(4, shared: true, persistent: true, crossExecution: true), object(5)]
        let before = try snapshot(objects, [], [1])
        let after = try snapshot(objects, (UInt32(2)...5).map { .init(from: 1, to: $0) }, [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.reachable.added, [2, 3, 4, 5])
        XCTAssertEqual(delta.shared.added, [2, 4])
        XCTAssertEqual(delta.persistent.added, [3, 4])
        XCTAssertEqual(delta.crossExecution.added, [3, 4])
        XCTAssertEqual(delta.priorities.map(\.objectID), [4, 3, 2, 5])
        XCTAssertEqual(delta.priorities.map(\.newExposureCategoryCount), [3, 2, 1, 0])
        XCTAssertTrue(delta.priorities.allSatisfy { (0...3).contains($0.newExposureCategoryCount) })
    }

    func testClassificationPromotionAddsExposureWithoutNewReachability() throws {
        let before = try snapshot([object(1)], [], [1])
        let after = try snapshot([object(1, shared: true, persistent: true, crossExecution: true)], [], [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.reachable.added, [])
        XCTAssertEqual(delta.reachable.removed, [])
        XCTAssertEqual(delta.shared.added, [1])
        XCTAssertEqual(delta.persistent.added, [1])
        XCTAssertEqual(delta.crossExecution.added, [1])
        XCTAssertEqual(delta.priorities.map(\.objectID), [1])
        XCTAssertFalse(delta.priorities[0].newlyReachable)
        XCTAssertEqual(delta.priorities[0].newExposureCategoryCount, 3)
    }

    func testRemovedExposureNeverCancelsNewExposure() throws {
        let objects = [object(1), object(2, shared: true), object(3, shared: true)]
        let removed = L.Edge(from: 1, to: 2), added = L.Edge(from: 1, to: 3)
        let before = try snapshot(objects, [removed], [1])
        let after = try snapshot(objects, [added], [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.reachable.added, [3])
        XCTAssertEqual(delta.reachable.removed, [2])
        XCTAssertEqual(delta.shared.added, [3])
        XCTAssertEqual(delta.shared.removed, [2])
        XCTAssertEqual(delta.edges.added, [added])
        XCTAssertEqual(delta.edges.removed, [removed])
        XCTAssertEqual(delta.priorities.map(\.objectID), [3])
        XCTAssertEqual(delta.priorities[0].newExposureCategoryCount, 1)
    }

    func testCyclesSelfEdgesAndDisconnectedComponentsAreBounded() throws {
        let objects = (UInt32(1)...4).map { object($0, shared: true) }
        let edges: [L.Edge] = [.init(from: 1, to: 2), .init(from: 2, to: 1), .init(from: 2, to: 2),
                               .init(from: 3, to: 4), .init(from: 4, to: 3)]
        let before = try snapshot(objects, edges, [1])
        XCTAssertEqual(before.reachableIDs, [1, 2])
        let after = try snapshot(objects, edges, [1, 3])
        XCTAssertEqual(after.reachableIDs, [1, 2, 3, 4])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.roots.added, [3])
        XCTAssertEqual(delta.reachable.added, [3, 4])
        XCTAssertEqual(delta.edges.added, [])
        XCTAssertEqual(delta.priorities.map(\.objectID), [3, 4])
    }

    func testEdgeDirectionIsNotSilentlyTreatedAsUndirectedOrAsAGrant() throws {
        let objects = [object(1), object(2, shared: true)]
        let edge = L.Edge(from: 2, to: 1)
        let before = try snapshot(objects, [], [1])
        let after = try snapshot(objects, [edge], [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(after.reachableIDs, [1])
        XCTAssertEqual(delta.edges.added, [edge])
        XCTAssertEqual(delta.reachable.added, [])
        XCTAssertEqual(delta.shared.added, [])
        XCTAssertEqual(delta.priorities, [])
    }

    func testClassificationRemovalIsNotNegativeExposureOrErasureProof() throws {
        let before = try snapshot([object(1, shared: true, persistent: true, crossExecution: true)], [], [1])
        let after = try snapshot([object(1)], [], [1])
        let delta = L.compare(before: before, after: after)
        XCTAssertEqual(delta.reachable.added, [])
        XCTAssertEqual(delta.reachable.removed, [])
        XCTAssertEqual(delta.shared.removed, [1])
        XCTAssertEqual(delta.persistent.removed, [1])
        XCTAssertEqual(delta.crossExecution.removed, [1])
        XCTAssertEqual(delta.priorities, [])
    }

    func testInputOrderDoesNotChangeCanonicalSnapshotOrDelta() throws {
        let objects = [object(1), object(2, shared: true), object(3, shared: true)]
        let edges: [L.Edge] = [.init(from: 1, to: 3), .init(from: 1, to: 2), .init(from: 3, to: 2)]
        let first = try snapshot(objects, edges, [3, 1])
        let second = try snapshot(Array(objects.reversed()), Array(edges.reversed()), [1, 3])
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.edges, [.init(from: 1, to: 2), .init(from: 1, to: 3), .init(from: 3, to: 2)])
        let empty = try snapshot([])
        XCTAssertEqual(L.compare(before: empty, after: first), L.compare(before: empty, after: second))
        let unchanged = L.compare(before: first, after: second)
        XCTAssertEqual(unchanged.roots.added, [])
        XCTAssertEqual(unchanged.roots.removed, [])
        XCTAssertEqual(unchanged.reachable.added, [])
        XCTAssertEqual(unchanged.reachable.removed, [])
        XCTAssertEqual(unchanged.edges.added, [])
        XCTAssertEqual(unchanged.edges.removed, [])
        XCTAssertEqual(unchanged.priorities, [])
    }

    func testRejectsZeroOrDuplicateObjectsAndUnknownOrDuplicateRoots() {
        XCTAssertNil(L.snapshot(objects: [object(0)], edges: [], roots: []))
        XCTAssertNil(L.snapshot(objects: [object(1), object(1, shared: true)], edges: [], roots: []))
        let invalidRoots: [[UInt32]] = [[0], [2], [1, 1]]
        for roots in invalidRoots {
            XCTAssertNil(L.snapshot(objects: [object(1)], edges: [], roots: roots))
        }
    }

    func testRejectsDanglingAndDuplicateEdges() {
        let objects = [object(1), object(2)]
        for edge in [L.Edge(from: 0, to: 1), .init(from: 1, to: 0),
                     .init(from: 3, to: 1), .init(from: 1, to: 3)] {
            XCTAssertNil(L.snapshot(objects: objects, edges: [edge], roots: [1]))
        }
        let edge = L.Edge(from: 1, to: 2)
        XCTAssertNil(L.snapshot(objects: objects, edges: [edge, edge], roots: [1]))
    }

    func testExactBoundsAcceptedAndEachOversizedInputRejected() throws {
        XCTAssertEqual(L.maximumObjects, 128)
        XCTAssertEqual(L.maximumEdges, 512)
        let ids = Array(UInt32(1)...128)
        let objects = ids.map { object($0) }
        let edges: [L.Edge] = (UInt32(1)...4).flatMap { from in ids.map { .init(from: from, to: $0) } }
        let full = try snapshot(objects, edges, ids)
        XCTAssertEqual(full.reachableIDs, ids)
        XCTAssertEqual(full.edges.count, 512)
        XCTAssertNil(L.snapshot(objects: objects + [object(129)], edges: edges, roots: ids))
        XCTAssertNil(L.snapshot(objects: objects, edges: edges + [.init(from: 5, to: 1)], roots: ids))
        XCTAssertNil(L.snapshot(objects: objects, edges: edges, roots: ids + [129]))
    }

    func testEmptyRootsExposeNothingAndLargeOpaqueIDsDoNotBecomeAddresses() throws {
        let empty = try snapshot([])
        XCTAssertEqual(empty.reachableIDs, [])
        let hidden = try snapshot([object(.max, shared: true, persistent: true, crossExecution: true)])
        XCTAssertEqual(hidden.reachableIDs, [])
        XCTAssertEqual(hidden.sharedIDs, [])
        XCTAssertEqual(hidden.persistentIDs, [])
        XCTAssertEqual(hidden.crossExecutionIDs, [])
        let rooted = try snapshot(hidden.objects, [], [.max])
        XCTAssertEqual(rooted.reachableIDs, [.max])
        XCTAssertEqual(L.compare(before: hidden, after: rooted).reachable.added, [.max])
    }
}

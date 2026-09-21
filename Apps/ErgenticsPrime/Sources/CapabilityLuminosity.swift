/// A structural-exposure diagnostic over an explicitly supplied object graph.
/// "Luminosity" has no physical units here: it is not light, energy, leakage
/// bits, noninterference, a capability grant, or an access-authorization score.
/// No objects, relationships, classifications, or roots are discovered here.
enum CapabilityLuminosity {
    typealias ObjectID = UInt32
    static let maximumObjects = 128
    static let maximumEdges = 512

    /// IDs must denote the same objects across compared snapshots. Their
    /// identity and these classifications are caller-supplied, not attested.
    struct Object: Equatable, Sendable {
        let id: ObjectID
        let shared: Bool
        let persistent: Bool
        let crossExecution: Bool
    }

    /// A directed, declared reachability relationship. Spatial locality means
    /// graph adjacency, not physical distance or an observed communication.
    /// Membership in this model does not install or grant a capability.
    struct Edge: Hashable, Sendable {
        let from: ObjectID
        let to: ObjectID
    }

    struct Snapshot: Equatable, Sendable {
        let objects: [Object]
        let edges: [Edge]
        let roots: [ObjectID]
        let reachableIDs: [ObjectID]
        let sharedIDs: [ObjectID]
        let persistentIDs: [ObjectID]
        let crossExecutionIDs: [ObjectID]

        fileprivate init(objects: [Object], edges: [Edge], roots: [ObjectID],
                         reachableIDs: [ObjectID], sharedIDs: [ObjectID],
                         persistentIDs: [ObjectID], crossExecutionIDs: [ObjectID]) {
            self.objects = objects
            self.edges = edges
            self.roots = roots
            self.reachableIDs = reachableIDs
            self.sharedIDs = sharedIDs
            self.persistentIDs = persistentIDs
            self.crossExecutionIDs = crossExecutionIDs
        }
    }

    struct IDDelta: Equatable, Sendable {
        let added: [ObjectID]
        let removed: [ObjectID]
    }

    struct EdgeDelta: Equatable, Sendable {
        let added: [Edge]
        let removed: [Edge]
    }

    struct Priority: Equatable, Sendable {
        let objectID: ObjectID
        let newlyReachable: Bool
        let newlyShared: Bool
        let newlyPersistent: Bool
        let newlyCrossExecution: Bool

        /// Unweighted category count, always 0...3, used only to order review.
        /// Categories overlap; this is neither an object count nor leaked data.
        var newExposureCategoryCount: Int {
            (newlyShared ? 1 : 0) + (newlyPersistent ? 1 : 0) + (newlyCrossExecution ? 1 : 0)
        }
    }

    struct Delta: Equatable, Sendable {
        let roots: IDDelta
        let reachable: IDDelta
        let shared: IDDelta
        let persistent: IDDelta
        let crossExecution: IDDelta
        let edges: EdgeDelta
        let priorities: [Priority]
    }

    /// Builds the complete bounded model before reachability calculation.
    /// Duplicate/dangling input is rejected, not silently deduplicated.
    /// Cycles and self-edges are allowed; each object enters the worklist once.
    static func snapshot(objects: [Object], edges: [Edge], roots: [ObjectID]) -> Snapshot? {
        guard objects.count <= maximumObjects, edges.count <= maximumEdges,
              roots.count <= maximumObjects else { return nil }
        var ids: Set<ObjectID> = []
        for object in objects {
            guard object.id != 0, ids.insert(object.id).inserted else { return nil }
        }
        var rootIDs: Set<ObjectID> = []
        for id in roots {
            guard ids.contains(id), rootIDs.insert(id).inserted else { return nil }
        }
        var edgeSet: Set<Edge> = []
        for edge in edges {
            guard ids.contains(edge.from), ids.contains(edge.to),
                  edgeSet.insert(edge).inserted else { return nil }
        }
        let orderedObjects = objects.sorted { $0.id < $1.id }
        let orderedEdges = edges.sorted(by: edgeOrder)
        let orderedRoots = roots.sorted()
        var adjacency: [ObjectID: [ObjectID]] = [:]
        for edge in orderedEdges { adjacency[edge.from, default: []].append(edge.to) }
        var reachable = rootIDs
        var pending = orderedRoots
        var next = 0
        while next < pending.count {
            let id = pending[next]
            next += 1
            for target in adjacency[id] ?? [] {
                if reachable.insert(target).inserted { pending.append(target) }
            }
        }
        let reachableObjects = orderedObjects.filter { reachable.contains($0.id) }
        return Snapshot(objects: orderedObjects, edges: orderedEdges, roots: orderedRoots,
                        reachableIDs: reachable.sorted(),
                        sharedIDs: reachableObjects.filter(\.shared).map(\.id),
                        persistentIDs: reachableObjects.filter(\.persistent).map(\.id),
                        crossExecutionIDs: reachableObjects.filter(\.crossExecution).map(\.id))
    }

    /// Exact, separate set differences: removals never cancel newly exposed
    /// objects. "Removed" means absent from the later model, not data erasure,
    /// successful revocation, or that a former observer forgot information.
    /// An already-reachable object's classification change can add exposure
    /// without adding reachability. Private/local additions remain visible.
    static func compare(before: Snapshot, after: Snapshot) -> Delta {
        let roots = difference(before.roots, after.roots)
        let reachable = difference(before.reachableIDs, after.reachableIDs)
        let shared = difference(before.sharedIDs, after.sharedIDs)
        let persistent = difference(before.persistentIDs, after.persistentIDs)
        let crossExecution = difference(before.crossExecutionIDs, after.crossExecutionIDs)
        let oldEdges = Set(before.edges), newEdges = Set(after.edges)
        let edges = EdgeDelta(added: newEdges.subtracting(oldEdges).sorted(by: edgeOrder),
                              removed: oldEdges.subtracting(newEdges).sorted(by: edgeOrder))
        let newReachable = Set(reachable.added), newShared = Set(shared.added)
        let newPersistent = Set(persistent.added), newCrossExecution = Set(crossExecution.added)
        let candidates = newReachable.union(newShared).union(newPersistent).union(newCrossExecution)
        let priorities = candidates.map { id in
            Priority(objectID: id, newlyReachable: newReachable.contains(id),
                     newlyShared: newShared.contains(id), newlyPersistent: newPersistent.contains(id),
                     newlyCrossExecution: newCrossExecution.contains(id))
        }.sorted {
            if $0.newExposureCategoryCount != $1.newExposureCategoryCount {
                return $0.newExposureCategoryCount > $1.newExposureCategoryCount
            }
            return $0.objectID < $1.objectID
        }
        return Delta(roots: roots, reachable: reachable, shared: shared, persistent: persistent,
                     crossExecution: crossExecution, edges: edges, priorities: priorities)
    }

    private static func difference(_ before: [ObjectID], _ after: [ObjectID]) -> IDDelta {
        let old = Set(before), new = Set(after)
        return IDDelta(added: new.subtracting(old).sorted(), removed: old.subtracting(new).sorted())
    }

    private static func edgeOrder(_ left: Edge, _ right: Edge) -> Bool {
        left.from == right.from ? left.to < right.to : left.from < right.from
    }
}

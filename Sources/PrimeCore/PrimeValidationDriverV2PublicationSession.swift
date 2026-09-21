// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PublicationNamespaceEntry: Codable, Equatable, Sendable {
    public let relativePath: String
    public let kind: String
    public let mode: UInt16
    public let byteCount: UInt64?
    public let sha256: String?
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PublicationPreparationObservation: Codable, Equatable, Sendable {
    public let liveAdmissionIdentitySHA256: String
    public let phaseHistoryBinding: PrimeArtifactBinding
    public let entriesBeforeManifest: [PrimeValidationDriverV2PublicationNamespaceEntry]
    public let plannedInnerFinalReceiptBinding: PrimeArtifactBinding
    public let publicationStartedAtUptimeNanoseconds: UInt64
    public let publicationExpiresAtUptimeNanoseconds: UInt64
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PublicationReadbackObservation: Codable, Equatable, Sendable {
    public let manifestBinding: PrimeArtifactBinding
    public let innerFinalReceiptBinding: PrimeArtifactBinding
    public let outerEnvelopeBinding: PrimeArtifactBinding
    public let exactFinalNamespacePaths: [String]
    public let completedAtUptimeNanoseconds: UInt64
}

/// Shared canonical projection for independent outer readback. This Codable
/// value is not the non-Codable live owner that emits its admission identity.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PublicationAdmissionIdentityV1: Codable, Equatable, Sendable {
    public let schema: String
    public let intentSHA256: String
    public let sourceSnapshotSHA256: String
    public let declaredExecutionGoScopeSHA256: String
    public let packageResolvedBinding: PrimeArtifactBinding
    public let inventoryBinding: PrimeArtifactBinding
    public let planBinding: PrimeArtifactBinding
    public let goBinding: PrimeArtifactBinding
    public let shardIdentifiers: [String]
    public let terminalBindings: [PrimeArtifactBinding]
    public let acceptanceBindings: [PrimeArtifactBinding]
    public let artifactBindings: [PrimeArtifactBinding]
    public let phaseHistorySHA256: String
    public let phasePrefixBindings: [PrimeArtifactBinding]
    public let publicationStartedAt: UInt64

    public init(intentSHA256: String, sourceSnapshotSHA256: String, declaredExecutionGoScopeSHA256: String,
        packageResolvedBinding: PrimeArtifactBinding, inventoryBinding: PrimeArtifactBinding,
        planBinding: PrimeArtifactBinding, goBinding: PrimeArtifactBinding, shardIdentifiers: [String],
        terminalBindings: [PrimeArtifactBinding], acceptanceBindings: [PrimeArtifactBinding],
        artifactBindings: [PrimeArtifactBinding], phaseHistorySHA256: String,
        phasePrefixBindings: [PrimeArtifactBinding], publicationStartedAt: UInt64) {
        schema = "prime_driver_v2_gate_h_live_publication_admission_v1"
        self.intentSHA256 = intentSHA256; self.sourceSnapshotSHA256 = sourceSnapshotSHA256
        self.declaredExecutionGoScopeSHA256 = declaredExecutionGoScopeSHA256
        self.packageResolvedBinding = packageResolvedBinding; self.inventoryBinding = inventoryBinding
        self.planBinding = planBinding; self.goBinding = goBinding; self.shardIdentifiers = shardIdentifiers
        self.terminalBindings = terminalBindings; self.acceptanceBindings = acceptanceBindings
        self.artifactBindings = artifactBindings; self.phaseHistorySHA256 = phaseHistorySHA256
        self.phasePrefixBindings = phasePrefixBindings; self.publicationStartedAt = publicationStartedAt
    }
}

extension PrimeValidationDriverV2ExecutionPublicationPermit {
    /// The existing one-shot permit is the sole constructor. Decoding any
    /// observation or envelope cannot call this path without that live owner.
    @_spi(PrimeValidationDriverV2RoleFacade)
    public func consumeBoundPublicationSession() throws -> PrimeValidationDriverV2PublicationSession {
        try .init(lifetime: consumePublicationLifetime())
    }
}

/// A terminal-only owner. Its four fixed files are the final writes in this
/// evidence namespace. Each failure consumes the operation permanently.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2PublicationSession {
    private static let historyLeaf = "phase-history.json"
    private static let manifestLeaf = "evidence-manifest.json"
    private static let innerLeaf = "final-receipt.json"
    private static let outerLeaf = "publication-envelope.json"
    private static let finalLeaves = [manifestLeaf, innerLeaf, outerLeaf]
    public let completedExecution: PrimeValidationDriverV2ExecutionCompletedObservation
    private let lifetime: PrimeValidationDriverV2ExecutionPublicationLifetime
    private let lock = NSLock()
    private var addedBindings: [PrimeArtifactBinding] = []
    private var prepared = false
    private var publicationAttempted = false
    private var publicationCompleted = false
    private var poisoned = false
    private var namespace: Namespace?
    private var plannedInnerData: Data?
    private var preparation: PrimeValidationDriverV2PublicationPreparationObservation?

    fileprivate init(lifetime: PrimeValidationDriverV2ExecutionPublicationLifetime) throws {
        self.lifetime = lifetime; completedExecution = lifetime.observation
        try lifetime.revalidateContinuity()
    }

    public func prepare(phaseHistoryData: Data, innerFinalReceiptData: Data) throws
        -> PrimeValidationDriverV2PublicationPreparationObservation {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, !prepared, !publicationAttempted else { throw rejected("prepare_consumed") }
        prepared = true
        do {
            try canonicalObject(phaseHistoryData); try canonicalObject(innerFinalReceiptData)
            guard phaseHistoryData == completedExecution.phaseHistoryData,
                  completedExecution.orderedPhasePrefixBindings.count == 8 else {
                throw rejected("native_phase_history")
            }
            try revalidateOwner()
            let history = try lifetime.staging.publishData(phaseHistoryData, path: Self.historyLeaf)
            addedBindings.append(history)
            try revalidateOwner()
            let admission = lifetime.state.retainedState.admission
            let evidenceFD = try admission.evidenceRoot.root.duplicateTrustedRootDescriptorForInventory()
            defer { close(evidenceFD) }
            let runID = lifetime.state.context.evidenceRunID
            let tree = try Namespace(parent: evidenceFD, leaf: runID,
                deadline: lifetime.deadline.expiresAtUptimeNanoseconds, allowsPublicationWrites: true)
            let absent = Self.finalLeaves.map { "execution/" + $0 }
            guard Set(tree.entries.map(\.relativePath)).isDisjoint(with: absent) else {
                throw rejected("final_leaf_exists")
            }
            let scopedHistory = scoped(history)
            guard tree.entries.contains(where: {
                $0.relativePath == scopedHistory.relativePath && $0.byteCount == scopedHistory.byteCount
                    && $0.sha256 == scopedHistory.sha256 && $0.mode == 0o444
            }) else { throw rejected("history_native_join") }
            let inner = PrimeArtifactBinding(relativePath: "execution/" + Self.innerLeaf,
                sha256: PrimeSHA256.hexDigest(of: innerFinalReceiptData),
                byteCount: UInt64(innerFinalReceiptData.count), purpose: .immutableData)
            let identity = PrimeValidationDriverV2PublicationAdmissionIdentityV1(
                intentSHA256: PrimeSHA256.hexDigest(of: completedExecution.canonicalIntentData),
                sourceSnapshotSHA256: PrimeSHA256.hexDigest(of: completedExecution.sourceSnapshotData),
                declaredExecutionGoScopeSHA256: PrimeSHA256.hexDigest(of: completedExecution.declaredExecutionGoScopeData),
                packageResolvedBinding: completedExecution.packageResolvedBinding,
                inventoryBinding: completedExecution.predecessorInventoryBinding,
                planBinding: completedExecution.planBinding, goBinding: completedExecution.goBinding,
                shardIdentifiers: completedExecution.orderedShardIdentifiers,
                terminalBindings: completedExecution.orderedTerminalBindings,
                acceptanceBindings: completedExecution.orderedAcceptanceBindings,
                artifactBindings: completedExecution.immutableArtifactBindings,
                phaseHistorySHA256: PrimeSHA256.hexDigest(of: completedExecution.phaseHistoryData),
                phasePrefixBindings: completedExecution.orderedPhasePrefixBindings,
                publicationStartedAt: completedExecution.publicationStartedAtUptimeNanoseconds)
            let observed = PrimeValidationDriverV2PublicationPreparationObservation(
                liveAdmissionIdentitySHA256: PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(identity)),
                phaseHistoryBinding: scopedHistory, entriesBeforeManifest: tree.entries,
                plannedInnerFinalReceiptBinding: inner,
                publicationStartedAtUptimeNanoseconds: completedExecution.publicationStartedAtUptimeNanoseconds,
                publicationExpiresAtUptimeNanoseconds: completedExecution.publicationExpiresAtUptimeNanoseconds)
            namespace = tree; plannedInnerData = innerFinalReceiptData; preparation = observed
            try revalidateOwner(); try tree.revalidate(added: [:])
            return observed
        } catch { poisoned = true; throw error }
    }

    public func publish(manifestData: Data, innerFinalReceiptData: Data, outerEnvelopeData: Data) throws
        -> PrimeValidationDriverV2PublicationReadbackObservation {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, prepared, !publicationAttempted, let namespace, let preparation,
              plannedInnerData == innerFinalReceiptData else { throw rejected("publication_consumed") }
        publicationAttempted = true
        do {
            try canonicalObject(manifestData); try canonicalObject(outerEnvelopeData)
            try validateFinalFrameJoins(manifestData: manifestData, innerData: innerFinalReceiptData,
                                       outerData: outerEnvelopeData, preparation: preparation)
            try revalidateOwner(); try namespace.revalidate(added: [:])
            var published = [String: PrimeArtifactBinding]()
            for (leaf, data) in [(Self.manifestLeaf, manifestData), (Self.innerLeaf, innerFinalReceiptData),
                                 (Self.outerLeaf, outerEnvelopeData)] {
                try revalidateOwner(); try namespace.revalidate(added: published)
                var created: Descriptor?
                let binding = try lifetime.staging.publishData(data, path: leaf, observingCreatedDescriptor: { fd in
                    let duplicate = fcntl(fd, F_DUPFD_CLOEXEC, 3)
                    guard duplicate >= 3 else { throw self.rejected("created_descriptor") }
                    created = Descriptor(duplicate)
                })
                addedBindings.append(binding); published["execution/" + leaf] = scoped(binding)
                guard let created else { throw rejected("created_descriptor_missing") }
                try namespace.retainPublished(created: created, binding: scoped(binding))
                try revalidateOwner(); try namespace.revalidate(added: published)
            }
            // All code after the outer write is read-only. A failure here is a
            // rejected publication, never permission to write a replacement.
            let paths = (namespace.entries.map(\.relativePath) + Array(published.keys)).sorted()
            let completed = DispatchTime.now().uptimeNanoseconds
            try time()
            publicationCompleted = true
            return .init(manifestBinding: published["execution/" + Self.manifestLeaf]!,
                innerFinalReceiptBinding: published["execution/" + Self.innerLeaf]!,
                outerEnvelopeBinding: published["execution/" + Self.outerLeaf]!,
                exactFinalNamespacePaths: paths, completedAtUptimeNanoseconds: completed)
        } catch { poisoned = true; throw error }
    }

    public func revalidate() throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, publicationCompleted, let namespace else { throw rejected("not_published") }
        do {
            let final = addedBindings.filter { Self.finalLeaves.contains($0.relativePath) }.map(scoped)
            guard final.count == 3 else { throw rejected("final_binding_count") }
            try revalidateOwner()
            try namespace.revalidate(added: Dictionary(uniqueKeysWithValues: final.map { ($0.relativePath, $0) }))
            try revalidateOwner()
        } catch { poisoned = true; throw error }
    }

    private func validateFinalFrameJoins(manifestData: Data, innerData: Data, outerData: Data,
        preparation: PrimeValidationDriverV2PublicationPreparationObservation) throws {
        let manifest = try HJSON.object(manifestData), outer = try HJSON.object(outerData)
        guard outer["artifactKind"] as? String == "prime_driver_v2_outer_publication_envelope_v1",
              outer["liveAdmissionIdentitySHA256"] as? String == preparation.liveAdmissionIdentitySHA256,
              outer["preEnvelopeManifestSHA256"] as? String == PrimeSHA256.hexDigest(of: manifestData),
              outer["innerFinalReceiptSHA256"] as? String == PrimeSHA256.hexDigest(of: innerData),
              outer["finalPhaseLedgerSHA256"] as? String == preparation.phaseHistoryBinding.sha256,
              manifest["phaseHistorySHA256"] as? String == preparation.phaseHistoryBinding.sha256,
              let entries = manifest["entries"] as? [[String: Any]] else { throw rejected("final_frame_joins") }
        var expected = preparation.entriesBeforeManifest.map { native -> [String: Any] in
            var value: [String: Any] = ["relativePath": native.relativePath, "kind": native.kind, "mode": native.mode]
            if let count = native.byteCount, let hash = native.sha256 { value["content"] = ["byteCount": count, "sha256": hash] }
            return value
        }
        expected.append(["relativePath": preparation.plannedInnerFinalReceiptBinding.relativePath,
            "kind": "immutable_file", "mode": UInt16(0o444), "content": [
                "byteCount": preparation.plannedInnerFinalReceiptBinding.byteCount,
                "sha256": preparation.plannedInnerFinalReceiptBinding.sha256]])
        expected.sort { ($0["relativePath"] as! String) < ($1["relativePath"] as! String) }
        guard try HJSON.encode(entries) == HJSON.encode(expected) else { throw rejected("manifest_exact_native_inventory") }
    }

    private func scoped(_ binding: PrimeArtifactBinding) -> PrimeArtifactBinding {
        .init(relativePath: "execution/" + binding.relativePath, sha256: binding.sha256,
              byteCount: binding.byteCount, purpose: binding.purpose)
    }
    private func canonicalObject(_ data: Data) throws {
        guard !data.isEmpty, data.count <= 16 * 1024 * 1024,
              try HJSON.encode(HJSON.object(data)) == data else { throw rejected("canonical_frame") }
    }
    private func time() throws {
        guard try lifetime.deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) else {
            throw rejected("deadline")
        }
    }
    private func revalidateOwner() throws {
        try time()
        try PrimeValidationDriverV2ExecutionPlanRawCapability.checkpoint(
            lifetime.state, inventory: lifetime.inventory, deadline: lifetime.deadline)
        try lifetime.phaseWriter.revalidate()
        let expected = (completedExecution.immutableArtifactBindings + addedBindings).sorted { $0.relativePath < $1.relativePath }
        guard try lifetime.staging.completedBindings() == expected else { throw rejected("changed_execution_prefix") }
        try time()
    }
    private func rejected(_ value: String) -> Error { hRejected("publication_" + value) }

    fileprivate final class Descriptor {
        let value: Int32
        init(_ value: Int32) { self.value = value }
        deinit { close(value) }
    }
    fileprivate final class Namespace {
        private final class Node {
            let descriptor: Descriptor
            let parent: Int32
            let leaf: String
            let path: String
            let original: stat
            let directory: Bool
            let binding: PrimeArtifactBinding?
            let allowsPublicationWrites: Bool
            init(parent: Int32, leaf: String, path: String, deadline: UInt64, created: Descriptor? = nil,
                 allowsPublicationWrites: Bool = false) throws {
                let opened = created?.value ?? openat(parent, leaf, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
                guard opened >= 3 else { if opened >= 0 { close(opened) }; throw hRejected("publication_node_open") }
                descriptor = created ?? .init(opened); self.parent = parent; self.leaf = leaf; self.path = path
                self.allowsPublicationWrites = allowsPublicationWrites
                var value = stat()
                guard fstat(opened, &value) == 0 else { throw hRejected("publication_node_stat") }
                original = value; directory = value.st_mode & S_IFMT == S_IFDIR
                guard value.st_uid == geteuid(), value.st_flags == 0 else { throw hRejected("publication_node_owner") }
                if directory {
                    guard value.st_mode & 0o7777 == 0o700 else { throw hRejected("publication_directory_mode") }
                    try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(opened, path: path)
                    binding = nil
                } else {
                    guard value.st_mode & S_IFMT == S_IFREG, value.st_nlink == 1,
                          [mode_t(0o444), mode_t(0o555)].contains(value.st_mode & 0o7777),
                          value.st_size >= 0, value.st_size <= 512 * 1024 * 1024 else { throw hRejected("publication_file_mode") }
                    try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(opened, path: path)
                    let data = try Self.read(opened, count: Int(value.st_size), deadline: deadline)
                    binding = .init(relativePath: path, sha256: PrimeSHA256.hexDigest(of: data), byteCount: UInt64(data.count),
                        purpose: value.st_mode & 0o111 == 0 ? .immutableData : .executable)
                }
                try revalidate(deadline: deadline)
            }
            func revalidate(deadline: UInt64) throws {
                guard DispatchTime.now().uptimeNanoseconds < deadline else { throw hRejected("publication_namespace_deadline") }
                var held = stat(), named = stat()
                guard fstat(descriptor.value, &held) == 0, fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                      held.st_dev == original.st_dev, held.st_ino == original.st_ino,
                      held.st_mode == original.st_mode, held.st_uid == original.st_uid, held.st_gid == original.st_gid,
                      held.st_flags == original.st_flags,
                      PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, named) else {
                    throw hRejected("publication_namespace_rejoin")
                }
                // The retained ExecutionStaging owner independently freezes
                // this one parent after each of our four fixed publications.
                if path != "execution" || !allowsPublicationWrites {
                    guard PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, original) else {
                        throw hRejected("publication_namespace_metadata")
                    }
                }
                if let binding {
                    let data = try Self.read(descriptor.value, count: Int(binding.byteCount), deadline: deadline)
                    guard PrimeSHA256.hexDigest(of: data) == binding.sha256 else { throw hRejected("publication_namespace_content") }
                }
                if directory {
                    try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(descriptor.value, path: path)
                } else {
                    try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(descriptor.value, path: path)
                }
                var finalHeld = stat(), finalNamed = stat()
                guard fstat(descriptor.value, &finalHeld) == 0,
                      fstatat(parent, leaf, &finalNamed, AT_SYMLINK_NOFOLLOW) == 0,
                      PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(finalHeld, held),
                      PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(finalHeld, finalNamed),
                      DispatchTime.now().uptimeNanoseconds < deadline else {
                    throw hRejected("publication_namespace_final_rejoin")
                }
            }
            static func read(_ fd: Int32, count: Int, deadline: UInt64) throws -> Data {
                var result = Data(count: count)
                try result.withUnsafeMutableBytes { buffer in
                    var offset = 0
                    while offset < count {
                        guard DispatchTime.now().uptimeNanoseconds < deadline else { throw hRejected("publication_read_deadline") }
                        let n = pread(fd, buffer.baseAddress!.advanced(by: offset), min(64 * 1024, count - offset), off_t(offset))
                        if n < 0 && errno == EINTR { continue }
                        guard n > 0 else { throw hRejected("publication_read") }; offset += n
                    }
                }
                return result
            }
        }
        let entries: [PrimeValidationDriverV2PublicationNamespaceEntry]
        private let rootParent: Descriptor
        private let root: Node
        private let nodes: [Node]
        private let directories: [String: Set<String>]
        private let deadline: UInt64
        private var publishedNodes: [String: Node] = [:]
        init(parent: Int32, leaf: String, deadline: UInt64, allowsPublicationWrites: Bool = false) throws {
            guard !leaf.isEmpty, leaf != ".", leaf != "..", !leaf.contains("/"),
                  leaf.utf8.allSatisfy({ (33...126).contains($0) && $0 != 92 }) else { throw hRejected("publication_run_leaf") }
            let duplicate = fcntl(parent, F_DUPFD_CLOEXEC, 3)
            guard duplicate >= 3 else { throw hRejected("publication_root_duplicate") }
            rootParent = .init(duplicate)
            let capturedRoot = try Node(parent: duplicate, leaf: leaf, path: "", deadline: deadline)
            root = capturedRoot
            var captured = [Node](), directories = [String: Set<String>]()
            func scan(_ parent: Node, depth: Int) throws {
                guard depth <= 32, captured.count < 100_000 else { throw hRejected("publication_namespace_cap") }
                let names = try PrimeValidationDriverV2ExecutionStaging.entries(parent.descriptor.value)
                directories[parent.path] = names
                for leaf in names.sorted() {
                    guard captured.count < 100_000 else { throw hRejected("publication_namespace_cap") }
                    let path = parent.path.isEmpty ? leaf : parent.path + "/" + leaf
                    let node = try Node(parent: parent.descriptor.value, leaf: leaf, path: path, deadline: deadline,
                        allowsPublicationWrites: allowsPublicationWrites)
                    guard node.original.st_dev == capturedRoot.original.st_dev else { throw hRejected("publication_namespace_device") }
                    captured.append(node)
                    if node.directory { try scan(node, depth: depth + 1) }
                }
            }
            try scan(capturedRoot, depth: 0)
            nodes = captured; self.directories = directories; self.deadline = deadline
            entries = captured.map { node in .init(relativePath: node.path,
                kind: node.directory ? "directory" : node.binding!.purpose == .executable ? "executable" : "immutable_file",
                mode: UInt16(node.original.st_mode & 0o7777), byteCount: node.binding?.byteCount, sha256: node.binding?.sha256)
            }.sorted { $0.relativePath < $1.relativePath }
            try revalidate(added: [:])
        }
        func retainPublished(created: Descriptor, binding: PrimeArtifactBinding) throws {
            guard publishedNodes[binding.relativePath] == nil,
                  let execution = nodes.first(where: { $0.path == "execution" }),
                  binding.relativePath.hasPrefix("execution/"),
                  !binding.relativePath.dropFirst("execution/".count).contains("/") else {
                throw hRejected("publication_retained_leaf")
            }
            let leaf = String(binding.relativePath.dropFirst("execution/".count))
            let node = try Node(parent: execution.descriptor.value, leaf: leaf, path: binding.relativePath,
                deadline: deadline, created: created)
            guard node.binding == binding else { throw hRejected("publication_created_binding") }
            publishedNodes[binding.relativePath] = node
        }
        func revalidate(added: [String: PrimeArtifactBinding]) throws {
            try root.revalidate(deadline: deadline)
            for node in nodes { try node.revalidate(deadline: deadline) }
            for (path, names) in directories {
                let parent = path.isEmpty ? root : nodes.first(where: { $0.path == path })!
                let expected = path == "execution" ? names.union(added.keys.map { String($0.dropFirst("execution/".count)) }) : names
                guard try PrimeValidationDriverV2ExecutionStaging.entries(parent.descriptor.value) == expected else {
                    throw hRejected("publication_namespace_exact_set")
                }
            }
            guard Set(publishedNodes.keys) == Set(added.keys) else { throw hRejected("publication_created_set") }
            for (path, binding) in added {
                let node = publishedNodes[path]!
                guard node.binding == binding else { throw hRejected("publication_added_binding") }
                try node.revalidate(deadline: deadline)
            }
        }
    }
}

/// Read-only outer observation. The caller supplies already-held evidence root
/// authority; decoding its returned values cannot construct an execution owner.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2PublicationNamespaceReadback {
    public let entries: [PrimeValidationDriverV2PublicationNamespaceEntry]
    private let namespace: PrimeValidationDriverV2PublicationSession.Namespace

    private init(namespace: PrimeValidationDriverV2PublicationSession.Namespace) {
        self.namespace = namespace; entries = namespace.entries
    }

    public static func capture(evidenceRootDescriptor: Int32, runID: String, manifestData: Data,
        outerEnvelopeData: Data, deadlineNanoseconds: UInt64) throws -> PrimeValidationDriverV2PublicationNamespaceReadback {
        let manifest = try HJSON.object(manifestData), outer = try HJSON.object(outerEnvelopeData)
        guard manifest["runID"] as? String == runID, outer["runID"] as? String == runID,
              outer["artifactKind"] as? String == "prime_driver_v2_outer_publication_envelope_v1",
              outer["preEnvelopeManifestSHA256"] as? String == PrimeSHA256.hexDigest(of: manifestData),
              let manifestEntries = manifest["entries"] as? [[String: Any]] else { throw hRejected("publication_outer_frame") }
        let namespace = try PrimeValidationDriverV2PublicationSession.Namespace(parent: evidenceRootDescriptor,
            leaf: runID, deadline: deadlineNanoseconds)
        var expected = try manifestEntries.map { value -> PrimeValidationDriverV2PublicationNamespaceEntry in
            let keys = Set(value.keys)
            guard keys == ["relativePath", "kind", "mode"] || keys == ["relativePath", "kind", "mode", "content"],
                  let path = value["relativePath"] as? String, let kind = value["kind"] as? String,
                  let mode = value["mode"] as? NSNumber, mode.uint64Value <= UInt16.max,
                  try HJSON.encode([mode]) == HJSON.encode([mode.uint64Value]) else { throw hRejected("publication_outer_entry") }
            let content = value["content"] as? [String: Any]
            if let content {
                guard Set(content.keys) == ["byteCount", "sha256"], let count = content["byteCount"] as? NSNumber,
                      try HJSON.encode([count]) == HJSON.encode([count.uint64Value]),
                      let hash = content["sha256"] as? String else { throw hRejected("publication_outer_content") }
                return .init(relativePath: path, kind: kind, mode: UInt16(mode.uint64Value), byteCount: count.uint64Value, sha256: hash)
            }
            guard value["content"] == nil else { throw hRejected("publication_outer_null_content") }
            return .init(relativePath: path, kind: kind, mode: UInt16(mode.uint64Value), byteCount: nil, sha256: nil)
        }
        for (path, data) in [("execution/evidence-manifest.json", manifestData), ("execution/publication-envelope.json", outerEnvelopeData)] {
            guard !expected.contains(where: { $0.relativePath == path }) else { throw hRejected("publication_outer_self_reference") }
            expected.append(.init(relativePath: path, kind: "immutable_file", mode: 0o444,
                byteCount: UInt64(data.count), sha256: PrimeSHA256.hexDigest(of: data)))
        }
        guard namespace.entries == expected.sorted(by: { $0.relativePath < $1.relativePath }),
              let inner = namespace.entries.first(where: { $0.relativePath == "execution/final-receipt.json" }),
              inner.kind == "immutable_file", let innerHash = inner.sha256,
              let expectedInnerHash = outer["innerFinalReceiptSHA256"] as? String, innerHash == expectedInnerHash,
              let history = namespace.entries.first(where: { $0.relativePath == "execution/phase-history.json" }),
              history.kind == "immutable_file", let historyHash = history.sha256,
              let expectedHistoryHash = outer["finalPhaseLedgerSHA256"] as? String, historyHash == expectedHistoryHash else {
            throw hRejected("publication_outer_namespace")
        }
        try namespace.revalidate(added: [:]); return .init(namespace: namespace)
    }

    public func revalidate() throws { try namespace.revalidate(added: [:]) }
}

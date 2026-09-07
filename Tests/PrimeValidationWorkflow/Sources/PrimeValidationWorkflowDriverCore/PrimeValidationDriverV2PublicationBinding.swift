// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

/// Additive history of actual phase artifacts. These are content references,
/// not retroactively manufactured frozen PhaseStartV2 receipts.
package struct PrimeValidationDriverV2PublicationPhaseEntryV1: Codable, Equatable {
    package let phase: PrimeValidationDriverPhaseV2
    package let ordinal: Int
    package let evidenceOrigin: String
    package let predecessorPrefixSHA256: String
    package let disposition: PrimeValidationPhaseTerminalDispositionV2
    package let start: PrimeArtifactBinding
    package let terminal: PrimeArtifactBinding?
    package let acceptedOutputBindings: [PrimeArtifactBinding]
    package let activeNanoseconds: UInt64
}

/// An immutable prefix includes its predecessor's exact entry values. The
/// publication envelope, written last, is the sole publication terminal.
package struct PrimeValidationDriverV2PublicationPhasePrefixV1: Codable, Equatable {
    package let schemaVersion: Int
    package let runID: String
    package let intentSHA256: String
    package let sequence: UInt64
    package let previousPrefixSHA256: String
    package let recordedAtUptimeNanoseconds: UInt64
    package let entries: [PrimeValidationDriverV2PublicationPhaseEntryV1]

    package func validate(intent: PrimeValidationRunIntentV2,
                          previous: PrimeValidationDriverV2PublicationPhasePrefixV1?) throws {
        try intent.validate()
        guard schemaVersion == 1, runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              sequence > 0, sequence <= 8, entries.count == Int(sequence),
              recordedAtUptimeNanoseconds > 0,
              entries.map(\.phase) == Array(PrimeValidationDriverPhaseV2.allCases.prefix(entries.count)),
              entries.allSatisfy({ $0.phase != .publication }) else { throw publicationRejected("phase_shape") }
        let predecessor: String
        if let previous {
            guard previous.sequence + 1 == sequence,
                  recordedAtUptimeNanoseconds > previous.recordedAtUptimeNanoseconds,
                  Array(entries.dropLast()) == previous.entries,
                  previous.entries.allSatisfy({ $0.disposition == .succeeded && $0.terminal != nil }) else {
                throw publicationRejected("phase_successor")
            }
            predecessor = try publicationHash(previous)
        } else {
            guard sequence == 1 else { throw publicationRejected("missing_prefix") }
            predecessor = String(repeating: "0", count: 64)
        }
        guard previousPrefixSHA256 == predecessor else { throw publicationRejected("prefix_hash") }
        for (index, value) in entries.enumerated() {
            let distinctArtifacts = [value.start] + (value.terminal.map { [$0] } ?? []) + value.acceptedOutputBindings
            guard value.ordinal == index, value.activeNanoseconds > 0,
                  value.evidenceOrigin == (index < 3 ? "retained_predecessor_projection" : "live_h_phase"),
                  value.activeNanoseconds <= intent.phaseBudgets.first(where: { $0.phase == value.phase })!.maximumActiveNanoseconds,
                  index == entries.count - 1 || value.disposition == .succeeded,
                  value.disposition != .succeeded || value.terminal != nil,
                  index == entries.count - 1 || value.terminal != nil,
                  value.disposition != .succeeded || !value.acceptedOutputBindings.isEmpty,
                  Set(distinctArtifacts.map(\.relativePath)).count == distinctArtifacts.count,
                  value.acceptedOutputBindings.map(\.relativePath) == value.acceptedOutputBindings.map(\.relativePath).sorted(),
                  Set(value.acceptedOutputBindings.map(\.relativePath)).count == value.acceptedOutputBindings.count else {
                throw publicationRejected("phase_terminal")
            }
            try publicationArtifact(value.start)
            if let terminal = value.terminal { try publicationArtifact(terminal) }
            try value.acceptedOutputBindings.forEach { try publicationArtifact($0) }
        }
        guard entries.last!.predecessorPrefixSHA256 == predecessor else { throw publicationRejected("phase_predecessor") }
    }
}

package struct PrimeValidationDriverV2PublicationPhaseHistoryV1: Codable, Equatable {
    package let schemaVersion: Int
    package let runID: String
    package let intentSHA256: String
    package let prefixes: [PrimeValidationDriverV2PublicationPhasePrefixV1]
    package let immutablePrefixBindings: [PrimeArtifactBinding]

    package func validate(intent: PrimeValidationRunIntentV2, requireComplete: Bool) throws {
        guard schemaVersion == 1, runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              !prefixes.isEmpty, prefixes.count <= 8,
              prefixes.count == immutablePrefixBindings.count else { throw publicationRejected("history_shape") }
        var previous: PrimeValidationDriverV2PublicationPhasePrefixV1?
        for (index, prefix) in prefixes.enumerated() {
            try prefix.validate(intent: intent, previous: previous)
            let path = String(format: "execution/phase-ledger-%02d.json", index + 1)
            try publicationArtifact(immutablePrefixBindings[index], path: path,
                data: PrimeCanonicalJSON.encode(prefix))
            previous = prefix
        }
        if requireComplete {
            guard prefixes.count == 8,
                  prefixes.last!.entries.allSatisfy({ $0.disposition == .succeeded && $0.terminal != nil }) else {
                throw publicationRejected("history_not_complete")
            }
        }
    }
}

package struct PrimeValidationDriverV2PublicationSourceV1: Codable, Equatable {
    package let sourceCommit: String
    /// Declared root-tree OID from the accepted capsule/source pin. Gate E
    /// observes ls-tree bytes, not a standalone root-tree OID probe.
    package let sourceTree: String
    /// SHA-256 of the exact equal E discovery/replay stdout bytes.
    package let sourceTreeReplaySHA256: String
    package let sourceIdentitySHA256: String
    package let sourceSnapshotSHA256: String
    package let governorExecutable: PrimeValidationExecutableBindingV2
    package let supervisorExecutable: PrimeValidationExecutableBindingV2
    package let swiftPackageExecutable: PrimeValidationExecutableBindingV2

    package init(sourceCommit: String, sourceTree: String, sourceTreeReplaySHA256: String, sourceIdentitySHA256: String,
        sourceSnapshotSHA256: String, governorExecutable: PrimeValidationExecutableBindingV2,
        supervisorExecutable: PrimeValidationExecutableBindingV2, swiftPackageExecutable: PrimeValidationExecutableBindingV2) {
        self.sourceCommit = sourceCommit; self.sourceTree = sourceTree; self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.sourceTreeReplaySHA256 = sourceTreeReplaySHA256
        self.sourceSnapshotSHA256 = sourceSnapshotSHA256; self.governorExecutable = governorExecutable
        self.supervisorExecutable = supervisorExecutable; self.swiftPackageExecutable = swiftPackageExecutable
    }

    package func validate() throws {
        for value in [sourceCommit, sourceTree] {
            guard value.count == 40, value.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
                throw publicationRejected("source_git_identity")
            }
        }
        try PrimeValidationDriverV2Validation.requireSHA256(sourceIdentitySHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(sourceTreeReplaySHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(sourceSnapshotSHA256)
        try governorExecutable.validate(); try supervisorExecutable.validate(); try swiftPackageExecutable.validate()
    }

    /// Joins declared H scope. The governor independently joins E commit and
    /// equal tree stdout bytes, capsule tree pin, and retained images. This
    /// declaration never proves ownership or turns the tree pin into a probe.
    package func validateDeclaredScope(_ data: Data, intent: PrimeValidationRunIntentV2) throws {
        struct Scope: Codable, Equatable {
            let schema: String
            let intentSHA256: String
            let sourceCommit: String
            let sourceTree: String
            let sourceTreeReplaySHA256: String
            let sourceIdentitySHA256: String
            let governorExecutable: PrimeValidationExecutableBindingV2
            let supervisorExecutable: PrimeValidationExecutableBindingV2
            let referenceScopes: [String]
            let candidateScope: String
            let referenceMaximumActiveNanoseconds: UInt64
            let candidateMaximumActiveNanoseconds: UInt64
        }
        try validate()
        let expected = Scope(schema: "prime_driver_v2_gate_h_declared_execution_scope_v1",
            intentSHA256: try intent.identitySHA256(), sourceCommit: sourceCommit, sourceTree: sourceTree,
            sourceTreeReplaySHA256: sourceTreeReplaySHA256,
            sourceIdentitySHA256: sourceIdentitySHA256, governorExecutable: governorExecutable,
            supervisorExecutable: supervisorExecutable,
            referenceScopes: ["parallel_xctest", "sequential_xctest", "swift_testing"],
            candidateScope: "frozen_suite_contiguous_32_original_planner",
            referenceMaximumActiveNanoseconds: 1_800_000_000_000,
            candidateMaximumActiveNanoseconds: 1_800_000_000_000)
        guard try PrimeCanonicalJSON.encode(expected) == data,
              supervisorExecutable == intent.driverExecutable,
              sourceSnapshotSHA256 == intent.sourceSnapshot.sha256 else { throw publicationRejected("declared_scope") }
    }
}

package struct PrimeValidationDriverV2EvidenceManifestEntryV1: Codable, Equatable {
    package let relativePath: String
    package let kind: String
    package let mode: UInt16
    package let content: PrimeValidationContentBinding?

    package func validate() throws {
        try PrimeValidationDriverV2Validation.requireSafeRelativePath(relativePath)
        switch kind {
        case "directory": guard mode == 0o700, content == nil else { throw publicationRejected("manifest_directory") }
        case "immutable_file", "executable":
            guard mode == (kind == "executable" ? 0o555 : 0o444), let content else {
                throw publicationRejected("manifest_file")
            }
            try content.validate()
            guard content.byteCount <= 512 * 1024 * 1024,
                  kind != "executable" || content.byteCount > 0 else { throw publicationRejected("manifest_file_cap") }
        default: throw publicationRejected("manifest_kind")
        }
    }
}

package struct PrimeValidationDriverV2EvidenceManifestV1: Codable, Equatable {
    package static let path = "execution/evidence-manifest.json"
    package static let finalReceiptPath = "execution/final-receipt.json"
    package static let envelopePath = "execution/publication-envelope.json"
    package static let historyPath = "execution/phase-history.json"
    package let schemaVersion: Int
    package let runID: String
    package let intentSHA256: String
    package let phaseHistorySHA256: String
    package let entries: [PrimeValidationDriverV2EvidenceManifestEntryV1]

    package func validate(intent: PrimeValidationRunIntentV2,
                          history: PrimeValidationDriverV2PublicationPhaseHistoryV1,
                          innerFinalReceiptData: Data) throws {
        try history.validate(intent: intent, requireComplete: true)
        guard schemaVersion == 1, runID == intent.runID, intentSHA256 == (try intent.identitySHA256()),
              phaseHistorySHA256 == (try publicationHash(history)),
              !entries.isEmpty, entries.count <= 100_000,
              entries.map(\.relativePath) == entries.map(\.relativePath).sorted(),
              Set(entries.map(\.relativePath)).count == entries.count,
              !entries.contains(where: { $0.relativePath == Self.path || $0.relativePath == Self.envelopePath }) else {
            throw publicationRejected("manifest_shape")
        }
        try entries.forEach { try $0.validate() }
        let indexed = Dictionary(uniqueKeysWithValues: entries.map { ($0.relativePath, $0) })
        for entry in entries {
            if let slash = entry.relativePath.lastIndex(of: "/") {
                guard indexed[String(entry.relativePath[..<slash])]?.kind == "directory" else {
                    throw publicationRejected("manifest_parent")
                }
            }
        }
        try require(binding: .init(relativePath: Self.finalReceiptPath,
            sha256: PrimeSHA256.hexDigest(of: innerFinalReceiptData), byteCount: UInt64(innerFinalReceiptData.count),
            purpose: .immutableData))
        try require(binding: .init(relativePath: Self.historyPath,
            sha256: publicationHash(history), byteCount: UInt64(PrimeCanonicalJSON.encode(history).count), purpose: .immutableData))
        for binding in history.immutablePrefixBindings { try require(binding: binding) }
        for entry in history.prefixes.last!.entries {
            try require(binding: entry.start)
            if let terminal = entry.terminal { try require(binding: terminal) }
            for binding in entry.acceptedOutputBindings { try require(binding: binding) }
        }
    }

    package func require(binding: PrimeArtifactBinding) throws {
        try publicationArtifact(binding)
        guard let entry = entries.first(where: { $0.relativePath == binding.relativePath }),
              entry.kind == "immutable_file", entry.mode == 0o444,
              entry.content?.byteCount == binding.byteCount,
              entry.content?.sha256 == binding.sha256 else { throw publicationRejected("manifest_binding_join") }
    }

    package func validateObservedInventory(_ observed: [PrimeValidationDriverV2PublicationNamespaceEntry],
        plannedInner: PrimeArtifactBinding) throws {
        var expected = try observed.map(Self.entry)
        expected.append(.init(relativePath: plannedInner.relativePath, kind: "immutable_file", mode: 0o444,
            content: try Self.content(plannedInner.byteCount, plannedInner.sha256)))
        guard plannedInner.relativePath == Self.finalReceiptPath, plannedInner.purpose == .immutableData,
              entries == expected.sorted(by: { $0.relativePath < $1.relativePath }) else {
            throw publicationRejected("manifest_actual_inventory")
        }
    }

    package static func entry(_ value: PrimeValidationDriverV2PublicationNamespaceEntry) throws
        -> PrimeValidationDriverV2EvidenceManifestEntryV1 {
        let content: PrimeValidationContentBinding?
        if let count = value.byteCount, let hash = value.sha256 { content = try Self.content(count, hash) }
        else {
            guard value.byteCount == nil, value.sha256 == nil else { throw publicationRejected("native_content_pair") }
            content = nil
        }
        let entry = PrimeValidationDriverV2EvidenceManifestEntryV1(relativePath: value.relativePath,
            kind: value.kind, mode: value.mode, content: content)
        try entry.validate(); return entry
    }

    fileprivate static func content(_ count: UInt64, _ hash: String) throws -> PrimeValidationContentBinding {
        struct Fields: Encodable { let byteCount: UInt64; let sha256: String }
        return try PrimeCanonicalJSON.decode(PrimeValidationContentBinding.self,
            from: PrimeCanonicalJSON.encode(Fields(byteCount: count, sha256: hash)))
    }

    /// The manifest cannot hash itself. The final exact namespace is this
    /// set plus its own file and the last outer envelope, with no other leaf.
    package var finalNamespacePaths: Set<String> {
        Set(entries.map(\.relativePath)).union([Self.path, Self.envelopePath])
    }
}

/// Only this consumed concrete native permit can publish. Codable values above
/// remain consistency evidence and cannot construct or recover this bridge.
package final class PrimeValidationDriverV2PublicationBinding {
    package let envelope: PrimeValidationDriverV2OuterPublicationEnvelopeV1
    package let manifest: PrimeValidationDriverV2EvidenceManifestV1
    package let observation: PrimeValidationDriverV2PublicationReadbackObservation
    private let session: PrimeValidationDriverV2PublicationSession

    private init(envelope: PrimeValidationDriverV2OuterPublicationEnvelopeV1,
        manifest: PrimeValidationDriverV2EvidenceManifestV1,
        observation: PrimeValidationDriverV2PublicationReadbackObservation,
        session: PrimeValidationDriverV2PublicationSession) {
        self.envelope = envelope; self.manifest = manifest; self.observation = observation; self.session = session
    }

    package func revalidate() throws { try session.revalidate() }

    package static func publish(permit: PrimeValidationDriverV2ExecutionPublicationPermit,
        intent: PrimeValidationRunIntentV2, build: PrimeValidationBuildReceiptV2,
        inventory: PrimeValidationInventoryReceiptV2, plan: PrimeValidationExecutionPlanV2,
        conclusion: PrimeValidationDriverV2ParsedExecutionConclusion,
        history: PrimeValidationDriverV2PublicationPhaseHistoryV1,
        source: PrimeValidationDriverV2PublicationSourceV1,
        acceptedCapsuleSHA256: String) throws -> PrimeValidationDriverV2PublicationBinding {
        // Consumption comes first: even a malformed typed proposal cannot
        // recover this attempt's publication owner and try different inputs.
        let session = try permit.consumeBoundPublicationSession()
        let raw = session.completedExecution
        try history.validate(intent: intent, requireComplete: true)
        try plan.validate(intent: intent, buildReceipt: build, inventoryReceipt: inventory)
        try source.validateDeclaredScope(raw.declaredExecutionGoScopeData, intent: intent)
        try PrimeValidationDriverV2Validation.requireSHA256(acceptedCapsuleSHA256)
        guard try PrimeCanonicalJSON.encode(intent) == raw.canonicalIntentData,
              try PrimeCanonicalJSON.encode(history) == raw.phaseHistoryData,
              history.immutablePrefixBindings == raw.orderedPhasePrefixBindings,
              PrimeValidationContentBinding(data: raw.sourceSnapshotData) == intent.sourceSnapshot,
              raw.packageResolvedBinding.byteCount == intent.packageLock.byteCount,
              raw.packageResolvedBinding.sha256 == intent.packageLock.sha256,
              raw.packageResolvedBinding.purpose == .immutableData,
              raw.orderedShardIdentifiers == plan.shards.map(\.shardID),
              raw.orderedTerminalBindings.count == plan.shards.count,
              raw.orderedAcceptanceBindings.count == plan.shards.count,
              raw.immutableArtifactBindings.map(\.relativePath) == raw.immutableArtifactBindings.map(\.relativePath).sorted(),
              Set(raw.immutableArtifactBindings.map(\.relativePath)).count == raw.immutableArtifactBindings.count else {
            throw publicationRejected("native_completed_join")
        }
        try publicationArtifact(raw.planBinding, data: PrimeCanonicalJSON.encode(plan))
        for binding in [raw.planBinding, raw.goBinding] + raw.orderedTerminalBindings + raw.orderedAcceptanceBindings {
            try publicationArtifact(binding)
            guard raw.immutableArtifactBindings.contains(binding) else { throw publicationRejected("native_prefix_join") }
        }
        for binding in history.immutablePrefixBindings {
            let local = PrimeArtifactBinding(relativePath: String(binding.relativePath.dropFirst("execution/".count)),
                sha256: binding.sha256, byteCount: binding.byteCount, purpose: binding.purpose)
            guard raw.immutableArtifactBindings.contains(local) else { throw publicationRejected("unwritten_phase_prefix") }
        }
        let inner = try PrimeCanonicalJSON.encode(conclusion.finalReceipt)
        let preparation = try session.prepare(phaseHistoryData: PrimeCanonicalJSON.encode(history), innerFinalReceiptData: inner)
        var entries = try preparation.entriesBeforeManifest.map(PrimeValidationDriverV2EvidenceManifestV1.entry)
        entries.append(.init(relativePath: PrimeValidationDriverV2EvidenceManifestV1.finalReceiptPath,
            kind: "immutable_file", mode: 0o444, content: .init(data: inner)))
        let manifest = PrimeValidationDriverV2EvidenceManifestV1(schemaVersion: 1, runID: intent.runID,
            intentSHA256: try intent.identitySHA256(), phaseHistorySHA256: try publicationHash(history),
            entries: entries.sorted { $0.relativePath < $1.relativePath })
        try manifest.validateObservedInventory(preparation.entriesBeforeManifest, plannedInner: preparation.plannedInnerFinalReceiptBinding)
        let envelope = PrimeValidationDriverV2OuterPublicationEnvelopeV1(schemaVersion: 1,
            artifactKind: "prime_driver_v2_outer_publication_envelope_v1", runID: intent.runID,
            intentSHA256: try intent.identitySHA256(), liveAdmissionIdentitySHA256: preparation.liveAdmissionIdentitySHA256,
            acceptedCapsuleSHA256: acceptedCapsuleSHA256,
            finalPhaseLedgerSHA256: try publicationHash(history), preEnvelopeManifestSHA256: try publicationHash(manifest),
            buildReceiptSHA256: try build.identitySHA256(against: intent),
            inventoryReceiptSHA256: try inventory.identitySHA256(intent: intent, buildReceipt: build),
            executionPlanSHA256: try plan.identitySHA256(intent: intent, buildReceipt: build, inventoryReceipt: inventory),
            referenceAggregateSHA256: try publicationHash(conclusion.reference),
            candidateAggregateSHA256: try publicationHash(conclusion.candidate),
            comparisonReceiptSHA256: try publicationHash(conclusion.comparison),
            innerFinalReceiptSHA256: PrimeSHA256.hexDigest(of: inner), source: source,
            disposition: conclusion.finalReceipt.disposition, publicationSequence: history.prefixes.last!.sequence + 1,
            publicationStartedAtUptimeNanoseconds: preparation.publicationStartedAtUptimeNanoseconds,
            publicationDeadlineUptimeNanoseconds: preparation.publicationExpiresAtUptimeNanoseconds)
        try envelope.validate(intent: intent, build: build, inventory: inventory, plan: plan, conclusion: conclusion,
            history: history, manifest: manifest, expectedLiveAdmissionIdentitySHA256: preparation.liveAdmissionIdentitySHA256,
            expectedAcceptedCapsuleSHA256: acceptedCapsuleSHA256, expectedSource: source)
        let manifestData = try PrimeCanonicalJSON.encode(manifest), envelopeData = try PrimeCanonicalJSON.encode(envelope)
        let observation = try session.publish(manifestData: manifestData, innerFinalReceiptData: inner, outerEnvelopeData: envelopeData)
        try publicationArtifact(observation.manifestBinding, path: PrimeValidationDriverV2EvidenceManifestV1.path, data: manifestData)
        try publicationArtifact(observation.innerFinalReceiptBinding, path: PrimeValidationDriverV2EvidenceManifestV1.finalReceiptPath, data: inner)
        try publicationArtifact(observation.outerEnvelopeBinding, path: PrimeValidationDriverV2EvidenceManifestV1.envelopePath, data: envelopeData)
        guard observation.exactFinalNamespacePaths == manifest.finalNamespacePaths.sorted(),
              observation.completedAtUptimeNanoseconds >= envelope.publicationStartedAtUptimeNanoseconds,
              observation.completedAtUptimeNanoseconds < envelope.publicationDeadlineUptimeNanoseconds else {
            throw publicationRejected("native_final_readback")
        }
        return .init(envelope: envelope, manifest: manifest, observation: observation, session: session)
    }
}

/// Failure closeout belongs in the governor's outer journal, outside the
/// execution namespace. It deliberately contains no unobserved aggregates,
/// comparison or final-receipt identity and cannot authorize a successor.
package struct PrimeValidationDriverV2GovernorIncompleteObservationV1: Codable, Equatable {
    package enum Reason: String, Codable { case failedTerminal, startedWithoutTerminal, supervisorRejected, publicationRejected }
    package let schemaVersion: Int
    package let artifactKind: String
    package let runID: String
    package let intentSHA256: String
    package let acceptedCapsuleSHA256: String
    package let disposition: PrimeValidationDisposition
    package let reason: Reason
    package let immutablePrefixBindings: [PrimeArtifactBinding]
    package let observedStartBindings: [PrimeArtifactBinding]
    package let observedTerminalBindings: [PrimeArtifactBinding]
    package let supervisorExitCode: Int32?
    package let observedAtUptimeNanoseconds: UInt64
    package let successorAuthorized: Bool

    package init(schemaVersion: Int, artifactKind: String, runID: String, intentSHA256: String,
        acceptedCapsuleSHA256: String, disposition: PrimeValidationDisposition, reason: Reason,
        immutablePrefixBindings: [PrimeArtifactBinding], observedStartBindings: [PrimeArtifactBinding],
        observedTerminalBindings: [PrimeArtifactBinding], supervisorExitCode: Int32?,
        observedAtUptimeNanoseconds: UInt64, successorAuthorized: Bool) {
        self.schemaVersion = schemaVersion; self.artifactKind = artifactKind; self.runID = runID
        self.intentSHA256 = intentSHA256; self.acceptedCapsuleSHA256 = acceptedCapsuleSHA256
        self.disposition = disposition; self.reason = reason; self.immutablePrefixBindings = immutablePrefixBindings
        self.observedStartBindings = observedStartBindings; self.observedTerminalBindings = observedTerminalBindings
        self.supervisorExitCode = supervisorExitCode; self.observedAtUptimeNanoseconds = observedAtUptimeNanoseconds
        self.successorAuthorized = successorAuthorized
    }

    /// Expected arguments must come from the governor's held readback. This
    /// function checks data joins only; it has no publication/launch method.
    package func validate(expectedRunID: String, expectedIntentSHA256: String,
        expectedAcceptedCapsuleSHA256: String, actualPrefixBindings: [PrimeArtifactBinding],
        actualStartBindings: [PrimeArtifactBinding], actualTerminalBindings: [PrimeArtifactBinding],
        actualSupervisorExitCode: Int32?, actualObservedAtUptimeNanoseconds: UInt64,
        actualReason: Reason) throws {
        guard schemaVersion == 1, artifactKind == "prime_driver_v2_gate_h_governor_incomplete_observation_v1",
              runID == expectedRunID, intentSHA256 == expectedIntentSHA256,
              acceptedCapsuleSHA256 == expectedAcceptedCapsuleSHA256,
              disposition == .incomplete, !successorAuthorized,
              reason == actualReason,
              immutablePrefixBindings == actualPrefixBindings,
              observedStartBindings == actualStartBindings,
              observedTerminalBindings == actualTerminalBindings,
              supervisorExitCode == actualSupervisorExitCode,
              observedAtUptimeNanoseconds == actualObservedAtUptimeNanoseconds,
              observedAtUptimeNanoseconds > 0,
              immutablePrefixBindings.count <= 8,
              observedStartBindings.count <= 128, observedTerminalBindings.count <= observedStartBindings.count else {
            throw publicationRejected("incomplete_observed_joins")
        }
        try PrimeValidationDriverV2Validation.requireSHA256(intentSHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(acceptedCapsuleSHA256)
        for values in [immutablePrefixBindings, observedStartBindings, observedTerminalBindings] {
            guard Set(values.map(\.relativePath)).count == values.count else { throw publicationRejected("incomplete_duplicate") }
            try values.forEach { try publicationArtifact($0) }
        }
        switch reason {
        case .failedTerminal: guard !observedTerminalBindings.isEmpty else { throw publicationRejected("missing_failed_terminal") }
        case .startedWithoutTerminal:
            guard observedStartBindings.count > observedTerminalBindings.count else { throw publicationRejected("missing_unfinished_start") }
        case .supervisorRejected:
            guard let supervisorExitCode, supervisorExitCode != 0 else { throw publicationRejected("missing_supervisor_rejection") }
        case .publicationRejected: break
        }
    }
}

package struct PrimeValidationDriverV2OuterPublicationEnvelopeV1: Codable, Equatable {
    package let schemaVersion: Int
    package let artifactKind: String
    package let runID: String
    package let intentSHA256: String
    package let liveAdmissionIdentitySHA256: String
    package let acceptedCapsuleSHA256: String
    package let finalPhaseLedgerSHA256: String
    package let preEnvelopeManifestSHA256: String
    package let buildReceiptSHA256: String
    package let inventoryReceiptSHA256: String
    package let executionPlanSHA256: String
    package let referenceAggregateSHA256: String
    package let candidateAggregateSHA256: String
    package let comparisonReceiptSHA256: String
    package let innerFinalReceiptSHA256: String
    package let source: PrimeValidationDriverV2PublicationSourceV1
    package let disposition: PrimeValidationDisposition
    package let publicationSequence: UInt64
    package let publicationStartedAtUptimeNanoseconds: UInt64
    package let publicationDeadlineUptimeNanoseconds: UInt64

    /// Data consistency only. Successful validation does not recreate the
    /// live admission identity or a native publication permit.
    package func validate(intent: PrimeValidationRunIntentV2,
        build: PrimeValidationBuildReceiptV2, inventory: PrimeValidationInventoryReceiptV2,
        plan: PrimeValidationExecutionPlanV2, conclusion: PrimeValidationDriverV2ParsedExecutionConclusion,
        history: PrimeValidationDriverV2PublicationPhaseHistoryV1,
        manifest: PrimeValidationDriverV2EvidenceManifestV1,
        expectedLiveAdmissionIdentitySHA256: String,
        expectedAcceptedCapsuleSHA256: String,
        expectedSource: PrimeValidationDriverV2PublicationSourceV1) throws {
        try history.validate(intent: intent, requireComplete: true)
        try plan.validate(intent: intent, buildReceipt: build, inventoryReceipt: inventory)
        try source.validate()
        let inner = try PrimeCanonicalJSON.encode(conclusion.finalReceipt)
        try manifest.validate(intent: intent, history: history, innerFinalReceiptData: inner)
        try conclusion.finalReceipt.validateAssumingValidatedComparison(
            comparison: conclusion.comparison, reference: conclusion.reference, candidate: conclusion.candidate)
        guard schemaVersion == 1, artifactKind == "prime_driver_v2_outer_publication_envelope_v1",
              runID == intent.runID, intentSHA256 == (try intent.identitySHA256()),
              source == expectedSource,
              source.sourceSnapshotSHA256 == intent.sourceSnapshot.sha256,
              source.supervisorExecutable == intent.driverExecutable,
              acceptedCapsuleSHA256 == expectedAcceptedCapsuleSHA256,
              liveAdmissionIdentitySHA256 == expectedLiveAdmissionIdentitySHA256,
              finalPhaseLedgerSHA256 == (try publicationHash(history)),
              preEnvelopeManifestSHA256 == (try publicationHash(manifest)),
              buildReceiptSHA256 == (try build.identitySHA256(against: intent)),
              inventoryReceiptSHA256 == (try inventory.identitySHA256(intent: intent, buildReceipt: build)),
              executionPlanSHA256 == (try plan.identitySHA256(intent: intent, buildReceipt: build, inventoryReceipt: inventory)),
              referenceAggregateSHA256 == (try publicationHash(conclusion.reference)),
              candidateAggregateSHA256 == (try publicationHash(conclusion.candidate)),
              comparisonReceiptSHA256 == (try publicationHash(conclusion.comparison)),
              innerFinalReceiptSHA256 == PrimeSHA256.hexDigest(of: inner),
              disposition == conclusion.finalReceipt.disposition,
              disposition == .completePass || disposition == .completeFail,
              conclusion.reference.runID == runID, conclusion.candidate.runID == runID,
              conclusion.comparison.runID == runID,
              conclusion.reference.executionPlanSHA256 == executionPlanSHA256,
              conclusion.candidate.executionPlanSHA256 == executionPlanSHA256,
              conclusion.comparison.executionPlanSHA256 == executionPlanSHA256,
              conclusion.reference.inventorySHA256 == plan.inventorySHA256,
              conclusion.candidate.inventorySHA256 == plan.inventorySHA256,
              conclusion.comparison.inventorySHA256 == plan.inventorySHA256,
              publicationSequence == history.prefixes.last!.sequence + 1,
              publicationStartedAtUptimeNanoseconds > 0,
              history.prefixes.last!.recordedAtUptimeNanoseconds <= publicationStartedAtUptimeNanoseconds,
              publicationDeadlineUptimeNanoseconds > publicationStartedAtUptimeNanoseconds,
              publicationDeadlineUptimeNanoseconds - publicationStartedAtUptimeNanoseconds == 30_000_000_000,
              intent.phaseBudgets.first(where: { $0.phase == .publication })?.maximumActiveNanoseconds == 30_000_000_000 else {
            throw publicationRejected("envelope_join")
        }
        try PrimeValidationDriverV2Validation.requireSHA256(liveAdmissionIdentitySHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(acceptedCapsuleSHA256)
    }
}

private func publicationArtifact(_ binding: PrimeArtifactBinding, path: String? = nil, data: Data? = nil) throws {
    try PrimeValidationDriverV2Validation.requireSafeRelativePath(binding.relativePath)
    try PrimeValidationDriverV2Validation.requireSHA256(binding.sha256)
    guard binding.purpose == .immutableData, binding.byteCount <= 512 * 1024 * 1024,
          path == nil || path == binding.relativePath,
          data == nil || (binding.byteCount == data!.count && binding.sha256 == PrimeSHA256.hexDigest(of: data!)) else {
        throw publicationRejected("artifact_binding")
    }
}
private func publicationHash<T: Encodable>(_ value: T) throws -> String {
    PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(value))
}
private func publicationRejected(_ reason: String) -> Error {
    PrimeValidationDriverV2Error.invalidBinding("publication_" + reason)
}

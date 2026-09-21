// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import Darwin

/// Closed declarations of complete H phase budgets. Selection never creates
/// execution authority and never follows from observed inventory size.
@_spi(PrimeValidationDriverV2RoleFacade)
public enum PrimeValidationDriverV2ExecutionBudgetProfile: String, CaseIterable, Sendable {
    case frozenV1 = "frozen_v1"
    case currentSourceExecutionV1 = "current_source_execution_v1"

    public var executionArmMaximumActiveNanoseconds: UInt64 {
        self == .frozenV1 ? 1_800_000_000_000 : 10_800_000_000_000
    }

    public func maximumActiveNanoseconds(phase: String) throws -> UInt64 {
        switch phase {
        case "source_admission", "execution_plan", "publication": return 30_000_000_000
        case "build": return 900_000_000_000
        case "inventory": return 300_000_000_000
        case "reference_execution", "candidate_execution": return executionArmMaximumActiveNanoseconds
        case "reconciliation": return 120_000_000_000
        case "comparison": return 60_000_000_000
        default: throw hRejected("unknown_execution_budget_phase")
        }
    }

    public var canonicalPhaseBudgetsData: Data {
        get throws {
            try HJSON.encode(Self.phases.sorted().map { phase in
                ["phase": phase, "maximumActiveNanoseconds": try maximumActiveNanoseconds(phase: phase)] as [String: Any]
            })
        }
    }

    public var outerMaximumActiveNanoseconds: UInt64 {
        get throws {
            var total: UInt64 = 30_000_000_000
            for phase in Self.phases {
                let (next, overflow) = total.addingReportingOverflow(try maximumActiveNanoseconds(phase: phase))
                guard !overflow else { throw hRejected("execution_budget_overflow") }
                total = next
            }
            return total
        }
    }

    public static func resolve(canonicalPhaseBudgetsData data: Data) throws -> Self {
        for profile in allCases where try data == profile.canonicalPhaseBudgetsData { return profile }
        throw hRejected("unknown_execution_budget_profile")
    }

    public static func resolve(canonicalIntentData data: Data) throws -> Self {
        let intent = try HJSON.object(data)
        guard let budgets = intent["phaseBudgets"] else { throw hRejected("missing_execution_budget_profile") }
        let profile = try resolve(canonicalPhaseBudgetsData: HJSON.encode(budgets))
        if profile == .currentSourceExecutionV1 {
            guard let baseline = intent["baseline"],
                  try PrimeValidationDriverV2InventoryProfile.resolve(canonicalBaselineData: HJSON.encode(baseline))
                    == .currentSourceInventoryV1 else { throw hRejected("execution_budget_inventory_profile") }
        }
        return profile
    }

    private static let phases = ["source_admission", "build", "inventory", "execution_plan",
        "reference_execution", "candidate_execution", "reconciliation", "comparison", "publication"]
}

/// Declared H scope, never an execution capability. Core joins both actual E
/// HEAD values, its exact replayed tree-byte digest and retained source identity.
/// The root-tree OID remains a capsule/source pin, not an E probe result. The
/// outer governor independently joins that pin and both held executable images.
enum PrimeValidationDriverV2ExecutionGoScope {
    static func validate(_ data: Data, intentData: Data, retainedSourceIdentitySHA256: String) throws {
        let value = try HJSON.object(data)
        let intent = try HJSON.object(intentData)
        let budgetProfile = try PrimeValidationDriverV2ExecutionBudgetProfile.resolve(canonicalIntentData: intentData)
        let keys: Set<String> = ["schema", "intentSHA256", "sourceCommit", "sourceTree", "sourceTreeReplaySHA256",
            "sourceIdentitySHA256", "governorExecutable", "supervisorExecutable",
            "referenceScopes", "candidateScope", "referenceMaximumActiveNanoseconds",
            "candidateMaximumActiveNanoseconds"]
        guard Set(value.keys) == keys,
              value["schema"] as? String == "prime_driver_v2_gate_h_declared_execution_scope_v1",
              value["intentSHA256"] as? String == PrimeSHA256.hexDigest(of: intentData),
              hex(value["sourceCommit"], count: 40), hex(value["sourceTree"], count: 40),
              hex(value["sourceTreeReplaySHA256"], count: 64),
              hex(value["sourceIdentitySHA256"], count: 64),
              value["sourceIdentitySHA256"] as? String == retainedSourceIdentitySHA256,
              value["referenceScopes"] as? [String] == ["parallel_xctest", "sequential_xctest", "swift_testing"],
              value["candidateScope"] as? String == "frozen_suite_contiguous_32_original_planner",
              let referenceBudget = value["referenceMaximumActiveNanoseconds"],
              let candidateBudget = value["candidateMaximumActiveNanoseconds"],
              try HJSON.encode([referenceBudget]) == HJSON.encode([budgetProfile.executionArmMaximumActiveNanoseconds]),
              try HJSON.encode([candidateBudget]) == HJSON.encode([budgetProfile.executionArmMaximumActiveNanoseconds]),
              let declaredSupervisor = value["supervisorExecutable"], let actualIntentSupervisor = intent["driverExecutable"],
              try HJSON.encode(declaredSupervisor) == HJSON.encode(actualIntentSupervisor)
        else { throw hRejected("declared_go_scope") }
        try executable(value["governorExecutable"])
        try executable(value["supervisorExecutable"])
    }

    static func joinObservedPrime(_ data: Data, predecessor: PrimeValidationDriverV2FixedProbeRawObservation,
        retainedSourceIdentitySHA256: String) throws {
        let declared = try HJSON.object(data)
        guard predecessor.supervisorProcessIdentifier == getpid(),
              predecessor.sourceIdentitySHA256 == retainedSourceIdentitySHA256,
              predecessor.orderedProcesses.count == 16,
              let commit = declared["sourceCommit"] as? String,
              let treeDigest = declared["sourceTreeReplaySHA256"] as? String else {
            throw hRejected("go_native_E_scope")
        }
        func output(_ role: PrimeValidationDriverV2FixedProbeRole) throws -> Data {
            let matches = predecessor.orderedProcesses.filter { $0.role == role }
            guard matches.count == 1, matches[0].exitedNormally, matches[0].exitStatus == 0,
                  matches[0].standardOutputReachedEOF, !matches[0].standardOutputOverflowed else {
                throw hRejected("go_native_E_role")
            }
            return matches[0].standardOutput
        }
        let discovery = try output(.primeTreeDiscovery), replay = try output(.primeTreeReplay)
        try joinPrimeBytes(commit: commit, treeDigest: treeDigest, headPre: output(.primeHeadPre),
            headPost: output(.primeHeadPost), discovery: discovery, replay: replay)
        // sourceTree is the capsule-declared Git tree OID. E's native tree
        // observation is the digest of its exact admitted-path ls-tree bytes.
    }

    static func joinPrimeBytes(commit: String, treeDigest: String, headPre: Data, headPost: Data,
        discovery: Data, replay: Data) throws {
        let expectedHead = Data((commit + "\n").utf8)
        guard hex(commit, count: 40), hex(treeDigest, count: 64),
              headPre == expectedHead, headPost == expectedHead,
              !discovery.isEmpty, discovery == replay, PrimeSHA256.hexDigest(of: replay) == treeDigest else {
            throw hRejected("go_native_E_commit_tree")
        }
    }

    private static func hex(_ value: Any?, count: Int) -> Bool {
        guard let value = value as? String, value.utf8.count == count else { return false }
        return value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }

    private static func executable(_ value: Any?) throws {
        guard let value = value as? [String: Any], Set(value.keys) == ["absolutePath", "content"],
              let path = value["absolutePath"] as? String, path.first == "/", path != "/",
              path.utf8.count <= 4096, !path.utf8.contains(0), !path.contains("//"),
              !path.hasSuffix("/"), !path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
              let content = value["content"] as? [String: Any], Set(content.keys) == ["byteCount", "sha256"],
              let count = content["byteCount"] as? NSNumber, count.uint64Value > 0,
              try HJSON.encode([count]) == HJSON.encode([count.uint64Value]),
              hex(content["sha256"], count: 64) else { throw hRejected("declared_go_image") }
    }
}

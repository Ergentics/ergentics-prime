// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import Darwin

/// Declared H scope, never an execution capability. Core joins both actual E
/// HEAD values, its exact replayed tree-byte digest and retained source identity.
/// The root-tree OID remains a capsule/source pin, not an E probe result. The
/// outer governor independently joins that pin and both held executable images.
enum PrimeValidationDriverV2ExecutionGoScope {
    static func validate(_ data: Data, intentData: Data, retainedSourceIdentitySHA256: String) throws {
        let value = try HJSON.object(data)
        let intent = try HJSON.object(intentData)
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
              try HJSON.encode([referenceBudget]) == HJSON.encode([UInt64(1_800_000_000_000)]),
              try HJSON.encode([candidateBudget]) == HJSON.encode([UInt64(1_800_000_000_000)]),
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

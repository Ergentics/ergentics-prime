import Foundation
import XCTest

final class ManagedWorkspaceProjectionTests: XCTestCase {
    private let oidA = String(repeating: "a", count: 40)
    private let oidB = String(repeating: "b", count: 40)
    private let oidC = String(repeating: "c", count: 40)
    private let oidD = String(repeating: "d", count: 40)

    private func idleStatus() -> ManagedWorkspaceAssessmentLease.Status {
        ManagedWorkspaceAssessmentLease.Status(phase: .idle, workspaceID: nil, generation: nil)
    }

    private func data(
        path: String = "/Users/first-canary/Prime-Secret",
        observedAt: String = "2026-08-30T18:00:00Z",
        headMode: String = "branch",
        branch: Any = "customer/secret-alpha",
        headOID: Any? = nil,
        changes: Any? = ["staged": 0, "unstaged": 2, "untracked": NSNull()],
        remotes: [[String: Any]] = [[
            "name": "private-origin",
            "url": "https://example.invalid/private/secret-prime.git"
        ]],
        upstream: Any? = nil,
        consistency: String = "stable",
        pretty: Bool = false
    ) throws -> Data {
        var object: [String: Any] = [
            "schema": PrimeGitSnapshot.schemaIdentifier,
            "repositoryPath": path,
            "observedAt": observedAt,
            "headMode": headMode,
            "remotes": remotes,
            "consistency": consistency
        ]
        object["branch"] = branch
        switch headMode {
        case "unborn": object["headOID"] = NSNull()
        default: object["headOID"] = headOID ?? oidA
        }
        if let changes { object["changeCounts"] = changes }
        if let upstream { object["upstream"] = upstream }
        return try JSONSerialization.data(
            withJSONObject: object,
            options: pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
        )
    }

    private func project(_ data: Data,
                         status: ManagedWorkspaceAssessmentLease.Status? = nil) throws
        -> ManagedWorkspaceProductGUIPresentation {
        try ManagedWorkspaceProjector.productGUIAndAccessibility(
            observation: ManagedWorkspaceObservationParser.primeSnapshot(data),
            leaseStatus: status ?? idleStatus()
        )
    }

    func testEmptyPresentationContainsOnlyRegisteredProductLabel() throws {
        let value = try ManagedWorkspaceProjector.productGUIAndAccessibility(
            observation: nil, leaseStatus: idleStatus()
        )
        XCTAssertEqual(value.workspaceDisplayName, "Prime")
        XCTAssertEqual(value.observation, .notImported)
        XCTAssertEqual(value.activity, .idle)
    }

    func testForbiddenFieldsAreNoninterfering() throws {
        let first = try data(
            upstream: ["ref": "refs/remotes/private-origin/customer-secret",
                       "commitOID": oidB, "ahead": 2, "behind": 1]
        )
        let second = try data(
            path: "/Volumes/second-canary/Other-Secret",
            observedAt: "2025-01-02T03:04:05Z",
            branch: "release/second-secret",
            headOID: oidC,
            remotes: [["name": "confidential-backup",
                       "url": "ssh://example.invalid/another/secret.git"]],
            upstream: ["ref": "refs/remotes/confidential-backup/hidden",
                       "commitOID": oidD, "ahead": 2, "behind": 1],
            pretty: true
        )
        XCTAssertNotEqual(first, second)
        XCTAssertEqual(try project(first), try project(second))
    }

    func testReflectionContainsNoForbiddenCanaryOrRawIdentifier() throws {
        let value = try project(data(
            upstream: ["ref": "refs/remotes/private-origin/customer-secret",
                       "commitOID": oidB, "ahead": 2, "behind": 1]
        ))
        let rendered = String(reflecting: value)
        for forbidden in [
            "first-canary", "Prime-Secret", "customer/secret-alpha",
            "private-origin", "example.invalid", "secret-prime", oidA, oidB,
            "2026-08-30", ManagedWorkspaceObservation.primeParserID,
            PrimeGitSnapshot.schemaIdentifier
        ] {
            XCTAssertFalse(rendered.contains(forbidden), forbidden)
        }
    }

    func testClaimAndHeadModesRemainExplicitlyProducerReported() throws {
        let cases: [(String, String, Any, ManagedWorkspaceProductGUIPresentation.Claim,
                     ManagedWorkspaceProductGUIPresentation.ReportedHeadMode)] = [
            ("unchecked", "branch", "main", .unchecked, .branch),
            ("stable", "detached", NSNull(), .producerReportedStable, .detached),
            ("changed", "unborn", "new-main", .producerReportedChanged, .unborn)
        ]
        for (consistency, mode, branch, claim, head) in cases {
            let presentation = try project(data(
                headMode: mode, branch: branch, changes: nil, remotes: [],
                consistency: consistency
            ))
            guard case .imported(let imported) = presentation.observation else {
                return XCTFail("Expected imported presentation")
            }
            XCTAssertEqual(imported.claim, claim)
            XCTAssertEqual(imported.head, head)
        }
    }

    func testUnknownAndZeroCountsRemainDistinct() throws {
        let missing = try project(data(changes: nil, remotes: []))
        let zero = try project(data(
            changes: ["staged": 0, "unstaged": NSNull(), "untracked": 0],
            remotes: []
        ))
        guard case .imported(let missingValue) = missing.observation,
              case .imported(let zeroValue) = zero.observation else {
            return XCTFail("Expected imported presentations")
        }
        XCTAssertNil(missingValue.changes)
        XCTAssertEqual(zeroValue.changes?.staged, 0)
        XCTAssertNil(zeroValue.changes?.unstaged)
        XCTAssertEqual(zeroValue.changes?.untracked, 0)
    }

    func testRemoteDetailsCoarsenToPresenceOnly() throws {
        let absent = try project(data(remotes: []))
        let present = try project(data(remotes: [["name": "one"], ["name": "two"]]))
        guard case .imported(let absentValue) = absent.observation,
              case .imported(let presentValue) = present.observation else {
            return XCTFail("Expected imported presentations")
        }
        XCTAssertEqual(absentValue.remotes, .producerReportedNone)
        XCTAssertEqual(presentValue.remotes, .producerReportedPresent)
    }

    func testCachedComparisonRequiresReportedPair() throws {
        let absent = try project(data(
            upstream: ["ref": "refs/remotes/origin/main"]
        ))
        let present = try project(data(
            upstream: ["ref": "refs/remotes/origin/main", "commitOID": oidB,
                       "ahead": 4, "behind": 3]
        ))
        guard case .imported(let absentValue) = absent.observation,
              case .imported(let presentValue) = present.observation else {
            return XCTFail("Expected imported presentations")
        }
        XCTAssertEqual(absentValue.cachedComparison, .notRecorded)
        XCTAssertEqual(presentValue.cachedComparison, .producerReported(ahead: 4, behind: 3))
    }

    func testActivityCoarsensLeasePhasesAndDropsGeneration() throws {
        let values: [(ManagedWorkspaceAssessmentLease.Phase,
                      ManagedWorkspaceProductGUIPresentation.Activity)] = [
            (.active, .assessing),
            (.cancellationRequested, .cancellationRequested),
            (.workerReturned, .settling),
            (.postflightSettled, .settling)
        ]
        for (phase, activity) in values {
            let first = ManagedWorkspaceAssessmentLease.Status(
                phase: phase, workspaceID: .prime, generation: 1
            )
            let second = ManagedWorkspaceAssessmentLease.Status(
                phase: phase, workspaceID: .prime, generation: 9_999
            )
            let a = try project(data(), status: first)
            let b = try project(data(), status: second)
            XCTAssertEqual(a.activity, activity)
            XCTAssertEqual(a, b)
        }
    }

    func testReplacingActivityCannotRestoreDiscardedSourceFields() throws {
        let secret = "/PRIVATE/replacing-activity-canary"
        let projected = try project(data(path: secret))
        let active = ManagedWorkspaceProjector.replacingActivity(in: projected, with: .assessing)
        let unavailable = ManagedWorkspaceProjector.replacingActivity(in: active, with: .unavailable)
        XCTAssertEqual(active.activity, .assessing)
        XCTAssertEqual(unavailable.activity, .unavailable)
        XCTAssertEqual(unavailable.observation, projected.observation)
        XCTAssertFalse(String(reflecting: unavailable).contains(secret))
    }

    func testStatusSubjectMismatchRejectsFailClosed() throws {
        let other = try XCTUnwrap(ManagedWorkspaceID(rawValue: "other"))
        let invalid: [ManagedWorkspaceAssessmentLease.Status] = [
            .init(phase: .idle, workspaceID: .prime, generation: 1),
            .init(phase: .active, workspaceID: nil, generation: nil),
            .init(phase: .active, workspaceID: other, generation: 1),
            .init(phase: .active, workspaceID: .prime, generation: nil)
        ]
        for status in invalid {
            XCTAssertThrowsError(try project(data(), status: status)) {
                XCTAssertEqual($0 as? ManagedWorkspaceProjectionError, .statusMismatch)
            }
        }
    }

    func testMaximumReportedCountProjectsExactly() throws {
        let value = try project(data(changes: [
            "staged": PrimeGitSnapshot.maximumCount,
            "unstaged": PrimeGitSnapshot.maximumCount,
            "untracked": PrimeGitSnapshot.maximumCount
        ]))
        guard case .imported(let imported) = value.observation else {
            return XCTFail("Expected imported presentation")
        }
        XCTAssertEqual(imported.changes?.staged, UInt32(PrimeGitSnapshot.maximumCount))
        XCTAssertEqual(imported.changes?.unstaged, UInt32(PrimeGitSnapshot.maximumCount))
        XCTAssertEqual(imported.changes?.untracked, UInt32(PrimeGitSnapshot.maximumCount))
    }

}

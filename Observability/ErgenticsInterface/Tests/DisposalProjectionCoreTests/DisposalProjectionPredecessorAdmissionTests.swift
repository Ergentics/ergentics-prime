import Darwin
import Foundation
@testable import DisposalProjectionCore
import XCTest

final class DisposalProjectionPredecessorAdmissionTests: XCTestCase {
    private let logicalPath = "retained/predecessor-chain.jsonl"

    func testExactGenesisPrefixAndTerminalChainDerivesEveryPredecessorID() throws {
        let roots = testRoots(3)
        defer { roots.forEach(removeProjection) }

        let prefix = predecessorJournal(frameCount: 1)
        let successor = predecessorJournal(frameCount: 2)
        let terminal = predecessorJournal(frameCount: 3)
        let first = try DisposalProjectionSetBuilder.build(
            request: .init(journal: prefix, journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let second = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: successor,
                journalLogicalPath: logicalPath,
                predecessor: reference(first)),
            outputRootPath: roots[1])
        let third = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: terminal,
                journalLogicalPath: logicalPath,
                predecessor: reference(second)),
            outputRootPath: roots[2])

        for root in roots {
            XCTAssertTrue(pathExists(root))
            XCTAssertFalse(pathExists(DisposalSealedArtifactSet.stagingPath(for: root)))
        }

        XCTAssertFalse(first.terminal)
        XCTAssertFalse(second.terminal)
        XCTAssertTrue(third.terminal)
        XCTAssertEqual(first.status, "ABSTAIN_NONTERMINAL_PREFIX_PROJECTION")
        XCTAssertEqual(third.status, "PASS_NONAUTHORITATIVE_TERMINAL_PROJECTION")
        let firstSnapshot = try admitted(root: roots[0], seal: first.sealSHA256)
        let secondSnapshot = try admitted(root: roots[1], seal: second.sealSHA256)
        let thirdSnapshot = try admitted(root: roots[2], seal: third.sealSHA256)
        XCTAssertNil(firstSnapshot.metadata.predecessorProjectionID)
        XCTAssertEqual(secondSnapshot.metadata.predecessorProjectionID, first.projectionID)
        XCTAssertEqual(thirdSnapshot.metadata.predecessorProjectionID, second.projectionID)
        XCTAssertEqual(firstSnapshot.metadata.frameCount, 1)
        XCTAssertEqual(secondSnapshot.metadata.frameCount, 2)
        XCTAssertEqual(thirdSnapshot.metadata.frameCount, 3)
        assertPublicMachinePrefix(firstSnapshot, successor: secondSnapshot)
        assertPublicMachinePrefix(secondSnapshot, successor: thirdSnapshot)
        XCTAssertEqual(thirdSnapshot.metadata.status, "PASS_NONAUTHORITATIVE_TERMINAL_PROJECTION")
        XCTAssertTrue(third.sourceSealed)
        XCTAssertEqual(thirdSnapshot.metadata.authorityVector, "00000000")
        XCTAssertFalse(thirdSnapshot.metadata.authoritative)
        XCTAssertFalse(thirdSnapshot.metadata.mayFeedController)

        let evidence = try DisposalSQLiteConnection(serializedReadOnly: Data(
            contentsOf: URL(fileURLWithPath: third.evidencePath)))
        defer { try? evidence.close() }
        XCTAssertEqual(
            try evidence.scalarText(
                "SELECT predecessor_projection_id FROM evidence_seal WHERE singleton=1"),
            second.projectionID)
    }

    func testMissingWrongSealEqualAndShorterRejectBeforeOutputCreation() throws {
        let roots = testRoots(6)
        defer { roots.forEach(removeProjection) }
        let prefix = predecessorJournal(frameCount: 1)
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(journal: prefix, journalLogicalPath: logicalPath),
            outputRootPath: roots[0])

        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: .init(
                    rootPath: roots[0],
                    expectedSealSHA256: String(repeating: "0", count: 64))),
            outputRoot: roots[1],
            code: "DISPOSAL_READER_SEAL_SHA256")
        assertPathAbsent(roots[1])

        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: .init(
                    rootPath: roots[5],
                    expectedSealSHA256: predecessor.sealSHA256)),
            outputRoot: roots[2],
            code: "PREDECESSOR_ROOT_MISSING")
        assertPathAbsent(roots[2])

        assertBuildReject(
            request: .init(
                journal: prefix,
                journalLogicalPath: logicalPath,
                predecessor: reference(predecessor)),
            outputRoot: roots[3],
            code: "PREDECESSOR_STRICT_EXTENSION")
        assertPathAbsent(roots[3])

        let twoFrameRoot = roots[4]
        let twoFrame = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath),
            outputRootPath: twoFrameRoot)
        assertBuildReject(
            request: .init(
                journal: prefix,
                journalLogicalPath: logicalPath,
                predecessor: reference(twoFrame)),
            outputRoot: roots[5],
            code: "PREDECESSOR_STRICT_EXTENSION")
        assertPathAbsent(roots[5])
    }

    func testLogicalIdentityEpochPrefixAndTerminalContinuityRejects() throws {
        let roots = testRoots(8)
        defer { roots.forEach(removeProjection) }
        let twoFrame = predecessorJournal(frameCount: 2)
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(journal: twoFrame, journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let exactReference = reference(predecessor)

        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 3),
                journalLogicalPath: logicalPath + ".drift",
                predecessor: exactReference),
            outputRoot: roots[1],
            code: "PREDECESSOR_LOGICAL_PATH_JOIN")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(
                    frameCount: 3,
                    invocationID: String(repeating: "2", count: 64)),
                journalLogicalPath: logicalPath,
                predecessor: exactReference),
            outputRoot: roots[2],
            code: "PREDECESSOR_INVOCATION_JOIN")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 3, epochLabel: "EPOCH_B"),
                journalLogicalPath: logicalPath,
                predecessor: exactReference),
            outputRoot: roots[3],
            code: "PREDECESSOR_EPOCH_JOIN")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 3, secondValue: "DRIFT"),
                journalLogicalPath: logicalPath,
                predecessor: exactReference),
            outputRoot: roots[4],
            code: "PREDECESSOR_SOURCE_PREFIX_JOIN")

        let terminal = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 3),
                journalLogicalPath: logicalPath),
            outputRootPath: roots[5])
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 3),
                journalLogicalPath: logicalPath,
                predecessor: reference(terminal)),
            outputRoot: roots[6],
            code: "PREDECESSOR_NOT_APPENDABLE")
        for root in roots[1...4] + [roots[6]] { assertPathAbsent(root) }
    }

    func testRootModeInventoryAndLeafModeRejectBeforeOutputCreation() throws {
        let roots = testRoots(4)
        let evidenceLeaf = roots[0] + "/" + DisposalProjectionSetV1.evidenceLeaf
        let extraLeaf = roots[0] + "/unexpected-leaf"
        defer {
            _ = chmod(roots[0], 0o700)
            _ = chmod(evidenceLeaf, 0o400)
            _ = unlink(extraLeaf)
            _ = chmod(roots[0], 0o500)
            roots.forEach(removeProjection)
        }
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRootPath: roots[0])

        try requireSyscall(chmod(roots[0], 0o700), operation: "chmod-root-drift")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: reference(predecessor)),
            outputRoot: roots[1],
            code: "DISPOSAL_READER_ROOT_MODE")
        assertPathAbsent(roots[1])
        try requireSyscall(chmod(roots[0], 0o500), operation: "chmod-root-restore")

        try requireSyscall(chmod(roots[0], 0o700), operation: "chmod-root-leaf-open")
        try requireSyscall(chmod(evidenceLeaf, 0o600), operation: "chmod-leaf-drift")
        try requireSyscall(chmod(roots[0], 0o500), operation: "chmod-root-leaf-seal")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: reference(predecessor)),
            outputRoot: roots[2],
            code: "DISPOSAL_READER_LEAF_MODE")
        assertPathAbsent(roots[2])
        try requireSyscall(chmod(roots[0], 0o700), operation: "chmod-root-leaf-restore")
        try requireSyscall(chmod(evidenceLeaf, 0o400), operation: "chmod-leaf-restore")

        guard FileManager.default.createFile(
            atPath: extraLeaf,
            contents: Data("unexpected\n".utf8))
        else {
            throw DisposalProjectionRejection(code: "TEST_EXTRA_LEAF_CREATE")
        }
        try requireSyscall(chmod(extraLeaf, 0o400), operation: "chmod-extra-leaf")
        try requireSyscall(chmod(roots[0], 0o500), operation: "chmod-root-inventory-seal")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: reference(predecessor)),
            outputRoot: roots[3],
            code: "DISPOSAL_READER_ROOT_INVENTORY")
        assertPathAbsent(roots[3])
    }

    func testHeldLeafVnodeReboundAfterAdmissionRejectsBeforeOutputCreation() throws {
        let roots = testRoots(2)
        let backup = "/private/tmp/ergentics-predecessor-held-backup-" +
            UUID().uuidString.lowercased()
        defer {
            restoreReboundLeaf(root: roots[0], backup: backup)
            roots.forEach(removeProjection)
            _ = unlink(backup)
        }
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let leaf = roots[0] + "/" + DisposalProjectionSetV1.sealLeaf
        let bytes = try Data(contentsOf: URL(fileURLWithPath: leaf))
        let hooks = DisposalProjectionBuildTestingHooks(
            afterPredecessorAdmission: {
                try requireSyscall(chmod(roots[0], 0o700), operation: "chmod-root-open")
                try requireSyscall(rename(leaf, backup), operation: "rename-held-leaf")
                guard FileManager.default.createFile(atPath: leaf, contents: bytes) else {
                    throw DisposalProjectionRejection(code: "TEST_REBOUND_CREATE")
                }
                try requireSyscall(chmod(leaf, 0o400), operation: "chmod-new-leaf")
                try requireSyscall(chmod(roots[0], 0o500), operation: "chmod-root-sealed")
            },
            beforeSuccessorPublication: nil)
        do {
            _ = try DisposalProjectionSetBuilder.buildForTesting(
                request: .init(
                    journal: predecessorJournal(frameCount: 2),
                    journalLogicalPath: logicalPath,
                    predecessor: reference(predecessor)),
                outputRootPath: roots[1],
                testingHooks: hooks)
            XCTFail("rebound predecessor leaf was accepted")
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertTrue(
                ["DISPOSAL_READER_LEAF_DRIFT", "DISPOSAL_READER_LEAF_REBOUND"]
                    .contains(rejection.code),
                rejection.code)
        }
        assertPathAbsent(roots[1])
    }

    func testPrepublicationPredecessorFailureCannotLeaveAnAdmittedSuccessor() throws {
        let roots = testRoots(2)
        let moved = roots[0] + "-moved"
        let staging = DisposalSealedArtifactSet.stagingPath(for: roots[1])
        defer {
            if pathExists(moved) && !pathExists(roots[0]) { _ = rename(moved, roots[0]) }
            roots.forEach(removeProjection)
            removeProjection(moved)
            removeProjection(staging)
        }
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let hooks = DisposalProjectionBuildTestingHooks(
            afterPredecessorAdmission: nil,
            beforeSuccessorPublication: {
                try requireSyscall(rename(roots[0], moved), operation: "rename-predecessor-root")
            })
        do {
            _ = try DisposalProjectionSetBuilder.buildForTesting(
                request: .init(
                    journal: predecessorJournal(frameCount: 2),
                    journalLogicalPath: logicalPath,
                    predecessor: reference(predecessor)),
                outputRootPath: roots[1],
                testingHooks: hooks)
            XCTFail("prepublication predecessor loss returned a report")
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertEqual(rejection.code, "DISPOSAL_READER_ROOT_REVALIDATE")
        }
        assertPathAbsent(roots[1])
        XCTAssertTrue(pathExists(staging))
        XCTAssertEqual(try pathMode(staging), 0o500)
        let seal = try Data(contentsOf: URL(
            fileURLWithPath: staging + "/" + DisposalProjectionSetV1.sealLeaf))
        guard case .rejected(let rejection) = DisposalProjectionReader.load(
            rootPath: staging,
            expectedSealSHA256: disposalSHA256(seal))
        else {
            return XCTFail("staging successor was admitted")
        }
        XCTAssertEqual(rejection.code, "DISPOSAL_READER_ROOT_PATH_SHAPE")
    }

    func testPreparedOutputMutationCannotPublishAReaderRejectedFinalRoot() throws {
        let roots = testRoots(2)
        let staging = DisposalSealedArtifactSet.stagingPath(for: roots[1])
        let extraLeaf = staging + "/unexpected-after-prepare"
        defer {
            _ = chmod(staging, 0o700)
            _ = unlink(extraLeaf)
            _ = chmod(staging, 0o500)
            roots.forEach(removeProjection)
            removeProjection(staging)
        }
        let predecessor = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let hooks = DisposalProjectionBuildTestingHooks(
            afterPredecessorAdmission: nil,
            beforeSuccessorPublication: {
                try requireSyscall(chmod(staging, 0o700), operation: "chmod-staging-open")
                guard FileManager.default.createFile(
                    atPath: extraLeaf,
                    contents: Data("unexpected\n".utf8))
                else {
                    throw DisposalProjectionRejection(code: "TEST_STAGING_EXTRA_CREATE")
                }
                try requireSyscall(chmod(extraLeaf, 0o400), operation: "chmod-staging-extra")
                try requireSyscall(chmod(staging, 0o500), operation: "chmod-staging-seal")
            })
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: reference(predecessor)),
            outputRoot: roots[1],
            code: "OUTPUT_INVENTORY",
            testingHooks: hooks)
        assertPathAbsent(roots[1])
        XCTAssertTrue(pathExists(staging))
    }

    func testOutputPathAdmissionMatchesReaderCanonicalShape() {
        let leaf = "ergentics-output-shape-" + UUID().uuidString.lowercased()
        let canonical = "/private/tmp/" + leaf
        let request = DisposalProjectionSetRequest(
            journal: predecessorJournal(frameCount: 1),
            journalLogicalPath: logicalPath)
        for malformed in [
            "/private/tmp//" + leaf,
            "/private/tmp/./" + leaf,
            "/private/tmp/nothing/../" + leaf,
            canonical + "/",
            canonical + "\0suffix",
        ] {
            assertBuildReject(
                request: request,
                outputRoot: malformed,
                code: "OUTPUT_ROOT_PATH_SHAPE")
        }
        assertPathAbsent(canonical)
    }

    func testHeldOutputParentReboundCannotPublishAtAContradictoryPath() throws {
        let suffix = UUID().uuidString.lowercased()
        let parent = "/private/tmp/ergentics-output-parent-" + suffix
        let movedParent = parent + "-moved"
        let output = parent + "/projection"
        let stagingLeaf = URL(
            fileURLWithPath: DisposalSealedArtifactSet.stagingPath(for: output)
        ).lastPathComponent
        let retainedStaging = movedParent + "/" + stagingLeaf
        try requireSyscall(mkdir(parent, 0o700), operation: "mkdir-output-parent")
        defer {
            removeProjection(output)
            removeProjection(retainedStaging)
            _ = rmdir(parent)
            _ = rmdir(movedParent)
        }

        let hooks = DisposalProjectionBuildTestingHooks(
            afterPredecessorAdmission: nil,
            beforeSuccessorPublication: {
                try requireSyscall(
                    Darwin.rename(parent, movedParent),
                    operation: "rename-output-parent")
                try requireSyscall(
                    mkdir(parent, 0o700),
                    operation: "recreate-output-parent")
            })
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRoot: output,
            code: "OUTPUT_PARENT_REBOUND",
            testingHooks: hooks)
        assertPathAbsent(output)
        XCTAssertTrue(pathExists(retainedStaging))
        XCTAssertEqual(try pathMode(retainedStaging), 0o500)
    }

    func testIntermediateParentSymlinkAliasCannotPublishAReaderRejectedRoot() throws {
        let suffix = UUID().uuidString.lowercased()
        let ancestor = "/private/tmp/ergentics-output-ancestor-" + suffix
        let movedAncestor = ancestor + "-moved"
        let parent = ancestor + "/held-parent"
        let movedParent = movedAncestor + "/held-parent"
        let output = parent + "/projection"
        let stagingLeaf = URL(
            fileURLWithPath: DisposalSealedArtifactSet.stagingPath(for: output)
        ).lastPathComponent
        let retainedStaging = movedParent + "/" + stagingLeaf
        try requireSyscall(mkdir(ancestor, 0o700), operation: "mkdir-output-ancestor")
        try requireSyscall(mkdir(parent, 0o700), operation: "mkdir-held-output-parent")
        defer {
            removeProjection(retainedStaging)
            _ = unlink(ancestor)
            _ = rmdir(movedParent)
            _ = rmdir(movedAncestor)
        }

        let hooks = DisposalProjectionBuildTestingHooks(
            afterPredecessorAdmission: nil,
            beforeSuccessorPublication: {
                try requireSyscall(
                    Darwin.rename(ancestor, movedAncestor),
                    operation: "rename-output-ancestor")
                try requireSyscall(
                    symlink(movedAncestor, ancestor),
                    operation: "symlink-output-ancestor")
            })
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 1),
                journalLogicalPath: logicalPath),
            outputRoot: output,
            code: "OUTPUT_PARENT_ALIAS_DRIFT",
            testingHooks: hooks)
        assertPathAbsent(output)
        XCTAssertTrue(pathExists(retainedStaging))
        XCTAssertEqual(try pathMode(retainedStaging), 0o500)
    }

    func testR19UnsealedPrefixesAppendButSealedSourceCannotBecomePredecessor() throws {
        let roots = testRoots(5)
        defer { roots.forEach(removeProjection) }
        let source = try r19Fixture()
        let firstPrefix = sourcePrefix(source, frames: 1)
        let secondPrefix = sourcePrefix(source, frames: 2)
        let first = try DisposalProjectionSetBuilder.build(
            request: .init(journal: firstPrefix, journalLogicalPath: logicalPath),
            outputRootPath: roots[0])
        let second = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: secondPrefix,
                journalLogicalPath: logicalPath,
                predecessor: reference(first)),
            outputRootPath: roots[1])
        let sealed = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: source,
                journalLogicalPath: logicalPath,
                predecessor: reference(second)),
            outputRootPath: roots[2])
        XCTAssertFalse(sealed.terminal)
        XCTAssertTrue(sealed.sourceSealed)
        XCTAssertEqual(sealed.status, "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL")
        let sealedSnapshot = try admitted(root: roots[2], seal: sealed.sealSHA256)
        XCTAssertTrue(sealedSnapshot.metadata.sourceSealed)
        XCTAssertFalse(sealedSnapshot.metadata.terminal)
        XCTAssertEqual(
            sealedSnapshot.metadata.status,
            "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL")
        let firstSnapshot = try admitted(root: roots[0], seal: first.sealSHA256)
        let secondSnapshot = try admitted(root: roots[1], seal: second.sealSHA256)
        assertPublicMachinePrefix(firstSnapshot, successor: secondSnapshot)
        assertPublicMachinePrefix(secondSnapshot, successor: sealedSnapshot)

        assertBuildReject(
            request: .init(
                journal: source,
                journalLogicalPath: logicalPath,
                predecessor: reference(sealed)),
            outputRoot: roots[3],
            code: "PREDECESSOR_NOT_APPENDABLE")
        assertBuildReject(
            request: .init(
                journal: predecessorJournal(frameCount: 2),
                journalLogicalPath: logicalPath,
                predecessor: reference(first)),
            outputRoot: roots[4],
            code: "PREDECESSOR_SOURCE_KIND_JOIN")
        assertPathAbsent(roots[3])
        assertPathAbsent(roots[4])
    }

    func testPublicSurfaceHasNoRawPredecessorIDAndMainRequiresRootSealPair() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let models = try String(
            contentsOf: packageRoot.appendingPathComponent(
                "Sources/DisposalProjectionCore/DisposalProjectionSetModels.swift"),
            encoding: .utf8)
        let main = try String(
            contentsOf: packageRoot.appendingPathComponent(
                "Sources/ErgenticsDisposalProjector/main.swift"),
            encoding: .utf8)
        XCTAssertFalse(models.contains("public let predecessorProjectionID"))
        XCTAssertFalse(models.contains("predecessorProjectionID: String?"))
        XCTAssertTrue(main.contains("ERGENTICS_DISPOSAL_PREDECESSOR_ROOT"))
        XCTAssertTrue(main.contains("ERGENTICS_DISPOSAL_PREDECESSOR_SEAL_SHA256"))
        XCTAssertTrue(main.contains("report.status"))
        XCTAssertTrue(
            main.contains(
                "environment[\"ERGENTICS_DISPOSAL_PREDECESSOR_PROJECTION_ID\"] == nil"))
    }

    private func reference(
        _ report: DisposalProjectionSetReport
    ) -> DisposalProjectionPredecessorReference {
        .init(
            rootPath: report.outputRootPath,
            expectedSealSHA256: report.sealSHA256)
    }

    private func admitted(
        root: String,
        seal: String
    ) throws -> DisposalProjectionSnapshot {
        guard case .admitted(let snapshot) = DisposalProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: seal)
        else {
            throw DisposalProjectionRejection(code: "TEST_PREDECESSOR_READER_REJECT")
        }
        return snapshot
    }

    private func assertPublicMachinePrefix(
        _ predecessor: DisposalProjectionSnapshot,
        successor: DisposalProjectionSnapshot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let maximumOrdinal = predecessor.metadata.frameCount - 1
        let states = successor.machineStates.filter { $0.prefixOrdinal <= maximumOrdinal }
        XCTAssertEqual(predecessor.machineStates, states, file: file, line: line)
        let stateIDs = Set(states.map(\.id))
        let transitions = successor.machineTransitions.filter { stateIDs.contains($0.toStateID) }
        XCTAssertEqual(predecessor.machineTransitions, transitions, file: file, line: line)
        let transitionIDs = Set(transitions.map(\.id))
        let predicates = successor.machinePredicates.filter {
            transitionIDs.contains($0.transitionID)
        }
        XCTAssertEqual(predecessor.machinePredicates, predicates, file: file, line: line)
        let witnesses = successor.machineWitnesses.filter {
            $0.visiblePrefixOrdinal <= maximumOrdinal
        }
        XCTAssertEqual(predecessor.machineWitnesses, witnesses, file: file, line: line)
        let witnessIDs = Set(witnesses.map(\.id))
        let leaves = successor.machineMerkleLeaves.filter { stateIDs.contains($0.stateID) }
        XCTAssertEqual(predecessor.machineMerkleLeaves, leaves, file: file, line: line)
        let allowedNodeIDs = stateIDs.union(transitionIDs).union(witnessIDs)
        let edges = successor.machineEdges.filter {
            allowedNodeIDs.contains($0.fromNodeID) && allowedNodeIDs.contains($0.toNodeID)
        }
        XCTAssertEqual(predecessor.machineEdges, edges, file: file, line: line)
    }

    private func assertBuildReject(
        request: DisposalProjectionSetRequest,
        outputRoot: String,
        code: String,
        testingHooks: DisposalProjectionBuildTestingHooks? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            if let testingHooks {
                _ = try DisposalProjectionSetBuilder.buildForTesting(
                    request: request,
                    outputRootPath: outputRoot,
                    testingHooks: testingHooks)
            } else {
                _ = try DisposalProjectionSetBuilder.build(
                    request: request,
                    outputRootPath: outputRoot)
            }
            XCTFail("expected rejection \(code)", file: file, line: line)
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertEqual(rejection.code, code, file: file, line: line)
        } catch {
            XCTFail("unexpected error \(error)", file: file, line: line)
        }
    }

    private func assertPathAbsent(
        _ path: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var state = stat()
        errno = 0
        XCTAssertNotEqual(lstat(path, &state), 0, file: file, line: line)
        XCTAssertEqual(errno, ENOENT, file: file, line: line)
    }

    private func testRoots(_ count: Int) -> [String] {
        let suffix = UUID().uuidString.lowercased()
        return (0..<count).map {
            "/private/tmp/ergentics-predecessor-\(suffix)-\($0)"
        }
    }

    private func r19Fixture() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(
            forResource: "r19-observations.v1",
            withExtension: "jsonl",
            subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
}

private func predecessorJournal(
    frameCount: Int,
    invocationID: String = String(repeating: "1", count: 64),
    epochLabel: String = "EPOCH_A",
    secondValue: String = "EXACT"
) -> Data {
    precondition((1...3).contains(frameCount))
    let start = predecessorFrame(
        ordinal: 0,
        eventType: "start",
        payload: predecessorObject([
            "arc_label": predecessorString("PREDECESSOR_TEST"),
            "consumption_state": predecessorString("UNCONSUMED"),
            "epoch_label": predecessorString(epochLabel),
            "invocation_id": predecessorString(invocationID),
            "retry_authorized": predecessorBoolean(false),
            "status": predecessorString("ABSTAIN_TEST_PREFIX"),
        ]),
        previous: nil)
    guard frameCount > 1 else { return start }
    let second = predecessorFrame(
        ordinal: 1,
        eventType: "clocks",
        payload: predecessorObject([
            "status": predecessorString("RECORDED"),
            "value": predecessorString(secondValue),
        ]),
        previous: disposalSHA256(start))
    guard frameCount > 2 else { return start + second }
    let terminal = predecessorFrame(
        ordinal: 2,
        eventType: "terminal",
        payload: predecessorObject([
            "capture_state": predecessorString("ABSTAIN"),
            "completion_class": predecessorString("ABSTAIN_INCOMPLETE"),
            "gate_e_outcome": predecessorString("ABSTAIN"),
            "status": predecessorString("ABSTAIN_TEST_TERMINAL"),
        ]),
        previous: disposalSHA256(second))
    return start + second + terminal
}

private func predecessorFrame(
    ordinal: Int,
    eventType: String,
    payload: DisposalJSONValue,
    previous: String?
) -> Data {
    let root = predecessorObject([
        "authoritative": predecessorBoolean(false),
        "authority_vector": predecessorString("00000000"),
        "event_type": predecessorString(eventType),
        "may_feed_controller": predecessorBoolean(false),
        "ordinal": predecessorNumber(String(ordinal)),
        "payload": payload,
        "payload_hash_rule": predecessorString(DisposalEventJournal.payloadHashRule),
        "payload_sha256": predecessorString(disposalSHA256(payload.canonicalData())),
        "previous_frame_sha256": previous.map(predecessorString) ?? .null(disposalZeroSpan),
        "prose_may_supply_fact": predecessorBoolean(false),
        "schema": predecessorString(DisposalEventJournal.frameSchema),
    ])
    var bytes = root.canonicalData()
    bytes.append(0x0a)
    return bytes
}

private func predecessorObject(
    _ members: [String: DisposalJSONValue]
) -> DisposalJSONValue {
    .object(
        members.map { .init(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

private func predecessorString(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

private func predecessorNumber(_ value: String) -> DisposalJSONValue {
    .number(value, disposalZeroSpan)
}

private func predecessorBoolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}

private func sourcePrefix(_ source: Data, frames: Int) -> Data {
    var result = Data()
    for line in source.split(separator: 0x0a, omittingEmptySubsequences: true).prefix(frames) {
        result.append(contentsOf: line)
        result.append(0x0a)
    }
    return result
}

private func requireSyscall(_ result: Int32, operation: String) throws {
    guard result == 0 else {
        throw DisposalProjectionRejection(
            code: "TEST_SYSCALL",
            detail: operation + ":" + String(cString: strerror(errno)))
    }
}

private func pathExists(_ path: String) -> Bool {
    var state = stat()
    return lstat(path, &state) == 0
}

private func pathMode(_ path: String) throws -> Int {
    var state = stat()
    guard lstat(path, &state) == 0 else {
        throw DisposalProjectionRejection(code: "TEST_PATH_MODE")
    }
    return Int(state.st_mode & 0o7777)
}

private func restoreReboundLeaf(root: String, backup: String) {
    guard pathExists(root), pathExists(backup) else { return }
    let leaf = root + "/" + DisposalProjectionSetV1.sealLeaf
    _ = chmod(root, 0o700)
    _ = unlink(leaf)
    _ = rename(backup, leaf)
    _ = chmod(leaf, 0o400)
    _ = chmod(root, 0o500)
}

private func removeProjection(_ root: String) {
    for leaf in [
        DisposalProjectionSetV1.evidenceLeaf,
        DisposalProjectionSetV1.metricsLeaf,
        DisposalProjectionSetV1.graphLeaf,
        DisposalProjectionSetV1.sealLeaf,
    ] {
        let path = root + "/" + leaf
        _ = chmod(path, 0o600)
        _ = unlink(path)
    }
    _ = chmod(root, 0o700)
    _ = rmdir(root)
}

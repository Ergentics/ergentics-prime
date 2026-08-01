import Foundation
import XCTest
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import PrimeNativeNeuralGateTerminalReceiptOwnershipContracts
@testable import PrimeNativeNeuralGateRoleArtifactReferenceContracts

final class PrimeNativeNeuralGateRoleArtifactReferenceContractsTests:
    XCTestCase
{
    typealias Contract =
        PrimeNativeNeuralGateRoleArtifactReferenceContract
    typealias Error =
        PrimeNativeNeuralGateRoleArtifactReferenceContractError

    func testFrozenContractClosesExactTenRoleTwentyPathInventory()
        throws
    {
        let contract = Contract.frozenV1
        try contract.validate()
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_role_artifact_source_reference_contract_v1"
        )
        XCTAssertEqual(contract.exactRoleCount, 10)
        XCTAssertEqual(contract.exactRoleScopedArtifactRuleCount, 20)
        XCTAssertEqual(
            contract.roleArtifactDeclarations.map(\.role),
            PrimeNativeNeuralGateCorrectedProcessRole.allCases
        )
        let rules = contract.roleArtifactDeclarations
            .flatMap(\.artifactRules)
        XCTAssertEqual(rules.count, 20)
        XCTAssertEqual(
            Set(rules.map(\.relativePath)),
            Set(
                PrimeNativeNeuralGateTerminalReceiptOwnershipContract
                    .preReceiptOwnedArtifactPaths()
            )
        )
        let expectedCounts: [
            PrimeNativeNeuralGateCorrectedProcessRole: Int
        ] = [
            .probeSupervisor: 6,
            .verifierSupervisor: 6,
            .probeSwiftPackageDescribeChild: 0,
            .verifierSwiftPackageDescribeChild: 0,
            .probeHistoricalWorker: 0,
            .verifierHistoricalWorker: 0,
            .probeCorrectedRawWorker: 2,
            .verifierCorrectedRawWorker: 2,
            .probeCorrectedEvaluationWorker: 2,
            .verifierCorrectedEvaluationWorker: 2,
        ]
        XCTAssertEqual(
            Dictionary(
                uniqueKeysWithValues:
                    contract.roleArtifactDeclarations.map {
                        ($0.role, $0.artifactRules.count)
                    }
            ),
            expectedCounts
        )
        XCTAssertTrue(contract.typedRoleArtifactRulesFrozen)
        XCTAssertTrue(
            contract.workerSourceReferenceDeclarationsFrozen
        )
        XCTAssertFalse(
            contract.realizedRoleArtifactContentReferencesPresent
        )
        XCTAssertFalse(contract.actualCompiledSourceClosuresPresent)
        XCTAssertFalse(contract.actualSealedExecutablesPresent)
        XCTAssertEqual(
            [
                contract.commonReferenceIdentityMagic,
                contract.branchReferenceIdentityMagic,
                contract.primeSourceSnapshotIdentityMagic,
                contract.swiftPackageDescribeIdentityMagic,
                contract.compiledSourceClosureIdentityMagic,
                contract.sealedWorkerExecutableIdentityMagic,
                contract.workerSourceAggregateIdentityMagic,
                contract.roleArtifactContentIdentityMagic,
            ],
            [
                "PRIMERAC1",
                "PRIMERAB1",
                "PRIMEWSS1",
                "PRIMEWSD1",
                "PRIMEWSC1",
                "PRIMEWSE1",
                "PRIMEWSA1",
                "PRIMERAR1",
            ]
        )
        XCTAssertEqual(
            contract.identitySerializationContractID,
            PrimeNativeNeuralGateInvariantCodec
                .serializationContractID
        )
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.workerMaterialized)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(contract.evaluationPerformed)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertFalse(Contract.self is any Decodable.Type)
        XCTAssertFalse(
            PrimeNativeNeuralGateCommonCaptureScheduleReference
                .self is any Decodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateBranchScheduleReference
                .self is any Decodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateWorkerSourceReference
                .self is any Decodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateRoleArtifactContentReference
                .self is any Decodable.Type
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "c6948fb552c78f16911f4846a5f6971ed6e69486aba5afbc2d40fe4c5f342cf8"
        )
    }

    func testDeclarationInventoryRejectsMissingDuplicateAndMutatedRules()
        throws
    {
        let contract = Contract.frozenV1
        let maximum = contract.maximumRoleArtifactJSONByteCount
        var missingRole = contract.roleArtifactDeclarations
        missingRole.removeLast()
        XCTAssertThrowsError(
            try Contract.validateRoleArtifactDeclarations(
                missingRole,
                maximumByteCount: maximum
            )
        )

        var duplicateRole = contract.roleArtifactDeclarations
        duplicateRole.append(try XCTUnwrap(duplicateRole.first))
        XCTAssertThrowsError(
            try Contract.validateRoleArtifactDeclarations(
                duplicateRole,
                maximumByteCount: maximum
            )
        )

        let firstDeclaration = try XCTUnwrap(
            contract.roleArtifactDeclarations.first(where: {
                !$0.artifactRules.isEmpty
            })
        )
        let firstRule = try XCTUnwrap(
            firstDeclaration.artifactRules.first
        )
        let mutatedPathRule = PrimeNativeNeuralGateRoleArtifactRule(
            schemaID: firstRule.schemaID,
            schemaVersion: firstRule.schemaVersion,
            schemaKind: firstRule.schemaKind,
            branch: firstRule.branch,
            relativePath: firstRule.relativePath + ".shadow",
            ownerProcessRole: firstRule.ownerProcessRole,
            allowedReaderProcessRoles:
                firstRule.allowedReaderProcessRoles,
            maximumByteCount: firstRule.maximumByteCount,
            purpose: firstRule.purpose,
            mode: firstRule.mode
        )
        XCTAssertThrowsError(
            try Contract.validateRoleArtifactDeclarations(
                replacing(
                    firstRule,
                    with: mutatedPathRule,
                    in: contract.roleArtifactDeclarations
                ),
                maximumByteCount: maximum
            )
        )

        let swappedOwnerRule = PrimeNativeNeuralGateRoleArtifactRule(
            schemaID: firstRule.schemaID,
            schemaVersion: firstRule.schemaVersion,
            schemaKind: firstRule.schemaKind,
            branch: firstRule.branch,
            relativePath: firstRule.relativePath,
            ownerProcessRole:
                firstRule.branch == .probe
                    ? .verifierSupervisor
                    : .probeSupervisor,
            allowedReaderProcessRoles:
                firstRule.allowedReaderProcessRoles,
            maximumByteCount: firstRule.maximumByteCount,
            purpose: firstRule.purpose,
            mode: firstRule.mode
        )
        XCTAssertThrowsError(
            try Contract.validateRoleArtifactDeclarations(
                replacing(
                    firstRule,
                    with: swappedOwnerRule,
                    in: contract.roleArtifactDeclarations
                ),
                maximumByteCount: maximum
            )
        )

        let narrowedReadersRule = PrimeNativeNeuralGateRoleArtifactRule(
            schemaID: firstRule.schemaID,
            schemaVersion: firstRule.schemaVersion,
            schemaKind: firstRule.schemaKind,
            branch: firstRule.branch,
            relativePath: firstRule.relativePath,
            ownerProcessRole: firstRule.ownerProcessRole,
            allowedReaderProcessRoles:
                [firstRule.ownerProcessRole],
            maximumByteCount: firstRule.maximumByteCount,
            purpose: firstRule.purpose,
            mode: firstRule.mode
        )
        XCTAssertThrowsError(
            try Contract.validateRoleArtifactDeclarations(
                replacing(
                    firstRule,
                    with: narrowedReadersRule,
                    in: contract.roleArtifactDeclarations
                ),
                maximumByteCount: maximum
            )
        )
    }

    func testSixWorkerSourceDeclarationsRemainPlannedAndAbsent()
        throws
    {
        let declarations = Contract.frozenV1
            .plannedWorkerSourceReferenceDeclarations
        try Contract.validatePlannedWorkerSourceReferenceDeclarations(
            declarations
        )
        XCTAssertEqual(
            declarations.map(\.role),
            [
                .probeHistoricalWorker,
                .verifierHistoricalWorker,
                .probeCorrectedRawWorker,
                .verifierCorrectedRawWorker,
                .probeCorrectedEvaluationWorker,
                .verifierCorrectedEvaluationWorker,
            ]
        )
        XCTAssertTrue(declarations.allSatisfy {
            $0.requiredBuildConfiguration == "release"
                && $0.requiredReferenceKinds
                    == PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                        .allCases
                && $0.actualWorkerSourceReference == nil
                && !$0.sourcePinningObserved
                && !$0.workerMaterialized
                && !$0.executionObserved
                && !$0.sourceBindingV7Issued
        })

        var missing = declarations
        missing.removeLast()
        XCTAssertThrowsError(
            try Contract
                .validatePlannedWorkerSourceReferenceDeclarations(
                    missing
                )
        )

        let first = try XCTUnwrap(declarations.first)
        let fabricated =
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: first.role,
                targetName: first.targetName,
                requiredDirectLocalTargetNames:
                    first.requiredDirectLocalTargetNames,
                requiredReferenceKinds: [
                    .primeSourceSnapshot,
                    .compiledSourceClosure,
                    .sealedWorkerExecutable,
                ]
            )
        var mutated = declarations
        mutated[0] = fabricated
        XCTAssertThrowsError(
            try Contract
                .validatePlannedWorkerSourceReferenceDeclarations(
                    mutated
                )
        )
    }

    func testWorkerRoleTargetAndDirectDependencyOrderIsExact()
        throws
    {
        let declarations = Contract.frozenV1
            .plannedWorkerSourceReferenceDeclarations
        let expected: [
            PrimeNativeNeuralGateCorrectedProcessRole:
                (String, [String])
        ] = [
            .probeHistoricalWorker: (
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                ]
            ),
            .verifierHistoricalWorker: (
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                ]
            ),
            .probeCorrectedRawWorker: (
                "PrimeNativeNeuralGateCorrectedRawWorker",
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateLogitSidecarMechanics",
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                    "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                ]
            ),
            .verifierCorrectedRawWorker: (
                "PrimeNativeNeuralGateCorrectedRawWorker",
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateLogitSidecarMechanics",
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                    "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                ]
            ),
            .probeCorrectedEvaluationWorker: (
                "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                ]
            ),
            .verifierCorrectedEvaluationWorker: (
                "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                ]
            ),
        ]
        for declaration in declarations {
            let value = try XCTUnwrap(expected[declaration.role])
            XCTAssertEqual(declaration.targetName, value.0)
            XCTAssertEqual(
                declaration.requiredDirectLocalTargetNames,
                value.1
            )
        }
    }

    func testTypedWorkerSourceAggregateBindsAllFourExactKinds()
        throws
    {
        let declaration = try XCTUnwrap(
            Contract.frozenV1
                .plannedWorkerSourceReferenceDeclarations.first(where: {
                    $0.role == .probeCorrectedRawWorker
                })
        )
        let common = try makeCommon()
        let sourceIdentity = digest("9")
        let snapshot = try PrimeNativeNeuralGatePrimeSourceSnapshotReference(
            workerRole: declaration.role,
            workerTargetName: declaration.targetName,
            relativePath: "source/prime-source-snapshot.json",
            contentSHA256: digest("1"),
            byteCount: 100,
            sourceIdentitySHA256: sourceIdentity,
            embeddedSourceIdentitySHA256: sourceIdentity,
            commonReference: common
        )
        let packageDescribe = try PrimeNativeNeuralGateSwiftPackageDescribeReference(
            workerRole: declaration.role,
            workerTargetName: declaration.targetName,
            relativePath: "source/swift-package-describe.json",
            contentSHA256: digest("2"),
            byteCount: 101,
            sourceIdentitySHA256: sourceIdentity,
            commonReference: common
        )
        let closure = try PrimeNativeNeuralGateCompiledSourceClosureReference(
            workerRole: declaration.role,
            workerTargetName: declaration.targetName,
            relativePath: "source/compiled-source-closure.json",
            contentSHA256: digest("3"),
            byteCount: 102,
            sourceIdentitySHA256: sourceIdentity,
            embeddedSourceIdentitySHA256: sourceIdentity,
            orderedDirectLocalTargetNames:
                declaration.requiredDirectLocalTargetNames,
            commonReference: common
        )
        let executable = try PrimeNativeNeuralGateSealedWorkerExecutableReference(
            workerRole: declaration.role,
            workerTargetName: declaration.targetName,
            relativePath: "bin/corrected-raw-worker",
            contentSHA256: digest("4"),
            byteCount: 103,
            sourceIdentitySHA256: sourceIdentity,
            embeddedSourceIdentitySHA256: sourceIdentity,
            commonReference: common
        )
        let aggregate = try PrimeNativeNeuralGateWorkerSourceReference(
            declaration: declaration,
            commonReference: common,
            primeSourceSnapshot: snapshot,
            swiftPackageDescribe: packageDescribe,
            compiledSourceClosure: closure,
            sealedWorkerExecutable: executable
        )
        XCTAssertEqual(
            [
                snapshot.referenceIdentitySHA256,
                packageDescribe.referenceIdentitySHA256,
                closure.referenceIdentitySHA256,
                executable.referenceIdentitySHA256,
                aggregate.referenceIdentitySHA256,
            ],
            [
                "e9fce06e639df04a0632f41c1361ab77fd4bfd67b93d3062992343e5d62e6d32",
                "7256a230b0dd3a5de132bdaafc750bd1efd83b675e00e70b4620d970ef91d944",
                "198817b38b20bb3851cb74e465bb2ccf3bed8df1391f4571b6fa95040d782f73",
                "7a649c9b16157735592c31b7c6e4de9ce60774a777350512845b15f20c18ac42",
                "c946c4abac90225305d71fcf3b5cf27c81a4c68c7732ad4e8134cbc2aaac2337",
            ]
        )
        try aggregate.validate(
            declaration: declaration,
            commonReference: common
        )
        XCTAssertEqual(
            [
                snapshot.artifact.referenceKind,
                packageDescribe.artifact.referenceKind,
                closure.artifact.referenceKind,
                executable.artifact.referenceKind,
            ],
            PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                .allCases
        )
        XCTAssertEqual(snapshot.artifact.mode, "0444")
        XCTAssertEqual(snapshot.artifact.purpose, .immutableData)
        XCTAssertEqual(executable.artifact.mode, "0555")
        XCTAssertEqual(executable.artifact.purpose, .executable)
        XCTAssertFalse(aggregate.descriptorObservationsPresent)
        XCTAssertFalse(aggregate.sourcePinningObserved)
        XCTAssertFalse(aggregate.workerMaterialized)
        XCTAssertFalse(aggregate.executionObserved)
        XCTAssertFalse(aggregate.sourceBindingV7Issued)
        XCTAssertEqual(
            try keys(in: JSONEncoder().encode(snapshot)),
            Set([
                "schema_version",
                "reference_kind",
                "artifact",
                "reference_identity_sha256",
                "descriptor_content_verified",
                "source_pinning_observed",
            ])
        )
        XCTAssertEqual(
            try keys(in: JSONEncoder().encode(closure)),
            Set([
                "schema_version",
                "reference_kind",
                "artifact",
                "ordered_direct_local_target_names",
                "reference_identity_sha256",
                "descriptor_content_verified",
                "source_pinning_observed",
            ])
        )
        XCTAssertEqual(
            try keys(in: JSONEncoder().encode(aggregate)),
            Set([
                "schema_version",
                "reference_kind",
                "worker_role",
                "worker_target_name",
                "ordered_direct_local_target_names",
                "common_capture_schedule_reference_identity_sha256",
                "prime_source_snapshot",
                "swift_package_describe",
                "compiled_source_closure",
                "sealed_worker_executable",
                "reference_identity_sha256",
                "descriptor_observations_present",
                "source_pinning_observed",
                "worker_materialized",
                "execution_observed",
                "source_binding_v7_issued",
            ])
        )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGatePrimeSourceSnapshotReference(
                workerRole: declaration.role,
                workerTargetName: declaration.targetName,
                relativePath: "../escaped.json",
                contentSHA256: digest("1"),
                byteCount: 100,
                sourceIdentitySHA256: sourceIdentity,
                embeddedSourceIdentitySHA256: sourceIdentity,
                commonReference: common
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateSealedWorkerExecutableReference(
                workerRole: declaration.role,
                workerTargetName: declaration.targetName,
                relativePath: "bin/worker",
                contentSHA256: digest("4"),
                byteCount: 103,
                sourceIdentitySHA256: sourceIdentity,
                embeddedSourceIdentitySHA256: digest("8"),
                commonReference: common
            )
        )
        let reordered = try PrimeNativeNeuralGateCompiledSourceClosureReference(
            workerRole: declaration.role,
            workerTargetName: declaration.targetName,
            relativePath: "source/compiled-source-closure.json",
            contentSHA256: digest("3"),
            byteCount: 102,
            sourceIdentitySHA256: sourceIdentity,
            embeddedSourceIdentitySHA256: sourceIdentity,
            orderedDirectLocalTargetNames:
                declaration.requiredDirectLocalTargetNames.reversed(),
            commonReference: common
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateWorkerSourceReference(
                declaration: declaration,
                commonReference: common,
                primeSourceSnapshot: snapshot,
                swiftPackageDescribe: packageDescribe,
                compiledSourceClosure: reordered,
                sealedWorkerExecutable: executable
            )
        )
        let collidingDescribe = try
            PrimeNativeNeuralGateSwiftPackageDescribeReference(
                workerRole: declaration.role,
                workerTargetName: declaration.targetName,
                relativePath: executable.artifact.relativePath,
                contentSHA256: digest("2"),
                byteCount: 101,
                sourceIdentitySHA256: sourceIdentity,
                commonReference: common
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateWorkerSourceReference(
                declaration: declaration,
                commonReference: common,
                primeSourceSnapshot: snapshot,
                swiftPackageDescribe: collidingDescribe,
                compiledSourceClosure: closure,
                sealedWorkerExecutable: executable
            )
        )
        let observed =
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: declaration.role,
                targetName: declaration.targetName,
                requiredDirectLocalTargetNames:
                    declaration.requiredDirectLocalTargetNames,
                actualWorkerSourceReference: aggregate,
                sourcePinningObserved: true
            )
        var declarations = Contract.frozenV1
            .plannedWorkerSourceReferenceDeclarations
        declarations[2] = observed
        XCTAssertThrowsError(
            try Contract.validatePlannedWorkerSourceReferenceDeclarations(
                declarations
            )
        )
    }

    func testCommonAndBranchReferencesAreContentBoundButNonauthorizing()
        throws
    {
        let common = try makeCommon()
        try common.validate()
        let probe = try makeBranch(
            .probe,
            common: common
        )
        try probe.validate(commonReference: common)
        XCTAssertEqual(
            common.referenceIdentitySHA256,
            "4063d07965d06f3a0f6230bcd2ed4902f1cc322618b5470e70fd3f656599a6cc"
        )
        XCTAssertEqual(
            probe.referenceIdentitySHA256,
            "307565ec95b3a9a2d7c321f5cb9a1478d61c9d20bf76bdc746dcc27228a1880b"
        )
        XCTAssertFalse(common.retainedCaptureAuthorityEstablished)
        XCTAssertFalse(common.processDeliveryObserved)
        XCTAssertFalse(probe.processDeliveryObserved)
        XCTAssertFalse(probe.workerMaterialized)

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCommonCaptureScheduleReference(
                captureIdentitySHA256: "not-a-digest",
                sourceRootIdentity: rootIdentity(),
                promptSourceBindingSHA256: digest("b"),
                scheduleIdentitySHA256: digest("c")
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateBranchScheduleReference(
                branch: .probe,
                invocationRole: .verifier,
                commonReferenceIdentitySHA256:
                    common.referenceIdentitySHA256,
                rawCandidateIdentitySHA256: digest("d"),
                outerCandidateIdentitySHA256: digest("e"),
                deliveryIdentitySHA256: digest("f")
            )
        )
        let differentCommon = try PrimeNativeNeuralGateCommonCaptureScheduleReference(
            captureIdentitySHA256: digest("9"),
            sourceRootIdentity: rootIdentity(),
            promptSourceBindingSHA256: digest("b"),
            scheduleIdentitySHA256: digest("c")
        )
        XCTAssertThrowsError(
            try probe.validate(commonReference: differentCommon)
        )
    }

    func testContentReferenceBindsPathRoleContentAndCommonSchedule()
        throws
    {
        let rule = try XCTUnwrap(
            Contract.frozenV1.roleArtifactDeclarations
                .first(where: { $0.role == .probeSupervisor })?
                .artifactRules.first
        )
        let common = try makeCommon()
        let branch = try makeBranch(.probe, common: common)
        let reference = try PrimeNativeNeuralGateRoleArtifactContentReference(
            rule: rule,
            contentSHA256: digest("1"),
            byteCount: 512,
            commonReference: common,
            branchReference: branch
        )
        try reference.validate(
            rule: rule,
            commonReference: common,
            branchReference: branch
        )
        XCTAssertEqual(reference.role, rule.ownerProcessRole)
        XCTAssertEqual(reference.relativePath, rule.relativePath)
        XCTAssertEqual(reference.contentSHA256, digest("1"))
        XCTAssertEqual(
            reference.referenceIdentitySHA256,
            "af7c10e68945ea18fe46883bdfd6e28b4da1eedcba6cfb8f8072d9457751392d"
        )
        XCTAssertFalse(reference.descriptorContentVerified)
        XCTAssertFalse(reference.processDeliveryObserved)
        XCTAssertFalse(reference.executionObserved)
        XCTAssertFalse(reference.mechanicsPassAuthorized)
        XCTAssertFalse(reference.terminalReceiptAuthorized)

        let changed = try PrimeNativeNeuralGateRoleArtifactContentReference(
            rule: rule,
            contentSHA256: digest("2"),
            byteCount: 512,
            commonReference: common,
            branchReference: branch
        )
        XCTAssertNotEqual(
            changed.referenceIdentitySHA256,
            reference.referenceIdentitySHA256
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateRoleArtifactContentReference(
                rule: rule,
                contentSHA256: digest("1"),
                byteCount: rule.maximumByteCount + 1,
                commonReference: common,
                branchReference: branch
            )
        )
        let verifier = try makeBranch(
            .verifier,
            common: common
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateRoleArtifactContentReference(
                rule: rule,
                contentSHA256: digest("1"),
                byteCount: 512,
                commonReference: common,
                branchReference: verifier
            )
        )
    }

    private func replacing(
        _ old: PrimeNativeNeuralGateRoleArtifactRule,
        with new: PrimeNativeNeuralGateRoleArtifactRule,
        in declarations:
            [PrimeNativeNeuralGateRoleArtifactDeclaration]
    ) -> [PrimeNativeNeuralGateRoleArtifactDeclaration] {
        declarations.map { declaration in
            guard declaration.artifactRules.contains(old) else {
                return declaration
            }
            return PrimeNativeNeuralGateRoleArtifactDeclaration(
                role: declaration.role,
                artifactRules: declaration.artifactRules.map {
                    $0 == old ? new : $0
                }
            )
        }
    }

    private func makeCommon() throws
        -> PrimeNativeNeuralGateCommonCaptureScheduleReference
    {
        try PrimeNativeNeuralGateCommonCaptureScheduleReference(
            captureIdentitySHA256: digest("a"),
            sourceRootIdentity: rootIdentity(),
            promptSourceBindingSHA256: digest("b"),
            scheduleIdentitySHA256: digest("c")
        )
    }

    private func makeBranch(
        _ branch: PrimeNativeNeuralGateCorrectedProcessBranch,
        common: PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws -> PrimeNativeNeuralGateBranchScheduleReference {
        try PrimeNativeNeuralGateBranchScheduleReference(
            branch: branch,
            invocationRole: branch.targetFreeInvocationRole,
            commonReferenceIdentitySHA256:
                common.referenceIdentitySHA256,
            rawCandidateIdentitySHA256:
                branch == .probe ? digest("d") : digest("4"),
            outerCandidateIdentitySHA256:
                branch == .probe ? digest("e") : digest("5"),
            deliveryIdentitySHA256:
                branch == .probe ? digest("f") : digest("6")
        )
    }

    private func rootIdentity()
        -> PrimeNativeNeuralGateTargetFreeSourceRootIdentity
    {
        PrimeNativeNeuralGateTargetFreeSourceRootIdentity(
            deviceID: 1,
            inode: 2,
            ownerUserID: 501,
            ownerGroupID: 20,
            actualMode: 0o700,
            linkCount: 2,
            modificationSeconds: 10,
            modificationNanoseconds: 20,
            statusChangeSeconds: 30,
            statusChangeNanoseconds: 40
        )
    }

    private func digest(_ character: Character) -> String {
        String(repeating: String(character), count: 64)
    }

    private func keys(in data: Data) throws -> Set<String> {
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        return Set(object.keys)
    }
}

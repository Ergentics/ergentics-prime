#if canImport(Darwin)
import Darwin
import MachO
#else
import Glibc
#endif
import Foundation

public enum PrimeNativeContractMigrationResolver {
    public static let resolverExecutablePath =
        "PrimeNativeContractResolutionProbe.executable"
    public static let resolverSourceSnapshotPath =
        "prime-swift-source-snapshot.v1.json"
    public static let requiredResolverSourcePaths:
        Set<String> = [
            "Sources/PrimeCore/PrimeNativeContractMigration.swift",
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift",
            "Sources/PrimeCore/PrimeNativeContractResolutionArguments.swift",
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
            "Sources/PrimeNativeContractResolutionProbe/PrimeNativeContractResolutionProbeMain.swift",
            "Sources/PrimeNativeContractResolutionVerifier/PrimeNativeContractResolutionVerifierMain.swift",
        ]

    public static func validate(
        _ input: PrimeNativeMigrationResolvedInput
    ) throws {
        let plan = PrimeNativeContractMigrationPlan.frozenV1
        try plan.validate()
        try validateRepository(input.repository, plan: plan)

        let expectedIDs = plan.artifacts.map(\.artifactID)
        guard Set(input.blobsByArtifactID.keys)
                == Set(expectedIDs),
              input.blobsByArtifactID.count
                == expectedIDs.count else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactSetMismatch
        }

        for specification in plan.artifacts {
            guard let blob =
                    input.blobsByArtifactID[
                        specification.artifactID
                    ] else {
                throw PrimeNativeContractMigrationError
                    .resolvedArtifactMissing(
                        specification.artifactID
                    )
            }
            try validate(
                blob,
                against: specification
            )
        }
        try validateCommandObservations(
            input.commandObservations,
            plan: plan
        )
        try validateGitTool(input.gitTool)
        try validateCommandOutputBindings(
            input.commandObservations,
            gitTool: input.gitTool,
            repository: input.repository,
            plan: plan
        )
    }

    public static func publish(
        _ input: PrimeNativeMigrationResolvedInput,
        resolverSourceRoot: URL,
        resolverSourcePreState:
            PrimeNativeMigrationResolverSourceState,
        resolverSourceSnapshot:
            PrimeSwiftSourceSnapshot,
        to root: PrimeArtifactRoot
    ) throws -> (
        receipt: PrimeNativeContractMigrationReceipt,
        receiptBinding: PrimeArtifactBinding
    ) {
        try validate(input)
        guard PrimeNativeContractMigrationPlan
                .isGitOID(
                    resolverSourcePreState.revision
                ),
              PrimeNativeContractMigrationPlan
                .isGitOID(
                    resolverSourcePreState.treeOID
                ),
              PrimeNativeContractMigrationPlan.frozenV1
                .acceptedResolverRemoteURLs.contains(
                    resolverSourcePreState.remoteURL
                ),
              resolverSourcePreState.clean else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "resolver source identity"
                )
        }
        try validateResolverSourceState(
            resolverSourcePreState,
            phase: .preSnapshot
        )
        try PrimeSwiftSourceProvenance.validate(
            resolverSourceSnapshot,
            requiredRelativePaths:
                requiredResolverSourcePaths
        )
        let resolverExecutableData =
            try runningExecutableData()
        let resolverSourcePostState =
            try PrimeNativeGitBlobTransport()
            .sourceState(
                repositoryRoot: resolverSourceRoot,
                phase: .postExecutable
            )
        try validateResolverSourceState(
            resolverSourcePostState,
            phase: .postExecutable
        )
        guard resolverSourcePostState.remoteURL
                == resolverSourcePreState.remoteURL,
              resolverSourcePostState.revision
                == resolverSourcePreState.revision,
              resolverSourcePostState.treeOID
                == resolverSourcePreState.treeOID,
              resolverSourcePostState.clean else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "resolver source changed during capture"
                )
        }
        let resolverSourceCommandObservations =
            resolverSourcePreState
                .commandObservations
            + resolverSourcePostState
                .commandObservations
        try validateResolverSourceCommandObservations(
            resolverSourceCommandObservations,
            remoteURL:
                resolverSourcePostState.remoteURL,
            revision:
                resolverSourcePostState.revision,
            treeOID:
                resolverSourcePostState.treeOID,
            clean:
                resolverSourcePostState.clean
        )
        let mutations = try mutationSweep(for: input)

        try root.requirePrivateRootMode()
        try root.requireEmpty()
        try root.ensurePrivateDirectory(at: "resolved")
        let sourceSnapshot = try root.publishCanonical(
            resolverSourceSnapshot,
            at: resolverSourceSnapshotPath
        )
        let executable = try root.publish(
            resolverExecutableData,
            at: resolverExecutablePath,
            purpose: .executable
        )

        let plan = PrimeNativeContractMigrationPlan.frozenV1
        let artifacts = try plan.artifacts.map {
            specification in
            guard let blob =
                    input.blobsByArtifactID[
                        specification.artifactID
                    ] else {
                throw PrimeNativeContractMigrationError
                    .resolvedArtifactMissing(
                        specification.artifactID
                    )
            }
            let observedSHA256 =
                PrimeSHA256.hexDigest(of: blob.data)
            let binding = try root.publish(
                blob.data,
                at: specification
                    .materializedRelativePath,
                purpose: .immutableData
            )
            return PrimeNativeMigrationMaterializedArtifact(
                artifactID: specification.artifactID,
                donorRelativePath:
                    specification.repositoryRelativePath,
                donorRevision: plan.companionRevision,
                mode: blob.mode,
                objectType: blob.objectType,
                gitBlobOID: blob.gitBlobOID,
                expectedSHA256: specification.sha256,
                observedSHA256: observedSHA256,
                expectedByteCount: specification.byteCount,
                observedByteCount: UInt64(blob.data.count),
                role: specification.role,
                artifact: binding
            )
        }

        let receipt = PrimeNativeContractMigrationReceipt(
            resolverSourceRemoteURL:
                resolverSourcePostState.remoteURL,
            resolverSourceRevision:
                resolverSourcePostState.revision,
            resolverSourceTreeOID:
                resolverSourcePostState.treeOID,
            resolverSourceTreeClean:
                resolverSourcePostState.clean,
            resolverSourceCommandObservations:
                resolverSourceCommandObservations,
            resolverSourceSnapshot: sourceSnapshot,
            resolverExecutable: executable,
            gitTool: input.gitTool,
            repository: input.repository,
            commandObservations:
                input.commandObservations,
            artifacts: artifacts,
            mutationSweep: mutations
        )
        try receipt.validate()
        try receipt.validate(in: root)

        let receiptBinding = try root.publishCanonical(
            receipt,
            at: plan.outputReceiptPath
        )
        let receiptData = try root.readVerified(
            receiptBinding,
            maximumByteCount: 4 * 1024 * 1024
        )
        let roundTrip = try PrimeCanonicalJSON.decode(
            PrimeNativeContractMigrationReceipt.self,
            from: receiptData,
            artifact: plan.outputReceiptPath
        )
        guard roundTrip == receipt else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid("canonical round trip")
        }
        try roundTrip.validate(in: root)
        return (roundTrip, receiptBinding)
    }

    static func mutationSweep(
        for input: PrimeNativeMigrationResolvedInput
    ) throws -> [PrimeNativeContractMigrationMutationRecord] {
        var records:
            [PrimeNativeContractMigrationMutationRecord] = []
        records.reserveCapacity(
            PrimeNativeContractMigrationMutation
                .allCases.count
        )

        for mutation in
            PrimeNativeContractMigrationMutation.allCases
        {
            let detected: Bool
            switch mutation {
            case .identicalTreeWrongRevision:
                let mutatedRepository =
                    PrimeNativeMigrationRepositoryObservation(
                        observedRemoteURL:
                            input.repository
                                .observedRemoteURL,
                        requestedRevision:
                            PrimeNativeContractMigrationPlan
                                .frozenV1
                                .companionRevision,
                        resolvedRevision:
                            "71130d543262d0d7483eff3d264ea60ad3c0ded5",
                        treeOID:
                            PrimeNativeContractMigrationPlan
                                .frozenV1
                                .companionTreeOID,
                        objectFormat:
                            input.repository.objectFormat,
                        rawCommitByteCount:
                            input.repository
                                .rawCommitByteCount,
                        rawCommitSHA256:
                            input.repository
                                .rawCommitSHA256
                    )
                detected = throwsError {
                    try validateRepository(
                        mutatedRepository,
                        plan: .frozenV1
                    )
                }

            case .identicalBlobWrongPath:
                let artifactID =
                    "neuralkit_package_lock"
                guard let source =
                        input.blobsByArtifactID[
                            artifactID
                        ],
                      let specification =
                        PrimeNativeContractMigrationPlan
                        .frozenV1.artifacts.first(
                            where: {
                                $0.artifactID == artifactID
                            }
                        ) else {
                    throw PrimeNativeContractMigrationError
                        .resolvedArtifactMissing(artifactID)
                }
                let wrongPath =
                    PrimeNativeMigrationResolvedGitBlob(
                        artifactID: source.artifactID,
                        repositoryRelativePath:
                            "prime-runtime/Package.resolved",
                        mode: source.mode,
                        objectType: source.objectType,
                        gitBlobOID: source.gitBlobOID,
                        data: source.data
                    )
                detected = throwsError {
                    try validate(
                        wrongPath,
                        against: specification
                    )
                }

            case .missingArtifact:
                var blobs = input.blobsByArtifactID
                blobs.removeValue(
                    forKey:
                        PrimeNativeContractMigrationPlan
                        .frozenV1.artifacts[0].artifactID
                )
                let mutated =
                    PrimeNativeMigrationResolvedInput(
                        repository: input.repository,
                        gitTool: input.gitTool,
                        commandObservations:
                            input.commandObservations,
                        blobsByArtifactID: blobs
                    )
                detected = throwsError {
                    try validate(mutated)
                }

            case .changedBlobBytes:
                let specification =
                    PrimeNativeContractMigrationPlan
                        .frozenV1.artifacts[0]
                guard let source =
                        input.blobsByArtifactID[
                            specification.artifactID
                        ] else {
                    throw PrimeNativeContractMigrationError
                        .resolvedArtifactMissing(
                            specification.artifactID
                        )
                }
                var changed = source.data
                guard !changed.isEmpty else {
                    throw PrimeNativeContractMigrationError
                        .resolvedArtifactByteCountMismatch(
                            artifactID:
                                specification.artifactID,
                            expected:
                                specification.byteCount,
                            actual: 0
                        )
                }
                changed[changed.startIndex] ^= 0x01
                let mutated =
                    PrimeNativeMigrationResolvedGitBlob(
                        artifactID: source.artifactID,
                        repositoryRelativePath:
                            source.repositoryRelativePath,
                        mode: source.mode,
                        objectType: source.objectType,
                        gitBlobOID: source.gitBlobOID,
                        data: changed
                    )
                detected = throwsError {
                    try validate(
                        mutated,
                        against: specification
                    )
                }

            case .authorityExpansion:
                var object = try JSONSerialization
                    .jsonObject(
                        with:
                            PrimeCanonicalJSON.encode(
                                PrimeNativeContractMigrationPlan
                                    .frozenV1
                            )
                    ) as? [String: Any]
                object?["compatibilityReplayComplete"] = true
                guard let object,
                      JSONSerialization.isValidJSONObject(
                          object
                      ) else {
                    throw PrimeNativeContractMigrationError
                        .mutationUndetected(
                            mutation.rawValue
                        )
                }
                let data = try JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
                let mutated = try JSONDecoder().decode(
                    PrimeNativeContractMigrationPlan.self,
                    from: data
                )
                detected = throwsError {
                    try mutated.validate()
                }
            }
            guard detected else {
                throw PrimeNativeContractMigrationError
                    .mutationUndetected(mutation.rawValue)
            }
            records.append(
                PrimeNativeContractMigrationMutationRecord(
                    mutation: mutation,
                    detectorID: mutation.detectorID,
                    detected: true,
                    restored: true,
                    independentScientificOracleClaimed:
                        false
                )
            )
        }
        return records
    }

    static func validateRepository(
        _ observation:
            PrimeNativeMigrationRepositoryObservation,
        plan: PrimeNativeContractMigrationPlan
    ) throws {
        guard plan.acceptedRemoteURLs.contains(
            observation.observedRemoteURL
        ) else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }
        guard observation.requestedRevision
                == plan.companionRevision,
              observation.resolvedRevision
                == plan.companionRevision else {
            throw PrimeNativeContractMigrationError
                .repositoryRevisionMismatch(
                    expected: plan.companionRevision,
                    observed:
                        observation.resolvedRevision
                )
        }
        guard observation.treeOID
                == plan.companionTreeOID else {
            throw PrimeNativeContractMigrationError
                .repositoryTreeMismatch(
                    expected: plan.companionTreeOID,
                    observed: observation.treeOID
                )
        }
        guard observation.objectFormat
                == plan.companionObjectFormat,
              observation.rawCommitByteCount
                == plan.companionRawCommitByteCount,
              observation.rawCommitSHA256
                == plan.companionRawCommitSHA256 else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }
    }

    static func validate(
        _ blob: PrimeNativeMigrationResolvedGitBlob,
        against specification:
            PrimeNativeMigrationArtifactSpecification
    ) throws {
        guard blob.artifactID
                == specification.artifactID,
              blob.repositoryRelativePath
                == specification.repositoryRelativePath else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactPathMismatch(
                    specification.artifactID
                )
        }
        guard blob.mode == "100644",
              blob.objectType == "blob",
              blob.gitBlobOID
                == specification.gitBlobOID else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactObjectMismatch(
                    specification.artifactID
                )
        }
        let byteCount = UInt64(blob.data.count)
        guard byteCount == specification.byteCount else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactByteCountMismatch(
                    artifactID:
                        specification.artifactID,
                    expected: specification.byteCount,
                    actual: byteCount
                )
        }
        let sha256 =
            PrimeSHA256.hexDigest(of: blob.data)
        guard sha256 == specification.sha256 else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactHashMismatch(
                    artifactID:
                        specification.artifactID,
                    expected: specification.sha256,
                    actual: sha256
                )
        }
    }

    static func validateGitTool(
        _ binding: PrimeNativeMigrationGitToolBinding
    ) throws {
        guard binding.absolutePath == "/usr/bin/git",
              PrimeNativeContractMigrationPlan
                .isSHA256(binding.sha256),
              binding.byteCount > 0,
              binding.deviceID > 0,
              binding.inode > 0,
              binding.version.hasPrefix("git version "),
              PrimeNativeContractMigrationPlan
                .isSHA256(
                    binding.versionOutputSHA256
                ),
              binding.environmentPolicyID
                == "prime_git_read_only_empty_environment_v1"
        else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid("git tool binding")
        }
    }

    static func validateCommandObservations(
        _ observations:
            [PrimeNativeMigrationGitCommandObservation],
        plan: PrimeNativeContractMigrationPlan
    ) throws {
        let expected = expectedCommandObservations(
            plan: plan
        )
        guard observations.count == expected.count,
              zip(observations, expected).allSatisfy({
                  observation, expectation in
                  observation.operation
                        == expectation.operation
                      && observation.argv
                        == expectation.argv
                      && observation.processIdentifier > 0
                      && observation.terminationStatus == 0
                      && observation.terminationReason == "exit"
                      && PrimeNativeContractMigrationPlan
                        .isSHA256(
                            observation.stdoutSHA256
                        )
                      && PrimeNativeContractMigrationPlan
                        .isSHA256(
                            observation.stderrSHA256
                        )
                      && !observation.outputOverflowed
              }) else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "git command observations"
                )
        }
    }

    static func expectedCommandObservations(
        plan: PrimeNativeContractMigrationPlan
    ) -> [(
        operation: String,
        argv: [String]
    )] {
        let prefix = [
            "--no-replace-objects",
            "-c",
            "core.fsmonitor=false",
            "-C",
            "<repository-root>",
        ]
        var expected: [(
            operation: String,
            argv: [String]
        )] = [
            ("git_version", prefix + ["--version"]),
            (
                "remote_identity",
                prefix + [
                    "remote",
                    "get-url",
                    "origin",
                ]
            ),
            (
                "object_format",
                prefix + [
                    "rev-parse",
                    "--show-object-format",
                ]
            ),
            (
                "resolved_revision",
                prefix + [
                    "rev-parse",
                    "\(plan.companionRevision)^{commit}",
                ]
            ),
            (
                "resolved_tree",
                prefix + [
                    "rev-parse",
                    "\(plan.companionRevision)^{tree}",
                ]
            ),
            (
                "raw_commit",
                prefix + [
                    "cat-file",
                    "-p",
                    plan.companionRevision,
                ]
            ),
            (
                "inventory_tree",
                prefix
                    + [
                        "ls-tree",
                        "-z",
                        "--full-tree",
                        plan.companionRevision,
                        "--",
                    ]
                    + plan.artifacts.map(
                        \.repositoryRelativePath
                    )
            ),
        ]
        expected.append(
            contentsOf: plan.artifacts.map {
                specification in
                (
                    "blob:\(specification.artifactID)",
                    prefix + [
                        "cat-file",
                        "blob",
                        specification.gitBlobOID,
                    ]
                )
            }
        )
        expected.append(
            contentsOf: [
                (
                    "post_resolved_revision",
                    prefix + [
                        "rev-parse",
                        "\(plan.companionRevision)^{commit}",
                    ]
                ),
                (
                    "post_resolved_tree",
                    prefix + [
                        "rev-parse",
                        "\(plan.companionRevision)^{tree}",
                    ]
                ),
            ]
        )
        return expected
    }

    static func validateCommandOutputBindings(
        _ observations:
            [PrimeNativeMigrationGitCommandObservation],
        gitTool: PrimeNativeMigrationGitToolBinding,
        repository:
            PrimeNativeMigrationRepositoryObservation,
        plan: PrimeNativeContractMigrationPlan
    ) throws {
        guard observations.count
                == expectedCommandObservations(
                    plan: plan
                ).count else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "git command output bindings"
                )
        }
        let byOperation = Dictionary(
            uniqueKeysWithValues: observations.map {
                ($0.operation, $0)
            }
        )
        let emptyHash = PrimeSHA256.hexDigest(
            of: Data()
        )
        guard byOperation.count == observations.count,
              observations.allSatisfy({
                  $0.stderrByteCount == 0
                      && $0.stderrSHA256 == emptyHash
              }),
              output(
                  byOperation["git_version"],
                  equalsLine: gitTool.version
              ),
              byOperation["git_version"]?
                .stdoutSHA256
                == gitTool.versionOutputSHA256,
              output(
                  byOperation["remote_identity"],
                  equalsLine:
                    repository.observedRemoteURL
              ),
              output(
                  byOperation["object_format"],
                  equalsLine:
                    repository.objectFormat
              ),
              output(
                  byOperation["resolved_revision"],
                  equalsLine:
                    repository.resolvedRevision
              ),
              output(
                  byOperation["resolved_tree"],
                  equalsLine: repository.treeOID
              ),
              output(
                  byOperation["raw_commit"],
                  byteCount:
                    repository.rawCommitByteCount,
                  sha256:
                    repository.rawCommitSHA256
              ),
              output(
                  byOperation["inventory_tree"],
                  equals:
                    expectedInventoryTreeOutput(
                        plan: plan
                    )
              ),
              output(
                  byOperation[
                      "post_resolved_revision"
                  ],
                  equalsLine:
                    repository.resolvedRevision
              ),
              output(
                  byOperation["post_resolved_tree"],
                  equalsLine: repository.treeOID
              ),
              plan.artifacts.allSatisfy({
                  specification in
                  output(
                      byOperation[
                          "blob:\(specification.artifactID)"
                      ],
                      byteCount:
                        specification.byteCount,
                      sha256: specification.sha256
                  )
              }) else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "git command output bindings"
                )
        }
    }

    static func validateResolverSourceCommandObservations(
        _ observations:
            [PrimeNativeMigrationGitCommandObservation],
        remoteURL: String,
        revision: String,
        treeOID: String,
        clean: Bool
    ) throws {
        let expected =
            expectedResolverSourceCommandObservations()
        let emptyHash = PrimeSHA256.hexDigest(
            of: Data()
        )
        guard observations.count == expected.count,
              zip(observations, expected).allSatisfy({
                  observation, expectation in
                  observation.operation
                        == expectation.operation
                      && observation.argv
                        == expectation.argv
                      && observation.processIdentifier > 0
                      && observation.terminationStatus == 0
                      && observation.terminationReason == "exit"
                      && !observation.outputOverflowed
                      && observation.stderrByteCount == 0
                      && observation.stderrSHA256
                        == emptyHash
              }),
              output(
                  observations[0],
                  equalsLine: remoteURL
              ),
              output(
                  observations[1],
                  equalsLine: revision
              ),
              output(
                  observations[2],
                  equalsLine: treeOID
              ),
              clean,
              output(
                  observations[3],
                  byteCount: 0,
                  sha256: emptyHash
              ),
              output(
                  observations[4],
                  equalsLine: remoteURL
              ),
              output(
                  observations[5],
                  equalsLine: revision
              ),
              output(
                  observations[6],
                  equalsLine: treeOID
              ),
              output(
                  observations[7],
                  byteCount: 0,
                  sha256: emptyHash
              ) else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "resolver source command observations"
                )
        }
    }

    static func expectedResolverSourceCommandObservations()
        -> [(
            operation: String,
            argv: [String]
        )]
    {
        let prefix = [
            "--no-replace-objects",
            "-c",
            "core.fsmonitor=false",
            "-C",
            "<repository-root>",
        ]
        let expected = [
            PrimeNativeMigrationResolverSourcePhase
                .preSnapshot,
            .postExecutable,
        ].flatMap { phase -> [(
            operation: String,
            argv: [String]
        )] in
            [
                (
                    "\(phase.rawValue)_remote",
                    prefix + [
                        "remote",
                        "get-url",
                        "origin",
                    ]
                ),
                (
                    "\(phase.rawValue)_revision",
                    prefix + [
                        "rev-parse",
                        "HEAD^{commit}",
                    ]
                ),
                (
                    "\(phase.rawValue)_tree",
                    prefix + [
                        "rev-parse",
                        "HEAD^{tree}",
                    ]
                ),
                (
                    "\(phase.rawValue)_status",
                    prefix + [
                        "status",
                        "--porcelain=v1",
                        "--untracked-files=all",
                    ]
                ),
            ]
        }
        return expected
    }

    private static func validateResolverSourceState(
        _ state: PrimeNativeMigrationResolverSourceState,
        phase: PrimeNativeMigrationResolverSourcePhase
    ) throws {
        let expected =
            expectedResolverSourceCommandObservations()
            .filter {
                $0.operation.hasPrefix(
                    phase.rawValue + "_"
                )
            }
        let emptyHash = PrimeSHA256.hexDigest(
            of: Data()
        )
        guard state.commandObservations.count
                == expected.count,
              zip(
                  state.commandObservations,
                  expected
              ).allSatisfy({
                  observation, expectation in
                  observation.operation
                        == expectation.operation
                      && observation.argv
                        == expectation.argv
                      && observation.processIdentifier > 0
                      && observation.terminationStatus == 0
                      && observation.terminationReason
                        == "exit"
                      && !observation.outputOverflowed
                      && observation.stderrByteCount == 0
                      && observation.stderrSHA256
                        == emptyHash
              }),
              output(
                  state.commandObservations[0],
                  equalsLine: state.remoteURL
              ),
              output(
                  state.commandObservations[1],
                  equalsLine: state.revision
              ),
              output(
                  state.commandObservations[2],
                  equalsLine: state.treeOID
              ),
              state.clean,
              output(
                  state.commandObservations[3],
                  byteCount: 0,
                  sha256: emptyHash
              ) else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "resolver source \(phase.rawValue)"
                )
        }
    }

    private static func output(
        _ observation:
            PrimeNativeMigrationGitCommandObservation?,
        equalsLine value: String
    ) -> Bool {
        let data = Data((value + "\n").utf8)
        return output(
            observation,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data)
        )
    }

    private static func output(
        _ observation:
            PrimeNativeMigrationGitCommandObservation?,
        equals data: Data
    ) -> Bool {
        output(
            observation,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data)
        )
    }

    private static func output(
        _ observation:
            PrimeNativeMigrationGitCommandObservation?,
        byteCount: UInt64,
        sha256: String
    ) -> Bool {
        observation.map {
            $0.stdoutByteCount == byteCount
                && $0.stdoutSHA256 == sha256
        } == true
    }

    static func expectedInventoryTreeOutput(
        plan: PrimeNativeContractMigrationPlan
    ) -> Data {
        var output = Data()
        for specification in plan.artifacts.sorted(
            by: {
                $0.repositoryRelativePath
                    < $1.repositoryRelativePath
            }
        ) {
            output.append(
                Data(
                    (
                        "100644 blob "
                            + specification.gitBlobOID
                            + "\t"
                            + specification
                                .repositoryRelativePath
                    ).utf8
                )
            )
            output.append(0)
        }
        return output
    }

    private static func runningExecutableData()
        throws -> Data
    {
        #if os(macOS)
        var requiredSize: UInt32 = 0
        _ = _NSGetExecutablePath(nil, &requiredSize)
        guard requiredSize > 1 else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable path"
                )
        }
        var pathBuffer = [CChar](
            repeating: 0,
            count: Int(requiredSize)
        )
        guard _NSGetExecutablePath(
            &pathBuffer,
            &requiredSize
        ) == 0 else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable path"
                )
        }
        let url = URL(
            fileURLWithPath:
                String(cString: pathBuffer)
        ).resolvingSymlinksInPath()
            .standardizedFileURL
        let loaded = try
            PrimeNative3BLoadedExecutableVnode
            .observeCurrentProcess()
        let maximumBytes: off_t =
            256 * 1024 * 1024
        var pathMetadata = stat()
        guard lstat(url.path, &pathMetadata) == 0,
              pathMetadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              pathMetadata.st_uid == geteuid(),
              pathMetadata.st_mode & mode_t(0o022)
                == 0,
              pathMetadata.st_nlink == 1,
              pathMetadata.st_size > 0,
              pathMetadata.st_size <= maximumBytes else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable metadata"
                )
        }
        let descriptor = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable open"
                )
        }
        defer {
            _ = close(descriptor)
        }
        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_mode & mode_t(0o022) == 0,
              before.st_nlink == 1,
              before.st_size > 0,
              before.st_size <= maximumBytes,
              before.st_dev == pathMetadata.st_dev,
              before.st_ino == pathMetadata.st_ino,
              before.st_size == pathMetadata.st_size else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable identity"
                )
        }
        try loaded.requireMatches(
            deviceID:
                UInt64(
                    bitPattern: Int64(before.st_dev)
                ),
            inode: UInt64(before.st_ino)
        )

        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count = buffer.withUnsafeMutableBytes {
                read(
                    descriptor,
                    $0.baseAddress,
                    $0.count
                )
            }
            if count < 0, errno == EINTR {
                continue
            }
            guard count >= 0 else {
                throw PrimeNativeContractMigrationError
                    .receiptInvalid(
                        "running resolver executable read"
                    )
            }
            if count == 0 {
                break
            }
            data.append(
                contentsOf: buffer[0 ..< count]
            )
            guard data.count <= Int(maximumBytes)
            else {
                throw PrimeNativeContractMigrationError
                    .receiptInvalid(
                        "running resolver executable size"
                    )
            }
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_mtimespec.tv_sec
                == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec
                == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec
                == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec
                == after.st_ctimespec.tv_nsec,
              data.count == Int(after.st_size) else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid(
                    "running resolver executable changed"
                )
        }
        return data
        #else
        throw PrimeNativeContractMigrationError
            .receiptInvalid(
                "running resolver executable platform"
            )
        #endif
    }

    private static func throwsError(
        _ operation: () throws -> Void
    ) -> Bool {
        do {
            try operation()
            return false
        } catch {
            return true
        }
    }
}

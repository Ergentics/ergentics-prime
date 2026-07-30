import Foundation

public enum PrimeNativeContractMigrationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case invalidRepositoryRoot
    case repositoryIdentityMismatch
    case repositoryRevisionMismatch(
        expected: String,
        observed: String
    )
    case repositoryTreeMismatch(
        expected: String,
        observed: String
    )
    case gitProcessFailed(
        operation: String,
        status: Int32,
        stderrSHA256: String
    )
    case gitProcessTimedOut(String)
    case gitOutputTooLarge(String)
    case malformedGitOutput(String)
    case resolvedArtifactSetMismatch
    case resolvedArtifactMissing(String)
    case resolvedArtifactPathMismatch(String)
    case resolvedArtifactObjectMismatch(String)
    case resolvedArtifactHashMismatch(
        artifactID: String,
        expected: String,
        actual: String
    )
    case resolvedArtifactByteCountMismatch(
        artifactID: String,
        expected: UInt64,
        actual: UInt64
    )
    case mutationUndetected(String)
    case receiptInvalid(String)
}

extension PrimeNativeContractMigrationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .contractDrift:
            "native contract resolver plan drifted"
        case .invalidRepositoryRoot:
            "companion repository root is not a safe read-only directory"
        case .repositoryIdentityMismatch:
            "companion repository remote identity mismatch"
        case let .repositoryRevisionMismatch(expected, observed):
            "companion revision mismatch: expected \(expected), got \(observed)"
        case let .repositoryTreeMismatch(expected, observed):
            "companion tree mismatch: expected \(expected), got \(observed)"
        case let .gitProcessFailed(
            operation,
            status,
            stderrSHA256
        ):
            "git transport failed during \(operation); status=\(status) stderr_sha256=\(stderrSHA256)"
        case let .gitProcessTimedOut(operation):
            "git transport timed out during \(operation)"
        case let .gitOutputTooLarge(operation):
            "git transport output exceeded its bound during \(operation)"
        case let .malformedGitOutput(operation):
            "git transport emitted malformed output during \(operation)"
        case .resolvedArtifactSetMismatch:
            "resolved artifact set differs from the frozen companion inventory"
        case let .resolvedArtifactMissing(artifactID):
            "resolved companion artifact is missing: \(artifactID)"
        case let .resolvedArtifactPathMismatch(artifactID):
            "resolved companion artifact path mismatch: \(artifactID)"
        case let .resolvedArtifactObjectMismatch(artifactID):
            "resolved companion Git object mismatch: \(artifactID)"
        case let .resolvedArtifactHashMismatch(
            artifactID,
            expected,
            actual
        ):
            "resolved artifact hash mismatch for \(artifactID): expected \(expected), got \(actual)"
        case let .resolvedArtifactByteCountMismatch(
            artifactID,
            expected,
            actual
        ):
            "resolved artifact byte count mismatch for \(artifactID): expected \(expected), got \(actual)"
        case let .mutationUndetected(mutation):
            "native contract resolver mutation was not detected: \(mutation)"
        case let .receiptInvalid(detail):
            "native contract resolver receipt is invalid: \(detail)"
        }
    }
}

public enum PrimeNativeMigrationArtifactRole:
    String,
    Codable,
    Equatable,
    Sendable
{
    case tokenizerManifest = "tokenizer_manifest"
    case corpusManifest = "corpus_manifest"
    case historicalEvidence = "historical_evidence"
    case evaluationContractEvidence =
        "evaluation_contract_evidence"
    case dependencyLock = "dependency_lock"
}

public struct PrimeNativeMigrationArtifactSpecification:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let repositoryRelativePath: String
    public let gitBlobOID: String
    public let sha256: String
    public let byteCount: UInt64
    public let role: PrimeNativeMigrationArtifactRole
    public let materializedRelativePath: String
}

/// Post-Phase-2 admission for the first narrow Phase-3 transition.
///
/// This plan resolves only the eight companion blobs already frozen in
/// `PrimeNativeArcContinuityPlan.frozenV1`. Git is an observed raw-blob
/// transport. Swift owns revision/path/mode/type/OID admission, SHA-256 and
/// byte-count verification, immutable publication, mutations, and the result.
/// No donor source is imported or executed by this slice.
public struct PrimeNativeContractMigrationPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let scope: String
    public let continuityArcID: String
    public let resolverRepository: String
    public let acceptedResolverRemoteURLs: [String]
    public let companionRepository: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let companionObjectFormat: String
    public let companionRawCommitByteCount: UInt64
    public let companionRawCommitSHA256: String
    public let acceptedRemoteURLs: [String]
    public let artifacts:
        [PrimeNativeMigrationArtifactSpecification]
    public let expectedArtifactCount: Int
    public let expectedTotalByteCount: UInt64
    public let blobTransport: String
    public let scientificAuthorityLanguage: String
    public let phaseTwoCanonicalReceiptSHA256: String
    public let phaseTwoCanonicalReceiptOffDeviceDurable: Bool
    public let phaseTwoCompleteDescriptorRootOffDeviceDurable: Bool
    public let companionReadOnly: Bool
    public let companionRuntimeDependencyAuthorized: Bool
    public let compatibilityReplayComplete: Bool
    public let adapterImplementationAuthorized: Bool
    public let archiveExpansionAuthorized: Bool
    public let companionExecutionAuthorized: Bool
    public let neuralKitExecutionAuthorized: Bool
    public let modelExecutionAuthorized: Bool
    public let functionalTrainingAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let pythonExecutionAuthorized: Bool
    public let shellExecutionAuthorized: Bool
    public let historicalShellCaptureImportedAsAuthority: Bool
    public let outputReceiptPath: String
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        planID:
            "ergentics_prime_frozen_companion_blob_resolver_v1",
        scope: "frozen_companion_blob_resolution_only",
        continuityArcID:
            "ergentics_prime_native_neuralkit_continuity_v1",
        resolverRepository:
            "Ergentics/ergentics-prime",
        acceptedResolverRemoteURLs: [
            "https://github.com/Ergentics/ergentics-prime.git",
            "git@github.com:Ergentics/ergentics-prime.git",
        ],
        companionRepository:
            "Ergentics/pmhnp-companion-ergentics",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionTreeOID:
            "9009daa4f8a07fbd5897e00b9571cef44ec292db",
        companionObjectFormat: "sha1",
        companionRawCommitByteCount: 1_240,
        companionRawCommitSHA256:
            "c1087083018d8b964e67e9f1d0d93d689805459457cd58c8f0d46d54c81e0abe",
        acceptedRemoteURLs: [
            "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
            "git@github.com:Ergentics/pmhnp-companion-ergentics.git",
        ],
        artifacts: Self.frozenArtifacts,
        expectedArtifactCount: 8,
        expectedTotalByteCount: 11_969_097,
        blobTransport:
            "swift_process_direct_exec_usr_bin_git_read_only_plumbing_no_shell",
        scientificAuthorityLanguage: "swift",
        phaseTwoCanonicalReceiptSHA256:
            "2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e",
        phaseTwoCanonicalReceiptOffDeviceDurable: true,
        phaseTwoCompleteDescriptorRootOffDeviceDurable: false,
        companionReadOnly: true,
        companionRuntimeDependencyAuthorized: false,
        compatibilityReplayComplete: false,
        adapterImplementationAuthorized: false,
        archiveExpansionAuthorized: false,
        companionExecutionAuthorized: false,
        neuralKitExecutionAuthorized: false,
        modelExecutionAuthorized: false,
        functionalTrainingAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        pythonExecutionAuthorized: false,
        shellExecutionAuthorized: false,
        historicalShellCaptureImportedAsAuthority: false,
        outputReceiptPath:
            "prime-native-contract-resolution-receipt.v1.json",
        authorityStatement:
            "The canonical exact-3B continuation receipt is repository- and off-device-durable and supports structural replay. The complete descriptor-backed checkpoint/runtime root remains local-only. This slice resolves only eight frozen companion Git blobs by exact commit, tree, path, mode, type, object ID, byte count, and SHA-256 under Swift authority. It does not perform compatibility replay, implement an adapter, expand an archive, execute donor code or NeuralKit, admit a checkpoint or evaluation shard, train a model, calibrate a profile, quantize, or authorize product use."
    )

    private static let frozenArtifacts:
        [PrimeNativeMigrationArtifactSpecification] =
    [
        specification(
            "native_byte_tokenizer_manifest",
            "content-staging/prime-native-byte-tokenizer-manifest.v1.json",
            "c2661016dd5a3af21fd6a998f286184ebdd7a196",
            "5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302",
            4_790,
            .tokenizerManifest,
            "resolved/native-byte-tokenizer-manifest.v1.json"
        ),
        specification(
            "native_compositional_corpus_manifest",
            "content-staging/prime-native-text-corpus-manifest.v1.json",
            "a01344ad4105d755cfd97324092b15a1b31dc542",
            "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031",
            44_803,
            .corpusManifest,
            "resolved/native-text-corpus-manifest.v1.json"
        ),
        specification(
            "native_10m_metal_mechanics_report",
            "content-staging/prime-native-metal-language-canary-report.latest.json",
            "e04a264634d5f785e73a4c64b773fd5a4329f896",
            "686bc619ca2019e0960a887b35a8e7dc853172b0d24d27cfbba01e5624c7360c",
            40_833,
            .historicalEvidence,
            "resolved/native-10m-metal-mechanics-report.json"
        ),
        specification(
            "native_schema4_profile_screen_archive",
            "content-staging/prime-native-language-schema4-profile-screen.v1.tar.xz",
            "4b3027164c82af0db1feab8db9da95d3f9e8f9bd",
            "0830920b1e1d57e2fa20731d1caae89899802fec286bbca2e6ee58cbfb5cc903",
            11_830_112,
            .historicalEvidence,
            "resolved/native-schema4-profile-screen.tar.xz"
        ),
        specification(
            "native_schema6_profile_screen_audit",
            "content-staging/prime-native-language-schema6-profile-screen-audit.v1.json",
            "577a7ccbdddbc9c0d249b5fa1ec355c0319d0193",
            "4d7e696344770f57779cc72e1c6f58cb5ea6ce1b3ef0f86f1b571a3f10e84612",
            38_760,
            .historicalEvidence,
            "resolved/native-schema6-profile-screen-audit.json"
        ),
        specification(
            "native_schema6_truth_projection",
            "content-staging/prime-native-language-schema6-profile-screen-truth-projection.v1.json",
            "e48445e10e8a39e96a21dcc84bd1d7d92ddfa33c",
            "7d1c190659cec310e52e5823b1b752cba31f5a64a43cb25dfd1469d41155378a",
            2_090,
            .historicalEvidence,
            "resolved/native-schema6-truth-projection.json"
        ),
        specification(
            "neuralkit_native_language_verify_abstain_receipt",
            "content-staging/prime-native-language-schema4-verify-abstain-receipt.v1.json",
            "afe0fde09285c1ad928d2e8f77dfd622b32e6b20",
            "91c6fd5f26492357cad938dcab1926356bc33914cc281c5ccd2297f1759b0b0a",
            5_760,
            .evaluationContractEvidence,
            "resolved/neuralkit-native-language-verify-abstain-receipt.json"
        ),
        specification(
            "neuralkit_package_lock",
            "neural-kit/Package.resolved",
            "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
            1_949,
            .dependencyLock,
            "resolved/neuralkit-package.resolved"
        ),
    ]

    private static func specification(
        _ artifactID: String,
        _ repositoryRelativePath: String,
        _ gitBlobOID: String,
        _ sha256: String,
        _ byteCount: UInt64,
        _ role: PrimeNativeMigrationArtifactRole,
        _ materializedRelativePath: String
    ) -> PrimeNativeMigrationArtifactSpecification {
        PrimeNativeMigrationArtifactSpecification(
            artifactID: artifactID,
            repositoryRelativePath: repositoryRelativePath,
            gitBlobOID: gitBlobOID,
            sha256: sha256,
            byteCount: byteCount,
            role: role,
            materializedRelativePath: materializedRelativePath
        )
    }

    public func validate() throws {
        let continuity = PrimeNativeArcContinuityPlan.frozenV1
        let continuityCompanion = continuity.artifacts.filter {
            $0.authorityOwner
                == "Ergentics/pmhnp-companion-ergentics"
                && $0.locatorScope
                    == .repositoryRelativeAtPinnedRevision
        }
        let artifactIDs = artifacts.map(\.artifactID)
        let donorPaths =
            artifacts.map(\.repositoryRelativePath)
        let outputPaths =
            artifacts.map(\.materializedRelativePath)
        let totalByteCount = artifacts.reduce(
            UInt64(0)
        ) {
            $0 + $1.byteCount
        }
        guard self == Self.frozenV1,
              schemaVersion == 1,
              planID
                == "ergentics_prime_frozen_companion_blob_resolver_v1",
              scope == "frozen_companion_blob_resolution_only",
              continuity.arcID == continuityArcID,
              resolverRepository
                == "Ergentics/ergentics-prime",
              !acceptedResolverRemoteURLs.isEmpty,
              continuity.companionRepository
                == companionRepository,
              continuity.companionRevision
                == companionRevision,
              Self.isGitOID(companionTreeOID),
              companionObjectFormat == "sha1",
              companionRawCommitByteCount == 1_240,
              Self.isSHA256(
                  companionRawCommitSHA256
              ),
              !acceptedRemoteURLs.isEmpty,
              artifacts.count == expectedArtifactCount,
              artifacts.count == continuityCompanion.count,
              Set(artifactIDs).count == artifactIDs.count,
              Set(donorPaths).count == donorPaths.count,
              Set(outputPaths).count == outputPaths.count,
              Set(artifactIDs)
                == Set(continuityCompanion.map(\.artifactID)),
              artifacts.allSatisfy({ specification in
                  guard let inventory =
                          continuityCompanion.first(
                              where: {
                                  $0.artifactID
                                    == specification
                                        .artifactID
                              }
                          ) else {
                      return false
                  }
                  return inventory.locator
                        == specification
                            .repositoryRelativePath
                      && inventory.sha256
                        == specification.sha256
                      && Self.isSafeRelativePath(
                          specification.repositoryRelativePath
                      )
                      && Self.isSafeRelativePath(
                          specification.materializedRelativePath
                      )
                      && specification
                        .materializedRelativePath
                        .hasPrefix("resolved/")
                      && Self.isGitOID(
                          specification.gitBlobOID
                      )
                      && Self.isSHA256(
                          specification.sha256
                      )
                      && specification.byteCount > 0
              }),
              totalByteCount == expectedTotalByteCount,
              blobTransport
                == "swift_process_direct_exec_usr_bin_git_read_only_plumbing_no_shell",
              scientificAuthorityLanguage == "swift",
              phaseTwoCanonicalReceiptSHA256
                == "2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e",
              phaseTwoCanonicalReceiptOffDeviceDurable,
              !phaseTwoCompleteDescriptorRootOffDeviceDurable,
              companionReadOnly,
              !companionRuntimeDependencyAuthorized,
              !compatibilityReplayComplete,
              !adapterImplementationAuthorized,
              !archiveExpansionAuthorized,
              !companionExecutionAuthorized,
              !neuralKitExecutionAuthorized,
              !modelExecutionAuthorized,
              !functionalTrainingAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !pythonExecutionAuthorized,
              !shellExecutionAuthorized,
              !historicalShellCaptureImportedAsAuthority,
              outputReceiptPath
                == "prime-native-contract-resolution-receipt.v1.json",
              authorityStatement.contains(
                  "resolves only eight frozen companion Git blobs"
              ),
              authorityStatement.contains(
                  "does not perform compatibility replay"
              )
        else {
            throw PrimeNativeContractMigrationError.contractDrift
        }
    }

    static func isGitOID(_ value: String) -> Bool {
        value.utf8.count == 40
            && value.utf8.allSatisfy(isLowerHex)
    }

    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy(isLowerHex)
    }

    static func isSafeRelativePath(_ value: String) -> Bool {
        guard !value.isEmpty,
              !value.hasPrefix("/"),
              !value.contains("\0") else {
            return false
        }
        let components = value.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        return !components.isEmpty
            && components.allSatisfy {
                !$0.isEmpty && $0 != "." && $0 != ".."
            }
    }

    private static func isLowerHex(_ byte: UInt8) -> Bool {
        (byte >= 48 && byte <= 57)
            || (byte >= 97 && byte <= 102)
    }
}

public struct PrimeNativeMigrationGitToolBinding:
    Codable,
    Equatable,
    Sendable
{
    public let absolutePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let deviceID: UInt64
    public let inode: UInt64
    public let version: String
    public let versionOutputSHA256: String
    public let environmentPolicyID: String
}

public struct PrimeNativeMigrationGitCommandObservation:
    Codable,
    Equatable,
    Sendable
{
    public let operation: String
    public let argv: [String]
    public let processIdentifier: Int32
    public let terminationStatus: Int32
    public let terminationReason: String
    public let stdoutByteCount: UInt64
    public let stdoutSHA256: String
    public let stderrByteCount: UInt64
    public let stderrSHA256: String
    public let outputOverflowed: Bool
}

public enum PrimeNativeMigrationResolverSourcePhase:
    String,
    Equatable,
    Sendable
{
    case preSnapshot = "resolver_source_pre"
    case postExecutable = "resolver_source_post"
}

public struct PrimeNativeMigrationResolverSourceState:
    Equatable,
    Sendable
{
    public let remoteURL: String
    public let revision: String
    public let treeOID: String
    public let clean: Bool
    public let commandObservations:
        [PrimeNativeMigrationGitCommandObservation]

    public init(
        remoteURL: String,
        revision: String,
        treeOID: String,
        clean: Bool,
        commandObservations:
            [PrimeNativeMigrationGitCommandObservation]
    ) {
        self.remoteURL = remoteURL
        self.revision = revision
        self.treeOID = treeOID
        self.clean = clean
        self.commandObservations = commandObservations
    }
}

public struct PrimeNativeMigrationRepositoryObservation:
    Codable,
    Equatable,
    Sendable
{
    public let observedRemoteURL: String
    public let requestedRevision: String
    public let resolvedRevision: String
    public let treeOID: String
    public let objectFormat: String
    public let rawCommitByteCount: UInt64
    public let rawCommitSHA256: String
}

public struct PrimeNativeMigrationResolvedGitBlob:
    Equatable,
    Sendable
{
    public let artifactID: String
    public let repositoryRelativePath: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let data: Data
}

public struct PrimeNativeMigrationResolvedInput:
    Sendable
{
    public let repository:
        PrimeNativeMigrationRepositoryObservation
    public let gitTool: PrimeNativeMigrationGitToolBinding
    public let commandObservations:
        [PrimeNativeMigrationGitCommandObservation]
    public let blobsByArtifactID:
        [String: PrimeNativeMigrationResolvedGitBlob]

    public init(
        repository:
            PrimeNativeMigrationRepositoryObservation,
        gitTool: PrimeNativeMigrationGitToolBinding,
        commandObservations:
            [PrimeNativeMigrationGitCommandObservation],
        blobsByArtifactID:
            [String: PrimeNativeMigrationResolvedGitBlob]
    ) {
        self.repository = repository
        self.gitTool = gitTool
        self.commandObservations = commandObservations
        self.blobsByArtifactID = blobsByArtifactID
    }
}

public struct PrimeNativeMigrationMaterializedArtifact:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let donorRelativePath: String
    public let donorRevision: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let expectedSHA256: String
    public let observedSHA256: String
    public let expectedByteCount: UInt64
    public let observedByteCount: UInt64
    public let role: PrimeNativeMigrationArtifactRole
    public let artifact: PrimeArtifactBinding
}

public enum PrimeNativeContractMigrationMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case identicalTreeWrongRevision =
        "identical_tree_wrong_revision"
    case identicalBlobWrongPath =
        "identical_blob_wrong_path"
    case missingArtifact = "missing_artifact"
    case changedBlobBytes = "changed_blob_bytes"
    case authorityExpansion = "authority_expansion"

    public var detectorID: String {
        switch self {
        case .identicalTreeWrongRevision:
            "exact_revision_detector_v1"
        case .identicalBlobWrongPath:
            "exact_tree_path_detector_v1"
        case .missingArtifact:
            "exact_inventory_detector_v1"
        case .changedBlobBytes:
            "swift_size_sha256_detector_v1"
        case .authorityExpansion:
            "resolver_scope_detector_v1"
        }
    }
}

public struct PrimeNativeContractMigrationMutationRecord:
    Codable,
    Equatable,
    Sendable
{
    public let mutation: PrimeNativeContractMigrationMutation
    public let detectorID: String
    public let detected: Bool
    public let restored: Bool
    public let independentScientificOracleClaimed: Bool
}

public enum PrimeNativeContractMigrationOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
}

public struct PrimeNativeContractMigrationReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome: PrimeNativeContractMigrationOutcome
    public let claimScope: String
    public let plan: PrimeNativeContractMigrationPlan
    public let resolverSourceRemoteURL: String
    public let resolverSourceRevision: String
    public let resolverSourceTreeOID: String
    public let resolverSourceTreeClean: Bool
    public let resolverSourceCommandObservations:
        [PrimeNativeMigrationGitCommandObservation]
    public let resolverSourceSnapshot:
        PrimeArtifactBinding
    public let resolverExecutable: PrimeArtifactBinding
    public let gitTool: PrimeNativeMigrationGitToolBinding
    public let repository:
        PrimeNativeMigrationRepositoryObservation
    public let commandObservations:
        [PrimeNativeMigrationGitCommandObservation]
    public let artifacts:
        [PrimeNativeMigrationMaterializedArtifact]
    public let totalMaterializedByteCount: UInt64
    public let mutationSweep:
        [PrimeNativeContractMigrationMutationRecord]
    public let declaredCompanionInventoryResolutionComplete: Bool
    public let compatibilityReplayComplete: Bool
    public let adapterImplementationComplete: Bool
    public let archiveExpanded: Bool
    public let companionWritePerformed: Bool
    public let companionRuntimeDependencyAdded: Bool
    public let donorExecutionPerformed: Bool
    public let neuralKitExecutionPerformed: Bool
    public let modelTrainingPerformed: Bool
    public let productPromotionAuthorized: Bool
    public let independentScientificOracleClaimed: Bool

    public init(
        resolverSourceRemoteURL: String,
        resolverSourceRevision: String,
        resolverSourceTreeOID: String,
        resolverSourceTreeClean: Bool,
        resolverSourceCommandObservations:
            [PrimeNativeMigrationGitCommandObservation],
        resolverSourceSnapshot: PrimeArtifactBinding,
        resolverExecutable: PrimeArtifactBinding,
        gitTool: PrimeNativeMigrationGitToolBinding,
        repository:
            PrimeNativeMigrationRepositoryObservation,
        commandObservations:
            [PrimeNativeMigrationGitCommandObservation],
        artifacts:
            [PrimeNativeMigrationMaterializedArtifact],
        mutationSweep:
            [PrimeNativeContractMigrationMutationRecord]
    ) {
        schemaVersion = 1
        artifactKind =
            "prime_native_frozen_companion_blob_resolution"
        outcome = .pass
        claimScope = "frozen_companion_blob_resolution_only"
        plan = .frozenV1
        self.resolverSourceRemoteURL =
            resolverSourceRemoteURL
        self.resolverSourceRevision =
            resolverSourceRevision
        self.resolverSourceTreeOID =
            resolverSourceTreeOID
        self.resolverSourceTreeClean =
            resolverSourceTreeClean
        self.resolverSourceCommandObservations =
            resolverSourceCommandObservations
        self.resolverSourceSnapshot =
            resolverSourceSnapshot
        self.resolverExecutable = resolverExecutable
        self.gitTool = gitTool
        self.repository = repository
        self.commandObservations = commandObservations
        self.artifacts = artifacts
        totalMaterializedByteCount =
            artifacts.reduce(UInt64(0)) {
                $0 + $1.observedByteCount
            }
        self.mutationSweep = mutationSweep
        declaredCompanionInventoryResolutionComplete = true
        compatibilityReplayComplete = false
        adapterImplementationComplete = false
        archiveExpanded = false
        companionWritePerformed = false
        companionRuntimeDependencyAdded = false
        donorExecutionPerformed = false
        neuralKitExecutionPerformed = false
        modelTrainingPerformed = false
        productPromotionAuthorized = false
        independentScientificOracleClaimed = false
    }

    public func validate() throws {
        try plan.validate()
        guard schemaVersion == 1,
              artifactKind
                == "prime_native_frozen_companion_blob_resolution",
              outcome == .pass,
              claimScope
                == "frozen_companion_blob_resolution_only",
              plan.acceptedResolverRemoteURLs.contains(
                  resolverSourceRemoteURL
              ),
              PrimeNativeContractMigrationPlan
                .isGitOID(resolverSourceRevision),
              PrimeNativeContractMigrationPlan
                .isGitOID(resolverSourceTreeOID),
              resolverSourceTreeClean,
              resolverSourceSnapshot.relativePath
                == "prime-swift-source-snapshot.v1.json",
              resolverSourceSnapshot.purpose
                == .immutableData,
              PrimeNativeContractMigrationPlan
                .isSHA256(
                    resolverSourceSnapshot.sha256
                ),
              resolverSourceSnapshot.byteCount > 0,
              resolverExecutable.relativePath
                == PrimeNativeContractMigrationResolver
                    .resolverExecutablePath,
              resolverExecutable.purpose == .executable,
              PrimeNativeContractMigrationPlan
                .isSHA256(resolverExecutable.sha256),
              resolverExecutable.byteCount > 0,
              gitTool.absolutePath == "/usr/bin/git",
              PrimeNativeContractMigrationPlan
                .isSHA256(gitTool.sha256),
              gitTool.byteCount > 0,
              gitTool.deviceID > 0,
              gitTool.inode > 0,
              gitTool.version.hasPrefix("git version "),
              PrimeNativeContractMigrationPlan
                .isSHA256(gitTool.versionOutputSHA256),
              gitTool.environmentPolicyID
                == "prime_git_read_only_fixed_environment_v2",
              plan.acceptedRemoteURLs.contains(
                  repository.observedRemoteURL
              ),
              repository.requestedRevision
                == plan.companionRevision,
              repository.resolvedRevision
                == plan.companionRevision,
              repository.treeOID == plan.companionTreeOID,
              repository.objectFormat
                == plan.companionObjectFormat,
              repository.rawCommitByteCount
                == plan.companionRawCommitByteCount,
              repository.rawCommitSHA256
                == plan.companionRawCommitSHA256,
              !commandObservations.isEmpty,
              commandObservations.allSatisfy({
                  $0.processIdentifier > 0
                      && $0.terminationStatus == 0
                      && $0.terminationReason == "exit"
                      && PrimeNativeContractMigrationPlan
                        .isSHA256($0.stdoutSHA256)
                      && PrimeNativeContractMigrationPlan
                        .isSHA256($0.stderrSHA256)
                      && !$0.outputOverflowed
              }),
              artifacts.count == plan.expectedArtifactCount,
              zip(artifacts, plan.artifacts)
                .allSatisfy({
                    artifact, specification in
                    artifact.artifactID
                        == specification.artifactID
                        && artifact.donorRelativePath
                            == specification
                                .repositoryRelativePath
                        && artifact.donorRevision
                            == plan.companionRevision
                        && artifact.mode == "100644"
                        && artifact.objectType == "blob"
                        && artifact.gitBlobOID
                            == specification.gitBlobOID
                        && artifact.expectedSHA256
                            == specification.sha256
                        && artifact.observedSHA256
                            == specification.sha256
                        && artifact.expectedByteCount
                            == specification.byteCount
                        && artifact.observedByteCount
                            == specification.byteCount
                        && artifact.role
                            == specification.role
                        && artifact.artifact.relativePath
                            == specification
                                .materializedRelativePath
                        && artifact.artifact.sha256
                            == specification.sha256
                        && artifact.artifact.byteCount
                            == specification.byteCount
                        && artifact.artifact.purpose
                            == .immutableData
                }),
              totalMaterializedByteCount
                == plan.expectedTotalByteCount,
              mutationSweep.map(\.mutation)
                == PrimeNativeContractMigrationMutation
                    .allCases,
              mutationSweep.allSatisfy({
                  $0.detectorID
                        == $0.mutation.detectorID
                      && $0.detected
                      && $0.restored
                      && !$0
                        .independentScientificOracleClaimed
              }),
              declaredCompanionInventoryResolutionComplete,
              !compatibilityReplayComplete,
              !adapterImplementationComplete,
              !archiveExpanded,
              !companionWritePerformed,
              !companionRuntimeDependencyAdded,
              !donorExecutionPerformed,
              !neuralKitExecutionPerformed,
              !modelTrainingPerformed,
              !productPromotionAuthorized,
              !independentScientificOracleClaimed
        else {
            throw PrimeNativeContractMigrationError
                .receiptInvalid("structural contract")
        }
        try PrimeNativeContractMigrationResolver
            .validateGitTool(gitTool)
        try PrimeNativeContractMigrationResolver
            .validateRepository(repository, plan: plan)
        try PrimeNativeContractMigrationResolver
            .validateCommandObservations(
                commandObservations,
                plan: plan
            )
        try PrimeNativeContractMigrationResolver
            .validateCommandOutputBindings(
                commandObservations,
                gitTool: gitTool,
                repository: repository,
                plan: plan
            )
        try PrimeNativeContractMigrationResolver
            .validateResolverSourceCommandObservations(
                resolverSourceCommandObservations,
                remoteURL: resolverSourceRemoteURL,
                revision: resolverSourceRevision,
                treeOID: resolverSourceTreeOID,
                clean: resolverSourceTreeClean
            )
    }

    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validate()
        let sourceSnapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: resolverSourceSnapshot
        )
        try PrimeSwiftSourceProvenance.validate(
            sourceSnapshot,
            requiredRelativePaths:
                PrimeNativeContractMigrationResolver
                .requiredResolverSourcePaths
        )
        _ = try root.verify(resolverExecutable)
        for artifact in artifacts {
            _ = try root.verify(artifact.artifact)
        }
    }
}

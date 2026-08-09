import Foundation
import PrimeLatinProposalProducerRevalidationObservation

private enum PrimeLatinProposalProducerRevalidationProbeError: Error {
    case invalidArguments
    case invalidObservation
}

private struct PrimeLatinProposalProducerRevalidationProbeArguments {
    let labRoot: URL
    let producerRepositoryRoot: URL
    let toolRepositoryRoot: URL
    let scratchParent: URL

    static func parse(_ rawArguments: [String]) throws -> Self {
        guard rawArguments.count == 10 else {
            throw PrimeLatinProposalProducerRevalidationProbeError
                .invalidArguments
        }
        var action: String?
        var labRoot: String?
        var producerRepositoryRoot: String?
        var toolRepositoryRoot: String?
        var scratchParent: String?
        var index = 0
        while index < rawArguments.count {
            let option = rawArguments[index]
            let value = rawArguments[index + 1]
            guard !value.isEmpty else {
                throw PrimeLatinProposalProducerRevalidationProbeError
                    .invalidArguments
            }
            switch option {
            case "--action":
                guard action == nil else {
                    throw PrimeLatinProposalProducerRevalidationProbeError
                        .invalidArguments
                }
                action = value
            case "--lab-root":
                guard labRoot == nil else {
                    throw PrimeLatinProposalProducerRevalidationProbeError
                        .invalidArguments
                }
                labRoot = value
            case "--producer-repository-root":
                guard producerRepositoryRoot == nil else {
                    throw PrimeLatinProposalProducerRevalidationProbeError
                        .invalidArguments
                }
                producerRepositoryRoot = value
            case "--tool-repository-root":
                guard toolRepositoryRoot == nil else {
                    throw PrimeLatinProposalProducerRevalidationProbeError
                        .invalidArguments
                }
                toolRepositoryRoot = value
            case "--scratch-parent":
                guard scratchParent == nil else {
                    throw PrimeLatinProposalProducerRevalidationProbeError
                        .invalidArguments
                }
                scratchParent = value
            default:
                throw PrimeLatinProposalProducerRevalidationProbeError
                    .invalidArguments
            }
            index += 2
        }
        guard action == "observe",
              let labRoot,
              let producerRepositoryRoot,
              let toolRepositoryRoot,
              let scratchParent,
              [
                  labRoot,
                  producerRepositoryRoot,
                  toolRepositoryRoot,
                  scratchParent,
              ].allSatisfy({ $0.hasPrefix("/") }) else {
            throw PrimeLatinProposalProducerRevalidationProbeError
                .invalidArguments
        }
        return Self(
            labRoot: URL(fileURLWithPath: labRoot, isDirectory: true),
            producerRepositoryRoot: URL(
                fileURLWithPath: producerRepositoryRoot,
                isDirectory: true),
            toolRepositoryRoot: URL(
                fileURLWithPath: toolRepositoryRoot,
                isDirectory: true),
            scratchParent: URL(
                fileURLWithPath: scratchParent,
                isDirectory: true))
    }
}

@main
struct PrimeLatinProposalProducerRevalidationObservationProbeMain {
    static func main() throws {
        let arguments = try PrimeLatinProposalProducerRevalidationProbeArguments
            .parse(Array(CommandLine.arguments.dropFirst()))
        let request = try PrimeLatinProposalProducerRevalidationRequestV1(
            labRoot: arguments.labRoot,
            producerRepositoryRoot: arguments.producerRepositoryRoot,
            toolRepositoryRoot: arguments.toolRepositoryRoot,
            scratchParent: arguments.scratchParent)
        let capture = try PrimeLatinProposalProducerRevalidationCaptureV1
            .capture(request: request)
        let observation = try capture.recaptureAndValidateUnchanged()
        let authority = observation.authority
        let build = observation.build
        let process = observation.process
        let toolSource = observation.toolSource
        guard observation == capture.observation,
              observation.schema
                == "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1",
              observation.outcome == "abstain",
              observation.verificationScope
                == "prime_built_exact_merged_revalidator_source_closure_and_observed_two_cross_bound_live_producer_processes_only_non_authorizing",
              observation.pairReceiptSHA256
                == "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7",
              observation.producerRepository == "Ergentics/ergentics-llm",
              observation.producerCommit
                == "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
              observation.producerTree
                == "c1f41758aea2860ab06039776f5ea0403dff1b61",
              toolSource.repository == "Ergentics/ergentics-llm",
              toolSource.commit
                == "1ccfb6bf6718e2378f14ab87cacae1ada303cf48",
              toolSource.tree
                == "6ee438bf1132d26767fbf447355b8165455b956f",
              toolSource.parentCommit == observation.producerCommit,
              toolSource.rawCommitSHA256
                == "380c13a3f9f3421db875d2ccc3c4547002374a9d74427a0573e0c59f6d3078ac",
              toolSource.rawCommitByteCount == 1_328,
              toolSource.trackedIndexEntryCount == 147,
              toolSource.trackedIndexInventorySHA256
                == "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81",
              toolSource.trackedIndexInventoryByteCount == 14_281,
              toolSource.artifacts.count == 4,
              toolSource.locallyDeclaredOriginURL
                == "https://github.com/Ergentics/ergentics-llm.git",
              toolSource.originObservationScope
                == "locally_declared_origin_only_not_network_authenticated",
              observation.candidateCatalogSHA256
                == "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
              observation.candidateCatalogByteCount == 20_803,
              observation.experimentManifestSHA256
                == "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
              observation.experimentManifestByteCount == 3_364,
              observation.candidateDeclarationSetSHA256
                == "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
              observation.candidateDeclarationSetByteCount == 14_860,
              observation.tokenizerBundleSHA256
                == "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
              observation.tokenizerBundleByteCount == 2_930,
              observation.candidateIDs == ["latin_structural_fixture_v1"],
              observation.candidateIdentitySHA256s
                == ["64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265"],
              observation.declarationBundleSHA256s
                == ["6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd"],
              observation.inputBindingCount == 21,
              observation.optimizerSteps == 1,
              observation.trainingTokens == 128,
              observation.wallClockSeconds == 60,
              observation.outputNamespace
                == "models/latin-prospective/structural-fixture-v3-776c412e",
              build.buildPolicyID
                == "prime_latin_exact_source_direct_swiftc_build_v1",
              build.compilerLauncher.role == "compiler_launcher",
              build.compilerLauncher.absolutePath == "/usr/bin/xcrun",
              build.compiler.role == "swift_compiler",
              build.compiler.absolutePath
                == "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver",
              build.compilerIdentityScope
                == "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated",
              build.compileCommandCount == 3,
              build.processLaunchCount == 5,
              build.governanceArtifactCount == 4,
              build.compilerInputSourceCount == 3,
              build.executable.role
                == "producer_revalidation_probe_executable",
              build.executable.byteCount > 0,
              lowerHex(build.compilerLauncher.sha256, count: 64),
              lowerHex(build.compiler.sha256, count: 64),
              lowerHex(build.executable.sha256, count: 64),
              process.processPolicyID
                == "prime_latin_producer_revalidation_fixed_fresh_process_v1",
              process.invocationCount == 2,
              process.standardOutputSHA256
                == "0657289657fbb99ca91ad9b1788ccfbe9b1697881cef85df6241ab30b0bf984f",
              process.standardOutputByteCount == 8_434,
              process.standardErrorSHA256
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
              process.standardErrorByteCount == 0,
              authority.disposition
                == "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay",
              authority.pairCaptureAndRecaptureComplete,
              authority.inputSnapshotCaptureAndRecaptureComplete,
              authority.producerGitObservationComplete,
              authority.exactMergedRevalidatorSourceObserved,
              authority.exactRevalidatorSourceClosureObserved,
              authority.compilerIdentityObserved,
              !authority.compilerCryptographicallyAuthenticated,
              authority.localExactSourceClosureBuildObserved,
              !authority.externalSourceToBinaryAttestationAvailable,
              authority.revalidatorExecutableBuiltFromObservedSourceClosure,
              authority.revalidatorExecutableIdentityStable,
              authority.boundedFreshProcessObservationComplete,
              authority.canonicalRevalidationObservationDecoded,
              authority.expectedPairReceiptCrossBindingValidated,
              authority.exactTwentyOneInputBindingsCrossBound,
              authority.canonicalHashChainCrossBindingsMatched,
              authority.repeatedProducerProcessObservationUnchanged,
              authority.outputNamespaceAbsenceVerified,
              authority.llmGitStateIndependentlyObserved,
              authority.revalidatorToolSourceIndependentlyObserved,
              authority.liveProducerWorkspaceRevalidationComplete,
              !authority.originRemoteCryptographicallyAuthenticated,
              !authority.ignoredWorkspaceBytesObserved,
              !authority.durableInputSnapshotPublished,
              !authority.durableGitObservationPublished,
              !authority.durableRevalidationObservationPublished,
              !authority.independentPrimeReplayComplete,
              !authority.runtimeDecoderImplementationAvailable,
              !authority.runtimeDependencyClosureEstablished,
              !authority.runtimeInitializationEstablished,
              !authority.primeProposalPacketProduced,
              !authority.primeTrialAuthorizationProduced,
              !authority.primeDecisionReceiptProduced,
              !authority.candidateSelectionAuthorized,
              !authority.trialExecutionAuthorized,
              !authority.furtherTrainingAuthorized,
              !authority.promotionAuthorized,
              !authority.productUseAuthorized,
              !authority.publicationAuthorized,
              !authority.proposalPairPublicationPerformedByThisObservation,
              !authority.primeDurableReceiptPublished else {
            throw PrimeLatinProposalProducerRevalidationProbeError
                .invalidObservation
        }

        let summary =
            "{\"candidate_catalog_sha256\":\"" +
            observation.candidateCatalogSHA256 +
            "\",\"experiment_manifest_sha256\":\"" +
            observation.experimentManifestSHA256 +
            "\",\"independent_prime_replay_complete\":false," +
            "\"live_producer_workspace_revalidation_complete\":true," +
            "\"outcome\":\"abstain\",\"pair_receipt_sha256\":\"" +
            observation.pairReceiptSHA256 +
            "\",\"producer_commit\":\"" + observation.producerCommit +
            "\",\"schema\":\"" + observation.schema +
            "\",\"tool_commit\":\"" + toolSource.commit + "\"}\n"
        let output = Data(summary.utf8)
        guard output.count <= 1_024 else {
            throw PrimeLatinProposalProducerRevalidationProbeError
                .invalidObservation
        }
        try FileHandle.standardOutput.write(contentsOf: output)
    }

    private static func lowerHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }
}

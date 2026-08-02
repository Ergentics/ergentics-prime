public enum PrimeNativeNeuralGateTopologyError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case duplicateTarget(String)
    case missingDependency(
        target: String,
        dependency: String
    )
    case invalidMaterialization(
        target: String
    )
    case forbiddenReachability(
        target: String,
        reached: String
    )
    case historicalContainmentEscape(
        target: String
    )
    case unknownTarget(String)
}

public enum PrimeNativeNeuralGateTargetMaterialization:
    String,
    Codable,
    Equatable,
    Sendable
{
    case implemented
    case plannedNotMaterialized =
        "planned_not_materialized"
}

public struct PrimeNativeNeuralGateTopologyTarget:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let materialization:
        PrimeNativeNeuralGateTargetMaterialization
    public let directLocalDependencyNames:
        [String]
    public let externalProductDependencyNames:
        [String]
    public let authority: String

    public init(
        targetName: String,
        materialization:
            PrimeNativeNeuralGateTargetMaterialization,
        directLocalDependencyNames: [String],
        externalProductDependencyNames: [String],
        authority: String
    ) {
        self.targetName = targetName
        self.materialization = materialization
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.externalProductDependencyNames =
            externalProductDependencyNames
        self.authority = authority
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case materialization
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case externalProductDependencyNames =
            "external_product_dependency_names"
        case authority
    }
}

public struct PrimeNativeNeuralGateForbiddenReachability:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let forbiddenReachableTargetNames:
        [String]

    public init(
        targetName: String,
        forbiddenReachableTargetNames: [String]
    ) {
        self.targetName = targetName
        self.forbiddenReachableTargetNames =
            forbiddenReachableTargetNames
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case forbiddenReachableTargetNames =
            "forbidden_reachable_target_names"
    }
}

public struct PrimeNativeNeuralGateTopologyContractBinding:
    Codable,
    Equatable,
    Sendable
{
    public let contractID: String
    public let contentSHA256: String

    fileprivate init(
        contractID: String,
        contentSHA256: String
    ) {
        self.contractID = contractID
        self.contentSHA256 = contentSHA256
    }

    fileprivate func validate() -> Bool {
        !contractID.isEmpty
            && contractID.utf8.count <= 256
            && contractID.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 95
            }
            && contentSHA256.utf8.count == 64
            && contentSHA256.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case contentSHA256 = "content_sha256"
    }
}

/// The post-audit Stage-B topology correction.
///
/// This contract deliberately does not revise the historical V5 replay plan
/// or V6 source binding. Those identities remain byte-for-byte history. It
/// supersedes only their unsafe future target-routing assumption and remains
/// `planned_not_materialized` until every future target exists and a live
/// package-description closure is validated.
public struct PrimeNativeNeuralGateTrapDisjointTopologyContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let status:
        PrimeNativeNeuralGateTargetMaterialization
    public let executionImplemented: Bool
    public let historicalReplayPlanID: String
    public let historicalSourceBindingContractID:
        String
    public private(set) var
        historicalEvidenceExportDesignContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalEvidenceExportSourceContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalWorkerEvidenceExportCallEdgeSourceContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalEvidenceSemanticArtifactProjectionDesignContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalEvidenceSemanticArtifactProjectionSourceContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding:
        PrimeNativeNeuralGateTopologyContractBinding? = nil
    public private(set) var
        historicalEvidenceExportTargetName:
        String? = nil
    public private(set) var
        historicalEvidenceSemanticArtifactProjectionTargetName:
        String? = nil
    public let historicalContractsPreserved: Bool
    public let historicalFutureTargetGraphSuperseded:
        Bool
    public let targetGraph:
        [PrimeNativeNeuralGateTopologyTarget]
    public let forbiddenReachability:
        [PrimeNativeNeuralGateForbiddenReachability]
    public let historicalContainmentRootTargetName:
        String
    public let historicalRuntimeTargetName: String
    public let historicalReplayTargetName: String
    public let pureReplayTargetName: String
    public let donorAdaptationV2PreservedAsHistory:
        Bool
    public let donorAdaptationV3Required: Bool
    public let donorAdaptationV3RequiredDestination:
        String
    public let sourceBindingV7Issued: Bool
    public let sourceBindingV7Prerequisite: String
    public let packageCaptureAuthority: String
    public let mutationProducerDetectorTargetAssignmentDeferred:
        Bool
    public let mutationProducerDetectorMustBeDisjoint:
        Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_trap_disjoint_topology_v1",
        status: .plannedNotMaterialized,
        executionImplemented: false,
        historicalReplayPlanID:
            "ergentics_prime_native_neural_gate_dual_fixture_replay_v5",
        historicalSourceBindingContractID:
            "prime_stage_b_release_source_executable_join_v6",
        historicalContractsPreserved: true,
        historicalFutureTargetGraphSuperseded: true,
        targetGraph: [
            target(
                "PrimeCore",
                .implemented,
                [],
                "typed Prime contracts and durable artifact substrate"
            ),
            target(
                "PrimeNativeCorpusReplayMechanics",
                .implemented,
                [],
                "trap-bearing offline corpus and fixture derivation authority"
            ),
            target(
                "PrimeNativeNeuralGateReplayMechanics",
                .implemented,
                [],
                "pure raw-UTF8 stream, chunk, invariant, and fingerprint mechanics"
            ),
            target(
                "PrimeNativeNeuralGateCorrectedMechanics",
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                "prompt-only raw execution values and structural traces"
            ),
            target(
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedMechanics",
                ],
                "correlation, target feasibility, regrade, statistics, capability, verdict, and mutation-observation validation"
            ),
            target(
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                .implemented,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                ],
                "trap-bearing offline corrected fixture derivation"
            ),
            target(
                "PrimeNativeNeuralGatePromptSolver",
                .implemented,
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                ],
                "prompt-only solver leaf with no fixture or evaluation authority"
            ),
            target(
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                .implemented,
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                ],
                "lossless bounded Float32 full-vocabulary logit sidecar mechanics"
            ),
            target(
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                .implemented,
                [
                    "PrimeNativeNeuralGateLogitSidecarMechanics",
                ],
                "maintained MLX Float32 log-softmax recomputation",
                externalProducts: [
                    "MLX",
                    "MLXNN",
                ]
            ),
            target(
                "ErgenticsPrimeRuntime",
                .plannedNotMaterialized,
                [],
                "source-derived historical runtime authority"
            ),
            target(
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                .plannedNotMaterialized,
                [
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                "byte-exact donor gate, bounded verdict carrier, and historical-only observation seam"
            ),
            target(
                "PrimeNativeNeuralGateReplayTransport",
                .plannedNotMaterialized,
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                "pure typed Stage-B artifact contracts and bounded transport"
            ),
            target(
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                .plannedNotMaterialized,
                [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                ],
                "sealed fresh-process historical fixture execution"
            ),
            target(
                "PrimeNativeNeuralGateReplayProbe",
                .plannedNotMaterialized,
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateReplayTransport",
                ],
                "trap-free Stage-B probe supervisor"
            ),
            target(
                "PrimeNativeNeuralGateReplayVerifier",
                .plannedNotMaterialized,
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateReplayTransport",
                ],
                "trap-free independent Stage-B verifier supervisor"
            ),
            target(
                "PrimeNativeNeuralGateCorrectedRawWorker",
                .plannedNotMaterialized,
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateLogitSidecarMechanics",
                ],
                "separately launched prompt-only corrected raw executor"
            ),
        ],
        forbiddenReachability: [
            forbidden(
                "PrimeNativeNeuralGateCorrectedMechanics",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGatePromptSolver",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateReplayTransport",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateReplayProbe",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateReplayVerifier",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
            forbidden(
                "PrimeNativeNeuralGateCorrectedRawWorker",
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            ),
        ],
        historicalContainmentRootTargetName:
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        historicalRuntimeTargetName:
            "ErgenticsPrimeRuntime",
        historicalReplayTargetName:
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
        pureReplayTargetName:
            "PrimeNativeNeuralGateReplayMechanics",
        donorAdaptationV2PreservedAsHistory: true,
        donorAdaptationV3Required: true,
        donorAdaptationV3RequiredDestination:
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/",
        sourceBindingV7Issued: false,
        sourceBindingV7Prerequisite:
            "freeze_and_materialize_every_planned_and_deferred_evidence_role_including_independent_corrected_mutation_producer_detector_and_process_scoped_evaluation_ownership_then_validate_a_live_compiled_source_closure_against_the_exact_package_description",
        packageCaptureAuthority:
            "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
        mutationProducerDetectorTargetAssignmentDeferred:
            true,
        mutationProducerDetectorMustBeDisjoint: true,
        nextImplementationPrerequisite:
            "implement_pure_typed_artifact_schemas_bounded_canonical_decoders_and_source_bound_corrected_mutation_producer_detector_without_materializing_historical_runtime",
        authorityStatement:
            "This V1 contract corrects future Stage-B target routing while preserving the historical V5 replay-plan and V6 source-binding bytes. The implemented raw/evaluation split is package-observable. Historical runtime, historical replay, replay transport, workers, probe, and verifier remain planned_not_materialized; executionImplemented is false. A package-description capture proves only the captured package and secure-capture mechanics unless the live compiled-source closure is reconciled against the same contract. Source binding V7 is not issued and cannot issue until every planned and deferred evidence role, including independent corrected mutation producer/detector and process-scoped evaluation ownership, is frozen and materialized. Donor adaptation V2 remains historical only; V3 must route donor gate and carrier material to the historical replay target, never the pure replay substrate. Mutation production and independent detection must be disjoint, but their target assignment remains deferred until typed raw-material contracts exist."
    )

    /// Materializes only the non-authorizing artifact-contract and bounded
    /// in-memory transport layers. V1 remains the exact historical topology
    /// that preceded this split.
    public static let frozenV2: Self = {
        let previous = frozenV1
        let contractsTargetName =
            "PrimeNativeNeuralGateReplayArtifactContracts"
        var targets:
            [PrimeNativeNeuralGateTopologyTarget] =
            []
        for target in previous.targetGraph {
            switch target.targetName {
            case "PrimeNativeNeuralGateReplayTransport":
                targets.append(
                    Self.target(
                        contractsTargetName,
                        .implemented,
                        [],
                        "pure non-authorizing Stage-B wire identities, bounded semantic artifact keys, and reserved output namespace"
                    )
                )
                targets.append(
                    Self.target(
                        target.targetName,
                        .implemented,
                        [
                            contractsTargetName,
                            "PrimeNativeNeuralGateReplayMechanics",
                        ],
                        "bounded canonical in-memory decoding into non-authorizing validated transport values"
                    )
                )
            case "PrimeNativeNeuralGateCorrectedRawWorker":
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target
                            .directLocalDependencyNames
                            + [contractsTargetName],
                        target.authority,
                        externalProducts:
                            target
                            .externalProductDependencyNames
                    )
                )
            default:
                targets.append(target)
            }
        }

        var reachability:
            [PrimeNativeNeuralGateForbiddenReachability] =
            []
        for rule in previous.forbiddenReachability {
            if rule.targetName
                == "PrimeNativeNeuralGateReplayTransport"
            {
                reachability.append(
                    Self.forbidden(
                        contractsTargetName,
                        [
                            "PrimeCore",
                            "PrimeNativeCorpusReplayMechanics",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                            "PrimeNativeNeuralGatePromptSolver",
                            "PrimeNativeNeuralGateLogitSidecarMechanics",
                            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                            "ErgenticsPrimeRuntime",
                            "PrimeNativeNeuralGateHistoricalReplayMechanics",
                        ]
                    )
                )
                reachability.append(
                    Self.forbidden(
                        rule.targetName,
                        [
                            "PrimeCore",
                            "PrimeNativeCorpusReplayMechanics",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                            "PrimeNativeNeuralGatePromptSolver",
                            "PrimeNativeNeuralGateLogitSidecarMechanics",
                            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                            "ErgenticsPrimeRuntime",
                            "PrimeNativeNeuralGateHistoricalReplayMechanics",
                        ]
                    )
                )
            } else {
                reachability.append(rule)
            }
        }

        return Self(
            schemaVersion: 2,
            contractID:
                "prime_stage_b_trap_disjoint_topology_v2",
            status: .plannedNotMaterialized,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous
                .historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded:
                true,
            targetGraph: targets,
            forbiddenReachability:
                reachability,
            historicalContainmentRootTargetName:
                previous
                .historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory:
                true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous
                .donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred:
                true,
            mutationProducerDetectorMustBeDisjoint:
                true,
            nextImplementationPrerequisite:
                "complete_descriptor_rooted_streaming_artifact_decoders_freeze_corrected_process_and_receipt_ownership_then_materialize_disjoint_corrected_mutation_producer_detector",
            authorityStatement:
                "This V2 contract preserves V1 and the historical V5/V6 identities while materializing only two trap-free, non-authorizing layers: a dependency-free artifact-contract target and a bounded in-memory transport target that depends only on those contracts and pure replay mechanics. No production target imports transport in this slice. Large invariant and logit payloads still require descriptor-rooted streaming validation; corrected process ownership and replacement receipt count remain deferred. Workers, probe, verifier, historical runtime, historical replay, mutation producer, and mutation detector remain planned_not_materialized. executionImplemented is false, source binding V7 is not issued, and decoder success cannot create mechanics PASS, model capability, scientific authority, product authority, or a terminal receipt."
        )
    }()

    /// Materializes the trap-free replay-composition layer without changing
    /// the authority or materialization status of any worker, supervisor, or
    /// historical target. V1 and V2 remain exact historical contracts.
    public static let frozenV3: Self = {
        let previous = frozenV2
        let compositionTargetName =
            "PrimeNativeNeuralGateReplayComposition"
        var targets:
            [PrimeNativeNeuralGateTopologyTarget] =
            []
        for target in previous.targetGraph {
            if target.targetName
                == "PrimeNativeNeuralGateReplayTransport"
            {
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames,
                        "bounded canonical in-memory decoding plus the shared non-authorizing canonical producer codec for three manifests and three pathless record shapes",
                        externalProducts:
                            target
                            .externalProductDependencyNames
                    )
                )
                targets.append(
                    Self.target(
                        compositionTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            "PrimeNativeNeuralGateReplayTransport",
                            "PrimeNativeNeuralGateReplayMechanics",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                            "PrimeNativeNeuralGateLogitSidecarMechanics",
                        ],
                        "strict canonical prompt scheduling, target-free correlation identity, and exact outer/raw/validated-sidecar joins under prime_stage_b_strict_prompt_schedule_exact_cross_artifact_join_v1 SHA-256 75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e"
                    )
                )
            } else {
                targets.append(target)
            }
        }

        var reachability = previous.forbiddenReachability
        reachability.append(
            Self.forbidden(
                compositionTargetName,
                [
                    "PrimeCore",
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            )
        )

        return Self(
            schemaVersion: 3,
            contractID:
                "prime_stage_b_trap_disjoint_topology_v3",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous
                .historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded:
                true,
            targetGraph: targets,
            forbiddenReachability:
                reachability,
            historicalContainmentRootTargetName:
                previous
                .historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory:
                true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous
                .donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred:
                true,
            mutationProducerDetectorMustBeDisjoint:
                true,
            nextImplementationPrerequisite:
                "implement_descriptor_rooted_bounded_invariant_stream_decoders_bind_validated_stream_capabilities_and_lawful_schedule_delivery_to_frozen_composition_then_freeze_independent_prompt_target_crosswalk_without_materializing_workers",
            authorityStatement:
                "This V3 contract preserves V1, V2, and the historical V5/V6 identities while materializing only two additional trap-free capabilities already present in the package: the shared bounded canonical producer/decoder codec in PrimeNativeNeuralGateReplayTransport and PrimeNativeNeuralGateReplayComposition under prime_stage_b_strict_prompt_schedule_exact_cross_artifact_join_v1 SHA-256 75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e. Composition derives a strict exact prompt schedule and target-free correlation identity, and rejects outer/raw/validated-sidecar joins unless reconstructed decisions reproduce the raw PRIMECRT4 trace. It does not establish descriptor-rooted or durable artifact origin, lawful schedule-capability delivery to disjoint producers, independent prompt/target crosswalk authority, prompt independence, model execution, evaluation, verdict, publication, scientific authority, product authority, or a receipt. Historical runtime, historical replay, all workers, probe, verifier, mutation producer, and mutation detector remain planned_not_materialized. executionImplemented is false and source binding V7 is not issued."
        )
    }()

    /// Materializes descriptor-rooted artifact source binding and typed,
    /// target-free schedule delivery without admitting fixture/target
    /// authority into the raw execution closure. V1 through V3 remain exact
    /// historical contracts.
    public static let frozenV4: Self = {
        let previous = frozenV3
        let sourceBindingTargetName =
            "PrimeNativeNeuralGateReplaySourceBinding"
        let compositionTargetName =
            "PrimeNativeNeuralGateReplayComposition"
        let sourceCompositionTargetName =
            "PrimeNativeNeuralGateReplaySourceComposition"
        var targets:
            [PrimeNativeNeuralGateTopologyTarget] =
            []
        for target in previous.targetGraph {
            if target.targetName == compositionTargetName {
                targets.append(
                    Self.target(
                        sourceBindingTargetName,
                        .implemented,
                        [
                            "PrimeCore",
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            "PrimeNativeNeuralGateReplayTransport",
                            "PrimeNativeNeuralGateReplayMechanics",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                            "PrimeNativeNeuralGateLogitSidecarMechanics",
                        ],
                        "descriptor-rooted read-only artifact opening, bounded invariant global/chunk streaming, source-bound logit sidecar validation, and sealed non-authorizing source capabilities"
                    )
                )
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames,
                        target.authority,
                        externalProducts:
                            target.externalProductDependencyNames
                    )
                )
                targets.append(
                    Self.target(
                        sourceCompositionTargetName,
                        .implemented,
                        [
                            sourceBindingTargetName,
                            compositionTargetName,
                        ],
                        "outer adapter for source-bound prompt schedule construction, asymmetric target-free raw/outer schedule delivery, and exact source-capability composition"
                    )
                )
            } else {
                targets.append(target)
            }
        }

        var reachability = previous.forbiddenReachability
        reachability.append(
            Self.forbidden(
                sourceBindingTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                sourceCompositionTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            )
        )

        return Self(
            schemaVersion: 4,
            contractID:
                "prime_stage_b_descriptor_source_binding_topology_v4",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred: true,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "freeze_single_held_root_four_source_capture_inventory_session_then_freeze_independent_source_derived_prompt_target_crosswalk_in_trap_bearing_authority_target_without_materializing_workers",
            authorityStatement:
                "This V4 contract preserves V1, V2, V3, and the historical V5/V6 identities while materializing only descriptor-rooted read-only source binding and an outer typed source-composition adapter. Source binding reuses PrimeCore's hardened artifact-root descriptor API, rejects symlinks and writable files, detects instability during each descriptor read, validates invariant global/chunk partitions without materializing complete streams, and source-binds the existing lossless logit codec. The pure V1 composition target remains free of PrimeCore; the outer adapter alone bridges sealed source capabilities into asymmetric target-free schedule views and the exact join. Equal root identity across separate binds does not establish a single descendant-tree capture epoch or durable origin. A single held-root four-source capture/inventory session is the immediate next boundary; the separate trap-bearing independent crosswalk follows it. Neither target establishes independent prompt/target binding, prompt-content target independence, model execution, evaluation, verdict, publication, scientific authority, product authority, or a receipt. Historical runtime, all workers, probe, verifier, mutation producer, and mutation detector remain planned_not_materialized. executionImplemented is false and source binding V7 is not issued."
        )
    }()

    /// Materializes one exact held-root four-source capture capability and a
    /// separate trap-bearing source-derived prompt/target crosswalk authority.
    /// It does not materialize a worker, supervisor, execution process, or
    /// receipt. V1 through V4 remain exact historical contracts.
    public static let frozenV5: Self = {
        let previous = frozenV4
        let sourceCompositionTargetName =
            "PrimeNativeNeuralGateReplaySourceComposition"
        let captureTargetName =
            "PrimeNativeNeuralGateReplayCaptureInventory"
        let crosswalkTargetName =
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority"
        var targets:
            [PrimeNativeNeuralGateTopologyTarget] =
            []
        for target in previous.targetGraph {
            targets.append(target)
            if target.targetName == sourceCompositionTargetName {
                targets.append(
                    Self.target(
                        captureTargetName,
                        .implemented,
                        [
                            "PrimeCore",
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            "PrimeNativeNeuralGateReplaySourceBinding",
                        ],
                        "sealed exact 41-file held-root four-source capture inventory with retained descriptor-rooted unchanged recapture; establishes one capture epoch and durable origin only for the captured source bytes"
                    )
                )
                targets.append(
                    Self.target(
                        crosswalkTargetName,
                        .implemented,
                        [
                            "PrimeCore",
                            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                            captureTargetName,
                            "PrimeNativeNeuralGateReplayComposition",
                            sourceCompositionTargetName,
                            "PrimeNativeNeuralGateReplayTransport",
                        ],
                        "trap-bearing source-derived 18,432-row PRIMECPI2-to-PRIMECOR1-to-PRIMECFT1 keyed prompt/target authority over a sealed capture; establishes outer expected-completion binding without prompt-blind execution or mechanics PASS authority"
                    )
                )
            }
        }

        var reachability =
            previous.forbiddenReachability.map { rule in
                Self.forbidden(
                    rule.targetName,
                    rule.forbiddenReachableTargetNames
                        + [
                            captureTargetName,
                            crosswalkTargetName,
                        ]
                )
            }
        reachability.append(
            Self.forbidden(
                captureTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    crosswalkTargetName,
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                crosswalkTargetName,
                [
                    "PrimeNativeNeuralGatePromptSolver",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                    "PrimeNativeNeuralGateReplayProbe",
                    "PrimeNativeNeuralGateReplayVerifier",
                    "PrimeNativeNeuralGateCorrectedRawWorker",
                ]
            )
        )

        return Self(
            schemaVersion: 5,
            contractID:
                "prime_stage_b_held_root_capture_crosswalk_authority_topology_v5",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred: true,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "freeze_corrected_process_evaluation_receipt_ownership_and_lawful_target_free_schedule_delivery_then_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers",
            authorityStatement:
                "This V5 contract preserves V1, V2, V3, V4, and the historical V5/V6 replay identities while materializing only two additional boundaries. The retained exact 41-file held-root four-source capture establishes one descendant-tree capture epoch and durable origin for the captured prompt, outer-evaluation, one-seed raw-execution, and one-seed lossless-logit bytes. The separate trap-bearing source-derived crosswalk establishes corrected fixture identity, exact PRIMECPI2-to-PRIMECOR1-to-PRIMECFT1 keyed association, and outer expected-completion binding across all 18,432 rows. It does not prove prompt-content target independence, observe process delivery or model execution, perform evaluation or verdict publication, authorize mechanics PASS, issue a receipt, establish scientific authority, or authorize product use. Historical runtime, all workers, probe, verifier, mutation producer, and mutation detector remain planned_not_materialized. executionImplemented is false and source binding V7 is not issued."
        )
    }()

    /// Freezes the non-authorizing process, evaluation, and receipt ownership
    /// records plus a narrow target-free schedule-delivery wire boundary.
    /// Every supervisor and worker remains planned and absent. V1 through V5
    /// remain exact historical contracts.
    public static let frozenV6: Self = {
        let previous = frozenV5
        let sourceCompositionTargetName =
            "PrimeNativeNeuralGateReplaySourceComposition"
        let rawWorkerTargetName =
            "PrimeNativeNeuralGateCorrectedRawWorker"
        let probeTargetName =
            "PrimeNativeNeuralGateReplayProbe"
        let verifierTargetName =
            "PrimeNativeNeuralGateReplayVerifier"
        let scheduleTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts"
        let processTargetName =
            "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts"
        let evaluationTargetName =
            "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts"
        let terminalTargetName =
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts"
        let deliveryAuthorityTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority"
        let probeEvaluationTargetName =
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker"
        let verifierEvaluationTargetName =
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker"

        var targets:
            [PrimeNativeNeuralGateTopologyTarget] =
            []
        for target in previous.targetGraph {
            switch target.targetName {
            case sourceCompositionTargetName:
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames
                            + [scheduleTargetName],
                        target.authority,
                        externalProducts:
                            target.externalProductDependencyNames
                    )
                )
                targets.append(
                    Self.target(
                        scheduleTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            "PrimeNativeNeuralGateReplayMechanics",
                            "PrimeNativeNeuralGateCorrectedMechanics",
                        ],
                        "pure bounded non-authorizing raw and outer target-free schedule wire contracts; raw slots admit only execution index, prompt bytes/tokens, PRIMECPI2 binding, and PRIMECOR1 while outer slots admit only execution index and PRIMECOR1"
                    )
                )
                targets.append(
                    Self.target(
                        processTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            scheduleTargetName,
                        ],
                        "non-authorizing ownership and record contracts for an exact symmetric 10-process topology: two supervisors, two swift-package describe children, two historical workers, two corrected raw workers, and two corrected evaluation workers"
                    )
                )
                targets.append(
                    Self.target(
                        evaluationTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            processTargetName,
                        ],
                        "non-authorizing probe/verifier corrected-evaluation ownership and result-binding contracts with no fixture, crosswalk, evaluator implementation, or receipt authority"
                    )
                )
                targets.append(
                    Self.target(
                        terminalTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayArtifactContracts",
                            processTargetName,
                            evaluationTargetName,
                        ],
                        "non-authorizing verifier-supervisor terminal-receipt ownership and exclusive no-replace receipt-last ordering contract; publication remains unimplemented and unauthorized"
                    )
                )
                targets.append(
                    Self.target(
                        deliveryAuthorityTargetName,
                        .implemented,
                        [
                            "PrimeNativeNeuralGateReplayCaptureInventory",
                            sourceCompositionTargetName,
                            scheduleTargetName,
                            processTargetName,
                            evaluationTargetName,
                        ],
                        "supervisor-only non-Codable adapter retaining the V5 exact-tree capture across pre/post recapture while binding content-derived target-free candidates to exact probe/verifier schedule owners; no delivery is observed"
                    )
                )
            case rawWorkerTargetName:
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames
                            .filter { $0 != "PrimeCore" }
                            + [
                                scheduleTargetName,
                                processTargetName,
                            ],
                        "separately launched prompt-only corrected raw executor consuming only the narrow target-free schedule and raw-process ownership contracts",
                        externalProducts:
                            target.externalProductDependencyNames
                    )
                )
                targets.append(
                    Self.target(
                        probeEvaluationTargetName,
                        .plannedNotMaterialized,
                        [
                            "PrimeCore",
                            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                            evaluationTargetName,
                        ],
                        "distinct trap-bearing probe corrected-evaluation worker; may bind expected targets and emit an evaluation result but cannot publish a terminal receipt"
                    )
                )
                targets.append(
                    Self.target(
                        verifierEvaluationTargetName,
                        .plannedNotMaterialized,
                        [
                            "PrimeCore",
                            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                            evaluationTargetName,
                        ],
                        "distinct trap-bearing verifier corrected-evaluation worker; may independently bind expected targets and emit an evaluation result but cannot publish a terminal receipt"
                    )
                )
            case probeTargetName:
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames
                            + [processTargetName],
                        "trap-free Stage-B probe supervisor bound only to target-free process ownership and transport records",
                        externalProducts:
                            target.externalProductDependencyNames
                    )
                )
            case verifierTargetName:
                targets.append(
                    Self.target(
                        target.targetName,
                        target.materialization,
                        target.directLocalDependencyNames
                            + [
                                processTargetName,
                                evaluationTargetName,
                                terminalTargetName,
                            ],
                        "target-blind Stage-B verifier supervisor and designated receipt-last owner; it consumes only typed process/evaluation records and cannot reach target-bearing evaluation implementation",
                        externalProducts:
                            target.externalProductDependencyNames
                    )
                )
            default:
                targets.append(target)
            }
        }

        func appendingUnique(
            _ base: [String],
            _ additions: [String]
        ) -> [String] {
            var result = base
            for addition in additions
            where !result.contains(addition) {
                result.append(addition)
            }
            return result
        }

        let allNewTargetNames = [
            scheduleTargetName,
            processTargetName,
            evaluationTargetName,
            terminalTargetName,
            deliveryAuthorityTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
        ]
        var reachability =
            previous.forbiddenReachability.map { rule in
                let additions: [String]
                switch rule.targetName {
                case sourceCompositionTargetName,
                     "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority":
                    additions = [
                        processTargetName,
                        evaluationTargetName,
                        terminalTargetName,
                        deliveryAuthorityTargetName,
                        probeEvaluationTargetName,
                        verifierEvaluationTargetName,
                    ]
                case probeTargetName:
                    additions = [
                        evaluationTargetName,
                        terminalTargetName,
                        deliveryAuthorityTargetName,
                        probeEvaluationTargetName,
                        verifierEvaluationTargetName,
                    ]
                case verifierTargetName:
                    additions = [
                        deliveryAuthorityTargetName,
                        probeEvaluationTargetName,
                        verifierEvaluationTargetName,
                    ]
                case rawWorkerTargetName:
                    additions = [
                        "PrimeCore",
                        "PrimeNativeNeuralGateReplayTransport",
                        "PrimeNativeNeuralGateReplayComposition",
                        "PrimeNativeNeuralGateReplaySourceBinding",
                        sourceCompositionTargetName,
                        evaluationTargetName,
                        terminalTargetName,
                        deliveryAuthorityTargetName,
                        probeEvaluationTargetName,
                        verifierEvaluationTargetName,
                        "PrimeNativeNeuralGateCorrectedMutationProducer",
                        "PrimeNativeNeuralGateCorrectedMutationDetector",
                    ]
                default:
                    additions = allNewTargetNames
                }
                return Self.forbidden(
                    rule.targetName,
                    appendingUnique(
                        rule.forbiddenReachableTargetNames,
                        additions
                    )
                )
            }

        for reverseProtectedTargetName in [
            "PrimeCore",
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateReplayMechanics",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        ] {
            reachability.append(
                Self.forbidden(
                    reverseProtectedTargetName,
                    allNewTargetNames
                )
            )
        }
        let rawProcessForbidden = [
            "PrimeCore",
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateReplayComposition",
            "PrimeNativeNeuralGateReplaySourceBinding",
            sourceCompositionTargetName,
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            evaluationTargetName,
            terminalTargetName,
            deliveryAuthorityTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        ]
        reachability.append(
            Self.forbidden(
                scheduleTargetName,
                appendingUnique(
                    rawProcessForbidden,
                    [
                        processTargetName,
                        evaluationTargetName,
                        terminalTargetName,
                        deliveryAuthorityTargetName,
                    ]
                )
            )
        )
        reachability.append(
            Self.forbidden(
                processTargetName,
                rawProcessForbidden
            )
        )
        reachability.append(
            Self.forbidden(
                evaluationTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                    "PrimeNativeNeuralGateReplayComposition",
                    "PrimeNativeNeuralGateReplaySourceBinding",
                    sourceCompositionTargetName,
                    deliveryAuthorityTargetName,
                    "PrimeNativeNeuralGateReplayCaptureInventory",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    terminalTargetName,
                    probeEvaluationTargetName,
                    verifierEvaluationTargetName,
                    "PrimeNativeNeuralGateCorrectedMutationProducer",
                    "PrimeNativeNeuralGateCorrectedMutationDetector",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                terminalTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                    "PrimeNativeNeuralGateReplayComposition",
                    "PrimeNativeNeuralGateReplaySourceBinding",
                    sourceCompositionTargetName,
                    deliveryAuthorityTargetName,
                    "PrimeNativeNeuralGateReplayCaptureInventory",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    probeEvaluationTargetName,
                    verifierEvaluationTargetName,
                    "PrimeNativeNeuralGateCorrectedMutationProducer",
                    "PrimeNativeNeuralGateCorrectedMutationDetector",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                deliveryAuthorityTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    terminalTargetName,
                    probeEvaluationTargetName,
                    verifierEvaluationTargetName,
                    "PrimeNativeNeuralGateCorrectedMutationProducer",
                    "PrimeNativeNeuralGateCorrectedMutationDetector",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                ]
            )
        )
        let evaluationWorkerForbidden = [
            terminalTargetName,
            deliveryAuthorityTargetName,
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        ]
        reachability.append(
            Self.forbidden(
                probeEvaluationTargetName,
                appendingUnique(
                    evaluationWorkerForbidden,
                    [verifierEvaluationTargetName]
                )
            )
        )
        reachability.append(
            Self.forbidden(
                verifierEvaluationTargetName,
                appendingUnique(
                    evaluationWorkerForbidden,
                    [probeEvaluationTargetName]
                )
            )
        )

        return Self(
            schemaVersion: 6,
            contractID:
                "prime_stage_b_process_evaluation_receipt_ownership_target_free_delivery_topology_v6",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred: true,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "freeze_typed_source_pinned_worker_and_role_artifact_references_with_common_capture_schedule_binding_and_bounded_candidate_stream_decoder_then_freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers",
            authorityStatement:
                "This V6 contract preserves V1 through V5 and the historical V5/V6 replay identities while materializing four non-authorizing declaration targets plus one isolated supervisor-only retained-capture delivery authority. The raw-safe schedule target uses byte-capped slot decoding and content-derived candidate identities but intentionally exposes no aggregate candidate decoder. The isolated authority retains the V5 exact-tree capability across pre/post recapture and binds the source-derived schedule to exact probe/verifier ownership without entering the raw-worker closure. Separate process, evaluation, and receipt declarations freeze an exact symmetric 10-process future topology and designate the verifier supervisor as receipt-last owner without materializing any process. The corrected raw worker drops PrimeCore and may reach only raw mechanics plus target-free schedule/process contracts. Distinct probe and verifier corrected-evaluation workers remain planned and trap-bearing; neither may publish the terminal receipt. No process delivery, model execution, evaluation, verdict, mechanics PASS, receipt publication, mutation execution/detection, scientific authority, or product authority is observed or authorized. Historical runtime, every supervisor and worker, mutation producer, and mutation detector remain planned_not_materialized. executionImplemented is false and source binding V7 is not issued."
        )
    }()

    /// Adds exact-count framed target-free stream admission plus typed,
    /// non-authorizing worker and role-artifact references. Every referenced
    /// worker, executable, process, and artifact remains absent. V1 through
    /// V6 remain exact historical contracts.
    public static let frozenV7: Self = {
        let previous = frozenV6
        let scheduleTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts"
        let referenceContractsTargetName =
            "PrimeNativeNeuralGateRoleArtifactReferenceContracts"
        let referenceAuthorityTargetName =
            "PrimeNativeNeuralGateRoleArtifactReferenceAuthority"

        var targets = previous.targetGraph.map { target in
            guard target.targetName == scheduleTargetName
            else {
                return target
            }
            return Self.target(
                target.targetName,
                target.materialization,
                target.directLocalDependencyNames,
                "pure bounded non-authorizing raw and outer target-free schedule contracts with strict slot decoding and exact-18432-record incremental PRIMEIRM1 stream admission; aggregate candidates remain non-Decodable",
                externalProducts:
                    target.externalProductDependencyNames
            )
        }
        targets.append(
            Self.target(
                referenceContractsTargetName,
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    scheduleTargetName,
                    "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                    "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                    "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
                ],
                "pure Encodable-only common capture/schedule, six-worker typed Release source-reference schema, and exact ten-role/twenty-path content-reference contracts; actual worker closures, executables, and artifact content remain unobserved"
            )
        )
        targets.append(
            Self.target(
                referenceAuthorityTargetName,
                .implemented,
                [
                    referenceContractsTargetName,
                    "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                    "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                    scheduleTargetName,
                ],
                "supervisor-only non-Codable adapter retaining the held replay capture across pre/post recapture while deriving copied common and branch schedule references; no artifact or process delivery is observed"
            )
        )

        func appendingUnique(
            _ base: [String],
            _ additions: [String]
        ) -> [String] {
            var result = base
            for addition in additions
            where !result.contains(addition) {
                result.append(addition)
            }
            return result
        }

        let newTargetNames = [
            referenceContractsTargetName,
            referenceAuthorityTargetName,
        ]
        var reachability = previous.forbiddenReachability.map {
            rule in
            Self.forbidden(
                rule.targetName,
                appendingUnique(
                    rule.forbiddenReachableTargetNames,
                    newTargetNames
                )
            )
        }
        reachability.append(
            Self.forbidden(
                referenceContractsTargetName,
                [
                    "PrimeCore",
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                    "PrimeNativeNeuralGateReplayComposition",
                    "PrimeNativeNeuralGateReplaySourceBinding",
                    "PrimeNativeNeuralGateReplaySourceComposition",
                    "PrimeNativeNeuralGateReplayCaptureInventory",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                    referenceAuthorityTargetName,
                    "PrimeNativeNeuralGateCorrectedMutationProducer",
                    "PrimeNativeNeuralGateCorrectedMutationDetector",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                referenceAuthorityTargetName,
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                    "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                    "PrimeNativeNeuralGateCorrectedMutationProducer",
                    "PrimeNativeNeuralGateCorrectedMutationDetector",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                ]
            )
        )

        return Self(
            schemaVersion: 7,
            contractID:
                "prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation",
            mutationProducerDetectorTargetAssignmentDeferred: true,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers",
            authorityStatement:
                "This V7 topology preserves V1 through V6 and adds only exact-count bounded PRIMEIRM1 target-free stream admission, pure typed copied-reference contracts, and a supervisor-only retained-capture reference adapter. The six worker declarations require typed Release source snapshot, package-description, compiled-closure, and sealed-executable references bound to the common capture/schedule identity, but all actual values remain absent: no missing target is treated as a compiled closure, and no executable digest, vnode, PID, or same-process observation is fabricated. The exact twenty corrected pre-receipt paths can be bound by role, path, content, and one common capture/schedule identity, but no artifact is materialized and copied identities never become capture authority. Every supervisor and worker remains planned_not_materialized. No process delivery, model execution, evaluation, mutation execution or detection, verdict, mechanics PASS, receipt publication, source binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Freezes the previously deferred semantic-record boundary and a
    /// label-free surface boundary, then materializes two mutually disjoint
    /// corrected-mutation mechanics targets. These are internal library
    /// targets, not worker executables or processes. Every role-scoped worker
    /// and supervisor remains absent, and V1 through V7 remain exact history.
    public static let frozenV8: Self = {
        let previous = frozenV7
        let surfaceTargetName =
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts"
        let semanticTargetName =
            "PrimeNativeNeuralGateSemanticRecordContracts"
        let producerTargetName =
            "PrimeNativeNeuralGateCorrectedMutationProducer"
        let detectorTargetName =
            "PrimeNativeNeuralGateCorrectedMutationDetector"

        var targets = previous.targetGraph
        targets.append(
            Self.target(
                surfaceTargetName,
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                "pure label-free presence-only corrected-control surface contracts plus canonical bounded bytes and SHA/SZ binding; no mutation catalog, mutation identity, expected-leg mapping, implementation, process, execution, PASS, receipt, science, or product authority"
            )
        )
        targets.append(
            Self.target(
                semanticTargetName,
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    surfaceTargetName,
                ],
                "pure non-authorizing semantic records, including mutation catalog and identity mapping over the label-free surface contract, historical observation, MLX digest observation, corrected statistics, and count-derived verdict values; no mutation implementation, process, execution, PASS, receipt, science, or product authority"
            )
        )
        targets.append(
            Self.target(
                producerTargetName,
                .implemented,
                [semanticTargetName, surfaceTargetName],
                "internal corrected fifteen-case mutation-production mechanics over the frozen semantic catalog and label-free control surface; no detector, worker, process, delivery, execution-evidence, evaluation, verdict, PASS, receipt, science, or product authority"
            )
        )
        targets.append(
            Self.target(
                detectorTargetName,
                .implemented,
                [surfaceTargetName],
                "independently implemented structurally label-blind corrected-control detector over only the presence-only surface contract; it cannot reach semantic catalog or identity mapping, artifact catalogs, mutation production, evaluation, PASS, receipt, science, or product use"
            )
        )

        func appendingUnique(
            _ base: [String],
            _ additions: [String]
        ) -> [String] {
            var result = base
            for addition in additions
            where !result.contains(addition) {
                result.append(addition)
            }
            return result
        }

        let newTargetNames = [
            surfaceTargetName,
            semanticTargetName,
            producerTargetName,
            detectorTargetName,
        ]

        // At this boundary no pre-existing target may acquire any new
        // semantic/surface contract or mutation implementation through a
        // transitive dependency. A later worker-materialization topology must
        // replace this rule explicitly.
        var reachability = previous.forbiddenReachability.map {
            rule in
            Self.forbidden(
                rule.targetName,
                appendingUnique(
                    rule.forbiddenReachableTargetNames,
                    newTargetNames
                )
            )
        }
        let existingRuleTargetNames = Set(
            reachability.map(\.targetName)
        )
        for target in previous.targetGraph
        where !existingRuleTargetNames.contains(
            target.targetName
        ) {
            reachability.append(
                Self.forbidden(
                    target.targetName,
                    newTargetNames
                )
            )
        }

        let previousTargetNames = previous.targetGraph.map(
            \.targetName
        )
        let replayMechanicsTargetName =
            "PrimeNativeNeuralGateReplayMechanics"
        let replayArtifactTargetName =
            "PrimeNativeNeuralGateReplayArtifactContracts"
        reachability.append(
            Self.forbidden(
                surfaceTargetName,
                previousTargetNames.filter {
                    $0 != replayMechanicsTargetName
                } + [
                    semanticTargetName,
                    producerTargetName,
                    detectorTargetName,
                ]
            )
        )
        reachability.append(
            Self.forbidden(
                semanticTargetName,
                previousTargetNames.filter {
                    $0 != replayMechanicsTargetName
                        && $0 != replayArtifactTargetName
                } + [producerTargetName, detectorTargetName]
            )
        )
        reachability.append(
            Self.forbidden(
                producerTargetName,
                previousTargetNames.filter {
                    $0 != replayMechanicsTargetName
                        && $0 != replayArtifactTargetName
                } + [detectorTargetName]
            )
        )
        reachability.append(
            Self.forbidden(
                detectorTargetName,
                previousTargetNames.filter {
                    $0 != replayMechanicsTargetName
                } + [
                    semanticTargetName,
                    producerTargetName,
                ]
            )
        )

        return Self(
            schemaVersion: 8,
            contractID:
                "prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v8_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7",
            authorityStatement:
                "This V8 topology preserves V1 through V7 and adds only one pure label-free corrected-control surface target, one semantic-record target, and two internal mutually unreachable corrected-mutation mechanics targets. The producer may reach the semantic catalog/identity mapping and label-free surface. The independently implemented detector may reach only the label-free surface and replay mechanics: it is structurally unable to reach semantic catalog or identity mapping, artifact catalogs, expected-leg mappings, or mutation production. Neither implementation may reach evaluation or fixture authority, the prompt-target crosswalk, MLX, retained delivery/reference authority, terminal receipt ownership, historical runtime, or any supervisor or worker. Their package materialization is not Stage-B execution evidence: every supervisor, worker, executable, process, delivery, artifact observation, durable or process-scoped mutation execution/detection observation, evaluation, verdict, mechanics PASS, receipt publication, source/execution-binding V7, scientific authority, and product authority remains absent or unauthorized. The next bounded prerequisite is the source-derived historical gate/carrier seam and exact forty-six-mutation raw material; it must not hand-port donor behavior or materialize workers."
        )
    }()

    /// Adds only an offline, in-memory historical source-derivation target.
    /// It consumes caller-supplied bytes, validates the frozen donor pins,
    /// and derives inert carrier/seam/mutation source material. No historical
    /// replay target, worker, process, executable, or artifact publication is
    /// materialized.
    public static let frozenV9: Self = {
        let previous = frozenV8
        let derivationTargetName =
            "PrimeNativeNeuralGateHistoricalSourceDerivation"
        var targets = previous.targetGraph
        targets.append(
            Self.target(
                derivationTargetName,
                .implemented,
                [
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                "offline caller-byte-only LF source derivation for the exact pinned historical gate/carrier seam and direct forty-six-mutation source material; no filesystem or Git transport, per-case parser, executable transform binding, detector, worker, process, execution observation, durable publication, PASS, receipt, source binding V7, science, or product authority"
            )
        )

        func appendingUnique(
            _ base: [String],
            _ addition: String
        ) -> [String] {
            base.contains(addition)
                ? base
                : base + [addition]
        }

        var reachability =
            previous.forbiddenReachability.map { rule in
                Self.forbidden(
                    rule.targetName,
                    appendingUnique(
                        rule.forbiddenReachableTargetNames,
                        derivationTargetName
                    )
                )
            }
        let priorRuleTargets = Set(
            reachability.map(\.targetName)
        )
        for target in previous.targetGraph
        where !priorRuleTargets.contains(target.targetName) {
            reachability.append(
                Self.forbidden(
                    target.targetName,
                    [derivationTargetName]
                )
            )
        }
        let permitted = Set([
            "PrimeNativeNeuralGateReplayMechanics",
        ])
        reachability.append(
            Self.forbidden(
                derivationTargetName,
                previous.targetGraph.map(\.targetName)
                    .filter { !permitted.contains($0) }
            )
        )

        return Self(
            schemaVersion: 9,
            contractID:
                "prime_stage_b_source_pinned_historical_gate_carrier_mutation_material_topology_v9",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v9_source_material_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "author_and_source_bind_prime_historical_observation_seam_and_materialize_historical_replay_mechanics_without_materializing_workers_or_issuing_source_binding_v7",
            authorityStatement:
                "This V9 topology preserves V1 through V8 and adaptation proof V2 while adding only one offline internal Swift source-derivation target and additive adaptation proof V3. V3 corrects the future gate and carrier destinations from the pure replay substrate to the still-unmaterialized historical replay target. The derivation target depends only on the pure replay codec, accepts only caller-supplied bytes, validates the exact pinned gate and carrier identities, and derives the bounded carrier declaration, native gate/carrier construction use, and exact six-group direct source material containing the historical forty-six-mutation declarations and transforms. The source includes the donor's same-family named-leg dispatch; it is not independent detection. No PrimeCore, per-case parser, executable transform binding, exact failure-set derivation, historical invariant reconstruction, SZ/statistics/triad verdict, filesystem or Git transport, historical runtime/replay target, supervisor, worker, executable, process, model/Metal execution, durable observation, mechanics PASS, receipt, source/execution-binding V7, scientific authority, or product authority is present or authorized."
        )
    }()

    /// Materializes only the exact source-pinned historical runtime and
    /// historical replay-mechanics libraries. The gate, carrier, and
    /// Prime-owned observation seam compile, but no worker, executable, or
    /// process is materialized and no gate invocation, model execution, or
    /// durable evidence has been executed or observed.
    public static let frozenV10: Self = {
        let previous = frozenV9
        let runtimeTargetName =
            previous.historicalRuntimeTargetName
        let historicalTargetName =
            previous.historicalReplayTargetName
        let pureReplayTargetName =
            previous.pureReplayTargetName

        let targets = previous.targetGraph.map { target in
            switch target.targetName {
            case runtimeTargetName:
                Self.target(
                    runtimeTargetName,
                    .implemented,
                    [],
                    "exact seven-file source-pinned Ergentics historical runtime authority; contains historical filesystem-capable and trap-bearing APIs, has no product or executable, and is reachable only from the isolated historical replay and still-planned historical worker closures"
                )
            case historicalTargetName:
                Self.target(
                    historicalTargetName,
                    .implemented,
                    [
                        runtimeTargetName,
                        pureReplayTargetName,
                    ],
                    "exact byte-pinned native gate, V9-derived bounded verdict carrier, and Prime-authored in-memory assessment observation seam; compile-only source closure with Prime admission forced to ABSTAIN and no worker, process, execution observation, durable publication, PASS, receipt, source binding V7, science, or product authority"
                )
            default:
                target
            }
        }

        func appendingUnique(
            _ base: [String],
            _ additions: [String]
        ) -> [String] {
            additions.reduce(base) { result, name in
                result.contains(name)
                    ? result
                    : result + [name]
            }
        }

        var reachability = previous.forbiddenReachability
            .filter {
                $0.targetName != runtimeTargetName
                    && $0.targetName != historicalTargetName
            }
            .map { rule in
                guard rule.targetName
                        != previous
                        .historicalContainmentRootTargetName
                else {
                    return rule
                }
                return Self.forbidden(
                    rule.targetName,
                    appendingUnique(
                        rule.forbiddenReachableTargetNames,
                        [
                            runtimeTargetName,
                            historicalTargetName,
                        ]
                    )
                )
            }
        let allTargetNames = targets.map(\.targetName)
        reachability.append(
            Self.forbidden(
                runtimeTargetName,
                allTargetNames.filter {
                    $0 != runtimeTargetName
                }
            )
        )
        let historicalPermitted = Set([
            runtimeTargetName,
            pureReplayTargetName,
        ])
        reachability.append(
            Self.forbidden(
                historicalTargetName,
                allTargetNames.filter {
                    $0 != historicalTargetName
                        && !historicalPermitted.contains($0)
                }
            )
        )

        return Self(
            schemaVersion: 10,
            contractID:
                "prime_stage_b_source_bound_historical_replay_mechanics_topology_v10",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                runtimeTargetName,
            historicalReplayTargetName:
                historicalTargetName,
            pureReplayTargetName:
                pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v10_historical_execution_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7",
            authorityStatement:
                "This V10 topology preserves V1 through V9 and materializes only two previously planned internal library targets: the exact seven-file Ergentics historical runtime authority and the isolated historical replay mechanics target containing the byte-exact native gate, V9-derived bounded carrier, and Prime-authored observation seam. The historical replay target depends only on that runtime and the pure replay codec; no current product, executable, supervisor, corrected path, source-binding path, or worker can reach either historical target. The observation seam accepts in-memory Materials only, excludes filesystem URLs and nondeterministic phase timing, explicitly marks private invariant/per-mutation details unavailable, and forces the Prime admission disposition to ABSTAIN. The compiled historical code retains known trap and filesystem-capable APIs, so package materialization is not execution evidence. No historical fixture or worker, gate or model execution, process, durable observation, independent detector, distinct-family/four-tier audit, mechanics PASS, receipt, source/execution-binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Adds the exact source-derived historical fixture to the already
    /// isolated historical replay module and materializes only the future
    /// fresh-process worker executable target. The target exists so its
    /// source closure can be compiled and inspected; no worker image is
    /// sealed, launched, or accepted as evidence at this boundary.
    public static let frozenV11: Self = {
        let previous = frozenV10
        let historicalTargetName =
            previous.historicalReplayTargetName
        let workerTargetName =
            previous.historicalContainmentRootTargetName

        let targets = previous.targetGraph.map { target in
            switch target.targetName {
            case historicalTargetName:
                Self.target(
                    target.targetName,
                    target.materialization,
                    target.directLocalDependencyNames,
                    "V10 exact historical gate, bounded verdict carrier, and Prime observation seam plus the exact 88,141-byte source-derived historical fixture routed into the same module for lawful access to internal donor declarations; compile-only historical source closure with Prime admission forced to ABSTAIN and no process, durable publication, PASS, receipt, source binding V7, science, or product authority"
                )
            case workerTargetName:
                Self.target(
                    target.targetName,
                    .implemented,
                    target.directLocalDependencyNames,
                    "internal executable target for a future sealed fresh-process historical fixture worker; binds the exact source-derived fixture and V10 observation seam but has no product, sealed image, invocation, process observation, artifact publication, mechanics PASS, receipt, source binding V7, science, or product authority"
                )
            default:
                target
            }
        }

        return Self(
            schemaVersion: 11,
            contractID:
                "prime_stage_b_source_bound_historical_fixture_worker_topology_v11",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability:
                previous.forbiddenReachability,
            historicalContainmentRootTargetName:
                workerTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                historicalTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_not_v11_worker_execution_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V11 topology preserves V1 through V10, retains the exact V10 runtime, gate, carrier, observation seam, and pure replay sources, and adds only the exact source-derived 88,141-byte historical fixture to the existing isolated historical replay module. Same-module placement is required because the source-faithful fixture accesses internal declarations of the byte-exact gate; no donor access level is changed. V11 also materializes only the package-internal historical worker executable target with its previously frozen four direct dependencies. Compilation and a future invocation call edge are not a sealed executable observation or execution evidence. The gate still does not publicly expose invariant records, per-mutation fingerprints, or observed failed-leg sets, so this worker target cannot yet satisfy the complete frozen historical-worker artifact protocol. Every probe, verifier, corrected worker, and remaining execution role stays absent. No worker image sealing or launch, process, gate or model execution, durable observation, independent detector, distinct-family/four-tier audit, mechanics PASS, terminal receipt, source/execution-binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Preserves the complete V11 package graph while source-binding only the
    /// exact namespace basis and semantic requirements for a future isolated
    /// historical evidence-export variant. The derived source, target,
    /// exporter suffix, Materials bridge, and worker call edge remain absent.
    public static let frozenV12: Self = {
        let previous = frozenV11
        return Self(
            schemaVersion: 12,
            contractID:
                "prime_stage_b_source_bound_historical_evidence_export_adapter_topology_v12",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID:
                        "prime_source_bound_historical_evidence_export_adapter_design_v12",
                    contentSHA256:
                        "e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d"
                ),
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: previous.targetGraph,
            forbiddenReachability:
                previous.forbiddenReachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_design_prime_source_bound_historical_evidence_export_adapter_design_v12_sha256_e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d_not_derived_export_variant_worker_execution_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "materialize_the_exact_source_bound_historical_evidence_export_variant_in_the_isolated_historical_replay_boundary_without_executing_the_gate_or_worker_sealing_or_launching_a_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V12 topology preserves V1 through V11 and leaves the complete V11 target graph, materialization states, dependencies, and forbidden reachability unchanged. It binds PrimeCore design contract prime_source_bound_historical_evidence_export_adapter_design_v12 at canonical SHA-256 e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d. That design contract records why a thin wrapper cannot recover the pinned gate's lexically private and discarded invariant, fingerprint, and failed-leg intermediates; rejects reflection, access relaxation, expected-leg substitution, and a compact hand-reconstruction kernel; source-binds the exact 368,953-byte two-rewrite whole-gate internal namespace basis; freezes exact singleton allowed-failure policy separately from complete observed regrade sets; identity-binds all twelve Materials initializer inputs; and freezes role-neutral, path-free, timing-free, non-Codable semantics for a later same-file instrumented variant. The exporter suffix and final derived source identity remain deliberately unbound, so no derived source, target, Materials bridge implementation, worker call edge, process, mutation, gate/model execution, or historical evidence is present. The existing worker main remains unavailable with status 78. No durable publication, independent detector, distinct-family/four-tier audit, mechanics PASS, terminal receipt, source/execution-binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Materializes only the source-bound historical evidence exporter as a
    /// package-internal library. The exporter remains unreachable from every
    /// current product and executable, and neither it nor the historical gate
    /// or worker is invoked at this boundary.
    public static let frozenV13: Self = {
        let previous = frozenV12
        let exporterTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
        let allowedExporterClosure = Set([
            previous.historicalRuntimeTargetName,
            previous.pureReplayTargetName,
            previous.historicalReplayTargetName,
        ])
        var targets = previous.targetGraph
        targets.append(
            target(
                exporterTargetName,
                .implemented,
                [
                    previous.historicalRuntimeTargetName,
                    previous.pureReplayTargetName,
                    previous.historicalReplayTargetName,
                ],
                "source-bound append-only historical evidence-export variant with an exact twelve-field in-memory Materials bridge and nine-field non-Codable authority-free carrier; compile-only package-internal library with no product, worker call edge, process, gate invocation, evidence publication, PASS, receipt, source binding V7, science, or product authority"
            )
        )
        var reachability =
            previous.forbiddenReachability.map { rule in
                forbidden(
                    rule.targetName,
                    rule.forbiddenReachableTargetNames
                        + [exporterTargetName]
                )
            }
        reachability.append(
            forbidden(
                exporterTargetName,
                previous.targetGraph.map(\.targetName)
                    .filter {
                        !allowedExporterClosure.contains($0)
                    }
            )
        )

        return Self(
            schemaVersion: 13,
            contractID:
                "prime_stage_b_source_bound_historical_evidence_export_source_topology_v13",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                previous
                .historicalEvidenceExportDesignContractBinding,
            historicalEvidenceExportSourceContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID:
                        "prime_source_bound_historical_evidence_export_source_v13",
                    contentSHA256:
                        "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"
                ),
            historicalEvidenceExportTargetName:
                exporterTargetName,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_source_prime_source_bound_historical_evidence_export_source_v13_sha256_ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e_not_exporter_or_worker_execution_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "source_bind_the_historical_worker_evidence_export_call_edge_without_sealing_launching_or_executing_the_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V13 topology preserves V1 through V12 and materializes exactly one package-internal library target for source-bound historical evidence export. The target contains the exact 412,226-byte whole-gate namespace variant, depends only on ErgenticsPrimeRuntime, the pure replay codec, and the already isolated historical replay mechanics, and is not declared as a product. Every pre-existing target is forbidden from reaching the exporter, while the exporter may reach only its exact three-target dependency closure. The historical worker source, dependencies, call graph, unavailable main, and copied resource remain unchanged and the worker does not depend on or invoke the exporter. The exporter facade accepts only in-memory historical Materials, validates the exact seed catalog before non-trapping row-cache construction, and returns a non-Codable, role-neutral, path-free, timing-free, authority-free carrier. Package compilation is source evidence only. No exporter, worker, fixture, mutation, gate, model, process, or Metal workload executes; no historical evidence, durable publication, independent detector, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Source- and compile-binds one private historical worker-to-exporter
    /// call edge while preserving the unavailable worker entry point. No
    /// request handling, worker execution, encoding, or publication is
    /// reachable or observed at this boundary.
    public static let frozenV14: Self = {
        let previous = frozenV13
        let workerTargetName =
            previous.historicalContainmentRootTargetName
        let exporterTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
        let targets = previous.targetGraph.map { target in
            guard target.targetName == workerTargetName else {
                return target
            }
            return Self.target(
                target.targetName,
                target.materialization,
                target.directLocalDependencyNames
                    + [exporterTargetName],
                "internal executable target whose unchanged V11 main remains unavailable with status 78; V14 appends only the source-bound historical evidence exporter dependency and a separately pinned private cross-file materialize-to-export call edge that main cannot name; compile-only with no request handling, sealing, launch, execution, encoding, publication, PASS, receipt, source binding V7, science, or product authority",
                externalProducts:
                    target.externalProductDependencyNames
            )
        }
        let reachability =
            previous.forbiddenReachability.map { rule in
                guard rule.targetName == workerTargetName else {
                    return rule
                }
                return Self.forbidden(
                    rule.targetName,
                    rule.forbiddenReachableTargetNames
                        .filter { $0 != exporterTargetName }
                )
            }

        return Self(
            schemaVersion: 14,
            contractID:
                "prime_stage_b_historical_worker_evidence_export_call_edge_source_topology_v14",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                previous
                .historicalEvidenceExportDesignContractBinding,
            historicalEvidenceExportSourceContractBinding:
                previous
                .historicalEvidenceExportSourceContractBinding,
            historicalWorkerEvidenceExportCallEdgeSourceContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID:
                        "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
                    contentSHA256:
                        "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"
                ),
            historicalEvidenceExportTargetName:
                previous.historicalEvidenceExportTargetName,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                workerTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_source_prime_source_bound_historical_worker_evidence_export_call_edge_v14_sha256_8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8_not_worker_request_handling_sealing_launch_execution_evidence_projection_publication_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "design_and_source_bind_the_historical_evidence_carrier_to_frozen_worker_semantic_artifact_projection_without_enabling_worker_request_handling_sealing_launch_execution_or_issuing_source_binding_v7",
            authorityStatement:
                "This V14 topology preserves V1 through V13 and changes only the existing product-free historical worker target. Its exact four V11 direct dependencies remain an ordered prefix and the existing V13 historical evidence exporter is appended once. One separately pinned Swift extension contains a private Bundle.module Package.resolved lookup, source-faithful historical fixture materialization, and typed exporter call. The exact V11 primary worker source remains unchanged; main exits unconditionally with status 78 and cannot name that private cross-file member. Every other target, dependency, materialization state, and forbidden-reachability rule remains exact; only the worker's V13 prohibition against reaching the exporter is removed, while the exporter still cannot reach the worker. Compilation proves only the typed call edge. No request handling, sealing, launch, worker/fixture/exporter/gate/model execution, evidence observation, encoding, durable publication, independent detection, distinct implementation family, AgentContractKit four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Source-binds the exact carrier-to-semantic-artifact projection design
    /// and its three fail-closed blockers while preserving the complete V14
    /// package graph and unavailable worker. No projector source or target is
    /// materialized at this boundary.
    public static let frozenV15: Self = {
        let previous = frozenV14

        return Self(
            schemaVersion: 15,
            contractID:
                "prime_stage_b_historical_evidence_semantic_artifact_projection_design_topology_v15",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                previous
                .historicalEvidenceExportDesignContractBinding,
            historicalEvidenceExportSourceContractBinding:
                previous
                .historicalEvidenceExportSourceContractBinding,
            historicalWorkerEvidenceExportCallEdgeSourceContractBinding:
                previous
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            historicalEvidenceSemanticArtifactProjectionDesignContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID:
                        "prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15",
                    contentSHA256:
                        "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27"
                ),
            historicalEvidenceExportTargetName:
                previous.historicalEvidenceExportTargetName,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: previous.targetGraph,
            forbiddenReachability:
                previous.forbiddenReachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_design_prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15_sha256_2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27_not_projection_codec_target_worker_request_handling_sealing_launch_execution_encoding_publication_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                "freeze_the_complete_non_authorizing_historical_semantic_artifact_namespace_and_additive_keyed_three_seed_statistics_envelope_then_source_bind_a_historical_only_projection_codec_without_enabling_worker_request_handling_sealing_launch_execution_publication_or_issuing_source_binding_v7",
            authorityStatement:
                "This V15 topology preserves the complete V14 target graph, dependency order, materialization state, and forbidden reachability byte-for-byte. It binds only the PrimeCore carrier-to-semantic-artifact projection design. That design maps all nine V13 carrier fields to exact artifact-set destinations and proves three blockers: all three existing V4 historical specifications remain schema-deferred while nineteen required artifacts per role are absent, the carrier's three keyed seed-specific statistics families cannot enter the singular V8 statistics schema without an additive keyed envelope, and the current semantic-record target reaches the corrected mutation surface forbidden from the historical worker closure. No projection source or target is materialized, no semantic or corrected-mechanics dependency reaches the historical worker, and the V11 main remains unavailable with status 78. No request handling, sealing, launch, worker/exporter/gate/model execution, encoding, publication, durable evidence, independent detection, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    /// Materializes the complete non-authorizing historical namespace, the
    /// lossless keyed three-seed statistics envelope, the corrected mutation-
    /// record split, and one pure historical projection codec. The worker
    /// remains unchanged and unavailable; it cannot reach the projector.
    public static let frozenV16: Self = {
        let previous = frozenV15
        let source =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
            .frozenV1
        let sourceSHA256 = try! source.contentSHA256()
        let semanticTargetName =
            "PrimeNativeNeuralGateSemanticRecordContracts"
        let mutationRecordTargetName =
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts"
        let producerTargetName =
            "PrimeNativeNeuralGateCorrectedMutationProducer"
        let surfaceTargetName =
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts"
        let projectorTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        let replayArtifactTargetName =
            "PrimeNativeNeuralGateReplayArtifactContracts"
        let replayMechanicsTargetName =
            "PrimeNativeNeuralGateReplayMechanics"
        let exporterTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"

        var targets = previous.targetGraph.map { target in
            switch target.targetName {
            case semanticTargetName:
                Self.target(
                    target.targetName,
                    target.materialization,
                    [
                        replayArtifactTargetName,
                        replayMechanicsTargetName,
                    ],
                    "pure historical-safe and corrected non-authorizing semantic records after the byte-exact corrected mutation-record source moved to its own target; live historical observed-failure validation uses frozen historical critical-leg-domain membership so uppercase NL identifiers are preserved and unknown identifiers rejected without changing V8 canonical bytes; no corrected mutation surface, implementation, worker, process, execution, evidence, PASS, receipt, science, or product authority",
                    externalProducts:
                        target.externalProductDependencyNames
                )
            case producerTargetName:
                Self.target(
                    target.targetName,
                    target.materialization,
                    [
                        mutationRecordTargetName,
                        surfaceTargetName,
                    ],
                    "internal corrected fifteen-case mutation-production mechanics over the byte-exact corrected mutation-record target and label-free control surface; no historical semantic projector, detector, worker, process, execution-evidence, evaluation, verdict, PASS, receipt, science, or product authority",
                    externalProducts:
                        target.externalProductDependencyNames
                )
            default:
                target
            }
        }
        targets.append(
            Self.target(
                mutationRecordTargetName,
                .implemented,
                [
                    replayArtifactTargetName,
                    replayMechanicsTargetName,
                    surfaceTargetName,
                ],
                "byte-exact relocated corrected mutation catalog and identity records; no historical projector, mutation implementation, detector, worker, process, execution, evidence, PASS, receipt, science, or product authority"
            )
        )
        targets.append(
            Self.target(
                projectorTargetName,
                .implemented,
                [
                    exporterTargetName,
                    replayArtifactTargetName,
                    replayMechanicsTargetName,
                    semanticTargetName,
                ],
                "package-internal pure in-memory historical carrier-to-semantic-artifact projection codec with complete non-authorizing namespace, lossless keyed three-seed statistics, and exact reconstruction before omission of only deterministically redundant fingerprint fields; synthetic tests exercise component mechanics only while the public project entry point remains runtime-unexercised, and no worker, ReplayTransport, filesystem, publication, execution, PASS, receipt, source binding V7, science, or product authority is integrated or authorized"
            )
        )

        func appendingUnique(
            _ base: [String],
            _ additions: [String]
        ) -> [String] {
            var result = base
            for addition in additions
            where !result.contains(addition) {
                result.append(addition)
            }
            return result
        }

        var reachability = previous.forbiddenReachability.map {
            rule in
            Self.forbidden(
                rule.targetName,
                appendingUnique(
                    rule.forbiddenReachableTargetNames,
                    rule.targetName == producerTargetName
                        ? [projectorTargetName]
                        : [
                            mutationRecordTargetName,
                            projectorTargetName,
                        ]
                )
            )
        }
        let priorRuleTargetNames = Set(
            reachability.map(\.targetName)
        )
        for target in previous.targetGraph
        where !priorRuleTargetNames.contains(target.targetName) {
            reachability.append(
                Self.forbidden(
                    target.targetName,
                    target.targetName == producerTargetName
                        ? [projectorTargetName]
                        : [
                            mutationRecordTargetName,
                            projectorTargetName,
                        ]
                )
            )
        }

        let allTargetNames = targets.map(\.targetName)
        let mutationRecordAllowed = Set([
            mutationRecordTargetName,
            replayArtifactTargetName,
            replayMechanicsTargetName,
            surfaceTargetName,
        ])
        reachability.append(
            Self.forbidden(
                mutationRecordTargetName,
                allTargetNames.filter {
                    !mutationRecordAllowed.contains($0)
                }
            )
        )
        let projectorAllowed = Set([
            projectorTargetName,
            exporterTargetName,
            replayArtifactTargetName,
            replayMechanicsTargetName,
            semanticTargetName,
            previous.historicalRuntimeTargetName,
            previous.historicalReplayTargetName,
        ])
        reachability.append(
            Self.forbidden(
                projectorTargetName,
                allTargetNames.filter {
                    !projectorAllowed.contains($0)
                }
            )
        )

        return Self(
            schemaVersion: 16,
            contractID:
                "prime_stage_b_source_bound_historical_evidence_semantic_artifact_projection_topology_v16",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                previous
                .historicalEvidenceExportDesignContractBinding,
            historicalEvidenceExportSourceContractBinding:
                previous
                .historicalEvidenceExportSourceContractBinding,
            historicalWorkerEvidenceExportCallEdgeSourceContractBinding:
                previous
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            historicalEvidenceSemanticArtifactProjectionDesignContractBinding:
                previous
                .historicalEvidenceSemanticArtifactProjectionDesignContractBinding,
            historicalEvidenceSemanticArtifactProjectionSourceContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID: source.contractID,
                    contentSHA256: sourceSHA256
                ),
            historicalEvidenceExportTargetName:
                previous.historicalEvidenceExportTargetName,
            historicalEvidenceSemanticArtifactProjectionTargetName:
                projectorTargetName,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_source_\(source.contractID)_sha256_\(sourceSHA256)_not_worker_request_handling_sealing_launch_execution_io_publication_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                source.nextImplementationPrerequisite,
            authorityStatement:
                [
                    "This V16 topology preserves every V1 through V15 canonical identity and changes only the package-internal source boundaries required by the frozen V15 prerequisite.",
                    "The byte-exact corrected mutation-record source moves into its own target; the semantic target drops its corrected-surface edge; and the corrected producer names the new record target while retaining its surface dependency.",
                    "The corrected-mutation ownership V2 release-source-reference prerequisite remains deferred and component-local; because every corrected-mutation target is outside the historical projector's transitive closure, it does not supersede this topology-wide next implementation prerequisite or gate the disjoint worker-carrier-to-projector call edge.",
                    "V16 appends the corrected record target and a historical-contained pure in-memory projector whose exact direct dependencies are the V13 exporter, artifact contracts, pure replay mechanics, and historical-safe semantic records.",
                    "The complete namespace has forty-four non-authorizing specifications, twenty-two per role, and the additive envelope retains all three admitted seed families by explicit key without positional joins or reduction.",
                    "The live historical observed-failure validator now admits only frozen historical critical-leg-domain members, preserving uppercase NL identifiers and rejecting unknown identifiers without changing V8 canonical contract bytes.",
                    "Deterministically redundant fingerprint fields are omitted only after exact canonical reconstruction; no non-derivable carrier information is dropped or defaulted.",
                    "The projector cannot reach corrected mutation surface, record, producer, detector, PrimeCore, ReplayTransport, or the worker.",
                    "The worker target, five direct dependencies, status-78 unavailable main, and V14 call edge remain unchanged and cannot reach the projector.",
                    "ReplayTransport remains materialized but has no V16 projector integration.",
                    "Focused synthetic tests exercise component mechanics only; the public project entry point remains runtime-unexercised, and no synthetic result is historical evidence.",
                    "No request handling, sealing, launch, worker/exporter/projector/gate/model execution, artifact I/O, publication, durable evidence, independent detection, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized.",
                ].joined(separator: " ")
        )
    }()

    /// Appends one compiler-bound private carrier-to-projector call edge to
    /// the unavailable historical worker. The exact main and V14 exporter
    /// edge remain byte-exact and cannot name the new cross-file member.
    public static let frozenV17: Self = {
        let previous = frozenV16
        let source =
            PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract
            .frozenV1
        let sourceSHA256 =
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        let workerTargetName =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let projectorTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        let semanticTargetName =
            "PrimeNativeNeuralGateSemanticRecordContracts"

        let targets = previous.targetGraph.map { target in
            guard target.targetName == workerTargetName
            else {
                return target
            }
            return Self.target(
                target.targetName,
                target.materialization,
                target.directLocalDependencyNames
                    + [projectorTargetName],
                "internal unavailable historical worker executable target whose exact status-78 main and V14 exporter edge remain byte-exact; V17 appends only one third Swift source containing a private typed already-formed-carrier plus explicit-context call into the product-free pure V16 projector and one sixth direct dependency, with no request handling, worker call-edge or public projector-entry-point invocation, ReplayTransport integration, worker-derived historical artifact I/O, publication, PASS, receipt, source binding V7, science, or product authority",
                externalProducts:
                    target.externalProductDependencyNames
            )
        }
        let reachability = previous.forbiddenReachability.map {
            rule in
            guard rule.targetName == workerTargetName
            else {
                return rule
            }
            return Self.forbidden(
                rule.targetName,
                rule.forbiddenReachableTargetNames.filter {
                    $0 != projectorTargetName
                        && $0 != semanticTargetName
                }
            )
        }

        return Self(
            schemaVersion: 17,
            contractID:
                "prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17",
            status: previous.status,
            executionImplemented: false,
            historicalReplayPlanID:
                previous.historicalReplayPlanID,
            historicalSourceBindingContractID:
                previous.historicalSourceBindingContractID,
            historicalEvidenceExportDesignContractBinding:
                previous
                .historicalEvidenceExportDesignContractBinding,
            historicalEvidenceExportSourceContractBinding:
                previous
                .historicalEvidenceExportSourceContractBinding,
            historicalWorkerEvidenceExportCallEdgeSourceContractBinding:
                previous
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            historicalEvidenceSemanticArtifactProjectionDesignContractBinding:
                previous
                .historicalEvidenceSemanticArtifactProjectionDesignContractBinding,
            historicalEvidenceSemanticArtifactProjectionSourceContractBinding:
                previous
                .historicalEvidenceSemanticArtifactProjectionSourceContractBinding,
            historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding:
                PrimeNativeNeuralGateTopologyContractBinding(
                    contractID: source.contractID,
                    contentSHA256: sourceSHA256
                ),
            historicalEvidenceExportTargetName:
                previous.historicalEvidenceExportTargetName,
            historicalEvidenceSemanticArtifactProjectionTargetName:
                previous
                .historicalEvidenceSemanticArtifactProjectionTargetName,
            historicalContractsPreserved: true,
            historicalFutureTargetGraphSuperseded: true,
            targetGraph: targets,
            forbiddenReachability: reachability,
            historicalContainmentRootTargetName:
                previous.historicalContainmentRootTargetName,
            historicalRuntimeTargetName:
                previous.historicalRuntimeTargetName,
            historicalReplayTargetName:
                previous.historicalReplayTargetName,
            pureReplayTargetName:
                previous.pureReplayTargetName,
            donorAdaptationV2PreservedAsHistory: true,
            donorAdaptationV3Required: true,
            donorAdaptationV3RequiredDestination:
                previous.donorAdaptationV3RequiredDestination,
            sourceBindingV7Issued: false,
            sourceBindingV7Prerequisite:
                previous.sourceBindingV7Prerequisite,
            packageCaptureAuthority:
                "actual_package_secure_capture_only_bound_source_\(source.contractID)_sha256_\(sourceSHA256)_not_worker_request_handling_sealing_launch_execution_io_publication_or_source_execution_binding_v7_evidence",
            mutationProducerDetectorTargetAssignmentDeferred:
                false,
            mutationProducerDetectorMustBeDisjoint: true,
            nextImplementationPrerequisite:
                source.nextImplementationPrerequisite,
            authorityStatement:
                [
                    "This V17 topology preserves every V1 through V16 canonical identity, the exact V11 status-78 main, the exact V14 worker/exporter call edge, and the complete V16 projector source and dependency closure.",
                    "It changes only the existing product-free historical worker target by appending one third Swift source and the V16 projector as a sixth direct dependency after the exact five-dependency V14 prefix.",
                    "The new private cross-file member accepts an already-formed V13 Evidence carrier plus explicit V16 context and contains one typed projector call; neither the main nor the private V14 edge can name it.",
                    "Worker target reachability now includes the projector and historical-safe semantic records, so exactly those two V16 worker prohibitions are removed while every corrected mutation, probe, verifier, corrected worker, evaluation, receipt, and source-binding path remains forbidden.",
                    "The projector still cannot reach the worker, ReplayTransport, PrimeCore, or corrected mutation targets; ReplayTransport remains an independent worker dependency with no projector call or decoder integration.",
                    "Compilation proves only the typed call edge. V16 synthetic projector-component tests remain non-historical mechanics evidence. No test launches the worker, and no request handling, sealing, launch, worker call-edge or public project(evidence:context:) entry-point invocation, worker-derived historical artifact construction or I/O, gate/model execution, historical evidence observation or publication, durable evidence, independent detection, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized.",
                ].joined(separator: " ")
        )
    }()

    public var historicalEvidenceExportDesignContractID:
        String?
    {
        historicalEvidenceExportDesignContractBinding?
            .contractID
    }

    public var historicalEvidenceExportDesignContractSHA256:
        String?
    {
        historicalEvidenceExportDesignContractBinding?
            .contentSHA256
    }

    public var historicalEvidenceExportSourceContractID:
        String?
    {
        historicalEvidenceExportSourceContractBinding?
            .contractID
    }

    public var historicalEvidenceExportSourceContractSHA256:
        String?
    {
        historicalEvidenceExportSourceContractBinding?
            .contentSHA256
    }

    public var
        historicalWorkerEvidenceExportCallEdgeSourceContractID:
        String?
    {
        historicalWorkerEvidenceExportCallEdgeSourceContractBinding?
            .contractID
    }

    public var
        historicalWorkerEvidenceExportCallEdgeSourceContractSHA256:
        String?
    {
        historicalWorkerEvidenceExportCallEdgeSourceContractBinding?
            .contentSHA256
    }

    public var
        historicalEvidenceSemanticArtifactProjectionDesignContractID:
        String?
    {
        historicalEvidenceSemanticArtifactProjectionDesignContractBinding?
            .contractID
    }

    public var
        historicalEvidenceSemanticArtifactProjectionDesignContractSHA256:
        String?
    {
        historicalEvidenceSemanticArtifactProjectionDesignContractBinding?
            .contentSHA256
    }

    public var
        historicalEvidenceSemanticArtifactProjectionSourceContractID:
        String?
    {
        historicalEvidenceSemanticArtifactProjectionSourceContractBinding?
            .contractID
    }

    public var
        historicalEvidenceSemanticArtifactProjectionSourceContractSHA256:
        String?
    {
        historicalEvidenceSemanticArtifactProjectionSourceContractBinding?
            .contentSHA256
    }

    public var
        historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractID:
        String?
    {
        historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding?
            .contractID
    }

    public var
        historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractSHA256:
        String?
    {
        historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding?
            .contentSHA256
    }

    public func target(
        named name: String
    ) throws -> PrimeNativeNeuralGateTopologyTarget {
        guard let target = targetGraph.first(
            where: { $0.targetName == name }
        ) else {
            throw PrimeNativeNeuralGateTopologyError
                .unknownTarget(name)
        }
        return target
    }

    public func transitiveLocalTargetNames(
        reachableFrom targetName: String
    ) throws -> [String] {
        let targets = try targetMap()
        guard targets[targetName] != nil else {
            throw PrimeNativeNeuralGateTopologyError
                .unknownTarget(targetName)
        }
        var visited = Set<String>()
        var pending =
            targets[targetName]!
            .directLocalDependencyNames
        while let dependency = pending.popLast() {
            guard let target = targets[dependency]
            else {
                throw PrimeNativeNeuralGateTopologyError
                    .missingDependency(
                        target: targetName,
                        dependency: dependency
                    )
            }
            if visited.insert(dependency).inserted {
                pending.append(
                    contentsOf:
                        target
                        .directLocalDependencyNames
                )
            }
        }
        return visited.sorted()
    }

    public func validate() throws {
        let expected: Self
        switch schemaVersion {
        case 1:
            expected = .frozenV1
        case 2:
            expected = .frozenV2
        case 3:
            expected = .frozenV3
        case 4:
            expected = .frozenV4
        case 5:
            expected = .frozenV5
        case 6:
            expected = .frozenV6
        case 7:
            expected = .frozenV7
        case 8:
            expected = .frozenV8
        case 9:
            expected = .frozenV9
        case 10:
            expected = .frozenV10
        case 11:
            expected = .frozenV11
        case 12:
            expected = .frozenV12
        case 13:
            expected = .frozenV13
        case 14:
            expected = .frozenV14
        case 15:
            expected = .frozenV15
        case 16:
            expected = .frozenV16
        case 17:
            expected = .frozenV17
        default:
            throw PrimeNativeNeuralGateTopologyError
                .invalidFrozenContract
        }
        // Validate a bound contract directly at its introduction version.
        // Later topology versions retain that already-frozen canonical ID and
        // digest literally. Replaying every predecessor's recursive validator
        // here creates combinatorial validation without adding a new binding
        // check; dedicated contract tests remain the source-validation gate.
        let designBindingValid: Bool
        if schemaVersion == 12 {
            let design =
                PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract
                .frozenV1
            try design.validate()
            let designSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(design)
            )
            designBindingValid =
                historicalEvidenceExportDesignContractBinding?
                .validate() == true
                && historicalEvidenceExportDesignContractID
                    == design.contractID
                && historicalEvidenceExportDesignContractSHA256
                    == designSHA256
        } else if schemaVersion > 12 {
            let frozenDesign =
                PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract
                .frozenV1
            let frozenDesignSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(frozenDesign)
            )
            designBindingValid =
                historicalEvidenceExportDesignContractBinding?
                .validate() == true
                && historicalEvidenceExportDesignContractID
                    == "prime_source_bound_historical_evidence_export_adapter_design_v12"
                && historicalEvidenceExportDesignContractSHA256
                    == "e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d"
                && frozenDesign.contractID
                    == historicalEvidenceExportDesignContractID
                && frozenDesignSHA256
                    == historicalEvidenceExportDesignContractSHA256
        } else {
            designBindingValid =
                historicalEvidenceExportDesignContractBinding
                    == nil
        }
        let sourceBindingValid: Bool
        if schemaVersion == 13 {
            let source =
                PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
                .frozenV1
            try source.validate()
            let sourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(source)
            )
            sourceBindingValid =
                historicalEvidenceExportSourceContractBinding?
                .validate() == true
                && historicalEvidenceExportSourceContractID
                    == source.contractID
                && historicalEvidenceExportSourceContractSHA256
                    == sourceSHA256
                && historicalEvidenceExportTargetName
                    == source.targetBinding.targetName
        } else if schemaVersion > 13 {
            let frozenSource =
                PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
                .frozenV1
            let frozenSourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(frozenSource)
            )
            sourceBindingValid =
                historicalEvidenceExportSourceContractBinding?
                .validate() == true
                && historicalEvidenceExportSourceContractID
                    == "prime_source_bound_historical_evidence_export_source_v13"
                && historicalEvidenceExportSourceContractSHA256
                    == "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"
                && historicalEvidenceExportTargetName
                    == "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
                && frozenSource.contractID
                    == historicalEvidenceExportSourceContractID
                && frozenSourceSHA256
                    == historicalEvidenceExportSourceContractSHA256
                && frozenSource.targetBinding.targetName
                    == historicalEvidenceExportTargetName
        } else {
            sourceBindingValid =
                historicalEvidenceExportSourceContractBinding
                    == nil
                && historicalEvidenceExportTargetName == nil
        }
        let callEdgeSourceBindingValid: Bool
        if schemaVersion == 14 {
            let source =
                PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract
                .frozenV1
            try source.validate()
            let sourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(source)
            )
            callEdgeSourceBindingValid =
                historicalWorkerEvidenceExportCallEdgeSourceContractBinding?
                .validate() == true
                && historicalWorkerEvidenceExportCallEdgeSourceContractID
                    == source.contractID
                && historicalWorkerEvidenceExportCallEdgeSourceContractSHA256
                    == sourceSHA256
        } else if schemaVersion > 14 {
            let frozenSource =
                PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract
                .frozenV1
            let frozenSourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(frozenSource)
            )
            callEdgeSourceBindingValid =
                historicalWorkerEvidenceExportCallEdgeSourceContractBinding?
                .validate() == true
                && historicalWorkerEvidenceExportCallEdgeSourceContractID
                    == "prime_source_bound_historical_worker_evidence_export_call_edge_v14"
                && historicalWorkerEvidenceExportCallEdgeSourceContractSHA256
                    == "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"
                && frozenSource.contractID
                    == historicalWorkerEvidenceExportCallEdgeSourceContractID
                && frozenSourceSHA256
                    == historicalWorkerEvidenceExportCallEdgeSourceContractSHA256
        } else {
            callEdgeSourceBindingValid =
                historicalWorkerEvidenceExportCallEdgeSourceContractBinding
                    == nil
        }
        let projectionDesignBindingValid: Bool
        if schemaVersion == 15 {
            let design =
                PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract
                .frozenV1
            try design.validate()
            let designSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(design)
            )
            projectionDesignBindingValid =
                historicalEvidenceSemanticArtifactProjectionDesignContractBinding?
                .validate() == true
                && historicalEvidenceSemanticArtifactProjectionDesignContractID
                    == design.contractID
                && historicalEvidenceSemanticArtifactProjectionDesignContractSHA256
                    == designSHA256
        } else if schemaVersion > 15 {
            let frozenDesign =
                PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract
                .frozenV1
            let frozenDesignSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(frozenDesign)
            )
            projectionDesignBindingValid =
                historicalEvidenceSemanticArtifactProjectionDesignContractBinding?
                .validate() == true
                && historicalEvidenceSemanticArtifactProjectionDesignContractID
                    == "prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15"
                && historicalEvidenceSemanticArtifactProjectionDesignContractSHA256
                    == "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27"
                && frozenDesign.contractID
                    == historicalEvidenceSemanticArtifactProjectionDesignContractID
                && frozenDesignSHA256
                    == historicalEvidenceSemanticArtifactProjectionDesignContractSHA256
        } else {
            projectionDesignBindingValid =
                historicalEvidenceSemanticArtifactProjectionDesignContractBinding
                    == nil
        }
        let projectionSourceBindingValid: Bool
        if schemaVersion == 16 {
            let source =
                PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
                .frozenV1
            try source.validate()
            let sourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(source)
            )
            projectionSourceBindingValid =
                historicalEvidenceSemanticArtifactProjectionSourceContractBinding?
                .validate() == true
                && historicalEvidenceSemanticArtifactProjectionSourceContractID
                    == source.contractID
                && historicalEvidenceSemanticArtifactProjectionSourceContractSHA256
                    == sourceSHA256
                && historicalEvidenceSemanticArtifactProjectionTargetName
                    == source.projectionTargetBinding.targetName
        } else if schemaVersion > 16 {
            let frozenSource =
                PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
                .frozenV1
            let frozenSourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(frozenSource)
            )
            projectionSourceBindingValid =
                historicalEvidenceSemanticArtifactProjectionSourceContractBinding?
                .validate() == true
                && historicalEvidenceSemanticArtifactProjectionSourceContractID
                    == "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16"
                && historicalEvidenceSemanticArtifactProjectionSourceContractSHA256
                    == "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
                && historicalEvidenceSemanticArtifactProjectionTargetName
                    == "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
                && frozenSource.contractID
                    == historicalEvidenceSemanticArtifactProjectionSourceContractID
                && frozenSourceSHA256
                    == historicalEvidenceSemanticArtifactProjectionSourceContractSHA256
                && frozenSource.projectionTargetBinding.targetName
                    == historicalEvidenceSemanticArtifactProjectionTargetName
        } else {
            projectionSourceBindingValid =
                historicalEvidenceSemanticArtifactProjectionSourceContractBinding
                    == nil
                && historicalEvidenceSemanticArtifactProjectionTargetName
                    == nil
        }
        let workerProjectionCallEdgeSourceBindingValid: Bool
        if schemaVersion >= 17 {
            let source =
                PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract
                .frozenV1
            try source.validate()
            let sourceSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(source)
            )
            workerProjectionCallEdgeSourceBindingValid =
                historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding?
                .validate() == true
                && historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractID
                    == source.contractID
                && historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractSHA256
                    == sourceSHA256
        } else {
            workerProjectionCallEdgeSourceBindingValid =
                historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding
                    == nil
        }
        guard self == expected,
              status == .plannedNotMaterialized,
              !executionImplemented,
              historicalContractsPreserved,
              historicalFutureTargetGraphSuperseded,
              donorAdaptationV2PreservedAsHistory,
              donorAdaptationV3Required,
              !sourceBindingV7Issued,
              mutationProducerDetectorTargetAssignmentDeferred
                == (schemaVersion < 8),
              mutationProducerDetectorMustBeDisjoint,
              designBindingValid,
              sourceBindingValid,
              callEdgeSourceBindingValid,
              projectionDesignBindingValid,
              projectionSourceBindingValid,
              workerProjectionCallEdgeSourceBindingValid
        else {
            throw PrimeNativeNeuralGateTopologyError
                .invalidFrozenContract
        }
        let targets = try targetMap()
        let namesSet = Set(targets.keys)
        for target in targetGraph {
            for dependency
                in target.directLocalDependencyNames
            {
                guard namesSet.contains(dependency)
                else {
                    throw PrimeNativeNeuralGateTopologyError
                        .missingDependency(
                            target: target.targetName,
                            dependency: dependency
                        )
                }
            }
        }
        for rule in forbiddenReachability {
            let closure = Set(
                try transitiveLocalTargetNames(
                    reachableFrom: rule.targetName
                )
            )
            if let reached =
                rule
                .forbiddenReachableTargetNames
                .first(where: closure.contains)
            {
                throw PrimeNativeNeuralGateTopologyError
                    .forbiddenReachability(
                        target: rule.targetName,
                        reached: reached
                    )
            }
        }
        for target in targetGraph {
            var historicalContainedTargetNames = [
                historicalRuntimeTargetName,
                historicalReplayTargetName,
                historicalContainmentRootTargetName,
            ]
            if let historicalEvidenceExportTargetName {
                historicalContainedTargetNames.append(
                    historicalEvidenceExportTargetName
                )
            }
            if let
                historicalEvidenceSemanticArtifactProjectionTargetName
            {
                historicalContainedTargetNames.append(
                    historicalEvidenceSemanticArtifactProjectionTargetName
                )
            }
            guard !historicalContainedTargetNames
                .contains(target.targetName)
            else {
                continue
            }
            let closure = Set(
                try transitiveLocalTargetNames(
                    reachableFrom:
                        target.targetName
                )
            )
            guard
                !closure.contains(
                    historicalRuntimeTargetName
                ),
                !closure.contains(
                    historicalReplayTargetName
                )
            else {
                throw PrimeNativeNeuralGateTopologyError
                    .historicalContainmentEscape(
                        target: target.targetName
                    )
            }
        }
        let implementedNames = Set(
            targetGraph
                .filter {
                    $0.materialization == .implemented
                }
                .map(\.targetName)
        )
        for target in targetGraph
        where target.materialization == .implemented {
            guard
                Set(target.directLocalDependencyNames)
                .isSubset(of: implementedNames)
            else {
                throw PrimeNativeNeuralGateTopologyError
                    .invalidMaterialization(
                        target: target.targetName
                    )
            }
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private func targetMap() throws
        -> [String: PrimeNativeNeuralGateTopologyTarget]
    {
        var result:
            [String: PrimeNativeNeuralGateTopologyTarget] =
            [:]
        for target in targetGraph {
            guard result.updateValue(
                target,
                forKey: target.targetName
            ) == nil
            else {
                throw PrimeNativeNeuralGateTopologyError
                    .duplicateTarget(
                        target.targetName
                    )
            }
        }
        return result
    }

    private static func target(
        _ name: String,
        _ materialization:
            PrimeNativeNeuralGateTargetMaterialization,
        _ dependencies: [String],
        _ authority: String,
        externalProducts: [String] = []
    ) -> PrimeNativeNeuralGateTopologyTarget {
        PrimeNativeNeuralGateTopologyTarget(
            targetName: name,
            materialization: materialization,
            directLocalDependencyNames:
                dependencies,
            externalProductDependencyNames:
                externalProducts,
            authority: authority
        )
    }

    private static func forbidden(
        _ targetName: String,
        _ names: [String]
    ) -> PrimeNativeNeuralGateForbiddenReachability {
        PrimeNativeNeuralGateForbiddenReachability(
            targetName: targetName,
            forbiddenReachableTargetNames: names
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case status
        case executionImplemented =
            "execution_implemented"
        case historicalReplayPlanID =
            "historical_replay_plan_id"
        case historicalSourceBindingContractID =
            "historical_source_binding_contract_id"
        case historicalEvidenceExportDesignContractBinding =
            "historical_evidence_export_design_contract_binding"
        case historicalEvidenceExportSourceContractBinding =
            "historical_evidence_export_source_contract_binding"
        case historicalWorkerEvidenceExportCallEdgeSourceContractBinding =
            "historical_worker_evidence_export_call_edge_source_contract_binding"
        case historicalEvidenceSemanticArtifactProjectionDesignContractBinding =
            "historical_evidence_semantic_artifact_projection_design_contract_binding"
        case historicalEvidenceSemanticArtifactProjectionSourceContractBinding =
            "historical_evidence_semantic_artifact_projection_source_contract_binding"
        case historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding =
            "historical_worker_semantic_artifact_projection_call_edge_source_contract_binding"
        case historicalEvidenceExportTargetName =
            "historical_evidence_export_target_name"
        case historicalEvidenceSemanticArtifactProjectionTargetName =
            "historical_evidence_semantic_artifact_projection_target_name"
        case historicalContractsPreserved =
            "historical_contracts_preserved"
        case historicalFutureTargetGraphSuperseded =
            "historical_future_target_graph_superseded"
        case targetGraph = "target_graph"
        case forbiddenReachability =
            "forbidden_reachability"
        case historicalContainmentRootTargetName =
            "historical_containment_root_target_name"
        case historicalRuntimeTargetName =
            "historical_runtime_target_name"
        case historicalReplayTargetName =
            "historical_replay_target_name"
        case pureReplayTargetName =
            "pure_replay_target_name"
        case donorAdaptationV2PreservedAsHistory =
            "donor_adaptation_v2_preserved_as_history"
        case donorAdaptationV3Required =
            "donor_adaptation_v3_required"
        case donorAdaptationV3RequiredDestination =
            "donor_adaptation_v3_required_destination"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case sourceBindingV7Prerequisite =
            "source_binding_v7_prerequisite"
        case packageCaptureAuthority =
            "package_capture_authority"
        case mutationProducerDetectorTargetAssignmentDeferred =
            "mutation_producer_detector_target_assignment_deferred"
        case mutationProducerDetectorMustBeDisjoint =
            "mutation_producer_detector_must_be_disjoint"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement =
            "authority_statement"
    }
}

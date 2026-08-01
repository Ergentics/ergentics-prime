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
        default:
            throw PrimeNativeNeuralGateTopologyError
                .invalidFrozenContract
        }
        guard self == expected,
              status == .plannedNotMaterialized,
              !executionImplemented,
              historicalContractsPreserved,
              historicalFutureTargetGraphSuperseded,
              donorAdaptationV2PreservedAsHistory,
              donorAdaptationV3Required,
              !sourceBindingV7Issued,
              mutationProducerDetectorTargetAssignmentDeferred,
              mutationProducerDetectorMustBeDisjoint
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
            guard ![
                historicalRuntimeTargetName,
                historicalReplayTargetName,
                historicalContainmentRootTargetName,
            ].contains(target.targetName)
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

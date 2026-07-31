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
        guard self == .frozenV1,
              schemaVersion == 1,
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

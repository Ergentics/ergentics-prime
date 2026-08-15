// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeNativeDecoderTraining
import XCTest

final class PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests:
    XCTestCase
{
    func testBSpecificNative300MResourceWitnessContractIsExactAndExecutionPure()
        throws
    {
        typealias Witness =
            PrimeNativeDecoderBSpecificNative300MResourceWitness
        let authority =
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .frozenV1
        try authority.validateExactV1()
        try Witness.validatePureContractV1()

        XCTAssertEqual(
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .canonicalSHA256,
            "15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba")
        XCTAssertEqual(
            Witness.authorityCanonicalSHA256,
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .canonicalSHA256)
        XCTAssertEqual(
            Witness.internalCandidatePrefix,
            authority.leaseReceiptIntegrity.internalCandidatePrefix)
        XCTAssertEqual(
            Witness.publicReceiptPrefix,
            authority.leaseReceiptIntegrity.publicCanonicalReceiptPrefix)
        XCTAssertEqual(
            Witness.internalTerminalPrefix,
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_INTERNAL_TERMINAL_V1=")
        XCTAssertEqual(
            Witness.candidateSchemaID,
            "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_candidate_v1")
        XCTAssertEqual(
            Witness.terminalSchemaID,
            "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_terminal_v1")

        let candidateSchemaKeys = [
            "authority_canonical_sha256", "authority_id", "classification",
            "one_shot_consumed", "payload", "schema_id", "schema_version",
            "scientific_status",
        ]
        let terminalSchemaKeys = [
            "actual_metadata", "actual_metadata_availability",
            "actual_metadata_unavailable_reason",
            "authority_canonical_sha256", "authority_id",
            "candidate_present", "candidate_scientific_status",
            "candidate_sha256", "classification", "errno",
            "errno_availability", "first_failed_guard_id", "lease_acquired",
            "one_shot_consumed", "release_verifier_exit_zero", "schema_id",
            "schema_version", "supervisor_integrity_guard_count",
            "supervisor_post_candidate_inventory",
            "supervisor_post_candidate_lease_tuple",
            "supervisor_post_candidate_parent_tuple",
            "supervisor_preflight_parent_tuple", "terminal_status",
            "verifier_inventory", "verifier_lease_tuple",
            "verifier_parent_tuple",
        ]
        XCTAssertEqual(Witness.candidateSchemaKeys, candidateSchemaKeys)
        XCTAssertEqual(Witness.terminalSchemaKeys, terminalSchemaKeys)
        XCTAssertEqual(candidateSchemaKeys.count, 8)
        XCTAssertEqual(terminalSchemaKeys.count, 26)

        let publicReceiptSchemaKeys = [
            "actual_metadata", "actual_metadata_availability",
            "actual_metadata_unavailable_reason",
            "artifact_upload_authorized", "authority_canonical_sha256",
            "authority_id", "b_specific_native300m_resource_clearance",
            "b_specific_native300m_resource_witness",
            "candidate_canonical_byte_count", "candidate_present",
            "candidate_scientific_status", "candidate_sha256",
            "classification", "errno", "errno_availability",
            "exact_changed_source_identities", "first_failed_guard_id",
            "historical_stage6_resource_clearance_applies_to_b_path",
            "lease_acquired", "mechanics_revision",
            "mechanics_run_attempt", "mechanics_run_id",
            "mechanics_run_number", "mechanics_tree", "one_shot_consumed",
            "ordinary_job_fit_established", "release_verifier_exit_zero",
            "rerun_authorized", "retained_artifact_authorized",
            "retry_authorized", "schema_id", "schema_version",
            "stage7_authorized", "status",
            "supervisor_integrity_guard_count",
            "terminal_canonical_byte_count", "terminal_sha256",
            "validated_private_candidate", "validated_private_terminal",
        ]
        XCTAssertEqual(publicReceiptSchemaKeys.count, 39)
        XCTAssertEqual(
            publicReceiptSchemaKeys,
            publicReceiptSchemaKeys.sorted())

        XCTAssertEqual(
            Witness.phaseNames,
            authority.resourceEnvelope.requiredPhaseNames)
        XCTAssertEqual(
            Witness.integrityGuardIDs,
            authority.leaseReceiptIntegrity.orderedIntegrityGuardIDs)
        XCTAssertEqual(Witness.integrityGuardIDs.count, 18)
        XCTAssertEqual(
            Witness.classificationDomain,
            [authority.transitions.passClassification]
                + authority.transitions.abstainClassifications
                + [authority.transitions.integrityAbstainClassification]
                + authority.transitions.noPublicReceiptClassifications)
        XCTAssertEqual(
            Witness.operationCountKeys,
            [
                "adamw_update_count", "backward_count",
                "checked_evaluation_barrier_count", "cross_entropy_count",
                "dense_embedding_construction_count",
                "direct_package_b_training_logits_api_call_count",
                "evaluation_forward_pass_count", "forward_loss_count",
                "full_graph_evaluation_count",
                "gpu_synchronization_barrier_count", "gradient_clip_count",
                "gradient_norm_count", "kv_cache_allocation_count",
                "input_embedding_forward_pair_diagnostic_invocation_count",
                "maintained_gather_training_logits_count",
                "memory_clear_cache_count", "mlx_peak_memory_reset_count",
                "model_allocation_count", "model_materialization_count",
                "optimizer_step_count",
                "postflight_device_reenumeration_count",
                "tiny_training_selector_invocation_count",
                "token_bounds_checked_eval_count",
                "token_bounds_gpu_synchronization_count",
                "token_bounds_host_bool_item_count",
                "token_bounds_validation_count", "value_and_grad_count",
            ])

        let expectedEnvironmentVariableNames = [
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXECUTABLE_PATH",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_LEASE_ROOT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_PRIVATE_WORKING_DIRECTORY",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXACT_MLX_REVISION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_PATH",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_BYTES",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_SHA256",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_OPERATING_SYSTEM_BUILD",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_KERNEL_IDENTITY",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_SWIFT_TOOLCHAIN",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_XCODE_TOOLCHAIN",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MACOS_SDK",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_BUILD_CONFIGURATION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MLX_GRAPH_COMPILE_MODE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CANONICAL_SHA256",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_SOURCE_IDENTITY_JSON",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_TEST_IDENTITY_JSON",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_BASE_REVISION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_BASE_TREE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVISION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_TREE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_FIRST_PARENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_SECOND_PARENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_HEAD",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_PULL_REQUEST_NUMBER",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_NUMBER",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_ATTEMPT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_CHECK_SUITE_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_IMAGE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_IMAGE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_EVENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REF",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_STATUS",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_CONCLUSION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ARTIFACT_COUNT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RERUN_COUNT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EXECUTED_REVISION",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EXECUTED_TREE",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_FIRST_PARENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_SECOND_PARENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EVENT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_REF",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_ID",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_NUMBER",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_ATTEMPT",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXACT_CHANGED_SOURCE_IDENTITIES_JSON",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_PROVENANCE_SOURCE_IDENTITIES_JSON",
            "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EMBEDDED_SOURCE_IDENTITY_SHA256",
        ]
        XCTAssertEqual(
            Witness.environmentVariableNames,
            expectedEnvironmentVariableNames)
        XCTAssertEqual(expectedEnvironmentVariableNames.count, 54)
        XCTAssertEqual(
            Set(expectedEnvironmentVariableNames).count,
            expectedEnvironmentVariableNames.count)

        XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 8)
        XCTAssertEqual(authority.futureExecution.buildCount, 1)
        XCTAssertEqual(authority.futureExecution.pureContractXCTestStartCount, 2)
        XCTAssertEqual(authority.futureExecution.launcherInvocationCount, 1)
        XCTAssertEqual(authority.futureExecution.directExecutableProbeCount, 1)
        XCTAssertEqual(authority.futureExecution.successorAggregateInvocationCount, 3)
        XCTAssertEqual(
            authority.leaseReceiptIntegrity.operationalProbeRoleProcessInvocationCount,
            3)
        XCTAssertEqual(authority.leaseReceiptIntegrity.resourceWorkerSpawnCount, 1)
        XCTAssertEqual(authority.leaseReceiptIntegrity.releaseVerifierSpawnCount, 1)
        XCTAssertEqual(
            authority.leaseReceiptIntegrity.launcherPublicCanonicalReceiptMaximumCount,
            1)
        XCTAssertEqual(authority.suite.futureTotalXCTestCount, 114)
        XCTAssertEqual(authority.suite.futureBContractXCTestStartCount, 2)
        XCTAssertEqual(authority.suite.futureBSuccessorAggregateInvocationCount, 3)
        XCTAssertFalse(authority.ceiling.stage7Authorized)

        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 {
            repositoryRoot.deleteLastPathComponent()
        }
        let manifestSource = try source(
            at: repositoryRoot,
            relativePath: authority.successorManifest.packageManifestPath)
        XCTAssertEqual(occurrences(of: ".executable(", in: manifestSource), 2)
        XCTAssertEqual(
            occurrences(of: ".executableTarget(", in: manifestSource), 2)
        XCTAssertEqual(occurrences(of: ".testTarget(", in: manifestSource), 1)
        XCTAssertEqual(
            occurrences(
                of: "PrimeNativeDecoderBSpecificNative300MResourceWitness",
                in: manifestSource),
            4)
        XCTAssertEqual(
            occurrences(
                of: "d37885a278f1c37484a94d0f401a418735e66519",
                in: manifestSource),
            1)

        let probeSource = try source(
            at: repositoryRoot,
            relativePath: authority.successorManifest.trainingProbeSourcePath)
        XCTAssertEqual(
            importLines(in: probeSource),
            [
                "import CoreGraphics", "import Darwin", "import Foundation",
                "import Metal", "import MLX", "import MLXNN",
                "import MLXOptimizers", "import PrimeCore",
                "import PrimeNativeDecoder",
            ])
        for required in [
            "public static func runSupervisor()",
            "runSupervisorProcess", "runResourceWorkerProcess",
            "runReleaseVerifierProcess", "spawnResourceWorker",
            "spawnReleaseVerifier", "--resource-worker",
            "--release-verifier", "PrimeMetalDeviceLease.acquire",
            "posix_spawn", "POSIX_SPAWN_SETPGROUP",
            "POSIX_SPAWN_CLOEXEC_DEFAULT", "O_DIRECTORY", "O_NOFOLLOW",
            "O_CLOEXEC", "checkedEval(model, beforeFingerprintSampleViews)",
            "checkedEval(lossAndGradient.loss, lossAndGradient.gradients)",
            "checkedEval(rawGradientNorm)", "checkedEval(clippedGradients)",
            "checkedEval(model, optimizer, afterFingerprintSampleViews)",
            "trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
            "passMeasuredPeakIsBelowConfiguredLimit",
            "bResourceDirectoryInventory", "fdopendir", "readdir",
            "physicalPathGuardID", "firstStableParentMismatch",
            "relocatePrivatePipeDescriptorIfNeeded",
            "workerFrameDescriptor == 19",
            "_exit(0)",
        ] {
            XCTAssertTrue(probeSource.contains(required), required)
        }
        XCTAssertEqual(
            occurrences(of: "PrimeMetalDeviceLease.acquire", in: probeSource),
            2)
        XCTAssertFalse(probeSource.contains("let line = receiptPrefix +"))
        XCTAssertFalse(probeSource.contains("swift run"))
        XCTAssertFalse(
            probeSource.contains("contentsOfDirectory(atPath:"))
        let compactProbeSource = whitespaceCompacted(probeSource)
        for requiredRouting in [
            "let arguments = CommandLine.arguments if arguments.count == 3, arguments[1] == workerArgument, arguments[2] == \"--frame-descriptor=\\(workerFrameDescriptor)\"",
            "if arguments.count == 2, arguments[1] == verifierArgument",
            "guard arguments.count == 1 else",
            "let arguments = [bindings.executablePath, verifierArgument]",
            "let arguments = [ executable, workerArgument, \"--frame-descriptor=\\(workerFrameDescriptor)\", ]",
            "physicalPathGuardID: \"supervisor_preflight_parent_physical_path\"",
            "physicalPathGuardID: \"supervisor_post_candidate_parent_stable_fields\"",
            "physicalPathGuardID: \"verifier_parent_identity\"",
            "bResourceDirectoryInventory( descriptor: descriptor, guardID: guardID)",
        ] {
            XCTAssertTrue(
                compactProbeSource.contains(requiredRouting),
                requiredRouting)
        }
        for retiredHelper in [
            "isValidatedLeaseBusyTerminal", "makeFinalReceipt",
            "validateFinalReceipt", "validateFinalReceiptShape",
            "falseCeiling", "configurationReceipt",
        ] {
            XCTAssertFalse(probeSource.contains(retiredHelper), retiredHelper)
        }
        XCTAssertFalse(
            probeSource.split(separator: "\n").contains { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed.hasPrefix("Process()")
                    || trimmed.contains("= Process()")
            })

        let mainSource = try source(
            at: repositoryRoot,
            relativePath: authority.successorManifest.executableMainPath)
        XCTAssertEqual(
            importLines(in: mainSource),
            authority.successorManifest.executableMainImports.map {
                "import \($0)"
            })
        XCTAssertEqual(
            occurrences(
                of: authority.successorManifest.executableMainEntryPoint,
                in: mainSource),
            1)
        XCTAssertTrue(
            mainSource.contains(
                "PrimeNativeDecoderBSpecificNative300MResourceWitness.runSupervisor()"))

        let launcherSource = try source(
            at: repositoryRoot,
            relativePath: authority.successorManifest.launcherPath)
        XCTAssertTrue(launcherSource.hasPrefix("#!/usr/bin/env bash\n"))
        for required in [
            "readonly authority_canonical_sha256=\"15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba\"",
            "readonly authority_closure_revision=\"b1695b17523068e2b720066d84c422cbe2e67975\"",
            "readonly authority_closure_tree=\"3b910fe8bbdec008cf9665b6208292f7c1c0c7f3\"",
            "readonly authority_closure_first_parent=\"7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4\"",
            "readonly authority_closure_second_parent=\"ff612ddc6420bc7db0f4993b7aeff7e17fb3f9bc\"",
            "readonly authority_closure_run_id=\"31850975271\"",
            "readonly authority_closure_run_number=\"121\"",
            "readonly authority_closure_run_attempt=\"1\"",
            "readonly authority_closure_check_suite_id=\"86410537152\"",
            "readonly authority_closure_active_job_id=\"94926582838\"",
            "readonly authority_closure_reviewed_job_id=\"94927151419\"",
            "readonly expected_preserved_index_sha256=\"de530cb1b5e6c2d8612d97ca1d22a0378fe530a6915dab88648a5caf3dae056d\"",
            "readonly candidate_maximum_count=\"1\"",
            "readonly terminal_exact_count=\"1\"",
            "readonly public_receipt_maximum_count=\"1\"",
            "readonly candidate_schema_key_count=\"8\"",
            "readonly terminal_schema_key_count=\"26\"",
            "readonly public_receipt_schema_key_count=\"39\"",
            "readonly public_receipt_maximum_byte_count=\"1048576\"",
            "readonly launcher_environment_binding_count=\"54\"",
            "readonly integrity_guard_count=\"18\"",
            "readonly expected_root_test_count=\"60\"",
            "readonly expected_isolated_test_count=\"6\"",
            "readonly expected_focused_contract_test_count=\"1\"",
            "readonly expected_focused_whole_test_count=\"67\"",
            "readonly expected_metal_test_count=\"44\"",
            "readonly expected_maintained_runtime_test_count=\"1\"",
            "readonly expected_tokenizer_test_count=\"1\"",
            "readonly expected_launcher_contract_test_count=\"1\"",
            "readonly expected_live_xctest_count=\"47\"",
            "readonly expected_total_xctest_count=\"114\"",
            "readonly expected_original_stage5_launcher_invocation_count=\"0\"",
            "readonly expected_replacement_stage5_launcher_invocation_count=\"0\"",
            "readonly expected_historical_stage6_launcher_invocation_count=\"0\"",
            "ABSTAIN_INTEGRITY", "supervisor_exit_zero",
            "outer_private_working_directory_postflight",
            "outer_repository_postflight", "outer_metallib_postflight",
            "outer_parent_and_lease_file_rebind",
            "original_stage5_receipt_prefix",
            "replacement_stage5_receipt_prefix",
            "historical_stage6_receipt_prefix",
            "pass_measured_mlx_peak_below_configured_limit",
            "attempted_prefix_counts", "strictly_increasing",
            "nondecreasing", "configured_limit_observation_keys",
            "validated_model_observation_keys",
            "validated_gradient_observation_keys",
            "validated_moment_observation_keys",
            "expected_gradient_clip_scale_bits",
            "typed_descriptor_evidence", "allowed_resource_xattrs",
            "clean_terminal_identity_closure",
            "integrity_guard_prefix_count_matches_first_failure",
            "parent_preflight_stable_fields",
            "parent_verifier_stable_fields",
            "candidate_contract_v1", "safely_candidate_contract_v1",
            "terminal_contract_v1", "safely_terminal_contract_v1",
            "public_contract_v1", "safely_public_contract_v1",
            "candidate_canonical_byte_count",
            "terminal_canonical_byte_count",
            "validated_private_candidate",
            "validated_private_terminal",
            "embedded_candidate_json", "embedded_terminal_json",
            "canonically cross-bound", "public_line_byte_count",
            "validated supervisor terminal before any outer",
            "def hex40:", ".mechanics_revision | hex40",
            "unexpected_schema_key", "not_numeric",
            "unknown_integrity_guard",
        ] {
            XCTAssertTrue(launcherSource.contains(required), required)
        }
        let exactPublicReceiptSchemaArray = publicReceiptSchemaKeys
            .map { "\"\($0)\"" }
            .joined(separator: ",")
        XCTAssertTrue(
            launcherSource.contains(
                "([\(exactPublicReceiptSchemaArray)] | sort)"))
        XCTAssertTrue(launcherSource.contains("and (keys | length) == 39"))
        XCTAssertTrue(
            launcherSource.contains(
                "validated_private_candidate:$validated_private_candidate[0]"))
        XCTAssertTrue(
            launcherSource.contains(
                "validated_private_terminal:$validated_private_terminal[0]"))
        XCTAssertTrue(
            launcherSource.contains(
                "exec /usr/bin/printf '%s\\n' \"$public_line\""))
        XCTAssertEqual(occurrences(of: "--build-tests", in: launcherSource), 1)
        XCTAssertEqual(occurrences(of: "--skip-build", in: launcherSource), 1)
        XCTAssertEqual(
            occurrences(of: "--filter \"$contract_filter\"", in: launcherSource),
            1)
        XCTAssertEqual(
            launcherSource.split(separator: "\n").filter {
                $0.trimmingCharacters(in: .whitespaces) == "\"$executable\""
            }.count,
            1)
        let launcherEnvironmentNames = launcherSource.split(separator: "\n")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter {
                $0.hasPrefix(
                    "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_")
                    && $0.contains("=")
            }
            .compactMap { $0.split(separator: "=", maxSplits: 1).first }
            .map(String.init)
        XCTAssertEqual(launcherEnvironmentNames.count, 54)
        XCTAssertEqual(
            launcherEnvironmentNames.sorted(),
            expectedEnvironmentVariableNames.sorted())

        let nonemptyLauncherLines = launcherSource.split(separator: "\n")
            .map(String.init)
            .filter { !$0.isEmpty }
        XCTAssertEqual(
            Array(nonemptyLauncherLines.suffix(2)),
            [
                "trap - EXIT HUP INT TERM",
                "exec /usr/bin/printf '%s\\n' \"$public_line\"",
            ])
        XCTAssertEqual(
            occurrences(
                of: authority.leaseReceiptIntegrity.finalPublicReceiptCommand,
                in: launcherSource),
            1)
        XCTAssertFalse(launcherSource.contains("\nrm "))
        XCTAssertFalse(launcherSource.contains("\nrmdir "))
        XCTAssertFalse(launcherSource.contains("unlink("))
        XCTAssertFalse(launcherSource.contains("OK:"))
        XCTAssertFalse(launcherSource.contains("GITHUB_STEP_SUMMARY"))

        let criticalProbeMutationAnchors = [
            "passMeasuredPeakIsBelowConfiguredLimit(",
            "bResourceDirectoryInventory(", "fdopendir(", "readdir(",
            "physicalPathGuardID:", "firstStableParentMismatch(",
            "relocatePrivatePipeDescriptorIfNeeded(",
            "workerFrameDescriptor == 19",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: probeSource,
                requiredAnchors: criticalProbeMutationAnchors))
        for anchor in criticalProbeMutationAnchors {
            let mutated = replacingEvery(anchor, with: "MUTATED", in: probeSource)
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: mutated,
                    requiredAnchors: criticalProbeMutationAnchors),
                anchor)
        }

        let criticalLauncherMutationAnchors = [
            "def candidate_contract_v1:",
            "def safely_candidate_contract_v1:",
            "def terminal_contract_v1:",
            "def safely_terminal_contract_v1:",
            "def public_contract_v1:",
            "def safely_public_contract_v1:",
            "def pass_measured_mlx_peak_below_configured_limit:",
            "def attempted_prefix_counts:",
            "def strictly_increasing:", "def nondecreasing:",
            "def expected_gradient_clip_scale_bits:",
            "def typed_descriptor_evidence:",
            "def allowed_resource_xattrs:",
            "def clean_terminal_identity_closure(",
            "def integrity_guard_prefix_count_matches_first_failure(",
            "def parent_preflight_stable_fields:",
            "def parent_verifier_stable_fields:",
            ".observed_nlink == 1 and .byte_count == 0",
            ".mode == \"0700\" and .security_flags == 0",
            ".gid == $effective_gid and .mode == \"0600\"",
            "validated_private_candidate:$validated_private_candidate[0]",
            "validated_private_terminal:$validated_private_terminal[0]",
            ".validated_private_candidate == $expected_candidate[0]",
            ".validated_private_terminal == $expected_terminal[0]",
            ".terminal_canonical_byte_count",
            ".candidate_canonical_byte_count",
            "embedded validated private candidate is not canonically cross-bound",
            "embedded validated private terminal is not canonically cross-bound",
            "def hex40:", ".mechanics_revision | hex40",
            "public_line_byte_count",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: launcherSource,
                requiredAnchors: criticalLauncherMutationAnchors))
        for anchor in criticalLauncherMutationAnchors {
            let mutated = replacingEvery(
                anchor, with: "MUTATED", in: launcherSource)
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: mutated,
                    requiredAnchors: criticalLauncherMutationAnchors),
                anchor)
        }
    }

    private func source(at root: URL, relativePath: String) throws -> String {
        try String(
            contentsOf: root.appendingPathComponent(relativePath),
            encoding: .utf8)
    }

    private func importLines(in source: String) -> [String] {
        source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
    }

    private func occurrences(of needle: String, in source: String) -> Int {
        source.components(separatedBy: needle).count - 1
    }

    private func whitespaceCompacted(_ source: String) -> String {
        source.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    private func criticalStaticContractHolds(
        in source: String,
        requiredAnchors: [String]
    ) -> Bool {
        requiredAnchors.allSatisfy { source.contains($0) }
    }

    private func replacingEvery(
        _ needle: String,
        with replacement: String,
        in source: String
    ) -> String {
        source.replacingOccurrences(of: needle, with: replacement)
    }
}

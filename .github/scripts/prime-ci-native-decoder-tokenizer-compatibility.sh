#!/usr/bin/env bash
# Exact-head hosted functional compatibility probe for Prime's tokenizer and
# one random-initialized Native-300M decoder allocation and full-prefix
# no-cache forward.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-tokenizer-compatibility: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly expected_mlx_submodules=$' ce45c52505c8158ea48d2a54e8caae05efd86bfe Source/Cmlx/mlx (v0.31.1)\n 0726ca922fc902c4c61ef9c27d94132be418e945 Source/Cmlx/mlx-c (v0.6.0)'
readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly frozen_test_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTokenizerCompatibilityValidation"
readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly scratch_path="$runner_temp/prime-native-decoder-tokenizer-compatibility-build"
readonly cache_path="$runner_temp/prime-native-decoder-tokenizer-compatibility-cache"
readonly config_path="$runner_temp/prime-native-decoder-tokenizer-compatibility-config"
readonly security_path="$runner_temp/prime-native-decoder-tokenizer-compatibility-security"
readonly private_cwd="$runner_temp/prime-native-decoder-tokenizer-compatibility-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-tokenizer-compatibility-lease"
readonly lease_path="$lease_root/metal.lock"
readonly test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"
readonly receipt_prefix="PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT="

for command_name in \
    awk bash chmod cmp cp env find git grep jq mkdir otool sed shasum \
    stat swift tr wc xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

[[ "$exact_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact Prime revision"
[[ "$mlx_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact MLX revision"
while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime checkout is not at the exact revision"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
[[ "$exact_tree" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact Prime tree"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not clean"
[[ -f "$embedded_provenance" && ! -L "$embedded_provenance" ]] ||
    fail "embedded Prime provenance source is missing"
readonly embedded_source_identity_matches="$(
    grep -Eo '"[0-9a-f]{64}"' "$embedded_provenance" || true
)"
[[ "$(printf '%s\n' "$embedded_source_identity_matches" |
    awk 'NF { count += 1 } END { print count + 0 }')" == "1" ]] ||
    fail "embedded Prime provenance must contain exactly one source identity"
readonly embedded_source_identity="${embedded_source_identity_matches//\"/}"
[[ "$embedded_source_identity" =~ ^[0-9a-f]{64}$ ]] ||
    fail "embedded Prime source identity is invalid"
[[ -d "$mlx_bare" && ! -L "$mlx_bare" ]] ||
    fail "missing exact MLX bare repository"
[[ -d "$mlx_source" && ! -L "$mlx_source" ]] ||
    fail "missing exact MLX donor worktree"
[[ "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
    == "$mlx_revision" ]] ||
    fail "MLX bare repository is not pinned exactly"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX donor worktree is not pinned exactly"
[[ "$(git -C "$mlx_source" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "MLX donor submodules are not pinned exactly"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor worktree is not clean"

[[ -s "$frozen_test_log" && ! -L "$frozen_test_log" ]] ||
    fail "frozen 44-test Metal log is missing"
grep -Eq 'Executed 44 tests, with 0 failures' "$frozen_test_log" ||
    fail "frozen 44-test Metal launcher did not complete first"
! grep -Eiq 'skipped|Test skipped|Metal is unavailable' "$frozen_test_log" ||
    fail "frozen 44-test Metal log contains a skip"
[[ -s "$runtime_test_log" && ! -L "$runtime_test_log" ]] ||
    fail "maintained-runtime authority log is missing"
grep -Eq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "maintained-runtime authority test did not complete first"
[[ -s "$runtime_probe_log" && ! -L "$runtime_probe_log" ]] ||
    fail "maintained-runtime probe log is missing"
[[ "$(grep -Fc -- 'PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' \
    "$runtime_probe_log")" == "1" ]] ||
    fail "maintained-runtime receipt did not complete first"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "frozen launcher metallib root is missing"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" -type f -name default.metallib -print)
[[ "$metallib_count" -eq 1 && -f "$metallib" && -s "$metallib" \
    && ! -L "$metallib" ]] ||
    fail "expected exactly one same-job fresh metallib"
[[ "$(find "$frozen_metallib_root" -name default.metallib -print | \
    wc -l | tr -d ' ')" == "1" ]] ||
    fail "frozen metallib tree contains a non-regular candidate"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_byte_count" -le 67108864 ]] ||
    fail "fresh metallib byte count is outside the bound"
[[ "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib SHA-256 is invalid"

for fresh_path in \
    "$scratch_path" \
    "$cache_path" \
    "$config_path" \
    "$security_path" \
    "$private_cwd" \
    "$lease_root" \
    "$test_log" \
    "$probe_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "compatibility path must be initially absent: $fresh_path"
done
mkdir -p \
    "$scratch_path" \
    "$cache_path" \
    "$config_path" \
    "$security_path" \
    "$private_cwd" \
    "$lease_root"
chmod 700 "$private_cwd" "$lease_root"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private compatibility working directory is not empty"

export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="protocol.file.allow"
export GIT_CONFIG_VALUE_1="always"

readonly swift_arguments=(
    --package-path "$validation_root"
    --scratch-path "$scratch_path"
    --cache-path "$cache_path"
    --config-path "$config_path"
    --security-path "$security_path"
    --disable-dependency-cache
    --manifest-cache local
    --disable-netrc
    --disable-keychain
    --force-resolved-versions
    --configuration release
    --jobs 2
)

TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" \
    --product PrimeNativeDecoderTokenizerCompatibilityProbe
TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests

readonly compiled_mlx="$scratch_path/checkouts/ergentics-mlx-swift"
readonly compiled_numerics="$scratch_path/checkouts/swift-numerics"
[[ -d "$compiled_mlx" && ! -L "$compiled_mlx" ]] ||
    fail "compatibility MLX checkout is missing"
[[ "$(git -C "$compiled_mlx" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "compatibility probe compiled a different MLX revision"
[[ "$(git -C "$compiled_mlx" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "compatibility probe compiled different MLX submodules"
[[ -z "$(git -C "$compiled_mlx" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compatibility MLX checkout is not clean"
[[ -d "$compiled_numerics" && ! -L "$compiled_numerics" ]] ||
    fail "compatibility Swift Numerics checkout is missing"
[[ "$(git -C "$compiled_numerics" rev-parse HEAD)" \
    == "$numerics_revision" ]] ||
    fail "compatibility probe compiled a different Swift Numerics revision"
[[ -z "$(git -C "$compiled_numerics" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compatibility Swift Numerics checkout is not clean"

readonly bin_path="$(TMPDIR="$runner_temp" swift build \
    "${swift_arguments[@]}" --show-bin-path)"
[[ "$bin_path" == "$scratch_path/arm64-apple-macosx/release" ]] ||
    fail "compatibility binary directory is outside the exact Release path"
[[ -d "$bin_path" && ! -L "$bin_path" ]] ||
    fail "compatibility binary directory is missing"
readonly probe_executable="$bin_path/PrimeNativeDecoderTokenizerCompatibilityProbe"
readonly test_bundle="$bin_path/PrimeNativeDecoderTokenizerCompatibilityValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderTokenizerCompatibilityValidationPackageTests"
[[ -x "$probe_executable" && ! -L "$probe_executable" ]] ||
    fail "Release tokenizer compatibility probe is missing"
[[ -d "$test_bundle" && ! -L "$test_bundle" ]] ||
    fail "tokenizer compatibility authority XCTest bundle is missing"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "tokenizer compatibility authority XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$probe_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release compatibility probe does not link ${framework}"
done
if otool -L "$probe_executable" | awk 'NR > 1 {print $1}' |
    grep -Eiq '(^|/)(lib)?(MLX|Cmlx)([._-]|\.framework/|$)'; then
    fail "Release compatibility probe dynamically links MLX or Cmlx"
fi

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1

set +e
TMPDIR="$runner_temp" xcrun xctest "$test_bundle" \
    2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${test_pipe_status[0]:-1}" -eq 0 ]] ||
    fail "tokenizer compatibility authority XCTest command failed"
[[ "${test_pipe_status[1]:-1}" -eq 0 ]] ||
    fail "tokenizer compatibility authority XCTest log capture failed"
[[ -s "$test_log" && ! -L "$test_log" ]] ||
    fail "tokenizer compatibility authority XCTest log is empty"
grep -Fq "Test Suite 'PrimeNativeDecoderTokenizerCompatibilityAuthorityTests' passed" \
    "$test_log" ||
    fail "tokenizer compatibility authority suite did not pass"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "tokenizer compatibility authority suite did not execute exactly one test"
! grep -Eiq '^Test (Case|Suite).*failed|^error:|skipped|Test skipped' \
    "$test_log" ||
    fail "tokenizer compatibility authority suite reported a failure or skip"

readonly staged_bundle="$bin_path/mlx-swift_Cmlx.bundle"
readonly staged_metallib="$staged_bundle/Contents/Resources/default.metallib"
[[ ! -e "$staged_bundle" && ! -L "$staged_bundle" ]] ||
    fail "sole tokenizer compatibility metallib bundle must be initially absent"
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "compatibility binary directory already contains a loader candidate"
mkdir -p "$staged_bundle/Contents/Resources"
cp -X "$metallib" "$staged_metallib"
chmod 444 "$staged_metallib"
[[ -f "$staged_metallib" && -s "$staged_metallib" \
    && ! -L "$staged_metallib" ]] ||
    fail "staged compatibility metallib is not a nonempty regular file"
[[ "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print | \
    wc -l | tr -d ' ')" == "1" ]] ||
    fail "compatibility binary directory has more than one loader candidate"
cmp -s "$metallib" "$staged_metallib" ||
    fail "compatibility metallib staging changed bytes"
[[ "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" ]] ||
    fail "staged compatibility metallib byte count changed"
[[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
    == "$metallib_sha256" ]] ||
    fail "staged compatibility metallib SHA-256 changed"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private compatibility working directory changed before launch"
[[ ! -e "$lease_path" && ! -L "$lease_path" ]] ||
    fail "compatibility Metal lease must be initially absent"

set +e
(
    cd "$private_cwd"
    env \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_PATH="$staged_metallib" \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METAL_LEASE_PATH="$lease_path" \
        "$probe_executable"
) 2>&1 | tee "$probe_log"
probe_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${probe_pipe_status[0]:-1}" -eq 0 ]] ||
    fail "Release tokenizer compatibility probe failed"
[[ "${probe_pipe_status[1]:-1}" -eq 0 ]] ||
    fail "Release tokenizer compatibility probe log capture failed"
[[ -s "$probe_log" && ! -L "$probe_log" ]] ||
    fail "Release tokenizer compatibility probe log is empty"
[[ "$(grep -Fc -- "$receipt_prefix" "$probe_log")" == "1" ]] ||
    fail "Release compatibility probe emitted an inexact receipt count"
readonly receipt_json="$(grep -F -- "$receipt_prefix" "$probe_log" |
    sed "s/^${receipt_prefix}//")"
printf '%s' "$receipt_json" | jq -e \
    --arg revision "$exact_revision" \
    --arg tree "$exact_tree" \
    --arg embedded_source_identity "$embedded_source_identity" \
    --arg sha256 "$metallib_sha256" \
    --argjson byte_count "$metallib_byte_count" \
    '
      type == "object"
      and (keys == ([
          "schema_version",
          "evidence_id",
          "authority_id",
          "executed_revision",
          "executed_tree",
          "executed_embedded_source_identity_sha256",
          "environment_policy",
          "launched_environment_validated_before_framework_access",
          "launched_environment_revalidated_after_evaluation",
          "release_instrumentation_evidence_absent",
          "core_graphics_bootstrap_observed",
          "enumerated_metal_device_count",
          "default_metal_device_matched_index_zero",
          "mlx_device_type",
          "mlx_device_index",
          "metal_lease_held_before_and_after_evaluation",
          "tokenizer_manifest_sha256",
          "tokenizer_replay_probe_sha256",
          "tokenizer_manifest_and_replay_validated",
          "source_text",
          "source_utf8_sha256",
          "canonical_text",
          "canonical_utf8_sha256",
          "primary_sequence_token_ids",
          "independent_sequence_token_ids",
          "sequence_token_ids_sha256",
          "primary_and_independent_token_paths_agree",
          "decoded_text",
          "decode_round_trip_established",
          "compatibility_identity_canonical_byte_count",
          "compatibility_identity_sha256",
          "compatibility_identity_validated",
          "configuration",
          "initialization_seed",
          "model_construction_count",
          "parameter_descriptor_count",
          "parameter_catalog_canonical_byte_count",
          "parameter_catalog_sha256",
          "parameter_path_set_matches",
          "parameter_path_order_matches",
          "parameter_path_order",
          "parameter_shapes_match",
          "parameter_dtypes_match",
          "observed_parameter_count",
          "observed_parameter_byte_count",
          "forward_invocation_count",
          "forward_mode",
          "decoder_kv_cache_used",
          "backward_invoked",
          "checkpoint_io_observed",
          "generation_invoked",
          "memory_cache_limit",
          "memory_cache_clear_count",
          "cache_cleared_before_parameter_materialization",
          "parameter_materialization_evaluation_count",
          "parameter_materialization_evaluation_api",
          "parameters_materialized_before_forward",
          "cache_cleared_after_parameter_materialization",
          "cache_cleared_before_forward_output_evaluation",
          "forward_output_evaluation_count",
          "forward_output_evaluation_api",
          "cache_cleared_after_forward_output_evaluation",
          "logits_readback_count",
          "logits_readback_api",
          "output_shape",
          "output_dtype",
          "output_element_count",
          "output_byte_count",
          "output_all_finite",
          "output_finite_value_count",
          "output_hash_encoding",
          "output_float32_bit_pattern_sha256",
          "metallib_artifact_relative_path",
          "metallib_byte_count",
          "metallib_sha256",
          "existing_metallib_candidate_count_before_execution",
          "existing_metallib_candidate_count_after_execution",
          "metallib_path_and_descriptor_reverified",
          "metal_library_validated_from_exact_url",
          "tokenizer_sequence_mechanics_compatibility_established",
          "tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_established",
          "tokenizer_functional_compatibility_established",
          "model_functional_compatibility_established",
          "native300m_model_allocation_observed",
          "decoder_forward_observed",
          "actual_parameter_catalog_projection_observed",
          "output_shape_dtype_and_finiteness_observed",
          "caller_supplied_revision_binding_is_independent_observation",
          "caller_expectation_is_artifact_admission",
          "metallib_artifact_provenance_established",
          "loaded_metallib_identity_independently_observed",
          "physical_gpu_identity_established",
          "tf32_static_value_directly_observed",
          "tf32_differential_observed",
          "nax_tf32_consumer_path_observed",
          "deterministic_seed_replay_observed",
          "padding_masking_or_ragged_batch_compatibility_established",
          "kv_cache_compatibility_established",
          "generated_token_detokenization_observed",
          "semantic_model_compatibility_established",
          "model_quality_established",
          "v2_manifest_defined",
          "v2_codec_defined",
          "checkpoint_container_io_implemented",
          "checkpoint_artifact_available",
          "checkpoint_artifact_provenance_established",
          "checkpoint_admission_granted",
          "native300m_checkpoint_write_authorized",
          "native300m_checkpoint_load_authorized",
          "optimizer_state_included",
          "rng_state_included",
          "data_cursor_included",
          "loss_backward_or_gradient_observed",
          "train_evaluate_surface_established",
          "training_resume_established",
          "training_execution_observed",
          "candidate_admission_granted",
          "trial_authorized",
          "canary_replacement_authorized",
          "quantization_authorized",
          "product_use_authorized",
          "publication_authorized",
          "frozen_subsystem_mutation_authorized",
          "external_rendering_dependency_authorized",
          "new_external_dependency_authorized",
          "process_exit_required_after_receipt",
          "status"
      ] | sort))
      and ((.environment_policy | keys) == ([
          "schemaVersion",
          "policyID",
          "policyVersion",
          "scope",
          "predecessorPolicyID",
          "predecessorPolicyVersion",
          "predecessorRemainsFrozen",
          "exactMLXRevision",
          "requiredEnvironmentKey",
          "requiredEnvironmentValue",
          "exclusiveEnvironmentKeyPrefix",
          "forbiddenEnvironmentKeyPrefixes",
          "numericMode",
          "comparisonPolicy",
          "authorityCeiling"
      ] | sort))
      and ((.configuration | keys) == ([
          "vocabulary_size",
          "model_width",
          "layer_count",
          "query_head_count",
          "key_value_head_count",
          "head_width",
          "intermediate_width",
          "maximum_sequence_length",
          "rope_theta_float32_bit_pattern",
          "rms_norm_epsilon_float32_bit_pattern",
          "unique_parameter_count"
      ] | sort))
      and .schema_version == 1
      and .evidence_id
          == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1"
      and .authority_id
          == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_v1"
      and .executed_revision == $revision
      and .executed_tree == $tree
      and .executed_embedded_source_identity_sha256
          == $embedded_source_identity
      and .environment_policy.policyID
          == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_environment_v1"
      and .environment_policy.requiredEnvironmentKey == "MLX_ENABLE_TF32"
      and .environment_policy.requiredEnvironmentValue == "0"
      and .environment_policy.exclusiveEnvironmentKeyPrefix == "MLX_"
      and .launched_environment_validated_before_framework_access == true
      and .launched_environment_revalidated_after_evaluation == true
      and .release_instrumentation_evidence_absent == true
      and .core_graphics_bootstrap_observed == true
      and .enumerated_metal_device_count == 1
      and .default_metal_device_matched_index_zero == true
      and .mlx_device_type == "gpu"
      and .mlx_device_index == 0
      and .metal_lease_held_before_and_after_evaluation == true
      and .tokenizer_manifest_sha256
          == "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7"
      and .tokenizer_replay_probe_sha256
          == "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb"
      and .tokenizer_manifest_and_replay_validated == true
      and .source_text == "A"
      and .source_utf8_sha256
          == "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd"
      and .canonical_text == "A"
      and .canonical_utf8_sha256
          == "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd"
      and .primary_sequence_token_ids == [1, 321, 70]
      and .independent_sequence_token_ids == [1, 321, 70]
      and .sequence_token_ids_sha256
          == "ee79e8d0748fc336565d6bd981be781c6eed4d34df268815e442de024127e8b3"
      and .primary_and_independent_token_paths_agree == true
      and .decoded_text == "A"
      and .decode_round_trip_established == true
      and .compatibility_identity_canonical_byte_count == 30553
      and .compatibility_identity_sha256
          == "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843"
      and .compatibility_identity_validated == true
      and .configuration.vocabulary_size == 512
      and .configuration.model_width == 1024
      and .configuration.layer_count == 24
      and .configuration.query_head_count == 16
      and .configuration.key_value_head_count == 4
      and .configuration.head_width == 64
      and .configuration.intermediate_width == 2816
      and .configuration.maximum_sequence_length == 2048
      and .configuration.rope_theta_float32_bit_pattern == 1176256512
      and .configuration.rms_norm_epsilon_float32_bit_pattern == 925353388
      and .configuration.unique_parameter_count == 271107072
      and .initialization_seed == 42
      and .model_construction_count == 1
      and .parameter_descriptor_count == 218
      and .parameter_catalog_canonical_byte_count == 28951
      and .parameter_catalog_sha256
          == "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1"
      and .parameter_path_set_matches == true
      and .parameter_path_order_matches == true
      and .parameter_path_order
          == "global_lexicographic_ascending_utf8_v1"
      and .parameter_shapes_match == true
      and .parameter_dtypes_match == true
      and .observed_parameter_count == 271107072
      and .observed_parameter_byte_count == 1084428288
      and .forward_invocation_count == 1
      and .forward_mode == "full_prefix_no_cache_position_zero"
      and .decoder_kv_cache_used == false
      and .backward_invoked == false
      and .checkpoint_io_observed == false
      and .generation_invoked == false
      and .memory_cache_limit == 0
      and .memory_cache_clear_count == 4
      and .cache_cleared_before_parameter_materialization == true
      and .parameter_materialization_evaluation_count == 1
      and .parameter_materialization_evaluation_api
          == "MLX.checkedEval(model)"
      and .parameters_materialized_before_forward == true
      and .cache_cleared_after_parameter_materialization == true
      and .cache_cleared_before_forward_output_evaluation == true
      and .forward_output_evaluation_count == 1
      and .forward_output_evaluation_api == "MLX.checkedEval(logits)"
      and .cache_cleared_after_forward_output_evaluation == true
      and .logits_readback_count == 1
      and .logits_readback_api == "MLX.MLXArray.asArray(Float.self)"
      and .output_shape == [1, 3, 512]
      and .output_dtype == "float32"
      and .output_element_count == 1536
      and .output_byte_count == 6144
      and .output_all_finite == true
      and .output_finite_value_count == 1536
      and .output_hash_encoding
          == "ordered_big_endian_float32_bit_patterns_v1"
      and (.output_float32_bit_pattern_sha256
          | test("^[0-9a-f]{64}$"))
      and .metallib_artifact_relative_path
          == "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
      and .metallib_byte_count == $byte_count
      and .metallib_sha256 == $sha256
      and .existing_metallib_candidate_count_before_execution == 1
      and .existing_metallib_candidate_count_after_execution == 1
      and .metallib_path_and_descriptor_reverified == true
      and .metal_library_validated_from_exact_url == true
      and .tokenizer_sequence_mechanics_compatibility_established == true
      and .tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_established == true
      and .tokenizer_functional_compatibility_established == true
      and .model_functional_compatibility_established == false
      and .native300m_model_allocation_observed == true
      and .decoder_forward_observed == true
      and .actual_parameter_catalog_projection_observed == true
      and .output_shape_dtype_and_finiteness_observed == true
      and ([
          .caller_supplied_revision_binding_is_independent_observation,
          .caller_expectation_is_artifact_admission,
          .metallib_artifact_provenance_established,
          .loaded_metallib_identity_independently_observed,
          .physical_gpu_identity_established,
          .tf32_static_value_directly_observed,
          .tf32_differential_observed,
          .nax_tf32_consumer_path_observed,
          .deterministic_seed_replay_observed,
          .padding_masking_or_ragged_batch_compatibility_established,
          .kv_cache_compatibility_established,
          .generated_token_detokenization_observed,
          .semantic_model_compatibility_established,
          .model_quality_established,
          .v2_manifest_defined,
          .v2_codec_defined,
          .checkpoint_container_io_implemented,
          .checkpoint_artifact_available,
          .checkpoint_artifact_provenance_established,
          .checkpoint_admission_granted,
          .native300m_checkpoint_write_authorized,
          .native300m_checkpoint_load_authorized,
          .optimizer_state_included,
          .rng_state_included,
          .data_cursor_included,
          .loss_backward_or_gradient_observed,
          .train_evaluate_surface_established,
          .training_resume_established,
          .training_execution_observed,
          .candidate_admission_granted,
          .trial_authorized,
          .canary_replacement_authorized,
          .quantization_authorized,
          .product_use_authorized,
          .publication_authorized,
          .frozen_subsystem_mutation_authorized,
          .external_rendering_dependency_authorized,
          .new_external_dependency_authorized
      ] | all(. == false))
      and .process_exit_required_after_receipt == true
      and .status
          == "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"
    ' >/dev/null ||
    fail "Release tokenizer compatibility receipt is invalid"
! grep -Eiq 'skipped|Test skipped|Metal is unavailable|^error:' "$probe_log" ||
    fail "Release tokenizer compatibility probe reported a skip or error"

[[ -f "$lease_path" && ! -L "$lease_path" ]] ||
    fail "tokenizer compatibility probe did not leave the secure Metal lease"
[[ "$(stat -f %Lp "$lease_path")" == "600" ]] ||
    fail "tokenizer compatibility Metal lease permissions changed"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private compatibility working directory changed during execution"
[[ "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print | \
    wc -l | tr -d ' ')" == "1" ]] ||
    fail "tokenizer compatibility loader candidate inventory changed"
cmp -s "$metallib" "$staged_metallib" ||
    fail "tokenizer compatibility metallib bytes changed during execution"
[[ "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" ]] ||
    fail "tokenizer compatibility metallib byte count changed during execution"
[[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
    == "$metallib_sha256" ]] ||
    fail "tokenizer compatibility metallib SHA-256 changed during execution"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime revision changed during tokenizer compatibility"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout changed during tokenizer compatibility"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX donor revision changed during tokenizer compatibility"
[[ "$(git -C "$mlx_source" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "MLX donor submodules changed during tokenizer compatibility"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor changed during tokenizer compatibility"
[[ "$(git -C "$compiled_mlx" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "compiled MLX revision changed after tokenizer compatibility"
[[ "$(git -C "$compiled_mlx" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "compiled MLX submodules changed after tokenizer compatibility"
[[ -z "$(git -C "$compiled_mlx" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compiled MLX checkout changed after tokenizer compatibility"
[[ "$(git -C "$compiled_numerics" rev-parse HEAD)" \
    == "$numerics_revision" ]] ||
    fail "compiled Swift Numerics revision changed after tokenizer compatibility"
[[ -z "$(git -C "$compiled_numerics" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compiled Swift Numerics checkout changed after tokenizer compatibility"

echo "OK: exact-head Prime tokenizer-to-random-initialized-Native-300M full-prefix witness passed"
echo "Prime tokenizer compatibility: metallib_sha256=$metallib_sha256 metallib_bytes=$metallib_byte_count"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The exact reviewed Prime main revision completed the bounded tokenizer-to-random-initialized-Native-300M full-prefix witness after the frozen 44-test suite and maintained-runtime closure.'
        echo 'The probe encoded source A as [1,321,70], matched all 218 live Native-300M parameter descriptors and 271107072 float32 elements to the V2 catalog, then completed one fixed-seed full-prefix no-cache forward with finite [1,3,512] logits on the singleton Metal device.'
        echo 'This observes one random-initialized Native-300M allocation and forward only; it performs no checkpoint I/O, decoder KV-cache use, generation, backward pass, optimizer step, or training, establishes no model quality, and grants no trial, canary, product, or publication authority.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

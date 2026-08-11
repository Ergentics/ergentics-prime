#!/usr/bin/env bash
# Exact-head hosted closure for the maintained Prime native-decoder runtime.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-runtime-closure: $*" >&2
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
readonly frozen_validation_build="$runner_temp/prime-native-decoder-build"
readonly frozen_mlx_checkout="$frozen_validation_build/checkouts/ergentics-mlx-swift"
readonly frozen_numerics_checkout="$frozen_validation_build/checkouts/swift-numerics"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly frozen_test_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly validation_root="$prime_root/Tests/PrimeNativeDecoderRuntimeClosureValidation"
readonly scratch_path="$runner_temp/prime-native-decoder-runtime-closure-build"
readonly cache_path="$runner_temp/prime-native-decoder-runtime-closure-cache"
readonly config_path="$runner_temp/prime-native-decoder-runtime-closure-config"
readonly security_path="$runner_temp/prime-native-decoder-runtime-closure-security"
readonly private_cwd="$runner_temp/prime-native-decoder-runtime-closure-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-runtime-closure-lease"
readonly lease_path="$lease_root/metal.lock"
readonly test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly receipt_prefix="PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT="

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
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not clean"
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
    fail "expected the frozen launcher to leave exactly one fresh metallib"
[[ "$(find "$frozen_metallib_root" -name default.metallib -print | wc -l | tr -d ' ')" \
    == "1" ]] ||
    fail "frozen metallib tree contains a non-regular candidate"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_byte_count" -le 67108864 ]] ||
    fail "fresh metallib byte count is outside the bounded expectation"
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
        fail "runtime closure path must be initially absent: $fresh_path"
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
    fail "private runtime working directory is not empty"

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
)

TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" \
    --product PrimeNativeDecoderRuntimeClosureProbe
TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests

readonly compiled_mlx="$scratch_path/checkouts/ergentics-mlx-swift"
readonly compiled_numerics="$scratch_path/checkouts/swift-numerics"
[[ -d "$compiled_mlx" && ! -L "$compiled_mlx" ]] ||
    fail "runtime closure MLX checkout is missing"
[[ "$(git -C "$compiled_mlx" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "runtime closure compiled a different MLX revision"
[[ "$(git -C "$compiled_mlx" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "runtime closure compiled different MLX submodules"
[[ -z "$(git -C "$compiled_mlx" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "runtime closure MLX checkout is not clean"
[[ -d "$compiled_numerics" && ! -L "$compiled_numerics" ]] ||
    fail "runtime closure Swift Numerics checkout is missing"
[[ "$(git -C "$compiled_numerics" rev-parse HEAD)" \
    == "$numerics_revision" ]] ||
    fail "runtime closure compiled a different Swift Numerics revision"
[[ -z "$(git -C "$compiled_numerics" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "runtime closure Swift Numerics checkout is not clean"

readonly bin_path="$(TMPDIR="$runner_temp" swift build \
    "${swift_arguments[@]}" --show-bin-path)"
[[ "$bin_path" == "$scratch_path/arm64-apple-macosx/release" ]] ||
    fail "runtime closure binary directory is outside the exact release path"
[[ -d "$bin_path" && ! -L "$bin_path" ]] ||
    fail "runtime closure binary directory is missing"
readonly probe_executable="$bin_path/PrimeNativeDecoderRuntimeClosureProbe"
readonly test_bundle="$bin_path/PrimeNativeDecoderRuntimeClosureValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderRuntimeClosureValidationPackageTests"
[[ -x "$probe_executable" && ! -L "$probe_executable" ]] ||
    fail "Release runtime closure probe is missing"
[[ -d "$test_bundle" && ! -L "$test_bundle" ]] ||
    fail "runtime closure authority XCTest bundle is missing"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "runtime closure authority XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$probe_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release runtime closure probe does not link ${framework}"
done
if otool -L "$probe_executable" | awk 'NR > 1 {print $1}' |
    grep -Eiq '(^|/)(lib)?(MLX|Cmlx)([._-]|\.framework/|$)'; then
    fail "Release runtime closure probe dynamically links MLX or Cmlx"
fi

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1

set +e
TMPDIR="$runner_temp" xcrun xctest "$test_bundle" \
    2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${test_pipe_status[0]:-1}" -eq 0 ]] ||
    fail "runtime closure authority XCTest command failed"
[[ "${test_pipe_status[1]:-1}" -eq 0 ]] ||
    fail "runtime closure authority XCTest log capture failed"
[[ -s "$test_log" && ! -L "$test_log" ]] ||
    fail "runtime closure authority XCTest log is empty"
grep -Fq "Test Suite 'PrimeNativeDecoderRuntimeClosureAuthorityTests' passed" \
    "$test_log" ||
    fail "runtime closure authority suite did not pass"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "runtime closure authority suite did not execute exactly one test"
! grep -Eiq '^Test (Case|Suite).*failed|^error:|skipped|Test skipped' \
    "$test_log" ||
    fail "runtime closure authority suite reported a failure or skip"

readonly staged_bundle="$bin_path/mlx-swift_Cmlx.bundle"
readonly staged_metallib="$staged_bundle/Contents/Resources/default.metallib"
[[ ! -e "$staged_bundle" && ! -L "$staged_bundle" ]] ||
    fail "sole SwiftPM metallib bundle candidate must be initially absent"
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "runtime closure binary directory already contains a loader candidate"
mkdir -p "$staged_bundle/Contents/Resources"
cp -X "$metallib" "$staged_metallib"
chmod 444 "$staged_metallib"
[[ -f "$staged_metallib" && -s "$staged_metallib" \
    && ! -L "$staged_metallib" ]] ||
    fail "staged runtime metallib is not a nonempty regular file"
[[ "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print | wc -l | tr -d ' ')" \
    == "1" ]] ||
    fail "runtime closure binary directory has more than one loader candidate"
cmp -s "$metallib" "$staged_metallib" ||
    fail "runtime metallib staging changed bytes"
[[ "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" ]] ||
    fail "staged runtime metallib byte count changed"
[[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
    == "$metallib_sha256" ]] ||
    fail "staged runtime metallib SHA-256 changed"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private runtime working directory changed before launch"
[[ ! -e "$private_cwd/default.metallib" \
    && ! -L "$private_cwd/default.metallib" ]] ||
    fail "private runtime cwd contains the fallback metallib candidate"
[[ ! -e "$lease_path" && ! -L "$lease_path" ]] ||
    fail "Metal lease must be initially absent"

set +e
(
    cd "$private_cwd"
    env \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_RUNTIME_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_RUNTIME_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_RUNTIME_METAL_LEASE_PATH="$lease_path" \
        "$probe_executable"
) 2>&1 | tee "$probe_log"
probe_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${probe_pipe_status[0]:-1}" -eq 0 ]] ||
    fail "Release runtime closure probe failed"
[[ "${probe_pipe_status[1]:-1}" -eq 0 ]] ||
    fail "Release runtime closure probe log capture failed"
[[ -s "$probe_log" && ! -L "$probe_log" ]] ||
    fail "Release runtime closure probe log is empty"
[[ "$(grep -Fc -- "$receipt_prefix" "$probe_log")" == "1" ]] ||
    fail "Release runtime closure probe emitted an inexact receipt count"
readonly receipt_json="$(grep -F -- "$receipt_prefix" "$probe_log" |
    sed "s/^${receipt_prefix}//")"
printf '%s' "$receipt_json" | jq -e \
    --arg sha256 "$metallib_sha256" \
    --argjson byte_count "$metallib_byte_count" \
    '
      type == "object"
      and (keys == ([
          "schema_version",
          "evidence_id",
          "authority_id",
          "plan",
          "environment_policy",
          "release_instrumentation",
          "executable",
          "metallib_expectation",
          "metallib",
          "metal_device",
          "mlx_initialization",
          "runtime_dependency_closure_established",
          "runtime_loaded_metallib_identity_established",
          "source_pinned_exclusive_candidate_inference_established",
          "loaded_metallib_identity_independently_observed",
          "runtime_metal_device_identity_established",
          "bounded_mlx_runtime_initialization_established",
          "caller_expectation_is_artifact_admission",
          "metallib_artifact_provenance_established",
          "decoder_model_initialization_established",
          "decoder_forward_observed",
          "checkpoint_io_observed",
          "checkpoint_admission_granted",
          "training_execution_observed",
          "product_use_authorized"
      ] | sort))
      and ((.plan | keys) == ([
          "schema_version",
          "plan_id",
          "authority_id",
          "compatibility_identity_schema",
          "compatibility_identity_canonical_byte_count",
          "compatibility_identity_sha256",
          "repaired_decoder_source_sha256",
          "exact_mlx_revision",
          "configuration",
          "initialization_probe_operation",
          "initialization_probe_dtype",
          "initialization_probe_shape",
          "initialization_probe_left_float32_bit_patterns",
          "initialization_probe_right_float32_bit_patterns",
          "initialization_probe_expected_float32_bit_patterns",
          "decoder_model_allocated",
          "decoder_forward_observed",
          "checkpoint_io_observed",
          "training_execution_observed"
      ] | sort))
      and ((.plan.configuration | keys) == ([
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
      and ((.release_instrumentation | keys) == ([
          "declaration",
          "observation"
      ] | sort))
      and ((.release_instrumentation.declaration | keys) == ([
          "policyID",
          "policyVersion",
          "inspectedImageScope",
          "machOInspectionAPI",
          "runtimeSymbolInspectionAPI",
          "forbiddenMachOSegmentNames",
          "searchedMachOSegmentNames",
          "forbiddenMachOSectionNames",
          "forbiddenRuntimeSymbolNames"
      ] | sort))
      and ((.release_instrumentation.observation | keys) == ([
          "mainExecutableImageName",
          "presentForbiddenMachOSegmentNames",
          "presentForbiddenMachOSections",
          "presentForbiddenRuntimeSymbolNames"
      ] | sort))
      and ((.executable | keys) == ([
          "capture_method",
          "executable_name",
          "byte_count",
          "sha256",
          "device_id",
          "inode",
          "path_and_descriptor_reverified"
      ] | sort))
      and ((.metallib_expectation | keys) == ([
          "schemaVersion",
          "artifactRelativePath",
          "byteCount",
          "sha256"
      ] | sort))
      and ((.metallib | keys) == ([
          "artifact_relative_path",
          "byte_count",
          "sha256",
          "device_id",
          "inode",
          "unique_candidate_count_before_execution",
          "unique_candidate_count_after_execution",
          "existing_candidate_count_before_execution",
          "existing_candidate_count_after_execution",
          "source_pinned_loader_identity_claim_kind",
          "path_and_descriptor_reverified",
          "metal_library_validated_from_exact_url"
      ] | sort))
      and ((.metal_device | keys) == ([
          "core_graphics_bootstrap_observed",
          "enumerated_device_count",
          "index_zero_name",
          "index_zero_registry_id",
          "index_zero_architecture_name",
          "index_zero_has_unified_memory",
          "index_zero_is_low_power",
          "index_zero_is_removable",
          "index_zero_is_headless",
          "default_device_matched_index_zero",
          "postflight_device_reverified",
          "mlx_device_identity_claim_kind",
          "physical_gpu_identity_required"
      ] | sort))
      and ((.mlx_initialization | keys) == ([
          "device_type",
          "device_index",
          "operation",
          "dtype",
          "shape",
          "left_float32_bit_patterns",
          "right_float32_bit_patterns",
          "output_float32_bit_patterns",
          "evaluation_api",
          "readback_api",
          "exact_output_established",
          "launched_environment_revalidated_after_evaluation",
          "tf32_static_value_directly_observed",
          "tf32_differential_observed",
          "nax_tf32_consumer_path_observed"
      ] | sort))
      and .schema_version == 1
      and .evidence_id
          == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1"
      and .environment_policy.requiredEnvironmentKey
          == "MLX_ENABLE_TF32"
      and .environment_policy.requiredEnvironmentValue == "0"
      and .environment_policy.exclusiveEnvironmentKeyPrefix == "MLX_"
      and .release_instrumentation.observation
          .presentForbiddenMachOSegmentNames == []
      and .release_instrumentation.observation
          .presentForbiddenMachOSections == []
      and .release_instrumentation.observation
          .presentForbiddenRuntimeSymbolNames == []
      and .executable.executable_name
          == "PrimeNativeDecoderRuntimeClosureProbe"
      and .executable.path_and_descriptor_reverified == true
      and .metallib_expectation.byteCount == $byte_count
      and .metallib_expectation.sha256 == $sha256
      and .metallib.artifact_relative_path
          == "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
      and .metallib.byte_count == $byte_count
      and .metallib.sha256 == $sha256
      and .metallib.existing_candidate_count_before_execution == 1
      and .metallib.existing_candidate_count_after_execution == 1
      and .metallib.path_and_descriptor_reverified == true
      and .metallib.metal_library_validated_from_exact_url == true
      and .metal_device.core_graphics_bootstrap_observed == true
      and .metal_device.enumerated_device_count == 1
      and .metal_device.default_device_matched_index_zero == true
      and .metal_device.postflight_device_reverified == true
      and .metal_device.physical_gpu_identity_required == false
      and .mlx_initialization.device_type == "gpu"
      and .mlx_initialization.device_index == 0
      and .mlx_initialization.dtype == "float32"
      and .mlx_initialization.shape == [2, 2]
      and .mlx_initialization.output_float32_bit_patterns
          == .plan.initialization_probe_expected_float32_bit_patterns
      and .mlx_initialization.exact_output_established == true
      and .mlx_initialization
          .launched_environment_revalidated_after_evaluation == true
      and .mlx_initialization.tf32_static_value_directly_observed == false
      and .mlx_initialization.tf32_differential_observed == false
      and .mlx_initialization.nax_tf32_consumer_path_observed == false
      and .plan.configuration.vocabulary_size == 512
      and .plan.decoder_model_allocated == false
      and .plan.decoder_forward_observed == false
      and .plan.checkpoint_io_observed == false
      and .plan.training_execution_observed == false
      and .runtime_dependency_closure_established == true
      and .runtime_loaded_metallib_identity_established == false
      and .source_pinned_exclusive_candidate_inference_established == true
      and .loaded_metallib_identity_independently_observed == false
      and .runtime_metal_device_identity_established == true
      and .bounded_mlx_runtime_initialization_established == true
      and .caller_expectation_is_artifact_admission == false
      and .metallib_artifact_provenance_established == false
      and .decoder_model_initialization_established == false
      and .decoder_forward_observed == false
      and .checkpoint_io_observed == false
      and .checkpoint_admission_granted == false
      and .training_execution_observed == false
      and .product_use_authorized == false
    ' >/dev/null ||
    fail "Release runtime closure receipt is invalid or not expectation-bound"
! grep -Eiq 'skipped|Test skipped|Metal is unavailable|^error:' "$probe_log" ||
    fail "Release runtime closure probe reported a skip or error"

[[ -f "$lease_path" && ! -L "$lease_path" ]] ||
    fail "runtime closure did not leave the secure Metal lease file"
[[ "$(stat -f %Lp "$lease_path")" == "600" ]] ||
    fail "runtime closure Metal lease permissions changed"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private runtime working directory changed during execution"
[[ "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print | wc -l | tr -d ' ')" \
    == "1" ]] ||
    fail "runtime closure loader candidate inventory changed"
cmp -s "$metallib" "$staged_metallib" ||
    fail "runtime metallib bytes changed during execution"
[[ "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" ]] ||
    fail "runtime metallib byte count changed during execution"
[[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
    == "$metallib_sha256" ]] ||
    fail "runtime metallib SHA-256 changed during execution"

[[ -d "$frozen_mlx_checkout" && ! -L "$frozen_mlx_checkout" ]] ||
    fail "frozen launcher compiled MLX checkout is missing"
[[ "$(git -C "$frozen_mlx_checkout" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "frozen launcher compiled a different MLX revision"
[[ "$(git -C "$frozen_mlx_checkout" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "frozen launcher compiled different MLX submodules"
[[ -z "$(git -C "$frozen_mlx_checkout" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "frozen launcher MLX checkout changed"
[[ -d "$frozen_numerics_checkout" && ! -L "$frozen_numerics_checkout" ]] ||
    fail "frozen launcher Swift Numerics checkout is missing"
[[ "$(git -C "$frozen_numerics_checkout" rev-parse HEAD)" \
    == "$numerics_revision" ]] ||
    fail "frozen launcher compiled a different Swift Numerics revision"
[[ -z "$(git -C "$frozen_numerics_checkout" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "frozen launcher Swift Numerics checkout changed"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime revision changed during the runtime closure"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout changed during the runtime closure"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX donor revision changed during the runtime closure"
[[ "$(git -C "$mlx_source" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "MLX donor submodules changed during the runtime closure"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor changed during the runtime closure"
[[ "$(git -C "$compiled_mlx" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "runtime closure MLX revision changed after execution"
[[ "$(git -C "$compiled_mlx" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] ||
    fail "runtime closure MLX submodules changed after execution"
[[ -z "$(git -C "$compiled_mlx" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "runtime closure MLX checkout changed after execution"
[[ "$(git -C "$compiled_numerics" rev-parse HEAD)" \
    == "$numerics_revision" ]] ||
    fail "runtime closure Swift Numerics revision changed after execution"
[[ -z "$(git -C "$compiled_numerics" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "runtime closure Swift Numerics checkout changed after execution"

echo "OK: exact-head maintained native-decoder runtime dependency, metallib, singleton-device, and MLX initialization closure passed"
echo "Prime runtime closure: metallib_sha256=$metallib_sha256 metallib_bytes=$metallib_byte_count"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The exact reviewed Prime main revision completed the bounded maintained native-decoder runtime closure in a dedicated Release process after the frozen 44-test Metal suite.'
        echo "The child retained only MLX_ENABLE_TF32=0 in the MLX namespace, used the same-job fresh pinned-source metallib (${metallib_byte_count} bytes, SHA-256 ${metallib_sha256}), held the Prime Metal lease, and completed the explicit float32 2x2 GPU matmul receipt."
        echo 'This source-pinned exclusive-candidate inference is not independent loaded-path instrumentation and grants no decoder forward, Native-300M allocation, checkpoint I/O or admission, training, trial, canary, product, or publication authority.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

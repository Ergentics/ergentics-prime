#!/usr/bin/env bash
# One-shot reviewed-main root-identity repair execution of one public
# Native-300M V2 checkpoint write and one public fresh load. The artifact
# remains execution/job-local and is removed by this supervisor only after the
# receipt is validated.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-checkpoint-v2-io-root-identity-repair: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly base_revision="1a69407a8fbd5f141e8ece584066b8dcfa6f606f"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly expected_mlx_submodules=$' ce45c52505c8158ea48d2a54e8caae05efd86bfe Source/Cmlx/mlx (v0.31.1)\n 0726ca922fc902c4c61ef9c27d94132be418e945 Source/Cmlx/mlx-c (v0.6.0)'
readonly maximum_checkpoint_bytes=1101205504
readonly required_free_multiplier=3
readonly required_free_bytes=3303616512
readonly artifact_relative_path="checkpoint-v2-native300m-seed43-root-identity-repair.safetensors"
readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly active_root_log="$runner_temp/prime-active-root-tests.log"
readonly checkpoint_v2_log="$runner_temp/prime-checkpoint-v2-tests.log"
readonly checkpoint_v2_io_log="$runner_temp/prime-checkpoint-v2-io-tests.log"
readonly checkpoint_v2_io_execution_pure_test_log="$runner_temp/prime-checkpoint-v2-io-execution-pure-tests.log"
readonly repair_execution_pure_test_log="$runner_temp/prime-checkpoint-v2-io-root-identity-repair-execution-pure-tests.log"
readonly frozen_metal_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly tokenizer_test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly tokenizer_probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"
readonly validation_root="$prime_root/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation"
readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly scratch_path="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-build"
readonly cache_path="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-cache"
readonly config_path="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-config"
readonly security_path="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-security"
readonly private_cwd="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-cwd"
readonly artifact_root="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-artifact-root"
readonly lease_root="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-lease"
readonly lease_path="$lease_root/metal.lock"
readonly test_log="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-authority-tests.log"
readonly probe_log="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-probe.log"
readonly receipt_base64="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-receipt.b64"
readonly receipt_json="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-receipt.json"
readonly receipt_identity_json="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-identity.json"
readonly receipt_tensor_bindings_json="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-tensor-bindings.json"
readonly receipt_manifest_json="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-manifest.json"
readonly receipt_external_binding_json="$runner_temp/prime-native-decoder-checkpoint-v2-io-root-identity-repair-external-binding.json"
readonly receipt_begin="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_BEGIN="
readonly receipt_chunk="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_CHUNK="
readonly receipt_end="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_END="

# On failure, remove only the exact fixed root when its complete inventory is
# either empty or the single fixed immutable leaf with conservative metadata.
# Any unexpected entry, symlink, owner, mode, link count, or device mismatch
# leaves the root untouched for runner teardown. This never recursively removes
# the artifact root and cannot turn a failed/truncated probe into evidence.
cleanup_failed_fixed_artifact_root() {
    local exit_status="$1"
    local fixed_leaf="$artifact_root/$artifact_relative_path"
    local physical_root inventory
    [[ "$exit_status" -ne 0 ]] || return 0
    [[ -d "$artifact_root" && ! -L "$artifact_root" ]] ||
        return "$exit_status"
    physical_root="$(cd "$artifact_root" 2>/dev/null && pwd -P)" ||
        return "$exit_status"
    [[ "$physical_root" == "$artifact_root" \
        && "$(stat -f %u "$artifact_root" 2>/dev/null)" == "$(id -u)" \
        && "$(stat -f %Lp "$artifact_root" 2>/dev/null)" == "700" ]] ||
        return "$exit_status"
    inventory="$(find "$artifact_root" -mindepth 1 -print \
        2>/dev/null)" || return "$exit_status"
    if [[ -z "$inventory" ]]; then
        rmdir -- "$artifact_root" 2>/dev/null || true
    elif [[ "$inventory" == "$fixed_leaf" \
        && -f "$fixed_leaf" && ! -L "$fixed_leaf" \
        && "$(stat -f %u "$fixed_leaf" 2>/dev/null)" == "$(id -u)" \
        && "$(stat -f %l "$fixed_leaf" 2>/dev/null)" == "1" \
        && "$(stat -f %Lp "$fixed_leaf" 2>/dev/null)" == "444" \
        && "$(stat -f %d "$fixed_leaf" 2>/dev/null)" \
            == "$(stat -f %d "$artifact_root" 2>/dev/null)" ]]; then
        unlink "$fixed_leaf" 2>/dev/null || true
        [[ ! -e "$fixed_leaf" && ! -L "$fixed_leaf" ]] &&
            rmdir -- "$artifact_root" 2>/dev/null || true
    fi
    return "$exit_status"
}

for command_name in \
    awk base64 bash cat chmod cmp cp df env find git grep id jq mkdir otool \
    pwd rm rmdir sed shasum stat swift tail tee tr uname unlink wc xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

# This guard precedes predecessor scratch reclamation, this package build, and
# every model/checkpoint operation. It makes the command a direct-successor,
# first-attempt, hosted-main one-shot rather than a persistent main-push load.
[[ "${GITHUB_ACTIONS:-}" == "true" ]] ||
    fail "execution requires GitHub Actions"
[[ "${RUNNER_ENVIRONMENT:-}" == "github-hosted" ]] ||
    fail "execution requires a GitHub-hosted runner"
[[ "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" ]] ||
    fail "execution repository is not exact"
[[ "${GITHUB_EVENT_NAME:-}" == "push" ]] ||
    fail "execution requires a push event"
[[ "${GITHUB_REF:-}" == "refs/heads/main" ]] ||
    fail "execution requires refs/heads/main"
[[ "${GITHUB_RUN_ATTEMPT:-}" == "1" ]] ||
    fail "execution reruns are forbidden"
[[ "${RUNNER_OS:-}" == "macOS" ]] ||
    fail "execution requires RUNNER_OS=macOS"
[[ "${RUNNER_ARCH:-}" == "ARM64" ]] ||
    fail "execution requires RUNNER_ARCH=ARM64"
[[ "${GITHUB_SHA:-}" == "$exact_revision" ]] ||
    fail "GitHub SHA does not equal EXACT_REVISION"
[[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]] ||
    fail "execution requires macOS arm64"
[[ "$exact_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact Prime revision"
[[ "$mlx_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid MLX revision"
[[ -d "$runner_temp" && ! -L "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not a real directory"
[[ "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not its physical absolute path"
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
readonly parent_line="$(git -C "$prime_root" rev-list --parents -n 1 HEAD)"
IFS=' ' read -r executed_commit first_parent second_parent extra_parent \
    <<< "$parent_line"
[[ "$executed_commit" == "$exact_revision" && -n "$first_parent" \
    && -n "$second_parent" && -z "${extra_parent:-}" ]] ||
    fail "executed commit is not an exact two-parent merge"
[[ "$first_parent" == "$base_revision" ]] ||
    fail "executed merge is not a direct successor of the authorized base"
[[ "$second_parent" =~ ^[0-9a-f]{40}$ && "$second_parent" != "$first_parent" ]] ||
    fail "reviewed second parent is invalid"
git -C "$prime_root" cat-file -e "${first_parent}^{commit}"
git -C "$prime_root" cat-file -e "${second_parent}^{commit}"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
readonly reviewed_head_tree="$(git -C "$prime_root" rev-parse "${second_parent}^{tree}")"
[[ "$exact_tree" == "$reviewed_head_tree" ]] ||
    fail "merge tree differs from reviewed second-parent tree"

[[ -f "$embedded_provenance" && ! -L "$embedded_provenance" ]] ||
    fail "embedded Prime provenance source is missing"
readonly embedded_matches="$(grep -Eo '"[0-9a-f]{64}"' \
    "$embedded_provenance" || true)"
[[ "$(printf '%s\n' "$embedded_matches" |
    awk 'NF { count += 1 } END { print count + 0 }')" == "1" ]] ||
    fail "embedded provenance must contain one source identity"
readonly embedded_source_identity="${embedded_matches//\"/}"

[[ -d "$mlx_bare" && ! -L "$mlx_bare" ]] ||
    fail "missing exact MLX bare repository"
[[ -d "$mlx_source" && ! -L "$mlx_source" ]] ||
    fail "missing exact MLX donor worktree"
[[ "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
    == "$mlx_revision" ]] || fail "MLX bare revision changed"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX donor revision changed"
[[ "$(git -C "$mlx_source" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] || fail "MLX submodules changed"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor is dirty"

readonly predecessor_logs=(
    "$active_root_log"
    "$checkpoint_v2_log"
    "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_pure_test_log"
    "$repair_execution_pure_test_log"
    "$frozen_metal_log"
    "$runtime_test_log"
    "$runtime_probe_log"
    "$tokenizer_test_log"
    "$tokenizer_probe_log"
)
[[ "${#predecessor_logs[@]}" -eq 10 ]] || fail "predecessor log inventory"
for predecessor_log in "${predecessor_logs[@]}"; do
    [[ -s "$predecessor_log" && ! -L "$predecessor_log" ]] ||
        fail "missing predecessor log: $predecessor_log"
done
grep -Eq 'Executed [1-9][0-9]* tests?, with 0 failures' "$active_root_log" ||
    fail "focused active-root contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint V2 identity contract did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint V2 I/O declarative contract did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' \
    "$checkpoint_v2_io_execution_pure_test_log" ||
    fail "checkpoint V2 I/O execution and failure-observation contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' \
    "$repair_execution_pure_test_log" ||
    fail "checkpoint V2 I/O root-identity repair contract did not complete"
grep -Eq 'Executed 44 tests, with 0 failures' "$frozen_metal_log" ||
    fail "frozen 44-test Metal suite did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "runtime authority contract did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer authority contract did not complete"
for predecessor_log in \
    "$checkpoint_v2_log" "$checkpoint_v2_io_log" \
    "$checkpoint_v2_io_execution_pure_test_log" \
    "$repair_execution_pure_test_log" "$frozen_metal_log" \
    "$runtime_test_log" "$tokenizer_test_log"; do
    ! grep -Eiq 'skipped|Test skipped|Metal is unavailable|^error:' \
        "$predecessor_log" || fail "predecessor log failed: $predecessor_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' \
    "$runtime_probe_log")" == "1" ]] || fail "runtime receipt count"
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    "$tokenizer_probe_log")" == "1" ]] || fail "tokenizer receipt count"
readonly runtime_receipt="$(grep -E \
    '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log" |
    sed 's/^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=//')"
printf '%s' "$runtime_receipt" | jq -e \
    '.evidence_id == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1"
     and .runtime_dependency_closure_established == true
     and .checkpoint_io_observed == false' >/dev/null ||
    fail "runtime predecessor receipt"
readonly tokenizer_receipt="$(grep -E \
    '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    "$tokenizer_probe_log" |
    sed 's/^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=//')"
printf '%s' "$tokenizer_receipt" | jq -e \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    '.executed_revision == $revision and .executed_tree == $tree
     and .status == "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"' \
    >/dev/null || fail "tokenizer predecessor receipt"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "fresh metallib root is missing"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" -type f -name default.metallib -print)
[[ "$metallib_count" -eq 1 && -f "$metallib" && -s "$metallib" \
    && ! -L "$metallib" ]] || fail "expected one fresh metallib"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_byte_count" -le 67108864 ]] || fail "metallib byte count"
[[ "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] || fail "metallib SHA-256"

readonly reclaimable_relative_paths=(
    prime-active-root-build prime-active-root-cache
    prime-active-root-config prime-active-root-security
    prime-checkpoint-v2-build prime-checkpoint-v2-cache
    prime-checkpoint-v2-config prime-checkpoint-v2-security
    prime-checkpoint-v2-io-build prime-checkpoint-v2-io-cache
    prime-checkpoint-v2-io-config prime-checkpoint-v2-io-security
    prime-checkpoint-v2-io-execution-pure-build
    prime-checkpoint-v2-io-execution-pure-cache
    prime-checkpoint-v2-io-execution-pure-config
    prime-checkpoint-v2-io-execution-pure-security
    prime-checkpoint-v2-io-root-identity-repair-execution-pure-build
    prime-checkpoint-v2-io-root-identity-repair-execution-pure-cache
    prime-checkpoint-v2-io-root-identity-repair-execution-pure-config
    prime-checkpoint-v2-io-root-identity-repair-execution-pure-security
    prime-native-decoder-build prime-native-decoder-cache
    prime-native-decoder-config prime-native-decoder-security
    prime-native-decoder-runtime-closure-build
    prime-native-decoder-runtime-closure-cache
    prime-native-decoder-runtime-closure-config
    prime-native-decoder-runtime-closure-security
    prime-native-decoder-tokenizer-compatibility-build
    prime-native-decoder-tokenizer-compatibility-cache
    prime-native-decoder-tokenizer-compatibility-config
    prime-native-decoder-tokenizer-compatibility-security
)
[[ "${#reclaimable_relative_paths[@]}" -eq 32 ]] ||
    fail "reclamation allowlist count"
for relative in "${reclaimable_relative_paths[@]}"; do
    target="$runner_temp/$relative"
    [[ "$target" == "$runner_temp"/prime-* ]] ||
        fail "reclamation path escaped RUNNER_TEMP"
    [[ -d "$target" && ! -L "$target" ]] ||
        fail "reclamation target is not a real directory: $target"
    [[ "$(cd "$target" && pwd -P)" == "$target" ]] ||
        fail "reclamation target is not physical: $target"
    [[ "$(stat -f %u "$target")" == "$(id -u)" ]] ||
        fail "reclamation target is not runner-owned: $target"
done
for relative in "${reclaimable_relative_paths[@]}"; do
    target="$runner_temp/$relative"
    rm -rf -- "$target"
    [[ ! -e "$target" && ! -L "$target" ]] ||
        fail "reclamation target remains: $target"
done
echo "Checkpoint V2 I/O root-identity repair: reclaimed exactly 32 authorized predecessor temporary directories after validating 10 logs and 2 receipts"

available_bytes() {
    local value
    value="$(df -Pk "$runner_temp" |
        awk 'NR == 2 { printf "%.0f", $4 * 1024 }')"
    [[ "$value" =~ ^[0-9]+$ ]] || fail "invalid available-byte result"
    printf '%s' "$value"
}
readonly available_after_reclamation="$(available_bytes)"
[[ "$available_after_reclamation" -ge "$required_free_bytes" ]] ||
    fail "less than 3x checkpoint cap free after reclamation"

for fresh_path in \
    "$scratch_path" "$cache_path" "$config_path" "$security_path" \
    "$private_cwd" "$artifact_root" "$lease_root" "$test_log" \
    "$probe_log" "$receipt_base64" "$receipt_json" \
    "$receipt_identity_json" "$receipt_tensor_bindings_json" \
    "$receipt_manifest_json" "$receipt_external_binding_json"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "execution path must be initially absent: $fresh_path"
done
trap 'cleanup_failed_fixed_artifact_root "$?"' EXIT
mkdir -p "$scratch_path" "$cache_path" "$config_path" "$security_path"

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
    --product PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe
TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests
readonly compiled_mlx="$scratch_path/checkouts/ergentics-mlx-swift"
readonly compiled_numerics="$scratch_path/checkouts/swift-numerics"
[[ "$(git -C "$compiled_mlx" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "compiled MLX revision"
[[ "$(git -C "$compiled_mlx" submodule status --recursive)" \
    == "$expected_mlx_submodules" ]] || fail "compiled MLX submodules"
[[ "$(git -C "$compiled_numerics" rev-parse HEAD)" \
    == "$numerics_revision" ]] || fail "compiled Numerics revision"
[[ -z "$(git -C "$compiled_mlx" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compiled MLX checkout is dirty"
[[ -z "$(git -C "$compiled_numerics" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "compiled Numerics checkout is dirty"
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1

readonly available_after_build="$(available_bytes)"
[[ "$available_after_build" -ge "$required_free_bytes" ]] ||
    fail "less than 3x checkpoint cap free after Release build"
readonly bin_path="$(TMPDIR="$runner_temp" swift build \
    "${swift_arguments[@]}" --show-bin-path)"
[[ "$bin_path" == "$scratch_path/arm64-apple-macosx/release" ]] ||
    fail "Release binary directory is not exact"
readonly probe_executable="$bin_path/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe"
readonly test_bundle="$bin_path/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidationPackageTests"
[[ -x "$probe_executable" && ! -L "$probe_executable" ]] ||
    fail "Release checkpoint probe is missing"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "authority XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$probe_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release checkpoint probe does not link ${framework}"
done
if otool -L "$probe_executable" | awk 'NR > 1 {print $1}' |
    grep -Eiq '(^|/)(lib)?(MLX|Cmlx)([._-]|\.framework/|$)'; then
    fail "Release checkpoint probe dynamically links MLX or Cmlx"
fi

set +e
TMPDIR="$runner_temp" xcrun xctest "$test_bundle" 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${test_pipe_status[0]:-1}" -eq 0 \
    && "${test_pipe_status[1]:-1}" -eq 0 ]] || fail "authority XCTest failed"
grep -Fq "Test Suite 'PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests' passed" \
    "$test_log" || fail "authority suite did not pass"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "authority suite did not execute exactly one test"
! grep -Eiq '^Test (Case|Suite).*failed|^error:|skipped|Test skipped' \
    "$test_log" || fail "authority suite failed or skipped"

readonly staged_bundle="$bin_path/mlx-swift_Cmlx.bundle"
readonly staged_metallib="$staged_bundle/Contents/Resources/default.metallib"
[[ ! -e "$staged_bundle" && ! -L "$staged_bundle" ]] ||
    fail "sole metallib bundle must be initially absent"
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Release bin already contains a loader candidate"
mkdir -p "$staged_bundle/Contents/Resources"
cp -X "$metallib" "$staged_metallib"
chmod 444 "$staged_metallib"
[[ -f "$staged_metallib" && -s "$staged_metallib" \
    && ! -L "$staged_metallib" ]] || fail "staged metallib"
[[ "$(stat -f %Lp "$staged_metallib")" == "444" ]] ||
    fail "staged metallib mode"
cmp -s "$metallib" "$staged_metallib" || fail "staged metallib bytes"
[[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
    == "$metallib_sha256" ]] || fail "staged metallib SHA-256"

mkdir -p "$private_cwd" "$artifact_root" "$lease_root"
chmod 700 "$private_cwd" "$artifact_root" "$lease_root"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" \
    && -z "$(find "$artifact_root" -mindepth 1 -print)" ]] ||
    fail "private execution roots are not empty"
[[ ! -e "$lease_path" && ! -L "$lease_path" ]] || fail "lease exists"

set +e
(
    cd "$private_cwd"
    env \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_EXECUTED_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_FIRST_PARENT_REVISION="$first_parent" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_SECOND_PARENT_REVISION="$second_parent" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_EXECUTED_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_REVIEWED_HEAD_TREE="$reviewed_head_tree" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_ARTIFACT_ROOT_PATH="$artifact_root" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_METALLIB_PATH="$staged_metallib" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_METAL_LEASE_PATH="$lease_path" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_AVAILABLE_BYTES_AFTER_RECLAMATION="$available_after_reclamation" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_AVAILABLE_BYTES_AFTER_BUILD="$available_after_build" \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_PREDECESSOR_VALIDATED_LOG_COUNT=10 \
        PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_PREDECESSOR_VALIDATED_RECEIPT_COUNT=2 \
        "$probe_executable"
) 2>&1 | tee "$probe_log"
probe_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${probe_pipe_status[0]:-1}" -eq 0 \
    && "${probe_pipe_status[1]:-1}" -eq 0 ]] || fail "Release probe failed"
[[ -s "$probe_log" && ! -L "$probe_log" ]] || fail "probe log is empty"
[[ "$(grep -Ec "^${receipt_begin}" "$probe_log")" == "1" ]] ||
    fail "receipt BEGIN count"
[[ "$(grep -Ec "^${receipt_end}" "$probe_log")" == "1" ]] ||
    fail "receipt END count"
readonly begin_line="$(grep -E "^${receipt_begin}" "$probe_log")"
readonly begin_payload="${begin_line#${receipt_begin}}"
readonly begin_pattern='^byte_count=([0-9]+);sha256=([0-9a-f]{64});encoding=rfc4648_base64_no_wrap;chunk_character_count=4096;chunk_count=([0-9]+);evidence_id=ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1;authority_id=ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1$'
[[ "$begin_payload" =~ $begin_pattern ]] || fail "receipt BEGIN shape"
readonly receipt_byte_count="${BASH_REMATCH[1]}"
readonly receipt_sha256="${BASH_REMATCH[2]}"
readonly receipt_chunk_count="${BASH_REMATCH[3]}"
[[ "$receipt_byte_count" -gt 16384 && "$receipt_byte_count" -le 262144 ]] ||
    fail "receipt canonical byte count"
readonly expected_base64_count=$(( (receipt_byte_count + 2) / 3 * 4 ))
readonly expected_chunk_count=$(( (expected_base64_count + 4095) / 4096 ))
[[ "$receipt_chunk_count" -eq "$expected_chunk_count" \
    && "$receipt_chunk_count" -gt 1 && "$receipt_chunk_count" -le 86 ]] ||
    fail "receipt chunk count"

cleanup_receipt_transport() {
    rm -f -- \
        "$receipt_base64" "$receipt_json" \
        "$receipt_identity_json" "$receipt_tensor_bindings_json" \
        "$receipt_manifest_json" "$receipt_external_binding_json"
}
cleanup_receipt_transport_and_failed_fixed_artifact_root() {
    local exit_status="$1"
    cleanup_receipt_transport
    cleanup_failed_fixed_artifact_root "$exit_status"
}
trap 'cleanup_receipt_transport_and_failed_fixed_artifact_root "$?"' EXIT
readonly prior_umask="$(umask)"
umask 077
set -o noclobber
for receipt_file in \
    "$receipt_base64" "$receipt_json" \
    "$receipt_identity_json" "$receipt_tensor_bindings_json" \
    "$receipt_manifest_json" "$receipt_external_binding_json"; do
    : > "$receipt_file" || fail "exclusive receipt file creation: $receipt_file"
done
set +o noclobber
umask "$prior_umask"
for receipt_file in \
    "$receipt_base64" "$receipt_json" \
    "$receipt_identity_json" "$receipt_tensor_bindings_json" \
    "$receipt_manifest_json" "$receipt_external_binding_json"; do
    [[ -f "$receipt_file" && ! -L "$receipt_file" \
        && "$(stat -f %u "$receipt_file")" == "$(id -u)" \
        && "$(stat -f %l "$receipt_file")" == "1" \
        && "$(stat -f %Lp "$receipt_file")" == "600" ]] ||
        fail "unsafe private receipt transport file: $receipt_file"
done
readonly expected_end="${receipt_end}chunk_count=${receipt_chunk_count};sha256=${receipt_sha256}"
chunk_index=0
transport_state=before
while IFS= read -r line; do
    case "$transport_state" in
        before)
            if [[ "$line" == "$begin_line" ]]; then
                transport_state=chunks
            elif [[ "$line" == "$receipt_begin"* \
                || "$line" == "$receipt_chunk"* \
                || "$line" == "$receipt_end"* ]]; then
                fail "receipt marker occurred before the exact BEGIN"
            fi
            ;;
        chunks)
            if [[ "$line" == "$receipt_chunk"* ]]; then
            chunk_body="${line#${receipt_chunk}}"
            chunk_pattern='^([0-9]{6}):([A-Za-z0-9+/]+={0,2})$'
            [[ "$chunk_body" =~ $chunk_pattern ]] || fail "receipt chunk shape"
            ordinal="${BASH_REMATCH[1]}"
            payload="${BASH_REMATCH[2]}"
            expected_ordinal="$(printf '%06d' "$chunk_index")"
            [[ "$ordinal" == "$expected_ordinal" ]] ||
                fail "receipt chunks are not contiguous in emitted order"
            payload_length="${#payload}"
            [[ "$payload_length" -gt 0 && $((payload_length % 4)) -eq 0 ]] ||
                fail "receipt chunk alignment"
            if [[ "$chunk_index" -lt $((receipt_chunk_count - 1)) ]]; then
                [[ "$payload_length" -eq 4096 ]] || fail "short nonfinal chunk"
            else
                [[ "$payload_length" -le 4096 ]] || fail "oversized final chunk"
            fi
            [[ "${#line}" -lt 16384 ]] || fail "receipt chunk line too long"
            printf '%s' "$payload" >> "$receipt_base64"
            chunk_index=$((chunk_index + 1))
            elif [[ "$line" == "$expected_end" ]]; then
                [[ "$chunk_index" -eq "$receipt_chunk_count" ]] ||
                    fail "receipt END occurred before all chunks"
                transport_state=after
            else
                fail "non-chunk line interleaved between receipt BEGIN and END"
            fi
            ;;
        after)
            fail "receipt END was not the final probe-log line"
            ;;
        *)
            fail "invalid receipt transport parser state"
            ;;
    esac
done < "$probe_log"
[[ "$transport_state" == "after" \
    && "$chunk_index" -eq "$receipt_chunk_count" ]] ||
    fail "receipt transport did not reach an exact END"
[[ "$(wc -c < "$receipt_base64" | tr -d ' ')" \
    == "$expected_base64_count" ]] || fail "receipt base64 byte count"
base64 -D < "$receipt_base64" > "$receipt_json" || fail "receipt base64 decode"
[[ "$(wc -c < "$receipt_json" | tr -d ' ')" == "$receipt_byte_count" ]] ||
    fail "decoded receipt byte count"
[[ "$(wc -l < "$receipt_json" | tr -d ' ')" == "0" ]] ||
    fail "decoded canonical receipt contains a literal newline"
[[ "$(shasum -a 256 "$receipt_json" | awk '{print $1}')" \
    == "$receipt_sha256" ]] || fail "decoded receipt SHA-256"
readonly end_line="$(grep -E "^${receipt_end}" "$probe_log")"
[[ "$end_line" == "$expected_end" && "$(tail -n 1 "$probe_log")" == "$end_line" ]] ||
    fail "receipt END is not exact and final"
cmp -s \
    <(jq -cS . "$receipt_json") \
    <({ cat "$receipt_json"; printf '\n'; }) ||
    fail "decoded receipt is not canonical JSON"

# Recompute every canonical nested identity carried by the typed evidence.
# These remain file-backed because the full 218-entry arrays are too large for
# shell variables and must not be silently truncated by log/argument limits.
jq -cSj '.external_binding.manifest.compatibility_identity' \
    "$receipt_json" > "$receipt_identity_json" ||
    fail "compatibility identity canonicalization"
jq -cSj '.external_binding.manifest.tensor_bindings' \
    "$receipt_json" > "$receipt_tensor_bindings_json" ||
    fail "tensor-binding canonicalization"
jq -cSj '.external_binding.manifest' \
    "$receipt_json" > "$receipt_manifest_json" ||
    fail "manifest canonicalization"
jq -cSj '.external_binding' \
    "$receipt_json" > "$receipt_external_binding_json" ||
    fail "external-binding canonicalization"
for canonical_file in \
    "$receipt_identity_json" "$receipt_tensor_bindings_json" \
    "$receipt_manifest_json" "$receipt_external_binding_json"; do
    [[ -s "$canonical_file" && -f "$canonical_file" \
        && ! -L "$canonical_file" \
        && "$(stat -f %u "$canonical_file")" == "$(id -u)" \
        && "$(stat -f %l "$canonical_file")" == "1" \
        && "$(stat -f %Lp "$canonical_file")" == "600" \
        && "$(wc -l < "$canonical_file" | tr -d ' ')" == "0" ]] ||
        fail "unsafe nested canonical receipt file: $canonical_file"
done
readonly identity_canonical_bytes="$(wc -c < "$receipt_identity_json" | tr -d ' ')"
readonly identity_canonical_sha="$(shasum -a 256 "$receipt_identity_json" | awk '{print $1}')"
readonly tensor_bindings_canonical_bytes="$(wc -c < "$receipt_tensor_bindings_json" | tr -d ' ')"
readonly tensor_bindings_canonical_sha="$(shasum -a 256 "$receipt_tensor_bindings_json" | awk '{print $1}')"
readonly manifest_canonical_bytes="$(wc -c < "$receipt_manifest_json" | tr -d ' ')"
readonly manifest_canonical_sha="$(shasum -a 256 "$receipt_manifest_json" | awk '{print $1}')"
readonly external_binding_canonical_bytes="$(wc -c < "$receipt_external_binding_json" | tr -d ' ')"
readonly external_binding_canonical_sha="$(shasum -a 256 "$receipt_external_binding_json" | awk '{print $1}')"
for canonical_count in \
    "$identity_canonical_bytes" "$tensor_bindings_canonical_bytes" \
    "$manifest_canonical_bytes" "$external_binding_canonical_bytes"; do
    [[ "$canonical_count" =~ ^[1-9][0-9]*$ ]] ||
        fail "invalid nested canonical byte count"
done
for canonical_sha in \
    "$identity_canonical_sha" "$tensor_bindings_canonical_sha" \
    "$manifest_canonical_sha" "$external_binding_canonical_sha"; do
    [[ "$canonical_sha" =~ ^[0-9a-f]{64}$ ]] ||
        fail "invalid nested canonical SHA-256"
done

jq -e \
    --arg revision "$exact_revision" \
    --arg first "$first_parent" \
    --arg second "$second_parent" \
    --arg tree "$exact_tree" \
    --arg source_identity "$embedded_source_identity" \
    --arg metallib_sha "$metallib_sha256" \
    --arg identity_sha "$identity_canonical_sha" \
    --arg tensor_sha "$tensor_bindings_canonical_sha" \
    --arg manifest_sha "$manifest_canonical_sha" \
    --arg external_sha "$external_binding_canonical_sha" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --argjson available_reclaimed "$available_after_reclamation" \
    --argjson available_built "$available_after_build" \
    --argjson effective_uid "$(id -u)" \
    --argjson identity_bytes "$identity_canonical_bytes" \
    --argjson tensor_bytes "$tensor_bindings_canonical_bytes" \
    --argjson manifest_bytes "$manifest_canonical_bytes" \
    --argjson external_bytes "$external_binding_canonical_bytes" \
    --argjson artifact_mode 292 \
    --argjson root_mode 448 \
    '
      type == "object"
      and (keys == ([
        "architecture",
        "artifact_binding_verified_before_and_after_complete_materialization_via_pinned_artifact_root",
        "artifact_root_entry_count_after_write",
        "artifact_root_entry_names_after_write",
        "artifact_root_entry_names_before_write",
        "artifact_root_identity_after_load",
        "artifact_root_identity_after_write",
        "artifact_root_identity_before_write",
        "artifact_root_initially_empty",
        "artifact_root_owner_matched_effective_user",
        "artifact_root_path_is_absolute",
        "artifact_upload_invoked_before_receipt",
        "atomic_checkpoint_replacement_established",
        "authority_id",
        "available_filesystem_bytes_after_build",
        "available_filesystem_bytes_after_reclamation",
        "backward_invoked",
        "cache_cleared_before_source_materialization",
        "cache_cleared_between_source_write_and_public_load",
        "caller_source_model_construction_count",
        "caller_supplied_revision_binding_is_independent_observation",
        "canary_replacement_authorized",
        "candidate_admission_granted",
        "checkpoint_admission_granted",
        "checkpoint_artifact_availability_beyond_process_established",
        "checkpoint_artifact_available_during_process",
        "checkpoint_artifact_provenance_established",
        "checkpoint_artifact_retention_established",
        "checkpoint_container_hash_bound",
        "checkpoint_durability_mechanics_completed",
        "checkpoint_io_observed",
        "checkpoint_loaded_forward_observed",
        "checkpoint_round_trip_behavior_parity_established",
        "cleanup_required_after_parent_receipt_verification",
        "compatibility_identity_canonical_byte_count",
        "compatibility_identity_sha256",
        "compatibility_identity_validated",
        "configuration",
        "container_materialization_count_required_by_pinned_codec",
        "core_graphics_bootstrap_observed",
        "cumulative_public_load_completion_count_source_inferred_after_success",
        "cumulative_public_write_completion_count_source_inferred_after_success",
        "data_cursor_included",
        "decoder_forward_observed",
        "decoder_kv_cache_used",
        "default_metal_device_matched_index_zero",
        "deterministic_seed_replay_observed",
        "enumerated_metal_device_count",
        "environment_policy",
        "evidence_id",
        "exact_revision_matched_github_sha",
        "exclusive_no_replace_publication_completed",
        "executed_embedded_source_identity_sha256",
        "executed_ordered_parent_revisions",
        "executed_revision",
        "executed_tree",
        "execution_event",
        "execution_ref",
        "execution_repository",
        "execution_run_attempt",
        "exhausted_seed42_public_load_completion_count_source_inferred",
        "exhausted_seed42_public_write_completion_count_source_inferred",
        "existing_checkpoint_artifact_compatibility_observed",
        "existing_metallib_candidate_count_after_execution",
        "existing_metallib_candidate_count_before_execution",
        "external_binding",
        "external_binding_canonical_byte_count",
        "external_binding_canonical_sha256",
        "failed_checkpoint_write_recovery_observed",
        "focused_contract_logs_validated_before_reclamation",
        "free_space_preflight_passed",
        "fresh_loaded_model_construction_required_by_pinned_codec",
        "frozen_44_metal_log_validated_before_reclamation",
        "generated_file_and_parent_synchronization_returned_success",
        "generation_invoked",
        "github_actions",
        "independent_codec_comparator_observed",
        "independent_post_load_artifact_root_verify_observed",
        "independent_post_load_tensor_hash_replay_observed",
        "initial_parameter_materialization_evaluation_api",
        "initial_parameter_materialization_evaluation_count",
        "initialization_seed",
        "known_runner_temporary_paths_absent_before_probe",
        "known_runner_temporary_reclamation_path_count",
        "kv_cache_state_included",
        "launched_environment_revalidated_after_evaluation",
        "launched_environment_validated_before_framework_access",
        "loaded_metallib_identity_independently_observed",
        "loaded_parameter_catalog_and_logical_hashes_matched_manifest_via_pinned_codec",
        "loaded_structural_parameter_catalog_matched",
        "logical_parameter_round_trip_via_pinned_codec_observed",
        "loss_observed",
        "maintained_runtime_authority_log_and_receipt_validated_before_reclamation",
        "manifest_canonical_byte_count",
        "manifest_canonical_sha256",
        "manifest_validated",
        "memory_cache_clear_count",
        "memory_cache_limit",
        "metal_lease_held_before_and_after_evaluation",
        "metal_library_validated_from_exact_url",
        "metallib_artifact_relative_path",
        "metallib_byte_count",
        "metallib_path_and_descriptor_reverified",
        "metallib_sha256",
        "mlx_device_index",
        "mlx_device_type",
        "model_quality_established",
        "native300m_checkpoint_load_observed",
        "native300m_checkpoint_write_observed",
        "native300m_model_allocation_observed",
        "observed_parameter_byte_count",
        "observed_parameter_count",
        "operating_system",
        "optimizer_state_included",
        "optimizer_step_observed",
        "parent_success_cleanup_required_after_receipt",
        "physical_gpu_identity_established",
        "predecessor_validated_log_count",
        "predecessor_validated_receipt_count",
        "predecessor_failure_observation_consumed_by_authority_source",
        "process_exit_required_after_receipt",
        "product_use_authorized",
        "public_checkpoint_load_completion_count",
        "public_checkpoint_load_invocation_count",
        "public_checkpoint_write_completion_count",
        "public_checkpoint_write_invocation_count",
        "publication_authorized",
        "publication_root_link_counts_positive",
        "publication_stable_five_fields_matched",
        "published_artifact_link_count",
        "published_artifact_mode",
        "published_artifact_device_matched_root",
        "published_artifact_is_regular_file",
        "published_artifact_is_symbolic_link",
        "published_artifact_owner_matched_effective_user",
        "quantization_authorized",
        "release_instrumentation_evidence_absent",
        "reproducible_checkpoint_serialization_observed",
        "required_free_space_multiplier",
        "read_only_full_root_identity_matched",
        "retry_observed",
        "reviewed_pull_request_head_tree",
        "rng_state_included",
        "runner_environment",
        "runtime_dependency_closure_predecessor_receipt_validated_for_checkpoint_io",
        "schema_version",
        "second_independent_write_observed",
        "source_inferred_decoder_construction_count",
        "source_model_arc_deallocation_observed",
        "source_model_reference_lexical_scope_ended_before_public_load",
        "status",
        "success_cleanup_completed_before_receipt",
        "tensor_binding_count",
        "tensor_bindings_canonical_byte_count",
        "tensor_bindings_sha256",
        "tf32_differential_observed",
        "tf32_static_value_directly_observed",
        "tokenizer_authority_log_and_receipt_validated_before_reclamation",
        "total_decoder_construction_count_is_source_inferred_only",
        "train_evaluate_surface_established",
        "training_execution_observed",
        "training_resume_established",
        "trial_authorized",
        "writer_hidden_descriptor_restore_and_reinspection_completed_via_successful_pinned_codec_return"
      ] | sort))
      and ((.artifact_root_identity_before_write | keys) == ([
        "change_time_nanoseconds", "change_time_seconds", "device_id",
        "inode", "link_count", "modification_time_nanoseconds",
        "modification_time_seconds", "owner_group_id", "owner_user_id",
        "permission_mode"
      ] | sort))
      and ((.artifact_root_identity_after_write | keys)
        == (.artifact_root_identity_before_write | keys))
      and ((.artifact_root_identity_after_load | keys)
        == (.artifact_root_identity_before_write | keys))
      and ((.environment_policy | keys) == ([
        "schemaVersion", "policyID", "policyVersion", "scope",
        "predecessorPolicyID", "predecessorPolicyVersion",
        "predecessorRemainsFrozen", "exactMLXRevision",
        "requiredEnvironmentKey", "requiredEnvironmentValue",
        "exclusiveEnvironmentKeyPrefix", "forbiddenEnvironmentKeyPrefixes",
        "numericMode", "comparisonPolicy", "authorityCeiling"
      ] | sort))
      and ((.configuration | keys) == ([
        "vocabulary_size", "model_width", "layer_count",
        "query_head_count", "key_value_head_count", "head_width",
        "intermediate_width", "maximum_sequence_length",
        "rope_theta_float32_bit_pattern",
        "rms_norm_epsilon_float32_bit_pattern", "unique_parameter_count"
      ] | sort))
      and ((.external_binding | keys) == ([
        "schema_version", "schema_id", "manifest",
        "manifest_canonical_byte_count", "manifest_canonical_sha256",
        "artifact_binding"
      ] | sort))
      and ((.external_binding.artifact_binding | keys)
        == (["relativePath", "sha256", "byteCount", "purpose"] | sort))
      and ((.external_binding.manifest | keys) == ([
        "schema_version", "schema_id", "artifact_kind",
        "checkpoint_format", "state_scope", "logical_tensor_hash_algorithm",
        "logical_tensor_byte_encoding", "compatibility_identity",
        "tensor_bindings", "tensor_bindings_sha256",
        "optimizer_state_included", "rng_state_included",
        "data_cursor_included", "kv_cache_state_included"
      ] | sort))
      and ((.external_binding.manifest.compatibility_identity | keys)
        == ([
          "schema_version", "schema_id", "identity_scope", "authority_id",
          "predecessor_compatibility_identity_sha256",
          "repair_authority_id", "architecture_schema", "implementation_id",
          "decoder_source_sha256", "exact_mlx_revision",
          "parameter_path_schema", "required_tensor_dtype",
          "tied_output_projection", "configuration", "token_identity",
          "parameter_catalog", "parameter_catalog_sha256",
          "total_parameter_count", "total_parameter_byte_count",
          "maximum_checkpoint_byte_count"
        ] | sort))
      and ((.external_binding.manifest.compatibility_identity.configuration
        | keys) == ([
          "vocabulary_size", "model_width", "layer_count",
          "query_head_count", "key_value_head_count", "head_width",
          "intermediate_width", "maximum_sequence_length",
          "rope_theta_float32_bit_pattern",
          "rms_norm_epsilon_float32_bit_pattern", "unique_parameter_count"
        ] | sort))
      and ((.external_binding.manifest.compatibility_identity.token_identity
        | keys) == ([
          "schema_version", "tokenizer_id", "tokenizer_manifest_sha256",
          "vocabulary_size"
        ] | sort))
      and (.external_binding.manifest.compatibility_identity.parameter_catalog
        | length) == 218
      and (.external_binding.manifest.compatibility_identity.parameter_catalog
        | all((keys == ([
          "path", "shape", "dtype", "element_count", "byte_count"
        ] | sort))))
      and (.external_binding.manifest.tensor_bindings
        | all((keys == (["path", "logical_sha256", "all_values_finite"] | sort))))
      and .compatibility_identity_canonical_byte_count == $identity_bytes
      and .compatibility_identity_canonical_byte_count == 30553
      and .compatibility_identity_sha256 == $identity_sha
      and .compatibility_identity_sha256 == "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843"
      and .compatibility_identity_validated == true
      and .external_binding_canonical_byte_count == $external_bytes
      and .external_binding_canonical_sha256 == $external_sha
      and .manifest_canonical_byte_count == $manifest_bytes
      and .manifest_canonical_sha256 == $manifest_sha
      and .external_binding.manifest_canonical_byte_count == $manifest_bytes
      and .external_binding.manifest_canonical_sha256 == $manifest_sha
      and .manifest_validated == true
      and .tensor_bindings_canonical_byte_count == $tensor_bytes
      and .tensor_bindings_sha256 == $tensor_sha
      and .external_binding.manifest.tensor_bindings_sha256 == $tensor_sha
      and .external_binding.schema_version == 2
      and .external_binding.schema_id == "manifest_plus_canonical_manifest_identity_plus_prime_artifact_binding_v2"
      and .external_binding.manifest.schema_version == 2
      and .external_binding.manifest.schema_id == "ergentics_prime_native_decoder_weights_checkpoint_v2"
      and .external_binding.manifest.artifact_kind == "prime_native_decoder_model_weights_only_checkpoint"
      and .external_binding.manifest.checkpoint_format == "safetensors"
      and .external_binding.manifest.state_scope == "model_parameters_only_no_optimizer_rng_cursor_or_cache"
      and .external_binding.manifest.logical_tensor_hash_algorithm == "sha256"
      and .external_binding.manifest.logical_tensor_byte_encoding == "contiguous_row_major_little_endian_float32"
      and ([.external_binding.manifest.optimizer_state_included,
            .external_binding.manifest.rng_state_included,
            .external_binding.manifest.data_cursor_included,
            .external_binding.manifest.kv_cache_state_included]
        | all(. == false))
      and .configuration
        == .external_binding.manifest.compatibility_identity.configuration
      and .configuration == {
        "vocabulary_size": 512,
        "model_width": 1024,
        "layer_count": 24,
        "query_head_count": 16,
        "key_value_head_count": 4,
        "head_width": 64,
        "intermediate_width": 2816,
        "maximum_sequence_length": 2048,
        "rope_theta_float32_bit_pattern": 1176256512,
        "rms_norm_epsilon_float32_bit_pattern": 925353388,
        "unique_parameter_count": 271107072
      }
      and .external_binding.manifest.compatibility_identity.parameter_catalog_sha256
        == "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1"
      and (.external_binding.manifest.compatibility_identity.parameter_catalog
        | length) == 218
      and .external_binding.manifest.compatibility_identity.total_parameter_count
        == 271107072
      and .external_binding.manifest.compatibility_identity.total_parameter_byte_count
        == 1084428288
      and .external_binding.manifest.compatibility_identity.maximum_checkpoint_byte_count
        == 1101205504
      and (.external_binding.manifest.tensor_bindings | length) == 218
      and (.external_binding.manifest.tensor_bindings
        | all(.all_values_finite == true
          and (.logical_sha256 | test("^[0-9a-f]{64}$"))))
      and ([.external_binding.manifest.tensor_bindings[].path]
        == [.external_binding.manifest.compatibility_identity.parameter_catalog[].path])
      and .schema_version == 1
      and .evidence_id == "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1"
      and .authority_id == "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1"
      and .executed_revision == $revision
      and .executed_ordered_parent_revisions == [$first, $second]
      and .executed_tree == $tree
      and .reviewed_pull_request_head_tree == $tree
      and .executed_embedded_source_identity_sha256 == $source_identity
      and .execution_event == "push"
      and .execution_ref == "refs/heads/main"
      and .execution_run_attempt == 1
      and .execution_repository == "Ergentics/ergentics-prime"
      and .github_actions == "true"
      and .runner_environment == "github-hosted"
      and .operating_system == "macOS"
      and .architecture == "arm64"
      and .exact_revision_matched_github_sha == true
      and .environment_policy == {
        "schemaVersion": 1,
        "policyID": "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_environment_v1",
        "policyVersion": 1,
        "scope": "one_seed43_native300m_v2_checkpoint_root_identity_repair_write_and_one_fresh_load",
        "predecessorPolicyID": "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_environment_v1",
        "predecessorPolicyVersion": 1,
        "predecessorRemainsFrozen": true,
        "exactMLXRevision": "d37885a278f1c37484a94d0f401a418735e66519",
        "requiredEnvironmentKey": "MLX_ENABLE_TF32",
        "requiredEnvironmentValue": "0",
        "exclusiveEnvironmentKeyPrefix": "MLX_",
        "forbiddenEnvironmentKeyPrefixes": ["DYLD_", "LLVM_PROFILE_"],
        "numericMode": "float32_checkpoint_materialization_tf32_disabled",
        "comparisonPolicy": "exact_manifest_catalog_shape_dtype_count_and_logical_tensor_hash_via_pinned_codec_with_repaired_root_publication_snapshot",
        "authorityCeiling": "one_process_local_seed43_native300m_source_materialization_one_v2_write_one_fresh_v2_load_no_forward_backward_retry_artifact_admission_upload_or_retention"
      }
      and .launched_environment_validated_before_framework_access == true
      and .launched_environment_revalidated_after_evaluation == true
      and .release_instrumentation_evidence_absent == true
      and .core_graphics_bootstrap_observed == true
      and .enumerated_metal_device_count == 1
      and .default_metal_device_matched_index_zero == true
      and .mlx_device_type == "gpu" and .mlx_device_index == 0
      and .metal_lease_held_before_and_after_evaluation == true
      and .metallib_artifact_relative_path == "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
      and .metallib_byte_count == $metallib_bytes
      and .metallib_sha256 == $metallib_sha
      and .existing_metallib_candidate_count_before_execution == 1
      and .existing_metallib_candidate_count_after_execution == 1
      and .metallib_path_and_descriptor_reverified == true
      and .metal_library_validated_from_exact_url == true
      and .focused_contract_logs_validated_before_reclamation == true
      and .frozen_44_metal_log_validated_before_reclamation == true
      and .maintained_runtime_authority_log_and_receipt_validated_before_reclamation == true
      and .tokenizer_authority_log_and_receipt_validated_before_reclamation == true
      and .predecessor_validated_log_count == 10
      and .predecessor_validated_receipt_count == 2
      and .predecessor_failure_observation_consumed_by_authority_source == true
      and .exhausted_seed42_public_write_completion_count_source_inferred == 1
      and .exhausted_seed42_public_load_completion_count_source_inferred == 0
      and .cumulative_public_write_completion_count_source_inferred_after_success == 2
      and .cumulative_public_load_completion_count_source_inferred_after_success == 1
      and .known_runner_temporary_reclamation_path_count == 32
      and .known_runner_temporary_paths_absent_before_probe == true
      and .available_filesystem_bytes_after_reclamation == $available_reclaimed
      and .available_filesystem_bytes_after_build == $available_built
      and .available_filesystem_bytes_after_build >= 3303616512
      and .required_free_space_multiplier == 3
      and .free_space_preflight_passed == true
      and .artifact_root_path_is_absolute == true
      and .artifact_root_owner_matched_effective_user == true
      and .artifact_root_initially_empty == true
      and .artifact_root_entry_count_after_write == 1
      and .artifact_root_entry_names_before_write == []
      and .artifact_root_entry_names_after_write
        == ["checkpoint-v2-native300m-seed43-root-identity-repair.safetensors"]
      and .published_artifact_is_regular_file == true
      and .published_artifact_is_symbolic_link == false
      and .published_artifact_device_matched_root == true
      and .published_artifact_owner_matched_effective_user == true
      and .publication_stable_five_fields_matched == true
      and .publication_root_link_counts_positive == true
      and .read_only_full_root_identity_matched == true
      and ([.artifact_root_identity_before_write,
            .artifact_root_identity_after_write,
            .artifact_root_identity_after_load]
        | all(.device_id > 0
          and .inode > 0
          and .owner_user_id == $effective_uid
          and .permission_mode == $root_mode
          and .link_count > 0
          and .modification_time_nanoseconds >= 0
          and .modification_time_nanoseconds < 1000000000
          and .change_time_nanoseconds >= 0
          and .change_time_nanoseconds < 1000000000))
      # Publication can change directory link count and timestamps. This
      # tuple intentionally binds only the stable object fields; positivity
      # above and the exact empty-to-one-fixed-leaf inventory bind topology.
      and ([.artifact_root_identity_before_write.device_id,
            .artifact_root_identity_before_write.inode,
            .artifact_root_identity_before_write.owner_user_id,
            .artifact_root_identity_before_write.owner_group_id,
            .artifact_root_identity_before_write.permission_mode]
        == [.artifact_root_identity_after_write.device_id,
            .artifact_root_identity_after_write.inode,
            .artifact_root_identity_after_write.owner_user_id,
            .artifact_root_identity_after_write.owner_group_id,
            .artifact_root_identity_after_write.permission_mode])
      and .artifact_root_identity_after_load == .artifact_root_identity_after_write
      and .initialization_seed == 43
      and .caller_source_model_construction_count == 1
      and .initial_parameter_materialization_evaluation_count == 1
      and .initial_parameter_materialization_evaluation_api == "MLX.checkedEval(model)"
      and .memory_cache_limit == 0 and .memory_cache_clear_count == 2
      and .cache_cleared_before_source_materialization == true
      and .source_model_reference_lexical_scope_ended_before_public_load == true
      and .cache_cleared_between_source_write_and_public_load == true
      and .public_checkpoint_write_invocation_count == 1
      and .public_checkpoint_write_completion_count == 1
      and .public_checkpoint_load_invocation_count == 1
      and .public_checkpoint_load_completion_count == 1
      and .total_decoder_construction_count_is_source_inferred_only == true
      and .source_inferred_decoder_construction_count == 3
      and .container_materialization_count_required_by_pinned_codec == 2
      and .fresh_loaded_model_construction_required_by_pinned_codec == true
      and .external_binding.artifact_binding.relativePath == "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors"
      and .external_binding.artifact_binding.purpose == "immutable_data"
      and .external_binding.artifact_binding.byteCount > 1084428288
      and .external_binding.artifact_binding.byteCount <= 1101205504
      and (.external_binding.artifact_binding.sha256 | test("^[0-9a-f]{64}$"))
      and .external_binding.artifact_binding.sha256
        != "0000000000000000000000000000000000000000000000000000000000000000"
      and .tensor_binding_count == 218
      and .observed_parameter_count == 271107072
      and .observed_parameter_byte_count == 1084428288
      and .published_artifact_mode == $artifact_mode
      and .published_artifact_link_count == 1
      and .writer_hidden_descriptor_restore_and_reinspection_completed_via_successful_pinned_codec_return == true
      and .loaded_parameter_catalog_and_logical_hashes_matched_manifest_via_pinned_codec == true
      and .loaded_structural_parameter_catalog_matched == true
      and .artifact_binding_verified_before_and_after_complete_materialization_via_pinned_artifact_root == true
      and .exclusive_no_replace_publication_completed == true
      and .generated_file_and_parent_synchronization_returned_success == true
      and .native300m_model_allocation_observed == true
      and .native300m_checkpoint_write_observed == true
      and .native300m_checkpoint_load_observed == true
      and .checkpoint_io_observed == true
      and .checkpoint_artifact_available_during_process == true
      and .checkpoint_container_hash_bound == true
      and .checkpoint_durability_mechanics_completed == true
      and .logical_parameter_round_trip_via_pinned_codec_observed == true
      and .runtime_dependency_closure_predecessor_receipt_validated_for_checkpoint_io == true
      and ([.caller_supplied_revision_binding_is_independent_observation,
            .loaded_metallib_identity_independently_observed,
            .physical_gpu_identity_established,
            .tf32_static_value_directly_observed,
            .tf32_differential_observed,
            .deterministic_seed_replay_observed,
            .reproducible_checkpoint_serialization_observed,
            .second_independent_write_observed,
            .independent_post_load_tensor_hash_replay_observed,
            .independent_codec_comparator_observed,
            .independent_post_load_artifact_root_verify_observed,
            .source_model_arc_deallocation_observed,
            .artifact_upload_invoked_before_receipt,
            .checkpoint_artifact_availability_beyond_process_established,
            .checkpoint_artifact_retention_established,
            .checkpoint_artifact_provenance_established,
            .checkpoint_admission_granted,
            .existing_checkpoint_artifact_compatibility_observed,
            .atomic_checkpoint_replacement_established,
            .failed_checkpoint_write_recovery_observed,
            .checkpoint_loaded_forward_observed,
            .checkpoint_round_trip_behavior_parity_established,
            .optimizer_state_included, .rng_state_included,
            .data_cursor_included, .kv_cache_state_included,
            .decoder_forward_observed, .decoder_kv_cache_used,
            .backward_invoked, .loss_observed, .optimizer_step_observed,
            .generation_invoked, .train_evaluate_surface_established,
            .training_resume_established, .training_execution_observed,
            .model_quality_established, .candidate_admission_granted,
            .trial_authorized, .canary_replacement_authorized,
            .quantization_authorized, .product_use_authorized,
            .publication_authorized, .retry_observed] | all(. == false))
      and .process_exit_required_after_receipt == true
      and .cleanup_required_after_parent_receipt_verification == true
      and .success_cleanup_completed_before_receipt == false
      and .parent_success_cleanup_required_after_receipt == true
      and .status == "PASS_process_local_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_only"
      and ([.. | strings | select(startswith("/"))] | length) == 0
    ' "$receipt_json" >/dev/null || fail "canonical receipt semantic validation"

readonly receipt_root_device="$(jq -r '.artifact_root_identity_after_load.device_id' "$receipt_json")"
readonly receipt_root_inode="$(jq -r '.artifact_root_identity_after_load.inode' "$receipt_json")"
readonly receipt_root_uid="$(jq -r '.artifact_root_identity_after_load.owner_user_id' "$receipt_json")"
readonly receipt_root_gid="$(jq -r '.artifact_root_identity_after_load.owner_group_id' "$receipt_json")"
readonly receipt_root_mode="$(jq -r '.artifact_root_identity_after_load.permission_mode' "$receipt_json")"
readonly receipt_root_links="$(jq -r '.artifact_root_identity_after_load.link_count' "$receipt_json")"
readonly receipt_root_mtime_seconds="$(jq -r '.artifact_root_identity_after_load.modification_time_seconds' "$receipt_json")"
readonly receipt_root_mtime_nanos="$(jq -r '.artifact_root_identity_after_load.modification_time_nanoseconds' "$receipt_json")"
readonly receipt_root_ctime_seconds="$(jq -r '.artifact_root_identity_after_load.change_time_seconds' "$receipt_json")"
readonly receipt_root_ctime_nanos="$(jq -r '.artifact_root_identity_after_load.change_time_nanoseconds' "$receipt_json")"
readonly receipt_root_mtime="${receipt_root_mtime_seconds}.$(printf '%09d' "$receipt_root_mtime_nanos")"
readonly receipt_root_ctime="${receipt_root_ctime_seconds}.$(printf '%09d' "$receipt_root_ctime_nanos")"
readonly receipt_artifact_bytes="$(jq -r '.external_binding.artifact_binding.byteCount' "$receipt_json")"
readonly artifact_path="$artifact_root/$artifact_relative_path"
[[ -d "$artifact_root" && ! -L "$artifact_root" ]] || fail "artifact root postflight"
[[ "$(stat -f %d "$artifact_root")" == "$receipt_root_device" \
    && "$(stat -f %i "$artifact_root")" == "$receipt_root_inode" \
    && "$(stat -f %u "$artifact_root")" == "$receipt_root_uid" \
    && "$(stat -f %g "$artifact_root")" == "$receipt_root_gid" \
    && "$(stat -f %Lp "$artifact_root")" == "700" \
    && "$receipt_root_mode" == "448" \
    && "$(stat -f %l "$artifact_root")" == "$receipt_root_links" \
    && "$(stat -f %.9Fm "$artifact_root")" == "$receipt_root_mtime" \
    && "$(stat -f %.9Fc "$artifact_root")" == "$receipt_root_ctime" ]] ||
    fail "artifact root identity changed before cleanup"
[[ "$(find "$artifact_root" -mindepth 1 -print)" == "$artifact_path" ]] ||
    fail "artifact root does not contain exactly the fixed leaf"
[[ -f "$artifact_path" && ! -L "$artifact_path" \
    && "$(stat -f %d "$artifact_path")" == "$receipt_root_device" \
    && "$(stat -f %u "$artifact_path")" == "$(id -u)" \
    && "$(stat -f %l "$artifact_path")" == "1" \
    && "$(stat -f %Lp "$artifact_path")" == "444" \
    && "$(stat -f %z "$artifact_path")" == "$receipt_artifact_bytes" ]] ||
    fail "receipt-bound artifact metadata changed before cleanup"
unlink "$artifact_path"
rmdir "$artifact_root"
[[ ! -e "$artifact_path" && ! -L "$artifact_path" \
    && ! -e "$artifact_root" && ! -L "$artifact_root" ]] ||
    fail "literal artifact cleanup postcondition"

[[ -f "$lease_path" && ! -L "$lease_path" \
    && "$(stat -f %Lp "$lease_path")" == "600" ]] || fail "Metal lease postflight"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private working directory changed"
cmp -s "$metallib" "$staged_metallib" || fail "metallib changed"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout changed"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor changed"

echo "OK: exact reviewed-main one-shot Native-300M V2 checkpoint public write/load passed; the fixed artifact and 0700 root were removed after receipt validation"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The exact direct-successor reviewed-main merge completed one seed-43 Native-300M source materialization, one public V2 checkpoint write, and one public fresh load through PrimeArtifactRoot after the frozen Metal, maintained-runtime, and tokenizer predecessors.'
        echo 'The chunked canonical typed receipt binds the full 218-entry logical manifest and external whole-container binding. The supervisor validated it, then unlinked the sole immutable checkpoint leaf and removed its private ephemeral root without uploading or retaining the artifact.'
        echo 'No decoder forward, KV cache, generation, backward pass, loss, optimizer step, retry, training, artifact admission, candidate admission, trial, canary, product use, or publication was authorized or observed.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

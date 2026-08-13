#!/usr/bin/env bash
# One-shot exact-main Stage-3 witness for the authorized tiny CPU typed
# in-memory explicit-RNG/cursor resume boundary. This script consumes the
# retained same-job Metal/runtime/tokenizer prerequisites, stages their already
# built default.metallib into one fresh validation build, and directly runs the
# sole Stage-3 XCTest. It performs no checkpoint I/O, retention, or upload.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-stage3-tiny-cpu-resume: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly base_revision="372248bd2e2d282bbb2b0fe39273211aee0da43a"
readonly base_tree="f4df5d9b17c216748387435ef0f1f8d14ede2f54"
readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_canonical_sha256="0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6"
readonly repair_authority_canonical_sha256="34cd246fbeb754f31f7ecf3fee03d35fdc5c615e5a61c245e609a7ef03845b59"
readonly inventory_order_repair_authority_canonical_sha256="52f2619ebcbc6e8d608042ffb107411bbcb6ac4630482dba0007436f52bb03ce"
readonly authority_id="prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_authority_v1"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE3_TINY_CPU_EXPLICIT_RNG_CURSOR_RESUME_RECEIPT="

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_manifest="$validation_root/Package.swift"
readonly validation_lock="$validation_root/Package.resolved"
readonly retained_stage2_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift"
readonly stage3_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift"
readonly training_source="$prime_root/Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
readonly authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift"
readonly authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests.swift"
readonly repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift"
readonly repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift"
readonly inventory_order_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift"
readonly inventory_order_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift"
readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"

readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly metal_build="$runner_temp/prime-native-decoder-build"
readonly runtime_build="$runner_temp/prime-native-decoder-runtime-closure-build"
readonly tokenizer_build="$runner_temp/prime-native-decoder-tokenizer-compatibility-build"
readonly active_root_log="$runner_temp/prime-active-root-tests.log"
readonly checkpoint_v2_log="$runner_temp/prime-checkpoint-v2-tests.log"
readonly checkpoint_v2_io_log="$runner_temp/prime-checkpoint-v2-io-tests.log"
readonly checkpoint_v2_io_execution_log="$runner_temp/prime-checkpoint-v2-io-execution-pure-tests.log"
readonly checkpoint_v2_io_root_repair_log="$runner_temp/prime-checkpoint-v2-io-root-identity-repair-execution-pure-tests.log"
readonly metal_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly tokenizer_test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly tokenizer_probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"

readonly scratch_path="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-config"
readonly security_path="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-cwd"
readonly test_log="$runner_temp/prime-native-decoder-stage3-tiny-cpu-resume-tests.log"
readonly test_class="PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests"
readonly test_method="testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed"
readonly test_filter="${test_class}/${test_method}"

for command_name in awk bash chmod cmp cp cut dirname env find git grep id jq \
    mkdir otool pwd shasum sort stat swift tee uname wc xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

readonly xctest_failure_or_skip_regex="^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - "

xctest_log_has_failure_or_skip() {
    grep -Eq "$xctest_failure_or_skip_regex" "$1"
}

[[ "${GITHUB_ACTIONS:-}" == "true" \
    && "${RUNNER_ENVIRONMENT:-}" == "github-hosted" \
    && "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" \
    && "${GITHUB_WORKFLOW:-}" == "Prime active-root quarantine" \
    && "${GITHUB_JOB:-}" == "trusted-main-compile" \
    && "${GITHUB_EVENT_NAME:-}" == "push" \
    && "${GITHUB_REF:-}" == "refs/heads/main" \
    && "${GITHUB_RUN_ATTEMPT:-}" == "1" \
    && "${RUNNER_OS:-}" == "macOS" \
    && "${RUNNER_ARCH:-}" == "ARM64" ]] ||
    fail "execution is not the first hosted exact-main attempt"
[[ "${GITHUB_SHA:-}" == "$exact_revision" \
    && "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" ]] ||
    fail "GitHub revision binding changed"
[[ "$exact_revision" =~ ^[0-9a-f]{40}$ \
    && "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "revision pin changed"
[[ -d "$runner_temp" && ! -L "$runner_temp" \
    && "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not an exact physical directory"
[[ -f "${GITHUB_EVENT_PATH:-}" && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
    fail "push event payload is missing or linked"
jq -e --arg revision "$exact_revision" --arg base "$base_revision" \
    '.ref == "refs/heads/main"
     and .before == $base
     and .after == $revision
     and .head_commit.id == $revision
     and .repository.full_name == "Ergentics/ergentics-prime"
     and .deleted == false
     and .forced == false' "$GITHUB_EVENT_PATH" >/dev/null ||
    fail "push event is not the exact direct main successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached Stage-3"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)
export MLX_ENABLE_TF32=0

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not exact and clean"
readonly parent_line="$(git -C "$prime_root" rev-list --parents -n 1 HEAD)"
IFS=' ' read -r executed_commit first_parent second_parent extra_parent \
    <<< "$parent_line"
[[ "$executed_commit" == "$exact_revision" \
    && "$first_parent" == "$base_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && -z "${extra_parent:-}" ]] ||
    fail "execution is not the exact two-parent direct successor"
[[ "$(git -C "$prime_root" rev-parse "${first_parent}^{tree}")" == "$base_tree" ]] ||
    fail "authority base tree changed"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
[[ "$(git -C "$prime_root" rev-parse "${second_parent}^{tree}")" == "$exact_tree" ]] ||
    fail "merge tree differs from reviewed head tree"

readonly expected_changed_status=$'A\tSources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift\nA\tTests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift\nM\t.github/scripts/prime-ci-active-root-quarantine.sh\nM\t.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh\nM\t.github/workflows/prime-active-root-quarantine.yml\nM\tSources/PrimeCore/PrimeEmbeddedBuildProvenance.swift'
readonly observed_changed_status="$(git -C "$prime_root" diff-tree \
    --no-commit-id --name-status --no-renames -r \
    "$first_parent" "$exact_revision" | LC_ALL=C sort)"
[[ "$observed_changed_status" == "$expected_changed_status" ]] ||
    fail "Stage-3 direct-successor scope is not the exact six paths"
readonly changed_paths_json="$(printf '%s\n' "$observed_changed_status" |
    awk -F '\t' '{print $2}' | LC_ALL=C sort |
    jq -Rsc 'split("\n")[:-1]')"

assert_pinned_file() {
    local relative_path="$1" expected_mode="$2" expected_blob="$3"
    local expected_bytes="$4" expected_sha256="$5"
    local absolute_path="$prime_root/$relative_path"
    [[ -f "$absolute_path" && ! -L "$absolute_path" \
        && "$(stat -f %l "$absolute_path")" == "1" ]] ||
        fail "pinned path is missing or aliased: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- "$relative_path" | awk '{print $1}')" \
        == "$expected_mode" ]] || fail "mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object -- "$relative_path")" == "$expected_blob" ]] ||
        fail "blob changed: $relative_path"
    [[ "$(stat -f %z "$absolute_path")" == "$expected_bytes" ]] ||
        fail "byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$absolute_path" | awk '{print $1}')" == "$expected_sha256" ]] ||
        fail "SHA-256 changed: $relative_path"
}

assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift' \
    '100644' '65cb43e09e9839c0b03cc2e5fafd1ad0b1d4f4fa' '37517' \
    '72a521a0eb6e0e169150e8934925794639bb1d9576fa9c02896c817965af11b4'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests.swift' \
    '100644' 'ab751cfbb2bf728054d3e91ae25d5fce1be8533a' '14254' \
    'baf8eb9c32f4298a77c619643535da98aea45f7c5cf996f54be78888130fedba'
grep -Fq "$authority_canonical_sha256" "$authority_source" ||
    fail "authority canonical digest changed"
assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift' \
    '100644' 'eefd30bc41cefc2fbfe226fc5c33b9525679c72c' '12344' \
    'f535def96350b264b37143cc7f4c3be6e47ef6f37b000cf887ead93ae4daab1c'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift' \
    '100644' '24b36a968f97032146ca6833a9ff4eb20758ac92' '5090' \
    '3401d564066cd7529d0001d505d91690a0290ddcd79c2242f6a97e8d8f0d5d74'
grep -Fq "$repair_authority_canonical_sha256" "$repair_authority_source" ||
    fail "repair authority canonical digest changed"
assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift' \
    '100644' 'a3537ccf14aaa1ceb158688999fdd6fb2af5f5cc' '10830' \
    'cfac0afd75b61950aea7a4fa16c067a07d934d99a5cc2b27905725b3563b840d'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift' \
    '100644' '9db7797c80c57b0b97e108f3b9688e4c069ea015' '3453' \
    '3395533b29fa5b00a62448a42d9da4fa821e5f5eb1232c0f19f3ca5d749ffdb8'
grep -Fq "$inventory_order_repair_authority_canonical_sha256" \
    "$inventory_order_repair_authority_source" ||
    fail "inventory-order repair authority canonical digest changed"
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' \
    '100644' '9f05e5a17426f00adf9dad7b55d84057122e98f9' '1054' \
    '0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' \
    '100644' '8bf05edf1ea8789e7683e72fe756d79aaaa61320' '645' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' \
    '100644' '61e86200c508526ae2ab66e359d771841f7208db' '30214' \
    '29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96'
assert_pinned_file 'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' '3e3517b747dac6c77b14747f4a0d92e892ad4448' '60976' \
    '665568ea2ad237526acee5ded4805abaaac964c266cd2aa3841a3abbc48c4161'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift' \
    '100644' 'a986a63c9d674b03dc879a6c8131577999311a88' '15726' \
    '39051b266433bb510887750bafbc773646181f75cf85b2339ddd9fccb817cf6a'

[[ "$(find "$validation_root" -type f ! -path '*/.*' -print | LC_ALL=C sort)" \
    == "$validation_lock"$'\n'"$validation_manifest"$'\n'"$stage3_test"$'\n'"$retained_stage2_test" ]] ||
    fail "validation package inventory changed"

assert_regular_file() {
    [[ -f "$1" && ! -L "$1" && "$(stat -f %l "$1")" == "1" ]] ||
        fail "required artifact is missing or aliased: $1"
}

[[ -d "$mlx_bare" && ! -L "$mlx_bare" \
    && "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" == "$mlx_revision" ]] ||
    fail "MLX bare repository changed"
[[ -d "$mlx_source" && ! -L "$mlx_source" \
    && "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX source worktree changed"

readonly predecessor_test_logs=(
    "$active_root_log" "$checkpoint_v2_log" "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_log" "$checkpoint_v2_io_root_repair_log"
    "$metal_log" "$runtime_test_log" "$tokenizer_test_log"
)
readonly predecessor_receipt_logs=("$runtime_probe_log" "$tokenizer_probe_log")
for predecessor_log in "${predecessor_test_logs[@]}" "${predecessor_receipt_logs[@]}"; do
    assert_regular_file "$predecessor_log"
done
grep -Fq 'Executed 47 tests, with 0 failures' "$active_root_log" ||
    fail "root-47 contracts did not complete"
grep -Fq 'Executed 44 tests, with 0 failures' "$metal_log" ||
    fail "Metal 44 did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "runtime predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer predecessor did not complete"
for predecessor_test_log in "${predecessor_test_logs[@]}"; do
    ! xctest_log_has_failure_or_skip "$predecessor_test_log" ||
        fail "predecessor test log failed or skipped: $predecessor_test_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log")" == "1" \
    && "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' "$tokenizer_probe_log")" == "1" ]] ||
    fail "predecessor receipt inventory changed"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "fresh metallib root is missing"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" \
    \( -name default.metallib -o -name mlx.metallib \) -print)
[[ "$metallib_count" -eq 1 ]] || fail "fresh metallib candidate count is not one"
assert_regular_file "$metallib"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib identity is invalid"

readonly runtime_receipt="$(grep -E '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log" | cut -d= -f2-)"
readonly tokenizer_receipt="$(grep -E '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' "$tokenizer_probe_log" | cut -d= -f2-)"
printf '%s' "$runtime_receipt" | jq -e \
    --arg sha "$metallib_sha256" --argjson bytes "$metallib_byte_count" \
    '.metallib.sha256 == $sha and .metallib.byte_count == $bytes
     and .runtime_loaded_metallib_identity_established == false
     and .training_execution_observed == false' >/dev/null ||
    fail "runtime receipt fresh-metallib binding changed"
printf '%s' "$tokenizer_receipt" | jq -e \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg sha "$metallib_sha256" --argjson bytes "$metallib_byte_count" \
    '.executed_revision == $revision and .executed_tree == $tree
     and .metallib_sha256 == $sha and .metallib_byte_count == $bytes
     and .loaded_metallib_identity_independently_observed == false
     and .training_execution_observed == false' >/dev/null ||
    fail "tokenizer receipt successor binding changed"

for fresh_path in "$scratch_path" "$cache_path" "$config_path" \
    "$security_path" "$private_cwd" "$test_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "Stage-3 path must be initially absent: $fresh_path"
done
mkdir -p "$scratch_path" "$cache_path" "$config_path" "$security_path" "$private_cwd"
chmod 700 "$private_cwd"

readonly frozen_numerics_checkout="$metal_build/checkouts/swift-numerics"
[[ -d "$frozen_numerics_checkout" && ! -L "$frozen_numerics_checkout" \
    && "$(git -C "$frozen_numerics_checkout" rev-parse HEAD)" == "$numerics_revision" \
    && -z "$(git -C "$frozen_numerics_checkout" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "frozen Swift Numerics checkout changed"
export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://${frozen_numerics_checkout}/.insteadOf"
export GIT_CONFIG_VALUE_1="https://github.com/apple/swift-numerics"
export GIT_CONFIG_KEY_2="protocol.file.allow"
export GIT_CONFIG_VALUE_2="always"
TMPDIR="$runner_temp" swift build \
    --package-path "$validation_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions \
    --configuration debug --jobs 2 --build-tests
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1 GIT_CONFIG_KEY_2 GIT_CONFIG_VALUE_2

readonly bin_path="$scratch_path/arm64-apple-macosx/debug"
readonly test_bundle="$bin_path/PrimeNativeDecoderTrainingValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderTrainingValidationPackageTests"
readonly cli_metallib="$bin_path/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
readonly test_resource_metallib="$test_bundle/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "Stage-3 XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Stage-3 XCTest executable does not link ${framework}"
done
[[ -z "$(find "$bin_path" \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Stage-3 build already contains a metallib candidate"
mkdir -p "$(dirname "$cli_metallib")" "$(dirname "$test_resource_metallib")"
cp -X "$metallib" "$cli_metallib"
cp -X "$metallib" "$test_resource_metallib"
chmod 444 "$cli_metallib" "$test_resource_metallib"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    assert_regular_file "$staged_metallib"
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" == "$metallib_sha256" ]] ||
        fail "Stage-3 staged metallib identity changed"
    cmp -s "$metallib" "$staged_metallib" || fail "Stage-3 staged metallib bytes changed"
done

set +e
(
    cd "$private_cwd"
    TMPDIR="$runner_temp" xcrun xctest -XCTest "$test_filter" "$test_bundle"
) 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#test_pipe_status[@]}" -eq 2 \
    && "${test_pipe_status[0]}" -eq 0 \
    && "${test_pipe_status[1]}" -eq 0 ]] ||
    fail "Stage-3 direct XCTest or log capture failed"
assert_regular_file "$test_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$test_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$test_log")" == "0" ]] ||
    fail "Stage-3 test counts are not 1/1/0/0"
grep -Fq "$test_method" "$test_log" || fail "exact Stage-3 method did not execute"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "Stage-3 test summary changed"
! xctest_log_has_failure_or_skip "$test_log" ||
    fail "Stage-3 test reported a failure or skip"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-3"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private Stage-3 working directory changed"
for prior_log in "${predecessor_test_logs[@]}" "${predecessor_receipt_logs[@]}" "$test_log"; do
    ! grep -Fq "$receipt_prefix" "$prior_log" ||
        fail "Stage-3 receipt prefix existed before emission"
done

readonly receipt_json="$(jq -cnS \
    --arg authority_id "$authority_id" \
    --arg authority_canonical_sha256 "$authority_canonical_sha256" \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg first_parent "$first_parent" --arg second_parent "$second_parent" \
    --argjson changed_paths "$changed_paths_json" \
    --arg metallib_sha256 "$metallib_sha256" \
    --argjson metallib_byte_count "$metallib_byte_count" \
    --arg test_class "$test_class" --arg test_method "$test_method" \
    --arg test_filter "$test_filter" \
    '{schema_version:1,
      receipt_id:"prime_native_decoder_stage3_tiny_cpu_explicit_rng_cursor_resume_receipt_v1",
      authority_id:$authority_id,
      authority_canonical_sha256:$authority_canonical_sha256,
      status:"PASS_exact_main_tiny_cpu_explicit_rng_cursor_resume_one_test_zero_failure_zero_skip",
      execution:{revision:$revision,tree:$tree,first_parent_revision:$first_parent,
        second_parent_revision:$second_parent,parent_count:2,changed_paths:$changed_paths,
        github_event_name:"push",github_ref:"refs/heads/main",github_run_attempt:1},
      predecessor:{focused_root_test_count:47,focused_isolated_test_count:6,
        metal_test_count:44,maintained_runtime_test_count:1,tokenizer_test_count:1,
        retained_order:["metal","maintained_runtime","tokenizer","stage3"]},
      metallib:{byte_count:$metallib_byte_count,sha256:$metallib_sha256,
        source_candidate_count:1,staged_copy_count:2,staged_permission_mode:"444",
        loaded_path_inferred:false,independently_observed_loaded_identity:false,
        retained_after_job:false,artifact_provenance_established:false},
      stage3_test:{test_class:$test_class,test_method:$test_method,test_filter:$test_filter,
        build_command:"swift build --build-tests",build_count:1,direct_xctest_count:1,
        started_count:1,passed_count:1,failure_count:0,skip_count:0,
        typed_in_memory_snapshot_export_restore_established:true,
        uninterrupted_and_fresh_restored_step2_exact_equality_established:true,
        explicit_rng_key_counter_and_next_cursor_boundary_established:true},
      ceiling:{checkpoint_io_observed:false,checkpoint_codec_authorized:false,
        filesystem_capability_added:false,artifact_upload_invoked:false,
        retained_artifact_established:false,metal_determinism_established:false,
        native300m_training_authorized:false,stage4_authorized:false,
        trial_authorized:false,canary_authorized:false,product_use_authorized:false,
        publication_authorized:false,rerun_authorized:false}}')"
[[ "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "Stage-3 receipt is not canonical JSON"
printf '%s%s\n' "$receipt_prefix" "$receipt_json"
echo "OK: exact-main Stage-3 tiny CPU explicit-RNG/cursor resume passed once; durable checkpoint Stage 4 remains unauthorized"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The one-shot Stage-3 tiny CPU witness exported an immutable typed in-memory post-step-1 boundary, restored it into a fresh trainer, and proved exact uninterrupted-versus-restored step-2 and terminal evaluation/state equality.'
        echo 'Four Prime-owned domain-separated key/counter records and the next-unconsumed batch cursor were bound; the witness added no filesystem, checkpoint, artifact, upload, or implicit MLX RNG restoration capability.'
        echo 'The receipt is log-only. Loaded-metallib identity remains inference-only, and durable Stage 4, Native-300M training, trial, canary, product, publication, and rerun authority remain false.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

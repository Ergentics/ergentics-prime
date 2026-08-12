#!/usr/bin/env bash
# Exact-main Stage-2 default-metallib bootstrap repair. This successor repairs
# only the predecessor-log outcome classifier, then consumes the retained Metal
# launcher's same-job fresh metallib after the frozen Metal, maintained-runtime,
# and tokenizer predecessors have completed. It neither builds nor retains a
# metallib and grants no Stage-3 authority.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-stage2-metallib-bootstrap-repair: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly base_revision="775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1"
readonly base_tree="817405a8710ad24245721689e7a6736c55a0b06c"
readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly expected_mlx_submodules=$' ce45c52505c8158ea48d2a54e8caae05efd86bfe Source/Cmlx/mlx (v0.31.1)\n 0726ca922fc902c4c61ef9c27d94132be418e945 Source/Cmlx/mlx-c (v0.6.0)'
readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_manifest="$validation_root/Package.swift"
readonly validation_lock="$validation_root/Package.resolved"
readonly validation_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift"
readonly authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift"
readonly authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift"

readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
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

readonly metal_build="$runner_temp/prime-native-decoder-build"
readonly runtime_build="$runner_temp/prime-native-decoder-runtime-closure-build"
readonly tokenizer_build="$runner_temp/prime-native-decoder-tokenizer-compatibility-build"
readonly scratch_path="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-config"
readonly security_path="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-cwd"
readonly test_log="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-tests.log"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_PREDECESSOR_LOG_CLASSIFIER_REPAIR_RECEIPT="
readonly test_class="PrimeNativeDecoderTrainingTests"
readonly test_method="testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
readonly test_filter="${test_class}/${test_method}"

for command_name in \
    awk bash chmod cmp cp dirname env find git grep id jq mkdir otool pwd \
    sed shasum sort stat swift tee tr uname wc xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

# XCTest outcome recognition is case-sensitive and bounded to complete outcome
# grammar. In particular, a passing test identifier may contain `Failed`
# without becoming a failure observation.
readonly xctest_failure_or_skip_regex="^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - "

xctest_log_has_failure_or_skip() {
    local log_path="$1"
    grep -Eq "$xctest_failure_or_skip_regex" "$log_path"
}

readonly classifier_acceptance_fixtures=(
    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' started."
    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' passed (0.860 seconds)."
    "Test Case '-[ClassifierFixtureTests testSkippedAttemptNameIsOnlyAnIdentifier]' started."
    "Test Case '-[ClassifierFixtureTests testSkippedAttemptNameIsOnlyAnIdentifier]' passed (0.001 seconds)."
    "Test Suite 'ClassifierFixtureTests' passed at 2026-08-12 00:00:00.000."
    $'\t Executed 2 tests, with 0 failures (0 unexpected) in 0.860 (0.861) seconds'
    "Classifier fixture prose mentions failed and skipped without reporting an outcome."
    "note: error: is quoted here only as classifier fixture prose"
)
[[ "${#classifier_acceptance_fixtures[@]}" -eq 8 ]] ||
    fail "bounded classifier acceptance fixture count changed"
for classifier_acceptance_fixture in "${classifier_acceptance_fixtures[@]}"; do
    if printf '%s\n' "$classifier_acceptance_fixture" |
        grep -Eq "$xctest_failure_or_skip_regex"; then
        fail "bounded classifier rejected an accepted outcome fixture"
    fi
done
readonly classifier_rejection_fixtures=(
    "Test Case '-[ClassifierFixtureTests testExactFailure]' failed (0.001 seconds)."
    "Test Suite 'ClassifierFixtureTests' failed at 2026-08-12 00:00:00.000."
    "error: exact classifier fixture error"
    "Test Case '-[ClassifierFixtureTests testExactSkip]' skipped (0.001 seconds)."
    "/tmp/ClassifierFixtureTests.swift:1: -[ClassifierFixtureTests testExactSkip] : Test skipped - exact fixture"
)
[[ "${#classifier_rejection_fixtures[@]}" -eq 5 ]] ||
    fail "bounded classifier rejection fixture count changed"
for classifier_rejection_fixture in "${classifier_rejection_fixtures[@]}"; do
    printf '%s\n' "$classifier_rejection_fixture" |
        grep -Eq "$xctest_failure_or_skip_regex" ||
        fail "bounded classifier accepted a failure-or-skip fixture"
done

# The repair is admitted only for the first exact-main attempt in GitHub's
# hosted arm64 environment. It performs no fetch and therefore also requires
# the reviewed checkout to have made the direct predecessor objects available.
[[ "${GITHUB_ACTIONS:-}" == "true" ]] ||
    fail "execution requires GitHub Actions"
[[ "${RUNNER_ENVIRONMENT:-}" == "github-hosted" ]] ||
    fail "execution requires a GitHub-hosted runner"
[[ "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" ]] ||
    fail "execution repository is not exact"
[[ "${GITHUB_WORKFLOW:-}" == "Prime active-root quarantine" \
    && "${GITHUB_JOB:-}" == "trusted-main-compile" ]] ||
    fail "execution workflow or job is not exact"
[[ "${GITHUB_WORKFLOW_REF:-}" \
    == "Ergentics/ergentics-prime/.github/workflows/prime-active-root-quarantine.yml@refs/heads/main" ]] ||
    fail "execution workflow ref is not exact"
[[ "${GITHUB_EVENT_NAME:-}" == "push" ]] ||
    fail "execution requires a push event"
[[ "${GITHUB_REF:-}" == "refs/heads/main" ]] ||
    fail "execution requires refs/heads/main"
[[ "${GITHUB_REF_TYPE:-}" == "branch" ]] ||
    fail "execution requires a branch ref"
[[ "${GITHUB_REF_NAME:-}" == "main" ]] ||
    fail "execution requires the main branch name"
[[ "${GITHUB_RUN_ATTEMPT:-}" == "1" ]] ||
    fail "execution reruns are forbidden"
[[ "${RUNNER_OS:-}" == "macOS" ]] ||
    fail "execution requires RUNNER_OS=macOS"
[[ "${RUNNER_ARCH:-}" == "ARM64" ]] ||
    fail "execution requires RUNNER_ARCH=ARM64"
[[ "${GITHUB_SHA:-}" == "$exact_revision" ]] ||
    fail "GitHub SHA does not equal EXACT_REVISION"
[[ "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" ]] ||
    fail "GitHub workflow SHA does not equal EXACT_REVISION"
[[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]] ||
    fail "execution requires macOS arm64"
[[ "$exact_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact Prime revision"
[[ "$mlx_revision" =~ ^[0-9a-f]{40}$ ]] ||
    fail "invalid exact MLX revision"
[[ "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "MLX wrapper revision is not the exact authorized pin"
[[ -d "$runner_temp" && ! -L "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not a real directory"
[[ "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not its physical absolute path"
[[ -f "${GITHUB_EVENT_PATH:-}" && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
    fail "GitHub push event payload is missing or linked"
jq -e \
    --arg revision "$exact_revision" \
    --arg base "$base_revision" \
    '.ref == "refs/heads/main"
     and .before == $base
     and .after == $revision
     and .head_commit.id == $revision
     and .repository.full_name == "Ergentics/ergentics-prime"
     and .deleted == false
     and .forced == false' \
    "$GITHUB_EVENT_PATH" >/dev/null ||
    fail "GitHub push event payload is not the exact non-forced main update"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "private dependency credential must not reach the repair launcher"
while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)
export MLX_ENABLE_TF32=0
[[ "$(env | awk -F= '$1 ~ /^MLX_/ {print $1}' | LC_ALL=C sort)" \
    == "MLX_ENABLE_TF32" ]] ||
    fail "repair launcher did not establish the exclusive MLX environment"
[[ -z "$(env | awk -F= '$1 ~ /^(DYLD_|LLVM_PROFILE_)/ {print $1}')" ]] ||
    fail "repair launcher retained a forbidden process override"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime checkout is not at the exact revision"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not clean"
readonly parent_line="$(git -C "$prime_root" rev-list --parents -n 1 HEAD)"
IFS=' ' read -r executed_commit first_parent second_parent extra_parent \
    <<< "$parent_line"
[[ "$executed_commit" == "$exact_revision" \
    && "$first_parent" == "$base_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && "$second_parent" != "$first_parent" \
    && -z "${extra_parent:-}" ]] ||
    fail "executed commit is not the exact two-parent direct successor of the authorized base"
git -C "$prime_root" cat-file -e "${first_parent}^{commit}"
[[ "$(git -C "$prime_root" rev-parse "${first_parent}^{tree}")" \
    == "$base_tree" ]] ||
    fail "authorized base tree changed"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
[[ "$exact_tree" =~ ^[0-9a-f]{40}$ ]] || fail "invalid exact Prime tree"
git -C "$prime_root" cat-file -e "${second_parent}^{commit}"
[[ "$(git -C "$prime_root" rev-parse "${second_parent}^{tree}")" \
    == "$exact_tree" ]] ||
    fail "merge tree differs from the reviewed second-parent tree"
readonly parent_count=2

readonly expected_changed_status=$'A\tSources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift\nA\tTests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift\nM\t.github/scripts/prime-ci-active-root-quarantine.sh\nM\t.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh\nM\t.github/workflows/prime-active-root-quarantine.yml\nM\tSources/PrimeCore/PrimeEmbeddedBuildProvenance.swift'
readonly observed_changed_status="$(git -C "$prime_root" diff-tree \
    --no-commit-id --name-status --no-renames -r \
    "$first_parent" "$exact_revision" | LC_ALL=C sort)"
[[ "$observed_changed_status" == "$expected_changed_status" ]] ||
    fail "direct-successor change scope is not the exact six-path repair"
readonly changed_paths_json="$(printf '%s\n' "$observed_changed_status" |
    awk -F '\t' '{print $2}' | LC_ALL=C sort |
    jq -Rsc 'split("\n")[:-1]')"
[[ "$(printf '%s' "$changed_paths_json" | jq 'length')" == "6" ]] ||
    fail "direct-successor changed-path count is not six"

assert_pinned_file() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_bytes="$4"
    local expected_sha256="$5"
    local absolute_path="$prime_root/$relative_path"
    [[ -f "$absolute_path" && ! -L "$absolute_path" \
        && "$(stat -f %l "$absolute_path")" == "1" ]] ||
        fail "pinned source is missing, linked, or aliased: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- "$relative_path" |
        awk '{print $1}')" == "$expected_mode" ]] ||
        fail "pinned source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object -- "$relative_path")" \
        == "$expected_blob" ]] ||
        fail "pinned source blob changed: $relative_path"
    [[ "$(stat -f %z "$absolute_path")" == "$expected_bytes" ]] ||
        fail "pinned source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$absolute_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        fail "pinned source SHA-256 changed: $relative_path"
}

assert_pinned_file \
    'Package.swift' '100644' \
    '765d3c88139bc1f74af16b77b2f3b06d33f66f75' '32795' \
    'bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2'
assert_pinned_file \
    'Package.resolved' '100644' \
    '14d804bb4291720477240c27e24de6fbdc876b3b' '645' \
    'bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375'
assert_pinned_file \
    'Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift' '100644' \
    '0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f' '39598' \
    'd59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994'
assert_pinned_file \
    'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' 'e160cc829f8498abafd100f3f0444742058f0479' '37829' \
    '5e6810a6bd5a9dc0bbe6d6369cec3db6dc84068dc9b415413aafb03f311211dc'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' '100644' \
    '9f05e5a17426f00adf9dad7b55d84057122e98f9' '1054' \
    '0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' '100644' \
    '8bf05edf1ea8789e7683e72fe756d79aaaa61320' '645' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' \
    '100644' '61e86200c508526ae2ab66e359d771841f7208db' '30214' \
    '29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96'
assert_pinned_file \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift' \
    '100644' 'b1c07a407f05fe7058c43656451f428ab794543e' '51385' \
    'ecd9d25354e6e74fe8aeb8421fb5dcc92c1f51309b0ce1f2c2791423be435293'
assert_pinned_file \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift' \
    '100644' 'f84eefb6428187ba4e08b3febf0c87256bd7788c' '29596' \
    'f17aa6fedf3f460de44f706c9fe9d6ebb5cd9b690936d4fb5a5947765c8ddfd3'
assert_pinned_file \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift' \
    '100644' 'b3b42c285c8fe048d4eeea111f3f9f9bab37707d' '66167' \
    '2f97065f3c09f69d2ce38774a16a5d4dcb9deb20899cdeb1f8821334d2486983'
assert_pinned_file \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift' \
    '100644' '15164c2256129816789fd2408f73f7b1c7eaccbd' '35453' \
    '2600a86636c5440ddd010e10a0928fd7f49b96d2926536d881364e524630d187'

[[ -f "$authority_source" && ! -L "$authority_source" \
    && "$(stat -f %l "$authority_source")" == "1" ]] ||
    fail "repair authority source is missing or linked"
[[ -f "$authority_test" && ! -L "$authority_test" \
    && "$(stat -f %l "$authority_test")" == "1" ]] ||
    fail "repair authority test is missing or linked"
grep -Fq \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityV1' \
    "$authority_source" || fail "repair authority type is missing"
grep -Fq \
    'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling' \
    "$authority_test" || fail "repair authority test is missing"
grep -Fq \
    '9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b' \
    "$authority_test" || fail "repair authority canonical digest is missing"
[[ "$(find "$validation_root" -type f ! -path '*/.*' -print |
    LC_ALL=C sort)" \
    == "$validation_lock"$'\n'"$validation_manifest"$'\n'"$validation_test" ]] ||
    fail "Stage-2 validation package inventory changed"

assert_regular_file() {
    local path="$1"
    [[ -f "$path" && ! -L "$path" \
        && "$(stat -f %l "$path")" == "1" ]] ||
        fail "required artifact is missing, linked, or aliased: $path"
}

file_identity() {
    local path="$1"
    assert_regular_file "$path"
    printf '%s:%s:%s:%s:%s:%s:%s:%s' \
        "$(stat -f %d "$path")" \
        "$(stat -f %i "$path")" \
        "$(stat -f %u "$path")" \
        "$(stat -f %g "$path")" \
        "$(stat -f %Lp "$path")" \
        "$(stat -f %l "$path")" \
        "$(stat -f %z "$path")" \
        "$(shasum -a 256 "$path" | awk '{print $1}')"
}

assert_mlx_worktree() {
    local path="$1"
    [[ -d "$path" && ! -L "$path" ]] ||
        fail "MLX worktree is missing or linked: $path"
    [[ "$(git -C "$path" rev-parse HEAD)" == "$mlx_revision" ]] ||
        fail "MLX worktree revision changed: $path"
    [[ "$(git -C "$path" submodule status --recursive)" \
        == "$expected_mlx_submodules" ]] ||
        fail "MLX worktree submodules changed: $path"
    [[ -z "$(git -C "$path" status --porcelain=v1 --untracked-files=all)" ]] ||
        fail "MLX worktree is dirty: $path"
}

assert_numerics_worktree() {
    local path="$1"
    [[ -d "$path" && ! -L "$path" ]] ||
        fail "Swift Numerics worktree is missing or linked: $path"
    [[ "$(git -C "$path" rev-parse HEAD)" == "$numerics_revision" ]] ||
        fail "Swift Numerics revision changed: $path"
    [[ -z "$(git -C "$path" status --porcelain=v1 --untracked-files=all)" ]] ||
        fail "Swift Numerics worktree is dirty: $path"
}

[[ -d "$mlx_bare" && ! -L "$mlx_bare" ]] ||
    fail "missing exact MLX bare repository"
[[ "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
    == "$mlx_revision" ]] ||
    fail "MLX bare repository is not pinned exactly"
assert_mlx_worktree "$mlx_source"

readonly predecessor_mlx_worktrees=(
    "$metal_build/checkouts/ergentics-mlx-swift"
    "$runtime_build/checkouts/ergentics-mlx-swift"
    "$tokenizer_build/checkouts/ergentics-mlx-swift"
)
readonly predecessor_numerics_worktrees=(
    "$metal_build/checkouts/swift-numerics"
    "$runtime_build/checkouts/swift-numerics"
    "$tokenizer_build/checkouts/swift-numerics"
)
for worktree in "${predecessor_mlx_worktrees[@]}"; do
    assert_mlx_worktree "$worktree"
done
for worktree in "${predecessor_numerics_worktrees[@]}"; do
    assert_numerics_worktree "$worktree"
done
readonly frozen_numerics_checkout="${predecessor_numerics_worktrees[0]}"

readonly predecessor_logs=(
    "$active_root_log"
    "$checkpoint_v2_log"
    "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_log"
    "$checkpoint_v2_io_root_repair_log"
    "$metal_log"
    "$runtime_test_log"
    "$runtime_probe_log"
    "$tokenizer_test_log"
    "$tokenizer_probe_log"
)
[[ "${#predecessor_logs[@]}" -eq 10 ]] ||
    fail "predecessor log inventory changed"
for predecessor_log in "${predecessor_logs[@]}"; do
    assert_regular_file "$predecessor_log"
done
grep -Fq 'Executed 41 tests, with 0 failures' "$active_root_log" ||
    fail "focused root-41 contracts did not complete"
grep -Fq \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests' \
    "$active_root_log" ||
    fail "focused root log does not bind the repair authority class"
grep -Fq \
    'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling' \
    "$active_root_log" ||
    fail "focused root log does not bind the repair authority method"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint V2 identity contract did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint V2 I/O declarative contract did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' \
    "$checkpoint_v2_io_execution_log" ||
    fail "checkpoint V2 I/O pure contracts did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' \
    "$checkpoint_v2_io_root_repair_log" ||
    fail "checkpoint root-identity pure contracts did not complete"
grep -Fq 'Executed 44 tests, with 0 failures' "$metal_log" ||
    fail "repaired 44-test Metal suite did not complete"
grep -Fq "testMetalRepairAuthorityIsAppendOnlyAndSourceExact]' passed" \
    "$metal_log" || fail "repaired Metal identity assertion did not pass"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "maintained-runtime authority test did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer authority test did not complete"
for predecessor_test_log in \
    "$active_root_log" "$checkpoint_v2_log" "$checkpoint_v2_io_log" \
    "$checkpoint_v2_io_execution_log" "$checkpoint_v2_io_root_repair_log" \
    "$metal_log" "$runtime_test_log" "$tokenizer_test_log"; do
    ! xctest_log_has_failure_or_skip "$predecessor_test_log" ||
        fail "predecessor test log failed or skipped: $predecessor_test_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' \
    "$runtime_probe_log")" == "1" ]] ||
    fail "maintained-runtime receipt count is not one"
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    "$tokenizer_probe_log")" == "1" ]] ||
    fail "tokenizer receipt count is not one"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "same-job fresh metallib root is missing"
[[ "$(cd "$frozen_metallib_root" && pwd -P)" \
    == "$frozen_metallib_root" ]] ||
    fail "same-job fresh metallib root is not its physical fixed path"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" \
    \( -name default.metallib -o -name mlx.metallib \) -print)
[[ "$metallib_count" -eq 1 ]] ||
    fail "fresh metallib root does not contain exactly one loader candidate"
assert_regular_file "$metallib"
readonly metallib_parent="$(cd "$(dirname "$metallib")" && pwd -P)"
[[ -s "$metallib" \
    && "${metallib##*/}" == "default.metallib" \
    && "$metallib" == "$frozen_metallib_root"/* \
    && ( "$metallib_parent" == "$frozen_metallib_root" \
        || "$metallib_parent" == "$frozen_metallib_root"/* ) ]] ||
    fail "fresh default.metallib is empty, renamed, or escaped its fixed root"
readonly metallib_relative_path="${metallib#"$runner_temp/"}"
[[ "$metallib_relative_path" != "$metallib" \
    && "$metallib_relative_path" != *$'\n'* \
    && "$metallib_relative_path" != *$'\r'* ]] ||
    fail "fresh metallib relative path is unsafe"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_byte_count" -le 67108864 ]] ||
    fail "fresh metallib byte count is outside the bound"
[[ "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib SHA-256 is invalid"
grep -Fq \
    "Prime decoder Metal gate: metallib_sha256=${metallib_sha256} metallib_bytes=${metallib_byte_count}" \
    "$metal_log" || fail "Metal log does not bind the fresh metallib"

readonly runtime_receipt="$(grep -E \
    '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log" |
    sed 's/^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=//')"
printf '%s' "$runtime_receipt" | jq -e \
    --arg sha256 "$metallib_sha256" \
    --argjson byte_count "$metallib_byte_count" \
    '.evidence_id == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1"
     and .runtime_dependency_closure_established == true
     and .metallib.sha256 == $sha256
     and .metallib.byte_count == $byte_count
     and .checkpoint_io_observed == false
     and .training_execution_observed == false' >/dev/null ||
    fail "maintained-runtime predecessor receipt changed"
readonly tokenizer_receipt="$(grep -E \
    '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    "$tokenizer_probe_log" |
    sed 's/^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=//')"
printf '%s' "$tokenizer_receipt" | jq -e \
    --arg revision "$exact_revision" \
    --arg tree "$exact_tree" \
    --arg sha256 "$metallib_sha256" \
    --argjson byte_count "$metallib_byte_count" \
    '.executed_revision == $revision
     and .executed_tree == $tree
     and .metallib_sha256 == $sha256
     and .metallib_byte_count == $byte_count
     and .status == "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"
     and .train_evaluate_surface_established == false
     and .training_execution_observed == false' >/dev/null ||
    fail "tokenizer predecessor receipt changed"

readonly metal_bin="$metal_build/arm64-apple-macosx/debug"
readonly runtime_bin="$runtime_build/arm64-apple-macosx/release"
readonly tokenizer_bin="$tokenizer_build/arm64-apple-macosx/release"
readonly predecessor_metallibs=(
    "$metallib"
    "$metal_bin/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
    "$metal_bin/PrimeNativeDecoderValidationPackageTests.xctest/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
    "$runtime_bin/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
    "$tokenizer_bin/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
)
[[ "${#predecessor_metallibs[@]}" -eq 5 ]] ||
    fail "predecessor metallib inventory changed"
for predecessor_metallib in "${predecessor_metallibs[@]}"; do
    assert_regular_file "$predecessor_metallib"
    [[ "$(cd "$(dirname "$predecessor_metallib")" && pwd -P)" \
        == "$(dirname "$predecessor_metallib")" ]] ||
        fail "predecessor metallib parent is linked or aliased: $predecessor_metallib"
    cmp -s "$metallib" "$predecessor_metallib" ||
        fail "predecessor metallib bytes diverged: $predecessor_metallib"
    [[ "$(stat -f %z "$predecessor_metallib")" \
        == "$metallib_byte_count" ]] ||
        fail "predecessor metallib byte count diverged: $predecessor_metallib"
    [[ "$(shasum -a 256 "$predecessor_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" ]] ||
        fail "predecessor metallib SHA-256 diverged: $predecessor_metallib"
done
for immutable_metallib in \
    "${predecessor_metallibs[3]}" "${predecessor_metallibs[4]}"; do
    [[ "$(stat -f %Lp "$immutable_metallib")" == "444" ]] ||
        fail "predecessor staged metallib is not mode 0444: $immutable_metallib"
done

readonly predecessor_artifacts=(
    "${predecessor_logs[@]}"
    "${predecessor_metallibs[@]}"
)
[[ "${#predecessor_artifacts[@]}" -eq 15 ]] ||
    fail "predecessor artifact inventory changed"
predecessor_artifact_identities=()
for predecessor_artifact in "${predecessor_artifacts[@]}"; do
    predecessor_artifact_identities+=("$(file_identity "$predecessor_artifact")")
done

for fresh_path in \
    "$scratch_path" "$cache_path" "$config_path" "$security_path" \
    "$private_cwd" "$test_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "repair path must be initially absent: $fresh_path"
done
mkdir -p \
    "$scratch_path" "$cache_path" "$config_path" "$security_path" \
    "$private_cwd"
chmod 700 "$private_cwd"
[[ "$(stat -f %Lp "$private_cwd")" == "700" \
    && "$(stat -f %u "$private_cwd")" == "$(id -u)" \
    && -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private repair working directory is not exact and empty"

export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://${frozen_numerics_checkout}/.insteadOf"
export GIT_CONFIG_VALUE_1="https://github.com/apple/swift-numerics"
export GIT_CONFIG_KEY_2="protocol.file.allow"
export GIT_CONFIG_VALUE_2="always"
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
    --configuration debug
    --jobs 2
)
TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1
unset GIT_CONFIG_KEY_2 GIT_CONFIG_VALUE_2

readonly compiled_mlx="$scratch_path/checkouts/ergentics-mlx-swift"
readonly compiled_numerics="$scratch_path/checkouts/swift-numerics"
assert_mlx_worktree "$compiled_mlx"
assert_numerics_worktree "$compiled_numerics"
readonly bin_path="$scratch_path/arm64-apple-macosx/debug"
[[ -d "$bin_path" && ! -L "$bin_path" \
    && "$(cd "$bin_path" && pwd -P)" == "$bin_path" ]] ||
    fail "Stage-2 binary directory is missing, linked, or outside the exact path"
readonly test_bundle="$bin_path/PrimeNativeDecoderTrainingValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderTrainingValidationPackageTests"
readonly cli_bundle="$bin_path/mlx-swift_Cmlx.bundle"
readonly test_resource_bundle="$test_bundle/Contents/Resources/mlx-swift_Cmlx.bundle"
readonly cli_metallib="$cli_bundle/Contents/Resources/default.metallib"
readonly test_resource_metallib="$test_resource_bundle/Contents/Resources/default.metallib"
[[ -d "$test_bundle" && ! -L "$test_bundle" ]] ||
    fail "Stage-2 XCTest bundle is missing or linked"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "Stage-2 XCTest executable is missing or linked"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Stage-2 XCTest executable does not link ${framework}"
done
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Stage-2 binary directory already contains a loader candidate"
for destination_bundle in "$cli_bundle" "$test_resource_bundle"; do
    if [[ -e "$destination_bundle" || -L "$destination_bundle" ]]; then
        [[ -d "$destination_bundle" && ! -L "$destination_bundle" ]] ||
            fail "Stage-2 destination bundle is not a real directory: $destination_bundle"
    fi
done
for destination_metallib in "$cli_metallib" "$test_resource_metallib"; do
    [[ ! -e "$destination_metallib" && ! -L "$destination_metallib" ]] ||
        fail "Stage-2 metallib destination must be initially absent: $destination_metallib"
done
mkdir -p \
    "$cli_bundle/Contents/Resources" \
    "$test_resource_bundle/Contents/Resources"
for destination_directory in \
    "$cli_bundle" \
    "$cli_bundle/Contents" \
    "$cli_bundle/Contents/Resources" \
    "$test_bundle/Contents" \
    "$test_bundle/Contents/Resources" \
    "$test_resource_bundle" \
    "$test_resource_bundle/Contents" \
    "$test_resource_bundle/Contents/Resources"; do
    [[ -d "$destination_directory" && ! -L "$destination_directory" \
        && "$(cd "$destination_directory" && pwd -P)" \
            == "$destination_directory" ]] ||
        fail "Stage-2 destination directory is linked or aliased: $destination_directory"
done
cp -X "$metallib" "$cli_metallib"
cp -X "$metallib" "$test_resource_metallib"
chmod 444 "$cli_metallib" "$test_resource_metallib"
readonly expected_stage2_loader_inventory="$test_resource_metallib"$'\n'"$cli_metallib"
readonly observed_stage2_loader_inventory="$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print |
    LC_ALL=C sort)"
[[ "$observed_stage2_loader_inventory" \
    == "$expected_stage2_loader_inventory" ]] ||
    fail "Stage-2 loader inventory is not the exact two destinations"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    assert_regular_file "$staged_metallib"
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %u "$staged_metallib")" == "$(id -u)" ]] ||
        fail "Stage-2 staged metallib ownership or mode changed: $staged_metallib"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "Stage-2 metallib staging changed bytes: $staged_metallib"
    [[ "$(stat -f %z "$staged_metallib")" \
        == "$metallib_byte_count" ]] ||
        fail "Stage-2 staged metallib byte count changed: $staged_metallib"
    [[ "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" ]] ||
        fail "Stage-2 staged metallib SHA-256 changed: $staged_metallib"
done
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" \
    && ! -e "$private_cwd/default.metallib" \
    && ! -L "$private_cwd/default.metallib" ]] ||
    fail "private repair cwd contains a fallback loader candidate"

set +e
(
    cd "$private_cwd"
    TMPDIR="$runner_temp" xcrun xctest \
        -XCTest "$test_filter" "$test_bundle"
) 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${test_pipe_status[0]:-1}" -eq 0 ]] ||
    fail "Stage-2 direct XCTest invocation failed"
[[ "${test_pipe_status[1]:-1}" -eq 0 ]] ||
    fail "Stage-2 XCTest log capture failed"
assert_regular_file "$test_log"
[[ -s "$test_log" ]] || fail "Stage-2 XCTest log is empty"
[[ "$(grep -Ec '^Test Case .* started\.$' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$test_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$test_log")" == "0" ]] ||
    fail "Stage-2 XCTest start/pass/failure/skip counts are not 1/1/0/0"
[[ "$(grep -Ec "^Test Case .*${test_method}.* started\\.$" \
    "$test_log")" == "1" \
    && "$(grep -Ec "^Test Case .*${test_method}.* passed \\(" \
    "$test_log")" == "1" ]] ||
    fail "exact frozen Stage-2 test did not start and pass once"
grep -Fq "Test Suite '${test_class}' passed" "$test_log" ||
    fail "Stage-2 XCTest class did not pass"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "Stage-2 XCTest did not execute exactly one test"
! xctest_log_has_failure_or_skip "$test_log" ||
    fail "Stage-2 XCTest reported a failure, error, or skip"
! grep -Fq 'Metal is unavailable' "$test_log" ||
    fail "Stage-2 XCTest reported unavailable Metal"

# Revalidate every repository and predecessor artifact after the one direct
# XCTest invocation. The two Stage-2 copies and the empty private cwd are also
# rechecked before the sole non-artifact receipt is emitted.
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-2 repair"
[[ "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
    == "$mlx_revision" ]] ||
    fail "MLX bare repository changed during Stage-2 repair"
assert_mlx_worktree "$mlx_source"
for worktree in "${predecessor_mlx_worktrees[@]}" "$compiled_mlx"; do
    assert_mlx_worktree "$worktree"
done
for worktree in "${predecessor_numerics_worktrees[@]}" "$compiled_numerics"; do
    assert_numerics_worktree "$worktree"
done
for artifact_index in "${!predecessor_artifacts[@]}"; do
    [[ "$(file_identity "${predecessor_artifacts[$artifact_index]}")" \
        == "${predecessor_artifact_identities[$artifact_index]}" ]] ||
        fail "predecessor artifact changed during Stage-2 repair: ${predecessor_artifacts[$artifact_index]}"
done
[[ "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print |
    LC_ALL=C sort)" == "$expected_stage2_loader_inventory" ]] ||
    fail "Stage-2 loader inventory changed after execution"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %l "$staged_metallib")" == "1" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
            == "$metallib_sha256" ]] ||
        fail "Stage-2 staged metallib changed after execution: $staged_metallib"
done
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private repair working directory changed during execution"
[[ "$(env | awk -F= '$1 ~ /^MLX_/ {print $1}' | LC_ALL=C sort)" \
    == "MLX_ENABLE_TF32" \
    && "$MLX_ENABLE_TF32" == "0" ]] ||
    fail "exclusive MLX environment changed during execution"
[[ -z "$(env | awk -F= \
    '$1 ~ /^(DYLD_|LLVM_PROFILE_|GIT_CONFIG_COUNT$|GIT_CONFIG_KEY_|GIT_CONFIG_VALUE_)/ {print $1}')" ]] ||
    fail "temporary dependency or process environment remained after execution"
for prior_log in "${predecessor_logs[@]}" "$test_log"; do
    ! grep -Fq -- "$receipt_prefix" "$prior_log" ||
        fail "repair receipt prefix existed before the sole receipt emission"
done

readonly receipt_json="$(jq -cnS \
    --arg authority_id \
        'ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_predecessor_log_classifier_repair_authority_v1' \
    --arg receipt_id \
        'ergentics_prime_native_decoder_stage2_metallib_bootstrap_predecessor_log_classifier_repair_receipt_v1' \
    --arg status \
        'PASS_exact_main_stage2_same_job_fresh_metallib_bootstrap_predecessor_log_classifier_repair_one_test_zero_failure_zero_skip' \
    --arg revision "$exact_revision" \
    --arg tree "$exact_tree" \
    --arg first_parent "$first_parent" \
    --arg second_parent "$second_parent" \
    --argjson parent_count "$parent_count" \
    --argjson changed_paths "$changed_paths_json" \
    --arg mlx_revision "$mlx_revision" \
    --arg predecessor_log_classifier_regex "$xctest_failure_or_skip_regex" \
    --arg source_relative_path "$metallib_relative_path" \
    --arg metallib_sha256 "$metallib_sha256" \
    --argjson metallib_byte_count "$metallib_byte_count" \
    --arg test_class "$test_class" \
    --arg test_method "$test_method" \
    --arg test_filter "$test_filter" \
    '{
      schema_version: 1,
      receipt_id: $receipt_id,
      authority_id: $authority_id,
      status: $status,
      execution: {
        revision: $revision,
        tree: $tree,
        first_parent_revision: $first_parent,
        second_parent_revision: $second_parent,
        parent_count: $parent_count,
        changed_paths: $changed_paths,
        github_event_name: "push",
        github_ref: "refs/heads/main",
        github_run_attempt: 1
      },
      dependency: {
        mlx_revision: $mlx_revision,
        validated_repository_count_before_build: 8,
        validated_repository_count_after_execution: 10
      },
      predecessor: {
        validated_log_count: 10,
        validated_receipt_count: 2,
        focused_root_test_count: 41,
        focused_isolated_test_count: 6,
        focused_whole_step_test_count: 47,
        metal_test_count: 44,
        maintained_runtime_test_count: 1,
        tokenizer_test_count: 1,
        pre_stage2_total_test_count: 93,
        retained_order: ["metal", "maintained_runtime", "tokenizer", "stage2"]
      },
      predecessor_log_classifier: {
        command: "grep -Eq",
        exact_regex: $predecessor_log_classifier_regex,
        matching_is_case_sensitive: true,
        quoted_xctest_case_and_suite_outcome_markers_require_closed_identity: true,
        line_leading_error_diagnostic_is_rejected: true,
        xctest_skip_diagnostic_is_rejected: true,
        acceptance_fixture_count: 8,
        acceptance_fixture_match_count: 0,
        rejection_fixture_count: 5,
        rejection_fixture_match_count: 5
      },
      metallib: {
        source_relative_path: $source_relative_path,
        source_candidate_count: 1,
        byte_count: $metallib_byte_count,
        sha256: $metallib_sha256,
        built_by_this_launcher: false,
        staged_copy_count: 2,
        staged_permission_mode: "444",
        staged_relative_paths: [
          "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
          "PrimeNativeDecoderTrainingValidationPackageTests.xctest/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
        ],
        copies_byte_identical: true,
        retained_after_job: false,
        artifact_provenance_established: false
      },
      stage2_test: {
        build_command: "swift build --build-tests",
        build_command_count: 1,
        direct_xctest_invocation_count: 1,
        test_class: $test_class,
        test_method: $test_method,
        test_filter: $test_filter,
        started_count: 1,
        passed_count: 1,
        failure_count: 0,
        skip_count: 0,
        private_working_directory_empty_before_and_after: true,
        tiny_cpu_train_evaluate_mechanics_execution_established: true,
        default_metallib_bootstrap_repair_established: true
      },
      authority_ceiling: {
        same_job_ephemeral_metallib_only: true,
        receipt_is_actions_artifact: false,
        artifact_upload_invoked: false,
        checkpoint_io_observed: false,
        checkpoint_admission_granted: false,
        retained_artifact_established: false,
        native300m_training_authorized: false,
        training_resume_established: false,
        stage3_authorized: false,
        trial_authorized: false,
        canary_replacement_authorized: false,
        product_use_authorized: false,
        publication_authorized: false,
        rerun_authorized: false
      }
    }')"
[[ "$receipt_json" != *$'\n'* && "$receipt_json" != *$'\r'* ]] ||
    fail "repair receipt is not one-line canonical JSON"
[[ "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "repair receipt is not canonical JSON"
printf '%s%s\n' "$receipt_prefix" "$receipt_json"

echo "OK: exact-main Stage-2 mechanics passed once with two mode-0444 byte-identical copies of the retained same-job fresh metallib; Stage 3 remains unauthorized"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The exact direct-successor reviewed-main attempt reused the retained Metal launcher’s same-job fresh default.metallib only after Metal 44/44, maintained runtime 1/1, and tokenizer 1/1 completed.'
        echo 'The unchanged Stage-2 validation bundle was built once, received two mode-0444 byte-identical ephemeral bundle copies, and ran its sole frozen method directly from an empty private working directory with one pass, zero failures, and zero skips.'
        echo 'The one-line receipt is log-only and non-artifactual. No metallib build, checkpoint I/O or admission, retained artifact, Native-300M training, resume, Stage 3, trial, canary, product, publication, upload, or rerun authority is established.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

#!/usr/bin/env bash
# Exact-head GitHub-hosted Metal gate for the Prime-owned decoder.
set -euo pipefail

fail() {
    echo "prime-native-decoder-metal: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly ci_policy_id="ergentics_prime_native_decoder_ci_mlx_compute_environment"
readonly expected_mlx_submodules=$' ce45c52505c8158ea48d2a54e8caae05efd86bfe Source/Cmlx/mlx (v0.31.1)\n 0726ca922fc902c4c61ef9c27d94132be418e945 Source/Cmlx/mlx-c (v0.6.0)'
readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly validation_root="$prime_root/Tests/PrimeNativeDecoderValidation"
readonly scratch_path="$runner_temp/prime-native-decoder-build"
readonly cache_path="$runner_temp/prime-native-decoder-cache"
readonly config_path="$runner_temp/prime-native-decoder-config"
readonly security_path="$runner_temp/prime-native-decoder-security"
readonly metallib_attempt="$runner_temp/prime-native-decoder-metallib"
readonly test_log="$runner_temp/prime-native-decoder-metal-tests.log"

[[ "$exact_revision" =~ ^[0-9a-f]{40}$ ]] || fail "invalid exact revision"
[[ "$mlx_revision" =~ ^[0-9a-f]{40}$ ]] || fail "invalid MLX revision"
while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)
export MLX_ENABLE_TF32=0
[[ "$(env | awk -F= '$1 ~ /^MLX_/ {print $1}' | LC_ALL=C sort)" \
    == "MLX_ENABLE_TF32" ]] ||
    fail "reviewed launcher did not establish the exclusive MLX environment"
[[ "$MLX_ENABLE_TF32" == "0" ]] ||
    fail "reviewed launcher established the wrong TF32 value"
[[ -z "$(env | awk -F= '$1 ~ /^(DYLD_|LLVM_PROFILE_)/ {print $1}')" ]] ||
    fail "reviewed launcher retained a forbidden process override"
[[ "$(uname -m)" == arm64 ]] || fail "live Metal gate requires Apple silicon"
xcrun swift -e '
    import CoreGraphics
    import Metal
    _ = CGColorSpaceCreateDeviceRGB()
    guard let device = MTLCreateSystemDefaultDevice() else {
        fatalError("GitHub runner exposes no default Metal device")
    }
    print("Prime decoder Metal gate: device=\(device.name)")
'
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime checkout is not at the exact revision"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not clean"
[[ -d "$mlx_bare" && ! -L "$mlx_bare" ]] || fail "missing exact MLX bare repository"
[[ -d "$mlx_source" && ! -L "$mlx_source" ]] || fail "missing exact MLX source worktree"
[[ "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" == "$mlx_revision" ]] ||
    fail "MLX bare repository is not pinned exactly"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX source worktree is not pinned exactly"
[[ "$(git -C "$mlx_source" submodule status --recursive)" == "$expected_mlx_submodules" ]] ||
    fail "MLX source submodules are not pinned exactly"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX source worktree is not clean"
[[ -d "$mlx_source/xcode/MLX.xcodeproj" ]] || fail "pinned MLX Xcode project is missing"

mkdir -p \
    "$scratch_path" \
    "$cache_path" \
    "$config_path" \
    "$security_path"
[[ ! -e "$metallib_attempt" && ! -L "$metallib_attempt" ]] ||
    fail "metallib attempt root already exists"
mkdir -p "$metallib_attempt/obj" "$metallib_attempt/products"

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
)

TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests

readonly swiftpm_mlx_source="$scratch_path/checkouts/ergentics-mlx-swift"
[[ -d "$swiftpm_mlx_source" && ! -L "$swiftpm_mlx_source" ]] ||
    fail "SwiftPM MLX checkout is missing"
[[ "$(git -C "$swiftpm_mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "SwiftPM compiled a different MLX revision"
[[ "$(git -C "$swiftpm_mlx_source" submodule status --recursive)" == "$expected_mlx_submodules" ]] ||
    fail "SwiftPM compiled different MLX submodules"
[[ -z "$(git -C "$swiftpm_mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "SwiftPM MLX checkout is not clean"

xcodebuild \
    -project "$mlx_source/xcode/MLX.xcodeproj" \
    -target Cmlx \
    -configuration Debug \
    OBJROOT="$metallib_attempt/obj" \
    SYMROOT="$metallib_attempt/products" \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=YES \
    ARCHS=arm64 \
    build

metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$metallib_attempt" -type f -name default.metallib -print)
[[ "$metallib_count" -eq 1 && -f "$metallib" && -s "$metallib" && ! -L "$metallib" ]] ||
    fail "expected exactly one generated default.metallib"

bin_path="$(TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --show-bin-path)"
[[ "$bin_path" == "$scratch_path/arm64-apple-macosx/debug" ]] ||
    fail "SwiftPM binary directory is outside the exact arm64 debug path"
[[ -d "$bin_path" && ! -L "$bin_path" ]] || fail "SwiftPM binary directory is missing"
readonly test_bundle="$bin_path/PrimeNativeDecoderValidationPackageTests.xctest"
readonly cli_bundle="$bin_path/mlx-swift_Cmlx.bundle"
readonly test_resource_bundle="$test_bundle/Contents/Resources/mlx-swift_Cmlx.bundle"
[[ -d "$test_bundle" && ! -L "$test_bundle" ]] || fail "decoder XCTest bundle is missing"

for destination_bundle in "$cli_bundle" "$test_resource_bundle"; do
    [[ ! -e "$destination_bundle" && ! -L "$destination_bundle" ]] ||
        fail "metallib destination must be initially absent: $destination_bundle"
done
mkdir -p \
    "$cli_bundle/Contents/Resources" \
    "$test_resource_bundle/Contents/Resources"
cp "$metallib" "$cli_bundle/Contents/Resources/default.metallib"
cp "$metallib" "$test_resource_bundle/Contents/Resources/default.metallib"
cmp -s "$metallib" "$cli_bundle/Contents/Resources/default.metallib" ||
    fail "CLI metallib staging changed bytes"
cmp -s "$metallib" "$test_resource_bundle/Contents/Resources/default.metallib" ||
    fail "XCTest metallib staging changed bytes"

readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderValidationPackageTests"
[[ -x "$test_executable" ]] || fail "decoder XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/${framework}.framework/" ||
        fail "decoder XCTest executable does not link ${framework}"
done

echo "Prime decoder Metal gate: metallib_sha256=$(shasum -a 256 "$metallib" | awk '{print $1}') metallib_bytes=$(stat -f %z "$metallib")"

set +e
TMPDIR="$runner_temp" xcrun xctest "$test_bundle" \
    2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${test_pipe_status[0]:-1}" -eq 0 ]] || fail "decoder XCTest command failed"
[[ "${test_pipe_status[1]:-1}" -eq 0 ]] || fail "decoder XCTest log capture failed"
[[ -s "$test_log" ]] || fail "decoder XCTest log is empty"
! grep -Eiq '^Test (Case|Suite).*failed|^error:' "$test_log" ||
    fail "decoder XCTest reported a failure"
! grep -Eiq 'skipped|Test skipped|Metal is unavailable' "$test_log" ||
    fail "live Metal gate cannot contain skipped tests"
grep -Fq "Test Suite 'PrimeNativeDecoderAuthorityTests' passed" "$test_log" ||
    fail "decoder authority suite did not pass"
grep -Fq "Test Suite 'PrimeNativeDecoderCheckpointTests' passed" "$test_log" ||
    fail "decoder checkpoint suite did not pass"
grep -Fq "Test Suite 'PrimeNativeGQADecoderTests' passed" "$test_log" ||
    fail "decoder GQA suite did not pass"
grep -Eq 'Executed 44 tests, with 0 failures' "$test_log" ||
    fail "full 44-test decoder suite did not execute"

for required_metal_test in \
    testParameterInventoryIsExactAndOutputProjectionIsTied \
    testUnequalHeadGQAForwardIsFiniteAndCausal \
    testProjectedQKVHasExactHeadShapesAndRoPEOffsetScope \
    testPinnedCausalSDPAMatchesScalarGQAReference \
    testSeededConstructionIsDeterministicAndSeedSensitive \
    testInputValidationRejectsUnsupportedSequences \
    testCachePrefillAndSingleTokenDecodeMatchFullPrefix \
    testCacheSupportsRectangularBatchAndCausalChunkContinuation \
    testCacheCapacityGrowthPreservesPrefixAndParity \
    testCacheRejectsParameterRevisionMixingUntilReset \
    testCacheValidationFailsBeforeMutationAndResetReplays \
    testCacheContextLimitFailsWithoutAdvancingState \
    testCausalGQAAndRoPEAreDifferentiableWithoutTraining \
    testSeededFactoryDoesNotConsumeGlobalRandomState \
    testSyntheticBorrowedDescriptorRoundTripRestoresExactFreshModel \
    testSyntheticLoadRejectsDifferentValidManifestBeforeRestore \
    testSyntheticLoadRejectsMalformedMetadataAndTensorCatalog; do
    grep -Fq -- "$required_metal_test]' passed" "$test_log" ||
        fail "required live Metal test did not pass: $required_metal_test"
done

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" ]] ||
    fail "Prime revision changed during the Metal gate"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout changed during the Metal gate"
[[ "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "MLX donor revision changed during the Metal gate"
[[ "$(git -C "$mlx_source" submodule status --recursive)" == "$expected_mlx_submodules" ]] ||
    fail "MLX donor submodules changed during the Metal gate"
[[ -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX donor changed during the Metal gate"
[[ "$(git -C "$swiftpm_mlx_source" rev-parse HEAD)" == "$mlx_revision" ]] ||
    fail "SwiftPM MLX revision changed during the Metal gate"
[[ "$(git -C "$swiftpm_mlx_source" submodule status --recursive)" == "$expected_mlx_submodules" ]] ||
    fail "SwiftPM MLX submodules changed during the Metal gate"
[[ -z "$(git -C "$swiftpm_mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "SwiftPM MLX checkout changed during the Metal gate"

echo "OK: exact-head Prime decoder body, GQA, RoPE, gradients, KV cache, and synthetic checkpoint mechanics passed on live Metal under ${ci_policy_id} v1"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo "The exact reviewed Prime main revision passed all 44 isolated native-decoder tests on a GitHub-hosted Apple-silicon Metal device under CI mechanics policy ${ci_policy_id} version 1, with MLX_ENABLE_TF32=0 fixed before first MLX access, the exact pinned MLX source, and a freshly staged default.metallib."
        echo 'This synthetic CI mechanics observation neither changes nor satisfies the separate frozen maintained-runtime policy and grants no checkpoint admission, training or resume, trial, canary, product, or publication authority.'
    } >> "$GITHUB_STEP_SUMMARY"
fi

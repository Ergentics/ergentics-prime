#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly script_directory="$(cd "$(dirname "$0")" && pwd -P)"
readonly prime_root="$(cd "$script_directory/../.." && pwd -P)"
readonly expected_prime_head="${GITHUB_SHA:?GITHUB_SHA is required}"
readonly checkout_token="${ERGENTICS_MLX_READ_TOKEN:-}"
readonly expected_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly expected_mlx_origin="https://github.com/Ergentics/ergentics-mlx-swift"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"

die() {
    echo "prime-ci-root-quarantine: $*" >&2
    exit 1
}

for command_name in git grep jq sed swift; do
    command -v "$command_name" >/dev/null 2>&1 ||
        die "missing command: $command_name"
done

[[ -n "$checkout_token" ]] ||
    die "ERGENTICS_MLX_READ_TOKEN is required"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout does not match GITHUB_SHA"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout is dirty"

for forbidden_active_root in \
    mlx-swift-lm \
    MLXLLM \
    'name: "PrimeGPUCalibration"' \
    'name: "PrimeNative3BMetalContinuationProbe"'; do
    if grep -Fq -- "$forbidden_active_root" "$prime_root/Package.swift"; then
        die "active root manifest retains quarantined dependency: $forbidden_active_root"
    fi
done

jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$expected_mlx_revision" \
    '
      ([.pins[] | select(
          .identity == "mlx-swift-lm"
          or .identity == "swift-syntax"
      )] | length) == 0
      and ([.pins[] | select(
          .identity == "ergentics-mlx-swift"
          and .location == $expected_origin
          and .state.revision == $expected_revision
      )] | length) == 1
    ' \
    "$prime_root/Package.resolved" >/dev/null ||
    die "active root lock does not preserve the exact first-party MLX boundary"

jq -e '.version == 1 and .object == []' \
    "$prime_root/.swiftpm/configuration/mirrors.json" >/dev/null ||
    die "active root retains a SwiftPM mirror mapping"

quarantine_workflow="$runner_temp/root-quarantine-workflow.yml"
sed -n '/^  root-quarantine:/,$p' \
    "$prime_root/.github/workflows/swift.yml" > "$quarantine_workflow"
[[ -s "$quarantine_workflow" ]] ||
    die "root-quarantine workflow job is missing"
if grep -n -E \
    'pmhnp-companion-ergentics|PRIME_PMHNP_COMPANION_ROOT|PRIME_NATIVE_COMPANION_ROOT' \
    "$quarantine_workflow"; then
    die "root-quarantine gate gained a companion dependency"
fi

export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.https://x-access-token:${checkout_token}@github.com/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/"
export CLANG_MODULE_CACHE_PATH="$runner_temp/prime-root-quarantine-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"

swift test \
    --package-path "$prime_root" \
    --scratch-path "$runner_temp/prime-root-quarantine-build" \
    --cache-path "$runner_temp/prime-root-quarantine-cache" \
    --config-path "$runner_temp/prime-root-quarantine-config" \
    --security-path "$runner_temp/prime-root-quarantine-security" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --force-resolved-versions \
    --filter PrimeNativeNeuralGateMLXIsolationSourceContractTests

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset CLANG_MODULE_CACHE_PATH SWIFTPM_MODULECACHE_OVERRIDE

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during the quarantine gate"

echo "OK: active Prime root excludes MLXLLM and preserves exact Ergentics MLX"

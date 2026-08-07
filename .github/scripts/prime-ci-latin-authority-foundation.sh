#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly script_directory="$(cd "$(dirname "$0")" && pwd -P)"
readonly prime_root="$(cd "$script_directory/../.." && pwd -P)"
readonly expected_prime_head="${GITHUB_SHA:?GITHUB_SHA is required}"
readonly checkout_token="${ERGENTICS_MLX_READ_TOKEN:-}"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly authority_source="$prime_root/Sources/PrimeLatinLLMAuthority"

die() {
    echo "prime-ci-latin-authority-foundation: $*" >&2
    exit 1
}

for command_name in git grep swift; do
    command -v "$command_name" >/dev/null 2>&1 ||
        die "missing command: $command_name"
done

[[ -n "$checkout_token" ]] ||
    die "ERGENTICS_MLX_READ_TOKEN is required"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout does not match GITHUB_SHA"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout is dirty"
[[ -d "$authority_source" && ! -L "$authority_source" ]] ||
    die "Prime Latin authority source target is missing or unsafe"

if grep -R -n -E \
    '^[[:space:]]*import[[:space:]]+(PrimeCore|MLX|MLXNN|MLXLLM|MLXOptimizers)([[:space:]]|$)' \
    "$authority_source"; then
    die "Prime Latin authority target imports a prohibited dependency"
fi

export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.https://x-access-token:${checkout_token}@github.com/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/"
export CLANG_MODULE_CACHE_PATH="$runner_temp/prime-latin-authority-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"

swift test \
    --package-path "$prime_root" \
    --scratch-path "$runner_temp/prime-latin-authority-build" \
    --cache-path "$runner_temp/prime-latin-authority-cache" \
    --config-path "$runner_temp/prime-latin-authority-config" \
    --security-path "$runner_temp/prime-latin-authority-security" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --force-resolved-versions \
    --filter PrimeLatinLLMAuthorityTests

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset CLANG_MODULE_CACHE_PATH SWIFTPM_MODULECACHE_OVERRIDE

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during the Latin authority gate"

echo "OK: Prime Latin authority foundation is structural and non-authorizing"

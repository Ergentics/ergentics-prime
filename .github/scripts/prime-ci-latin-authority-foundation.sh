#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly script_directory="$(cd "$(dirname "$0")" && pwd -P)"
readonly prime_root="$(cd "$script_directory/../.." && pwd -P)"
readonly expected_prime_head="${GITHUB_SHA:?GITHUB_SHA is required}"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly authority_source="$prime_root/Sources/PrimeLatinLLMAuthority"
readonly authority_tests="$prime_root/Tests/PrimeLatinLLMAuthorityTests"
readonly package_template="$script_directory/prime-latin-authority-foundation.Package.swift"
readonly staged_package="$runner_temp/prime-latin-authority-package"

die() {
    echo "prime-ci-latin-authority-foundation: $*" >&2
    exit 1
}

for command_name in cmp cp git grep mkdir swift; do
    command -v "$command_name" >/dev/null 2>&1 ||
        die "missing command: $command_name"
done

[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" && -z "${ERGENTICS_PAT:-}" ]] ||
    die "Latin authority gate must not receive a private-read credential"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout does not match GITHUB_SHA"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout is dirty"
[[ -d "$authority_source" && ! -L "$authority_source" ]] ||
    die "Prime Latin authority source target is missing or unsafe"
[[ -d "$authority_tests" && ! -L "$authority_tests" ]] ||
    die "Prime Latin authority test target is missing or unsafe"
[[ -f "$package_template" && ! -L "$package_template" ]] ||
    die "Prime Latin authority package template is missing or unsafe"

if grep -R -n -E \
    '^[[:space:]]*import[[:space:]]+(PrimeCore|MLX|MLXNN|MLXLLM|MLXOptimizers)([[:space:]]|$)' \
    "$authority_source"; then
    die "Prime Latin authority target imports a prohibited dependency"
fi

[[ ! -e "$staged_package" && ! -L "$staged_package" ]] ||
    die "staged package path already exists"
mkdir -p \
    "$staged_package/Sources/PrimeLatinLLMAuthority" \
    "$staged_package/Tests/PrimeLatinLLMAuthorityTests"
cp "$package_template" "$staged_package/Package.swift"
cp \
    "$authority_source/PrimeLatinLLMAuthority.swift" \
    "$staged_package/Sources/PrimeLatinLLMAuthority/PrimeLatinLLMAuthority.swift"
cp \
    "$authority_tests/PrimeLatinLLMAuthorityTests.swift" \
    "$staged_package/Tests/PrimeLatinLLMAuthorityTests/PrimeLatinLLMAuthorityTests.swift"
cmp -s \
    "$package_template" \
    "$staged_package/Package.swift" || die "staged manifest changed"
cmp -s \
    "$authority_source/PrimeLatinLLMAuthority.swift" \
    "$staged_package/Sources/PrimeLatinLLMAuthority/PrimeLatinLLMAuthority.swift" ||
    die "staged source changed"
cmp -s \
    "$authority_tests/PrimeLatinLLMAuthorityTests.swift" \
    "$staged_package/Tests/PrimeLatinLLMAuthorityTests/PrimeLatinLLMAuthorityTests.swift" ||
    die "staged tests changed"

export CLANG_MODULE_CACHE_PATH="$runner_temp/prime-latin-authority-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"
export PRIME_REPOSITORY_ROOT="$prime_root"

swift test \
    --package-path "$staged_package" \
    --scratch-path "$runner_temp/prime-latin-authority-build" \
    --cache-path "$runner_temp/prime-latin-authority-cache" \
    --config-path "$runner_temp/prime-latin-authority-config" \
    --security-path "$runner_temp/prime-latin-authority-security" \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --filter PrimeLatinLLMAuthorityTests

unset CLANG_MODULE_CACHE_PATH SWIFTPM_MODULECACHE_OVERRIDE PRIME_REPOSITORY_ROOT

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during the Latin authority gate"

echo "OK: Prime Latin authority foundation is structural and non-authorizing"

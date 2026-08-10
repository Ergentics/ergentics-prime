#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly prime_root="$(cd -- "$script_directory/../.." && pwd -P)"
readonly expected_prime_head="${ERGENTICS_EXACT_REVISION:?ERGENTICS_EXACT_REVISION is required}"
readonly expected_mlx_origin="https://github.com/Ergentics/ergentics-mlx-swift"
readonly root_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly typed_mlx_revision="68904d54b72871f26968261ae05d4fbb7c5e3142"
readonly numerics_origin="https://github.com/apple/swift-numerics"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly numerics_version="1.1.1"
readonly workflow_path="$prime_root/.github/workflows/prime-active-root-quarantine.yml"
readonly decoder_metal_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-metal.sh"

die() {
    echo "prime-ci-active-root-quarantine: $*" >&2
    exit 1
}

for command_name in awk bash git grep jq mktemp paste shasum sort swift swiftc wc; do
    command -v "$command_name" >/dev/null 2>&1 ||
        die "missing command: $command_name"
done

[[ "$expected_prime_head" =~ ^[0-9a-f]{40}$ ]] ||
    die "exact revision must be a lowercase 40-character object ID"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout does not match ERGENTICS_EXACT_REVISION"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout is dirty"

require_preserved_object() {
    local preserved_relative_path="$1"
    local expected_object_id="$2"
    local observed_object_id
    observed_object_id="$(git -C "$prime_root" rev-parse "HEAD:$preserved_relative_path")" ||
        die "preserved path is missing: $preserved_relative_path"
    [[ "$observed_object_id" == "$expected_object_id" ]] ||
        die "preserved historical object changed: $preserved_relative_path"
}

require_preserved_object \
    "artifacts/exact-3b-fp32-canary-865073a-20260729T183120Z" \
    "71092e17f1c5e0548b5661d83124b1fac38776df"
require_preserved_object \
    "artifacts/exact-3b-fp32-canary-d52ea93-20260729T172009Z" \
    "603f40d7ae80969ae4050dcf0fa86c311cf50dce"
require_preserved_object \
    "artifacts/native-3b-metal-continuation-4507fe629a4f-20260730T040459Z" \
    "f4c36cbd10c45c397c48a9b7efe4e327a050ff43"
require_preserved_object \
    "artifacts/native-3b-metal-continuation-7c3989bd0e44-20260730T045558Z" \
    "3f0ad851d6c1c4a5616671dd7519dae692279fa8"
require_preserved_object \
    "artifacts/native-contract-resolution-canonical-2026-07-29" \
    "35663beaf47ce9f011642d8d429c8b797accaa40"
require_preserved_object \
    "artifacts/native-full-corpus-replay-canonical-2026-07-30" \
    "7e49defb4dd6b3ff0ff38f3e0ab215275e47f487"
require_preserved_object \
    "artifacts/native-generation-contract-projection-canonical-2026-07-30" \
    "12a2f6fb1a4f4156a2f151a110219863a847e215"
require_preserved_object \
    "artifacts/native-neural-gate-contract-projection-canonical-2026-07-30" \
    "50302bd7e801a00641419ee32327914a08c9bcd7"
require_preserved_object \
    "artifacts/native-resolved-contract-adapter-canonical-2026-07-30" \
    "8902a68ded0bd716e195f20b55a994514790005f"
require_preserved_object \
    "artifacts/optimizer-restore-gate-865073a-20260729T183341Z" \
    "6e35e4e8a3b3e1948573d635680835b88b43a830"
require_preserved_object \
    "artifacts/typed-optimizer-restore-6465beb-20260729T184600Z" \
    "07b36d0f83efc6538f95edba94522c43b8c8c60d"
require_preserved_object \
    "Sources/PrimeGPUCalibration" \
    "9dd5592b4e07f9cdce16919b28bf255e80ce75b8"
require_preserved_object \
    "Sources/PrimeNative3BMetalContinuationProbe" \
    "4ce807243a31836abf2ef83b7e6c2c8d3958658f"
require_preserved_object \
    "Sources/ErgenticsPrimeRuntime" \
    "78ac5094f30c0ac228f3a1909b3324d2d520314e"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeArcContinuity.swift" \
    "ef16d19f5d11e1a318dec711f0f6d86fb5487783"
require_preserved_object \
    "Sources/PrimeCore/PrimeNative3BProfile.swift" \
    "31e45acecd94186f6982d264aea68dcca8837a50"
require_preserved_object \
    "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift" \
    "67a2c221a1e08a9cdbecab38d937022e9fff7909"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift" \
    "b4cc33cd079a1817dd233317772eaee59645ba2b"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderDerivedDelta.swift" \
    "84b8c0ce3f6753d21800d0ce60b430ee2bd7db3f"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift" \
    "2621721ef52cfb0aa823f096df9be83c37971aab"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift" \
    "f284cb6d9bfdd37add9273f3e0eecd69e13cd134"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservation.swift" \
    "39e37fc4dd7e2b6131ce0efc790b49602a94f484"
require_preserved_object \
    "Sources/PrimeCore/PrimeMLXRuntimeEnvironmentPolicy.swift" \
    "302718448a233695f57eb9bf508a56f0790a778b"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-metal.sh" \
    "418d2d2753cee38e0b3558ad45e1e09865ffd11d"
require_preserved_object \
    "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift" \
    "14833cbae5a819d875663740bca8fb8ff175df0c"
require_preserved_object \
    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved" \
    "18aef69512c82c3e6cdff192f3aa0a6ee13c702e"

readonly root_manifest="$prime_root/Package.swift"
for forbidden_active_root in \
    "mlx-swift-lm" \
    "MLXLLM" \
    'name: "PrimeGPUCalibration"' \
    'name: "PrimeNative3BMetalContinuationProbe"' \
    "pmhnp-companion-ergentics"; do
    if grep -Fq -- "$forbidden_active_root" "$root_manifest"; then
        die "active root manifest retains quarantined dependency: $forbidden_active_root"
    fi
done

[[ "$(grep -Fc -- "$expected_mlx_origin" "$root_manifest")" == "1" ]] ||
    die "active root must declare the first-party MLX origin exactly once"
[[ "$(grep -Fc -- "$root_mlx_revision" "$root_manifest")" == "1" ]] ||
    die "active root must declare the pinned MLX revision exactly once"
[[ "$(grep -Fc -- '.package(' "$root_manifest")" == "1" ]] ||
    die "active root gained an unexpected direct package dependency"

readonly -a mirror_paths=(
    ".swiftpm/configuration/mirrors.json"
    "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json"
    "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json"
    "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json"
)
for mirror_relative_path in "${mirror_paths[@]}"; do
    jq -e \
        '.version == 1 and .object == [] and (keys | sort) == ["object", "version"]' \
        "$prime_root/$mirror_relative_path" >/dev/null ||
        die "active mirror configuration is not empty: $mirror_relative_path"
done

assert_active_lock() {
    local lock_relative_path="$1"
    local manifest_relative_path="$2"
    local expected_revision="$3"
    local expected_origin_hash
    expected_origin_hash="$(
        shasum -a 256 "$prime_root/$manifest_relative_path" |
            awk '{print $1}'
    )"

    jq -e \
        --arg expected_origin "$expected_mlx_origin" \
        --arg expected_revision "$expected_revision" \
        --arg expected_origin_hash "$expected_origin_hash" \
        --arg numerics_origin "$numerics_origin" \
        --arg numerics_revision "$numerics_revision" \
        --arg numerics_version "$numerics_version" \
        '
          ((keys | sort) == ["originHash", "pins", "version"])
          and .version == 3
          and .originHash == $expected_origin_hash
          and (.pins | length) == 2
          and ([.pins[] | .identity] == ["ergentics-mlx-swift", "swift-numerics"])
          and ((.pins[0] | keys | sort) == ["identity", "kind", "location", "state"])
          and .pins[0].identity == "ergentics-mlx-swift"
          and .pins[0].kind == "remoteSourceControl"
          and .pins[0].location == $expected_origin
          and ((.pins[0].state | keys | sort) == ["revision"])
          and .pins[0].state.revision == $expected_revision
          and ((.pins[1] | keys | sort) == ["identity", "kind", "location", "state"])
          and .pins[1].identity == "swift-numerics"
          and .pins[1].kind == "remoteSourceControl"
          and .pins[1].location == $numerics_origin
          and ((.pins[1].state | keys | sort) == ["revision", "version"])
          and .pins[1].state.revision == $numerics_revision
          and .pins[1].state.version == $numerics_version
        ' \
        "$prime_root/$lock_relative_path" >/dev/null ||
        die "active lock violates the first-party boundary: $lock_relative_path"
}

assert_active_lock \
    "Package.resolved" \
    "Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeNeuralGateMLXValidation/Package.resolved" \
    "Tests/PrimeNativeNeuralGateMLXValidation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeDecoderValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderValidation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/Package.resolved" \
    "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/Package.swift" \
    "$typed_mlx_revision"
assert_active_lock \
    "Tests/PrimeValidationWorkflow/Package.resolved" \
    "Tests/PrimeValidationWorkflow/Package.swift" \
    "$root_mlx_revision"

for forbidden_workflow_value in \
    "--disable-sandbox" \
    "self-hosted" \
    "xlarge" \
    "pmhnp-companion-ergentics" \
    "PRIME_PMHNP_COMPANION_ROOT"; do
    if grep -Fq -- "$forbidden_workflow_value" "$workflow_path"; then
        die "hosted quarantine workflow contains forbidden value: $forbidden_workflow_value"
    fi
done
grep -Fq -- 'github.event.pull_request.head.sha || github.sha' "$workflow_path" ||
    die "workflow is not bound to the exact pull-request head"
grep -Fq -- 'runs-on: macos-15' "$workflow_path" ||
    die "workflow is not on the standard hosted macOS runner"
[[ -f "$decoder_metal_gate_path" && ! -L "$decoder_metal_gate_path" ]] ||
    die "Prime native decoder Metal gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- '.github/scripts/prime-ci-native-decoder-metal.sh')" \
    == '.github/scripts/prime-ci-native-decoder-metal.sh' ]] ||
    die "Prime native decoder Metal gate is not tracked exactly"
bash -n "$decoder_metal_gate_path" ||
    die "Prime native decoder Metal gate is not valid Bash"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-metal.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder Metal gate mode changed"
[[ "$(wc -c < "$decoder_metal_gate_path" | awk '{print $1}')" == "11793" ]] ||
    die "Prime native decoder Metal gate byte count changed"
[[ "$(shasum -a 256 "$decoder_metal_gate_path" | awk '{print $1}')" \
    == "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff" ]] ||
    die "Prime native decoder Metal gate SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_metal_gate_path")" \
    == "418d2d2753cee38e0b3558ad45e1e09865ffd11d" ]] ||
    die "Prime native decoder Metal gate blob changed"
grep -Fq -- 'run: bash .github/scripts/prime-ci-native-decoder-metal.sh' "$workflow_path" ||
    die "trusted-main workflow does not invoke the Prime native decoder Metal gate"
for required_metal_gate_value in \
    'MTLCreateSystemDefaultDevice' \
    '-target Cmlx' \
    'default.metallib' \
    'ergentics_prime_native_decoder_ci_mlx_compute_environment' \
    'export MLX_ENABLE_TF32=0' \
    'Executed 44 tests, with 0 failures' \
    'live Metal gate cannot contain skipped tests'; do
    grep -Fq -- "$required_metal_gate_value" "$decoder_metal_gate_path" ||
        die "Prime native decoder Metal gate is missing: $required_metal_gate_value"
done
! grep -Fq -- 'MLX_ENABLE_TF32' "$workflow_path" ||
    die "workflow must not inject the decoder TF32 mechanics policy"
grep -Fxq -- \
    '      PRIME_MLX_REVISION: d37885a278f1c37484a94d0f401a418735e66519' \
    "$workflow_path" ||
    die "workflow does not expose the non-MLX-prefixed revision binding"
for forbidden_metal_gate_value in \
    '--disable-sandbox' \
    '--filter' \
    'self-hosted' \
    'xlarge' \
    'PrimeValidationWorkflow' \
    'DriverV2' \
    'pmhnp-companion-ergentics' \
    'MLXLLM'; do
    if grep -Fq -- "$forbidden_metal_gate_value" "$decoder_metal_gate_path"; then
        die "Prime native decoder Metal gate contains quarantined value: $forbidden_metal_gate_value"
    fi
done

readonly runner_temp="${RUNNER_TEMP:-/private/tmp}"
readonly manifest_dump="$(mktemp "$runner_temp/prime-package-dump.json.XXXXXX")"
readonly decoder_manifest_dump="$(mktemp "$runner_temp/prime-decoder-package-dump.json.XXXXXX")"
readonly manifest_scratch="$runner_temp/prime-package-dump-build"
readonly manifest_cache="$runner_temp/prime-package-dump-cache"
readonly manifest_config="$runner_temp/prime-package-dump-config"
readonly manifest_security="$runner_temp/prime-package-dump-security"
trap 'unlink "$manifest_dump" "$decoder_manifest_dump" 2>/dev/null || true' EXIT
mkdir -p \
    "$manifest_scratch" \
    "$manifest_cache" \
    "$manifest_config" \
    "$manifest_security"
TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    '
      .name == "ErgenticsPrime"
      and (.dependencies | length) == 1
      and ([.dependencies[] | tostring | select(contains($expected_origin))] | length) == 1
      and ([.products[].name | select(
          . == "PrimeGPUCalibration"
          or . == "PrimeNative3BMetalContinuationProbe"
      )] | length) == 0
      and ([.products[] | select(
          .name == "PrimeNativeDecoder"
          and .targets == ["PrimeNativeDecoder"]
          and .type.library == ["automatic"]
      )] | length) == 1
      and ([.products[] | select(
          .name == "PrimeNativeDecoderCheckpoint"
          and .targets == ["PrimeNativeDecoderCheckpoint"]
          and .type.library == ["automatic"]
      )] | length) == 1
      and ([.targets[] | select(
          .name == "PrimeNativeDecoder"
          and .type == "regular"
          and ([.dependencies[] | (.byName[0] // .product[0])]
              == ["PrimeCore", "MLX", "MLXNN"])
      )] | length) == 1
      and ([.targets[] | select(
          .name == "PrimeNativeDecoderCheckpoint"
          and .type == "regular"
          and ([.dependencies[] | (.byName[0] // .product[0])]
              == ["PrimeCore", "PrimeNativeDecoder", "MLX", "MLXNN"])
      )] | length) == 1
    ' \
    "$manifest_dump" >/dev/null ||
    die "evaluated package graph violates the active quarantine"

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$root_mlx_revision" \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderValidation"
      and (.dependencies | length) == 2
      and ([.dependencies[] | select(
          .fileSystem[0].nameForTargetDependencyResolutionOnly
              == "ergentics-prime"
          and .fileSystem[0].path == $prime_root
      )] | length) == 1
      and ([.dependencies[] | tostring | select(
          contains($expected_origin)
          and contains($expected_revision)
      )] | length) == 1
      and (.targets | length) == 1
      and .targets[0].name == "PrimeNativeDecoderTests"
      and .targets[0].type == "test"
      and ([.targets[0].dependencies[].product[0]] == [
          "PrimeCore",
          "PrimeNativeDecoder",
          "PrimeNativeDecoderCheckpoint",
          "MLX",
          "MLXNN"
      ])
      and ([.targets[0].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-prime",
          "ergentics-prime",
          "ergentics-mlx-swift",
          "ergentics-mlx-swift"
      ])
      and ([.targets[0].settings[].kind.linkedFramework._0] == [
          "CoreGraphics",
          "Metal"
      ])
    ' \
    "$decoder_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder validation manifest changed"

readonly decoder_source="$prime_root/Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
readonly decoder_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderAuthority.swift"
readonly decoder_derived_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderDerivedDelta.swift"
readonly decoder_checkpoint_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift"
readonly decoder_checkpoint_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift"
readonly decoder_metal_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift"
readonly decoder_metal_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservation.swift"
readonly decoder_validation_manifest="$prime_root/Tests/PrimeNativeDecoderValidation/Package.swift"
readonly decoder_authority_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift"
readonly decoder_validation_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift"
readonly decoder_checkpoint_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift"

[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoder')" \
    == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift" ]] ||
    die "PrimeNativeDecoder production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderCheckpoint')" \
    == "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift" ]] ||
    die "PrimeNativeDecoderCheckpoint production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Tests/PrimeNativeDecoderValidation')" \
    == $'Tests/PrimeNativeDecoderValidation/Package.resolved\nTests/PrimeNativeDecoderValidation/Package.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift' ]] ||
    die "PrimeNativeDecoder validation inventory changed"
[[ ! -e "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" \
    && ! -L "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" ]] ||
    die "PrimeNativeDecoder validation must use the supplied isolated config path"
[[ -f "$decoder_source" && ! -L "$decoder_source" ]] ||
    die "PrimeNativeDecoder source is missing or linked"
[[ -f "$decoder_validation_test" && ! -L "$decoder_validation_test" ]] ||
    die "PrimeNativeDecoder test source is missing or linked"
[[ -f "$decoder_checkpoint_test" && ! -L "$decoder_checkpoint_test" ]] ||
    die "PrimeNativeDecoderCheckpoint test source is missing or linked"
[[ -f "$decoder_authority_test" && ! -L "$decoder_authority_test" ]] ||
    die "PrimeNativeDecoder authority test source is missing or linked"
[[ -f "$decoder_authority_source" && ! -L "$decoder_authority_source" ]] ||
    die "frozen PrimeNativeDecoder authority is missing or linked"
[[ -f "$decoder_checkpoint_source" && ! -L "$decoder_checkpoint_source" ]] ||
    die "PrimeNativeDecoderCheckpoint source is missing or linked"
[[ -f "$decoder_checkpoint_authority_source" \
    && ! -L "$decoder_checkpoint_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint authority is missing or linked"
[[ -f "$decoder_metal_repair_authority_source" \
    && ! -L "$decoder_metal_repair_authority_source" ]] ||
    die "PrimeNativeDecoder Metal-repair authority is missing or linked"
[[ -f "$decoder_metal_execution_observation_source" \
    && ! -L "$decoder_metal_execution_observation_source" ]] ||
    die "PrimeNativeDecoder Metal execution observation is missing or linked"
[[ "$(wc -c < "$decoder_checkpoint_authority_source" | awk '{print $1}')" \
    == "14399" ]] ||
    die "PrimeNativeDecoderCheckpoint authority byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_authority_source" | awk '{print $1}')" \
    == "60d593b8b0346570400f98212b173cef9f4495f24af34517097c20309eb765ac" ]] ||
    die "PrimeNativeDecoderCheckpoint authority SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_authority_source")" \
    == "2621721ef52cfb0aa823f096df9be83c37971aab" ]] ||
    die "PrimeNativeDecoderCheckpoint authority blob changed"
[[ "$(wc -c < "$decoder_authority_source" | awk '{print $1}')" == "18462" ]] ||
    die "frozen PrimeNativeDecoder authority byte count changed"
[[ "$(shasum -a 256 "$decoder_authority_source" | awk '{print $1}')" \
    == "afe0fe9b18cd835299fc2185508b383b33c36a0be27372ff41beb555e1776eaa" ]] ||
    die "frozen PrimeNativeDecoder authority SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_authority_source")" \
    == "b4cc33cd079a1817dd233317772eaee59645ba2b" ]] ||
    die "frozen PrimeNativeDecoder authority blob changed"
for historical_decoder_binding in \
    '55407cba9dbcc4e915b0994aed16f02c1da95e16' \
    '7e3e9c676225e7d600c5580cb3ae73a3d15fdeff12d0933e175b41923c370162'; do
    grep -Fq -- "$historical_decoder_binding" \
        "$decoder_derived_authority_source" \
        "$decoder_checkpoint_authority_source" ||
        die "historical decoder source binding is not preserved"
done
[[ "$(wc -c < "$decoder_metal_repair_authority_source" | awk '{print $1}')" \
    == "26865" ]] ||
    die "PrimeNativeDecoder Metal-repair authority byte count changed"
[[ "$(shasum -a 256 "$decoder_metal_repair_authority_source" | awk '{print $1}')" \
    == "5e88a1a191f94daac01f86e5dbad48ebfcdd50957ac17acf6f404ac8dd0a97ac" ]] ||
    die "PrimeNativeDecoder Metal-repair authority SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_metal_repair_authority_source")" \
    == "f284cb6d9bfdd37add9273f3e0eecd69e13cd134" ]] ||
    die "PrimeNativeDecoder Metal-repair authority blob changed"
[[ "$(wc -c < "$decoder_metal_execution_observation_source" | awk '{print $1}')" \
    == "17488" ]] ||
    die "PrimeNativeDecoder Metal execution observation byte count changed"
[[ "$(shasum -a 256 "$decoder_metal_execution_observation_source" | awk '{print $1}')" \
    == "d132edeb434423e1f2c391258e7f0a502f872c53097b3a9a7db7780007a91306" ]] ||
    die "PrimeNativeDecoder Metal execution observation SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_metal_execution_observation_source")" \
    == "39e37fc4dd7e2b6131ce0efc790b49602a94f484" ]] ||
    die "PrimeNativeDecoder Metal execution observation blob changed"
[[ "$(wc -c < "$decoder_source" | awk '{print $1}')" == "39050" ]] ||
    die "PrimeNativeDecoder repaired source byte count changed"
[[ "$(shasum -a 256 "$decoder_source" | awk '{print $1}')" \
    == "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b" ]] ||
    die "PrimeNativeDecoder repaired source SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_source")" \
    == "835a4826549e1f28ec27e3533f746218beb3bdf2" ]] ||
    die "PrimeNativeDecoder repaired source blob changed"
[[ "$(wc -c < "$decoder_validation_test" | awk '{print $1}')" == "40513" ]] ||
    die "PrimeNativeDecoder repaired regression byte count changed"
[[ "$(shasum -a 256 "$decoder_validation_test" | awk '{print $1}')" \
    == "ee612ac7b02e759fdb556d1f29d4f1327da3d9bb39f6e20090a8d862b2a5c53f" ]] ||
    die "PrimeNativeDecoder repaired regression SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_validation_test")" \
    == "0162a60c422de7d05abbdd6932420930adcd5813" ]] ||
    die "PrimeNativeDecoder repaired regression blob changed"
[[ "$(wc -c < "$decoder_authority_test" | awk '{print $1}')" == "34555" ]] ||
    die "PrimeNativeDecoder repair-authority test byte count changed"
[[ "$(shasum -a 256 "$decoder_authority_test" | awk '{print $1}')" \
    == "28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe" ]] ||
    die "PrimeNativeDecoder repair-authority test SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_authority_test")" \
    == "25b7c9b99e789988fb7362b73a41d35eafba406d" ]] ||
    die "PrimeNativeDecoder repair-authority test blob changed"
[[ "$(wc -c < "$decoder_checkpoint_test" | awk '{print $1}')" == "33037" ]] ||
    die "PrimeNativeDecoder checkpoint execution test byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_test" | awk '{print $1}')" \
    == "97944a997a389e6ea79ba92f9be965bc66230064e171c51c9150f6b1080b9172" ]] ||
    die "PrimeNativeDecoder checkpoint execution test SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_test")" \
    == "375a9278d6fe82b7033c731a8e4f7d51c5cc96b5" ]] ||
    die "PrimeNativeDecoder checkpoint execution test blob changed"
[[ "$(wc -c < "$decoder_checkpoint_source" | awk '{print $1}')" == "39956" ]] ||
    die "PrimeNativeDecoderCheckpoint source byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_source" | awk '{print $1}')" \
    == "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b" ]] ||
    die "PrimeNativeDecoderCheckpoint source SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_source")" \
    == "24de078fb6424123b8e6974588b4cc514219c026" ]] ||
    die "PrimeNativeDecoderCheckpoint source blob changed"
swiftc -frontend -parse "$decoder_source"
swiftc -frontend -parse "$decoder_checkpoint_source"
swiftc -frontend -parse "$decoder_checkpoint_authority_source"
swiftc -frontend -parse "$decoder_metal_repair_authority_source"
swiftc -frontend -parse "$decoder_metal_execution_observation_source"
swiftc -frontend -parse "$decoder_authority_test"
swiftc -frontend -parse "$decoder_checkpoint_test"
swiftc -frontend -parse "$decoder_validation_test"

readonly observed_mlxllm_references="$({
    git -C "$prime_root" grep -l -F 'MLXLLM' -- Sources || true
} | LC_ALL=C sort)"
readonly expected_mlxllm_references=$'Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift\nSources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift\nSources/PrimeCore/PrimeNative3BMetalContinuation.swift\nSources/PrimeCore/PrimeNativeArcContinuity.swift\nSources/PrimeCore/PrimeNativeDecoderAuthority.swift\nSources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift\nSources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift\nSources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift'
[[ "$observed_mlxllm_references" == "$expected_mlxllm_references" ]] ||
    die "frozen MLXLLM source-reference allowlist changed"

readonly observed_mlxllm_imports="$({
    git -C "$prime_root" grep -l -E \
        '^[[:space:]]*import[[:space:]]+MLXLLM([[:space:]]|$)' \
        -- Sources || true
} | LC_ALL=C sort)"
readonly expected_mlxllm_imports=$'Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift\nSources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift'
[[ "$observed_mlxllm_imports" == "$expected_mlxllm_imports" ]] ||
    die "active MLXLLM import quarantine changed"

[[ "$(awk '/^import / {print $2}' "$decoder_source" | paste -sd, -)" \
    == "PrimeCore,MLX,MLXNN" ]] ||
    die "PrimeNativeDecoder production imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_checkpoint_source" | paste -sd, -)" \
    == "Darwin,Foundation,PrimeCore,PrimeNativeDecoder,MLX,MLXNN" ]] ||
    die "PrimeNativeDecoderCheckpoint production imports changed"
[[ "$(grep -Fc -- '.package(' "$decoder_validation_manifest")" == "2" ]] ||
    die "PrimeNativeDecoder validation gained an unexpected dependency"
grep -Fq -- 'name: "PrimeNativeDecoder"' "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not consume the Prime product"
grep -Fq -- 'name: "PrimeNativeDecoderCheckpoint"' \
    "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not consume the checkpoint product"
grep -Fq -- "$root_mlx_revision" "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not pin the active MLX revision"

for forbidden_decoder_value in \
    "MLXLLM" \
    "MLXLMCommon" \
    "LlamaModel" \
    "LlamaConfiguration" \
    "Python" \
    "python" \
    "PythonKit" \
    "PrimeNativeProfiles.exact3B" \
    "PrimeNative3BMetalContinuation" \
    "ErgenticsNativeScaleEngineRecommend" \
    "huggingface.co" \
    "loadModelContainer" \
    "snapshot_download" \
    "/usr/bin/python" \
    "/bin/python" \
    "/bin/sh" \
    "/bin/zsh" \
    "/bin/bash" \
    "posix_spawn" \
    "execve(" \
    "Process" \
    "HuggingFace" \
    "PMHNP" \
    "MLXOptimizers" \
    "ErgenticsLLM" \
    "NativeTinyDecoder" \
    "URLSession"; do
    if grep -Fq -- "$forbidden_decoder_value" \
        "$decoder_source" \
        "$decoder_checkpoint_source" \
        "$decoder_authority_test" \
        "$decoder_checkpoint_test" \
        "$decoder_validation_test"; then
        die "PrimeNativeDecoder closure contains forbidden value: $forbidden_decoder_value"
    fi
done

for forbidden_checkpoint_capability in \
    "FileManager" \
    "FileHandle" \
    "Data(contentsOf:" \
    "write(to:" \
    "PrimeArtifactRoot" \
    "URL(fileURLWithPath:" \
    "DispatchIO" \
    "NSFileCoordinator" \
    "open(" \
    "creat(" \
    "fopen(" \
    "close(" \
    "unlink(" \
    "rename(" \
    "fsync(" \
    "writeNative300MByte512" \
    "loadNative300MByte512"; do
    if grep -Fq -- "$forbidden_checkpoint_capability" \
        "$decoder_checkpoint_source"; then
        die "PrimeNativeDecoderCheckpoint owns forbidden capability: $forbidden_checkpoint_capability"
    fi
done

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during metadata validation"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during metadata validation"

echo "OK: first-party MLX is pinned; mlx-swift-lm execution targets are disconnected while historical comparator evidence remains preserved"

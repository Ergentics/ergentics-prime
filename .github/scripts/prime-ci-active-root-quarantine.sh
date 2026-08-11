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
readonly decoder_runtime_closure_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-runtime-closure.sh"

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
    "Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservationCorrection.swift" \
    "b9b0947cd814efc09d6412409d286b6be6db192f"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderGateRepairExecutionObservation.swift" \
    "3b242cd57b4f922ada466d8ae39b58424ff878c2"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderReviewedMainMetalExecutionObservation.swift" \
    "f5025b136b761b2db680cdc656542c6d5caa309e"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift" \
    "b09e51e6cd79b3962fec4ddb28c1a154ef979076"
require_preserved_object \
    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift" \
    "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.swift" \
    "f2694f6b9c85b997a4ce7dedca48e456cf65d7c1"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.resolved" \
    "3083ed5145d3f8eae3858a61b103ebf31071feef"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Tests/PrimeNativeDecoderCompatibilityIdentityV2Tests.swift" \
    "2dd3a7f4a381129580897e529f935275a7e38cf8"
require_preserved_object \
    "Sources/PrimeCore/PrimeMLXRuntimeEnvironmentPolicy.swift" \
    "302718448a233695f57eb9bf508a56f0790a778b"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-metal.sh" \
    "418d2d2753cee38e0b3558ad45e1e09865ffd11d"
require_preserved_object \
    "Package.swift" \
    "f201abbf928e5e3d6b0c7785110539cdaeee911b"
require_preserved_object \
    "Package.resolved" \
    "dcd0192f705c22378f2d9e871a240c0493ad8a80"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift" \
    "379c3e40ab24ae696c01da0b3f2116d0093cedb2"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeExecutionObservation.swift" \
    "49e107f9fdd2ec5deb262d1885f015c6640eb33c"
require_preserved_object \
    "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift" \
    "dd3ca76ba7799c6deb0012276967c07bee3644d0"
require_preserved_object \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift" \
    "ed63a3edf5def776cdb531166090a69afdf0e425"
require_preserved_object \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved" \
    "9128fe027a155fe6ea3c56667cf57989bc05128d"
require_preserved_object \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift" \
    "63679a06c900b803b23778b011980636a3b302f1"
require_preserved_object \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift" \
    "f159267dfa77a643337ba9cd7f60d733d4d84033"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-runtime-closure.sh" \
    "f1c3041d7e47fa315f60c889a736a412640e8710"
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
    "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.resolved" \
    "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift" \
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
[[ -f "$decoder_runtime_closure_gate_path" \
    && ! -L "$decoder_runtime_closure_gate_path" ]] ||
    die "Prime native decoder runtime-closure gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- \
    '.github/scripts/prime-ci-native-decoder-runtime-closure.sh')" \
    == '.github/scripts/prime-ci-native-decoder-runtime-closure.sh' ]] ||
    die "Prime native decoder runtime-closure gate is not tracked exactly"
bash -n "$decoder_runtime_closure_gate_path" ||
    die "Prime native decoder runtime-closure gate is not valid Bash"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-runtime-closure.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder runtime-closure gate mode changed"
grep -Fq -- '      - name: Run the Prime-owned decoder on live Metal' \
    "$workflow_path" ||
    die "trusted-main workflow lost the frozen decoder Metal step"
readonly frozen_metal_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-metal.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
readonly runtime_closure_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
[[ "$frozen_metal_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" \
        -eq $((frozen_metal_workflow_line + 1)) ]] ||
    die "trusted-main workflow does not run the runtime closure immediately after the frozen Metal gate"
grep -Fq -- \
    '--package-path Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation' \
    "$workflow_path" ||
    die "trusted-main workflow does not run checkpoint V2 validation"
grep -Fq -- 'Executed 1 test, with 0 failures' "$workflow_path" ||
    die "trusted-main workflow does not bind checkpoint V2 validation count"
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

for required_runtime_closure_gate_value in \
    'prime-native-decoder-metal-tests.log' \
    'prime-native-decoder-metallib' \
    '--configuration release' \
    '--build-tests' \
    'xcrun xctest' \
    'Executed 1 test, with 0 failures' \
    'MLX_ENABLE_TF32=0' \
    'CoreGraphics' \
    'Metal' \
    'private_cwd' \
    'PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT='; do
    grep -Fq -- "$required_runtime_closure_gate_value" \
        "$decoder_runtime_closure_gate_path" ||
        die "Prime native decoder runtime-closure gate is missing: $required_runtime_closure_gate_value"
done
for forbidden_runtime_closure_gate_value in \
    '--disable-sandbox' \
    'xcodebuild' \
    'git fetch' \
    'git clone' \
    'submodule update' \
    'MLXLLM' \
    'PMHNP' \
    'DriverV2' \
    'Geometry' \
    'RenderKit' \
    'PrimeNativeGQADecoder.make' \
    '.forward('; do
    if grep -Fq -- "$forbidden_runtime_closure_gate_value" \
        "$decoder_runtime_closure_gate_path"; then
        die "Prime native decoder runtime-closure gate contains forbidden value: $forbidden_runtime_closure_gate_value"
    fi
done

readonly runner_temp="${RUNNER_TEMP:-/private/tmp}"
readonly manifest_dump="$(mktemp "$runner_temp/prime-package-dump.json.XXXXXX")"
readonly decoder_manifest_dump="$(mktemp "$runner_temp/prime-decoder-package-dump.json.XXXXXX")"
readonly decoder_checkpoint_v2_manifest_dump="$(mktemp "$runner_temp/prime-decoder-checkpoint-v2-package-dump.json.XXXXXX")"
readonly decoder_runtime_closure_manifest_dump="$(mktemp "$runner_temp/prime-decoder-runtime-closure-package-dump.json.XXXXXX")"
readonly manifest_scratch="$runner_temp/prime-package-dump-build"
readonly manifest_cache="$runner_temp/prime-package-dump-cache"
readonly manifest_config="$runner_temp/prime-package-dump-config"
readonly manifest_security="$runner_temp/prime-package-dump-security"
trap 'unlink "$manifest_dump" "$decoder_manifest_dump" "$decoder_checkpoint_v2_manifest_dump" "$decoder_runtime_closure_manifest_dump" 2>/dev/null || true' EXIT
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
      and ([.products[] | select(
          .name == "PrimeNativeDecoderRuntime"
          and .targets == ["PrimeNativeDecoderRuntime"]
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
      and ([.targets[] | select(
          .name == "PrimeNativeDecoderRuntime"
          and .type == "regular"
          and ([.dependencies[] | (.byName[0] // .product[0])]
              == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "PrimeNativeDecoderCheckpoint",
                  "MLX"
              ])
          and ([.settings[].kind.linkedFramework._0]
              == ["CoreGraphics", "Metal"])
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

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_checkpoint_v2_manifest_dump"
jq -e \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderCheckpointCompatibilityV2Validation"
      and (.dependencies | length) == 1
      and .dependencies[0].fileSystem[0]
          .nameForTargetDependencyResolutionOnly == "ergentics-prime"
      and .dependencies[0].fileSystem[0].path == $prime_root
      and (.targets | length) == 1
      and .targets[0].name
          == "PrimeNativeDecoderCheckpointCompatibilityV2Tests"
      and .targets[0].type == "test"
      and ([.targets[0].dependencies[].product[0]] == [
          "PrimeCore",
          "PrimeNativeDecoderCheckpoint"
      ])
      and ([.targets[0].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-prime"
      ])
      and (.targets[0].settings | length) == 0
      and (.products | length) == 0
    ' \
    "$decoder_checkpoint_v2_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder checkpoint V2 validation manifest changed"

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderRuntimeClosureValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_runtime_closure_manifest_dump"
jq -e \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderRuntimeClosureValidation"
      and (.dependencies | length) == 1
      and .dependencies[0].fileSystem[0]
          .nameForTargetDependencyResolutionOnly == "ergentics-prime"
      and .dependencies[0].fileSystem[0].path == $prime_root
      and (.products | length) == 1
      and .products[0].name == "PrimeNativeDecoderRuntimeClosureProbe"
      and .products[0].targets == ["PrimeNativeDecoderRuntimeClosureProbe"]
      and (.products[0].type | keys) == ["executable"]
      and (.targets | length) == 2
      and [.targets[].name] == [
          "PrimeNativeDecoderRuntimeClosureProbe",
          "PrimeNativeDecoderRuntimeClosureAuthorityTests"
      ]
      and [.targets[].type] == ["executable", "test"]
      and ([.targets[0].dependencies[].product[0]] == [
          "PrimeCore",
          "PrimeNativeDecoderRuntime"
      ])
      and ([.targets[1].dependencies[].product[0]] == [
          "PrimeCore",
          "PrimeNativeDecoderRuntime"
      ])
      and ([.targets[0].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-prime"
      ])
      and ([.targets[1].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-prime"
      ])
      and (.targets[0].settings | length) == 0
      and (.targets[1].settings | length) == 0
    ' \
    "$decoder_runtime_closure_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder runtime-closure validation manifest changed"

readonly decoder_source="$prime_root/Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
readonly decoder_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderAuthority.swift"
readonly decoder_derived_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderDerivedDelta.swift"
readonly decoder_checkpoint_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift"
readonly decoder_checkpoint_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift"
readonly decoder_checkpoint_v2_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift"
readonly decoder_checkpoint_v2_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift"
readonly decoder_runtime_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift"
readonly decoder_runtime_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeExecutionObservation.swift"
readonly decoder_runtime_source="$prime_root/Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift"
readonly decoder_metal_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift"
readonly decoder_metal_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservation.swift"
readonly decoder_metal_execution_correction_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservationCorrection.swift"
readonly decoder_gate_repair_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderGateRepairExecutionObservation.swift"
readonly decoder_reviewed_main_metal_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderReviewedMainMetalExecutionObservation.swift"
readonly decoder_validation_manifest="$prime_root/Tests/PrimeNativeDecoderValidation/Package.swift"
readonly decoder_authority_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift"
readonly decoder_validation_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift"
readonly decoder_checkpoint_test="$prime_root/Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift"
readonly decoder_checkpoint_v2_validation_root="$prime_root/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation"
readonly decoder_checkpoint_v2_validation_manifest="$decoder_checkpoint_v2_validation_root/Package.swift"
readonly decoder_checkpoint_v2_validation_lock="$decoder_checkpoint_v2_validation_root/Package.resolved"
readonly decoder_checkpoint_v2_validation_test="$decoder_checkpoint_v2_validation_root/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Tests/PrimeNativeDecoderCompatibilityIdentityV2Tests.swift"
readonly decoder_runtime_closure_validation_root="$prime_root/Tests/PrimeNativeDecoderRuntimeClosureValidation"
readonly decoder_runtime_closure_validation_manifest="$decoder_runtime_closure_validation_root/Package.swift"
readonly decoder_runtime_closure_validation_lock="$decoder_runtime_closure_validation_root/Package.resolved"
readonly decoder_runtime_closure_probe="$decoder_runtime_closure_validation_root/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift"
readonly decoder_runtime_closure_test="$decoder_runtime_closure_validation_root/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift"

[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoder')" \
    == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift" ]] ||
    die "PrimeNativeDecoder production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderCheckpoint')" \
    == $'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift' ]] ||
    die "PrimeNativeDecoderCheckpoint production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderRuntime')" \
    == 'Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift' ]] ||
    die "PrimeNativeDecoderRuntime production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Tests/PrimeNativeDecoderValidation')" \
    == $'Tests/PrimeNativeDecoderValidation/Package.resolved\nTests/PrimeNativeDecoderValidation/Package.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift\nTests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift' ]] ||
    die "PrimeNativeDecoder validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation')" \
    == $'Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.resolved\nTests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.swift\nTests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Tests/PrimeNativeDecoderCompatibilityIdentityV2Tests.swift' ]] ||
    die "PrimeNativeDecoder checkpoint V2 validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation')" \
    == $'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved\nTests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder runtime-closure validation inventory changed"
[[ ! -e "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" \
    && ! -L "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" ]] ||
    die "PrimeNativeDecoder validation must use the supplied isolated config path"
[[ ! -e "$decoder_checkpoint_v2_validation_root/.swiftpm" \
    && ! -L "$decoder_checkpoint_v2_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder checkpoint V2 validation must use the supplied isolated config path"
[[ ! -e "$decoder_runtime_closure_validation_root/.swiftpm" \
    && ! -L "$decoder_runtime_closure_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder runtime-closure validation must use the supplied isolated config path"
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
[[ -f "$decoder_checkpoint_v2_source" \
    && ! -L "$decoder_checkpoint_v2_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 identity source is missing or linked"
[[ -f "$decoder_checkpoint_authority_source" \
    && ! -L "$decoder_checkpoint_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint authority is missing or linked"
[[ -f "$decoder_checkpoint_v2_authority_source" \
    && ! -L "$decoder_checkpoint_v2_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 authority is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_test" \
    && ! -L "$decoder_checkpoint_v2_validation_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation test is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_manifest" \
    && ! -L "$decoder_checkpoint_v2_validation_manifest" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation manifest is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_lock" \
    && ! -L "$decoder_checkpoint_v2_validation_lock" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation lock is missing or linked"
[[ -f "$decoder_runtime_authority_source" \
    && ! -L "$decoder_runtime_authority_source" ]] ||
    die "PrimeNativeDecoder maintained-runtime authority is missing or linked"
[[ -f "$decoder_runtime_execution_observation_source" \
    && ! -L "$decoder_runtime_execution_observation_source" ]] ||
    die "PrimeNativeDecoder maintained-runtime execution observation is missing or linked"
[[ -f "$decoder_runtime_source" && ! -L "$decoder_runtime_source" ]] ||
    die "PrimeNativeDecoder runtime source is missing or linked"
[[ -f "$decoder_runtime_closure_validation_manifest" \
    && ! -L "$decoder_runtime_closure_validation_manifest" ]] ||
    die "PrimeNativeDecoder runtime-closure validation manifest is missing or linked"
[[ -f "$decoder_runtime_closure_validation_lock" \
    && ! -L "$decoder_runtime_closure_validation_lock" ]] ||
    die "PrimeNativeDecoder runtime-closure validation lock is missing or linked"
[[ -f "$decoder_runtime_closure_probe" \
    && ! -L "$decoder_runtime_closure_probe" ]] ||
    die "PrimeNativeDecoder runtime-closure probe is missing or linked"
[[ -f "$decoder_runtime_closure_test" \
    && ! -L "$decoder_runtime_closure_test" ]] ||
    die "PrimeNativeDecoder runtime-closure test is missing or linked"
[[ -f "$decoder_metal_repair_authority_source" \
    && ! -L "$decoder_metal_repair_authority_source" ]] ||
    die "PrimeNativeDecoder Metal-repair authority is missing or linked"
[[ -f "$decoder_metal_execution_observation_source" \
    && ! -L "$decoder_metal_execution_observation_source" ]] ||
    die "PrimeNativeDecoder Metal execution observation is missing or linked"
[[ -f "$decoder_metal_execution_correction_source" \
    && ! -L "$decoder_metal_execution_correction_source" ]] ||
    die "PrimeNativeDecoder Metal execution correction is missing or linked"
[[ -f "$decoder_gate_repair_execution_observation_source" \
    && ! -L "$decoder_gate_repair_execution_observation_source" ]] ||
    die "PrimeNativeDecoder gate-repair execution observation is missing or linked"
[[ -f "$decoder_reviewed_main_metal_execution_observation_source" \
    && ! -L "$decoder_reviewed_main_metal_execution_observation_source" ]] ||
    die "PrimeNativeDecoder reviewed-main Metal observation is missing or linked"
[[ "$(wc -c < "$decoder_checkpoint_authority_source" | awk '{print $1}')" \
    == "14399" ]] ||
    die "PrimeNativeDecoderCheckpoint authority byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_authority_source" | awk '{print $1}')" \
    == "60d593b8b0346570400f98212b173cef9f4495f24af34517097c20309eb765ac" ]] ||
    die "PrimeNativeDecoderCheckpoint authority SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_authority_source")" \
    == "2621721ef52cfb0aa823f096df9be83c37971aab" ]] ||
    die "PrimeNativeDecoderCheckpoint authority blob changed"
for v2_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift' \
    'Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.swift' \
    'Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Package.resolved' \
    'Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation/Tests/PrimeNativeDecoderCheckpointCompatibilityV2Tests/PrimeNativeDecoderCompatibilityIdentityV2Tests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- "$v2_regular_source" | awk '{print $1}')" \
        == "100644" ]] ||
        die "PrimeNativeDecoderCheckpoint V2 source mode changed: $v2_regular_source"
done
for runtime_closure_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift' \
    'Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeExecutionObservation.swift' \
    'Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift' \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift' \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift' \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$runtime_closure_regular_source" | awk '{print $1}')" == "100644" ]] ||
        die "PrimeNativeDecoder runtime-closure source mode changed: $runtime_closure_regular_source"
done

assert_runtime_closure_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "runtime-closure identity source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "runtime-closure identity source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "runtime-closure identity source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "runtime-closure identity source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "runtime-closure identity source SHA-256 changed: $relative_path"
}

assert_runtime_closure_source_identity \
    'Package.swift' \
    '100644' \
    'f201abbf928e5e3d6b0c7785110539cdaeee911b' \
    '32082' \
    'db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400'
assert_runtime_closure_source_identity \
    'Package.resolved' \
    '100644' \
    'dcd0192f705c22378f2d9e871a240c0493ad8a80' \
    '645' \
    'a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741'
assert_runtime_closure_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift' \
    '100644' \
    '379c3e40ab24ae696c01da0b3f2116d0093cedb2' \
    '60844' \
    'f53a7a055058fbf528d7a96b4111c673fa3bc2dbd2ae10bf5129aa8b828a2445'
assert_runtime_closure_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeExecutionObservation.swift' \
    '100644' \
    '49e107f9fdd2ec5deb262d1885f015c6640eb33c' \
    '47473' \
    'ecbe1cbacb5da829e867bb1097cf2542eff346ae293488b49deb2f9287edb9c0'
assert_runtime_closure_source_identity \
    'Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift' \
    '100644' \
    'dd3ca76ba7799c6deb0012276967c07bee3644d0' \
    '55550' \
    '71d312d03f81509ece6234067a8b5f43c410ca2941da658134921141037fa981'
assert_runtime_closure_source_identity \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift' \
    '100644' \
    'ed63a3edf5def776cdb531166090a69afdf0e425' \
    '1368' \
    '57239460a6e2dc6884ba1a034b04084dbc52477c78c11078824b006ce0abe058'
assert_runtime_closure_source_identity \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved' \
    '100644' \
    '9128fe027a155fe6ea3c56667cf57989bc05128d' \
    '645' \
    'fabc36489bd4b7af41d0a9994286e7a7458f46fedd25c545fd0ab190274f33e5'
assert_runtime_closure_source_identity \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift' \
    '100644' \
    '63679a06c900b803b23778b011980636a3b302f1' \
    '3133' \
    '59419ec899b4ed12b8c40156c27c5f870efe78dcb93a45b0ec93ccf7ab26196c'
assert_runtime_closure_source_identity \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift' \
    '100644' \
    'f159267dfa77a643337ba9cd7f60d733d4d84033' \
    '15364' \
    'cf80369f52e83ab4b1be453a3ca1fec4eea14013ca3843d67c17de29f36c69f5'
assert_runtime_closure_source_identity \
    '.github/scripts/prime-ci-native-decoder-runtime-closure.sh' \
    '100755' \
    'f1c3041d7e47fa315f60c889a736a412640e8710' \
    '26614' \
    'aac5421ec7b1465bb746079bf5ea2634e20b9456099b33ce0271228638342cc5'
[[ "$(wc -c < "$decoder_checkpoint_v2_authority_source" | awk '{print $1}')" \
    == "29660" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 authority byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_v2_authority_source" | awk '{print $1}')" \
    == "ea5048b74b37cb8df9978f10c632c9fdbef47655b414518ce926b9d73ada8bdd" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 authority SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_v2_authority_source")" \
    == "b09e51e6cd79b3962fec4ddb28c1a154ef979076" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 authority blob changed"
[[ "$(wc -c < "$decoder_checkpoint_v2_source" | awk '{print $1}')" \
    == "9228" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 identity byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_v2_source" | awk '{print $1}')" \
    == "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 identity SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_v2_source")" \
    == "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 identity blob changed"
[[ "$(wc -c < "$decoder_checkpoint_v2_validation_manifest" | awk '{print $1}')" \
    == "759" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation manifest byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_v2_validation_manifest" | awk '{print $1}')" \
    == "dd1b0c661bd22a8d36b02ce310873a9dc7bd2b6e532661affae2a8baf1f2d7a5" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation manifest SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_v2_validation_manifest")" \
    == "f2694f6b9c85b997a4ce7dedca48e456cf65d7c1" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation manifest blob changed"
[[ "$(wc -c < "$decoder_checkpoint_v2_validation_lock" | awk '{print $1}')" \
    == "645" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation lock byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_v2_validation_lock" | awk '{print $1}')" \
    == "a919de67d38bc986c38a52fa3e3fdcf9fbc5890eb987c506ced769d404829e34" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation lock SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_v2_validation_lock")" \
    == "3083ed5145d3f8eae3858a61b103ebf31071feef" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation lock blob changed"
[[ "$(wc -c < "$decoder_checkpoint_v2_validation_test" | awk '{print $1}')" \
    == "16942" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation test byte count changed"
[[ "$(shasum -a 256 "$decoder_checkpoint_v2_validation_test" | awk '{print $1}')" \
    == "7a7e5111c4047ba009a4ddb5320e206e66e2b89f1674bf66739a0c3e7dda8c74" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation test SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_checkpoint_v2_validation_test")" \
    == "2dd3a7f4a381129580897e529f935275a7e38cf8" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation test blob changed"
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
[[ "$(git -C "$prime_root" ls-files -s -- \
    'Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservationCorrection.swift' | awk '{print $1}')" \
    == "100644" ]] ||
    die "PrimeNativeDecoder Metal execution correction mode changed"
[[ "$(wc -c < "$decoder_metal_execution_correction_source" | awk '{print $1}')" \
    == "22744" ]] ||
    die "PrimeNativeDecoder Metal execution correction byte count changed"
[[ "$(shasum -a 256 "$decoder_metal_execution_correction_source" | awk '{print $1}')" \
    == "9ef5851532c58d10165c6e6f511889f29d4f10bce7cc7b0b5d305392d0e54748" ]] ||
    die "PrimeNativeDecoder Metal execution correction SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_metal_execution_correction_source")" \
    == "b9b0947cd814efc09d6412409d286b6be6db192f" ]] ||
    die "PrimeNativeDecoder Metal execution correction blob changed"
[[ "$(git -C "$prime_root" ls-files -s -- \
    'Sources/PrimeCore/PrimeNativeDecoderGateRepairExecutionObservation.swift' | awk '{print $1}')" \
    == "100644" ]] ||
    die "PrimeNativeDecoder gate-repair execution observation mode changed"
[[ "$(wc -c < "$decoder_gate_repair_execution_observation_source" | awk '{print $1}')" \
    == "19780" ]] ||
    die "PrimeNativeDecoder gate-repair execution observation byte count changed"
[[ "$(shasum -a 256 "$decoder_gate_repair_execution_observation_source" | awk '{print $1}')" \
    == "fcce012be39a0178ff22e21a4218e4384dea6d082733b45930c9b8133011de9d" ]] ||
    die "PrimeNativeDecoder gate-repair execution observation SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_gate_repair_execution_observation_source")" \
    == "3b242cd57b4f922ada466d8ae39b58424ff878c2" ]] ||
    die "PrimeNativeDecoder gate-repair execution observation blob changed"
[[ "$(git -C "$prime_root" ls-files -s -- \
    'Sources/PrimeCore/PrimeNativeDecoderReviewedMainMetalExecutionObservation.swift' | awk '{print $1}')" \
    == "100644" ]] ||
    die "PrimeNativeDecoder reviewed-main Metal observation mode changed"
[[ "$(wc -c < "$decoder_reviewed_main_metal_execution_observation_source" | awk '{print $1}')" \
    == "37500" ]] ||
    die "PrimeNativeDecoder reviewed-main Metal observation byte count changed"
[[ "$(shasum -a 256 "$decoder_reviewed_main_metal_execution_observation_source" | awk '{print $1}')" \
    == "c94fa198edc1708eab69687fc2baac9fddfd91900bca99f1fe7cb5c4473f1746" ]] ||
    die "PrimeNativeDecoder reviewed-main Metal observation SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_reviewed_main_metal_execution_observation_source")" \
    == "f5025b136b761b2db680cdc656542c6d5caa309e" ]] ||
    die "PrimeNativeDecoder reviewed-main Metal observation blob changed"
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
swiftc -frontend -parse "$decoder_checkpoint_v2_source"
swiftc -frontend -parse "$decoder_checkpoint_authority_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_authority_source"
swiftc -frontend -parse "$decoder_runtime_authority_source"
swiftc -frontend -parse "$decoder_runtime_execution_observation_source"
swiftc -frontend -parse "$decoder_runtime_source"
swiftc -frontend -parse "$decoder_metal_repair_authority_source"
swiftc -frontend -parse "$decoder_metal_execution_observation_source"
swiftc -frontend -parse "$decoder_metal_execution_correction_source"
swiftc -frontend -parse "$decoder_gate_repair_execution_observation_source"
swiftc -frontend -parse "$decoder_reviewed_main_metal_execution_observation_source"
swiftc -frontend -parse "$decoder_authority_test"
swiftc -frontend -parse "$decoder_checkpoint_test"
swiftc -frontend -parse "$decoder_validation_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_validation_test"
swiftc -frontend -parse "$decoder_runtime_closure_probe"
swiftc -frontend -parse "$decoder_runtime_closure_test"

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
[[ "$(awk '/^import / {print $2}' "$decoder_checkpoint_v2_source" | paste -sd, -)" \
    == "Foundation,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 identity imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_runtime_authority_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoder maintained-runtime authority imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_runtime_execution_observation_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoder maintained-runtime execution observation imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_runtime_source" | paste -sd, -)" \
    == "CoreGraphics,Darwin,Foundation,Metal,MLX,PrimeCore,PrimeNativeDecoder,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoder runtime imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_runtime_closure_probe" | paste -sd, -)" \
    == "Darwin,Foundation,PrimeCore,PrimeNativeDecoderRuntime" ]] ||
    die "PrimeNativeDecoder runtime-closure probe imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_runtime_closure_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderRuntime" ]] ||
    die "PrimeNativeDecoder runtime-closure test imports changed"
[[ "$(grep -Fc -- '.package(' "$decoder_validation_manifest")" == "2" ]] ||
    die "PrimeNativeDecoder validation gained an unexpected dependency"
grep -Fq -- 'name: "PrimeNativeDecoder"' "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not consume the Prime product"
grep -Fq -- 'name: "PrimeNativeDecoderCheckpoint"' \
    "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not consume the checkpoint product"
grep -Fq -- "$root_mlx_revision" "$decoder_validation_manifest" ||
    die "PrimeNativeDecoder validation does not pin the active MLX revision"
[[ "$(grep -Fc -- '.package(' "$decoder_checkpoint_v2_validation_manifest")" \
    == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 validation gained an unexpected dependency"
grep -Fq -- 'name: "PrimeCore"' \
    "$decoder_checkpoint_v2_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 validation does not consume PrimeCore"
grep -Fq -- 'name: "PrimeNativeDecoderCheckpoint"' \
    "$decoder_checkpoint_v2_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 validation does not consume the checkpoint product"
[[ "$(grep -Fc -- '.package(' "$decoder_runtime_closure_validation_manifest")" \
    == "1" ]] ||
    die "PrimeNativeDecoder runtime-closure validation gained an unexpected dependency"
grep -Fq -- 'name: "PrimeCore"' \
    "$decoder_runtime_closure_validation_manifest" ||
    die "PrimeNativeDecoder runtime-closure validation does not consume PrimeCore"
grep -Fq -- 'name: "PrimeNativeDecoderRuntime"' \
    "$decoder_runtime_closure_validation_manifest" ||
    die "PrimeNativeDecoder runtime-closure validation does not consume the runtime product"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_runtime_closure_test")" == "1" ]] ||
    die "PrimeNativeDecoder runtime-closure validation test count changed"

for forbidden_runtime_closure_source_value in \
    'MLXLLM' \
    'MLXNN' \
    'MLXOptimizers' \
    'PMHNP' \
    'Geometry' \
    'RenderKit' \
    'PrimeNativeGQADecoder.make' \
    '.forward(' \
    'PrimeNativeDecoderCheckpointManifestV1' \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'writeNative300MByte512' \
    'loadNative300MByte512' \
    'URLSession' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_runtime_closure_source_value" \
        "$decoder_runtime_authority_source" \
        "$decoder_runtime_execution_observation_source" \
        "$decoder_runtime_source" \
        "$decoder_runtime_closure_probe" \
        "$decoder_runtime_closure_test"; then
        die "PrimeNativeDecoder runtime closure contains forbidden value: $forbidden_runtime_closure_source_value"
    fi
done
if grep -Eq -- \
    '(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)' \
    "$decoder_runtime_authority_source" \
    "$decoder_runtime_execution_observation_source" \
    "$decoder_runtime_source" \
    "$decoder_runtime_closure_probe" \
    "$decoder_runtime_closure_test"; then
    die "PrimeNativeDecoder runtime closure contains forbidden value: Process"
fi

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
    "HuggingFace" \
    "PMHNP" \
    "MLXOptimizers" \
    "ErgenticsLLM" \
    "NativeTinyDecoder" \
    "URLSession"; do
    if grep -Fq -- "$forbidden_decoder_value" \
        "$decoder_source" \
        "$decoder_checkpoint_source" \
        "$decoder_checkpoint_v2_source" \
        "$decoder_authority_test" \
        "$decoder_checkpoint_test" \
        "$decoder_validation_test" \
        "$decoder_checkpoint_v2_validation_test"; then
        die "PrimeNativeDecoder closure contains forbidden value: $forbidden_decoder_value"
    fi
done

# The frozen implementation authority forbids the standalone Foundation
# Process identifier.  The isolated XCTest target must nevertheless inspect
# its own launched environment through ProcessInfo before its first Metal/MLX
# call.  Match the Swift identifier token rather than an arbitrary substring
# so ProcessInfo and inProcess-bound authority fields remain distinct.
if grep -Eq -- \
    '(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)' \
    "$decoder_source" \
    "$decoder_checkpoint_source" \
    "$decoder_checkpoint_v2_source" \
    "$decoder_authority_test" \
    "$decoder_checkpoint_test" \
    "$decoder_validation_test" \
    "$decoder_checkpoint_v2_validation_test"; then
    die "PrimeNativeDecoder closure contains forbidden value: Process"
fi

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
        "$decoder_checkpoint_source" \
        "$decoder_checkpoint_v2_source"; then
        die "PrimeNativeDecoderCheckpoint owns forbidden capability: $forbidden_checkpoint_capability"
    fi
done

for forbidden_v2_identity_capability in \
    "import Darwin" \
    "import Metal" \
    "import MLX" \
    "import MLXNN" \
    "import MLXOptimizers" \
    "MLXArray" \
    "PrimeNativeDecoderCheckpointManifestV1" \
    "PrimeNativeDecoderCheckpointCodecV1" \
    "FileManager" \
    "FileHandle" \
    "URL(fileURLWithPath:" \
    "open(" \
    "close(" \
    "read(" \
    "write(" \
    "load(" \
    "save("; do
    if grep -Fq -- "$forbidden_v2_identity_capability" \
        "$decoder_checkpoint_v2_source"; then
        die "PrimeNativeDecoderCheckpoint V2 identity owns forbidden capability: $forbidden_v2_identity_capability"
    fi
done

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during metadata validation"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during metadata validation"

echo "OK: first-party MLX is pinned; mlx-swift-lm execution targets are disconnected while historical comparator evidence remains preserved"

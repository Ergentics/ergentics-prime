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
readonly decoder_tokenizer_compatibility_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh"
readonly decoder_checkpoint_v2_io_execution_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh"

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
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift" \
    "f0d010959aaf20fddb755aec7a1b61550dec93dd"
require_preserved_object \
    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift" \
    "105af3f93acf9358e7b66c3a327e45a931deab8b"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift" \
    "0a371f2fec33db3fe42d425674e2fd2539927eb7"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved" \
    "d5621ea4139fee6cc1fc39e03512ea4c1b009b5f"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift" \
    "74129e24c11a742adb11a80a8e454924426c63ee"
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
    "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift" \
    "a14d52e2af3dee3c39d8bb6cb017995cf3a4aa0c"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift" \
    "92bc5e2f1e802c37d2b3b6ac07c6b60ce483328c"
require_preserved_object \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift" \
    "da9785a7263522541a81fd39c34acc2512d87100"
require_preserved_object \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved" \
    "6f080d562484a13a45194d430c395f8a3b64a0bd"
require_preserved_object \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift" \
    "3a5d77e0e874a082a0e8d3a8352de0f41b34010b"
require_preserved_object \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift" \
    "d8c696981633bceae281e681b9f33ef0d5ca6141"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh" \
    "b12d52802e7f24be7a905ae0cbceeed945fcc11a"
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
    "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift" \
    "$root_mlx_revision"
assert_active_lock \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift" \
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
[[ "$(grep -Fxc -- '  active-root:' "$workflow_path")" == "1" \
    && "$(grep -Fxc -- '  trusted-main-compile:' "$workflow_path")" == "1" \
    && "$(grep -Fxc -- '    steps:' "$workflow_path")" == "2" ]] ||
    die "hosted quarantine workflow job topology changed"
[[ "$(awk '
    /^  active-root:$/ { inside = 1; next }
    /^  trusted-main-compile:$/ { inside = 0 }
    inside && /^      - name:/ { count += 1 }
    END { print count + 0 }
' "$workflow_path")" == "5" \
    && "$(awk '
        /^  trusted-main-compile:$/ { inside = 1; next }
        inside && /^      - name:/ { count += 1 }
        END { print count + 0 }
    ' "$workflow_path")" == "5" ]] ||
    die "hosted quarantine workflow step topology changed"
[[ "$(grep -Fxc -- '    runs-on: macos-15' "$workflow_path")" == "1" \
    && "$(grep -Fxc -- '    runs-on: macos-26' "$workflow_path")" == "1" \
    && "$(awk '
        /^  active-root:$/ { inside = 1; next }
        /^  trusted-main-compile:$/ { inside = 0 }
        inside && /^    timeout-minutes:/ { print $2 }
    ' "$workflow_path")" == "45" \
    && "$(awk '
        /^  trusted-main-compile:$/ { inside = 1; next }
        inside && /^    timeout-minutes:/ { print $2 }
    ' "$workflow_path")" == "90" ]] ||
    die "hosted quarantine workflow runner or timeout boundary changed"
[[ "$(grep -Fxc -- \
    '          git -C ergentics-prime fetch --depth=1 --no-tags --no-write-fetch-head origin "$EXACT_REVISION"' \
    "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        '          git -C ergentics-prime fetch --depth=2 --no-tags --no-write-fetch-head origin "$EXACT_REVISION"' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "    if: github.event_name == 'push' && github.ref == 'refs/heads/main'" \
        "$workflow_path")" == "1" ]] ||
    die "hosted quarantine workflow checkout or reviewed-main boundary changed"
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
[[ -f "$decoder_tokenizer_compatibility_gate_path" \
    && ! -L "$decoder_tokenizer_compatibility_gate_path" ]] ||
    die "Prime native decoder tokenizer-compatibility gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- \
    '.github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh')" \
    == '.github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh' ]] ||
    die "Prime native decoder tokenizer-compatibility gate is not tracked exactly"
bash -n "$decoder_tokenizer_compatibility_gate_path" ||
    die "Prime native decoder tokenizer-compatibility gate is not valid Bash"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder tokenizer-compatibility gate mode changed"
[[ -f "$decoder_checkpoint_v2_io_execution_gate_path" \
    && ! -L "$decoder_checkpoint_v2_io_execution_gate_path" ]] ||
    die "Prime native decoder checkpoint V2 I/O execution gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh')" \
    == '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh' ]] ||
    die "Prime native decoder checkpoint V2 I/O execution gate is not tracked exactly"
bash -n "$decoder_checkpoint_v2_io_execution_gate_path" ||
    die "Prime native decoder checkpoint V2 I/O execution gate is not valid Bash"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder checkpoint V2 I/O execution gate mode changed"
grep -Fq -- '      - name: Run the Prime-owned decoder on live Metal' \
    "$workflow_path" ||
    die "trusted-main workflow lost the frozen decoder Metal step"
readonly frozen_metal_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-metal.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
readonly runtime_closure_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
readonly tokenizer_compatibility_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_execution_workflow_line="$(grep -nFx -- \
    '          bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh' \
    "$workflow_path" | awk -F: '{print $1}')"
[[ "$frozen_metal_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$tokenizer_compatibility_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_execution_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" \
        -eq $((frozen_metal_workflow_line + 1)) \
    && "$tokenizer_compatibility_workflow_line" \
        -eq $((runtime_closure_workflow_line + 1)) \
    && "$checkpoint_v2_io_execution_workflow_line" \
        -eq $((tokenizer_compatibility_workflow_line + 1)) ]] ||
    die "trusted-main workflow does not run the four decoder gates in exact order"
grep -Fq -- \
    '--package-path Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation' \
    "$workflow_path" ||
    die "trusted-main workflow does not run checkpoint V2 validation"
grep -Fq -- \
    '--package-path Tests/PrimeNativeDecoderCheckpointV2IOValidation' \
    "$workflow_path" ||
    die "trusted-main workflow does not run checkpoint V2 I/O validation"
grep -Fq -- 'prime-checkpoint-v2-io-tests.log' "$workflow_path" ||
    die "trusted-main workflow does not retain checkpoint V2 I/O validation output"
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

for required_tokenizer_compatibility_gate_value in \
    'prime-native-decoder-metal-tests.log' \
    'prime-native-decoder-runtime-closure-authority-tests.log' \
    'prime-native-decoder-runtime-closure-probe.log' \
    '--configuration release' \
    '--jobs 2' \
    '--build-tests' \
    'xcrun xctest' \
    'Executed 1 test, with 0 failures' \
    'MLX_ENABLE_TF32=0' \
    'PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_REVISION=' \
    'PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_TREE=' \
    'CoreGraphics' \
    'Metal' \
    'private_cwd' \
    'PrimeNativeDecoderTokenizerCompatibilityProbe' \
    'PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    'PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only'; do
    grep -Fq -- "$required_tokenizer_compatibility_gate_value" \
        "$decoder_tokenizer_compatibility_gate_path" ||
        die "Prime native decoder tokenizer-compatibility gate is missing: $required_tokenizer_compatibility_gate_value"
done
for forbidden_tokenizer_compatibility_gate_value in \
    '--disable-sandbox' \
    'xcodebuild' \
    'git fetch' \
    'git clone' \
    'submodule update' \
    'MLXLLM' \
    'MLXOptimizers' \
    'PMHNP' \
    'DriverV2' \
    'Geometry' \
    'RenderKit' \
    'PrimeNativeDecoderCheckpointManifestV1' \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'writeNative300MByte512' \
    'loadNative300MByte512' \
    'synthetic_' \
    'tiny'; do
    if grep -Fq -- "$forbidden_tokenizer_compatibility_gate_value" \
        "$decoder_tokenizer_compatibility_gate_path"; then
        die "Prime native decoder tokenizer-compatibility gate contains forbidden value: $forbidden_tokenizer_compatibility_gate_value"
    fi
done

for required_checkpoint_v2_io_execution_gate_value in \
    '[[ "${GITHUB_ACTIONS:-}" == "true" ]]' \
    '[[ "${RUNNER_ENVIRONMENT:-}" == "github-hosted" ]]' \
    '[[ "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" ]]' \
    '[[ "${GITHUB_EVENT_NAME:-}" == "push" ]]' \
    '[[ "${GITHUB_REF:-}" == "refs/heads/main" ]]' \
    '[[ "${GITHUB_RUN_ATTEMPT:-}" == "1" ]]' \
    '[[ "${RUNNER_OS:-}" == "macOS" ]]' \
    '[[ "${RUNNER_ARCH:-}" == "ARM64" ]]' \
    '[[ "${GITHUB_SHA:-}" == "$exact_revision" ]]' \
    'readonly base_revision="b861fa8270cbdceefd6079f7e09fece495fc4b79"' \
    'rev-list --parents -n 1 HEAD' \
    '[[ "$first_parent" == "$base_revision" ]]' \
    '[[ "$exact_tree" == "$reviewed_head_tree" ]]' \
    '[[ "${#predecessor_logs[@]}" -eq 8 ]]' \
    'PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' \
    'PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
    '[[ "${#reclaimable_relative_paths[@]}" -eq 24 ]]' \
    'rm -rf -- "$target"' \
    'readonly required_free_bytes=3303616512' \
    'less than 3x checkpoint cap free after reclamation' \
    'less than 3x checkpoint cap free after Release build' \
    '--configuration release' \
    'xcrun xctest "$test_bundle"' \
    'Executed 1 test, with 0 failures' \
    'PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_PREDECESSOR_VALIDATED_LOG_COUNT=8' \
    'PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_PREDECESSOR_VALIDATED_RECEIPT_COUNT=2' \
    'readonly receipt_begin="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_BEGIN="' \
    'readonly receipt_chunk="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_CHUNK="' \
    'readonly receipt_end="PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_END="' \
    'chunk_character_count=4096' \
    'chunk_pattern=' \
    'expected_ordinal="$(printf '\''%06d'\'' "$chunk_index")"' \
    '"$receipt_chunk_count" -le 86' \
    'transport_state=before' \
    'transport_state=chunks' \
    'transport_state=after' \
    'umask 077' \
    'set -o noclobber' \
    'exclusive receipt file creation' \
    '"$(stat -f %Lp "$receipt_file")" == "600"' \
    'receipt_identity_json=' \
    'receipt_tensor_bindings_json=' \
    'receipt_manifest_json=' \
    'receipt_external_binding_json=' \
    'base64 -D < "$receipt_base64" > "$receipt_json"' \
    'decoded canonical receipt contains a literal newline' \
    'cmp -s \' \
    "jq -cSj '.external_binding.manifest.compatibility_identity'" \
    "jq -cSj '.external_binding.manifest.tensor_bindings'" \
    "jq -cSj '.external_binding.manifest'" \
    "jq -cSj '.external_binding'" \
    'unsafe nested canonical receipt file' \
    'readonly identity_canonical_bytes=' \
    'readonly tensor_bindings_canonical_bytes=' \
    'readonly manifest_canonical_bytes=' \
    'readonly external_binding_canonical_bytes=' \
    'and (keys == ([' \
    'external_binding.manifest.compatibility_identity | keys' \
    'external_binding.manifest.compatibility_identity.parameter_catalog' \
    '.compatibility_identity_canonical_byte_count == 30553' \
    '.compatibility_identity_sha256 == "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843"' \
    '.compatibility_identity_validated == true' \
    '.external_binding_canonical_byte_count == $external_bytes' \
    '.external_binding_canonical_sha256 == $external_sha' \
    '.manifest_canonical_byte_count == $manifest_bytes' \
    '.manifest_canonical_sha256 == $manifest_sha' \
    '.manifest_validated == true' \
    '.tensor_bindings_canonical_byte_count == $tensor_bytes' \
    '.tensor_bindings_sha256 == $tensor_sha' \
    '.configuration == {' \
    '"vocabulary_size": 512,' \
    '"model_width": 1024,' \
    '"layer_count": 24,' \
    '"query_head_count": 16,' \
    '"key_value_head_count": 4,' \
    '"head_width": 64,' \
    '"intermediate_width": 2816,' \
    '"maximum_sequence_length": 2048,' \
    '"rope_theta_float32_bit_pattern": 1176256512,' \
    '"rms_norm_epsilon_float32_bit_pattern": 925353388,' \
    '"unique_parameter_count": 271107072' \
    '== "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1"' \
    '== 271107072' \
    '== 1084428288' \
    '== 1101205504' \
    '[.external_binding.manifest.tensor_bindings[].path]' \
    '== [.external_binding.manifest.compatibility_identity.parameter_catalog[].path]' \
    '.caller_source_model_construction_count == 1' \
    '.memory_cache_limit == 0 and .memory_cache_clear_count == 2' \
    '.source_inferred_decoder_construction_count == 3' \
    '.container_materialization_count_required_by_pinned_codec == 2' \
    '[.artifact_root_identity_before_write.device_id,' \
    'canonical receipt semantic validation' \
    'artifact_root_identity_after_load == .artifact_root_identity_after_write' \
    'artifact_binding.byteCount' \
    '"$(stat -f %d "$artifact_path")" == "$receipt_root_device"' \
    '"$(stat -f %.9Fm "$artifact_root")" == "$receipt_root_mtime"' \
    '"$(stat -f %.9Fc "$artifact_root")" == "$receipt_root_ctime"' \
    'unlink "$artifact_path"' \
    'rmdir "$artifact_root"' \
    'literal artifact cleanup postcondition'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_gate_value" \
        "$decoder_checkpoint_v2_io_execution_gate_path" ||
        die "Prime native decoder checkpoint V2 I/O execution gate is missing: $required_checkpoint_v2_io_execution_gate_value"
done

for forbidden_checkpoint_v2_io_execution_gate_value in \
    '--disable-sandbox' \
    'xcodebuild' \
    'git fetch' \
    'git clone' \
    'submodule update' \
    'MLXLLM' \
    'MLXOptimizers' \
    'PMHNP' \
    'DriverV2' \
    'Geometry' \
    'RenderKit' \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'writeNative300MByte512' \
    'loadNative300MByte512' \
    'rm -rf -- "$artifact_root"' \
    'shasum -a 256 "$artifact_path"' \
    'canonical_receipt=' \
    'transported_receipt=' \
    'curl ' \
    'scp ' \
    'rsync '; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_gate_value" \
        "$decoder_checkpoint_v2_io_execution_gate_path"; then
        die "Prime native decoder checkpoint V2 I/O execution gate contains forbidden value: $forbidden_checkpoint_v2_io_execution_gate_value"
    fi
done

readonly expected_checkpoint_v2_io_reclamation_inventory=$'prime-active-root-build\nprime-active-root-cache\nprime-active-root-config\nprime-active-root-security\nprime-checkpoint-v2-build\nprime-checkpoint-v2-cache\nprime-checkpoint-v2-config\nprime-checkpoint-v2-security\nprime-checkpoint-v2-io-build\nprime-checkpoint-v2-io-cache\nprime-checkpoint-v2-io-config\nprime-checkpoint-v2-io-security\nprime-native-decoder-build\nprime-native-decoder-cache\nprime-native-decoder-config\nprime-native-decoder-security\nprime-native-decoder-runtime-closure-build\nprime-native-decoder-runtime-closure-cache\nprime-native-decoder-runtime-closure-config\nprime-native-decoder-runtime-closure-security\nprime-native-decoder-tokenizer-compatibility-build\nprime-native-decoder-tokenizer-compatibility-cache\nprime-native-decoder-tokenizer-compatibility-config\nprime-native-decoder-tokenizer-compatibility-security'
readonly observed_checkpoint_v2_io_reclamation_inventory="$(awk '
    /^readonly reclaimable_relative_paths=\($/ { inside = 1; next }
    inside && /^\)$/ { exit }
    inside {
        for (field = 1; field <= NF; field += 1) {
            print $field
        }
    }
' "$decoder_checkpoint_v2_io_execution_gate_path")"
[[ "$observed_checkpoint_v2_io_reclamation_inventory" \
    == "$expected_checkpoint_v2_io_reclamation_inventory" ]] ||
    die "Prime native decoder checkpoint V2 I/O reclamation allowlist changed"

readonly checkpoint_v2_io_receipt_top_level_key_count="$(awk '
    /and \(keys == \(\[/ { inside = 1; next }
    inside && /\] \| sort\)\)/ { print count + 0; exit }
    inside && /^[[:space:]]*"/ { count += 1 }
' "$decoder_checkpoint_v2_io_execution_gate_path")"
[[ "$checkpoint_v2_io_receipt_top_level_key_count" == "148" ]] ||
    die "Prime native decoder checkpoint V2 I/O receipt key inventory changed"

[[ "$(grep -Fxc -- '[[ "$(grep -Ec "^${receipt_begin}" "$probe_log")" == "1" ]] ||' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '[[ "$(grep -Ec "^${receipt_end}" "$probe_log")" == "1" ]] ||' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '    --arg identity_sha "$identity_canonical_sha" \' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '    --arg tensor_sha "$tensor_bindings_canonical_sha" \' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '    --arg manifest_sha "$manifest_canonical_sha" \' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '    --arg external_sha "$external_binding_canonical_sha" \' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" ]] ||
    die "Prime native decoder checkpoint V2 I/O transport binding count changed"

[[ "$(grep -Fc -- 'rm -rf' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '    rm -rf -- "$target"' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- 'unlink "$artifact_path"' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- 'rmdir "$artifact_root"' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fc -- 'swift build' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "3" \
    && "$(grep -Fc -- 'xcrun xctest' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" \
    && "$(grep -Fxc -- '        "$probe_executable"' \
        "$decoder_checkpoint_v2_io_execution_gate_path")" == "1" ]] ||
    die "Prime native decoder checkpoint V2 I/O execution capability count changed"

readonly checkpoint_v2_io_one_shot_line="$(grep -nF -- \
    '[[ "$exact_tree" == "$reviewed_head_tree" ]]' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_predecessor_receipt_line="$(grep -nF -- \
    '>/dev/null || fail "tokenizer predecessor receipt"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_reclaim_line="$(grep -nFx -- \
    '    rm -rf -- "$target"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_after_reclaim_space_line="$(grep -nF -- \
    'readonly available_after_reclamation=' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_first_build_line="$(grep -nF -- \
    'TMPDIR="$runner_temp" swift build' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: 'NR == 1 {print $1}')"
readonly checkpoint_v2_io_after_build_space_line="$(grep -nF -- \
    'readonly available_after_build=' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_xctest_line="$(grep -nF -- \
    'TMPDIR="$runner_temp" xcrun xctest' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_artifact_root_line="$(grep -nF -- \
    'mkdir -p "$private_cwd" "$artifact_root" "$lease_root"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_line="$(grep -nFx -- \
    '        "$probe_executable"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_transport_line="$(grep -nF -- \
    'transport_state=before' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_semantic_receipt_line="$(grep -nF -- \
    'canonical receipt semantic validation' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_unlink_line="$(grep -nFx -- \
    'unlink "$artifact_path"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_rmdir_line="$(grep -nFx -- \
    'rmdir "$artifact_root"' \
    "$decoder_checkpoint_v2_io_execution_gate_path" | awk -F: '{print $1}')"
[[ "$checkpoint_v2_io_one_shot_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_predecessor_receipt_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_reclaim_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_after_reclaim_space_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_first_build_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_after_build_space_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_xctest_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_artifact_root_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_transport_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_semantic_receipt_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_unlink_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_rmdir_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_one_shot_line" -lt "$checkpoint_v2_io_predecessor_receipt_line" \
    && "$checkpoint_v2_io_predecessor_receipt_line" -lt "$checkpoint_v2_io_reclaim_line" \
    && "$checkpoint_v2_io_reclaim_line" -lt "$checkpoint_v2_io_after_reclaim_space_line" \
    && "$checkpoint_v2_io_after_reclaim_space_line" -lt "$checkpoint_v2_io_first_build_line" \
    && "$checkpoint_v2_io_first_build_line" -lt "$checkpoint_v2_io_after_build_space_line" \
    && "$checkpoint_v2_io_after_build_space_line" -lt "$checkpoint_v2_io_xctest_line" \
    && "$checkpoint_v2_io_xctest_line" -lt "$checkpoint_v2_io_artifact_root_line" \
    && "$checkpoint_v2_io_artifact_root_line" -lt "$checkpoint_v2_io_probe_line" \
    && "$checkpoint_v2_io_probe_line" -lt "$checkpoint_v2_io_transport_line" \
    && "$checkpoint_v2_io_transport_line" -lt "$checkpoint_v2_io_semantic_receipt_line" \
    && "$checkpoint_v2_io_semantic_receipt_line" -lt "$checkpoint_v2_io_unlink_line" \
    && "$checkpoint_v2_io_unlink_line" -lt "$checkpoint_v2_io_rmdir_line" ]] ||
    die "Prime native decoder checkpoint V2 I/O one-shot execution order changed"

readonly runner_temp="${RUNNER_TEMP:-/private/tmp}"
readonly manifest_dump="$(mktemp "$runner_temp/prime-package-dump.json.XXXXXX")"
readonly decoder_manifest_dump="$(mktemp "$runner_temp/prime-decoder-package-dump.json.XXXXXX")"
readonly decoder_checkpoint_v2_manifest_dump="$(mktemp "$runner_temp/prime-decoder-checkpoint-v2-package-dump.json.XXXXXX")"
readonly decoder_checkpoint_v2_io_manifest_dump="$(mktemp "$runner_temp/prime-decoder-checkpoint-v2-io-package-dump.json.XXXXXX")"
readonly decoder_checkpoint_v2_io_execution_manifest_dump="$(mktemp "$runner_temp/prime-decoder-checkpoint-v2-io-execution-package-dump.json.XXXXXX")"
readonly decoder_runtime_closure_manifest_dump="$(mktemp "$runner_temp/prime-decoder-runtime-closure-package-dump.json.XXXXXX")"
readonly decoder_tokenizer_compatibility_manifest_dump="$(mktemp "$runner_temp/prime-decoder-tokenizer-compatibility-package-dump.json.XXXXXX")"
readonly manifest_scratch="$runner_temp/prime-package-dump-build"
readonly manifest_cache="$runner_temp/prime-package-dump-cache"
readonly manifest_config="$runner_temp/prime-package-dump-config"
readonly manifest_security="$runner_temp/prime-package-dump-security"
trap 'unlink "$manifest_dump" "$decoder_manifest_dump" "$decoder_checkpoint_v2_manifest_dump" "$decoder_checkpoint_v2_io_manifest_dump" "$decoder_checkpoint_v2_io_execution_manifest_dump" "$decoder_runtime_closure_manifest_dump" "$decoder_tokenizer_compatibility_manifest_dump" 2>/dev/null || true' EXIT
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
    --package-path "$prime_root/Tests/PrimeNativeDecoderCheckpointV2IOValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_checkpoint_v2_io_manifest_dump"
jq -e \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderCheckpointV2IOValidation"
      and (.dependencies | length) == 1
      and .dependencies[0].fileSystem[0]
          .nameForTargetDependencyResolutionOnly == "ergentics-prime"
      and .dependencies[0].fileSystem[0].path == $prime_root
      and (.targets | length) == 1
      and .targets[0].name == "PrimeNativeDecoderCheckpointV2IOTests"
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
    "$decoder_checkpoint_v2_io_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation manifest changed"

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_checkpoint_v2_io_execution_manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$root_mlx_revision" \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderCheckpointV2IOExecutionValidation"
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
      and (.products | length) == 1
      and .products[0].name
          == "PrimeNativeDecoderCheckpointV2IOExecutionProbe"
      and .products[0].targets
          == ["PrimeNativeDecoderCheckpointV2IOExecutionProbe"]
      and (.products[0].type | keys) == ["executable"]
      and (.targets | length) == 2
      and [.targets[].name] == [
          "PrimeNativeDecoderCheckpointV2IOExecutionProbe",
          "PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests"
      ]
      and [.targets[].type] == ["executable", "test"]
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
      and ([.targets[1].dependencies[].product[0]] == [
          "PrimeCore",
          "PrimeNativeDecoderCheckpoint"
      ])
      and ([.targets[1].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-prime"
      ])
      and (.targets[1].settings | length) == 0
    ' \
    "$decoder_checkpoint_v2_io_execution_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution validation manifest changed"

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

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderTokenizerCompatibilityValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_tokenizer_compatibility_manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$root_mlx_revision" \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderTokenizerCompatibilityValidation"
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
      and (.products | length) == 1
      and .products[0].name
          == "PrimeNativeDecoderTokenizerCompatibilityProbe"
      and .products[0].targets
          == ["PrimeNativeDecoderTokenizerCompatibilityProbe"]
      and (.products[0].type | keys) == ["executable"]
      and (.targets | length) == 2
      and [.targets[].name] == [
          "PrimeNativeDecoderTokenizerCompatibilityProbe",
          "PrimeNativeDecoderTokenizerCompatibilityAuthorityTests"
      ]
      and [.targets[].type] == ["executable", "test"]
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
      and ([.targets[1].dependencies[].product[0]] == ["PrimeCore"])
      and ([.targets[1].dependencies[].product[1]]
          == ["ergentics-prime"])
      and (.targets[1].settings | length) == 0
    ' \
    "$decoder_tokenizer_compatibility_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder tokenizer-compatibility validation manifest changed"

readonly decoder_source="$prime_root/Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
readonly decoder_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderAuthority.swift"
readonly decoder_derived_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderDerivedDelta.swift"
readonly decoder_checkpoint_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift"
readonly decoder_checkpoint_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift"
readonly decoder_checkpoint_v2_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift"
readonly decoder_checkpoint_v2_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift"
readonly decoder_checkpoint_v2_io_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift"
readonly decoder_checkpoint_v2_io_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift"
readonly decoder_checkpoint_v2_io_execution_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift"
readonly decoder_checkpoint_v2_io_execution_evidence_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift"
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
readonly decoder_checkpoint_v2_io_validation_root="$prime_root/Tests/PrimeNativeDecoderCheckpointV2IOValidation"
readonly decoder_checkpoint_v2_io_validation_manifest="$decoder_checkpoint_v2_io_validation_root/Package.swift"
readonly decoder_checkpoint_v2_io_validation_lock="$decoder_checkpoint_v2_io_validation_root/Package.resolved"
readonly decoder_checkpoint_v2_io_validation_test="$decoder_checkpoint_v2_io_validation_root/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift"
readonly decoder_checkpoint_v2_io_execution_validation_root="$prime_root/Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation"
readonly decoder_checkpoint_v2_io_execution_validation_manifest="$decoder_checkpoint_v2_io_execution_validation_root/Package.swift"
readonly decoder_checkpoint_v2_io_execution_validation_lock="$decoder_checkpoint_v2_io_execution_validation_root/Package.resolved"
readonly decoder_checkpoint_v2_io_execution_probe="$decoder_checkpoint_v2_io_execution_validation_root/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift"
readonly decoder_checkpoint_v2_io_execution_test="$decoder_checkpoint_v2_io_execution_validation_root/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift"
readonly decoder_runtime_closure_validation_root="$prime_root/Tests/PrimeNativeDecoderRuntimeClosureValidation"
readonly decoder_runtime_closure_validation_manifest="$decoder_runtime_closure_validation_root/Package.swift"
readonly decoder_runtime_closure_validation_lock="$decoder_runtime_closure_validation_root/Package.resolved"
readonly decoder_runtime_closure_probe="$decoder_runtime_closure_validation_root/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift"
readonly decoder_runtime_closure_test="$decoder_runtime_closure_validation_root/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift"
readonly decoder_tokenizer_compatibility_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift"
readonly decoder_tokenizer_compatibility_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift"
readonly decoder_tokenizer_compatibility_validation_root="$prime_root/Tests/PrimeNativeDecoderTokenizerCompatibilityValidation"
readonly decoder_tokenizer_compatibility_validation_manifest="$decoder_tokenizer_compatibility_validation_root/Package.swift"
readonly decoder_tokenizer_compatibility_validation_lock="$decoder_tokenizer_compatibility_validation_root/Package.resolved"
readonly decoder_tokenizer_compatibility_probe="$decoder_tokenizer_compatibility_validation_root/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift"
readonly decoder_tokenizer_compatibility_test="$decoder_tokenizer_compatibility_validation_root/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift"

[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoder')" \
    == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift" ]] ||
    die "PrimeNativeDecoder production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderCheckpoint')" \
    == $'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift' ]] ||
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
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation')" \
    == $'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved\nTests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift\nTests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift' ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation')" \
    == $'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation')" \
    == $'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved\nTests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder runtime-closure validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation')" \
    == $'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation inventory changed"
[[ ! -e "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" \
    && ! -L "$prime_root/Tests/PrimeNativeDecoderValidation/.swiftpm" ]] ||
    die "PrimeNativeDecoder validation must use the supplied isolated config path"
[[ ! -e "$decoder_checkpoint_v2_validation_root/.swiftpm" \
    && ! -L "$decoder_checkpoint_v2_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder checkpoint V2 validation must use the supplied isolated config path"
[[ ! -e "$decoder_checkpoint_v2_io_validation_root/.swiftpm" \
    && ! -L "$decoder_checkpoint_v2_io_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation must use the supplied isolated config path"
[[ ! -e "$decoder_checkpoint_v2_io_execution_validation_root/.swiftpm" \
    && ! -L "$decoder_checkpoint_v2_io_execution_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution validation must use the supplied isolated config path"
[[ ! -e "$decoder_runtime_closure_validation_root/.swiftpm" \
    && ! -L "$decoder_runtime_closure_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder runtime-closure validation must use the supplied isolated config path"
[[ ! -e "$decoder_tokenizer_compatibility_validation_root/.swiftpm" \
    && ! -L "$decoder_tokenizer_compatibility_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation must use the supplied isolated config path"
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
[[ -f "$decoder_checkpoint_v2_io_source" \
    && ! -L "$decoder_checkpoint_v2_io_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O source is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_authority_source" \
    && ! -L "$decoder_checkpoint_v2_io_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O authority is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_authority_source" \
    && ! -L "$decoder_checkpoint_v2_io_execution_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution authority is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_evidence_source" \
    && ! -L "$decoder_checkpoint_v2_io_execution_evidence_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution evidence is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_test" \
    && ! -L "$decoder_checkpoint_v2_validation_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation test is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_manifest" \
    && ! -L "$decoder_checkpoint_v2_validation_manifest" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation manifest is missing or linked"
[[ -f "$decoder_checkpoint_v2_validation_lock" \
    && ! -L "$decoder_checkpoint_v2_validation_lock" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 validation lock is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_validation_test" \
    && ! -L "$decoder_checkpoint_v2_io_validation_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O validation test is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_validation_manifest" \
    && ! -L "$decoder_checkpoint_v2_io_validation_manifest" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O validation manifest is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_validation_lock" \
    && ! -L "$decoder_checkpoint_v2_io_validation_lock" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O validation lock is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_validation_manifest" \
    && ! -L "$decoder_checkpoint_v2_io_execution_validation_manifest" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution manifest is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_validation_lock" \
    && ! -L "$decoder_checkpoint_v2_io_execution_validation_lock" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution lock is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_probe" \
    && ! -L "$decoder_checkpoint_v2_io_execution_probe" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution probe is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_execution_test" \
    && ! -L "$decoder_checkpoint_v2_io_execution_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution test is missing or linked"
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
[[ -f "$decoder_tokenizer_compatibility_authority_source" \
    && ! -L "$decoder_tokenizer_compatibility_authority_source" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility authority is missing or linked"
[[ -f "$decoder_tokenizer_compatibility_execution_observation_source" \
    && ! -L "$decoder_tokenizer_compatibility_execution_observation_source" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility execution observation is missing or linked"
[[ -f "$decoder_tokenizer_compatibility_validation_manifest" \
    && ! -L "$decoder_tokenizer_compatibility_validation_manifest" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation manifest is missing or linked"
[[ -f "$decoder_tokenizer_compatibility_validation_lock" \
    && ! -L "$decoder_tokenizer_compatibility_validation_lock" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation lock is missing or linked"
[[ -f "$decoder_tokenizer_compatibility_probe" \
    && ! -L "$decoder_tokenizer_compatibility_probe" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility probe is missing or linked"
[[ -f "$decoder_tokenizer_compatibility_test" \
    && ! -L "$decoder_tokenizer_compatibility_test" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility test is missing or linked"
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
for v2_io_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$v2_io_regular_source" | awk '{print $1}')" == "100644" ]] ||
        die "PrimeNativeDecoder checkpoint V2 I/O source mode changed: $v2_io_regular_source"
done
for v2_io_execution_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$v2_io_execution_regular_source" | awk '{print $1}')" == "100644" ]] ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution source mode changed: $v2_io_execution_regular_source"
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
for tokenizer_compatibility_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift' \
    'Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift' \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift' \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift' \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$tokenizer_compatibility_regular_source" | awk '{print $1}')" \
        == "100644" ]] ||
        die "PrimeNativeDecoder tokenizer-compatibility source mode changed: $tokenizer_compatibility_regular_source"
done

assert_checkpoint_v2_io_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "checkpoint V2 I/O identity source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "checkpoint V2 I/O identity source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "checkpoint V2 I/O identity source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "checkpoint V2 I/O identity source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "checkpoint V2 I/O identity source SHA-256 changed: $relative_path"
}

assert_checkpoint_v2_io_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift' \
    '100644' \
    'f0d010959aaf20fddb755aec7a1b61550dec93dd' \
    '40522' \
    '8d3626aacfce1fd0350b79872b829df4322695981eaebcf88bc4f38ec2973880'
assert_checkpoint_v2_io_source_identity \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift' \
    '100644' \
    '105af3f93acf9358e7b66c3a327e45a931deab8b' \
    '54880' \
    '39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d'
assert_checkpoint_v2_io_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift' \
    '100644' \
    '0a371f2fec33db3fe42d425674e2fd2539927eb7' \
    '737' \
    'f4b7232483671d73f1b73796d3bff738ea2e3c3f286370ffc1f7e53b2697a8f9'
assert_checkpoint_v2_io_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved' \
    '100644' \
    'd5621ea4139fee6cc1fc39e03512ea4c1b009b5f' \
    '645' \
    '8effb57587a4ec226d390bef418324d6dcef4491905bc88e341e1c64f72d043f'
assert_checkpoint_v2_io_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift' \
    '100644' \
    '74129e24c11a742adb11a80a8e454924426c63ee' \
    '18388' \
    'f910ae77c7ea54d67f751902168b278bd6a45a5c2deb45618c5f0cb0b6952376'

assert_checkpoint_v2_io_execution_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "checkpoint V2 I/O execution source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "checkpoint V2 I/O execution source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "checkpoint V2 I/O execution source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "checkpoint V2 I/O execution source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "checkpoint V2 I/O execution source SHA-256 changed: $relative_path"
}

assert_checkpoint_v2_io_execution_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift' \
    '100644' \
    'f82bd280fd1c269ce6a6e0392a8849630d0af124' \
    '60654' \
    'd56febe490f6a774028c1bc1567f907f18b0f5591b78a24ad0ff0fe6947be62f'
assert_checkpoint_v2_io_execution_source_identity \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift' \
    '100644' \
    '416423e41a072ab323a345a12782ac54faac57d8' \
    '52898' \
    'bc5dc07a60dc2b3642bd5440857d32345a36b128283e0c200deb15889d388544'
assert_checkpoint_v2_io_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift' \
    '100644' \
    '233ab6e0a2c747ca2166a3ad0a8841ddd83a24b6' \
    '2136' \
    'cfcde7c6ebf00a2aabe26aa1b4417a3cc5e7d4caf771fbd32cc7a2637be5d2b1'
assert_checkpoint_v2_io_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved' \
    '100644' \
    '9887e211ac39cdf8083419ba144f2ca26ffc44cd' \
    '645' \
    '538966e5f400f66e786b2946e4267ccf41e92ef4077a29c2358413792640e5b6'
assert_checkpoint_v2_io_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift' \
    '100644' \
    '71262c7794e5d47e0d8990346a0e6682f4fcd09b' \
    '40914' \
    'a1a768c17e6fcb510b75468b81309863712cd3f07dc7dc4f41ba559f27d9fad9'
assert_checkpoint_v2_io_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift' \
    '100644' \
    '8b1c18b57c70dda967885c2737d0d4170c7e417a' \
    '27448' \
    '869db27f80824cfa0a6420efac62237c389cbed692c3f119f47f07c5ff68db6f'
assert_checkpoint_v2_io_execution_source_identity \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh' \
    '100755' \
    '0683f4bfba4dc7929e4c397a499132f859a80b0e' \
    '60125' \
    '824fe36fcb6e0707650868e1fbfc1bb67cf6ccace7a9c0ea21a60bead27bbe07'

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

assert_tokenizer_compatibility_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "tokenizer-compatibility identity source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "tokenizer-compatibility identity source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "tokenizer-compatibility identity source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "tokenizer-compatibility identity source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "tokenizer-compatibility identity source SHA-256 changed: $relative_path"
}

assert_tokenizer_compatibility_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift' \
    '100644' \
    'a14d52e2af3dee3c39d8bb6cb017995cf3a4aa0c' \
    '66000' \
    '0ff6ee0e74176d6b059c9f97932301ecc3f62f8c3ea23103b69952b1eaad4efe'
assert_tokenizer_compatibility_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift' \
    '100644' \
    '92bc5e2f1e802c37d2b3b6ac07c6b60ce483328c' \
    '48237' \
    '62eb03797435a40b7c3265b2d9886f58b1b9a5be3f7759804daa6b1bcf2e94a4'
assert_tokenizer_compatibility_source_identity \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift' \
    '100644' \
    'da9785a7263522541a81fd39c34acc2512d87100' \
    '1981' \
    '8edbfc6aacb66fb90399c1812afb2877f9ea13356f71612271382db10c63e86a'
assert_tokenizer_compatibility_source_identity \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved' \
    '100644' \
    '6f080d562484a13a45194d430c395f8a3b64a0bd' \
    '645' \
    'd1e5dfc20834ce54f02d65630ff58bbcc39592fa34d81bc209c45aa4776fa4d4'
assert_tokenizer_compatibility_source_identity \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift' \
    '100644' \
    '3a5d77e0e874a082a0e8d3a8352de0f41b34010b' \
    '33171' \
    '46d46b739770484e55be23d9df8d699d1caa26584b4724db6f686dc637a578f1'
assert_tokenizer_compatibility_source_identity \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift' \
    '100644' \
    'd8c696981633bceae281e681b9f33ef0d5ca6141' \
    '20790' \
    '43fb10b7af7936bca680e6e1377a4f94616049a26aec8fae45e097d805b3588f'
assert_tokenizer_compatibility_source_identity \
    '.github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh' \
    '100755' \
    'b12d52802e7f24be7a905ae0cbceeed945fcc11a' \
    '33174' \
    '0c70d3cd538e297cf629707a51bcc8ede87b42e488369ffd321ac3c44062f06a'
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
swiftc -frontend -parse "$decoder_checkpoint_v2_io_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_evidence_source"
swiftc -frontend -parse "$decoder_checkpoint_authority_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_authority_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_authority_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_authority_source"
swiftc -frontend -parse "$decoder_runtime_authority_source"
swiftc -frontend -parse "$decoder_runtime_execution_observation_source"
swiftc -frontend -parse "$decoder_runtime_source"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_authority_source"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_execution_observation_source"
swiftc -frontend -parse "$decoder_metal_repair_authority_source"
swiftc -frontend -parse "$decoder_metal_execution_observation_source"
swiftc -frontend -parse "$decoder_metal_execution_correction_source"
swiftc -frontend -parse "$decoder_gate_repair_execution_observation_source"
swiftc -frontend -parse "$decoder_reviewed_main_metal_execution_observation_source"
swiftc -frontend -parse "$decoder_authority_test"
swiftc -frontend -parse "$decoder_checkpoint_test"
swiftc -frontend -parse "$decoder_validation_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_validation_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_validation_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_probe"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_test"
swiftc -frontend -parse "$decoder_runtime_closure_probe"
swiftc -frontend -parse "$decoder_runtime_closure_test"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_probe"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_test"

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
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_authority_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O authority imports changed"
[[ "$(awk '/^import / {print $2}' "$decoder_checkpoint_v2_io_source" | paste -sd, -)" \
    == "Darwin,Foundation,MLX,MLXNN,PrimeCore,PrimeNativeDecoder" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_validation_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O validation imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_authority_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution authority imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_evidence_source" | paste -sd, -)" \
    == "Foundation,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution evidence imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_probe" | paste -sd, -)" \
    == "CoreGraphics,Darwin,Foundation,Metal,MLX,MLXNN,PrimeCore,PrimeNativeDecoder,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution probe imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution test imports changed"
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
[[ "$(awk '/^import / {print $2}' \
    "$decoder_tokenizer_compatibility_authority_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility authority imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_tokenizer_compatibility_execution_observation_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility execution observation imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_tokenizer_compatibility_probe" | paste -sd, -)" \
    == "CoreGraphics,Darwin,Foundation,Metal,MLX,MLXNN,PrimeCore,PrimeNativeDecoder,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility probe imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_tokenizer_compatibility_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,PrimeCore,XCTest" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility test imports changed"
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
[[ "$(grep -Fc -- '.package(' "$decoder_checkpoint_v2_io_validation_manifest")" \
    == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation gained an unexpected dependency"
grep -Fq -- 'name: "PrimeCore"' \
    "$decoder_checkpoint_v2_io_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation does not consume PrimeCore"
grep -Fq -- 'name: "PrimeNativeDecoderCheckpoint"' \
    "$decoder_checkpoint_v2_io_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation does not consume the checkpoint product"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_checkpoint_v2_io_validation_test")" == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O validation test count changed"
[[ "$(grep -Fc -- '.package(' \
    "$decoder_checkpoint_v2_io_execution_validation_manifest")" == "2" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution dependency count changed"
for required_checkpoint_v2_io_execution_product in \
    'name: "PrimeCore"' \
    'name: "PrimeNativeDecoder"' \
    'name: "PrimeNativeDecoderCheckpoint"' \
    'name: "MLX"' \
    'name: "MLXNN"'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_product" \
        "$decoder_checkpoint_v2_io_execution_validation_manifest" ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution manifest is missing: $required_checkpoint_v2_io_execution_product"
done
grep -Fq -- "$root_mlx_revision" \
    "$decoder_checkpoint_v2_io_execution_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution manifest does not pin active MLX"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_checkpoint_v2_io_execution_test")" == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution test count changed"
for required_checkpoint_v2_io_execution_probe_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1' \
    '.validateLaunchedCurrentProcess()' \
    'PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()' \
    'let model = PrimeNativeGQADecoder.make(' \
    'model.train(false)' \
    'try checkedEval(model)' \
    '.writeNative300MByte512(' \
    '.loadNative300MByte512(' \
    'try artifactRoot.requirePrivateRootMode()' \
    'try artifactRoot.requireEmpty()' \
    'artifactRoot.verifiedRootIdentity()' \
    'availableImmediatelyBeforeWrite' \
    'try inspectLoadedModelStructure(' \
    'loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec:' \
    'writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn:' \
    'artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot:' \
    'try evidence.validate()' \
    'try evidence.canonicalReceiptData()' \
    'receipt.base64EncodedString()' \
    'receiptChunkCharacterCount' \
    'receiptChunkOrdinalWidth' \
    'print(beginLine)' \
    'print(endLine)'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_probe_value" \
        "$decoder_checkpoint_v2_io_execution_probe" ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution probe lost: $required_checkpoint_v2_io_execution_probe_value"
done
[[ "$(grep -Fc -- 'let model = PrimeNativeGQADecoder.make(' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- 'model.train(false)' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- 'try checkedEval(model)' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- '.writeNative300MByte512(' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- '.loadNative300MByte512(' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- 'Memory.clearCache()' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "2" \
    && "$(grep -Fc -- 'artifactRoot.verifiedRootIdentity()' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "3" \
    && "$(grep -Fc -- 'PrimeArtifactRoot(directoryURL:' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- 'try Device.withDefaultDevice(gpu)' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" \
    && "$(grep -Fc -- 'try withError {' \
        "$decoder_checkpoint_v2_io_execution_probe")" == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O probe execution count changed"
for forbidden_checkpoint_v2_io_execution_probe_value in \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'MLXLLM' \
    'MLXOptimizers' \
    'ObjectIdentifier' \
    '.forward(' \
    'asArray(' \
    'artifactRoot.verify(' \
    'root.verify(' \
    'URLSession' \
    'FileHandle' \
    'Data(contentsOf:' \
    'write(to:' \
    'posix_spawn' \
    'execve(' \
    'unlink(' \
    'rename(' \
    'retry'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_probe_value" \
        "$decoder_checkpoint_v2_io_execution_probe"; then
        die "PrimeNativeDecoder checkpoint V2 I/O execution probe contains forbidden value: $forbidden_checkpoint_v2_io_execution_probe_value"
    fi
done
if grep -Eq -- \
    '(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)' \
    "$decoder_checkpoint_v2_io_execution_probe"; then
    die "PrimeNativeDecoder checkpoint V2 I/O execution probe contains standalone Process"
fi

readonly checkpoint_v2_io_probe_environment_lines="$(grep -nF -- \
    '.validateLaunchedCurrentProcess()' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_environment_first="$(printf '%s\n' \
    "$checkpoint_v2_io_probe_environment_lines" | awk 'NR == 1')"
readonly checkpoint_v2_io_probe_host_guard_line="$(grep -nF -- \
    'executionRepository == authority.authoritativeRepository,' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_root_line="$(grep -nF -- \
    'let artifactRoot = try PrimeArtifactRoot(directoryURL:' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_framework_line="$(grep -nF -- \
    'let colorSpace = CGColorSpaceCreateDeviceRGB()' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_cache_lines="$(grep -nF -- \
    'Memory.clearCache()' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_cache_first="$(printf '%s\n' \
    "$checkpoint_v2_io_probe_cache_lines" | awk 'NR == 1')"
readonly checkpoint_v2_io_probe_cache_second="$(printf '%s\n' \
    "$checkpoint_v2_io_probe_cache_lines" | awk 'NR == 2')"
readonly checkpoint_v2_io_probe_write_line="$(grep -nF -- \
    'let binding = try writeCallerSourceModel(' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_load_line="$(grep -nF -- \
    'let structure = try loadAndInspectStructure(' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_evidence_line="$(grep -nF -- \
    'try evidence.validate()' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_probe_receipt_line="$(grep -nF -- \
    'try emitChunkedReceipt(evidence)' \
    "$decoder_checkpoint_v2_io_execution_probe" | awk -F: '{print $1}')"
[[ "$checkpoint_v2_io_probe_environment_first" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_host_guard_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_root_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_framework_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_cache_first" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_write_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_cache_second" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_load_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_evidence_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_receipt_line" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_probe_environment_first" -lt "$checkpoint_v2_io_probe_host_guard_line" \
    && "$checkpoint_v2_io_probe_host_guard_line" -lt "$checkpoint_v2_io_probe_root_line" \
    && "$checkpoint_v2_io_probe_root_line" -lt "$checkpoint_v2_io_probe_framework_line" \
    && "$checkpoint_v2_io_probe_framework_line" -lt "$checkpoint_v2_io_probe_cache_first" \
    && "$checkpoint_v2_io_probe_cache_first" -lt "$checkpoint_v2_io_probe_write_line" \
    && "$checkpoint_v2_io_probe_write_line" -lt "$checkpoint_v2_io_probe_cache_second" \
    && "$checkpoint_v2_io_probe_cache_second" -lt "$checkpoint_v2_io_probe_load_line" \
    && "$checkpoint_v2_io_probe_load_line" -lt "$checkpoint_v2_io_probe_evidence_line" \
    && "$checkpoint_v2_io_probe_evidence_line" -lt "$checkpoint_v2_io_probe_receipt_line" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O probe execution order changed"

for required_checkpoint_v2_io_execution_test_value in \
    'func testExecutionAuthorityEvidenceAndTransportAreExactAndPure()' \
    '"PINNED_AFTER_SOURCE_STABILIZATION"' \
    'XCTAssertEqual(authority.newExecutionSourceBindings.count, 6)' \
    'let expectedNewExecutionPaths = [' \
    'XCTAssertGreaterThan(chunkCount, 1)' \
    'XCTAssertLessThanOrEqual(chunkCount, 86)' \
    '.decodeCanonicalReceipt(from: receipt)' \
    '.decodeCanonicalReceipt(from: nonCanonicalReceipt)' \
    'for key in authorityBooleanKeys {' \
    'func assertAuthoritySourceBindingMutation(' \
    'try assertAuthoritySourceBindingMutation("reorder")' \
    'for key in evidenceBooleanKeys {' \
    'func assertEvidenceMutation(' \
    'try assertEvidenceMutation("parent order")'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_test_value" \
        "$decoder_checkpoint_v2_io_execution_test" ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution test lost: $required_checkpoint_v2_io_execution_test_value"
done
for forbidden_checkpoint_v2_io_execution_test_value in \
    'PrimeNativeGQADecoder.make(' \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    'PrimeArtifactRoot(' \
    'Memory.clearCache()' \
    'import MLX' \
    'import Metal' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_test_value" \
        "$decoder_checkpoint_v2_io_execution_test"; then
        die "PrimeNativeDecoder checkpoint V2 I/O execution test gained execution capability: $forbidden_checkpoint_v2_io_execution_test_value"
    fi
done

for required_checkpoint_v2_io_execution_authority_value in \
    'public struct' \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1:' \
    '"ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_authority_v1"' \
    '"b861fa8270cbdceefd6079f7e09fece495fc4b79"' \
    '"PINNED_AFTER_SOURCE_STABILIZATION"' \
    'newExecutionSourceBindings.count == 6,' \
    '"Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift"' \
    '"Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift"' \
    '"Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved"' \
    '"Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift"' \
    '"Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift"' \
    '".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh"' \
    'requiredExecutedCommitParentCount: 2,' \
    'directSuccessorValidationRequiredBeforeDeletionBuildOrModel: true,' \
    'localOrManualExecutionAuthorized: false,' \
    'rerunExecutionAuthorized: false,' \
    'laterMainExecutionAuthorized: false,' \
    'receiptChunkCharacterCount: 4_096,' \
    'receiptChunkOrdinalWidth: 6,' \
    'maximumReceiptChunkCount: 86,' \
    'maximumCanonicalReceiptByteCount: 262_144,' \
    'receiptBeginLineCount: 1,' \
    'receiptEndLineCount: 1,' \
    'supervisorPostReceiptIndependentWholeFileHashAuthorized: false,' \
    'supervisorPostReceiptArtifactRootVerifyAuthorized: false,' \
    'supervisorCleanupUnlinkCount: 1,' \
    'supervisorCleanupRmdirCount: 1,' \
    'supervisorCleanupRecursiveDeletionAuthorized: false,' \
    'processExitRequiredAfterReceipt: true,' \
    'parentReceiptVerificationRequiredBeforeArtifactCleanup: true,' \
    'artifactAndRootCleanupRequiredAfterParentVerification: true,' \
    'workflowCommandListExtensionAuthorized: true,' \
    'workflowTopologyMutationAuthorized: false,' \
    'workflowJobInventoryMutationAuthorized: false,' \
    'workflowStepInventoryMutationAuthorized: false,' \
    'workflowRunnerMutationAuthorized: false,' \
    'workflowExecutionOrderMutationAuthorized: false,' \
    'reviewedMainTimeoutBeforeMinutes: 45,' \
    'reviewedMainTimeoutAfterMinutes: 90,' \
    'reviewedMainCheckoutFetchDepthBefore: 1,' \
    'reviewedMainCheckoutFetchDepthDuringExecution: 2,' \
    'reviewedMainCheckoutFetchDepthAfterObservation: 1,' \
    'native300MModelAllocationAuthorized: true,' \
    'native300MCheckpointWriteAuthorized: true,' \
    'native300MCheckpointLoadAuthorized: true,' \
    'checkpointArtifactRetentionAuthorized: false,' \
    'checkpointArtifactUploadAuthorized: false,' \
    'checkpointArtifactAdmissionAuthorized: false,' \
    'decoderForwardAuthorized: false,' \
    'backwardAuthorized: false,' \
    'generationAuthorized: false,' \
    'trainingAuthorized: false,' \
    'native300MCheckpointWriteObserved: false,' \
    'native300MCheckpointLoadObserved: false,' \
    'checkpointIOObserved: false,' \
    'checkpointContainerHashBound: false,' \
    '"ABSTAIN_exact_seed42_native300m_v2_checkpoint_one_write_one_load_authorized_not_observed_no_artifact_admission"'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_authority_value" \
        "$decoder_checkpoint_v2_io_execution_authority_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution authority lost: $required_checkpoint_v2_io_execution_authority_value"
done
for forbidden_checkpoint_v2_io_execution_authority_capability in \
    'FileManager' \
    'FileHandle' \
    'URL(' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'PrimeArtifactRoot(' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    'import MLX' \
    'import Metal' \
    'Process()'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_authority_capability" \
        "$decoder_checkpoint_v2_io_execution_authority_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O execution authority owns forbidden capability: $forbidden_checkpoint_v2_io_execution_authority_capability"
    fi
done

for required_checkpoint_v2_io_execution_evidence_value in \
    'public struct' \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1:' \
    'try externalBinding.validate()' \
    'try externalBinding.manifest.compatibilityIdentity.validate()' \
    'public func canonicalReceiptData() throws -> Data {' \
    'public static func decodeCanonicalReceipt(' \
    'maximumCanonicalReceiptByteCount' \
    'private var positiveClaimsAreExact: Bool {' \
    'native300MCheckpointWriteObserved' \
    'native300MCheckpointLoadObserved' \
    'checkpointArtifactAvailableDuringProcess' \
    'logicalParameterRoundTripViaPinnedCodecObserved' \
    'private var falseCeilingsAreExact: Bool {' \
    '!independentPostLoadTensorHashReplayObserved' \
    '!independentPostLoadArtifactRootVerifyObserved' \
    '!artifactUploadInvokedBeforeReceipt' \
    '!checkpointArtifactRetentionEstablished' \
    '!checkpointAdmissionGranted' \
    '!checkpointLoadedForwardObserved' \
    '!backwardInvoked' \
    '!generationInvoked' \
    '!trainingExecutionObserved' \
    '!productUseAuthorized' \
    '!publicationAuthorized' \
    '!retryObserved'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_evidence_value" \
        "$decoder_checkpoint_v2_io_execution_evidence_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution evidence lost: $required_checkpoint_v2_io_execution_evidence_value"
done
for forbidden_checkpoint_v2_io_execution_evidence_capability in \
    'FileManager' \
    'FileHandle' \
    'URL(' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'PrimeArtifactRoot(' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    'import MLX' \
    'import Metal' \
    'Process()'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_evidence_capability" \
        "$decoder_checkpoint_v2_io_execution_evidence_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O execution evidence owns forbidden capability: $forbidden_checkpoint_v2_io_execution_evidence_capability"
    fi
done

for required_checkpoint_v2_io_authority_value in \
    'native300MCheckpointWriteExecutionAuthorized: true,' \
    'native300MCheckpointLoadExecutionAuthorized: true,' \
    'native300MCheckpointWriteObserved: false,' \
    'native300MCheckpointLoadObserved: false,' \
    'checkpointIOObserved: false,' \
    'checkpointArtifactAvailable: false,' \
    'checkpointContainerHashBound: false,' \
    'checkpointAdmissionGranted: false,' \
    'workflowCommandListExtensionAuthorized: true,' \
    'workflowTopologyMutationAuthorized: false,' \
    'publicationAuthorized: false,' \
    'ABSTAIN_v2_checkpoint_artifact_root_manifest_container_codec_io_implemented_native_write_load_authorized_not_observed_no_artifact_admission'; do
    grep -Fq -- "$required_checkpoint_v2_io_authority_value" \
        "$decoder_checkpoint_v2_io_authority_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O authority lost: $required_checkpoint_v2_io_authority_value"
done
for forbidden_checkpoint_v2_io_authority_capability in \
    'FileManager' \
    'FileHandle' \
    'URL(' \
    'Data(contentsOf:' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'Process'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_authority_capability" \
        "$decoder_checkpoint_v2_io_authority_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O authority owns forbidden capability: $forbidden_checkpoint_v2_io_authority_capability"
    fi
done
for required_checkpoint_v2_io_implementation_value in \
    'public struct PrimeNativeDecoderCheckpointManifestV2' \
    'public struct PrimeNativeDecoderCheckpointExternalBindingV2' \
    'public enum PrimeNativeDecoderCheckpointCodecV2' \
    'public static func writeNative300MByte512(' \
    'public static func loadNative300MByte512(' \
    'PrimeArtifactRoot' \
    'publishGeneratedFile(' \
    'withVerifiedArtifactDescriptor(' \
    'MLX.save(' \
    'MLX.loadArraysAndMetadata(' \
    'validateRawSafetensorsLayout(' \
    'PrimeV2SafetensorsHeaderParser' \
    'maximumBytes:'; do
    grep -Fq -- "$required_checkpoint_v2_io_implementation_value" \
        "$decoder_checkpoint_v2_io_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O implementation lost: $required_checkpoint_v2_io_implementation_value"
done
for exact_checkpoint_v2_io_implementation_value in \
    'public static func writeNative300MByte512(' \
    'public static func loadNative300MByte512(' \
    'publishGeneratedFile(' \
    'withVerifiedArtifactDescriptor(' \
    'MLX.save(' \
    'MLX.loadArraysAndMetadata('; do
    [[ "$(grep -Fc -- "$exact_checkpoint_v2_io_implementation_value" \
        "$decoder_checkpoint_v2_io_source")" == "1" ]] ||
        die "PrimeNativeDecoder checkpoint V2 I/O capability count changed: $exact_checkpoint_v2_io_implementation_value"
done
for forbidden_checkpoint_v2_io_implementation_capability in \
    'FileManager' \
    'FileHandle' \
    'URL(fileURLWithPath:' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'unlink(' \
    'rename('; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_implementation_capability" \
        "$decoder_checkpoint_v2_io_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O implementation owns forbidden capability: $forbidden_checkpoint_v2_io_implementation_capability"
    fi
done
if awk '
    /^[[:space:]]*public / && /fileDescriptor|FileHandle|URL/ { found = 1 }
    END { exit(found ? 0 : 1) }
' "$decoder_checkpoint_v2_io_source"; then
    die "PrimeNativeDecoder checkpoint V2 I/O public surface exposes a raw filesystem primitive"
fi
for required_checkpoint_v2_io_test_value in \
    'func testArtifactRootBackedV2SchemasAndAuthorityFailClosed() throws {' \
    'XCTAssertEqual(tensorBindings.count, 218)' \
    'XCTAssertEqual(authorityBooleanKeys.count, 101)' \
    'XCTAssertThrowsError(' \
    'let implementationData = try Data(contentsOf: implementationURL)' \
    'PrimeSHA256.hexDigest(of: implementationData)' \
    'implementation.contains(required)' \
    'implementation.contains(forbidden)'; do
    grep -Fq -- "$required_checkpoint_v2_io_test_value" \
        "$decoder_checkpoint_v2_io_validation_test" ||
        die "PrimeNativeDecoder checkpoint V2 I/O declarative test lost: $required_checkpoint_v2_io_test_value"
done
for forbidden_checkpoint_v2_io_test_execution in \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeArtifactRoot('; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_test_execution" \
        "$decoder_checkpoint_v2_io_validation_test"; then
        die "PrimeNativeDecoder checkpoint V2 I/O declarative test gained execution capability: $forbidden_checkpoint_v2_io_test_execution"
    fi
done
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
[[ "$(grep -Fc -- '.package(' \
    "$decoder_tokenizer_compatibility_validation_manifest")" == "2" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation dependency count changed"
for required_tokenizer_compatibility_product in \
    'name: "PrimeCore"' \
    'name: "PrimeNativeDecoder"' \
    'name: "PrimeNativeDecoderCheckpoint"' \
    'name: "MLX"' \
    'name: "MLXNN"'; do
    grep -Fq -- "$required_tokenizer_compatibility_product" \
        "$decoder_tokenizer_compatibility_validation_manifest" ||
        die "PrimeNativeDecoder tokenizer-compatibility validation is missing: $required_tokenizer_compatibility_product"
done
grep -Fq -- "$root_mlx_revision" \
    "$decoder_tokenizer_compatibility_validation_manifest" ||
    die "PrimeNativeDecoder tokenizer-compatibility validation does not pin active MLX"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_tokenizer_compatibility_test")" == "1" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation test count changed"
for required_tokenizer_compatibility_test_value in \
    'let paths = leafPaths(in: object)' \
    'for path in paths {' \
    'let evidenceBooleanPaths = try leafPaths(in: evidenceObject)' \
    'for path in evidenceBooleanPaths {' \
    'XCTAssertThrowsError(' \
    'try evidenceReplay.validate()'; do
    grep -Fq -- "$required_tokenizer_compatibility_test_value" \
        "$decoder_tokenizer_compatibility_test" ||
        die "PrimeNativeDecoder tokenizer-compatibility mutation test is missing: $required_tokenizer_compatibility_test_value"
done

[[ "$(grep -Fc -- 'Memory.clearCache()' \
    "$decoder_tokenizer_compatibility_probe")" == "4" \
    && "$(grep -Fc -- 'let model = PrimeNativeGQADecoder.make(' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'model.train(false)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'try checkedEval(model)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'let catalog = try liveCatalog(' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'let logits = try model.forward(tokenIDs: tokenIDs)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'try checkedEval(logits)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'let values = logits.asArray(Float.self)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'try Device.withDefaultDevice(gpu)' \
        "$decoder_tokenizer_compatibility_probe")" == "1" \
    && "$(grep -Fc -- 'try withError {' \
        "$decoder_tokenizer_compatibility_probe")" == "1" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility execution capability count changed"

readonly tokenizer_clear_lines="$(grep -nF -- 'Memory.clearCache()' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_clear_1="$(printf '%s\n' "$tokenizer_clear_lines" | awk 'NR == 1')"
readonly tokenizer_clear_2="$(printf '%s\n' "$tokenizer_clear_lines" | awk 'NR == 2')"
readonly tokenizer_clear_3="$(printf '%s\n' "$tokenizer_clear_lines" | awk 'NR == 3')"
readonly tokenizer_clear_4="$(printf '%s\n' "$tokenizer_clear_lines" | awk 'NR == 4')"
readonly tokenizer_make_line="$(grep -nF -- \
    'let model = PrimeNativeGQADecoder.make(' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_train_line="$(grep -nF -- 'model.train(false)' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_model_eval_line="$(grep -nF -- 'try checkedEval(model)' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_catalog_line="$(grep -nF -- \
    'let catalog = try liveCatalog(' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_forward_line="$(grep -nF -- \
    'let logits = try model.forward(tokenIDs: tokenIDs)' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_logits_eval_line="$(grep -nF -- 'try checkedEval(logits)' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
readonly tokenizer_readback_line="$(grep -nF -- \
    'let values = logits.asArray(Float.self)' \
    "$decoder_tokenizer_compatibility_probe" | awk -F: '{print $1}')"
[[ "$tokenizer_clear_1" -lt "$tokenizer_make_line" \
    && "$tokenizer_make_line" -lt "$tokenizer_train_line" \
    && "$tokenizer_train_line" -lt "$tokenizer_model_eval_line" \
    && "$tokenizer_model_eval_line" -lt "$tokenizer_clear_2" \
    && "$tokenizer_clear_2" -lt "$tokenizer_catalog_line" \
    && "$tokenizer_catalog_line" -lt "$tokenizer_forward_line" \
    && "$tokenizer_forward_line" -lt "$tokenizer_clear_3" \
    && "$tokenizer_clear_3" -lt "$tokenizer_logits_eval_line" \
    && "$tokenizer_logits_eval_line" -lt "$tokenizer_readback_line" \
    && "$tokenizer_readback_line" -lt "$tokenizer_clear_4" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility evaluation order changed"

for forbidden_tokenizer_compatibility_source_value in \
    'MLXLLM' \
    'MLXOptimizers' \
    'PMHNP' \
    'DriverV2' \
    'Geometry' \
    'RenderKit' \
    'PrimeNativeDecoderCheckpointManifestV1' \
    'PrimeNativeDecoderCheckpointCodecV1' \
    'writeNative300MByte512' \
    'loadNative300MByte512' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'FileHandle' \
    'Data(contentsOf:' \
    'write(to:' \
    'contentsOfDirectory'; do
    if grep -Fq -- "$forbidden_tokenizer_compatibility_source_value" \
        "$decoder_tokenizer_compatibility_authority_source" \
        "$decoder_tokenizer_compatibility_execution_observation_source" \
        "$decoder_tokenizer_compatibility_probe" \
        "$decoder_tokenizer_compatibility_test"; then
        die "PrimeNativeDecoder tokenizer compatibility contains forbidden capability: $forbidden_tokenizer_compatibility_source_value"
    fi
done
if grep -Eq -- \
    '(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)' \
    "$decoder_tokenizer_compatibility_authority_source" \
    "$decoder_tokenizer_compatibility_execution_observation_source" \
    "$decoder_tokenizer_compatibility_probe" \
    "$decoder_tokenizer_compatibility_test"; then
    die "PrimeNativeDecoder tokenizer compatibility contains forbidden value: Process"
fi

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

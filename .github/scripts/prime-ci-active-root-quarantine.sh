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
readonly decoder_stage2_metallib_bootstrap_repair_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"
readonly decoder_stage3_tiny_cpu_resume_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh"
readonly decoder_checkpoint_v2_io_execution_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh"
readonly decoder_checkpoint_v2_io_root_identity_repair_gate_path="$prime_root/.github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh"

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
    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift" \
    "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"
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
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift" \
    "f82bd280fd1c269ce6a6e0392a8849630d0af124"
require_preserved_object \
    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift" \
    "416423e41a072ab323a345a12782ac54faac57d8"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift" \
    "233ab6e0a2c747ca2166a3ad0a8841ddd83a24b6"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved" \
    "9887e211ac39cdf8083419ba144f2ca26ffc44cd"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift" \
    "71262c7794e5d47e0d8990346a0e6682f4fcd09b"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift" \
    "8b1c18b57c70dda967885c2737d0d4170c7e417a"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh" \
    "0683f4bfba4dc7929e4c397a499132f859a80b0e"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservation.swift" \
    "ab6212e0499ae7aaa1da2cc66be8b67026f504c1"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift" \
    "0ed3aa83f0dc16b0893655b9582985947509b919"
require_preserved_object \
    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift" \
    "244328c77fd20fb0338453e8d0ce9818e3470903"
require_preserved_object \
    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift" \
    "6edb77813df76adb8d7c84d8faf451e325634433"
require_preserved_object \
    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservation.swift" \
    "2e79695501fea9ce8ebbcf713a037a6190676f88"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift" \
    "1cc830db123defbf6a8c0f1362d6d2bb9d754d34"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved" \
    "315cda0e2afccd6fd0acac96e6a0b9bf76afbeca"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift" \
    "61f029352f7a27fa95b4a7b7238d58f1db834387"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift" \
    "8a7bbb1c147555a04e77937eda47b9938c6f742d"
require_preserved_object \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests.swift" \
    "afed0e75e6da05475e2d3decce058d81072c2b6a"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh" \
    "ed7852704219f61bc29841641257da697389458c"
require_preserved_object \
    "Sources/PrimeCore/PrimeMLXRuntimeEnvironmentPolicy.swift" \
    "302718448a233695f57eb9bf508a56f0790a778b"
require_preserved_object \
    ".github/scripts/prime-ci-native-decoder-metal.sh" \
    "418d2d2753cee38e0b3558ad45e1e09865ffd11d"
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
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift" \
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
    "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved" \
    "Tests/PrimeNativeDecoderTrainingValidation/Package.swift" \
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
    "--insecure" \
    "actions/upload-artifact" \
    "GIT_SSL_NO_VERIFY" \
    "http.sslCAInfo" \
    "http.sslVerify" \
    "self-hosted" \
    "xlarge" \
    "pmhnp-companion-ergentics" \
    "PRIME_PMHNP_COMPANION_ROOT"; do
    if grep -Fq -- "$forbidden_workflow_value" "$workflow_path"; then
        die "hosted quarantine workflow contains forbidden value: $forbidden_workflow_value"
    fi
done
emit_secure_dependency_fetch_block() {
    awk '
    /^      - name: Fetch the exact private dependency without evaluating Prime$/ {
        inside = 1
    }
    inside && /^      - name: Compile and run the focused contracts without a credential$/ {
        exit
    }
    inside { print }
' "$workflow_path"
}
readonly secure_dependency_fetch_block="$(emit_secure_dependency_fetch_block)"
readonly secure_dependency_fetch_block_sha256="$(
    emit_secure_dependency_fetch_block | shasum -a 256 | awk '{print $1}'
)"
[[ "$secure_dependency_fetch_block_sha256" \
    == "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847" ]] ||
    die "secure private-dependency fetch block changed"
for forbidden_secure_fetch_value in \
    '--insecure' \
    'GIT_SSL_NO_VERIFY' \
    'http.sslCAInfo' \
    'http.sslVerify' \
    'retry'; do
    if grep -Fq -- "$forbidden_secure_fetch_value" \
        <<< "$secure_dependency_fetch_block"; then
        die "secure private-dependency fetch gained a TLS bypass or retry: $forbidden_secure_fetch_value"
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
    ' "$workflow_path")" == "60" ]] ||
    die "hosted quarantine workflow runner or timeout boundary changed"
[[ "$(grep -Fxc -- \
    '          git -C ergentics-prime fetch --depth=1 --no-tags --no-write-fetch-head origin "$EXACT_REVISION"' \
    "$workflow_path")" == "2" \
    && "$(grep -Fxc -- \
        "    if: github.event_name == 'push' && github.ref == 'refs/heads/main'" \
        "$workflow_path")" == "1" ]] ||
    die "hosted quarantine workflow depth-one boundary changed"
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
[[ -f "$decoder_stage2_metallib_bootstrap_repair_gate_path" \
    && ! -L "$decoder_stage2_metallib_bootstrap_repair_gate_path" ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- \
    '.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh')" \
    == '.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh' ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate is not tracked exactly"
bash -n "$decoder_stage2_metallib_bootstrap_repair_gate_path" ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate is not valid Bash"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate mode changed"
[[ "$(wc -c < "$decoder_stage2_metallib_bootstrap_repair_gate_path" | awk '{print $1}')" \
    == "53660" ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate byte count changed"
[[ "$(shasum -a 256 "$decoder_stage2_metallib_bootstrap_repair_gate_path" | awk '{print $1}')" \
    == "27c276d9acf9662ff315dccb849304aa61b44dfad67237120eeb9dd97324a840" ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" \
    == "6a50cc027a566104a1d9d505add93b619f1a32f5" ]] ||
    die "Prime native decoder Stage-2 metallib bootstrap repair gate blob changed"
for required_stage2_metallib_bootstrap_repair_launcher_value in \
    'readonly base_revision="075922cec8361c0085d5b2c6d000828e3c0bfc35"' \
    'readonly base_tree="c6bd910b13796bb12098834c5e7daab83cba8668"' \
    '[[ "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" ]]' \
    '[[ "${GITHUB_WORKFLOW:-}" == "Prime active-root quarantine" \' \
    '&& "${GITHUB_JOB:-}" == "trusted-main-compile" ]]' \
    'Ergentics/ergentics-prime/.github/workflows/prime-active-root-quarantine.yml@refs/heads/main' \
    '[[ "${GITHUB_EVENT_NAME:-}" == "push" ]]' \
    '[[ "${GITHUB_REF:-}" == "refs/heads/main" ]]' \
    '[[ "${GITHUB_RUN_ATTEMPT:-}" == "1" ]]' \
    '[[ "${GITHUB_SHA:-}" == "$exact_revision" ]]' \
    '[[ "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" ]]' \
    'readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"' \
    '[[ "$mlx_revision" == "$required_mlx_revision" ]]' \
    '[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]]' \
    'readonly expected_changed_status=$' \
    'M\t.github/scripts/prime-ci-active-root-quarantine.sh' \
    'A\tSources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift' \
    'A\tTests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift' \
    'M\t.github/workflows/prime-active-root-quarantine.yml' \
    'M\tSources/PrimeCore/PrimeEmbeddedBuildProvenance.swift' \
    'M\t.github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh' \
    'fail "direct-successor change scope is not the exact six-path repair"' \
    'readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"' \
    'readonly metal_full_output_log="$runner_temp/prime-native-decoder-metal-full-output.log"' \
    'readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT="' \
    'readonly test_log="$runner_temp/prime-native-decoder-stage2-metallib-bootstrap-repair-tests.log"' \
    'readonly test_class="PrimeNativeDecoderTrainingTests"' \
    'readonly test_method="testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"' \
    '[[ "${#predecessor_logs[@]}" -eq 11 ]]' \
    'grep -Fq '\''Executed 43 tests, with 0 failures'\'' "$active_root_log"' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests' \
    'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling' \
    'grep -Fq '\''Executed 44 tests, with 0 failures'\'' "$metal_log"' \
    'grep -Fq '\''Executed 1 test, with 0 failures'\'' "$runtime_test_log"' \
    'grep -Fq '\''Executed 1 test, with 0 failures'\'' "$tokenizer_test_log"' \
    'metallib_count=0' \
    'fail "fresh metallib root does not contain exactly one loader candidate"' \
    '[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$' \
    '&& "$metallib_byte_count" -le 67108864 ]]' \
    'readonly metal_full_output_identity_prefix_count=' \
    'readonly metal_xctest_log_identity_prefix_count=' \
    'readonly metal_full_output_identity_count=' \
    'readonly metal_xctest_log_identity_count=' \
    '[[ "$metal_full_output_identity_prefix_count" == "1" \' \
    '&& "$metal_full_output_identity_count" == "1" ]]' \
    '[[ "$metal_xctest_log_identity_prefix_count" == "0" \' \
    '&& "$metal_xctest_log_identity_count" == "0" ]]' \
    '[[ "${#predecessor_metallibs[@]}" -eq 5 ]]' \
    '[[ "${#predecessor_artifacts[@]}" -eq 16 ]]' \
    'TMPDIR="$runner_temp" swift build "${swift_arguments[@]}" --build-tests' \
    'cp -X "$metallib" "$cli_metallib"' \
    'cp -X "$metallib" "$test_resource_metallib"' \
    'TMPDIR="$runner_temp" xcrun xctest \' \
    'fail "Stage-2 XCTest start/pass/failure/skip counts are not 1/1/0/0"' \
    'grep -Eq '\''Executed 1 test, with 0 failures'\'' "$test_log"' \
    'built_by_this_launcher: false' \
    'staged_copy_count: 2' \
    'validated_log_count: 11' \
    'validated_receipt_count: 2' \
    'predecessor_artifact_snapshot_count: 16' \
    'predecessor_artifact_revalidation_count_after_xctest: 16' \
    'focused_root_test_count: 43' \
    'focused_isolated_test_count: 6' \
    'focused_whole_step_test_count: 49' \
    'pre_stage2_total_test_count: 95' \
    'trusted_completed_test_count: 96' \
    'build_command_count: 1' \
    'direct_xctest_invocation_count: 1' \
    'failure_count: 0' \
    'skip_count: 0' \
    'retained_order: ["metal", "maintained_runtime", "tokenizer", "stage2"]' \
    'command: "grep -Eq"' \
    'matching_is_case_sensitive: true' \
    'quoted_xctest_case_and_suite_outcome_markers_require_closed_identity: true' \
    'acceptance_fixture_count: 8' \
    'acceptance_fixture_match_count: 0' \
    'rejection_fixture_count: 5' \
    'rejection_fixture_match_count: 5' \
    'metal_full_output_log_capture_added: true' \
    'metal_full_output_log_capture_invocation_count: 1' \
    'metal_full_output_log_tee_invocation_count: 1' \
    'metal_full_output_log_initial_absence_required: true' \
    'required_metal_launcher_pipe_status: 0' \
    'required_metal_full_output_tee_pipe_status: 0' \
    'metal_launcher_exit_and_tee_exit_validated: true' \
    'metal_full_output_log_identity_prefix_count: $metal_full_output_identity_prefix_count' \
    'metal_full_output_log_fresh_identity_count: $metal_full_output_identity_count' \
    'metal_xctest_log_identity_prefix_count: $metal_xctest_log_identity_prefix_count' \
    'metal_xctest_log_fresh_identity_count: $metal_xctest_log_identity_count' \
    'metallib_identity_inventory_count: 5' \
    'metal_bundle_byte_identity_match_count: 2' \
    'runtime_receipt_identity_match_count: 1' \
    'tokenizer_receipt_identity_match_count: 1' \
    'loaded_metallib_path_inferred: false' \
    'artifact_upload_invoked: false' \
    'rerun_authorized: false'; do
    grep -Fq -- "$required_stage2_metallib_bootstrap_repair_launcher_value" \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path" ||
        die "Stage-2 metallib bootstrap repair launcher lost: $required_stage2_metallib_bootstrap_repair_launcher_value"
done
readonly expected_stage2_predecessor_log_classifier_regex="^Test Case '[^']+' failed \\\\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\\\(| : Test skipped - "
[[ "$(grep -Fxc -- \
        "readonly xctest_failure_or_skip_regex=\"$expected_stage2_predecessor_log_classifier_regex\"" \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fxc -- \
        '    grep -Eq "$xctest_failure_or_skip_regex" "$log_path"' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fxc -- \
        '[[ "${#classifier_acceptance_fixtures[@]}" -eq 8 ]] ||' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fxc -- \
        '[[ "${#classifier_rejection_fixtures[@]}" -eq 5 ]] ||' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" ]] ||
    die "Stage-2 predecessor-log classifier grammar or fixture ceiling changed"
for required_stage2_predecessor_log_classifier_fixture in \
    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' started." \
    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' passed (0.860 seconds)." \
    "Test Case '-[ClassifierFixtureTests testSkippedAttemptNameIsOnlyAnIdentifier]' started." \
    "Test Case '-[ClassifierFixtureTests testSkippedAttemptNameIsOnlyAnIdentifier]' passed (0.001 seconds)." \
    "Test Suite 'ClassifierFixtureTests' passed at 2026-08-12 00:00:00.000." \
    'Executed 2 tests, with 0 failures (0 unexpected) in 0.860 (0.861) seconds' \
    'Classifier fixture prose mentions failed and skipped without reporting an outcome.' \
    'note: error: is quoted here only as classifier fixture prose' \
    "Test Case '-[ClassifierFixtureTests testExactFailure]' failed (0.001 seconds)." \
    "Test Suite 'ClassifierFixtureTests' failed at 2026-08-12 00:00:00.000." \
    'error: exact classifier fixture error' \
    "Test Case '-[ClassifierFixtureTests testExactSkip]' skipped (0.001 seconds)." \
    '/tmp/ClassifierFixtureTests.swift:1: -[ClassifierFixtureTests testExactSkip] : Test skipped - exact fixture'; do
    [[ "$(grep -Fc -- "$required_stage2_predecessor_log_classifier_fixture" \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" ]] ||
        die "Stage-2 predecessor-log classifier fixture changed: $required_stage2_predecessor_log_classifier_fixture"
done
[[ "$(grep -Fc -- 'grep -Eiq' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "0" \
    && "$(grep -Fc -- \
        '^Test (Case|Suite).*failed|^error:|skipped|Test skipped' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "0" ]] ||
    die "Stage-2 launcher retains the exhausted case-insensitive unbounded classifier"
[[ "$(grep -Ec -- '^[[:space:]]*TMPDIR=.*swift build ' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Ec -- '^[[:space:]]*cp -X ' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "2" \
    && "$(grep -Ec -- '^[[:space:]]*TMPDIR=.*xcrun xctest ' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fc -- \
        'PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT=' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fc -- 'readonly parent_count=2' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "1" \
    && "$(grep -Fc -- 'readonly parent_count=1' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "0" \
    && "$(grep -Fc -- '-z "${second_parent:-}" ||' \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path")" == "0" ]] ||
    die "Stage-2 metallib bootstrap repair launcher command or exact-two-parent boundary changed"
for forbidden_stage2_metallib_bootstrap_repair_launcher_value in \
    'swift test' \
    'xcodebuild' \
    'swift build --show-bin-path' \
    '--disable-sandbox' \
    'git fetch' \
    'git clone' \
    'git submodule update' \
    'curl ' \
    'wget ' \
    'actions/upload-artifact' \
    'prime-native-decoder-training-tests.log' \
    'prime-native-decoder-training-build' \
    'prime-native-decoder-training-cache' \
    'prime-native-decoder-training-config' \
    'prime-native-decoder-training-security'; do
    if grep -Fq -- "$forbidden_stage2_metallib_bootstrap_repair_launcher_value" \
        "$decoder_stage2_metallib_bootstrap_repair_gate_path"; then
        die "Stage-2 metallib bootstrap repair launcher gained forbidden behavior: $forbidden_stage2_metallib_bootstrap_repair_launcher_value"
    fi
done
[[ -f "$decoder_stage3_tiny_cpu_resume_gate_path" \
    && ! -L "$decoder_stage3_tiny_cpu_resume_gate_path" ]] ||
    die "Stage-3 tiny CPU resume launcher is missing or linked"
[[ "$(git -C "$prime_root" ls-files -s -- \
        '.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh' |
        awk '{print $1}')" == "100755" ]] ||
    die "Stage-3 tiny CPU resume launcher mode changed"
bash -n "$decoder_stage3_tiny_cpu_resume_gate_path" ||
    die "Stage-3 tiny CPU resume launcher is not valid Bash"
[[ "$(git -C "$prime_root" hash-object \
        "$decoder_stage3_tiny_cpu_resume_gate_path")" \
        == "f912e776309866eaec5c6a162892c096b9bc2488" \
    && "$(wc -c < "$decoder_stage3_tiny_cpu_resume_gate_path" | awk '{print $1}')" \
        == "26319" \
    && "$(shasum -a 256 "$decoder_stage3_tiny_cpu_resume_gate_path" | awk '{print $1}')" \
        == "1a184b52e0055128afbb6a9ccc22c46e8a929f30b3e0f43752f6a43e48eae6bd" ]] ||
    die "Stage-3 tiny CPU resume launcher identity changed"
for required_stage3_launcher_value in \
    'readonly base_revision="372248bd2e2d282bbb2b0fe39273211aee0da43a"' \
    'readonly base_tree="f4df5d9b17c216748387435ef0f1f8d14ede2f54"' \
    'readonly authority_canonical_sha256="0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6"' \
    'readonly repair_authority_canonical_sha256="34cd246fbeb754f31f7ecf3fee03d35fdc5c615e5a61c245e609a7ef03845b59"' \
    'readonly inventory_order_repair_authority_canonical_sha256="52f2619ebcbc6e8d608042ffb107411bbcb6ac4630482dba0007436f52bb03ce"' \
    'readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE3_TINY_CPU_EXPLICIT_RNG_CURSOR_RESUME_RECEIPT="' \
    'A\tSources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift' \
    'A\tTests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift' \
    'M\t.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh' \
    'fail "Stage-3 direct-successor scope is not the exact six paths"' \
    'grep -Fq '\''Executed 47 tests, with 0 failures'\'' "$active_root_log"' \
    'grep -Fq "$authority_canonical_sha256" "$authority_source"' \
    'grep -Fq "$inventory_order_repair_authority_canonical_sha256" \' \
    'grep -Fq '\''Executed 44 tests, with 0 failures'\'' "$metal_log"' \
    'readonly test_method="testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed"' \
    'TMPDIR="$runner_temp" swift build \' \
    'cp -X "$metallib" "$cli_metallib"' \
    'cp -X "$metallib" "$test_resource_metallib"' \
    'TMPDIR="$runner_temp" xcrun xctest -XCTest "$test_filter" "$test_bundle"' \
    'fail "Stage-3 test counts are not 1/1/0/0"' \
    'typed_in_memory_snapshot_export_restore_established:true' \
    'uninterrupted_and_fresh_restored_step2_exact_equality_established:true' \
    'checkpoint_io_observed:false' \
    'stage4_authorized:false' \
    'rerun_authorized:false'; do
    grep -Fq -- "$required_stage3_launcher_value" \
        "$decoder_stage3_tiny_cpu_resume_gate_path" ||
        die "Stage-3 tiny CPU resume launcher lost: $required_stage3_launcher_value"
done
[[ "$(grep -Ec -- '^[[:space:]]*TMPDIR=.*swift build ' \
        "$decoder_stage3_tiny_cpu_resume_gate_path")" == "1" \
    && "$(grep -Ec -- '^[[:space:]]*cp -X ' \
        "$decoder_stage3_tiny_cpu_resume_gate_path")" == "2" \
    && "$(grep -Ec -- '^[[:space:]]*TMPDIR=.*xcrun xctest ' \
        "$decoder_stage3_tiny_cpu_resume_gate_path")" == "1" ]] ||
    die "Stage-3 launcher command cardinality changed"
for forbidden_stage3_launcher_value in \
    'swift test' 'xcodebuild' 'git fetch' 'git clone' 'git submodule update' \
    'curl ' 'wget ' 'actions/upload-artifact' 'PrimeArtifactRoot' \
    'PrimeNativeDecoderCheckpoint'; do
    ! grep -Fq -- "$forbidden_stage3_launcher_value" \
        "$decoder_stage3_tiny_cpu_resume_gate_path" ||
        die "Stage-3 launcher gained forbidden behavior: $forbidden_stage3_launcher_value"
done
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
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_gate_path" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_gate_path" ]] ||
    die "Prime native decoder checkpoint V2 I/O root-identity repair gate is missing or linked"
[[ "$(git -C "$prime_root" ls-files -- \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh')" \
    == '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh' ]] ||
    die "Prime native decoder checkpoint V2 I/O root-identity repair gate is not tracked exactly"
[[ "$(git -C "$prime_root" ls-files -s -- \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh' | awk '{print $1}')" \
    == "100755" ]] ||
    die "Prime native decoder checkpoint V2 I/O root-identity repair gate mode changed"
bash -n "$decoder_checkpoint_v2_io_root_identity_repair_gate_path" ||
    die "Prime native decoder checkpoint V2 I/O root-identity repair gate is not valid Bash"
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
[[ "$frozen_metal_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$tokenizer_compatibility_workflow_line" =~ ^[1-9][0-9]*$ \
    && "$runtime_closure_workflow_line" \
        -eq $((frozen_metal_workflow_line + 1)) \
    && "$tokenizer_compatibility_workflow_line" \
        -eq $((runtime_closure_workflow_line + 1)) ]] ||
    die "trusted-main workflow does not retain exactly the Metal, runtime, tokenizer order"
[[ "$(grep -Fc -- \
    '          bash .github/scripts/prime-ci-native-decoder-' \
    "$workflow_path")" == "3" \
    && "$(grep -Fxc -- \
        '          bash .github/scripts/prime-ci-native-decoder-metal.sh' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        '          bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh' \
        "$workflow_path")" == "0" \
    && "$(grep -Fxc -- \
        '          bash .github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh' \
        "$workflow_path")" == "0" \
    && "$(grep -Fxc -- \
        '          bash .github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh' \
        "$workflow_path")" == "0" ]] ||
    die "trusted-main workflow lost the exact three-launcher sequence or retained a retired one-shot"
readonly live_decoder_workflow_block="$(awk '
    /^      - name: Run the Prime-owned decoder on live Metal$/ { inside = 1 }
    inside { print }
' "$workflow_path")"
readonly expected_live_decoder_workflow_block='      - name: Run the Prime-owned decoder on live Metal
        working-directory: ergentics-prime
        run: |
          bash .github/scripts/prime-ci-native-decoder-metal.sh
          bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh
          bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh'
[[ "$live_decoder_workflow_block" == "$expected_live_decoder_workflow_block" ]] ||
    die "trusted-main exact contiguous Metal, runtime, and tokenizer block changed"
! grep -Fq -- \
    '          bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh' \
    "$workflow_path" ||
    die "retired Prime native decoder checkpoint V2 I/O one-shot remains live"
! grep -Fq -- \
    '          bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh' \
    "$workflow_path" ||
    die "retired Prime native decoder checkpoint V2 I/O root-identity repair one-shot remains live"
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
[[ "$(grep -Fc -- \
    '--package-path Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation' \
    "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-execution-pure-tests.log' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-execution-pure-build' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-execution-pure-cache' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-execution-pure-config' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-execution-pure-security' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'Executed 2 tests, with 0 failures' \
        "$workflow_path")" == "2" ]] ||
    die "trusted-main workflow does not run and bind the exact two-test V2 I/O execution pure suite"
[[ "$(grep -Fc -- \
    '--package-path Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation' \
    "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-root-identity-repair-execution-pure-tests.log' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-root-identity-repair-execution-pure-build' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-root-identity-repair-execution-pure-cache' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-root-identity-repair-execution-pure-config' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'prime-checkpoint-v2-io-root-identity-repair-execution-pure-security' \
        "$workflow_path")" == "2" \
    && "$(grep -Fc -- \
        'Executed 2 tests, with 0 failures' \
        "$workflow_path")" == "2" ]] ||
    die "trusted-main workflow does not run and bind the exact two-test root-identity repair pure suite"
readonly trajectory_exact_resume_design_filter='PrimeCoreTests.PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests/testFrozenV1CanonicalCodableMutationAndSourceBoundary'
[[ "$(grep -Fc -- "$trajectory_exact_resume_design_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the exact trajectory-resume design contract"
readonly trajectory_design_timeout_observation_filter='PrimeCoreTests.PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests/testFrozenV1CanonicalCodableRecursiveMutationAndAuthorityCeiling'
[[ "$(grep -Fc -- "$trajectory_design_timeout_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'testFrozenV1CanonicalCodableRecursiveMutationAndAuthorityCeiling' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the exact trajectory-design timeout observation"
readonly tiny_cpu_mechanics_authority_filter='PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests/testFrozenV1CanonicalCodableExhaustiveMutationAndCeiling'
readonly tiny_cpu_mechanics_failure_observation_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling'
readonly private_dependency_tls_failure_observation_filter='PrimeCoreTests.PrimeReviewedMainPrivateDependencyTLSFailureObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling'
readonly metal_current_decoder_identity_assertion_failure_observation_filter='PrimeCoreTests.PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling'
readonly metal_current_decoder_identity_assertion_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling'
readonly stage2_metallib_bootstrap_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling'
readonly stage2_metallib_bootstrap_repair_failure_observation_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling'
readonly stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling'
readonly stage2_fresh_metallib_cross_binding_failure_observation_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling'
readonly stage2_fresh_metallib_evidence_surface_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling'
readonly stage2_fresh_metallib_evidence_surface_repair_execution_observation_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling'
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling'
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling'
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests/testFrozenV1CanonicalCodableRecursiveMutationAndRepairCeiling'
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_filter='PrimeCoreTests.PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests/testFrozenV1CanonicalCodableRecursiveMutationAndSuccessCeiling'
readonly stage4_tiny_durable_multileaf_commit_fault_injection_authority_filter='PrimeCoreTests.PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling'
[[ "$(grep -Fc -- "$tiny_cpu_mechanics_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- "$tiny_cpu_mechanics_failure_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'testFrozenV1CanonicalCodableExhaustiveMutationAndCeiling' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        '          grep -Fq '\''Executed 49 tests, with 0 failures'\'' "$test_log"' \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not run the exact Stage-2 authority and failure-observation pure contracts"
[[ "$(grep -Fc -- "$private_dependency_tls_failure_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeReviewedMainPrivateDependencyTLSFailureObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeReviewedMainPrivateDependencyTLSFailureObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeReviewedMainPrivateDependencyTLSFailureObservationTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the private-dependency TLS failure observation"
[[ "$(grep -Fc -- \
        "$metal_current_decoder_identity_assertion_failure_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        "$metal_current_decoder_identity_assertion_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the current-decoder identity assertion failure and repair contracts"
[[ "$(grep -Fc -- \
        "$stage2_metallib_bootstrap_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        "$stage2_metallib_bootstrap_repair_failure_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        "$stage2_fresh_metallib_cross_binding_failure_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        '          grep -Fq '\''Executed 49 tests, with 0 failures'\'' "$test_log"' \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the Stage-2 metallib bootstrap repair, failure observations, and classifier repair authority"
[[ "$(grep -Fc -- \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the fresh-metallib evidence-surface repair authority"
[[ "$(grep -Fc -- \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the fresh-metallib evidence-surface repair execution observation"
[[ "$(grep -Fc -- \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests' \\" \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the Stage-3 explicit-RNG/cursor-resume authority"
[[ "$(grep -Fc -- \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the Stage-3 canonical-binding repair authority"
[[ "$(grep -Fc -- \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the Stage-3 validation-inventory order repair authority"
[[ "$(grep -Fc -- \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservation.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run the Stage-3 execution observation"
[[ "$(grep -Fc -- \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_filter" \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthority.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fxc -- \
        "          grep -Fq 'PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests' \\" \
        "$workflow_path")" == "1" ]] ||
    die "hosted workflow does not parse and run exactly the Stage-4 tiny durable multileaf authority"
for required_stage4_tiny_durable_multileaf_authority_summary_value in \
    'The dependency-free Stage-4 tiny durable multileaf authority is pure and nonexecuting.' \
    'Only after this authority merges and its exact-main depth-one closure passes may one separately scoped exact-main mechanics successor' \
    'The tiny weights mechanics fixture is not the frozen Native-300M V2 checkpoint and neither uses nor widens that public codec.' \
    'performs no filesystem or checkpoint I/O' \
    'invokes no Stage-4 launcher' \
    'grants no retry, Stage 5, Metal-determinism, Native-300M, admission, training, trial, canary, product, or publication authority'; do
    [[ "$(grep -Fc -- \
        "$required_stage4_tiny_durable_multileaf_authority_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the exact Stage-4 authority summary: $required_stage4_tiny_durable_multileaf_authority_summary_value"
done
for required_stage2_metallib_bootstrap_repair_failure_summary_value in \
    'Exact-main workflow run 31544702133 attempt 1' \
    'passed secure fetch, root 39, Metal 44, maintained runtime 1, and tokenizer 1' \
    'frozen launcher preflight falsely treated the passing test identifier testFailedAttemptObservationIsExactExhaustedAndPure as a failed predecessor' \
    'before fresh-metallib discovery, staging, build, direct XCTest, or Stage-2 test start' \
    'without characterizing a predecessor test or Stage-2 mechanics failure' \
    'no rerun, artifact, Stage 3, or downstream authority is established'; do
    [[ "$(grep -Fc -- \
        "$required_stage2_metallib_bootstrap_repair_failure_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the exact Stage-2 repair failure summary: $required_stage2_metallib_bootstrap_repair_failure_summary_value"
done
for required_stage2_predecessor_log_classifier_repair_summary_value in \
    'repairs only that predecessor-log classifier to a case-sensitive outcome grammar with eight accepted and five rejected regression fixtures' \
    'after root 41, Metal 44, maintained runtime 1, and tokenizer 1 pass in order' \
    'one Git-internal submodule clone retry from zero workflow-authored retries' \
    'mutates neither secure fetch nor production' \
    'a separate terminal outcome observation must retire the invocation'; do
    [[ "$(grep -Fc -- \
        "$required_stage2_predecessor_log_classifier_repair_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the exact Stage-2 classifier repair summary: $required_stage2_predecessor_log_classifier_repair_summary_value"
done
for required_stage2_fresh_metallib_cross_binding_failure_summary_value in \
    'Exact-main workflow run 31555440908 attempt 1' \
    'zero workflow-authored and zero Git-internal retries' \
    'root 41, Metal 44, maintained runtime 1, and tokenizer 1 in order' \
    'discovered and hashed the same-job fresh metallib' \
    'identity binding from the XCTest-only Metal log' \
    'preserved Metal launcher emits that binding before its XCTest tee' \
    'before receipt validation, Stage-2 build, metallib staging, direct XCTest, test start, or receipt' \
    'launcher remains frozen, the reviewed-main checkout returns to depth one' \
    'Metal, maintained runtime, and tokenizer remain live in order' \
    'No rerun, Actions artifact, checkpoint, Stage 3, or downstream authority is established'; do
    [[ "$(grep -Fc -- \
        "$required_stage2_fresh_metallib_cross_binding_failure_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the exact Stage-2 fresh-metallib cross-binding failure summary: $required_stage2_fresh_metallib_cross_binding_failure_summary_value"
done
for required_stage2_fresh_metallib_evidence_surface_repair_summary_value in \
    'bounded evidence-surface successor captures the unchanged Metal launcher’s complete output once in a fixed initially absent same-job log' \
    'requires both launcher and tee pipeline statuses to be zero' \
    'dynamic fresh metallib identity exactly once there and zero times in the XCTest-only log' \
    'After root 43, Metal 44, maintained runtime 1, and tokenizer 1 pass in order' \
    'same five metallib identities and two canonical receipts' \
    'snapshots and revalidates all 16 predecessor artifacts' \
    'one direct Stage-2 XCTest attempt for trusted total 96' \
    'no retry, rerun, artifact, checkpoint, Stage 3, or downstream authority' \
    'a separate terminal outcome must retire the invocation'; do
    [[ "$(grep -Fc -- \
        "$required_stage2_fresh_metallib_evidence_surface_repair_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the fresh-metallib evidence-surface repair summary: $required_stage2_fresh_metallib_evidence_surface_repair_summary_value"
done
for required_stage2_fresh_metallib_evidence_surface_repair_execution_summary_value in \
    'Exact-main workflow run 31565094400 attempt 1' \
    'unchanged secure fetch with no workflow-authored or Git-internal retry' \
    'root 43, Metal 44, maintained runtime 1, tokenizer 1, and the single direct Stage-2 mechanics test with zero failures or skips' \
    'canonical receipt cross-binds the fresh metallib file, both Metal bundle candidates, and the runtime and tokenizer receipts' \
    'explicitly declining to infer which metallib path MLX loaded' \
    'consumes the repair authority and retires the full-output wrapper and Stage-2 invocation' \
    'frozen launcher remains preserved, reviewed-main checkout returns to depth one' \
    'retained live order is Metal, then maintained runtime, then tokenizer' \
    'Mechanics execution is established' \
    'Stage 3 remains blocked after this success observation merges and its retirement closure passes exact main, pending distinct authority' \
    'no rerun, Actions artifact, checkpoint, training-resume, product, publication, or downstream authority is granted'; do
    [[ "$(grep -Fc -- \
        "$required_stage2_fresh_metallib_evidence_surface_repair_execution_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the fresh-metallib evidence-surface repair execution summary: $required_stage2_fresh_metallib_evidence_surface_repair_execution_summary_value"
done
for required_stage3_tiny_cpu_explicit_rng_cursor_resume_summary_value in \
    'Stage-3 tiny-CPU explicit-RNG/cursor-resume authority is dependency-free and remains frozen' \
    'exact direct-main successor may run one' \
    'typed in-memory step-1 snapshot' \
    'fresh-trainer restore' \
    'exact uninterrupted-versus-restored step-2 witness' \
    'four Prime-owned key/counter domains' \
    'exact next-unconsumed cursor' \
    'no checkpoint file or codec' \
    'implicit MLX RNG restoration' \
    'Native-300M work'; do
    [[ "$(grep -Fc -- \
        "$required_stage3_tiny_cpu_explicit_rng_cursor_resume_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the Stage-3 explicit-RNG/cursor-resume authority summary: $required_stage3_tiny_cpu_explicit_rng_cursor_resume_summary_value"
done
for required_stage3_inventory_order_repair_summary_value in \
    'Exact-main run 31674969104 attempt 1' \
    'root 46, Metal 44, maintained runtime 1, and tokenizer 1 passed' \
    'expected the two validation test paths in an order contrary to its own bytewise sort' \
    'exactly one expected-order replacement and one new direct-main successor' \
    'does not recover or rerun either consumed attempt' \
    'either consumed attempt and grants no Stage-3 success, checkpoint, downstream stage, artifact, product, or publication claim'; do
    [[ "$(grep -Fc -- "$required_stage3_inventory_order_repair_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the Stage-3 inventory-order repair summary: $required_stage3_inventory_order_repair_summary_value"
done
for required_stage3_execution_observation_summary_value in \
    'Exact-main run 31679144989 attempt 1 passed root 47, Metal 44, maintained runtime 1, tokenizer 1, and exactly one Stage-3' \
    'one canonical receipt' \
    'typed in-memory snapshot/export/fresh-restore mechanics are established only for that bounded witness' \
    'loaded-metallib identity remains inference-only' \
    'no artifact was retained or uploaded' \
    'one-shot is consumed and retired here' \
    'checkpoint I/O, durable Stage 4, Native-300M training, trial, canary, product, publication, and rerun authority remain false'; do
    [[ "$(grep -Fc -- "$required_stage3_execution_observation_summary_value" \
        "$workflow_path")" == "1" ]] ||
        die "workflow lost the Stage-3 execution-observation summary: $required_stage3_execution_observation_summary_value"
done
[[ "$(grep -Fc -- \
        'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift' \
        "$workflow_path")" == "1" \
    && "$(grep -Fc -- \
        '--package-path Tests/PrimeNativeDecoderTrainingValidation' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- 'prime-native-decoder-training-tests.log' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- 'prime-native-decoder-training-build' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- 'prime-native-decoder-training-cache' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- 'prime-native-decoder-training-config' \
        "$workflow_path")" == "0" \
    && "$(grep -Fc -- 'prime-native-decoder-training-security' \
        "$workflow_path")" == "0" ]] ||
    die "reviewed-main workflow bypassed the bounded Stage-2 successor launcher with an inline mechanics invocation"
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
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_manifest_dump="$(mktemp "$runner_temp/prime-decoder-checkpoint-v2-io-root-identity-repair-execution-package-dump.json.XXXXXX")"
readonly decoder_runtime_closure_manifest_dump="$(mktemp "$runner_temp/prime-decoder-runtime-closure-package-dump.json.XXXXXX")"
readonly decoder_tokenizer_compatibility_manifest_dump="$(mktemp "$runner_temp/prime-decoder-tokenizer-compatibility-package-dump.json.XXXXXX")"
readonly decoder_training_validation_manifest_dump="$(mktemp "$runner_temp/prime-decoder-training-validation-package-dump.json.XXXXXX")"
readonly manifest_scratch="$runner_temp/prime-package-dump-build"
readonly manifest_cache="$runner_temp/prime-package-dump-cache"
readonly manifest_config="$runner_temp/prime-package-dump-config"
readonly manifest_security="$runner_temp/prime-package-dump-security"
trap 'unlink "$manifest_dump" "$decoder_manifest_dump" "$decoder_checkpoint_v2_manifest_dump" "$decoder_checkpoint_v2_io_manifest_dump" "$decoder_checkpoint_v2_io_execution_manifest_dump" "$decoder_checkpoint_v2_io_root_identity_repair_execution_manifest_dump" "$decoder_runtime_closure_manifest_dump" "$decoder_tokenizer_compatibility_manifest_dump" "$decoder_training_validation_manifest_dump" 2>/dev/null || true' EXIT
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
          .name == "PrimeNativeDecoderTraining"
          and .targets == ["PrimeNativeDecoderTraining"]
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
          .name == "PrimeNativeDecoderTraining"
          and .type == "regular"
          and ([.dependencies[] | (.byName[0] // .product[0])] == [
              "PrimeCore",
              "PrimeNativeDecoder",
              "MLX",
              "MLXNN",
              "MLXOptimizers"
          ])
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
    --package-path "$prime_root/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_checkpoint_v2_io_root_identity_repair_execution_manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$root_mlx_revision" \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation"
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
          == "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe"
      and .products[0].targets
          == ["PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe"]
      and (.products[0].type | keys) == ["executable"]
      and (.targets | length) == 2
      and [.targets[].name] == [
          "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
          "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests"
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
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair execution validation manifest changed"

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

TMPDIR="$runner_temp" swift package \
    --package-path "$prime_root/Tests/PrimeNativeDecoderTrainingValidation" \
    --scratch-path "$manifest_scratch" \
    --cache-path "$manifest_cache" \
    --config-path "$manifest_config" \
    --security-path "$manifest_security" \
    --disable-netrc \
    --disable-keychain \
    dump-package > "$decoder_training_validation_manifest_dump"
jq -e \
    --arg expected_origin "$expected_mlx_origin" \
    --arg expected_revision "$root_mlx_revision" \
    --arg prime_root "$prime_root" \
    '
      .name == "PrimeNativeDecoderTrainingValidation"
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
      and .targets[0].name == "PrimeNativeDecoderTrainingTests"
      and .targets[0].type == "test"
      and ([.targets[0].dependencies[].product[0]] == [
          "PrimeNativeDecoderTraining",
          "MLX"
      ])
      and ([.targets[0].dependencies[].product[1]] == [
          "ergentics-prime",
          "ergentics-mlx-swift"
      ])
      and ([.targets[0].settings[].kind.linkedFramework._0] == [
          "CoreGraphics",
          "Metal"
      ])
    ' \
    "$decoder_training_validation_manifest_dump" >/dev/null ||
    die "PrimeNativeDecoder Stage-2 validation manifest changed"

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
readonly decoder_checkpoint_v2_io_execution_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservation.swift"
readonly decoder_checkpoint_v2_io_execution_evidence_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservation.swift"
readonly decoder_trajectory_exact_resume_design_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift"
readonly decoder_trajectory_exact_resume_design_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests.swift"
readonly decoder_trajectory_design_timeout_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservation.swift"
readonly decoder_trajectory_design_timeout_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests.swift"
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
readonly decoder_checkpoint_v2_io_execution_failure_observation_test="$decoder_checkpoint_v2_io_execution_validation_root/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root="$prime_root/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest="$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Package.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_validation_lock="$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Package.resolved"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_probe="$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_test="$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift"
readonly decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test="$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests.swift"
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
readonly decoder_tiny_cpu_mechanics_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift"
readonly decoder_tiny_cpu_mechanics_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests.swift"
readonly decoder_tiny_cpu_mechanics_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservation.swift"
readonly decoder_tiny_cpu_mechanics_failure_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests.swift"
readonly private_dependency_tls_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeReviewedMainPrivateDependencyTLSFailureObservation.swift"
readonly private_dependency_tls_failure_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeReviewedMainPrivateDependencyTLSFailureObservationTests.swift"
readonly metal_current_decoder_identity_assertion_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservation.swift"
readonly metal_current_decoder_identity_assertion_failure_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests.swift"
readonly metal_current_decoder_identity_assertion_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthority.swift"
readonly metal_current_decoder_identity_assertion_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests.swift"
readonly stage2_metallib_bootstrap_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift"
readonly stage2_metallib_bootstrap_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift"
readonly stage2_metallib_bootstrap_repair_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservation.swift"
readonly stage2_metallib_bootstrap_repair_failure_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests.swift"
readonly stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift"
readonly stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift"
readonly stage2_fresh_metallib_cross_binding_failure_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift"
readonly stage2_fresh_metallib_cross_binding_failure_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift"
readonly stage2_fresh_metallib_evidence_surface_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift"
readonly stage2_fresh_metallib_evidence_surface_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift"
readonly stage2_fresh_metallib_evidence_surface_repair_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservation.swift"
readonly stage2_fresh_metallib_evidence_surface_repair_execution_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservation.swift"
readonly stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests.swift"
readonly stage4_tiny_durable_multileaf_commit_fault_injection_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthority.swift"
readonly stage4_tiny_durable_multileaf_commit_fault_injection_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests.swift"
readonly decoder_training_source="$prime_root/Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
readonly decoder_training_validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly decoder_training_validation_manifest="$decoder_training_validation_root/Package.swift"
readonly decoder_training_validation_lock="$decoder_training_validation_root/Package.resolved"
readonly decoder_training_validation_test="$decoder_training_validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift"
readonly decoder_stage3_tiny_cpu_resume_test="$decoder_training_validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift"

[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoder')" \
    == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift" ]] ||
    die "PrimeNativeDecoder production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderCheckpoint')" \
    == $'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservation.swift\nSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift' ]] ||
    die "PrimeNativeDecoderCheckpoint production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderRuntime')" \
    == 'Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift' ]] ||
    die "PrimeNativeDecoderRuntime production source inventory changed"
[[ "$(git -C "$prime_root" ls-files -- 'Sources/PrimeNativeDecoderTraining')" \
    == 'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' ]] ||
    die "PrimeNativeDecoderTraining production source inventory changed"
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
    == $'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift\nTests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift' ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation')" \
    == $'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved\nTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift\nTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift\nTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift\nTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests.swift' ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair execution validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderRuntimeClosureValidation')" \
    == $'Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved\nTests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift\nTests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder runtime-closure validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation')" \
    == $'Tests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.resolved\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Package.swift\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Sources/PrimeNativeDecoderTokenizerCompatibilityProbe/main.swift\nTests/PrimeNativeDecoderTokenizerCompatibilityValidation/Tests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests/PrimeNativeDecoderTokenizerCompatibilityAuthorityTests.swift' ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation inventory changed"
[[ "$(git -C "$prime_root" ls-files -- \
    'Tests/PrimeNativeDecoderTrainingValidation')" \
    == $'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved\nTests/PrimeNativeDecoderTrainingValidation/Package.swift\nTests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift\nTests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' ]] ||
    die "PrimeNativeDecoder Stage-3 validation inventory changed"
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
[[ ! -e "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/.swiftpm" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair execution validation must use the supplied isolated config path"
[[ ! -e "$decoder_runtime_closure_validation_root/.swiftpm" \
    && ! -L "$decoder_runtime_closure_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder runtime-closure validation must use the supplied isolated config path"
[[ ! -e "$decoder_tokenizer_compatibility_validation_root/.swiftpm" \
    && ! -L "$decoder_tokenizer_compatibility_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder tokenizer-compatibility validation must use the supplied isolated config path"
[[ ! -e "$decoder_training_validation_root/.swiftpm" \
    && ! -L "$decoder_training_validation_root/.swiftpm" ]] ||
    die "PrimeNativeDecoder Stage-2 validation must use the supplied isolated config path"
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
[[ -f "$decoder_tiny_cpu_mechanics_authority_source" \
    && ! -L "$decoder_tiny_cpu_mechanics_authority_source" ]] ||
    die "PrimeNativeDecoder Stage-2 authority is missing or linked"
[[ -f "$decoder_tiny_cpu_mechanics_authority_test" \
    && ! -L "$decoder_tiny_cpu_mechanics_authority_test" ]] ||
    die "PrimeNativeDecoder Stage-2 authority test is missing or linked"
[[ -f "$decoder_tiny_cpu_mechanics_failure_observation_source" \
    && ! -L "$decoder_tiny_cpu_mechanics_failure_observation_source" ]] ||
    die "PrimeNativeDecoder Stage-2 failure observation is missing or linked"
[[ -f "$decoder_tiny_cpu_mechanics_failure_observation_test" \
    && ! -L "$decoder_tiny_cpu_mechanics_failure_observation_test" ]] ||
    die "PrimeNativeDecoder Stage-2 failure-observation test is missing or linked"
[[ -f "$private_dependency_tls_failure_observation_source" \
    && ! -L "$private_dependency_tls_failure_observation_source" ]] ||
    die "private-dependency TLS failure observation is missing or linked"
[[ -f "$private_dependency_tls_failure_observation_test" \
    && ! -L "$private_dependency_tls_failure_observation_test" ]] ||
    die "private-dependency TLS failure-observation test is missing or linked"
[[ -f "$metal_current_decoder_identity_assertion_failure_observation_source" \
    && ! -L "$metal_current_decoder_identity_assertion_failure_observation_source" ]] ||
    die "current-decoder identity assertion failure observation is missing or linked"
[[ -f "$metal_current_decoder_identity_assertion_failure_observation_test" \
    && ! -L "$metal_current_decoder_identity_assertion_failure_observation_test" ]] ||
    die "current-decoder identity assertion failure-observation test is missing or linked"
[[ -f "$metal_current_decoder_identity_assertion_repair_authority_source" \
    && ! -L "$metal_current_decoder_identity_assertion_repair_authority_source" ]] ||
    die "current-decoder identity assertion repair authority is missing or linked"
[[ -f "$metal_current_decoder_identity_assertion_repair_authority_test" \
    && ! -L "$metal_current_decoder_identity_assertion_repair_authority_test" ]] ||
    die "current-decoder identity assertion repair-authority test is missing or linked"
[[ -f "$stage2_metallib_bootstrap_repair_authority_source" \
    && ! -L "$stage2_metallib_bootstrap_repair_authority_source" ]] ||
    die "Stage-2 metallib bootstrap repair authority is missing or linked"
[[ -f "$stage2_metallib_bootstrap_repair_authority_test" \
    && ! -L "$stage2_metallib_bootstrap_repair_authority_test" ]] ||
    die "Stage-2 metallib bootstrap repair authority test is missing or linked"
[[ -f "$stage2_metallib_bootstrap_repair_failure_observation_source" \
    && ! -L "$stage2_metallib_bootstrap_repair_failure_observation_source" ]] ||
    die "Stage-2 metallib bootstrap repair failure observation is missing or linked"
[[ -f "$stage2_metallib_bootstrap_repair_failure_observation_test" \
    && ! -L "$stage2_metallib_bootstrap_repair_failure_observation_test" ]] ||
    die "Stage-2 metallib bootstrap repair failure-observation test is missing or linked"
[[ -f "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source" \
    && ! -L "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source" ]] ||
    die "Stage-2 predecessor-log classifier repair authority is missing or linked"
[[ -f "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test" \
    && ! -L "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test" ]] ||
    die "Stage-2 predecessor-log classifier repair authority test is missing or linked"
[[ -f "$stage2_fresh_metallib_cross_binding_failure_observation_source" \
    && ! -L "$stage2_fresh_metallib_cross_binding_failure_observation_source" ]] ||
    die "Stage-2 fresh-metallib cross-binding failure observation is missing or linked"
[[ -f "$stage2_fresh_metallib_cross_binding_failure_observation_test" \
    && ! -L "$stage2_fresh_metallib_cross_binding_failure_observation_test" ]] ||
    die "Stage-2 fresh-metallib cross-binding failure-observation test is missing or linked"
[[ -f "$stage2_fresh_metallib_evidence_surface_repair_authority_source" \
    && ! -L "$stage2_fresh_metallib_evidence_surface_repair_authority_source" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair authority is missing or linked"
[[ -f "$stage2_fresh_metallib_evidence_surface_repair_authority_test" \
    && ! -L "$stage2_fresh_metallib_evidence_surface_repair_authority_test" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair-authority test is missing or linked"
[[ -f "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source" \
    && ! -L "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair execution observation is missing or linked"
[[ -f "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test" \
    && ! -L "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair execution-observation test is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" ]] ||
    die "Stage-3 explicit-RNG/cursor-resume authority is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test" ]] ||
    die "Stage-3 explicit-RNG/cursor-resume authority test is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source" ]] ||
    die "Stage-3 canonical-binding repair authority is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test" ]] ||
    die "Stage-3 canonical-binding repair authority test is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source" ]] ||
    die "Stage-3 validation-inventory order repair authority is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test" ]] ||
    die "Stage-3 validation-inventory order repair authority test is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source" ]] ||
    die "Stage-3 execution observation is missing or linked"
[[ -f "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test" \
    && ! -L "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test" ]] ||
    die "Stage-3 execution observation test is missing or linked"
[[ -f "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source" \
    && ! -L "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source" ]] ||
    die "Stage-4 tiny durable multileaf authority is missing or linked"
[[ -f "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test" \
    && ! -L "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test" ]] ||
    die "Stage-4 tiny durable multileaf authority test is missing or linked"
[[ -f "$decoder_training_source" && ! -L "$decoder_training_source" ]] ||
    die "PrimeNativeDecoderTraining source is missing or linked"
[[ -f "$decoder_training_validation_manifest" \
    && ! -L "$decoder_training_validation_manifest" \
    && -f "$decoder_training_validation_lock" \
    && ! -L "$decoder_training_validation_lock" \
    && -f "$decoder_training_validation_test" \
    && ! -L "$decoder_training_validation_test" \
    && -f "$decoder_stage3_tiny_cpu_resume_test" \
    && ! -L "$decoder_stage3_tiny_cpu_resume_test" ]] ||
    die "PrimeNativeDecoder Stage-2 validation source set is missing or linked"
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
[[ -f "$decoder_checkpoint_v2_io_execution_failure_observation_source" \
    && ! -L "$decoder_checkpoint_v2_io_execution_failure_observation_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution failure observation is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair authority is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair evidence is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair observation is missing or linked"
[[ -f "$decoder_trajectory_exact_resume_design_authority_source" \
    && ! -L "$decoder_trajectory_exact_resume_design_authority_source" ]] ||
    die "PrimeNativeDecoder trajectory exact-resume design authority is missing or linked"
[[ -f "$decoder_trajectory_exact_resume_design_authority_test" \
    && ! -L "$decoder_trajectory_exact_resume_design_authority_test" ]] ||
    die "PrimeNativeDecoder trajectory exact-resume design test is missing or linked"
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
[[ -f "$decoder_checkpoint_v2_io_execution_failure_observation_test" \
    && ! -L "$decoder_checkpoint_v2_io_execution_failure_observation_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution failure-observation test is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair execution manifest is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_lock" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_lock" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair execution lock is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair execution probe is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_test" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair execution test is missing or linked"
[[ -f "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test" \
    && ! -L "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair execution observation test is missing or linked"
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
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservation.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$v2_io_execution_regular_source" | awk '{print $1}')" == "100644" ]] ||
        die "PrimeNativeDecoder checkpoint V2 I/O execution source mode changed: $v2_io_execution_regular_source"
done
for v2_io_root_identity_repair_execution_regular_source in \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift' \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservation.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved' \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift' \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests.swift'; do
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$v2_io_root_identity_repair_execution_regular_source" | awk '{print $1}')" \
        == "100644" ]] ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair execution source mode changed: $v2_io_root_identity_repair_execution_regular_source"
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
assert_checkpoint_v2_io_execution_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservation.swift' \
    '100644' \
    'ab6212e0499ae7aaa1da2cc66be8b67026f504c1' \
    '44667' \
    'e35bb2770a0b668fac0b9d26ea057ffe1837210abea0e30d8beb4ad4838e522f'
assert_checkpoint_v2_io_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift' \
    '100644' \
    '0ed3aa83f0dc16b0893655b9582985947509b919' \
    '16695' \
    '89ff93473e36ecc8a1fad38ef46c792ad0d12edee2508d91101d4df336cf7c2c'

assert_checkpoint_v2_io_root_identity_repair_execution_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "checkpoint V2 I/O root-identity repair source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "checkpoint V2 I/O root-identity repair source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "checkpoint V2 I/O root-identity repair source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "checkpoint V2 I/O root-identity repair source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "checkpoint V2 I/O root-identity repair source SHA-256 changed: $relative_path"
}

assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift' \
    '100644' \
    '244328c77fd20fb0338453e8d0ce9818e3470903' \
    '63136' \
    'df689547c1a60ec904ad4cf320581cd6740fca6e797fc2a7fc17a3d9f7ac9f2e'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift' \
    '100644' \
    '6edb77813df76adb8d7c84d8faf451e325634433' \
    '62078' \
    '3bd2fa7bd7ada430b05e16e28242e452ebcd8bd0fb8165ee17723efd44096de8'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservation.swift' \
    '100644' \
    '2e79695501fea9ce8ebbcf713a037a6190676f88' \
    '127248' \
    '1bd6ea60f5824e78e8f41bed84f397f5a85f1a90ba852afa4b64cf5d6d5efa78'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift' \
    '100644' \
    '1cc830db123defbf6a8c0f1362d6d2bb9d754d34' \
    '2226' \
    '0caa578cf38870dec6b12cced51859ebb5e3a75ecd30257b76e94c520690c1a4'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved' \
    '100644' \
    '315cda0e2afccd6fd0acac96e6a0b9bf76afbeca' \
    '645' \
    'b93b010098821b26f2efe368e71d1fcf6a2dcb83403962140dfb61f2f70b4c34'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift' \
    '100644' \
    '61f029352f7a27fa95b4a7b7238d58f1db834387' \
    '41866' \
    'bac43ad7e9e44cc02b3b2e51ecf17d1ffb184a086e3c0c5854c8f2ba67b7a504'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift' \
    '100644' \
    '8a7bbb1c147555a04e77937eda47b9938c6f742d' \
    '41659' \
    '07575be036b7901ac9c8adba11d1d35a71df453a00bf62e2a8435a6af3e86373'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    'Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests.swift' \
    '100644' \
    'afed0e75e6da05475e2d3decce058d81072c2b6a' \
    '39093' \
    '5a433b7dadc32894f442420b17f42ac84dd44aee180b4966839c65abeca14881'
assert_checkpoint_v2_io_root_identity_repair_execution_source_identity \
    '.github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh' \
    '100755' \
    'ed7852704219f61bc29841641257da697389458c' \
    '66828' \
    'f56adf9d50d96fc8d06bfbf1bbebd9ce054f4de4f2577e778fc5afb24bd93f7b'

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

assert_trajectory_exact_resume_design_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "trajectory exact-resume design source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "trajectory exact-resume design source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "trajectory exact-resume design source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "trajectory exact-resume design source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "trajectory exact-resume design source SHA-256 changed: $relative_path"
}

assert_trajectory_exact_resume_design_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift' \
    '100644' \
    '20bcbf28ddcfa9a6339510d53e81da02ada9953e' \
    '77582' \
    '92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969'
assert_trajectory_exact_resume_design_source_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests.swift' \
    '100644' \
    '186dc546c7f889f28d700322ac06b7b8a8a4c252' \
    '26700' \
    '1fc9d8a4dde9e5e4192de9c248076f218ea38094eb68c335ade6de50862eb58b'

assert_trajectory_design_timeout_observation_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "trajectory-design timeout observation source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "trajectory-design timeout observation source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "trajectory-design timeout observation source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "trajectory-design timeout observation source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "trajectory-design timeout observation source SHA-256 changed: $relative_path"
}

assert_trajectory_design_timeout_observation_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservation.swift' \
    '100644' \
    '26be0dbd5cec53fd9ea013a1c470106a4fbe4225' \
    '28691' \
    'af3ef53cd5da61f68ca7c0aa661dfd57d58679d36c382a1ba0a306bf251197d0'
assert_trajectory_design_timeout_observation_source_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests.swift' \
    '100644' \
    'a85c2ebd99b0a2f088b7f683795ed878877296e4' \
    '16123' \
    'a87f58cedd3143bb359a58d6185a5f1482fe2f825ac509ffc7f7414eab7ab05a'
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
[[ "$(wc -c < "$decoder_source" | awk '{print $1}')" == "39598" ]] ||
    die "PrimeNativeDecoder Stage-2 successor source byte count changed"
[[ "$(shasum -a 256 "$decoder_source" | awk '{print $1}')" \
    == "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994" ]] ||
    die "PrimeNativeDecoder Stage-2 successor source SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_source")" \
    == "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f" ]] ||
    die "PrimeNativeDecoder Stage-2 successor source blob changed"
[[ "$(wc -c < "$decoder_validation_test" | awk '{print $1}')" == "40513" ]] ||
    die "PrimeNativeDecoder repaired regression byte count changed"
[[ "$(shasum -a 256 "$decoder_validation_test" | awk '{print $1}')" \
    == "ee612ac7b02e759fdb556d1f29d4f1327da3d9bb39f6e20090a8d862b2a5c53f" ]] ||
    die "PrimeNativeDecoder repaired regression SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_validation_test")" \
    == "0162a60c422de7d05abbdd6932420930adcd5813" ]] ||
    die "PrimeNativeDecoder repaired regression blob changed"
[[ "$(wc -c < "$decoder_authority_test" | awk '{print $1}')" == "35548" ]] ||
    die "PrimeNativeDecoder current-decoder assertion repair test byte count changed"
[[ "$(shasum -a 256 "$decoder_authority_test" | awk '{print $1}')" \
    == "40c65bd0169ed5af08248acb38b5b287a82894fec8e8f2c2808f348e3cd50373" ]] ||
    die "PrimeNativeDecoder current-decoder assertion repair test SHA-256 changed"
[[ "$(git -C "$prime_root" hash-object "$decoder_authority_test")" \
    == "329e57a8cbb2aa55879a94c88b17c391d13a1eb4" ]] ||
    die "PrimeNativeDecoder current-decoder assertion repair test blob changed"
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
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_failure_observation_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source"
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
swiftc -frontend -parse "$decoder_checkpoint_v2_io_execution_failure_observation_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_test"
swiftc -frontend -parse "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test"
swiftc -frontend -parse "$decoder_runtime_closure_probe"
swiftc -frontend -parse "$decoder_runtime_closure_test"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_probe"
swiftc -frontend -parse "$decoder_tokenizer_compatibility_test"
swiftc -frontend -parse "$decoder_tiny_cpu_mechanics_authority_source"
swiftc -frontend -parse "$decoder_tiny_cpu_mechanics_authority_test"
swiftc -frontend -parse "$decoder_tiny_cpu_mechanics_failure_observation_source"
swiftc -frontend -parse "$decoder_tiny_cpu_mechanics_failure_observation_test"
swiftc -frontend -parse "$private_dependency_tls_failure_observation_source"
swiftc -frontend -parse "$private_dependency_tls_failure_observation_test"
swiftc -frontend -parse "$metal_current_decoder_identity_assertion_failure_observation_source"
swiftc -frontend -parse "$metal_current_decoder_identity_assertion_failure_observation_test"
swiftc -frontend -parse "$metal_current_decoder_identity_assertion_repair_authority_source"
swiftc -frontend -parse "$metal_current_decoder_identity_assertion_repair_authority_test"
swiftc -frontend -parse "$stage2_metallib_bootstrap_repair_authority_source"
swiftc -frontend -parse "$stage2_metallib_bootstrap_repair_authority_test"
swiftc -frontend -parse "$stage2_metallib_bootstrap_repair_failure_observation_source"
swiftc -frontend -parse "$stage2_metallib_bootstrap_repair_failure_observation_test"
swiftc -frontend -parse "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source"
swiftc -frontend -parse "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test"
swiftc -frontend -parse "$stage2_fresh_metallib_cross_binding_failure_observation_source"
swiftc -frontend -parse "$stage2_fresh_metallib_cross_binding_failure_observation_test"
swiftc -frontend -parse "$stage2_fresh_metallib_evidence_surface_repair_authority_source"
swiftc -frontend -parse "$stage2_fresh_metallib_evidence_surface_repair_authority_test"
swiftc -frontend -parse "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source"
swiftc -frontend -parse "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source"
swiftc -frontend -parse "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test"
swiftc -frontend -parse "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source"
swiftc -frontend -parse "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test"
swiftc -frontend -parse "$decoder_training_source"
swiftc -frontend -parse "$decoder_training_validation_test"
swiftc -frontend -parse "$decoder_stage3_tiny_cpu_resume_test"

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
    "$decoder_checkpoint_v2_io_execution_failure_observation_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution failure-observation imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_evidence_source" | paste -sd, -)" \
    == "Foundation,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution evidence imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source" | paste -sd, -)" \
    == "Foundation" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair authority imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source" | paste -sd, -)" \
    == "Foundation,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair evidence imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source" | paste -sd, -)" \
    == "Foundation,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair observation imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_probe" | paste -sd, -)" \
    == "CoreGraphics,Darwin,Foundation,Metal,MLX,MLXNN,PrimeCore,PrimeNativeDecoder,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution probe imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution test imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_execution_failure_observation_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O execution failure-observation test imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | paste -sd, -)" \
    == "CoreGraphics,Darwin,Foundation,Metal,MLX,MLXNN,PrimeCore,PrimeNativeDecoder,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair probe imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair test imports changed"
[[ "$(awk '/^import / {print $2}' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test" | paste -sd, -)" \
    == "CoreFoundation,Foundation,XCTest,PrimeCore,PrimeNativeDecoderCheckpoint" ]] ||
    die "PrimeNativeDecoderCheckpoint V2 I/O root-identity repair observation test imports changed"
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
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_checkpoint_v2_io_execution_failure_observation_test")" == "1" \
    && "$(grep -ER -- '^[[:space:]]+func test' \
        "$decoder_checkpoint_v2_io_execution_validation_root/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests" \
        | wc -l | awk '{print $1}')" == "2" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O execution target must contain exactly two pure tests"
[[ "$(grep -Fc -- '.package(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest")" \
    == "2" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair execution dependency count changed"
for required_checkpoint_v2_io_root_identity_repair_execution_product in \
    'name: "PrimeCore"' \
    'name: "PrimeNativeDecoder"' \
    'name: "PrimeNativeDecoderCheckpoint"' \
    'name: "MLX"' \
    'name: "MLXNN"'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_execution_product" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair manifest is missing: $required_checkpoint_v2_io_root_identity_repair_execution_product"
done
grep -Fq -- "$root_mlx_revision" \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_manifest" ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair manifest does not pin active MLX"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_test")" == "1" \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test")" == "1" \
    && "$(grep -ER -- '^[[:space:]]+func test' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_validation_root/Tests" \
        | wc -l | awk '{print $1}')" == "2" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair target must contain exactly two pure tests"
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

for required_checkpoint_v2_io_execution_failure_test_value in \
    'func testFailedAttemptObservationIsExactExhaustedAndPure()' \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1' \
    'try observation.validateExactV1()' \
    'observation.runID, 31_472_165_002' \
    'observation.reviewedMainJobID, 93_718_282_081' \
    'observation.publicCheckpointWriteCompletionCountSourceInferred' \
    'observation.externalBindingReturnSourceInferred' \
    'observation.externalBindingFieldsIndependentlyObserved' \
    'observation.publicCheckpointLoadInvocationCountSourceInferred' \
    'observation.receiptBeginMarkerCount' \
    'observation.parentArtifactUnlinkCompleted' \
    'observation.eventualRunnerVMCleanupObserved' \
    'ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission' \
    'let mutations = recursiveMutations(of: object, path: "$root")' \
    'XCTAssertGreaterThan(mutations.count, 200)' \
    'XCTAssertGreaterThan(decodedMutationCount, 150)' \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError' \
    '.contractDrift'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_failure_test_value" \
        "$decoder_checkpoint_v2_io_execution_failure_observation_test" ||
        die "PrimeNativeDecoder checkpoint V2 I/O failure-observation test lost: $required_checkpoint_v2_io_execution_failure_test_value"
done
for forbidden_checkpoint_v2_io_execution_failure_test_value in \
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
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_failure_test_value" \
        "$decoder_checkpoint_v2_io_execution_failure_observation_test"; then
        die "PrimeNativeDecoder checkpoint V2 I/O failure-observation test gained execution capability: $forbidden_checkpoint_v2_io_execution_failure_test_value"
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

for required_checkpoint_v2_io_execution_failure_observation_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1:' \
    'PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError' \
    'case contractDrift' \
    'public static let frozenV1 = Self(' \
    'try predecessor.validateExactV1()' \
    'self == expected,' \
    'observedSourceBindings.count == 10,' \
    '"ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_failure_observation_v1"' \
    '"27749af3347437daa693d4375acb759283923a4a"' \
    '"a222082fa6b5c469cc4da967a77cbb7e4960e455"' \
    'runID: 31_472_165_002,' \
    'runNumber: 51,' \
    'runAttempt: 1,' \
    'runConclusion: "failure",' \
    'activeRootJobID: 93_717_678_740,' \
    'activeRootJobSucceeded: true,' \
    'reviewedMainJobID: 93_718_282_081,' \
    'reviewedMainJobConclusion: "failure",' \
    'renderedJobLogsBound: true,' \
    'rawGitHubLogArchiveBytesBound: false,' \
    'publishedWorkflowArtifactCount: 0,' \
    'checkpointArtifactUploaded: false,' \
    'freshMetallibBuildSucceeded: true,' \
    'predecessorMetalGateSucceeded: true,' \
    'predecessorMaintainedRuntimeClosureSucceeded: true,' \
    'predecessorTokenizerCompatibilitySucceeded: true,' \
    'predecessorValidatedLogCount: 8,' \
    'predecessorValidatedReceiptCount: 2,' \
    'authorizedRunnerTemporaryReclamationCompleted: true,' \
    '"prime-native-decoder-checkpoint-v2-io-execution-probe: contract drift: artifact root changed identity during write"' \
    'probeProcessExitCode: 2,' \
    'receiptBeginMarkerCount: 0,' \
    'receiptChunkMarkerCount: 0,' \
    'receiptEndMarkerCount: 0,' \
    'executionEvidenceValueConstructed: false,' \
    'canonicalReceiptConstructed: false,' \
    'canonicalReceiptEmitted: false,' \
    'initializationSeed: 42,' \
    'publicCheckpointWriteInvocationCountSourceInferred: 1,' \
    'publicCheckpointWriteCompletionCountSourceInferred: 1,' \
    'externalBindingReturnSourceInferred: true,' \
    'externalBindingFieldsIndependentlyObserved: false,' \
    'publicCheckpointLoadInvocationCountSourceInferred: 0,' \
    'publicCheckpointLoadCompletionCountSourceInferred: 0,' \
    'postWriteRootStableObjectIdentityGuardPassed: false,' \
    'publishedArtifactPathInspectionCompleted: false,' \
    'artifactRootChangedFieldIdentifiedByRun: false,' \
    'localDiagnosticRootLinkCountBeforeLeafAddition: 2,' \
    'localDiagnosticRootLinkCountAfterLeafAddition: 3,' \
    'localDiagnosisIsFailedRunTelemetry: false,' \
    'parentReceiptVerificationCompleted: false,' \
    'parentArtifactUnlinkCompleted: false,' \
    'parentArtifactRootRmdirCompleted: false,' \
    'eventualRunnerVMCleanupObserved: false,' \
    'predecessorAuthorityAttemptConsumed: true,' \
    'predecessorAuthorityExhausted: true,' \
    'rerunObserved: false,' \
    'rerunAuthorized: false,' \
    'replacementExecutionAuthorityEstablished: false,' \
    'checkpointArtifactAvailabilityEstablished: false,' \
    'checkpointArtifactRetentionEstablished: false,' \
    'checkpointContainerHashIndependentlyObserved: false,' \
    'checkpointIORoundTripObserved: false,' \
    'checkpointAdmissionGranted: false,' \
    'optimizerStateInclusionObservedByCheckpointAttempt: false,' \
    'rngStateInclusionObservedByCheckpointAttempt: false,' \
    'dataCursorInclusionObservedByCheckpointAttempt: false,' \
    'kvCacheStateInclusionObservedByCheckpointAttempt: false,' \
    'trainingExecutionObserved: false,' \
    'publicationAuthorized: false,' \
    '"ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission"' \
    '"require_a_separate_successor_execution_authority_before_any_new_attempt"'; do
    grep -Fq -- "$required_checkpoint_v2_io_execution_failure_observation_value" \
        "$decoder_checkpoint_v2_io_execution_failure_observation_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O failure observation lost: $required_checkpoint_v2_io_execution_failure_observation_value"
done
for forbidden_checkpoint_v2_io_execution_failure_observation_capability in \
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
    if grep -Fq -- "$forbidden_checkpoint_v2_io_execution_failure_observation_capability" \
        "$decoder_checkpoint_v2_io_execution_failure_observation_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O failure observation owns forbidden capability: $forbidden_checkpoint_v2_io_execution_failure_observation_capability"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_authority_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1:' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1:' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityComparatorV1' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairComparatorProofV1' \
    '"PINNED_AFTER_SOURCE_STABILIZATION"' \
    'Set(newExecutionSourceBindings.map(\.path)).count == 6' \
    'publicationStableObjectFieldsEqual(' \
    'readOnlyFullIdentityEqual(' \
    'rootLinkCountEqualityAcrossPublicationRequired: false,' \
    'rootTimestampsEqualityAcrossPublicationRequired: false,' \
    'rootFullIdentityEqualityAcrossReadOnlyLoadRequired: true,' \
    'linkCountBeforeWrite: 2,' \
    'linkCountAfterWrite: 3,' \
    'linkCountAfterLoad: 3,' \
    'exhaustedSeed42PublicWriteCompletionCountSourceInferred: 1,' \
    'exhaustedSeed42PublicLoadCompletionCountSourceInferred: 0,' \
    'cumulativePublicWriteCompletionCountSourceInferredAfterSuccess: 2,' \
    'cumulativePublicLoadCompletionCountSourceInferredAfterSuccess: 1,' \
    'predecessorValidatedLogCount: 10,' \
    'predecessorValidatedReceiptCount: 2,' \
    'reclaimableRunnerTemporaryRelativePaths.count == 32,' \
    'requiredDirectSuccessorFirstParentRevision:' \
    '"1a69407a8fbd5f141e8ece584066b8dcfa6f606f"' \
    'requiredExecutionRunAttempt: 1,' \
    'localOrManualExecutionAuthorized: false,' \
    'rerunExecutionAuthorized: false,' \
    'laterMainExecutionAuthorized: false,' \
    'executionRetryAuthorized: false,' \
    'reviewedMainTimeoutBeforeMinutes: 45,' \
    'reviewedMainTimeoutAfterMinutes: 90,' \
    'reviewedMainCheckoutFetchDepthBefore: 1,' \
    'reviewedMainCheckoutFetchDepthDuringExecution: 2,' \
    'receiptChunkCharacterCount: 4_096,' \
    'maximumReceiptChunkCount: 86,' \
    'maximumCanonicalReceiptByteCount: 262_144,' \
    'supervisorPostReceiptIndependentWholeFileHashAuthorized: false,' \
    'supervisorPostReceiptRootIdentityAndInventoryVerificationAuthorized:' \
    'supervisorCleanupUnlinkCount: 1,' \
    'supervisorCleanupRmdirCount: 1,' \
    'supervisorCleanupRecursiveDeletionAuthorized: false,' \
    'parentReceiptVerificationRequiredBeforeSuccessCleanup: true,' \
    'receiptMayClaimSuccessCleanupCompleted: false,' \
    'boundedFailureCleanupAuthorized: true,' \
    'boundedFailureCleanupRequiresExactKnownRoot: true,' \
    'boundedFailureCleanupAllowsOnlyEmptyRootOrFixedLeaf: true,' \
    'boundedFailureCleanupRecursiveDeletionAuthorized: false,' \
    'boundedFailureCleanupProducesSuccessEvidence: false,' \
    'initializationSeed: 43,' \
    'native300MCheckpointWriteAuthorized: true,' \
    'native300MCheckpointLoadAuthorized: true,' \
    'checkpointArtifactRetentionAuthorized: false,' \
    'checkpointArtifactUploadAuthorized: false,' \
    'checkpointArtifactAdmissionAuthorized: false,' \
    'decoderForwardAuthorized: false,' \
    'backwardAuthorized: false,' \
    'trainingAuthorized: false,' \
    'native300MCheckpointWriteObserved: false,' \
    'native300MCheckpointLoadObserved: false,' \
    'checkpointIOObserved: false,' \
    '"ABSTAIN_exact_seed43_native300m_v2_checkpoint_root_identity_repair_one_write_one_load_authorized_not_observed_no_artifact_admission"'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_authority_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair authority lost: $required_checkpoint_v2_io_root_identity_repair_authority_value"
done
for forbidden_checkpoint_v2_io_root_identity_repair_authority_capability in \
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
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_authority_capability" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_authority_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair authority owns forbidden capability: $forbidden_checkpoint_v2_io_root_identity_repair_authority_capability"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_evidence_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1:' \
    'try externalBinding.validate()' \
    'public func canonicalReceiptData() throws -> Data {' \
    'public static func decodeCanonicalReceipt(' \
    'predecessorFailureObservationConsumedByAuthoritySource' \
    'exhaustedSeed42PublicWriteCompletionCountSourceInferred' \
    'cumulativePublicWriteCompletionCountSourceInferredAfterSuccess' \
    'artifactRootEntryNamesBeforeWrite' \
    'artifactRootEntryNamesAfterWrite' \
    'publishedArtifactIsRegularFile' \
    'publishedArtifactDeviceMatchedRoot' \
    'publishedArtifactOwnerMatchedEffectiveUser' \
    'publicationStableFiveFieldsMatched' \
    'publicationRootLinkCountsPositive' \
    'readOnlyFullRootIdentityMatched' \
    'publicCheckpointWriteInvocationCount' \
    'publicCheckpointWriteCompletionCount' \
    'publicCheckpointLoadInvocationCount' \
    'publicCheckpointLoadCompletionCount' \
    'native300MCheckpointWriteObserved' \
    'native300MCheckpointLoadObserved' \
    'checkpointArtifactAvailableDuringProcess' \
    'logicalParameterRoundTripViaPinnedCodecObserved' \
    '!independentPostLoadTensorHashReplayObserved' \
    '!independentPostLoadArtifactRootVerifyObserved' \
    '!artifactUploadInvokedBeforeReceipt' \
    '!checkpointArtifactAvailabilityBeyondProcessEstablished' \
    '!checkpointArtifactRetentionEstablished' \
    '!checkpointArtifactProvenanceEstablished' \
    '!checkpointAdmissionGranted' \
    '!checkpointLoadedForwardObserved' \
    '!backwardInvoked' \
    '!generationInvoked' \
    '!trainingExecutionObserved' \
    '!productUseAuthorized' \
    '!publicationAuthorized' \
    '!retryObserved' \
    '!successCleanupCompletedBeforeReceipt' \
    'parentSuccessCleanupRequiredAfterReceipt' \
    '"PASS_process_local_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_only"'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_evidence_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair evidence lost: $required_checkpoint_v2_io_root_identity_repair_evidence_value"
done
for forbidden_checkpoint_v2_io_root_identity_repair_evidence_capability in \
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
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_evidence_capability" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_evidence_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair evidence owns forbidden capability: $forbidden_checkpoint_v2_io_root_identity_repair_evidence_capability"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_observation_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError' \
    'case contractDrift' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationV1:' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1' \
    'public static let frozenV1: Self = {' \
    'public func validateExactV1() throws {' \
    'try authority.validateExactV1()' \
    'try receiptEvidence.validate()' \
    'receiptData = try receiptEvidence.canonicalReceiptData()' \
    'self == expected,' \
    'observedSourceBindings.map(\.path) == expectedSourcePaths' \
    'observedSourceBindings.count == 10' \
    'Set(observedSourceBindings.map(\.path)).count == 10' \
    'allObservedSourceHashesAreExactLowercaseHex' \
    '"ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_observation_v1"' \
    '"github_reviewed_main_exact_one_shot_checkpoint_v2_io_root_identity_repair_success_observation"' \
    'observedPullRequestNumber: 79,' \
    '"https://github.com/Ergentics/ergentics-prime/pull/79"' \
    '"44cfa2caa3af5bb44ad53294de33ba2d0faa9a59"' \
    '"1a69407a8fbd5f141e8ece584066b8dcfa6f606f"' \
    '"7314b8a85c5f134c9521b84d2d51d12d3d5084bb"' \
    '"fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c"' \
    '"d1aa5b2352ebcf3595b5221f9bb784c610175ce3acc27d963d833cef85c57a90"' \
    'historyPreservingTwoParentMergeObserved: true,' \
    'mergeTreeEqualsReviewedHeadTree: true,' \
    'exactDirectSuccessorOfAuthorizedBaseObserved: true,' \
    '".github/scripts/prime-ci-active-root-quarantine.sh"' \
    '"50ee76136a5d11a24119dc78053b357ab21cd1a3"' \
    'byteCount: 200_218,' \
    '"303658f5ffb680bf1536eb2ff76ec6d4b0994dd0c24cdd0ab887979387811f96"' \
    '".github/workflows/prime-active-root-quarantine.yml"' \
    '"f6d64634d66734a73061c9b93823ab7098776904"' \
    'byteCount: 33_497,' \
    '"0d98ca3634658693492e822a84b94f02f43850ecb54d5e690a94e5cd027407b6"' \
    '"Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"' \
    '"610eb14185e746dcb24c26b780f56d70925f3af7"' \
    '"df3efa4ef8242674a1fe85220ddf13af8f05cb465a1cf08ba67518010503e31c"' \
    'workflowID: 329_017_041,' \
    'runID: 31_484_642_403,' \
    'runNumber: 55,' \
    'runAttempt: 1,' \
    'runCreatedAt: "2026-08-11T10:59:42Z",' \
    'runStartedAt: "2026-08-11T10:59:42Z",' \
    'runUpdatedAt: "2026-08-11T11:42:44Z",' \
    'runStatus: "completed",' \
    'runConclusion: "success",' \
    'activeRootJobID: 93_757_136_546,' \
    'activeRootJobStartedAt: "2026-08-11T10:59:45Z",' \
    'activeRootJobCompletedAt: "2026-08-11T11:02:15Z",' \
    'activeRootJobConclusion: "success",' \
    'reviewedMainJobID: 93_757_733_456,' \
    'reviewedMainJobStartedAt: "2026-08-11T11:02:18Z",' \
    'reviewedMainJobCompletedAt: "2026-08-11T11:42:43Z",' \
    'reviewedMainJobConclusion: "success",' \
    'reviewedMainRanAfterActiveRootSuccess: true,' \
    'liveStepStartedAt: "2026-08-11T11:15:26Z",' \
    'liveStepCompletedAt: "2026-08-11T11:42:37Z",' \
    'liveStepConclusion: "success",' \
    '"bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh"' \
    '.observationSuccessorMustRemoveLiveLauncherCommandBeforeMerge' \
    'consumedLiveLauncherPath' \
    '== observedSourceBindings[6].path' \
    'liveRepairCommandRetired: true,' \
    'retiredLauncherSourceRemainsFrozen: true,' \
    'consumedLiveExecutionReexecutionAuthorized: false,' \
    'reviewedMainTimeoutDuringObservedExecutionMinutes == 90' \
    'reviewedMainTimeoutRestoredAfterObservationMinutes == 45' \
    'reviewedMainTimeoutRestoredToOrdinary45Minutes: true,' \
    'reviewedMainCheckoutFetchDepthDuringObservedExecution == 2' \
    'reviewedMainCheckoutFetchDepthRestoredAfterObservation == 1' \
    'reviewedMainCheckoutDepthRestoredToOne: true,' \
    'activeJobTransportDecodedUTF8LogByteCount: 225_372,' \
    'activeJobTransportDecodedUTF8LogSplitLineCount: 1_717,' \
    '"a6f948b106edb307a3a826af74bdc82398afba6b1961359e77ec79bb9f069de8"' \
    'reviewedMainJobTransportDecodedUTF8LogByteCount: 10_348_719,' \
    'reviewedMainJobTransportDecodedUTF8LogSplitLineCount: 78_565,' \
    '"caa3e223077cca02d917d2814668a2dc4e36d5e8eed3f60c76689821ed53e588"' \
    '"github_connector_transport_decoded_utf8_text_bom_included_response_wrapper_excluded"' \
    'decodedJobLogsIncludedUTF8BOM: true,' \
    'connectorResponseWrapperExcludedFromLogIdentity: true,' \
    'decodedJobLogsBound: true,' \
    'rawGitHubLogArchiveBytesBound: false,' \
    'jobLogsRetainedInRepository: false,' \
    'durableJobLogPublicationEstablished: false,' \
    'reviewedMainErrorAnnotationCount: 0,' \
    'publishedWorkflowArtifactCount: 0,' \
    'checkpointArtifactUploaded: false,' \
    'receiptBeginMarkerCount: 1,' \
    'receiptChunkMarkerCount: 26,' \
    'receiptEndMarkerCount: 1,' \
    'receiptFirstChunkOrdinal: "000000",' \
    'receiptLastChunkOrdinal: "000025",' \
    'receiptChunkCharacterCount: 4_096,' \
    'receiptFinalChunkCharacterCount: 540,' \
    'receiptBase64CharacterCount: 102_940,' \
    'receiptCanonicalByteCount: 77_205,' \
    '"b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf"' \
    'compatibilityIdentityCanonicalByteCount: 30_553,' \
    '"aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843"' \
    'tensorBindingsCanonicalByteCount: 35_184,' \
    '"7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566"' \
    'manifestCanonicalByteCount: 66_373,' \
    '"6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3"' \
    'externalBindingCanonicalByteCount: 66_854,' \
    '"c5a9b8a8aa4301f2dde0ab199bc39771298b1842009836537a085ba4b676d961"' \
    'receiptTransportWasOrderedContiguousAndFinal: true,' \
    'beforeWrite.deviceID == 16_777_230' \
    'beforeWrite.inode == 2_970_995' \
    'beforeWrite.ownerUserID == 501' \
    'beforeWrite.ownerGroupID == 20' \
    'beforeWrite.permissionMode == 0o700' \
    'beforeWrite.linkCount == 2' \
    'beforeWrite.publicationStableObjectFieldsEqual(' \
    'afterWrite.linkCount == 3' \
    'afterLoad.linkCount == 3' \
    'afterWrite.readOnlyFullIdentityEqual(to: afterLoad)' \
    '"checkpoint-v2-native300m-seed43-root-identity-repair.safetensors"' \
    'artifact.byteCount == 1_084_525_304' \
    '"a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538"' \
    'receiptEvidence.publishedArtifactMode == 0o444' \
    'receiptEvidence.publishedArtifactLinkCount == 1' \
    'receiptEvidence.publicCheckpointWriteCompletionCount == 1' \
    'receiptEvidence.publicCheckpointLoadCompletionCount == 1' \
    '"public_checkpoint_write_invocation_count":1' \
    '"public_checkpoint_write_completion_count":1' \
    '"public_checkpoint_load_invocation_count":1' \
    '"public_checkpoint_load_completion_count":1' \
    'exactParentPostReceiptVerificationSourceLineRange' \
    '== [1_156, 1_175]' \
    'exactParentArtifactUnlinkSourceLine == 1_176' \
    'exactParentArtifactRootRmdirSourceLine == 1_177' \
    '== [1_178, 1_180]' \
    'receiptEndObservedAt: "2026-08-11T11:42:37.6029040Z",' \
    '"2026-08-11T11:42:37.8067580Z"' \
    'receiptEndObservedAt < parentCleanupSuccessObservedAt' \
    'receiptEndPrecededParentCleanup: true,' \
    'parentReceiptVerificationCompleted: true,' \
    'parentArtifactUnlinkCompleted: true,' \
    'parentArtifactRootRmdirCompleted: true,' \
    'parentLiteralCleanupPostconditionCompleted: true,' \
    '!parentCleanupWasIndependentRetainedFilesystemObservation' \
    'failureTrapCleanupEstablishedSuccess: false,' \
    'predecessorAuthorityAttemptConsumed: true,' \
    'predecessorAuthorityExhausted: true,' \
    'rerunObserved: false,' \
    'rerunAuthorized: false,' \
    'replacementExecutionAuthorityEstablished: false,' \
    'executionReceiptSourceAndRunBindingEstablished: true,' \
    'native300MModelAllocationObserved: true,' \
    'native300MCheckpointWriteObserved: true,' \
    'native300MCheckpointLoadObserved: true,' \
    'checkpointIOObserved: true,' \
    'checkpointArtifactAvailableDuringProcess: true,' \
    'checkpointContainerHashBound: true,' \
    'checkpointDurabilityMechanicsCompleted: true,' \
    'logicalParameterRoundTripViaPinnedCodecObserved: true,' \
    'publicationStableFiveFieldsMatched: true,' \
    'publicationRootLinkCountTransitionObserved: true,' \
    'readOnlyFullRootIdentityMatched: true,' \
    'allArtifactAdmissionTrainingAndProductCeilingsAreFalse' \
    '!checkpointArtifactAvailabilityBeyondProcessEstablished' \
    '&& !checkpointArtifactRetentionEstablished' \
    '&& !checkpointArtifactProvenanceEstablished' \
    '&& !checkpointAdmissionGranted' \
    '&& !existingCheckpointArtifactCompatibilityObserved' \
    '&& !atomicCheckpointReplacementEstablished' \
    '&& !failedCheckpointWriteRecoveryObserved' \
    '&& !independentPostLoadTensorHashReplayObserved' \
    '&& !independentCodecComparatorObserved' \
    '&& !independentPostLoadArtifactRootVerifyObserved' \
    '&& !checkpointLoadedForwardObserved' \
    '&& !checkpointRoundTripBehaviorParityEstablished' \
    '&& !optimizerStateIncluded' \
    '&& !rngStateIncluded' \
    '&& !dataCursorIncluded' \
    '&& !kvCacheStateIncluded' \
    '&& !decoderForwardObserved' \
    '&& !decoderKVCacheUsed' \
    '&& !backwardInvoked' \
    '&& !lossObserved' \
    '&& !optimizerStepObserved' \
    '&& !generationInvoked' \
    '&& !trainEvaluateSurfaceEstablished' \
    '&& !trainingResumeEstablished' \
    '&& !trainingExecutionObserved' \
    '&& !modelQualityEstablished' \
    '&& !candidateAdmissionGranted' \
    '&& !trialAuthorized' \
    '&& !canaryReplacementAuthorized' \
    '&& !quantizationAuthorized' \
    '&& !productUseAuthorized' \
    '&& !publicationAuthorized' \
    '"ABSTAIN_exact_reviewed_main_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_parent_verified_ephemeral_cleanup_observed_no_artifact_retention_provenance_or_admission"'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_observation_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair observation lost: $required_checkpoint_v2_io_root_identity_repair_observation_value"
done

for forbidden_checkpoint_v2_io_root_identity_repair_observation_capability in \
    'FileManager' \
    'FileHandle' \
    'URL(' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'PrimeArtifactRoot(' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    '.writeNative300MByte512(' \
    '.loadNative300MByte512(' \
    'Memory.clearCache()' \
    'import MLX' \
    'import Metal' \
    'Process()'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_observation_capability" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_source"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair observation owns forbidden capability: $forbidden_checkpoint_v2_io_root_identity_repair_observation_capability"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_probe_value in \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1' \
    '.validateLaunchedCurrentProcess()' \
    'PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()' \
    'let model = PrimeNativeGQADecoder.make(' \
    'model.train(false)' \
    'try checkedEval(model)' \
    '.writeNative300MByte512(' \
    '.loadNative300MByte512(' \
    'let rootBeforeWrite = executionRootIdentity(' \
    'let rootAfterWrite = executionRootIdentity(' \
    'let rootAfterLoad = executionRootIdentity(' \
    '.validatePublicationTransition(' \
    '.validateReadOnlyTransition(' \
    'try evidence.validate()' \
    'try emitChunkedReceipt(evidence)'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_probe_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair probe lost: $required_checkpoint_v2_io_root_identity_repair_probe_value"
done
[[ "$(grep -Fc -- 'let model = PrimeNativeGQADecoder.make(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- 'model.train(false)' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- 'try checkedEval(model)' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- '.writeNative300MByte512(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- '.loadNative300MByte512(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- 'Memory.clearCache()' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "2" \
    && "$(grep -Fc -- 'let rootBeforeWrite = executionRootIdentity(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- 'let rootAfterWrite = executionRootIdentity(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- 'let rootAfterLoad = executionRootIdentity(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- '.validatePublicationTransition(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" \
    && "$(grep -Fc -- '.validateReadOnlyTransition(' \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe")" == "1" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair probe call counts changed"
for forbidden_checkpoint_v2_io_root_identity_repair_probe_value in \
    '.forward(' \
    'forward(tokenIDs:' \
    'callAsFunction(' \
    'valueAndGrad' \
    'argmax' \
    'optimizer.step' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'PrimeNativeDecoderCheckpointV1'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_probe_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair probe contains forbidden value: $forbidden_checkpoint_v2_io_root_identity_repair_probe_value"
    fi
done
if grep -Eq -- \
    '(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe"; then
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair probe contains standalone Process"
fi

readonly checkpoint_v2_io_root_repair_environment_first="$(grep -nF -- \
    '.validateLaunchedCurrentProcess()' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: 'NR == 1 {print $1}')"
readonly checkpoint_v2_io_root_repair_root_before="$(grep -nF -- \
    'let rootBeforeWrite = executionRootIdentity(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_cache_lines="$(grep -nF -- \
    'Memory.clearCache()' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_cache_first="$(printf '%s\n' \
    "$checkpoint_v2_io_root_repair_cache_lines" | awk 'NR == 1')"
readonly checkpoint_v2_io_root_repair_cache_second="$(printf '%s\n' \
    "$checkpoint_v2_io_root_repair_cache_lines" | awk 'NR == 2')"
readonly checkpoint_v2_io_root_repair_write="$(grep -nF -- \
    'let binding = try writeCallerSourceModel(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_publication_validation="$(grep -nF -- \
    '.validatePublicationTransition(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_load="$(grep -nF -- \
    'let structure = try loadAndInspectStructure(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_read_validation="$(grep -nF -- \
    '.validateReadOnlyTransition(' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_evidence="$(grep -nF -- \
    'try evidence.validate()' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
readonly checkpoint_v2_io_root_repair_receipt="$(grep -nF -- \
    'try emitChunkedReceipt(evidence)' \
    "$decoder_checkpoint_v2_io_root_identity_repair_execution_probe" | awk -F: '{print $1}')"
[[ "$checkpoint_v2_io_root_repair_environment_first" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_root_before" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_cache_first" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_write" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_publication_validation" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_cache_second" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_load" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_read_validation" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_evidence" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_receipt" =~ ^[1-9][0-9]*$ \
    && "$checkpoint_v2_io_root_repair_environment_first" -lt "$checkpoint_v2_io_root_repair_root_before" \
    && "$checkpoint_v2_io_root_repair_root_before" -lt "$checkpoint_v2_io_root_repair_cache_first" \
    && "$checkpoint_v2_io_root_repair_cache_first" -lt "$checkpoint_v2_io_root_repair_write" \
    && "$checkpoint_v2_io_root_repair_write" -lt "$checkpoint_v2_io_root_repair_publication_validation" \
    && "$checkpoint_v2_io_root_repair_publication_validation" -lt "$checkpoint_v2_io_root_repair_cache_second" \
    && "$checkpoint_v2_io_root_repair_cache_second" -lt "$checkpoint_v2_io_root_repair_load" \
    && "$checkpoint_v2_io_root_repair_load" -lt "$checkpoint_v2_io_root_repair_read_validation" \
    && "$checkpoint_v2_io_root_repair_read_validation" -lt "$checkpoint_v2_io_root_repair_evidence" \
    && "$checkpoint_v2_io_root_repair_evidence" -lt "$checkpoint_v2_io_root_repair_receipt" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair probe execution order changed"

for required_checkpoint_v2_io_root_identity_repair_test_value in \
    'func testExecutionAuthorityEvidenceAndTransportAreExactAndPure()' \
    '"PINNED_AFTER_SOURCE_STABILIZATION"' \
    'XCTAssertEqual(authority.newExecutionSourceBindings.count, 6)' \
    'XCTAssertEqual(authority.predecessorValidatedLogCount, 10)' \
    'authority.reclaimableRunnerTemporaryRelativePaths.count,' \
    'XCTAssertFalse(' \
    'authority.rootLinkCountEqualityAcrossPublicationRequired' \
    'authority.rootTimestampsEqualityAcrossPublicationRequired' \
    '.validatePublicationTransition(' \
    '.validateReadOnlyTransition(' \
    'oldRootBefore.stableObjectFieldsEqual(to: oldRootAfter)' \
    'let receipt = try evidence.canonicalReceiptData()' \
    '.decodeCanonicalReceipt(from: receipt)' \
    'for key in authorityBooleanKeys {' \
    'for key in evidenceBooleanKeys {' \
    'try assertAuthoritySourceBindingMutation("reorder")' \
    'try assertEvidenceMutation("post-load root timestamp")' \
    'try assertEvidenceMutation("post-load root inode")'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_test_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_test" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair test lost: $required_checkpoint_v2_io_root_identity_repair_test_value"
done
for forbidden_checkpoint_v2_io_root_identity_repair_test_value in \
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
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_test_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_test"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair test gained execution capability: $forbidden_checkpoint_v2_io_root_identity_repair_test_value"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_observation_test_value in \
    'func testExecutionObservationIsExactExhaustedRetiredAndPure() throws {' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationV1' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError' \
    'PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1' \
    'let observation = Observation.frozenV1' \
    'try observation.validateExactV1()' \
    'let expectedSources = [' \
    'observation.observedSourceBindings.count' \
    'Set(observation.observedSourceBindings.map(\.path)).count' \
    'try actual.validate()' \
    'XCTAssertEqual(observation.runID, 31_484_642_403)' \
    'XCTAssertEqual(observation.activeRootJobID, 93_757_136_546)' \
    'XCTAssertEqual(observation.reviewedMainJobID, 93_757_733_456)' \
    'XCTAssertTrue(observation.liveRepairCommandRetired)' \
    'XCTAssertTrue(observation.retiredLauncherSourceRemainsFrozen)' \
    'XCTAssertFalse(observation.consumedLiveExecutionReexecutionAuthorized)' \
    'observation.reviewedMainTimeoutDuringObservedExecutionMinutes' \
    'observation.reviewedMainTimeoutRestoredAfterObservationMinutes' \
    'observation.reviewedMainTimeoutRestoredToOrdinary45Minutes' \
    'observation.reviewedMainCheckoutFetchDepthDuringObservedExecution' \
    'observation.reviewedMainCheckoutFetchDepthRestoredAfterObservation' \
    'observation.reviewedMainCheckoutDepthRestoredToOne' \
    'observation.activeJobTransportDecodedUTF8LogByteCount' \
    'observation.activeJobTransportDecodedUTF8LogSplitLineCount' \
    '"a6f948b106edb307a3a826af74bdc82398afba6b1961359e77ec79bb9f069de8"' \
    'observation.reviewedMainJobTransportDecodedUTF8LogByteCount' \
    'observation.reviewedMainJobTransportDecodedUTF8LogSplitLineCount' \
    '"caa3e223077cca02d917d2814668a2dc4e36d5e8eed3f60c76689821ed53e588"' \
    'XCTAssertFalse(observation.rawGitHubLogArchiveBytesBound)' \
    'XCTAssertFalse(observation.jobLogsRetainedInRepository)' \
    'XCTAssertFalse(observation.durableJobLogPublicationEstablished)' \
    'XCTAssertEqual(observation.publishedWorkflowArtifactCount, 0)' \
    'XCTAssertFalse(observation.checkpointArtifactUploaded)' \
    'XCTAssertEqual(observation.receiptBeginMarkerCount, 1)' \
    'XCTAssertEqual(observation.receiptChunkMarkerCount, 26)' \
    'XCTAssertEqual(observation.receiptEndMarkerCount, 1)' \
    'XCTAssertEqual(observation.receiptCanonicalByteCount, 77_205)' \
    '"b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf"' \
    'let evidence = observation.receiptEvidence' \
    'try evidence.validate()' \
    'XCTAssertEqual(evidence.initializationSeed, 43)' \
    'XCTAssertEqual(beforeWrite.linkCount, 2)' \
    'XCTAssertEqual(afterWrite.linkCount, 3)' \
    'XCTAssertEqual(afterLoad, afterWrite)' \
    'beforeWrite.publicationStableObjectFieldsEqual(to: afterWrite)' \
    'afterWrite.readOnlyFullIdentityEqual(to: afterLoad)' \
    'XCTAssertTrue(evidence.publicationStableFiveFieldsMatched)' \
    'XCTAssertTrue(evidence.readOnlyFullRootIdentityMatched)' \
    'artifact.byteCount, 1_084_525_304' \
    '"a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538"' \
    'XCTAssertEqual(evidence.publicCheckpointWriteInvocationCount, 1)' \
    'XCTAssertEqual(evidence.publicCheckpointWriteCompletionCount, 1)' \
    'XCTAssertEqual(evidence.publicCheckpointLoadInvocationCount, 1)' \
    'XCTAssertEqual(evidence.publicCheckpointLoadCompletionCount, 1)' \
    'observation.exactParentPostReceiptVerificationSourceLineRange' \
    'XCTAssertEqual(observation.exactParentArtifactUnlinkSourceLine, 1_176)' \
    'observation.exactParentArtifactRootRmdirSourceLine' \
    'observation.exactParentCleanupAbsencePostconditionSourceLineRange' \
    '"2026-08-11T11:42:37.6029040Z"' \
    '"2026-08-11T11:42:37.8067580Z"' \
    'XCTAssertTrue(observation.receiptEndPrecededParentCleanup)' \
    'XCTAssertTrue(observation.parentReceiptVerificationCompleted)' \
    'XCTAssertTrue(observation.parentArtifactUnlinkCompleted)' \
    'XCTAssertTrue(observation.parentArtifactRootRmdirCompleted)' \
    'XCTAssertTrue(observation.parentLiteralCleanupPostconditionCompleted)' \
    'let falseCeilings = [' \
    'XCTAssertEqual(falseCeilings.count, 32)' \
    'for key in falseCeilings.keys.sorted() {' \
    'let receiptData = try evidence.canonicalReceiptData()' \
    'PrimeSHA256.hexDigest(of: receiptData)' \
    'let decodedReceipt = try Evidence.decodeCanonicalReceipt(' \
    'try decodedReceipt.validate()' \
    'let encodedObservation = try JSONEncoder().encode(observation)' \
    'let decodedObservation = try JSONDecoder().decode(' \
    'try decodedObservation.validateExactV1()' \
    'let canonicalObservation = try PrimeCanonicalJSON.encode(observation)' \
    'let mutations = recursiveScalarAndArrayMutations(' \
    'XCTAssertGreaterThan(mutations.count, 2_500)' \
    'mutations.contains { $0.0.hasSuffix(".boolean") }' \
    'mutations.contains { $0.0.hasSuffix(".number") }' \
    'mutations.contains { $0.0.hasSuffix(".string") }' \
    'mutations.contains { $0.0.hasSuffix(".array-duplicate") }' \
    'mutations.contains { $0.0.hasSuffix(".array-reorder") }' \
    'var rejectedAfterDecodeCount = 0' \
    'var rejectedAtDecodeCount = 0' \
    'try mutated.validateExactV1()' \
    '.contractDrift' \
    'catch is DecodingError {' \
    'XCTAssertGreaterThan(rejectedAfterDecodeCount, 2_500)' \
    'XCTAssertGreaterThan(rejectedAtDecodeCount, 0)' \
    'rejectedAfterDecodeCount + rejectedAtDecodeCount'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_observation_test_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair observation test lost: $required_checkpoint_v2_io_root_identity_repair_observation_test_value"
done

for forbidden_checkpoint_v2_io_root_identity_repair_observation_test_value in \
    'PrimeNativeGQADecoder.make(' \
    'PrimeNativeDecoderCheckpointCodecV2.' \
    '.writeNative300MByte512(' \
    '.loadNative300MByte512(' \
    'PrimeArtifactRoot(' \
    'Memory.clearCache()' \
    'import MLX' \
    'import Metal' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'posix_spawn' \
    'execve(' \
    'Process()'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_observation_test_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_execution_observation_test"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair observation test gained execution capability: $forbidden_checkpoint_v2_io_root_identity_repair_observation_test_value"
    fi
done

for required_checkpoint_v2_io_root_identity_repair_launcher_value in \
    '[[ "${GITHUB_ACTIONS:-}" == "true" ]]' \
    '[[ "${RUNNER_ENVIRONMENT:-}" == "github-hosted" ]]' \
    '[[ "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" ]]' \
    '[[ "${GITHUB_EVENT_NAME:-}" == "push" ]]' \
    '[[ "${GITHUB_REF:-}" == "refs/heads/main" ]]' \
    '[[ "${GITHUB_RUN_ATTEMPT:-}" == "1" ]]' \
    'readonly base_revision="1a69407a8fbd5f141e8ece584066b8dcfa6f606f"' \
    '[[ "${#predecessor_logs[@]}" -eq 10 ]]' \
    '[[ "${#reclaimable_relative_paths[@]}" -eq 32 ]]' \
    'rm -rf -- "$target"' \
    'cleanup_failed_fixed_artifact_root()' \
    'set -o noclobber' \
    'transport_state=before' \
    'receipt marker occurred before the exact BEGIN' \
    'receipt chunks are not contiguous in emitted order' \
    'non-chunk line interleaved between receipt BEGIN and END' \
    'receipt END was not the final probe-log line' \
    'decoded receipt is not canonical JSON' \
    'predecessor_validated_log_count == 10' \
    'predecessor_validated_receipt_count == 2' \
    'known_runner_temporary_reclamation_path_count == 32' \
    'publication_stable_five_fields_matched == true' \
    'publication_root_link_counts_positive == true' \
    'read_only_full_root_identity_matched == true' \
    '.artifact_root_identity_after_load == .artifact_root_identity_after_write' \
    'success_cleanup_completed_before_receipt == false' \
    'unlink "$artifact_path"' \
    'rmdir "$artifact_root"' \
    'OK: exact reviewed-main one-shot Native-300M V2 checkpoint public write/load passed'; do
    grep -Fq -- "$required_checkpoint_v2_io_root_identity_repair_launcher_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path" ||
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair launcher lost: $required_checkpoint_v2_io_root_identity_repair_launcher_value"
done
[[ "$(grep -Fc -- 'rm -rf -- "$target"' \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path")" == "1" \
    && "$(grep -Fc -- 'unlink "$artifact_path"' \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path")" == "1" \
    && "$(grep -Fc -- 'rmdir "$artifact_root"' \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path")" == "1" \
    && "$(grep -Fc -- 'actions/upload-artifact' \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path")" == "0" ]] ||
    die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair deletion or upload boundary changed"
for forbidden_checkpoint_v2_io_root_identity_repair_launcher_value in \
    'rm -rf -- "$artifact_root"' \
    'git clean' \
    'git reset' \
    'git checkout --' \
    'workflow_dispatch' \
    'GITHUB_RUN_ATTEMPT:-2' \
    'curl ' \
    'gh run rerun' \
    'actions/upload-artifact'; do
    if grep -Fq -- "$forbidden_checkpoint_v2_io_root_identity_repair_launcher_value" \
        "$decoder_checkpoint_v2_io_root_identity_repair_gate_path"; then
        die "PrimeNativeDecoder checkpoint V2 I/O root-identity repair launcher contains forbidden value: $forbidden_checkpoint_v2_io_root_identity_repair_launcher_value"
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

[[ "$(grep -Ec -- '^import ' \
        "$decoder_trajectory_exact_resume_design_authority_source")" == "1" \
    && "$(grep -Fxc -- 'import Foundation' \
        "$decoder_trajectory_exact_resume_design_authority_source")" == "1" ]] ||
    die "trajectory exact-resume design authority gained a dependency import"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_trajectory_exact_resume_design_authority_test")" == "1" ]] ||
    die "trajectory exact-resume design test count changed"

for required_trajectory_exact_resume_design_value in \
    'public struct PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1:' \
    'public static let frozenV1: Self = {' \
    'public func validateExactV1() throws {' \
    'currentArc: "trajectory_schema_and_pure_contract_v1"' \
    'predecessorSourceClosureCoversEveryRepositoryInputSourceUsedByThisDesign:' \
    'seed42PublicWriteReturnSourceInferred: true' \
    'seed42PublicWriteCompletionCountSourceInferred: 1' \
    'seed42PublicLoadCompletionCountSourceInferred: 0' \
    'seed42ExternalBindingFieldsIndependentlyBound: false' \
    'seed42OriginalArtifactRecoverable: false' \
    'seed42RegenerationWouldBeNewExecutionNotRecovery: true' \
    'seed43VerifiedArtifactDeleted: true' \
    'seed43ArtifactAvailableBeyondProcess: false' \
    'seed43OriginalArtifactRecoverable: false' \
    'seed43ExternalBindingCanBeUsedAsAvailableParent: false' \
    '"model_parameters_only_no_optimizer_rng_cursor_or_cache"' \
    '"tiny_cpu_mechanics_only_not_native300m_training"' \
    'totalMomentTensorCount: 436' \
    'totalMomentLogicalByteCount: 2_168_856_576' \
    'dedicatedSupportedTypedExactStateImporterAvailable: false' \
    'innerStateArrayContainerIsDirectStateReference: false' \
    'innerStateElementsCanMutateStateViaUnderscoredUpdate: true' \
    'publicUnderscoredMLXArrayUpdateInternalAvailable: true' \
    'underscoredMutationDocumentedAsImplementationDetail: true' \
    'underscoredMutationAuthorizedForTrajectoryResume: false' \
    'underscoredMutationReliabilityEstablishedForTrajectoryResume:' \
    'primeOwnedExplicitKeyCounterRequired: true' \
    'accumulationPhaseAtSnapshot: 0' \
    'pendingGradientTensorCountAtSnapshot: 0' \
    'pendingPrefetchItemCountAtSnapshot: 0' \
    'kvCacheEntryCountAtSnapshot: 0' \
    'finalCommitManifestPublishedLast: true' \
    'finalCommitManifestIsExclusiveCommitPoint: true' \
    'artifactRootProvidesAtomicMultiFileTransaction: false' \
    'partialPrecommitLeavesAreAuthoritative: false' \
    'discoverAndTrustLoadAuthorized: false' \
    'sameDeviceRepeatedUninterruptedAndResumedTrialsRequired:' \
    'exactMetalGradientBytesEstablished: false' \
    'minimumCommittedTensorStateByteCount: 3_253_284_864' \
    'externalDependencySourcesIncludedInRepositoryClosure: false' \
    'everyExternalDependencyClaimUsedByThisDesignHasExactSourceBinding:' \
    'path: "Source/MLX/State.swift"' \
    'path: "Source/MLX/Protocols.swift"' \
    'path: "Source/MLX/MLXArray.swift"' \
    'path: "Source/MLXOptimizers/Optimizers.swift"' \
    'path: "mlx/primitives.cpp"' \
    '"mlx/backend/metal/kernels/indexing/scatter_axis.h"' \
    'childPath: "Source/Cmlx/mlx"' \
    'childPath: "Source/Cmlx/mlx-c"' \
    'allowedSourceImports: ["Foundation"]' \
    'liveLauncherAuthorized: false' \
    'trainingExecutionObserved: false' \
    'publicationAuthorized: false' \
    'ABSTAIN_design_only_no_usable_seed42_or_seed43_parent_no_training_io_retention_provenance_admission_or_exact_metal_resume_claim'; do
    grep -Fq -- "$required_trajectory_exact_resume_design_value" \
        "$decoder_trajectory_exact_resume_design_authority_source" ||
        die "trajectory exact-resume design authority lost: $required_trajectory_exact_resume_design_value"
done

for required_trajectory_exact_resume_stage in \
    'trajectory_schema_and_pure_contract_v1' \
    'tiny_cpu_train_evaluate_mechanics_v1' \
    'tiny_cpu_explicit_rng_cursor_resume_v1' \
    'tiny_durable_multileaf_commit_fault_injection_v1' \
    'tiny_repeated_metal_trajectory_determinism_assay_v1' \
    'native300m_resource_only_one_step_probe_v1' \
    'native300m_trajectory_checkpoint_execution_v1' \
    'retained_trajectory_provenance_and_admission_v1'; do
    grep -Fq -- "$required_trajectory_exact_resume_stage" \
        "$decoder_trajectory_exact_resume_design_authority_source" ||
        die "trajectory exact-resume stage order lost: $required_trajectory_exact_resume_stage"
done

for required_trajectory_exact_resume_test_value in \
    'func testFrozenV1CanonicalCodableMutationAndSourceBoundary() throws {' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'for path in valuePaths {' \
    'for path in fieldPaths {' \
    'XCTAssertEqual(dependencyBindings.count, 12)' \
    'XCTAssertEqual(dependencyRelationships.count, 2)' \
    'executionAndAdmissionCeilings(authority).allSatisfy { !$0 }' \
    'ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589'; do
    grep -Fq -- "$required_trajectory_exact_resume_test_value" \
        "$decoder_trajectory_exact_resume_design_authority_test" ||
        die "trajectory exact-resume pure mutation test lost: $required_trajectory_exact_resume_test_value"
done
[[ "$(grep -Fc -- 'gitMode: "160000"' \
        "$decoder_trajectory_exact_resume_design_authority_source")" == "4" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(' \
        "$decoder_trajectory_exact_resume_design_authority_source")" == "12" ]] ||
    die "trajectory exact-resume external dependency binding inventory changed"

for forbidden_trajectory_exact_resume_execution_capability in \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'MLXArray(' \
    ': MLXArray' \
    '-> MLXArray' \
    '[MLXArray]' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeArtifactRoot(' \
    'writeNative300MByte512(' \
    'loadNative300MByte512(' \
    '.forward(' \
    'checkedEval(' \
    'AdamW(' \
    '._updateInternal(' \
    'FileManager' \
    'FileHandle' \
    'Data(contentsOf:' \
    'String(contentsOf:' \
    'URLSession' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_trajectory_exact_resume_execution_capability" \
        "$decoder_trajectory_exact_resume_design_authority_source" \
        "$decoder_trajectory_exact_resume_design_authority_test"; then
        die "trajectory exact-resume design gained execution capability: $forbidden_trajectory_exact_resume_execution_capability"
    fi
done

[[ "$(grep -Ec -- '^import ' \
        "$decoder_trajectory_design_timeout_observation_source")" == "1" \
    && "$(grep -Fxc -- 'import Foundation' \
        "$decoder_trajectory_design_timeout_observation_source")" == "1" ]] ||
    die "trajectory-design timeout observation gained a dependency import"
[[ "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_trajectory_design_timeout_observation_test")" == "1" ]] ||
    die "trajectory-design timeout observation test count changed"

for required_trajectory_design_timeout_observation_value in \
    'public struct PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public func validateExactV1() throws {' \
    'observationKind: "reviewed_main_timeout_observation"' \
    'classification: "timeout_incomplete_not_semantic_failure"' \
    'runID: 31_509_046_898' \
    'runConclusion: "cancelled"' \
    'configuredReviewedMainTimeoutMinutes: 45' \
    'totalTestCount: 38' \
    'testCount: 44' \
    'receiptCount: 1' \
    '"prime-ci-native-decoder-tokenizer-compatibility.sh"' \
    'probeProductBuildReportedDurationMilliseconds: 527_150' \
    '"tokenizer_authority_test_build_cancelled_before_test_execution"' \
    'authorityTestBuildCompleted: false' \
    'testExecutionStarted: false' \
    'native300MModelAllocated: false' \
    'successMarkerObserved: false' \
    'publishedWorkflowArtifactCount: 0' \
    'artifactUploadStepPresent: false' \
    'retiredSeed42LauncherCommandCount: 0' \
    'retiredSeed43LauncherCommandCount: 0' \
    'publicCheckpointV2IOExecuted: false' \
    'timeoutIncompleteNotSemanticFailure: true' \
    'partialSuccessDoesNotCompleteReviewedMainJob: true' \
    'rerunObserved: false' \
    'tinyCPUTrainEvaluateMechanicsObserved: false' \
    'publicationAuthorized: false' \
    'ABSTAIN_REVIEWED_MAIN_TIMEOUT_INCOMPLETE_NOT_SEMANTIC_FAILURE' \
    'require_full_exact_main_completion_after_repair' \
    'do_not_advance_to_tiny_cpu_mechanics_before_full_completion'; do
    grep -Fq -- "$required_trajectory_design_timeout_observation_value" \
        "$decoder_trajectory_design_timeout_observation_source" ||
        die "trajectory-design timeout observation lost: $required_trajectory_design_timeout_observation_value"
done

for required_trajectory_design_timeout_observation_test_value in \
    'func testFrozenV1CanonicalCodableRecursiveMutationAndAuthorityCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    '"timeout_incomplete_not_semantic_failure"' \
    '"tokenizer_authority_test_build_cancelled_before_test_execution"' \
    'XCTAssertEqual(observation.focusedTests.totalTestCount, 38)' \
    'XCTAssertEqual(observation.metal.testCount, 44)' \
    'XCTAssertEqual(observation.maintainedRuntime.receiptCount, 1)' \
    'XCTAssertEqual(observation.tokenizer.executedTestCount, 0)' \
    'XCTAssertEqual(logs.publishedWorkflowArtifactCount, 0)' \
    'XCTAssertFalse(observation.publicCheckpointV2IOExecuted)' \
    'ceiling.tinyCPUTrainEvaluateMechanicsObserved' \
    'let drifts = recursiveDrifts(root, path: "$")' \
    'XCTAssertGreaterThan(drifts.count, 250)' \
    'unknown_future_execution_authority'; do
    grep -Fq -- "$required_trajectory_design_timeout_observation_test_value" \
        "$decoder_trajectory_design_timeout_observation_test" ||
        die "trajectory-design timeout observation test lost: $required_trajectory_design_timeout_observation_test_value"
done

for forbidden_trajectory_design_timeout_observation_capability in \
    'import Darwin' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeArtifactRoot(' \
    'writeNative300MByte512(' \
    'loadNative300MByte512(' \
    '.forward(' \
    'checkedEval(' \
    'AdamW(' \
    'FileManager' \
    'FileHandle' \
    'Data(contentsOf:' \
    'String(contentsOf:' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_trajectory_design_timeout_observation_capability" \
        "$decoder_trajectory_design_timeout_observation_source" \
        "$decoder_trajectory_design_timeout_observation_test"; then
        die "trajectory-design timeout observation gained execution capability: $forbidden_trajectory_design_timeout_observation_capability"
    fi
done
assert_tiny_cpu_mechanics_source_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "Stage-2 identity source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "Stage-2 identity source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "Stage-2 identity source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "Stage-2 identity source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "Stage-2 identity source SHA-256 changed: $relative_path"
}

assert_tiny_cpu_mechanics_source_identity \
    'Package.swift' \
    '100644' \
    '765d3c88139bc1f74af16b77b2f3b06d33f66f75' \
    '32795' \
    'bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2'
assert_tiny_cpu_mechanics_source_identity \
    'Package.resolved' \
    '100644' \
    '14d804bb4291720477240c27e24de6fbdc876b3b' \
    '645' \
    'bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375'
assert_tiny_cpu_mechanics_source_identity \
    'Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift' \
    '100644' \
    '0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f' \
    '39598' \
    'd59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994'
assert_tiny_cpu_mechanics_source_identity \
    'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' \
    '3e3517b747dac6c77b14747f4a0d92e892ad4448' \
    '60976' \
    '665568ea2ad237526acee5ded4805abaaac964c266cd2aa3841a3abbc48c4161'
assert_tiny_cpu_mechanics_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift' \
    '100644' \
    'c24af7fab204b8139e4d6f919e9c04ade48bfe6b' \
    '98327' \
    'ed0f66770a3cf772af264c5bd7f592a433ee48574d80f98664bc8421c32db5e1'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests.swift' \
    '100644' \
    '3ea30af2bbd8b4e77f69a55e910a04b9b82b34dc' \
    '37484' \
    '1aa3485ed39cf21a3a6fb2417b1d70903c9d2e74e0faa404696e70c8bcfb1f7a'
assert_tiny_cpu_mechanics_source_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservation.swift' \
    '100644' \
    '4fa7b0a7d32a997d0ab3a5bc89aa5dd4bd6f9909' \
    '56633' \
    '52ff3b2a9fcd0ad1a16c4dca467b4fbf1c14dc73f24c29284e9b27ec225635ef'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests.swift' \
    '100644' \
    '3ce9adbe899e7a7e3af3f281e172a4b80a7d0558' \
    '32000' \
    '1b54d3630f2881f1b78a362094954fbe0d816a3a1ad8216405404861c21e64cb'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' \
    '100644' \
    '9f05e5a17426f00adf9dad7b55d84057122e98f9' \
    '1054' \
    '0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' \
    '100644' \
    '8bf05edf1ea8789e7683e72fe756d79aaaa61320' \
    '645' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' \
    '100644' \
    '61e86200c508526ae2ab66e359d771841f7208db' \
    '30214' \
    '29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96'
assert_tiny_cpu_mechanics_source_identity \
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift' \
    '100644' \
    'a986a63c9d674b03dc879a6c8131577999311a88' \
    '15726' \
    '39051b266433bb510887750bafbc773646181f75cf85b2339ddd9fccb817cf6a'

jq -e \
    --slurpfile root_lock "$prime_root/Package.resolved" \
    '
      .pins == $root_lock[0].pins
      and .version == $root_lock[0].version
      and .originHash == "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45"
    ' \
    "$decoder_training_validation_lock" >/dev/null ||
    die "Stage-2 validation lock diverged from the exact root pin payload"

[[ "$(grep -Ec -- '^import ' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "1" \
    && "$(grep -Fxc -- 'import Foundation' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "1" \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_tiny_cpu_mechanics_authority_test")" == "1" ]] ||
    die "Stage-2 pure authority gained a dependency or test"
for required_tiny_cpu_authority_value in \
    'public struct PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1:' \
    'public static let frozenV1: Self = {' \
    'public func validateExactV1() throws {' \
    'workflowRunID: 31_515_766_609' \
    'reviewedMainTimeoutMinutes: 60' \
    'exactFocusedTestCount: 39' \
    'seed42CheckpointCommandCount: 0' \
    'seed43CheckpointCommandCount: 0' \
    'firstAndOnlyWorkflowAttemptCompletedSuccessfully: true' \
    'currentArcImplementationSourcesRequireRefreshedEmbeddedClosure:' \
    'externalSourceBindings.count == 23' \
    'externalGitlinks.count == 2' \
    'path: "mlx/c/stream.cpp"' \
    'path: "mlx/backend/metal/metal.cpp"' \
    'path: "mlx/backend/metal/device_info.cpp"' \
    'path: "mlx/backend/metal/eval.cpp"' \
    'checkpointTargetDependencyPresent: false' \
    'predecessorDecoderIdentityRemainsHistoricalAndFrozen: true' \
    'v2CheckpointCompatibilityForDecoderSuccessorReestablished:' \
    'checkpointProvenanceForDecoderSuccessorEstablished: false' \
    'localCapabilitySkipCountsAsMechanicsSuccess: false' \
    'hostedFocusedTestRequiredExecutionCount: 1' \
    'hostedFocusedTestRequiredSkipCount: 0' \
    'hostedFocusedTestRequiredFailureCount: 0' \
    'explicitRNGDomainImplementationAuthorized: false' \
    'deterministicDataCursorImplementationAuthorized: false' \
    'resumeExecutionAuthorized: false' \
    'checkpointReadAuthorized: false' \
    'checkpointWriteAuthorized: false' \
    'metalTensorExecutionAuthorized: false' \
    'native300MTrainingAuthorized: false' \
    'publicationAuthorized: false' \
    'implementationObservedByThisPreExecutionAuthority: true' \
    'executionObservedByThisPreExecutionAuthority: false' \
    'validate_bind_and_publish_already_materialized_exact_stage2_implementation_source_closure' \
    'AUTHORIZED_TINY_CPU_TRAIN_EVALUATE_MECHANICS_ONLY_DOWNSTREAM_ABSTAIN'; do
    grep -Fq -- "$required_tiny_cpu_authority_value" \
        "$decoder_tiny_cpu_mechanics_authority_source" ||
        die "Stage-2 authority lost: $required_tiny_cpu_authority_value"
done
[[ "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUFileIdentityV1(' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "9" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "23" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUExternalGitlinkV1(' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "2" \
    && "$(grep -Fc -- 'gitMode: "160000"' \
        "$decoder_tiny_cpu_mechanics_authority_source")" == "4" ]] ||
    die "Stage-2 authority source-binding inventory changed"
for required_tiny_cpu_authority_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveMutationAndCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'XCTAssertEqual(authority.internalSourceBindings.count, 9)' \
    'XCTAssertEqual(authority.externalSourceBindings.count, 23)' \
    'XCTAssertEqual(authority.externalGitlinks.count, 2)' \
    'XCTAssertTrue(stage2Ceilings(authority).allSatisfy { $0 })' \
    'XCTAssertTrue(downstreamCeilings(authority).allSatisfy { !$0 })' \
    'XCTAssertTrue(authority.implementationObservedByThisPreExecutionAuthority)' \
    'XCTAssertFalse(authority.executionObservedByThisPreExecutionAuthority)' \
    'validate_bind_and_publish_already_materialized_exact_stage2_implementation_source_closure' \
    '3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840' \
    'XCTAssertGreaterThan(valuePaths.count, 300)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_field_\(index)' \
    'Authority.decodeCanonical(prefixed)' \
    'Authority.decodeCanonical(suffixed)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_tiny_cpu_authority_test_value" \
        "$decoder_tiny_cpu_mechanics_authority_test" ||
        die "Stage-2 pure authority test lost: $required_tiny_cpu_authority_test_value"
done
for forbidden_tiny_cpu_authority_capability in \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'import Metal' \
    'PrimeNativeGQADecoder.make(' \
    'PrimeArtifactRoot(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_tiny_cpu_authority_capability" \
        "$decoder_tiny_cpu_mechanics_authority_source" \
        "$decoder_tiny_cpu_mechanics_authority_test"; then
        die "Stage-2 pure authority gained capability: $forbidden_tiny_cpu_authority_capability"
    fi
done

[[ "$(awk '/^import / { print }' \
        "$decoder_tiny_cpu_mechanics_failure_observation_source")" \
    == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$decoder_tiny_cpu_mechanics_failure_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_tiny_cpu_mechanics_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests:' \
        "$decoder_tiny_cpu_mechanics_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
        "$decoder_tiny_cpu_mechanics_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(' \
        "$decoder_tiny_cpu_mechanics_failure_observation_source")" == "12" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(' \
        "$decoder_tiny_cpu_mechanics_failure_observation_source")" == "17" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUFailureTestGroupV1(' \
        "$decoder_tiny_cpu_mechanics_failure_observation_source")" == "5" ]] ||
    die "Stage-2 failure observation import or sealed evidence inventory changed"
for required_tiny_cpu_failure_observation_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError:' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"exhausted_exact_main_stage2_hosted_metallib_bootstrap_failure"' \
    'pullRequestNumber: 83' \
    '"8d544c34a09a770198b50126f50adb766f234a8f"' \
    '"605d47dde85715f356e4d6e11beb3a3262cc4e7e"' \
    '"f13322ebc368c639a0f04b7570af093cc57ec22b"' \
    '"c5b776a9ad25375ef681de3041ef6259ac84dc4a"' \
    'path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"' \
    'gitBlob: "afc0182aeb4e9bd15fb91c45029ab10a77f97805"' \
    '"5cd23ce3656badd6d309797f257aeeec7dc66d0807df7f2845b75f8a1699c079"' \
    'runID: 31_525_634_838' \
    'runNumber: 63' \
    'runAttempt: 1' \
    'exactHeadPushRunCount: 1' \
    'previousAttemptURLWasNull: true' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'rerunCount: 0' \
    'id: 93_893_140_174' \
    'id: 93_893_902_353' \
    'runnerVersion: "2.336.0"' \
    'reviewedRunnerImage: "macos-26-arm64"' \
    'swiftVersion: "6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)"' \
    '"e1cc35d3a637432d22cbbb199b0227f1401d675f43231214081e00e30be11c65"' \
    '"820af763e807444722af2390e29efa782ee12841ffbeeebc1591b751908527d4"' \
    '"431d7afb7ab70ce0b60b3b04da0969317a5734d562c2a461a2be7c5196b015ef"' \
    'memberCount: 17' \
    'completedTestCountBeforeStage2Termination: 40' \
    'stage2TestClass: "PrimeNativeDecoderTrainingTests"' \
    '"testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"' \
    'stage2TestInvocationCount: 1' \
    'stage2TestStartCount: 1' \
    'stage2CompletedPassCount: 0' \
    'stage2CompletedFailureCount: 0' \
    'stage2CompletedSkipCount: 0' \
    'hostedStage2RequirementSatisfied: false' \
    '"metal_44_of_44"' \
    '"maintained_runtime_receipt"' \
    '"tokenizer_receipt"' \
    'retainedLiveSequenceInvocationCounts: [0, 0, 0]' \
    'retiredSeed42CheckpointCommandCount: 0' \
    'retiredSeed43CheckpointCommandCount: 0' \
    'checkpointReceiptMarkerCount: 0' \
    'oldOneShotSuccessMarkerCount: 0' \
    'name: "Run the Prime-owned decoder on live Metal"' \
    'diagnosticFocusedArchiveMemberTimestamp:' \
    '"2026-08-11T19:24:39.4258430Z"' \
    'diagnosticAggregateLogTimestamp:' \
    '"2026-08-11T19:24:39.4258460Z"' \
    '"MLX error: Failed to load the default metallib. library not found library not found library not found library not found  at /Users/runner/work/_temp/prime-native-decoder-training-build/checkouts/ergentics-mlx-swift/Source/Cmlx/mlx-c/mlx/c/stream.cpp:106"' \
    'failureSourceRevision:' \
    '"0726ca922fc902c4c61ef9c27d94132be418e945"' \
    'failureSourcePath: "mlx/c/stream.cpp"' \
    'failureSourceLine: 106' \
    'processExitCode: 1' \
    'failureClassification:' \
    '"pinned_mlx_default_metallib_bootstrap_failure_before_cpu_mechanics"' \
    'hostedBootstrapFailureObserved: true' \
    'CPUTrainEvaluateSemanticFailureObserved: false' \
    'CPUTrainEvaluateMechanicsPassObserved: false' \
    '"exact_frozen_source_order_plus_terminal_aggregate_and_archive_member_logs"' \
    'metalCapabilityGuardAdmittedHostSourceInferred: true' \
    'localNoMetalDeviceSkipPathTaken: false' \
    'stage2WorkflowMetallibBuildCommandCount: 0' \
    'stage2WorkflowMetallibStageCommandCount: 0' \
    'loadableDefaultMetallibDiscovered: false' \
    'withDefaultDeviceClosureEntryCount: 0' \
    'CPUDeviceEstablished: false' \
    'trainerConstructionCount: 0' \
    'decoderModelAllocationCount: 0' \
    'completedOptimizerStepCount: 0' \
    'evaluationCompletionCount: 0' \
    'twoTrainerEqualityAssertionCount: 0' \
    'initialSnapshotEqualityAssertionCount: 0' \
    'firstStepResultEqualityAssertionCount: 0' \
    'secondStepResultEqualityAssertionCount: 0' \
    'evaluationResultEqualityAssertionCount: 0' \
    'evaluationSharedPrefixSelectedLossEqualityAssertionCount: 0' \
    'globalMeanLossAssertionCount: 0' \
    'thirdStepRejectionGuardInvocationCount: 0' \
    'observedRuntimeDigestValueCount: 0' \
    'observedFloat32BitPatternValueCount: 0' \
    'MLXTensorComputationObserved: false' \
    'metalTensorSubmissionObserved: false' \
    'failurePrecedesCPUMechanics: true' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    'runLogArchiveIsActionsArtifact: false' \
    'checkpointArtifactCreated: false' \
    'predecessorExecutionAttemptConsumed: true' \
    'predecessorExecutionAuthorityExhausted: true' \
    'rerunObserved: false' \
    'rerunAuthorized: false' \
    'failedAttemptRecoverable: false' \
    'failedWorkflowInvocationRemainsLive: false' \
    'bootstrapRepairRequiredBeforeAnotherAttempt: true' \
    'bootstrapRepairAuthorizedByThisObservation: false' \
    'stage3Blocked: true' \
    '"ABSTAIN_stage2_attempt_consumed_hosted_default_metallib_bootstrap_failed_before_cpu_trainer_model_step_or_evaluation_no_rerun_no_actions_or_checkpoint_artifact_no_downstream_authority"' \
    '"keep_the_exhausted_invocation_filter_log_and_scratch_paths_retired"' \
    '"separately_authorize_a_pinned_source_default_metallib_bootstrap_repair"' \
    '"require_one_successful_stage2_test_with_zero_skips_and_zero_failures_before_stage3"'; do
    grep -Fq -- "$required_tiny_cpu_failure_observation_value" \
        "$decoder_tiny_cpu_mechanics_failure_observation_source" ||
        die "Stage-2 failure observation lost: $required_tiny_cpu_failure_observation_value"
done
for required_tiny_cpu_failure_observation_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(observation.observedSourceBindings.count, 12)' \
    'XCTAssertEqual(run.runID, 31_525_634_838)' \
    'XCTAssertEqual(run.runAttempt, 1)' \
    'XCTAssertEqual(run.rerunCount, 0)' \
    'XCTAssertEqual(active.id, 93_893_140_174)' \
    'XCTAssertEqual(reviewed.id, 93_893_902_353)' \
    'XCTAssertEqual(activeLog.byteCount, 230_005)' \
    'XCTAssertEqual(activeLog.lfByteCount, 1_733)' \
    'activeLog.newlineDelimitedComponentCountIncludingTerminalEmpty,' \
    'XCTAssertEqual(reviewedLog.byteCount, 377_065)' \
    'XCTAssertEqual(reviewedLog.lfByteCount, 3_829)' \
    'XCTAssertEqual(archive.memberCount, 17)' \
    'XCTAssertEqual(archive.uncompressedByteCount, 1_215_574)' \
    'focused.completedGroups.map(\.completedTestCount),' \
    '[34, 1, 1, 2, 2]' \
    'XCTAssertEqual(focused.stage2TestInvocationCount, 1)' \
    'XCTAssertEqual(focused.stage2TestStartCount, 1)' \
    'XCTAssertEqual(focused.stage2CompletedPassCount, 0)' \
    'XCTAssertEqual(focused.stage2CompletedFailureCount, 0)' \
    'XCTAssertEqual(focused.stage2CompletedSkipCount, 0)' \
    'XCTAssertFalse(focused.hostedStage2RequirementSatisfied)' \
    'XCTAssertEqual(focused.retainedLiveSequenceInvocationCounts, [0, 0, 0])' \
    'failure.diagnosticFocusedArchiveMemberTimestamp,' \
    'failure.diagnosticAggregateLogTimestamp,' \
    'XCTAssertNotEqual(' \
    'XCTAssertTrue(failure.hostedBootstrapFailureObserved)' \
    'XCTAssertFalse(failure.CPUTrainEvaluateSemanticFailureObserved)' \
    'XCTAssertFalse(failure.CPUTrainEvaluateMechanicsPassObserved)' \
    'XCTAssertEqual(flow.batchRejectionCallCountSourceInferred, 17)' \
    'XCTAssertEqual(flow.gradientClipCallCountSourceInferred, 7)' \
    'XCTAssertEqual(flow.validBatchConstructionCountSourceInferred, 4)' \
    'XCTAssertEqual(flow.stage2WorkflowMetallibBuildCommandCount, 0)' \
    'XCTAssertEqual(flow.stage2WorkflowMetallibStageCommandCount, 0)' \
    'XCTAssertFalse(flow.loadableDefaultMetallibDiscovered)' \
    'Array(repeating: 0, count: 22)' \
    'XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })' \
    'XCTAssertTrue(ceiling.predecessorExecutionAttemptConsumed)' \
    'XCTAssertTrue(ceiling.predecessorExecutionAuthorityExhausted)' \
    'XCTAssertTrue(ceiling.bootstrapRepairRequiredBeforeAnotherAttempt)' \
    'XCTAssertTrue(ceiling.stage3Blocked)' \
    'XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })' \
    '3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002' \
    'XCTAssertGreaterThan(valuePaths.count, 450)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 45)' \
    'XCTAssertGreaterThan(scalarPaths.count, 350)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_failure_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_tiny_cpu_failure_observation_test_value" \
        "$decoder_tiny_cpu_mechanics_failure_observation_test" ||
        die "Stage-2 failure-observation test lost: $required_tiny_cpu_failure_observation_test_value"
done
for forbidden_tiny_cpu_failure_observation_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1(' \
    'PrimeNativeGQADecoder.make(' \
    'Device.withDefaultDevice(' \
    'MTLCopyAllDevices(' \
    'MTLCreateSystemDefaultDevice(' \
    'PrimeArtifactRoot(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_tiny_cpu_failure_observation_capability" \
        "$decoder_tiny_cpu_mechanics_failure_observation_source" \
        "$decoder_tiny_cpu_mechanics_failure_observation_test"; then
        die "Stage-2 failure observation gained capability: $forbidden_tiny_cpu_failure_observation_capability"
    fi
done

assert_private_dependency_tls_failure_observation_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "private-dependency TLS failure source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "private-dependency TLS failure source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "private-dependency TLS failure source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "private-dependency TLS failure source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "private-dependency TLS failure source SHA-256 changed: $relative_path"
}

assert_private_dependency_tls_failure_observation_identity \
    'Sources/PrimeCore/PrimeReviewedMainPrivateDependencyTLSFailureObservation.swift' \
    '100644' \
    '4601692d5a52cbe1ae012e81ea5d86394e5ffadf' \
    '56027' \
    'e5092d50858d4fad76b229cc4b954d445df221d7019b06cb930c792370eddf6d'
assert_private_dependency_tls_failure_observation_identity \
    'Tests/PrimeCoreTests/PrimeReviewedMainPrivateDependencyTLSFailureObservationTests.swift' \
    '100644' \
    'b9d63cc1e4f6a60c99f1157bf08524befcc3f59a' \
    '32599' \
    'b53318309597cb3d3e270bb978d0f0f96661dbbb47eda374a7753de9c9795655'

[[ "$(awk '/^import / { print }' \
        "$private_dependency_tls_failure_observation_source")" \
    == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$private_dependency_tls_failure_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$private_dependency_tls_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeReviewedMainPrivateDependencyTLSFailureObservationTests:' \
        "$private_dependency_tls_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
        "$private_dependency_tls_failure_observation_test")" == "1" \
    && "$(grep -Fc -- 'PrimeReviewedMainTLSFailureSourceIdentityV1(' \
        "$private_dependency_tls_failure_observation_source")" == "7" \
    && "$(grep -Fc -- 'PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(' \
        "$private_dependency_tls_failure_observation_source")" == "16" \
    && "$(grep -Fc -- 'PrimeReviewedMainTLSFailureJobStepV1(' \
        "$private_dependency_tls_failure_observation_source")" == "14" ]] ||
    die "private-dependency TLS failure observation import or sealed evidence inventory changed"
for required_private_dependency_tls_failure_value in \
    'PrimeReviewedMainPrivateDependencyTLSFailureObservationError:' \
    'PrimeReviewedMainPrivateDependencyTLSFailureObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"ergentics_prime_reviewed_main_private_dependency_tls_failure_observation_v1"' \
    '"exact_main_external_tls_failure_before_private_dependency_evaluation"' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_execution_failure_observation_v1"' \
    '"3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002"' \
    'pullRequestNumber: 84' \
    'revision: "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb"' \
    '"8d544c34a09a770198b50126f50adb766f234a8f"' \
    '"64eed284f0b5630a23feeea1e74dcd74fe275571"' \
    'tree: "7f983f66b05c338464662f741d410ae70b1e662a"' \
    '"4790206681d2c41ffadbed2b774377fcdd2ef2e89c671f14d39026cc0018c2c8"' \
    'runID: 31_530_684_844' \
    'runNumber: 65' \
    'runAttempt: 1' \
    'exactHeadPushRunCount: 1' \
    'previousAttemptURLWasNull: true' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'rerunCount: 0' \
    'id: 93_909_705_892' \
    'id: 93_910_498_134' \
    'byteCount: 231_409' \
    '"9df1918e7a6bdd24ba52386a1878114029642d57ce1f739c7523e2071e9772a7"' \
    'byteCount: 10_195' \
    '"763401f815fa31f7e3a8fb76468ac30b983580a84e3603b6219deaa8e3a79a2e"' \
    'byteCount: 4_024' \
    '"c347aee0e6e114955166c8418967817631ef9fa5befec474fd96379a051a4da9"' \
    'byteCount: 66_580' \
    '"642d3b1d139c840c3f02a93fd96d03b3504e9ccf5340b1a05900dedda441e2fc"' \
    'memberCount: 16' \
    'uncompressedByteCount: 484_639' \
    'requiredFocusedRootTestCount: 35' \
    'focusedRootInvocationCount: 0' \
    'focusedRootCompletedTestCount: 0' \
    'retainedLiveSequenceWorkflowCounts: [1, 1, 1]' \
    'retainedLiveSequenceInvocationCounts: [0, 0, 0]' \
    'stage2ValidationPackageCommandCount: 0' \
    'stage2InvocationCount: 0' \
    'failedJobStepNumber: 4' \
    '"Fetch the exact private dependency without evaluating Prime"' \
    'transportFetchInvocationCount: 1' \
    'dependencyFetchCompleted: false' \
    'fetchHeadValidationCount: 0' \
    'dependencyPackageEvaluationCount: 0' \
    'credentialLeakScanCount: 0' \
    '"fatal: unable to access '\''https://github.com/Ergentics/ergentics-mlx-swift/'\'': SSL certificate problem: self signed certificate"' \
    '"2026-08-11T20:03:04.6476270Z"' \
    '"2026-08-11T20:03:04.6476320Z"' \
    'processExitCode: 128' \
    '"Process completed with exit code 128."' \
    '"git_https_tls_self_signed_certificate_before_private_dependency_fetch_completion"' \
    'externalTLSFailureObserved: true' \
    'failurePrecedesDependencyEvaluation: true' \
    'failurePrecedesReviewedMainSwiftCompilation: true' \
    'failurePrecedesFocusedRootExecution: true' \
    'failurePrecedesRetainedLiveSequence: true' \
    'predecessorStage2ObservationRemainsFrozen: true' \
    'predecessorStage2AttemptRemainsExhausted: true' \
    'runnerTLSRepairRequiredBeforeDistinctRun: true' \
    'stage3RemainsBlocked: true' \
    'repositorySourceDefectEstablished: false' \
    'credentialRejectionObserved: false' \
    'stage2RepairAttempted: false' \
    'runnerTLSRepairEstablished: false' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    'runLogArchiveIsActionsArtifact: false' \
    'rerunAuthorized: false' \
    'replacementRunAuthorized: false' \
    'runnerTLSRepairAuthorized: false' \
    'TLSVerificationBypassAuthorized: false' \
    'customCAInstallationAuthorized: false' \
    'stage2ExecutionEstablished: false' \
    'stage2BootstrapRepairEstablished: false' \
    'stage3AuthorityEstablished: false' \
    '"ABSTAIN_exact_main_private_dependency_external_tls_failure_before_dependency_evaluation_root35_live_sequence_or_stage2_no_rerun_no_artifact_no_downstream_authority"' \
    '"require_root36_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"' \
    '"keep_stage2_retired_and_stage3_blocked_pending_separate_default_metallib_repair_authority"'; do
    grep -Fq -- "$required_private_dependency_tls_failure_value" \
        "$private_dependency_tls_failure_observation_source" ||
        die "private-dependency TLS failure observation lost: $required_private_dependency_tls_failure_value"
done
for required_private_dependency_tls_failure_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(observation.observedSourceBindings.count, 7)' \
    'XCTAssertEqual(run.runID, 31_530_684_844)' \
    'XCTAssertEqual(run.runAttempt, 1)' \
    'XCTAssertEqual(run.rerunCount, 0)' \
    'XCTAssertFalse(run.rerunObserved)' \
    'XCTAssertFalse(run.rerunAuthorized)' \
    'XCTAssertEqual(active.id, 93_909_705_892)' \
    'XCTAssertEqual(reviewed.id, 93_910_498_134)' \
    'XCTAssertEqual(archive.memberCount, 16)' \
    'XCTAssertEqual(archive.uncompressedByteCount, 484_639)' \
    'XCTAssertEqual(execution.requiredFocusedRootTestCount, 35)' \
    'XCTAssertEqual(execution.retainedLiveSequenceWorkflowCounts, [1, 1, 1])' \
    'XCTAssertEqual(execution.retainedLiveSequenceInvocationCounts, [0, 0, 0])' \
    'Array(repeating: 0, count: 18)' \
    'XCTAssertEqual(failure.transportFetchInvocationCount, 1)' \
    'XCTAssertFalse(failure.dependencyFetchCompleted)' \
    'XCTAssertEqual(failure.processExitCode, 128)' \
    'XCTAssertTrue(semantics.externalTLSFailureObserved)' \
    'XCTAssertTrue(semantics.predecessorStage2ObservationRemainsFrozen)' \
    'XCTAssertTrue(semantics.predecessorStage2AttemptRemainsExhausted)' \
    'XCTAssertTrue(semantics.runnerTLSRepairRequiredBeforeDistinctRun)' \
    'XCTAssertTrue(semantics.stage3RemainsBlocked)' \
    'XCTAssertTrue(semanticFalseClaims(semantics).allSatisfy { !$0 })' \
    'XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })' \
    'authorityClaims(observation.authorityCeiling).allSatisfy { !$0 }' \
    '"require_root36_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"' \
    '"44917549689204bb9aabbd24b642d491a26fa501c3828cbc82009aa5e157a35d"' \
    'XCTAssertGreaterThan(valuePaths.count, 275)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 25)' \
    'XCTAssertGreaterThan(scalarPaths.count, 200)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_reviewed_main_private_dependency_tls_failure_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_private_dependency_tls_failure_test_value" \
        "$private_dependency_tls_failure_observation_test" ||
        die "private-dependency TLS failure-observation test lost: $required_private_dependency_tls_failure_test_value"
done
for forbidden_private_dependency_tls_failure_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_private_dependency_tls_failure_capability" \
        "$private_dependency_tls_failure_observation_source" \
        "$private_dependency_tls_failure_observation_test"; then
        die "private-dependency TLS failure observation gained capability: $forbidden_private_dependency_tls_failure_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity() {
    local relative_path="$1"
    local expected_mode="$2"
    local expected_blob="$3"
    local expected_byte_count="$4"
    local expected_sha256="$5"
    local source_path="$prime_root/$relative_path"

    [[ -f "$source_path" && ! -L "$source_path" ]] ||
        die "Metal current-decoder assertion arc source is missing or linked: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "$relative_path" | awk '{print $1}')" == "$expected_mode" ]] ||
        die "Metal current-decoder assertion arc source mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object "$source_path")" \
        == "$expected_blob" ]] ||
        die "Metal current-decoder assertion arc source blob changed: $relative_path"
    [[ "$(wc -c < "$source_path" | awk '{print $1}')" \
        == "$expected_byte_count" ]] ||
        die "Metal current-decoder assertion arc source byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$source_path" | awk '{print $1}')" \
        == "$expected_sha256" ]] ||
        die "Metal current-decoder assertion arc source SHA-256 changed: $relative_path"
}

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservation.swift' \
    '100644' \
    '2caec8b51732c35674212e1fc52bdba754e1aba5' \
    '64802' \
    '2751e4718cb2d25f25a2e8dc1e9b857457789d33a2f589ce60a1dd0e619475b2'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests.swift' \
    '100644' \
    'cf1c4aaee93932e84f79ac63ccbfc305bfc92d90' \
    '35169' \
    '952c84453e8cfec84528bc49c089a40cae0cd7052329158dd4d84c72ef3c9c52'

[[ "$(awk '/^import / { print }' \
        "$metal_current_decoder_identity_assertion_failure_observation_source")" \
    == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$metal_current_decoder_identity_assertion_failure_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$metal_current_decoder_identity_assertion_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests:' \
        "$metal_current_decoder_identity_assertion_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
        "$metal_current_decoder_identity_assertion_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(' \
        "$metal_current_decoder_identity_assertion_failure_observation_source")" == "9" \
    && "$(grep -Fc -- 'Self.member(' \
        "$metal_current_decoder_identity_assertion_failure_observation_source")" == "18" \
    && "$(grep -Fc -- 'PrimeNativeDecoderMetalIdentityFailureJobStepV1(' \
        "$metal_current_decoder_identity_assertion_failure_observation_source")" == "14" ]] ||
    die "Metal current-decoder assertion failure import or sealed evidence inventory changed"
for required_metal_current_decoder_assertion_failure_value in \
    'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError:' \
    'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_failure_observation_v1"' \
    '"exact_main_metal_current_decoder_identity_assertion_failure_after_root36"' \
    '"ergentics_prime_reviewed_main_private_dependency_tls_failure_observation_v1"' \
    '"44917549689204bb9aabbd24b642d491a26fa501c3828cbc82009aa5e157a35d"' \
    'pullRequestNumber: 85' \
    'revision: "2d0464ca35212d3d84781654b6a4e08158f27eab"' \
    '"e540b73f6a46cf6e0de5b932d7167f178d4ac6fb"' \
    '"5198f5da94977d11f5fcfabf65bb55a62cb31f26"' \
    'tree: "be66df2affb85e2d846ba6f5f51e540d17864796"' \
    'embeddedSourceIdentitySHA256:' \
    '"bb94b8a0e846639e2260bbe50d352b797e37b64f6318d13b28f3cbc5e1cc8f43"' \
    'path: ".github/workflows/prime-active-root-quarantine.yml"' \
    'gitBlob: "17cd469ea8ee75c070a404390abd2319c782f5e0"' \
    'path: ".github/scripts/prime-ci-active-root-quarantine.sh"' \
    'gitBlob: "da6389dfa57c0a67268dd441fe418ed1fc6ff521"' \
    'path: ".github/scripts/prime-ci-native-decoder-metal.sh"' \
    'gitBlob: "418d2d2753cee38e0b3558ad45e1e09865ffd11d"' \
    'workflowID: 329_017_041' \
    'runID: 31_533_658_617' \
    'runNumber: 67' \
    'runAttempt: 1' \
    'checkSuiteID: 85_540_241_762' \
    'exactHeadPushRunCount: 1' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'rerunCount: 0' \
    'id: 93_919_471_247' \
    'id: 93_920_049_786' \
    'runnerVersion: "2.336.0"' \
    'reviewedRunnerImage: "macos-26-arm64"' \
    'byteCount: 232_035' \
    '"46187396b65c13adf6e1da20d625890eb804f6b4ba476615ed0a532a55c89682"' \
    'byteCount: 10_192_525' \
    '"0b2d720a64c341dc874f3271b0e4a5792c6d7af36337f1d15f1641d27937ef16"' \
    'byteCount: 4_893' \
    '"7c50a7eddd18f8c8049ef431164da6175ffae284140dfd68a9062d8d0bc701a2"' \
    'byteCount: 337_696' \
    '"f972a9fe4bf0f00c467dd90f43a60cc594f2228cec6e720d8acfd2816b6f61e1"' \
    'byteCount: 9_843_772' \
    '"343c5ae69d86eb6ba16d1ab0fe72663651c3ca3d4ae921e632c355e2f7506f6a"' \
    'memberCount: 18' \
    'uncompressedByteCount: 20_850_557' \
    '"7ab28a53a38c61145065a921c53414d5ce15fe40a6db66b678c65b3c93e05736"' \
    'securePrivateDependencyFetchInvocationCount: 1' \
    'securePrivateDependencyFetchCompleted: true' \
    'focusedRootRequiredTestCount: 36' \
    'focusedRootCompletedTestCount: 36' \
    'retainedLiveSequenceWorkflowCounts: [1, 1, 1]' \
    'retainedLiveSequenceInvocationCounts: [1, 0, 0]' \
    'metallibBuildInvocationCount: 1' \
    'metallibBuildCompleted: true' \
    'metallibByteCount: 6_292_732' \
    'metalStartedTestCount: 44' \
    'metalPassedTestCount: 43' \
    'metalFailedTestCount: 1' \
    'metalAssertionFailureCount: 2' \
    'metalSkipCount: 0' \
    'runtimeClosureInvocationCount: 0' \
    'runtimeReceiptCount: 0' \
    'tokenizerCompatibilityInvocationCount: 0' \
    'tokenizerReceiptCount: 0' \
    'stage2ValidationPackageCommandCount: 0' \
    'stage2ValidationFilterCount: 0' \
    'stage2ValidationLogPathCount: 0' \
    'stage2ValidationScratchPathCount: 0' \
    'stage2InvocationCount: 0' \
    'retiredSeed42CheckpointCommandCount: 0' \
    'retiredSeed43CheckpointCommandCount: 0' \
    'checkpointReceiptMarkerCount: 0' \
    'artifactUploadStepCount: 0' \
    'frozenMetalAuthorityGitBlob:' \
    '"835a4826549e1f28ec27e3533f746218beb3bdf2"' \
    'frozenMetalAuthorityByteCount: 39_050' \
    '"058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"' \
    'currentDecoderGitBlob:' \
    '"0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"' \
    'currentDecoderByteCount: 39_598' \
    '"d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"' \
    'currentMinusFrozenByteCount: 548' \
    '"f13322ebc368c639a0f04b7570af093cc57ec22b"' \
    '"package func trainingLogitsNoCache(_ rankTwoTokenIDs: MLXArray) -> MLXArray"' \
    'diffContainsOnlyStage2TrainingSeam: true' \
    'frozenMetalAuthorityRemainsHistorical: true' \
    'failedJobStepNumber: 6' \
    '"testMetalRepairAuthorityIsAppendOnlyAndSourceExact"' \
    'byteCountAssertionLine: 338' \
    'sha256AssertionLine: 339' \
    'failedTestCaseCount: 1' \
    'assertionFailureCount: 2' \
    'processExitCode: 2' \
    '"metal_authority_current_decoder_identity_assertion_stale_after_stage2_package_only_seam"' \
    'secureDependencyFetchSuccessObserved: true' \
    'failureLimitedToCurrentDecoderIdentityAssertion: true' \
    'runtimeAndTokenizerBlockedByOrderedFailClosedSequence: true' \
    'predecessorTLSObservationRemainsFrozen: true' \
    'predecessorStage2FailureObservationRemainsFrozen: true' \
    'predecessorStage2AttemptRemainsExhausted: true' \
    'separateIdentityAssertionRepairRequired: true' \
    'privateDependencyTLSFailureObserved: false' \
    'metalFunctionalRegressionEstablished: false' \
    'currentDecoderIdentityRepairAttempted: false' \
    'metalValidationEstablished: false' \
    'runtimeClosureEstablished: false' \
    'tokenizerCompatibilityEstablished: false' \
    'stage2ExecutionEstablished: false' \
    'stage2BootstrapRepairEstablished: false' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    'runLogArchiveIsActionsArtifact: false' \
    'rerunAuthorized: false' \
    'replacementRunAuthorized: false' \
    'currentDecoderIdentityAssertionRepairAuthorized: false' \
    'checkpointArtifactUploadAuthorized: false' \
    'native300MTrainingEstablished: false' \
    'publicationAuthorized: false' \
    '"ABSTAIN_exact_main_root36_and_fresh_metallib_passed_metal44_current_decoder_identity_assertion_failed_runtime_tokenizer_stage2_checkpoint_absent_no_rerun_no_artifact_no_downstream_authority"' \
    '"require_root37_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"'; do
    grep -Fq -- "$required_metal_current_decoder_assertion_failure_value" \
        "$metal_current_decoder_identity_assertion_failure_observation_source" ||
        die "Metal current-decoder assertion failure observation lost: $required_metal_current_decoder_assertion_failure_value"
done
for required_metal_current_decoder_assertion_failure_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(observation.observedSourceBindings.count, 9)' \
    'XCTAssertEqual(run.workflowID, 329_017_041)' \
    'XCTAssertEqual(run.runID, 31_533_658_617)' \
    'XCTAssertEqual(run.runNumber, 67)' \
    'XCTAssertEqual(run.runAttempt, 1)' \
    'XCTAssertEqual(run.checkSuiteID, 85_540_241_762)' \
    'XCTAssertEqual(run.rerunCount, 0)' \
    'XCTAssertFalse(run.rerunObserved)' \
    'XCTAssertFalse(run.rerunAuthorized)' \
    'XCTAssertEqual(active.id, 93_919_471_247)' \
    'XCTAssertEqual(reviewed.id, 93_920_049_786)' \
    'XCTAssertEqual(archive.memberCount, 18)' \
    'XCTAssertEqual(archive.uncompressedByteCount, 20_850_557)' \
    'XCTAssertEqual(execution.focusedRootRequiredTestCount, 36)' \
    'XCTAssertEqual(execution.retainedLiveSequenceWorkflowCounts, [1, 1, 1])' \
    'XCTAssertEqual(execution.retainedLiveSequenceInvocationCounts, [1, 0, 0])' \
    'XCTAssertEqual(execution.metalStartedTestCount, 44)' \
    'XCTAssertEqual(execution.metalPassedTestCount, 43)' \
    'XCTAssertEqual(execution.metalFailedTestCount, 1)' \
    'XCTAssertEqual(execution.metalAssertionFailureCount, 2)' \
    'Array(repeating: 0, count: 19)' \
    'XCTAssertEqual(drift.currentMinusFrozenByteCount, 548)' \
    'XCTAssertTrue(drift.diffContainsOnlyStage2TrainingSeam)' \
    'XCTAssertTrue(drift.frozenMetalAuthorityRemainsHistorical)' \
    'XCTAssertEqual(assertion.byteCountAssertionLine, 338)' \
    'XCTAssertEqual(assertion.sha256AssertionLine, 339)' \
    'XCTAssertEqual(assertion.failedTestCaseCount, 1)' \
    'XCTAssertEqual(assertion.assertionFailureCount, 2)' \
    'XCTAssertEqual(assertion.processExitCode, 2)' \
    'XCTAssertTrue(semantics.failureLimitedToCurrentDecoderIdentityAssertion)' \
    'semanticFalseClaims(semantics).allSatisfy { !$0 }' \
    'artifactFalseClaims(artifacts).allSatisfy { !$0 }' \
    'authorityClaims(observation.authorityCeiling).allSatisfy { !$0 }' \
    '"require_root37_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"' \
    '"7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424"' \
    'XCTAssertGreaterThan(valuePaths.count, 300)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 25)' \
    'XCTAssertGreaterThan(scalarPaths.count, 225)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_metal_current_decoder_identity_failure_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_metal_current_decoder_assertion_failure_test_value" \
        "$metal_current_decoder_identity_assertion_failure_observation_test" ||
        die "Metal current-decoder assertion failure test lost: $required_metal_current_decoder_assertion_failure_test_value"
done
for forbidden_metal_current_decoder_assertion_failure_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_metal_current_decoder_assertion_failure_capability" \
        "$metal_current_decoder_identity_assertion_failure_observation_source" \
        "$metal_current_decoder_identity_assertion_failure_observation_test"; then
        die "Metal current-decoder assertion failure observation gained capability: $forbidden_metal_current_decoder_assertion_failure_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthority.swift' \
    '100644' \
    '49c25bb51083dc8160e08e96a7445b1afad4f82f' \
    '31511' \
    '8e046899c393cc75935a83199654011f909e6a95884f1bbc862429993b5c68e3'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests.swift' \
    '100644' \
    'f24b0cbdb265332ebe6a9ff4c62e92e207474b20' \
    '25001' \
    '65aaeecfa44644a57a3f470e784e45444c32ddf2a73fe7861ef95b01c54a9825'

[[ "$(awk '/^import / { print }' \
        "$metal_current_decoder_identity_assertion_repair_authority_source")" \
    == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$metal_current_decoder_identity_assertion_repair_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$metal_current_decoder_identity_assertion_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityTests:' \
        "$metal_current_decoder_identity_assertion_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
        "$metal_current_decoder_identity_assertion_repair_authority_test")" == "1" ]] ||
    die "Metal current-decoder assertion repair import or single-test boundary changed"
for required_metal_current_decoder_assertion_repair_value in \
    'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError:' \
    'PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_repair_authority_v1"' \
    '"test_only_historical_plan_to_current_stage2_decoder_identity_assertion_repair"' \
    '"ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_failure_observation_v1"' \
    '"7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424"' \
    'mergeRevision:' \
    '"2d0464ca35212d3d84781654b6a4e08158f27eab"' \
    'mergeTree:' \
    '"be66df2affb85e2d846ba6f5f51e540d17864796"' \
    'runID: 31_533_658_617' \
    'runNumber: 67' \
    'runAttempt: 1' \
    'activeRootJobID: 93_919_471_247' \
    'reviewedMainJobID: 93_920_049_786' \
    'focusedRootRequiredTestCount: 36' \
    'focusedRootCompletedTestCount: 36' \
    'requiredMetalTestCount: 44' \
    'completedMetalTestCount: 44' \
    'passedMetalTestCaseCount: 43' \
    'failedMetalTestCaseCount: 1' \
    'assertionFailureCount: 2' \
    'metalSkipCount: 0' \
    'runtimeInvocationCount: 0' \
    'tokenizerInvocationCount: 0' \
    'runConsumedAsTerminalFailureEvidence: true' \
    'runRecoveryOrReinterpretationAuthorized: false' \
    '"Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift"' \
    '"f284cb6d9bfdd37add9273f3e0eecd69e13cd134"' \
    'repairedDecoderSourceByteCount: 39_050' \
    '"058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"' \
    'sourceAuthorityCanonicalSHA256:' \
    '"3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840"' \
    'expectedGitBlob:' \
    '"0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"' \
    'expectedByteCount: 39_598' \
    '"d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"' \
    'packageOnlyTrainingLogitsNoCacheSeamIsSoleIdentityDelta: true' \
    'predecessorGitBlob:' \
    '"25b7c9b99e789988fb7362b73a41d35eafba406d"' \
    'predecessorByteCount: 34_555' \
    '"28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe"' \
    'repairedGitBlob:' \
    '"329e57a8cbb2aa55879a94c88b17c391d13a1eb4"' \
    'repairedByteCount: 35_548' \
    '"40c65bd0169ed5af08248acb38b5b287a82894fec8e8f2c2808f348e3cd50373"' \
    'authorityTestClassMethodCount: 11' \
    'requiredMetalTotalTestCount: 44' \
    'liveHistoricalPlanIdentityAssertionCount: 0' \
    'liveStage2SuccessorIdentityAssertionCount: 3' \
    'cryptoKitSHA1ForPureGitBlobFramingAuthorized: true' \
    'testCountChangeAuthorized: false' \
    'productionTargetChangeAuthorized: false' \
    'testOnlyCurrentDecoderIdentityAssertionRepairAuthorized: true' \
    'implementationObservedByThisAuthority: true' \
    'executionObservedByThisAuthority: false' \
    'defaultMetallibRepairAuthorized: false' \
    'stage2BootstrapRepairAuthorized: false' \
    'checkpointArtifactAuthorized: false' \
    'native300MTrainingAuthorized: false' \
    'publicationAuthorized: false' \
    '"AUTHORIZED_test_only_metal_current_decoder_identity_assertion_repair_preserve_historical_plan_bind_stage2_successor_no_run_recovery_or_downstream_authority"' \
    '"require_distinct_exact_main_root38_then_metal44_then_runtime1_then_tokenizer1_before_any_new_success_observation"'; do
    grep -Fq -- "$required_metal_current_decoder_assertion_repair_value" \
        "$metal_current_decoder_identity_assertion_repair_authority_source" ||
        die "Metal current-decoder assertion repair authority lost: $required_metal_current_decoder_assertion_repair_value"
done
for required_metal_current_decoder_assertion_repair_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    '"7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424"' \
    'XCTAssertEqual(consumed.runID, 31_533_658_617)' \
    'XCTAssertEqual(consumed.runNumber, 67)' \
    'XCTAssertEqual(consumed.runAttempt, 1)' \
    'XCTAssertEqual(consumed.requiredMetalTestCount, 44)' \
    'XCTAssertEqual(consumed.completedMetalTestCount, 44)' \
    'XCTAssertEqual(consumed.passedMetalTestCaseCount, 43)' \
    'XCTAssertEqual(consumed.failedMetalTestCaseCount, 1)' \
    'XCTAssertEqual(consumed.assertionFailureCount, 2)' \
    'consumed.rerunCount,' \
    'Array(repeating: 0, count: 6)' \
    'XCTAssertFalse(consumed.runRecoveryOrReinterpretationAuthorized)' \
    'XCTAssertTrue(historical.remainsFrozen)' \
    'XCTAssertTrue(historical.identityRemainsHistorical)' \
    'XCTAssertTrue(current.stage2SurfaceDesignIsCurrentDecoderIdentitySource)' \
    'XCTAssertEqual(patch.authorityTestClassMethodCount, 11)' \
    'XCTAssertEqual(patch.requiredMetalTotalTestCount, 44)' \
    'XCTAssertTrue(patch.cryptoKitSHA1ForPureGitBlobFramingAuthorized)' \
    'falseClaims(authority.authorityCeiling).allSatisfy { !$0 }' \
    '"beb9f8ba1c0c09527b4e30c1d3225e641a30498300ddd58c5e2f7086f0fb5e35"' \
    'XCTAssertGreaterThan(valuePaths.count, 150)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 5)' \
    'XCTAssertGreaterThan(scalarPaths.count, 130)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_metal_current_decoder_identity_assertion_repair_field_\(index)' \
    'Authority.decodeCanonical(prefixed)' \
    'Authority.decodeCanonical(suffixed)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(slashEscapedData)' \
    'Authority.decodeCanonical(reorderedData)' \
    'Authority.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_metal_current_decoder_assertion_repair_test_value" \
        "$metal_current_decoder_identity_assertion_repair_authority_test" ||
        die "Metal current-decoder assertion repair test lost: $required_metal_current_decoder_assertion_repair_test_value"
done
for forbidden_metal_current_decoder_assertion_repair_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_metal_current_decoder_assertion_repair_capability" \
        "$metal_current_decoder_identity_assertion_repair_authority_source" \
        "$metal_current_decoder_identity_assertion_repair_authority_test"; then
        die "Metal current-decoder assertion repair gained capability: $forbidden_metal_current_decoder_assertion_repair_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift' \
    '100644' \
    'b1c07a407f05fe7058c43656451f428ab794543e' \
    '51385' \
    'ecd9d25354e6e74fe8aeb8421fb5dcc92c1f51309b0ce1f2c2791423be435293'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift' \
    '100644' \
    'f84eefb6428187ba4e08b3febf0c87256bd7788c' \
    '29596' \
    'f17aa6fedf3f460de44f706c9fe9d6ebb5cd9b690936d4fb5a5947765c8ddfd3'

[[ "$(awk '/^import / { print }' \
        "$stage2_metallib_bootstrap_repair_authority_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_metallib_bootstrap_repair_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_metallib_bootstrap_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests:' \
        "$stage2_metallib_bootstrap_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
        "$stage2_metallib_bootstrap_repair_authority_test")" == "1" ]] ||
    die "Stage-2 metallib bootstrap repair authority import or single-test boundary changed"
for required_stage2_metallib_bootstrap_repair_authority_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityError:' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_authority_v1"' \
    '"exact_main_direct_successor_same_job_default_metallib_two_copy_direct_xctest_repair_authority"' \
    '"8504f0af692e19d3337cec00f2c624537bc7386a"' \
    '"1b2bd05d14287fbb145d5bf6af74eb537accca8f"' \
    'historyPreservingTwoParentMergeObserved: true' \
    'mergeTreeEqualsReviewedHeadTree: true' \
    'workflowID: 329_017_041' \
    'runID: 31_538_639_561' \
    'runNumber: 69' \
    'runAttempt: 1' \
    'checkSuiteID: 85_554_232_445' \
    'activeRootRunnerID: 1_000_001_694' \
    'reviewedMainRunnerID: 1_000_001_695' \
    'rerunCount: 0' \
    'rerunObserved: false' \
    'secureFetchInvocationCount: 1' \
    'secureFetchCompletionCount: 1' \
    'secureFetchRetryCount: 0' \
    'tlsVerificationBypassCount: 0' \
    'focusedRootTestCount: 38' \
    'focusedRootFailureCount: 0' \
    'focusedRootSkipCount: 0' \
    'focusedWholeStepTestCount: 44' \
    'focusedWholeStepFailureCount: 0' \
    'focusedWholeStepSkipCount: 0' \
    'retainedLiveSequenceInvocationCounts: [1, 1, 1]' \
    'metallibBuildInvocationCount: 1' \
    'metallibBuildCompletionCount: 1' \
    'metallibByteCount: 6_292_748' \
    '"38117775b78e1f1a7920501d433c43426ea73c204e94bc4f25fee758f02364a6"' \
    'metalTestCount: 44' \
    'metalFailureCount: 0' \
    'metalSkipCount: 0' \
    'repairedMetalAuthorityTestPassed: true' \
    'runtimeTestCount: 1' \
    'runtimeReceiptCount: 1' \
    'tokenizerTestCount: 1' \
    'tokenizerReceiptCount: 1' \
    'retainedLiveCombinedTestCount: 46' \
    'stage2InvocationCount: 0' \
    'checkpointLiveCommandCount: 0' \
    'artifactUploadStepCount: 0' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    'stage2BootstrapRepairObservedInPrerequisite: false' \
    '"3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002"' \
    'exhaustedRunID: 31_525_634_838' \
    '"pinned_mlx_default_metallib_bootstrap_failure_before_cpu_mechanics"' \
    'predecessorExecutionAttemptConsumed: true' \
    'predecessorExecutionAuthorityExhausted: true' \
    'failedAttemptRecoverable: false' \
    'failedInvocationRemainsLive: false' \
    'exhaustedScratchPathsRemainRetired: true' \
    'exhaustedLogPathRemainsRetired: true' \
    'distinctRepairRequired: true' \
    'requiredExecutionCommitParentCount: 2' \
    'requiredFirstParentRevision:' \
    'executionMergeTreeMustEqualSecondParentTree: true' \
    'activeRootCheckoutFetchDepth: 1' \
    'reviewedMainCheckoutFetchDepth: 2' \
    'launcherNetworkFetchCommandCount: 0' \
    '".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"' \
    '"bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"' \
    '"PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_REPAIR_RECEIPT="' \
    '"prime-native-decoder-metallib"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-build"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-cache"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-config"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-security"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-cwd"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair-tests.log"' \
    'requiredSourceMetallibCount: 1' \
    'maximumMetallibByteCount: 67_108_864' \
    'stagedMetallibCopyCount: 2' \
    'requiredStagedMetallibCount: 2' \
    'swiftBuildInvocationCount: 1' \
    'swiftBuildTestsFlagCount: 1' \
    'swiftShowBinPathInvocationCount: 0' \
    'swiftTestInvocationCount: 0' \
    'xcodebuildInvocationCount: 0' \
    'directXCTestInvocationCount: 1' \
    'rebuildAfterMetallibStagingInvocationCount: 0' \
    'requiredStage2TestCount: 1' \
    'requiredStage2FailureCount: 0' \
    'requiredStage2SkipCount: 0' \
    'oneDistinctExecutionAttemptAuthorized: true' \
    'githubRunAttemptMustEqualOne: true' \
    'successorObservationMustRetireLiveInvocation: true' \
    'sameJobFreshMetallibConsumptionAuthorized: true' \
    'twoCopyMetallibStagingAuthorized: true' \
    'directBuiltXCTestExecutionAuthorized: true' \
    'exactOneDirectSuccessorAttemptAuthorized: true' \
    'repairImplementationObservedByThisAuthority: false' \
    'repairExecutionObservedByThisAuthority: false' \
    'secureFetchMutationAuthorized: false' \
    'additionalMetallibBuildAuthorized: false' \
    'networkFetchAuthorizedInRepairLauncher: false' \
    'secondStage2AttemptAuthorized: false' \
    'stage2SuccessEstablished: false' \
    'stage3AuthorityEstablished: false' \
    'checkpointArtifactUploadAuthorized: false' \
    'native300MTrainingAuthorized: false' \
    'publicationAuthorized: false' \
    '"AUTHORIZED_exact_one_direct_successor_stage2_same_job_fresh_metallib_two_copy_direct_built_xctest_repair_not_execution_no_rerun_artifact_checkpoint_or_downstream_authority"' \
    '"keep_stage3_blocked_until_that_distinct_execution_observation"' \
    'observedBaseSourceBindings.count == 17' \
    'design.exactDirectSuccessorChangedPaths.count == 6' \
    '"beb9f8ba1c0c09527b4e30c1d3225e641a30498300ddd58c5e2f7086f0fb5e35"'; do
    grep -Fq -- "$required_stage2_metallib_bootstrap_repair_authority_value" \
        "$stage2_metallib_bootstrap_repair_authority_source" ||
        die "Stage-2 metallib bootstrap repair authority lost: $required_stage2_metallib_bootstrap_repair_authority_value"
done
for required_stage2_metallib_bootstrap_repair_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'XCTAssertEqual(green.runID, 31_538_639_561)' \
    'XCTAssertEqual(green.runNumber, 69)' \
    'XCTAssertEqual(green.runAttempt, 1)' \
    'XCTAssertEqual(green.checkSuiteID, 85_554_232_445)' \
    'XCTAssertEqual(green.activeRootRunnerID, 1_000_001_694)' \
    'XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_695)' \
    'XCTAssertEqual(green.secureFetchInvocationCount, 1)' \
    'XCTAssertEqual(green.secureFetchRetryCount, 0)' \
    'XCTAssertEqual(green.tlsVerificationBypassCount, 0)' \
    '[38, 0, 0, 44, 0, 0]' \
    'XCTAssertEqual(green.retainedLiveSequenceInvocationCounts, [1, 1, 1])' \
    'XCTAssertEqual(green.metallibBuildInvocationCount, 1)' \
    '[44, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1]' \
    '[46, 0, 0]' \
    'Array(repeating: 0, count: 9)' \
    'XCTAssertEqual(consumed.exhaustedRunID, 31_525_634_838)' \
    'XCTAssertTrue(consumed.predecessorExecutionAuthorityExhausted)' \
    'XCTAssertFalse(consumed.failedAttemptRecoverable)' \
    'XCTAssertFalse(consumed.failedInvocationRemainsLive)' \
    'XCTAssertEqual(bindings.count, 17)' \
    'XCTAssertEqual(recipe.requiredExecutionCommitParentCount, 2)' \
    'XCTAssertEqual(recipe.activeRootCheckoutFetchDepth, 1)' \
    'XCTAssertEqual(recipe.reviewedMainCheckoutFetchDepth, 2)' \
    'XCTAssertEqual(recipe.launcherNetworkFetchCommandCount, 0)' \
    '[1, 1, 0, 0, 0, 1, 0]' \
    '[1, 0, 0]' \
    'XCTAssertTrue(falseClaims(authority.authorityCeiling).allSatisfy { !$0 })' \
    'XCTAssertEqual(authority.orderedRequiredActions.count, 7)' \
    'XCTAssertGreaterThan(valuePaths.count, 350)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 250)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_default_metallib_bootstrap_repair_field_\(index)' \
    'Authority.decodeCanonical(prefixed)' \
    'Authority.decodeCanonical(suffixed)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(slashEscapedData)' \
    'Authority.decodeCanonical(reorderedData)' \
    'Authority.decodeCanonical(duplicateData)' \
    '"2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de"'; do
    grep -Fq -- "$required_stage2_metallib_bootstrap_repair_test_value" \
        "$stage2_metallib_bootstrap_repair_authority_test" ||
        die "Stage-2 metallib bootstrap repair authority test lost: $required_stage2_metallib_bootstrap_repair_test_value"
done
! grep -Fq -- '__CANONICAL_SHA256__' \
    "$stage2_metallib_bootstrap_repair_authority_source" \
    "$stage2_metallib_bootstrap_repair_authority_test" ||
    die "Stage-2 metallib bootstrap repair authority retains a canonical placeholder"
for forbidden_stage2_metallib_bootstrap_repair_authority_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_stage2_metallib_bootstrap_repair_authority_capability" \
        "$stage2_metallib_bootstrap_repair_authority_source" \
        "$stage2_metallib_bootstrap_repair_authority_test"; then
        die "Stage-2 metallib bootstrap repair authority gained capability: $forbidden_stage2_metallib_bootstrap_repair_authority_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservation.swift' \
    '100644' \
    'c5e6ef9be1aa311e01e885fff3f81b8ffa6ec96e' \
    '74063' \
    'b340b4998775a2486cc1cb3cdc6878db79fddff7d26d2c593f8195c60a92697c'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests.swift' \
    '100644' \
    '76e7a47f28ee90f967fe0df9b0e4c34468e31c1f' \
    '40863' \
    'f0decd42ee396f9b28b0c3856464cd57589129daab0a02e99604f82c28078b87'

[[ "$(awk '/^import / { print }' \
        "$stage2_metallib_bootstrap_repair_failure_observation_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_metallib_bootstrap_repair_failure_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_metallib_bootstrap_repair_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests:' \
        "$stage2_metallib_bootstrap_repair_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
        "$stage2_metallib_bootstrap_repair_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError:' \
        "$stage2_metallib_bootstrap_repair_failure_observation_source")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationV1:' \
        "$stage2_metallib_bootstrap_repair_failure_observation_source")" == "1" ]] ||
    die "Stage-2 metallib bootstrap repair failure observation import, public type, or single-test boundary changed"
for required_stage2_metallib_bootstrap_repair_failure_observation_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError:' \
    'case contractDrift' \
    'case noncanonicalEncoding' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    'try predecessor.validateExactV1()' \
    'self == Self.frozenV1' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_execution_failure_observation_v1"' \
    '"exact_main_stage2_metallib_bootstrap_repair_launcher_preflight_false_positive_observation"' \
    '"2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de"' \
    'pullRequestNumber: 87' \
    '"6b5233ae0589de539e91f613e7990de3ca5b5833"' \
    '"8504f0af692e19d3337cec00f2c624537bc7386a"' \
    '"cf93879f650f1708e51478cc630ac9a753226471"' \
    '"8d8944b8b73547c97822b50e06da895a1fb29f1f"' \
    'mergedAt: "2026-08-11T22:59:38Z"' \
    'historyPreservingTwoParentMergeObserved: true' \
    'mergeTreeEqualsReviewedHeadTree: true' \
    'mergeCommitSignatureVerified: true' \
    '"bdb0a217ec36611373ed7b25b982d78ee97f9f82d9ab274507978ab728194c2d"' \
    'observedSourceBindings.count == 10' \
    'workflowID: 329_017_041' \
    'runID: 31_544_702_133' \
    'runNumber: 71' \
    'runAttempt: 1' \
    'checkSuiteID: 85_570_388_096' \
    'exactHeadPushRunCount: 1' \
    'previousAttemptURLWasNull: true' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'rerunCount: 0' \
    'rerunObserved: false' \
    'id: 93_954_592_456' \
    'runnerID: 1_000_001_697' \
    'id: 93_955_091_811' \
    'runnerID: 1_000_001_698' \
    '"4f8f50aa9bc9df36a4389e2d87b0eb91baed8ebf7761cb54729688ca3656e7e5"' \
    '"53a5f1f178e1f6d46a8b14aecca09b95b79fc9121fc9f3c3a1985528e5b6efec"' \
    '"a9e9797d237f18227eac1e1a1d71c46fb6ff937637ef94383c89bc26acb34b2c"' \
    '"6858e8f204000409cbbbbb023a667c57e1684fca8280ea43f693f3457e18de43"' \
    '"b122f61be5b1811176ce6a69878ac1693de1c3ee2e049f6444c5f8892ca9cb3b"' \
    'byteCount: 1_348_689' \
    '"54a7d35df9485108b3f084fc5508bdc5887b8dccb89beee2ce1fa0a6c048bd17"' \
    'memberCount: 18' \
    'uncompressedByteCount: 20_961_389' \
    'repeatedDownloadsWereByteIdentical: true' \
    'memberTimestampsAreDOSZero: true' \
    'latinCompletedTestCount: 116' \
    'latinFailureCount: 0' \
    'latinSkipCount: 0' \
    'securePrivateDependencyFetchInvocationCount: 1' \
    'securePrivateDependencyFetchCompletionCount: 1' \
    'securePrivateDependencyFetchRetryCount: 0' \
    'tlsVerificationBypassCount: 0' \
    'focusedRootTestCount: 39' \
    'focusedRootFailureCount: 0' \
    'focusedRootSkipCount: 0' \
    'isolatedCheckpointGroupTestCounts: [1, 1, 2, 2]' \
    'focusedWholeStepTestCount: 45' \
    'offendingPredecessorPackageTestCount: 2' \
    'offendingPredecessorPackageFailureCount: 0' \
    'offendingPredecessorPackageSkipCount: 0' \
    'observedLiveInvocationCounts: [1, 1, 1, 1]' \
    'greenPredecessorLiveSuccessCounts: [1, 1, 1]' \
    'freshMetallibFileName: "default.metallib"' \
    'freshMetallibCandidateCount: 1' \
    'freshMetallibByteCount: 6_292_716' \
    '"c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255"' \
    'metalGroupTestCounts: [11, 14, 19]' \
    'metalTestCount: 44' \
    'metalFailureCount: 0' \
    'metalSkipCount: 0' \
    'runtimeTestCount: 1' \
    'runtimeFailureCount: 0' \
    'runtimeSkipCount: 0' \
    '"5df550107d486819d132a66de422de8929ecba9a750aec528b2b1bfff9ccc90f"' \
    'tokenizerTestCount: 1' \
    'tokenizerFailureCount: 0' \
    'tokenizerSkipCount: 0' \
    '"ceba20f60d3fd6d1afc0eb56bc28372aa93d52b9f3fd53b8b506d9aeda8ed0dd"' \
    'loadedMetallibIdentityIndependentlyObserved: false' \
    'metallibArtifactProvenanceEstablished: false' \
    'predecessorLogInventoryCount: 10' \
    'emittedPredecessorReceiptCount: 2' \
    'completedPreStage2TestCount: 91' \
    '"launcher_preflight_false_positive_before_metallib_discovery_staging_build_or_test"' \
    '"grep -Eiq"' \
    '"^Test (Case|Suite).*failed|^error:|skipped|Test skipped"' \
    'guardFailureSourceLine: 374' \
    'predecessorReceiptValidationSourceLine: 376' \
    'stage2MetallibDiscoverySourceLine: 383' \
    'stage2FreshPathAbsenceGuardSourceLine: 495' \
    'stage2WorkspaceCreationSourceLine: 501' \
    'matchedPredecessorLogOrdinal: 4' \
    'completedPredecessorLogScanCountBeforeFalsePositive: 3' \
    '"testFailedAttemptObservationIsExactExhaustedAndPure"' \
    '"case_insensitive_unbounded_failed_substring_matched_passed_test_identifier"' \
    '"predecessor_log_validation_false_positive_after_green_predecessors_before_stage2_metallib_discovery_or_build"' \
    'processExitCode: 2' \
    'predecessorReceiptValidationReached: false' \
    'sameJobFreshMetallibWasAvailableFromPredecessor: true' \
    'sameJobFreshMetallibWasInspectedByStage2Launcher: false' \
    'stage2RepairLauncherReachedFreshMetallibDiscovery: false' \
    'stage2MetallibDiscoveryCount: 0' \
    'stage2MetallibCandidateCount: 0' \
    'stage2StagedDestinationCount: 0' \
    'stage2MetallibCopyCount: 0' \
    'stage2BuildInvocationCount: 0' \
    'stage2BuildTestsInvocationCount: 0' \
    'stage2DirectXCTestInvocationCount: 0' \
    'stage2TestStartCount: 0' \
    'stage2TestPassCount: 0' \
    'stage2TestFailureCount: 0' \
    'stage2TestSkipCount: 0' \
    'stage2RepairReceiptCount: 0' \
    'stage2MechanicsEstablished: false' \
    'stage2BootstrapRepairEstablished: false' \
    'failureOccurredAfterGreenPredecessors: true' \
    'failureOccurredBeforeTargetTestBundleResolution: true' \
    'predecessorTestFailureObserved: false' \
    'stage2MechanicsTestFailureObserved: false' \
    'metallibDiscoveryOrBuildFailureObserved: false' \
    'launcherClassifierFalsePositiveObserved: true' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    'publishedWorkflowArtifactCount: 0' \
    'artifactUploadStepCount: 0' \
    'stage2RepairReceiptEmitted: false' \
    'predecessorExecutionAuthorityConsumed: true' \
    'predecessorExecutionAuthorityExhausted: true' \
    'failureObservationAuthorizesNothing: true' \
    'distinctRepairAuthorityRequired: true' \
    'launcherSourceMustRemainPreservedForAudit: true' \
    'consumedStage2LiveInvocationRetirementRequired: true' \
    'workflowMutationBeyondRequiredRetirementAuthorized: false' \
    'launcherMutationAuthorized: false' \
    'predecessorLogClassifierRepairAuthorized: false' \
    'stage2ReexecutionAuthorized: false' \
    'stage2SuccessEstablished: false' \
    'stage3RemainsBlocked: true' \
    '"FAIL_exact_main_stage2_launcher_preflight_false_positive_no_stage2_test_no_receipt_no_rerun_no_actions_or_stage2_artifact_no_downstream_authority"' \
    '"retire_consumed_stage2_live_invocation_without_rerun"' \
    '"preserve_failed_launcher_source_and_immutable_evidence"' \
    '"separately_authorize_bounded_predecessor_log_classifier_repair"' \
    '"require_distinct_exact_main_closure_before_any_stage2_success_observation"' \
    '"keep_stage3_blocked"'; do
    grep -Fq -- \
        "$required_stage2_metallib_bootstrap_repair_failure_observation_value" \
        "$stage2_metallib_bootstrap_repair_failure_observation_source" ||
        die "Stage-2 metallib bootstrap repair failure observation lost: $required_stage2_metallib_bootstrap_repair_failure_observation_value"
done
for required_stage2_metallib_bootstrap_repair_failure_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(repository.mergedAt, "2026-08-11T22:59:38Z")' \
    'XCTAssertEqual(predecessor.observedLiveInvocationCounts, [1, 1, 1, 1])' \
    'XCTAssertEqual(predecessor.greenPredecessorLiveSuccessCounts, [1, 1, 1])' \
    'XCTAssertFalse(failure.predecessorReceiptValidationReached)' \
    'XCTAssertFalse(failure.sameJobFreshMetallibWasInspectedByStage2Launcher)' \
    'XCTAssertFalse(failure.stage2RepairLauncherReachedFreshMetallibDiscovery)' \
    'XCTAssertEqual(failure.stage2TestStartCount, 0)' \
    'XCTAssertEqual(failure.stage2TestPassCount, 0)' \
    'XCTAssertEqual(failure.stage2TestFailureCount, 0)' \
    'XCTAssertEqual(failure.stage2TestSkipCount, 0)' \
    'XCTAssertFalse(failure.predecessorTestFailureObserved)' \
    'XCTAssertFalse(failure.stage2MechanicsTestFailureObserved)' \
    'XCTAssertFalse(failure.metallibDiscoveryOrBuildFailureObserved)' \
    'XCTAssertTrue(failure.launcherClassifierFalsePositiveObserved)' \
    'XCTAssertFalse(artifacts.runLogArchiveIsActionsArtifact)' \
    'XCTAssertFalse(artifacts.freshMetallibRetainedAfterJob)' \
    'XCTAssertFalse(artifacts.freshMetallibArtifactProvenanceEstablished)' \
    'XCTAssertTrue(ceiling.failureObservationAuthorizesNothing)' \
    'XCTAssertTrue(ceiling.distinctRepairAuthorityRequired)' \
    'XCTAssertTrue(ceiling.consumedStage2LiveInvocationRetirementRequired)' \
    'authorityFalseClaims(ceiling).allSatisfy { !$0 }' \
    '"2184710f59bc2b4625bb0a74f5f835c859fada79406ffc957b5ffca4861a9926"' \
    'XCTAssertGreaterThan(valuePaths.count, 350)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 250)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_bootstrap_failure_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- \
        "$required_stage2_metallib_bootstrap_repair_failure_test_value" \
        "$stage2_metallib_bootstrap_repair_failure_observation_test" ||
        die "Stage-2 metallib bootstrap repair failure-observation test lost: $required_stage2_metallib_bootstrap_repair_failure_test_value"
done
! grep -Fq -- '__CANONICAL_SHA256__' \
    "$stage2_metallib_bootstrap_repair_failure_observation_source" \
    "$stage2_metallib_bootstrap_repair_failure_observation_test" ||
    die "Stage-2 metallib bootstrap repair failure observation retains a canonical placeholder"
for forbidden_stage2_metallib_bootstrap_repair_failure_observation_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- \
        "$forbidden_stage2_metallib_bootstrap_repair_failure_observation_capability" \
        "$stage2_metallib_bootstrap_repair_failure_observation_source"; then
        die "Stage-2 metallib bootstrap repair failure observation gained capability: $forbidden_stage2_metallib_bootstrap_repair_failure_observation_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift' \
    '100644' \
    'b3b42c285c8fe048d4eeea111f3f9f9bab37707d' \
    '66167' \
    '2f97065f3c09f69d2ce38774a16a5d4dcb9deb20899cdeb1f8821334d2486983'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift' \
    '100644' \
    '15164c2256129816789fd2408f73f7b1c7eaccbd' \
    '35453' \
    '2600a86636c5440ddd010e10a0928fd7f49b96d2926536d881364e524630d187'

[[ "$(awk '/^import / { print }' \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests:' \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test")" == "1" ]] ||
    die "Stage-2 predecessor-log classifier repair authority import or single-test boundary changed"
for required_stage2_predecessor_log_classifier_repair_authority_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityError:' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_predecessor_log_classifier_repair_authority_v1"' \
    '"exact_main_direct_successor_bounded_predecessor_log_classifier_repair_and_one_replacement_stage2_execution_authority"' \
    '"775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1"' \
    '"817405a8710ad24245721689e7a6736c55a0b06c"' \
    'workflowID: 329_017_041' \
    'runID: 31_550_007_242' \
    'runNumber: 73' \
    'runAttempt: 1' \
    'checkSuiteID: 85_584_105_952' \
    'activeRootRunnerID: 1_000_001_700' \
    'reviewedMainRunnerID: 1_000_001_701' \
    'workflowAuthoredRetryCount: 0' \
    'gitInternalSubmoduleRetryScheduledCount: 1' \
    'mlxSubmoduleCloneAttemptCount: 2' \
    'mlxCSubmoduleCloneAttemptCount: 1' \
    'gitSubmoduleTLSFailureCount: 1' \
    'tlsVerificationBypassCount: 0' \
    'customCAInstallationCount: 0' \
    '"Failed to clone '\''Source/Cmlx/mlx'\''. Retry scheduled"' \
    'focusedRootTestCount: 40' \
    'focusedWholeStepTestCount: 46' \
    'retainedLiveSequenceInvocationCounts: [1, 1, 1]' \
    'metalTestCount: 44' \
    'runtimeTestCount: 1' \
    'tokenizerTestCount: 1' \
    'stage2InvocationCount: 0' \
    'artifactUploadStepCount: 0' \
    'actionsArtifactsTotalCount: 0' \
    'failureObservationCanonicalSHA256:' \
    '"2184710f59bc2b4625bb0a74f5f835c859fada79406ffc957b5ffca4861a9926"' \
    'failedLauncherGitBlob:' \
    '"fd339c3819059050dcd31112023e169e22f9fbac"' \
    'retiredCaseInsensitiveRegex:' \
    '"^Test (Case|Suite).*failed|^error:|skipped|Test skipped"' \
    'classifierCommand: "grep -Eq"' \
    'matchingIsCaseSensitive: true' \
    'quotedXCTestCaseAndSuiteOutcomeMarkersRequireClosedIdentity: true' \
    'passingFixtureMatchCount: 0' \
    'rejectingFixtureMatchCount: 5' \
    'requiredRootTestCount: 41' \
    'requiredFocusedIsolatedTestCount: 6' \
    'requiredFocusedWholeStepTestCount: 47' \
    'requiredPreStage2CompletedTestCount: 93' \
    'activeRootCheckoutFetchDepth: 1' \
    'reviewedMainCheckoutFetchDepth: 2' \
    'launcherNetworkFetchCommandCount: 0' \
    '"PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_PREDECESSOR_LOG_CLASSIFIER_REPAIR_RECEIPT="' \
    'swiftBuildInvocationCount: 1' \
    'stagedMetallibCopyCount: 2' \
    'directXCTestInvocationCount: 1' \
    'requiredStage2TestCount: 1' \
    'requiredStage2FailureCount: 0' \
    'requiredStage2SkipCount: 0' \
    'oneDistinctExecutionAttemptAuthorized: true' \
    'githubRunAttemptMustEqualOne: true' \
    'successorObservationMustRetireLiveInvocation: true' \
    'boundedPredecessorLogClassifierRepairAuthorized: true' \
    'classifierMechanicalPinUpdatesAuthorized: true' \
    'repairImplementationObservedByThisAuthority: false' \
    'repairExecutionObservedByThisAuthority: false' \
    'secureFetchMutationAuthorized: false' \
    'workflowAuthoredRetryAuthorized: false' \
    'gitInternalRetryBehaviorMutationAuthorized: false' \
    'rerunAuthorized: false' \
    'stage2SuccessEstablished: false' \
    'stage3AuthorityEstablished: false' \
    '"AUTHORIZED_exact_one_direct_successor_bounded_case_sensitive_predecessor_log_classifier_repair_and_one_replacement_stage2_execution_not_execution_evidence_no_authored_retry_rerun_artifact_checkpoint_or_downstream_authority"' \
    'observedBaseSourceBindings.count == 21' \
    'design.exactDirectSuccessorChangedPaths.count == 6'; do
    grep -Fq -- "$required_stage2_predecessor_log_classifier_repair_authority_value" \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source" ||
        die "Stage-2 predecessor-log classifier repair authority lost: $required_stage2_predecessor_log_classifier_repair_authority_value"
done
for required_stage2_predecessor_log_classifier_repair_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'XCTAssertEqual(green.runID, 31_550_007_242)' \
    'XCTAssertEqual(green.runNumber, 73)' \
    'XCTAssertEqual(green.runAttempt, 1)' \
    'XCTAssertEqual(green.checkSuiteID, 85_584_105_952)' \
    'XCTAssertEqual(green.activeRootRunnerID, 1_000_001_700)' \
    'XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_701)' \
    'XCTAssertEqual(green.workflowAuthoredRetryCount, 0)' \
    'XCTAssertEqual(green.gitInternalSubmoduleRetryScheduledCount, 1)' \
    'XCTAssertEqual(classifier.classifierCommand, "grep -Eq")' \
    'XCTAssertTrue(classifier.matchingIsCaseSensitive)' \
    'XCTAssertEqual(classifier.exactPassingRegressionFixtures.count, 8)' \
    'XCTAssertEqual(classifier.exactRejectingRegressionFixtures.count, 5)' \
    'XCTAssertEqual(classifier.passingFixtureMatchCount, 0)' \
    'XCTAssertEqual(classifier.rejectingFixtureMatchCount, 5)' \
    '[41, 6, 47, 44, 1, 1, 93]' \
    'XCTAssertEqual(recipe.activeRootCheckoutFetchDepth, 1)' \
    'XCTAssertEqual(recipe.reviewedMainCheckoutFetchDepth, 2)' \
    '[1, 1, 0, 0, 0, 1, 0]' \
    '[1, 0, 0]' \
    'XCTAssertTrue(authority.boundedPredecessorLogClassifierRepairAuthorized)' \
    'XCTAssertFalse(authority.repairImplementationObservedByThisAuthority)' \
    'XCTAssertFalse(authority.repairExecutionObservedByThisAuthority)' \
    'falseClaims(authority.authorityCeiling).allSatisfy { !$0 }' \
    '"9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b"' \
    'XCTAssertGreaterThan(valuePaths.count, 350)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 250)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_predecessor_log_classifier_repair_field_\(index)' \
    'Authority.decodeCanonical(prefixed)' \
    'Authority.decodeCanonical(suffixed)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(slashEscapedData)' \
    'Authority.decodeCanonical(reorderedData)' \
    'Authority.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_stage2_predecessor_log_classifier_repair_test_value" \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test" ||
        die "Stage-2 predecessor-log classifier repair test lost: $required_stage2_predecessor_log_classifier_repair_test_value"
done
! grep -Fq -- '__CANONICAL_SHA256__' \
    "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source" \
    "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_test" ||
    die "Stage-2 predecessor-log classifier repair authority retains a canonical placeholder"
for forbidden_stage2_predecessor_log_classifier_repair_authority_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- "$forbidden_stage2_predecessor_log_classifier_repair_authority_capability" \
        "$stage2_metallib_bootstrap_predecessor_log_classifier_repair_authority_source"; then
        die "Stage-2 predecessor-log classifier repair authority gained capability: $forbidden_stage2_predecessor_log_classifier_repair_authority_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift' \
    '100644' \
    '35ca8e0d056ea9cffce532f2882c9d13d622e5cf' \
    '76806' \
    '3fbd5f40b70a589e38393468df526da7a128e427d9fbf9a83462efd80d35fe93'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift' \
    '100644' \
    'c176a50a7ac7367cbd7f66e6003613ba597adb43' \
    '41359' \
    'c7fd5fcd2c1422cece77d34f45e70f5778c29bbf258972c9b9b30b5e6d3f8e2e'

[[ "$(awk '/^import / { print }' \
        "$stage2_fresh_metallib_cross_binding_failure_observation_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_fresh_metallib_cross_binding_failure_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_fresh_metallib_cross_binding_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests:' \
        "$stage2_fresh_metallib_cross_binding_failure_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
        "$stage2_fresh_metallib_cross_binding_failure_observation_test")" == "1" ]] ||
    die "Stage-2 fresh-metallib cross-binding failure observation import or single-test boundary changed"
for required_stage2_fresh_metallib_cross_binding_failure_observation_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError:' \
    'case contractDrift' \
    'case noncanonicalEncoding' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    'self == Self.frozenV1' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_cross_binding_execution_failure_observation_v1"' \
    '"exact_main_stage2_fresh_metallib_cross_binding_evidence_surface_failure_observation"' \
    '"9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b"' \
    'pullRequestNumber: 89' \
    '"050c0e4c60df4a1d0bd3dbba1f194f425609cb1b"' \
    '"775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1"' \
    '"f34057921b53af80ddb40c0fd89fa4ee0ddbce85"' \
    '"ea5a8da68dd9539cdb78b5203da796941c5495a8"' \
    '"643c3de86ac22c478750f052bdf1db77bb3e634623154e8898044792ef09d02f"' \
    'observedSourceBindings.count == 10' \
    'runID: 31_555_440_908' \
    'runNumber: 75' \
    'runAttempt: 1' \
    'checkSuiteID: 85_598_166_484' \
    'exactHeadPushRunCount: 1' \
    'previousAttemptURLWasNull: true' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'id: 93_986_794_547' \
    'runnerID: 1_000_001_703' \
    'id: 93_987_253_841' \
    'runnerID: 1_000_001_704' \
    '"c7ce5e5ee05c21795ba15a235038ae9a23b66fb486e5a3448c3905a86bf6d214"' \
    'byteCount: 1_341_817' \
    'memberCount: 18' \
    'uncompressedByteCount: 20_975_223' \
    'workflowAuthoredRetryCount: 0' \
    'separateSecureFetchRetryStepCount: 0' \
    'gitInternalSubmoduleRetryCount: 0' \
    'priorRunGitInternalSubmoduleRetryCount: 1' \
    'mlxSubmoduleCloneAttemptCount: 1' \
    'mlxCSubmoduleCloneAttemptCount: 1' \
    'gitSubmoduleTLSFailureCount: 0' \
    '"ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"' \
    'focusedRootTestCount: 41' \
    'isolatedCheckpointGroupTestCounts: [1, 1, 2, 2]' \
    'focusedWholeStepTestCount: 47' \
    'observedLiveInvocationCounts: [1, 1, 1, 1]' \
    'greenPredecessorLiveSuccessCounts: [1, 1, 1]' \
    'freshMetallibByteCount: 6_292_684' \
    '"0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"' \
    'metalTestCount: 44' \
    'runtimeTestCount: 1' \
    'tokenizerTestCount: 1' \
    'completedPreStage2TestCount: 93' \
    'classifierCommand: "grep -Eq"' \
    'classifierAcceptedFixtureCount: 8' \
    'classifierRejectedFixtureCount: 5' \
    'predecessorLogInventoryCount: 10' \
    'predecessorLogScanCount: 8' \
    'stage2MetallibDiscoverySourceLine: 437' \
    'stage2MetallibHashSourceLine: 465' \
    'metalAggregateIdentityEmissionSourceLine: 159' \
    'metalXCTestTeeSourceLines: [162, 163]' \
    'crossBindingGuardSourceLines: [471, 472, 473]' \
    'predecessorReceiptValidationSourceLine: 475' \
    'stage2BuildSourceLine: 585' \
    'stage2CopySourceLines: [642, 643]' \
    'stage2DirectXCTestSourceLines: [674, 675, 676]' \
    'aggregateMetalIdentityCount: 1' \
    'metalXCTestLogIdentityCount: 0' \
    'runtimeReceiptMetallibIdentityMatched: true' \
    'tokenizerReceiptMetallibIdentityMatched: true' \
    'metallibIdentityDivergenceObserved: false' \
    '"deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence"' \
    '"prime-native-decoder-stage2-metallib-bootstrap-repair: Metal log does not bind the fresh metallib"' \
    'processExitCode: 2' \
    'predecessorReceiptValidationReached: false' \
    'sameJobFreshMetallibWasInspectedByStage2Launcher: true' \
    'stage2RepairLauncherReachedFreshMetallibDiscovery: true' \
    'stage2MetallibDiscoveryCount: 1' \
    'stage2MetallibCandidateCount: 1' \
    'stage2BuildInvocationCount: 0' \
    'stage2DirectXCTestInvocationCount: 0' \
    'stage2TestStartCount: 0' \
    'stage2RepairReceiptCount: 0' \
    'predecessorExecutionAuthorityConsumed: true' \
    'predecessorExecutionAuthorityExhausted: true' \
    'failureObservationAuthorizesNothing: true' \
    'consumedStage2LiveInvocationRetirementRequired: true' \
    'launcherMutationAuthorized: false' \
    'stage2ReexecutionAuthorized: false' \
    'stage3RemainsBlocked: true' \
    '"FAIL_exact_main_stage2_fresh_metallib_cross_binding_log_channel_guard_no_stage2_build_test_or_receipt_no_rerun_no_artifact_no_downstream_authority"' \
    '"retire_consumed_stage2_live_invocation_without_rerun"' \
    '"preserve_metal_and_failed_stage2_launcher_sources_and_immutable_evidence"' \
    '"separately_authorize_bounded_fresh_metallib_cross_binding_evidence_surface_repair"'; do
    grep -Fq -- "$required_stage2_fresh_metallib_cross_binding_failure_observation_value" \
        "$stage2_fresh_metallib_cross_binding_failure_observation_source" ||
        die "Stage-2 fresh-metallib cross-binding failure observation lost: $required_stage2_fresh_metallib_cross_binding_failure_observation_value"
done
for required_stage2_fresh_metallib_cross_binding_failure_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(run.runID, 31_555_440_908)' \
    'XCTAssertEqual(predecessor.focusedRootTestCount, 41)' \
    'XCTAssertEqual(predecessor.completedPreStage2TestCount, 93)' \
    'XCTAssertEqual(failure.predecessorLogScanCount, 8)' \
    'XCTAssertEqual(failure.aggregateMetalIdentityCount, 1)' \
    'XCTAssertEqual(failure.metalXCTestLogIdentityCount, 0)' \
    'XCTAssertTrue(failure.sameJobFreshMetallibWasInspectedByStage2Launcher)' \
    'XCTAssertTrue(failure.stage2RepairLauncherReachedFreshMetallibDiscovery)' \
    'XCTAssertEqual(failure.stage2BuildInvocationCount, 0)' \
    'XCTAssertEqual(failure.stage2DirectXCTestInvocationCount, 0)' \
    'XCTAssertEqual(failure.stage2RepairReceiptCount, 0)' \
    'XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })' \
    '"6c0f9a82ff61e30abc9122faca47fdace203deecd464431d41fd84d0709d382f"' \
    'XCTAssertGreaterThan(valuePaths.count, 350)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 250)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_fresh_cross_binding_failure_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_stage2_fresh_metallib_cross_binding_failure_test_value" \
        "$stage2_fresh_metallib_cross_binding_failure_observation_test" ||
        die "Stage-2 fresh-metallib cross-binding failure-observation test lost: $required_stage2_fresh_metallib_cross_binding_failure_test_value"
done
! grep -Fq -- '__CANONICAL_SHA256__' \
    "$stage2_fresh_metallib_cross_binding_failure_observation_source" \
    "$stage2_fresh_metallib_cross_binding_failure_observation_test" ||
    die "Stage-2 fresh-metallib cross-binding failure observation retains a canonical placeholder"
for forbidden_stage2_fresh_metallib_cross_binding_failure_observation_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- \
        "$forbidden_stage2_fresh_metallib_cross_binding_failure_observation_capability" \
        "$stage2_fresh_metallib_cross_binding_failure_observation_source"; then
        die "Stage-2 fresh-metallib cross-binding failure observation gained capability: $forbidden_stage2_fresh_metallib_cross_binding_failure_observation_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift' \
    '100644' \
    '523d30f7bd42d67276476ee545cc2f62c4a5b361' \
    '63673' \
    'cb1e143d35c553514aec2e715a0e6beb87fc63b212be390bb1bd50ca630f14e0'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift' \
    '100644' \
    'cb5e9301694ae6f37d0d2001fecabe589d563c6c' \
    '33534' \
    '03b25be292a00917320d208333e1bfd820042dd8e44ba440f736db0d7363ece3'

[[ "$(awk '/^import / { print }' \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests:' \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test")" == "1" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair authority import or single-test boundary changed"
for required_stage2_fresh_metallib_evidence_surface_repair_authority_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError:' \
    'case contractDrift' \
    'case noncanonicalEncoding' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1:' \
    'Codable,' \
    'Equatable,' \
    'Sendable' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    'try failure.validateExactV1()' \
    'self == Self.frozenV1' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1"' \
    '"exact_main_direct_successor_bounded_fresh_metallib_evidence_surface_repair_and_one_replacement_stage2_execution_authority"' \
    '"075922cec8361c0085d5b2c6d000828e3c0bfc35"' \
    '"c6bd910b13796bb12098834c5e7daab83cba8668"' \
    'workflowID: 329_017_041' \
    'runID: 31_560_270_980' \
    'runNumber: 77' \
    'runAttempt: 1' \
    'checkSuiteID: 85_610_747_095' \
    'activeRootRunnerID: 1_000_001_706' \
    'reviewedMainRunnerID: 1_000_001_707' \
    'workflowAuthoredRetryCount: 0' \
    'gitInternalSubmoduleRetryScheduledCount: 0' \
    'mlxSubmoduleCloneAttemptCount: 1' \
    'mlxCSubmoduleCloneAttemptCount: 1' \
    'gitSubmoduleTLSFailureCount: 0' \
    'tlsVerificationBypassCount: 0' \
    'customCAInstallationCount: 0' \
    'focusedRootTestCount: 42' \
    'focusedWholeStepTestCount: 48' \
    'retainedLiveSequence: [' \
    'retainedLiveInvocationCounts: [1, 1, 1]' \
    'metallibByteCount: 6_292_652' \
    '"026a9cb2e57091ea50d51f037ec94735d04941d4115adc567dace16d629c65b7"' \
    'metalTestCount: 44' \
    'runtimeTestCount: 1' \
    'tokenizerTestCount: 1' \
    'preStage2CompletedTestCount: 94' \
    'stage2LauncherInvocationCount: 0' \
    'stage2BuildInvocationCount: 0' \
    'stage2DirectXCTestInvocationCount: 0' \
    'stage2ReceiptCount: 0' \
    'actionsArtifactsTotalCount: 0' \
    'actionsArtifactsArrayExactlyEmpty: true' \
    '"8112ede2cb0c1caaa325495a55481e7b6f15491c3919a0013ab11a6dfc038ef3"' \
    '"6c0f9a82ff61e30abc9122faca47fdace203deecd464431d41fd84d0709d382f"' \
    'exhaustedRunID: 31_555_440_908' \
    '"45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb"' \
    'failedLauncherByteCount: 44_691' \
    '"3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185"' \
    'aggregateMetalIdentityCount: 1' \
    'metalXCTestLogIdentityCount: 0' \
    'metallibIdentityDivergenceObserved: false' \
    'stage2FreshMetallibDiscoveryCount: 1' \
    'predecessorExecutionAuthorityConsumed: true' \
    'predecessorExecutionAuthorityExhausted: true' \
    'failedRunRecoverable: false' \
    'consumedLiveInvocationRetired: true' \
    'exactDirectSuccessorChangedStatuses: [' \
    '"M", "M", "M", "M", "A", "A"' \
    'activeRootCheckoutFetchDepth: 1' \
    'reviewedMainCheckoutFetchDepth: 2' \
    '"PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT="' \
    '"ergentics_prime_native_decoder_stage2_metallib_bootstrap_fresh_metallib_evidence_surface_repair_receipt_v1"' \
    '"PASS_exact_main_stage2_same_job_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip"' \
    'impossibleMetalXCTestIdentityGrepRemovalCount: 1' \
    '"prime-native-decoder-metal-full-output.log"' \
    'metalFullOutputLogCaptureAdded: true' \
    'metalFullOutputLogCaptureInvocationCount: 1' \
    'metalFullOutputLogTeeInvocationCount: 1' \
    'metalFullOutputLogInitialAbsenceRequired: true' \
    'metalFullOutputLogRegularFileRequired: true' \
    'metalFullOutputLogSymbolicLinkForbidden: true' \
    'metalFullOutputLogRequiredHardLinkCount: 1' \
    'requiredMetalLauncherPipeStatus: 0' \
    'requiredMetalFullOutputTeePipeStatus: 0' \
    'metalLauncherExitAndTeeExitValidated: true' \
    'metalFullOutputLogIdentityPrefixCount: 1' \
    'metalFullOutputLogFreshIdentityCount: 1' \
    'metalXCTestLogIdentityPrefixCount: 0' \
    'metalXCTestLogFreshIdentityCount: 0' \
    'metalLauncherSourceChanged: false' \
    'metalLauncherMutationCount: 0' \
    'predecessorLogClassifierMutationCount: 0' \
    'requiredPredecessorLogCount: 11' \
    'requiredClassifierScannedLogCount: 8' \
    'classifierAcceptedFixtureCount: 8' \
    'classifierRejectedFixtureCount: 5' \
    'requiredPredecessorReceiptCount: 2' \
    'requiredFocusedRootTestCount: 43' \
    'requiredFocusedIsolatedTestCount: 6' \
    'requiredFocusedWholeStepTestCount: 49' \
    'requiredMetalTestCount: 44' \
    'requiredRuntimeTestCount: 1' \
    'requiredTokenizerTestCount: 1' \
    'requiredPreStage2CompletedTestCount: 95' \
    'requiredTrustedCompletedTestCount: 96' \
    'freshSourceCandidateCount: 1' \
    'freshSourceFileIdentityValidated: true' \
    'requiredMetallibIdentityInventoryCount: 5' \
    'requiredMetalBundleCandidateCount: 2' \
    'metalBundleByteIdentityMatchCount: 2' \
    'runtimeReceiptIdentityMatchCount: 1' \
    'tokenizerReceiptIdentityMatchCount: 1' \
    'receiptIdentityCrossBindingEstablished: true' \
    'loadedMetallibPathInferred: false' \
    'predecessorArtifactSnapshotCount: 16' \
    'predecessorArtifactRevalidationCountAfterXCTest: 16' \
    'swiftBuildInvocationCount: 1' \
    'stagedMetallibCopyCount: 2' \
    'stagedMetallibPermissionMode: "444"' \
    'directXCTestInvocationCount: 1' \
    'rebuildAfterStagingInvocationCount: 0' \
    'requiredStage2TestCount: 1' \
    'requiredStage2FailureCount: 0' \
    'requiredStage2SkipCount: 0' \
    'oneDistinctExecutionAttemptAuthorized: true' \
    'fixedMetalFullOutputLogCaptureAuthorized: true' \
    'additionalLogCaptureBeyondFixedMetalFullOutputAuthorized: false' \
    'repairImplementationObservedByThisAuthority: false' \
    'repairExecutionObservedByThisAuthority: false' \
    'stage2SuccessEstablished: false' \
    'stage3AuthorityEstablished: false' \
    '"AUTHORIZED_exact_one_direct_successor_bounded_fresh_metallib_evidence_surface_repair_and_one_replacement_stage2_execution_not_execution_evidence_no_retry_rerun_artifact_checkpoint_or_downstream_authority"'; do
    grep -Fq -- "$required_stage2_fresh_metallib_evidence_surface_repair_authority_value" \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_source" ||
        die "Stage-2 fresh-metallib evidence-surface repair authority lost: $required_stage2_fresh_metallib_evidence_surface_repair_authority_value"
done
for required_stage2_fresh_metallib_evidence_surface_repair_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'XCTAssertEqual(green.runID, 31_560_270_980)' \
    'XCTAssertEqual(green.runNumber, 77)' \
    'XCTAssertEqual(green.runAttempt, 1)' \
    'XCTAssertEqual(green.activeRootRunnerID, 1_000_001_706)' \
    'XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_707)' \
    '[42, 0, 0, 48, 0, 0]' \
    '[44, 0, 0, 1, 0, 0, 1, 0, 0, 94, 0, 0]' \
    'XCTAssertEqual(consumed.aggregateMetalIdentityCount, 1)' \
    'XCTAssertEqual(consumed.metalXCTestLogIdentityCount, 0)' \
    '[11, 8, 8, 5, 2]' \
    '[43, 6, 49, 44, 1, 1, 95, 96]' \
    'XCTAssertEqual(design.metalFullOutputLogIdentityPrefixCount, 1)' \
    'XCTAssertEqual(design.metalFullOutputLogFreshIdentityCount, 1)' \
    'XCTAssertEqual(design.metalXCTestLogIdentityPrefixCount, 0)' \
    'XCTAssertEqual(design.metalXCTestLogFreshIdentityCount, 0)' \
    'XCTAssertEqual(design.predecessorArtifactSnapshotCount, 16)' \
    'XCTAssertEqual(design.predecessorArtifactRevalidationCountAfterXCTest, 16)' \
    'XCTAssertTrue(authority.fixedMetalFullOutputLogCaptureAuthorized)' \
    'falseClaims(authority.authorityCeiling).allSatisfy { !$0 }' \
    '"bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a"' \
    'requireSendable(Authority.self)' \
    'XCTAssertGreaterThan(valuePaths.count, 300)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 225)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_fresh_metallib_evidence_surface_repair_field_\(index)' \
    'Authority.decodeCanonical(prefixed)' \
    'Authority.decodeCanonical(suffixed)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(slashEscapedData)' \
    'Authority.decodeCanonical(reorderedData)' \
    'Authority.decodeCanonical(duplicateData)'; do
    grep -Fq -- "$required_stage2_fresh_metallib_evidence_surface_repair_test_value" \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test" ||
        die "Stage-2 fresh-metallib evidence-surface repair test lost: $required_stage2_fresh_metallib_evidence_surface_repair_test_value"
done
for stage2_fresh_metallib_evidence_surface_repair_placeholder in \
    '__CANONICAL_SHA256__' 'PINNED_CANONICAL_SHA256' 'PLACEHOLDER'; do
    ! grep -Fq -- "$stage2_fresh_metallib_evidence_surface_repair_placeholder" \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_source" \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_test" ||
        die "Stage-2 fresh-metallib evidence-surface repair authority retains a placeholder"
done
for forbidden_stage2_fresh_metallib_evidence_surface_repair_authority_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- \
        "$forbidden_stage2_fresh_metallib_evidence_surface_repair_authority_capability" \
        "$stage2_fresh_metallib_evidence_surface_repair_authority_source"; then
        die "Stage-2 fresh-metallib evidence-surface repair authority gained capability: $forbidden_stage2_fresh_metallib_evidence_surface_repair_authority_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservation.swift' \
    '100644' \
    '3acba8ddf8bd90dc36a858d1d424f3efdd6e8d44' \
    '79616' \
    '24490e18f9b20e622fcd92f054f0325b55e1f404302754d71cc57eb26e424c3f'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests.swift' \
    '100644' \
    '1b182445cc3aa7bcd57e2b99390daf8a42141b3f' \
    '39775' \
    '7c6cabc7b0ed955f0b5d194f7e7766ca27b8613ff9e9c69b43b431e761b859bb'
[[ "$(wc -l < \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source" | awk '{print $1}')" == "1553" \
    && "$(wc -l < \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test" | awk '{print $1}')" == "915" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair execution observation LF count changed"

[[ "$(awk '/^import / { print }' \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests:' \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling()' \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test")" == "1" ]] ||
    die "Stage-2 fresh-metallib evidence-surface repair execution observation import or single-test boundary changed"
for required_stage2_fresh_metallib_evidence_surface_repair_execution_observation_value in \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError:' \
    'case contractDrift' \
    'case noncanonicalEncoding' \
    'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationV1:' \
    'public static let frozenV1 = Self(' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    'public func validateExactV1() throws {' \
    'self == Self.frozenV1' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_execution_observation_v1"' \
    '"exact_main_stage2_fresh_metallib_evidence_surface_repair_execution_success_observation"' \
    '"ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1"' \
    '"bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a"' \
    'pullRequestNumber: 91' \
    '"5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d"' \
    '"075922cec8361c0085d5b2c6d000828e3c0bfc35"' \
    '"f2d04016463133854995d2523770bb19cfe2eef4"' \
    '"d673bcbfa13b660b7fe898dc127186e8da1aaa6b"' \
    '"2e9a9da262a8c6a6b3e12b2d71e42627fc46bbc6bffd60c7791d5a5812ce58d7"' \
    'observedSourceBindings.count == 18' \
    'runID: 31_565_094_400' \
    'runNumber: 79' \
    'runAttempt: 1' \
    'checkSuiteID: 85_623_258_434' \
    'exactHeadPushRunCount: 1' \
    'previousAttemptURLWasNull: true' \
    'secondAttemptEndpointHTTPStatus: 404' \
    'rerunCount: 0' \
    'rerunObserved: false' \
    'rerunAuthorized: false' \
    'id: 94_015_181_778' \
    'runnerID: 1_000_001_709' \
    'id: 94_015_642_394' \
    'runnerID: 1_000_001_710' \
    '"680fc1b1672db3ef0d2bab7d7e8599d6d176d3929d14aeeef4f03197cdc7cce4"' \
    '"019f6ba8535ddaca21b49ecc289b91cb09679552cb597c99d634139646ff7c3a"' \
    '"457781579fa43d313886ca57c887fd5a42d828a6b97e33cec5fc682181d3caf7"' \
    '"c21ee98599a75671bfe125cf100a42d02131acedb0dd5265c050177d074e79ac"' \
    '"6327bf59a8f84557af8d9cc01f4274114e48e47238379139752bd2b94e3df583"' \
    'byteCount: 1_357_752' \
    '"02e8588ba5ac1190ce309cd1a7b92fc8fc04e383e5ffb101acb07df17590dfb3"' \
    'memberCount: 18' \
    'uncompressedByteCount: 21_069_195' \
    'workflowAuthoredRetryCount: 0' \
    'separateRetryStepCount: 0' \
    'gitInternalSubmoduleRetryCount: 0' \
    'mlxSubmoduleCloneAttemptCount: 1' \
    'mlxCSubmoduleCloneAttemptCount: 1' \
    'gitSubmoduleTLSFailureCount: 0' \
    'tlsVerificationBypassCount: 0' \
    '"ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"' \
    'latinCompletedTestCount: 116' \
    'focusedRootTestCount: 43' \
    'isolatedCheckpointGroupTestCounts: [1, 1, 2, 2]' \
    'focusedWholeStepTestCount: 49' \
    'liveInvocationSequence: [' \
    '"metal", "maintained_runtime", "tokenizer", "stage2"' \
    'liveInvocationCounts: [1, 1, 1, 1]' \
    'freshMetallibByteCount: 6_292_732' \
    '"54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6"' \
    'metalGroupTestCounts: [11, 14, 19]' \
    'metalTestCount: 44' \
    'runtimeTestCount: 1' \
    '"1e03e85dd25c553d46d181c148b8b45bb7e701498cb335f2a07b4596b32bb619"' \
    'tokenizerTestCount: 1' \
    '"102ccf73a7e4c527dfbdce70d52946e570f4c2677e50e189e0a41c82705baca7"' \
    'validatedPredecessorLogCount: 11' \
    'validatedPredecessorReceiptCount: 2' \
    'predecessorArtifactSnapshotCount: 16' \
    'predecessorArtifactRevalidationCountAfterXCTest: 16' \
    'completedPreStage2TestCount: 95' \
    '"$RUNNER_TEMP/prime-native-decoder-metal-full-output.log"' \
    'captureInvocationCount: 1' \
    'teeInvocationCount: 1' \
    'pipelineStatusElementCount: 2' \
    'launcherPipelineStatus: 0' \
    'teePipelineStatus: 0' \
    'pipelineStatusCapturedImmediatelyAfterPipeline: true' \
    'errexitRestoredImmediatelyAfterStatusCapture: true' \
    'fullOutputIdentityPrefixCount: 1' \
    'fullOutputExactIdentityCount: 1' \
    'xctestOnlyIdentityPrefixCount: 0' \
    'xctestOnlyExactIdentityCount: 0' \
    'metalLauncherSourceChanged: false' \
    'acceptanceFixtureCount: 8' \
    'rejectionFixtureCount: 5' \
    'scannedLogCount: 8' \
    'freshSourceCandidateCount: 1' \
    'metallibIdentityInventoryCount: 5' \
    'byteIdenticalComparisonCount: 5' \
    'byteCountEqualityCount: 5' \
    'sha256EqualityCount: 5' \
    'metalBundleCandidateCount: 2' \
    'runtimeBundleCandidateCount: 1' \
    'tokenizerBundleCandidateCount: 1' \
    'runtimeReceiptIdentityMatchCount: 1' \
    'tokenizerReceiptIdentityMatchCount: 1' \
    'sourceBoundEvidenceEstablished: true' \
    'loadedMetallibPathInferred: false' \
    'independentlyObservedLoadedMetallibIdentityEstablished: false' \
    'buildCommandCount: 1' \
    'metallibBuiltByThisLauncher: false' \
    'stagedDestinationCount: 2' \
    'stagedCopyCount: 2' \
    'stagedPermissionMode: "444"' \
    'directXCTestInvocationCount: 1' \
    '"testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"' \
    'testStartCount: 1' \
    'testPassCount: 1' \
    'testFailureCount: 0' \
    'testSkipCount: 0' \
    '"5c7a1cb1cec4a66517e5e1fc382ae757f6d6b6460d1f55b963040b958d907a78"' \
    'trustedCompletedTestCount: 96' \
    'mechanicsExecutionEstablished: true' \
    'defaultMetallibBootstrapRepairEstablished: true' \
    'freshMetallibEvidenceSurfaceRepairEstablished: true' \
    'actionsArtifactsTotalCount: 0' \
    'runLogArchiveIsActionsArtifact: false' \
    'freshMetallibArtifactProvenanceEstablished: false' \
    'checkpointArtifactCreated: false' \
    'predecessorRepairAuthorityConsumed: true' \
    'predecessorRepairAuthorityExhausted: true' \
    'successObservationAuthorizesNothing: true' \
    'consumedStage2LiveInvocationRetirementRequired: true' \
    'launcherSourceMustRemainPreservedForAudit: true' \
    'stage3RemainsBlocked: true' \
    'additionalStage2ExecutionAuthorized: false' \
    'trainingResumeEstablished: false' \
    'productUseAuthorized: false' \
    'publicationAuthorized: false' \
    'stage3AuthorityEstablished: false' \
    '"PASS_exact_main_stage2_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip_no_rerun_no_artifact_no_stage3_authority"' \
    '"retire_consumed_stage2_live_invocation_without_rerun"' \
    '"preserve_frozen_stage2_launcher_and_immutable_execution_evidence"' \
    '"keep_stage3_blocked_until_distinct_authority"'; do
    grep -Fq -- \
        "$required_stage2_fresh_metallib_evidence_surface_repair_execution_observation_value" \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source" ||
        die "Stage-2 fresh-metallib evidence-surface repair execution observation lost: $required_stage2_fresh_metallib_evidence_surface_repair_execution_observation_value"
done
for required_stage2_fresh_metallib_evidence_surface_repair_execution_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling()' \
    'XCTAssertNoThrow(try observation.validateExactV1())' \
    'XCTAssertEqual(run.runID, 31_565_094_400)' \
    'XCTAssertEqual(run.runNumber, 79)' \
    'XCTAssertEqual(run.runAttempt, 1)' \
    'XCTAssertEqual(run.rerunCount, 0)' \
    'XCTAssertEqual(predecessor.focusedRootTestCount, 43)' \
    'XCTAssertEqual(predecessor.focusedWholeStepTestCount, 49)' \
    'XCTAssertEqual(predecessor.completedPreStage2TestCount, 95)' \
    'XCTAssertEqual(stage2.testStartCount, 1)' \
    'XCTAssertEqual(stage2.testPassCount, 1)' \
    'XCTAssertEqual(stage2.testFailureCount, 0)' \
    'XCTAssertEqual(stage2.testSkipCount, 0)' \
    'XCTAssertTrue(stage2.sourceBoundEvidenceEstablished)' \
    'XCTAssertFalse(stage2.loadedMetallibPathInferred)' \
    'XCTAssertFalse(stage2.independentlyObservedLoadedMetallibIdentityEstablished)' \
    'XCTAssertFalse(receipt.loadedMetallibIdentityIndependentlyObserved)' \
    'XCTAssertFalse(receipt.metallibArtifactProvenanceEstablished)' \
    'XCTAssertEqual(stage2.trustedCompletedTestCount, 96)' \
    'XCTAssertTrue(stage2.mechanicsExecutionEstablished)' \
    'XCTAssertTrue(stage2.defaultMetallibBootstrapRepairEstablished)' \
    'XCTAssertTrue(stage2.freshMetallibEvidenceSurfaceRepairEstablished)' \
    'XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })' \
    'XCTAssertTrue(ceiling.successObservationAuthorizesNothing)' \
    'XCTAssertTrue(ceiling.consumedStage2LiveInvocationRetirementRequired)' \
    'XCTAssertTrue(ceiling.stage3RemainsBlocked)' \
    'XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })' \
    '"f553a7ce431cedccf25b06a89af2a47f8adcf9db556ca4b5a2341bb3463729e4"' \
    'requireSendable(Observation.self)' \
    'XCTAssertGreaterThan(valuePaths.count, 400)' \
    'XCTAssertGreaterThan(dictionaryPaths.count, 20)' \
    'XCTAssertGreaterThan(scalarPaths.count, 300)' \
    'null \(pathLabel(path))' \
    'removed \(pathLabel(path))' \
    'unknown_stage2_evidence_repair_execution_field_\(index)' \
    'Observation.decodeCanonical(prefixed)' \
    'Observation.decodeCanonical(suffixed)' \
    'Observation.decodeCanonical(pretty)' \
    'Observation.decodeCanonical(slashEscapedData)' \
    'Observation.decodeCanonical(reorderedData)' \
    'Observation.decodeCanonical(duplicateData)'; do
    grep -Fq -- \
        "$required_stage2_fresh_metallib_evidence_surface_repair_execution_test_value" \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test" ||
        die "Stage-2 fresh-metallib evidence-surface repair execution-observation test lost: $required_stage2_fresh_metallib_evidence_surface_repair_execution_test_value"
done
for stage2_fresh_metallib_evidence_surface_repair_execution_placeholder in \
    '__CANONICAL_SHA256__' 'PINNED_CANONICAL_SHA256' 'PLACEHOLDER'; do
    ! grep -Fq -- \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_placeholder" \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source" \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_test" ||
        die "Stage-2 fresh-metallib evidence-surface repair execution observation retains a placeholder"
done
for forbidden_stage2_fresh_metallib_evidence_surface_repair_execution_observation_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'PrimeNativeGQADecoder.make(' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- \
        "$forbidden_stage2_fresh_metallib_evidence_surface_repair_execution_observation_capability" \
        "$stage2_fresh_metallib_evidence_surface_repair_execution_observation_source"; then
        die "Stage-2 fresh-metallib evidence-surface repair execution observation gained capability: $forbidden_stage2_fresh_metallib_evidence_surface_repair_execution_observation_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthority.swift' \
    '100644' \
    '65cb43e09e9839c0b03cc2e5fafd1ad0b1d4f4fa' \
    '37517' \
    '72a521a0eb6e0e169150e8934925794639bb1d9576fa9c02896c817965af11b4'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests.swift' \
    '100644' \
    'ab751cfbb2bf728054d3e91ae25d5fce1be8533a' \
    '14254' \
    'baf8eb9c32f4298a77c619643535da98aea45f7c5cf996f54be78888130fedba'
[[ "$(wc -l < \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" | awk '{print $1}')" == "794" \
    && "$(wc -l < \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test" | awk '{print $1}')" == "363" \
    && "$(tr -cd '\r' < \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" | wc -c | awk '{print $1}')" == "0" \
    && "$(tr -cd '\r' < \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test" | wc -c | awk '{print $1}')" == "0" ]] ||
    die "Stage-3 explicit-RNG/cursor-resume authority line-ending identity changed"

[[ "$(awk '/^import / { print }' \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityTests:' \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()' \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test")" == "1" ]] ||
    die "Stage-3 explicit-RNG/cursor-resume authority import or single-test boundary changed"
for required_stage3_tiny_cpu_explicit_rng_cursor_resume_authority_value in \
    'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError:' \
    'PrimeNativeDecoderTinyCPUExplicitRNGDomainV1:' \
    'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityV1:' \
    'public static let frozenV1 = Self(' \
    'public func validateExactV1() throws {' \
    'self == Self.frozenV1' \
    'public static func decodeCanonical(_ data: Data) throws -> Self {' \
    '"0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6"' \
    '"tiny_cpu_explicit_rng_cursor_resume_v1"' \
    '"71b456d78be5addc858b706677005753eb22c39a"' \
    '"6e5a37bb71cdf62040e31a8ab21fc935e7f663a3"' \
    '"f553a7ce431cedccf25b06a89af2a47f8adcf9db556ca4b5a2341bb3463729e4"' \
    'mechanicsExecutionRunID: 31_565_094_400' \
    'retirementRunID: 31_572_113_622' \
    'retirementRootTestCount: 44' \
    'stage2MechanicsEstablished: true' \
    'stage2InvocationRetired: true' \
    'uniqueParameterCount: 5_200' \
    'trainableParameterPathCount: 20' \
    'firstMomentTensorCount: 20' \
    'secondMomentTensorCount: 20' \
    'algorithmID: "sha256_counter_stream_v1"' \
    'requiredDomains: PrimeNativeDecoderTinyCPUExplicitRNGDomainV1' \
    'implicitGlobalRandomStateAuthorized: false' \
    'mlxRandomStateInnerStateImporterAuthorized: false' \
    'cursorPointsToNextUnconsumedBatch: true' \
    'callerSuppliedBatchSubstitutionPermitted: false' \
    'snapshotStorage: "process_local_typed_value_only"' \
    'optimizerMomentTensorCount: 40' \
    'restoreTargetMustBeFresh: true' \
    'restoreTargetOptimizerMustBeUninitialized: true' \
    'restoreFailureMustLeaveFreshTargetUnchanged: true' \
    'step2ResultEqualityRequired: true' \
    'tensorValueEqualityIsBitExact: true' \
    'digestEqualityAloneIsSufficient: false' \
    'exactlyOneHostedTestRequired: true' \
    '".github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh"' \
    '"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"' \
    'newHostedLauncherRequired: true' \
    'authorityOnlyNoExecutionEvidence: true' \
    'implementationAuthorizedAfterGreenAuthorityClosure: true' \
    'oneExactMainExecutionOpportunityAuthorized: true' \
    'filesystemMutationAuthorized: false' \
    'checkpointReadAuthorized: false' \
    'checkpointWriteAuthorized: false' \
    'artifactRootAuthorized: false' \
    'metalDeterminismEstablished: false' \
    'native300MTrainingAuthorized: false' \
    'stage4Authorized: false' \
    'publicationAuthorized: false' \
    'AUTHORIZED_stage3_tiny_cpu_typed_in_memory_explicit_rng_cursor_resume_implementation_and_one_exact_main_witness_after_green_authority_closure_no_checkpoint_artifact_metal_determinism_native300m_or_downstream_authority'; do
    grep -Fq -- \
        "$required_stage3_tiny_cpu_explicit_rng_cursor_resume_authority_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" ||
        die "Stage-3 explicit-RNG/cursor-resume authority lost: $required_stage3_tiny_cpu_explicit_rng_cursor_resume_authority_value"
done
for required_stage3_tiny_cpu_explicit_rng_cursor_resume_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()' \
    'XCTAssertNoThrow(try authority.validateExactV1())' \
    'XCTAssertEqual(authority.stageID, "tiny_cpu_explicit_rng_cursor_resume_v1")' \
    'XCTAssertTrue(authority.stage2Evidence.stage2MechanicsEstablished)' \
    'XCTAssertTrue(authority.stage2Evidence.stage2InvocationRetired)' \
    'XCTAssertEqual(authority.fixture.trainableParameterPathCount, 20)' \
    'PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases' \
    'XCTAssertFalse(authority.randomDesign.implicitGlobalRandomStateAuthorized)' \
    'XCTAssertTrue(authority.cursorDesign.cursorPointsToNextUnconsumedBatch)' \
    'XCTAssertTrue(authority.snapshotBoundary.restoreTargetMustBeFresh)' \
    'XCTAssertTrue(authority.witness.step2ResultEqualityRequired)' \
    'XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 6)' \
    'XCTAssertTrue(authority.ceiling.authorityOnlyNoExecutionEvidence)' \
    'authorityFalseClaims(authority.ceiling).allSatisfy { !$0 }' \
    'unknown_stage3_rng_cursor_authority_field_\(index)' \
    'Authority.decodeCanonical(pretty)' \
    'Authority.decodeCanonical(Data([0x20]) + canonical)' \
    'Authority.decodeCanonical(canonical + Data([0x0a]))' \
    'Authority.decodeCanonical(duplicate)' \
    'requireSendable(Authority.self)'; do
    grep -Fq -- \
        "$required_stage3_tiny_cpu_explicit_rng_cursor_resume_test_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_test" ||
        die "Stage-3 explicit-RNG/cursor-resume authority test lost: $required_stage3_tiny_cpu_explicit_rng_cursor_resume_test_value"
done
for stage3_tiny_cpu_explicit_rng_cursor_resume_placeholder in \
    '__CANONICAL_SHA256__' 'PINNED_CANONICAL_SHA256' 'PLACEHOLDER'; do
    ! grep -Fq -- \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_placeholder" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source" ||
        die "Stage-3 explicit-RNG/cursor-resume authority retains a placeholder"
done
for forbidden_stage3_tiny_cpu_explicit_rng_cursor_resume_capability in \
    'import CoreGraphics' \
    'import Metal' \
    'import MLX' \
    'import MLXNN' \
    'import MLXOptimizers' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve('; do
    if grep -Fq -- \
        "$forbidden_stage3_tiny_cpu_explicit_rng_cursor_resume_capability" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_authority_source"; then
        die "Stage-3 explicit-RNG/cursor-resume authority gained capability: $forbidden_stage3_tiny_cpu_explicit_rng_cursor_resume_capability"
    fi
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift' \
    '100644' \
    'eefd30bc41cefc2fbfe226fc5c33b9525679c72c' \
    '12344' \
    'f535def96350b264b37143cc7f4c3be6e47ef6f37b000cf887ead93ae4daab1c'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift' \
    '100644' \
    '24b36a968f97032146ca6833a9ff4eb20758ac92' \
    '5090' \
    '3401d564066cd7529d0001d505d91690a0290ddcd79c2242f6a97e8d8f0d5d74'
[[ "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source" | awk '{print $1}')" == "257" \
    && "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test" | awk '{print $1}')" == "102" \
    && "$(awk '/^import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source")" == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test")" == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test")" == "1" ]] ||
    die "Stage-3 canonical-binding repair authority identity surface changed"
for required_stage3_canonical_binding_repair_value in \
    '"34cd246fbeb754f31f7ecf3fee03d35fdc5c615e5a61c245e609a7ef03845b59"' \
    'workflowRunID: 31_671_673_260' \
    'workflowRunNumber: 85' \
    'checkSuiteID: 85_917_692_508' \
    'stage3LauncherInvocationCount: 1' \
    'stage3BuildCount: 0' \
    'stage3DirectXCTestCount: 0' \
    'stage3ReceiptCount: 0' \
    'canonicalOccurrenceCountInAuthoritySource: 1' \
    'canonicalOccurrenceCountInAuthorityTest: 0' \
    'failedSearchLiteral: "grep -Fq \"$authority_canonical_sha256\" \"$authority_test\""' \
    'repairedSearchLiteral: "grep -Fq \"$authority_canonical_sha256\" \"$authority_source\""' \
    'expectedRootTestCount: 46' \
    'retryOrRerunAuthorized: false' \
    'distinctDirectMainSuccessorAttemptAuthorized: true' \
    'stage3ExecutionEstablished: false' \
    'trainingResumeEstablished: false' \
    'stage4Authorized: false' \
    'outcomeObservationRequired: true'; do
    grep -Fq -- "$required_stage3_canonical_binding_repair_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source" ||
        die "Stage-3 canonical-binding repair authority lost: $required_stage3_canonical_binding_repair_value"
done
for required_stage3_canonical_binding_repair_test_value in \
    'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()' \
    'XCTAssertGreaterThan(mutationCount, 60)' \
    'XCTAssertFalse(authority.defect.stage3MechanicsFailureEstablished)' \
    'XCTAssertFalse(authority.repair.retryOrRerunAuthorized)' \
    'XCTAssertFalse(authority.ceiling.stage3ExecutionEstablished)' \
    'XCTAssertTrue(authority.ceiling.outcomeObservationRequired)'; do
    grep -Fq -- "$required_stage3_canonical_binding_repair_test_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_test" ||
        die "Stage-3 canonical-binding repair authority test lost: $required_stage3_canonical_binding_repair_test_value"
done
for forbidden_stage3_canonical_binding_repair_capability in \
    'import CoreGraphics' 'import Metal' 'import MLX' 'import MLXNN' \
    'import MLXOptimizers' 'FileManager' 'FileHandle' 'URLSession' 'Process('; do
    ! grep -Fq -- "$forbidden_stage3_canonical_binding_repair_capability" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_canonical_binding_repair_authority_source" ||
        die "Stage-3 canonical-binding repair authority gained capability: $forbidden_stage3_canonical_binding_repair_capability"
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift' \
    '100644' \
    'a3537ccf14aaa1ceb158688999fdd6fb2af5f5cc' \
    '10830' \
    'cfac0afd75b61950aea7a4fa16c067a07d934d99a5cc2b27905725b3563b840d'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift' \
    '100644' \
    '9db7797c80c57b0b97e108f3b9688e4c069ea015' \
    '3453' \
    '3395533b29fa5b00a62448a42d9da4fa821e5f5eb1232c0f19f3ca5d749ffdb8'
[[ "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source" | awk '{print $1}')" == "215" \
    && "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test" | awk '{print $1}')" == "64" \
    && "$(awk '/^import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source")" == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test")" == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test")" == "1" ]] ||
    die "Stage-3 validation-inventory order repair authority identity surface changed"
for required_stage3_inventory_order_repair_value in \
    'public static let canonicalSHA256 = "52f2619ebcbc6e8d608042ffb107411bbcb6ac4630482dba0007436f52bb03ce"' \
    'mergeRevision: "372248bd2e2d282bbb2b0fe39273211aee0da43a"' \
    'workflowRunID: 31_674_969_104' \
    'workflowRunNumber: 87' \
    'checkSuiteID: 85_926_465_475' \
    'rootTestCount: 46' \
    'stage3LauncherInvocationCount: 1' \
    'stage3BuildCount: 0' \
    'stage3TestStartedCount: 0' \
    'stage3ReceiptCount: 0' \
    'packageInventoryMutationObserved: false' \
    'failureWasBeforeStage3Build: true' \
    'stage3MechanicsFailureEstablished: false' \
    'expectedRootTestCount: 47' \
    'inventoryExpectedOrderReplacementCount: 1' \
    'retryOrRerunAuthorized: false' \
    'oneDistinctDirectMainSuccessorAuthorized: true' \
    'stage3ExecutionEstablished: false' \
    'stage4Authorized: false' \
    'terminalOutcomeObservationRequired: true'; do
    grep -Fq -- "$required_stage3_inventory_order_repair_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source" ||
        die "Stage-3 validation-inventory order repair authority lost: $required_stage3_inventory_order_repair_value"
done
for required_stage3_inventory_order_repair_test_value in \
    'func testFrozenV1CanonicalCodableRecursiveMutationAndRepairCeiling() throws {' \
    'XCTAssertGreaterThan(mutations, 45)' \
    'XCTAssertFalse(authority.inventory.packageInventoryMutationObserved)' \
    'XCTAssertFalse(authority.inventory.stage3MechanicsFailureEstablished)' \
    'XCTAssertFalse(authority.repair.retryOrRerunAuthorized)' \
    'XCTAssertFalse(authority.ceiling.stage3ExecutionEstablished)' \
    'XCTAssertTrue(authority.ceiling.terminalOutcomeObservationRequired)'; do
    grep -Fq -- "$required_stage3_inventory_order_repair_test_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_test" ||
        die "Stage-3 validation-inventory order repair authority test lost: $required_stage3_inventory_order_repair_test_value"
done
for forbidden_stage3_inventory_order_repair_capability in \
    'import CoreGraphics' 'import Metal' 'import MLX' 'import MLXNN' \
    'import MLXOptimizers' 'FileManager' 'FileHandle' 'URLSession' 'Process('; do
    ! grep -Fq -- "$forbidden_stage3_inventory_order_repair_capability" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_authority_source" ||
        die "Stage-3 validation-inventory order repair authority gained capability: $forbidden_stage3_inventory_order_repair_capability"
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservation.swift' \
    '100644' 'fd32a489ea3cae08cad3e6e462434f3f97df8cab' '10894' \
    '737c91e750f7f3520a634b737c17b672d47a290e726dcce7179c5518b7745d22'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests.swift' \
    '100644' 'fae2cc34a1f2d53dd8610e6bb93a379509742f6f' '3768' \
    '3c04ec65c760d4caa92dce775bf96b7673075db3e459285806095ff8543a2807'
[[ "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source" | awk '{print $1}')" == "235" \
    && "$(wc -l < "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test" | awk '{print $1}')" == "75" \
    && "$(awk '/^import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source")" == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test")" == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_test")" == "1" ]] ||
    die "Stage-3 execution observation identity surface changed"
for required_stage3_execution_observation_value in \
    'public static let canonicalSHA256 = "9f0d4c974eca94edc6ca9953cd9cd27fef2e53ad6850addcbfc0a80512530d8d"' \
    'mergeRevision: "ea96f7a503adfb5e814f81f2180318f8d1f06abd"' \
    'workflowRunID: 31_679_144_989' \
    'workflowRunNumber: 89' \
    'checkSuiteID: 85_937_734_896' \
    'exactHeadPushRunCount: 1' \
    'artifactCount: 0' \
    'focusedRootTestCount: 47' \
    'metalTestCount: 44' \
    'receiptPayloadByteCount: 2_842' \
    'receiptPayloadSHA256: "f14c68a835ff6779a4b3a3fe5ab0f66e464d2070d63538c32f19842045f7826e"' \
    'typedInMemorySnapshotExportRestoreEstablished: true' \
    'uninterruptedAndFreshRestoredStep2ExactEqualityEstablished: true' \
    'explicitRNGKeyCounterAndNextCursorBoundaryEstablished: true' \
    'expectedRootTestCount: 48' \
    'reviewedCheckoutDepth: 1' \
    'stage3LauncherInvocationCount: 0' \
    'stage3LauncherSourcePreserved: true' \
    'successfulAttemptConsumed: true' \
    'retryOrRerunAuthorized: false' \
    'stage4Authorized: false' \
    'exactMainRetirementClosureRequired: true'; do
    grep -Fq -- "$required_stage3_execution_observation_value" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source" ||
        die "Stage-3 execution observation lost: $required_stage3_execution_observation_value"
done
for forbidden_stage3_execution_observation_capability in \
    'import CoreGraphics' 'import Metal' 'import MLX' 'import MLXNN' \
    'import MLXOptimizers' 'FileManager' 'FileHandle' 'URLSession' 'Process('; do
    ! grep -Fq -- "$forbidden_stage3_execution_observation_capability" \
        "$stage3_tiny_cpu_explicit_rng_cursor_resume_execution_observation_source" ||
        die "Stage-3 execution observation gained capability: $forbidden_stage3_execution_observation_capability"
done

assert_metal_current_decoder_assertion_arc_identity \
    'Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthority.swift' \
    '100644' 'c9a1a23e65454fd7fd8f46e118c04060d0a78123' '36866' \
    '6b38af1926584bc47d20971299214e737bbda931395b08cef6bb5bf64b439ba8'
assert_metal_current_decoder_assertion_arc_identity \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests.swift' \
    '100644' 'c9eeea7514f28350ed95ab42e77de6cb865a6347' '15413' \
    '1a768e399edc92eacfbf32142fc9bf4faa897805697dc1b53c4f4441bbaf4406'
[[ "$(wc -l < \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source" | \
        awk '{print $1}')" == "775" \
    && "$(wc -l < \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test" | \
        awk '{print $1}')" == "379" \
    && "$(awk '/^import / { print }' \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source")" \
        == 'import Foundation' \
    && "$(awk '/^import / || /^@testable import / { print }' \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test")" \
        == $'import CoreFoundation\nimport Foundation\n@testable import PrimeCore\nimport XCTest' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()' \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_test")" == "1" ]] ||
    die "Stage-4 tiny durable multileaf authority parse or sole-test surface changed"
for required_stage4_tiny_durable_multileaf_authority_value in \
    'public static let canonicalSHA256 =' \
    '"0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031"' \
    'stage3RetirementMergeRevision:' \
    '"5cadcfb915356984f1d6496d7a255725937f9007"' \
    'stage3RetirementTree:' \
    '"7fa0f3c9cdcbbd68386a55414e9e08425bccbc7a"' \
    'stage3LauncherGitBlob:' \
    '"f912e776309866eaec5c6a162892c096b9bc2488"' \
    'stage3LauncherSHA256:' \
    '"1a184b52e0055128afbb6a9ccc22c46e8a929f30b3e0f43752f6a43e48eae6bd"' \
    'stageID: "tiny_durable_multileaf_commit_fault_injection_v1"' \
    'nextStageID:' \
    '"tiny_repeated_metal_trajectory_determinism_assay_v1"' \
    'weightsRoleSemantics:' \
    '"bounded_real_tiny_mechanics_safetensors_fixture_not_native300m_exact_v2_leaf"' \
    'native300MPublicV2CodecUseAuthorized: false' \
    'publicV2CodecMutationAuthorized: false' \
    'native300MExactV2LeafCompositionDeferred: true' \
    'finalCommitManifestPublishedLast: true' \
    'finalCommitManifestIsExclusiveCommitPoint: true' \
    'partialPrecommitLeavesAreAuthoritative: false' \
    'partialPrecommitLeavesMustBeQuarantined: true' \
    'loadRequiresExternallySuppliedExactCommitBinding: true' \
    'loadRequiresExactInventoryAndEveryLeafBinding: true' \
    'discoverAndTrustLoadAuthorized: false' \
    'inPlaceMutationOrReplacementAuthorized: false' \
    'failedWritePartialStateCanBePromoted: false' \
    'injectedFailureCount: 7' \
    'publishedFileCount: 4' \
    'roundTripRestoresExactStage3Snapshot: true' \
    'directXCTestCount: 1' \
    'failureCount: 0' \
    'skipCount: 0' \
    '".github/scripts/prime-ci-active-root-quarantine.sh"' \
    '".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh"' \
    '".github/workflows/prime-active-root-quarantine.yml"' \
    '"Package.resolved"' \
    '"Package.swift"' \
    '"Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"' \
    '"Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift"' \
    '"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"' \
    '"Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift"' \
    'rootPackageManifestMutationAuthorized: true' \
    'rootPackageResolvedMutationAuthorized: true' \
    'trainingValidationManifestMutationAuthorized: false' \
    'trainingValidationLockMutationAuthorized: false' \
    'checkpointTargetDependencyForTrainingAuthorized: true' \
    'genericCodecMustBeInCheckpointTarget: true' \
    'trainingSourceMayOnlyBridgeStage3Snapshot: true' \
    'stage3LauncherMutationAuthorized: false' \
    'existingMetalLauncherMutationAuthorized: false' \
    'secureFetchMutationAuthorized: false' \
    'workflowTimeoutChangeAuthorized: false' \
    'reviewedCheckoutDepth: 2' \
    'newHostedLauncherRequired: true' \
    'authorityRootTestCount: 49' \
    'implementationFocusedWholeTestCount: 55' \
    'preStage4TotalTestCount: 101' \
    'totalTestCount: 102' \
    'authorityOnlyNoExecutionEvidence: true' \
    'mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: true' \
    'oneExactMainExecutionOpportunityAuthorized: true' \
    'tinyEphemeralArtifactRootAuthorizedForMechanics: true' \
    'stage3SnapshotLeafSerializationAuthorizedForMechanics: true' \
    'additionalExecutionOrRerunAuthorized: false' \
    'retainedArtifactAuthorized: false' \
    'artifactUploadAuthorized: false' \
    'checkpointAdmissionGranted: false' \
    'publicV2CodecWideningAuthorized: false' \
    'metalDeterminismEstablished: false' \
    'stage5Authorized: false' \
    'native300MAllocationAuthorized: false' \
    'native300MTrainingAuthorized: false' \
    'generalTrainingResumeEstablished: false' \
    'modelQualityEstablished: false' \
    'candidateAdmissionGranted: false' \
    'trialAuthorized: false' \
    'canaryAuthorized: false' \
    'productUseAuthorized: false' \
    'publicationAuthorized: false' \
    'AUTHORIZED_stage4_tiny_ephemeral_durable_four_leaf_commit_fault_injection_mechanics_and_one_exact_main_witness_after_green_authority_closure_no_retention_admission_metal_native300m_rerun_or_downstream_authority'; do
    grep -Fq -- "$required_stage4_tiny_durable_multileaf_authority_value" \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source" ||
        die "Stage-4 tiny durable multileaf authority lost: $required_stage4_tiny_durable_multileaf_authority_value"
done
for forbidden_stage4_tiny_durable_multileaf_authority_capability in \
    'import CoreGraphics' 'import Metal' 'import MLX' 'import MLXNN' \
    'import MLXOptimizers' 'FileManager' 'FileHandle' 'URLSession' 'Process(' \
    'posix_spawn' 'execve('; do
    ! grep -Fq -- "$forbidden_stage4_tiny_durable_multileaf_authority_capability" \
        "$stage4_tiny_durable_multileaf_commit_fault_injection_authority_source" ||
        die "Stage-4 tiny durable multileaf authority gained capability: $forbidden_stage4_tiny_durable_multileaf_authority_capability"
done

[[ "$(awk '/^import / { print }' "$decoder_authority_test")" \
        == $'import CryptoKit\nimport Foundation\nimport XCTest\nimport PrimeCore' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_authority_test")" == "11" \
    && "$(grep -Fc -- \
        'func testMetalRepairAuthorityIsAppendOnlyAndSourceExact() throws {' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- 'plan.repairedDecoderSourceGitBlob' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- 'plan.repairedDecoderSourceByteCount' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- 'plan.repairedDecoderSourceSHA256' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'currentDecoderSurface.currentDecoderSuccessorExpectedGitBlob' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'currentDecoderSurface.currentDecoderSuccessorExpectedByteCount' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- \
        'currentDecoderSurface.currentDecoderSuccessorExpectedSHA256' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- 'gitBlobOID(' "$decoder_authority_test")" == "2" \
    && "$(grep -Fc -- 'Insecure.SHA1.hash(data: framed)' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- '835a4826549e1f28ec27e3533f746218beb3bdf2' \
        "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- '39_050' "$decoder_authority_test")" == "1" \
    && "$(grep -Fc -- \
        '058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b' \
        "$decoder_authority_test")" == "1" ]] ||
    die "Metal current-decoder assertion repair exceeded its exact existing-test boundary"

[[ "$(awk '/^import / { print }' "$decoder_training_source")" \
    == $'import Foundation\nimport PrimeCore\nimport PrimeNativeDecoder\nimport MLX\nimport MLXNN\nimport MLXOptimizers' ]] ||
    die "PrimeNativeDecoderTraining import allowlist changed"
[[ "$(grep -Ec -- '^public (struct|final class) ' \
        "$decoder_training_source")" == "9" \
    && "$(grep -Fxc -- \
        'enum PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1:' \
        "$decoder_training_source")" == "1" \
    && "$(grep -Fxc -- \
        'struct PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1:' \
        "$decoder_training_source")" == "1" \
    && "$(grep -Fxc -- \
        'struct PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1:' \
        "$decoder_training_source")" == "1" ]] ||
    die "PrimeNativeDecoderTraining public or internal type surface changed"
for required_tiny_cpu_public_type in \
    'public final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1 {' \
    'public struct PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1:' \
    'public struct PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1:' \
    'public struct PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1:' \
    'public struct PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1:' \
    'public struct PrimeNativeDecoderTinyCPUExplicitRNGRecordV1:' \
    'public struct PrimeNativeDecoderTinyCPUDataCursorV1:' \
    'public struct PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1 {' \
    'public final class PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1 {'; do
    [[ "$(grep -Fxc -- "$required_tiny_cpu_public_type" \
        "$decoder_training_source")" == "1" ]] ||
        die "PrimeNativeDecoderTraining public surface lost: $required_tiny_cpu_public_type"
done
[[ "$(grep -Fc -- 'package func trainingLogitsNoCache(' \
        "$decoder_source")" == "1" \
    && "$(grep -Fc -- 'trainingLogitsNoCache(' \
        "$decoder_source")" == "1" \
    && "$(grep -Fc -- 'trainingLogitsNoCache(' \
        "$decoder_training_source")" == "1" \
    && "$(grep -Fc -- 'rankTwoTokenIDs.ndim == 2' \
        "$decoder_source")" == "1" \
    && "$(grep -Fc -- 'rankTwoTokenIDs.dtype == .int32' \
        "$decoder_source")" == "1" \
    && "$(grep -Fc -- 'return self(rankTwoTokenIDs, positionOffset: 0)' \
        "$decoder_source")" == "1" \
    && "$(grep -Fc -- 'public func trainingLogitsNoCache' \
        "$decoder_source")" == "0" ]] ||
    die "PrimeNativeDecoder package-scoped no-cache training seam changed"
for required_tiny_cpu_training_value in \
    'public let vocabularySize = 32' \
    'public let modelWidth = 16' \
    'public let layerCount = 2' \
    'public let queryHeadCount = 4' \
    'public let keyValueHeadCount = 2' \
    'public let headWidth = 4' \
    'public let intermediateWidth = 32' \
    'public let maximumSequenceLength = 16' \
    'public let maximumBatchSize = 2' \
    'public let paddingTokenID = 0' \
    'public let initializationSeed: UInt64 = 7' \
    'public let uniqueParameterCount: Int64 = 5_200' \
    'public let trainableParameterPathCount = 20' \
    'public let maximumGlobalStep = 2' \
    'public let learningRateFloat32BitPattern = Float(1e-4).bitPattern' \
    'public let beta1Float32BitPattern = Float(0.9).bitPattern' \
    'public let beta2Float32BitPattern = Float(0.999).bitPattern' \
    'public let epsilonFloat32BitPattern = Float(1e-8).bitPattern' \
    'public let weightDecayFloat32BitPattern = Float(0.01).bitPattern' \
    'public let maximumGradientNormFloat32BitPattern = Float(1).bitPattern' \
    'public let gradientNormEpsilonFloat32BitPattern = Float(1e-6).bitPattern' \
    'guard (2 ... sequenceLength).contains(validTokenCount) else {' \
    'for column in validTokenCount ..< sequenceLength {' \
    'guard tokenID == configuration.paddingTokenID else {' \
    'guard !completionMask[row][0] else {' \
    '(1 ..< validTokenCount).first(where: {' \
    'selectedTargetCount += validTokenCount - firstSelected' \
    'try Device.withDefaultDevice(.cpu) {' \
    'let optimizer = AdamW(' \
    'let lossAndGradient = valueAndGrad(model: decoder) {' \
    'let logits = model.trainingLogitsNoCache(tokenIDs)' \
    'let shiftedTargets = tokenIDs[0..., 1 ..< sequenceLength]' \
    'let shiftedMask = completionMask[0..., 1 ..< sequenceLength]' \
    'labelSmoothing: 0,' \
    'reduction: .none)' \
    'let loss = sum(perTargetLoss * shiftedMask)' \
    '/ Float(selectedTargetCount)' \
    'if rawNormValue < Self.maximumGradientNorm {' \
    'private static let maximumGradientNorm = Float(1)' \
    'private static let gradientNormEpsilon = Float(1e-6)' \
    '/ (globalNorm + gradientNormEpsilon)' \
    'return shapes.sorted { utf8Less($0.0, $1.0) }' \
    'for path in expectedParameterPaths {' \
    'total = total + sum(square(gradient.asType(.float32)))' \
    'return sqrt(total)' \
    'lhs.utf8.lexicographicallyPrecedes(rhs.utf8)' \
    'optimizer.update(' \
    'optimizerState = try optimizer.parameters()' \
    'globalStep = completedStep' \
    'let before = try validationSnapshot()' \
    'guard before == after,' \
    '.maximumGlobalStepReached('; do
    grep -Fq -- "$required_tiny_cpu_training_value" \
        "$decoder_training_source" ||
        die "PrimeNativeDecoderTraining mechanics lost: $required_tiny_cpu_training_value"
done
readonly tiny_cpu_third_step_guard_line="$(grep -nF -- \
    'guard globalStep < configuration.maximumGlobalStep else {' \
    "$decoder_training_source" | awk -F: '{print $1}')"
readonly tiny_cpu_train_device_line="$(grep -nF -- \
    'return try Device.withDefaultDevice(.cpu) {' \
    "$decoder_training_source" | awk -F: 'NR == 1 {print $1}')"
readonly tiny_cpu_train_graph_line="$(grep -nF -- \
    'let lossAndGradient = valueAndGrad(model: decoder) {' \
    "$decoder_training_source" | awk -F: '{print $1}')"
[[ "$tiny_cpu_third_step_guard_line" =~ ^[1-9][0-9]*$ \
    && "$tiny_cpu_train_device_line" =~ ^[1-9][0-9]*$ \
    && "$tiny_cpu_train_graph_line" =~ ^[1-9][0-9]*$ \
    && "$tiny_cpu_third_step_guard_line" -lt "$tiny_cpu_train_device_line" \
    && "$tiny_cpu_train_device_line" -lt "$tiny_cpu_train_graph_line" ]] ||
    die "PrimeNativeDecoderTraining third-step pre-device/pre-graph boundary changed"
for forbidden_tiny_cpu_training_capability in \
    'PrimeNativeDecoderCheckpoint' \
    'PrimeArtifactRoot' \
    'FileManager' \
    'FileHandle' \
    'URL(' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve(' \
    'MLXRandom.seed' \
    'Random.seed' \
    'globalState' \
    '.forward(' \
    'clipGradNorm' \
    'clipGradients' \
    '._updateInternal(' \
    'biasCorrection' \
    'import Metal' \
    'import CoreGraphics' \
    'MTLCommand' \
    'PrimeNativeGQADecoderCache' \
    'makeCache' \
    'writeNative300MByte512' \
    'loadNative300MByte512'; do
    if grep -Fq -- "$forbidden_tiny_cpu_training_capability" \
        "$decoder_training_source"; then
        die "PrimeNativeDecoderTraining gained forbidden capability: $forbidden_tiny_cpu_training_capability"
    fi
done

[[ "$(awk '/^import / || /^@testable import / { print }' \
        "$decoder_training_validation_test")" \
    == $'import CoreGraphics\nimport Metal\nimport MLX\nimport XCTest\n@testable import PrimeNativeDecoderTraining' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_training_validation_test")" == "1" \
    && "$(grep -Fc -- 'throw XCTSkip(' \
        "$decoder_training_validation_test")" == "1" \
    && "$(grep -Fc -- 'MTLCopyAllDevices()' \
        "$decoder_training_validation_test")" == "1" \
    && "$(grep -Fc -- 'MTLCreateSystemDefaultDevice()' \
        "$decoder_training_validation_test")" == "1" ]] ||
    die "PrimeNativeDecoder Stage-2 validation surface changed"
for required_tiny_cpu_validation_value in \
    'func testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed() throws {' \
    'let first = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()' \
    'let second = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()' \
    'XCTAssertFalse(first === second)' \
    'XCTAssertEqual(initialFirst, initialSecond)' \
    'try second.validationSnapshot(),' \
    'let firstStepFirst = try first.train(batch: firstBatch)' \
    'let firstStepSecond = try second.train(batch: firstBatch)' \
    'let secondStepFirst = try first.train(batch: secondBatch)' \
    'let secondStepSecond = try second.train(batch: secondBatch)' \
    'let evaluationFirst = try first.evaluate(batch: evaluationBatch)' \
    'let evaluationSecond = try second.evaluate(batch: evaluationBatch)' \
    'assertGlobalMeanLoss(' \
    '.maximumGlobalStepReached(maximum: 2, observed: 2)' \
    'tokenIDs: [[1, 0, 2, 0]]' \
    '.tokenIDOutOfRange(row: 0, column: 1, value: -1)' \
    '.validationClipScale(globalNorm: Float(1).nextDown)' \
    '.validationClipScale(globalNorm: 1)' \
    'XCTAssertEqual(configuration.maximumBatchSize, 2)' \
    'XCTAssertEqual(configuration.maximumGlobalStep, 2)'; do
    grep -Fq -- "$required_tiny_cpu_validation_value" \
        "$decoder_training_validation_test" ||
        die "PrimeNativeDecoder Stage-2 validation lost: $required_tiny_cpu_validation_value"
done
readonly tiny_cpu_metal_guard_line="$(grep -nF -- \
    'let metalDevices = MTLCopyAllDevices()' \
    "$decoder_training_validation_test" | awk -F: '{print $1}')"
readonly tiny_cpu_mlx_device_line="$(grep -nF -- \
    'try Device.withDefaultDevice(.cpu) {' \
    "$decoder_training_validation_test" | awk -F: '{print $1}')"
[[ "$tiny_cpu_metal_guard_line" =~ ^[1-9][0-9]*$ \
    && "$tiny_cpu_mlx_device_line" =~ ^[1-9][0-9]*$ \
    && "$tiny_cpu_metal_guard_line" -lt "$tiny_cpu_mlx_device_line" ]] ||
    die "Stage-2 test-only Metal capability guard no longer precedes MLX initialization"
for forbidden_tiny_cpu_validation_capability in \
    'PrimeNativeDecoderCheckpoint' \
    'PrimeArtifactRoot' \
    'FileManager' \
    'FileHandle' \
    'URLSession' \
    'Process(' \
    'posix_spawn' \
    'execve(' \
    'makeCommandQueue' \
    'MTLCommandBuffer' \
    'MTLBuffer' \
    'MTLTexture'; do
    if grep -Fq -- "$forbidden_tiny_cpu_validation_capability" \
        "$decoder_training_validation_test"; then
        die "Stage-2 validation gained forbidden capability: $forbidden_tiny_cpu_validation_capability"
    fi
done

for required_stage3_training_value in \
    'PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1' \
    'PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1' \
    'PrimeNativeDecoderTinyCPUExplicitRNGRecordV1' \
    'PrimeNativeDecoderTinyCPUDataCursorV1' \
    'PrimeNativeDecoderTinyCPUExactTensorStateV1' \
    'float32BitPatterns: [UInt32]' \
    'public static let stageID = "tiny_cpu_explicit_rng_cursor_resume_v1"' \
    'public static let randomAlgorithmID = "sha256_counter_stream_v1"' \
    'public func trainNext()' \
    'public func exportInMemoryResumeSnapshot()' \
    'func restoreInMemoryResumeSnapshot(' \
    'cursor.nextBatchOrdinal == trainer.globalStep' \
    'try decoder.update(' \
    'verify: .all' \
    'try optimizer.update(' \
    'snapshot.accumulationPhase == 0' \
    'snapshot.pendingGradientTensorCount == 0' \
    'snapshot.pendingPrefetchItemCount == 0' \
    'snapshot.kvCacheEntryCount == 0'; do
    grep -Fq -- "$required_stage3_training_value" "$decoder_training_source" ||
        die "PrimeNativeDecoderTraining Stage-3 resume boundary lost: $required_stage3_training_value"
done
[[ "$(awk '/^import / || /^@testable import / { print }' \
        "$decoder_stage3_tiny_cpu_resume_test")" \
    == $'import CoreGraphics\nimport Metal\nimport MLX\nimport MLXNN\nimport MLXOptimizers\nimport XCTest\n@testable import PrimeNativeDecoderTraining' \
    && "$(grep -Ec -- '^[[:space:]]+func test' \
        "$decoder_stage3_tiny_cpu_resume_test")" == "1" \
    && "$(grep -Fc -- \
        'func testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed() throws {' \
        "$decoder_stage3_tiny_cpu_resume_test")" == "1" \
    && "$(grep -Fc -- 'throw XCTSkip(' \
        "$decoder_stage3_tiny_cpu_resume_test")" == "1" ]] ||
    die "Stage-3 tiny CPU resume test import or single-method boundary changed"
for required_stage3_test_value in \
    'let control =' \
    'let source =' \
    'let snapshot = try source.exportInMemoryResumeSnapshot()' \
    'let sourceStep2 = try source.trainNext()' \
    'restoring: snapshot' \
    'assertRestorableStateEqual(' \
    'XCTAssertEqual(sourceStep2, controlStep2)' \
    'XCTAssertEqual(restoredStep2, controlStep2)' \
    'XCTAssertEqual(controlEvaluation2, restoredEvaluation2)' \
    'let beforeExportExactTensors = try source.exactTensorState()' \
    'XCTAssertNotEqual(' \
    'try source.exactTensorState(),' \
    'beforeExportExactTensors)' \
    'try control.exactTensorState(),' \
    'try restored.exactTensorState())' \
    'assertMalformedSnapshotsFailClosed(snapshot)' \
    'assertLifecycleRejections(snapshot)' \
    'snapshot.randomRecords.map(\.counter)' \
    '[1, 1, 0, 0]' \
    '[1, 2, 0, 0]' \
    'XCTAssertThrowsError(' \
    'try target.restoreInMemoryResumeSnapshot(snapshot)' \
    'XCTAssertEqual(' \
    'try target.validationSnapshot(),' \
    'before,'; do
    grep -Fq -- "$required_stage3_test_value" \
        "$decoder_stage3_tiny_cpu_resume_test" ||
        die "Stage-3 tiny CPU resume test lost: $required_stage3_test_value"
done
for forbidden_stage3_product_capability in \
    'PrimeArtifactRoot' 'PrimeNativeDecoderCheckpoint' 'FileManager' \
    'FileHandle' 'URLSession' 'Process(' 'posix_spawn' 'execve(' \
    'func trainNext(batch:'; do
    ! grep -Fq -- "$forbidden_stage3_product_capability" \
        "$decoder_training_source" ||
        die "Stage-3 training source gained forbidden capability: $forbidden_stage3_product_capability"
done

[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during metadata validation"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during metadata validation"

echo "OK: first-party MLX is pinned; mlx-swift-lm execution targets are disconnected while historical comparator evidence remains preserved"

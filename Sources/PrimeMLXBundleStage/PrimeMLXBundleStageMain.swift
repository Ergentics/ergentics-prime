import Foundation
import PrimeCore

@main
enum PrimeMLXBundleStageCLI {
    static func main() {
        do {
            let arguments =
                try PrimeMLXBundleStageArguments
                    .parse(
                        Array(
                            CommandLine.arguments
                                .dropFirst()
                        )
                    )
            let runtimeRole = arguments.runtimeRole
            let result =
                try PrimePinnedMLXMetallib
                    .stageExactXcodeMetallib(
                        from: arguments.sourceHost,
                        beside: arguments.destinationHost,
                        runtimeRole: runtimeRole
                    )
            print(
                "Prime MLX bundle exact stage complete: " +
                    "runtime_role=\(runtimeRole.rawValue) " +
                    "mlx_swift=" +
                    "\(result.binding.mlxSwiftVersion) " +
                    "destination_metallib_initially_absent=" +
                    "\(result.destinationMetallibInitiallyAbsent) " +
                    "xcode_donor_info_plist_sha256=" +
                    PrimePinnedMLXMetallib
                    .expectedXcodeDonorInfoPlistSHA256 +
                    " runtime_info_plist_sha256=" +
                    PrimePinnedMLXMetallib
                    .expectedInfoPlistSHA256 +
                    " metallib_sha256=" +
                    result.binding.artifact.sha256
            )
        } catch {
            FileHandle.standardError.write(
                Data(
                    "Prime MLX bundle staging failed: \(error)\n"
                        .utf8
                )
            )
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

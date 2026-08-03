import Foundation
import PrimeCore

@main
enum PrimeMLXRuntimeScaffoldCLI {
    static func main() {
        do {
            let arguments =
                try PrimeMLXRuntimeScaffoldArguments
                    .parse(
                        Array(
                            CommandLine.arguments
                                .dropFirst()
                        )
                    )
            let runtimeRole = arguments.runtimeRole
            let result =
                try PrimePinnedMLXMetallib
                    .scaffoldCanonicalRuntimeBundle(
                        from: arguments.sourceRoot,
                        beside: arguments.destinationHost,
                        runtimeRole: runtimeRole
                    )
            print(
                "Prime MLX runtime scaffold complete: " +
                    "runtime_role=\(runtimeRole.rawValue) " +
                    "mlx_swift=" +
                    "\(PrimePinnedMLXMetallib.mlxSwiftVersion) " +
                    "destination_bundle_initially_absent=" +
                    "\(result.destinationBundleInitiallyAbsent) " +
                    "runtime_info_plist_sha256=" +
                    result.infoPlist.sha256 +
                    " metallib_absent=true"
            )
        } catch {
            FileHandle.standardError.write(
                Data(
                    "Prime MLX runtime scaffold failed: \(error)\n"
                        .utf8
                )
            )
            Foundation.exit(EXIT_FAILURE)
        }
    }
}

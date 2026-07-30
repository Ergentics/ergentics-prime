import Foundation
import Testing
@testable import PrimeCore

@Suite
struct PrimeNativeNeuralGateContractArgumentsTests {
    @Test
    func probeArgumentsAdmitOnlyDisjointPrimeArtifactRoots()
        throws
    {
        let prime =
            "/private/tmp/prime-neural-gate-arguments"
        let arguments =
            try PrimeNativeNeuralGateContractArguments
            .parse([
                "probe",
                "--generation-root",
                prime + "/artifacts/generation",
                "--corpus-replay-root",
                prime + "/artifacts/corpus",
                "--prime-root",
                prime,
                "--artifact-root",
                prime + "/artifacts/gate",
            ])

        #expect(
            arguments.generationRoot.path
                == prime + "/artifacts/generation"
        )
        #expect(
            arguments.corpusReplayRoot.path
                == prime + "/artifacts/corpus"
        )
        #expect(arguments.primeRoot.path == prime)
        #expect(
            arguments.artifactRoot.path
                == prime + "/artifacts/gate"
        )
    }

    @Test
    func probeArgumentsRejectOverlapAndUnknownKnobs() {
        let prime =
            "/private/tmp/prime-neural-gate-arguments"
        #expect(throws: Error.self) {
            _ =
                try PrimeNativeNeuralGateContractArguments
                .parse([
                    "probe",
                    "--generation-root",
                    prime + "/artifacts/shared",
                    "--corpus-replay-root",
                    prime + "/artifacts/corpus",
                    "--prime-root",
                    prime,
                    "--artifact-root",
                    prime + "/artifacts/shared/output",
                ])
        }
        #expect(throws: Error.self) {
            _ =
                try PrimeNativeNeuralGateContractArguments
                .parse([
                    "probe",
                    "--generation-root",
                    prime + "/artifacts/generation",
                    "--corpus-replay-root",
                    prime + "/artifacts/corpus",
                    "--prime-root",
                    prime,
                    "--artifact-root",
                    prime + "/artifacts/gate",
                    "--seed",
                    "1618",
                ])
        }
    }

    @Test
    func verifierArgumentsRequireOnlyPrimeAndArtifactRoots()
        throws
    {
        let prime =
            "/private/tmp/prime-neural-gate-verifier"
        let arguments =
            try PrimeNativeNeuralGateContractVerifierArguments
            .parse([
                "verifier",
                "--artifact-root",
                prime + "/artifacts/gate",
                "--prime-root",
                prime,
            ])
        #expect(arguments.primeRoot.path == prime)
        #expect(
            arguments.artifactRoot.path
                == prime + "/artifacts/gate"
        )

        #expect(throws: Error.self) {
            _ =
                try PrimeNativeNeuralGateContractVerifierArguments
                .parse([
                    "verifier",
                    "--artifact-root",
                    prime + "/artifacts/gate",
                ])
        }
    }
}

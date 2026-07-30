import Foundation
import XCTest

final class PrimeNative3BMetalContinuationSourceContractTests:
    XCTestCase
{
    func testMaintainedExact3BLlamaMappingAndGPUExecution()
        throws
    {
        let source = try probeSource()
        for requiredImport in [
            "import MLX\n",
            "import MLXLLM\n",
            "import MLXNN\n",
            "import MLXOptimizers\n",
            "import PrimeCore\n",
        ] {
            XCTAssertTrue(
                source.contains(requiredImport),
                "missing maintained dependency \(requiredImport)"
            )
        }
        XCTAssertTrue(
            source.contains(
                "PrimeNativeProfiles"
            )
                && source.contains(
                    ".exact3B"
                )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeNativeArcContinuityPlan"
            )
                && source.contains(
                    ".frozenV1"
                )
        )

        let model = try function(
            containing: "LlamaConfiguration(",
            in: source
        )
        try assertOrdered(
            [
                "MLXRandom.seed(",
                "LlamaConfiguration(",
                "hiddenSize: profile.modelDimension",
                "hiddenLayers: profile.layerCount",
                "intermediateSize: profile.feedForwardDimension",
                "attentionHeads: profile.attentionHeads",
                "headDimensions: profile.headDimension",
                "rmsNormEps: 1e-5",
                "vocabularySize: profile.vocabularySize",
                "kvHeads: profile.keyValueHeads",
                "maxPositionEmbeddings:",
                "profile.maximumSequenceLength",
                "ropeTheta: Float(profile.ropeBase)",
                "tieWordEmbeddings: true",
                "attentionBias: false",
                "mlpBias: false",
                "LlamaModel(configuration)",
                "eval(model)",
            ],
            in: model
        )

        let gpuExecution = try function(
            containing:
                "Device.withDefaultDevice(.gpu)",
            in: source
        )
        XCTAssertTrue(
            gpuExecution.contains(
                "Device.withDefaultDevice(.gpu)"
            )
        )
        XCTAssertFalse(
            gpuExecution.contains(
                "Device.withDefaultDevice(.cpu)"
            )
        )
    }

    func testFrozenAdamWStepAndPublicTypedRestore()
        throws
    {
        let source = try probeSource()
        let optimizer = try function(
            containingAll: [
                "PrimeTypedOptimizerConfiguration",
                ".frozenAdamW",
                "AdamW(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "PrimeTypedOptimizerConfiguration",
                ".frozenAdamW",
                "AdamW(",
                "learningRate:",
                "betas:",
                "eps:",
                "weightDecay:",
            ],
            in: optimizer
        )

        let step = try function(
            containing: "clipGradNorm(",
            in: source
        )
        try assertOrdered(
            [
                "clipGradNorm(",
                "maxNorm: 1",
                "optimizer.update(",
                "eval(",
            ],
            in: step
        )

        let restore = try function(
            containingAll: [
                "model.update(",
                "optimizer.update(",
                "matching:",
            ],
            in: source
        )
        try assertOrdered(
            [
                "model.update(",
                "parameters:",
                "verify: .all",
                "optimizer.update(",
                "parameters:",
                "matching:",
                "optimizer.parameters()",
            ],
            in: restore
        )
        let restorer = try function(
            containingAll: [
                "poisonModelCatalog(",
                "consume poisonOptimizer",
                "Memory.clearCache()",
                "restoreCheckpoint(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "poisonModelCatalog(",
                "consume poisonOptimizer",
                "Memory.clearCache()",
                "restoreCheckpoint(",
            ],
            in: restorer
        )
        let restoredState = try function(
            containingAll: [
                "restoredStateWitness(",
                "PrimeNative3BContinuationRestoredStateWitness(",
                "optimizer.parameters()",
                "fixedLogitsCatalog(",
            ],
            in: source
        )
        for copiedWriterMeasurement in [
            "source.lossBitPattern",
            "source.rawGradientNormBitPattern",
            "source.clippedGradientNormBitPattern",
            "source.clippedGradient",
        ] {
            XCTAssertFalse(
                restoredState.contains(
                    copiedWriterMeasurement
                )
            )
        }
        XCTAssertTrue(
            source.contains("AdamOptimizerState")
        )
        for forbidden in [
            ".innerState(",
            "_updateInternal",
            "Mirror(",
            "dummy optimizer",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden private optimizer route \(forbidden)"
            )
        }
    }

    func testFreshRoleOrchestrationIsSelfExecAndBounded()
        throws
    {
        let source = try probeSource()
        for role in [
            "case control",
            "case writer",
            "case restorer",
        ] {
            XCTAssertTrue(
                source.contains(role),
                "missing fresh worker role \(role)"
            )
        }

        let launch = try function(
            containing: "let process = Process()",
            in: source
        )
        try assertOrdered(
            [
                "let process = Process()",
                "process.executableURL = executableURL",
                "\"--internal-role\"",
                "role.rawValue",
                "\"--internal-worker-capability-sha256\"",
                "let workerEnvironment = [String: String]()",
                "PrimeMLXRuntimeEnvironmentPolicy",
                ".validate(",
                "process.environment = workerEnvironment",
                "let supervisorInput = Pipe()",
                "process.standardInput = supervisorInput",
                "BoundedPipeCapture(",
                "process.run()",
                "defer {",
                "terminateAndReapLaunchedChild(",
                "supervisorInput.fileHandleForWriting.write(",
                "supervisorInput.fileHandleForWriting.close()",
                "PrimeProcessTermination",
                "process.waitUntilExit()",
            ],
            in: launch
        )

        let parent = try function(
            containingAll: [
                "role: .control",
                "role: .writer",
                "role: .restorer",
            ],
            in: source
        )
        try assertOrdered(
            [
                "runChild(",
                "role: .control",
                "runChild(",
                "role: .writer",
                "runChild(",
                "role: .restorer",
            ],
            in: parent
        )
        XCTAssertTrue(
            parent.contains(
                "supervisorObservation("
            )
                && parent.contains(
                    "supervisorProcesses:"
                )
        )

        let supervisorEvidence = try function(
            containingAll: [
                "supervisorObservation(",
                "worker.processIdentifier",
                "exit.processIdentifier",
                "PrimeNative3BSupervisorProcessObservation(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "worker.role == expectedRole",
                "worker.processIdentifier",
                "exit.processIdentifier",
                "PrimeNative3BSupervisorProcessObservation(",
            ],
            in: supervisorEvidence
        )

        for requiredBoundary in [
            "verifyInheritedSupervisorCapability(",
            "verifySameExecutableSupervisorParent(",
            "verifySupervisorAuthorityLeaseHeld(",
            "PrimeExclusiveProcessLease.acquire(",
            "PrimeMetalDeviceLease.acquire(",
            "runningExecutableURL()",
        ] {
            XCTAssertTrue(
                source.contains(requiredBoundary),
                "missing process boundary \(requiredBoundary)"
            )
        }
    }

    func testLoadedMachOVnodeBindsParentAndEveryWorker()
        throws
    {
        let source = try probeSource()
        let runningExecutable = try function(
            containingAll: [
                "runningExecutableData()",
                "PrimeNative3BLoadedExecutableVnode",
                ".observeCurrentProcess()",
                "expectedLoadedExecutable: loaded",
            ],
            in: source
        )
        try assertOrdered(
            [
                "PrimeNative3BLoadedExecutableVnode",
                ".observeCurrentProcess()",
                "stableRegularFileData(",
                "expectedLoadedExecutable: loaded",
            ],
            in: runningExecutable
        )

        let childContext = try function(
            containingAll: [
                "let verifiedExecutable",
                "root.verify(executable)",
                "PrimeNative3BLoadedExecutableVnode",
                ".requireMatches(verifiedExecutable)",
            ],
            in: source
        )
        try assertOrdered(
            [
                "root.verify(executable)",
                "PrimeNative3BLoadedExecutableVnode",
                ".observeCurrentProcess()",
                ".requireMatches(verifiedExecutable)",
            ],
            in: childContext
        )

        let stagedPublication = try function(
            containingAll: [
                "publishStagedExecutable(",
                "publishGeneratedFile(",
                "Darwin.write(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "stagedExecutableMaximumBytes",
                "publishGeneratedFile(",
                "maximumByteCount:",
                "stagedExecutableMaximumBytes",
                "Darwin.write(",
            ],
            in: stagedPublication
        )

        let workerPublication = try function(
            containingAll: [
                "record.executable",
                "PrimeNative3BLoadedExecutableVnode",
                "publishCanonical(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "root.verify(record.executable)",
                "PrimeNative3BLoadedExecutableVnode",
                ".observeCurrentProcess()",
                ".requireMatches(verifiedExecutable)",
                "publishCanonical(",
            ],
            in: workerPublication
        )

        let finalInputCheck = try function(
            containingAll: [
                "parentExecutableSHA256",
                "verifyExecutableIdentity(",
                "verifyDependency(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "verifyExecutableIdentity(",
                "parentExecutableSHA256",
                "verifyDependency(",
            ],
            in: finalInputCheck
        )
    }

    func testDedicatedRuntimeRoleIsUsedAtEveryRuntimeGate()
        throws
    {
        let source = try probeSource()
        let capture = try function(
            containing: ".captureSibling(",
            in: source
        )
        XCTAssertTrue(
            capture.contains(
                ".native3BMetalContinuationProbe"
            )
        )

        let currentReverification = try function(
            containing: ".reverifySibling(",
            in: source
        )
        XCTAssertTrue(
            currentReverification.contains(
                ".native3BMetalContinuationProbe"
            )
        )
        let stagedReverification = try function(
            containing:
                ".reverifyStagedRuntimeImage(",
            in: source
        )
        XCTAssertTrue(
            stagedReverification.contains(
                ".native3BMetalContinuationProbe"
            )
        )
        XCTAssertTrue(
            privateFunctions(in: source)
                .contains(where: {
                    $0.contains(
                        "PrimeMLXRuntimeImageLayout"
                    )
                        && $0.contains(
                            ".native3BMetalContinuationProbe"
                        )
                })
        )
        for wrongRole in [
            "runtimeRole: .calibration",
            "runtimeRole:\n                .calibration",
            "runtimeRole: .typedOptimizerRestoreProbe",
            "runtimeRole:\n                .typedOptimizerRestoreProbe",
        ] {
            XCTAssertFalse(
                source.contains(wrongRole),
                "wrong runtime evidence role \(wrongRole)"
            )
        }
    }

    func testCheckpointUsesDescriptorPublicationAndVerifiedMaterializedLoad()
        throws
    {
        let source = try probeSource()
        let save = try function(
            containingAll: [
                "publishGeneratedFile(",
                "save(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "publishGeneratedFile(",
                "save(",
                "fileDescriptor:",
                "maximumBytes:",
            ],
            in: save
        )
        XCTAssertFalse(
            save.contains("Data(contentsOf:")
        )

        let load = try function(
            containingAll: [
                "withVerifiedArtifactDescriptor(",
                "loadArraysAndMetadata(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "binding.byteCount",
                "checkpointComponentMaximumByteCount",
                "withVerifiedArtifactDescriptor(",
                "loadArraysAndMetadata(",
                "fileDescriptor:",
                "stream: .cpu",
                "materialize:",
                "eval(",
            ],
            in: load
        )
        XCTAssertFalse(
            load.contains("stream: .gpu"),
            "descriptor-backed MLX Load has no Metal implementation"
        )
        XCTAssertTrue(
            load.contains(
                "continuation still execute under the GPU default device"
            )
        )
        XCTAssertFalse(
            load.contains("Data(contentsOf:")
        )

        for checkpointPath in [
            "model-after-step-1.v1.safetensors",
            "adam-first-moment-after-step-1.v1.safetensors",
            "adam-second-moment-after-step-1.v1.safetensors",
        ] {
            XCTAssertTrue(
                source.contains(checkpointPath),
                "missing checkpoint component \(checkpointPath)"
            )
        }

        let writer = try function(
            containingAll: [
                "let checkpointManifest =",
                "let writerRecord =",
            ],
            in: source
        )
        try assertOrdered(
            [
                "let checkpointManifest =",
                "let writerRecord =",
            ],
            in: writer
        )
    }

    func testExactComparisonChainPrecedesReceiptPublication()
        throws
    {
        let source = try probeSource()
        let parent = try function(
            containingAll: [
                "preSaveComparison",
                "restoredAtNComparison",
                "continuedAtNPlus1Comparison",
                "PrimeNative3BMetalContinuationReceipt(",
            ],
            in: source
        )
        try assertOrdered(
            [
                "preSaveComparison",
                "restoredAtNComparison",
                "continuedAtNPlus1Comparison",
                "PrimeNative3BMetalContinuationReceipt(",
                "try receipt.validate(",
                "publishCanonical(",
            ],
            in: parent
        )
        XCTAssertTrue(
            source.contains(
                "PrimeNative3BContinuationReconciler"
            )
        )
        for forbidden in [
            "allClose",
            "isClose",
            "atol",
            "rtol",
            "tolerance",
            "decisionParity",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "tolerance cannot promote exact continuation: \(forbidden)"
            )
        }
    }

    func testTrainingInputsFailClosedOnEmbeddingRowCollisions()
        throws
    {
        let source = try probeSource()
        let inputs = try function(
            containingAll: [
                "private func workerInputs(",
                ".collisionFreeTrainingTokens(",
                "Set(tokens).count",
                "training input contains repeated token IDs",
            ],
            in: source
        )
        XCTAssertTrue(
            inputs.contains(
                "seeds.trainingSchedule.value"
            )
        )
        XCTAssertTrue(
            inputs.contains(
                ".fixedEvaluationSequenceLength"
            )
        )
        XCTAssertFalse(
            inputs.contains("MLXRandom.randInt")
        )
        XCTAssertTrue(
            source.contains(
                "private func deterministicRandomInputs("
            )
        )
    }

    func testNoExternalModelOrScientificExecutionRoute()
        throws
    {
        let source = try probeSource()
        for forbidden in [
            "import NeuralKit",
            "NeuralKit.",
            "PrimeAskBrain",
            "import Tokenizers",
            "AutoTokenizer",
            "loadTokenizer(",
            "PrimeNativeByteTokenizer",
            "ErgenticsPrimeNativeTextCorpus",
            "ModelContainer",
            "HubApi",
            "HubClient",
            "fromPretrained",
            "loadModel(",
            "meta-llama",
            "Llama-3",
            "python",
            "/bin/sh",
            "/bin/zsh",
            "import Metal",
            "MTLDevice",
            "MTLCommand",
            "MTLLibrary",
            "makeLibrary(",
            "makeFunction(",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden external or custom route \(forbidden)"
            )
        }
    }

    private func probeSource() throws -> String {
        let tests = URL(
            fileURLWithPath: #filePath
        ).deletingLastPathComponent()
        let root = tests
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf:
                root.appendingPathComponent(
                    "Sources/" +
                        "PrimeNative3BMetalContinuationProbe/" +
                        "PrimeNative3BMetalContinuationProbeMain.swift"
                ),
            encoding: .utf8
        )
    }

    private func function(
        containing anchor: String,
        in source: String
    ) throws -> Substring {
        try function(
            containingAll: [anchor],
            in: source
        )
    }

    private func function(
        containingAll anchors: [String],
        in source: String
    ) throws -> Substring {
        let functions = privateFunctions(in: source)
        return try XCTUnwrap(
            functions.first(where: { function in
                anchors.allSatisfy {
                    function.contains($0)
                }
            }),
            "no private function contains anchors: " +
                anchors.joined(separator: ", ")
        )
    }

    private func privateFunctions(
        in source: String
    ) -> [Substring] {
        let marker = "\nprivate func "
        var starts = [String.Index]()
        if source.hasPrefix("private func ") {
            starts.append(source.startIndex)
        }
        var cursor = source.startIndex
        while let match = source.range(
            of: marker,
            range: cursor ..< source.endIndex
        ) {
            starts.append(
                source.index(after: match.lowerBound)
            )
            cursor = match.upperBound
        }

        return starts.enumerated().map {
            index, start in
            let nextFunction =
                index + 1 < starts.count
                    ? starts[index + 1]
                    : source.endIndex
            let main = source.range(
                of: "\n@main",
                range: start ..< nextFunction
            )?.lowerBound
            return source[
                start ..< (main ?? nextFunction)
            ]
        }
    }

    private func assertOrdered(
        _ anchors: [String],
        in source: Substring
    ) throws {
        var cursor = source.startIndex
        for anchor in anchors {
            let match = try XCTUnwrap(
                source.range(
                    of: anchor,
                    range: cursor ..< source.endIndex
                ),
                "missing ordered source-contract anchor: \(anchor)"
            )
            cursor = match.upperBound
        }
    }
}

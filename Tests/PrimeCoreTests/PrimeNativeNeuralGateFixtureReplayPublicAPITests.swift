import Foundation
import PrimeCore
import XCTest

final class PrimeNativeNeuralGateFixtureReplayPublicAPITests:
    XCTestCase
{
    func testCrossTargetValidationSurfaceCompiles() {
        XCTAssertTrue(true)
    }

    private func validateCaptureFromAnotherTarget(
        _ record:
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        planSHA256: String,
        supervisorProcessIdentifier: Int32,
        primeSourceState:
            PrimeNativeNeuralGatePrimeGitStateRecord,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        packageManifest:
            PrimeNativeNeuralGateSourceFileIdentity,
        standardOutput:
            PrimeArtifactBinding,
        swiftDriverLaunchFileData: Data,
        mappedChildMainImageData: Data,
        standardOutputData: Data
    ) throws {
        try record.validateForRunningRelease(
            against: contract,
            expectedPlanSHA256: planSHA256,
            expectedSupervisorProcessIdentifier:
                supervisorProcessIdentifier,
            expectedPrimeSourceState:
                primeSourceState,
            expectedPrimeSourceSnapshot:
                primeSourceSnapshot,
            expectedPackageManifest:
                packageManifest,
            expectedStandardOutput:
                standardOutput,
            swiftDriverLaunchFileData:
                swiftDriverLaunchFileData,
            mappedChildMainImageData:
                mappedChildMainImageData,
            standardOutputData:
                standardOutputData
        )
    }

    private func validateWorkerFromAnotherTarget(
        _ record:
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
        workerContract:
            PrimeNativeNeuralGateHistoricalWorkerContract,
        sourceExecutionBinding:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        planSHA256: String,
        closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord,
        closureBinding:
            PrimeArtifactBinding,
        snapshot: PrimeSwiftSourceSnapshot,
        swiftPackageDescribeData: Data,
        capturedRunningExecutableData: Data
    ) throws {
        try record.validateForRunningRelease(
            against: workerContract,
            sourceExecutionBinding:
                sourceExecutionBinding,
            expectedPlanSHA256: planSHA256,
            closure: closure,
            closureBinding: closureBinding,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            capturedRunningExecutableData:
                capturedRunningExecutableData
        )
    }

    private func validateWorkerResultFromAnotherTarget(
        _ result:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        request:
            PrimeNativeNeuralGateHistoricalWorkerRequest,
        requestBinding:
            PrimeArtifactBinding,
        prevalidatedWorkerProcess:
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
        workerProcessBinding:
            PrimeArtifactBinding,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try result
            .validateAgainstPrevalidatedWorkerProcess(
                request: request,
                requestBinding: requestBinding,
                workerProcess:
                    prevalidatedWorkerProcess,
                workerProcessBinding:
                    workerProcessBinding,
                contract: contract
            )
    }

    private func validateWorkerExecutionFromAnotherTarget(
        _ execution:
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord,
        prevalidatedRequest:
            PrimeNativeNeuralGateHistoricalWorkerRequest,
        prevalidatedResult:
            PrimeNativeNeuralGateHistoricalWorkerResult,
        resultBinding:
            PrimeArtifactBinding,
        requestBinding:
            PrimeArtifactBinding,
        contract:
            PrimeNativeNeuralGateHistoricalWorkerContract
    ) throws {
        try execution
            .validateSuccessfulAgainstPrevalidatedRequestAndResult(
                request: prevalidatedRequest,
                result: prevalidatedResult,
                resultBinding: resultBinding,
                requestBinding: requestBinding,
                contract: contract
            )
    }
}

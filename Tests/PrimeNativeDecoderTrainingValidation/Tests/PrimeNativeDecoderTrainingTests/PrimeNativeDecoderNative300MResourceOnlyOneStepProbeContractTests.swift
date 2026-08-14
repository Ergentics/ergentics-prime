// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import MLX
import PrimeCore
import PrimeNativeDecoderTraining
import XCTest

final class PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests:
    XCTestCase
{
    func testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure()
        throws
    {
        let authority =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                .frozenV1
        try authority.validateExactV1()

        try PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
            .validatePureContractV1()

        XCTAssertEqual(
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.receiptPrefix,
            authority.futureProbe.receiptPrefix)
        XCTAssertEqual(
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.receiptSchemaID,
            authority.receiptContract.schemaID)
        XCTAssertEqual(
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.phaseNames,
            authority.futureProbe.resourceMeasurementBoundaries)
        XCTAssertEqual(
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                .classificationDomain,
            authority.receiptContract.classificationDomain)
        XCTAssertEqual(
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                .operationCountKeys,
            authority.receiptContract.operationCountKeys)

        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 {
            repositoryRoot.deleteLastPathComponent()
        }
        let sourceURL = repositoryRoot.appendingPathComponent(
            authority.successorManifest.trainingProbeSourcePath)
        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            importLines,
            authority.successorManifest.trainingProbeSourceImports.map {
                "import \($0)"
            })

        for required in [
            "public static func runSupervisor()",
            "@inline(never)",
            "runAllocatedProbe",
            "Device(.gpu, index: Int32(0))",
            "Device.withDefaultDevice(executionDevice)",
            "Device.defaultDevice() === executionDevice",
            "Stream() == Stream.gpu",
            "MLX.Memory.peakMemory = 0",
            "MLX.Memory.clearCache()",
            "PrimeMetalDeviceLease.acquire(at:",
            "posix_spawn",
            "POSIX_SPAWN_SETPGROUP",
            "checkedEval(model, beforeFingerprintSampleViews)",
            "checkedEval(lossAndGradient.loss, lossAndGradient.gradients)",
            "checkedEval(rawGradientNorm)",
            "checkedEval(clippedGradients)",
            "checkedEval(model, optimizer, afterFingerprintSampleViews)",
            "optimizer.innerState()",
            "trainingLogitsNoCache",
            "_exit(0)",
        ] {
            XCTAssertTrue(source.contains(required), required)
        }
        XCTAssertFalse(source.contains("swift run"))
        XCTAssertFalse(
            source.split(separator: "\n").contains { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed.hasPrefix("Process()")
                    || trimmed.contains("= Process()")
            })
    }
}

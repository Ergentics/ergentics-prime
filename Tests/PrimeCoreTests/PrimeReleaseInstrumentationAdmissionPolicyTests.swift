import XCTest
@testable import PrimeCore

final class PrimeReleaseInstrumentationAdmissionPolicyTests:
    XCTestCase
{
    private let cleanObservation =
        PrimeReleaseInstrumentationObservation(
            mainExecutableImageName:
                "/Applications/PrimeGPUCalibration",
            presentForbiddenMachOSegmentNames: [],
            presentForbiddenMachOSections: [],
            presentForbiddenRuntimeSymbolNames: []
        )

    func testDeclarationIsFrozenForReceiptBinding()
        throws
    {
        let declaration =
            PrimeReleaseInstrumentationAdmissionPolicy
                .declaration

        XCTAssertEqual(
            declaration.policyID,
            "ergentics_prime_release_instrumentation_admission"
        )
        XCTAssertEqual(declaration.policyVersion, 1)
        XCTAssertEqual(
            declaration.inspectedImageScope,
            "dyld_main_executable_image_index_zero"
        )
        XCTAssertEqual(
            declaration.machOInspectionAPI,
            "Darwin._dyld_get_image_header+MachO.getsegmentdata/getsectiondata"
        )
        XCTAssertEqual(
            declaration.runtimeSymbolInspectionAPI,
            "Darwin.dlopen(nil)+dlsym"
        )
        XCTAssertEqual(
            declaration.forbiddenMachOSegmentNames,
            [
                "__LLVM_COV",
                "__LLVM_PRF",
            ]
        )
        XCTAssertEqual(
            declaration.searchedMachOSegmentNames,
            [
                "__DATA",
                "__DATA_CONST",
                "__LLVM_COV",
                "__LLVM_PRF",
                "__TEXT",
            ]
        )
        XCTAssertEqual(
            declaration.forbiddenMachOSectionNames,
            [
                "__llvm_covdata",
                "__llvm_covfun",
                "__llvm_covinit",
                "__llvm_covmap",
                "__llvm_covnames",
                "__llvm_prf_bits",
                "__llvm_prf_cnts",
                "__llvm_prf_data",
                "__llvm_prf_names",
                "__llvm_prf_vals",
                "__llvm_prf_vnds",
                "__llvm_prf_vns",
                "__llvm_prf_vtab",
            ]
        )
        XCTAssertEqual(
            declaration.forbiddenRuntimeSymbolNames,
            [
                "__asan_init",
                "__llvm_profile_initialize_file",
                "__llvm_profile_register_function",
                "__llvm_profile_runtime",
                "__llvm_profile_write_file",
                "__msan_init",
                "__tsan_init",
                "__ubsan_handle_add_overflow",
                "__ubsan_handle_type_mismatch_v1",
            ]
        )

        let encoded = try JSONEncoder().encode(
            declaration
        )
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeReleaseInstrumentationAdmissionPolicyDeclaration
                    .self,
                from: encoded
            ),
            declaration
        )
    }

    func testCleanInjectedObservationIsAdmitted()
        throws
    {
        let evidence =
            try PrimeReleaseInstrumentationAdmissionPolicy
                .validate(
                    observation: cleanObservation
                )

        XCTAssertEqual(
            evidence.declaration,
            PrimeReleaseInstrumentationAdmissionPolicy
                .declaration
        )
        XCTAssertEqual(
            evidence.observation,
            cleanObservation
        )
        XCTAssertFalse(
            evidence.observation
                .instrumentationObserved
        )

        let encoded = try JSONEncoder().encode(
            evidence
        )
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeReleaseInstrumentationAdmissionEvidence
                    .self,
                from: encoded
            ),
            evidence
        )
    }

    func testInjectedCoverageSegmentIsRejected() {
        assertRejected(
            observation:
                PrimeReleaseInstrumentationObservation(
                    mainExecutableImageName:
                        "/Applications/PrimeGPUCalibration",
                    presentForbiddenMachOSegmentNames: [
                        "__LLVM_COV"
                    ],
                    presentForbiddenMachOSections: [],
                    presentForbiddenRuntimeSymbolNames: []
                )
        )
    }

    func testInjectedProfileSectionIsRejected() {
        assertRejected(
            observation:
                PrimeReleaseInstrumentationObservation(
                    mainExecutableImageName:
                        "/Applications/PrimeGPUCalibration",
                    presentForbiddenMachOSegmentNames: [],
                    presentForbiddenMachOSections: [
                        PrimeMachOSectionReference(
                            segmentName: "__DATA",
                            sectionName:
                                "__llvm_prf_cnts"
                        )
                    ],
                    presentForbiddenRuntimeSymbolNames: []
                )
        )
    }

    func testInjectedSanitizerRuntimeIsRejected() {
        assertRejected(
            observation:
                PrimeReleaseInstrumentationObservation(
                    mainExecutableImageName:
                        "/Applications/PrimeGPUCalibration",
                    presentForbiddenMachOSegmentNames: [],
                    presentForbiddenMachOSections: [],
                    presentForbiddenRuntimeSymbolNames: [
                        "__asan_init"
                    ]
                )
        )
    }

    func testObservationCanonicalizesMutationInputs()
        throws
    {
        let observation =
            PrimeReleaseInstrumentationObservation(
                mainExecutableImageName:
                    "/Applications/PrimeGPUCalibration",
                presentForbiddenMachOSegmentNames: [
                    "__LLVM_PRF",
                    "__LLVM_COV",
                    "__LLVM_PRF",
                ],
                presentForbiddenMachOSections: [
                    PrimeMachOSectionReference(
                        segmentName: "__DATA",
                        sectionName:
                            "__llvm_prf_data"
                    ),
                    PrimeMachOSectionReference(
                        segmentName: "__DATA",
                        sectionName:
                            "__llvm_prf_cnts"
                    ),
                    PrimeMachOSectionReference(
                        segmentName: "__DATA",
                        sectionName:
                            "__llvm_prf_data"
                    ),
                ],
                presentForbiddenRuntimeSymbolNames: [
                    "__tsan_init",
                    "__asan_init",
                    "__tsan_init",
                ]
            )

        XCTAssertEqual(
            observation
                .presentForbiddenMachOSegmentNames,
            [
                "__LLVM_COV",
                "__LLVM_PRF",
            ]
        )
        XCTAssertEqual(
            observation
                .presentForbiddenMachOSections,
            [
                PrimeMachOSectionReference(
                    segmentName: "__DATA",
                    sectionName:
                        "__llvm_prf_cnts"
                ),
                PrimeMachOSectionReference(
                    segmentName: "__DATA",
                    sectionName:
                        "__llvm_prf_data"
                ),
            ]
        )
        XCTAssertEqual(
            observation
                .presentForbiddenRuntimeSymbolNames,
            [
                "__asan_init",
                "__tsan_init",
            ]
        )

        let encoded = try JSONEncoder().encode(
            observation
        )
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeReleaseInstrumentationObservation
                    .self,
                from: encoded
            ),
            observation
        )
    }

    func testLiveObserverUsesTheMainExecutableImage()
        throws
    {
        let observation =
            try PrimeReleaseInstrumentationAdmissionPolicy
                .observeCurrentProcess()

        XCTAssertFalse(
            observation.mainExecutableImageName
                .isEmpty
        )
        XCTAssertEqual(
            observation
                .presentForbiddenMachOSegmentNames,
            Array(
                Set(
                    observation
                        .presentForbiddenMachOSegmentNames
                )
            )
            .sorted()
        )
        XCTAssertEqual(
            observation
                .presentForbiddenRuntimeSymbolNames,
            Array(
                Set(
                    observation
                        .presentForbiddenRuntimeSymbolNames
                )
            )
            .sorted()
        )
    }

    private func assertRejected(
        observation:
            PrimeReleaseInstrumentationObservation,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeReleaseInstrumentationAdmissionPolicy
                .validate(
                    observation: observation
                ),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeReleaseInstrumentationAdmissionError,
                .forbiddenInstrumentationObserved(
                    observation
                ),
                file: file,
                line: line
            )
        }
    }
}

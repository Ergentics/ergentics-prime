import Darwin
import Foundation
import MachO

@frozen
public struct PrimeMachOSectionReference:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let segmentName: String
    public let sectionName: String

    public init(
        segmentName: String,
        sectionName: String
    ) {
        self.segmentName = segmentName
        self.sectionName = sectionName
    }
}

@frozen
public struct PrimeReleaseInstrumentationAdmissionPolicyDeclaration:
    Codable,
    Equatable,
    Sendable
{
    public let policyID: String
    public let policyVersion: Int
    public let inspectedImageScope: String
    public let machOInspectionAPI: String
    public let runtimeSymbolInspectionAPI: String
    public let forbiddenMachOSegmentNames: [String]
    public let searchedMachOSegmentNames: [String]
    public let forbiddenMachOSectionNames: [String]
    public let forbiddenRuntimeSymbolNames: [String]

    public init(
        policyID: String,
        policyVersion: Int,
        inspectedImageScope: String,
        machOInspectionAPI: String,
        runtimeSymbolInspectionAPI: String,
        forbiddenMachOSegmentNames: [String],
        searchedMachOSegmentNames: [String],
        forbiddenMachOSectionNames: [String],
        forbiddenRuntimeSymbolNames: [String]
    ) {
        self.policyID = policyID
        self.policyVersion = policyVersion
        self.inspectedImageScope = inspectedImageScope
        self.machOInspectionAPI = machOInspectionAPI
        self.runtimeSymbolInspectionAPI =
            runtimeSymbolInspectionAPI
        self.forbiddenMachOSegmentNames =
            forbiddenMachOSegmentNames
        self.searchedMachOSegmentNames =
            searchedMachOSegmentNames
        self.forbiddenMachOSectionNames =
            forbiddenMachOSectionNames
        self.forbiddenRuntimeSymbolNames =
            forbiddenRuntimeSymbolNames
    }
}

@frozen
public struct PrimeReleaseInstrumentationObservation:
    Codable,
    Equatable,
    Sendable
{
    public let mainExecutableImageName: String
    public let presentForbiddenMachOSegmentNames: [String]
    public let presentForbiddenMachOSections:
        [PrimeMachOSectionReference]
    public let presentForbiddenRuntimeSymbolNames: [String]

    public init(
        mainExecutableImageName: String,
        presentForbiddenMachOSegmentNames: [String],
        presentForbiddenMachOSections:
            [PrimeMachOSectionReference],
        presentForbiddenRuntimeSymbolNames: [String]
    ) {
        self.mainExecutableImageName =
            mainExecutableImageName
        self.presentForbiddenMachOSegmentNames =
            Array(
                Set(
                    presentForbiddenMachOSegmentNames
                )
            )
            .sorted()
        self.presentForbiddenMachOSections =
            Array(
                Set(
                    presentForbiddenMachOSections
                )
            )
            .sorted { left, right in
                if left.segmentName
                    != right.segmentName
                {
                    return left.segmentName
                        < right.segmentName
                }
                return left.sectionName
                    < right.sectionName
            }
        self.presentForbiddenRuntimeSymbolNames =
            Array(
                Set(
                    presentForbiddenRuntimeSymbolNames
                )
            )
            .sorted()
    }

    public var instrumentationObserved: Bool {
        !presentForbiddenMachOSegmentNames.isEmpty
            || !presentForbiddenMachOSections.isEmpty
            || !presentForbiddenRuntimeSymbolNames.isEmpty
    }
}

@frozen
public struct PrimeReleaseInstrumentationAdmissionEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let declaration:
        PrimeReleaseInstrumentationAdmissionPolicyDeclaration
    public let observation:
        PrimeReleaseInstrumentationObservation

    public init(
        declaration:
            PrimeReleaseInstrumentationAdmissionPolicyDeclaration,
        observation:
            PrimeReleaseInstrumentationObservation
    ) {
        self.declaration = declaration
        self.observation = observation
    }
}

public enum PrimeReleaseInstrumentationAdmissionError:
    Error,
    Equatable,
    Sendable
{
    case mainExecutableImageUnavailable
    case mainExecutableImageNameUnavailable
    case unsupportedMainExecutableMachOMagic(UInt32)
    case runtimeSymbolInspectionUnavailable
    case forbiddenInstrumentationObserved(
        PrimeReleaseInstrumentationObservation
    )
}

/// Rejects benchmark executables built with LLVM source-coverage,
/// profiling, or sanitizer instrumentation.
///
/// The live observer uses Darwin's public dyld, Mach-O, and dynamic-loader
/// interfaces. It does not decode a Mach-O file or delegate admission to a
/// shell command. Runtime symbol lookup is a supplemental guard because
/// statically linked instrumentation symbols can be hidden; the loaded-image
/// segment and section checks remain authoritative for LLVM coverage/profile
/// instrumentation.
public enum PrimeReleaseInstrumentationAdmissionPolicy {
    public static let declaration =
        PrimeReleaseInstrumentationAdmissionPolicyDeclaration(
            policyID:
                "ergentics_prime_release_instrumentation_admission",
            policyVersion: 1,
            inspectedImageScope:
                "dyld_main_executable_image_index_zero",
            machOInspectionAPI:
                "Darwin._dyld_get_image_header+MachO.getsegmentdata/getsectiondata",
            runtimeSymbolInspectionAPI:
                "Darwin.dlopen(nil)+dlsym",
            forbiddenMachOSegmentNames: [
                "__LLVM_COV",
                "__LLVM_PRF",
            ],
            searchedMachOSegmentNames: [
                "__DATA",
                "__DATA_CONST",
                "__LLVM_COV",
                "__LLVM_PRF",
                "__TEXT",
            ],
            forbiddenMachOSectionNames: [
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
            ],
            forbiddenRuntimeSymbolNames: [
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

    @discardableResult
    public static func validate(
        observation:
            PrimeReleaseInstrumentationObservation
    ) throws
        -> PrimeReleaseInstrumentationAdmissionEvidence
    {
        if observation.instrumentationObserved {
            throw
                PrimeReleaseInstrumentationAdmissionError
                    .forbiddenInstrumentationObserved(
                        observation
                    )
        }
        return PrimeReleaseInstrumentationAdmissionEvidence(
            declaration: declaration,
            observation: observation
        )
    }

    public static func observeCurrentProcess() throws
        -> PrimeReleaseInstrumentationObservation
    {
        guard
            let untypedHeader =
                _dyld_get_image_header(0)
        else {
            throw
                PrimeReleaseInstrumentationAdmissionError
                    .mainExecutableImageUnavailable
        }
        guard
            untypedHeader.pointee.magic
                == MH_MAGIC_64
        else {
            throw
                PrimeReleaseInstrumentationAdmissionError
                    .unsupportedMainExecutableMachOMagic(
                        untypedHeader.pointee.magic
                    )
        }
        guard
            let imageNamePointer =
                _dyld_get_image_name(0)
        else {
            throw
                PrimeReleaseInstrumentationAdmissionError
                    .mainExecutableImageNameUnavailable
        }

        let header = UnsafeRawPointer(
            untypedHeader
        )
        .assumingMemoryBound(
            to: mach_header_64.self
        )

        let presentSegments =
            declaration.forbiddenMachOSegmentNames
                .filter { segmentName in
                    containsSegment(
                        named: segmentName,
                        in: header
                    )
                }

        var presentSections:
            [PrimeMachOSectionReference] = []
        for segmentName
            in declaration.searchedMachOSegmentNames
        {
            for sectionName
                in declaration
                    .forbiddenMachOSectionNames
            {
                if containsSection(
                    segmentName: segmentName,
                    sectionName: sectionName,
                    in: header
                ) {
                    presentSections.append(
                        PrimeMachOSectionReference(
                            segmentName: segmentName,
                            sectionName: sectionName
                        )
                    )
                }
            }
        }

        let runtimeSymbols =
            try presentRuntimeSymbols()
        return PrimeReleaseInstrumentationObservation(
            mainExecutableImageName: String(
                cString: imageNamePointer
            ),
            presentForbiddenMachOSegmentNames:
                presentSegments,
            presentForbiddenMachOSections:
                presentSections,
            presentForbiddenRuntimeSymbolNames:
                runtimeSymbols
        )
    }

    @discardableResult
    public static func validateCurrentProcess() throws
        -> PrimeReleaseInstrumentationAdmissionEvidence
    {
        try validate(
            observation: observeCurrentProcess()
        )
    }

    private static func containsSegment(
        named segmentName: String,
        in header:
            UnsafePointer<mach_header_64>
    ) -> Bool {
        var byteCount: UInt = 0
        return segmentName.withCString {
            namePointer in
            getsegmentdata(
                header,
                namePointer,
                &byteCount
            ) != nil
        }
    }

    private static func containsSection(
        segmentName: String,
        sectionName: String,
        in header:
            UnsafePointer<mach_header_64>
    ) -> Bool {
        var byteCount: UInt = 0
        return segmentName.withCString {
            segmentNamePointer in
            sectionName.withCString {
                sectionNamePointer in
                getsectiondata(
                    header,
                    segmentNamePointer,
                    sectionNamePointer,
                    &byteCount
                ) != nil
            }
        }
    }

    private static func presentRuntimeSymbols()
        throws -> [String]
    {
        guard
            let executableHandle = dlopen(
                nil,
                RTLD_NOW | RTLD_LOCAL
            )
        else {
            throw
                PrimeReleaseInstrumentationAdmissionError
                    .runtimeSymbolInspectionUnavailable
        }
        defer {
            dlclose(executableHandle)
        }

        return declaration
            .forbiddenRuntimeSymbolNames
            .filter { symbolName in
                symbolName.withCString {
                    symbolNamePointer in
                    dlsym(
                        executableHandle,
                        symbolNamePointer
                    ) != nil
                }
            }
    }
}

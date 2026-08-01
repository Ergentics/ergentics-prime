import Foundation
import PrimeCore
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplaySourceBinding

public enum PrimeNativeNeuralGateReplayCaptureInventoryError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case sourceDiscoveryRejected
    case sourceSetMismatch
    case rootIdentityMismatch
    case liveInventoryRejected
    case sourceInventoryMismatch
    case finalRecaptureRejected
}

/// Frozen mechanics contract for one exact held-root four-source capture.
///
/// The retained PrimeCore inventory is the authority boundary. Its Codable
/// inventory value alone cannot construct this capability or promote a claim.
public struct PrimeNativeNeuralGateReplayCaptureInventoryContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let sourceBindingContractID: String
    public let retainedInventoryContractID: String
    public let exactArtifactCount: Int
    public let exactWholeRootNodeClosureRequired: Bool
    public let dedicatedSourceRootRequired: Bool
    public let authoritativeRebindRequired: Bool
    public let finalUnchangedRecaptureRequired: Bool
    public let singleSourceCaptureEpochEstablished: Bool
    public let durableArtifactOriginEstablished: Bool
    public let independentPromptTargetCrosswalkEstablished: Bool
    public let processDeliveryObserved: Bool
    public let modelExecutionEstablished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_single_held_root_four_source_capture_inventory_v1",
        sourceBindingContractID:
            PrimeNativeNeuralGateReplaySourceBindingPolicy
            .serializationContractID,
        retainedInventoryContractID:
            "primecore_retained_exact_descriptor_rooted_inventory_recapture_v1",
        exactArtifactCount: 41,
        exactWholeRootNodeClosureRequired: true,
        dedicatedSourceRootRequired: true,
        authoritativeRebindRequired: true,
        finalUnchangedRecaptureRequired: true,
        singleSourceCaptureEpochEstablished: true,
        durableArtifactOriginEstablished: true,
        independentPromptTargetCrosswalkEstablished: false,
        processDeliveryObserved: false,
        modelExecutionEstablished: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 capability uses PrimeCore's retained exact-tree inventory authority. A preliminary four-source bind discovers and canonicalizes exactly 41 immutable files in a dedicated owner-private source root; those discovery values are discarded. PrimeCore captures the complete descriptor-rooted node closure, retains the admitted root and scoped descriptors plus exact node identities, the four sources are rebound while that capability is live, and a final recapture must match exactly before a sealed result is returned. Successful capture establishes one source epoch and durable origin only for the captured prompt, outer-evaluation, one-seed raw-execution, and one-seed lossless-logit bytes. It does not establish the independent prompt/target crosswalk, prompt-content target independence, process delivery, model execution, evaluation, mechanics PASS, a receipt, scientific authority, or product authority."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              sourceBindingContractID
                == PrimeNativeNeuralGateReplaySourceBindingPolicy
                .serializationContractID,
              exactArtifactCount == 41,
              exactWholeRootNodeClosureRequired,
              dedicatedSourceRootRequired,
              authoritativeRebindRequired,
              finalUnchangedRecaptureRequired,
              singleSourceCaptureEpochEstablished,
              durableArtifactOriginEstablished,
              !independentPromptTargetCrosswalkEstablished,
              !processDeliveryObserved,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateReplayCaptureInventoryError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case sourceBindingContractID =
            "source_binding_contract_id"
        case retainedInventoryContractID =
            "retained_inventory_contract_id"
        case exactArtifactCount = "exact_artifact_count"
        case exactWholeRootNodeClosureRequired =
            "exact_whole_root_node_closure_required"
        case dedicatedSourceRootRequired =
            "dedicated_source_root_required"
        case authoritativeRebindRequired =
            "authoritative_rebind_required"
        case finalUnchangedRecaptureRequired =
            "final_unchanged_recapture_required"
        case singleSourceCaptureEpochEstablished =
            "single_source_capture_epoch_established"
        case durableArtifactOriginEstablished =
            "durable_artifact_origin_established"
        case independentPromptTargetCrosswalkEstablished =
            "independent_prompt_target_crosswalk_established"
        case processDeliveryObserved =
            "process_delivery_observed"
        case modelExecutionEstablished =
            "model_execution_established"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Sealed, non-Codable result of one retained-inventory capture epoch.
public struct PrimeNativeNeuralGateFourSourceCaptureInventory:
    @unchecked Sendable
{
    public let contractID: String
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let replicateSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let captureIdentitySHA256: String
    public let inventory:
        PrimeNativeNeuralGateRealizedFilesystemInventory
    public let promptRecords:
        PrimeNativeNeuralGateValidatedPromptRecordStream
    public let outerRecords:
        PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream
    public let rawRecords:
        PrimeNativeNeuralGateValidatedRawExecutionRecordStream
    public let logitSidecar:
        PrimeNativeNeuralGateSourceBoundLogitSidecar

    public let exactWholeRootNodeClosureEstablished = true
    public let singleSourceCaptureEpochEstablished = true
    public let durableArtifactOriginEstablished = true
    public let independentPromptTargetCrosswalkEstablished = false
    public let promptContentTargetIndependenceEstablished = false
    public let processDeliveryObserved = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    private let liveInventory:
        PrimeTrustedArtifactInventoryCapture

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        captureIdentitySHA256: String,
        liveInventory:
            PrimeTrustedArtifactInventoryCapture,
        sources: BoundSources
    ) {
        contractID =
            PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1.contractID
        self.rootIdentity = rootIdentity
        self.replicateSeed = replicateSeed
        self.captureIdentitySHA256 =
            captureIdentitySHA256
        self.liveInventory = liveInventory
        inventory = liveInventory.inventory
        promptRecords = sources.prompt
        outerRecords = sources.outer
        rawRecords = sources.raw
        logitSidecar = sources.logit
    }

    /// Revalidates the retained exact-tree capability. The returned Codable
    /// value is diagnostic transport only and cannot reconstruct this type.
    @discardableResult
    public func validateStillUnchanged() throws
        -> PrimeNativeNeuralGateRealizedFilesystemInventory
    {
        do {
            return try liveInventory
                .recaptureAndValidateUnchanged()
        } catch {
            throw PrimeNativeNeuralGateReplayCaptureInventoryError
                .finalRecaptureRejected
        }
    }
}

public enum PrimeNativeNeuralGateReplayCaptureInventory {
    private typealias Error =
        PrimeNativeNeuralGateReplayCaptureInventoryError
    private typealias ArtifactContract =
        PrimeNativeNeuralGateReplayArtifactOutputContract

    public static func capture(
        rootDirectoryURL: URL,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws -> PrimeNativeNeuralGateFourSourceCaptureInventory {
        let root: PrimeArtifactRoot
        do {
            root = try PrimeArtifactRoot(
                directoryURL: rootDirectoryURL
            )
        } catch {
            throw Error.sourceDiscoveryRejected
        }
        return try capture(
            artifactRoot: root,
            replicateSeed: replicateSeed
        )
    }

    public static func capture(
        artifactRoot: PrimeArtifactRoot,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws -> PrimeNativeNeuralGateFourSourceCaptureInventory {
        let contract =
            PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1
        try contract.validate()
        do {
            try artifactRoot.requirePrivateRootMode()
        } catch {
            throw Error.sourceDiscoveryRejected
        }

        // The discovery capabilities are deliberately scoped out before the
        // retained inventory exists. Only their exact immutable bindings
        // cross the authority boundary into the authoritative rebind.
        let bindings: [PrimeArtifactBinding] = try {
            let discovered: BoundSources
            do {
                discovered = try bindSources(
                    artifactRoot: artifactRoot,
                    replicateSeed: replicateSeed
                )
            } catch {
                throw Error.sourceDiscoveryRejected
            }
            try requireCommonRoot(
                discovered,
                expectedSeed: replicateSeed
            )
            return try exactBindings(
                for: discovered,
                replicateSeed: replicateSeed
            )
        }()

        let liveInventory:
            PrimeTrustedArtifactInventoryCapture
        do {
            liveInventory = try artifactRoot
                .captureTrustedInventory(
                    expectedArtifacts: bindings
                )
        } catch {
            throw Error.liveInventoryRejected
        }

        let rebound: BoundSources
        do {
            rebound = try bindSources(
                artifactRoot: artifactRoot,
                replicateSeed: replicateSeed
            )
        } catch {
            throw Error.liveInventoryRejected
        }
        try requireCommonRoot(
            rebound,
            expectedSeed: replicateSeed
        )
        let rootIdentity = rebound.prompt.rootIdentity
        let currentRoot: PrimeArtifactRootIdentity
        do {
            currentRoot = try artifactRoot
                .verifiedRootIdentity()
        } catch {
            throw Error.rootIdentityMismatch
        }
        guard rootIdentity == currentRoot else {
            throw Error.rootIdentityMismatch
        }
        try requireInventory(
            liveInventory.inventory,
            bindings: bindings,
            matches: rebound
        )
        let finalInventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory
        do {
            finalInventory = try liveInventory
                .recaptureAndValidateUnchanged()
        } catch {
            throw Error.finalRecaptureRejected
        }
        guard finalInventory == liveInventory.inventory
        else {
            throw Error.finalRecaptureRejected
        }
        let identity = try captureIdentitySHA256(
            rootIdentity: rootIdentity,
            replicateSeed: replicateSeed,
            inventory: finalInventory,
            sources: rebound
        )
        return PrimeNativeNeuralGateFourSourceCaptureInventory(
            rootIdentity: rootIdentity,
            replicateSeed: replicateSeed,
            captureIdentitySHA256: identity,
            liveInventory: liveInventory,
            sources: rebound
        )
    }

    private static func bindSources(
        artifactRoot: PrimeArtifactRoot,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws -> BoundSources {
        BoundSources(
            prompt: try
                PrimeNativeNeuralGateReplaySourceBinding
                .bindPromptRecords(
                    artifactRoot: artifactRoot
                ),
            outer: try
                PrimeNativeNeuralGateReplaySourceBinding
                .bindOuterEvaluationRecords(
                    artifactRoot: artifactRoot
                ),
            raw: try
                PrimeNativeNeuralGateReplaySourceBinding
                .bindRawExecutionRecords(
                    artifactRoot: artifactRoot,
                    replicateSeed: replicateSeed
                ),
            logit: try
                PrimeNativeNeuralGateReplaySourceBinding
                .bindLogitSidecar(
                    artifactRoot: artifactRoot,
                    replicateSeed: replicateSeed
                )
        )
    }

    private static func requireCommonRoot(
        _ sources: BoundSources,
        expectedSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws {
        let root = sources.prompt.rootIdentity
        guard sources.outer.rootIdentity == root,
              sources.raw.rootIdentity == root,
              sources.logit.rootIdentity == root,
              sources.raw.replicateSeed == expectedSeed,
              sources.logit.replicateSeed == expectedSeed,
              sources.prompt.sourceStreamBindingEstablished,
              sources.outer.sourceStreamBindingEstablished,
              sources.raw.sourceStreamBindingEstablished,
              sources.logit.sourceStreamBindingEstablished,
              !sources.prompt.durableArtifactOriginEstablished,
              !sources.outer.durableArtifactOriginEstablished,
              !sources.raw.durableArtifactOriginEstablished,
              !sources.logit.durableArtifactOriginEstablished
        else {
            throw Error.rootIdentityMismatch
        }
    }

    private static func exactBindings(
        for sources: BoundSources,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws -> [PrimeArtifactBinding] {
        let observations = sources.observations
        var byPath =
            [String: PrimeNativeNeuralGateSourceFileObservation]()
        byPath.reserveCapacity(observations.count)
        for observation in observations {
            guard byPath[observation.relativePath] == nil
            else {
                throw Error.sourceSetMismatch
            }
            byPath[observation.relativePath] = observation
        }
        let expectedPaths = try expectedKeys(
            replicateSeed
        ).map {
            try ArtifactContract.frozenV4
                .spec(for: $0).relativePath
        }.sorted()
        guard expectedPaths.count == 41,
              observations.count == expectedPaths.count,
              byPath.keys.sorted() == expectedPaths
        else {
            throw Error.sourceSetMismatch
        }
        return try expectedPaths.map { path in
            guard let observation = byPath[path]
            else {
                throw Error.sourceSetMismatch
            }
            return PrimeArtifactBinding(
                relativePath: path,
                sha256: observation.sha256,
                byteCount: observation.byteCount,
                purpose: .immutableData
            )
        }
    }

    private static func expectedKeys(
        _ seed: PrimeNativeNeuralGateArtifactSeed
    ) -> [PrimeNativeNeuralGateArtifactKey] {
        [
            .promptOnlyFixtureManifest,
            .promptOnlyFixtureGlobal,
            .outerEvaluationManifest,
            .outerEvaluationGlobal,
            .rawExecutionManifest(seed),
            .rawExecutionGlobal(seed),
            .logitDictionary(seed),
            .logitManifest(seed),
        ]
        + (0 ..< 5).flatMap { ordinal in
            [
                .promptOnlyFixtureChunk(UInt32(ordinal)),
                .outerEvaluationChunk(UInt32(ordinal)),
                .rawExecutionChunk(
                    seed,
                    UInt32(ordinal)
                ),
            ]
        }
        + (0 ..< 18).map {
            .logitChunk(seed, UInt32($0))
        }
    }

    private static func requireInventory(
        _ inventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory,
        bindings: [PrimeArtifactBinding],
        matches sources: BoundSources
    ) throws {
        guard inventory.rootRelativePath == nil,
              inventory.fileEntries.map(\.artifact)
                == bindings,
              inventory.unsupportedNodeRelativePaths.isEmpty,
              inventory.enumerationIncludesAllNodeTypes,
              !inventory.symbolicLinksFollowed,
              inventory.fileEntries.allSatisfy({
                  $0.posixMode == "0444"
                    && $0.fileType == "regular_file"
                    && $0.linkCount == 1
                    && $0.ownerMatchesCurrentEffectiveUser
                    && $0.capturedFromDescriptor
              })
        else {
            throw Error.sourceInventoryMismatch
        }
        var byPath = [String: PrimeArtifactBinding]()
        for entry in inventory.fileEntries {
            guard byPath[entry.artifact.relativePath] == nil
            else {
                throw Error.sourceInventoryMismatch
            }
            byPath[entry.artifact.relativePath] =
                entry.artifact
        }
        let observations = sources.observations
        guard observations.count == bindings.count else {
            throw Error.sourceInventoryMismatch
        }
        for observation in observations {
            guard let binding = byPath[
                    observation.relativePath
                  ],
                  binding.sha256 == observation.sha256,
                  binding.byteCount == observation.byteCount
            else {
                throw Error.sourceInventoryMismatch
            }
        }
    }

    private static func captureIdentitySHA256(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        inventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory,
        sources: BoundSources
    ) throws -> String {
        let payload = CaptureIdentityPayload(
            contractID:
                PrimeNativeNeuralGateReplayCaptureInventoryContract
                .frozenV1.contractID,
            root: .init(rootIdentity),
            replicateSeed: replicateSeed.rawValue,
            promptSourceBindingSHA256:
                sources.prompt.sourceBindingSHA256,
            outerSourceBindingSHA256:
                sources.outer.sourceBindingSHA256,
            rawSourceBindingSHA256:
                sources.raw.sourceBindingSHA256,
            logitSourceBindingSHA256:
                sources.logit.sourceBindingSHA256,
            inventory: inventory
        )
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(payload)
        )
    }
}

fileprivate struct BoundSources: Sendable {
    let prompt: PrimeNativeNeuralGateValidatedPromptRecordStream
    let outer:
        PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream
    let raw: PrimeNativeNeuralGateValidatedRawExecutionRecordStream
    let logit: PrimeNativeNeuralGateSourceBoundLogitSidecar

    var observations:
        [PrimeNativeNeuralGateSourceFileObservation]
    {
        prompt.fileObservations
        + outer.fileObservations
        + raw.fileObservations
        + logit.fileObservations
    }
}

private struct CaptureRootIdentity: Codable {
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let actualMode: UInt16
    let linkCount: UInt64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    init(_ root: PrimeNativeNeuralGateSourceRootIdentity) {
        deviceID = root.deviceID
        inode = root.inode
        ownerUserID = root.ownerUserID
        ownerGroupID = root.ownerGroupID
        actualMode = root.actualMode
        linkCount = root.linkCount
        modificationSeconds = root.modificationSeconds
        modificationNanoseconds = root.modificationNanoseconds
        statusChangeSeconds = root.statusChangeSeconds
        statusChangeNanoseconds = root.statusChangeNanoseconds
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case ownerUserID = "owner_user_id"
        case ownerGroupID = "owner_group_id"
        case actualMode = "actual_mode"
        case linkCount = "link_count"
        case modificationSeconds = "modification_seconds"
        case modificationNanoseconds = "modification_nanoseconds"
        case statusChangeSeconds = "status_change_seconds"
        case statusChangeNanoseconds = "status_change_nanoseconds"
    }
}

private struct CaptureIdentityPayload: Codable {
    let contractID: String
    let root: CaptureRootIdentity
    let replicateSeed: Int
    let promptSourceBindingSHA256: String
    let outerSourceBindingSHA256: String
    let rawSourceBindingSHA256: String
    let logitSourceBindingSHA256: String
    let inventory:
        PrimeNativeNeuralGateRealizedFilesystemInventory

    private enum CodingKeys: String, CodingKey {
        case contractID = "contract_id"
        case root
        case replicateSeed = "replicate_seed"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case outerSourceBindingSHA256 =
            "outer_source_binding_sha256"
        case rawSourceBindingSHA256 =
            "raw_source_binding_sha256"
        case logitSourceBindingSHA256 =
            "logit_source_binding_sha256"
        case inventory
    }
}

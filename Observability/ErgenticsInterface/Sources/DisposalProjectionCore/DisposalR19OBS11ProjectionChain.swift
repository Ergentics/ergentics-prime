import Darwin
import Foundation

struct DisposalR19OBS11PlanStep: Equatable, Sendable {
    let step: Int
    let frameCount: Int
    let bytes: Int
    let prefixSHA256: String
    let tailFrameLFSHA256: String
    let finalRoot: String
    let stagingRoot: String
    let predecessorStep: Int?
    let sourceSealed: Bool
    let terminal: Bool
    let status: String
}

struct DisposalR19OBS11FrozenIdentity: Equatable, Sendable {
    let label: String
    let path: String
    let device: UInt64
    let inode: UInt64
    let generation: UInt32
    let mode: String
    let uid: UInt32
    let gid: UInt32
    let linkCount: UInt64
    let bytes: Int
    let sha256: String?
}

struct DisposalR19OBS11FrozenResource: Equatable, Sendable {
    let leaf: String
    let bytes: Int
    let sha256: String
}

enum DisposalR19OBS11FrozenPlan {
    static let checkpointID = "R19-OBS11-C0"
    static let c0SHA256 = "e68dd4f83bd59f66d94824c4e9476a1b8ea70c2383dd24dd0c3a846d7f72bf54"
    static let c0Blob = "6954a3b29ea1c4a603b18615a2228fb40dcdbba3"
    static let c0Commit = "633d4cdf5a5fa409fed315b2e1913a2304c4ff18"
    static let c0Tree = "e9eff0086feeca57fefa43db951cfbecf9006f51"
    static let minimumOpenFileSoftLimit: UInt64 = 256
    static let sourcePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        "r19-observability-eaf9b76-v1/r19-observations.v1.jsonl"
    static let sourceBytes = 17_557
    static let sourceSHA256 = "6f90d4709ad136c356d75ee28ba49a71854215ed386721e734a42eac86f56743"
    static let sqliteBytes = 1_802_240
    static let sqliteSHA256 = "cc3cc4489b4dee8218173721051ebc0d9be12a26a8ff1f8e3fe4e7fa6f5b4032"
    static let sourceClosure: [DisposalR19OBS11FrozenIdentity] = [
        .init(
            label: "SOURCE_PARENT",
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45",
            device: 16_777_231,
            inode: 13_612_594,
            generation: 0,
            mode: "0755",
            uid: 501,
            gid: 20,
            linkCount: 37,
            bytes: 1_184,
            sha256: nil),
        .init(
            label: "SOURCE_ROOT",
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/r19-observability-eaf9b76-v1",
            device: 16_777_231,
            inode: 17_509_052,
            generation: 0,
            mode: "0500",
            uid: 501,
            gid: 20,
            linkCount: 4,
            bytes: 128,
            sha256: nil),
        .init(
            label: "SOURCE_JOURNAL",
            path: sourcePath,
            device: 16_777_231,
            inode: 17_509_053,
            generation: 0,
            mode: "0400",
            uid: 501,
            gid: 20,
            linkCount: 1,
            bytes: sourceBytes,
            sha256: sourceSHA256),
        .init(
            label: "SOURCE_SQLITE_SIBLING",
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/r19-observability-eaf9b76-v1/r19-observations.v1.sqlite3",
            device: 16_777_231,
            inode: 17_509_057,
            generation: 0,
            mode: "0400",
            uid: 501,
            gid: 20,
            linkCount: 1,
            bytes: sqliteBytes,
            sha256: sqliteSHA256),
    ]
    static let ruleResources: [DisposalR19OBS11FrozenResource] = [
        .init(
            leaf: "001-evidence.sql",
            bytes: 50_706,
            sha256: "f3e003136aa4f9a12308d310ffa6bc92d71bccb99a7a50656c32231b79a435c7"),
        .init(
            leaf: "001-graph.sql",
            bytes: 41_517,
            sha256: "f65eb702e528f851bfd3bcce2817258dfdc5779132bba780964c82c0d752009e"),
        .init(
            leaf: "001-metrics.sql",
            bytes: 12_119,
            sha256: "eda615d5bc71246c54d7335679f641646e11c8938ef01a459cf168be2aa5ce61"),
        .init(
            leaf: "disposal-adapters.v1.json",
            bytes: 4_610,
            sha256: "68e09200dd29a47fcbe49e083df41fe55ead950198edf75300ab6e302b61be1b"),
        .init(
            leaf: "disposal-lattice.v1.json",
            bytes: 1_937,
            sha256: "c99361cb2052032e176b1ab5cd22898a67231b98bdea8c972388bdeab12ba022"),
    ]
    static let receiptFinalRoot =
        "/private/tmp/ergentics-r19-obs11-eaf9b76-chain-receipt-v1"
    static let receiptStagingRoot =
        "/private/tmp/.ergentics-r19-obs11-receipt-staging-" +
        "f73a8ace6f22922f9bdf21c1b4cb715cf23fefac53928c636879571a8ef312d4"
    static let chainID = disposalLengthFramedID(
        "ergentics-r19-obs11-chain-id-v1",
        [c0SHA256, sourceSHA256, receiptFinalRoot])
    static let terminalLeaf = "99-terminal.json"
    static let ordinaryLeaves = [
        "00-start.json",
        "01-f01-intent.json", "02-f01-result.json",
        "03-f02-intent.json", "04-f02-result.json",
        "05-f03-intent.json", "06-f03-result.json",
        "07-f04-intent.json", "08-f04-result.json",
        "09-f05-intent.json", "10-f05-result.json",
        "11-f06-intent.json", "12-f06-result.json",
        "13-f07-intent.json", "14-f07-result.json",
        "15-f08-intent.json", "16-f08-result.json",
    ]

    static let steps: [DisposalR19OBS11PlanStep] = [
        step(
            1, 1_793,
            "06beda693f2692474a360be7aa81b90ddfb80935afa6c9da664a8c08eb22d201",
            "06beda693f2692474a360be7aa81b90ddfb80935afa6c9da664a8c08eb22d201",
            "295d1917bc78ba2f6df819080625ce814c0f81cf510dfe6a53c49c5b279d01d2"),
        step(
            2, 4_093,
            "36ef2d7da4f1b0674bf132e609a627d62efbef218e79d94319aee3162dd76639",
            "0d038102858c9e7eca6d33eee33b40c19b92818be95faf70ec89c1a53b0cc479",
            "3940219fadc045ded7cdbd1e29b056b1970cd74a11b1d9cdd44dcff30c767909"),
        step(
            3, 6_471,
            "3e7cdf4a20402a98fc71666579c8f7e4440d33d4e91c24ca8cd0f4f11b0a4814",
            "c5bf5cceca75877dfdb2613857a0753adb68f8db56abdcbd92058cb55f8c95ec",
            "296b7163340a0091cd8284fb28554719473872755d90bd09acd386481e65a7c1"),
        step(
            4, 8_763,
            "f0dabd271efdf9c8a30ef80d098c9ea64cf5dcc2667fbe084981cc9f3e0b3264",
            "9da1c5798c88eaa29a9671c51c997712690b3c5d455b45a5ca2e35fa4e282405",
            "01be912e36242fe6a21a2bb3bd26c98d9868cfc369a2bf1cf22c6cf49ed7e3f0"),
        step(
            5, 11_124,
            "591d2706b0728db8de411d8de4bcabf44926ef8213eea779032f3b91bf5a085a",
            "772dbce9af1dfa2f8bb8482ce70486ea8b5ddc45b01d684ea8fa2c060e0b1809",
            "33b7216d1257f40d12e01fd6586665e444f7e42a7111f9d8bab604aeeeec3ab7"),
        step(
            6, 13_681,
            "0d78a0eb3a633b781d492b868baa519b372e2bdb7c6ba0be1680de83aab16255",
            "395fd45de1a1a1b896dea6c71da620d8e46f386cc43ed064b1e8f28561ad5f71",
            "8f2f5d2eb90fc9c66661fd67c2b222d094821e73c410bbc65ff415a1d2d3e71"),
        step(
            7, 16_034,
            "db791a590ed6d4189ea91fa313702c9a27a181474ccb7c5a6dc67d19763f42d2",
            "c7d354bd8fb70b97babe7aa2ac2f509282f982c19c3a3892dbb5c4ca068788ba",
            "2dab22cfe3b18383f4fd7179fd459bba3562648b2edd87176426aec30cc417a8"),
        step(
            8, 17_557,
            "6f90d4709ad136c356d75ee28ba49a71854215ed386721e734a42eac86f56743",
            "d2e1c528f67102b4e9e21fca74bc3c82f92a405f5919cb35905d521857cc40a1",
            "0b20d9420c5f96e64df1a7b3dc4af2c630678daf5150436dc8252d1fe8b9de4f")
    ]

    private static func step(
        _ ordinal: Int,
        _ bytes: Int,
        _ prefixSHA256: String,
        _ tailFrameLFSHA256: String,
        _ stagingDigest: String
    ) -> DisposalR19OBS11PlanStep {
        let step = String(format: "%02d", ordinal)
        let finalRoot = "/private/tmp/ergentics-r19-obs11-eaf9b76-f\(step)-\(prefixSHA256)"
        return .init(
            step: ordinal,
            frameCount: ordinal,
            bytes: bytes,
            prefixSHA256: prefixSHA256,
            tailFrameLFSHA256: tailFrameLFSHA256,
            finalRoot: finalRoot,
            stagingRoot: "/private/tmp/.ergentics-disposal-staging-" + stagingDigest,
            predecessorStep: ordinal == 1 ? nil : ordinal - 1,
            sourceSealed: ordinal == 8,
            terminal: false,
            status: ordinal == 8
                ? "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL"
                : "ABSTAIN_NONTERMINAL_PREFIX_PROJECTION")
    }
}

enum DisposalR19OBS11FailureStage: String, Equatable, Sendable {
    case frozenSource = "FROZEN_SOURCE"
    case namespacePreflight = "NAMESPACE_PREFLIGHT"
    case sourceRevalidation = "SOURCE_REVALIDATION"
    case resourceRevalidation = "RESOURCE_REVALIDATION"
    case receiptStart = "RECEIPT_START"
    case receiptIntent = "RECEIPT_INTENT"
    case projectionBuild = "PROJECTION_BUILD"
    case projectionAdmission = "PROJECTION_ADMISSION"
    case projectionRevalidation = "PROJECTION_REVALIDATION"
    case receiptResult = "RECEIPT_RESULT"
    case chainRevalidation = "CHAIN_REVALIDATION"
    case receiptMerkle = "RECEIPT_MERKLE"
    case receiptTerminal = "RECEIPT_TERMINAL"
    case receiptPublication = "RECEIPT_PUBLICATION"
}

struct DisposalR19OBS11StableFailure: Error, Equatable, Sendable {
    let stage: DisposalR19OBS11FailureStage
    let code: String
    let step: Int?
}

struct DisposalR19OBS11StepObservation: Equatable, Sendable {
    let outputRootPath: String
    let projectionID: String
    let sealSHA256: String
    let evidenceSHA256: String
    let metricsSHA256: String
    let graphSHA256: String
    let evidenceBytes: Int
    let metricsBytes: Int
    let graphBytes: Int
    let sourceSHA256: String
    let sourceBytes: Int
    let frameCount: Int
    let tailFrameLFSHA256: String
    let predecessorProjectionID: String?
    let sourceSealed: Bool
    let terminal: Bool
    let status: String
    let authorityVector: String
    let authoritative: Bool
    let mayFeedController: Bool
    let machinePrefixJoin: String
}

struct DisposalR19OBS11RetainedNamespaceState: Equatable, Sendable {
    let step: Int?
    let finalRootState: String
    let stagingRootState: String
    let originProof: String
    let snapshotSHA256: String?
    let snapshotComponents: [String]?
}

final class DisposalR19OBS11RetainedNamespaceHold {
    let state: DisposalR19OBS11RetainedNamespaceState
    private let revalidateBody: () throws -> Void

    init(
        state: DisposalR19OBS11RetainedNamespaceState,
        revalidate: @escaping () throws -> Void
    ) {
        self.state = state
        revalidateBody = revalidate
    }

    func revalidate() throws {
        try revalidateBody()
    }
}

struct DisposalR19OBS11SourcePort {
    let journal: Data
    let sqliteBytes: Int
    let sqliteSHA256: String
    let descriptorSoftLimit: UInt64
    let revalidate: () throws -> Void
}

struct DisposalR19OBS11ProjectionPort {
    let preflightAllAbsent: () throws -> Void
    let buildAndAdmit: (
        _ step: DisposalR19OBS11PlanStep,
        _ request: DisposalProjectionSetRequest
    ) throws -> DisposalR19OBS11StepObservation
    let revalidateAll: () throws -> Void
    let observeRetainedState: (_ step: Int?) throws -> DisposalR19OBS11RetainedNamespaceHold
}

struct DisposalR19OBS11ReceiptPort {
    let appendExact: (_ leaf: String, _ frameWithLF: Data) throws -> String
    let durableLeafNames: () -> [String]
    let publish: (
        _ expectedLeaves: [String],
        _ afterPreparedRevalidation: () throws -> Void
    ) throws -> Void
}

struct DisposalR19OBS11ResourcePort {
    let facts: [DisposalR19OBS11FrozenResource]
    let revalidate: () throws -> Void
}

final class DisposalR19OBS11ProjectionChainCoordinator {
    private let source: DisposalR19OBS11SourcePort
    private let projection: DisposalR19OBS11ProjectionPort
    private let receipts: DisposalR19OBS11ReceiptPort
    private let resources: DisposalR19OBS11ResourcePort
    private var previousReceiptSHA256: String?
    private var durableOrdinaryLeaves: [String] = []
    private var observations: [DisposalR19OBS11StepObservation] = []
    private var resultReceiptSHA256s: [String] = []

    init(
        source: DisposalR19OBS11SourcePort,
        projection: DisposalR19OBS11ProjectionPort,
        receipts: DisposalR19OBS11ReceiptPort,
        resources: DisposalR19OBS11ResourcePort
    ) {
        self.source = source
        self.projection = projection
        self.receipts = receipts
        self.resources = resources
    }

    func run() throws {
        do {
            try validateFrozenSource()
            try revalidateSourceAndResources(step: nil)
            try staged(.namespacePreflight, step: nil) {
                try projection.preflightAllAbsent()
            }
            _ = try appendOrdinary(
                leaf: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
                payload: startPayload(),
                stage: .receiptStart,
                step: nil)

            for plan in DisposalR19OBS11FrozenPlan.steps {
                try revalidateAll(step: plan.step)
                let predecessor = observations.last
                let intentLeaf = DisposalR19OBS11FrozenPlan.ordinaryLeaves[plan.step * 2 - 1]
                _ = try appendOrdinary(
                    leaf: intentLeaf,
                    payload: intentPayload(plan: plan, predecessor: predecessor),
                    stage: .receiptIntent,
                    step: plan.step)
                try revalidateSourceAndResources(step: plan.step)

                let prefix = source.journal.prefix(plan.bytes)
                let request = DisposalProjectionSetRequest(
                    journal: Data(prefix),
                    journalLogicalPath: DisposalR19OBS11FrozenPlan.sourcePath,
                    predecessor: predecessor.map {
                        DisposalProjectionPredecessorReference(
                            rootPath: $0.outputRootPath,
                            expectedSealSHA256: $0.sealSHA256)
                    })
                let observation = try staged(.projectionBuild, step: plan.step) {
                    try projection.buildAndAdmit(plan, request)
                }
                try staged(.projectionAdmission, step: plan.step) {
                    try validate(observation: observation, plan: plan, predecessor: predecessor)
                }
                observations.append(observation)
                try revalidateAll(step: plan.step)

                let resultLeaf = DisposalR19OBS11FrozenPlan.ordinaryLeaves[plan.step * 2]
                let resultSHA = try appendOrdinary(
                    leaf: resultLeaf,
                    payload: resultPayload(plan: plan, observation: observation),
                    stage: .receiptResult,
                    step: plan.step)
                resultReceiptSHA256s.append(resultSHA)
            }

            try staged(.chainRevalidation, step: nil) {
                try revalidateAll(step: nil)
            }
            let merkleRoot = try staged(.receiptMerkle, step: nil) {
                try DisposalR19OBS11ReceiptMerkle.root(
                    resultFrameWithLFSHA256: resultReceiptSHA256s)
            }
            try appendTerminal(
                payload: successTerminalPayload(merkleRoot: merkleRoot),
                ordinal: 17,
                stage: .receiptTerminal)
            try publishReceiptRoot(stage: .receiptPublication)
        } catch let failure as DisposalR19OBS11StableFailure {
            try publishFailureIfExactPrefix(failure)
            throw failure
        } catch let rejection as DisposalProjectionRejection {
            let failure = DisposalR19OBS11StableFailure(
                stage: .projectionBuild,
                code: rejection.code,
                step: observations.count + 1)
            try publishFailureIfExactPrefix(failure)
            throw failure
        } catch {
            let failure = DisposalR19OBS11StableFailure(
                stage: .projectionBuild,
                code: "OBS11_UNCLASSIFIED_FAILURE",
                step: observations.count + 1)
            try publishFailureIfExactPrefix(failure)
            throw failure
        }
    }

    private func validateFrozenSource() throws {
        try staged(.frozenSource, step: nil) {
            try disposalRequireProjection(
                source.journal.count == DisposalR19OBS11FrozenPlan.sourceBytes &&
                    disposalSHA256(source.journal) == DisposalR19OBS11FrozenPlan.sourceSHA256 &&
                    source.sqliteBytes == DisposalR19OBS11FrozenPlan.sqliteBytes &&
                    source.sqliteSHA256 == DisposalR19OBS11FrozenPlan.sqliteSHA256 &&
                    source.journal.last == 0x0a &&
                    source.journal.filter { $0 == 0x0a }.count == 8,
                "OBS11_SOURCE_EXACT")
            try disposalRequireProjection(
                source.descriptorSoftLimit >=
                    DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
                "OBS11_DESCRIPTOR_LIMIT_INSUFFICIENT")
            try disposalRequireProjection(
                resources.facts == DisposalR19OBS11FrozenPlan.ruleResources,
                "OBS11_RULE_RESOURCE_FACT_JOIN")
            let namespacePaths = DisposalR19OBS11FrozenPlan.steps.flatMap {
                [$0.finalRoot, $0.stagingRoot]
            } + [
                DisposalR19OBS11FrozenPlan.receiptFinalRoot,
                DisposalR19OBS11FrozenPlan.receiptStagingRoot,
            ]
            try disposalRequireProjection(
                Set(namespacePaths).count == namespacePaths.count,
                "OBS11_NAMESPACE_UNIQUE")
            for plan in DisposalR19OBS11FrozenPlan.steps {
                try disposalRequireProjection(
                    DisposalSealedArtifactSet.stagingPath(for: plan.finalRoot) ==
                        plan.stagingRoot &&
                        plan.predecessorStep == (plan.step == 1 ? nil : plan.step - 1),
                    "OBS11_NAMESPACE_DERIVATION",
                    frameOrdinal: plan.step - 1)
                let prefix = Data(source.journal.prefix(plan.bytes))
                try disposalRequireProjection(
                    prefix.count == plan.bytes && disposalSHA256(prefix) == plan.prefixSHA256,
                    "OBS11_PREFIX_EXACT",
                    frameOrdinal: plan.step - 1)
                let lower = plan.step == 1
                    ? 0
                    : DisposalR19OBS11FrozenPlan.steps[plan.step - 2].bytes
                let frame = source.journal.subdata(in: lower..<plan.bytes)
                try disposalRequireProjection(
                    frame.last == 0x0a &&
                        disposalSHA256(frame) == plan.tailFrameLFSHA256,
                    "OBS11_PREFIX_TAIL_EXACT",
                    frameOrdinal: plan.step - 1)
            }
        }
    }

    private func validate(
        observation: DisposalR19OBS11StepObservation,
        plan: DisposalR19OBS11PlanStep,
        predecessor: DisposalR19OBS11StepObservation?
    ) throws {
        try disposalRequireProjection(
            observation.outputRootPath == plan.finalRoot,
            "OBS11_RESULT_ROOT")
        try disposalRequireProjection(
            observation.sourceBytes == plan.bytes &&
                observation.sourceSHA256 == plan.prefixSHA256 &&
                observation.frameCount == plan.frameCount &&
                observation.tailFrameLFSHA256 == plan.tailFrameLFSHA256,
            "OBS11_RESULT_SOURCE")
        try disposalRequireProjection(
            observation.predecessorProjectionID == predecessor?.projectionID,
            "OBS11_RESULT_PREDECESSOR")
        try disposalRequireProjection(
            observation.machinePrefixJoin == (predecessor == nil
                ? "NOT_APPLICABLE_GENESIS_NO_PREDECESSOR"
                : "PASS_EXACT"),
            "OBS11_RESULT_MACHINE_PREFIX_JOIN")
        try disposalRequireProjection(
            observation.sourceSealed == plan.sourceSealed &&
                observation.terminal == plan.terminal &&
                observation.status == plan.status,
            "OBS11_RESULT_STATUS")
        try disposalRequireProjection(
            observation.authorityVector == "00000000" &&
                !observation.authoritative && !observation.mayFeedController,
            "OBS11_RESULT_AUTHORITY")
        for digest in [
            observation.projectionID, observation.sealSHA256,
            observation.evidenceSHA256, observation.metricsSHA256,
            observation.graphSHA256,
        ] {
            try disposalRequireProjection(
                disposalIsLowerHex(digest, count: 64),
                "OBS11_RESULT_DIGEST")
        }
        try disposalRequireProjection(
            observation.evidenceBytes > 0 && observation.metricsBytes > 0 &&
                observation.graphBytes > 0,
            "OBS11_RESULT_BYTES")
    }

    private func revalidateSourceAndResources(step: Int?) throws {
        try staged(.sourceRevalidation, step: step) { try source.revalidate() }
        try staged(.resourceRevalidation, step: step) { try resources.revalidate() }
    }

    private func revalidateAll(step: Int?) throws {
        try revalidateSourceAndResources(step: step)
        try staged(.projectionRevalidation, step: step) {
            try projection.revalidateAll()
        }
    }

    @discardableResult
    private func appendOrdinary(
        leaf: String,
        payload: [String: DisposalJSONValue],
        stage: DisposalR19OBS11FailureStage,
        step: Int?
    ) throws -> String {
        let ordinal = durableOrdinaryLeaves.count
        let frame = try staged(stage, step: step) {
            try DisposalR19OBS11ReceiptCodec.make(
                chainOrdinal: ordinal,
                leafName: leaf,
                previousFrameWithLFSHA256: previousReceiptSHA256,
                payloadMembers: payload)
        }
        let observed = try staged(stage, step: step) {
            try receipts.appendExact(leaf, frame.bytesWithLF)
        }
        try staged(stage, step: step) {
            try disposalRequireProjection(
                observed == frame.frameWithLFSHA256,
                "OBS11_RECEIPT_RETURNED_SHA")
        }
        durableOrdinaryLeaves.append(leaf)
        previousReceiptSHA256 = observed
        return observed
    }

    private func appendTerminal(
        payload: [String: DisposalJSONValue],
        ordinal: Int,
        stage: DisposalR19OBS11FailureStage
    ) throws {
        let frame = try staged(stage, step: nil) {
            try DisposalR19OBS11ReceiptCodec.make(
                chainOrdinal: ordinal,
                leafName: DisposalR19OBS11FrozenPlan.terminalLeaf,
                previousFrameWithLFSHA256: previousReceiptSHA256,
                payloadMembers: payload)
        }
        let observed = try staged(stage, step: nil) {
            try receipts.appendExact(
                DisposalR19OBS11FrozenPlan.terminalLeaf,
                frame.bytesWithLF)
        }
        try staged(stage, step: nil) {
            try disposalRequireProjection(
                observed == frame.frameWithLFSHA256,
                "OBS11_RECEIPT_RETURNED_SHA")
        }
        previousReceiptSHA256 = observed
    }

    private func publishFailureIfExactPrefix(
        _ failure: DisposalR19OBS11StableFailure
    ) throws {
        guard !durableOrdinaryLeaves.isEmpty,
              receipts.durableLeafNames() == durableOrdinaryLeaves,
              durableOrdinaryLeaves == Array(
                DisposalR19OBS11FrozenPlan.ordinaryLeaves.prefix(
                    durableOrdinaryLeaves.count))
        else { return }
        do {
            let retained = try projection.observeRetainedState(failure.step)
            try appendTerminal(
                payload: failureTerminalPayload(failure, retainedState: retained.state),
                ordinal: durableOrdinaryLeaves.count,
                stage: .receiptTerminal)
            try publishReceiptRoot(
                stage: .receiptPublication,
                retainedNamespaceRevalidation: { try retained.revalidate() })
        } catch {
            // Every prefix is retained. Failure publication is one-shot and is
            // never repaired, removed, or retried.
        }
    }

    private func publishReceiptRoot(
        stage: DisposalR19OBS11FailureStage,
        retainedNamespaceRevalidation: () throws -> Void = {}
    ) throws {
        let expected = durableOrdinaryLeaves + [DisposalR19OBS11FrozenPlan.terminalLeaf]
        try staged(stage, step: nil) {
            try receipts.publish(expected) {
                try source.revalidate()
                try resources.revalidate()
                try projection.revalidateAll()
                try retainedNamespaceRevalidation()
            }
        }
    }

    private func staged<T>(
        _ stage: DisposalR19OBS11FailureStage,
        step: Int?,
        _ body: () throws -> T
    ) throws -> T {
        do {
            return try body()
        } catch let failure as DisposalR19OBS11StableFailure {
            throw failure
        } catch let rejection as DisposalProjectionRejection {
            throw DisposalR19OBS11StableFailure(
                stage: stage, code: rejection.code, step: step)
        } catch {
            throw DisposalR19OBS11StableFailure(
                stage: stage, code: "OBS11_" + stage.rawValue + "_FAILURE", step: step)
        }
    }

    private func commonPayload(
        _ kind: DisposalR19OBS11ReceiptKind
    ) -> [String: DisposalJSONValue] {
        [
            "authoritative": disposalJSONBoolean(false),
            "authority_vector": disposalJSONString("00000000"),
            "c0_blob": disposalJSONString(DisposalR19OBS11FrozenPlan.c0Blob),
            "c0_sha256": disposalJSONString(DisposalR19OBS11FrozenPlan.c0SHA256),
            "chain_id": disposalJSONString(DisposalR19OBS11FrozenPlan.chainID),
            "checkpoint_id": disposalJSONString(DisposalR19OBS11FrozenPlan.checkpointID),
            "gate_e": disposalJSONString("ABSTAIN"),
            "may_feed_controller": disposalJSONBoolean(false),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "receipt_kind": disposalJSONString(kind.rawValue),
            "scientific_outcome": disposalJSONString("ABSTAIN"),
        ]
    }

    private func startPayload() -> [String: DisposalJSONValue] {
        var payload = commonPayload(.start)
        payload["c0_commit"] = disposalJSONString(DisposalR19OBS11FrozenPlan.c0Commit)
        payload["c0_tree"] = disposalJSONString(DisposalR19OBS11FrozenPlan.c0Tree)
        payload["build_identity_state"] = disposalJSONString(
            "ABSTAIN_OUTER_LAUNCH_EVIDENCE_REQUIRED")
        payload["descriptor_soft_limit"] = disposalR19OBS11JSONUInt64(
            source.descriptorSoftLimit)
        payload["descriptor_minimum_required"] = disposalR19OBS11JSONUInt64(
            DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit)
        payload["descriptor_limit_mutated"] = disposalJSONBoolean(false)
        payload["source_bytes"] = disposalJSONNumber(source.journal.count)
        payload["source_logical_path"] = disposalJSONString(
            DisposalR19OBS11FrozenPlan.sourcePath)
        payload["source_sha256"] = disposalJSONString(disposalSHA256(source.journal))
        payload["sqlite_bytes"] = disposalJSONNumber(source.sqliteBytes)
        payload["sqlite_sha256"] = disposalJSONString(source.sqliteSHA256)
        payload["step_count"] = disposalJSONNumber(DisposalR19OBS11FrozenPlan.steps.count)
        payload["receipt_final_root"] = disposalJSONString(
            DisposalR19OBS11FrozenPlan.receiptFinalRoot)
        payload["receipt_staging_root"] = disposalJSONString(
            DisposalR19OBS11FrozenPlan.receiptStagingRoot)
        payload["source_closure"] = disposalR19OBS11JSONArray(
            DisposalR19OBS11FrozenPlan.sourceClosure.map { identity in
                var row: [String: DisposalJSONValue] = [
                    "bytes": disposalJSONNumber(identity.bytes),
                    "device": disposalR19OBS11JSONUInt64(identity.device),
                    "generation": disposalR19OBS11JSONUInt64(UInt64(identity.generation)),
                    "gid": disposalR19OBS11JSONUInt64(UInt64(identity.gid)),
                    "inode": disposalR19OBS11JSONUInt64(identity.inode),
                    "label": disposalJSONString(identity.label),
                    "mode": disposalJSONString(identity.mode),
                    "nlink": disposalR19OBS11JSONUInt64(identity.linkCount),
                    "path": disposalJSONString(identity.path),
                    "uid": disposalR19OBS11JSONUInt64(UInt64(identity.uid)),
                ]
                row["sha256"] = disposalJSONOptionalString(identity.sha256)
                return disposalR19OBS11JSONObject(row)
            })
        payload["rule_resources"] = disposalR19OBS11JSONArray(
            resources.facts.map { resource in
                disposalR19OBS11JSONObject([
                    "bytes": disposalJSONNumber(resource.bytes),
                    "leaf": disposalJSONString(resource.leaf),
                    "sha256": disposalJSONString(resource.sha256),
                ])
            })
        payload["rule_resource_runtime_policy"] = disposalJSONString(
            "HELD_DESCRIPTOR_ROOT_0500_EXACT_FIVE_LEAVES_0400_REVALIDATED_FULL_LIFETIME")
        payload["projection_namespaces"] = disposalR19OBS11JSONArray(
            DisposalR19OBS11FrozenPlan.steps.map { plan in
                disposalR19OBS11JSONObject([
                    "bytes": disposalJSONNumber(plan.bytes),
                    "final_root": disposalJSONString(plan.finalRoot),
                    "frame_count": disposalJSONNumber(plan.frameCount),
                    "prefix_sha256": disposalJSONString(plan.prefixSHA256),
                    "staging_root": disposalJSONString(plan.stagingRoot),
                    "step": disposalJSONNumber(plan.step),
                    "tail_frame_with_lf_sha256": disposalJSONString(
                        plan.tailFrameLFSHA256),
                ])
            })
        payload["runtime_contract"] = disposalR19OBS11JSONObject([
            "argument_count": disposalJSONNumber(1),
            "cwd": disposalJSONString("/private/var/empty"),
            "environment": disposalJSONString("EMPTY_REPLACEMENT"),
            "process_children": disposalJSONNumber(0),
            "stdin": disposalJSONString("/dev/null"),
        ])
        return payload
    }

    private func intentPayload(
        plan: DisposalR19OBS11PlanStep,
        predecessor: DisposalR19OBS11StepObservation?
    ) -> [String: DisposalJSONValue] {
        var payload = commonPayload(.stepIntent)
        payload["step"] = disposalJSONNumber(plan.step)
        payload["prefix_bytes"] = disposalJSONNumber(plan.bytes)
        payload["prefix_sha256"] = disposalJSONString(plan.prefixSHA256)
        payload["tail_frame_with_lf_sha256"] = disposalJSONString(
            plan.tailFrameLFSHA256)
        payload["final_root"] = disposalJSONString(plan.finalRoot)
        payload["staging_root"] = disposalJSONString(plan.stagingRoot)
        payload["predecessor_step"] = plan.predecessorStep.map(disposalJSONNumber)
            ?? .null(disposalZeroSpan)
        payload["predecessor_root"] = disposalJSONOptionalString(
            predecessor?.outputRootPath)
        payload["predecessor_projection_id"] = disposalJSONOptionalString(
            predecessor?.projectionID)
        payload["predecessor_seal_sha256"] = disposalJSONOptionalString(
            predecessor?.sealSHA256)
        payload["expected_source_sealed"] = disposalJSONBoolean(plan.sourceSealed)
        payload["expected_terminal"] = disposalJSONBoolean(plan.terminal)
        payload["expected_status"] = disposalJSONString(plan.status)
        return payload
    }

    private func resultPayload(
        plan: DisposalR19OBS11PlanStep,
        observation: DisposalR19OBS11StepObservation
    ) -> [String: DisposalJSONValue] {
        var payload = commonPayload(.stepResult)
        payload["step"] = disposalJSONNumber(plan.step)
        payload["output_root"] = disposalJSONString(observation.outputRootPath)
        payload["projection_id"] = disposalJSONString(observation.projectionID)
        payload["seal_sha256"] = disposalJSONString(observation.sealSHA256)
        payload["evidence_sha256"] = disposalJSONString(observation.evidenceSHA256)
        payload["metrics_sha256"] = disposalJSONString(observation.metricsSHA256)
        payload["graph_sha256"] = disposalJSONString(observation.graphSHA256)
        payload["evidence_bytes"] = disposalJSONNumber(observation.evidenceBytes)
        payload["metrics_bytes"] = disposalJSONNumber(observation.metricsBytes)
        payload["graph_bytes"] = disposalJSONNumber(observation.graphBytes)
        payload["source_sha256"] = disposalJSONString(observation.sourceSHA256)
        payload["source_bytes"] = disposalJSONNumber(observation.sourceBytes)
        payload["frame_count"] = disposalJSONNumber(observation.frameCount)
        payload["tail_frame_with_lf_sha256"] = disposalJSONString(
            observation.tailFrameLFSHA256)
        payload["predecessor_projection_id"] = disposalJSONOptionalString(
            observation.predecessorProjectionID)
        payload["source_sealed"] = disposalJSONBoolean(observation.sourceSealed)
        payload["terminal"] = disposalJSONBoolean(observation.terminal)
        payload["status"] = disposalJSONString(observation.status)
        payload["reader_admission"] = disposalJSONString("PASS_EXACT")
        payload["machine_prefix_join"] = disposalJSONString(
            observation.machinePrefixJoin)
        return payload
    }

    private func successTerminalPayload(
        merkleRoot: String
    ) -> [String: DisposalJSONValue] {
        var payload = commonPayload(.terminalSuccess)
        payload["mechanics_status"] = disposalJSONString(
            "PASS_EXACT_NONAUTHORITATIVE_1_TO_8_CHAIN")
        payload["completed_steps"] = disposalJSONNumber(observations.count)
        payload["result_merkle_leaf_count"] = disposalJSONNumber(
            resultReceiptSHA256s.count)
        payload["result_merkle_root_sha256"] = disposalJSONString(merkleRoot)
        payload["result_frame_with_lf_sha256s"] = disposalR19OBS11JSONArray(
            resultReceiptSHA256s.map(disposalJSONString))
        payload["projection_ids"] = disposalR19OBS11JSONArray(
            observations.map { disposalJSONString($0.projectionID) })
        payload["projection_seal_sha256s"] = disposalR19OBS11JSONArray(
            observations.map { disposalJSONString($0.sealSHA256) })
        payload["full_chain_revalidation"] = disposalJSONString("PASS_EXACT")
        return payload
    }

    private func failureTerminalPayload(
        _ failure: DisposalR19OBS11StableFailure,
        retainedState: DisposalR19OBS11RetainedNamespaceState
    ) -> [String: DisposalJSONValue] {
        var payload = commonPayload(.terminalFailure)
        payload["mechanics_status"] = disposalJSONString(
            "FAIL_CONSUMED_RETAINED_PREFIX")
        payload["failure_stage"] = disposalJSONString(failure.stage.rawValue)
        payload["failure_code"] = disposalJSONString(failure.code)
        payload["failure_step"] = failure.step.map(disposalJSONNumber)
            ?? .null(disposalZeroSpan)
        payload["durable_nonterminal_prefix_count"] = disposalJSONNumber(
            durableOrdinaryLeaves.count)
        payload["completed_result_steps"] = disposalJSONNumber(
            resultReceiptSHA256s.count)
        payload["highest_completed_result_step"] = resultReceiptSHA256s.isEmpty
            ? .null(disposalZeroSpan)
            : disposalJSONNumber(resultReceiptSHA256s.count)
        payload["retained_projection_roots"] = disposalR19OBS11JSONArray(
            observations.map { disposalJSONString($0.outputRootPath) })
        payload["current_namespace_step"] = retainedState.step.map(disposalJSONNumber)
            ?? .null(disposalZeroSpan)
        let currentPlan = retainedState.step.flatMap { step in
            DisposalR19OBS11FrozenPlan.steps.indices.contains(step - 1)
                ? DisposalR19OBS11FrozenPlan.steps[step - 1]
                : nil
        }
        payload["current_final_root"] = disposalJSONOptionalString(currentPlan?.finalRoot)
        payload["current_staging_root"] = disposalJSONOptionalString(currentPlan?.stagingRoot)
        payload["current_final_root_state"] = disposalJSONString(
            retainedState.finalRootState)
        payload["current_staging_root_state"] = disposalJSONString(
            retainedState.stagingRootState)
        payload["current_namespace_origin_proof"] = disposalJSONString(
            retainedState.originProof)
        payload["current_namespace_snapshot_sha256"] = disposalJSONOptionalString(
            retainedState.snapshotSHA256)
        payload["current_namespace_snapshot_components"] = retainedState.snapshotComponents
            .map { disposalR19OBS11JSONArray($0.map(disposalJSONString)) }
            ?? .null(disposalZeroSpan)
        payload["result_merkle_leaf_count"] = disposalJSONNumber(
            resultReceiptSHA256s.count)
        if resultReceiptSHA256s.isEmpty {
            payload["result_merkle_root_sha256"] = .null(disposalZeroSpan)
        } else {
            payload["result_merkle_root_sha256"] = disposalJSONString(
                prefixMerkleRoot(resultReceiptSHA256s))
        }
        return payload
    }

    private func prefixMerkleRoot(_ digests: [String]) -> String {
        let leaves = digests.enumerated().map { index, digest in
            disposalLengthFramedID(
                DisposalR19OBS11ReceiptMerkle.leafDomain,
                [DisposalR19OBS11ReceiptMerkle.chainDomain, String(index + 1), digest])
        }
        func subtree(_ values: ArraySlice<String>) -> String {
            if values.count == 1 { return values.first! }
            var split = 1
            while split * 2 < values.count { split *= 2 }
            let boundary = values.index(values.startIndex, offsetBy: split)
            return disposalLengthFramedID(
                DisposalR19OBS11ReceiptMerkle.nodeDomain,
                [
                    DisposalR19OBS11ReceiptMerkle.chainDomain,
                    subtree(values[..<boundary]),
                    subtree(values[boundary...]),
                ])
        }
        return subtree(leaves[...])
    }
}

private final class DisposalR19OBS11ProductionProjectionPort {
    private let resources: DisposalProjectionRuleResources
    private var held: [DisposalValidatedProjection] = []
    private var currentOwnership: (
        step: Int,
        token: DisposalOutputNamespaceOwnership
    )?

    init(resources: DisposalProjectionRuleResources) {
        self.resources = resources
    }

    func preflightAllAbsent() throws {
        for path in DisposalR19OBS11FrozenPlan.steps.flatMap({
            [$0.finalRoot, $0.stagingRoot]
        }) {
            var state = stat()
            errno = 0
            try disposalRequireProjection(
                lstat(path, &state) != 0 && errno == ENOENT,
                "OBS11_OUTPUT_NAMESPACE_NOT_ABSENT",
                detail: path)
        }
    }

    func buildAndAdmit(
        step: DisposalR19OBS11PlanStep,
        request: DisposalProjectionSetRequest
    ) throws -> DisposalR19OBS11StepObservation {
        currentOwnership = nil
        let report = try DisposalProjectionSetBuilder.buildFrozen(
            request: request,
            outputRootPath: step.finalRoot,
            resources: resources,
            outputAdmission: { [self] token in
                currentOwnership = (step: step.step, token: token)
            })
        var staging = stat()
        errno = 0
        try disposalRequireProjection(
            lstat(step.stagingRoot, &staging) != 0 && errno == ENOENT,
            "OBS11_OUTPUT_STAGING_REMAINS")
        let validated = try DisposalProjectionReader.validateExact(
            rootPath: step.finalRoot,
            expectedSealSHA256: report.sealSHA256,
            resources: resources)
        try validateReport(report, validated: validated, step: step)
        let machinePrefixJoin: String
        if let predecessor = held.last {
            try disposalR19OBS11ValidatePublicMachinePrefix(
                predecessor.snapshot,
                successor: validated.snapshot)
            machinePrefixJoin = "PASS_EXACT"
        } else {
            machinePrefixJoin = "NOT_APPLICABLE_GENESIS_NO_PREDECESSOR"
        }
        held.append(validated)
        return .init(
            outputRootPath: report.outputRootPath,
            projectionID: report.projectionID,
            sealSHA256: report.sealSHA256,
            evidenceSHA256: report.evidenceSHA256,
            metricsSHA256: report.metricsSHA256,
            graphSHA256: report.graphSHA256,
            evidenceBytes: report.evidenceBytes,
            metricsBytes: report.metricsBytes,
            graphBytes: report.graphBytes,
            sourceSHA256: validated.snapshot.metadata.sourceSHA256,
            sourceBytes: validated.snapshot.metadata.sourceBytes,
            frameCount: validated.snapshot.metadata.frameCount,
            tailFrameLFSHA256: validated.snapshot.frames.last?.rawWithLFSHA256 ?? "",
            predecessorProjectionID: validated.snapshot.metadata.predecessorProjectionID,
            sourceSealed: validated.snapshot.metadata.sourceSealed,
            terminal: validated.snapshot.metadata.terminal,
            status: validated.snapshot.metadata.status,
            authorityVector: validated.snapshot.metadata.authorityVector,
            authoritative: validated.snapshot.metadata.authoritative,
            mayFeedController: validated.snapshot.metadata.mayFeedController,
            machinePrefixJoin: machinePrefixJoin)
    }

    func revalidateAll() throws {
        for projection in held { try projection.held.revalidate() }
    }

    func observeRetainedState(
        step: Int?
    ) throws -> DisposalR19OBS11RetainedNamespaceHold {
        guard let step,
              DisposalR19OBS11FrozenPlan.steps.indices.contains(step - 1)
        else {
            return DisposalR19OBS11RetainedNamespaceHold(
                state: .init(
                    step: nil,
                    finalRootState: "NOT_APPLICABLE",
                    stagingRootState: "NOT_APPLICABLE",
                    originProof: "NOT_APPLICABLE_NO_CURRENT_STEP",
                    snapshotSHA256: nil,
                    snapshotComponents: nil),
                revalidate: {})
        }
        let plan = DisposalR19OBS11FrozenPlan.steps[step - 1]
        let ownership = currentOwnership.flatMap {
            $0.step == step ? $0.token : nil
        }
        let held = try DisposalR19OBS11HeldNamespacePair(
            plan: plan,
            ownership: ownership)
        return DisposalR19OBS11RetainedNamespaceHold(
            state: held.state,
            revalidate: { try held.revalidate() })
    }

    private func validateReport(
        _ report: DisposalProjectionSetReport,
        validated: DisposalValidatedProjection,
        step: DisposalR19OBS11PlanStep
    ) throws {
        let snapshot = validated.snapshot
        try disposalRequireProjection(report.outputRootPath == step.finalRoot, "OBS11_REPORT_ROOT")
        try disposalRequireProjection(
            report.evidencePath == step.finalRoot + "/" + DisposalProjectionSetV1.evidenceLeaf &&
                report.metricsPath == step.finalRoot + "/" + DisposalProjectionSetV1.metricsLeaf &&
                report.graphPath == step.finalRoot + "/" + DisposalProjectionSetV1.graphLeaf &&
                report.sealPath == step.finalRoot + "/" + DisposalProjectionSetV1.sealLeaf,
            "OBS11_REPORT_PATHS")
        try disposalRequireProjection(
            report.projectionID == snapshot.metadata.projectionID &&
                report.sealSHA256 == snapshot.metadata.sealSHA256 &&
                report.evidenceSHA256 == snapshot.metadata.evidenceSHA256 &&
                report.metricsSHA256 == snapshot.metadata.metricsSHA256 &&
                report.graphSHA256 == snapshot.metadata.graphSHA256,
            "OBS11_REPORT_READER_DIGEST_JOIN")
        try disposalRequireProjection(
            report.evidenceBytes == validated.held.evidence.count &&
                report.metricsBytes == validated.held.metrics.count &&
                report.graphBytes == validated.held.graph.count,
            "OBS11_REPORT_READER_BYTE_JOIN")
        try disposalRequireProjection(
            report.frameCount == snapshot.metadata.frameCount &&
                report.sourceSealed == snapshot.metadata.sourceSealed &&
                report.terminal == snapshot.metadata.terminal &&
                report.status == snapshot.metadata.status &&
                report.authorityVector == snapshot.metadata.authorityVector,
            "OBS11_REPORT_READER_STATE_JOIN")
    }
}

func disposalR19OBS11ValidatePublicMachinePrefix(
    _ predecessor: DisposalProjectionSnapshot,
    successor: DisposalProjectionSnapshot
) throws {
    let maximumOrdinal = predecessor.metadata.frameCount - 1
    let states = successor.machineStates.filter { $0.prefixOrdinal <= maximumOrdinal }
    try disposalRequireProjection(
        predecessor.machineStates == states,
        "OBS11_PUBLIC_MACHINE_PREFIX_STATES")
    let stateIDs = Set(states.map(\.id))
    let transitions = successor.machineTransitions.filter { stateIDs.contains($0.toStateID) }
    try disposalRequireProjection(
        predecessor.machineTransitions == transitions,
        "OBS11_PUBLIC_MACHINE_PREFIX_TRANSITIONS")
    let transitionIDs = Set(transitions.map(\.id))
    try disposalRequireProjection(
        predecessor.machinePredicates == successor.machinePredicates.filter {
            transitionIDs.contains($0.transitionID)
        },
        "OBS11_PUBLIC_MACHINE_PREFIX_PREDICATES")
    let witnesses = successor.machineWitnesses.filter {
        $0.visiblePrefixOrdinal <= maximumOrdinal
    }
    try disposalRequireProjection(
        predecessor.machineWitnesses == witnesses,
        "OBS11_PUBLIC_MACHINE_PREFIX_WITNESSES")
    let witnessIDs = Set(witnesses.map(\.id))
    try disposalRequireProjection(
        predecessor.machineMerkleLeaves == successor.machineMerkleLeaves.filter {
            stateIDs.contains($0.stateID)
        },
        "OBS11_PUBLIC_MACHINE_PREFIX_MERKLE")
    let allowed = stateIDs.union(transitionIDs).union(witnessIDs)
    try disposalRequireProjection(
        predecessor.machineEdges == successor.machineEdges.filter {
            allowed.contains($0.fromNodeID) && allowed.contains($0.toNodeID)
        },
        "OBS11_PUBLIC_MACHINE_PREFIX_EDGES")
}

package enum DisposalR19OBS11ProjectionChain {
    package static func runFrozen() throws {
        let descriptorSoftLimit = try disposalR19OBS11AdmitOpenFileBudget()
        let heldSource = try DisposalHeldR19Source.admitFrozenOBS11()
        let heldResources = try DisposalHeldProjectionRuleResources.admitFrozen()
        let production = DisposalR19OBS11ProductionProjectionPort(
            resources: heldResources.resources)
        try production.preflightAllAbsent()
        let receiptJournal = try DisposalDurableReceiptJournal.admitFrozenOBS11()
        let coordinator = DisposalR19OBS11ProjectionChainCoordinator(
            source: .init(
                journal: heldSource.journal,
                sqliteBytes: heldSource.sqlite.count,
                sqliteSHA256: disposalSHA256(heldSource.sqlite),
                descriptorSoftLimit: descriptorSoftLimit,
                revalidate: { try heldSource.revalidate() }),
            projection: .init(
                preflightAllAbsent: { try production.preflightAllAbsent() },
                buildAndAdmit: { try production.buildAndAdmit(step: $0, request: $1) },
                revalidateAll: { try production.revalidateAll() },
                observeRetainedState: {
                    try production.observeRetainedState(step: $0)
                }),
            receipts: .init(
                appendExact: {
                    try receiptJournal.appendExact(leaf: $0, frameWithLF: $1)
                },
                durableLeafNames: { receiptJournal.durableLeafNames },
                publish: {
                    try receiptJournal.publish(
                        expectedLeaves: $0,
                        afterPreparedRevalidation: $1)
                }),
            resources: .init(
                facts: disposalR19OBS11ObserveRuleResources(
                    heldResources.resources),
                revalidate: { try heldResources.revalidate() }))
        try coordinator.run()
    }
}

private func disposalR19OBS11ObserveRuleResources(
    _ resources: DisposalProjectionRuleResources
) -> [DisposalR19OBS11FrozenResource] {
    [
        .init(
            leaf: "001-evidence.sql",
            bytes: resources.evidenceDDL.count,
            sha256: disposalSHA256(resources.evidenceDDL)),
        .init(
            leaf: "001-graph.sql",
            bytes: resources.graphDDL.count,
            sha256: disposalSHA256(resources.graphDDL)),
        .init(
            leaf: "001-metrics.sql",
            bytes: resources.metricsDDL.count,
            sha256: disposalSHA256(resources.metricsDDL)),
        .init(
            leaf: "disposal-adapters.v1.json",
            bytes: resources.adapters.count,
            sha256: disposalSHA256(resources.adapters)),
        .init(
            leaf: "disposal-lattice.v1.json",
            bytes: resources.lattice.count,
            sha256: disposalSHA256(resources.lattice)),
    ]
}

private func disposalR19OBS11AdmitOpenFileBudget() throws -> UInt64 {
    var limits = rlimit()
    guard getrlimit(RLIMIT_NOFILE, &limits) == 0 else {
        throw DisposalProjectionRejection(
            code: "OBS11_DESCRIPTOR_LIMIT_READ",
            detail: String(cString: strerror(errno)))
    }
    let softLimit = UInt64(limits.rlim_cur)
    try disposalRequireProjection(
        softLimit >= DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
        "OBS11_DESCRIPTOR_LIMIT_INSUFFICIENT")
    return softLimit
}

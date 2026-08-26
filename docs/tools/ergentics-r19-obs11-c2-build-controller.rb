#!/usr/bin/ruby

# Closed local C2 build-identity controller. This source is inert until a
# successor readiness record freezes its exact bytes and an invocation is
# separately approved. It never executes the built product and never changes
# the Driver V2 evidence ledger or an authority bit.

BOOTSTRAP_ENVIRONMENT = {
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

unless ARGV.empty? && ENV.to_h == BOOTSTRAP_ENVIRONMENT
  exit!(77)
end

require "base64"
require "digest"
require "fcntl"
require "fiddle/import"
require "json"
require "set"

Thread.abort_on_exception = false

class C2Failure < StandardError
  attr_reader :code, :consumed

  def initialize(code, consumed: true)
    @code = code
    @consumed = consumed
    super(code)
  end
end

class C2ContainmentRequired < C2Failure; end

def c2_fail(code, consumed: true)
  raise C2Failure.new(code, consumed: consumed)
end

REPOSITORY =
  "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" \
  ".phase-a-v2-fixture-identity-restore-only-staging"
PACKAGE = "#{REPOSITORY}/Observability/ErgenticsInterface"
SOURCE_LOCAL_DOT_BUILD = "#{PACKAGE}/.build"
CONTROL_RECORD =
  "#{REPOSITORY}/artifacts/" \
  "r19-obs11-retained-r19-projection-chain-2026-08-26/" \
  "r19-obs11-c2-controller-control-freeze.v1.json"

CONTROL_COMMIT = "f7baf3997a98cd9ae34da2cb835c429b6c58dd10"
CONTROL_TREE = "5a2434d5610de7981b8f8d00714651a8cee6e0b5"
CONTROL_RECORD_BYTES = 20_265
CONTROL_RECORD_SHA256 =
  "caa6ed8a9cac827efe55ae36bf8fc2ac946a7c6fdd4e004f0d963836aa2e6932"
SOURCE_MANIFEST_SHA256 =
  "c70113ab48c0018680ed2d217767eea1790f41c567661ee28beaa11b8532fd35"
SOURCE_MANIFEST_FILES = 37
SOURCE_MANIFEST_BYTES = 1_028_302

PRIVATE_TMP = "/private/tmp"
BUILD_A_ROOT =
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-a-v1"
BUILD_B_ROOT =
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-b-v1"
EXECUTION_CLOSURE_ROOT =
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-" \
  "execution-closure-v1"
BUILD_B_WITNESS_ROOT =
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-" \
  "build-b-witness-closure-v1"
JOURNAL_ROOT =
  "/private/tmp/ergentics-r19-obs11-c2-build-control-8405636a-v1"
ALL_FROZEN_ROOTS = [
  BUILD_A_ROOT, BUILD_B_ROOT, EXECUTION_CLOSURE_ROOT,
  BUILD_B_WITNESS_ROOT, JOURNAL_ROOT,
].freeze

PRODUCT_LEAF = "ErgenticsR19OBS11ProjectionChain"
RESOURCE_ROOT_LEAF = "ErgenticsR19OBS11ProjectionChain.resources.v1"
BUILD_TRIPLE = "arm64-apple-macosx"
BUILD_CONFIGURATION = "release"
PRODUCT_RELATIVE =
  "scratch/#{BUILD_TRIPLE}/#{BUILD_CONFIGURATION}/#{PRODUCT_LEAF}"
PLAN_RELATIVE = "scratch/#{BUILD_CONFIGURATION}.yaml"
LINK_LIST_RELATIVE =
  "scratch/#{BUILD_TRIPLE}/#{BUILD_CONFIGURATION}/" \
  "#{PRODUCT_LEAF}.product/Objects.LinkFileList"
CORE_SOURCES_RELATIVE =
  "scratch/#{BUILD_TRIPLE}/#{BUILD_CONFIGURATION}/" \
  "DisposalProjectionCore.build/sources"
RUNNER_SOURCES_RELATIVE =
  "scratch/#{BUILD_TRIPLE}/#{BUILD_CONFIGURATION}/" \
  "#{PRODUCT_LEAF}.build/sources"

EXPECTED_UID = 501
EXPECTED_EGID = 20
EXPECTED_GROUPS = [
  12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398,
  399, 400, 701,
].freeze
DEVNULL_IDENTITY = {
  "device" => -458_678_049,
  "gid" => 0,
  "inode" => 336,
  "mode" => "0666",
  "nlink" => 1,
  "rdev" => 50_331_650,
  "uid" => 0,
}.freeze
BUILD_ROOT_GID = 0
RUNTIME_CLOSURE_GID = 20

SWIFT_PACKAGE =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/swift-package"
SWIFT_BUILD =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/swift-build"
SWIFTC =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/swiftc"
SWIFT_FRONTEND =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/swift-frontend"
SWIFT_DRIVER =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/swift-driver"
CLANG =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/clang"
LD =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/ld"
SDK =
  "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/" \
  "Developer/SDKs/MacOSX26.5.sdk"
SDK_RESOLVED =
  "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/" \
  "Developer/SDKs/MacOSX.sdk"
SDK_SETTINGS_JSON = "#{SDK_RESOLVED}/SDKSettings.json"
SDK_SETTINGS_PLIST = "#{SDK_RESOLVED}/SDKSettings.plist"
XCODE_VERSION_PLIST = "/Applications/Xcode.app/Contents/version.plist"
XCODE_INFO_PLIST = "/Applications/Xcode.app/Contents/Info.plist"

MAPPED_EXECUTABLE_EXPECTED = {
  "/usr/bin/ruby" => {
    "absolute_file_offset" => 65_536,
    "uuid_hex" => "eb2540b7e13236beb719619d0fbf7203".freeze,
  }.freeze,
  SWIFT_PACKAGE => {
    "absolute_file_offset" => 0,
    "uuid_hex" => "561f67557606396f9382b01d5cc7edfb".freeze,
  }.freeze,
}.freeze

TOOL_EXPECTED = {
  "/usr/bin/ruby" => [135_200,
    "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c",
    {"device" => 16_777_231, "inode" => 1_152_921_500_312_572_705,
      "mode" => "0555", "uid" => 0, "gid" => 0, "nlink" => 1}],
  SWIFT_PACKAGE => [23_293_616,
    "dc1a5f5bd4f05be81b8cc4a4bc6e0fd8846210e4cb829062d0fed3d03f79b753",
    {"device" => 16_777_231, "inode" => 1_118_471,
      "mode" => "0755", "uid" => 0, "gid" => 0, "nlink" => 1}],
  SWIFT_FRONTEND => [171_036_592,
    "2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb",
    {"device" => 16_777_231, "inode" => 1_118_375,
      "mode" => "0755", "uid" => 0, "gid" => 0, "nlink" => 1}],
  SWIFT_DRIVER => [3_011_968,
    "fead52ebe00ec6ec700ecbb4be30f0b6204dd0506cb271dda72ac257261bd64b",
    {"device" => 16_777_231, "inode" => 1_118_459,
      "mode" => "0755", "uid" => 0, "gid" => 0, "nlink" => 1}],
  CLANG => [141_373_024,
    "7def90dd8829726686213a747fc5bff1583df933dae5edc55d755479e0bfe00a",
    {"device" => 16_777_231, "inode" => 1_118_318,
      "mode" => "0755", "uid" => 0, "gid" => 0, "nlink" => 1}],
  LD => [2_331_792,
    "5897b275efd93b201b6df5832dd541262b3f20f290859ba78f2200a6a66ef38b",
    {"device" => 16_777_231, "inode" => 1_118_358,
      "mode" => "0755", "uid" => 0, "gid" => 0, "nlink" => 1}],
  SDK_SETTINGS_JSON => [7_774,
    "f8d005f09381389167f9e0aeaa169bc9e7dff162ef22ca2fd8e98df7ff1acafe",
    {"device" => 16_777_231, "inode" => 1_082_899,
      "mode" => "0644", "uid" => 0, "gid" => 0, "nlink" => 1}],
  SDK_SETTINGS_PLIST => [5_388,
    "e5c7c40b8c5dc1a9f99f8b9fa51870f8fe180421225b8201d0c4c826aad11bdc",
    {"device" => 16_777_231, "inode" => 1_046_242,
      "mode" => "0644", "uid" => 0, "gid" => 0, "nlink" => 1}],
  XCODE_VERSION_PLIST => [523,
    "951ddf34d65d84d57684bd083ca7deebf8d5722eefb074f3cdf00f8304d5f511",
    {"device" => 16_777_231, "inode" => 1_147_463,
      "mode" => "0644", "uid" => 0, "gid" => 0, "nlink" => 1}],
  XCODE_INFO_PLIST => [33_286,
    "224c27a718df1d8b4e785d29d06259e0a9326c424e70d30efab9c587463f719a",
    {"device" => 16_777_231, "inode" => 1_147_460,
      "mode" => "0644", "uid" => 0, "gid" => 0, "nlink" => 1}],
  CONTROL_RECORD => [CONTROL_RECORD_BYTES, CONTROL_RECORD_SHA256,
    {"device" => 16_777_231, "inode" => 17_945_099,
      "mode" => "0644", "uid" => 501, "gid" => 20, "nlink" => 1}],
}.freeze

SYMLINK_EXPECTED = {
  SWIFT_BUILD => {
    "device" => 16_777_231, "gid" => 0, "inode" => 1_118_475,
    "mode" => "0755", "nlink" => 1, "target" => "swift-package",
    "uid" => 0,
  },
  SWIFTC => {
    "device" => 16_777_231, "gid" => 0, "inode" => 1_118_435,
    "mode" => "0755", "nlink" => 1, "target" => "swift-frontend",
    "uid" => 0,
  },
  SDK => {
    "device" => 16_777_231, "gid" => 0, "inode" => 1_082_900,
    "mode" => "0755", "nlink" => 1, "target" => "MacOSX.sdk",
    "uid" => 0,
  },
}.freeze

SYSTEM_DIRECTORY_EXPECTED = {
  SDK_RESOLVED => {
    "device" => 16_777_231, "gid" => 0, "inode" => 1_009_705,
    "mode" => "0755", "nlink" => 7, "uid" => 0,
  },
  "/private/var/empty" => {
    "device" => 16_777_231, "gid" => 3, "inode" => 774_080,
    "mode" => "0755", "nlink" => 2, "uid" => 0,
  },
}.freeze

SOURCE_MANIFEST_TEXT = <<~'MANIFEST'.freeze
  Package.swift	2177	c9cd9e7d8f96ca326dfa6e90947ae35b4a0fa84fcd3024f2c602a1cf2174d835
  Sources/DisposalProjectionCore/DisposalCanonicalJSON.swift	13746	214a7b59bcfbce4ae7d23b823b957e8c037de8b68f0d95a9ef47795883373974
  Sources/DisposalProjectionCore/DisposalConservationSetMerkle.swift	6642	bee95754846fd91b496795de01d8d5b5b3a68736550020e2c11140d3a52f449b
  Sources/DisposalProjectionCore/DisposalDurableReceiptJournal.swift	26201	1fea41b10017afaa73534c9796c4412b3512c8d766965bf076fe436d14cc147c
  Sources/DisposalProjectionCore/DisposalEventJournal.swift	20889	0d68792d79ed59c524a256b79af0406134ed89835e761ec7f573a20030edcf9a
  Sources/DisposalProjectionCore/DisposalEvidenceBuilder.swift	25553	c543a344d5fb81ab455b6eaa9dec931fb2c27443226fdb3810f73397f9a902c3
  Sources/DisposalProjectionCore/DisposalExecutableRelativeResourceRoot.swift	3929	5d7ba6889ac88d3ee0df170938da508cba608dcaac1b0e56c5a3a44c0ae59c67
  Sources/DisposalProjectionCore/DisposalGraphBuilder.swift	157113	139d41bf5ff22e89a9536c2a9afe0ec0e7b025f5d78c08250ca54f0d1e7ad583
  Sources/DisposalProjectionCore/DisposalHeldProjectionSet.swift	20414	4a46b2863e5883da943ea8b2cd92046d5bb93b31384616331d4ef11808d9b716
  Sources/DisposalProjectionCore/DisposalHeldR19Source.swift	17673	2c5c7a6de1b5024c890318a3baeb45a25144ffd0c8eab3f3eac2429a2d16f554
  Sources/DisposalProjectionCore/DisposalJournalAdmission.swift	4630	9f50843e021251a8451a617ec6280ad80b59c74769e0e107c5875e35227cc1aa
  Sources/DisposalProjectionCore/DisposalMetricsBuilder.swift	39723	58022b73c8310b3eb2ba69ea450f6b702c18c16427d0f56aa41cb696e3ee0481
  Sources/DisposalProjectionCore/DisposalProjectionEmbeddedResources.swift	171165	0fa14ffd865aaa37b6f4608401d90b503991b9de039189628e1705619f582c7d
  Sources/DisposalProjectionCore/DisposalProjectionModels.swift	4421	4f196d86d92d8e6a496d733068fc026f16dbe6126d1493b6cf61c839843cd5b3
  Sources/DisposalProjectionCore/DisposalProjectionPredecessorAdmission.swift	9113	13b9b75c60141cf8d287a66a29b4601fb038bc36685d588ff6cb9340d473f592
  Sources/DisposalProjectionCore/DisposalProjectionReader.swift	58345	8c6faf8307d5b08b92ac0f910b755206eb140dd3710f98f2522afff7007f72a0
  Sources/DisposalProjectionCore/DisposalProjectionReaderModels.swift	10771	50609003d0a086c2b047fb7ee691c12083011125dc08e4030fbe51ea644a483f
  Sources/DisposalProjectionCore/DisposalProjectionRuleResources.swift	22374	c69e337288323cfc08f595d82ba4445ec941ac8dabdce97ea2f1164ffdd44968
  Sources/DisposalProjectionCore/DisposalProjectionSetBuilder.swift	13769	609e71dbd8cc53eb2f6eb743ca6ec9b17c34008aeaf3de8d44cc9267378a934c
  Sources/DisposalProjectionCore/DisposalProjectionSetModels.swift	4540	28e68a5bc7dca114a499f3ece8525a71019759ce2fd92213102d7719a364fa76
  Sources/DisposalProjectionCore/DisposalProjectionSourceAdapter.swift	40236	315bbf1a5c71fe5675d97c6b0c74da0d09a4de6936c68060a34768a6f4c1579e
  Sources/DisposalProjectionCore/DisposalProjectionUtilities.swift	6173	0806521bd82330edb5f723205500eed4a79ed960c5cbb25313218dd9ddfd6b80
  Sources/DisposalProjectionCore/DisposalR19OBS11HeldNamespacePair.swift	24706	96a3fc3bb76c9fd879b5f9a3ff3da35e16706ff0ac41d3f39df3e4bbd9a22306
  Sources/DisposalProjectionCore/DisposalR19OBS11ProjectionChain.swift	50562	752ecf3bcc7845cc4a7c6ae89a7a2077e4b0cf2cce8d72a9781c7b223789a112
  Sources/DisposalProjectionCore/DisposalR19OBS11ReceiptFrames.swift	13688	a218467787596abb51c253b0831316fe0e6f72ca145bf0d8a134796cf4400f77
  Sources/DisposalProjectionCore/DisposalRational.swift	10830	f7d7eedd80f336b14fbe074fc39fea7a8b01bb41be20283acf41b678a9211c3c
  Sources/DisposalProjectionCore/DisposalSQLite.swift	10173	d2db99e27faf36b5c8e96bd7ee2020a3a929814d2069d7ac22f6bbfbff8a7bc6
  Sources/DisposalProjectionCore/DisposalSealedArtifactSet.swift	27119	a073e5bb9ef07229f58ad95d774465985d95cbf89c2130aebfd56182eaf7f02b
  Sources/DisposalProjectionCore/DisposalTypedProcessEvidence.swift	97319	516efa6441a3278bee33e0fef5ef903f9c2c551cbd3773243aa30273d1a7dc8b
  Sources/DisposalProjectionCore/Resources/001-evidence.sql	50706	f3e003136aa4f9a12308d310ffa6bc92d71bccb99a7a50656c32231b79a435c7
  Sources/DisposalProjectionCore/Resources/001-graph.sql	41517	f65eb702e528f851bfd3bcce2817258dfdc5779132bba780964c82c0d752009e
  Sources/DisposalProjectionCore/Resources/001-metrics.sql	12119	eda615d5bc71246c54d7335679f641646e11c8938ef01a459cf168be2aa5ce61
  Sources/DisposalProjectionCore/Resources/disposal-adapters.v1.json	4610	68e09200dd29a47fcbe49e083df41fe55ead950198edf75300ab6e302b61be1b
  Sources/DisposalProjectionCore/Resources/disposal-lattice.v1.json	1937	c99361cb2052032e176b1ab5cd22898a67231b98bdea8c972388bdeab12ba022
  Sources/DisposalProjectionPrimitivesC/DisposalProjectionPrimitivesC.c	1210	23be91a9b415b28730f3810be214706db40c7ba7e8627bb8fbc20111f0e8eede
  Sources/DisposalProjectionPrimitivesC/include/DisposalProjectionPrimitivesC.h	610	f38cd093da4a23e55fcc436e47efcfd598cb5c3473814575e351fd9eb67805e0
  Sources/ErgenticsR19OBS11ProjectionChain/main.swift	1599	3df10dfd1235ef5bc8f4d042c27bea062a226fb6fac66cc61fb31d8ce936a55a
MANIFEST

SOURCE_EXPECTED = SOURCE_MANIFEST_TEXT.lines.to_h do |line|
  relative, bytes, sha256 = line.chomp.split("\t", 3)
  ["#{PACKAGE}/#{relative}", {"relative" => relative,
    "bytes" => Integer(bytes, 10), "sha256" => sha256}]
end.freeze

DIRECTORY_INVENTORIES = {
  PACKAGE => %w[.build Package.swift Sources Tests],
  "#{PACKAGE}/Sources" => %w[
    DisposalProjectionCore DisposalProjectionPrimitivesC
    ErgenticsDisposalProjector ErgenticsInterface ErgenticsLedgerProjector
    ErgenticsR19OBS11ProjectionChain LedgerProjectionCore
  ],
  "#{PACKAGE}/Sources/DisposalProjectionCore" => %w[
    DisposalCanonicalJSON.swift DisposalConservationSetMerkle.swift
    DisposalDurableReceiptJournal.swift DisposalEventJournal.swift
    DisposalEvidenceBuilder.swift DisposalExecutableRelativeResourceRoot.swift
    DisposalGraphBuilder.swift DisposalHeldProjectionSet.swift
    DisposalHeldR19Source.swift DisposalJournalAdmission.swift
    DisposalMetricsBuilder.swift DisposalProjectionEmbeddedResources.swift
    DisposalProjectionModels.swift DisposalProjectionPredecessorAdmission.swift
    DisposalProjectionReader.swift DisposalProjectionReaderModels.swift
    DisposalProjectionRuleResources.swift DisposalProjectionSetBuilder.swift
    DisposalProjectionSetModels.swift DisposalProjectionSourceAdapter.swift
    DisposalProjectionUtilities.swift DisposalR19OBS11HeldNamespacePair.swift
    DisposalR19OBS11ProjectionChain.swift DisposalR19OBS11ReceiptFrames.swift
    DisposalRational.swift DisposalSQLite.swift DisposalSealedArtifactSet.swift
    DisposalTypedProcessEvidence.swift Resources
  ],
  "#{PACKAGE}/Sources/DisposalProjectionCore/Resources" => %w[
    001-evidence.sql 001-graph.sql 001-metrics.sql
    disposal-adapters.v1.json disposal-lattice.v1.json
  ],
  "#{PACKAGE}/Sources/DisposalProjectionPrimitivesC" => %w[
    DisposalProjectionPrimitivesC.c include
  ],
  "#{PACKAGE}/Sources/DisposalProjectionPrimitivesC/include" =>
    %w[DisposalProjectionPrimitivesC.h],
  "#{PACKAGE}/Sources/ErgenticsDisposalProjector" => %w[main.swift],
  "#{PACKAGE}/Sources/ErgenticsInterface" => %w[
    DisposalProjectionViews.swift ErgenticsInterfaceApp.swift
    InterfaceShell.swift ProjectionGraphView.swift ProjectionOverviewView.swift
    ProjectionStateEnergyView.swift ProjectionTimelineRecordsView.swift
  ],
  "#{PACKAGE}/Sources/ErgenticsLedgerProjector" => %w[main.swift],
  "#{PACKAGE}/Sources/ErgenticsR19OBS11ProjectionChain" => %w[main.swift],
  "#{PACKAGE}/Sources/LedgerProjectionCore" => %w[
    CanonicalJSON.swift LedgerPrefixScanner.swift LedgerProjectionModels.swift
    ProjectionBuilder.swift ProjectionReader.swift Resources SQLiteStore.swift
  ],
  "#{PACKAGE}/Sources/LedgerProjectionCore/Resources" =>
    %w[001-initial.sql adapters.v1.json],
  "#{PACKAGE}/Tests" =>
    %w[DisposalProjectionCoreTests LedgerProjectionCoreTests],
  "#{PACKAGE}/Tests/DisposalProjectionCoreTests" => %w[
    DisposalGraphStateMachineTests.swift DisposalProjectionCoreTests.swift
    DisposalProjectionEmbeddedResourceTests.swift
    DisposalProjectionPredecessorAdmissionTests.swift
    DisposalR19OBS11ProjectionChainTests.swift
    DisposalTypedProcessEvidenceTests.swift Fixtures
    R19OBS11ProjectionChainStaticSurfaceTests.swift
    R19ObservabilityJournalAdapterTests.swift
  ],
  "#{PACKAGE}/Tests/DisposalProjectionCoreTests/Fixtures" =>
    %w[r19-observations.v1.jsonl],
  "#{PACKAGE}/Tests/LedgerProjectionCoreTests" =>
    %w[LedgerProjectionTests.swift],
}.transform_values { |entries| entries.sort.freeze }.freeze

RESOURCE_EXPECTED = [
  ["001-evidence.sql", 50_706,
    "f3e003136aa4f9a12308d310ffa6bc92d71bccb99a7a50656c32231b79a435c7"],
  ["001-graph.sql", 41_517,
    "f65eb702e528f851bfd3bcce2817258dfdc5779132bba780964c82c0d752009e"],
  ["001-metrics.sql", 12_119,
    "eda615d5bc71246c54d7335679f641646e11c8938ef01a459cf168be2aa5ce61"],
  ["disposal-adapters.v1.json", 4_610,
    "68e09200dd29a47fcbe49e083df41fe55ead950198edf75300ab6e302b61be1b"],
  ["disposal-lattice.v1.json", 1_937,
    "c99361cb2052032e176b1ab5cd22898a67231b98bdea8c972388bdeab12ba022"],
].freeze
RESOURCE_PACK_COMMITMENT =
  "a35466c0d654c9d9c8c3da3b86fb886d1d01ce4f4487d84bdd57b46031f70f51"

JOURNAL_LEAVES = %w[
  00-start.json
  01-build-a-commitment.json
  02-build-a-result.json
  03-build-a-admission.json
  04-closure-a-result.json
  05-build-b-commitment.json
  06-build-b-result.json
  07-build-b-admission.json
  08-compare-result.json
].freeze
TERMINAL_LEAF = "99-terminal.json"
BUILD_CHILDREN = %w[
  cache clang-module-cache config home scratch security
  swiftpm-module-cache tmp
].freeze
BUILD_EVENT_LOG_LEAF = "controller-events.jsonl"
BUILD_STDOUT_LEAF = "swiftpm.stdout.bin"
BUILD_STDERR_LEAF = "swiftpm.stderr.bin"

CAPTURE_CAP = 16 * 1_024 * 1_024
JOURNAL_FRAME_CAP = 16 * 1_024 * 1_024
PRODUCT_CAP = 64 * 1_024 * 1_024
PLAN_CAP = 16 * 1_024 * 1_024
LINK_LIST_CAP = 4 * 1_024 * 1_024
TREE_FILE_CAP = 4_096
TREE_DIRECTORY_CAP = 4_096
TREE_SYMLINK_CAP = 4_096
TREE_BYTE_CAP = 512 * 1_024 * 1_024
BUILD_CUTOFF_NS = 840_000_000_000
BUILD_HORIZON_NS = 900_000_000_000
SIGNAL_CERTIFICATE_MAX_AGE_NS = 50_000_000
POLL_INTERVAL_NS = 50_000_000
LOW_POWER_INTERVAL_NS = 1_000_000_000
LINEAGE_SCAN_INTERVAL_NS = 1_000_000_000
JOIN_ATTEMPTS = 4
JOIN_RETRY_SECONDS = 0.001
PID_CAPACITY = 131_072
CAPTURED_LIFETIME_CAP = 4_096
AMBIENT_LIFETIME_CAP = 4_096
AMBIENT_BASELINE_BYTE_CAP = 4 * 1_024 * 1_024

O_RDONLY = 0
O_RDWR = 2
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
O_SYMLINK = 0x00200000
F_FULLFSYNC = 51
F_GETFD = 1
FD_CLOEXEC = 1
RENAME_EXCL = 0x00000004
RENAME_NOFOLLOW_ANY = 0x00000010

EVFILT_VNODE = -4
EV_ADD = 0x0001
EV_ENABLE = 0x0004
EV_CLEAR = 0x0020
EV_RECEIPT = 0x0040
EV_ERROR = 0x4000
NOTE_DELETE = 0x00000001
NOTE_WRITE = 0x00000002
NOTE_EXTEND = 0x00000004
NOTE_ATTRIB = 0x00000008
NOTE_LINK = 0x00000010
NOTE_RENAME = 0x00000020
NOTE_REVOKE = 0x00000040
VNODE_NOTES = NOTE_DELETE | NOTE_WRITE | NOTE_EXTEND | NOTE_ATTRIB |
  NOTE_LINK | NOTE_RENAME | NOTE_REVOKE
KEVENT_BYTES = 32

PROC_ALL_PIDS = 1
PROC_PGRP_ONLY = 2
PROC_RUID_ONLY = 5
PROC_PIDT_SHORTBSDINFO = 13
PROC_PIDUNIQIDENTIFIERINFO = 17
PROC_PIDREGIONPATHINFO = 8
PROC_PIDVNODEPATHINFO = 9
SHORT_BSD_SIZE = 64
UNIQUE_INFO_SIZE = 56
REGION_SIZE = 1_272
VNODE_PATHS_SIZE = 2_352
PATH_SIZE = 4_096
VM_PROT_EXECUTE = 4
ERRNO_ESRCH = 3

LIVE_INTERFERENCE_GENERATIONS = [
  {"label" => "R19_GUARDIAN", "pid" => 21_601,
    "uniqueid" => 8_930_176, "idversion" => 17_456_018},
  {"label" => "GATE_C_AWK", "pid" => 56_518,
    "uniqueid" => 8_668_003, "idversion" => 16_806_376},
].freeze

module C2Darwin
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int openat(int, const char*, int)"
  extern "int mkdirat(int, const char*, unsigned int)"
  extern "int fchown(int, int, int)"
  extern "int fchmod(int, unsigned int)"
  extern "int fcntl(int, int)"
  extern "int mkostempsat_np(int, char*, int, int)"
  extern "int renameatx_np(int, const char*, int, const char*, unsigned int)"
  extern "int dup(int)"
  extern "void* fdopendir(int)"
  extern "void* readdir(void*)"
  extern "int closedir(void*)"
  extern "int kqueue()"
  extern "int kevent(int, void*, int, void*, int, void*)"
  extern "int proc_listpids(unsigned int, unsigned int, void*, int)"
  extern "int proc_pidinfo(int, int, unsigned long long, void*, int)"
  extern "int proc_pidpath(int, void*, unsigned int)"
  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int kill(int, int)"
  extern "long flistxattr(int, void*, unsigned long, int)"
  extern "void* __error()"
end

module C2Security
  extend Fiddle::Importer
  dlload "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation",
    "/System/Library/Frameworks/Security.framework/Security"
  extern "void* CFURLCreateFromFileSystemRepresentation(void*, const unsigned char*, long, unsigned char)"
  extern "void CFRelease(void*)"
  extern "int SecStaticCodeCreateWithPath(void*, unsigned int, void*)"
  extern "int SecStaticCodeCheckValidity(void*, unsigned int, void*)"
end

NATIVE_ERRNO_ZERO = [0].pack("i!").freeze

def call_with_native_errno
  c2_fail("NATIVE_ERRNO_WIDTH") unless
    Fiddle::SIZEOF_INT == 4 &&
      NATIVE_ERRNO_ZERO.bytesize == Fiddle::SIZEOF_INT
  address = C2Darwin.__error().to_i
  c2_fail("NATIVE_ERRNO_POINTER") if address.zero?
  pointer = Fiddle::Pointer.new(address)
  Fiddle.last_error = 0
  pointer[0, Fiddle::SIZEOF_INT] = NATIVE_ERRNO_ZERO
  c2_fail("NATIVE_ERRNO_READBACK") unless
    pointer[0, Fiddle::SIZEOF_INT] == NATIVE_ERRNO_ZERO
  pointer[0, Fiddle::SIZEOF_INT] = NATIVE_ERRNO_ZERO
  result = yield
  error = Fiddle.last_error
  c2_fail("NATIVE_ERRNO_CAPTURE") unless error.is_a?(Integer)
  [result, error]
end

def monotonic_ns
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
end

def canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, output|
      output[key] = canonical_value(value.fetch(key))
    end
  when Array
    value.map { |entry| canonical_value(entry) }
  else
    value
  end
end

def canonical_json(value)
  JSON.generate(canonical_value(value))
end

def mode_string(stat)
  format("%04o", stat.mode & 0o7777)
end

def safe_close(io)
  return nil if io.nil? || io.closed?
  io.close
  nil
rescue Errno::EINTR
  retry
rescue StandardError => error
  error.class.name
end

def descriptor_cloexec?(io)
  flags, error = call_with_native_errno do
    C2Darwin.fcntl(io.fileno, F_GETFD)
  end
  c2_fail("FCNTL_GETFD:#{io.fileno}:#{error}") if flags.negative?
  flags & FD_CLOEXEC == FD_CLOEXEC
end

def full_sync(io, label)
  c2_fail("#{label}:FSYNC") unless io.fsync == 0
  result, error = call_with_native_errno do
    C2Darwin.fcntl(io.fileno, F_FULLFSYNC)
  end
  c2_fail("#{label}:FULLFSYNC:#{error}") unless result == 0
  true
end

def openat_io(parent, leaf, flags, directory: false)
  c2_fail("OPENAT_LEAF:#{leaf}") if
    leaf.empty? || leaf == "." || leaf == ".." || leaf.include?("/") ||
      leaf.include?("\0")
  flags |= O_DIRECTORY if directory
  allowed = O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY
  c2_fail("OPENAT_FLAGS:#{leaf}") unless flags & ~allowed == 0
  descriptor, error = call_with_native_errno do
    C2Darwin.openat(parent.fileno, leaf, flags | O_CLOEXEC)
  end
  c2_fail("OPENAT:#{leaf}:#{error}") if descriptor < 3
  io = IO.new(descriptor)
  c2_fail("OPENAT_CLOEXEC:#{leaf}") unless descriptor_cloexec?(io)
  io
rescue StandardError
  safe_close(io) if defined?(io)
  raise
end

def open_held_path(path, directory: false, kind: :regular)
  c2_fail("HELD_KIND:#{path}") unless
    (directory && kind == :regular) ||
      (!directory && %i[regular character].include?(kind))
  flags = O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
  flags |= O_DIRECTORY if directory
  descriptor = IO.sysopen(path, flags)
  io = IO.new(descriptor)
  c2_fail("HELD_CLOEXEC:#{path}") unless descriptor_cloexec?(io)
  expected_type = if directory
    io.stat.directory?
  elsif kind == :character
    io.stat.chardev?
  else
    io.stat.file?
  end
  c2_fail("HELD_TYPE:#{path}") unless expected_type
  io
rescue StandardError
  safe_close(io) if defined?(io)
  raise
end

def open_held_symlink(path)
  descriptor = IO.sysopen(path, O_RDONLY | O_SYMLINK | O_CLOEXEC)
  io = IO.new(descriptor)
  c2_fail("HELD_SYMLINK_CLOEXEC:#{path}") unless descriptor_cloexec?(io)
  c2_fail("HELD_SYMLINK_TYPE:#{path}") unless io.stat.symlink?
  io
rescue StandardError
  safe_close(io) if defined?(io)
  raise
end

def held_bytes(io, cap, label)
  stat = io.stat
  c2_fail("#{label}:SIZE_NEGATIVE") if stat.size.negative?
  c2_fail("#{label}:SIZE_CAP") if stat.size > cap
  io.rewind
  bytes = io.read(stat.size)
  c2_fail("#{label}:READ_SIZE") unless bytes && bytes.bytesize == stat.size
  c2_fail("#{label}:READ_OVERFLOW") unless io.read(1).nil?
  io.rewind
  bytes
end

def held_digest(io, cap, label)
  Digest::SHA256.hexdigest(held_bytes(io, cap, label))
end

def identity(io, sha256: nil)
  stat = io.stat
  result = {
    "ctime_ns" => (stat.ctime.to_r * 1_000_000_000).to_i,
    "device" => stat.dev,
    "gid" => stat.gid,
    "inode" => stat.ino,
    "mode" => mode_string(stat),
    "mtime_ns" => (stat.mtime.to_r * 1_000_000_000).to_i,
    "nlink" => stat.nlink,
    "size" => stat.size,
    "type" => stat.directory? ? "DIRECTORY" :
      (stat.file? ? "REGULAR" : (stat.symlink? ? "SYMLINK" : "OTHER")),
    "uid" => stat.uid,
  }
  result["sha256"] = sha256 if sha256
  result
end

def require_symlink_policy(path, io, expected)
  named = open_held_symlink(path)
  held_stat = io.stat
  named_stat = named.stat
  c2_fail("SYMLINK_NAMED_JOIN:#{path}") unless
    [held_stat.dev, held_stat.ino] == [named_stat.dev, named_stat.ino]
  observed = identity(io).merge("target" => File.readlink(path))
  expected.each do |field, value|
    c2_fail("SYMLINK_IDENTITY:#{field}:#{path}") unless
      observed.fetch(field) == value
  end
  verification = open_held_symlink(path)
  c2_fail("SYMLINK_READLINK_RACE:#{path}") unless
    [verification.stat.dev, verification.stat.ino] ==
      [held_stat.dev, held_stat.ino] &&
      File.readlink(path) == expected.fetch("target")
  close_error = safe_close(verification)
  c2_fail("SYMLINK_VERIFICATION_CLOSE:#{path}:#{close_error}") if close_error
  close_error = safe_close(named)
  c2_fail("SYMLINK_NAMED_CLOSE:#{path}:#{close_error}") if close_error
  observed
rescue StandardError
  safe_close(verification) if defined?(verification)
  safe_close(named) if defined?(named)
  raise
end

def require_named_join(path, io, directory: false, kind: :regular)
  named = open_held_path(path, directory: directory, kind: kind)
  held_stat = io.stat
  named_stat = named.stat
  c2_fail("NAMED_JOIN:#{path}") unless
    [held_stat.dev, held_stat.ino] == [named_stat.dev, named_stat.ino]
  safe_close(named)
  true
rescue StandardError
  safe_close(named) if defined?(named)
  raise
end

def directory_entries(io, label)
  duplicate, error = call_with_native_errno do
    C2Darwin.dup(io.fileno)
  end
  c2_fail("#{label}:DUP:#{error}") if duplicate < 3
  directory, error = call_with_native_errno do
    C2Darwin.fdopendir(duplicate)
  end
  if directory.to_i == 0
    IO.new(duplicate).close rescue nil
    c2_fail("#{label}:FDOPENDIR:#{error}")
  end
  entries = []
  loop do
    pointer, error = call_with_native_errno do
      C2Darwin.readdir(directory)
    end
    if pointer.to_i == 0
      c2_fail("#{label}:READDIR:#{error}") unless error == 0
      break
    end
    bytes = Fiddle::Pointer.new(pointer.to_i)
    name_length = bytes[18, 2].unpack1("S<")
    c2_fail("#{label}:DIRENT_NAME_CAP") if name_length > 1_023
    name = bytes[21, name_length]
    c2_fail("#{label}:DIRENT_NAME") if
      name.empty? || name.include?("\0") || name.include?("/")
    entries << name unless name == "." || name == ".."
  end
  close_result, error = call_with_native_errno do
    C2Darwin.closedir(directory)
  end
  directory = nil
  c2_fail("#{label}:CLOSEDIR:#{error}") unless close_result == 0
  c2_fail("#{label}:DUPLICATE") unless entries.uniq.length == entries.length
  entries.sort
rescue StandardError
  C2Darwin.closedir(directory) if
    defined?(directory) && directory && directory.to_i != 0
  raise
end

def require_directory_policy(path, io, mode:, uid:, gid:, inventory: nil)
  require_named_join(path, io, directory: true)
  stat = io.stat
  c2_fail("DIRECTORY_POLICY:#{path}") unless
    stat.directory? && mode_string(stat) == mode && stat.uid == uid &&
      stat.gid == gid
  if inventory
    observed = directory_entries(io, "DIRECTORY_INVENTORY:#{path}")
    c2_fail("DIRECTORY_INVENTORY:#{path}") unless observed == inventory.sort
  end
  identity(io)
end

def require_file_policy(path, io, expected, uid: nil, gid: nil, mode: nil)
  require_named_join(path, io)
  stat = io.stat
  c2_fail("FILE_TYPE:#{path}") unless stat.file?
  c2_fail("FILE_NLINK:#{path}") unless stat.nlink == 1
  c2_fail("FILE_UID:#{path}") if uid && stat.uid != uid
  c2_fail("FILE_GID:#{path}") if gid && stat.gid != gid
  c2_fail("FILE_MODE:#{path}") if mode && mode_string(stat) != mode
  bytes = held_bytes(io, expected.fetch("bytes"), "FILE:#{path}")
  c2_fail("FILE_BYTES:#{path}") unless bytes.bytesize == expected.fetch("bytes")
  sha256 = Digest::SHA256.hexdigest(bytes)
  c2_fail("FILE_SHA256:#{path}") unless sha256 == expected.fetch("sha256")
  observed = identity(io, sha256: sha256)
  %w[device gid inode mode nlink uid].each do |field|
    next unless expected.key?(field)
    c2_fail("FILE_IDENTITY:#{field}:#{path}") unless
      observed.fetch(field) == expected.fetch(field)
  end
  observed
end

def require_absent(path, label)
  File.lstat(path)
  c2_fail("#{label}:PRESENT", consumed: false)
rescue Errno::ENOENT
  true
end

def require_absent_consumed(path, label)
  File.lstat(path)
  c2_fail("#{label}:PRESENT")
rescue Errno::ENOENT
  true
end

def create_directory_at(parent, leaf, mode:, uid:, gid:, label:)
  result, error = call_with_native_errno do
    C2Darwin.mkdirat(parent.fileno, leaf, mode)
  end
  c2_fail("#{label}:MKDIRAT:#{error}") unless result == 0
  full_sync(parent, "#{label}:INSERTED_PARENT")
  child = openat_io(parent, leaf, O_RDONLY | O_NOFOLLOW_ANY, directory: true)
  stat = child.stat
  c2_fail("#{label}:INITIAL_OWNER") unless stat.uid == uid
  if stat.gid != gid
    changed, error = call_with_native_errno do
      C2Darwin.fchown(child.fileno, -1, gid)
    end
    c2_fail("#{label}:FCHOWN:#{error}") unless changed == 0
  end
  changed, error = call_with_native_errno do
    C2Darwin.fchmod(child.fileno, mode)
  end
  c2_fail("#{label}:FCHMOD:#{error}") unless changed == 0
  full_sync(child, "#{label}:CHILD")
  full_sync(parent, "#{label}:PARENT")
  c2_fail("#{label}:FINAL_POLICY") unless
    child.stat.directory? && child.stat.uid == uid && child.stat.gid == gid &&
      mode_string(child.stat) == format("%04o", mode)
  child
rescue StandardError
  safe_close(child) if defined?(child)
  raise
end

def staging_template(final_leaf)
  c2_fail("STAGING_FINAL_LEAF") if final_leaf.include?("/")
  ".#{final_leaf}.XXXXXX.staging"
end

def publish_bytes(
  parent, final_leaf, bytes, mode:, uid:, gid:, label:,
  retain_writable: false
)
  template = staging_template(final_leaf).dup
  descriptor, error = call_with_native_errno do
    C2Darwin.mkostempsat_np(
      parent.fileno, template, ".staging".bytesize, O_CLOEXEC
    )
  end
  c2_fail("#{label}:MKOSTEMPSAT:#{error}") if descriptor < 3
  io = IO.new(descriptor, "w+b")
  staged_leaf = template.split("\0", 2).first
  full_sync(parent, "#{label}:STAGING_PARENT")
  c2_fail("#{label}:CLOEXEC") unless descriptor_cloexec?(io)
  offset = 0
  while offset < bytes.bytesize
    written = io.write(bytes.byteslice(offset, bytes.bytesize - offset))
    c2_fail("#{label}:SHORT_WRITE") unless written && written.positive?
    offset += written
  end
  io.flush
  full_sync(io, "#{label}:CONTENT")
  changed, error = call_with_native_errno do
    C2Darwin.fchown(io.fileno, uid, gid)
  end
  c2_fail("#{label}:FCHOWN:#{error}") unless changed == 0
  changed, error = call_with_native_errno do
    C2Darwin.fchmod(io.fileno, mode)
  end
  c2_fail("#{label}:FCHMOD:#{error}") unless changed == 0
  full_sync(io, "#{label}:SEALED")
  staged = openat_io(parent, staged_leaf, O_RDONLY | O_NOFOLLOW_ANY)
  c2_fail("#{label}:STAGING_JOIN") unless
    [staged.stat.dev, staged.stat.ino] == [io.stat.dev, io.stat.ino]
  safe_close(staged)
  renamed, error = call_with_native_errno do
    C2Darwin.renameatx_np(
      parent.fileno, staged_leaf, parent.fileno, final_leaf,
      RENAME_EXCL | RENAME_NOFOLLOW_ANY
    )
  end
  c2_fail("#{label}:RENAME_EXCL:#{error}") unless renamed == 0
  full_sync(parent, "#{label}:PUBLISHED_PARENT")
  named = openat_io(parent, final_leaf, O_RDONLY | O_NOFOLLOW_ANY)
  c2_fail("#{label}:FINAL_JOIN") unless
    [named.stat.dev, named.stat.ino] == [io.stat.dev, io.stat.ino]
  c2_fail("#{label}:FINAL_POLICY") unless
    named.stat.file? && named.stat.uid == uid && named.stat.gid == gid &&
      named.stat.nlink == 1 && mode_string(named.stat) == format("%04o", mode) &&
      named.stat.size == bytes.bytesize
  readback = held_bytes(named, bytes.bytesize, "#{label}:READBACK")
  c2_fail("#{label}:READBACK_BYTES") unless readback == bytes
  if retain_writable
    close_error = safe_close(named)
    c2_fail("#{label}:READ_DESCRIPTOR_CLOSE:#{close_error}") if close_error
    io.rewind
    io
  else
    close_error = safe_close(io)
    c2_fail("#{label}:WRITER_CLOSE:#{close_error}") if close_error
    named.rewind
    named
  end
rescue StandardError
  safe_close(named) if defined?(named)
  safe_close(staged) if defined?(staged)
  safe_close(io) if defined?(io)
  raise
end

class DurableLeafJournal
  attr_reader :root, :root_io, :index, :previous_frame_sha256, :poisoned

  def initialize(parent_io)
    leaf = File.basename(JOURNAL_ROOT)
    @root = JOURNAL_ROOT
    @root_io = create_directory_at(
      parent_io, leaf, mode: 0o700, uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, label: "JOURNAL_ROOT"
    )
    @parent_io = parent_io
    @index = 0
    @previous_frame_sha256 = "0" * 64
    @poisoned = false
    @terminal = false
  end

  def ordinary_complete?
    @index == JOURNAL_LEAVES.length
  end

  def write_ordinary(leaf, body)
    c2_fail("JOURNAL_POISONED") if @poisoned || @terminal
    expected = JOURNAL_LEAVES.fetch(@index)
    c2_fail("JOURNAL_ORDER:#{leaf}:#{expected}") unless leaf == expected
    write_frame(leaf, body, terminal: false)
    @index += 1
  end

  def write_terminal(body)
    c2_fail("JOURNAL_POISONED") if @poisoned || @terminal
    expected_inventory = JOURNAL_LEAVES.first(@index) + [TERMINAL_LEAF]
    candidate = body.merge(
      "root_seal_predicate" => {
        "gid" => BUILD_ROOT_GID,
        "inventory" => expected_inventory,
        "mode" => "0500",
        "named_vnode_join_required" => true,
        "uid" => EXPECTED_UID,
      },
      "terminal_semantics" =>
        "CANDIDATE_REQUIRES_SEALED_ROOT_PREDICATE_V1"
    )
    write_frame(TERMINAL_LEAF, candidate, terminal: true)
    full_sync(@root_io, "JOURNAL_TERMINAL_PRESEAL_ROOT")
    full_sync(@parent_io, "JOURNAL_TERMINAL_PRESEAL_PARENT")
    require_directory_policy(
      @root, @root_io, mode: "0700", uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, inventory: expected_inventory
    )
    changed, error = call_with_native_errno do
      C2Darwin.fchmod(@root_io.fileno, 0o500)
    end
    c2_fail("JOURNAL_TERMINAL_FCHMOD:#{error}") unless changed == 0
    @terminal = true
  end

  def write_frame(leaf, body, terminal:)
    payload = {
      "authority_vector" => "00000000",
      "body" => body,
      "gate_e" => "ABSTAIN",
      "leaf" => leaf,
      "ordinary_index" => @index,
      "previous_frame_with_lf_sha256" => @previous_frame_sha256,
      "runner_executions" => 0,
      "schema" => "ergentics-r19-obs11-c2-build-journal-frame-v1",
      "scientific_outcome" => "ABSTAIN",
      "terminal" => terminal,
    }
    payload_sha256 = Digest::SHA256.hexdigest(canonical_json(payload))
    frame = payload.merge("payload_sha256" => payload_sha256)
    bytes = canonical_json(frame).b + "\n".b
    c2_fail("JOURNAL_FRAME_CAP:#{leaf}") if bytes.bytesize > JOURNAL_FRAME_CAP
    @poisoned = true
    io = publish_bytes(
      @root_io, leaf, bytes, mode: 0o400, uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, label: "JOURNAL:#{leaf}"
    )
    observed = held_bytes(io, bytes.bytesize, "JOURNAL_READBACK:#{leaf}")
    parsed = JSON.parse(observed.byteslice(0, observed.bytesize - 1))
    c2_fail("JOURNAL_CANONICAL:#{leaf}") unless
      observed == canonical_json(parsed).b + "\n".b
    digest_free = parsed.reject { |key, _| key == "payload_sha256" }
    c2_fail("JOURNAL_PAYLOAD_DIGEST:#{leaf}") unless
      Digest::SHA256.hexdigest(canonical_json(digest_free)) ==
        parsed.fetch("payload_sha256")
    @previous_frame_sha256 = Digest::SHA256.hexdigest(observed)
    safe_close(io)
    @poisoned = false
    @previous_frame_sha256
  rescue StandardError
    safe_close(io) if defined?(io)
    raise
  end
end

class AppendOnlyEventLog
  attr_reader :sequence, :previous_frame_sha256

  def initialize(root_io, root_path, label)
    @root_io = root_io
    @root_path = root_path
    @label = label
    @sequence = 0
    @previous_frame_sha256 = "0" * 64
    @poisoned = false
    @sealed = false
    @io = publish_bytes(
      root_io, BUILD_EVENT_LOG_LEAF, "".b, mode: 0o400,
      uid: EXPECTED_UID, gid: BUILD_ROOT_GID, label: "#{label}:EVENT_LOG",
      retain_writable: true
    )
  end

  def append(event)
    c2_fail("#{@label}:EVENT_LOG_POISONED") if @poisoned || @sealed
    core = {
      "event" => event,
      "previous_frame_sha256" => @previous_frame_sha256,
      "sequence" => @sequence,
    }
    frame = core.merge(
      "payload_sha256" => Digest::SHA256.hexdigest(canonical_json(core))
    )
    bytes = canonical_json(frame).b + "\n".b
    c2_fail("#{@label}:EVENT_LOG_CAP") if
      @io.stat.size + bytes.bytesize > CAPTURE_CAP
    @poisoned = true
    @io.seek(0, IO::SEEK_END)
    offset = 0
    while offset < bytes.bytesize
      written = @io.write(bytes.byteslice(offset, bytes.bytesize - offset))
      c2_fail("#{@label}:EVENT_LOG_SHORT_WRITE") unless
        written && written.positive?
      offset += written
    end
    @io.flush
    full_sync(@io, "#{@label}:EVENT_LOG_APPEND")
    full_sync(@root_io, "#{@label}:EVENT_LOG_ROOT")
    @previous_frame_sha256 = Digest::SHA256.hexdigest(bytes)
    @sequence += 1
    @poisoned = false
    @previous_frame_sha256
  end

  def sealed?
    @sealed
  end

  def seal!
    c2_fail("#{@label}:EVENT_LOG_SEAL_STATE") if @poisoned || @sealed
    @io.flush
    full_sync(@io, "#{@label}:EVENT_LOG_FINAL")
    close_error = safe_close(@io)
    c2_fail("#{@label}:EVENT_LOG_WRITER_CLOSE:#{close_error}") if close_error
    @io = openat_io(@root_io, BUILD_EVENT_LOG_LEAF,
      O_RDONLY | O_NOFOLLOW_ANY)
    stat = @io.stat
    c2_fail("#{@label}:EVENT_LOG_FINAL_POLICY") unless
      stat.file? && stat.uid == EXPECTED_UID && stat.gid == BUILD_ROOT_GID &&
        stat.nlink == 1 && mode_string(stat) == "0400"
    @sealed = true
    identity
  end

  def identity
    c2_fail("#{@label}:EVENT_LOG_NOT_SEALED") unless @sealed
    require_named_join("#{@root_path}/#{BUILD_EVENT_LOG_LEAF}", @io)
    bytes = held_bytes(@io, CAPTURE_CAP, "#{@label}:EVENT_LOG_READBACK")
    c2_fail("#{@label}:EVENT_LOG_EMPTY") if bytes.empty?
    lines = bytes.lines
    c2_fail("#{@label}:EVENT_LOG_LINE_END") unless
      lines.all? { |line| line.end_with?("\n") }
    previous = "0" * 64
    lines.each_with_index do |line, index|
      parsed = JSON.parse(line)
      c2_fail("#{@label}:EVENT_LOG_CANONICAL:#{index}") unless
        line == canonical_json(parsed) + "\n"
      core = parsed.reject { |key, _| key == "payload_sha256" }
      c2_fail("#{@label}:EVENT_LOG_SEQUENCE:#{index}") unless
        parsed.fetch("sequence") == index
      c2_fail("#{@label}:EVENT_LOG_PREVIOUS:#{index}") unless
        parsed.fetch("previous_frame_sha256") == previous
      c2_fail("#{@label}:EVENT_LOG_PAYLOAD:#{index}") unless
        parsed.fetch("payload_sha256") ==
          Digest::SHA256.hexdigest(canonical_json(core))
      previous = Digest::SHA256.hexdigest(line.b)
    end
    c2_fail("#{@label}:EVENT_LOG_COUNT") unless lines.length == @sequence
    c2_fail("#{@label}:EVENT_LOG_TAIL") unless
      previous == @previous_frame_sha256
    stat = @io.stat
    {
      "device" => stat.dev, "inode" => stat.ino, "mode" => mode_string(stat),
      "size" => stat.size, "frames" => @sequence,
      "sha256" => Digest::SHA256.hexdigest(bytes),
      "tail_frame_sha256" => @previous_frame_sha256,
    }
  end
end

class HeldNode
  attr_reader :path, :io, :admitted, :expected, :directory

  def initialize(path, directory:, expected: nil, inventory: nil)
    @path = path
    @directory = directory
    @expected = expected
    @inventory = inventory
    @io = open_held_path(path, directory: directory)
    @admitted = revalidate!("CAPTURE")
  end

  def revalidate!(label)
    if @directory
      observed = require_directory_policy(
        @path, @io, mode: "0755", uid: EXPECTED_UID, gid: EXPECTED_EGID,
        inventory: @inventory
      )
    else
      observed = require_file_policy(
        @path, @io, @expected,
        uid: @path.start_with?(PACKAGE) ? EXPECTED_UID : nil,
        gid: @path.start_with?(PACKAGE) ? EXPECTED_EGID : nil,
        mode: @path.start_with?(PACKAGE) ? "0644" : nil
      )
    end
    c2_fail("HELD_NODE_DRIFT:#{label}:#{@path}") if
      @admitted && observed != @admitted
    observed
  end
end

class HeldSymlinkNode
  attr_reader :path, :io, :admitted, :directory

  def initialize(path, expected)
    @path = path
    @expected = expected
    @directory = false
    @io = open_held_symlink(path)
    @admitted = revalidate!("CAPTURE")
  end

  def revalidate!(label)
    observed = require_symlink_policy(@path, @io, @expected)
    c2_fail("HELD_SYMLINK_DRIFT:#{label}:#{@path}") if
      @admitted && observed != @admitted
    observed
  end
end

class HeldSystemDirectoryNode
  attr_reader :path, :io, :admitted, :directory

  def initialize(path, expected)
    @path = path
    @expected = expected
    @directory = true
    @io = open_held_path(path, directory: true)
    @admitted = revalidate!("CAPTURE")
  end

  def revalidate!(label)
    observed = require_directory_policy(
      @path, @io, mode: @expected.fetch("mode"),
      uid: @expected.fetch("uid"), gid: @expected.fetch("gid")
    )
    @expected.each do |field, value|
      c2_fail("SYSTEM_DIRECTORY_IDENTITY:#{field}:#{@path}") unless
        observed.fetch(field) == value
    end
    c2_fail("HELD_SYSTEM_DIRECTORY_DRIFT:#{label}:#{@path}") if
      @admitted && observed != @admitted
    observed
  end
end

class VnodeContinuity
  attr_reader :nodes, :armed, :poisoned, :events

  def initialize
    @nodes = []
    SOURCE_EXPECTED.keys.sort.each do |path|
      @nodes << HeldNode.new(
        path, directory: false, expected: SOURCE_EXPECTED.fetch(path)
      )
    end
    DIRECTORY_INVENTORIES.keys.sort.each do |path|
      @nodes << HeldNode.new(
        path, directory: true, inventory: DIRECTORY_INVENTORIES.fetch(path)
      )
    end
    TOOL_EXPECTED.keys.sort.each do |path|
      bytes, sha256, frozen_identity = TOOL_EXPECTED.fetch(path)
      @nodes << HeldNode.new(
        path, directory: false,
        expected: {"bytes" => bytes, "sha256" => sha256}
          .merge(frozen_identity || {})
      )
    end
    SYMLINK_EXPECTED.keys.sort.each do |path|
      @nodes << HeldSymlinkNode.new(path, SYMLINK_EXPECTED.fetch(path))
    end
    SYSTEM_DIRECTORY_EXPECTED.keys.sort.each do |path|
      @nodes << HeldSystemDirectoryNode.new(
        path, SYSTEM_DIRECTORY_EXPECTED.fetch(path)
      )
    end
    @armed = false
    @poisoned = false
    @events = []
  end

  def source_manifest_receipt
    lines = SOURCE_EXPECTED.keys.sort.map do |path|
      expected = SOURCE_EXPECTED.fetch(path)
      "Observability/ErgenticsInterface/#{expected.fetch('relative')}\t" \
        "#{expected.fetch('bytes')}\t" \
        "#{expected.fetch('sha256')}\n"
    end.join
    c2_fail("SOURCE_MANIFEST_FILE_COUNT") unless
      SOURCE_EXPECTED.length == SOURCE_MANIFEST_FILES
    c2_fail("SOURCE_MANIFEST_BYTE_COUNT") unless
      SOURCE_EXPECTED.values.sum { |entry| entry.fetch("bytes") } ==
        SOURCE_MANIFEST_BYTES
    c2_fail("SOURCE_MANIFEST_SHA256") unless
      Digest::SHA256.hexdigest(lines) == SOURCE_MANIFEST_SHA256
    {
      "bytes" => SOURCE_MANIFEST_BYTES,
      "files" => SOURCE_MANIFEST_FILES,
      "manifest_sha256" => SOURCE_MANIFEST_SHA256,
      "watched_directories" => DIRECTORY_INVENTORIES.length,
      "watched_system_directories" => SYSTEM_DIRECTORY_EXPECTED.length,
      "watched_symlinks" => SYMLINK_EXPECTED.length,
      "watched_tools_and_records" => TOOL_EXPECTED.length,
    }
  end

  def arm!
    c2_fail("VNODE_ALREADY_ARMED") if @armed
    descriptor, error = call_with_native_errno do
      C2Darwin.kqueue
    end
    c2_fail("KQUEUE_CREATE:#{error}") if descriptor < 3
    @kqueue = IO.new(descriptor)
    @kqueue.close_on_exec = true
    c2_fail("KQUEUE_CLOEXEC") unless @kqueue.close_on_exec?
    @nodes.each_with_index do |node, index|
      change = [
        node.io.fileno, EVFILT_VNODE, EV_ADD | EV_ENABLE | EV_CLEAR | EV_RECEIPT,
        VNODE_NOTES, 0, index + 1,
      ].pack("Q<s<S<L<q<Q<")
      event = "\0" * KEVENT_BYTES
      timeout = [0, 0].pack("q<q<")
      returned, error = call_with_native_errno do
        C2Darwin.kevent(
          @kqueue.fileno, change, 1, event, 1, timeout
        )
      end
      c2_fail("KQUEUE_REGISTER:#{index}:#{error}") unless returned == 1
      ident, filter, flags, _fflags, data, udata =
        event.unpack("Q<s<S<L<q<Q<")
      c2_fail("KQUEUE_RECEIPT:#{index}") unless
        ident == node.io.fileno && filter == EVFILT_VNODE &&
          flags & EV_ERROR != 0 && data == 0 && udata == index + 1
    end
    @armed = true
    poll!(0, "ARM_DRAIN_1")
    revalidate!("ARM_BOUNDARY")
    poll!(0, "ARM_DRAIN_2")
    true
  end

  def poll!(timeout_ns, label)
    c2_fail("VNODE_NOT_ARMED") unless @armed
    event_bytes = "\0" * (KEVENT_BYTES * 128)
    timeout = [timeout_ns / 1_000_000_000,
      timeout_ns % 1_000_000_000].pack("q<q<")
    returned, error = call_with_native_errno do
      C2Darwin.kevent(
        @kqueue.fileno, nil, 0, event_bytes, 128, timeout
      )
    end
    c2_fail("KQUEUE_POLL:#{label}:#{error}") if returned.negative?
    returned.times do |index|
      ident, filter, flags, fflags, data, udata =
        event_bytes.byteslice(index * KEVENT_BYTES, KEVENT_BYTES)
          .unpack("Q<s<S<L<q<Q<")
      @events << {
        "data" => data, "fflags" => fflags, "filter" => filter,
        "flags" => flags, "ident" => ident, "label" => label,
        "udata" => udata,
      }
    end
    unless returned.zero?
      @poisoned = true
      raise C2ContainmentRequired.new("VNODE_EVENT:#{label}")
    end
    true
  end

  def revalidate!(label)
    c2_fail("VNODE_POISONED:#{label}") if @poisoned
    @nodes.each { |node| node.revalidate!(label) }
    poll!(0, "#{label}:POST_REVALIDATION") if @armed
    true
  end

  def resource_nodes
    base = "#{PACKAGE}/Sources/DisposalProjectionCore/Resources/"
    @nodes.select { |node| !node.directory && node.path.start_with?(base) }
      .sort_by(&:path)
  end

  def node(path)
    @nodes.find { |entry| entry.path == path }
  end

  def receipt
    {
      "armed" => @armed,
      "events" => @events.length,
      "nodes" => @nodes.length,
      "poisoned" => @poisoned,
      "source" => source_manifest_receipt,
    }
  end
end

class TreeSnapshot
  attr_reader :receipt, :frames

  def initialize(root)
    @root = root
    @frames = []
    @files = 0
    @directories = 0
    @symlinks = 0
    @bytes = 0
    walk
    relative_paths = @frames.map { |frame| frame.fetch("relative") }
    c2_fail("TREE_FRAME_RELATIVE_SHAPE:#{@root}") unless
      relative_paths.all? { |relative| relative.is_a?(String) }
    binary_relative_paths = relative_paths.map { |relative| relative.b }
    c2_fail("TREE_FRAME_RELATIVE_DUPLICATE:#{@root}") unless
      binary_relative_paths.uniq.length == binary_relative_paths.length
    @frames.sort_by! { |frame| frame.fetch("relative").b }
    encoded = @frames.map { |frame| canonical_json(frame) + "\n" }.join
    @receipt = {
      "aggregate_file_bytes" => @bytes,
      "directories" => @directories,
      "files" => @files,
      "frames" => @frames.length,
      "manifest_sha256" => Digest::SHA256.hexdigest(encoded),
      "root" => @root,
      "symlinks" => @symlinks,
    }
  end

  def walk
    root_io = open_held_path(@root, directory: true)
    root_identity = identity(root_io)
    stack = [["", root_io]]
    until stack.empty?
      relative, directory = stack.pop
      @directories += 1
      c2_fail("TREE_DIRECTORY_CAP:#{@root}") if
        @directories > TREE_DIRECTORY_CAP
      entries = directory_entries(directory, "TREE:#{@root}:#{relative}")
      @frames << {
        "entries" => entries,
        "identity" => identity(directory),
        "kind" => "DIRECTORY",
        "relative" => relative,
      }
      entries.reverse_each do |leaf|
        child_relative = relative.empty? ? leaf : "#{relative}/#{leaf}"
        path = "#{@root}/#{child_relative}"
        state = File.lstat(path)
        if state.directory?
          child = open_held_path(path, directory: true)
          stack << [child_relative, child]
        elsif state.file?
          @files += 1
          c2_fail("TREE_FILE_CAP:#{@root}") if @files > TREE_FILE_CAP
          @bytes += state.size
          c2_fail("TREE_BYTE_CAP:#{@root}") if @bytes > TREE_BYTE_CAP
          child = open_held_path(path)
          require_named_join(path, child)
          bytes = held_bytes(child, state.size, "TREE_FILE:#{child_relative}")
          after = child.stat
          c2_fail("TREE_FILE_DRIFT:#{child_relative}") unless
            [state.dev, state.ino, state.mode, state.uid, state.gid,
             state.nlink, state.size, state.mtime.to_r, state.ctime.to_r] ==
              [after.dev, after.ino, after.mode, after.uid, after.gid,
               after.nlink, after.size, after.mtime.to_r, after.ctime.to_r]
          @frames << {
            "identity" => identity(child,
              sha256: Digest::SHA256.hexdigest(bytes)),
            "kind" => "REGULAR",
            "relative" => child_relative,
          }
          safe_close(child)
        elsif state.symlink?
          @symlinks += 1
          c2_fail("TREE_SYMLINK_CAP:#{@root}") if
            @symlinks > TREE_SYMLINK_CAP
          target = File.readlink(path)
          fresh = File.lstat(path)
          c2_fail("TREE_SYMLINK_DRIFT:#{child_relative}") unless
            [state.dev, state.ino, state.mode, state.uid, state.gid,
             state.nlink, state.size, state.mtime.to_r, state.ctime.to_r] ==
              [fresh.dev, fresh.ino, fresh.mode, fresh.uid, fresh.gid,
               fresh.nlink, fresh.size, fresh.mtime.to_r, fresh.ctime.to_r] &&
              target == File.readlink(path)
          @frames << {
            "identity" => {
              "device" => state.dev, "gid" => state.gid,
              "inode" => state.ino, "mode" => mode_string(state),
              "nlink" => state.nlink, "size" => state.size,
              "target_sha256" => Digest::SHA256.hexdigest(target.b),
              "uid" => state.uid,
            },
            "kind" => "SYMLINK",
            "relative" => child_relative,
          }
        else
          c2_fail("TREE_UNSUPPORTED_NODE:#{path}")
        end
      end
      safe_close(directory) unless directory.equal?(root_io)
    end
    require_named_join(@root, root_io, directory: true)
    c2_fail("TREE_ROOT_DRIFT:#{@root}") unless identity(root_io) == root_identity
    safe_close(root_io)
  rescue StandardError
    safe_close(child) if defined?(child)
    safe_close(directory) if defined?(directory)
    safe_close(root_io) if defined?(root_io)
    raise
  end
end

class BuildNamespace
  attr_reader :path, :root_io, :children, :event_log, :label

  def initialize(parent_io, path, label)
    @path = path
    @label = label
    leaf = File.basename(path)
    @root_io = create_directory_at(
      parent_io, leaf, mode: 0o700, uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, label: "#{label}:ROOT"
    )
    @children = {}
    @capture_ios = {}
    @capture_identities = {}
    BUILD_CHILDREN.each do |child_leaf|
      @children[child_leaf] = create_directory_at(
        @root_io, child_leaf, mode: 0o700, uid: EXPECTED_UID,
        gid: BUILD_ROOT_GID, label: "#{label}:#{child_leaf}"
      )
    end
    require_directory_policy(
      @path, @root_io, mode: "0700", uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, inventory: BUILD_CHILDREN
    )
    @event_log = AppendOnlyEventLog.new(@root_io, @path, label)
  end

  def environment
    {
      "CFFIXED_USER_HOME" => "#{@path}/home",
      "CLANG_MODULE_CACHE_PATH" => "#{@path}/clang-module-cache",
      "DEVELOPER_DIR" => "/Applications/Xcode.app/Contents/Developer",
      "HOME" => "#{@path}/home",
      "LANG" => "C.UTF-8",
      "LC_ALL" => "C.UTF-8",
      "MACOSX_DEPLOYMENT_TARGET" => "14.0",
      "PATH" =>
        "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
        "XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin",
      "SDKROOT" => SDK,
      "SOURCE_DATE_EPOCH" => "0",
      "SWIFTPM_MODULECACHE_OVERRIDE" => "#{@path}/swiftpm-module-cache",
      "TERM" => "dumb",
      "TMPDIR" => "#{@path}/tmp/",
      "TZ" => "UTC",
      "XDG_CACHE_HOME" => "#{@path}/cache",
      "XDG_CONFIG_HOME" => "#{@path}/config",
      "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
    }
  end

  def argv
    [
      "--package-path", PACKAGE,
      "--scratch-path", "#{@path}/scratch",
      "--cache-path", "#{@path}/cache",
      "--config-path", "#{@path}/config",
      "--security-path", "#{@path}/security",
      "--configuration", "release",
      "--product", PRODUCT_LEAF,
      "--jobs", "1",
      "--disable-automatic-resolution",
      "-Xswiftc", "-gnone",
      "-Xswiftc", "-no-serialize-debugging-options",
      "-Xcc", "-g0",
      "-Xlinker", "-S",
    ]
  end

  def product_path
    "#{@path}/#{PRODUCT_RELATIVE}"
  end

  def plan_path
    "#{@path}/#{PLAN_RELATIVE}"
  end

  def link_list_path
    "#{@path}/#{LINK_LIST_RELATIVE}"
  end

  def core_sources_path
    "#{@path}/#{CORE_SOURCES_RELATIVE}"
  end

  def runner_sources_path
    "#{@path}/#{RUNNER_SOURCES_RELATIVE}"
  end

  def publish_capture(leaf, bytes, label)
    c2_fail("#{@label}:CAPTURE_DUPLICATE:#{leaf}") if @capture_ios.key?(leaf)
    io = publish_bytes(
      @root_io, leaf, bytes, mode: 0o400, uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, label: "#{@label}:#{label}"
    )
    result = identity(io, sha256: Digest::SHA256.hexdigest(bytes))
    @capture_ios[leaf] = io
    @capture_identities[leaf] = result
    result
  end

  def revalidate!(expected_inventory: nil)
    inventory = expected_inventory ||
      (BUILD_CHILDREN + [BUILD_EVENT_LOG_LEAF] + @capture_ios.keys).sort
    require_directory_policy(
      @path, @root_io, mode: "0700", uid: EXPECTED_UID,
      gid: BUILD_ROOT_GID, inventory: inventory
    )
    @children.each do |leaf, io|
      require_directory_policy(
        "#{@path}/#{leaf}", io, mode: "0700", uid: EXPECTED_UID,
        gid: BUILD_ROOT_GID
      )
    end
    @capture_ios.each do |leaf, io|
      require_named_join("#{@path}/#{leaf}", io)
      bytes = held_bytes(io, CAPTURE_CAP, "#{@label}:CAPTURE:#{leaf}")
      observed = identity(io, sha256: Digest::SHA256.hexdigest(bytes))
      c2_fail("#{@label}:CAPTURE_DRIFT:#{leaf}") unless
        observed == @capture_identities.fetch(leaf)
    end
    @event_log.identity if @event_log&.sealed?
    true
  end
end

def length_framed_id(domain, components)
  bytes = "ERGENTICS_DISPOSAL_LENGTH_FRAMED_ID_V1".b
  bytes << [domain.b.bytesize].pack("Q>") << domain.b
  bytes << [components.length].pack("Q>")
  components.each do |component|
    encoded = component.b
    bytes << [encoded.bytesize].pack("Q>") << encoded
  end
  Digest::SHA256.hexdigest(bytes)
end

def verify_resource_pack_constant
  components = RESOURCE_EXPECTED.flat_map do |leaf, bytes, sha256|
    [leaf, bytes.to_s, sha256]
  end
  observed = length_framed_id(
    "ergentics-disposal-embedded-rule-resource-pack-v1", components
  )
  c2_fail("RESOURCE_PACK_COMMITMENT", consumed: false) unless
    observed == RESOURCE_PACK_COMMITMENT
  observed
end

def u32(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("L<")
end

def u64(bytes, offset)
  bytes.byteslice(offset, 8).unpack1("Q<")
end

def read_pid_info(pid, flavor, size)
  buffer = "\0" * size
  returned, error = call_with_native_errno do
    C2Darwin.proc_pidinfo(pid, flavor, 0, buffer, buffer.bytesize)
  end
  [returned, error, buffer]
end

def parse_unique_info(buffer)
  c2_fail("PROC_UNIQUE_FRAME") unless buffer.bytesize == UNIQUE_INFO_SIZE
  record = {
    "uuid_hex" => buffer.byteslice(0, 16).unpack1("H*"),
    "uniqueid" => u64(buffer, 16),
    "puniqueid" => u64(buffer, 24),
    "idversion" => u32(buffer, 32),
    "orig_ppidversion" => u32(buffer, 36),
    "reserve2" => u64(buffer, 40),
    "reserve3" => u64(buffer, 48),
  }
  c2_fail("PROC_UNIQUE_ZERO") if record.fetch("uniqueid").zero?
  c2_fail("PROC_UNIQUE_RESERVED") unless
    record.fetch("reserve2").zero? && record.fetch("reserve3").zero?
  record
end

def parse_short_bsd(buffer)
  c2_fail("PROC_SHORT_FRAME") unless buffer.bytesize == SHORT_BSD_SIZE
  record = {
    "pid" => u32(buffer, 0),
    "ppid" => u32(buffer, 4),
    "pgid" => u32(buffer, 8),
    "status" => u32(buffer, 12),
    "comm_hex" => buffer.byteslice(16, 16).unpack1("H*"),
    "flags" => u32(buffer, 32),
    "uid" => u32(buffer, 36),
    "gid" => u32(buffer, 40),
    "ruid" => u32(buffer, 44),
    "rgid" => u32(buffer, 48),
    "svuid" => u32(buffer, 52),
    "svgid" => u32(buffer, 56),
    "rfu" => u32(buffer, 60),
  }
  c2_fail("PROC_SHORT_RESERVED") unless record.fetch("rfu").zero?
  record
end

def read_unique(pid)
  returned, error, buffer = read_pid_info(
    pid, PROC_PIDUNIQIDENTIFIERINFO, UNIQUE_INFO_SIZE
  )
  return [:joined, parse_unique_info(buffer)] if returned == UNIQUE_INFO_SIZE
  c2_fail("PROC_UNIQUE_PARTIAL:#{pid}:#{returned}") if returned.positive?
  return [:gone, nil] if returned.zero? && error == ERRNO_ESRCH
  c2_fail("PROC_UNIQUE:#{pid}:#{returned}:#{error}")
end

def read_short(pid)
  returned, error, buffer = read_pid_info(
    pid, PROC_PIDT_SHORTBSDINFO, SHORT_BSD_SIZE
  )
  if returned == SHORT_BSD_SIZE
    record = parse_short_bsd(buffer)
    c2_fail("PROC_SHORT_PID:#{pid}") unless record.fetch("pid") == pid
    return [:joined, record]
  end
  c2_fail("PROC_SHORT_PARTIAL:#{pid}:#{returned}") if returned.positive?
  return [:gone, nil] if returned.zero? && error == ERRNO_ESRCH
  c2_fail("PROC_SHORT:#{pid}:#{returned}:#{error}")
end

def read_domain(pid, kind)
  value, error = call_with_native_errno do
    kind == :sid ? C2Darwin.getsid(pid) : C2Darwin.getpgid(pid)
  end
  return [:joined, value] if value >= 0
  return [:gone, nil] if error == ERRNO_ESRCH
  c2_fail("PROC_DOMAIN:#{kind}:#{pid}:#{error}")
end

def unique_equal?(left, right)
  %w[
    uuid_hex uniqueid puniqueid idversion orig_ppidversion reserve2 reserve3
  ].all? { |field| left.fetch(field) == right.fetch(field) }
end

def short_equal?(left, right)
  %w[pid ppid pgid comm_hex uid gid ruid rgid svuid svgid rfu].all? do |field|
    left.fetch(field) == right.fetch(field)
  end
end

def join_process(pid)
  epochs = []
  JOIN_ATTEMPTS.times do |attempt|
    u0_kind, u0 = read_unique(pid)
    return {"kind" => "gone", "pid" => pid} if u0_kind == :gone
    epochs << [u0.fetch("uniqueid"), u0.fetch("idversion")]
    s0_kind, s0 = read_short(pid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if s0_kind == :gone
    sid0_kind, sid0 = read_domain(pid, :sid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if sid0_kind == :gone
    pgid0_kind, pgid0 = read_domain(pid, :pgid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if pgid0_kind == :gone
    sid1_kind, sid1 = read_domain(pid, :sid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if sid1_kind == :gone
    pgid1_kind, pgid1 = read_domain(pid, :pgid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if pgid1_kind == :gone
    s1_kind, s1 = read_short(pid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if s1_kind == :gone
    u1_kind, u1 = read_unique(pid)
    return {"kind" => "gone", "pid" => pid,
      "tombstones" => epochs.uniq} if u1_kind == :gone
    epochs << [u1.fetch("uniqueid"), u1.fetch("idversion")]
    if unique_equal?(u0, u1) && short_equal?(s0, s1) &&
       sid0 == sid1 && pgid0 == pgid1 &&
       pgid0 == s0.fetch("pgid") && pgid1 == s1.fetch("pgid")
      return {
        "attempts" => attempt + 1,
        "kind" => "joined",
        "pgid" => pgid1,
        "pid" => pid,
        "short" => s1,
        "sid" => sid1,
        "unique" => u1,
      }
    end
    sleep(JOIN_RETRY_SECONDS) if attempt + 1 < JOIN_ATTEMPTS
  end
  {"kind" => "unknown", "pid" => pid, "epochs" => epochs.uniq}
end

def require_joined_process(pid, label)
  observed = join_process(pid)
  c2_fail("#{label}:#{observed.fetch('kind')}") unless
    observed.fetch("kind") == "joined"
  observed
end

def listed_pids(list_type, type_info, allow_empty: false)
  bytes = "\0" * (PID_CAPACITY * 4)
  returned, error = call_with_native_errno do
    C2Darwin.proc_listpids(
      list_type, type_info, bytes, bytes.bytesize
    )
  end
  return [] if allow_empty && returned.zero? && error.zero?
  c2_fail("PROC_LIST:#{list_type}:#{type_info}:#{error}") unless
    returned.positive? && returned < bytes.bytesize && returned % 4 == 0
  pids = bytes.byteslice(0, returned).unpack("L<*").select(&:positive?)
  c2_fail("PROC_LIST_DUPLICATE") unless pids.uniq.length == pids.length
  pids.sort
end

def process_receipt(member)
  {
    "comm_hex" => member.dig("short", "comm_hex"),
    "credentials" => %w[uid gid ruid rgid svuid svgid].map do |field|
      member.dig("short", field)
    end,
    "idversion" => member.dig("unique", "idversion"),
    "orig_ppidversion" => member.dig("unique", "orig_ppidversion"),
    "pgid" => member.fetch("pgid"),
    "pid" => member.fetch("pid"),
    "ppid" => member.dig("short", "ppid"),
    "puniqueid" => member.dig("unique", "puniqueid"),
    "sid" => member.fetch("sid"),
    "status" => member.dig("short", "status"),
    "uniqueid" => member.dig("unique", "uniqueid"),
    "uuid_hex" => member.dig("unique", "uuid_hex"),
  }
end

def same_process?(left, right)
  left.fetch("pid") == right.fetch("pid") &&
    unique_equal?(left.fetch("unique"), right.fetch("unique")) &&
    short_equal?(left.fetch("short"), right.fetch("short")) &&
    left.fetch("sid") == right.fetch("sid") &&
    left.fetch("pgid") == right.fetch("pgid")
end

def live_interference_absent!
  LIVE_INTERFERENCE_GENERATIONS.each do |expected|
    observed = join_process(expected.fetch("pid"))
    next if observed.fetch("kind") == "gone"
    c2_fail("LIVE_INTERFERENCE_UNKNOWN:#{expected.fetch('label')}",
      consumed: false) if observed.fetch("kind") != "joined"
    same_generation =
      observed.dig("unique", "uniqueid") == expected.fetch("uniqueid") &&
      observed.dig("unique", "idversion") == expected.fetch("idversion")
    c2_fail("LIVE_INTERFERENCE_PRESENT:#{expected.fetch('label')}",
      consumed: false) if same_generation
  end
  true
end

def process_path(pid)
  buffer = "\0" * PATH_SIZE
  returned, error = call_with_native_errno do
    C2Darwin.proc_pidpath(pid, buffer, buffer.bytesize)
  end
  return :gone if returned <= 0 && error == ERRNO_ESRCH
  c2_fail("PROC_PIDPATH:#{pid}:#{error}") if returned <= 0
  c2_fail("PROC_PIDPATH_FRAME:#{pid}") if returned >= buffer.bytesize
  buffer.byteslice(0, returned).split("\0", 2).first
end

def process_cwd(pid)
  bytes = "\0" * VNODE_PATHS_SIZE
  returned, error = call_with_native_errno do
    C2Darwin.proc_pidinfo(
      pid, PROC_PIDVNODEPATHINFO, 0, bytes, bytes.bytesize
    )
  end
  return :gone if returned <= 0 && error == ERRNO_ESRCH
  c2_fail("PROC_CWD:#{pid}:#{returned}:#{error}") unless
    returned == VNODE_PATHS_SIZE
  path = bytes.byteslice(152, 1_024).split("\0", 2).first
  c2_fail("PROC_CWD_PATH:#{pid}") unless path.start_with?("/")
  {
    "device" => u32(bytes, 0),
    "inode" => u64(bytes, 8),
    "path" => path,
  }
end

def mapped_image_identity(pid, expected_path, observed_uuid_hex)
  c2_fail("MAPPED_IMAGE_EXPECTATION_CARDINALITY") unless
    MAPPED_EXECUTABLE_EXPECTED.length == 2
  expectation = MAPPED_EXECUTABLE_EXPECTED[expected_path]
  c2_fail("MAPPED_IMAGE_EXPECTATION_PATH:#{expected_path}") unless expectation
  c2_fail("MAPPED_IMAGE_EXPECTATION_UUID:#{expected_path}") unless
    observed_uuid_hex == expectation.fetch("uuid_hex")
  expected_file_offset = expectation.fetch("absolute_file_offset")
  address = 0
  256.times do
    bytes = "\0" * REGION_SIZE
    returned, error = call_with_native_errno do
      C2Darwin.proc_pidinfo(
        pid, PROC_PIDREGIONPATHINFO, address, bytes, bytes.bytesize
      )
    end
    return :gone if returned <= 0 && error == ERRNO_ESRCH
    return nil if returned <= 0 && error.zero?
    c2_fail("PROC_REGION:#{pid}:#{error}") unless returned == REGION_SIZE
    protection = u32(bytes, 0)
    file_offset = u64(bytes, 16)
    region_address = u64(bytes, 80)
    region_size = u64(bytes, 88)
    device = u32(bytes, 96)
    inode = u64(bytes, 104)
    c2_fail("PROC_REGION_ORDER:#{pid}") if
      region_address < address || region_size.zero?
    following = region_address + region_size
    c2_fail("PROC_REGION_OVERFLOW:#{pid}") if following > 0xffff_ffff_ffff_ffff
    if protection & VM_PROT_EXECUTE != 0 &&
        file_offset == expected_file_offset
      path = bytes.byteslice(248, 1_024).split("\0", 2).first
      if path == expected_path
        return {
          "device" => device,
          "file_offset" => file_offset,
          "inode" => inode,
          "path" => path,
          "uuid_hex" => observed_uuid_hex,
        }
      end
    end
    address = following
  end
  c2_fail("PROC_REGION_CAP:#{pid}")
end

class GroupTracker
  attr_reader :direct_pid, :direct_group, :controller, :captured,
    :signal_authority_poisoned, :escaped

  def initialize(controller)
    @controller = controller
    @captured = {}
    @origins = {}
    @transitions = {}
    @captured_epochs = Set.new
    @epoch_classes = {}
    @lifetime_classes = {}
    @ambient_baseline = []
    @baseline_complete = false
    @signal_authority_poisoned = false
    @escaped = {}
    @direct_pid = nil
    @direct_group = nil
    assign_class!(@controller, "owned")
  end

  def epoch_key(member)
    [member.dig("unique", "uniqueid"), member.dig("unique", "idversion")]
  end

  def parent_epoch_key(member)
    [member.dig("unique", "puniqueid"),
      member.dig("unique", "orig_ppidversion")]
  end

  def merge_class(left, right)
    return right if left.nil?
    return left if right.nil? || left == right
    "hard_stop"
  end

  def assign_class!(member, candidate)
    epoch = epoch_key(member)
    lifetime = member.dig("unique", "uniqueid")
    epoch_class = merge_class(@epoch_classes[epoch], candidate)
    lifetime_class = merge_class(@lifetime_classes[lifetime], candidate)
    if epoch_class == "hard_stop" || lifetime_class == "hard_stop"
      @signal_authority_poisoned = true
      c2_fail("OWNED_AMBIENT_CLASS_COLLISION:#{member.fetch('pid')}")
    end
    @epoch_classes[epoch] = epoch_class
    @lifetime_classes[lifetime] = lifetime_class
  end

  def candidate_class(member)
    candidates = [
      @epoch_classes[epoch_key(member)],
      @lifetime_classes[member.dig("unique", "uniqueid")],
      @epoch_classes[parent_epoch_key(member)],
    ].compact
    candidates.reduce(nil) { |memo, value| merge_class(memo, value) }
  end

  def propagate_classes!(records)
    classifications = {}
    (records.length + 2).times do
      changed = false
      records.each do |member|
        key = [member.fetch("pid"), member.dig("unique", "uniqueid")]
        candidate = candidate_class(member)
        if candidate == "hard_stop"
          @signal_authority_poisoned = true
          c2_fail("CLASSIFICATION_COLLISION:#{key.join(':')}")
        end
        changed ||= classifications[key] != candidate
        classifications[key] = candidate
        next unless candidate
        before_epoch = @epoch_classes[epoch_key(member)]
        before_lifetime =
          @lifetime_classes[member.dig("unique", "uniqueid")]
        assign_class!(member, candidate)
        changed ||= before_epoch != @epoch_classes[epoch_key(member)] ||
          before_lifetime !=
            @lifetime_classes[member.dig("unique", "uniqueid")]
      end
      break unless changed
    end
    classifications
  end

  def ruid_census
    listed_pids(PROC_RUID_ONLY, EXPECTED_UID).map do |pid|
      member = join_process(pid)
      next if member.fetch("kind") == "gone"
      c2_fail("RUID_MEMBER_UNKNOWN:#{pid}") unless
        member.fetch("kind") == "joined" &&
          member.dig("short", "ruid") == EXPECTED_UID
      member
    end.compact.sort_by { |member| member.fetch("pid") }
  end

  def capture_ambient_baseline!
    c2_fail("AMBIENT_BASELINE_STATE") if @baseline_complete || @direct_pid
    2.times do |index|
      records = ruid_census
      c2_fail("AMBIENT_LIFETIME_CAP") if
        records.length > AMBIENT_LIFETIME_CAP
      controller = records.find do |member|
        member.fetch("pid") == @controller.fetch("pid") &&
          member.dig("unique", "uniqueid") ==
            @controller.dig("unique", "uniqueid")
      end
      c2_fail("AMBIENT_CONTROLLER_MISSING") unless controller
      records.each do |member|
        next if member.fetch("pid") == @controller.fetch("pid")
        assign_class!(member, "ambient")
      end
      rows = records.map { |member| process_receipt(member) }
      @ambient_baseline << {
        "count" => rows.length,
        "index" => index + 1,
        "rows" => rows,
        "rows_sha256" => Digest::SHA256.hexdigest(canonical_json(rows)),
      }
    end
    c2_fail("AMBIENT_BASELINE_BYTE_CAP") if
      canonical_json(@ambient_baseline).bytesize > AMBIENT_BASELINE_BYTE_CAP
    @baseline_complete = true
    @ambient_baseline
  end

  def arm_direct!(
    pid, expected_image_path, expected_image_io,
    expected_cwd_path, expected_cwd_io
  )
    c2_fail("TRACKER_ALREADY_ARMED") if @direct_pid
    c2_fail("TRACKER_BASELINE_MISSING") unless @baseline_complete
    member = require_joined_process(pid, "DIRECT_CHILD")
    c2_fail("DIRECT_CHILD_PPID") unless
      member.dig("short", "ppid") == @controller.fetch("pid")
    c2_fail("DIRECT_CHILD_PARENT_UNIQUE") unless
      member.dig("unique", "puniqueid") ==
        @controller.dig("unique", "uniqueid")
    c2_fail("DIRECT_CHILD_PARENT_VERSION") unless
      member.dig("unique", "orig_ppidversion") ==
        @controller.dig("unique", "idversion")
    c2_fail("DIRECT_CHILD_SESSION") unless
      member.fetch("sid") == @controller.fetch("sid")
    c2_fail("DIRECT_CHILD_PRIVATE_GROUP") unless
      member.fetch("pgid") == pid
    credentials = %w[uid gid ruid rgid svuid svgid].map do |field|
      member.dig("short", field)
    end
    c2_fail("DIRECT_CHILD_CREDENTIALS") unless
      credentials == [EXPECTED_UID, EXPECTED_EGID, EXPECTED_UID,
        EXPECTED_EGID, EXPECTED_UID, EXPECTED_EGID]
    path = process_path(pid)
    c2_fail("DIRECT_CHILD_PATH_GONE") if path == :gone
    c2_fail("DIRECT_CHILD_PATH") unless path == expected_image_path
    mapped = mapped_image_identity(
      pid, expected_image_path, member.dig("unique", "uuid_hex")
    )
    c2_fail("DIRECT_CHILD_MAPPED_GONE") if mapped == :gone
    c2_fail("DIRECT_CHILD_MAPPED_IMAGE") unless
      mapped && mapped.fetch("device") == expected_image_io.stat.dev &&
        mapped.fetch("inode") == expected_image_io.stat.ino
    cwd = process_cwd(pid)
    c2_fail("DIRECT_CHILD_CWD_GONE") if cwd == :gone
    c2_fail("DIRECT_CHILD_CWD") unless
      cwd == {
        "device" => expected_cwd_io.stat.dev,
        "inode" => expected_cwd_io.stat.ino,
        "path" => expected_cwd_path,
      }
    after = require_joined_process(pid, "DIRECT_CHILD_POST_IMAGE")
    c2_fail("DIRECT_CHILD_IMAGE_RACE") unless same_process?(member, after)
    @direct_pid = pid
    @direct_group = pid
    assign_class!(after, "owned")
    capture!(after)
    process_receipt(after).merge(
      "cwd" => cwd,
      "mapped_image" => mapped,
      "path" => path
    )
  end

  def capture!(member)
    receipt = process_receipt(member)
    key = [receipt.fetch("pid"), receipt.fetch("uniqueid")]
    prior = @captured[key]
    if prior.nil? && @captured.length >= CAPTURED_LIFETIME_CAP
      @signal_authority_poisoned = true
      c2_fail("CAPTURED_LIFETIME_CAP")
    end
    immutable_fields = %w[
      credentials orig_ppidversion pid puniqueid uniqueid
    ]
    stable_prior = prior && immutable_fields.map do |field|
      [field, prior.fetch(field)]
    end
    stable_receipt = immutable_fields.map do |field|
      [field, receipt.fetch(field)]
    end
    if prior && stable_prior != stable_receipt
      @signal_authority_poisoned = true
      c2_fail("CAPTURED_LIFETIME_DRIFT:#{key.join(':')}")
    end
    @origins[key] ||= receipt
    @captured[key] = receipt
    transitions = (@transitions[key] ||= {
      "comm_hex" => Set.new,
      "idversion" => Set.new,
      "pgid" => Set.new,
      "sid" => Set.new,
      "status" => Set.new,
      "uuid_hex" => Set.new,
    })
    transitions.fetch("comm_hex").add(receipt.fetch("comm_hex"))
    transitions.fetch("idversion").add(receipt.fetch("idversion"))
    transitions.fetch("pgid").add(receipt.fetch("pgid"))
    transitions.fetch("sid").add(receipt.fetch("sid"))
    transitions.fetch("status").add(receipt.fetch("status"))
    transitions.fetch("uuid_hex").add(receipt.fetch("uuid_hex"))
    @captured_epochs.add([
      receipt.fetch("uniqueid"), receipt.fetch("idversion")
    ])
    receipt
  end

  def owned_by_epoch?(member)
    parent_epoch = [
      member.dig("unique", "puniqueid"),
      member.dig("unique", "orig_ppidversion"),
    ]
    @captured_epochs.include?(parent_epoch)
  end

  def group_snapshot
    records = listed_pids(
      PROC_PGRP_ONLY, @direct_group, allow_empty: true
    ).map do |pid|
      member = join_process(pid)
      next if member.fetch("kind") == "gone"
      if member.fetch("kind") != "joined"
        @signal_authority_poisoned = true
        c2_fail("GROUP_MEMBER_UNKNOWN:#{pid}")
      end
      c2_fail("GROUP_MEMBER_DOMAIN:#{pid}") unless
        member.fetch("pgid") == @direct_group &&
          member.fetch("sid") == @controller.fetch("sid")
      direct = member.fetch("pid") == @direct_pid &&
        member.dig("unique", "uniqueid") ==
          @captured.values.find { |entry| entry.fetch("pid") == @direct_pid }
            .fetch("uniqueid")
      unless direct || owned_by_epoch?(member) ||
             @captured.key?([member.fetch("pid"),
               member.dig("unique", "uniqueid")])
        @signal_authority_poisoned = true
        c2_fail("GROUP_MEMBER_UNOWNED:#{pid}")
      end
      capture!(member)
      process_receipt(member)
    end.compact.sort_by { |entry| entry.fetch("pid") }
    c2_fail("GROUP_MEMBER_DUPLICATE") unless
      records.map { |entry| entry.fetch("pid") }.uniq.length == records.length
    records
  end

  def double_group_snapshot
    first = group_snapshot
    second = group_snapshot
    stable = lambda do |records|
      records.map do |receipt|
        receipt.reject { |field, _| field == "status" }
      end
    end
    return nil unless stable.call(first) == stable.call(second)
    second
  end

  def scan_lineage
    c2_fail("LINEAGE_BASELINE_MISSING") unless @baseline_complete
    records = ruid_census
    classifications = propagate_classes!(records)
    records.each do |member|
      key = [member.fetch("pid"), member.dig("unique", "uniqueid")]
      classification = classifications[key]
      if classification.nil?
        @signal_authority_poisoned = true
        c2_fail("LINEAGE_UNKNOWN:#{key.join(':')}")
      end
      c2_fail("LINEAGE_CLASS:#{key.join(':')}") unless
        %w[ambient owned].include?(classification)
      next if classification == "ambient" ||
        member.fetch("pid") == @controller.fetch("pid")
      capture!(member)
    end
    escaped_now = []
    @captured.each_value do |receipt|
      current = records.find do |member|
        member.fetch("pid") == receipt.fetch("pid") &&
          member.dig("unique", "uniqueid") == receipt.fetch("uniqueid")
      end
      next unless current
      if current.fetch("pgid") != @direct_group ||
         current.fetch("sid") != @controller.fetch("sid")
        key = [receipt.fetch("pid"), receipt.fetch("uniqueid")]
        @escaped[key] = process_receipt(current)
        escaped_now << key
      end
    end
    unless escaped_now.empty?
      @signal_authority_poisoned = true
      c2_fail("LINEAGE_DOMAIN_ESCAPE:#{escaped_now.sort.flatten.join(':')}")
    end
    true
  end

  def escaped_live?
    @escaped.any? do |(pid, uniqueid), _receipt|
      kind, observed = read_unique(pid)
      kind == :joined && observed.fetch("uniqueid") == uniqueid
    end
  end

  def receipt
    {
      "ambient_baseline" => @ambient_baseline,
      "ambient_baseline_complete" => @baseline_complete,
      "captured" => @captured.keys.sort.map { |key| @captured.fetch(key) },
      "direct_group" => @direct_group,
      "direct_pid" => @direct_pid,
      "escaped" => @escaped.keys.sort.map { |key| @escaped.fetch(key) },
      "origins" => @origins.keys.sort.map { |key| @origins.fetch(key) },
      "signal_authority_poisoned" => @signal_authority_poisoned,
      "transitions" => @transitions.keys.sort.map do |key|
        {
          "pid" => key.first,
          "uniqueid" => key.last,
          "values" => @transitions.fetch(key).transform_values do |values|
            values.to_a.sort
          end,
        }
      end,
    }
  end
end

class BoundedCapture
  attr_reader :total, :overflow, :error, :retained, :sha256

  def initialize(io, cap)
    @io = io
    @cap = cap
    @total = 0
    @overflow = false
    @error = nil
    @retained = "".b
    @done = false
    @mutex = Mutex.new
    @thread = Thread.new { drain }
    @thread.report_on_exception = false if
      @thread.respond_to?(:report_on_exception=)
  end

  def drain
    digest = Digest::SHA256.new
    loop do
      begin
        chunk = @io.readpartial(65_536)
      rescue Errno::EINTR
        next
      rescue EOFError
        break
      end
      digest.update(chunk)
      @total += chunk.bytesize
      if @retained.bytesize < @cap
        count = [@cap - @retained.bytesize, chunk.bytesize].min
        @retained << chunk.byteslice(0, count)
      end
      @overflow = true if @total > @cap
    end
    @sha256 = digest.hexdigest
  rescue StandardError => exception
    @error = exception.class.name
  ensure
    safe_close(@io)
    @mutex.synchronize { @done = true }
  end

  def done?
    @mutex.synchronize { @done }
  end

  def join
    @thread.join
    self
  end

  def receipt
    {
      "capture_error" => @error,
      "complete" => !@overflow && @error.nil? && @total == @retained.bytesize,
      "overflow" => @overflow,
      "retained_bytes" => @retained.bytesize,
      "sha256" => @sha256,
      "total_bytes" => @total,
    }
  end
end

class OwnedChildRun
  attr_reader :result

  def initialize(namespace, continuity, swift_package_io, controller_join)
    @namespace = namespace
    @continuity = continuity
    @swift_package_io = swift_package_io
    @controller_join = controller_join
    @term_committed = false
    @kill_committed = false
    @term_entered = false
    @kill_entered = false
    @signals = []
    @capture_publication_attempted = false
    @conservation_complete = false
    @result = nil
  end

  def run
    cutoff = monotonic_ns + BUILD_CUTOFF_NS
    horizon = cutoff + (BUILD_HORIZON_NS - BUILD_CUTOFF_NS)
    environment = @namespace.environment
    argv = @namespace.argv
    @namespace.event_log.append({
      "argv0_logical" => "swift-build",
      "arguments" => argv,
      "capture_cap" => CAPTURE_CAP,
      "cutoff_monotonic_ns" => cutoff,
      "cwd" => "/private/var/empty",
      "environment" => environment.keys.sort.map do |key|
        [key, environment.fetch(key)]
      end,
      "horizon_monotonic_ns" => horizon,
      "physical_image" => SWIFT_PACKAGE,
      "type" => "CHILD_PRESPAWN_COMMITMENT",
    })
    @continuity.revalidate!("#{@namespace.label}:PRESPAWN")
    tracker = GroupTracker.new(@controller_join)
    ambient_baseline = tracker.capture_ambient_baseline!
    @namespace.event_log.append({
      "baseline" => ambient_baseline,
      "type" => "PRESPAWN_AMBIENT_BASELINE_RETAINED",
    })
    stdin_io = open_held_path("/dev/null", kind: :character)
    require_named_join("/dev/null", stdin_io, kind: :character)
    null_stat = stdin_io.stat
    c2_fail("DEVNULL_POLICY") unless
      null_stat.chardev? && {
        "device" => null_stat.dev,
        "gid" => null_stat.gid,
        "inode" => null_stat.ino,
        "mode" => mode_string(null_stat),
        "nlink" => null_stat.nlink,
        "rdev" => null_stat.rdev,
        "uid" => null_stat.uid,
      } == DEVNULL_IDENTITY
    stdout_r, stdout_w = IO.pipe
    stderr_r, stderr_w = IO.pipe
    stdout_capture = BoundedCapture.new(stdout_r, CAPTURE_CAP)
    stderr_capture = BoundedCapture.new(stderr_r, CAPTURE_CAP)
    pid = Process.spawn(
      environment,
      [SWIFT_PACKAGE, "swift-build"],
      *argv,
      chdir: "/private/var/empty",
      in: stdin_io,
      out: stdout_w,
      err: stderr_w,
      close_others: true,
      unsetenv_others: true,
      pgroup: true
    )
    safe_close(stdout_w)
    safe_close(stderr_w)
    safe_close(stdin_io)
    direct = tracker.arm_direct!(
      pid, SWIFT_PACKAGE, @swift_package_io, "/private/var/empty",
      @continuity.node("/private/var/empty").io
    )
    @namespace.event_log.append({
      "direct_child" => direct,
      "type" => "CHILD_SPAWN_JOINED",
    })
    failure_code = nil
    last_lineage_scan = 0
    reaped_status = nil
    loop do
      now = monotonic_ns
      begin
        @continuity.poll!(0, "#{@namespace.label}:CHILD_INTERVAL")
      rescue C2Failure => error
        failure_code ||= error.code
      end
      if stdout_capture.overflow || stderr_capture.overflow ||
         stdout_capture.error || stderr_capture.error
        failure_code ||= "CAPTURE_FAILURE"
      end
      if now - last_lineage_scan >= LINEAGE_SCAN_INTERVAL_NS
        begin
          tracker.scan_lineage
        rescue C2Failure => error
          failure_code ||= error.code
        end
        last_lineage_scan = now
      end
      members_certified = false
      members = begin
        observed_members = tracker.group_snapshot
        members_certified = true
        observed_members
      rescue C2Failure => error
        failure_code ||= error.code
        []
      end
      if failure_code && !@term_entered
        attempt_signal("TERM", tracker, members)
      elsif now >= cutoff && !@term_entered
        failure_code ||= "BUILD_CUTOFF"
        attempt_signal("TERM", tracker, members)
      end
      kill_due = if @term_call_entered_monotonic_ns
        now >= [@term_call_entered_monotonic_ns + 60_000_000_000,
          horizon].min
      else
        now >= horizon
      end
      attempt_signal("KILL", tracker, members) if
        kill_due && @term_entered && !@kill_entered

      leader_only_zombie =
        members.length == 1 && members.first.fetch("pid") == pid &&
          members.first.fetch("status") == 5
      reap_eligible = members_certified &&
        (members.empty? || leader_only_zombie)
      if reap_eligible && stdout_capture.done? && stderr_capture.done?
        begin
          tracker.scan_lineage
        rescue C2Failure => error
          failure_code ||= error.code
        end
        observed = Process.waitpid2(pid, Process::WNOHANG)
        if observed
          waited_pid, status = observed
          c2_fail("WAITPID_WRONG_PID") unless waited_pid == pid
          reaped_status = status
          break
        end
      end
      unactuated_commitment =
        (@term_committed && !@term_entered) ||
        (@kill_committed && !@kill_entered)
      actuation_exhausted = @kill_committed
      wait_ns = if unactuated_commitment || actuation_exhausted ||
                   (failure_code &&
                     (tracker.signal_authority_poisoned ||
                       tracker.escaped_live?))
        LOW_POWER_INTERVAL_NS
      else
        POLL_INTERVAL_NS
      end
      begin
        @continuity.poll!(wait_ns, "#{@namespace.label}:WAIT")
      rescue C2Failure => error
        failure_code ||= error.code
      end
    end
    stdout_capture.join
    stderr_capture.join
    capture_receipts = publish_reaped_captures!(
      stdout_capture, stderr_capture, reaped_status, tracker
    )
    conservation = prove_conservation(tracker)
    @conservation_complete = true
    @continuity.revalidate!("#{@namespace.label}:POST_REAP")
    @namespace.revalidate!(expected_inventory:
      (BUILD_CHILDREN + [BUILD_EVENT_LOG_LEAF, BUILD_STDOUT_LEAF,
        BUILD_STDERR_LEAF]).sort)
    result_core = {
      "conservation" => conservation,
      "direct_child" => direct,
      "exited" => reaped_status.exited?,
      "exit_status" => reaped_status.exited? ? reaped_status.exitstatus : nil,
      "failure_code" => failure_code,
      "kill_entered" => @kill_entered,
      "signaled" => reaped_status.signaled?,
      "signals" => @signals,
      "stderr" => capture_receipts.fetch("stderr"),
      "stdout" => capture_receipts.fetch("stdout"),
      "termsig" => reaped_status.signaled? ? reaped_status.termsig : nil,
      "term_entered" => @term_entered,
      "tracker" => tracker.receipt,
    }
    result_core_sha256 = Digest::SHA256.hexdigest(canonical_json(result_core))
    @namespace.event_log.append({
      "result_core_sha256" => result_core_sha256,
      "type" => "CHILD_RESULT_RETAINED",
    })
    final_event_log_identity = @namespace.event_log.seal!
    @namespace.revalidate!(expected_inventory:
      (BUILD_CHILDREN + [BUILD_EVENT_LOG_LEAF, BUILD_STDOUT_LEAF,
        BUILD_STDERR_LEAF]).sort)
    @result = result_core.merge(
      "event_log" => final_event_log_identity,
      "result_core_sha256" => result_core_sha256
    )
    @result
  rescue StandardError => error
    safe_close(stdout_w) if defined?(stdout_w)
    safe_close(stderr_w) if defined?(stderr_w)
    safe_close(stdin_io) if defined?(stdin_io)
    if defined?(pid) && pid && !@conservation_complete
      contain_after_exception(
        pid, tracker, stdout_capture, stderr_capture,
        (defined?(reaped_status) ? reaped_status : nil), error
      )
    end
    raise
  end

  def publish_reaped_captures!(
    stdout_capture, stderr_capture, reaped_status, tracker
  )
    c2_fail("CAPTURE_PUBLICATION_REPEATED") if
      @capture_publication_attempted
    @capture_publication_attempted = true
    c2_fail("CAPTURE_PUBLICATION_WITHOUT_REAP") unless reaped_status
    stdout_identity = @namespace.publish_capture(
      BUILD_STDOUT_LEAF, stdout_capture.retained, "STDOUT"
    )
    stderr_identity = @namespace.publish_capture(
      BUILD_STDERR_LEAF, stderr_capture.retained, "STDERR"
    )
    receipts = {
      "stderr" => stderr_capture.receipt.merge("leaf" => stderr_identity),
      "stdout" => stdout_capture.receipt.merge("leaf" => stdout_identity),
    }
    @namespace.event_log.append({
      "captures" => receipts,
      "exited" => reaped_status.exited?,
      "exit_status" =>
        (reaped_status.exited? ? reaped_status.exitstatus : nil),
      "signaled" => reaped_status.signaled?,
      "termsig" =>
        (reaped_status.signaled? ? reaped_status.termsig : nil),
      "tracker" => tracker.receipt,
      "type" => "CHILD_REAP_AND_CAPTURE_RETAINED",
    })
    @namespace.revalidate!(expected_inventory:
      (BUILD_CHILDREN + [BUILD_EVENT_LOG_LEAF, BUILD_STDOUT_LEAF,
        BUILD_STDERR_LEAF]).sort)
    receipts
  end

  def attempt_signal(action, tracker, members)
    c2_fail("SIGNAL_ACTION") unless %w[TERM KILL].include?(action)
    return if action == "TERM" ? @term_committed : @kill_committed
    return if tracker.signal_authority_poisoned || members.empty?
    return if members.all? { |member| member.fetch("status") == 5 }
    snapshot_started = monotonic_ns
    certificate_members = tracker.double_group_snapshot
    return unless certificate_members
    return if certificate_members.empty? ||
      certificate_members.all? { |member| member.fetch("status") == 5 }
    snapshot_completed = monotonic_ns
    certificate = {
      "action" => action,
      "group" => tracker.direct_group,
      "members" => certificate_members,
      "members_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(certificate_members)),
      "sid" => @controller_join.fetch("sid"),
      "snapshot_completed_monotonic_ns" => snapshot_completed,
      "snapshot_started_monotonic_ns" => snapshot_started,
    }
    if action == "TERM"
      @term_committed = true
    else
      @kill_committed = true
    end
    @namespace.event_log.append({
      "certificate" => certificate,
      "type" => "SIGNAL_CALL_ENTRY_COMMITMENT",
    })
    actuation_snapshot_started = monotonic_ns
    actuation_members = tracker.double_group_snapshot
    return unless actuation_members
    stable = lambda do |records|
      records.map do |receipt|
        receipt.reject { |field, _| field == "status" }
      end
    end
    return unless stable.call(actuation_members) ==
      stable.call(certificate_members)
    return if actuation_members.all? { |member| member.fetch("status") == 5 }
    call_record = certificate.merge(
      "actuation_members_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(actuation_members)),
      "actuation_snapshot_started_monotonic_ns" =>
        actuation_snapshot_started,
      "call_entered" => false,
      "delivered" => false
    )
    c2_fail("SIGNAL_CERTIFICATE_EXPIRED") if
      monotonic_ns - actuation_snapshot_started >=
        SIGNAL_CERTIFICATE_MAX_AGE_NS
    call_entered_monotonic_ns = monotonic_ns
    if action == "TERM"
      @term_entered = true
      @term_call_entered_monotonic_ns = call_entered_monotonic_ns
    else
      @kill_entered = true
    end
    call_record["call_entered"] = true
    call_record["call_entered_monotonic_ns"] = call_entered_monotonic_ns
    begin
      delivered = if action == "TERM"
        Process.kill("TERM", -tracker.direct_group)
      else
        Process.kill("KILL", -tracker.direct_group)
      end
      call_record["delivered"] = delivered == 1
      call_record["process_kill_return"] = delivered
    rescue StandardError => error
      call_record["call_error_class"] = error.class.name
      call_record["call_error_sha256"] =
        Digest::SHA256.hexdigest(error.message.to_s.b)
    end
    @signals << call_record
    result_event = {
      "action" => action,
      "call_entered" => true,
      "delivered" => call_record.fetch("delivered"),
      "process_kill_return" => call_record["process_kill_return"],
      "type" => "SIGNAL_CALL_RESULT",
    }
    begin
      @namespace.event_log.append(result_event)
    rescue StandardError => log_error
      call_record["result_log_error_class"] = log_error.class.name
      call_record["result_log_error_sha256"] =
        Digest::SHA256.hexdigest(log_error.message.to_s.b)
    end
  rescue StandardError => error
    @signals << {
      "action" => action,
      "call_entered" => false,
      "delivered" => false,
      "error_class" => error.class.name,
      "error_sha256" => Digest::SHA256.hexdigest(error.message.to_s.b),
    }
    nil
  end

  def contain_after_exception(
    pid, tracker, stdout_capture, stderr_capture, reaped_status, error
  )
    tracker ||= GroupTracker.new(@controller_join)
    loop do
      unless tracker.direct_pid
        begin
          tracker.arm_direct!(
            pid, SWIFT_PACKAGE, @swift_package_io, "/private/var/empty",
            @continuity.node("/private/var/empty").io
          )
        rescue StandardError
        end
      end
      if tracker.direct_pid
        members_certified = false
        members = begin
          observed_members = tracker.group_snapshot
          members_certified = true
          observed_members
        rescue StandardError
          []
        end
        attempt_signal("TERM", tracker, members) unless @term_committed
        attempt_signal("KILL", tracker, members) if
          @term_entered && !@kill_committed &&
            monotonic_ns - @term_call_entered_monotonic_ns >=
              60_000_000_000
        leader_only_zombie =
          members.length == 1 && members.first.fetch("pid") == pid &&
            members.first.fetch("status") == 5
        reap_eligible = members_certified &&
          (members.empty? || leader_only_zombie)
        if reaped_status.nil? && reap_eligible &&
           stdout_capture&.done? && stderr_capture&.done?
          begin
            tracker.scan_lineage
          rescue StandardError
          end
          begin
            observed = Process.waitpid2(pid, Process::WNOHANG)
            if observed
              waited_pid, observed_status = observed
              c2_fail("WAITPID_WRONG_PID") unless waited_pid == pid
              reaped_status = observed_status
            end
          rescue StandardError
          end
        end
      elsif reaped_status.nil?
        begin
          observed = Process.waitpid2(pid, Process::WNOHANG)
          reaped_status = observed.last if observed && observed.first == pid
        rescue Errno::ECHILD
        end
      end
      if reaped_status && stdout_capture&.done? && stderr_capture&.done?
        stdout_capture.join
        stderr_capture.join
        unless @capture_publication_attempted
          begin
            publish_reaped_captures!(
              stdout_capture, stderr_capture, reaped_status, tracker
            )
          rescue StandardError
          end
        end
        if tracker.direct_pid
          begin
            current_members = tracker.group_snapshot
            if current_members.empty?
              prove_conservation(tracker)
              @conservation_complete = true
              break
            end
          rescue StandardError
          end
        end
      end
      @continuity.poll!(LOW_POWER_INTERVAL_NS,
        "#{@namespace.label}:EXCEPTION_CONTAINMENT") rescue nil
    end
    raise error
  end

  def observe_empty_group_twice(tracker, label)
    observations = []
    until observations.length == 2
      pids = listed_pids(
        PROC_PGRP_ONLY, tracker.direct_group, allow_empty: true
      )
      unless pids.empty?
        @continuity.poll!(LOW_POWER_INTERVAL_NS,
          "#{@namespace.label}:#{label}:GROUP_DRAIN") rescue nil
        next
      end
      result, error = call_with_native_errno do
        C2Darwin.kill(-tracker.direct_group, 0)
      end
      if result == -1 && error == ERRNO_ESRCH
        observations << {
          "group" => tracker.direct_group,
          "list" => "EMPTY",
          "signal_zero" => "ESRCH",
        }
      else
        @continuity.poll!(LOW_POWER_INTERVAL_NS,
          "#{@namespace.label}:#{label}:GROUP_ZERO_WAIT") rescue nil
      end
    end
    observations
  end

  def prove_conservation(tracker)
    observe_empty_group_twice(tracker, "INITIAL")
    generation_observations_by_key = {}
    empty_group_observations = nil
    loop do
      tracker.scan_lineage
      captured_keys = tracker.captured.keys.sort
      captured_keys.each do |pid, uniqueid|
        generation_observations_by_key[[pid, uniqueid]] ||= 2.times.map do
          loop do
            kind, observed = read_unique(pid)
            if kind == :gone || observed.fetch("uniqueid") != uniqueid
              break({
                "expected_uniqueid" => uniqueid,
                "observation" => kind == :gone ? "ESRCH" : "PID_REBOUND",
                "pid" => pid,
              })
            end
            @continuity.poll!(LOW_POWER_INTERVAL_NS,
              "#{@namespace.label}:GENERATION_WAIT") rescue nil
          end
        end
      end
      tracker.scan_lineage
      next unless tracker.captured.keys.sort == captured_keys
      c2_fail("ESCAPED_LINEAGE_REMAINS") if tracker.escaped_live?
      observe_empty_group_twice(tracker, "FIXED_POINT")
      tracker.scan_lineage
      next unless tracker.captured.keys.sort == captured_keys
      c2_fail("ESCAPED_LINEAGE_REMAINS") if tracker.escaped_live?
      empty_group_observations =
        observe_empty_group_twice(tracker, "FINAL_FIXED_POINT")
      break
    end
    generation_observations = generation_observations_by_key.keys.sort.flat_map do |key|
      generation_observations_by_key.fetch(key)
    end
    {
      "captured_lifetimes" => tracker.captured.length,
      "generation_observations" => generation_observations,
      "generation_observations_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(generation_observations)),
      "group_absence_observations" => empty_group_observations,
      "group_absence_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(empty_group_observations)),
    }
  end
end

def compare_held_bytes(left, right)
  left.rewind
  right.rewind
  loop do
    a = left.read(65_536)
    b = right.read(65_536)
    return true if (a.nil? || a.empty?) && (b.nil? || b.empty?)
    return false unless a == b
  end
ensure
  left.rewind
  right.rewind
end

def static_code_strict_status(path)
  path_bytes = path.b
  url = C2Security.CFURLCreateFromFileSystemRepresentation(
    nil, path_bytes, path_bytes.bytesize, 0
  )
  c2_fail("SECURITY_CFURL") if url.to_i.zero?
  storage = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
  storage[0, Fiddle::SIZEOF_VOIDP] = [0].pack("J")
  create_status = C2Security.SecStaticCodeCreateWithPath(url, 0, storage)
  c2_fail("SECURITY_STATIC_CODE_CREATE:#{create_status}") unless
    create_status.zero?
  code_address = storage[0, Fiddle::SIZEOF_VOIDP].unpack1("J")
  c2_fail("SECURITY_STATIC_CODE_NULL") if code_address.zero?
  code = Fiddle::Pointer.new(code_address)
  strict_single_threaded = (1 << 4) | (1 << 12)
  check_status = C2Security.SecStaticCodeCheckValidity(
    code, strict_single_threaded, nil
  )
  {
    "create_status" => create_status,
    "flags" => strict_single_threaded,
    "validity_status" => check_status,
  }
ensure
  C2Security.CFRelease(code) if defined?(code) && code && code.to_i != 0
  C2Security.CFRelease(url) if defined?(url) && url && url.to_i != 0
end

def held_xattr_names(io)
  required, error = call_with_native_errno do
    C2Darwin.flistxattr(io.fileno, nil, 0, 0)
  end
  c2_fail("FLISTXATTR_SIZE:#{error}") if required.negative?
  return [] if required.zero?
  c2_fail("FLISTXATTR_CAP") if required > 65_536
  buffer = "\0" * required
  observed, error = call_with_native_errno do
    C2Darwin.flistxattr(
      io.fileno, buffer, buffer.bytesize, 0
    )
  end
  c2_fail("FLISTXATTR_READ:#{error}") unless observed == required
  c2_fail("FLISTXATTR_TERMINATOR") unless buffer.end_with?("\0")
  names = buffer.split("\0", -1)
  names.pop
  c2_fail("FLISTXATTR_NAME") if names.any? do |name|
    name.empty? || name.include?("/") || !name.dup.force_encoding(Encoding::UTF_8)
      .valid_encoding?
  end
  c2_fail("FLISTXATTR_DUPLICATE") unless names.uniq.length == names.length
  names.sort
end

class MachOAdmission
  DYLIB_COMMANDS = [
    0x0000000c, 0x00000018, 0x0000001f, 0x8000001f,
    0x00000020, 0x80000020, 0x00000023, 0x80000023,
  ].freeze
  FORBIDDEN_UNDEFINED = %w[
    _accept _accept4 _bind _connect _copyfile _dlclose _dlopen _dlsym
    _execv _execve _execvp _execvP _fclonefileat _fork _freeaddrinfo
    _getaddrinfo _gethostbyname _kill _killpg _link _linkat _listen
    _popen _posix_spawn _posix_spawnp _raise _recv _recvfrom _recvmsg
    _removexattr _send _sendmsg _sendto _setxattr _signal _sigaction
    _socket _socketpair _symlink _symlinkat _system _unlink _unlinkat
    _vfork _wait _wait3 _wait4 _waitid _waitpid
  ].freeze

  attr_reader :projection

  def initialize(product_io, product_path)
    @io = product_io
    @path = product_path
    @bytes = held_bytes(product_io, PRODUCT_CAP, "MACHO_PRODUCT")
    @projection = parse
  end

  def parse_c_string(bytes, offset, label)
    c2_fail("#{label}:OFFSET") if offset < 8 || offset >= bytes.bytesize
    tail = bytes.byteslice(offset, bytes.bytesize - offset)
    terminator = tail.index("\0")
    c2_fail("#{label}:TERMINATOR") unless terminator
    value = tail.byteslice(0, terminator).force_encoding(Encoding::UTF_8)
    c2_fail("#{label}:UTF8") unless value.valid_encoding?
    value
  end

  def parse
    c2_fail("MACHO_HEADER_SHORT") if @bytes.bytesize < 32
    header = @bytes.byteslice(0, 32)
    magic, cpu_type, cpu_subtype, file_type, command_count,
      command_bytes, flags, reserved = header.unpack("L<8")
    c2_fail("MACHO_MAGIC") unless magic == 0xfeedfacf
    c2_fail("MACHO_CPU") unless cpu_type == 0x0100000c
    c2_fail("MACHO_CPU_SUBTYPE") unless cpu_subtype & 0x00ff_ffff == 0
    c2_fail("MACHO_FILETYPE") unless file_type == 2
    c2_fail("MACHO_RESERVED") unless reserved.zero?
    c2_fail("MACHO_COMMAND_CAP") if
      command_count.zero? || command_count > 256 || command_bytes > 2_097_152
    c2_fail("MACHO_COMMAND_BOUNDS") if 32 + command_bytes > @bytes.bytesize
    commands = @bytes.byteslice(32, command_bytes)
    offset = 0
    command_rows = []
    uuid = []
    build_versions = []
    mains = []
    signatures = []
    segments = []
    dylibs = []
    rpaths = []
    symtab = nil
    dysymtab = nil
    command_count.times do |index|
      c2_fail("MACHO_COMMAND_HEADER:#{index}") if offset + 8 > commands.bytesize
      command, size = commands.byteslice(offset, 8).unpack("L<2")
      c2_fail("MACHO_COMMAND_SIZE:#{index}") if
        size < 8 || size % 8 != 0 || offset + size > commands.bytesize
      raw = commands.byteslice(offset, size)
      command_rows << {
        "command" => format("0x%08x", command),
        "index" => index,
        "raw_sha256" => Digest::SHA256.hexdigest(raw),
        "size" => size,
      }
      case command
      when 0x1b
        c2_fail("MACHO_UUID_SIZE") unless size == 24
        encoded = raw.byteslice(8, 16).unpack("C16")
          .map { |byte| format("%02X", byte) }.join
        uuid << "#{encoded[0, 8]}-#{encoded[8, 4]}-#{encoded[12, 4]}-" \
          "#{encoded[16, 4]}-#{encoded[20, 12]}"
      when 0x32
        c2_fail("MACHO_BUILD_SIZE") if size < 24
        platform, minimum, sdk, tool_count = raw.byteslice(8, 16).unpack("L<4")
        c2_fail("MACHO_BUILD_TOOL_CAP") if tool_count > 32
        c2_fail("MACHO_BUILD_TOOL_BOUNDS") unless size == 24 + tool_count * 8
        tools = tool_count.times.map do |tool_index|
          tool, version = raw.byteslice(24 + tool_index * 8, 8).unpack("L<2")
          {"tool" => tool, "version" => version}
        end
        build_versions << {
          "minimum" => minimum, "platform" => platform,
          "sdk" => sdk, "tools" => tools,
        }
      when 0x80000028
        c2_fail("MACHO_MAIN_SIZE") unless size == 24
        entry, stack = raw.byteslice(8, 16).unpack("Q<2")
        mains << {"entryoff" => entry, "stacksize" => stack}
      when 0x1d
        c2_fail("MACHO_SIGNATURE_SIZE") unless size == 16
        data_offset, data_size = raw.byteslice(8, 8).unpack("L<2")
        signatures << {"offset" => data_offset, "size" => data_size}
      when 0x19
        segments << parse_segment(raw)
      when 0x2
        c2_fail("MACHO_SYMTAB_DUPLICATE") if symtab
        c2_fail("MACHO_SYMTAB_SIZE") unless size == 24
        symoff, nsyms, stroff, strsize = raw.byteslice(8, 16).unpack("L<4")
        symtab = {"nsyms" => nsyms, "stroff" => stroff,
          "strsize" => strsize, "symoff" => symoff}
      when 0xb
        c2_fail("MACHO_DYSYMTAB_DUPLICATE") if dysymtab
        c2_fail("MACHO_DYSYMTAB_SIZE") unless size == 80
        values = raw.byteslice(8, 72).unpack("L<18")
        dysymtab = values
      when 0x8000001c
        name_offset = raw.byteslice(8, 4).unpack1("L<")
        rpaths << parse_c_string(raw, name_offset, "MACHO_RPATH")
      else
        if DYLIB_COMMANDS.include?(command)
          c2_fail("MACHO_DYLIB_SIZE") if size < 24
          name_offset = raw.byteslice(8, 4).unpack1("L<")
          dylibs << {
            "command" => format("0x%08x", command),
            "name" => parse_c_string(raw, name_offset, "MACHO_DYLIB"),
          }
        end
      end
      offset += size
    end
    c2_fail("MACHO_COMMAND_TOTAL") unless offset == commands.bytesize
    c2_fail("MACHO_UUID_COUNT") unless uuid.length == 1
    c2_fail("MACHO_BUILD_COUNT") unless build_versions.length == 1
    c2_fail("MACHO_MAIN_COUNT") unless mains.length == 1
    c2_fail("MACHO_SIGNATURE_COUNT") unless signatures.length == 1
    build = build_versions.first
    c2_fail("MACHO_PLATFORM") unless build.fetch("platform") == 1
    c2_fail("MACHO_MINIMUM") unless build.fetch("minimum") == 0x000e0000
    c2_fail("MACHO_SDK") unless build.fetch("sdk") == 0x001a0500
    signature = signatures.first
    c2_fail("MACHO_SIGNATURE_ALIGNMENT") unless signature.fetch("offset") % 16 == 0
    c2_fail("MACHO_SIGNATURE_BOUNDS") unless
      signature.fetch("offset") + signature.fetch("size") == @bytes.bytesize &&
        signature.fetch("offset") >= 32 + command_bytes &&
        signature.fetch("size") >= 20 && signature.fetch("size") <= 1_048_576
    c2_fail("MACHO_MAIN_BOUNDS") unless
      mains.first.fetch("entryoff") < signature.fetch("offset")
    segments.each do |segment|
      c2_fail("MACHO_SEGMENT_FILE_BOUNDS:#{segment.fetch('name')}") if
        segment.fetch("fileoff") + segment.fetch("filesize") >
          @bytes.bytesize
    end
    symbols = parse_symbols(symtab)
    forbidden = symbols.fetch("undefined") & FORBIDDEN_UNDEFINED
    forbidden.concat(symbols.fetch("undefined").select do |symbol|
      symbol.match?(/\A_(?:posix_spawn.*|exec.*|wait.*|kill.*|socket.*|send.*|recv.*)\z/) ||
        symbol.include?("NSTask")
    end)
    c2_fail("MACHO_FORBIDDEN_UNDEFINED:#{forbidden.sort.join(',')}") unless
      forbidden.empty?
    code_signature = parse_code_signature(signature)
    security = static_code_strict_status(@path)
    c2_fail("SECURITY_STRICT_VALIDITY") unless
      security.fetch("validity_status").zero?
    xattrs = held_xattr_names(@io)
    c2_fail("PRODUCT_XATTR_FORBIDDEN") unless
      (xattrs - ["com.apple.provenance"]).empty?
    {
      "build_version" => build,
      "code_signature" => code_signature,
      "command_count" => command_count,
      "command_rows" => command_rows,
      "commands_size" => command_bytes,
      "cpu_subtype" => cpu_subtype,
      "dylibs" => dylibs,
      "dysymtab" => dysymtab,
      "filetype" => file_type,
      "flags" => flags,
      "header_sha256" => Digest::SHA256.hexdigest(header),
      "main" => mains.first,
      "rpaths" => rpaths,
      "security_framework" => security,
      "segments" => segments,
      "symbols" => symbols,
      "uuid" => uuid.first,
      "xattr_names" => xattrs,
    }
  end

  def parse_segment(raw)
    c2_fail("MACHO_SEGMENT_SIZE") if raw.bytesize < 72
    name = raw.byteslice(8, 16).split("\0", 2).first
    values = raw.byteslice(24, 48).unpack("Q<4L<4")
    vmaddr, vmsize, fileoff, filesize, maxprot, initprot, nsects, flags = values
    c2_fail("MACHO_SECTION_CAP:#{name}") if nsects > 512
    c2_fail("MACHO_SECTION_SIZE:#{name}") unless raw.bytesize == 72 + nsects * 80
    sections = nsects.times.map do |index|
      bytes = raw.byteslice(72 + index * 80, 80)
      section_name = bytes.byteslice(0, 16).split("\0", 2).first
      segment_name = bytes.byteslice(16, 16).split("\0", 2).first
      address, size = bytes.byteslice(32, 16).unpack("Q<2")
      offset, alignment, relocation_offset, relocations, section_flags,
        reserved1, reserved2, reserved3 = bytes.byteslice(48, 32).unpack("L<8")
      c2_fail("MACHO_SECTION_BOUNDS:#{section_name}") if
        offset.positive? && offset + size > @bytes.bytesize
      {
        "address" => address, "alignment" => alignment,
        "flags" => section_flags, "name" => section_name,
        "offset" => offset, "relocation_offset" => relocation_offset,
        "relocations" => relocations, "reserved1" => reserved1,
        "reserved2" => reserved2, "reserved3" => reserved3,
        "segment" => segment_name, "size" => size,
      }
    end
    {
      "fileoff" => fileoff, "filesize" => filesize, "flags" => flags,
      "initprot" => initprot, "maxprot" => maxprot, "name" => name,
      "sections" => sections, "vmaddr" => vmaddr, "vmsize" => vmsize,
    }
  end

  def parse_symbols(symtab)
    c2_fail("MACHO_SYMTAB_MISSING") unless symtab
    nsyms = symtab.fetch("nsyms")
    symoff = symtab.fetch("symoff")
    stroff = symtab.fetch("stroff")
    strsize = symtab.fetch("strsize")
    c2_fail("MACHO_SYMBOL_CAP") if nsyms > 1_000_000
    c2_fail("MACHO_SYMBOL_BOUNDS") if symoff + nsyms * 16 > @bytes.bytesize
    c2_fail("MACHO_STRING_BOUNDS") if stroff + strsize > @bytes.bytesize
    strings = @bytes.byteslice(stroff, strsize)
    defined = []
    undefined = []
    nsyms.times do |index|
      string_index, type, _section, _description, value =
        @bytes.byteslice(symoff + index * 16, 16).unpack("L<CCS<Q<")
      next if type & 0xe0 != 0
      c2_fail("MACHO_SYMBOL_STRING_INDEX") if string_index >= strsize
      tail = strings.byteslice(string_index, strsize - string_index)
      terminator = tail.index("\0")
      c2_fail("MACHO_SYMBOL_TERMINATOR") unless terminator
      name = tail.byteslice(0, terminator).force_encoding(Encoding::UTF_8)
      c2_fail("MACHO_SYMBOL_UTF8") unless name.valid_encoding?
      next if name.empty?
      if type & 0x0e == 0 && value.zero?
        undefined << name
      else
        defined << name
      end
    end
    {
      "defined" => defined.uniq.sort,
      "defined_count" => defined.uniq.length,
      "undefined" => undefined.uniq.sort,
      "undefined_count" => undefined.uniq.length,
    }
  end

  def parse_code_signature(signature)
    offset = signature.fetch("offset")
    size = signature.fetch("size")
    bytes = @bytes.byteslice(offset, size)
    magic, length, count = bytes.byteslice(0, 12).unpack("N3")
    c2_fail("SUPERBLOB_MAGIC") unless magic == 0xfade0cc0
    c2_fail("SUPERBLOB_LENGTH") unless length >= 20 && length <= bytes.bytesize
    c2_fail("SUPERBLOB_COUNT") if count.zero? || count > 16
    c2_fail("SUPERBLOB_INDEX") if 12 + count * 8 > length
    slots = count.times.map do |index|
      slot_type, blob_offset = bytes.byteslice(12 + index * 8, 8).unpack("N2")
      c2_fail("SUPERBLOB_SLOT_OFFSET") if
        blob_offset < 12 + count * 8 || blob_offset + 8 > length
      blob_magic, blob_length = bytes.byteslice(blob_offset, 8).unpack("N2")
      c2_fail("SUPERBLOB_SLOT_LENGTH") if
        blob_length < 8 || blob_offset + blob_length > length
      {
        "blob_length" => blob_length, "blob_magic" => blob_magic,
        "blob_offset" => blob_offset, "slot_type" => slot_type,
      }
    end
    c2_fail("SUPERBLOB_SLOT_DUPLICATE") unless
      slots.map { |slot| slot.fetch("slot_type") }.uniq.length == slots.length
    primary = slots.select do |slot|
      slot.fetch("slot_type").zero? && slot.fetch("blob_magic") == 0xfade0c02
    end
    c2_fail("CODEDIRECTORY_PRIMARY_COUNT") unless primary.length == 1
    slot = primary.first
    code_directory = bytes.byteslice(
      slot.fetch("blob_offset"), slot.fetch("blob_length")
    )
    version, flags = code_directory.byteslice(8, 8).unpack("N2")
    hash_offset, ident_offset = code_directory.byteslice(16, 8).unpack("N2")
    special_slots, code_slots, code_limit =
      code_directory.byteslice(24, 12).unpack("N3")
    hash_size, hash_type, platform, page_exponent =
      code_directory.byteslice(36, 4).unpack("C4")
    c2_fail("CODEDIRECTORY_VERSION") if version < 0x20400
    c2_fail("CODEDIRECTORY_ADHOC") if flags & 0x2 == 0
    c2_fail("CODEDIRECTORY_SPECIAL_SLOTS") unless special_slots.zero?
    c2_fail("CODEDIRECTORY_HASH") unless hash_size == 32 && hash_type == 2
    c2_fail("CODEDIRECTORY_PLATFORM") unless platform.zero?
    c2_fail("CODEDIRECTORY_PAGE") unless page_exponent == 12
    c2_fail("CODEDIRECTORY_CODE_LIMIT") unless code_limit == offset
    page_size = 1 << page_exponent
    c2_fail("CODEDIRECTORY_CODE_SLOTS") unless
      code_slots == (code_limit + page_size - 1) / page_size
    c2_fail("CODEDIRECTORY_IDENT_OFFSET") if
      ident_offset < 40 || ident_offset >= code_directory.bytesize
    identifier = parse_c_string(
      code_directory, ident_offset, "CODEDIRECTORY_IDENTIFIER"
    )
    c2_fail("CODEDIRECTORY_IDENTIFIER") unless identifier == PRODUCT_LEAF
    c2_fail("CODEDIRECTORY_HASH_OFFSET") if
      hash_offset < 40 || hash_offset + code_slots * hash_size >
        code_directory.bytesize
    code_slots.times do |index|
      page_offset = index * page_size
      count = [page_size, code_limit - page_offset].min
      expected = code_directory.byteslice(
        hash_offset + index * hash_size, hash_size
      )
      observed = Digest::SHA256.digest(@bytes.byteslice(page_offset, count))
      c2_fail("CODEDIRECTORY_PAGE_HASH:#{index}") unless observed == expected
    end
    c2_fail("CODEDIRECTORY_EXEC_FIELDS") if code_directory.bytesize < 88
    executable_base, executable_limit, executable_flags =
      code_directory.byteslice(64, 24).unpack("Q>3")
    c2_fail("CODEDIRECTORY_EXEC_BASE") unless executable_base.zero?
    c2_fail("CODEDIRECTORY_EXEC_LIMIT") if
      executable_limit.zero? || executable_limit > code_limit
    c2_fail("CODEDIRECTORY_EXEC_FLAGS") unless executable_flags == 1
    full_sha256 = Digest::SHA256.hexdigest(code_directory)
    {
      "cdhash" => full_sha256.byteslice(0, 40),
      "code_directory_sha256" => full_sha256,
      "code_limit" => code_limit,
      "code_slots" => code_slots,
      "executable_segment_base" => executable_base,
      "executable_segment_flags" => executable_flags,
      "executable_segment_limit" => executable_limit,
      "flags" => flags,
      "hash_size" => hash_size,
      "hash_type" => hash_type,
      "identifier" => identifier,
      "page_exponent" => page_exponent,
      "primary_slot" => slot,
      "raw_superblob_sha256" => Digest::SHA256.hexdigest(bytes),
      "slots" => slots,
      "special_slots" => special_slots,
      "version" => version,
    }
  end
end

class BuildAdmission
  attr_reader :namespace, :product_io, :product_identity, :macho,
    :plan_receipt, :link_receipt, :scratch_receipt, :normalized_link_bytes,
    :normalized_link_sha256, :normalized_plan_bytes, :normalized_plan_sha256,
    :source_list_receipts

  def initialize(namespace, run_result, continuity, dot_build_baseline)
    @namespace = namespace
    @run_result = run_result
    @continuity = continuity
    require_successful_run
    @continuity.revalidate!("#{namespace.label}:ADMISSION_ENTRY")
    @dot_build_after = TreeSnapshot.new(SOURCE_LOCAL_DOT_BUILD).receipt
    c2_fail("#{namespace.label}:SOURCE_DOT_BUILD_CHANGED") unless
      @dot_build_after == dot_build_baseline
    @scratch_snapshot = TreeSnapshot.new("#{namespace.path}/scratch")
    @scratch_receipt = @scratch_snapshot.receipt
    validate_scratch_surface
    @plan_io = open_held_path(namespace.plan_path)
    plan_bytes = held_bytes(@plan_io, PLAN_CAP, "#{namespace.label}:PLAN")
    @plan_receipt = identity(
      @plan_io, sha256: Digest::SHA256.hexdigest(plan_bytes)
    )
    @link_io = open_held_path(namespace.link_list_path)
    link_bytes = held_bytes(
      @link_io, LINK_LIST_CAP, "#{namespace.label}:LINK_LIST"
    )
    @link_receipt = identity(
      @link_io, sha256: Digest::SHA256.hexdigest(link_bytes)
    )
    validate_source_lists
    validate_plan(plan_bytes, link_bytes)
    @product_io = open_held_path(namespace.product_path)
    product_bytes = held_bytes(
      @product_io, PRODUCT_CAP, "#{namespace.label}:PRODUCT"
    )
    stat = @product_io.stat
    c2_fail("#{namespace.label}:PRODUCT_POLICY") unless
      stat.file? && stat.uid == EXPECTED_UID && stat.gid == BUILD_ROOT_GID &&
        stat.nlink == 1 && stat.size.positive? &&
        stat.mode & 0o100 != 0 && stat.mode & 0o022 == 0
    @product_identity = identity(
      @product_io, sha256: Digest::SHA256.hexdigest(product_bytes)
    )
    validate_product_taint(product_bytes)
    @macho = MachOAdmission.new(@product_io, namespace.product_path).projection
    revalidate_product!("POST_ANALYSIS")
    revalidate_auxiliary!("POST_ANALYSIS")
    @continuity.revalidate!("#{namespace.label}:ADMISSION_EXIT")
  end

  def require_successful_run
    c2_fail("#{namespace.label}:RUN_FAILURE_CODE") if @run_result.fetch("failure_code")
    c2_fail("#{namespace.label}:SIGNAL_ENTERED") if
      @run_result.fetch("term_entered") || @run_result.fetch("kill_entered")
    c2_fail("#{namespace.label}:NOT_NORMAL_ZERO") unless
      @run_result.fetch("exited") && @run_result.fetch("exit_status") == 0 &&
        !@run_result.fetch("signaled")
    %w[stdout stderr].each do |stream|
      receipt = @run_result.fetch(stream)
      c2_fail("#{namespace.label}:#{stream}:INCOMPLETE") unless
        receipt.fetch("complete") && !receipt.fetch("overflow") &&
          receipt.fetch("capture_error").nil?
    end
  end

  def validate_scratch_surface
    allowed_targets = Set.new(%w[
      DisposalProjectionCore.build DisposalProjectionPrimitivesC.build
      ErgenticsR19OBS11ProjectionChain.build
    ])
    @scratch_snapshot.frames.each do |frame|
      relative = frame.fetch("relative")
      c2_fail("#{namespace.label}:GENERATED_RESOURCE_ACCESSOR") if
        relative.include?("resource_bundle_accessor")
      c2_fail("#{namespace.label}:RESOURCE_BUNDLE") if
        relative.include?("ErgenticsInterface_DisposalProjectionCore.bundle")
      relative.split("/").select { |part| part.end_with?(".build") }.each do |part|
        c2_fail("#{namespace.label}:UNEXPECTED_TARGET:#{part}") unless
          allowed_targets.include?(part)
      end
    end
  end

  def inline_argument_arrays(plan_bytes)
    text = plan_bytes.dup.force_encoding(Encoding::UTF_8)
    c2_fail("#{namespace.label}:PLAN_UTF8") unless text.valid_encoding?
    arrays = text.lines.map do |line|
      match = /^\s+args: (\[.*\])\s*$/.match(line)
      next unless match
      parsed = JSON.parse(match[1])
      c2_fail("#{namespace.label}:PLAN_ARGS_SHAPE") unless
        parsed.is_a?(Array) && parsed.all? { |entry| entry.is_a?(String) }
      parsed
    end.compact
    c2_fail("#{namespace.label}:PLAN_ARGS_EMPTY") if arrays.empty?
    arrays
  end

  def forwarded_values(arguments, wrapper)
    values = []
    arguments.each_index do |index|
      next unless arguments[index] == wrapper
      c2_fail("#{namespace.label}:#{wrapper}:MISSING_VALUE") if
        index + 1 >= arguments.length
      values << arguments[index + 1]
    end
    values
  end

  def validate_swift_debug_arguments(arguments, kind, require_xcc_g0:)
    wrappers = Set.new(%w[-Xcc -Xfrontend -Xlinker])
    top_level = []
    arguments.each_index do |index|
      next if index.positive? && wrappers.include?(arguments[index - 1])
      top_level << arguments[index]
    end
    frontend = top_level + forwarded_values(arguments, "-Xfrontend")
    debug = frontend.select { |argument| argument.start_with?("-g") }
    allowed_debug = %w[-g -gnone -gline-tables-only]
    unexpected_debug = debug - allowed_debug
    c2_fail("#{namespace.label}:#{kind}:SWIFT_DEBUG_UNKNOWN:" \
      "#{unexpected_debug.join(',')}") unless unexpected_debug.empty?
    c2_fail("#{namespace.label}:#{kind}:SWIFT_GNONE") unless
      debug.last == "-gnone"
    serialization = arguments.select do |argument|
      %w[-serialize-debugging-options
        -no-serialize-debugging-options].include?(argument)
    end
    c2_fail("#{namespace.label}:#{kind}:SWIFT_SERIALIZED_DEBUG_ENABLE") if
      serialization.include?("-serialize-debugging-options")
    c2_fail("#{namespace.label}:#{kind}:SWIFT_SERIALIZED_DEBUG_DISABLE") unless
      serialization == ["-no-serialize-debugging-options"]
    xcc_debug = forwarded_values(arguments, "-Xcc")
      .select { |argument| argument.start_with?("-g") }
    unexpected_xcc_debug = xcc_debug - %w[-g -g0]
    c2_fail("#{namespace.label}:#{kind}:XCC_DEBUG_UNKNOWN:" \
      "#{unexpected_xcc_debug.join(',')}") unless unexpected_xcc_debug.empty?
    if require_xcc_g0 || !xcc_debug.empty?
      c2_fail("#{namespace.label}:#{kind}:XCC_G0") unless
        xcc_debug.last == "-g0"
    end
  end

  def validate_clang_debug_arguments(arguments)
    debug = arguments.select { |argument| argument.start_with?("-g") }
    unexpected = debug - %w[-g -g0]
    c2_fail("#{namespace.label}:CLANG_DEBUG_UNKNOWN:#{unexpected.join(',')}") unless
      unexpected.empty?
    c2_fail("#{namespace.label}:CLANG_G0") unless debug.last == "-g0"
  end

  def validate_source_lists
    expected_core = SOURCE_EXPECTED.keys.select do |path|
      path.match?(%r{/Sources/DisposalProjectionCore/[^/]+\.swift\z})
    end.sort
    expected_runner = [
      "#{PACKAGE}/Sources/#{PRODUCT_LEAF}/main.swift",
    ]
    @source_list_ios = {}
    @source_list_receipts = {}
    [
      ["core", namespace.core_sources_path, expected_core],
      ["runner", namespace.runner_sources_path, expected_runner],
    ].each do |label, path, expected|
      io = open_held_path(path)
      bytes = held_bytes(io, 1_048_576,
        "#{namespace.label}:SOURCE_LIST:#{label}")
      c2_fail("#{namespace.label}:SOURCE_LIST_LINE_END:#{label}") unless
        bytes.end_with?("\n")
      text = bytes.dup.force_encoding(Encoding::UTF_8)
      c2_fail("#{namespace.label}:SOURCE_LIST_UTF8:#{label}") unless
        text.valid_encoding?
      observed = text.lines.map(&:chomp)
      c2_fail("#{namespace.label}:SOURCE_LIST_DUPLICATE:#{label}") unless
        observed.uniq.length == observed.length
      c2_fail("#{namespace.label}:SOURCE_LIST_EXACT:#{label}") unless
        observed == expected
      @source_list_ios[label] = io
      @source_list_receipts[label] = identity(
        io, sha256: Digest::SHA256.hexdigest(bytes)
      ).merge("entries" => observed.length)
    end
  end

  def validate_plan(plan_bytes, link_bytes)
    arrays = inline_argument_arrays(plan_bytes)
    core = arrays.select do |args|
      index = args.index("-module-name")
      index && args[index + 1] == "DisposalProjectionCore"
    end
    runner = arrays.select do |args|
      index = args.index("-module-name")
      index && args[index + 1] == "ErgenticsR19OBS11ProjectionChain"
    end
    c_source =
      "#{PACKAGE}/Sources/DisposalProjectionPrimitivesC/" \
      "DisposalProjectionPrimitivesC.c"
    c_compile = arrays.select { |args| args.include?(c_source) && args.include?("-c") }
    link = arrays.select do |args|
      index = args.index("-o")
      index && args[index + 1] == namespace.product_path
    end
    c2_fail("#{namespace.label}:CORE_COMPILE_COUNT") unless core.length == 1
    c2_fail("#{namespace.label}:RUNNER_COMPILE_COUNT") unless runner.length == 1
    c2_fail("#{namespace.label}:C_COMPILE_COUNT") unless c_compile.length == 1
    c2_fail("#{namespace.label}:LINK_COUNT") unless link.length == 1
    c2_fail("#{namespace.label}:CORE_TOOL") unless core.first.first == SWIFTC
    c2_fail("#{namespace.label}:RUNNER_TOOL") unless runner.first.first == SWIFTC
    c2_fail("#{namespace.label}:C_TOOL") unless c_compile.first.first == CLANG
    c2_fail("#{namespace.label}:LINK_TOOL") unless link.first.first == SWIFTC
    core_response = "@#{namespace.core_sources_path}"
    runner_response = "@#{namespace.runner_sources_path}"
    c2_fail("#{namespace.label}:CORE_RESPONSE_FILE") unless
      core.first.count(core_response) == 1 &&
        core.first.select { |argument| argument.start_with?("@") } ==
          [core_response]
    c2_fail("#{namespace.label}:RUNNER_RESPONSE_FILE") unless
      runner.first.count(runner_response) == 1 &&
        runner.first.select { |argument| argument.start_with?("@") } ==
          [runner_response]
    [["CORE", core.first], ["RUNNER", runner.first]].each do |kind, arguments|
      direct_swift_inputs = arguments.select do |argument|
        argument.end_with?(".swift") || argument == "-primary-file" ||
          argument.match?(/\A-(?:primary-)?filelist(?:=|\z)/)
      end
      c2_fail("#{namespace.label}:#{kind}:DIRECT_SWIFT_INPUT:" \
        "#{direct_swift_inputs.join(',')}") unless direct_swift_inputs.empty?
    end
    c2_fail("#{namespace.label}:C_SOURCE_EXACT") unless
      c_compile.first.count(c_source) == 1 &&
        c_compile.first.select do |argument|
          argument.match?(/\.(?:c|cc|cpp|cxx|m|mm)\z/)
        end == [c_source]
    c2_fail("#{namespace.label}:LINK_RESPONSE_FILE") unless
      link.first.count("@#{namespace.link_list_path}") == 1 &&
        link.first.select { |argument| argument.start_with?("@") } ==
          ["@#{namespace.link_list_path}"] &&
        link.first.none? do |argument|
          argument.match?(/\.(?:a|dylib|o)\z/)
        end
    selected_arrays = (core + runner + c_compile + link).uniq
    selected_markers = %w[
      DisposalProjectionCore.build DisposalProjectionPrimitivesC.build
      ErgenticsR19OBS11ProjectionChain.build
      ErgenticsR19OBS11ProjectionChain.product
    ] + [
      "#{PACKAGE}/Sources/DisposalProjectionCore/",
      "#{PACKAGE}/Sources/DisposalProjectionPrimitivesC/",
      "#{PACKAGE}/Sources/#{PRODUCT_LEAF}/",
    ]
    unexpected_selected = arrays.select do |args|
      args.any? do |argument|
        selected_markers.any? { |marker| argument.include?(marker) }
      end
    end.reject { |args| selected_arrays.include?(args) }
    c2_fail("#{namespace.label}:EXTRA_SELECTED_COMMAND") unless
      unexpected_selected.empty?
    validate_swift_debug_arguments(
      core.first, "CORE", require_xcc_g0: true
    )
    validate_swift_debug_arguments(
      runner.first, "RUNNER", require_xcc_g0: true
    )
    validate_clang_debug_arguments(c_compile.first)
    link_args = link.first
    linker_s = link_args.each_cons(2).any? do |left, right|
      left == "-Xlinker" && right == "-S"
    end || link_args.include?("-Wl,-S")
    c2_fail("#{namespace.label}:LINKER_S") unless linker_s
    text = plan_bytes
    c2_fail("#{namespace.label}:CORE_ACCESSOR_PLAN") if
      text.include?("DisposalProjectionCore.build/DerivedSources/" \
        "resource_bundle_accessor.swift") ||
        text.include?("ErgenticsInterface_DisposalProjectionCore.bundle")
    link_text = link_bytes.dup.force_encoding(Encoding::UTF_8)
    c2_fail("#{namespace.label}:LINK_LIST_UTF8") unless link_text.valid_encoding?
    observed = link_text.lines.map(&:strip).reject(&:empty?)
    c2_fail("#{namespace.label}:LINK_LIST_DUPLICATE") unless
      observed.uniq.length == observed.length
    core_objects = SOURCE_EXPECTED.values.map { |entry| entry.fetch("relative") }
      .select { |relative| relative.match?(%r{\ASources/DisposalProjectionCore/[^/]+\.swift\z}) }
      .map { |relative| File.basename(relative) + ".o" }
    release_root =
      "#{namespace.path}/scratch/#{BUILD_TRIPLE}/#{BUILD_CONFIGURATION}"
    expected_objects = core_objects.map do |leaf|
      "#{release_root}/DisposalProjectionCore.build/#{leaf}"
    end + [
      "#{release_root}/DisposalProjectionPrimitivesC.build/" \
        "DisposalProjectionPrimitivesC.c.o",
      "#{release_root}/#{PRODUCT_LEAF}.build/main.swift.o",
    ]
    expected_link_bytes = (expected_objects.join("\n") + "\n").b
    c2_fail("#{namespace.label}:LINK_LIST_CANONICAL_BYTES") unless
      link_bytes == expected_link_bytes
    c2_fail("#{namespace.label}:LINK_OBJECT_SET") unless
      observed == expected_objects
    @normalized_plan_bytes = plan_bytes.gsub(namespace.path.b, "<ROOT>".b)
    @normalized_plan_sha256 = Digest::SHA256.hexdigest(@normalized_plan_bytes)
    @normalized_link_bytes = link_bytes.gsub(namespace.path.b, "<ROOT>".b)
    @normalized_link_sha256 = Digest::SHA256.hexdigest(@normalized_link_bytes)
  end

  def validate_product_taint(bytes)
    needles = [
      BUILD_A_ROOT, BUILD_B_ROOT, REPOSITORY, PACKAGE,
      SOURCE_LOCAL_DOT_BUILD, "resource_bundle_accessor.swift",
      "ErgenticsInterface_DisposalProjectionCore.bundle",
      "could not load resource bundle", "SWIFTPM_MODULE_BUNDLE",
    ].map(&:b)
    present = needles.select { |needle| bytes.include?(needle) }
    c2_fail("#{namespace.label}:PRODUCT_TAINT:" \
      "#{present.map { |item| Digest::SHA256.hexdigest(item) }.join(',')}") unless
      present.empty?
  end

  def revalidate_product!(label)
    require_named_join(namespace.product_path, @product_io)
    bytes = held_bytes(@product_io, PRODUCT_CAP, "#{namespace.label}:#{label}")
    observed = identity(
      @product_io, sha256: Digest::SHA256.hexdigest(bytes)
    )
    c2_fail("#{namespace.label}:PRODUCT_DRIFT:#{label}") unless
      observed == @product_identity
    observed
  end

  def revalidate_auxiliary!(label)
    namespace.revalidate!
    [
      ["PLAN", @plan_io, namespace.plan_path, PLAN_CAP, @plan_receipt],
      ["LINK", @link_io, namespace.link_list_path, LINK_LIST_CAP,
        @link_receipt],
    ].each do |kind, io, path, cap, expected|
      require_named_join(path, io)
      bytes = held_bytes(io, cap,
        "#{namespace.label}:#{label}:#{kind}")
      observed = identity(io, sha256: Digest::SHA256.hexdigest(bytes))
      c2_fail("#{namespace.label}:#{kind}_DRIFT:#{label}") unless
        observed == expected
    end
    @source_list_ios.each do |kind, io|
      path = kind == "core" ? namespace.core_sources_path :
        namespace.runner_sources_path
      require_named_join(path, io)
      bytes = held_bytes(io, 1_048_576,
        "#{namespace.label}:#{label}:SOURCE_LIST:#{kind}")
      observed = identity(io, sha256: Digest::SHA256.hexdigest(bytes))
        .merge("entries" => bytes.lines.length)
      c2_fail("#{namespace.label}:SOURCE_LIST_DRIFT:#{kind}:#{label}") unless
        observed == @source_list_receipts.fetch(kind)
    end
    true
  end

  def receipt
    {
      "link" => @link_receipt,
      "macho" => @macho,
      "normalized_link_sha256" => @normalized_link_sha256,
      "normalized_plan_sha256" => @normalized_plan_sha256,
      "plan" => @plan_receipt,
      "product" => @product_identity,
      "scratch" => @scratch_receipt,
      "source_lists" => @source_list_receipts,
      "source_local_dot_build" => @dot_build_after,
    }
  end
end

class RuntimeClosure
  attr_reader :path, :root_io, :resource_root_io, :executable_io,
    :resource_ios, :receipt

  def initialize(parent_io, path, admission, continuity, label)
    @parent_io = parent_io
    @path = path
    @admission = admission
    @continuity = continuity
    @label = label
    require_absent_consumed(path, "#{label}:CLOSURE_INITIAL")
    admission.revalidate_product!("#{label}:PREPACKAGE")
    continuity.revalidate!("#{label}:PREPACKAGE")
    @root_io = create_directory_at(
      parent_io, File.basename(path), mode: 0o700, uid: EXPECTED_UID,
      gid: RUNTIME_CLOSURE_GID, label: "#{label}:CLOSURE_ROOT"
    )
    @resource_root_io = create_directory_at(
      @root_io, RESOURCE_ROOT_LEAF, mode: 0o700, uid: EXPECTED_UID,
      gid: RUNTIME_CLOSURE_GID, label: "#{label}:RESOURCE_ROOT"
    )
    product_bytes = held_bytes(
      admission.product_io, PRODUCT_CAP, "#{label}:HELD_PRODUCT"
    )
    @executable_io = publish_bytes(
      @root_io, PRODUCT_LEAF, product_bytes, mode: 0o500,
      uid: EXPECTED_UID, gid: RUNTIME_CLOSURE_GID,
      label: "#{label}:EXECUTABLE"
    )
    @resource_ios = {}
    resource_rows = []
    continuity.resource_nodes.each do |node|
      leaf = File.basename(node.path)
      specification = RESOURCE_EXPECTED.find { |entry| entry.first == leaf }
      c2_fail("#{label}:RESOURCE_SPECIFICATION:#{leaf}") unless specification
      expected_bytes = specification.fetch(1)
      expected_sha256 = specification.fetch(2)
      bytes = held_bytes(node.io, expected_bytes, "#{label}:RESOURCE:#{leaf}")
      c2_fail("#{label}:RESOURCE_BYTES:#{leaf}") unless
        bytes.bytesize == expected_bytes &&
          Digest::SHA256.hexdigest(bytes) == expected_sha256
      io = publish_bytes(
        @resource_root_io, leaf, bytes, mode: 0o400,
        uid: EXPECTED_UID, gid: RUNTIME_CLOSURE_GID,
        label: "#{label}:RESOURCE:#{leaf}"
      )
      @resource_ios[leaf] = io
      resource_rows << identity(io, sha256: expected_sha256)
        .merge("leaf" => leaf)
    end
    c2_fail("#{label}:RESOURCE_COUNT") unless
      @resource_ios.keys.sort == RESOURCE_EXPECTED.map(&:first).sort
    seal_directory(@resource_root_io, 0o500, "#{label}:RESOURCE_ROOT")
    seal_directory(@root_io, 0o500, "#{label}:CLOSURE_ROOT")
    full_sync(parent_io, "#{label}:PRIVATE_TMP")
    root_identity = require_directory_policy(
      path, @root_io, mode: "0500", uid: EXPECTED_UID,
      gid: RUNTIME_CLOSURE_GID,
      inventory: [PRODUCT_LEAF, RESOURCE_ROOT_LEAF]
    )
    resource_identity = require_directory_policy(
      "#{path}/#{RESOURCE_ROOT_LEAF}", @resource_root_io,
      mode: "0500", uid: EXPECTED_UID, gid: RUNTIME_CLOSURE_GID,
      inventory: RESOURCE_EXPECTED.map(&:first)
    )
    c2_fail("#{label}:CLOSURE_NLINK") unless
      @root_io.stat.nlink == 4 && @resource_root_io.stat.nlink == 7
    executable_identity = revalidate_file(
      @executable_io, "#{path}/#{PRODUCT_LEAF}", product_bytes,
      mode: "0500", label: "#{label}:EXECUTABLE_FINAL"
    )
    @resource_ios.each do |leaf, io|
      specification = RESOURCE_EXPECTED.find { |entry| entry.first == leaf }
      bytes = held_bytes(
        continuity.resource_nodes.find { |node| File.basename(node.path) == leaf }.io,
        specification.fetch(1), "#{label}:REFERENCE_REVALIDATE:#{leaf}"
      )
      revalidate_file(
        io, "#{path}/#{RESOURCE_ROOT_LEAF}/#{leaf}", bytes,
        mode: "0400", label: "#{label}:RESOURCE_FINAL:#{leaf}"
      )
    end
    admission.revalidate_product!("#{label}:POSTPACKAGE")
    c2_fail("#{label}:PRODUCT_COPY_JOIN") unless
      compare_held_bytes(admission.product_io, @executable_io)
    continuity.revalidate!("#{label}:POSTPACKAGE")
    @receipt = {
      "executable" => executable_identity,
      "path" => path,
      "resource_pack_commitment" => verify_resource_pack_constant,
      "resource_root" => resource_identity,
      "resources" => resource_rows.sort_by { |row| row.fetch("leaf") },
      "root" => root_identity,
    }
  rescue StandardError
    raise
  end

  def seal_directory(io, mode, label)
    result, error = call_with_native_errno do
      C2Darwin.fchmod(io.fileno, mode)
    end
    c2_fail("#{label}:FCHMOD:#{error}") unless result == 0
    full_sync(io, label)
  end

  def revalidate_file(io, path, bytes, mode:, label:)
    require_named_join(path, io)
    stat = io.stat
    c2_fail("#{label}:POLICY") unless
      stat.file? && stat.uid == EXPECTED_UID &&
        stat.gid == RUNTIME_CLOSURE_GID && mode_string(stat) == mode &&
        stat.nlink == 1 && stat.size == bytes.bytesize
    observed = held_bytes(io, bytes.bytesize, label)
    c2_fail("#{label}:BYTES") unless observed == bytes
    identity(io, sha256: Digest::SHA256.hexdigest(observed))
  end

  def revalidate!
    root_identity = require_directory_policy(
      @path, @root_io, mode: "0500", uid: EXPECTED_UID,
      gid: RUNTIME_CLOSURE_GID,
      inventory: [PRODUCT_LEAF, RESOURCE_ROOT_LEAF]
    )
    resource_identity = require_directory_policy(
      "#{@path}/#{RESOURCE_ROOT_LEAF}", @resource_root_io,
      mode: "0500", uid: EXPECTED_UID, gid: RUNTIME_CLOSURE_GID,
      inventory: RESOURCE_EXPECTED.map(&:first)
    )
    c2_fail("#{@label}:ROOT_DRIFT") unless root_identity == @receipt.fetch("root")
    c2_fail("#{@label}:RESOURCE_ROOT_DRIFT") unless
      resource_identity == @receipt.fetch("resource_root")
    c2_fail("#{@label}:CLOSURE_NLINK_DRIFT") unless
      @root_io.stat.nlink == 4 && @resource_root_io.stat.nlink == 7
    @admission.revalidate_product!("#{@label}:CLOSURE_REVALIDATE")
    product_bytes = held_bytes(
      @admission.product_io, PRODUCT_CAP,
      "#{@label}:CLOSURE_REVALIDATE_PRODUCT"
    )
    executable_identity = revalidate_file(
      @executable_io, "#{@path}/#{PRODUCT_LEAF}", product_bytes,
      mode: "0500", label: "#{@label}:EXECUTABLE_REVALIDATE"
    )
    c2_fail("#{@label}:EXECUTABLE_IDENTITY_DRIFT") unless
      executable_identity == @receipt.fetch("executable")
    expected_resource_rows = @receipt.fetch("resources").to_h do |row|
      [row.fetch("leaf"), row]
    end
    RESOURCE_EXPECTED.each do |leaf, bytes, sha256|
      io = @resource_ios.fetch(leaf)
      reference_node = @continuity.resource_nodes.find do |node|
        File.basename(node.path) == leaf
      end
      c2_fail("#{@label}:RESOURCE_REFERENCE:#{leaf}") unless reference_node
      reference_bytes = held_bytes(
        reference_node.io, bytes,
        "#{@label}:RESOURCE_REFERENCE_REVALIDATE:#{leaf}"
      )
      c2_fail("#{@label}:RESOURCE_REFERENCE_DIGEST:#{leaf}") unless
        Digest::SHA256.hexdigest(reference_bytes) == sha256
      observed_identity = revalidate_file(
        io, "#{@path}/#{RESOURCE_ROOT_LEAF}/#{leaf}", reference_bytes,
        mode: "0400", label: "#{@label}:RESOURCE_REVALIDATE:#{leaf}"
      ).merge("leaf" => leaf)
      c2_fail("#{@label}:RESOURCE_IDENTITY_DRIFT:#{leaf}") unless
        observed_identity == expected_resource_rows.fetch(leaf)
    end
    @continuity.revalidate!("#{@label}:CLOSURE_REVALIDATE")
    true
  end
end

def compare_runtime_closures(left, right)
  left.revalidate!
  right.revalidate!
  c2_fail("CLOSURE_ROOT_VNODE_ALIAS") if
    [left.root_io.stat.dev, left.root_io.stat.ino] ==
      [right.root_io.stat.dev, right.root_io.stat.ino]
  c2_fail("CLOSURE_RESOURCE_ROOT_VNODE_ALIAS") if
    [left.resource_root_io.stat.dev, left.resource_root_io.stat.ino] ==
      [right.resource_root_io.stat.dev, right.resource_root_io.stat.ino]
  c2_fail("CLOSURE_EXECUTABLE_VNODE_ALIAS") if
    [left.executable_io.stat.dev, left.executable_io.stat.ino] ==
      [right.executable_io.stat.dev, right.executable_io.stat.ino]
  c2_fail("CLOSURE_EXECUTABLE_BYTES") unless
    compare_held_bytes(left.executable_io, right.executable_io)
  RESOURCE_EXPECTED.each do |leaf, _bytes, _sha256|
    left_io = left.resource_ios.fetch(leaf)
    right_io = right.resource_ios.fetch(leaf)
    c2_fail("CLOSURE_RESOURCE_VNODE_ALIAS:#{leaf}") if
      [left_io.stat.dev, left_io.stat.ino] ==
        [right_io.stat.dev, right_io.stat.ino]
    c2_fail("CLOSURE_RESOURCE_BYTES:#{leaf}") unless
      compare_held_bytes(left_io, right_io)
  end
  {
    "a_root" => left.receipt,
    "b_root" => right.receipt,
    "equal_raw_leaf_bytes" => true,
    "root_vnodes_distinct" => true,
  }
end

class C2StateMachine
  TRANSITIONS = {
    "entered" => "start_durable",
    "start_durable" => "source_armed",
    "source_armed" => "a_committed",
    "a_committed" => "a_reaped",
    "a_reaped" => "a_admitted",
    "a_admitted" => "closure_a_durable",
    "closure_a_durable" => "b_committed",
    "b_committed" => "b_reaped",
    "b_reaped" => "b_admitted",
    "b_admitted" => "raw_equal",
    "raw_equal" => "closure_pair_equal",
    "closure_pair_equal" => "terminal_success",
  }.freeze

  attr_reader :state

  def initialize
    @state = "entered"
  end

  def advance!(next_state)
    expected = TRANSITIONS.fetch(@state)
    c2_fail("STATE_TRANSITION:#{@state}:#{next_state}:#{expected}") unless
      next_state == expected
    @state = next_state
  end

  def fail!
    @state = "failed"
  end
end

def verify_swift_build_link
  path = SWIFT_BUILD
  state = File.lstat(path)
  c2_fail("SWIFT_BUILD_NOT_SYMLINK", consumed: false) unless state.symlink?
  c2_fail("SWIFT_BUILD_LINK_INODE", consumed: false) unless
    state.dev == 16_777_231 && state.ino == 1_118_475
  c2_fail("SWIFT_BUILD_LINK_TARGET", consumed: false) unless
    File.readlink(path) == "swift-package" && File.realpath(path) == SWIFT_PACKAGE
  true
end

def verify_sdk_link
  state = File.lstat(SDK)
  c2_fail("SDK_NOT_SYMLINK", consumed: false) unless state.symlink?
  c2_fail("SDK_LINK_INODE", consumed: false) unless
    state.dev == 16_777_231 && state.ino == 1_082_900
  c2_fail("SDK_LINK_TARGET", consumed: false) unless
    File.readlink(SDK) == "MacOSX.sdk" && File.realpath(SDK) == SDK_RESOLVED
  true
end

def bootstrap_preflight
  c2_fail("BOOTSTRAP_CWD", consumed: false) unless
    Dir.pwd == "/private/var/empty"
  c2_fail("BOOTSTRAP_UID", consumed: false) unless
    Process.euid == EXPECTED_UID && Process.uid == EXPECTED_UID
  c2_fail("BOOTSTRAP_GID", consumed: false) unless
    Process.egid == EXPECTED_EGID && Process.gid == EXPECTED_EGID
  c2_fail("BOOTSTRAP_GROUPS", consumed: false) unless
    Process.groups.sort == EXPECTED_GROUPS.sort
  File.umask(0o077)
  verify_swift_build_link
  verify_sdk_link
  verify_resource_pack_constant
  live_interference_absent!
  ALL_FROZEN_ROOTS.each { |path| require_absent(path, "PREFLIGHT_ROOT") }
  tmp_io = open_held_path(PRIVATE_TMP, directory: true)
  require_directory_policy(
    PRIVATE_TMP, tmp_io, mode: "1777", uid: 0, gid: 0
  )
  continuity = VnodeContinuity.new
  dot_build = TreeSnapshot.new(SOURCE_LOCAL_DOT_BUILD).receipt
  controller_join = require_joined_process(Process.pid, "CONTROLLER")
  credentials = %w[uid gid ruid rgid svuid svgid].map do |field|
    controller_join.dig("short", field)
  end
  c2_fail("CONTROLLER_CREDENTIALS", consumed: false) unless
    credentials == [EXPECTED_UID, EXPECTED_EGID, EXPECTED_UID,
      EXPECTED_EGID, EXPECTED_UID, EXPECTED_EGID]
  ruby_node = continuity.node("/usr/bin/ruby")
  c2_fail("CONTROLLER_RUBY_NODE", consumed: false) unless ruby_node
  observed_path = process_path(Process.pid)
  c2_fail("CONTROLLER_IMAGE_PATH", consumed: false) unless
    observed_path == "/usr/bin/ruby"
  mapped = mapped_image_identity(
    Process.pid, "/usr/bin/ruby",
    controller_join.dig("unique", "uuid_hex")
  )
  c2_fail("CONTROLLER_IMAGE_MAP", consumed: false) unless
    mapped && mapped.fetch("device") == ruby_node.io.stat.dev &&
      mapped.fetch("inode") == ruby_node.io.stat.ino
  ALL_FROZEN_ROOTS.each { |path| require_absent(path, "IMMEDIATE_ROOT") }
  {
    "controller_join" => controller_join,
    "dot_build" => dot_build,
    "mapped_ruby" => mapped,
    "tmp_io" => tmp_io,
    "continuity" => continuity,
  }
rescue C2Failure => error
  raise C2Failure.new(error.code, consumed: false)
end

journal = nil
state = C2StateMachine.new
consumed = false

begin
  preflight = bootstrap_preflight
  continuity = preflight.fetch("continuity")
  tmp_io = preflight.fetch("tmp_io")
  controller_join = preflight.fetch("controller_join")
  dot_build_baseline = preflight.fetch("dot_build")
  consumed = true
  journal = DurableLeafJournal.new(tmp_io)
  journal.write_ordinary("00-start.json", {
    "consumption" => "CONSUMED_NO_RETRY",
    "control_commit" => CONTROL_COMMIT,
    "control_record_sha256" => CONTROL_RECORD_SHA256,
    "control_tree" => CONTROL_TREE,
    "controller" => process_receipt(controller_join),
    "mapped_ruby" => preflight.fetch("mapped_ruby"),
    "source_local_dot_build" => dot_build_baseline,
    "status" => "START_DURABLE",
  })
  state.advance!("start_durable")
  continuity.arm!
  state.advance!("source_armed")

  journal.write_ordinary("01-build-a-commitment.json", {
    "build" => "A",
    "build_root" => BUILD_A_ROOT,
    "continuity" => continuity.receipt,
    "environment" => "EMPTY_REPLACEMENT_FIXED_BY_ROOT_A",
    "maximum_swiftpm_groups_total" => 2,
    "physical_image" => SWIFT_PACKAGE,
    "status" => "BUILD_A_COMMITTED",
  })
  state.advance!("a_committed")
  a_namespace = BuildNamespace.new(tmp_io, BUILD_A_ROOT, "BUILD_A")
  swift_package_io = continuity.node(SWIFT_PACKAGE).io
  a_run = OwnedChildRun.new(
    a_namespace, continuity, swift_package_io, controller_join
  ).run
  journal.write_ordinary("02-build-a-result.json", {
    "build" => "A", "result" => a_run, "status" => "BUILD_A_REAPED",
  })
  state.advance!("a_reaped")
  a_admission = BuildAdmission.new(
    a_namespace, a_run, continuity, dot_build_baseline
  )
  journal.write_ordinary("03-build-a-admission.json", {
    "admission" => a_admission.receipt,
    "build" => "A",
    "status" => "BUILD_A_ADMISSION_PASS",
  })
  state.advance!("a_admitted")
  a_closure = RuntimeClosure.new(
    tmp_io, EXECUTION_CLOSURE_ROOT, a_admission, continuity, "CLOSURE_A"
  )
  journal.write_ordinary("04-closure-a-result.json", {
    "closure" => a_closure.receipt,
    "status" => "CLOSURE_A_DURABLE",
  })
  state.advance!("closure_a_durable")

  continuity.revalidate!("PRE_BUILD_B_COMMITMENT")
  a_closure.revalidate!
  require_absent_consumed(BUILD_B_ROOT, "BUILD_B_ROOT_PRECOMMIT")
  require_absent_consumed(BUILD_B_WITNESS_ROOT, "BUILD_B_CLOSURE_PRECOMMIT")
  journal.write_ordinary("05-build-b-commitment.json", {
    "build" => "B",
    "build_root" => BUILD_B_ROOT,
    "closure_a" => a_closure.receipt,
    "environment" => "EMPTY_REPLACEMENT_FIXED_BY_ROOT_B",
    "status" => "BUILD_B_COMMITTED_AFTER_A_ADMISSION",
  })
  state.advance!("b_committed")
  b_namespace = BuildNamespace.new(tmp_io, BUILD_B_ROOT, "BUILD_B")
  b_run = OwnedChildRun.new(
    b_namespace, continuity, swift_package_io, controller_join
  ).run
  journal.write_ordinary("06-build-b-result.json", {
    "build" => "B", "result" => b_run, "status" => "BUILD_B_REAPED",
  })
  state.advance!("b_reaped")
  b_admission = BuildAdmission.new(
    b_namespace, b_run, continuity, dot_build_baseline
  )
  journal.write_ordinary("07-build-b-admission.json", {
    "admission" => b_admission.receipt,
    "build" => "B",
    "status" => "BUILD_B_ADMISSION_PASS",
  })
  state.advance!("b_admitted")

  a_admission.revalidate_product!("PRE_RAW_COMPARE_A")
  b_admission.revalidate_product!("PRE_RAW_COMPARE_B")
  a_admission.revalidate_auxiliary!("PRE_RAW_COMPARE_A")
  b_admission.revalidate_auxiliary!("PRE_RAW_COMPARE_B")
  c2_fail("PRODUCT_VNODE_ALIAS") if
    [a_admission.product_io.stat.dev, a_admission.product_io.stat.ino] ==
      [b_admission.product_io.stat.dev, b_admission.product_io.stat.ino]
  c2_fail("PRODUCT_IDENTITY_SIZE") unless
    a_admission.product_identity.fetch("size") ==
      b_admission.product_identity.fetch("size")
  c2_fail("PRODUCT_IDENTITY_SHA256") unless
    a_admission.product_identity.fetch("sha256") ==
      b_admission.product_identity.fetch("sha256")
  c2_fail("PRODUCT_RAW_BYTES") unless
    compare_held_bytes(a_admission.product_io, b_admission.product_io)
  state.advance!("raw_equal")
  c2_fail("MACHO_PROJECTION_DRIFT") unless
    a_admission.macho == b_admission.macho
  c2_fail("BUILD_PLAN_PROJECTION_DRIFT") unless
    a_admission.normalized_plan_bytes == b_admission.normalized_plan_bytes &&
      a_admission.normalized_plan_sha256 == b_admission.normalized_plan_sha256
  c2_fail("LINK_LIST_PROJECTION_DRIFT") unless
    a_admission.normalized_link_bytes == b_admission.normalized_link_bytes &&
      a_admission.normalized_link_sha256 == b_admission.normalized_link_sha256
  b_closure = RuntimeClosure.new(
    tmp_io, BUILD_B_WITNESS_ROOT, b_admission, continuity, "CLOSURE_B"
  )
  closure_comparison = compare_runtime_closures(a_closure, b_closure)
  state.advance!("closure_pair_equal")
  continuity.revalidate!("FINAL_COMPARE")
  final_dot_build = TreeSnapshot.new(SOURCE_LOCAL_DOT_BUILD).receipt
  c2_fail("FINAL_SOURCE_DOT_BUILD_DRIFT") unless
    final_dot_build == dot_build_baseline
  journal.write_ordinary("08-compare-result.json", {
    "closure_comparison" => closure_comparison,
    "macho_projection_equal" => true,
    "normalized_link_list_equal" => true,
    "normalized_build_plan_equal" => true,
    "product_raw_equal" => true,
    "product_sha256" => a_admission.product_identity.fetch("sha256"),
    "source_local_dot_build" => final_dot_build,
    "status" => "PASS_EXACT_LOCAL_BUILD_IDENTITY_ONLY",
  })
  state.advance!("terminal_success")
  journal.write_terminal({
    "authority_vector" => "00000000",
    "builds" => 2,
    "gate_e" => "ABSTAIN",
    "product_executions" => 0,
    "runner_executions" => 0,
    "scientific_outcome" => "ABSTAIN",
    "candidate_outcome" => "PASS_EXACT_LOCAL_BUILD_IDENTITY_ONLY",
    "state" => "success_candidate_pending_root_seal",
    "status" => "SUCCESS_CANDIDATE_PENDING_ROOT_SEAL",
  })
  exit!(0)
rescue StandardError => error
  failed_from_state = state.state
  state.fail!
  if consumed && journal && !journal.poisoned
    begin
      code = error.is_a?(C2Failure) ? error.code : error.class.name
      journal.write_terminal({
        "authority_vector" => "00000000",
        "consumption" => "CONSUMED_NO_RETRY",
        "error_class" => error.class.name,
        "error_code" => code,
        "error_message_sha256" => Digest::SHA256.hexdigest(error.message.to_s.b),
        "gate_e" => "ABSTAIN",
        "runner_executions" => 0,
        "scientific_outcome" => "ABSTAIN",
        "failed_from_state" => failed_from_state,
        "state" => state.state,
        "candidate_outcome" => "FAIL_CONSUMED_RETAINED_PREFIX_NO_RETRY",
        "status" => "FAILURE_CANDIDATE_PENDING_ROOT_SEAL",
      })
    rescue StandardError
    end
  end
  exit!(consumed ? 70 : 77)
end

# frozen_string_literal: true

# This source is an external development tool. It is not an Xcode build input,
# app resource, launch service, or long-lived process. The qualification freeze
# is data describing the only admitted invocations; it is not runtime code.
module H3QualificationSeal
  ROOT = '/Users/ergentics/Developer/ErgenticsProvenance'.freeze
  SOURCE = 'Tools/H3QualificationSeal/h3_qualification_seal.rb'.freeze
  FREEZE_PATH = 'Control/hypervisor-local-v1/h3-signed-application-qualification-runner-freeze-2026-09-04.v1.json'.freeze
  FREEZE_COMMIT = '245382fb61fb94fe8ef29bcbfa00d6f39fa7d14a'.freeze
  FREEZE_SHA256 = '5f9d2510f3ff1b2c4b33eb33a4fae7e5b8b18a55f73ff0a22a045445653e68cf'.freeze
  PREDECESSOR = '461af031064b0529e7432b1f6cf0cfc2cbccec48'.freeze
  PREDECESSOR_TREE = '829331092cdc290f1a0e651fd64a9a56dd4187d2'.freeze
  PBX_PATH = 'ErgenticsProvenance.xcodeproj/project.pbxproj'.freeze
  PBX_BASELINE = 'b5fd9b2e1c72f54924269b6ff9453f87abeae5f2'.freeze
  PBX_BASELINE_SHA256 = '93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561'.freeze
  SCHEME_PATH = 'ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenanceH3Qualification.xcscheme'.freeze
  ENVIRONMENT = [
    'DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer',
    'GIT_CONFIG_GLOBAL=/dev/null', 'GIT_CONFIG_NOSYSTEM=1',
    'GIT_NO_LAZY_FETCH=1', 'GIT_OPTIONAL_LOCKS=0', 'HOME=/Users/ergentics',
    'LANG=C', 'LC_ALL=C', 'LOGNAME=ergentics',
    'PATH=/usr/bin:/bin:/usr/sbin:/sbin', 'TMPDIR=/private/tmp/',
    'USER=ergentics', '__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0'
  ].freeze
  MODES = %w[--check-ordinary-compatibility --seal-admission
             --run-admission-debug --run-admission-release --verify-admission
             --stage-guest --run-guest-debug --run-guest-release --verify-guest].freeze
  IMPLEMENTATION_PATHS = [
    PBX_PATH, SCHEME_PATH, 'Sources/DevelopmentLaunch.swift',
    'Sources/ProvenanceApp.swift', 'Sources/ProvenanceModel.swift',
    'Sources/HypervisorModel.swift', 'Sources/HypervisorH3LiveVerifier.swift',
    'Sources/DevelopmentRustBootExport.swift', 'Sources/H3QualificationProtocol.swift',
    'Sources/H3QualificationCoordinator.swift', SOURCE,
    'Tools/H3QualificationController/main.swift',
    'Tools/H3QualificationController/H3QualificationControllerPolicy.swift',
    'Tools/H3QualificationController/H3QualificationProcess.swift',
    'Tools/H3QualificationController/H3QualificationSigning.swift',
    'Tools/H3QualificationController/H3QualificationStorage.swift',
    'Tests/H3QualificationRunnerTests.swift'
  ].freeze
  DIRTY_PINS = [
    ['Control/hypervisor-local-v1/h2-live-build-plan.v1.json', 'b0a73ca324d0c7dc4e9619b549c2c4c85cbcae1e32a021f55d282a7c150470ba'],
    ['Control/hypervisor-local-v1/h2-live-build-wire.schema.v1.json', '307e614ca6940bb01a57c625ed8e2a22378269d0fc2c923b86154c2862ac79b1']
  ].freeze
  # Reject before support-library loading, evidence I/O, or a child spawn.
  if $PROGRAM_NAME == __FILE__
    unless $PROGRAM_NAME == ROOT + '/' + SOURCE && ARGV.length == 1 && MODES.include?(ARGV[0]) &&
           ENV.map { |key, value| key + '=' + value }.sort == ENVIRONMENT
      STDERR.write("H3 qualification seal: inadmissible argv or environment\n")
      exit(64)
    end
  end
end

require 'json'
require 'digest/sha1'
require 'digest/sha2'
require 'base64'
require 'fiddle/import'
require 'fcntl'

module H3QualificationSeal
  class Rejected < StandardError; end
  class Cancelled < Rejected; end
  class ContainmentUnproven < Rejected; end

  # Literal pins copied from the reviewed artifact; no runtime policy-file read.
  PIN_DATA = {"toolchain_pin"=>{"xcodebuild"=>"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild", "xcode_version"=>"26.6", "xcode_build_version"=>"17F113", "macos_sdk_version"=>"26.5", "swiftc"=>"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc", "swift_driver_version"=>"1.148.6", "swift_version"=>"6.3.3", "swift_build"=>"swiftlang-6.3.3.1.3 clang-2100.1.1.101", "target"=>"arm64-apple-macosx26.0", "architecture"=>"arm64", "macos_build"=>"25G83", "seal_launcher"=>"/usr/bin/env", "seal_launcher_sha256"=>"75690864f0e7397db05bcc0f4439915559ce24c2d834d530e4e619c14b938556", "seal_launcher_identifier"=>"com.apple.env", "seal_launcher_cdhash"=>"a6a8e7d5551056079e931c3b7f491ef3d41e3780", "seal_runtime"=>"/usr/bin/ruby", "seal_runtime_version"=>"2.6.10p210", "seal_runtime_revision"=>"67958", "seal_runtime_platform"=>"universal.arm64e-darwin25", "seal_runtime_sha256"=>"4d57327e7abe67e1c3f84a0869f4239b3324a3d7ea20a70077450e688282fe4f", "seal_runtime_identifier"=>"com.apple.ruby", "seal_runtime_cdhash"=>"6f4f8341f32e8e479783aa9e2fc9518693472df2", "seal_runtime_support_pins_sha256"=>"0273e30aa84370d5aa2440e1e870b3319f6a6a6fed81f9143f208da8f0833f2b", "qualification_rule"=>"Any different resolved Xcode, build version, SDK, compiler, target, seal runtime, project, source, or signing setting stops execution and requires a reviewed delta."}, "seal_runtime_support_pins"=>{"load_order_rule"=>"The seal source requires exactly json, digest/sha1, digest/sha2, base64, fiddle/import, and fcntl before any evidence root open or child spawn. Filter $LOADED_FEATURES to absolute paths, raw-UTF-8 sort that set, then require exact equality to these 26 entries in displayed order; each must be a root-owned regular nonsymlink with its exact SHA-256. Canonical JSON of this sorted array with keys path then sha256 and no whitespace hashes to 0273e30aa84370d5aa2440e1e870b3319f6a6a6fed81f9143f208da8f0833f2b.", "pins"=>[{"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/base64.rb", "sha256"=>"06bcb56e089cbb04d802814da487708a701445a123d4c52708afa41043778c41"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/digest.rb", "sha256"=>"eae3ead98eab5aba9c41030d7827b7225b223968a8f7e921c2dca72e72f7abcc"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/digest/sha2.rb", "sha256"=>"dd2bf31a36b6cb0088930a68e2a5390f2a2d93d2d6e61c6010fb4bbac1da7cac"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle.rb", "sha256"=>"d9f8894c029a2217fc368cb6fe26e11ea32270bdc98a68f4a0b33b8d1b55696a"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/closure.rb", "sha256"=>"762b117a58851789e4a5f3871bee97f453e04a1afe64e91c1937737427f418f5"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/cparser.rb", "sha256"=>"7dfbb2e84e823cca56990b43a9ac0ff2a04726d28d04d5a04aef90c11874bf42"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/function.rb", "sha256"=>"65524bcf2d69e3f7053aa476286f011f0523c6efe0ea6f5f3c373d9a9a2de5aa"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/import.rb", "sha256"=>"503d19010cacff71ecaf0789a8e24db7c87900b829829a20f24273df3950d829"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/pack.rb", "sha256"=>"134df1991cffe2ef273501001dfa077a7f6cae38f44b05d8aeeb2ce79f0c83c5"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/struct.rb", "sha256"=>"429f8525491e40c710b91ede8230aa7e1647f9d7eb66ace9d9e6a6c7532b6e7b"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fiddle/value.rb", "sha256"=>"af87eaf3c40a33c856d86bbbbc5faa8adcff5d68efb0850125b44579c54dcd90"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/json.rb", "sha256"=>"c8be18a279705593f35a9078773710a5e09bb715a2b5d08503b8f0620a6d7c26"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/json/common.rb", "sha256"=>"f27e766b87230f32ba84202148da1f5436ff0d20189a5109e0e029e2f7a5a75b"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/json/ext.rb", "sha256"=>"6759cf47337135c9954218820995d1f1337395906a1881264bba6c0cdb5d61cb"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/json/generic_object.rb", "sha256"=>"74244c827f6c26ac278dbfcd819fb0bde8572650a525de9b390ff5f672feb0f2"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/json/version.rb", "sha256"=>"3f0180bfd061cf17032d613c0a275dcf02b48b51a323dd103e43010c37dae1d7"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/ostruct.rb", "sha256"=>"917f9c5043db84d650c35f2f79b4f9624b06d73935357378663fea6dfbbcd655"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/digest.bundle", "sha256"=>"640e3b7f20a0f65cf014bf699c74530e345d3c4bbd8b9d07478be8025e0eddf7"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/digest/sha1.bundle", "sha256"=>"916b2bd7d3f7dde96e4bb79d9c3f389a90cdd9ffc0875e2ce85b57758c2ff9cf"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/digest/sha2.bundle", "sha256"=>"19e8db515d668ad2dba104957d7c65d2270e118e408b2fd6dc52d4994e0245b3"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/enc/encdb.bundle", "sha256"=>"1837b369a58b106569e1911f5a81f085344359541fccc5df4dd5516a91ea61a0"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/enc/trans/transdb.bundle", "sha256"=>"d5878c3fc5ab3dd287fa7243447071be33c2dc995fe9d0655d94c509846a8721"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/fcntl.bundle", "sha256"=>"09e256928b4b0a7fc067faced952dd4bb6c08b10f16ce56a63237606f97b1372"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/fiddle.bundle", "sha256"=>"1ae96f3da2566feaf1fc4776eff3d5c047403ed68cc7e101d9b71acb6ba85266"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/json/ext/generator.bundle", "sha256"=>"356f92e64a611ebd7a672705871ceea31f7a1407571492b087c8de9a4c9ff02c"}, {"path"=>"/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin25/json/ext/parser.bundle", "sha256"=>"ff31273463da5db5f3eb17cd5fdfab7965b4104f25a5265f82e220be07696891"}]}, "dirty_file_guard"=>{"tracked_unstaged_only"=>[{"path"=>"Control/hypervisor-local-v1/h2-live-build-plan.v1.json", "sha256"=>"b0a73ca324d0c7dc4e9619b549c2c4c85cbcae1e32a021f55d282a7c150470ba"}, {"path"=>"Control/hypervisor-local-v1/h2-live-build-wire.schema.v1.json", "sha256"=>"307e614ca6940bb01a57c625ed8e2a22378269d0fc2c923b86154c2862ac79b1"}], "index"=>"EMPTY", "preexisting_untracked_control_roots"=>53, "ambient_root_name_serialization"=>"Each following UTF-8 path exactly as stored, in the displayed LC_ALL=C byte order, followed by one LF including the final entry; no status prefix, count, blank line, NUL, or qualification-freeze path.", "ambient_root_names"=>["Control/capability-flow-closure-2026-08-31/", "Control/capability-namespace-2026-08-31.exGRYE/", "Control/deltapu-demonstration-2026-08-31.7uWX7J/", "Control/deltapu-gui-diagnostics-2026-08-31.UUKvMh/", "Control/deltapu-gui-readiness-2026-08-31.S6BVRj/", "Control/deltapu-gui-successor-2026-08-31.rmotTW/", "Control/deltapu-gui-v2-2026-08-31.UgzOFO/", "Control/deltapu-layout-primitive-2026-08-31.4F4qQa/", "Control/deltapu-reference-2026-08-31.w2FTKY/", "Control/deltapu-verification-boundary-2026-08-31.Fmwcqx/", "Control/functional-readiness-2026-08-31-r1/", "Control/functional-readiness-live-2026-08-31.ED79CA/", "Control/gui-environment-names-2026-08-30.t2kgKx/", "Control/gui-readiness-2026-08-30/", "Control/rust-first-boot-controls-2026-08-30.BOCnEm.archive-audit.stderr", "Control/rust-first-boot-controls-2026-08-30.BOCnEm.archive-audit.txt", "Control/rust-first-boot-controls-2026-08-30.BOCnEm.archive.json", "Control/rust-first-boot-controls-2026-08-30.BOCnEm.tar", "Control/rust-first-boot-controls-2026-08-30.BOCnEm/", "Control/rust-first-boot-entry-readiness-2026-08-31/", "Control/rust-first-boot-entry-v1/", "Control/rust-first-boot-live-readiness-2026-08-31.archive.json", "Control/rust-first-boot-live-readiness-2026-08-31.tar", "Control/rust-first-boot-live-readiness-2026-08-31/", "Control/rust-first-boot-materialization-handoff-2026-08-30.archive.json", "Control/rust-first-boot-materialization-handoff-2026-08-30.tar", "Control/rust-first-boot-materialization-handoff-2026-08-30/", "Control/rust-first-boot-materialization-result-v1/", "Control/rust-first-boot-materializer-build-2026-08-31.DRlbMB/", "Control/rust-first-boot-materializer-checkpoint-2026-08-31.archive.json", "Control/rust-first-boot-materializer-checkpoint-2026-08-31.tar", "Control/rust-first-boot-materializer-checkpoint-2026-08-31/", "Control/rust-first-boot-materializer-v1/", "Control/rust-first-boot-outer-build-2026-08-30.njdrYn/", "Control/rust-first-boot-outer-checkpoint-2026-08-30.KbpOX3.archive.json", "Control/rust-first-boot-outer-checkpoint-2026-08-30.KbpOX3.tar", "Control/rust-first-boot-outer-checkpoint-2026-08-30.KbpOX3/", "Control/rust-first-boot-outer-handoff-2026-08-30.archive-audit.stderr", "Control/rust-first-boot-outer-handoff-2026-08-30.archive-audit.txt", "Control/rust-first-boot-outer-handoff-2026-08-30.archive.json", "Control/rust-first-boot-outer-handoff-2026-08-30.tar", "Control/rust-first-boot-outer-handoff-2026-08-30/", "Control/rust-first-boot-outer-observer-v1/", "Control/rust-guest-bootstrap-2026-08-30.YtXTfY.archive.json", "Control/rust-guest-bootstrap-2026-08-30.YtXTfY.tar", "Control/rust-guest-bootstrap-2026-08-30.YtXTfY/", "Control/rust-guest-first-boot-freeze-2026-08-30/", "Control/rust-guest-integration-2026-08-30.fQdE42.archive.json", "Control/rust-guest-integration-2026-08-30.fQdE42.tar", "Control/rust-guest-integration-2026-08-30.fQdE42/", "Control/standalone-lifecycle-2026-08-31-r1/", "Control/verification-2026-08-30/", "Control/xcode-signed-archive-2026-08-31.Qaa3AE/"], "ambient_root_names_sha256"=>"1aa7745b2bfd2f8840bb6f636c43ef9139ebfce0e10d5cc40c8beb7d305f7db8", "preexisting_ignored_paths"=>7, "ignored_path_name_serialization"=>"Each following UTF-8 path exactly as stored, in the displayed LC_ALL=C byte order, followed by one LF including the final entry; no !! prefix, count, blank line, or NUL. This serialization is separate from ambient_root_names and does not change its count or hash.", "ignored_path_names"=>[".DS_Store", "Control/functional-readiness-2026-08-31-r1/verification.TCTqUA/DerivedData/", "Control/functional-readiness-live-2026-08-31.ED79CA/DerivedData/", "Control/standalone-lifecycle-2026-08-31-r1/verification.4ac3zI/DerivedData/", "DerivedData/", "ErgenticsProvenance.xcodeproj/project.xcworkspace/xcuserdata/", "ErgenticsProvenance.xcodeproj/xcuserdata/"], "ignored_path_names_sha256"=>"d06e3ba7884ccc4ed3d34ab0fa741bbf3f3c0fe1a2c3a43a0f07778054e9a0ec", "workspace_structural_directories_count"=>4, "workspace_structural_directory_serialization"=>"Each following trailing-slash UTF-8 directory path in displayed order followed by one LF including the final entry; these empty/untracked workspace ancestors are namespace structure, not source or evidence.", "workspace_structural_directories"=>["ErgenticsProvenance.xcodeproj/project.xcworkspace/", "ErgenticsProvenance.xcodeproj/project.xcworkspace/xcshareddata/", "ErgenticsProvenance.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/", "ErgenticsProvenance.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/configuration/"], "workspace_structural_directories_sha256"=>"43240b37a01222d07606e683dc9d0970e5322d4b79f5b87ba5156d205ad337f0", "prior_deep_inventory_note"=>"A prior pre/post host-suite inventory was reported as b6191d554b2b526c0ea71b194411a4830f58cff8c4927b05498b86f3e20672f3, but its serialization is not retained here and it is not used as a reproducible gate.", "preservation_rule"=>"Do not stage, move, normalize, prune, archive, clean, overwrite, or otherwise mutate the guarded files, ambient untracked evidence, or separately frozen ignored paths."}, "pinned_source_inputs"=>[{"path"=>"ErgenticsProvenance.xcodeproj/project.pbxproj", "git_blob"=>"b5fd9b2e1c72f54924269b6ff9453f87abeae5f2", "sha256"=>"93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561"}, {"path"=>"ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenance.xcscheme", "git_blob"=>"412b603ef4b0ca473dbae34dbd8051690e01a7b8", "sha256"=>"3a34c15f9ecb369fd18956ee671fa3b67d83414d6af35c4a9a486bcca1df4666"}, {"path"=>"Entitlements.plist", "git_blob"=>"d7bd491f0c772584a3bfa1b977306e3f31941bf4", "sha256"=>"ffab5dd538d1fc0aefa6b0e7facf2dcc4f0927845db0806b2bec82a617b2dcf2"}, {"path"=>"Sources/DevelopmentLaunch.swift", "git_blob"=>"c0814a3454b30ccf83b888ab1899c1779c2f96c8", "sha256"=>"c5470f01af214bd52b0f4b9048a54900de04a33e4974c53685f7da83ba4f10f6"}, {"path"=>"Sources/ProvenanceApp.swift", "git_blob"=>"a857dfbd24b8f494d44b9599fadbd1e214eaf203", "sha256"=>"ce66b6846cd08a9a7058d77d9a59b2da781364544b4cf6f2460b4e0fe2cd57cb"}, {"path"=>"Sources/ProvenanceModel.swift", "git_blob"=>"3c3e66a8b4ac75784f825ecf57b9c7510a6eb3c3", "sha256"=>"c4eb9d1fa4e5d69a48db70e26029090aa939e6eaf95d223cc25b86716f1ecb28"}, {"path"=>"Sources/ProvenanceReadOnly.c", "git_blob"=>"45292fa6c53b42b600be49dce90eed82e6cb84b7", "sha256"=>"78c4d4e2e8e4b50ee81b5a671b127dfb2fdad2ec812b67314bf6553af37fd0c6"}, {"path"=>"Sources/HypervisorModel.swift", "git_blob"=>"e57277d21cfffbdfd6c9bc8d71151d08460971a5", "sha256"=>"216a72a262f275ae9e1c6da57e3cb35ee9f76bcac41db484e7c9c80a27a36ede"}, {"path"=>"Sources/HypervisorGuest.c", "git_blob"=>"f4262e98bab43d9d649fa7a3b5d69d36f3cc3ec6", "sha256"=>"006b15327db939ad930ef8594eca61b5bbd71cc243250caee9393fbf539baf87"}, {"path"=>"Sources/HypervisorGuest.h", "git_blob"=>"4630c11f629f57b7086328448fabc1c7ddb18d35", "sha256"=>"d663619e58a267dce936a4551ba69a493c238fa9c6897ef68ebf003fa9dbb58d"}, {"path"=>"Sources/HypervisorH3LiveVerifier.swift", "git_blob"=>"3e2f7504e0d16df16c2064f41a7ddf4d1fd4bef1", "sha256"=>"3072f6b85a310ddc8c3a7bf5eedb8fe7ef7cfcd86fedd9d7b56593e5a54666cd"}, {"path"=>"Sources/DevelopmentRustBootExport.swift", "git_blob"=>"6c39514d5d617bbf95d5eef81fcb0a7ac49cd3d9", "sha256"=>"71cf5756b23e02bb139f7521d719d0620b62b1a3e1b6365bba6e5bf4fe93f1a9"}, {"path"=>"Guest/cursor-resume.S", "git_blob"=>"0abbf5d5cc460b6c8f042e6f80b9edf137b33182", "sha256"=>"5c0461d4d61bf798c334e33f822ff37f9e8f0b1a3272f812d4d2154ace4197a3"}]}.freeze

  # A check is required at every source-controlled iteration and syscall edge.
  # Cleanup owns a separate finite budget and deliberately does not clear this.
  class Budget
    attr_reader :cancelled
    def initialize
      @cancelled = false
    end
    def cancel
      @cancelled = true
    end
    def check
      raise Cancelled, 'mode alarm observed' if @cancelled
    end
  end

  module Check
    module_function
    def that(condition, reason)
      raise Rejected, reason unless condition
    end
    def u64(value)
      that(value.instance_of?(Integer) && value >= 0 && value <= 18_446_744_073_709_551_615, 'u64 overflow')
      value
    end
    def oid(value)
      that(value.instance_of?(String) && /\A[0-9a-f]{40}\z/.match?(value) && value != '0' * 40, 'invalid object ID')
      value
    end
    def path(value)
      that(value.instance_of?(String) && value.bytesize.between?(1, 4096), 'path size')
      text = value.dup.force_encoding(Encoding::UTF_8)
      that(text.valid_encoding? && !text.include?("\0") && !text.include?('\\'), 'path encoding')
      parts = text.split('/', -1)
      that(parts.length <= 8 && parts.none? { |x| x.empty? || x == '.' || x == '..' }, 'path component')
      text
    end
  end

  module Canonical
    module_function
    # Iterative encoding bounds the call stack even for rejected input. Sorting
    # valid UTF-8 keys by bytes is equivalent to Unicode scalar ordering.
    def encode(value, budget = Budget.new)
      output = String.new(encoding: Encoding::UTF_8)
      work = [[:value, value, 0]]
      until work.empty?
        budget.check
        kind, item, depth = work.pop
        if kind == :literal
          output << item
          next
        end
        Check.that(depth <= 32, 'canonical depth')
        case item
        when Hash
          Check.that(item.keys.all? { |k| k.instance_of?(String) && k.valid_encoding? }, 'canonical keys')
          keys = item.keys.sort_by(&:b)
          work << [:literal, '}', depth]
          keys.reverse_each.with_index do |key, reverse_index|
            budget.check
            work << [:literal, ',', depth] unless reverse_index == 0
            work << [:value, item.fetch(key), depth + 1]
            work << [:literal, ':', depth]
            work << [:value, key, depth + 1]
          end
          work << [:literal, '{', depth]
        when Array
          work << [:literal, ']', depth]
          item.reverse_each.with_index do |child, reverse_index|
            budget.check
            work << [:literal, ',', depth] unless reverse_index == 0
            work << [:value, child, depth + 1]
          end
          work << [:literal, '[', depth]
        when String
          Check.that(item.dup.force_encoding(Encoding::UTF_8).valid_encoding?, 'canonical UTF-8')
          output << JSON.generate(item)
        when Integer
          output << item.to_s
        when TrueClass then output << 'true'
        when FalseClass then output << 'false'
        when NilClass then output << 'null'
        else raise Rejected, 'canonical scalar type'
        end
        Check.that(output.bytesize <= 29_425_792, 'canonical byte limit')
      end
      output
    end

    def stream(bytes)
      { 'base64' => Base64.strict_encode64(bytes), 'byte_count' => bytes.bytesize,
        'sha256' => Digest::SHA256.hexdigest(bytes), 'truncated' => false }
    end
  end

  # Preflight never calls JSON.parse. It validates lexical limits and duplicate
  # keys using only an explicit bounded stack before a decoder sees the bytes.
  class JSONPreflight
    NORMAL = { depth: 32, tokens: 262_144, members: 8192, elements: 4096,
               string: 1_398_104, total_strings: 26_214_400, number: 21 }.freeze
    SETTINGS = { depth: 32, tokens: 65_536, members: 8192, elements: 4096,
                 string: 262_144, total_strings: 2_097_152, number: 0 }.freeze
    def initialize(bytes, budget = Budget.new, settings: false, maximum: 29_425_792)
      budget.check
      Check.that(bytes.instance_of?(String) && bytes.bytesize.between?(1, maximum), 'JSON input byte bound before allocation')
      @bytes = bytes.dup.force_encoding(Encoding::UTF_8)
      Check.that(@bytes.valid_encoding? && @bytes.bytesize.between?(1, maximum), 'JSON input bytes')
      @bytes = @bytes.b
      @budget, @limits, @settings = budget, settings ? SETTINGS : NORMAL, settings
      @at = @tokens = @strings = 0
    end

    def decode(canonical: false)
      scan
      @budget.check
      value = JSON.parse(@bytes, max_nesting: 32, allow_nan: false, create_additions: false)
      Check.that(Canonical.encode(value, @budget).b == @bytes.b, 'noncanonical JSON') if canonical
      value
    rescue JSON::ParserError, JSON::NestingError => error
      raise Rejected, 'JSON decode: ' + error.class.name
    end

    def scan
      stack = [{ kind: :root, state: :value, count: 0 }]
      until stack.empty?
        @budget.check
        space
        frame = stack[-1]
        case frame[:state]
        when :done
          Check.that(@at == @bytes.bytesize, 'JSON trailing bytes')
          stack.pop
        when :key, :key_or_end
          if peek == 125 && frame[:state] == :key_or_end
            @at += 1
            stack.pop
          else
            Check.that(peek == 34, 'JSON object key')
            key = string
            Check.that(!frame[:keys].key?(key), 'JSON duplicate key')
            frame[:keys][key] = true
            frame[:count] += 1
            Check.that(frame[:count] <= @limits[:members], 'JSON member limit')
            frame[:state] = :colon
          end
        when :colon
          take(58)
          frame[:state] = :value
        when :comma_object
          if peek == 125
            @at += 1
            stack.pop
          else
            take(44)
            frame[:state] = :key
          end
        when :comma_array
          if peek == 93
            @at += 1
            stack.pop
          else
            take(44)
            frame[:state] = :value
          end
        when :value, :value_or_end
          if frame[:state] == :value_or_end && peek == 93
            @at += 1
            stack.pop
            next
          end
          @tokens += 1
          Check.that(@tokens <= @limits[:tokens], 'JSON token limit')
          if frame[:kind] == :array
            frame[:count] += 1
            Check.that(frame[:count] <= @limits[:elements], 'JSON element limit')
          end
          frame[:state] = { root: :done, object: :comma_object, array: :comma_array }.fetch(frame[:kind])
          case peek
          when 123
            @at += 1
            Check.that(stack.length <= @limits[:depth], 'JSON depth')
            stack << { kind: :object, state: :key_or_end, count: 0, keys: {} }
          when 91
            @at += 1
            Check.that(stack.length <= @limits[:depth], 'JSON depth')
            stack << { kind: :array, state: :value_or_end, count: 0 }
          when 34 then string
          when 116, 102, 110
            Check.that(!@settings, 'build settings nonstring scalar')
            literal = { 116 => 'true', 102 => 'false', 110 => 'null' }.fetch(peek)
            Check.that(@bytes.byteslice(@at, literal.bytesize) == literal, 'JSON literal')
            @at += literal.bytesize
          else number
          end
        else raise Rejected, 'JSON machine state'
        end
      end
      true
    end

    private
    def peek
      @bytes.getbyte(@at)
    end
    def take(byte)
      Check.that(peek == byte, 'JSON delimiter')
      @at += 1
    end
    def space
      while [32, 9, 10, 13].include?(peek)
        @budget.check
        @at += 1
      end
    end
    def number
      Check.that(!@settings, 'build settings number')
      first = @at
      @at += 1 if peek == 45
      if peek == 48
        @at += 1
      else
        Check.that(peek && peek.between?(49, 57), 'JSON number start')
        while peek && peek.between?(48, 57)
          @budget.check
          @at += 1
          Check.that(@at - first <= @limits[:number], 'JSON number limit')
        end
      end
      token = @bytes.byteslice(first, @at - first)
      Check.that(token != '-0' && token.bytesize <= @limits[:number], 'JSON integer form')
      Check.that(![46, 69, 101].include?(peek), 'JSON noninteger form')
    end
    def hex4
      token = @bytes.byteslice(@at, 4)
      Check.that(token && /\A[0-9a-fA-F]{4}\z/.match?(token), 'JSON unicode escape')
      @at += 4
      token.to_i(16)
    end
    def string
      take(34)
      out = String.new(encoding: Encoding::BINARY)
      loop do
        @budget.check
        byte = peek
        Check.that(!byte.nil? && byte >= 32, 'JSON string scalar')
        @at += 1
        break if byte == 34
        if byte == 92
          escape = peek
          @at += 1
          replacements = { 34 => '"', 92 => '\\', 47 => '/', 98 => "\b", 102 => "\f", 110 => "\n", 114 => "\r", 116 => "\t" }
          if replacements.key?(escape)
            out << replacements.fetch(escape)
          elsif escape == 117
            scalar = hex4
            if scalar.between?(0xd800, 0xdbff)
              Check.that(@bytes.byteslice(@at, 2) == '\\u', 'JSON missing low surrogate')
              @at += 2
              low = hex4
              Check.that(low.between?(0xdc00, 0xdfff), 'JSON low surrogate')
              scalar = 0x10000 + ((scalar - 0xd800) << 10) + low - 0xdc00
            else
              Check.that(!scalar.between?(0xdc00, 0xdfff), 'JSON isolated surrogate')
            end
            out << [scalar].pack('U').b
          else raise Rejected, 'JSON escape'
          end
        else
          out << byte
        end
        Check.that(out.bytesize <= @limits[:string], 'JSON string limit')
      end
      out.force_encoding(Encoding::UTF_8)
      Check.that(out.valid_encoding?, 'JSON decoded UTF-8')
      @strings += out.bytesize
      Check.that(@strings <= @limits[:total_strings], 'JSON cumulative strings')
      out
    end
  end

  # OpenStep accepts only syntax needed for a PBX graph. A lexical/structural
  # pass precedes typed allocation; both passes use bounded explicit stacks.
  class OpenStep
    def initialize(bytes, budget = Budget.new)
      Check.that(bytes.bytesize.between?(1, 1_048_576), 'PBX byte limit')
      @text = bytes.dup.force_encoding(Encoding::UTF_8)
      Check.that(@text.valid_encoding? && !@text.include?("\0"), 'PBX UTF-8')
      @text = @text.b
      @budget = budget
    end
    def decode
      parse(false)
      parse(true)
    end
    private
    def parse(materialize)
      @at = @tokens = @decoded = 0
      stack = [{ kind: :root, state: :value, count: 0, value: nil }]
      answer = nil
      until stack.empty?
        @budget.check
        frame = stack[-1]
        token = lex
        case frame[:state]
        when :done
          Check.that(token.nil?, 'PBX trailing bytes')
          answer = frame[:value]
          stack.pop
        when :key, :key_or_end
          if token == [:mark, '}'] && frame[:state] == :key_or_end
            stack.pop
            attach(stack[-1], materialize ? frame[:value] : nil)
          else
            Check.that(token && token[0] == :scalar, 'PBX key')
            key = token[1]
            Check.that(!frame[:keys].key?(key), 'PBX duplicate key or object ID')
            frame[:keys][key] = true
            frame[:count] += 1
            Check.that(frame[:count] <= 65_536, 'PBX member limit')
            frame[:key], frame[:state] = key, :equals
          end
        when :equals
          Check.that(token == [:mark, '='], 'PBX equals')
          frame[:state] = :value
        when :semicolon
          Check.that(token == [:mark, ';'], 'PBX semicolon')
          frame[:state] = :key_or_end
        when :comma
          if token == [:mark, ')']
            stack.pop
            attach(stack[-1], materialize ? frame[:value] : nil)
          else
            Check.that(token == [:mark, ','], 'PBX array comma')
            frame[:state] = :value_or_end
          end
        when :value, :value_or_end
          if token == [:mark, ')'] && frame[:state] == :value_or_end
            stack.pop
            attach(stack[-1], materialize ? frame[:value] : nil)
            next
          end
          Check.that(!token.nil?, 'PBX missing value')
          if frame[:kind] == :array
            frame[:count] += 1
            Check.that(frame[:count] <= 65_536, 'PBX array limit')
          end
          if token[0] == :scalar
            attach(frame, materialize ? token[1] : nil)
          elsif token == [:mark, '{'] || token == [:mark, '(']
            Check.that(stack.length <= 32, 'PBX depth')
            object = token[1] == '{'
            stack << { kind: object ? :object : :array, state: object ? :key_or_end : :value_or_end,
                       count: 0, keys: {}, value: materialize ? (object ? {} : []) : nil }
          else raise Rejected, 'PBX value delimiter'
          end
        else raise Rejected, 'PBX parser state'
        end
      end
      answer
    end
    def attach(frame, value)
      case frame[:kind]
      when :root
        frame[:value], frame[:state] = value, :done
      when :object
        frame[:value][frame[:key]] = value if frame[:value]
        frame[:state] = :semicolon
      when :array
        frame[:value] << value if frame[:value]
        frame[:state] = :comma
      end
    end
    def lex
      loop do
        @budget.check
        byte = @text.getbyte(@at)
        return nil unless byte
        if [32, 9, 10, 13].include?(byte)
          @at += 1
        elsif @text.byteslice(@at, 2) == '//'
          start = @at
          @at += 2
          while @at < @text.bytesize && @text.getbyte(@at) != 10
            @budget.check
            @at += 1
            Check.that(@at - start <= 262_144, 'PBX comment limit')
          end
          decoded(@at - start)
        elsif @text.byteslice(@at, 2) == '/*'
          start = @at
          @at += 2
          until @text.byteslice(@at, 2) == '*/'
            @budget.check
            Check.that(@at < @text.bytesize && @at - start <= 262_144, 'PBX block comment')
            @at += 1
          end
          @at += 2
          decoded(@at - start)
        else break
        end
      end
      byte = @text.getbyte(@at)
      if '{}()=;,'.bytes.include?(byte)
        if [123, 40].include?(byte)
          @tokens += 1
          Check.that(@tokens <= 131_072, 'PBX token limit')
        end
        @at += 1
        return [:mark, byte.chr]
      end
      @tokens += 1
      Check.that(@tokens <= 131_072, 'PBX token limit')
      output = String.new(encoding: Encoding::BINARY)
      if byte == 34
        @at += 1
        loop do
          @budget.check
          byte = @text.getbyte(@at)
          Check.that(byte && byte >= 32, 'PBX quoted scalar')
          @at += 1
          break if byte == 34
          if byte == 92
            byte = @text.getbyte(@at)
            @at += 1
            escapes = { 34 => '"', 92 => '\\', 110 => "\n", 114 => "\r", 116 => "\t" }
            Check.that(escapes.key?(byte), 'PBX quoted escape')
            output << escapes.fetch(byte)
          else output << byte
          end
          Check.that(output.bytesize <= 262_144, 'PBX scalar limit')
        end
      else
        while (byte = @text.getbyte(@at)) && ((48..57).cover?(byte) || (65..90).cover?(byte) || (97..122).cover?(byte) || '_./$+-'.bytes.include?(byte))
          @budget.check
          output << byte
          @at += 1
          Check.that(output.bytesize <= 262_144, 'PBX identifier limit')
        end
        Check.that(!output.empty?, 'PBX invalid identifier')
      end
      output.force_encoding(Encoding::UTF_8)
      Check.that(output.valid_encoding?, 'PBX decoded UTF-8')
      decoded(output.bytesize)
      [:scalar, output]
    end
    def decoded(count)
      @decoded += count
      Check.that(@decoded <= 2_097_152, 'PBX decoded token total')
    end
  end

  class QualificationScheme
    DECLARATION = '<?xml version="1.0" encoding="UTF-8"?>'.freeze
    ENTRY = { 'buildForAnalyzing' => 'YES', 'buildForArchiving' => 'NO',
              'buildForProfiling' => 'NO', 'buildForRunning' => 'YES', 'buildForTesting' => 'NO' }.freeze
    def self.validate(bytes, budget = Budget.new)
      Check.that(bytes.bytesize.between?(1, 8192) && bytes.ascii_only?, 'scheme bytes')
      Check.that(bytes.start_with?(DECLARATION), 'scheme declaration')
      text, at, tokens = bytes.b, DECLARATION.bytesize, 1
      expected = [
        ['Scheme', { 'LastUpgradeVersion' => '2660', 'version' => '1.7' }],
        ['BuildAction', { 'parallelizeBuildables' => 'NO', 'buildImplicitDependencies' => 'NO' }],
        ['BuildActionEntries', {}], ['BuildActionEntry', ENTRY],
        ['BuildableReference', reference('B40000000000000000000001', 'Ergentics Provenance.app', 'ErgenticsProvenance')],
        ['BuildActionEntry', ENTRY],
        ['BuildableReference', reference('D30000000000000000000001', 'ErgenticsProvenanceH3QualificationController', 'ErgenticsProvenanceH3QualificationController')]
      ]
      expected_events = [[:start, 0], [:start, 1], [:start, 2], [:start, 3], [:start, 4], [:end, 4], [:end, 3],
                         [:start, 5], [:start, 6], [:end, 6], [:end, 5], [:end, 2], [:end, 1], [:end, 0]]
      events, stack, elements = [], [], 0
      while at < text.bytesize
        budget.check
        if [32, 9, 10, 13].include?(text.getbyte(at))
          at += 1
          next
        end
        Check.that(text.getbyte(at) == 60, 'scheme inter-element text')
        at += 1
        closing = text.getbyte(at) == 47
        at += 1 if closing
        match = /\A[A-Za-z][A-Za-z0-9]*/.match(text.byteslice(at, text.bytesize - at))
        Check.that(match, 'scheme element name')
        name = match[0]
        at += name.bytesize
        tokens += 1
        if closing
          Check.that(text.getbyte(at) == 62 && !stack.empty? && stack[-1][0] == name, 'scheme close')
          at += 1
          events << [:end, stack.pop[1]]
          next
        end
        attributes = {}
        loop do
          budget.check
          separator = false
          while [32, 9, 10, 13].include?(text.getbyte(at))
            budget.check
            separator = true
            at += 1
          end
          break if [47, 62].include?(text.getbyte(at))
          Check.that(separator, 'scheme attribute separation')
          match = /\A[A-Za-z][A-Za-z0-9]*/.match(text.byteslice(at, text.bytesize - at))
          Check.that(match && match[0].bytesize <= 128, 'scheme attribute name')
          key = match[0]
          at += key.bytesize
          while [32, 9, 10, 13].include?(text.getbyte(at)); budget.check; at += 1; end
          Check.that(text.getbyte(at) == 61, 'scheme attribute equals')
          at += 1
          while [32, 9, 10, 13].include?(text.getbyte(at)); budget.check; at += 1; end
          quote = text.getbyte(at)
          Check.that([34, 39].include?(quote), 'scheme attribute quote')
          at += 1
          value = String.new
          until text.getbyte(at) == quote
            budget.check
            byte = text.getbyte(at)
            Check.that(byte && byte >= 32 && byte != 60, 'scheme attribute scalar')
            if byte == 38
              entity = /\A&(amp|lt|gt|quot|apos);/.match(text.byteslice(at, 6))
              Check.that(entity, 'scheme entity')
              value << { 'amp' => '&', 'lt' => '<', 'gt' => '>', 'quot' => '"', 'apos' => "'" }.fetch(entity[1])
              at += entity[0].bytesize
            else
              value << byte
              at += 1
            end
            Check.that(value.bytesize <= 128, 'scheme attribute value size')
          end
          at += 1
          Check.that(!attributes.key?(key) && attributes.length < 8, 'scheme duplicate or excess attributes')
          attributes[key] = value
          tokens += 2
          Check.that(tokens <= 128, 'scheme lexical tokens')
        end
        self_close = text.getbyte(at) == 47
        at += 1 if self_close
        Check.that(text.getbyte(at) == 62, 'scheme tag end')
        at += 1
        Check.that(elements < 7 && expected[elements] == [name, attributes], 'scheme semantic graph')
        Check.that(stack.length < 5, 'scheme depth')
        index = elements
        elements += 1
        events << [:start, index]
        if self_close
          events << [:end, index]
        else stack << [name, index]
        end
      end
      Check.that(stack.empty? && elements == 7 && events == expected_events, 'scheme exact ordered graph')
      true
    end
    def self.reference(id, product, target)
      { 'BuildableIdentifier' => 'primary', 'BlueprintIdentifier' => id, 'BuildableName' => product,
        'BlueprintName' => target, 'ReferencedContainer' => 'container:ErgenticsProvenance.xcodeproj' }
    end
  end

  module GitObjects
    ZERO = ('0' * 40).freeze
    module_function
    def nul_records(bytes, maximum, budget)
      records, offset = [], 0
      while offset < bytes.bytesize
        budget.check
        Check.that(records.length < maximum, 'NUL record count')
        endpoint = bytes.index("\0", offset)
        Check.that(endpoint, 'missing NUL record separator')
        records << bytes.byteslice(offset, endpoint - offset)
        offset = endpoint + 1
      end
      records
    end
    def listing(bytes, budget = Budget.new)
      Check.that(bytes.bytesize <= 65_536 && bytes.end_with?("\0"), 'tree listing framing')
      rows = nul_records(bytes, 254, budget)
      Check.that(rows.length.between?(2, 254), 'tree listing count')
      result, paths = [], {}
      rows.each do |row|
        budget.check
        match = /\A(100644|100755) blob ([0-9a-f]{40})\t([^\0]+)\z/.match(row)
        Check.that(match, 'tree listing grammar')
        path = Check.path(match[3])
        Check.that(!paths.key?(path), 'tree duplicate path')
        paths[path] = true
        result << { 'mode' => match[1], 'oid' => Check.oid(match[2]), 'path' => path }
      end
      Check.that(result.map { |r| r['path'].b } == result.map { |r| r['path'].b }.sort, 'tree listing path order')
      reconstruct(result, budget)
      result
    end

    def delta(bytes, budget = Budget.new)
      Check.that(bytes.bytesize.between?(1, 65_536) && bytes.end_with?("\0"), 'raw delta framing')
      rows = nul_records(bytes, 34, budget)
      Check.that(rows.length.even?, 'raw delta count')
      result = []
      rows.each_slice(2) do |header, path|
        budget.check
        match = /\A:(000000|100644|100755) (100644|100755) ([0-9a-f]{40}) ([0-9a-f]{40}) ([AM])\z/.match(header)
        Check.that(match, 'raw delta grammar')
        old_mode, new_mode, old_oid, new_oid, status = match.captures
        Check.oid(new_oid)
        if status == 'A'
          Check.that(old_mode == '000000' && old_oid == ZERO, 'raw addition tuple')
        else
          Check.oid(old_oid)
          Check.that(old_mode != '000000' && [old_mode, old_oid] != [new_mode, new_oid], 'raw modification tuple')
        end
        result << { 'old_mode' => old_mode, 'mode' => new_mode, 'old_oid' => old_oid,
                    'oid' => new_oid, 'status' => status, 'path' => Check.path(path) }
      end
      paths = result.map { |row| row['path'].b }
      Check.that(paths == paths.sort && paths.uniq == paths, 'raw delta path order')
      result
    end

    def reverse(entries, delta, budget = Budget.new)
      map = entries.each_with_object({}) { |entry, result| result[entry.fetch('path')] = entry.dup }
      delta.reverse_each do |change|
        budget.check
        current = map[change.fetch('path')]
        Check.that(current && current.values_at('mode', 'oid') == change.values_at('mode', 'oid'), 'reverse delta new leaf')
        if change['status'] == 'A'
          map.delete(change['path'])
        else
          map[change['path']] = { 'path' => change['path'], 'mode' => change['old_mode'], 'oid' => change['old_oid'] }
        end
      end
      result = map.values.sort_by { |entry| entry['path'].b }
      reconstruct(result, budget)
      result
    end

    def reconstruct(entries, budget = Budget.new)
      directories = { '' => {} }
      entries.each do |entry|
        budget.check
        parts, directory = Check.path(entry.fetch('path')).split('/'), ''
        parts.each_with_index do |part, index|
          budget.check
          final = index == parts.length - 1
          current = directories.fetch(directory)
          if final
            Check.that(!current.key?(part), 'tree file/directory collision')
            Check.that(%w[100644 100755].include?(entry['mode']), 'tree mode')
            current[part] = [:file, entry['mode'], Check.oid(entry['oid'])]
          else
            path = directory.empty? ? part : directory + '/' + part
            Check.that(!current.key?(part) || current[part] == [:directory, path], 'tree directory/file collision')
            current[part] = [:directory, path]
            directories[path] ||= {}
            directory = path
          end
        end
      end
      Check.that(directories.length <= 1779, 'tree directory limit')
      tree_records, oids = [], {}
      directories.keys.sort_by { |path| [-path.count('/'), -path.bytesize] }.each do |path|
        budget.check
        children = directories.fetch(path)
        payload = String.new(encoding: Encoding::BINARY)
        children.keys.sort_by { |name| name.b + (children[name][0] == :directory ? '/' : "\0") }.each do |name|
          budget.check
          node = children.fetch(name)
          mode, oid = node[0] == :directory ? ['40000', oids.fetch(node[1])] : [node[1], node[2]]
          payload << mode << ' ' << name.b << "\0" << [oid].pack('H*')
        end
        oid = Digest::SHA1.hexdigest("tree #{payload.bytesize}\0".b + payload)
        oids[path] = oid
        tree_records << { 'oid' => oid, 'path' => path, 'payload_byte_count' => payload.bytesize,
                          'payload_sha256' => Digest::SHA256.hexdigest(payload) }
      end
      { 'root_oid' => oids.fetch(''), 'blob_count' => entries.length, 'subtree_count' => directories.length,
        'trees_sha256' => Digest::SHA256.hexdigest(Canonical.encode(tree_records.sort_by { |row| row['path'].b }, budget)) }
    end

    def commit(bytes, expected_oid, expected_tree, expected_parent, budget = Budget.new)
      Check.that(bytes.bytesize.between?(1, 1_048_576), 'commit byte limit')
      Check.that(Digest::SHA1.hexdigest("commit #{bytes.bytesize}\0".b + bytes.b) == expected_oid, 'commit raw OID')
      separator = bytes.index("\n\n")
      Check.that(separator && separator > 0, 'commit header terminator')
      trees, parents, prior = [], [], nil
      bytes.byteslice(0, separator).split("\n", -1).each do |line|
        budget.check
        if line.start_with?(' ')
          Check.that(prior && !%w[tree parent].include?(prior), 'commit header continuation')
        else
          match = /\A([a-z][a-z0-9-]*) ([^\0\r\n]+)\z/.match(line)
          Check.that(match, 'commit header grammar')
          prior = match[1]
          trees << Check.oid(match[2]) if prior == 'tree'
          parents << Check.oid(match[2]) if prior == 'parent'
        end
      end
      Check.that(trees == [expected_tree] && parents == [expected_parent], 'commit tree/sole-parent join')
      { 'byte_count' => bytes.bytesize, 'parent' => parents[0], 'parent_count' => 1,
        'recomputed_oid' => expected_oid, 'sha256' => Digest::SHA256.hexdigest(bytes), 'tree' => trees[0] }
    end

    def index(bytes, entries, budget = Budget.new)
      expected = String.new(encoding: Encoding::BINARY)
      entries.each do |entry|
        budget.check
        expected << entry.fetch('mode') << ' ' << entry.fetch('oid') << " 0\t" << entry.fetch('path').b << "\0"
      end
      Check.that(bytes.b == expected, 'index differs from implementation tree')
      true
    end
  end

  class PBXDelta
    APP = 'B40000000000000000000001'.freeze
    CONTROLLER = 'D30000000000000000000001'.freeze
    CONTROLLER_NAME = 'ErgenticsProvenanceH3QualificationController'.freeze
    APP_SOURCES = %w[Sources/H3QualificationProtocol.swift Sources/H3QualificationCoordinator.swift].freeze
    TEST_SOURCES = %w[Sources/H3QualificationProtocol.swift Tools/H3QualificationController/H3QualificationControllerPolicy.swift Tests/H3QualificationRunnerTests.swift].freeze
    CONTROLLER_SOURCES = %w[Sources/H3QualificationProtocol.swift Tools/H3QualificationController/main.swift Tools/H3QualificationController/H3QualificationControllerPolicy.swift Tools/H3QualificationController/H3QualificationProcess.swift Tools/H3QualificationController/H3QualificationSigning.swift Tools/H3QualificationController/H3QualificationStorage.swift].freeze
    SETTINGS = {
      'CODE_SIGN_IDENTITY' => 'Apple Development', 'CODE_SIGN_STYLE' => 'Automatic',
      'CODE_SIGNING_ALLOWED' => 'YES', 'CODE_SIGNING_REQUIRED' => 'YES',
      'CODE_SIGN_INJECT_BASE_ENTITLEMENTS' => 'NO', 'CREATE_INFOPLIST_SECTION_IN_BINARY' => 'YES',
      'DEVELOPMENT_TEAM' => 'ZCQ435U8JP', 'ENABLE_APP_SANDBOX' => 'NO',
      'ENABLE_HARDENED_RUNTIME' => 'YES', 'GENERATE_INFOPLIST_FILE' => 'YES',
      'MACOSX_DEPLOYMENT_TARGET' => '26.0',
      'PRODUCT_BUNDLE_IDENTIFIER' => 'com.ergentics.provenance.h3-qualification-controller',
      'PRODUCT_NAME' => CONTROLLER_NAME, 'SKIP_INSTALL' => 'YES', 'SWIFT_VERSION' => '6.0'
    }.freeze

    def self.validate(baseline_bytes, implementation_bytes, budget = Budget.new)
      new(baseline_bytes, implementation_bytes, budget).validate
    end
    def initialize(baseline_bytes, implementation_bytes, budget)
      @budget = budget
      Check.that(Digest::SHA256.hexdigest(baseline_bytes) == PBX_BASELINE_SHA256, 'PBX baseline SHA256')
      Check.that(Digest::SHA1.hexdigest("blob #{baseline_bytes.bytesize}\0".b + baseline_bytes.b) == PBX_BASELINE, 'PBX baseline OID')
      @baseline = OpenStep.new(baseline_bytes, budget).decode
      @implementation = OpenStep.new(implementation_bytes, budget).decode
    end
    def validate
      Check.that(@baseline.instance_of?(Hash) && @implementation.instance_of?(Hash), 'PBX root object')
      Check.that(@baseline.reject { |key, _| key == 'objects' } == @implementation.reject { |key, _| key == 'objects' }, 'PBX root mutation')
      @old, @new = @baseline.fetch('objects'), @implementation.fetch('objects')
      Check.that(@old.instance_of?(Hash) && @new.instance_of?(Hash) && (@old.keys - @new.keys).empty?, 'PBX object removal')
      @new.each do |id, object|
        @budget.check
        Check.that(/\A[0-9A-Fa-f]{24}\z/.match?(id) && object.instance_of?(Hash) && object['isa'].instance_of?(String), 'PBX typed object')
      end
      @added = @new.keys - @old.keys
      @consumed = {}
      @referenced_refs = {}
      @paths = resolve_paths(@new)
      tests = @old.find { |_, object| object['isa'] == 'PBXNativeTarget' && object['name'] == 'ProvenanceTests' }
      Check.that(tests, 'PBX baseline test target')
      @test_id = tests[0]
      app_phase = source_phase(@old, APP)
      test_phase = source_phase(@old, @test_id)
      @source_phase_additions = { app_phase => APP_SOURCES, test_phase => TEST_SOURCES }
      @test_configs = configs(@old, @test_id)
      product_ref = @new.fetch(CONTROLLER).fetch('productReference')
      @old.each do |id, before|
        @budget.check
        after = @new.fetch(id)
        if @source_phase_additions.key?(id)
          unchanged_except(before, after, ['files'])
          added = appended(before.fetch('files'), after.fetch('files'))
          Check.that(membership_paths(added).sort == @source_phase_additions.fetch(id).sort, 'PBX existing source membership delta')
        elsif @test_configs.include?(id)
          unchanged_except(before, after, ['buildSettings'])
          left, right = before.fetch('buildSettings'), after.fetch('buildSettings')
          unchanged_except(left, right, ['SWIFT_ACTIVE_COMPILATION_CONDITIONS'])
          prior = left.fetch('SWIFT_ACTIVE_COMPILATION_CONDITIONS')
          Check.that(prior.instance_of?(Array) && right['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] == prior + ['EPR_H3_QUALIFICATION_TESTS'], 'PBX test compilation conditions')
        elsif before['isa'] == 'PBXGroup'
          unchanged_except(before, after, ['children'])
          added = appended(before.fetch('children'), after.fetch('children'))
          Check.that(added.all? { |child| @added.include?(child) }, 'PBX existing group adds existing object')
        elsif before['isa'] == 'PBXProject'
          unchanged_except(before, after, ['targets'])
          Check.that(after['targets'] == before.fetch('targets') + [CONTROLLER], 'PBX target addition')
          products = @new.fetch(after.fetch('productRefGroup'))
          Check.that(products.fetch('children').include?(product_ref), 'PBX controller product group')
        else Check.that(before == after, 'PBX unrelated existing object mutation')
        end
      end
      validate_controller(product_ref)
      # Every new object has an exact role and must be reachable through the
      # admitted target membership/group graph. Dead objects cannot hide code.
      @added.each do |id|
        @budget.check
        object = @new.fetch(id)
        case object['isa']
        when 'PBXFileReference'
          valid_file_reference(id, object, product_ref)
        when 'PBXGroup'
          Check.that((object.keys - %w[isa children name path sourceTree]).empty? && object['sourceTree'] == '<group>', 'PBX new group fields')
          Check.that(object['children'].instance_of?(Array) && !object['children'].empty?, 'PBX unnecessary empty group')
          Check.that(object['children'].uniq == object['children'] && object['children'].all? { |child| @added.include?(child) }, 'PBX new group children')
          Check.that(@paths.key?(id), 'PBX unattached new group')
          @consumed[id] = true
        when 'PBXBuildFile', 'PBXNativeTarget', 'PBXSourcesBuildPhase', 'PBXFrameworksBuildPhase', 'XCBuildConfiguration', 'XCConfigurationList'
          Check.that(@consumed[id], 'PBX unconsumed executable object')
        else raise Rejected, 'PBX forbidden added object class'
        end
      end
      expected = (APP_SOURCES + TEST_SOURCES + CONTROLLER_SOURCES).uniq.sort
      actual = @added.each_with_object([]) do |id, result|
        object = @new.fetch(id)
        result << @paths[id] if object['isa'] == 'PBXFileReference' && @paths[id] && @paths[id].end_with?('.swift')
      end
      Check.that(actual.sort == expected, 'PBX exact new source references')
      true
    rescue KeyError, TypeError, NoMethodError
      raise Rejected, 'PBX missing or ill-typed graph field'
    end
    private
    def unchanged_except(before, after, fields)
      Check.that(before.reject { |key, _| fields.include?(key) } == after.reject { |key, _| fields.include?(key) }, 'PBX unexpected field mutation')
    end
    def appended(before, after)
      Check.that(before.instance_of?(Array) && after.instance_of?(Array) && after.select { |id| before.include?(id) } == before && after.uniq == after, 'PBX list removes or reorders an existing entry')
      after.reject { |id| before.include?(id) }
    end
    def source_phase(objects, target)
      phases = objects.fetch(target).fetch('buildPhases').select { |id| objects.fetch(id)['isa'] == 'PBXSourcesBuildPhase' }
      Check.that(phases.length == 1, 'PBX source phase count')
      phases[0]
    end
    def configs(objects, target)
      objects.fetch(objects.fetch(target).fetch('buildConfigurationList')).fetch('buildConfigurations')
    end
    def resolve_paths(objects)
      project = objects.fetch(@implementation.fetch('rootObject'))
      paths, pending = {}, [[project.fetch('mainGroup'), '']]
      until pending.empty?
        @budget.check
        id, prefix = pending.pop
        Check.that(!paths.key?(id), 'PBX group cycle or duplicate reference')
        object = objects.fetch(id)
        tree = object.fetch('sourceTree', '<group>')
        path = object.fetch('path', '')
        Check.that(path.instance_of?(String), 'PBX group path type')
        resolved = if tree == '<group>'
                     path.empty? ? prefix : (prefix.empty? ? path : prefix + '/' + path)
                   elsif %w[SDKROOT BUILT_PRODUCTS_DIR DEVELOPER_DIR SOURCE_ROOT].include?(tree)
                     tree + ':' + path
                   else raise Rejected, 'PBX unsupported source tree'
                   end
        paths[id] = resolved
        if object['isa'] == 'PBXGroup'
          children = object.fetch('children')
          Check.that(children.instance_of?(Array) && children.uniq == children, 'PBX group child shape')
          children.reverse_each { |child| @budget.check; pending << [child, resolved] }
        else
          Check.that(object['isa'] == 'PBXFileReference', 'PBX group contains forbidden object')
        end
      end
      paths
    end
    def membership_paths(ids)
      Check.that(ids.instance_of?(Array) && ids.uniq == ids, 'PBX membership duplicate')
      ids.map do |id|
        @budget.check
        object = @new.fetch(id)
        Check.that(@added.include?(id) && object.keys.sort == %w[fileRef isa] && object['isa'] == 'PBXBuildFile', 'PBX added build file')
        Check.that(!@consumed[id], 'PBX reused added build file')
        @consumed[id] = true
        reference = object.fetch('fileRef')
        @referenced_refs[reference] = true
        @paths.fetch(reference)
      end
    end
    def validate_controller(product_ref)
      target = @new.fetch(CONTROLLER)
      Check.that(@added.include?(CONTROLLER) && target.keys.sort == %w[buildConfigurationList buildPhases buildRules dependencies isa name productName productReference productType], 'PBX controller target fields')
      Check.that(target['isa'] == 'PBXNativeTarget' && target['name'] == CONTROLLER_NAME && target['productName'] == CONTROLLER_NAME && target['productType'] == 'com.apple.product-type.tool', 'PBX controller target identity')
      Check.that(target['buildRules'] == [] && target['dependencies'] == [] && target['buildPhases'].length == 2, 'PBX controller phase/rule/dependency')
      @consumed[CONTROLLER] = true
      phases = target['buildPhases'].map do |id|
        @budget.check
        object = @new.fetch(id)
        Check.that(@added.include?(id) && object.keys.sort == %w[buildActionMask files isa runOnlyForDeploymentPostprocessing], 'PBX new phase fields')
        Check.that(object['buildActionMask'] == '2147483647' && object['runOnlyForDeploymentPostprocessing'] == '0', 'PBX new phase flags')
        @consumed[id] = true
        [object['isa'], membership_paths(object['files'])]
      end
      source = phases.select { |kind, _| kind == 'PBXSourcesBuildPhase' }
      framework = phases.select { |kind, _| kind == 'PBXFrameworksBuildPhase' }
      Check.that(source.length == 1 && source[0][1].sort == CONTROLLER_SOURCES.sort, 'PBX controller sources')
      Check.that(framework.length == 1 && framework[0][1].map { |path| path.split('/').last }.sort == %w[Foundation.framework Security.framework], 'PBX controller frameworks')
      list_id = target.fetch('buildConfigurationList')
      list = @new.fetch(list_id)
      Check.that(@added.include?(list_id) && list.keys.sort == %w[buildConfigurations defaultConfigurationIsVisible defaultConfigurationName isa], 'PBX controller configuration list fields')
      Check.that(list['isa'] == 'XCConfigurationList' && list['defaultConfigurationIsVisible'] == '0' && list['defaultConfigurationName'] == 'Release', 'PBX controller configuration list values')
      @consumed[list_id] = true
      names = list.fetch('buildConfigurations').map do |id|
        @budget.check
        configuration = @new.fetch(id)
        Check.that(@added.include?(id) && configuration.keys.sort == %w[buildSettings isa name] && configuration['isa'] == 'XCBuildConfiguration', 'PBX controller configuration fields')
        Check.that(configuration['buildSettings'] == SETTINGS, 'PBX controller explicit settings')
        @consumed[id] = true
        configuration['name']
      end
      Check.that(names == %w[Debug Release], 'PBX controller configurations')
      Check.that(@paths[product_ref] == 'BUILT_PRODUCTS_DIR:' + CONTROLLER_NAME, 'PBX product reference path')
    end
    def valid_file_reference(id, object, product_ref)
      Check.that(@paths.key?(id) && (object.keys - %w[isa lastKnownFileType explicitFileType includeInIndex name path sourceTree]).empty?, 'PBX file reference fields')
      Check.that(@referenced_refs[id] || id == product_ref, 'PBX unnecessary file reference')
      path = @paths.fetch(id)
      sources = (APP_SOURCES + TEST_SOURCES + CONTROLLER_SOURCES).uniq
      if sources.include?(path)
        Check.that(object['lastKnownFileType'] == 'sourcecode.swift' && object['sourceTree'] == '<group>' && !object.key?('explicitFileType') && !object.key?('includeInIndex'), 'PBX Swift source reference')
      elsif id == product_ref
        Check.that(object['explicitFileType'] == 'compiled.mach-o.executable' && object['includeInIndex'] == '0' && object['sourceTree'] == 'BUILT_PRODUCTS_DIR', 'PBX product reference shape')
      else
        Check.that(['SDKROOT:System/Library/Frameworks/Foundation.framework', 'SDKROOT:System/Library/Frameworks/Security.framework'].include?(path), 'PBX unapproved file reference')
        Check.that(object['lastKnownFileType'] == 'wrapper.framework', 'PBX framework type')
      end
      @consumed[id] = true
    end
  end

  # Native symbols are bound only when an explicitly admitted mode is entered.
  # Loading this source for a pure parser audit does not bind or invoke them.
  class Native
    O_RDONLY = 0
    O_WRONLY = 1
    O_NONBLOCK = 4
    O_NOFOLLOW = 256
    O_CREAT = 512
    O_EXCL = 2048
    O_EVTONLY = 32_768
    O_DIRECTORY = 1_048_576
    O_CLOEXEC = 16_777_216
    READ_FILE = O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC
    READ_DIR = O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
    attr_reader :api
    def initialize
      @api = Module.new do
        extend Fiddle::Importer
        dlload '/usr/lib/libSystem.B.dylib', '/usr/lib/libproc.dylib'
        extern 'int open(const char *, int, int)'
        extern 'int openat(int, const char *, int, int)'
        extern 'int mkdirat(int, const char *, unsigned short)'
        extern 'int fchdir(int)'
        extern 'int fsync(int)'
        extern 'int fcntl(int, int, long)'
        extern 'unsigned int alarm(unsigned int)'
        extern 'int waitid(int, unsigned int, void *, int)'
        extern 'int proc_listpids(unsigned int, unsigned int, void *, int)'
      end
    end
    def call(name, *arguments)
      result = @api.public_send(name, *arguments)
      error = Fiddle.last_error
      [result, error]
    end
  end

  # Cleanup consumes existing ownership only: no reopen, retry, clock, process,
  # or signal operation is introduced. A pending failure retains its identity
  # even when one cleanup action fails, and remaining owned closes are attempted.
  module Cleanup
    module_function
    def attempts(original_error: nil)
      cleanup_error = nil
      attempt = lambda do |&action|
        begin
          action.call
        rescue Exception => error
          cleanup_error ||= error
          nil
        end
      end
      yield attempt
      raise cleanup_error if cleanup_error && original_error.nil?
      nil
    end
    def close_all(owners, original_error: nil)
      attempts(original_error: original_error) do |attempt|
        until owners.empty?
          owned = owners.pop # Disown before the one close attempt.
          next unless owned
          attempt.call { owned.close unless owned.respond_to?(:closed?) && owned.closed? }
        end
      end
    end
    def transfer(owners)
      Check.that(owners.instance_of?(Array) && !owners.empty?, 'descriptor transfer owner list')
      endpoint = owners.pop
      begin
        close_all(owners)
      rescue Exception => error
        # The caller has not received the endpoint yet. A failed intermediate
        # close must consume its local ownership, without hiding that failure.
        close_all([endpoint], original_error: error)
        raise
      end
      endpoint
    end
  end

  class Files
    attr_reader :native, :budget
    def initialize(native, budget)
      @native, @budget = native, budget
    end
    def identity(io, directory: false)
      @budget.check
      stat = io.stat
      value = { 'device' => stat.dev.to_s, 'inode' => stat.ino.to_s, 'type' => stat.ftype,
                'uid' => stat.uid, 'mode' => stat.mode & 0o7777, 'nlink' => stat.nlink }
      unless directory
        value['size'] = stat.size
        value['mtime_nsec'] = stat.mtime.to_i * 1_000_000_000 + stat.mtime.nsec
        value['ctime_nsec'] = stat.ctime.to_i * 1_000_000_000 + stat.ctime.nsec
      end
      value
    end
    def admit(io, directory: false, owner: Process.euid)
      value = identity(io, directory: directory)
      Check.that(value['type'] == (directory ? 'directory' : 'file'), 'descriptor type')
      Check.that(owner.nil? || value['uid'] == owner, 'descriptor owner')
      Check.that(directory || value['nlink'] == 1, 'regular link count')
      value
    end
    def wrap(fd, error)
      Check.that(fd >= 0, 'descriptor open errno ' + error.to_s)
      IO.for_fd(fd, autoclose: true)
    end
    def absolute(path, directory: false, owner: Process.euid)
      Check.that(path.start_with?('/') && path != '/', 'absolute path')
      # The separately frozen platform runtime pins name regular files below
      # an OS-supplied ancestor closure. Their final vnode still receives the
      # nonblocking no-follow regular-file admission before any data read.
      if !directory && owner == 0 && (path.start_with?('/usr/bin/') || path.start_with?('/System/Library/Frameworks/Ruby.framework/'))
        @budget.check
        fd, error = @native.call(:open, path, Native::READ_FILE, 0)
        io = wrap(fd, error)
        owned = [io]
        begin
          admit(io, owner: 0)
          return Cleanup.transfer(owned)
        ensure
          Cleanup.close_all(owned, original_error: $!)
        end
      end
      relative = Check.path(path.byteslice(1, path.bytesize - 1))
      @budget.check
      fd, error = @native.call(:open, '/', Native::READ_DIR, 0)
      root = wrap(fd, error)
      owned = [root]
      begin
        admit(root, directory: true, owner: 0)
        owned << relative(root, relative, directory: directory, owner: owner)
        Cleanup.transfer(owned)
      ensure
        Cleanup.close_all(owned, original_error: $!)
      end
    end
    def relative(parent, path, directory: false, owner: Process.euid)
      parts = Check.path(path).split('/')
      owned = []
      current = parent
      begin
        parts.each_with_index do |part, index|
          @budget.check
          is_directory = index < parts.length - 1 || directory
          flags = is_directory ? Native::READ_DIR : Native::READ_FILE
          fd, error = @native.call(:openat, current.fileno, part, flags, 0)
          io = wrap(fd, error)
          owned << io
          # Ancestors may be platform-owned; the requested endpoint has the
          # caller's exact frozen owner requirement.
          admit(io, directory: is_directory, owner: index == parts.length - 1 ? owner : nil)
          current = io
        end
        Cleanup.transfer(owned)
      ensure
        Cleanup.close_all(owned, original_error: $!)
      end
    end
    def absent(parent, name)
      Check.that(Check.path(name).split('/').length == 1, 'absence basename')
      @budget.check
      fd, error = @native.call(:openat, parent.fileno, name, Native::READ_DIR, 0)
      if fd >= 0
        IO.for_fd(fd, autoclose: true).close
        raise Rejected, 'required fresh directory already exists'
      end
      Check.that(error == 2, 'directory absence not ENOENT')
      true
    end
    def hash(io, minimum: 0, maximum: 1_048_576, rewind: false, retain: false)
      before = admit(io, owner: nil)
      size = before.fetch('size')
      Check.that(size.between?(minimum, maximum), 'regular byte bound')
      @budget.check
      Check.that(io.seek(0, IO::SEEK_SET) == 0, 'hash rewind') if rewind
      digest, total, attempts, interrupts = Digest::SHA256.new, 0, 0, 0
      buffer = String.new(encoding: Encoding::BINARY)
      retained = retain ? String.new(encoding: Encoding::BINARY) : nil
      loop do
        @budget.check
        attempts += 1
        Check.that(attempts <= size + 65, 'hash attempt bound')
        request = total < size ? [65_536, size - total].min : 1
        begin
          chunk = io.read(request, buffer)
        rescue Errno::EINTR
          interrupts += 1
          Check.that(interrupts <= 64, 'hash EINTR bound')
          next
        end
        if total == size
          Check.that(chunk.nil?, 'regular EOF probe must return nil')
          break
        end
        Check.that(chunk && chunk.bytesize.between?(1, request), 'short or invalid regular read')
        total += chunk.bytesize
        digest.update(chunk)
        retained << chunk if retained
      end
      Check.that(identity(io) == before, 'held identity changed during hash')
      { 'byte_count' => total, 'sha256' => digest.hexdigest, 'identity' => before, 'bytes' => retained }
    end
    def observe(parent, path, minimum: 0, maximum: 1_048_576, retain: false, owner: Process.euid)
      io = relative(parent, path, owner: owner)
      begin
        hash(io, minimum: minimum, maximum: maximum, retain: retain)
      ensure
        Cleanup.close_all([io], original_error: $!)
      end
    end
    def pair(parent, path, minimum: 0, maximum: 1_048_576, retain: false, owner: Process.euid)
      held = relative(parent, path, owner: owner)
      begin
        first = hash(held, minimum: minimum, maximum: maximum, retain: retain)
        named = observe(parent, path, minimum: minimum, maximum: maximum, retain: retain, owner: owner)
        Check.that(first == named, 'held/named byte or identity mismatch')
        [held, first]
      rescue Exception
        Cleanup.close_all([held], original_error: $!)
        raise
      end
    end
    def inventory(held, absolute_path, expected, maximum: 314)
      Check.that(expected.length <= maximum && expected.uniq == expected, 'inventory expected count')
      before = admit(held, directory: true)
      @budget.check
      directory = Dir.open(absolute_path, encoding: Encoding::BINARY)
      observed, seen, dots, calls = [], {}, [], 0
      begin
        temporary = IO.for_fd(directory.fileno, autoclose: false)
        Check.that(identity(temporary, directory: true) == before, 'directory handle mismatch')
        loop do
          @budget.check
          calls += 1
          Check.that(calls <= maximum + 3, 'directory return bound')
          name = directory.read
          break if name.nil?
          Check.that(!seen.key?(name), 'duplicate directory entry')
          seen[name] = true
          if name == '.' || name == '..'
            dots << name
            next
          end
          Check.that(name.bytesize > 0 && !name.include?("\0") && !name.include?('/'), 'directory name grammar')
          observed << name
          Check.that(observed.length <= maximum && expected.include?(name), 'unexpected directory entry')
        end
        Check.that(dots.sort == ['.', '..'] && observed.sort == expected.map(&:b).sort, 'directory inventory mismatch')
        Check.that(identity(temporary, directory: true) == before, 'directory changed during enumeration')
      ensure
        Cleanup.close_all([directory], original_error: $!)
      end
      named = absolute(absolute_path, directory: true)
      begin
        Check.that(identity(named, directory: true) == before && identity(held, directory: true) == before, 'directory named rejoin')
      ensure
        Cleanup.close_all([named], original_error: $!)
      end
      observed
    end
  end

  # Pure copied-value admission only. Actual environment/constants/loaded-feature
  # observations and all support-file opens remain owned by RuntimeAdmission.
  module RuntimePolicy
    module_function
    def environment(uid, entries)
      Check.that(uid.instance_of?(Integer) && uid == 501 && entries == ENVIRONMENT, 'runtime uid/environment')
      true
    end
    def constants(version, patchlevel, revision, platform)
      Check.that(version == '2.6.10' && patchlevel.instance_of?(Integer) && patchlevel == 210 &&
        revision == '67958' && platform == 'universal.arm64e-darwin25', 'Ruby runtime constants')
      true
    end
    def support(features)
      pins = PIN_DATA.fetch('seal_runtime_support_pins').fetch('pins')
      Check.that(features == pins.map { |pin| pin.fetch('path') }, 'runtime loaded support closure')
      serialized = pins.map { |pin| { 'path' => pin.fetch('path'), 'sha256' => pin.fetch('sha256') } }
      Check.that(Digest::SHA256.hexdigest(JSON.generate(serialized)) == '0273e30aa84370d5aa2440e1e870b3319f6a6a6fed81f9143f208da8f0833f2b', 'runtime support aggregate')
      toolchain = PIN_DATA.fetch('toolchain_pin')
      [
        { 'path' => '/usr/bin/env', 'sha256' => toolchain.fetch('seal_launcher_sha256') },
        { 'path' => '/usr/bin/ruby', 'sha256' => toolchain.fetch('seal_runtime_sha256') }
      ] + pins
    end
    def content(actual, expected)
      Check.that(actual == expected, 'runtime content pin')
      true
    end
    def invocation(program:, arguments:, environment:, cwd:, uid:, budget:)
      budget.check
      Check.that(program == ROOT + '/' + SOURCE && arguments.instance_of?(Array) && arguments.length == 1,
                 'driver fixed program/argument count')
      Check.that(environment == ENVIRONMENT && cwd == ROOT && uid.instance_of?(Integer) && uid == 501,
                 'driver exact environment/cwd/uid')
      ModePlan.resolve(arguments[0], budget)
    end
  end

  class RuntimeAdmission
    attr_reader :self_sha256
    def initialize(files)
      @files = files
    end
    def validate
      RuntimePolicy.environment(Process.euid, ENV.map { |key, value| key + '=' + value }.sort)
      RuntimePolicy.constants(RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_REVISION.to_s, RUBY_PLATFORM)
      features = $LOADED_FEATURES.select { |path| path.start_with?('/') }.sort_by(&:b)
      runtime_pins = RuntimePolicy.support(features)
      runtime_pins.each do |pin|
        @files.budget.check
        io = @files.absolute(pin.fetch('path'), owner: 0)
        begin
          observation = @files.hash(io)
          RuntimePolicy.content(observation['sha256'], pin['sha256'])
        ensure
          Cleanup.close_all([io], original_error: $!)
        end
      end
      repository = @files.absolute(ROOT, directory: true)
      begin
        held, observation = @files.pair(repository, SOURCE)
        held.close
        @self_sha256 = observation.fetch('sha256')
      ensure
        Cleanup.close_all([repository], original_error: $!)
      end
      true
    end
  end

  # No timer, signal disposition, filesystem object, or child is touched by
  # construction. The driver may enter this gate only after runtime admission.
  class ModeClock
    DEADLINES = {
      '--check-ordinary-compatibility' => 3600, '--seal-admission' => 21_600,
      '--run-admission-debug' => 420, '--run-admission-release' => 420,
      '--verify-admission' => 480, '--stage-guest' => 7200,
      '--run-guest-debug' => 420, '--run-guest-release' => 420,
      '--verify-guest' => 480
    }.freeze
    def initialize(native, budget)
      @native, @budget = native, budget
      @entered = false
    end
    def around(mode)
      Check.that(!@entered && DEADLINES.key?(mode), 'mode clock single exact admission')
      @entered = true
      @budget.check
      start = Check.u64(Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond))
      deadline = Check.u64(start + DEADLINES.fetch(mode) * 1_000_000_000)
      Signal.trap('ALRM') { @budget.cancel }
      alarm_attempted = true
      remaining, = @native.call(:alarm, DEADLINES.fetch(mode))
      Check.that(remaining == 0, 'mode alarm prior timer')
      @budget.check
      value = yield
      @budget.check
      Check.that(Check.u64(Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)) < deadline, 'mode wall deadline')
      value
    ensure
      if alarm_attempted
        original_error = $!
        Cleanup.attempts(original_error: original_error) do |attempt|
          attempt.call do
            remaining, = @native.call(:alarm, 0)
            Check.that(remaining.instance_of?(Integer) && remaining.between?(0, DEADLINES.fetch(mode)), 'mode alarm cancellation result')
          end
        end
        @budget.check if original_error.nil?
      end
    end
  end

  # Production-used bounded request progression. The callback receives only the
  # immutable not-yet-written suffix and represents the existing one write site.
  # It owns no descriptor, clock, process or close; the supervisor retains those.
  class BatchInputState
    attr_reader :request, :written, :attempts, :waits, :interruptions, :error
    def initialize(request)
      Check.that(request.instance_of?(String) && request.bytesize.between?(205, 10_537) && request.bytesize % 41 == 0, 'batch request size')
      @request = request.dup.freeze
      @written = @attempts = @waits = @interruptions = 0
      @stopped = @entered = false
      @error = nil
    end
    def step
      Check.that(!@stopped && !@entered && @error.nil? && !complete?, 'batch input already terminal or entered')
      @entered = true
      @attempts += 1
      Check.that(@attempts <= @request.bytesize + 3064, 'batch write attempts')
      suffix = @request.byteslice(@written, [10_537, @request.bytesize - @written].min).freeze
      begin
        count = yield suffix
      rescue Errno::EINTR
        return_admitted!
        @interruptions += 1
        Check.that(@interruptions <= 64, 'batch EINTR bound')
        return false
      end
      return_admitted!
      if count == :wait_writable
        @waits += 1
        Check.that(@waits <= 3000, 'batch not-writable bound')
      else
        Check.that(count.instance_of?(Integer) && count.between?(1, suffix.bytesize), 'batch positive write')
        @written += count
      end
      complete?
    rescue StandardError => error
      @error ||= error
      @stopped = true
      raise @error
    ensure
      @entered = false
    end
    def stop!
      @stopped = true
    end
    def complete?
      @written == @request.bytesize
    end
    private
    def return_admitted!
      raise @error if @error
      Check.that(@entered && !@stopped, 'batch input changed during write')
    end
  end

  # Pure failure/progress state. It cannot observe a child, advance a deadline,
  # cancel a mode, or grant signal/reap authority. A failed read is never EOF;
  # an attempted close is never evidence that the input actually closed.
  class SupervisorIOState
    attr_reader :error
    def initialize(input_required:, output_count:)
      Check.that([true, false].include?(input_required) && output_count.instance_of?(Integer) && [1, 2].include?(output_count), 'supervisor IO shape')
      @input_required, @input_close_attempted = input_required, false
      @input_closed = !input_required
      @read_failed, @eofs = Array.new(output_count, false), Array.new(output_count, false)
      @error = nil
    end
    def record(error)
      raise error if error.is_a?(ContainmentUnproven)
      Check.that(error.is_a?(Exception), 'supervisor failure object')
      @error ||= error
    end
    def readable?(index)
      Check.that(index.instance_of?(Integer) && index.between?(0, @eofs.length - 1), 'supervisor pipe index')
      !@read_failed[index] && !@eofs[index]
    end
    def read_failed(index, error)
      Check.that(readable?(index), 'supervisor failed-read transition')
      record(error)
      @read_failed[index] = true
    end
    def eof!(index)
      Check.that(readable?(index), 'supervisor EOF transition')
      @eofs[index] = true
    end
    def observed_read(index, observe:)
      read_observation(observe)
      return :disabled unless readable?(index)
      begin
        chunk = yield
      rescue Errno::EINTR
        read_observation(observe)
        raise
      end
      # The entered read may deliver cancellation. This same ordering is used
      # by the real loop and by inert fake-read tests, before normal capture.
      read_observation(observe)
      chunk
    end
    def read_observation(observe)
      observe.call
    rescue IOError, SystemCallError
      # An observation/clock error is not a failed pipe read or a read EINTR.
      # Raising here retains that original error as the Ruby exception cause;
      # an existing ContainmentUnproven bypasses this rescue unchanged.
      raise ContainmentUnproven, 'pipe observation unavailable'
    end
    private :read_observation
    def capture(index, chunk)
      Check.that(readable?(index) && chunk.instance_of?(String) && chunk.bytesize.between?(1, 65_536), 'supervisor positive capture input')
      return false if @error
      yield chunk
      true
    rescue StandardError => error
      record(error)
      false
    end
    def outputs_complete?; @eofs.all?; end
    def writable?; @input_required && !@input_close_attempted && @error.nil?; end
    def begin_input_close
      return false unless @input_required && !@input_close_attempted
      @input_close_attempted = true
      true
    end
    def input_closed!
      Check.that(@input_required && @input_close_attempted && !@input_closed, 'supervisor input close transition')
      @input_closed = true
    end
    def inputs_closed?; @input_closed; end
  end

  # Pure bounded decoding of the one native group-result prefix. The supplied
  # reader is called only after the byte count is admitted; no pointer/native
  # owner is present here. Successful calls may leave an unrelated errno value.
  module GroupInventory
    module_function
    def observe(result:, error:, child_pid:, terminal:, check:)
      check.call
      unless result.instance_of?(Integer) && error.instance_of?(Integer) && result >= 0 && result < 1_048_576 && result % 4 == 0 &&
             child_pid.instance_of?(Integer) && child_pid.between?(1, 2_147_483_647) &&
             (terminal.nil? || WaitTuple.terminal?(terminal))
        raise ContainmentUnproven, 'group inventory errno or count ' + error.to_s
      end
      check.call
      prefix = yield result
      unless prefix.instance_of?(String) && prefix.bytesize == result
        raise ContainmentUnproven, 'group fixed-buffer prefix mismatch'
      end
      check.call
      members, seen = [], {}
      offset = 0
      while offset < result
        check.call
        member = prefix.byteslice(offset, 4).unpack1('l<')
        unless member.between?(1, 2_147_483_647) && !seen.key?(member)
          raise ContainmentUnproven, 'invalid group member'
        end
        seen[member] = true
        members << member
        offset += 4
      end
      check.call
      if terminal
        members << child_pid unless seen.key?(child_pid)
      elsif !seen.key?(child_pid)
        raise ContainmentUnproven, 'live child missing from group inventory'
      end
      check.call
      sorted = members.sort
      check.call
      sorted.freeze
    end
  end

  # Scalar-only ownership decisions shared by the actual supervisor and inert
  # event traces. It never performs or supplies a process, signal, wait, clock,
  # descriptor or native operation. The effect owner supplies observations and
  # reserves each already-frozen call before executing it at its existing site.
  class SupervisorPolicy
    attr_reader :pid, :spawn_tick, :deadline, :terminal, :cleanup_deadline,
                :trigger_failure, :reap_tick, :terminal_tick
    def self.default_chld!(value)
      Check.that(value == 'DEFAULT', 'SIGCHLD disposition')
    end
    def initialize(seconds:)
      Check.that([30, 60, 120, 900].include?(seconds), 'policy fixed child deadline')
      @seconds, @pid, @spawn_tick, @terminal = seconds, nil, nil, nil
      @kill = @reap_attempted = @reaped = @probe_attempted = @probe_gone = @complete = @unproven = false
      @pgid_admitted = false
      @cycles = @cleanup_cycles = @interval = @stable = @waitid_eintr = 0
      @cycle_finished = true
      @group = @last_anchor_interval = @wait_cycle = nil
    end
    def spawn_started!(tick)
      require_state(@spawn_tick.nil? && @pid.nil?, 'duplicate spawn start')
      @spawn_tick = scalar_tick(tick)
      @deadline = scalar_tick(tick + @seconds * 1_000_000_000)
      @last_tick = tick
    end
    def admit_child!(pid)
      require_state(@spawn_tick && @pid.nil? && pid.instance_of?(Integer) && pid.between?(1, 2_147_483_647), 'spawn positive child')
      @pid = pid
    end
    def admit_pgid!(pgid)
      observable!
      require_state(!@pgid_admitted && pgid.instance_of?(Integer) && pgid == @pid, 'fresh process group ownership')
      @pgid_admitted = true
    end
    def exited_before_pgid!
      observable!
      require_state(!@pgid_admitted && !@terminal.nil?, 'getpgid absent without terminal anchor')
      @pgid_admitted = true
    end
    def observe_time!(now, cancelled:)
      observable!
      sample_time(now)
      require_state(cancelled == true || cancelled == false, 'cancellation scalar')
      if cancelled || now >= @deadline
        unless @cleanup_deadline
          @cleanup_deadline = scalar_tick(now + 5_000_000_000)
          @trigger_failure = Rejected.new(cancelled ? 'mode alarm' : 'child deadline')
          # A trigger first seen during an active cycle consumes the first
          # cleanup cycle too; its remaining pipe/interval work is not free.
          @cleanup_cycles = @cycle_finished ? 0 : 1
        end
      end
      require_state(!@cleanup_deadline || now <= @cleanup_deadline, 'cleanup horizon exhausted')
      now
    end
    def begin_cycle!
      observable!
      require_state(@cycle_finished, 'unfinished observation cycle')
      @cycles += 1
      limit = @cleanup_deadline ? @seconds * 100 + 564 : @seconds * 100 + 64
      require_state(@cycles <= limit, 'observation count exhausted')
      if @cleanup_deadline
        @cleanup_cycles += 1
        require_state(@cleanup_cycles <= 564, 'cleanup observation count exhausted')
      end
      @cycle_finished, @group = false, nil
    end
    def waitid_result(result:, error:)
      observable!
      require_state(result.instance_of?(Integer) && error.instance_of?(Integer), 'waitid result/errno scalars')
      if result == -1 && error == 4
        @waitid_eintr += 1
        require_state(@waitid_eintr <= 64, 'waitid EINTR bound')
        return :retry
      end
      require_state(result == 0, 'waitid errno ' + error.to_s)
      event = WaitTuple.decode(yield, @pid)
      require_state(@terminal.nil? || @terminal == event, 'contradictory terminal waitid')
      @terminal ||= event && event.freeze
      @wait_cycle = @cycles
      event
    rescue ContainmentUnproven
      @unproven = true
      raise
    end
    def inventory_result!(result:, error:, inputs_closed:, outputs_complete:, check:, &read_prefix)
      observable!
      require_state(@pgid_admitted && !@cycle_finished && @group.nil? && @wait_cycle == @cycles, 'inventory needs fresh wait observation')
      booleans!(inputs_closed, outputs_complete)
      members = GroupInventory.observe(result: result, error: error, child_pid: @pid,
        terminal: @terminal, check: check, &read_prefix)
      inventory!(members, inputs_closed: inputs_closed, outputs_complete: outputs_complete)
      members
    rescue ContainmentUnproven
      @unproven = true
      raise
    end
    def kill_due?
      observable!
      require_state(!@group.nil? && @wait_cycle == @cycles, 'kill needs current anchored inventory')
      !@cleanup_deadline.nil? && !@kill && (@terminal.nil? || !@outputs_complete_for_kill || @group != [@pid])
    end
    def reserve_kill!(outputs_complete:)
      observable!
      booleans!(outputs_complete)
      @outputs_complete_for_kill = outputs_complete
      require_state(kill_due?, 'ineligible or repeated group SIGKILL')
      @kill = true
    end
    def should_kill?(outputs_complete:)
      observable!
      booleans!(outputs_complete)
      @outputs_complete_for_kill = outputs_complete
      kill_due?
    end
    def finish_cycle!(inputs_closed:, outputs_complete:)
      observable!
      booleans!(inputs_closed, outputs_complete)
      require_state(!@cycle_finished && !@group.nil?, 'missing or duplicate inventory cycle')
      if @eligible_at_inventory && inputs_closed && outputs_complete && @group == [@pid]
        if @stable == 0
          @stable, @last_anchor_interval = 1, @interval
        elsif @interval > @last_anchor_interval
          @stable, @last_anchor_interval = 2, @interval
        end
      else
        @stable, @last_anchor_interval = 0, nil
      end
      @cycle_finished = true
      @stable >= 2
    end
    def interval_completed!
      observable!
      require_state(@cycle_finished && @cycles > 0 && @interval_cycle != @cycles, 'interval outside finished cycle')
      @interval += 1
      @interval_cycle = @cycles
    end
    def reserve_reap!
      observable!
      require_state(@cycle_finished && @stable >= 2 && @group == [@pid] && @terminal, 'reap without two later anchor-only observations')
      @reap_attempted = true
    end
    def reap_result!(pid:, raw_status:, now:)
      require_state(@reap_attempted && !@reaped, 'unexpected or repeated exact reap')
      require_state(pid.instance_of?(Integer) && pid == @pid && WaitTuple.matches_raw?(@terminal, raw_status), 'exact reap/status contradiction')
      sample_time(now)
      @reaped, @reap_tick = true, now
    end
    def reserve_post_reap_probe!
      require_state(@reaped && !@probe_attempted, 'post-reap probe ownership')
      @probe_attempted = true
    end
    def post_reap_result!(result:, error:)
      require_state(@probe_attempted && !@probe_gone, 'post-reap result ownership')
      require_state(result.nil? && error.instance_of?(Integer) && error == 3, 'owned PGID remains or is uncertain after reap')
      @probe_gone = true
    end
    def complete!(now)
      require_state(@reaped && @probe_gone && !@complete, 'containment completion order')
      sample_time(now)
      require_state(!@cleanup_deadline || now <= @cleanup_deadline, 'cleanup horizon exhausted')
      @complete, @terminal_tick = true, now
    end
    def kill_attempted?; @kill; end
    def reap_attempted?; @reap_attempted; end
    def reaped?; @reaped; end
    def containment_complete?; @complete && !@unproven; end
    private
    def inventory!(members, inputs_closed:, outputs_complete:)
      # Only inventory_result! can publish this already validated, sorted and
      # frozen decoder result. No second unchecked member traversal or copy.
      @group = members
      @eligible_at_inventory = !@terminal.nil? && inputs_closed && outputs_complete
    end
    def require_state(value, message)
      return if value && !@unproven
      @unproven = true
      raise ContainmentUnproven, message
    end
    def observable!
      require_state(@pid && !@reap_attempted, 'observation or signal after reap attempt')
    end
    def scalar_tick(value)
      require_state(value.instance_of?(Integer) && value.between?(0, 18_446_744_073_709_551_615), 'policy tick scalar')
      value
    end
    def sample_time(now)
      scalar_tick(now)
      require_state(@last_tick.nil? || now >= @last_tick, 'monotonic clock regression')
      @last_tick = now
    end
    def booleans!(*values)
      require_state(values.all? { |value| value == true || value == false }, 'policy Boolean scalar')
    end
  end

  # One direct child, one fresh PGID, one retained waitable anchor. Successful
  # results require both independent inventories, exact reap, and ESRCH after
  # reap. No PID is re-used as signal authority after this transition.
  class Supervisor
    INTERVAL = 0.010
    MAX_PID = 2_147_483_647
    attr_reader :children
    def initialize(files)
      @files, @native, @budget = files, files.native, files.budget
      @children = 0
      @siginfo = Fiddle::Pointer.malloc(104)
      Check.that(@siginfo.to_i % 8 == 0, 'siginfo alignment')
      @pid_buffer = Fiddle::Pointer.malloc(1_048_576)
      @active = nil
      @chld_admitted = false
    end
    def clock
      value = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
      Check.u64(value)
      Check.that(@last_clock.nil? || value >= @last_clock, 'monotonic clock regression')
      @last_clock = value
    end
    def run(argv, **options)
      Check.that(@active.nil?, 'prior child containment unresolved')
      @owned_descriptors = []
      run_owned(argv, **options)
    ensure
      original_error = $!
      cleanup_error = nil
      (@owned_descriptors || []).reverse_each do |io|
        begin
          release(io)
        rescue Exception => error
          cleanup_error ||= error
        end
      end
      if @active && !@active[:policy].containment_complete?
        # One bounded best-effort diagnostic, never a blocking write or evidence.
        begin
          STDERR.write_nonblock("CONTAINMENT_UNPROVEN exact child #{@active[:pid]}\n", exception: false)
        rescue IOError, SystemCallError
        end
        raise ContainmentUnproven, 'exact child containment unresolved' unless original_error.is_a?(ContainmentUnproven)
      end
      @active = nil if @active && @active[:policy].containment_complete?
      raise cleanup_error if cleanup_error && original_error.nil?
    end
    def run_owned(argv, cwd:, seconds:, maximum: 65_536, merged: false, input: nil, consumer: nil, accepted_statuses: [0], controller: false)
      @budget.check
      @setup_failure = nil
      Check.that(@active.nil? && argv.instance_of?(Array) && argv.length > 1 && argv.all? { |v| v.instance_of?(String) && !v.include?("\0") }, 'supervisor fixed argv')
      Check.that([ROOT, '/private/var/empty'].include?(cwd) && [30, 60, 120, 900].include?(seconds), 'supervisor context/deadline')
      if controller
        Check.that(ControllerInvocation.valid?(argv, seconds) && cwd == '/private/var/empty' && maximum == 65_536 &&
                   !merged && input.nil? && consumer.nil? && accepted_statuses == [0, 65], 'exact controller spawn capability')
      else
        Check.that(accepted_statuses == [0], 'external probe exit policy')
      end
      policy = SupervisorPolicy.new(seconds: seconds)
      unless @chld_admitted
        @budget.check
        SupervisorPolicy.default_chld!(Signal.trap('CHLD', 'DEFAULT'))
        @chld_admitted = true
      end
      pipes = [IO.pipe.map { |io| own(io) }]
      pipes << IO.pipe.map { |io| own(io) } unless merged
      pipes.flatten.each { |io| @budget.check; io.close_on_exec = true }
      pipes.each { |read, _| read.fcntl(Fcntl::F_SETFL, read.fcntl(Fcntl::F_GETFL) | Native::O_NONBLOCK) }
      input_pipe = input ? IO.pipe.map { |io| own(io) } : nil
      flow = SupervisorIOState.new(input_required: !input.nil?, output_count: pipes.length)
      batch_input = input && BatchInputState.new(input)
      if input_pipe
        input_pipe.each { |io| io.close_on_exec = true }
        input_pipe[1].fcntl(Fcntl::F_SETFL, input_pipe[1].fcntl(Fcntl::F_GETFL) | Native::O_NONBLOCK)
      end
      admitted_cwd = own(@files.absolute(cwd, directory: true, owner: cwd == ROOT ? 501 : 0))
      original = own(@files.absolute(Dir.pwd, directory: true, owner: nil))
      stdin = input_pipe ? input_pipe[0] : own(File.open('/dev/null', File::RDONLY))
      setup_error = nil
      begin
        @budget.check
        rc, error = @native.call(:fchdir, admitted_cwd.fileno)
        Check.that(rc == 0, 'child cwd fchdir errno ' + error.to_s)
        spawn_tick = clock
        deadline = Check.u64(spawn_tick + seconds * 1_000_000_000)
        policy.spawn_started!(spawn_tick)
        child_environment = controller ? {} : ENVIRONMENT.each_with_object({}) { |entry, hash| key, value = entry.split('=', 2); hash[key] = value }
        pid = Process.spawn(child_environment,
                            [argv[0], argv[0]], *argv.drop(1), unsetenv_others: true, close_others: true,
                            pgroup: true, in: stdin, out: pipes[0][1], err: merged ? pipes[0][1] : pipes[1][1])
        Check.that(pid.instance_of?(Integer) && pid.between?(1, MAX_PID), 'spawn positive child')
        @active = { pid: pid, policy: policy, deadline: deadline, spawn_tick: spawn_tick, flow: flow, batch_input: batch_input }
        policy.admit_child!(pid)
        @children += 1
      rescue Exception => error
        setup_error ||= error
      ensure
        begin
          rc, error = @native.call(:fchdir, original.fileno)
          Check.that(rc == 0, 'restore cwd errno ' + error.to_s)
        rescue Exception => error
          setup_error ||= error
        end
        [original, admitted_cwd, stdin, *pipes.map(&:last)].each do |io|
          begin
            release(io)
          rescue Exception => error
            setup_error ||= error
          end
        end
      end
      raise setup_error if setup_error && !@active
      @setup_failure = setup_error
      reads = pipes.map(&:first)
      captures = reads.map { String.new(encoding: Encoding::BINARY) }
      caps = merged ? [maximum] : [maximum, 65_536]
      totals, buffer = reads.map { 0 }, String.new(encoding: Encoding::BINARY)
      terminal, cleanup_deadline = nil, nil
      flow.record(@setup_failure) if @setup_failure
      eintr = 0
      input_writer = input_pipe && input_pipe[1]
      @active[:input_writer] = input_writer
      close_input if flow.error
      observe_read = method(:observation_context)
      begin
        begin
          policy.admit_pgid!(Process.getpgid(pid))
        rescue Errno::ESRCH
          terminal = waitable(pid)
          policy.exited_before_pgid!
        end
        loop do
          now = observation_context
          cleanup_deadline = policy.cleanup_deadline
          policy.begin_cycle!
          terminal = waitable(pid)
          # The first of the two accepted inventories must itself occur after
          # every required EOF/input-close has already been observed; an EOF
          # discovered later in this iteration cannot backdate that inventory.
          inputs_before_inventory, outputs_before_inventory = flow.inputs_closed?, flow.outputs_complete?
          group(pid, inputs_closed: inputs_before_inventory, outputs_complete: outputs_before_inventory)
          # A flag/deadline may have become visible during an EINTR retry or
          # the inventory call. That same trigger closes stdin and switches
          # this iteration to cleanup before any ordinary consumer or write.
          observation_context
          cleanup_deadline = policy.cleanup_deadline
          if policy.should_kill?(outputs_complete: flow.outputs_complete?)
            # This inventory and live/terminal anchor are fresh, and no reap has
            # occurred. The one timeout-only signal can address this PGID only.
            policy.reserve_kill!(outputs_complete: flow.outputs_complete?)
            begin
              Process.kill('KILL', -pid)
            rescue Errno::ESRCH
              # The group can become empty after the anchored inventory. A
              # signal attempt still fails the mode and cannot be repeated.
            end
          end
          reads.each_with_index do |read, index|
            begin
              chunk = flow.observed_read(index, observe: observe_read) do
                read.read_nonblock(65_536, buffer, exception: false)
              end
            rescue Errno::EINTR
              eintr += 1
              raise ContainmentUnproven, 'pipe EINTR limit' if eintr > 64
              next
            rescue IOError, SystemCallError => error
              # No retry/reopen and no invented EOF. Other usable pipes still
              # drain; missing EOF can only end as CONTAINMENT_UNPROVEN.
              flow.read_failed(index, error)
              close_input
              close_output(read, flow)
              next
            end
            next if chunk == :disabled
            if chunk.nil?
              flow.eof!(index)
              close_output(read, flow)
            elsif chunk != :wait_readable
              begin
                Check.that(chunk.bytesize.between?(1, 65_536), 'pipe positive read')
                totals[index] += chunk.bytesize
                if totals[index] > caps[index]
                  flow.record(Rejected.new('pipe output overflow'))
                else
                  flow.capture(index, chunk) do |bytes|
                    if index == 0 && consumer
                      consumer.call(bytes)
                    else captures[index] << bytes
                    end
                  end
                end
              rescue StandardError => error
                # Only local framing/capture/consumer work is inside this
                # boundary. In particular, artifact ENOSPC/EIO consumes that
                # writer attempt, suppresses later work and preserves the first
                # failure until exact containment. ContainmentUnproven escapes.
                flow.record(error)
              end
            end
            close_input if flow.error
          end
          # Drain/consumer work can expose an alarm or cross the deadline.
          # Refresh the existing trigger before any next ordinary batch write.
          observation_context
          cleanup_deadline = policy.cleanup_deadline
          if flow.writable?
            begin
              completed_input = batch_input.step do |request|
                input_writer.write_nonblock(request, exception: false)
              end
              close_input if completed_input
            rescue StandardError => error
              flow.record(error)
            end
          end
          close_input if flow.error
          if policy.finish_cycle!(inputs_closed: flow.inputs_closed?, outputs_complete: flow.outputs_complete?)
            policy.reserve_reap!
            pair = Process.waitpid2(pid, Process::WNOHANG)
            reap_tick = clock
            status = pair && pair[1]
            policy.reap_result!(pid: pair && pair[0], raw_status: status && status.to_i, now: reap_tick)
            policy.reserve_post_reap_probe!
            begin
              result = Process.kill(0, -pid)
              policy.post_reap_result!(result: result, error: 0)
            rescue Errno::ESRCH
              policy.post_reap_result!(result: nil, error: 3)
              # This is the only accepted post-reap result. Signal authority is
              # permanently gone, including if any other result were returned.
            end
            terminal_tick = clock
            # Reaping removes signal authority; only these later observations
            # establish completed containment. An error between the two must
            # retain the unresolved owner and take CONTAINMENT_UNPROVEN priority.
            policy.complete!(terminal_tick)
            flow.record(Rejected.new('incomplete batch stdin')) if batch_input && !batch_input.complete?
            flow.record(Rejected.new('child abnormal or unexpected exit')) unless status.exited? && accepted_statuses.include?(status.exitstatus)
            flow.record(Rejected.new('timeout signal attempted')) if policy.kill_attempted?
            flow.record(Rejected.new('late terminal acceptance')) if terminal_tick > deadline || @budget.cancelled
            raise flow.error if flow.error
            result = {
              'child_pid' => pid, 'exit_status' => status.exitstatus, 'kill_attempted' => false,
              'kill_errno' => 0, 'kill_return' => -2_147_483_648, 'normal_exit' => true,
              'observed_pipe_eof_count' => reads.length, 'operation_deadline_tick' => deadline.to_s,
              'output_overflow' => false, 'process_group_gone' => true, 'reap_tick' => reap_tick.to_s,
              'reaped' => true, 'required_pipe_eof_count' => reads.length, 'signal' => nil,
              'spawn_tick' => spawn_tick.to_s, 'terminal_tick' => terminal_tick.to_s,
              'timebase_denominator' => 1, 'timebase_numerator' => 1, 'timed_out' => false,
              'wait_status' => status.to_i
            }
            return { 'process' => result, 'stdout' => captures[0], 'stderr' => merged ? ''.b : captures[1] }
          end
          # Readiness is sampled nonblocking above. Waiting on already-ready
          # pipes here would collapse the cadence and incorrectly count two
          # instantaneous group inventories as independently spaced samples.
          # Each ordinary tick therefore owns one monotonic ten-millisecond
          # interval; an interrupted interval is retried only within its same
          # endpoint and the shared 64-EINTR bound.
          interval_end = Check.u64(now + 10_000_000)
          interval_completed = false
          loop do
            remaining = interval_end - clock
            if remaining <= 0
              interval_completed = true
              break
            end
            break if @budget.cancelled && cleanup_deadline.nil?
            begin
              IO.select(nil, nil, nil, [remaining, 10_000_000].min / 1_000_000_000.0)
              interval_completed = true
              break
            rescue Errno::EINTR
              eintr += 1
              raise ContainmentUnproven, 'select EINTR limit' if eintr > 64
            rescue IOError, SystemCallError
              # A failed wait cannot establish the mandatory spacing between
              # terminal inventories. Do not retry it or busy-loop to fake it.
              raise ContainmentUnproven, 'observation interval unavailable'
            end
          end
          policy.interval_completed! if interval_completed
        end
      end
    end
    private :run_owned
    private
    def own(io)
      @owned_descriptors << io
      io
    end
    def release(io)
      # Disown before the one close attempt. An error consumes that attempt;
      # terminal cleanup must not retry it or reuse its descriptor number.
      return unless io && @owned_descriptors.delete(io)
      io.close unless io.closed?
    end
    def close_output(io, flow)
      release(io)
    rescue StandardError => error
      flow.record(error)
    end
    def close_input
      flow = @active.fetch(:flow)
      return unless flow.begin_input_close
      @active.fetch(:batch_input).stop!
      begin
        writer = @active.fetch(:input_writer)
        release(writer)
        Check.that(writer.closed?, 'batch input close incomplete')
        flow.input_closed!
      rescue StandardError => error
        flow.record(error)
      end
    end
    def observation_context
      now = clock
      policy = @active.fetch(:policy)
      previous_trigger = policy.cleanup_deadline
      policy.observe_time!(now, cancelled: @budget.cancelled)
      if policy.cleanup_deadline && !previous_trigger
        @active.fetch(:flow).record(policy.trigger_failure)
        close_input
      end
      now
    end
    def waitable(pid)
      loop do
        observation_context
        @siginfo[0, 104] = "\0" * 104
        result, error = @native.call(:waitid, 1, pid, @siginfo, 4 | 1 | 32)
        event = @active.fetch(:policy).waitid_result(result: result, error: error) { @siginfo[0, 24] }
        next if event == :retry
        return event
      end
    end
    def group(pid, inputs_closed:, outputs_complete:)
      observation_context
      result, error = @native.call(:proc_listpids, 2, pid, @pid_buffer, 1_048_576)
      @active.fetch(:policy).inventory_result!(result: result, error: error,
        inputs_closed: inputs_closed, outputs_complete: outputs_complete,
        check: method(:observation_context)) { |length| length == 0 ? ''.b : @pid_buffer[0, length] }
    end
    def status_matches?(status, terminal)
      WaitTuple.matches_raw?(terminal, status.to_i)
    end
  end

  # The ABI permits decoding exactly these six scalars and no pad/union bytes.
  # This pure decoder is also exercised without constructing a native owner.
  module WaitTuple
    module_function
    def terminal?(value)
      value.instance_of?(Array) && value.length == 2 && value.all? { |item| item.instance_of?(Integer) } &&
        ((value[0] == 1 && value[1].between?(0, 255)) || ([2, 3].include?(value[0]) && value[1].between?(1, 31)))
    end
    def matches_raw?(terminal, raw_status)
      return false unless terminal?(terminal) && raw_status.instance_of?(Integer)
      expected = terminal[0] == 1 ? terminal[1] << 8 : terminal[1] | (terminal[0] == 3 ? 0x80 : 0)
      raw_status == expected
    end
    def decode(prefix, pid)
      raise ContainmentUnproven, 'waitid scalar prefix size' unless prefix.instance_of?(String) && prefix.bytesize == 24
      signo, native_errno, code, child, uid, status = prefix.unpack('l<l<l<l<L<l<')
      if child == 0
        raise ContainmentUnproven, 'nonzero waitid no-event scalar' unless [signo, native_errno, code, uid, status].all? { |value| value == 0 }
        return nil
      end
      unless pid.instance_of?(Integer) && pid.between?(1, 2_147_483_647) && signo == 20 && native_errno == 0 && child == pid && uid == 501 &&
             ((code == 1 && status.between?(0, 255)) || ([2, 3].include?(code) && status.between?(1, 31)))
        raise ContainmentUnproven, 'invalid waitid terminal tuple'
      end
      [code, status]
    end
  end

  module ControllerInvocation
    module_function
    def argv(mode)
      Check.that(%w[run_admission_debug run_admission_release verify_admission run_guest_debug run_guest_release verify_guest].include?(mode), 'fixed controller mode')
      guest = mode.include?('guest')
      verify = mode.start_with?('verify_')
      configuration = mode.end_with?('_debug') ? 'Debug' : 'Release'
      executable = '/private/tmp/ergentics-h3q-' + configuration.downcase + '-v1/Build/Products/' + configuration + '/ErgenticsProvenanceH3QualificationController'
      root = '/private/tmp/ergentics-h3q-' + (guest ? 'guest' : 'admission') + '-campaign-v1'
      argument = verify ? '--verify-' + (guest ? 'guest' : 'admission') + '-campaign' : (guest ? '--guest' : '--admission-only')
      [executable, argument, verify ? root : root + '/' + configuration.downcase]
    end
    def valid?(candidate, seconds)
      %w[run_admission_debug run_admission_release verify_admission run_guest_debug run_guest_release verify_guest].any? do |mode|
        candidate == argv(mode) && seconds == (mode.start_with?('verify_') ? 120 : 60)
      end
    end
  end

  # Streaming git cat-file --batch framing. The caller feeds each pipe chunk as
  # it arrives while request writes continue in the same supervisor loop. Only
  # commit and PBX payloads have a bounded retained buffer.
  class TrackedBatch
    attr_reader :request, :source, :summary
    def initialize(files:, repository:, entries:, implementation_commit:, implementation_tree:,
                   freeze_tree:, implementation_delta:, predecessor_delta:, listing_sha256:)
      @files, @budget, @repository = files, files.budget, repository
      @entries = entries
      @implementation_commit, @implementation_tree, @freeze_tree = implementation_commit, implementation_tree, freeze_tree
      @listing_sha256 = listing_sha256
      @delta = implementation_delta
      Check.that(!@delta.empty? && (@delta.map { |row| row['path'] } - IMPLEMENTATION_PATHS).empty?, 'implementation delta allowlist')
      Check.that(predecessor_delta.length == 1 && predecessor_delta[0]['status'] == 'A' && predecessor_delta[0]['path'] == FREEZE_PATH && predecessor_delta[0]['mode'] == '100644', 'one-path freeze commit delta')
      freeze_entries = GitObjects.reverse(entries, @delta, @budget)
      predecessor_entries = GitObjects.reverse(freeze_entries, predecessor_delta, @budget)
      @trees = [
        ['PREDECESSOR', GitObjects.reconstruct(predecessor_entries, @budget)],
        ['FREEZE', GitObjects.reconstruct(freeze_entries, @budget)],
        ['IMPLEMENTATION', GitObjects.reconstruct(entries, @budget)]
      ]
      Check.that(@trees.map { |_, value| value['root_oid'] } == [PREDECESSOR_TREE, freeze_tree, implementation_tree], 'three reconstructed tree roots')
      @objects = [{ oid: implementation_commit, type: 'commit', role: :implementation_commit },
                  { oid: FREEZE_COMMIT, type: 'commit', role: :freeze_commit }]
      entries.each { |entry| @budget.check; @objects << { oid: entry['oid'], type: 'blob', role: :worktree, entry: entry } }
      @objects << { oid: PBX_BASELINE, type: 'blob', role: :baseline }
      @request = @objects.map { |object| object[:oid] + "\n" }.join.b.freeze
      Check.that(@request.bytesize == (entries.length + 3) * 41 && @request.bytesize.between?(205, 10_537), 'batch exact immutable request')
      @at, @state, @header, @total, @payload_total = 0, :header, ''.b, 0, 0
      @response_hash = Digest::SHA256.new
      @joins, @commits, @worktree, @dirty = [], {}, {}, []
      @current = @held = @implementation_pbx = @baseline_pbx = nil
      @closed = false
    end

    def consume(chunk)
      @budget.check
      Check.that(!@closed, 'batch already terminal')
      Check.that(chunk.bytesize.between?(1, 65_536), 'batch chunk bound')
      @total += chunk.bytesize
      Check.that(@total <= 29_425_792, 'batch complete response cap')
      @response_hash.update(chunk)
      offset = 0
      while offset < chunk.bytesize
        @budget.check
        case @state
        when :header
          Check.that(@at < @objects.length, 'batch extra response')
          byte = chunk.getbyte(offset)
          offset += 1
          if byte == 10
            begin_object
          else
            @header << byte
            Check.that(@header.bytesize <= 64, 'batch header size')
          end
        when :payload
          count = [@size - @received, chunk.bytesize - offset].min
          Check.that(count > 0, 'batch zero payload step')
          payload = chunk.byteslice(offset, count)
          @object_sha1.update(payload)
          @object_sha256.update(payload)
          @retained << payload if @retained
          @received += count
          offset += count
          @state = :separator if @received == @size
        when :separator
          Check.that(chunk.getbyte(offset) == 10, 'batch payload separator')
          offset += 1
          finish_object
          @state = :header
        else raise Rejected, 'batch state'
        end
      end
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end

    def close
      @closed = true
      # Terminal cleanup releases these transient owned references even when a
      # comparison, parser step or the one held close fails. Evidence summaries
      # and source/join metadata remain available; a closed parser never resumes.
      @implementation_pbx = @baseline_pbx = @retained = @current = nil
      close_held
    end

    def finish(argv)
      @budget.check
      Check.that(!@closed, 'batch finish already terminal')
      Check.that(@at == @objects.length && @header.empty? && @state == :header && @held.nil?, 'batch missing response or trailing framing')
      Check.that(@dirty == DIRTY_PINS.map(&:first), 'exact two dirty exceptions')
      Check.that(@implementation_pbx && @baseline_pbx, 'PBX buffers missing')
      PBXDelta.validate(@baseline_pbx, @implementation_pbx, @budget)
      @implementation_pbx = @baseline_pbx = nil
      delta_paths = @delta.map { |row| row.fetch('path') }
      delta_pins = delta_paths.map { |path| @budget.check; { 'path' => path, 'sha256' => @worktree.fetch(path).fetch('sha256') } }
      frozen_pins = PIN_DATA.fetch('pinned_source_inputs').reject { |pin| delta_paths.include?(pin.fetch('path')) }.map do |pin|
        @budget.check
        Check.that(@worktree.fetch(pin.fetch('path')).fetch('sha256') == pin.fetch('sha256'), 'selected frozen source pin')
        { 'path' => pin.fetch('path'), 'sha256' => pin.fetch('sha256') }
      end
      @source = {
        'delta_path_pins' => delta_pins, 'delta_paths' => delta_paths, 'freeze_commit' => FREEZE_COMMIT,
        'freeze_tree' => @freeze_tree, 'frozen_input_pins' => frozen_pins,
        'implementation_commit' => @implementation_commit, 'implementation_tree' => @implementation_tree
      }
      @summary = {
        'argv' => argv, 'auxiliary_object_count' => 3, 'clean_match_count' => @entries.length - 2,
        'cwd' => ROOT, 'dirty_exception_count' => 2, 'entry_count' => @entries.length,
        'entry_join_sha256' => Digest::SHA256.hexdigest(Canonical.encode(@joins, @budget)),
        'environment' => ENVIRONMENT, 'exit_status' => 0,
        'freeze_reconstructed_tree' => @freeze_tree, 'implementation_reconstructed_tree' => @implementation_tree,
        'listing_sha256' => @listing_sha256,
        'pbx_baseline_blob_byte_count' => @baseline_summary.fetch('byte_count'),
        'pbx_baseline_blob_oid' => PBX_BASELINE, 'pbx_baseline_blob_recomputed_oid' => PBX_BASELINE,
        'pbx_baseline_blob_sha256' => PBX_BASELINE_SHA256, 'predecessor_reconstructed_tree' => PREDECESSOR_TREE,
        'request_byte_count' => @request.bytesize, 'request_sha256' => Digest::SHA256.hexdigest(@request),
        'response_byte_count' => @total, 'response_sha256' => @response_hash.hexdigest,
        'stderr' => Canonical.stream(''.b), 'stdin_closed' => true, 'stdout_eof' => true,
        'tree_reconstruction_join_sha256' => Digest::SHA256.hexdigest(Canonical.encode(@trees.map { |name, tree| tree.merge('snapshot' => name) }, @budget))
      }
      %w[implementation freeze].each do |prefix|
        @commits.fetch(prefix.to_sym).each { |key, value| @summary[prefix + '_commit_' + key] = value }
      end
      @summary
    ensure
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
    end
    private
    def close_held
      owned = @held
      @held = nil
      Cleanup.close_all([owned])
    end
    def begin_object
      @current = @objects.fetch(@at)
      match = /\A([0-9a-f]{40}) (commit|blob) (0|[1-9][0-9]{0,6})\z/.match(@header)
      Check.that(match && match[1] == @current[:oid] && match[2] == @current[:type], 'batch requested OID/type')
      @size = match[3].to_i
      Check.that(@size <= 1_048_576 && (@current[:role] == :worktree || @size > 0), 'batch payload size')
      @payload_total += @size if @current[:role] == :worktree
      Check.that(@payload_total <= 26_214_400, 'implementation blob aggregate size')
      @object_sha1, @object_sha256 = Digest::SHA1.new, Digest::SHA256.new
      @object_sha1.update(@current[:type] + ' ' + @size.to_s + "\0")
      retain = @current[:role] != :worktree || @current[:entry]['path'] == PBX_PATH
      @retained = retain ? ''.b : nil
      @received = 0
      @header = ''.b
      if @current[:role] == :worktree
        entry = @current.fetch(:entry)
        @held, @held_observation = @files.pair(@repository, entry.fetch('path'))
        execute = @held_observation.fetch('identity').fetch('mode') & 0o111
        Check.that(execute == (entry.fetch('mode') == '100755' ? 0o111 : 0), 'Git executable-bit triplet')
      end
      @state = @size == 0 ? :separator : :payload
    end
    def finish_object
      oid, sha256 = @object_sha1.hexdigest, @object_sha256.hexdigest
      Check.that(oid == @current.fetch(:oid), 'streamed raw Git object SHA1')
      case @current[:role]
      when :implementation_commit
        @commits[:implementation] = GitObjects.commit(@retained, @implementation_commit, @implementation_tree, FREEZE_COMMIT, @budget)
      when :freeze_commit
        @commits[:freeze] = GitObjects.commit(@retained, FREEZE_COMMIT, @freeze_tree, PREDECESSOR, @budget)
      when :baseline
        Check.that(sha256 == PBX_BASELINE_SHA256, 'PBX auxiliary baseline SHA256')
        @baseline_pbx = @retained
        @baseline_summary = { 'byte_count' => @size }
      when :worktree
        entry, first = @current.fetch(:entry), @held_observation
        after = @files.observe(@repository, entry.fetch('path'))
        Check.that(@files.identity(@held) == first.fetch('identity') && first == after, 'post-named worktree observation')
        close_held
        path = entry.fetch('path')
        dirty = DIRTY_PINS.find { |candidate, _| candidate == path }
        if dirty
          Check.that(first.fetch('sha256') == dirty[1] && [@size, sha256] != first.values_at('byte_count', 'sha256'), 'frozen dirty mismatch')
          @dirty << path
          disposition = 'FROZEN_DIRTY_EXCEPTION'
        else
          Check.that([@size, sha256] == first.values_at('byte_count', 'sha256'), 'raw worktree/commit byte equality')
          disposition = 'RAW_MATCH'
        end
        Check.that(sha256 == FREEZE_SHA256, 'freeze artifact byte pin') if path == FREEZE_PATH
        @worktree[path] = first
        @joins << { 'blob_byte_count' => @size, 'blob_oid' => oid, 'blob_recomputed_oid' => oid,
                    'blob_sha256' => sha256, 'disposition' => disposition, 'mode' => entry.fetch('mode'),
                    'path' => path, 'worktree_byte_count' => first.fetch('byte_count'), 'worktree_sha256' => first.fetch('sha256') }
        @implementation_pbx = @retained if path == PBX_PATH
      end
      @retained = @current = nil
      @at += 1
    end
  end

  class GitControl
    CONFIG_SHA256 = 'cae33efdb02cf774435c1ff9cb16bcc1014606908530c6e1dc727615fe3e8cda'.freeze
    CONFIG_BYTES = "[core]\n\trepositoryformatversion = 0\n\tfilemode = true\n\tbare = false\n\tlogallrefupdates = true\n\tignorecase = true\n\tprecomposeunicode = true\n".freeze
    ABSENT = %w[commondir config.worktree shallow packed-refs info/grafts info/attributes objects/info/alternates objects/info/http-alternates].freeze
    attr_reader :repository, :implementation_commit
    def initialize(files)
      @files = files
      @repository = @git = nil
      @held = {}
    end
    def open
      @repository = @files.absolute(ROOT, directory: true)
      @git = @files.relative(@repository, '.git', directory: true)
      @root_identity, @git_identity = @files.identity(@repository, directory: true), @files.identity(@git, directory: true)
      %w[config HEAD refs/heads/main].each do |path|
        @files.budget.check
        io, observation = @files.pair(@git, path, retain: true)
        @held[path] = [io, observation]
      end
      config = @held.fetch('config')[1]
      Check.that(config['byte_count'] == 137 && config['bytes'] == CONFIG_BYTES && config['sha256'] == CONFIG_SHA256, 'Git exact local configuration')
      Check.that(@held.fetch('HEAD')[1]['bytes'] == "ref: refs/heads/main\n", 'Git symbolic HEAD')
      main = @held.fetch('refs/heads/main')[1]['bytes']
      Check.that(/\A[0-9a-f]{40}\n\z/.match?(main), 'Git main ref bytes')
      @implementation_commit = Check.oid(main.byteslice(0, 40))
      Check.that(@implementation_commit != FREEZE_COMMIT, 'implementation is not a direct successor yet')
      self
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def checkpoint
      @files.budget.check
      Check.that(@files.identity(@repository, directory: true) == @root_identity && @files.identity(@git, directory: true) == @git_identity, 'held Git root identity')
      named_root = @files.absolute(ROOT, directory: true)
      begin
        named_git = @files.relative(named_root, '.git', directory: true)
        begin
          Check.that(@files.identity(named_root, directory: true) == @root_identity && @files.identity(named_git, directory: true) == @git_identity, 'named Git root identity')
        ensure
          Cleanup.close_all([named_git], original_error: $!)
        end
      ensure
        Cleanup.close_all([named_root], original_error: $!)
      end
      @held.each do |path, pair|
        @files.budget.check
        io, observation = pair
        named = @files.relative(@git, path)
        begin
          Check.that(@files.identity(io) == observation['identity'] && @files.identity(named) == observation['identity'], 'Git control-plane identity drift')
        ensure
          Cleanup.close_all([named], original_error: $!)
        end
      end
      ABSENT.each { |path| @files.budget.check; require_absent(path) }
      true
    end
    def finish
      checkpoint
      @held.each do |path, pair|
        @files.budget.check
        io, before = pair
        after = @files.observe(@git, path, retain: true)
        Check.that(before == after && @files.identity(io) == before['identity'], 'Git control-plane post content drift')
      end
      true
    end
    def close
      owned = [@repository, @git] + @held.values.map(&:first)
      @held = {}
      @repository = @git = nil
      Cleanup.close_all(owned)
    end
    private
    def require_absent(path)
      components = path.split('/')
      leaf = components.pop
      parent = components.empty? ? @git : @files.relative(@git, components.join('/'), directory: true)
      begin
        @files.budget.check
        fd, error = @files.native.call(:openat, parent.fileno, leaf, Native::READ_FILE, 0)
        if fd >= 0
          IO.for_fd(fd, autoclose: true).close
          raise Rejected, 'forbidden Git control-plane file present'
        end
        Check.that(error == 2, 'Git control-plane absence errno')
      ensure
        Cleanup.close_all(parent.equal?(@git) ? [] : [parent], original_error: $!)
      end
    end
  end

  class Namespace
    def initialize(files, repository)
      @files, @repository, @budget = files, repository, files.budget
    end
    def validate(entries)
      guard = PIN_DATA.fetch('dirty_file_guard')
      ambient, ignored = guard.fetch('ambient_root_names'), guard.fetch('ignored_path_names')
      structural = guard.fetch('workspace_structural_directories')
      { 'ambient_root_names' => ambient, 'ignored_path_names' => ignored,
        'workspace_structural_directories' => structural }.each do |field, paths|
        @budget.check
        Check.that(Digest::SHA256.hexdigest(paths.map { |path| path + "\n" }.join) == guard.fetch(field + '_sha256'), 'namespace literal serialization pin')
      end
      opaque = (ambient + ignored).select { |path| path.end_with?('/') }.map { |path| path.chomp('/') } + ['.git']
      skeleton = { '' => {} }
      all = entries.map { |entry| entry.fetch('path') } + ambient + ignored + structural + ['.git/']
      all.each do |path|
        @budget.check
        clean = path.end_with?('/') ? path.byteslice(0, path.bytesize - 1) : path
        parts, prefix = Check.path(clean).split('/'), ''
        parts.each_with_index do |part, index|
          @budget.check
          break if opaque.include?(prefix)
          skeleton[prefix] ||= {}
          skeleton[prefix][part] = true
          prefix = prefix.empty? ? part : prefix + '/' + part
          if index < parts.length - 1 || path.end_with?('/')
            skeleton[prefix] ||= {} unless opaque.include?(prefix)
          end
        end
      end
      Check.that(skeleton.length <= 1900, 'namespace skeleton bound')
      held = []
      begin
        skeleton.keys.sort_by(&:b).each do |path|
          @budget.check
          io = path.empty? ? @files.absolute(ROOT, directory: true) : @files.relative(@repository, path, directory: true)
          held << [io, nil]
          identity = @files.identity(io, directory: true)
          held[-1][1] = identity
          @files.inventory(io, path.empty? ? ROOT : ROOT + '/' + path, skeleton.fetch(path).keys.sort_by(&:b))
        end
        (ambient + ignored + structural).each do |path|
          @budget.check
          directory = path.end_with?('/')
          io = @files.relative(@repository, directory ? path.chomp('/') : path, directory: directory)
          io.close
        end
        held.each { |io, identity| @budget.check; Check.that(@files.identity(io, directory: true) == identity, 'namespace retained directory drift') }
      ensure
        Cleanup.close_all(held.map(&:first), original_error: $!)
      end
      {
        'allowed_tracked_dirty' => DIRTY_PINS.map { |path, sha| { 'path' => path, 'sha256' => sha } },
        'ambient_roots_count' => 53, 'ambient_roots_sha256' => guard.fetch('ambient_root_names_sha256'),
        'head_matches_implementation' => true, 'ignored_paths_count' => 7,
        'ignored_paths_sha256' => guard.fetch('ignored_path_names_sha256'), 'index_empty' => true,
        'unexpected_namespace_entries' => 0, 'workspace_structural_directories_count' => 4,
        'workspace_structural_directories_sha256' => guard.fetch('workspace_structural_directories_sha256')
      }
    end
  end

  class SourcePass
    BASE = ['/usr/bin/git', '--no-replace-objects', '--git-dir=' + ROOT + '/.git', '--work-tree=' + ROOT].freeze
    attr_reader :candidate, :entries
    def initialize(files, supervisor, self_sha256)
      @files, @supervisor, @self_sha256 = files, supervisor, self_sha256
    end
    def perform(independent_dirty_reads:)
      control = GitControl.new(@files).open
      batch = nil
      begin
        commit = control.implementation_commit
        @probes = []
        head = probe(control, ['rev-parse', 'HEAD'])
        tree = probe(control, ['rev-parse', 'HEAD^{tree}'])
        freeze_tree = probe(control, ['rev-parse', FREEZE_COMMIT + '^{tree}'])
        Check.that(oid_line(head) == commit, 'Git held main/HEAD join')
        tree_oid, freeze_tree_oid = oid_line(tree), oid_line(freeze_tree)
        raw_args = %w[diff --raw --no-abbrev --no-renames --no-ext-diff --no-textconv -z]
        predecessor_delta = GitObjects.delta(probe(control, raw_args + [PREDECESSOR + '..' + FREEZE_COMMIT, '--']), @files.budget)
        implementation_delta = GitObjects.delta(probe(control, raw_args + [FREEZE_COMMIT + '..' + commit, '--']), @files.budget)
        names = probe(control, ['-c', 'core.quotePath=false', 'diff', '--no-ext-diff', '--no-textconv', '--name-only', '--no-renames', '-z', FREEZE_COMMIT + '..' + commit, '--'])
        Check.that(names == implementation_delta.map { |row| row.fetch('path') + "\0" }.join.b, 'raw/name-only delta equality')
        listing_bytes = probe(control, ['ls-tree', '-r', '-z', '--full-tree', commit])
        @entries = GitObjects.listing(listing_bytes, @files.budget)
        batch = TrackedBatch.new(files: @files, repository: control.repository, entries: @entries,
                                 implementation_commit: commit, implementation_tree: tree_oid, freeze_tree: freeze_tree_oid,
                                 implementation_delta: implementation_delta, predecessor_delta: predecessor_delta,
                                 listing_sha256: Digest::SHA256.hexdigest(listing_bytes))
        control.checkpoint
        argv = BASE + ['cat-file', '--batch']
        result = @supervisor.run(argv, cwd: ROOT, seconds: 30, maximum: 29_425_792,
                                 input: batch.request, consumer: batch.method(:consume))
        Check.that(result.fetch('stderr').empty?, 'batch stderr')
        @probes << batch.finish(argv)
        raw_index = probe(control, ['ls-files', '--stage', '-z', '--'])
        GitObjects.index(raw_index, @entries, @files.budget)
        control.finish
        dirty_guard = Namespace.new(@files, control.repository).validate(@entries)
        if independent_dirty_reads
          DIRTY_PINS.each do |path, expected|
            @files.budget.check
            held, observation = @files.pair(control.repository, path)
            held.close
            Check.that(observation.fetch('sha256') == expected, 'independent dirty content pin')
          end
        end
        self_pin = batch.source.fetch('delta_path_pins').find { |pin| pin['path'] == SOURCE }
        Check.that(self_pin && self_pin['sha256'] == @self_sha256, 'executing/interpreted/tree seal source join')
        @candidate = { 'dirty_guard' => dirty_guard, 'probes' => @probes,
                       'schema' => 'com.ergentics.provenance.h3-qualification-source-state.v1',
                       'source' => batch.source, 'version' => 1 }
        bytes = Canonical.encode(@candidate, @files.budget)
        Check.that(bytes.bytesize <= 262_144 && @probes.length == 9, 'source candidate bytes/count')
        bytes
      ensure
        Cleanup.attempts(original_error: $!) do |attempt|
          attempt.call { batch.close } if batch
          attempt.call { control.close }
        end
      end
    end
    private
    def probe(control, arguments)
      control.checkpoint
      argv = BASE + arguments
      result = @supervisor.run(argv, cwd: ROOT, seconds: 30)
      Check.that(result.fetch('stderr').empty?, 'source probe stderr')
      @probes << { 'argv' => argv, 'cwd' => ROOT, 'environment' => ENVIRONMENT, 'exit_status' => 0,
                   'stderr' => Canonical.stream(result.fetch('stderr')), 'stdout' => Canonical.stream(result.fetch('stdout')) }
      result.fetch('stdout')
    end
    def oid_line(bytes)
      Check.that(/\A[0-9a-f]{40}\n\z/.match?(bytes), 'Git single OID line')
      Check.oid(bytes.byteslice(0, 40))
    end
  end

  class BuildSettings
    APP = 'ErgenticsProvenance'.freeze
    CONTROLLER = 'ErgenticsProvenanceH3QualificationController'.freeze
    COMMON = {
      'ARCHS' => 'arm64', 'CODE_SIGN_IDENTITY' => 'Apple Development', 'CODE_SIGN_STYLE' => 'Automatic',
      'CODE_SIGNING_ALLOWED' => 'YES', 'CODE_SIGNING_REQUIRED' => 'YES', 'DEVELOPMENT_TEAM' => 'ZCQ435U8JP',
      'ENABLE_HARDENED_RUNTIME' => 'YES', 'MACOSX_DEPLOYMENT_TARGET' => '26.0', 'PLATFORM_NAME' => 'macosx',
      'SDKROOT' => '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk', 'SWIFT_VERSION' => '6.0'
    }.freeze
    APPLICATION = {
      'CODE_SIGN_ENTITLEMENTS' => 'Entitlements.plist', 'ENABLE_APP_SANDBOX' => 'YES',
      'EXECUTABLE_NAME' => 'Ergentics Provenance', 'EXECUTABLE_PATH' => 'Ergentics Provenance.app/Contents/MacOS/Ergentics Provenance',
      'FULL_PRODUCT_NAME' => 'Ergentics Provenance.app', 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.ergentics.provenance',
      'PRODUCT_NAME' => 'Ergentics Provenance', 'TARGET_NAME' => APP
    }.freeze
    CONTROL = {
      'CODE_SIGN_INJECT_BASE_ENTITLEMENTS' => 'NO', 'CREATE_INFOPLIST_SECTION_IN_BINARY' => 'YES',
      'ENABLE_APP_SANDBOX' => 'NO', 'EXECUTABLE_NAME' => CONTROLLER, 'EXECUTABLE_PATH' => CONTROLLER,
      'FULL_PRODUCT_NAME' => CONTROLLER, 'GENERATE_INFOPLIST_FILE' => 'YES',
      'PRODUCT_BUNDLE_IDENTIFIER' => 'com.ergentics.provenance.h3-qualification-controller',
      'PRODUCT_NAME' => CONTROLLER, 'SKIP_INSTALL' => 'YES', 'TARGET_NAME' => CONTROLLER
    }.freeze
    def self.validate(bytes, configuration:, ordinary:, budget: Budget.new)
      Check.that(%w[Debug Release].include?(configuration), 'settings configuration')
      root = JSONPreflight.new(bytes, budget, settings: true, maximum: 1_048_576).decode
      Check.that(root.instance_of?(Array) && root.length == 2, 'settings target count')
      records = {}
      root.each do |record|
        budget.check
        Check.that(record.instance_of?(Hash) && record.keys.sort == %w[action buildSettings target], 'settings record keys')
        target = record.fetch('target')
        Check.that([APP, CONTROLLER].include?(target) && !records.key?(target) && record['action'] == 'build', 'settings unique target/action')
        settings = record.fetch('buildSettings')
        Check.that(settings.instance_of?(Hash) && settings.all? { |key, value| key.instance_of?(String) && key.bytesize <= 1024 && value.instance_of?(String) }, 'settings string key/value shape')
        expected = (target == APP ? APPLICATION : CONTROL).dup
        if ordinary
          expected = expected.select { |key, _| %w[TARGET_NAME PRODUCT_NAME FULL_PRODUCT_NAME].include?(key) }
          expected['CODE_SIGNING_ALLOWED'] = expected['CODE_SIGNING_REQUIRED'] = 'NO'
          conditions = configuration == 'Debug' ? ['DEBUG'] : []
        else
          expected.merge!(COMMON)
          expected['CONFIGURATION'] = configuration
          expected['TARGET_BUILD_DIR'] = '/private/tmp/ergentics-h3q-' + configuration.downcase + '-v1/Build/Products/' + configuration
          expected['BUILT_PRODUCTS_DIR'] = expected['CONFIGURATION_BUILD_DIR'] = expected['TARGET_BUILD_DIR']
          Check.that(!settings.key?('CODE_SIGN_ENTITLEMENTS'), 'controller entitlement setting present') if target == CONTROLLER
          conditions = (configuration == 'Debug' ? ['DEBUG'] : []) + ['EPR_H3_QUALIFICATION']
        end
        expected.each { |key, value| budget.check; Check.that(settings[key] == value, 'resolved required build setting ' + key) }
        raw_conditions = settings.fetch('SWIFT_ACTIVE_COMPILATION_CONDITIONS', '')
        tokens = raw_conditions.split(/[ \t\r\n]+/).reject(&:empty?)
        Check.that(tokens.sort == conditions.sort && tokens.uniq == tokens, 'resolved compilation condition set')
        Check.that(!tokens.include?('EPR_H3_QUALIFICATION_TESTS'), 'test-only condition in product settings')
        records[target] = record
      end
      [records.fetch(APP), records.fetch(CONTROLLER)]
    rescue KeyError, TypeError
      raise Rejected, 'settings missing or ill-typed field'
    end
  end

  class UserSchemeGuard
    ROOTS = %w[ErgenticsProvenance.xcodeproj/xcuserdata ErgenticsProvenance.xcodeproj/project.xcworkspace/xcuserdata].freeze
    def initialize(files, repository)
      @files, @repository, @roots = files, repository, []
      ROOTS.each do |path|
        files.budget.check
        io = files.relative(repository, path, directory: true)
        @roots << [path, io, nil]
        @roots[-1][2] = files.identity(io, directory: true)
      end
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def walk
      @entries = @returns = @handles = 0
      seen = {}
      pending = @roots.map { |path, io, identity| [path, io, identity, 0, false] }.reverse
      until pending.empty?
        @files.budget.check
        path, io, before, depth, owned = pending.pop
        directory = nil
        begin
          key = before.values_at('device', 'inode')
          Check.that(!seen.key?(key), 'user scheme directory cycle')
          seen[key] = true
          Check.that(depth <= 8 && @files.identity(io, directory: true) == before, 'user scheme directory admission')
          @handles += 1
          Check.that(@handles <= 4098, 'user scheme directory handles')
          directory = Dir.open(ROOT + '/' + path, encoding: Encoding::BINARY)
          names, calls, dots = {}, 0, []
          temporary = IO.for_fd(directory.fileno, autoclose: false)
          Check.that(@files.identity(temporary, directory: true) == before, 'user scheme Dir descriptor join')
          loop do
            @files.budget.check
            calls += 1
            @returns += 1
            Check.that(calls <= 4099 && @returns <= 32_768, 'user scheme read return bound')
            name = directory.read
            break if name.nil?
            Check.that(!names.key?(name), 'user scheme duplicate entry')
            names[name] = true
            if name == '.' || name == '..'
              dots << name
              next
            end
            @entries += 1
            Check.that(@entries <= 4096 && name.bytesize.between?(1, 1024) && !name.include?("\0") && !name.include?('/'), 'user scheme entry bound')
            Check.that(name.dup.force_encoding(Encoding::UTF_8).valid_encoding?, 'user scheme UTF-8 name')
            Check.that(!name.tr('A-Z', 'a-z').end_with?('.xcscheme'), 'shadowing user scheme')
            @files.budget.check
            fd, error = @files.native.call(:openat, io.fileno, name, Native::O_EVTONLY | Native::O_NOFOLLOW | Native::O_CLOEXEC, 0)
            event = @files.wrap(fd, error)
            begin
              stat = event.stat
              Check.that(stat.file? || stat.directory?, 'user scheme nonregular entry')
              identity = @files.identity(event, directory: stat.directory?)
              Check.that(stat.uid == 501, 'user scheme entry owner')
              if stat.directory?
                Check.that(depth < 8, 'user scheme directory depth')
                child = @files.relative(io, name, directory: true)
                pending << [path + '/' + name, child, identity, depth + 1, true]
                Check.that(@files.identity(child, directory: true) == identity, 'user scheme directory reopen')
              end
            ensure
              Cleanup.close_all([event], original_error: $!)
            end
          end
          Check.that(dots.sort == ['.', '..'] && @files.identity(temporary, directory: true) == before, 'user scheme enumeration identity/dots')
        ensure
          Cleanup.close_all([owned ? io : nil, directory], original_error: $!)
        end
      end
      @roots.each do |path, io, before|
        @files.budget.check
        named = @files.relative(@repository, path, directory: true)
        begin
          Check.that(@files.identity(named, directory: true) == before && @files.identity(io, directory: true) == before, 'user scheme held root replacement')
        ensure
          Cleanup.close_all([named], original_error: $!)
        end
      end
      true
    ensure
      Cleanup.close_all(pending.select { |entry| entry[4] }.map { |entry| entry[1] }, original_error: $!) if pending
    end
    def close
      owned = (@roots || []).map { |entry| entry[1] }
      @roots = []
      Cleanup.close_all(owned)
    end
  end

  class SchemeBracket
    def initialize(files, repository, pin)
      @files, @repository, @pin = files, repository, pin
    end
    def around
      held = guard = nil
      begin
        held, before = @files.pair(@repository, SCHEME_PATH, minimum: 1, maximum: 8192, retain: true)
        Check.that(before.fetch('sha256') == @pin, 'scheme implementation-tree pin')
        QualificationScheme.validate(before.fetch('bytes'), @files.budget)
        guard = UserSchemeGuard.new(@files, @repository)
        guard.walk
        result = yield
        after = @files.hash(held, minimum: 1, maximum: 8192, rewind: true, retain: true)
        named = @files.observe(@repository, SCHEME_PATH, minimum: 1, maximum: 8192, retain: true)
        Check.that(before == after && before == named, 'scheme pre/post content or identity drift')
        guard.walk
        result
      ensure
        Cleanup.close_all([held, guard], original_error: $!)
      end
    end
  end

  class OrdinaryCompatibility
    XCODEBUILD = '/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild'.freeze
    def initialize(files, supervisor, runtime)
      @files, @supervisor, @runtime = files, supervisor, runtime
    end
    def run
      parent = repository = nil
      before_count = @supervisor.children
      begin
        parent = @files.absolute('/private/tmp', directory: true, owner: 0)
        repository = @files.absolute(ROOT, directory: true)
        stat = @files.identity(parent, directory: true)
        Check.that(stat['mode'] == 0o1777, 'ordinary temporary parent policy')
        pass = SourcePass.new(@files, @supervisor, @runtime.self_sha256)
        first = pass.perform(independent_dirty_reads: true)
        source = pass.candidate.fetch('source')
        scheme = source.fetch('delta_path_pins').find { |pin| pin['path'] == SCHEME_PATH }
        Check.that(scheme, 'qualification scheme missing from implementation delta')
        [['Debug', true], ['Debug', false], ['Release', true], ['Release', false]].each do |configuration, settings|
          @files.budget.check
          suffix = configuration.downcase + (settings ? '-settings' : '-build')
          basename = 'ergentics-h3q-ordinary-' + suffix + '-v1'
          argv = [XCODEBUILD, '-project', ROOT + '/ErgenticsProvenance.xcodeproj',
                  '-scheme', 'ErgenticsProvenanceH3Qualification', '-configuration', configuration,
                  '-destination', 'platform=macOS,arch=arm64', '-derivedDataPath', '/private/tmp/' + basename,
                  'CODE_SIGNING_ALLOWED=NO', 'CODE_SIGNING_REQUIRED=NO', 'build']
          argv += ['-showBuildSettings', '-json'] if settings
          result = SchemeBracket.new(@files, repository, scheme.fetch('sha256')).around do
            @files.absent(parent, basename)
            @supervisor.run(argv, cwd: ROOT, seconds: settings ? 120 : 900,
                            maximum: settings ? 1_048_576 : 8_388_608, merged: !settings)
          end
          if settings
            Check.that(result.fetch('stderr').empty?, 'ordinary settings stderr')
            BuildSettings.validate(result.fetch('stdout'), configuration: configuration, ordinary: true, budget: @files.budget)
          end
          observation = pass.perform(independent_dirty_reads: true)
          Check.that(observation == first, 'C1...C5 source candidate mismatch')
        end
        Check.that(@supervisor.children - before_count == 49, 'ordinary exact direct-child count')
        Check.that(@files.identity(parent, directory: true) == stat, 'ordinary retained parent drift')
        true
      ensure
        Cleanup.close_all([parent, repository], original_error: $!)
      end
    end
  end

  module ProbeBytes
    module_function
    def stream(value, budget)
      budget.check
      Check.that(value.instance_of?(Hash) && value.keys.sort == %w[base64 byte_count sha256 truncated], 'captured stream keys')
      Check.that(value['byte_count'].instance_of?(Integer) && value['byte_count'].between?(0, 65_536) && value['truncated'] == false, 'captured stream bound')
      encoded = value['base64']
      Check.that(encoded.instance_of?(String) && encoded.bytesize <= 87_384, 'captured base64 bound')
      begin
        bytes = Base64.strict_decode64(encoded)
      rescue ArgumentError
        raise Rejected, 'captured base64 syntax'
      end
      Check.that(Base64.strict_encode64(bytes) == encoded && bytes.bytesize == value['byte_count'] && Digest::SHA256.hexdigest(bytes) == value['sha256'], 'captured stream exact bytes/hash')
      bytes
    end
    def command(value, argv, cwd, budget)
      budget.check
      Check.that(value.instance_of?(Hash) && value.keys.sort == %w[argv cwd environment exit_status stderr stdout], 'command probe keys')
      Check.that(value['argv'] == argv && value['cwd'] == cwd && value['environment'] == ENVIRONMENT &&
                 value['exit_status'].instance_of?(Integer) && value['exit_status'] == 0, 'command probe execution context')
      [stream(value.fetch('stdout'), budget), stream(value.fetch('stderr'), budget)]
    end
    def utf8(bytes, budget)
      budget.check
      value = bytes.dup.force_encoding(Encoding::UTF_8)
      Check.that(value.valid_encoding? && !value.include?("\0"), 'probe UTF-8/NUL')
      value
    end
    def lines(bytes, budget)
      text = utf8(bytes, budget).b
      Check.that(text.empty? || text.end_with?("\n"), 'probe line framing')
      result, offset = [], 0
      while offset < text.bytesize
        budget.check
        endpoint = text.index("\n", offset)
        Check.that(endpoint && result.length < 65_536, 'probe line limit')
        result << text.byteslice(offset, endpoint - offset).force_encoding(Encoding::UTF_8)
        offset = endpoint + 1
      end
      result
    end
    def field(lines, name, budget)
      matches = []
      lines.each do |line|
        budget.check
        matches << line.byteslice(name.bytesize + 1, line.bytesize) if line.start_with?(name + '=')
      end
      Check.that(matches.length == 1 && !matches[0].empty?, 'codesign unique field ' + name)
      matches[0]
    end
  end

  class ToolchainProbes
    ARGV = [
      ['/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild', '-version'],
      ['/usr/bin/xcrun', '--sdk', 'macosx', '--show-sdk-version'],
      ['/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc', '--version'],
      ['/usr/bin/ruby', '--disable=gems,rubyopt,did_you_mean', '-v'],
      ['/usr/bin/shasum', '-a', '256', '/usr/bin/ruby'],
      ['/usr/bin/codesign', '-d', '--verbose=4', '/usr/bin/ruby'],
      ['/usr/bin/shasum', '-a', '256', '/usr/bin/env'],
      ['/usr/bin/codesign', '-d', '--verbose=4', '/usr/bin/env'],
      ['/usr/bin/sw_vers', '-buildVersion'], ['/usr/bin/uname', '-m']
    ].freeze
    def self.validate(probes, budget = Budget.new)
      Check.that(probes.instance_of?(Array) && probes.length == 10, 'toolchain ten probes')
      streams = probes.each_with_index.map { |probe, index| budget.check; ProbeBytes.command(probe, ARGV[index], '/private/var/empty', budget) }
      [0, 1, 2, 3, 4, 6, 8, 9].each { |index| budget.check; Check.that(streams[index][1].empty?, 'toolchain unexpected stderr') }
      Check.that(streams[0][0] == "Xcode 26.6\nBuild version 17F113\n" && streams[1][0] == "26.5\n", 'Xcode/SDK version pin')
      swift_lines = ProbeBytes.lines(streams[2][0], budget)
      # The driver and compiler version may share their one version line; the
      # three exact facts must each occur once and no additional line is valid.
      Check.that(swift_lines == [
        'swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)',
        'Target: arm64-apple-macosx26.0'
      ] || swift_lines == [
        'swift-driver version: 1.148.6',
        'Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)',
        'Target: arm64-apple-macosx26.0'
      ], 'Swift driver/compiler/target pin')
      Check.that(streams[3][0] == "ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]\n", 'Ruby version output pin')
      pin = PIN_DATA.fetch('toolchain_pin')
      [[4, 5, 'seal_runtime', '/usr/bin/ruby'], [6, 7, 'seal_launcher', '/usr/bin/env']].each do |hash_index, code_index, prefix, path|
        budget.check
        Check.that(streams[hash_index][0] == pin.fetch(prefix + '_sha256') + '  ' + path + "\n", 'platform executable hash probe')
        Check.that(streams[code_index][0].empty?, 'platform codesign display stdout')
        lines = ProbeBytes.lines(streams[code_index][1], budget)
        Check.that(ProbeBytes.field(lines, 'Executable', budget) == path &&
                   ProbeBytes.field(lines, 'Identifier', budget) == pin.fetch(prefix + '_identifier') &&
                   ProbeBytes.field(lines, 'CDHash', budget) == pin.fetch(prefix + '_cdhash'), 'platform codesign identity pin')
      end
      Check.that(streams[8][0] == "25G83\n" && streams[9][0] == "arm64\n", 'host build/architecture pin')
      mapping = {
        'architecture' => 'architecture', 'macos_build' => 'macos_build', 'macos_sdk' => 'macos_sdk_version',
        'seal_launcher_cdhash' => 'seal_launcher_cdhash', 'seal_launcher_identifier' => 'seal_launcher_identifier',
        'seal_launcher_path' => 'seal_launcher', 'seal_launcher_sha256' => 'seal_launcher_sha256',
        'seal_runtime_cdhash' => 'seal_runtime_cdhash', 'seal_runtime_identifier' => 'seal_runtime_identifier',
        'seal_runtime_path' => 'seal_runtime', 'seal_runtime_platform' => 'seal_runtime_platform',
        'seal_runtime_revision' => 'seal_runtime_revision', 'seal_runtime_sha256' => 'seal_runtime_sha256',
        'seal_runtime_support_pins_sha256' => 'seal_runtime_support_pins_sha256', 'seal_runtime_version' => 'seal_runtime_version',
        'swift_build' => 'swift_build', 'swift_driver_version' => 'swift_driver_version', 'swift_target' => 'target',
        'swift_version' => 'swift_version', 'swiftc_path' => 'swiftc', 'xcode_build' => 'xcode_build_version',
        'xcode_version' => 'xcode_version', 'xcodebuild_path' => 'xcodebuild'
      }
      value = mapping.each_with_object({}) { |(field, pin_field), out| budget.check; out[field] = pin.fetch(pin_field) }
      value['probes'] = probes
      value
    end
    def self.produce(supervisor, budget)
      probes = ARGV.map do |argv|
        budget.check
        result = supervisor.run(argv, cwd: '/private/var/empty', seconds: 30)
        { 'argv' => argv, 'cwd' => '/private/var/empty', 'environment' => ENVIRONMENT, 'exit_status' => 0,
          'stderr' => Canonical.stream(result.fetch('stderr')), 'stdout' => Canonical.stream(result.fetch('stdout')) }
      end
      validate(probes, budget)
    end
  end

  class ProductProbes
    ENTITLEMENTS = {
      'com.apple.security.app-sandbox' => true,
      'com.apple.security.files.user-selected.read-only' => true,
      'com.apple.security.hypervisor' => true
    }.freeze
    CONTROLLER = 'ErgenticsProvenanceH3QualificationController'.freeze
    def self.validate_requirement(requirement, identifier, budget, authority: nil)
      budget.check
      Check.that(requirement.bytesize.between?(1, 256) && requirement.each_codepoint.none? { |scalar| scalar < 32 || scalar == 127 }, 'product designated requirement text256')
      required = ['anchor apple generic', 'identifier "' + identifier + '"', 'certificate leaf[subject.OU] = "ZCQ435U8JP"']
      optional = ['certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */', 'certificate leaf[field.1.2.840.113635.100.6.1.2] /* exists */']
      clauses = requirement.split(' and ', -1)
      return requirement if clauses.uniq == clauses && (required - clauses).empty? && (clauses - required - optional).empty?

      # Narrow CN compatibility: the caller has independently admitted the
      # exact Apple Development/team/three-certificate metadata chain. The CN
      # must equal its actual first Authority, with the intermediate OID now
      # mandatory. This is a separate closed grammar, not a text-only fallback.
      budget.check
      prefix = 'Apple Development: '
      Check.that(authority.instance_of?(String) && authority.bytesize.between?(prefix.bytesize + 1, 256) &&
                 authority.start_with?(prefix) && !authority.include?('"') && !authority.include?('\\'), 'designated requirement CN Authority grammar')
      authority_text = authority.dup.force_encoding(Encoding::UTF_8)
      Check.that(authority_text.valid_encoding? && !/\A[[:space:]]*\z/.match?(authority_text.byteslice(prefix.bytesize, authority_text.bytesize)), 'designated requirement nonempty CN Authority')
      cn_clause = 'certificate leaf[subject.CN] = "' + authority_text + '"'
      # A quoted name may contain the literal conjunction text. Replace only
      # its exact complete clause in a local lexical copy before splitting.
      # Input controls forbid this marker in real bytes. Evidence is never
      # rewritten: both successful branches return the original requirement.
      marker = "\0H3_CAPTURED_LEAF_CN\0"
      lexical = requirement.gsub(cn_clause, marker)
      cn_clauses = lexical.split(' and ', -1)
      cn_required = required[0, 2] + [marker, optional[0]]
      cn_optional = [optional[1]]
      Check.that(cn_clauses.uniq == cn_clauses && (cn_required - cn_clauses).empty? &&
                 (cn_clauses - cn_required - cn_optional).empty?, 'designated requirement exact CN/Apple/identifier/intermediate conjunction')
      requirement
    end
    def self.paths(configuration, application)
      Check.that(%w[DEBUG RELEASE].include?(configuration), 'product configuration')
      variant = configuration == 'DEBUG' ? 'Debug' : 'Release'
      directory = '/private/tmp/ergentics-h3q-' + configuration.downcase + '-v1/Build/Products/' + variant
      code = directory + '/' + (application ? 'Ergentics Provenance.app' : CONTROLLER)
      executable = application ? code + '/Contents/MacOS/Ergentics Provenance' : code
      [code, executable]
    end
    def self.argv(configuration, application)
      code, executable = paths(configuration, application)
      [['/usr/bin/shasum', '-a', '256', executable], ['/usr/bin/dwarfdump', '--uuid', executable],
       ['/usr/bin/codesign', '--verify', '--strict', '--all-architectures', code],
       ['/usr/bin/codesign', '-d', '--verbose=4', '--requirements', '-', '--entitlements', ':-', code],
       ['/usr/bin/otool', '-L', executable], ['/usr/bin/nm', '-gju', executable]]
    end
    def self.entitlement_text(lines, budget)
      index = lines.index { |line| line.strip == '[Dict]' }
      return nil unless index
      rest = lines.drop(index)
      Check.that(rest[0].strip == '[Dict]', 'entitlement dictionary marker')
      rest.shift
      values = {}
      until rest.empty?
        budget.check
        Check.that(rest.length >= 3, 'entitlement dictionary entry framing')
        key, value_marker, boolean = rest.shift(3).map(&:strip)
        match = /\A\[Key\] ([A-Za-z0-9.-]+)\z/.match(key)
        Check.that(match && value_marker == '[Value]' && ['[Bool] true', '[Bool] false'].include?(boolean), 'entitlement dictionary scalar')
        Check.that(!values.key?(match[1]), 'duplicate entitlement')
        values[match[1]] = boolean == '[Bool] true'
      end
      values
    end
    def self.entitlement_xml(text, budget)
      budget.check
      text = text.b
      beginning = text.index('<?xml') || text.index('<plist')
      return nil unless beginning
      xml = text.byteslice(beginning, text.bytesize - beginning).force_encoding(Encoding::UTF_8)
      xml = xml.sub(/\A<\?xml version="1\.0" encoding="UTF-8"\?>[ \t\r\n]*/, '')
      xml = xml.sub(/\A<!DOCTYPE plist PUBLIC "-\/\/Apple\/\/DTD PLIST 1\.0\/\/EN" "http:\/\/www\.apple\.com\/DTDs\/PropertyList-1\.0\.dtd">[ \t\r\n]*/, '')
      match = /\A<plist version="1\.0">[ \t\r\n]*<dict>([\s\S]*)<\/dict>[ \t\r\n]*<\/plist>[ \t\r\n]*\z/.match(xml)
      empty = /\A<plist version="1\.0">[ \t\r\n]*<dict\/>[ \t\r\n]*<\/plist>[ \t\r\n]*\z/.match(xml)
      return {} if empty
      Check.that(match, 'entitlement XML envelope')
      body, values = match[1], {}
      until body.empty?
        budget.check
        body = body.sub(/\A[ \t\r\n]+/, '')
        break if body.empty?
        entry = /\A<key>([A-Za-z0-9.-]+)<\/key>[ \t\r\n]*<(true|false)\/>/.match(body)
        Check.that(entry && !values.key?(entry[1]), 'entitlement XML entry/duplicate')
        values[entry[1]] = entry[2] == 'true'
        body = body.byteslice(entry[0].bytesize, body.bytesize - entry[0].bytesize)
      end
      values
    end
    def self.claim(probes, configuration, application, budget)
      expected = argv(configuration, application)
      Check.that(probes.length == 6, 'product six probes')
      streams = probes.each_with_index.map { |probe, index| budget.check; ProbeBytes.command(probe, expected[index], '/private/var/empty', budget) }
      code, executable = paths(configuration, application)
      [0, 1, 4, 5].each { |index| budget.check; Check.that(streams[index][1].empty?, 'product probe unexpected stderr') }
      sha = /\A([0-9a-f]{64})  (.+)\n\z/.match(streams[0][0])
      Check.that(sha && sha[2] == executable, 'product SHA256 output')
      uuid = /\AUUID: ([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}) \(arm64\) (.+)\n\z/.match(streams[1][0])
      Check.that(uuid && uuid[2] == executable, 'product UUID/architecture output')
      Check.that(streams[2][0].empty? && ["".b, code + ": valid on disk\n" + code + ": satisfies its Designated Requirement\n"].include?(streams[2][1]), 'strict codesign verification output')
      metadata = ProbeBytes.lines(streams[3][1], budget)
      stdout_lines = ProbeBytes.lines(streams[3][0], budget)
      Check.that(ProbeBytes.field(metadata, 'Executable', budget) == executable, 'codesign executable path')
      identifier = application ? 'com.ergentics.provenance' : 'com.ergentics.provenance.h3-qualification-controller'
      Check.that(ProbeBytes.field(metadata, 'Identifier', budget) == identifier && ProbeBytes.field(metadata, 'TeamIdentifier', budget) == 'ZCQ435U8JP', 'product signing identity/team')
      cdhash = ProbeBytes.field(metadata, 'CDHash', budget)
      Check.that(/\A(?:[0-9a-f]{40}|[0-9a-f]{64})\z/.match?(cdhash), 'product CDHash shape')
      directories = metadata.select { |line| line.start_with?('CodeDirectory ') }
      Check.that(directories.length == 1 && /\ACodeDirectory v=[0-9]+ size=[0-9]+ flags=0x10000\(runtime\) hashes=[0-9]+\+[0-9]+ location=embedded\z/.match?(directories[0]), 'product hardened-runtime signing flags')
      authorities = metadata.select { |line| line.start_with?('Authority=') }.map { |line| line.byteslice(10, line.bytesize) }
      Check.that(authorities.length == 3 && authorities[0].start_with?('Apple Development: ') && authorities[1] == 'Apple Worldwide Developer Relations Certification Authority' && authorities[2] == 'Apple Root CA', 'product Apple Development certificate chain')
      requirements = (stdout_lines + metadata).select { |line| line.start_with?('designated => ') }
      Check.that(requirements.length == 1, 'product designated requirement count')
      requirement = requirements[0].byteslice(14, requirements[0].bytesize)
      validate_requirement(requirement, identifier, budget, authority: authorities[0])
      # The claim retains the actual emitted requirement. The frozen admission
      # requirement remains a separately evaluated Security policy at runtime.
      entitlement_encodings = []
      [stdout_lines, metadata].each do |stream_lines|
        budget.check
        entitlement_lines = stream_lines.reject { |line| line.start_with?('designated => ') }
        text_entitlements = entitlement_text(entitlement_lines, budget)
        xml_entitlements = entitlement_xml(entitlement_lines.join("\n") + "\n", budget)
        entitlement_encodings << text_entitlements unless text_entitlements.nil?
        entitlement_encodings << xml_entitlements unless xml_entitlements.nil?
      end
      Check.that(entitlement_encodings.length <= 1, 'multiple entitlement encodings')
      entitlements = entitlement_encodings[0]
      if application
        Check.that(entitlements == ENTITLEMENTS, 'application exact entitlements')
      else
        Check.that(entitlements.nil? || entitlements == {}, 'controller nonempty entitlements')
        entitlements = nil
      end
      loads = ProbeBytes.lines(streams[4][0], budget)
      Check.that(loads.shift == executable + ':', 'load-command executable header')
      loads.each { |line| budget.check; Check.that(/\A\t[^\t\r\n]+ \(compatibility version [0-9]+(?:\.[0-9]+){0,2}, current version [0-9]+(?:\.[0-9]+){0,2}(?:, weak)?\)\z/.match?(line), 'load-command line framing') }
      symbols = ProbeBytes.lines(streams[5][0], budget)
      symbols.each { |line| budget.check; Check.that(/\A[A-Za-z_$][A-Za-z0-9_.$]*\z/.match?(line), 'undefined symbol framing') }
      unless application
        Check.that(loads.none? { |line| line.include?('Hypervisor.framework') || line.include?('/Hypervisor ') }, 'controller Hypervisor linkage')
        Check.that(symbols.none? { |line| /\A_?hv_/.match?(line) }, 'controller Hypervisor symbol')
      end
      { 'cdhash' => cdhash, 'code_object_path' => code, 'designated_requirement' => requirement,
        'entitlements' => entitlements, 'entitlements_sha256' => Digest::SHA256.hexdigest(Canonical.encode(entitlements, budget)),
        'executable_path' => executable, 'executable_sha256' => sha[1], 'identifier' => identifier,
        'macho_uuid' => uuid[1].downcase, 'runtime' => true, 'team_identifier' => 'ZCQ435U8JP', 'valid' => true }
    end
    def self.validate(probes, configuration, budget = Budget.new)
      Check.that(probes.instance_of?(Array) && probes.length == 12, 'product twelve probes')
      application = claim(probes[0, 6], configuration, true, budget)
      controller = claim(probes[6, 6], configuration, false, budget)
      { 'application' => application, 'configuration' => configuration, 'controller' => controller,
        'controller_hypervisor_load_commands' => 0, 'controller_hypervisor_symbols' => 0,
        'probes' => probes, 'schema' => 'com.ergentics.provenance.h3-qualification-product-audit.v1', 'version' => 1 }
    end
  end

  # Byte-only independent admission of a closed application run. No filesystem,
  # clock, process, Security, native pointer or executable owner is constructed.
  module RunEvidence
    module_function
    ABSENT = -2_147_483_648
    U64 = 18_446_744_073_709_551_615
    EMPTY_SHA = Digest::SHA256.hexdigest('').freeze
    ZERO_SHA = ('0' * 64).freeze
    ENTITLEMENTS = { 'com.apple.security.app-sandbox' => true,
                     'com.apple.security.files.user-selected.read-only' => true,
                     'com.apple.security.hypervisor' => true }.freeze
    NATIVE_LITERALS = %w[abi cancellation chronology conservation counts cursor execution outcome phase_source phase_target quarantine signing status teardown watchdog].map { |s| 'native.' + s }.freeze
    SWIFT_LITERALS = %w[checkpoint_diagnostic checkpoint_merkle cursor_reconstruction fixed_image fixed_replies live_graph live_projection live_receipt readiness_contract sctlr_transition terminal_merkle].map { |s| 'swift.' + s }.freeze
    # Frozen descriptors are data, not a runtime policy-file dependency.
    SCHEMAS = JSON.parse('{"inner_report_v1":{"authority":"inner_authority","build":"inner_build","cancellation_monitor":"inner_cancellation_monitor","effects":"inner_effects","gate":"inner_gate","native":"one_of(inner_native_not_entered,inner_native_returned)","process":"inner_process","run":"run_identity","schema":"const(com.ergentics.provenance.h3-qualification-inner.v1)","signing":"one_of(inner_signing_admitted,inner_signing_rejected)","timing":"inner_timing","verifier":"one_of(inner_verifier_not_entered,inner_verifier_result)","version":"const(1)"},"inner_authority":{"authority_effect":"const(NONE)","authority_vector":"const(00000000)","gate_e":"const(ABSTAIN)","h4_entered":"const(false)","prime_git_entered":"const(false)","sqlite_opened":"const(false)"},"inner_build":{"configuration":"enum(DEBUG,RELEASE)","guest_abi_version":"const(5)","guest_image_byte_count":"const(136)","guest_image_sha256":"const(3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0)","guest_profile_id":"const(H3_CURSOR_RESUME)","qualification_variant":"const(true)"},"inner_effects":{"app_launched":"const(true)","guest_entered_count":"count2","helper_processes":"const(0)","hv_vm_created_count":"count2","lifecycle_disposition":"enum(NOT_ENTERED,RECOVERY_VOLATILE,QUARANTINED)","prime_git_entries":"const(0)","reservation_entries":"JSON integer 0...1 counting successful epr_guest_reserve acquisitions, not failed attempts","reservation_release_entries":"JSON integer 0...1 counting explicit report-path epr_guest_reservation_release calls","reservation_release_status":"i32; const(-2147483648) when reservation_release_entries=0, otherwise the actual native return","runner_location":"const(EVALUATED_MAC_EXTERNAL_CONTROLLER)","signals_observed_before_report":"const(0)","signing_state":"enum(ADMITTED,REJECTED,API_ERROR)","storage_entries":"const(0)","subject_location":"const(EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION)"},"inner_gate":{"accepted":"const(true)","frame_sha256":"hex64","mode_byte":"enum(01,02)","validated_tick":"tick"},"inner_cancellation_monitor":{"bytes_observed":"const(0)","disposition":"const(COMPLETION_FIRST)","fd_closed":"const(true)","poll_calls":"u32 in 0...1065","read_calls":"u32 in 0...1129; any call must have produced neither a positive byte, EOF, nor non-EINTR error before completion won","route_calls":"const(0)","started_tick":"tick","task_joined":"const(true)","terminal_tick":"tick and >= started_tick"},"inner_process":{"bundle_identifier":"const(com.ergentics.provenance)","environment_count":"const(5)","environment_names":"exact array [APP_SANDBOX_CONTAINER_ID,CFFIXED_USER_HOME,HOME,TMPDIR,__CF_USER_TEXT_ENCODING] in raw UTF-8 sorted order with no values retained","environment_observation":"const(OBSERVED_AFTER_FRAMEWORK_START_FROM_EMPTY_ENVP_ORIGIN_UNATTRIBUTED)","pid":"JSON integer in 1...2147483647","team_identifier":"const(ZCQ435U8JP)"},"run_identity":{"configuration":"enum(DEBUG,RELEASE)","mode":"enum(ADMISSION_ONLY,GUEST)","nonce":"hex64","run_id":"hex64"},"inner_signing_admitted":{"admitted":"const(true)","effective_entitlements":"effective_entitlements","effective_entitlements_sha256":"const(f754d498901c39fbbc8f6a5cfb35cf5661174a201d24c6c37a22a3f50708336b) over the canonical effective_entitlements object bytes","error":"const(0)","native_result":"const(1)","status":"const(ADMITTED)"},"inner_signing_rejected":{"admitted":"const(false)","error":"i32","native_result":"enum(-1,0)","status":"enum(REJECTED,API_ERROR)"},"effective_entitlements":{"com.apple.security.app-sandbox":"const(true)","com.apple.security.files.user-selected.read-only":"const(true)","com.apple.security.hypervisor":"const(true)"},"inner_timing":{"continuous_end_tick":"tick and >= continuous_start_tick","continuous_start_tick":"tick","timebase_denominator":"u32 and >0","timebase_numerator":"u32 and >0"},"inner_native_not_entered":{"disposition":"const(NOT_ENTERED)","preparation_error":"i32","reason":"enum(ADMISSION_MODE,SIGNING_REJECTED,PREPARATION_REJECTED,CANCELED_BEFORE_ENTRY)"},"inner_native_returned":{"checkpoint":"native_checkpoint","checkpoint_merkle_hex":"hex64","checkpoint_reply_hex":"hex64","cursor_evidence_hex":"hex1360 copied byte-for-byte from all 680 returned EPRGuestH3CursorEvidence storage bytes regardless of byte_count","cursor_evidence_sha256":"lowercase SHA-256 of the exact 680 bytes decoded from cursor_evidence_hex","cursor_sha256":"hex64","disposition":"const(RETURNED)","final_reply_hex":"hex64","outer":"native_outer","sctlr_transition":"native_sctlr_transition","source":"native_phase","target":"native_phase","terminal_merkle_hex":"hex64"},"native_outer":{"abi_version":"const(5)","cancellation_calls":"bit","cancellation_requested":"bit","checkpoint_valid":"bit","cursor_decoded":"bit","cursor_restored":"bit","cursor_sealed":"bit","execution_pass":"bit","resources_quarantined":"bit","signing_admitted":"bit","source_conserved":"bit","target_conserved":"bit","teardown_pass":"bit","terminal_valid":"bit","watchdog_fired":"bit","cursor_evidence_byte_count":"enum(0,680)","outcome":"enum(1,2,3,4,5)","timebase_denom":"u32","timebase_numer":"u32","watchdog_create_entries":"JSON integer 0...2","watchdog_join_entries":"JSON integer 0...2","cancellation_status":"i32","failure_stage":"i32","first_error":"i32","signing_error":"i32","watchdog_create_status":"enum(-2147483648,0...2147483647)","watchdog_join_status":"enum(-2147483648,0...2147483647)","watchdog_wait_status":"enum(-2147483648,0...2147483647)","end_ticks":"u64dec","start_ticks":"u64dec"},"native_phase":{"conserved":"bit","mappings_entered":"JSON integer 0...3","register_read_calls":"JSON integer 0...38 with role-specific tighter source maximum 36","register_set_calls":"JSON integer 0...36","run_entries":"JSON integer 0...1","read_register_status":"i32","register_status":"i32","run_status":"i32","vcpu_create_status":"i32","vcpu_destroy_status":"i32","vm_create_status":"i32","vm_destroy_status":"i32","host_unmap_statuses":"array(i32,exactly3)","map_statuses":"array(i32,exactly3)","unmap_statuses":"array(i32,exactly3)","entry_ticks":"u64dec","exception_reason":"u64dec","exit_ticks":"u64dec","fault_ipa":"u64dec","fault_virtual_address":"u64dec","generation":"u64dec","pc":"u64dec","syndrome":"u64dec","x4":"u64dec"},"native_checkpoint":{"schema_version":"const(1)","required_mask":"const(511)","evaluated_mask":"enum(0,511)","passed_mask":"JSON integer 0...511","gpr_mismatch_mask":"JSON integer 0...2147483647","reserved_zero":"const(0)","checkpoint_sequence":"u64dec","cpsr":"u64dec","sctlr":"u64dec","sp":"u64dec","vbar":"u64dec","gprs":"array(u64dec,exactly31)","pages":"array(native_checkpoint_page,exactly3 ordered code,request,reply)"},"native_checkpoint_page":{"expected_byte":"JSON integer 0...255","first_mismatch_offset":"JSON integer 0...16383 or const(4294967295)","observed_byte":"JSON integer 0...255","reserved_zero":"const(0)","role":"enum(code,request,reply)"},"native_sctlr_transition":{"reserved_zero_0":"const(0)","reserved_zero_1":"const(0)","sampled_mask":"enum(0,1,3,7)","schema_version":"enum(0,1)","source_post_exit_read_entries":"enum(0,1)","source_pre_entry_read_entries":"enum(0,1)","source_post_exit_read_status":"i32","source_pre_entry_read_status":"i32","requested":"u64dec","source_post_exit":"u64dec","source_pre_entry":"u64dec"},"inner_verifier_not_entered":{"disposition":"const(NOT_ENTERED)"},"inner_verifier_result":{"checkpoint_failures":"verifier_diagnostic_list","checkpoint_integrity":"enum(VALID_NOT_EVALUATED,VALID_PASS,VALID_FAILURE,MALFORMED)","checkpoint_root":"empty string or hex64","detail_sha256":"lowercase SHA-256 of the exact unnormalized UTF-8 bytes of deterministic pure replay\'s protocol-owned H3QualificationPresentation.detail, which the app-only presentation join requires to equal GuestH3Presentation.detail, with no NUL, newline, Unicode normalization, locale interpolation, or alternate spelling","disposition":"enum(PRE_NATIVE_REJECTION,CANCELED_BEFORE_NATIVE_ENTRY,VERIFIED_PASS,NATIVE_NONPASS,NATIVE_WITNESS_MALFORMED,SWIFT_RECONSTRUCTION_REJECTION)","durable":"const(false)","graph_root":"empty string or hex64","h4_entered":"const(false)","pre_entry_xor_post_exit":"null or u64dec","projection_root":"empty string or hex64","quarantined":"boolean","readiness_receipt_root":"empty string or hex64","requested_xor_pre_entry":"null or u64dec","sctlr_transition_failures":"verifier_diagnostic_list","sctlr_transition_integrity":"enum(VALID_NOT_SAMPLED,VALID_FULL,VALID_PARTIAL,MALFORMED)","status":"enum(PASS,FAIL,CANCELED,BUSY,QUARANTINED,INCOMPLETE)","terminal_root":"empty string or hex64","verifier_error_sha256":"lowercase SHA-256 of the exact unnormalized UTF-8 verifier-error bytes in protocol-owned H3QualificationPresentation\'s optional presentation diagnostic, required equal to the app-only GuestH3NativeDiagnostic.verifierError by the presentation join; SHA256(empty)=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 when that presentation diagnostic is nil, including PASS and every native-NOT_ENTERED presentation. The separate mandatory H3QualificationNativeCapture remains complete on PASS and is not this optional presentation diagnostic"},"outer_receipt_v1":{"application":"one_of(outer_application_not_launched,outer_application_identity)","child":"one_of(child_not_created,child_reaped)","classification":"outer_classification","controller_claim":"controller_identity_claim","deadlines":"outer_deadlines","evidence":"outer_evidence","gate":"outer_gate_cancel","host":"outer_host","kill":"outer_kill","run":"run_identity","schema":"const(com.ergentics.provenance.h3-qualification-outer-receipt.v1)","spawn":"outer_spawn","stderr":"outer_stderr","taxonomy":"outer_taxonomy","version":"const(1)"},"outer_host":{"architecture":"const(arm64)","macos_build":"text256","macos_version":"text256"},"file_identity":{"device":"u64dec","generation":"u32","inode":"u64dec","link_count":"u64dec","mode":"u32","owner":"u32"},"code_identity_claim":{"cdhash":"cdhash","code_object_path":"canonical absolute UTF-8 SecCodeCopyPath result <=4096 bytes; exact application bundle root for bundled application code, exact executable path for the unbundled controller","designated_requirement":"text256","entitlements":"effective_entitlements for the application; JSON null for the controller only after the raw signing observation has no entitlement blob or decodes to an exact empty dictionary, with any nonempty controller entitlement rejected","entitlements_sha256":"hex64 over exact canonical entitlements JSON bytes; the controller null representation is the four ASCII bytes null and therefore hashes to 74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","executable_path":"canonical absolute UTF-8 path <=4096 bytes naming the exact held Mach-O executable and equal proc_pidpath for a launched application","executable_sha256":"hex64","identifier":"text256","macho_uuid":"uuid","runtime":"boolean","team_identifier":"text256","valid":"boolean"},"controller_identity_claim":{"code":"code_identity_claim with identifier com.ergentics.provenance.h3-qualification-controller and entitlements null","held_at_start":"file_identity from the read-only no-follow descriptor opened on the controller executable at startup","named_at_start":"file_identity from the canonical controller executable path at startup","pid":"positive JSON integer from getpid(), retained only for exact outer-supervisor correlation and not as authority"},"outer_application_identity":{"dynamic":"code_identity_claim","held_after_reap":"file_identity observed from the retained read-only descriptor after exact child reap","held_before_gate":"file_identity","held_before_spawn":"file_identity","named_after_reap":"file_identity independently reopened without following symlinks from the canonical executable path after exact child reap","named_before_gate":"file_identity","named_before_spawn":"file_identity","post_static":"code_identity_claim from strict static validation after exact reap","pre_static":"code_identity_claim","proc_pidpath":"canonical absolute UTF-8 path <=4096 bytes"},"outer_application_not_launched":{"held_before_spawn":"file_identity","held_terminal":"file_identity","named_before_spawn":"file_identity","named_terminal":"file_identity","pre_static":"code_identity_claim"},"child_not_created":{"disposition":"const(NOT_CREATED)","exit":"const(NOT_APPLICABLE)","pid":"const(0)","reap":"const(NOT_APPLICABLE)","signal":"const(NOT_APPLICABLE)","wait_status":"const(NOT_APPLICABLE)"},"child_reaped":{"disposition":"const(REAPED)","exit":"i32 or NOT_APPLICABLE when signaled","pid":"JSON integer in 1...2147483647","reap":"const(EXACT_PID_REAPED)","signal":"i32 or NOT_APPLICABLE when normally exited","wait_status":"i32"},"outer_classification":{"failed_predicates":"an exact duplicate-free raw UTF-8-sorted subset of classification_predicate_vocabulary.all_literals_in_raw_utf8_order, byte-equal to the pure recomputation required by classification_predicate_vocabulary.derivation_rule; diagnostic status/failure strings are never classification literals","result":"enum(NO_CHILD_FAILURE,RETAINED_NONPASS,RUN_CANDIDATE_PASS)"},"outer_deadlines":{"cancel_tick":"u64dec; 0 iff no cancellation attempt","gate_attempt_tick":"u64dec; exactly 0 iff no gate-write attempt, otherwise sampled immediately before that sole write","gate_deadline_tick":"tick","gate_return_tick":"u64dec; exactly 0 iff no gate-write attempt, otherwise sampled immediately after that sole write returns","kill_attempt_tick":"u64dec; 0 iff no kill attempt","kill_deadline_tick":"tick","operation_deadline_tick":"tick","reap_tick":"u64dec; exactly 0 for NOT_CREATED and a positive tick for REAPED","spawn_tick":"tick sampled immediately before the sole posix_spawn call, including a failed call","terminal_horizon_tick":"tick","terminal_tick":"tick sampled only after exact reap or NOT_CREATED disposition, required pipe EOFs, stdout readback, and all held/named/evidence-root terminal revalidations finish","timebase_denominator":"u32 and >0","timebase_numerator":"u32 and >0"},"outer_evidence":{"build_source_manifest_sha256":"hex64 from the controller\'s bounded held-root-relative run prelaunch read, later required to equal the campaign artifact_reference","effective_entitlements_sha256":"the exact admitted canonical entitlement hash, or const(0000000000000000000000000000000000000000000000000000000000000000) when inner signing is REJECTED/API_ERROR or the inner frame is absent","effective_hypervisor_value":"TRUE only for admitted inner signing; const(NOT_OBSERVED) for REJECTED/API_ERROR signing or an absent inner frame","hypervisor_support":"enum(NOT_QUERIED,NATIVE_ENTRY_SUCCEEDED,NATIVE_ENTRY_FAILED,NOT_ENTERED), never caller-selected: NOT_ENTERED for NOT_CREATED, absent/invalid inner frame, or valid GUEST native NOT_ENTERED; NOT_QUERIED for every valid ADMISSION_ONLY inner frame; for valid GUEST native RETURNED, NATIVE_ENTRY_SUCCEEDED iff at least one source/target vm_create_status is exactly HV_SUCCESS numeric zero, NATIVE_ENTRY_FAILED iff neither is zero and at least one is non-sentinel, otherwise NOT_ENTERED when both are INT32_MIN. Source-prefix validation separately rejects role-order-impossible combinations.","inner_byte_count":"JSON integer 0...65552","inner_eof":"boolean","inner_sha256":"hex64; SHA256(empty) if absent","inner_valid":"boolean","product_audit_sha256":"hex64 from the controller\'s bounded held-root-relative same-configuration product-audit read, later required to equal the campaign artifact_reference","root_identity":"file_identity","stdout_identity_terminal":"file_identity after failed posix_spawn or after exact child reap"},"outer_gate_cancel":{"cancel_errno":"i32","cancel_frame_sha256":"hex64 of expected frozen cancellation frame","cancel_return":"i32","cancel_writes":"JSON integer 0...1","gate_errno":"i32","gate_frame_sha256":"hex64 of expected frozen gate frame","gate_return":"i32","gate_writes":"JSON integer 0...1"},"outer_spawn":{"argv":"exact two-element application argv excluding argv0","attributes":"const(CLOEXEC_DEFAULT_EMPTY_MASK_DEFAULT_CATCHABLE_SIGNALS)","cwd":"const(/private/var/empty)","environment_count":"const(0)","fd_map":"const(0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro)","spawn_return":"the i32 returned directly by posix_spawn, never ambient errno; const(0) iff child.disposition=REAPED, or JSON integer 1...2147483647 iff child.disposition=NOT_CREATED"},"outer_kill":{"attempted":"boolean","errno":"i32","pid":"JSON integer 0...2147483647","return":"i32"},"outer_stderr":{"eof":"boolean","overflow":"boolean","retained_byte_count":"JSON integer 0...65536","retained_sha256":"hex64","total_byte_count":"JSON integer 0...1048576"},"outer_taxonomy":{"app_launched":"boolean","authority_effect":"const(NONE)","guest_entered_count":"count2","helper_processes":"const(0); the controller is the runner and the application is the subject, not a helper","hv_vm_created_count":"count2","runner_location":"const(EVALUATED_MAC_EXTERNAL_CONTROLLER)","signals":"JSON integer 0...1 and equal successful-or-attempted SIGKILL call count","signing_state":"enum(NOT_ENTERED,ADMITTED,REJECTED,API_ERROR)","sqlite_opened":"const(false)","subject_location":"const(EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION)"}}').freeze

    def reject_unless(condition, label)
      Check.that(condition, 'run evidence: ' + label)
    end
    def integer(value, low, high, label)
      reject_unless(value.instance_of?(Integer) && value.between?(low, high), label)
      value
    end
    def text(value, bound, label)
      reject_unless(value.instance_of?(String) && value.bytesize <= bound &&
                    value.valid_encoding? && !/[\x00-\x1f\x7f]/.match?(value), label)
      value
    end
    def hex(value, count, label)
      reject_unless(value.instance_of?(String) && value.bytesize == count && /\A[0-9a-f]*\z/.match?(value), label)
      value
    end
    def word(value)
      reject_unless(value.instance_of?(String) && /\A(?:0|[1-9][0-9]{0,19})\z/.match?(value), 'canonical unsigned decimal')
      Check.u64(value.to_i)
    end
    def words(object, budget)
      object.each_with_object({}) { |(key, value), result| budget.check; result[key] = value.instance_of?(String) && /\A[0-9]+\z/.match?(value) ? value.to_i : value }
    end
    def structure(value, name, budget)
      budget.check
      fields = SCHEMAS.fetch(name)
      reject_unless(value.instance_of?(Hash) && value.keys.sort_by(&:b) == fields.keys.sort_by(&:b), name + ' exact keys')
      fields.each { |key, descriptor| budget.check; field(value[key], descriptor, name + '.' + key, budget) }
      value
    end
    def field(value, descriptor, context, budget)
      budget.check
      case context
      when 'outer_spawn.fd_map'
        return reject_unless(value == '0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro', context)
      when 'outer_spawn.argv'
        reject_unless(value.instance_of?(Array) && value.length == 2, context)
        value.each { |v| budget.check; text(v, 4096, context) }
        return
      when 'outer_classification.failed_predicates'
        reject_unless(value.instance_of?(Array) && value.length <= 44 &&
                      value.all? { |item| budget.check; item.instance_of?(String) } &&
                      value.uniq == value && value.sort_by(&:b) == value, context)
        allowed = NATIVE_LITERALS + SWIFT_LITERALS + %w[application.h3_preparation application.live_self_signing_admission runner.application_identity runner.authority_boundary runner.build_identity runner.cancellation runner.deadline runner.environment runner.exit runner.export runner.gate runner.inner_frame runner.monitor runner.run_identity runner.signal runner.spawn runner.stderr runner.timing]
        return reject_unless((value - allowed).empty?, context)
      when 'outer_evidence.effective_hypervisor_value'
        return reject_unless(%w[TRUE NOT_OBSERVED].include?(value), context)
      end
      if descriptor == 'null or u64dec'
        word(value) unless value.nil?
      elsif descriptor == 'empty string or hex64'
        hex(value, 64, context) unless value == ''
      elsif descriptor.start_with?('effective_entitlements for the application')
        structure(value, 'effective_entitlements', budget) unless value.nil?
      elsif descriptor.start_with?('const(')
        literal = descriptor[/\Aconst\(([^)]*)\)/, 1]
        expected = case literal
                   when 'true' then true
                   when 'false' then false
                   when 'null' then nil
                   when '[]' then []
                   else /\A(?:0|-?[1-9][0-9]*)\z/.match?(literal) ? literal.to_i : literal
                   end
        reject_unless(value.class == expected.class && value == expected, context)
      elsif descriptor.start_with?('enum(')
        choices = descriptor[/\Aenum\(([^)]*)\)/, 1].split(',')
        allowed = choices.any? do |choice|
          budget.check
          if (range = /\A(-?[0-9]+)\.\.\.(-?[0-9]+)\z/.match(choice))
            value.instance_of?(Integer) && value.between?(range[1].to_i, range[2].to_i)
          elsif /\A(?:0|-?[1-9][0-9]*)\z/.match?(choice)
            value.instance_of?(Integer) && value == choice.to_i
          else
            value == choice
          end
        end
        reject_unless(allowed, context)
      elsif descriptor.start_with?('one_of(')
        choices = descriptor[/\Aone_of\(([^)]*)\)/, 1].split(',')
        matches = choices.count do |name|
          budget.check
          begin
            structure(value, name, budget); true
          rescue Cancelled
            raise
          rescue Rejected
            false
          end
        end
        reject_unless(matches == 1, context)
      elsif descriptor.start_with?('array(')
        match = /\Aarray\(([^,]+),exactly([0-9]+)/.match(descriptor)
        reject_unless(match && value.instance_of?(Array) && value.length == match[2].to_i, context)
        value.each { |item| budget.check; field(item, match[1], context, budget) }
        reject_unless(value.map { |x| budget.check; x['role'] } == %w[code request reply], context) if match[1] == 'native_checkpoint_page'
      elsif descriptor.start_with?('JSON integer')
        match = /([0-9]+)\.\.\.([0-9]+)/.match(descriptor)
        if descriptor.include?('or const(4294967295)') && value == 4_294_967_295
          return
        end
        reject_unless(!match.nil?, context + ' descriptor')
        integer(value, match[1].to_i, match[2].to_i, context)
      elsif descriptor.start_with?('u32')
        integer(value, descriptor.include?('>0') ? 1 : 0, 4_294_967_295, context)
        match = /0\.\.\.([0-9]+)/.match(descriptor)
        integer(value, 0, match[1].to_i, context) if match
      elsif descriptor.start_with?('i32')
        integer(value, ABSENT, 2_147_483_647, context) unless descriptor.include?('NOT_APPLICABLE') && value == 'NOT_APPLICABLE'
      elsif descriptor.start_with?('u64dec', 'tick')
        n = word(value)
        reject_unless(n > 0, context) if descriptor.start_with?('tick')
      elsif descriptor.start_with?('hex')
        hex(value, descriptor[/\Ahex([0-9]+)/, 1].to_i, context)
      elsif descriptor.start_with?('lowercase SHA-256', 'the exact admitted canonical entitlement hash')
        hex(value, 64, context)
      elsif descriptor == 'bit' || descriptor == 'count2'
        integer(value, 0, descriptor == 'bit' ? 1 : 2, context)
      elsif descriptor == 'boolean'
        reject_unless(value == true || value == false, context)
      elsif descriptor == 'text256'
        text(value, 256, context)
      elsif descriptor == 'cdhash'
        reject_unless(value.instance_of?(String) && [40, 64].include?(value.bytesize), context)
        hex(value, value.bytesize, context)
      elsif descriptor == 'uuid'
        reject_unless(value.instance_of?(String) && /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.match?(value), context)
      elsif descriptor == 'verifier_diagnostic_list'
        reject_unless(value.instance_of?(Array) && value.length <= 64, context)
        value.each { |item| budget.check; text(item, 256, context) }
      elsif descriptor.start_with?('exact array [APP_SANDBOX')
        reject_unless(value == %w[APP_SANDBOX_CONTAINER_ID CFFIXED_USER_HOME HOME TMPDIR __CF_USER_TEXT_ENCODING], context)
      elsif SCHEMAS.key?(descriptor.split(/[ ;]/).first)
        structure(value, descriptor.split(/[ ;]/).first, budget)
      elsif descriptor.include?('absolute')
        text(value, 4096, context)
        reject_unless(value.start_with?('/') && value != '/' && !value.include?('\\') &&
                      value[1..-1].split('/', -1).none? { |part| budget.check; part.empty? || part == '.' || part == '..' }, context)
      elsif descriptor.start_with?('positive JSON integer', 'same positive JSON integer', 'the i32 returned directly')
        integer(value, descriptor.start_with?('the i32') ? 0 : 1, 2_147_483_647, context)
      else
        raise Rejected, 'run evidence: unimplemented frozen descriptor ' + context
      end
    end

    def ordered(values, label, budget)
      reject_unless(values.each_cons(2).all? { |left, right| budget.check; left <= right }, label)
    end
    def digest(bytes)
      Digest::SHA256.hexdigest(bytes)
    end
    def identity(value, executable:, budget:)
      structure(value, 'file_identity', budget)
      reject_unless(value['owner'] == 501 && value['link_count'] == '1' && word(value['inode']) > 0 &&
                    value['mode'] & 0o022 == 0 && (!executable || value['mode'] & 0o111 != 0), 'file identity')
    end
    def code(value, configuration, application, budget)
      structure(value, 'code_identity_claim', budget)
      expected_paths = ProductProbes.paths(configuration, application)
      reject_unless([value['code_object_path'], value['executable_path']] == expected_paths, 'code/executable paths')
      reject_unless(value['identifier'] == (application ? 'com.ergentics.provenance' : 'com.ergentics.provenance.h3-qualification-controller') &&
                    value['team_identifier'] == 'ZCQ435U8JP' && value['runtime'] == true && value['valid'] == true &&
                    !value['designated_requirement'].empty?, 'code signing identity')
      expected = application ? ENTITLEMENTS : nil
      reject_unless(value['entitlements'] == expected && value['entitlements_sha256'] == digest(Canonical.encode(expected, budget)), 'static entitlements')
    end
    def deadline(start, seconds, numer, denom)
      product = Check.u64(Check.u64(seconds * 1_000_000_000) * denom)
      Check.u64(start + product / numer + (product % numer == 0 ? 0 : 1))
    end
    def frame(bytes, budget)
      budget.check
      reject_unless(bytes.instance_of?(String) && bytes.bytesize.between?(17, 65_552) &&
                    bytes.byteslice(0, 8) == 'EPRH3I01' && /\A[0-9a-f]{8}\z/.match?(bytes.byteslice(8, 8)), 'inner frame header')
      length = bytes.byteslice(8, 8).to_i(16)
      reject_unless(length.between?(1, 65_536) && bytes.bytesize == length + 16, 'inner exact frame length')
      JSONPreflight.new(bytes.byteslice(16, length), budget, maximum: 65_536).decode(canonical: true)
    end

    def phase_prefix(phase, source, budget)
      budget.check
      p = words(phase, budget)
      maps, unmaps, host = p.values_at('map_statuses', 'unmap_statuses', 'host_unmap_statuses')
      setters, reads, runs, mappings = p.values_at('register_set_calls', 'register_read_calls', 'run_entries', 'mappings_entered')
      reject_unless(reads <= (source ? 36 : 38) &&
                    (setters == 0) == (p['register_status'] == ABSENT) &&
                    (reads == 0) == (p['read_register_status'] == ABSENT) &&
                    (runs == 0) == (p['run_status'] == ABSENT), 'phase count/status sentinel')
      reject_unless(p['vm_create_status'] == 0 ? mappings >= 1 : mappings == 0, 'VM/map admission')
      maps.each_with_index do |status, index|
        budget.check
        reject_unless(index >= mappings ? status == ABSENT :
          (index + 1 < mappings ? status == 0 : status != ABSENT && (mappings == 3 || status != 0)), 'ordered mapping prefix')
      end
      eligible = mappings == 3 && maps.all? { |status| budget.check; status == 0 }
      reject_unless((p['vcpu_create_status'] != ABSENT) == eligible &&
                    (p['vcpu_create_status'] == 0 || setters == 0) &&
                    (setters == 0 || setters == 36 || p['register_status'] != 0) &&
                    (runs == 0 || setters == 36 && p['register_status'] == 0), 'ordered register setters')
      reject_unless(runs == 0 ? p['exit_ticks'] == 0 : p['entry_ticks'] > 0 && p['entry_ticks'] <= p['exit_ticks'], 'phase entry/exit ticks')
      if source
        reject_unless((p['run_status'] == 0 ? reads > 0 : reads == 0) &&
                      (reads == 0 || reads == 36 || p['read_register_status'] != 0), 'source register-read prefix')
      else
        reject_unless((reads == 0 || setters == 36 && p['register_status'] == 0) &&
                      (runs == 0 ? reads <= 36 : (p['run_status'] == 0 ? reads >= 37 : reads == 36)) &&
                      (reads != 37 || p['read_register_status'] != 0), 'target restore/terminal reads')
      end
      allocated = host.take_while { |status| budget.check; status != ABSENT }.length
      reject_unless(host.drop(allocated).all? { |status| budget.check; status == ABSENT } &&
                    host.all? { |status| budget.check; [ABSENT, -1, 0].include?(status) }, 'host allocation/unmap prefix')
      vm_attempted = p['vm_create_status'] != ABSENT
      vm_created = p['vm_create_status'] == 0
      vcpu_created = p['vcpu_create_status'] == 0
      vcpu_cleared = !vcpu_created || p['vcpu_destroy_status'] == 0
      kernel_cleared = vcpu_cleared && (!vm_created || p['vm_destroy_status'] == 0)
      reject_unless((p['vcpu_destroy_status'] != ABSENT) == vcpu_created &&
                    (p['vm_destroy_status'] != ABSENT) == (vm_created && vcpu_cleared), 'role destruction calls')
      unmaps.each_with_index do |status, index|
        budget.check
        reject_unless((status != ABSENT) == (vcpu_cleared && maps[index] == 0), 'mapped-slot destruction')
      end
      reject_unless(kernel_cleared ? !vm_attempted || allocated == 3 : allocated == 0, 'host/kernel cleanup ordering')
      attempted = vm_attempted || allocated > 0 || p['conserved'] == 1
      cleanup = if vcpu_created && p['vcpu_destroy_status'] != 0 then 14
                elsif unmaps.any? { |status| budget.check; status != ABSENT && status != 0 } then 15
                elsif vm_created && p['vm_destroy_status'] != 0 then 16
                elsif host.include?(-1) then 17
                end
      reject_unless(p['conserved'] == (attempted && kernel_cleared && cleanup.nil? ? 1 : 0), 'role conservation')
      reject_unless(attempted || setters == 0 && reads == 0 && runs == 0 && p['entry_ticks'] == 0 && p['exit_ticks'] == 0, 'untouched role')
      if runs != 1 || p['run_status'] != 0
        reject_unless(p['exception_reason'] == U64 && p['syndrome'] == 0 && p['fault_ipa'] == 0 && p['fault_virtual_address'] == 0, 'untouched exit frame')
      elsif p['exception_reason'] != 1
        reject_unless(p['syndrome'] == 0 && p['fault_ipa'] == 0 && p['fault_virtual_address'] == 0, 'nonexception exit payload')
      end
      pc_read_count = source ? 33 : 37
      pc_success = reads >= pc_read_count && (reads > pc_read_count || p['read_register_status'] == 0)
      x4_success = reads == (source ? 36 : 38) && p['read_register_status'] == 0
      reject_unless(pc_success || p['pc'] == 0, 'untouched PC')
      reject_unless(x4_success || p['x4'] == 0, 'untouched X4')
      forward = if attempted && !vm_attempted then 3
                elsif vm_attempted && !vm_created then 4
                elsif maps.any? { |status| budget.check; status != ABSENT && status != 0 } then 5
                elsif p['vcpu_create_status'] != ABSENT && (!vcpu_created || setters == 0) then 6
                elsif setters > 0 && p['register_status'] != 0 then 7
                elsif !source && reads > 0 && reads <= 36 && p['read_register_status'] != 0 then 10
                elsif runs == 1 && p['run_status'] != 0 then 9
                elsif reads > 0 && p['read_register_status'] != 0 then 10
                end
      forward_error = case forward
                      when 4 then p['vm_create_status']
                      when 5 then maps.find { |status| budget.check; status != ABSENT && status != 0 }
                      when 6 then vcpu_created ? 14 : p['vcpu_create_status']
                      when 7 then p['register_status']
                      when 9 then p['run_status']
                      when 10 then p['read_register_status']
                      end
      cleanup_error = case cleanup
                      when 14 then p['vcpu_destroy_status']
                      when 15 then unmaps.find { |status| budget.check; status != ABSENT && status != 0 }
                      when 16 then p['vm_destroy_status']
                      end
      { attempted: attempted, cleanup: cleanup, cleanup_error: cleanup_error,
        forward: forward, forward_error: forward_error }
    end
    def trap(phase, source, budget)
      p = words(phase, budget)
      dfsc = p['syndrome'] & 63
      p['exception_reason'] == 1 && dfsc.between?(4, 7) && p['syndrome'] == (0x9384_0040 | dfsc) &&
        p['pc'] == (source ? 0x1000_0050 : 0x1000_007c) &&
        p['fault_ipa'] == 0x1000_c000 && p['fault_virtual_address'] == 0x1000_c000 && p['x4'] == (source ? 1 : 2)
    end
    def native_prefix(native, budget)
      budget.check
      v, s, t, c, d = %w[outer source target checkpoint sctlr_transition].map { |key| budget.check; words(native[key], budget) }
      count = v['cursor_evidence_byte_count']
      evidence = [native['cursor_evidence_hex']].pack('H*')
      reject_unless(digest(evidence) == native['cursor_evidence_sha256'] &&
                    (count == 680 || count == 0 && evidence == "\0" * 680), 'cursor storage count/hash')
      reject_unless(v['failure_stage'].between?(0, 23) && (v['failure_stage'] == 0) == (v['first_error'] == 0) &&
                    v['cancellation_calls'] <= v['cancellation_requested'] &&
                    (v['cancellation_calls'] == 0) == (v['cancellation_status'] == ABSENT) &&
                    (v['watchdog_fired'] == 0 || v['cancellation_requested'] == 1) &&
                    (v['signing_admitted'] == 0 || v['signing_error'] == 0), 'native outer scalar prefix')
      reject_unless(v['watchdog_join_entries'] <= v['watchdog_create_entries'] &&
                    v['cursor_sealed'] == (count == 680 ? 1 : 0) && v['cursor_sealed'] <= v['checkpoint_valid'] &&
                    v['cursor_decoded'] <= v['cursor_sealed'] && v['cursor_decoded'] <= v['source_conserved'] &&
                    v['cursor_restored'] <= v['cursor_decoded'] && v['terminal_valid'] <= v['cursor_restored'] &&
                    v['execution_pass'] <= v['terminal_valid'] &&
                    (v['resources_quarantined'] == 0 || v['teardown_pass'] == 0), 'native forward-bit prefix')
      reject_unless((v['timebase_numer'] == 0 && v['timebase_denom'] == 0 || v['timebase_numer'] > 0 && v['timebase_denom'] > 0) &&
                    (v['start_ticks'] == 0 && v['end_ticks'] == 0 || v['start_ticks'] > 0 && v['start_ticks'] <= v['end_ticks']), 'native timebase/ticks')
      reject_unless(v['cancellation_requested'] != 0 || v['execution_pass'] == v['terminal_valid'], 'terminal execution bit')
      creates, joins = v.values_at('watchdog_create_entries', 'watchdog_join_entries')
      create_status, join_status = v.values_at('watchdog_create_status', 'watchdog_join_status')
      reject_unless((creates != 0 || create_status == ABSENT && joins == 0 && join_status == ABSENT) &&
                    (joins == 0) == (join_status == ABSENT), 'watchdog untouched status')
      reject_unless(create_status == 0 ? joins == 1 : create_status > 0 && joins == 0 && join_status == ABSENT, 'first watchdog create/join') if creates == 1
      reject_unless(create_status == 0 ? joins == 2 : create_status > 0 && joins == 1 && join_status == 0, 'second watchdog create/join') if creates == 2
      reject_unless(v['resources_quarantined'] == 1 && v['teardown_pass'] == 0, 'failed watchdog join conservation') if joins > 0 && join_status != 0
      sp, tp = phase_prefix(native['source'], true, budget), phase_prefix(native['target'], false, budget)
      reject_unless(v['source_conserved'] == s['conserved'] && v['target_conserved'] == t['conserved'], 'outer role conservation')
      immediate = v['start_ticks'] == 0
      if immediate
        reject_unless(!sp[:attempted] && !tp[:attempted] && s['generation'] == 0 && t['generation'] == 0 &&
                      v['timebase_numer'] == 0 && v['signing_admitted'] == 0 && v['signing_error'] == ABSENT &&
                      v['cancellation_requested'] == 0 && creates == 0 && v['watchdog_fired'] == 0 &&
                      v['watchdog_wait_status'] == ABSENT && v['teardown_pass'] == 0, 'immediate claim prefix')
        reject_unless((v['outcome'] == 4 && v['resources_quarantined'] == 0 && v['failure_stage'] == 0) ||
                      (v['outcome'] == 5 && v['resources_quarantined'] == 1 && v['failure_stage'] == 0) ||
                      (v['outcome'] == 2 && v['resources_quarantined'] == 0 && v['failure_stage'] == 1), 'immediate claim outcome')
      else
        clean = (!sp[:attempted] || s['conserved'] == 1) && (!tp[:attempted] || t['conserved'] == 1) && (joins == 0 || join_status == 0)
        reject_unless(v['teardown_pass'] == (clean ? 1 : 0) && v['resources_quarantined'] == (clean ? 0 : 1), 'final cleanup outcome')
        pass = v['execution_pass'] == 1 && clean && s['conserved'] == 1 && t['conserved'] == 1 &&
          creates == 2 && joins == 2 && v['failure_stage'] == 0 && v['cancellation_requested'] == 0
        reject_unless(v['outcome'] == (pass ? 1 : (v['cancellation_requested'] == 1 ? 3 : 2)) &&
                      (pass || v['failure_stage'] != 0), 'final native outcome')
      end
      if s['generation'] == 0 || t['generation'] == 0
        reject_unless(s['generation'] == 0 && t['generation'] == 0 && !sp[:attempted] && !tp[:attempted] &&
                      v['signing_error'] == ABSENT && (immediate || v['failure_stage'] == 1), 'generation assignment')
      else
        reject_unless(!immediate && s['generation'].odd? && s['generation'] < U64 &&
                      t['generation'] == s['generation'] + 1, 'fresh ordered generations')
      end
      if v['signing_error'] == ABSENT
        reject_unless(v['signing_admitted'] == 0 && v['timebase_numer'] == 0 && !sp[:attempted] && !tp[:attempted] &&
                      (immediate || v['failure_stage'] == 1 || v['failure_stage'] == 18 && v['cancellation_requested'] == 1), 'signing not entered')
      else
        reject_unless(!immediate && s['generation'] > 0, 'signing chronology')
        if v['signing_admitted'] == 0
          reject_unless(v['timebase_numer'] == 0 && !sp[:attempted] && !tp[:attempted] && v['failure_stage'] == 1 &&
                        v['first_error'] == (v['signing_error'] == 0 ? 13 : v['signing_error']), 'native signing rejection')
        end
      end
      reject_unless(v['timebase_numer'] == 0 || v['signing_admitted'] == 1 && s['generation'] > 0, 'timebase follows signing')
      reject_unless(!sp[:attempted] || v['timebase_numer'] > 0 && v['signing_admitted'] == 1, 'source preparation admission')
      reject_unless(tp[:attempted] == (v['cursor_decoded'] == 1), 'target preparation after decode')
      if !immediate && v['signing_admitted'] == 1 && !sp[:attempted]
        reject_unless(v['failure_stage'] == (v['timebase_numer'] == 0 ? 2 : 3), 'preparation predecessor failure')
      end
      [s, t].each do |phase|
        budget.check
        reject_unless(v['timebase_numer'] > 0 && v['start_ticks'] <= phase['entry_ticks'] && phase['entry_ticks'] <= v['end_ticks'], 'contained native entry') if phase['entry_ticks'] > 0
        reject_unless(phase['exit_ticks'] <= v['end_ticks'], 'contained native exit') if phase['exit_ticks'] > 0
      end
      reject_unless(s['exit_ticks'] > 0 && s['exit_ticks'] <= t['entry_ticks'], 'cross-role chronology') if t['entry_ticks'] > 0
      pre_entered = s['register_set_calls'] == 36 && s['register_status'] == 0
      reject_unless((d['schema_version'] == 1) == pre_entered, 'SCTLR helper entry')
      if !pre_entered
        reject_unless(%w[sampled_mask source_pre_entry_read_entries source_post_exit_read_entries source_pre_entry_read_status source_post_exit_read_status requested source_pre_entry source_post_exit].all? { |key| budget.check; d[key] == 0 }, 'untouched SCTLR')
      else
        reject_unless(d['requested'] == 0x30d0_0980 && d['source_pre_entry_read_entries'] == 1 && d['source_pre_entry_read_status'] != ABSENT, 'SCTLR pre result')
        pre_ok = d['source_pre_entry_read_status'] == 0
        post_entered = s['register_read_calls'] > 0
        post_ok = post_entered && d['source_post_exit_read_status'] == 0
        reject_unless(d['source_post_exit_read_entries'] == (post_entered ? 1 : 0) &&
                      (post_entered ? d['source_post_exit_read_status'] != ABSENT : d['source_post_exit_read_status'] == ABSENT) &&
                      d['sampled_mask'] == (pre_ok ? (post_ok ? 7 : 3) : 1), 'SCTLR sample order')
        reject_unless(pre_ok || d['source_pre_entry'] == 0 && !post_entered && creates == 0 && s['entry_ticks'] == 0, 'failed SCTLR pre-read')
        reject_unless(post_ok || d['source_post_exit'] == 0, 'unsampled SCTLR post')
        reject_unless(s['read_register_status'] == d['source_post_exit_read_status'], 'first source read result') if s['register_read_calls'] == 1
        reject_unless(post_ok, 'reads after SCTLR failure') if s['register_read_calls'] > 1
        reject_unless(v['failure_stage'] == 7 && v['first_error'] == d['source_pre_entry_read_status'], 'SCTLR first failure') unless pre_ok
      end
      reject_unless(creates == 0 || pre_entered && d['source_pre_entry_read_status'] == 0, 'source watchdog predecessor')
      reject_unless(creates != 2 || v['cursor_restored'] == 1, 'target watchdog predecessor')
      reject_unless(creates > 0 && (creates == 2 || create_status == 0), 'source run watchdog') if s['entry_ticks'] > 0 || s['run_entries'] > 0
      reject_unless(creates == 2 && create_status == 0, 'target run watchdog') if t['entry_ticks'] > 0 || t['run_entries'] > 0
      reject_unless(joins > 0, 'watchdog observation without worker') if v['watchdog_wait_status'] != ABSENT || v['watchdog_fired'] == 1
      reject_unless(v['cancellation_requested'] == 1, 'failed wait cancels') unless [ABSENT, 0, 60].include?(v['watchdog_wait_status'])
      reject_unless(s['vcpu_create_status'] == 0 && s['register_set_calls'] > 0, 'cancellation live-vcpu dependency') if v['cancellation_calls'] == 1
      reject_unless(v['cancellation_requested'] == 0 || v['execution_pass'] == 0, 'cancellation clears execution')
      source_complete = s['run_status'] == 0 && s['register_read_calls'] == 36 && s['read_register_status'] == 0 &&
        (creates == 2 || joins == 1 && join_status == 0)
      if c['evaluated_mask'] == 511
        reject_unless(source_complete && trap(native['source'], true, budget) && d['source_post_exit_read_status'] == 0 &&
                      c['sctlr'] == d['source_post_exit'] && word(c['gprs'][4]) == s['x4'], 'checkpoint capture chronology')
      end
      if v['checkpoint_valid'] == 0
        reject_unless(%w[checkpoint_reply_hex cursor_sha256 checkpoint_merkle_hex].all? { |key| budget.check; native[key] == ZERO_SHA }, 'untouched checkpoint buffers')
      end
      if v['cursor_restored'] == 1
        reject_unless(t['register_read_calls'] >= 36 && (t['register_read_calls'] > 36 || t['read_register_status'] == 0) &&
                      t['register_set_calls'] == 36 && t['register_status'] == 0, 'restore complete prefix')
      end
      reject_unless(t['run_entries'] == 0 || v['cursor_restored'] == 1, 'target run after restoration')
      terminal_complete = t['run_status'] == 0 && t['register_read_calls'] == 38 && t['read_register_status'] == 0 && joins == 2 && join_status == 0
      reject_unless(native['final_reply_hex'] == ZERO_SHA && native['terminal_merkle_hex'] == ZERO_SHA, 'untouched terminal buffers') unless terminal_complete
      terminal_hash_eligible = terminal_complete && trap(native['target'], false, budget) && native['final_reply_hex'] == [2, 1, 42, 43].pack('Q<4').unpack1('H*')
      reject_unless(native['terminal_merkle_hex'] == ZERO_SHA, 'terminal hash before predicates') unless terminal_hash_eligible
      reject_unless(terminal_hash_eligible, 'terminal valid prefix') if v['terminal_valid'] == 1
      [sp, tp].each do |prefix|
        budget.check
        if prefix[:forward]
          reject_unless(v['failure_stage'] == prefix[:forward], 'first forward failure')
          reject_unless(v['first_error'] == prefix[:forward_error], 'first forward error') unless prefix[:forward_error].nil?
        end
      end
      stage, error = v.values_at('failure_stage', 'first_error')
      case stage
      when 1
        reject_unless(!sp[:attempted] && !tp[:attempted] && v['signing_admitted'] == 0 && v['timebase_numer'] == 0, 'admission failure prefix')
        reject_unless(s['generation'] == 0 && [22, 37, 75].include?(error), 'claim/thread/generation failure') if v['signing_error'] == ABSENT
      when 2
        reject_unless(v['terminal_valid'] == 0 && native['final_reply_hex'] == ZERO_SHA && native['terminal_merkle_hex'] == ZERO_SHA, 'clock before terminal copy')
        if v['timebase_numer'] == 0
          reject_unless(error == 22 && !sp[:attempted] && !tp[:attempted], 'timebase failure')
        else
          target_clock = v['cursor_restored'] == 1
          phase, prior_watchdogs = target_clock ? [t, 1] : [s, 0]
          reject_unless(target_clock || c['evaluated_mask'] == 0 && !tp[:attempted] && d['schema_version'] == 1 &&
                        d['source_pre_entry_read_status'] == 0, 'role clock predecessor')
          if creates == prior_watchdogs
            reject_unless(error == 75 && phase['entry_ticks'] == 0 && phase['run_entries'] == 0, 'watchdog deadline overflow')
          else
            reject_unless(creates == prior_watchdogs + 1 && create_status == 0 && phase['entry_ticks'] > 0 && error == 60 &&
                          (phase['run_entries'] == 0 || phase['run_status'] == 0 && phase['register_read_calls'] == (target_clock ? 38 : 36) &&
                           phase['read_register_status'] == 0), 'role deadline prefix')
          end
        end
      when 3
        reject_unless(error > 0 && (sp[:forward] == 3 || tp[:forward] == 3 ||
                      !sp[:attempted] && !tp[:attempted] && v['signing_admitted'] == 1 && v['timebase_numer'] > 0 && error == 22), 'private memory failure')
      when 4, 5, 6, 9, 10
        reject_unless(sp[:forward] == stage || tp[:forward] == stage, 'claimed phase failure needs matching call')
      when 7
        reject_unless(sp[:forward] == 7 || tp[:forward] == 7 || d['schema_version'] == 1 && d['source_pre_entry_read_status'] != 0, 'register failure witness')
      when 8
        reject_unless(creates > 0 && create_status > 0 && error == create_status, 'watchdog create failure')
      when 11
        reject_unless(source_complete && v['checkpoint_valid'] == 0 && !tp[:attempted] && error == 71, 'checkpoint rejection prefix')
      when 12
        raise Rejected, 'run evidence: legacy snapshot stage is not entered by H3'
      when 13
        reject_unless(joins > 0 && join_status > 0 && error == join_status, 'watchdog join failure')
      when 14, 15, 16, 17
        first_cleanup = sp[:cleanup].nil? ? tp : sp
        reject_unless(first_cleanup[:cleanup] == stage, 'first cleanup failure')
        reject_unless(first_cleanup[:cleanup_error].nil? ? error > 0 : error == first_cleanup[:cleanup_error], 'cleanup first error')
      when 18
        reject_unless(v['cancellation_requested'] == 1 && error == 89, 'cancellation failure errno')
      when 19
        reject_unless(v['checkpoint_valid'] == 1 && v['cursor_sealed'] == 0 && !tp[:attempted] && error == 5, 'cursor capture failure')
      when 20
        raise Rejected, 'run evidence: unreachable stage-20 first failure'
      when 21
        reject_unless(v['cursor_sealed'] == 1 && s['conserved'] == 1 && !tp[:attempted] && error == 71, 'cursor decode failure')
      when 22
        reject_unless(tp[:attempted] && t['register_set_calls'] == 36 && t['register_status'] == 0 &&
                      v['cursor_restored'] == 0 && t['run_entries'] == 0 &&
                      (t['register_read_calls'] == 0 || t['read_register_status'] == 0) && error == 71, 'restore semantic failure')
      when 23
        reject_unless(terminal_complete && v['terminal_valid'] == 0 && error == 71, 'terminal semantic rejection')
      end
      true
    end
    def native_conditions(native, verifier, budget)
      budget.check
      v, s, t = %w[outer source target].map { |key| budget.check; words(native[key], budget) }
      phase_ok = lambda do |phase, source|
        budget.check
        scalar = %w[vm_create_status vcpu_create_status register_status run_status read_register_status vcpu_destroy_status vm_destroy_status]
        scalar.all? { |key| budget.check; phase[key] == 0 } &&
          %w[map_statuses unmap_statuses host_unmap_statuses].all? { |key| budget.check; phase[key].all? { |status| budget.check; status == 0 } } && trap(phase, source, budget)
      end
      chronology = v['start_ticks'] > 0 && v['timebase_numer'] > 0 && v['timebase_denom'] > 0 &&
        [v['start_ticks'], s['entry_ticks'], s['exit_ticks'], t['entry_ticks'], t['exit_ticks'], v['end_ticks']].each_cons(2).all? { |a, b| budget.check; a <= b } &&
        s['generation'] > 0 && s['generation'].odd? && s['generation'] < U64 && t['generation'] == s['generation'] + 1
      {
        'native.abi' => v['abi_version'] == 5,
        'native.cancellation' => v['cancellation_requested'] == 0 && v['cancellation_calls'] == 0 && v['cancellation_status'] == ABSENT,
        'native.chronology' => chronology,
        'native.conservation' => v['source_conserved'] == 1 && v['target_conserved'] == 1 && s['conserved'] == 1 && t['conserved'] == 1,
        'native.counts' => s['run_entries'] == 1 && t['run_entries'] == 1 && s['mappings_entered'] == 3 && t['mappings_entered'] == 3 &&
          s['register_set_calls'] == 36 && t['register_set_calls'] == 36 && s['register_read_calls'] == 36 &&
          t['register_read_calls'] == 38 && s['vm_create_status'] == 0 && t['vm_create_status'] == 0,
        'native.cursor' => v['cursor_sealed'] == 1 && v['cursor_decoded'] == 1 && v['cursor_restored'] == 1 && v['cursor_evidence_byte_count'] == 680,
        'native.execution' => v['execution_pass'] == 1 && v['checkpoint_valid'] == 1 && v['terminal_valid'] == 1,
        'native.outcome' => v['outcome'] == 1,
        'native.phase_source' => phase_ok.call(s, true),
        'native.phase_target' => phase_ok.call(t, false),
        'native.quarantine' => v['resources_quarantined'] == 0 && verifier['quarantined'] == false,
        'native.signing' => v['signing_admitted'] == 1 && v['signing_error'] == 0,
        'native.status' => v['failure_stage'] == 0 && v['first_error'] == 0,
        'native.teardown' => v['teardown_pass'] == 1,
        'native.watchdog' => v['watchdog_fired'] == 0 && v['watchdog_create_entries'] == 2 && v['watchdog_join_entries'] == 2 &&
          v['watchdog_create_status'] == 0 && v['watchdog_join_status'] == 0 && [ABSENT, 0, 60].include?(v['watchdog_wait_status'])
      }
    end

    def validate(inner_bytes:, outer_bytes:, stderr_bytes:, mode:, configuration:, budget:)
      budget.check
      reject_unless(%w[ADMISSION_ONLY GUEST].include?(mode) && %w[DEBUG RELEASE].include?(configuration), 'mode/configuration')
      reject_unless(stderr_bytes.instance_of?(String) && stderr_bytes.empty?, 'closed run empty stderr')
      inner = frame(inner_bytes, budget)
      outer = JSONPreflight.new(outer_bytes, budget, maximum: 131_072).decode(canonical: true)
      structure(inner, 'inner_report_v1', budget)
      structure(outer, 'outer_receipt_v1', budget)
      run = inner['run']
      reject_unless(run == outer['run'] && run['mode'] == mode && run['configuration'] == configuration &&
                    inner['build']['configuration'] == configuration, 'run identity echoes')
      nonce = [run['nonce']].pack('H*')
      mode_byte = mode == 'ADMISSION_ONLY' ? "\x01" : "\x02"
      configuration_byte = configuration == 'DEBUG' ? "\x01" : "\x02"
      reject_unless(run['run_id'] == digest("com.ergentics.provenance.h3-qualification-run-id.v1\0".b + mode_byte + configuration_byte + nonce), 'run id derivation')
      gate_hash = digest('EPRH3G01'.b + mode_byte + nonce)
      cancel_hash = digest('EPRH3C01'.b + nonce)
      reject_unless(inner['gate']['frame_sha256'] == gate_hash && inner['gate']['mode_byte'] == mode_byte.unpack1('H*') &&
                    outer['gate']['gate_frame_sha256'] == gate_hash && outer['gate']['cancel_frame_sha256'] == cancel_hash, 'gate/cancel derivation')
      spawn = outer['spawn']; child = outer['child']; gate = outer['gate']; evidence = outer['evidence']
      reject_unless(spawn['spawn_return'] == 0 && spawn['argv'] == [mode == 'ADMISSION_ONLY' ? '--h3-qualification-admission-once' : '--h3-qualification-guest-once', run['nonce']], 'spawn/argv')
      reject_unless(child['disposition'] == 'REAPED' && child['exit'] == 0 && child['signal'] == 'NOT_APPLICABLE' &&
                    child['wait_status'] == 0 && child['pid'] == inner['process']['pid'], 'exact normal exit zero')
      reject_unless(gate['gate_writes'] == 1 && gate['gate_return'] == 41 && gate['gate_errno'] == 0 &&
                    gate['cancel_writes'] == 0 && gate['cancel_return'] == ABSENT && gate['cancel_errno'] == 0, 'closed gate/cancellation')
      reject_unless(outer['kill'] == { 'attempted' => false, 'errno' => 0, 'pid' => child['pid'], 'return' => ABSENT }, 'closed no signal')
      reject_unless(outer['stderr'] == { 'eof' => true, 'overflow' => false, 'retained_byte_count' => 0,
                    'retained_sha256' => EMPTY_SHA, 'total_byte_count' => 0 }, 'stderr terminal evidence')
      reject_unless(evidence['inner_valid'] == true && evidence['inner_eof'] == true &&
                    evidence['inner_byte_count'] == inner_bytes.bytesize && evidence['inner_sha256'] == digest(inner_bytes), 'exact retained frame')
      identity(evidence['stdout_identity_terminal'], executable: false, budget: budget)
      reject_unless(evidence['stdout_identity_terminal']['mode'] == 384, 'stdout mode')
      root = evidence['root_identity']
      reject_unless(root['owner'] == 501 && root['mode'] == 448 && word(root['link_count']) >= 2 &&
                    word(root['inode']) > 0 && root['device'] == evidence['stdout_identity_terminal']['device'], 'evidence root')
      controller = outer['controller_claim']; app = outer['application']
      code(controller['code'], configuration, false, budget)
      identity(controller['held_at_start'], executable: true, budget: budget)
      reject_unless(controller['held_at_start'] == controller['named_at_start'], 'controller held/named identity')
      code(app['pre_static'], configuration, true, budget)
      reject_unless(app['dynamic'] == app['pre_static'] && app['post_static'] == app['pre_static'] &&
                    app['proc_pidpath'] == app['pre_static']['executable_path'], 'application code joins')
      identity(app['held_before_spawn'], executable: true, budget: budget)
      %w[held_before_gate named_before_spawn named_before_gate held_after_reap named_after_reap].each do |key|
        budget.check
        reject_unless(app[key] == app['held_before_spawn'], 'application vnode joins')
      end
      d = words(outer['deadlines'], budget); timing = words(inner['timing'], budget); monitor = words(inner['cancellation_monitor'], budget)
      reject_unless(d['timebase_numerator'] == timing['timebase_numerator'] && d['timebase_denominator'] == timing['timebase_denominator'], 'wrapper timebase join')
      [['gate_deadline_tick', 5], ['operation_deadline_tick', 10], ['kill_deadline_tick', 15], ['terminal_horizon_tick', 20]].each do |key, seconds|
        budget.check
        expected = deadline(d['spawn_tick'], seconds, d['timebase_numerator'], d['timebase_denominator'])
        reject_unless(Check.u64(expected) == d[key], 'fixed controller deadline')
      end
      ordered([d['spawn_tick'], d['gate_attempt_tick'], d['gate_return_tick'], d['gate_deadline_tick']], 'gate clock order', budget)
      ordered([d['spawn_tick'], timing['continuous_start_tick'], word(inner['gate']['validated_tick']), monitor['started_tick'],
               monitor['terminal_tick'], timing['continuous_end_tick'], d['reap_tick'], d['terminal_tick'], d['terminal_horizon_tick']], 'terminal clock order', budget)
      reject_unless(d['gate_return_tick'] <= d['reap_tick'] && d['gate_attempt_tick'] <= word(inner['gate']['validated_tick']) &&
                    d['cancel_tick'] == 0 && d['kill_attempt_tick'] == 0, 'gate/cancel/reap clocks')
      signing = inner['signing']; effects = inner['effects']; taxonomy = outer['taxonomy']
      reject_unless(effects['signing_state'] == signing['status'] && taxonomy['signing_state'] == signing['status'] &&
                    taxonomy['app_launched'] == true && taxonomy['signals'] == 0, 'signing taxonomy')
      if signing['admitted']
        reject_unless(evidence['effective_hypervisor_value'] == 'TRUE' &&
                      signing['effective_entitlements'] == app['pre_static']['entitlements'] &&
                      signing['effective_entitlements_sha256'] == app['pre_static']['entitlements_sha256'] &&
                      evidence['effective_entitlements_sha256'] == signing['effective_entitlements_sha256'], 'effective/static signing join')
      else
        reject_unless((signing['native_result'] == 0 && signing['error'] == 0 && signing['status'] == 'REJECTED') ||
                      (signing['native_result'] == -1 && signing['error'] != 0 && signing['status'] == 'API_ERROR'), 'cached rejected signing tuple')
        reject_unless(evidence['effective_hypervisor_value'] == 'NOT_OBSERVED' && evidence['effective_entitlements_sha256'] == ZERO_SHA, 'rejected signing observation')
      end
      failures = []
      native = inner['native']
      if mode == 'ADMISSION_ONLY'
        reject_unless(native == { 'disposition' => 'NOT_ENTERED', 'preparation_error' => ABSENT,
                      'reason' => signing['admitted'] ? 'ADMISSION_MODE' : 'SIGNING_REJECTED' } &&
                      inner['verifier'] == { 'disposition' => 'NOT_ENTERED' } &&
                      effects['lifecycle_disposition'] == 'NOT_ENTERED' && effects['reservation_entries'] == 0 &&
                      effects['reservation_release_entries'] == 0 && effects['reservation_release_status'] == ABSENT &&
                      effects['guest_entered_count'] == 0 && effects['hv_vm_created_count'] == 0 &&
                      evidence['hypervisor_support'] == 'NOT_QUERIED', 'admission zero native effects')
        failures << 'application.live_self_signing_admission' unless signing['admitted']
      else
        reject_unless(signing['admitted'] && native['disposition'] == 'RETURNED' &&
                      effects['reservation_entries'] == 1 && effects['reservation_release_entries'] == 1 &&
                      effects['reservation_release_status'] == 0 && effects['lifecycle_disposition'] == 'RECOVERY_VOLATILE', 'guest closed reservation/lifecycle')
        native_prefix(native, budget)
        replay = GuestReplay.replay(native: native, budget: budget)
        reject_unless(replay.instance_of?(Hash) && replay[:verifier] == inner['verifier'], 'independent exact verifier replay')
        reject_unless(replay[:conditions].instance_of?(Hash) && replay[:conditions].keys.sort == SWIFT_LITERALS.sort &&
                      replay[:conditions].values.all? { |v| budget.check; v == true || v == false }, 'complete Swift predicate derivation')
        reject_unless(inner['verifier']['checkpoint_integrity'] != 'MALFORMED' &&
                      inner['verifier']['sctlr_transition_integrity'] != 'MALFORMED' &&
                      (native['outer']['cursor_sealed'] == 0 || replay[:conditions]['swift.cursor_reconstruction']), 'native witness source validity')
        conditions = native_conditions(native, inner['verifier'], budget).merge(replay[:conditions])
        failures = conditions.reject { |_, pass| budget.check; pass }.keys.sort_by(&:b)
        creates = [native['source'], native['target']].count { |phase| budget.check; phase['vm_create_status'] == 0 }
        entries = native['source']['run_entries'] + native['target']['run_entries']
        support = creates > 0 ? 'NATIVE_ENTRY_SUCCEEDED' :
          ([native['source'], native['target']].any? { |phase| budget.check; phase['vm_create_status'] != ABSENT } ? 'NATIVE_ENTRY_FAILED' : 'NOT_ENTERED')
        reject_unless(effects['hv_vm_created_count'] == creates && effects['guest_entered_count'] == entries &&
                      evidence['hypervisor_support'] == support, 'native effect/support derivation')
        reject_unless(native['outer']['teardown_pass'] == 1 && native['outer']['resources_quarantined'] == 0 &&
                      inner['verifier']['quarantined'] == false && conditions['native.cancellation'], 'closed guest conservation/cancellation')
      end
      reject_unless(taxonomy['guest_entered_count'] == effects['guest_entered_count'] &&
                    taxonomy['hv_vm_created_count'] == effects['hv_vm_created_count'], 'effect taxonomy count join')
      result = failures.empty? ? 'RUN_CANDIDATE_PASS' : 'RETAINED_NONPASS'
      reject_unless(outer['classification'] == { 'failed_predicates' => failures, 'result' => result }, 'exact classification derivation')
      { inner: inner, outer: outer, failures: failures, result: result,
        guest_entries: effects['guest_entered_count'], hv_vm_creates: effects['hv_vm_created_count'],
        terminal_nonpass: !failures.empty? }
    end
  end

  class ImmutableArtifact
    attr_reader :bytes, :reference
    def initialize(files, directory, path, maximum:, retain: false)
      Check.that(Check.path(path).split('/').length == 1 && maximum.instance_of?(Integer) && maximum.between?(1, 8_388_608), 'artifact fixed basename/bound')
      @files, @directory, @path, @maximum = files, directory, path, maximum
      @budget, @native = files.budget, files.native
      @count = @attempts = @interrupts = 0
      @hash, @bytes = Digest::SHA256.new, retain ? ''.b : nil
      @reference = @finished = @failed = nil
      @root_identity = @files.admit(directory, directory: true)
      @budget.check
      fd, error = @native.call(:openat, directory.fileno, path, Native::O_WRONLY | Native::O_CREAT | Native::O_EXCL | Native::O_NOFOLLOW | Native::O_CLOEXEC, 0o600)
      @io = @files.wrap(fd, error)
      @created = @files.admit(@io)
      Check.that(@created['mode'] == 0o600 && @created['size'] == 0 && @created['device'] == @root_identity['device'], 'created artifact leaf policy')
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def append(chunk)
      @budget.check
      Check.that(!@failed && !@finished && @io && !@io.closed? && chunk.instance_of?(String) && chunk.bytesize.between?(1, 65_536), 'artifact streaming state/chunk')
      Check.that(@count + chunk.bytesize <= @maximum, 'artifact byte cap')
      offset = 0
      while offset < chunk.bytesize
        @budget.check
        @attempts += 1
        Check.that(@attempts <= @maximum + 64, 'artifact write attempt cap')
        begin
          request = chunk.byteslice(offset, chunk.bytesize - offset)
          written = @io.syswrite(request)
        rescue Errno::EINTR
          @interrupts += 1
          Check.that(@interrupts <= 64, 'artifact write EINTR cap')
          next
        end
        Check.that(written.instance_of?(Integer) && written.between?(1, request.bytesize), 'artifact write progress')
        @hash.update(request.byteslice(0, written))
        @bytes << request.byteslice(0, written) if @bytes
        @count += written
        offset += written
      end
    rescue Exception
      @failed = true
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def finish(sync_directory: false)
      @budget.check
      Check.that(!@failed && !@finished && @io && !@io.closed? && @count >= 1, 'artifact finish one nonempty attempt')
      @finished = true
      after = @files.admit(@io)
      Check.that(after.values_at('device', 'inode', 'type', 'uid', 'mode', 'nlink') == @created.values_at('device', 'inode', 'type', 'uid', 'mode', 'nlink') && after['size'] == @count, 'artifact post-write identity/size')
      @budget.check
      result, error = @native.call(:fsync, @io.fileno)
      Check.that(result == 0, 'artifact fsync errno ' + error.to_s)
      @budget.check
      result, error = @native.call(:fcntl, @io.fileno, 51, 0)
      Check.that(result == 0, 'artifact F_FULLFSYNC errno ' + error.to_s)
      @budget.check
      close
      reopened = @files.observe(@directory, @path, maximum: @maximum)
      Check.that(reopened['identity'] == after && reopened['byte_count'] == @count && reopened['sha256'] == @hash.hexdigest, 'artifact durability reopen bytes/identity')
      if sync_directory
        @budget.check
        result, error = @native.call(:fsync, @directory.fileno)
        Check.that(result == 0, 'artifact containing-directory fsync errno ' + error.to_s)
      end
      @reference = { 'byte_count' => @count, 'path' => @path, 'sha256' => @hash.hexdigest }
    ensure
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
    end
    def close
      owned = @io
      @io = nil
      owned.close if owned && !owned.closed?
    end
    def self.write(files, directory, path, bytes, maximum:, sync_directory: false)
      Check.that(bytes.instance_of?(String) && bytes.bytesize <= maximum, 'artifact complete input byte cap')
      writer = new(files, directory, path, maximum: maximum)
      begin
        offset = 0
        while offset < bytes.bytesize
          files.budget.check
          chunk = bytes.byteslice(offset, [65_536, bytes.bytesize - offset].min)
          writer.append(chunk)
          offset += chunk.bytesize
        end
        writer.finish(sync_directory: sync_directory)
      ensure
        Cleanup.close_all([writer], original_error: $!)
      end
    end
  end

  class CampaignDirectory
    ADMISSION = 'ergentics-h3q-admission-campaign-v1'.freeze
    GUEST = 'ergentics-h3q-guest-campaign-v1'.freeze
    attr_reader :root, :run_roots, :path
    def initialize(files, parent, basename)
      Check.that([ADMISSION, GUEST].include?(basename), 'campaign fixed basename')
      @files, @parent, @path = files, parent, '/private/tmp/' + basename
      @root, @run_roots = nil, {}
      parent_identity = files.admit(parent, directory: true, owner: 0)
      Check.that(parent_identity['mode'] == 0o1777 && parent_identity['nlink'] >= 2, 'campaign parent policy')
      files.absent(parent, basename)
      files.budget.check
      result, error = files.native.call(:mkdirat, parent.fileno, basename, 0o700)
      Check.that(result == 0, 'campaign mkdirat errno ' + error.to_s)
      @root = files.relative(parent, basename, directory: true)
      identity = files.admit(@root, directory: true)
      Check.that(identity['mode'] == 0o700 && identity['nlink'] >= 2 && identity['device'] == parent_identity['device'], 'new campaign root policy')
      files.budget.check
      result, error = files.native.call(:fsync, parent.fileno)
      Check.that(result == 0, 'campaign parent fsync errno ' + error.to_s)
      %w[debug release].each do |name|
        files.budget.check
        result, error = files.native.call(:mkdirat, @root.fileno, name, 0o700)
        Check.that(result == 0, 'run root mkdirat errno ' + error.to_s)
        run = files.relative(@root, name, directory: true)
        @run_roots[name] = run
        run_identity = files.admit(run, directory: true)
        Check.that(run_identity['mode'] == 0o700 && run_identity['nlink'] >= 2 && run_identity['device'] == identity['device'], 'new run root policy')
        files.inventory(run, @path + '/' + name, [], maximum: 5)
      end
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def complete_prelaunch(files)
      @files.inventory(@root, @path, files + %w[debug release], maximum: 16)
      @run_roots.each { |name, io| @files.budget.check; @files.inventory(io, @path + '/' + name, [], maximum: 5) }
      @files.budget.check
      result, error = @files.native.call(:fsync, @root.fileno)
      Check.that(result == 0, 'campaign prelaunch directory fsync errno ' + error.to_s)
      true
    end
    def close
      owned = [@root].compact + (@run_roots || {}).values
      @run_roots = {}
      @root = nil
      Cleanup.close_all(owned)
    end
  end

  class SealedBuild
    PRELAUNCH = %w[build-source-manifest.json debug-build-settings.json debug-build.log debug-product-audit.json release-build-settings.json release-build.log release-product-audit.json source-state.json].freeze
    def initialize(files, supervisor, runtime)
      @files, @supervisor, @runtime, @budget = files, supervisor, runtime, files.budget
    end
    def run
      parent = repository = campaign = nil
      before_children = @supervisor.children
      begin
        parent = @files.absolute('/private/tmp', directory: true, owner: 0)
        repository = @files.absolute(ROOT, directory: true)
        campaign = CampaignDirectory.new(@files, parent, CampaignDirectory::ADMISSION)
        toolchain = ToolchainProbes.produce(@supervisor, @budget)
        source_pass = SourcePass.new(@files, @supervisor, @runtime.self_sha256)
        first = source_pass.perform(independent_dirty_reads: true) # P1
        source_candidate = source_pass.candidate
        scheme_pin = source_candidate.fetch('source').fetch('delta_path_pins').find { |pin| pin['path'] == SCHEME_PATH }
        Check.that(scheme_pin, 'seal qualification scheme source pin')
        artifacts, builds, products = {}, [], []
        %w[Debug Release].each do |configuration|
          @budget.check
          lower = configuration.downcase
          derived = '/private/tmp/ergentics-h3q-' + lower + '-v1'
          argv = [OrdinaryCompatibility::XCODEBUILD, '-project', ROOT + '/ErgenticsProvenance.xcodeproj',
                  '-scheme', 'ErgenticsProvenanceH3Qualification', '-configuration', configuration,
                  '-destination', 'platform=macOS,arch=arm64', '-derivedDataPath', derived,
                  'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION', 'CODE_SIGNING_ALLOWED=YES', 'build']
          log = ImmutableArtifact.new(@files, campaign.root, lower + '-build.log', maximum: 8_388_608)
          begin
            build_result = SchemeBracket.new(@files, repository, scheme_pin.fetch('sha256')).around do
              @files.absent(parent, 'ergentics-h3q-' + lower + '-v1')
              @supervisor.run(argv, cwd: ROOT, seconds: 900, maximum: 8_388_608, merged: true, consumer: log.method(:append))
            end
            log_reference = log.finish
          ensure
            Cleanup.close_all([log], original_error: $!)
          end
          Check.that(source_pass.perform(independent_dirty_reads: true) == first, 'P2/P4 source bracket')
          settings_argv = argv + ['-showBuildSettings', '-json']
          settings_writer = ImmutableArtifact.new(@files, campaign.root, lower + '-build-settings.json', maximum: 1_048_576, retain: true)
          begin
            settings_result = SchemeBracket.new(@files, repository, scheme_pin.fetch('sha256')).around do
              @supervisor.run(settings_argv, cwd: ROOT, seconds: 120, maximum: 1_048_576, consumer: settings_writer.method(:append))
            end
            Check.that(settings_result.fetch('stderr').empty?, 'sealed settings stderr')
            settings = BuildSettings.validate(settings_writer.bytes, configuration: configuration, ordinary: false, budget: @budget)
            settings_reference = settings_writer.finish
          ensure
            Cleanup.close_all([settings_writer], original_error: $!)
          end
          audit = produce_product_audit(parent, configuration.upcase, settings)
          audit_bytes = Canonical.encode(audit, @budget)
          audit_reference = ImmutableArtifact.write(@files, campaign.root, lower + '-product-audit.json', audit_bytes, maximum: 262_144)
          Check.that(source_pass.perform(independent_dirty_reads: true) == first, 'P3/P5 source bracket')
          artifacts[lower + '_build_log'] = log_reference
          artifacts[lower + '_build_settings'] = settings_reference
          artifacts[lower + '_product_audit'] = audit_reference
          builds << { 'argv' => argv, 'build_log' => log_reference, 'build_process' => build_result.fetch('process'),
                      'configuration' => configuration.upcase, 'cwd' => ROOT, 'derived_data_path' => derived,
                      'environment' => ENVIRONMENT, 'product_audit' => audit_reference, 'settings' => settings_reference,
                      'settings_argv' => settings_argv, 'settings_process' => settings_result.fetch('process'),
                      'settings_stderr' => Canonical.stream(settings_result.fetch('stderr')) }
          products << { 'application' => audit.fetch('application'), 'configuration' => configuration.upcase,
                        'controller' => audit.fetch('controller'), 'audit' => audit_reference }
        end
        # The sole durable source-state value is the identical P-derived value;
        # all four brackets completed before either final artifact is created.
        artifacts['source_state'] = ImmutableArtifact.write(@files, campaign.root, 'source-state.json', first, maximum: 262_144)
        manifest = { 'artifacts' => artifacts, 'builds' => builds, 'dirty_guard' => source_candidate.fetch('dirty_guard'),
                     'products' => products, 'schema' => 'com.ergentics.provenance.h3-qualification-build-source-manifest.v1',
                     'source' => source_candidate.fetch('source'), 'source_state' => artifacts.fetch('source_state'),
                     'toolchain' => toolchain, 'version' => 1 }
        ImmutableArtifact.write(@files, campaign.root, 'build-source-manifest.json', Canonical.encode(manifest, @budget), maximum: 262_144)
        campaign.complete_prelaunch(PRELAUNCH)
        Check.that(@supervisor.children - before_children == 83, 'seal admission exact direct-child count')
        true
      ensure
        Cleanup.close_all([parent, repository, campaign], original_error: $!)
      end
    end
    private
    def produce_product_audit(parent, configuration, settings)
      probes = []
      [true, false].each_with_index do |application, index|
        @budget.check
        code, executable = ProductProbes.paths(configuration, application)
        resolved = settings.fetch(index).fetch('buildSettings')
        Check.that(resolved.fetch('TARGET_BUILD_DIR') + '/' + resolved.fetch('FULL_PRODUCT_NAME') == code &&
                   resolved.fetch('TARGET_BUILD_DIR') + '/' + resolved.fetch('EXECUTABLE_PATH') == executable, 'settings/product exact path derivation')
        relative = executable.byteslice('/private/tmp/'.bytesize, executable.bytesize)
        held, before = @files.pair(parent, relative, minimum: 1, maximum: 67_108_864)
        begin
          ProductProbes.argv(configuration, application).each do |argv|
            @budget.check
            result = @supervisor.run(argv, cwd: '/private/var/empty', seconds: 30)
            probes << { 'argv' => argv, 'cwd' => '/private/var/empty', 'environment' => ENVIRONMENT, 'exit_status' => 0,
                        'stderr' => Canonical.stream(result.fetch('stderr')), 'stdout' => Canonical.stream(result.fetch('stdout')) }
          end
          after = @files.observe(parent, relative, minimum: 1, maximum: 67_108_864)
          Check.that(before == after && @files.identity(held) == before.fetch('identity'), 'product post-probe executable byte/identity join')
          claim = ProductProbes.claim(probes.last(6), configuration, application, @budget)
          Check.that(claim.fetch('executable_sha256') == before.fetch('sha256'), 'product internal/external executable SHA256 join')
        ensure
          Cleanup.close_all([held], original_error: $!)
        end
      end
      ProductProbes.validate(probes, configuration, @budget)
    end
  end

  # Pure validation of the complete eight-file prelaunch audit set. Source
  # semantics are supplied only by a freshly completed SourcePass, never by a
  # caller-authored claim or an earlier probe's labels alone.
  # Independent, pure reconstruction of the native guest's inert projections.
  # Inputs are copied wire values, never a VM, pointer, file or live capability.
  module GuestReplay
    module_function
    IMAGE_HEX = '000088d20000a2f2010090d20100a2f2030098d20300a2f204fcdfc89f0400f121030054050440f9bf0400f1c1020054060840f9070c40f9c600078b250400f9260800f93f0c00f924fc9fc89f3f03d5640000b9dfa800f161010054280840f91fa900f10101005408050091280c00f9440080d224fc9fc89f3f03d5640000b9a0d53bd4a07521d4'.freeze
    IMAGE_HASH = '3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0'.freeze
    PREFIX = 'ergentics.provenance.hypervisor-stage.h3.'.freeze
    STAGE = 'hypervisor_explicit_state_cursor_resume_v1'.freeze
    CP_SCHEMA = 'ergentics.hypervisor.guest.h3.checkpoint.v2'.freeze
    TERMINAL_SCHEMA = 'ergentics.hypervisor.guest.h3.terminal.v2'.freeze
    GPRS = ([0x10004000, 0x10008000, 0, 0x1000c000, 1, 1, 42, 23] + [0] * 23).freeze
    SENTINEL = -2_147_483_648
    U32_MAX = 4_294_967_295
    PREDICATES = %w[h2_product_causal_lineage_exact cursor_schema_exact checkpoint_state_exact next_operation_exact source_owner_retired fresh_owner_independent resume_not_reexecution control_resume_terminal_equal cursor_one_winner_no_replay json_cbor_semantic_join merkle_ancestry_exact no_live_or_durable_effects].freeze
    H2 = {
      'h2_product_source_commit' => 'ffefa11b412cbefb0dd5230e7eb6f6cfa6d5eb55',
      'h2_product_source_tree' => '2b6333ba5c05a8a6b3b4e873850bd36355a5cba9',
      'h2_product_result_commit' => '12a0ff52a81e669f135ec9ab4640ee0ba091dbc6',
      'h2_product_result_tree' => '3c06694713ceb690373a36c04922371180c06931',
      'h2_product_result_parent_commit' => 'ffefa11b412cbefb0dd5230e7eb6f6cfa6d5eb55',
      'h2_product_receipt_sha256' => '83a201a32114c81fa737f6edfa2b0976324e6e0ca44223f589abbffae4c6f4d4',
      'h2_product_receipt_git_blob' => '98c037b8c82ed27f458c48fc6a1d92fc05a78e59',
      'build_archive_receipt_sha256' => 'fd5e58920b61750cd37b1f6d19e78d37b17824aae559f306527268feb2f7ddd2',
      'build_archive_receipt_git_blob' => '5b46f8e7f88895d7a1919eb325a4f6ce827806af',
      'h2_static_result_sha256' => 'b3693a405a382bd33f8762c08147afd13669533a525856cabb7b954238853855',
      'h2_static_result_git_blob' => 'ef67768a9c895f9c9a06e12f49590b9d724e5103',
      'h2_static_receipt_root' => '50a3a244914f5987c3552a0d68faaedef29d17d856d7d645f6d834b5e32c20ca',
      'h2_static_output_state_root' => '6b880870ce4216c9c0793ef198695920323ff23cf6e79b0d8a6cca1f2d8d5d66',
      'h2_snapshot_root' => '37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df'
    }.freeze
    def number(object, key)
      value = object.fetch(key)
      return value if value.instance_of?(Integer)
      Check.that(value.instance_of?(String) && /\A(?:0|[1-9][0-9]{0,19})\z/.match?(value), 'guest canonical scalar ' + key)
      Check.u64(value.to_i)
    end
    def bytes(text, count)
      Check.that(text.instance_of?(String) && text.bytesize == count * 2 && /\A[0-9a-f]*\z/.match?(text), 'guest fixed hex')
      [text].pack('H*')
    end
    def sha(value); Digest::SHA256.hexdigest(value); end
    def image; bytes(IMAGE_HEX, 136); end
    def frame(words); words.each { |word| Check.u64(word) }; words.pack('Q<*'); end
    def page(prefix)
      Check.that(prefix.bytesize <= 16_384, 'guest page prefix')
      prefix.b + "\0" * (16_384 - prefix.bytesize)
    end
    def cbor_head(major, count)
      Check.u64(count)
      return [(major << 5) | count].pack('C') if count < 24
      width, format, tag = count <= 255 ? [1, 'C', 24] : count <= 65_535 ? [2, 'n', 25] : count <= U32_MAX ? [4, 'N', 26] : [8, 'Q>', 27]
      [(major << 5) | tag].pack('C') + [count].pack(format)
    end
    def cbor(value, budget)
      output, work, nodes = ''.b, [[:value, value, 0]], 0
      until work.empty?
        budget.check
        kind, item, depth = work.pop
        if kind == :raw
          Check.that(output.bytesize + item.bytesize <= 65_536, 'guest CBOR byte bound')
          output << item
          next
        end
        nodes += 1
        Check.that(depth <= 16 && nodes <= 8192, 'guest CBOR structural bound')
        case item
        when TrueClass, FalseClass then work << [:raw, item ? "\xf5".b : "\xf4".b, depth]
        when String
          Check.that(item.bytesize <= 65_536 && item.dup.force_encoding(Encoding::UTF_8).valid_encoding?, 'guest CBOR text')
          work << [:raw, item.b, depth]
          work << [:raw, cbor_head(3, item.bytesize), depth]
        when Array
          Check.that(item.length <= 256, 'guest CBOR array')
          item.reverse_each { |child| budget.check; work << [:value, child, depth + 1] }
          work << [:raw, cbor_head(4, item.length), depth]
        when Hash
          Check.that(item.length <= 256 && item.keys.all? { |key| key.instance_of?(String) && key.bytesize <= 256 }, 'guest CBOR map')
          keys = item.keys.sort_by { |key| cbor_head(3, key.bytesize) + key.b }
          keys.reverse_each { |key| budget.check; work << [:value, item.fetch(key), depth + 1]; work << [:value, key, depth + 1] }
          work << [:raw, cbor_head(5, item.length), depth]
        else raise Rejected, 'guest projection scalar'
        end
      end
      output
    end
    def merkle(leaves, budget)
      Check.that(leaves.instance_of?(Hash) && leaves.length.between?(1, 128) && leaves.key?('schema'), 'guest Merkle leaf inventory')
      total = 0
      level = leaves.keys.sort_by(&:b).map do |label|
        budget.check
        payload = leaves.fetch(label)
        Check.that(label.instance_of?(String) && !label.empty? && label.ascii_only? && payload.instance_of?(String), 'guest Merkle leaf shape')
        total += label.bytesize + payload.bytesize
        Check.that(total <= 1_048_576, 'guest Merkle byte bound')
        Digest::SHA256.digest("\0" + [label.bytesize].pack('N') + label.b + [payload.bytesize].pack('Q>') + payload.b)
      end
      while level.length > 1
        budget.check
        level = level.each_slice(2).map { |pair| budget.check; Digest::SHA256.digest((pair.length == 2 ? "\x01" : "\x03") + pair.join) }
      end
      sha("\x02" + [leaves.length].pack('Q>') + level.fetch(0))
    end
    # Decoder for the generated semantic subset: text, booleans, arrays and
    # text-keyed maps. Limits are checked before collection/string allocation.
    def decode_cbor(encoded, budget)
      Check.that(encoded.instance_of?(String) && encoded.bytesize.between?(1, 65_536), 'guest CBOR decode byte bound')
      offset, nodes = 0, 0
      take = lambda do |count|
        budget.check
        Check.that(count <= encoded.bytesize - offset, 'guest CBOR truncated')
        result = encoded.byteslice(offset, count)
        offset += count
        result
      end
      parse = nil
      parse = lambda do |depth|
        budget.check
        nodes += 1
        Check.that(depth <= 16 && nodes <= 8192, 'guest CBOR decode structural bound')
        first = take.call(1).getbyte(0)
        major, info = first >> 5, first & 31
        if major == 7
          Check.that([20, 21].include?(info), 'guest CBOR simple value')
          next info == 21
        end
        Check.that([3, 4, 5].include?(major) && info <= 27, 'guest CBOR generated type')
        count = if info < 24
                  info
                else
                  width, format, minimum = { 24 => [1, 'C', 24], 25 => [2, 'n', 256], 26 => [4, 'N', 65_536], 27 => [8, 'Q>', 4_294_967_296] }.fetch(info)
                  value = take.call(width).unpack1(format)
                  Check.that(value >= minimum, 'guest CBOR shortest head')
                  value
                end
        if major == 3
          value = take.call(count).force_encoding(Encoding::UTF_8)
          Check.that(value.valid_encoding?, 'guest CBOR decoded UTF8')
          next value
        end
        Check.that(count <= 256, 'guest CBOR decode collection bound')
        next Array.new(count) { parse.call(depth + 1) } if major == 4
        value, previous = {}, nil
        count.times do
          budget.check
          begin_key = offset
          key = parse.call(depth + 1)
          key_bytes = encoded.byteslice(begin_key, offset - begin_key)
          Check.that(key.instance_of?(String) && !value.key?(key), 'guest CBOR decoded map key')
          ordering = [key_bytes.bytesize, key_bytes.b]
          Check.that(previous.nil? || (previous <=> ordering) == -1, 'guest CBOR decoded key order')
          previous = ordering
          value[key] = parse.call(depth + 1)
        end
        value
      end
      value = parse.call(0)
      Check.that(offset == encoded.bytesize, 'guest CBOR trailing bytes')
      value
    end
    def project(semantic, schema, role, budget)
      budget.check
      Check.that(semantic.fetch('schema') == schema, 'guest projection schema')
      json, encoded = Canonical.encode(semantic, budget), cbor(semantic, budget)
      Check.that(json.bytesize.between?(1, 65_536) && encoded.bytesize.between?(1, 65_536), 'guest projection bound')
      Check.that(JSONPreflight.new(json, budget, maximum: 65_536).decode(canonical: true) == semantic && decode_cbor(encoded, budget) == semantic, 'guest independent JSON/CBOR semantic join')
      { 'semantic' => semantic, 'json' => json, 'cbor' => encoded,
        'root' => merkle({ 'schema' => schema, role + '.json' => json, role + '.cbor' => encoded }, budget) }
    end
    def node(id, partition, type, schema, root)
      { 'id' => id, 'partition' => partition, 'node_type' => type, 'content_schema' => schema, 'content_root' => root }
    end
    def edge(from, to, position, relation, predicate = nil)
      value = { 'from' => from, 'to' => to, 'position' => position.to_s, 'relation' => relation }
      value['predicate_id'] = predicate if predicate
      value
    end
    def phase_semantic(phase)
      keys = %w[conserved entry_ticks exception_reason exit_ticks fault_ipa fault_virtual_address generation mappings_entered pc register_read_calls register_set_calls run_entries syndrome x4]
      value = keys.each_with_object({}) { |key, out| out[key] = number(phase, key).to_s }
      statuses = {}
      %w[host_unmap map unmap].each { |key| statuses[key] = phase.fetch(key + '_statuses').map(&:to_s) }
      %w[read_register register run vcpu_create vcpu_destroy vm_create vm_destroy].each { |key| statuses[key] = number(phase, key + '_status').to_s }
      value['statuses'] = statuses
      value
    end
    def live_receipt(native, readiness, budget)
      readiness = readiness.select { |key, _value| key.instance_of?(String) }
      o = native.fetch('outer')
      cp, cursor, terminal = native.values_at('checkpoint_merkle_hex', 'cursor_sha256', 'terminal_merkle_hex')
      lifecycle_keys = %w[cancellation_calls cancellation_requested cancellation_status end_ticks resources_quarantined start_ticks timebase_denom timebase_numer watchdog_create_entries watchdog_join_entries watchdog_wait_status]
      result_keys = %w[abi_version checkpoint_valid cursor_decoded cursor_restored cursor_sealed execution_pass failure_stage first_error outcome signing_admitted signing_error source_conserved target_conserved teardown_pass terminal_valid watchdog_create_status watchdog_fired watchdog_join_status]
      boundary = { 'authority_vector' => '00000000', 'durable' => false, 'gate_e' => 'ABSTAIN', 'h4_entered' => false }
      state_value = boundary.merge(
        'lifecycle' => lifecycle_keys.each_with_object({}) { |key, value| value[key] = number(o, key).to_s },
        'native_result' => result_keys.each_with_object({}) { |key, value| value[key] = number(o, key).to_s },
        'native_roots' => { 'checkpoint_merkle' => cp, 'cursor_sha256' => cursor, 'guest_image_sha256' => IMAGE_HASH, 'terminal_merkle' => terminal },
        'projection_disposition' => 'IN_MEMORY_PRESENTATION_ONLY', 'readiness' => readiness.merge('outcome' => 'PASS_H3_CURSOR_CONTRACT_ONLY'),
        'schema' => PREFIX + 'live-state.v1', 'source' => phase_semantic(native.fetch('source')), 'stage_id' => STAGE,
        'status' => 'PASS', 'target' => phase_semantic(native.fetch('target')))
      state = project(state_value, state_value['schema'], 'state', budget)
      transitions = [
        ['readiness-live-join', 'STATIC_READINESS_JOINS_LIVE_STATE', [readiness['receipt_root'], readiness['graph_root'], readiness['cursor_root']], [state['root']]],
        ['cursor-checkpoint', 'CURSOR_DIGEST_COMMITS_CHECKPOINT', [cursor], [cp]],
        ['checkpoint-terminal', 'CHECKPOINT_RESUMES_TO_TERMINAL', [cp], [terminal]],
        ['authority-boundary', 'PRESENTATION_CANNOT_ELEVATE_AUTHORITY', [terminal], [state['root']]]
      ]
      transition_nodes = transitions.map do |id, relation, inputs, outputs|
        budget.check
        value = boundary.merge('id' => id, 'inputs' => inputs, 'outputs' => outputs, 'predicate' => relation,
          'readiness_graph_root' => readiness['graph_root'], 'readiness_receipt_root' => readiness['receipt_root'], 'schema' => PREFIX + 'live-transition.v1')
        projection = project(value, value['schema'], 'transition', budget)
        node(id, 'transition', 'verified-transition', value['schema'], projection['root'])
      end
      state_nodes = [
        node('static-readiness-receipt', 'state', 'static-readiness-receipt', PREFIX + 'receipt.v1', readiness['receipt_root']),
        node('static-readiness-graph', 'state', 'static-readiness-graph', PREFIX + 'graph.v1', readiness['graph_root']),
        node('static-readiness-cursor', 'state', 'static-readiness-cursor', PREFIX + 'cursor.v1', readiness['cursor_root']),
        node('native-cursor', 'state', 'native-cursor', 'ergentics.hypervisor.guest.h3.cursor.v1', cursor),
        node('native-checkpoint', 'state', 'native-checkpoint', CP_SCHEMA, cp),
        node('native-terminal', 'state', 'native-terminal', TERMINAL_SCHEMA, terminal),
        node('live-state', 'state', 'verified-live-state', state_value['schema'], state['root'])]
      edges = [
        ['static-readiness-receipt', 'readiness-live-join', 'READINESS_RECEIPT_INPUT'],
        ['static-readiness-graph', 'readiness-live-join', 'READINESS_GRAPH_INPUT'],
        ['static-readiness-cursor', 'readiness-live-join', 'READINESS_CURSOR_INPUT'],
        ['readiness-live-join', 'live-state', 'VERIFIES_LIVE_STATE'],
        ['native-cursor', 'cursor-checkpoint', 'CURSOR_INPUT'], ['cursor-checkpoint', 'native-checkpoint', 'COMMITS_CHECKPOINT'],
        ['native-checkpoint', 'checkpoint-terminal', 'CHECKPOINT_INPUT'], ['checkpoint-terminal', 'native-terminal', 'DERIVES_TERMINAL'],
        ['native-terminal', 'authority-boundary', 'TERMINAL_INPUT'], ['authority-boundary', 'live-state', 'BOUNDS_PRESENTATION']
      ].each_with_index.map { |(from, to, relation), index| edge(from, to, index, relation) }
      graph_value = boundary.merge('bipartite' => true, 'bipartite_rule' => 'STATE_TO_TRANSITION_OR_TRANSITION_TO_STATE_ONLY',
        'edge_count' => edges.length.to_s, 'edges' => edges, 'node_count' => (state_nodes.length + transition_nodes.length).to_s,
        'nodes' => state_nodes + transition_nodes, 'schema' => PREFIX + 'live-graph.v1')
      graph = project(graph_value, graph_value['schema'], 'graph', budget)
      root = merkle({ 'schema' => PREFIX + 'live-receipt.v1', 'graph.json' => graph['json'], 'graph.cbor' => graph['cbor'],
        'state.json' => state['json'], 'state.cbor' => state['cbor'], 'readiness_receipt_root' => readiness['receipt_root'],
        'readiness_graph_root' => readiness['graph_root'], 'cursor_digest' => cursor, 'checkpoint_root' => cp, 'terminal_root' => terminal }, budget)
      { 'root' => root, 'graph_root' => graph['root'] }
    end
    def cursor_error(native, budget)
      o, s, t = native.values_at('outer', 'source', 'target')
      return 'H3 cursor evidence length rejected' unless number(o, 'cursor_evidence_byte_count') == 680
      evidence = bytes(native.fetch('cursor_evidence_hex'), 680)
      reply = bytes(native.fetch('checkpoint_reply_hex'), 32)
      return 'H3 fixed checkpoint reply rejected' unless reply == frame([1, 1, 42, 0])
      return 'H3 evidence magic rejected' unless evidence.byteslice(0, 8) == "EPRH3E2\0"
      header = [2, number(s, 'generation'), number(t, 'generation'), 2, 3, 31, 4, 136, 16_384, 0x50, 0x54, 0x7c, 0x1000c000, 4, 1, 2]
      return 'H3 evidence header rejected' unless evidence.byteslice(8, 128) == header.pack('Q>*')
      return 'H3 checkpoint GPR rejected' unless evidence.byteslice(136, 248) == GPRS.pack('Q>*')
      return 'H3 checkpoint system register rejected' unless evidence.byteslice(384, 32) == [0x600003c5, 0x30d00980, 0x1000bff0, 0].pack('Q>*')
      regions = [1, 0x10000000, 16_384, 5, 2, 0x10004000, 16_384, 1, 3, 0x10008000, 16_384, 3]
      return 'H3 region descriptor rejected' unless evidence.byteslice(416, 96) == regions.pack('Q>*')
      hashes = [page(image), page(frame([1, 1, 19, 23])), page(reply)].map { |value| budget.check; Digest::SHA256.digest(value) }.join
      return 'H3 exact-page digests rejected' unless evidence.byteslice(512, 96) == hashes
      return 'H3 evidence reply reconstruction metadata rejected' unless evidence.byteslice(608, 32) == reply && evidence.byteslice(640, 8) == [16_352].pack('Q>')
      internal = 'EPRCUR02' + evidence.byteslice(8, 600) + page(reply)
      return 'H3 full internal cursor digest reconstruction rejected' unless internal.bytesize == 16_992 && sha(internal) == native.fetch('cursor_sha256') && evidence.byteslice(648, 32) == bytes(native.fetch('cursor_sha256'), 32)
      nil
    end
    def native_merkle(native, terminal, budget)
      cursor, checkpoint = bytes(native.fetch('cursor_sha256'), 32), bytes(native.fetch('checkpoint_reply_hex'), 32)
      leaves = { 'cursor_digest' => cursor, 'guest_image' => image, 'request' => frame([1, 1, 19, 23]) }
      if terminal
        leaves.merge!('schema' => TERMINAL_SCHEMA, 'checkpoint_reply' => checkpoint, 'final_reply' => bytes(native.fetch('final_reply_hex'), 32))
      else leaves.merge!('schema' => CP_SCHEMA, 'reply' => checkpoint)
      end
      merkle(leaves, budget)
    end
    def verification_error(native, checkpoint, transition, budget)
      o, s, t = native.values_at('outer', 'source', 'target')
      get = ->(key) { number(o, key) }
      pass_keys = %w[outcome execution_pass teardown_pass signing_admitted cursor_sealed cursor_decoded cursor_restored checkpoint_valid terminal_valid source_conserved target_conserved]
      return 'H3 native PASS predicates rejected' unless get.call('abi_version') == 5 && pass_keys.all? { |key| get.call(key) == 1 }
      return 'H3 cancellation/watchdog predicates rejected' unless %w[cancellation_requested cancellation_calls watchdog_fired resources_quarantined].all? { |key| get.call(key) == 0 } && get.call('watchdog_create_entries') == 2 && get.call('watchdog_join_entries') == 2
      return 'H3 outer native statuses rejected' unless %w[failure_stage first_error signing_error watchdog_create_status watchdog_join_status].all? { |key| get.call(key) == 0 } && get.call('cancellation_status') == SENTINEL && [SENTINEL, 0, 60].include?(get.call('watchdog_wait_status'))
      return 'H3 two-interval clock order rejected' unless get.call('start_ticks') > 0 && get.call('start_ticks') <= number(s, 'entry_ticks') && number(s, 'exit_ticks') <= number(t, 'entry_ticks') && number(t, 'exit_ticks') <= get.call('end_ticks') && get.call('timebase_numer') > 0 && get.call('timebase_denom') > 0
      [[s, 'checkpoint', 36, 0x10000050, 1], [t, 'terminal', 38, 0x1000007c, 2]].each do |phase, label, reads, pc, x4|
        budget.check
        return 'H3 ' + label + ' entry/conservation counters rejected' unless number(phase, 'run_entries') == 1 && number(phase, 'mappings_entered') == 3 && number(phase, 'register_set_calls') == 36 && number(phase, 'register_read_calls') == reads && number(phase, 'conserved') == 1
        statuses = %w[vm_create vcpu_create register run read_register vcpu_destroy vm_destroy].map { |key| number(phase, key + '_status') } + %w[map unmap host_unmap].flat_map { |key| phase.fetch(key + '_statuses') }
        return 'H3 ' + label + ' native status rejected' unless statuses.all?(&:zero?)
        dfsc = number(phase, 'syndrome') & 63
        return 'H3 ' + label + ' exit frame rejected' unless number(phase, 'generation') > 0 && number(phase, 'entry_ticks') > 0 && number(phase, 'entry_ticks') <= number(phase, 'exit_ticks') && number(phase, 'exception_reason') == 1 && (4..7).include?(dfsc) && number(phase, 'syndrome') == (0x93840040 | dfsc) && number(phase, 'pc') == pc && number(phase, 'fault_ipa') == 0x1000c000 && number(phase, 'fault_virtual_address') == 0x1000c000 && number(phase, 'x4') == x4
      end
      return 'H3 checkpoint diagnostic join rejected' unless checkpoint['integrity'] == 'VALID_PASS' && checkpoint['failures'].empty?
      return 'H3 SCTLR transition diagnostic join rejected' unless transition['integrity'] == 'VALID_FULL' && transition['failures'].empty?
      generation = number(s, 'generation')
      return 'H3 fresh phase-generation successor join rejected' unless generation.odd? && generation < 18_446_744_073_709_551_615 && number(t, 'generation') == generation + 1
      return 'H3 fixed image metadata rejected' unless image.bytesize == 136
      return 'H3 fixed image digest rejected' unless sha(image) == IMAGE_HASH
      return 'H3 cursor evidence length rejected' unless get.call('cursor_evidence_byte_count') == 680
      return 'H3 fixed reply frames rejected' unless bytes(native.fetch('checkpoint_reply_hex'), 32) == frame([1, 1, 42, 0]) && bytes(native.fetch('final_reply_hex'), 32) == frame([2, 1, 42, 43])
      error = cursor_error(native, budget)
      return error if error
      return 'H3 checkpoint Merkle reconstruction rejected' unless native_merkle(native, false, budget) == native.fetch('checkpoint_merkle_hex')
      return 'H3 terminal Merkle reconstruction rejected' unless native_merkle(native, true, budget) == native.fetch('terminal_merkle_hex')
      nil
    end
    def replay(native:, budget:)
      budget.check
      checkpoint, transition = checkpoint_assessment(native, budget), sctlr_assessment(native, budget)
      ready = readiness(budget)
      live = live_receipt(native, ready, budget)
      error = verification_error(native, checkpoint, transition, budget)
      passed = error.nil?
      o = native.fetch('outer')
      outcome = number(o, 'outcome')
      classification = outcome == 1 ? 'SWIFT_RECONSTRUCTION_REJECTION' : 'NATIVE_NONPASS'
      classification = 'NATIVE_WITNESS_MALFORMED' if checkpoint['integrity'] == 'MALFORMED' || transition['integrity'] == 'MALFORMED'
      detail = if passed
                 'Swift independently reconstructed the immutable checkpoint cursor at 42; the same reserved lifetime consumed it into one fresh VM/vCPU interval, reached 43, and conserved both intervals. No journal or durable receipt was opened.'
               elsif classification == 'NATIVE_NONPASS'
                 'H3 native execution returned non-PASS. Exact copied diagnostic fields are shown below. No PASS or durable evidence was published.'
               elsif classification == 'NATIVE_WITNESS_MALFORMED'
                 'H3 native checkpoint or SCTLR-transition witness was internally inconsistent. Raw copied values are retained below; no interpretation, PASS, or durable evidence was published.'
               else
                 'H3 native result did not satisfy independent Swift reconstruction: ' + error + '. No PASS or durable evidence was published.'
               end
      verifier = {
        'checkpoint_failures' => checkpoint['failures'], 'checkpoint_integrity' => checkpoint['integrity'],
        'checkpoint_root' => passed ? native.fetch('checkpoint_merkle_hex') : '', 'detail_sha256' => sha(detail),
        'disposition' => passed ? 'VERIFIED_PASS' : classification, 'durable' => false, 'graph_root' => passed ? live['graph_root'] : '',
        'h4_entered' => false, 'pre_entry_xor_post_exit' => transition['pre_entry_xor_post_exit'],
        'projection_root' => passed ? live['root'] : '', 'quarantined' => !passed && (number(o, 'resources_quarantined') != 0 || number(o, 'teardown_pass') != 1 || outcome == 5),
        'readiness_receipt_root' => passed ? ready['receipt_root'] : '', 'requested_xor_pre_entry' => transition['requested_xor_pre_entry'],
        'sctlr_transition_failures' => transition['failures'], 'sctlr_transition_integrity' => transition['integrity'],
        'status' => passed ? 'PASS' : { 2 => 'FAIL', 3 => 'CANCELED', 4 => 'BUSY', 5 => 'QUARANTINED' }.fetch(outcome, 'INCOMPLETE'),
        'terminal_root' => passed ? native.fetch('terminal_merkle_hex') : '', 'verifier_error_sha256' => sha(error || '') }
      conditions = {
        'swift.checkpoint_diagnostic' => checkpoint['integrity'] == 'VALID_PASS' && checkpoint['failures'].empty?,
        'swift.checkpoint_merkle' => native_merkle(native, false, budget) == native.fetch('checkpoint_merkle_hex'),
        'swift.cursor_reconstruction' => cursor_error(native, budget).nil?, 'swift.fixed_image' => image.bytesize == 136 && sha(image) == IMAGE_HASH,
        'swift.fixed_replies' => bytes(native.fetch('checkpoint_reply_hex'), 32) == frame([1, 1, 42, 0]) && bytes(native.fetch('final_reply_hex'), 32) == frame([2, 1, 42, 43]),
        'swift.live_graph' => live['graph_root'] == verifier['graph_root'], 'swift.live_projection' => live['root'] == verifier['projection_root'],
        'swift.live_receipt' => live['root'] == verifier['projection_root'] && ready['receipt_root'] == verifier['readiness_receipt_root'],
        'swift.readiness_contract' => ready.fetch(:verification) == { outcome: 'PASS_H3_CURSOR_CONTRACT_ONLY', gate_e: 'ABSTAIN', authority_vector: '00000000', vm_entry_count: 0, stage_completed: false, live_resume_authorized: false } &&
          %w[receipt_root cursor_root graph_root].all? { |key| /\A[0-9a-f]{64}\z/.match?(ready.fetch(key)) },
        'swift.sctlr_transition' => transition['integrity'] == 'VALID_FULL' && transition['failures'].empty?,
        'swift.terminal_merkle' => native_merkle(native, true, budget) == native.fetch('terminal_merkle_hex') }
      { verifier: verifier, conditions: conditions }
    end
    def checkpoint_assessment(native, budget)
      c, s, o = native.fetch('checkpoint'), native.fetch('source'), native.fetch('outer')
      get = ->(key) { number(c, key) }
      stage, valid = number(o, 'failure_stage'), number(o, 'checkpoint_valid')
      malformed, failures = [], []
      malformed << 'schema_version' unless get.call('schema_version') == 1
      malformed << 'required_mask' unless get.call('required_mask') == 511
      malformed << 'reserved_zero' unless get.call('reserved_zero') == 0
      evaluated, passed = get.call('evaluated_mask'), get.call('passed_mask')
      malformed << 'evaluated_unknown_bits' unless evaluated & ~511 == 0
      malformed << 'passed_outside_evaluated' unless passed & ~evaluated == 0
      malformed << 'partial_evaluation' unless [0, 511].include?(evaluated)
      gprs, pages = c.fetch('gprs').map { |value| number({ 'v' => value }, 'v') }, c.fetch('pages')
      malformed << 'fixed_array_width' unless gprs.length == 31 && pages.length == 3
      malformed << 'gpr_unknown_bit' unless get.call('gpr_mismatch_mask') & 0x80000000 == 0
      malformed << 'page_reserved_zero' if pages.any? { |w| w.fetch('reserved_zero') != 0 }
      traps = []
      dfsc = number(s, 'syndrome') & 63
      traps << 'trap.exception_reason' unless number(s, 'exception_reason') == 1
      traps << 'trap.syndrome' unless number(s, 'syndrome') == (0x93840040 | dfsc) && (4..7).include?(dfsc)
      { 'pc' => 0x10000050, 'fault_ipa' => 0x1000c000, 'fault_virtual_address' => 0x1000c000, 'x4' => 1 }.each do |key, value|
        budget.check
        traps << 'trap.' + (key == 'fault_virtual_address' ? 'fault_va' : key) unless number(s, key) == value
      end
      malformed << 'h3_unreachable_snapshot_stage' if stage == 12
      finish = lambda do |integrity|
        { 'integrity' => malformed.empty? ? integrity : 'MALFORMED', 'failures' => malformed.map { |name| 'malformed.' + name } + failures }
      end
      if evaluated == 0
        malformed << 'not_evaluated_after_checkpoint_stage' if (14..17).include?(stage) || (19..23).include?(stage)
        empty_pages = pages.all? { |w| w['first_mismatch_offset'] == U32_MAX && w['observed_byte'] == 0 && w['expected_byte'] == 0 }
        unless passed == 0 && get.call('gpr_mismatch_mask') == 0 && get.call('checkpoint_sequence') == 0 && gprs.all?(&:zero?) && %w[cpsr sctlr sp vbar].all? { |key| get.call(key) == 0 } && empty_pages
          malformed << 'not_evaluated_payload'
        end
        malformed << 'not_evaluated_checkpoint_valid' unless valid == 0
        if stage == 11
          failures.concat(traps)
          malformed << 'predicate_stage_without_trap_witness' if traps.empty?
        end
        return finish.call(stage == 11 ? 'VALID_FAILURE' : 'VALID_NOT_EVALUATED')
      end
      malformed << 'evaluated_at_admission_stage' if stage == 1
      malformed << 'evaluated_after_trap_failure' unless traps.empty?
      recomputed = 0
      if get.call('checkpoint_sequence') == 1 then recomputed |= 1 else failures << 'checkpoint.sequence' end
      expected_pages = [page(image), page(frame([1, 1, 19, 23])), page(frame([1, 1, 42, 0]))]
      if sha(image) == IMAGE_HASH
        pages.each_with_index do |witness, index|
          budget.check
          offset, observed, expected = witness.values_at('first_mismatch_offset', 'observed_byte', 'expected_byte')
          if offset == U32_MAX
            if observed == 0 && expected == 0 then recomputed |= 1 << (index + 1) else malformed << 'page_exact_payload_' + index.to_s end
          elsif offset < 16_384
            malformed << 'page_mismatch_payload_' + index.to_s if observed == expected || expected_pages.fetch(index).getbyte(offset) != expected
            failures << %w[checkpoint.code_page checkpoint.request_page checkpoint.reply_page].fetch(index)
          else malformed << 'page_mismatch_offset_' + index.to_s
          end
        end
      else malformed << 'fixed_page_identity'
      end
      if pages.length == 3
        reply = pages.fetch(2)
        sequence = get.call('checkpoint_sequence')
        if sequence != 1
          offset = (0...8).find { |index| ((sequence >> (index * 8)) & 255) != (index == 0 ? 1 : 0) }
          if offset.nil? || reply['first_mismatch_offset'] != offset
            malformed << 'sequence_reply_offset'
          elsif reply['observed_byte'] != ((sequence >> (offset * 8)) & 255) || reply['expected_byte'] != (offset == 0 ? 1 : 0)
            malformed << 'sequence_reply_value'
          end
        elsif reply['first_mismatch_offset'] < 8 then malformed << 'sequence_reply_exact_word'
        end
      end
      gpr_mask = 0
      gprs.each_with_index { |value, index| budget.check; gpr_mask |= 1 << index if value != GPRS.fetch(index) } if gprs.length == 31
      malformed << 'gpr_mismatch_mask' unless get.call('gpr_mismatch_mask') == gpr_mask
      if gpr_mask == 0 then recomputed |= 16 else failures << 'checkpoint.gprs' end
      [['cpsr', 0x600003c5, 5], ['sctlr', 0x30d00980, 6], ['sp', 0x1000bff0, 7], ['vbar', 0, 8]].each do |key, value, bit|
        budget.check
        if get.call(key) == value then recomputed |= 1 << bit else failures << 'checkpoint.' + key end
      end
      malformed << 'passed_mask' unless passed == recomputed
      failures.concat(traps)
      failures << 'checkpoint.register_set_calls' unless number(s, 'register_set_calls') == 36
      failures << 'checkpoint.register_read_calls' unless number(s, 'register_read_calls') == 36
      total = recomputed == 511 && traps.empty? && number(s, 'register_set_calls') == 36 && number(s, 'register_read_calls') == 36
      malformed << 'predicate_stage_without_failure' if stage == 11 && total
      if valid == 1
        malformed << 'checkpoint_valid_without_pass' unless total
        malformed << 'checkpoint_valid_with_predicate_failure' if stage == 11
      elsif stage != 11 || total then malformed << 'checkpoint_rejection_join'
      end
      malformed << 'checkpoint_valid_domain' if valid > 1
      finish.call(total ? 'VALID_PASS' : 'VALID_FAILURE')
    end
    def sctlr_assessment(native, budget)
      t, c, s, o = native.values_at('sctlr_transition', 'checkpoint', 'source', 'outer')
      get = ->(key) { number(t, key) }
      mask, schema = get.call('sampled_mask'), get.call('schema_version')
      pre, post = mask & 2 != 0, mask & 4 != 0
      requested_xor = pre ? get.call('requested') ^ get.call('source_pre_entry') : nil
      phase_xor = post ? get.call('source_pre_entry') ^ get.call('source_post_exit') : nil
      failures = []
      reject = ->(token) { budget.check; failures << 'malformed.sctlr_transition.' + token }
      finish = ->(integrity) { { 'integrity' => failures.empty? ? integrity : 'MALFORMED', 'failures' => failures, 'requested_xor_pre_entry' => requested_xor&.to_s, 'pre_entry_xor_post_exit' => phase_xor&.to_s } }
      evaluated = number(c, 'evaluated_mask') != 0
      stage, outcome = number(o, 'failure_stage'), number(o, 'outcome')
      entered = number(s, 'run_entries') == 1
      not_run = number(s, 'run_entries') == 0 && number(s, 'run_status') == SENTINEL
      returned = entered && number(s, 'run_status') == 0
      if schema == 0
        reject.call('inactive_payload') unless t.all? { |key, value| number(t, key) == 0 }
        stopped = stage == 0 && [4, 5].include?(outcome) || [1, 2, 3, 4, 5, 6, 7, 18].include?(stage)
        reject.call('zero_chronology') unless not_run && !evaluated && stopped
        requested_xor = phase_xor = nil
        return finish.call('VALID_NOT_SAMPLED')
      end
      reject.call('active_claim_outcome') if [4, 5].include?(outcome)
      reject.call('schema_version') unless schema == 1
      reject.call('sampled_unknown_bits') unless mask & ~7 == 0
      reject.call('sampled_dependency') unless [1, 3, 7].include?(mask)
      reject.call('reserved_zero') unless get.call('reserved_zero_0') == 0 && get.call('reserved_zero_1') == 0
      reject.call('requested') unless get.call('requested') == 0x30d00980
      reject.call('pre_entry_count_domain') if get.call('source_pre_entry_read_entries') > 1
      reject.call('post_exit_count_domain') if get.call('source_post_exit_read_entries') > 1
      [['pre_entry', pre], ['post_exit', post]].each do |phase, sampled|
        budget.check
        entries, status, value = get.call('source_' + phase + '_read_entries'), get.call('source_' + phase + '_read_status'), get.call('source_' + phase)
        if sampled
          reject.call(phase + '_success_join') unless entries == 1 && status == 0
        elsif entries == 0
          reject.call(phase + '_unentered_status') unless status == SENTINEL
          reject.call(phase + '_unsampled_value') unless value == 0
        else
          reject.call(phase + '_failure_status') if [0, SENTINEL].include?(status)
          reject.call(phase + '_failed_value') unless value == 0
        end
      end
      pre_failed = mask == 1 && get.call('source_pre_entry_read_entries') == 1 && ![0, SENTINEL].include?(get.call('source_pre_entry_read_status'))
      post_failed = mask == 3 && get.call('source_pre_entry_read_entries') == 1 && get.call('source_pre_entry_read_status') == 0 && get.call('source_post_exit_read_entries') == 1 && ![0, SENTINEL].include?(get.call('source_post_exit_read_status'))
      case mask
      when 1
        reject.call('pre_entry_failure_chronology') unless pre_failed && not_run && !evaluated && stage == 7
      when 3
        if post_failed
          reject.call('post_exit_failure_chronology') unless returned && !evaluated && stage == 10
        else
          stopped = not_run && [2, 8, 18].include?(stage) || entered && ![0, SENTINEL].include?(number(s, 'run_status')) && stage == 9
          reject.call('pre_entry_only_chronology') unless get.call('source_post_exit_read_entries') == 0 && !evaluated && stopped
        end
      when 7
        reject.call('full_without_successful_run') unless returned
        reject.call('full_at_admission_stage') if stage == 1
        reject.call('checkpoint_sctlr_join') if evaluated && get.call('source_post_exit') != number(c, 'sctlr')
      end
      reject.call('checkpoint_without_full_transition') if evaluated && mask != 7
      reject.call('successful_run_without_full_transition') if returned && mask != 7 && !post_failed
      reject.call('stage_zero_outcome') if stage == 0 && outcome != 1
      reject.call('pass_with_failure_stage') if outcome == 1 && stage != 0
      reject.call('pass_without_full_transition') if outcome == 1 && mask != 7
      finish.call(mask == 7 ? 'VALID_FULL' : 'VALID_PARTIAL')
    end
    def machine_state_copy(state, budget)
      budget.check
      keys = %w[left right accumulator next_ordinal schema]
      Check.that(state.instance_of?(Hash) && state.length == 5 && keys.all? { |key| state.key?(key) }, 'guest readiness fixed state keys')
      keys.each_with_object({}) do |key, owned|
        budget.check
        value = state.fetch(key)
        Check.that(value.instance_of?(String) && value.bytesize.between?(1, 256), 'guest readiness state scalar bound')
        owned[key.dup.freeze] = value.dup.freeze
      end.freeze
    end
    def machine_owner(identity, initial, budget = Budget.new)
      { identity: identity, state: machine_state_copy(initial, budget), trace: [], retired: false }
    end
    def machine_advance(owner, budget)
      budget.check
      Check.that(!owner.fetch(:retired), 'guest readiness retired owner')
      state = owner.fetch(:state)
      ordinal = number(state, 'next_ordinal')
      Check.that([0, 1].include?(ordinal), 'guest readiness terminal owner')
      accumulator = ordinal == 0 ? Check.u64(number(state, 'left') + number(state, 'right')) : Check.u64(number(state, 'accumulator') + 1)
      owner[:state] = machine_state_copy(state.merge('accumulator' => accumulator.to_s, 'next_ordinal' => (ordinal + 1).to_s), budget)
      owner[:trace] = owner.fetch(:trace) + [ordinal]
    end
    def machine_export(owner, checkpoint, budget)
      budget.check
      Check.that(!owner.fetch(:retired) && owner.fetch(:state) == checkpoint && owner.fetch(:trace) == [0], 'guest readiness export checkpoint')
      capability = { state: machine_state_copy(owner.fetch(:state), budget), disposition: :available }
      owner[:retired] = true
      capability
    end
    def machine_consume(capability, target, initial, budget)
      budget.check
      Check.that(capability.fetch(:disposition) == :available, 'guest readiness cursor consumed')
      capability[:disposition] = :claimed
      begin
        Check.that(capability.fetch(:state) == initial.merge('accumulator' => '42', 'next_ordinal' => '1'), 'guest readiness exact cursor state')
        Check.that(!target.fetch(:retired) && target.fetch(:trace).empty? && target.fetch(:state) == initial, 'guest readiness target not fresh')
        target[:state] = machine_state_copy(capability.fetch(:state), budget)
        machine_advance(target, budget)
        Check.that(target.fetch(:trace) == [1], 'guest readiness resume trace')
        capability[:disposition] = :consumed
      rescue Rejected
        capability[:disposition] = :poisoned
        raise
      end
    end
    def readiness(budget)
      # Reconstruct the fixed two-operation machine, single consume and immutable
      # evidence graph. These local values are not live execution capabilities.
      initial = { 'left' => '19', 'right' => '23', 'accumulator' => '0', 'next_ordinal' => '0', 'schema' => PREFIX + 'machine-state.v1' }
      checkpoint = initial.merge('accumulator' => (19 + 23).to_s, 'next_ordinal' => '1')
      terminal = checkpoint.merge('accumulator' => (checkpoint.fetch('accumulator').to_i + 1).to_s, 'next_ordinal' => '2')
      control, source, target, replay_target = (0..3).map { |id| budget.check; machine_owner(id, initial, budget) }
      2.times { machine_advance(control, budget) }
      machine_advance(source, budget)
      capability = machine_export(source, checkpoint, budget)
      machine_consume(capability, target, initial, budget)
      replay_rejected = false
      begin
        machine_consume(capability, replay_target, initial, budget)
      rescue Rejected
        replay_rejected = true
      end
      Check.that(source.fetch(:trace) + target.fetch(:trace) == control.fetch(:trace) &&
                 control.fetch(:state) == terminal && target.fetch(:state) == terminal && terminal['accumulator'] == '43' &&
                 source.fetch(:retired) && source.fetch(:identity) != target.fetch(:identity) &&
                 capability.fetch(:disposition) == :consumed && replay_rejected &&
                 replay_target.fetch(:state) == initial && replay_target.fetch(:trace).empty? &&
                 H2['h2_product_result_parent_commit'] == H2['h2_product_source_commit'], 'guest readiness value machine')
      effects = %w[clock_read environment_read file_read file_write journal_open network process_launch sqlite_open vm_launch].each_with_object({}) { |key, result| result[key] = false }
      input_semantic = H2.merge('authority_vector' => '00000000', 'archive_receipt_disposition' => 'EXTERNAL_COMMITTED_INPUT_PIN', 'effects' => effects, 'gate_e' => 'ABSTAIN', 'lineage_disposition' => 'EXACT_PARENT_RESULT_COMMIT_CONTAINS_RECEIPTS', 'schema' => PREFIX + 'input-state.v1', 'stage_id' => STAGE, 'status' => 'H2_PRODUCT_LOCAL_MECHANICS_PASS')
      cursor_semantic = H2.merge('base_state_root' => project(initial, initial['schema'], 'state', budget)['root'], 'checkpoint_state' => checkpoint, 'checkpoint_state_root' => project(checkpoint, checkpoint['schema'], 'state', budget)['root'], 'next_operation' => 'increment_checkpoint_once', 'next_ordinal' => '1', 'profile' => 'fixed-two-phase-19-plus-23-then-increment-v1', 'schema' => PREFIX + 'cursor.v1', 'source_generation' => 'h3-contract-source-owner-v1')
      input = project(input_semantic, input_semantic['schema'], 'state', budget)
      cursor = project(cursor_semantic, cursor_semantic['schema'], 'cursor', budget)
      results = {
        'h2_product_causal_lineage_exact' => H2.all? { |key, value| cursor_semantic[key] == value } && H2['h2_product_result_parent_commit'] == H2['h2_product_source_commit'],
        'cursor_schema_exact' => cursor_semantic['schema'] == PREFIX + 'cursor.v1' && cursor_semantic['profile'] == 'fixed-two-phase-19-plus-23-then-increment-v1',
        'checkpoint_state_exact' => capability.fetch(:state) == checkpoint && cursor_semantic['checkpoint_state'] == checkpoint && cursor_semantic['checkpoint_state_root'] == project(checkpoint, checkpoint['schema'], 'state', budget)['root'],
        'next_operation_exact' => cursor_semantic['next_ordinal'] == '1' && cursor_semantic['next_operation'] == 'increment_checkpoint_once',
        'source_owner_retired' => source.fetch(:retired),
        'fresh_owner_independent' => source.fetch(:identity) != target.fetch(:identity),
        'resume_not_reexecution' => source.fetch(:trace) == [0] && target.fetch(:trace) == [1],
        'control_resume_terminal_equal' => control.fetch(:state) == terminal && target.fetch(:state) == control.fetch(:state),
        'cursor_one_winner_no_replay' => capability.fetch(:disposition) == :consumed && replay_rejected && replay_target.fetch(:state) == initial && replay_target.fetch(:trace).empty?,
        'json_cbor_semantic_join' => JSONPreflight.new(cursor['json'], budget, maximum: 65_536).decode(canonical: true) == cursor_semantic && decode_cbor(cursor['cbor'], budget) == cursor_semantic,
        'merkle_ancestry_exact' => cursor_semantic['base_state_root'] == project(initial, initial['schema'], 'state', budget)['root'] && cursor['root'] == merkle({ 'schema' => cursor_semantic['schema'], 'cursor.json' => cursor['json'], 'cursor.cbor' => cursor['cbor'] }, budget),
        'no_live_or_durable_effects' => effects.values.all? { |value| value == false } && input_semantic['authority_vector'] == '00000000' && input_semantic['gate_e'] == 'ABSTAIN'
      }
      Check.that(results.keys == PREDICATES && results.values.all? { |value| value == true }, 'guest readiness all twelve predicates')
      witnesses = PREDICATES.each_with_index.map do |predicate, index|
        budget.check
        value = { 'authority_delta' => '00000000', 'cursor_root' => cursor['root'], 'observed' => results.fetch(predicate), 'outcome' => 'SATISFIED', 'position' => index.to_s, 'predicate_id' => predicate, 'producer_scope' => 'PURE_PRODUCT_CONTRACT', 'schema' => PREFIX + 'witness.v1', 'slice_id' => 'H3_CONTRACT_READINESS', 'stage_id' => STAGE, 'vm_disposition' => 'NOT_CREATED' }
        project(value, value['schema'], 'witness', budget)
      end
      transition_semantic = { 'authority_delta' => '00000000', 'combiner' => 'ALL_OF', 'cursor_root' => cursor['root'], 'derived_outcome' => 'PASS_H3_CURSOR_CONTRACT_ONLY', 'gate_e' => 'ABSTAIN', 'input_state_root' => input['root'], 'output_stage' => STAGE, 'predicates' => PREDICATES.each_with_index.map { |predicate, index| { 'outcome' => 'SATISFIED', 'position' => index.to_s, 'predicate_id' => predicate, 'witness_root' => witnesses[index]['root'] } }, 'schema' => PREFIX + 'transition.v1', 'successor_authorized' => false, 'vm_entry_count' => '0' }
      transition = project(transition_semantic, transition_semantic['schema'], 'transition', budget)
      output_semantic = { 'authority_vector' => '00000000', 'cursor_root' => cursor['root'], 'effects' => effects, 'gate_e' => 'ABSTAIN', 'next_stage' => 'NONE', 'parent_state_roots' => [input['root']], 'schema' => PREFIX + 'output-state.v1', 'stage_complete' => false, 'slice_id' => 'H3_CONTRACT_READINESS', 'stage_id' => STAGE, 'status' => 'PASS_H3_CURSOR_CONTRACT_ONLY', 'successor_authorized' => false, 'transition_root' => transition['root'], 'vm_entry_count' => '0' }
      output = project(output_semantic, output_semantic['schema'], 'state', budget)
      nodes = [node('input-state', 'evidence', 'state', input_semantic['schema'], input['root']), node('cursor', 'evidence', 'state-cursor', cursor_semantic['schema'], cursor['root'])]
      witnesses.each_with_index { |witness, index| budget.check; nodes << node('witness-' + index.to_s, 'evidence', 'witness', PREFIX + 'witness.v1', witness['root']) }
      nodes += [node('transition', 'transition', 'transition', transition_semantic['schema'], transition['root']), node('output-state', 'evidence', 'state', output_semantic['schema'], output['root'])]
      edges = [edge('input-state', 'transition', 0, 'INPUT_STATE'), edge('cursor', 'transition', 1, 'CURSOR_INPUT')]
      PREDICATES.each_with_index { |predicate, index| budget.check; edges << edge('witness-' + index.to_s, 'transition', index + 2, 'SATISFIES_PREDICATE', predicate) }
      edges << edge('transition', 'output-state', edges.length, 'DERIVES_OUTPUT_STATE')
      graph_semantic = { 'bipartite_rule' => 'EVIDENCE_TO_TRANSITION_OR_TRANSITION_TO_EVIDENCE_ONLY', 'edge_count' => edges.length.to_s, 'edges' => edges, 'node_count' => nodes.length.to_s, 'nodes' => nodes, 'schema' => PREFIX + 'graph.v1', 'stage_id' => STAGE }
      graph = project(graph_semantic, graph_semantic['schema'], 'graph', budget)
      leaves = { 'schema' => PREFIX + 'receipt.v1' }
      { 'cursor' => cursor_semantic, 'graph' => graph_semantic, 'state' => [input_semantic, output_semantic], 'transition' => transition_semantic, 'witnesses' => witnesses.map { |witness| witness['semantic'] } }.each do |role, semantic|
        budget.check
        leaves[role + '.json'] = Canonical.encode(semantic, budget)
        leaves[role + '.cbor'] = cbor(semantic, budget)
      end
      Check.that(output_semantic['status'] == 'PASS_H3_CURSOR_CONTRACT_ONLY' && output_semantic['gate_e'] == 'ABSTAIN' && output_semantic['authority_vector'] == '00000000' && output_semantic['vm_entry_count'] == '0' && output_semantic['stage_complete'] == false && output_semantic['successor_authorized'] == false, 'guest readiness authority boundary')
      { 'receipt_root' => merkle(leaves, budget), 'cursor_root' => cursor['root'], 'graph_root' => graph['root'],
        verification: { outcome: output_semantic['status'], gate_e: output_semantic['gate_e'], authority_vector: output_semantic['authority_vector'], vm_entry_count: output_semantic['vm_entry_count'].to_i, stage_completed: output_semantic['stage_complete'], live_resume_authorized: output_semantic['successor_authorized'] } }
    end
  end

  module BuildAudit
    module_function
    MANIFEST_KEYS = %w[artifacts builds dirty_guard products schema source source_state toolchain version].freeze
    PROCESS_KEYS = %w[child_pid exit_status kill_attempted kill_errno kill_return normal_exit observed_pipe_eof_count operation_deadline_tick output_overflow process_group_gone reap_tick reaped required_pipe_eof_count signal spawn_tick terminal_tick timebase_denominator timebase_numerator timed_out wait_status].freeze
    def object(value, keys, budget, label)
      budget.check
      Check.that(value.instance_of?(Hash) && value.keys.sort_by(&:b) == keys.sort_by(&:b), label + ' exact keys')
      value
    end
    def decode(bytes, budget, maximum: 262_144)
      value = JSONPreflight.new(bytes, budget, maximum: maximum).decode(canonical: true)
      Check.that(value.instance_of?(Hash), 'audit top-level object')
      value
    end
    def tick(value)
      Check.that(value.instance_of?(String) && /\A(?:0|[1-9][0-9]{0,19})\z/.match?(value), 'process canonical tick')
      Check.u64(value.to_i)
    end
    def process(value, seconds, eof_count, budget)
      object(value, PROCESS_KEYS, budget, 'successful process')
      Check.that(value['child_pid'].instance_of?(Integer) && value['child_pid'].between?(1, 2_147_483_647), 'process child PID')
      expected = { 'exit_status' => 0, 'kill_attempted' => false, 'kill_errno' => 0,
                   'kill_return' => -2_147_483_648, 'normal_exit' => true,
                   'observed_pipe_eof_count' => eof_count, 'output_overflow' => false,
                   'process_group_gone' => true, 'reaped' => true, 'required_pipe_eof_count' => eof_count,
                   'signal' => nil, 'timebase_denominator' => 1, 'timebase_numerator' => 1,
                   'timed_out' => false, 'wait_status' => 0 }
      expected.each { |key, item| budget.check; Check.that(value[key].class == item.class && value[key] == item, 'successful process ' + key) }
      spawn, reap, terminal, deadline = %w[spawn_tick reap_tick terminal_tick operation_deadline_tick].map { |key| budget.check; tick(value.fetch(key)) }
      Check.that(spawn > 0 && spawn < terminal && spawn <= reap && reap <= terminal && terminal <= deadline &&
                 deadline == Check.u64(spawn + seconds * 1_000_000_000), 'process chronology/deadline')
      value
    end
    def reference(observations, path, maximum, budget)
      budget.check
      observation = observations.fetch(path)
      bytes = observation.fetch('bytes')
      Check.that(bytes.instance_of?(String) && bytes.bytesize.between?(1, maximum) &&
                 observation.fetch('byte_count') == bytes.bytesize && observation.fetch('sha256') == Digest::SHA256.hexdigest(bytes), 'retained artifact bytes/count/hash')
      { 'byte_count' => bytes.bytesize, 'path' => path, 'sha256' => observation.fetch('sha256') }
    end
    def argv(configuration)
      Check.that(%w[DEBUG RELEASE].include?(configuration), 'build argv configuration')
      name = configuration == 'DEBUG' ? 'Debug' : 'Release'
      [OrdinaryCompatibility::XCODEBUILD, '-project', ROOT + '/ErgenticsProvenance.xcodeproj',
       '-scheme', 'ErgenticsProvenanceH3Qualification', '-configuration', name,
       '-destination', 'platform=macOS,arch=arm64', '-derivedDataPath', '/private/tmp/ergentics-h3q-' + name.downcase + '-v1',
       'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION', 'CODE_SIGNING_ALLOWED=YES', 'build']
    end
    def manifest_header(bytes, self_sha256, budget)
      value = object(decode(bytes, budget), MANIFEST_KEYS, budget, 'build manifest')
      Check.that(value['schema'] == 'com.ergentics.provenance.h3-qualification-build-source-manifest.v1' &&
                 value['version'].instance_of?(Integer) && value['version'] == 1, 'build manifest schema/version')
      source = value.fetch('source')
      Check.that(source.instance_of?(Hash) && source['delta_path_pins'].instance_of?(Array) && source['delta_path_pins'].length.between?(1, 17), 'manifest source pin array')
      pins = source['delta_path_pins'].select { |pin| budget.check; pin.instance_of?(Hash) && pin['path'] == SOURCE }
      Check.that(pins.length == 1 && pins[0] == { 'path' => SOURCE, 'sha256' => self_sha256 }, 'manifest/runtime seal source pin')
      value
    end
    def validate(observations, candidate_bytes, self_sha256, budget)
      source_state = decode(candidate_bytes, budget)
      Check.that(observations.fetch('source-state.json').fetch('bytes') == candidate_bytes, 'fresh source continuity canonical bytes')
      manifest = manifest_header(observations.fetch('build-source-manifest.json').fetch('bytes'), self_sha256, budget)
      Check.that(manifest['source'] == source_state.fetch('source') && manifest['dirty_guard'] == source_state.fetch('dirty_guard'), 'source manifest/state exact join')
      names = {
        'debug_build_log' => ['debug-build.log', 8_388_608], 'debug_build_settings' => ['debug-build-settings.json', 1_048_576],
        'debug_product_audit' => ['debug-product-audit.json', 262_144], 'release_build_log' => ['release-build.log', 8_388_608],
        'release_build_settings' => ['release-build-settings.json', 1_048_576], 'release_product_audit' => ['release-product-audit.json', 262_144],
        'source_state' => ['source-state.json', 262_144]
      }
      expected_refs = names.each_with_object({}) { |(key, (path, maximum)), out| budget.check; out[key] = reference(observations, path, maximum, budget) }
      Check.that(manifest['artifacts'] == expected_refs && manifest['source_state'] == expected_refs.fetch('source_state'), 'manifest exact artifact references')
      toolchain = manifest.fetch('toolchain')
      Check.that(toolchain.instance_of?(Hash) && toolchain == ToolchainProbes.validate(toolchain.fetch('probes'), budget), 'manifest independently parsed toolchain')
      Check.that(manifest['builds'].instance_of?(Array) && manifest['builds'].length == 2 &&
                 manifest['products'].instance_of?(Array) && manifest['products'].length == 2, 'manifest two configuration records')
      audits, settings = {}, {}
      %w[DEBUG RELEASE].each_with_index do |configuration, index|
        budget.check
        lower = configuration.downcase
        audit = decode(observations.fetch(lower + '-product-audit.json').fetch('bytes'), budget)
        Check.that(audit == ProductProbes.validate(audit.fetch('probes'), configuration, budget), 'independently parsed product audit')
        audits[configuration] = audit
        settings[configuration] = BuildSettings.validate(observations.fetch(lower + '-build-settings.json').fetch('bytes'),
                                                         configuration: configuration == 'DEBUG' ? 'Debug' : 'Release', ordinary: false, budget: budget)
        record = manifest.fetch('builds').fetch(index)
        object(record, %w[argv build_log build_process configuration cwd derived_data_path environment product_audit settings settings_argv settings_process settings_stderr], budget, 'build record')
        fixed_argv = argv(configuration)
        expected = {
          'argv' => fixed_argv, 'build_log' => expected_refs.fetch(lower + '_build_log'),
          'build_process' => process(record.fetch('build_process'), 900, 1, budget),
          'configuration' => configuration, 'cwd' => ROOT, 'derived_data_path' => fixed_argv[10], 'environment' => ENVIRONMENT,
          'product_audit' => expected_refs.fetch(lower + '_product_audit'), 'settings' => expected_refs.fetch(lower + '_build_settings'),
          'settings_argv' => fixed_argv + ['-showBuildSettings', '-json'],
          'settings_process' => process(record.fetch('settings_process'), 120, 2, budget), 'settings_stderr' => Canonical.stream(''.b)
        }
        Check.that(record == expected, 'build exact argv/context/process/reference join')
        pair = { 'application' => audit.fetch('application'), 'audit' => expected_refs.fetch(lower + '_product_audit'),
                 'configuration' => configuration, 'controller' => audit.fetch('controller') }
        Check.that(manifest.fetch('products').fetch(index) == pair, 'product pair independently parsed audit join')
      end
      { 'manifest' => manifest, 'source_state' => source_state, 'audits' => audits, 'settings' => settings }
    end
  end

  # Pure independent Ruby closure of retained campaign bytes. This module has
  # no file/process/native owner and cannot attest the sealer's later exit or
  # durability. The mode driver must separately establish fresh SourcePass
  # continuity and the foreground observation required by the frozen handoff.
  module CampaignEvidence
    module_function
    PRELAUNCH = SealedBuild::PRELAUNCH
    RUN_FILES = %w[inner-application-report.frame application-stderr.bin outer-observer-receipt.json manifest.json].freeze
    CLOSED_FILES = (RUN_FILES + ['seal-supervisor-receipt.json']).freeze
    PRIOR = %w[prior-admission-checkpoint.json prior-admission-verifier-supervisor.json prior-admission-campaign-seal.json].freeze
    CHECKPOINT_KEYS = %w[aggregates authority build_source_manifest campaign prior_admission result runs schema taxonomy verifier version].freeze
    RUN_KEYS = %w[application_cdhash application_executable_sha256 configuration controller_cdhash controller_executable_sha256 manifest nonce receipt run_id supervisor].freeze
    SUPERVISOR_KEYS = %w[argv build_source_manifest campaign campaign_checkpoint configuration controller_executable_after controller_executable_before controller_product_audit cwd descriptor_contract environment evidence_root_after_child evidence_root_before inventory_after_child inventory_before mode outer_receipt process result run_manifest schema seal_source_sha256 source_state version].freeze
    SEAL_KEYS = %w[build_source_manifest campaign campaign_checkpoint result run_supervisors schema seal_source_sha256 source_state verifier_supervisor version].freeze
    AUTHORITY = { 'authority_effect' => 'NONE', 'authority_vector' => '00000000', 'gate_e' => 'ABSTAIN',
                  'h4_entered' => false, 'prime_git_entered' => false, 'sqlite_opened' => false }.freeze

    def checked
      yield
    rescue KeyError, TypeError, NoMethodError, ArgumentError => error
      raise Rejected, 'campaign malformed input: ' + error.class.name
    end
    def object(value, keys, budget, label)
      Check.that(value.instance_of?(Hash) && value.length == keys.length, label + ' member bound')
      BuildAudit.object(value, keys, budget, label)
    end
    def integer(value, minimum, maximum, label)
      Check.that(value.instance_of?(Integer) && value.between?(minimum, maximum), label)
      value
    end
    def digest(value, label = 'campaign SHA256')
      Check.that(value.instance_of?(String) && /\A[0-9a-f]{64}\z/.match?(value), label)
      value
    end
    def mode_name(mode)
      Check.that(%w[ADMISSION GUEST].include?(mode), 'campaign mode')
      mode
    end
    def configuration_name(configuration)
      Check.that(%w[DEBUG RELEASE].include?(configuration), 'campaign configuration')
      configuration
    end
    def root(mode)
      '/private/tmp/ergentics-h3q-' + mode_name(mode).downcase + '-campaign-v1'
    end
    def checkpoint_name(mode)
      mode_name(mode).downcase + '-campaign-checkpoint.json'
    end
    def seal_name(mode)
      mode_name(mode).downcase + '-campaign-seal.json'
    end
    def input_names(mode)
      PRELAUNCH + (mode_name(mode) == 'GUEST' ? PRIOR : []) +
        %w[debug release].flat_map { |name| CLOSED_FILES.map { |leaf| name + '/' + leaf } }
    end
    def maximum(path)
      return 8_388_608 if %w[debug-build.log release-build.log].include?(path)
      return 1_048_576 if %w[debug-build-settings.json release-build-settings.json].include?(path)
      leaf = path.split('/').last
      return 65_552 if leaf == 'inner-application-report.frame'
      return 65_536 if %w[manifest.json application-stderr.bin].include?(leaf)
      return 131_072 if %w[outer-observer-receipt.json seal-supervisor-receipt.json campaign-verifier-supervisor.json prior-admission-verifier-supervisor.json].include?(leaf)
      262_144
    end
    def bytes(artifacts, path, budget)
      budget.check
      value = artifacts.fetch(path)
      minimum = path.end_with?('/application-stderr.bin') ? 0 : 1
      Check.that(value.instance_of?(String) && value.bytesize.between?(minimum, maximum(path)), 'campaign artifact byte bound')
      value
    end
    def inventory(artifacts, mode, budget, exact: nil, extras: [])
      budget.check
      Check.that(artifacts.instance_of?(Hash) && artifacts.length <= 24 && artifacts.keys.all? { |key| key.instance_of?(String) }, 'campaign byte map')
      allowed = input_names(mode) + extras
      Check.that((artifacts.keys - allowed).empty?, 'unexpected campaign artifact')
      Check.that(artifacts.keys.sort_by(&:b) == exact.sort_by(&:b), 'exact campaign artifact inventory') if exact
      artifacts.each_key { |path| bytes(artifacts, path, budget) }
      artifacts
    end
    def reference(artifacts, path, budget, claimed_path: path)
      value = bytes(artifacts, path, budget)
      Check.that(!value.empty?, 'nonempty referenced artifact')
      { 'byte_count' => value.bytesize, 'path' => claimed_path, 'sha256' => Digest::SHA256.hexdigest(value) }
    end
    def historical_reference(value, path, budget)
      object(value, %w[byte_count path sha256], budget, 'historical artifact reference')
      Check.that(value['path'] == path, 'historical exact relative path')
      integer(value['byte_count'], 1, maximum(path), 'historical artifact bound')
      digest(value['sha256'])
      value
    end
    def decode(artifacts, path, budget)
      BuildAudit.decode(bytes(artifacts, path, budget), budget, maximum: maximum(path))
    end
    def schema(value, suffix, keys, budget)
      object(value, keys, budget, suffix)
      Check.that(value['schema'] == 'com.ergentics.provenance.h3-qualification-' + suffix + '.v1' &&
                 value['version'].instance_of?(Integer) && value['version'] == 1, 'campaign schema/version')
      value
    end
    def encode(value, budget)
      result = Canonical.encode(value, budget)
      Check.that(result.bytesize.between?(1, 262_144), 'campaign output bound')
      result
    end
    def source_hash(manifest, budget)
      pins = manifest.fetch('source').fetch('delta_path_pins')
      Check.that(pins.instance_of?(Array) && pins.length.between?(1, 17), 'campaign source pin bound')
      selected = pins.select { |pin| budget.check; pin.instance_of?(Hash) && pin['path'] == SOURCE }
      Check.that(selected.length == 1, 'campaign exact seal source pin')
      object(selected[0], %w[path sha256], budget, 'seal source pin')
      digest(selected[0]['sha256'])
    end
    def build_audit(artifacts, budget)
      observations = PRELAUNCH.each_with_object({}) do |path, out|
        value = bytes(artifacts, path, budget)
        out[path] = { 'bytes' => value, 'byte_count' => value.bytesize, 'sha256' => Digest::SHA256.hexdigest(value) }
      end
      manifest = decode(artifacts, 'build-source-manifest.json', budget)
      # This repeats the byte/product/settings audit, not the fresh IO proof.
      # SourcePass's independently regenerated equality is enforced by driver.
      BuildAudit.validate(observations, bytes(artifacts, 'source-state.json', budget), source_hash(manifest, budget), budget)
    end
    def vnode(value, budget, directory: false)
      object(value, %w[device generation inode link_count mode owner], budget, 'controller file identity')
      %w[device inode link_count].each { |key| budget.check; BuildAudit.tick(value[key]) }
      integer(value['generation'], 0, 4_294_967_295, 'file generation')
      integer(value['owner'], 0, 4_294_967_295, 'file owner')
      integer(value['mode'], 0, 4_294_967_295, 'file mode')
      Check.that(value['owner'] == 501 && BuildAudit.tick(value['inode']) > 0 &&
                 (directory ? BuildAudit.tick(value['link_count']) >= 2 && value['mode'] == 448 :
                   value['link_count'] == '1' && value['mode'] <= 0o7777 && (value['mode'] & 0o022) == 0 && (value['mode'] & 0o111) != 0), 'file regular/directory policy')
      value
    end
    def controller_identity(value, code, budget)
      object(value, %w[code held_at_start named_at_start pid], budget, 'controller identity')
      integer(value['pid'], 1, 2_147_483_647, 'controller PID')
      vnode(value['held_at_start'], budget)
      Check.that(value['held_at_start'] == value['named_at_start'] && value['code'] == code, 'controller exact audited code/vnode')
      value
    end
    def seal_identity(value, path, budget, directory: false)
      keys = directory ? %w[device inode link_count mode owner path type] : %w[device inode link_count mode owner path sha256 size type]
      object(value, keys, budget, 'seal path identity')
      %w[device inode link_count].each { |key| budget.check; BuildAudit.tick(value[key]) }
      integer(value['owner'], 0, 4_294_967_295, 'seal identity owner')
      integer(value['mode'], 0, 4_294_967_295, 'seal identity mode')
      Check.that(value['path'] == path && value['owner'] == 501 && BuildAudit.tick(value['inode']) > 0, 'seal fixed path/owner/inode')
      if directory
        Check.that(value['type'] == 'DIRECTORY' && value['mode'] == 448 && BuildAudit.tick(value['link_count']) >= 2, 'seal directory policy')
      else
        Check.that(value['type'] == 'REGULAR' && value['link_count'] == '1' && value['mode'] <= 0o7777 &&
                   BuildAudit.tick(value['size']).between?(1, 67_108_864), 'seal executable policy')
        digest(value['sha256'])
      end
      value
    end
    def held_named(value, path, budget, directory: false)
      object(value, %w[held named], budget, 'seal held/named identity')
      seal_identity(value['held'], path, budget, directory: directory)
      Check.that(value['held'] == value['named'], 'seal held/named equality')
      value['held']
    end
    def process(value, result, verifying, budget)
      keys = BuildAudit::PROCESS_KEYS + %w[process_group stderr stdout]
      object(value, keys, budget, 'supervised controller process')
      pid = integer(value['child_pid'], 1, 2_147_483_647, 'supervised PID')
      status = %w[RETAINED_NONPASS FAIL_H3_GUEST_CAMPAIGN].include?(result) ? 65 : 0
      expected = { 'exit_status' => status, 'kill_attempted' => false, 'kill_errno' => 0, 'kill_return' => -2_147_483_648,
        'normal_exit' => true, 'observed_pipe_eof_count' => 2, 'output_overflow' => false, 'process_group' => pid,
        'process_group_gone' => true, 'reaped' => true, 'required_pipe_eof_count' => 2, 'signal' => nil,
        'stderr' => Canonical.stream(''.b), 'stdout' => Canonical.stream(''.b), 'timebase_denominator' => 1,
        'timebase_numerator' => 1, 'timed_out' => false, 'wait_status' => status << 8 }
      expected.each { |key, item| budget.check; Check.that(value[key].class == item.class && value[key] == item, 'supervised process ' + key) }
      spawn, reap, terminal, deadline = %w[spawn_tick reap_tick terminal_tick operation_deadline_tick].map { |key| budget.check; BuildAudit.tick(value[key]) }
      Check.that(spawn > 0 && spawn < reap && reap <= terminal && terminal <= deadline &&
                 deadline == Check.u64(spawn + (verifying ? 120 : 60) * 1_000_000_000), 'supervised chronology/deadline')
      value
    end
    def validate_supervisor(value:, artifacts:, mode:, configuration:, controller:, result:, budget:)
      checked do
        mode_name(mode)
        verifying = configuration.nil?
        config = verifying ? 'RELEASE' : configuration_name(configuration)
        name = verifying ? 'VERIFY_' + mode : 'RUN_' + mode + '_' + config
        allowed = verifying ? (mode == 'ADMISSION' ? ['PASS_ADMISSION_CAMPAIGN'] : %w[PASS_H3_GUEST_CAMPAIGN FAIL_H3_GUEST_CAMPAIGN]) : %w[RUN_CANDIDATE_PASS RETAINED_NONPASS]
        Check.that(allowed.include?(result), 'supervisor result role')
        schema(value, 'seal-supervisor-receipt', SUPERVISOR_KEYS, budget)
        context = build_audit(artifacts, budget)
        manifest = context.fetch('manifest')
        audit_path = config.downcase + '-product-audit.json'
        audit = context.fetch('audits').fetch(config)
        controller_identity(controller, audit.fetch('controller'), budget)
        process(value['process'], result, verifying, budget)
        path = root(mode) + (verifying ? '' : '/' + config.downcase)
        executable = ProductProbes.paths(config, false)[1]
        before = held_named(value['controller_executable_before'], executable, budget)
        root_identity = held_named(value['evidence_root_before'], path, budget, directory: true)
        Check.that(value['controller_executable_after'] == value['controller_executable_before'] &&
                   value['evidence_root_after_child'] == value['evidence_root_before'], 'supervisor terminal identities')
        Check.that(before['sha256'] == controller['code']['executable_sha256'] && value['process']['child_pid'] == controller['pid'], 'supervisor exact controller hash/PID')
        %w[device inode link_count owner].each { |key| budget.check; Check.that(before[key] == controller['held_at_start'][key], 'supervisor/controller vnode ' + key) }
        Check.that(before['mode'] == controller['held_at_start']['mode'], 'supervisor/controller permission mode')
        expected = { 'argv' => ControllerInvocation.argv(name.downcase), 'campaign' => mode, 'configuration' => configuration,
          'cwd' => '/private/var/empty', 'descriptor_contract' => 'STDIN_DEV_NULL_STDOUT_PIPE_STDERR_PIPE_CLOSE_OTHERS_FRESH_PGROUP',
          'environment' => [], 'mode' => name, 'result' => result, 'seal_source_sha256' => source_hash(manifest, budget),
          'build_source_manifest' => reference(artifacts, 'build-source-manifest.json', budget),
          'source_state' => reference(artifacts, 'source-state.json', budget),
          'controller_product_audit' => reference(artifacts, audit_path, budget) }
        if verifying
          checkpoint = schema(decode(artifacts, checkpoint_name(mode), budget), 'campaign-checkpoint', CHECKPOINT_KEYS, budget)
          Check.that(checkpoint['verifier'] == controller && checkpoint['result'] == result && checkpoint['campaign'] == mode,
                     'verifier supervisor checkpoint identity/result')
          before_names = (PRELAUNCH + (mode == 'GUEST' ? PRIOR : []) + %w[debug release]).sort_by(&:b)
          expected.merge!('inventory_before' => before_names, 'inventory_after_child' => (before_names + [checkpoint_name(mode)]).sort_by(&:b),
                          'campaign_checkpoint' => reference(artifacts, checkpoint_name(mode), budget), 'outer_receipt' => nil, 'run_manifest' => nil)
        else
          prefix = config.downcase + '/'
          expected.merge!('inventory_before' => [], 'inventory_after_child' => RUN_FILES.sort_by(&:b), 'campaign_checkpoint' => nil,
            'outer_receipt' => reference(artifacts, prefix + 'outer-observer-receipt.json', budget, claimed_path: 'outer-observer-receipt.json'),
            'run_manifest' => reference(artifacts, prefix + 'manifest.json', budget, claimed_path: 'manifest.json'))
          outer = decode(artifacts, prefix + 'outer-observer-receipt.json', budget)
          run_evidence = RunEvidence.validate(inner_bytes: bytes(artifacts, prefix + 'inner-application-report.frame', budget),
            outer_bytes: bytes(artifacts, prefix + 'outer-observer-receipt.json', budget), stderr_bytes: bytes(artifacts, prefix + 'application-stderr.bin', budget),
            mode: mode == 'ADMISSION' ? 'ADMISSION_ONLY' : 'GUEST', configuration: config, budget: budget)
          Check.that(run_evidence.fetch(:result) == result, 'run supervisor independent classification')
          Check.that(outer['controller_claim'] == controller && outer['classification']['result'] == result, 'supervisor exact outer identity/result')
          %w[device inode link_count owner].each { |key| budget.check; Check.that(root_identity[key] == outer['evidence']['root_identity'][key], 'supervisor/run root identity') }
          Check.that(root_identity['mode'] == outer['evidence']['root_identity']['mode'], 'supervisor/run root mode')
        end
        expected.each { |key, item| budget.check; Check.that(value[key].class == item.class && value[key] == item, 'supervisor fixed ' + key) }
        value
      end
    end

    def validate_run(artifacts:, mode:, configuration:, budget:, require_supervisor: false)
      checked do
        inventory(artifacts, mode, budget)
        configuration_name(configuration)
        context = build_audit(artifacts, budget)
        prior_closure(artifacts, context, budget) if mode == 'GUEST'
        validate_run_with_audit(artifacts, mode, configuration, context, budget, require_supervisor)
      end
    end
    def validate_run_with_audit(artifacts, mode, configuration, context, budget, require_supervisor)
      prefix = configuration.downcase + '/'
      leaf_names = artifacts.keys.select { |path| path.start_with?(prefix) }.map { |path| path.delete_prefix(prefix) }
      Check.that(leaf_names.sort_by(&:b) == (require_supervisor ? CLOSED_FILES : RUN_FILES).sort_by(&:b), 'exact selected run inventory')
      evidence = RunEvidence.validate(inner_bytes: bytes(artifacts, prefix + 'inner-application-report.frame', budget),
        outer_bytes: bytes(artifacts, prefix + 'outer-observer-receipt.json', budget), stderr_bytes: bytes(artifacts, prefix + 'application-stderr.bin', budget),
        mode: mode == 'ADMISSION' ? 'ADMISSION_ONLY' : 'GUEST', configuration: configuration, budget: budget)
      outer = evidence.fetch(:outer)
      audit = context.fetch('audits').fetch(configuration)
      Check.that(outer.fetch('application').fetch('pre_static') == audit.fetch('application'), 'run application/audit code')
      controller_identity(outer.fetch('controller_claim'), audit.fetch('controller'), budget)
      Check.that(outer['host']['architecture'] == context['manifest']['toolchain']['architecture'] &&
                 outer['host']['macos_build'] == context['manifest']['toolchain']['macos_build'], 'run observed host/build join')
      Check.that(outer['evidence']['build_source_manifest_sha256'] == reference(artifacts, 'build-source-manifest.json', budget)['sha256'] &&
                 outer['evidence']['product_audit_sha256'] == reference(artifacts, configuration.downcase + '-product-audit.json', budget)['sha256'], 'run prelaunch input hashes')
      manifest = schema(decode(artifacts, prefix + 'manifest.json', budget), 'manifest', %w[configuration files mode run_id schema version], budget)
      files = RUN_FILES[0, 3].map do |name|
        retained = bytes(artifacts, prefix + name, budget)
        { 'byte_count' => retained.bytesize, 'mode' => 384, 'path' => name, 'sha256' => Digest::SHA256.hexdigest(retained) }
      end
      Check.that(manifest['files'] == files && manifest['configuration'] == configuration && manifest['mode'] == outer['run']['mode'] &&
                 manifest['run_id'] == outer['run']['run_id'], 'run manifest prior-three-leaf DAG')
      supervisor = nil
      if require_supervisor
        supervisor = validate_supervisor(value: decode(artifacts, prefix + 'seal-supervisor-receipt.json', budget), artifacts: artifacts,
          mode: mode, configuration: configuration, controller: outer['controller_claim'], result: evidence.fetch(:result), budget: budget)
      end
      evidence.merge(run_manifest: manifest, supervisor: supervisor)
    end
    def run_id(mode, configuration, nonce)
      digest(nonce, 'run nonce')
      Digest::SHA256.hexdigest('com.ergentics.provenance.h3-qualification-run-id.v1'.b +
        [0, mode_name(mode) == 'ADMISSION' ? 1 : 2, configuration_name(configuration) == 'DEBUG' ? 1 : 2].pack('C*') + [nonce].pack('H*'))
    end
    def run_summary(evidence, artifacts, configuration, budget)
      outer = evidence.fetch(:outer)
      application = outer['application']['pre_static']
      controller = outer['controller_claim']['code']
      prefix = configuration.downcase + '/'
      { 'application_cdhash' => application['cdhash'], 'application_executable_sha256' => application['executable_sha256'],
        'configuration' => configuration, 'controller_cdhash' => controller['cdhash'], 'controller_executable_sha256' => controller['executable_sha256'],
        'manifest' => reference(artifacts, prefix + 'manifest.json', budget), 'nonce' => outer['run']['nonce'],
        'receipt' => reference(artifacts, prefix + 'outer-observer-receipt.json', budget), 'run_id' => outer['run']['run_id'],
        'supervisor' => reference(artifacts, prefix + 'seal-supervisor-receipt.json', budget) }
    end
    def checkpoint_object(mode, verifier, manifest_ref, runs, creates, entries, nonpass, prior)
      { 'aggregates' => { 'app_launches' => 2, 'guest_entries' => entries, 'helper_processes' => 0, 'hv_vm_creates' => creates,
                         'nonces_distinct' => true, 'signals' => 0, 'sqlite_opens' => 0 },
        'authority' => AUTHORITY, 'build_source_manifest' => manifest_ref, 'campaign' => mode, 'prior_admission' => prior,
        'result' => mode == 'ADMISSION' ? 'PASS_ADMISSION_CAMPAIGN' : nonpass ? 'FAIL_H3_GUEST_CAMPAIGN' : 'PASS_H3_GUEST_CAMPAIGN',
        'runs' => runs, 'schema' => 'com.ergentics.provenance.h3-qualification-campaign-checkpoint.v1',
        'taxonomy' => { 'app_launched' => true, 'authority_effect' => 'NONE', 'guest_entered_count' => entries, 'helper_processes' => 0,
          'hv_vm_created_count' => creates, 'runner_location' => 'EVALUATED_MAC_SIGNED_CAMPAIGN_VERIFIER', 'signals' => 0,
          'signing_state' => 'ADMITTED', 'sqlite_opened' => false, 'subject_location' => 'TWO_EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION_RUNS' },
        'verifier' => verifier, 'version' => 1 }
    end
    def validate_prior_closure(artifacts:, budget:)
      checked do
        inventory(artifacts, 'GUEST', budget)
        context = build_audit(artifacts, budget)
        prior_closure(artifacts, context, budget)
      end
    end
    def prior_closure(artifacts, context, budget)
      checkpoint = schema(decode(artifacts, PRIOR[0], budget), 'campaign-checkpoint', CHECKPOINT_KEYS, budget)
      runs = checkpoint['runs']
      Check.that(runs.instance_of?(Array) && runs.length == 2, 'prior exact run count')
      runs.each_with_index do |run, index|
        configuration = %w[DEBUG RELEASE][index]
        object(run, RUN_KEYS, budget, 'prior campaign run')
        prefix = configuration.downcase + '/'
        Check.that(run['configuration'] == configuration && run['run_id'] == run_id('ADMISSION', configuration, run['nonce']), 'prior run identity')
        %w[manifest receipt supervisor].zip(%w[manifest.json outer-observer-receipt.json seal-supervisor-receipt.json]).each do |field, name|
          historical_reference(run[field], prefix + name, budget)
        end
        audit = context['audits'][configuration]
        %w[application controller].each do |role|
          %w[cdhash executable_sha256].each { |field| budget.check; Check.that(run[role + '_' + field] == audit[role][field], 'prior same audited binary') }
        end
      end
      Check.that(runs.map { |run| run['nonce'] }.uniq.length == 2 && runs.map { |run| run['run_id'] }.uniq.length == 2, 'prior distinct nonces/IDs')
      controller_identity(checkpoint['verifier'], context['audits']['RELEASE']['controller'], budget)
      expected = checkpoint_object('ADMISSION', checkpoint['verifier'], reference(artifacts, 'build-source-manifest.json', budget), runs, 0, 0, false, nil)
      Check.that(checkpoint == expected, 'prior admission exact PASS checkpoint')
      aliased = artifacts.merge('admission-campaign-checkpoint.json' => bytes(artifacts, PRIOR[0], budget),
                               'campaign-verifier-supervisor.json' => bytes(artifacts, PRIOR[1], budget))
      supervisor = validate_supervisor(value: decode(artifacts, PRIOR[1], budget), artifacts: aliased, mode: 'ADMISSION', configuration: nil,
        controller: checkpoint['verifier'], result: checkpoint['result'], budget: budget)
      seal = schema(decode(artifacts, PRIOR[2], budget), 'campaign-seal', SEAL_KEYS, budget)
      expected_seal = seal_object('ADMISSION', checkpoint, reference(aliased, 'admission-campaign-checkpoint.json', budget),
        reference(aliased, 'campaign-verifier-supervisor.json', budget), reference(artifacts, 'build-source-manifest.json', budget),
        reference(artifacts, 'source-state.json', budget), source_hash(context['manifest'], budget))
      Check.that(seal == expected_seal && supervisor['seal_source_sha256'] == seal['seal_source_sha256'], 'prior admission acyclic seal closure')
      checkpoint
    end
    def build_checkpoint(artifacts:, mode:, verifier:, budget:)
      checked do
        inventory(artifacts, mode, budget, exact: input_names(mode))
        context = build_audit(artifacts, budget)
        controller_identity(verifier, context['audits']['RELEASE']['controller'], budget)
        prior_checkpoint = mode == 'GUEST' ? prior_closure(artifacts, context, budget) : nil
        runs, entries, creates, nonpass = [], 0, 0, false
        %w[DEBUG RELEASE].each do |configuration|
          budget.check
          evidence = validate_run_with_audit(artifacts, mode, configuration, context, budget, true)
          result = evidence.fetch(:result)
          Check.that(result == 'RUN_CANDIDATE_PASS' || (mode == 'GUEST' && evidence.fetch(:terminal_nonpass) == true &&
                     evidence.fetch(:outer).fetch('taxonomy').fetch('signing_state') == 'ADMITTED'), 'campaign eligible run classification')
          nonpass ||= result != 'RUN_CANDIDATE_PASS'
          creates = integer(creates + integer(evidence.fetch(:hv_vm_creates), 0, 2, 'run VM count'), 0, 4, 'campaign VM sum')
          entries = integer(entries + integer(evidence.fetch(:guest_entries), 0, 2, 'run guest count'), 0, 4, 'campaign guest sum')
          runs << run_summary(evidence, artifacts, configuration, budget)
        end
        all_runs = runs + (prior_checkpoint ? prior_checkpoint['runs'] : [])
        Check.that(all_runs.map { |run| run['nonce'] }.uniq.length == all_runs.length &&
                   all_runs.map { |run| run['run_id'] }.uniq.length == all_runs.length, 'all campaign nonces/run IDs pairwise distinct')
        Check.that(nonpass || (creates == (mode == 'GUEST' ? 4 : 0) && entries == (mode == 'GUEST' ? 4 : 0)), 'campaign PASS exact counts')
        prior = mode == 'GUEST' ? { 'checkpoint' => reference(artifacts, PRIOR[0], budget),
          'verifier_supervisor' => reference(artifacts, PRIOR[1], budget), 'campaign_seal' => reference(artifacts, PRIOR[2], budget) } : nil
        encode(checkpoint_object(mode, verifier, reference(artifacts, 'build-source-manifest.json', budget), runs, creates, entries, nonpass, prior), budget)
      end
    end
    def validate_checkpoint(bytes:, artifacts:, mode:, verifier:, budget:)
      checked do
        input = artifacts.dup
        if input.key?(checkpoint_name(mode))
          Check.that(input.delete(checkpoint_name(mode)) == bytes, 'checkpoint supplied bytes')
        end
        parsed = BuildAudit.decode(bytes, budget)
        expected = build_checkpoint(artifacts: input, mode: mode, verifier: verifier, budget: budget)
        Check.that(bytes == expected, 'checkpoint independently recomputed canonical bytes')
        parsed
      end
    end
    def seal_object(mode, checkpoint, checkpoint_ref, supervisor_ref, manifest_ref, source_ref, seal_hash)
      { 'build_source_manifest' => manifest_ref, 'campaign' => mode, 'campaign_checkpoint' => checkpoint_ref,
        'result' => checkpoint['result'], 'run_supervisors' => checkpoint['runs'].map { |run| run['supervisor'] },
        'schema' => 'com.ergentics.provenance.h3-qualification-campaign-seal.v1', 'seal_source_sha256' => seal_hash,
        'source_state' => source_ref, 'verifier_supervisor' => supervisor_ref, 'version' => 1 }
    end
    def build_seal(artifacts:, mode:, budget:)
      checked do
        additions = [checkpoint_name(mode), 'campaign-verifier-supervisor.json']
        inventory(artifacts, mode, budget, exact: input_names(mode) + additions, extras: additions)
        checkpoint = decode(artifacts, checkpoint_name(mode), budget)
        input = artifacts.reject { |key, _| additions.include?(key) }
        validate_checkpoint(bytes: bytes(artifacts, checkpoint_name(mode), budget), artifacts: input, mode: mode,
                            verifier: checkpoint.fetch('verifier'), budget: budget)
        supervisor = validate_supervisor(value: decode(artifacts, 'campaign-verifier-supervisor.json', budget), artifacts: artifacts,
          mode: mode, configuration: nil, controller: checkpoint['verifier'], result: checkpoint['result'], budget: budget)
        manifest = decode(artifacts, 'build-source-manifest.json', budget)
        Check.that(supervisor['seal_source_sha256'] == source_hash(manifest, budget), 'final seal source continuity')
        encode(seal_object(mode, checkpoint, reference(artifacts, checkpoint_name(mode), budget),
          reference(artifacts, 'campaign-verifier-supervisor.json', budget), reference(artifacts, 'build-source-manifest.json', budget),
          reference(artifacts, 'source-state.json', budget), source_hash(manifest, budget)), budget)
      end
    end
    def validate_seal(bytes:, artifacts:, mode:, budget:)
      checked do
        input = artifacts.dup
        Check.that(input.delete(seal_name(mode)) == bytes, 'seal supplied bytes') if input.key?(seal_name(mode))
        parsed = BuildAudit.decode(bytes, budget)
        Check.that(bytes == build_seal(artifacts: input, mode: mode, budget: budget), 'final seal independently recomputed canonical bytes')
        parsed
      end
    end
  end

  # One read-only admission of the exact next-mode root state. Each selected
  # campaign leaf is content-opened at most once; its retained bytes feed both
  # continuity and later audit/copy/evidence joins without duplicate reads.
  class CampaignSnapshot
    RUN_LEAVES = %w[application-stderr.bin inner-application-report.frame manifest.json outer-observer-receipt.json seal-supervisor-receipt.json].freeze
    PRIOR_LEAVES = %w[prior-admission-campaign-seal.json prior-admission-checkpoint.json prior-admission-verifier-supervisor.json].freeze
    STATES = {
      'run_admission_debug' => ['ADMISSION', 0, false], 'run_admission_release' => ['ADMISSION', 1, false],
      'verify_admission' => ['ADMISSION', 2, false], 'stage_guest' => ['ADMISSION', 2, true],
      'run_guest_debug' => ['GUEST', 0, false], 'run_guest_release' => ['GUEST', 1, false], 'verify_guest' => ['GUEST', 2, false]
    }.freeze
    attr_reader :parent, :root, :runs, :path, :observations, :source_bytes, :audit, :campaign, :expected_files, :root_entries
    def initialize(files, mode)
      @files, @budget, @mode = files, files.budget, mode
      @parent = @root = nil
      @runs, @observations = {}, {}
      Check.that(STATES.key?(mode), 'campaign snapshot exact mode')
      @campaign, closed, sealed = STATES.fetch(mode)
      basename = @campaign == 'ADMISSION' ? CampaignDirectory::ADMISSION : CampaignDirectory::GUEST
      @path = '/private/tmp/' + basename
      @parent = files.absolute('/private/tmp', directory: true, owner: 0)
      parent_identity = files.admit(@parent, directory: true, owner: 0)
      Check.that(parent_identity['mode'] == 0o1777 && parent_identity['nlink'] >= 2, 'snapshot parent policy')
      @root = files.relative(@parent, basename, directory: true)
      @root_identity = files.admit(@root, directory: true)
      directory_policy(@root_identity, parent_identity)
      %w[debug release].each do |name|
        @budget.check
        @runs[name] = files.relative(@root, name, directory: true)
        directory_policy(files.admit(@runs.fetch(name), directory: true), @root_identity)
      end
      @root_entries = SealedBuild::PRELAUNCH + (@campaign == 'GUEST' ? PRIOR_LEAVES : []) + %w[debug release]
      @root_entries += %w[admission-campaign-checkpoint.json admission-campaign-seal.json campaign-verifier-supervisor.json] if sealed
      @expected_files = @root_entries.reject { |name| %w[debug release].include?(name) }
      %w[debug release].each_with_index do |name, index|
        @budget.check
        leaves = index < closed ? RUN_LEAVES : []
        files.inventory(@runs.fetch(name), @path + '/' + name, leaves, maximum: 5)
        @expected_files += leaves.map { |leaf| name + '/' + leaf }
      end
      @expected_files.sort_by!(&:b)
      files.inventory(@root, @path, @root_entries, maximum: 16)
      expected_count = { 'run_admission_debug' => 8, 'run_admission_release' => 13, 'verify_admission' => 18,
                         'stage_guest' => 21, 'run_guest_debug' => 11, 'run_guest_release' => 16, 'verify_guest' => 21 }.fetch(mode)
      Check.that(@expected_files.length == expected_count, 'mode exact preflight file count')
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def read(path)
      @budget.check
      Check.that(@expected_files.include?(path) && !@observations.key?(path), 'one selected campaign content open')
      maximum = self.class.maximum(path)
      descriptor = @files.relative(@root, path)
      begin
        identity = @files.admit(descriptor)
        Check.that(identity['mode'] == 0o600 && identity['device'] == @root_identity['device'], 'campaign leaf mode/device')
        value = @files.hash(descriptor, maximum: maximum, retain: true)
        @observations[path] = value
      ensure
        Cleanup.close_all([descriptor], original_error: $!)
      end
      value
    end
    def continuity(supervisor, runtime)
      Check.that(@observations.empty?, 'continuity first two reads')
      manifest = read('build-source-manifest.json')
      state = read('source-state.json')
      BuildAudit.manifest_header(manifest.fetch('bytes'), runtime.self_sha256, @budget)
      source_pass = SourcePass.new(@files, supervisor, runtime.self_sha256)
      @source_bytes = source_pass.perform(independent_dirty_reads: false)
      Check.that(@source_bytes == state.fetch('bytes'), 'complete nine-probe source-state continuity')
      true
    end
    def complete_audit(runtime)
      Check.that(@source_bytes && @observations.keys.sort == %w[build-source-manifest.json source-state.json], 'continuity must precede remaining reads')
      @expected_files.each { |path| @budget.check; read(path) unless @observations.key?(path) }
      @audit = BuildAudit.validate(@observations, @source_bytes, runtime.self_sha256, @budget)
    end
    def self.maximum(path)
      basename = path.split('/').last
      return 8_388_608 if %w[debug-build.log release-build.log].include?(basename)
      return 1_048_576 if %w[debug-build-settings.json release-build-settings.json].include?(basename)
      return 65_552 if basename == 'inner-application-report.frame'
      return 65_536 if basename == 'application-stderr.bin'
      return 65_536 if basename == 'manifest.json'
      return 131_072 if %w[outer-observer-receipt.json seal-supervisor-receipt.json campaign-verifier-supervisor.json prior-admission-verifier-supervisor.json].include?(basename)
      262_144
    end
    def close
      owned = [@parent, @root].compact + (@runs || {}).values
      @runs, @root, @parent = {}, nil, nil
      Cleanup.close_all(owned)
    end
    private
    def directory_policy(identity, parent)
      Check.that(identity['mode'] == 0o700 && identity['nlink'] >= 2 && identity['device'] == parent['device'], 'snapshot directory policy')
    end
  end
  # BEGIN DORMANT H3 MODE DRIVER
  # Loading these definitions does not authorize or start an invocation. The
  # CLI dispatches only for the exact program identity. Separate operator launch
  # authorization and clean top-level pipe/exit/reap observation are not values
  # this interpreted program can manufacture from its own artifacts.
  module ModePlan
    module_function
    PLANS = {
      '--check-ordinary-compatibility' => { argument: '--check-ordinary-compatibility', name: 'check_ordinary_compatibility', kind: :ordinary, campaign: nil, configuration: nil, closed_runs: 0, children: 49, source_passes: 5 }.freeze,
      '--seal-admission' => { argument: '--seal-admission', name: 'seal_admission', kind: :seal, campaign: 'ADMISSION', configuration: nil, closed_runs: 0, children: 83, source_passes: 5 }.freeze,
      '--run-admission-debug' => { argument: '--run-admission-debug', name: 'run_admission_debug', kind: :run, campaign: 'ADMISSION', configuration: 'DEBUG', closed_runs: 0, children: 10, source_passes: 1 }.freeze,
      '--run-admission-release' => { argument: '--run-admission-release', name: 'run_admission_release', kind: :run, campaign: 'ADMISSION', configuration: 'RELEASE', closed_runs: 1, children: 10, source_passes: 1 }.freeze,
      '--verify-admission' => { argument: '--verify-admission', name: 'verify_admission', kind: :verify, campaign: 'ADMISSION', configuration: nil, closed_runs: 2, children: 10, source_passes: 1 }.freeze,
      '--stage-guest' => { argument: '--stage-guest', name: 'stage_guest', kind: :stage, campaign: 'GUEST', configuration: nil, closed_runs: 2, children: 33, source_passes: 1 }.freeze,
      '--run-guest-debug' => { argument: '--run-guest-debug', name: 'run_guest_debug', kind: :run, campaign: 'GUEST', configuration: 'DEBUG', closed_runs: 0, children: 10, source_passes: 1 }.freeze,
      '--run-guest-release' => { argument: '--run-guest-release', name: 'run_guest_release', kind: :run, campaign: 'GUEST', configuration: 'RELEASE', closed_runs: 1, children: 10, source_passes: 1 }.freeze,
      '--verify-guest' => { argument: '--verify-guest', name: 'verify_guest', kind: :verify, campaign: 'GUEST', configuration: nil, closed_runs: 2, children: 10, source_passes: 1 }.freeze
    }.freeze
    def resolve(argument, budget = Budget.new)
      budget.check
      Check.that(argument.instance_of?(String) && PLANS.key?(argument), 'driver exact mode argument')
      PLANS.fetch(argument)
    end
  end

  module LaunchContext
    module_function
    def validate(program:, arguments:, environment:, cwd:, uid:, budget:)
      RuntimePolicy.invocation(program: program, arguments: arguments, environment: environment,
        cwd: cwd, uid: uid, budget: budget)
    end
    def admit(budget)
      budget.check
      Check.that(ENV.length == 13, 'driver environment entry bound')
      environment = ENV.map { |key, value| budget.check; key + '=' + value }.sort_by(&:b)
      budget.check
      cwd = Dir.pwd
      budget.check
      uid = Process.euid
      validate(program: $PROGRAM_NAME, arguments: ARGV, environment: environment,
               cwd: cwd, uid: uid, budget: budget)
      # launch_context's fd0=/dev/null-ro, distinct capped nonblocking fd1/fd2,
      # closed other descriptors, and top-level EOF/exit/exact reap belong to
      # the foreground operator. There is no extra /dev/null open here and no
      # self-reported Boolean that substitutes for those outer observations.
    end
  end

  module ObservationWire
    module_function
    def file(observation, path, budget)
      budget.check
      Check.that(%w[DEBUG RELEASE].any? { |configuration| budget.check; path == ProductProbes.paths(configuration, false)[1] },
                 'driver fixed controller executable path')
      BuildAudit.object(observation, %w[byte_count bytes identity sha256], budget, 'driver executable observation')
      identity = observation.fetch('identity')
      BuildAudit.object(identity, %w[ctime_nsec device inode mode mtime_nsec nlink size type uid], budget, 'driver executable stat')
      Check.that(identity['type'] == 'file' && identity['uid'] == 501 && identity['nlink'] == 1 &&
                 identity['size'].instance_of?(Integer) && identity['size'].between?(1, 67_108_864) &&
                 identity['mode'].instance_of?(Integer) && identity['mode'].between?(0, 0o7777) &&
                 (identity['mode'] & 0o022) == 0 && (identity['mode'] & 0o111) != 0 &&
                 identity['mtime_nsec'].instance_of?(Integer) && identity['ctime_nsec'].instance_of?(Integer) &&
                 observation['byte_count'] == identity['size'] && observation['bytes'].nil?, 'driver executable policy/count')
      value = { 'device' => identity['device'], 'inode' => identity['inode'], 'link_count' => '1',
        'mode' => identity['mode'], 'owner' => identity['uid'], 'path' => path,
        'sha256' => observation['sha256'], 'size' => identity['size'].to_s, 'type' => 'REGULAR' }
      CampaignEvidence.seal_identity(value, path, budget)
    end
    def directory(identity, path, budget)
      budget.check
      allowed = %w[ADMISSION GUEST].flat_map do |campaign|
        budget.check
        root = CampaignEvidence.root(campaign)
        [root, root + '/debug', root + '/release']
      end
      Check.that(allowed.include?(path), 'driver fixed evidence directory path')
      BuildAudit.object(identity, %w[device inode mode nlink type uid], budget, 'driver directory stat')
      Check.that(identity['type'] == 'directory' && identity['uid'] == 501 && identity['mode'] == 0o700 &&
                 identity['nlink'].instance_of?(Integer) && identity['nlink'] >= 2, 'driver directory policy')
      value = { 'device' => identity['device'], 'inode' => identity['inode'], 'link_count' => identity['nlink'].to_s,
        'mode' => identity['mode'], 'owner' => identity['uid'], 'path' => path, 'type' => 'DIRECTORY' }
      CampaignEvidence.seal_identity(value, path, budget, directory: true)
    end
    def process(result, budget)
      budget.check
      BuildAudit.object(result, %w[process stderr stdout], budget, 'driver supervised result')
      Check.that(result['stdout'].instance_of?(String) && result['stdout'].empty? &&
                 result['stderr'].instance_of?(String) && result['stderr'].empty?, 'driver controller pipes must be empty')
      observed = result.fetch('process')
      BuildAudit.object(observed, BuildAudit::PROCESS_KEYS, budget, 'driver supervised process')
      CampaignEvidence.integer(observed['child_pid'], 1, 2_147_483_647, 'driver exact controller PID')
      Check.that(observed['exit_status'].instance_of?(Integer) && [0, 65].include?(observed['exit_status']), 'driver controller exit domain')
      observed.merge('process_group' => observed['child_pid'], 'stdout' => Canonical.stream(result['stdout']),
                     'stderr' => Canonical.stream(result['stderr']))
    end
    def controller_claim(claim, code, observed_file, pid, budget)
      budget.check
      CampaignEvidence.controller_identity(claim, code, budget)
      Check.that(claim['pid'] == pid && observed_file['sha256'] == code['executable_sha256'] &&
                 observed_file['path'] == code['executable_path'], 'driver actual controller PID/code/path join')
      %w[device inode link_count mode owner].each do |key|
        budget.check
        Check.that(observed_file[key] == claim['held_at_start'][key], 'driver observed controller vnode ' + key)
      end
      # st_gen is validated only as the controller's own bounded scalar claim.
      # Ruby File::Stat supplies no generation field and makes no such claim.
      claim
    end
  end

  class ArtifactIO
    attr_reader :artifacts
    def self.retained(observations, budget)
      budget.check
      Check.that(observations.instance_of?(Hash) && observations.length <= 24, 'driver retained file-map bound')
      observations.each_with_object({}) do |(path, value), result|
        budget.check
        Check.that(path.instance_of?(String) && value.instance_of?(Hash), 'driver retained artifact shape')
        raw = value.fetch('bytes')
        Check.that(raw.instance_of?(String) && raw.bytesize <= CampaignSnapshot.maximum(path) &&
                   value.fetch('byte_count') == raw.bytesize && value.fetch('sha256') == Digest::SHA256.hexdigest(raw),
                   'driver retained artifact count/hash')
        result[path] = raw
      end
    end
    def initialize(files, snapshot, plan)
      @files, @snapshot, @plan, @budget = files, snapshot, plan, files.budget
      @budget.check
      Check.that([:run, :verify].include?(plan[:kind]), 'driver artifact mode')
      @artifacts = self.class.retained(snapshot.observations, @budget)
      @attempted_reads, @attempted_writes, @published = {}, {}, 0
      if plan[:kind] == :run
        prefix = plan.fetch(:configuration).downcase + '/'
        @reads = CampaignEvidence::RUN_FILES.map { |name| @budget.check; prefix + name }
        @writes = [prefix + 'seal-supervisor-receipt.json']
        @directory = snapshot.runs.fetch(plan[:configuration].downcase)
      else
        @reads = [CampaignEvidence.checkpoint_name(plan[:campaign])]
        @writes = ['campaign-verifier-supervisor.json', CampaignEvidence.seal_name(plan[:campaign])]
        @directory = snapshot.root
      end
    end
    def read_created(path)
      @budget.check
      Check.that(@reads.include?(path) && !@attempted_reads.key?(path) && !@artifacts.key?(path), 'driver one exact new artifact read')
      @attempted_reads[path] = true
      leaf = path.split('/').last
      root_identity = @files.admit(@directory, directory: true)
      io = @files.relative(@directory, leaf)
      begin
        identity = @files.admit(io)
        Check.that(identity['mode'] == 0o600 && identity['device'] == root_identity['device'], 'driver new artifact mode/device')
        observation = @files.hash(io, maximum: CampaignSnapshot.maximum(path), retain: true)
      ensure
        Cleanup.close_all([io], original_error: $!)
      end
      @budget.check
      @artifacts[path] = observation.fetch('bytes')
    end
    def publish(path, bytes)
      @budget.check
      Check.that(@writes[@published] == path && !@attempted_writes.key?(path) && !@artifacts.key?(path), 'driver publication exact order/once')
      Check.that(bytes.instance_of?(String) && bytes.bytesize.between?(1, CampaignSnapshot.maximum(path)), 'driver publication byte bound')
      @attempted_writes[path] = true
      leaf = path.split('/').last
      reference = ImmutableArtifact.write(@files, @directory, leaf, bytes,
        maximum: CampaignSnapshot.maximum(path), sync_directory: true)
      Check.that(reference == { 'byte_count' => bytes.bytesize, 'path' => leaf, 'sha256' => Digest::SHA256.hexdigest(bytes) },
                 'driver durable publication reference')
      @budget.check
      @artifacts[path] = bytes
      @published += 1
      reference
    end
  end

  class ControllerObservation
    attr_reader :argv, :code, :before, :after, :root_before, :root_after
    def initialize(files, snapshot, plan)
      @files, @snapshot, @budget = files, snapshot, files.budget
      @held = nil
      @budget.check
      Check.that([:run, :verify].include?(plan[:kind]) && snapshot.campaign == plan[:campaign], 'driver observed controller mode/root')
      @argv = ControllerInvocation.argv(plan.fetch(:name))
      configuration = plan[:kind] == :verify ? 'RELEASE' : plan.fetch(:configuration)
      @code = snapshot.audit.fetch('audits').fetch(configuration).fetch('controller')
      @executable = ProductProbes.paths(configuration, false)[1]
      Check.that(@argv[0] == @executable && @code.fetch('executable_path') == @executable, 'driver audited executable path')
      @relative = @executable.delete_prefix('/private/tmp/')
      @held, @first = files.pair(snapshot.parent, @relative, minimum: 1, maximum: 67_108_864)
      observed = ObservationWire.file(@first, @executable, @budget)
      Check.that(observed['sha256'] == @code.fetch('executable_sha256'), 'driver pre-spawn controller SHA256')
      @before = { 'held' => observed, 'named' => observed.dup }
      @root_path = @argv.fetch(2)
      @root_descriptor = plan[:kind] == :verify ? snapshot.root : snapshot.runs.fetch(configuration.downcase)
      @root_before = observe_root
      @completion_attempted = false
    rescue Exception
      Cleanup.attempts(original_error: $!) { |attempt| attempt.call { close } }
      raise
    end
    def complete
      @budget.check
      Check.that(@held && !@completion_attempted, 'driver one post-reap controller observation')
      @completion_attempted = true
      held = @files.hash(@held, minimum: 1, maximum: 67_108_864, rewind: true)
      named = @files.observe(@snapshot.parent, @relative, minimum: 1, maximum: 67_108_864)
      Check.that(held == @first && named == @first, 'driver post-reap held/named controller bytes/stat')
      @after = { 'held' => ObservationWire.file(held, @executable, @budget),
                 'named' => ObservationWire.file(named, @executable, @budget) }
      @root_after = observe_root
      Check.that(@before == @after && @root_before == @root_after, 'driver terminal controller/root equality')
      true
    end
    def close
      owned = @held
      @held = nil
      owned.close if owned && !owned.closed?
    end
    private
    def observe_root
      @budget.check
      held = @files.admit(@root_descriptor, directory: true)
      named_descriptor = @files.relative(@snapshot.parent, @root_path.delete_prefix('/private/tmp/'), directory: true)
      begin
        named = @files.admit(named_descriptor, directory: true)
        Check.that(held == named && @files.identity(@root_descriptor, directory: true) == held, 'driver held/named evidence root')
      ensure
        Cleanup.close_all([named_descriptor], original_error: $!)
      end
      { 'held' => ObservationWire.directory(held, @root_path, @budget),
        'named' => ObservationWire.directory(named, @root_path, @budget) }
    end
  end

  module SupervisorReceipt
    module_function
    def build(plan:, artifacts:, controller:, result:, process:, executable_before:, executable_after:,
              root_before:, root_after:, inventory_before:, inventory_after:, seal_source_sha256:, budget:)
      budget.check
      Check.that(plan == ModePlan.resolve(plan.fetch(:argument), budget) && [:run, :verify].include?(plan[:kind]), 'driver receipt exact mode')
      verifying = plan[:kind] == :verify
      campaign, configuration = plan.values_at(:campaign, :configuration)
      selected_configuration = verifying ? 'RELEASE' : configuration
      value = {
        'argv' => ControllerInvocation.argv(plan[:name]),
        'build_source_manifest' => CampaignEvidence.reference(artifacts, 'build-source-manifest.json', budget),
        'campaign' => campaign,
        'campaign_checkpoint' => verifying ? CampaignEvidence.reference(artifacts, CampaignEvidence.checkpoint_name(campaign), budget) : nil,
        'configuration' => configuration, 'controller_executable_after' => executable_after,
        'controller_executable_before' => executable_before,
        'controller_product_audit' => CampaignEvidence.reference(artifacts, selected_configuration.downcase + '-product-audit.json', budget),
        'cwd' => '/private/var/empty',
        'descriptor_contract' => 'STDIN_DEV_NULL_STDOUT_PIPE_STDERR_PIPE_CLOSE_OTHERS_FRESH_PGROUP',
        'environment' => [], 'evidence_root_after_child' => root_after, 'evidence_root_before' => root_before,
        'inventory_after_child' => inventory_after, 'inventory_before' => inventory_before,
        'mode' => plan[:name].upcase, 'outer_receipt' => nil, 'process' => process, 'result' => result,
        'run_manifest' => nil, 'schema' => 'com.ergentics.provenance.h3-qualification-seal-supervisor-receipt.v1',
        'seal_source_sha256' => seal_source_sha256,
        'source_state' => CampaignEvidence.reference(artifacts, 'source-state.json', budget), 'version' => 1
      }
      unless verifying
        prefix = configuration.downcase + '/'
        value['outer_receipt'] = CampaignEvidence.reference(artifacts, prefix + 'outer-observer-receipt.json', budget, claimed_path: 'outer-observer-receipt.json')
        value['run_manifest'] = CampaignEvidence.reference(artifacts, prefix + 'manifest.json', budget, claimed_path: 'manifest.json')
      end
      CampaignEvidence.validate_supervisor(value: value, artifacts: artifacts, mode: campaign, configuration: configuration,
        controller: controller, result: result, budget: budget)
      bytes = Canonical.encode(value, budget)
      Check.that(bytes.bytesize.between?(1, 131_072), 'driver supervisor receipt byte bound')
      Check.that(BuildAudit.decode(bytes, budget, maximum: 131_072) == value, 'driver supervisor canonical reparse')
      bytes
    end
  end

  class PostSealMode
    def initialize(files, supervisor, runtime, plan)
      @files, @supervisor, @runtime, @plan, @budget = files, supervisor, runtime, plan, files.budget
      @budget.check
      Check.that(plan == ModePlan.resolve(plan.fetch(:argument), @budget) && [:run, :verify, :stage].include?(plan[:kind]), 'driver post-seal exact mode')
    end
    def run
      snapshot = guest = nil
      @budget.check
      snapshot = CampaignSnapshot.new(@files, @plan.fetch(:name))
      snapshot.continuity(@supervisor, @runtime)
      # manifest_and_staging fixes this ordering: continuity first, creation of
      # the distinct fresh guest root next, then the remaining 19 admission
      # input reads and full DAG validation before any copy. An invalid later
      # input retains only that incomplete fresh prefix; nothing is repaired.
      if @plan[:kind] == :stage
        guest = CampaignDirectory.new(@files, snapshot.parent, CampaignDirectory::GUEST)
      end
      snapshot.complete_audit(@runtime)
      artifacts = ArtifactIO.retained(snapshot.observations, @budget)
      prior_identities = precondition(artifacts)
      case @plan[:kind]
      when :run then run_controller(snapshot, prior_identities)
      when :verify then verify_controller(snapshot)
      when :stage then stage_guest(snapshot, guest, artifacts)
      else raise Rejected, 'driver post-seal unreachable mode'
      end
    ensure
      original_error = $!
      cleanup_error = nil
      [guest, snapshot].each do |owned|
        begin
          owned.close if owned
        rescue Exception => error
          cleanup_error ||= error
        end
      end
      raise cleanup_error if cleanup_error && original_error.nil?
    end
    private
    def eligible_run(evidence, campaign)
      @budget.check
      result = evidence.fetch(:result)
      Check.that(result == 'RUN_CANDIDATE_PASS' ||
                 (result == 'RETAINED_NONPASS' && evidence.fetch(:terminal_nonpass) == true), 'driver eligible closed run')
      Check.that(campaign != 'GUEST' || evidence.fetch(:outer).fetch('taxonomy').fetch('signing_state') == 'ADMITTED',
                 'driver guest closed-run signing')
      result
    end
    def identities_distinct(identities)
      @budget.check
      Check.that(identities.length <= 4, 'driver run identity count bound')
      nonces, ids = [], []
      identities.each do |identity|
        @budget.check
        nonces << CampaignEvidence.digest(identity.fetch('nonce'), 'driver nonce')
        ids << CampaignEvidence.digest(identity.fetch('run_id'), 'driver run id')
      end
      Check.that(nonces.uniq.length == nonces.length && ids.uniq.length == ids.length, 'driver all retained nonces/run IDs distinct')
      true
    end
    def precondition(artifacts)
      @budget.check
      if @plan[:kind] == :stage
        seal = CampaignEvidence.validate_seal(bytes: artifacts.fetch('admission-campaign-seal.json'),
          artifacts: artifacts, mode: 'ADMISSION', budget: @budget)
        Check.that(seal['result'] == 'PASS_ADMISSION_CAMPAIGN', 'driver stage requires complete admission PASS seal')
        # The additional clean top-level admission-verifier observation remains
        # operator-retained. Neither this DAG nor an in-process flag asserts it.
        return []
      end
      identities = []
      if @plan[:campaign] == 'GUEST'
        prior = CampaignEvidence.validate_prior_closure(artifacts: artifacts, budget: @budget)
        prior.fetch('runs').each { |run| @budget.check; identities << run }
      end
      @plan.fetch(:closed_runs).times do |index|
        @budget.check
        configuration = %w[DEBUG RELEASE].fetch(index)
        evidence = CampaignEvidence.validate_run(artifacts: artifacts, mode: @plan[:campaign],
          configuration: configuration, budget: @budget, require_supervisor: true)
        result = eligible_run(evidence, @plan[:campaign])
        Check.that(@plan[:campaign] != 'ADMISSION' || result == 'RUN_CANDIDATE_PASS', 'driver terminal admission non-PASS forbids continuation')
        identities << evidence.fetch(:outer).fetch('run')
      end
      identities_distinct(identities)
      identities
    end
    def inventories(snapshot, root_names, selected_run_files = nil)
      @budget.check
      @files.inventory(snapshot.root, snapshot.path, root_names, maximum: 16)
      %w[debug release].each_with_index do |name, index|
        @budget.check
        leaves = if @plan[:kind] == :run && name == @plan[:configuration].downcase
                   selected_run_files || []
                 else
                   index < @plan[:closed_runs] ? CampaignSnapshot::RUN_LEAVES : []
                 end
        @files.inventory(snapshot.runs.fetch(name), snapshot.path + '/' + name, leaves, maximum: 5)
      end
      true
    end
    def invoke(snapshot)
      @budget.check
      observation = ControllerObservation.new(@files, snapshot, @plan)
      begin
        raw = @supervisor.run(observation.argv, cwd: '/private/var/empty',
          seconds: @plan[:kind] == :verify ? 120 : 60, maximum: 65_536,
          accepted_statuses: [0, 65], controller: true)
        process = ObservationWire.process(raw, @budget)
        observation.complete
      ensure
        original_error = $!
        begin
          observation.close
        rescue Exception => close_error
          raise close_error if original_error.nil?
        end
      end
      [observation, process]
    end
    def receipt(artifacts, observation, process, controller, result, before_names, after_names)
      @budget.check
      ObservationWire.controller_claim(controller, observation.code, observation.before.fetch('held'), process.fetch('child_pid'), @budget)
      SupervisorReceipt.build(plan: @plan, artifacts: artifacts, controller: controller, result: result, process: process,
        executable_before: observation.before, executable_after: observation.after,
        root_before: observation.root_before, root_after: observation.root_after,
        inventory_before: before_names, inventory_after: after_names,
        seal_source_sha256: @runtime.self_sha256, budget: @budget)
    end
    def run_controller(snapshot, prior_identities)
      @budget.check
      io = ArtifactIO.new(@files, snapshot, @plan)
      prefix = @plan.fetch(:configuration).downcase + '/'
      inventories(snapshot, snapshot.root_entries, [])
      observation, process = invoke(snapshot)
      four = CampaignEvidence::RUN_FILES.sort_by(&:b)
      inventories(snapshot, snapshot.root_entries, four)
      CampaignEvidence::RUN_FILES.each { |name| @budget.check; io.read_created(prefix + name) }
      evidence = CampaignEvidence.validate_run(artifacts: io.artifacts, mode: @plan[:campaign],
        configuration: @plan[:configuration], budget: @budget, require_supervisor: false)
      result = eligible_run(evidence, @plan[:campaign])
      identities_distinct(prior_identities + [evidence.fetch(:outer).fetch('run')])
      CampaignEvidence.process(process, result, false, @budget)
      controller = evidence.fetch(:outer).fetch('controller_claim')
      bytes = receipt(io.artifacts, observation, process, controller, result, [], four)
      io.publish(prefix + 'seal-supervisor-receipt.json', bytes)
      inventories(snapshot, snapshot.root_entries, CampaignSnapshot::RUN_LEAVES)
      CampaignEvidence.validate_run(artifacts: io.artifacts, mode: @plan[:campaign],
        configuration: @plan[:configuration], budget: @budget, require_supervisor: true)
      result == 'RUN_CANDIDATE_PASS' ? 0 : 65
    end
    def verify_controller(snapshot)
      @budget.check
      io = ArtifactIO.new(@files, snapshot, @plan)
      before_names = snapshot.root_entries.sort_by(&:b)
      inventories(snapshot, before_names)
      observation, process = invoke(snapshot)
      checkpoint_name = CampaignEvidence.checkpoint_name(@plan[:campaign])
      after_names = (before_names + [checkpoint_name]).sort_by(&:b)
      inventories(snapshot, after_names)
      checkpoint_bytes = io.read_created(checkpoint_name)
      checkpoint = BuildAudit.decode(checkpoint_bytes, @budget)
      controller = checkpoint.fetch('verifier')
      ObservationWire.controller_claim(controller, observation.code, observation.before.fetch('held'), process.fetch('child_pid'), @budget)
      checkpoint = CampaignEvidence.validate_checkpoint(bytes: checkpoint_bytes, artifacts: io.artifacts,
        mode: @plan[:campaign], verifier: controller, budget: @budget)
      result = checkpoint.fetch('result')
      CampaignEvidence.process(process, result, true, @budget)
      supervisor_bytes = receipt(io.artifacts, observation, process, controller, result, before_names, after_names)
      io.publish('campaign-verifier-supervisor.json', supervisor_bytes)
      seal_bytes = CampaignEvidence.build_seal(artifacts: io.artifacts, mode: @plan[:campaign], budget: @budget)
      seal_name = CampaignEvidence.seal_name(@plan[:campaign])
      io.publish(seal_name, seal_bytes)
      inventories(snapshot, after_names + ['campaign-verifier-supervisor.json', seal_name])
      CampaignEvidence.validate_seal(bytes: seal_bytes, artifacts: io.artifacts, mode: @plan[:campaign], budget: @budget)
      result == 'FAIL_H3_GUEST_CAMPAIGN' ? 65 : 0
    end
    def stage_guest(snapshot, guest, artifacts)
      @budget.check
      Check.that(guest && guest.path == CampaignEvidence.root('GUEST'), 'driver fresh guest destination')
      copies = SealedBuild::PRELAUNCH.map { |name| @budget.check; [name, name] }
      copies += [['admission-campaign-checkpoint.json', 'prior-admission-checkpoint.json'],
                 ['campaign-verifier-supervisor.json', 'prior-admission-verifier-supervisor.json'],
                 ['admission-campaign-seal.json', 'prior-admission-campaign-seal.json']]
      copied = {}
      copies.each do |source, destination|
        @budget.check
        bytes = artifacts.fetch(source)
        reference = ImmutableArtifact.write(@files, guest.root, destination, bytes,
          maximum: CampaignSnapshot.maximum(destination))
        Check.that(reference == { 'byte_count' => bytes.bytesize, 'path' => destination, 'sha256' => Digest::SHA256.hexdigest(bytes) },
                   'driver staged bytes/count/hash equality')
        copied[destination] = bytes
      end
      %w[DEBUG RELEASE].each do |configuration|
        @budget.check
        fresh = stage_product_audit(snapshot.parent, configuration, snapshot.audit.fetch('settings').fetch(configuration))
        Check.that(Canonical.encode(fresh, @budget).b == copied.fetch(configuration.downcase + '-product-audit.json').b,
                   'driver staged product re-probe canonical equality')
      end
      CampaignEvidence.validate_prior_closure(artifacts: copied, budget: @budget)
      guest.complete_prelaunch(SealedBuild::PRELAUNCH + CampaignEvidence::PRIOR)
      0
    end
    def stage_product_audit(parent, configuration, settings)
      @budget.check
      probes = []
      [true, false].each_with_index do |application, index|
        @budget.check
        code, executable = ProductProbes.paths(configuration, application)
        resolved = settings.fetch(index).fetch('buildSettings')
        Check.that(resolved.fetch('TARGET_BUILD_DIR') + '/' + resolved.fetch('FULL_PRODUCT_NAME') == code &&
                   resolved.fetch('TARGET_BUILD_DIR') + '/' + resolved.fetch('EXECUTABLE_PATH') == executable,
                   'driver stage settings/product path')
        relative = executable.delete_prefix('/private/tmp/')
        held, before = @files.pair(parent, relative, minimum: 1, maximum: 67_108_864)
        begin
          ProductProbes.argv(configuration, application).each do |argv|
            @budget.check
            result = @supervisor.run(argv, cwd: '/private/var/empty', seconds: 30)
            probes << { 'argv' => argv, 'cwd' => '/private/var/empty', 'environment' => ENVIRONMENT,
              'exit_status' => 0, 'stderr' => Canonical.stream(result.fetch('stderr')), 'stdout' => Canonical.stream(result.fetch('stdout')) }
          end
          after = @files.observe(parent, relative, minimum: 1, maximum: 67_108_864)
          Check.that(after == before && @files.identity(held) == before.fetch('identity'), 'driver staged product post-probe stat/bytes')
          claim = ProductProbes.claim(probes.last(6), configuration, application, @budget)
          Check.that(claim.fetch('executable_sha256') == before.fetch('sha256'), 'driver staged internal/external executable hash')
        ensure
          original_error = $!
          begin
            held.close
          rescue Exception => close_error
            raise close_error if original_error.nil?
          end
        end
      end
      ProductProbes.validate(probes, configuration, @budget)
    end
  end

  class ModeDriver
    def self.run
      budget = Budget.new
      begin
        plan = LaunchContext.admit(budget)
      rescue Rejected, KeyError, TypeError, ArgumentError
        diagnostic('H3 qualification seal: inadmissible launch context')
        return 64
      end
      native = Native.new
      files = Files.new(native, budget)
      runtime = RuntimeAdmission.new(files)
      runtime.validate
      ModeClock.new(native, budget).around(plan.fetch(:argument)) do
        budget.check
        supervisor = Supervisor.new(files)
        status = case plan.fetch(:kind)
                 when :ordinary
                   OrdinaryCompatibility.new(files, supervisor, runtime).run
                   0
                 when :seal
                   SealedBuild.new(files, supervisor, runtime).run
                   0
                 when :run, :verify, :stage
                   PostSealMode.new(files, supervisor, runtime, plan).run
                 else raise Rejected, 'driver unreachable mode'
                 end
        budget.check
        Check.that(supervisor.children == plan.fetch(:children) && [0, 65].include?(status), 'driver complete exact child/result count')
        Check.that(status != 65 || [:run, :verify].include?(plan[:kind]), 'driver non-PASS result role')
        status
      end
    rescue ContainmentUnproven
      # No retry, next mode, positive evidence, or post-reap signal is created.
      # The supervisor owns the exact-child diagnostic. Local I/O failure is
      # returned only after contained terminal observation; unresolved ownership
      # takes this branch. Neither a diagnostic nor exit 70/74 proves containment.
      diagnostic('H3 qualification seal: containment unproven; operator attention required')
      70
    rescue IOError, SystemCallError
      diagnostic('H3 qualification seal: I/O failure; retained prefix is not a completed mode')
      74
    rescue Rejected, KeyError, TypeError, NoMethodError, ArgumentError
      diagnostic('H3 qualification seal: rejected or incomplete; no automatic continuation')
      70
    end
    def self.diagnostic(message)
      # Operator pipes are nonblocking. This is one bounded best-effort write,
      # not a receipt or an assertion that the operator observed EOF/reap.
      STDERR.write_nonblock(message + "\n")
    rescue IOError, SystemCallError
      nil
    end
    private_class_method :diagnostic
  end
  # END DORMANT H3 MODE DRIVER
end

# Only the exact program entry dispatches a mode; requiring these definitions
# performs no mode execution. Every invocation still requires its frozen
# operator authorization, launch context, bounds and terminal observations.
if $PROGRAM_NAME == __FILE__
  exit(H3QualificationSeal::ModeDriver.run)
end

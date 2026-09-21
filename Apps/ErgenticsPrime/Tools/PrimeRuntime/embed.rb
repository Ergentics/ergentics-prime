require 'fileutils'
require 'json'
require 'digest'

products, contents, identity = ARGV
raise 'Expected Xcode build paths' unless products && contents
helper = File.join(products, 'ErgenticsPrimeRuntime')
raise 'Prime helper was not built' unless File.file?(helper)
libraries = Dir.glob(File.join(products, '*Cmlx*.bundle')).select { |path| File.directory?(path) }
raise "Expected one built MLX resource bundle, found #{libraries.length}" unless libraries.length == 1
metallibs = Dir.glob(File.join(libraries.first, '**/default.metallib'))
raise 'Expected one freshly built Metal library' unless metallibs.length == 1
destination = File.join(contents, 'Helpers/PrimeRuntime')
FileUtils.mkdir_p(destination)
FileUtils.cp(helper, File.join(destination, 'ErgenticsPrimeRuntime'), preserve: true)
bundle = File.join(destination, 'mlx-swift_Cmlx.bundle')
FileUtils.mkdir_p(File.join(bundle, 'Contents/Resources'))
FileUtils.cp(metallibs.first, File.join(bundle, 'Contents/Resources/default.metallib'))
File.write(File.join(bundle, 'Contents/Info.plist'), <<~PLIST)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0"><dict><key>CFBundleIdentifier</key><string>mlx-swift_Cmlx</string><key>CFBundleName</key><string>mlx-swift_Cmlx</string><key>CFBundlePackageType</key><string>BNDL</string><key>CFBundleVersion</key><string>1</string></dict></plist>
PLIST
FileUtils.rm_f(File.join(destination, 'metallib.json')) # obsolete output from the initial development build
FileUtils.mkdir_p(File.join(contents, 'Resources'))
File.write(File.join(contents, 'Resources/PrimeRuntimeMetallib.json'), JSON.generate({
  schemaVersion: 1,
  artifactRelativePath: 'mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib',
  byteCount: File.size(metallibs.first),
  sha256: Digest::SHA256.file(metallibs.first).hexdigest,
}))
checkpoint = File.expand_path('../../Resources/PrimePromptCheckpoint.json', __dir__)
raise 'Missing sealed Prime checkpoint binding' unless File.file?(checkpoint)
binding = JSON.parse(File.binread(checkpoint))
weights_binding = binding.fetch('weights_external_binding').fetch('artifact_binding')
weights_relative_path = 'baseline_checkpoint/weights.safetensors'
raise 'Unexpected Prime weights binding' unless binding.fetch('set_role') == 'baseline_checkpoint' &&
  binding.fetch('load_authoritative') == true &&
  weights_binding.fetch('relativePath') == weights_relative_path &&
  weights_binding.fetch('purpose') == 'immutable_data' &&
  weights_binding.fetch('byteCount').is_a?(Integer) && weights_binding.fetch('byteCount') > 0 &&
  weights_binding.fetch('sha256').match?(/\A[0-9a-f]{64}\z/)
weights = File.expand_path('../../Resources/PrimeModel/' + weights_relative_path, __dir__)
verify_weights = lambda do |path|
  stat = File.lstat(path)
  raise 'Missing or invalid retained Prime model weights' unless stat.file? && !stat.symlink? &&
    stat.size == weights_binding.fetch('byteCount') &&
    Digest::SHA256.file(path).hexdigest == weights_binding.fetch('sha256')
end
verify_weights.call(weights)
FileUtils.cp(checkpoint, File.join(contents, 'Resources/PrimePromptCheckpoint.json'))
bundled_weights = File.join(contents, 'Resources/PrimeModel', weights_relative_path)
FileUtils.mkdir_p(File.dirname(bundled_weights))
FileUtils.rm_f(bundled_weights) # Replace our previous read-only build output without following its leaf.
FileUtils.cp(weights, bundled_weights)
File.chmod(0444, bundled_weights)
verify_weights.call(bundled_weights)
if identity && !identity.empty?
  raise 'Could not sign the embedded MLX resource bundle' unless system('/usr/bin/codesign', '--force', '--sign', identity, '--timestamp=none', bundle)
end
puts 'Embedded the native Prime helper, freshly built Metal library, and verified retained model weights.'

# The independently built app-admitted services are copied into this same app;
# the saved standalone runtimes and their checkpoint copies remain unchanged.
compute_embed = File.expand_path('../PrimeComputeNative/embed.rb', __dir__)
raise 'Could not embed the current Prime compute services' unless
  system('/usr/bin/ruby', compute_embed, products, contents, identity.to_s)

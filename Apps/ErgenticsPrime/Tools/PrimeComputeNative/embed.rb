#!/usr/bin/ruby
# Package only the new app-admitted helpers and exact retained Prime weights.
# This script runs inside the app's existing Xcode embed phase, before its outer seal.
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'securerandom'

products, contents, identity = ARGV
raise 'Expected the existing Xcode embed arguments' unless products && contents
raise 'A real app signing identity is required for the Prime services' if identity.to_s.empty? || identity == '-'
contents = File.expand_path(contents)
raise 'Expected an app Contents directory' unless File.basename(contents) == 'Contents' &&
  File.extname(File.dirname(contents)) == '.app' && File.directory?(contents) && !File.symlink?(contents)
raise 'Never embed into an installed app' if contents.start_with?('/Applications/')

# build02 changes only the app-specific MLX resource loader location; build01
# and the standalone runtimes remain retained with their original libraries.
build = File.join(__dir__, 'build02')
assets = JSON.parse(File.binread(File.expand_path('../../BuildAssets.json', __dir__)))
raise 'Expected BuildAssets.json schemaVersion 1' unless assets['schemaVersion'] == 1
collection = assets['experimentCollection']
raise 'Missing absolute experiment collection in BuildAssets.json' unless collection.is_a?(String) &&
  collection.start_with?('/') && File.directory?(collection)
collection = File.expand_path(collection)
raise 'Never change a saved experiment build' if contents.start_with?(collection + '/')
receipt_path = File.join(build, 'result.json')
receipt = JSON.parse(File.binread(receipt_path))
raise 'The app-specific Prime helpers must finish building first' unless receipt['status'] == 'completed'

helpers = [
  ['PrimeModelService', 'com.ergentics.provenance.prime-model-service'],
  ['PrimeGeometryService', 'com.ergentics.provenance.prime-geometry-service'],
].freeze
models = [
  ['1618', '0010-prime-domain-seed1618', '122af63187129249ef0c85dbac6e6f1bd0c0e67c60f88b387844fd002bd2d0ec'],
  ['2718', '0011-prime-domain-seed2718', 'f5201fae919d8636300086829943fd38059767ab293147ca8c0c65ce91402067'],
  ['3141', '0012-prime-domain-seed3141', '7064c514a9a41369951d1ee829ac0f028bb488a0b9551d5e8b1d2433173cd4e1'],
].freeze

stamp = lambda do |path|
  value = File.lstat(path)
  raise "Expected a regular non-symlink input: #{path}" unless value.file? && !value.symlink?
  {'byteCount' => value.size, 'sha256' => Digest::SHA256.file(path).hexdigest}
end
copy_exact = lambda do |source, destination, expected, mode|
  before = stamp.call(source)
  raise "Source binding mismatch: #{source}" unless before == expected
  FileUtils.mkdir_p(File.dirname(destination))
  raise "Symlink destination directory: #{destination}" if File.symlink?(File.dirname(destination))
  if File.exist?(destination) || File.symlink?(destination)
    raise "Unexpected destination: #{destination}" unless File.file?(destination) && !File.symlink?(destination)
  end
  temporary = File.join(File.dirname(destination), ".#{File.basename(destination)}.prime-embed-#{$$}-#{SecureRandom.hex(4)}")
  begin
    FileUtils.copy_file(source, temporary)
    File.chmod(mode, temporary)
    raise "Copied artifact mismatch: #{destination}" unless stamp.call(temporary) == expected
    raise "Source changed while copying: #{source}" unless stamp.call(source) == before
    File.rename(temporary, destination)
  ensure
    File.unlink(temporary) if File.exist?(temporary)
  end
  before
end

recorded = receipt.fetch('outputs')
raise 'Expected explicit compiled output bindings' unless recorded.is_a?(Array)
by_name = recorded.to_h { |row| [row.fetch('name'), row] }
names = helpers.map(&:first) + ['mlx.metallib']
raise 'Missing or duplicate compiled output bindings' unless by_name.length == recorded.length &&
  names.all? { |name| by_name.key?(name) }

helper_rows = helpers.map do |name, identifier|
  source = File.join(build, name)
  expected = by_name.fetch(name).slice('byteCount', 'sha256')
  raise "Invalid compiled helper binding: #{name}" unless expected['byteCount'].is_a?(Integer) &&
    expected['byteCount'] > 0 && expected['sha256'].to_s.match?(/\A[0-9a-f]{64}\z/)
  relative = "Contents/Helpers/PrimeCompute/#{name}"
  destination = File.join(File.dirname(contents), relative)
  copy_exact.call(source, destination, expected, 0o755)
  # The compile receipt binds the unsigned input. Sign only this new app copy;
  # the source build and all sealed standalone runtimes retain their exact bytes.
  raise "Could not sign app service #{name}" unless system('/usr/bin/codesign', '--force',
    '--sign', identity, '--identifier', identifier, '--entitlements', File.join(__dir__, 'Entitlements.plist'),
    '--options', 'runtime', '--timestamp=none', '--generate-entitlement-der', destination)
  stdout, stderr, status = Open3.capture3('/usr/bin/codesign', '-d', '--verbose=2', destination)
  details = stdout + stderr
  raise "App helper is not signed with its dedicated identity: #{name}" unless status.success? &&
    details.lines.map(&:strip).include?("Identifier=#{identifier}") &&
    details.lines.map(&:strip).include?('TeamIdentifier=ZCQ435U8JP')
  raise "Compiled source changed while signing #{name}" unless stamp.call(source) == expected
  {'name' => name, 'identifier' => identifier, 'relativePath' => relative}.merge(stamp.call(destination))
end

metal_source = File.join(build, 'mlx.metallib')
metal_expected = by_name.fetch('mlx.metallib').slice('byteCount', 'sha256')
raise 'Invalid compiled Metal-library binding' unless metal_expected['byteCount'].is_a?(Integer) &&
  metal_expected['byteCount'] > 0 && metal_expected['sha256'].to_s.match?(/\A[0-9a-f]{64}\z/)
metal_relative = 'Contents/Resources/PrimeCompute/mlx.metallib'
copy_exact.call(metal_source, File.join(File.dirname(contents), metal_relative), metal_expected, 0o444)
# A prior failed Build23 placed this data file among nested executable code.
# Remove only that exact generated leaf from the current build output. The
# app-specific loader now reads the proper outer-sealed Resources location.
old_metal = File.join(contents, 'Helpers/PrimeCompute/mlx.metallib')
if File.exist?(old_metal) || File.symlink?(old_metal)
  raise 'Unexpected old Prime Metal resource; retained for inspection' unless stamp.call(old_metal) == metal_expected
  File.unlink(old_metal)
end

model_rows = models.map do |seed, directory, digest|
  source = File.join(collection, directory, 'Runtime/prime-domain-trace.safetensors')
  expected = {'byteCount' => 40_919_832, 'sha256' => digest}
  saved = JSON.parse(File.binread(File.join(collection, directory, 'BUILD.json')))
  raise "Saved checkpoint metadata mismatch for seed #{seed}" unless saved['seed'].to_s == seed &&
    saved.fetch('weights').slice('byteCount', 'sha256') == expected && saved['newTraining'] == false
  relative = "PrimeCompute/seed-#{seed}.safetensors"
  copy_exact.call(source, File.join(contents, 'Resources', relative), expected, 0o444)
  {'seed' => seed, 'relativePath' => relative}.merge(expected)
end

manifest = {'schemaVersion' => 1, 'models' => model_rows, 'helpers' => helper_rows,
            'metallib' => {'relativePath' => metal_relative}.merge(metal_expected)}
destination = File.join(contents, 'Resources/PrimeComputeAssets.json')
raise 'Manifest destination is a symlink' if File.symlink?(destination)
temporary = destination + ".prime-embed-#{$$}-#{SecureRandom.hex(4)}"
begin
  File.open(temporary, File::WRONLY | File::CREAT | File::EXCL, 0o444) do |file|
    file.write(JSON.pretty_generate(manifest) + "\n")
    file.flush
    file.fsync
  end
  File.rename(temporary, destination)
ensure
  File.unlink(temporary) if File.exist?(temporary)
end
puts 'Embedded the app-specific Prime model/geometry services, matched Metal library, and three exact retained checkpoints.'

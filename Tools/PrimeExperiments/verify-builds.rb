#!/usr/bin/env ruby
# Verify the saved snapshot. New Results directories are allowed; pinned files must match.
require 'json'
require 'digest'
root = File.realpath(__dir__)
raise 'usage: ruby verify.rb --all' unless ARGV == ['--all']
index = JSON.parse(File.read(File.join(root, 'BUILD-INDEX.json')))
checked = 0
verify = lambda do |base, row|
  relative = row.fetch('path')
  raise 'unsafe manifest path' if relative.start_with?('/') || relative.split('/').any? { |x| ['', '.', '..'].include?(x) }
  path = File.join(base, relative)
  raise "changed path: #{relative}" unless File.realpath(path) == path && File.file?(path)
  expected_size = row['byteCount'] || row['bytes']
  raise "changed bytes: #{relative}" unless File.size(path) == expected_size && Digest::SHA256.file(path).hexdigest == row.fetch('sha256')
  checked += 1
end
index.fetch('builds').each do |build|
  base = File.join(root, build.fetch('directory'))
  verify.call(base, build.fetch('fileManifest'))
  JSON.parse(File.read(File.join(base, 'file-manifest.json'))).fetch('files').each { |row| verify.call(base, row) }
end
runtime = index.fetch('sharedRuntime')
verify.call(root, runtime.fetch('manifest'))
data = JSON.parse(File.read(File.join(root, runtime['manifest']['path'])))
base = File.join(root, data.fetch('destination'))
data.fetch('files').each { |row| verify.call(base, row) }
data.fetch('symlinks').each do |row|
  path = File.join(base, row.fetch('path'))
  raise "changed Python link: #{row['path']}" unless File.symlink?(path) && File.readlink(path) == row.fetch('target')
end
external = data.fetch('externalInterpreter')
raise 'Command Line Tools interpreter changed' unless Digest::SHA256.file(external.fetch('path')).hexdigest == external.fetch('sha256')
puts JSON.generate(status: 'saved_bytes_verified', checkedFiles: checked, builds: index['builds'].size,
                   modelExecutionPerformed: false, trainingPerformed: false)

#!/usr/bin/env ruby
require 'json'
require 'digest'

root = File.expand_path('..', __dir__)
index = JSON.parse(File.read(File.join(root, 'BUILD-INDEX.json')))
binding = index.fetch('expandedExperiment').fetch('fileManifest')
manifest = File.join(__dir__, binding.fetch('path'))
raise 'manifest changed' unless File.size(manifest) == binding.fetch('byteCount') &&
  Digest::SHA256.file(manifest).hexdigest == binding.fetch('sha256')
rows = JSON.parse(File.read(manifest)).fetch('files')
raise 'duplicate paths' unless rows.map { |r| r.fetch('path') }.uniq.length == rows.length
rows.each do |row|
  relative = row.fetch('path')
  raise 'noncanonical relative path' if relative.start_with?('/') || relative.split('/').any? { |part| ['', '.', '..'].include?(part) }
  path = File.join(root, relative)
  raise 'non-regular or redirected file: ' + relative unless File.file?(path) && !File.symlink?(path) && File.realpath(path) == path
  raise 'changed bytes: ' + relative unless File.size(path) == row.fetch('byteCount') &&
    Digest::SHA256.file(path).hexdigest == row.fetch('sha256')
end
puts JSON.generate(status: 'saved_expansion_bytes_verified', checkedFiles: rows.length,
  inferenceRuns: 36, modelExecutionPerformed: false)

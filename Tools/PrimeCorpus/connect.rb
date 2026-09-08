#!/usr/bin/env ruby
# Preserve explicitly pinned source artifacts. No harvesting, projection, training or inference.
require 'json'
require 'digest'
require 'fileutils'
require 'pathname'

module PrimeCorpusConnect
  ROLES = %w[corpus sidecar implementation evidence].freeze
  MAX_REGISTRY = 8 * 1024 * 1024
  MAX_LINE = 16 * 1024 * 1024

  class UniqueObject < Hash
    def []=(key, value)
      raise ArgumentError, "duplicate JSON key: #{key}" if key?(key)
      super
    end
  end

  def self.check(condition, message)
    raise ArgumentError, message unless condition
  end

  def self.absolute(path)
    check(path.is_a?(String) && path.start_with?('/') && !path.include?("\0") &&
          Pathname.new(path).cleanpath.to_s == path, 'expected normalized absolute path')
    path
  end

  def self.relative(path)
    check(path.is_a?(String) && !path.empty? && !path.start_with?('/') && !path.include?("\0") &&
          path.split('/', -1).none? { |part| ['', '.', '..'].include?(part) }, 'unsafe relative source path')
    path
  end

  # Check every existing component, including ancestors of the declared root.
  def self.no_symlinks(path)
    current = '/'
    path.split('/').reject(&:empty?).each do |part|
      current = File.join(current, part)
      check(!File.lstat(current).symlink?, "symlink rejected: #{current}")
    end
  end

  def self.identity(stat)
    [stat.dev, stat.ino, stat.size, stat.mtime, stat.ctime]
  end

  def self.open_source(path)
    no_symlinks(path)
    before = File.lstat(path)
    check(before.file?, "not a regular file: #{path}")
    flags = File::RDONLY
    flags |= File::NOFOLLOW if File.const_defined?(:NOFOLLOW)
    File.open(path, flags) do |input|
      check(identity(input.stat) == identity(before), "source changed while opening: #{path}")
      result = yield(input)
      no_symlinks(path)
      check(identity(input.stat) == identity(before) && identity(File.lstat(path)) == identity(before),
            "source changed while reading: #{path}")
      result
    end
  end

  def self.jsonl_counts(path)
    result = {'physicalLines' => 0, 'blankLines' => 0, 'jsonObjects' => 0, 'otherJSONValues' => 0,
              'invalidJSONLines' => 0, 'oversizeLines' => 0, 'schemaCounts' => {}, 'familyCounts' => {},
              'polarityCounts' => {}}
    increment = lambda do |counts, value|
      key = value.nil? ? '(absent)' : JSON.generate(value)
      key = '(other values beyond 4096)' if !counts.key?(key) && counts.length >= 4096
      counts[key] = counts.fetch(key, 0) + 1
    end
    File.open(path, 'rb') do |input|
      while (line = input.gets(MAX_LINE + 1))
        result['physicalLines'] += 1
        if line.bytesize > MAX_LINE
          result['oversizeLines'] += 1
          while !line.end_with?("\n") && (line = input.gets(MAX_LINE + 1)); end
          next
        end
        if line.strip.empty?
          result['blankLines'] += 1
          next
        end
        begin
          row = JSON.parse(line, object_class: UniqueObject)
          unless row.is_a?(Hash)
            result['otherJSONValues'] += 1
            next
          end
          result['jsonObjects'] += 1
          increment.call(result['schemaCounts'], row['schema_version'] || row['schema'])
          increment.call(result['familyCounts'], row['family_id'] || row['skill_id'])
          increment.call(result['polarityCounts'], row['polarity'])
        rescue JSON::ParserError, ArgumentError
          result['invalidJSONLines'] += 1
        end
      end
    end
    result
  end

  def self.write_json(output, path, value)
    bytes = JSON.pretty_generate(value) + "\n"
    File.open(File.join(output, path), File::WRONLY | File::CREAT | File::EXCL, 0o600) do |file|
      file.write(bytes)
      file.flush
      file.fsync
    end
    {'path' => path, 'byteCount' => bytes.bytesize, 'sha256' => Digest::SHA256.hexdigest(bytes)}
  end

  def self.run(argv)
    check(argv.length == 4, 'usage: connect.rb --registry ABS_JSON --output FRESH_ABS_DIR')
    options = {}
    argv.each_slice(2) do |key, value|
      check(%w[--registry --output].include?(key) && !options.key?(key), 'unknown or duplicate argument')
      options[key] = absolute(value)
    end
    check(options.keys.sort == %w[--output --registry], 'registry and output are required')
    registry_path, output = options.values_at('--registry', '--output')
    registry_bytes = open_source(registry_path) do |input|
      check(input.stat.size <= MAX_REGISTRY, 'registry exceeds 8 MiB')
      input.read(MAX_REGISTRY + 1)
    end
    registry = JSON.parse(registry_bytes, object_class: UniqueObject)
    check(registry.is_a?(Hash), 'registry must be an object')
    sources = registry['sources']
    check(sources.is_a?(Array) && sources.length.between?(1, 256), 'expected 1..256 sources')
    source_ids, paths, total_files = {}, [], 0
    sources.each do |source|
      check(source.is_a?(Hash), 'source must be an object')
      id = source['id']
      check(id.is_a?(String) && id.match?(/\A[a-zA-Z0-9][a-zA-Z0-9._-]{0,79}\z/) && !source_ids.key?(id),
            'invalid or duplicate source ID')
      source_ids[id] = true
      root = absolute(source['root'])
      no_symlinks(root)
      check(File.directory?(root), "source root is not a directory: #{id}")
      check(output != root && !output.start_with?(root == '/' ? '/' : root + '/'),
            "output must be outside source roots: #{id}")
      check(source.key?('revision') && (source['revision'].nil? || source['revision'].is_a?(String)),
            'source revision must be a string or explicit null')
      check(source['files'].is_a?(Array) && !source['files'].empty?, 'source files must be nonempty')
      seen = {}
      source['files'].each do |file|
        check(file.is_a?(Hash), 'file entry must be an object')
        path = relative(file['path'])
        check(!seen.key?(path), "duplicate source path: #{id}/#{path}")
        seen[path] = true
        check(file['byteCount'].is_a?(Integer) && file['byteCount'] >= 0, 'byteCount must be a nonnegative integer')
        check(file['sha256'].is_a?(String) && file['sha256'].match?(/\A[0-9a-f]{64}\z/), 'invalid SHA256')
        check(ROLES.include?(file['role']), 'invalid artifact role')
        paths << [id, root, file]
        total_files += 1
        check(total_files <= 10_000, 'registry exceeds 10000 files')
      end
    end
    no_symlinks(File.dirname(output))
    check(File.directory?(File.dirname(output)), 'output parent must already exist')
    check(!File.exist?(output) && !File.symlink?(output), 'output already exists')
    created = false
    begin
      Dir.mkdir(output, 0o700)
      created = true
      bindings = []
      counts = {'sources' => sources.length, 'files' => 0, 'bytes' => 0, 'filesByRole' => {}, 'jsonl' => {}}
      paths.each do |id, root, file|
        destination = File.join('raw', id, file['path'])
        target = File.join(output, destination)
        FileUtils.mkdir_p(File.dirname(target), mode: 0o700)
        digest, copied = Digest::SHA256.new, 0
        open_source(File.join(root, file['path'])) do |input|
          check(input.stat.size == file['byteCount'], "source byteCount changed: #{id}/#{file['path']}")
          File.open(target, File::WRONLY | File::CREAT | File::EXCL, 0o600) do |saved|
            while (chunk = input.read(1024 * 1024))
              copied += chunk.bytesize
              check(copied <= file['byteCount'], 'source grew during copy')
              digest.update(chunk)
              saved.write(chunk)
            end
            saved.flush
            saved.fsync
          end
        end
        check(copied == file['byteCount'] && digest.hexdigest == file['sha256'], "source pin changed: #{id}/#{file['path']}")
        bindings << file.merge('sourceID' => id, 'outputPath' => destination, 'verifiedByteCount' => copied,
                               'verifiedSHA256' => digest.hexdigest)
        counts['files'] += 1
        counts['bytes'] += copied
        counts['filesByRole'][file['role']] = counts['filesByRole'].fetch(file['role'], 0) + 1
        if %w[corpus sidecar].include?(file['role']) && file['path'].end_with?('.jsonl')
          counts['jsonl'][destination] = jsonl_counts(target)
        end
      end
      metadata = []
      registry_identity = {'path' => registry_path, 'byteCount' => registry_bytes.bytesize,
                           'sha256' => Digest::SHA256.hexdigest(registry_bytes)}
      metadata << write_json(output, 'source-bindings.json', {
        'schema' => 'prime_source_bindings_v1', 'registry' => registry_identity,
        'revisionScope' => 'Revision and controlState are registry declarations; exact listed file bytes are verified.',
        'sources' => sources.map { |source| source.reject { |key, _| key == 'files' } }, 'files' => bindings,
        'notes' => registry['notes']})
      metadata << write_json(output, 'counts.json', counts)
      metadata << write_json(output, 'pending-model-sidecar.json', {
        'schema' => 'prime_connected_sources_v1', 'status' => 'connected_raw_sources_pending_selection',
        'registry' => registry_identity, 'sourceBindings' => metadata.first,
        'trainingPerformed' => false, 'inferencePerformed' => false, 'tokenizerReplaced' => false,
        'modelWeightsChanged' => false, 'sourceLabelsReinterpreted' => false,
        'trainingSelection' => nil, 'evaluationSelection' => nil,
        'meaning' => 'Raw source connection only. Artifact roles and original labels are preserved; no learned capability or oracle recertification is asserted.'})
      write_json(output, 'COMPLETE.json', {
        'schema' => 'prime_connection_complete_v1', 'status' => 'connected_untrained',
        'registry' => registry_identity, 'counts' => counts.reject { |key, _| key == 'jsonl' },
        'metadata' => metadata, 'trainingPerformed' => false})
      puts JSON.generate({'status' => 'connected_untrained', 'output' => output,
                          'files' => counts['files'], 'bytes' => counts['bytes']})
    rescue Exception
      FileUtils.remove_entry_secure(output) if created && File.directory?(output) && !File.symlink?(output)
      raise
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    PrimeCorpusConnect.run(ARGV)
  rescue StandardError => error
    warn "connect.rb: #{error.message}"
    exit 1
  end
end

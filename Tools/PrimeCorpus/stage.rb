#!/usr/bin/env ruby
# Staging only: no model, tokenizer, subprocess, network, or training invocation.
require 'json'
require 'digest'
require 'set'

module PrimeCorpus
  VERSION = 'prime_corpus_stager_v1'.freeze
  SPLIT = 'sha256_utf8_family_first_u32_be_mod5_holdout0_v1'.freeze
  FORMAT = 'problem_json_string_answer_json_string_one_line_v1'.freeze
  MAX_BYTES = 64 * 1024 * 1024
  MAX_ROWS = 25_000
  FILE_FAMILIES = {
    'algebra.solve.jsonl' => %w[algebra.linear.solve algebra.quadratic.solve],
    'algebra.systems.jsonl' => %w[algebra.linear.system],
    'algebra.factor.jsonl' => %w[algebra.factor.quadratic],
    'algebra.exp.jsonl' => %w[algebra.exp.solve],
    'algebra.rational.jsonl' => %w[algebra.rational.solve],
    'algebra.inequality.jsonl' => %w[algebra.linear.inequality],
    'geometry.area.jsonl' => %w[geometry.triangle.area],
    'geometry.pointintriangle.jsonl' => %w[geometry.point_in_triangle],
    'geometry.polygon_area.jsonl' => %w[geometry.polygon.area],
    'geometry.point_in_polygon.jsonl' => %w[geometry.point_in_polygon],
    'renderkit.ggx.jsonl' => %w[renderkit.ggx.ndf_peak renderkit.ggx.energy],
    'renderkit.projection.midpoint.jsonl' => %w[renderkit.projection.midpoint],
    'renderkit.metal.coverage.jsonl' => %w[renderkit.metal.coverage],
    'renderkit.shading.specular_peak.jsonl' => %w[renderkit.shading.specular_peak],
    'logic.parsing.jsonl' => %w[logic.parsing.expr logic.parsing.membership],
    'music.theory.jsonl' => %w[music.interval.directed music.triad.quality],
    'music.scales.jsonl' => %w[music.major_scale.membership],
    'music.seventh.jsonl' => %w[music.seventh.quality],
    'music.inversion.jsonl' => %w[music.chord.inversion],
    'music.rhythm.jsonl' => %w[music.rhythm.polyrhythm_lcm music.rhythm.euclidean_necklace],
    'music.modes.jsonl' => %w[music.modes.identification music.modes.degree_triad],
    'music.setclass.jsonl' => %w[music.setclass.ti_equivalence]
  }.freeze
  REFERENCE_PATHS = {
    'weights' => 'models/ergentics_native_lab_v2/weights.safetensors',
    'train_manifest' => 'models/ergentics_native_lab_v2/train_manifest.json',
    'tokenizer_manifest' => 'tokenizer/prime_native_bpe_v1/manifest.json',
    'tokenizer_model' => 'tokenizer/prime_native_bpe_v1/model.spm'
  }.freeze
  class Failure < StandardError; end
  class UniqueObject < Hash
    def []=(key, value)
      raise Failure, 'duplicate_json_key' if key?(key)
      super
    end
  end
  def self.require!(condition, reason)
    raise Failure, reason unless condition
  end
  def self.parse(bytes)
    text = bytes.dup.force_encoding(Encoding::UTF_8)
    require!(text.valid_encoding?, 'invalid_utf8')
    JSON.parse(text, object_class: UniqueObject, max_nesting: 40)
  end
  def self.canonical(value)
    case value
    when Hash then value.keys.sort.to_h { |k| [k, canonical(value[k])] }
    when Array then value.map { |v| canonical(v) }
    else value
    end
  end
  def self.json(value)
    JSON.generate(canonical(value)) + "\n"
  end
  def self.relative(path)
    require!(path.is_a?(String) && path.bytesize.between?(1, 512) &&
      !path.include?("\0") && !path.include?('\\') &&
      path.split('/', -1).all? { |p| !p.empty? && p != '.' && p != '..' }, 'invalid_relative_path')
    path
  end
  def self.root(path)
    require!(path.is_a?(String) && path.start_with?('/') &&
      File.expand_path(path) == path && File.realpath(path) == path &&
      File.directory?(path), 'noncanonical_root')
    path
  end
  def self.signature(s)
    [s.dev, s.ino, s.mode, s.uid, s.gid, s.nlink, s.size, s.mtime, s.ctime]
  end
  def self.string(value)
    value.is_a?(String) && !value.strip.empty? && !value.include?("\0")
  end

  class Stage
    def initialize
      @held = []; @outputs = []; @source_bindings = []; @deadline = now + 120
    end
    def now; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
    def check; PrimeCorpus.require!(now < @deadline, 'staging_deadline'); end
    def read(path, cap, expected = nil, retain_bytes = true)
      check
      PrimeCorpus.require!(File.realpath(path) == path, 'symlink_input')
      file = File.open(path, File::RDONLY | File::NOFOLLOW)
      before = file.stat
      PrimeCorpus.require!(before.file? && before.nlink == 1 && before.size.between?(1, cap), 'input_file_metadata')
      hash = Digest::SHA256.new; bytes = ''.b; count = 0
      while (part = file.read(1024 * 1024))
        check; count += part.bytesize; hash.update(part); bytes << part if retain_bytes
      end
      PrimeCorpus.require!(count == before.size && PrimeCorpus.signature(file.stat) == PrimeCorpus.signature(before), 'input_changed')
      binding = { 'path' => path, 'byteCount' => count, 'sha256' => hash.hexdigest }
      if expected
        PrimeCorpus.require!(expected['byteCount'] == count && expected['sha256'] == binding['sha256'], 'input_pin_mismatch')
      end
      @held << [file, path, PrimeCorpus.signature(before)]
      [bytes, binding]
    rescue
      file.close if file && !@held.any? { |h| h[0].equal?(file) }
      raise
    end
    def revalidate
      @held.each do |file, path, stat|
        check
        PrimeCorpus.require!(File.realpath(path) == path && PrimeCorpus.signature(file.stat) == stat &&
          PrimeCorpus.signature(File.lstat(path)) == stat, 'retained_input_changed')
      end
    end
    def write(path, bytes)
      check; PrimeCorpus.relative(path)
      destination = File.join(@output, path)
      parent = File.dirname(destination)
      missing = []; p = parent
      until File.directory?(p)
        missing << p; p = File.dirname(p)
      end
      missing.reverse_each { |d| Dir.mkdir(d, 0700) }
      PrimeCorpus.require!(File.realpath(parent) == parent, 'output_parent_changed')
      File.open(destination, File::WRONLY | File::CREAT | File::EXCL | File::NOFOLLOW, 0600) do |f|
        PrimeCorpus.require!(f.write(bytes) == bytes.bytesize, 'short_output_write')
        f.chmod(0444); f.flush; f.fsync
      end
      binding = { 'path' => path, 'byteCount' => bytes.bytesize, 'sha256' => Digest::SHA256.hexdigest(bytes) }
      @outputs << binding
      binding
    end
    def validate_row(row, file)
      PrimeCorpus.require!(row.is_a?(Hash) && row['schema_version'] == '0.1' &&
        %w[positive negative].include?(row['polarity']), 'record_schema_or_polarity')
      %w[id family_id canonical_hash problem answer_canonical source_app source_repo license].each do |key|
        PrimeCorpus.require!(PrimeCorpus.string(row[key]), "record_missing_#{key}")
      end
      PrimeCorpus.require!(row['solution_trace'].nil? ||
        (row['solution_trace'].is_a?(Array) && row['solution_trace'].all? { |s| s.is_a?(String) }), 'solution_trace_shape')
      expected_app = file.start_with?('algebra.') ? 'algebra-app' :
        (file.start_with?('geometry.', 'renderkit.') ? 'geometry-app' :
        (file.start_with?('music.') ? 'music-theory-app' : 'ergentics-logic'))
      PrimeCorpus.require!(row['source_app'] == expected_app && row['source_repo'] == "Ergentics/#{expected_app}" &&
        row['license'] == 'Ergentics-proprietary' && @source_ids.include?(expected_app), 'record_source_join')
      if row['polarity'] == 'negative'
        PrimeCorpus.require!(row['rejected_by'].is_a?(Array) && !row['rejected_by'].empty? &&
          row['rejected_by'].all? { |s| PrimeCorpus.string(s) } && PrimeCorpus.string(row['failure_mode']), 'negative_label_missing')
      end
    end
    def eligible?(row, file)
      return false unless FILE_FAMILIES.fetch(file, []).include?(row['family_id']) && row['polarity'] == 'positive'
      # GGX/coverage list an explicit same-formula corroborator; it is never counted as a fourth axiom.
      oracles = row['oracles']
      PrimeCorpus.require!(oracles.is_a?(Array) && oracles.size.between?(3, 4), 'oracle_shape')
      counted = oracles.reject { |o| o['oracle_class'] == 'shipped_code_parity' && o['algorithm_family'] == 'same_formula_execution' }
      PrimeCorpus.require!(counted.size == 3 && row['independent_oracle_count'] == 3 &&
        PrimeCorpus.string(row['independence_verified_by']) && PrimeCorpus.string(row['agreement']), 'oracle_count')
      identities = counted.map do |o|
        PrimeCorpus.require!(o.is_a?(Hash) && %w[oracle_class algorithm_family result oracle_version].all? { |k| PrimeCorpus.string(o[k]) } &&
          o['depends_on'].is_a?(Array) && !o['depends_on'].empty? && o['depends_on'].all? { |d| PrimeCorpus.string(d) }, 'oracle_fields')
        [o['oracle_class'], o['algorithm_family']]
      end
      PrimeCorpus.require!(identities.uniq.size == 3 && counted.combination(2).all? { |a, b| (a['depends_on'] & b['depends_on']).empty? }, 'structural_independence')
      generation = row['generation']
      PrimeCorpus.require!(generation.is_a?(Hash) && generation.key?('seed') && generation['raw_inputs'].is_a?(Hash) &&
        PrimeCorpus.string(generation['generator_version']) && PrimeCorpus.string(generation['rng_algorithm']) &&
        row['oracle_versions'].is_a?(Hash) && PrimeCorpus.string(row['harvest_run_id']), 'generation_provenance')
      true
    end
    def render(row)
      # One physical line per example: NativeLabTrainer splits on newline.
      # Full solution_trace remains unchanged in raw/. The first real SPM measurement
      # showed the full-trace projection exceeded the existing 512-token context.
      fields = [row['problem'].strip.unicode_normalize(:nfc), row['answer_canonical'].strip.unicode_normalize(:nfc)]
      "PROBLEM: #{JSON.generate(fields[0])} ANSWER: #{JSON.generate(fields[1])}\n"
    end
    def run(registry_path, output)
      registry_bytes, registry_binding = read(registry_path, 1024 * 1024)
      registry = PrimeCorpus.parse(registry_bytes)
      PrimeCorpus.require!(registry['schema'] == 'prime_corpus_source_registry_v1', 'registry_schema')
      sources = registry['sources']
      source_ids = sources.is_a?(Array) ? sources.map { |s| s['id'] }.sort : []
      PrimeCorpus.require!([%w[algebra-app ergentics-logic geometry-app],
        %w[algebra-app ergentics-logic geometry-app music-theory-app]].include?(source_ids), 'registry_sources')
      @source_ids = source_ids
      PrimeCorpus.require!(output.start_with?('/') && File.expand_path(output) == output, 'output_path')
      input_roots = sources.map { |s| PrimeCorpus.root(s['root']) }
      input_roots << PrimeCorpus.root(registry.fetch('referenceModel').fetch('root'))
      PrimeCorpus.require!(input_roots.none? { |r| output == r || output.start_with?(r + '/') }, 'output_inside_source')
      PrimeCorpus.root(File.dirname(output)); Dir.mkdir(output, 0700); @output = output
      write('source-registry.json', registry_bytes)
      records = []; ids = Set.new; total = 0
      sources.sort_by { |s| s['id'] }.each do |source|
        base = PrimeCorpus.root(source['root'])
        PrimeCorpus.require!(source['revision'].is_a?(String) && source['revision'].match?(/\A[0-9a-f]{40}\z/), 'source_revision')
        files = source['files']
        PrimeCorpus.require!(files.is_a?(Array) && files.size.between?(1, 64) && files.map { |f| f['path'] }.uniq.size == files.size, 'source_files')
        files.sort_by { |f| f['path'] }.each do |entry|
          relative = PrimeCorpus.relative(entry['path'])
          PrimeCorpus.require!(%w[evidence corpus].include?(entry['kind']), 'source_file_kind')
          bytes, binding = read(File.join(base, relative), 16 * 1024 * 1024, entry)
          total += bytes.bytesize; PrimeCorpus.require!(total <= MAX_BYTES, 'source_total_limit')
          binding.merge!('sourceID' => source['id'], 'relativePath' => relative, 'revisionDeclared' => source['revision'], 'kind' => entry['kind'])
          @source_bindings << binding
          raw_path = "raw/#{source['id']}/#{relative}"; write(raw_path, bytes)
          next unless entry['kind'] == 'corpus'
          PrimeCorpus.require!(source['id'] == 'ergentics-logic' && relative.match?(/\Acorpus\/exemplars\/(?:algebra|geometry|renderkit|logic\.parsing|music)[a-z0-9_.-]*\.jsonl\z/), 'corpus_path_scope')
          text = bytes.dup.force_encoding(Encoding::UTF_8)
          PrimeCorpus.require!(text.valid_encoding? && text.end_with?("\n"), 'jsonl_framing')
          text.each_line.with_index(1) do |line, number|
            check; PrimeCorpus.require!(line.bytesize <= 256 * 1024 && !line.strip.empty?, 'jsonl_line')
            row = PrimeCorpus.parse(line); name = File.basename(relative); validate_row(row, name)
            PrimeCorpus.require!(ids.add?(row['id']), 'duplicate_record_id')
            family = row['family_id']; bucket = Digest::SHA256.digest(family).unpack1('N') % 5
            split = bucket.zero? ? 'holdout' : 'train'
            eligible = eligible?(row, name)
            records << { 'id' => row['id'], 'family' => family, 'polarity' => row['polarity'],
              'rawPath' => raw_path, 'line' => number, 'rawLineSHA256' => Digest::SHA256.hexdigest(line),
              'split' => split, 'eligiblePositive' => eligible,
              'problemSHA256' => Digest::SHA256.hexdigest(row['problem'].strip.unicode_normalize(:nfc)),
              'text' => eligible ? render(row) : nil,
              'exclusion' => eligible ? nil : (row['polarity'] == 'negative' ? 'negative_preserved_not_positive_target' : 'outside_closed_ledger_allowlist') }
            PrimeCorpus.require!(records.size <= MAX_ROWS, 'row_limit')
          end
        end
      end
      required = { 'algebra-app' => %w[Sources/AlgStats/Harvest.swift Sources/AlgStats/HarvestDeepen.swift],
        'geometry-app' => %w[Sources/GeometryStats/Harvest.swift],
        'ergentics-logic' => %w[CLAUDE.md corpus/GATE-STATUS.md docs/LOGIC-CORPUS-SCHEMA.md tools/exemplars_to_text.py] }
      required['music-theory-app'] = %w[Sources/MusicStats/Harvest.swift] if source_ids.include?('music-theory-app')
      required.each do |id, paths|
        actual = @source_bindings.select { |b| b['sourceID'] == id }.map { |b| b['relativePath'] }
        PrimeCorpus.require!((paths - actual).empty?, 'missing_source_evidence')
      end
      holdout_problems = records.select { |r| r['split'] == 'holdout' }.map { |r| r['problemSHA256'] }.to_set
      records.each do |r|
        if r['split'] == 'train' && r['eligiblePositive'] && holdout_problems.include?(r['problemSHA256'])
          r['eligiblePositive'] = false; r['text'] = nil; r['exclusion'] = 'problem_also_in_holdout_family'
        end
      end
      train = records.select { |r| r['split'] == 'train' && r['eligiblePositive'] }
      holdout = records.select { |r| r['split'] == 'holdout' && r['eligiblePositive'] }
      PrimeCorpus.require!(!train.empty? && !holdout.empty? &&
        (train.map { |r| r['family'] } & holdout.map { |r| r['family'] }).empty?, 'split_empty_or_overlap')
      train_binding = write('corpus/en/L1/prime-positive-train.txt', train.map { |r| r['text'] }.join)
      holdout_binding = write('evaluation/positive-holdout.txt', holdout.map { |r| r['text'] }.join)
      entry = { 'path' => train_binding['path'], 'sha256' => train_binding['sha256'], 'bytes' => train_binding['byteCount'],
        'language' => 'en', 'level' => 'L1', 'topics' => [] }
      { 'algebra' => %w[algebra.], 'geometry' => %w[geometry. renderkit.],
        'logic-parsing' => %w[logic.parsing.], 'music-theory' => %w[music.] }.each do |topic, prefixes|
        entry['topics'] << topic if train.any? { |r| prefixes.any? { |prefix| r['family'].start_with?(prefix) } }
      end
      native_manifest = write('corpus/manifest.json', PrimeCorpus.json('schema' => 'prime_corpus_manifest_v2', 'files' => [entry]))
      write('evaluation/manifest.json', PrimeCorpus.json('schema' => 'prime_corpus_holdout_manifest_v1', 'files' => [holdout_binding],
        'excludedFromTokenizerTrainInput' => true, 'splitPolicy' => SPLIT))
      index = records.map { |r| r.reject { |k, _| k == 'text' }.merge('renderedLineSHA256' => r['text'] && Digest::SHA256.hexdigest(r['text'])) }
      write('record-index.jsonl', index.map { |r| PrimeCorpus.json(r) }.join)
      reference = registry['referenceModel']
      PrimeCorpus.require!(reference.is_a?(Hash) && reference['modelID'] == 'ergentics_native_lab_v2', 'reference_model')
      model_root = PrimeCorpus.root(reference['root']); model_files = reference['files']
      PrimeCorpus.require!(model_files.is_a?(Array) && model_files.map { |f| f['role'] }.sort == REFERENCE_PATHS.keys.sort, 'reference_roles')
      model_bindings = []; model_json = {}
      model_files.each do |f|
        PrimeCorpus.require!(f['path'] == REFERENCE_PATHS.fetch(f['role']), 'reference_path')
        bytes, binding = read(File.join(model_root, f['path']), f['role'] == 'weights' ? 160 * 1024 * 1024 : 1024 * 1024, f, f['role'] != 'weights')
        model_bindings << binding.merge('role' => f['role'])
        model_json[f['role']] = PrimeCorpus.parse(bytes) if f['role'].end_with?('manifest')
      end
      tm = model_json.fetch('train_manifest'); tok = model_json.fetch('tokenizer_manifest')
      spm = model_bindings.find { |f| f['role'] == 'tokenizer_model' }
      PrimeCorpus.require!(tm['model_family_id'] == reference['modelID'] && tm['tokenizer_id'] == 'prime_native_bpe_v1' &&
        tm['vocab_size'] == 8192 && tok['tokenizer_id'] == 'prime_native_bpe_v1' && tok['vocab_size'] == 8192 &&
        tm['spm_sha256'] == spm['sha256'], 'reference_tokenizer_join')
      write('pending-model-sidecar.json', PrimeCorpus.json('schema' => 'prime_corpus_pending_model_sidecar_v1',
        'status' => 'untrained_pending', 'referenceModelID' => reference['modelID'], 'referenceFiles' => model_bindings,
        'candidateCorpusManifest' => native_manifest, 'tokenizerReplaced' => false, 'trainingPerformed' => false,
        'approved' => false, 'modelTrainedOnStagedCorpus' => false, 'checkpointCompatibility' => 'not_established'))
      write('source-bindings.json', PrimeCorpus.json('registry' => registry_binding, 'files' => @source_bindings,
        'revisionScope' => 'registry-declared revisions; listed file bytes independently hashed'))
      revalidate
      receipt = { 'schema' => 'prime_corpus_stage_result_v1', 'status' => 'staged_untrained_pending',
        'toolVersion' => VERSION, 'toolSHA256' => Digest::SHA256.file(__FILE__).hexdigest, 'registry' => registry_binding,
        'splitPolicy' => SPLIT, 'renderFormat' => FORMAT, 'recordCount' => records.size,
        'positiveCount' => records.count { |r| r['polarity'] == 'positive' },
        'negativeCount' => records.count { |r| r['polarity'] == 'negative' },
        'trainPositiveCount' => train.size, 'holdoutPositiveCount' => holdout.size,
        'excludedPositiveCount' => records.count { |r| r['polarity'] == 'positive' && !r['eligiblePositive'] },
        'trainFamilies' => train.map { |r| r['family'] }.uniq.sort, 'holdoutFamilies' => holdout.map { |r| r['family'] }.uniq.sort,
        'trainingPerformed' => false, 'tokenizerReplaced' => false, 'approved' => false, 'outputs' => @outputs.dup }
      write('COMPLETE.json', PrimeCorpus.json(receipt))
      puts PrimeCorpus.json('status' => receipt['status'], 'output' => @output, 'records' => records.size,
        'trainPositiveCount' => train.size, 'holdoutPositiveCount' => holdout.size)
      receipt
    rescue StandardError => e
      if @output && !File.exist?(File.join(@output, 'COMPLETE.json'))
        begin
          write('FAILED.json', PrimeCorpus.json('status' => 'staging_failed', 'errorClass' => e.class.name, 'trainingPerformed' => false))
        rescue StandardError
          # Original exception remains the failure; partial outputs are never a completed stage.
        end
      end
      raise
    ensure
      @held.each { |file, _, _| file.close unless file.closed? }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    PrimeCorpus.require!(ARGV.length == 4 && ARGV[0] == '--registry' && ARGV[2] == '--output', 'usage_--registry_PATH_--output_FRESH_DIRECTORY')
    PrimeCorpus::Stage.new.run(ARGV[1], ARGV[3])
  rescue StandardError => e
    warn "Prime corpus staging failed: #{e.class}: #{e.message.to_s[0, 240]}"
    exit 1
  end
end

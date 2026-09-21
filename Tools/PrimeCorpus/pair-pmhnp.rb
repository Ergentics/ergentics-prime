#!/usr/bin/env ruby
# Adapt existing LM0 exports. No training, model invocation, or source mutation.
require_relative 'stage'

begin
  PrimeCorpus.require!(ARGV.size == 4 && ARGV[0] == '--source' && ARGV[2] == '--output',
    'usage_--source_PINNED_RAW_COMPANION_ROOT_--output_FRESH_DIRECTORY')
  source = PrimeCorpus.root(ARGV[1]); output = ARGV[3]
  PrimeCorpus.require!(output.start_with?('/') && File.expand_path(output) == output &&
    !output.start_with?(source + '/'), 'invalid_output')
  PrimeCorpus.root(File.dirname(output))
  rows = {}; inputs = []
  %w[train val holdout].each do |split|
    path = File.join(source, "content-staging/prime-lm0-#{split}.jsonl")
    PrimeCorpus.require!(File.realpath(path) == path && File.file?(path) &&
      File.size(path).between?(1, 16 * 1024 * 1024), 'input_path_or_size')
    bytes = File.binread(path)
    inputs << {path: path, byteCount: bytes.bytesize, sha256: Digest::SHA256.hexdigest(bytes), split: split}
    rows[split] = bytes.lines.map.with_index(1) do |line, index|
      row = PrimeCorpus.parse(line)
      %w[prompt evidenceSpan kind oracleRef].each do |key|
        PrimeCorpus.require!(PrimeCorpus.string(row[key]), "missing_#{key}")
      end
      { row: row, line: index, inputSHA256: inputs.last[:sha256],
        question: row['prompt'].strip.unicode_normalize(:nfc) }
    end
    PrimeCorpus.require!(rows[split].size.between?(1, 25_000), 'row_count')
  end
  held_questions = (rows['val'] + rows['holdout']).map { |r| r[:question] }.to_set
  removed = rows['train'].select { |r| held_questions.include?(r[:question]) }
  selected = rows.merge('train' => rows['train'].reject { |r| held_questions.include?(r[:question]) })
  PrimeCorpus.require!(!selected['train'].empty?, 'no_training_pairs')
  Dir.mkdir(output, 0700)
  bindings = []
  write = lambda do |relative, text|
    path = File.join(output, relative)
    File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0600) { |f| f.write(text) }
    binding = {path: relative, byteCount: text.bytesize, sha256: Digest::SHA256.hexdigest(text)}
    bindings << binding
    binding
  end
  # JSON string quoting keeps internal newlines in the same physical training sample.
  # Read back with JSON.parse to recover each original field exactly; no text truncation.
  selected.each do |split, records|
    write.call("#{split}.txt", records.map { |r|
      "PROBLEM: #{JSON.generate(r[:row]['prompt'])} ANSWER: #{JSON.generate(r[:row]['evidenceSpan'])}\n"
    }.join)
  end
  index = rows.flat_map do |split, records|
    records.map { |r| {sourceSplit: split, sourceLine: r[:line], inputSHA256: r[:inputSHA256],
      kind: r[:row]['kind'], sourceOracleRef: r[:row]['oracleRef'],
      selection: split == 'train' && held_questions.include?(r[:question]) ? 'raw_only_question_in_evaluation' : split} }
  end
  write.call('record-index.jsonl', index.map { |row| JSON.generate(row) + "\n" }.join)
  overlap = rows['val'].map { |r| r[:question] }.to_set & rows['holdout'].map { |r| r[:question] }.to_set
  report = {schema: 'prime_pmhnp_paired_candidate_v1', inputs: inputs,
    originalRows: rows.transform_values(&:size), selectedRows: selected.transform_values(&:size),
    removedTrainRowsWithEvaluationQuestion: removed.size,
    validationHoldoutSharedQuestions: overlap.size,
    splitPolicy: 'Preserve existing source split; remove training questions also present in validation or holdout. Evaluation overlap is reported, not relabeled.',
    format: PrimeCorpus::FORMAT, preservesAllInputFieldsInRawSource: true,
    additionalTextTruncation: false, upstreamTruncationRepaired: false,
    trainingPerformed: false, clinicalRecertificationPerformed: false,
    outputs: bindings}
  write.call('COMPLETE.json', JSON.pretty_generate(report) + "\n")
  puts JSON.generate(report.reject { |k, _| %i[inputs outputs].include?(k) })
rescue StandardError => e
  warn "PMHNP pairing failed: #{e.class}: #{e.message.to_s[0, 200]}"
  exit 1
end

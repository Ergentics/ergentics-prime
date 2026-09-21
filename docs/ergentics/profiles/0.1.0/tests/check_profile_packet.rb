#!/usr/bin/env ruby
require 'json'
require 'digest'
require 'fileutils'
require 'timeout'
require_relative '../scripts/profile_packet'

EP = ErgenticsProfiles
SOURCE = File.expand_path('..', __dir__)
options = {}
ARGV.each_slice(2) { |key, value| options[key] = value }
raise 'Use --agent-root ABSOLUTE --work NEW_ABSOLUTE_DIRECTORY' unless options.keys.sort == %w[--agent-root --work].sort
AGENTS = options.fetch('--agent-root')
WORK = options.fetch('--work')
raise 'Evidence directory already exists' if File.exist?(WORK)
FileUtils.mkdir_p(WORK)
RESULTS = []

def assert(value, message)
  raise message unless value
end

def put_json(path, object)
  File.write(path, JSON.pretty_generate(object) + "\n")
  Digest::SHA256.file(path).hexdigest
end

def seal_manifest(root)
  rows = Dir.glob(File.join(root, '**', '*')).select { |p| File.file?(p) && p != File.join(root, 'MANIFEST.json') }.sort.map do |path|
    {'path' => path.delete_prefix(root + '/'), 'bytes' => File.size(path), 'sha256' => Digest::SHA256.file(path).hexdigest}
  end
  put_json(File.join(root, 'MANIFEST.json'), {'schema' => 'ergentics.profile-manifest.v1', 'name' => 'ergentics-profiles', 'version' => '0.1.0', 'owner' => 'Ergentics, LLC', 'files' => rows})
end

def fixture(name, profile_id = 'ergentics_swift_c')
  root = File.join(WORK, name)
  FileUtils.mkdir_p(root)
  profiles = File.join(root, 'profiles')
  FileUtils.cp_r(SOURCE, profiles)
  corpus = File.join(root, 'corpus')
  FileUtils.cp_r(File.join(SOURCE, 'corpus'), corpus)
  policy = File.join(root, 'synthetic-policy.txt')
  File.write(policy, "Synthetic policy binding for helper regression only. This text grants no authority.\n")
  index = JSON.parse(File.read(File.join(corpus, 'INDEX.json')))
  names = ['evidence-stages', 'bounded-polling-control', profile_id == 'ergentics_swift_c' ? 'swift-c-boundary' : 'cpp-file-identity']
  req = {
    'schema' => 'ergentics.profile-request.v1', 'run_id' => name, 'profile_id' => profile_id, 'profile_version' => '0.1.0',
    'assignment' => 'Synthetic packet helper regression; do not dispatch a model.',
    'authority' => 'User-authorized local profile preparation; this fixture itself grants no new permission.',
    'purpose' => 'profile_validation',
    'requested' => {'adapter' => 'codex_explicit', 'model' => 'gpt-5.6-terra', 'reasoning_effort' => 'medium', 'context' => {'mode' => 'fresh', 'inherited_context' => 'none requested'}, 'tools' => ['read selected packet', 'write assigned result']},
    'processing' => {'mode' => 'hosted', 'recipient' => 'codex-task', 'provider' => 'OpenAI', 'retention_evidence' => 'unverified; no provider-setting assertion'},
    'budget' => {'max_context_bytes' => 131072, 'max_output_bytes' => 16384, 'deadline_seconds' => 60, 'max_entries' => 8},
    'selection' => names.map { |id| index['entries'].find { |e| e['id'] == id }.select { |k, _| %w[id version sha256].include?(k) } },
    'bindings' => {
      'profiles' => {'root' => profiles, 'sha256' => seal_manifest(profiles)},
      'agents' => {'root' => AGENTS, 'sha256' => Digest::SHA256.file(File.join(AGENTS, 'MANIFEST.json')).hexdigest},
      'policy' => {'path' => policy, 'id' => 'EA-POLICY-001', 'version' => '0.4.1', 'sha256' => Digest::SHA256.file(policy).hexdigest},
      'corpus' => {'root' => corpus, 'index_sha256' => Digest::SHA256.file(File.join(corpus, 'INDEX.json')).hexdigest}
    }, 'extensions' => {}
  }
  {root: root, profiles: profiles, corpus: corpus, index: index, request: req, output: File.join(root, 'packet'), request_path: File.join(root, 'request.json')}
end

def update_index(f)
  f[:request]['bindings']['corpus']['index_sha256'] = put_json(File.join(f[:corpus], 'INDEX.json'), f[:index])
end

def prepare(f, reader = EP::Reader.new, writer_hook = nil)
  sha = put_json(f[:request_path], f[:request])
  result = EP.prepare(request_path: f[:request_path], request_sha: sha, output: f[:output], reader: reader, writer_hook: writer_hook)
  [result, reader, JSON.parse(File.read(File.join(f[:output], 'RECEIPT.json')))]
end

def negative(f, expected, payload_reads: 0, reader: EP::Reader.new)
  sha = put_json(f[:request_path], f[:request])
  begin
    EP.prepare(request_path: f[:request_path], request_sha: sha, output: f[:output], reader: reader)
    raise 'Unexpected acceptance'
  rescue EP::Rejected => error
    assert(error.code == expected, "Expected #{expected}, got #{error.code}")
  end
  count = reader.ledger.count { |r| r['kind'] == 'corpus_payload' }
  assert(count == payload_reads, "Expected #{payload_reads} corpus reads, got #{count}")
  assert(!File.exist?(f[:output]), 'Rejected request created output')
  {'expected_rejection' => expected, 'corpus_reads' => count, 'read_ledger' => reader.ledger}
end

def check(name)
  observation = Timeout.timeout(8) { yield }
  RESULTS << {'id' => name, 'result' => 'PASS', 'observation' => observation}
rescue StandardError => error
  RESULTS << {'id' => name, 'result' => 'FAIL', 'error_class' => error.class.name, 'error' => error.message}
end

check('accepted-shared-and-scoped-selection') do
  f = fixture('accepted-shared-and-scoped-selection')
  File.write(File.join(f[:corpus], 'unindexed-sentinel.txt'), 'SYNTHETIC UNSELECTED: must not be read')
  result, reader, receipt = prepare(f)
  selected = reader.ledger.select { |r| r['kind'] == 'corpus_payload' }
  assert(selected.length == 3, 'Selection not exact')
  assert(selected.none? { |r| r['path'].include?('unindexed') }, 'Unindexed data read')
  assert(receipt['observed_execution']['model_context_ingestion'] == 'NOT_OBSERVED', 'Invented model ingest')
  assert(receipt['observed_execution']['served_model'] == 'unknown', 'Requested model copied as observed')
  assert(receipt['requested']['model'] == 'gpt-5.6-terra', 'Requested setting lost')
  assert(!File.exist?(File.join(f[:output], 'INCOMPLETE')), 'Unfinished marker remained')
  assert((File.stat(f[:output]).mode & 0222) == 0, 'Output directory not read-only')
  receipt['files'].each do |row|
    path = File.join(f[:output], row['path'])
    assert(Digest::SHA256.file(path).hexdigest == row['sha256'] && (File.stat(path).mode & 0222) == 0, 'Output file binding/mode')
  end
  result.merge('no_unselected_read' => true, 'observed_not_inferred' => true)
end

check('second-profile-shared-corpus') do
  f = fixture('second-profile-shared-corpus', 'ergentics_cpp')
  result, _, receipt = prepare(f)
  assert(receipt['selected_entries'].map { |e| e['id'] }.include?('cpp-file-identity'), 'Missing role-specific entry')
  result
end

%w[candidate withheld].each do |status|
  check('review-' + status) do
    f = fixture('review-' + status)
    f[:index]['entries'].find { |e| e['id'] == 'swift-c-boundary' }['review']['status'] = status
    update_index(f)
    negative(f, 'entry_not_reviewed')
  end
end

{
  'wrong-profile-scope' => ['profile_ids', ['ergentics_cpp'], 'entry_profile_scope'],
  'wrong-purpose' => ['purposes', ['different_task'], 'entry_purpose_scope'],
  'local-only-to-hosted' => ['routes', [{'recipient' => 'local-packet', 'processing' => 'local_preparation'}], 'entry_processing_scope'],
  'holdout-answer' => ['kind', 'holdout_answer', 'entry_kind_not_allowed'],
  'credential-class' => ['material_class', 'credential', 'entry_material_not_allowed'],
  'raw-history-class' => ['material_class', 'raw_history', 'entry_material_not_allowed']
}.each do |name, values|
  check(name) do
    f = fixture(name)
    f[:index]['entries'].find { |e| e['id'] == 'swift-c-boundary' }[values[0]] = values[1]
    update_index(f)
    negative(f, values[2])
  end
end

check('unselected-withheld-payload-never-opened') do
  f = fixture('unselected-withheld-payload-never-opened')
  e = f[:index]['entries'].find { |x| x['id'] == 'cpp-file-identity' }
  e['review']['status'] = 'withheld'
  File.unlink(File.join(f[:corpus], e['path']))
  update_index(f)
  result, reader, = prepare(f)
  assert(reader.ledger.none? { |r| r['path'] == File.join(f[:corpus], e['path']) }, 'Withheld file opened')
  result
end

check('selected-payload-hash-drift') do
  f = fixture('selected-payload-hash-drift')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  bytes = File.binread(path)
  bytes.setbyte(0, bytes.getbyte(0) == 35 ? 33 : 35)
  File.binwrite(path, bytes)
  reader = EP::Reader.new
  outcome = negative(f, 'content_hash_mismatch', payload_reads: 1, reader: reader)
  row = reader.ledger.find { |x| x['kind'] == 'corpus_payload' }
  assert(row['status'] == 'rejected_after_read' && row['sha256'] == Digest::SHA256.hexdigest(bytes), 'Rejected-read identity missing')
  outcome
end

check('wrong-policy-pin-before-corpus-read') do
  f = fixture('wrong-policy-pin-before-corpus-read')
  f[:request]['bindings']['policy']['sha256'] = '0' * 64
  negative(f, 'content_hash_mismatch')
end

check('wrong-external-request-pin') do
  f = fixture('wrong-external-request-pin')
  put_json(f[:request_path], f[:request])
  reader = EP::Reader.new
  begin
    EP.prepare(request_path: f[:request_path], request_sha: '0' * 64, output: f[:output], reader: reader)
    raise 'Unexpected acceptance'
  rescue EP::Rejected => e
    assert(e.code == 'content_hash_mismatch', e.code)
  end
  assert(reader.ledger.length == 1 && !File.exist?(f[:output]), 'Read beyond invalid request')
  {'request_reads' => 1, 'other_reads' => 0}
end

check('relative-path-traversal') do
  f = fixture('relative-path-traversal')
  f[:index]['entries'][0]['path'] = '../outside.txt'
  update_index(f)
  negative(f, 'relative_path')
end

check('selected-symlink-before-payload-read') do
  f = fixture('selected-symlink-before-payload-read')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  File.rename(path, path + '.original')
  File.symlink(path + '.original', path)
  negative(f, 'nonregular_or_link')
end

check('fifo-rejected-without-blocking-read') do
  f = fixture('fifo-rejected-without-blocking-read')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  File.unlink(path)
  assert(system('/usr/bin/mkfifo', path), 'Synthetic FIFO creation failed')
  negative(f, 'nonregular_or_link')
end

check('named-file-replaced-during-read') do
  f = fixture('named-file-replaced-during-read')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  replacement = File.binread(path)
  reader = EP::Reader.new(lambda do |event, name|
    if event == :after_read && name == path
      File.rename(path, path + '.original')
      File.binwrite(path, replacement)
    end
  end)
  negative(f, 'changed_during_read', payload_reads: 1, reader: reader)
end

check('file-removed-during-read-preserves-ledger') do
  f = fixture('file-removed-during-read-preserves-ledger')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  reader = EP::Reader.new(lambda { |event, name| File.unlink(path) if event == :after_read && name == path })
  outcome = negative(f, 'missing_or_changed_path', payload_reads: 1, reader: reader)
  row = reader.ledger.find { |r| r['kind'] == 'corpus_payload' }
  assert(row['status'] == 'rejected_after_read' && row['sha256'] == f[:index]['entries'][0]['sha256'], 'Read evidence lost on path removal')
  outcome
end

check('ancestor-replaced-during-read') do
  f = fixture('ancestor-replaced-during-read')
  path = File.join(f[:corpus], f[:index]['entries'][0]['path'])
  parent = File.dirname(path)
  reader = EP::Reader.new(lambda do |event, name|
    if event == :after_read && name == path
      File.rename(parent, parent + '.original')
      Dir.mkdir(parent)
      File.link(File.join(parent + '.original', File.basename(path)), path)
    end
  end)
  negative(f, 'changed_during_read', payload_reads: 1, reader: reader)
end

check('empty-eligible-content') do
  f = fixture('empty-eligible-content')
  entry = f[:index]['entries'][0]
  File.write(File.join(f[:corpus], entry['path']), '')
  entry['bytes'] = 0; entry['sha256'] = Digest::SHA256.hexdigest('')
  f[:request]['selection'][0]['sha256'] = entry['sha256']
  update_index(f)
  prepare(f).first
end

check('duplicate-json-keys') do
  f = fixture('duplicate-json-keys')
  File.write(f[:request_path], '{"schema":"a","schema":"b"}')
  reader = EP::Reader.new
  begin
    EP.prepare(request_path: f[:request_path], request_sha: Digest::SHA256.file(f[:request_path]).hexdigest, output: f[:output], reader: reader)
    raise 'Duplicate keys accepted'
  rescue EP::Rejected => e
    assert(e.code == 'duplicate_json_key', e.code)
  end
  {'rejection' => 'duplicate_json_key', 'reads' => reader.ledger.length}
end

check('manifest-array-shape') do
  f = fixture('manifest-array-shape')
  f[:request]['bindings']['profiles']['sha256'] = put_json(File.join(f[:profiles], 'MANIFEST.json'), [])
  negative(f, 'manifest_shape')
end

check('typed-request-identity') do
  f = fixture('typed-request-identity')
  f[:request]['run_id'] = 19
  negative(f, 'request_identity')
end

check('typed-corpus-root') do
  f = fixture('typed-corpus-root')
  f[:request]['bindings']['corpus']['root'] = []
  negative(f, 'expected_string')
end

check('typed-profile-version') do
  f = fixture('typed-profile-version')
  path = File.join(f[:profiles], 'profiles/ergentics_swift_c.json')
  profile = JSON.parse(File.read(path))
  profile['version'] = []
  put_json(path, profile)
  f[:request]['bindings']['profiles']['sha256'] = seal_manifest(f[:profiles])
  negative(f, 'profile_identity')
end

check('unknown-field-rejected') do
  f = fixture('unknown-field-rejected')
  f[:request]['secret_extra_work'] = 'not executed'
  negative(f, 'unknown_field')
end

check('namespaced-extension-inert') do
  f = fixture('namespaced-extension-inert')
  f[:request]['extensions'] = {'test.future_field' => {'requested_action' => 'not executed', 'path' => '/synthetic/never-read'}}
  result, reader, = prepare(f)
  assert(reader.ledger.none? { |r| r['path'] == '/synthetic/never-read' }, 'Extension executed/read')
  result
end

check('budget-rejected-before-corpus-read') do
  f = fixture('budget-rejected-before-corpus-read')
  f[:request]['budget']['max_context_bytes'] = 1
  negative(f, 'context_byte_budget')
end

check('duplicate-selection') do
  f = fixture('duplicate-selection')
  f[:request]['selection'] << f[:request]['selection'][0].dup
  negative(f, 'duplicate_selection')
end

check('duplicate-index-entry') do
  f = fixture('duplicate-index-entry')
  f[:index]['entries'] << f[:index]['entries'][0].dup
  update_index(f)
  negative(f, 'duplicate_corpus_entry')
end

check('local-preparation-no-inference-claim') do
  f = fixture('local-preparation-no-inference-claim')
  f[:request]['requested']['adapter'] = 'packet_only'
  f[:request]['requested']['model'] = 'local-model:unimplemented-test-selector'
  f[:request]['processing'] = {'mode' => 'local_preparation', 'recipient' => 'local-packet', 'provider' => 'not invoked', 'retention_evidence' => 'no inference performed'}
  result, _, receipt = prepare(f)
  assert(receipt['observed_execution']['model_dispatch'] == 'NOT_PERFORMED', 'Local preparation became inference')
  result
end

check('relocated-roots-and-spaces') do
  f = fixture('relocated-roots-and-spaces')
  relocated = File.join(f[:root], 'relocated space')
  FileUtils.mkdir_p(relocated)
  new_agents = File.join(relocated, 'agent dependency')
  FileUtils.cp_r(AGENTS, new_agents)
  new_profiles = File.join(relocated, 'profile package')
  new_corpus = File.join(relocated, 'selected corpus')
  FileUtils.cp_r(f[:profiles], new_profiles)
  FileUtils.cp_r(f[:corpus], new_corpus)
  f[:request]['bindings']['agents']['root'] = new_agents
  f[:request]['bindings']['profiles']['root'] = new_profiles
  f[:request]['bindings']['corpus']['root'] = new_corpus
  result, _, receipt = prepare(f)
  assert(receipt['files'].find { |x| x['path'] == 'agent/agents/ergentics_swift_c/AGENT.md' }['sha256'] == Digest::SHA256.file(File.join(AGENTS, 'agents/ergentics_swift_c/AGENT.md')).hexdigest, 'Relocation changed role')
  result.merge('scope' => 'Filesystem relocation only; no other backend invoked')
end

check('collision-preserves-original') do
  f = fixture('collision-preserves-original')
  prepare(f)
  before = Digest::SHA256.file(File.join(f[:output], 'RECEIPT.json')).hexdigest
  begin
    prepare(f)
    raise 'Existing output overwritten'
  rescue EP::Rejected => e
    assert(e.code == 'output_exists', e.code)
  end
  assert(before == Digest::SHA256.file(File.join(f[:output], 'RECEIPT.json')).hexdigest, 'Original changed')
  {'original_unchanged' => true, 'rejection' => 'output_exists'}
end

check('partial-write-retains-incomplete') do
  f = fixture('partial-write-retains-incomplete')
  calls = 0
  begin
    prepare(f, EP::Reader.new, lambda { |_name| calls += 1; raise IOError, 'synthetic write failure' if calls == 2 })
    raise 'Injected failure ignored'
  rescue IOError
    assert(File.exist?(File.join(f[:output], 'INCOMPLETE')), 'Missing incomplete marker')
    assert(!File.exist?(File.join(f[:output], 'RECEIPT.json')), 'Partial packet looks complete')
  end
  {'incomplete_preserved' => true, 'completed_receipt' => false}
end

check('directory-sealing-failure-restores-incomplete') do
  f = fixture('directory-sealing-failure-restores-incomplete')
  original = File.method(:chmod)
  File.define_singleton_method(:chmod) do |mode, *paths|
    raise Errno::EACCES, 'synthetic directory sealing failure' if mode == 0500 && paths.include?(File.join(f[:output], 'agent'))
    original.call(mode, *paths)
  end
  begin
    prepare(f)
    raise 'Sealing failure ignored'
  rescue Errno::EACCES
    assert(File.exist?(File.join(f[:output], 'INCOMPLETE')), 'Finalization failure lost marker')
    assert(File.exist?(File.join(f[:output], 'RECEIPT.json')), 'Expected completed bytes before sealing failure')
  ensure
    File.define_singleton_method(:chmod, &original)
  end
  {'sealing_failure_rejected' => true, 'incomplete_restored' => true, 'receipt_alone_not_completion' => true}
end

def promotion_fixture(name)
  f = fixture(name)
  body = "Authored synthetic contribution: a prepared packet is distinct from an observed model load.\n"
  path = 'new-lesson.md'
  File.write(File.join(f[:root], path), body)
  candidate = f[:index]['entries'][0].merge('id' => 'prepared-versus-loaded', 'path' => path, 'bytes' => body.bytesize, 'sha256' => Digest::SHA256.hexdigest(body), 'origin' => 'Synthetic contribution test; no historical or private payload.')
  evidence = {}
  %w[positive_evidence golden_negative_evidence].each do |kind|
    file = File.join(f[:root], kind + '.json')
    sha = put_json(file, {'schema' => 'ergentics.corpus-review-check.v1', 'candidate_sha256' => candidate['sha256'], 'kind' => kind, 'result' => 'PASS', 'method' => 'Synthetic evidence-join fixture; not a claimed application test.', 'observation' => kind == 'positive_evidence' ? 'Prepared packet remains prepared.' : 'Preparation must not be relabelled as model ingestion.'})
    evidence[kind] = {'path' => file, 'sha256' => sha}
  end
  request = {'schema' => 'ergentics.corpus-promotion.v1', 'authority' => 'Synthetic local contribution packaging test', 'source' => {'root' => f[:root]}, 'candidate' => candidate, 'review' => {'status' => 'accepted', 'reviewer' => candidate['review']['reviewer']}.merge(evidence), 'corpus' => {'id' => 'test-contribution', 'version' => '0.1.0', 'owner' => 'Ergentics, LLC'}, 'extensions' => {}}
  f.merge(promotion: request)
end

check('reviewed-promotion-and-consumption') do
  f = promotion_fixture('reviewed-promotion-and-consumption')
  sha = put_json(f[:request_path], f[:promotion])
  promoted = File.join(f[:root], 'contribution')
  original_index_hash = f[:request]['bindings']['corpus']['index_sha256']
  result = EP.promote(request_path: f[:request_path], request_sha: sha, output: promoted)
  contribution = JSON.parse(File.read(File.join(promoted, 'INDEX.json')))['entries'][0]
  audit = contribution['extensions']['ergentics.promotion']
  assert(audit['request_sha256'] == sha && audit['review_evidence'].keys.sort == %w[golden_negative_evidence positive_evidence], 'Promotion lineage not carried forward')
  assert(audit['source_relative_path'] == 'new-lesson.md' && audit['source_locator_meaning'].include?('never automatically opened'), 'Portable lineage meaning missing')
  assert(original_index_hash == Digest::SHA256.file(File.join(f[:corpus], 'INDEX.json')).hexdigest, 'Old corpus mutated')
  f[:request]['bindings']['corpus'] = {'root' => promoted, 'index_sha256' => result['index_sha256']}
  f[:request]['selection'] = [f[:promotion]['candidate'].select { |k, _| %w[id version sha256].include?(k) }]
  consumed, _, = prepare(f)
  {'promotion' => result, 'receiving_packet' => consumed, 'old_corpus_unchanged' => true}
end

check('promotion-reserved-lineage-before-read') do
  f = promotion_fixture('promotion-reserved-lineage-before-read')
  f[:promotion]['candidate']['extensions'] = {'ergentics.promotion' => {'forged' => true}}
  sha = put_json(f[:request_path], f[:promotion])
  reader = EP::Reader.new
  begin
    EP.promote(request_path: f[:request_path], request_sha: sha, output: f[:output], reader: reader)
    raise 'Prewritten reserved lineage accepted'
  rescue EP::Rejected => e
    assert(e.code == 'reserved_promotion_extension', e.code)
  end
  assert(reader.ledger.none? { |r| r['kind'] == 'promotion_candidate' }, 'Read before lineage check')
  {'candidate_reads' => 0, 'reserved_lineage_rejected' => true}
end

check('promotion-requires-review') do
  f = promotion_fixture('promotion-requires-review')
  f[:promotion]['review']['status'] = 'candidate'
  sha = put_json(f[:request_path], f[:promotion])
  reader = EP::Reader.new
  begin
    EP.promote(request_path: f[:request_path], request_sha: sha, output: f[:output], reader: reader)
    raise 'Unreviewed contribution accepted'
  rescue EP::Rejected => e
    assert(e.code == 'promotion_not_reviewed', e.code)
  end
  assert(reader.ledger.none? { |r| r['kind'] == 'promotion_candidate' }, 'Unreviewed candidate read')
  {'candidate_reads' => 0}
end

check('promotion-negative-evidence-identity') do
  f = promotion_fixture('promotion-negative-evidence-identity')
  pin = f[:promotion]['review']['golden_negative_evidence']
  record = JSON.parse(File.read(pin['path']))
  record['candidate_sha256'] = '0' * 64
  pin['sha256'] = put_json(pin['path'], record)
  sha = put_json(f[:request_path], f[:promotion])
  reader = EP::Reader.new
  begin
    EP.promote(request_path: f[:request_path], request_sha: sha, output: f[:output], reader: reader)
    raise 'Wrong evidence joined'
  rescue EP::Rejected => e
    assert(e.code == 'promotion_evidence_mismatch', e.code)
  end
  assert(reader.ledger.none? { |r| r['kind'] == 'promotion_candidate' }, 'Candidate read before valid review')
  {'candidate_reads' => 0, 'rejection' => 'promotion_evidence_mismatch'}
end

report = {'schema' => 'ergentics.profile-helper-checks.v1', 'tool_version' => EP::VERSION, 'ruby' => RUBY_DESCRIPTION, 'helper_sha256' => Digest::SHA256.file(File.join(SOURCE, 'scripts/profile_packet.rb')).hexdigest, 'cases' => RESULTS, 'passed' => RESULTS.count { |x| x['result'] == 'PASS' }, 'failed' => RESULTS.count { |x| x['result'] == 'FAIL' }, 'scope' => 'Owned local synthetic fixtures and selected Agent definitions. No model/native-app execution, provider-control verification, hostile-filesystem confinement proof or corpus sweep.'}
put_json(File.join(WORK, 'RESULTS.json'), report)
puts JSON.generate({evidence: WORK, passed: report['passed'], failed: report['failed'], failures: RESULTS.select { |x| x['result'] == 'FAIL' }})
exit(report['failed'] == 0 ? 0 : 1)

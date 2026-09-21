# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require_relative "control-file"

abort("usage: #{$PROGRAM_NAME} CONTROL.json") unless ARGV.length == 1

class V12AuditDuplicateRejectingHash < Hash
  def []=(key, value)
    raise "DUPLICATE_KEY:#{key}" if key?(key)

    super
  end
end

def v12_audit_compact(value)
  JSON.generate(value)
end

def v12_audit_sha(bytes)
  Digest::SHA256.hexdigest(bytes.b)
end

def v12_audit_parse(bytes)
  JSON.parse(
    bytes,
    :object_class => V12AuditDuplicateRejectingHash,
    :array_class => Array,
    :create_additions => false
  )
end

def v12_audit_resolve(root, pointer)
  pointer.split("/").drop(1).reduce(root) do |value, token|
    value.fetch(token.gsub("~1", "/").gsub("~0", "~"))
  end
end

path = ARGV.fetch(0)
raw_control = V12ControlFile.capture(path).bytes
j = v12_audit_parse(raw_control)
x = j.fetch("exact_record_schema_v12")
r = x.fetch("reusable_objects")
s = x.fetch("state_constraint_registry_v12")
d = x.fetch("decision_kernel_v12")

raise "authority" unless
  j.fetch("authority").values_at(
    "authority_vector", "authoritative", "gate_e", "scientific_outcome",
    "prose_may_supply_fact"
  ) == ["00000000", false, "ABSTAIN", "ABSTAIN", false]

observation = s.fetch("observation_integrity_conformance_catalog_v12")
custom = d.fetch("custom_operator_conformance_catalog_v12")
fixture_groups = [
  ["OBSERVATION", observation.fetch("source_fixtures")],
  ["CUSTOM", custom.fetch("fixtures")]
]
fixture_groups.each do |_domain, fixtures|
  raise "fixture ids" unless
    fixtures.map { |fixture| fixture.fetch("fixture_id") }.uniq.length ==
      fixtures.length
  fixtures.each do |fixture|
    bytes = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
    raise "fixture bytes #{fixture.fetch("fixture_id")}" unless
      bytes.bytesize == fixture.fetch("bytes_uint")
    raise "fixture hash #{fixture.fetch("fixture_id")}" unless
      v12_audit_sha(bytes) == fixture.fetch("sha256")
    parsed = v12_audit_parse(bytes)
    raise "fixture canonical #{fixture.fetch("fixture_id")}" unless
      v12_audit_compact(parsed).b == bytes.b
  end
end

boundary_sources = fixture_groups.flat_map do |domain, fixtures|
  fixtures.sort_by { |fixture| fixture.fetch("fixture_id") }.map do |fixture|
    Marshal.load(Marshal.dump(fixture)).merge(
      "fixture_id" => "#{domain}/#{fixture.fetch("fixture_id")}"
    )
  end
end
boundary = d.fetch("production_journal_boundary_install_receipt_v12")
raise "boundary universe" unless
  boundary.fetch("assessed_source_fixture_count_uint") == 604 &&
  boundary.fetch("assessed_source_domains_exact_order") ==
    %w[OBSERVATION CUSTOM] &&
  boundary.fetch("assessed_source_order_rule_enum") ==
    "DOMAIN_DECLARATION_THEN_ASCII_FIXTURE_ID" &&
  boundary.fetch("assessed_source_fixtures_sha256") ==
    v12_audit_sha(v12_audit_compact(boundary_sources))
raise "boundary state" unless
  boundary.values_at(
    "state_enum", "blocking_dependency_id", "production_body_emitted_bool",
    "production_frame_emitted_bool", "production_catalog_emitted_bool",
    "production_catalog_key_absent_bool"
  ) == [
    "MISSING_TYPED_DEPENDENCY",
    "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME",
    false, false, false, true
  ]
raise "production catalog" if
  d.key?("production_journal_conformance_fixture_catalog_v12")
raise "retired schema" if
  v12_audit_compact(j).include?("ergentics.conformance.operation-frame.v12")

static = d.fetch("static_model_journal_algebra_catalog_v12")
static_predigest = {}
static.keys.first(8).each do |key|
  static_predigest[key] = static.fetch(key)
end
raise "static payload" unless
  static.fetch("catalog_payload_sha256") ==
    v12_audit_sha(v12_audit_compact(static_predigest))
entries = static.fetch("entries")
raise "static counts" unless
  [entries.length, static.fetch("predecessor_edges").length] == [6, 5]
envelope_keys = x.dig("records", "journal", "envelope_keys_exact_ordered")
frame_hashes = []
entries.each_with_index do |entry, index|
  raw = entry.fetch("complete_frame_raw_bytes")
  bytes = Base64.strict_decode64(raw.fetch("base64"))
  frame_hash = v12_audit_sha(bytes)
  frame_hashes << frame_hash
  raise "raw identity #{index}" unless
    [bytes.bytesize, frame_hash] ==
      [raw.fetch("bytes_uint"), raw.fetch("sha256")]
  raise "LF #{index}" unless
    bytes.end_with?("\n") && bytes.count("\n") == 1
  json = bytes.delete_suffix("\n")
  envelope = v12_audit_parse(json)
  raise "frame canonical #{index}" unless v12_audit_compact(envelope) == json
  raise "envelope keys #{index}" unless envelope.keys == envelope_keys
  predigest = {}
  envelope.keys.first(7).each { |key| predigest[key] = envelope.fetch(key) }
  raise "frame payload #{index}" unless
    envelope.fetch("payload_sha256") ==
      v12_audit_sha(v12_audit_compact(predigest))
  identity = entry.fetch("frame_identity")
  raise "frame identity #{index}" unless
    identity.fetch("complete_frame_sha256") == frame_hash &&
    identity.fetch("payload_sha256") == envelope.fetch("payload_sha256") &&
    identity.fetch("bytes_uint") == bytes.bytesize
  index_row = static.fetch("index_rows").fetch(index)
  raise "index #{index}" unless
    index_row == [
      index, entry.fetch("fixture_id"),
      v12_audit_sha(v12_audit_compact(entry)), frame_hash,
      envelope.fetch("payload_sha256")
    ]
  if index.zero?
    raise "genesis predecessor" unless
      envelope.fetch(
        "previous_complete_frame_with_lf_sha256_or_null"
      ).nil? && entry.fetch("predecessor_fixture_id_or_null").nil?
  else
    raise "predecessor #{index}" unless
      envelope.fetch("previous_complete_frame_with_lf_sha256_or_null") ==
        frame_hashes.fetch(index - 1) &&
      entry.fetch("predecessor_fixture_id_or_null") ==
        entries.fetch(index - 1).fetch("fixture_id")
  end
end

static.fetch("predecessor_edges").each_with_index do |edge, index|
  left = entries.fetch(index)
  right = entries.fetch(index + 1)
  raise "edge #{index}" unless
    edge.fetch("predecessor_fixture_id") == left.fetch("fixture_id") &&
    edge.fetch("successor_fixture_id") == right.fetch("fixture_id") &&
    edge.fetch("predecessor_complete_frame_sha256") ==
      frame_hashes.fetch(index) &&
    edge.fetch("successor_embedded_predecessor_sha256") ==
      frame_hashes.fetch(index) &&
    edge.fetch("joined_bool") == true
end

merkle = static.fetch("merkle_commitment")
leaf_domain = Base64.strict_decode64(merkle.fetch("leaf_domain_base64"))
node_domain = Base64.strict_decode64(merkle.fetch("node_domain_base64"))
leaves = entries.map do |entry|
  bytes = Base64.strict_decode64(
    entry.dig("complete_frame_raw_bytes", "base64")
  )
  v12_audit_sha(leaf_domain + bytes)
end
raise "merkle leaves" unless leaves == merkle.fetch("ordered_leaf_hashes")
level = leaves.dup
until level.length == 1
  level << level.last if level.length.odd?
  level = level.each_slice(2).map do |left, right|
    v12_audit_sha(
      node_domain + [left].pack("H*") + [right].pack("H*")
    )
  end
end
raise "merkle root" unless level.fetch(0) == merkle.fetch("root_sha256")

profiles = s.fetch("conformance_dependency_profiles_v12")
commitments = s.fetch("conformance_dependency_commitments_v12")
expected_counts = {
  "STATIC_CONTROL" => 50, "CUSTOM_OPERATOR" => 35,
  "TIMING" => 28, "OBSERVATION_INTEGRITY" => 54
}
expected_counts.each do |family, count|
  profile_rows = profiles.fetch(family).fetch("rows_exact")
  commitment = commitments.fetch(family)
  rows = commitment.fetch("rows_exact")
  raise "dependency count #{family}" unless
    profile_rows.length == count && rows.length == count
  rows.zip(profile_rows).each do |committed, profiled|
    raise "dependency identity #{family}" unless
      committed.first(2) == profiled
    raise "dependency digest #{family}/#{committed.fetch(0)}" unless
      committed.fetch(2) ==
        v12_audit_sha(
          v12_audit_compact(v12_audit_resolve(j, profiled.fetch(1)))
        )
  end
  raise "dependency row hash #{family}" unless
    commitment.fetch("rows_sha256") ==
      v12_audit_sha(v12_audit_compact(rows))
end

{
  "ProductionJournalBoundaryInstallReceiptV12" =>
    "production_journal_boundary_install_receipt_v12",
  "StaticModelJournalAlgebraInstallReceiptV12" =>
    "static_model_journal_algebra_install_receipt_v12",
  "StaticModelJournalAlgebraSelfTestReceiptV12" =>
    "static_model_journal_algebra_self_test_receipt_v12",
  "CustomOperatorStaticModelRouteReplayV12" =>
    "custom_operator_static_model_route_replay_v12",
  "CustomOperatorProjectionSourceClosureAssessmentV12" =>
    "custom_operator_projection_source_closure_assessment_v12"
}.each do |type_id, field|
  schema = r.fetch(type_id)
  value = d.fetch(field)
  raise "typed keys #{type_id}" unless value.keys == schema.fetch("keys")
  schema.fetch("constants_exact", {}).each do |key, expected|
    raise "constant #{type_id}/#{key}" unless value.fetch(key) == expected
  end
end

bindings = s.dig(
  "static_control_conformance_catalog_v12", "array_row_bindings_exact"
)
raise "static bindings" unless
  bindings.map { |row| row.fetch(0).split("/").last } == %w[
    check_rows_exact expected_result_rows entries index_rows predecessor_edges
  ]
raise "case counts" unless
  [
    s.dig(
      "static_control_conformance_catalog_v12", "catalog_case_counts_exact",
      "total"
    ),
    observation.fetch("vector_count_uint"),
    observation.fetch("status_selection_vector_count_uint"),
    custom.fetch("vector_count_uint")
  ] == [684, 135, 109, 259]

STDOUT.write(JSON.generate({
  "result" => "PASS",
  "sha256" => v12_audit_sha(raw_control),
  "fixtures" => boundary_sources.length,
  "static_entries" => entries.length,
  "static_edges" => static.fetch("predecessor_edges").length,
  "merkle" => merkle.fetch("root_sha256"),
  "dependencies" => expected_counts,
  "total" => 684
}) + "\n")

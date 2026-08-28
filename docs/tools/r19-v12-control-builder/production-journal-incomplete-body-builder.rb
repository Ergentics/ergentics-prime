# frozen_string_literal: true

require "digest"
require "json"
require_relative "production-journal-conformance-fixtures"

# Scratch-only typed dependency assessment for the synthetic incomplete
# production-journal catalog.  This module intentionally does not emit a body:
# the held V12 schema has no incomplete START record, while every JOURNAL body
# requires an available, recursively valid held START frame.  Encoding an
# invented successful START would convert conformance data into false history.
module V12ProductionJournalIncompleteBodyBuilder
  CATALOG = V12ProductionJournalConformanceFixtures
  FRAME = V12ProductionOperationFrame

  R00_TRANSITION_CUT = {
    "receipt_count_uint" => 31,
    "states_exact" => ["NOT_ENTERED"] * 31,
    "first_unentered_ordinal_uint" => 0,
    "root_and_journal_state_enum" => "ABSENT",
    "watch_state_enum" => "PARTIAL_OR_UNAVAILABLE",
    "timing_state_enum" => "START_ONLY_OR_UNAVAILABLE",
    "publication_successor_join_state_enum" => "NOT_PROVED",
    "selected_status_enum" => "INCOMPLETE_R00"
  }.freeze

  OPERATION_TRANSITION_CUT = {
    "receipt_count_uint" => 4,
    "states_exact" => ["NOT_ENTERED"] * 4,
    "first_unentered_ordinal_uint" => 0,
    "process_state_enum" => "NOT_ATTEMPTED",
    "fixed_outputs_state_enum" => "ABSENT",
    "watch_state_enum" => "PARTIAL_OR_UNAVAILABLE",
    "timing_state_enum" => "NOT_REQUESTED__NOT_ATTEMPTED_OR_UNAVAILABLE",
    "publication_successor_join_state_enum" => "NOT_PROVED",
    "selected_status_enum" => "INCOMPLETE_OPERATION"
  }.freeze

  class MissingTypedDependency < StandardError
    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
      super("MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME:#{JSON.generate(assessment)}")
    end
  end

  module_function

  def compact(value)
    JSON.generate(value)
  end

  def sha256(value)
    Digest::SHA256.hexdigest(value.b)
  end

  def start_impossibility_proof(control)
    records = control.dig("exact_record_schema_v12", "records") || {}
    start = records["start"] || {}
    kernel = control.dig("exact_record_schema_v12", "decision_kernel_v12") || {}
    bindings = kernel.dig("evidence_source_bindings_v12", "START") || []
    profiles = kernel.fetch("evidence_source_profiles_v12", [])
    start_profiles = profiles.select { |row| row.fetch(0) == "START" }
    journal_start_profile = profiles.find do |row|
      row.fetch(0) == "JOURNAL" && row.fetch(1) == "START"
    end
    journal_start_binding = kernel.dig(
      "evidence_source_bindings_v12", "JOURNAL"
    )&.find { |row| row.fetch(0) == "START" }
    rules = kernel.dig("status_rules_v12", "START") || []
    definitions = kernel.fetch("predicate_definitions_v12", [])
    st_accept = definitions.find { |row| row["predicate_id"] == "ST_ACCEPT" }
    accepted_conditions = rules.flat_map do |rule|
      rule.fetch("conditions_all", [])
    end

    exact =
      start.fetch("statuses", nil) == ["START_BODY_ACCEPTED_BUILD_EPOCH_CONSUMED"] &&
      rules.length == 1 &&
      rules.dig(0, "selected_status_enum") ==
        "START_BODY_ACCEPTED_BUILD_EPOCH_CONSUMED" &&
      accepted_conditions == [
        {"predicate_id" => "ST_ACCEPT", "allowed_states_exact_order" => ["TRUE"]}
      ] &&
      journal_start_binding == ["START", "DURABLE_RECORD", true] &&
      journal_start_profile && journal_start_profile.fetch(11) == "MUST_BE_AVAILABLE" &&
      journal_start_profile.fetch(4) == "HELD_RECORD_FRAME" &&
      journal_start_profile.fetch(5) == "/exact_record_schema_v12/records/start" &&
      bindings.all? { |row| row.fetch(2) == true } &&
      start_profiles.all? { |row| row.fetch(11) == "MUST_BE_AVAILABLE" } &&
      st_accept.is_a?(Hash)

    {
      "proof_state_enum" => exact ? "PROVED_IMPOSSIBLE_UNDER_FROZEN_NONAUTHORITY_CONSTRAINT" :
        "HELD_CONTROL_SHAPE_MISMATCH",
      "start_statuses_exact" => start.fetch("statuses", nil),
      "incomplete_or_not_entered_start_status_exists_bool" =>
        Array(start["statuses"]).any? { |status| status.match?(/INCOMPLETE|NOT_ENTERED/) },
      "only_start_status_requires_predicate_id" => "ST_ACCEPT",
      "only_start_status_requires_predicate_state_enum" => "TRUE",
      "st_accept_assertion_program_sha256" => st_accept &&
        sha256(compact(st_accept.fetch("assertion_postfix_program"))),
      "st_accept_direct_predicates_exact" => st_accept ?
        st_accept.fetch("assertion_postfix_program").select { |row| row.fetch(0) == "PRED" }.map { |row| row.fetch(1) } : [],
      "start_required_source_bindings_exact" => bindings,
      "start_all_source_bindings_required_bool" =>
        !bindings.empty? && bindings.all? { |row| row.fetch(2) == true },
      "journal_start_binding_exact" => journal_start_binding,
      "journal_start_profile_exact" => journal_start_profile,
      "nonhistorical_synthetic_start_consequence" =>
        "WOULD_ASSERT_ST_ACCEPT_TRUE_AND_BUILD_EPOCH_CONSUMED_WITH_REQUIRED_DURABLE_IMPLEMENTATION_READINESS_LAUNCH_BINDING_FRAMES_AND_RUNTIME_OBSERVATIONS",
      "blocking_dependency_id" => "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME",
      "body_emission_authorized_bool" => false
    }
  end

  def closure_assessment(control)
    proof = start_impossibility_proof(control)
    {
      "closure_state_enum" => proof.fetch("proof_state_enum") ==
        "PROVED_IMPOSSIBLE_UNDER_FROZEN_NONAUTHORITY_CONSTRAINT" ?
        "MISSING_TYPED_DEPENDENCY" : "HELD_CONTROL_SHAPE_MISMATCH",
      "catalog_plan_exact" => CATALOG.deep_clone(CATALOG::CATALOG_PLAN),
      "catalog_plan_sha256" => sha256(compact(CATALOG::CATALOG_PLAN)),
      "r00_typed_incomplete_cut" => CATALOG.deep_clone(R00_TRANSITION_CUT),
      "operation_typed_incomplete_cut" => CATALOG.deep_clone(OPERATION_TRANSITION_CUT),
      "start_impossibility_proof" => proof,
      "missing_typed_dependency" => {
        "dependency_id" => "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME",
        "required_type" => "HELD_RECORD_FRAME",
        "schema_json_pointer" => "/exact_record_schema_v12/records/start",
        "canonical_form_enum" => "CANONICAL_RECORD_FRAME_EXACT_ONE_LF",
        "availability_enum" => "MUST_BE_AVAILABLE",
        "acceptable_provenance_enum" =>
          "FRESH_NONHISTORICAL_RECURSIVELY_VALID_NONAUTHORITY_SOURCE",
        "available_bool" => false
      },
      "body_emitted_bool" => false,
      "frame_emitted_bool" => false,
      "catalog_emitted_bool" => false
    }
  end

  def body_builders!(control)
    raise MissingTypedDependency.new(closure_assessment(control))
  end

  def build_catalog!(control:, recursive_body_validator:,
                     postpublication_observations: nil)
    builders = body_builders!(control)
    CATALOG.build_catalog!(
      :control => control,
      :body_builders => builders,
      :recursive_body_validator => recursive_body_validator,
      :postpublication_observations => postpublication_observations
    )
  end
end

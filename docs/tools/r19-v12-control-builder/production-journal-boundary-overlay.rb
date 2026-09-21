# frozen_string_literal: true

require "digest"
require "json"
require_relative "production-journal-incomplete-body-builder"

# Installs only the executable assessment of the production START -> R00
# boundary.  It never invokes a body builder and never creates a production
# journal frame, observation, reference, or catalog.  Static-model algebra is
# installed by a different module and cannot satisfy this assessment.
module V12ProductionJournalBoundaryOverlay
  INCOMPLETE = V12ProductionJournalIncompleteBodyBuilder
  JOURNAL = V12ProductionJournalConformanceFixtures

  PROOF_FIELD = "production_journal_start_boundary_assessment_v12".freeze
  CATALOG_ASSESSMENT_FIELD =
    "production_journal_catalog_closure_assessment_v12".freeze
  RECEIPT_FIELD = "production_journal_boundary_install_receipt_v12".freeze
  FORBIDDEN_CATALOG_FIELD =
    JOURNAL::PRODUCTION_JOURNAL_CONFORMANCE_CATALOG_FIELD.freeze
  RECEIPT_TYPE_ID = "ProductionJournalBoundaryInstallReceiptV12".freeze
  SOURCE_DOMAINS_EXACT_ORDER = %w[OBSERVATION CUSTOM].freeze
  SOURCE_ORDER_RULE =
    "DOMAIN_DECLARATION_THEN_ASCII_FIXTURE_ID".freeze

  class BoundaryError < StandardError
    attr_reader :code, :details

    def initialize(code, details = {})
      @code = code
      @details = details
      super("#{code}:#{JSON.generate(details)}")
    end
  end

  module_function

  def compact(value)
    JSON.generate(value)
  end

  def sha256(value)
    Digest::SHA256.hexdigest(value.b)
  end

  def deep_clone(value)
    Marshal.load(Marshal.dump(value))
  end

  def receipt_schema
    {
      "keys" => [
        "state_enum", "blocking_dependency_id",
        "start_boundary_assessment_sha256",
        "catalog_closure_assessment_sha256",
        "catalog_plan_sha256", "planned_entry_count_uint",
        "planned_edge_count_uint", "assessed_source_fixture_count_uint",
        "assessed_source_domains_exact_order",
        "assessed_source_order_rule_enum",
        "assessed_source_fixtures_sha256", "production_body_emitted_bool",
        "production_frame_emitted_bool", "production_catalog_emitted_bool",
        "production_catalog_key_absent_bool",
        "synthetic_static_model_is_separate_bool",
        "production_schema_sha256_before", "production_schema_sha256_after",
        "production_schemas_unchanged_bool"
      ],
      "field_types_exact" => {
        "state_enum" => "S", "blocking_dependency_id" => "S",
        "start_boundary_assessment_sha256" => "H64",
        "catalog_closure_assessment_sha256" => "H64",
        "catalog_plan_sha256" => "H64",
        "planned_entry_count_uint" => "U", "planned_edge_count_uint" => "U",
        "assessed_source_fixture_count_uint" => "U",
        "assessed_source_domains_exact_order" => "CONTROL_OBJECT",
        "assessed_source_order_rule_enum" => "S",
        "assessed_source_fixtures_sha256" => "H64",
        "production_body_emitted_bool" => "B",
        "production_frame_emitted_bool" => "B",
        "production_catalog_emitted_bool" => "B",
        "production_catalog_key_absent_bool" => "B",
        "synthetic_static_model_is_separate_bool" => "B",
        "production_schema_sha256_before" => "CONTROL_OBJECT",
        "production_schema_sha256_after" => "CONTROL_OBJECT",
        "production_schemas_unchanged_bool" => "B"
      },
      "constants_exact" => {
        "state_enum" => "MISSING_TYPED_DEPENDENCY",
        "blocking_dependency_id" =>
          "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME",
        "planned_entry_count_uint" => 6, "planned_edge_count_uint" => 5,
        "assessed_source_domains_exact_order" =>
          SOURCE_DOMAINS_EXACT_ORDER,
        "assessed_source_order_rule_enum" => SOURCE_ORDER_RULE,
        "production_body_emitted_bool" => false,
        "production_frame_emitted_bool" => false,
        "production_catalog_emitted_bool" => false,
        "production_catalog_key_absent_bool" => true,
        "synthetic_static_model_is_separate_bool" => true,
        "production_schemas_unchanged_bool" => true
      },
      "rule" => "R00_HAS_NULL_JOURNAL_PREDECESSOR_BUT_REQUIRES_A_PROVED_START_PUBLICATION_PREDECESSOR;THE_ONLY_START_STATUS_ASSERTS_BUILD_EPOCH_CONSUMPTION_AND_REQUIRES_A_HELD_RECURSIVELY_VALID_START_FRAME;THE_COUNT_AND_CANONICAL_DIGEST_COMMIT_THE_COMPLETE_NAMESPACED_OBSERVATION_PLUS_CUSTOM_SOURCE_FIXTURE_UNIVERSE_ASSESSED_AT_INSTALL;WITHOUT_THE_EXACT_START_SOURCE_PRODUCTION_BODY_FRAME_REFERENCE_OBSERVATION_AND_CATALOG_COUNTS_STAY_ZERO;STATIC_MODEL_ALGEBRA_IS_A_DISJOINT_NONCOERCIBLE_DOMAIN"
    }
  end

  def production_schema_hashes(control)
    exact = control.fetch("exact_record_schema_v12")
    reusable = exact.fetch("reusable_objects")
    rows = {
      "RecordObservationV12" => reusable.fetch("RecordObservationV12"),
      "FrameReferenceV12" => reusable.fetch("FrameReferenceV12"),
      "RecordFrameBytesV12" => reusable.fetch("RecordFrameBytesV12"),
      "RecordFrameBytesSetV12" => reusable.fetch("RecordFrameBytesSetV12"),
      "journal_record_schema" => exact.dig("records", "journal"),
      "start_record_schema" => exact.dig("records", "start")
    }
    rows.to_h { |key, value| [key, sha256(compact(value))] }
  end

  def assess!(control, source_fixtures)
    boundary = INCOMPLETE.closure_assessment(control)
    catalog = JOURNAL.catalog_closure_assessment(
      :control => control,
      :source_fixtures => source_fixtures
    )
    dependency = boundary.fetch("missing_typed_dependency")
    proof = boundary.fetch("start_impossibility_proof")
    unless boundary.fetch("closure_state_enum") == "MISSING_TYPED_DEPENDENCY" &&
           dependency.fetch("dependency_id") ==
             "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME" &&
           dependency.fetch("available_bool") == false &&
           proof.fetch("blocking_dependency_id") == dependency.fetch("dependency_id") &&
           proof.fetch("incomplete_or_not_entered_start_status_exists_bool") == false &&
           proof.fetch("body_emission_authorized_bool") == false &&
           boundary.values_at(
             "body_emitted_bool", "frame_emitted_bool", "catalog_emitted_bool"
           ) == [false, false, false]
      raise BoundaryError.new("START_BOUNDARY_ASSESSMENT_MISMATCH")
    end
    unless catalog.fetch("closure_state_enum") == "MISSING_TYPED_DEPENDENCY" &&
           catalog.fetch("catalog_field") == FORBIDDEN_CATALOG_FIELD &&
           catalog.fetch("catalog_plan_exact") == JOURNAL::CATALOG_PLAN &&
           catalog.fetch("planned_predecessor_edges_exact").length == 5 &&
           catalog.dig("merkle_plan_exact", "evaluation_state_enum") ==
             "NOT_EVALUATED_NO_VALID_FRAMES" &&
           catalog.fetch("catalog_emitted_bool") == false &&
           catalog.fetch("historical_receipt_interpretation_bool") == false
      raise BoundaryError.new("PRODUCTION_CATALOG_ASSESSMENT_MISMATCH")
    end
    {"boundary" => boundary, "catalog" => catalog}
  end

  def install!(control, source_fixtures)
    exact = control.fetch("exact_record_schema_v12")
    reusable = exact.fetch("reusable_objects")
    decision = exact.fetch("decision_kernel_v12")
    field_collisions = [PROOF_FIELD, CATALOG_ASSESSMENT_FIELD, RECEIPT_FIELD,
                        FORBIDDEN_CATALOG_FIELD].select { |key| decision.key?(key) }
    unless field_collisions.empty?
      raise BoundaryError.new(
        "PRODUCTION_BOUNDARY_FIELD_COLLISION", "fields" => field_collisions
      )
    end
    if reusable.key?(RECEIPT_TYPE_ID)
      raise BoundaryError.new(
        "PRODUCTION_BOUNDARY_TYPE_COLLISION", "type_id" => RECEIPT_TYPE_ID
      )
    end

    before = production_schema_hashes(control)
    assessment = assess!(control, source_fixtures)
    boundary = assessment.fetch("boundary")
    catalog = assessment.fetch("catalog")
    receipt = {
      "state_enum" => "MISSING_TYPED_DEPENDENCY",
      "blocking_dependency_id" =>
        "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME",
      "start_boundary_assessment_sha256" => sha256(compact(boundary)),
      "catalog_closure_assessment_sha256" => sha256(compact(catalog)),
      "catalog_plan_sha256" => boundary.fetch("catalog_plan_sha256"),
      "planned_entry_count_uint" => JOURNAL::CATALOG_PLAN.length,
      "planned_edge_count_uint" =>
        catalog.fetch("planned_predecessor_edges_exact").length,
      "assessed_source_fixture_count_uint" => source_fixtures.length,
      "assessed_source_domains_exact_order" =>
        deep_clone(SOURCE_DOMAINS_EXACT_ORDER),
      "assessed_source_order_rule_enum" => SOURCE_ORDER_RULE,
      "assessed_source_fixtures_sha256" => sha256(compact(source_fixtures)),
      "production_body_emitted_bool" => false,
      "production_frame_emitted_bool" => false,
      "production_catalog_emitted_bool" => false,
      "production_catalog_key_absent_bool" => true,
      "synthetic_static_model_is_separate_bool" => true,
      "production_schema_sha256_before" => before,
      "production_schema_sha256_after" => before,
      "production_schemas_unchanged_bool" => true
    }

    reusable[RECEIPT_TYPE_ID] = receipt_schema
    decision[PROOF_FIELD] = deep_clone(boundary)
    decision[CATALOG_ASSESSMENT_FIELD] = deep_clone(catalog)
    decision[RECEIPT_FIELD] = receipt
    after = production_schema_hashes(control)
    unless before == after && !decision.key?(FORBIDDEN_CATALOG_FIELD)
      raise BoundaryError.new("PRODUCTION_BOUNDARY_INSTALL_MUTATED_AUTHORITY")
    end
    receipt
  end
end

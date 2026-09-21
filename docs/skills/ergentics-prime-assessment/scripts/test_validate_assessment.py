"""Synthetic metadata boundaries only; no Prime or native helper execution."""

import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('assessment_validator', Path(__file__).with_name('validate_assessment.py'))
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class AssessmentValidationTests(unittest.TestCase):
    def setUp(self):
        # Resolve only the test's newly-created directory; actual validator
        # inputs deliberately exercise path alias rejection below.
        self.temporary = tempfile.TemporaryDirectory(prefix='prime-assessment-synthetic-')
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.source = self.root / 'fixture.swift'
        self.source.write_text('// benign synthetic source\n')
        sha = hashlib.sha256(self.source.read_bytes()).hexdigest()
        self.record = {
            'schema_version': 1, 'assessment_id': 'synthetic-control',
            'scope': {'roots': [str(self.root)], 'required_surfaces': ['maintained_source'],
                      'question': 'Assess this synthetic source only.', 'exclusions': []},
            'inventory': [{'id': 'source', 'surface': 'maintained_source', 'kind': 'source',
                           'path': str(self.source), 'sha256': sha}],
            'reviews': [{'item_id': 'source', 'state': 'reviewed', 'basis': 'synthetic benign source inspected',
                         'evidence': ['synthetic source fixture']}],
            'findings': [],
            'verifications': [{'id': 'check', 'status': 'pass', 'subjects': {'source': sha},
                               'evidence': ['synthetic source identity check']}],
            'live_processes': {'state': 'unknown', 'count': None, 'evidence': []},
            'holds': [{'id': 'commit', 'active': True, 'reason': 'Synthetic user hold remains active.'}],
            'completion': {'state': 'complete', 'summary': 'Only the declared synthetic source was assessed.'},
        }

    def reject(self, record=None, check_files=False):
        with self.assertRaises((validator.Invalid, OSError)):
            validator.validate(record or self.record, check_files)

    def test_benign_control_preserves_hold_and_scope_limit(self):
        result = validator.validate(self.record, True)
        self.assertEqual(result['files_verified'], 1)
        self.assertEqual(result['active_holds'], ['commit'])
        self.assertFalse(result['scope_or_behavior_qualified_by_this_validator'])

    def test_empty_inventory(self):
        self.record['inventory'] = []; self.record['reviews'] = []
        self.reject()

    def test_missing_required_surface(self):
        self.record['scope']['required_surfaces'].append('retained_images')
        self.reject()

    def test_missing_review(self):
        self.record['reviews'] = []
        self.reject()

    def test_duplicate_inventory_identity(self):
        self.record['inventory'].append(copy.deepcopy(self.record['inventory'][0]))
        self.reject()

    def test_duplicate_path_does_not_inflate_denominator(self):
        duplicate = copy.deepcopy(self.record['inventory'][0]); duplicate['id'] = 'duplicate'
        self.record['inventory'].append(duplicate)
        self.reject()

    def test_pending_not_complete(self):
        self.record['reviews'][0]['state'] = 'pending'
        self.reject()

    def test_pending_not_complete_with_limits(self):
        self.record['reviews'][0]['state'] = 'pending'
        self.record['completion']['state'] = 'complete_with_limits'
        self.reject()

    def test_blocked_requires_qualified_completion(self):
        self.record['reviews'][0]['state'] = 'blocked'
        self.reject()
        self.record['completion']['state'] = 'complete_with_limits'
        self.assertEqual(validator.validate(self.record)['declared_completion'], 'complete_with_limits')

    def test_live_count_unknown_is_not_zero(self):
        self.record['live_processes']['count'] = 0
        self.reject()

    def test_observed_count_requires_evidence_and_time(self):
        self.record['live_processes'].update(state='observed', count=0)
        self.reject()

    def test_boolean_count_is_not_an_integer_observation(self):
        self.record['live_processes'].update(state='observed', count=False, evidence=['fixture'], observed_at='2026-09-20T00:00:00Z')
        self.reject()

    def test_required_live_surface_not_cleared_by_source_tests(self):
        self.record['scope']['required_surfaces'].append('live_processes')
        self.record['inventory'].append({'id': 'live', 'surface': 'live_processes', 'kind': 'logical', 'description': 'Snapshot unavailable.'})
        self.record['reviews'].append({'item_id': 'live', 'state': 'reviewed', 'basis': 'Denial recorded.', 'evidence': ['denied snapshot']})
        self.reject()

    def test_file_tamper_invalidates_binding(self):
        self.source.write_text('// changed synthetic fixture\n')
        self.reject(check_files=True)

    def test_path_outside_scope(self):
        self.record['scope']['roots'] = [str(self.root / 'elsewhere')]
        self.reject()

    def test_leaf_symlink_rejected(self):
        link = self.root / 'link.swift'; link.symlink_to(self.source)
        self.record['inventory'][0]['path'] = str(link)
        self.reject(check_files=True)

    def test_parent_symlink_rejected(self):
        real = self.root / 'real'; real.mkdir()
        child = real / 'file.swift'; child.write_bytes(self.source.read_bytes())
        alias = self.root / 'alias'; alias.symlink_to(real, target_is_directory=True)
        self.record['inventory'][0]['path'] = str(alias / 'file.swift')
        self.reject(check_files=True)

    def test_parent_replacement_during_read_cannot_bind_old_path(self):
        active = self.root / 'active'; active.mkdir()
        subject = active / 'subject'; subject.write_bytes(b'a' * 131072)
        original_read = os.read
        replaced = False

        def replace_after_first_read(fd, count):
            nonlocal replaced
            result = original_read(fd, count)
            if not replaced:
                replaced = True
                active.rename(self.root / 'retained')
                active.mkdir()
                (active / 'subject').write_bytes(b'b' * 131072)
            return result

        with patch.object(validator.os, 'read', side_effect=replace_after_first_read):
            with self.assertRaises(validator.Invalid):
                validator.read_regular(subject, 262144)
        self.assertTrue(replaced)

    def test_fifo_rejected_without_waiting_for_writer(self):
        fifo = self.root / 'pipe'; os.mkfifo(fifo)
        with self.assertRaises(validator.Invalid):
            validator.read_regular(fifo, 16)

    def test_cap_applies_before_content_read(self):
        with self.assertRaises(validator.Invalid):
            validator.read_regular(self.source, 2)

    def test_credential_path_rejected_before_open(self):
        self.record['inventory'][0]['path'] = str(self.root / '.env.synthetic')
        self.reject(check_files=True)

    def test_duplicate_json_key(self):
        with self.assertRaises(validator.Invalid):
            validator.parse_record('{"schema_version": 1, "schema_version": 2}')

    def test_nonfinite_json_number(self):
        with self.assertRaises(validator.Invalid):
            validator.parse_record('{"count": NaN}')

    def test_logical_item_cannot_skip_file_identity(self):
        self.record['inventory'][0].update(kind='logical', description='Incorrectly relabeled file.')
        self.reject()

    def test_failed_current_check_is_preserved(self):
        self.record['verifications'][0]['status'] = 'fail'
        self.reject()

    def test_same_candidate_correction_preserves_initial_failure(self):
        old = copy.deepcopy(self.record['verifications'][0])
        old.update(id='initial', status='fail', superseded_by='check')
        self.record['verifications'].insert(0, old)
        validator.validate(self.record)
        self.assertEqual(self.record['verifications'][0]['status'], 'fail')

    def test_new_candidate_does_not_silently_erase_old_failure(self):
        old = copy.deepcopy(self.record['verifications'][0])
        old.update(id='initial', status='fail', superseded_by='check', subjects={'source': '0' * 64})
        self.record['verifications'].insert(0, old)
        self.reject()

    def test_supersession_cycle(self):
        self.record['verifications'][0]['superseded_by'] = 'check'
        self.reject()

    def test_fixed_finding_needs_current_candidate_evidence(self):
        self.record['findings'] = [{'id': 'defect', 'state': 'fixed', 'item_ids': ['source'],
                                   'evidence': ['synthetic defect'], 'verification_ids': ['check']}]
        validator.validate(self.record)
        self.record['verifications'][0]['subjects']['source'] = '0' * 64
        self.reject()

    def test_historical_check_requires_reason(self):
        self.record['verifications'][0].update(status='fail', current=False)
        self.reject()
        self.record['verifications'][0]['history_reason'] = 'Earlier candidate; preserved separately.'
        validator.validate(self.record)

    def test_current_pass_cannot_qualify_different_bytes_without_a_finding(self):
        self.record['verifications'][0]['subjects']['source'] = '0' * 64
        self.reject(check_files=True)

    def test_current_failure_must_also_name_current_bytes(self):
        self.record['completion']['state'] = 'in_progress'
        self.record['verifications'][0].update(status='fail', subjects={'source': '0' * 64})
        self.reject()

    def test_explicit_historical_pass_can_preserve_prior_candidate(self):
        self.record['verifications'][0].update(
            current=False, subjects={'source': '0' * 64},
            history_reason='Earlier candidate; not evidence for current bytes.')
        validator.validate(self.record, True)

    def test_logical_item_cannot_receive_a_current_file_hash_check(self):
        self.record['inventory'].append({'id': 'live', 'surface': 'live_processes',
                                        'kind': 'logical', 'description': 'Unavailable snapshot.'})
        self.record['reviews'].append({'item_id': 'live', 'state': 'blocked',
                                      'basis': 'OS denied enumeration.', 'evidence': []})
        self.record['completion']['state'] = 'complete_with_limits'
        self.record['verifications'][0]['subjects'] = {'live': '0' * 64}
        self.reject()

    def test_unsupported_schema(self):
        self.record['schema_version'] = 2
        self.reject()


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env python3
"""Read retained reports; reconstruct static v1 inputs without replaying predictions.

This uses Python standard-library metadata processing only. It imports no model
framework and never runs a learned model. Output references are separate from
model-visible input files. Run from any directory.
"""
import collections
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

HERE = Path(__file__).resolve().parent
OUT = HERE / 'variable-depth-v1-preparation'
LAB = Path('/Users/ergentics/prime-mlx-lab')
REPO = Path('/Users/ergentics/pmhnp-companion-ergentics')
SOURCE = REPO / 'prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeVariableDepthCanary.swift'
RUNS = ['native-variable-depth-seed1618-4000', 'native-variable-depth-seed1618-8000-v1']
AXES = ['base', 'alphabet_b', 'heldout_codebook', 'joint_alphabet_b_codebook', 'neutral_context']
PATTERN = re.compile(r'^(holdout|validation|mutation)-(base|validation_codebook|alphabet_b|heldout_codebook|joint_alphabet_b_codebook|neutral_context)-(canonical|alphabet_b)-(train-[abcd]|validation|holdout)-d([34])-((?:3[234]-)+3[234])-s([0-7])(-context)?$')
BOOKS = {'train-a': [32, 34, 33], 'train-b': [33, 32, 34], 'train-c': [34, 32, 33], 'train-d': [34, 33, 32], 'validation': [32, 33, 34], 'holdout': [33, 34, 32]}
PERMUTATION = [3, 0, 6, 1, 7, 4, 2, 5]
MANIFEST_HASH = '2ed11ee4fd1a879e0364aafabb47fe1941f6debe780e1392f9a2a764fb04ec5d'

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda: f.read(1024 * 1024), b''):
            h.update(b)
    return h.hexdigest()

def save(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')

def encode(x, surface):
    return 16 + x if surface == 'canonical' else 64 + PERMUTATION[x]

def reconstruct(row):
    match = PATTERN.fullmatch(row['row_id'])
    assert match, row['row_id']
    split, axis, surface, book, depth, op_text, start, context = match.groups()
    depth, start = int(depth), int(start)
    operations = list(map(int, op_text.split('-')))
    assert len(operations) == depth
    aliases = [40, 41, 42] if surface == 'canonical' else [48, 49, 50]
    bindings = dict(zip(aliases, BOOKS[book]))
    header = [8]
    for index, (alias, op) in enumerate(bindings.items()):
        header += [alias, 9, op, 11 if index == 2 else 10]
    program = [aliases[BOOKS[book].index(op)] for op in operations]
    initial_common = [1] + ([12] if context else []) + header
    continuation_common = [1] + header
    stages, states = [], []
    value = start
    for index, (alias, operation) in enumerate(zip(program, operations)):
        value = ((value + 1) if operation == 32 else (value - 1) if operation == 33 else -value) % 8
        states.append(encode(value, surface))
        terminal = 3 if index == depth - 1 else 6
        if index == 0:
            prefix = initial_common + [5, encode(start, surface), alias, terminal]
            suffix = []
            expected_recorded_input = prefix
        else:
            prefix = continuation_common + [7]
            suffix = [alias, terminal]
            expected_recorded_input = prefix + [row['trace_predictions'][index - 1]] + suffix
        assert row['trace_input_ids'][index] == expected_recorded_input, (row['row_id'], index)
        stages.append({'stageIndex': index, 'requiresPriorPrediction': index > 0,
                       'inputPrefixIDs': prefix, 'inputSuffixIDs': suffix})
    assert states == row['trace_targets'], row['row_id']
    assert states[-1] == row['direct_target'], row['row_id']
    legend = (
        'Use arithmetic modulo 8, with residues 0 through 7. '
        'Value-symbol IDs encode residues as follows: '
        + ', '.join(str(encode(x, surface)) + '=' + str(x) for x in range(8)) + '. '
        'Primitive-operation IDs: 32 means add 1 modulo 8; 33 means subtract 1 modulo 8; '
        '34 means negate modulo 8. Alias-operation IDs bind to primitive IDs as follows: '
        + ', '.join(str(a) + '=' + str(o) for a, o in bindings.items()) + '. '
        + ('The neutral context marker 12 has no effect. ' if context else '')
        + 'These are task symbols, not your tokenizer IDs. Return exactly one decimal value-symbol ID and no other text.'
    )
    case = {
        'id': row['row_id'], 'axis': axis, 'depth': depth, 'sourceSplit': split,
        'surface': surface, 'codebookID': book, 'startSurfaceSymbol': encode(start, surface),
        'operationSurfaceSymbols': program, 'allowedValueSymbols': sorted(encode(x, surface) for x in range(8)),
        'codebookHeaderIDs': header, 'directInputIDs': initial_common + [2, encode(start, surface)] + program + [3],
        'traceStages': stages, 'legend': legend, 'questionBase': legend,
        'directQuestion': legend + '\nStart at value-symbol ID ' + str(encode(start, surface))
            + '. Apply alias-operation IDs in this order: ' + ', '.join(map(str, program)) + '. Return the final value-symbol ID.',
        'stepQuestionTemplate': legend + '\nStart at value-symbol ID {prior_surface_symbol}. Apply alias-operation ID {operation_surface_symbol} once. Return the resulting value-symbol ID.'
    }
    reference = {'id': row['row_id'], 'semanticStart': start, 'semanticOperations': operations,
                 'expectedStateIDs': states, 'directTargetID': states[-1]}
    selection = {'axis': axis, 'depth': depth, 'family': 'd' + str(depth) + '-' + op_text,
                 'start': start, 'split': split}
    return case, reference, selection

def main():
    reports, reconstructions, receipts = [], [], []
    first_header = None
    for name in RUNS:
        report_path = LAB / name / 'prime-native-variable-depth-seed1618.json'
        report = json.loads(report_path.read_text())
        assert report['manifest']['manifest_sha256'] == MANIFEST_HASH
        assert report['schema_version'] == '1'
        weights = report_path.with_suffix('.safetensors')
        weight_hash = digest(weights)
        assert weight_hash == report['durability']['checkpoint_sha256']
        with weights.open('rb') as f:
            n = struct.unpack('<Q', f.read(8))[0]
            header = json.loads(f.read(n))
        shapes = {k: {'dtype': v['dtype'], 'shape': v['shape']} for k, v in header.items() if k != '__metadata__'}
        assert len(shapes) == 74
        assert all(x['dtype'] == 'F32' for x in shapes.values())
        if first_header is None:
            first_header = shapes
        else:
            assert shapes == first_header
        reconstructed = {r['row_id']: reconstruct(r) for r in report['predictions']}
        assert len(reconstructed) == 1120
        reports.append(report)
        reconstructions.append(reconstructed)
        receipts.append({'reportPath': str(report_path), 'reportSHA256': digest(report_path),
                         'weightsPath': str(weights), 'weightsSHA256': weight_hash,
                         'weightsBytes': weights.stat().st_size, 'tensorCount': len(shapes),
                         'allTensorDtypes': ['F32'], 'trainedInSwift': report['implementation']['execution_language'] == 'swift'})
    assert reconstructions[0] == reconstructions[1], 'Both reports must yield identical static inputs and independently checked targets.'
    eligible = {k: v for k, v in reconstructions[0].items() if v[2]['axis'] in AXES and v[2]['split'] in ['holdout', 'mutation']}
    families = {}
    for depth in [3, 4]:
        available = [{x[2]['family'] for x in eligible.values() if x[2]['axis'] == axis and x[2]['depth'] == depth} for axis in AXES]
        families[depth] = min(set.intersection(*available))
    selected = []
    for axis in AXES:
        for depth in [3, 4]:
            rows = [v for v in eligible.values() if v[2]['axis'] == axis and v[2]['family'] == families[depth]]
            rows.sort(key=lambda v: v[2]['start'])
            assert [v[2]['start'] for v in rows] == list(range(8))
            selected.extend(rows)
    cases = [v[0] for v in selected]
    refs = [v[1] for v in selected]
    assert len(cases) == 80
    inputs = {'schemaVersion': 'prime-variable-depth-v1-inputs-1',
              'originalManifestSHA256': MANIFEST_HASH,
              'selection': 'For each depth 3 and 4, lexicographically first semantic program family shared by the five axes; all starts 0..7; no filtering by predictions or outcomes.',
              'controller': 'Each continuation must insert only that model run’s actual previous predicted integer ID between inputPrefixIDs and inputSuffixIDs. No normalization, clamping, gold substitution, or historical predictions. These inputs contain no targets.',
              'cases': cases}
    save(OUT / 'Inputs/cases.json', inputs)
    save(OUT / 'References/gold.json', {'schemaVersion': 'prime-variable-depth-v1-references-1', 'cases': refs})
    save(OUT / 'References/checkpoint-source-receipts.json', receipts)
    save(OUT / 'References/tensor-shapes.json', first_header)
    for c in cases:
        save(OUT / 'Inputs' / (c['id'] + '.json'), c)
    audit = {
        'schemaVersion': 'prime-variable-depth-v1-input-audit-1',
        'originalWholeManifestAvailable': False,
        'originalManifestSHA256RecordedByBothReports': MANIFEST_HASH,
        'originalWholeManifestSHA256Reproduced': False,
        'bindingMethod': 'Reconstruct from exact saved schema-v1 native trace inputs and row identifiers, removing each recorded continuation prediction; independently calculate references from the original modulo-8 codec; cross-check both runs produce identical static inputs and references.',
        'currentCodecSource': str(SOURCE), 'currentCodecSourceSHA256': digest(SOURCE),
        'currentSourceGitHEAD': subprocess.check_output(['git', '-C', str(REPO), 'rev-parse', 'HEAD'], text=True).strip(),
        'sourceScope': 'Current source schema is v2. encode/decode, codebook header, row construction and trace materialization formulas were verified against every saved v1 trace. We do not bind v1 weights to a v2 training manifest or its added binding examples.',
        'all1120RowsPerReportValidated': True, 'bothReportsStaticInputAndReferencesEqual': True,
        'selectedCaseCount': len(cases), 'selectedProgramFamiliesByDepth': families,
        'selectedAxes': AXES, 'selectedStartsPerAxisDepth': list(range(8)),
        'continuationSlotsRemovedAcrossBothFullReports': sum(sum(len(v[0]['traceStages']) - 1 for v in r.values()) for r in reconstructions),
        'targetsInModelInputs': False, 'historicalPredictionsInModelInputs': False,
        'directInputsSource': 'Reconstructed from original v1 first-stage common prefix, native APPLY token 2, original encoded start and alias program, ANSWER token 3; matches original Swift row-construction formula.',
        'naturalLanguageFairness': 'Llama receives the same value encoding and alias bindings as native inputs; aliases are retained rather than replaced by their resolved semantic operations. Both direct and iterative paths are supplied. Gold is stored only in References.',
        'inputSHA256': digest(OUT / 'Inputs/cases.json'), 'goldSHA256': digest(OUT / 'References/gold.json'),
        'noModelFrameworkImports': True, 'inferenceRun': False, 'originalSourcesModified': False,
        'checkpoints': receipts,
    }
    save(OUT / 'input-audit.json', audit)
    print(json.dumps({'output': str(OUT), 'cases': len(cases), 'families': families,
                      'inputSHA256': audit['inputSHA256'], 'goldSHA256': audit['goldSHA256']}, indent=2))

if __name__ == '__main__':
    main()

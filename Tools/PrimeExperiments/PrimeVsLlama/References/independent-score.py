#!/usr/bin/env python3
"""Independent reference validation and scoring. No model imports or execution."""
import collections
import hashlib
import json
from pathlib import Path
import re

OUT = Path(__file__).resolve().parents[2] / 'outputs/Prime-Experiment-Builds/Prime-v-Llama-01'
PATTERN = re.compile(r'^(holdout|mutation)-(base|alphabet_b|heldout_codebook|joint_alphabet_b_codebook|neutral_context)-(canonical|alphabet_b)-(train-a|holdout)-d([34])-((?:3[234]-)+3[234])-s([0-7])(-context)?$')
PERMUTATION = [3, 0, 6, 1, 7, 4, 2, 5]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def counts(rows):
    n = len(rows)
    result = {'caseCount': n}
    for key in ['directFinalCorrect', 'traceFinalCorrect', 'fullTraceCorrect',
                'traceCompleted', 'directAssignedValue', 'traceFinalAssignedValue',
                'traceFinalCorrectDespiteWrongIntermediate']:
        numerator = sum(r[key] for r in rows)
        result[key] = {'correct': numerator, 'total': n, 'fraction': numerator / n}
    result['intermediateStates'] = {
        'correct': sum(r['correctTraceStates'] for r in rows),
        'totalRequired': sum(r['depth'] for r in rows),
        'fraction': sum(r['correctTraceStates'] for r in rows) / sum(r['depth'] for r in rows),
        'missingOrWrongStatesCountAsIncorrect': True,
    }
    return result

def main():
    gp = OUT / 'References/gold.json'
    refs = json.loads(gp.read_text())['cases']
    assert len(refs) == 80
    checked = {}
    for row in refs:
        m = PATTERN.fullmatch(row['id'])
        assert m, row['id']
        split, axis, surface, book, depth, operation_text, start, context = m.groups()
        depth, start = int(depth), int(start)
        ops = list(map(int, operation_text.split('-')))
        assert len(ops) == depth and ops == row['semanticOperations']
        assert start == row['semanticStart']
        value = start
        states = []
        for op in ops:
            if op == 32:
                value = (value + 1) % 8
            elif op == 33:
                value = (value - 1) % 8
            elif op == 34:
                value = (-value) % 8
            states.append(16 + value if surface == 'canonical' else 64 + PERMUTATION[value])
        assert states == row['expectedStateIDs']
        assert states[-1] == row['directTargetID']
        checked[row['id']] = {'axis': axis, 'depth': depth, 'surface': surface,
                              'states': states, 'final': states[-1], 'start': start,
                              'operations': ops, 'family': 'd' + str(depth) + '-' + operation_text,
                              'allowed': set(range(16, 24) if surface == 'canonical' else range(64, 72))}
    assert len(checked) == 80
    models = []
    source_receipts = [{'path': str(gp), 'sha256': sha(gp)}]
    for name in ['0006-summary', '0007-summary', 'llama-summary']:
        path = OUT / 'Results' / (name + '.json')
        source_receipts.append({'path': str(path), 'sha256': sha(path)})
        data = json.loads(path.read_text())
        rows = data['cases']
        assert len(rows) == 80
        assert len({x['caseID'] for x in rows}) == 80
        assert set(x['caseID'] for x in rows) == set(checked)
        results = []
        for row in rows:
            ref = checked[row['caseID']]
            direct = row['directValueTokenID']
            trace = row['traceValueTokenIDs']
            final = row['traceFinalValueTokenID']
            assert isinstance(trace, list)
            assert all(type(x) is int for x in trace)
            assert len(trace) <= ref['depth']
            complete = row['traceCompleted']
            assert type(complete) is bool
            if complete:
                assert len(trace) == ref['depth'] and final == trace[-1]
            else:
                assert final is None
            direct_correct = type(direct) is int and direct == ref['final']
            final_correct = complete and type(final) is int and final == ref['final']
            full_correct = complete and trace == ref['states']
            results.append({
                'id': row['caseID'], 'axis': ref['axis'], 'depth': ref['depth'],
                'surface': ref['surface'], 'programFamily': ref['family'],
                'expectedFinalValueSymbol': ref['final'], 'expectedTraceValueSymbols': ref['states'],
                'directValueSymbol': direct, 'traceValueSymbols': trace, 'traceFinalValueSymbol': final,
                'directFinalCorrect': direct_correct, 'traceFinalCorrect': final_correct,
                'fullTraceCorrect': full_correct, 'traceCompleted': complete,
                'directAssignedValue': type(direct) is int and direct in ref['allowed'],
                'traceFinalAssignedValue': type(final) is int and final in ref['allowed'],
                'traceFinalCorrectDespiteWrongIntermediate': final_correct and not full_correct,
                'correctTraceStates': sum(p == g for p, g in zip(trace, ref['states'])),
            })
        models.append({
            'sourceSummary': name,
            'modelID': data.get('modelID', data.get('model', {}).get('modelID')),
            'aggregate': counts(results),
            'perAxis': {axis: counts([r for r in results if r['axis'] == axis]) for axis in sorted({r['axis'] for r in results})},
            'perDepth': {str(depth): counts([r for r in results if r['depth'] == depth]) for depth in [3, 4]},
            'caseOutcomes': results,
        })
    report = {
        'schemaVersion': 'prime-llama-independent-score-1',
        'sourceReceipts': source_receipts,
        'independentScorerPath': str(Path(__file__).resolve()),
        'independentScorerSHA256': sha(Path(__file__).resolve()),
        'referenceAudit': {
            'all80ReferenceRowsRecomputedIndependently': True,
            'method': 'Parse original semantic program and start from each row ID, cross-check reference metadata, apply modulo-8 operations, encode with the original canonical/alphabetB value mapping, and require every intermediate and final reference to match.',
            'exactlyTwoUnderlyingSemanticPrograms': [
                {'id': 'd3-32-34-32', 'operations': ['increment', 'negate', 'increment'], 'semanticResult': '(-start) modulo8'},
                {'id': 'd4-32-32-32-33', 'operations': ['increment', 'increment', 'increment', 'decrement'], 'semanticResult': '(start+2) modulo8'},
            ],
            'design': '2 semantic programs ×5 binding/context axes ×8 starts =80 cases; cases are correlated variations, not80 independent task families.',
            'selection': 'First lexicographic original heldout semantic family perdepth shared by all five axes, without filtering model outputs or expected correctness.',
        },
        'scoringPolicy': {
            'directFinal': 'Exact integer value-symbol equality to the reference final; null/unparsed/unassigned output is incorrect.',
            'traceFinal': 'Completed trace and exact final value-symbol equality; earlier mistakes do not prevent this metric from passing.',
            'fullTrace': 'Completed trace whose entire predicted state sequence exactly equals every reference state.',
            'intermediateAccuracy': 'Correct predicted state positions divided by all required state positions; absent positions are incorrect.',
            'noOutputRepair': True,
        },
        'scopeLimits': [
            'This scores a narrow fixed symbolic-language transfer suite. It does not establish general language, coding, mathematical problem-solving or clinical capability.',
            'Prime predictions are native vocabulary IDs; Llama answers are decimal textual labels for those task symbols, parsed upstream. They are not Llama tokenizer IDs.',
            'Final correctness may mask wrong intermediate states; full-trace accuracy is therefore reported separately.',
            'Two checkpoints share one training seed and architecture; this is not a multi-seed population estimate.',
            'Independent scoring reads the supplied main result summaries and verifies them structurally; separate driver/readiness review owns raw-generation and feedback integrity.',
            'The original full v1 training manifest hash was recorded in reports but not reproduced; inputs were bound to saved v1 execution evidence.',
        ],
        'models': models,
        'gpuRun': False, 'originalResultFilesModified': False,
    }
    destination = OUT / 'INDEPENDENT-SCORE.json'
    destination.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(json.dumps({'saved': str(destination), 'sha256': sha(destination),
                      'models': [{k:v for k,v in m.items() if k not in ['caseOutcomes','perDepth']} for m in models]}, indent=2))

if __name__ == '__main__':
    main()

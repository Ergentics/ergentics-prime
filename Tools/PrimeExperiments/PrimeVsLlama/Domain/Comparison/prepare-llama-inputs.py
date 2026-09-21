#!/usr/bin/env python3
"""Prepare a bounded, input-selected policy comparison, not model answers.

The independent formula implementation below is used only to verify the rule
translation against retained references. It never supplies question answers or
scores to model-visible prompts. No model framework or runtime is imported.
"""
import collections
import hashlib
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
READINESS = [0.18, 0.30, 0.45, 0.64, 0.82]
DURABILITY = [0.0, 0.35, 0.70]
BLUEPRINT = [33 / 150, 41 / 150, 33 / 150, 17 / 150, 26 / 150]

RULES = """Evaluate this fixed SeatEngine domain recommendation policy.
Numbers below are task-symbol IDs, not your tokenizer IDs. Return only the requested decimal symbol ID, without explanation or a code block.

Input codec: domain IDs64,65,66,67,68 mean I,II,III,IV,V. Readiness IDs80,81,82,83,84 mean R=0.18,0.30,0.45,0.64,0.82. Durability IDs96,97,98 mean E=0,0.35,0.70. Candidate fields are ordered domain,readiness,durability. ID225 is a corrupt field. ID4 is a neutral context marker and does not change the policy. BOS1, TRACE5, VERSUS6, RESUME7 and ANSWER3 are structural delimiters.

Blueprint weights B for I,II,III,IV,V are respectively33/150,41/150,33/150,17/150,26/150. Recent history is empty; no headroom, format cap or share-guard multiplier is applied. Goal weights are fluency0.15 and durable0.85.
Let p(R)=0.5*(1+erf((R-0.50)/(0.18*sqrt(2)))). Let t(a)=(1+max(a,0)/14)^(-0.5) for a>=0 and0 for a<0. Let gap=min(14*(clamp(R,0.000001,1)^(-2)-1),180). Let D(R)=clamp((t(180-gap)-t(180))/(1-t(180)),0,1).
Candidate priority is B*(0.15*p(R)*(1-R)+0.85*(1-E)*p(R)*D(R)). Use this derived D(R), not an approximation such as(1-R)^2.29.

Event selection: sigmoid(x)=1/(1+exp(-x)); a=sigmoid(8*(R-0.30)), b=sigmoid(8*(R-0.65)). Compare WE=1-a, PF=a-b, RP=b. Select the largest; ties prefer WE, thenPF, thenRP. Event indices WE,PF,RP are0,1,2 (worked example, productive failure, retrieval practice). Event probabilities select the event only; they do not multiply priority.

Candidate-summary task: if any of its three input fields is225, return224(ABSTAIN). Otherwise calculate priorities for the complete fixed grid of5domains x5readiness values x3durability values above. Sort distinct priority values ascending; let U be their count and rank be the candidate's zero-based index. Define band=min(11,floor(rank*12/U)). Its summary symbol is128+3*band+eventIndex. No table of candidate scores or summary answers is supplied.

Direct pair task: if either candidate contains225, return224(ABSTAIN). Otherwise select the candidate with larger priority; a priority tie retains the left candidate. Return192+sideOffset+selectedEventIndex, where sideOffset=0for left and3for right.

Summary-pair task: take the two actual predicted summary symbols supplied in the question; do not replace them with recomputed or expected summaries. If either is224, return224. A summary symbol128..163 encodes band=floor((ID-128)/3) and eventIndex=(ID-128)%3. For unequal bands select the larger band and return192+sideOffset+that summary's eventIndex. Original represented pairs have unequal bands; the frozen canary supplies no declared selection rule for equal-band or other undefined summary combinations. Keep supplied symbols unchanged when predicting.
"""

def sha(data):
    return hashlib.sha256(data).hexdigest()

def canonical(obj):
    return json.dumps(obj, sort_keys=True, separators=(',', ':')).encode()

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        assert path.read_bytes() == data, f'Existing artifact differs: {path}'
    else:
        with path.open('xb') as f:
            f.write(data)
    return sha(data)

def save(path, obj):
    return write(path, (json.dumps(obj, indent=2, sort_keys=True) + '\n').encode())

def fields(ids):
    tokens = list(ids)
    if tokens[1] == 4:
        tokens.pop(1)
    assert len(tokens) == 6 and tokens[:2] == [1, 5] and tokens[-1] == 3
    return tokens[2:5]

def priority_event(domain_index, readiness_index, durability_index):
    R, E = READINESS[readiness_index], DURABILITY[durability_index]
    p = 0.5 * (1 + math.erf((R - 0.5) / 0.18 / math.sqrt(2)))
    def trace(age):
        return 0.0 if age < 0 else (1 + max(age, 0.0) / 14) ** (-0.5)
    gap = min(14 * (max(min(R, 1.0), 1e-6) ** (-2) - 1), 180)
    difficulty = max(0.0, min(1.0, (trace(180 - gap) - trace(180)) / (1 - trace(180))))
    priority = BLUEPRINT[domain_index] * (0.15 * p * (1 - R) + (0.45 + 0.40) * (1 - E) * p * difficulty)
    a, b = 1 / (1 + math.exp(-8 * (R - 0.30))), 1 / (1 + math.exp(-8 * (R - 0.65)))
    event_scores = [1 - a, a - b, b]
    event = max(range(3), key=event_scores.__getitem__)
    return priority, event

def audit_policy(rows):
    values = {(d, r, e): priority_event(d, r, e) for d in range(5) for r in range(5) for e in range(3)}
    distinct = sorted(set(p for p, _ in values.values()))
    summaries = {k: 128 + min(11, distinct.index(p) * 12 // len(distinct)) * 3 + event for k, (p, event) in values.items()}
    def summary(ids):
        d, r, e = fields(ids)
        return 224 if 225 in [d, r, e] else summaries[(d - 64, r - 80, e - 96)]
    failures = []
    for row in rows:
        left, right = summary(row['left_input_ids']), summary(row['right_input_ids'])
        if 224 in (left, right):
            final = 224
        else:
            lb, rb = (left - 128) // 3, (right - 128) // 3
            assert lb != rb
            chosen = left if lb > rb else right
            final = 192 + (0 if lb > rb else 3) + (chosen - 128) % 3
        if [left, right, final] != [row['left_summary_target_id'], row['right_summary_target_id'], row['final_target_id']]:
            failures.append(row['row_id'])
    return {'sourceGridStates': len(values), 'uniquePriorityValues': len(distinct), 'originalRowsChecked': len(rows),
            'candidateAndFinalReferenceMismatches': failures, 'computedPerCandidateAnswerTableExportedToPrompts': False}

def stratum(row):
    left, right = fields(row['left_input_ids']), fields(row['right_input_ids'])
    corrupt = [(side, index) for side, values in [('left', left), ('right', right)] for index, token in enumerate(values) if token == 225]
    if not corrupt:
        return (row['split'], row['family_id'], 'represented', 'left-readiness-' + str(left[1]))
    assert len(corrupt) == 1
    side, index = corrupt[0]
    return (row['split'], row['family_id'], 'malformed', side + '-' + ['domain', 'readiness', 'durability'][index])

def selection_hash(row):
    # Deliberately excludes target IDs, engine winner/event, and recorded outputs.
    return sha(canonical({'left': row['left_input_ids'], 'right': row['right_input_ids'],
                          'direct': row['direct_input_ids'], 'prefix': row['final_prefix_ids'], 'suffix': row['final_suffix_ids']}))

def candidate_description(ids):
    d, r, e = fields(ids)
    domain = dict(zip(range(64, 69), ['I', 'II', 'III', 'IV', 'V'])).get(d, 'corrupt field225')
    readiness = str(READINESS[r - 80]) if 80 <= r <= 84 else 'corrupt field225'
    durability = str(DURABILITY[e - 96]) if 96 <= e <= 98 else 'corrupt field225'
    return f'domain={domain}(ID{d}), readiness={readiness}(ID{r}), durability={durability}(ID{e})'

def main():
    mp = HERE / 'References/original-manifest.json'
    manifest = json.loads(mp.read_bytes())
    all_rows = manifest['rows'] + manifest['mutations']
    # Selection sees only original input fields and source split/family metadata.
    evaluation = [r for r in manifest['rows'] if r['split'] == 'holdout'] + manifest['mutations']
    groups = collections.defaultdict(list)
    for row in evaluation:
        groups[stratum(row)].append(row)
    selected = [min(groups[key], key=lambda row: (selection_hash(row), row['row_id'])) for key in sorted(groups)]
    assert len(selected) == 32
    assert sum(stratum(r)[2] == 'represented' for r in selected) == 20
    assert sum(stratum(r)[2] == 'malformed' for r in selected) == 12
    cases = []
    for row in selected:
        left, right = candidate_description(row['left_input_ids']), candidate_description(row['right_input_ids'])
        neutral = 'The neutral context marker4 is present.' if 4 in row['final_prefix_ids'] else 'No neutral context marker is present.'
        direct = RULES + '\nDIRECT PAIR. ' + neutral + '\nLeft: ' + left + '.\nRight: ' + right + '.\nOriginal task input IDs: ' + json.dumps(row['direct_input_ids']) + '.\nReturn the predicted final symbol ID.'
        lq = RULES + '\nCANDIDATE SUMMARY. ' + neutral + '\nCandidate: ' + left + '.\nOriginal task input IDs: ' + json.dumps(row['left_input_ids']) + '.\nReturn the predicted candidate-summary symbol ID.'
        rq = RULES + '\nCANDIDATE SUMMARY. ' + neutral + '\nCandidate: ' + right + '.\nOriginal task input IDs: ' + json.dumps(row['right_input_ids']) + '.\nReturn the predicted candidate-summary symbol ID.'
        fq = RULES + '\nSUMMARY PAIR. ' + neutral + '\nActual predicted left summary: {left_summary_symbol}. Actual predicted right summary: {right_summary_symbol}.\nOriginal final prefix IDs: ' + json.dumps(row['final_prefix_ids']) + '; append the supplied left and right summary symbols in that order, then suffix IDs: ' + json.dumps(row['final_suffix_ids']) + '.\nReturn the predicted final symbol ID.'
        cases.append({'id': row['row_id'], 'sourceSplit': row['split'], 'selectionStratum': list(stratum(row)),
                      'inputSelectionSHA256': selection_hash(row),
                      'directInputIDs': row['direct_input_ids'], 'leftInputIDs': row['left_input_ids'],
                      'rightInputIDs': row['right_input_ids'], 'finalPrefixIDs': row['final_prefix_ids'], 'finalSuffixIDs': row['final_suffix_ids'],
                      'directQuestion': direct, 'leftQuestion': lq, 'rightQuestion': rq, 'finalQuestionTemplate': fq,
                      'outputSymbolMinimum': 0, 'outputSymbolCount': 16384,
                      'finalFeedbackSources': {'left_summary_symbol': 'actual output ofleftQuestion', 'right_summary_symbol': 'actual output ofrightQuestion'}})
    rules_hash = write(HERE / 'Llama/Inputs/policy-rules.md', RULES.encode())
    cases_hash = save(HERE / 'Llama/Inputs/cases.json', {'schema': 'prime_domain_llama_original_input_comparison_v1',
        'selection': 'One smallest SHA256 of original input-only arrays per source split/domain-pair/left-readiness stratum for represented cases, and per source split/corrupt-side/corrupt-field stratum for malformed cases.32cases:20represented+12malformed. No prediction or reference value controls selection.',
        'jobOrder': ['directQuestion','leftQuestion','rightQuestion','finalQuestionTemplate'],
        'continuationPolicy': 'Pass actual parsed0..16383 model summary outputs into the two named final placeholders, including224ABSTAIN; do not substitute reference targets, previous runs, or recomputed policy summaries. Preserve raw unparseable outputs and label unavailable continuation rather than inventing a summary.',
        'cases': cases})
    refs = [{'id': r['row_id'], 'sourceSplit': r['split'], 'familyID': r['family_id'], 'represented': r['represented'],
             'expectedJobIDs': [r['final_target_id'], r['left_summary_target_id'], r['right_summary_target_id'], r['final_target_id']],
             'engineWinner': r.get('engine_winner'), 'engineEventType': r.get('engine_event_type')}
            for r in selected]
    save(HERE / 'Llama/References/gold.json', {'schema': 'prime_domain_llama_subset_references_v1', 'cases': refs})
    derivation = audit_policy(all_rows)
    assert not derivation['candidateAndFinalReferenceMismatches']
    source_scope = {
        'Recommender.swift': {'lines': '176-269,307-350', 'role': 'Actual priority path, defaults with no additional multipliers, strict-first final selection, global goal vector'},
        'EngineV21.swift': {'lines': '30-46,84-126', 'role': 'Original probit success probability, derived difficulty, objective and constants'},
        'Domain.swift': {'lines': '12-13,38-45', 'role': 'Five-domain order and canonical blueprint weights'},
        'MatchScore.swift': {'lines': '46-80', 'role': 'Partition-of-unity event probabilities and deterministic tie order'},
        'EngineConstants.swift': {'role': 'Population0.30/0.65 sigmoid cut parameters and steepness8'},
        'AntiRedundancy.swift': {'lines': '46-67', 'role': 'Empty history leaves multiplier1'},
        'Lab/ErgenticsPrimeDomainTraceShadowCanary.swift': {'lines': '14-31,426-565,566-842', 'role': 'Exact symbols, finite grid, unique-priority rank/band, native input construction and corrupted-fieldABSTAIN labels'},
    }
    audit = {'schema': 'prime_domain_llama_translation_audit_v1', 'status': 'PREPARED_INPUT_ONLY_RULE_TRANSLATION_VERIFIED',
        'ruleSheetSHA256': rules_hash, 'caseFileSHA256': cases_hash, 'originalManifestSHA256': sha(mp.read_bytes()),
        'caseCount': len(cases), 'representedCases': 20, 'malformedCases': 12,
        'sourceSplits': dict(collections.Counter(c['sourceSplit'] for c in cases)),
        'selectionDependsOnlyOnInputsAndSplitMetadata': True, 'selectedCasesAllInFullNativeSuite': True,
        'noExpectedScoresSummariesOrWinnersInPrompts': True,
        'formulaVerification': derivation, 'sourceLineage': source_scope,
        'semanticCautions': ['The task is the original symbolic study-policy projection, not free-form clinical question answering.',
                             'The Llama model receives an explicit formula/rule sheet; Prime learned the corresponding finite symbolic task. This is a transparent instruction-based comparator, not identical tokenizer input or identical training exposure.',
                             'The original canary excludes represented equal-band pairs. Its summary-combiner behavior for tied bands or undefined summary IDs is not supplied as an invented fallback rule.',
                             'The formula verification is analysis for input translation, not a service allowed to answer on behalf ofeither model.',
                             'Expected labels are retained only in References; native original input arrays and placeholders remain unchanged.'],
        'questionByteLengths': {name: {'minimum': min(len(c[name].encode()) for c in cases), 'maximum': max(len(c[name].encode()) for c in cases)} for name in ['directQuestion','leftQuestion','rightQuestion','finalQuestionTemplate']},
        'scriptPath': str(Path(__file__).resolve()), 'scriptSHA256': sha(Path(__file__).read_bytes()),
        'modelRun': False, 'trainingRun': False, 'originalSourcesModified': False}
    save(HERE / 'Llama/INPUT-AUDIT.json', audit)
    print(json.dumps({'root': str(HERE / 'Llama'), 'cases': len(cases), 'inputSHA256': cases_hash,
                      'ruleSheetSHA256': rules_hash, 'verifiedOriginalRows': derivation['originalRowsChecked'],
                      'formulaMismatches': len(derivation['candidateAndFinalReferenceMismatches'])}, indent=2))

if __name__ == '__main__':
    main()

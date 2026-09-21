#!/usr/bin/env python3
"""Isolated restricted-AST interpretation plus an independently bounded CPython witness."""
import argparse
import ast
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

CASE_PATH = Path(__file__).resolve().with_name('coding-cases.json')
MAX_SOURCE = 16384
MAX_NODES = 512
MAX_DEPTH = 24
MAX_ITEMS = 256
MAX_BITS = 256
MAX_STEPS = 10000
BUILTINS = {'len', 'range', 'set', 'list', 'enumerate'}
ALLOWED = (ast.Module, ast.FunctionDef, ast.arguments, ast.arg, ast.Return, ast.Assign,
           ast.Expr, ast.If, ast.For, ast.Break, ast.Continue, ast.Pass, ast.Compare,
           ast.Eq, ast.NotEq, ast.Lt, ast.LtE, ast.Gt, ast.GtE, ast.In, ast.NotIn,
           ast.Name, ast.Load, ast.Store, ast.Constant, ast.List, ast.Tuple, ast.Set,
           ast.Call, ast.Attribute, ast.BinOp, ast.Add, ast.Sub, ast.Mult, ast.FloorDiv,
           ast.Mod, ast.UnaryOp, ast.USub, ast.UAdd, ast.Not, ast.BoolOp, ast.And,
           ast.Or, ast.IfExp, ast.Subscript, ast.Slice)

class Unsupported(Exception): pass
class Limit(Exception): pass
class Returned(Exception):
    def __init__(self, value): self.value = value
class Broken(Exception): pass
class Continued(Exception): pass


def demand(condition, reason, error=Unsupported):
    if not condition: raise error(reason)


def bounded(value, depth=0):
    if depth > 8: raise Limit('container nesting exceeds eight levels')
    if type(value) is int:
        if value.bit_length() > MAX_BITS: raise Limit('integer exceeds 256 bits')
    elif type(value) in (list, tuple, set):
        if len(value) > MAX_ITEMS: raise Limit('container exceeds 256 elements')
        for item in value: bounded(item, depth + 1)
    elif value is not None and type(value) is not bool:
        raise TypeError('interpreter values are integers, booleans, None and bounded containers only')
    return value


def extract(text):
    demand(len(text.encode('utf-8')) <= MAX_SOURCE, 'source exceeds 16 KiB', Limit)
    match = re.fullmatch(r'\s*```(?:python|py)?[ \t]*\r?\n(.*?)\r?\n```[ \t]*\s*', text, re.S)
    if match:
        return match.group(1), 'single_enclosing_python_fence', False
    return text, 'none', True


def validate(code, function_name):
    tree = ast.parse(code)
    nodes = list(ast.walk(tree))
    demand(len(nodes) <= MAX_NODES, 'AST exceeds 512 nodes', Limit)
    demand(all(isinstance(n, ALLOWED) for n in nodes), 'construct outside the restricted Python grammar')
    def depth(n):
        return 1 + max((depth(c) for c in ast.iter_child_nodes(n)), default=0)
    demand(depth(tree) <= MAX_DEPTH, 'AST nesting exceeds 24', Limit)
    demand(len(tree.body) == 1 and isinstance(tree.body[0], ast.FunctionDef), 'expected exactly one function')
    fn = tree.body[0]
    demand(fn.name == function_name, 'function name differs from requested interface')
    demand(sum(isinstance(n, ast.FunctionDef) for n in nodes) == 1, 'nested functions are unsupported')
    args = fn.args
    demand(not fn.decorator_list and fn.returns is None and fn.type_comment is None,
           'decorators and annotations are unsupported')
    demand(not args.posonlyargs and not args.vararg and not args.kwarg and not args.kwonlyargs
           and not args.defaults and not args.kw_defaults and len(args.args) == 1,
           'expected one ordinary positional argument without defaults')
    arg_name = args.args[0].arg
    demand(not arg_name.startswith('_') and '__' not in arg_name and arg_name not in BUILTINS
           and args.args[0].annotation is None, 'argument name or annotation is unsupported')
    parents = {child: node for node in nodes for child in ast.iter_child_nodes(node)}
    docstring = fn.body[0] if fn.body and isinstance(fn.body[0], ast.Expr) and isinstance(fn.body[0].value, ast.Constant) and isinstance(fn.body[0].value.value, str) else None
    for node in nodes:
        if isinstance(node, ast.Name):
            demand(not node.id.startswith('_') and '__' not in node.id, 'private/dunder names are unsupported')
            if isinstance(node.ctx, ast.Store):
                demand(node.id not in BUILTINS and node.id != fn.name, 'builtins and function name cannot be rebound')
        if isinstance(node, ast.Constant):
            if isinstance(node.value, str):
                demand(parents.get(node) is docstring, 'only a leading function docstring may contain a string')
                demand(len(node.value.encode()) <= 4096, 'docstring exceeds 4 KiB', Limit)
            else:
                demand(node.value is None or type(node.value) in (int, bool), 'unsupported literal type')
                bounded(node.value)
        if isinstance(node, ast.Attribute):
            parent = parents.get(node)
            demand(isinstance(parent, ast.Call) and parent.func is node and isinstance(node.value, ast.Name)
                   and node.attr in ('append', 'add'), 'only named local list.append/set.add calls are admitted')
        if isinstance(node, ast.Call):
            demand(not node.keywords and not any(isinstance(a, ast.Starred) for a in node.args), 'keyword/starred calls are unsupported')
            demand((isinstance(node.func, ast.Name) and node.func.id in BUILTINS)
                   or isinstance(node.func, ast.Attribute), 'arbitrary or recursive calls are unsupported')
    return fn, arg_name


class Interpreter:
    def __init__(self): self.steps = 0
    def tick(self):
        self.steps += 1
        if self.steps > MAX_STEPS: raise Limit('interpreter exceeded 10,000 steps for one vector')
    def store(self, node, value, env):
        self.tick(); bounded(value)
        if isinstance(node, ast.Name): env[node.id] = value
        elif isinstance(node, (ast.Tuple, ast.List)):
            demand(type(value) in (list, tuple) and len(node.elts) == len(value), 'unpacking shape mismatch', TypeError)
            for target, item in zip(node.elts, value): self.store(target, item, env)
        else: raise Unsupported('assignment target must be a local name or tuple/list of names')
    def expr(self, n, env):
        self.tick()
        if isinstance(n, ast.Constant): return bounded(n.value)
        if isinstance(n, ast.Name):
            if n.id not in env: raise NameError('undefined local: ' + n.id)
            return env[n.id]
        if isinstance(n, (ast.List, ast.Tuple, ast.Set)):
            items = [self.expr(x, env) for x in n.elts]
            return bounded(items if isinstance(n, ast.List) else tuple(items) if isinstance(n, ast.Tuple) else set(items))
        if isinstance(n, ast.UnaryOp):
            v = self.expr(n.operand, env)
            if isinstance(n.op, ast.Not): return not bool(v)
            demand(type(v) is int, 'unary arithmetic requires an integer', TypeError)
            return bounded(-v if isinstance(n.op, ast.USub) else +v)
        if isinstance(n, ast.BoolOp):
            result = self.expr(n.values[0], env)
            for term in n.values[1:]:
                if isinstance(n.op, ast.And) and not result: break
                if isinstance(n.op, ast.Or) and result: break
                result = self.expr(term, env)
            return result
        if isinstance(n, ast.IfExp):
            return self.expr(n.body if self.expr(n.test, env) else n.orelse, env)
        if isinstance(n, ast.BinOp):
            left, right = self.expr(n.left, env), self.expr(n.right, env)
            if isinstance(n.op, ast.Add) and type(left) is list and type(right) is list:
                demand(len(left) + len(right) <= MAX_ITEMS, 'list concatenation exceeds bound', Limit)
                return bounded(left + right)
            if isinstance(n.op, ast.Mult) and (type(left) is list or type(right) is list):
                seq, times = (left, right) if type(left) is list else (right, left)
                demand(type(times) is int, 'list repeat requires integer', TypeError)
                demand(len(seq) * max(times, 0) <= MAX_ITEMS, 'list repetition exceeds bound', Limit)
                return bounded(seq * times)
            demand(type(left) is int and type(right) is int, 'arithmetic requires integer operands', TypeError)
            if isinstance(n.op, ast.Add): result = left + right
            elif isinstance(n.op, ast.Sub): result = left - right
            elif isinstance(n.op, ast.Mult): result = left * right
            elif isinstance(n.op, ast.FloorDiv): result = left // right
            elif isinstance(n.op, ast.Mod): result = left % right
            else: raise Unsupported('unsupported operator')
            return bounded(result)
        if isinstance(n, ast.Compare):
            left = self.expr(n.left, env)
            for op, expr in zip(n.ops, n.comparators):
                right = self.expr(expr, env)
                if isinstance(op, ast.In): ok = left in right
                elif isinstance(op, ast.NotIn): ok = left not in right
                elif isinstance(op, ast.Eq): ok = left == right
                elif isinstance(op, ast.NotEq): ok = left != right
                elif isinstance(op, ast.Lt): ok = left < right
                elif isinstance(op, ast.LtE): ok = left <= right
                elif isinstance(op, ast.Gt): ok = left > right
                elif isinstance(op, ast.GtE): ok = left >= right
                else: raise Unsupported('unsupported comparison')
                if not ok: return False
                left = right
            return True
        if isinstance(n, ast.Subscript):
            value = self.expr(n.value, env)
            demand(type(value) in (list, tuple), 'indexing requires list or tuple', TypeError)
            if isinstance(n.slice, ast.Slice):
                values = [self.expr(v, env) if v is not None else None for v in (n.slice.lower, n.slice.upper, n.slice.step)]
                demand(all(v is None or type(v) is int for v in values), 'slice requires integers', TypeError)
                return bounded(value[slice(*values)])
            index = self.expr(n.slice, env)
            demand(type(index) is int, 'index requires integer', TypeError)
            return value[index]
        if isinstance(n, ast.Call):
            args = [self.expr(x, env) for x in n.args]
            if isinstance(n.func, ast.Attribute):
                receiver = self.expr(n.func.value, env)
                demand(len(args) == 1, 'container method requires one argument', TypeError)
                if n.func.attr == 'append':
                    demand(type(receiver) is list, 'append requires a list', TypeError)
                    demand(len(receiver) < MAX_ITEMS, 'append exceeds collection bound', Limit)
                    receiver.append(args[0]); bounded(receiver)
                elif n.func.attr == 'add':
                    demand(type(receiver) is set, 'add requires a set', TypeError)
                    receiver.add(args[0]); bounded(receiver)
                return None
            name = n.func.id
            if name == 'len':
                demand(len(args) == 1 and type(args[0]) in (list, tuple, set), 'len requires one container', TypeError)
                return len(args[0])
            if name in ('set', 'list'):
                demand(len(args) <= 1 and (not args or type(args[0]) in (list, tuple, set)), 'container constructor requires zero or one container', TypeError)
                return bounded((set if name == 'set' else list)(args[0] if args else []))
            if name == 'range':
                demand(1 <= len(args) <= 3 and all(type(a) is int for a in args), 'range requires one to three integers', TypeError)
                values = range(*args)
                demand(len(values) <= MAX_ITEMS, 'range exceeds 256 elements', Limit)
                return list(values)
            if name == 'enumerate':
                demand(1 <= len(args) <= 2 and type(args[0]) in (list, tuple) and (len(args) == 1 or type(args[1]) is int), 'enumerate arguments unsupported', TypeError)
                return bounded(list(enumerate(args[0], args[1] if len(args) == 2 else 0)))
            raise Unsupported('unsupported builtin')
        raise Unsupported('expression outside interpreted grammar')
    def block(self, statements, env):
        for statement in statements: self.stmt(statement, env)
    def stmt(self, n, env):
        self.tick()
        if isinstance(n, ast.Return): raise Returned(self.expr(n.value, env) if n.value is not None else None)
        if isinstance(n, ast.Assign):
            value = self.expr(n.value, env)
            for target in n.targets: self.store(target, value, env)
        elif isinstance(n, ast.Expr):
            if not (isinstance(n.value, ast.Constant) and isinstance(n.value.value, str)):
                self.expr(n.value, env)
        elif isinstance(n, ast.If): self.block(n.body if self.expr(n.test, env) else n.orelse, env)
        elif isinstance(n, ast.For):
            iterable = self.expr(n.iter, env)
            demand(type(iterable) in (list, tuple, set), 'for requires a bounded container', TypeError)
            did_break = False
            for item in iterable:
                self.tick(); self.store(n.target, item, env)
                try: self.block(n.body, env)
                except Continued: continue
                except Broken: did_break = True; break
            if not did_break: self.block(n.orelse, env)
        elif isinstance(n, ast.Break): raise Broken()
        elif isinstance(n, ast.Continue): raise Continued()
        elif isinstance(n, ast.Pass): pass
        else: raise Unsupported('statement outside interpreted grammar')
    def call(self, fn, parameter, input_value):
        env = {parameter: input_value}
        try: self.block(fn.body, env)
        except Returned as r: return r.value
        return None


def serializable(value):
    if type(value) is set:
        return {'type':'set','items':[serializable(x) for x in sorted(value,key=repr)]}
    if type(value) is tuple:
        return {'type':'tuple','items':[serializable(x) for x in value]}
    if type(value) is list:
        return [serializable(x) for x in value]
    return value


def cpython_witness(fn, case, interpreted):
    # Only the already validated single function is compiled. Imports, decorators,
    # arbitrary calls/attributes, dunder names and defaults cannot reach this point.
    safe_builtins = {'len':len, 'range':range, 'set':set, 'list':list, 'enumerate':enumerate}
    namespace = {'__builtins__':safe_builtins}
    module = ast.Module(body=[fn], type_ignores=[])
    exec(compile(module, '<validated-model-function>', 'exec'), namespace)
    function = namespace[fn.name]
    observations = []
    for number, (test, prior) in enumerate(zip(case['tests'], interpreted), 1):
        supplied = copy.deepcopy(test['input']); before = copy.deepcopy(supplied)
        counter = [0]
        def trace(frame, event, arg):
            if frame.f_code is not function.__code__: return None
            if event == 'call': frame.f_trace_opcodes = True
            if event == 'opcode':
                counter[0] += 1
                if counter[0] > 100000: raise Limit('CPython exceeded 100,000 opcodes for one vector')
                # Check locals after every prior opcode, bounding growing containers
                # and integers even when CPython iteration semantics differ.
                for value in frame.f_locals.values():
                    if type(value) is range:
                        if len(value) > MAX_ITEMS: raise Limit('CPython range exceeds collection bound')
                    else: bounded(value)
            return trace
        row = {'vector':number, 'input':before, 'expected':test['expected']}
        try:
            sys.settrace(trace)
            try: actual = function(supplied)
            finally: sys.settrace(None)
            bounded(actual)
            correct_type = (actual is None if test['expected'] is None else
                            type(actual) is int if type(test['expected']) is int else
                            type(actual) is list and all(type(x) is int for x in actual))
            unchanged = supplied == before
            new_container = not case.get('mustReturnNewList') or actual is not supplied
            rendered = serializable(actual)
            passed = correct_type and actual == test['expected'] and unchanged and new_container
            parity = ('actual' in prior and rendered == prior['actual']
                      and unchanged == prior['inputUnchanged']
                      and new_container == prior['newListRequirementPassed']
                      and passed == prior['passed'])
            row.update(actual=rendered, inputUnchanged=unchanged, newListRequirementPassed=new_container,
                       passed=passed, interpreterParity=parity, status='passed' if passed else 'wrong_answer')
        except Limit as error:
            row.update(passed=False, interpreterParity=prior.get('status')=='resource_limit',
                       status='resource_limit', reason=str(error))
        except Exception as error:
            row.update(passed=False, interpreterParity=prior.get('status')=='runtime_failure',
                       status='runtime_failure', reason=type(error).__name__+': '+str(error))
        finally: sys.settrace(None)
        row['executedOpcodeCount'] = counter[0]
        observations.append(row)
    return {'performed':True, 'runtime':sys.version.split()[0], 'safeBuiltins':sorted(safe_builtins),
            'opcodeBudgetPerVector':100000, 'localValuesCheckedAfterEveryOpcode':True,
            'tests':observations, 'passed':all(r['passed'] for r in observations),
            'allInterpreterParity':all(r['interpreterParity'] for r in observations)}


def evaluate_text(text, case_id):
    raw_sha = hashlib.sha256(text.encode()).hexdigest()
    receipt = {'schema': 'prime_coding_function_check_v1', 'caseID': case_id,
               'rawOutputSHA256': raw_sha, 'passed': False, 'tests': [],
               'codeWasRewritten': False, 'execution': 'restricted AST interpreter, then bounded CPython with explicit safe builtins when eligible'}
    try:
        pack = json.loads(CASE_PATH.read_text())
        case = next(c for c in pack['cases'] if c['caseID'] == case_id)
        receipt['testVectorFileSHA256'] = hashlib.sha256(CASE_PATH.read_bytes()).hexdigest()
        code, extraction, code_only = extract(text)
        receipt.update(extractedCode=code, extraction=extraction, codeOnlyCompliant=code_only)
        fn, parameter = validate(code, case['functionName'])
        receipt['syntaxValid'] = True
        for number, test in enumerate(case['tests'], 1):
            supplied = copy.deepcopy(test['input']); before = copy.deepcopy(supplied)
            interpreter = Interpreter()
            row = {'vector': number, 'input': before, 'expected': test['expected']}
            try:
                actual = interpreter.call(fn, parameter, supplied)
                bounded(actual)
                correct_type = (actual is None if test['expected'] is None else
                                type(actual) is int if type(test['expected']) is int else
                                type(actual) is list and all(type(x) is int for x in actual))
                unchanged = supplied == before
                new_container = not case.get('mustReturnNewList') or actual is not supplied
                row.update(actual=serializable(actual), inputUnchanged=unchanged, newListRequirementPassed=new_container,
                           passed=correct_type and actual == test['expected'] and unchanged and new_container)
            except Limit as error:
                row.update(passed=False, status='resource_limit', reason=str(error))
            except Unsupported as error:
                row.update(passed=False, status='unsupported_grammar', reason=str(error))
            except (TypeError, ValueError, NameError, IndexError, ZeroDivisionError, OverflowError, RuntimeError, Broken, Continued) as error:
                row.update(passed=False, status='runtime_failure', reason=type(error).__name__ + ': ' + str(error))
            row['interpreterSteps'] = interpreter.steps
            receipt['tests'].append(row)
        receipt['passed'] = all(t['passed'] for t in receipt['tests'])
        statuses = {t.get('status') for t in receipt['tests']}
        receipt['status'] = ('passed' if receipt['passed'] else 'resource_limit' if 'resource_limit' in statuses
                             else 'unsupported_grammar' if 'unsupported_grammar' in statuses
                             else 'runtime_failure' if 'runtime_failure' in statuses else 'wrong_answer')
        receipt['interpreterPassed'] = receipt['passed']
        if statuses & {'resource_limit','unsupported_grammar','runtime_failure'}:
            receipt['cpythonWitness'] = {'performed':False, 'reason':'Candidate did not finish every vector within the bounded interpreter; no CPython pass is claimed.'}
            receipt['passScope'] = 'interpreter_only'
        else:
            witness = cpython_witness(fn, case, receipt['tests'])
            receipt['cpythonWitness'] = witness
            receipt['passScope'] = 'restricted_ast_and_actual_cpython'
            receipt['passed'] = receipt['interpreterPassed'] and witness['passed'] and witness['allInterpreterParity']
            if any(r['status']=='resource_limit' for r in witness['tests']): receipt['status']='resource_limit'
            elif any(r['status']=='runtime_failure' for r in witness['tests']): receipt['status']='runtime_failure'
            elif not witness['allInterpreterParity']: receipt['status']='checker_semantics_mismatch'
            elif not receipt['passed']: receipt['status']='wrong_answer'
    except SyntaxError as error:
        receipt.update(status='syntax_error', syntaxValid=False, codeOnlyCompliant=False, reason=str(error))
    except Unsupported as error:
        receipt.update(status='unsupported_grammar', syntaxValid=True, codeOnlyCompliant=False, reason=str(error))
    except Limit as error:
        receipt.update(status='resource_limit', reason=str(error))
    except StopIteration:
        receipt.update(status='invalid_case', reason='unknown case ID')
    return receipt


def worker():
    import resource
    resource.setrlimit(resource.RLIMIT_CPU, (2, 3))
    address_limit_installed = True
    address_limit_error = None
    try:
        resource.setrlimit(resource.RLIMIT_AS, (512 * 1024 * 1024, 512 * 1024 * 1024))
    except (ValueError, OSError) as error:
        address_limit_installed = False
        address_limit_error = type(error).__name__ + ': ' + str(error)
    request = json.loads(sys.stdin.buffer.read(200000))
    result = evaluate_text(request['text'], request['caseID'])
    result['processLimits'] = {'cpuSoftSeconds': 2, 'cpuHardSeconds': 3, 'addressSpaceBytes': 512 * 1024 * 1024,
                               'parentWallTimeoutSeconds': 4, 'addressLimitInstalled': address_limit_installed, 'addressLimitError': address_limit_error, 'addressLimitNote': 'macOS may reject address-space rlimits; pure AST interpretation independently bounds source, collections, integers, depth and evaluation steps.'}
    print(json.dumps(result))


def check(text, case_id):
    env = dict(os.environ)
    for name in ('PYTHONHOME', 'PYTHONPATH'): env.pop(name, None)
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    base = {'schema': 'prime_coding_function_check_v1', 'caseID': case_id,
            'rawOutputSHA256': hashlib.sha256(text.encode()).hexdigest(), 'passed': False, 'tests': []}
    if len(text.encode()) > MAX_SOURCE:
        return dict(base, status='resource_limit', reason='source exceeds 16 KiB')
    try:
        process = subprocess.run([sys.executable, '-B', str(Path(__file__).resolve()), '--worker'],
                                 input=json.dumps({'text': text, 'caseID': case_id}, ensure_ascii=False),
                                 capture_output=True, text=True, env=env, timeout=4)
    except subprocess.TimeoutExpired:
        return dict(base, status='resource_limit', reason='isolated interpreter exceeded four-second wall limit')
    if process.returncode:
        return dict(base, status='resource_limit' if process.returncode < 0 else 'checker_failure',
                    reason='worker exited ' + str(process.returncode), stderr=process.stderr[:2000])
    try: result = json.loads(process.stdout)
    except json.JSONDecodeError:
        return dict(base, status='checker_failure', reason='invalid checker output', stderr=process.stderr[:2000])
    result['workerExitCode'] = process.returncode
    return result


def self_check():
    fixtures = [
        ('first_good', 'coding-first-duplicate', 'def first_duplicate(nums):\n    seen = set()\n    for n in nums:\n        if n in seen:\n            return n\n        seen.add(n)\n    return None\n', 'passed'),
        ('unique_good', 'coding-stable-unique', 'def stable_unique(nums):\n    result = []\n    for n in nums:\n        if n not in result:\n            result.append(n)\n    return result\n', 'passed'),
        ('unique_enumerate_good', 'coding-stable-unique', 'def stable_unique(nums):\n    result = []\n    for i, n in enumerate(nums):\n        if n not in nums[:i]:\n            result.append(n)\n    return result\n', 'passed'),
        ('always_wrong', 'coding-first-duplicate', 'def first_duplicate(nums):\n    return 0\n', 'wrong_answer'),
        ('alias_return', 'coding-stable-unique', 'def stable_unique(nums):\n    return nums\n', 'wrong_answer'),
        ('refuse_import', 'coding-first-duplicate', 'import os\ndef first_duplicate(nums):\n    return None\n', 'unsupported_grammar'),
        ('refuse_attribute', 'coding-first-duplicate', 'def first_duplicate(nums):\n    return nums.__class__\n', 'unsupported_grammar'),
        ('refuse_recursive_call', 'coding-first-duplicate', 'def first_duplicate(nums):\n    return first_duplicate(nums)\n', 'unsupported_grammar'),
        ('refuse_while', 'coding-first-duplicate', 'def first_duplicate(nums):\n    while True:\n        pass\n', 'unsupported_grammar'),
        ('bounded_growth', 'coding-stable-unique', 'def stable_unique(nums):\n    values = [0]\n    for n in values:\n        values.append(n)\n    return values\n', 'resource_limit'),
        ('bounded_range', 'coding-stable-unique', 'def stable_unique(nums):\n    for n in range(1000000):\n        pass\n    return []\n', 'resource_limit'),
        ('bounded_fuel', 'coding-stable-unique', 'def stable_unique(nums):\n    for a in range(100):\n        for b in range(100):\n            for c in range(100):\n                pass\n    return []\n', 'resource_limit'),
        ('bounded_enumerate_growth', 'coding-stable-unique', 'def stable_unique(nums):\n    values = [0]\n    for i, n in enumerate(values):\n        values.append(n)\n    return values\n', 'resource_limit'),
        ('fenced_good', 'coding-first-duplicate', '```python\ndef first_duplicate(nums):\n    seen = []\n    for n in nums:\n        if n in seen:\n            return n\n        seen.append(n)\n    return None\n```', 'passed'),
    ]
    results = []
    for name, case, code, expected in fixtures:
        result = check(code, case)
        ok = result['status'] == expected
        if expected == 'passed': ok = ok and result.get('cpythonWitness',{}).get('passed') and result['cpythonWitness']['allInterpreterParity']
        if name == 'fenced_good': ok = ok and result['codeOnlyCompliant'] is False and result['codeWasRewritten'] is False
        results.append({'fixture': name, 'expectedStatus': expected, 'actualStatus': result['status'], 'passed': ok,
                        'vectorCount': len(result['tests']), 'cpythonWitnessPerformed':result.get('cpythonWitness',{}).get('performed',False)})
    return {'schema': 'prime_coding_checker_self_check_v1', 'passed': all(r['passed'] for r in results),
            'fixtures': results, 'modelOutputsEvaluated': False,
            'checkerSHA256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', choices=['coding-first-duplicate', 'coding-stable-unique'])
    parser.add_argument('--input', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--self-check', action='store_true')
    parser.add_argument('--worker', action='store_true', help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.worker: worker(); return
    if args.self_check:
        result = self_check()
    else:
        if not args.case or not args.input: parser.error('--case and --input are required')
        if args.input.stat().st_size > MAX_SOURCE:
            result = {'schema':'prime_coding_function_check_v1','caseID':args.case,'passed':False,'tests':[],
                      'status':'resource_limit','reason':'source exceeds 16 KiB'}
        else: result = check(args.input.read_text(), args.case)
    rendered = json.dumps(result, indent=2) + '\n'
    if args.output:
        with args.output.open('x') as f: f.write(rendered)
    print(rendered, end='')
    if args.self_check and not result['passed']: raise SystemExit(1)

if __name__ == '__main__': main()

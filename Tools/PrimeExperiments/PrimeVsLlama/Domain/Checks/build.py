#!/usr/bin/env python3
"""Build six ABI 2 mechanism checks. No signing, admission call, VM or GPU run."""
from pathlib import Path
import hashlib, json, os, signal, subprocess, time

root = Path(__file__).resolve().parent
out = root / 'build01'
out.mkdir(mode=0o700)
sdk = Path('/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk')
clang = Path('/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang')
guest = root.parent / 'Guest'
admission = root.parent / 'Admission'
admission_object = root.parent / 'Native/build01/PrimeInferenceAdmission.o'
native_inputs = root.parent / 'Native/build01/compile-inputs.json'
environment = {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME': str(out), 'TMPDIR': str(out), 'LANG': 'C', 'LC_ALL': 'C'}

def binding(p):
    data = p.read_bytes()
    return {'path': str(p), 'byteCount': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

native = json.loads(native_inputs.read_bytes())
native_pins = native['files']
for p in [admission / 'PrimeInferenceAdmission.c', admission / 'PrimeInferenceAdmission.h', admission_object]:
    assert binding(p) in native_pins, 'current admission not bound by actual native build01'
guest_receipt = json.loads((guest / 'build01/build-result.json').read_bytes())
assert guest_receipt['abiVersion'] == 2
assert binding(guest / 'build01/PrimeGuestBridge.o') == guest_receipt['bridgeObject']
for p in [guest / 'PrimeGuestBridge.c', guest / 'PrimeGuestBridge.h', guest / 'guest.S']:
    assert binding(p) in guest_receipt['sourceFiles']
inputs = [root / 'main.c', Path(__file__), guest / 'PrimeGuestBridge.h', guest / 'PrimeGuestBridge.c',
          guest / 'guest.S', guest / 'build01/PrimeGuestBridge.o', guest / 'build01/build-result.json',
          admission / 'PrimeInferenceAdmission.h', admission / 'PrimeInferenceAdmission.c',
          admission_object, native_inputs]
before = [binding(p) for p in inputs]
commands = []

def run(name, args):
    start = time.monotonic_ns()
    with (out / (name + '.stdout')).open('xb') as stdout, (out / (name + '.stderr')).open('xb') as stderr:
        child = subprocess.Popen(args, cwd=root, env=environment, stdin=subprocess.DEVNULL,
                                 stdout=stdout, stderr=stderr, start_new_session=True)
        timeout = False
        try: status = child.wait(timeout=60)
        except subprocess.TimeoutExpired:
            timeout = True
            try: os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError: pass
            status = child.wait(timeout=10)
    commands.append({'name': name, 'argv': args, 'exitCode': status, 'pid': child.pid,
                     'exactDirectChildReaped': True, 'timedOut': timeout,
                     'elapsedNanoseconds': time.monotonic_ns() - start,
                     'stdout': binding(out / (name + '.stdout')), 'stderr': binding(out / (name + '.stderr'))})
    (out / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    assert status == 0 and not timeout, 'preserved ' + name + ' compiler failure'

os.umask(0o077)
base = [str(clang), '-target', 'arm64-apple-macosx14.0', '-isysroot', str(sdk)]
run('compile', base + ['-std=gnu11', '-O2', '-Wall', '-Wextra', '-Werror',
                       '-c', str(root / 'main.c'), '-o', str(out / 'Checks.o')])
run('link', base + [str(out / 'Checks.o'), str(guest / 'build01/PrimeGuestBridge.o'), str(admission_object),
                    '-framework', 'Hypervisor', '-framework', 'Security', '-framework', 'CoreFoundation',
                    '-o', str(out / 'PrimeGuestABITwoChecks')])
assert before == [binding(p) for p in inputs]
receipt = {'status': 'COMPILED_NOT_EXECUTED', 'scope': 'Six ABI 2 fixed mechanism fixtures: guest fan-in, pre-VM input rejection, full-vocabulary feedback and partial invalid binding. Not model or scientific evidence.',
           'files': before, 'inputsUnchanged': True, 'compiler': binding(clang.resolve()), 'commands': commands,
           'object': binding(out / 'Checks.o'), 'binaryBeforeRootSigning': binding(out / 'PrimeGuestABITwoChecks'),
           'admissionPolicy': 'Unchanged normal same-process admission before each test: com.ergentics.prime.vcpu-inference, team ZCQ435U8JP, hardened runtime, exactly hypervisor=true.',
           'guestRuns': 0, 'admissionInvocations': 0, 'modelRuns': 0, 'gpuRuns': 0, 'signingPerformed': False,
           'runtime': {'arguments': [], 'hardAlarmSeconds': 30, 'expectedChecks': 6,
                       'expectedDeliberateSleepSeconds': 0, 'stdout': 'JSONL admission, all numeric guest observations and per-check/summary outcomes',
                       'unexpectedFailureStopsBeforeNextVM': True}}
(out / 'build-result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({'status': receipt['status'], 'binary': receipt['binaryBeforeRootSigning']}, indent=2))
